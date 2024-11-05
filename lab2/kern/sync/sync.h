// 头文件保护，它确保这个头文件不会被多次包含
#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

/*用来保存当前中断状态，并在中断处于使能状态时禁用中断
read_csr(sstatus)读取 RISC-V 架构中 sstatus 寄存器的值，该寄存器保存当前系统状态，其中 SSTATUS_SIE 标志位表示当前中断是否使能
if (read_csr(sstatus) & SSTATUS_SIE)检查中断是否使能   如果 SSTATUS_SIE 位置为1，表示中断当前是开启的
intr_disable()如果中断开启，则调用 intr_disable() 禁用中断
返回值：返回 1 表示中断之前是开启的，返回 0 表示中断之前是关闭的*/
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

/*该函数用于恢复中断状态。它接收一个 flag 参数
if (flag)检查 flag，如果为 1，说明之前中断是开启的，因此调用 intr_enable() 重新开启中断*/
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

/*这两个宏用来简化中断的保存和恢复操作
local_intr_save(x)将当前中断状态保存到变量 x 中，并禁用中断
通过调用 __intr_save() 函数，x 将存储 __intr_save() 的返回值，即中断状态（1 或 0）
local_intr_restore(x)根据之前保存的 x 状态调用 __intr_restore(x) 函数，决定是否恢复中断
这两个宏一般用于保护关键代码区域，确保在执行这些代码时不会受到中断的干扰

宏设计技巧，它主要用于确保宏在被调用时具有类似函数的行为，避免语法问题和意外的副作用*/
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
