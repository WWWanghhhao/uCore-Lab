
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
<<<<<<< HEAD
    80200022:	5c4000ef          	jal	ra,802005e6 <memset>

    cons_init();  // init the console
    80200026:	154000ef          	jal	ra,8020017a <cons_init>
=======
    80200022:	5b8000ef          	jal	ra,802005da <memset>

    cons_init();  // init the console
    80200026:	150000ef          	jal	ra,80200176 <cons_init>
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
<<<<<<< HEAD
    8020002e:	a0e58593          	addi	a1,a1,-1522 # 80200a38 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a2650513          	addi	a0,a0,-1498 # 80200a58 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>
=======
    8020002e:	9fe58593          	addi	a1,a1,-1538 # 80200a28 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a1650513          	addi	a0,a0,-1514 # 80200a48 <etext+0x20>
    8020003a:	036000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    8020003e:	068000ef          	jal	ra,802000a6 <print_kerninfo>
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
<<<<<<< HEAD
    80200042:	148000ef          	jal	ra,8020018a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	13a000ef          	jal	ra,80200184 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:
=======
    80200042:	144000ef          	jal	ra,80200186 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0ee000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	136000ef          	jal	ra,80200180 <intr_enable>
    
    __asm__ __volatile__("mret");   
    8020004e:	30200073          	mret
    __asm__ __volatile__("ebreak"); 
    80200052:	9002                	ebreak

    while (1)
    80200054:	a001                	j	80200054 <kern_init+0x4a>

0000000080200056 <cputch>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
<<<<<<< HEAD
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	124000ef          	jal	ra,8020017c <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
=======
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    cons_putc(c);
    8020005e:	11a000ef          	jal	ra,80200178 <cons_putc>
    (*cnt)++;
    80200062:	401c                	lw	a5,0(s0)
}
    80200064:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
}
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
<<<<<<< HEAD
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5d0000ef          	jal	ra,80200664 <vprintfmt>
=======
    80200070:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200076:	8e2a                	mv	t3,a0
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	00000517          	auipc	a0,0x0
    80200082:	fd850513          	addi	a0,a0,-40 # 80200056 <cputch>
    80200086:	004c                	addi	a1,sp,4
    80200088:	869a                	mv	a3,t1
    8020008a:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	5be000ef          	jal	ra,80200658 <vprintfmt>
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
<<<<<<< HEAD
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
=======
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
<<<<<<< HEAD
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9be50513          	addi	a0,a0,-1602 # 80200a60 <etext+0x2c>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9c850513          	addi	a0,a0,-1592 # 80200a80 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	97058593          	addi	a1,a1,-1680 # 80200a34 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9d450513          	addi	a0,a0,-1580 # 80200aa0 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9e050513          	addi	a0,a0,-1568 # 80200ac0 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9ec50513          	addi	a0,a0,-1556 # 80200ae0 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9de50513          	addi	a0,a0,-1570 # 80200b00 <etext+0xcc>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:
=======
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	9a850513          	addi	a0,a0,-1624 # 80200a50 <etext+0x28>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fbfff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5458593          	addi	a1,a1,-172 # 8020000a <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	9b250513          	addi	a0,a0,-1614 # 80200a70 <etext+0x48>
    802000c6:	fabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	95e58593          	addi	a1,a1,-1698 # 80200a28 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	9be50513          	addi	a0,a0,-1602 # 80200a90 <etext+0x68>
    802000da:	f97ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <ticks>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	9ca50513          	addi	a0,a0,-1590 # 80200ab0 <etext+0x88>
    802000ee:	f83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	9d650513          	addi	a0,a0,-1578 # 80200ad0 <etext+0xa8>
    80200102:	f6fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efc78793          	addi	a5,a5,-260 # 8020000a <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	9c850513          	addi	a0,a0,-1592 # 80200af0 <etext+0xc8>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	bf3d                	j	80200070 <cprintf>

0000000080200134 <clock_init>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
<<<<<<< HEAD
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    __asm__ volatile("nop");
=======
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200140:	c0102573          	rdtime	a0
    ticks = 0;
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
<<<<<<< HEAD
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	0bb000ef          	jal	ra,80200a00 <sbi_set_timer>
    ticks = 0;
    8020014a:	00004797          	auipc	a5,0x4
    8020014e:	ec07b323          	sd	zero,-314(a5) # 80204010 <ticks>
    __asm__ volatile("mret");
    80200152:	30200073          	mret
    __asm__ volatile("nop");
    80200156:	0001                	nop
    __asm__ volatile("ebreak");
    80200158:	9002                	ebreak
    __asm__ volatile("nop");
    8020015a:	0001                	nop
}
    8020015c:	60a2                	ld	ra,8(sp)
    cprintf("++ setup timer interrupts\n");
    8020015e:	00001517          	auipc	a0,0x1
    80200162:	9d250513          	addi	a0,a0,-1582 # 80200b30 <etext+0xfc>
}
    80200166:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200168:	b709                	j	8020006a <cprintf>

000000008020016a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	08b0006f          	j	80200a00 <sbi_set_timer>

000000008020017a <cons_init>:
=======
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	0a9000ef          	jal	ra,802009f4 <sbi_set_timer>
}
    80200150:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ea07bf23          	sd	zero,-322(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	9c650513          	addi	a0,a0,-1594 # 80200b20 <etext+0xf8>
}
    80200162:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200164:	b731                	j	80200070 <cprintf>

0000000080200166 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200166:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	0830006f          	j	802009f4 <sbi_set_timer>

0000000080200176 <cons_init>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
<<<<<<< HEAD
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	zext.b	a0,a0
    80200180:	0670006f          	j	802009e6 <sbi_console_putchar>

0000000080200184 <intr_enable>:
=======
    80200176:	8082                	ret

0000000080200178 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200178:	0ff57513          	zext.b	a0,a0
    8020017c:	05f0006f          	j	802009da <sbi_console_putchar>

0000000080200180 <intr_enable>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
<<<<<<< HEAD
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
  extern void __alltraps(void);
  /* Set sscratch register to 0, indicating to exception vector that we are
   * presently executing in the kernel */
  write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
  /* Set the exception vector address */
  write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	38678793          	addi	a5,a5,902 # 80200514 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
  cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
  cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
  cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
  cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	9ac50513          	addi	a0,a0,-1620 # 80200b50 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
  cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ebdff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	9b450513          	addi	a0,a0,-1612 # 80200b68 <etext+0x134>
    802001bc:	eafff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	9be50513          	addi	a0,a0,-1602 # 80200b80 <etext+0x14c>
    802001ca:	ea1ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	9c850513          	addi	a0,a0,-1592 # 80200b98 <etext+0x164>
    802001d8:	e93ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9d250513          	addi	a0,a0,-1582 # 80200bb0 <etext+0x17c>
    802001e6:	e85ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	9dc50513          	addi	a0,a0,-1572 # 80200bc8 <etext+0x194>
    802001f4:	e77ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	9e650513          	addi	a0,a0,-1562 # 80200be0 <etext+0x1ac>
    80200202:	e69ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	9f050513          	addi	a0,a0,-1552 # 80200bf8 <etext+0x1c4>
    80200210:	e5bff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	9fa50513          	addi	a0,a0,-1542 # 80200c10 <etext+0x1dc>
    8020021e:	e4dff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	a0450513          	addi	a0,a0,-1532 # 80200c28 <etext+0x1f4>
    8020022c:	e3fff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	a0e50513          	addi	a0,a0,-1522 # 80200c40 <etext+0x20c>
    8020023a:	e31ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	a1850513          	addi	a0,a0,-1512 # 80200c58 <etext+0x224>
    80200248:	e23ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	a2250513          	addi	a0,a0,-1502 # 80200c70 <etext+0x23c>
    80200256:	e15ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	a2c50513          	addi	a0,a0,-1492 # 80200c88 <etext+0x254>
    80200264:	e07ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	a3650513          	addi	a0,a0,-1482 # 80200ca0 <etext+0x26c>
    80200272:	df9ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	a4050513          	addi	a0,a0,-1472 # 80200cb8 <etext+0x284>
    80200280:	debff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	a4a50513          	addi	a0,a0,-1462 # 80200cd0 <etext+0x29c>
    8020028e:	dddff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	a5450513          	addi	a0,a0,-1452 # 80200ce8 <etext+0x2b4>
    8020029c:	dcfff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	a5e50513          	addi	a0,a0,-1442 # 80200d00 <etext+0x2cc>
    802002aa:	dc1ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	a6850513          	addi	a0,a0,-1432 # 80200d18 <etext+0x2e4>
    802002b8:	db3ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	a7250513          	addi	a0,a0,-1422 # 80200d30 <etext+0x2fc>
    802002c6:	da5ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	a7c50513          	addi	a0,a0,-1412 # 80200d48 <etext+0x314>
    802002d4:	d97ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a8650513          	addi	a0,a0,-1402 # 80200d60 <etext+0x32c>
    802002e2:	d89ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a9050513          	addi	a0,a0,-1392 # 80200d78 <etext+0x344>
    802002f0:	d7bff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a9a50513          	addi	a0,a0,-1382 # 80200d90 <etext+0x35c>
    802002fe:	d6dff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	aa450513          	addi	a0,a0,-1372 # 80200da8 <etext+0x374>
    8020030c:	d5fff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	aae50513          	addi	a0,a0,-1362 # 80200dc0 <etext+0x38c>
    8020031a:	d51ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	ab850513          	addi	a0,a0,-1352 # 80200dd8 <etext+0x3a4>
    80200328:	d43ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	ac250513          	addi	a0,a0,-1342 # 80200df0 <etext+0x3bc>
    80200336:	d35ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	acc50513          	addi	a0,a0,-1332 # 80200e08 <etext+0x3d4>
    80200344:	d27ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	ad650513          	addi	a0,a0,-1322 # 80200e20 <etext+0x3ec>
    80200352:	d19ff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
  cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	adc50513          	addi	a0,a0,-1316 # 80200e38 <etext+0x404>
}
    80200364:	0141                	addi	sp,sp,16
  cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	b311                	j	8020006a <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
  cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
  cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	ae050513          	addi	a0,a0,-1312 # 80200e50 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
  cprintf("trapframe at %p\n", tf);
    8020037a:	cf1ff0ef          	jal	ra,8020006a <cprintf>
  print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1dff0ef          	jal	ra,8020019c <print_regs>
  cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	ae050513          	addi	a0,a0,-1312 # 80200e68 <etext+0x434>
    80200390:	cdbff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	ae850513          	addi	a0,a0,-1304 # 80200e80 <etext+0x44c>
    802003a0:	ccbff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	af050513          	addi	a0,a0,-1296 # 80200e98 <etext+0x464>
    802003b0:	cbbff0ef          	jal	ra,8020006a <cprintf>
  cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
  cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	af450513          	addi	a0,a0,-1292 # 80200eb0 <etext+0x47c>
}
    802003c4:	0141                	addi	sp,sp,16
  cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	b155                	j	8020006a <cprintf>

00000000802003c8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
  intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	472d                	li	a4,11
    802003ce:	0786                	slli	a5,a5,0x1
    802003d0:	8385                	srli	a5,a5,0x1
    802003d2:	06f76863          	bltu	a4,a5,80200442 <interrupt_handler+0x7a>
    802003d6:	00001717          	auipc	a4,0x1
    802003da:	ba270713          	addi	a4,a4,-1118 # 80200f78 <etext+0x544>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
    break;
  case IRQ_H_SOFT:
    cprintf("Hypervisor software interrupt\n");
    break;
  case IRQ_M_SOFT:
    cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b4050513          	addi	a0,a0,-1216 # 80200f28 <etext+0x4f4>
    802003f0:	b9ad                	j	8020006a <cprintf>
    cprintf("Hypervisor software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	b1650513          	addi	a0,a0,-1258 # 80200f08 <etext+0x4d4>
    802003fa:	b985                	j	8020006a <cprintf>
    cprintf("User software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	acc50513          	addi	a0,a0,-1332 # 80200ec8 <etext+0x494>
    80200404:	b19d                	j	8020006a <cprintf>
    cprintf("Supervisor software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	ae250513          	addi	a0,a0,-1310 # 80200ee8 <etext+0x4b4>
    8020040e:	b9b1                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200410:	1141                	addi	sp,sp,-16
    80200412:	e406                	sd	ra,8(sp)
     *(2)计数器（ticks）加一
     *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
     * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
     */

    clock_set_next_event();
    80200414:	d57ff0ef          	jal	ra,8020016a <clock_set_next_event>
    ticks += 1;
    80200418:	00004797          	auipc	a5,0x4
    8020041c:	bf878793          	addi	a5,a5,-1032 # 80204010 <ticks>
    80200420:	6398                	ld	a4,0(a5)
    80200422:	0705                	addi	a4,a4,1
    80200424:	e398                	sd	a4,0(a5)
    if (ticks % TICK_NUM == 0) {
    80200426:	639c                	ld	a5,0(a5)
    80200428:	06400713          	li	a4,100
    8020042c:	02e7f7b3          	remu	a5,a5,a4
    80200430:	cb91                	beqz	a5,80200444 <interrupt_handler+0x7c>
    break;
  default:
    print_trapframe(tf);
    break;
  }
}
    80200432:	60a2                	ld	ra,8(sp)
    80200434:	0141                	addi	sp,sp,16
    80200436:	8082                	ret
    cprintf("Supervisor external interrupt\n");
    80200438:	00001517          	auipc	a0,0x1
    8020043c:	b2050513          	addi	a0,a0,-1248 # 80200f58 <etext+0x524>
    80200440:	b12d                	j	8020006a <cprintf>
    print_trapframe(tf);
    80200442:	b71d                	j	80200368 <print_trapframe>
  cprintf("%d ticks\n", TICK_NUM);
    80200444:	06400593          	li	a1,100
    80200448:	00001517          	auipc	a0,0x1
    8020044c:	b0050513          	addi	a0,a0,-1280 # 80200f48 <etext+0x514>
      ticks = 0;
    80200450:	00004797          	auipc	a5,0x4
    80200454:	bc07b023          	sd	zero,-1088(a5) # 80204010 <ticks>
  cprintf("%d ticks\n", TICK_NUM);
    80200458:	c13ff0ef          	jal	ra,8020006a <cprintf>
      num += 1;
    8020045c:	00004797          	auipc	a5,0x4
    80200460:	bbc78793          	addi	a5,a5,-1092 # 80204018 <num>
    80200464:	6398                	ld	a4,0(a5)
      if (num == 10) {
    80200466:	46a9                	li	a3,10
      num += 1;
    80200468:	0705                	addi	a4,a4,1
    8020046a:	e398                	sd	a4,0(a5)
      if (num == 10) {
    8020046c:	639c                	ld	a5,0(a5)
    8020046e:	fcd792e3          	bne	a5,a3,80200432 <interrupt_handler+0x6a>
}
    80200472:	60a2                	ld	ra,8(sp)
        num = 0;
    80200474:	00004797          	auipc	a5,0x4
    80200478:	ba07b223          	sd	zero,-1116(a5) # 80204018 <num>
}
    8020047c:	0141                	addi	sp,sp,16
        sbi_shutdown();
    8020047e:	ab71                	j	80200a1a <sbi_shutdown>

0000000080200480 <exception_handler>:

void exception_handler(struct trapframe *tf) {
  switch (tf->cause) {
    80200480:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200484:	1141                	addi	sp,sp,-16
    80200486:	e022                	sd	s0,0(sp)
    80200488:	e406                	sd	ra,8(sp)
  switch (tf->cause) {
    8020048a:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    8020048c:	842a                	mv	s0,a0
  switch (tf->cause) {
    8020048e:	04e78663          	beq	a5,a4,802004da <exception_handler+0x5a>
    80200492:	02f76c63          	bltu	a4,a5,802004ca <exception_handler+0x4a>
    80200496:	4709                	li	a4,2
    80200498:	02e79563          	bne	a5,a4,802004c2 <exception_handler+0x42>
    /* LAB1 CHALLENGE3   YOUR CODE :  */
    /*(1)输出指令异常类型（ Illegal instruction）
     *(2)输出异常指令地址
     *(3)更新 tf->epc寄存器
     */
    cprintf("Exception type:Illegal instruction\n");
    8020049c:	00001517          	auipc	a0,0x1
    802004a0:	b0c50513          	addi	a0,a0,-1268 # 80200fa8 <etext+0x574>
    802004a4:	bc7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Illegal instruction caught at 0x%d\n", tf->epc);
    802004a8:	10843583          	ld	a1,264(s0)
    802004ac:	00001517          	auipc	a0,0x1
    802004b0:	b2450513          	addi	a0,a0,-1244 # 80200fd0 <etext+0x59c>
    802004b4:	bb7ff0ef          	jal	ra,8020006a <cprintf>
    tf->epc += 4;
    802004b8:	10843783          	ld	a5,264(s0)
    802004bc:	0791                	addi	a5,a5,4
    802004be:	10f43423          	sd	a5,264(s0)
    break;
  default:
    print_trapframe(tf);
    break;
  }
}
    802004c2:	60a2                	ld	ra,8(sp)
    802004c4:	6402                	ld	s0,0(sp)
    802004c6:	0141                	addi	sp,sp,16
    802004c8:	8082                	ret
  switch (tf->cause) {
    802004ca:	17f1                	addi	a5,a5,-4
    802004cc:	471d                	li	a4,7
    802004ce:	fef77ae3          	bgeu	a4,a5,802004c2 <exception_handler+0x42>
}
    802004d2:	6402                	ld	s0,0(sp)
    802004d4:	60a2                	ld	ra,8(sp)
    802004d6:	0141                	addi	sp,sp,16
    print_trapframe(tf);
    802004d8:	bd41                	j	80200368 <print_trapframe>
    cprintf("Exception type: breakpoint\n");
    802004da:	00001517          	auipc	a0,0x1
    802004de:	b1e50513          	addi	a0,a0,-1250 # 80200ff8 <etext+0x5c4>
    802004e2:	b89ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("ebreak caught at 0x%d\n", tf->epc);
    802004e6:	10843583          	ld	a1,264(s0)
    802004ea:	00001517          	auipc	a0,0x1
    802004ee:	b2e50513          	addi	a0,a0,-1234 # 80201018 <etext+0x5e4>
    802004f2:	b79ff0ef          	jal	ra,8020006a <cprintf>
    tf->epc += 2;
    802004f6:	10843783          	ld	a5,264(s0)
}
    802004fa:	60a2                	ld	ra,8(sp)
    tf->epc += 2;
    802004fc:	0789                	addi	a5,a5,2
    802004fe:	10f43423          	sd	a5,264(s0)
}
    80200502:	6402                	ld	s0,0(sp)
    80200504:	0141                	addi	sp,sp,16
    80200506:	8082                	ret

0000000080200508 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
  if ((intptr_t)tf->cause < 0) {
    80200508:	11853783          	ld	a5,280(a0)
    8020050c:	0007c363          	bltz	a5,80200512 <trap+0xa>
    // interrupts
    interrupt_handler(tf);
  } else {
    // exceptions
    exception_handler(tf);
    80200510:	bf85                	j	80200480 <exception_handler>
    interrupt_handler(tf);
    80200512:	bd5d                	j	802003c8 <interrupt_handler>

0000000080200514 <__alltraps>:
=======
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200186:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	37e78793          	addi	a5,a5,894 # 80200508 <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
}
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	9a050513          	addi	a0,a0,-1632 # 80200b40 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    802001a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	ec7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	9a850513          	addi	a0,a0,-1624 # 80200b58 <etext+0x130>
    802001b8:	eb9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	9b250513          	addi	a0,a0,-1614 # 80200b70 <etext+0x148>
    802001c6:	eabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	9bc50513          	addi	a0,a0,-1604 # 80200b88 <etext+0x160>
    802001d4:	e9dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	9c650513          	addi	a0,a0,-1594 # 80200ba0 <etext+0x178>
    802001e2:	e8fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	9d050513          	addi	a0,a0,-1584 # 80200bb8 <etext+0x190>
    802001f0:	e81ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	9da50513          	addi	a0,a0,-1574 # 80200bd0 <etext+0x1a8>
    802001fe:	e73ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	9e450513          	addi	a0,a0,-1564 # 80200be8 <etext+0x1c0>
    8020020c:	e65ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	9ee50513          	addi	a0,a0,-1554 # 80200c00 <etext+0x1d8>
    8020021a:	e57ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	9f850513          	addi	a0,a0,-1544 # 80200c18 <etext+0x1f0>
    80200228:	e49ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	a0250513          	addi	a0,a0,-1534 # 80200c30 <etext+0x208>
    80200236:	e3bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	a0c50513          	addi	a0,a0,-1524 # 80200c48 <etext+0x220>
    80200244:	e2dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	a1650513          	addi	a0,a0,-1514 # 80200c60 <etext+0x238>
    80200252:	e1fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	a2050513          	addi	a0,a0,-1504 # 80200c78 <etext+0x250>
    80200260:	e11ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	a2a50513          	addi	a0,a0,-1494 # 80200c90 <etext+0x268>
    8020026e:	e03ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	a3450513          	addi	a0,a0,-1484 # 80200ca8 <etext+0x280>
    8020027c:	df5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	a3e50513          	addi	a0,a0,-1474 # 80200cc0 <etext+0x298>
    8020028a:	de7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	a4850513          	addi	a0,a0,-1464 # 80200cd8 <etext+0x2b0>
    80200298:	dd9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	a5250513          	addi	a0,a0,-1454 # 80200cf0 <etext+0x2c8>
    802002a6:	dcbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	a5c50513          	addi	a0,a0,-1444 # 80200d08 <etext+0x2e0>
    802002b4:	dbdff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	a6650513          	addi	a0,a0,-1434 # 80200d20 <etext+0x2f8>
    802002c2:	dafff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	a7050513          	addi	a0,a0,-1424 # 80200d38 <etext+0x310>
    802002d0:	da1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	a7a50513          	addi	a0,a0,-1414 # 80200d50 <etext+0x328>
    802002de:	d93ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	a8450513          	addi	a0,a0,-1404 # 80200d68 <etext+0x340>
    802002ec:	d85ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	a8e50513          	addi	a0,a0,-1394 # 80200d80 <etext+0x358>
    802002fa:	d77ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	a9850513          	addi	a0,a0,-1384 # 80200d98 <etext+0x370>
    80200308:	d69ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	aa250513          	addi	a0,a0,-1374 # 80200db0 <etext+0x388>
    80200316:	d5bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	aac50513          	addi	a0,a0,-1364 # 80200dc8 <etext+0x3a0>
    80200324:	d4dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	ab650513          	addi	a0,a0,-1354 # 80200de0 <etext+0x3b8>
    80200332:	d3fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	ac050513          	addi	a0,a0,-1344 # 80200df8 <etext+0x3d0>
    80200340:	d31ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	aca50513          	addi	a0,a0,-1334 # 80200e10 <etext+0x3e8>
    8020034e:	d23ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	7c6c                	ld	a1,248(s0)
}
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	ad050513          	addi	a0,a0,-1328 # 80200e28 <etext+0x400>
}
    80200360:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	b339                	j	80200070 <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	ad450513          	addi	a0,a0,-1324 # 80200e40 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cfbff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1dff0ef          	jal	ra,80200198 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	ad450513          	addi	a0,a0,-1324 # 80200e58 <etext+0x430>
    8020038c:	ce5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	adc50513          	addi	a0,a0,-1316 # 80200e70 <etext+0x448>
    8020039c:	cd5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	ae450513          	addi	a0,a0,-1308 # 80200e88 <etext+0x460>
    802003ac:	cc5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	ae850513          	addi	a0,a0,-1304 # 80200ea0 <etext+0x478>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	b17d                	j	80200070 <cprintf>

00000000802003c4 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c4:	11853783          	ld	a5,280(a0)
    802003c8:	472d                	li	a4,11
    802003ca:	0786                	slli	a5,a5,0x1
    802003cc:	8385                	srli	a5,a5,0x1
    802003ce:	08f76263          	bltu	a4,a5,80200452 <interrupt_handler+0x8e>
    802003d2:	00001717          	auipc	a4,0x1
    802003d6:	b9670713          	addi	a4,a4,-1130 # 80200f68 <etext+0x540>
    802003da:	078a                	slli	a5,a5,0x2
    802003dc:	97ba                	add	a5,a5,a4
    802003de:	439c                	lw	a5,0(a5)
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	b3450513          	addi	a0,a0,-1228 # 80200f18 <etext+0x4f0>
    802003ec:	b151                	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	b0a50513          	addi	a0,a0,-1270 # 80200ef8 <etext+0x4d0>
    802003f6:	b9ad                	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	ac050513          	addi	a0,a0,-1344 # 80200eb8 <etext+0x490>
    80200400:	b985                	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200402:	00001517          	auipc	a0,0x1
    80200406:	ad650513          	addi	a0,a0,-1322 # 80200ed8 <etext+0x4b0>
    8020040a:	b19d                	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040c:	1141                	addi	sp,sp,-16
    8020040e:	e022                	sd	s0,0(sp)
    80200410:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */

            clock_set_next_event();//源代码在clock.c
    80200412:	d55ff0ef          	jal	ra,80200166 <clock_set_next_event>
            ticks++;
    80200416:	00004797          	auipc	a5,0x4
    8020041a:	bfa78793          	addi	a5,a5,-1030 # 80204010 <ticks>
    8020041e:	6398                	ld	a4,0(a5)
    80200420:	00004417          	auipc	s0,0x4
    80200424:	bf840413          	addi	s0,s0,-1032 # 80204018 <num>
    80200428:	0705                	addi	a4,a4,1
    8020042a:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
    8020042c:	639c                	ld	a5,0(a5)
    8020042e:	06400713          	li	a4,100
    80200432:	02e7f7b3          	remu	a5,a5,a4
    80200436:	cf99                	beqz	a5,80200454 <interrupt_handler+0x90>
                print_ticks();
                num++;
            }
            if(num==10){
    80200438:	6018                	ld	a4,0(s0)
    8020043a:	47a9                	li	a5,10
    8020043c:	02f70863          	beq	a4,a5,8020046c <interrupt_handler+0xa8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200440:	60a2                	ld	ra,8(sp)
    80200442:	6402                	ld	s0,0(sp)
    80200444:	0141                	addi	sp,sp,16
    80200446:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200448:	00001517          	auipc	a0,0x1
    8020044c:	b0050513          	addi	a0,a0,-1280 # 80200f48 <etext+0x520>
    80200450:	b105                	j	80200070 <cprintf>
            print_trapframe(tf);
    80200452:	bf09                	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200454:	06400593          	li	a1,100
    80200458:	00001517          	auipc	a0,0x1
    8020045c:	ae050513          	addi	a0,a0,-1312 # 80200f38 <etext+0x510>
    80200460:	c11ff0ef          	jal	ra,80200070 <cprintf>
                num++;
    80200464:	601c                	ld	a5,0(s0)
    80200466:	0785                	addi	a5,a5,1
    80200468:	e01c                	sd	a5,0(s0)
    8020046a:	b7f9                	j	80200438 <interrupt_handler+0x74>
}
    8020046c:	6402                	ld	s0,0(sp)
    8020046e:	60a2                	ld	ra,8(sp)
    80200470:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200472:	ab71                	j	80200a0e <sbi_shutdown>

0000000080200474 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200474:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200478:	1141                	addi	sp,sp,-16
    8020047a:	e022                	sd	s0,0(sp)
    8020047c:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    8020047e:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200480:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200482:	04e78663          	beq	a5,a4,802004ce <exception_handler+0x5a>
    80200486:	02f76c63          	bltu	a4,a5,802004be <exception_handler+0x4a>
    8020048a:	4709                	li	a4,2
    8020048c:	02e79563          	bne	a5,a4,802004b6 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   YOUR CODE : 2211804 */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("指令异常类型:Illegal instruction\n");
    80200490:	00001517          	auipc	a0,0x1
    80200494:	b0850513          	addi	a0,a0,-1272 # 80200f98 <etext+0x570>
    80200498:	bd9ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("异常指令地址%p\n",tf->epc);
    8020049c:	10843583          	ld	a1,264(s0)
    802004a0:	00001517          	auipc	a0,0x1
    802004a4:	b2050513          	addi	a0,a0,-1248 # 80200fc0 <etext+0x598>
    802004a8:	bc9ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 4;
    802004ac:	10843783          	ld	a5,264(s0)
    802004b0:	0791                	addi	a5,a5,4
    802004b2:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b6:	60a2                	ld	ra,8(sp)
    802004b8:	6402                	ld	s0,0(sp)
    802004ba:	0141                	addi	sp,sp,16
    802004bc:	8082                	ret
    switch (tf->cause) {
    802004be:	17f1                	addi	a5,a5,-4
    802004c0:	471d                	li	a4,7
    802004c2:	fef77ae3          	bgeu	a4,a5,802004b6 <exception_handler+0x42>
}
    802004c6:	6402                	ld	s0,0(sp)
    802004c8:	60a2                	ld	ra,8(sp)
    802004ca:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004cc:	bd61                	j	80200364 <print_trapframe>
            cprintf("指令异常类型:Illegal instruction\n");
    802004ce:	00001517          	auipc	a0,0x1
    802004d2:	aca50513          	addi	a0,a0,-1334 # 80200f98 <etext+0x570>
    802004d6:	b9bff0ef          	jal	ra,80200070 <cprintf>
            cprintf("异常指令地址%p\n",tf->epc);
    802004da:	10843583          	ld	a1,264(s0)
    802004de:	00001517          	auipc	a0,0x1
    802004e2:	ae250513          	addi	a0,a0,-1310 # 80200fc0 <etext+0x598>
    802004e6:	b8bff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 2;
    802004ea:	10843783          	ld	a5,264(s0)
}
    802004ee:	60a2                	ld	ra,8(sp)
            tf->epc += 2;
    802004f0:	0789                	addi	a5,a5,2
    802004f2:	10f43423          	sd	a5,264(s0)
}
    802004f6:	6402                	ld	s0,0(sp)
    802004f8:	0141                	addi	sp,sp,16
    802004fa:	8082                	ret

00000000802004fc <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004fc:	11853783          	ld	a5,280(a0)
    80200500:	0007c363          	bltz	a5,80200506 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200504:	bf85                	j	80200474 <exception_handler>
        interrupt_handler(tf);
    80200506:	bd7d                	j	802003c4 <interrupt_handler>

0000000080200508 <__alltraps>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
<<<<<<< HEAD
    80200514:	14011073          	csrw	sscratch,sp
    80200518:	712d                	addi	sp,sp,-288
    8020051a:	e002                	sd	zero,0(sp)
    8020051c:	e406                	sd	ra,8(sp)
    8020051e:	ec0e                	sd	gp,24(sp)
    80200520:	f012                	sd	tp,32(sp)
    80200522:	f416                	sd	t0,40(sp)
    80200524:	f81a                	sd	t1,48(sp)
    80200526:	fc1e                	sd	t2,56(sp)
    80200528:	e0a2                	sd	s0,64(sp)
    8020052a:	e4a6                	sd	s1,72(sp)
    8020052c:	e8aa                	sd	a0,80(sp)
    8020052e:	ecae                	sd	a1,88(sp)
    80200530:	f0b2                	sd	a2,96(sp)
    80200532:	f4b6                	sd	a3,104(sp)
    80200534:	f8ba                	sd	a4,112(sp)
    80200536:	fcbe                	sd	a5,120(sp)
    80200538:	e142                	sd	a6,128(sp)
    8020053a:	e546                	sd	a7,136(sp)
    8020053c:	e94a                	sd	s2,144(sp)
    8020053e:	ed4e                	sd	s3,152(sp)
    80200540:	f152                	sd	s4,160(sp)
    80200542:	f556                	sd	s5,168(sp)
    80200544:	f95a                	sd	s6,176(sp)
    80200546:	fd5e                	sd	s7,184(sp)
    80200548:	e1e2                	sd	s8,192(sp)
    8020054a:	e5e6                	sd	s9,200(sp)
    8020054c:	e9ea                	sd	s10,208(sp)
    8020054e:	edee                	sd	s11,216(sp)
    80200550:	f1f2                	sd	t3,224(sp)
    80200552:	f5f6                	sd	t4,232(sp)
    80200554:	f9fa                	sd	t5,240(sp)
    80200556:	fdfe                	sd	t6,248(sp)
    80200558:	14001473          	csrrw	s0,sscratch,zero
    8020055c:	100024f3          	csrr	s1,sstatus
    80200560:	14102973          	csrr	s2,sepc
    80200564:	143029f3          	csrr	s3,stval
    80200568:	14202a73          	csrr	s4,scause
    8020056c:	e822                	sd	s0,16(sp)
    8020056e:	e226                	sd	s1,256(sp)
    80200570:	e64a                	sd	s2,264(sp)
    80200572:	ea4e                	sd	s3,272(sp)
    80200574:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200576:	850a                	mv	a0,sp
    jal trap
    80200578:	f91ff0ef          	jal	ra,80200508 <trap>

000000008020057c <__trapret>:
=======
    80200508:	14011073          	csrw	sscratch,sp
    8020050c:	712d                	addi	sp,sp,-288
    8020050e:	e002                	sd	zero,0(sp)
    80200510:	e406                	sd	ra,8(sp)
    80200512:	ec0e                	sd	gp,24(sp)
    80200514:	f012                	sd	tp,32(sp)
    80200516:	f416                	sd	t0,40(sp)
    80200518:	f81a                	sd	t1,48(sp)
    8020051a:	fc1e                	sd	t2,56(sp)
    8020051c:	e0a2                	sd	s0,64(sp)
    8020051e:	e4a6                	sd	s1,72(sp)
    80200520:	e8aa                	sd	a0,80(sp)
    80200522:	ecae                	sd	a1,88(sp)
    80200524:	f0b2                	sd	a2,96(sp)
    80200526:	f4b6                	sd	a3,104(sp)
    80200528:	f8ba                	sd	a4,112(sp)
    8020052a:	fcbe                	sd	a5,120(sp)
    8020052c:	e142                	sd	a6,128(sp)
    8020052e:	e546                	sd	a7,136(sp)
    80200530:	e94a                	sd	s2,144(sp)
    80200532:	ed4e                	sd	s3,152(sp)
    80200534:	f152                	sd	s4,160(sp)
    80200536:	f556                	sd	s5,168(sp)
    80200538:	f95a                	sd	s6,176(sp)
    8020053a:	fd5e                	sd	s7,184(sp)
    8020053c:	e1e2                	sd	s8,192(sp)
    8020053e:	e5e6                	sd	s9,200(sp)
    80200540:	e9ea                	sd	s10,208(sp)
    80200542:	edee                	sd	s11,216(sp)
    80200544:	f1f2                	sd	t3,224(sp)
    80200546:	f5f6                	sd	t4,232(sp)
    80200548:	f9fa                	sd	t5,240(sp)
    8020054a:	fdfe                	sd	t6,248(sp)
    8020054c:	14001473          	csrrw	s0,sscratch,zero
    80200550:	100024f3          	csrr	s1,sstatus
    80200554:	14102973          	csrr	s2,sepc
    80200558:	143029f3          	csrr	s3,stval
    8020055c:	14202a73          	csrr	s4,scause
    80200560:	e822                	sd	s0,16(sp)
    80200562:	e226                	sd	s1,256(sp)
    80200564:	e64a                	sd	s2,264(sp)
    80200566:	ea4e                	sd	s3,272(sp)
    80200568:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020056a:	850a                	mv	a0,sp
    jal trap
    8020056c:	f91ff0ef          	jal	ra,802004fc <trap>

0000000080200570 <__trapret>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
<<<<<<< HEAD
    8020057c:	6492                	ld	s1,256(sp)
    8020057e:	6932                	ld	s2,264(sp)
    80200580:	10049073          	csrw	sstatus,s1
    80200584:	14191073          	csrw	sepc,s2
    80200588:	60a2                	ld	ra,8(sp)
    8020058a:	61e2                	ld	gp,24(sp)
    8020058c:	7202                	ld	tp,32(sp)
    8020058e:	72a2                	ld	t0,40(sp)
    80200590:	7342                	ld	t1,48(sp)
    80200592:	73e2                	ld	t2,56(sp)
    80200594:	6406                	ld	s0,64(sp)
    80200596:	64a6                	ld	s1,72(sp)
    80200598:	6546                	ld	a0,80(sp)
    8020059a:	65e6                	ld	a1,88(sp)
    8020059c:	7606                	ld	a2,96(sp)
    8020059e:	76a6                	ld	a3,104(sp)
    802005a0:	7746                	ld	a4,112(sp)
    802005a2:	77e6                	ld	a5,120(sp)
    802005a4:	680a                	ld	a6,128(sp)
    802005a6:	68aa                	ld	a7,136(sp)
    802005a8:	694a                	ld	s2,144(sp)
    802005aa:	69ea                	ld	s3,152(sp)
    802005ac:	7a0a                	ld	s4,160(sp)
    802005ae:	7aaa                	ld	s5,168(sp)
    802005b0:	7b4a                	ld	s6,176(sp)
    802005b2:	7bea                	ld	s7,184(sp)
    802005b4:	6c0e                	ld	s8,192(sp)
    802005b6:	6cae                	ld	s9,200(sp)
    802005b8:	6d4e                	ld	s10,208(sp)
    802005ba:	6dee                	ld	s11,216(sp)
    802005bc:	7e0e                	ld	t3,224(sp)
    802005be:	7eae                	ld	t4,232(sp)
    802005c0:	7f4e                	ld	t5,240(sp)
    802005c2:	7fee                	ld	t6,248(sp)
    802005c4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005c6:	10200073          	sret

00000000802005ca <strnlen>:
=======
    80200570:	6492                	ld	s1,256(sp)
    80200572:	6932                	ld	s2,264(sp)
    80200574:	10049073          	csrw	sstatus,s1
    80200578:	14191073          	csrw	sepc,s2
    8020057c:	60a2                	ld	ra,8(sp)
    8020057e:	61e2                	ld	gp,24(sp)
    80200580:	7202                	ld	tp,32(sp)
    80200582:	72a2                	ld	t0,40(sp)
    80200584:	7342                	ld	t1,48(sp)
    80200586:	73e2                	ld	t2,56(sp)
    80200588:	6406                	ld	s0,64(sp)
    8020058a:	64a6                	ld	s1,72(sp)
    8020058c:	6546                	ld	a0,80(sp)
    8020058e:	65e6                	ld	a1,88(sp)
    80200590:	7606                	ld	a2,96(sp)
    80200592:	76a6                	ld	a3,104(sp)
    80200594:	7746                	ld	a4,112(sp)
    80200596:	77e6                	ld	a5,120(sp)
    80200598:	680a                	ld	a6,128(sp)
    8020059a:	68aa                	ld	a7,136(sp)
    8020059c:	694a                	ld	s2,144(sp)
    8020059e:	69ea                	ld	s3,152(sp)
    802005a0:	7a0a                	ld	s4,160(sp)
    802005a2:	7aaa                	ld	s5,168(sp)
    802005a4:	7b4a                	ld	s6,176(sp)
    802005a6:	7bea                	ld	s7,184(sp)
    802005a8:	6c0e                	ld	s8,192(sp)
    802005aa:	6cae                	ld	s9,200(sp)
    802005ac:	6d4e                	ld	s10,208(sp)
    802005ae:	6dee                	ld	s11,216(sp)
    802005b0:	7e0e                	ld	t3,224(sp)
    802005b2:	7eae                	ld	t4,232(sp)
    802005b4:	7f4e                	ld	t5,240(sp)
    802005b6:	7fee                	ld	t6,248(sp)
    802005b8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ba:	10200073          	sret

00000000802005be <strnlen>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
<<<<<<< HEAD
    802005ca:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802005cc:	e589                	bnez	a1,802005d6 <strnlen+0xc>
    802005ce:	a811                	j	802005e2 <strnlen+0x18>
        cnt ++;
    802005d0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802005d2:	00f58863          	beq	a1,a5,802005e2 <strnlen+0x18>
    802005d6:	00f50733          	add	a4,a0,a5
    802005da:	00074703          	lbu	a4,0(a4)
    802005de:	fb6d                	bnez	a4,802005d0 <strnlen+0x6>
    802005e0:	85be                	mv	a1,a5
    }
    return cnt;
}
    802005e2:	852e                	mv	a0,a1
    802005e4:	8082                	ret

00000000802005e6 <memset>:
=======
    802005be:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802005c0:	e589                	bnez	a1,802005ca <strnlen+0xc>
    802005c2:	a811                	j	802005d6 <strnlen+0x18>
        cnt ++;
    802005c4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802005c6:	00f58863          	beq	a1,a5,802005d6 <strnlen+0x18>
    802005ca:	00f50733          	add	a4,a0,a5
    802005ce:	00074703          	lbu	a4,0(a4)
    802005d2:	fb6d                	bnez	a4,802005c4 <strnlen+0x6>
    802005d4:	85be                	mv	a1,a5
    }
    return cnt;
}
    802005d6:	852e                	mv	a0,a1
    802005d8:	8082                	ret

00000000802005da <memset>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
<<<<<<< HEAD
    802005e6:	ca01                	beqz	a2,802005f6 <memset+0x10>
    802005e8:	962a                	add	a2,a2,a0
    char *p = s;
    802005ea:	87aa                	mv	a5,a0
        *p ++ = c;
    802005ec:	0785                	addi	a5,a5,1
    802005ee:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802005f2:	fec79de3          	bne	a5,a2,802005ec <memset+0x6>
=======
    802005da:	ca01                	beqz	a2,802005ea <memset+0x10>
    802005dc:	962a                	add	a2,a2,a0
    char *p = s;
    802005de:	87aa                	mv	a5,a0
        *p ++ = c;
    802005e0:	0785                	addi	a5,a5,1
    802005e2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802005e6:	fec79de3          	bne	a5,a2,802005e0 <memset+0x6>
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
<<<<<<< HEAD
    802005f6:	8082                	ret

00000000802005f8 <printnum>:
=======
    802005ea:	8082                	ret

00000000802005ec <printnum>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
<<<<<<< HEAD
    802005f8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005fc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005fe:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200602:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200604:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200608:	f022                	sd	s0,32(sp)
    8020060a:	ec26                	sd	s1,24(sp)
    8020060c:	e84a                	sd	s2,16(sp)
    8020060e:	f406                	sd	ra,40(sp)
    80200610:	e44e                	sd	s3,8(sp)
    80200612:	84aa                	mv	s1,a0
    80200614:	892e                	mv	s2,a1
=======
    802005ec:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005f0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005f2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005f6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005f8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005fc:	f022                	sd	s0,32(sp)
    802005fe:	ec26                	sd	s1,24(sp)
    80200600:	e84a                	sd	s2,16(sp)
    80200602:	f406                	sd	ra,40(sp)
    80200604:	e44e                	sd	s3,8(sp)
    80200606:	84aa                	mv	s1,a0
    80200608:	892e                	mv	s2,a1
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
<<<<<<< HEAD
    80200616:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020061a:	2a01                	sext.w	s4,s4
    if (num >= base) {
    8020061c:	03067e63          	bgeu	a2,a6,80200658 <printnum+0x60>
    80200620:	89be                	mv	s3,a5
        while (-- width > 0)
    80200622:	00805763          	blez	s0,80200630 <printnum+0x38>
    80200626:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200628:	85ca                	mv	a1,s2
    8020062a:	854e                	mv	a0,s3
    8020062c:	9482                	jalr	s1
        while (-- width > 0)
    8020062e:	fc65                	bnez	s0,80200626 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200630:	1a02                	slli	s4,s4,0x20
    80200632:	00001797          	auipc	a5,0x1
    80200636:	9fe78793          	addi	a5,a5,-1538 # 80201030 <etext+0x5fc>
    8020063a:	020a5a13          	srli	s4,s4,0x20
    8020063e:	9a3e                	add	s4,s4,a5
}
    80200640:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200642:	000a4503          	lbu	a0,0(s4)
}
    80200646:	70a2                	ld	ra,40(sp)
    80200648:	69a2                	ld	s3,8(sp)
    8020064a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020064c:	85ca                	mv	a1,s2
    8020064e:	87a6                	mv	a5,s1
}
    80200650:	6942                	ld	s2,16(sp)
    80200652:	64e2                	ld	s1,24(sp)
    80200654:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200656:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200658:	03065633          	divu	a2,a2,a6
    8020065c:	8722                	mv	a4,s0
    8020065e:	f9bff0ef          	jal	ra,802005f8 <printnum>
    80200662:	b7f9                	j	80200630 <printnum+0x38>

0000000080200664 <vprintfmt>:
=======
    8020060a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020060e:	2a01                	sext.w	s4,s4
    if (num >= base) {
    80200610:	03067e63          	bgeu	a2,a6,8020064c <printnum+0x60>
    80200614:	89be                	mv	s3,a5
        while (-- width > 0)
    80200616:	00805763          	blez	s0,80200624 <printnum+0x38>
    8020061a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020061c:	85ca                	mv	a1,s2
    8020061e:	854e                	mv	a0,s3
    80200620:	9482                	jalr	s1
        while (-- width > 0)
    80200622:	fc65                	bnez	s0,8020061a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200624:	1a02                	slli	s4,s4,0x20
    80200626:	00001797          	auipc	a5,0x1
    8020062a:	9b278793          	addi	a5,a5,-1614 # 80200fd8 <etext+0x5b0>
    8020062e:	020a5a13          	srli	s4,s4,0x20
    80200632:	9a3e                	add	s4,s4,a5
}
    80200634:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200636:	000a4503          	lbu	a0,0(s4)
}
    8020063a:	70a2                	ld	ra,40(sp)
    8020063c:	69a2                	ld	s3,8(sp)
    8020063e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200640:	85ca                	mv	a1,s2
    80200642:	87a6                	mv	a5,s1
}
    80200644:	6942                	ld	s2,16(sp)
    80200646:	64e2                	ld	s1,24(sp)
    80200648:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020064a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    8020064c:	03065633          	divu	a2,a2,a6
    80200650:	8722                	mv	a4,s0
    80200652:	f9bff0ef          	jal	ra,802005ec <printnum>
    80200656:	b7f9                	j	80200624 <printnum+0x38>

0000000080200658 <vprintfmt>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
<<<<<<< HEAD
    80200664:	7119                	addi	sp,sp,-128
    80200666:	f4a6                	sd	s1,104(sp)
    80200668:	f0ca                	sd	s2,96(sp)
    8020066a:	ecce                	sd	s3,88(sp)
    8020066c:	e8d2                	sd	s4,80(sp)
    8020066e:	e4d6                	sd	s5,72(sp)
    80200670:	e0da                	sd	s6,64(sp)
    80200672:	fc5e                	sd	s7,56(sp)
    80200674:	f06a                	sd	s10,32(sp)
    80200676:	fc86                	sd	ra,120(sp)
    80200678:	f8a2                	sd	s0,112(sp)
    8020067a:	f862                	sd	s8,48(sp)
    8020067c:	f466                	sd	s9,40(sp)
    8020067e:	ec6e                	sd	s11,24(sp)
    80200680:	892a                	mv	s2,a0
    80200682:	84ae                	mv	s1,a1
    80200684:	8d32                	mv	s10,a2
    80200686:	8a36                	mv	s4,a3
=======
    80200658:	7119                	addi	sp,sp,-128
    8020065a:	f4a6                	sd	s1,104(sp)
    8020065c:	f0ca                	sd	s2,96(sp)
    8020065e:	ecce                	sd	s3,88(sp)
    80200660:	e8d2                	sd	s4,80(sp)
    80200662:	e4d6                	sd	s5,72(sp)
    80200664:	e0da                	sd	s6,64(sp)
    80200666:	fc5e                	sd	s7,56(sp)
    80200668:	f06a                	sd	s10,32(sp)
    8020066a:	fc86                	sd	ra,120(sp)
    8020066c:	f8a2                	sd	s0,112(sp)
    8020066e:	f862                	sd	s8,48(sp)
    80200670:	f466                	sd	s9,40(sp)
    80200672:	ec6e                	sd	s11,24(sp)
    80200674:	892a                	mv	s2,a0
    80200676:	84ae                	mv	s1,a1
    80200678:	8d32                	mv	s10,a2
    8020067a:	8a36                	mv	s4,a3
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
<<<<<<< HEAD
    80200688:	02500993          	li	s3,37
=======
    8020067c:	02500993          	li	s3,37
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
<<<<<<< HEAD
    8020068c:	5b7d                	li	s6,-1
    8020068e:	00001a97          	auipc	s5,0x1
    80200692:	9d6a8a93          	addi	s5,s5,-1578 # 80201064 <etext+0x630>
=======
    80200680:	5b7d                	li	s6,-1
    80200682:	00001a97          	auipc	s5,0x1
    80200686:	98aa8a93          	addi	s5,s5,-1654 # 8020100c <etext+0x5e4>
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
<<<<<<< HEAD
    80200696:	00001b97          	auipc	s7,0x1
    8020069a:	baab8b93          	addi	s7,s7,-1110 # 80201240 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020069e:	000d4503          	lbu	a0,0(s10)
    802006a2:	001d0413          	addi	s0,s10,1
    802006a6:	01350a63          	beq	a0,s3,802006ba <vprintfmt+0x56>
            if (ch == '\0') {
    802006aa:	c121                	beqz	a0,802006ea <vprintfmt+0x86>
            putch(ch, putdat);
    802006ac:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ae:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006b0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b2:	fff44503          	lbu	a0,-1(s0)
    802006b6:	ff351ae3          	bne	a0,s3,802006aa <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    802006ba:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006be:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006c2:	4c81                	li	s9,0
    802006c4:	4881                	li	a7,0
        width = precision = -1;
    802006c6:	5c7d                	li	s8,-1
    802006c8:	5dfd                	li	s11,-1
    802006ca:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006ce:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006d0:	fdd6059b          	addiw	a1,a2,-35
    802006d4:	0ff5f593          	zext.b	a1,a1
    802006d8:	00140d13          	addi	s10,s0,1
    802006dc:	04b56263          	bltu	a0,a1,80200720 <vprintfmt+0xbc>
    802006e0:	058a                	slli	a1,a1,0x2
    802006e2:	95d6                	add	a1,a1,s5
    802006e4:	4194                	lw	a3,0(a1)
    802006e6:	96d6                	add	a3,a3,s5
    802006e8:	8682                	jr	a3
=======
    8020068a:	00001b97          	auipc	s7,0x1
    8020068e:	b5eb8b93          	addi	s7,s7,-1186 # 802011e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200692:	000d4503          	lbu	a0,0(s10)
    80200696:	001d0413          	addi	s0,s10,1
    8020069a:	01350a63          	beq	a0,s3,802006ae <vprintfmt+0x56>
            if (ch == '\0') {
    8020069e:	c121                	beqz	a0,802006de <vprintfmt+0x86>
            putch(ch, putdat);
    802006a0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006a4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a6:	fff44503          	lbu	a0,-1(s0)
    802006aa:	ff351ae3          	bne	a0,s3,8020069e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    802006ae:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006b2:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006b6:	4c81                	li	s9,0
    802006b8:	4881                	li	a7,0
        width = precision = -1;
    802006ba:	5c7d                	li	s8,-1
    802006bc:	5dfd                	li	s11,-1
    802006be:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006c2:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006c4:	fdd6059b          	addiw	a1,a2,-35
    802006c8:	0ff5f593          	zext.b	a1,a1
    802006cc:	00140d13          	addi	s10,s0,1
    802006d0:	04b56263          	bltu	a0,a1,80200714 <vprintfmt+0xbc>
    802006d4:	058a                	slli	a1,a1,0x2
    802006d6:	95d6                	add	a1,a1,s5
    802006d8:	4194                	lw	a3,0(a1)
    802006da:	96d6                	add	a3,a3,s5
    802006dc:	8682                	jr	a3
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
<<<<<<< HEAD
    802006ea:	70e6                	ld	ra,120(sp)
    802006ec:	7446                	ld	s0,112(sp)
    802006ee:	74a6                	ld	s1,104(sp)
    802006f0:	7906                	ld	s2,96(sp)
    802006f2:	69e6                	ld	s3,88(sp)
    802006f4:	6a46                	ld	s4,80(sp)
    802006f6:	6aa6                	ld	s5,72(sp)
    802006f8:	6b06                	ld	s6,64(sp)
    802006fa:	7be2                	ld	s7,56(sp)
    802006fc:	7c42                	ld	s8,48(sp)
    802006fe:	7ca2                	ld	s9,40(sp)
    80200700:	7d02                	ld	s10,32(sp)
    80200702:	6de2                	ld	s11,24(sp)
    80200704:	6109                	addi	sp,sp,128
    80200706:	8082                	ret
            padc = '0';
    80200708:	87b2                	mv	a5,a2
            goto reswitch;
    8020070a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020070e:	846a                	mv	s0,s10
    80200710:	00140d13          	addi	s10,s0,1
    80200714:	fdd6059b          	addiw	a1,a2,-35
    80200718:	0ff5f593          	zext.b	a1,a1
    8020071c:	fcb572e3          	bgeu	a0,a1,802006e0 <vprintfmt+0x7c>
            putch('%', putdat);
    80200720:	85a6                	mv	a1,s1
    80200722:	02500513          	li	a0,37
    80200726:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200728:	fff44783          	lbu	a5,-1(s0)
    8020072c:	8d22                	mv	s10,s0
    8020072e:	f73788e3          	beq	a5,s3,8020069e <vprintfmt+0x3a>
    80200732:	ffed4783          	lbu	a5,-2(s10)
    80200736:	1d7d                	addi	s10,s10,-1
    80200738:	ff379de3          	bne	a5,s3,80200732 <vprintfmt+0xce>
    8020073c:	b78d                	j	8020069e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    8020073e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200742:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200746:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200748:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020074c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200750:	02d86463          	bltu	a6,a3,80200778 <vprintfmt+0x114>
                ch = *fmt;
    80200754:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200758:	002c169b          	slliw	a3,s8,0x2
    8020075c:	0186873b          	addw	a4,a3,s8
    80200760:	0017171b          	slliw	a4,a4,0x1
    80200764:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200766:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020076a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020076c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200770:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200774:	fed870e3          	bgeu	a6,a3,80200754 <vprintfmt+0xf0>
            if (width < 0)
    80200778:	f40ddce3          	bgez	s11,802006d0 <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020077c:	8de2                	mv	s11,s8
    8020077e:	5c7d                	li	s8,-1
    80200780:	bf81                	j	802006d0 <vprintfmt+0x6c>
            if (width < 0)
    80200782:	fffdc693          	not	a3,s11
    80200786:	96fd                	srai	a3,a3,0x3f
    80200788:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020078c:	00144603          	lbu	a2,1(s0)
    80200790:	2d81                	sext.w	s11,s11
    80200792:	846a                	mv	s0,s10
            goto reswitch;
    80200794:	bf35                	j	802006d0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200796:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020079a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020079e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    802007a0:	846a                	mv	s0,s10
            goto process_precision;
    802007a2:	bfd9                	j	80200778 <vprintfmt+0x114>
    if (lflag >= 2) {
    802007a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007aa:	01174463          	blt	a4,a7,802007b2 <vprintfmt+0x14e>
    else if (lflag) {
    802007ae:	1a088e63          	beqz	a7,8020096a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802007b2:	000a3603          	ld	a2,0(s4)
    802007b6:	46c1                	li	a3,16
    802007b8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    802007ba:	2781                	sext.w	a5,a5
    802007bc:	876e                	mv	a4,s11
    802007be:	85a6                	mv	a1,s1
    802007c0:	854a                	mv	a0,s2
    802007c2:	e37ff0ef          	jal	ra,802005f8 <printnum>
            break;
    802007c6:	bde1                	j	8020069e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007c8:	000a2503          	lw	a0,0(s4)
    802007cc:	85a6                	mv	a1,s1
    802007ce:	0a21                	addi	s4,s4,8
    802007d0:	9902                	jalr	s2
            break;
    802007d2:	b5f1                	j	8020069e <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007d6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007da:	01174463          	blt	a4,a7,802007e2 <vprintfmt+0x17e>
    else if (lflag) {
    802007de:	18088163          	beqz	a7,80200960 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007e2:	000a3603          	ld	a2,0(s4)
    802007e6:	46a9                	li	a3,10
    802007e8:	8a2e                	mv	s4,a1
    802007ea:	bfc1                	j	802007ba <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007ec:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007f0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007f2:	846a                	mv	s0,s10
            goto reswitch;
    802007f4:	bdf1                	j	802006d0 <vprintfmt+0x6c>
            putch(ch, putdat);
    802007f6:	85a6                	mv	a1,s1
    802007f8:	02500513          	li	a0,37
    802007fc:	9902                	jalr	s2
            break;
    802007fe:	b545                	j	8020069e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    80200800:	00144603          	lbu	a2,1(s0)
            lflag ++;
    80200804:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200806:	846a                	mv	s0,s10
            goto reswitch;
    80200808:	b5e1                	j	802006d0 <vprintfmt+0x6c>
    if (lflag >= 2) {
    8020080a:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020080c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200810:	01174463          	blt	a4,a7,80200818 <vprintfmt+0x1b4>
    else if (lflag) {
    80200814:	14088163          	beqz	a7,80200956 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    80200818:	000a3603          	ld	a2,0(s4)
    8020081c:	46a1                	li	a3,8
    8020081e:	8a2e                	mv	s4,a1
    80200820:	bf69                	j	802007ba <vprintfmt+0x156>
            putch('0', putdat);
    80200822:	03000513          	li	a0,48
    80200826:	85a6                	mv	a1,s1
    80200828:	e03e                	sd	a5,0(sp)
    8020082a:	9902                	jalr	s2
            putch('x', putdat);
    8020082c:	85a6                	mv	a1,s1
    8020082e:	07800513          	li	a0,120
    80200832:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200834:	0a21                	addi	s4,s4,8
            goto number;
    80200836:	6782                	ld	a5,0(sp)
    80200838:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020083a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    8020083e:	bfb5                	j	802007ba <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200840:	000a3403          	ld	s0,0(s4)
    80200844:	008a0713          	addi	a4,s4,8
    80200848:	e03a                	sd	a4,0(sp)
    8020084a:	14040263          	beqz	s0,8020098e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    8020084e:	0fb05763          	blez	s11,8020093c <vprintfmt+0x2d8>
    80200852:	02d00693          	li	a3,45
    80200856:	0cd79163          	bne	a5,a3,80200918 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020085a:	00044783          	lbu	a5,0(s0)
    8020085e:	0007851b          	sext.w	a0,a5
    80200862:	cf85                	beqz	a5,8020089a <vprintfmt+0x236>
    80200864:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200868:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020086c:	000c4563          	bltz	s8,80200876 <vprintfmt+0x212>
    80200870:	3c7d                	addiw	s8,s8,-1
    80200872:	036c0263          	beq	s8,s6,80200896 <vprintfmt+0x232>
                    putch('?', putdat);
    80200876:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200878:	0e0c8e63          	beqz	s9,80200974 <vprintfmt+0x310>
    8020087c:	3781                	addiw	a5,a5,-32
    8020087e:	0ef47b63          	bgeu	s0,a5,80200974 <vprintfmt+0x310>
                    putch('?', putdat);
    80200882:	03f00513          	li	a0,63
    80200886:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200888:	000a4783          	lbu	a5,0(s4)
    8020088c:	3dfd                	addiw	s11,s11,-1
    8020088e:	0a05                	addi	s4,s4,1
    80200890:	0007851b          	sext.w	a0,a5
    80200894:	ffe1                	bnez	a5,8020086c <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200896:	01b05963          	blez	s11,802008a8 <vprintfmt+0x244>
    8020089a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020089c:	85a6                	mv	a1,s1
    8020089e:	02000513          	li	a0,32
    802008a2:	9902                	jalr	s2
            for (; width > 0; width --) {
    802008a4:	fe0d9be3          	bnez	s11,8020089a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008a8:	6a02                	ld	s4,0(sp)
    802008aa:	bbd5                	j	8020069e <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802008ae:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    802008b2:	01174463          	blt	a4,a7,802008ba <vprintfmt+0x256>
    else if (lflag) {
    802008b6:	08088d63          	beqz	a7,80200950 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    802008ba:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802008be:	0a044d63          	bltz	s0,80200978 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    802008c2:	8622                	mv	a2,s0
    802008c4:	8a66                	mv	s4,s9
    802008c6:	46a9                	li	a3,10
    802008c8:	bdcd                	j	802007ba <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008ca:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008ce:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008d0:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008d2:	41f7d69b          	sraiw	a3,a5,0x1f
    802008d6:	8fb5                	xor	a5,a5,a3
    802008d8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008dc:	02d74163          	blt	a4,a3,802008fe <vprintfmt+0x29a>
    802008e0:	00369793          	slli	a5,a3,0x3
    802008e4:	97de                	add	a5,a5,s7
    802008e6:	639c                	ld	a5,0(a5)
    802008e8:	cb99                	beqz	a5,802008fe <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008ea:	86be                	mv	a3,a5
    802008ec:	00000617          	auipc	a2,0x0
    802008f0:	77460613          	addi	a2,a2,1908 # 80201060 <etext+0x62c>
    802008f4:	85a6                	mv	a1,s1
    802008f6:	854a                	mv	a0,s2
    802008f8:	0ce000ef          	jal	ra,802009c6 <printfmt>
    802008fc:	b34d                	j	8020069e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008fe:	00000617          	auipc	a2,0x0
    80200902:	75260613          	addi	a2,a2,1874 # 80201050 <etext+0x61c>
    80200906:	85a6                	mv	a1,s1
    80200908:	854a                	mv	a0,s2
    8020090a:	0bc000ef          	jal	ra,802009c6 <printfmt>
    8020090e:	bb41                	j	8020069e <vprintfmt+0x3a>
                p = "(null)";
    80200910:	00000417          	auipc	s0,0x0
    80200914:	73840413          	addi	s0,s0,1848 # 80201048 <etext+0x614>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200918:	85e2                	mv	a1,s8
    8020091a:	8522                	mv	a0,s0
    8020091c:	e43e                	sd	a5,8(sp)
    8020091e:	cadff0ef          	jal	ra,802005ca <strnlen>
    80200922:	40ad8dbb          	subw	s11,s11,a0
    80200926:	01b05b63          	blez	s11,8020093c <vprintfmt+0x2d8>
                    putch(padc, putdat);
    8020092a:	67a2                	ld	a5,8(sp)
    8020092c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200930:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200932:	85a6                	mv	a1,s1
    80200934:	8552                	mv	a0,s4
    80200936:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200938:	fe0d9ce3          	bnez	s11,80200930 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020093c:	00044783          	lbu	a5,0(s0)
    80200940:	00140a13          	addi	s4,s0,1
    80200944:	0007851b          	sext.w	a0,a5
    80200948:	d3a5                	beqz	a5,802008a8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    8020094a:	05e00413          	li	s0,94
    8020094e:	bf39                	j	8020086c <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200950:	000a2403          	lw	s0,0(s4)
    80200954:	b7ad                	j	802008be <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200956:	000a6603          	lwu	a2,0(s4)
    8020095a:	46a1                	li	a3,8
    8020095c:	8a2e                	mv	s4,a1
    8020095e:	bdb1                	j	802007ba <vprintfmt+0x156>
    80200960:	000a6603          	lwu	a2,0(s4)
    80200964:	46a9                	li	a3,10
    80200966:	8a2e                	mv	s4,a1
    80200968:	bd89                	j	802007ba <vprintfmt+0x156>
    8020096a:	000a6603          	lwu	a2,0(s4)
    8020096e:	46c1                	li	a3,16
    80200970:	8a2e                	mv	s4,a1
    80200972:	b5a1                	j	802007ba <vprintfmt+0x156>
                    putch(ch, putdat);
    80200974:	9902                	jalr	s2
    80200976:	bf09                	j	80200888 <vprintfmt+0x224>
                putch('-', putdat);
    80200978:	85a6                	mv	a1,s1
    8020097a:	02d00513          	li	a0,45
    8020097e:	e03e                	sd	a5,0(sp)
    80200980:	9902                	jalr	s2
                num = -(long long)num;
    80200982:	6782                	ld	a5,0(sp)
    80200984:	8a66                	mv	s4,s9
    80200986:	40800633          	neg	a2,s0
    8020098a:	46a9                	li	a3,10
    8020098c:	b53d                	j	802007ba <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    8020098e:	03b05163          	blez	s11,802009b0 <vprintfmt+0x34c>
    80200992:	02d00693          	li	a3,45
    80200996:	f6d79de3          	bne	a5,a3,80200910 <vprintfmt+0x2ac>
                p = "(null)";
    8020099a:	00000417          	auipc	s0,0x0
    8020099e:	6ae40413          	addi	s0,s0,1710 # 80201048 <etext+0x614>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009a2:	02800793          	li	a5,40
    802009a6:	02800513          	li	a0,40
    802009aa:	00140a13          	addi	s4,s0,1
    802009ae:	bd6d                	j	80200868 <vprintfmt+0x204>
    802009b0:	00000a17          	auipc	s4,0x0
    802009b4:	699a0a13          	addi	s4,s4,1689 # 80201049 <etext+0x615>
    802009b8:	02800513          	li	a0,40
    802009bc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    802009c0:	05e00413          	li	s0,94
    802009c4:	b565                	j	8020086c <vprintfmt+0x208>

00000000802009c6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009c8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009cc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ce:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d0:	ec06                	sd	ra,24(sp)
    802009d2:	f83a                	sd	a4,48(sp)
    802009d4:	fc3e                	sd	a5,56(sp)
    802009d6:	e0c2                	sd	a6,64(sp)
    802009d8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009da:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009dc:	c89ff0ef          	jal	ra,80200664 <vprintfmt>
}
    802009e0:	60e2                	ld	ra,24(sp)
    802009e2:	6161                	addi	sp,sp,80
    802009e4:	8082                	ret

00000000802009e6 <sbi_console_putchar>:
=======
    802006de:	70e6                	ld	ra,120(sp)
    802006e0:	7446                	ld	s0,112(sp)
    802006e2:	74a6                	ld	s1,104(sp)
    802006e4:	7906                	ld	s2,96(sp)
    802006e6:	69e6                	ld	s3,88(sp)
    802006e8:	6a46                	ld	s4,80(sp)
    802006ea:	6aa6                	ld	s5,72(sp)
    802006ec:	6b06                	ld	s6,64(sp)
    802006ee:	7be2                	ld	s7,56(sp)
    802006f0:	7c42                	ld	s8,48(sp)
    802006f2:	7ca2                	ld	s9,40(sp)
    802006f4:	7d02                	ld	s10,32(sp)
    802006f6:	6de2                	ld	s11,24(sp)
    802006f8:	6109                	addi	sp,sp,128
    802006fa:	8082                	ret
            padc = '0';
    802006fc:	87b2                	mv	a5,a2
            goto reswitch;
    802006fe:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200702:	846a                	mv	s0,s10
    80200704:	00140d13          	addi	s10,s0,1
    80200708:	fdd6059b          	addiw	a1,a2,-35
    8020070c:	0ff5f593          	zext.b	a1,a1
    80200710:	fcb572e3          	bgeu	a0,a1,802006d4 <vprintfmt+0x7c>
            putch('%', putdat);
    80200714:	85a6                	mv	a1,s1
    80200716:	02500513          	li	a0,37
    8020071a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    8020071c:	fff44783          	lbu	a5,-1(s0)
    80200720:	8d22                	mv	s10,s0
    80200722:	f73788e3          	beq	a5,s3,80200692 <vprintfmt+0x3a>
    80200726:	ffed4783          	lbu	a5,-2(s10)
    8020072a:	1d7d                	addi	s10,s10,-1
    8020072c:	ff379de3          	bne	a5,s3,80200726 <vprintfmt+0xce>
    80200730:	b78d                	j	80200692 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200732:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200736:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020073a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020073c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200740:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200744:	02d86463          	bltu	a6,a3,8020076c <vprintfmt+0x114>
                ch = *fmt;
    80200748:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    8020074c:	002c169b          	slliw	a3,s8,0x2
    80200750:	0186873b          	addw	a4,a3,s8
    80200754:	0017171b          	slliw	a4,a4,0x1
    80200758:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    8020075a:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020075e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200760:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200764:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200768:	fed870e3          	bgeu	a6,a3,80200748 <vprintfmt+0xf0>
            if (width < 0)
    8020076c:	f40ddce3          	bgez	s11,802006c4 <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200770:	8de2                	mv	s11,s8
    80200772:	5c7d                	li	s8,-1
    80200774:	bf81                	j	802006c4 <vprintfmt+0x6c>
            if (width < 0)
    80200776:	fffdc693          	not	a3,s11
    8020077a:	96fd                	srai	a3,a3,0x3f
    8020077c:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200780:	00144603          	lbu	a2,1(s0)
    80200784:	2d81                	sext.w	s11,s11
    80200786:	846a                	mv	s0,s10
            goto reswitch;
    80200788:	bf35                	j	802006c4 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    8020078a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020078e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200792:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200794:	846a                	mv	s0,s10
            goto process_precision;
    80200796:	bfd9                	j	8020076c <vprintfmt+0x114>
    if (lflag >= 2) {
    80200798:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020079a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020079e:	01174463          	blt	a4,a7,802007a6 <vprintfmt+0x14e>
    else if (lflag) {
    802007a2:	1a088e63          	beqz	a7,8020095e <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802007a6:	000a3603          	ld	a2,0(s4)
    802007aa:	46c1                	li	a3,16
    802007ac:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    802007ae:	2781                	sext.w	a5,a5
    802007b0:	876e                	mv	a4,s11
    802007b2:	85a6                	mv	a1,s1
    802007b4:	854a                	mv	a0,s2
    802007b6:	e37ff0ef          	jal	ra,802005ec <printnum>
            break;
    802007ba:	bde1                	j	80200692 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007bc:	000a2503          	lw	a0,0(s4)
    802007c0:	85a6                	mv	a1,s1
    802007c2:	0a21                	addi	s4,s4,8
    802007c4:	9902                	jalr	s2
            break;
    802007c6:	b5f1                	j	80200692 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007ca:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007ce:	01174463          	blt	a4,a7,802007d6 <vprintfmt+0x17e>
    else if (lflag) {
    802007d2:	18088163          	beqz	a7,80200954 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007d6:	000a3603          	ld	a2,0(s4)
    802007da:	46a9                	li	a3,10
    802007dc:	8a2e                	mv	s4,a1
    802007de:	bfc1                	j	802007ae <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007e0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007e4:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007e6:	846a                	mv	s0,s10
            goto reswitch;
    802007e8:	bdf1                	j	802006c4 <vprintfmt+0x6c>
            putch(ch, putdat);
    802007ea:	85a6                	mv	a1,s1
    802007ec:	02500513          	li	a0,37
    802007f0:	9902                	jalr	s2
            break;
    802007f2:	b545                	j	80200692 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007f4:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007f8:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007fa:	846a                	mv	s0,s10
            goto reswitch;
    802007fc:	b5e1                	j	802006c4 <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007fe:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200800:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200804:	01174463          	blt	a4,a7,8020080c <vprintfmt+0x1b4>
    else if (lflag) {
    80200808:	14088163          	beqz	a7,8020094a <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    8020080c:	000a3603          	ld	a2,0(s4)
    80200810:	46a1                	li	a3,8
    80200812:	8a2e                	mv	s4,a1
    80200814:	bf69                	j	802007ae <vprintfmt+0x156>
            putch('0', putdat);
    80200816:	03000513          	li	a0,48
    8020081a:	85a6                	mv	a1,s1
    8020081c:	e03e                	sd	a5,0(sp)
    8020081e:	9902                	jalr	s2
            putch('x', putdat);
    80200820:	85a6                	mv	a1,s1
    80200822:	07800513          	li	a0,120
    80200826:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200828:	0a21                	addi	s4,s4,8
            goto number;
    8020082a:	6782                	ld	a5,0(sp)
    8020082c:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020082e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200832:	bfb5                	j	802007ae <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200834:	000a3403          	ld	s0,0(s4)
    80200838:	008a0713          	addi	a4,s4,8
    8020083c:	e03a                	sd	a4,0(sp)
    8020083e:	14040263          	beqz	s0,80200982 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200842:	0fb05763          	blez	s11,80200930 <vprintfmt+0x2d8>
    80200846:	02d00693          	li	a3,45
    8020084a:	0cd79163          	bne	a5,a3,8020090c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020084e:	00044783          	lbu	a5,0(s0)
    80200852:	0007851b          	sext.w	a0,a5
    80200856:	cf85                	beqz	a5,8020088e <vprintfmt+0x236>
    80200858:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020085c:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200860:	000c4563          	bltz	s8,8020086a <vprintfmt+0x212>
    80200864:	3c7d                	addiw	s8,s8,-1
    80200866:	036c0263          	beq	s8,s6,8020088a <vprintfmt+0x232>
                    putch('?', putdat);
    8020086a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020086c:	0e0c8e63          	beqz	s9,80200968 <vprintfmt+0x310>
    80200870:	3781                	addiw	a5,a5,-32
    80200872:	0ef47b63          	bgeu	s0,a5,80200968 <vprintfmt+0x310>
                    putch('?', putdat);
    80200876:	03f00513          	li	a0,63
    8020087a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020087c:	000a4783          	lbu	a5,0(s4)
    80200880:	3dfd                	addiw	s11,s11,-1
    80200882:	0a05                	addi	s4,s4,1
    80200884:	0007851b          	sext.w	a0,a5
    80200888:	ffe1                	bnez	a5,80200860 <vprintfmt+0x208>
            for (; width > 0; width --) {
    8020088a:	01b05963          	blez	s11,8020089c <vprintfmt+0x244>
    8020088e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200890:	85a6                	mv	a1,s1
    80200892:	02000513          	li	a0,32
    80200896:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200898:	fe0d9be3          	bnez	s11,8020088e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020089c:	6a02                	ld	s4,0(sp)
    8020089e:	bbd5                	j	80200692 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802008a2:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    802008a6:	01174463          	blt	a4,a7,802008ae <vprintfmt+0x256>
    else if (lflag) {
    802008aa:	08088d63          	beqz	a7,80200944 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    802008ae:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802008b2:	0a044d63          	bltz	s0,8020096c <vprintfmt+0x314>
            num = getint(&ap, lflag);
    802008b6:	8622                	mv	a2,s0
    802008b8:	8a66                	mv	s4,s9
    802008ba:	46a9                	li	a3,10
    802008bc:	bdcd                	j	802007ae <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008be:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008c2:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008c4:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008c6:	41f7d69b          	sraiw	a3,a5,0x1f
    802008ca:	8fb5                	xor	a5,a5,a3
    802008cc:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008d0:	02d74163          	blt	a4,a3,802008f2 <vprintfmt+0x29a>
    802008d4:	00369793          	slli	a5,a3,0x3
    802008d8:	97de                	add	a5,a5,s7
    802008da:	639c                	ld	a5,0(a5)
    802008dc:	cb99                	beqz	a5,802008f2 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008de:	86be                	mv	a3,a5
    802008e0:	00000617          	auipc	a2,0x0
    802008e4:	72860613          	addi	a2,a2,1832 # 80201008 <etext+0x5e0>
    802008e8:	85a6                	mv	a1,s1
    802008ea:	854a                	mv	a0,s2
    802008ec:	0ce000ef          	jal	ra,802009ba <printfmt>
    802008f0:	b34d                	j	80200692 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008f2:	00000617          	auipc	a2,0x0
    802008f6:	70660613          	addi	a2,a2,1798 # 80200ff8 <etext+0x5d0>
    802008fa:	85a6                	mv	a1,s1
    802008fc:	854a                	mv	a0,s2
    802008fe:	0bc000ef          	jal	ra,802009ba <printfmt>
    80200902:	bb41                	j	80200692 <vprintfmt+0x3a>
                p = "(null)";
    80200904:	00000417          	auipc	s0,0x0
    80200908:	6ec40413          	addi	s0,s0,1772 # 80200ff0 <etext+0x5c8>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020090c:	85e2                	mv	a1,s8
    8020090e:	8522                	mv	a0,s0
    80200910:	e43e                	sd	a5,8(sp)
    80200912:	cadff0ef          	jal	ra,802005be <strnlen>
    80200916:	40ad8dbb          	subw	s11,s11,a0
    8020091a:	01b05b63          	blez	s11,80200930 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    8020091e:	67a2                	ld	a5,8(sp)
    80200920:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200924:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200926:	85a6                	mv	a1,s1
    80200928:	8552                	mv	a0,s4
    8020092a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020092c:	fe0d9ce3          	bnez	s11,80200924 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200930:	00044783          	lbu	a5,0(s0)
    80200934:	00140a13          	addi	s4,s0,1
    80200938:	0007851b          	sext.w	a0,a5
    8020093c:	d3a5                	beqz	a5,8020089c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    8020093e:	05e00413          	li	s0,94
    80200942:	bf39                	j	80200860 <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200944:	000a2403          	lw	s0,0(s4)
    80200948:	b7ad                	j	802008b2 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    8020094a:	000a6603          	lwu	a2,0(s4)
    8020094e:	46a1                	li	a3,8
    80200950:	8a2e                	mv	s4,a1
    80200952:	bdb1                	j	802007ae <vprintfmt+0x156>
    80200954:	000a6603          	lwu	a2,0(s4)
    80200958:	46a9                	li	a3,10
    8020095a:	8a2e                	mv	s4,a1
    8020095c:	bd89                	j	802007ae <vprintfmt+0x156>
    8020095e:	000a6603          	lwu	a2,0(s4)
    80200962:	46c1                	li	a3,16
    80200964:	8a2e                	mv	s4,a1
    80200966:	b5a1                	j	802007ae <vprintfmt+0x156>
                    putch(ch, putdat);
    80200968:	9902                	jalr	s2
    8020096a:	bf09                	j	8020087c <vprintfmt+0x224>
                putch('-', putdat);
    8020096c:	85a6                	mv	a1,s1
    8020096e:	02d00513          	li	a0,45
    80200972:	e03e                	sd	a5,0(sp)
    80200974:	9902                	jalr	s2
                num = -(long long)num;
    80200976:	6782                	ld	a5,0(sp)
    80200978:	8a66                	mv	s4,s9
    8020097a:	40800633          	neg	a2,s0
    8020097e:	46a9                	li	a3,10
    80200980:	b53d                	j	802007ae <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200982:	03b05163          	blez	s11,802009a4 <vprintfmt+0x34c>
    80200986:	02d00693          	li	a3,45
    8020098a:	f6d79de3          	bne	a5,a3,80200904 <vprintfmt+0x2ac>
                p = "(null)";
    8020098e:	00000417          	auipc	s0,0x0
    80200992:	66240413          	addi	s0,s0,1634 # 80200ff0 <etext+0x5c8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200996:	02800793          	li	a5,40
    8020099a:	02800513          	li	a0,40
    8020099e:	00140a13          	addi	s4,s0,1
    802009a2:	bd6d                	j	8020085c <vprintfmt+0x204>
    802009a4:	00000a17          	auipc	s4,0x0
    802009a8:	64da0a13          	addi	s4,s4,1613 # 80200ff1 <etext+0x5c9>
    802009ac:	02800513          	li	a0,40
    802009b0:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    802009b4:	05e00413          	li	s0,94
    802009b8:	b565                	j	80200860 <vprintfmt+0x208>

00000000802009ba <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009ba:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009bc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009c2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009c4:	ec06                	sd	ra,24(sp)
    802009c6:	f83a                	sd	a4,48(sp)
    802009c8:	fc3e                	sd	a5,56(sp)
    802009ca:	e0c2                	sd	a6,64(sp)
    802009cc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009ce:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009d0:	c89ff0ef          	jal	ra,80200658 <vprintfmt>
}
    802009d4:	60e2                	ld	ra,24(sp)
    802009d6:	6161                	addi	sp,sp,80
    802009d8:	8082                	ret

00000000802009da <sbi_console_putchar>:
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
<<<<<<< HEAD
    802009e6:	4781                	li	a5,0
    802009e8:	00003717          	auipc	a4,0x3
    802009ec:	61873703          	ld	a4,1560(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009f0:	88ba                	mv	a7,a4
    802009f2:	852a                	mv	a0,a0
    802009f4:	85be                	mv	a1,a5
    802009f6:	863e                	mv	a2,a5
    802009f8:	00000073          	ecall
    802009fc:	87aa                	mv	a5,a0
=======
    802009da:	4781                	li	a5,0
    802009dc:	00003717          	auipc	a4,0x3
    802009e0:	62473703          	ld	a4,1572(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009e4:	88ba                	mv	a7,a4
    802009e6:	852a                	mv	a0,a0
    802009e8:	85be                	mv	a1,a5
    802009ea:	863e                	mv	a2,a5
    802009ec:	00000073          	ecall
    802009f0:	87aa                	mv	a5,a0
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
<<<<<<< HEAD
    802009fe:	8082                	ret

0000000080200a00 <sbi_set_timer>:
    __asm__ volatile (
    80200a00:	4781                	li	a5,0
    80200a02:	00003717          	auipc	a4,0x3
    80200a06:	61e73703          	ld	a4,1566(a4) # 80204020 <SBI_SET_TIMER>
    80200a0a:	88ba                	mv	a7,a4
    80200a0c:	852a                	mv	a0,a0
    80200a0e:	85be                	mv	a1,a5
    80200a10:	863e                	mv	a2,a5
    80200a12:	00000073          	ecall
    80200a16:	87aa                	mv	a5,a0
=======
    802009f2:	8082                	ret

00000000802009f4 <sbi_set_timer>:
    __asm__ volatile (
    802009f4:	4781                	li	a5,0
    802009f6:	00003717          	auipc	a4,0x3
    802009fa:	62a73703          	ld	a4,1578(a4) # 80204020 <SBI_SET_TIMER>
    802009fe:	88ba                	mv	a7,a4
    80200a00:	852a                	mv	a0,a0
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0
>>>>>>> 716958834b48ecaf18562a46466dd27072437116

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
<<<<<<< HEAD
    80200a18:	8082                	ret

0000000080200a1a <sbi_shutdown>:
    __asm__ volatile (
    80200a1a:	4781                	li	a5,0
    80200a1c:	00003717          	auipc	a4,0x3
    80200a20:	5ec73703          	ld	a4,1516(a4) # 80204008 <SBI_SHUTDOWN>
    80200a24:	88ba                	mv	a7,a4
    80200a26:	853e                	mv	a0,a5
    80200a28:	85be                	mv	a1,a5
    80200a2a:	863e                	mv	a2,a5
    80200a2c:	00000073          	ecall
    80200a30:	87aa                	mv	a5,a0
=======
    80200a0c:	8082                	ret

0000000080200a0e <sbi_shutdown>:
    __asm__ volatile (
    80200a0e:	4781                	li	a5,0
    80200a10:	00003717          	auipc	a4,0x3
    80200a14:	5f873703          	ld	a4,1528(a4) # 80204008 <SBI_SHUTDOWN>
    80200a18:	88ba                	mv	a7,a4
    80200a1a:	853e                	mv	a0,a5
    80200a1c:	85be                	mv	a1,a5
    80200a1e:	863e                	mv	a2,a5
    80200a20:	00000073          	ecall
    80200a24:	87aa                	mv	a5,a0
>>>>>>> 716958834b48ecaf18562a46466dd27072437116


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
<<<<<<< HEAD
    80200a32:	8082                	ret
=======
    80200a26:	8082                	ret
>>>>>>> 716958834b48ecaf18562a46466dd27072437116
