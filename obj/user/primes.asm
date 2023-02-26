
obj/user/primes.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 cf 00 00 00       	call   800100 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	83 ec 04             	sub    $0x4,%esp
  80003f:	6a 00                	push   $0x0
  800041:	6a 00                	push   $0x0
  800043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800046:	50                   	push   %eax
  800047:	e8 16 10 00 00       	call   801062 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 20 14 80 00       	push   $0x801420
  800060:	e8 a0 01 00 00       	call   800205 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 e0 0c 00 00       	call   800d4a <fork>
  80006a:	89 c6                	mov    %eax,%esi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x51>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 2c 14 80 00       	push   $0x80142c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 35 14 80 00       	push   $0x801435
  800080:	e8 df 00 00 00       	call   800164 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b3                	je     80003c <primeproc+0x8>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	83 ec 04             	sub    $0x4,%esp
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800093:	50                   	push   %eax
  800094:	e8 c9 0f 00 00       	call   801062 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e4                	je     800089 <primeproc+0x55>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	56                   	push   %esi
  8000ab:	e8 5d 0f 00 00       	call   80100d <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d4                	jmp    800089 <primeproc+0x55>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 8b 0c 00 00       	call   800d4a <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 2c 14 80 00       	push   $0x80142c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 35 14 80 00       	push   $0x801435
  8000d2:	e8 8d 00 00 00       	call   800164 <_panic>
	if (id == 0)
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	74 07                	je     8000e2 <umain+0x2d>
  8000db:	bb 02 00 00 00       	mov    $0x2,%ebx
  8000e0:	eb 0a                	jmp    8000ec <umain+0x37>
		primeproc();
  8000e2:	e8 4d ff ff ff       	call   800034 <primeproc>
  8000e7:	bb 02 00 00 00       	mov    $0x2,%ebx

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000ec:	6a 00                	push   $0x0
  8000ee:	6a 00                	push   $0x0
  8000f0:	53                   	push   %ebx
  8000f1:	56                   	push   %esi
  8000f2:	e8 16 0f 00 00       	call   80100d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f7:	43                   	inc    %ebx
		ipc_send(id, i, 0, 0);
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	eb ef                	jmp    8000ec <umain+0x37>
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 75 08             	mov    0x8(%ebp),%esi
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80010b:	e8 bf 0b 00 00       	call   800ccf <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011c:	c1 e0 07             	shl    $0x7,%eax
  80011f:	29 d0                	sub    %edx,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x36>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	53                   	push   %ebx
  80013a:	56                   	push   %esi
  80013b:	e8 75 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800140:	e8 0b 00 00 00       	call   800150 <exit>
  800145:	83 c4 10             	add    $0x10,%esp
}
  800148:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800156:	6a 00                	push   $0x0
  800158:	e8 91 0b 00 00       	call   800cee <sys_env_destroy>
  80015d:	83 c4 10             	add    $0x10,%esp
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80016b:	8d 45 14             	lea    0x14(%ebp),%eax
  80016e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800171:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800177:	e8 53 0b 00 00       	call   800ccf <sys_getenvid>
  80017c:	83 ec 0c             	sub    $0xc,%esp
  80017f:	ff 75 0c             	pushl  0xc(%ebp)
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	53                   	push   %ebx
  800186:	50                   	push   %eax
  800187:	68 50 14 80 00       	push   $0x801450
  80018c:	e8 74 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800191:	83 c4 18             	add    $0x18,%esp
  800194:	ff 75 f8             	pushl  -0x8(%ebp)
  800197:	ff 75 10             	pushl  0x10(%ebp)
  80019a:	e8 15 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  80019f:	c7 04 24 e7 17 80 00 	movl   $0x8017e7,(%esp)
  8001a6:	e8 5a 00 00 00       	call   800205 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ae:	cc                   	int3   
  8001af:	eb fd                	jmp    8001ae <_panic+0x4a>
  8001b1:	00 00                	add    %al,(%eax)
	...

008001b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 1c 02 80 00       	push   $0x80021c
  8001e3:	e8 70 01 00 00       	call   800358 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001f1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 9e 08 00 00       	call   800a9b <sys_cputs>
  8001fd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80020e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9a ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 04             	sub    $0x4,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800226:	8b 03                	mov    (%ebx),%eax
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022f:	40                   	inc    %eax
  800230:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800232:	3d ff 00 00 00       	cmp    $0xff,%eax
  800237:	75 1a                	jne    800253 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	68 ff 00 00 00       	push   $0xff
  800241:	8d 43 08             	lea    0x8(%ebx),%eax
  800244:	50                   	push   %eax
  800245:	e8 51 08 00 00       	call   800a9b <sys_cputs>
		b->idx = 0;
  80024a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800250:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800253:	ff 43 04             	incl   0x4(%ebx)
}
  800256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800259:	c9                   	leave  
  80025a:	c3                   	ret    
	...

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 1c             	sub    $0x1c,%esp
  800265:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800268:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800271:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800274:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800277:	8b 55 10             	mov    0x10(%ebp),%edx
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027d:	89 d6                	mov    %edx,%esi
  80027f:	bf 00 00 00 00       	mov    $0x0,%edi
  800284:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800287:	72 04                	jb     80028d <printnum+0x31>
  800289:	39 c2                	cmp    %eax,%edx
  80028b:	77 3f                	ja     8002cc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800296:	50                   	push   %eax
  800297:	52                   	push   %edx
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	e8 cc 0e 00 00       	call   801174 <__udivdi3>
  8002a8:	83 c4 18             	add    $0x18,%esp
  8002ab:	52                   	push   %edx
  8002ac:	50                   	push   %eax
  8002ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8002b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002b3:	e8 a4 ff ff ff       	call   80025c <printnum>
  8002b8:	83 c4 20             	add    $0x20,%esp
  8002bb:	eb 14                	jmp    8002d1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	ff 75 e8             	pushl  -0x18(%ebp)
  8002c3:	ff 75 18             	pushl  0x18(%ebp)
  8002c6:	ff 55 ec             	call   *-0x14(%ebp)
  8002c9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cc:	4b                   	dec    %ebx
  8002cd:	85 db                	test   %ebx,%ebx
  8002cf:	7f ec                	jg     8002bd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 e8             	pushl  -0x18(%ebp)
  8002d7:	83 ec 04             	sub    $0x4,%esp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002df:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e2:	e8 b9 0f 00 00       	call   8012a0 <__umoddi3>
  8002e7:	83 c4 14             	add    $0x14,%esp
  8002ea:	0f be 80 73 14 80 00 	movsbl 0x801473(%eax),%eax
  8002f1:	50                   	push   %eax
  8002f2:	ff 55 ec             	call   *-0x14(%ebp)
  8002f5:	83 c4 10             	add    $0x10,%esp
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800305:	83 fa 01             	cmp    $0x1,%edx
  800308:	7e 0e                	jle    800318 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 42 08             	lea    0x8(%edx),%eax
  80030f:	89 01                	mov    %eax,(%ecx)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	8b 52 04             	mov    0x4(%edx),%edx
  800316:	eb 22                	jmp    80033a <getuint+0x3a>
	else if (lflag)
  800318:	85 d2                	test   %edx,%edx
  80031a:	74 10                	je     80032c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 42 04             	lea    0x4(%edx),%eax
  800321:	89 01                	mov    %eax,(%ecx)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
  80032a:	eb 0e                	jmp    80033a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80032c:	8b 10                	mov    (%eax),%edx
  80032e:	8d 42 04             	lea    0x4(%edx),%eax
  800331:	89 01                	mov    %eax,(%ecx)
  800333:	8b 02                	mov    (%edx),%eax
  800335:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800342:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800345:	8b 11                	mov    (%ecx),%edx
  800347:	3b 51 04             	cmp    0x4(%ecx),%edx
  80034a:	73 0a                	jae    800356 <sprintputch+0x1a>
		*b->buf++ = ch;
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	88 02                	mov    %al,(%edx)
  800351:	8d 42 01             	lea    0x1(%edx),%eax
  800354:	89 01                	mov    %eax,(%ecx)
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
  80035e:	83 ec 3c             	sub    $0x3c,%esp
  800361:	8b 75 08             	mov    0x8(%ebp),%esi
  800364:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036a:	eb 1a                	jmp    800386 <vprintfmt+0x2e>
  80036c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80036f:	eb 15                	jmp    800386 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800371:	84 c0                	test   %al,%al
  800373:	0f 84 15 03 00 00    	je     80068e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	57                   	push   %edi
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	50                   	push   %eax
  800381:	ff d6                	call   *%esi
  800383:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800386:	8a 03                	mov    (%ebx),%al
  800388:	43                   	inc    %ebx
  800389:	3c 25                	cmp    $0x25,%al
  80038b:	75 e4                	jne    800371 <vprintfmt+0x19>
  80038d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800394:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8003ad:	eb 0a                	jmp    8003b9 <vprintfmt+0x61>
  8003af:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8003b6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8a 03                	mov    (%ebx),%al
  8003bb:	0f b6 d0             	movzbl %al,%edx
  8003be:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8003c1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8003c4:	83 e8 23             	sub    $0x23,%eax
  8003c7:	3c 55                	cmp    $0x55,%al
  8003c9:	0f 87 9c 02 00 00    	ja     80066b <vprintfmt+0x313>
  8003cf:	0f b6 c0             	movzbl %al,%eax
  8003d2:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  8003d9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8003dd:	eb d7                	jmp    8003b6 <vprintfmt+0x5e>
  8003df:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8003e3:	eb d1                	jmp    8003b6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8003e5:	89 d9                	mov    %ebx,%ecx
  8003e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003f1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003f4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003fb:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003ff:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800400:	8d 42 d0             	lea    -0x30(%edx),%eax
  800403:	83 f8 09             	cmp    $0x9,%eax
  800406:	77 21                	ja     800429 <vprintfmt+0xd1>
  800408:	eb e4                	jmp    8003ee <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040a:	8b 55 14             	mov    0x14(%ebp),%edx
  80040d:	8d 42 04             	lea    0x4(%edx),%eax
  800410:	89 45 14             	mov    %eax,0x14(%ebp)
  800413:	8b 12                	mov    (%edx),%edx
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800418:	eb 12                	jmp    80042c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80041a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041e:	79 96                	jns    8003b6 <vprintfmt+0x5e>
  800420:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800427:	eb 8d                	jmp    8003b6 <vprintfmt+0x5e>
  800429:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800430:	79 84                	jns    8003b6 <vprintfmt+0x5e>
  800432:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800435:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800438:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80043f:	e9 72 ff ff ff       	jmp    8003b6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800444:	ff 45 d4             	incl   -0x2c(%ebp)
  800447:	e9 6a ff ff ff       	jmp    8003b6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044c:	8b 55 14             	mov    0x14(%ebp),%edx
  80044f:	8d 42 04             	lea    0x4(%edx),%eax
  800452:	89 45 14             	mov    %eax,0x14(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	57                   	push   %edi
  800459:	ff 32                	pushl  (%edx)
  80045b:	ff d6                	call   *%esi
			break;
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	e9 07 ff ff ff       	jmp    80036c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800465:	8b 55 14             	mov    0x14(%ebp),%edx
  800468:	8d 42 04             	lea    0x4(%edx),%eax
  80046b:	89 45 14             	mov    %eax,0x14(%ebp)
  80046e:	8b 02                	mov    (%edx),%eax
  800470:	85 c0                	test   %eax,%eax
  800472:	79 02                	jns    800476 <vprintfmt+0x11e>
  800474:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800476:	83 f8 0f             	cmp    $0xf,%eax
  800479:	7f 0b                	jg     800486 <vprintfmt+0x12e>
  80047b:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	75 15                	jne    80049b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800486:	50                   	push   %eax
  800487:	68 84 14 80 00       	push   $0x801484
  80048c:	57                   	push   %edi
  80048d:	56                   	push   %esi
  80048e:	e8 6e 02 00 00       	call   800701 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	e9 d1 fe ff ff       	jmp    80036c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 8d 14 80 00       	push   $0x80148d
  8004a1:	57                   	push   %edi
  8004a2:	56                   	push   %esi
  8004a3:	e8 59 02 00 00       	call   800701 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 bc fe ff ff       	jmp    80036c <vprintfmt+0x14>
  8004b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004b3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bc:	8d 42 04             	lea    0x4(%edx),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	8b 1a                	mov    (%edx),%ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	75 05                	jne    8004cd <vprintfmt+0x175>
  8004c8:	bb 90 14 80 00       	mov    $0x801490,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8004d1:	7e 66                	jle    800539 <vprintfmt+0x1e1>
  8004d3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8004d7:	74 60                	je     800539 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	51                   	push   %ecx
  8004dd:	53                   	push   %ebx
  8004de:	e8 57 02 00 00       	call   80073a <strnlen>
  8004e3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	57                   	push   %edi
  8004fb:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	ff 4d d8             	decl   -0x28(%ebp)
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050a:	7f eb                	jg     8004f7 <vprintfmt+0x19f>
  80050c:	eb 2b                	jmp    800539 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800515:	74 15                	je     80052c <vprintfmt+0x1d4>
  800517:	8d 42 e0             	lea    -0x20(%edx),%eax
  80051a:	83 f8 5e             	cmp    $0x5e,%eax
  80051d:	76 0d                	jbe    80052c <vprintfmt+0x1d4>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	57                   	push   %edi
  800523:	6a 3f                	push   $0x3f
  800525:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb 0a                	jmp    800536 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	57                   	push   %edi
  800530:	52                   	push   %edx
  800531:	ff d6                	call   *%esi
  800533:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800536:	ff 4d d8             	decl   -0x28(%ebp)
  800539:	8a 03                	mov    (%ebx),%al
  80053b:	43                   	inc    %ebx
  80053c:	84 c0                	test   %al,%al
  80053e:	74 1b                	je     80055b <vprintfmt+0x203>
  800540:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800544:	78 c8                	js     80050e <vprintfmt+0x1b6>
  800546:	ff 4d dc             	decl   -0x24(%ebp)
  800549:	79 c3                	jns    80050e <vprintfmt+0x1b6>
  80054b:	eb 0e                	jmp    80055b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	57                   	push   %edi
  800551:	6a 20                	push   $0x20
  800553:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800555:	ff 4d d8             	decl   -0x28(%ebp)
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055f:	7f ec                	jg     80054d <vprintfmt+0x1f5>
  800561:	e9 06 fe ff ff       	jmp    80036c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800566:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80056a:	7e 10                	jle    80057c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80056c:	8b 55 14             	mov    0x14(%ebp),%edx
  80056f:	8d 42 08             	lea    0x8(%edx),%eax
  800572:	89 45 14             	mov    %eax,0x14(%ebp)
  800575:	8b 02                	mov    (%edx),%eax
  800577:	8b 52 04             	mov    0x4(%edx),%edx
  80057a:	eb 20                	jmp    80059c <vprintfmt+0x244>
	else if (lflag)
  80057c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800580:	74 0e                	je     800590 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	99                   	cltd   
  80058e:	eb 0c                	jmp    80059c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	89 d1                	mov    %edx,%ecx
  80059e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8005a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a6:	85 c9                	test   %ecx,%ecx
  8005a8:	78 0a                	js     8005b4 <vprintfmt+0x25c>
  8005aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005af:	e9 89 00 00 00       	jmp    80063d <vprintfmt+0x2e5>
				putch('-', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	57                   	push   %edi
  8005b8:	6a 2d                	push   $0x2d
  8005ba:	ff d6                	call   *%esi
				num = -(long long) num;
  8005bc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8005bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c2:	f7 da                	neg    %edx
  8005c4:	83 d1 00             	adc    $0x0,%ecx
  8005c7:	f7 d9                	neg    %ecx
  8005c9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	eb 6a                	jmp    80063d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d9:	e8 22 fd ff ff       	call   800300 <getuint>
  8005de:	89 d1                	mov    %edx,%ecx
  8005e0:	89 c2                	mov    %eax,%edx
  8005e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005e7:	eb 54                	jmp    80063d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ef:	e8 0c fd ff ff       	call   800300 <getuint>
  8005f4:	89 d1                	mov    %edx,%ecx
  8005f6:	89 c2                	mov    %eax,%edx
  8005f8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005fd:	eb 3e                	jmp    80063d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	57                   	push   %edi
  800603:	6a 30                	push   $0x30
  800605:	ff d6                	call   *%esi
			putch('x', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	57                   	push   %edi
  80060b:	6a 78                	push   $0x78
  80060d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80060f:	8b 55 14             	mov    0x14(%ebp),%edx
  800612:	8d 42 04             	lea    0x4(%edx),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
  800618:	8b 12                	mov    (%edx),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	eb 14                	jmp    80063d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062f:	e8 cc fc ff ff       	call   800300 <getuint>
  800634:	89 d1                	mov    %edx,%ecx
  800636:	89 c2                	mov    %eax,%edx
  800638:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063d:	83 ec 0c             	sub    $0xc,%esp
  800640:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	ff 75 d8             	pushl  -0x28(%ebp)
  800648:	53                   	push   %ebx
  800649:	51                   	push   %ecx
  80064a:	52                   	push   %edx
  80064b:	89 fa                	mov    %edi,%edx
  80064d:	89 f0                	mov    %esi,%eax
  80064f:	e8 08 fc ff ff       	call   80025c <printnum>
			break;
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	e9 10 fd ff ff       	jmp    80036c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	57                   	push   %edi
  800660:	52                   	push   %edx
  800661:	ff d6                	call   *%esi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	e9 01 fd ff ff       	jmp    80036c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	57                   	push   %edi
  80066f:	6a 25                	push   $0x25
  800671:	ff d6                	call   *%esi
  800673:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800676:	83 ea 02             	sub    $0x2,%edx
  800679:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067c:	8a 02                	mov    (%edx),%al
  80067e:	4a                   	dec    %edx
  80067f:	3c 25                	cmp    $0x25,%al
  800681:	75 f9                	jne    80067c <vprintfmt+0x324>
  800683:	83 c2 02             	add    $0x2,%edx
  800686:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800689:	e9 de fc ff ff       	jmp    80036c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	c9                   	leave  
  800695:	c3                   	ret    

00800696 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 18             	sub    $0x18,%esp
  80069c:	8b 55 08             	mov    0x8(%ebp),%edx
  80069f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	74 37                	je     8006dd <vsnprintf+0x47>
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	7e 33                	jle    8006dd <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006b1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8006b8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bb:	ff 75 14             	pushl  0x14(%ebp)
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	68 3c 03 80 00       	push   $0x80033c
  8006ca:	e8 89 fc ff ff       	call   800358 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	eb 05                	jmp    8006e2 <vsnprintf+0x4c>
  8006dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006f0:	50                   	push   %eax
  8006f1:	ff 75 10             	pushl  0x10(%ebp)
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	ff 75 08             	pushl  0x8(%ebp)
  8006fa:	e8 97 ff ff ff       	call   800696 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 3c fc ff ff       	call   800358 <vprintfmt>
	va_end(ap);
  80071c:	83 c4 10             	add    $0x10,%esp
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    
  800721:	00 00                	add    %al,(%eax)
	...

00800724 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 55 08             	mov    0x8(%ebp),%edx
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	eb 01                	jmp    800732 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800731:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800736:	75 f9                	jne    800731 <strlen+0xd>
		n++;
	return n;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 01                	jmp    80074b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80074a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 d0                	cmp    %edx,%eax
  80074d:	74 06                	je     800755 <strnlen+0x1b>
  80074f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800753:	75 f5                	jne    80074a <strnlen+0x10>
		n++;
	return n;
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800760:	8a 01                	mov    (%ecx),%al
  800762:	88 02                	mov    %al,(%edx)
  800764:	42                   	inc    %edx
  800765:	41                   	inc    %ecx
  800766:	84 c0                	test   %al,%al
  800768:	75 f6                	jne    800760 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800776:	53                   	push   %ebx
  800777:	e8 a8 ff ff ff       	call   800724 <strlen>
	strcpy(dst + len, src);
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800782:	50                   	push   %eax
  800783:	e8 cf ff ff ff       	call   800757 <strcpy>
	return dst;
}
  800788:	89 d8                	mov    %ebx,%eax
  80078a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a2:	eb 0c                	jmp    8007b0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8007a4:	8a 02                	mov    (%edx),%al
  8007a6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007af:	41                   	inc    %ecx
  8007b0:	39 d9                	cmp    %ebx,%ecx
  8007b2:	75 f0                	jne    8007a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	85 c9                	test   %ecx,%ecx
  8007ca:	75 04                	jne    8007d0 <strlcpy+0x16>
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	eb 14                	jmp    8007e4 <strlcpy+0x2a>
  8007d0:	89 f0                	mov    %esi,%eax
  8007d2:	eb 04                	jmp    8007d8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d4:	88 10                	mov    %dl,(%eax)
  8007d6:	40                   	inc    %eax
  8007d7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d8:	49                   	dec    %ecx
  8007d9:	74 06                	je     8007e1 <strlcpy+0x27>
  8007db:	8a 13                	mov    (%ebx),%dl
  8007dd:	84 d2                	test   %dl,%dl
  8007df:	75 f3                	jne    8007d4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007e1:	c6 00 00             	movb   $0x0,(%eax)
  8007e4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5e                   	pop    %esi
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	eb 02                	jmp    8007f7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007f5:	42                   	inc    %edx
  8007f6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f7:	8a 02                	mov    (%edx),%al
  8007f9:	84 c0                	test   %al,%al
  8007fb:	74 04                	je     800801 <strcmp+0x17>
  8007fd:	3a 01                	cmp    (%ecx),%al
  8007ff:	74 f4                	je     8007f5 <strcmp+0xb>
  800801:	0f b6 c0             	movzbl %al,%eax
  800804:	0f b6 11             	movzbl (%ecx),%edx
  800807:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800815:	8b 55 10             	mov    0x10(%ebp),%edx
  800818:	eb 03                	jmp    80081d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80081a:	4a                   	dec    %edx
  80081b:	41                   	inc    %ecx
  80081c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081d:	85 d2                	test   %edx,%edx
  80081f:	75 07                	jne    800828 <strncmp+0x1d>
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 14                	jmp    80083c <strncmp+0x31>
  800828:	8a 01                	mov    (%ecx),%al
  80082a:	84 c0                	test   %al,%al
  80082c:	74 04                	je     800832 <strncmp+0x27>
  80082e:	3a 03                	cmp    (%ebx),%al
  800830:	74 e8                	je     80081a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 d0             	movzbl %al,%edx
  800835:	0f b6 03             	movzbl (%ebx),%eax
  800838:	29 c2                	sub    %eax,%edx
  80083a:	89 d0                	mov    %edx,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800848:	eb 05                	jmp    80084f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80084a:	38 ca                	cmp    %cl,%dl
  80084c:	74 0c                	je     80085a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084e:	40                   	inc    %eax
  80084f:	8a 10                	mov    (%eax),%dl
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f5                	jne    80084a <strchr+0xb>
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800865:	eb 05                	jmp    80086c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800867:	38 ca                	cmp    %cl,%dl
  800869:	74 07                	je     800872 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80086b:	40                   	inc    %eax
  80086c:	8a 10                	mov    (%eax),%dl
  80086e:	84 d2                	test   %dl,%dl
  800870:	75 f5                	jne    800867 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800883:	85 db                	test   %ebx,%ebx
  800885:	74 36                	je     8008bd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800887:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088d:	75 29                	jne    8008b8 <memset+0x44>
  80088f:	f6 c3 03             	test   $0x3,%bl
  800892:	75 24                	jne    8008b8 <memset+0x44>
		c &= 0xFF;
  800894:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800897:	89 d6                	mov    %edx,%esi
  800899:	c1 e6 08             	shl    $0x8,%esi
  80089c:	89 d0                	mov    %edx,%eax
  80089e:	c1 e0 18             	shl    $0x18,%eax
  8008a1:	89 d1                	mov    %edx,%ecx
  8008a3:	c1 e1 10             	shl    $0x10,%ecx
  8008a6:	09 c8                	or     %ecx,%eax
  8008a8:	09 c2                	or     %eax,%edx
  8008aa:	89 f0                	mov    %esi,%eax
  8008ac:	09 d0                	or     %edx,%eax
  8008ae:	89 d9                	mov    %ebx,%ecx
  8008b0:	c1 e9 02             	shr    $0x2,%ecx
  8008b3:	fc                   	cld    
  8008b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b6:	eb 05                	jmp    8008bd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b8:	89 d9                	mov    %ebx,%ecx
  8008ba:	fc                   	cld    
  8008bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bd:	89 f8                	mov    %edi,%eax
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5f                   	pop    %edi
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	57                   	push   %edi
  8008c8:	56                   	push   %esi
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8008cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008d2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008d4:	39 c6                	cmp    %eax,%esi
  8008d6:	73 36                	jae    80090e <memmove+0x4a>
  8008d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	73 2f                	jae    80090e <memmove+0x4a>
		s += n;
		d += n;
  8008df:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	f6 c2 03             	test   $0x3,%dl
  8008e5:	75 1b                	jne    800902 <memmove+0x3e>
  8008e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ed:	75 13                	jne    800902 <memmove+0x3e>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 0e                	jne    800902 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008f4:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
  8008fd:	fd                   	std    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 09                	jmp    80090b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800902:	8d 7e ff             	lea    -0x1(%esi),%edi
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 20                	jmp    80092e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800914:	75 15                	jne    80092b <memmove+0x67>
  800916:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091c:	75 0d                	jne    80092b <memmove+0x67>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 08                	jne    80092b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800923:	c1 e9 02             	shr    $0x2,%ecx
  800926:	fc                   	cld    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 03                	jmp    80092e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092b:	fc                   	cld    
  80092c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 81 ff ff ff       	call   8008c4 <memmove>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	53                   	push   %ebx
  800949:	83 ec 04             	sub    $0x4,%esp
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80094f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800955:	eb 1b                	jmp    800972 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800957:	8a 1a                	mov    (%edx),%bl
  800959:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80095c:	8a 19                	mov    (%ecx),%bl
  80095e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800961:	74 0d                	je     800970 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800963:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800967:	0f b6 c3             	movzbl %bl,%eax
  80096a:	29 c2                	sub    %eax,%edx
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	eb 0d                	jmp    80097d <memcmp+0x38>
		s1++, s2++;
  800970:	42                   	inc    %edx
  800971:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	48                   	dec    %eax
  800973:	83 f8 ff             	cmp    $0xffffffff,%eax
  800976:	75 df                	jne    800957 <memcmp+0x12>
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80097d:	83 c4 04             	add    $0x4,%esp
  800980:	5b                   	pop    %ebx
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	03 55 10             	add    0x10(%ebp),%edx
  800991:	eb 05                	jmp    800998 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800993:	38 08                	cmp    %cl,(%eax)
  800995:	74 05                	je     80099c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800997:	40                   	inc    %eax
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	72 f7                	jb     800993 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	83 ec 04             	sub    $0x4,%esp
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8009ad:	eb 01                	jmp    8009b0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009af:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b0:	8a 01                	mov    (%ecx),%al
  8009b2:	3c 20                	cmp    $0x20,%al
  8009b4:	74 f9                	je     8009af <strtol+0x11>
  8009b6:	3c 09                	cmp    $0x9,%al
  8009b8:	74 f5                	je     8009af <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ba:	3c 2b                	cmp    $0x2b,%al
  8009bc:	75 0a                	jne    8009c8 <strtol+0x2a>
		s++;
  8009be:	41                   	inc    %ecx
  8009bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009c6:	eb 17                	jmp    8009df <strtol+0x41>
	else if (*s == '-')
  8009c8:	3c 2d                	cmp    $0x2d,%al
  8009ca:	74 09                	je     8009d5 <strtol+0x37>
  8009cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009d3:	eb 0a                	jmp    8009df <strtol+0x41>
		s++, neg = 1;
  8009d5:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009d8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009df:	85 f6                	test   %esi,%esi
  8009e1:	74 05                	je     8009e8 <strtol+0x4a>
  8009e3:	83 fe 10             	cmp    $0x10,%esi
  8009e6:	75 1a                	jne    800a02 <strtol+0x64>
  8009e8:	8a 01                	mov    (%ecx),%al
  8009ea:	3c 30                	cmp    $0x30,%al
  8009ec:	75 10                	jne    8009fe <strtol+0x60>
  8009ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f2:	75 0a                	jne    8009fe <strtol+0x60>
		s += 2, base = 16;
  8009f4:	83 c1 02             	add    $0x2,%ecx
  8009f7:	be 10 00 00 00       	mov    $0x10,%esi
  8009fc:	eb 04                	jmp    800a02 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009fe:	85 f6                	test   %esi,%esi
  800a00:	74 07                	je     800a09 <strtol+0x6b>
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 13                	jmp    800a1c <strtol+0x7e>
  800a09:	3c 30                	cmp    $0x30,%al
  800a0b:	74 07                	je     800a14 <strtol+0x76>
  800a0d:	be 0a 00 00 00       	mov    $0xa,%esi
  800a12:	eb ee                	jmp    800a02 <strtol+0x64>
		s++, base = 8;
  800a14:	41                   	inc    %ecx
  800a15:	be 08 00 00 00       	mov    $0x8,%esi
  800a1a:	eb e6                	jmp    800a02 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a1c:	8a 11                	mov    (%ecx),%dl
  800a1e:	88 d3                	mov    %dl,%bl
  800a20:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a23:	3c 09                	cmp    $0x9,%al
  800a25:	77 08                	ja     800a2f <strtol+0x91>
			dig = *s - '0';
  800a27:	0f be c2             	movsbl %dl,%eax
  800a2a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a2d:	eb 1c                	jmp    800a4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a32:	3c 19                	cmp    $0x19,%al
  800a34:	77 08                	ja     800a3e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a36:	0f be c2             	movsbl %dl,%eax
  800a39:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a3c:	eb 0d                	jmp    800a4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a41:	3c 19                	cmp    $0x19,%al
  800a43:	77 15                	ja     800a5a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a45:	0f be c2             	movsbl %dl,%eax
  800a48:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a4b:	39 f2                	cmp    %esi,%edx
  800a4d:	7d 0b                	jge    800a5a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a4f:	41                   	inc    %ecx
  800a50:	89 f8                	mov    %edi,%eax
  800a52:	0f af c6             	imul   %esi,%eax
  800a55:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a58:	eb c2                	jmp    800a1c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a5a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a60:	74 05                	je     800a67 <strtol+0xc9>
		*endptr = (char *) s;
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a6b:	74 04                	je     800a71 <strtol+0xd3>
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	f7 df                	neg    %edi
}
  800a71:	89 f8                	mov    %edi,%eax
  800a73:	83 c4 04             	add    $0x4,%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    
	...

00800a7c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8c:	89 fa                	mov    %edi,%edx
  800a8e:	89 f9                	mov    %edi,%ecx
  800a90:	89 fb                	mov    %edi,%ebx
  800a92:	89 fe                	mov    %edi,%esi
  800a94:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	c9                   	leave  
  800a9a:	c3                   	ret    

00800a9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	83 ec 04             	sub    $0x4,%esp
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	bf 00 00 00 00       	mov    $0x0,%edi
  800aaf:	89 f8                	mov    %edi,%eax
  800ab1:	89 fb                	mov    %edi,%ebx
  800ab3:	89 fe                	mov    %edi,%esi
  800ab5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab7:	83 c4 04             	add    $0x4,%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad5:	89 f9                	mov    %edi,%ecx
  800ad7:	89 fb                	mov    %edi,%ebx
  800ad9:	89 fe                	mov    %edi,%esi
  800adb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800add:	85 c0                	test   %eax,%eax
  800adf:	7e 17                	jle    800af8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	50                   	push   %eax
  800ae5:	6a 0d                	push   $0xd
  800ae7:	68 7f 17 80 00       	push   $0x80177f
  800aec:	6a 23                	push   $0x23
  800aee:	68 9c 17 80 00       	push   $0x80179c
  800af3:	e8 6c f6 ff ff       	call   800164 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b17:	be 00 00 00 00       	mov    $0x0,%esi
  800b1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b37:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3c:	89 fb                	mov    %edi,%ebx
  800b3e:	89 fe                	mov    %edi,%esi
  800b40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b42:	85 c0                	test   %eax,%eax
  800b44:	7e 17                	jle    800b5d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	50                   	push   %eax
  800b4a:	6a 0a                	push   $0xa
  800b4c:	68 7f 17 80 00       	push   $0x80177f
  800b51:	6a 23                	push   $0x23
  800b53:	68 9c 17 80 00       	push   $0x80179c
  800b58:	e8 07 f6 ff ff       	call   800164 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	b8 09 00 00 00       	mov    $0x9,%eax
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7e:	89 fb                	mov    %edi,%ebx
  800b80:	89 fe                	mov    %edi,%esi
  800b82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b84:	85 c0                	test   %eax,%eax
  800b86:	7e 17                	jle    800b9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 09                	push   $0x9
  800b8e:	68 7f 17 80 00       	push   $0x80177f
  800b93:	6a 23                	push   $0x23
  800b95:	68 9c 17 80 00       	push   $0x80179c
  800b9a:	e8 c5 f5 ff ff       	call   800164 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc0:	89 fb                	mov    %edi,%ebx
  800bc2:	89 fe                	mov    %edi,%esi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 08                	push   $0x8
  800bd0:	68 7f 17 80 00       	push   $0x80177f
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 9c 17 80 00       	push   $0x80179c
  800bdc:	e8 83 f5 ff ff       	call   800164 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  800c02:	89 fb                	mov    %edi,%ebx
  800c04:	89 fe                	mov    %edi,%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 06                	push   $0x6
  800c12:	68 7f 17 80 00       	push   $0x80177f
  800c17:	6a 23                	push   $0x23
  800c19:	68 9c 17 80 00       	push   $0x80179c
  800c1e:	e8 41 f5 ff ff       	call   800164 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c40:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 05 00 00 00       	mov    $0x5,%eax
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 05                	push   $0x5
  800c54:	68 7f 17 80 00       	push   $0x80177f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 9c 17 80 00       	push   $0x80179c
  800c60:	e8 ff f4 ff ff       	call   800164 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c84:	bf 00 00 00 00       	mov    $0x0,%edi
  800c89:	89 fe                	mov    %edi,%esi
  800c8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 17                	jle    800ca8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 04                	push   $0x4
  800c97:	68 7f 17 80 00       	push   $0x80177f
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 9c 17 80 00       	push   $0x80179c
  800ca3:	e8 bc f4 ff ff       	call   800164 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc0:	89 fa                	mov    %edi,%edx
  800cc2:	89 f9                	mov    %edi,%ecx
  800cc4:	89 fb                	mov    %edi,%ebx
  800cc6:	89 fe                	mov    %edi,%esi
  800cc8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cda:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdf:	89 fa                	mov    %edi,%edx
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	89 fb                	mov    %edi,%ebx
  800ce5:	89 fe                	mov    %edi,%esi
  800ce7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b8 03 00 00 00       	mov    $0x3,%eax
  800cff:	bf 00 00 00 00       	mov    $0x0,%edi
  800d04:	89 f9                	mov    %edi,%ecx
  800d06:	89 fb                	mov    %edi,%ebx
  800d08:	89 fe                	mov    %edi,%esi
  800d0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 17                	jle    800d27 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 03                	push   $0x3
  800d16:	68 7f 17 80 00       	push   $0x80177f
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 9c 17 80 00       	push   $0x80179c
  800d22:	e8 3d f4 ff ff       	call   800164 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    
	...

00800d30 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d36:	68 aa 17 80 00       	push   $0x8017aa
  800d3b:	68 92 00 00 00       	push   $0x92
  800d40:	68 c0 17 80 00       	push   $0x8017c0
  800d45:	e8 1a f4 ff ff       	call   800164 <_panic>

00800d4a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800d53:	68 eb 0e 80 00       	push   $0x800eeb
  800d58:	e8 6f 03 00 00       	call   8010cc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800d5d:	ba 07 00 00 00       	mov    $0x7,%edx
  800d62:	89 d0                	mov    %edx,%eax
  800d64:	cd 30                	int    $0x30
  800d66:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	75 25                	jne    800d94 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800d6f:	e8 5b ff ff ff       	call   800ccf <sys_getenvid>
  800d74:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d79:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d80:	c1 e0 07             	shl    $0x7,%eax
  800d83:	29 d0                	sub    %edx,%eax
  800d85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d8a:	a3 04 20 80 00       	mov    %eax,0x802004
  800d8f:	e9 4d 01 00 00       	jmp    800ee1 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800d94:	85 c0                	test   %eax,%eax
  800d96:	79 12                	jns    800daa <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d98:	50                   	push   %eax
  800d99:	68 cb 17 80 00       	push   $0x8017cb
  800d9e:	6a 77                	push   $0x77
  800da0:	68 c0 17 80 00       	push   $0x8017c0
  800da5:	e8 ba f3 ff ff       	call   800164 <_panic>
  800daa:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800daf:	89 d8                	mov    %ebx,%eax
  800db1:	c1 e8 16             	shr    $0x16,%eax
  800db4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dbb:	a8 01                	test   $0x1,%al
  800dbd:	0f 84 ab 00 00 00    	je     800e6e <fork+0x124>
  800dc3:	89 da                	mov    %ebx,%edx
  800dc5:	c1 ea 0c             	shr    $0xc,%edx
  800dc8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800dcf:	a8 01                	test   $0x1,%al
  800dd1:	0f 84 97 00 00 00    	je     800e6e <fork+0x124>
  800dd7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800dde:	a8 04                	test   $0x4,%al
  800de0:	0f 84 88 00 00 00    	je     800e6e <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800de6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800ded:	89 d6                	mov    %edx,%esi
  800def:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800dfa:	a9 02 08 00 00       	test   $0x802,%eax
  800dff:	74 0f                	je     800e10 <fork+0xc6>
  800e01:	f6 c4 04             	test   $0x4,%ah
  800e04:	75 0a                	jne    800e10 <fork+0xc6>
		perm &= ~PTE_W;
  800e06:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800e10:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	52                   	push   %edx
  800e1d:	56                   	push   %esi
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	6a 00                	push   $0x0
  800e22:	e8 04 fe ff ff       	call   800c2b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800e27:	83 c4 20             	add    $0x20,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	79 14                	jns    800e42 <fork+0xf8>
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 14 18 80 00       	push   $0x801814
  800e36:	6a 52                	push   $0x52
  800e38:	68 c0 17 80 00       	push   $0x8017c0
  800e3d:	e8 22 f3 ff ff       	call   800164 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f0             	pushl  -0x10(%ebp)
  800e48:	56                   	push   %esi
  800e49:	6a 00                	push   $0x0
  800e4b:	56                   	push   %esi
  800e4c:	6a 00                	push   $0x0
  800e4e:	e8 d8 fd ff ff       	call   800c2b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800e53:	83 c4 20             	add    $0x20,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	79 14                	jns    800e6e <fork+0x124>
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	68 38 18 80 00       	push   $0x801838
  800e62:	6a 55                	push   $0x55
  800e64:	68 c0 17 80 00       	push   $0x8017c0
  800e69:	e8 f6 f2 ff ff       	call   800164 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800e6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800e74:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800e7a:	0f 85 2f ff ff ff    	jne    800daf <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800e80:	83 ec 04             	sub    $0x4,%esp
  800e83:	6a 07                	push   $0x7
  800e85:	68 00 f0 bf ee       	push   $0xeebff000
  800e8a:	57                   	push   %edi
  800e8b:	e8 dd fd ff ff       	call   800c6d <sys_page_alloc>
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 15                	jns    800eac <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800e97:	50                   	push   %eax
  800e98:	68 e9 17 80 00       	push   $0x8017e9
  800e9d:	68 83 00 00 00       	push   $0x83
  800ea2:	68 c0 17 80 00       	push   $0x8017c0
  800ea7:	e8 b8 f2 ff ff       	call   800164 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	68 4c 11 80 00       	push   $0x80114c
  800eb4:	57                   	push   %edi
  800eb5:	e8 69 fc ff ff       	call   800b23 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800eba:	83 c4 08             	add    $0x8,%esp
  800ebd:	6a 02                	push   $0x2
  800ebf:	57                   	push   %edi
  800ec0:	e8 e2 fc ff ff       	call   800ba7 <sys_env_set_status>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	79 15                	jns    800ee1 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800ecc:	50                   	push   %eax
  800ecd:	68 fc 17 80 00       	push   $0x8017fc
  800ed2:	68 89 00 00 00       	push   $0x89
  800ed7:	68 c0 17 80 00       	push   $0x8017c0
  800edc:	e8 83 f2 ff ff       	call   800164 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800ee1:	89 f8                	mov    %edi,%eax
  800ee3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5f                   	pop    %edi
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	53                   	push   %ebx
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800ef5:	8b 1a                	mov    (%edx),%ebx
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	c1 e8 0c             	shr    $0xc,%eax
  800efc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800f03:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f07:	74 05                	je     800f0e <pgfault+0x23>
  800f09:	f6 c4 08             	test   $0x8,%ah
  800f0c:	75 14                	jne    800f22 <pgfault+0x37>
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	68 5c 18 80 00       	push   $0x80185c
  800f16:	6a 1e                	push   $0x1e
  800f18:	68 c0 17 80 00       	push   $0x8017c0
  800f1d:	e8 42 f2 ff ff       	call   800164 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	6a 00                	push   $0x0
  800f2e:	e8 3a fd ff ff       	call   800c6d <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 14                	jns    800f4e <pgfault+0x63>
  800f3a:	83 ec 04             	sub    $0x4,%esp
  800f3d:	68 88 18 80 00       	push   $0x801888
  800f42:	6a 2a                	push   $0x2a
  800f44:	68 c0 17 80 00       	push   $0x8017c0
  800f49:	e8 16 f2 ff ff       	call   800164 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800f4e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 00 10 00 00       	push   $0x1000
  800f5c:	53                   	push   %ebx
  800f5d:	68 00 f0 7f 00       	push   $0x7ff000
  800f62:	e8 5d f9 ff ff       	call   8008c4 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800f67:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6e:	53                   	push   %ebx
  800f6f:	6a 00                	push   $0x0
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 ae fc ff ff       	call   800c2b <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 14                	jns    800f98 <pgfault+0xad>
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 ac 18 80 00       	push   $0x8018ac
  800f8c:	6a 2e                	push   $0x2e
  800f8e:	68 c0 17 80 00       	push   $0x8017c0
  800f93:	e8 cc f1 ff ff       	call   800164 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	68 00 f0 7f 00       	push   $0x7ff000
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 42 fc ff ff       	call   800be9 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 14                	jns    800fc2 <pgfault+0xd7>
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 cc 18 80 00       	push   $0x8018cc
  800fb6:	6a 32                	push   $0x32
  800fb8:	68 c0 17 80 00       	push   $0x8017c0
  800fbd:	e8 a2 f1 ff ff       	call   800164 <_panic>
	//panic("pgfault not implemented");
}
  800fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    
	...

00800fc8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	53                   	push   %ebx
  800fcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fcf:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800fd4:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  800fdb:	89 c8                	mov    %ecx,%eax
  800fdd:	c1 e0 07             	shl    $0x7,%eax
  800fe0:	29 d0                	sub    %edx,%eax
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  800fea:	8b 40 50             	mov    0x50(%eax),%eax
  800fed:	39 d8                	cmp    %ebx,%eax
  800fef:	75 0b                	jne    800ffc <ipc_find_env+0x34>
			return envs[i].env_id;
  800ff1:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  800ff7:	8b 40 40             	mov    0x40(%eax),%eax
  800ffa:	eb 0e                	jmp    80100a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ffc:	41                   	inc    %ecx
  800ffd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801003:	75 cf                	jne    800fd4 <ipc_find_env+0xc>
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80100a:	5b                   	pop    %ebx
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801019:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80101f:	85 db                	test   %ebx,%ebx
  801021:	75 05                	jne    801028 <ipc_send+0x1b>
  801023:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	57                   	push   %edi
  80102b:	ff 75 08             	pushl  0x8(%ebp)
  80102e:	e8 cd fa ff ff       	call   800b00 <sys_ipc_try_send>
		if (r == 0) {		//success
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	74 20                	je     80105a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80103a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80103d:	75 07                	jne    801046 <ipc_send+0x39>
			sys_yield();
  80103f:	e8 6c fc ff ff       	call   800cb0 <sys_yield>
  801044:	eb e2                	jmp    801028 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	68 f0 18 80 00       	push   $0x8018f0
  80104e:	6a 41                	push   $0x41
  801050:	68 13 19 80 00       	push   $0x801913
  801055:	e8 0a f1 ff ff       	call   800164 <_panic>
		}
	}
}
  80105a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80106a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801070:	85 c0                	test   %eax,%eax
  801072:	75 05                	jne    801079 <ipc_recv+0x17>
  801074:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	50                   	push   %eax
  80107d:	e8 3d fa ff ff       	call   800abf <sys_ipc_recv>
	if (r < 0) {				
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	79 16                	jns    80109f <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801089:	85 db                	test   %ebx,%ebx
  80108b:	74 06                	je     801093 <ipc_recv+0x31>
  80108d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801093:	85 f6                	test   %esi,%esi
  801095:	74 2c                	je     8010c3 <ipc_recv+0x61>
  801097:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80109d:	eb 24                	jmp    8010c3 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  80109f:	85 db                	test   %ebx,%ebx
  8010a1:	74 0a                	je     8010ad <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8010a3:	a1 04 20 80 00       	mov    0x802004,%eax
  8010a8:	8b 40 74             	mov    0x74(%eax),%eax
  8010ab:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  8010ad:	85 f6                	test   %esi,%esi
  8010af:	74 0a                	je     8010bb <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8010b1:	a1 04 20 80 00       	mov    0x802004,%eax
  8010b6:	8b 40 78             	mov    0x78(%eax),%eax
  8010b9:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8010bb:	a1 04 20 80 00       	mov    0x802004,%eax
  8010c0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    
	...

008010cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010d2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010d9:	75 64                	jne    80113f <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  8010db:	a1 04 20 80 00       	mov    0x802004,%eax
  8010e0:	8b 40 48             	mov    0x48(%eax),%eax
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	6a 07                	push   $0x7
  8010e8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ed:	50                   	push   %eax
  8010ee:	e8 7a fb ff ff       	call   800c6d <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 14                	jns    80110e <set_pgfault_handler+0x42>
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	68 20 19 80 00       	push   $0x801920
  801102:	6a 22                	push   $0x22
  801104:	68 8c 19 80 00       	push   $0x80198c
  801109:	e8 56 f0 ff ff       	call   800164 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  80110e:	a1 04 20 80 00       	mov    0x802004,%eax
  801113:	8b 40 48             	mov    0x48(%eax),%eax
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	68 4c 11 80 00       	push   $0x80114c
  80111e:	50                   	push   %eax
  80111f:	e8 ff f9 ff ff       	call   800b23 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 14                	jns    80113f <set_pgfault_handler+0x73>
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	68 50 19 80 00       	push   $0x801950
  801133:	6a 25                	push   $0x25
  801135:	68 8c 19 80 00       	push   $0x80198c
  80113a:	e8 25 f0 ff ff       	call   800164 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    
  801149:	00 00                	add    %al,(%eax)
	...

0080114c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80114c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801152:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801154:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801157:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80115b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80115e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801162:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801166:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801168:	83 c4 08             	add    $0x8,%esp
	popal
  80116b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80116c:	83 c4 04             	add    $0x4,%esp
	popfl
  80116f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801170:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801171:	c3                   	ret    
	...

00801174 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	83 ec 28             	sub    $0x28,%esp
  80117c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801183:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80118a:	8b 45 10             	mov    0x10(%ebp),%eax
  80118d:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801193:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801195:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801197:	8b 45 08             	mov    0x8(%ebp),%eax
  80119a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  80119d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011a3:	85 ff                	test   %edi,%edi
  8011a5:	75 21                	jne    8011c8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  8011a7:	39 d1                	cmp    %edx,%ecx
  8011a9:	76 49                	jbe    8011f4 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011ab:	f7 f1                	div    %ecx
  8011ad:	89 c1                	mov    %eax,%ecx
  8011af:	31 c0                	xor    %eax,%eax
  8011b1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011b4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8011b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011c0:	83 c4 28             	add    $0x28,%esp
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    
  8011c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011c8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8011cb:	0f 87 97 00 00 00    	ja     801268 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8011d1:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8011d4:	83 f0 1f             	xor    $0x1f,%eax
  8011d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011da:	75 34                	jne    801210 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8011dc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8011df:	72 08                	jb     8011e9 <__udivdi3+0x75>
  8011e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011e4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8011e7:	77 7f                	ja     801268 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011e9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011ee:	31 c0                	xor    %eax,%eax
  8011f0:	eb c2                	jmp    8011b4 <__udivdi3+0x40>
  8011f2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8011f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 79                	je     801274 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011fe:	89 fa                	mov    %edi,%edx
  801200:	f7 f1                	div    %ecx
  801202:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801204:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801207:	f7 f1                	div    %ecx
  801209:	89 c1                	mov    %eax,%ecx
  80120b:	89 f0                	mov    %esi,%eax
  80120d:	eb a5                	jmp    8011b4 <__udivdi3+0x40>
  80120f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801210:	b8 20 00 00 00       	mov    $0x20,%eax
  801215:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80121b:	89 fa                	mov    %edi,%edx
  80121d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801220:	d3 e2                	shl    %cl,%edx
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801228:	d3 e8                	shr    %cl,%eax
  80122a:	89 d7                	mov    %edx,%edi
  80122c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80122e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801231:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801234:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801236:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801239:	d3 e0                	shl    %cl,%eax
  80123b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80123e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801241:	d3 ea                	shr    %cl,%edx
  801243:	09 d0                	or     %edx,%eax
  801245:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801248:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80124b:	d3 ea                	shr    %cl,%edx
  80124d:	f7 f7                	div    %edi
  80124f:	89 d7                	mov    %edx,%edi
  801251:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801254:	f7 e6                	mul    %esi
  801256:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801258:	39 d7                	cmp    %edx,%edi
  80125a:	72 38                	jb     801294 <__udivdi3+0x120>
  80125c:	74 27                	je     801285 <__udivdi3+0x111>
  80125e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801261:	31 c0                	xor    %eax,%eax
  801263:	e9 4c ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801268:	31 c9                	xor    %ecx,%ecx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	e9 43 ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
  801271:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801274:	b8 01 00 00 00       	mov    $0x1,%eax
  801279:	31 d2                	xor    %edx,%edx
  80127b:	f7 75 f4             	divl   -0xc(%ebp)
  80127e:	89 c1                	mov    %eax,%ecx
  801280:	e9 76 ff ff ff       	jmp    8011fb <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801285:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801288:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80128b:	d3 e0                	shl    %cl,%eax
  80128d:	39 f0                	cmp    %esi,%eax
  80128f:	73 cd                	jae    80125e <__udivdi3+0xea>
  801291:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801294:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801297:	49                   	dec    %ecx
  801298:	31 c0                	xor    %eax,%eax
  80129a:	e9 15 ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
	...

008012a0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	83 ec 30             	sub    $0x30,%esp
  8012a8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bf:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8012c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8012c5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8012c7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8012ca:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8012cd:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8012d0:	85 d2                	test   %edx,%edx
  8012d2:	75 1c                	jne    8012f0 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8012d4:	89 fa                	mov    %edi,%edx
  8012d6:	39 f8                	cmp    %edi,%eax
  8012d8:	0f 86 c2 00 00 00    	jbe    8013a0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8012e2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8012e5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012ec:	eb 12                	jmp    801300 <__umoddi3+0x60>
  8012ee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8012f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012f3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8012f6:	76 18                	jbe    801310 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8012f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8012fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8012fe:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801300:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801303:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801306:	83 c4 30             	add    $0x30,%esp
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801310:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801314:	83 f0 1f             	xor    $0x1f,%eax
  801317:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80131a:	0f 84 ac 00 00 00    	je     8013cc <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801320:	b8 20 00 00 00       	mov    $0x20,%eax
  801325:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80132b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80132e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801331:	d3 e2                	shl    %cl,%edx
  801333:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801336:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801339:	d3 e8                	shr    %cl,%eax
  80133b:	89 d6                	mov    %edx,%esi
  80133d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80133f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801342:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801345:	d3 e0                	shl    %cl,%eax
  801347:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80134a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  80134d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80134f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801352:	d3 e0                	shl    %cl,%eax
  801354:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801357:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80135a:	d3 ea                	shr    %cl,%edx
  80135c:	09 d0                	or     %edx,%eax
  80135e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801361:	d3 ea                	shr    %cl,%edx
  801363:	f7 f6                	div    %esi
  801365:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801368:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80136b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80136e:	0f 82 8d 00 00 00    	jb     801401 <__umoddi3+0x161>
  801374:	0f 84 91 00 00 00    	je     80140b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80137a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80137d:	29 c7                	sub    %eax,%edi
  80137f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801381:	89 f2                	mov    %esi,%edx
  801383:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801386:	d3 e2                	shl    %cl,%edx
  801388:	89 f8                	mov    %edi,%eax
  80138a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80138d:	d3 e8                	shr    %cl,%eax
  80138f:	09 c2                	or     %eax,%edx
  801391:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801394:	d3 ee                	shr    %cl,%esi
  801396:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801399:	e9 62 ff ff ff       	jmp    801300 <__umoddi3+0x60>
  80139e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8013a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 15                	je     8013bc <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8013a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8013ad:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b2:	f7 f1                	div    %ecx
  8013b4:	e9 29 ff ff ff       	jmp    8012e2 <__umoddi3+0x42>
  8013b9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8013bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	f7 75 ec             	divl   -0x14(%ebp)
  8013c6:	89 c1                	mov    %eax,%ecx
  8013c8:	eb dd                	jmp    8013a7 <__umoddi3+0x107>
  8013ca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cf:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8013d2:	72 19                	jb     8013ed <__umoddi3+0x14d>
  8013d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8013da:	76 11                	jbe    8013ed <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013df:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8013e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8013e8:	e9 13 ff ff ff       	jmp    801300 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8013f6:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8013f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8013ff:	eb db                	jmp    8013dc <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801401:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801404:	19 f2                	sbb    %esi,%edx
  801406:	e9 6f ff ff ff       	jmp    80137a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80140b:	39 c7                	cmp    %eax,%edi
  80140d:	72 f2                	jb     801401 <__umoddi3+0x161>
  80140f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801412:	e9 63 ff ff ff       	jmp    80137a <__umoddi3+0xda>
