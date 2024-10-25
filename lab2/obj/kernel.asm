
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <self>
ffffffffc020003a:	00028617          	auipc	a2,0x28
ffffffffc020003e:	71e60613          	addi	a2,a2,1822 # ffffffffc0228758 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	514010ef          	jal	ra,ffffffffc020155e <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	51e50513          	addi	a0,a0,1310 # ffffffffc0201570 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	623000ef          	jal	ra,ffffffffc0200e88 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	7e3000ef          	jal	ra,ffffffffc0201088 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	7ad000ef          	jal	ra,ffffffffc0201088 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	45450513          	addi	a0,a0,1108 # ffffffffc0201590 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	45e50513          	addi	a0,a0,1118 # ffffffffc02015b0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	41258593          	addi	a1,a1,1042 # ffffffffc0201570 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	46a50513          	addi	a0,a0,1130 # ffffffffc02015d0 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <self>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	47650513          	addi	a0,a0,1142 # ffffffffc02015f0 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00028597          	auipc	a1,0x28
ffffffffc020018a:	5d258593          	addi	a1,a1,1490 # ffffffffc0228758 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	48250513          	addi	a0,a0,1154 # ffffffffc0201610 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00029597          	auipc	a1,0x29
ffffffffc020019e:	9bd58593          	addi	a1,a1,-1603 # ffffffffc0228b57 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	47450513          	addi	a0,a0,1140 # ffffffffc0201630 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	49660613          	addi	a2,a2,1174 # ffffffffc0201660 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	4a250513          	addi	a0,a0,1186 # ffffffffc0201678 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	4aa60613          	addi	a2,a2,1194 # ffffffffc0201690 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	4c258593          	addi	a1,a1,1218 # ffffffffc02016b0 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	4c250513          	addi	a0,a0,1218 # ffffffffc02016b8 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	4c460613          	addi	a2,a2,1220 # ffffffffc02016c8 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	4e458593          	addi	a1,a1,1252 # ffffffffc02016f0 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	4a450513          	addi	a0,a0,1188 # ffffffffc02016b8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	4e060613          	addi	a2,a2,1248 # ffffffffc0201700 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	4f858593          	addi	a1,a1,1272 # ffffffffc0201720 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	48850513          	addi	a0,a0,1160 # ffffffffc02016b8 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	4c650513          	addi	a0,a0,1222 # ffffffffc0201730 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	4cc50513          	addi	a0,a0,1228 # ffffffffc0201758 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	526c0c13          	addi	s8,s8,1318 # ffffffffc02017c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	4d690913          	addi	s2,s2,1238 # ffffffffc0201780 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	4d648493          	addi	s1,s1,1238 # ffffffffc0201788 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	4d4b0b13          	addi	s6,s6,1236 # ffffffffc0201790 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	3eca0a13          	addi	s4,s4,1004 # ffffffffc02016b0 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	13a010ef          	jal	ra,ffffffffc020140a <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	4e2d0d13          	addi	s10,s10,1250 # ffffffffc02017c8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	236010ef          	jal	ra,ffffffffc020152a <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	222010ef          	jal	ra,ffffffffc020152a <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	202010ef          	jal	ra,ffffffffc0201548 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	1c4010ef          	jal	ra,ffffffffc0201548 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	41250513          	addi	a0,a0,1042 # ffffffffc02017b0 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00028317          	auipc	t1,0x28
ffffffffc02003b0:	34c30313          	addi	t1,t1,844 # ffffffffc02286f8 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	43650513          	addi	a0,a0,1078 # ffffffffc0201810 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	cb050513          	addi	a0,a0,-848 # ffffffffc02020a0 <commands+0x8d8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	0b8010ef          	jal	ra,ffffffffc02014d8 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00028797          	auipc	a5,0x28
ffffffffc020042a:	2c07bd23          	sd	zero,730(a5) # ffffffffc0228700 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	40250513          	addi	a0,a0,1026 # ffffffffc0201830 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	0920106f          	j	ffffffffc02014d8 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	06e0106f          	j	ffffffffc02014be <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	09e0106f          	j	ffffffffc02014f2 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	3d250513          	addi	a0,a0,978 # ffffffffc0201850 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	3da50513          	addi	a0,a0,986 # ffffffffc0201868 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	3e450513          	addi	a0,a0,996 # ffffffffc0201880 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	3ee50513          	addi	a0,a0,1006 # ffffffffc0201898 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	3f850513          	addi	a0,a0,1016 # ffffffffc02018b0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	40250513          	addi	a0,a0,1026 # ffffffffc02018c8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	40c50513          	addi	a0,a0,1036 # ffffffffc02018e0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	41650513          	addi	a0,a0,1046 # ffffffffc02018f8 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	42050513          	addi	a0,a0,1056 # ffffffffc0201910 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	42a50513          	addi	a0,a0,1066 # ffffffffc0201928 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	43450513          	addi	a0,a0,1076 # ffffffffc0201940 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	43e50513          	addi	a0,a0,1086 # ffffffffc0201958 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	44850513          	addi	a0,a0,1096 # ffffffffc0201970 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	45250513          	addi	a0,a0,1106 # ffffffffc0201988 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	45c50513          	addi	a0,a0,1116 # ffffffffc02019a0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	46650513          	addi	a0,a0,1126 # ffffffffc02019b8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	47050513          	addi	a0,a0,1136 # ffffffffc02019d0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	47a50513          	addi	a0,a0,1146 # ffffffffc02019e8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	48450513          	addi	a0,a0,1156 # ffffffffc0201a00 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	48e50513          	addi	a0,a0,1166 # ffffffffc0201a18 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	49850513          	addi	a0,a0,1176 # ffffffffc0201a30 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	4a250513          	addi	a0,a0,1186 # ffffffffc0201a48 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201a60 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201a78 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4c050513          	addi	a0,a0,1216 # ffffffffc0201a90 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0201aa8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4d450513          	addi	a0,a0,1236 # ffffffffc0201ac0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	4de50513          	addi	a0,a0,1246 # ffffffffc0201ad8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	4e850513          	addi	a0,a0,1256 # ffffffffc0201af0 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	4f250513          	addi	a0,a0,1266 # ffffffffc0201b08 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201b20 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	50250513          	addi	a0,a0,1282 # ffffffffc0201b38 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	50650513          	addi	a0,a0,1286 # ffffffffc0201b50 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	50650513          	addi	a0,a0,1286 # ffffffffc0201b68 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	50e50513          	addi	a0,a0,1294 # ffffffffc0201b80 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	51650513          	addi	a0,a0,1302 # ffffffffc0201b98 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	51a50513          	addi	a0,a0,1306 # ffffffffc0201bb0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	5e070713          	addi	a4,a4,1504 # ffffffffc0201c90 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	56650513          	addi	a0,a0,1382 # ffffffffc0201c28 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	53c50513          	addi	a0,a0,1340 # ffffffffc0201c08 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	4f250513          	addi	a0,a0,1266 # ffffffffc0201bc8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	56850513          	addi	a0,a0,1384 # ffffffffc0201c48 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00028697          	auipc	a3,0x28
ffffffffc02006f6:	00e68693          	addi	a3,a3,14 # ffffffffc0228700 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	56050513          	addi	a0,a0,1376 # ffffffffc0201c70 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201be8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	53450513          	addi	a0,a0,1332 # ffffffffc0201c60 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <init>:
  }
  return 1 << m;
}

void init(void) {
  size = 0;
ffffffffc0200802:	00028797          	auipc	a5,0x28
ffffffffc0200806:	f007bb23          	sd	zero,-234(a5) # ffffffffc0228718 <size>
  nr_free = 0;
ffffffffc020080a:	00028797          	auipc	a5,0x28
ffffffffc020080e:	ee07bf23          	sd	zero,-258(a5) # ffffffffc0228708 <nr_free>
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy2_alloc>:
  }

  pages_base = base; // pages_base 指向内存页的基址
}

static struct Page *buddy2_alloc(size_t size) {
ffffffffc0200814:	85aa                	mv	a1,a0
  struct Page *page = NULL;
  unsigned int index = 0;
  unsigned int node_size;
  unsigned int offset = 0;

  if (size <= 0)
ffffffffc0200816:	12050863          	beqz	a0,ffffffffc0200946 <buddy2_alloc+0x132>
    return NULL;

  if (!IS_POWER_OF_2(size))
ffffffffc020081a:	fff50793          	addi	a5,a0,-1
ffffffffc020081e:	8fe9                	and	a5,a5,a0
ffffffffc0200820:	efe5                	bnez	a5,ffffffffc0200918 <buddy2_alloc+0x104>
    size = roundUp(size);

  if (self.longest[index] <
ffffffffc0200822:	00005617          	auipc	a2,0x5
ffffffffc0200826:	7ee60613          	addi	a2,a2,2030 # ffffffffc0206010 <self>
ffffffffc020082a:	00466783          	lwu	a5,4(a2)
ffffffffc020082e:	10b7ec63          	bltu	a5,a1,ffffffffc0200946 <buddy2_alloc+0x132>
      size) // (根节点)是否有足够大的空闲块。如果不够大，则返回 NULL。
    return NULL;

  // 从根节点开始遍历二叉树，寻找第一个 >= size 的空闲块
  for (node_size = self.size; node_size != size; node_size /= 2) {
ffffffffc0200832:	00062e03          	lw	t3,0(a2)
    else
      index = RIGHT_LEAF(index); // 进右子树
  }

  // 可分配数量减少
  nr_free -= size;
ffffffffc0200836:	00028e97          	auipc	t4,0x28
ffffffffc020083a:	ed2e8e93          	addi	t4,t4,-302 # ffffffffc0228708 <nr_free>
ffffffffc020083e:	000eb783          	ld	a5,0(t4)
  for (node_size = self.size; node_size != size; node_size /= 2) {
ffffffffc0200842:	020e1713          	slli	a4,t3,0x20
ffffffffc0200846:	9301                	srli	a4,a4,0x20
  nr_free -= size;
ffffffffc0200848:	40b78333          	sub	t1,a5,a1
  for (node_size = self.size; node_size != size; node_size /= 2) {
ffffffffc020084c:	0ee58f63          	beq	a1,a4,ffffffffc020094a <buddy2_alloc+0x136>
ffffffffc0200850:	86f2                	mv	a3,t3
  unsigned int index = 0;
ffffffffc0200852:	4781                	li	a5,0
    if (self.longest[LEFT_LEAF(index)] >= size)
ffffffffc0200854:	0017951b          	slliw	a0,a5,0x1
ffffffffc0200858:	0015079b          	addiw	a5,a0,1
ffffffffc020085c:	02079813          	slli	a6,a5,0x20
ffffffffc0200860:	01e85713          	srli	a4,a6,0x1e
ffffffffc0200864:	9732                	add	a4,a4,a2
ffffffffc0200866:	00476883          	lwu	a7,4(a4)
  for (node_size = self.size; node_size != size; node_size /= 2) {
ffffffffc020086a:	0016d71b          	srliw	a4,a3,0x1
ffffffffc020086e:	02071813          	slli	a6,a4,0x20
ffffffffc0200872:	02085813          	srli	a6,a6,0x20
    if (self.longest[LEFT_LEAF(index)] >= size)
ffffffffc0200876:	00b8f463          	bgeu	a7,a1,ffffffffc020087e <buddy2_alloc+0x6a>
      index = RIGHT_LEAF(index); // 进右子树
ffffffffc020087a:	0025079b          	addiw	a5,a0,2
  for (node_size = self.size; node_size != size; node_size /= 2) {
ffffffffc020087e:	0007069b          	sext.w	a3,a4
ffffffffc0200882:	fcb819e3          	bne	a6,a1,ffffffffc0200854 <buddy2_alloc+0x40>
  self.longest[index] = 0;

  offset = (index + 1) * node_size - self.size;
ffffffffc0200886:	0017871b          	addiw	a4,a5,1
ffffffffc020088a:	02d706bb          	mulw	a3,a4,a3
  self.longest[index] = 0;
ffffffffc020088e:	02079813          	slli	a6,a5,0x20
ffffffffc0200892:	01e85513          	srli	a0,a6,0x1e
ffffffffc0200896:	9532                	add	a0,a0,a2
ffffffffc0200898:	00052223          	sw	zero,4(a0)
  nr_free -= size;
ffffffffc020089c:	006eb023          	sd	t1,0(t4)
  offset = (index + 1) * node_size - self.size;
ffffffffc02008a0:	41c686bb          	subw	a3,a3,t3
  while (index) {
    index = PARENT(index);
    self.longest[index] =
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
  }
  page = offset + pages_base;
ffffffffc02008a4:	1682                	slli	a3,a3,0x20
ffffffffc02008a6:	9281                	srli	a3,a3,0x20
ffffffffc02008a8:	00269513          	slli	a0,a3,0x2
ffffffffc02008ac:	9536                	add	a0,a0,a3
ffffffffc02008ae:	00351e93          	slli	t4,a0,0x3
  while (index) {
ffffffffc02008b2:	e781                	bnez	a5,ffffffffc02008ba <buddy2_alloc+0xa6>
ffffffffc02008b4:	a0b1                	j	ffffffffc0200900 <buddy2_alloc+0xec>
ffffffffc02008b6:	0017871b          	addiw	a4,a5,1
    index = PARENT(index);
ffffffffc02008ba:	0017579b          	srliw	a5,a4,0x1
ffffffffc02008be:	37fd                	addiw	a5,a5,-1
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc02008c0:	9b79                	andi	a4,a4,-2
ffffffffc02008c2:	0017969b          	slliw	a3,a5,0x1
ffffffffc02008c6:	2685                	addiw	a3,a3,1
ffffffffc02008c8:	1702                	slli	a4,a4,0x20
ffffffffc02008ca:	9301                	srli	a4,a4,0x20
ffffffffc02008cc:	02069513          	slli	a0,a3,0x20
ffffffffc02008d0:	01e55693          	srli	a3,a0,0x1e
ffffffffc02008d4:	070a                	slli	a4,a4,0x2
ffffffffc02008d6:	96b2                	add	a3,a3,a2
ffffffffc02008d8:	9732                	add	a4,a4,a2
ffffffffc02008da:	00472883          	lw	a7,4(a4)
ffffffffc02008de:	0046a803          	lw	a6,4(a3)
    self.longest[index] =
ffffffffc02008e2:	02079693          	slli	a3,a5,0x20
ffffffffc02008e6:	01e6d713          	srli	a4,a3,0x1e
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc02008ea:	0008831b          	sext.w	t1,a7
ffffffffc02008ee:	00080e1b          	sext.w	t3,a6
    self.longest[index] =
ffffffffc02008f2:	9732                	add	a4,a4,a2
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc02008f4:	006e7363          	bgeu	t3,t1,ffffffffc02008fa <buddy2_alloc+0xe6>
ffffffffc02008f8:	8846                	mv	a6,a7
    self.longest[index] =
ffffffffc02008fa:	01072223          	sw	a6,4(a4)
  while (index) {
ffffffffc02008fe:	ffc5                	bnez	a5,ffffffffc02008b6 <buddy2_alloc+0xa2>
  page = offset + pages_base;
ffffffffc0200900:	00028517          	auipc	a0,0x28
ffffffffc0200904:	e1053503          	ld	a0,-496(a0) # ffffffffc0228710 <pages_base>
ffffffffc0200908:	9576                	add	a0,a0,t4

  page->property = size;
ffffffffc020090a:	c90c                	sw	a1,16(a0)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020090c:	57f5                	li	a5,-3
ffffffffc020090e:	00850713          	addi	a4,a0,8
ffffffffc0200912:	60f7302f          	amoand.d	zero,a5,(a4)
  ClearPageProperty(page);

  return page;
ffffffffc0200916:	8082                	ret
    size = roundUp(size);
ffffffffc0200918:	0005059b          	sext.w	a1,a0
  while ((1 << m) < size) {
ffffffffc020091c:	4785                	li	a5,1
ffffffffc020091e:	02b7fe63          	bgeu	a5,a1,ffffffffc020095a <buddy2_alloc+0x146>
  unsigned int m = 0;
ffffffffc0200922:	4781                	li	a5,0
  while ((1 << m) < size) {
ffffffffc0200924:	4685                	li	a3,1
    m++;
ffffffffc0200926:	2785                	addiw	a5,a5,1
  while ((1 << m) < size) {
ffffffffc0200928:	00f6973b          	sllw	a4,a3,a5
ffffffffc020092c:	feb76de3          	bltu	a4,a1,ffffffffc0200926 <buddy2_alloc+0x112>
  if (self.longest[index] <
ffffffffc0200930:	00005617          	auipc	a2,0x5
ffffffffc0200934:	6e060613          	addi	a2,a2,1760 # ffffffffc0206010 <self>
ffffffffc0200938:	00466783          	lwu	a5,4(a2)
    size = roundUp(size);
ffffffffc020093c:	02071593          	slli	a1,a4,0x20
ffffffffc0200940:	9181                	srli	a1,a1,0x20
  if (self.longest[index] <
ffffffffc0200942:	eeb7f8e3          	bgeu	a5,a1,ffffffffc0200832 <buddy2_alloc+0x1e>
    return NULL;
ffffffffc0200946:	4501                	li	a0,0
}
ffffffffc0200948:	8082                	ret
  nr_free -= size;
ffffffffc020094a:	006eb023          	sd	t1,0(t4)
  self.longest[index] = 0;
ffffffffc020094e:	00005797          	auipc	a5,0x5
ffffffffc0200952:	6c07a323          	sw	zero,1734(a5) # ffffffffc0206014 <self+0x4>
ffffffffc0200956:	4e81                	li	t4,0
ffffffffc0200958:	b765                	j	ffffffffc0200900 <buddy2_alloc+0xec>
  while ((1 << m) < size) {
ffffffffc020095a:	4585                	li	a1,1
  return 1 << m;
ffffffffc020095c:	b5d9                	j	ffffffffc0200822 <buddy2_alloc+0xe>

ffffffffc020095e <buddy2_nr_free>:
      self.longest[index] = MAX(left_longest, right_longest);
    }
  }
}

size_t buddy2_nr_free() { return nr_free; }
ffffffffc020095e:	00028517          	auipc	a0,0x28
ffffffffc0200962:	daa53503          	ld	a0,-598(a0) # ffffffffc0228708 <nr_free>
ffffffffc0200966:	8082                	ret

ffffffffc0200968 <buddy2_free>:
  unsigned int offset = (pg - pages_base);
ffffffffc0200968:	00028797          	auipc	a5,0x28
ffffffffc020096c:	da87b783          	ld	a5,-600(a5) # ffffffffc0228710 <pages_base>
ffffffffc0200970:	40f507b3          	sub	a5,a0,a5
ffffffffc0200974:	00002717          	auipc	a4,0x2
ffffffffc0200978:	b9473703          	ld	a4,-1132(a4) # ffffffffc0202508 <error_string+0x38>
ffffffffc020097c:	878d                	srai	a5,a5,0x3
ffffffffc020097e:	02e787b3          	mul	a5,a5,a4
static void buddy2_free(struct Page *pg, size_t n) {
ffffffffc0200982:	1141                	addi	sp,sp,-16
ffffffffc0200984:	e406                	sd	ra,8(sp)
  assert(offset >= 0 && offset < size);
ffffffffc0200986:	00028717          	auipc	a4,0x28
ffffffffc020098a:	d9273703          	ld	a4,-622(a4) # ffffffffc0228718 <size>
ffffffffc020098e:	02079693          	slli	a3,a5,0x20
ffffffffc0200992:	9281                	srli	a3,a3,0x20
ffffffffc0200994:	10e6fb63          	bgeu	a3,a4,ffffffffc0200aaa <buddy2_free+0x142>
  index = offset + self.size - 1;
ffffffffc0200998:	00005597          	auipc	a1,0x5
ffffffffc020099c:	67858593          	addi	a1,a1,1656 # ffffffffc0206010 <self>
ffffffffc02009a0:	4198                	lw	a4,0(a1)
ffffffffc02009a2:	2781                	sext.w	a5,a5
ffffffffc02009a4:	377d                	addiw	a4,a4,-1
ffffffffc02009a6:	9fb9                	addw	a5,a5,a4
  for (; self.longest[index]; index = PARENT(index)) {
ffffffffc02009a8:	02079693          	slli	a3,a5,0x20
ffffffffc02009ac:	01e6d713          	srli	a4,a3,0x1e
ffffffffc02009b0:	972e                	add	a4,a4,a1
ffffffffc02009b2:	4358                	lw	a4,4(a4)
ffffffffc02009b4:	c771                	beqz	a4,ffffffffc0200a80 <buddy2_free+0x118>
    node_size *= 2;
ffffffffc02009b6:	4689                	li	a3,2
    if (index == 0)
ffffffffc02009b8:	e789                	bnez	a5,ffffffffc02009c2 <buddy2_free+0x5a>
ffffffffc02009ba:	a0c1                	j	ffffffffc0200a7a <buddy2_free+0x112>
    node_size *= 2;
ffffffffc02009bc:	0016969b          	slliw	a3,a3,0x1
    if (index == 0)
ffffffffc02009c0:	cfcd                	beqz	a5,ffffffffc0200a7a <buddy2_free+0x112>
  for (; self.longest[index]; index = PARENT(index)) {
ffffffffc02009c2:	2785                	addiw	a5,a5,1
ffffffffc02009c4:	0017d79b          	srliw	a5,a5,0x1
ffffffffc02009c8:	37fd                	addiw	a5,a5,-1
ffffffffc02009ca:	02079613          	slli	a2,a5,0x20
ffffffffc02009ce:	01e65713          	srli	a4,a2,0x1e
ffffffffc02009d2:	972e                	add	a4,a4,a1
ffffffffc02009d4:	4358                	lw	a4,4(a4)
ffffffffc02009d6:	f37d                	bnez	a4,ffffffffc02009bc <buddy2_free+0x54>
  for (; p != pg + node_size; p++) {
ffffffffc02009d8:	02069813          	slli	a6,a3,0x20
ffffffffc02009dc:	02085813          	srli	a6,a6,0x20
ffffffffc02009e0:	00281613          	slli	a2,a6,0x2
ffffffffc02009e4:	9642                	add	a2,a2,a6
ffffffffc02009e6:	060e                	slli	a2,a2,0x3
  self.longest[index] = node_size;
ffffffffc02009e8:	02079893          	slli	a7,a5,0x20
ffffffffc02009ec:	01e8d713          	srli	a4,a7,0x1e
ffffffffc02009f0:	972e                	add	a4,a4,a1
ffffffffc02009f2:	c354                	sw	a3,4(a4)
  for (; p != pg + node_size; p++) {
ffffffffc02009f4:	962a                	add	a2,a2,a0
ffffffffc02009f6:	02c50063          	beq	a0,a2,ffffffffc0200a16 <buddy2_free+0xae>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009fa:	6518                	ld	a4,8(a0)
    assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02009fc:	8b05                	andi	a4,a4,1
ffffffffc02009fe:	e751                	bnez	a4,ffffffffc0200a8a <buddy2_free+0x122>
ffffffffc0200a00:	6518                	ld	a4,8(a0)
ffffffffc0200a02:	8b09                	andi	a4,a4,2
ffffffffc0200a04:	e359                	bnez	a4,ffffffffc0200a8a <buddy2_free+0x122>
    p->flags = 0;
ffffffffc0200a06:	00053423          	sd	zero,8(a0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a0a:	00052023          	sw	zero,0(a0)
  for (; p != pg + node_size; p++) {
ffffffffc0200a0e:	02850513          	addi	a0,a0,40
ffffffffc0200a12:	fec514e3          	bne	a0,a2,ffffffffc02009fa <buddy2_free+0x92>
  nr_free += node_size;
ffffffffc0200a16:	00028617          	auipc	a2,0x28
ffffffffc0200a1a:	cf260613          	addi	a2,a2,-782 # ffffffffc0228708 <nr_free>
ffffffffc0200a1e:	6218                	ld	a4,0(a2)
ffffffffc0200a20:	9742                	add	a4,a4,a6
ffffffffc0200a22:	e218                	sd	a4,0(a2)
  while (index) {
ffffffffc0200a24:	cbb9                	beqz	a5,ffffffffc0200a7a <buddy2_free+0x112>
    index = PARENT(index);
ffffffffc0200a26:	2785                	addiw	a5,a5,1
ffffffffc0200a28:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200a2c:	377d                	addiw	a4,a4,-1
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a2e:	0017161b          	slliw	a2,a4,0x1
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a32:	9bf9                	andi	a5,a5,-2
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a34:	2605                	addiw	a2,a2,1
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a36:	1782                	slli	a5,a5,0x20
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a38:	02061513          	slli	a0,a2,0x20
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a3c:	9381                	srli	a5,a5,0x20
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a3e:	01e55613          	srli	a2,a0,0x1e
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a42:	078a                	slli	a5,a5,0x2
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a44:	962e                	add	a2,a2,a1
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a46:	97ae                	add	a5,a5,a1
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a48:	4248                	lw	a0,4(a2)
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a4a:	0047a803          	lw	a6,4(a5)
    node_size *= 2;
ffffffffc0200a4e:	0016969b          	slliw	a3,a3,0x1
    index = PARENT(index);
ffffffffc0200a52:	0007079b          	sext.w	a5,a4
    if (left_longest + right_longest == node_size) {
ffffffffc0200a56:	010508bb          	addw	a7,a0,a6
ffffffffc0200a5a:	8636                	mv	a2,a3
ffffffffc0200a5c:	00d88863          	beq	a7,a3,ffffffffc0200a6c <buddy2_free+0x104>
      self.longest[index] = MAX(left_longest, right_longest);
ffffffffc0200a60:	0005061b          	sext.w	a2,a0
ffffffffc0200a64:	01057463          	bgeu	a0,a6,ffffffffc0200a6c <buddy2_free+0x104>
ffffffffc0200a68:	0008061b          	sext.w	a2,a6
ffffffffc0200a6c:	02071513          	slli	a0,a4,0x20
ffffffffc0200a70:	01e55713          	srli	a4,a0,0x1e
ffffffffc0200a74:	972e                	add	a4,a4,a1
ffffffffc0200a76:	c350                	sw	a2,4(a4)
  while (index) {
ffffffffc0200a78:	f7dd                	bnez	a5,ffffffffc0200a26 <buddy2_free+0xbe>
}
ffffffffc0200a7a:	60a2                	ld	ra,8(sp)
ffffffffc0200a7c:	0141                	addi	sp,sp,16
ffffffffc0200a7e:	8082                	ret
  for (; self.longest[index]; index = PARENT(index)) {
ffffffffc0200a80:	02800613          	li	a2,40
ffffffffc0200a84:	4805                	li	a6,1
  unsigned int node_size = 1, index = 0;
ffffffffc0200a86:	4685                	li	a3,1
ffffffffc0200a88:	b785                	j	ffffffffc02009e8 <buddy2_free+0x80>
    assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a8a:	00001697          	auipc	a3,0x1
ffffffffc0200a8e:	28668693          	addi	a3,a3,646 # ffffffffc0201d10 <commands+0x548>
ffffffffc0200a92:	00001617          	auipc	a2,0x1
ffffffffc0200a96:	24e60613          	addi	a2,a2,590 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200a9a:	09400593          	li	a1,148
ffffffffc0200a9e:	00001517          	auipc	a0,0x1
ffffffffc0200aa2:	25a50513          	addi	a0,a0,602 # ffffffffc0201cf8 <commands+0x530>
ffffffffc0200aa6:	907ff0ef          	jal	ra,ffffffffc02003ac <__panic>
  assert(offset >= 0 && offset < size);
ffffffffc0200aaa:	00001697          	auipc	a3,0x1
ffffffffc0200aae:	21668693          	addi	a3,a3,534 # ffffffffc0201cc0 <commands+0x4f8>
ffffffffc0200ab2:	00001617          	auipc	a2,0x1
ffffffffc0200ab6:	22e60613          	addi	a2,a2,558 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200aba:	08300593          	li	a1,131
ffffffffc0200abe:	00001517          	auipc	a0,0x1
ffffffffc0200ac2:	23a50513          	addi	a0,a0,570 # ffffffffc0201cf8 <commands+0x530>
ffffffffc0200ac6:	8e7ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200aca <buddy2_init_memmap>:
  while ((1 << m) <= n) {
ffffffffc0200aca:	cdc5                	beqz	a1,ffffffffc0200b82 <buddy2_init_memmap+0xb8>
  unsigned int m = 0;
ffffffffc0200acc:	4781                	li	a5,0
  while ((1 << m) <= n) {
ffffffffc0200ace:	4685                	li	a3,1
    m++;
ffffffffc0200ad0:	0007881b          	sext.w	a6,a5
ffffffffc0200ad4:	2785                	addiw	a5,a5,1
  while ((1 << m) <= n) {
ffffffffc0200ad6:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200ada:	fee5fbe3          	bgeu	a1,a4,ffffffffc0200ad0 <buddy2_init_memmap+0x6>
  return 1 << (m - 1);
ffffffffc0200ade:	010697bb          	sllw	a5,a3,a6
  size = roundDown(n);
ffffffffc0200ae2:	02079713          	slli	a4,a5,0x20
ffffffffc0200ae6:	9301                	srli	a4,a4,0x20
ffffffffc0200ae8:	00028897          	auipc	a7,0x28
ffffffffc0200aec:	c3088893          	addi	a7,a7,-976 # ffffffffc0228718 <size>
ffffffffc0200af0:	00e8b023          	sd	a4,0(a7)
  if (size < 1 || !IS_POWER_OF_2(size)) {
ffffffffc0200af4:	cb59                	beqz	a4,ffffffffc0200b8a <buddy2_init_memmap+0xc0>
ffffffffc0200af6:	fff70693          	addi	a3,a4,-1
ffffffffc0200afa:	8ef9                	and	a3,a3,a4
ffffffffc0200afc:	e6d9                	bnez	a3,ffffffffc0200b8a <buddy2_init_memmap+0xc0>
  for (; p != base + n; p++) {
ffffffffc0200afe:	00259613          	slli	a2,a1,0x2
ffffffffc0200b02:	962e                	add	a2,a2,a1
ffffffffc0200b04:	060e                	slli	a2,a2,0x3
  self.size = size;
ffffffffc0200b06:	00005717          	auipc	a4,0x5
ffffffffc0200b0a:	50f72523          	sw	a5,1290(a4) # ffffffffc0206010 <self>
  for (; p != base + n; p++) {
ffffffffc0200b0e:	962a                	add	a2,a2,a0
  node_size = size * 2;
ffffffffc0200b10:	4789                	li	a5,2
ffffffffc0200b12:	0107983b          	sllw	a6,a5,a6
  for (; p != base + n; p++) {
ffffffffc0200b16:	02c50063          	beq	a0,a2,ffffffffc0200b36 <buddy2_init_memmap+0x6c>
ffffffffc0200b1a:	87aa                	mv	a5,a0
ffffffffc0200b1c:	6798                	ld	a4,8(a5)
    assert(PageReserved(p));
ffffffffc0200b1e:	8b05                	andi	a4,a4,1
ffffffffc0200b20:	c735                	beqz	a4,ffffffffc0200b8c <buddy2_init_memmap+0xc2>
    p->flags = p->property = 0;
ffffffffc0200b22:	0007a823          	sw	zero,16(a5)
ffffffffc0200b26:	0007b423          	sd	zero,8(a5)
ffffffffc0200b2a:	0007a023          	sw	zero,0(a5)
  for (; p != base + n; p++) {
ffffffffc0200b2e:	02878793          	addi	a5,a5,40
ffffffffc0200b32:	fec795e3          	bne	a5,a2,ffffffffc0200b1c <buddy2_init_memmap+0x52>
  base->property = n;
ffffffffc0200b36:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b38:	4789                	li	a5,2
ffffffffc0200b3a:	00850713          	addi	a4,a0,8
ffffffffc0200b3e:	40f7302f          	amoor.d	zero,a5,(a4)
  nr_free += size;
ffffffffc0200b42:	00028597          	auipc	a1,0x28
ffffffffc0200b46:	bc658593          	addi	a1,a1,-1082 # ffffffffc0228708 <nr_free>
ffffffffc0200b4a:	0008b883          	ld	a7,0(a7)
ffffffffc0200b4e:	619c                	ld	a5,0(a1)
ffffffffc0200b50:	00005717          	auipc	a4,0x5
ffffffffc0200b54:	4c470713          	addi	a4,a4,1220 # ffffffffc0206014 <self+0x4>
  for (i = 0; i < 2 * size - 1; i++) {
ffffffffc0200b58:	00189613          	slli	a2,a7,0x1
  nr_free += size;
ffffffffc0200b5c:	97c6                	add	a5,a5,a7
ffffffffc0200b5e:	e19c                	sd	a5,0(a1)
  for (i = 0; i < 2 * size - 1; i++) {
ffffffffc0200b60:	167d                	addi	a2,a2,-1
    if (IS_POWER_OF_2(i + 1)) {
ffffffffc0200b62:	87b6                	mv	a5,a3
ffffffffc0200b64:	0685                	addi	a3,a3,1
ffffffffc0200b66:	8ff5                	and	a5,a5,a3
ffffffffc0200b68:	e399                	bnez	a5,ffffffffc0200b6e <buddy2_init_memmap+0xa4>
      node_size /= 2;
ffffffffc0200b6a:	0018581b          	srliw	a6,a6,0x1
    self.longest[i] = node_size;
ffffffffc0200b6e:	01072023          	sw	a6,0(a4)
  for (i = 0; i < 2 * size - 1; i++) {
ffffffffc0200b72:	0711                	addi	a4,a4,4
ffffffffc0200b74:	fec697e3          	bne	a3,a2,ffffffffc0200b62 <buddy2_init_memmap+0x98>
  pages_base = base; // pages_base 指向内存页的基址
ffffffffc0200b78:	00028797          	auipc	a5,0x28
ffffffffc0200b7c:	b8a7bc23          	sd	a0,-1128(a5) # ffffffffc0228710 <pages_base>
ffffffffc0200b80:	8082                	ret
  size = roundDown(n);
ffffffffc0200b82:	00028797          	auipc	a5,0x28
ffffffffc0200b86:	b807bb23          	sd	zero,-1130(a5) # ffffffffc0228718 <size>
  if (size < 1 || !IS_POWER_OF_2(size)) {
ffffffffc0200b8a:	8082                	ret
void buddy2_init_memmap(struct Page *base, size_t n) {
ffffffffc0200b8c:	1141                	addi	sp,sp,-16
    assert(PageReserved(p));
ffffffffc0200b8e:	00001697          	auipc	a3,0x1
ffffffffc0200b92:	1aa68693          	addi	a3,a3,426 # ffffffffc0201d38 <commands+0x570>
ffffffffc0200b96:	00001617          	auipc	a2,0x1
ffffffffc0200b9a:	14a60613          	addi	a2,a2,330 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200b9e:	03d00593          	li	a1,61
ffffffffc0200ba2:	00001517          	auipc	a0,0x1
ffffffffc0200ba6:	15650513          	addi	a0,a0,342 # ffffffffc0201cf8 <commands+0x530>
void buddy2_init_memmap(struct Page *base, size_t n) {
ffffffffc0200baa:	e406                	sd	ra,8(sp)
    assert(PageReserved(p));
ffffffffc0200bac:	801ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bb0 <basic_check>:

  free_page(p1);
  free_page(p2);
}

static void basic_check(void) {
ffffffffc0200bb0:	7179                	addi	sp,sp,-48
  |p4 |p5 |p2 |
  最后释放。
  注意，指针的地址都是块的首地址。
  通过计算验证，然后将结果打印出来，较为直观。也可以通过断言机制assert()判定。
  */
  cprintf("-----------------------------------------------------"
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	19650513          	addi	a0,a0,406 # ffffffffc0201d48 <commands+0x580>
static void basic_check(void) {
ffffffffc0200bba:	f406                	sd	ra,40(sp)
ffffffffc0200bbc:	f022                	sd	s0,32(sp)
ffffffffc0200bbe:	ec26                	sd	s1,24(sp)
ffffffffc0200bc0:	e84a                	sd	s2,16(sp)
ffffffffc0200bc2:	e44e                	sd	s3,8(sp)
ffffffffc0200bc4:	e052                	sd	s4,0(sp)
  cprintf("-----------------------------------------------------"
ffffffffc0200bc6:	cecff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  struct Page *p0, *p1, *p2;
  p0 = p1 = NULL;
  p2 = NULL;
  struct Page *p3, *p4, *p5;
  assert((p0 = alloc_page()) != NULL);
ffffffffc0200bca:	4505                	li	a0,1
ffffffffc0200bcc:	23e000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200bd0:	1c050d63          	beqz	a0,ffffffffc0200daa <basic_check+0x1fa>
ffffffffc0200bd4:	842a                	mv	s0,a0
  assert((p1 = alloc_page()) != NULL);
ffffffffc0200bd6:	4505                	li	a0,1
ffffffffc0200bd8:	232000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200bdc:	892a                	mv	s2,a0
ffffffffc0200bde:	20050663          	beqz	a0,ffffffffc0200dea <basic_check+0x23a>
  assert((p2 = alloc_page()) != NULL);
ffffffffc0200be2:	4505                	li	a0,1
ffffffffc0200be4:	226000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200be8:	84aa                	mv	s1,a0
ffffffffc0200bea:	1e050063          	beqz	a0,ffffffffc0200dca <basic_check+0x21a>
  free_page(p0);
ffffffffc0200bee:	8522                	mv	a0,s0
ffffffffc0200bf0:	4585                	li	a1,1
ffffffffc0200bf2:	256000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  free_page(p1);
ffffffffc0200bf6:	854a                	mv	a0,s2
ffffffffc0200bf8:	4585                	li	a1,1
ffffffffc0200bfa:	24e000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  free_page(p2);
ffffffffc0200bfe:	4585                	li	a1,1
ffffffffc0200c00:	8526                	mv	a0,s1
ffffffffc0200c02:	246000ef          	jal	ra,ffffffffc0200e48 <free_pages>

  p0 = alloc_pages(70);
ffffffffc0200c06:	04600513          	li	a0,70
ffffffffc0200c0a:	200000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200c0e:	8a2a                	mv	s4,a0
  p1 = alloc_pages(35);
ffffffffc0200c10:	02300513          	li	a0,35
ffffffffc0200c14:	1f6000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200c18:	842a                	mv	s0,a0
  // 注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
  cprintf("p0 %p\n", p0);
ffffffffc0200c1a:	85d2                	mv	a1,s4
ffffffffc0200c1c:	00001517          	auipc	a0,0x1
ffffffffc0200c20:	40c50513          	addi	a0,a0,1036 # ffffffffc0202028 <commands+0x860>
ffffffffc0200c24:	c8eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p1 %p\n", p1);
ffffffffc0200c28:	85a2                	mv	a1,s0
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	40650513          	addi	a0,a0,1030 # ffffffffc0202030 <commands+0x868>
ffffffffc0200c32:	c80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p1-p0 equal %p ?=128\n", p1 - p0); // 应该差128
ffffffffc0200c36:	414405b3          	sub	a1,s0,s4
ffffffffc0200c3a:	00002997          	auipc	s3,0x2
ffffffffc0200c3e:	8ce9b983          	ld	s3,-1842(s3) # ffffffffc0202508 <error_string+0x38>
ffffffffc0200c42:	858d                	srai	a1,a1,0x3
ffffffffc0200c44:	033585b3          	mul	a1,a1,s3
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	3f050513          	addi	a0,a0,1008 # ffffffffc0202038 <commands+0x870>
ffffffffc0200c50:	c62ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  p2 = alloc_pages(257);
ffffffffc0200c54:	10100513          	li	a0,257
ffffffffc0200c58:	1b2000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200c5c:	84aa                	mv	s1,a0
  cprintf("p2 %p\n", p2);
ffffffffc0200c5e:	85aa                	mv	a1,a0
ffffffffc0200c60:	00001517          	auipc	a0,0x1
ffffffffc0200c64:	3f050513          	addi	a0,a0,1008 # ffffffffc0202050 <commands+0x888>
ffffffffc0200c68:	c4aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p2-p1 equal %p ?=128+256\n", p2 - p1); // 应该差384
ffffffffc0200c6c:	408485b3          	sub	a1,s1,s0
ffffffffc0200c70:	858d                	srai	a1,a1,0x3
ffffffffc0200c72:	033585b3          	mul	a1,a1,s3
ffffffffc0200c76:	00001517          	auipc	a0,0x1
ffffffffc0200c7a:	3e250513          	addi	a0,a0,994 # ffffffffc0202058 <commands+0x890>
ffffffffc0200c7e:	c34ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  p3 = alloc_pages(63);
ffffffffc0200c82:	03f00513          	li	a0,63
ffffffffc0200c86:	184000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200c8a:	892a                	mv	s2,a0
  cprintf("p3 %p\n", p3);
ffffffffc0200c8c:	85aa                	mv	a1,a0
ffffffffc0200c8e:	00001517          	auipc	a0,0x1
ffffffffc0200c92:	3ea50513          	addi	a0,a0,1002 # ffffffffc0202078 <commands+0x8b0>
ffffffffc0200c96:	c1cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p3-p1 equal %p ?=64\n", p3 - p1); // 应该差64
ffffffffc0200c9a:	408905b3          	sub	a1,s2,s0
ffffffffc0200c9e:	858d                	srai	a1,a1,0x3
ffffffffc0200ca0:	033585b3          	mul	a1,a1,s3
ffffffffc0200ca4:	00001517          	auipc	a0,0x1
ffffffffc0200ca8:	3dc50513          	addi	a0,a0,988 # ffffffffc0202080 <commands+0x8b8>
ffffffffc0200cac:	c06ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  free_pages(p0, 70);
ffffffffc0200cb0:	04600593          	li	a1,70
ffffffffc0200cb4:	8552                	mv	a0,s4
ffffffffc0200cb6:	192000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p0!\n");
ffffffffc0200cba:	00001517          	auipc	a0,0x1
ffffffffc0200cbe:	3de50513          	addi	a0,a0,990 # ffffffffc0202098 <commands+0x8d0>
ffffffffc0200cc2:	bf0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  free_pages(p1, 35);
ffffffffc0200cc6:	02300593          	li	a1,35
ffffffffc0200cca:	8522                	mv	a0,s0
ffffffffc0200ccc:	17c000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p1!\n");
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	3d850513          	addi	a0,a0,984 # ffffffffc02020a8 <commands+0x8e0>
ffffffffc0200cd8:	bdaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  free_pages(p3, 63);
ffffffffc0200cdc:	03f00593          	li	a1,63
ffffffffc0200ce0:	854a                	mv	a0,s2
ffffffffc0200ce2:	166000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p3!\n");
ffffffffc0200ce6:	00001517          	auipc	a0,0x1
ffffffffc0200cea:	3d250513          	addi	a0,a0,978 # ffffffffc02020b8 <commands+0x8f0>
ffffffffc0200cee:	bc4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  p4 = alloc_pages(255);
ffffffffc0200cf2:	0ff00513          	li	a0,255
ffffffffc0200cf6:	114000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200cfa:	842a                	mv	s0,a0
  cprintf("p4 %p\n", p4);
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00001517          	auipc	a0,0x1
ffffffffc0200d02:	3ca50513          	addi	a0,a0,970 # ffffffffc02020c8 <commands+0x900>
ffffffffc0200d06:	bacff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p2-p4 equal %p ?=512\n", p2 - p4); // 应该差512
ffffffffc0200d0a:	408485b3          	sub	a1,s1,s0
ffffffffc0200d0e:	858d                	srai	a1,a1,0x3
ffffffffc0200d10:	033585b3          	mul	a1,a1,s3
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	3bc50513          	addi	a0,a0,956 # ffffffffc02020d0 <commands+0x908>
ffffffffc0200d1c:	b96ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

  p5 = alloc_pages(255);
ffffffffc0200d20:	0ff00513          	li	a0,255
ffffffffc0200d24:	0e6000ef          	jal	ra,ffffffffc0200e0a <alloc_pages>
ffffffffc0200d28:	892a                	mv	s2,a0
  cprintf("p5 %p\n", p5);
ffffffffc0200d2a:	85aa                	mv	a1,a0
ffffffffc0200d2c:	00001517          	auipc	a0,0x1
ffffffffc0200d30:	3bc50513          	addi	a0,a0,956 # ffffffffc02020e8 <commands+0x920>
ffffffffc0200d34:	b7eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("p5-p4 equal %p ?=256\n", p5 - p4); // 应该差256
ffffffffc0200d38:	408905b3          	sub	a1,s2,s0
ffffffffc0200d3c:	858d                	srai	a1,a1,0x3
ffffffffc0200d3e:	033585b3          	mul	a1,a1,s3
ffffffffc0200d42:	00001517          	auipc	a0,0x1
ffffffffc0200d46:	3ae50513          	addi	a0,a0,942 # ffffffffc02020f0 <commands+0x928>
ffffffffc0200d4a:	b68ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  free_pages(p2, 257);
ffffffffc0200d4e:	10100593          	li	a1,257
ffffffffc0200d52:	8526                	mv	a0,s1
ffffffffc0200d54:	0f4000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p2!\n");
ffffffffc0200d58:	00001517          	auipc	a0,0x1
ffffffffc0200d5c:	3b050513          	addi	a0,a0,944 # ffffffffc0202108 <commands+0x940>
ffffffffc0200d60:	b52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  free_pages(p4, 255);
ffffffffc0200d64:	0ff00593          	li	a1,255
ffffffffc0200d68:	8522                	mv	a0,s0
ffffffffc0200d6a:	0de000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p4!\n");
ffffffffc0200d6e:	00001517          	auipc	a0,0x1
ffffffffc0200d72:	3aa50513          	addi	a0,a0,938 # ffffffffc0202118 <commands+0x950>
ffffffffc0200d76:	b3cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  free_pages(p5, 255);
ffffffffc0200d7a:	854a                	mv	a0,s2
ffffffffc0200d7c:	0ff00593          	li	a1,255
ffffffffc0200d80:	0c8000ef          	jal	ra,ffffffffc0200e48 <free_pages>
  cprintf("free p5!\n");
ffffffffc0200d84:	00001517          	auipc	a0,0x1
ffffffffc0200d88:	3a450513          	addi	a0,a0,932 # ffffffffc0202128 <commands+0x960>
ffffffffc0200d8c:	b26ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
  cprintf("CHECK DONE!\n");
}
ffffffffc0200d90:	7402                	ld	s0,32(sp)
ffffffffc0200d92:	70a2                	ld	ra,40(sp)
ffffffffc0200d94:	64e2                	ld	s1,24(sp)
ffffffffc0200d96:	6942                	ld	s2,16(sp)
ffffffffc0200d98:	69a2                	ld	s3,8(sp)
ffffffffc0200d9a:	6a02                	ld	s4,0(sp)
  cprintf("CHECK DONE!\n");
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	39c50513          	addi	a0,a0,924 # ffffffffc0202138 <commands+0x970>
}
ffffffffc0200da4:	6145                	addi	sp,sp,48
  cprintf("CHECK DONE!\n");
ffffffffc0200da6:	b0cff06f          	j	ffffffffc02000b2 <cprintf>
  assert((p0 = alloc_page()) != NULL);
ffffffffc0200daa:	00001697          	auipc	a3,0x1
ffffffffc0200dae:	21e68693          	addi	a3,a3,542 # ffffffffc0201fc8 <commands+0x800>
ffffffffc0200db2:	00001617          	auipc	a2,0x1
ffffffffc0200db6:	f2e60613          	addi	a2,a2,-210 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200dba:	0f200593          	li	a1,242
ffffffffc0200dbe:	00001517          	auipc	a0,0x1
ffffffffc0200dc2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0201cf8 <commands+0x530>
ffffffffc0200dc6:	de6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
  assert((p2 = alloc_page()) != NULL);
ffffffffc0200dca:	00001697          	auipc	a3,0x1
ffffffffc0200dce:	23e68693          	addi	a3,a3,574 # ffffffffc0202008 <commands+0x840>
ffffffffc0200dd2:	00001617          	auipc	a2,0x1
ffffffffc0200dd6:	f0e60613          	addi	a2,a2,-242 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200dda:	0f400593          	li	a1,244
ffffffffc0200dde:	00001517          	auipc	a0,0x1
ffffffffc0200de2:	f1a50513          	addi	a0,a0,-230 # ffffffffc0201cf8 <commands+0x530>
ffffffffc0200de6:	dc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
  assert((p1 = alloc_page()) != NULL);
ffffffffc0200dea:	00001697          	auipc	a3,0x1
ffffffffc0200dee:	1fe68693          	addi	a3,a3,510 # ffffffffc0201fe8 <commands+0x820>
ffffffffc0200df2:	00001617          	auipc	a2,0x1
ffffffffc0200df6:	eee60613          	addi	a2,a2,-274 # ffffffffc0201ce0 <commands+0x518>
ffffffffc0200dfa:	0f300593          	li	a1,243
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	efa50513          	addi	a0,a0,-262 # ffffffffc0201cf8 <commands+0x530>
ffffffffc0200e06:	da6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e0a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e0a:	100027f3          	csrr	a5,sstatus
ffffffffc0200e0e:	8b89                	andi	a5,a5,2
ffffffffc0200e10:	e799                	bnez	a5,ffffffffc0200e1e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e12:	00028797          	auipc	a5,0x28
ffffffffc0200e16:	91e7b783          	ld	a5,-1762(a5) # ffffffffc0228730 <pmm_manager>
ffffffffc0200e1a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e1c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200e1e:	1141                	addi	sp,sp,-16
ffffffffc0200e20:	e406                	sd	ra,8(sp)
ffffffffc0200e22:	e022                	sd	s0,0(sp)
ffffffffc0200e24:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e26:	e38ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e2a:	00028797          	auipc	a5,0x28
ffffffffc0200e2e:	9067b783          	ld	a5,-1786(a5) # ffffffffc0228730 <pmm_manager>
ffffffffc0200e32:	6f9c                	ld	a5,24(a5)
ffffffffc0200e34:	8522                	mv	a0,s0
ffffffffc0200e36:	9782                	jalr	a5
ffffffffc0200e38:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e3a:	e1eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e3e:	60a2                	ld	ra,8(sp)
ffffffffc0200e40:	8522                	mv	a0,s0
ffffffffc0200e42:	6402                	ld	s0,0(sp)
ffffffffc0200e44:	0141                	addi	sp,sp,16
ffffffffc0200e46:	8082                	ret

ffffffffc0200e48 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e48:	100027f3          	csrr	a5,sstatus
ffffffffc0200e4c:	8b89                	andi	a5,a5,2
ffffffffc0200e4e:	e799                	bnez	a5,ffffffffc0200e5c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e50:	00028797          	auipc	a5,0x28
ffffffffc0200e54:	8e07b783          	ld	a5,-1824(a5) # ffffffffc0228730 <pmm_manager>
ffffffffc0200e58:	739c                	ld	a5,32(a5)
ffffffffc0200e5a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e5c:	1101                	addi	sp,sp,-32
ffffffffc0200e5e:	ec06                	sd	ra,24(sp)
ffffffffc0200e60:	e822                	sd	s0,16(sp)
ffffffffc0200e62:	e426                	sd	s1,8(sp)
ffffffffc0200e64:	842a                	mv	s0,a0
ffffffffc0200e66:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e68:	df6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e6c:	00028797          	auipc	a5,0x28
ffffffffc0200e70:	8c47b783          	ld	a5,-1852(a5) # ffffffffc0228730 <pmm_manager>
ffffffffc0200e74:	739c                	ld	a5,32(a5)
ffffffffc0200e76:	85a6                	mv	a1,s1
ffffffffc0200e78:	8522                	mv	a0,s0
ffffffffc0200e7a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e7c:	6442                	ld	s0,16(sp)
ffffffffc0200e7e:	60e2                	ld	ra,24(sp)
ffffffffc0200e80:	64a2                	ld	s1,8(sp)
ffffffffc0200e82:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e84:	dd4ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200e88 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e88:	00001797          	auipc	a5,0x1
ffffffffc0200e8c:	2d878793          	addi	a5,a5,728 # ffffffffc0202160 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e90:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e92:	1101                	addi	sp,sp,-32
ffffffffc0200e94:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e96:	00001517          	auipc	a0,0x1
ffffffffc0200e9a:	30250513          	addi	a0,a0,770 # ffffffffc0202198 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e9e:	00028497          	auipc	s1,0x28
ffffffffc0200ea2:	89248493          	addi	s1,s1,-1902 # ffffffffc0228730 <pmm_manager>
void pmm_init(void) {
ffffffffc0200ea6:	ec06                	sd	ra,24(sp)
ffffffffc0200ea8:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200eaa:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200eac:	a06ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200eb0:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eb2:	00028417          	auipc	s0,0x28
ffffffffc0200eb6:	89640413          	addi	s0,s0,-1898 # ffffffffc0228748 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200eba:	679c                	ld	a5,8(a5)
ffffffffc0200ebc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ebe:	57f5                	li	a5,-3
ffffffffc0200ec0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ec2:	00001517          	auipc	a0,0x1
ffffffffc0200ec6:	2ee50513          	addi	a0,a0,750 # ffffffffc02021b0 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200eca:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200ecc:	9e6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ed0:	46c5                	li	a3,17
ffffffffc0200ed2:	06ee                	slli	a3,a3,0x1b
ffffffffc0200ed4:	40100613          	li	a2,1025
ffffffffc0200ed8:	16fd                	addi	a3,a3,-1
ffffffffc0200eda:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ede:	0656                	slli	a2,a2,0x15
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	2e850513          	addi	a0,a0,744 # ffffffffc02021c8 <buddy_pmm_manager+0x68>
ffffffffc0200ee8:	9caff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eec:	777d                	lui	a4,0xfffff
ffffffffc0200eee:	00029797          	auipc	a5,0x29
ffffffffc0200ef2:	86978793          	addi	a5,a5,-1943 # ffffffffc0229757 <end+0xfff>
ffffffffc0200ef6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ef8:	00028517          	auipc	a0,0x28
ffffffffc0200efc:	82850513          	addi	a0,a0,-2008 # ffffffffc0228720 <npage>
ffffffffc0200f00:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f04:	00028597          	auipc	a1,0x28
ffffffffc0200f08:	82458593          	addi	a1,a1,-2012 # ffffffffc0228728 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200f0c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f0e:	e19c                	sd	a5,0(a1)
ffffffffc0200f10:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f12:	4701                	li	a4,0
ffffffffc0200f14:	4885                	li	a7,1
ffffffffc0200f16:	fff80837          	lui	a6,0xfff80
ffffffffc0200f1a:	a011                	j	ffffffffc0200f1e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200f1c:	619c                	ld	a5,0(a1)
ffffffffc0200f1e:	97b6                	add	a5,a5,a3
ffffffffc0200f20:	07a1                	addi	a5,a5,8
ffffffffc0200f22:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f26:	611c                	ld	a5,0(a0)
ffffffffc0200f28:	0705                	addi	a4,a4,1
ffffffffc0200f2a:	02868693          	addi	a3,a3,40
ffffffffc0200f2e:	01078633          	add	a2,a5,a6
ffffffffc0200f32:	fec765e3          	bltu	a4,a2,ffffffffc0200f1c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f36:	6190                	ld	a2,0(a1)
ffffffffc0200f38:	00279713          	slli	a4,a5,0x2
ffffffffc0200f3c:	973e                	add	a4,a4,a5
ffffffffc0200f3e:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f42:	070e                	slli	a4,a4,0x3
ffffffffc0200f44:	96b2                	add	a3,a3,a2
ffffffffc0200f46:	96ba                	add	a3,a3,a4
ffffffffc0200f48:	c0200737          	lui	a4,0xc0200
ffffffffc0200f4c:	08e6ef63          	bltu	a3,a4,ffffffffc0200fea <pmm_init+0x162>
ffffffffc0200f50:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f52:	45c5                	li	a1,17
ffffffffc0200f54:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f56:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f58:	04b6e863          	bltu	a3,a1,ffffffffc0200fa8 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f5c:	609c                	ld	a5,0(s1)
ffffffffc0200f5e:	7b9c                	ld	a5,48(a5)
ffffffffc0200f60:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	2fe50513          	addi	a0,a0,766 # ffffffffc0202260 <buddy_pmm_manager+0x100>
ffffffffc0200f6a:	948ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f6e:	00004597          	auipc	a1,0x4
ffffffffc0200f72:	09258593          	addi	a1,a1,146 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f76:	00027797          	auipc	a5,0x27
ffffffffc0200f7a:	7cb7b523          	sd	a1,1994(a5) # ffffffffc0228740 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f7e:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f82:	08f5e063          	bltu	a1,a5,ffffffffc0201002 <pmm_init+0x17a>
ffffffffc0200f86:	6010                	ld	a2,0(s0)
}
ffffffffc0200f88:	6442                	ld	s0,16(sp)
ffffffffc0200f8a:	60e2                	ld	ra,24(sp)
ffffffffc0200f8c:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f8e:	40c58633          	sub	a2,a1,a2
ffffffffc0200f92:	00027797          	auipc	a5,0x27
ffffffffc0200f96:	7ac7b323          	sd	a2,1958(a5) # ffffffffc0228738 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f9a:	00001517          	auipc	a0,0x1
ffffffffc0200f9e:	2e650513          	addi	a0,a0,742 # ffffffffc0202280 <buddy_pmm_manager+0x120>
}
ffffffffc0200fa2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200fa4:	90eff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200fa8:	6705                	lui	a4,0x1
ffffffffc0200faa:	177d                	addi	a4,a4,-1
ffffffffc0200fac:	96ba                	add	a3,a3,a4
ffffffffc0200fae:	777d                	lui	a4,0xfffff
ffffffffc0200fb0:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200fb2:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200fb6:	00f57e63          	bgeu	a0,a5,ffffffffc0200fd2 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200fba:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200fbc:	982a                	add	a6,a6,a0
ffffffffc0200fbe:	00281513          	slli	a0,a6,0x2
ffffffffc0200fc2:	9542                	add	a0,a0,a6
ffffffffc0200fc4:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fc6:	8d95                	sub	a1,a1,a3
ffffffffc0200fc8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fca:	81b1                	srli	a1,a1,0xc
ffffffffc0200fcc:	9532                	add	a0,a0,a2
ffffffffc0200fce:	9782                	jalr	a5
}
ffffffffc0200fd0:	b771                	j	ffffffffc0200f5c <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200fd2:	00001617          	auipc	a2,0x1
ffffffffc0200fd6:	25e60613          	addi	a2,a2,606 # ffffffffc0202230 <buddy_pmm_manager+0xd0>
ffffffffc0200fda:	06b00593          	li	a1,107
ffffffffc0200fde:	00001517          	auipc	a0,0x1
ffffffffc0200fe2:	27250513          	addi	a0,a0,626 # ffffffffc0202250 <buddy_pmm_manager+0xf0>
ffffffffc0200fe6:	bc6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fea:	00001617          	auipc	a2,0x1
ffffffffc0200fee:	20e60613          	addi	a2,a2,526 # ffffffffc02021f8 <buddy_pmm_manager+0x98>
ffffffffc0200ff2:	06f00593          	li	a1,111
ffffffffc0200ff6:	00001517          	auipc	a0,0x1
ffffffffc0200ffa:	22a50513          	addi	a0,a0,554 # ffffffffc0202220 <buddy_pmm_manager+0xc0>
ffffffffc0200ffe:	baeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201002:	86ae                	mv	a3,a1
ffffffffc0201004:	00001617          	auipc	a2,0x1
ffffffffc0201008:	1f460613          	addi	a2,a2,500 # ffffffffc02021f8 <buddy_pmm_manager+0x98>
ffffffffc020100c:	08a00593          	li	a1,138
ffffffffc0201010:	00001517          	auipc	a0,0x1
ffffffffc0201014:	21050513          	addi	a0,a0,528 # ffffffffc0202220 <buddy_pmm_manager+0xc0>
ffffffffc0201018:	b94ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020101c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020101c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201020:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201022:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201026:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201028:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020102c:	f022                	sd	s0,32(sp)
ffffffffc020102e:	ec26                	sd	s1,24(sp)
ffffffffc0201030:	e84a                	sd	s2,16(sp)
ffffffffc0201032:	f406                	sd	ra,40(sp)
ffffffffc0201034:	e44e                	sd	s3,8(sp)
ffffffffc0201036:	84aa                	mv	s1,a0
ffffffffc0201038:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020103a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020103e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201040:	03067e63          	bgeu	a2,a6,ffffffffc020107c <printnum+0x60>
ffffffffc0201044:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201046:	00805763          	blez	s0,ffffffffc0201054 <printnum+0x38>
ffffffffc020104a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020104c:	85ca                	mv	a1,s2
ffffffffc020104e:	854e                	mv	a0,s3
ffffffffc0201050:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201052:	fc65                	bnez	s0,ffffffffc020104a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201054:	1a02                	slli	s4,s4,0x20
ffffffffc0201056:	00001797          	auipc	a5,0x1
ffffffffc020105a:	26a78793          	addi	a5,a5,618 # ffffffffc02022c0 <buddy_pmm_manager+0x160>
ffffffffc020105e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201062:	9a3e                	add	s4,s4,a5
}
ffffffffc0201064:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201066:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020106a:	70a2                	ld	ra,40(sp)
ffffffffc020106c:	69a2                	ld	s3,8(sp)
ffffffffc020106e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201070:	85ca                	mv	a1,s2
ffffffffc0201072:	87a6                	mv	a5,s1
}
ffffffffc0201074:	6942                	ld	s2,16(sp)
ffffffffc0201076:	64e2                	ld	s1,24(sp)
ffffffffc0201078:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020107a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020107c:	03065633          	divu	a2,a2,a6
ffffffffc0201080:	8722                	mv	a4,s0
ffffffffc0201082:	f9bff0ef          	jal	ra,ffffffffc020101c <printnum>
ffffffffc0201086:	b7f9                	j	ffffffffc0201054 <printnum+0x38>

ffffffffc0201088 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201088:	7119                	addi	sp,sp,-128
ffffffffc020108a:	f4a6                	sd	s1,104(sp)
ffffffffc020108c:	f0ca                	sd	s2,96(sp)
ffffffffc020108e:	ecce                	sd	s3,88(sp)
ffffffffc0201090:	e8d2                	sd	s4,80(sp)
ffffffffc0201092:	e4d6                	sd	s5,72(sp)
ffffffffc0201094:	e0da                	sd	s6,64(sp)
ffffffffc0201096:	fc5e                	sd	s7,56(sp)
ffffffffc0201098:	f06a                	sd	s10,32(sp)
ffffffffc020109a:	fc86                	sd	ra,120(sp)
ffffffffc020109c:	f8a2                	sd	s0,112(sp)
ffffffffc020109e:	f862                	sd	s8,48(sp)
ffffffffc02010a0:	f466                	sd	s9,40(sp)
ffffffffc02010a2:	ec6e                	sd	s11,24(sp)
ffffffffc02010a4:	892a                	mv	s2,a0
ffffffffc02010a6:	84ae                	mv	s1,a1
ffffffffc02010a8:	8d32                	mv	s10,a2
ffffffffc02010aa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010ac:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02010b0:	5b7d                	li	s6,-1
ffffffffc02010b2:	00001a97          	auipc	s5,0x1
ffffffffc02010b6:	242a8a93          	addi	s5,s5,578 # ffffffffc02022f4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010ba:	00001b97          	auipc	s7,0x1
ffffffffc02010be:	416b8b93          	addi	s7,s7,1046 # ffffffffc02024d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010c2:	000d4503          	lbu	a0,0(s10)
ffffffffc02010c6:	001d0413          	addi	s0,s10,1
ffffffffc02010ca:	01350a63          	beq	a0,s3,ffffffffc02010de <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010ce:	c121                	beqz	a0,ffffffffc020110e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010d0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010d2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010d4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010d6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010da:	ff351ae3          	bne	a0,s3,ffffffffc02010ce <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010de:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010e2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010e6:	4c81                	li	s9,0
ffffffffc02010e8:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010ea:	5c7d                	li	s8,-1
ffffffffc02010ec:	5dfd                	li	s11,-1
ffffffffc02010ee:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02010f2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010f4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010f8:	0ff5f593          	zext.b	a1,a1
ffffffffc02010fc:	00140d13          	addi	s10,s0,1
ffffffffc0201100:	04b56263          	bltu	a0,a1,ffffffffc0201144 <vprintfmt+0xbc>
ffffffffc0201104:	058a                	slli	a1,a1,0x2
ffffffffc0201106:	95d6                	add	a1,a1,s5
ffffffffc0201108:	4194                	lw	a3,0(a1)
ffffffffc020110a:	96d6                	add	a3,a3,s5
ffffffffc020110c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020110e:	70e6                	ld	ra,120(sp)
ffffffffc0201110:	7446                	ld	s0,112(sp)
ffffffffc0201112:	74a6                	ld	s1,104(sp)
ffffffffc0201114:	7906                	ld	s2,96(sp)
ffffffffc0201116:	69e6                	ld	s3,88(sp)
ffffffffc0201118:	6a46                	ld	s4,80(sp)
ffffffffc020111a:	6aa6                	ld	s5,72(sp)
ffffffffc020111c:	6b06                	ld	s6,64(sp)
ffffffffc020111e:	7be2                	ld	s7,56(sp)
ffffffffc0201120:	7c42                	ld	s8,48(sp)
ffffffffc0201122:	7ca2                	ld	s9,40(sp)
ffffffffc0201124:	7d02                	ld	s10,32(sp)
ffffffffc0201126:	6de2                	ld	s11,24(sp)
ffffffffc0201128:	6109                	addi	sp,sp,128
ffffffffc020112a:	8082                	ret
            padc = '0';
ffffffffc020112c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020112e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201132:	846a                	mv	s0,s10
ffffffffc0201134:	00140d13          	addi	s10,s0,1
ffffffffc0201138:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020113c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201140:	fcb572e3          	bgeu	a0,a1,ffffffffc0201104 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201144:	85a6                	mv	a1,s1
ffffffffc0201146:	02500513          	li	a0,37
ffffffffc020114a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020114c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201150:	8d22                	mv	s10,s0
ffffffffc0201152:	f73788e3          	beq	a5,s3,ffffffffc02010c2 <vprintfmt+0x3a>
ffffffffc0201156:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020115a:	1d7d                	addi	s10,s10,-1
ffffffffc020115c:	ff379de3          	bne	a5,s3,ffffffffc0201156 <vprintfmt+0xce>
ffffffffc0201160:	b78d                	j	ffffffffc02010c2 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201162:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201166:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020116a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020116c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201170:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201174:	02d86463          	bltu	a6,a3,ffffffffc020119c <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201178:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020117c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201180:	0186873b          	addw	a4,a3,s8
ffffffffc0201184:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201188:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020118a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020118e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201190:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201194:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201198:	fed870e3          	bgeu	a6,a3,ffffffffc0201178 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020119c:	f40ddce3          	bgez	s11,ffffffffc02010f4 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02011a0:	8de2                	mv	s11,s8
ffffffffc02011a2:	5c7d                	li	s8,-1
ffffffffc02011a4:	bf81                	j	ffffffffc02010f4 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02011a6:	fffdc693          	not	a3,s11
ffffffffc02011aa:	96fd                	srai	a3,a3,0x3f
ffffffffc02011ac:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b0:	00144603          	lbu	a2,1(s0)
ffffffffc02011b4:	2d81                	sext.w	s11,s11
ffffffffc02011b6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011b8:	bf35                	j	ffffffffc02010f4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02011ba:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011be:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02011c2:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011c4:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011c6:	bfd9                	j	ffffffffc020119c <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011ca:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011ce:	01174463          	blt	a4,a7,ffffffffc02011d6 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011d2:	1a088e63          	beqz	a7,ffffffffc020138e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011d6:	000a3603          	ld	a2,0(s4)
ffffffffc02011da:	46c1                	li	a3,16
ffffffffc02011dc:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011de:	2781                	sext.w	a5,a5
ffffffffc02011e0:	876e                	mv	a4,s11
ffffffffc02011e2:	85a6                	mv	a1,s1
ffffffffc02011e4:	854a                	mv	a0,s2
ffffffffc02011e6:	e37ff0ef          	jal	ra,ffffffffc020101c <printnum>
            break;
ffffffffc02011ea:	bde1                	j	ffffffffc02010c2 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011ec:	000a2503          	lw	a0,0(s4)
ffffffffc02011f0:	85a6                	mv	a1,s1
ffffffffc02011f2:	0a21                	addi	s4,s4,8
ffffffffc02011f4:	9902                	jalr	s2
            break;
ffffffffc02011f6:	b5f1                	j	ffffffffc02010c2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011fa:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011fe:	01174463          	blt	a4,a7,ffffffffc0201206 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201202:	18088163          	beqz	a7,ffffffffc0201384 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201206:	000a3603          	ld	a2,0(s4)
ffffffffc020120a:	46a9                	li	a3,10
ffffffffc020120c:	8a2e                	mv	s4,a1
ffffffffc020120e:	bfc1                	j	ffffffffc02011de <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201210:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201214:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201216:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201218:	bdf1                	j	ffffffffc02010f4 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020121a:	85a6                	mv	a1,s1
ffffffffc020121c:	02500513          	li	a0,37
ffffffffc0201220:	9902                	jalr	s2
            break;
ffffffffc0201222:	b545                	j	ffffffffc02010c2 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201224:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201228:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020122a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020122c:	b5e1                	j	ffffffffc02010f4 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020122e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201230:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201234:	01174463          	blt	a4,a7,ffffffffc020123c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201238:	14088163          	beqz	a7,ffffffffc020137a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020123c:	000a3603          	ld	a2,0(s4)
ffffffffc0201240:	46a1                	li	a3,8
ffffffffc0201242:	8a2e                	mv	s4,a1
ffffffffc0201244:	bf69                	j	ffffffffc02011de <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201246:	03000513          	li	a0,48
ffffffffc020124a:	85a6                	mv	a1,s1
ffffffffc020124c:	e03e                	sd	a5,0(sp)
ffffffffc020124e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201250:	85a6                	mv	a1,s1
ffffffffc0201252:	07800513          	li	a0,120
ffffffffc0201256:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201258:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020125a:	6782                	ld	a5,0(sp)
ffffffffc020125c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020125e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201262:	bfb5                	j	ffffffffc02011de <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201264:	000a3403          	ld	s0,0(s4)
ffffffffc0201268:	008a0713          	addi	a4,s4,8
ffffffffc020126c:	e03a                	sd	a4,0(sp)
ffffffffc020126e:	14040263          	beqz	s0,ffffffffc02013b2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201272:	0fb05763          	blez	s11,ffffffffc0201360 <vprintfmt+0x2d8>
ffffffffc0201276:	02d00693          	li	a3,45
ffffffffc020127a:	0cd79163          	bne	a5,a3,ffffffffc020133c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020127e:	00044783          	lbu	a5,0(s0)
ffffffffc0201282:	0007851b          	sext.w	a0,a5
ffffffffc0201286:	cf85                	beqz	a5,ffffffffc02012be <vprintfmt+0x236>
ffffffffc0201288:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020128c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201290:	000c4563          	bltz	s8,ffffffffc020129a <vprintfmt+0x212>
ffffffffc0201294:	3c7d                	addiw	s8,s8,-1
ffffffffc0201296:	036c0263          	beq	s8,s6,ffffffffc02012ba <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020129a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020129c:	0e0c8e63          	beqz	s9,ffffffffc0201398 <vprintfmt+0x310>
ffffffffc02012a0:	3781                	addiw	a5,a5,-32
ffffffffc02012a2:	0ef47b63          	bgeu	s0,a5,ffffffffc0201398 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02012a6:	03f00513          	li	a0,63
ffffffffc02012aa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012ac:	000a4783          	lbu	a5,0(s4)
ffffffffc02012b0:	3dfd                	addiw	s11,s11,-1
ffffffffc02012b2:	0a05                	addi	s4,s4,1
ffffffffc02012b4:	0007851b          	sext.w	a0,a5
ffffffffc02012b8:	ffe1                	bnez	a5,ffffffffc0201290 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02012ba:	01b05963          	blez	s11,ffffffffc02012cc <vprintfmt+0x244>
ffffffffc02012be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012c0:	85a6                	mv	a1,s1
ffffffffc02012c2:	02000513          	li	a0,32
ffffffffc02012c6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012c8:	fe0d9be3          	bnez	s11,ffffffffc02012be <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012cc:	6a02                	ld	s4,0(sp)
ffffffffc02012ce:	bbd5                	j	ffffffffc02010c2 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012d2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012d6:	01174463          	blt	a4,a7,ffffffffc02012de <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012da:	08088d63          	beqz	a7,ffffffffc0201374 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012de:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012e2:	0a044d63          	bltz	s0,ffffffffc020139c <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012e6:	8622                	mv	a2,s0
ffffffffc02012e8:	8a66                	mv	s4,s9
ffffffffc02012ea:	46a9                	li	a3,10
ffffffffc02012ec:	bdcd                	j	ffffffffc02011de <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02012ee:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012f2:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02012f4:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02012f6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02012fa:	8fb5                	xor	a5,a5,a3
ffffffffc02012fc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201300:	02d74163          	blt	a4,a3,ffffffffc0201322 <vprintfmt+0x29a>
ffffffffc0201304:	00369793          	slli	a5,a3,0x3
ffffffffc0201308:	97de                	add	a5,a5,s7
ffffffffc020130a:	639c                	ld	a5,0(a5)
ffffffffc020130c:	cb99                	beqz	a5,ffffffffc0201322 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020130e:	86be                	mv	a3,a5
ffffffffc0201310:	00001617          	auipc	a2,0x1
ffffffffc0201314:	fe060613          	addi	a2,a2,-32 # ffffffffc02022f0 <buddy_pmm_manager+0x190>
ffffffffc0201318:	85a6                	mv	a1,s1
ffffffffc020131a:	854a                	mv	a0,s2
ffffffffc020131c:	0ce000ef          	jal	ra,ffffffffc02013ea <printfmt>
ffffffffc0201320:	b34d                	j	ffffffffc02010c2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	fbe60613          	addi	a2,a2,-66 # ffffffffc02022e0 <buddy_pmm_manager+0x180>
ffffffffc020132a:	85a6                	mv	a1,s1
ffffffffc020132c:	854a                	mv	a0,s2
ffffffffc020132e:	0bc000ef          	jal	ra,ffffffffc02013ea <printfmt>
ffffffffc0201332:	bb41                	j	ffffffffc02010c2 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201334:	00001417          	auipc	s0,0x1
ffffffffc0201338:	fa440413          	addi	s0,s0,-92 # ffffffffc02022d8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020133c:	85e2                	mv	a1,s8
ffffffffc020133e:	8522                	mv	a0,s0
ffffffffc0201340:	e43e                	sd	a5,8(sp)
ffffffffc0201342:	1cc000ef          	jal	ra,ffffffffc020150e <strnlen>
ffffffffc0201346:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020134a:	01b05b63          	blez	s11,ffffffffc0201360 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020134e:	67a2                	ld	a5,8(sp)
ffffffffc0201350:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201354:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201356:	85a6                	mv	a1,s1
ffffffffc0201358:	8552                	mv	a0,s4
ffffffffc020135a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020135c:	fe0d9ce3          	bnez	s11,ffffffffc0201354 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201360:	00044783          	lbu	a5,0(s0)
ffffffffc0201364:	00140a13          	addi	s4,s0,1
ffffffffc0201368:	0007851b          	sext.w	a0,a5
ffffffffc020136c:	d3a5                	beqz	a5,ffffffffc02012cc <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020136e:	05e00413          	li	s0,94
ffffffffc0201372:	bf39                	j	ffffffffc0201290 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201374:	000a2403          	lw	s0,0(s4)
ffffffffc0201378:	b7ad                	j	ffffffffc02012e2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020137a:	000a6603          	lwu	a2,0(s4)
ffffffffc020137e:	46a1                	li	a3,8
ffffffffc0201380:	8a2e                	mv	s4,a1
ffffffffc0201382:	bdb1                	j	ffffffffc02011de <vprintfmt+0x156>
ffffffffc0201384:	000a6603          	lwu	a2,0(s4)
ffffffffc0201388:	46a9                	li	a3,10
ffffffffc020138a:	8a2e                	mv	s4,a1
ffffffffc020138c:	bd89                	j	ffffffffc02011de <vprintfmt+0x156>
ffffffffc020138e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201392:	46c1                	li	a3,16
ffffffffc0201394:	8a2e                	mv	s4,a1
ffffffffc0201396:	b5a1                	j	ffffffffc02011de <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201398:	9902                	jalr	s2
ffffffffc020139a:	bf09                	j	ffffffffc02012ac <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020139c:	85a6                	mv	a1,s1
ffffffffc020139e:	02d00513          	li	a0,45
ffffffffc02013a2:	e03e                	sd	a5,0(sp)
ffffffffc02013a4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02013a6:	6782                	ld	a5,0(sp)
ffffffffc02013a8:	8a66                	mv	s4,s9
ffffffffc02013aa:	40800633          	neg	a2,s0
ffffffffc02013ae:	46a9                	li	a3,10
ffffffffc02013b0:	b53d                	j	ffffffffc02011de <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02013b2:	03b05163          	blez	s11,ffffffffc02013d4 <vprintfmt+0x34c>
ffffffffc02013b6:	02d00693          	li	a3,45
ffffffffc02013ba:	f6d79de3          	bne	a5,a3,ffffffffc0201334 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02013be:	00001417          	auipc	s0,0x1
ffffffffc02013c2:	f1a40413          	addi	s0,s0,-230 # ffffffffc02022d8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013c6:	02800793          	li	a5,40
ffffffffc02013ca:	02800513          	li	a0,40
ffffffffc02013ce:	00140a13          	addi	s4,s0,1
ffffffffc02013d2:	bd6d                	j	ffffffffc020128c <vprintfmt+0x204>
ffffffffc02013d4:	00001a17          	auipc	s4,0x1
ffffffffc02013d8:	f05a0a13          	addi	s4,s4,-251 # ffffffffc02022d9 <buddy_pmm_manager+0x179>
ffffffffc02013dc:	02800513          	li	a0,40
ffffffffc02013e0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013e4:	05e00413          	li	s0,94
ffffffffc02013e8:	b565                	j	ffffffffc0201290 <vprintfmt+0x208>

ffffffffc02013ea <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013ea:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013ec:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013f0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013f2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013f4:	ec06                	sd	ra,24(sp)
ffffffffc02013f6:	f83a                	sd	a4,48(sp)
ffffffffc02013f8:	fc3e                	sd	a5,56(sp)
ffffffffc02013fa:	e0c2                	sd	a6,64(sp)
ffffffffc02013fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02013fe:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201400:	c89ff0ef          	jal	ra,ffffffffc0201088 <vprintfmt>
}
ffffffffc0201404:	60e2                	ld	ra,24(sp)
ffffffffc0201406:	6161                	addi	sp,sp,80
ffffffffc0201408:	8082                	ret

ffffffffc020140a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020140a:	715d                	addi	sp,sp,-80
ffffffffc020140c:	e486                	sd	ra,72(sp)
ffffffffc020140e:	e0a6                	sd	s1,64(sp)
ffffffffc0201410:	fc4a                	sd	s2,56(sp)
ffffffffc0201412:	f84e                	sd	s3,48(sp)
ffffffffc0201414:	f452                	sd	s4,40(sp)
ffffffffc0201416:	f056                	sd	s5,32(sp)
ffffffffc0201418:	ec5a                	sd	s6,24(sp)
ffffffffc020141a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020141c:	c901                	beqz	a0,ffffffffc020142c <readline+0x22>
ffffffffc020141e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201420:	00001517          	auipc	a0,0x1
ffffffffc0201424:	ed050513          	addi	a0,a0,-304 # ffffffffc02022f0 <buddy_pmm_manager+0x190>
ffffffffc0201428:	c8bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020142c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020142e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201430:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201432:	4aa9                	li	s5,10
ffffffffc0201434:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201436:	00027b97          	auipc	s7,0x27
ffffffffc020143a:	ec2b8b93          	addi	s7,s7,-318 # ffffffffc02282f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020143e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201442:	ce9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201446:	00054a63          	bltz	a0,ffffffffc020145a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020144a:	00a95a63          	bge	s2,a0,ffffffffc020145e <readline+0x54>
ffffffffc020144e:	029a5263          	bge	s4,s1,ffffffffc0201472 <readline+0x68>
        c = getchar();
ffffffffc0201452:	cd9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201456:	fe055ae3          	bgez	a0,ffffffffc020144a <readline+0x40>
            return NULL;
ffffffffc020145a:	4501                	li	a0,0
ffffffffc020145c:	a091                	j	ffffffffc02014a0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020145e:	03351463          	bne	a0,s3,ffffffffc0201486 <readline+0x7c>
ffffffffc0201462:	e8a9                	bnez	s1,ffffffffc02014b4 <readline+0xaa>
        c = getchar();
ffffffffc0201464:	cc7fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201468:	fe0549e3          	bltz	a0,ffffffffc020145a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020146c:	fea959e3          	bge	s2,a0,ffffffffc020145e <readline+0x54>
ffffffffc0201470:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201472:	e42a                	sd	a0,8(sp)
ffffffffc0201474:	c75fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201478:	6522                	ld	a0,8(sp)
ffffffffc020147a:	009b87b3          	add	a5,s7,s1
ffffffffc020147e:	2485                	addiw	s1,s1,1
ffffffffc0201480:	00a78023          	sb	a0,0(a5)
ffffffffc0201484:	bf7d                	j	ffffffffc0201442 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201486:	01550463          	beq	a0,s5,ffffffffc020148e <readline+0x84>
ffffffffc020148a:	fb651ce3          	bne	a0,s6,ffffffffc0201442 <readline+0x38>
            cputchar(c);
ffffffffc020148e:	c5bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201492:	00027517          	auipc	a0,0x27
ffffffffc0201496:	e6650513          	addi	a0,a0,-410 # ffffffffc02282f8 <buf>
ffffffffc020149a:	94aa                	add	s1,s1,a0
ffffffffc020149c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02014a0:	60a6                	ld	ra,72(sp)
ffffffffc02014a2:	6486                	ld	s1,64(sp)
ffffffffc02014a4:	7962                	ld	s2,56(sp)
ffffffffc02014a6:	79c2                	ld	s3,48(sp)
ffffffffc02014a8:	7a22                	ld	s4,40(sp)
ffffffffc02014aa:	7a82                	ld	s5,32(sp)
ffffffffc02014ac:	6b62                	ld	s6,24(sp)
ffffffffc02014ae:	6bc2                	ld	s7,16(sp)
ffffffffc02014b0:	6161                	addi	sp,sp,80
ffffffffc02014b2:	8082                	ret
            cputchar(c);
ffffffffc02014b4:	4521                	li	a0,8
ffffffffc02014b6:	c33fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02014ba:	34fd                	addiw	s1,s1,-1
ffffffffc02014bc:	b759                	j	ffffffffc0201442 <readline+0x38>

ffffffffc02014be <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02014be:	4781                	li	a5,0
ffffffffc02014c0:	00005717          	auipc	a4,0x5
ffffffffc02014c4:	b4873703          	ld	a4,-1208(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02014c8:	88ba                	mv	a7,a4
ffffffffc02014ca:	852a                	mv	a0,a0
ffffffffc02014cc:	85be                	mv	a1,a5
ffffffffc02014ce:	863e                	mv	a2,a5
ffffffffc02014d0:	00000073          	ecall
ffffffffc02014d4:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02014d6:	8082                	ret

ffffffffc02014d8 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02014d8:	4781                	li	a5,0
ffffffffc02014da:	00027717          	auipc	a4,0x27
ffffffffc02014de:	27673703          	ld	a4,630(a4) # ffffffffc0228750 <SBI_SET_TIMER>
ffffffffc02014e2:	88ba                	mv	a7,a4
ffffffffc02014e4:	852a                	mv	a0,a0
ffffffffc02014e6:	85be                	mv	a1,a5
ffffffffc02014e8:	863e                	mv	a2,a5
ffffffffc02014ea:	00000073          	ecall
ffffffffc02014ee:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02014f0:	8082                	ret

ffffffffc02014f2 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02014f2:	4501                	li	a0,0
ffffffffc02014f4:	00005797          	auipc	a5,0x5
ffffffffc02014f8:	b0c7b783          	ld	a5,-1268(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02014fc:	88be                	mv	a7,a5
ffffffffc02014fe:	852a                	mv	a0,a0
ffffffffc0201500:	85aa                	mv	a1,a0
ffffffffc0201502:	862a                	mv	a2,a0
ffffffffc0201504:	00000073          	ecall
ffffffffc0201508:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020150a:	2501                	sext.w	a0,a0
ffffffffc020150c:	8082                	ret

ffffffffc020150e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020150e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201510:	e589                	bnez	a1,ffffffffc020151a <strnlen+0xc>
ffffffffc0201512:	a811                	j	ffffffffc0201526 <strnlen+0x18>
        cnt ++;
ffffffffc0201514:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201516:	00f58863          	beq	a1,a5,ffffffffc0201526 <strnlen+0x18>
ffffffffc020151a:	00f50733          	add	a4,a0,a5
ffffffffc020151e:	00074703          	lbu	a4,0(a4)
ffffffffc0201522:	fb6d                	bnez	a4,ffffffffc0201514 <strnlen+0x6>
ffffffffc0201524:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201526:	852e                	mv	a0,a1
ffffffffc0201528:	8082                	ret

ffffffffc020152a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020152a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020152e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201532:	cb89                	beqz	a5,ffffffffc0201544 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201534:	0505                	addi	a0,a0,1
ffffffffc0201536:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201538:	fee789e3          	beq	a5,a4,ffffffffc020152a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020153c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201540:	9d19                	subw	a0,a0,a4
ffffffffc0201542:	8082                	ret
ffffffffc0201544:	4501                	li	a0,0
ffffffffc0201546:	bfed                	j	ffffffffc0201540 <strcmp+0x16>

ffffffffc0201548 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201548:	00054783          	lbu	a5,0(a0)
ffffffffc020154c:	c799                	beqz	a5,ffffffffc020155a <strchr+0x12>
        if (*s == c) {
ffffffffc020154e:	00f58763          	beq	a1,a5,ffffffffc020155c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201552:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201556:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201558:	fbfd                	bnez	a5,ffffffffc020154e <strchr+0x6>
    }
    return NULL;
ffffffffc020155a:	4501                	li	a0,0
}
ffffffffc020155c:	8082                	ret

ffffffffc020155e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020155e:	ca01                	beqz	a2,ffffffffc020156e <memset+0x10>
ffffffffc0201560:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201562:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201564:	0785                	addi	a5,a5,1
ffffffffc0201566:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020156a:	fec79de3          	bne	a5,a2,ffffffffc0201564 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020156e:	8082                	ret
