#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

#include <assert.h>
#include <atomic.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>

// pmm_manager is a physical memory management class. A special pmm manager - 
// pmm_manager 是一个物理内存管理器的抽象接口，定义了管理物理内存所需的操作
// XXX_pmm_manager
// only needs to implement the methods in pmm_manager class, then
// XXX_pmm_manager can be used
// by ucore to manage the total physical memory space.
struct pmm_manager {
    const char *name;  // XXX_pmm_manager's name 管理器的名字，用于识别当前使用的内存管理策略
    void (*init)(
        void);  // initialize internal description&management data structure
                // (free block list, number of free block) of XXX_pmm_manager
                // 初始化函数，用于初始化内存管理器的数据结构，如空闲内存块列表。
    void (*init_memmap)(
        struct Page *base,
        size_t n);  // setup description&management data structcure according to
                    // the initial free physical memory space
                    // 根据初始的空闲物理内存空间设置内存管理数据结构，将一段空闲的物理内存映射到 Page 结构体
    struct Page *(*alloc_pages)(
        size_t n);  // allocate >=n pages, depend on the allocation algorithm 分配连续的物理页，n 表示所需的页数
    void (*free_pages)(struct Page *base, size_t n);  // free >=n pages with
                                                      // "base" addr of Page
                                                      // descriptor
                                                      // structures(memlayout.h)
                                                      // 释放连续的 n 个物理页
    size_t (*nr_free_pages)(void);  // return the number of free pages 返回当前系统中剩余的空闲页数
    void (*check)(void);            // check the correctness of XXX_pmm_manager 检查内存管理器的正确性 用于调试
};

extern const struct pmm_manager *pmm_manager; //当前正在使用的物理内存管理器

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);
size_t nr_free_pages(void); // number of free pages

#define alloc_page() alloc_pages(1)
#define free_page(page) free_pages(page, 1)


/* *
 * PADDR - takes a kernel virtual address (an address that points above
 * KERNBASE),
 * where the machine's maximum 256MB of physical memory is mapped and returns
 * the
 * corresponding physical address.  It panics if you pass it a non-kernel
 * virtual address.
 * */
// PADDR 用来将内核虚拟地址转换为物理地址
// 首先检查虚拟地址 kva 是否位于内核地址空间之上（KERNBASE），否则抛出异常
// 将虚拟地址减去偏移量得到对应的物理地址
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 * */

// KADDR 用于将物理地址转换为内核虚拟地址：
// 它根据物理页号（PPN）检查地址是否合法（即是否超过总页数 npage）
// 如果地址合法，它将物理地址加上偏移量 va_pa_offset，得到虚拟地址
#define KADDR(pa)                                                
    ({                                                           
        uintptr_t __m_pa = (pa);                                 
        size_t __m_ppn = PPN(__m_pa);                            
        if (__m_ppn >= npage) {                                  
            panic("KADDR called with invalid pa %08lx", __m_pa); 
        }                                                        
        (void *)(__m_pa + va_pa_offset);                         
    })

extern struct Page *pages; //用于管理物理页的数组，每个元素是一个 Page 结构体，表示一个物理页
extern size_t npage; //表示系统中物理内存的页数
extern const size_t nbase; //系统内存的起始页号 DRAM_BASE 的页号
extern uint64_t va_pa_offset; //虚拟地址与物理地址之间的偏移

//将一个 Page 结构体指针转换为页号（ppn）    通过计算它在 pages 数组中的位置并加上 nbase 得到物理页号
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; } 

//将 Page 结构体转换为物理地址    它通过页号左移页大小位数（PGSHIFT，通常为12，表示4KB页）来得到物理地址
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

// 页转虚拟地址
static inline void *
page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
}


//获取页面的引用计数
static inline int page_ref(struct Page *page) { return page->ref; }
//设置页面的引用计数为指定值
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
//将页面的引用计数加1，返回新的引用计数
static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}
//将页面的引用计数减1，返回新的引用计数
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}

//pa2page 将物理地址转换为 Page 结构体
//首先检查地址是否合法（PPN(pa) 小于 npage），如果合法，则通过页号减去 nbase 从 pages 数组中获取对应的 Page 结构体。
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}

//flush_tlb 通过执行 sfence.vm 指令刷新 TLB（转换查找缓冲区），确保虚拟地址到物理地址的映射被重新加载
static inline void flush_tlb() { asm volatile("sfence.vm"); }
extern char bootstack[], bootstacktop[]; // defined in entry.S 表示内核引导栈的起始地址（bootstack）和栈顶地址（bootstacktop）

#endif /* !__KERN_MM_PMM_H__ */
