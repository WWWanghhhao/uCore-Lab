#include "memlayout.h"
#include "pmm.h"
#include "vmm.h"
#include <defs.h>
#include <list.h>
#include <riscv.h>
// #include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>

list_entry_t pra_list_head2;

/*
 * _lru_init_mm - 初始化 LRU 算法所需的数据结构
 * @mm: 内存管理结构
 *
 * 初始化 pra_list_head2 双向链表,并将 mm->sm_priv 指向该链表头节点。
 *
 * 返回 0 表示初始化成功。
 */
static int _lru_init_mm(struct mm_struct *mm) {
  list_init(&pra_list_head2);
  mm->sm_priv = &pra_list_head2;
  // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
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
 * 然后将页面添加到链表头部。
 *
 * 返回 0 表示操作成功。
 */
static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr,
                              struct Page *page, int swap_in) {
  list_entry_t *head = (list_entry_t *)mm->sm_priv;
  list_entry_t *entry = &(page->pra_page_link);

  assert(entry != NULL && head != NULL);
  list_add(head, entry);
  return 0;

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
static int _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page,
                                int in_tick) {
  list_entry_t *head = (list_entry_t *)mm->sm_priv;
  assert(head != NULL);
  assert(in_tick == 0);

  list_entry_t *entry = list_prev(head);
  if (entry != head) {
    list_del(entry);
    *ptr_page = le2page(entry, pra_page_link);
  } else {
    *ptr_page = NULL;
  }
  return 0;
}

static void _lru_swap_access(struct mm_struct *mm, uintptr_t addr) {
  if (mm != NULL) {
    struct Page *p = get_page(mm->pgdir, addr, NULL);
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    if (head != NULL) {
      list_entry_t *cur = head->next;
      while (cur != head) {
        struct Page *page = le2page(cur, pra_page_link);
        if (page == p) {
          list_del(cur);
          list_add(head, &(page->pra_page_link));
          break;
        }
        cur = cur->next;
      }
    }
  }
}

static int _lru_check_swap(void) {

  cprintf("write Virt Page d in lru_check_swap\n");
  *(unsigned char *)0x4000 = 0x0d;
  _lru_swap_access(check_mm_struct, 0x4000);
  assert(pgfault_num == 4);

  cprintf("write Virt Page c in lru_check_swap\n");
  *(unsigned char *)0x3000 = 0x0c;
  _lru_swap_access(check_mm_struct, 0x3000);
  assert(pgfault_num == 4);

  cprintf("write Virt Page b in lru_check_swap\n");
  *(unsigned char *)0x2000 = 0x0b;
  _lru_swap_access(check_mm_struct, 0x2000);
  assert(pgfault_num == 4);

  cprintf("write Virt Page a in lru_check_swap\n");
  *(unsigned char *)0x1000 = 0x0a;
  _lru_swap_access(check_mm_struct, 0x1000);
  assert(pgfault_num == 4);

  // a b c d
  cprintf("write Virt Page e in lru_check_swap\n");
  *(unsigned char *)0x5000 = 0x0e;
  _lru_swap_access(check_mm_struct, 0x5000);
  assert(pgfault_num == 5);

  // e a b c
  cprintf("write Virt Page a in lru_check_swap\n");

  *(unsigned char *)0x1000 = 0x0a;
  _lru_swap_access(check_mm_struct, 0x1000);
  assert(pgfault_num == 5);

  // a e b c
  cprintf("write Virt Page c in lru_check_swap\n");

  *(unsigned char *)0x3000 = 0x0c;
  _lru_swap_access(check_mm_struct, 0x3000);
  assert(pgfault_num == 5);

  // c a e b
  cprintf("write Virt Page d in lru_check_swap\n");

  *(unsigned char *)0x4000 = 0x0d;
  _lru_swap_access(check_mm_struct, 0x4000);
  assert(pgfault_num == 6);

  // d c a e
  cprintf("write Virt Page b in lru_check_swap\n");

  *(unsigned char *)0x2000 = 0x0b;
  _lru_swap_access(check_mm_struct, 0x2000);
  assert(pgfault_num == 7);

  // b d c a
  cprintf("write Virt Page c in lru_check_swap\n");

  *(unsigned char *)0x3000 = 0x0c;
  _lru_swap_access(check_mm_struct, 0x3000);
  assert(pgfault_num == 7);

  // c b d a
  cprintf("write Virt Page e in lru_check_swap\n");

  *(unsigned char *)0x5000 = 0x0e;
  _lru_swap_access(check_mm_struct, 0x5000);
  assert(pgfault_num == 8);

  // e c b d
  cprintf("write Virt Page a in lru_check_swap\n");

  *(unsigned char *)0x1000 = 0x0a;
  _lru_swap_access(check_mm_struct, 0x1000);
  assert(pgfault_num == 9);

  return 0;
}

static int _lru_init(void) { return 0; }

static int _lru_set_unswappable(struct mm_struct *mm, uintptr_t addr) {
  return 0;
}

static int _lru_tick_event(struct mm_struct *mm) { return 0; }

struct swap_manager swap_manager_lru = {
    .name = "lru swap manager",
    .init = &_lru_init,
    .init_mm = &_lru_init_mm,
    .tick_event = &_lru_tick_event,
    .map_swappable = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap = &_lru_check_swap,
};
