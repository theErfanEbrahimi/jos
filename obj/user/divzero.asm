
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	ba 00 00 00 00       	mov    $0x0,%edx
  80004e:	89 d1                	mov    %edx,%ecx
  800050:	99                   	cltd   
  800051:	f7 f9                	idiv   %ecx
  800053:	50                   	push   %eax
  800054:	68 40 0f 80 00       	push   $0x800f40
  800059:	e8 bb 00 00 00       	call   800119 <cprintf>
  80005e:	83 c4 10             	add    $0x10,%esp
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
	...

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	8b 75 08             	mov    0x8(%ebp),%esi
  80006c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80006f:	e8 6f 0b 00 00       	call   800be3 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800080:	c1 e0 07             	shl    $0x7,%eax
  800083:	29 d0                	sub    %edx,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 f6                	test   %esi,%esi
  800091:	7e 07                	jle    80009a <libmain+0x36>
		binaryname = argv[0];
  800093:	8b 03                	mov    (%ebx),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	53                   	push   %ebx
  80009e:	56                   	push   %esi
  80009f:	e8 90 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0b 00 00 00       	call   8000b4 <exit>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 41 0b 00 00       	call   800c02 <sys_env_destroy>
  8000c1:	83 c4 10             	add    $0x10,%esp
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    
	...

008000c8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000d1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000d8:	00 00 00 
	b.cnt = 0;
  8000db:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8000e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e5:	ff 75 0c             	pushl  0xc(%ebp)
  8000e8:	ff 75 08             	pushl  0x8(%ebp)
  8000eb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000f1:	50                   	push   %eax
  8000f2:	68 30 01 80 00       	push   $0x800130
  8000f7:	e8 70 01 00 00       	call   80026c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000fc:	83 c4 08             	add    $0x8,%esp
  8000ff:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800105:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 9e 08 00 00       	call   8009af <sys_cputs>
  800111:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80011f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800122:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800125:	50                   	push   %eax
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	e8 9a ff ff ff       	call   8000c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 04             	sub    $0x4,%esp
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013a:	8b 03                	mov    (%ebx),%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800143:	40                   	inc    %eax
  800144:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800146:	3d ff 00 00 00       	cmp    $0xff,%eax
  80014b:	75 1a                	jne    800167 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	68 ff 00 00 00       	push   $0xff
  800155:	8d 43 08             	lea    0x8(%ebx),%eax
  800158:	50                   	push   %eax
  800159:	e8 51 08 00 00       	call   8009af <sys_cputs>
		b->idx = 0;
  80015e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800164:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800167:	ff 43 04             	incl   0x4(%ebx)
}
  80016a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    
	...

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 1c             	sub    $0x1c,%esp
  800179:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80017c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80017f:	8b 45 08             	mov    0x8(%ebp),%eax
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800188:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80018b:	8b 55 10             	mov    0x10(%ebp),%edx
  80018e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800191:	89 d6                	mov    %edx,%esi
  800193:	bf 00 00 00 00       	mov    $0x0,%edi
  800198:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80019b:	72 04                	jb     8001a1 <printnum+0x31>
  80019d:	39 c2                	cmp    %eax,%edx
  80019f:	77 3f                	ja     8001e0 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a1:	83 ec 0c             	sub    $0xc,%esp
  8001a4:	ff 75 18             	pushl  0x18(%ebp)
  8001a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	52                   	push   %edx
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b7:	e8 d8 0a 00 00       	call   800c94 <__udivdi3>
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	52                   	push   %edx
  8001c0:	50                   	push   %eax
  8001c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001c7:	e8 a4 ff ff ff       	call   800170 <printnum>
  8001cc:	83 c4 20             	add    $0x20,%esp
  8001cf:	eb 14                	jmp    8001e5 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	ff 75 e8             	pushl  -0x18(%ebp)
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	ff 55 ec             	call   *-0x14(%ebp)
  8001dd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e0:	4b                   	dec    %ebx
  8001e1:	85 db                	test   %ebx,%ebx
  8001e3:	7f ec                	jg     8001d1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e8             	pushl  -0x18(%ebp)
  8001eb:	83 ec 04             	sub    $0x4,%esp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f6:	e8 c5 0b 00 00       	call   800dc0 <__umoddi3>
  8001fb:	83 c4 14             	add    $0x14,%esp
  8001fe:	0f be 80 58 0f 80 00 	movsbl 0x800f58(%eax),%eax
  800205:	50                   	push   %eax
  800206:	ff 55 ec             	call   *-0x14(%ebp)
  800209:	83 c4 10             	add    $0x10,%esp
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 42 08             	lea    0x8(%edx),%eax
  800223:	89 01                	mov    %eax,(%ecx)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x3a>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 42 04             	lea    0x4(%edx),%eax
  800235:	89 01                	mov    %eax,(%ecx)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 42 04             	lea    0x4(%edx),%eax
  800245:	89 01                	mov    %eax,(%ecx)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800256:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800259:	8b 11                	mov    (%ecx),%edx
  80025b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80025e:	73 0a                	jae    80026a <sprintputch+0x1a>
		*b->buf++ = ch;
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	88 02                	mov    %al,(%edx)
  800265:	8d 42 01             	lea    0x1(%edx),%eax
  800268:	89 01                	mov    %eax,(%ecx)
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	8b 75 08             	mov    0x8(%ebp),%esi
  800278:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80027b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027e:	eb 1a                	jmp    80029a <vprintfmt+0x2e>
  800280:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800283:	eb 15                	jmp    80029a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800285:	84 c0                	test   %al,%al
  800287:	0f 84 15 03 00 00    	je     8005a2 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	57                   	push   %edi
  800291:	0f b6 c0             	movzbl %al,%eax
  800294:	50                   	push   %eax
  800295:	ff d6                	call   *%esi
  800297:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029a:	8a 03                	mov    (%ebx),%al
  80029c:	43                   	inc    %ebx
  80029d:	3c 25                	cmp    $0x25,%al
  80029f:	75 e4                	jne    800285 <vprintfmt+0x19>
  8002a1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002af:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002b6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002bd:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002c1:	eb 0a                	jmp    8002cd <vprintfmt+0x61>
  8002c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8002ca:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8a 03                	mov    (%ebx),%al
  8002cf:	0f b6 d0             	movzbl %al,%edx
  8002d2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8002d5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8002d8:	83 e8 23             	sub    $0x23,%eax
  8002db:	3c 55                	cmp    $0x55,%al
  8002dd:	0f 87 9c 02 00 00    	ja     80057f <vprintfmt+0x313>
  8002e3:	0f b6 c0             	movzbl %al,%eax
  8002e6:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002ed:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8002f1:	eb d7                	jmp    8002ca <vprintfmt+0x5e>
  8002f3:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8002f7:	eb d1                	jmp    8002ca <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8002f9:	89 d9                	mov    %ebx,%ecx
  8002fb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800302:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800305:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800308:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80030c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80030f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800313:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800314:	8d 42 d0             	lea    -0x30(%edx),%eax
  800317:	83 f8 09             	cmp    $0x9,%eax
  80031a:	77 21                	ja     80033d <vprintfmt+0xd1>
  80031c:	eb e4                	jmp    800302 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031e:	8b 55 14             	mov    0x14(%ebp),%edx
  800321:	8d 42 04             	lea    0x4(%edx),%eax
  800324:	89 45 14             	mov    %eax,0x14(%ebp)
  800327:	8b 12                	mov    (%edx),%edx
  800329:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80032c:	eb 12                	jmp    800340 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80032e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800332:	79 96                	jns    8002ca <vprintfmt+0x5e>
  800334:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033b:	eb 8d                	jmp    8002ca <vprintfmt+0x5e>
  80033d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800340:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800344:	79 84                	jns    8002ca <vprintfmt+0x5e>
  800346:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800349:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800353:	e9 72 ff ff ff       	jmp    8002ca <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800358:	ff 45 d4             	incl   -0x2c(%ebp)
  80035b:	e9 6a ff ff ff       	jmp    8002ca <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800360:	8b 55 14             	mov    0x14(%ebp),%edx
  800363:	8d 42 04             	lea    0x4(%edx),%eax
  800366:	89 45 14             	mov    %eax,0x14(%ebp)
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	57                   	push   %edi
  80036d:	ff 32                	pushl  (%edx)
  80036f:	ff d6                	call   *%esi
			break;
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	e9 07 ff ff ff       	jmp    800280 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800379:	8b 55 14             	mov    0x14(%ebp),%edx
  80037c:	8d 42 04             	lea    0x4(%edx),%eax
  80037f:	89 45 14             	mov    %eax,0x14(%ebp)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	85 c0                	test   %eax,%eax
  800386:	79 02                	jns    80038a <vprintfmt+0x11e>
  800388:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038a:	83 f8 0f             	cmp    $0xf,%eax
  80038d:	7f 0b                	jg     80039a <vprintfmt+0x12e>
  80038f:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800396:	85 d2                	test   %edx,%edx
  800398:	75 15                	jne    8003af <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80039a:	50                   	push   %eax
  80039b:	68 69 0f 80 00       	push   $0x800f69
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	e8 6e 02 00 00       	call   800615 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	e9 d1 fe ff ff       	jmp    800280 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003af:	52                   	push   %edx
  8003b0:	68 72 0f 80 00       	push   $0x800f72
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	e8 59 02 00 00       	call   800615 <printfmt>
  8003bc:	83 c4 10             	add    $0x10,%esp
  8003bf:	e9 bc fe ff ff       	jmp    800280 <vprintfmt+0x14>
  8003c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003c7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8003d0:	8d 42 04             	lea    0x4(%edx),%eax
  8003d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d6:	8b 1a                	mov    (%edx),%ebx
  8003d8:	85 db                	test   %ebx,%ebx
  8003da:	75 05                	jne    8003e1 <vprintfmt+0x175>
  8003dc:	bb 75 0f 80 00       	mov    $0x800f75,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8003e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8003e5:	7e 66                	jle    80044d <vprintfmt+0x1e1>
  8003e7:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8003eb:	74 60                	je     80044d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	51                   	push   %ecx
  8003f1:	53                   	push   %ebx
  8003f2:	e8 57 02 00 00       	call   80064e <strnlen>
  8003f7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8003fa:	29 c1                	sub    %eax,%ecx
  8003fc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800406:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800409:	eb 0f                	jmp    80041a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	57                   	push   %edi
  80040f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800412:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800414:	ff 4d d8             	decl   -0x28(%ebp)
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041e:	7f eb                	jg     80040b <vprintfmt+0x19f>
  800420:	eb 2b                	jmp    80044d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800422:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800425:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800429:	74 15                	je     800440 <vprintfmt+0x1d4>
  80042b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80042e:	83 f8 5e             	cmp    $0x5e,%eax
  800431:	76 0d                	jbe    800440 <vprintfmt+0x1d4>
					putch('?', putdat);
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	57                   	push   %edi
  800437:	6a 3f                	push   $0x3f
  800439:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	eb 0a                	jmp    80044a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	57                   	push   %edi
  800444:	52                   	push   %edx
  800445:	ff d6                	call   *%esi
  800447:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044a:	ff 4d d8             	decl   -0x28(%ebp)
  80044d:	8a 03                	mov    (%ebx),%al
  80044f:	43                   	inc    %ebx
  800450:	84 c0                	test   %al,%al
  800452:	74 1b                	je     80046f <vprintfmt+0x203>
  800454:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800458:	78 c8                	js     800422 <vprintfmt+0x1b6>
  80045a:	ff 4d dc             	decl   -0x24(%ebp)
  80045d:	79 c3                	jns    800422 <vprintfmt+0x1b6>
  80045f:	eb 0e                	jmp    80046f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	57                   	push   %edi
  800465:	6a 20                	push   $0x20
  800467:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800469:	ff 4d d8             	decl   -0x28(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800473:	7f ec                	jg     800461 <vprintfmt+0x1f5>
  800475:	e9 06 fe ff ff       	jmp    800280 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80047a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80047e:	7e 10                	jle    800490 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800480:	8b 55 14             	mov    0x14(%ebp),%edx
  800483:	8d 42 08             	lea    0x8(%edx),%eax
  800486:	89 45 14             	mov    %eax,0x14(%ebp)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	8b 52 04             	mov    0x4(%edx),%edx
  80048e:	eb 20                	jmp    8004b0 <vprintfmt+0x244>
	else if (lflag)
  800490:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800494:	74 0e                	je     8004a4 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	99                   	cltd   
  8004a2:	eb 0c                	jmp    8004b0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004b0:	89 d1                	mov    %edx,%ecx
  8004b2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	85 c9                	test   %ecx,%ecx
  8004bc:	78 0a                	js     8004c8 <vprintfmt+0x25c>
  8004be:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004c3:	e9 89 00 00 00       	jmp    800551 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	57                   	push   %edi
  8004cc:	6a 2d                	push   $0x2d
  8004ce:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004d3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004d6:	f7 da                	neg    %edx
  8004d8:	83 d1 00             	adc    $0x0,%ecx
  8004db:	f7 d9                	neg    %ecx
  8004dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb 6a                	jmp    800551 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ed:	e8 22 fd ff ff       	call   800214 <getuint>
  8004f2:	89 d1                	mov    %edx,%ecx
  8004f4:	89 c2                	mov    %eax,%edx
  8004f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004fb:	eb 54                	jmp    800551 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800500:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800503:	e8 0c fd ff ff       	call   800214 <getuint>
  800508:	89 d1                	mov    %edx,%ecx
  80050a:	89 c2                	mov    %eax,%edx
  80050c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800511:	eb 3e                	jmp    800551 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	57                   	push   %edi
  800517:	6a 30                	push   $0x30
  800519:	ff d6                	call   *%esi
			putch('x', putdat);
  80051b:	83 c4 08             	add    $0x8,%esp
  80051e:	57                   	push   %edi
  80051f:	6a 78                	push   $0x78
  800521:	ff d6                	call   *%esi
			num = (unsigned long long)
  800523:	8b 55 14             	mov    0x14(%ebp),%edx
  800526:	8d 42 04             	lea    0x4(%edx),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
  80052c:	8b 12                	mov    (%edx),%edx
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800533:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 14                	jmp    800551 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80053d:	8d 45 14             	lea    0x14(%ebp),%eax
  800540:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800543:	e8 cc fc ff ff       	call   800214 <getuint>
  800548:	89 d1                	mov    %edx,%ecx
  80054a:	89 c2                	mov    %eax,%edx
  80054c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 d8             	pushl  -0x28(%ebp)
  80055c:	53                   	push   %ebx
  80055d:	51                   	push   %ecx
  80055e:	52                   	push   %edx
  80055f:	89 fa                	mov    %edi,%edx
  800561:	89 f0                	mov    %esi,%eax
  800563:	e8 08 fc ff ff       	call   800170 <printnum>
			break;
  800568:	83 c4 20             	add    $0x20,%esp
  80056b:	e9 10 fd ff ff       	jmp    800280 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	57                   	push   %edi
  800574:	52                   	push   %edx
  800575:	ff d6                	call   *%esi
			break;
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	e9 01 fd ff ff       	jmp    800280 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	6a 25                	push   $0x25
  800585:	ff d6                	call   *%esi
  800587:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80058a:	83 ea 02             	sub    $0x2,%edx
  80058d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800590:	8a 02                	mov    (%edx),%al
  800592:	4a                   	dec    %edx
  800593:	3c 25                	cmp    $0x25,%al
  800595:	75 f9                	jne    800590 <vprintfmt+0x324>
  800597:	83 c2 02             	add    $0x2,%edx
  80059a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80059d:	e9 de fc ff ff       	jmp    800280 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005a5:	5b                   	pop    %ebx
  8005a6:	5e                   	pop    %esi
  8005a7:	5f                   	pop    %edi
  8005a8:	c9                   	leave  
  8005a9:	c3                   	ret    

008005aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	83 ec 18             	sub    $0x18,%esp
  8005b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 37                	je     8005f1 <vsnprintf+0x47>
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	7e 33                	jle    8005f1 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005c5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8005c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8005cc:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005cf:	ff 75 14             	pushl  0x14(%ebp)
  8005d2:	ff 75 10             	pushl  0x10(%ebp)
  8005d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005d8:	50                   	push   %eax
  8005d9:	68 50 02 80 00       	push   $0x800250
  8005de:	e8 89 fc ff ff       	call   80026c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb 05                	jmp    8005f6 <vsnprintf+0x4c>
  8005f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800604:	50                   	push   %eax
  800605:	ff 75 10             	pushl  0x10(%ebp)
  800608:	ff 75 0c             	pushl  0xc(%ebp)
  80060b:	ff 75 08             	pushl  0x8(%ebp)
  80060e:	e8 97 ff ff ff       	call   8005aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800613:	c9                   	leave  
  800614:	c3                   	ret    

00800615 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800615:	55                   	push   %ebp
  800616:	89 e5                	mov    %esp,%ebp
  800618:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800621:	50                   	push   %eax
  800622:	ff 75 10             	pushl  0x10(%ebp)
  800625:	ff 75 0c             	pushl  0xc(%ebp)
  800628:	ff 75 08             	pushl  0x8(%ebp)
  80062b:	e8 3c fc ff ff       	call   80026c <vprintfmt>
	va_end(ap);
  800630:	83 c4 10             	add    $0x10,%esp
}
  800633:	c9                   	leave  
  800634:	c3                   	ret    
  800635:	00 00                	add    %al,(%eax)
	...

00800638 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	8b 55 08             	mov    0x8(%ebp),%edx
  80063e:	b8 00 00 00 00       	mov    $0x0,%eax
  800643:	eb 01                	jmp    800646 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800645:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800646:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80064a:	75 f9                	jne    800645 <strlen+0xd>
		n++;
	return n;
}
  80064c:	c9                   	leave  
  80064d:	c3                   	ret    

0080064e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800654:	8b 55 0c             	mov    0xc(%ebp),%edx
  800657:	b8 00 00 00 00       	mov    $0x0,%eax
  80065c:	eb 01                	jmp    80065f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80065e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80065f:	39 d0                	cmp    %edx,%eax
  800661:	74 06                	je     800669 <strnlen+0x1b>
  800663:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800667:	75 f5                	jne    80065e <strnlen+0x10>
		n++;
	return n;
}
  800669:	c9                   	leave  
  80066a:	c3                   	ret    

0080066b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800671:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800674:	8a 01                	mov    (%ecx),%al
  800676:	88 02                	mov    %al,(%edx)
  800678:	42                   	inc    %edx
  800679:	41                   	inc    %ecx
  80067a:	84 c0                	test   %al,%al
  80067c:	75 f6                	jne    800674 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	53                   	push   %ebx
  800687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80068a:	53                   	push   %ebx
  80068b:	e8 a8 ff ff ff       	call   800638 <strlen>
	strcpy(dst + len, src);
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800696:	50                   	push   %eax
  800697:	e8 cf ff ff ff       	call   80066b <strcpy>
	return dst;
}
  80069c:	89 d8                	mov    %ebx,%eax
  80069e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	56                   	push   %esi
  8006a7:	53                   	push   %ebx
  8006a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	eb 0c                	jmp    8006c4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006b8:	8a 02                	mov    (%edx),%al
  8006ba:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8006c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006c3:	41                   	inc    %ecx
  8006c4:	39 d9                	cmp    %ebx,%ecx
  8006c6:	75 f0                	jne    8006b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	56                   	push   %esi
  8006d2:	53                   	push   %ebx
  8006d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	75 04                	jne    8006e4 <strlcpy+0x16>
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	eb 14                	jmp    8006f8 <strlcpy+0x2a>
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	eb 04                	jmp    8006ec <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006e8:	88 10                	mov    %dl,(%eax)
  8006ea:	40                   	inc    %eax
  8006eb:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8006ec:	49                   	dec    %ecx
  8006ed:	74 06                	je     8006f5 <strlcpy+0x27>
  8006ef:	8a 13                	mov    (%ebx),%dl
  8006f1:	84 d2                	test   %dl,%dl
  8006f3:	75 f3                	jne    8006e8 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8006f5:	c6 00 00             	movb   $0x0,(%eax)
  8006f8:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 55 08             	mov    0x8(%ebp),%edx
  800704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800707:	eb 02                	jmp    80070b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800709:	42                   	inc    %edx
  80070a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80070b:	8a 02                	mov    (%edx),%al
  80070d:	84 c0                	test   %al,%al
  80070f:	74 04                	je     800715 <strcmp+0x17>
  800711:	3a 01                	cmp    (%ecx),%al
  800713:	74 f4                	je     800709 <strcmp+0xb>
  800715:	0f b6 c0             	movzbl %al,%eax
  800718:	0f b6 11             	movzbl (%ecx),%edx
  80071b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800729:	8b 55 10             	mov    0x10(%ebp),%edx
  80072c:	eb 03                	jmp    800731 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80072e:	4a                   	dec    %edx
  80072f:	41                   	inc    %ecx
  800730:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800731:	85 d2                	test   %edx,%edx
  800733:	75 07                	jne    80073c <strncmp+0x1d>
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	eb 14                	jmp    800750 <strncmp+0x31>
  80073c:	8a 01                	mov    (%ecx),%al
  80073e:	84 c0                	test   %al,%al
  800740:	74 04                	je     800746 <strncmp+0x27>
  800742:	3a 03                	cmp    (%ebx),%al
  800744:	74 e8                	je     80072e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800746:	0f b6 d0             	movzbl %al,%edx
  800749:	0f b6 03             	movzbl (%ebx),%eax
  80074c:	29 c2                	sub    %eax,%edx
  80074e:	89 d0                	mov    %edx,%eax
}
  800750:	5b                   	pop    %ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80075c:	eb 05                	jmp    800763 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80075e:	38 ca                	cmp    %cl,%dl
  800760:	74 0c                	je     80076e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800762:	40                   	inc    %eax
  800763:	8a 10                	mov    (%eax),%dl
  800765:	84 d2                	test   %dl,%dl
  800767:	75 f5                	jne    80075e <strchr+0xb>
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800779:	eb 05                	jmp    800780 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80077b:	38 ca                	cmp    %cl,%dl
  80077d:	74 07                	je     800786 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80077f:	40                   	inc    %eax
  800780:	8a 10                	mov    (%eax),%dl
  800782:	84 d2                	test   %dl,%dl
  800784:	75 f5                	jne    80077b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	57                   	push   %edi
  80078c:	56                   	push   %esi
  80078d:	53                   	push   %ebx
  80078e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800797:	85 db                	test   %ebx,%ebx
  800799:	74 36                	je     8007d1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80079b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007a1:	75 29                	jne    8007cc <memset+0x44>
  8007a3:	f6 c3 03             	test   $0x3,%bl
  8007a6:	75 24                	jne    8007cc <memset+0x44>
		c &= 0xFF;
  8007a8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007ab:	89 d6                	mov    %edx,%esi
  8007ad:	c1 e6 08             	shl    $0x8,%esi
  8007b0:	89 d0                	mov    %edx,%eax
  8007b2:	c1 e0 18             	shl    $0x18,%eax
  8007b5:	89 d1                	mov    %edx,%ecx
  8007b7:	c1 e1 10             	shl    $0x10,%ecx
  8007ba:	09 c8                	or     %ecx,%eax
  8007bc:	09 c2                	or     %eax,%edx
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	09 d0                	or     %edx,%eax
  8007c2:	89 d9                	mov    %ebx,%ecx
  8007c4:	c1 e9 02             	shr    $0x2,%ecx
  8007c7:	fc                   	cld    
  8007c8:	f3 ab                	rep stos %eax,%es:(%edi)
  8007ca:	eb 05                	jmp    8007d1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007cc:	89 d9                	mov    %ebx,%ecx
  8007ce:	fc                   	cld    
  8007cf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8007d1:	89 f8                	mov    %edi,%eax
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5f                   	pop    %edi
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	57                   	push   %edi
  8007dc:	56                   	push   %esi
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007e6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007e8:	39 c6                	cmp    %eax,%esi
  8007ea:	73 36                	jae    800822 <memmove+0x4a>
  8007ec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	73 2f                	jae    800822 <memmove+0x4a>
		s += n;
		d += n;
  8007f3:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8007f6:	f6 c2 03             	test   $0x3,%dl
  8007f9:	75 1b                	jne    800816 <memmove+0x3e>
  8007fb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800801:	75 13                	jne    800816 <memmove+0x3e>
  800803:	f6 c1 03             	test   $0x3,%cl
  800806:	75 0e                	jne    800816 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800808:	8d 7e fc             	lea    -0x4(%esi),%edi
  80080b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80080e:	c1 e9 02             	shr    $0x2,%ecx
  800811:	fd                   	std    
  800812:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800814:	eb 09                	jmp    80081f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800816:	8d 7e ff             	lea    -0x1(%esi),%edi
  800819:	8d 72 ff             	lea    -0x1(%edx),%esi
  80081c:	fd                   	std    
  80081d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80081f:	fc                   	cld    
  800820:	eb 20                	jmp    800842 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800822:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800828:	75 15                	jne    80083f <memmove+0x67>
  80082a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800830:	75 0d                	jne    80083f <memmove+0x67>
  800832:	f6 c1 03             	test   $0x3,%cl
  800835:	75 08                	jne    80083f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800837:	c1 e9 02             	shr    $0x2,%ecx
  80083a:	fc                   	cld    
  80083b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80083d:	eb 03                	jmp    800842 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80083f:	fc                   	cld    
  800840:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800842:	5e                   	pop    %esi
  800843:	5f                   	pop    %edi
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800849:	ff 75 10             	pushl  0x10(%ebp)
  80084c:	ff 75 0c             	pushl  0xc(%ebp)
  80084f:	ff 75 08             	pushl  0x8(%ebp)
  800852:	e8 81 ff ff ff       	call   8007d8 <memmove>
}
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 04             	sub    $0x4,%esp
  800860:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	eb 1b                	jmp    800886 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80086b:	8a 1a                	mov    (%edx),%bl
  80086d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800870:	8a 19                	mov    (%ecx),%bl
  800872:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800875:	74 0d                	je     800884 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800877:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80087b:	0f b6 c3             	movzbl %bl,%eax
  80087e:	29 c2                	sub    %eax,%edx
  800880:	89 d0                	mov    %edx,%eax
  800882:	eb 0d                	jmp    800891 <memcmp+0x38>
		s1++, s2++;
  800884:	42                   	inc    %edx
  800885:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800886:	48                   	dec    %eax
  800887:	83 f8 ff             	cmp    $0xffffffff,%eax
  80088a:	75 df                	jne    80086b <memcmp+0x12>
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800891:	83 c4 04             	add    $0x4,%esp
  800894:	5b                   	pop    %ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	03 55 10             	add    0x10(%ebp),%edx
  8008a5:	eb 05                	jmp    8008ac <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008a7:	38 08                	cmp    %cl,(%eax)
  8008a9:	74 05                	je     8008b0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008ab:	40                   	inc    %eax
  8008ac:	39 d0                	cmp    %edx,%eax
  8008ae:	72 f7                	jb     8008a7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	83 ec 04             	sub    $0x4,%esp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c1:	eb 01                	jmp    8008c4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008c3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008c4:	8a 01                	mov    (%ecx),%al
  8008c6:	3c 20                	cmp    $0x20,%al
  8008c8:	74 f9                	je     8008c3 <strtol+0x11>
  8008ca:	3c 09                	cmp    $0x9,%al
  8008cc:	74 f5                	je     8008c3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8008ce:	3c 2b                	cmp    $0x2b,%al
  8008d0:	75 0a                	jne    8008dc <strtol+0x2a>
		s++;
  8008d2:	41                   	inc    %ecx
  8008d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008da:	eb 17                	jmp    8008f3 <strtol+0x41>
	else if (*s == '-')
  8008dc:	3c 2d                	cmp    $0x2d,%al
  8008de:	74 09                	je     8008e9 <strtol+0x37>
  8008e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008e7:	eb 0a                	jmp    8008f3 <strtol+0x41>
		s++, neg = 1;
  8008e9:	8d 49 01             	lea    0x1(%ecx),%ecx
  8008ec:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008f3:	85 f6                	test   %esi,%esi
  8008f5:	74 05                	je     8008fc <strtol+0x4a>
  8008f7:	83 fe 10             	cmp    $0x10,%esi
  8008fa:	75 1a                	jne    800916 <strtol+0x64>
  8008fc:	8a 01                	mov    (%ecx),%al
  8008fe:	3c 30                	cmp    $0x30,%al
  800900:	75 10                	jne    800912 <strtol+0x60>
  800902:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800906:	75 0a                	jne    800912 <strtol+0x60>
		s += 2, base = 16;
  800908:	83 c1 02             	add    $0x2,%ecx
  80090b:	be 10 00 00 00       	mov    $0x10,%esi
  800910:	eb 04                	jmp    800916 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800912:	85 f6                	test   %esi,%esi
  800914:	74 07                	je     80091d <strtol+0x6b>
  800916:	bf 00 00 00 00       	mov    $0x0,%edi
  80091b:	eb 13                	jmp    800930 <strtol+0x7e>
  80091d:	3c 30                	cmp    $0x30,%al
  80091f:	74 07                	je     800928 <strtol+0x76>
  800921:	be 0a 00 00 00       	mov    $0xa,%esi
  800926:	eb ee                	jmp    800916 <strtol+0x64>
		s++, base = 8;
  800928:	41                   	inc    %ecx
  800929:	be 08 00 00 00       	mov    $0x8,%esi
  80092e:	eb e6                	jmp    800916 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800930:	8a 11                	mov    (%ecx),%dl
  800932:	88 d3                	mov    %dl,%bl
  800934:	8d 42 d0             	lea    -0x30(%edx),%eax
  800937:	3c 09                	cmp    $0x9,%al
  800939:	77 08                	ja     800943 <strtol+0x91>
			dig = *s - '0';
  80093b:	0f be c2             	movsbl %dl,%eax
  80093e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800941:	eb 1c                	jmp    80095f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800943:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800946:	3c 19                	cmp    $0x19,%al
  800948:	77 08                	ja     800952 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80094a:	0f be c2             	movsbl %dl,%eax
  80094d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800950:	eb 0d                	jmp    80095f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800952:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800955:	3c 19                	cmp    $0x19,%al
  800957:	77 15                	ja     80096e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800959:	0f be c2             	movsbl %dl,%eax
  80095c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80095f:	39 f2                	cmp    %esi,%edx
  800961:	7d 0b                	jge    80096e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800963:	41                   	inc    %ecx
  800964:	89 f8                	mov    %edi,%eax
  800966:	0f af c6             	imul   %esi,%eax
  800969:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  80096c:	eb c2                	jmp    800930 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  80096e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800970:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800974:	74 05                	je     80097b <strtol+0xc9>
		*endptr = (char *) s;
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
  800979:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  80097b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80097f:	74 04                	je     800985 <strtol+0xd3>
  800981:	89 c7                	mov    %eax,%edi
  800983:	f7 df                	neg    %edi
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	83 c4 04             	add    $0x4,%esp
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    
	...

00800990 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800996:	b8 01 00 00 00       	mov    $0x1,%eax
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a0:	89 fa                	mov    %edi,%edx
  8009a2:	89 f9                	mov    %edi,%ecx
  8009a4:	89 fb                	mov    %edi,%ebx
  8009a6:	89 fe                	mov    %edi,%esi
  8009a8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	83 ec 04             	sub    $0x4,%esp
  8009b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	89 f8                	mov    %edi,%eax
  8009c5:	89 fb                	mov    %edi,%ebx
  8009c7:	89 fe                	mov    %edi,%esi
  8009c9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009cb:	83 c4 04             	add    $0x4,%esp
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009df:	b8 0d 00 00 00       	mov    $0xd,%eax
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e9:	89 f9                	mov    %edi,%ecx
  8009eb:	89 fb                	mov    %edi,%ebx
  8009ed:	89 fe                	mov    %edi,%esi
  8009ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	7e 17                	jle    800a0c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009f5:	83 ec 0c             	sub    $0xc,%esp
  8009f8:	50                   	push   %eax
  8009f9:	6a 0d                	push   $0xd
  8009fb:	68 5f 12 80 00       	push   $0x80125f
  800a00:	6a 23                	push   $0x23
  800a02:	68 7c 12 80 00       	push   $0x80127c
  800a07:	e8 38 02 00 00       	call   800c44 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5f                   	pop    %edi
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a23:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a2b:	be 00 00 00 00       	mov    $0x0,%esi
  800a30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	83 ec 0c             	sub    $0xc,%esp
  800a40:	8b 55 08             	mov    0x8(%ebp),%edx
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a50:	89 fb                	mov    %edi,%ebx
  800a52:	89 fe                	mov    %edi,%esi
  800a54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a56:	85 c0                	test   %eax,%eax
  800a58:	7e 17                	jle    800a71 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a5a:	83 ec 0c             	sub    $0xc,%esp
  800a5d:	50                   	push   %eax
  800a5e:	6a 0a                	push   $0xa
  800a60:	68 5f 12 80 00       	push   $0x80125f
  800a65:	6a 23                	push   $0x23
  800a67:	68 7c 12 80 00       	push   $0x80127c
  800a6c:	e8 d3 01 00 00       	call   800c44 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	83 ec 0c             	sub    $0xc,%esp
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	b8 09 00 00 00       	mov    $0x9,%eax
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a92:	89 fb                	mov    %edi,%ebx
  800a94:	89 fe                	mov    %edi,%esi
  800a96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	7e 17                	jle    800ab3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	50                   	push   %eax
  800aa0:	6a 09                	push   $0x9
  800aa2:	68 5f 12 80 00       	push   $0x80125f
  800aa7:	6a 23                	push   $0x23
  800aa9:	68 7c 12 80 00       	push   $0x80127c
  800aae:	e8 91 01 00 00       	call   800c44 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 0c             	sub    $0xc,%esp
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 08 00 00 00       	mov    $0x8,%eax
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad4:	89 fb                	mov    %edi,%ebx
  800ad6:	89 fe                	mov    %edi,%esi
  800ad8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ada:	85 c0                	test   %eax,%eax
  800adc:	7e 17                	jle    800af5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	50                   	push   %eax
  800ae2:	6a 08                	push   $0x8
  800ae4:	68 5f 12 80 00       	push   $0x80125f
  800ae9:	6a 23                	push   $0x23
  800aeb:	68 7c 12 80 00       	push   $0x80127c
  800af0:	e8 4f 01 00 00       	call   800c44 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b11:	bf 00 00 00 00       	mov    $0x0,%edi
  800b16:	89 fb                	mov    %edi,%ebx
  800b18:	89 fe                	mov    %edi,%esi
  800b1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	7e 17                	jle    800b37 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	50                   	push   %eax
  800b24:	6a 06                	push   $0x6
  800b26:	68 5f 12 80 00       	push   $0x80125f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 7c 12 80 00       	push   $0x80127c
  800b32:	e8 0d 01 00 00       	call   800c44 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b54:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b57:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5e:	85 c0                	test   %eax,%eax
  800b60:	7e 17                	jle    800b79 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	50                   	push   %eax
  800b66:	6a 05                	push   $0x5
  800b68:	68 5f 12 80 00       	push   $0x80125f
  800b6d:	6a 23                	push   $0x23
  800b6f:	68 7c 12 80 00       	push   $0x80127c
  800b74:	e8 cb 00 00 00       	call   800c44 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b93:	b8 04 00 00 00       	mov    $0x4,%eax
  800b98:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9d:	89 fe                	mov    %edi,%esi
  800b9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 04                	push   $0x4
  800bab:	68 5f 12 80 00       	push   $0x80125f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 7c 12 80 00       	push   $0x80127c
  800bb7:	e8 88 00 00 00       	call   800c44 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd4:	89 fa                	mov    %edi,%edx
  800bd6:	89 f9                	mov    %edi,%ecx
  800bd8:	89 fb                	mov    %edi,%ebx
  800bda:	89 fe                	mov    %edi,%esi
  800bdc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf3:	89 fa                	mov    %edi,%edx
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	89 fb                	mov    %edi,%ebx
  800bf9:	89 fe                	mov    %edi,%esi
  800bfb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c13:	bf 00 00 00 00       	mov    $0x0,%edi
  800c18:	89 f9                	mov    %edi,%ecx
  800c1a:	89 fb                	mov    %edi,%ebx
  800c1c:	89 fe                	mov    %edi,%esi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 03                	push   $0x3
  800c2a:	68 5f 12 80 00       	push   $0x80125f
  800c2f:	6a 23                	push   $0x23
  800c31:	68 7c 12 80 00       	push   $0x80127c
  800c36:	e8 09 00 00 00       	call   800c44 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    
	...

00800c44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	53                   	push   %ebx
  800c48:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800c4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c51:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c57:	e8 87 ff ff ff       	call   800be3 <sys_getenvid>
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	ff 75 0c             	pushl  0xc(%ebp)
  800c62:	ff 75 08             	pushl  0x8(%ebp)
  800c65:	53                   	push   %ebx
  800c66:	50                   	push   %eax
  800c67:	68 8c 12 80 00       	push   $0x80128c
  800c6c:	e8 a8 f4 ff ff       	call   800119 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c71:	83 c4 18             	add    $0x18,%esp
  800c74:	ff 75 f8             	pushl  -0x8(%ebp)
  800c77:	ff 75 10             	pushl  0x10(%ebp)
  800c7a:	e8 49 f4 ff ff       	call   8000c8 <vcprintf>
	cprintf("\n");
  800c7f:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  800c86:	e8 8e f4 ff ff       	call   800119 <cprintf>
  800c8b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c8e:	cc                   	int3   
  800c8f:	eb fd                	jmp    800c8e <_panic+0x4a>
  800c91:	00 00                	add    %al,(%eax)
	...

00800c94 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	83 ec 28             	sub    $0x28,%esp
  800c9c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ca3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800caa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cad:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800cb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cb3:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800cb5:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cc3:	85 ff                	test   %edi,%edi
  800cc5:	75 21                	jne    800ce8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cc7:	39 d1                	cmp    %edx,%ecx
  800cc9:	76 49                	jbe    800d14 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ccb:	f7 f1                	div    %ecx
  800ccd:	89 c1                	mov    %eax,%ecx
  800ccf:	31 c0                	xor    %eax,%eax
  800cd1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cd4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cd7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cda:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ce0:	83 c4 28             	add    $0x28,%esp
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    
  800ce7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ce8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ceb:	0f 87 97 00 00 00    	ja     800d88 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf1:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cf4:	83 f0 1f             	xor    $0x1f,%eax
  800cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cfa:	75 34                	jne    800d30 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cfc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cff:	72 08                	jb     800d09 <__udivdi3+0x75>
  800d01:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d04:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d07:	77 7f                	ja     800d88 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d09:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d0e:	31 c0                	xor    %eax,%eax
  800d10:	eb c2                	jmp    800cd4 <__udivdi3+0x40>
  800d12:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d17:	85 c0                	test   %eax,%eax
  800d19:	74 79                	je     800d94 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d1e:	89 fa                	mov    %edi,%edx
  800d20:	f7 f1                	div    %ecx
  800d22:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d27:	f7 f1                	div    %ecx
  800d29:	89 c1                	mov    %eax,%ecx
  800d2b:	89 f0                	mov    %esi,%eax
  800d2d:	eb a5                	jmp    800cd4 <__udivdi3+0x40>
  800d2f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d30:	b8 20 00 00 00       	mov    $0x20,%eax
  800d35:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d3b:	89 fa                	mov    %edi,%edx
  800d3d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d40:	d3 e2                	shl    %cl,%edx
  800d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d45:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d48:	d3 e8                	shr    %cl,%eax
  800d4a:	89 d7                	mov    %edx,%edi
  800d4c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d4e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d51:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d54:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d59:	d3 e0                	shl    %cl,%eax
  800d5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d5e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d61:	d3 ea                	shr    %cl,%edx
  800d63:	09 d0                	or     %edx,%eax
  800d65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d68:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d6b:	d3 ea                	shr    %cl,%edx
  800d6d:	f7 f7                	div    %edi
  800d6f:	89 d7                	mov    %edx,%edi
  800d71:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d74:	f7 e6                	mul    %esi
  800d76:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d78:	39 d7                	cmp    %edx,%edi
  800d7a:	72 38                	jb     800db4 <__udivdi3+0x120>
  800d7c:	74 27                	je     800da5 <__udivdi3+0x111>
  800d7e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d81:	31 c0                	xor    %eax,%eax
  800d83:	e9 4c ff ff ff       	jmp    800cd4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d88:	31 c9                	xor    %ecx,%ecx
  800d8a:	31 c0                	xor    %eax,%eax
  800d8c:	e9 43 ff ff ff       	jmp    800cd4 <__udivdi3+0x40>
  800d91:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d94:	b8 01 00 00 00       	mov    $0x1,%eax
  800d99:	31 d2                	xor    %edx,%edx
  800d9b:	f7 75 f4             	divl   -0xc(%ebp)
  800d9e:	89 c1                	mov    %eax,%ecx
  800da0:	e9 76 ff ff ff       	jmp    800d1b <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800da8:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800dab:	d3 e0                	shl    %cl,%eax
  800dad:	39 f0                	cmp    %esi,%eax
  800daf:	73 cd                	jae    800d7e <__udivdi3+0xea>
  800db1:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800db4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800db7:	49                   	dec    %ecx
  800db8:	31 c0                	xor    %eax,%eax
  800dba:	e9 15 ff ff ff       	jmp    800cd4 <__udivdi3+0x40>
	...

00800dc0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	83 ec 30             	sub    $0x30,%esp
  800dc8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dcf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dd6:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ddc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddf:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800de5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800de7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dea:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800ded:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df0:	85 d2                	test   %edx,%edx
  800df2:	75 1c                	jne    800e10 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800df4:	89 fa                	mov    %edi,%edx
  800df6:	39 f8                	cmp    %edi,%eax
  800df8:	0f 86 c2 00 00 00    	jbe    800ec0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e02:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e05:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e0c:	eb 12                	jmp    800e20 <__umoddi3+0x60>
  800e0e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e13:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e16:	76 18                	jbe    800e30 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e18:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e1b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e1e:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e20:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e23:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e26:	83 c4 30             	add    $0x30,%esp
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e30:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e34:	83 f0 1f             	xor    $0x1f,%eax
  800e37:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e3a:	0f 84 ac 00 00 00    	je     800eec <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e40:	b8 20 00 00 00       	mov    $0x20,%eax
  800e45:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e4b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e4e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e51:	d3 e2                	shl    %cl,%edx
  800e53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e56:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e59:	d3 e8                	shr    %cl,%eax
  800e5b:	89 d6                	mov    %edx,%esi
  800e5d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e62:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e65:	d3 e0                	shl    %cl,%eax
  800e67:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e6a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e6d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e72:	d3 e0                	shl    %cl,%eax
  800e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e77:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e7a:	d3 ea                	shr    %cl,%edx
  800e7c:	09 d0                	or     %edx,%eax
  800e7e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e81:	d3 ea                	shr    %cl,%edx
  800e83:	f7 f6                	div    %esi
  800e85:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e88:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e8e:	0f 82 8d 00 00 00    	jb     800f21 <__umoddi3+0x161>
  800e94:	0f 84 91 00 00 00    	je     800f2b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e9d:	29 c7                	sub    %eax,%edi
  800e9f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea1:	89 f2                	mov    %esi,%edx
  800ea3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ea6:	d3 e2                	shl    %cl,%edx
  800ea8:	89 f8                	mov    %edi,%eax
  800eaa:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ead:	d3 e8                	shr    %cl,%eax
  800eaf:	09 c2                	or     %eax,%edx
  800eb1:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800eb4:	d3 ee                	shr    %cl,%esi
  800eb6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800eb9:	e9 62 ff ff ff       	jmp    800e20 <__umoddi3+0x60>
  800ebe:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ec0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	74 15                	je     800edc <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ec7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eca:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ecd:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed2:	f7 f1                	div    %ecx
  800ed4:	e9 29 ff ff ff       	jmp    800e02 <__umoddi3+0x42>
  800ed9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800edc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee1:	31 d2                	xor    %edx,%edx
  800ee3:	f7 75 ec             	divl   -0x14(%ebp)
  800ee6:	89 c1                	mov    %eax,%ecx
  800ee8:	eb dd                	jmp    800ec7 <__umoddi3+0x107>
  800eea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eef:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ef2:	72 19                	jb     800f0d <__umoddi3+0x14d>
  800ef4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800efa:	76 11                	jbe    800f0d <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800efc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eff:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f02:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f05:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f08:	e9 13 ff ff ff       	jmp    800e20 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f0d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f13:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f16:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f1c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f1f:	eb db                	jmp    800efc <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f21:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f24:	19 f2                	sbb    %esi,%edx
  800f26:	e9 6f ff ff ff       	jmp    800e9a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2b:	39 c7                	cmp    %eax,%edi
  800f2d:	72 f2                	jb     800f21 <__umoddi3+0x161>
  800f2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f32:	e9 63 ff ff ff       	jmp    800e9a <__umoddi3+0xda>
