
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 53 00 00 00       	call   800084 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80003a:	68 53 00 80 00       	push   $0x800053
  80003f:	e8 20 0c 00 00       	call   800c64 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800044:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80004b:	00 00 00 
  80004e:	83 c4 10             	add    $0x10,%esp
}
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	83 ec 0c             	sub    $0xc,%esp
  800059:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80005c:	8b 50 04             	mov    0x4(%eax),%edx
  80005f:	83 e2 07             	and    $0x7,%edx
  800062:	52                   	push   %edx
  800063:	ff 30                	pushl  (%eax)
  800065:	68 00 10 80 00       	push   $0x801000
  80006a:	e8 ca 00 00 00       	call   800139 <cprintf>
	sys_env_destroy(sys_getenvid());
  80006f:	e8 8f 0b 00 00       	call   800c03 <sys_getenvid>
  800074:	89 04 24             	mov    %eax,(%esp)
  800077:	e8 a6 0b 00 00       	call   800c22 <sys_env_destroy>
  80007c:	83 c4 10             	add    $0x10,%esp
}
  80007f:	c9                   	leave  
  800080:	c3                   	ret    
  800081:	00 00                	add    %al,(%eax)
	...

00800084 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	8b 75 08             	mov    0x8(%ebp),%esi
  80008c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80008f:	e8 6f 0b 00 00       	call   800c03 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800094:	25 ff 03 00 00       	and    $0x3ff,%eax
  800099:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a0:	c1 e0 07             	shl    $0x7,%eax
  8000a3:	29 d0                	sub    %edx,%eax
  8000a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000aa:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 07                	jle    8000ba <libmain+0x36>
		binaryname = argv[0];
  8000b3:	8b 03                	mov    (%ebx),%eax
  8000b5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	56                   	push   %esi
  8000bf:	e8 70 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c4:	e8 0b 00 00 00       	call   8000d4 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
}
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	c9                   	leave  
  8000d2:	c3                   	ret    
	...

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 41 0b 00 00       	call   800c22 <sys_env_destroy>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
	...

008000e8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 50 01 80 00       	push   $0x800150
  800117:	e8 70 01 00 00       	call   80028c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800125:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 9e 08 00 00       	call   8009cf <sys_cputs>
  800131:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800142:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9a ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	53                   	push   %ebx
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800163:	40                   	inc    %eax
  800164:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800166:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016b:	75 1a                	jne    800187 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	68 ff 00 00 00       	push   $0xff
  800175:	8d 43 08             	lea    0x8(%ebx),%eax
  800178:	50                   	push   %eax
  800179:	e8 51 08 00 00       	call   8009cf <sys_cputs>
		b->idx = 0;
  80017e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800184:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800187:	ff 43 04             	incl   0x4(%ebx)
}
  80018a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 1c             	sub    $0x1c,%esp
  800199:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80019c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001ab:	8b 55 10             	mov    0x10(%ebp),%edx
  8001ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b1:	89 d6                	mov    %edx,%esi
  8001b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001b8:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001bb:	72 04                	jb     8001c1 <printnum+0x31>
  8001bd:	39 c2                	cmp    %eax,%edx
  8001bf:	77 3f                	ja     800200 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	ff 75 18             	pushl  0x18(%ebp)
  8001c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	52                   	push   %edx
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d7:	e8 80 0b 00 00       	call   800d5c <__udivdi3>
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	52                   	push   %edx
  8001e0:	50                   	push   %eax
  8001e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001e7:	e8 a4 ff ff ff       	call   800190 <printnum>
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	eb 14                	jmp    800205 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	ff 75 e8             	pushl  -0x18(%ebp)
  8001f7:	ff 75 18             	pushl  0x18(%ebp)
  8001fa:	ff 55 ec             	call   *-0x14(%ebp)
  8001fd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800200:	4b                   	dec    %ebx
  800201:	85 db                	test   %ebx,%ebx
  800203:	7f ec                	jg     8001f1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e8             	pushl  -0x18(%ebp)
  80020b:	83 ec 04             	sub    $0x4,%esp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	ff 75 e4             	pushl  -0x1c(%ebp)
  800213:	ff 75 e0             	pushl  -0x20(%ebp)
  800216:	e8 6d 0c 00 00       	call   800e88 <__umoddi3>
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	0f be 80 26 10 80 00 	movsbl 0x801026(%eax),%eax
  800225:	50                   	push   %eax
  800226:	ff 55 ec             	call   *-0x14(%ebp)
  800229:	83 c4 10             	add    $0x10,%esp
}
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 42 08             	lea    0x8(%edx),%eax
  800243:	89 01                	mov    %eax,(%ecx)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x3a>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 42 04             	lea    0x4(%edx),%eax
  800255:	89 01                	mov    %eax,(%ecx)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 42 04             	lea    0x4(%edx),%eax
  800265:	89 01                	mov    %eax,(%ecx)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800276:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800279:	8b 11                	mov    (%ecx),%edx
  80027b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1a>
		*b->buf++ = ch;
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	88 02                	mov    %al,(%edx)
  800285:	8d 42 01             	lea    0x1(%edx),%eax
  800288:	89 01                	mov    %eax,(%ecx)
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	8b 75 08             	mov    0x8(%ebp),%esi
  800298:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80029b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80029e:	eb 1a                	jmp    8002ba <vprintfmt+0x2e>
  8002a0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002a3:	eb 15                	jmp    8002ba <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a5:	84 c0                	test   %al,%al
  8002a7:	0f 84 15 03 00 00    	je     8005c2 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	57                   	push   %edi
  8002b1:	0f b6 c0             	movzbl %al,%eax
  8002b4:	50                   	push   %eax
  8002b5:	ff d6                	call   *%esi
  8002b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ba:	8a 03                	mov    (%ebx),%al
  8002bc:	43                   	inc    %ebx
  8002bd:	3c 25                	cmp    $0x25,%al
  8002bf:	75 e4                	jne    8002a5 <vprintfmt+0x19>
  8002c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002cf:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002dd:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002e1:	eb 0a                	jmp    8002ed <vprintfmt+0x61>
  8002e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8002ea:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8002ed:	8a 03                	mov    (%ebx),%al
  8002ef:	0f b6 d0             	movzbl %al,%edx
  8002f2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8002f5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8002f8:	83 e8 23             	sub    $0x23,%eax
  8002fb:	3c 55                	cmp    $0x55,%al
  8002fd:	0f 87 9c 02 00 00    	ja     80059f <vprintfmt+0x313>
  800303:	0f b6 c0             	movzbl %al,%eax
  800306:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  80030d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800311:	eb d7                	jmp    8002ea <vprintfmt+0x5e>
  800313:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800317:	eb d1                	jmp    8002ea <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800319:	89 d9                	mov    %ebx,%ecx
  80031b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800322:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800325:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800328:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80032c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80032f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800333:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800334:	8d 42 d0             	lea    -0x30(%edx),%eax
  800337:	83 f8 09             	cmp    $0x9,%eax
  80033a:	77 21                	ja     80035d <vprintfmt+0xd1>
  80033c:	eb e4                	jmp    800322 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80033e:	8b 55 14             	mov    0x14(%ebp),%edx
  800341:	8d 42 04             	lea    0x4(%edx),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
  800347:	8b 12                	mov    (%edx),%edx
  800349:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80034c:	eb 12                	jmp    800360 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80034e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800352:	79 96                	jns    8002ea <vprintfmt+0x5e>
  800354:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035b:	eb 8d                	jmp    8002ea <vprintfmt+0x5e>
  80035d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800360:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800364:	79 84                	jns    8002ea <vprintfmt+0x5e>
  800366:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800369:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800373:	e9 72 ff ff ff       	jmp    8002ea <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800378:	ff 45 d4             	incl   -0x2c(%ebp)
  80037b:	e9 6a ff ff ff       	jmp    8002ea <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800380:	8b 55 14             	mov    0x14(%ebp),%edx
  800383:	8d 42 04             	lea    0x4(%edx),%eax
  800386:	89 45 14             	mov    %eax,0x14(%ebp)
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	57                   	push   %edi
  80038d:	ff 32                	pushl  (%edx)
  80038f:	ff d6                	call   *%esi
			break;
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	e9 07 ff ff ff       	jmp    8002a0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 42 04             	lea    0x4(%edx),%eax
  80039f:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	85 c0                	test   %eax,%eax
  8003a6:	79 02                	jns    8003aa <vprintfmt+0x11e>
  8003a8:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 0b                	jg     8003ba <vprintfmt+0x12e>
  8003af:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 15                	jne    8003cf <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 37 10 80 00       	push   $0x801037
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	e8 6e 02 00 00       	call   800635 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	e9 d1 fe ff ff       	jmp    8002a0 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003cf:	52                   	push   %edx
  8003d0:	68 40 10 80 00       	push   $0x801040
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	e8 59 02 00 00       	call   800635 <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 bc fe ff ff       	jmp    8002a0 <vprintfmt+0x14>
  8003e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003e7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ed:	8b 55 14             	mov    0x14(%ebp),%edx
  8003f0:	8d 42 04             	lea    0x4(%edx),%eax
  8003f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8003f6:	8b 1a                	mov    (%edx),%ebx
  8003f8:	85 db                	test   %ebx,%ebx
  8003fa:	75 05                	jne    800401 <vprintfmt+0x175>
  8003fc:	bb 43 10 80 00       	mov    $0x801043,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800401:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800405:	7e 66                	jle    80046d <vprintfmt+0x1e1>
  800407:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80040b:	74 60                	je     80046d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	51                   	push   %ecx
  800411:	53                   	push   %ebx
  800412:	e8 57 02 00 00       	call   80066e <strnlen>
  800417:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80041a:	29 c1                	sub    %eax,%ecx
  80041c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800426:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800429:	eb 0f                	jmp    80043a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	57                   	push   %edi
  80042f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800432:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800434:	ff 4d d8             	decl   -0x28(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80043e:	7f eb                	jg     80042b <vprintfmt+0x19f>
  800440:	eb 2b                	jmp    80046d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800442:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	74 15                	je     800460 <vprintfmt+0x1d4>
  80044b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80044e:	83 f8 5e             	cmp    $0x5e,%eax
  800451:	76 0d                	jbe    800460 <vprintfmt+0x1d4>
					putch('?', putdat);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	57                   	push   %edi
  800457:	6a 3f                	push   $0x3f
  800459:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	eb 0a                	jmp    80046a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	57                   	push   %edi
  800464:	52                   	push   %edx
  800465:	ff d6                	call   *%esi
  800467:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046a:	ff 4d d8             	decl   -0x28(%ebp)
  80046d:	8a 03                	mov    (%ebx),%al
  80046f:	43                   	inc    %ebx
  800470:	84 c0                	test   %al,%al
  800472:	74 1b                	je     80048f <vprintfmt+0x203>
  800474:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800478:	78 c8                	js     800442 <vprintfmt+0x1b6>
  80047a:	ff 4d dc             	decl   -0x24(%ebp)
  80047d:	79 c3                	jns    800442 <vprintfmt+0x1b6>
  80047f:	eb 0e                	jmp    80048f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	57                   	push   %edi
  800485:	6a 20                	push   $0x20
  800487:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800489:	ff 4d d8             	decl   -0x28(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800493:	7f ec                	jg     800481 <vprintfmt+0x1f5>
  800495:	e9 06 fe ff ff       	jmp    8002a0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80049a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80049e:	7e 10                	jle    8004b0 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8004a3:	8d 42 08             	lea    0x8(%edx),%eax
  8004a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	8b 52 04             	mov    0x4(%edx),%edx
  8004ae:	eb 20                	jmp    8004d0 <vprintfmt+0x244>
	else if (lflag)
  8004b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b4:	74 0e                	je     8004c4 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	99                   	cltd   
  8004c2:	eb 0c                	jmp    8004d0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004d0:	89 d1                	mov    %edx,%ecx
  8004d2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004da:	85 c9                	test   %ecx,%ecx
  8004dc:	78 0a                	js     8004e8 <vprintfmt+0x25c>
  8004de:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004e3:	e9 89 00 00 00       	jmp    800571 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	57                   	push   %edi
  8004ec:	6a 2d                	push   $0x2d
  8004ee:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f6:	f7 da                	neg    %edx
  8004f8:	83 d1 00             	adc    $0x0,%ecx
  8004fb:	f7 d9                	neg    %ecx
  8004fd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb 6a                	jmp    800571 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800507:	8d 45 14             	lea    0x14(%ebp),%eax
  80050a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80050d:	e8 22 fd ff ff       	call   800234 <getuint>
  800512:	89 d1                	mov    %edx,%ecx
  800514:	89 c2                	mov    %eax,%edx
  800516:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80051b:	eb 54                	jmp    800571 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
  800520:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800523:	e8 0c fd ff ff       	call   800234 <getuint>
  800528:	89 d1                	mov    %edx,%ecx
  80052a:	89 c2                	mov    %eax,%edx
  80052c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800531:	eb 3e                	jmp    800571 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	57                   	push   %edi
  800537:	6a 30                	push   $0x30
  800539:	ff d6                	call   *%esi
			putch('x', putdat);
  80053b:	83 c4 08             	add    $0x8,%esp
  80053e:	57                   	push   %edi
  80053f:	6a 78                	push   $0x78
  800541:	ff d6                	call   *%esi
			num = (unsigned long long)
  800543:	8b 55 14             	mov    0x14(%ebp),%edx
  800546:	8d 42 04             	lea    0x4(%edx),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	8b 12                	mov    (%edx),%edx
  80054e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800553:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	eb 14                	jmp    800571 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80055d:	8d 45 14             	lea    0x14(%ebp),%eax
  800560:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800563:	e8 cc fc ff ff       	call   800234 <getuint>
  800568:	89 d1                	mov    %edx,%ecx
  80056a:	89 c2                	mov    %eax,%edx
  80056c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800578:	50                   	push   %eax
  800579:	ff 75 d8             	pushl  -0x28(%ebp)
  80057c:	53                   	push   %ebx
  80057d:	51                   	push   %ecx
  80057e:	52                   	push   %edx
  80057f:	89 fa                	mov    %edi,%edx
  800581:	89 f0                	mov    %esi,%eax
  800583:	e8 08 fc ff ff       	call   800190 <printnum>
			break;
  800588:	83 c4 20             	add    $0x20,%esp
  80058b:	e9 10 fd ff ff       	jmp    8002a0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	57                   	push   %edi
  800594:	52                   	push   %edx
  800595:	ff d6                	call   *%esi
			break;
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	e9 01 fd ff ff       	jmp    8002a0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	57                   	push   %edi
  8005a3:	6a 25                	push   $0x25
  8005a5:	ff d6                	call   *%esi
  8005a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005aa:	83 ea 02             	sub    $0x2,%edx
  8005ad:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005b0:	8a 02                	mov    (%edx),%al
  8005b2:	4a                   	dec    %edx
  8005b3:	3c 25                	cmp    $0x25,%al
  8005b5:	75 f9                	jne    8005b0 <vprintfmt+0x324>
  8005b7:	83 c2 02             	add    $0x2,%edx
  8005ba:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005bd:	e9 de fc ff ff       	jmp    8002a0 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c5:	5b                   	pop    %ebx
  8005c6:	5e                   	pop    %esi
  8005c7:	5f                   	pop    %edi
  8005c8:	c9                   	leave  
  8005c9:	c3                   	ret    

008005ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
  8005d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 37                	je     800611 <vsnprintf+0x47>
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	7e 33                	jle    800611 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005e5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8005e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8005ec:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8005ef:	ff 75 14             	pushl  0x14(%ebp)
  8005f2:	ff 75 10             	pushl  0x10(%ebp)
  8005f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005f8:	50                   	push   %eax
  8005f9:	68 70 02 80 00       	push   $0x800270
  8005fe:	e8 89 fc ff ff       	call   80028c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800606:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800609:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	eb 05                	jmp    800616 <vsnprintf+0x4c>
  800611:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800616:	c9                   	leave  
  800617:	c3                   	ret    

00800618 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800624:	50                   	push   %eax
  800625:	ff 75 10             	pushl  0x10(%ebp)
  800628:	ff 75 0c             	pushl  0xc(%ebp)
  80062b:	ff 75 08             	pushl  0x8(%ebp)
  80062e:	e8 97 ff ff ff       	call   8005ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800633:	c9                   	leave  
  800634:	c3                   	ret    

00800635 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800641:	50                   	push   %eax
  800642:	ff 75 10             	pushl  0x10(%ebp)
  800645:	ff 75 0c             	pushl  0xc(%ebp)
  800648:	ff 75 08             	pushl  0x8(%ebp)
  80064b:	e8 3c fc ff ff       	call   80028c <vprintfmt>
	va_end(ap);
  800650:	83 c4 10             	add    $0x10,%esp
}
  800653:	c9                   	leave  
  800654:	c3                   	ret    
  800655:	00 00                	add    %al,(%eax)
	...

00800658 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
  80065b:	8b 55 08             	mov    0x8(%ebp),%edx
  80065e:	b8 00 00 00 00       	mov    $0x0,%eax
  800663:	eb 01                	jmp    800666 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800665:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800666:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80066a:	75 f9                	jne    800665 <strlen+0xd>
		n++;
	return n;
}
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800674:	8b 55 0c             	mov    0xc(%ebp),%edx
  800677:	b8 00 00 00 00       	mov    $0x0,%eax
  80067c:	eb 01                	jmp    80067f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80067e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80067f:	39 d0                	cmp    %edx,%eax
  800681:	74 06                	je     800689 <strnlen+0x1b>
  800683:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800687:	75 f5                	jne    80067e <strnlen+0x10>
		n++;
	return n;
}
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800691:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800694:	8a 01                	mov    (%ecx),%al
  800696:	88 02                	mov    %al,(%edx)
  800698:	42                   	inc    %edx
  800699:	41                   	inc    %ecx
  80069a:	84 c0                	test   %al,%al
  80069c:	75 f6                	jne    800694 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	53                   	push   %ebx
  8006a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006aa:	53                   	push   %ebx
  8006ab:	e8 a8 ff ff ff       	call   800658 <strlen>
	strcpy(dst + len, src);
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006b6:	50                   	push   %eax
  8006b7:	e8 cf ff ff ff       	call   80068b <strcpy>
	return dst;
}
  8006bc:	89 d8                	mov    %ebx,%eax
  8006be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	eb 0c                	jmp    8006e4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006d8:	8a 02                	mov    (%edx),%al
  8006da:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8006e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006e3:	41                   	inc    %ecx
  8006e4:	39 d9                	cmp    %ebx,%ecx
  8006e6:	75 f0                	jne    8006d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8006e8:	89 f0                	mov    %esi,%eax
  8006ea:	5b                   	pop    %ebx
  8006eb:	5e                   	pop    %esi
  8006ec:	c9                   	leave  
  8006ed:	c3                   	ret    

008006ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	56                   	push   %esi
  8006f2:	53                   	push   %ebx
  8006f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	75 04                	jne    800704 <strlcpy+0x16>
  800700:	89 f0                	mov    %esi,%eax
  800702:	eb 14                	jmp    800718 <strlcpy+0x2a>
  800704:	89 f0                	mov    %esi,%eax
  800706:	eb 04                	jmp    80070c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800708:	88 10                	mov    %dl,(%eax)
  80070a:	40                   	inc    %eax
  80070b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80070c:	49                   	dec    %ecx
  80070d:	74 06                	je     800715 <strlcpy+0x27>
  80070f:	8a 13                	mov    (%ebx),%dl
  800711:	84 d2                	test   %dl,%dl
  800713:	75 f3                	jne    800708 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800715:	c6 00 00             	movb   $0x0,(%eax)
  800718:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
  800724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800727:	eb 02                	jmp    80072b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800729:	42                   	inc    %edx
  80072a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80072b:	8a 02                	mov    (%edx),%al
  80072d:	84 c0                	test   %al,%al
  80072f:	74 04                	je     800735 <strcmp+0x17>
  800731:	3a 01                	cmp    (%ecx),%al
  800733:	74 f4                	je     800729 <strcmp+0xb>
  800735:	0f b6 c0             	movzbl %al,%eax
  800738:	0f b6 11             	movzbl (%ecx),%edx
  80073b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800749:	8b 55 10             	mov    0x10(%ebp),%edx
  80074c:	eb 03                	jmp    800751 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80074e:	4a                   	dec    %edx
  80074f:	41                   	inc    %ecx
  800750:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800751:	85 d2                	test   %edx,%edx
  800753:	75 07                	jne    80075c <strncmp+0x1d>
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	eb 14                	jmp    800770 <strncmp+0x31>
  80075c:	8a 01                	mov    (%ecx),%al
  80075e:	84 c0                	test   %al,%al
  800760:	74 04                	je     800766 <strncmp+0x27>
  800762:	3a 03                	cmp    (%ebx),%al
  800764:	74 e8                	je     80074e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800766:	0f b6 d0             	movzbl %al,%edx
  800769:	0f b6 03             	movzbl (%ebx),%eax
  80076c:	29 c2                	sub    %eax,%edx
  80076e:	89 d0                	mov    %edx,%eax
}
  800770:	5b                   	pop    %ebx
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80077c:	eb 05                	jmp    800783 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80077e:	38 ca                	cmp    %cl,%dl
  800780:	74 0c                	je     80078e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800782:	40                   	inc    %eax
  800783:	8a 10                	mov    (%eax),%dl
  800785:	84 d2                	test   %dl,%dl
  800787:	75 f5                	jne    80077e <strchr+0xb>
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800799:	eb 05                	jmp    8007a0 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80079b:	38 ca                	cmp    %cl,%dl
  80079d:	74 07                	je     8007a6 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80079f:	40                   	inc    %eax
  8007a0:	8a 10                	mov    (%eax),%dl
  8007a2:	84 d2                	test   %dl,%dl
  8007a4:	75 f5                	jne    80079b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	57                   	push   %edi
  8007ac:	56                   	push   %esi
  8007ad:	53                   	push   %ebx
  8007ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007b7:	85 db                	test   %ebx,%ebx
  8007b9:	74 36                	je     8007f1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007c1:	75 29                	jne    8007ec <memset+0x44>
  8007c3:	f6 c3 03             	test   $0x3,%bl
  8007c6:	75 24                	jne    8007ec <memset+0x44>
		c &= 0xFF;
  8007c8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007cb:	89 d6                	mov    %edx,%esi
  8007cd:	c1 e6 08             	shl    $0x8,%esi
  8007d0:	89 d0                	mov    %edx,%eax
  8007d2:	c1 e0 18             	shl    $0x18,%eax
  8007d5:	89 d1                	mov    %edx,%ecx
  8007d7:	c1 e1 10             	shl    $0x10,%ecx
  8007da:	09 c8                	or     %ecx,%eax
  8007dc:	09 c2                	or     %eax,%edx
  8007de:	89 f0                	mov    %esi,%eax
  8007e0:	09 d0                	or     %edx,%eax
  8007e2:	89 d9                	mov    %ebx,%ecx
  8007e4:	c1 e9 02             	shr    $0x2,%ecx
  8007e7:	fc                   	cld    
  8007e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8007ea:	eb 05                	jmp    8007f1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8007ec:	89 d9                	mov    %ebx,%ecx
  8007ee:	fc                   	cld    
  8007ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8007f1:	89 f8                	mov    %edi,%eax
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	57                   	push   %edi
  8007fc:	56                   	push   %esi
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800803:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800806:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800808:	39 c6                	cmp    %eax,%esi
  80080a:	73 36                	jae    800842 <memmove+0x4a>
  80080c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	73 2f                	jae    800842 <memmove+0x4a>
		s += n;
		d += n;
  800813:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800816:	f6 c2 03             	test   $0x3,%dl
  800819:	75 1b                	jne    800836 <memmove+0x3e>
  80081b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800821:	75 13                	jne    800836 <memmove+0x3e>
  800823:	f6 c1 03             	test   $0x3,%cl
  800826:	75 0e                	jne    800836 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800828:	8d 7e fc             	lea    -0x4(%esi),%edi
  80082b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80082e:	c1 e9 02             	shr    $0x2,%ecx
  800831:	fd                   	std    
  800832:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800834:	eb 09                	jmp    80083f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800836:	8d 7e ff             	lea    -0x1(%esi),%edi
  800839:	8d 72 ff             	lea    -0x1(%edx),%esi
  80083c:	fd                   	std    
  80083d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80083f:	fc                   	cld    
  800840:	eb 20                	jmp    800862 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800842:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800848:	75 15                	jne    80085f <memmove+0x67>
  80084a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800850:	75 0d                	jne    80085f <memmove+0x67>
  800852:	f6 c1 03             	test   $0x3,%cl
  800855:	75 08                	jne    80085f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800857:	c1 e9 02             	shr    $0x2,%ecx
  80085a:	fc                   	cld    
  80085b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80085d:	eb 03                	jmp    800862 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80085f:	fc                   	cld    
  800860:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800862:	5e                   	pop    %esi
  800863:	5f                   	pop    %edi
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800869:	ff 75 10             	pushl  0x10(%ebp)
  80086c:	ff 75 0c             	pushl  0xc(%ebp)
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 81 ff ff ff       	call   8007f8 <memmove>
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 04             	sub    $0x4,%esp
  800880:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	eb 1b                	jmp    8008a6 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80088b:	8a 1a                	mov    (%edx),%bl
  80088d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800890:	8a 19                	mov    (%ecx),%bl
  800892:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800895:	74 0d                	je     8008a4 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800897:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80089b:	0f b6 c3             	movzbl %bl,%eax
  80089e:	29 c2                	sub    %eax,%edx
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	eb 0d                	jmp    8008b1 <memcmp+0x38>
		s1++, s2++;
  8008a4:	42                   	inc    %edx
  8008a5:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008a6:	48                   	dec    %eax
  8008a7:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008aa:	75 df                	jne    80088b <memcmp+0x12>
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008b1:	83 c4 04             	add    $0x4,%esp
  8008b4:	5b                   	pop    %ebx
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	03 55 10             	add    0x10(%ebp),%edx
  8008c5:	eb 05                	jmp    8008cc <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008c7:	38 08                	cmp    %cl,(%eax)
  8008c9:	74 05                	je     8008d0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008cb:	40                   	inc    %eax
  8008cc:	39 d0                	cmp    %edx,%eax
  8008ce:	72 f7                	jb     8008c7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	57                   	push   %edi
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	83 ec 04             	sub    $0x4,%esp
  8008db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008de:	8b 75 10             	mov    0x10(%ebp),%esi
  8008e1:	eb 01                	jmp    8008e4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008e3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008e4:	8a 01                	mov    (%ecx),%al
  8008e6:	3c 20                	cmp    $0x20,%al
  8008e8:	74 f9                	je     8008e3 <strtol+0x11>
  8008ea:	3c 09                	cmp    $0x9,%al
  8008ec:	74 f5                	je     8008e3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8008ee:	3c 2b                	cmp    $0x2b,%al
  8008f0:	75 0a                	jne    8008fc <strtol+0x2a>
		s++;
  8008f2:	41                   	inc    %ecx
  8008f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8008fa:	eb 17                	jmp    800913 <strtol+0x41>
	else if (*s == '-')
  8008fc:	3c 2d                	cmp    $0x2d,%al
  8008fe:	74 09                	je     800909 <strtol+0x37>
  800900:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800907:	eb 0a                	jmp    800913 <strtol+0x41>
		s++, neg = 1;
  800909:	8d 49 01             	lea    0x1(%ecx),%ecx
  80090c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800913:	85 f6                	test   %esi,%esi
  800915:	74 05                	je     80091c <strtol+0x4a>
  800917:	83 fe 10             	cmp    $0x10,%esi
  80091a:	75 1a                	jne    800936 <strtol+0x64>
  80091c:	8a 01                	mov    (%ecx),%al
  80091e:	3c 30                	cmp    $0x30,%al
  800920:	75 10                	jne    800932 <strtol+0x60>
  800922:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800926:	75 0a                	jne    800932 <strtol+0x60>
		s += 2, base = 16;
  800928:	83 c1 02             	add    $0x2,%ecx
  80092b:	be 10 00 00 00       	mov    $0x10,%esi
  800930:	eb 04                	jmp    800936 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800932:	85 f6                	test   %esi,%esi
  800934:	74 07                	je     80093d <strtol+0x6b>
  800936:	bf 00 00 00 00       	mov    $0x0,%edi
  80093b:	eb 13                	jmp    800950 <strtol+0x7e>
  80093d:	3c 30                	cmp    $0x30,%al
  80093f:	74 07                	je     800948 <strtol+0x76>
  800941:	be 0a 00 00 00       	mov    $0xa,%esi
  800946:	eb ee                	jmp    800936 <strtol+0x64>
		s++, base = 8;
  800948:	41                   	inc    %ecx
  800949:	be 08 00 00 00       	mov    $0x8,%esi
  80094e:	eb e6                	jmp    800936 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800950:	8a 11                	mov    (%ecx),%dl
  800952:	88 d3                	mov    %dl,%bl
  800954:	8d 42 d0             	lea    -0x30(%edx),%eax
  800957:	3c 09                	cmp    $0x9,%al
  800959:	77 08                	ja     800963 <strtol+0x91>
			dig = *s - '0';
  80095b:	0f be c2             	movsbl %dl,%eax
  80095e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800961:	eb 1c                	jmp    80097f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800963:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800966:	3c 19                	cmp    $0x19,%al
  800968:	77 08                	ja     800972 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80096a:	0f be c2             	movsbl %dl,%eax
  80096d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800970:	eb 0d                	jmp    80097f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800972:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800975:	3c 19                	cmp    $0x19,%al
  800977:	77 15                	ja     80098e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800979:	0f be c2             	movsbl %dl,%eax
  80097c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80097f:	39 f2                	cmp    %esi,%edx
  800981:	7d 0b                	jge    80098e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800983:	41                   	inc    %ecx
  800984:	89 f8                	mov    %edi,%eax
  800986:	0f af c6             	imul   %esi,%eax
  800989:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  80098c:	eb c2                	jmp    800950 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  80098e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800990:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800994:	74 05                	je     80099b <strtol+0xc9>
		*endptr = (char *) s;
  800996:	8b 55 0c             	mov    0xc(%ebp),%edx
  800999:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  80099b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80099f:	74 04                	je     8009a5 <strtol+0xd3>
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	f7 df                	neg    %edi
}
  8009a5:	89 f8                	mov    %edi,%eax
  8009a7:	83 c4 04             	add    $0x4,%esp
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    
	...

008009b0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	57                   	push   %edi
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c0:	89 fa                	mov    %edi,%edx
  8009c2:	89 f9                	mov    %edi,%ecx
  8009c4:	89 fb                	mov    %edi,%ebx
  8009c6:	89 fe                	mov    %edi,%esi
  8009c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 04             	sub    $0x4,%esp
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009de:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	89 fb                	mov    %edi,%ebx
  8009e7:	89 fe                	mov    %edi,%esi
  8009e9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8009eb:	83 c4 04             	add    $0x4,%esp
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
  800a09:	89 f9                	mov    %edi,%ecx
  800a0b:	89 fb                	mov    %edi,%ebx
  800a0d:	89 fe                	mov    %edi,%esi
  800a0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a11:	85 c0                	test   %eax,%eax
  800a13:	7e 17                	jle    800a2c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a15:	83 ec 0c             	sub    $0xc,%esp
  800a18:	50                   	push   %eax
  800a19:	6a 0d                	push   $0xd
  800a1b:	68 1f 13 80 00       	push   $0x80131f
  800a20:	6a 23                	push   $0x23
  800a22:	68 3c 13 80 00       	push   $0x80133c
  800a27:	e8 e0 02 00 00       	call   800d0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a43:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a4b:	be 00 00 00 00       	mov    $0x0,%esi
  800a50:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a70:	89 fb                	mov    %edi,%ebx
  800a72:	89 fe                	mov    %edi,%esi
  800a74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a76:	85 c0                	test   %eax,%eax
  800a78:	7e 17                	jle    800a91 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a7a:	83 ec 0c             	sub    $0xc,%esp
  800a7d:	50                   	push   %eax
  800a7e:	6a 0a                	push   $0xa
  800a80:	68 1f 13 80 00       	push   $0x80131f
  800a85:	6a 23                	push   $0x23
  800a87:	68 3c 13 80 00       	push   $0x80133c
  800a8c:	e8 7b 02 00 00       	call   800d0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800a91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    

00800a99 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 0c             	sub    $0xc,%esp
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa8:	b8 09 00 00 00       	mov    $0x9,%eax
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab2:	89 fb                	mov    %edi,%ebx
  800ab4:	89 fe                	mov    %edi,%esi
  800ab6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7e 17                	jle    800ad3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	50                   	push   %eax
  800ac0:	6a 09                	push   $0x9
  800ac2:	68 1f 13 80 00       	push   $0x80131f
  800ac7:	6a 23                	push   $0x23
  800ac9:	68 3c 13 80 00       	push   $0x80133c
  800ace:	e8 39 02 00 00       	call   800d0c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 08 00 00 00       	mov    $0x8,%eax
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	89 fb                	mov    %edi,%ebx
  800af6:	89 fe                	mov    %edi,%esi
  800af8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	7e 17                	jle    800b15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	50                   	push   %eax
  800b02:	6a 08                	push   $0x8
  800b04:	68 1f 13 80 00       	push   $0x80131f
  800b09:	6a 23                	push   $0x23
  800b0b:	68 3c 13 80 00       	push   $0x80133c
  800b10:	e8 f7 01 00 00       	call   800d0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b31:	bf 00 00 00 00       	mov    $0x0,%edi
  800b36:	89 fb                	mov    %edi,%ebx
  800b38:	89 fe                	mov    %edi,%esi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 06                	push   $0x6
  800b46:	68 1f 13 80 00       	push   $0x80131f
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 3c 13 80 00       	push   $0x80133c
  800b52:	e8 b5 01 00 00       	call   800d0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b74:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 05                	push   $0x5
  800b88:	68 1f 13 80 00       	push   $0x80131f
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 3c 13 80 00       	push   $0x80133c
  800b94:	e8 73 01 00 00       	call   800d0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbd:	89 fe                	mov    %edi,%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 04                	push   $0x4
  800bcb:	68 1f 13 80 00       	push   $0x80131f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 3c 13 80 00       	push   $0x80133c
  800bd7:	e8 30 01 00 00       	call   800d0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf4:	89 fa                	mov    %edi,%edx
  800bf6:	89 f9                	mov    %edi,%ecx
  800bf8:	89 fb                	mov    %edi,%ebx
  800bfa:	89 fe                	mov    %edi,%esi
  800bfc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	89 fa                	mov    %edi,%edx
  800c15:	89 f9                	mov    %edi,%ecx
  800c17:	89 fb                	mov    %edi,%ebx
  800c19:	89 fe                	mov    %edi,%esi
  800c1b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c33:	bf 00 00 00 00       	mov    $0x0,%edi
  800c38:	89 f9                	mov    %edi,%ecx
  800c3a:	89 fb                	mov    %edi,%ebx
  800c3c:	89 fe                	mov    %edi,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 03                	push   $0x3
  800c4a:	68 1f 13 80 00       	push   $0x80131f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 3c 13 80 00       	push   $0x80133c
  800c56:	e8 b1 00 00 00       	call   800d0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    
	...

00800c64 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800c6a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800c71:	75 64                	jne    800cd7 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800c73:	a1 04 20 80 00       	mov    0x802004,%eax
  800c78:	8b 40 48             	mov    0x48(%eax),%eax
  800c7b:	83 ec 04             	sub    $0x4,%esp
  800c7e:	6a 07                	push   $0x7
  800c80:	68 00 f0 bf ee       	push   $0xeebff000
  800c85:	50                   	push   %eax
  800c86:	e8 16 ff ff ff       	call   800ba1 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	79 14                	jns    800ca6 <set_pgfault_handler+0x42>
  800c92:	83 ec 04             	sub    $0x4,%esp
  800c95:	68 4c 13 80 00       	push   $0x80134c
  800c9a:	6a 22                	push   $0x22
  800c9c:	68 b5 13 80 00       	push   $0x8013b5
  800ca1:	e8 66 00 00 00       	call   800d0c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800ca6:	a1 04 20 80 00       	mov    0x802004,%eax
  800cab:	8b 40 48             	mov    0x48(%eax),%eax
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	68 e4 0c 80 00       	push   $0x800ce4
  800cb6:	50                   	push   %eax
  800cb7:	e8 9b fd ff ff       	call   800a57 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	79 14                	jns    800cd7 <set_pgfault_handler+0x73>
  800cc3:	83 ec 04             	sub    $0x4,%esp
  800cc6:	68 7c 13 80 00       	push   $0x80137c
  800ccb:	6a 25                	push   $0x25
  800ccd:	68 b5 13 80 00       	push   $0x8013b5
  800cd2:	e8 35 00 00 00       	call   800d0c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    
  800ce1:	00 00                	add    %al,(%eax)
	...

00800ce4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ce4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800ce5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800cea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800cec:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  800cef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800cf3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800cf6:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  800cfa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  800cfe:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  800d00:	83 c4 08             	add    $0x8,%esp
	popal
  800d03:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800d04:	83 c4 04             	add    $0x4,%esp
	popfl
  800d07:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d08:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  800d09:	c3                   	ret    
	...

00800d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800d13:	8d 45 14             	lea    0x14(%ebp),%eax
  800d16:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d19:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d1f:	e8 df fe ff ff       	call   800c03 <sys_getenvid>
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	ff 75 0c             	pushl  0xc(%ebp)
  800d2a:	ff 75 08             	pushl  0x8(%ebp)
  800d2d:	53                   	push   %ebx
  800d2e:	50                   	push   %eax
  800d2f:	68 c4 13 80 00       	push   $0x8013c4
  800d34:	e8 00 f4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d39:	83 c4 18             	add    $0x18,%esp
  800d3c:	ff 75 f8             	pushl  -0x8(%ebp)
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	e8 a1 f3 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800d47:	c7 04 24 1a 10 80 00 	movl   $0x80101a,(%esp)
  800d4e:	e8 e6 f3 ff ff       	call   800139 <cprintf>
  800d53:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d56:	cc                   	int3   
  800d57:	eb fd                	jmp    800d56 <_panic+0x4a>
  800d59:	00 00                	add    %al,(%eax)
	...

00800d5c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	83 ec 28             	sub    $0x28,%esp
  800d64:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800d6b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d72:	8b 45 10             	mov    0x10(%ebp),%eax
  800d75:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d7b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800d7d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800d85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d88:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	75 21                	jne    800db0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800d8f:	39 d1                	cmp    %edx,%ecx
  800d91:	76 49                	jbe    800ddc <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c1                	mov    %eax,%ecx
  800d97:	31 c0                	xor    %eax,%eax
  800d99:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d9c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800da5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800da8:	83 c4 28             	add    $0x28,%esp
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    
  800daf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800db0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800db3:	0f 87 97 00 00 00    	ja     800e50 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800db9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800dbc:	83 f0 1f             	xor    $0x1f,%eax
  800dbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800dc2:	75 34                	jne    800df8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800dc7:	72 08                	jb     800dd1 <__udivdi3+0x75>
  800dc9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800dcc:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dcf:	77 7f                	ja     800e50 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd1:	b9 01 00 00 00       	mov    $0x1,%ecx
  800dd6:	31 c0                	xor    %eax,%eax
  800dd8:	eb c2                	jmp    800d9c <__udivdi3+0x40>
  800dda:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	74 79                	je     800e5c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800de3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800de6:	89 fa                	mov    %edi,%edx
  800de8:	f7 f1                	div    %ecx
  800dea:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800def:	f7 f1                	div    %ecx
  800df1:	89 c1                	mov    %eax,%ecx
  800df3:	89 f0                	mov    %esi,%eax
  800df5:	eb a5                	jmp    800d9c <__udivdi3+0x40>
  800df7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800df8:	b8 20 00 00 00       	mov    $0x20,%eax
  800dfd:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e03:	89 fa                	mov    %edi,%edx
  800e05:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e08:	d3 e2                	shl    %cl,%edx
  800e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e10:	d3 e8                	shr    %cl,%eax
  800e12:	89 d7                	mov    %edx,%edi
  800e14:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800e16:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800e19:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e1c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e26:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e29:	d3 ea                	shr    %cl,%edx
  800e2b:	09 d0                	or     %edx,%eax
  800e2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e30:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e33:	d3 ea                	shr    %cl,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 d7                	mov    %edx,%edi
  800e39:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e3c:	f7 e6                	mul    %esi
  800e3e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e40:	39 d7                	cmp    %edx,%edi
  800e42:	72 38                	jb     800e7c <__udivdi3+0x120>
  800e44:	74 27                	je     800e6d <__udivdi3+0x111>
  800e46:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e49:	31 c0                	xor    %eax,%eax
  800e4b:	e9 4c ff ff ff       	jmp    800d9c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e50:	31 c9                	xor    %ecx,%ecx
  800e52:	31 c0                	xor    %eax,%eax
  800e54:	e9 43 ff ff ff       	jmp    800d9c <__udivdi3+0x40>
  800e59:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e61:	31 d2                	xor    %edx,%edx
  800e63:	f7 75 f4             	divl   -0xc(%ebp)
  800e66:	89 c1                	mov    %eax,%ecx
  800e68:	e9 76 ff ff ff       	jmp    800de3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e70:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e73:	d3 e0                	shl    %cl,%eax
  800e75:	39 f0                	cmp    %esi,%eax
  800e77:	73 cd                	jae    800e46 <__udivdi3+0xea>
  800e79:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e7c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e7f:	49                   	dec    %ecx
  800e80:	31 c0                	xor    %eax,%eax
  800e82:	e9 15 ff ff ff       	jmp    800d9c <__udivdi3+0x40>
	...

00800e88 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	83 ec 30             	sub    $0x30,%esp
  800e90:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800e97:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ea4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800eaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ead:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800eaf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800eb2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800eb5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eb8:	85 d2                	test   %edx,%edx
  800eba:	75 1c                	jne    800ed8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800ebc:	89 fa                	mov    %edi,%edx
  800ebe:	39 f8                	cmp    %edi,%eax
  800ec0:	0f 86 c2 00 00 00    	jbe    800f88 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec6:	89 f0                	mov    %esi,%eax
  800ec8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800eca:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800ecd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800ed4:	eb 12                	jmp    800ee8 <__umoddi3+0x60>
  800ed6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800edb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800ede:	76 18                	jbe    800ef8 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800ee0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800ee3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ee6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800eeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800eee:	83 c4 30             	add    $0x30,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ef8:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800efc:	83 f0 1f             	xor    $0x1f,%eax
  800eff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f02:	0f 84 ac 00 00 00    	je     800fb4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f08:	b8 20 00 00 00       	mov    $0x20,%eax
  800f0d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800f10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f13:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f16:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f19:	d3 e2                	shl    %cl,%edx
  800f1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f21:	d3 e8                	shr    %cl,%eax
  800f23:	89 d6                	mov    %edx,%esi
  800f25:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f32:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800f35:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f37:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f3a:	d3 e0                	shl    %cl,%eax
  800f3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f3f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f42:	d3 ea                	shr    %cl,%edx
  800f44:	09 d0                	or     %edx,%eax
  800f46:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f49:	d3 ea                	shr    %cl,%edx
  800f4b:	f7 f6                	div    %esi
  800f4d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800f50:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f53:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800f56:	0f 82 8d 00 00 00    	jb     800fe9 <__umoddi3+0x161>
  800f5c:	0f 84 91 00 00 00    	je     800ff3 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f62:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f65:	29 c7                	sub    %eax,%edi
  800f67:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f6e:	d3 e2                	shl    %cl,%edx
  800f70:	89 f8                	mov    %edi,%eax
  800f72:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f75:	d3 e8                	shr    %cl,%eax
  800f77:	09 c2                	or     %eax,%edx
  800f79:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800f7c:	d3 ee                	shr    %cl,%esi
  800f7e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800f81:	e9 62 ff ff ff       	jmp    800ee8 <__umoddi3+0x60>
  800f86:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 15                	je     800fa4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f92:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f95:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	f7 f1                	div    %ecx
  800f9c:	e9 29 ff ff ff       	jmp    800eca <__umoddi3+0x42>
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa9:	31 d2                	xor    %edx,%edx
  800fab:	f7 75 ec             	divl   -0x14(%ebp)
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	eb dd                	jmp    800f8f <__umoddi3+0x107>
  800fb2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800fba:	72 19                	jb     800fd5 <__umoddi3+0x14d>
  800fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fbf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800fc2:	76 11                	jbe    800fd5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800fc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fc7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800fca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800fcd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800fd0:	e9 13 ff ff ff       	jmp    800ee8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fd5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800fde:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800fe1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fe4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800fe7:	eb db                	jmp    800fc4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fe9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800fec:	19 f2                	sbb    %esi,%edx
  800fee:	e9 6f ff ff ff       	jmp    800f62 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff3:	39 c7                	cmp    %eax,%edi
  800ff5:	72 f2                	jb     800fe9 <__umoddi3+0x161>
  800ff7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffa:	e9 63 ff ff ff       	jmp    800f62 <__umoddi3+0xda>
