#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <stdio.h>
#include <string.h>
#include <../sync/sync.h>
#include <riscv.h>

#include <buddy_pmm.h> //添加buddy system（伙伴系统）分配算法
#include <slub.h>  // 添加slub分配算法

// virtual address of physical page array 一个指向 Page 结构体的指针，用来管理物理内存中的页表。
struct Page *pages;
// amount of physical memory (in pages) 系统中的物理页数量
size_t npage = 0;
// the kernel image is mapped at VA=KERNBASE and PA=info.base 虚拟地址与物理地址之间的偏移
uint64_t va_pa_offset;
// memory starts at 0x80000000 in RISC-V
// DRAM_BASE defined in riscv.h as 0x80000000 基于 DRAM_BASE 计算出的页数，表示内存的基础地址
const size_t nbase = DRAM_BASE / PGSIZE;

// virtual address of boot-time page directory 页表的虚拟地址
uintptr_t *satp_virtual = NULL;
// physical address of boot-time page directory 页表的物理地址
uintptr_t satp_physical;

// physical memory management 管理物理内存的抽象接口
const struct pmm_manager *pmm_manager;


static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance 初始化了物理内存管理器 这里使用 best-fit 策略
static void init_pmm_manager(void) {
    pmm_manager = &best_fit_pmm_manager;//best_fit_pmm_manager  default_pmm_manager buddy_pmm_manager
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - call pmm->init_memmap to build Page struct for free memory 内存块初始化 
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
//分配连续的 n 个页，通过 pmm_manager->alloc_pages(n) 调用内存管理器的具体分配逻辑
//这段代码使用了局部中断保存和恢复机制，确保内存分配过程中的原子性，避免多线程环境下的竞争条件
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag);
    return page;
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
//释放 n 个连续页 调用 pmm_manager->free_pages(base, n) 将指定的物理页块释放回内存管理器
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory 调用 pmm_manager->nr_free_pages() 来获取当前系统中空闲页的数量
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* 确定了物理内存的布局，包括内存的起始地址、结束地址和总大小
 * 初始化页描述符数组 pages，并标记内核占用的页面为保留页 
 * 计算可用物理内存的起始地址和大小，并调用 init 函数进行初始化。
 */ 
static void page_init(void) {
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    uint64_t mem_begin = KERNEL_BEGIN_PADDR;
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; //硬编码取代 sbi_query_memory()接口

    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;
    }

    extern char end[];

    npage = maxpa / PGSIZE; // 物理内存页的总数
    //kernel在end[]结束, pages是剩下的页的开始
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    // 把 pages 指针指向内核所占空间结束后的第一页

    //一开始把所有页面都设置为保留给内核使用的，之后再设置哪些页面可以分配给其他程序
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
   
    // 计算可用物理内存的起始地址 mem_begin
    //按照页面大小PGSIZE进行对齐, ROUNDUP, ROUNDDOWN是在libs/defs.h定义的
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end) {
        //初始化我们可以自由使用的物理内存。
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management 
物理内存管理模块的入口函数
调用 init_pmm_manager() 初始化内存管理策略
调用 page_init() 来检测和初始化系统中的可用物理内存
调用 check_alloc_page() 检查分配功能的正确性
*/
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other size).
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

//调用 pmm_manager->check() 进行内存分配和释放功能的自检 确保内存管理的分配/释放逻辑正确
static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
