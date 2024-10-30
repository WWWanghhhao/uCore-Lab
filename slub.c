#include <list.h>
#include <string.h>
#include <slub.h>

#define SLUB_MAX_OBJS 128
#define SLUB_MIN_OBJS 8
#define SLUB_ALIGN 8

struct slub_obj {
    struct list_head list;
    size_t size;
    int ref_count;
};

struct slub_cache {
    struct list_head free_list[SLUB_MAX_OBJS / SLUB_MIN_OBJS + 1];
    size_t obj_size[SLUB_MAX_OBJS / SLUB_MIN_OBJS + 1];
    int nr_free[SLUB_MAX_OBJS / SLUB_MIN_OBJS + 1];
};

static struct slub_cache slub_cache;

void slub_init(void) {
    memset(&slub_cache, 0, sizeof(slub_cache));
    for (int i = 0; i < SLUB_MAX_OBJS / SLUB_MIN_OBJS + 1; i++) {
        INIT_LIST_HEAD(&slub_cache.free_list[i]);
        slub_cache.obj_size[i] = (i + 1) * SLUB_MIN_OBJS;
    }
}

static int slub_get_class(size_t size) {
    if (size <= SLUB_MIN_OBJS) {
        return 0;
    }
    return (size + SLUB_MIN_OBJS - 1) / SLUB_MIN_OBJS - 1;
}

void *slub_alloc(size_t size) {
    int class = slub_get_class(size);
    if (list_empty(&slub_cache.free_list[class])) {
        // 向操作系统申请新的内存页
        struct Page *page = buddy2_alloc(1);
        if (!page) {
            return NULL;
        }
        for (int i = 0; i < PAGE_SIZE / slub_cache.obj_size[class]; i++) {
            struct slub_obj *obj = (struct slub_obj *)(page->virtual_address + i * slub_cache.obj_size[class]);
            list_add(&obj->list, &slub_cache.free_list[class]);
            obj->size = slub_cache.obj_size[class];
            obj->ref_count = 0;
        }
    }
    struct slub_obj *obj = list_first_entry(&slub_cache.free_list[class], struct slub_obj, list);
    list_del(&obj->list);
    obj->ref_count = 1;
    return obj;
}

void slub_free(void *ptr) {
    struct slub_obj *obj = (struct slub_obj *)((char *)ptr - offsetof(struct slub_obj, list));
    if (--obj->ref_count == 0) {
        int class = slub_get_class(obj->size);
        list_add(&obj->list, &slub_cache.free_list[class]);
    }
}