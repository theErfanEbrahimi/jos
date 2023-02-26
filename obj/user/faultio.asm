
obj/user/faultio.debug:     file format elf32-i386


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
  80002c:	e8 3b 00 00 00       	call   80006c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  80003a:	9c                   	pushf  
  80003b:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003c:	f6 c4 30             	test   $0x30,%ah
  80003f:	74 10                	je     800051 <umain+0x1d>
		cprintf("eflags wrong\n");
  800041:	83 ec 0c             	sub    $0xc,%esp
  800044:	68 40 0f 80 00       	push   $0x800f40
  800049:	e8 d3 00 00 00       	call   800121 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800051:	b0 f0                	mov    $0xf0,%al
  800053:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800058:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	68 4e 0f 80 00       	push   $0x800f4e
  800061:	e8 bb 00 00 00       	call   800121 <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
}
  800069:	c9                   	leave  
  80006a:	c3                   	ret    
	...

0080006c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006c:	55                   	push   %ebp
  80006d:	89 e5                	mov    %esp,%ebp
  80006f:	56                   	push   %esi
  800070:	53                   	push   %ebx
  800071:	8b 75 08             	mov    0x8(%ebp),%esi
  800074:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800077:	e8 6f 0b 00 00       	call   800beb <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80007c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800081:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800088:	c1 e0 07             	shl    $0x7,%eax
  80008b:	29 d0                	sub    %edx,%eax
  80008d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800092:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800097:	85 f6                	test   %esi,%esi
  800099:	7e 07                	jle    8000a2 <libmain+0x36>
		binaryname = argv[0];
  80009b:	8b 03                	mov    (%ebx),%eax
  80009d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	56                   	push   %esi
  8000a7:	e8 88 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0b 00 00 00       	call   8000bc <exit>
  8000b1:	83 c4 10             	add    $0x10,%esp
}
  8000b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    
	...

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 41 0b 00 00       	call   800c0a <sys_env_destroy>
  8000c9:	83 c4 10             	add    $0x10,%esp
}
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
	...

008000d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000d9:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000e0:	00 00 00 
	b.cnt = 0;
  8000e3:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8000ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000ed:	ff 75 0c             	pushl  0xc(%ebp)
  8000f0:	ff 75 08             	pushl  0x8(%ebp)
  8000f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000f9:	50                   	push   %eax
  8000fa:	68 38 01 80 00       	push   $0x800138
  8000ff:	e8 70 01 00 00       	call   800274 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800104:	83 c4 08             	add    $0x8,%esp
  800107:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  80010d:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	e8 9e 08 00 00       	call   8009b7 <sys_cputs>
  800119:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800127:	8d 45 0c             	lea    0xc(%ebp),%eax
  80012a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80012d:	50                   	push   %eax
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	e8 9a ff ff ff       	call   8000d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	83 ec 04             	sub    $0x4,%esp
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800142:	8b 03                	mov    (%ebx),%eax
  800144:	8b 55 08             	mov    0x8(%ebp),%edx
  800147:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014b:	40                   	inc    %eax
  80014c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800153:	75 1a                	jne    80016f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	68 ff 00 00 00       	push   $0xff
  80015d:	8d 43 08             	lea    0x8(%ebx),%eax
  800160:	50                   	push   %eax
  800161:	e8 51 08 00 00       	call   8009b7 <sys_cputs>
		b->idx = 0;
  800166:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80016f:	ff 43 04             	incl   0x4(%ebx)
}
  800172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800175:	c9                   	leave  
  800176:	c3                   	ret    
	...

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 1c             	sub    $0x1c,%esp
  800181:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800184:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800187:	8b 45 08             	mov    0x8(%ebp),%eax
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800190:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800193:	8b 55 10             	mov    0x10(%ebp),%edx
  800196:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800199:	89 d6                	mov    %edx,%esi
  80019b:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a0:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001a3:	72 04                	jb     8001a9 <printnum+0x31>
  8001a5:	39 c2                	cmp    %eax,%edx
  8001a7:	77 3f                	ja     8001e8 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a9:	83 ec 0c             	sub    $0xc,%esp
  8001ac:	ff 75 18             	pushl  0x18(%ebp)
  8001af:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001b2:	50                   	push   %eax
  8001b3:	52                   	push   %edx
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bf:	e8 d8 0a 00 00       	call   800c9c <__udivdi3>
  8001c4:	83 c4 18             	add    $0x18,%esp
  8001c7:	52                   	push   %edx
  8001c8:	50                   	push   %eax
  8001c9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001cf:	e8 a4 ff ff ff       	call   800178 <printnum>
  8001d4:	83 c4 20             	add    $0x20,%esp
  8001d7:	eb 14                	jmp    8001ed <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e8             	pushl  -0x18(%ebp)
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff 55 ec             	call   *-0x14(%ebp)
  8001e5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e8:	4b                   	dec    %ebx
  8001e9:	85 db                	test   %ebx,%ebx
  8001eb:	7f ec                	jg     8001d9 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 e8             	pushl  -0x18(%ebp)
  8001f3:	83 ec 04             	sub    $0x4,%esp
  8001f6:	57                   	push   %edi
  8001f7:	56                   	push   %esi
  8001f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fe:	e8 c5 0b 00 00       	call   800dc8 <__umoddi3>
  800203:	83 c4 14             	add    $0x14,%esp
  800206:	0f be 80 72 0f 80 00 	movsbl 0x800f72(%eax),%eax
  80020d:	50                   	push   %eax
  80020e:	ff 55 ec             	call   *-0x14(%ebp)
  800211:	83 c4 10             	add    $0x10,%esp
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800221:	83 fa 01             	cmp    $0x1,%edx
  800224:	7e 0e                	jle    800234 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 42 08             	lea    0x8(%edx),%eax
  80022b:	89 01                	mov    %eax,(%ecx)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	8b 52 04             	mov    0x4(%edx),%edx
  800232:	eb 22                	jmp    800256 <getuint+0x3a>
	else if (lflag)
  800234:	85 d2                	test   %edx,%edx
  800236:	74 10                	je     800248 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 42 04             	lea    0x4(%edx),%eax
  80023d:	89 01                	mov    %eax,(%ecx)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
  800246:	eb 0e                	jmp    800256 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 42 04             	lea    0x4(%edx),%eax
  80024d:	89 01                	mov    %eax,(%ecx)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80025e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800261:	8b 11                	mov    (%ecx),%edx
  800263:	3b 51 04             	cmp    0x4(%ecx),%edx
  800266:	73 0a                	jae    800272 <sprintputch+0x1a>
		*b->buf++ = ch;
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	88 02                	mov    %al,(%edx)
  80026d:	8d 42 01             	lea    0x1(%edx),%eax
  800270:	89 01                	mov    %eax,(%ecx)
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 3c             	sub    $0x3c,%esp
  80027d:	8b 75 08             	mov    0x8(%ebp),%esi
  800280:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800283:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800286:	eb 1a                	jmp    8002a2 <vprintfmt+0x2e>
  800288:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80028b:	eb 15                	jmp    8002a2 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028d:	84 c0                	test   %al,%al
  80028f:	0f 84 15 03 00 00    	je     8005aa <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	57                   	push   %edi
  800299:	0f b6 c0             	movzbl %al,%eax
  80029c:	50                   	push   %eax
  80029d:	ff d6                	call   *%esi
  80029f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a2:	8a 03                	mov    (%ebx),%al
  8002a4:	43                   	inc    %ebx
  8002a5:	3c 25                	cmp    $0x25,%al
  8002a7:	75 e4                	jne    80028d <vprintfmt+0x19>
  8002a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002b7:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002be:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002c5:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002c9:	eb 0a                	jmp    8002d5 <vprintfmt+0x61>
  8002cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8002d2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8002d5:	8a 03                	mov    (%ebx),%al
  8002d7:	0f b6 d0             	movzbl %al,%edx
  8002da:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8002dd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8002e0:	83 e8 23             	sub    $0x23,%eax
  8002e3:	3c 55                	cmp    $0x55,%al
  8002e5:	0f 87 9c 02 00 00    	ja     800587 <vprintfmt+0x313>
  8002eb:	0f b6 c0             	movzbl %al,%eax
  8002ee:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002f5:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8002f9:	eb d7                	jmp    8002d2 <vprintfmt+0x5e>
  8002fb:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8002ff:	eb d1                	jmp    8002d2 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800301:	89 d9                	mov    %ebx,%ecx
  800303:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80030d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800310:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800314:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800317:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80031b:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  80031c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80031f:	83 f8 09             	cmp    $0x9,%eax
  800322:	77 21                	ja     800345 <vprintfmt+0xd1>
  800324:	eb e4                	jmp    80030a <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800326:	8b 55 14             	mov    0x14(%ebp),%edx
  800329:	8d 42 04             	lea    0x4(%edx),%eax
  80032c:	89 45 14             	mov    %eax,0x14(%ebp)
  80032f:	8b 12                	mov    (%edx),%edx
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800334:	eb 12                	jmp    800348 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800336:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80033a:	79 96                	jns    8002d2 <vprintfmt+0x5e>
  80033c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800343:	eb 8d                	jmp    8002d2 <vprintfmt+0x5e>
  800345:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800348:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80034c:	79 84                	jns    8002d2 <vprintfmt+0x5e>
  80034e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80035b:	e9 72 ff ff ff       	jmp    8002d2 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800360:	ff 45 d4             	incl   -0x2c(%ebp)
  800363:	e9 6a ff ff ff       	jmp    8002d2 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800368:	8b 55 14             	mov    0x14(%ebp),%edx
  80036b:	8d 42 04             	lea    0x4(%edx),%eax
  80036e:	89 45 14             	mov    %eax,0x14(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	57                   	push   %edi
  800375:	ff 32                	pushl  (%edx)
  800377:	ff d6                	call   *%esi
			break;
  800379:	83 c4 10             	add    $0x10,%esp
  80037c:	e9 07 ff ff ff       	jmp    800288 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800381:	8b 55 14             	mov    0x14(%ebp),%edx
  800384:	8d 42 04             	lea    0x4(%edx),%eax
  800387:	89 45 14             	mov    %eax,0x14(%ebp)
  80038a:	8b 02                	mov    (%edx),%eax
  80038c:	85 c0                	test   %eax,%eax
  80038e:	79 02                	jns    800392 <vprintfmt+0x11e>
  800390:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	83 f8 0f             	cmp    $0xf,%eax
  800395:	7f 0b                	jg     8003a2 <vprintfmt+0x12e>
  800397:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	75 15                	jne    8003b7 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 83 0f 80 00       	push   $0x800f83
  8003a8:	57                   	push   %edi
  8003a9:	56                   	push   %esi
  8003aa:	e8 6e 02 00 00       	call   80061d <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	e9 d1 fe ff ff       	jmp    800288 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003b7:	52                   	push   %edx
  8003b8:	68 8c 0f 80 00       	push   $0x800f8c
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	e8 59 02 00 00       	call   80061d <printfmt>
  8003c4:	83 c4 10             	add    $0x10,%esp
  8003c7:	e9 bc fe ff ff       	jmp    800288 <vprintfmt+0x14>
  8003cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003cf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d5:	8b 55 14             	mov    0x14(%ebp),%edx
  8003d8:	8d 42 04             	lea    0x4(%edx),%eax
  8003db:	89 45 14             	mov    %eax,0x14(%ebp)
  8003de:	8b 1a                	mov    (%edx),%ebx
  8003e0:	85 db                	test   %ebx,%ebx
  8003e2:	75 05                	jne    8003e9 <vprintfmt+0x175>
  8003e4:	bb 8f 0f 80 00       	mov    $0x800f8f,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8003e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8003ed:	7e 66                	jle    800455 <vprintfmt+0x1e1>
  8003ef:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8003f3:	74 60                	je     800455 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	51                   	push   %ecx
  8003f9:	53                   	push   %ebx
  8003fa:	e8 57 02 00 00       	call   800656 <strnlen>
  8003ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800402:	29 c1                	sub    %eax,%ecx
  800404:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80040e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800411:	eb 0f                	jmp    800422 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	57                   	push   %edi
  800417:	ff 75 c4             	pushl  -0x3c(%ebp)
  80041a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041c:	ff 4d d8             	decl   -0x28(%ebp)
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800426:	7f eb                	jg     800413 <vprintfmt+0x19f>
  800428:	eb 2b                	jmp    800455 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042a:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	74 15                	je     800448 <vprintfmt+0x1d4>
  800433:	8d 42 e0             	lea    -0x20(%edx),%eax
  800436:	83 f8 5e             	cmp    $0x5e,%eax
  800439:	76 0d                	jbe    800448 <vprintfmt+0x1d4>
					putch('?', putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	57                   	push   %edi
  80043f:	6a 3f                	push   $0x3f
  800441:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	eb 0a                	jmp    800452 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	57                   	push   %edi
  80044c:	52                   	push   %edx
  80044d:	ff d6                	call   *%esi
  80044f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800452:	ff 4d d8             	decl   -0x28(%ebp)
  800455:	8a 03                	mov    (%ebx),%al
  800457:	43                   	inc    %ebx
  800458:	84 c0                	test   %al,%al
  80045a:	74 1b                	je     800477 <vprintfmt+0x203>
  80045c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800460:	78 c8                	js     80042a <vprintfmt+0x1b6>
  800462:	ff 4d dc             	decl   -0x24(%ebp)
  800465:	79 c3                	jns    80042a <vprintfmt+0x1b6>
  800467:	eb 0e                	jmp    800477 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	57                   	push   %edi
  80046d:	6a 20                	push   $0x20
  80046f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800471:	ff 4d d8             	decl   -0x28(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047b:	7f ec                	jg     800469 <vprintfmt+0x1f5>
  80047d:	e9 06 fe ff ff       	jmp    800288 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800482:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800486:	7e 10                	jle    800498 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800488:	8b 55 14             	mov    0x14(%ebp),%edx
  80048b:	8d 42 08             	lea    0x8(%edx),%eax
  80048e:	89 45 14             	mov    %eax,0x14(%ebp)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	8b 52 04             	mov    0x4(%edx),%edx
  800496:	eb 20                	jmp    8004b8 <vprintfmt+0x244>
	else if (lflag)
  800498:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049c:	74 0e                	je     8004ac <vprintfmt+0x238>
		return va_arg(*ap, long);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	99                   	cltd   
  8004aa:	eb 0c                	jmp    8004b8 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004b8:	89 d1                	mov    %edx,%ecx
  8004ba:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c2:	85 c9                	test   %ecx,%ecx
  8004c4:	78 0a                	js     8004d0 <vprintfmt+0x25c>
  8004c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004cb:	e9 89 00 00 00       	jmp    800559 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	57                   	push   %edi
  8004d4:	6a 2d                	push   $0x2d
  8004d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004de:	f7 da                	neg    %edx
  8004e0:	83 d1 00             	adc    $0x0,%ecx
  8004e3:	f7 d9                	neg    %ecx
  8004e5:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	eb 6a                	jmp    800559 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004f5:	e8 22 fd ff ff       	call   80021c <getuint>
  8004fa:	89 d1                	mov    %edx,%ecx
  8004fc:	89 c2                	mov    %eax,%edx
  8004fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800503:	eb 54                	jmp    800559 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800505:	8d 45 14             	lea    0x14(%ebp),%eax
  800508:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050b:	e8 0c fd ff ff       	call   80021c <getuint>
  800510:	89 d1                	mov    %edx,%ecx
  800512:	89 c2                	mov    %eax,%edx
  800514:	bb 08 00 00 00       	mov    $0x8,%ebx
  800519:	eb 3e                	jmp    800559 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	57                   	push   %edi
  80051f:	6a 30                	push   $0x30
  800521:	ff d6                	call   *%esi
			putch('x', putdat);
  800523:	83 c4 08             	add    $0x8,%esp
  800526:	57                   	push   %edi
  800527:	6a 78                	push   $0x78
  800529:	ff d6                	call   *%esi
			num = (unsigned long long)
  80052b:	8b 55 14             	mov    0x14(%ebp),%edx
  80052e:	8d 42 04             	lea    0x4(%edx),%eax
  800531:	89 45 14             	mov    %eax,0x14(%ebp)
  800534:	8b 12                	mov    (%edx),%edx
  800536:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 14                	jmp    800559 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800545:	8d 45 14             	lea    0x14(%ebp),%eax
  800548:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054b:	e8 cc fc ff ff       	call   80021c <getuint>
  800550:	89 d1                	mov    %edx,%ecx
  800552:	89 c2                	mov    %eax,%edx
  800554:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800559:	83 ec 0c             	sub    $0xc,%esp
  80055c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800560:	50                   	push   %eax
  800561:	ff 75 d8             	pushl  -0x28(%ebp)
  800564:	53                   	push   %ebx
  800565:	51                   	push   %ecx
  800566:	52                   	push   %edx
  800567:	89 fa                	mov    %edi,%edx
  800569:	89 f0                	mov    %esi,%eax
  80056b:	e8 08 fc ff ff       	call   800178 <printnum>
			break;
  800570:	83 c4 20             	add    $0x20,%esp
  800573:	e9 10 fd ff ff       	jmp    800288 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	57                   	push   %edi
  80057c:	52                   	push   %edx
  80057d:	ff d6                	call   *%esi
			break;
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	e9 01 fd ff ff       	jmp    800288 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	57                   	push   %edi
  80058b:	6a 25                	push   $0x25
  80058d:	ff d6                	call   *%esi
  80058f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800592:	83 ea 02             	sub    $0x2,%edx
  800595:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800598:	8a 02                	mov    (%edx),%al
  80059a:	4a                   	dec    %edx
  80059b:	3c 25                	cmp    $0x25,%al
  80059d:	75 f9                	jne    800598 <vprintfmt+0x324>
  80059f:	83 c2 02             	add    $0x2,%edx
  8005a2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005a5:	e9 de fc ff ff       	jmp    800288 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ad:	5b                   	pop    %ebx
  8005ae:	5e                   	pop    %esi
  8005af:	5f                   	pop    %edi
  8005b0:	c9                   	leave  
  8005b1:	c3                   	ret    

008005b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	83 ec 18             	sub    $0x18,%esp
  8005b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	74 37                	je     8005f9 <vsnprintf+0x47>
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	7e 33                	jle    8005f9 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005cd:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8005d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8005d4:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005d7:	ff 75 14             	pushl  0x14(%ebp)
  8005da:	ff 75 10             	pushl  0x10(%ebp)
  8005dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e0:	50                   	push   %eax
  8005e1:	68 58 02 80 00       	push   $0x800258
  8005e6:	e8 89 fc ff ff       	call   800274 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb 05                	jmp    8005fe <vsnprintf+0x4c>
  8005f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80060c:	50                   	push   %eax
  80060d:	ff 75 10             	pushl  0x10(%ebp)
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	ff 75 08             	pushl  0x8(%ebp)
  800616:	e8 97 ff ff ff       	call   8005b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  80061b:	c9                   	leave  
  80061c:	c3                   	ret    

0080061d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800629:	50                   	push   %eax
  80062a:	ff 75 10             	pushl  0x10(%ebp)
  80062d:	ff 75 0c             	pushl  0xc(%ebp)
  800630:	ff 75 08             	pushl  0x8(%ebp)
  800633:	e8 3c fc ff ff       	call   800274 <vprintfmt>
	va_end(ap);
  800638:	83 c4 10             	add    $0x10,%esp
}
  80063b:	c9                   	leave  
  80063c:	c3                   	ret    
  80063d:	00 00                	add    %al,(%eax)
	...

00800640 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800640:	55                   	push   %ebp
  800641:	89 e5                	mov    %esp,%ebp
  800643:	8b 55 08             	mov    0x8(%ebp),%edx
  800646:	b8 00 00 00 00       	mov    $0x0,%eax
  80064b:	eb 01                	jmp    80064e <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  80064d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80064e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800652:	75 f9                	jne    80064d <strlen+0xd>
		n++;
	return n;
}
  800654:	c9                   	leave  
  800655:	c3                   	ret    

00800656 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80065c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065f:	b8 00 00 00 00       	mov    $0x0,%eax
  800664:	eb 01                	jmp    800667 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800666:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800667:	39 d0                	cmp    %edx,%eax
  800669:	74 06                	je     800671 <strnlen+0x1b>
  80066b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80066f:	75 f5                	jne    800666 <strnlen+0x10>
		n++;
	return n;
}
  800671:	c9                   	leave  
  800672:	c3                   	ret    

00800673 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800679:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80067c:	8a 01                	mov    (%ecx),%al
  80067e:	88 02                	mov    %al,(%edx)
  800680:	42                   	inc    %edx
  800681:	41                   	inc    %ecx
  800682:	84 c0                	test   %al,%al
  800684:	75 f6                	jne    80067c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	53                   	push   %ebx
  80068f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800692:	53                   	push   %ebx
  800693:	e8 a8 ff ff ff       	call   800640 <strlen>
	strcpy(dst + len, src);
  800698:	ff 75 0c             	pushl  0xc(%ebp)
  80069b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80069e:	50                   	push   %eax
  80069f:	e8 cf ff ff ff       	call   800673 <strcpy>
	return dst;
}
  8006a4:	89 d8                	mov    %ebx,%eax
  8006a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	eb 0c                	jmp    8006cc <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006c0:	8a 02                	mov    (%edx),%al
  8006c2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8006c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006cb:	41                   	inc    %ecx
  8006cc:	39 d9                	cmp    %ebx,%ecx
  8006ce:	75 f0                	jne    8006c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	5b                   	pop    %ebx
  8006d3:	5e                   	pop    %esi
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	56                   	push   %esi
  8006da:	53                   	push   %ebx
  8006db:	8b 75 08             	mov    0x8(%ebp),%esi
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	75 04                	jne    8006ec <strlcpy+0x16>
  8006e8:	89 f0                	mov    %esi,%eax
  8006ea:	eb 14                	jmp    800700 <strlcpy+0x2a>
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	eb 04                	jmp    8006f4 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006f0:	88 10                	mov    %dl,(%eax)
  8006f2:	40                   	inc    %eax
  8006f3:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8006f4:	49                   	dec    %ecx
  8006f5:	74 06                	je     8006fd <strlcpy+0x27>
  8006f7:	8a 13                	mov    (%ebx),%dl
  8006f9:	84 d2                	test   %dl,%dl
  8006fb:	75 f3                	jne    8006f0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8006fd:	c6 00 00             	movb   $0x0,(%eax)
  800700:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 55 08             	mov    0x8(%ebp),%edx
  80070c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070f:	eb 02                	jmp    800713 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800711:	42                   	inc    %edx
  800712:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800713:	8a 02                	mov    (%edx),%al
  800715:	84 c0                	test   %al,%al
  800717:	74 04                	je     80071d <strcmp+0x17>
  800719:	3a 01                	cmp    (%ecx),%al
  80071b:	74 f4                	je     800711 <strcmp+0xb>
  80071d:	0f b6 c0             	movzbl %al,%eax
  800720:	0f b6 11             	movzbl (%ecx),%edx
  800723:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800731:	8b 55 10             	mov    0x10(%ebp),%edx
  800734:	eb 03                	jmp    800739 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800736:	4a                   	dec    %edx
  800737:	41                   	inc    %ecx
  800738:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800739:	85 d2                	test   %edx,%edx
  80073b:	75 07                	jne    800744 <strncmp+0x1d>
  80073d:	b8 00 00 00 00       	mov    $0x0,%eax
  800742:	eb 14                	jmp    800758 <strncmp+0x31>
  800744:	8a 01                	mov    (%ecx),%al
  800746:	84 c0                	test   %al,%al
  800748:	74 04                	je     80074e <strncmp+0x27>
  80074a:	3a 03                	cmp    (%ebx),%al
  80074c:	74 e8                	je     800736 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80074e:	0f b6 d0             	movzbl %al,%edx
  800751:	0f b6 03             	movzbl (%ebx),%eax
  800754:	29 c2                	sub    %eax,%edx
  800756:	89 d0                	mov    %edx,%eax
}
  800758:	5b                   	pop    %ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800764:	eb 05                	jmp    80076b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800766:	38 ca                	cmp    %cl,%dl
  800768:	74 0c                	je     800776 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80076a:	40                   	inc    %eax
  80076b:	8a 10                	mov    (%eax),%dl
  80076d:	84 d2                	test   %dl,%dl
  80076f:	75 f5                	jne    800766 <strchr+0xb>
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800781:	eb 05                	jmp    800788 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800783:	38 ca                	cmp    %cl,%dl
  800785:	74 07                	je     80078e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800787:	40                   	inc    %eax
  800788:	8a 10                	mov    (%eax),%dl
  80078a:	84 d2                	test   %dl,%dl
  80078c:	75 f5                	jne    800783 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	57                   	push   %edi
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	8b 7d 08             	mov    0x8(%ebp),%edi
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80079f:	85 db                	test   %ebx,%ebx
  8007a1:	74 36                	je     8007d9 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007a9:	75 29                	jne    8007d4 <memset+0x44>
  8007ab:	f6 c3 03             	test   $0x3,%bl
  8007ae:	75 24                	jne    8007d4 <memset+0x44>
		c &= 0xFF;
  8007b0:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007b3:	89 d6                	mov    %edx,%esi
  8007b5:	c1 e6 08             	shl    $0x8,%esi
  8007b8:	89 d0                	mov    %edx,%eax
  8007ba:	c1 e0 18             	shl    $0x18,%eax
  8007bd:	89 d1                	mov    %edx,%ecx
  8007bf:	c1 e1 10             	shl    $0x10,%ecx
  8007c2:	09 c8                	or     %ecx,%eax
  8007c4:	09 c2                	or     %eax,%edx
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	09 d0                	or     %edx,%eax
  8007ca:	89 d9                	mov    %ebx,%ecx
  8007cc:	c1 e9 02             	shr    $0x2,%ecx
  8007cf:	fc                   	cld    
  8007d0:	f3 ab                	rep stos %eax,%es:(%edi)
  8007d2:	eb 05                	jmp    8007d9 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007d4:	89 d9                	mov    %ebx,%ecx
  8007d6:	fc                   	cld    
  8007d7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8007d9:	89 f8                	mov    %edi,%eax
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5f                   	pop    %edi
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	57                   	push   %edi
  8007e4:	56                   	push   %esi
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007ee:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007f0:	39 c6                	cmp    %eax,%esi
  8007f2:	73 36                	jae    80082a <memmove+0x4a>
  8007f4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007f7:	39 d0                	cmp    %edx,%eax
  8007f9:	73 2f                	jae    80082a <memmove+0x4a>
		s += n;
		d += n;
  8007fb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8007fe:	f6 c2 03             	test   $0x3,%dl
  800801:	75 1b                	jne    80081e <memmove+0x3e>
  800803:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800809:	75 13                	jne    80081e <memmove+0x3e>
  80080b:	f6 c1 03             	test   $0x3,%cl
  80080e:	75 0e                	jne    80081e <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800810:	8d 7e fc             	lea    -0x4(%esi),%edi
  800813:	8d 72 fc             	lea    -0x4(%edx),%esi
  800816:	c1 e9 02             	shr    $0x2,%ecx
  800819:	fd                   	std    
  80081a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80081c:	eb 09                	jmp    800827 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80081e:	8d 7e ff             	lea    -0x1(%esi),%edi
  800821:	8d 72 ff             	lea    -0x1(%edx),%esi
  800824:	fd                   	std    
  800825:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800827:	fc                   	cld    
  800828:	eb 20                	jmp    80084a <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80082a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800830:	75 15                	jne    800847 <memmove+0x67>
  800832:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800838:	75 0d                	jne    800847 <memmove+0x67>
  80083a:	f6 c1 03             	test   $0x3,%cl
  80083d:	75 08                	jne    800847 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80083f:	c1 e9 02             	shr    $0x2,%ecx
  800842:	fc                   	cld    
  800843:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800845:	eb 03                	jmp    80084a <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800847:	fc                   	cld    
  800848:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80084a:	5e                   	pop    %esi
  80084b:	5f                   	pop    %edi
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800851:	ff 75 10             	pushl  0x10(%ebp)
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	ff 75 08             	pushl  0x8(%ebp)
  80085a:	e8 81 ff ff ff       	call   8007e0 <memmove>
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	83 ec 04             	sub    $0x4,%esp
  800868:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80086b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	eb 1b                	jmp    80088e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800873:	8a 1a                	mov    (%edx),%bl
  800875:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800878:	8a 19                	mov    (%ecx),%bl
  80087a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  80087d:	74 0d                	je     80088c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80087f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800883:	0f b6 c3             	movzbl %bl,%eax
  800886:	29 c2                	sub    %eax,%edx
  800888:	89 d0                	mov    %edx,%eax
  80088a:	eb 0d                	jmp    800899 <memcmp+0x38>
		s1++, s2++;
  80088c:	42                   	inc    %edx
  80088d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80088e:	48                   	dec    %eax
  80088f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800892:	75 df                	jne    800873 <memcmp+0x12>
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800899:	83 c4 04             	add    $0x4,%esp
  80089c:	5b                   	pop    %ebx
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	03 55 10             	add    0x10(%ebp),%edx
  8008ad:	eb 05                	jmp    8008b4 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008af:	38 08                	cmp    %cl,(%eax)
  8008b1:	74 05                	je     8008b8 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008b3:	40                   	inc    %eax
  8008b4:	39 d0                	cmp    %edx,%eax
  8008b6:	72 f7                	jb     8008af <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	83 ec 04             	sub    $0x4,%esp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c9:	eb 01                	jmp    8008cc <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008cb:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008cc:	8a 01                	mov    (%ecx),%al
  8008ce:	3c 20                	cmp    $0x20,%al
  8008d0:	74 f9                	je     8008cb <strtol+0x11>
  8008d2:	3c 09                	cmp    $0x9,%al
  8008d4:	74 f5                	je     8008cb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8008d6:	3c 2b                	cmp    $0x2b,%al
  8008d8:	75 0a                	jne    8008e4 <strtol+0x2a>
		s++;
  8008da:	41                   	inc    %ecx
  8008db:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008e2:	eb 17                	jmp    8008fb <strtol+0x41>
	else if (*s == '-')
  8008e4:	3c 2d                	cmp    $0x2d,%al
  8008e6:	74 09                	je     8008f1 <strtol+0x37>
  8008e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008ef:	eb 0a                	jmp    8008fb <strtol+0x41>
		s++, neg = 1;
  8008f1:	8d 49 01             	lea    0x1(%ecx),%ecx
  8008f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008fb:	85 f6                	test   %esi,%esi
  8008fd:	74 05                	je     800904 <strtol+0x4a>
  8008ff:	83 fe 10             	cmp    $0x10,%esi
  800902:	75 1a                	jne    80091e <strtol+0x64>
  800904:	8a 01                	mov    (%ecx),%al
  800906:	3c 30                	cmp    $0x30,%al
  800908:	75 10                	jne    80091a <strtol+0x60>
  80090a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80090e:	75 0a                	jne    80091a <strtol+0x60>
		s += 2, base = 16;
  800910:	83 c1 02             	add    $0x2,%ecx
  800913:	be 10 00 00 00       	mov    $0x10,%esi
  800918:	eb 04                	jmp    80091e <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80091a:	85 f6                	test   %esi,%esi
  80091c:	74 07                	je     800925 <strtol+0x6b>
  80091e:	bf 00 00 00 00       	mov    $0x0,%edi
  800923:	eb 13                	jmp    800938 <strtol+0x7e>
  800925:	3c 30                	cmp    $0x30,%al
  800927:	74 07                	je     800930 <strtol+0x76>
  800929:	be 0a 00 00 00       	mov    $0xa,%esi
  80092e:	eb ee                	jmp    80091e <strtol+0x64>
		s++, base = 8;
  800930:	41                   	inc    %ecx
  800931:	be 08 00 00 00       	mov    $0x8,%esi
  800936:	eb e6                	jmp    80091e <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800938:	8a 11                	mov    (%ecx),%dl
  80093a:	88 d3                	mov    %dl,%bl
  80093c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80093f:	3c 09                	cmp    $0x9,%al
  800941:	77 08                	ja     80094b <strtol+0x91>
			dig = *s - '0';
  800943:	0f be c2             	movsbl %dl,%eax
  800946:	8d 50 d0             	lea    -0x30(%eax),%edx
  800949:	eb 1c                	jmp    800967 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80094b:	8d 43 9f             	lea    -0x61(%ebx),%eax
  80094e:	3c 19                	cmp    $0x19,%al
  800950:	77 08                	ja     80095a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800952:	0f be c2             	movsbl %dl,%eax
  800955:	8d 50 a9             	lea    -0x57(%eax),%edx
  800958:	eb 0d                	jmp    800967 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80095a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  80095d:	3c 19                	cmp    $0x19,%al
  80095f:	77 15                	ja     800976 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800961:	0f be c2             	movsbl %dl,%eax
  800964:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800967:	39 f2                	cmp    %esi,%edx
  800969:	7d 0b                	jge    800976 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  80096b:	41                   	inc    %ecx
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	0f af c6             	imul   %esi,%eax
  800971:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800974:	eb c2                	jmp    800938 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800976:	89 f8                	mov    %edi,%eax

	if (endptr)
  800978:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80097c:	74 05                	je     800983 <strtol+0xc9>
		*endptr = (char *) s;
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800983:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800987:	74 04                	je     80098d <strtol+0xd3>
  800989:	89 c7                	mov    %eax,%edi
  80098b:	f7 df                	neg    %edi
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	83 c4 04             	add    $0x4,%esp
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	c9                   	leave  
  800996:	c3                   	ret    
	...

00800998 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80099e:	b8 01 00 00 00       	mov    $0x1,%eax
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a8:	89 fa                	mov    %edi,%edx
  8009aa:	89 f9                	mov    %edi,%ecx
  8009ac:	89 fb                	mov    %edi,%ebx
  8009ae:	89 fe                	mov    %edi,%esi
  8009b0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	83 ec 04             	sub    $0x4,%esp
  8009c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	89 fb                	mov    %edi,%ebx
  8009cf:	89 fe                	mov    %edi,%esi
  8009d1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009d3:	83 c4 04             	add    $0x4,%esp
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009e7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f1:	89 f9                	mov    %edi,%ecx
  8009f3:	89 fb                	mov    %edi,%ebx
  8009f5:	89 fe                	mov    %edi,%esi
  8009f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8009f9:	85 c0                	test   %eax,%eax
  8009fb:	7e 17                	jle    800a14 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	50                   	push   %eax
  800a01:	6a 0d                	push   $0xd
  800a03:	68 7f 12 80 00       	push   $0x80127f
  800a08:	6a 23                	push   $0x23
  800a0a:	68 9c 12 80 00       	push   $0x80129c
  800a0f:	e8 38 02 00 00       	call   800c4c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5f                   	pop    %edi
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 55 08             	mov    0x8(%ebp),%edx
  800a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a2b:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a33:	be 00 00 00 00       	mov    $0x0,%esi
  800a38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	83 ec 0c             	sub    $0xc,%esp
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
  800a58:	89 fb                	mov    %edi,%ebx
  800a5a:	89 fe                	mov    %edi,%esi
  800a5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	7e 17                	jle    800a79 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	50                   	push   %eax
  800a66:	6a 0a                	push   $0xa
  800a68:	68 7f 12 80 00       	push   $0x80127f
  800a6d:	6a 23                	push   $0x23
  800a6f:	68 9c 12 80 00       	push   $0x80129c
  800a74:	e8 d3 01 00 00       	call   800c4c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	83 ec 0c             	sub    $0xc,%esp
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	b8 09 00 00 00       	mov    $0x9,%eax
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9a:	89 fb                	mov    %edi,%ebx
  800a9c:	89 fe                	mov    %edi,%esi
  800a9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	7e 17                	jle    800abb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	50                   	push   %eax
  800aa8:	6a 09                	push   $0x9
  800aaa:	68 7f 12 80 00       	push   $0x80127f
  800aaf:	6a 23                	push   $0x23
  800ab1:	68 9c 12 80 00       	push   $0x80129c
  800ab6:	e8 91 01 00 00       	call   800c4c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ad7:	bf 00 00 00 00       	mov    $0x0,%edi
  800adc:	89 fb                	mov    %edi,%ebx
  800ade:	89 fe                	mov    %edi,%esi
  800ae0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	7e 17                	jle    800afd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	50                   	push   %eax
  800aea:	6a 08                	push   $0x8
  800aec:	68 7f 12 80 00       	push   $0x80127f
  800af1:	6a 23                	push   $0x23
  800af3:	68 9c 12 80 00       	push   $0x80129c
  800af8:	e8 4f 01 00 00       	call   800c4c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	b8 06 00 00 00       	mov    $0x6,%eax
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	89 fb                	mov    %edi,%ebx
  800b20:	89 fe                	mov    %edi,%esi
  800b22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b24:	85 c0                	test   %eax,%eax
  800b26:	7e 17                	jle    800b3f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	50                   	push   %eax
  800b2c:	6a 06                	push   $0x6
  800b2e:	68 7f 12 80 00       	push   $0x80127f
  800b33:	6a 23                	push   $0x23
  800b35:	68 9c 12 80 00       	push   $0x80129c
  800b3a:	e8 0d 01 00 00       	call   800c4c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 0c             	sub    $0xc,%esp
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5c:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b66:	85 c0                	test   %eax,%eax
  800b68:	7e 17                	jle    800b81 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	50                   	push   %eax
  800b6e:	6a 05                	push   $0x5
  800b70:	68 7f 12 80 00       	push   $0x80127f
  800b75:	6a 23                	push   $0x23
  800b77:	68 9c 12 80 00       	push   $0x80129c
  800b7c:	e8 cb 00 00 00       	call   800c4c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	89 fe                	mov    %edi,%esi
  800ba7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 04                	push   $0x4
  800bb3:	68 7f 12 80 00       	push   $0x80127f
  800bb8:	6a 23                	push   $0x23
  800bba:	68 9c 12 80 00       	push   $0x80129c
  800bbf:	e8 88 00 00 00       	call   800c4c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdc:	89 fa                	mov    %edi,%edx
  800bde:	89 f9                	mov    %edi,%ecx
  800be0:	89 fb                	mov    %edi,%ebx
  800be2:	89 fe                	mov    %edi,%esi
  800be4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfb:	89 fa                	mov    %edi,%edx
  800bfd:	89 f9                	mov    %edi,%ecx
  800bff:	89 fb                	mov    %edi,%ebx
  800c01:	89 fe                	mov    %edi,%esi
  800c03:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c20:	89 f9                	mov    %edi,%ecx
  800c22:	89 fb                	mov    %edi,%ebx
  800c24:	89 fe                	mov    %edi,%esi
  800c26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7e 17                	jle    800c43 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 03                	push   $0x3
  800c32:	68 7f 12 80 00       	push   $0x80127f
  800c37:	6a 23                	push   $0x23
  800c39:	68 9c 12 80 00       	push   $0x80129c
  800c3e:	e8 09 00 00 00       	call   800c4c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    
	...

00800c4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800c53:	8d 45 14             	lea    0x14(%ebp),%eax
  800c56:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c59:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c5f:	e8 87 ff ff ff       	call   800beb <sys_getenvid>
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	ff 75 08             	pushl  0x8(%ebp)
  800c6d:	53                   	push   %ebx
  800c6e:	50                   	push   %eax
  800c6f:	68 ac 12 80 00       	push   $0x8012ac
  800c74:	e8 a8 f4 ff ff       	call   800121 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c79:	83 c4 18             	add    $0x18,%esp
  800c7c:	ff 75 f8             	pushl  -0x8(%ebp)
  800c7f:	ff 75 10             	pushl  0x10(%ebp)
  800c82:	e8 49 f4 ff ff       	call   8000d0 <vcprintf>
	cprintf("\n");
  800c87:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800c8e:	e8 8e f4 ff ff       	call   800121 <cprintf>
  800c93:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c96:	cc                   	int3   
  800c97:	eb fd                	jmp    800c96 <_panic+0x4a>
  800c99:	00 00                	add    %al,(%eax)
	...

00800c9c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	83 ec 28             	sub    $0x28,%esp
  800ca4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800cab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800cb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cbb:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800cbd:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc8:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ccb:	85 ff                	test   %edi,%edi
  800ccd:	75 21                	jne    800cf0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800ccf:	39 d1                	cmp    %edx,%ecx
  800cd1:	76 49                	jbe    800d1c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cd3:	f7 f1                	div    %ecx
  800cd5:	89 c1                	mov    %eax,%ecx
  800cd7:	31 c0                	xor    %eax,%eax
  800cd9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cdc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cdf:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ce2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ce5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ce8:	83 c4 28             	add    $0x28,%esp
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    
  800cef:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cf0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cf3:	0f 87 97 00 00 00    	ja     800d90 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cfc:	83 f0 1f             	xor    $0x1f,%eax
  800cff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d02:	75 34                	jne    800d38 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d04:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d07:	72 08                	jb     800d11 <__udivdi3+0x75>
  800d09:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d0c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d0f:	77 7f                	ja     800d90 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d11:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d16:	31 c0                	xor    %eax,%eax
  800d18:	eb c2                	jmp    800cdc <__udivdi3+0x40>
  800d1a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	74 79                	je     800d9c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d26:	89 fa                	mov    %edi,%edx
  800d28:	f7 f1                	div    %ecx
  800d2a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d2f:	f7 f1                	div    %ecx
  800d31:	89 c1                	mov    %eax,%ecx
  800d33:	89 f0                	mov    %esi,%eax
  800d35:	eb a5                	jmp    800cdc <__udivdi3+0x40>
  800d37:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d38:	b8 20 00 00 00       	mov    $0x20,%eax
  800d3d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d43:	89 fa                	mov    %edi,%edx
  800d45:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d48:	d3 e2                	shl    %cl,%edx
  800d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d50:	d3 e8                	shr    %cl,%eax
  800d52:	89 d7                	mov    %edx,%edi
  800d54:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d56:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d59:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d5c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d61:	d3 e0                	shl    %cl,%eax
  800d63:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d66:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d69:	d3 ea                	shr    %cl,%edx
  800d6b:	09 d0                	or     %edx,%eax
  800d6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d70:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d73:	d3 ea                	shr    %cl,%edx
  800d75:	f7 f7                	div    %edi
  800d77:	89 d7                	mov    %edx,%edi
  800d79:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d7c:	f7 e6                	mul    %esi
  800d7e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d80:	39 d7                	cmp    %edx,%edi
  800d82:	72 38                	jb     800dbc <__udivdi3+0x120>
  800d84:	74 27                	je     800dad <__udivdi3+0x111>
  800d86:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d89:	31 c0                	xor    %eax,%eax
  800d8b:	e9 4c ff ff ff       	jmp    800cdc <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d90:	31 c9                	xor    %ecx,%ecx
  800d92:	31 c0                	xor    %eax,%eax
  800d94:	e9 43 ff ff ff       	jmp    800cdc <__udivdi3+0x40>
  800d99:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	f7 75 f4             	divl   -0xc(%ebp)
  800da6:	89 c1                	mov    %eax,%ecx
  800da8:	e9 76 ff ff ff       	jmp    800d23 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800db0:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800db3:	d3 e0                	shl    %cl,%eax
  800db5:	39 f0                	cmp    %esi,%eax
  800db7:	73 cd                	jae    800d86 <__udivdi3+0xea>
  800db9:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dbc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800dbf:	49                   	dec    %ecx
  800dc0:	31 c0                	xor    %eax,%eax
  800dc2:	e9 15 ff ff ff       	jmp    800cdc <__udivdi3+0x40>
	...

00800dc8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	83 ec 30             	sub    $0x30,%esp
  800dd0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dd7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dde:	8b 75 08             	mov    0x8(%ebp),%esi
  800de1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800de4:	8b 45 10             	mov    0x10(%ebp),%eax
  800de7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ded:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800def:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800df2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800df5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df8:	85 d2                	test   %edx,%edx
  800dfa:	75 1c                	jne    800e18 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800dfc:	89 fa                	mov    %edi,%edx
  800dfe:	39 f8                	cmp    %edi,%eax
  800e00:	0f 86 c2 00 00 00    	jbe    800ec8 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e06:	89 f0                	mov    %esi,%eax
  800e08:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e0a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e0d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e14:	eb 12                	jmp    800e28 <__umoddi3+0x60>
  800e16:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e18:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e1b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e1e:	76 18                	jbe    800e38 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e20:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e23:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e26:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e28:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e2e:	83 c4 30             	add    $0x30,%esp
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e38:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e3c:	83 f0 1f             	xor    $0x1f,%eax
  800e3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e42:	0f 84 ac 00 00 00    	je     800ef4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e48:	b8 20 00 00 00       	mov    $0x20,%eax
  800e4d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e53:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e56:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e61:	d3 e8                	shr    %cl,%eax
  800e63:	89 d6                	mov    %edx,%esi
  800e65:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e6a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e6d:	d3 e0                	shl    %cl,%eax
  800e6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e72:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e75:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e7a:	d3 e0                	shl    %cl,%eax
  800e7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e7f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e82:	d3 ea                	shr    %cl,%edx
  800e84:	09 d0                	or     %edx,%eax
  800e86:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e89:	d3 ea                	shr    %cl,%edx
  800e8b:	f7 f6                	div    %esi
  800e8d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e90:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e93:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e96:	0f 82 8d 00 00 00    	jb     800f29 <__umoddi3+0x161>
  800e9c:	0f 84 91 00 00 00    	je     800f33 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ea2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ea5:	29 c7                	sub    %eax,%edi
  800ea7:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea9:	89 f2                	mov    %esi,%edx
  800eab:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eae:	d3 e2                	shl    %cl,%edx
  800eb0:	89 f8                	mov    %edi,%eax
  800eb2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800eb5:	d3 e8                	shr    %cl,%eax
  800eb7:	09 c2                	or     %eax,%edx
  800eb9:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800ebc:	d3 ee                	shr    %cl,%esi
  800ebe:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ec1:	e9 62 ff ff ff       	jmp    800e28 <__umoddi3+0x60>
  800ec6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ec8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	74 15                	je     800ee4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ecf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ed5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eda:	f7 f1                	div    %ecx
  800edc:	e9 29 ff ff ff       	jmp    800e0a <__umoddi3+0x42>
  800ee1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ee4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee9:	31 d2                	xor    %edx,%edx
  800eeb:	f7 75 ec             	divl   -0x14(%ebp)
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	eb dd                	jmp    800ecf <__umoddi3+0x107>
  800ef2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800efa:	72 19                	jb     800f15 <__umoddi3+0x14d>
  800efc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eff:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800f02:	76 11                	jbe    800f15 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f07:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f0a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f0d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f10:	e9 13 ff ff ff       	jmp    800e28 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f15:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f1b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f1e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f24:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f27:	eb db                	jmp    800f04 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f29:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f2c:	19 f2                	sbb    %esi,%edx
  800f2e:	e9 6f ff ff ff       	jmp    800ea2 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f33:	39 c7                	cmp    %eax,%edi
  800f35:	72 f2                	jb     800f29 <__umoddi3+0x161>
  800f37:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3a:	e9 63 ff ff ff       	jmp    800ea2 <__umoddi3+0xda>
