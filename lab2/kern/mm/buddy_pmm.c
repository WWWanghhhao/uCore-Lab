#include "memlayout.h"
#include <buddy_pmm.h>
#include <list.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>

#define LEFT_LEAF(index) ((index) * 2 + 1)    // 左子节点
#define RIGHT_LEAF(index) ((index) * 2 + 2)   // 右子节点
#define PARENT(index) (((index) + 1) / 2 - 1) // 父节点
#define IS_POWER_OF_2(x) (!((x) & ((x) - 1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

struct buddy2 {
  unsigned int size;           // 内存块的总大小
  unsigned int longest[35000]; // 每个节点的最长空闲块大小
} self;

size_t size;    // 内存块的总大小
size_t nr_free; // 当前可分配的内存块数量

struct Page *pages_base; // 内存页的基址指针

unsigned int roundDown(size_t n) {
  // 找到不大于 n 的最大 2 的整次幂
  unsigned int m = 0;
  while ((1 << m) <= n) {
    m++;
  }
  return 1 << (m - 1);
}

unsigned int roundUp(unsigned int size) {
  // 找到不小于 n 的最小 2 的整次幂
  unsigned int m = 0;
  while ((1 << m) < size) {
    m++;
  }
  return 1 << m;
}

void init(void) {
  size = 0;
  nr_free = 0;
}

void buddy2_init_memmap(struct Page *base, size_t n) {
  // 初始化内存映射，创建一个大小为不大于 n 的 2 的整数次幂的二叉树
  unsigned int node_size;

  size = roundDown(n);
  if (size < 1 || !IS_POWER_OF_2(size)) {
    return;
  }

  self.size = size;
  node_size = size * 2;

  // 清理 [base, base+n] 内存区域
  struct Page *p = base;
  for (; p != base + n; p++) {
    assert(PageReserved(p));
    p->flags = p->property = 0;
    set_page_ref(p, 0);
  }

  base->property = n;
  SetPageProperty(base);
  nr_free += size;

  // 通过循环计算每个二叉树节点所监控的内存块大小
  size_t i;
  for (i = 0; i < 2 * size - 1; i++) {
    if (IS_POWER_OF_2(i + 1)) {
      node_size /= 2;
    }
    self.longest[i] = node_size;
  }

  pages_base = base; // pages_base 指向内存页的基址
}

static struct Page *buddy2_alloc(size_t size) {
  struct Page *page = NULL;
  unsigned int index = 0;
  unsigned int node_size;
  unsigned int offset = 0;

  if (size <= 0)
    return NULL;

  if (!IS_POWER_OF_2(size))
    size = roundUp(size);

  if (self.longest[index] <
      size) // (根节点)是否有足够大的空闲块。如果不够大，则返回 NULL。
    return NULL;

  // 从根节点开始遍历二叉树，寻找第一个 >= size 的空闲块
  for (node_size = self.size; node_size != size; node_size /= 2) {
    if (self.longest[LEFT_LEAF(index)] >= size)
      index = LEFT_LEAF(index); // 进左子树
    else
      index = RIGHT_LEAF(index); // 进右子树
  }

  // 可分配数量减少
  nr_free -= size;
  self.longest[index] = 0;

  offset = (index + 1) * node_size - self.size;
  // 向上更新父节点的空闲块大小
  while (index) {
    index = PARENT(index);
    self.longest[index] =
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
  }
  page = offset + pages_base;

  page->property = size;
  ClearPageProperty(page);

  return page;
}

static void buddy2_free(struct Page *pg, size_t n) {
  // 计算给定页数的偏移
  unsigned int offset = (pg - pages_base);
  unsigned int node_size = 1, index = 0;
  unsigned int left_longest, right_longest;

  assert(offset >= 0 && offset < size);

  // offset = (index+1)*node_size - self.size 这里node_size为1，因为是叶节点
  index = offset + self.size - 1;

  for (; self.longest[index]; index = PARENT(index)) {
    node_size *= 2;
    if (index == 0)
      return;
  }
  // 找到实际分配的中间节点位置，并将此中间节点的值恢复
  self.longest[index] = node_size;
  struct Page *p = pg;

  // node_size 是为 pg 分配的内存大小，因此需要将 [pg,pg+node_size]
  // 的内存区域重置
  for (; p != pg + node_size; p++) {
    assert(!PageReserved(p) && !PageProperty(p));
    p->flags = 0;
    set_page_ref(p, 0);
  }

  nr_free += node_size;

  while (index) {
    index = PARENT(index);
    node_size *= 2;
    left_longest = self.longest[LEFT_LEAF(index)];
    right_longest = self.longest[RIGHT_LEAF(index)];
    if (left_longest + right_longest == node_size) {
      self.longest[index] = node_size;
    } else {
      self.longest[index] = MAX(left_longest, right_longest);
    }
  }
}

size_t buddy2_nr_free() { return nr_free; }

static void buddy2_check(void) {
  struct Page *p0, *p1, *p2;
  p0 = p1 = p2 = NULL;
  assert((p0 = alloc_page()) != NULL);
  assert((p1 = alloc_page()) != NULL);
  assert((p2 = alloc_page()) != NULL);

  assert(p0 != p1 && p0 != p2 && p1 != p2);

  assert(page2pa(p0) < npage * PGSIZE);
  assert(page2pa(p1) < npage * PGSIZE);
  assert(page2pa(p2) < npage * PGSIZE);

  unsigned int nr_free_store = nr_free;

  free_page(p0);
  free_page(p1);
  free_page(p2);
  assert(nr_free == size);

  assert((p0 = alloc_page()) != NULL);
  assert((p1 = alloc_pages(3)) != NULL);
  assert((p2 = alloc_page()) != NULL);

  free_page(p0);
  assert(nr_free == size - 5);

  free_page(p1);
  free_page(p2);
}

static void basic_check(void) {
  cprintf("-----------------------------------------------------"
          "\n\nThe test process is as follows:\n"
          "First,alloc   p0 p1 p2  p3\n"
          "sizes of them 80 40 260 60\n"
          "the buddy block:    |64+64|64|64|128+128|512|\n"
          "the pages we alloc: |p0   |p1|p3|empty  |p2|\n"
          "then,free. p0 p1 p3\n"
          "now,the first 512 pages are free\n"
          "then alloc:     p4  p5\n"
          "sizes of the:   250 250\n"
          "now,the distribution in memory space are below:\n"
          "|256|256|256|\n"
          "|p4 |p5 |p2 |\n"
          "Last,free all buddy blocks.\n\n"
          "------------------------------------------------------\n");

  struct Page *p0, *p1, *p2;
  p0 = p1 = NULL;
  p2 = NULL;
  struct Page *p3, *p4, *p5;
  assert((p0 = alloc_page()) != NULL);
  assert((p1 = alloc_page()) != NULL);
  assert((p2 = alloc_page()) != NULL);
  free_page(p0);
  free_page(p1);
  free_page(p2);

  p0 = alloc_pages(80);
  p1 = alloc_pages(40);
  cprintf("p0 %p\n", p0);
  cprintf("p1 %p\n", p1);
  cprintf("p1-p0 equal %p ?=128\n", p1 - p0); // 应该差128

  p2 = alloc_pages(260);
  cprintf("p2 %p\n", p2);
  cprintf("p2-p1 equal %p ?=128+256\n", p2 - p1); // 应该差384

  p3 = alloc_pages(60);
  cprintf("p3 %p\n", p3);
  cprintf("p3-p1 equal %p ?=64\n", p3 - p1); // 应该差64

  free_pages(p0, 80);
  cprintf("free p0!\n");
  free_pages(p1, 40);
  cprintf("free p1!\n");
  free_pages(p3, 60);
  cprintf("free p3!\n");

  p4 = alloc_pages(250);
  cprintf("p4 %p\n", p4);
  cprintf("p2-p4 equal %p ?=512\n", p2 - p4); // 应该差512

  p5 = alloc_pages(250);
  cprintf("p5 %p\n", p5);
  cprintf("p5-p4 equal %p ?=256\n", p5 - p4); // 应该差256
  free_pages(p2, 260);
  cprintf("free p2!\n");
  free_pages(p4, 250);
  cprintf("free p4!\n");
  free_pages(p5, 250);
  cprintf("free p5!\n");
  cprintf("CHECK DONE!\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = init,
    .init_memmap = buddy2_init_memmap,
    .alloc_pages = buddy2_alloc,
    .free_pages = buddy2_free,
    .nr_free_pages = buddy2_nr_free,
    .check = basic_check,
};