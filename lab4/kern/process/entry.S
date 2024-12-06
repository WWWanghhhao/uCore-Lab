.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
	jalr s0

	jal do_exit
#将此前设置在 tf 中的参数位置 s1转移到 a0 作为实际的参数，并且跳转到 s0 对应的地址处，
#即 kernel_thread 调用时传入的 fn，此处即为 init_main 函数的地址。

#do_exit 时会直接调用 panic 并且 kmonitor 中调用了 sbi_shutdown 所以操作系统在执行完 init_main 之后会直接关机。

