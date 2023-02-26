
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 9e 00 00 00       	call   f01000dc <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
f0100046:	8d 45 14             	lea    0x14(%ebp),%eax
f0100049:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010004c:	ff 75 0c             	pushl  0xc(%ebp)
f010004f:	ff 75 08             	pushl  0x8(%ebp)
f0100052:	68 60 64 10 f0       	push   $0xf0106460
f0100057:	e8 aa 36 00 00       	call   f0103706 <cprintf>
	vcprintf(fmt, ap);
f010005c:	83 c4 08             	add    $0x8,%esp
f010005f:	ff 75 fc             	pushl  -0x4(%ebp)
f0100062:	ff 75 10             	pushl  0x10(%ebp)
f0100065:	e8 76 36 00 00       	call   f01036e0 <vcprintf>
	cprintf("\n");
f010006a:	c7 04 24 65 76 10 f0 	movl   $0xf0107665,(%esp)
f0100071:	e8 90 36 00 00       	call   f0103706 <cprintf>
	va_end(ap);
f0100076:	83 c4 10             	add    $0x10,%esp
}
f0100079:	c9                   	leave  
f010007a:	c3                   	ret    

f010007b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010007b:	55                   	push   %ebp
f010007c:	89 e5                	mov    %esp,%ebp
f010007e:	53                   	push   %ebx
f010007f:	83 ec 14             	sub    $0x14,%esp
f0100082:	8b 5d 10             	mov    0x10(%ebp),%ebx
	va_list ap;

	if (panicstr)
f0100085:	83 3d 80 fe 1e f0 00 	cmpl   $0x0,0xf01efe80
f010008c:	75 3f                	jne    f01000cd <_panic+0x52>
		goto dead;
	panicstr = fmt;
f010008e:	89 1d 80 fe 1e f0    	mov    %ebx,0xf01efe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100094:	fa                   	cli    
f0100095:	fc                   	cld    

	va_start(ap, fmt);
f0100096:	8d 45 14             	lea    0x14(%ebp),%eax
f0100099:	89 45 f8             	mov    %eax,-0x8(%ebp)
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010009c:	e8 cd 5c 00 00       	call   f0105d6e <cpunum>
f01000a1:	ff 75 0c             	pushl  0xc(%ebp)
f01000a4:	ff 75 08             	pushl  0x8(%ebp)
f01000a7:	50                   	push   %eax
f01000a8:	68 b8 64 10 f0       	push   $0xf01064b8
f01000ad:	e8 54 36 00 00       	call   f0103706 <cprintf>
	vcprintf(fmt, ap);
f01000b2:	83 c4 08             	add    $0x8,%esp
f01000b5:	ff 75 f8             	pushl  -0x8(%ebp)
f01000b8:	53                   	push   %ebx
f01000b9:	e8 22 36 00 00       	call   f01036e0 <vcprintf>
	cprintf("\n");
f01000be:	c7 04 24 65 76 10 f0 	movl   $0xf0107665,(%esp)
f01000c5:	e8 3c 36 00 00       	call   f0103706 <cprintf>
	va_end(ap);
f01000ca:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cd:	83 ec 0c             	sub    $0xc,%esp
f01000d0:	6a 00                	push   $0x0
f01000d2:	e8 ab 07 00 00       	call   f0100882 <monitor>
f01000d7:	83 c4 10             	add    $0x10,%esp
f01000da:	eb f1                	jmp    f01000cd <_panic+0x52>

f01000dc <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000dc:	55                   	push   %ebp
f01000dd:	89 e5                	mov    %esp,%ebp
f01000df:	56                   	push   %esi
f01000e0:	53                   	push   %ebx
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000e1:	e8 73 04 00 00       	call   f0100559 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000e6:	83 ec 08             	sub    $0x8,%esp
f01000e9:	68 ac 1a 00 00       	push   $0x1aac
f01000ee:	68 7a 64 10 f0       	push   $0xf010647a
f01000f3:	e8 0e 36 00 00       	call   f0103706 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000f8:	e8 61 13 00 00       	call   f010145e <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000fd:	e8 e8 2c 00 00       	call   f0102dea <env_init>
	trap_init();
f0100102:	e8 4e 37 00 00       	call   f0103855 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100107:	e8 71 59 00 00       	call   f0105a7d <mp_init>
	lapic_init();
f010010c:	e8 be 5c 00 00       	call   f0105dcf <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100111:	e8 64 35 00 00       	call   f010367a <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100116:	c7 04 24 a0 43 12 f0 	movl   $0xf01243a0,(%esp)
f010011d:	e8 eb 5f 00 00       	call   f010610d <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100122:	83 c4 10             	add    $0x10,%esp
f0100125:	83 3d 88 fe 1e f0 07 	cmpl   $0x7,0xf01efe88
f010012c:	77 16                	ja     f0100144 <i386_init+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010012e:	68 00 70 00 00       	push   $0x7000
f0100133:	68 dc 64 10 f0       	push   $0xf01064dc
f0100138:	6a 52                	push   $0x52
f010013a:	68 95 64 10 f0       	push   $0xf0106495
f010013f:	e8 37 ff ff ff       	call   f010007b <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100144:	83 ec 04             	sub    $0x4,%esp
f0100147:	b8 c6 59 10 f0       	mov    $0xf01059c6,%eax
f010014c:	2d 4c 59 10 f0       	sub    $0xf010594c,%eax
f0100151:	50                   	push   %eax
f0100152:	68 4c 59 10 f0       	push   $0xf010594c
f0100157:	68 00 70 00 f0       	push   $0xf0007000
f010015c:	e8 33 56 00 00       	call   f0105794 <memmove>
f0100161:	be 00 00 00 00       	mov    $0x0,%esi
f0100166:	83 c4 10             	add    $0x10,%esp
f0100169:	eb 6e                	jmp    f01001d9 <i386_init+0xfd>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
f010016b:	e8 fe 5b 00 00       	call   f0105d6e <cpunum>
f0100170:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100177:	29 c2                	sub    %eax,%edx
f0100179:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010017c:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
f0100183:	39 da                	cmp    %ebx,%edx
f0100185:	74 4f                	je     f01001d6 <i386_init+0xfa>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100187:	89 f1                	mov    %esi,%ecx
f0100189:	c1 f9 02             	sar    $0x2,%ecx
f010018c:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f010018f:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100192:	89 c2                	mov    %eax,%edx
f0100194:	c1 e2 05             	shl    $0x5,%edx
f0100197:	29 c2                	sub    %eax,%edx
f0100199:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f010019c:	89 d0                	mov    %edx,%eax
f010019e:	c1 e0 0e             	shl    $0xe,%eax
f01001a1:	29 d0                	sub    %edx,%eax
f01001a3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01001a6:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01001a9:	c1 e0 0f             	shl    $0xf,%eax
f01001ac:	05 00 90 1f f0       	add    $0xf01f9000,%eax
f01001b1:	a3 84 fe 1e f0       	mov    %eax,0xf01efe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001b6:	83 ec 08             	sub    $0x8,%esp
f01001b9:	68 00 70 00 00       	push   $0x7000
f01001be:	0f b6 86 20 00 1f f0 	movzbl -0xfe0ffe0(%esi),%eax
f01001c5:	50                   	push   %eax
f01001c6:	e8 45 5d 00 00       	call   f0105f10 <lapic_startap>
f01001cb:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001ce:	8b 43 04             	mov    0x4(%ebx),%eax
f01001d1:	83 f8 01             	cmp    $0x1,%eax
f01001d4:	75 f8                	jne    f01001ce <i386_init+0xf2>
f01001d6:	83 c6 74             	add    $0x74,%esi
f01001d9:	8d 9e 20 00 1f f0    	lea    -0xfe0ffe0(%esi),%ebx
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001df:	8b 15 c4 03 1f f0    	mov    0xf01f03c4,%edx
f01001e5:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01001ec:	29 d0                	sub    %edx,%eax
f01001ee:	8d 04 82             	lea    (%edx,%eax,4),%eax
f01001f1:	8d 04 85 20 00 1f f0 	lea    -0xfe0ffe0(,%eax,4),%eax
f01001f8:	39 d8                	cmp    %ebx,%eax
f01001fa:	0f 87 6b ff ff ff    	ja     f010016b <i386_init+0x8f>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100200:	83 ec 08             	sub    $0x8,%esp
f0100203:	6a 01                	push   $0x1
f0100205:	68 75 a4 1a f0       	push   $0xf01aa475
f010020a:	e8 88 32 00 00       	call   f0103497 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010020f:	83 c4 08             	add    $0x8,%esp
f0100212:	6a 00                	push   $0x0
f0100214:	68 ae 55 1a f0       	push   $0xf01a55ae
f0100219:	e8 79 32 00 00       	call   f0103497 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f010021e:	e8 d3 00 00 00       	call   f01002f6 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100223:	e8 c3 44 00 00       	call   f01046eb <sched_yield>

f0100228 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100228:	55                   	push   %ebp
f0100229:	89 e5                	mov    %esp,%ebp
f010022b:	83 ec 08             	sub    $0x8,%esp
f010022e:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100233:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100238:	77 12                	ja     f010024c <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010023a:	50                   	push   %eax
f010023b:	68 00 65 10 f0       	push   $0xf0106500
f0100240:	6a 69                	push   $0x69
f0100242:	68 95 64 10 f0       	push   $0xf0106495
f0100247:	e8 2f fe ff ff       	call   f010007b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010024c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100251:	0f 22 d8             	mov    %eax,%cr3
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100254:	e8 15 5b 00 00       	call   f0105d6e <cpunum>
f0100259:	83 ec 08             	sub    $0x8,%esp
f010025c:	50                   	push   %eax
f010025d:	68 a1 64 10 f0       	push   $0xf01064a1
f0100262:	e8 9f 34 00 00       	call   f0103706 <cprintf>

	lapic_init();
f0100267:	e8 63 5b 00 00       	call   f0105dcf <lapic_init>
	env_init_percpu();
f010026c:	e8 4f 2b 00 00       	call   f0102dc0 <env_init_percpu>
	trap_init_percpu();
f0100271:	e8 ba 34 00 00       	call   f0103730 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100276:	e8 f3 5a 00 00       	call   f0105d6e <cpunum>
f010027b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100282:	29 c2                	sub    %eax,%edx
f0100284:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0100287:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010028e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100293:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100297:	c7 04 24 a0 43 12 f0 	movl   $0xf01243a0,(%esp)
f010029e:	e8 6a 5e 00 00       	call   f010610d <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f01002a3:	e8 43 44 00 00       	call   f01046eb <sched_yield>

f01002a8 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002a8:	55                   	push   %ebp
f01002a9:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ab:	ba 84 00 00 00       	mov    $0x84,%edx
f01002b0:	ec                   	in     (%dx),%al
f01002b1:	ec                   	in     (%dx),%al
f01002b2:	ec                   	in     (%dx),%al
f01002b3:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002b4:	c9                   	leave  
f01002b5:	c3                   	ret    

f01002b6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002b6:	55                   	push   %ebp
f01002b7:	89 e5                	mov    %esp,%ebp
f01002b9:	53                   	push   %ebx
f01002ba:	83 ec 04             	sub    $0x4,%esp
f01002bd:	89 c3                	mov    %eax,%ebx
f01002bf:	eb 26                	jmp    f01002e7 <cons_intr+0x31>
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f01002c1:	85 d2                	test   %edx,%edx
f01002c3:	74 22                	je     f01002e7 <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f01002c5:	a1 24 f2 1e f0       	mov    0xf01ef224,%eax
f01002ca:	88 90 20 f0 1e f0    	mov    %dl,-0xfe10fe0(%eax)
f01002d0:	40                   	inc    %eax
f01002d1:	a3 24 f2 1e f0       	mov    %eax,0xf01ef224
		if (cons.wpos == CONSBUFSIZE)
f01002d6:	3d 00 02 00 00       	cmp    $0x200,%eax
f01002db:	75 0a                	jne    f01002e7 <cons_intr+0x31>
			cons.wpos = 0;
f01002dd:	c7 05 24 f2 1e f0 00 	movl   $0x0,0xf01ef224
f01002e4:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002e7:	ff d3                	call   *%ebx
f01002e9:	89 c2                	mov    %eax,%edx
f01002eb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ee:	75 d1                	jne    f01002c1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002f0:	83 c4 04             	add    $0x4,%esp
f01002f3:	5b                   	pop    %ebx
f01002f4:	c9                   	leave  
f01002f5:	c3                   	ret    

f01002f6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002f6:	55                   	push   %ebp
f01002f7:	89 e5                	mov    %esp,%ebp
f01002f9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01002fc:	b8 98 06 10 f0       	mov    $0xf0100698,%eax
f0100301:	e8 b0 ff ff ff       	call   f01002b6 <cons_intr>
}
f0100306:	c9                   	leave  
f0100307:	c3                   	ret    

f0100308 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100308:	55                   	push   %ebp
f0100309:	89 e5                	mov    %esp,%ebp
f010030b:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010030e:	80 3d 04 f0 1e f0 00 	cmpb   $0x0,0xf01ef004
f0100315:	74 0a                	je     f0100321 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100317:	b8 79 06 10 f0       	mov    $0xf0100679,%eax
f010031c:	e8 95 ff ff ff       	call   f01002b6 <cons_intr>
}
f0100321:	c9                   	leave  
f0100322:	c3                   	ret    

f0100323 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100323:	55                   	push   %ebp
f0100324:	89 e5                	mov    %esp,%ebp
f0100326:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100329:	e8 da ff ff ff       	call   f0100308 <serial_intr>
	kbd_intr();
f010032e:	e8 c3 ff ff ff       	call   f01002f6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100333:	a1 20 f2 1e f0       	mov    0xf01ef220,%eax
f0100338:	3b 05 24 f2 1e f0    	cmp    0xf01ef224,%eax
f010033e:	75 07                	jne    f0100347 <cons_getc+0x24>
f0100340:	ba 00 00 00 00       	mov    $0x0,%edx
f0100345:	eb 1e                	jmp    f0100365 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100347:	0f b6 90 20 f0 1e f0 	movzbl -0xfe10fe0(%eax),%edx
f010034e:	40                   	inc    %eax
f010034f:	a3 20 f2 1e f0       	mov    %eax,0xf01ef220
		if (cons.rpos == CONSBUFSIZE)
f0100354:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100359:	75 0a                	jne    f0100365 <cons_getc+0x42>
			cons.rpos = 0;
f010035b:	c7 05 20 f2 1e f0 00 	movl   $0x0,0xf01ef220
f0100362:	00 00 00 
		return c;
	}
	return 0;
}
f0100365:	89 d0                	mov    %edx,%eax
f0100367:	c9                   	leave  
f0100368:	c3                   	ret    

f0100369 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100369:	55                   	push   %ebp
f010036a:	89 e5                	mov    %esp,%ebp
f010036c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010036f:	e8 af ff ff ff       	call   f0100323 <cons_getc>
f0100374:	85 c0                	test   %eax,%eax
f0100376:	74 f7                	je     f010036f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100378:	c9                   	leave  
f0100379:	c3                   	ret    

f010037a <iscons>:

int
iscons(int fdnum)
{
f010037a:	55                   	push   %ebp
f010037b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010037d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100382:	c9                   	leave  
f0100383:	c3                   	ret    

f0100384 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100384:	55                   	push   %ebp
f0100385:	89 e5                	mov    %esp,%ebp
f0100387:	57                   	push   %edi
f0100388:	56                   	push   %esi
f0100389:	53                   	push   %ebx
f010038a:	83 ec 0c             	sub    $0xc,%esp
f010038d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100390:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100395:	be fd 03 00 00       	mov    $0x3fd,%esi
f010039a:	eb 06                	jmp    f01003a2 <cons_putc+0x1e>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010039c:	e8 07 ff ff ff       	call   f01002a8 <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003a1:	43                   	inc    %ebx
f01003a2:	89 f2                	mov    %esi,%edx
f01003a4:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a5:	a8 20                	test   $0x20,%al
f01003a7:	75 08                	jne    f01003b1 <cons_putc+0x2d>
f01003a9:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003af:	75 eb                	jne    f010039c <cons_putc+0x18>
f01003b1:	0f b6 7d f0          	movzbl -0x10(%ebp),%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003ba:	89 f8                	mov    %edi,%eax
f01003bc:	ee                   	out    %al,(%dx)
f01003bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c2:	be 79 03 00 00       	mov    $0x379,%esi
f01003c7:	eb 06                	jmp    f01003cf <cons_putc+0x4b>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01003c9:	e8 da fe ff ff       	call   f01002a8 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ce:	43                   	inc    %ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cf:	89 f2                	mov    %esi,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	84 c0                	test   %al,%al
f01003d4:	78 08                	js     f01003de <cons_putc+0x5a>
f01003d6:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003dc:	75 eb                	jne    f01003c9 <cons_putc+0x45>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003de:	ba 78 03 00 00       	mov    $0x378,%edx
f01003e3:	89 f8                	mov    %edi,%eax
f01003e5:	ee                   	out    %al,(%dx)
f01003e6:	b0 0d                	mov    $0xd,%al
f01003e8:	b2 7a                	mov    $0x7a,%dl
f01003ea:	ee                   	out    %al,(%dx)
f01003eb:	b0 08                	mov    $0x8,%al
f01003ed:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003ee:	f7 45 f0 00 ff ff ff 	testl  $0xffffff00,-0x10(%ebp)
f01003f5:	75 07                	jne    f01003fe <cons_putc+0x7a>
		c |= 0x0700;
f01003f7:	81 4d f0 00 07 00 00 	orl    $0x700,-0x10(%ebp)

	switch (c & 0xff) {
f01003fe:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
f0100402:	83 f8 09             	cmp    $0x9,%eax
f0100405:	74 78                	je     f010047f <cons_putc+0xfb>
f0100407:	83 f8 09             	cmp    $0x9,%eax
f010040a:	7f 0b                	jg     f0100417 <cons_putc+0x93>
f010040c:	83 f8 08             	cmp    $0x8,%eax
f010040f:	0f 85 9e 00 00 00    	jne    f01004b3 <cons_putc+0x12f>
f0100415:	eb 10                	jmp    f0100427 <cons_putc+0xa3>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	74 38                	je     f0100454 <cons_putc+0xd0>
f010041c:	83 f8 0d             	cmp    $0xd,%eax
f010041f:	0f 85 8e 00 00 00    	jne    f01004b3 <cons_putc+0x12f>
f0100425:	eb 35                	jmp    f010045c <cons_putc+0xd8>
	case '\b':
		if (crt_pos > 0) {
f0100427:	66 a1 10 f0 1e f0    	mov    0xf01ef010,%ax
f010042d:	66 85 c0             	test   %ax,%ax
f0100430:	0f 84 e6 00 00 00    	je     f010051c <cons_putc+0x198>
			crt_pos--;
f0100436:	48                   	dec    %eax
f0100437:	66 a3 10 f0 1e f0    	mov    %ax,0xf01ef010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010043d:	0f b7 c0             	movzwl %ax,%eax
f0100440:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100443:	b2 00                	mov    $0x0,%dl
f0100445:	83 ca 20             	or     $0x20,%edx
f0100448:	8b 0d 0c f0 1e f0    	mov    0xf01ef00c,%ecx
f010044e:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100452:	eb 7c                	jmp    f01004d0 <cons_putc+0x14c>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100454:	66 83 05 10 f0 1e f0 	addw   $0x50,0xf01ef010
f010045b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010045c:	66 8b 1d 10 f0 1e f0 	mov    0xf01ef010,%bx
f0100463:	b9 50 00 00 00       	mov    $0x50,%ecx
f0100468:	ba 00 00 00 00       	mov    $0x0,%edx
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 f7 f1             	div    %cx
f0100472:	89 d8                	mov    %ebx,%eax
f0100474:	66 29 d0             	sub    %dx,%ax
f0100477:	66 a3 10 f0 1e f0    	mov    %ax,0xf01ef010
f010047d:	eb 51                	jmp    f01004d0 <cons_putc+0x14c>
		break;
	case '\t':
		cons_putc(' ');
f010047f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100484:	e8 fb fe ff ff       	call   f0100384 <cons_putc>
		cons_putc(' ');
f0100489:	b8 20 00 00 00       	mov    $0x20,%eax
f010048e:	e8 f1 fe ff ff       	call   f0100384 <cons_putc>
		cons_putc(' ');
f0100493:	b8 20 00 00 00       	mov    $0x20,%eax
f0100498:	e8 e7 fe ff ff       	call   f0100384 <cons_putc>
		cons_putc(' ');
f010049d:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a2:	e8 dd fe ff ff       	call   f0100384 <cons_putc>
		cons_putc(' ');
f01004a7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ac:	e8 d3 fe ff ff       	call   f0100384 <cons_putc>
f01004b1:	eb 1d                	jmp    f01004d0 <cons_putc+0x14c>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b3:	66 a1 10 f0 1e f0    	mov    0xf01ef010,%ax
f01004b9:	0f b7 c8             	movzwl %ax,%ecx
f01004bc:	8b 15 0c f0 1e f0    	mov    0xf01ef00c,%edx
f01004c2:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01004c5:	66 89 1c 4a          	mov    %bx,(%edx,%ecx,2)
f01004c9:	40                   	inc    %eax
f01004ca:	66 a3 10 f0 1e f0    	mov    %ax,0xf01ef010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004d0:	66 81 3d 10 f0 1e f0 	cmpw   $0x7cf,0xf01ef010
f01004d7:	cf 07 
f01004d9:	76 41                	jbe    f010051c <cons_putc+0x198>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004db:	8b 15 0c f0 1e f0    	mov    0xf01ef00c,%edx
f01004e1:	83 ec 04             	sub    $0x4,%esp
f01004e4:	68 00 0f 00 00       	push   $0xf00
f01004e9:	8d 82 a0 00 00 00    	lea    0xa0(%edx),%eax
f01004ef:	50                   	push   %eax
f01004f0:	52                   	push   %edx
f01004f1:	e8 9e 52 00 00       	call   f0105794 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004f6:	8b 15 0c f0 1e f0    	mov    0xf01ef00c,%edx
f01004fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 84 42 00 0f 00 	movw   $0x720,0xf00(%edx,%eax,2)
f010050b:	00 20 07 
f010050e:	40                   	inc    %eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050f:	83 f8 50             	cmp    $0x50,%eax
f0100512:	75 f0                	jne    f0100504 <cons_putc+0x180>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100514:	66 83 2d 10 f0 1e f0 	subw   $0x50,0xf01ef010
f010051b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010051c:	8b 35 08 f0 1e f0    	mov    0xf01ef008,%esi
f0100522:	89 f3                	mov    %esi,%ebx
f0100524:	b0 0e                	mov    $0xe,%al
f0100526:	89 f2                	mov    %esi,%edx
f0100528:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100529:	66 8b 0d 10 f0 1e f0 	mov    0xf01ef010,%cx
f0100530:	46                   	inc    %esi
f0100531:	0f b6 c5             	movzbl %ch,%eax
f0100534:	89 f2                	mov    %esi,%edx
f0100536:	ee                   	out    %al,(%dx)
f0100537:	b0 0f                	mov    $0xf,%al
f0100539:	89 da                	mov    %ebx,%edx
f010053b:	ee                   	out    %al,(%dx)
f010053c:	88 c8                	mov    %cl,%al
f010053e:	89 f2                	mov    %esi,%edx
f0100540:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100541:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100544:	5b                   	pop    %ebx
f0100545:	5e                   	pop    %esi
f0100546:	5f                   	pop    %edi
f0100547:	c9                   	leave  
f0100548:	c3                   	ret    

f0100549 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100549:	55                   	push   %ebp
f010054a:	89 e5                	mov    %esp,%ebp
f010054c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010054f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100552:	e8 2d fe ff ff       	call   f0100384 <cons_putc>
}
f0100557:	c9                   	leave  
f0100558:	c3                   	ret    

f0100559 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100559:	55                   	push   %ebp
f010055a:	89 e5                	mov    %esp,%ebp
f010055c:	57                   	push   %edi
f010055d:	56                   	push   %esi
f010055e:	53                   	push   %ebx
f010055f:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100562:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100569:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100570:	5a a5 
	if (*cp != 0xA55A) {
f0100572:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100578:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010057c:	74 11                	je     f010058f <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010057e:	c7 05 08 f0 1e f0 b4 	movl   $0x3b4,0xf01ef008
f0100585:	03 00 00 
f0100588:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010058d:	eb 16                	jmp    f01005a5 <cons_init+0x4c>
	} else {
		*cp = was;
f010058f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100596:	c7 05 08 f0 1e f0 d4 	movl   $0x3d4,0xf01ef008
f010059d:	03 00 00 
f01005a0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a5:	8b 1d 08 f0 1e f0    	mov    0xf01ef008,%ebx
f01005ab:	89 d9                	mov    %ebx,%ecx
f01005ad:	b0 0e                	mov    $0xe,%al
f01005af:	89 da                	mov    %ebx,%edx
f01005b1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b2:	8d 7b 01             	lea    0x1(%ebx),%edi

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b5:	89 fa                	mov    %edi,%edx
f01005b7:	ec                   	in     (%dx),%al
f01005b8:	0f b6 c0             	movzbl %al,%eax
f01005bb:	89 c3                	mov    %eax,%ebx
f01005bd:	c1 e3 08             	shl    $0x8,%ebx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c0:	b0 0f                	mov    $0xf,%al
f01005c2:	89 ca                	mov    %ecx,%edx
f01005c4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c5:	89 fa                	mov    %edi,%edx
f01005c7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c8:	89 35 0c f0 1e f0    	mov    %esi,0xf01ef00c
	crt_pos = pos;
f01005ce:	0f b6 c0             	movzbl %al,%eax
f01005d1:	09 d8                	or     %ebx,%eax
f01005d3:	66 a3 10 f0 1e f0    	mov    %ax,0xf01ef010

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01005d9:	e8 18 fd ff ff       	call   f01002f6 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01005de:	83 ec 0c             	sub    $0xc,%esp
f01005e1:	0f b7 05 90 43 12 f0 	movzwl 0xf0124390,%eax
f01005e8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01005ed:	50                   	push   %eax
f01005ee:	e8 09 30 00 00       	call   f01035fc <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f3:	b0 00                	mov    $0x0,%al
f01005f5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005fa:	89 da                	mov    %ebx,%edx
f01005fc:	ee                   	out    %al,(%dx)
f01005fd:	b0 80                	mov    $0x80,%al
f01005ff:	b2 fb                	mov    $0xfb,%dl
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b0 0c                	mov    $0xc,%al
f0100604:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100609:	89 ca                	mov    %ecx,%edx
f010060b:	ee                   	out    %al,(%dx)
f010060c:	b0 00                	mov    $0x0,%al
f010060e:	b2 f9                	mov    $0xf9,%dl
f0100610:	ee                   	out    %al,(%dx)
f0100611:	b0 03                	mov    $0x3,%al
f0100613:	b2 fb                	mov    $0xfb,%dl
f0100615:	ee                   	out    %al,(%dx)
f0100616:	b0 00                	mov    $0x0,%al
f0100618:	b2 fc                	mov    $0xfc,%dl
f010061a:	ee                   	out    %al,(%dx)
f010061b:	b0 01                	mov    $0x1,%al
f010061d:	b2 f9                	mov    $0xf9,%dl
f010061f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100620:	b2 fd                	mov    $0xfd,%dl
f0100622:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100623:	83 c4 10             	add    $0x10,%esp
f0100626:	3c ff                	cmp    $0xff,%al
f0100628:	0f 95 45 ef          	setne  -0x11(%ebp)
f010062c:	8a 45 ef             	mov    -0x11(%ebp),%al
f010062f:	a2 04 f0 1e f0       	mov    %al,0xf01ef004
f0100634:	89 da                	mov    %ebx,%edx
f0100636:	ec                   	in     (%dx),%al
f0100637:	89 ca                	mov    %ecx,%edx
f0100639:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010063a:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f010063e:	74 21                	je     f0100661 <cons_init+0x108>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100640:	83 ec 0c             	sub    $0xc,%esp
f0100643:	0f b7 05 90 43 12 f0 	movzwl 0xf0124390,%eax
f010064a:	25 ef ff 00 00       	and    $0xffef,%eax
f010064f:	50                   	push   %eax
f0100650:	e8 a7 2f 00 00       	call   f01035fc <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100655:	83 c4 10             	add    $0x10,%esp
f0100658:	80 3d 04 f0 1e f0 00 	cmpb   $0x0,0xf01ef004
f010065f:	75 10                	jne    f0100671 <cons_init+0x118>
		cprintf("Serial port does not exist!\n");
f0100661:	83 ec 0c             	sub    $0xc,%esp
f0100664:	68 24 65 10 f0       	push   $0xf0106524
f0100669:	e8 98 30 00 00       	call   f0103706 <cprintf>
f010066e:	83 c4 10             	add    $0x10,%esp
}
f0100671:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100674:	5b                   	pop    %ebx
f0100675:	5e                   	pop    %esi
f0100676:	5f                   	pop    %edi
f0100677:	c9                   	leave  
f0100678:	c3                   	ret    

f0100679 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100681:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100682:	a8 01                	test   $0x1,%al
f0100684:	75 07                	jne    f010068d <serial_proc_data+0x14>
f0100686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010068b:	eb 09                	jmp    f0100696 <serial_proc_data+0x1d>
f010068d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100692:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100693:	0f b6 c0             	movzbl %al,%eax
}
f0100696:	c9                   	leave  
f0100697:	c3                   	ret    

f0100698 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100698:	55                   	push   %ebp
f0100699:	89 e5                	mov    %esp,%ebp
f010069b:	53                   	push   %ebx
f010069c:	83 ec 04             	sub    $0x4,%esp
f010069f:	ba 64 00 00 00       	mov    $0x64,%edx
f01006a4:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01006a5:	0f b6 c0             	movzbl %al,%eax
f01006a8:	a8 01                	test   $0x1,%al
f01006aa:	0f 84 e0 00 00 00    	je     f0100790 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01006b0:	a8 20                	test   $0x20,%al
f01006b2:	0f 85 d8 00 00 00    	jne    f0100790 <kbd_proc_data+0xf8>
f01006b8:	b2 60                	mov    $0x60,%dl
		return -1;

	data = inb(KBDATAP);
f01006ba:	ec                   	in     (%dx),%al
f01006bb:	88 c2                	mov    %al,%dl

	if (data == 0xE0) {
f01006bd:	3c e0                	cmp    $0xe0,%al
f01006bf:	75 11                	jne    f01006d2 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f01006c1:	83 0d 00 f0 1e f0 40 	orl    $0x40,0xf01ef000
f01006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006cd:	e9 c3 00 00 00       	jmp    f0100795 <kbd_proc_data+0xfd>
		return 0;
	} else if (data & 0x80) {
f01006d2:	84 c0                	test   %al,%al
f01006d4:	79 30                	jns    f0100706 <kbd_proc_data+0x6e>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006d6:	8b 0d 00 f0 1e f0    	mov    0xf01ef000,%ecx
f01006dc:	f6 c1 40             	test   $0x40,%cl
f01006df:	75 03                	jne    f01006e4 <kbd_proc_data+0x4c>
f01006e1:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01006e4:	0f b6 c2             	movzbl %dl,%eax
f01006e7:	8a 80 60 65 10 f0    	mov    -0xfef9aa0(%eax),%al
f01006ed:	83 c8 40             	or     $0x40,%eax
f01006f0:	0f b6 c0             	movzbl %al,%eax
f01006f3:	f7 d0                	not    %eax
f01006f5:	21 c8                	and    %ecx,%eax
f01006f7:	a3 00 f0 1e f0       	mov    %eax,0xf01ef000
f01006fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100701:	e9 8f 00 00 00       	jmp    f0100795 <kbd_proc_data+0xfd>
		return 0;
	} else if (shift & E0ESC) {
f0100706:	a1 00 f0 1e f0       	mov    0xf01ef000,%eax
f010070b:	a8 40                	test   $0x40,%al
f010070d:	74 0b                	je     f010071a <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010070f:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100712:	83 e0 bf             	and    $0xffffffbf,%eax
f0100715:	a3 00 f0 1e f0       	mov    %eax,0xf01ef000
	}

	shift |= shiftcode[data];
f010071a:	0f b6 ca             	movzbl %dl,%ecx
	shift ^= togglecode[data];
f010071d:	0f b6 81 60 65 10 f0 	movzbl -0xfef9aa0(%ecx),%eax
f0100724:	0b 05 00 f0 1e f0    	or     0xf01ef000,%eax
f010072a:	0f b6 91 60 66 10 f0 	movzbl -0xfef99a0(%ecx),%edx
f0100731:	31 c2                	xor    %eax,%edx
f0100733:	89 15 00 f0 1e f0    	mov    %edx,0xf01ef000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100739:	89 d0                	mov    %edx,%eax
f010073b:	83 e0 03             	and    $0x3,%eax
f010073e:	8b 04 85 60 67 10 f0 	mov    -0xfef98a0(,%eax,4),%eax
f0100745:	0f b6 1c 08          	movzbl (%eax,%ecx,1),%ebx
	if (shift & CAPSLOCK) {
f0100749:	f6 c2 08             	test   $0x8,%dl
f010074c:	74 18                	je     f0100766 <kbd_proc_data+0xce>
		if ('a' <= c && c <= 'z')
f010074e:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100751:	83 f8 19             	cmp    $0x19,%eax
f0100754:	77 05                	ja     f010075b <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f0100756:	83 eb 20             	sub    $0x20,%ebx
f0100759:	eb 0b                	jmp    f0100766 <kbd_proc_data+0xce>
		else if ('A' <= c && c <= 'Z')
f010075b:	8d 43 bf             	lea    -0x41(%ebx),%eax
f010075e:	83 f8 19             	cmp    $0x19,%eax
f0100761:	77 03                	ja     f0100766 <kbd_proc_data+0xce>
			c += 'a' - 'A';
f0100763:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100766:	89 d0                	mov    %edx,%eax
f0100768:	f7 d0                	not    %eax
f010076a:	a8 06                	test   $0x6,%al
f010076c:	75 27                	jne    f0100795 <kbd_proc_data+0xfd>
f010076e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100774:	75 1f                	jne    f0100795 <kbd_proc_data+0xfd>
		cprintf("Rebooting!\n");
f0100776:	83 ec 0c             	sub    $0xc,%esp
f0100779:	68 41 65 10 f0       	push   $0xf0106541
f010077e:	e8 83 2f 00 00       	call   f0103706 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100783:	b0 03                	mov    $0x3,%al
f0100785:	ba 92 00 00 00       	mov    $0x92,%edx
f010078a:	ee                   	out    %al,(%dx)
f010078b:	83 c4 10             	add    $0x10,%esp
f010078e:	eb 05                	jmp    f0100795 <kbd_proc_data+0xfd>
f0100790:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100795:	89 d8                	mov    %ebx,%eax
f0100797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010079a:	c9                   	leave  
f010079b:	c3                   	ret    

f010079c <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010079c:	55                   	push   %ebp
f010079d:	89 e5                	mov    %esp,%ebp
f010079f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007a2:	68 70 67 10 f0       	push   $0xf0106770
f01007a7:	e8 5a 2f 00 00       	call   f0103706 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ac:	83 c4 08             	add    $0x8,%esp
f01007af:	68 0c 00 10 00       	push   $0x10000c
f01007b4:	68 1c 68 10 f0       	push   $0xf010681c
f01007b9:	e8 48 2f 00 00       	call   f0103706 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007be:	83 c4 0c             	add    $0xc,%esp
f01007c1:	68 0c 00 10 00       	push   $0x10000c
f01007c6:	68 0c 00 10 f0       	push   $0xf010000c
f01007cb:	68 44 68 10 f0       	push   $0xf0106844
f01007d0:	e8 31 2f 00 00       	call   f0103706 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007d5:	83 c4 0c             	add    $0xc,%esp
f01007d8:	68 4b 64 10 00       	push   $0x10644b
f01007dd:	68 4b 64 10 f0       	push   $0xf010644b
f01007e2:	68 68 68 10 f0       	push   $0xf0106868
f01007e7:	e8 1a 2f 00 00       	call   f0103706 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ec:	83 c4 0c             	add    $0xc,%esp
f01007ef:	68 00 f0 1e 00       	push   $0x1ef000
f01007f4:	68 00 f0 1e f0       	push   $0xf01ef000
f01007f9:	68 8c 68 10 f0       	push   $0xf010688c
f01007fe:	e8 03 2f 00 00       	call   f0103706 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100803:	83 c4 0c             	add    $0xc,%esp
f0100806:	68 08 10 23 00       	push   $0x231008
f010080b:	68 08 10 23 f0       	push   $0xf0231008
f0100810:	68 b0 68 10 f0       	push   $0xf01068b0
f0100815:	e8 ec 2e 00 00       	call   f0103706 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010081a:	b8 08 10 23 f0       	mov    $0xf0231008,%eax
f010081f:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100824:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100827:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010082c:	79 05                	jns    f0100833 <mon_kerninfo+0x97>
f010082e:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100833:	c1 f8 0a             	sar    $0xa,%eax
f0100836:	50                   	push   %eax
f0100837:	68 d4 68 10 f0       	push   $0xf01068d4
f010083c:	e8 c5 2e 00 00       	call   f0103706 <cprintf>
	return 0;
}
f0100841:	b8 00 00 00 00       	mov    $0x0,%eax
f0100846:	c9                   	leave  
f0100847:	c3                   	ret    

f0100848 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100848:	55                   	push   %ebp
f0100849:	89 e5                	mov    %esp,%ebp
f010084b:	53                   	push   %ebx
f010084c:	83 ec 04             	sub    $0x4,%esp
f010084f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100854:	83 ec 04             	sub    $0x4,%esp
f0100857:	ff b3 a8 69 10 f0    	pushl  -0xfef9658(%ebx)
f010085d:	ff b3 a4 69 10 f0    	pushl  -0xfef965c(%ebx)
f0100863:	68 89 67 10 f0       	push   $0xf0106789
f0100868:	e8 99 2e 00 00       	call   f0103706 <cprintf>
f010086d:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100870:	83 c4 10             	add    $0x10,%esp
f0100873:	83 fb 18             	cmp    $0x18,%ebx
f0100876:	75 dc                	jne    f0100854 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100878:	b8 00 00 00 00       	mov    $0x0,%eax
f010087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100880:	c9                   	leave  
f0100881:	c3                   	ret    

f0100882 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100882:	55                   	push   %ebp
f0100883:	89 e5                	mov    %esp,%ebp
f0100885:	57                   	push   %edi
f0100886:	56                   	push   %esi
f0100887:	53                   	push   %ebx
f0100888:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010088b:	68 00 69 10 f0       	push   $0xf0106900
f0100890:	e8 71 2e 00 00       	call   f0103706 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100895:	c7 04 24 24 69 10 f0 	movl   $0xf0106924,(%esp)
f010089c:	e8 65 2e 00 00       	call   f0103706 <cprintf>

	if (tf != NULL)
f01008a1:	83 c4 10             	add    $0x10,%esp
f01008a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008a8:	74 0e                	je     f01008b8 <monitor+0x36>
		print_trapframe(tf);
f01008aa:	83 ec 0c             	sub    $0xc,%esp
f01008ad:	ff 75 08             	pushl  0x8(%ebp)
f01008b0:	e8 d6 36 00 00       	call   f0103f8b <print_trapframe>
f01008b5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008b8:	83 ec 0c             	sub    $0xc,%esp
f01008bb:	68 92 67 10 f0       	push   $0xf0106792
f01008c0:	e8 4b 4c 00 00       	call   f0105510 <readline>
f01008c5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008c7:	83 c4 10             	add    $0x10,%esp
f01008ca:	85 c0                	test   %eax,%eax
f01008cc:	74 ea                	je     f01008b8 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008ce:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
f01008d5:	bf 00 00 00 00       	mov    $0x0,%edi
f01008da:	eb 04                	jmp    f01008e0 <monitor+0x5e>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008dc:	c6 03 00             	movb   $0x0,(%ebx)
f01008df:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008e0:	8a 03                	mov    (%ebx),%al
f01008e2:	84 c0                	test   %al,%al
f01008e4:	74 5e                	je     f0100944 <monitor+0xc2>
f01008e6:	83 ec 08             	sub    $0x8,%esp
f01008e9:	0f be c0             	movsbl %al,%eax
f01008ec:	50                   	push   %eax
f01008ed:	68 96 67 10 f0       	push   $0xf0106796
f01008f2:	e8 18 4e 00 00       	call   f010570f <strchr>
f01008f7:	83 c4 10             	add    $0x10,%esp
f01008fa:	85 c0                	test   %eax,%eax
f01008fc:	75 de                	jne    f01008dc <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01008fe:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100901:	74 41                	je     f0100944 <monitor+0xc2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100903:	83 ff 0f             	cmp    $0xf,%edi
f0100906:	75 14                	jne    f010091c <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100908:	83 ec 08             	sub    $0x8,%esp
f010090b:	6a 10                	push   $0x10
f010090d:	68 9b 67 10 f0       	push   $0xf010679b
f0100912:	e8 ef 2d 00 00       	call   f0103706 <cprintf>
f0100917:	83 c4 10             	add    $0x10,%esp
f010091a:	eb 9c                	jmp    f01008b8 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010091c:	89 5c bd b4          	mov    %ebx,-0x4c(%ebp,%edi,4)
f0100920:	47                   	inc    %edi
f0100921:	eb 01                	jmp    f0100924 <monitor+0xa2>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100923:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100924:	8a 03                	mov    (%ebx),%al
f0100926:	84 c0                	test   %al,%al
f0100928:	74 b6                	je     f01008e0 <monitor+0x5e>
f010092a:	83 ec 08             	sub    $0x8,%esp
f010092d:	0f be c0             	movsbl %al,%eax
f0100930:	50                   	push   %eax
f0100931:	68 96 67 10 f0       	push   $0xf0106796
f0100936:	e8 d4 4d 00 00       	call   f010570f <strchr>
f010093b:	83 c4 10             	add    $0x10,%esp
f010093e:	85 c0                	test   %eax,%eax
f0100940:	74 e1                	je     f0100923 <monitor+0xa1>
f0100942:	eb 9c                	jmp    f01008e0 <monitor+0x5e>
			buf++;
	}
	argv[argc] = 0;
f0100944:	c7 44 bd b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%edi,4)
f010094b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010094c:	85 ff                	test   %edi,%edi
f010094e:	0f 84 64 ff ff ff    	je     f01008b8 <monitor+0x36>
f0100954:	be 00 00 00 00       	mov    $0x0,%esi
f0100959:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010095e:	83 ec 08             	sub    $0x8,%esp
f0100961:	ff b3 a4 69 10 f0    	pushl  -0xfef965c(%ebx)
f0100967:	ff 75 b4             	pushl  -0x4c(%ebp)
f010096a:	e8 4b 4d 00 00       	call   f01056ba <strcmp>
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	85 c0                	test   %eax,%eax
f0100974:	75 22                	jne    f0100998 <monitor+0x116>
			return commands[i].func(argc, argv, tf);
f0100976:	83 ec 04             	sub    $0x4,%esp
f0100979:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010097c:	ff 75 08             	pushl  0x8(%ebp)
f010097f:	8d 55 b4             	lea    -0x4c(%ebp),%edx
f0100982:	52                   	push   %edx
f0100983:	57                   	push   %edi
f0100984:	ff 14 85 ac 69 10 f0 	call   *-0xfef9654(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010098b:	83 c4 10             	add    $0x10,%esp
f010098e:	85 c0                	test   %eax,%eax
f0100990:	0f 89 22 ff ff ff    	jns    f01008b8 <monitor+0x36>
f0100996:	eb 21                	jmp    f01009b9 <monitor+0x137>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100998:	46                   	inc    %esi
f0100999:	83 c3 0c             	add    $0xc,%ebx
f010099c:	83 fe 02             	cmp    $0x2,%esi
f010099f:	75 bd                	jne    f010095e <monitor+0xdc>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009a1:	83 ec 08             	sub    $0x8,%esp
f01009a4:	ff 75 b4             	pushl  -0x4c(%ebp)
f01009a7:	68 b8 67 10 f0       	push   $0xf01067b8
f01009ac:	e8 55 2d 00 00       	call   f0103706 <cprintf>
f01009b1:	83 c4 10             	add    $0x10,%esp
f01009b4:	e9 ff fe ff ff       	jmp    f01008b8 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009bc:	5b                   	pop    %ebx
f01009bd:	5e                   	pop    %esi
f01009be:	5f                   	pop    %edi
f01009bf:	c9                   	leave  
f01009c0:	c3                   	ret    

f01009c1 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009c1:	55                   	push   %ebp
f01009c2:	89 e5                	mov    %esp,%ebp
f01009c4:	53                   	push   %ebx
f01009c5:	83 ec 30             	sub    $0x30,%esp
	int *ebp = (int *)read_ebp();//like %ebp
f01009c8:	89 eb                	mov    %ebp,%ebx
	cprintf("Stack backtrace:\n");
f01009ca:	68 ce 67 10 f0       	push   $0xf01067ce
f01009cf:	e8 32 2d 00 00       	call   f0103706 <cprintf>
	struct Eipdebuginfo info;//文件string信息，省略结构体定义

	while (ebp != 0x0) {
f01009d4:	83 c4 10             	add    $0x10,%esp
f01009d7:	eb 51                	jmp    f0100a2a <mon_backtrace+0x69>
		// 第一行的当前ebp和栈环境是mon_backtrace的
		cprintf("ebp %8x eip %8x args %08x %08x %08x %08x %08x ", 
f01009d9:	ff 73 18             	pushl  0x18(%ebx)
f01009dc:	ff 73 14             	pushl  0x14(%ebx)
f01009df:	ff 73 10             	pushl  0x10(%ebx)
f01009e2:	ff 73 0c             	pushl  0xc(%ebx)
f01009e5:	ff 73 08             	pushl  0x8(%ebx)
f01009e8:	ff 73 04             	pushl  0x4(%ebx)
f01009eb:	53                   	push   %ebx
f01009ec:	68 4c 69 10 f0       	push   $0xf010694c
f01009f1:	e8 10 2d 00 00       	call   f0103706 <cprintf>
				ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1], &info);
f01009f6:	83 c4 18             	add    $0x18,%esp
f01009f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01009fc:	50                   	push   %eax
f01009fd:	ff 73 04             	pushl  0x4(%ebx)
f0100a00:	e8 3b 44 00 00       	call   f0104e40 <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, 
f0100a05:	83 c4 08             	add    $0x8,%esp
f0100a08:	8b 43 04             	mov    0x4(%ebx),%eax
f0100a0b:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0100a0e:	50                   	push   %eax
f0100a0f:	ff 75 ec             	pushl  -0x14(%ebp)
f0100a12:	ff 75 f0             	pushl  -0x10(%ebp)
f0100a15:	ff 75 e8             	pushl  -0x18(%ebp)
f0100a18:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100a1b:	68 e0 67 10 f0       	push   $0xf01067e0
f0100a20:	e8 e1 2c 00 00       	call   f0103706 <cprintf>
				info.eip_fn_name, ebp[1]-info.eip_fn_addr);
		ebp = (int *)ebp[0];
f0100a25:	8b 1b                	mov    (%ebx),%ebx
f0100a27:	83 c4 20             	add    $0x20,%esp
{
	int *ebp = (int *)read_ebp();//like %ebp
	cprintf("Stack backtrace:\n");
	struct Eipdebuginfo info;//文件string信息，省略结构体定义

	while (ebp != 0x0) {
f0100a2a:	85 db                	test   %ebx,%ebx
f0100a2c:	75 ab                	jne    f01009d9 <mon_backtrace+0x18>
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, 
				info.eip_fn_name, ebp[1]-info.eip_fn_addr);
		ebp = (int *)ebp[0];
	}
	return 0;
}
f0100a2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a36:	c9                   	leave  
f0100a37:	c3                   	ret    

f0100a38 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100a38:	55                   	push   %ebp
f0100a39:	89 e5                	mov    %esp,%ebp
f0100a3b:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a3d:	83 3d 28 f2 1e f0 00 	cmpl   $0x0,0xf01ef228
f0100a44:	75 0f                	jne    f0100a55 <boot_alloc+0x1d>
		extern char end[];							
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a46:	b8 07 20 23 f0       	mov    $0xf0232007,%eax
f0100a4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a50:	a3 28 f2 1e f0       	mov    %eax,0xf01ef228
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a55:	a1 28 f2 1e f0       	mov    0xf01ef228,%eax
	nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100a5a:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100a61:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a67:	89 15 28 f2 1e f0    	mov    %edx,0xf01ef228
	return result;
}
f0100a6d:	c9                   	leave  
f0100a6e:	c3                   	ret    

f0100a6f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100a6f:	55                   	push   %ebp
f0100a70:	89 e5                	mov    %esp,%ebp
f0100a72:	57                   	push   %edi
f0100a73:	56                   	push   %esi
f0100a74:	53                   	push   %ebx
f0100a75:	83 ec 04             	sub    $0x4,%esp
f0100a78:	8b 3d 30 f2 1e f0    	mov    0xf01ef230,%edi
				pages[i].pp_link = NULL;
		}else if(i == MPENTRY_PADDR / PGSIZE){
			pages[i].pp_ref = 1;
			pages[i].pp_link = NULL;
		}
		else if(i>=1 && i<npages_basemem)
f0100a7e:	a1 2c f2 1e f0       	mov    0xf01ef22c,%eax
f0100a83:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a8b:	be 00 00 00 00       	mov    $0x0,%esi
f0100a90:	e9 e0 00 00 00       	jmp    f0100b75 <page_init+0x106>
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
		if(i == 0)
f0100a95:	85 db                	test   %ebx,%ebx
f0100a97:	75 1b                	jne    f0100ab4 <page_init+0x45>
		{	pages[i].pp_ref = 1;
f0100a99:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100a9e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
				pages[i].pp_link = NULL;
f0100aa4:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100aa9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100aaf:	e9 bd 00 00 00       	jmp    f0100b71 <page_init+0x102>
		}else if(i == MPENTRY_PADDR / PGSIZE){
f0100ab4:	83 fb 07             	cmp    $0x7,%ebx
f0100ab7:	75 1c                	jne    f0100ad5 <page_init+0x66>
			pages[i].pp_ref = 1;
f0100ab9:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100abe:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			pages[i].pp_link = NULL;
f0100ac4:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100ac9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100ad0:	e9 9c 00 00 00       	jmp    f0100b71 <page_init+0x102>
		}
		else if(i>=1 && i<npages_basemem)
f0100ad5:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100ad8:	73 1e                	jae    f0100af8 <page_init+0x89>
		{
			pages[i].pp_ref = 0;
f0100ada:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100adf:	66 c7 44 06 04 00 00 	movw   $0x0,0x4(%esi,%eax,1)
			pages[i].pp_link = page_free_list; 
f0100ae6:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100aeb:	89 3c 06             	mov    %edi,(%esi,%eax,1)
			page_free_list = &pages[i];
f0100aee:	89 f7                	mov    %esi,%edi
f0100af0:	03 3d 90 fe 1e f0    	add    0xf01efe90,%edi
f0100af6:	eb 79                	jmp    f0100b71 <page_init+0x102>
		}
		else if(i>=IOPHYSMEM/PGSIZE && i< EXTPHYSMEM/PGSIZE )
f0100af8:	8d 83 60 ff ff ff    	lea    -0xa0(%ebx),%eax
f0100afe:	83 f8 5f             	cmp    $0x5f,%eax
f0100b01:	77 1a                	ja     f0100b1d <page_init+0xae>
		{
			pages[i].pp_ref = 1;
f0100b03:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b08:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
			pages[i].pp_link = NULL;
f0100b0f:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b14:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
f0100b1b:	eb 54                	jmp    f0100b71 <page_init+0x102>
		}
		else if( i >= EXTPHYSMEM / PGSIZE && 
f0100b1d:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0100b23:	76 30                	jbe    f0100b55 <page_init+0xe6>
f0100b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b2a:	e8 09 ff ff ff       	call   f0100a38 <boot_alloc>
f0100b2f:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b34:	c1 e8 0c             	shr    $0xc,%eax
f0100b37:	39 c3                	cmp    %eax,%ebx
f0100b39:	73 1a                	jae    f0100b55 <page_init+0xe6>
				i < ( (int)(boot_alloc(0)) - KERNBASE)/PGSIZE)
		{
			pages[i].pp_ref = 1;
f0100b3b:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b40:	66 c7 44 30 04 01 00 	movw   $0x1,0x4(%eax,%esi,1)
			pages[i].pp_link =NULL;
f0100b47:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b4c:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
f0100b53:	eb 1c                	jmp    f0100b71 <page_init+0x102>
		}
		else
		{
			pages[i].pp_ref = 0;
f0100b55:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b5a:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
			pages[i].pp_link = page_free_list;
f0100b61:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
f0100b66:	89 3c 30             	mov    %edi,(%eax,%esi,1)
			page_free_list = &pages[i];
f0100b69:	89 f7                	mov    %esi,%edi
f0100b6b:	03 3d 90 fe 1e f0    	add    0xf01efe90,%edi
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++)
f0100b71:	43                   	inc    %ebx
f0100b72:	83 c6 08             	add    $0x8,%esi
f0100b75:	3b 1d 88 fe 1e f0    	cmp    0xf01efe88,%ebx
f0100b7b:	0f 82 14 ff ff ff    	jb     f0100a95 <page_init+0x26>
f0100b81:	89 3d 30 f2 1e f0    	mov    %edi,0xf01ef230
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

}
f0100b87:	83 c4 04             	add    $0x4,%esp
f0100b8a:	5b                   	pop    %ebx
f0100b8b:	5e                   	pop    %esi
f0100b8c:	5f                   	pop    %edi
f0100b8d:	c9                   	leave  
f0100b8e:	c3                   	ret    

f0100b8f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100b8f:	55                   	push   %ebp
f0100b90:	89 e5                	mov    %esp,%ebp
f0100b92:	83 ec 08             	sub    $0x8,%esp
f0100b95:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100b98:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f0100b9d:	75 05                	jne    f0100ba4 <page_free+0x15>
f0100b9f:	83 3a 00             	cmpl   $0x0,(%edx)
f0100ba2:	74 17                	je     f0100bbb <page_free+0x2c>
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL\n");
f0100ba4:	83 ec 04             	sub    $0x4,%esp
f0100ba7:	68 bc 69 10 f0       	push   $0xf01069bc
f0100bac:	68 89 01 00 00       	push   $0x189
f0100bb1:	68 85 73 10 f0       	push   $0xf0107385
f0100bb6:	e8 c0 f4 ff ff       	call   f010007b <_panic>
	}
	pp->pp_link = page_free_list;
f0100bbb:	a1 30 f2 1e f0       	mov    0xf01ef230,%eax
f0100bc0:	89 02                	mov    %eax,(%edx)
	page_free_list = pp;
f0100bc2:	89 15 30 f2 1e f0    	mov    %edx,0xf01ef230
}
f0100bc8:	c9                   	leave  
f0100bc9:	c3                   	ret    

f0100bca <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100bca:	55                   	push   %ebp
f0100bcb:	89 e5                	mov    %esp,%ebp
f0100bcd:	83 ec 08             	sub    $0x8,%esp
f0100bd0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100bd3:	8b 42 04             	mov    0x4(%edx),%eax
f0100bd6:	48                   	dec    %eax
f0100bd7:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100bdb:	66 85 c0             	test   %ax,%ax
f0100bde:	75 0c                	jne    f0100bec <page_decref+0x22>
		page_free(pp);
f0100be0:	83 ec 0c             	sub    $0xc,%esp
f0100be3:	52                   	push   %edx
f0100be4:	e8 a6 ff ff ff       	call   f0100b8f <page_free>
f0100be9:	83 c4 10             	add    $0x10,%esp
}
f0100bec:	c9                   	leave  
f0100bed:	c3                   	ret    

f0100bee <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100bee:	55                   	push   %ebp
f0100bef:	89 e5                	mov    %esp,%ebp
f0100bf1:	53                   	push   %ebx
f0100bf2:	83 ec 04             	sub    $0x4,%esp
f0100bf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100bf8:	e8 71 51 00 00       	call   f0105d6e <cpunum>
f0100bfd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100c04:	29 c2                	sub    %eax,%edx
f0100c06:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0100c09:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f0100c10:	00 
f0100c11:	74 20                	je     f0100c33 <tlb_invalidate+0x45>
f0100c13:	e8 56 51 00 00       	call   f0105d6e <cpunum>
f0100c18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100c1f:	29 c2                	sub    %eax,%edx
f0100c21:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0100c24:	8b 14 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%edx
f0100c2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c2e:	39 42 60             	cmp    %eax,0x60(%edx)
f0100c31:	75 03                	jne    f0100c36 <tlb_invalidate+0x48>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100c33:	0f 01 3b             	invlpg (%ebx)
		invlpg(va);
}
f0100c36:	83 c4 04             	add    $0x4,%esp
f0100c39:	5b                   	pop    %ebx
f0100c3a:	c9                   	leave  
f0100c3b:	c3                   	ret    

f0100c3c <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c3c:	55                   	push   %ebp
f0100c3d:	89 e5                	mov    %esp,%ebp
f0100c3f:	56                   	push   %esi
f0100c40:	53                   	push   %ebx
f0100c41:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c43:	83 ec 0c             	sub    $0xc,%esp
f0100c46:	50                   	push   %eax
f0100c47:	e8 84 29 00 00       	call   f01035d0 <mc146818_read>
f0100c4c:	89 c3                	mov    %eax,%ebx
f0100c4e:	8d 46 01             	lea    0x1(%esi),%eax
f0100c51:	89 04 24             	mov    %eax,(%esp)
f0100c54:	e8 77 29 00 00       	call   f01035d0 <mc146818_read>
f0100c59:	c1 e0 08             	shl    $0x8,%eax
f0100c5c:	09 c3                	or     %eax,%ebx
}
f0100c5e:	89 d8                	mov    %ebx,%eax
f0100c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c63:	5b                   	pop    %ebx
f0100c64:	5e                   	pop    %esi
f0100c65:	c9                   	leave  
f0100c66:	c3                   	ret    

f0100c67 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100c67:	55                   	push   %ebp
f0100c68:	89 e5                	mov    %esp,%ebp
f0100c6a:	56                   	push   %esi
f0100c6b:	53                   	push   %ebx
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100c6c:	b8 15 00 00 00       	mov    $0x15,%eax
f0100c71:	e8 c6 ff ff ff       	call   f0100c3c <nvram_read>
f0100c76:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100c78:	b8 17 00 00 00       	mov    $0x17,%eax
f0100c7d:	e8 ba ff ff ff       	call   f0100c3c <nvram_read>
f0100c82:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100c84:	b8 34 00 00 00       	mov    $0x34,%eax
f0100c89:	e8 ae ff ff ff       	call   f0100c3c <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100c8e:	c1 e0 06             	shl    $0x6,%eax
f0100c91:	74 08                	je     f0100c9b <i386_detect_memory+0x34>
		totalmem = 16 * 1024 + ext16mem;
f0100c93:	8d 90 00 40 00 00    	lea    0x4000(%eax),%edx
f0100c99:	eb 0e                	jmp    f0100ca9 <i386_detect_memory+0x42>
	else if (extmem)
f0100c9b:	85 f6                	test   %esi,%esi
f0100c9d:	75 04                	jne    f0100ca3 <i386_detect_memory+0x3c>
f0100c9f:	89 da                	mov    %ebx,%edx
f0100ca1:	eb 06                	jmp    f0100ca9 <i386_detect_memory+0x42>
		totalmem = 1 * 1024 + extmem;
f0100ca3:	8d 96 00 04 00 00    	lea    0x400(%esi),%edx
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100ca9:	89 d0                	mov    %edx,%eax
f0100cab:	c1 e8 02             	shr    $0x2,%eax
f0100cae:	a3 88 fe 1e f0       	mov    %eax,0xf01efe88
	npages_basemem = basemem / (PGSIZE / 1024);
f0100cb3:	89 d8                	mov    %ebx,%eax
f0100cb5:	c1 e8 02             	shr    $0x2,%eax
f0100cb8:	a3 2c f2 1e f0       	mov    %eax,0xf01ef22c

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100cbd:	89 d0                	mov    %edx,%eax
f0100cbf:	29 d8                	sub    %ebx,%eax
f0100cc1:	50                   	push   %eax
f0100cc2:	53                   	push   %ebx
f0100cc3:	52                   	push   %edx
f0100cc4:	68 fc 69 10 f0       	push   $0xf01069fc
f0100cc9:	e8 38 2a 00 00       	call   f0103706 <cprintf>
f0100cce:	83 c4 10             	add    $0x10,%esp
		totalmem, basemem, totalmem - basemem);
}
f0100cd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100cd4:	5b                   	pop    %ebx
f0100cd5:	5e                   	pop    %esi
f0100cd6:	c9                   	leave  
f0100cd7:	c3                   	ret    

f0100cd8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100cd8:	55                   	push   %ebp
f0100cd9:	89 e5                	mov    %esp,%ebp
f0100cdb:	83 ec 08             	sub    $0x8,%esp
f0100cde:	89 d1                	mov    %edx,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ce0:	c1 ea 16             	shr    $0x16,%edx
f0100ce3:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100ce6:	a8 01                	test   $0x1,%al
f0100ce8:	74 46                	je     f0100d30 <check_va2pa+0x58>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100cea:	89 c2                	mov    %eax,%edx
f0100cec:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cf2:	89 d0                	mov    %edx,%eax
f0100cf4:	c1 e8 0c             	shr    $0xc,%eax
f0100cf7:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0100cfd:	72 15                	jb     f0100d14 <check_va2pa+0x3c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cff:	52                   	push   %edx
f0100d00:	68 dc 64 10 f0       	push   $0xf01064dc
f0100d05:	68 92 03 00 00       	push   $0x392
f0100d0a:	68 85 73 10 f0       	push   $0xf0107385
f0100d0f:	e8 67 f3 ff ff       	call   f010007b <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100d14:	89 c8                	mov    %ecx,%eax
f0100d16:	c1 e8 0c             	shr    $0xc,%eax
f0100d19:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100d1e:	8b 84 82 00 00 00 f0 	mov    -0x10000000(%edx,%eax,4),%eax
f0100d25:	a8 01                	test   $0x1,%al
f0100d27:	74 07                	je     f0100d30 <check_va2pa+0x58>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d2e:	eb 05                	jmp    f0100d35 <check_va2pa+0x5d>
f0100d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100d35:	c9                   	leave  
f0100d36:	c3                   	ret    

f0100d37 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d37:	55                   	push   %ebp
f0100d38:	89 e5                	mov    %esp,%ebp
f0100d3a:	53                   	push   %ebx
f0100d3b:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *res = page_free_list;
f0100d3e:	8b 1d 30 f2 1e f0    	mov    0xf01ef230,%ebx
	if (res == NULL) {
f0100d44:	85 db                	test   %ebx,%ebx
f0100d46:	75 12                	jne    f0100d5a <page_alloc+0x23>
		cprintf("page_alloc: out of free memory\n");
f0100d48:	83 ec 0c             	sub    $0xc,%esp
f0100d4b:	68 38 6a 10 f0       	push   $0xf0106a38
f0100d50:	e8 b1 29 00 00       	call   f0103706 <cprintf>
		return NULL;
f0100d55:	83 c4 10             	add    $0x10,%esp
f0100d58:	eb 5b                	jmp    f0100db5 <page_alloc+0x7e>
	}
	page_free_list = res->pp_link;
f0100d5a:	8b 03                	mov    (%ebx),%eax
f0100d5c:	a3 30 f2 1e f0       	mov    %eax,0xf01ef230
	res->pp_link = NULL;
f0100d61:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100d67:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d6b:	74 48                	je     f0100db5 <page_alloc+0x7e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d6d:	89 d8                	mov    %ebx,%eax
f0100d6f:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0100d75:	c1 f8 03             	sar    $0x3,%eax
f0100d78:	89 c2                	mov    %eax,%edx
f0100d7a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d7d:	89 d0                	mov    %edx,%eax
f0100d7f:	c1 e8 0c             	shr    $0xc,%eax
f0100d82:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0100d88:	72 12                	jb     f0100d9c <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d8a:	52                   	push   %edx
f0100d8b:	68 dc 64 10 f0       	push   $0xf01064dc
f0100d90:	6a 58                	push   $0x58
f0100d92:	68 91 73 10 f0       	push   $0xf0107391
f0100d97:	e8 df f2 ff ff       	call   f010007b <_panic>
		memset(page2kva(res), 0, PGSIZE);
f0100d9c:	83 ec 04             	sub    $0x4,%esp
f0100d9f:	68 00 10 00 00       	push   $0x1000
f0100da4:	6a 00                	push   $0x0
f0100da6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0100dac:	50                   	push   %eax
f0100dad:	e8 92 49 00 00       	call   f0105744 <memset>
f0100db2:	83 c4 10             	add    $0x10,%esp
	}
	return res;
}
f0100db5:	89 d8                	mov    %ebx,%eax
f0100db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100dba:	c9                   	leave  
f0100dbb:	c3                   	ret    

f0100dbc <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	56                   	push   %esi
f0100dc0:	53                   	push   %ebx
	// Fill this function in
	pde_t* ppde = pgdir + PDX(va);
f0100dc1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dc4:	89 f0                	mov    %esi,%eax
f0100dc6:	c1 e8 16             	shr    $0x16,%eax
f0100dc9:	c1 e0 02             	shl    $0x2,%eax
f0100dcc:	89 c3                	mov    %eax,%ebx
f0100dce:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*ppde & PTE_P)) {								
f0100dd1:	f6 03 01             	testb  $0x1,(%ebx)
f0100dd4:	75 2c                	jne    f0100e02 <pgdir_walk+0x46>
		if (create) {
f0100dd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100dda:	74 63                	je     f0100e3f <pgdir_walk+0x83>
			struct PageInfo *pp = page_alloc(1);
f0100ddc:	83 ec 0c             	sub    $0xc,%esp
f0100ddf:	6a 01                	push   $0x1
f0100de1:	e8 51 ff ff ff       	call   f0100d37 <page_alloc>
			if (pp == NULL) {
f0100de6:	83 c4 10             	add    $0x10,%esp
f0100de9:	85 c0                	test   %eax,%eax
f0100deb:	74 52                	je     f0100e3f <pgdir_walk+0x83>
				return NULL;
			}
			pp->pp_ref++;
f0100ded:	66 ff 40 04          	incw   0x4(%eax)
			*ppde = (page2pa(pp)) | PTE_P | PTE_U | PTE_W;	
f0100df1:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0100df7:	c1 f8 03             	sar    $0x3,%eax
f0100dfa:	c1 e0 0c             	shl    $0xc,%eax
f0100dfd:	83 c8 07             	or     $0x7,%eax
f0100e00:	89 03                	mov    %eax,(%ebx)
		} else {
			return NULL;
		}
	}

	return (pte_t *)KADDR(PTE_ADDR(*ppde)) + PTX(va);		
f0100e02:	8b 13                	mov    (%ebx),%edx
f0100e04:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0a:	89 d0                	mov    %edx,%eax
f0100e0c:	c1 e8 0c             	shr    $0xc,%eax
f0100e0f:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0100e15:	72 15                	jb     f0100e2c <pgdir_walk+0x70>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e17:	52                   	push   %edx
f0100e18:	68 dc 64 10 f0       	push   $0xf01064dc
f0100e1d:	68 c2 01 00 00       	push   $0x1c2
f0100e22:	68 85 73 10 f0       	push   $0xf0107385
f0100e27:	e8 4f f2 ff ff       	call   f010007b <_panic>
f0100e2c:	89 f0                	mov    %esi,%eax
f0100e2e:	c1 e8 0a             	shr    $0xa,%eax
f0100e31:	25 fc 0f 00 00       	and    $0xffc,%eax
f0100e36:	8d 84 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%eax
f0100e3d:	eb 05                	jmp    f0100e44 <pgdir_walk+0x88>
f0100e3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e44:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e47:	5b                   	pop    %ebx
f0100e48:	5e                   	pop    %esi
f0100e49:	c9                   	leave  
f0100e4a:	c3                   	ret    

f0100e4b <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0100e4b:	55                   	push   %ebp
f0100e4c:	89 e5                	mov    %esp,%ebp
f0100e4e:	57                   	push   %edi
f0100e4f:	56                   	push   %esi
f0100e50:	53                   	push   %ebx
f0100e51:	83 ec 0c             	sub    $0xc,%esp
f0100e54:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	//cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0100e57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e5a:	03 45 10             	add    0x10(%ebp),%eax
f0100e5d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100e62:	89 c6                	mov    %eax,%esi
f0100e64:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0100e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100e73:	eb 48                	jmp    f0100ebd <user_mem_check+0x72>
	for (uint32_t i = start; i < end; i += PGSIZE) {
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0100e75:	83 ec 04             	sub    $0x4,%esp
f0100e78:	6a 00                	push   $0x0
f0100e7a:	53                   	push   %ebx
f0100e7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e7e:	ff 70 60             	pushl  0x60(%eax)
f0100e81:	e8 36 ff ff ff       	call   f0100dbc <pgdir_walk>
		if ((i >= ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {        
f0100e86:	83 c4 10             	add    $0x10,%esp
f0100e89:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100e8f:	77 10                	ja     f0100ea1 <user_mem_check+0x56>
f0100e91:	85 c0                	test   %eax,%eax
f0100e93:	74 0c                	je     f0100ea1 <user_mem_check+0x56>
f0100e95:	8b 00                	mov    (%eax),%eax
f0100e97:	a8 01                	test   $0x1,%al
f0100e99:	74 06                	je     f0100ea1 <user_mem_check+0x56>
f0100e9b:	21 f8                	and    %edi,%eax
f0100e9d:	39 c7                	cmp    %eax,%edi
f0100e9f:	74 16                	je     f0100eb7 <user_mem_check+0x6c>
			user_mem_check_addr = (i < (uint32_t)va ? (uint32_t)va : i);                
f0100ea1:	89 d8                	mov    %ebx,%eax
f0100ea3:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0100ea6:	73 03                	jae    f0100eab <user_mem_check+0x60>
f0100ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100eab:	a3 34 f2 1e f0       	mov    %eax,0xf01ef234
f0100eb0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0100eb5:	eb 0f                	jmp    f0100ec6 <user_mem_check+0x7b>
{
	// LAB 3: Your code here.
	//cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	for (uint32_t i = start; i < end; i += PGSIZE) {
f0100eb7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100ebd:	39 f3                	cmp    %esi,%ebx
f0100ebf:	72 b4                	jb     f0100e75 <user_mem_check+0x2a>
f0100ec1:	b8 00 00 00 00       	mov    $0x0,%eax
			return -E_FAULT;
		}
	}
	//cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	return 0;
}
f0100ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec9:	5b                   	pop    %ebx
f0100eca:	5e                   	pop    %esi
f0100ecb:	5f                   	pop    %edi
f0100ecc:	c9                   	leave  
f0100ecd:	c3                   	ret    

f0100ece <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0100ece:	55                   	push   %ebp
f0100ecf:	89 e5                	mov    %esp,%ebp
f0100ed1:	53                   	push   %ebx
f0100ed2:	83 ec 04             	sub    $0x4,%esp
f0100ed5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0100ed8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100edb:	83 c8 04             	or     $0x4,%eax
f0100ede:	50                   	push   %eax
f0100edf:	ff 75 10             	pushl  0x10(%ebp)
f0100ee2:	ff 75 0c             	pushl  0xc(%ebp)
f0100ee5:	53                   	push   %ebx
f0100ee6:	e8 60 ff ff ff       	call   f0100e4b <user_mem_check>
f0100eeb:	83 c4 10             	add    $0x10,%esp
f0100eee:	85 c0                	test   %eax,%eax
f0100ef0:	79 21                	jns    f0100f13 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0100ef2:	83 ec 04             	sub    $0x4,%esp
f0100ef5:	ff 35 34 f2 1e f0    	pushl  0xf01ef234
f0100efb:	ff 73 48             	pushl  0x48(%ebx)
f0100efe:	68 58 6a 10 f0       	push   $0xf0106a58
f0100f03:	e8 fe 27 00 00       	call   f0103706 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0100f08:	89 1c 24             	mov    %ebx,(%esp)
f0100f0b:	e8 08 25 00 00       	call   f0103418 <env_destroy>
f0100f10:	83 c4 10             	add    $0x10,%esp
	}
}
f0100f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f16:	c9                   	leave  
f0100f17:	c3                   	ret    

f0100f18 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f18:	55                   	push   %ebp
f0100f19:	89 e5                	mov    %esp,%ebp
f0100f1b:	53                   	push   %ebx
f0100f1c:	83 ec 08             	sub    $0x8,%esp
f0100f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	struct PageInfo *pp;
	pte_t *pte =  pgdir_walk(pgdir, va, 0);			
f0100f22:	6a 00                	push   $0x0
f0100f24:	ff 75 0c             	pushl  0xc(%ebp)
f0100f27:	ff 75 08             	pushl  0x8(%ebp)
f0100f2a:	e8 8d fe ff ff       	call   f0100dbc <pgdir_walk>
f0100f2f:	89 c2                	mov    %eax,%edx
	if (pte == NULL) {
f0100f31:	83 c4 10             	add    $0x10,%esp
f0100f34:	85 c0                	test   %eax,%eax
f0100f36:	74 36                	je     f0100f6e <page_lookup+0x56>
		return NULL;
	}
	if (!(*pte) & PTE_P) {
f0100f38:	8b 00                	mov    (%eax),%eax
f0100f3a:	85 c0                	test   %eax,%eax
f0100f3c:	74 30                	je     f0100f6e <page_lookup+0x56>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f3e:	c1 e8 0c             	shr    $0xc,%eax
f0100f41:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0100f47:	72 14                	jb     f0100f5d <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0100f49:	83 ec 04             	sub    $0x4,%esp
f0100f4c:	68 90 6a 10 f0       	push   $0xf0106a90
f0100f51:	6a 51                	push   $0x51
f0100f53:	68 91 73 10 f0       	push   $0xf0107391
f0100f58:	e8 1e f1 ff ff       	call   f010007b <_panic>
	return &pages[PGNUM(pa)];
f0100f5d:	c1 e0 03             	shl    $0x3,%eax
f0100f60:	03 05 90 fe 1e f0    	add    0xf01efe90,%eax
		return NULL;
	}
	physaddr_t pa = PTE_ADDR(*pte);					
	pp = pa2page(pa);								
	if (pte_store != NULL) {
f0100f66:	85 db                	test   %ebx,%ebx
f0100f68:	74 09                	je     f0100f73 <page_lookup+0x5b>
		*pte_store = pte;
f0100f6a:	89 13                	mov    %edx,(%ebx)
f0100f6c:	eb 05                	jmp    f0100f73 <page_lookup+0x5b>
f0100f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pp;
}
f0100f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f76:	c9                   	leave  
f0100f77:	c3                   	ret    

f0100f78 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	56                   	push   %esi
f0100f7c:	53                   	push   %ebx
f0100f7d:	83 ec 14             	sub    $0x14,%esp
f0100f80:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0100f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f89:	50                   	push   %eax
f0100f8a:	53                   	push   %ebx
f0100f8b:	56                   	push   %esi
f0100f8c:	e8 87 ff ff ff       	call   f0100f18 <page_lookup>
	if (pp == NULL) {
f0100f91:	83 c4 10             	add    $0x10,%esp
f0100f94:	85 c0                	test   %eax,%eax
f0100f96:	74 1f                	je     f0100fb7 <page_remove+0x3f>
		return;
	}
	page_decref(pp);
f0100f98:	83 ec 0c             	sub    $0xc,%esp
f0100f9b:	50                   	push   %eax
f0100f9c:	e8 29 fc ff ff       	call   f0100bca <page_decref>
	*pte_store = 0;
f0100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fa4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0100faa:	83 c4 08             	add    $0x8,%esp
f0100fad:	53                   	push   %ebx
f0100fae:	56                   	push   %esi
f0100faf:	e8 3a fc ff ff       	call   f0100bee <tlb_invalidate>
f0100fb4:	83 c4 10             	add    $0x10,%esp
}
f0100fb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fba:	5b                   	pop    %ebx
f0100fbb:	5e                   	pop    %esi
f0100fbc:	c9                   	leave  
f0100fbd:	c3                   	ret    

f0100fbe <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fbe:	55                   	push   %ebp
f0100fbf:	89 e5                	mov    %esp,%ebp
f0100fc1:	57                   	push   %edi
f0100fc2:	56                   	push   %esi
f0100fc3:	53                   	push   %ebx
f0100fc4:	83 ec 10             	sub    $0x10,%esp
f0100fc7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fca:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100fcd:	6a 01                	push   $0x1
f0100fcf:	ff 75 10             	pushl  0x10(%ebp)
f0100fd2:	57                   	push   %edi
f0100fd3:	e8 e4 fd ff ff       	call   f0100dbc <pgdir_walk>
f0100fd8:	89 c3                	mov    %eax,%ebx
	if (pte == NULL) {
f0100fda:	83 c4 10             	add    $0x10,%esp
f0100fdd:	85 c0                	test   %eax,%eax
f0100fdf:	75 07                	jne    f0100fe8 <page_insert+0x2a>
f0100fe1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100fe6:	eb 41                	jmp    f0101029 <page_insert+0x6b>
		return -E_NO_MEM;
	}
	pp->pp_ref++;										
f0100fe8:	66 ff 46 04          	incw   0x4(%esi)
	if ((*pte) & PTE_P) {								
f0100fec:	f6 00 01             	testb  $0x1,(%eax)
f0100fef:	74 0f                	je     f0101000 <page_insert+0x42>
		page_remove(pgdir, va);
f0100ff1:	83 ec 08             	sub    $0x8,%esp
f0100ff4:	ff 75 10             	pushl  0x10(%ebp)
f0100ff7:	57                   	push   %edi
f0100ff8:	e8 7b ff ff ff       	call   f0100f78 <page_remove>
f0100ffd:	83 c4 10             	add    $0x10,%esp
	}
	physaddr_t pa = page2pa(pp);
	*pte = pa | perm | PTE_P;
f0101000:	89 f0                	mov    %esi,%eax
f0101002:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0101008:	c1 f8 03             	sar    $0x3,%eax
f010100b:	c1 e0 0c             	shl    $0xc,%eax
f010100e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101011:	83 ca 01             	or     $0x1,%edx
f0101014:	09 d0                	or     %edx,%eax
f0101016:	89 03                	mov    %eax,(%ebx)
	pgdir[PDX(va)] |= perm;
f0101018:	8b 45 10             	mov    0x10(%ebp),%eax
f010101b:	c1 e8 16             	shr    $0x16,%eax
f010101e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101021:	09 14 87             	or     %edx,(%edi,%eax,4)
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
	
	return 0;
}
f0101029:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102c:	5b                   	pop    %ebx
f010102d:	5e                   	pop    %esi
f010102e:	5f                   	pop    %edi
f010102f:	c9                   	leave  
f0101030:	c3                   	ret    

f0101031 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101031:	55                   	push   %ebp
f0101032:	89 e5                	mov    %esp,%ebp
f0101034:	57                   	push   %edi
f0101035:	56                   	push   %esi
f0101036:	53                   	push   %ebx
f0101037:	83 ec 0c             	sub    $0xc,%esp
f010103a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010103d:	89 d6                	mov    %edx,%esi
f010103f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function in
	size_t pgs = size / PGSIZE;
f0101042:	89 c8                	mov    %ecx,%eax
f0101044:	c1 e8 0c             	shr    $0xc,%eax
	if (size % PGSIZE != 0) {
f0101047:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		pgs++;
f010104d:	83 f9 01             	cmp    $0x1,%ecx
f0101050:	83 d8 ff             	sbb    $0xffffffff,%eax
f0101053:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101056:	bf 00 00 00 00       	mov    $0x0,%edi
f010105b:	eb 45                	jmp    f01010a2 <boot_map_region+0x71>
	}
	for (int i = 0; i < pgs; i++) {
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f010105d:	83 ec 04             	sub    $0x4,%esp
f0101060:	6a 01                	push   $0x1
f0101062:	56                   	push   %esi
f0101063:	ff 75 ec             	pushl  -0x14(%ebp)
f0101066:	e8 51 fd ff ff       	call   f0100dbc <pgdir_walk>
f010106b:	89 c2                	mov    %eax,%edx
		if (pte == NULL) {
f010106d:	83 c4 10             	add    $0x10,%esp
f0101070:	85 c0                	test   %eax,%eax
f0101072:	75 17                	jne    f010108b <boot_map_region+0x5a>
			panic("boot_map_region(): out of memory\n");
f0101074:	83 ec 04             	sub    $0x4,%esp
f0101077:	68 b0 6a 10 f0       	push   $0xf0106ab0
f010107c:	68 db 01 00 00       	push   $0x1db
f0101081:	68 85 73 10 f0       	push   $0xf0107385
f0101086:	e8 f0 ef ff ff       	call   f010007b <_panic>
		}
		*pte = pa | PTE_P | perm;
f010108b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010108e:	83 c8 01             	or     $0x1,%eax
f0101091:	09 d8                	or     %ebx,%eax
f0101093:	89 02                	mov    %eax,(%edx)
		pa += PGSIZE;
f0101095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		va += PGSIZE;
f010109b:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// Fill this function in
	size_t pgs = size / PGSIZE;
	if (size % PGSIZE != 0) {
		pgs++;
	}
	for (int i = 0; i < pgs; i++) {
f01010a1:	47                   	inc    %edi
f01010a2:	3b 7d f0             	cmp    -0x10(%ebp),%edi
f01010a5:	75 b6                	jne    f010105d <boot_map_region+0x2c>
		}
		*pte = pa | PTE_P | perm;
		pa += PGSIZE;
		va += PGSIZE;
	}
}
f01010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010aa:	5b                   	pop    %ebx
f01010ab:	5e                   	pop    %esi
f01010ac:	5f                   	pop    %edi
f01010ad:	c9                   	leave  
f01010ae:	c3                   	ret    

f01010af <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01010af:	55                   	push   %ebp
f01010b0:	89 e5                	mov    %esp,%ebp
f01010b2:	53                   	push   %ebx
f01010b3:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size,PGSIZE);
f01010b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b9:	05 ff 0f 00 00       	add    $0xfff,%eax
f01010be:	89 c3                	mov    %eax,%ebx
f01010c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(base+size >= MMIOLIM)panic("mmio_map_region: out of memory!\n");
f01010c6:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
f01010cc:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01010cf:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01010d4:	76 17                	jbe    f01010ed <mmio_map_region+0x3e>
f01010d6:	83 ec 04             	sub    $0x4,%esp
f01010d9:	68 d4 6a 10 f0       	push   $0xf0106ad4
f01010de:	68 77 02 00 00       	push   $0x277
f01010e3:	68 85 73 10 f0       	push   $0xf0107385
f01010e8:	e8 8e ef ff ff       	call   f010007b <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD| PTE_PWT | PTE_W);
f01010ed:	83 ec 08             	sub    $0x8,%esp
f01010f0:	6a 1a                	push   $0x1a
f01010f2:	ff 75 08             	pushl  0x8(%ebp)
f01010f5:	89 d9                	mov    %ebx,%ecx
f01010f7:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01010fc:	e8 30 ff ff ff       	call   f0101031 <boot_map_region>
	base += size;
f0101101:	89 d8                	mov    %ebx,%eax
f0101103:	03 05 00 43 12 f0    	add    0xf0124300,%eax
f0101109:	a3 00 43 12 f0       	mov    %eax,0xf0124300
f010110e:	29 d8                	sub    %ebx,%eax
	return (void*)(base-size);
}
f0101110:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101113:	c9                   	leave  
f0101114:	c3                   	ret    

f0101115 <mem_init_mp>:
// Modify mappings in kern_pgdir to support SMP
//   - Map the per-CPU stacks in the region [KSTACKTOP-PTSIZE, KSTACKTOP)
//
static void
mem_init_mp(void)
{
f0101115:	55                   	push   %ebp
f0101116:	89 e5                	mov    %esp,%ebp
f0101118:	56                   	push   %esi
f0101119:	53                   	push   %ebx
f010111a:	be 00 10 1f f0       	mov    $0xf01f1000,%esi
f010111f:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f0101124:	89 f0                	mov    %esi,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101126:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010112c:	77 15                	ja     f0101143 <mem_init_mp+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010112e:	56                   	push   %esi
f010112f:	68 00 65 10 f0       	push   $0xf0106500
f0101134:	68 15 01 00 00       	push   $0x115
f0101139:	68 85 73 10 f0       	push   $0xf0107385
f010113e:	e8 38 ef ff ff       	call   f010007b <_panic>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir,
f0101143:	83 ec 08             	sub    $0x8,%esp
f0101146:	6a 02                	push   $0x2
f0101148:	05 00 00 00 10       	add    $0x10000000,%eax
f010114d:	50                   	push   %eax
f010114e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101153:	89 da                	mov    %ebx,%edx
f0101155:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f010115a:	e8 d2 fe ff ff       	call   f0101031 <boot_map_region>
f010115f:	81 c6 00 80 00 00    	add    $0x8000,%esi
f0101165:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	for(int i = 0; i < NCPU; i++){
f010116b:	83 c4 10             	add    $0x10,%esp
f010116e:	81 fb 00 80 f7 ef    	cmp    $0xeff78000,%ebx
f0101174:	75 ae                	jne    f0101124 <mem_init_mp+0xf>
						KSTKSIZE,
						PADDR(percpu_kstacks[i]),
						PTE_W);
	}

}
f0101176:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101179:	5b                   	pop    %ebx
f010117a:	5e                   	pop    %esi
f010117b:	c9                   	leave  
f010117c:	c3                   	ret    

f010117d <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010117d:	55                   	push   %ebp
f010117e:	89 e5                	mov    %esp,%ebp
f0101180:	57                   	push   %edi
f0101181:	56                   	push   %esi
f0101182:	53                   	push   %ebx
f0101183:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101186:	3c 01                	cmp    $0x1,%al
f0101188:	19 f6                	sbb    %esi,%esi
f010118a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101190:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101191:	8b 0d 30 f2 1e f0    	mov    0xf01ef230,%ecx
f0101197:	85 c9                	test   %ecx,%ecx
f0101199:	75 17                	jne    f01011b2 <check_page_free_list+0x35>
		panic("'page_free_list' is a null pointer!");
f010119b:	83 ec 04             	sub    $0x4,%esp
f010119e:	68 f8 6a 10 f0       	push   $0xf0106af8
f01011a3:	68 c5 02 00 00       	push   $0x2c5
f01011a8:	68 85 73 10 f0       	push   $0xf0107385
f01011ad:	e8 c9 ee ff ff       	call   f010007b <_panic>

	if (only_low_memory) {
f01011b2:	84 c0                	test   %al,%al
f01011b4:	74 4d                	je     f0101203 <check_page_free_list+0x86>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01011b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01011b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01011bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011c2:	8b 1d 90 fe 1e f0    	mov    0xf01efe90,%ebx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01011c8:	89 c8                	mov    %ecx,%eax
f01011ca:	29 d8                	sub    %ebx,%eax
f01011cc:	c1 e0 09             	shl    $0x9,%eax
f01011cf:	c1 e8 16             	shr    $0x16,%eax
f01011d2:	39 c6                	cmp    %eax,%esi
f01011d4:	0f 96 c0             	setbe  %al
f01011d7:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01011da:	8b 54 85 e4          	mov    -0x1c(%ebp,%eax,4),%edx
f01011de:	89 0a                	mov    %ecx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01011e0:	89 4c 85 e4          	mov    %ecx,-0x1c(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011e4:	8b 09                	mov    (%ecx),%ecx
f01011e6:	85 c9                	test   %ecx,%ecx
f01011e8:	75 de                	jne    f01011c8 <check_page_free_list+0x4b>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}						
		*tp[1] = 0;
f01011ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01011ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01011f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011f9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01011fe:	a3 30 f2 1e f0       	mov    %eax,0xf01ef230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101203:	8b 1d 30 f2 1e f0    	mov    0xf01ef230,%ebx
f0101209:	eb 56                	jmp    f0101261 <check_page_free_list+0xe4>
f010120b:	89 d8                	mov    %ebx,%eax
f010120d:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0101213:	c1 f8 03             	sar    $0x3,%eax
f0101216:	89 c2                	mov    %eax,%edx
f0101218:	c1 e2 0c             	shl    $0xc,%edx
		if (PDX(page2pa(pp)) < pdx_limit)
f010121b:	89 d0                	mov    %edx,%eax
f010121d:	c1 e8 16             	shr    $0x16,%eax
f0101220:	39 c6                	cmp    %eax,%esi
f0101222:	76 3b                	jbe    f010125f <check_page_free_list+0xe2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101224:	89 d0                	mov    %edx,%eax
f0101226:	c1 e8 0c             	shr    $0xc,%eax
f0101229:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f010122f:	72 12                	jb     f0101243 <check_page_free_list+0xc6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101231:	52                   	push   %edx
f0101232:	68 dc 64 10 f0       	push   $0xf01064dc
f0101237:	6a 58                	push   $0x58
f0101239:	68 91 73 10 f0       	push   $0xf0107391
f010123e:	e8 38 ee ff ff       	call   f010007b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101243:	83 ec 04             	sub    $0x4,%esp
f0101246:	68 80 00 00 00       	push   $0x80
f010124b:	68 97 00 00 00       	push   $0x97
f0101250:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101256:	50                   	push   %eax
f0101257:	e8 e8 44 00 00       	call   f0105744 <memset>
f010125c:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010125f:	8b 1b                	mov    (%ebx),%ebx
f0101261:	85 db                	test   %ebx,%ebx
f0101263:	75 a6                	jne    f010120b <check_page_free_list+0x8e>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101265:	b8 00 00 00 00       	mov    $0x0,%eax
f010126a:	e8 c9 f7 ff ff       	call   f0100a38 <boot_alloc>
f010126f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101272:	8b 1d 30 f2 1e f0    	mov    0xf01ef230,%ebx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101278:	8b 35 90 fe 1e f0    	mov    0xf01efe90,%esi
		assert(pp < pages + npages);
f010127e:	a1 88 fe 1e f0       	mov    0xf01efe88,%eax
f0101283:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101286:	8d 04 c6             	lea    (%esi,%eax,8),%eax
f0101289:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010128c:	89 f7                	mov    %esi,%edi
f010128e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101295:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010129c:	e9 5f 01 00 00       	jmp    f0101400 <check_page_free_list+0x283>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012a1:	39 f3                	cmp    %esi,%ebx
f01012a3:	73 19                	jae    f01012be <check_page_free_list+0x141>
f01012a5:	68 9f 73 10 f0       	push   $0xf010739f
f01012aa:	68 ab 73 10 f0       	push   $0xf01073ab
f01012af:	68 df 02 00 00       	push   $0x2df
f01012b4:	68 85 73 10 f0       	push   $0xf0107385
f01012b9:	e8 bd ed ff ff       	call   f010007b <_panic>
		assert(pp < pages + npages);
f01012be:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01012c1:	72 19                	jb     f01012dc <check_page_free_list+0x15f>
f01012c3:	68 c0 73 10 f0       	push   $0xf01073c0
f01012c8:	68 ab 73 10 f0       	push   $0xf01073ab
f01012cd:	68 e0 02 00 00       	push   $0x2e0
f01012d2:	68 85 73 10 f0       	push   $0xf0107385
f01012d7:	e8 9f ed ff ff       	call   f010007b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012dc:	89 d8                	mov    %ebx,%eax
f01012de:	29 f8                	sub    %edi,%eax
f01012e0:	a8 07                	test   $0x7,%al
f01012e2:	74 19                	je     f01012fd <check_page_free_list+0x180>
f01012e4:	68 1c 6b 10 f0       	push   $0xf0106b1c
f01012e9:	68 ab 73 10 f0       	push   $0xf01073ab
f01012ee:	68 e1 02 00 00       	push   $0x2e1
f01012f3:	68 85 73 10 f0       	push   $0xf0107385
f01012f8:	e8 7e ed ff ff       	call   f010007b <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012fd:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101300:	89 c2                	mov    %eax,%edx
f0101302:	c1 e2 0c             	shl    $0xc,%edx
f0101305:	75 19                	jne    f0101320 <check_page_free_list+0x1a3>
f0101307:	68 d4 73 10 f0       	push   $0xf01073d4
f010130c:	68 ab 73 10 f0       	push   $0xf01073ab
f0101311:	68 e4 02 00 00       	push   $0x2e4
f0101316:	68 85 73 10 f0       	push   $0xf0107385
f010131b:	e8 5b ed ff ff       	call   f010007b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101320:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101326:	75 19                	jne    f0101341 <check_page_free_list+0x1c4>
f0101328:	68 e5 73 10 f0       	push   $0xf01073e5
f010132d:	68 ab 73 10 f0       	push   $0xf01073ab
f0101332:	68 e5 02 00 00       	push   $0x2e5
f0101337:	68 85 73 10 f0       	push   $0xf0107385
f010133c:	e8 3a ed ff ff       	call   f010007b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101341:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f0101347:	75 19                	jne    f0101362 <check_page_free_list+0x1e5>
f0101349:	68 50 6b 10 f0       	push   $0xf0106b50
f010134e:	68 ab 73 10 f0       	push   $0xf01073ab
f0101353:	68 e6 02 00 00       	push   $0x2e6
f0101358:	68 85 73 10 f0       	push   $0xf0107385
f010135d:	e8 19 ed ff ff       	call   f010007b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101362:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f0101368:	75 19                	jne    f0101383 <check_page_free_list+0x206>
f010136a:	68 fe 73 10 f0       	push   $0xf01073fe
f010136f:	68 ab 73 10 f0       	push   $0xf01073ab
f0101374:	68 e7 02 00 00       	push   $0x2e7
f0101379:	68 85 73 10 f0       	push   $0xf0107385
f010137e:	e8 f8 ec ff ff       	call   f010007b <_panic>
f0101383:	89 d1                	mov    %edx,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101385:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
f010138b:	76 40                	jbe    f01013cd <check_page_free_list+0x250>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010138d:	89 d0                	mov    %edx,%eax
f010138f:	c1 e8 0c             	shr    $0xc,%eax
f0101392:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101395:	77 12                	ja     f01013a9 <check_page_free_list+0x22c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101397:	52                   	push   %edx
f0101398:	68 dc 64 10 f0       	push   $0xf01064dc
f010139d:	6a 58                	push   $0x58
f010139f:	68 91 73 10 f0       	push   $0xf0107391
f01013a4:	e8 d2 ec ff ff       	call   f010007b <_panic>
f01013a9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01013af:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f01013b2:	76 19                	jbe    f01013cd <check_page_free_list+0x250>
f01013b4:	68 74 6b 10 f0       	push   $0xf0106b74
f01013b9:	68 ab 73 10 f0       	push   $0xf01073ab
f01013be:	68 e8 02 00 00       	push   $0x2e8
f01013c3:	68 85 73 10 f0       	push   $0xf0107385
f01013c8:	e8 ae ec ff ff       	call   f010007b <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01013cd:	81 fa 00 70 00 00    	cmp    $0x7000,%edx
f01013d3:	75 19                	jne    f01013ee <check_page_free_list+0x271>
f01013d5:	68 18 74 10 f0       	push   $0xf0107418
f01013da:	68 ab 73 10 f0       	push   $0xf01073ab
f01013df:	68 ea 02 00 00       	push   $0x2ea
f01013e4:	68 85 73 10 f0       	push   $0xf0107385
f01013e9:	e8 8d ec ff ff       	call   f010007b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01013ee:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01013f4:	77 05                	ja     f01013fb <check_page_free_list+0x27e>
			++nfree_basemem;
f01013f6:	ff 45 d8             	incl   -0x28(%ebp)
f01013f9:	eb 03                	jmp    f01013fe <check_page_free_list+0x281>
		else
			++nfree_extmem;
f01013fb:	ff 45 dc             	incl   -0x24(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013fe:	8b 1b                	mov    (%ebx),%ebx
f0101400:	85 db                	test   %ebx,%ebx
f0101402:	0f 85 99 fe ff ff    	jne    f01012a1 <check_page_free_list+0x124>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101408:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010140c:	7f 19                	jg     f0101427 <check_page_free_list+0x2aa>
f010140e:	68 35 74 10 f0       	push   $0xf0107435
f0101413:	68 ab 73 10 f0       	push   $0xf01073ab
f0101418:	68 f2 02 00 00       	push   $0x2f2
f010141d:	68 85 73 10 f0       	push   $0xf0107385
f0101422:	e8 54 ec ff ff       	call   f010007b <_panic>
	assert(nfree_extmem > 0);
f0101427:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010142b:	7f 19                	jg     f0101446 <check_page_free_list+0x2c9>
f010142d:	68 47 74 10 f0       	push   $0xf0107447
f0101432:	68 ab 73 10 f0       	push   $0xf01073ab
f0101437:	68 f3 02 00 00       	push   $0x2f3
f010143c:	68 85 73 10 f0       	push   $0xf0107385
f0101441:	e8 35 ec ff ff       	call   f010007b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101446:	83 ec 0c             	sub    $0xc,%esp
f0101449:	68 bc 6b 10 f0       	push   $0xf0106bbc
f010144e:	e8 b3 22 00 00       	call   f0103706 <cprintf>
f0101453:	83 c4 10             	add    $0x10,%esp
}
f0101456:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101459:	5b                   	pop    %ebx
f010145a:	5e                   	pop    %esi
f010145b:	5f                   	pop    %edi
f010145c:	c9                   	leave  
f010145d:	c3                   	ret    

f010145e <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010145e:	55                   	push   %ebp
f010145f:	89 e5                	mov    %esp,%ebp
f0101461:	57                   	push   %edi
f0101462:	56                   	push   %esi
f0101463:	53                   	push   %ebx
f0101464:	83 ec 4c             	sub    $0x4c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f0101467:	e8 fb f7 ff ff       	call   f0100c67 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);					
f010146c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101471:	e8 c2 f5 ff ff       	call   f0100a38 <boot_alloc>
f0101476:	a3 8c fe 1e f0       	mov    %eax,0xf01efe8c
	memset(kern_pgdir, 0, PGSIZE);
f010147b:	83 ec 04             	sub    $0x4,%esp
f010147e:	68 00 10 00 00       	push   $0x1000
f0101483:	6a 00                	push   $0x0
f0101485:	50                   	push   %eax
f0101486:	e8 b9 42 00 00       	call   f0105744 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010148b:	8b 15 8c fe 1e f0    	mov    0xf01efe8c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101491:	89 d0                	mov    %edx,%eax
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010149c:	77 15                	ja     f01014b3 <mem_init+0x55>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010149e:	52                   	push   %edx
f010149f:	68 00 65 10 f0       	push   $0xf0106500
f01014a4:	68 94 00 00 00       	push   $0x94
f01014a9:	68 85 73 10 f0       	push   $0xf0107385
f01014ae:	e8 c8 eb ff ff       	call   f010007b <_panic>
f01014b3:	05 00 00 00 10       	add    $0x10000000,%eax
f01014b8:	83 c8 05             	or     $0x5,%eax
f01014bb:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);	
f01014c1:	a1 88 fe 1e f0       	mov    0xf01efe88,%eax
f01014c6:	c1 e0 03             	shl    $0x3,%eax
f01014c9:	e8 6a f5 ff ff       	call   f0100a38 <boot_alloc>
f01014ce:	a3 90 fe 1e f0       	mov    %eax,0xf01efe90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01014d3:	83 ec 04             	sub    $0x4,%esp
f01014d6:	8b 15 88 fe 1e f0    	mov    0xf01efe88,%edx
f01014dc:	c1 e2 03             	shl    $0x3,%edx
f01014df:	52                   	push   %edx
f01014e0:	6a 00                	push   $0x0
f01014e2:	50                   	push   %eax
f01014e3:	e8 5c 42 00 00       	call   f0105744 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f01014e8:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01014ed:	e8 46 f5 ff ff       	call   f0100a38 <boot_alloc>
f01014f2:	a3 38 f2 1e f0       	mov    %eax,0xf01ef238
	memset(envs, 0, sizeof(struct Env) * NENV);
f01014f7:	83 c4 0c             	add    $0xc,%esp
f01014fa:	68 00 f0 01 00       	push   $0x1f000
f01014ff:	6a 00                	push   $0x0
f0101501:	50                   	push   %eax
f0101502:	e8 3d 42 00 00       	call   f0105744 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or PADDR(kern_pgdir)
	page_init();
f0101507:	e8 63 f5 ff ff       	call   f0100a6f <page_init>

	check_page_free_list(1);
f010150c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101511:	e8 67 fc ff ff       	call   f010117d <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101516:	83 c4 10             	add    $0x10,%esp
f0101519:	83 3d 90 fe 1e f0 00 	cmpl   $0x0,0xf01efe90
f0101520:	75 17                	jne    f0101539 <mem_init+0xdb>
		panic("'pages' is a null pointer!");
f0101522:	83 ec 04             	sub    $0x4,%esp
f0101525:	68 58 74 10 f0       	push   $0xf0107458
f010152a:	68 06 03 00 00       	push   $0x306
f010152f:	68 85 73 10 f0       	push   $0xf0107385
f0101534:	e8 42 eb ff ff       	call   f010007b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101539:	a1 30 f2 1e f0       	mov    0xf01ef230,%eax
f010153e:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
f0101545:	eb 05                	jmp    f010154c <mem_init+0xee>
		++nfree;
f0101547:	ff 45 b8             	incl   -0x48(%ebp)

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010154a:	8b 00                	mov    (%eax),%eax
f010154c:	85 c0                	test   %eax,%eax
f010154e:	75 f7                	jne    f0101547 <mem_init+0xe9>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101550:	83 ec 0c             	sub    $0xc,%esp
f0101553:	6a 00                	push   $0x0
f0101555:	e8 dd f7 ff ff       	call   f0100d37 <page_alloc>
f010155a:	89 c7                	mov    %eax,%edi
f010155c:	83 c4 10             	add    $0x10,%esp
f010155f:	85 c0                	test   %eax,%eax
f0101561:	75 19                	jne    f010157c <mem_init+0x11e>
f0101563:	68 73 74 10 f0       	push   $0xf0107473
f0101568:	68 ab 73 10 f0       	push   $0xf01073ab
f010156d:	68 0e 03 00 00       	push   $0x30e
f0101572:	68 85 73 10 f0       	push   $0xf0107385
f0101577:	e8 ff ea ff ff       	call   f010007b <_panic>
	assert((pp1 = page_alloc(0)));
f010157c:	83 ec 0c             	sub    $0xc,%esp
f010157f:	6a 00                	push   $0x0
f0101581:	e8 b1 f7 ff ff       	call   f0100d37 <page_alloc>
f0101586:	89 c6                	mov    %eax,%esi
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	75 19                	jne    f01015a8 <mem_init+0x14a>
f010158f:	68 89 74 10 f0       	push   $0xf0107489
f0101594:	68 ab 73 10 f0       	push   $0xf01073ab
f0101599:	68 0f 03 00 00       	push   $0x30f
f010159e:	68 85 73 10 f0       	push   $0xf0107385
f01015a3:	e8 d3 ea ff ff       	call   f010007b <_panic>
	assert((pp2 = page_alloc(0)));
f01015a8:	83 ec 0c             	sub    $0xc,%esp
f01015ab:	6a 00                	push   $0x0
f01015ad:	e8 85 f7 ff ff       	call   f0100d37 <page_alloc>
f01015b2:	89 c3                	mov    %eax,%ebx
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	75 19                	jne    f01015d4 <mem_init+0x176>
f01015bb:	68 9f 74 10 f0       	push   $0xf010749f
f01015c0:	68 ab 73 10 f0       	push   $0xf01073ab
f01015c5:	68 10 03 00 00       	push   $0x310
f01015ca:	68 85 73 10 f0       	push   $0xf0107385
f01015cf:	e8 a7 ea ff ff       	call   f010007b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015d4:	39 f7                	cmp    %esi,%edi
f01015d6:	75 19                	jne    f01015f1 <mem_init+0x193>
f01015d8:	68 b5 74 10 f0       	push   $0xf01074b5
f01015dd:	68 ab 73 10 f0       	push   $0xf01073ab
f01015e2:	68 13 03 00 00       	push   $0x313
f01015e7:	68 85 73 10 f0       	push   $0xf0107385
f01015ec:	e8 8a ea ff ff       	call   f010007b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015f1:	39 c6                	cmp    %eax,%esi
f01015f3:	74 04                	je     f01015f9 <mem_init+0x19b>
f01015f5:	39 c7                	cmp    %eax,%edi
f01015f7:	75 19                	jne    f0101612 <mem_init+0x1b4>
f01015f9:	68 e0 6b 10 f0       	push   $0xf0106be0
f01015fe:	68 ab 73 10 f0       	push   $0xf01073ab
f0101603:	68 14 03 00 00       	push   $0x314
f0101608:	68 85 73 10 f0       	push   $0xf0107385
f010160d:	e8 69 ea ff ff       	call   f010007b <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101612:	8b 15 90 fe 1e f0    	mov    0xf01efe90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101618:	a1 88 fe 1e f0       	mov    0xf01efe88,%eax
f010161d:	89 c1                	mov    %eax,%ecx
f010161f:	c1 e1 0c             	shl    $0xc,%ecx
f0101622:	89 f8                	mov    %edi,%eax
f0101624:	29 d0                	sub    %edx,%eax
f0101626:	c1 f8 03             	sar    $0x3,%eax
f0101629:	c1 e0 0c             	shl    $0xc,%eax
f010162c:	39 c8                	cmp    %ecx,%eax
f010162e:	72 19                	jb     f0101649 <mem_init+0x1eb>
f0101630:	68 c7 74 10 f0       	push   $0xf01074c7
f0101635:	68 ab 73 10 f0       	push   $0xf01073ab
f010163a:	68 15 03 00 00       	push   $0x315
f010163f:	68 85 73 10 f0       	push   $0xf0107385
f0101644:	e8 32 ea ff ff       	call   f010007b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101649:	89 f0                	mov    %esi,%eax
f010164b:	29 d0                	sub    %edx,%eax
f010164d:	c1 f8 03             	sar    $0x3,%eax
f0101650:	c1 e0 0c             	shl    $0xc,%eax
f0101653:	39 c1                	cmp    %eax,%ecx
f0101655:	77 19                	ja     f0101670 <mem_init+0x212>
f0101657:	68 e4 74 10 f0       	push   $0xf01074e4
f010165c:	68 ab 73 10 f0       	push   $0xf01073ab
f0101661:	68 16 03 00 00       	push   $0x316
f0101666:	68 85 73 10 f0       	push   $0xf0107385
f010166b:	e8 0b ea ff ff       	call   f010007b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101670:	89 d8                	mov    %ebx,%eax
f0101672:	29 d0                	sub    %edx,%eax
f0101674:	c1 f8 03             	sar    $0x3,%eax
f0101677:	c1 e0 0c             	shl    $0xc,%eax
f010167a:	39 c1                	cmp    %eax,%ecx
f010167c:	77 19                	ja     f0101697 <mem_init+0x239>
f010167e:	68 01 75 10 f0       	push   $0xf0107501
f0101683:	68 ab 73 10 f0       	push   $0xf01073ab
f0101688:	68 17 03 00 00       	push   $0x317
f010168d:	68 85 73 10 f0       	push   $0xf0107385
f0101692:	e8 e4 e9 ff ff       	call   f010007b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101697:	a1 30 f2 1e f0       	mov    0xf01ef230,%eax
f010169c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	page_free_list = 0;
f010169f:	c7 05 30 f2 1e f0 00 	movl   $0x0,0xf01ef230
f01016a6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016a9:	83 ec 0c             	sub    $0xc,%esp
f01016ac:	6a 00                	push   $0x0
f01016ae:	e8 84 f6 ff ff       	call   f0100d37 <page_alloc>
f01016b3:	83 c4 10             	add    $0x10,%esp
f01016b6:	85 c0                	test   %eax,%eax
f01016b8:	74 19                	je     f01016d3 <mem_init+0x275>
f01016ba:	68 1e 75 10 f0       	push   $0xf010751e
f01016bf:	68 ab 73 10 f0       	push   $0xf01073ab
f01016c4:	68 1e 03 00 00       	push   $0x31e
f01016c9:	68 85 73 10 f0       	push   $0xf0107385
f01016ce:	e8 a8 e9 ff ff       	call   f010007b <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016d3:	83 ec 0c             	sub    $0xc,%esp
f01016d6:	57                   	push   %edi
f01016d7:	e8 b3 f4 ff ff       	call   f0100b8f <page_free>
	page_free(pp1);
f01016dc:	89 34 24             	mov    %esi,(%esp)
f01016df:	e8 ab f4 ff ff       	call   f0100b8f <page_free>
	page_free(pp2);
f01016e4:	89 1c 24             	mov    %ebx,(%esp)
f01016e7:	e8 a3 f4 ff ff       	call   f0100b8f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016f3:	e8 3f f6 ff ff       	call   f0100d37 <page_alloc>
f01016f8:	89 c3                	mov    %eax,%ebx
f01016fa:	83 c4 10             	add    $0x10,%esp
f01016fd:	85 c0                	test   %eax,%eax
f01016ff:	75 19                	jne    f010171a <mem_init+0x2bc>
f0101701:	68 73 74 10 f0       	push   $0xf0107473
f0101706:	68 ab 73 10 f0       	push   $0xf01073ab
f010170b:	68 25 03 00 00       	push   $0x325
f0101710:	68 85 73 10 f0       	push   $0xf0107385
f0101715:	e8 61 e9 ff ff       	call   f010007b <_panic>
	assert((pp1 = page_alloc(0)));
f010171a:	83 ec 0c             	sub    $0xc,%esp
f010171d:	6a 00                	push   $0x0
f010171f:	e8 13 f6 ff ff       	call   f0100d37 <page_alloc>
f0101724:	89 c7                	mov    %eax,%edi
f0101726:	83 c4 10             	add    $0x10,%esp
f0101729:	85 c0                	test   %eax,%eax
f010172b:	75 19                	jne    f0101746 <mem_init+0x2e8>
f010172d:	68 89 74 10 f0       	push   $0xf0107489
f0101732:	68 ab 73 10 f0       	push   $0xf01073ab
f0101737:	68 26 03 00 00       	push   $0x326
f010173c:	68 85 73 10 f0       	push   $0xf0107385
f0101741:	e8 35 e9 ff ff       	call   f010007b <_panic>
	assert((pp2 = page_alloc(0)));
f0101746:	83 ec 0c             	sub    $0xc,%esp
f0101749:	6a 00                	push   $0x0
f010174b:	e8 e7 f5 ff ff       	call   f0100d37 <page_alloc>
f0101750:	89 c6                	mov    %eax,%esi
f0101752:	83 c4 10             	add    $0x10,%esp
f0101755:	85 c0                	test   %eax,%eax
f0101757:	75 19                	jne    f0101772 <mem_init+0x314>
f0101759:	68 9f 74 10 f0       	push   $0xf010749f
f010175e:	68 ab 73 10 f0       	push   $0xf01073ab
f0101763:	68 27 03 00 00       	push   $0x327
f0101768:	68 85 73 10 f0       	push   $0xf0107385
f010176d:	e8 09 e9 ff ff       	call   f010007b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101772:	39 fb                	cmp    %edi,%ebx
f0101774:	75 19                	jne    f010178f <mem_init+0x331>
f0101776:	68 b5 74 10 f0       	push   $0xf01074b5
f010177b:	68 ab 73 10 f0       	push   $0xf01073ab
f0101780:	68 29 03 00 00       	push   $0x329
f0101785:	68 85 73 10 f0       	push   $0xf0107385
f010178a:	e8 ec e8 ff ff       	call   f010007b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010178f:	39 c7                	cmp    %eax,%edi
f0101791:	74 04                	je     f0101797 <mem_init+0x339>
f0101793:	39 c3                	cmp    %eax,%ebx
f0101795:	75 19                	jne    f01017b0 <mem_init+0x352>
f0101797:	68 e0 6b 10 f0       	push   $0xf0106be0
f010179c:	68 ab 73 10 f0       	push   $0xf01073ab
f01017a1:	68 2a 03 00 00       	push   $0x32a
f01017a6:	68 85 73 10 f0       	push   $0xf0107385
f01017ab:	e8 cb e8 ff ff       	call   f010007b <_panic>
	assert(!page_alloc(0));
f01017b0:	83 ec 0c             	sub    $0xc,%esp
f01017b3:	6a 00                	push   $0x0
f01017b5:	e8 7d f5 ff ff       	call   f0100d37 <page_alloc>
f01017ba:	83 c4 10             	add    $0x10,%esp
f01017bd:	85 c0                	test   %eax,%eax
f01017bf:	74 19                	je     f01017da <mem_init+0x37c>
f01017c1:	68 1e 75 10 f0       	push   $0xf010751e
f01017c6:	68 ab 73 10 f0       	push   $0xf01073ab
f01017cb:	68 2b 03 00 00       	push   $0x32b
f01017d0:	68 85 73 10 f0       	push   $0xf0107385
f01017d5:	e8 a1 e8 ff ff       	call   f010007b <_panic>
f01017da:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f01017dd:	89 d8                	mov    %ebx,%eax
f01017df:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f01017e5:	c1 f8 03             	sar    $0x3,%eax
f01017e8:	89 c2                	mov    %eax,%edx
f01017ea:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ed:	89 d0                	mov    %edx,%eax
f01017ef:	c1 e8 0c             	shr    $0xc,%eax
f01017f2:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f01017f8:	72 12                	jb     f010180c <mem_init+0x3ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017fa:	52                   	push   %edx
f01017fb:	68 dc 64 10 f0       	push   $0xf01064dc
f0101800:	6a 58                	push   $0x58
f0101802:	68 91 73 10 f0       	push   $0xf0107391
f0101807:	e8 6f e8 ff ff       	call   f010007b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010180c:	83 ec 04             	sub    $0x4,%esp
f010180f:	68 00 10 00 00       	push   $0x1000
f0101814:	6a 01                	push   $0x1
f0101816:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010181c:	50                   	push   %eax
f010181d:	e8 22 3f 00 00       	call   f0105744 <memset>
	page_free(pp0);
f0101822:	89 1c 24             	mov    %ebx,(%esp)
f0101825:	e8 65 f3 ff ff       	call   f0100b8f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010182a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101831:	e8 01 f5 ff ff       	call   f0100d37 <page_alloc>
f0101836:	83 c4 10             	add    $0x10,%esp
f0101839:	85 c0                	test   %eax,%eax
f010183b:	75 19                	jne    f0101856 <mem_init+0x3f8>
f010183d:	68 2d 75 10 f0       	push   $0xf010752d
f0101842:	68 ab 73 10 f0       	push   $0xf01073ab
f0101847:	68 30 03 00 00       	push   $0x330
f010184c:	68 85 73 10 f0       	push   $0xf0107385
f0101851:	e8 25 e8 ff ff       	call   f010007b <_panic>
	assert(pp && pp0 == pp);
f0101856:	39 c3                	cmp    %eax,%ebx
f0101858:	74 19                	je     f0101873 <mem_init+0x415>
f010185a:	68 4b 75 10 f0       	push   $0xf010754b
f010185f:	68 ab 73 10 f0       	push   $0xf01073ab
f0101864:	68 31 03 00 00       	push   $0x331
f0101869:	68 85 73 10 f0       	push   $0xf0107385
f010186e:	e8 08 e8 ff ff       	call   f010007b <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101873:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0101876:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f010187c:	c1 f8 03             	sar    $0x3,%eax
f010187f:	89 c2                	mov    %eax,%edx
f0101881:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101884:	89 d0                	mov    %edx,%eax
f0101886:	c1 e8 0c             	shr    $0xc,%eax
f0101889:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f010188f:	72 12                	jb     f01018a3 <mem_init+0x445>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101891:	52                   	push   %edx
f0101892:	68 dc 64 10 f0       	push   $0xf01064dc
f0101897:	6a 58                	push   $0x58
f0101899:	68 91 73 10 f0       	push   $0xf0107391
f010189e:	e8 d8 e7 ff ff       	call   f010007b <_panic>
f01018a3:	b8 00 00 00 00       	mov    $0x0,%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018a8:	80 bc 10 00 00 00 f0 	cmpb   $0x0,-0x10000000(%eax,%edx,1)
f01018af:	00 
f01018b0:	74 19                	je     f01018cb <mem_init+0x46d>
f01018b2:	68 5b 75 10 f0       	push   $0xf010755b
f01018b7:	68 ab 73 10 f0       	push   $0xf01073ab
f01018bc:	68 34 03 00 00       	push   $0x334
f01018c1:	68 85 73 10 f0       	push   $0xf0107385
f01018c6:	e8 b0 e7 ff ff       	call   f010007b <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018cb:	40                   	inc    %eax
f01018cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01018d1:	75 d5                	jne    f01018a8 <mem_init+0x44a>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018d3:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f01018d6:	89 0d 30 f2 1e f0    	mov    %ecx,0xf01ef230

	// free the pages we took
	page_free(pp0);
f01018dc:	83 ec 0c             	sub    $0xc,%esp
f01018df:	53                   	push   %ebx
f01018e0:	e8 aa f2 ff ff       	call   f0100b8f <page_free>
	page_free(pp1);
f01018e5:	89 3c 24             	mov    %edi,(%esp)
f01018e8:	e8 a2 f2 ff ff       	call   f0100b8f <page_free>
	page_free(pp2);
f01018ed:	89 34 24             	mov    %esi,(%esp)
f01018f0:	e8 9a f2 ff ff       	call   f0100b8f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018f5:	a1 30 f2 1e f0       	mov    0xf01ef230,%eax
f01018fa:	83 c4 10             	add    $0x10,%esp
f01018fd:	eb 05                	jmp    f0101904 <mem_init+0x4a6>
		--nfree;
f01018ff:	ff 4d b8             	decl   -0x48(%ebp)
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101902:	8b 00                	mov    (%eax),%eax
f0101904:	85 c0                	test   %eax,%eax
f0101906:	75 f7                	jne    f01018ff <mem_init+0x4a1>
		--nfree;
	assert(nfree == 0);
f0101908:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
f010190c:	74 19                	je     f0101927 <mem_init+0x4c9>
f010190e:	68 65 75 10 f0       	push   $0xf0107565
f0101913:	68 ab 73 10 f0       	push   $0xf01073ab
f0101918:	68 41 03 00 00       	push   $0x341
f010191d:	68 85 73 10 f0       	push   $0xf0107385
f0101922:	e8 54 e7 ff ff       	call   f010007b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101927:	83 ec 0c             	sub    $0xc,%esp
f010192a:	68 00 6c 10 f0       	push   $0xf0106c00
f010192f:	e8 d2 1d 00 00       	call   f0103706 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101934:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010193b:	e8 f7 f3 ff ff       	call   f0100d37 <page_alloc>
f0101940:	89 c7                	mov    %eax,%edi
f0101942:	83 c4 10             	add    $0x10,%esp
f0101945:	85 c0                	test   %eax,%eax
f0101947:	75 19                	jne    f0101962 <mem_init+0x504>
f0101949:	68 73 74 10 f0       	push   $0xf0107473
f010194e:	68 ab 73 10 f0       	push   $0xf01073ab
f0101953:	68 a7 03 00 00       	push   $0x3a7
f0101958:	68 85 73 10 f0       	push   $0xf0107385
f010195d:	e8 19 e7 ff ff       	call   f010007b <_panic>
	assert((pp1 = page_alloc(0)));
f0101962:	83 ec 0c             	sub    $0xc,%esp
f0101965:	6a 00                	push   $0x0
f0101967:	e8 cb f3 ff ff       	call   f0100d37 <page_alloc>
f010196c:	89 c6                	mov    %eax,%esi
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	75 19                	jne    f010198e <mem_init+0x530>
f0101975:	68 89 74 10 f0       	push   $0xf0107489
f010197a:	68 ab 73 10 f0       	push   $0xf01073ab
f010197f:	68 a8 03 00 00       	push   $0x3a8
f0101984:	68 85 73 10 f0       	push   $0xf0107385
f0101989:	e8 ed e6 ff ff       	call   f010007b <_panic>
	assert((pp2 = page_alloc(0)));
f010198e:	83 ec 0c             	sub    $0xc,%esp
f0101991:	6a 00                	push   $0x0
f0101993:	e8 9f f3 ff ff       	call   f0100d37 <page_alloc>
f0101998:	89 c3                	mov    %eax,%ebx
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	75 19                	jne    f01019ba <mem_init+0x55c>
f01019a1:	68 9f 74 10 f0       	push   $0xf010749f
f01019a6:	68 ab 73 10 f0       	push   $0xf01073ab
f01019ab:	68 a9 03 00 00       	push   $0x3a9
f01019b0:	68 85 73 10 f0       	push   $0xf0107385
f01019b5:	e8 c1 e6 ff ff       	call   f010007b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ba:	39 f7                	cmp    %esi,%edi
f01019bc:	75 19                	jne    f01019d7 <mem_init+0x579>
f01019be:	68 b5 74 10 f0       	push   $0xf01074b5
f01019c3:	68 ab 73 10 f0       	push   $0xf01073ab
f01019c8:	68 ac 03 00 00       	push   $0x3ac
f01019cd:	68 85 73 10 f0       	push   $0xf0107385
f01019d2:	e8 a4 e6 ff ff       	call   f010007b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019d7:	39 c6                	cmp    %eax,%esi
f01019d9:	74 04                	je     f01019df <mem_init+0x581>
f01019db:	39 c7                	cmp    %eax,%edi
f01019dd:	75 19                	jne    f01019f8 <mem_init+0x59a>
f01019df:	68 e0 6b 10 f0       	push   $0xf0106be0
f01019e4:	68 ab 73 10 f0       	push   $0xf01073ab
f01019e9:	68 ad 03 00 00       	push   $0x3ad
f01019ee:	68 85 73 10 f0       	push   $0xf0107385
f01019f3:	e8 83 e6 ff ff       	call   f010007b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019f8:	a1 30 f2 1e f0       	mov    0xf01ef230,%eax
f01019fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101a00:	c7 05 30 f2 1e f0 00 	movl   $0x0,0xf01ef230
f0101a07:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a0a:	83 ec 0c             	sub    $0xc,%esp
f0101a0d:	6a 00                	push   $0x0
f0101a0f:	e8 23 f3 ff ff       	call   f0100d37 <page_alloc>
f0101a14:	83 c4 10             	add    $0x10,%esp
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	74 19                	je     f0101a34 <mem_init+0x5d6>
f0101a1b:	68 1e 75 10 f0       	push   $0xf010751e
f0101a20:	68 ab 73 10 f0       	push   $0xf01073ab
f0101a25:	68 b4 03 00 00       	push   $0x3b4
f0101a2a:	68 85 73 10 f0       	push   $0xf0107385
f0101a2f:	e8 47 e6 ff ff       	call   f010007b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a34:	83 ec 04             	sub    $0x4,%esp
f0101a37:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101a3a:	50                   	push   %eax
f0101a3b:	6a 00                	push   $0x0
f0101a3d:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101a43:	e8 d0 f4 ff ff       	call   f0100f18 <page_lookup>
f0101a48:	83 c4 10             	add    $0x10,%esp
f0101a4b:	85 c0                	test   %eax,%eax
f0101a4d:	74 19                	je     f0101a68 <mem_init+0x60a>
f0101a4f:	68 20 6c 10 f0       	push   $0xf0106c20
f0101a54:	68 ab 73 10 f0       	push   $0xf01073ab
f0101a59:	68 b7 03 00 00       	push   $0x3b7
f0101a5e:	68 85 73 10 f0       	push   $0xf0107385
f0101a63:	e8 13 e6 ff ff       	call   f010007b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a68:	6a 02                	push   $0x2
f0101a6a:	6a 00                	push   $0x0
f0101a6c:	56                   	push   %esi
f0101a6d:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101a73:	e8 46 f5 ff ff       	call   f0100fbe <page_insert>
f0101a78:	83 c4 10             	add    $0x10,%esp
f0101a7b:	85 c0                	test   %eax,%eax
f0101a7d:	78 19                	js     f0101a98 <mem_init+0x63a>
f0101a7f:	68 58 6c 10 f0       	push   $0xf0106c58
f0101a84:	68 ab 73 10 f0       	push   $0xf01073ab
f0101a89:	68 ba 03 00 00       	push   $0x3ba
f0101a8e:	68 85 73 10 f0       	push   $0xf0107385
f0101a93:	e8 e3 e5 ff ff       	call   f010007b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a98:	83 ec 0c             	sub    $0xc,%esp
f0101a9b:	57                   	push   %edi
f0101a9c:	e8 ee f0 ff ff       	call   f0100b8f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101aa1:	6a 02                	push   $0x2
f0101aa3:	6a 00                	push   $0x0
f0101aa5:	56                   	push   %esi
f0101aa6:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101aac:	e8 0d f5 ff ff       	call   f0100fbe <page_insert>
f0101ab1:	83 c4 20             	add    $0x20,%esp
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	74 19                	je     f0101ad1 <mem_init+0x673>
f0101ab8:	68 88 6c 10 f0       	push   $0xf0106c88
f0101abd:	68 ab 73 10 f0       	push   $0xf01073ab
f0101ac2:	68 be 03 00 00       	push   $0x3be
f0101ac7:	68 85 73 10 f0       	push   $0xf0107385
f0101acc:	e8 aa e5 ff ff       	call   f010007b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ad1:	8b 0d 8c fe 1e f0    	mov    0xf01efe8c,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ad7:	89 7d c8             	mov    %edi,-0x38(%ebp)
f0101ada:	8b 11                	mov    (%ecx),%edx
f0101adc:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ae2:	89 f8                	mov    %edi,%eax
f0101ae4:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0101aea:	c1 f8 03             	sar    $0x3,%eax
f0101aed:	c1 e0 0c             	shl    $0xc,%eax
f0101af0:	39 c2                	cmp    %eax,%edx
f0101af2:	74 19                	je     f0101b0d <mem_init+0x6af>
f0101af4:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0101af9:	68 ab 73 10 f0       	push   $0xf01073ab
f0101afe:	68 bf 03 00 00       	push   $0x3bf
f0101b03:	68 85 73 10 f0       	push   $0xf0107385
f0101b08:	e8 6e e5 ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b12:	89 c8                	mov    %ecx,%eax
f0101b14:	e8 bf f1 ff ff       	call   f0100cd8 <check_va2pa>
f0101b19:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0101b1c:	89 f2                	mov    %esi,%edx
f0101b1e:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101b24:	c1 fa 03             	sar    $0x3,%edx
f0101b27:	c1 e2 0c             	shl    $0xc,%edx
f0101b2a:	39 d0                	cmp    %edx,%eax
f0101b2c:	74 19                	je     f0101b47 <mem_init+0x6e9>
f0101b2e:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0101b33:	68 ab 73 10 f0       	push   $0xf01073ab
f0101b38:	68 c0 03 00 00       	push   $0x3c0
f0101b3d:	68 85 73 10 f0       	push   $0xf0107385
f0101b42:	e8 34 e5 ff ff       	call   f010007b <_panic>
	assert(pp1->pp_ref == 1);
f0101b47:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b4c:	74 19                	je     f0101b67 <mem_init+0x709>
f0101b4e:	68 70 75 10 f0       	push   $0xf0107570
f0101b53:	68 ab 73 10 f0       	push   $0xf01073ab
f0101b58:	68 c1 03 00 00       	push   $0x3c1
f0101b5d:	68 85 73 10 f0       	push   $0xf0107385
f0101b62:	e8 14 e5 ff ff       	call   f010007b <_panic>
	assert(pp0->pp_ref == 1);
f0101b67:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b6c:	74 19                	je     f0101b87 <mem_init+0x729>
f0101b6e:	68 81 75 10 f0       	push   $0xf0107581
f0101b73:	68 ab 73 10 f0       	push   $0xf01073ab
f0101b78:	68 c2 03 00 00       	push   $0x3c2
f0101b7d:	68 85 73 10 f0       	push   $0xf0107385
f0101b82:	e8 f4 e4 ff ff       	call   f010007b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b87:	6a 02                	push   $0x2
f0101b89:	68 00 10 00 00       	push   $0x1000
f0101b8e:	53                   	push   %ebx
f0101b8f:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101b95:	e8 24 f4 ff ff       	call   f0100fbe <page_insert>
f0101b9a:	83 c4 10             	add    $0x10,%esp
f0101b9d:	85 c0                	test   %eax,%eax
f0101b9f:	74 19                	je     f0101bba <mem_init+0x75c>
f0101ba1:	68 10 6d 10 f0       	push   $0xf0106d10
f0101ba6:	68 ab 73 10 f0       	push   $0xf01073ab
f0101bab:	68 c5 03 00 00       	push   $0x3c5
f0101bb0:	68 85 73 10 f0       	push   $0xf0107385
f0101bb5:	e8 c1 e4 ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bbf:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101bc4:	e8 0f f1 ff ff       	call   f0100cd8 <check_va2pa>
f0101bc9:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0101bcc:	89 da                	mov    %ebx,%edx
f0101bce:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101bd4:	c1 fa 03             	sar    $0x3,%edx
f0101bd7:	c1 e2 0c             	shl    $0xc,%edx
f0101bda:	39 d0                	cmp    %edx,%eax
f0101bdc:	74 19                	je     f0101bf7 <mem_init+0x799>
f0101bde:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0101be3:	68 ab 73 10 f0       	push   $0xf01073ab
f0101be8:	68 c6 03 00 00       	push   $0x3c6
f0101bed:	68 85 73 10 f0       	push   $0xf0107385
f0101bf2:	e8 84 e4 ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 1);
f0101bf7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bfc:	74 19                	je     f0101c17 <mem_init+0x7b9>
f0101bfe:	68 92 75 10 f0       	push   $0xf0107592
f0101c03:	68 ab 73 10 f0       	push   $0xf01073ab
f0101c08:	68 c7 03 00 00       	push   $0x3c7
f0101c0d:	68 85 73 10 f0       	push   $0xf0107385
f0101c12:	e8 64 e4 ff ff       	call   f010007b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c17:	83 ec 0c             	sub    $0xc,%esp
f0101c1a:	6a 00                	push   $0x0
f0101c1c:	e8 16 f1 ff ff       	call   f0100d37 <page_alloc>
f0101c21:	83 c4 10             	add    $0x10,%esp
f0101c24:	85 c0                	test   %eax,%eax
f0101c26:	74 19                	je     f0101c41 <mem_init+0x7e3>
f0101c28:	68 1e 75 10 f0       	push   $0xf010751e
f0101c2d:	68 ab 73 10 f0       	push   $0xf01073ab
f0101c32:	68 ca 03 00 00       	push   $0x3ca
f0101c37:	68 85 73 10 f0       	push   $0xf0107385
f0101c3c:	e8 3a e4 ff ff       	call   f010007b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c41:	6a 02                	push   $0x2
f0101c43:	68 00 10 00 00       	push   $0x1000
f0101c48:	53                   	push   %ebx
f0101c49:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101c4f:	e8 6a f3 ff ff       	call   f0100fbe <page_insert>
f0101c54:	83 c4 10             	add    $0x10,%esp
f0101c57:	85 c0                	test   %eax,%eax
f0101c59:	74 19                	je     f0101c74 <mem_init+0x816>
f0101c5b:	68 10 6d 10 f0       	push   $0xf0106d10
f0101c60:	68 ab 73 10 f0       	push   $0xf01073ab
f0101c65:	68 cd 03 00 00       	push   $0x3cd
f0101c6a:	68 85 73 10 f0       	push   $0xf0107385
f0101c6f:	e8 07 e4 ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c74:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c79:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101c7e:	e8 55 f0 ff ff       	call   f0100cd8 <check_va2pa>
f0101c83:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0101c86:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101c8c:	c1 fa 03             	sar    $0x3,%edx
f0101c8f:	c1 e2 0c             	shl    $0xc,%edx
f0101c92:	39 d0                	cmp    %edx,%eax
f0101c94:	74 19                	je     f0101caf <mem_init+0x851>
f0101c96:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0101c9b:	68 ab 73 10 f0       	push   $0xf01073ab
f0101ca0:	68 ce 03 00 00       	push   $0x3ce
f0101ca5:	68 85 73 10 f0       	push   $0xf0107385
f0101caa:	e8 cc e3 ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 1);
f0101caf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cb4:	74 19                	je     f0101ccf <mem_init+0x871>
f0101cb6:	68 92 75 10 f0       	push   $0xf0107592
f0101cbb:	68 ab 73 10 f0       	push   $0xf01073ab
f0101cc0:	68 cf 03 00 00       	push   $0x3cf
f0101cc5:	68 85 73 10 f0       	push   $0xf0107385
f0101cca:	e8 ac e3 ff ff       	call   f010007b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ccf:	83 ec 0c             	sub    $0xc,%esp
f0101cd2:	6a 00                	push   $0x0
f0101cd4:	e8 5e f0 ff ff       	call   f0100d37 <page_alloc>
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	74 19                	je     f0101cf9 <mem_init+0x89b>
f0101ce0:	68 1e 75 10 f0       	push   $0xf010751e
f0101ce5:	68 ab 73 10 f0       	push   $0xf01073ab
f0101cea:	68 d3 03 00 00       	push   $0x3d3
f0101cef:	68 85 73 10 f0       	push   $0xf0107385
f0101cf4:	e8 82 e3 ff ff       	call   f010007b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cf9:	8b 0d 8c fe 1e f0    	mov    0xf01efe8c,%ecx
f0101cff:	8b 11                	mov    (%ecx),%edx
f0101d01:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d07:	89 d0                	mov    %edx,%eax
f0101d09:	c1 e8 0c             	shr    $0xc,%eax
f0101d0c:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0101d12:	72 15                	jb     f0101d29 <mem_init+0x8cb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d14:	52                   	push   %edx
f0101d15:	68 dc 64 10 f0       	push   $0xf01064dc
f0101d1a:	68 d6 03 00 00       	push   $0x3d6
f0101d1f:	68 85 73 10 f0       	push   $0xf0107385
f0101d24:	e8 52 e3 ff ff       	call   f010007b <_panic>
f0101d29:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101d2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d32:	83 ec 04             	sub    $0x4,%esp
f0101d35:	6a 00                	push   $0x0
f0101d37:	68 00 10 00 00       	push   $0x1000
f0101d3c:	51                   	push   %ecx
f0101d3d:	e8 7a f0 ff ff       	call   f0100dbc <pgdir_walk>
f0101d42:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101d45:	83 c2 04             	add    $0x4,%edx
f0101d48:	83 c4 10             	add    $0x10,%esp
f0101d4b:	39 d0                	cmp    %edx,%eax
f0101d4d:	74 19                	je     f0101d68 <mem_init+0x90a>
f0101d4f:	68 7c 6d 10 f0       	push   $0xf0106d7c
f0101d54:	68 ab 73 10 f0       	push   $0xf01073ab
f0101d59:	68 d7 03 00 00       	push   $0x3d7
f0101d5e:	68 85 73 10 f0       	push   $0xf0107385
f0101d63:	e8 13 e3 ff ff       	call   f010007b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d68:	6a 06                	push   $0x6
f0101d6a:	68 00 10 00 00       	push   $0x1000
f0101d6f:	53                   	push   %ebx
f0101d70:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101d76:	e8 43 f2 ff ff       	call   f0100fbe <page_insert>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	85 c0                	test   %eax,%eax
f0101d80:	74 19                	je     f0101d9b <mem_init+0x93d>
f0101d82:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0101d87:	68 ab 73 10 f0       	push   $0xf01073ab
f0101d8c:	68 da 03 00 00       	push   $0x3da
f0101d91:	68 85 73 10 f0       	push   $0xf0107385
f0101d96:	e8 e0 e2 ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d9b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da0:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101da5:	e8 2e ef ff ff       	call   f0100cd8 <check_va2pa>
f0101daa:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0101dad:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101db3:	c1 fa 03             	sar    $0x3,%edx
f0101db6:	c1 e2 0c             	shl    $0xc,%edx
f0101db9:	39 d0                	cmp    %edx,%eax
f0101dbb:	74 19                	je     f0101dd6 <mem_init+0x978>
f0101dbd:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0101dc2:	68 ab 73 10 f0       	push   $0xf01073ab
f0101dc7:	68 db 03 00 00       	push   $0x3db
f0101dcc:	68 85 73 10 f0       	push   $0xf0107385
f0101dd1:	e8 a5 e2 ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 1);
f0101dd6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ddb:	74 19                	je     f0101df6 <mem_init+0x998>
f0101ddd:	68 92 75 10 f0       	push   $0xf0107592
f0101de2:	68 ab 73 10 f0       	push   $0xf01073ab
f0101de7:	68 dc 03 00 00       	push   $0x3dc
f0101dec:	68 85 73 10 f0       	push   $0xf0107385
f0101df1:	e8 85 e2 ff ff       	call   f010007b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101df6:	83 ec 04             	sub    $0x4,%esp
f0101df9:	6a 00                	push   $0x0
f0101dfb:	68 00 10 00 00       	push   $0x1000
f0101e00:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101e06:	e8 b1 ef ff ff       	call   f0100dbc <pgdir_walk>
f0101e0b:	83 c4 10             	add    $0x10,%esp
f0101e0e:	f6 00 04             	testb  $0x4,(%eax)
f0101e11:	75 19                	jne    f0101e2c <mem_init+0x9ce>
f0101e13:	68 fc 6d 10 f0       	push   $0xf0106dfc
f0101e18:	68 ab 73 10 f0       	push   $0xf01073ab
f0101e1d:	68 dd 03 00 00       	push   $0x3dd
f0101e22:	68 85 73 10 f0       	push   $0xf0107385
f0101e27:	e8 4f e2 ff ff       	call   f010007b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e2c:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101e31:	f6 00 04             	testb  $0x4,(%eax)
f0101e34:	75 19                	jne    f0101e4f <mem_init+0x9f1>
f0101e36:	68 a3 75 10 f0       	push   $0xf01075a3
f0101e3b:	68 ab 73 10 f0       	push   $0xf01073ab
f0101e40:	68 de 03 00 00       	push   $0x3de
f0101e45:	68 85 73 10 f0       	push   $0xf0107385
f0101e4a:	e8 2c e2 ff ff       	call   f010007b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e4f:	6a 02                	push   $0x2
f0101e51:	68 00 10 00 00       	push   $0x1000
f0101e56:	53                   	push   %ebx
f0101e57:	50                   	push   %eax
f0101e58:	e8 61 f1 ff ff       	call   f0100fbe <page_insert>
f0101e5d:	83 c4 10             	add    $0x10,%esp
f0101e60:	85 c0                	test   %eax,%eax
f0101e62:	74 19                	je     f0101e7d <mem_init+0xa1f>
f0101e64:	68 10 6d 10 f0       	push   $0xf0106d10
f0101e69:	68 ab 73 10 f0       	push   $0xf01073ab
f0101e6e:	68 e1 03 00 00       	push   $0x3e1
f0101e73:	68 85 73 10 f0       	push   $0xf0107385
f0101e78:	e8 fe e1 ff ff       	call   f010007b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e7d:	83 ec 04             	sub    $0x4,%esp
f0101e80:	6a 00                	push   $0x0
f0101e82:	68 00 10 00 00       	push   $0x1000
f0101e87:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101e8d:	e8 2a ef ff ff       	call   f0100dbc <pgdir_walk>
f0101e92:	83 c4 10             	add    $0x10,%esp
f0101e95:	f6 00 02             	testb  $0x2,(%eax)
f0101e98:	75 19                	jne    f0101eb3 <mem_init+0xa55>
f0101e9a:	68 30 6e 10 f0       	push   $0xf0106e30
f0101e9f:	68 ab 73 10 f0       	push   $0xf01073ab
f0101ea4:	68 e2 03 00 00       	push   $0x3e2
f0101ea9:	68 85 73 10 f0       	push   $0xf0107385
f0101eae:	e8 c8 e1 ff ff       	call   f010007b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101eb3:	83 ec 04             	sub    $0x4,%esp
f0101eb6:	6a 00                	push   $0x0
f0101eb8:	68 00 10 00 00       	push   $0x1000
f0101ebd:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101ec3:	e8 f4 ee ff ff       	call   f0100dbc <pgdir_walk>
f0101ec8:	83 c4 10             	add    $0x10,%esp
f0101ecb:	f6 00 04             	testb  $0x4,(%eax)
f0101ece:	74 19                	je     f0101ee9 <mem_init+0xa8b>
f0101ed0:	68 64 6e 10 f0       	push   $0xf0106e64
f0101ed5:	68 ab 73 10 f0       	push   $0xf01073ab
f0101eda:	68 e3 03 00 00       	push   $0x3e3
f0101edf:	68 85 73 10 f0       	push   $0xf0107385
f0101ee4:	e8 92 e1 ff ff       	call   f010007b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ee9:	6a 02                	push   $0x2
f0101eeb:	68 00 00 40 00       	push   $0x400000
f0101ef0:	57                   	push   %edi
f0101ef1:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101ef7:	e8 c2 f0 ff ff       	call   f0100fbe <page_insert>
f0101efc:	83 c4 10             	add    $0x10,%esp
f0101eff:	85 c0                	test   %eax,%eax
f0101f01:	78 19                	js     f0101f1c <mem_init+0xabe>
f0101f03:	68 9c 6e 10 f0       	push   $0xf0106e9c
f0101f08:	68 ab 73 10 f0       	push   $0xf01073ab
f0101f0d:	68 e6 03 00 00       	push   $0x3e6
f0101f12:	68 85 73 10 f0       	push   $0xf0107385
f0101f17:	e8 5f e1 ff ff       	call   f010007b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f1c:	6a 02                	push   $0x2
f0101f1e:	68 00 10 00 00       	push   $0x1000
f0101f23:	56                   	push   %esi
f0101f24:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101f2a:	e8 8f f0 ff ff       	call   f0100fbe <page_insert>
f0101f2f:	83 c4 10             	add    $0x10,%esp
f0101f32:	85 c0                	test   %eax,%eax
f0101f34:	74 19                	je     f0101f4f <mem_init+0xaf1>
f0101f36:	68 d4 6e 10 f0       	push   $0xf0106ed4
f0101f3b:	68 ab 73 10 f0       	push   $0xf01073ab
f0101f40:	68 e9 03 00 00       	push   $0x3e9
f0101f45:	68 85 73 10 f0       	push   $0xf0107385
f0101f4a:	e8 2c e1 ff ff       	call   f010007b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f4f:	83 ec 04             	sub    $0x4,%esp
f0101f52:	6a 00                	push   $0x0
f0101f54:	68 00 10 00 00       	push   $0x1000
f0101f59:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0101f5f:	e8 58 ee ff ff       	call   f0100dbc <pgdir_walk>
f0101f64:	83 c4 10             	add    $0x10,%esp
f0101f67:	f6 00 04             	testb  $0x4,(%eax)
f0101f6a:	74 19                	je     f0101f85 <mem_init+0xb27>
f0101f6c:	68 64 6e 10 f0       	push   $0xf0106e64
f0101f71:	68 ab 73 10 f0       	push   $0xf01073ab
f0101f76:	68 ea 03 00 00       	push   $0x3ea
f0101f7b:	68 85 73 10 f0       	push   $0xf0107385
f0101f80:	e8 f6 e0 ff ff       	call   f010007b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f85:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f8a:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101f8f:	e8 44 ed ff ff       	call   f0100cd8 <check_va2pa>
f0101f94:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101f97:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101f9d:	c1 fa 03             	sar    $0x3,%edx
f0101fa0:	c1 e2 0c             	shl    $0xc,%edx
f0101fa3:	39 d0                	cmp    %edx,%eax
f0101fa5:	74 19                	je     f0101fc0 <mem_init+0xb62>
f0101fa7:	68 10 6f 10 f0       	push   $0xf0106f10
f0101fac:	68 ab 73 10 f0       	push   $0xf01073ab
f0101fb1:	68 ed 03 00 00       	push   $0x3ed
f0101fb6:	68 85 73 10 f0       	push   $0xf0107385
f0101fbb:	e8 bb e0 ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fc0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc5:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0101fca:	e8 09 ed ff ff       	call   f0100cd8 <check_va2pa>
f0101fcf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101fd2:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f0101fd8:	c1 fa 03             	sar    $0x3,%edx
f0101fdb:	c1 e2 0c             	shl    $0xc,%edx
f0101fde:	39 d0                	cmp    %edx,%eax
f0101fe0:	74 19                	je     f0101ffb <mem_init+0xb9d>
f0101fe2:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0101fe7:	68 ab 73 10 f0       	push   $0xf01073ab
f0101fec:	68 ee 03 00 00       	push   $0x3ee
f0101ff1:	68 85 73 10 f0       	push   $0xf0107385
f0101ff6:	e8 80 e0 ff ff       	call   f010007b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ffb:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102000:	74 19                	je     f010201b <mem_init+0xbbd>
f0102002:	68 b9 75 10 f0       	push   $0xf01075b9
f0102007:	68 ab 73 10 f0       	push   $0xf01073ab
f010200c:	68 f0 03 00 00       	push   $0x3f0
f0102011:	68 85 73 10 f0       	push   $0xf0107385
f0102016:	e8 60 e0 ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 0);
f010201b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102020:	74 19                	je     f010203b <mem_init+0xbdd>
f0102022:	68 ca 75 10 f0       	push   $0xf01075ca
f0102027:	68 ab 73 10 f0       	push   $0xf01073ab
f010202c:	68 f1 03 00 00       	push   $0x3f1
f0102031:	68 85 73 10 f0       	push   $0xf0107385
f0102036:	e8 40 e0 ff ff       	call   f010007b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010203b:	83 ec 0c             	sub    $0xc,%esp
f010203e:	6a 00                	push   $0x0
f0102040:	e8 f2 ec ff ff       	call   f0100d37 <page_alloc>
f0102045:	83 c4 10             	add    $0x10,%esp
f0102048:	85 c0                	test   %eax,%eax
f010204a:	74 04                	je     f0102050 <mem_init+0xbf2>
f010204c:	39 c3                	cmp    %eax,%ebx
f010204e:	74 19                	je     f0102069 <mem_init+0xc0b>
f0102050:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0102055:	68 ab 73 10 f0       	push   $0xf01073ab
f010205a:	68 f4 03 00 00       	push   $0x3f4
f010205f:	68 85 73 10 f0       	push   $0xf0107385
f0102064:	e8 12 e0 ff ff       	call   f010007b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102069:	83 ec 08             	sub    $0x8,%esp
f010206c:	6a 00                	push   $0x0
f010206e:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102074:	e8 ff ee ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102079:	ba 00 00 00 00       	mov    $0x0,%edx
f010207e:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0102083:	e8 50 ec ff ff       	call   f0100cd8 <check_va2pa>
f0102088:	83 c4 10             	add    $0x10,%esp
f010208b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010208e:	74 19                	je     f01020a9 <mem_init+0xc4b>
f0102090:	68 90 6f 10 f0       	push   $0xf0106f90
f0102095:	68 ab 73 10 f0       	push   $0xf01073ab
f010209a:	68 f8 03 00 00       	push   $0x3f8
f010209f:	68 85 73 10 f0       	push   $0xf0107385
f01020a4:	e8 d2 df ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020a9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ae:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01020b3:	e8 20 ec ff ff       	call   f0100cd8 <check_va2pa>
f01020b8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01020bb:	2b 15 90 fe 1e f0    	sub    0xf01efe90,%edx
f01020c1:	c1 fa 03             	sar    $0x3,%edx
f01020c4:	c1 e2 0c             	shl    $0xc,%edx
f01020c7:	39 d0                	cmp    %edx,%eax
f01020c9:	74 19                	je     f01020e4 <mem_init+0xc86>
f01020cb:	68 3c 6f 10 f0       	push   $0xf0106f3c
f01020d0:	68 ab 73 10 f0       	push   $0xf01073ab
f01020d5:	68 f9 03 00 00       	push   $0x3f9
f01020da:	68 85 73 10 f0       	push   $0xf0107385
f01020df:	e8 97 df ff ff       	call   f010007b <_panic>
	assert(pp1->pp_ref == 1);
f01020e4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020e9:	74 19                	je     f0102104 <mem_init+0xca6>
f01020eb:	68 70 75 10 f0       	push   $0xf0107570
f01020f0:	68 ab 73 10 f0       	push   $0xf01073ab
f01020f5:	68 fa 03 00 00       	push   $0x3fa
f01020fa:	68 85 73 10 f0       	push   $0xf0107385
f01020ff:	e8 77 df ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 0);
f0102104:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102109:	74 19                	je     f0102124 <mem_init+0xcc6>
f010210b:	68 ca 75 10 f0       	push   $0xf01075ca
f0102110:	68 ab 73 10 f0       	push   $0xf01073ab
f0102115:	68 fb 03 00 00       	push   $0x3fb
f010211a:	68 85 73 10 f0       	push   $0xf0107385
f010211f:	e8 57 df ff ff       	call   f010007b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102124:	6a 00                	push   $0x0
f0102126:	68 00 10 00 00       	push   $0x1000
f010212b:	56                   	push   %esi
f010212c:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102132:	e8 87 ee ff ff       	call   f0100fbe <page_insert>
f0102137:	83 c4 10             	add    $0x10,%esp
f010213a:	85 c0                	test   %eax,%eax
f010213c:	74 19                	je     f0102157 <mem_init+0xcf9>
f010213e:	68 b4 6f 10 f0       	push   $0xf0106fb4
f0102143:	68 ab 73 10 f0       	push   $0xf01073ab
f0102148:	68 fe 03 00 00       	push   $0x3fe
f010214d:	68 85 73 10 f0       	push   $0xf0107385
f0102152:	e8 24 df ff ff       	call   f010007b <_panic>
	assert(pp1->pp_ref);
f0102157:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010215c:	75 19                	jne    f0102177 <mem_init+0xd19>
f010215e:	68 db 75 10 f0       	push   $0xf01075db
f0102163:	68 ab 73 10 f0       	push   $0xf01073ab
f0102168:	68 ff 03 00 00       	push   $0x3ff
f010216d:	68 85 73 10 f0       	push   $0xf0107385
f0102172:	e8 04 df ff ff       	call   f010007b <_panic>
	assert(pp1->pp_link == NULL);
f0102177:	83 3e 00             	cmpl   $0x0,(%esi)
f010217a:	74 19                	je     f0102195 <mem_init+0xd37>
f010217c:	68 e7 75 10 f0       	push   $0xf01075e7
f0102181:	68 ab 73 10 f0       	push   $0xf01073ab
f0102186:	68 00 04 00 00       	push   $0x400
f010218b:	68 85 73 10 f0       	push   $0xf0107385
f0102190:	e8 e6 de ff ff       	call   f010007b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102195:	83 ec 08             	sub    $0x8,%esp
f0102198:	68 00 10 00 00       	push   $0x1000
f010219d:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f01021a3:	e8 d0 ed ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01021ad:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01021b2:	e8 21 eb ff ff       	call   f0100cd8 <check_va2pa>
f01021b7:	83 c4 10             	add    $0x10,%esp
f01021ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021bd:	74 19                	je     f01021d8 <mem_init+0xd7a>
f01021bf:	68 90 6f 10 f0       	push   $0xf0106f90
f01021c4:	68 ab 73 10 f0       	push   $0xf01073ab
f01021c9:	68 04 04 00 00       	push   $0x404
f01021ce:	68 85 73 10 f0       	push   $0xf0107385
f01021d3:	e8 a3 de ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021d8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021dd:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01021e2:	e8 f1 ea ff ff       	call   f0100cd8 <check_va2pa>
f01021e7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ea:	74 19                	je     f0102205 <mem_init+0xda7>
f01021ec:	68 ec 6f 10 f0       	push   $0xf0106fec
f01021f1:	68 ab 73 10 f0       	push   $0xf01073ab
f01021f6:	68 05 04 00 00       	push   $0x405
f01021fb:	68 85 73 10 f0       	push   $0xf0107385
f0102200:	e8 76 de ff ff       	call   f010007b <_panic>
	assert(pp1->pp_ref == 0);
f0102205:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010220a:	74 19                	je     f0102225 <mem_init+0xdc7>
f010220c:	68 fc 75 10 f0       	push   $0xf01075fc
f0102211:	68 ab 73 10 f0       	push   $0xf01073ab
f0102216:	68 06 04 00 00       	push   $0x406
f010221b:	68 85 73 10 f0       	push   $0xf0107385
f0102220:	e8 56 de ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 0);
f0102225:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010222a:	74 19                	je     f0102245 <mem_init+0xde7>
f010222c:	68 ca 75 10 f0       	push   $0xf01075ca
f0102231:	68 ab 73 10 f0       	push   $0xf01073ab
f0102236:	68 07 04 00 00       	push   $0x407
f010223b:	68 85 73 10 f0       	push   $0xf0107385
f0102240:	e8 36 de ff ff       	call   f010007b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102245:	83 ec 0c             	sub    $0xc,%esp
f0102248:	6a 00                	push   $0x0
f010224a:	e8 e8 ea ff ff       	call   f0100d37 <page_alloc>
f010224f:	83 c4 10             	add    $0x10,%esp
f0102252:	85 c0                	test   %eax,%eax
f0102254:	74 04                	je     f010225a <mem_init+0xdfc>
f0102256:	39 c6                	cmp    %eax,%esi
f0102258:	74 19                	je     f0102273 <mem_init+0xe15>
f010225a:	68 14 70 10 f0       	push   $0xf0107014
f010225f:	68 ab 73 10 f0       	push   $0xf01073ab
f0102264:	68 0a 04 00 00       	push   $0x40a
f0102269:	68 85 73 10 f0       	push   $0xf0107385
f010226e:	e8 08 de ff ff       	call   f010007b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102273:	83 ec 0c             	sub    $0xc,%esp
f0102276:	6a 00                	push   $0x0
f0102278:	e8 ba ea ff ff       	call   f0100d37 <page_alloc>
f010227d:	83 c4 10             	add    $0x10,%esp
f0102280:	85 c0                	test   %eax,%eax
f0102282:	74 19                	je     f010229d <mem_init+0xe3f>
f0102284:	68 1e 75 10 f0       	push   $0xf010751e
f0102289:	68 ab 73 10 f0       	push   $0xf01073ab
f010228e:	68 0d 04 00 00       	push   $0x40d
f0102293:	68 85 73 10 f0       	push   $0xf0107385
f0102298:	e8 de dd ff ff       	call   f010007b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010229d:	8b 0d 8c fe 1e f0    	mov    0xf01efe8c,%ecx
f01022a3:	8b 11                	mov    (%ecx),%edx
f01022a5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022ab:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01022ae:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f01022b4:	c1 f8 03             	sar    $0x3,%eax
f01022b7:	c1 e0 0c             	shl    $0xc,%eax
f01022ba:	39 c2                	cmp    %eax,%edx
f01022bc:	74 19                	je     f01022d7 <mem_init+0xe79>
f01022be:	68 b8 6c 10 f0       	push   $0xf0106cb8
f01022c3:	68 ab 73 10 f0       	push   $0xf01073ab
f01022c8:	68 10 04 00 00       	push   $0x410
f01022cd:	68 85 73 10 f0       	push   $0xf0107385
f01022d2:	e8 a4 dd ff ff       	call   f010007b <_panic>
	kern_pgdir[0] = 0;
f01022d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022dd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022e2:	74 19                	je     f01022fd <mem_init+0xe9f>
f01022e4:	68 81 75 10 f0       	push   $0xf0107581
f01022e9:	68 ab 73 10 f0       	push   $0xf01073ab
f01022ee:	68 12 04 00 00       	push   $0x412
f01022f3:	68 85 73 10 f0       	push   $0xf0107385
f01022f8:	e8 7e dd ff ff       	call   f010007b <_panic>
	pp0->pp_ref = 0;
f01022fd:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102303:	83 ec 0c             	sub    $0xc,%esp
f0102306:	57                   	push   %edi
f0102307:	e8 83 e8 ff ff       	call   f0100b8f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010230c:	83 c4 0c             	add    $0xc,%esp
f010230f:	6a 01                	push   $0x1
f0102311:	68 00 10 40 00       	push   $0x401000
f0102316:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f010231c:	e8 9b ea ff ff       	call   f0100dbc <pgdir_walk>
f0102321:	89 c1                	mov    %eax,%ecx
f0102323:	89 45 f0             	mov    %eax,-0x10(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102326:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f010232b:	83 c0 04             	add    $0x4,%eax
f010232e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102331:	8b 10                	mov    (%eax),%edx
f0102333:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102339:	89 d0                	mov    %edx,%eax
f010233b:	c1 e8 0c             	shr    $0xc,%eax
f010233e:	83 c4 10             	add    $0x10,%esp
f0102341:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102347:	72 15                	jb     f010235e <mem_init+0xf00>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102349:	52                   	push   %edx
f010234a:	68 dc 64 10 f0       	push   $0xf01064dc
f010234f:	68 19 04 00 00       	push   $0x419
f0102354:	68 85 73 10 f0       	push   $0xf0107385
f0102359:	e8 1d dd ff ff       	call   f010007b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010235e:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102364:	39 c1                	cmp    %eax,%ecx
f0102366:	74 19                	je     f0102381 <mem_init+0xf23>
f0102368:	68 0d 76 10 f0       	push   $0xf010760d
f010236d:	68 ab 73 10 f0       	push   $0xf01073ab
f0102372:	68 1a 04 00 00       	push   $0x41a
f0102377:	68 85 73 10 f0       	push   $0xf0107385
f010237c:	e8 fa dc ff ff       	call   f010007b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102381:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102384:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f010238a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102390:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102393:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102399:	c1 f8 03             	sar    $0x3,%eax
f010239c:	89 c2                	mov    %eax,%edx
f010239e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023a1:	89 d0                	mov    %edx,%eax
f01023a3:	c1 e8 0c             	shr    $0xc,%eax
f01023a6:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f01023ac:	72 12                	jb     f01023c0 <mem_init+0xf62>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023ae:	52                   	push   %edx
f01023af:	68 dc 64 10 f0       	push   $0xf01064dc
f01023b4:	6a 58                	push   $0x58
f01023b6:	68 91 73 10 f0       	push   $0xf0107391
f01023bb:	e8 bb dc ff ff       	call   f010007b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023c0:	83 ec 04             	sub    $0x4,%esp
f01023c3:	68 00 10 00 00       	push   $0x1000
f01023c8:	68 ff 00 00 00       	push   $0xff
f01023cd:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	e8 6b 33 00 00       	call   f0105744 <memset>
	page_free(pp0);
f01023d9:	89 3c 24             	mov    %edi,(%esp)
f01023dc:	e8 ae e7 ff ff       	call   f0100b8f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023e1:	83 c4 0c             	add    $0xc,%esp
f01023e4:	6a 01                	push   $0x1
f01023e6:	6a 00                	push   $0x0
f01023e8:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f01023ee:	e8 c9 e9 ff ff       	call   f0100dbc <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023f6:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f01023fc:	c1 f8 03             	sar    $0x3,%eax
f01023ff:	89 c2                	mov    %eax,%edx
f0102401:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102404:	89 d0                	mov    %edx,%eax
f0102406:	c1 e8 0c             	shr    $0xc,%eax
f0102409:	83 c4 10             	add    $0x10,%esp
f010240c:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102412:	72 12                	jb     f0102426 <mem_init+0xfc8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102414:	52                   	push   %edx
f0102415:	68 dc 64 10 f0       	push   $0xf01064dc
f010241a:	6a 58                	push   $0x58
f010241c:	68 91 73 10 f0       	push   $0xf0107391
f0102421:	e8 55 dc ff ff       	call   f010007b <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102426:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010242c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010242f:	b8 00 00 00 00       	mov    $0x0,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102434:	f6 84 82 00 00 00 f0 	testb  $0x1,-0x10000000(%edx,%eax,4)
f010243b:	01 
f010243c:	74 19                	je     f0102457 <mem_init+0xff9>
f010243e:	68 25 76 10 f0       	push   $0xf0107625
f0102443:	68 ab 73 10 f0       	push   $0xf01073ab
f0102448:	68 24 04 00 00       	push   $0x424
f010244d:	68 85 73 10 f0       	push   $0xf0107385
f0102452:	e8 24 dc ff ff       	call   f010007b <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102457:	40                   	inc    %eax
f0102458:	3d 00 04 00 00       	cmp    $0x400,%eax
f010245d:	75 d5                	jne    f0102434 <mem_init+0xfd6>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010245f:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0102464:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010246a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102470:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102473:	a3 30 f2 1e f0       	mov    %eax,0xf01ef230

	// free the pages we took
	page_free(pp0);
f0102478:	83 ec 0c             	sub    $0xc,%esp
f010247b:	57                   	push   %edi
f010247c:	e8 0e e7 ff ff       	call   f0100b8f <page_free>
	page_free(pp1);
f0102481:	89 34 24             	mov    %esi,(%esp)
f0102484:	e8 06 e7 ff ff       	call   f0100b8f <page_free>
	page_free(pp2);
f0102489:	89 1c 24             	mov    %ebx,(%esp)
f010248c:	e8 fe e6 ff ff       	call   f0100b8f <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102491:	83 c4 08             	add    $0x8,%esp
f0102494:	68 01 10 00 00       	push   $0x1001
f0102499:	6a 00                	push   $0x0
f010249b:	e8 0f ec ff ff       	call   f01010af <mmio_map_region>
f01024a0:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024a2:	83 c4 08             	add    $0x8,%esp
f01024a5:	68 00 10 00 00       	push   $0x1000
f01024aa:	6a 00                	push   $0x0
f01024ac:	e8 fe eb ff ff       	call   f01010af <mmio_map_region>
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01024b1:	83 c4 10             	add    $0x10,%esp
f01024b4:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024ba:	76 0e                	jbe    f01024ca <mem_init+0x106c>
f01024bc:	8d 93 00 20 00 00    	lea    0x2000(%ebx),%edx
f01024c2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024c8:	76 19                	jbe    f01024e3 <mem_init+0x1085>
f01024ca:	68 38 70 10 f0       	push   $0xf0107038
f01024cf:	68 ab 73 10 f0       	push   $0xf01073ab
f01024d4:	68 34 04 00 00       	push   $0x434
f01024d9:	68 85 73 10 f0       	push   $0xf0107385
f01024de:	e8 98 db ff ff       	call   f010007b <_panic>
	page_free(pp1);
	page_free(pp2);

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024e3:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01024e5:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01024ea:	76 0d                	jbe    f01024f9 <mem_init+0x109b>
f01024ec:	8d 80 00 20 00 00    	lea    0x2000(%eax),%eax
f01024f2:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024f7:	76 19                	jbe    f0102512 <mem_init+0x10b4>
f01024f9:	68 60 70 10 f0       	push   $0xf0107060
f01024fe:	68 ab 73 10 f0       	push   $0xf01073ab
f0102503:	68 35 04 00 00       	push   $0x435
f0102508:	68 85 73 10 f0       	push   $0xf0107385
f010250d:	e8 69 db ff ff       	call   f010007b <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102512:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0102518:	75 08                	jne    f0102522 <mem_init+0x10c4>
f010251a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0102520:	74 19                	je     f010253b <mem_init+0x10dd>
f0102522:	68 88 70 10 f0       	push   $0xf0107088
f0102527:	68 ab 73 10 f0       	push   $0xf01073ab
f010252c:	68 37 04 00 00       	push   $0x437
f0102531:	68 85 73 10 f0       	push   $0xf0107385
f0102536:	e8 40 db ff ff       	call   f010007b <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010253b:	39 d6                	cmp    %edx,%esi
f010253d:	73 19                	jae    f0102558 <mem_init+0x10fa>
f010253f:	68 3c 76 10 f0       	push   $0xf010763c
f0102544:	68 ab 73 10 f0       	push   $0xf01073ab
f0102549:	68 39 04 00 00       	push   $0x439
f010254e:	68 85 73 10 f0       	push   $0xf0107385
f0102553:	e8 23 db ff ff       	call   f010007b <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102558:	89 da                	mov    %ebx,%edx
f010255a:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f010255f:	e8 74 e7 ff ff       	call   f0100cd8 <check_va2pa>
f0102564:	85 c0                	test   %eax,%eax
f0102566:	74 19                	je     f0102581 <mem_init+0x1123>
f0102568:	68 b0 70 10 f0       	push   $0xf01070b0
f010256d:	68 ab 73 10 f0       	push   $0xf01073ab
f0102572:	68 3b 04 00 00       	push   $0x43b
f0102577:	68 85 73 10 f0       	push   $0xf0107385
f010257c:	e8 fa da ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102581:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
f0102587:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f010258c:	e8 47 e7 ff ff       	call   f0100cd8 <check_va2pa>
f0102591:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102596:	74 19                	je     f01025b1 <mem_init+0x1153>
f0102598:	68 d4 70 10 f0       	push   $0xf01070d4
f010259d:	68 ab 73 10 f0       	push   $0xf01073ab
f01025a2:	68 3c 04 00 00       	push   $0x43c
f01025a7:	68 85 73 10 f0       	push   $0xf0107385
f01025ac:	e8 ca da ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01025b1:	89 f2                	mov    %esi,%edx
f01025b3:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01025b8:	e8 1b e7 ff ff       	call   f0100cd8 <check_va2pa>
f01025bd:	85 c0                	test   %eax,%eax
f01025bf:	74 19                	je     f01025da <mem_init+0x117c>
f01025c1:	68 04 71 10 f0       	push   $0xf0107104
f01025c6:	68 ab 73 10 f0       	push   $0xf01073ab
f01025cb:	68 3d 04 00 00       	push   $0x43d
f01025d0:	68 85 73 10 f0       	push   $0xf0107385
f01025d5:	e8 a1 da ff ff       	call   f010007b <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025da:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025e0:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01025e5:	e8 ee e6 ff ff       	call   f0100cd8 <check_va2pa>
f01025ea:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025ed:	74 19                	je     f0102608 <mem_init+0x11aa>
f01025ef:	68 28 71 10 f0       	push   $0xf0107128
f01025f4:	68 ab 73 10 f0       	push   $0xf01073ab
f01025f9:	68 3e 04 00 00       	push   $0x43e
f01025fe:	68 85 73 10 f0       	push   $0xf0107385
f0102603:	e8 73 da ff ff       	call   f010007b <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102608:	83 ec 04             	sub    $0x4,%esp
f010260b:	6a 00                	push   $0x0
f010260d:	53                   	push   %ebx
f010260e:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102614:	e8 a3 e7 ff ff       	call   f0100dbc <pgdir_walk>
f0102619:	83 c4 10             	add    $0x10,%esp
f010261c:	f6 00 1a             	testb  $0x1a,(%eax)
f010261f:	75 19                	jne    f010263a <mem_init+0x11dc>
f0102621:	68 54 71 10 f0       	push   $0xf0107154
f0102626:	68 ab 73 10 f0       	push   $0xf01073ab
f010262b:	68 40 04 00 00       	push   $0x440
f0102630:	68 85 73 10 f0       	push   $0xf0107385
f0102635:	e8 41 da ff ff       	call   f010007b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010263a:	83 ec 04             	sub    $0x4,%esp
f010263d:	6a 00                	push   $0x0
f010263f:	53                   	push   %ebx
f0102640:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102646:	e8 71 e7 ff ff       	call   f0100dbc <pgdir_walk>
f010264b:	83 c4 10             	add    $0x10,%esp
f010264e:	f6 00 04             	testb  $0x4,(%eax)
f0102651:	74 19                	je     f010266c <mem_init+0x120e>
f0102653:	68 98 71 10 f0       	push   $0xf0107198
f0102658:	68 ab 73 10 f0       	push   $0xf01073ab
f010265d:	68 41 04 00 00       	push   $0x441
f0102662:	68 85 73 10 f0       	push   $0xf0107385
f0102667:	e8 0f da ff ff       	call   f010007b <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010266c:	83 ec 04             	sub    $0x4,%esp
f010266f:	6a 00                	push   $0x0
f0102671:	53                   	push   %ebx
f0102672:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102678:	e8 3f e7 ff ff       	call   f0100dbc <pgdir_walk>
f010267d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102683:	83 c4 0c             	add    $0xc,%esp
f0102686:	6a 00                	push   $0x0
f0102688:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010268e:	50                   	push   %eax
f010268f:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102695:	e8 22 e7 ff ff       	call   f0100dbc <pgdir_walk>
f010269a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026a0:	83 c4 0c             	add    $0xc,%esp
f01026a3:	6a 00                	push   $0x0
f01026a5:	56                   	push   %esi
f01026a6:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f01026ac:	e8 0b e7 ff ff       	call   f0100dbc <pgdir_walk>
f01026b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01026b7:	c7 04 24 4e 76 10 f0 	movl   $0xf010764e,(%esp)
f01026be:	e8 43 10 00 00       	call   f0103706 <cprintf>
f01026c3:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c8:	83 c4 10             	add    $0x10,%esp
f01026cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d0:	77 15                	ja     f01026e7 <mem_init+0x1289>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d2:	50                   	push   %eax
f01026d3:	68 00 65 10 f0       	push   $0xf0106500
f01026d8:	68 bd 00 00 00       	push   $0xbd
f01026dd:	68 85 73 10 f0       	push   $0xf0107385
f01026e2:	e8 94 d9 ff ff       	call   f010007b <_panic>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01026e7:	83 ec 08             	sub    $0x8,%esp
f01026ea:	6a 04                	push   $0x4
f01026ec:	05 00 00 00 10       	add    $0x10000000,%eax
f01026f1:	50                   	push   %eax
f01026f2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026f7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026fc:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0102701:	e8 2b e9 ff ff       	call   f0101031 <boot_map_region>
f0102706:	a1 38 f2 1e f0       	mov    0xf01ef238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270b:	83 c4 10             	add    $0x10,%esp
f010270e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102713:	77 15                	ja     f010272a <mem_init+0x12cc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102715:	50                   	push   %eax
f0102716:	68 00 65 10 f0       	push   $0xf0106500
f010271b:	68 c6 00 00 00       	push   $0xc6
f0102720:	68 85 73 10 f0       	push   $0xf0107385
f0102725:	e8 51 d9 ff ff       	call   f010007b <_panic>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010272a:	83 ec 08             	sub    $0x8,%esp
f010272d:	6a 04                	push   $0x4
f010272f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102734:	50                   	push   %eax
f0102735:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010273a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010273f:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0102744:	e8 e8 e8 ff ff       	call   f0101031 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102749:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f010274e:	83 c4 10             	add    $0x10,%esp
f0102751:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102756:	77 15                	ja     f010276d <mem_init+0x130f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102758:	50                   	push   %eax
f0102759:	68 00 65 10 f0       	push   $0xf0106500
f010275e:	68 d3 00 00 00       	push   $0xd3
f0102763:	68 85 73 10 f0       	push   $0xf0107385
f0102768:	e8 0e d9 ff ff       	call   f010007b <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010276d:	83 ec 08             	sub    $0x8,%esp
f0102770:	6a 02                	push   $0x2
f0102772:	05 00 00 00 10       	add    $0x10000000,%eax
f0102777:	50                   	push   %eax
f0102778:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010277d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102782:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f0102787:	e8 a5 e8 ff ff       	call   f0101031 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f010278c:	83 c4 08             	add    $0x8,%esp
f010278f:	6a 02                	push   $0x2
f0102791:	6a 00                	push   $0x0
f0102793:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102798:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010279d:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
f01027a2:	e8 8a e8 ff ff       	call   f0101031 <boot_map_region>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
f01027a7:	e8 69 e9 ff ff       	call   f0101115 <mem_init_mp>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027ac:	8b 0d 8c fe 1e f0    	mov    0xf01efe8c,%ecx
f01027b2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027b5:	a1 88 fe 1e f0       	mov    0xf01efe88,%eax
f01027ba:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027c1:	89 c6                	mov    %eax,%esi
f01027c3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01027c9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027ce:	83 c4 10             	add    $0x10,%esp
f01027d1:	eb 5b                	jmp    f010282e <mem_init+0x13d0>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027d3:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01027d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027dc:	e8 f7 e4 ff ff       	call   f0100cd8 <check_va2pa>
f01027e1:	89 c2                	mov    %eax,%edx
f01027e3:	a1 90 fe 1e f0       	mov    0xf01efe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027ed:	77 15                	ja     f0102804 <mem_init+0x13a6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ef:	50                   	push   %eax
f01027f0:	68 00 65 10 f0       	push   $0xf0106500
f01027f5:	68 59 03 00 00       	push   $0x359
f01027fa:	68 85 73 10 f0       	push   $0xf0107385
f01027ff:	e8 77 d8 ff ff       	call   f010007b <_panic>
f0102804:	8d 84 18 00 00 00 10 	lea    0x10000000(%eax,%ebx,1),%eax
f010280b:	39 c2                	cmp    %eax,%edx
f010280d:	74 19                	je     f0102828 <mem_init+0x13ca>
f010280f:	68 cc 71 10 f0       	push   $0xf01071cc
f0102814:	68 ab 73 10 f0       	push   $0xf01073ab
f0102819:	68 59 03 00 00       	push   $0x359
f010281e:	68 85 73 10 f0       	push   $0xf0107385
f0102823:	e8 53 d8 ff ff       	call   f010007b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102828:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010282e:	39 f3                	cmp    %esi,%ebx
f0102830:	72 a1                	jb     f01027d3 <mem_init+0x1375>
f0102832:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102837:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f010283d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102840:	e8 93 e4 ff ff       	call   f0100cd8 <check_va2pa>
f0102845:	89 c2                	mov    %eax,%edx
f0102847:	a1 38 f2 1e f0       	mov    0xf01ef238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010284c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102851:	77 15                	ja     f0102868 <mem_init+0x140a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102853:	50                   	push   %eax
f0102854:	68 00 65 10 f0       	push   $0xf0106500
f0102859:	68 5e 03 00 00       	push   $0x35e
f010285e:	68 85 73 10 f0       	push   $0xf0107385
f0102863:	e8 13 d8 ff ff       	call   f010007b <_panic>
f0102868:	8d 84 18 00 00 00 10 	lea    0x10000000(%eax,%ebx,1),%eax
f010286f:	39 c2                	cmp    %eax,%edx
f0102871:	74 19                	je     f010288c <mem_init+0x142e>
f0102873:	68 00 72 10 f0       	push   $0xf0107200
f0102878:	68 ab 73 10 f0       	push   $0xf01073ab
f010287d:	68 5e 03 00 00       	push   $0x35e
f0102882:	68 85 73 10 f0       	push   $0xf0107385
f0102887:	e8 ef d7 ff ff       	call   f010007b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010288c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102892:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0102898:	75 9d                	jne    f0102837 <mem_init+0x13d9>
f010289a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010289f:	eb 31                	jmp    f01028d2 <mem_init+0x1474>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028a1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028aa:	e8 29 e4 ff ff       	call   f0100cd8 <check_va2pa>
f01028af:	39 c3                	cmp    %eax,%ebx
f01028b1:	74 19                	je     f01028cc <mem_init+0x146e>
f01028b3:	68 34 72 10 f0       	push   $0xf0107234
f01028b8:	68 ab 73 10 f0       	push   $0xf01073ab
f01028bd:	68 62 03 00 00       	push   $0x362
f01028c2:	68 85 73 10 f0       	push   $0xf0107385
f01028c7:	e8 af d7 ff ff       	call   f010007b <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028d2:	a1 88 fe 1e f0       	mov    0xf01efe88,%eax
f01028d7:	c1 e0 0c             	shl    $0xc,%eax
f01028da:	39 c3                	cmp    %eax,%ebx
f01028dc:	72 c3                	jb     f01028a1 <mem_init+0x1443>
f01028de:	bf 00 10 1f f0       	mov    $0xf01f1000,%edi
f01028e3:	c7 45 e0 00 00 ff ef 	movl   $0xefff0000,-0x20(%ebp)
f01028ea:	89 7d d8             	mov    %edi,-0x28(%ebp)
f01028ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028f0:	81 c6 00 80 00 00    	add    $0x8000,%esi
f01028f6:	8d 9f 00 00 00 10    	lea    0x10000000(%edi),%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028fc:	89 f2                	mov    %esi,%edx
f01028fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102901:	e8 d2 e3 ff ff       	call   f0100cd8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102906:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010290c:	77 17                	ja     f0102925 <mem_init+0x14c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010290e:	ff 75 d8             	pushl  -0x28(%ebp)
f0102911:	68 00 65 10 f0       	push   $0xf0106500
f0102916:	68 6a 03 00 00       	push   $0x36a
f010291b:	68 85 73 10 f0       	push   $0xf0107385
f0102920:	e8 56 d7 ff ff       	call   f010007b <_panic>
f0102925:	39 c3                	cmp    %eax,%ebx
f0102927:	74 19                	je     f0102942 <mem_init+0x14e4>
f0102929:	68 5c 72 10 f0       	push   $0xf010725c
f010292e:	68 ab 73 10 f0       	push   $0xf01073ab
f0102933:	68 6a 03 00 00       	push   $0x36a
f0102938:	68 85 73 10 f0       	push   $0xf0107385
f010293d:	e8 39 d7 ff ff       	call   f010007b <_panic>
f0102942:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102948:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010294e:	8d 87 00 80 00 10    	lea    0x10008000(%edi),%eax
f0102954:	39 c3                	cmp    %eax,%ebx
f0102956:	75 a4                	jne    f01028fc <mem_init+0x149e>
f0102958:	bb 00 00 00 00       	mov    $0x0,%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010295d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102960:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0102963:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102966:	e8 6d e3 ff ff       	call   f0100cd8 <check_va2pa>
f010296b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010296e:	74 19                	je     f0102989 <mem_init+0x152b>
f0102970:	68 a4 72 10 f0       	push   $0xf01072a4
f0102975:	68 ab 73 10 f0       	push   $0xf01073ab
f010297a:	68 6c 03 00 00       	push   $0x36c
f010297f:	68 85 73 10 f0       	push   $0xf0107385
f0102984:	e8 f2 d6 ff ff       	call   f010007b <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102989:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010298f:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102995:	75 c6                	jne    f010295d <mem_init+0x14ff>
f0102997:	81 6d e0 00 00 01 00 	subl   $0x10000,-0x20(%ebp)
f010299e:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01029a4:	81 7d e0 00 00 f7 ef 	cmpl   $0xeff70000,-0x20(%ebp)
f01029ab:	0f 85 39 ff ff ff    	jne    f01028ea <mem_init+0x148c>
f01029b1:	ba 00 00 00 00       	mov    $0x0,%edx
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01029b6:	8d 82 45 fc ff ff    	lea    -0x3bb(%edx),%eax
f01029bc:	83 f8 04             	cmp    $0x4,%eax
f01029bf:	77 26                	ja     f01029e7 <mem_init+0x1589>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01029c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029c4:	f6 04 91 01          	testb  $0x1,(%ecx,%edx,4)
f01029c8:	0f 85 83 00 00 00    	jne    f0102a51 <mem_init+0x15f3>
f01029ce:	68 67 76 10 f0       	push   $0xf0107667
f01029d3:	68 ab 73 10 f0       	push   $0xf01073ab
f01029d8:	68 77 03 00 00       	push   $0x377
f01029dd:	68 85 73 10 f0       	push   $0xf0107385
f01029e2:	e8 94 d6 ff ff       	call   f010007b <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01029e7:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f01029ed:	76 40                	jbe    f0102a2f <mem_init+0x15d1>
				assert(pgdir[i] & PTE_P);
f01029ef:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029f2:	8b 04 91             	mov    (%ecx,%edx,4),%eax
f01029f5:	a8 01                	test   $0x1,%al
f01029f7:	75 19                	jne    f0102a12 <mem_init+0x15b4>
f01029f9:	68 67 76 10 f0       	push   $0xf0107667
f01029fe:	68 ab 73 10 f0       	push   $0xf01073ab
f0102a03:	68 7b 03 00 00       	push   $0x37b
f0102a08:	68 85 73 10 f0       	push   $0xf0107385
f0102a0d:	e8 69 d6 ff ff       	call   f010007b <_panic>
				assert(pgdir[i] & PTE_W);
f0102a12:	a8 02                	test   $0x2,%al
f0102a14:	75 3b                	jne    f0102a51 <mem_init+0x15f3>
f0102a16:	68 78 76 10 f0       	push   $0xf0107678
f0102a1b:	68 ab 73 10 f0       	push   $0xf01073ab
f0102a20:	68 7c 03 00 00       	push   $0x37c
f0102a25:	68 85 73 10 f0       	push   $0xf0107385
f0102a2a:	e8 4c d6 ff ff       	call   f010007b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a32:	83 3c 90 00          	cmpl   $0x0,(%eax,%edx,4)
f0102a36:	74 19                	je     f0102a51 <mem_init+0x15f3>
f0102a38:	68 89 76 10 f0       	push   $0xf0107689
f0102a3d:	68 ab 73 10 f0       	push   $0xf01073ab
f0102a42:	68 7e 03 00 00       	push   $0x37e
f0102a47:	68 85 73 10 f0       	push   $0xf0107385
f0102a4c:	e8 2a d6 ff ff       	call   f010007b <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a51:	42                   	inc    %edx
f0102a52:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0102a58:	0f 85 58 ff ff ff    	jne    f01029b6 <mem_init+0x1558>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a5e:	83 ec 0c             	sub    $0xc,%esp
f0102a61:	68 c8 72 10 f0       	push   $0xf01072c8
f0102a66:	e8 9b 0c 00 00       	call   f0103706 <cprintf>
f0102a6b:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a70:	83 c4 10             	add    $0x10,%esp
f0102a73:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a78:	77 15                	ja     f0102a8f <mem_init+0x1631>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a7a:	50                   	push   %eax
f0102a7b:	68 00 65 10 f0       	push   $0xf0106500
f0102a80:	68 ec 00 00 00       	push   $0xec
f0102a85:	68 85 73 10 f0       	push   $0xf0107385
f0102a8a:	e8 ec d5 ff ff       	call   f010007b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102a8f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a94:	0f 22 d8             	mov    %eax,%cr3
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));

	check_page_free_list(0);
f0102a97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a9c:	e8 dc e6 ff ff       	call   f010117d <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102aa1:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102aa4:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102aa9:	83 e0 f3             	and    $0xfffffff3,%eax
f0102aac:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102aaf:	83 ec 0c             	sub    $0xc,%esp
f0102ab2:	6a 00                	push   $0x0
f0102ab4:	e8 7e e2 ff ff       	call   f0100d37 <page_alloc>
f0102ab9:	89 c7                	mov    %eax,%edi
f0102abb:	83 c4 10             	add    $0x10,%esp
f0102abe:	85 c0                	test   %eax,%eax
f0102ac0:	75 19                	jne    f0102adb <mem_init+0x167d>
f0102ac2:	68 73 74 10 f0       	push   $0xf0107473
f0102ac7:	68 ab 73 10 f0       	push   $0xf01073ab
f0102acc:	68 56 04 00 00       	push   $0x456
f0102ad1:	68 85 73 10 f0       	push   $0xf0107385
f0102ad6:	e8 a0 d5 ff ff       	call   f010007b <_panic>
	assert((pp1 = page_alloc(0)));
f0102adb:	83 ec 0c             	sub    $0xc,%esp
f0102ade:	6a 00                	push   $0x0
f0102ae0:	e8 52 e2 ff ff       	call   f0100d37 <page_alloc>
f0102ae5:	89 c6                	mov    %eax,%esi
f0102ae7:	83 c4 10             	add    $0x10,%esp
f0102aea:	85 c0                	test   %eax,%eax
f0102aec:	75 19                	jne    f0102b07 <mem_init+0x16a9>
f0102aee:	68 89 74 10 f0       	push   $0xf0107489
f0102af3:	68 ab 73 10 f0       	push   $0xf01073ab
f0102af8:	68 57 04 00 00       	push   $0x457
f0102afd:	68 85 73 10 f0       	push   $0xf0107385
f0102b02:	e8 74 d5 ff ff       	call   f010007b <_panic>
	assert((pp2 = page_alloc(0)));
f0102b07:	83 ec 0c             	sub    $0xc,%esp
f0102b0a:	6a 00                	push   $0x0
f0102b0c:	e8 26 e2 ff ff       	call   f0100d37 <page_alloc>
f0102b11:	89 c3                	mov    %eax,%ebx
f0102b13:	83 c4 10             	add    $0x10,%esp
f0102b16:	85 c0                	test   %eax,%eax
f0102b18:	75 19                	jne    f0102b33 <mem_init+0x16d5>
f0102b1a:	68 9f 74 10 f0       	push   $0xf010749f
f0102b1f:	68 ab 73 10 f0       	push   $0xf01073ab
f0102b24:	68 58 04 00 00       	push   $0x458
f0102b29:	68 85 73 10 f0       	push   $0xf0107385
f0102b2e:	e8 48 d5 ff ff       	call   f010007b <_panic>
	page_free(pp0);
f0102b33:	83 ec 0c             	sub    $0xc,%esp
f0102b36:	57                   	push   %edi
f0102b37:	e8 53 e0 ff ff       	call   f0100b8f <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b3c:	89 f0                	mov    %esi,%eax
f0102b3e:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102b44:	c1 f8 03             	sar    $0x3,%eax
f0102b47:	89 c2                	mov    %eax,%edx
f0102b49:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b4c:	89 d0                	mov    %edx,%eax
f0102b4e:	c1 e8 0c             	shr    $0xc,%eax
f0102b51:	83 c4 10             	add    $0x10,%esp
f0102b54:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102b5a:	72 12                	jb     f0102b6e <mem_init+0x1710>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b5c:	52                   	push   %edx
f0102b5d:	68 dc 64 10 f0       	push   $0xf01064dc
f0102b62:	6a 58                	push   $0x58
f0102b64:	68 91 73 10 f0       	push   $0xf0107391
f0102b69:	e8 0d d5 ff ff       	call   f010007b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b6e:	83 ec 04             	sub    $0x4,%esp
f0102b71:	68 00 10 00 00       	push   $0x1000
f0102b76:	6a 01                	push   $0x1
f0102b78:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102b7e:	50                   	push   %eax
f0102b7f:	e8 c0 2b 00 00       	call   f0105744 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b84:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0102b87:	89 d8                	mov    %ebx,%eax
f0102b89:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102b8f:	c1 f8 03             	sar    $0x3,%eax
f0102b92:	89 c2                	mov    %eax,%edx
f0102b94:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b97:	89 d0                	mov    %edx,%eax
f0102b99:	c1 e8 0c             	shr    $0xc,%eax
f0102b9c:	83 c4 10             	add    $0x10,%esp
f0102b9f:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102ba5:	72 12                	jb     f0102bb9 <mem_init+0x175b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ba7:	52                   	push   %edx
f0102ba8:	68 dc 64 10 f0       	push   $0xf01064dc
f0102bad:	6a 58                	push   $0x58
f0102baf:	68 91 73 10 f0       	push   $0xf0107391
f0102bb4:	e8 c2 d4 ff ff       	call   f010007b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bb9:	83 ec 04             	sub    $0x4,%esp
f0102bbc:	68 00 10 00 00       	push   $0x1000
f0102bc1:	6a 02                	push   $0x2
f0102bc3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102bc9:	50                   	push   %eax
f0102bca:	e8 75 2b 00 00       	call   f0105744 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bcf:	6a 02                	push   $0x2
f0102bd1:	68 00 10 00 00       	push   $0x1000
f0102bd6:	56                   	push   %esi
f0102bd7:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102bdd:	e8 dc e3 ff ff       	call   f0100fbe <page_insert>
	assert(pp1->pp_ref == 1);
f0102be2:	83 c4 20             	add    $0x20,%esp
f0102be5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102bea:	74 19                	je     f0102c05 <mem_init+0x17a7>
f0102bec:	68 70 75 10 f0       	push   $0xf0107570
f0102bf1:	68 ab 73 10 f0       	push   $0xf01073ab
f0102bf6:	68 5d 04 00 00       	push   $0x45d
f0102bfb:	68 85 73 10 f0       	push   $0xf0107385
f0102c00:	e8 76 d4 ff ff       	call   f010007b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c05:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c0c:	01 01 01 
f0102c0f:	74 19                	je     f0102c2a <mem_init+0x17cc>
f0102c11:	68 e8 72 10 f0       	push   $0xf01072e8
f0102c16:	68 ab 73 10 f0       	push   $0xf01073ab
f0102c1b:	68 5e 04 00 00       	push   $0x45e
f0102c20:	68 85 73 10 f0       	push   $0xf0107385
f0102c25:	e8 51 d4 ff ff       	call   f010007b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c2a:	6a 02                	push   $0x2
f0102c2c:	68 00 10 00 00       	push   $0x1000
f0102c31:	53                   	push   %ebx
f0102c32:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102c38:	e8 81 e3 ff ff       	call   f0100fbe <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c3d:	83 c4 10             	add    $0x10,%esp
f0102c40:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c47:	02 02 02 
f0102c4a:	74 19                	je     f0102c65 <mem_init+0x1807>
f0102c4c:	68 0c 73 10 f0       	push   $0xf010730c
f0102c51:	68 ab 73 10 f0       	push   $0xf01073ab
f0102c56:	68 60 04 00 00       	push   $0x460
f0102c5b:	68 85 73 10 f0       	push   $0xf0107385
f0102c60:	e8 16 d4 ff ff       	call   f010007b <_panic>
	assert(pp2->pp_ref == 1);
f0102c65:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c6a:	74 19                	je     f0102c85 <mem_init+0x1827>
f0102c6c:	68 92 75 10 f0       	push   $0xf0107592
f0102c71:	68 ab 73 10 f0       	push   $0xf01073ab
f0102c76:	68 61 04 00 00       	push   $0x461
f0102c7b:	68 85 73 10 f0       	push   $0xf0107385
f0102c80:	e8 f6 d3 ff ff       	call   f010007b <_panic>
	assert(pp1->pp_ref == 0);
f0102c85:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c8a:	74 19                	je     f0102ca5 <mem_init+0x1847>
f0102c8c:	68 fc 75 10 f0       	push   $0xf01075fc
f0102c91:	68 ab 73 10 f0       	push   $0xf01073ab
f0102c96:	68 62 04 00 00       	push   $0x462
f0102c9b:	68 85 73 10 f0       	push   $0xf0107385
f0102ca0:	e8 d6 d3 ff ff       	call   f010007b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ca5:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cac:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102caf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102cb2:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102cb8:	c1 f8 03             	sar    $0x3,%eax
f0102cbb:	89 c2                	mov    %eax,%edx
f0102cbd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cc0:	89 d0                	mov    %edx,%eax
f0102cc2:	c1 e8 0c             	shr    $0xc,%eax
f0102cc5:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102ccb:	72 12                	jb     f0102cdf <mem_init+0x1881>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ccd:	52                   	push   %edx
f0102cce:	68 dc 64 10 f0       	push   $0xf01064dc
f0102cd3:	6a 58                	push   $0x58
f0102cd5:	68 91 73 10 f0       	push   $0xf0107391
f0102cda:	e8 9c d3 ff ff       	call   f010007b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cdf:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102ce6:	03 03 03 
f0102ce9:	74 19                	je     f0102d04 <mem_init+0x18a6>
f0102ceb:	68 30 73 10 f0       	push   $0xf0107330
f0102cf0:	68 ab 73 10 f0       	push   $0xf01073ab
f0102cf5:	68 64 04 00 00       	push   $0x464
f0102cfa:	68 85 73 10 f0       	push   $0xf0107385
f0102cff:	e8 77 d3 ff ff       	call   f010007b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d04:	83 ec 08             	sub    $0x8,%esp
f0102d07:	68 00 10 00 00       	push   $0x1000
f0102d0c:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102d12:	e8 61 e2 ff ff       	call   f0100f78 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d17:	83 c4 10             	add    $0x10,%esp
f0102d1a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d1f:	74 19                	je     f0102d3a <mem_init+0x18dc>
f0102d21:	68 ca 75 10 f0       	push   $0xf01075ca
f0102d26:	68 ab 73 10 f0       	push   $0xf01073ab
f0102d2b:	68 66 04 00 00       	push   $0x466
f0102d30:	68 85 73 10 f0       	push   $0xf0107385
f0102d35:	e8 41 d3 ff ff       	call   f010007b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d3a:	8b 0d 8c fe 1e f0    	mov    0xf01efe8c,%ecx
f0102d40:	8b 11                	mov    (%ecx),%edx
f0102d42:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d48:	89 f8                	mov    %edi,%eax
f0102d4a:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102d50:	c1 f8 03             	sar    $0x3,%eax
f0102d53:	c1 e0 0c             	shl    $0xc,%eax
f0102d56:	39 c2                	cmp    %eax,%edx
f0102d58:	74 19                	je     f0102d73 <mem_init+0x1915>
f0102d5a:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0102d5f:	68 ab 73 10 f0       	push   $0xf01073ab
f0102d64:	68 69 04 00 00       	push   $0x469
f0102d69:	68 85 73 10 f0       	push   $0xf0107385
f0102d6e:	e8 08 d3 ff ff       	call   f010007b <_panic>
	kern_pgdir[0] = 0;
f0102d73:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d79:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d7e:	74 19                	je     f0102d99 <mem_init+0x193b>
f0102d80:	68 81 75 10 f0       	push   $0xf0107581
f0102d85:	68 ab 73 10 f0       	push   $0xf01073ab
f0102d8a:	68 6b 04 00 00       	push   $0x46b
f0102d8f:	68 85 73 10 f0       	push   $0xf0107385
f0102d94:	e8 e2 d2 ff ff       	call   f010007b <_panic>
	pp0->pp_ref = 0;
f0102d99:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// free the pages we took
	page_free(pp0);
f0102d9f:	83 ec 0c             	sub    $0xc,%esp
f0102da2:	57                   	push   %edi
f0102da3:	e8 e7 dd ff ff       	call   f0100b8f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102da8:	c7 04 24 5c 73 10 f0 	movl   $0xf010735c,(%esp)
f0102daf:	e8 52 09 00 00       	call   f0103706 <cprintf>
f0102db4:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dba:	5b                   	pop    %ebx
f0102dbb:	5e                   	pop    %esi
f0102dbc:	5f                   	pop    %edi
f0102dbd:	c9                   	leave  
f0102dbe:	c3                   	ret    
	...

f0102dc0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102dc0:	55                   	push   %ebp
f0102dc1:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102dc3:	b8 88 43 12 f0       	mov    $0xf0124388,%eax
f0102dc8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102dcb:	b8 23 00 00 00       	mov    $0x23,%eax
f0102dd0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102dd2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102dd4:	b0 10                	mov    $0x10,%al
f0102dd6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102dd8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102dda:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102ddc:	ea e3 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102de3
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102de3:	b0 00                	mov    $0x0,%al
f0102de5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102de8:	c9                   	leave  
f0102de9:	c3                   	ret    

f0102dea <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102dea:	55                   	push   %ebp
f0102deb:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f0102ded:	c7 05 3c f2 1e f0 00 	movl   $0x0,0xf01ef23c
f0102df4:	00 00 00 
f0102df7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102dfc:	ba 84 ef 01 00       	mov    $0x1ef84,%edx
	for (int i = NENV - 1; i >= 0; i--) {	
		envs[i].env_id = 0;
f0102e01:	a1 38 f2 1e f0       	mov    0xf01ef238,%eax
f0102e06:	c7 44 10 48 00 00 00 	movl   $0x0,0x48(%eax,%edx,1)
f0102e0d:	00 
		envs[i].env_link = env_free_list;
f0102e0e:	a1 38 f2 1e f0       	mov    0xf01ef238,%eax
f0102e13:	89 4c 10 44          	mov    %ecx,0x44(%eax,%edx,1)
		env_free_list = &envs[i];
f0102e17:	89 d1                	mov    %edx,%ecx
f0102e19:	03 0d 38 f2 1e f0    	add    0xf01ef238,%ecx
f0102e1f:	83 ea 7c             	sub    $0x7c,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
	for (int i = NENV - 1; i >= 0; i--) {	
f0102e22:	83 fa 84             	cmp    $0xffffff84,%edx
f0102e25:	75 da                	jne    f0102e01 <env_init+0x17>
f0102e27:	89 0d 3c f2 1e f0    	mov    %ecx,0xf01ef23c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();    //加载GDT
f0102e2d:	e8 8e ff ff ff       	call   f0102dc0 <env_init_percpu>
}
f0102e32:	c9                   	leave  
f0102e33:	c3                   	ret    

f0102e34 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e34:	55                   	push   %ebp
f0102e35:	89 e5                	mov    %esp,%ebp
f0102e37:	57                   	push   %edi
f0102e38:	56                   	push   %esi
f0102e39:	53                   	push   %ebx
f0102e3a:	83 ec 0c             	sub    $0xc,%esp
f0102e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102e40:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102e43:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e46:	85 c9                	test   %ecx,%ecx
f0102e48:	75 24                	jne    f0102e6e <envid2env+0x3a>
		*env_store = curenv;
f0102e4a:	e8 1f 2f 00 00       	call   f0105d6e <cpunum>
f0102e4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102e56:	29 c2                	sub    %eax,%edx
f0102e58:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102e5b:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0102e62:	89 07                	mov    %eax,(%edi)
f0102e64:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e69:	e9 85 00 00 00       	jmp    f0102ef3 <envid2env+0xbf>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e6e:	89 c8                	mov    %ecx,%eax
f0102e70:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102e75:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102e7c:	c1 e0 07             	shl    $0x7,%eax
f0102e7f:	29 d0                	sub    %edx,%eax
f0102e81:	89 c6                	mov    %eax,%esi
f0102e83:	03 35 38 f2 1e f0    	add    0xf01ef238,%esi
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e89:	83 7e 54 00          	cmpl   $0x0,0x54(%esi)
f0102e8d:	74 05                	je     f0102e94 <envid2env+0x60>
f0102e8f:	3b 4e 48             	cmp    0x48(%esi),%ecx
f0102e92:	74 0d                	je     f0102ea1 <envid2env+0x6d>
		*env_store = 0;
f0102e94:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
f0102e9a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e9f:	eb 52                	jmp    f0102ef3 <envid2env+0xbf>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ea1:	84 db                	test   %bl,%bl
f0102ea3:	74 47                	je     f0102eec <envid2env+0xb8>
f0102ea5:	e8 c4 2e 00 00       	call   f0105d6e <cpunum>
f0102eaa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102eb1:	29 c2                	sub    %eax,%edx
f0102eb3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102eb6:	3b 34 95 28 00 1f f0 	cmp    -0xfe0ffd8(,%edx,4),%esi
f0102ebd:	74 2d                	je     f0102eec <envid2env+0xb8>
f0102ebf:	8b 5e 4c             	mov    0x4c(%esi),%ebx
f0102ec2:	e8 a7 2e 00 00       	call   f0105d6e <cpunum>
f0102ec7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102ece:	29 c2                	sub    %eax,%edx
f0102ed0:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102ed3:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0102eda:	3b 58 48             	cmp    0x48(%eax),%ebx
f0102edd:	74 0d                	je     f0102eec <envid2env+0xb8>
		*env_store = 0;
f0102edf:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
f0102ee5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eea:	eb 07                	jmp    f0102ef3 <envid2env+0xbf>
		return -E_BAD_ENV;
	}

	*env_store = e;
f0102eec:	89 37                	mov    %esi,(%edi)
f0102eee:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0102ef3:	83 c4 0c             	add    $0xc,%esp
f0102ef6:	5b                   	pop    %ebx
f0102ef7:	5e                   	pop    %esi
f0102ef8:	5f                   	pop    %edi
f0102ef9:	c9                   	leave  
f0102efa:	c3                   	ret    

f0102efb <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102efb:	55                   	push   %ebp
f0102efc:	89 e5                	mov    %esp,%ebp
f0102efe:	56                   	push   %esi
f0102eff:	53                   	push   %ebx
f0102f00:	8b 75 08             	mov    0x8(%ebp),%esi
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0102f03:	e8 66 2e 00 00       	call   f0105d6e <cpunum>
f0102f08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0102f0f:	29 c2                	sub    %eax,%edx
f0102f11:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f14:	8b 1c 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%ebx
f0102f1b:	e8 4e 2e 00 00       	call   f0105d6e <cpunum>
f0102f20:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0102f23:	89 f4                	mov    %esi,%esp
f0102f25:	61                   	popa   
f0102f26:	07                   	pop    %es
f0102f27:	1f                   	pop    %ds
f0102f28:	83 c4 08             	add    $0x8,%esp
f0102f2b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f2c:	83 ec 04             	sub    $0x4,%esp
f0102f2f:	68 97 76 10 f0       	push   $0xf0107697
f0102f34:	68 01 02 00 00       	push   $0x201
f0102f39:	68 a3 76 10 f0       	push   $0xf01076a3
f0102f3e:	e8 38 d1 ff ff       	call   f010007b <_panic>

f0102f43 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f43:	55                   	push   %ebp
f0102f44:	89 e5                	mov    %esp,%ebp
f0102f46:	56                   	push   %esi
f0102f47:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f48:	8b 1d 3c f2 1e f0    	mov    0xf01ef23c,%ebx
f0102f4e:	85 db                	test   %ebx,%ebx
f0102f50:	75 0a                	jne    f0102f5c <env_alloc+0x19>
f0102f52:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102f57:	e9 4d 01 00 00       	jmp    f01030a9 <env_alloc+0x166>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))  //分配一页，page alloc只会从空闲表中找一页，修改link部分为NULL，因此我们需要增加ref
f0102f5c:	83 ec 0c             	sub    $0xc,%esp
f0102f5f:	6a 01                	push   $0x1
f0102f61:	e8 d1 dd ff ff       	call   f0100d37 <page_alloc>
f0102f66:	83 c4 10             	add    $0x10,%esp
f0102f69:	85 c0                	test   %eax,%eax
f0102f6b:	75 0a                	jne    f0102f77 <env_alloc+0x34>
f0102f6d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102f72:	e9 32 01 00 00       	jmp    f01030a9 <env_alloc+0x166>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102f77:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f7b:	2b 05 90 fe 1e f0    	sub    0xf01efe90,%eax
f0102f81:	c1 f8 03             	sar    $0x3,%eax
f0102f84:	89 c2                	mov    %eax,%edx
f0102f86:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f89:	89 d0                	mov    %edx,%eax
f0102f8b:	c1 e8 0c             	shr    $0xc,%eax
f0102f8e:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0102f94:	72 12                	jb     f0102fa8 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f96:	52                   	push   %edx
f0102f97:	68 dc 64 10 f0       	push   $0xf01064dc
f0102f9c:	6a 58                	push   $0x58
f0102f9e:	68 91 73 10 f0       	push   $0xf0107391
f0102fa3:	e8 d3 d0 ff ff       	call   f010007b <_panic>
	e->env_pgdir = (pde_t *) page2kva(p);  //页目录指向
f0102fa8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102fae:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); //模仿内核页目录
f0102fb1:	83 ec 04             	sub    $0x4,%esp
f0102fb4:	68 00 10 00 00       	push   $0x1000
f0102fb9:	ff 35 8c fe 1e f0    	pushl  0xf01efe8c
f0102fbf:	50                   	push   %eax
f0102fc0:	e8 3d 28 00 00       	call   f0105802 <memcpy>
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;  //模仿，修改页目录项为用户的
f0102fc5:	8b 53 60             	mov    0x60(%ebx),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc8:	89 d0                	mov    %edx,%eax
f0102fca:	83 c4 10             	add    $0x10,%esp
f0102fcd:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fd3:	77 15                	ja     f0102fea <env_alloc+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fd5:	52                   	push   %edx
f0102fd6:	68 00 65 10 f0       	push   $0xf0106500
f0102fdb:	68 c5 00 00 00       	push   $0xc5
f0102fe0:	68 a3 76 10 f0       	push   $0xf01076a3
f0102fe5:	e8 91 d0 ff ff       	call   f010007b <_panic>
f0102fea:	05 00 00 00 10       	add    $0x10000000,%eax
f0102fef:	83 c8 05             	or     $0x5,%eax
f0102ff2:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ff8:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ffb:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103000:	89 c6                	mov    %eax,%esi
f0103002:	81 e6 00 fc ff ff    	and    $0xfffffc00,%esi
f0103008:	7f 05                	jg     f010300f <env_alloc+0xcc>
f010300a:	be 00 10 00 00       	mov    $0x1000,%esi
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f010300f:	89 d9                	mov    %ebx,%ecx
f0103011:	2b 0d 38 f2 1e f0    	sub    0xf01ef238,%ecx
f0103017:	c1 f9 02             	sar    $0x2,%ecx
f010301a:	89 c8                	mov    %ecx,%eax
f010301c:	c1 e0 05             	shl    $0x5,%eax
f010301f:	89 ca                	mov    %ecx,%edx
f0103021:	c1 e2 0a             	shl    $0xa,%edx
f0103024:	01 d0                	add    %edx,%eax
f0103026:	01 c8                	add    %ecx,%eax
f0103028:	89 c2                	mov    %eax,%edx
f010302a:	c1 e2 0f             	shl    $0xf,%edx
f010302d:	01 d0                	add    %edx,%eax
f010302f:	c1 e0 05             	shl    $0x5,%eax
f0103032:	01 c8                	add    %ecx,%eax
f0103034:	f7 d8                	neg    %eax
f0103036:	09 f0                	or     %esi,%eax
f0103038:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010303b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010303e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103041:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103048:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010304f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103056:	83 ec 04             	sub    $0x4,%esp
f0103059:	6a 44                	push   $0x44
f010305b:	6a 00                	push   $0x0
f010305d:	53                   	push   %ebx
f010305e:	e8 e1 26 00 00       	call   f0105744 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103063:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103069:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010306f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103075:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010307c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103082:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103089:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103090:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103094:	8b 43 44             	mov    0x44(%ebx),%eax
f0103097:	a3 3c f2 1e f0       	mov    %eax,0xf01ef23c
	*newenv_store = e;
f010309c:	8b 45 08             	mov    0x8(%ebp),%eax
f010309f:	89 18                	mov    %ebx,(%eax)
f01030a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a6:	83 c4 10             	add    $0x10,%esp

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030ac:	5b                   	pop    %ebx
f01030ad:	5e                   	pop    %esi
f01030ae:	c9                   	leave  
f01030af:	c3                   	ret    

f01030b0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01030b0:	55                   	push   %ebp
f01030b1:	89 e5                	mov    %esp,%ebp
f01030b3:	57                   	push   %edi
f01030b4:	56                   	push   %esi
f01030b5:	53                   	push   %ebx
f01030b6:	83 ec 0c             	sub    $0xc,%esp
f01030b9:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	void *start = ROUNDDOWN(va, PGSIZE);
f01030bb:	89 d3                	mov    %edx,%ebx
f01030bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va+len, PGSIZE);
f01030c3:	8d 94 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edx
f01030ca:	89 d6                	mov    %edx,%esi
f01030cc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01030d2:	eb 58                	jmp    f010312c <region_alloc+0x7c>
	while (start < end) {//开区间所以不等
		struct PageInfo *p = page_alloc(0); //分配一个物理页
f01030d4:	83 ec 0c             	sub    $0xc,%esp
f01030d7:	6a 00                	push   $0x0
f01030d9:	e8 59 dc ff ff       	call   f0100d37 <page_alloc>
		if (!p) {
f01030de:	83 c4 10             	add    $0x10,%esp
f01030e1:	85 c0                	test   %eax,%eax
f01030e3:	75 17                	jne    f01030fc <region_alloc+0x4c>
			panic("fault: region_alloc: page_alloc failed\n");
f01030e5:	83 ec 04             	sub    $0x4,%esp
f01030e8:	68 b0 76 10 f0       	push   $0xf01076b0
f01030ed:	68 23 01 00 00       	push   $0x123
f01030f2:	68 a3 76 10 f0       	push   $0xf01076a3
f01030f7:	e8 7f cf ff ff       	call   f010007b <_panic>
		}
		if(page_insert(e->env_pgdir, p, start, PTE_W | PTE_U) != 0){//建立映射,成功返回0
f01030fc:	6a 06                	push   $0x6
f01030fe:	53                   	push   %ebx
f01030ff:	50                   	push   %eax
f0103100:	ff 77 60             	pushl  0x60(%edi)
f0103103:	e8 b6 de ff ff       	call   f0100fbe <page_insert>
f0103108:	83 c4 10             	add    $0x10,%esp
f010310b:	85 c0                	test   %eax,%eax
f010310d:	74 17                	je     f0103126 <region_alloc+0x76>
			panic("fault: region_alloc: page_insert failed\n");
f010310f:	83 ec 04             	sub    $0x4,%esp
f0103112:	68 d8 76 10 f0       	push   $0xf01076d8
f0103117:	68 26 01 00 00       	push   $0x126
f010311c:	68 a3 76 10 f0       	push   $0xf01076a3
f0103121:	e8 55 cf ff ff       	call   f010007b <_panic>
		}   
		start += PGSIZE;
f0103126:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	void *start = ROUNDDOWN(va, PGSIZE);
	void *end = ROUNDUP(va+len, PGSIZE);
	while (start < end) {//开区间所以不等
f010312c:	39 f3                	cmp    %esi,%ebx
f010312e:	72 a4                	jb     f01030d4 <region_alloc+0x24>
	}
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103130:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103133:	5b                   	pop    %ebx
f0103134:	5e                   	pop    %esi
f0103135:	5f                   	pop    %edi
f0103136:	c9                   	leave  
f0103137:	c3                   	ret    

f0103138 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103138:	55                   	push   %ebp
f0103139:	89 e5                	mov    %esp,%ebp
f010313b:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f010313e:	e8 2b 2c 00 00       	call   f0105d6e <cpunum>
f0103143:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010314a:	29 c2                	sub    %eax,%edx
f010314c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010314f:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f0103156:	00 
f0103157:	74 3d                	je     f0103196 <env_run+0x5e>
f0103159:	e8 10 2c 00 00       	call   f0105d6e <cpunum>
f010315e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103165:	29 c2                	sub    %eax,%edx
f0103167:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010316a:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0103171:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103175:	75 1f                	jne    f0103196 <env_run+0x5e>
       	 curenv->env_status = ENV_RUNNABLE;
f0103177:	e8 f2 2b 00 00       	call   f0105d6e <cpunum>
f010317c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103183:	29 c2                	sub    %eax,%edx
f0103185:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103188:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f010318f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
    	}

    	  curenv = e;
f0103196:	e8 d3 2b 00 00       	call   f0105d6e <cpunum>
f010319b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01031a2:	29 c2                	sub    %eax,%edx
f01031a4:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031aa:	89 04 95 28 00 1f f0 	mov    %eax,-0xfe0ffd8(,%edx,4)
  	  curenv->env_status = ENV_RUNNING;
f01031b1:	e8 b8 2b 00 00       	call   f0105d6e <cpunum>
f01031b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01031bd:	29 c2                	sub    %eax,%edx
f01031bf:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01031c2:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01031c9:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
  	  curenv->env_runs++;
f01031d0:	e8 99 2b 00 00       	call   f0105d6e <cpunum>
f01031d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01031dc:	29 c2                	sub    %eax,%edx
f01031de:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01031e1:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01031e8:	ff 40 58             	incl   0x58(%eax)
	  lcr3(PADDR(curenv->env_pgdir));//页目录切换
f01031eb:	e8 7e 2b 00 00       	call   f0105d6e <cpunum>
f01031f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01031f7:	29 c2                	sub    %eax,%edx
f01031f9:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01031fc:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0103203:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010320b:	77 15                	ja     f0103222 <env_run+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010320d:	50                   	push   %eax
f010320e:	68 00 65 10 f0       	push   $0xf0106500
f0103213:	68 26 02 00 00       	push   $0x226
f0103218:	68 a3 76 10 f0       	push   $0xf01076a3
f010321d:	e8 59 ce ff ff       	call   f010007b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103222:	05 00 00 00 10       	add    $0x10000000,%eax
f0103227:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010322a:	83 ec 0c             	sub    $0xc,%esp
f010322d:	68 a0 43 12 f0       	push   $0xf01243a0
f0103232:	e8 ec 2d 00 00       	call   f0106023 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103237:	f3 90                	pause  
	  unlock_kernel();
 	  env_pop_tf(&curenv->env_tf);
f0103239:	e8 30 2b 00 00       	call   f0105d6e <cpunum>
f010323e:	83 c4 04             	add    $0x4,%esp
f0103241:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103248:	29 c2                	sub    %eax,%edx
f010324a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010324d:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f0103254:	e8 a2 fc ff ff       	call   f0102efb <env_pop_tf>

f0103259 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103259:	55                   	push   %ebp
f010325a:	89 e5                	mov    %esp,%ebp
f010325c:	57                   	push   %edi
f010325d:	56                   	push   %esi
f010325e:	53                   	push   %ebx
f010325f:	83 ec 0c             	sub    $0xc,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103262:	e8 07 2b 00 00       	call   f0105d6e <cpunum>
f0103267:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010326e:	29 c2                	sub    %eax,%edx
f0103270:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103273:	8b 45 08             	mov    0x8(%ebp),%eax
f0103276:	39 04 95 28 00 1f f0 	cmp    %eax,-0xfe0ffd8(,%edx,4)
f010327d:	74 09                	je     f0103288 <env_free+0x2f>
f010327f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0103286:	eb 30                	jmp    f01032b8 <env_free+0x5f>
f0103288:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010328d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103292:	77 15                	ja     f01032a9 <env_free+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103294:	50                   	push   %eax
f0103295:	68 00 65 10 f0       	push   $0xf0106500
f010329a:	68 ad 01 00 00       	push   $0x1ad
f010329f:	68 a3 76 10 f0       	push   $0xf01076a3
f01032a4:	e8 d2 cd ff ff       	call   f010007b <_panic>
f01032a9:	05 00 00 00 10       	add    $0x10000000,%eax
f01032ae:	0f 22 d8             	mov    %eax,%cr3
f01032b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01032b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01032bb:	c1 e2 02             	shl    $0x2,%edx
f01032be:	89 55 e8             	mov    %edx,-0x18(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032c1:	8b 55 08             	mov    0x8(%ebp),%edx
f01032c4:	8b 42 60             	mov    0x60(%edx),%eax
f01032c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01032ca:	8b 04 02             	mov    (%edx,%eax,1),%eax
f01032cd:	a8 01                	test   $0x1,%al
f01032cf:	0f 84 ab 00 00 00    	je     f0103380 <env_free+0x127>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032d5:	89 c6                	mov    %eax,%esi
f01032d7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032dd:	89 f0                	mov    %esi,%eax
f01032df:	c1 e8 0c             	shr    $0xc,%eax
f01032e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01032e5:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f01032eb:	72 15                	jb     f0103302 <env_free+0xa9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ed:	56                   	push   %esi
f01032ee:	68 dc 64 10 f0       	push   $0xf01064dc
f01032f3:	68 bc 01 00 00       	push   $0x1bc
f01032f8:	68 a3 76 10 f0       	push   $0xf01076a3
f01032fd:	e8 79 cd ff ff       	call   f010007b <_panic>
f0103302:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103307:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010330a:	c1 e7 16             	shl    $0x16,%edi
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f010330d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103314:	01 
f0103315:	74 19                	je     f0103330 <env_free+0xd7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103317:	83 ec 08             	sub    $0x8,%esp
f010331a:	89 d8                	mov    %ebx,%eax
f010331c:	c1 e0 0c             	shl    $0xc,%eax
f010331f:	09 f8                	or     %edi,%eax
f0103321:	50                   	push   %eax
f0103322:	8b 55 08             	mov    0x8(%ebp),%edx
f0103325:	ff 72 60             	pushl  0x60(%edx)
f0103328:	e8 4b dc ff ff       	call   f0100f78 <page_remove>
f010332d:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103330:	43                   	inc    %ebx
f0103331:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103337:	75 d4                	jne    f010330d <env_free+0xb4>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103339:	8b 55 08             	mov    0x8(%ebp),%edx
f010333c:	8b 42 60             	mov    0x60(%edx),%eax
f010333f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103342:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103349:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010334c:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0103352:	72 14                	jb     f0103368 <env_free+0x10f>
		panic("pa2page called with invalid pa");
f0103354:	83 ec 04             	sub    $0x4,%esp
f0103357:	68 90 6a 10 f0       	push   $0xf0106a90
f010335c:	6a 51                	push   $0x51
f010335e:	68 91 73 10 f0       	push   $0xf0107391
f0103363:	e8 13 cd ff ff       	call   f010007b <_panic>
		page_decref(pa2page(pa));
f0103368:	83 ec 0c             	sub    $0xc,%esp
f010336b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010336e:	c1 e0 03             	shl    $0x3,%eax
f0103371:	03 05 90 fe 1e f0    	add    0xf01efe90,%eax
f0103377:	50                   	push   %eax
f0103378:	e8 4d d8 ff ff       	call   f0100bca <page_decref>
f010337d:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103380:	ff 45 ec             	incl   -0x14(%ebp)
f0103383:	81 7d ec bb 03 00 00 	cmpl   $0x3bb,-0x14(%ebp)
f010338a:	0f 85 28 ff ff ff    	jne    f01032b8 <env_free+0x5f>
f0103390:	8b 55 08             	mov    0x8(%ebp),%edx
f0103393:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103396:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339b:	77 15                	ja     f01033b2 <env_free+0x159>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010339d:	50                   	push   %eax
f010339e:	68 00 65 10 f0       	push   $0xf0106500
f01033a3:	68 ca 01 00 00       	push   $0x1ca
f01033a8:	68 a3 76 10 f0       	push   $0xf01076a3
f01033ad:	e8 c9 cc ff ff       	call   f010007b <_panic>
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
	e->env_pgdir = 0;
f01033b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01033b5:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033bc:	05 00 00 00 10       	add    $0x10000000,%eax
f01033c1:	c1 e8 0c             	shr    $0xc,%eax
f01033c4:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f01033ca:	72 14                	jb     f01033e0 <env_free+0x187>
		panic("pa2page called with invalid pa");
f01033cc:	83 ec 04             	sub    $0x4,%esp
f01033cf:	68 90 6a 10 f0       	push   $0xf0106a90
f01033d4:	6a 51                	push   $0x51
f01033d6:	68 91 73 10 f0       	push   $0xf0107391
f01033db:	e8 9b cc ff ff       	call   f010007b <_panic>
	page_decref(pa2page(pa));
f01033e0:	83 ec 0c             	sub    $0xc,%esp
f01033e3:	c1 e0 03             	shl    $0x3,%eax
f01033e6:	03 05 90 fe 1e f0    	add    0xf01efe90,%eax
f01033ec:	50                   	push   %eax
f01033ed:	e8 d8 d7 ff ff       	call   f0100bca <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01033f5:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01033fc:	a1 3c f2 1e f0       	mov    0xf01ef23c,%eax
f0103401:	8b 55 08             	mov    0x8(%ebp),%edx
f0103404:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103407:	89 15 3c f2 1e f0    	mov    %edx,0xf01ef23c
f010340d:	83 c4 10             	add    $0x10,%esp
}
f0103410:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103413:	5b                   	pop    %ebx
f0103414:	5e                   	pop    %esi
f0103415:	5f                   	pop    %edi
f0103416:	c9                   	leave  
f0103417:	c3                   	ret    

f0103418 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103418:	55                   	push   %ebp
f0103419:	89 e5                	mov    %esp,%ebp
f010341b:	53                   	push   %ebx
f010341c:	83 ec 04             	sub    $0x4,%esp
f010341f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103422:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103426:	75 23                	jne    f010344b <env_destroy+0x33>
f0103428:	e8 41 29 00 00       	call   f0105d6e <cpunum>
f010342d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103434:	29 c2                	sub    %eax,%edx
f0103436:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103439:	3b 1c 95 28 00 1f f0 	cmp    -0xfe0ffd8(,%edx,4),%ebx
f0103440:	74 09                	je     f010344b <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103442:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
f0103449:	eb 47                	jmp    f0103492 <env_destroy+0x7a>
		return;
	}

	env_free(e);
f010344b:	83 ec 0c             	sub    $0xc,%esp
f010344e:	53                   	push   %ebx
f010344f:	e8 05 fe ff ff       	call   f0103259 <env_free>

	if (curenv == e) {
f0103454:	e8 15 29 00 00       	call   f0105d6e <cpunum>
f0103459:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103460:	29 c2                	sub    %eax,%edx
f0103462:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103465:	83 c4 10             	add    $0x10,%esp
f0103468:	3b 1c 95 28 00 1f f0 	cmp    -0xfe0ffd8(,%edx,4),%ebx
f010346f:	75 21                	jne    f0103492 <env_destroy+0x7a>
		curenv = NULL;
f0103471:	e8 f8 28 00 00       	call   f0105d6e <cpunum>
f0103476:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010347d:	29 c2                	sub    %eax,%edx
f010347f:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103482:	c7 04 95 28 00 1f f0 	movl   $0x0,-0xfe0ffd8(,%edx,4)
f0103489:	00 00 00 00 
		sched_yield();
f010348d:	e8 59 12 00 00       	call   f01046eb <sched_yield>
	}
}
f0103492:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103495:	c9                   	leave  
f0103496:	c3                   	ret    

f0103497 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103497:	55                   	push   %ebp
f0103498:	89 e5                	mov    %esp,%ebp
f010349a:	57                   	push   %edi
f010349b:	56                   	push   %esi
f010349c:	53                   	push   %ebx
f010349d:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.

	struct Env *e;
    	int rc;
   	if((rc = env_alloc(&e, 0)) != 0) {
f01034a0:	6a 00                	push   $0x0
f01034a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01034a5:	50                   	push   %eax
f01034a6:	e8 98 fa ff ff       	call   f0102f43 <env_alloc>
f01034ab:	83 c4 10             	add    $0x10,%esp
f01034ae:	85 c0                	test   %eax,%eax
f01034b0:	74 17                	je     f01034c9 <env_create+0x32>
    	    panic("env_create failed: env_alloc failed.\n");
f01034b2:	83 ec 04             	sub    $0x4,%esp
f01034b5:	68 04 77 10 f0       	push   $0xf0107704
f01034ba:	68 93 01 00 00       	push   $0x193
f01034bf:	68 a3 76 10 f0       	push   $0xf01076a3
f01034c4:	e8 b2 cb ff ff       	call   f010007b <_panic>
   	}
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS) {
f01034c9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f01034cd:	75 0a                	jne    f01034d9 <env_create+0x42>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01034cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01034d2:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}

   	load_icode(e, binary);
f01034d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01034dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *ELF = (struct Elf *) binary;
f01034df:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct Proghdr *ph;				//ELF header
	int ph_cnt;						//load counter
	if (ELF->e_magic != ELF_MAGIC) {
f01034e2:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01034e8:	74 17                	je     f0103501 <env_create+0x6a>
		panic("fault: The binary is not ELF format\n");
f01034ea:	83 ec 04             	sub    $0x4,%esp
f01034ed:	68 2c 77 10 f0       	push   $0xf010772c
f01034f2:	68 6a 01 00 00       	push   $0x16a
f01034f7:	68 a3 76 10 f0       	push   $0xf01076a3
f01034fc:	e8 7a cb ff ff       	call   f010007b <_panic>
	}
	if(ELF->e_entry == 0){
f0103501:	83 7f 18 00          	cmpl   $0x0,0x18(%edi)
f0103505:	75 17                	jne    f010351e <env_create+0x87>
     panic("fault: The ELF file can't be executed.\n");
f0103507:	83 ec 04             	sub    $0x4,%esp
f010350a:	68 54 77 10 f0       	push   $0xf0107754
f010350f:	68 6d 01 00 00       	push   $0x16d
f0103514:	68 a3 76 10 f0       	push   $0xf01076a3
f0103519:	e8 5d cb ff ff       	call   f010007b <_panic>
  }
  
	ph = (struct Proghdr *) ((uint8_t *) ELF + ELF->e_phoff);//得到ELF header指针
f010351e:	89 fa                	mov    %edi,%edx
f0103520:	03 57 1c             	add    0x1c(%edi),%edx
	ph_cnt = ELF->e_phnum;//得到load counter
f0103523:	0f b7 4f 2c          	movzwl 0x2c(%edi),%ecx
f0103527:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010352a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010352d:	8b 41 60             	mov    0x60(%ecx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103530:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103535:	77 15                	ja     f010354c <env_create+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103537:	50                   	push   %eax
f0103538:	68 00 65 10 f0       	push   $0xf0106500
f010353d:	68 73 01 00 00       	push   $0x173
f0103542:	68 a3 76 10 f0       	push   $0xf01076a3
f0103547:	e8 2f cb ff ff       	call   f010007b <_panic>
f010354c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103551:	0f 22 d8             	mov    %eax,%cr3
f0103554:	89 d3                	mov    %edx,%ebx
f0103556:	be 00 00 00 00       	mov    $0x0,%esi
f010355b:	eb 3f                	jmp    f010359c <env_create+0x105>

	lcr3(PADDR(e->env_pgdir));			//设置cr3为用户页目录

	for (int i = 0; i < ph_cnt; i++) {
		if (ph[i].p_type == ELF_PROG_LOAD) {		//只加载LOAD类型的Segment
f010355d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103560:	75 36                	jne    f0103598 <env_create+0x101>
			region_alloc(e, (void *)ph[i].p_va, ph[i].p_memsz);//用户态建立映射
f0103562:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103565:	8b 53 08             	mov    0x8(%ebx),%edx
f0103568:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010356b:	e8 40 fb ff ff       	call   f01030b0 <region_alloc>
			memset((void *)ph[i].p_va, 0, ph[i].p_memsz);	//分配为0
f0103570:	83 ec 04             	sub    $0x4,%esp
f0103573:	ff 73 14             	pushl  0x14(%ebx)
f0103576:	6a 00                	push   $0x0
f0103578:	ff 73 08             	pushl  0x8(%ebx)
f010357b:	e8 c4 21 00 00       	call   f0105744 <memset>
			memcpy((void *)ph[i].p_va, binary + ph[i].p_offset, ph[i].p_filesz); //不为0的部分
f0103580:	83 c4 0c             	add    $0xc,%esp
f0103583:	ff 73 10             	pushl  0x10(%ebx)
f0103586:	8b 45 08             	mov    0x8(%ebp),%eax
f0103589:	03 43 04             	add    0x4(%ebx),%eax
f010358c:	50                   	push   %eax
f010358d:	ff 73 08             	pushl  0x8(%ebx)
f0103590:	e8 6d 22 00 00       	call   f0105802 <memcpy>
f0103595:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *) ((uint8_t *) ELF + ELF->e_phoff);//得到ELF header指针
	ph_cnt = ELF->e_phnum;//得到load counter

	lcr3(PADDR(e->env_pgdir));			//设置cr3为用户页目录

	for (int i = 0; i < ph_cnt; i++) {
f0103598:	46                   	inc    %esi
f0103599:	83 c3 20             	add    $0x20,%ebx
f010359c:	3b 75 dc             	cmp    -0x24(%ebp),%esi
f010359f:	7c bc                	jl     f010355d <env_create+0xc6>
			region_alloc(e, (void *)ph[i].p_va, ph[i].p_memsz);//用户态建立映射
			memset((void *)ph[i].p_va, 0, ph[i].p_memsz);	//分配为0
			memcpy((void *)ph[i].p_va, binary + ph[i].p_offset, ph[i].p_filesz); //不为0的部分
		}
	}
	e->env_tf.tf_eip = ELF->e_entry;
f01035a1:	8b 47 18             	mov    0x18(%edi),%eax
f01035a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035a7:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);//建立main stack映射
f01035aa:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01035af:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01035b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035b7:	e8 f4 fa ff ff       	call   f01030b0 <region_alloc>
	if (type == ENV_TYPE_FS) {
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
	}

   	load_icode(e, binary);
   	e->env_type = type;	
f01035bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01035bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01035c2:	89 48 50             	mov    %ecx,0x50(%eax)
}
f01035c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035c8:	5b                   	pop    %ebx
f01035c9:	5e                   	pop    %esi
f01035ca:	5f                   	pop    %edi
f01035cb:	c9                   	leave  
f01035cc:	c3                   	ret    
f01035cd:	00 00                	add    %al,(%eax)
	...

f01035d0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01035d0:	55                   	push   %ebp
f01035d1:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035d3:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f01035d7:	ba 70 00 00 00       	mov    $0x70,%edx
f01035dc:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035dd:	b2 71                	mov    $0x71,%dl
f01035df:	ec                   	in     (%dx),%al
f01035e0:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01035e3:	c9                   	leave  
f01035e4:	c3                   	ret    

f01035e5 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035e5:	55                   	push   %ebp
f01035e6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035e8:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
f01035ec:	ba 70 00 00 00       	mov    $0x70,%edx
f01035f1:	ee                   	out    %al,(%dx)
f01035f2:	b2 71                	mov    $0x71,%dl
f01035f4:	8a 45 0c             	mov    0xc(%ebp),%al
f01035f7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035f8:	c9                   	leave  
f01035f9:	c3                   	ret    
	...

f01035fc <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
f01035ff:	56                   	push   %esi
f0103600:	53                   	push   %ebx
f0103601:	8b 45 08             	mov    0x8(%ebp),%eax
f0103604:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103606:	66 a3 90 43 12 f0    	mov    %ax,0xf0124390
	if (!didinit)
f010360c:	80 3d 40 f2 1e f0 00 	cmpb   $0x0,0xf01ef240
f0103613:	74 5e                	je     f0103673 <irq_setmask_8259A+0x77>
f0103615:	ba 21 00 00 00       	mov    $0x21,%edx
f010361a:	ee                   	out    %al,(%dx)
f010361b:	89 f2                	mov    %esi,%edx
f010361d:	0f b6 c6             	movzbl %dh,%eax
f0103620:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103625:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103626:	83 ec 0c             	sub    $0xc,%esp
f0103629:	68 7c 77 10 f0       	push   $0xf010777c
f010362e:	e8 d3 00 00 00       	call   f0103706 <cprintf>
f0103633:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103638:	83 c4 10             	add    $0x10,%esp
f010363b:	0f b7 c6             	movzwl %si,%eax
f010363e:	89 c6                	mov    %eax,%esi
f0103640:	f7 d6                	not    %esi
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103642:	89 f0                	mov    %esi,%eax
f0103644:	88 d9                	mov    %bl,%cl
f0103646:	d3 f8                	sar    %cl,%eax
f0103648:	a8 01                	test   $0x1,%al
f010364a:	74 11                	je     f010365d <irq_setmask_8259A+0x61>
			cprintf(" %d", i);
f010364c:	83 ec 08             	sub    $0x8,%esp
f010364f:	53                   	push   %ebx
f0103650:	68 24 7c 10 f0       	push   $0xf0107c24
f0103655:	e8 ac 00 00 00       	call   f0103706 <cprintf>
f010365a:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010365d:	43                   	inc    %ebx
f010365e:	83 fb 10             	cmp    $0x10,%ebx
f0103661:	75 df                	jne    f0103642 <irq_setmask_8259A+0x46>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103663:	83 ec 0c             	sub    $0xc,%esp
f0103666:	68 65 76 10 f0       	push   $0xf0107665
f010366b:	e8 96 00 00 00       	call   f0103706 <cprintf>
f0103670:	83 c4 10             	add    $0x10,%esp
}
f0103673:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103676:	5b                   	pop    %ebx
f0103677:	5e                   	pop    %esi
f0103678:	c9                   	leave  
f0103679:	c3                   	ret    

f010367a <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010367a:	55                   	push   %ebp
f010367b:	89 e5                	mov    %esp,%ebp
f010367d:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f0103680:	c6 05 40 f2 1e f0 01 	movb   $0x1,0xf01ef240
f0103687:	b0 ff                	mov    $0xff,%al
f0103689:	ba 21 00 00 00       	mov    $0x21,%edx
f010368e:	ee                   	out    %al,(%dx)
f010368f:	b2 a1                	mov    $0xa1,%dl
f0103691:	ee                   	out    %al,(%dx)
f0103692:	b0 11                	mov    $0x11,%al
f0103694:	b2 20                	mov    $0x20,%dl
f0103696:	ee                   	out    %al,(%dx)
f0103697:	b0 20                	mov    $0x20,%al
f0103699:	b2 21                	mov    $0x21,%dl
f010369b:	ee                   	out    %al,(%dx)
f010369c:	b0 04                	mov    $0x4,%al
f010369e:	ee                   	out    %al,(%dx)
f010369f:	b0 03                	mov    $0x3,%al
f01036a1:	ee                   	out    %al,(%dx)
f01036a2:	b0 11                	mov    $0x11,%al
f01036a4:	b2 a0                	mov    $0xa0,%dl
f01036a6:	ee                   	out    %al,(%dx)
f01036a7:	b0 28                	mov    $0x28,%al
f01036a9:	b2 a1                	mov    $0xa1,%dl
f01036ab:	ee                   	out    %al,(%dx)
f01036ac:	b0 02                	mov    $0x2,%al
f01036ae:	ee                   	out    %al,(%dx)
f01036af:	b0 01                	mov    $0x1,%al
f01036b1:	ee                   	out    %al,(%dx)
f01036b2:	b0 68                	mov    $0x68,%al
f01036b4:	b2 20                	mov    $0x20,%dl
f01036b6:	ee                   	out    %al,(%dx)
f01036b7:	b0 0a                	mov    $0xa,%al
f01036b9:	ee                   	out    %al,(%dx)
f01036ba:	b0 68                	mov    $0x68,%al
f01036bc:	b2 a0                	mov    $0xa0,%dl
f01036be:	ee                   	out    %al,(%dx)
f01036bf:	b0 0a                	mov    $0xa,%al
f01036c1:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036c2:	66 a1 90 43 12 f0    	mov    0xf0124390,%ax
f01036c8:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036cc:	74 0f                	je     f01036dd <pic_init+0x63>
		irq_setmask_8259A(irq_mask_8259A);
f01036ce:	83 ec 0c             	sub    $0xc,%esp
f01036d1:	0f b7 c0             	movzwl %ax,%eax
f01036d4:	50                   	push   %eax
f01036d5:	e8 22 ff ff ff       	call   f01035fc <irq_setmask_8259A>
f01036da:	83 c4 10             	add    $0x10,%esp
}
f01036dd:	c9                   	leave  
f01036de:	c3                   	ret    
	...

f01036e0 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01036e0:	55                   	push   %ebp
f01036e1:	89 e5                	mov    %esp,%ebp
f01036e3:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036ed:	ff 75 0c             	pushl  0xc(%ebp)
f01036f0:	ff 75 08             	pushl  0x8(%ebp)
f01036f3:	8d 45 fc             	lea    -0x4(%ebp),%eax
f01036f6:	50                   	push   %eax
f01036f7:	68 1d 37 10 f0       	push   $0xf010371d
f01036fc:	e8 43 1a 00 00       	call   f0105144 <vprintfmt>
f0103701:	8b 45 fc             	mov    -0x4(%ebp),%eax
	return cnt;
}
f0103704:	c9                   	leave  
f0103705:	c3                   	ret    

f0103706 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103706:	55                   	push   %ebp
f0103707:	89 e5                	mov    %esp,%ebp
f0103709:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010370c:	8d 45 0c             	lea    0xc(%ebp),%eax
f010370f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
f0103712:	50                   	push   %eax
f0103713:	ff 75 08             	pushl  0x8(%ebp)
f0103716:	e8 c5 ff ff ff       	call   f01036e0 <vcprintf>
	va_end(ap);

	return cnt;
}
f010371b:	c9                   	leave  
f010371c:	c3                   	ret    

f010371d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010371d:	55                   	push   %ebp
f010371e:	89 e5                	mov    %esp,%ebp
f0103720:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103723:	ff 75 08             	pushl  0x8(%ebp)
f0103726:	e8 1e ce ff ff       	call   f0100549 <cputchar>
f010372b:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f010372e:	c9                   	leave  
f010372f:	c3                   	ret    

f0103730 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103730:	55                   	push   %ebp
f0103731:	89 e5                	mov    %esp,%ebp
f0103733:	57                   	push   %edi
f0103734:	56                   	push   %esi
f0103735:	53                   	push   %ebx
f0103736:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0103739:	e8 30 26 00 00       	call   f0105d6e <cpunum>
f010373e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103745:	29 c2                	sub    %eax,%edx
f0103747:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010374a:	0f b6 14 95 20 00 1f 	movzbl -0xfe0ffe0(,%edx,4),%edx
f0103751:	f0 
f0103752:	89 55 f0             	mov    %edx,-0x10(%ebp)
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103755:	e8 14 26 00 00       	call   f0105d6e <cpunum>
f010375a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103761:	29 c2                	sub    %eax,%edx
f0103763:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103766:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103769:	c1 e1 10             	shl    $0x10,%ecx
f010376c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103771:	29 c8                	sub    %ecx,%eax
f0103773:	89 04 95 30 00 1f f0 	mov    %eax,-0xfe0ffd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010377a:	e8 ef 25 00 00       	call   f0105d6e <cpunum>
f010377f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103786:	29 c2                	sub    %eax,%edx
f0103788:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010378b:	66 c7 04 95 34 00 1f 	movw   $0x10,-0xfe0ffcc(,%edx,4)
f0103792:	f0 10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103795:	e8 d4 25 00 00       	call   f0105d6e <cpunum>
f010379a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037a1:	29 c2                	sub    %eax,%edx
f01037a3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01037a6:	66 c7 04 95 92 00 1f 	movw   $0x68,-0xfe0ff6e(,%edx,4)
f01037ad:	f0 68 00 
	
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+i] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01037b0:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01037b3:	83 c6 05             	add    $0x5,%esi
f01037b6:	e8 b3 25 00 00       	call   f0105d6e <cpunum>
f01037bb:	89 c7                	mov    %eax,%edi
f01037bd:	e8 ac 25 00 00       	call   f0105d6e <cpunum>
f01037c2:	89 c3                	mov    %eax,%ebx
f01037c4:	e8 a5 25 00 00       	call   f0105d6e <cpunum>
f01037c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037d0:	29 c2                	sub    %eax,%edx
f01037d2:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01037d5:	8d 14 95 2c 00 1f f0 	lea    -0xfe0ffd4(,%edx,4),%edx
f01037dc:	c1 ea 18             	shr    $0x18,%edx
f01037df:	88 14 f5 27 43 12 f0 	mov    %dl,-0xfedbcd9(,%esi,8)
f01037e6:	c6 04 f5 26 43 12 f0 	movb   $0x40,-0xfedbcda(,%esi,8)
f01037ed:	40 
f01037ee:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f01037f5:	29 d8                	sub    %ebx,%eax
f01037f7:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f01037fa:	8d 04 85 2c 00 1f f0 	lea    -0xfe0ffd4(,%eax,4),%eax
f0103801:	c1 e8 10             	shr    $0x10,%eax
f0103804:	88 04 f5 24 43 12 f0 	mov    %al,-0xfedbcdc(,%esi,8)
f010380b:	8d 04 fd 00 00 00 00 	lea    0x0(,%edi,8),%eax
f0103812:	29 f8                	sub    %edi,%eax
f0103814:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103817:	8d 04 85 2c 00 1f f0 	lea    -0xfe0ffd4(,%eax,4),%eax
f010381e:	66 89 04 f5 22 43 12 	mov    %ax,-0xfedbcde(,%esi,8)
f0103825:	f0 
f0103826:	66 c7 04 f5 20 43 12 	movw   $0x67,-0xfedbce0(,%esi,8)
f010382d:	f0 67 00 
					sizeof(struct Taskstate)-1, 0);
	gdt[(GD_TSS0 >> 3)+i].sd_s = 0;
f0103830:	c6 04 f5 25 43 12 f0 	movb   $0x89,-0xfedbcdb(,%esi,8)
f0103837:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103838:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010383b:	8d 04 d5 28 00 00 00 	lea    0x28(,%edx,8),%eax
f0103842:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103845:	b8 94 43 12 f0       	mov    $0xf0124394,%eax
f010384a:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f010384d:	83 c4 0c             	add    $0xc,%esp
f0103850:	5b                   	pop    %ebx
f0103851:	5e                   	pop    %esi
f0103852:	5f                   	pop    %edi
f0103853:	c9                   	leave  
f0103854:	c3                   	ret    

f0103855 <trap_init>:
}


void
trap_init(void)
{
f0103855:	55                   	push   %ebp
f0103856:	89 e5                	mov    %esp,%ebp
f0103858:	83 ec 08             	sub    $0x8,%esp
	void th44();
	void th45();
	void th46();
	void th47();
	void th_syscall();
	SETGATE(idt[0], 0, GD_KT, th0, 0);	//SETGATE(gate, istrap, sel, off, dpl)	
f010385b:	b9 20 45 10 f0       	mov    $0xf0104520,%ecx
f0103860:	66 89 0d 60 f2 1e f0 	mov    %cx,0xf01ef260
f0103867:	66 c7 05 62 f2 1e f0 	movw   $0x8,0xf01ef262
f010386e:	08 00 
f0103870:	80 25 64 f2 1e f0 e0 	andb   $0xe0,0xf01ef264
f0103877:	c6 05 64 f2 1e f0 00 	movb   $0x0,0xf01ef264
f010387e:	a0 65 f2 1e f0       	mov    0xf01ef265,%al
f0103883:	83 e0 f0             	and    $0xfffffff0,%eax
f0103886:	83 c8 0e             	or     $0xe,%eax
f0103889:	a2 65 f2 1e f0       	mov    %al,0xf01ef265
f010388e:	88 c2                	mov    %al,%dl
f0103890:	83 e2 ef             	and    $0xffffffef,%edx
f0103893:	88 15 65 f2 1e f0    	mov    %dl,0xf01ef265
f0103899:	83 e0 8f             	and    $0xffffff8f,%eax
f010389c:	a2 65 f2 1e f0       	mov    %al,0xf01ef265
f01038a1:	83 c8 80             	or     $0xffffff80,%eax
f01038a4:	a2 65 f2 1e f0       	mov    %al,0xf01ef265
f01038a9:	c1 e9 10             	shr    $0x10,%ecx
f01038ac:	66 89 0d 66 f2 1e f0 	mov    %cx,0xf01ef266
	SETGATE(idt[1], 0, GD_KT, th1, 0);  
f01038b3:	b9 2a 45 10 f0       	mov    $0xf010452a,%ecx
f01038b8:	66 89 0d 68 f2 1e f0 	mov    %cx,0xf01ef268
f01038bf:	66 c7 05 6a f2 1e f0 	movw   $0x8,0xf01ef26a
f01038c6:	08 00 
f01038c8:	80 25 6c f2 1e f0 e0 	andb   $0xe0,0xf01ef26c
f01038cf:	c6 05 6c f2 1e f0 00 	movb   $0x0,0xf01ef26c
f01038d6:	a0 6d f2 1e f0       	mov    0xf01ef26d,%al
f01038db:	83 e0 f0             	and    $0xfffffff0,%eax
f01038de:	83 c8 0e             	or     $0xe,%eax
f01038e1:	a2 6d f2 1e f0       	mov    %al,0xf01ef26d
f01038e6:	88 c2                	mov    %al,%dl
f01038e8:	83 e2 ef             	and    $0xffffffef,%edx
f01038eb:	88 15 6d f2 1e f0    	mov    %dl,0xf01ef26d
f01038f1:	83 e0 8f             	and    $0xffffff8f,%eax
f01038f4:	a2 6d f2 1e f0       	mov    %al,0xf01ef26d
f01038f9:	83 c8 80             	or     $0xffffff80,%eax
f01038fc:	a2 6d f2 1e f0       	mov    %al,0xf01ef26d
f0103901:	c1 e9 10             	shr    $0x10,%ecx
f0103904:	66 89 0d 6e f2 1e f0 	mov    %cx,0xf01ef26e
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f010390b:	b9 34 45 10 f0       	mov    $0xf0104534,%ecx
f0103910:	66 89 0d 78 f2 1e f0 	mov    %cx,0xf01ef278
f0103917:	66 c7 05 7a f2 1e f0 	movw   $0x8,0xf01ef27a
f010391e:	08 00 
f0103920:	80 25 7c f2 1e f0 e0 	andb   $0xe0,0xf01ef27c
f0103927:	c6 05 7c f2 1e f0 00 	movb   $0x0,0xf01ef27c
f010392e:	a0 7d f2 1e f0       	mov    0xf01ef27d,%al
f0103933:	83 e0 f0             	and    $0xfffffff0,%eax
f0103936:	83 c8 0e             	or     $0xe,%eax
f0103939:	a2 7d f2 1e f0       	mov    %al,0xf01ef27d
f010393e:	83 e0 ef             	and    $0xffffffef,%eax
f0103941:	a2 7d f2 1e f0       	mov    %al,0xf01ef27d
f0103946:	88 c2                	mov    %al,%dl
f0103948:	83 ca 60             	or     $0x60,%edx
f010394b:	88 15 7d f2 1e f0    	mov    %dl,0xf01ef27d
f0103951:	83 c8 e0             	or     $0xffffffe0,%eax
f0103954:	a2 7d f2 1e f0       	mov    %al,0xf01ef27d
f0103959:	c1 e9 10             	shr    $0x10,%ecx
f010395c:	66 89 0d 7e f2 1e f0 	mov    %cx,0xf01ef27e
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103963:	b9 3e 45 10 f0       	mov    $0xf010453e,%ecx
f0103968:	66 89 0d 80 f2 1e f0 	mov    %cx,0xf01ef280
f010396f:	66 c7 05 82 f2 1e f0 	movw   $0x8,0xf01ef282
f0103976:	08 00 
f0103978:	80 25 84 f2 1e f0 e0 	andb   $0xe0,0xf01ef284
f010397f:	c6 05 84 f2 1e f0 00 	movb   $0x0,0xf01ef284
f0103986:	a0 85 f2 1e f0       	mov    0xf01ef285,%al
f010398b:	83 e0 f0             	and    $0xfffffff0,%eax
f010398e:	83 c8 0e             	or     $0xe,%eax
f0103991:	a2 85 f2 1e f0       	mov    %al,0xf01ef285
f0103996:	88 c2                	mov    %al,%dl
f0103998:	83 e2 ef             	and    $0xffffffef,%edx
f010399b:	88 15 85 f2 1e f0    	mov    %dl,0xf01ef285
f01039a1:	83 e0 8f             	and    $0xffffff8f,%eax
f01039a4:	a2 85 f2 1e f0       	mov    %al,0xf01ef285
f01039a9:	83 c8 80             	or     $0xffffff80,%eax
f01039ac:	a2 85 f2 1e f0       	mov    %al,0xf01ef285
f01039b1:	c1 e9 10             	shr    $0x10,%ecx
f01039b4:	66 89 0d 86 f2 1e f0 	mov    %cx,0xf01ef286
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f01039bb:	b9 48 45 10 f0       	mov    $0xf0104548,%ecx
f01039c0:	66 89 0d 88 f2 1e f0 	mov    %cx,0xf01ef288
f01039c7:	66 c7 05 8a f2 1e f0 	movw   $0x8,0xf01ef28a
f01039ce:	08 00 
f01039d0:	80 25 8c f2 1e f0 e0 	andb   $0xe0,0xf01ef28c
f01039d7:	c6 05 8c f2 1e f0 00 	movb   $0x0,0xf01ef28c
f01039de:	a0 8d f2 1e f0       	mov    0xf01ef28d,%al
f01039e3:	83 e0 f0             	and    $0xfffffff0,%eax
f01039e6:	83 c8 0e             	or     $0xe,%eax
f01039e9:	a2 8d f2 1e f0       	mov    %al,0xf01ef28d
f01039ee:	88 c2                	mov    %al,%dl
f01039f0:	83 e2 ef             	and    $0xffffffef,%edx
f01039f3:	88 15 8d f2 1e f0    	mov    %dl,0xf01ef28d
f01039f9:	83 e0 8f             	and    $0xffffff8f,%eax
f01039fc:	a2 8d f2 1e f0       	mov    %al,0xf01ef28d
f0103a01:	83 c8 80             	or     $0xffffff80,%eax
f0103a04:	a2 8d f2 1e f0       	mov    %al,0xf01ef28d
f0103a09:	c1 e9 10             	shr    $0x10,%ecx
f0103a0c:	66 89 0d 8e f2 1e f0 	mov    %cx,0xf01ef28e
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f0103a13:	b9 52 45 10 f0       	mov    $0xf0104552,%ecx
f0103a18:	66 89 0d 90 f2 1e f0 	mov    %cx,0xf01ef290
f0103a1f:	66 c7 05 92 f2 1e f0 	movw   $0x8,0xf01ef292
f0103a26:	08 00 
f0103a28:	80 25 94 f2 1e f0 e0 	andb   $0xe0,0xf01ef294
f0103a2f:	c6 05 94 f2 1e f0 00 	movb   $0x0,0xf01ef294
f0103a36:	a0 95 f2 1e f0       	mov    0xf01ef295,%al
f0103a3b:	83 e0 f0             	and    $0xfffffff0,%eax
f0103a3e:	83 c8 0e             	or     $0xe,%eax
f0103a41:	a2 95 f2 1e f0       	mov    %al,0xf01ef295
f0103a46:	88 c2                	mov    %al,%dl
f0103a48:	83 e2 ef             	and    $0xffffffef,%edx
f0103a4b:	88 15 95 f2 1e f0    	mov    %dl,0xf01ef295
f0103a51:	83 e0 8f             	and    $0xffffff8f,%eax
f0103a54:	a2 95 f2 1e f0       	mov    %al,0xf01ef295
f0103a59:	83 c8 80             	or     $0xffffff80,%eax
f0103a5c:	a2 95 f2 1e f0       	mov    %al,0xf01ef295
f0103a61:	c1 e9 10             	shr    $0x10,%ecx
f0103a64:	66 89 0d 96 f2 1e f0 	mov    %cx,0xf01ef296
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103a6b:	b9 5c 45 10 f0       	mov    $0xf010455c,%ecx
f0103a70:	66 89 0d 98 f2 1e f0 	mov    %cx,0xf01ef298
f0103a77:	66 c7 05 9a f2 1e f0 	movw   $0x8,0xf01ef29a
f0103a7e:	08 00 
f0103a80:	80 25 9c f2 1e f0 e0 	andb   $0xe0,0xf01ef29c
f0103a87:	c6 05 9c f2 1e f0 00 	movb   $0x0,0xf01ef29c
f0103a8e:	a0 9d f2 1e f0       	mov    0xf01ef29d,%al
f0103a93:	83 e0 f0             	and    $0xfffffff0,%eax
f0103a96:	83 c8 0e             	or     $0xe,%eax
f0103a99:	a2 9d f2 1e f0       	mov    %al,0xf01ef29d
f0103a9e:	88 c2                	mov    %al,%dl
f0103aa0:	83 e2 ef             	and    $0xffffffef,%edx
f0103aa3:	88 15 9d f2 1e f0    	mov    %dl,0xf01ef29d
f0103aa9:	83 e0 8f             	and    $0xffffff8f,%eax
f0103aac:	a2 9d f2 1e f0       	mov    %al,0xf01ef29d
f0103ab1:	83 c8 80             	or     $0xffffff80,%eax
f0103ab4:	a2 9d f2 1e f0       	mov    %al,0xf01ef29d
f0103ab9:	c1 e9 10             	shr    $0x10,%ecx
f0103abc:	66 89 0d 9e f2 1e f0 	mov    %cx,0xf01ef29e
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103ac3:	b8 66 45 10 f0       	mov    $0xf0104566,%eax
f0103ac8:	66 a3 a0 f2 1e f0    	mov    %ax,0xf01ef2a0
f0103ace:	66 c7 05 a2 f2 1e f0 	movw   $0x8,0xf01ef2a2
f0103ad5:	08 00 
f0103ad7:	c6 05 a4 f2 1e f0 00 	movb   $0x0,0xf01ef2a4
f0103ade:	c6 05 a5 f2 1e f0 8e 	movb   $0x8e,0xf01ef2a5
f0103ae5:	c1 e8 10             	shr    $0x10,%eax
f0103ae8:	66 a3 a6 f2 1e f0    	mov    %ax,0xf01ef2a6
	SETGATE(idt[9], 0, GD_KT, th9, 0);
f0103aee:	b8 6e 45 10 f0       	mov    $0xf010456e,%eax
f0103af3:	66 a3 a8 f2 1e f0    	mov    %ax,0xf01ef2a8
f0103af9:	66 c7 05 aa f2 1e f0 	movw   $0x8,0xf01ef2aa
f0103b00:	08 00 
f0103b02:	c6 05 ac f2 1e f0 00 	movb   $0x0,0xf01ef2ac
f0103b09:	c6 05 ad f2 1e f0 8e 	movb   $0x8e,0xf01ef2ad
f0103b10:	c1 e8 10             	shr    $0x10,%eax
f0103b13:	66 a3 ae f2 1e f0    	mov    %ax,0xf01ef2ae
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103b19:	b8 78 45 10 f0       	mov    $0xf0104578,%eax
f0103b1e:	66 a3 b0 f2 1e f0    	mov    %ax,0xf01ef2b0
f0103b24:	66 c7 05 b2 f2 1e f0 	movw   $0x8,0xf01ef2b2
f0103b2b:	08 00 
f0103b2d:	c6 05 b4 f2 1e f0 00 	movb   $0x0,0xf01ef2b4
f0103b34:	c6 05 b5 f2 1e f0 8e 	movb   $0x8e,0xf01ef2b5
f0103b3b:	c1 e8 10             	shr    $0x10,%eax
f0103b3e:	66 a3 b6 f2 1e f0    	mov    %ax,0xf01ef2b6
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f0103b44:	b8 7c 45 10 f0       	mov    $0xf010457c,%eax
f0103b49:	66 a3 b8 f2 1e f0    	mov    %ax,0xf01ef2b8
f0103b4f:	66 c7 05 ba f2 1e f0 	movw   $0x8,0xf01ef2ba
f0103b56:	08 00 
f0103b58:	c6 05 bc f2 1e f0 00 	movb   $0x0,0xf01ef2bc
f0103b5f:	c6 05 bd f2 1e f0 8e 	movb   $0x8e,0xf01ef2bd
f0103b66:	c1 e8 10             	shr    $0x10,%eax
f0103b69:	66 a3 be f2 1e f0    	mov    %ax,0xf01ef2be
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f0103b6f:	b8 80 45 10 f0       	mov    $0xf0104580,%eax
f0103b74:	66 a3 c0 f2 1e f0    	mov    %ax,0xf01ef2c0
f0103b7a:	66 c7 05 c2 f2 1e f0 	movw   $0x8,0xf01ef2c2
f0103b81:	08 00 
f0103b83:	c6 05 c4 f2 1e f0 00 	movb   $0x0,0xf01ef2c4
f0103b8a:	c6 05 c5 f2 1e f0 8e 	movb   $0x8e,0xf01ef2c5
f0103b91:	c1 e8 10             	shr    $0x10,%eax
f0103b94:	66 a3 c6 f2 1e f0    	mov    %ax,0xf01ef2c6
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103b9a:	b8 84 45 10 f0       	mov    $0xf0104584,%eax
f0103b9f:	66 a3 c8 f2 1e f0    	mov    %ax,0xf01ef2c8
f0103ba5:	66 c7 05 ca f2 1e f0 	movw   $0x8,0xf01ef2ca
f0103bac:	08 00 
f0103bae:	c6 05 cc f2 1e f0 00 	movb   $0x0,0xf01ef2cc
f0103bb5:	c6 05 cd f2 1e f0 8e 	movb   $0x8e,0xf01ef2cd
f0103bbc:	c1 e8 10             	shr    $0x10,%eax
f0103bbf:	66 a3 ce f2 1e f0    	mov    %ax,0xf01ef2ce
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103bc5:	b8 88 45 10 f0       	mov    $0xf0104588,%eax
f0103bca:	66 a3 d0 f2 1e f0    	mov    %ax,0xf01ef2d0
f0103bd0:	66 c7 05 d2 f2 1e f0 	movw   $0x8,0xf01ef2d2
f0103bd7:	08 00 
f0103bd9:	c6 05 d4 f2 1e f0 00 	movb   $0x0,0xf01ef2d4
f0103be0:	c6 05 d5 f2 1e f0 8e 	movb   $0x8e,0xf01ef2d5
f0103be7:	c1 e8 10             	shr    $0x10,%eax
f0103bea:	66 a3 d6 f2 1e f0    	mov    %ax,0xf01ef2d6
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103bf0:	b8 8c 45 10 f0       	mov    $0xf010458c,%eax
f0103bf5:	66 a3 e0 f2 1e f0    	mov    %ax,0xf01ef2e0
f0103bfb:	66 c7 05 e2 f2 1e f0 	movw   $0x8,0xf01ef2e2
f0103c02:	08 00 
f0103c04:	c6 05 e4 f2 1e f0 00 	movb   $0x0,0xf01ef2e4
f0103c0b:	c6 05 e5 f2 1e f0 8e 	movb   $0x8e,0xf01ef2e5
f0103c12:	c1 e8 10             	shr    $0x10,%eax
f0103c15:	66 a3 e6 f2 1e f0    	mov    %ax,0xf01ef2e6
	
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, th32, 0);
f0103c1b:	b8 98 45 10 f0       	mov    $0xf0104598,%eax
f0103c20:	66 a3 60 f3 1e f0    	mov    %ax,0xf01ef360
f0103c26:	66 c7 05 62 f3 1e f0 	movw   $0x8,0xf01ef362
f0103c2d:	08 00 
f0103c2f:	c6 05 64 f3 1e f0 00 	movb   $0x0,0xf01ef364
f0103c36:	c6 05 65 f3 1e f0 8e 	movb   $0x8e,0xf01ef365
f0103c3d:	c1 e8 10             	shr    $0x10,%eax
f0103c40:	66 a3 66 f3 1e f0    	mov    %ax,0xf01ef366
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, th33, 0);
f0103c46:	b8 9e 45 10 f0       	mov    $0xf010459e,%eax
f0103c4b:	66 a3 68 f3 1e f0    	mov    %ax,0xf01ef368
f0103c51:	66 c7 05 6a f3 1e f0 	movw   $0x8,0xf01ef36a
f0103c58:	08 00 
f0103c5a:	c6 05 6c f3 1e f0 00 	movb   $0x0,0xf01ef36c
f0103c61:	c6 05 6d f3 1e f0 8e 	movb   $0x8e,0xf01ef36d
f0103c68:	c1 e8 10             	shr    $0x10,%eax
f0103c6b:	66 a3 6e f3 1e f0    	mov    %ax,0xf01ef36e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, th34, 0);
f0103c71:	b8 a4 45 10 f0       	mov    $0xf01045a4,%eax
f0103c76:	66 a3 70 f3 1e f0    	mov    %ax,0xf01ef370
f0103c7c:	66 c7 05 72 f3 1e f0 	movw   $0x8,0xf01ef372
f0103c83:	08 00 
f0103c85:	c6 05 74 f3 1e f0 00 	movb   $0x0,0xf01ef374
f0103c8c:	c6 05 75 f3 1e f0 8e 	movb   $0x8e,0xf01ef375
f0103c93:	c1 e8 10             	shr    $0x10,%eax
f0103c96:	66 a3 76 f3 1e f0    	mov    %ax,0xf01ef376
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, th35, 0);
f0103c9c:	b8 aa 45 10 f0       	mov    $0xf01045aa,%eax
f0103ca1:	66 a3 78 f3 1e f0    	mov    %ax,0xf01ef378
f0103ca7:	66 c7 05 7a f3 1e f0 	movw   $0x8,0xf01ef37a
f0103cae:	08 00 
f0103cb0:	c6 05 7c f3 1e f0 00 	movb   $0x0,0xf01ef37c
f0103cb7:	c6 05 7d f3 1e f0 8e 	movb   $0x8e,0xf01ef37d
f0103cbe:	c1 e8 10             	shr    $0x10,%eax
f0103cc1:	66 a3 7e f3 1e f0    	mov    %ax,0xf01ef37e
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, th36, 0);
f0103cc7:	b8 b0 45 10 f0       	mov    $0xf01045b0,%eax
f0103ccc:	66 a3 80 f3 1e f0    	mov    %ax,0xf01ef380
f0103cd2:	66 c7 05 82 f3 1e f0 	movw   $0x8,0xf01ef382
f0103cd9:	08 00 
f0103cdb:	c6 05 84 f3 1e f0 00 	movb   $0x0,0xf01ef384
f0103ce2:	c6 05 85 f3 1e f0 8e 	movb   $0x8e,0xf01ef385
f0103ce9:	c1 e8 10             	shr    $0x10,%eax
f0103cec:	66 a3 86 f3 1e f0    	mov    %ax,0xf01ef386
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, th37, 0);
f0103cf2:	b8 b6 45 10 f0       	mov    $0xf01045b6,%eax
f0103cf7:	66 a3 88 f3 1e f0    	mov    %ax,0xf01ef388
f0103cfd:	66 c7 05 8a f3 1e f0 	movw   $0x8,0xf01ef38a
f0103d04:	08 00 
f0103d06:	c6 05 8c f3 1e f0 00 	movb   $0x0,0xf01ef38c
f0103d0d:	c6 05 8d f3 1e f0 8e 	movb   $0x8e,0xf01ef38d
f0103d14:	c1 e8 10             	shr    $0x10,%eax
f0103d17:	66 a3 8e f3 1e f0    	mov    %ax,0xf01ef38e
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, th38, 0);
f0103d1d:	b8 bc 45 10 f0       	mov    $0xf01045bc,%eax
f0103d22:	66 a3 90 f3 1e f0    	mov    %ax,0xf01ef390
f0103d28:	66 c7 05 92 f3 1e f0 	movw   $0x8,0xf01ef392
f0103d2f:	08 00 
f0103d31:	c6 05 94 f3 1e f0 00 	movb   $0x0,0xf01ef394
f0103d38:	c6 05 95 f3 1e f0 8e 	movb   $0x8e,0xf01ef395
f0103d3f:	c1 e8 10             	shr    $0x10,%eax
f0103d42:	66 a3 96 f3 1e f0    	mov    %ax,0xf01ef396
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, th39, 0);
f0103d48:	b8 c2 45 10 f0       	mov    $0xf01045c2,%eax
f0103d4d:	66 a3 98 f3 1e f0    	mov    %ax,0xf01ef398
f0103d53:	66 c7 05 9a f3 1e f0 	movw   $0x8,0xf01ef39a
f0103d5a:	08 00 
f0103d5c:	c6 05 9c f3 1e f0 00 	movb   $0x0,0xf01ef39c
f0103d63:	c6 05 9d f3 1e f0 8e 	movb   $0x8e,0xf01ef39d
f0103d6a:	c1 e8 10             	shr    $0x10,%eax
f0103d6d:	66 a3 9e f3 1e f0    	mov    %ax,0xf01ef39e
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, th40, 0);
f0103d73:	b8 c8 45 10 f0       	mov    $0xf01045c8,%eax
f0103d78:	66 a3 a0 f3 1e f0    	mov    %ax,0xf01ef3a0
f0103d7e:	66 c7 05 a2 f3 1e f0 	movw   $0x8,0xf01ef3a2
f0103d85:	08 00 
f0103d87:	c6 05 a4 f3 1e f0 00 	movb   $0x0,0xf01ef3a4
f0103d8e:	c6 05 a5 f3 1e f0 8e 	movb   $0x8e,0xf01ef3a5
f0103d95:	c1 e8 10             	shr    $0x10,%eax
f0103d98:	66 a3 a6 f3 1e f0    	mov    %ax,0xf01ef3a6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, th41, 0);
f0103d9e:	b8 ce 45 10 f0       	mov    $0xf01045ce,%eax
f0103da3:	66 a3 a8 f3 1e f0    	mov    %ax,0xf01ef3a8
f0103da9:	66 c7 05 aa f3 1e f0 	movw   $0x8,0xf01ef3aa
f0103db0:	08 00 
f0103db2:	c6 05 ac f3 1e f0 00 	movb   $0x0,0xf01ef3ac
f0103db9:	c6 05 ad f3 1e f0 8e 	movb   $0x8e,0xf01ef3ad
f0103dc0:	c1 e8 10             	shr    $0x10,%eax
f0103dc3:	66 a3 ae f3 1e f0    	mov    %ax,0xf01ef3ae
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, th42, 0);
f0103dc9:	b8 d4 45 10 f0       	mov    $0xf01045d4,%eax
f0103dce:	66 a3 b0 f3 1e f0    	mov    %ax,0xf01ef3b0
f0103dd4:	66 c7 05 b2 f3 1e f0 	movw   $0x8,0xf01ef3b2
f0103ddb:	08 00 
f0103ddd:	c6 05 b4 f3 1e f0 00 	movb   $0x0,0xf01ef3b4
f0103de4:	c6 05 b5 f3 1e f0 8e 	movb   $0x8e,0xf01ef3b5
f0103deb:	c1 e8 10             	shr    $0x10,%eax
f0103dee:	66 a3 b6 f3 1e f0    	mov    %ax,0xf01ef3b6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, th43, 0);
f0103df4:	b8 da 45 10 f0       	mov    $0xf01045da,%eax
f0103df9:	66 a3 b8 f3 1e f0    	mov    %ax,0xf01ef3b8
f0103dff:	66 c7 05 ba f3 1e f0 	movw   $0x8,0xf01ef3ba
f0103e06:	08 00 
f0103e08:	c6 05 bc f3 1e f0 00 	movb   $0x0,0xf01ef3bc
f0103e0f:	c6 05 bd f3 1e f0 8e 	movb   $0x8e,0xf01ef3bd
f0103e16:	c1 e8 10             	shr    $0x10,%eax
f0103e19:	66 a3 be f3 1e f0    	mov    %ax,0xf01ef3be
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, th44, 0);
f0103e1f:	b8 e0 45 10 f0       	mov    $0xf01045e0,%eax
f0103e24:	66 a3 c0 f3 1e f0    	mov    %ax,0xf01ef3c0
f0103e2a:	66 c7 05 c2 f3 1e f0 	movw   $0x8,0xf01ef3c2
f0103e31:	08 00 
f0103e33:	c6 05 c4 f3 1e f0 00 	movb   $0x0,0xf01ef3c4
f0103e3a:	c6 05 c5 f3 1e f0 8e 	movb   $0x8e,0xf01ef3c5
f0103e41:	c1 e8 10             	shr    $0x10,%eax
f0103e44:	66 a3 c6 f3 1e f0    	mov    %ax,0xf01ef3c6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, th45, 0);
f0103e4a:	b8 e6 45 10 f0       	mov    $0xf01045e6,%eax
f0103e4f:	66 a3 c8 f3 1e f0    	mov    %ax,0xf01ef3c8
f0103e55:	66 c7 05 ca f3 1e f0 	movw   $0x8,0xf01ef3ca
f0103e5c:	08 00 
f0103e5e:	c6 05 cc f3 1e f0 00 	movb   $0x0,0xf01ef3cc
f0103e65:	c6 05 cd f3 1e f0 8e 	movb   $0x8e,0xf01ef3cd
f0103e6c:	c1 e8 10             	shr    $0x10,%eax
f0103e6f:	66 a3 ce f3 1e f0    	mov    %ax,0xf01ef3ce
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, th46, 0);
f0103e75:	b8 ec 45 10 f0       	mov    $0xf01045ec,%eax
f0103e7a:	66 a3 d0 f3 1e f0    	mov    %ax,0xf01ef3d0
f0103e80:	66 c7 05 d2 f3 1e f0 	movw   $0x8,0xf01ef3d2
f0103e87:	08 00 
f0103e89:	c6 05 d4 f3 1e f0 00 	movb   $0x0,0xf01ef3d4
f0103e90:	c6 05 d5 f3 1e f0 8e 	movb   $0x8e,0xf01ef3d5
f0103e97:	c1 e8 10             	shr    $0x10,%eax
f0103e9a:	66 a3 d6 f3 1e f0    	mov    %ax,0xf01ef3d6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, th47, 0);
f0103ea0:	b8 f2 45 10 f0       	mov    $0xf01045f2,%eax
f0103ea5:	66 a3 d8 f3 1e f0    	mov    %ax,0xf01ef3d8
f0103eab:	66 c7 05 da f3 1e f0 	movw   $0x8,0xf01ef3da
f0103eb2:	08 00 
f0103eb4:	c6 05 dc f3 1e f0 00 	movb   $0x0,0xf01ef3dc
f0103ebb:	c6 05 dd f3 1e f0 8e 	movb   $0x8e,0xf01ef3dd
f0103ec2:	c1 e8 10             	shr    $0x10,%eax
f0103ec5:	66 a3 de f3 1e f0    	mov    %ax,0xf01ef3de
	SETGATE(idt[T_SYSCALL], 0, GD_KT, th_syscall, 3);	
f0103ecb:	b8 92 45 10 f0       	mov    $0xf0104592,%eax
f0103ed0:	66 a3 e0 f3 1e f0    	mov    %ax,0xf01ef3e0
f0103ed6:	66 c7 05 e2 f3 1e f0 	movw   $0x8,0xf01ef3e2
f0103edd:	08 00 
f0103edf:	c6 05 e4 f3 1e f0 00 	movb   $0x0,0xf01ef3e4
f0103ee6:	c6 05 e5 f3 1e f0 ee 	movb   $0xee,0xf01ef3e5
f0103eed:	c1 e8 10             	shr    $0x10,%eax
f0103ef0:	66 a3 e6 f3 1e f0    	mov    %ax,0xf01ef3e6
	
	// Per-CPU setup 
	trap_init_percpu();
f0103ef6:	e8 35 f8 ff ff       	call   f0103730 <trap_init_percpu>
}
f0103efb:	c9                   	leave  
f0103efc:	c3                   	ret    

f0103efd <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103efd:	55                   	push   %ebp
f0103efe:	89 e5                	mov    %esp,%ebp
f0103f00:	53                   	push   %ebx
f0103f01:	83 ec 0c             	sub    $0xc,%esp
f0103f04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f07:	ff 33                	pushl  (%ebx)
f0103f09:	68 90 77 10 f0       	push   $0xf0107790
f0103f0e:	e8 f3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f13:	83 c4 08             	add    $0x8,%esp
f0103f16:	ff 73 04             	pushl  0x4(%ebx)
f0103f19:	68 9f 77 10 f0       	push   $0xf010779f
f0103f1e:	e8 e3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f23:	83 c4 08             	add    $0x8,%esp
f0103f26:	ff 73 08             	pushl  0x8(%ebx)
f0103f29:	68 ae 77 10 f0       	push   $0xf01077ae
f0103f2e:	e8 d3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f33:	83 c4 08             	add    $0x8,%esp
f0103f36:	ff 73 0c             	pushl  0xc(%ebx)
f0103f39:	68 bd 77 10 f0       	push   $0xf01077bd
f0103f3e:	e8 c3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f43:	83 c4 08             	add    $0x8,%esp
f0103f46:	ff 73 10             	pushl  0x10(%ebx)
f0103f49:	68 cc 77 10 f0       	push   $0xf01077cc
f0103f4e:	e8 b3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f53:	83 c4 08             	add    $0x8,%esp
f0103f56:	ff 73 14             	pushl  0x14(%ebx)
f0103f59:	68 db 77 10 f0       	push   $0xf01077db
f0103f5e:	e8 a3 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f63:	83 c4 08             	add    $0x8,%esp
f0103f66:	ff 73 18             	pushl  0x18(%ebx)
f0103f69:	68 ea 77 10 f0       	push   $0xf01077ea
f0103f6e:	e8 93 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f73:	83 c4 08             	add    $0x8,%esp
f0103f76:	ff 73 1c             	pushl  0x1c(%ebx)
f0103f79:	68 f9 77 10 f0       	push   $0xf01077f9
f0103f7e:	e8 83 f7 ff ff       	call   f0103706 <cprintf>
f0103f83:	83 c4 10             	add    $0x10,%esp
}
f0103f86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f89:	c9                   	leave  
f0103f8a:	c3                   	ret    

f0103f8b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103f8b:	55                   	push   %ebp
f0103f8c:	89 e5                	mov    %esp,%ebp
f0103f8e:	53                   	push   %ebx
f0103f8f:	83 ec 04             	sub    $0x4,%esp
f0103f92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103f95:	e8 d4 1d 00 00       	call   f0105d6e <cpunum>
f0103f9a:	83 ec 04             	sub    $0x4,%esp
f0103f9d:	50                   	push   %eax
f0103f9e:	53                   	push   %ebx
f0103f9f:	68 08 78 10 f0       	push   $0xf0107808
f0103fa4:	e8 5d f7 ff ff       	call   f0103706 <cprintf>
	print_regs(&tf->tf_regs);
f0103fa9:	89 1c 24             	mov    %ebx,(%esp)
f0103fac:	e8 4c ff ff ff       	call   f0103efd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103fb1:	83 c4 08             	add    $0x8,%esp
f0103fb4:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103fb8:	50                   	push   %eax
f0103fb9:	68 26 78 10 f0       	push   $0xf0107826
f0103fbe:	e8 43 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103fc3:	83 c4 08             	add    $0x8,%esp
f0103fc6:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103fca:	50                   	push   %eax
f0103fcb:	68 39 78 10 f0       	push   $0xf0107839
f0103fd0:	e8 31 f7 ff ff       	call   f0103706 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fd5:	8b 53 28             	mov    0x28(%ebx),%edx
f0103fd8:	89 d0                	mov    %edx,%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103fda:	83 c4 10             	add    $0x10,%esp
f0103fdd:	83 fa 13             	cmp    $0x13,%edx
f0103fe0:	77 09                	ja     f0103feb <print_trapframe+0x60>
		return excnames[trapno];
f0103fe2:	8b 04 95 40 7b 10 f0 	mov    -0xfef84c0(,%edx,4),%eax
f0103fe9:	eb 20                	jmp    f010400b <print_trapframe+0x80>
	if (trapno == T_SYSCALL)
f0103feb:	83 fa 30             	cmp    $0x30,%edx
f0103fee:	75 07                	jne    f0103ff7 <print_trapframe+0x6c>
f0103ff0:	b8 4c 78 10 f0       	mov    $0xf010784c,%eax
f0103ff5:	eb 14                	jmp    f010400b <print_trapframe+0x80>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ff7:	83 e8 20             	sub    $0x20,%eax
f0103ffa:	83 f8 0f             	cmp    $0xf,%eax
f0103ffd:	77 07                	ja     f0104006 <print_trapframe+0x7b>
f0103fff:	b8 58 78 10 f0       	mov    $0xf0107858,%eax
f0104004:	eb 05                	jmp    f010400b <print_trapframe+0x80>
f0104006:	b8 6b 78 10 f0       	mov    $0xf010786b,%eax
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010400b:	83 ec 04             	sub    $0x4,%esp
f010400e:	50                   	push   %eax
f010400f:	52                   	push   %edx
f0104010:	68 7a 78 10 f0       	push   $0xf010787a
f0104015:	e8 ec f6 ff ff       	call   f0103706 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010401a:	83 c4 10             	add    $0x10,%esp
f010401d:	3b 1d 60 fa 1e f0    	cmp    0xf01efa60,%ebx
f0104023:	75 1a                	jne    f010403f <print_trapframe+0xb4>
f0104025:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104029:	75 14                	jne    f010403f <print_trapframe+0xb4>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010402b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010402e:	83 ec 08             	sub    $0x8,%esp
f0104031:	50                   	push   %eax
f0104032:	68 8c 78 10 f0       	push   $0xf010788c
f0104037:	e8 ca f6 ff ff       	call   f0103706 <cprintf>
f010403c:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010403f:	83 ec 08             	sub    $0x8,%esp
f0104042:	ff 73 2c             	pushl  0x2c(%ebx)
f0104045:	68 9b 78 10 f0       	push   $0xf010789b
f010404a:	e8 b7 f6 ff ff       	call   f0103706 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010404f:	83 c4 10             	add    $0x10,%esp
f0104052:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104056:	75 45                	jne    f010409d <print_trapframe+0x112>
		cprintf(" [%s, %s, %s]\n",
f0104058:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010405b:	a8 01                	test   $0x1,%al
f010405d:	74 07                	je     f0104066 <print_trapframe+0xdb>
f010405f:	b9 a9 78 10 f0       	mov    $0xf01078a9,%ecx
f0104064:	eb 05                	jmp    f010406b <print_trapframe+0xe0>
f0104066:	b9 b4 78 10 f0       	mov    $0xf01078b4,%ecx
f010406b:	a8 02                	test   $0x2,%al
f010406d:	74 07                	je     f0104076 <print_trapframe+0xeb>
f010406f:	ba c0 78 10 f0       	mov    $0xf01078c0,%edx
f0104074:	eb 05                	jmp    f010407b <print_trapframe+0xf0>
f0104076:	ba c6 78 10 f0       	mov    $0xf01078c6,%edx
f010407b:	a8 04                	test   $0x4,%al
f010407d:	74 07                	je     f0104086 <print_trapframe+0xfb>
f010407f:	b8 cb 78 10 f0       	mov    $0xf01078cb,%eax
f0104084:	eb 05                	jmp    f010408b <print_trapframe+0x100>
f0104086:	b8 8d 79 10 f0       	mov    $0xf010798d,%eax
f010408b:	51                   	push   %ecx
f010408c:	52                   	push   %edx
f010408d:	50                   	push   %eax
f010408e:	68 d0 78 10 f0       	push   $0xf01078d0
f0104093:	e8 6e f6 ff ff       	call   f0103706 <cprintf>
f0104098:	83 c4 10             	add    $0x10,%esp
f010409b:	eb 10                	jmp    f01040ad <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010409d:	83 ec 0c             	sub    $0xc,%esp
f01040a0:	68 65 76 10 f0       	push   $0xf0107665
f01040a5:	e8 5c f6 ff ff       	call   f0103706 <cprintf>
f01040aa:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040ad:	83 ec 08             	sub    $0x8,%esp
f01040b0:	ff 73 30             	pushl  0x30(%ebx)
f01040b3:	68 df 78 10 f0       	push   $0xf01078df
f01040b8:	e8 49 f6 ff ff       	call   f0103706 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040bd:	83 c4 08             	add    $0x8,%esp
f01040c0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01040c4:	50                   	push   %eax
f01040c5:	68 ee 78 10 f0       	push   $0xf01078ee
f01040ca:	e8 37 f6 ff ff       	call   f0103706 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040cf:	83 c4 08             	add    $0x8,%esp
f01040d2:	ff 73 38             	pushl  0x38(%ebx)
f01040d5:	68 01 79 10 f0       	push   $0xf0107901
f01040da:	e8 27 f6 ff ff       	call   f0103706 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01040df:	83 c4 10             	add    $0x10,%esp
f01040e2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040e6:	74 25                	je     f010410d <print_trapframe+0x182>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040e8:	83 ec 08             	sub    $0x8,%esp
f01040eb:	ff 73 3c             	pushl  0x3c(%ebx)
f01040ee:	68 10 79 10 f0       	push   $0xf0107910
f01040f3:	e8 0e f6 ff ff       	call   f0103706 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040f8:	83 c4 08             	add    $0x8,%esp
f01040fb:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01040ff:	50                   	push   %eax
f0104100:	68 1f 79 10 f0       	push   $0xf010791f
f0104105:	e8 fc f5 ff ff       	call   f0103706 <cprintf>
f010410a:	83 c4 10             	add    $0x10,%esp
	}
}
f010410d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104110:	c9                   	leave  
f0104111:	c3                   	ret    

f0104112 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104112:	55                   	push   %ebp
f0104113:	89 e5                	mov    %esp,%ebp
f0104115:	57                   	push   %edi
f0104116:	56                   	push   %esi
f0104117:	53                   	push   %ebx
f0104118:	83 ec 0c             	sub    $0xc,%esp
f010411b:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) //内核态发生缺页中断直接panic
f010411e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104121:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0104125:	75 17                	jne    f010413e <page_fault_handler+0x2c>
		panic("page_fault_handler():page fault in kernel mode!\n");
f0104127:	83 ec 04             	sub    $0x4,%esp
f010412a:	68 d8 7a 10 f0       	push   $0xf0107ad8
f010412f:	68 72 01 00 00       	push   $0x172
f0104134:	68 32 79 10 f0       	push   $0xf0107932
f0104139:	e8 3d bf ff ff       	call   f010007b <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	//already have upcall 
	if(curenv->env_pgfault_upcall){
f010413e:	e8 2b 1c 00 00       	call   f0105d6e <cpunum>
f0104143:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010414a:	29 c2                	sub    %eax,%edx
f010414c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010414f:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104156:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010415a:	0f 84 af 00 00 00    	je     f010420f <page_fault_handler+0xfd>
	struct UTrapframe * utf;
	if(ROUNDDOWN(tf->tf_esp, PGSIZE) == UXSTACKTOP - PGSIZE){
f0104160:	8b 75 08             	mov    0x8(%ebp),%esi
f0104163:	8b 56 3c             	mov    0x3c(%esi),%edx
f0104166:	89 d0                	mov    %edx,%eax
f0104168:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010416d:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
f0104172:	74 07                	je     f010417b <page_fault_handler+0x69>
f0104174:	bb cc ff bf ee       	mov    $0xeebfffcc,%ebx
f0104179:	eb 03                	jmp    f010417e <page_fault_handler+0x6c>
		utf = (struct UTrapframe *)((tf->tf_esp) - sizeof(struct UTrapframe) - 4);//32bit reservation for trap-time-esp
f010417b:	8d 5a c8             	lea    -0x38(%edx),%ebx
	}else{
		utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));//no reservation
		}
		
	user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W | PTE_U | PTE_P);
f010417e:	e8 eb 1b 00 00       	call   f0105d6e <cpunum>
f0104183:	6a 07                	push   $0x7
f0104185:	6a 34                	push   $0x34
f0104187:	53                   	push   %ebx
f0104188:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010418f:	29 c2                	sub    %eax,%edx
f0104191:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104194:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f010419b:	e8 2e cd ff ff       	call   f0100ece <user_mem_assert>
	utf->utf_fault_va = fault_va;
f01041a0:	89 3b                	mov    %edi,(%ebx)
	utf->utf_err = tf->tf_err;
f01041a2:	8b 55 08             	mov    0x8(%ebp),%edx
f01041a5:	8b 42 2c             	mov    0x2c(%edx),%eax
f01041a8:	89 43 04             	mov    %eax,0x4(%ebx)
	utf->utf_regs = tf->tf_regs;
f01041ab:	8d 7b 08             	lea    0x8(%ebx),%edi
f01041ae:	fc                   	cld    
f01041af:	b9 08 00 00 00       	mov    $0x8,%ecx
f01041b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01041b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f01041b9:	8b 42 30             	mov    0x30(%edx),%eax
f01041bc:	89 43 28             	mov    %eax,0x28(%ebx)
	utf->utf_eflags = tf->tf_eflags;
f01041bf:	8b 42 38             	mov    0x38(%edx),%eax
f01041c2:	89 43 2c             	mov    %eax,0x2c(%ebx)
	utf->utf_esp = tf->tf_esp;
f01041c5:	8b 42 3c             	mov    0x3c(%edx),%eax
f01041c8:	89 43 30             	mov    %eax,0x30(%ebx)

	tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;//turn to upcalll wrapper
f01041cb:	e8 9e 1b 00 00       	call   f0105d6e <cpunum>
f01041d0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041d7:	29 c2                	sub    %eax,%edx
f01041d9:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01041dc:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01041e3:	8b 40 64             	mov    0x64(%eax),%eax
f01041e6:	8b 55 08             	mov    0x8(%ebp),%edx
f01041e9:	89 42 30             	mov    %eax,0x30(%edx)
	tf->tf_esp = (uintptr_t)utf;//for next time UTrapframe to store,excetion stack to excute
f01041ec:	89 5a 3c             	mov    %ebx,0x3c(%edx)
	env_run(curenv);//返回user-mode
f01041ef:	e8 7a 1b 00 00       	call   f0105d6e <cpunum>
f01041f4:	83 c4 04             	add    $0x4,%esp
f01041f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041fe:	29 c2                	sub    %eax,%edx
f0104200:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104203:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f010420a:	e8 29 ef ff ff       	call   f0103138 <env_run>
	}
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010420f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104212:	8b 5e 30             	mov    0x30(%esi),%ebx
f0104215:	e8 54 1b 00 00       	call   f0105d6e <cpunum>
f010421a:	53                   	push   %ebx
f010421b:	57                   	push   %edi
f010421c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104223:	29 c2                	sub    %eax,%edx
f0104225:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104228:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f010422f:	ff 70 48             	pushl  0x48(%eax)
f0104232:	68 0c 7b 10 f0       	push   $0xf0107b0c
f0104237:	e8 ca f4 ff ff       	call   f0103706 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010423c:	89 34 24             	mov    %esi,(%esp)
f010423f:	e8 47 fd ff ff       	call   f0103f8b <print_trapframe>
	env_destroy(curenv);
f0104244:	e8 25 1b 00 00       	call   f0105d6e <cpunum>
f0104249:	83 c4 04             	add    $0x4,%esp
f010424c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104253:	29 c2                	sub    %eax,%edx
f0104255:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104258:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f010425f:	e8 b4 f1 ff ff       	call   f0103418 <env_destroy>
f0104264:	83 c4 10             	add    $0x10,%esp
	
}
f0104267:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010426a:	5b                   	pop    %ebx
f010426b:	5e                   	pop    %esi
f010426c:	5f                   	pop    %edi
f010426d:	c9                   	leave  
f010426e:	c3                   	ret    

f010426f <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010426f:	55                   	push   %ebp
f0104270:	89 e5                	mov    %esp,%ebp
f0104272:	53                   	push   %ebx
f0104273:	83 ec 04             	sub    $0x4,%esp
f0104276:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104279:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010427a:	83 3d 80 fe 1e f0 00 	cmpl   $0x0,0xf01efe80
f0104281:	74 01                	je     f0104284 <trap+0x15>
		asm volatile("hlt");
f0104283:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104284:	e8 e5 1a 00 00       	call   f0105d6e <cpunum>
f0104289:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104290:	29 c2                	sub    %eax,%edx
f0104292:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104295:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010429c:	b8 01 00 00 00       	mov    $0x1,%eax
f01042a1:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01042a5:	83 f8 02             	cmp    $0x2,%eax
f01042a8:	75 10                	jne    f01042ba <trap+0x4b>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01042aa:	83 ec 0c             	sub    $0xc,%esp
f01042ad:	68 a0 43 12 f0       	push   $0xf01243a0
f01042b2:	e8 56 1e 00 00       	call   f010610d <spin_lock>
f01042b7:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01042ba:	9c                   	pushf  
f01042bb:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01042bc:	f6 c4 02             	test   $0x2,%ah
f01042bf:	74 19                	je     f01042da <trap+0x6b>
f01042c1:	68 3e 79 10 f0       	push   $0xf010793e
f01042c6:	68 ab 73 10 f0       	push   $0xf01073ab
f01042cb:	68 3d 01 00 00       	push   $0x13d
f01042d0:	68 32 79 10 f0       	push   $0xf0107932
f01042d5:	e8 a1 bd ff ff       	call   f010007b <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01042da:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01042de:	83 e0 03             	and    $0x3,%eax
f01042e1:	83 f8 03             	cmp    $0x3,%eax
f01042e4:	0f 85 e1 00 00 00    	jne    f01043cb <trap+0x15c>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f01042ea:	e8 7f 1a 00 00       	call   f0105d6e <cpunum>
f01042ef:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01042f6:	29 c2                	sub    %eax,%edx
f01042f8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01042fb:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f0104302:	00 
f0104303:	75 19                	jne    f010431e <trap+0xaf>
f0104305:	68 57 79 10 f0       	push   $0xf0107957
f010430a:	68 ab 73 10 f0       	push   $0xf01073ab
f010430f:	68 44 01 00 00       	push   $0x144
f0104314:	68 32 79 10 f0       	push   $0xf0107932
f0104319:	e8 5d bd ff ff       	call   f010007b <_panic>
f010431e:	83 ec 0c             	sub    $0xc,%esp
f0104321:	68 a0 43 12 f0       	push   $0xf01243a0
f0104326:	e8 e2 1d 00 00       	call   f010610d <spin_lock>
		lock_kernel();
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010432b:	e8 3e 1a 00 00       	call   f0105d6e <cpunum>
f0104330:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104337:	29 c2                	sub    %eax,%edx
f0104339:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010433c:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104343:	83 c4 10             	add    $0x10,%esp
f0104346:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010434a:	75 41                	jne    f010438d <trap+0x11e>
			env_free(curenv);
f010434c:	e8 1d 1a 00 00       	call   f0105d6e <cpunum>
f0104351:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104358:	29 c2                	sub    %eax,%edx
f010435a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010435d:	83 ec 0c             	sub    $0xc,%esp
f0104360:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f0104367:	e8 ed ee ff ff       	call   f0103259 <env_free>
			curenv = NULL;
f010436c:	e8 fd 19 00 00       	call   f0105d6e <cpunum>
f0104371:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104378:	29 c2                	sub    %eax,%edx
f010437a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010437d:	c7 04 95 28 00 1f f0 	movl   $0x0,-0xfe0ffd8(,%edx,4)
f0104384:	00 00 00 00 
			sched_yield();
f0104388:	e8 5e 03 00 00       	call   f01046eb <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010438d:	e8 dc 19 00 00       	call   f0105d6e <cpunum>
f0104392:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104399:	29 c2                	sub    %eax,%edx
f010439b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010439e:	83 ec 04             	sub    $0x4,%esp
f01043a1:	6a 44                	push   $0x44
f01043a3:	53                   	push   %ebx
f01043a4:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f01043ab:	e8 52 14 00 00       	call   f0105802 <memcpy>
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01043b0:	e8 b9 19 00 00       	call   f0105d6e <cpunum>
f01043b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043bc:	29 c2                	sub    %eax,%edx
f01043be:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01043c1:	8b 1c 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%ebx
f01043c8:	83 c4 10             	add    $0x10,%esp
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01043cb:	89 1d 60 fa 1e f0    	mov    %ebx,0xf01efa60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f01043d1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01043d5:	75 11                	jne    f01043e8 <trap+0x179>
		page_fault_handler(tf);
f01043d7:	83 ec 0c             	sub    $0xc,%esp
f01043da:	53                   	push   %ebx
f01043db:	e8 32 fd ff ff       	call   f0104112 <page_fault_handler>
f01043e0:	83 c4 10             	add    $0x10,%esp
f01043e3:	e9 d8 00 00 00       	jmp    f01044c0 <trap+0x251>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f01043e8:	83 7b 28 03          	cmpl   $0x3,0x28(%ebx)
f01043ec:	75 11                	jne    f01043ff <trap+0x190>
		monitor(tf);
f01043ee:	83 ec 0c             	sub    $0xc,%esp
f01043f1:	53                   	push   %ebx
f01043f2:	e8 8b c4 ff ff       	call   f0100882 <monitor>
f01043f7:	83 c4 10             	add    $0x10,%esp
f01043fa:	e9 c1 00 00 00       	jmp    f01044c0 <trap+0x251>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) { 
f01043ff:	83 7b 28 30          	cmpl   $0x30,0x28(%ebx)
f0104403:	75 24                	jne    f0104429 <trap+0x1ba>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104405:	83 ec 08             	sub    $0x8,%esp
f0104408:	ff 73 04             	pushl  0x4(%ebx)
f010440b:	ff 33                	pushl  (%ebx)
f010440d:	ff 73 10             	pushl  0x10(%ebx)
f0104410:	ff 73 18             	pushl  0x18(%ebx)
f0104413:	ff 73 14             	pushl  0x14(%ebx)
f0104416:	ff 73 1c             	pushl  0x1c(%ebx)
f0104419:	e8 c9 03 00 00       	call   f01047e7 <syscall>
f010441e:	89 43 1c             	mov    %eax,0x1c(%ebx)
f0104421:	83 c4 20             	add    $0x20,%esp
f0104424:	e9 97 00 00 00       	jmp    f01044c0 <trap+0x251>


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104429:	83 7b 28 27          	cmpl   $0x27,0x28(%ebx)
f010442d:	75 1a                	jne    f0104449 <trap+0x1da>
		cprintf("Spurious interrupt on irq 7\n");
f010442f:	83 ec 0c             	sub    $0xc,%esp
f0104432:	68 5e 79 10 f0       	push   $0xf010795e
f0104437:	e8 ca f2 ff ff       	call   f0103706 <cprintf>
		print_trapframe(tf);
f010443c:	89 1c 24             	mov    %ebx,(%esp)
f010443f:	e8 47 fb ff ff       	call   f0103f8b <print_trapframe>
f0104444:	83 c4 10             	add    $0x10,%esp
f0104447:	eb 77                	jmp    f01044c0 <trap+0x251>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104449:	83 7b 28 20          	cmpl   $0x20,0x28(%ebx)
f010444d:	75 0a                	jne    f0104459 <trap+0x1ea>
		lapic_eoi();
f010444f:	e8 2e 19 00 00       	call   f0105d82 <lapic_eoi>
		sched_yield();
f0104454:	e8 92 02 00 00       	call   f01046eb <sched_yield>
		return;
	}
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD){
f0104459:	83 7b 28 21          	cmpl   $0x21,0x28(%ebx)
f010445d:	75 07                	jne    f0104466 <trap+0x1f7>
		kbd_intr();
f010445f:	e8 92 be ff ff       	call   f01002f6 <kbd_intr>
f0104464:	eb 5a                	jmp    f01044c0 <trap+0x251>
		return;
	}
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL){
f0104466:	83 7b 28 24          	cmpl   $0x24,0x28(%ebx)
f010446a:	75 07                	jne    f0104473 <trap+0x204>
		serial_intr();
f010446c:	e8 97 be ff ff       	call   f0100308 <serial_intr>
f0104471:	eb 4d                	jmp    f01044c0 <trap+0x251>
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104473:	83 ec 0c             	sub    $0xc,%esp
f0104476:	53                   	push   %ebx
f0104477:	e8 0f fb ff ff       	call   f0103f8b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010447c:	83 c4 10             	add    $0x10,%esp
f010447f:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104484:	75 17                	jne    f010449d <trap+0x22e>
		panic("unhandled trap in kernel");
f0104486:	83 ec 04             	sub    $0x4,%esp
f0104489:	68 7b 79 10 f0       	push   $0xf010797b
f010448e:	68 23 01 00 00       	push   $0x123
f0104493:	68 32 79 10 f0       	push   $0xf0107932
f0104498:	e8 de bb ff ff       	call   f010007b <_panic>
	else {
		env_destroy(curenv);
f010449d:	e8 cc 18 00 00       	call   f0105d6e <cpunum>
f01044a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044a9:	29 c2                	sub    %eax,%edx
f01044ab:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01044ae:	83 ec 0c             	sub    $0xc,%esp
f01044b1:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f01044b8:	e8 5b ef ff ff       	call   f0103418 <env_destroy>
f01044bd:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01044c0:	e8 a9 18 00 00       	call   f0105d6e <cpunum>
f01044c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044cc:	29 c2                	sub    %eax,%edx
f01044ce:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01044d1:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f01044d8:	00 
f01044d9:	74 3e                	je     f0104519 <trap+0x2aa>
f01044db:	e8 8e 18 00 00       	call   f0105d6e <cpunum>
f01044e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044e7:	29 c2                	sub    %eax,%edx
f01044e9:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01044ec:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01044f3:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044f7:	75 20                	jne    f0104519 <trap+0x2aa>
		env_run(curenv);
f01044f9:	e8 70 18 00 00       	call   f0105d6e <cpunum>
f01044fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104505:	29 c2                	sub    %eax,%edx
f0104507:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010450a:	83 ec 0c             	sub    $0xc,%esp
f010450d:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f0104514:	e8 1f ec ff ff       	call   f0103138 <env_run>
	else
		sched_yield();
f0104519:	e8 cd 01 00 00       	call   f01046eb <sched_yield>
	...

f0104520 <th0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(th0, 0)
f0104520:	6a 00                	push   $0x0
f0104522:	6a 00                	push   $0x0
f0104524:	e9 cf 00 00 00       	jmp    f01045f8 <_alltraps>
f0104529:	90                   	nop

f010452a <th1>:
	TRAPHANDLER_NOEC(th1, 1)
f010452a:	6a 00                	push   $0x0
f010452c:	6a 01                	push   $0x1
f010452e:	e9 c5 00 00 00       	jmp    f01045f8 <_alltraps>
f0104533:	90                   	nop

f0104534 <th3>:
	TRAPHANDLER_NOEC(th3, 3)
f0104534:	6a 00                	push   $0x0
f0104536:	6a 03                	push   $0x3
f0104538:	e9 bb 00 00 00       	jmp    f01045f8 <_alltraps>
f010453d:	90                   	nop

f010453e <th4>:
	TRAPHANDLER_NOEC(th4, 4)
f010453e:	6a 00                	push   $0x0
f0104540:	6a 04                	push   $0x4
f0104542:	e9 b1 00 00 00       	jmp    f01045f8 <_alltraps>
f0104547:	90                   	nop

f0104548 <th5>:
	TRAPHANDLER_NOEC(th5, 5)
f0104548:	6a 00                	push   $0x0
f010454a:	6a 05                	push   $0x5
f010454c:	e9 a7 00 00 00       	jmp    f01045f8 <_alltraps>
f0104551:	90                   	nop

f0104552 <th6>:
	TRAPHANDLER_NOEC(th6, 6)
f0104552:	6a 00                	push   $0x0
f0104554:	6a 06                	push   $0x6
f0104556:	e9 9d 00 00 00       	jmp    f01045f8 <_alltraps>
f010455b:	90                   	nop

f010455c <th7>:
	TRAPHANDLER_NOEC(th7, 7)
f010455c:	6a 00                	push   $0x0
f010455e:	6a 07                	push   $0x7
f0104560:	e9 93 00 00 00       	jmp    f01045f8 <_alltraps>
f0104565:	90                   	nop

f0104566 <th8>:
	TRAPHANDLER(th8, 8)
f0104566:	6a 08                	push   $0x8
f0104568:	e9 8b 00 00 00       	jmp    f01045f8 <_alltraps>
f010456d:	90                   	nop

f010456e <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f010456e:	6a 00                	push   $0x0
f0104570:	6a 09                	push   $0x9
f0104572:	e9 81 00 00 00       	jmp    f01045f8 <_alltraps>
f0104577:	90                   	nop

f0104578 <th10>:
	TRAPHANDLER(th10, 10)
f0104578:	6a 0a                	push   $0xa
f010457a:	eb 7c                	jmp    f01045f8 <_alltraps>

f010457c <th11>:
	TRAPHANDLER(th11, 11)
f010457c:	6a 0b                	push   $0xb
f010457e:	eb 78                	jmp    f01045f8 <_alltraps>

f0104580 <th12>:
	TRAPHANDLER(th12, 12)
f0104580:	6a 0c                	push   $0xc
f0104582:	eb 74                	jmp    f01045f8 <_alltraps>

f0104584 <th13>:
	TRAPHANDLER(th13, 13)
f0104584:	6a 0d                	push   $0xd
f0104586:	eb 70                	jmp    f01045f8 <_alltraps>

f0104588 <th14>:
	TRAPHANDLER(th14, 14)
f0104588:	6a 0e                	push   $0xe
f010458a:	eb 6c                	jmp    f01045f8 <_alltraps>

f010458c <th16>:
	TRAPHANDLER_NOEC(th16, 16)
f010458c:	6a 00                	push   $0x0
f010458e:	6a 10                	push   $0x10
f0104590:	eb 66                	jmp    f01045f8 <_alltraps>

f0104592 <th_syscall>:
	TRAPHANDLER_NOEC(th_syscall, T_SYSCALL)
f0104592:	6a 00                	push   $0x0
f0104594:	6a 30                	push   $0x30
f0104596:	eb 60                	jmp    f01045f8 <_alltraps>

f0104598 <th32>:
	
	TRAPHANDLER_NOEC(th32, IRQ_OFFSET)
f0104598:	6a 00                	push   $0x0
f010459a:	6a 20                	push   $0x20
f010459c:	eb 5a                	jmp    f01045f8 <_alltraps>

f010459e <th33>:
	TRAPHANDLER_NOEC(th33, IRQ_OFFSET + 1)
f010459e:	6a 00                	push   $0x0
f01045a0:	6a 21                	push   $0x21
f01045a2:	eb 54                	jmp    f01045f8 <_alltraps>

f01045a4 <th34>:
	TRAPHANDLER_NOEC(th34, IRQ_OFFSET + 2)
f01045a4:	6a 00                	push   $0x0
f01045a6:	6a 22                	push   $0x22
f01045a8:	eb 4e                	jmp    f01045f8 <_alltraps>

f01045aa <th35>:
	TRAPHANDLER_NOEC(th35, IRQ_OFFSET + 3)
f01045aa:	6a 00                	push   $0x0
f01045ac:	6a 23                	push   $0x23
f01045ae:	eb 48                	jmp    f01045f8 <_alltraps>

f01045b0 <th36>:
	TRAPHANDLER_NOEC(th36, IRQ_OFFSET + 4)
f01045b0:	6a 00                	push   $0x0
f01045b2:	6a 24                	push   $0x24
f01045b4:	eb 42                	jmp    f01045f8 <_alltraps>

f01045b6 <th37>:
	TRAPHANDLER_NOEC(th37, IRQ_OFFSET + 5)
f01045b6:	6a 00                	push   $0x0
f01045b8:	6a 25                	push   $0x25
f01045ba:	eb 3c                	jmp    f01045f8 <_alltraps>

f01045bc <th38>:
	TRAPHANDLER_NOEC(th38, IRQ_OFFSET + 6)
f01045bc:	6a 00                	push   $0x0
f01045be:	6a 26                	push   $0x26
f01045c0:	eb 36                	jmp    f01045f8 <_alltraps>

f01045c2 <th39>:
	TRAPHANDLER_NOEC(th39, IRQ_OFFSET + 7)
f01045c2:	6a 00                	push   $0x0
f01045c4:	6a 27                	push   $0x27
f01045c6:	eb 30                	jmp    f01045f8 <_alltraps>

f01045c8 <th40>:
	TRAPHANDLER_NOEC(th40, IRQ_OFFSET + 8)
f01045c8:	6a 00                	push   $0x0
f01045ca:	6a 28                	push   $0x28
f01045cc:	eb 2a                	jmp    f01045f8 <_alltraps>

f01045ce <th41>:
	TRAPHANDLER_NOEC(th41, IRQ_OFFSET + 9)
f01045ce:	6a 00                	push   $0x0
f01045d0:	6a 29                	push   $0x29
f01045d2:	eb 24                	jmp    f01045f8 <_alltraps>

f01045d4 <th42>:
	TRAPHANDLER_NOEC(th42, IRQ_OFFSET + 10)
f01045d4:	6a 00                	push   $0x0
f01045d6:	6a 2a                	push   $0x2a
f01045d8:	eb 1e                	jmp    f01045f8 <_alltraps>

f01045da <th43>:
	TRAPHANDLER_NOEC(th43, IRQ_OFFSET + 11)
f01045da:	6a 00                	push   $0x0
f01045dc:	6a 2b                	push   $0x2b
f01045de:	eb 18                	jmp    f01045f8 <_alltraps>

f01045e0 <th44>:
	TRAPHANDLER_NOEC(th44, IRQ_OFFSET + 12)
f01045e0:	6a 00                	push   $0x0
f01045e2:	6a 2c                	push   $0x2c
f01045e4:	eb 12                	jmp    f01045f8 <_alltraps>

f01045e6 <th45>:
	TRAPHANDLER_NOEC(th45, IRQ_OFFSET + 13)
f01045e6:	6a 00                	push   $0x0
f01045e8:	6a 2d                	push   $0x2d
f01045ea:	eb 0c                	jmp    f01045f8 <_alltraps>

f01045ec <th46>:
	TRAPHANDLER_NOEC(th46, IRQ_OFFSET + 14)
f01045ec:	6a 00                	push   $0x0
f01045ee:	6a 2e                	push   $0x2e
f01045f0:	eb 06                	jmp    f01045f8 <_alltraps>

f01045f2 <th47>:
	TRAPHANDLER_NOEC(th47, IRQ_OFFSET + 15)
f01045f2:	6a 00                	push   $0x0
f01045f4:	6a 2f                	push   $0x2f
f01045f6:	eb 00                	jmp    f01045f8 <_alltraps>

f01045f8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
	pushl %ds
f01045f8:	1e                   	push   %ds
	pushl %es
f01045f9:	06                   	push   %es
	pushal
f01045fa:	60                   	pusha  
	pushl $GD_KD
f01045fb:	6a 10                	push   $0x10
	popl %ds
f01045fd:	1f                   	pop    %ds
	pushl $GD_KD
f01045fe:	6a 10                	push   $0x10
	popl %es
f0104600:	07                   	pop    %es
	pushl %esp	
f0104601:	54                   	push   %esp
	call trap
f0104602:	e8 68 fc ff ff       	call   f010426f <trap>
	...

f0104608 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104608:	55                   	push   %ebp
f0104609:	89 e5                	mov    %esp,%ebp
f010460b:	83 ec 08             	sub    $0x8,%esp
f010460e:	8b 15 38 f2 1e f0    	mov    0xf01ef238,%edx
f0104614:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104619:	8b 42 54             	mov    0x54(%edx),%eax
f010461c:	48                   	dec    %eax
f010461d:	83 f8 02             	cmp    $0x2,%eax
f0104620:	76 2b                	jbe    f010464d <sched_halt+0x45>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104622:	41                   	inc    %ecx
f0104623:	83 c2 7c             	add    $0x7c,%edx
f0104626:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010462c:	75 eb                	jne    f0104619 <sched_halt+0x11>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f010462e:	83 ec 0c             	sub    $0xc,%esp
f0104631:	68 90 7b 10 f0       	push   $0xf0107b90
f0104636:	e8 cb f0 ff ff       	call   f0103706 <cprintf>
f010463b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010463e:	83 ec 0c             	sub    $0xc,%esp
f0104641:	6a 00                	push   $0x0
f0104643:	e8 3a c2 ff ff       	call   f0100882 <monitor>
f0104648:	83 c4 10             	add    $0x10,%esp
f010464b:	eb f1                	jmp    f010463e <sched_halt+0x36>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010464d:	e8 1c 17 00 00       	call   f0105d6e <cpunum>
f0104652:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104659:	29 c2                	sub    %eax,%edx
f010465b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010465e:	c7 04 95 28 00 1f f0 	movl   $0x0,-0xfe0ffd8(,%edx,4)
f0104665:	00 00 00 00 
f0104669:	a1 8c fe 1e f0       	mov    0xf01efe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010466e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104673:	77 12                	ja     f0104687 <sched_halt+0x7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104675:	50                   	push   %eax
f0104676:	68 00 65 10 f0       	push   $0xf0106500
f010467b:	6a 4a                	push   $0x4a
f010467d:	68 b9 7b 10 f0       	push   $0xf0107bb9
f0104682:	e8 f4 b9 ff ff       	call   f010007b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104687:	05 00 00 00 10       	add    $0x10000000,%eax
f010468c:	0f 22 d8             	mov    %eax,%cr3
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010468f:	e8 da 16 00 00       	call   f0105d6e <cpunum>
f0104694:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010469b:	29 c2                	sub    %eax,%edx
f010469d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01046a0:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01046a7:	b8 02 00 00 00       	mov    $0x2,%eax
f01046ac:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01046b0:	83 ec 0c             	sub    $0xc,%esp
f01046b3:	68 a0 43 12 f0       	push   $0xf01243a0
f01046b8:	e8 66 19 00 00       	call   f0106023 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01046bd:	f3 90                	pause  

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01046bf:	e8 aa 16 00 00       	call   f0105d6e <cpunum>
f01046c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01046cb:	29 c2                	sub    %eax,%edx
f01046cd:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01046d0:	8b 04 95 30 00 1f f0 	mov    -0xfe0ffd0(,%edx,4),%eax
f01046d7:	bd 00 00 00 00       	mov    $0x0,%ebp
f01046dc:	89 c4                	mov    %eax,%esp
f01046de:	6a 00                	push   $0x0
f01046e0:	6a 00                	push   $0x0
f01046e2:	fb                   	sti    
f01046e3:	f4                   	hlt    
f01046e4:	eb fd                	jmp    f01046e3 <sched_halt+0xdb>
f01046e6:	83 c4 10             	add    $0x10,%esp
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01046e9:	c9                   	leave  
f01046ea:	c3                   	ret    

f01046eb <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01046eb:	55                   	push   %ebp
f01046ec:	89 e5                	mov    %esp,%ebp
f01046ee:	56                   	push   %esi
f01046ef:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
       int cur = 0;
       if(curenv)cur = ENVX(curenv->env_id);       
f01046f0:	e8 79 16 00 00       	call   f0105d6e <cpunum>
f01046f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01046fc:	29 c2                	sub    %eax,%edx
f01046fe:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104701:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f0104708:	00 
f0104709:	75 07                	jne    f0104712 <sched_yield+0x27>
f010470b:	be 00 00 00 00       	mov    $0x0,%esi
f0104710:	eb 21                	jmp    f0104733 <sched_yield+0x48>
f0104712:	e8 57 16 00 00       	call   f0105d6e <cpunum>
f0104717:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010471e:	29 c2                	sub    %eax,%edx
f0104720:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104723:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f010472a:	8b 70 48             	mov    0x48(%eax),%esi
f010472d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
       for (int i = 1; i <= NENV; i++) {                
               int j = (cur + i) % NENV;
               if (envs[j].env_status == ENV_RUNNABLE) {
f0104733:	8b 1d 38 f2 1e f0    	mov    0xf01ef238,%ebx
f0104739:	b9 01 00 00 00       	mov    $0x1,%ecx
f010473e:	8d 04 31             	lea    (%ecx,%esi,1),%eax
f0104741:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104746:	79 07                	jns    f010474f <sched_yield+0x64>
f0104748:	48                   	dec    %eax
f0104749:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f010474e:	40                   	inc    %eax
f010474f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104756:	c1 e0 07             	shl    $0x7,%eax
f0104759:	29 d0                	sub    %edx,%eax
f010475b:	01 d8                	add    %ebx,%eax
f010475d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104761:	75 09                	jne    f010476c <sched_yield+0x81>
                       env_run(&envs[j]);
f0104763:	83 ec 0c             	sub    $0xc,%esp
f0104766:	50                   	push   %eax
f0104767:	e8 cc e9 ff ff       	call   f0103138 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
       int cur = 0;
       if(curenv)cur = ENVX(curenv->env_id);       
       for (int i = 1; i <= NENV; i++) {                
f010476c:	41                   	inc    %ecx
f010476d:	81 f9 01 04 00 00    	cmp    $0x401,%ecx
f0104773:	75 c9                	jne    f010473e <sched_yield+0x53>
               if (envs[j].env_status == ENV_RUNNABLE) {
                       env_run(&envs[j]);
                       break;
               }
       }
       if (curenv && curenv->env_status == ENV_RUNNING) {
f0104775:	e8 f4 15 00 00       	call   f0105d6e <cpunum>
f010477a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104781:	29 c2                	sub    %eax,%edx
f0104783:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104786:	83 3c 95 28 00 1f f0 	cmpl   $0x0,-0xfe0ffd8(,%edx,4)
f010478d:	00 
f010478e:	74 3e                	je     f01047ce <sched_yield+0xe3>
f0104790:	e8 d9 15 00 00       	call   f0105d6e <cpunum>
f0104795:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010479c:	29 c2                	sub    %eax,%edx
f010479e:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01047a1:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01047a8:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047ac:	75 20                	jne    f01047ce <sched_yield+0xe3>
               env_run(curenv);
f01047ae:	e8 bb 15 00 00       	call   f0105d6e <cpunum>
f01047b3:	83 ec 0c             	sub    $0xc,%esp
f01047b6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047bd:	29 c2                	sub    %eax,%edx
f01047bf:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01047c2:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f01047c9:	e8 6a e9 ff ff       	call   f0103138 <env_run>
       }

	// sched_halt never returns
	sched_halt();
f01047ce:	e8 35 fe ff ff       	call   f0104608 <sched_halt>
}
f01047d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01047d6:	5b                   	pop    %ebx
f01047d7:	5e                   	pop    %esi
f01047d8:	c9                   	leave  
f01047d9:	c3                   	ret    
	...

f01047dc <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f01047dc:	55                   	push   %ebp
f01047dd:	89 e5                	mov    %esp,%ebp
f01047df:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01047e2:	e8 04 ff ff ff       	call   f01046eb <sched_yield>

f01047e7 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01047e7:	55                   	push   %ebp
f01047e8:	89 e5                	mov    %esp,%ebp
f01047ea:	57                   	push   %edi
f01047eb:	56                   	push   %esi
f01047ec:	53                   	push   %ebx
f01047ed:	83 ec 1c             	sub    $0x1c,%esp
f01047f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01047f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01047f6:	8b 7d 14             	mov    0x14(%ebp),%edi
f01047f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret;
	switch (syscallno) {    //根据系统调用号调用相应函数
f01047fc:	83 f8 0d             	cmp    $0xd,%eax
f01047ff:	77 07                	ja     f0104808 <syscall+0x21>
f0104801:	ff 24 85 cc 7b 10 f0 	jmp    *-0xfef8434(,%eax,4)
f0104808:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010480d:	e9 2d 05 00 00       	jmp    f0104d3f <syscall+0x558>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104812:	e8 57 15 00 00       	call   f0105d6e <cpunum>
f0104817:	6a 00                	push   $0x0
f0104819:	ff 75 10             	pushl  0x10(%ebp)
f010481c:	53                   	push   %ebx
f010481d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104824:	29 c2                	sub    %eax,%edx
f0104826:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104829:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f0104830:	e8 99 c6 ff ff       	call   f0100ece <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104835:	83 c4 0c             	add    $0xc,%esp
f0104838:	53                   	push   %ebx
f0104839:	ff 75 10             	pushl  0x10(%ebp)
f010483c:	68 c6 7b 10 f0       	push   $0xf0107bc6
f0104841:	e8 c0 ee ff ff       	call   f0103706 <cprintf>
f0104846:	bb 00 00 00 00       	mov    $0x0,%ebx
	int32_t ret;
	switch (syscallno) {    //根据系统调用号调用相应函数
		case SYS_cputs:
			sys_cputs((char *)a1, (size_t)a2);
			ret = 0;
			break;
f010484b:	83 c4 10             	add    $0x10,%esp
f010484e:	e9 ec 04 00 00       	jmp    f0104d3f <syscall+0x558>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104853:	e8 cb ba ff ff       	call   f0100323 <cons_getc>
f0104858:	89 c3                	mov    %eax,%ebx
f010485a:	e9 e0 04 00 00       	jmp    f0104d3f <syscall+0x558>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010485f:	e8 0a 15 00 00       	call   f0105d6e <cpunum>
f0104864:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010486b:	29 c2                	sub    %eax,%edx
f010486d:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104870:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104877:	8b 58 48             	mov    0x48(%eax),%ebx
f010487a:	e9 c0 04 00 00       	jmp    f0104d3f <syscall+0x558>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010487f:	83 ec 04             	sub    $0x4,%esp
f0104882:	6a 01                	push   $0x1
f0104884:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104887:	50                   	push   %eax
f0104888:	53                   	push   %ebx
f0104889:	e8 a6 e5 ff ff       	call   f0102e34 <envid2env>
f010488e:	89 c3                	mov    %eax,%ebx
f0104890:	83 c4 10             	add    $0x10,%esp
f0104893:	85 c0                	test   %eax,%eax
f0104895:	0f 88 a4 04 00 00    	js     f0104d3f <syscall+0x558>
		return r;
	env_destroy(e);
f010489b:	83 ec 0c             	sub    $0xc,%esp
f010489e:	ff 75 f0             	pushl  -0x10(%ebp)
f01048a1:	e8 72 eb ff ff       	call   f0103418 <env_destroy>
f01048a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048ab:	83 c4 10             	add    $0x10,%esp
f01048ae:	e9 8c 04 00 00       	jmp    f0104d3f <syscall+0x558>
		case SYS_env_destroy:
			ret = sys_env_destroy((envid_t)a1);
			break;
		case SYS_yield:
			ret = 0;
			sys_yield();
f01048b3:	e8 24 ff ff ff       	call   f01047dc <sys_yield>
f01048b8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048bd:	e9 7d 04 00 00       	jmp    f0104d3f <syscall+0x558>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
        struct Env *e;
        int ret = env_alloc(&e, curenv->env_id);
f01048c2:	e8 a7 14 00 00       	call   f0105d6e <cpunum>
f01048c7:	83 ec 08             	sub    $0x8,%esp
f01048ca:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048d1:	29 c2                	sub    %eax,%edx
f01048d3:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01048d6:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f01048dd:	ff 70 48             	pushl  0x48(%eax)
f01048e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01048e3:	50                   	push   %eax
f01048e4:	e8 5a e6 ff ff       	call   f0102f43 <env_alloc>
f01048e9:	89 c3                	mov    %eax,%ebx
        if (ret < 0){//0: success, <0: fail
f01048eb:	83 c4 10             	add    $0x10,%esp
f01048ee:	85 c0                	test   %eax,%eax
f01048f0:	0f 88 49 04 00 00    	js     f0104d3f <syscall+0x558>
                return ret;
        }
        e->env_tf = curenv->env_tf;                     
f01048f6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01048f9:	e8 70 14 00 00       	call   f0105d6e <cpunum>
f01048fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104905:	29 c2                	sub    %eax,%edx
f0104907:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010490a:	83 ec 04             	sub    $0x4,%esp
f010490d:	6a 44                	push   $0x44
f010490f:	ff 34 95 28 00 1f f0 	pushl  -0xfe0ffd8(,%edx,4)
f0104916:	53                   	push   %ebx
f0104917:	e8 e6 0e 00 00       	call   f0105802 <memcpy>
        e->env_status = ENV_NOT_RUNNABLE;
f010491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010491f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        e->env_tf.tf_regs.reg_eax = 0;          
f0104926:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104929:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return e->env_id;
f0104930:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104933:	8b 58 48             	mov    0x48(%eax),%ebx
f0104936:	83 c4 10             	add    $0x10,%esp
f0104939:	e9 01 04 00 00       	jmp    f0104d3f <syscall+0x558>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f010493e:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104942:	74 0a                	je     f010494e <syscall+0x167>
f0104944:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104948:	0f 85 de 03 00 00    	jne    f0104d2c <syscall+0x545>
        struct Env *e;
        int ret = envid2env(envid, &e, 1);
f010494e:	83 ec 04             	sub    $0x4,%esp
f0104951:	6a 01                	push   $0x1
f0104953:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104956:	50                   	push   %eax
f0104957:	53                   	push   %ebx
f0104958:	e8 d7 e4 ff ff       	call   f0102e34 <envid2env>
f010495d:	89 c3                	mov    %eax,%ebx
        if (ret < 0) {
f010495f:	83 c4 10             	add    $0x10,%esp
f0104962:	85 c0                	test   %eax,%eax
f0104964:	0f 88 d5 03 00 00    	js     f0104d3f <syscall+0x558>
                return ret;
        }
        e->env_status = status;
f010496a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010496d:	8b 55 10             	mov    0x10(%ebp),%edx
f0104970:	89 50 54             	mov    %edx,0x54(%eax)
f0104973:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104978:	e9 c2 03 00 00       	jmp    f0104d3f <syscall+0x558>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;                                                                  
        int ret = envid2env(envid, &e, 1);
f010497d:	83 ec 04             	sub    $0x4,%esp
f0104980:	6a 01                	push   $0x1
f0104982:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104985:	50                   	push   %eax
f0104986:	53                   	push   %ebx
f0104987:	e8 a8 e4 ff ff       	call   f0102e34 <envid2env>
f010498c:	89 c3                	mov    %eax,%ebx
        if (ret) return ret;    //bad_env
f010498e:	83 c4 10             	add    $0x10,%esp
f0104991:	85 c0                	test   %eax,%eax
f0104993:	0f 85 a6 03 00 00    	jne    f0104d3f <syscall+0x558>
 
        if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;              
f0104999:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049a0:	0f 87 86 03 00 00    	ja     f0104d2c <syscall+0x545>
f01049a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01049a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01049ae:	39 45 10             	cmp    %eax,0x10(%ebp)
f01049b1:	0f 85 75 03 00 00    	jne    f0104d2c <syscall+0x545>
        int flag = PTE_U | PTE_P;
        if ((perm & flag) != flag) return -E_INVAL;
f01049b7:	89 f8                	mov    %edi,%eax
f01049b9:	83 e0 05             	and    $0x5,%eax
f01049bc:	83 f8 05             	cmp    $0x5,%eax
f01049bf:	0f 85 67 03 00 00    	jne    f0104d2c <syscall+0x545>
 
        struct PageInfo *pg = page_alloc(1);                    
f01049c5:	83 ec 0c             	sub    $0xc,%esp
f01049c8:	6a 01                	push   $0x1
f01049ca:	e8 68 c3 ff ff       	call   f0100d37 <page_alloc>
f01049cf:	89 c6                	mov    %eax,%esi
        if (!pg) return -E_NO_MEM;
f01049d1:	83 c4 10             	add    $0x10,%esp
f01049d4:	85 c0                	test   %eax,%eax
f01049d6:	0f 84 5e 03 00 00    	je     f0104d3a <syscall+0x553>
        ret = page_insert(e->env_pgdir, pg, va, perm);  
f01049dc:	57                   	push   %edi
f01049dd:	ff 75 10             	pushl  0x10(%ebp)
f01049e0:	50                   	push   %eax
f01049e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049e4:	ff 70 60             	pushl  0x60(%eax)
f01049e7:	e8 d2 c5 ff ff       	call   f0100fbe <page_insert>
f01049ec:	89 c3                	mov    %eax,%ebx
        if (ret) {
f01049ee:	83 c4 10             	add    $0x10,%esp
f01049f1:	85 c0                	test   %eax,%eax
f01049f3:	0f 84 46 03 00 00    	je     f0104d3f <syscall+0x558>
                page_free(pg);
f01049f9:	83 ec 0c             	sub    $0xc,%esp
f01049fc:	56                   	push   %esi
f01049fd:	e8 8d c1 ff ff       	call   f0100b8f <page_free>
f0104a02:	83 c4 10             	add    $0x10,%esp
f0104a05:	e9 35 03 00 00       	jmp    f0104d3f <syscall+0x558>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *se, *de;
        int ret = envid2env(srcenvid, &se, 1);
f0104a0a:	83 ec 04             	sub    $0x4,%esp
f0104a0d:	6a 01                	push   $0x1
f0104a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104a12:	50                   	push   %eax
f0104a13:	53                   	push   %ebx
f0104a14:	e8 1b e4 ff ff       	call   f0102e34 <envid2env>
f0104a19:	89 c3                	mov    %eax,%ebx
        if (ret) return ret;    //bad_env
f0104a1b:	83 c4 10             	add    $0x10,%esp
f0104a1e:	85 c0                	test   %eax,%eax
f0104a20:	0f 85 19 03 00 00    	jne    f0104d3f <syscall+0x558>
        ret = envid2env(dstenvid, &de, 1);
f0104a26:	83 ec 04             	sub    $0x4,%esp
f0104a29:	6a 01                	push   $0x1
f0104a2b:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104a2e:	50                   	push   %eax
f0104a2f:	57                   	push   %edi
f0104a30:	e8 ff e3 ff ff       	call   f0102e34 <envid2env>
f0104a35:	89 c3                	mov    %eax,%ebx
        if (ret) return ret;    //bad_env
f0104a37:	83 c4 10             	add    $0x10,%esp
f0104a3a:	85 c0                	test   %eax,%eax
f0104a3c:	0f 85 fd 02 00 00    	jne    f0104d3f <syscall+0x558>
 
        //      -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
        //              or dstva >= UTOP or dstva is not page-aligned.
        if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f0104a42:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a49:	0f 87 dd 02 00 00    	ja     f0104d2c <syscall+0x545>
			break;
		case SYS_page_alloc:
			ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
            		break;
		case SYS_page_map:
			ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104a4f:	89 f3                	mov    %esi,%ebx
        ret = envid2env(dstenvid, &de, 1);
        if (ret) return ret;    //bad_env
 
        //      -E_INVAL if srcva >= UTOP or srcva is not page-aligned,
        //              or dstva >= UTOP or dstva is not page-aligned.
        if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f0104a51:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104a57:	0f 87 cf 02 00 00    	ja     f0104d2c <syscall+0x545>
                ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f0104a5d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a65:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104a68:	0f 85 be 02 00 00    	jne    f0104d2c <syscall+0x545>
f0104a6e:	89 f0                	mov    %esi,%eax
f0104a70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a75:	39 c6                	cmp    %eax,%esi
f0104a77:	0f 85 af 02 00 00    	jne    f0104d2c <syscall+0x545>
                return -E_INVAL;
 
        //      -E_INVAL is srcva is not mapped in srcenvid's address space.
        pte_t *pte;
        struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f0104a7d:	83 ec 04             	sub    $0x4,%esp
f0104a80:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104a83:	50                   	push   %eax
f0104a84:	ff 75 10             	pushl  0x10(%ebp)
f0104a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a8a:	ff 70 60             	pushl  0x60(%eax)
f0104a8d:	e8 86 c4 ff ff       	call   f0100f18 <page_lookup>
f0104a92:	89 c1                	mov    %eax,%ecx
        if (!pg) return -E_INVAL;
f0104a94:	83 c4 10             	add    $0x10,%esp
f0104a97:	85 c0                	test   %eax,%eax
f0104a99:	0f 84 8d 02 00 00    	je     f0104d2c <syscall+0x545>
			break;
		case SYS_page_alloc:
			ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
            		break;
		case SYS_page_map:
			ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104a9f:	8b 55 1c             	mov    0x1c(%ebp),%edx
        struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
        if (!pg) return -E_INVAL;
 
        //      -E_INVAL if perm is inappropriate (see sys_page_alloc).
        int flag = PTE_U|PTE_P;
        if ((perm & flag) != flag) return -E_INVAL;
f0104aa2:	89 d0                	mov    %edx,%eax
f0104aa4:	83 e0 05             	and    $0x5,%eax
f0104aa7:	83 f8 05             	cmp    $0x5,%eax
f0104aaa:	0f 85 7c 02 00 00    	jne    f0104d2c <syscall+0x545>
 
        //      -E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
        //              address space.
        if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104ab0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ab3:	f6 00 02             	testb  $0x2,(%eax)
f0104ab6:	75 09                	jne    f0104ac1 <syscall+0x2da>
f0104ab8:	f6 c2 02             	test   $0x2,%dl
f0104abb:	0f 85 6b 02 00 00    	jne    f0104d2c <syscall+0x545>
 
        //      -E_NO_MEM if there's no memory to allocate any necessary page tables.
        ret = page_insert(de->env_pgdir, pg, dstva, perm);
f0104ac1:	52                   	push   %edx
f0104ac2:	53                   	push   %ebx
f0104ac3:	51                   	push   %ecx
f0104ac4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104ac7:	ff 70 60             	pushl  0x60(%eax)
f0104aca:	e8 ef c4 ff ff       	call   f0100fbe <page_insert>
f0104acf:	89 c3                	mov    %eax,%ebx
f0104ad1:	83 c4 10             	add    $0x10,%esp
f0104ad4:	e9 66 02 00 00       	jmp    f0104d3f <syscall+0x558>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *env;
        int ret = envid2env(envid, &env, 1);
f0104ad9:	83 ec 04             	sub    $0x4,%esp
f0104adc:	6a 01                	push   $0x1
f0104ade:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ae1:	50                   	push   %eax
f0104ae2:	53                   	push   %ebx
f0104ae3:	e8 4c e3 ff ff       	call   f0102e34 <envid2env>
f0104ae8:	89 c3                	mov    %eax,%ebx
        if (ret) return ret;
f0104aea:	83 c4 10             	add    $0x10,%esp
f0104aed:	85 c0                	test   %eax,%eax
f0104aef:	0f 85 4a 02 00 00    	jne    f0104d3f <syscall+0x558>
 
        if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;
f0104af5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104afc:	0f 87 2a 02 00 00    	ja     f0104d2c <syscall+0x545>
f0104b02:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104b0a:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104b0d:	0f 85 19 02 00 00    	jne    f0104d2c <syscall+0x545>
        page_remove(env->env_pgdir, va);
f0104b13:	83 ec 08             	sub    $0x8,%esp
f0104b16:	ff 75 10             	pushl  0x10(%ebp)
f0104b19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b1c:	ff 70 60             	pushl  0x60(%eax)
f0104b1f:	e8 54 c4 ff ff       	call   f0100f78 <page_remove>
f0104b24:	83 c4 10             	add    $0x10,%esp
f0104b27:	e9 13 02 00 00       	jmp    f0104d3f <syscall+0x558>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	//envid to env: also perm check
	if(envid2env(envid,&e,1) < 0)return -E_BAD_ENV;
f0104b2c:	83 ec 04             	sub    $0x4,%esp
f0104b2f:	6a 01                	push   $0x1
f0104b31:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b34:	50                   	push   %eax
f0104b35:	53                   	push   %ebx
f0104b36:	e8 f9 e2 ff ff       	call   f0102e34 <envid2env>
f0104b3b:	83 c4 10             	add    $0x10,%esp
f0104b3e:	85 c0                	test   %eax,%eax
f0104b40:	0f 88 ed 01 00 00    	js     f0104d33 <syscall+0x54c>
	e->env_pgfault_upcall = func;
f0104b46:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b49:	8b 55 10             	mov    0x10(%ebp),%edx
f0104b4c:	89 50 64             	mov    %edx,0x64(%eax)
f0104b4f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b54:	e9 e6 01 00 00       	jmp    f0104d3f <syscall+0x558>
		int r;
  	struct Env * dstenv;
  	pte_t * pte;
  	struct PageInfo *pp;
  	//err begin:
  	r = envid2env(envid, &dstenv, 0);
f0104b59:	83 ec 04             	sub    $0x4,%esp
f0104b5c:	6a 00                	push   $0x0
f0104b5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b61:	50                   	push   %eax
f0104b62:	53                   	push   %ebx
f0104b63:	e8 cc e2 ff ff       	call   f0102e34 <envid2env>
  	if (r < 0) return -E_BAD_ENV;		//1.env not exit
f0104b68:	83 c4 10             	add    $0x10,%esp
f0104b6b:	85 c0                	test   %eax,%eax
f0104b6d:	0f 88 c0 01 00 00    	js     f0104d33 <syscall+0x54c>
 	if (!dstenv->env_ipc_recving)return -E_IPC_NOT_RECV;		//2.target env not blocked:
f0104b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b76:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104b7a:	75 0a                	jne    f0104b86 <syscall+0x39f>
f0104b7c:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b81:	e9 b9 01 00 00       	jmp    f0104d3f <syscall+0x558>

  		//if srcva < UTOP,what err will exit?
  	if ((uint32_t)srcva < UTOP) {
f0104b86:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104b8c:	0f 87 84 00 00 00    	ja     f0104c16 <syscall+0x42f>
  		pp = page_lookup(curenv->env_pgdir, srcva, &pte);//find pp and pte
f0104b92:	e8 d7 11 00 00       	call   f0105d6e <cpunum>
f0104b97:	83 ec 04             	sub    $0x4,%esp
f0104b9a:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0104b9d:	52                   	push   %edx
f0104b9e:	57                   	push   %edi
f0104b9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ba6:	29 c2                	sub    %eax,%edx
f0104ba8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104bab:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104bb2:	ff 70 60             	pushl  0x60(%eax)
f0104bb5:	e8 5e c3 ff ff       	call   f0100f18 <page_lookup>
f0104bba:	89 c2                	mov    %eax,%edx
  		
    		if ((uint32_t)srcva & 0xfff)return  -E_INVAL;		//3.not page-aligned
f0104bbc:	83 c4 10             	add    $0x10,%esp
f0104bbf:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104bc5:	0f 85 61 01 00 00    	jne    f0104d2c <syscall+0x545>
    		int flag = PTE_U | PTE_P;
    		if (flag != (flag & perm)) return -E_INVAL;		//4.perm not appropriate
f0104bcb:	89 f0                	mov    %esi,%eax
f0104bcd:	83 e0 05             	and    $0x5,%eax
f0104bd0:	83 f8 05             	cmp    $0x5,%eax
f0104bd3:	0f 85 53 01 00 00    	jne    f0104d2c <syscall+0x545>

    		if (!pp) return -E_INVAL;		//5.srcva not mapped the same ppage
f0104bd9:	85 d2                	test   %edx,%edx
f0104bdb:	0f 84 4b 01 00 00    	je     f0104d2c <syscall+0x545>

    		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;		//6.srcva read-only
f0104be1:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0104be7:	74 0c                	je     f0104bf5 <syscall+0x40e>
f0104be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104bec:	f6 00 02             	testb  $0x2,(%eax)
f0104bef:	0f 84 37 01 00 00    	je     f0104d2c <syscall+0x545>

    		//if ((uint32_t)dstenv->env_ipc_dstva < UTOP) {
      			r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva, perm);
f0104bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104bf8:	56                   	push   %esi
f0104bf9:	ff 70 6c             	pushl  0x6c(%eax)
f0104bfc:	52                   	push   %edx
f0104bfd:	ff 70 60             	pushl  0x60(%eax)
f0104c00:	e8 b9 c3 ff ff       	call   f0100fbe <page_insert>
      			if (r < 0) return -E_NO_MEM;		//7.not enough memory for new page table
f0104c05:	83 c4 10             	add    $0x10,%esp
f0104c08:	85 c0                	test   %eax,%eax
f0104c0a:	0f 88 2a 01 00 00    	js     f0104d3a <syscall+0x553>

      			dstenv->env_ipc_perm = perm;
f0104c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c13:	89 70 78             	mov    %esi,0x78(%eax)
    		//}	
  	}

  	//succeed: update
  	dstenv->env_ipc_recving = 0;
f0104c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c19:	c6 40 68 00          	movb   $0x0,0x68(%eax)
  	dstenv->env_ipc_value = value;
f0104c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c20:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c23:	89 50 70             	mov    %edx,0x70(%eax)
  	dstenv->env_ipc_from = curenv->env_id;
f0104c26:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0104c29:	e8 40 11 00 00       	call   f0105d6e <cpunum>
f0104c2e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c35:	29 c2                	sub    %eax,%edx
f0104c37:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104c3a:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104c41:	8b 40 48             	mov    0x48(%eax),%eax
f0104c44:	89 43 74             	mov    %eax,0x74(%ebx)
  	dstenv->env_status = ENV_RUNNABLE;
f0104c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c4a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104c51:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c54:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c60:	e9 da 00 00 00       	jmp    f0104d3f <syscall+0x558>
			break;
		case SYS_ipc_try_send:
			ret = sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
			break;
		case SYS_ipc_recv:
			ret = sys_ipc_recv((void *)a1);
f0104c65:	89 de                	mov    %ebx,%esi
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *)UTOP && dstva != ROUNDDOWN(dstva, PGSIZE)) {
f0104c67:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104c6d:	77 0f                	ja     f0104c7e <syscall+0x497>
f0104c6f:	89 d8                	mov    %ebx,%eax
f0104c71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104c76:	39 c3                	cmp    %eax,%ebx
f0104c78:	0f 85 ae 00 00 00    	jne    f0104d2c <syscall+0x545>
		return -E_INVAL;
	}
	curenv->env_ipc_recving = 1;
f0104c7e:	e8 eb 10 00 00       	call   f0105d6e <cpunum>
f0104c83:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c8a:	29 c2                	sub    %eax,%edx
f0104c8c:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104c8f:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104c96:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104c9a:	e8 cf 10 00 00       	call   f0105d6e <cpunum>
f0104c9f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ca6:	29 c2                	sub    %eax,%edx
f0104ca8:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104cab:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104cb2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104cb9:	e8 b0 10 00 00       	call   f0105d6e <cpunum>
f0104cbe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cc5:	29 c2                	sub    %eax,%edx
f0104cc7:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104cca:	8b 04 95 28 00 1f f0 	mov    -0xfe0ffd8(,%edx,4),%eax
f0104cd1:	89 70 6c             	mov    %esi,0x6c(%eax)
	sys_yield();
f0104cd4:	e8 03 fb ff ff       	call   f01047dc <sys_yield>
f0104cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104cde:	eb 5f                	jmp    f0104d3f <syscall+0x558>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *e;
	if(envid2env(envid, &e, 1) < 0)return -E_BAD_ENV;
f0104ce0:	83 ec 04             	sub    $0x4,%esp
f0104ce3:	6a 01                	push   $0x1
f0104ce5:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0104ce8:	50                   	push   %eax
f0104ce9:	53                   	push   %ebx
f0104cea:	e8 45 e1 ff ff       	call   f0102e34 <envid2env>
f0104cef:	83 c4 10             	add    $0x10,%esp
f0104cf2:	85 c0                	test   %eax,%eax
f0104cf4:	78 3d                	js     f0104d33 <syscall+0x54c>
	e->env_tf = *tf;
f0104cf6:	83 ec 04             	sub    $0x4,%esp
f0104cf9:	6a 44                	push   $0x44
f0104cfb:	ff 75 10             	pushl  0x10(%ebp)
f0104cfe:	ff 75 e8             	pushl  -0x18(%ebp)
f0104d01:	e8 fc 0a 00 00       	call   f0105802 <memcpy>
	e->env_tf.tf_eflags |= FL_IF;
f0104d06:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104d09:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	e->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0104d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104d13:	81 60 38 ff cf ff ff 	andl   $0xffffcfff,0x38(%eax)
	e->env_tf.tf_cs |= 3;
f0104d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104d1d:	66 83 48 34 03       	orw    $0x3,0x34(%eax)
f0104d22:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d27:	83 c4 10             	add    $0x10,%esp
f0104d2a:	eb 13                	jmp    f0104d3f <syscall+0x558>
f0104d2c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d31:	eb 0c                	jmp    f0104d3f <syscall+0x558>
f0104d33:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104d38:	eb 05                	jmp    f0104d3f <syscall+0x558>
f0104d3a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		default:
			return -E_INVAL;
	}

	return ret;
}
f0104d3f:	89 d8                	mov    %ebx,%eax
f0104d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d44:	5b                   	pop    %ebx
f0104d45:	5e                   	pop    %esi
f0104d46:	5f                   	pop    %edi
f0104d47:	c9                   	leave  
f0104d48:	c3                   	ret    
f0104d49:	00 00                	add    %al,(%eax)
	...

f0104d4c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104d4c:	55                   	push   %ebp
f0104d4d:	89 e5                	mov    %esp,%ebp
f0104d4f:	57                   	push   %edi
f0104d50:	56                   	push   %esi
f0104d51:	53                   	push   %ebx
f0104d52:	83 ec 14             	sub    $0x14,%esp
f0104d55:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104d58:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104d5b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int l = *region_left, r = *region_right, any_matches = 0;
f0104d5e:	8b 32                	mov    (%edx),%esi
f0104d60:	8b 01                	mov    (%ecx),%eax
f0104d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104d65:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104d6c:	e9 80 00 00 00       	jmp    f0104df1 <stab_binsearch+0xa5>

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104d71:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104d74:	8d 04 16             	lea    (%esi,%edx,1),%eax
f0104d77:	89 c2                	mov    %eax,%edx
f0104d79:	c1 ea 1f             	shr    $0x1f,%edx
f0104d7c:	01 c2                	add    %eax,%edx
f0104d7e:	89 d7                	mov    %edx,%edi
f0104d80:	d1 ff                	sar    %edi
f0104d82:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104d85:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104d88:	8d 0c 83             	lea    (%ebx,%eax,4),%ecx
f0104d8b:	89 fa                	mov    %edi,%edx
f0104d8d:	eb 01                	jmp    f0104d90 <stab_binsearch+0x44>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104d8f:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104d90:	39 d6                	cmp    %edx,%esi
f0104d92:	7f 0e                	jg     f0104da2 <stab_binsearch+0x56>
f0104d94:	0f b6 41 04          	movzbl 0x4(%ecx),%eax
f0104d98:	83 e9 0c             	sub    $0xc,%ecx
f0104d9b:	39 45 08             	cmp    %eax,0x8(%ebp)
f0104d9e:	75 ef                	jne    f0104d8f <stab_binsearch+0x43>
f0104da0:	eb 05                	jmp    f0104da7 <stab_binsearch+0x5b>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104da2:	8d 77 01             	lea    0x1(%edi),%esi
f0104da5:	eb 4a                	jmp    f0104df1 <stab_binsearch+0xa5>
			continue;
f0104da7:	89 d1                	mov    %edx,%ecx
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104da9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104dac:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104daf:	8b 44 83 08          	mov    0x8(%ebx,%eax,4),%eax
f0104db3:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0104db6:	76 11                	jbe    f0104dc9 <stab_binsearch+0x7d>
			*region_left = m;
f0104db8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104dbb:	89 16                	mov    %edx,(%esi)
			l = true_m + 1;
f0104dbd:	8d 77 01             	lea    0x1(%edi),%esi
f0104dc0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0104dc7:	eb 28                	jmp    f0104df1 <stab_binsearch+0xa5>
		} else if (stabs[m].n_value > addr) {
f0104dc9:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0104dcc:	73 12                	jae    f0104de0 <stab_binsearch+0x94>
			*region_right = m - 1;
f0104dce:	49                   	dec    %ecx
f0104dcf:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f0104dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dd5:	89 08                	mov    %ecx,(%eax)
f0104dd7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
f0104dde:	eb 11                	jmp    f0104df1 <stab_binsearch+0xa5>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104de0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104de3:	89 13                	mov    %edx,(%ebx)
			l = m;
			addr++;
f0104de5:	ff 45 0c             	incl   0xc(%ebp)
f0104de8:	89 d6                	mov    %edx,%esi
f0104dea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104df1:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0104df4:	0f 8e 77 ff ff ff    	jle    f0104d71 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104dfa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104dfe:	75 0d                	jne    f0104e0d <stab_binsearch+0xc1>
		*region_right = *region_left - 1;
f0104e00:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e03:	8b 06                	mov    (%esi),%eax
f0104e05:	48                   	dec    %eax
f0104e06:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104e09:	89 02                	mov    %eax,(%edx)
f0104e0b:	eb 2b                	jmp    f0104e38 <stab_binsearch+0xec>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104e0d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e10:	8b 0b                	mov    (%ebx),%ecx
		     l > *region_left && stabs[l].n_type != type;
f0104e12:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104e15:	8b 1e                	mov    (%esi),%ebx
f0104e17:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0104e1a:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0104e1d:	8d 14 86             	lea    (%esi,%eax,4),%edx
f0104e20:	eb 01                	jmp    f0104e23 <stab_binsearch+0xd7>
		     l--)
f0104e22:	49                   	dec    %ecx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0104e23:	39 d9                	cmp    %ebx,%ecx
f0104e25:	7e 0c                	jle    f0104e33 <stab_binsearch+0xe7>
f0104e27:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0104e2b:	83 ea 0c             	sub    $0xc,%edx
f0104e2e:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104e31:	75 ef                	jne    f0104e22 <stab_binsearch+0xd6>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104e33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e36:	89 08                	mov    %ecx,(%eax)
	}
}
f0104e38:	83 c4 14             	add    $0x14,%esp
f0104e3b:	5b                   	pop    %ebx
f0104e3c:	5e                   	pop    %esi
f0104e3d:	5f                   	pop    %edi
f0104e3e:	c9                   	leave  
f0104e3f:	c3                   	ret    

f0104e40 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104e40:	55                   	push   %ebp
f0104e41:	89 e5                	mov    %esp,%ebp
f0104e43:	57                   	push   %edi
f0104e44:	56                   	push   %esi
f0104e45:	53                   	push   %ebx
f0104e46:	83 ec 2c             	sub    $0x2c,%esp
f0104e49:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104e4f:	c7 03 04 7c 10 f0    	movl   $0xf0107c04,(%ebx)
	info->eip_line = 0;
f0104e55:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104e5c:	c7 43 08 04 7c 10 f0 	movl   $0xf0107c04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104e63:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104e6a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104e6d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104e74:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104e7a:	76 1a                	jbe    f0104e96 <debuginfo_eip+0x56>
f0104e7c:	c7 45 c8 b0 81 10 f0 	movl   $0xf01081b0,-0x38(%ebp)
f0104e83:	b8 90 28 11 f0       	mov    $0xf0112890,%eax
f0104e88:	c7 45 cc 91 28 11 f0 	movl   $0xf0112891,-0x34(%ebp)
f0104e8f:	bf c7 9d 11 f0       	mov    $0xf0119dc7,%edi
f0104e94:	eb 1c                	jmp    f0104eb2 <debuginfo_eip+0x72>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104e96:	a1 00 00 20 00       	mov    0x200000,%eax
f0104e9b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		stab_end = usd->stab_end;
f0104e9e:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104ea3:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104ea9:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104eac:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104eb2:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0104eb5:	0f 83 78 01 00 00    	jae    f0105033 <debuginfo_eip+0x1f3>
f0104ebb:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104ebf:	0f 85 6e 01 00 00    	jne    f0105033 <debuginfo_eip+0x1f3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104ec5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104ecc:	89 c2                	mov    %eax,%edx
f0104ece:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0104ed1:	c1 fa 02             	sar    $0x2,%edx
f0104ed4:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0104ed7:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104eda:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0104edd:	89 c1                	mov    %eax,%ecx
f0104edf:	c1 e1 08             	shl    $0x8,%ecx
f0104ee2:	01 c8                	add    %ecx,%eax
f0104ee4:	89 c1                	mov    %eax,%ecx
f0104ee6:	c1 e1 10             	shl    $0x10,%ecx
f0104ee9:	01 c8                	add    %ecx,%eax
f0104eeb:	8d 44 42 ff          	lea    -0x1(%edx,%eax,2),%eax
f0104eef:	89 45 ec             	mov    %eax,-0x14(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104ef2:	8d 4d ec             	lea    -0x14(%ebp),%ecx
f0104ef5:	8d 55 f0             	lea    -0x10(%ebp),%edx
f0104ef8:	56                   	push   %esi
f0104ef9:	6a 64                	push   $0x64
f0104efb:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104efe:	e8 49 fe ff ff       	call   f0104d4c <stab_binsearch>
	if (lfile == 0)
f0104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f06:	83 c4 08             	add    $0x8,%esp
f0104f09:	85 c0                	test   %eax,%eax
f0104f0b:	0f 84 22 01 00 00    	je     f0105033 <debuginfo_eip+0x1f3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104f11:	89 45 e8             	mov    %eax,-0x18(%ebp)
	rfun = rfile;
f0104f14:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104f1a:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
f0104f1d:	8d 55 e8             	lea    -0x18(%ebp),%edx
f0104f20:	56                   	push   %esi
f0104f21:	6a 24                	push   $0x24
f0104f23:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104f26:	e8 21 fe ff ff       	call   f0104d4c <stab_binsearch>

	if (lfun <= rfun) {
f0104f2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104f2e:	83 c4 08             	add    $0x8,%esp
f0104f31:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0104f34:	7f 37                	jg     f0104f6d <debuginfo_eip+0x12d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104f36:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104f39:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104f3c:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f0104f3f:	89 f8                	mov    %edi,%eax
f0104f41:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0104f44:	39 c2                	cmp    %eax,%edx
f0104f46:	73 08                	jae    f0104f50 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104f48:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104f4b:	01 d0                	add    %edx,%eax
f0104f4d:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104f50:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104f53:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104f56:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104f59:	8b 44 81 08          	mov    0x8(%ecx,%eax,4),%eax
f0104f5d:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104f60:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104f62:	89 55 e0             	mov    %edx,-0x20(%ebp)
		rline = rfun;
f0104f65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f68:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104f6b:	eb 0f                	jmp    f0104f7c <debuginfo_eip+0x13c>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104f6d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f73:	89 45 e0             	mov    %eax,-0x20(%ebp)
		rline = rfile;
f0104f76:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104f79:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104f7c:	83 ec 08             	sub    $0x8,%esp
f0104f7f:	6a 3a                	push   $0x3a
f0104f81:	ff 73 08             	pushl  0x8(%ebx)
f0104f84:	e8 a3 07 00 00       	call   f010572c <strfind>
f0104f89:	2b 43 08             	sub    0x8(%ebx),%eax
f0104f8c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);//代码行数
f0104f8f:	8d 4d dc             	lea    -0x24(%ebp),%ecx
f0104f92:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104f95:	56                   	push   %esi
f0104f96:	6a 44                	push   $0x44
f0104f98:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104f9b:	e8 ac fd ff ff       	call   f0104d4c <stab_binsearch>
	if (lline <= rline) {
f0104fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fa3:	83 c4 18             	add    $0x18,%esp
f0104fa6:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0104fa9:	0f 8f 84 00 00 00    	jg     f0105033 <debuginfo_eip+0x1f3>
    	info->eip_line = stabs[lline].n_desc;
f0104faf:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104fb2:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104fb5:	0f b7 44 82 06       	movzwl 0x6(%edx,%eax,4),%eax
f0104fba:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104fbd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104fc0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104fc3:	eb 06                	jmp    f0104fcb <debuginfo_eip+0x18b>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104fc5:	8d 41 ff             	lea    -0x1(%ecx),%eax
f0104fc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104fcb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fce:	3b 4d d0             	cmp    -0x30(%ebp),%ecx
f0104fd1:	7c 35                	jl     f0105008 <debuginfo_eip+0x1c8>
f0104fd3:	89 ca                	mov    %ecx,%edx
f0104fd5:	8d 34 49             	lea    (%ecx,%ecx,2),%esi
f0104fd8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104fdb:	8d 34 b0             	lea    (%eax,%esi,4),%esi
f0104fde:	8a 46 04             	mov    0x4(%esi),%al
f0104fe1:	3c 84                	cmp    $0x84,%al
f0104fe3:	74 0a                	je     f0104fef <debuginfo_eip+0x1af>
f0104fe5:	3c 64                	cmp    $0x64,%al
f0104fe7:	75 dc                	jne    f0104fc5 <debuginfo_eip+0x185>
f0104fe9:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0104fed:	74 d6                	je     f0104fc5 <debuginfo_eip+0x185>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104fef:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104ff2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104ff5:	8b 14 81             	mov    (%ecx,%eax,4),%edx
f0104ff8:	89 f8                	mov    %edi,%eax
f0104ffa:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0104ffd:	39 c2                	cmp    %eax,%edx
f0104fff:	73 07                	jae    f0105008 <debuginfo_eip+0x1c8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105001:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105004:	01 d0                	add    %edx,%eax
f0105006:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105008:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010500b:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f010500e:	7d 2a                	jge    f010503a <debuginfo_eip+0x1fa>
		for (lline = lfun + 1;
f0105010:	40                   	inc    %eax
f0105011:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105014:	eb 06                	jmp    f010501c <debuginfo_eip+0x1dc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105016:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105019:	ff 45 e0             	incl   -0x20(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010501c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010501f:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0105022:	7d 16                	jge    f010503a <debuginfo_eip+0x1fa>
f0105024:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105027:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010502a:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f010502f:	74 e5                	je     f0105016 <debuginfo_eip+0x1d6>
f0105031:	eb 07                	jmp    f010503a <debuginfo_eip+0x1fa>
f0105033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105038:	eb 05                	jmp    f010503f <debuginfo_eip+0x1ff>
f010503a:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f010503f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105042:	5b                   	pop    %ebx
f0105043:	5e                   	pop    %esi
f0105044:	5f                   	pop    %edi
f0105045:	c9                   	leave  
f0105046:	c3                   	ret    
	...

f0105048 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105048:	55                   	push   %ebp
f0105049:	89 e5                	mov    %esp,%ebp
f010504b:	57                   	push   %edi
f010504c:	56                   	push   %esi
f010504d:	53                   	push   %ebx
f010504e:	83 ec 1c             	sub    $0x1c,%esp
f0105051:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105054:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105057:	8b 45 08             	mov    0x8(%ebp),%eax
f010505a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010505d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105060:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105063:	8b 55 10             	mov    0x10(%ebp),%edx
f0105066:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105069:	89 d6                	mov    %edx,%esi
f010506b:	bf 00 00 00 00       	mov    $0x0,%edi
f0105070:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105073:	72 04                	jb     f0105079 <printnum+0x31>
f0105075:	39 c2                	cmp    %eax,%edx
f0105077:	77 3f                	ja     f01050b8 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105079:	83 ec 0c             	sub    $0xc,%esp
f010507c:	ff 75 18             	pushl  0x18(%ebp)
f010507f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105082:	50                   	push   %eax
f0105083:	52                   	push   %edx
f0105084:	83 ec 08             	sub    $0x8,%esp
f0105087:	57                   	push   %edi
f0105088:	56                   	push   %esi
f0105089:	ff 75 e4             	pushl  -0x1c(%ebp)
f010508c:	ff 75 e0             	pushl  -0x20(%ebp)
f010508f:	e8 14 11 00 00       	call   f01061a8 <__udivdi3>
f0105094:	83 c4 18             	add    $0x18,%esp
f0105097:	52                   	push   %edx
f0105098:	50                   	push   %eax
f0105099:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010509c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010509f:	e8 a4 ff ff ff       	call   f0105048 <printnum>
f01050a4:	83 c4 20             	add    $0x20,%esp
f01050a7:	eb 14                	jmp    f01050bd <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01050a9:	83 ec 08             	sub    $0x8,%esp
f01050ac:	ff 75 e8             	pushl  -0x18(%ebp)
f01050af:	ff 75 18             	pushl  0x18(%ebp)
f01050b2:	ff 55 ec             	call   *-0x14(%ebp)
f01050b5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01050b8:	4b                   	dec    %ebx
f01050b9:	85 db                	test   %ebx,%ebx
f01050bb:	7f ec                	jg     f01050a9 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01050bd:	83 ec 08             	sub    $0x8,%esp
f01050c0:	ff 75 e8             	pushl  -0x18(%ebp)
f01050c3:	83 ec 04             	sub    $0x4,%esp
f01050c6:	57                   	push   %edi
f01050c7:	56                   	push   %esi
f01050c8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050cb:	ff 75 e0             	pushl  -0x20(%ebp)
f01050ce:	e8 01 12 00 00       	call   f01062d4 <__umoddi3>
f01050d3:	83 c4 14             	add    $0x14,%esp
f01050d6:	0f be 80 0e 7c 10 f0 	movsbl -0xfef83f2(%eax),%eax
f01050dd:	50                   	push   %eax
f01050de:	ff 55 ec             	call   *-0x14(%ebp)
f01050e1:	83 c4 10             	add    $0x10,%esp
}
f01050e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050e7:	5b                   	pop    %ebx
f01050e8:	5e                   	pop    %esi
f01050e9:	5f                   	pop    %edi
f01050ea:	c9                   	leave  
f01050eb:	c3                   	ret    

f01050ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01050ec:	55                   	push   %ebp
f01050ed:	89 e5                	mov    %esp,%ebp
f01050ef:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
f01050f1:	83 fa 01             	cmp    $0x1,%edx
f01050f4:	7e 0e                	jle    f0105104 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
f01050f6:	8b 10                	mov    (%eax),%edx
f01050f8:	8d 42 08             	lea    0x8(%edx),%eax
f01050fb:	89 01                	mov    %eax,(%ecx)
f01050fd:	8b 02                	mov    (%edx),%eax
f01050ff:	8b 52 04             	mov    0x4(%edx),%edx
f0105102:	eb 22                	jmp    f0105126 <getuint+0x3a>
	else if (lflag)
f0105104:	85 d2                	test   %edx,%edx
f0105106:	74 10                	je     f0105118 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0105108:	8b 10                	mov    (%eax),%edx
f010510a:	8d 42 04             	lea    0x4(%edx),%eax
f010510d:	89 01                	mov    %eax,(%ecx)
f010510f:	8b 02                	mov    (%edx),%eax
f0105111:	ba 00 00 00 00       	mov    $0x0,%edx
f0105116:	eb 0e                	jmp    f0105126 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
f0105118:	8b 10                	mov    (%eax),%edx
f010511a:	8d 42 04             	lea    0x4(%edx),%eax
f010511d:	89 01                	mov    %eax,(%ecx)
f010511f:	8b 02                	mov    (%edx),%eax
f0105121:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105126:	c9                   	leave  
f0105127:	c3                   	ret    

f0105128 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105128:	55                   	push   %ebp
f0105129:	89 e5                	mov    %esp,%ebp
f010512b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
f010512e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
f0105131:	8b 11                	mov    (%ecx),%edx
f0105133:	3b 51 04             	cmp    0x4(%ecx),%edx
f0105136:	73 0a                	jae    f0105142 <sprintputch+0x1a>
		*b->buf++ = ch;
f0105138:	8b 45 08             	mov    0x8(%ebp),%eax
f010513b:	88 02                	mov    %al,(%edx)
f010513d:	8d 42 01             	lea    0x1(%edx),%eax
f0105140:	89 01                	mov    %eax,(%ecx)
}
f0105142:	c9                   	leave  
f0105143:	c3                   	ret    

f0105144 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105144:	55                   	push   %ebp
f0105145:	89 e5                	mov    %esp,%ebp
f0105147:	57                   	push   %edi
f0105148:	56                   	push   %esi
f0105149:	53                   	push   %ebx
f010514a:	83 ec 3c             	sub    $0x3c,%esp
f010514d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105150:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105153:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105156:	eb 1a                	jmp    f0105172 <vprintfmt+0x2e>
f0105158:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010515b:	eb 15                	jmp    f0105172 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010515d:	84 c0                	test   %al,%al
f010515f:	0f 84 15 03 00 00    	je     f010547a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
f0105165:	83 ec 08             	sub    $0x8,%esp
f0105168:	57                   	push   %edi
f0105169:	0f b6 c0             	movzbl %al,%eax
f010516c:	50                   	push   %eax
f010516d:	ff d6                	call   *%esi
f010516f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105172:	8a 03                	mov    (%ebx),%al
f0105174:	43                   	inc    %ebx
f0105175:	3c 25                	cmp    $0x25,%al
f0105177:	75 e4                	jne    f010515d <vprintfmt+0x19>
f0105179:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0105180:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105187:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f010518e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105195:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
f0105199:	eb 0a                	jmp    f01051a5 <vprintfmt+0x61>
f010519b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
f01051a2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
f01051a5:	8a 03                	mov    (%ebx),%al
f01051a7:	0f b6 d0             	movzbl %al,%edx
f01051aa:	8d 4b 01             	lea    0x1(%ebx),%ecx
f01051ad:	89 4d ec             	mov    %ecx,-0x14(%ebp)
f01051b0:	83 e8 23             	sub    $0x23,%eax
f01051b3:	3c 55                	cmp    $0x55,%al
f01051b5:	0f 87 9c 02 00 00    	ja     f0105457 <vprintfmt+0x313>
f01051bb:	0f b6 c0             	movzbl %al,%eax
f01051be:	ff 24 85 60 7d 10 f0 	jmp    *-0xfef82a0(,%eax,4)
f01051c5:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
f01051c9:	eb d7                	jmp    f01051a2 <vprintfmt+0x5e>
f01051cb:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
f01051cf:	eb d1                	jmp    f01051a2 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
f01051d1:	89 d9                	mov    %ebx,%ecx
f01051d3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01051da:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01051dd:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f01051e0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
f01051e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
f01051e7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
f01051eb:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
f01051ec:	8d 42 d0             	lea    -0x30(%edx),%eax
f01051ef:	83 f8 09             	cmp    $0x9,%eax
f01051f2:	77 21                	ja     f0105215 <vprintfmt+0xd1>
f01051f4:	eb e4                	jmp    f01051da <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01051f6:	8b 55 14             	mov    0x14(%ebp),%edx
f01051f9:	8d 42 04             	lea    0x4(%edx),%eax
f01051fc:	89 45 14             	mov    %eax,0x14(%ebp)
f01051ff:	8b 12                	mov    (%edx),%edx
f0105201:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105204:	eb 12                	jmp    f0105218 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
f0105206:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010520a:	79 96                	jns    f01051a2 <vprintfmt+0x5e>
f010520c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105213:	eb 8d                	jmp    f01051a2 <vprintfmt+0x5e>
f0105215:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105218:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010521c:	79 84                	jns    f01051a2 <vprintfmt+0x5e>
f010521e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105221:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105224:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f010522b:	e9 72 ff ff ff       	jmp    f01051a2 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105230:	ff 45 d4             	incl   -0x2c(%ebp)
f0105233:	e9 6a ff ff ff       	jmp    f01051a2 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105238:	8b 55 14             	mov    0x14(%ebp),%edx
f010523b:	8d 42 04             	lea    0x4(%edx),%eax
f010523e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105241:	83 ec 08             	sub    $0x8,%esp
f0105244:	57                   	push   %edi
f0105245:	ff 32                	pushl  (%edx)
f0105247:	ff d6                	call   *%esi
			break;
f0105249:	83 c4 10             	add    $0x10,%esp
f010524c:	e9 07 ff ff ff       	jmp    f0105158 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105251:	8b 55 14             	mov    0x14(%ebp),%edx
f0105254:	8d 42 04             	lea    0x4(%edx),%eax
f0105257:	89 45 14             	mov    %eax,0x14(%ebp)
f010525a:	8b 02                	mov    (%edx),%eax
f010525c:	85 c0                	test   %eax,%eax
f010525e:	79 02                	jns    f0105262 <vprintfmt+0x11e>
f0105260:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105262:	83 f8 0f             	cmp    $0xf,%eax
f0105265:	7f 0b                	jg     f0105272 <vprintfmt+0x12e>
f0105267:	8b 14 85 c0 7e 10 f0 	mov    -0xfef8140(,%eax,4),%edx
f010526e:	85 d2                	test   %edx,%edx
f0105270:	75 15                	jne    f0105287 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
f0105272:	50                   	push   %eax
f0105273:	68 1f 7c 10 f0       	push   $0xf0107c1f
f0105278:	57                   	push   %edi
f0105279:	56                   	push   %esi
f010527a:	e8 6e 02 00 00       	call   f01054ed <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010527f:	83 c4 10             	add    $0x10,%esp
f0105282:	e9 d1 fe ff ff       	jmp    f0105158 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0105287:	52                   	push   %edx
f0105288:	68 bd 73 10 f0       	push   $0xf01073bd
f010528d:	57                   	push   %edi
f010528e:	56                   	push   %esi
f010528f:	e8 59 02 00 00       	call   f01054ed <printfmt>
f0105294:	83 c4 10             	add    $0x10,%esp
f0105297:	e9 bc fe ff ff       	jmp    f0105158 <vprintfmt+0x14>
f010529c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010529f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01052a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01052a5:	8b 55 14             	mov    0x14(%ebp),%edx
f01052a8:	8d 42 04             	lea    0x4(%edx),%eax
f01052ab:	89 45 14             	mov    %eax,0x14(%ebp)
f01052ae:	8b 1a                	mov    (%edx),%ebx
f01052b0:	85 db                	test   %ebx,%ebx
f01052b2:	75 05                	jne    f01052b9 <vprintfmt+0x175>
f01052b4:	bb 28 7c 10 f0       	mov    $0xf0107c28,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
f01052b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01052bd:	7e 66                	jle    f0105325 <vprintfmt+0x1e1>
f01052bf:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
f01052c3:	74 60                	je     f0105325 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
f01052c5:	83 ec 08             	sub    $0x8,%esp
f01052c8:	51                   	push   %ecx
f01052c9:	53                   	push   %ebx
f01052ca:	e8 3b 03 00 00       	call   f010560a <strnlen>
f01052cf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01052d2:	29 c1                	sub    %eax,%ecx
f01052d4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01052d7:	83 c4 10             	add    $0x10,%esp
f01052da:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f01052de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01052e1:	eb 0f                	jmp    f01052f2 <vprintfmt+0x1ae>
					putch(padc, putdat);
f01052e3:	83 ec 08             	sub    $0x8,%esp
f01052e6:	57                   	push   %edi
f01052e7:	ff 75 c4             	pushl  -0x3c(%ebp)
f01052ea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01052ec:	ff 4d d8             	decl   -0x28(%ebp)
f01052ef:	83 c4 10             	add    $0x10,%esp
f01052f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01052f6:	7f eb                	jg     f01052e3 <vprintfmt+0x19f>
f01052f8:	eb 2b                	jmp    f0105325 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052fa:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
f01052fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105301:	74 15                	je     f0105318 <vprintfmt+0x1d4>
f0105303:	8d 42 e0             	lea    -0x20(%edx),%eax
f0105306:	83 f8 5e             	cmp    $0x5e,%eax
f0105309:	76 0d                	jbe    f0105318 <vprintfmt+0x1d4>
					putch('?', putdat);
f010530b:	83 ec 08             	sub    $0x8,%esp
f010530e:	57                   	push   %edi
f010530f:	6a 3f                	push   $0x3f
f0105311:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105313:	83 c4 10             	add    $0x10,%esp
f0105316:	eb 0a                	jmp    f0105322 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0105318:	83 ec 08             	sub    $0x8,%esp
f010531b:	57                   	push   %edi
f010531c:	52                   	push   %edx
f010531d:	ff d6                	call   *%esi
f010531f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105322:	ff 4d d8             	decl   -0x28(%ebp)
f0105325:	8a 03                	mov    (%ebx),%al
f0105327:	43                   	inc    %ebx
f0105328:	84 c0                	test   %al,%al
f010532a:	74 1b                	je     f0105347 <vprintfmt+0x203>
f010532c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105330:	78 c8                	js     f01052fa <vprintfmt+0x1b6>
f0105332:	ff 4d dc             	decl   -0x24(%ebp)
f0105335:	79 c3                	jns    f01052fa <vprintfmt+0x1b6>
f0105337:	eb 0e                	jmp    f0105347 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105339:	83 ec 08             	sub    $0x8,%esp
f010533c:	57                   	push   %edi
f010533d:	6a 20                	push   $0x20
f010533f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105341:	ff 4d d8             	decl   -0x28(%ebp)
f0105344:	83 c4 10             	add    $0x10,%esp
f0105347:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010534b:	7f ec                	jg     f0105339 <vprintfmt+0x1f5>
f010534d:	e9 06 fe ff ff       	jmp    f0105158 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105352:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
f0105356:	7e 10                	jle    f0105368 <vprintfmt+0x224>
		return va_arg(*ap, long long);
f0105358:	8b 55 14             	mov    0x14(%ebp),%edx
f010535b:	8d 42 08             	lea    0x8(%edx),%eax
f010535e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105361:	8b 02                	mov    (%edx),%eax
f0105363:	8b 52 04             	mov    0x4(%edx),%edx
f0105366:	eb 20                	jmp    f0105388 <vprintfmt+0x244>
	else if (lflag)
f0105368:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010536c:	74 0e                	je     f010537c <vprintfmt+0x238>
		return va_arg(*ap, long);
f010536e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105371:	8d 50 04             	lea    0x4(%eax),%edx
f0105374:	89 55 14             	mov    %edx,0x14(%ebp)
f0105377:	8b 00                	mov    (%eax),%eax
f0105379:	99                   	cltd   
f010537a:	eb 0c                	jmp    f0105388 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
f010537c:	8b 45 14             	mov    0x14(%ebp),%eax
f010537f:	8d 50 04             	lea    0x4(%eax),%edx
f0105382:	89 55 14             	mov    %edx,0x14(%ebp)
f0105385:	8b 00                	mov    (%eax),%eax
f0105387:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105388:	89 d1                	mov    %edx,%ecx
f010538a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
f010538c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010538f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105392:	85 c9                	test   %ecx,%ecx
f0105394:	78 0a                	js     f01053a0 <vprintfmt+0x25c>
f0105396:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010539b:	e9 89 00 00 00       	jmp    f0105429 <vprintfmt+0x2e5>
				putch('-', putdat);
f01053a0:	83 ec 08             	sub    $0x8,%esp
f01053a3:	57                   	push   %edi
f01053a4:	6a 2d                	push   $0x2d
f01053a6:	ff d6                	call   *%esi
				num = -(long long) num;
f01053a8:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01053ab:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01053ae:	f7 da                	neg    %edx
f01053b0:	83 d1 00             	adc    $0x0,%ecx
f01053b3:	f7 d9                	neg    %ecx
f01053b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01053ba:	83 c4 10             	add    $0x10,%esp
f01053bd:	eb 6a                	jmp    f0105429 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01053bf:	8d 45 14             	lea    0x14(%ebp),%eax
f01053c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01053c5:	e8 22 fd ff ff       	call   f01050ec <getuint>
f01053ca:	89 d1                	mov    %edx,%ecx
f01053cc:	89 c2                	mov    %eax,%edx
f01053ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01053d3:	eb 54                	jmp    f0105429 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01053d5:	8d 45 14             	lea    0x14(%ebp),%eax
f01053d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01053db:	e8 0c fd ff ff       	call   f01050ec <getuint>
f01053e0:	89 d1                	mov    %edx,%ecx
f01053e2:	89 c2                	mov    %eax,%edx
f01053e4:	bb 08 00 00 00       	mov    $0x8,%ebx
f01053e9:	eb 3e                	jmp    f0105429 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01053eb:	83 ec 08             	sub    $0x8,%esp
f01053ee:	57                   	push   %edi
f01053ef:	6a 30                	push   $0x30
f01053f1:	ff d6                	call   *%esi
			putch('x', putdat);
f01053f3:	83 c4 08             	add    $0x8,%esp
f01053f6:	57                   	push   %edi
f01053f7:	6a 78                	push   $0x78
f01053f9:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053fb:	8b 55 14             	mov    0x14(%ebp),%edx
f01053fe:	8d 42 04             	lea    0x4(%edx),%eax
f0105401:	89 45 14             	mov    %eax,0x14(%ebp)
f0105404:	8b 12                	mov    (%edx),%edx
f0105406:	b9 00 00 00 00       	mov    $0x0,%ecx
f010540b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105410:	83 c4 10             	add    $0x10,%esp
f0105413:	eb 14                	jmp    f0105429 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105415:	8d 45 14             	lea    0x14(%ebp),%eax
f0105418:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010541b:	e8 cc fc ff ff       	call   f01050ec <getuint>
f0105420:	89 d1                	mov    %edx,%ecx
f0105422:	89 c2                	mov    %eax,%edx
f0105424:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105429:	83 ec 0c             	sub    $0xc,%esp
f010542c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0105430:	50                   	push   %eax
f0105431:	ff 75 d8             	pushl  -0x28(%ebp)
f0105434:	53                   	push   %ebx
f0105435:	51                   	push   %ecx
f0105436:	52                   	push   %edx
f0105437:	89 fa                	mov    %edi,%edx
f0105439:	89 f0                	mov    %esi,%eax
f010543b:	e8 08 fc ff ff       	call   f0105048 <printnum>
			break;
f0105440:	83 c4 20             	add    $0x20,%esp
f0105443:	e9 10 fd ff ff       	jmp    f0105158 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105448:	83 ec 08             	sub    $0x8,%esp
f010544b:	57                   	push   %edi
f010544c:	52                   	push   %edx
f010544d:	ff d6                	call   *%esi
			break;
f010544f:	83 c4 10             	add    $0x10,%esp
f0105452:	e9 01 fd ff ff       	jmp    f0105158 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105457:	83 ec 08             	sub    $0x8,%esp
f010545a:	57                   	push   %edi
f010545b:	6a 25                	push   $0x25
f010545d:	ff d6                	call   *%esi
f010545f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0105462:	83 ea 02             	sub    $0x2,%edx
f0105465:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105468:	8a 02                	mov    (%edx),%al
f010546a:	4a                   	dec    %edx
f010546b:	3c 25                	cmp    $0x25,%al
f010546d:	75 f9                	jne    f0105468 <vprintfmt+0x324>
f010546f:	83 c2 02             	add    $0x2,%edx
f0105472:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105475:	e9 de fc ff ff       	jmp    f0105158 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
f010547a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010547d:	5b                   	pop    %ebx
f010547e:	5e                   	pop    %esi
f010547f:	5f                   	pop    %edi
f0105480:	c9                   	leave  
f0105481:	c3                   	ret    

f0105482 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105482:	55                   	push   %ebp
f0105483:	89 e5                	mov    %esp,%ebp
f0105485:	83 ec 18             	sub    $0x18,%esp
f0105488:	8b 55 08             	mov    0x8(%ebp),%edx
f010548b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010548e:	85 d2                	test   %edx,%edx
f0105490:	74 37                	je     f01054c9 <vsnprintf+0x47>
f0105492:	85 c0                	test   %eax,%eax
f0105494:	7e 33                	jle    f01054c9 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105496:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010549d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01054a1:	89 45 f8             	mov    %eax,-0x8(%ebp)
f01054a4:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054a7:	ff 75 14             	pushl  0x14(%ebp)
f01054aa:	ff 75 10             	pushl  0x10(%ebp)
f01054ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01054b0:	50                   	push   %eax
f01054b1:	68 28 51 10 f0       	push   $0xf0105128
f01054b6:	e8 89 fc ff ff       	call   f0105144 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01054c4:	83 c4 10             	add    $0x10,%esp
f01054c7:	eb 05                	jmp    f01054ce <vsnprintf+0x4c>
f01054c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f01054ce:	c9                   	leave  
f01054cf:	c3                   	ret    

f01054d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054d0:	55                   	push   %ebp
f01054d1:	89 e5                	mov    %esp,%ebp
f01054d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054d6:	8d 45 14             	lea    0x14(%ebp),%eax
f01054d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f01054dc:	50                   	push   %eax
f01054dd:	ff 75 10             	pushl  0x10(%ebp)
f01054e0:	ff 75 0c             	pushl  0xc(%ebp)
f01054e3:	ff 75 08             	pushl  0x8(%ebp)
f01054e6:	e8 97 ff ff ff       	call   f0105482 <vsnprintf>
	va_end(ap);

	return rc;
}
f01054eb:	c9                   	leave  
f01054ec:	c3                   	ret    

f01054ed <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01054ed:	55                   	push   %ebp
f01054ee:	89 e5                	mov    %esp,%ebp
f01054f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01054f3:	8d 45 14             	lea    0x14(%ebp),%eax
f01054f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01054f9:	50                   	push   %eax
f01054fa:	ff 75 10             	pushl  0x10(%ebp)
f01054fd:	ff 75 0c             	pushl  0xc(%ebp)
f0105500:	ff 75 08             	pushl  0x8(%ebp)
f0105503:	e8 3c fc ff ff       	call   f0105144 <vprintfmt>
	va_end(ap);
f0105508:	83 c4 10             	add    $0x10,%esp
}
f010550b:	c9                   	leave  
f010550c:	c3                   	ret    
f010550d:	00 00                	add    %al,(%eax)
	...

f0105510 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105510:	55                   	push   %ebp
f0105511:	89 e5                	mov    %esp,%ebp
f0105513:	57                   	push   %edi
f0105514:	56                   	push   %esi
f0105515:	53                   	push   %ebx
f0105516:	83 ec 0c             	sub    $0xc,%esp
f0105519:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010551c:	85 c0                	test   %eax,%eax
f010551e:	74 11                	je     f0105531 <readline+0x21>
		cprintf("%s", prompt);
f0105520:	83 ec 08             	sub    $0x8,%esp
f0105523:	50                   	push   %eax
f0105524:	68 bd 73 10 f0       	push   $0xf01073bd
f0105529:	e8 d8 e1 ff ff       	call   f0103706 <cprintf>
f010552e:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105531:	83 ec 0c             	sub    $0xc,%esp
f0105534:	6a 00                	push   $0x0
f0105536:	e8 3f ae ff ff       	call   f010037a <iscons>
f010553b:	89 c7                	mov    %eax,%edi
f010553d:	be 00 00 00 00       	mov    $0x0,%esi
f0105542:	83 c4 10             	add    $0x10,%esp
	while (1) {
		c = getchar();
f0105545:	e8 1f ae ff ff       	call   f0100369 <getchar>
f010554a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010554c:	85 c0                	test   %eax,%eax
f010554e:	79 27                	jns    f0105577 <readline+0x67>
			if (c != -E_EOF)
f0105550:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105553:	75 0a                	jne    f010555f <readline+0x4f>
f0105555:	b8 00 00 00 00       	mov    $0x0,%eax
f010555a:	e9 8b 00 00 00       	jmp    f01055ea <readline+0xda>
				cprintf("read error: %e\n", c);
f010555f:	83 ec 08             	sub    $0x8,%esp
f0105562:	50                   	push   %eax
f0105563:	68 1f 7f 10 f0       	push   $0xf0107f1f
f0105568:	e8 99 e1 ff ff       	call   f0103706 <cprintf>
f010556d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105572:	83 c4 10             	add    $0x10,%esp
f0105575:	eb 73                	jmp    f01055ea <readline+0xda>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105577:	83 f8 08             	cmp    $0x8,%eax
f010557a:	74 05                	je     f0105581 <readline+0x71>
f010557c:	83 f8 7f             	cmp    $0x7f,%eax
f010557f:	75 18                	jne    f0105599 <readline+0x89>
f0105581:	85 f6                	test   %esi,%esi
f0105583:	7e 14                	jle    f0105599 <readline+0x89>
			if (echoing)
f0105585:	85 ff                	test   %edi,%edi
f0105587:	74 0d                	je     f0105596 <readline+0x86>
				cputchar('\b');
f0105589:	83 ec 0c             	sub    $0xc,%esp
f010558c:	6a 08                	push   $0x8
f010558e:	e8 b6 af ff ff       	call   f0100549 <cputchar>
f0105593:	83 c4 10             	add    $0x10,%esp
			i--;
f0105596:	4e                   	dec    %esi
f0105597:	eb ac                	jmp    f0105545 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105599:	83 fb 1f             	cmp    $0x1f,%ebx
f010559c:	7e 21                	jle    f01055bf <readline+0xaf>
f010559e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01055a4:	7f 9f                	jg     f0105545 <readline+0x35>
			if (echoing)
f01055a6:	85 ff                	test   %edi,%edi
f01055a8:	74 0c                	je     f01055b6 <readline+0xa6>
				cputchar(c);
f01055aa:	83 ec 0c             	sub    $0xc,%esp
f01055ad:	53                   	push   %ebx
f01055ae:	e8 96 af ff ff       	call   f0100549 <cputchar>
f01055b3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01055b6:	88 9e 80 fa 1e f0    	mov    %bl,-0xfe10580(%esi)
f01055bc:	46                   	inc    %esi
f01055bd:	eb 86                	jmp    f0105545 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01055bf:	83 fb 0a             	cmp    $0xa,%ebx
f01055c2:	74 09                	je     f01055cd <readline+0xbd>
f01055c4:	83 fb 0d             	cmp    $0xd,%ebx
f01055c7:	0f 85 78 ff ff ff    	jne    f0105545 <readline+0x35>
			if (echoing)
f01055cd:	85 ff                	test   %edi,%edi
f01055cf:	74 0d                	je     f01055de <readline+0xce>
				cputchar('\n');
f01055d1:	83 ec 0c             	sub    $0xc,%esp
f01055d4:	6a 0a                	push   $0xa
f01055d6:	e8 6e af ff ff       	call   f0100549 <cputchar>
f01055db:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01055de:	c6 86 80 fa 1e f0 00 	movb   $0x0,-0xfe10580(%esi)
f01055e5:	b8 80 fa 1e f0       	mov    $0xf01efa80,%eax
			return buf;
		}
	}
}
f01055ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055ed:	5b                   	pop    %ebx
f01055ee:	5e                   	pop    %esi
f01055ef:	5f                   	pop    %edi
f01055f0:	c9                   	leave  
f01055f1:	c3                   	ret    
	...

f01055f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055f4:	55                   	push   %ebp
f01055f5:	89 e5                	mov    %esp,%ebp
f01055f7:	8b 55 08             	mov    0x8(%ebp),%edx
f01055fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ff:	eb 01                	jmp    f0105602 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
f0105601:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105602:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f0105606:	75 f9                	jne    f0105601 <strlen+0xd>
		n++;
	return n;
}
f0105608:	c9                   	leave  
f0105609:	c3                   	ret    

f010560a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010560a:	55                   	push   %ebp
f010560b:	89 e5                	mov    %esp,%ebp
f010560d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105610:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105613:	b8 00 00 00 00       	mov    $0x0,%eax
f0105618:	eb 01                	jmp    f010561b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
f010561a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010561b:	39 d0                	cmp    %edx,%eax
f010561d:	74 06                	je     f0105625 <strnlen+0x1b>
f010561f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
f0105623:	75 f5                	jne    f010561a <strnlen+0x10>
		n++;
	return n;
}
f0105625:	c9                   	leave  
f0105626:	c3                   	ret    

f0105627 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105627:	55                   	push   %ebp
f0105628:	89 e5                	mov    %esp,%ebp
f010562a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010562d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105630:	8a 01                	mov    (%ecx),%al
f0105632:	88 02                	mov    %al,(%edx)
f0105634:	42                   	inc    %edx
f0105635:	41                   	inc    %ecx
f0105636:	84 c0                	test   %al,%al
f0105638:	75 f6                	jne    f0105630 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
f010563a:	8b 45 08             	mov    0x8(%ebp),%eax
f010563d:	c9                   	leave  
f010563e:	c3                   	ret    

f010563f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010563f:	55                   	push   %ebp
f0105640:	89 e5                	mov    %esp,%ebp
f0105642:	53                   	push   %ebx
f0105643:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105646:	53                   	push   %ebx
f0105647:	e8 a8 ff ff ff       	call   f01055f4 <strlen>
	strcpy(dst + len, src);
f010564c:	ff 75 0c             	pushl  0xc(%ebp)
f010564f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105652:	50                   	push   %eax
f0105653:	e8 cf ff ff ff       	call   f0105627 <strcpy>
	return dst;
}
f0105658:	89 d8                	mov    %ebx,%eax
f010565a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010565d:	c9                   	leave  
f010565e:	c3                   	ret    

f010565f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010565f:	55                   	push   %ebp
f0105660:	89 e5                	mov    %esp,%ebp
f0105662:	56                   	push   %esi
f0105663:	53                   	push   %ebx
f0105664:	8b 75 08             	mov    0x8(%ebp),%esi
f0105667:	8b 55 0c             	mov    0xc(%ebp),%edx
f010566a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010566d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105672:	eb 0c                	jmp    f0105680 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
f0105674:	8a 02                	mov    (%edx),%al
f0105676:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105679:	80 3a 01             	cmpb   $0x1,(%edx)
f010567c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010567f:	41                   	inc    %ecx
f0105680:	39 d9                	cmp    %ebx,%ecx
f0105682:	75 f0                	jne    f0105674 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105684:	89 f0                	mov    %esi,%eax
f0105686:	5b                   	pop    %ebx
f0105687:	5e                   	pop    %esi
f0105688:	c9                   	leave  
f0105689:	c3                   	ret    

f010568a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010568a:	55                   	push   %ebp
f010568b:	89 e5                	mov    %esp,%ebp
f010568d:	56                   	push   %esi
f010568e:	53                   	push   %ebx
f010568f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105695:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105698:	85 c9                	test   %ecx,%ecx
f010569a:	75 04                	jne    f01056a0 <strlcpy+0x16>
f010569c:	89 f0                	mov    %esi,%eax
f010569e:	eb 14                	jmp    f01056b4 <strlcpy+0x2a>
f01056a0:	89 f0                	mov    %esi,%eax
f01056a2:	eb 04                	jmp    f01056a8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056a4:	88 10                	mov    %dl,(%eax)
f01056a6:	40                   	inc    %eax
f01056a7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056a8:	49                   	dec    %ecx
f01056a9:	74 06                	je     f01056b1 <strlcpy+0x27>
f01056ab:	8a 13                	mov    (%ebx),%dl
f01056ad:	84 d2                	test   %dl,%dl
f01056af:	75 f3                	jne    f01056a4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
f01056b1:	c6 00 00             	movb   $0x0,(%eax)
f01056b4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01056b6:	5b                   	pop    %ebx
f01056b7:	5e                   	pop    %esi
f01056b8:	c9                   	leave  
f01056b9:	c3                   	ret    

f01056ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056ba:	55                   	push   %ebp
f01056bb:	89 e5                	mov    %esp,%ebp
f01056bd:	8b 55 08             	mov    0x8(%ebp),%edx
f01056c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056c3:	eb 02                	jmp    f01056c7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
f01056c5:	42                   	inc    %edx
f01056c6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056c7:	8a 02                	mov    (%edx),%al
f01056c9:	84 c0                	test   %al,%al
f01056cb:	74 04                	je     f01056d1 <strcmp+0x17>
f01056cd:	3a 01                	cmp    (%ecx),%al
f01056cf:	74 f4                	je     f01056c5 <strcmp+0xb>
f01056d1:	0f b6 c0             	movzbl %al,%eax
f01056d4:	0f b6 11             	movzbl (%ecx),%edx
f01056d7:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01056d9:	c9                   	leave  
f01056da:	c3                   	ret    

f01056db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056db:	55                   	push   %ebp
f01056dc:	89 e5                	mov    %esp,%ebp
f01056de:	53                   	push   %ebx
f01056df:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056e5:	8b 55 10             	mov    0x10(%ebp),%edx
f01056e8:	eb 03                	jmp    f01056ed <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f01056ea:	4a                   	dec    %edx
f01056eb:	41                   	inc    %ecx
f01056ec:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01056ed:	85 d2                	test   %edx,%edx
f01056ef:	75 07                	jne    f01056f8 <strncmp+0x1d>
f01056f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f6:	eb 14                	jmp    f010570c <strncmp+0x31>
f01056f8:	8a 01                	mov    (%ecx),%al
f01056fa:	84 c0                	test   %al,%al
f01056fc:	74 04                	je     f0105702 <strncmp+0x27>
f01056fe:	3a 03                	cmp    (%ebx),%al
f0105700:	74 e8                	je     f01056ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105702:	0f b6 d0             	movzbl %al,%edx
f0105705:	0f b6 03             	movzbl (%ebx),%eax
f0105708:	29 c2                	sub    %eax,%edx
f010570a:	89 d0                	mov    %edx,%eax
}
f010570c:	5b                   	pop    %ebx
f010570d:	c9                   	leave  
f010570e:	c3                   	ret    

f010570f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010570f:	55                   	push   %ebp
f0105710:	89 e5                	mov    %esp,%ebp
f0105712:	8b 45 08             	mov    0x8(%ebp),%eax
f0105715:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105718:	eb 05                	jmp    f010571f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
f010571a:	38 ca                	cmp    %cl,%dl
f010571c:	74 0c                	je     f010572a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010571e:	40                   	inc    %eax
f010571f:	8a 10                	mov    (%eax),%dl
f0105721:	84 d2                	test   %dl,%dl
f0105723:	75 f5                	jne    f010571a <strchr+0xb>
f0105725:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f010572a:	c9                   	leave  
f010572b:	c3                   	ret    

f010572c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010572c:	55                   	push   %ebp
f010572d:	89 e5                	mov    %esp,%ebp
f010572f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105732:	8a 4d 0c             	mov    0xc(%ebp),%cl
f0105735:	eb 05                	jmp    f010573c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
f0105737:	38 ca                	cmp    %cl,%dl
f0105739:	74 07                	je     f0105742 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010573b:	40                   	inc    %eax
f010573c:	8a 10                	mov    (%eax),%dl
f010573e:	84 d2                	test   %dl,%dl
f0105740:	75 f5                	jne    f0105737 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105742:	c9                   	leave  
f0105743:	c3                   	ret    

f0105744 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105744:	55                   	push   %ebp
f0105745:	89 e5                	mov    %esp,%ebp
f0105747:	57                   	push   %edi
f0105748:	56                   	push   %esi
f0105749:	53                   	push   %ebx
f010574a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010574d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105750:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
f0105753:	85 db                	test   %ebx,%ebx
f0105755:	74 36                	je     f010578d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105757:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010575d:	75 29                	jne    f0105788 <memset+0x44>
f010575f:	f6 c3 03             	test   $0x3,%bl
f0105762:	75 24                	jne    f0105788 <memset+0x44>
		c &= 0xFF;
f0105764:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105767:	89 d6                	mov    %edx,%esi
f0105769:	c1 e6 08             	shl    $0x8,%esi
f010576c:	89 d0                	mov    %edx,%eax
f010576e:	c1 e0 18             	shl    $0x18,%eax
f0105771:	89 d1                	mov    %edx,%ecx
f0105773:	c1 e1 10             	shl    $0x10,%ecx
f0105776:	09 c8                	or     %ecx,%eax
f0105778:	09 c2                	or     %eax,%edx
f010577a:	89 f0                	mov    %esi,%eax
f010577c:	09 d0                	or     %edx,%eax
f010577e:	89 d9                	mov    %ebx,%ecx
f0105780:	c1 e9 02             	shr    $0x2,%ecx
f0105783:	fc                   	cld    
f0105784:	f3 ab                	rep stos %eax,%es:(%edi)
f0105786:	eb 05                	jmp    f010578d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105788:	89 d9                	mov    %ebx,%ecx
f010578a:	fc                   	cld    
f010578b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010578d:	89 f8                	mov    %edi,%eax
f010578f:	5b                   	pop    %ebx
f0105790:	5e                   	pop    %esi
f0105791:	5f                   	pop    %edi
f0105792:	c9                   	leave  
f0105793:	c3                   	ret    

f0105794 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105794:	55                   	push   %ebp
f0105795:	89 e5                	mov    %esp,%ebp
f0105797:	57                   	push   %edi
f0105798:	56                   	push   %esi
f0105799:	8b 45 08             	mov    0x8(%ebp),%eax
f010579c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f010579f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01057a2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01057a4:	39 c6                	cmp    %eax,%esi
f01057a6:	73 36                	jae    f01057de <memmove+0x4a>
f01057a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057ab:	39 d0                	cmp    %edx,%eax
f01057ad:	73 2f                	jae    f01057de <memmove+0x4a>
		s += n;
		d += n;
f01057af:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057b2:	f6 c2 03             	test   $0x3,%dl
f01057b5:	75 1b                	jne    f01057d2 <memmove+0x3e>
f01057b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057bd:	75 13                	jne    f01057d2 <memmove+0x3e>
f01057bf:	f6 c1 03             	test   $0x3,%cl
f01057c2:	75 0e                	jne    f01057d2 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
f01057c4:	8d 7e fc             	lea    -0x4(%esi),%edi
f01057c7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057ca:	c1 e9 02             	shr    $0x2,%ecx
f01057cd:	fd                   	std    
f01057ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057d0:	eb 09                	jmp    f01057db <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01057d2:	8d 7e ff             	lea    -0x1(%esi),%edi
f01057d5:	8d 72 ff             	lea    -0x1(%edx),%esi
f01057d8:	fd                   	std    
f01057d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057db:	fc                   	cld    
f01057dc:	eb 20                	jmp    f01057fe <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057de:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057e4:	75 15                	jne    f01057fb <memmove+0x67>
f01057e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057ec:	75 0d                	jne    f01057fb <memmove+0x67>
f01057ee:	f6 c1 03             	test   $0x3,%cl
f01057f1:	75 08                	jne    f01057fb <memmove+0x67>
			asm volatile("cld; rep movsl\n"
f01057f3:	c1 e9 02             	shr    $0x2,%ecx
f01057f6:	fc                   	cld    
f01057f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057f9:	eb 03                	jmp    f01057fe <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01057fb:	fc                   	cld    
f01057fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01057fe:	5e                   	pop    %esi
f01057ff:	5f                   	pop    %edi
f0105800:	c9                   	leave  
f0105801:	c3                   	ret    

f0105802 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105802:	55                   	push   %ebp
f0105803:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105805:	ff 75 10             	pushl  0x10(%ebp)
f0105808:	ff 75 0c             	pushl  0xc(%ebp)
f010580b:	ff 75 08             	pushl  0x8(%ebp)
f010580e:	e8 81 ff ff ff       	call   f0105794 <memmove>
}
f0105813:	c9                   	leave  
f0105814:	c3                   	ret    

f0105815 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105815:	55                   	push   %ebp
f0105816:	89 e5                	mov    %esp,%ebp
f0105818:	53                   	push   %ebx
f0105819:	83 ec 04             	sub    $0x4,%esp
f010581c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
f010581f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
f0105822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105825:	eb 1b                	jmp    f0105842 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
f0105827:	8a 1a                	mov    (%edx),%bl
f0105829:	88 5d fb             	mov    %bl,-0x5(%ebp)
f010582c:	8a 19                	mov    (%ecx),%bl
f010582e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
f0105831:	74 0d                	je     f0105840 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
f0105833:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
f0105837:	0f b6 c3             	movzbl %bl,%eax
f010583a:	29 c2                	sub    %eax,%edx
f010583c:	89 d0                	mov    %edx,%eax
f010583e:	eb 0d                	jmp    f010584d <memcmp+0x38>
		s1++, s2++;
f0105840:	42                   	inc    %edx
f0105841:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105842:	48                   	dec    %eax
f0105843:	83 f8 ff             	cmp    $0xffffffff,%eax
f0105846:	75 df                	jne    f0105827 <memcmp+0x12>
f0105848:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f010584d:	83 c4 04             	add    $0x4,%esp
f0105850:	5b                   	pop    %ebx
f0105851:	c9                   	leave  
f0105852:	c3                   	ret    

f0105853 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105853:	55                   	push   %ebp
f0105854:	89 e5                	mov    %esp,%ebp
f0105856:	8b 45 08             	mov    0x8(%ebp),%eax
f0105859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010585c:	89 c2                	mov    %eax,%edx
f010585e:	03 55 10             	add    0x10(%ebp),%edx
f0105861:	eb 05                	jmp    f0105868 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105863:	38 08                	cmp    %cl,(%eax)
f0105865:	74 05                	je     f010586c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105867:	40                   	inc    %eax
f0105868:	39 d0                	cmp    %edx,%eax
f010586a:	72 f7                	jb     f0105863 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010586c:	c9                   	leave  
f010586d:	c3                   	ret    

f010586e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010586e:	55                   	push   %ebp
f010586f:	89 e5                	mov    %esp,%ebp
f0105871:	57                   	push   %edi
f0105872:	56                   	push   %esi
f0105873:	53                   	push   %ebx
f0105874:	83 ec 04             	sub    $0x4,%esp
f0105877:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010587a:	8b 75 10             	mov    0x10(%ebp),%esi
f010587d:	eb 01                	jmp    f0105880 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
f010587f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105880:	8a 01                	mov    (%ecx),%al
f0105882:	3c 20                	cmp    $0x20,%al
f0105884:	74 f9                	je     f010587f <strtol+0x11>
f0105886:	3c 09                	cmp    $0x9,%al
f0105888:	74 f5                	je     f010587f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
f010588a:	3c 2b                	cmp    $0x2b,%al
f010588c:	75 0a                	jne    f0105898 <strtol+0x2a>
		s++;
f010588e:	41                   	inc    %ecx
f010588f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0105896:	eb 17                	jmp    f01058af <strtol+0x41>
	else if (*s == '-')
f0105898:	3c 2d                	cmp    $0x2d,%al
f010589a:	74 09                	je     f01058a5 <strtol+0x37>
f010589c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01058a3:	eb 0a                	jmp    f01058af <strtol+0x41>
		s++, neg = 1;
f01058a5:	8d 49 01             	lea    0x1(%ecx),%ecx
f01058a8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058af:	85 f6                	test   %esi,%esi
f01058b1:	74 05                	je     f01058b8 <strtol+0x4a>
f01058b3:	83 fe 10             	cmp    $0x10,%esi
f01058b6:	75 1a                	jne    f01058d2 <strtol+0x64>
f01058b8:	8a 01                	mov    (%ecx),%al
f01058ba:	3c 30                	cmp    $0x30,%al
f01058bc:	75 10                	jne    f01058ce <strtol+0x60>
f01058be:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058c2:	75 0a                	jne    f01058ce <strtol+0x60>
		s += 2, base = 16;
f01058c4:	83 c1 02             	add    $0x2,%ecx
f01058c7:	be 10 00 00 00       	mov    $0x10,%esi
f01058cc:	eb 04                	jmp    f01058d2 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
f01058ce:	85 f6                	test   %esi,%esi
f01058d0:	74 07                	je     f01058d9 <strtol+0x6b>
f01058d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01058d7:	eb 13                	jmp    f01058ec <strtol+0x7e>
f01058d9:	3c 30                	cmp    $0x30,%al
f01058db:	74 07                	je     f01058e4 <strtol+0x76>
f01058dd:	be 0a 00 00 00       	mov    $0xa,%esi
f01058e2:	eb ee                	jmp    f01058d2 <strtol+0x64>
		s++, base = 8;
f01058e4:	41                   	inc    %ecx
f01058e5:	be 08 00 00 00       	mov    $0x8,%esi
f01058ea:	eb e6                	jmp    f01058d2 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01058ec:	8a 11                	mov    (%ecx),%dl
f01058ee:	88 d3                	mov    %dl,%bl
f01058f0:	8d 42 d0             	lea    -0x30(%edx),%eax
f01058f3:	3c 09                	cmp    $0x9,%al
f01058f5:	77 08                	ja     f01058ff <strtol+0x91>
			dig = *s - '0';
f01058f7:	0f be c2             	movsbl %dl,%eax
f01058fa:	8d 50 d0             	lea    -0x30(%eax),%edx
f01058fd:	eb 1c                	jmp    f010591b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01058ff:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0105902:	3c 19                	cmp    $0x19,%al
f0105904:	77 08                	ja     f010590e <strtol+0xa0>
			dig = *s - 'a' + 10;
f0105906:	0f be c2             	movsbl %dl,%eax
f0105909:	8d 50 a9             	lea    -0x57(%eax),%edx
f010590c:	eb 0d                	jmp    f010591b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010590e:	8d 43 bf             	lea    -0x41(%ebx),%eax
f0105911:	3c 19                	cmp    $0x19,%al
f0105913:	77 15                	ja     f010592a <strtol+0xbc>
			dig = *s - 'A' + 10;
f0105915:	0f be c2             	movsbl %dl,%eax
f0105918:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
f010591b:	39 f2                	cmp    %esi,%edx
f010591d:	7d 0b                	jge    f010592a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
f010591f:	41                   	inc    %ecx
f0105920:	89 f8                	mov    %edi,%eax
f0105922:	0f af c6             	imul   %esi,%eax
f0105925:	8d 3c 02             	lea    (%edx,%eax,1),%edi
f0105928:	eb c2                	jmp    f01058ec <strtol+0x7e>
		// we don't properly detect overflow!
	}
f010592a:	89 f8                	mov    %edi,%eax

	if (endptr)
f010592c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105930:	74 05                	je     f0105937 <strtol+0xc9>
		*endptr = (char *) s;
f0105932:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105935:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
f0105937:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010593b:	74 04                	je     f0105941 <strtol+0xd3>
f010593d:	89 c7                	mov    %eax,%edi
f010593f:	f7 df                	neg    %edi
}
f0105941:	89 f8                	mov    %edi,%eax
f0105943:	83 c4 04             	add    $0x4,%esp
f0105946:	5b                   	pop    %ebx
f0105947:	5e                   	pop    %esi
f0105948:	5f                   	pop    %edi
f0105949:	c9                   	leave  
f010594a:	c3                   	ret    
	...

f010594c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010594c:	fa                   	cli    

	xorw    %ax, %ax
f010594d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010594f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105951:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105953:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105955:	0f 01 16             	lgdtl  (%esi)
f0105958:	74 70                	je     f01059ca <sum+0x2>
	movl    %cr0, %eax
f010595a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010595d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105961:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105964:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010596a:	08 00                	or     %al,(%eax)

f010596c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010596c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105970:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105972:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105974:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105976:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010597a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010597c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010597e:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105983:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105986:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105989:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010598e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105991:	8b 25 84 fe 1e f0    	mov    0xf01efe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105997:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010599c:	b8 28 02 10 f0       	mov    $0xf0100228,%eax
	call    *%eax
f01059a1:	ff d0                	call   *%eax

f01059a3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01059a3:	eb fe                	jmp    f01059a3 <spin>
f01059a5:	8d 76 00             	lea    0x0(%esi),%esi

f01059a8 <gdt>:
	...
f01059b0:	ff                   	(bad)  
f01059b1:	ff 00                	incl   (%eax)
f01059b3:	00 00                	add    %al,(%eax)
f01059b5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01059bc:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01059c0 <gdtdesc>:
f01059c0:	17                   	pop    %ss
f01059c1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01059c6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01059c6:	90                   	nop
	...

f01059c8 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01059c8:	55                   	push   %ebp
f01059c9:	89 e5                	mov    %esp,%ebp
f01059cb:	56                   	push   %esi
f01059cc:	53                   	push   %ebx
f01059cd:	89 c6                	mov    %eax,%esi
f01059cf:	89 d3                	mov    %edx,%ebx
f01059d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01059d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01059db:	eb 07                	jmp    f01059e4 <sum+0x1c>
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01059dd:	0f b6 04 31          	movzbl (%ecx,%esi,1),%eax
f01059e1:	01 c2                	add    %eax,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059e3:	41                   	inc    %ecx
f01059e4:	39 d9                	cmp    %ebx,%ecx
f01059e6:	7c f5                	jl     f01059dd <sum+0x15>
f01059e8:	0f b6 c2             	movzbl %dl,%eax
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01059eb:	5b                   	pop    %ebx
f01059ec:	5e                   	pop    %esi
f01059ed:	c9                   	leave  
f01059ee:	c3                   	ret    

f01059ef <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01059ef:	55                   	push   %ebp
f01059f0:	89 e5                	mov    %esp,%ebp
f01059f2:	56                   	push   %esi
f01059f3:	53                   	push   %ebx
f01059f4:	89 c1                	mov    %eax,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059f6:	8b 1d 88 fe 1e f0    	mov    0xf01efe88,%ebx
f01059fc:	c1 e8 0c             	shr    $0xc,%eax
f01059ff:	39 d8                	cmp    %ebx,%eax
f0105a01:	72 12                	jb     f0105a15 <mpsearch1+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a03:	51                   	push   %ecx
f0105a04:	68 dc 64 10 f0       	push   $0xf01064dc
f0105a09:	6a 57                	push   $0x57
f0105a0b:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a10:	e8 66 a6 ff ff       	call   f010007b <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105a15:	8d 14 11             	lea    (%ecx,%edx,1),%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a18:	89 d0                	mov    %edx,%eax
f0105a1a:	c1 e8 0c             	shr    $0xc,%eax
f0105a1d:	39 c3                	cmp    %eax,%ebx
f0105a1f:	77 12                	ja     f0105a33 <mpsearch1+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a21:	52                   	push   %edx
f0105a22:	68 dc 64 10 f0       	push   $0xf01064dc
f0105a27:	6a 57                	push   $0x57
f0105a29:	68 bd 80 10 f0       	push   $0xf01080bd
f0105a2e:	e8 48 a6 ff ff       	call   f010007b <_panic>
f0105a33:	8d 99 00 00 00 f0    	lea    -0x10000000(%ecx),%ebx
f0105a39:	8d b2 00 00 00 f0    	lea    -0x10000000(%edx),%esi
f0105a3f:	eb 2a                	jmp    f0105a6b <mpsearch1+0x7c>

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105a41:	83 ec 04             	sub    $0x4,%esp
f0105a44:	6a 04                	push   $0x4
f0105a46:	68 cd 80 10 f0       	push   $0xf01080cd
f0105a4b:	53                   	push   %ebx
f0105a4c:	e8 c4 fd ff ff       	call   f0105815 <memcmp>
f0105a51:	83 c4 10             	add    $0x10,%esp
f0105a54:	85 c0                	test   %eax,%eax
f0105a56:	75 10                	jne    f0105a68 <mpsearch1+0x79>
f0105a58:	ba 10 00 00 00       	mov    $0x10,%edx
f0105a5d:	89 d8                	mov    %ebx,%eax
f0105a5f:	e8 64 ff ff ff       	call   f01059c8 <sum>
f0105a64:	84 c0                	test   %al,%al
f0105a66:	74 0c                	je     f0105a74 <mpsearch1+0x85>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105a68:	83 c3 10             	add    $0x10,%ebx
f0105a6b:	39 f3                	cmp    %esi,%ebx
f0105a6d:	72 d2                	jb     f0105a41 <mpsearch1+0x52>
f0105a6f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0105a74:	89 d8                	mov    %ebx,%eax
f0105a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a79:	5b                   	pop    %ebx
f0105a7a:	5e                   	pop    %esi
f0105a7b:	c9                   	leave  
f0105a7c:	c3                   	ret    

f0105a7d <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a7d:	55                   	push   %ebp
f0105a7e:	89 e5                	mov    %esp,%ebp
f0105a80:	57                   	push   %edi
f0105a81:	56                   	push   %esi
f0105a82:	53                   	push   %ebx
f0105a83:	83 ec 0c             	sub    $0xc,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a86:	c7 05 c0 03 1f f0 20 	movl   $0xf01f0020,0xf01f03c0
f0105a8d:	00 1f f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a90:	83 3d 88 fe 1e f0 00 	cmpl   $0x0,0xf01efe88
f0105a97:	75 16                	jne    f0105aaf <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a99:	68 00 04 00 00       	push   $0x400
f0105a9e:	68 dc 64 10 f0       	push   $0xf01064dc
f0105aa3:	6a 6f                	push   $0x6f
f0105aa5:	68 bd 80 10 f0       	push   $0xf01080bd
f0105aaa:	e8 cc a5 ff ff       	call   f010007b <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105aaf:	66 a1 0e 04 00 f0    	mov    0xf000040e,%ax
f0105ab5:	66 85 c0             	test   %ax,%ax
f0105ab8:	74 18                	je     f0105ad2 <mp_init+0x55>
f0105aba:	0f b7 c0             	movzwl %ax,%eax
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105abd:	c1 e0 04             	shl    $0x4,%eax
f0105ac0:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ac5:	e8 25 ff ff ff       	call   f01059ef <mpsearch1>
f0105aca:	89 c3                	mov    %eax,%ebx
f0105acc:	85 c0                	test   %eax,%eax
f0105ace:	75 3a                	jne    f0105b0a <mp_init+0x8d>
f0105ad0:	eb 1f                	jmp    f0105af1 <mp_init+0x74>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ad2:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ad9:	c1 e0 0a             	shl    $0xa,%eax
f0105adc:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ae1:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ae6:	e8 04 ff ff ff       	call   f01059ef <mpsearch1>
f0105aeb:	89 c3                	mov    %eax,%ebx
f0105aed:	85 c0                	test   %eax,%eax
f0105aef:	75 19                	jne    f0105b0a <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105af1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105af6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105afb:	e8 ef fe ff ff       	call   f01059ef <mpsearch1>
f0105b00:	89 c3                	mov    %eax,%ebx
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105b02:	85 c0                	test   %eax,%eax
f0105b04:	0f 84 41 02 00 00    	je     f0105d4b <mp_init+0x2ce>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105b0a:	8b 53 04             	mov    0x4(%ebx),%edx
f0105b0d:	85 d2                	test   %edx,%edx
f0105b0f:	74 06                	je     f0105b17 <mp_init+0x9a>
f0105b11:	80 7b 0b 00          	cmpb   $0x0,0xb(%ebx)
f0105b15:	74 15                	je     f0105b2c <mp_init+0xaf>
		cprintf("SMP: Default configurations not implemented\n");
f0105b17:	83 ec 0c             	sub    $0xc,%esp
f0105b1a:	68 30 7f 10 f0       	push   $0xf0107f30
f0105b1f:	e8 e2 db ff ff       	call   f0103706 <cprintf>
f0105b24:	83 c4 10             	add    $0x10,%esp
f0105b27:	e9 1f 02 00 00       	jmp    f0105d4b <mp_init+0x2ce>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b2c:	89 d0                	mov    %edx,%eax
f0105b2e:	c1 e8 0c             	shr    $0xc,%eax
f0105b31:	3b 05 88 fe 1e f0    	cmp    0xf01efe88,%eax
f0105b37:	72 15                	jb     f0105b4e <mp_init+0xd1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b39:	52                   	push   %edx
f0105b3a:	68 dc 64 10 f0       	push   $0xf01064dc
f0105b3f:	68 90 00 00 00       	push   $0x90
f0105b44:	68 bd 80 10 f0       	push   $0xf01080bd
f0105b49:	e8 2d a5 ff ff       	call   f010007b <_panic>
	return (void *)(pa + KERNBASE);
f0105b4e:	8d b2 00 00 00 f0    	lea    -0x10000000(%edx),%esi
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105b54:	89 f7                	mov    %esi,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105b56:	83 ec 04             	sub    $0x4,%esp
f0105b59:	6a 04                	push   $0x4
f0105b5b:	68 d2 80 10 f0       	push   $0xf01080d2
f0105b60:	56                   	push   %esi
f0105b61:	e8 af fc ff ff       	call   f0105815 <memcmp>
f0105b66:	83 c4 10             	add    $0x10,%esp
f0105b69:	85 c0                	test   %eax,%eax
f0105b6b:	74 15                	je     f0105b82 <mp_init+0x105>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105b6d:	83 ec 0c             	sub    $0xc,%esp
f0105b70:	68 60 7f 10 f0       	push   $0xf0107f60
f0105b75:	e8 8c db ff ff       	call   f0103706 <cprintf>
f0105b7a:	83 c4 10             	add    $0x10,%esp
f0105b7d:	e9 c9 01 00 00       	jmp    f0105d4b <mp_init+0x2ce>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b82:	0f b7 56 04          	movzwl 0x4(%esi),%edx
f0105b86:	89 f0                	mov    %esi,%eax
f0105b88:	e8 3b fe ff ff       	call   f01059c8 <sum>
f0105b8d:	84 c0                	test   %al,%al
f0105b8f:	74 15                	je     f0105ba6 <mp_init+0x129>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b91:	83 ec 0c             	sub    $0xc,%esp
f0105b94:	68 94 7f 10 f0       	push   $0xf0107f94
f0105b99:	e8 68 db ff ff       	call   f0103706 <cprintf>
f0105b9e:	83 c4 10             	add    $0x10,%esp
f0105ba1:	e9 a5 01 00 00       	jmp    f0105d4b <mp_init+0x2ce>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105ba6:	8a 46 06             	mov    0x6(%esi),%al
f0105ba9:	3c 01                	cmp    $0x1,%al
f0105bab:	74 1d                	je     f0105bca <mp_init+0x14d>
f0105bad:	3c 04                	cmp    $0x4,%al
f0105baf:	74 19                	je     f0105bca <mp_init+0x14d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105bb1:	83 ec 08             	sub    $0x8,%esp
f0105bb4:	0f b6 c0             	movzbl %al,%eax
f0105bb7:	50                   	push   %eax
f0105bb8:	68 b8 7f 10 f0       	push   $0xf0107fb8
f0105bbd:	e8 44 db ff ff       	call   f0103706 <cprintf>
f0105bc2:	83 c4 10             	add    $0x10,%esp
f0105bc5:	e9 81 01 00 00       	jmp    f0105d4b <mp_init+0x2ce>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105bca:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0105bce:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0105bd2:	01 f8                	add    %edi,%eax
f0105bd4:	e8 ef fd ff ff       	call   f01059c8 <sum>
f0105bd9:	02 47 2a             	add    0x2a(%edi),%al
f0105bdc:	84 c0                	test   %al,%al
f0105bde:	74 15                	je     f0105bf5 <mp_init+0x178>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105be0:	83 ec 0c             	sub    $0xc,%esp
f0105be3:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0105be8:	e8 19 db ff ff       	call   f0103706 <cprintf>
f0105bed:	83 c4 10             	add    $0x10,%esp
f0105bf0:	e9 56 01 00 00       	jmp    f0105d4b <mp_init+0x2ce>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105bf5:	85 f6                	test   %esi,%esi
f0105bf7:	0f 84 4e 01 00 00    	je     f0105d4b <mp_init+0x2ce>
		return;
	ismp = 1;
f0105bfd:	c7 05 00 00 1f f0 01 	movl   $0x1,0xf01f0000
f0105c04:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105c07:	8b 47 24             	mov    0x24(%edi),%eax
f0105c0a:	a3 00 10 23 f0       	mov    %eax,0xf0231000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c0f:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105c12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0105c19:	e9 a1 00 00 00       	jmp    f0105cbf <mp_init+0x242>
		switch (*p) {
f0105c1e:	8a 06                	mov    (%esi),%al
f0105c20:	84 c0                	test   %al,%al
f0105c22:	74 06                	je     f0105c2a <mp_init+0x1ad>
f0105c24:	3c 04                	cmp    $0x4,%al
f0105c26:	77 6f                	ja     f0105c97 <mp_init+0x21a>
f0105c28:	eb 68                	jmp    f0105c92 <mp_init+0x215>
		case MPPROC:
			proc = (struct mpproc *)p;
f0105c2a:	89 f1                	mov    %esi,%ecx
			if (proc->flags & MPPROC_BOOT)
f0105c2c:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105c30:	74 1e                	je     f0105c50 <mp_init+0x1d3>
				bootcpu = &cpus[ncpu];
f0105c32:	8b 15 c4 03 1f f0    	mov    0xf01f03c4,%edx
f0105c38:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0105c3f:	29 d0                	sub    %edx,%eax
f0105c41:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105c44:	8d 04 85 20 00 1f f0 	lea    -0xfe0ffe0(,%eax,4),%eax
f0105c4b:	a3 c0 03 1f f0       	mov    %eax,0xf01f03c0
			if (ncpu < NCPU) {
f0105c50:	8b 15 c4 03 1f f0    	mov    0xf01f03c4,%edx
f0105c56:	83 fa 07             	cmp    $0x7,%edx
f0105c59:	7f 1d                	jg     f0105c78 <mp_init+0x1fb>
				cpus[ncpu].cpu_id = ncpu;
f0105c5b:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0105c62:	29 d0                	sub    %edx,%eax
f0105c64:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105c67:	88 14 85 20 00 1f f0 	mov    %dl,-0xfe0ffe0(,%eax,4)
				ncpu++;
f0105c6e:	8d 42 01             	lea    0x1(%edx),%eax
f0105c71:	a3 c4 03 1f f0       	mov    %eax,0xf01f03c4
f0105c76:	eb 15                	jmp    f0105c8d <mp_init+0x210>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c78:	83 ec 08             	sub    $0x8,%esp
f0105c7b:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0105c7f:	50                   	push   %eax
f0105c80:	68 08 80 10 f0       	push   $0xf0108008
f0105c85:	e8 7c da ff ff       	call   f0103706 <cprintf>
f0105c8a:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c8d:	83 c6 14             	add    $0x14,%esi
f0105c90:	eb 2a                	jmp    f0105cbc <mp_init+0x23f>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c92:	83 c6 08             	add    $0x8,%esi
f0105c95:	eb 25                	jmp    f0105cbc <mp_init+0x23f>
			continue;
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c97:	83 ec 08             	sub    $0x8,%esp
f0105c9a:	0f b6 c0             	movzbl %al,%eax
f0105c9d:	50                   	push   %eax
f0105c9e:	68 30 80 10 f0       	push   $0xf0108030
f0105ca3:	e8 5e da ff ff       	call   f0103706 <cprintf>
			ismp = 0;
f0105ca8:	c7 05 00 00 1f f0 00 	movl   $0x0,0xf01f0000
f0105caf:	00 00 00 
			i = conf->entry;
f0105cb2:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105cb9:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cbc:	ff 45 f0             	incl   -0x10(%ebp)
f0105cbf:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105cc3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
f0105cc6:	0f 82 52 ff ff ff    	jb     f0105c1e <mp_init+0x1a1>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105ccc:	a1 c0 03 1f f0       	mov    0xf01f03c0,%eax
f0105cd1:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105cd8:	83 3d 00 00 1f f0 00 	cmpl   $0x0,0xf01f0000
f0105cdf:	75 26                	jne    f0105d07 <mp_init+0x28a>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105ce1:	c7 05 c4 03 1f f0 01 	movl   $0x1,0xf01f03c4
f0105ce8:	00 00 00 
		lapicaddr = 0;
f0105ceb:	c7 05 00 10 23 f0 00 	movl   $0x0,0xf0231000
f0105cf2:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105cf5:	83 ec 0c             	sub    $0xc,%esp
f0105cf8:	68 50 80 10 f0       	push   $0xf0108050
f0105cfd:	e8 04 da ff ff       	call   f0103706 <cprintf>
		return;
f0105d02:	83 c4 10             	add    $0x10,%esp
f0105d05:	eb 44                	jmp    f0105d4b <mp_init+0x2ce>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105d07:	83 ec 04             	sub    $0x4,%esp
f0105d0a:	ff 35 c4 03 1f f0    	pushl  0xf01f03c4
f0105d10:	a1 c0 03 1f f0       	mov    0xf01f03c0,%eax
f0105d15:	0f b6 00             	movzbl (%eax),%eax
f0105d18:	50                   	push   %eax
f0105d19:	68 d7 80 10 f0       	push   $0xf01080d7
f0105d1e:	e8 e3 d9 ff ff       	call   f0103706 <cprintf>

	if (mp->imcrp) {
f0105d23:	83 c4 10             	add    $0x10,%esp
f0105d26:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
f0105d2a:	74 1f                	je     f0105d4b <mp_init+0x2ce>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105d2c:	83 ec 0c             	sub    $0xc,%esp
f0105d2f:	68 7c 80 10 f0       	push   $0xf010807c
f0105d34:	e8 cd d9 ff ff       	call   f0103706 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d39:	b0 70                	mov    $0x70,%al
f0105d3b:	ba 22 00 00 00       	mov    $0x22,%edx
f0105d40:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105d41:	b2 23                	mov    $0x23,%dl
f0105d43:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105d44:	83 c8 01             	or     $0x1,%eax
f0105d47:	ee                   	out    %al,(%dx)
f0105d48:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105d4e:	5b                   	pop    %ebx
f0105d4f:	5e                   	pop    %esi
f0105d50:	5f                   	pop    %edi
f0105d51:	c9                   	leave  
f0105d52:	c3                   	ret    
	...

f0105d54 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105d54:	55                   	push   %ebp
f0105d55:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105d57:	c1 e0 02             	shl    $0x2,%eax
f0105d5a:	03 05 04 10 23 f0    	add    0xf0231004,%eax
f0105d60:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d62:	a1 04 10 23 f0       	mov    0xf0231004,%eax
f0105d67:	83 c0 20             	add    $0x20,%eax
f0105d6a:	8b 00                	mov    (%eax),%eax
}
f0105d6c:	c9                   	leave  
f0105d6d:	c3                   	ret    

f0105d6e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d6e:	55                   	push   %ebp
f0105d6f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d71:	a1 04 10 23 f0       	mov    0xf0231004,%eax
f0105d76:	85 c0                	test   %eax,%eax
f0105d78:	74 06                	je     f0105d80 <cpunum+0x12>
		return lapic[ID] >> 24;
f0105d7a:	8b 40 20             	mov    0x20(%eax),%eax
f0105d7d:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0105d80:	c9                   	leave  
f0105d81:	c3                   	ret    

f0105d82 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d82:	55                   	push   %ebp
f0105d83:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d85:	83 3d 04 10 23 f0 00 	cmpl   $0x0,0xf0231004
f0105d8c:	74 0f                	je     f0105d9d <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105d8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d93:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d98:	e8 b7 ff ff ff       	call   f0105d54 <lapicw>
}
f0105d9d:	c9                   	leave  
f0105d9e:	c3                   	ret    

f0105d9f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0105d9f:	55                   	push   %ebp
f0105da0:	89 e5                	mov    %esp,%ebp
}
f0105da2:	c9                   	leave  
f0105da3:	c3                   	ret    

f0105da4 <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0105da4:	55                   	push   %ebp
f0105da5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105da7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105daa:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105db0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105db5:	e8 9a ff ff ff       	call   f0105d54 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105dba:	8b 15 04 10 23 f0    	mov    0xf0231004,%edx
f0105dc0:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105dc6:	8b 02                	mov    (%edx),%eax
f0105dc8:	f6 c4 10             	test   $0x10,%ah
f0105dcb:	75 f9                	jne    f0105dc6 <lapic_ipi+0x22>
		;
}
f0105dcd:	c9                   	leave  
f0105dce:	c3                   	ret    

f0105dcf <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105dcf:	55                   	push   %ebp
f0105dd0:	89 e5                	mov    %esp,%ebp
f0105dd2:	83 ec 08             	sub    $0x8,%esp
	if (!lapicaddr)
f0105dd5:	a1 00 10 23 f0       	mov    0xf0231000,%eax
f0105dda:	85 c0                	test   %eax,%eax
f0105ddc:	0f 84 2c 01 00 00    	je     f0105f0e <lapic_init+0x13f>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105de2:	83 ec 08             	sub    $0x8,%esp
f0105de5:	68 00 10 00 00       	push   $0x1000
f0105dea:	50                   	push   %eax
f0105deb:	e8 bf b2 ff ff       	call   f01010af <mmio_map_region>
f0105df0:	a3 04 10 23 f0       	mov    %eax,0xf0231004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105df5:	ba 27 01 00 00       	mov    $0x127,%edx
f0105dfa:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105dff:	e8 50 ff ff ff       	call   f0105d54 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105e04:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105e09:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105e0e:	e8 41 ff ff ff       	call   f0105d54 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105e13:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105e18:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105e1d:	e8 32 ff ff ff       	call   f0105d54 <lapicw>
	lapicw(TICR, 10000000); 
f0105e22:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105e27:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105e2c:	e8 23 ff ff ff       	call   f0105d54 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105e31:	e8 38 ff ff ff       	call   f0105d6e <cpunum>
f0105e36:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105e3d:	29 c2                	sub    %eax,%edx
f0105e3f:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105e42:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
f0105e49:	83 c4 10             	add    $0x10,%esp
f0105e4c:	3b 15 c0 03 1f f0    	cmp    0xf01f03c0,%edx
f0105e52:	74 0f                	je     f0105e63 <lapic_init+0x94>
		lapicw(LINT0, MASKED);
f0105e54:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e59:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105e5e:	e8 f1 fe ff ff       	call   f0105d54 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105e63:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e68:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105e6d:	e8 e2 fe ff ff       	call   f0105d54 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105e72:	a1 04 10 23 f0       	mov    0xf0231004,%eax
f0105e77:	83 c0 30             	add    $0x30,%eax
f0105e7a:	8b 00                	mov    (%eax),%eax
f0105e7c:	c1 e8 10             	shr    $0x10,%eax
f0105e7f:	3c 03                	cmp    $0x3,%al
f0105e81:	76 0f                	jbe    f0105e92 <lapic_init+0xc3>
		lapicw(PCINT, MASKED);
f0105e83:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e88:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105e8d:	e8 c2 fe ff ff       	call   f0105d54 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105e92:	ba 33 00 00 00       	mov    $0x33,%edx
f0105e97:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105e9c:	e8 b3 fe ff ff       	call   f0105d54 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105ea1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ea6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105eab:	e8 a4 fe ff ff       	call   f0105d54 <lapicw>
	lapicw(ESR, 0);
f0105eb0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105eb5:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105eba:	e8 95 fe ff ff       	call   f0105d54 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105ebf:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec4:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105ec9:	e8 86 fe ff ff       	call   f0105d54 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105ece:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ed8:	e8 77 fe ff ff       	call   f0105d54 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105edd:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105ee2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee7:	e8 68 fe ff ff       	call   f0105d54 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105eec:	8b 15 04 10 23 f0    	mov    0xf0231004,%edx
f0105ef2:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105ef8:	8b 02                	mov    (%edx),%eax
f0105efa:	f6 c4 10             	test   $0x10,%ah
f0105efd:	75 f9                	jne    f0105ef8 <lapic_init+0x129>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105eff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f04:	b8 20 00 00 00       	mov    $0x20,%eax
f0105f09:	e8 46 fe ff ff       	call   f0105d54 <lapicw>
}
f0105f0e:	c9                   	leave  
f0105f0f:	c3                   	ret    

f0105f10 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105f10:	55                   	push   %ebp
f0105f11:	89 e5                	mov    %esp,%ebp
f0105f13:	57                   	push   %edi
f0105f14:	56                   	push   %esi
f0105f15:	53                   	push   %ebx
f0105f16:	83 ec 0c             	sub    $0xc,%esp
f0105f19:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f1c:	8a 4d 08             	mov    0x8(%ebp),%cl
f0105f1f:	b0 0f                	mov    $0xf,%al
f0105f21:	ba 70 00 00 00       	mov    $0x70,%edx
f0105f26:	ee                   	out    %al,(%dx)
f0105f27:	b0 0a                	mov    $0xa,%al
f0105f29:	b2 71                	mov    $0x71,%dl
f0105f2b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f2c:	83 3d 88 fe 1e f0 00 	cmpl   $0x0,0xf01efe88
f0105f33:	75 19                	jne    f0105f4e <lapic_startap+0x3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f35:	68 67 04 00 00       	push   $0x467
f0105f3a:	68 dc 64 10 f0       	push   $0xf01064dc
f0105f3f:	68 98 00 00 00       	push   $0x98
f0105f44:	68 f4 80 10 f0       	push   $0xf01080f4
f0105f49:	e8 2d a1 ff ff       	call   f010007b <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105f4e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105f55:	00 00 
	wrv[1] = addr >> 4;
f0105f57:	89 f0                	mov    %esi,%eax
f0105f59:	c1 e8 04             	shr    $0x4,%eax
f0105f5c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105f62:	89 cf                	mov    %ecx,%edi
f0105f64:	c1 e7 18             	shl    $0x18,%edi
f0105f67:	89 fa                	mov    %edi,%edx
f0105f69:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f6e:	e8 e1 fd ff ff       	call   f0105d54 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f73:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f78:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f7d:	e8 d2 fd ff ff       	call   f0105d54 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f82:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f87:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f8c:	e8 c3 fd ff ff       	call   f0105d54 <lapicw>
f0105f91:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105f96:	89 f0                	mov    %esi,%eax
f0105f98:	c1 e8 0c             	shr    $0xc,%eax
f0105f9b:	89 c6                	mov    %eax,%esi
f0105f9d:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105fa3:	89 fa                	mov    %edi,%edx
f0105fa5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105faa:	e8 a5 fd ff ff       	call   f0105d54 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105faf:	89 f2                	mov    %esi,%edx
f0105fb1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105fb6:	e8 99 fd ff ff       	call   f0105d54 <lapicw>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f0105fbb:	43                   	inc    %ebx
f0105fbc:	83 fb 02             	cmp    $0x2,%ebx
f0105fbf:	75 e2                	jne    f0105fa3 <lapic_startap+0x93>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f0105fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fc4:	5b                   	pop    %ebx
f0105fc5:	5e                   	pop    %esi
f0105fc6:	5f                   	pop    %edi
f0105fc7:	c9                   	leave  
f0105fc8:	c3                   	ret    
f0105fc9:	00 00                	add    %al,(%eax)
	...

f0105fcc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105fcc:	55                   	push   %ebp
f0105fcd:	89 e5                	mov    %esp,%ebp
f0105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105fd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105fd8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fdb:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105fde:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105fe5:	c9                   	leave  
f0105fe6:	c3                   	ret    

f0105fe7 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0105fe7:	55                   	push   %ebp
f0105fe8:	89 e5                	mov    %esp,%ebp
f0105fea:	53                   	push   %ebx
f0105feb:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0105fee:	83 38 00             	cmpl   $0x0,(%eax)
f0105ff1:	75 07                	jne    f0105ffa <holding+0x13>
f0105ff3:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ff8:	eb 23                	jmp    f010601d <holding+0x36>
f0105ffa:	8b 58 08             	mov    0x8(%eax),%ebx
f0105ffd:	e8 6c fd ff ff       	call   f0105d6e <cpunum>
f0106002:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106009:	29 c2                	sub    %eax,%edx
f010600b:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010600e:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
f0106015:	39 d3                	cmp    %edx,%ebx
f0106017:	0f 94 c0             	sete   %al
f010601a:	0f b6 c0             	movzbl %al,%eax
}
f010601d:	83 c4 04             	add    $0x4,%esp
f0106020:	5b                   	pop    %ebx
f0106021:	c9                   	leave  
f0106022:	c3                   	ret    

f0106023 <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106023:	55                   	push   %ebp
f0106024:	89 e5                	mov    %esp,%ebp
f0106026:	57                   	push   %edi
f0106027:	56                   	push   %esi
f0106028:	53                   	push   %ebx
f0106029:	83 ec 4c             	sub    $0x4c,%esp
f010602c:	8b 75 08             	mov    0x8(%ebp),%esi
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010602f:	89 f0                	mov    %esi,%eax
f0106031:	e8 b1 ff ff ff       	call   f0105fe7 <holding>
f0106036:	85 c0                	test   %eax,%eax
f0106038:	0f 85 b1 00 00 00    	jne    f01060ef <spin_unlock+0xcc>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010603e:	8d 46 0c             	lea    0xc(%esi),%eax
f0106041:	83 ec 04             	sub    $0x4,%esp
f0106044:	6a 28                	push   $0x28
f0106046:	50                   	push   %eax
f0106047:	8d 45 b4             	lea    -0x4c(%ebp),%eax
f010604a:	50                   	push   %eax
f010604b:	e8 44 f7 ff ff       	call   f0105794 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106050:	8b 46 08             	mov    0x8(%esi),%eax
f0106053:	8a 18                	mov    (%eax),%bl
f0106055:	8b 76 04             	mov    0x4(%esi),%esi
f0106058:	e8 11 fd ff ff       	call   f0105d6e <cpunum>
f010605d:	0f b6 db             	movzbl %bl,%ebx
f0106060:	53                   	push   %ebx
f0106061:	56                   	push   %esi
f0106062:	50                   	push   %eax
f0106063:	68 04 81 10 f0       	push   $0xf0108104
f0106068:	e8 99 d6 ff ff       	call   f0103706 <cprintf>
f010606d:	be 01 00 00 00       	mov    $0x1,%esi
f0106072:	83 c4 20             	add    $0x20,%esp
f0106075:	8d 7d b4             	lea    -0x4c(%ebp),%edi
f0106078:	eb 57                	jmp    f01060d1 <spin_unlock+0xae>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010607a:	83 ec 08             	sub    $0x8,%esp
f010607d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106080:	50                   	push   %eax
f0106081:	52                   	push   %edx
f0106082:	e8 b9 ed ff ff       	call   f0104e40 <debuginfo_eip>
f0106087:	83 c4 10             	add    $0x10,%esp
f010608a:	85 c0                	test   %eax,%eax
f010608c:	78 29                	js     f01060b7 <spin_unlock+0x94>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010608e:	8b 54 9f fc          	mov    -0x4(%edi,%ebx,4),%edx
f0106092:	83 ec 04             	sub    $0x4,%esp
f0106095:	89 d0                	mov    %edx,%eax
f0106097:	2b 45 ec             	sub    -0x14(%ebp),%eax
f010609a:	50                   	push   %eax
f010609b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010609e:	ff 75 e8             	pushl  -0x18(%ebp)
f01060a1:	ff 75 e0             	pushl  -0x20(%ebp)
f01060a4:	ff 75 dc             	pushl  -0x24(%ebp)
f01060a7:	52                   	push   %edx
f01060a8:	68 68 81 10 f0       	push   $0xf0108168
f01060ad:	e8 54 d6 ff ff       	call   f0103706 <cprintf>
f01060b2:	83 c4 20             	add    $0x20,%esp
f01060b5:	eb 14                	jmp    f01060cb <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01060b7:	83 ec 08             	sub    $0x8,%esp
f01060ba:	ff 74 9f fc          	pushl  -0x4(%edi,%ebx,4)
f01060be:	68 7f 81 10 f0       	push   $0xf010817f
f01060c3:	e8 3e d6 ff ff       	call   f0103706 <cprintf>
f01060c8:	83 c4 10             	add    $0x10,%esp
f01060cb:	46                   	inc    %esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060cc:	83 fe 0b             	cmp    $0xb,%esi
f01060cf:	74 0a                	je     f01060db <spin_unlock+0xb8>
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01060d1:	89 f3                	mov    %esi,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060d3:	8b 54 b7 fc          	mov    -0x4(%edi,%esi,4),%edx
f01060d7:	85 d2                	test   %edx,%edx
f01060d9:	75 9f                	jne    f010607a <spin_unlock+0x57>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01060db:	83 ec 04             	sub    $0x4,%esp
f01060de:	68 87 81 10 f0       	push   $0xf0108187
f01060e3:	6a 67                	push   $0x67
f01060e5:	68 93 81 10 f0       	push   $0xf0108193
f01060ea:	e8 8c 9f ff ff       	call   f010007b <_panic>
	}

	lk->pcs[0] = 0;
f01060ef:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060f6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01060fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0106102:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106105:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106108:	5b                   	pop    %ebx
f0106109:	5e                   	pop    %esi
f010610a:	5f                   	pop    %edi
f010610b:	c9                   	leave  
f010610c:	c3                   	ret    

f010610d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010610d:	55                   	push   %ebp
f010610e:	89 e5                	mov    %esp,%ebp
f0106110:	56                   	push   %esi
f0106111:	53                   	push   %ebx
f0106112:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106115:	89 d8                	mov    %ebx,%eax
f0106117:	e8 cb fe ff ff       	call   f0105fe7 <holding>
f010611c:	85 c0                	test   %eax,%eax
f010611e:	74 20                	je     f0106140 <spin_lock+0x33>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106120:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106123:	e8 46 fc ff ff       	call   f0105d6e <cpunum>
f0106128:	83 ec 0c             	sub    $0xc,%esp
f010612b:	53                   	push   %ebx
f010612c:	50                   	push   %eax
f010612d:	68 3c 81 10 f0       	push   $0xf010813c
f0106132:	6a 41                	push   $0x41
f0106134:	68 93 81 10 f0       	push   $0xf0108193
f0106139:	e8 3d 9f ff ff       	call   f010007b <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010613e:	f3 90                	pause  
f0106140:	b8 01 00 00 00       	mov    $0x1,%eax
f0106145:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106148:	85 c0                	test   %eax,%eax
f010614a:	75 f2                	jne    f010613e <spin_lock+0x31>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010614c:	e8 1d fc ff ff       	call   f0105d6e <cpunum>
f0106151:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106158:	29 c2                	sub    %eax,%edx
f010615a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010615d:	8d 14 95 20 00 1f f0 	lea    -0xfe0ffe0(,%edx,4),%edx
f0106164:	89 53 08             	mov    %edx,0x8(%ebx)
f0106167:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010616a:	89 ea                	mov    %ebp,%edx
f010616c:	89 f1                	mov    %esi,%ecx
f010616e:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106173:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106179:	76 14                	jbe    f010618f <spin_lock+0x82>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010617b:	8b 42 04             	mov    0x4(%edx),%eax
f010617e:	89 01                	mov    %eax,(%ecx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106180:	8b 02                	mov    (%edx),%eax
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106182:	43                   	inc    %ebx
f0106183:	83 c1 04             	add    $0x4,%ecx
f0106186:	83 fb 0a             	cmp    $0xa,%ebx
f0106189:	74 16                	je     f01061a1 <spin_lock+0x94>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010618b:	89 c2                	mov    %eax,%edx
f010618d:	eb e4                	jmp    f0106173 <spin_lock+0x66>
f010618f:	8d 04 9e             	lea    (%esi,%ebx,4),%eax
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106192:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106198:	43                   	inc    %ebx
f0106199:	83 c0 04             	add    $0x4,%eax
f010619c:	83 fb 09             	cmp    $0x9,%ebx
f010619f:	7e f1                	jle    f0106192 <spin_lock+0x85>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01061a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01061a4:	5b                   	pop    %ebx
f01061a5:	5e                   	pop    %esi
f01061a6:	c9                   	leave  
f01061a7:	c3                   	ret    

f01061a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01061a8:	55                   	push   %ebp
f01061a9:	89 e5                	mov    %esp,%ebp
f01061ab:	57                   	push   %edi
f01061ac:	56                   	push   %esi
f01061ad:	83 ec 28             	sub    $0x28,%esp
f01061b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01061b7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01061be:	8b 45 10             	mov    0x10(%ebp),%eax
f01061c1:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f01061c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01061c7:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
f01061c9:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
f01061cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
f01061d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061d4:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01061d7:	85 ff                	test   %edi,%edi
f01061d9:	75 21                	jne    f01061fc <__udivdi3+0x54>
    {
      if (d0 > n1)
f01061db:	39 d1                	cmp    %edx,%ecx
f01061dd:	76 49                	jbe    f0106228 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01061df:	f7 f1                	div    %ecx
f01061e1:	89 c1                	mov    %eax,%ecx
f01061e3:	31 c0                	xor    %eax,%eax
f01061e5:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01061e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01061eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f01061ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01061f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01061f4:	83 c4 28             	add    $0x28,%esp
f01061f7:	5e                   	pop    %esi
f01061f8:	5f                   	pop    %edi
f01061f9:	c9                   	leave  
f01061fa:	c3                   	ret    
f01061fb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f01061fc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
f01061ff:	0f 87 97 00 00 00    	ja     f010629c <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106205:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
f0106208:	83 f0 1f             	xor    $0x1f,%eax
f010620b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010620e:	75 34                	jne    f0106244 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106210:	3b 7d e8             	cmp    -0x18(%ebp),%edi
f0106213:	72 08                	jb     f010621d <__udivdi3+0x75>
f0106215:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106218:	39 55 f4             	cmp    %edx,-0xc(%ebp)
f010621b:	77 7f                	ja     f010629c <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010621d:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106222:	31 c0                	xor    %eax,%eax
f0106224:	eb c2                	jmp    f01061e8 <__udivdi3+0x40>
f0106226:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106228:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010622b:	85 c0                	test   %eax,%eax
f010622d:	74 79                	je     f01062a8 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010622f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106232:	89 fa                	mov    %edi,%edx
f0106234:	f7 f1                	div    %ecx
f0106236:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106238:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010623b:	f7 f1                	div    %ecx
f010623d:	89 c1                	mov    %eax,%ecx
f010623f:	89 f0                	mov    %esi,%eax
f0106241:	eb a5                	jmp    f01061e8 <__udivdi3+0x40>
f0106243:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106244:	b8 20 00 00 00       	mov    $0x20,%eax
f0106249:	2b 45 e4             	sub    -0x1c(%ebp),%eax
f010624c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010624f:	89 fa                	mov    %edi,%edx
f0106251:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f0106254:	d3 e2                	shl    %cl,%edx
f0106256:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106259:	8a 4d f0             	mov    -0x10(%ebp),%cl
f010625c:	d3 e8                	shr    %cl,%eax
f010625e:	89 d7                	mov    %edx,%edi
f0106260:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
f0106262:	8b 75 f4             	mov    -0xc(%ebp),%esi
f0106265:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f0106268:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f010626a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010626d:	d3 e0                	shl    %cl,%eax
f010626f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0106272:	8a 4d f0             	mov    -0x10(%ebp),%cl
f0106275:	d3 ea                	shr    %cl,%edx
f0106277:	09 d0                	or     %edx,%eax
f0106279:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010627c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010627f:	d3 ea                	shr    %cl,%edx
f0106281:	f7 f7                	div    %edi
f0106283:	89 d7                	mov    %edx,%edi
f0106285:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
f0106288:	f7 e6                	mul    %esi
f010628a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010628c:	39 d7                	cmp    %edx,%edi
f010628e:	72 38                	jb     f01062c8 <__udivdi3+0x120>
f0106290:	74 27                	je     f01062b9 <__udivdi3+0x111>
f0106292:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106295:	31 c0                	xor    %eax,%eax
f0106297:	e9 4c ff ff ff       	jmp    f01061e8 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f010629c:	31 c9                	xor    %ecx,%ecx
f010629e:	31 c0                	xor    %eax,%eax
f01062a0:	e9 43 ff ff ff       	jmp    f01061e8 <__udivdi3+0x40>
f01062a5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01062a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01062ad:	31 d2                	xor    %edx,%edx
f01062af:	f7 75 f4             	divl   -0xc(%ebp)
f01062b2:	89 c1                	mov    %eax,%ecx
f01062b4:	e9 76 ff ff ff       	jmp    f010622f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01062b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01062bc:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f01062bf:	d3 e0                	shl    %cl,%eax
f01062c1:	39 f0                	cmp    %esi,%eax
f01062c3:	73 cd                	jae    f0106292 <__udivdi3+0xea>
f01062c5:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01062c8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01062cb:	49                   	dec    %ecx
f01062cc:	31 c0                	xor    %eax,%eax
f01062ce:	e9 15 ff ff ff       	jmp    f01061e8 <__udivdi3+0x40>
	...

f01062d4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01062d4:	55                   	push   %ebp
f01062d5:	89 e5                	mov    %esp,%ebp
f01062d7:	57                   	push   %edi
f01062d8:	56                   	push   %esi
f01062d9:	83 ec 30             	sub    $0x30,%esp
f01062dc:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01062e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01062ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01062ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01062f0:	8b 45 10             	mov    0x10(%ebp),%eax
f01062f3:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
f01062f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01062f9:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
f01062fb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
f01062fe:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
f0106301:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106304:	85 d2                	test   %edx,%edx
f0106306:	75 1c                	jne    f0106324 <__umoddi3+0x50>
    {
      if (d0 > n1)
f0106308:	89 fa                	mov    %edi,%edx
f010630a:	39 f8                	cmp    %edi,%eax
f010630c:	0f 86 c2 00 00 00    	jbe    f01063d4 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106312:	89 f0                	mov    %esi,%eax
f0106314:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
f0106316:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
f0106319:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0106320:	eb 12                	jmp    f0106334 <__umoddi3+0x60>
f0106322:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106324:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106327:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
f010632a:	76 18                	jbe    f0106344 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
f010632c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
f010632f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0106332:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106334:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0106337:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010633a:	83 c4 30             	add    $0x30,%esp
f010633d:	5e                   	pop    %esi
f010633e:	5f                   	pop    %edi
f010633f:	c9                   	leave  
f0106340:	c3                   	ret    
f0106341:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106344:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
f0106348:	83 f0 1f             	xor    $0x1f,%eax
f010634b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010634e:	0f 84 ac 00 00 00    	je     f0106400 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106354:	b8 20 00 00 00       	mov    $0x20,%eax
f0106359:	2b 45 dc             	sub    -0x24(%ebp),%eax
f010635c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010635f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106362:	8a 4d dc             	mov    -0x24(%ebp),%cl
f0106365:	d3 e2                	shl    %cl,%edx
f0106367:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010636a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f010636d:	d3 e8                	shr    %cl,%eax
f010636f:	89 d6                	mov    %edx,%esi
f0106371:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
f0106373:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106376:	8a 4d dc             	mov    -0x24(%ebp),%cl
f0106379:	d3 e0                	shl    %cl,%eax
f010637b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f010637e:	8b 7d f4             	mov    -0xc(%ebp),%edi
f0106381:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106383:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106386:	d3 e0                	shl    %cl,%eax
f0106388:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010638b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f010638e:	d3 ea                	shr    %cl,%edx
f0106390:	09 d0                	or     %edx,%eax
f0106392:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106395:	d3 ea                	shr    %cl,%edx
f0106397:	f7 f6                	div    %esi
f0106399:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
f010639c:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010639f:	39 55 f0             	cmp    %edx,-0x10(%ebp)
f01063a2:	0f 82 8d 00 00 00    	jb     f0106435 <__umoddi3+0x161>
f01063a8:	0f 84 91 00 00 00    	je     f010643f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01063ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
f01063b1:	29 c7                	sub    %eax,%edi
f01063b3:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01063b5:	89 f2                	mov    %esi,%edx
f01063b7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
f01063ba:	d3 e2                	shl    %cl,%edx
f01063bc:	89 f8                	mov    %edi,%eax
f01063be:	8a 4d dc             	mov    -0x24(%ebp),%cl
f01063c1:	d3 e8                	shr    %cl,%eax
f01063c3:	09 c2                	or     %eax,%edx
f01063c5:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
f01063c8:	d3 ee                	shr    %cl,%esi
f01063ca:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01063cd:	e9 62 ff ff ff       	jmp    f0106334 <__umoddi3+0x60>
f01063d2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01063d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01063d7:	85 c0                	test   %eax,%eax
f01063d9:	74 15                	je     f01063f0 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01063db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01063de:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01063e1:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01063e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01063e6:	f7 f1                	div    %ecx
f01063e8:	e9 29 ff ff ff       	jmp    f0106316 <__umoddi3+0x42>
f01063ed:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01063f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01063f5:	31 d2                	xor    %edx,%edx
f01063f7:	f7 75 ec             	divl   -0x14(%ebp)
f01063fa:	89 c1                	mov    %eax,%ecx
f01063fc:	eb dd                	jmp    f01063db <__umoddi3+0x107>
f01063fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106400:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106403:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0106406:	72 19                	jb     f0106421 <__umoddi3+0x14d>
f0106408:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010640b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
f010640e:	76 11                	jbe    f0106421 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
f0106410:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106413:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
f0106416:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106419:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010641c:	e9 13 ff ff ff       	jmp    f0106334 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106424:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106427:	2b 45 ec             	sub    -0x14(%ebp),%eax
f010642a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
f010642d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106430:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0106433:	eb db                	jmp    f0106410 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106435:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0106438:	19 f2                	sbb    %esi,%edx
f010643a:	e9 6f ff ff ff       	jmp    f01063ae <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010643f:	39 c7                	cmp    %eax,%edi
f0106441:	72 f2                	jb     f0106435 <__umoddi3+0x161>
f0106443:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106446:	e9 63 ff ff ff       	jmp    f01063ae <__umoddi3+0xda>
