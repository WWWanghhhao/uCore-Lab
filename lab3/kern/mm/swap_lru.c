#include "pmm.h"
#include "vmm.h"
#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>


list_entry_t pra_list_head2;

/*
 * _lru_init_mm - 初始化 LRU 算法所需的数据结构
 * @mm: 内存管理结构
 * 
 * 初始化 pra_list_head2 双向链表,并将 mm->sm_priv 指向该链表头节点。
 * 
 * 返回 0 表示初始化成功。
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
    list_init(&pra_list_head2);
    mm->sm_priv = &pra_list_head2;
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}

/*
 * _lru_map_swappable - 将页面添加到 LRU 算法的双向链表中
 * @mm: 内存管理结构
 * @addr: 虚拟地址
 * @page: 页面结构
 * @swap_in: 页面是否被换入
 * 
 * 首先获取 mm->sm_priv 指向的链表头节点,以及页面在该链表中的节点。
 * 然后检查页面是否已经在链表中,如果在则将其从链表中删除。
 * 最后将页面添加到链表头部。
 * 
 * 返回 0 表示操作成功。
 */
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    
    int isIn = 0;

    list_entry_t* cur = head->next;
    while (cur->next != head) {
        if (cur == entry) {
            isIn = 1;
            break;
        }
        cur = cur->next;
    }
    if(isIn == 1 && head != entry) {
        list_del(entry);
    }
    list_add_before(head, entry);

    return 0;
}

/*
 * _lru_swap_out_victim - 选择 LRU 算法的换出页面
 * @mm: 内存管理结构
 * @ptr_page: 用于返回换出页面的指针
 * @in_tick: 是否在时钟中断中调用
 * 
 * 首先获取 mm->sm_priv 指向的链表头节点。
 * 然后从链表头部取出最早添加的页面作为换出页面,并从链表中删除。
 * 如果链表为空,则返回 NULL。
 * 
 * 返回 0 表示操作成功。
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);

    list_entry_t* entry = list_next(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

static int
_lru_check_swap(void) {
    //pte_t* ptep = get_pte()
    // 页面状态：d1 c1 b1 a1
    // 假设发生一次时钟中断，导致lru
    swap_tick_event(check_mm_struct);
    
    // 页面状态：a0 b0 c0 d0
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);

    // 页面状态：c1 a0 b0 d0
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);

    // 页面状态：d1 c1 a0 b0
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);

    // 页面状态：b1 d1 c1 a0
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);

    // 页面状态：e1 b1 d1 c1
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);

    // 页面状态：c2 e1 b1 d1
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    // 页面状态：a1 c2 e1 b1
    
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
