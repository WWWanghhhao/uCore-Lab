#include <slub.h>
#include <list.h>
#include <defs.h>
#include <string.h>
#include <stdio.h>

#include<buddy_pmm.h>
// slab内存块
struct slab_t
{
    int ref;                     // 页的引用次数（保留）
    struct kmem_cache_t *cachep; // 指向该 Slab 所属的仓库对象指针
    uint16_t inuse;              // 已分配对象的数目
    int16_t free;                // 下一个空闲对象偏移量，也就是静态链表的头部
    list_entry_t slab_link;      // Slab链表
};

// sized_cache的chunk_size: 16, 32, 64, 128, 256, 512, 1024, 2048
#define SIZED_CACHE_NUM 8
#define SIZED_CACHE_MIN 16
#define SIZED_CACHE_MAX 2048

//根据链表节点获取相应的 slab_t 结构体  le2page 是一个将链表节点转换为 Page 结构的函数，le 是链表项，link 是 slab_link 字段
#define le2slab(le, link) ((struct slab_t *)le2page((struct Page *)le, link))
//将 slab_t 转换为虚拟地址
#define slab2kva(slab) (page2kva((struct Page *)slab))

static list_entry_t cache_chain;                           // 一个链表头，连接所有的 kmem_cache_t 对象 每个 kmem_cache_t 代表一个特定大小的内存缓存cache_chain对应的链表会链接所有kmem_cache
static struct kmem_cache_t cache_cache;                    // kmem_cache_t仓库，kmem_cache_t也是由Slab算法分配的，因此它会cache所有的kmem_cache_t
                                                            //一个特殊的 kmem_cache_t，用于缓存 kmem_cache_t 对象自身的 Slab 这是因为 kmem_cache_t 也是通过 Slab 分配的，因此它需要一个专门的缓存区
static struct kmem_cache_t *sized_caches[SIZED_CACHE_NUM]; // 指针数组，数组的每一个元素指向1个固定大小的内置仓库，共有8个内置仓库，这些仓库存放实际的对象
                                                            //数组中的每个元素指向一个 kmem_cache_t，每个缓存对象管理特定大小的内存块 如 16 字节、32 字节等
static char *cache_cache_name = "cache";                   // kmem_cache_t仓库的名字
static char *sized_cache_name = "sized";                   // 内置仓库的名字 内置缓存（管理 16 至 2048 字节大小的内存块）

/* 从buddy中申请一页内存作为完全空闲的slab
   1. 从buddy中申请一个page
   2. 初始化空闲链表bufctl，初始化Slab元数据
   3. 初始化buf中的对象
   4. 最后将新的Slab加入到仓库的slab_free中
*/
static void *
kmem_cache_grow(struct kmem_cache_t *cachep)
{
    // 1. 从buddy中申请一个page
    // cprintf("从buddy拿出来a！\n");
    struct Page *page = alloc_page(); // ! 这个是manager中的函数，对接上buddy的接口
    // cprintf("从buddy拿出来b！%p\n", page);
    // cprintf("%p\n", page2pa(page));
    // 获取页的虚拟地址，page2kva在pmm.c实现
    void *kva = page2kva(page);
    // 2. 初始化Slab元数据，初始化空闲链表bufctl
    struct slab_t *slab = (struct slab_t *)page;
    slab->cachep = cachep;        // 设置仓库对象 将 Slab 与对应的 kmem_cache_t 缓存池关联，表示该 Slab 属于哪个缓存
    slab->inuse = slab->free = 0; // 当前没有分配过 初始化 Slab 的使用状态 inuse 代表已分配的对象数量，free 表示下一个空闲对象的偏移量
    // 在这一页开头构建静态链表（由于是初始化，直接按顺序穿起来），记录可用内存区块的偏移
    int16_t *bufctl = kva;
    for (int i = 1; i < cachep->num; i++)
        bufctl[i - 1] = i;
    bufctl[cachep->num - 1] = -1;  //将链表的最后一个元素设为 -1，表示链表的终止
    // 3. 初始化buf中的对象
    // 计算静态链表后的虚拟地址 将 bufctl 指针后移到 Slab 中存储对象的部分，开始对每个对象进行初始化
    void *buf = bufctl + cachep->num;
    // 有构造函数才做
    if (cachep->ctor)
        for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
            cachep->ctor(p, cachep, cachep->objsize);
    // 4. 最后将新的Slab加入到仓库的slab_free中
    list_add(&(cachep->slabs_free), &(slab->slab_link)); // 当前这一页全空闲
    return slab;
}

/*实现了 kmem_slab_destroy 函数，用于释放一个 Slab 块对应的页内存，析构 Slab 中的对象，并将内存页归还给 Buddy 分配器*/ 
static void
kmem_slab_destroy(struct kmem_cache_t *cachep, struct slab_t *slab)
{
    // 计算buf的虚拟地址
    struct Page *page = (struct Page *)slab; //将 slab 指针转换为 Page 结构体的指针
    int16_t *bufctl = page2kva(page);
    void *buf = bufctl + cachep->num;// num每个Slab保存的对象数目
    // 有析构函数才做 
    if (cachep->dtor)
        // 析构每个对象 
        for (void *p = buf; p < buf + cachep->objsize * cachep->num; p += cachep->objsize)
            cachep->dtor(p, cachep, cachep->objsize);
    
    page->property = page->flags = 0;// 清除property和flag
    list_del(&(page->page_link));//从相关的链表中删除 page，以确保它不再被引用或使用
    free_page(page); // ! 这个是manager中的函数，对接上buddy的接口
}

// 计算size大小的对象应该从第几个sized_cache分配
static int
kmem_sized_index(size_t size)
{
    // 向上取整
    size_t rsize = ROUNDUP(size, 2);
    if (rsize < SIZED_CACHE_MIN)
        rsize = SIZED_CACHE_MIN;
    // 寻找索引
    int index = 0;
    for (int t = rsize / 32; t; t /= 2)
        index++;
    return index;
}

// ! 测试部分代码
#define TEST_OBJECT_LENTH 2046
#define TEST_OBJECT_CTVAL 0x22
#define TEST_OBJECT_DTVAL 0x11

static const char *test_object_name = "test";

struct test_object
{
    char test_member[TEST_OBJECT_LENTH];
};

static void
test_ctor(void *objp, struct kmem_cache_t *cachep, size_t size)
{
    char *p = objp;
    for (int i = 0; i < size; i++)
        p[i] = TEST_OBJECT_CTVAL;
}

static void
test_dtor(void *objp, struct kmem_cache_t *cachep, size_t size)
{
    char *p = objp;
    for (int i = 0; i < size; i++)
        p[i] = TEST_OBJECT_DTVAL;
}

static size_t
list_length(list_entry_t *listelm)
{
    size_t len = 0;
    list_entry_t *le = listelm;
    while ((le = list_next(le)) != listelm)
        len++;
    return len;
}

static void
check_kmem()
{

    assert(sizeof(struct Page) == sizeof(struct slab_t)); // 页的大小等于slab的大小

    size_t fp = nr_free_pages();

    // 创建一个测试仓库，初始化对象内存空间全为TEST_OBJECT_CTVAL
    // test_object大小为2046字节
    //名为 test 的仓库 cp0，用于存储 test_object 类型的对象。构造和析构函数分别初始化和清理对象
    struct kmem_cache_t *cp0 = kmem_cache_create(test_object_name, sizeof(struct test_object), test_ctor, test_dtor);
    assert(cp0 != NULL);                                         // 创建成功
    assert(kmem_cache_size(cp0) == sizeof(struct test_object));  // 对象大小一致
    assert(strcmp(kmem_cache_name(cp0), test_object_name) == 0); // 名字一样

    struct test_object *p0, *p1, *p2, *p3, *p4, *p5;
    char *p;
    // 在仓库中分配5个对象
    assert((p0 = kmem_cache_alloc(cp0)) != NULL);
    assert((p1 = kmem_cache_alloc(cp0)) != NULL);
    assert((p2 = kmem_cache_alloc(cp0)) != NULL);
    assert((p3 = kmem_cache_alloc(cp0)) != NULL);
    assert((p4 = kmem_cache_alloc(cp0)) != NULL);
    p = (char *)p4;
    // 对象的初始值应该都是TEST_OBJECT_CTVAL
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == TEST_OBJECT_CTVAL);
    assert((p5 = kmem_cache_zalloc(cp0)) != NULL);
    p = (char *)p5;
    // 由于调用的是zalloc，也就是说分配一个对象之后对象内存区域全初始化为零，所以有p[i] == 0
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == 0);
    // 由于刚刚总共分配了6个对象（2046+2），现在应该从buddy取出了3页，因此空闲页数比之前少3
    assert(nr_free_pages() + 3 == fp);
    // 当前3页应当全被占满，都在slabs_full链表中
    assert(list_empty(&(cp0->slabs_free)));
    assert(list_empty(&(cp0->slabs_partial)));
    assert(list_length(&(cp0->slabs_full)) == 3);
    // 释放三个对象，现在slabs_free、slabs_partial、slabs_full应当各有一块slab
    kmem_cache_free(cp0, p3);
    kmem_cache_free(cp0, p4);
    kmem_cache_free(cp0, p5);
    assert(list_length(&(cp0->slabs_free)) == 1);
    assert(list_length(&(cp0->slabs_partial)) == 1);
    assert(list_length(&(cp0->slabs_full)) == 1);
    // 释放slabs_free链表中的所有slab
    assert(kmem_cache_shrink(cp0) == 1);    // 一共释放了1个slab
    assert(nr_free_pages() + 2 == fp);      // 现在多了一个空闲页
    assert(list_empty(&(cp0->slabs_free))); // slabs_free变空
    // p4处的内存被释放，现在对象内存处的值都是析构函数中的TEST_OBJECT_DTVAL
    p = (char *)p4;
    for (int i = 0; i < sizeof(struct test_object); i++)
        assert(p[i] == TEST_OBJECT_DTVAL);
    // 释放对象，现在slabs_free又多了两块slab
    kmem_cache_free(cp0, p0);
    kmem_cache_free(cp0, p1);
    kmem_cache_free(cp0, p2);
    // 释放所有全空闲slab，共释放2个
    assert(kmem_cache_reap() == 2);
    // 现在页全部空闲了
    assert(nr_free_pages() == fp);
    // 释放仓库
    kmem_cache_destroy(cp0);

    // 在内置仓库中申请内存
    assert((p0 = kmalloc(2048)) != NULL);
    // 空闲页少1
    assert(nr_free_pages() + 1 == fp);
    // 在内置仓库中释放对象
    kfree(p0);
    // 释放后，多出一个全空闲slab，释放掉
    assert(kmem_cache_reap() == 1);
    // 空闲页复原
    assert(nr_free_pages() == fp);

    cprintf("check_kmem() succeeded!\n");
}
// ! 测试部分代码结束

/* 创建一个kmem_cache
   从cache_cache中获得一个对象，初始化成员，最后将对象加入仓库链表cache_chain
*/
struct kmem_cache_t *
kmem_cache_create(const char *name, size_t size,
                  void (*ctor)(void *, struct kmem_cache_t *, size_t),
                  void (*dtor)(void *, struct kmem_cache_t *, size_t))
{
    // 至少得装得下一个对象，2是空闲表一项的大小
    assert(size <= (PGSIZE - 2));
    // sized_cache是从cache_cache中分配出来的
    struct kmem_cache_t *cachep = kmem_cache_alloc(&(cache_cache));
    if (cachep != NULL)
    {
        cachep->objsize = size;
        // 计算Slab中对象的数目，由于空闲表每一项占用2字节，所以每个Slab的对象数目就是：4096字节/(2字节+对象大小)
        cachep->num = PGSIZE / (sizeof(int16_t) + size);
        cachep->ctor = ctor;
        cachep->dtor = dtor;
        // 初始化名字
        memcpy(cachep->name, name, CACHE_NAMELEN);
        // 初始化链表
        list_init(&(cachep->slabs_full));
        list_init(&(cachep->slabs_partial));
        list_init(&(cachep->slabs_free));
        // 加入cache_chain中
        list_add(&(cache_chain), &(cachep->cache_link));
    }
    return cachep;
}

// 销毁kmem_cache_t及其中所有的Slab销毁一个 kmem_cache_t 缓存以及其所有关联的 slab，释放资源并清除链表中对其的引用
void kmem_cache_destroy(struct kmem_cache_t *cachep)
{
    list_entry_t *head, *le;
    // 销毁slabs_full
    head = &(cachep->slabs_full);//将 head 指向 slabs_full 链表的头部
    le = list_next(head);//通过循环遍历 slabs_full 链表，逐个调用 kmem_slab_destroy 函数销毁其中的 slab，释放内存
    while (le != head)
    {
        list_entry_t *temp = le;//使用 temp 临时保存当前节点，销毁后指向下一个节点，直到回到头部
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    // 销毁slabs_partial
    head = &(cachep->slabs_partial);
    le = list_next(head);
    while (le != head)
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    // 销毁slabs_free
    head = &(cachep->slabs_free);
    le = list_next(head);
    while (le != head)
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link));
    }
    // 在cache_cache中释放cachep
    kmem_cache_free(&(cache_cache), cachep);
}

/* 从cachep指向的仓库中分配一个对象
   1. 先查找slabs_partial（部分满），如果没找到空闲区域则查找slabs_free（全空）
   2. 还是没找到就从buddy中申请一个新的slab
   3. 分配内存，并更新各个链表与记录
   4. 从slab分配一个对象后，如果slab变满，那么将slab加入slabs_full
*/
void *
kmem_cache_alloc(struct kmem_cache_t *cachep)
{
    // cprintf("开始分配！\n");
    list_entry_t *le = NULL; //定义一个链表指针 le，用于指向当前可以分配对象的 slab
    // 1. 先查找slabs_partial
    if (!list_empty(&(cachep->slabs_partial)))
        le = list_next(&(cachep->slabs_partial));
    // 若 slabs_partial 为空，则检查 slabs_free，其中包含全空的 slab
    else
    {
        // 2. 如果 slabs_free 也为空，则调用 kmem_cache_grow 从 buddy 系统中申请一个新的 slab 并初始化
        if (list_empty(&(cachep->slabs_free)) && kmem_cache_grow(cachep) == NULL)
            // 如果 kmem_cache_grow 也失败，说明分配内存不足，返回 NULL
            return NULL;
        // 申请之后slabs_free就不是空了，所以是能取出来的
        le = list_next(&(cachep->slabs_free));
    }
    // 3. 分配内存，并更新各个链表与记录
    // 先把这一块slab摘下来 从 slabs_partial 或 slabs_free 中取出一个 slab，解除与链表的连接
    list_del(le);
    // 把这个list_entry转为page，再转为slab块
    struct slab_t *slab = le2slab(le, page_link);
    // 转为虚拟地址
    void *kva = slab2kva(slab);
    //bufctl 指向对象的空闲链表
    int16_t *bufctl = kva;
    // 偏移到buf
    void *buf = bufctl + cachep->num;
    // 从buf根据free偏移到第一个还能申请来存放对象的地址
    void *objp = buf + slab->free * cachep->objsize;
    // 取下这片区域，标记为使用，更新slab的空闲表
    //增加 inuse 计数，标记新分配的对象，并将 free 指向下一个空闲对象
    slab->inuse++;
    slab->free = bufctl[slab->free];
    // 4. 从slab分配一个对象后，如果slab变满，那么将slab加入slabs_full
    if (slab->inuse == cachep->num)
        list_add(&(cachep->slabs_full), le);
    else
        // 否则就放入slabs_partial
        list_add(&(cachep->slabs_partial), le);
    return objp;
}

// 使用kmem_cache_alloc分配一个对象之后将对象内存区域初始化为零
void *
kmem_cache_zalloc(struct kmem_cache_t *cachep)
{
    void *objp = kmem_cache_alloc(cachep);//调用 kmem_cache_alloc 函数从 cachep 指向的缓存中分配一个对象 分配成功后，objp 指向分配的对象内存地址
    memset(objp, 0, cachep->objsize); //使用 memset 函数将 objp 指向的内存区域初始化为零 cachep->objsize 表示对象的大小，确保对象的所有字节被置为零
    return objp;
}

/* 将对象objp从cachep中的Slab中释放
   也就是将对象空间加入空闲链表（slabs_partial或者slabs_free），更新Slab元信息
   如果Slab变空，那么将Slab加入slabs_free链表
*/
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp)
{
    // 获取对象所在的slab
    void *base = page2kva(pages); //获取页数组 pages 的起始虚拟地址 base
    void *kva = ROUNDDOWN(objp, PGSIZE); //获取对象所在页的基地址 kva
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE]; //将 kva 转换为 pages 中相应的 Slab 元数据地址，通过页索引来定位 Slab
    // 获取对象在slab中的偏移
    int16_t *bufctl = kva; //bufctl 指向 Slab 中管理空闲对象链表的区域
    void *buf = bufctl + cachep->num; //buf 表示 Slab 中第一个对象的起始地址
    int offset = (objp - buf) / cachep->objsize; 
    // 更新Slab元信息
    list_del(&(slab->slab_link)); // 将当前 Slab 从原来的链表（slabs_partial 或 slabs_full）中删除
    bufctl[offset] = slab->free; //将对象插入空闲链表中
    slab->inuse--; //更新使用计数
    slab->free = offset; //更新空闲链表头部
    // 如果Slab变空，那么将Slab加入slabs_free链表，否则加入slabs_partial
    if (slab->inuse == 0)
        list_add(&(cachep->slabs_free), &(slab->slab_link));
    else
        list_add(&(cachep->slabs_partial), &(slab->slab_link));
}

// 获得仓库中对象的大小
size_t
kmem_cache_size(struct kmem_cache_t *cachep)
{
    return cachep->objsize;
}

// 获得仓库的名称
const char *
kmem_cache_name(struct kmem_cache_t *cachep)
{
    return cachep->name;
}

// 释放仓库的slabs_free链表中所有Slab
int kmem_cache_shrink(struct kmem_cache_t *cachep)
{
    int count = 0; //用于记录释放的 Slab 数量
    list_entry_t *le = list_next(&(cachep->slabs_free));
    while (le != &(cachep->slabs_free)) //遍历 slabs_free 链表中每一个 Slab，直到回到链表头部
    {
        list_entry_t *temp = le;
        le = list_next(le);
        kmem_slab_destroy(cachep, le2slab(temp, page_link)); //kmem_slab_destroy 用于释放 temp 所指向的 Slab 页面，并将其归还到物理内存分配器
        count++;
    }
    return count;
}

/* 释放所有的全空闲slab
   遍历cache_chain仓库链表，对每一个仓库进行kmem_cache_shrink操作
*/
int kmem_cache_reap()
{
    int count = 0;
    list_entry_t *le = &(cache_chain);
    while ((le = list_next(le)) != &(cache_chain))
        count += kmem_cache_shrink(to_struct(le, struct kmem_cache_t, cache_link));
    return count;
}

// 找到大小最合适的内置仓库，申请一个对象
void *
kmalloc(size_t size)
{
    assert(size <= SIZED_CACHE_MAX);
    return kmem_cache_alloc(sized_caches[kmem_sized_index(size)]);
}

// 找到对象所在的 Slab 并调用相应缓存的释放函数，释放对象的内存
void kfree(void *objp)
{
    void *base = slab2kva(pages);
    void *kva = ROUNDDOWN(objp, PGSIZE);
    struct slab_t *slab = (struct slab_t *)&pages[(kva - base) / PGSIZE]; //根据页面起始地址找到 objp 所在的 Slab，并将该页面结构体转换为 slab_t 类型
    kmem_cache_free(slab->cachep, objp); //通过 Slab 的缓存指针 cachep 调用 kmem_cache_free 函数，释放该对象的内存
}

/* 1. 初始化kmem_cache_t仓库 由于kmem_cache_t也是由Slab算法分配的，所以需要预先手动初始化一个kmem_cache_t仓库
   2. 初始化内置仓库  初始化8个固定大小的内置仓库
   3. 测试slub分配器
*/
void kmem_int()
{

    // 1. 初始化kmem_cache的cache仓库，简称为cache_cache
    /*cache_cache 是专门用于分配 kmem_cache_t 对象的缓存，kmem_cache_t 是 Slab 分配器中缓存对象的结构体
    为了支持 Slab 分配器正常运行，需要手动初始化一个专用于 kmem_cache_t 的缓存（即 cache_cache）*/
    cache_cache.objsize = sizeof(struct kmem_cache_t); //指定对象大小为 kmem_cache_t 结构体的大小
    cache_cache.num = PGSIZE / (sizeof(int16_t) + sizeof(struct kmem_cache_t)); // 算num的时候还要考虑前面int16_t的信息
    cache_cache.ctor = NULL;
    cache_cache.dtor = NULL;
    memcpy(cache_cache.name, cache_cache_name, CACHE_NAMELEN);
    // 初始化cache_cache的链表
    list_init(&(cache_cache.slabs_full));
    list_init(&(cache_cache.slabs_partial));
    list_init(&(cache_cache.slabs_free));

    // 初始化cache_chain（这个链表会串起来所有的kmem_cache_t）
    list_init(&(cache_chain));
    // 将第一个kmem_cache_t也就是cache_cache加入到cache_chain对应的链表中 作为第一个缓存
    list_add(&(cache_chain), &(cache_cache.cache_link));

    // 2. 初始化8个固定大小的内置仓库
    for (int i = 0, size = 16; i < SIZED_CACHE_NUM; i++, size *= 2)//for 循环从大小为 16 开始，递增一倍，直至总共初始化 8 个大小不同的内置缓存
        sized_caches[i] = kmem_cache_create(sized_cache_name, size, NULL, NULL); //为每个大小创建一个缓存，用于内核分配内存对象

    // 3. 进行测试
    check_kmem();
}