
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	ff 35 00 00 10 f0    	pushl  0xf0100000
  800040:	68 40 0f 80 00       	push   $0x800f40
  800045:	e8 bb 00 00 00       	call   800105 <cprintf>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80005b:	e8 6f 0b 00 00       	call   800bcf <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	53                   	push   %ebx
  80008a:	56                   	push   %esi
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 41 0b 00 00       	call   800bee <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000bd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000c4:	00 00 00 
	b.cnt = 0;
  8000c7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8000ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d1:	ff 75 0c             	pushl  0xc(%ebp)
  8000d4:	ff 75 08             	pushl  0x8(%ebp)
  8000d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8000dd:	50                   	push   %eax
  8000de:	68 1c 01 80 00       	push   $0x80011c
  8000e3:	e8 70 01 00 00       	call   800258 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000e8:	83 c4 08             	add    $0x8,%esp
  8000eb:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8000f1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 9e 08 00 00       	call   80099b <sys_cputs>
  8000fd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80010b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80010e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800111:	50                   	push   %eax
  800112:	ff 75 08             	pushl  0x8(%ebp)
  800115:	e8 9a ff ff ff       	call   8000b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	53                   	push   %ebx
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800126:	8b 03                	mov    (%ebx),%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012f:	40                   	inc    %eax
  800130:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800132:	3d ff 00 00 00       	cmp    $0xff,%eax
  800137:	75 1a                	jne    800153 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	68 ff 00 00 00       	push   $0xff
  800141:	8d 43 08             	lea    0x8(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	e8 51 08 00 00       	call   80099b <sys_cputs>
		b->idx = 0;
  80014a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800150:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800153:	ff 43 04             	incl   0x4(%ebx)
}
  800156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800159:	c9                   	leave  
  80015a:	c3                   	ret    
	...

0080015c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 1c             	sub    $0x1c,%esp
  800165:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800168:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80016b:	8b 45 08             	mov    0x8(%ebp),%eax
  80016e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800171:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800174:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800177:	8b 55 10             	mov    0x10(%ebp),%edx
  80017a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	bf 00 00 00 00       	mov    $0x0,%edi
  800184:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800187:	72 04                	jb     80018d <printnum+0x31>
  800189:	39 c2                	cmp    %eax,%edx
  80018b:	77 3f                	ja     8001cc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	ff 75 18             	pushl  0x18(%ebp)
  800193:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	52                   	push   %edx
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a3:	e8 d8 0a 00 00       	call   800c80 <__udivdi3>
  8001a8:	83 c4 18             	add    $0x18,%esp
  8001ab:	52                   	push   %edx
  8001ac:	50                   	push   %eax
  8001ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001b3:	e8 a4 ff ff ff       	call   80015c <printnum>
  8001b8:	83 c4 20             	add    $0x20,%esp
  8001bb:	eb 14                	jmp    8001d1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	ff 75 e8             	pushl  -0x18(%ebp)
  8001c3:	ff 75 18             	pushl  0x18(%ebp)
  8001c6:	ff 55 ec             	call   *-0x14(%ebp)
  8001c9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cc:	4b                   	dec    %ebx
  8001cd:	85 db                	test   %ebx,%ebx
  8001cf:	7f ec                	jg     8001bd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	ff 75 e8             	pushl  -0x18(%ebp)
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	e8 c5 0b 00 00       	call   800dac <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 71 0f 80 00 	movsbl 0x800f71(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff 55 ec             	call   *-0x14(%ebp)
  8001f5:	83 c4 10             	add    $0x10,%esp
}
  8001f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5f                   	pop    %edi
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800205:	83 fa 01             	cmp    $0x1,%edx
  800208:	7e 0e                	jle    800218 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80020a:	8b 10                	mov    (%eax),%edx
  80020c:	8d 42 08             	lea    0x8(%edx),%eax
  80020f:	89 01                	mov    %eax,(%ecx)
  800211:	8b 02                	mov    (%edx),%eax
  800213:	8b 52 04             	mov    0x4(%edx),%edx
  800216:	eb 22                	jmp    80023a <getuint+0x3a>
	else if (lflag)
  800218:	85 d2                	test   %edx,%edx
  80021a:	74 10                	je     80022c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 42 04             	lea    0x4(%edx),%eax
  800221:	89 01                	mov    %eax,(%ecx)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	ba 00 00 00 00       	mov    $0x0,%edx
  80022a:	eb 0e                	jmp    80023a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80022c:	8b 10                	mov    (%eax),%edx
  80022e:	8d 42 04             	lea    0x4(%edx),%eax
  800231:	89 01                	mov    %eax,(%ecx)
  800233:	8b 02                	mov    (%edx),%eax
  800235:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800242:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800245:	8b 11                	mov    (%ecx),%edx
  800247:	3b 51 04             	cmp    0x4(%ecx),%edx
  80024a:	73 0a                	jae    800256 <sprintputch+0x1a>
		*b->buf++ = ch;
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
  800251:	8d 42 01             	lea    0x1(%edx),%eax
  800254:	89 01                	mov    %eax,(%ecx)
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 3c             	sub    $0x3c,%esp
  800261:	8b 75 08             	mov    0x8(%ebp),%esi
  800264:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800267:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80026a:	eb 1a                	jmp    800286 <vprintfmt+0x2e>
  80026c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80026f:	eb 15                	jmp    800286 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800271:	84 c0                	test   %al,%al
  800273:	0f 84 15 03 00 00    	je     80058e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	57                   	push   %edi
  80027d:	0f b6 c0             	movzbl %al,%eax
  800280:	50                   	push   %eax
  800281:	ff d6                	call   *%esi
  800283:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800286:	8a 03                	mov    (%ebx),%al
  800288:	43                   	inc    %ebx
  800289:	3c 25                	cmp    $0x25,%al
  80028b:	75 e4                	jne    800271 <vprintfmt+0x19>
  80028d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800294:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80029b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002a9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002ad:	eb 0a                	jmp    8002b9 <vprintfmt+0x61>
  8002af:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8002b6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8002b9:	8a 03                	mov    (%ebx),%al
  8002bb:	0f b6 d0             	movzbl %al,%edx
  8002be:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8002c1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8002c4:	83 e8 23             	sub    $0x23,%eax
  8002c7:	3c 55                	cmp    $0x55,%al
  8002c9:	0f 87 9c 02 00 00    	ja     80056b <vprintfmt+0x313>
  8002cf:	0f b6 c0             	movzbl %al,%eax
  8002d2:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002d9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8002dd:	eb d7                	jmp    8002b6 <vprintfmt+0x5e>
  8002df:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8002e3:	eb d1                	jmp    8002b6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8002e5:	89 d9                	mov    %ebx,%ecx
  8002e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8002f4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8002f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8002fb:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8002ff:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800300:	8d 42 d0             	lea    -0x30(%edx),%eax
  800303:	83 f8 09             	cmp    $0x9,%eax
  800306:	77 21                	ja     800329 <vprintfmt+0xd1>
  800308:	eb e4                	jmp    8002ee <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80030a:	8b 55 14             	mov    0x14(%ebp),%edx
  80030d:	8d 42 04             	lea    0x4(%edx),%eax
  800310:	89 45 14             	mov    %eax,0x14(%ebp)
  800313:	8b 12                	mov    (%edx),%edx
  800315:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800318:	eb 12                	jmp    80032c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80031a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80031e:	79 96                	jns    8002b6 <vprintfmt+0x5e>
  800320:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800327:	eb 8d                	jmp    8002b6 <vprintfmt+0x5e>
  800329:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80032c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800330:	79 84                	jns    8002b6 <vprintfmt+0x5e>
  800332:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800335:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800338:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80033f:	e9 72 ff ff ff       	jmp    8002b6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800344:	ff 45 d4             	incl   -0x2c(%ebp)
  800347:	e9 6a ff ff ff       	jmp    8002b6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80034c:	8b 55 14             	mov    0x14(%ebp),%edx
  80034f:	8d 42 04             	lea    0x4(%edx),%eax
  800352:	89 45 14             	mov    %eax,0x14(%ebp)
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	57                   	push   %edi
  800359:	ff 32                	pushl  (%edx)
  80035b:	ff d6                	call   *%esi
			break;
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	e9 07 ff ff ff       	jmp    80026c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800365:	8b 55 14             	mov    0x14(%ebp),%edx
  800368:	8d 42 04             	lea    0x4(%edx),%eax
  80036b:	89 45 14             	mov    %eax,0x14(%ebp)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	85 c0                	test   %eax,%eax
  800372:	79 02                	jns    800376 <vprintfmt+0x11e>
  800374:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800376:	83 f8 0f             	cmp    $0xf,%eax
  800379:	7f 0b                	jg     800386 <vprintfmt+0x12e>
  80037b:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800382:	85 d2                	test   %edx,%edx
  800384:	75 15                	jne    80039b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800386:	50                   	push   %eax
  800387:	68 82 0f 80 00       	push   $0x800f82
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	e8 6e 02 00 00       	call   800601 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	e9 d1 fe ff ff       	jmp    80026c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80039b:	52                   	push   %edx
  80039c:	68 8b 0f 80 00       	push   $0x800f8b
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	e8 59 02 00 00       	call   800601 <printfmt>
  8003a8:	83 c4 10             	add    $0x10,%esp
  8003ab:	e9 bc fe ff ff       	jmp    80026c <vprintfmt+0x14>
  8003b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003b3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bc:	8d 42 04             	lea    0x4(%edx),%eax
  8003bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c2:	8b 1a                	mov    (%edx),%ebx
  8003c4:	85 db                	test   %ebx,%ebx
  8003c6:	75 05                	jne    8003cd <vprintfmt+0x175>
  8003c8:	bb 8e 0f 80 00       	mov    $0x800f8e,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8003cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8003d1:	7e 66                	jle    800439 <vprintfmt+0x1e1>
  8003d3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8003d7:	74 60                	je     800439 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	51                   	push   %ecx
  8003dd:	53                   	push   %ebx
  8003de:	e8 57 02 00 00       	call   80063a <strnlen>
  8003e3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8003e6:	29 c1                	sub    %eax,%ecx
  8003e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8003eb:	83 c4 10             	add    $0x10,%esp
  8003ee:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8003f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003f5:	eb 0f                	jmp    800406 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	57                   	push   %edi
  8003fb:	ff 75 c4             	pushl  -0x3c(%ebp)
  8003fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800400:	ff 4d d8             	decl   -0x28(%ebp)
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80040a:	7f eb                	jg     8003f7 <vprintfmt+0x19f>
  80040c:	eb 2b                	jmp    800439 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80040e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	74 15                	je     80042c <vprintfmt+0x1d4>
  800417:	8d 42 e0             	lea    -0x20(%edx),%eax
  80041a:	83 f8 5e             	cmp    $0x5e,%eax
  80041d:	76 0d                	jbe    80042c <vprintfmt+0x1d4>
					putch('?', putdat);
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	57                   	push   %edi
  800423:	6a 3f                	push   $0x3f
  800425:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	eb 0a                	jmp    800436 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	57                   	push   %edi
  800430:	52                   	push   %edx
  800431:	ff d6                	call   *%esi
  800433:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800436:	ff 4d d8             	decl   -0x28(%ebp)
  800439:	8a 03                	mov    (%ebx),%al
  80043b:	43                   	inc    %ebx
  80043c:	84 c0                	test   %al,%al
  80043e:	74 1b                	je     80045b <vprintfmt+0x203>
  800440:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800444:	78 c8                	js     80040e <vprintfmt+0x1b6>
  800446:	ff 4d dc             	decl   -0x24(%ebp)
  800449:	79 c3                	jns    80040e <vprintfmt+0x1b6>
  80044b:	eb 0e                	jmp    80045b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	57                   	push   %edi
  800451:	6a 20                	push   $0x20
  800453:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800455:	ff 4d d8             	decl   -0x28(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	7f ec                	jg     80044d <vprintfmt+0x1f5>
  800461:	e9 06 fe ff ff       	jmp    80026c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800466:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80046a:	7e 10                	jle    80047c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80046c:	8b 55 14             	mov    0x14(%ebp),%edx
  80046f:	8d 42 08             	lea    0x8(%edx),%eax
  800472:	89 45 14             	mov    %eax,0x14(%ebp)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	8b 52 04             	mov    0x4(%edx),%edx
  80047a:	eb 20                	jmp    80049c <vprintfmt+0x244>
	else if (lflag)
  80047c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800480:	74 0e                	je     800490 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	99                   	cltd   
  80048e:	eb 0c                	jmp    80049c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80049c:	89 d1                	mov    %edx,%ecx
  80049e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	78 0a                	js     8004b4 <vprintfmt+0x25c>
  8004aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004af:	e9 89 00 00 00       	jmp    80053d <vprintfmt+0x2e5>
				putch('-', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	57                   	push   %edi
  8004b8:	6a 2d                	push   $0x2d
  8004ba:	ff d6                	call   *%esi
				num = -(long long) num;
  8004bc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c2:	f7 da                	neg    %edx
  8004c4:	83 d1 00             	adc    $0x0,%ecx
  8004c7:	f7 d9                	neg    %ecx
  8004c9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	eb 6a                	jmp    80053d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8004d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8004d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d9:	e8 22 fd ff ff       	call   800200 <getuint>
  8004de:	89 d1                	mov    %edx,%ecx
  8004e0:	89 c2                	mov    %eax,%edx
  8004e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004e7:	eb 54                	jmp    80053d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8004e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ef:	e8 0c fd ff ff       	call   800200 <getuint>
  8004f4:	89 d1                	mov    %edx,%ecx
  8004f6:	89 c2                	mov    %eax,%edx
  8004f8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8004fd:	eb 3e                	jmp    80053d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	57                   	push   %edi
  800503:	6a 30                	push   $0x30
  800505:	ff d6                	call   *%esi
			putch('x', putdat);
  800507:	83 c4 08             	add    $0x8,%esp
  80050a:	57                   	push   %edi
  80050b:	6a 78                	push   $0x78
  80050d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80050f:	8b 55 14             	mov    0x14(%ebp),%edx
  800512:	8d 42 04             	lea    0x4(%edx),%eax
  800515:	89 45 14             	mov    %eax,0x14(%ebp)
  800518:	8b 12                	mov    (%edx),%edx
  80051a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb 14                	jmp    80053d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800529:	8d 45 14             	lea    0x14(%ebp),%eax
  80052c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80052f:	e8 cc fc ff ff       	call   800200 <getuint>
  800534:	89 d1                	mov    %edx,%ecx
  800536:	89 c2                	mov    %eax,%edx
  800538:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800544:	50                   	push   %eax
  800545:	ff 75 d8             	pushl  -0x28(%ebp)
  800548:	53                   	push   %ebx
  800549:	51                   	push   %ecx
  80054a:	52                   	push   %edx
  80054b:	89 fa                	mov    %edi,%edx
  80054d:	89 f0                	mov    %esi,%eax
  80054f:	e8 08 fc ff ff       	call   80015c <printnum>
			break;
  800554:	83 c4 20             	add    $0x20,%esp
  800557:	e9 10 fd ff ff       	jmp    80026c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	57                   	push   %edi
  800560:	52                   	push   %edx
  800561:	ff d6                	call   *%esi
			break;
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	e9 01 fd ff ff       	jmp    80026c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	6a 25                	push   $0x25
  800571:	ff d6                	call   *%esi
  800573:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800576:	83 ea 02             	sub    $0x2,%edx
  800579:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80057c:	8a 02                	mov    (%edx),%al
  80057e:	4a                   	dec    %edx
  80057f:	3c 25                	cmp    $0x25,%al
  800581:	75 f9                	jne    80057c <vprintfmt+0x324>
  800583:	83 c2 02             	add    $0x2,%edx
  800586:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800589:	e9 de fc ff ff       	jmp    80026c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80058e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800591:	5b                   	pop    %ebx
  800592:	5e                   	pop    %esi
  800593:	5f                   	pop    %edi
  800594:	c9                   	leave  
  800595:	c3                   	ret    

00800596 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	83 ec 18             	sub    $0x18,%esp
  80059c:	8b 55 08             	mov    0x8(%ebp),%edx
  80059f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	74 37                	je     8005dd <vsnprintf+0x47>
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	7e 33                	jle    8005dd <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005b1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8005b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8005b8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005bb:	ff 75 14             	pushl  0x14(%ebp)
  8005be:	ff 75 10             	pushl  0x10(%ebp)
  8005c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005c4:	50                   	push   %eax
  8005c5:	68 3c 02 80 00       	push   $0x80023c
  8005ca:	e8 89 fc ff ff       	call   800258 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8005d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	eb 05                	jmp    8005e2 <vsnprintf+0x4c>
  8005dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005e2:	c9                   	leave  
  8005e3:	c3                   	ret    

008005e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8005f0:	50                   	push   %eax
  8005f1:	ff 75 10             	pushl  0x10(%ebp)
  8005f4:	ff 75 0c             	pushl  0xc(%ebp)
  8005f7:	ff 75 08             	pushl  0x8(%ebp)
  8005fa:	e8 97 ff ff ff       	call   800596 <vsnprintf>
	va_end(ap);

	return rc;
}
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    

00800601 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800607:	8d 45 14             	lea    0x14(%ebp),%eax
  80060a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80060d:	50                   	push   %eax
  80060e:	ff 75 10             	pushl  0x10(%ebp)
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	ff 75 08             	pushl  0x8(%ebp)
  800617:	e8 3c fc ff ff       	call   800258 <vprintfmt>
	va_end(ap);
  80061c:	83 c4 10             	add    $0x10,%esp
}
  80061f:	c9                   	leave  
  800620:	c3                   	ret    
  800621:	00 00                	add    %al,(%eax)
	...

00800624 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	8b 55 08             	mov    0x8(%ebp),%edx
  80062a:	b8 00 00 00 00       	mov    $0x0,%eax
  80062f:	eb 01                	jmp    800632 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800631:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800632:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800636:	75 f9                	jne    800631 <strlen+0xd>
		n++;
	return n;
}
  800638:	c9                   	leave  
  800639:	c3                   	ret    

0080063a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800640:	8b 55 0c             	mov    0xc(%ebp),%edx
  800643:	b8 00 00 00 00       	mov    $0x0,%eax
  800648:	eb 01                	jmp    80064b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80064a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80064b:	39 d0                	cmp    %edx,%eax
  80064d:	74 06                	je     800655 <strnlen+0x1b>
  80064f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800653:	75 f5                	jne    80064a <strnlen+0x10>
		n++;
	return n;
}
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800660:	8a 01                	mov    (%ecx),%al
  800662:	88 02                	mov    %al,(%edx)
  800664:	42                   	inc    %edx
  800665:	41                   	inc    %ecx
  800666:	84 c0                	test   %al,%al
  800668:	75 f6                	jne    800660 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	53                   	push   %ebx
  800673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800676:	53                   	push   %ebx
  800677:	e8 a8 ff ff ff       	call   800624 <strlen>
	strcpy(dst + len, src);
  80067c:	ff 75 0c             	pushl  0xc(%ebp)
  80067f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800682:	50                   	push   %eax
  800683:	e8 cf ff ff ff       	call   800657 <strcpy>
	return dst;
}
  800688:	89 d8                	mov    %ebx,%eax
  80068a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	56                   	push   %esi
  800693:	53                   	push   %ebx
  800694:	8b 75 08             	mov    0x8(%ebp),%esi
  800697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	eb 0c                	jmp    8006b0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006a4:	8a 02                	mov    (%edx),%al
  8006a6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8006ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006af:	41                   	inc    %ecx
  8006b0:	39 d9                	cmp    %ebx,%ecx
  8006b2:	75 f0                	jne    8006a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	56                   	push   %esi
  8006be:	53                   	push   %ebx
  8006bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 04                	jne    8006d0 <strlcpy+0x16>
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	eb 14                	jmp    8006e4 <strlcpy+0x2a>
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	eb 04                	jmp    8006d8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8006d4:	88 10                	mov    %dl,(%eax)
  8006d6:	40                   	inc    %eax
  8006d7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8006d8:	49                   	dec    %ecx
  8006d9:	74 06                	je     8006e1 <strlcpy+0x27>
  8006db:	8a 13                	mov    (%ebx),%dl
  8006dd:	84 d2                	test   %dl,%dl
  8006df:	75 f3                	jne    8006d4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8006e1:	c6 00 00             	movb   $0x0,(%eax)
  8006e4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f3:	eb 02                	jmp    8006f7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8006f5:	42                   	inc    %edx
  8006f6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8006f7:	8a 02                	mov    (%edx),%al
  8006f9:	84 c0                	test   %al,%al
  8006fb:	74 04                	je     800701 <strcmp+0x17>
  8006fd:	3a 01                	cmp    (%ecx),%al
  8006ff:	74 f4                	je     8006f5 <strcmp+0xb>
  800701:	0f b6 c0             	movzbl %al,%eax
  800704:	0f b6 11             	movzbl (%ecx),%edx
  800707:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800715:	8b 55 10             	mov    0x10(%ebp),%edx
  800718:	eb 03                	jmp    80071d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80071a:	4a                   	dec    %edx
  80071b:	41                   	inc    %ecx
  80071c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80071d:	85 d2                	test   %edx,%edx
  80071f:	75 07                	jne    800728 <strncmp+0x1d>
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	eb 14                	jmp    80073c <strncmp+0x31>
  800728:	8a 01                	mov    (%ecx),%al
  80072a:	84 c0                	test   %al,%al
  80072c:	74 04                	je     800732 <strncmp+0x27>
  80072e:	3a 03                	cmp    (%ebx),%al
  800730:	74 e8                	je     80071a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800732:	0f b6 d0             	movzbl %al,%edx
  800735:	0f b6 03             	movzbl (%ebx),%eax
  800738:	29 c2                	sub    %eax,%edx
  80073a:	89 d0                	mov    %edx,%eax
}
  80073c:	5b                   	pop    %ebx
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800748:	eb 05                	jmp    80074f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80074a:	38 ca                	cmp    %cl,%dl
  80074c:	74 0c                	je     80075a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80074e:	40                   	inc    %eax
  80074f:	8a 10                	mov    (%eax),%dl
  800751:	84 d2                	test   %dl,%dl
  800753:	75 f5                	jne    80074a <strchr+0xb>
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800765:	eb 05                	jmp    80076c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800767:	38 ca                	cmp    %cl,%dl
  800769:	74 07                	je     800772 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80076b:	40                   	inc    %eax
  80076c:	8a 10                	mov    (%eax),%dl
  80076e:	84 d2                	test   %dl,%dl
  800770:	75 f5                	jne    800767 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	57                   	push   %edi
  800778:	56                   	push   %esi
  800779:	53                   	push   %ebx
  80077a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800783:	85 db                	test   %ebx,%ebx
  800785:	74 36                	je     8007bd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800787:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80078d:	75 29                	jne    8007b8 <memset+0x44>
  80078f:	f6 c3 03             	test   $0x3,%bl
  800792:	75 24                	jne    8007b8 <memset+0x44>
		c &= 0xFF;
  800794:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800797:	89 d6                	mov    %edx,%esi
  800799:	c1 e6 08             	shl    $0x8,%esi
  80079c:	89 d0                	mov    %edx,%eax
  80079e:	c1 e0 18             	shl    $0x18,%eax
  8007a1:	89 d1                	mov    %edx,%ecx
  8007a3:	c1 e1 10             	shl    $0x10,%ecx
  8007a6:	09 c8                	or     %ecx,%eax
  8007a8:	09 c2                	or     %eax,%edx
  8007aa:	89 f0                	mov    %esi,%eax
  8007ac:	09 d0                	or     %edx,%eax
  8007ae:	89 d9                	mov    %ebx,%ecx
  8007b0:	c1 e9 02             	shr    $0x2,%ecx
  8007b3:	fc                   	cld    
  8007b4:	f3 ab                	rep stos %eax,%es:(%edi)
  8007b6:	eb 05                	jmp    8007bd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007b8:	89 d9                	mov    %ebx,%ecx
  8007ba:	fc                   	cld    
  8007bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8007bd:	89 f8                	mov    %edi,%eax
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5f                   	pop    %edi
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	57                   	push   %edi
  8007c8:	56                   	push   %esi
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8007cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8007d2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8007d4:	39 c6                	cmp    %eax,%esi
  8007d6:	73 36                	jae    80080e <memmove+0x4a>
  8007d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8007db:	39 d0                	cmp    %edx,%eax
  8007dd:	73 2f                	jae    80080e <memmove+0x4a>
		s += n;
		d += n;
  8007df:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8007e2:	f6 c2 03             	test   $0x3,%dl
  8007e5:	75 1b                	jne    800802 <memmove+0x3e>
  8007e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8007ed:	75 13                	jne    800802 <memmove+0x3e>
  8007ef:	f6 c1 03             	test   $0x3,%cl
  8007f2:	75 0e                	jne    800802 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8007f4:	8d 7e fc             	lea    -0x4(%esi),%edi
  8007f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8007fa:	c1 e9 02             	shr    $0x2,%ecx
  8007fd:	fd                   	std    
  8007fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800800:	eb 09                	jmp    80080b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800802:	8d 7e ff             	lea    -0x1(%esi),%edi
  800805:	8d 72 ff             	lea    -0x1(%edx),%esi
  800808:	fd                   	std    
  800809:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80080b:	fc                   	cld    
  80080c:	eb 20                	jmp    80082e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80080e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800814:	75 15                	jne    80082b <memmove+0x67>
  800816:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081c:	75 0d                	jne    80082b <memmove+0x67>
  80081e:	f6 c1 03             	test   $0x3,%cl
  800821:	75 08                	jne    80082b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800823:	c1 e9 02             	shr    $0x2,%ecx
  800826:	fc                   	cld    
  800827:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800829:	eb 03                	jmp    80082e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80082b:	fc                   	cld    
  80082c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80082e:	5e                   	pop    %esi
  80082f:	5f                   	pop    %edi
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800835:	ff 75 10             	pushl  0x10(%ebp)
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	ff 75 08             	pushl  0x8(%ebp)
  80083e:	e8 81 ff ff ff       	call   8007c4 <memmove>
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 04             	sub    $0x4,%esp
  80084c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80084f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	eb 1b                	jmp    800872 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800857:	8a 1a                	mov    (%edx),%bl
  800859:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80085c:	8a 19                	mov    (%ecx),%bl
  80085e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800861:	74 0d                	je     800870 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800863:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800867:	0f b6 c3             	movzbl %bl,%eax
  80086a:	29 c2                	sub    %eax,%edx
  80086c:	89 d0                	mov    %edx,%eax
  80086e:	eb 0d                	jmp    80087d <memcmp+0x38>
		s1++, s2++;
  800870:	42                   	inc    %edx
  800871:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800872:	48                   	dec    %eax
  800873:	83 f8 ff             	cmp    $0xffffffff,%eax
  800876:	75 df                	jne    800857 <memcmp+0x12>
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80087d:	83 c4 04             	add    $0x4,%esp
  800880:	5b                   	pop    %ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80088c:	89 c2                	mov    %eax,%edx
  80088e:	03 55 10             	add    0x10(%ebp),%edx
  800891:	eb 05                	jmp    800898 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800893:	38 08                	cmp    %cl,(%eax)
  800895:	74 05                	je     80089c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800897:	40                   	inc    %eax
  800898:	39 d0                	cmp    %edx,%eax
  80089a:	72 f7                	jb     800893 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	83 ec 04             	sub    $0x4,%esp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8008ad:	eb 01                	jmp    8008b0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008af:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008b0:	8a 01                	mov    (%ecx),%al
  8008b2:	3c 20                	cmp    $0x20,%al
  8008b4:	74 f9                	je     8008af <strtol+0x11>
  8008b6:	3c 09                	cmp    $0x9,%al
  8008b8:	74 f5                	je     8008af <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8008ba:	3c 2b                	cmp    $0x2b,%al
  8008bc:	75 0a                	jne    8008c8 <strtol+0x2a>
		s++;
  8008be:	41                   	inc    %ecx
  8008bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008c6:	eb 17                	jmp    8008df <strtol+0x41>
	else if (*s == '-')
  8008c8:	3c 2d                	cmp    $0x2d,%al
  8008ca:	74 09                	je     8008d5 <strtol+0x37>
  8008cc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008d3:	eb 0a                	jmp    8008df <strtol+0x41>
		s++, neg = 1;
  8008d5:	8d 49 01             	lea    0x1(%ecx),%ecx
  8008d8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8008df:	85 f6                	test   %esi,%esi
  8008e1:	74 05                	je     8008e8 <strtol+0x4a>
  8008e3:	83 fe 10             	cmp    $0x10,%esi
  8008e6:	75 1a                	jne    800902 <strtol+0x64>
  8008e8:	8a 01                	mov    (%ecx),%al
  8008ea:	3c 30                	cmp    $0x30,%al
  8008ec:	75 10                	jne    8008fe <strtol+0x60>
  8008ee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8008f2:	75 0a                	jne    8008fe <strtol+0x60>
		s += 2, base = 16;
  8008f4:	83 c1 02             	add    $0x2,%ecx
  8008f7:	be 10 00 00 00       	mov    $0x10,%esi
  8008fc:	eb 04                	jmp    800902 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8008fe:	85 f6                	test   %esi,%esi
  800900:	74 07                	je     800909 <strtol+0x6b>
  800902:	bf 00 00 00 00       	mov    $0x0,%edi
  800907:	eb 13                	jmp    80091c <strtol+0x7e>
  800909:	3c 30                	cmp    $0x30,%al
  80090b:	74 07                	je     800914 <strtol+0x76>
  80090d:	be 0a 00 00 00       	mov    $0xa,%esi
  800912:	eb ee                	jmp    800902 <strtol+0x64>
		s++, base = 8;
  800914:	41                   	inc    %ecx
  800915:	be 08 00 00 00       	mov    $0x8,%esi
  80091a:	eb e6                	jmp    800902 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80091c:	8a 11                	mov    (%ecx),%dl
  80091e:	88 d3                	mov    %dl,%bl
  800920:	8d 42 d0             	lea    -0x30(%edx),%eax
  800923:	3c 09                	cmp    $0x9,%al
  800925:	77 08                	ja     80092f <strtol+0x91>
			dig = *s - '0';
  800927:	0f be c2             	movsbl %dl,%eax
  80092a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80092d:	eb 1c                	jmp    80094b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80092f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800932:	3c 19                	cmp    $0x19,%al
  800934:	77 08                	ja     80093e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800936:	0f be c2             	movsbl %dl,%eax
  800939:	8d 50 a9             	lea    -0x57(%eax),%edx
  80093c:	eb 0d                	jmp    80094b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80093e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800941:	3c 19                	cmp    $0x19,%al
  800943:	77 15                	ja     80095a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800945:	0f be c2             	movsbl %dl,%eax
  800948:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80094b:	39 f2                	cmp    %esi,%edx
  80094d:	7d 0b                	jge    80095a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  80094f:	41                   	inc    %ecx
  800950:	89 f8                	mov    %edi,%eax
  800952:	0f af c6             	imul   %esi,%eax
  800955:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800958:	eb c2                	jmp    80091c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  80095a:	89 f8                	mov    %edi,%eax

	if (endptr)
  80095c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800960:	74 05                	je     800967 <strtol+0xc9>
		*endptr = (char *) s;
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80096b:	74 04                	je     800971 <strtol+0xd3>
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	f7 df                	neg    %edi
}
  800971:	89 f8                	mov    %edi,%eax
  800973:	83 c4 04             	add    $0x4,%esp
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	c9                   	leave  
  80097a:	c3                   	ret    
	...

0080097c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800982:	b8 01 00 00 00       	mov    $0x1,%eax
  800987:	bf 00 00 00 00       	mov    $0x0,%edi
  80098c:	89 fa                	mov    %edi,%edx
  80098e:	89 f9                	mov    %edi,%ecx
  800990:	89 fb                	mov    %edi,%ebx
  800992:	89 fe                	mov    %edi,%esi
  800994:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5f                   	pop    %edi
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009af:	89 f8                	mov    %edi,%eax
  8009b1:	89 fb                	mov    %edi,%ebx
  8009b3:	89 fe                	mov    %edi,%esi
  8009b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009b7:	83 c4 04             	add    $0x4,%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	83 ec 0c             	sub    $0xc,%esp
  8009c8:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009cb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d5:	89 f9                	mov    %edi,%ecx
  8009d7:	89 fb                	mov    %edi,%ebx
  8009d9:	89 fe                	mov    %edi,%esi
  8009db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	7e 17                	jle    8009f8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	50                   	push   %eax
  8009e5:	6a 0d                	push   $0xd
  8009e7:	68 7f 12 80 00       	push   $0x80127f
  8009ec:	6a 23                	push   $0x23
  8009ee:	68 9c 12 80 00       	push   $0x80129c
  8009f3:	e8 38 02 00 00       	call   800c30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8009f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 55 08             	mov    0x8(%ebp),%edx
  800a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a0f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a17:	be 00 00 00 00       	mov    $0x0,%esi
  800a1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	89 fb                	mov    %edi,%ebx
  800a3e:	89 fe                	mov    %edi,%esi
  800a40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a42:	85 c0                	test   %eax,%eax
  800a44:	7e 17                	jle    800a5d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a46:	83 ec 0c             	sub    $0xc,%esp
  800a49:	50                   	push   %eax
  800a4a:	6a 0a                	push   $0xa
  800a4c:	68 7f 12 80 00       	push   $0x80127f
  800a51:	6a 23                	push   $0x23
  800a53:	68 9c 12 80 00       	push   $0x80129c
  800a58:	e8 d3 01 00 00       	call   800c30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 0c             	sub    $0xc,%esp
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a74:	b8 09 00 00 00       	mov    $0x9,%eax
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	89 fb                	mov    %edi,%ebx
  800a80:	89 fe                	mov    %edi,%esi
  800a82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a84:	85 c0                	test   %eax,%eax
  800a86:	7e 17                	jle    800a9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	50                   	push   %eax
  800a8c:	6a 09                	push   $0x9
  800a8e:	68 7f 12 80 00       	push   $0x80127f
  800a93:	6a 23                	push   $0x23
  800a95:	68 9c 12 80 00       	push   $0x80129c
  800a9a:	e8 91 01 00 00       	call   800c30 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800a9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	b8 08 00 00 00       	mov    $0x8,%eax
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac0:	89 fb                	mov    %edi,%ebx
  800ac2:	89 fe                	mov    %edi,%esi
  800ac4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	7e 17                	jle    800ae1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aca:	83 ec 0c             	sub    $0xc,%esp
  800acd:	50                   	push   %eax
  800ace:	6a 08                	push   $0x8
  800ad0:	68 7f 12 80 00       	push   $0x80127f
  800ad5:	6a 23                	push   $0x23
  800ad7:	68 9c 12 80 00       	push   $0x80129c
  800adc:	e8 4f 01 00 00       	call   800c30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b8 06 00 00 00       	mov    $0x6,%eax
  800afd:	bf 00 00 00 00       	mov    $0x0,%edi
  800b02:	89 fb                	mov    %edi,%ebx
  800b04:	89 fe                	mov    %edi,%esi
  800b06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	7e 17                	jle    800b23 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	50                   	push   %eax
  800b10:	6a 06                	push   $0x6
  800b12:	68 7f 12 80 00       	push   $0x80127f
  800b17:	6a 23                	push   $0x23
  800b19:	68 9c 12 80 00       	push   $0x80129c
  800b1e:	e8 0d 01 00 00       	call   800c30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b40:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	b8 05 00 00 00       	mov    $0x5,%eax
  800b48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 05                	push   $0x5
  800b54:	68 7f 12 80 00       	push   $0x80127f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 9c 12 80 00       	push   $0x80129c
  800b60:	e8 cb 00 00 00       	call   800c30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
  800b89:	89 fe                	mov    %edi,%esi
  800b8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7e 17                	jle    800ba8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 04                	push   $0x4
  800b97:	68 7f 12 80 00       	push   $0x80127f
  800b9c:	6a 23                	push   $0x23
  800b9e:	68 9c 12 80 00       	push   $0x80129c
  800ba3:	e8 88 00 00 00       	call   800c30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc0:	89 fa                	mov    %edi,%edx
  800bc2:	89 f9                	mov    %edi,%ecx
  800bc4:	89 fb                	mov    %edi,%ebx
  800bc6:	89 fe                	mov    %edi,%esi
  800bc8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdf:	89 fa                	mov    %edi,%edx
  800be1:	89 f9                	mov    %edi,%ecx
  800be3:	89 fb                	mov    %edi,%ebx
  800be5:	89 fe                	mov    %edi,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfa:	b8 03 00 00 00       	mov    $0x3,%eax
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
  800c04:	89 f9                	mov    %edi,%ecx
  800c06:	89 fb                	mov    %edi,%ebx
  800c08:	89 fe                	mov    %edi,%esi
  800c0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7e 17                	jle    800c27 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	50                   	push   %eax
  800c14:	6a 03                	push   $0x3
  800c16:	68 7f 12 80 00       	push   $0x80127f
  800c1b:	6a 23                	push   $0x23
  800c1d:	68 9c 12 80 00       	push   $0x80129c
  800c22:	e8 09 00 00 00       	call   800c30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    
	...

00800c30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	53                   	push   %ebx
  800c34:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800c37:	8d 45 14             	lea    0x14(%ebp),%eax
  800c3a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c3d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c43:	e8 87 ff ff ff       	call   800bcf <sys_getenvid>
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	ff 75 0c             	pushl  0xc(%ebp)
  800c4e:	ff 75 08             	pushl  0x8(%ebp)
  800c51:	53                   	push   %ebx
  800c52:	50                   	push   %eax
  800c53:	68 ac 12 80 00       	push   $0x8012ac
  800c58:	e8 a8 f4 ff ff       	call   800105 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c5d:	83 c4 18             	add    $0x18,%esp
  800c60:	ff 75 f8             	pushl  -0x8(%ebp)
  800c63:	ff 75 10             	pushl  0x10(%ebp)
  800c66:	e8 49 f4 ff ff       	call   8000b4 <vcprintf>
	cprintf("\n");
  800c6b:	c7 04 24 d0 12 80 00 	movl   $0x8012d0,(%esp)
  800c72:	e8 8e f4 ff ff       	call   800105 <cprintf>
  800c77:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c7a:	cc                   	int3   
  800c7b:	eb fd                	jmp    800c7a <_panic+0x4a>
  800c7d:	00 00                	add    %al,(%eax)
	...

00800c80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	83 ec 28             	sub    $0x28,%esp
  800c88:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c8f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c96:	8b 45 10             	mov    0x10(%ebp),%eax
  800c99:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c9f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800ca1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cac:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800caf:	85 ff                	test   %edi,%edi
  800cb1:	75 21                	jne    800cd4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cb3:	39 d1                	cmp    %edx,%ecx
  800cb5:	76 49                	jbe    800d00 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cb7:	f7 f1                	div    %ecx
  800cb9:	89 c1                	mov    %eax,%ecx
  800cbb:	31 c0                	xor    %eax,%eax
  800cbd:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cc0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cc3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cc9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ccc:	83 c4 28             	add    $0x28,%esp
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    
  800cd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cd4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cd7:	0f 87 97 00 00 00    	ja     800d74 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cdd:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ce0:	83 f0 1f             	xor    $0x1f,%eax
  800ce3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ce6:	75 34                	jne    800d1c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ceb:	72 08                	jb     800cf5 <__udivdi3+0x75>
  800ced:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800cf0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800cf3:	77 7f                	ja     800d74 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cf5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cfa:	31 c0                	xor    %eax,%eax
  800cfc:	eb c2                	jmp    800cc0 <__udivdi3+0x40>
  800cfe:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d03:	85 c0                	test   %eax,%eax
  800d05:	74 79                	je     800d80 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d0a:	89 fa                	mov    %edi,%edx
  800d0c:	f7 f1                	div    %ecx
  800d0e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d13:	f7 f1                	div    %ecx
  800d15:	89 c1                	mov    %eax,%ecx
  800d17:	89 f0                	mov    %esi,%eax
  800d19:	eb a5                	jmp    800cc0 <__udivdi3+0x40>
  800d1b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d21:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d27:	89 fa                	mov    %edi,%edx
  800d29:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d2c:	d3 e2                	shl    %cl,%edx
  800d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d31:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d34:	d3 e8                	shr    %cl,%eax
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d3a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d3d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d40:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d42:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d45:	d3 e0                	shl    %cl,%eax
  800d47:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d4a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d4d:	d3 ea                	shr    %cl,%edx
  800d4f:	09 d0                	or     %edx,%eax
  800d51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d54:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	f7 f7                	div    %edi
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d60:	f7 e6                	mul    %esi
  800d62:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d64:	39 d7                	cmp    %edx,%edi
  800d66:	72 38                	jb     800da0 <__udivdi3+0x120>
  800d68:	74 27                	je     800d91 <__udivdi3+0x111>
  800d6a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d6d:	31 c0                	xor    %eax,%eax
  800d6f:	e9 4c ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d74:	31 c9                	xor    %ecx,%ecx
  800d76:	31 c0                	xor    %eax,%eax
  800d78:	e9 43 ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 75 f4             	divl   -0xc(%ebp)
  800d8a:	89 c1                	mov    %eax,%ecx
  800d8c:	e9 76 ff ff ff       	jmp    800d07 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d94:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d97:	d3 e0                	shl    %cl,%eax
  800d99:	39 f0                	cmp    %esi,%eax
  800d9b:	73 cd                	jae    800d6a <__udivdi3+0xea>
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800da0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800da3:	49                   	dec    %ecx
  800da4:	31 c0                	xor    %eax,%eax
  800da6:	e9 15 ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
	...

00800dac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	83 ec 30             	sub    $0x30,%esp
  800db4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dbb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dd3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dd6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dd9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ddc:	85 d2                	test   %edx,%edx
  800dde:	75 1c                	jne    800dfc <__umoddi3+0x50>
    {
      if (d0 > n1)
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	39 f8                	cmp    %edi,%eax
  800de4:	0f 86 c2 00 00 00    	jbe    800eac <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dee:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800df1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800df8:	eb 12                	jmp    800e0c <__umoddi3+0x60>
  800dfa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dfc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dff:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e02:	76 18                	jbe    800e1c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e04:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e07:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e0a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e0f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e12:	83 c4 30             	add    $0x30,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e1c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e20:	83 f0 1f             	xor    $0x1f,%eax
  800e23:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e26:	0f 84 ac 00 00 00    	je     800ed8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e37:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e3a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e3d:	d3 e2                	shl    %cl,%edx
  800e3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e42:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	89 d6                	mov    %edx,%esi
  800e49:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e4e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e51:	d3 e0                	shl    %cl,%eax
  800e53:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e56:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e59:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e5e:	d3 e0                	shl    %cl,%eax
  800e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e63:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e66:	d3 ea                	shr    %cl,%edx
  800e68:	09 d0                	or     %edx,%eax
  800e6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e6d:	d3 ea                	shr    %cl,%edx
  800e6f:	f7 f6                	div    %esi
  800e71:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e74:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e77:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e7a:	0f 82 8d 00 00 00    	jb     800f0d <__umoddi3+0x161>
  800e80:	0f 84 91 00 00 00    	je     800f17 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e86:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e89:	29 c7                	sub    %eax,%edi
  800e8b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e8d:	89 f2                	mov    %esi,%edx
  800e8f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e92:	d3 e2                	shl    %cl,%edx
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e99:	d3 e8                	shr    %cl,%eax
  800e9b:	09 c2                	or     %eax,%edx
  800e9d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800ea0:	d3 ee                	shr    %cl,%esi
  800ea2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ea5:	e9 62 ff ff ff       	jmp    800e0c <__umoddi3+0x60>
  800eaa:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	74 15                	je     800ec8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eb6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eb9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebe:	f7 f1                	div    %ecx
  800ec0:	e9 29 ff ff ff       	jmp    800dee <__umoddi3+0x42>
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	f7 75 ec             	divl   -0x14(%ebp)
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	eb dd                	jmp    800eb3 <__umoddi3+0x107>
  800ed6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800edb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ede:	72 19                	jb     800ef9 <__umoddi3+0x14d>
  800ee0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ee6:	76 11                	jbe    800ef9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eeb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800eee:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ef1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ef4:	e9 13 ff ff ff       	jmp    800e0c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eff:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f02:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f0b:	eb db                	jmp    800ee8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f0d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f10:	19 f2                	sbb    %esi,%edx
  800f12:	e9 6f ff ff ff       	jmp    800e86 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f17:	39 c7                	cmp    %eax,%edi
  800f19:	72 f2                	jb     800f0d <__umoddi3+0x161>
  800f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f1e:	e9 63 ff ff ff       	jmp    800e86 <__umoddi3+0xda>
