#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <assert.h>
#include <stdio.h>

struct buddy {
    unsigned int size;
    unsigned int longest[35000];
};

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

size_t size;//# of page
size_t nr_free;// # of free page in buddy
struct buddy buddy;
struct buddy* self=&buddy;
struct Page* buddy_base;

size_t ChangeToPow2(size_t n){
    size_t size=1;
    for(;size<=n;size*=2);
    return size/2;
}

static void
buddy_init(void) {
    size=nr_free = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned node_size;
    size=ChangeToPow2(n);
    
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    //
    SetPageProperty(base);
    buddy_base=base;
    nr_free=size;

    self->size = size;
    node_size = size * 2;

    for (size_t i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i+1))
        node_size /= 2;
        self->longest[i] = node_size;
    }
    buddy_base=base;
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(self);
    size_t size;
    if(n<=0)
        size=n=1;
    else
        size=ChangeToPow2(n);
    struct Page * page=NULL;
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if (self->longest[index] < size)
        return NULL;

    for(node_size = self->size; node_size != size; node_size /= 2 ) {
        if (self->longest[LEFT_LEAF(index)] >= size)
            index = LEFT_LEAF(index);
        else
            index = RIGHT_LEAF(index);
    }
    nr_free-=size;
    self->longest[index] = 0;
    offset = (index + 1) * node_size - self->size;

    while (index) {
        index = PARENT(index);
        self->longest[index] = 
        MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
    }

    page=offset+buddy_base;
    ClearPageProperty(page);
    page->property=size;
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    unsigned int offset=(base-buddy_base);
    unsigned int node_size, index = 0;
    unsigned int left_longest, right_longest;

    assert(self&&offset >= 0 && offset < self->size);
    node_size = 1;
    index = offset + self->size - 1;//child

    for (; self->longest[index] ; index = PARENT(index)) {
        node_size *= 2;
        if (index == 0)
            return;
    }

    self->longest[index] = node_size;
    struct Page *p = base;
    
    for (; p != base + node_size; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }

    nr_free+=node_size;

    while (index) {
        index = PARENT(index);
        node_size *= 2;

        left_longest = self->longest[LEFT_LEAF(index)];
        right_longest = self->longest[RIGHT_LEAF(index)];
        
        if (left_longest + right_longest == node_size) 
            self->longest[index] = node_size;
        else
            self->longest[index] = MAX(left_longest, right_longest);
    }

}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy2_check(void) {
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
    assert(nr_free == size-5);

    free_page(p1);
    free_page(p2);
}

static void basic_check(void) {
cprintf(
"-----------------------------------------------------"
"\n\nThe test process is as follows:\n"
"First,alloc   p0 p1 p2  p3\n"
"sizes of them 70 35 257 63\n"
"the buddy block:    |64+64|64|64|128+128|512|\n"
"the pages we alloc: |p0   |p1|p3|empty  |p2|\n"
"then,free. p0 p1 p3\n"
"now,the first 512 pages are free\n"
"then alloc:     p4  p5\n"
"sizes of the:   255 255\n"
"now,the distribution in memory space are below:\n"
"|256|256|256|\n"
"|p4 |p5 |p2 |\n"
"Last,free all buddy blocks.\n"
"Notice!addr of pointer is the base addr of the buddy block\n"
"we use cprintf() show the progress and if you want, you can use assert() to judge.\n\n"
"------------------------------------------------------\n");

    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    
    p0=alloc_pages(70);
    p1=alloc_pages(35);
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
    cprintf("p1 %p\n",p1);
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
    
    p2=alloc_pages(257);
    cprintf("p2 %p\n",p2);
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
    
    p3=alloc_pages(63);
    cprintf("p3 %p\n",p3);
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
    
    free_pages(p0,70);    
    cprintf("free p0!\n");
    free_pages(p1,35);
    cprintf("free p1!\n");
    free_pages(p3,63);    
    cprintf("free p3!\n");
    
    p4=alloc_pages(255);
    cprintf("p4 %p\n",p4);
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
    
    p5=alloc_pages(255);
    cprintf("p5 %p\n",p5);
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
        free_pages(p2,257);    
    cprintf("free p2!\n");
        free_pages(p4,255);    
    cprintf("free p4!\n"); 
            free_pages(p5,255);    
    cprintf("free p5!\n");   
    cprintf("CHECK DONE!\n") ;
}


const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = basic_check,
};