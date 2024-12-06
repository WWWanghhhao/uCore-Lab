#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}
/*它选择一个可运行状态的进程（PROC_RUNNABLE）并将其切换为当前进程。
如果没有合适的可运行进程，则选择 idleproc（空闲进程）*/
void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    /*local_intr_save 保存中断状态并关闭中断，确保调度过程不被中断。
    调度完成后，通过 local_intr_restore 恢复原始中断状态。*/
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;//当前进程不再需要调度
        //如果当前进程是 idleproc，则从 proc_list 的开头开始查找下一个可运行进程。
        //否则，从当前进程的链表位置（list_link）开始查找。
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        /*增加所选进程的运行次数计数（runs）。
        如果所选进程与当前进程不同，则调用 proc_run(next) 进行上下文切换。*/
        next->runs ++;
        if (next != current) {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}

