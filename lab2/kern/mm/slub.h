#ifndef __KERN_MM_SLUB_H__
#define __KERN_MM_SLUB_H__

#include <pmm.h>
#include <list.h>

//缓存名字的最大长度为 16
#define CACHE_NAMELEN 16

struct kmem_cache_t
{
    list_entry_t slabs_full;                             // 全满Slab链表
    list_entry_t slabs_partial;                          // 部分空闲Slab链表
    list_entry_t slabs_free;                             // 全空闲Slab链表
    uint16_t objsize;                                    // 对象大小
    uint16_t num;                                        // 每个Slab保存的对象数目
    void (*ctor)(void *, struct kmem_cache_t *, size_t); // 构造函数
    void (*dtor)(void *, struct kmem_cache_t *, size_t); // 析构函数
    char name[CACHE_NAMELEN];                            // 仓库名称
    list_entry_t cache_link;                             // 仓库链表
};

/*kmem_cache_create创建一个新的缓存池
name 是缓存池的名字 size 是每个对象的大小 ctor 是对象的构造函数 dtor 是对象的析构函数
它返回一个指向 kmem_cache_t 结构的指针，表示新创建的缓存池*/
struct kmem_cache_t *
kmem_cache_create(const char *name, size_t size,
                  void (*ctor)(void *, struct kmem_cache_t *, size_t),
                  void (*dtor)(void *, struct kmem_cache_t *, size_t));
//kmem_cache_destroy销毁一个缓存池，释放所有资源
void kmem_cache_destroy(struct kmem_cache_t *cachep);
//kmem_cache_alloc从指定的缓存池中分配一个对象
void *kmem_cache_alloc(struct kmem_cache_t *cachep);
//kmem_cache_zalloc类似 kmem_cache_alloc，但分配的内存被清零
void *kmem_cache_zalloc(struct kmem_cache_t *cachep);
//kmem_cache_free释放从缓存池中分配的对象
void kmem_cache_free(struct kmem_cache_t *cachep, void *objp);
//kmem_cache_size返回缓存池中每个对象的大小
size_t kmem_cache_size(struct kmem_cache_t *cachep);
//kmem_cache_name返回缓存池的名字
const char *kmem_cache_name(struct kmem_cache_t *cachep);
//kmem_cache_shrink收缩缓存池，释放空闲的 slab 以节省内存
int kmem_cache_shrink(struct kmem_cache_t *cachep);
//kmem_cache_reap回收整个系统中所有的缓存池，释放可以回收的内存
int kmem_cache_reap();
//kmalloc 和 kfree类似标准库中的 malloc 和 free，用于在 SLUB 系统中分配和释放内存
void *kmalloc(size_t size);
void kfree(void *objp);
// size_t ksize(void *objp);

void kmem_int();

#endif /* ! __KERN_MM_SLUB_H__ */