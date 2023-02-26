
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003a:	68 40 0f 80 00       	push   $0x800f40
  80003f:	e8 d1 00 00 00       	call   800115 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id); 
  800044:	a1 04 20 80 00       	mov    0x802004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 4e 0f 80 00       	push   $0x800f4e
  800055:	e8 bb 00 00 00       	call   800115 <cprintf>
  80005a:	83 c4 10             	add    $0x10,%esp
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    
	...

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
  800068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80006b:	e8 6f 0b 00 00       	call   800bdf <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	29 d0                	sub    %edx,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 f6                	test   %esi,%esi
  80008d:	7e 07                	jle    800096 <libmain+0x36>
		binaryname = argv[0];
  80008f:	8b 03                	mov    (%ebx),%eax
  800091:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	53                   	push   %ebx
  80009a:	56                   	push   %esi
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 41 0b 00 00       	call   800bfe <sys_env_destroy>
  8000bd:	83 c4 10             	add    $0x10,%esp
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    
	...

008000c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000cd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000d4:	00 00 00 
	b.cnt = 0;
  8000d7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8000de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e1:	ff 75 0c             	pushl  0xc(%ebp)
  8000e4:	ff 75 08             	pushl  0x8(%ebp)
  8000e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000ed:	50                   	push   %eax
  8000ee:	68 2c 01 80 00       	push   $0x80012c
  8000f3:	e8 70 01 00 00       	call   800268 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f8:	83 c4 08             	add    $0x8,%esp
  8000fb:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800101:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800107:	50                   	push   %eax
  800108:	e8 9e 08 00 00       	call   8009ab <sys_cputs>
  80010d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80011b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80011e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800121:	50                   	push   %eax
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	e8 9a ff ff ff       	call   8000c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 04             	sub    $0x4,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	40                   	inc    %eax
  800140:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800142:	3d ff 00 00 00       	cmp    $0xff,%eax
  800147:	75 1a                	jne    800163 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 51 08 00 00       	call   8009ab <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800163:	ff 43 04             	incl   0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
	...

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 1c             	sub    $0x1c,%esp
  800175:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800178:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800187:	8b 55 10             	mov    0x10(%ebp),%edx
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	89 d6                	mov    %edx,%esi
  80018f:	bf 00 00 00 00       	mov    $0x0,%edi
  800194:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800197:	72 04                	jb     80019d <printnum+0x31>
  800199:	39 c2                	cmp    %eax,%edx
  80019b:	77 3f                	ja     8001dc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	ff 75 18             	pushl  0x18(%ebp)
  8001a3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	52                   	push   %edx
  8001a8:	83 ec 08             	sub    $0x8,%esp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b3:	e8 d8 0a 00 00       	call   800c90 <__udivdi3>
  8001b8:	83 c4 18             	add    $0x18,%esp
  8001bb:	52                   	push   %edx
  8001bc:	50                   	push   %eax
  8001bd:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001c3:	e8 a4 ff ff ff       	call   80016c <printnum>
  8001c8:	83 c4 20             	add    $0x20,%esp
  8001cb:	eb 14                	jmp    8001e1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cd:	83 ec 08             	sub    $0x8,%esp
  8001d0:	ff 75 e8             	pushl  -0x18(%ebp)
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	ff 55 ec             	call   *-0x14(%ebp)
  8001d9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dc:	4b                   	dec    %ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f ec                	jg     8001cd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e8             	pushl  -0x18(%ebp)
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f2:	e8 c5 0b 00 00       	call   800dbc <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 6f 0f 80 00 	movsbl 0x800f6f(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff 55 ec             	call   *-0x14(%ebp)
  800205:	83 c4 10             	add    $0x10,%esp
}
  800208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020b:	5b                   	pop    %ebx
  80020c:	5e                   	pop    %esi
  80020d:	5f                   	pop    %edi
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800215:	83 fa 01             	cmp    $0x1,%edx
  800218:	7e 0e                	jle    800228 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	8d 42 08             	lea    0x8(%edx),%eax
  80021f:	89 01                	mov    %eax,(%ecx)
  800221:	8b 02                	mov    (%edx),%eax
  800223:	8b 52 04             	mov    0x4(%edx),%edx
  800226:	eb 22                	jmp    80024a <getuint+0x3a>
	else if (lflag)
  800228:	85 d2                	test   %edx,%edx
  80022a:	74 10                	je     80023c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 42 04             	lea    0x4(%edx),%eax
  800231:	89 01                	mov    %eax,(%ecx)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
  80023a:	eb 0e                	jmp    80024a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 42 04             	lea    0x4(%edx),%eax
  800241:	89 01                	mov    %eax,(%ecx)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800252:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800255:	8b 11                	mov    (%ecx),%edx
  800257:	3b 51 04             	cmp    0x4(%ecx),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1a>
		*b->buf++ = ch;
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
  800261:	8d 42 01             	lea    0x1(%edx),%eax
  800264:	89 01                	mov    %eax,(%ecx)
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	8b 75 08             	mov    0x8(%ebp),%esi
  800274:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027a:	eb 1a                	jmp    800296 <vprintfmt+0x2e>
  80027c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80027f:	eb 15                	jmp    800296 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800281:	84 c0                	test   %al,%al
  800283:	0f 84 15 03 00 00    	je     80059e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	57                   	push   %edi
  80028d:	0f b6 c0             	movzbl %al,%eax
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	8a 03                	mov    (%ebx),%al
  800298:	43                   	inc    %ebx
  800299:	3c 25                	cmp    $0x25,%al
  80029b:	75 e4                	jne    800281 <vprintfmt+0x19>
  80029d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002ab:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002b9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002bd:	eb 0a                	jmp    8002c9 <vprintfmt+0x61>
  8002bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8002c6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8a 03                	mov    (%ebx),%al
  8002cb:	0f b6 d0             	movzbl %al,%edx
  8002ce:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8002d1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8002d4:	83 e8 23             	sub    $0x23,%eax
  8002d7:	3c 55                	cmp    $0x55,%al
  8002d9:	0f 87 9c 02 00 00    	ja     80057b <vprintfmt+0x313>
  8002df:	0f b6 c0             	movzbl %al,%eax
  8002e2:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002e9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8002ed:	eb d7                	jmp    8002c6 <vprintfmt+0x5e>
  8002ef:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8002f3:	eb d1                	jmp    8002c6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8002f5:	89 d9                	mov    %ebx,%ecx
  8002f7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800301:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800304:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800308:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80030b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80030f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800310:	8d 42 d0             	lea    -0x30(%edx),%eax
  800313:	83 f8 09             	cmp    $0x9,%eax
  800316:	77 21                	ja     800339 <vprintfmt+0xd1>
  800318:	eb e4                	jmp    8002fe <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031a:	8b 55 14             	mov    0x14(%ebp),%edx
  80031d:	8d 42 04             	lea    0x4(%edx),%eax
  800320:	89 45 14             	mov    %eax,0x14(%ebp)
  800323:	8b 12                	mov    (%edx),%edx
  800325:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800328:	eb 12                	jmp    80033c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80032a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80032e:	79 96                	jns    8002c6 <vprintfmt+0x5e>
  800330:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800337:	eb 8d                	jmp    8002c6 <vprintfmt+0x5e>
  800339:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80033c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800340:	79 84                	jns    8002c6 <vprintfmt+0x5e>
  800342:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800345:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800348:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80034f:	e9 72 ff ff ff       	jmp    8002c6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800354:	ff 45 d4             	incl   -0x2c(%ebp)
  800357:	e9 6a ff ff ff       	jmp    8002c6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035c:	8b 55 14             	mov    0x14(%ebp),%edx
  80035f:	8d 42 04             	lea    0x4(%edx),%eax
  800362:	89 45 14             	mov    %eax,0x14(%ebp)
  800365:	83 ec 08             	sub    $0x8,%esp
  800368:	57                   	push   %edi
  800369:	ff 32                	pushl  (%edx)
  80036b:	ff d6                	call   *%esi
			break;
  80036d:	83 c4 10             	add    $0x10,%esp
  800370:	e9 07 ff ff ff       	jmp    80027c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800375:	8b 55 14             	mov    0x14(%ebp),%edx
  800378:	8d 42 04             	lea    0x4(%edx),%eax
  80037b:	89 45 14             	mov    %eax,0x14(%ebp)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	85 c0                	test   %eax,%eax
  800382:	79 02                	jns    800386 <vprintfmt+0x11e>
  800384:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800386:	83 f8 0f             	cmp    $0xf,%eax
  800389:	7f 0b                	jg     800396 <vprintfmt+0x12e>
  80038b:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800392:	85 d2                	test   %edx,%edx
  800394:	75 15                	jne    8003ab <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800396:	50                   	push   %eax
  800397:	68 80 0f 80 00       	push   $0x800f80
  80039c:	57                   	push   %edi
  80039d:	56                   	push   %esi
  80039e:	e8 6e 02 00 00       	call   800611 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a3:	83 c4 10             	add    $0x10,%esp
  8003a6:	e9 d1 fe ff ff       	jmp    80027c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003ab:	52                   	push   %edx
  8003ac:	68 89 0f 80 00       	push   $0x800f89
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	e8 59 02 00 00       	call   800611 <printfmt>
  8003b8:	83 c4 10             	add    $0x10,%esp
  8003bb:	e9 bc fe ff ff       	jmp    80027c <vprintfmt+0x14>
  8003c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003c3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cc:	8d 42 04             	lea    0x4(%edx),%eax
  8003cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d2:	8b 1a                	mov    (%edx),%ebx
  8003d4:	85 db                	test   %ebx,%ebx
  8003d6:	75 05                	jne    8003dd <vprintfmt+0x175>
  8003d8:	bb 8c 0f 80 00       	mov    $0x800f8c,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8003dd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8003e1:	7e 66                	jle    800449 <vprintfmt+0x1e1>
  8003e3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8003e7:	74 60                	je     800449 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	51                   	push   %ecx
  8003ed:	53                   	push   %ebx
  8003ee:	e8 57 02 00 00       	call   80064a <strnlen>
  8003f3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8003f6:	29 c1                	sub    %eax,%ecx
  8003f8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800402:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800405:	eb 0f                	jmp    800416 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	57                   	push   %edi
  80040b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80040e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800410:	ff 4d d8             	decl   -0x28(%ebp)
  800413:	83 c4 10             	add    $0x10,%esp
  800416:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041a:	7f eb                	jg     800407 <vprintfmt+0x19f>
  80041c:	eb 2b                	jmp    800449 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80041e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800425:	74 15                	je     80043c <vprintfmt+0x1d4>
  800427:	8d 42 e0             	lea    -0x20(%edx),%eax
  80042a:	83 f8 5e             	cmp    $0x5e,%eax
  80042d:	76 0d                	jbe    80043c <vprintfmt+0x1d4>
					putch('?', putdat);
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	57                   	push   %edi
  800433:	6a 3f                	push   $0x3f
  800435:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	eb 0a                	jmp    800446 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	57                   	push   %edi
  800440:	52                   	push   %edx
  800441:	ff d6                	call   *%esi
  800443:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800446:	ff 4d d8             	decl   -0x28(%ebp)
  800449:	8a 03                	mov    (%ebx),%al
  80044b:	43                   	inc    %ebx
  80044c:	84 c0                	test   %al,%al
  80044e:	74 1b                	je     80046b <vprintfmt+0x203>
  800450:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800454:	78 c8                	js     80041e <vprintfmt+0x1b6>
  800456:	ff 4d dc             	decl   -0x24(%ebp)
  800459:	79 c3                	jns    80041e <vprintfmt+0x1b6>
  80045b:	eb 0e                	jmp    80046b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	57                   	push   %edi
  800461:	6a 20                	push   $0x20
  800463:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800465:	ff 4d d8             	decl   -0x28(%ebp)
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046f:	7f ec                	jg     80045d <vprintfmt+0x1f5>
  800471:	e9 06 fe ff ff       	jmp    80027c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800476:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80047a:	7e 10                	jle    80048c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80047c:	8b 55 14             	mov    0x14(%ebp),%edx
  80047f:	8d 42 08             	lea    0x8(%edx),%eax
  800482:	89 45 14             	mov    %eax,0x14(%ebp)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	8b 52 04             	mov    0x4(%edx),%edx
  80048a:	eb 20                	jmp    8004ac <vprintfmt+0x244>
	else if (lflag)
  80048c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800490:	74 0e                	je     8004a0 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	99                   	cltd   
  80049e:	eb 0c                	jmp    8004ac <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004ac:	89 d1                	mov    %edx,%ecx
  8004ae:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	78 0a                	js     8004c4 <vprintfmt+0x25c>
  8004ba:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004bf:	e9 89 00 00 00       	jmp    80054d <vprintfmt+0x2e5>
				putch('-', putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	57                   	push   %edi
  8004c8:	6a 2d                	push   $0x2d
  8004ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8004cc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d2:	f7 da                	neg    %edx
  8004d4:	83 d1 00             	adc    $0x0,%ecx
  8004d7:	f7 d9                	neg    %ecx
  8004d9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	eb 6a                	jmp    80054d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8004e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004e9:	e8 22 fd ff ff       	call   800210 <getuint>
  8004ee:	89 d1                	mov    %edx,%ecx
  8004f0:	89 c2                	mov    %eax,%edx
  8004f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004f7:	eb 54                	jmp    80054d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ff:	e8 0c fd ff ff       	call   800210 <getuint>
  800504:	89 d1                	mov    %edx,%ecx
  800506:	89 c2                	mov    %eax,%edx
  800508:	bb 08 00 00 00       	mov    $0x8,%ebx
  80050d:	eb 3e                	jmp    80054d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	57                   	push   %edi
  800513:	6a 30                	push   $0x30
  800515:	ff d6                	call   *%esi
			putch('x', putdat);
  800517:	83 c4 08             	add    $0x8,%esp
  80051a:	57                   	push   %edi
  80051b:	6a 78                	push   $0x78
  80051d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80051f:	8b 55 14             	mov    0x14(%ebp),%edx
  800522:	8d 42 04             	lea    0x4(%edx),%eax
  800525:	89 45 14             	mov    %eax,0x14(%ebp)
  800528:	8b 12                	mov    (%edx),%edx
  80052a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	eb 14                	jmp    80054d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800539:	8d 45 14             	lea    0x14(%ebp),%eax
  80053c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053f:	e8 cc fc ff ff       	call   800210 <getuint>
  800544:	89 d1                	mov    %edx,%ecx
  800546:	89 c2                	mov    %eax,%edx
  800548:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 75 d8             	pushl  -0x28(%ebp)
  800558:	53                   	push   %ebx
  800559:	51                   	push   %ecx
  80055a:	52                   	push   %edx
  80055b:	89 fa                	mov    %edi,%edx
  80055d:	89 f0                	mov    %esi,%eax
  80055f:	e8 08 fc ff ff       	call   80016c <printnum>
			break;
  800564:	83 c4 20             	add    $0x20,%esp
  800567:	e9 10 fd ff ff       	jmp    80027c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	57                   	push   %edi
  800570:	52                   	push   %edx
  800571:	ff d6                	call   *%esi
			break;
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	e9 01 fd ff ff       	jmp    80027c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	6a 25                	push   $0x25
  800581:	ff d6                	call   *%esi
  800583:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800586:	83 ea 02             	sub    $0x2,%edx
  800589:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80058c:	8a 02                	mov    (%edx),%al
  80058e:	4a                   	dec    %edx
  80058f:	3c 25                	cmp    $0x25,%al
  800591:	75 f9                	jne    80058c <vprintfmt+0x324>
  800593:	83 c2 02             	add    $0x2,%edx
  800596:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800599:	e9 de fc ff ff       	jmp    80027c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80059e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005a1:	5b                   	pop    %ebx
  8005a2:	5e                   	pop    %esi
  8005a3:	5f                   	pop    %edi
  8005a4:	c9                   	leave  
  8005a5:	c3                   	ret    

008005a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	83 ec 18             	sub    $0x18,%esp
  8005ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8005af:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	74 37                	je     8005ed <vsnprintf+0x47>
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	7e 33                	jle    8005ed <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005c1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8005c5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8005c8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005cb:	ff 75 14             	pushl  0x14(%ebp)
  8005ce:	ff 75 10             	pushl  0x10(%ebp)
  8005d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d4:	50                   	push   %eax
  8005d5:	68 4c 02 80 00       	push   $0x80024c
  8005da:	e8 89 fc ff ff       	call   800268 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 05                	jmp    8005f2 <vsnprintf+0x4c>
  8005ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800600:	50                   	push   %eax
  800601:	ff 75 10             	pushl  0x10(%ebp)
  800604:	ff 75 0c             	pushl  0xc(%ebp)
  800607:	ff 75 08             	pushl  0x8(%ebp)
  80060a:	e8 97 ff ff ff       	call   8005a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80060f:	c9                   	leave  
  800610:	c3                   	ret    

00800611 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800611:	55                   	push   %ebp
  800612:	89 e5                	mov    %esp,%ebp
  800614:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80061d:	50                   	push   %eax
  80061e:	ff 75 10             	pushl  0x10(%ebp)
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	ff 75 08             	pushl  0x8(%ebp)
  800627:	e8 3c fc ff ff       	call   800268 <vprintfmt>
	va_end(ap);
  80062c:	83 c4 10             	add    $0x10,%esp
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    
  800631:	00 00                	add    %al,(%eax)
	...

00800634 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	8b 55 08             	mov    0x8(%ebp),%edx
  80063a:	b8 00 00 00 00       	mov    $0x0,%eax
  80063f:	eb 01                	jmp    800642 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800641:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800642:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800646:	75 f9                	jne    800641 <strlen+0xd>
		n++;
	return n;
}
  800648:	c9                   	leave  
  800649:	c3                   	ret    

0080064a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800650:	8b 55 0c             	mov    0xc(%ebp),%edx
  800653:	b8 00 00 00 00       	mov    $0x0,%eax
  800658:	eb 01                	jmp    80065b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80065a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80065b:	39 d0                	cmp    %edx,%eax
  80065d:	74 06                	je     800665 <strnlen+0x1b>
  80065f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800663:	75 f5                	jne    80065a <strnlen+0x10>
		n++;
	return n;
}
  800665:	c9                   	leave  
  800666:	c3                   	ret    

00800667 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80066d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800670:	8a 01                	mov    (%ecx),%al
  800672:	88 02                	mov    %al,(%edx)
  800674:	42                   	inc    %edx
  800675:	41                   	inc    %ecx
  800676:	84 c0                	test   %al,%al
  800678:	75 f6                	jne    800670 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800686:	53                   	push   %ebx
  800687:	e8 a8 ff ff ff       	call   800634 <strlen>
	strcpy(dst + len, src);
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800692:	50                   	push   %eax
  800693:	e8 cf ff ff ff       	call   800667 <strcpy>
	return dst;
}
  800698:	89 d8                	mov    %ebx,%eax
  80069a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	56                   	push   %esi
  8006a3:	53                   	push   %ebx
  8006a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	eb 0c                	jmp    8006c0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006b4:	8a 02                	mov    (%edx),%al
  8006b6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006b9:	80 3a 01             	cmpb   $0x1,(%edx)
  8006bc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006bf:	41                   	inc    %ecx
  8006c0:	39 d9                	cmp    %ebx,%ecx
  8006c2:	75 f0                	jne    8006b4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	75 04                	jne    8006e0 <strlcpy+0x16>
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	eb 14                	jmp    8006f4 <strlcpy+0x2a>
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	eb 04                	jmp    8006e8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006e4:	88 10                	mov    %dl,(%eax)
  8006e6:	40                   	inc    %eax
  8006e7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8006e8:	49                   	dec    %ecx
  8006e9:	74 06                	je     8006f1 <strlcpy+0x27>
  8006eb:	8a 13                	mov    (%ebx),%dl
  8006ed:	84 d2                	test   %dl,%dl
  8006ef:	75 f3                	jne    8006e4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8006f1:	c6 00 00             	movb   $0x0,(%eax)
  8006f4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    

008006fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800700:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800703:	eb 02                	jmp    800707 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800705:	42                   	inc    %edx
  800706:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800707:	8a 02                	mov    (%edx),%al
  800709:	84 c0                	test   %al,%al
  80070b:	74 04                	je     800711 <strcmp+0x17>
  80070d:	3a 01                	cmp    (%ecx),%al
  80070f:	74 f4                	je     800705 <strcmp+0xb>
  800711:	0f b6 c0             	movzbl %al,%eax
  800714:	0f b6 11             	movzbl (%ecx),%edx
  800717:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800725:	8b 55 10             	mov    0x10(%ebp),%edx
  800728:	eb 03                	jmp    80072d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80072a:	4a                   	dec    %edx
  80072b:	41                   	inc    %ecx
  80072c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80072d:	85 d2                	test   %edx,%edx
  80072f:	75 07                	jne    800738 <strncmp+0x1d>
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	eb 14                	jmp    80074c <strncmp+0x31>
  800738:	8a 01                	mov    (%ecx),%al
  80073a:	84 c0                	test   %al,%al
  80073c:	74 04                	je     800742 <strncmp+0x27>
  80073e:	3a 03                	cmp    (%ebx),%al
  800740:	74 e8                	je     80072a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800742:	0f b6 d0             	movzbl %al,%edx
  800745:	0f b6 03             	movzbl (%ebx),%eax
  800748:	29 c2                	sub    %eax,%edx
  80074a:	89 d0                	mov    %edx,%eax
}
  80074c:	5b                   	pop    %ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	8b 45 08             	mov    0x8(%ebp),%eax
  800755:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800758:	eb 05                	jmp    80075f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80075a:	38 ca                	cmp    %cl,%dl
  80075c:	74 0c                	je     80076a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80075e:	40                   	inc    %eax
  80075f:	8a 10                	mov    (%eax),%dl
  800761:	84 d2                	test   %dl,%dl
  800763:	75 f5                	jne    80075a <strchr+0xb>
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800775:	eb 05                	jmp    80077c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800777:	38 ca                	cmp    %cl,%dl
  800779:	74 07                	je     800782 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80077b:	40                   	inc    %eax
  80077c:	8a 10                	mov    (%eax),%dl
  80077e:	84 d2                	test   %dl,%dl
  800780:	75 f5                	jne    800777 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	57                   	push   %edi
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800790:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800793:	85 db                	test   %ebx,%ebx
  800795:	74 36                	je     8007cd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800797:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80079d:	75 29                	jne    8007c8 <memset+0x44>
  80079f:	f6 c3 03             	test   $0x3,%bl
  8007a2:	75 24                	jne    8007c8 <memset+0x44>
		c &= 0xFF;
  8007a4:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007a7:	89 d6                	mov    %edx,%esi
  8007a9:	c1 e6 08             	shl    $0x8,%esi
  8007ac:	89 d0                	mov    %edx,%eax
  8007ae:	c1 e0 18             	shl    $0x18,%eax
  8007b1:	89 d1                	mov    %edx,%ecx
  8007b3:	c1 e1 10             	shl    $0x10,%ecx
  8007b6:	09 c8                	or     %ecx,%eax
  8007b8:	09 c2                	or     %eax,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	09 d0                	or     %edx,%eax
  8007be:	89 d9                	mov    %ebx,%ecx
  8007c0:	c1 e9 02             	shr    $0x2,%ecx
  8007c3:	fc                   	cld    
  8007c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8007c6:	eb 05                	jmp    8007cd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007c8:	89 d9                	mov    %ebx,%ecx
  8007ca:	fc                   	cld    
  8007cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8007cd:	89 f8                	mov    %edi,%eax
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5f                   	pop    %edi
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	57                   	push   %edi
  8007d8:	56                   	push   %esi
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007df:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007e2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007e4:	39 c6                	cmp    %eax,%esi
  8007e6:	73 36                	jae    80081e <memmove+0x4a>
  8007e8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	73 2f                	jae    80081e <memmove+0x4a>
		s += n;
		d += n;
  8007ef:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8007f2:	f6 c2 03             	test   $0x3,%dl
  8007f5:	75 1b                	jne    800812 <memmove+0x3e>
  8007f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8007fd:	75 13                	jne    800812 <memmove+0x3e>
  8007ff:	f6 c1 03             	test   $0x3,%cl
  800802:	75 0e                	jne    800812 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800804:	8d 7e fc             	lea    -0x4(%esi),%edi
  800807:	8d 72 fc             	lea    -0x4(%edx),%esi
  80080a:	c1 e9 02             	shr    $0x2,%ecx
  80080d:	fd                   	std    
  80080e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800810:	eb 09                	jmp    80081b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800812:	8d 7e ff             	lea    -0x1(%esi),%edi
  800815:	8d 72 ff             	lea    -0x1(%edx),%esi
  800818:	fd                   	std    
  800819:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80081b:	fc                   	cld    
  80081c:	eb 20                	jmp    80083e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80081e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800824:	75 15                	jne    80083b <memmove+0x67>
  800826:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082c:	75 0d                	jne    80083b <memmove+0x67>
  80082e:	f6 c1 03             	test   $0x3,%cl
  800831:	75 08                	jne    80083b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800833:	c1 e9 02             	shr    $0x2,%ecx
  800836:	fc                   	cld    
  800837:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800839:	eb 03                	jmp    80083e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80083b:	fc                   	cld    
  80083c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800845:	ff 75 10             	pushl  0x10(%ebp)
  800848:	ff 75 0c             	pushl  0xc(%ebp)
  80084b:	ff 75 08             	pushl  0x8(%ebp)
  80084e:	e8 81 ff ff ff       	call   8007d4 <memmove>
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80085f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800865:	eb 1b                	jmp    800882 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800867:	8a 1a                	mov    (%edx),%bl
  800869:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80086c:	8a 19                	mov    (%ecx),%bl
  80086e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800871:	74 0d                	je     800880 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800873:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800877:	0f b6 c3             	movzbl %bl,%eax
  80087a:	29 c2                	sub    %eax,%edx
  80087c:	89 d0                	mov    %edx,%eax
  80087e:	eb 0d                	jmp    80088d <memcmp+0x38>
		s1++, s2++;
  800880:	42                   	inc    %edx
  800881:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800882:	48                   	dec    %eax
  800883:	83 f8 ff             	cmp    $0xffffffff,%eax
  800886:	75 df                	jne    800867 <memcmp+0x12>
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80088d:	83 c4 04             	add    $0x4,%esp
  800890:	5b                   	pop    %ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80089c:	89 c2                	mov    %eax,%edx
  80089e:	03 55 10             	add    0x10(%ebp),%edx
  8008a1:	eb 05                	jmp    8008a8 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008a3:	38 08                	cmp    %cl,(%eax)
  8008a5:	74 05                	je     8008ac <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008a7:	40                   	inc    %eax
  8008a8:	39 d0                	cmp    %edx,%eax
  8008aa:	72 f7                	jb     8008a3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	83 ec 04             	sub    $0x4,%esp
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8008bd:	eb 01                	jmp    8008c0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008bf:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008c0:	8a 01                	mov    (%ecx),%al
  8008c2:	3c 20                	cmp    $0x20,%al
  8008c4:	74 f9                	je     8008bf <strtol+0x11>
  8008c6:	3c 09                	cmp    $0x9,%al
  8008c8:	74 f5                	je     8008bf <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8008ca:	3c 2b                	cmp    $0x2b,%al
  8008cc:	75 0a                	jne    8008d8 <strtol+0x2a>
		s++;
  8008ce:	41                   	inc    %ecx
  8008cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008d6:	eb 17                	jmp    8008ef <strtol+0x41>
	else if (*s == '-')
  8008d8:	3c 2d                	cmp    $0x2d,%al
  8008da:	74 09                	je     8008e5 <strtol+0x37>
  8008dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008e3:	eb 0a                	jmp    8008ef <strtol+0x41>
		s++, neg = 1;
  8008e5:	8d 49 01             	lea    0x1(%ecx),%ecx
  8008e8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008ef:	85 f6                	test   %esi,%esi
  8008f1:	74 05                	je     8008f8 <strtol+0x4a>
  8008f3:	83 fe 10             	cmp    $0x10,%esi
  8008f6:	75 1a                	jne    800912 <strtol+0x64>
  8008f8:	8a 01                	mov    (%ecx),%al
  8008fa:	3c 30                	cmp    $0x30,%al
  8008fc:	75 10                	jne    80090e <strtol+0x60>
  8008fe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800902:	75 0a                	jne    80090e <strtol+0x60>
		s += 2, base = 16;
  800904:	83 c1 02             	add    $0x2,%ecx
  800907:	be 10 00 00 00       	mov    $0x10,%esi
  80090c:	eb 04                	jmp    800912 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80090e:	85 f6                	test   %esi,%esi
  800910:	74 07                	je     800919 <strtol+0x6b>
  800912:	bf 00 00 00 00       	mov    $0x0,%edi
  800917:	eb 13                	jmp    80092c <strtol+0x7e>
  800919:	3c 30                	cmp    $0x30,%al
  80091b:	74 07                	je     800924 <strtol+0x76>
  80091d:	be 0a 00 00 00       	mov    $0xa,%esi
  800922:	eb ee                	jmp    800912 <strtol+0x64>
		s++, base = 8;
  800924:	41                   	inc    %ecx
  800925:	be 08 00 00 00       	mov    $0x8,%esi
  80092a:	eb e6                	jmp    800912 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80092c:	8a 11                	mov    (%ecx),%dl
  80092e:	88 d3                	mov    %dl,%bl
  800930:	8d 42 d0             	lea    -0x30(%edx),%eax
  800933:	3c 09                	cmp    $0x9,%al
  800935:	77 08                	ja     80093f <strtol+0x91>
			dig = *s - '0';
  800937:	0f be c2             	movsbl %dl,%eax
  80093a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80093d:	eb 1c                	jmp    80095b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80093f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800942:	3c 19                	cmp    $0x19,%al
  800944:	77 08                	ja     80094e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800946:	0f be c2             	movsbl %dl,%eax
  800949:	8d 50 a9             	lea    -0x57(%eax),%edx
  80094c:	eb 0d                	jmp    80095b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80094e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800951:	3c 19                	cmp    $0x19,%al
  800953:	77 15                	ja     80096a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800955:	0f be c2             	movsbl %dl,%eax
  800958:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80095b:	39 f2                	cmp    %esi,%edx
  80095d:	7d 0b                	jge    80096a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  80095f:	41                   	inc    %ecx
  800960:	89 f8                	mov    %edi,%eax
  800962:	0f af c6             	imul   %esi,%eax
  800965:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800968:	eb c2                	jmp    80092c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  80096a:	89 f8                	mov    %edi,%eax

	if (endptr)
  80096c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800970:	74 05                	je     800977 <strtol+0xc9>
		*endptr = (char *) s;
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800977:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80097b:	74 04                	je     800981 <strtol+0xd3>
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	f7 df                	neg    %edi
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	83 c4 04             	add    $0x4,%esp
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	c9                   	leave  
  80098a:	c3                   	ret    
	...

0080098c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800992:	b8 01 00 00 00       	mov    $0x1,%eax
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
  80099c:	89 fa                	mov    %edi,%edx
  80099e:	89 f9                	mov    %edi,%ecx
  8009a0:	89 fb                	mov    %edi,%ebx
  8009a2:	89 fe                	mov    %edi,%esi
  8009a4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	83 ec 04             	sub    $0x4,%esp
  8009b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	89 fb                	mov    %edi,%ebx
  8009c3:	89 fe                	mov    %edi,%esi
  8009c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009c7:	83 c4 04             	add    $0x4,%esp
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 0c             	sub    $0xc,%esp
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009db:	b8 0d 00 00 00       	mov    $0xd,%eax
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	89 f9                	mov    %edi,%ecx
  8009e7:	89 fb                	mov    %edi,%ebx
  8009e9:	89 fe                	mov    %edi,%esi
  8009eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	7e 17                	jle    800a08 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	50                   	push   %eax
  8009f5:	6a 0d                	push   $0xd
  8009f7:	68 7f 12 80 00       	push   $0x80127f
  8009fc:	6a 23                	push   $0x23
  8009fe:	68 9c 12 80 00       	push   $0x80129c
  800a03:	e8 38 02 00 00       	call   800c40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0b:	5b                   	pop    %ebx
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 55 08             	mov    0x8(%ebp),%edx
  800a19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a1f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a27:	be 00 00 00 00       	mov    $0x0,%esi
  800a2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a47:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4c:	89 fb                	mov    %edi,%ebx
  800a4e:	89 fe                	mov    %edi,%esi
  800a50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a52:	85 c0                	test   %eax,%eax
  800a54:	7e 17                	jle    800a6d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a56:	83 ec 0c             	sub    $0xc,%esp
  800a59:	50                   	push   %eax
  800a5a:	6a 0a                	push   $0xa
  800a5c:	68 7f 12 80 00       	push   $0x80127f
  800a61:	6a 23                	push   $0x23
  800a63:	68 9c 12 80 00       	push   $0x80129c
  800a68:	e8 d3 01 00 00       	call   800c40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800a6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 0c             	sub    $0xc,%esp
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a84:	b8 09 00 00 00       	mov    $0x9,%eax
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	89 fb                	mov    %edi,%ebx
  800a90:	89 fe                	mov    %edi,%esi
  800a92:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a94:	85 c0                	test   %eax,%eax
  800a96:	7e 17                	jle    800aaf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a98:	83 ec 0c             	sub    $0xc,%esp
  800a9b:	50                   	push   %eax
  800a9c:	6a 09                	push   $0x9
  800a9e:	68 7f 12 80 00       	push   $0x80127f
  800aa3:	6a 23                	push   $0x23
  800aa5:	68 9c 12 80 00       	push   $0x80129c
  800aaa:	e8 91 01 00 00       	call   800c40 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	83 ec 0c             	sub    $0xc,%esp
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 08 00 00 00       	mov    $0x8,%eax
  800acb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad0:	89 fb                	mov    %edi,%ebx
  800ad2:	89 fe                	mov    %edi,%esi
  800ad4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	7e 17                	jle    800af1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ada:	83 ec 0c             	sub    $0xc,%esp
  800add:	50                   	push   %eax
  800ade:	6a 08                	push   $0x8
  800ae0:	68 7f 12 80 00       	push   $0x80127f
  800ae5:	6a 23                	push   $0x23
  800ae7:	68 9c 12 80 00       	push   $0x80129c
  800aec:	e8 4f 01 00 00       	call   800c40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800af1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	b8 06 00 00 00       	mov    $0x6,%eax
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b12:	89 fb                	mov    %edi,%ebx
  800b14:	89 fe                	mov    %edi,%esi
  800b16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	7e 17                	jle    800b33 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	50                   	push   %eax
  800b20:	6a 06                	push   $0x6
  800b22:	68 7f 12 80 00       	push   $0x80127f
  800b27:	6a 23                	push   $0x23
  800b29:	68 9c 12 80 00       	push   $0x80129c
  800b2e:	e8 0d 01 00 00       	call   800c40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b50:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	b8 05 00 00 00       	mov    $0x5,%eax
  800b58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 05                	push   $0x5
  800b64:	68 7f 12 80 00       	push   $0x80127f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 9c 12 80 00       	push   $0x80129c
  800b70:	e8 cb 00 00 00       	call   800c40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b94:	bf 00 00 00 00       	mov    $0x0,%edi
  800b99:	89 fe                	mov    %edi,%esi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 04                	push   $0x4
  800ba7:	68 7f 12 80 00       	push   $0x80127f
  800bac:	6a 23                	push   $0x23
  800bae:	68 9c 12 80 00       	push   $0x80129c
  800bb3:	e8 88 00 00 00       	call   800c40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd0:	89 fa                	mov    %edi,%edx
  800bd2:	89 f9                	mov    %edi,%ecx
  800bd4:	89 fb                	mov    %edi,%ebx
  800bd6:	89 fe                	mov    %edi,%esi
  800bd8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
  800bef:	89 fa                	mov    %edi,%edx
  800bf1:	89 f9                	mov    %edi,%ecx
  800bf3:	89 fb                	mov    %edi,%ebx
  800bf5:	89 fe                	mov    %edi,%esi
  800bf7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	89 f9                	mov    %edi,%ecx
  800c16:	89 fb                	mov    %edi,%ebx
  800c18:	89 fe                	mov    %edi,%esi
  800c1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 03                	push   $0x3
  800c26:	68 7f 12 80 00       	push   $0x80127f
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 9c 12 80 00       	push   $0x80129c
  800c32:	e8 09 00 00 00       	call   800c40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    
	...

00800c40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	53                   	push   %ebx
  800c44:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800c47:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c4d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c53:	e8 87 ff ff ff       	call   800bdf <sys_getenvid>
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	ff 75 0c             	pushl  0xc(%ebp)
  800c5e:	ff 75 08             	pushl  0x8(%ebp)
  800c61:	53                   	push   %ebx
  800c62:	50                   	push   %eax
  800c63:	68 ac 12 80 00       	push   $0x8012ac
  800c68:	e8 a8 f4 ff ff       	call   800115 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c6d:	83 c4 18             	add    $0x18,%esp
  800c70:	ff 75 f8             	pushl  -0x8(%ebp)
  800c73:	ff 75 10             	pushl  0x10(%ebp)
  800c76:	e8 49 f4 ff ff       	call   8000c4 <vcprintf>
	cprintf("\n");
  800c7b:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800c82:	e8 8e f4 ff ff       	call   800115 <cprintf>
  800c87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c8a:	cc                   	int3   
  800c8b:	eb fd                	jmp    800c8a <_panic+0x4a>
  800c8d:	00 00                	add    %al,(%eax)
	...

00800c90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	83 ec 28             	sub    $0x28,%esp
  800c98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c9f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800caf:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800cb1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	75 21                	jne    800ce4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cc3:	39 d1                	cmp    %edx,%ecx
  800cc5:	76 49                	jbe    800d10 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cc7:	f7 f1                	div    %ecx
  800cc9:	89 c1                	mov    %eax,%ecx
  800ccb:	31 c0                	xor    %eax,%eax
  800ccd:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cd0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cdc:	83 c4 28             	add    $0x28,%esp
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    
  800ce3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ce4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ce7:	0f 87 97 00 00 00    	ja     800d84 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ced:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cf0:	83 f0 1f             	xor    $0x1f,%eax
  800cf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cf6:	75 34                	jne    800d2c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cf8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cfb:	72 08                	jb     800d05 <__udivdi3+0x75>
  800cfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d00:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d03:	77 7f                	ja     800d84 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d05:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d0a:	31 c0                	xor    %eax,%eax
  800d0c:	eb c2                	jmp    800cd0 <__udivdi3+0x40>
  800d0e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d13:	85 c0                	test   %eax,%eax
  800d15:	74 79                	je     800d90 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d1a:	89 fa                	mov    %edi,%edx
  800d1c:	f7 f1                	div    %ecx
  800d1e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d23:	f7 f1                	div    %ecx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	89 f0                	mov    %esi,%eax
  800d29:	eb a5                	jmp    800cd0 <__udivdi3+0x40>
  800d2b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d31:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d37:	89 fa                	mov    %edi,%edx
  800d39:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d3c:	d3 e2                	shl    %cl,%edx
  800d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d41:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d44:	d3 e8                	shr    %cl,%eax
  800d46:	89 d7                	mov    %edx,%edi
  800d48:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d4a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d4d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d50:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d52:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d55:	d3 e0                	shl    %cl,%eax
  800d57:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d5a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d5d:	d3 ea                	shr    %cl,%edx
  800d5f:	09 d0                	or     %edx,%eax
  800d61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d64:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d67:	d3 ea                	shr    %cl,%edx
  800d69:	f7 f7                	div    %edi
  800d6b:	89 d7                	mov    %edx,%edi
  800d6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d70:	f7 e6                	mul    %esi
  800d72:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d74:	39 d7                	cmp    %edx,%edi
  800d76:	72 38                	jb     800db0 <__udivdi3+0x120>
  800d78:	74 27                	je     800da1 <__udivdi3+0x111>
  800d7a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d7d:	31 c0                	xor    %eax,%eax
  800d7f:	e9 4c ff ff ff       	jmp    800cd0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d84:	31 c9                	xor    %ecx,%ecx
  800d86:	31 c0                	xor    %eax,%eax
  800d88:	e9 43 ff ff ff       	jmp    800cd0 <__udivdi3+0x40>
  800d8d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d90:	b8 01 00 00 00       	mov    $0x1,%eax
  800d95:	31 d2                	xor    %edx,%edx
  800d97:	f7 75 f4             	divl   -0xc(%ebp)
  800d9a:	89 c1                	mov    %eax,%ecx
  800d9c:	e9 76 ff ff ff       	jmp    800d17 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800da4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800da7:	d3 e0                	shl    %cl,%eax
  800da9:	39 f0                	cmp    %esi,%eax
  800dab:	73 cd                	jae    800d7a <__udivdi3+0xea>
  800dad:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800db0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800db3:	49                   	dec    %ecx
  800db4:	31 c0                	xor    %eax,%eax
  800db6:	e9 15 ff ff ff       	jmp    800cd0 <__udivdi3+0x40>
	...

00800dbc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	83 ec 30             	sub    $0x30,%esp
  800dc4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dcb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dd2:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800de1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800de3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800de6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800de9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dec:	85 d2                	test   %edx,%edx
  800dee:	75 1c                	jne    800e0c <__umoddi3+0x50>
    {
      if (d0 > n1)
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	39 f8                	cmp    %edi,%eax
  800df4:	0f 86 c2 00 00 00    	jbe    800ebc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dfe:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e01:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e08:	eb 12                	jmp    800e1c <__umoddi3+0x60>
  800e0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e0c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e0f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e12:	76 18                	jbe    800e2c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e14:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e17:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e1a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e22:	83 c4 30             	add    $0x30,%esp
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    
  800e29:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e2c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e30:	83 f0 1f             	xor    $0x1f,%eax
  800e33:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e36:	0f 84 ac 00 00 00    	je     800ee8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e41:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e47:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e4a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e4d:	d3 e2                	shl    %cl,%edx
  800e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e52:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e55:	d3 e8                	shr    %cl,%eax
  800e57:	89 d6                	mov    %edx,%esi
  800e59:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e61:	d3 e0                	shl    %cl,%eax
  800e63:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e66:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e69:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e6e:	d3 e0                	shl    %cl,%eax
  800e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e73:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e76:	d3 ea                	shr    %cl,%edx
  800e78:	09 d0                	or     %edx,%eax
  800e7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e7d:	d3 ea                	shr    %cl,%edx
  800e7f:	f7 f6                	div    %esi
  800e81:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e84:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e87:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e8a:	0f 82 8d 00 00 00    	jb     800f1d <__umoddi3+0x161>
  800e90:	0f 84 91 00 00 00    	je     800f27 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e96:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e99:	29 c7                	sub    %eax,%edi
  800e9b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e9d:	89 f2                	mov    %esi,%edx
  800e9f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ea2:	d3 e2                	shl    %cl,%edx
  800ea4:	89 f8                	mov    %edi,%eax
  800ea6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ea9:	d3 e8                	shr    %cl,%eax
  800eab:	09 c2                	or     %eax,%edx
  800ead:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800eb0:	d3 ee                	shr    %cl,%esi
  800eb2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800eb5:	e9 62 ff ff ff       	jmp    800e1c <__umoddi3+0x60>
  800eba:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ebc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	74 15                	je     800ed8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ec6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ec9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ece:	f7 f1                	div    %ecx
  800ed0:	e9 29 ff ff ff       	jmp    800dfe <__umoddi3+0x42>
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ed8:	b8 01 00 00 00       	mov    $0x1,%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 75 ec             	divl   -0x14(%ebp)
  800ee2:	89 c1                	mov    %eax,%ecx
  800ee4:	eb dd                	jmp    800ec3 <__umoddi3+0x107>
  800ee6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eeb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800eee:	72 19                	jb     800f09 <__umoddi3+0x14d>
  800ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ef6:	76 11                	jbe    800f09 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800efb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800efe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f01:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f04:	e9 13 ff ff ff       	jmp    800e1c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f09:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f12:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f18:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f1b:	eb db                	jmp    800ef8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f1d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f20:	19 f2                	sbb    %esi,%edx
  800f22:	e9 6f ff ff ff       	jmp    800e96 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f27:	39 c7                	cmp    %eax,%edi
  800f29:	72 f2                	jb     800f1d <__umoddi3+0x161>
  800f2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2e:	e9 63 ff ff ff       	jmp    800e96 <__umoddi3+0xda>
