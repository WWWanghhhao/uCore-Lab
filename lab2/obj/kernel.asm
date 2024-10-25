
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
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <buddy>
ffffffffc020003a:	00028617          	auipc	a2,0x28
ffffffffc020003e:	72660613          	addi	a2,a2,1830 # ffffffffc0228760 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	4f0010ef          	jal	ra,ffffffffc020153a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201550 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	5ff000ef          	jal	ra,ffffffffc0200e64 <pmm_init>

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
ffffffffc02000a6:	7bf000ef          	jal	ra,ffffffffc0201064 <vprintfmt>
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
ffffffffc02000dc:	789000ef          	jal	ra,ffffffffc0201064 <vprintfmt>
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
ffffffffc0200140:	43450513          	addi	a0,a0,1076 # ffffffffc0201570 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	43e50513          	addi	a0,a0,1086 # ffffffffc0201590 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	3ee58593          	addi	a1,a1,1006 # ffffffffc020154c <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	44a50513          	addi	a0,a0,1098 # ffffffffc02015b0 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <buddy>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	45650513          	addi	a0,a0,1110 # ffffffffc02015d0 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00028597          	auipc	a1,0x28
ffffffffc020018a:	5da58593          	addi	a1,a1,1498 # ffffffffc0228760 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	46250513          	addi	a0,a0,1122 # ffffffffc02015f0 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00029597          	auipc	a1,0x29
ffffffffc020019e:	9c558593          	addi	a1,a1,-1595 # ffffffffc0228b5f <end+0x3ff>
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
ffffffffc02001c0:	45450513          	addi	a0,a0,1108 # ffffffffc0201610 <etext+0xc4>
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
ffffffffc02001ce:	47660613          	addi	a2,a2,1142 # ffffffffc0201640 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	48250513          	addi	a0,a0,1154 # ffffffffc0201658 <etext+0x10c>
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
ffffffffc02001ea:	48a60613          	addi	a2,a2,1162 # ffffffffc0201670 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	4a258593          	addi	a1,a1,1186 # ffffffffc0201690 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	4a250513          	addi	a0,a0,1186 # ffffffffc0201698 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	4a460613          	addi	a2,a2,1188 # ffffffffc02016a8 <etext+0x15c>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	4c458593          	addi	a1,a1,1220 # ffffffffc02016d0 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	48450513          	addi	a0,a0,1156 # ffffffffc0201698 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	4c060613          	addi	a2,a2,1216 # ffffffffc02016e0 <etext+0x194>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	4d858593          	addi	a1,a1,1240 # ffffffffc0201700 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	46850513          	addi	a0,a0,1128 # ffffffffc0201698 <etext+0x14c>
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
ffffffffc020026e:	4a650513          	addi	a0,a0,1190 # ffffffffc0201710 <etext+0x1c4>
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
ffffffffc0200290:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201738 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	506c0c13          	addi	s8,s8,1286 # ffffffffc02017a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	4b690913          	addi	s2,s2,1206 # ffffffffc0201760 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	4b648493          	addi	s1,s1,1206 # ffffffffc0201768 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	4b4b0b13          	addi	s6,s6,1204 # ffffffffc0201770 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	3cca0a13          	addi	s4,s4,972 # ffffffffc0201690 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	116010ef          	jal	ra,ffffffffc02013e6 <readline>
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
ffffffffc02002ea:	4c2d0d13          	addi	s10,s10,1218 # ffffffffc02017a8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	212010ef          	jal	ra,ffffffffc0201506 <strcmp>
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
ffffffffc0200308:	1fe010ef          	jal	ra,ffffffffc0201506 <strcmp>
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
ffffffffc0200346:	1de010ef          	jal	ra,ffffffffc0201524 <strchr>
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
ffffffffc0200384:	1a0010ef          	jal	ra,ffffffffc0201524 <strchr>
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
ffffffffc02003a2:	3f250513          	addi	a0,a0,1010 # ffffffffc0201790 <etext+0x244>
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
ffffffffc02003b0:	35430313          	addi	t1,t1,852 # ffffffffc0228700 <is_panic>
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
ffffffffc02003de:	41650513          	addi	a0,a0,1046 # ffffffffc02017f0 <commands+0x48>
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
ffffffffc02003f4:	c9850513          	addi	a0,a0,-872 # ffffffffc0202088 <commands+0x8e0>
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
ffffffffc0200420:	094010ef          	jal	ra,ffffffffc02014b4 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00028797          	auipc	a5,0x28
ffffffffc020042a:	2e07b123          	sd	zero,738(a5) # ffffffffc0228708 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	3e250513          	addi	a0,a0,994 # ffffffffc0201810 <commands+0x68>
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
ffffffffc0200446:	06e0106f          	j	ffffffffc02014b4 <sbi_set_timer>

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
ffffffffc0200450:	04a0106f          	j	ffffffffc020149a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	07a0106f          	j	ffffffffc02014ce <sbi_console_getchar>

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
ffffffffc0200482:	3b250513          	addi	a0,a0,946 # ffffffffc0201830 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	3ba50513          	addi	a0,a0,954 # ffffffffc0201848 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	3c450513          	addi	a0,a0,964 # ffffffffc0201860 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	3ce50513          	addi	a0,a0,974 # ffffffffc0201878 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	3d850513          	addi	a0,a0,984 # ffffffffc0201890 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	3e250513          	addi	a0,a0,994 # ffffffffc02018a8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	3ec50513          	addi	a0,a0,1004 # ffffffffc02018c0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	3f650513          	addi	a0,a0,1014 # ffffffffc02018d8 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	40050513          	addi	a0,a0,1024 # ffffffffc02018f0 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	40a50513          	addi	a0,a0,1034 # ffffffffc0201908 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	41450513          	addi	a0,a0,1044 # ffffffffc0201920 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	41e50513          	addi	a0,a0,1054 # ffffffffc0201938 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	42850513          	addi	a0,a0,1064 # ffffffffc0201950 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	43250513          	addi	a0,a0,1074 # ffffffffc0201968 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	43c50513          	addi	a0,a0,1084 # ffffffffc0201980 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	44650513          	addi	a0,a0,1094 # ffffffffc0201998 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	45050513          	addi	a0,a0,1104 # ffffffffc02019b0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	45a50513          	addi	a0,a0,1114 # ffffffffc02019c8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	46450513          	addi	a0,a0,1124 # ffffffffc02019e0 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	46e50513          	addi	a0,a0,1134 # ffffffffc02019f8 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	47850513          	addi	a0,a0,1144 # ffffffffc0201a10 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	48250513          	addi	a0,a0,1154 # ffffffffc0201a28 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	48c50513          	addi	a0,a0,1164 # ffffffffc0201a40 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	49650513          	addi	a0,a0,1174 # ffffffffc0201a58 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4a050513          	addi	a0,a0,1184 # ffffffffc0201a70 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0201a88 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4b450513          	addi	a0,a0,1204 # ffffffffc0201aa0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	4be50513          	addi	a0,a0,1214 # ffffffffc0201ab8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	4c850513          	addi	a0,a0,1224 # ffffffffc0201ad0 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	4d250513          	addi	a0,a0,1234 # ffffffffc0201ae8 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	4dc50513          	addi	a0,a0,1244 # ffffffffc0201b00 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	4e250513          	addi	a0,a0,1250 # ffffffffc0201b18 <commands+0x370>
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
ffffffffc020064e:	4e650513          	addi	a0,a0,1254 # ffffffffc0201b30 <commands+0x388>
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
ffffffffc0200666:	4e650513          	addi	a0,a0,1254 # ffffffffc0201b48 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201b60 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	4f650513          	addi	a0,a0,1270 # ffffffffc0201b78 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201b90 <commands+0x3e8>
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
ffffffffc02006b4:	5c070713          	addi	a4,a4,1472 # ffffffffc0201c70 <commands+0x4c8>
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
ffffffffc02006c6:	54650513          	addi	a0,a0,1350 # ffffffffc0201c08 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	51c50513          	addi	a0,a0,1308 # ffffffffc0201be8 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	4d250513          	addi	a0,a0,1234 # ffffffffc0201ba8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	54850513          	addi	a0,a0,1352 # ffffffffc0201c28 <commands+0x480>
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
ffffffffc02006f6:	01668693          	addi	a3,a3,22 # ffffffffc0228708 <ticks>
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
ffffffffc0200714:	54050513          	addi	a0,a0,1344 # ffffffffc0201c50 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0201bc8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	51450513          	addi	a0,a0,1300 # ffffffffc0201c40 <commands+0x498>
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

ffffffffc0200802 <buddy_init>:
    return size/2;
}

static void
buddy_init(void) {
    size=nr_free = 0;
ffffffffc0200802:	00028797          	auipc	a5,0x28
ffffffffc0200806:	f007bb23          	sd	zero,-234(a5) # ffffffffc0228718 <nr_free>
ffffffffc020080a:	00028797          	auipc	a5,0x28
ffffffffc020080e:	f007bb23          	sd	zero,-234(a5) # ffffffffc0228720 <size>
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00028517          	auipc	a0,0x28
ffffffffc0200818:	f0453503          	ld	a0,-252(a0) # ffffffffc0228718 <nr_free>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <buddy_free_pages>:
    unsigned int offset=(base-buddy_base);
ffffffffc020081e:	00028717          	auipc	a4,0x28
ffffffffc0200822:	ef273703          	ld	a4,-270(a4) # ffffffffc0228710 <buddy_base>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200826:	1141                	addi	sp,sp,-16
    unsigned int offset=(base-buddy_base);
ffffffffc0200828:	40e50733          	sub	a4,a0,a4
ffffffffc020082c:	870d                	srai	a4,a4,0x3
ffffffffc020082e:	00002797          	auipc	a5,0x2
ffffffffc0200832:	cda7b783          	ld	a5,-806(a5) # ffffffffc0202508 <error_string+0x38>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200836:	e406                	sd	ra,8(sp)
    assert(self&&offset >= 0 && offset < self->size);
ffffffffc0200838:	00005597          	auipc	a1,0x5
ffffffffc020083c:	7c85b583          	ld	a1,1992(a1) # ffffffffc0206000 <self>
    unsigned int offset=(base-buddy_base);
ffffffffc0200840:	02f7073b          	mulw	a4,a4,a5
    assert(self&&offset >= 0 && offset < self->size);
ffffffffc0200844:	10058863          	beqz	a1,ffffffffc0200954 <buddy_free_pages+0x136>
ffffffffc0200848:	419c                	lw	a5,0(a1)
ffffffffc020084a:	10f77563          	bgeu	a4,a5,ffffffffc0200954 <buddy_free_pages+0x136>
    index = offset + self->size - 1;//child
ffffffffc020084e:	37fd                	addiw	a5,a5,-1
ffffffffc0200850:	9fb9                	addw	a5,a5,a4
    for (; self->longest[index] ; index = PARENT(index)) {
ffffffffc0200852:	02079693          	slli	a3,a5,0x20
ffffffffc0200856:	01e6d713          	srli	a4,a3,0x1e
ffffffffc020085a:	972e                	add	a4,a4,a1
ffffffffc020085c:	4358                	lw	a4,4(a4)
ffffffffc020085e:	c771                	beqz	a4,ffffffffc020092a <buddy_free_pages+0x10c>
        node_size *= 2;
ffffffffc0200860:	4689                	li	a3,2
        if (index == 0)
ffffffffc0200862:	e789                	bnez	a5,ffffffffc020086c <buddy_free_pages+0x4e>
ffffffffc0200864:	a0c1                	j	ffffffffc0200924 <buddy_free_pages+0x106>
        node_size *= 2;
ffffffffc0200866:	0016969b          	slliw	a3,a3,0x1
        if (index == 0)
ffffffffc020086a:	cfcd                	beqz	a5,ffffffffc0200924 <buddy_free_pages+0x106>
    for (; self->longest[index] ; index = PARENT(index)) {
ffffffffc020086c:	2785                	addiw	a5,a5,1
ffffffffc020086e:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200872:	37fd                	addiw	a5,a5,-1
ffffffffc0200874:	02079613          	slli	a2,a5,0x20
ffffffffc0200878:	01e65713          	srli	a4,a2,0x1e
ffffffffc020087c:	972e                	add	a4,a4,a1
ffffffffc020087e:	4358                	lw	a4,4(a4)
ffffffffc0200880:	f37d                	bnez	a4,ffffffffc0200866 <buddy_free_pages+0x48>
    for (; p != base + node_size; p ++) {
ffffffffc0200882:	02069813          	slli	a6,a3,0x20
ffffffffc0200886:	02085813          	srli	a6,a6,0x20
ffffffffc020088a:	00281613          	slli	a2,a6,0x2
ffffffffc020088e:	9642                	add	a2,a2,a6
ffffffffc0200890:	060e                	slli	a2,a2,0x3
    self->longest[index] = node_size;
ffffffffc0200892:	02079893          	slli	a7,a5,0x20
ffffffffc0200896:	01e8d713          	srli	a4,a7,0x1e
ffffffffc020089a:	972e                	add	a4,a4,a1
ffffffffc020089c:	c354                	sw	a3,4(a4)
    for (; p != base + node_size; p ++) {
ffffffffc020089e:	962a                	add	a2,a2,a0
ffffffffc02008a0:	02c50063          	beq	a0,a2,ffffffffc02008c0 <buddy_free_pages+0xa2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008a4:	6518                	ld	a4,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02008a6:	8b05                	andi	a4,a4,1
ffffffffc02008a8:	e751                	bnez	a4,ffffffffc0200934 <buddy_free_pages+0x116>
ffffffffc02008aa:	6518                	ld	a4,8(a0)
ffffffffc02008ac:	8b09                	andi	a4,a4,2
ffffffffc02008ae:	e359                	bnez	a4,ffffffffc0200934 <buddy_free_pages+0x116>
        p->flags = 0;
ffffffffc02008b0:	00053423          	sd	zero,8(a0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008b4:	00052023          	sw	zero,0(a0)
    for (; p != base + node_size; p ++) {
ffffffffc02008b8:	02850513          	addi	a0,a0,40
ffffffffc02008bc:	fec514e3          	bne	a0,a2,ffffffffc02008a4 <buddy_free_pages+0x86>
    nr_free+=node_size;
ffffffffc02008c0:	00028617          	auipc	a2,0x28
ffffffffc02008c4:	e5860613          	addi	a2,a2,-424 # ffffffffc0228718 <nr_free>
ffffffffc02008c8:	6218                	ld	a4,0(a2)
ffffffffc02008ca:	9742                	add	a4,a4,a6
ffffffffc02008cc:	e218                	sd	a4,0(a2)
    while (index) {
ffffffffc02008ce:	cbb9                	beqz	a5,ffffffffc0200924 <buddy_free_pages+0x106>
        index = PARENT(index);
ffffffffc02008d0:	2785                	addiw	a5,a5,1
ffffffffc02008d2:	0017d71b          	srliw	a4,a5,0x1
ffffffffc02008d6:	377d                	addiw	a4,a4,-1
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008d8:	0017161b          	slliw	a2,a4,0x1
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008dc:	9bf9                	andi	a5,a5,-2
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008de:	2605                	addiw	a2,a2,1
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008e0:	1782                	slli	a5,a5,0x20
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008e2:	02061513          	slli	a0,a2,0x20
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008e6:	9381                	srli	a5,a5,0x20
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008e8:	01e55613          	srli	a2,a0,0x1e
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008ec:	078a                	slli	a5,a5,0x2
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008ee:	962e                	add	a2,a2,a1
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008f0:	97ae                	add	a5,a5,a1
        left_longest = self->longest[LEFT_LEAF(index)];
ffffffffc02008f2:	4248                	lw	a0,4(a2)
        right_longest = self->longest[RIGHT_LEAF(index)];
ffffffffc02008f4:	0047a803          	lw	a6,4(a5)
        node_size *= 2;
ffffffffc02008f8:	0016969b          	slliw	a3,a3,0x1
        index = PARENT(index);
ffffffffc02008fc:	0007079b          	sext.w	a5,a4
        if (left_longest + right_longest == node_size) 
ffffffffc0200900:	010508bb          	addw	a7,a0,a6
ffffffffc0200904:	8636                	mv	a2,a3
ffffffffc0200906:	00d88863          	beq	a7,a3,ffffffffc0200916 <buddy_free_pages+0xf8>
            self->longest[index] = MAX(left_longest, right_longest);
ffffffffc020090a:	0005061b          	sext.w	a2,a0
ffffffffc020090e:	01057463          	bgeu	a0,a6,ffffffffc0200916 <buddy_free_pages+0xf8>
ffffffffc0200912:	0008061b          	sext.w	a2,a6
ffffffffc0200916:	02071513          	slli	a0,a4,0x20
ffffffffc020091a:	01e55713          	srli	a4,a0,0x1e
ffffffffc020091e:	972e                	add	a4,a4,a1
ffffffffc0200920:	c350                	sw	a2,4(a4)
    while (index) {
ffffffffc0200922:	f7dd                	bnez	a5,ffffffffc02008d0 <buddy_free_pages+0xb2>
}
ffffffffc0200924:	60a2                	ld	ra,8(sp)
ffffffffc0200926:	0141                	addi	sp,sp,16
ffffffffc0200928:	8082                	ret
    for (; self->longest[index] ; index = PARENT(index)) {
ffffffffc020092a:	02800613          	li	a2,40
ffffffffc020092e:	4805                	li	a6,1
    node_size = 1;
ffffffffc0200930:	4685                	li	a3,1
ffffffffc0200932:	b785                	j	ffffffffc0200892 <buddy_free_pages+0x74>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200934:	00001697          	auipc	a3,0x1
ffffffffc0200938:	3cc68693          	addi	a3,a3,972 # ffffffffc0201d00 <commands+0x558>
ffffffffc020093c:	00001617          	auipc	a2,0x1
ffffffffc0200940:	39460613          	addi	a2,a2,916 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200944:	07c00593          	li	a1,124
ffffffffc0200948:	00001517          	auipc	a0,0x1
ffffffffc020094c:	3a050513          	addi	a0,a0,928 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200950:	a5dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(self&&offset >= 0 && offset < self->size);
ffffffffc0200954:	00001697          	auipc	a3,0x1
ffffffffc0200958:	34c68693          	addi	a3,a3,844 # ffffffffc0201ca0 <commands+0x4f8>
ffffffffc020095c:	00001617          	auipc	a2,0x1
ffffffffc0200960:	37460613          	addi	a2,a2,884 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200964:	06e00593          	li	a1,110
ffffffffc0200968:	00001517          	auipc	a0,0x1
ffffffffc020096c:	38050513          	addi	a0,a0,896 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200970:	a3dff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200974 <buddy_alloc_pages>:
    assert(self);
ffffffffc0200974:	00005597          	auipc	a1,0x5
ffffffffc0200978:	68c5b583          	ld	a1,1676(a1) # ffffffffc0206000 <self>
ffffffffc020097c:	10058a63          	beqz	a1,ffffffffc0200a90 <buddy_alloc_pages+0x11c>
        size=n=1;
ffffffffc0200980:	4605                	li	a2,1
    if(n<=0)
ffffffffc0200982:	e57d                	bnez	a0,ffffffffc0200a70 <buddy_alloc_pages+0xfc>
    if (self->longest[index] < size)
ffffffffc0200984:	0045e783          	lwu	a5,4(a1)
ffffffffc0200988:	0ec7ec63          	bltu	a5,a2,ffffffffc0200a80 <buddy_alloc_pages+0x10c>
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc020098c:	0005a883          	lw	a7,0(a1)
    nr_free-=size;
ffffffffc0200990:	00028317          	auipc	t1,0x28
ffffffffc0200994:	d8830313          	addi	t1,t1,-632 # ffffffffc0228718 <nr_free>
ffffffffc0200998:	00033783          	ld	a5,0(t1)
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc020099c:	02089713          	slli	a4,a7,0x20
ffffffffc02009a0:	9301                	srli	a4,a4,0x20
    nr_free-=size;
ffffffffc02009a2:	40c78833          	sub	a6,a5,a2
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc02009a6:	0ce60f63          	beq	a2,a4,ffffffffc0200a84 <buddy_alloc_pages+0x110>
ffffffffc02009aa:	86c6                	mv	a3,a7
    unsigned index = 0;
ffffffffc02009ac:	4781                	li	a5,0
        if (self->longest[LEFT_LEAF(index)] >= size)
ffffffffc02009ae:	0017951b          	slliw	a0,a5,0x1
ffffffffc02009b2:	0015079b          	addiw	a5,a0,1
ffffffffc02009b6:	02079e13          	slli	t3,a5,0x20
ffffffffc02009ba:	01ee5713          	srli	a4,t3,0x1e
ffffffffc02009be:	972e                	add	a4,a4,a1
ffffffffc02009c0:	00476703          	lwu	a4,4(a4)
ffffffffc02009c4:	00c77463          	bgeu	a4,a2,ffffffffc02009cc <buddy_alloc_pages+0x58>
            index = RIGHT_LEAF(index);
ffffffffc02009c8:	0025079b          	addiw	a5,a0,2
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
ffffffffc02009cc:	0016d71b          	srliw	a4,a3,0x1
ffffffffc02009d0:	02071513          	slli	a0,a4,0x20
ffffffffc02009d4:	9101                	srli	a0,a0,0x20
ffffffffc02009d6:	0007069b          	sext.w	a3,a4
ffffffffc02009da:	fcc51ae3          	bne	a0,a2,ffffffffc02009ae <buddy_alloc_pages+0x3a>
    offset = (index + 1) * node_size - self->size;
ffffffffc02009de:	0017871b          	addiw	a4,a5,1
ffffffffc02009e2:	02d706bb          	mulw	a3,a4,a3
    self->longest[index] = 0;
ffffffffc02009e6:	02079e13          	slli	t3,a5,0x20
ffffffffc02009ea:	01ee5513          	srli	a0,t3,0x1e
ffffffffc02009ee:	952e                	add	a0,a0,a1
    nr_free-=size;
ffffffffc02009f0:	01033023          	sd	a6,0(t1)
    self->longest[index] = 0;
ffffffffc02009f4:	00052223          	sw	zero,4(a0)
    offset = (index + 1) * node_size - self->size;
ffffffffc02009f8:	411686bb          	subw	a3,a3,a7
    page=offset+buddy_base;
ffffffffc02009fc:	1682                	slli	a3,a3,0x20
ffffffffc02009fe:	9281                	srli	a3,a3,0x20
ffffffffc0200a00:	00269513          	slli	a0,a3,0x2
ffffffffc0200a04:	9536                	add	a0,a0,a3
ffffffffc0200a06:	00351e93          	slli	t4,a0,0x3
    while (index) {
ffffffffc0200a0a:	e781                	bnez	a5,ffffffffc0200a12 <buddy_alloc_pages+0x9e>
ffffffffc0200a0c:	a0b1                	j	ffffffffc0200a58 <buddy_alloc_pages+0xe4>
ffffffffc0200a0e:	0017871b          	addiw	a4,a5,1
        index = PARENT(index);
ffffffffc0200a12:	0017579b          	srliw	a5,a4,0x1
ffffffffc0200a16:	37fd                	addiw	a5,a5,-1
        MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
ffffffffc0200a18:	0017969b          	slliw	a3,a5,0x1
ffffffffc0200a1c:	9b79                	andi	a4,a4,-2
ffffffffc0200a1e:	2685                	addiw	a3,a3,1
ffffffffc0200a20:	1702                	slli	a4,a4,0x20
ffffffffc0200a22:	9301                	srli	a4,a4,0x20
ffffffffc0200a24:	02069513          	slli	a0,a3,0x20
ffffffffc0200a28:	01e55693          	srli	a3,a0,0x1e
ffffffffc0200a2c:	070a                	slli	a4,a4,0x2
ffffffffc0200a2e:	96ae                	add	a3,a3,a1
ffffffffc0200a30:	972e                	add	a4,a4,a1
ffffffffc0200a32:	00472883          	lw	a7,4(a4)
ffffffffc0200a36:	0046a803          	lw	a6,4(a3)
        self->longest[index] = 
ffffffffc0200a3a:	02079693          	slli	a3,a5,0x20
ffffffffc0200a3e:	01e6d713          	srli	a4,a3,0x1e
        MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
ffffffffc0200a42:	0008831b          	sext.w	t1,a7
ffffffffc0200a46:	00080e1b          	sext.w	t3,a6
        self->longest[index] = 
ffffffffc0200a4a:	972e                	add	a4,a4,a1
        MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
ffffffffc0200a4c:	006e7363          	bgeu	t3,t1,ffffffffc0200a52 <buddy_alloc_pages+0xde>
ffffffffc0200a50:	8846                	mv	a6,a7
        self->longest[index] = 
ffffffffc0200a52:	01072223          	sw	a6,4(a4)
    while (index) {
ffffffffc0200a56:	ffc5                	bnez	a5,ffffffffc0200a0e <buddy_alloc_pages+0x9a>
    page=offset+buddy_base;
ffffffffc0200a58:	00028517          	auipc	a0,0x28
ffffffffc0200a5c:	cb853503          	ld	a0,-840(a0) # ffffffffc0228710 <buddy_base>
ffffffffc0200a60:	9576                	add	a0,a0,t4
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a62:	57f5                	li	a5,-3
ffffffffc0200a64:	00850713          	addi	a4,a0,8
ffffffffc0200a68:	60f7302f          	amoand.d	zero,a5,(a4)
    page->property=size;
ffffffffc0200a6c:	c910                	sw	a2,16(a0)
    return page;
ffffffffc0200a6e:	8082                	ret
    for(;size<=n;size*=2);
ffffffffc0200a70:	0606                	slli	a2,a2,0x1
ffffffffc0200a72:	fec57fe3          	bgeu	a0,a2,ffffffffc0200a70 <buddy_alloc_pages+0xfc>
    if (self->longest[index] < size)
ffffffffc0200a76:	0045e783          	lwu	a5,4(a1)
    return size/2;
ffffffffc0200a7a:	8205                	srli	a2,a2,0x1
    if (self->longest[index] < size)
ffffffffc0200a7c:	f0c7f8e3          	bgeu	a5,a2,ffffffffc020098c <buddy_alloc_pages+0x18>
        return NULL;
ffffffffc0200a80:	4501                	li	a0,0
}
ffffffffc0200a82:	8082                	ret
    nr_free-=size;
ffffffffc0200a84:	01033023          	sd	a6,0(t1)
    self->longest[index] = 0;
ffffffffc0200a88:	0005a223          	sw	zero,4(a1)
ffffffffc0200a8c:	4e81                	li	t4,0
ffffffffc0200a8e:	b7e9                	j	ffffffffc0200a58 <buddy_alloc_pages+0xe4>
buddy_alloc_pages(size_t n) {
ffffffffc0200a90:	1141                	addi	sp,sp,-16
    assert(self);
ffffffffc0200a92:	00001697          	auipc	a3,0x1
ffffffffc0200a96:	29668693          	addi	a3,a3,662 # ffffffffc0201d28 <commands+0x580>
ffffffffc0200a9a:	00001617          	auipc	a2,0x1
ffffffffc0200a9e:	23660613          	addi	a2,a2,566 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200aa2:	04400593          	li	a1,68
ffffffffc0200aa6:	00001517          	auipc	a0,0x1
ffffffffc0200aaa:	24250513          	addi	a0,a0,578 # ffffffffc0201ce8 <commands+0x540>
buddy_alloc_pages(size_t n) {
ffffffffc0200aae:	e406                	sd	ra,8(sp)
    assert(self);
ffffffffc0200ab0:	8fdff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ab4 <basic_check>:

    free_page(p1);
    free_page(p2);
}

static void basic_check(void) {
ffffffffc0200ab4:	7179                	addi	sp,sp,-48
cprintf(
ffffffffc0200ab6:	00001517          	auipc	a0,0x1
ffffffffc0200aba:	27a50513          	addi	a0,a0,634 # ffffffffc0201d30 <commands+0x588>
static void basic_check(void) {
ffffffffc0200abe:	f406                	sd	ra,40(sp)
ffffffffc0200ac0:	f022                	sd	s0,32(sp)
ffffffffc0200ac2:	ec26                	sd	s1,24(sp)
ffffffffc0200ac4:	e84a                	sd	s2,16(sp)
ffffffffc0200ac6:	e44e                	sd	s3,8(sp)
ffffffffc0200ac8:	e052                	sd	s4,0(sp)
cprintf(
ffffffffc0200aca:	de8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ace:	4505                	li	a0,1
ffffffffc0200ad0:	316000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200ad4:	1c050d63          	beqz	a0,ffffffffc0200cae <basic_check+0x1fa>
ffffffffc0200ad8:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ada:	4505                	li	a0,1
ffffffffc0200adc:	30a000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200ae0:	892a                	mv	s2,a0
ffffffffc0200ae2:	20050663          	beqz	a0,ffffffffc0200cee <basic_check+0x23a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ae6:	4505                	li	a0,1
ffffffffc0200ae8:	2fe000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	1e050063          	beqz	a0,ffffffffc0200cce <basic_check+0x21a>
    free_page(p0);
ffffffffc0200af2:	8522                	mv	a0,s0
ffffffffc0200af4:	4585                	li	a1,1
ffffffffc0200af6:	32e000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    free_page(p1);
ffffffffc0200afa:	854a                	mv	a0,s2
ffffffffc0200afc:	4585                	li	a1,1
ffffffffc0200afe:	326000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    free_page(p2);
ffffffffc0200b02:	4585                	li	a1,1
ffffffffc0200b04:	8526                	mv	a0,s1
ffffffffc0200b06:	31e000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    
    p0=alloc_pages(70);
ffffffffc0200b0a:	04600513          	li	a0,70
ffffffffc0200b0e:	2d8000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200b12:	8a2a                	mv	s4,a0
    p1=alloc_pages(35);
ffffffffc0200b14:	02300513          	li	a0,35
ffffffffc0200b18:	2ce000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200b1c:	842a                	mv	s0,a0
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
ffffffffc0200b1e:	85d2                	mv	a1,s4
ffffffffc0200b20:	00001517          	auipc	a0,0x1
ffffffffc0200b24:	4f050513          	addi	a0,a0,1264 # ffffffffc0202010 <commands+0x868>
ffffffffc0200b28:	d8aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1 %p\n",p1);
ffffffffc0200b2c:	85a2                	mv	a1,s0
ffffffffc0200b2e:	00001517          	auipc	a0,0x1
ffffffffc0200b32:	4ea50513          	addi	a0,a0,1258 # ffffffffc0202018 <commands+0x870>
ffffffffc0200b36:	d7cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
ffffffffc0200b3a:	414405b3          	sub	a1,s0,s4
ffffffffc0200b3e:	00002997          	auipc	s3,0x2
ffffffffc0200b42:	9ca9b983          	ld	s3,-1590(s3) # ffffffffc0202508 <error_string+0x38>
ffffffffc0200b46:	858d                	srai	a1,a1,0x3
ffffffffc0200b48:	033585b3          	mul	a1,a1,s3
ffffffffc0200b4c:	00001517          	auipc	a0,0x1
ffffffffc0200b50:	4d450513          	addi	a0,a0,1236 # ffffffffc0202020 <commands+0x878>
ffffffffc0200b54:	d5eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p2=alloc_pages(257);
ffffffffc0200b58:	10100513          	li	a0,257
ffffffffc0200b5c:	28a000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200b60:	84aa                	mv	s1,a0
    cprintf("p2 %p\n",p2);
ffffffffc0200b62:	85aa                	mv	a1,a0
ffffffffc0200b64:	00001517          	auipc	a0,0x1
ffffffffc0200b68:	4d450513          	addi	a0,a0,1236 # ffffffffc0202038 <commands+0x890>
ffffffffc0200b6c:	d46ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
ffffffffc0200b70:	408485b3          	sub	a1,s1,s0
ffffffffc0200b74:	858d                	srai	a1,a1,0x3
ffffffffc0200b76:	033585b3          	mul	a1,a1,s3
ffffffffc0200b7a:	00001517          	auipc	a0,0x1
ffffffffc0200b7e:	4c650513          	addi	a0,a0,1222 # ffffffffc0202040 <commands+0x898>
ffffffffc0200b82:	d30ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p3=alloc_pages(63);
ffffffffc0200b86:	03f00513          	li	a0,63
ffffffffc0200b8a:	25c000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200b8e:	892a                	mv	s2,a0
    cprintf("p3 %p\n",p3);
ffffffffc0200b90:	85aa                	mv	a1,a0
ffffffffc0200b92:	00001517          	auipc	a0,0x1
ffffffffc0200b96:	4ce50513          	addi	a0,a0,1230 # ffffffffc0202060 <commands+0x8b8>
ffffffffc0200b9a:	d18ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
ffffffffc0200b9e:	408905b3          	sub	a1,s2,s0
ffffffffc0200ba2:	858d                	srai	a1,a1,0x3
ffffffffc0200ba4:	033585b3          	mul	a1,a1,s3
ffffffffc0200ba8:	00001517          	auipc	a0,0x1
ffffffffc0200bac:	4c050513          	addi	a0,a0,1216 # ffffffffc0202068 <commands+0x8c0>
ffffffffc0200bb0:	d02ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    free_pages(p0,70);    
ffffffffc0200bb4:	04600593          	li	a1,70
ffffffffc0200bb8:	8552                	mv	a0,s4
ffffffffc0200bba:	26a000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p0!\n");
ffffffffc0200bbe:	00001517          	auipc	a0,0x1
ffffffffc0200bc2:	4c250513          	addi	a0,a0,1218 # ffffffffc0202080 <commands+0x8d8>
ffffffffc0200bc6:	cecff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p1,35);
ffffffffc0200bca:	02300593          	li	a1,35
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	254000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p1!\n");
ffffffffc0200bd4:	00001517          	auipc	a0,0x1
ffffffffc0200bd8:	4bc50513          	addi	a0,a0,1212 # ffffffffc0202090 <commands+0x8e8>
ffffffffc0200bdc:	cd6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p3,63);    
ffffffffc0200be0:	03f00593          	li	a1,63
ffffffffc0200be4:	854a                	mv	a0,s2
ffffffffc0200be6:	23e000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p3!\n");
ffffffffc0200bea:	00001517          	auipc	a0,0x1
ffffffffc0200bee:	4b650513          	addi	a0,a0,1206 # ffffffffc02020a0 <commands+0x8f8>
ffffffffc0200bf2:	cc0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p4=alloc_pages(255);
ffffffffc0200bf6:	0ff00513          	li	a0,255
ffffffffc0200bfa:	1ec000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200bfe:	842a                	mv	s0,a0
    cprintf("p4 %p\n",p4);
ffffffffc0200c00:	85aa                	mv	a1,a0
ffffffffc0200c02:	00001517          	auipc	a0,0x1
ffffffffc0200c06:	4ae50513          	addi	a0,a0,1198 # ffffffffc02020b0 <commands+0x908>
ffffffffc0200c0a:	ca8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
ffffffffc0200c0e:	408485b3          	sub	a1,s1,s0
ffffffffc0200c12:	858d                	srai	a1,a1,0x3
ffffffffc0200c14:	033585b3          	mul	a1,a1,s3
ffffffffc0200c18:	00001517          	auipc	a0,0x1
ffffffffc0200c1c:	4a050513          	addi	a0,a0,1184 # ffffffffc02020b8 <commands+0x910>
ffffffffc0200c20:	c92ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    p5=alloc_pages(255);
ffffffffc0200c24:	0ff00513          	li	a0,255
ffffffffc0200c28:	1be000ef          	jal	ra,ffffffffc0200de6 <alloc_pages>
ffffffffc0200c2c:	892a                	mv	s2,a0
    cprintf("p5 %p\n",p5);
ffffffffc0200c2e:	85aa                	mv	a1,a0
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	4a050513          	addi	a0,a0,1184 # ffffffffc02020d0 <commands+0x928>
ffffffffc0200c38:	c7aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
ffffffffc0200c3c:	408905b3          	sub	a1,s2,s0
ffffffffc0200c40:	858d                	srai	a1,a1,0x3
ffffffffc0200c42:	033585b3          	mul	a1,a1,s3
ffffffffc0200c46:	00001517          	auipc	a0,0x1
ffffffffc0200c4a:	49250513          	addi	a0,a0,1170 # ffffffffc02020d8 <commands+0x930>
ffffffffc0200c4e:	c64ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        free_pages(p2,257);    
ffffffffc0200c52:	10100593          	li	a1,257
ffffffffc0200c56:	8526                	mv	a0,s1
ffffffffc0200c58:	1cc000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p2!\n");
ffffffffc0200c5c:	00001517          	auipc	a0,0x1
ffffffffc0200c60:	49450513          	addi	a0,a0,1172 # ffffffffc02020f0 <commands+0x948>
ffffffffc0200c64:	c4eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        free_pages(p4,255);    
ffffffffc0200c68:	0ff00593          	li	a1,255
ffffffffc0200c6c:	8522                	mv	a0,s0
ffffffffc0200c6e:	1b6000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p4!\n"); 
ffffffffc0200c72:	00001517          	auipc	a0,0x1
ffffffffc0200c76:	48e50513          	addi	a0,a0,1166 # ffffffffc0202100 <commands+0x958>
ffffffffc0200c7a:	c38ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            free_pages(p5,255);    
ffffffffc0200c7e:	854a                	mv	a0,s2
ffffffffc0200c80:	0ff00593          	li	a1,255
ffffffffc0200c84:	1a0000ef          	jal	ra,ffffffffc0200e24 <free_pages>
    cprintf("free p5!\n");   
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	48850513          	addi	a0,a0,1160 # ffffffffc0202110 <commands+0x968>
ffffffffc0200c90:	c22ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("CHECK DONE!\n") ;
}
ffffffffc0200c94:	7402                	ld	s0,32(sp)
ffffffffc0200c96:	70a2                	ld	ra,40(sp)
ffffffffc0200c98:	64e2                	ld	s1,24(sp)
ffffffffc0200c9a:	6942                	ld	s2,16(sp)
ffffffffc0200c9c:	69a2                	ld	s3,8(sp)
ffffffffc0200c9e:	6a02                	ld	s4,0(sp)
    cprintf("CHECK DONE!\n") ;
ffffffffc0200ca0:	00001517          	auipc	a0,0x1
ffffffffc0200ca4:	48050513          	addi	a0,a0,1152 # ffffffffc0202120 <commands+0x978>
}
ffffffffc0200ca8:	6145                	addi	sp,sp,48
    cprintf("CHECK DONE!\n") ;
ffffffffc0200caa:	c08ff06f          	j	ffffffffc02000b2 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cae:	00001697          	auipc	a3,0x1
ffffffffc0200cb2:	30268693          	addi	a3,a3,770 # ffffffffc0201fb0 <commands+0x808>
ffffffffc0200cb6:	00001617          	auipc	a2,0x1
ffffffffc0200cba:	01a60613          	addi	a2,a2,26 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200cbe:	0d100593          	li	a1,209
ffffffffc0200cc2:	00001517          	auipc	a0,0x1
ffffffffc0200cc6:	02650513          	addi	a0,a0,38 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200cca:	ee2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cce:	00001697          	auipc	a3,0x1
ffffffffc0200cd2:	32268693          	addi	a3,a3,802 # ffffffffc0201ff0 <commands+0x848>
ffffffffc0200cd6:	00001617          	auipc	a2,0x1
ffffffffc0200cda:	ffa60613          	addi	a2,a2,-6 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200cde:	0d300593          	li	a1,211
ffffffffc0200ce2:	00001517          	auipc	a0,0x1
ffffffffc0200ce6:	00650513          	addi	a0,a0,6 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200cea:	ec2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cee:	00001697          	auipc	a3,0x1
ffffffffc0200cf2:	2e268693          	addi	a3,a3,738 # ffffffffc0201fd0 <commands+0x828>
ffffffffc0200cf6:	00001617          	auipc	a2,0x1
ffffffffc0200cfa:	fda60613          	addi	a2,a2,-38 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200cfe:	0d200593          	li	a1,210
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	fe650513          	addi	a0,a0,-26 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200d0a:	ea2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d0e <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d0e:	1141                	addi	sp,sp,-16
ffffffffc0200d10:	e406                	sd	ra,8(sp)
ffffffffc0200d12:	4785                	li	a5,1
    assert(n > 0);
ffffffffc0200d14:	c9cd                	beqz	a1,ffffffffc0200dc6 <buddy_init_memmap+0xb8>
    for(;size<=n;size*=2);
ffffffffc0200d16:	0786                	slli	a5,a5,0x1
ffffffffc0200d18:	fef5ffe3          	bgeu	a1,a5,ffffffffc0200d16 <buddy_init_memmap+0x8>
    for (; p != base + n; p ++) {
ffffffffc0200d1c:	00259693          	slli	a3,a1,0x2
ffffffffc0200d20:	96ae                	add	a3,a3,a1
    size=ChangeToPow2(n);
ffffffffc0200d22:	00028617          	auipc	a2,0x28
ffffffffc0200d26:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0228720 <size>
    return size/2;
ffffffffc0200d2a:	8385                	srli	a5,a5,0x1
    for (; p != base + n; p ++) {
ffffffffc0200d2c:	068e                	slli	a3,a3,0x3
    size=ChangeToPow2(n);
ffffffffc0200d2e:	e21c                	sd	a5,0(a2)
    for (; p != base + n; p ++) {
ffffffffc0200d30:	96aa                	add	a3,a3,a0
ffffffffc0200d32:	02d50063          	beq	a0,a3,ffffffffc0200d52 <buddy_init_memmap+0x44>
ffffffffc0200d36:	87aa                	mv	a5,a0
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d38:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d3a:	8b05                	andi	a4,a4,1
ffffffffc0200d3c:	c72d                	beqz	a4,ffffffffc0200da6 <buddy_init_memmap+0x98>
        p->flags = p->property = 0;
ffffffffc0200d3e:	0007a823          	sw	zero,16(a5)
ffffffffc0200d42:	0007b423          	sd	zero,8(a5)
ffffffffc0200d46:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200d4a:	02878793          	addi	a5,a5,40
ffffffffc0200d4e:	fed795e3          	bne	a5,a3,ffffffffc0200d38 <buddy_init_memmap+0x2a>
    base->property = n;
ffffffffc0200d52:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d54:	4789                	li	a5,2
ffffffffc0200d56:	00850713          	addi	a4,a0,8
ffffffffc0200d5a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free=size;
ffffffffc0200d5e:	620c                	ld	a1,0(a2)
    self->size = size;
ffffffffc0200d60:	00005797          	auipc	a5,0x5
ffffffffc0200d64:	2a07b783          	ld	a5,672(a5) # ffffffffc0206000 <self>
ffffffffc0200d68:	00478693          	addi	a3,a5,4
ffffffffc0200d6c:	0005871b          	sext.w	a4,a1
    nr_free=size;
ffffffffc0200d70:	00028617          	auipc	a2,0x28
ffffffffc0200d74:	9ab63423          	sd	a1,-1624(a2) # ffffffffc0228718 <nr_free>
    for (size_t i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200d78:	0586                	slli	a1,a1,0x1
    self->size = size;
ffffffffc0200d7a:	c398                	sw	a4,0(a5)
    node_size = size * 2;
ffffffffc0200d7c:	0017161b          	slliw	a2,a4,0x1
    for (size_t i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200d80:	15fd                	addi	a1,a1,-1
ffffffffc0200d82:	4781                	li	a5,0
        if (IS_POWER_OF_2(i+1))
ffffffffc0200d84:	873e                	mv	a4,a5
ffffffffc0200d86:	0785                	addi	a5,a5,1
ffffffffc0200d88:	8f7d                	and	a4,a4,a5
ffffffffc0200d8a:	e319                	bnez	a4,ffffffffc0200d90 <buddy_init_memmap+0x82>
        node_size /= 2;
ffffffffc0200d8c:	0016561b          	srliw	a2,a2,0x1
        self->longest[i] = node_size;
ffffffffc0200d90:	c290                	sw	a2,0(a3)
    for (size_t i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200d92:	0691                	addi	a3,a3,4
ffffffffc0200d94:	feb798e3          	bne	a5,a1,ffffffffc0200d84 <buddy_init_memmap+0x76>
}
ffffffffc0200d98:	60a2                	ld	ra,8(sp)
    buddy_base=base;
ffffffffc0200d9a:	00028797          	auipc	a5,0x28
ffffffffc0200d9e:	96a7bb23          	sd	a0,-1674(a5) # ffffffffc0228710 <buddy_base>
}
ffffffffc0200da2:	0141                	addi	sp,sp,16
ffffffffc0200da4:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200da6:	00001697          	auipc	a3,0x1
ffffffffc0200daa:	39268693          	addi	a3,a3,914 # ffffffffc0202138 <commands+0x990>
ffffffffc0200dae:	00001617          	auipc	a2,0x1
ffffffffc0200db2:	f2260613          	addi	a2,a2,-222 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200db6:	02d00593          	li	a1,45
ffffffffc0200dba:	00001517          	auipc	a0,0x1
ffffffffc0200dbe:	f2e50513          	addi	a0,a0,-210 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200dc2:	deaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200dc6:	00001697          	auipc	a3,0x1
ffffffffc0200dca:	36a68693          	addi	a3,a3,874 # ffffffffc0202130 <commands+0x988>
ffffffffc0200dce:	00001617          	auipc	a2,0x1
ffffffffc0200dd2:	f0260613          	addi	a2,a2,-254 # ffffffffc0201cd0 <commands+0x528>
ffffffffc0200dd6:	02700593          	li	a1,39
ffffffffc0200dda:	00001517          	auipc	a0,0x1
ffffffffc0200dde:	f0e50513          	addi	a0,a0,-242 # ffffffffc0201ce8 <commands+0x540>
ffffffffc0200de2:	dcaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200de6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200de6:	100027f3          	csrr	a5,sstatus
ffffffffc0200dea:	8b89                	andi	a5,a5,2
ffffffffc0200dec:	e799                	bnez	a5,ffffffffc0200dfa <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200dee:	00028797          	auipc	a5,0x28
ffffffffc0200df2:	94a7b783          	ld	a5,-1718(a5) # ffffffffc0228738 <pmm_manager>
ffffffffc0200df6:	6f9c                	ld	a5,24(a5)
ffffffffc0200df8:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200dfa:	1141                	addi	sp,sp,-16
ffffffffc0200dfc:	e406                	sd	ra,8(sp)
ffffffffc0200dfe:	e022                	sd	s0,0(sp)
ffffffffc0200e00:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e02:	e5cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e06:	00028797          	auipc	a5,0x28
ffffffffc0200e0a:	9327b783          	ld	a5,-1742(a5) # ffffffffc0228738 <pmm_manager>
ffffffffc0200e0e:	6f9c                	ld	a5,24(a5)
ffffffffc0200e10:	8522                	mv	a0,s0
ffffffffc0200e12:	9782                	jalr	a5
ffffffffc0200e14:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e16:	e42ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e1a:	60a2                	ld	ra,8(sp)
ffffffffc0200e1c:	8522                	mv	a0,s0
ffffffffc0200e1e:	6402                	ld	s0,0(sp)
ffffffffc0200e20:	0141                	addi	sp,sp,16
ffffffffc0200e22:	8082                	ret

ffffffffc0200e24 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e24:	100027f3          	csrr	a5,sstatus
ffffffffc0200e28:	8b89                	andi	a5,a5,2
ffffffffc0200e2a:	e799                	bnez	a5,ffffffffc0200e38 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e2c:	00028797          	auipc	a5,0x28
ffffffffc0200e30:	90c7b783          	ld	a5,-1780(a5) # ffffffffc0228738 <pmm_manager>
ffffffffc0200e34:	739c                	ld	a5,32(a5)
ffffffffc0200e36:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e38:	1101                	addi	sp,sp,-32
ffffffffc0200e3a:	ec06                	sd	ra,24(sp)
ffffffffc0200e3c:	e822                	sd	s0,16(sp)
ffffffffc0200e3e:	e426                	sd	s1,8(sp)
ffffffffc0200e40:	842a                	mv	s0,a0
ffffffffc0200e42:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e44:	e1aff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e48:	00028797          	auipc	a5,0x28
ffffffffc0200e4c:	8f07b783          	ld	a5,-1808(a5) # ffffffffc0228738 <pmm_manager>
ffffffffc0200e50:	739c                	ld	a5,32(a5)
ffffffffc0200e52:	85a6                	mv	a1,s1
ffffffffc0200e54:	8522                	mv	a0,s0
ffffffffc0200e56:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e58:	6442                	ld	s0,16(sp)
ffffffffc0200e5a:	60e2                	ld	ra,24(sp)
ffffffffc0200e5c:	64a2                	ld	s1,8(sp)
ffffffffc0200e5e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e60:	df8ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200e64 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e64:	00001797          	auipc	a5,0x1
ffffffffc0200e68:	2fc78793          	addi	a5,a5,764 # ffffffffc0202160 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e6c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e6e:	1101                	addi	sp,sp,-32
ffffffffc0200e70:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	32650513          	addi	a0,a0,806 # ffffffffc0202198 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e7a:	00028497          	auipc	s1,0x28
ffffffffc0200e7e:	8be48493          	addi	s1,s1,-1858 # ffffffffc0228738 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e82:	ec06                	sd	ra,24(sp)
ffffffffc0200e84:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200e86:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e88:	a2aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200e8c:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e8e:	00028417          	auipc	s0,0x28
ffffffffc0200e92:	8c240413          	addi	s0,s0,-1854 # ffffffffc0228750 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200e96:	679c                	ld	a5,8(a5)
ffffffffc0200e98:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e9a:	57f5                	li	a5,-3
ffffffffc0200e9c:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200e9e:	00001517          	auipc	a0,0x1
ffffffffc0200ea2:	31250513          	addi	a0,a0,786 # ffffffffc02021b0 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ea6:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200ea8:	a0aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200eac:	46c5                	li	a3,17
ffffffffc0200eae:	06ee                	slli	a3,a3,0x1b
ffffffffc0200eb0:	40100613          	li	a2,1025
ffffffffc0200eb4:	16fd                	addi	a3,a3,-1
ffffffffc0200eb6:	07e005b7          	lui	a1,0x7e00
ffffffffc0200eba:	0656                	slli	a2,a2,0x15
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	30c50513          	addi	a0,a0,780 # ffffffffc02021c8 <buddy_pmm_manager+0x68>
ffffffffc0200ec4:	9eeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ec8:	777d                	lui	a4,0xfffff
ffffffffc0200eca:	00029797          	auipc	a5,0x29
ffffffffc0200ece:	89578793          	addi	a5,a5,-1899 # ffffffffc022975f <end+0xfff>
ffffffffc0200ed2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ed4:	00028517          	auipc	a0,0x28
ffffffffc0200ed8:	85450513          	addi	a0,a0,-1964 # ffffffffc0228728 <npage>
ffffffffc0200edc:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ee0:	00028597          	auipc	a1,0x28
ffffffffc0200ee4:	85058593          	addi	a1,a1,-1968 # ffffffffc0228730 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200ee8:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eea:	e19c                	sd	a5,0(a1)
ffffffffc0200eec:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200eee:	4701                	li	a4,0
ffffffffc0200ef0:	4885                	li	a7,1
ffffffffc0200ef2:	fff80837          	lui	a6,0xfff80
ffffffffc0200ef6:	a011                	j	ffffffffc0200efa <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200ef8:	619c                	ld	a5,0(a1)
ffffffffc0200efa:	97b6                	add	a5,a5,a3
ffffffffc0200efc:	07a1                	addi	a5,a5,8
ffffffffc0200efe:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f02:	611c                	ld	a5,0(a0)
ffffffffc0200f04:	0705                	addi	a4,a4,1
ffffffffc0200f06:	02868693          	addi	a3,a3,40
ffffffffc0200f0a:	01078633          	add	a2,a5,a6
ffffffffc0200f0e:	fec765e3          	bltu	a4,a2,ffffffffc0200ef8 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f12:	6190                	ld	a2,0(a1)
ffffffffc0200f14:	00279713          	slli	a4,a5,0x2
ffffffffc0200f18:	973e                	add	a4,a4,a5
ffffffffc0200f1a:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f1e:	070e                	slli	a4,a4,0x3
ffffffffc0200f20:	96b2                	add	a3,a3,a2
ffffffffc0200f22:	96ba                	add	a3,a3,a4
ffffffffc0200f24:	c0200737          	lui	a4,0xc0200
ffffffffc0200f28:	08e6ef63          	bltu	a3,a4,ffffffffc0200fc6 <pmm_init+0x162>
ffffffffc0200f2c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f2e:	45c5                	li	a1,17
ffffffffc0200f30:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f32:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f34:	04b6e863          	bltu	a3,a1,ffffffffc0200f84 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f38:	609c                	ld	a5,0(s1)
ffffffffc0200f3a:	7b9c                	ld	a5,48(a5)
ffffffffc0200f3c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f3e:	00001517          	auipc	a0,0x1
ffffffffc0200f42:	32250513          	addi	a0,a0,802 # ffffffffc0202260 <buddy_pmm_manager+0x100>
ffffffffc0200f46:	96cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f4a:	00004597          	auipc	a1,0x4
ffffffffc0200f4e:	0b658593          	addi	a1,a1,182 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f52:	00027797          	auipc	a5,0x27
ffffffffc0200f56:	7eb7bb23          	sd	a1,2038(a5) # ffffffffc0228748 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f5a:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f5e:	08f5e063          	bltu	a1,a5,ffffffffc0200fde <pmm_init+0x17a>
ffffffffc0200f62:	6010                	ld	a2,0(s0)
}
ffffffffc0200f64:	6442                	ld	s0,16(sp)
ffffffffc0200f66:	60e2                	ld	ra,24(sp)
ffffffffc0200f68:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f6a:	40c58633          	sub	a2,a1,a2
ffffffffc0200f6e:	00027797          	auipc	a5,0x27
ffffffffc0200f72:	7cc7b923          	sd	a2,2002(a5) # ffffffffc0228740 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	30a50513          	addi	a0,a0,778 # ffffffffc0202280 <buddy_pmm_manager+0x120>
}
ffffffffc0200f7e:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f80:	932ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f84:	6705                	lui	a4,0x1
ffffffffc0200f86:	177d                	addi	a4,a4,-1
ffffffffc0200f88:	96ba                	add	a3,a3,a4
ffffffffc0200f8a:	777d                	lui	a4,0xfffff
ffffffffc0200f8c:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f8e:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200f92:	00f57e63          	bgeu	a0,a5,ffffffffc0200fae <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f96:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f98:	982a                	add	a6,a6,a0
ffffffffc0200f9a:	00281513          	slli	a0,a6,0x2
ffffffffc0200f9e:	9542                	add	a0,a0,a6
ffffffffc0200fa0:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200fa2:	8d95                	sub	a1,a1,a3
ffffffffc0200fa4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200fa6:	81b1                	srli	a1,a1,0xc
ffffffffc0200fa8:	9532                	add	a0,a0,a2
ffffffffc0200faa:	9782                	jalr	a5
}
ffffffffc0200fac:	b771                	j	ffffffffc0200f38 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200fae:	00001617          	auipc	a2,0x1
ffffffffc0200fb2:	28260613          	addi	a2,a2,642 # ffffffffc0202230 <buddy_pmm_manager+0xd0>
ffffffffc0200fb6:	06b00593          	li	a1,107
ffffffffc0200fba:	00001517          	auipc	a0,0x1
ffffffffc0200fbe:	29650513          	addi	a0,a0,662 # ffffffffc0202250 <buddy_pmm_manager+0xf0>
ffffffffc0200fc2:	beaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fc6:	00001617          	auipc	a2,0x1
ffffffffc0200fca:	23260613          	addi	a2,a2,562 # ffffffffc02021f8 <buddy_pmm_manager+0x98>
ffffffffc0200fce:	08900593          	li	a1,137
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	24e50513          	addi	a0,a0,590 # ffffffffc0202220 <buddy_pmm_manager+0xc0>
ffffffffc0200fda:	bd2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fde:	86ae                	mv	a3,a1
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	21860613          	addi	a2,a2,536 # ffffffffc02021f8 <buddy_pmm_manager+0x98>
ffffffffc0200fe8:	0a400593          	li	a1,164
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	23450513          	addi	a0,a0,564 # ffffffffc0202220 <buddy_pmm_manager+0xc0>
ffffffffc0200ff4:	bb8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ff8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200ff8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ffc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200ffe:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201002:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201004:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201008:	f022                	sd	s0,32(sp)
ffffffffc020100a:	ec26                	sd	s1,24(sp)
ffffffffc020100c:	e84a                	sd	s2,16(sp)
ffffffffc020100e:	f406                	sd	ra,40(sp)
ffffffffc0201010:	e44e                	sd	s3,8(sp)
ffffffffc0201012:	84aa                	mv	s1,a0
ffffffffc0201014:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201016:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020101a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020101c:	03067e63          	bgeu	a2,a6,ffffffffc0201058 <printnum+0x60>
ffffffffc0201020:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201022:	00805763          	blez	s0,ffffffffc0201030 <printnum+0x38>
ffffffffc0201026:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201028:	85ca                	mv	a1,s2
ffffffffc020102a:	854e                	mv	a0,s3
ffffffffc020102c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020102e:	fc65                	bnez	s0,ffffffffc0201026 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201030:	1a02                	slli	s4,s4,0x20
ffffffffc0201032:	00001797          	auipc	a5,0x1
ffffffffc0201036:	28e78793          	addi	a5,a5,654 # ffffffffc02022c0 <buddy_pmm_manager+0x160>
ffffffffc020103a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020103e:	9a3e                	add	s4,s4,a5
}
ffffffffc0201040:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201042:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201046:	70a2                	ld	ra,40(sp)
ffffffffc0201048:	69a2                	ld	s3,8(sp)
ffffffffc020104a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020104c:	85ca                	mv	a1,s2
ffffffffc020104e:	87a6                	mv	a5,s1
}
ffffffffc0201050:	6942                	ld	s2,16(sp)
ffffffffc0201052:	64e2                	ld	s1,24(sp)
ffffffffc0201054:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201056:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201058:	03065633          	divu	a2,a2,a6
ffffffffc020105c:	8722                	mv	a4,s0
ffffffffc020105e:	f9bff0ef          	jal	ra,ffffffffc0200ff8 <printnum>
ffffffffc0201062:	b7f9                	j	ffffffffc0201030 <printnum+0x38>

ffffffffc0201064 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201064:	7119                	addi	sp,sp,-128
ffffffffc0201066:	f4a6                	sd	s1,104(sp)
ffffffffc0201068:	f0ca                	sd	s2,96(sp)
ffffffffc020106a:	ecce                	sd	s3,88(sp)
ffffffffc020106c:	e8d2                	sd	s4,80(sp)
ffffffffc020106e:	e4d6                	sd	s5,72(sp)
ffffffffc0201070:	e0da                	sd	s6,64(sp)
ffffffffc0201072:	fc5e                	sd	s7,56(sp)
ffffffffc0201074:	f06a                	sd	s10,32(sp)
ffffffffc0201076:	fc86                	sd	ra,120(sp)
ffffffffc0201078:	f8a2                	sd	s0,112(sp)
ffffffffc020107a:	f862                	sd	s8,48(sp)
ffffffffc020107c:	f466                	sd	s9,40(sp)
ffffffffc020107e:	ec6e                	sd	s11,24(sp)
ffffffffc0201080:	892a                	mv	s2,a0
ffffffffc0201082:	84ae                	mv	s1,a1
ffffffffc0201084:	8d32                	mv	s10,a2
ffffffffc0201086:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201088:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020108c:	5b7d                	li	s6,-1
ffffffffc020108e:	00001a97          	auipc	s5,0x1
ffffffffc0201092:	266a8a93          	addi	s5,s5,614 # ffffffffc02022f4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201096:	00001b97          	auipc	s7,0x1
ffffffffc020109a:	43ab8b93          	addi	s7,s7,1082 # ffffffffc02024d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020109e:	000d4503          	lbu	a0,0(s10)
ffffffffc02010a2:	001d0413          	addi	s0,s10,1
ffffffffc02010a6:	01350a63          	beq	a0,s3,ffffffffc02010ba <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010aa:	c121                	beqz	a0,ffffffffc02010ea <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010ac:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010ae:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010b0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010b2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010b6:	ff351ae3          	bne	a0,s3,ffffffffc02010aa <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ba:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010be:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010c2:	4c81                	li	s9,0
ffffffffc02010c4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010c6:	5c7d                	li	s8,-1
ffffffffc02010c8:	5dfd                	li	s11,-1
ffffffffc02010ca:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02010ce:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010d0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02010d4:	0ff5f593          	zext.b	a1,a1
ffffffffc02010d8:	00140d13          	addi	s10,s0,1
ffffffffc02010dc:	04b56263          	bltu	a0,a1,ffffffffc0201120 <vprintfmt+0xbc>
ffffffffc02010e0:	058a                	slli	a1,a1,0x2
ffffffffc02010e2:	95d6                	add	a1,a1,s5
ffffffffc02010e4:	4194                	lw	a3,0(a1)
ffffffffc02010e6:	96d6                	add	a3,a3,s5
ffffffffc02010e8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02010ea:	70e6                	ld	ra,120(sp)
ffffffffc02010ec:	7446                	ld	s0,112(sp)
ffffffffc02010ee:	74a6                	ld	s1,104(sp)
ffffffffc02010f0:	7906                	ld	s2,96(sp)
ffffffffc02010f2:	69e6                	ld	s3,88(sp)
ffffffffc02010f4:	6a46                	ld	s4,80(sp)
ffffffffc02010f6:	6aa6                	ld	s5,72(sp)
ffffffffc02010f8:	6b06                	ld	s6,64(sp)
ffffffffc02010fa:	7be2                	ld	s7,56(sp)
ffffffffc02010fc:	7c42                	ld	s8,48(sp)
ffffffffc02010fe:	7ca2                	ld	s9,40(sp)
ffffffffc0201100:	7d02                	ld	s10,32(sp)
ffffffffc0201102:	6de2                	ld	s11,24(sp)
ffffffffc0201104:	6109                	addi	sp,sp,128
ffffffffc0201106:	8082                	ret
            padc = '0';
ffffffffc0201108:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020110a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020110e:	846a                	mv	s0,s10
ffffffffc0201110:	00140d13          	addi	s10,s0,1
ffffffffc0201114:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201118:	0ff5f593          	zext.b	a1,a1
ffffffffc020111c:	fcb572e3          	bgeu	a0,a1,ffffffffc02010e0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201120:	85a6                	mv	a1,s1
ffffffffc0201122:	02500513          	li	a0,37
ffffffffc0201126:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201128:	fff44783          	lbu	a5,-1(s0)
ffffffffc020112c:	8d22                	mv	s10,s0
ffffffffc020112e:	f73788e3          	beq	a5,s3,ffffffffc020109e <vprintfmt+0x3a>
ffffffffc0201132:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201136:	1d7d                	addi	s10,s10,-1
ffffffffc0201138:	ff379de3          	bne	a5,s3,ffffffffc0201132 <vprintfmt+0xce>
ffffffffc020113c:	b78d                	j	ffffffffc020109e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020113e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201142:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201146:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201148:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020114c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201150:	02d86463          	bltu	a6,a3,ffffffffc0201178 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201154:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201158:	002c169b          	slliw	a3,s8,0x2
ffffffffc020115c:	0186873b          	addw	a4,a3,s8
ffffffffc0201160:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201164:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201166:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020116a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020116c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201170:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201174:	fed870e3          	bgeu	a6,a3,ffffffffc0201154 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201178:	f40ddce3          	bgez	s11,ffffffffc02010d0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020117c:	8de2                	mv	s11,s8
ffffffffc020117e:	5c7d                	li	s8,-1
ffffffffc0201180:	bf81                	j	ffffffffc02010d0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201182:	fffdc693          	not	a3,s11
ffffffffc0201186:	96fd                	srai	a3,a3,0x3f
ffffffffc0201188:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020118c:	00144603          	lbu	a2,1(s0)
ffffffffc0201190:	2d81                	sext.w	s11,s11
ffffffffc0201192:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201194:	bf35                	j	ffffffffc02010d0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201196:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020119e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011a2:	bfd9                	j	ffffffffc0201178 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011aa:	01174463          	blt	a4,a7,ffffffffc02011b2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011ae:	1a088e63          	beqz	a7,ffffffffc020136a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011b2:	000a3603          	ld	a2,0(s4)
ffffffffc02011b6:	46c1                	li	a3,16
ffffffffc02011b8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011ba:	2781                	sext.w	a5,a5
ffffffffc02011bc:	876e                	mv	a4,s11
ffffffffc02011be:	85a6                	mv	a1,s1
ffffffffc02011c0:	854a                	mv	a0,s2
ffffffffc02011c2:	e37ff0ef          	jal	ra,ffffffffc0200ff8 <printnum>
            break;
ffffffffc02011c6:	bde1                	j	ffffffffc020109e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011c8:	000a2503          	lw	a0,0(s4)
ffffffffc02011cc:	85a6                	mv	a1,s1
ffffffffc02011ce:	0a21                	addi	s4,s4,8
ffffffffc02011d0:	9902                	jalr	s2
            break;
ffffffffc02011d2:	b5f1                	j	ffffffffc020109e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011d6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011da:	01174463          	blt	a4,a7,ffffffffc02011e2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02011de:	18088163          	beqz	a7,ffffffffc0201360 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02011e2:	000a3603          	ld	a2,0(s4)
ffffffffc02011e6:	46a9                	li	a3,10
ffffffffc02011e8:	8a2e                	mv	s4,a1
ffffffffc02011ea:	bfc1                	j	ffffffffc02011ba <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ec:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02011f0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011f2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011f4:	bdf1                	j	ffffffffc02010d0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02011f6:	85a6                	mv	a1,s1
ffffffffc02011f8:	02500513          	li	a0,37
ffffffffc02011fc:	9902                	jalr	s2
            break;
ffffffffc02011fe:	b545                	j	ffffffffc020109e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201200:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201204:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201206:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201208:	b5e1                	j	ffffffffc02010d0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020120a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020120c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201210:	01174463          	blt	a4,a7,ffffffffc0201218 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201214:	14088163          	beqz	a7,ffffffffc0201356 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201218:	000a3603          	ld	a2,0(s4)
ffffffffc020121c:	46a1                	li	a3,8
ffffffffc020121e:	8a2e                	mv	s4,a1
ffffffffc0201220:	bf69                	j	ffffffffc02011ba <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201222:	03000513          	li	a0,48
ffffffffc0201226:	85a6                	mv	a1,s1
ffffffffc0201228:	e03e                	sd	a5,0(sp)
ffffffffc020122a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020122c:	85a6                	mv	a1,s1
ffffffffc020122e:	07800513          	li	a0,120
ffffffffc0201232:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201234:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201236:	6782                	ld	a5,0(sp)
ffffffffc0201238:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020123a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020123e:	bfb5                	j	ffffffffc02011ba <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201240:	000a3403          	ld	s0,0(s4)
ffffffffc0201244:	008a0713          	addi	a4,s4,8
ffffffffc0201248:	e03a                	sd	a4,0(sp)
ffffffffc020124a:	14040263          	beqz	s0,ffffffffc020138e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020124e:	0fb05763          	blez	s11,ffffffffc020133c <vprintfmt+0x2d8>
ffffffffc0201252:	02d00693          	li	a3,45
ffffffffc0201256:	0cd79163          	bne	a5,a3,ffffffffc0201318 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020125a:	00044783          	lbu	a5,0(s0)
ffffffffc020125e:	0007851b          	sext.w	a0,a5
ffffffffc0201262:	cf85                	beqz	a5,ffffffffc020129a <vprintfmt+0x236>
ffffffffc0201264:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201268:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020126c:	000c4563          	bltz	s8,ffffffffc0201276 <vprintfmt+0x212>
ffffffffc0201270:	3c7d                	addiw	s8,s8,-1
ffffffffc0201272:	036c0263          	beq	s8,s6,ffffffffc0201296 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201276:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201278:	0e0c8e63          	beqz	s9,ffffffffc0201374 <vprintfmt+0x310>
ffffffffc020127c:	3781                	addiw	a5,a5,-32
ffffffffc020127e:	0ef47b63          	bgeu	s0,a5,ffffffffc0201374 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201282:	03f00513          	li	a0,63
ffffffffc0201286:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201288:	000a4783          	lbu	a5,0(s4)
ffffffffc020128c:	3dfd                	addiw	s11,s11,-1
ffffffffc020128e:	0a05                	addi	s4,s4,1
ffffffffc0201290:	0007851b          	sext.w	a0,a5
ffffffffc0201294:	ffe1                	bnez	a5,ffffffffc020126c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201296:	01b05963          	blez	s11,ffffffffc02012a8 <vprintfmt+0x244>
ffffffffc020129a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020129c:	85a6                	mv	a1,s1
ffffffffc020129e:	02000513          	li	a0,32
ffffffffc02012a2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012a4:	fe0d9be3          	bnez	s11,ffffffffc020129a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012a8:	6a02                	ld	s4,0(sp)
ffffffffc02012aa:	bbd5                	j	ffffffffc020109e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012ae:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012b2:	01174463          	blt	a4,a7,ffffffffc02012ba <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012b6:	08088d63          	beqz	a7,ffffffffc0201350 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012ba:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012be:	0a044d63          	bltz	s0,ffffffffc0201378 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012c2:	8622                	mv	a2,s0
ffffffffc02012c4:	8a66                	mv	s4,s9
ffffffffc02012c6:	46a9                	li	a3,10
ffffffffc02012c8:	bdcd                	j	ffffffffc02011ba <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02012ca:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012ce:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02012d0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02012d2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02012d6:	8fb5                	xor	a5,a5,a3
ffffffffc02012d8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012dc:	02d74163          	blt	a4,a3,ffffffffc02012fe <vprintfmt+0x29a>
ffffffffc02012e0:	00369793          	slli	a5,a3,0x3
ffffffffc02012e4:	97de                	add	a5,a5,s7
ffffffffc02012e6:	639c                	ld	a5,0(a5)
ffffffffc02012e8:	cb99                	beqz	a5,ffffffffc02012fe <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02012ea:	86be                	mv	a3,a5
ffffffffc02012ec:	00001617          	auipc	a2,0x1
ffffffffc02012f0:	00460613          	addi	a2,a2,4 # ffffffffc02022f0 <buddy_pmm_manager+0x190>
ffffffffc02012f4:	85a6                	mv	a1,s1
ffffffffc02012f6:	854a                	mv	a0,s2
ffffffffc02012f8:	0ce000ef          	jal	ra,ffffffffc02013c6 <printfmt>
ffffffffc02012fc:	b34d                	j	ffffffffc020109e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02012fe:	00001617          	auipc	a2,0x1
ffffffffc0201302:	fe260613          	addi	a2,a2,-30 # ffffffffc02022e0 <buddy_pmm_manager+0x180>
ffffffffc0201306:	85a6                	mv	a1,s1
ffffffffc0201308:	854a                	mv	a0,s2
ffffffffc020130a:	0bc000ef          	jal	ra,ffffffffc02013c6 <printfmt>
ffffffffc020130e:	bb41                	j	ffffffffc020109e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201310:	00001417          	auipc	s0,0x1
ffffffffc0201314:	fc840413          	addi	s0,s0,-56 # ffffffffc02022d8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201318:	85e2                	mv	a1,s8
ffffffffc020131a:	8522                	mv	a0,s0
ffffffffc020131c:	e43e                	sd	a5,8(sp)
ffffffffc020131e:	1cc000ef          	jal	ra,ffffffffc02014ea <strnlen>
ffffffffc0201322:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201326:	01b05b63          	blez	s11,ffffffffc020133c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020132a:	67a2                	ld	a5,8(sp)
ffffffffc020132c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201330:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201332:	85a6                	mv	a1,s1
ffffffffc0201334:	8552                	mv	a0,s4
ffffffffc0201336:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201338:	fe0d9ce3          	bnez	s11,ffffffffc0201330 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020133c:	00044783          	lbu	a5,0(s0)
ffffffffc0201340:	00140a13          	addi	s4,s0,1
ffffffffc0201344:	0007851b          	sext.w	a0,a5
ffffffffc0201348:	d3a5                	beqz	a5,ffffffffc02012a8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020134a:	05e00413          	li	s0,94
ffffffffc020134e:	bf39                	j	ffffffffc020126c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201350:	000a2403          	lw	s0,0(s4)
ffffffffc0201354:	b7ad                	j	ffffffffc02012be <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201356:	000a6603          	lwu	a2,0(s4)
ffffffffc020135a:	46a1                	li	a3,8
ffffffffc020135c:	8a2e                	mv	s4,a1
ffffffffc020135e:	bdb1                	j	ffffffffc02011ba <vprintfmt+0x156>
ffffffffc0201360:	000a6603          	lwu	a2,0(s4)
ffffffffc0201364:	46a9                	li	a3,10
ffffffffc0201366:	8a2e                	mv	s4,a1
ffffffffc0201368:	bd89                	j	ffffffffc02011ba <vprintfmt+0x156>
ffffffffc020136a:	000a6603          	lwu	a2,0(s4)
ffffffffc020136e:	46c1                	li	a3,16
ffffffffc0201370:	8a2e                	mv	s4,a1
ffffffffc0201372:	b5a1                	j	ffffffffc02011ba <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201374:	9902                	jalr	s2
ffffffffc0201376:	bf09                	j	ffffffffc0201288 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201378:	85a6                	mv	a1,s1
ffffffffc020137a:	02d00513          	li	a0,45
ffffffffc020137e:	e03e                	sd	a5,0(sp)
ffffffffc0201380:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201382:	6782                	ld	a5,0(sp)
ffffffffc0201384:	8a66                	mv	s4,s9
ffffffffc0201386:	40800633          	neg	a2,s0
ffffffffc020138a:	46a9                	li	a3,10
ffffffffc020138c:	b53d                	j	ffffffffc02011ba <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020138e:	03b05163          	blez	s11,ffffffffc02013b0 <vprintfmt+0x34c>
ffffffffc0201392:	02d00693          	li	a3,45
ffffffffc0201396:	f6d79de3          	bne	a5,a3,ffffffffc0201310 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020139a:	00001417          	auipc	s0,0x1
ffffffffc020139e:	f3e40413          	addi	s0,s0,-194 # ffffffffc02022d8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013a2:	02800793          	li	a5,40
ffffffffc02013a6:	02800513          	li	a0,40
ffffffffc02013aa:	00140a13          	addi	s4,s0,1
ffffffffc02013ae:	bd6d                	j	ffffffffc0201268 <vprintfmt+0x204>
ffffffffc02013b0:	00001a17          	auipc	s4,0x1
ffffffffc02013b4:	f29a0a13          	addi	s4,s4,-215 # ffffffffc02022d9 <buddy_pmm_manager+0x179>
ffffffffc02013b8:	02800513          	li	a0,40
ffffffffc02013bc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013c0:	05e00413          	li	s0,94
ffffffffc02013c4:	b565                	j	ffffffffc020126c <vprintfmt+0x208>

ffffffffc02013c6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013c6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013c8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013cc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013ce:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013d0:	ec06                	sd	ra,24(sp)
ffffffffc02013d2:	f83a                	sd	a4,48(sp)
ffffffffc02013d4:	fc3e                	sd	a5,56(sp)
ffffffffc02013d6:	e0c2                	sd	a6,64(sp)
ffffffffc02013d8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02013da:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02013dc:	c89ff0ef          	jal	ra,ffffffffc0201064 <vprintfmt>
}
ffffffffc02013e0:	60e2                	ld	ra,24(sp)
ffffffffc02013e2:	6161                	addi	sp,sp,80
ffffffffc02013e4:	8082                	ret

ffffffffc02013e6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02013e6:	715d                	addi	sp,sp,-80
ffffffffc02013e8:	e486                	sd	ra,72(sp)
ffffffffc02013ea:	e0a6                	sd	s1,64(sp)
ffffffffc02013ec:	fc4a                	sd	s2,56(sp)
ffffffffc02013ee:	f84e                	sd	s3,48(sp)
ffffffffc02013f0:	f452                	sd	s4,40(sp)
ffffffffc02013f2:	f056                	sd	s5,32(sp)
ffffffffc02013f4:	ec5a                	sd	s6,24(sp)
ffffffffc02013f6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02013f8:	c901                	beqz	a0,ffffffffc0201408 <readline+0x22>
ffffffffc02013fa:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	ef450513          	addi	a0,a0,-268 # ffffffffc02022f0 <buddy_pmm_manager+0x190>
ffffffffc0201404:	caffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201408:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020140a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020140c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020140e:	4aa9                	li	s5,10
ffffffffc0201410:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201412:	00027b97          	auipc	s7,0x27
ffffffffc0201416:	eeeb8b93          	addi	s7,s7,-274 # ffffffffc0228300 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020141a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020141e:	d0dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201422:	00054a63          	bltz	a0,ffffffffc0201436 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201426:	00a95a63          	bge	s2,a0,ffffffffc020143a <readline+0x54>
ffffffffc020142a:	029a5263          	bge	s4,s1,ffffffffc020144e <readline+0x68>
        c = getchar();
ffffffffc020142e:	cfdfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201432:	fe055ae3          	bgez	a0,ffffffffc0201426 <readline+0x40>
            return NULL;
ffffffffc0201436:	4501                	li	a0,0
ffffffffc0201438:	a091                	j	ffffffffc020147c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020143a:	03351463          	bne	a0,s3,ffffffffc0201462 <readline+0x7c>
ffffffffc020143e:	e8a9                	bnez	s1,ffffffffc0201490 <readline+0xaa>
        c = getchar();
ffffffffc0201440:	cebfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201444:	fe0549e3          	bltz	a0,ffffffffc0201436 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201448:	fea959e3          	bge	s2,a0,ffffffffc020143a <readline+0x54>
ffffffffc020144c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020144e:	e42a                	sd	a0,8(sp)
ffffffffc0201450:	c99fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201454:	6522                	ld	a0,8(sp)
ffffffffc0201456:	009b87b3          	add	a5,s7,s1
ffffffffc020145a:	2485                	addiw	s1,s1,1
ffffffffc020145c:	00a78023          	sb	a0,0(a5)
ffffffffc0201460:	bf7d                	j	ffffffffc020141e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201462:	01550463          	beq	a0,s5,ffffffffc020146a <readline+0x84>
ffffffffc0201466:	fb651ce3          	bne	a0,s6,ffffffffc020141e <readline+0x38>
            cputchar(c);
ffffffffc020146a:	c7ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020146e:	00027517          	auipc	a0,0x27
ffffffffc0201472:	e9250513          	addi	a0,a0,-366 # ffffffffc0228300 <buf>
ffffffffc0201476:	94aa                	add	s1,s1,a0
ffffffffc0201478:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020147c:	60a6                	ld	ra,72(sp)
ffffffffc020147e:	6486                	ld	s1,64(sp)
ffffffffc0201480:	7962                	ld	s2,56(sp)
ffffffffc0201482:	79c2                	ld	s3,48(sp)
ffffffffc0201484:	7a22                	ld	s4,40(sp)
ffffffffc0201486:	7a82                	ld	s5,32(sp)
ffffffffc0201488:	6b62                	ld	s6,24(sp)
ffffffffc020148a:	6bc2                	ld	s7,16(sp)
ffffffffc020148c:	6161                	addi	sp,sp,80
ffffffffc020148e:	8082                	ret
            cputchar(c);
ffffffffc0201490:	4521                	li	a0,8
ffffffffc0201492:	c57fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201496:	34fd                	addiw	s1,s1,-1
ffffffffc0201498:	b759                	j	ffffffffc020141e <readline+0x38>

ffffffffc020149a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020149a:	4781                	li	a5,0
ffffffffc020149c:	00005717          	auipc	a4,0x5
ffffffffc02014a0:	b7473703          	ld	a4,-1164(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02014a4:	88ba                	mv	a7,a4
ffffffffc02014a6:	852a                	mv	a0,a0
ffffffffc02014a8:	85be                	mv	a1,a5
ffffffffc02014aa:	863e                	mv	a2,a5
ffffffffc02014ac:	00000073          	ecall
ffffffffc02014b0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02014b2:	8082                	ret

ffffffffc02014b4 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02014b4:	4781                	li	a5,0
ffffffffc02014b6:	00027717          	auipc	a4,0x27
ffffffffc02014ba:	2a273703          	ld	a4,674(a4) # ffffffffc0228758 <SBI_SET_TIMER>
ffffffffc02014be:	88ba                	mv	a7,a4
ffffffffc02014c0:	852a                	mv	a0,a0
ffffffffc02014c2:	85be                	mv	a1,a5
ffffffffc02014c4:	863e                	mv	a2,a5
ffffffffc02014c6:	00000073          	ecall
ffffffffc02014ca:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02014cc:	8082                	ret

ffffffffc02014ce <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02014ce:	4501                	li	a0,0
ffffffffc02014d0:	00005797          	auipc	a5,0x5
ffffffffc02014d4:	b387b783          	ld	a5,-1224(a5) # ffffffffc0206008 <SBI_CONSOLE_GETCHAR>
ffffffffc02014d8:	88be                	mv	a7,a5
ffffffffc02014da:	852a                	mv	a0,a0
ffffffffc02014dc:	85aa                	mv	a1,a0
ffffffffc02014de:	862a                	mv	a2,a0
ffffffffc02014e0:	00000073          	ecall
ffffffffc02014e4:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02014e6:	2501                	sext.w	a0,a0
ffffffffc02014e8:	8082                	ret

ffffffffc02014ea <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02014ea:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014ec:	e589                	bnez	a1,ffffffffc02014f6 <strnlen+0xc>
ffffffffc02014ee:	a811                	j	ffffffffc0201502 <strnlen+0x18>
        cnt ++;
ffffffffc02014f0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02014f2:	00f58863          	beq	a1,a5,ffffffffc0201502 <strnlen+0x18>
ffffffffc02014f6:	00f50733          	add	a4,a0,a5
ffffffffc02014fa:	00074703          	lbu	a4,0(a4)
ffffffffc02014fe:	fb6d                	bnez	a4,ffffffffc02014f0 <strnlen+0x6>
ffffffffc0201500:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201502:	852e                	mv	a0,a1
ffffffffc0201504:	8082                	ret

ffffffffc0201506 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201506:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020150a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020150e:	cb89                	beqz	a5,ffffffffc0201520 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201510:	0505                	addi	a0,a0,1
ffffffffc0201512:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201514:	fee789e3          	beq	a5,a4,ffffffffc0201506 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201518:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020151c:	9d19                	subw	a0,a0,a4
ffffffffc020151e:	8082                	ret
ffffffffc0201520:	4501                	li	a0,0
ffffffffc0201522:	bfed                	j	ffffffffc020151c <strcmp+0x16>

ffffffffc0201524 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201524:	00054783          	lbu	a5,0(a0)
ffffffffc0201528:	c799                	beqz	a5,ffffffffc0201536 <strchr+0x12>
        if (*s == c) {
ffffffffc020152a:	00f58763          	beq	a1,a5,ffffffffc0201538 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020152e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201532:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201534:	fbfd                	bnez	a5,ffffffffc020152a <strchr+0x6>
    }
    return NULL;
ffffffffc0201536:	4501                	li	a0,0
}
ffffffffc0201538:	8082                	ret

ffffffffc020153a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020153a:	ca01                	beqz	a2,ffffffffc020154a <memset+0x10>
ffffffffc020153c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020153e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201540:	0785                	addi	a5,a5,1
ffffffffc0201542:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201546:	fec79de3          	bne	a5,a2,ffffffffc0201540 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020154a:	8082                	ret
