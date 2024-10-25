#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* All physical memory mapped at this address */
//内核虚拟内存的起始地址
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory 物理内存的最大大小
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用 最初的2MB被OpenSBI占用
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址 内核虚拟内存的结束地址

#define PHYSICAL_MEMORY_END         0x88000000
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000
#define KERNEL_BEGIN_PADDR          0x80200000
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000


#define KSTACKPAGE          2                           // # of pages in kernel stack 内核栈的页数
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack 内核栈的大小

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as physical address.
 * */
struct Page {
    int ref;                        // page frame's reference counter 页面引用计数
    uint64_t flags;                 // array of flags that describe the status of the page frame 页面状态标志位
    unsigned int property;          // the num of free block, used in first fit pm manager 页面块的大小（在 First Fit 分配算法中使用），表示连续空闲的块大小
    list_entry_t page_link;         // free list link 页面与其他页面的链表链接   将页面组织到一个双向链表中
};

/* Flags describing the status of a page frame */
//页面标志位 
//为0，表示该页面被内核保留，不能用于分配和释放
//为1，表示该页面是空闲页面块的头部页面
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

/*SetPageReserved: 设置 PG_reserved 位，将页面标记为保留页面
ClearPageReserved: 清除 PG_reserved 位，取消页面的保留状态
PageReserved: 测试 PG_reserved 位，判断页面是否为保留页面
SetPageProperty: 设置 PG_property 位，将页面标记为空闲块的头部页面
ClearPageProperty: 清除 PG_property 位
PageProperty: 测试 PG_property 位，判断页面是否为空闲块的头部页面*/
#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))

// convert list entry to page 将链表节点 le 转换为对应的 Page 结构体指针
// member 是 Page 结构体中的链表节点成员名（在这里是 page_link）
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/* free_area_t - maintains a doubly linked list to record free (unused) pages 
free_area_t 结构体用于维护一块空闲页面区域的链表信息*/
typedef struct {
    list_entry_t free_list;         // the list header 空闲页面的链表头，用于将空闲页面组织成双向链表
    unsigned int nr_free;           // number of free pages in this free list 记录当前空闲页面的数量
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
