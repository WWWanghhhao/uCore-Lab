
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
    80200022:	5c4000ef          	jal	ra,802005e6 <memset>

    cons_init();  // init the console
    80200026:	154000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a0e58593          	addi	a1,a1,-1522 # 80200a38 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a2650513          	addi	a0,a0,-1498 # 80200a58 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	148000ef          	jal	ra,8020018a <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	13a000ef          	jal	ra,80200184 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
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
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
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
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
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

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    __asm__ volatile("nop");

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
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

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	zext.b	a0,a0
    80200180:	0670006f          	j	802009e6 <sbi_console_putchar>

0000000080200184 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
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
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
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
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
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
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
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
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802005e6:	ca01                	beqz	a2,802005f6 <memset+0x10>
    802005e8:	962a                	add	a2,a2,a0
    char *p = s;
    802005ea:	87aa                	mv	a5,a0
        *p ++ = c;
    802005ec:	0785                	addi	a5,a5,1
    802005ee:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802005f2:	fec79de3          	bne	a5,a2,802005ec <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802005f6:	8082                	ret

00000000802005f8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
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
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
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
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
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
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200688:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020068c:	5b7d                	li	s6,-1
    8020068e:	00001a97          	auipc	s5,0x1
    80200692:	9d6a8a93          	addi	s5,s5,-1578 # 80201064 <etext+0x630>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
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
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
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
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009e6:	4781                	li	a5,0
    802009e8:	00003717          	auipc	a4,0x3
    802009ec:	61873703          	ld	a4,1560(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009f0:	88ba                	mv	a7,a4
    802009f2:	852a                	mv	a0,a0
    802009f4:	85be                	mv	a1,a5
    802009f6:	863e                	mv	a2,a5
    802009f8:	00000073          	ecall
    802009fc:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
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

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
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


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a32:	8082                	ret
