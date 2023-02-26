
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6b 00 00 00       	call   80009c <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 80 0f 80 00       	push   $0x800f80
  800049:	e8 03 01 00 00       	call   800151 <cprintf>
  80004e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800053:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
		sys_yield();
  800056:	e8 a1 0b 00 00       	call   800bfc <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
  80005b:	a1 04 20 80 00       	mov    0x802004,%eax
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	53                   	push   %ebx
  800067:	50                   	push   %eax
  800068:	68 a0 0f 80 00       	push   $0x800fa0
  80006d:	e8 df 00 00 00       	call   800151 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800072:	43                   	inc    %ebx
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	83 fb 05             	cmp    $0x5,%ebx
  800079:	75 db                	jne    800056 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007b:	a1 04 20 80 00       	mov    0x802004,%eax
  800080:	8b 40 48             	mov    0x48(%eax),%eax
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	50                   	push   %eax
  800087:	68 cc 0f 80 00       	push   $0x800fcc
  80008c:	e8 c0 00 00 00       	call   800151 <cprintf>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000a7:	e8 6f 0b 00 00       	call   800c1b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b8:	c1 e0 07             	shl    $0x7,%eax
  8000bb:	29 d0                	sub    %edx,%eax
  8000bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 f6                	test   %esi,%esi
  8000c9:	7e 07                	jle    8000d2 <libmain+0x36>
		binaryname = argv[0];
  8000cb:	8b 03                	mov    (%ebx),%eax
  8000cd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	53                   	push   %ebx
  8000d6:	56                   	push   %esi
  8000d7:	e8 58 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0b 00 00 00       	call   8000ec <exit>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
	...

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 41 0b 00 00       	call   800c3a <sys_env_destroy>
  8000f9:	83 c4 10             	add    $0x10,%esp
}
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
	...

00800100 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 68 01 80 00       	push   $0x800168
  80012f:	e8 70 01 00 00       	call   8002a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  80013d:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 9e 08 00 00       	call   8009e7 <sys_cputs>
  800149:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
  80015a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80015d:	50                   	push   %eax
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	e8 9a ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 1a                	jne    80019f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 51 08 00 00       	call   8009e7 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019f:	ff 43 04             	incl   0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    
	...

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001b4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	89 d6                	mov    %edx,%esi
  8001cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8001d0:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001d3:	72 04                	jb     8001d9 <printnum+0x31>
  8001d5:	39 c2                	cmp    %eax,%edx
  8001d7:	77 3f                	ja     800218 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	ff 75 18             	pushl  0x18(%ebp)
  8001df:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001e2:	50                   	push   %eax
  8001e3:	52                   	push   %edx
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ef:	e8 d8 0a 00 00       	call   800ccc <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8001fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001ff:	e8 a4 ff ff ff       	call   8001a8 <printnum>
  800204:	83 c4 20             	add    $0x20,%esp
  800207:	eb 14                	jmp    80021d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	ff 75 e8             	pushl  -0x18(%ebp)
  80020f:	ff 75 18             	pushl  0x18(%ebp)
  800212:	ff 55 ec             	call   *-0x14(%ebp)
  800215:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	4b                   	dec    %ebx
  800219:	85 db                	test   %ebx,%ebx
  80021b:	7f ec                	jg     800209 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	ff 75 e8             	pushl  -0x18(%ebp)
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022b:	ff 75 e0             	pushl  -0x20(%ebp)
  80022e:	e8 c5 0b 00 00       	call   800df8 <__umoddi3>
  800233:	83 c4 14             	add    $0x14,%esp
  800236:	0f be 80 f5 0f 80 00 	movsbl 0x800ff5(%eax),%eax
  80023d:	50                   	push   %eax
  80023e:	ff 55 ec             	call   *-0x14(%ebp)
  800241:	83 c4 10             	add    $0x10,%esp
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 42 08             	lea    0x8(%edx),%eax
  80025b:	89 01                	mov    %eax,(%ecx)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x3a>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 42 04             	lea    0x4(%edx),%eax
  80026d:	89 01                	mov    %eax,(%ecx)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 42 04             	lea    0x4(%edx),%eax
  80027d:	89 01                	mov    %eax,(%ecx)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80028e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800291:	8b 11                	mov    (%ecx),%edx
  800293:	3b 51 04             	cmp    0x4(%ecx),%edx
  800296:	73 0a                	jae    8002a2 <sprintputch+0x1a>
		*b->buf++ = ch;
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	88 02                	mov    %al,(%edx)
  80029d:	8d 42 01             	lea    0x1(%edx),%eax
  8002a0:	89 01                	mov    %eax,(%ecx)
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 3c             	sub    $0x3c,%esp
  8002ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	eb 1a                	jmp    8002d2 <vprintfmt+0x2e>
  8002b8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002bb:	eb 15                	jmp    8002d2 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002bd:	84 c0                	test   %al,%al
  8002bf:	0f 84 15 03 00 00    	je     8005da <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	57                   	push   %edi
  8002c9:	0f b6 c0             	movzbl %al,%eax
  8002cc:	50                   	push   %eax
  8002cd:	ff d6                	call   *%esi
  8002cf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d2:	8a 03                	mov    (%ebx),%al
  8002d4:	43                   	inc    %ebx
  8002d5:	3c 25                	cmp    $0x25,%al
  8002d7:	75 e4                	jne    8002bd <vprintfmt+0x19>
  8002d9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002e0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002e7:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002f5:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8002f9:	eb 0a                	jmp    800305 <vprintfmt+0x61>
  8002fb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800302:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8a 03                	mov    (%ebx),%al
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  80030d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800310:	83 e8 23             	sub    $0x23,%eax
  800313:	3c 55                	cmp    $0x55,%al
  800315:	0f 87 9c 02 00 00    	ja     8005b7 <vprintfmt+0x313>
  80031b:	0f b6 c0             	movzbl %al,%eax
  80031e:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  800325:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800329:	eb d7                	jmp    800302 <vprintfmt+0x5e>
  80032b:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80032f:	eb d1                	jmp    800302 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800331:	89 d9                	mov    %ebx,%ecx
  800333:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800340:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800344:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800347:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80034b:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  80034c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80034f:	83 f8 09             	cmp    $0x9,%eax
  800352:	77 21                	ja     800375 <vprintfmt+0xd1>
  800354:	eb e4                	jmp    80033a <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800356:	8b 55 14             	mov    0x14(%ebp),%edx
  800359:	8d 42 04             	lea    0x4(%edx),%eax
  80035c:	89 45 14             	mov    %eax,0x14(%ebp)
  80035f:	8b 12                	mov    (%edx),%edx
  800361:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800364:	eb 12                	jmp    800378 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800366:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80036a:	79 96                	jns    800302 <vprintfmt+0x5e>
  80036c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800373:	eb 8d                	jmp    800302 <vprintfmt+0x5e>
  800375:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800378:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80037c:	79 84                	jns    800302 <vprintfmt+0x5e>
  80037e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800381:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800384:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80038b:	e9 72 ff ff ff       	jmp    800302 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800390:	ff 45 d4             	incl   -0x2c(%ebp)
  800393:	e9 6a ff ff ff       	jmp    800302 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800398:	8b 55 14             	mov    0x14(%ebp),%edx
  80039b:	8d 42 04             	lea    0x4(%edx),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	57                   	push   %edi
  8003a5:	ff 32                	pushl  (%edx)
  8003a7:	ff d6                	call   *%esi
			break;
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	e9 07 ff ff ff       	jmp    8002b8 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b1:	8b 55 14             	mov    0x14(%ebp),%edx
  8003b4:	8d 42 04             	lea    0x4(%edx),%eax
  8003b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	79 02                	jns    8003c2 <vprintfmt+0x11e>
  8003c0:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c2:	83 f8 0f             	cmp    $0xf,%eax
  8003c5:	7f 0b                	jg     8003d2 <vprintfmt+0x12e>
  8003c7:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  8003ce:	85 d2                	test   %edx,%edx
  8003d0:	75 15                	jne    8003e7 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003d2:	50                   	push   %eax
  8003d3:	68 06 10 80 00       	push   $0x801006
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	e8 6e 02 00 00       	call   80064d <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 c4 10             	add    $0x10,%esp
  8003e2:	e9 d1 fe ff ff       	jmp    8002b8 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003e7:	52                   	push   %edx
  8003e8:	68 0f 10 80 00       	push   $0x80100f
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	e8 59 02 00 00       	call   80064d <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	e9 bc fe ff ff       	jmp    8002b8 <vprintfmt+0x14>
  8003fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003ff:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800402:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 55 14             	mov    0x14(%ebp),%edx
  800408:	8d 42 04             	lea    0x4(%edx),%eax
  80040b:	89 45 14             	mov    %eax,0x14(%ebp)
  80040e:	8b 1a                	mov    (%edx),%ebx
  800410:	85 db                	test   %ebx,%ebx
  800412:	75 05                	jne    800419 <vprintfmt+0x175>
  800414:	bb 12 10 80 00       	mov    $0x801012,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800419:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80041d:	7e 66                	jle    800485 <vprintfmt+0x1e1>
  80041f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800423:	74 60                	je     800485 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	51                   	push   %ecx
  800429:	53                   	push   %ebx
  80042a:	e8 57 02 00 00       	call   800686 <strnlen>
  80042f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80043e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800441:	eb 0f                	jmp    800452 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	57                   	push   %edi
  800447:	ff 75 c4             	pushl  -0x3c(%ebp)
  80044a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	ff 4d d8             	decl   -0x28(%ebp)
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	7f eb                	jg     800443 <vprintfmt+0x19f>
  800458:	eb 2b                	jmp    800485 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045a:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  80045d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800461:	74 15                	je     800478 <vprintfmt+0x1d4>
  800463:	8d 42 e0             	lea    -0x20(%edx),%eax
  800466:	83 f8 5e             	cmp    $0x5e,%eax
  800469:	76 0d                	jbe    800478 <vprintfmt+0x1d4>
					putch('?', putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	57                   	push   %edi
  80046f:	6a 3f                	push   $0x3f
  800471:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	eb 0a                	jmp    800482 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	57                   	push   %edi
  80047c:	52                   	push   %edx
  80047d:	ff d6                	call   *%esi
  80047f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800482:	ff 4d d8             	decl   -0x28(%ebp)
  800485:	8a 03                	mov    (%ebx),%al
  800487:	43                   	inc    %ebx
  800488:	84 c0                	test   %al,%al
  80048a:	74 1b                	je     8004a7 <vprintfmt+0x203>
  80048c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800490:	78 c8                	js     80045a <vprintfmt+0x1b6>
  800492:	ff 4d dc             	decl   -0x24(%ebp)
  800495:	79 c3                	jns    80045a <vprintfmt+0x1b6>
  800497:	eb 0e                	jmp    8004a7 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	57                   	push   %edi
  80049d:	6a 20                	push   $0x20
  80049f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004a1:	ff 4d d8             	decl   -0x28(%ebp)
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ab:	7f ec                	jg     800499 <vprintfmt+0x1f5>
  8004ad:	e9 06 fe ff ff       	jmp    8002b8 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004b2:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004b6:	7e 10                	jle    8004c8 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bb:	8d 42 08             	lea    0x8(%edx),%eax
  8004be:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c1:	8b 02                	mov    (%edx),%eax
  8004c3:	8b 52 04             	mov    0x4(%edx),%edx
  8004c6:	eb 20                	jmp    8004e8 <vprintfmt+0x244>
	else if (lflag)
  8004c8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cc:	74 0e                	je     8004dc <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	99                   	cltd   
  8004da:	eb 0c                	jmp    8004e8 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 00                	mov    (%eax),%eax
  8004e7:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004e8:	89 d1                	mov    %edx,%ecx
  8004ea:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004ec:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f2:	85 c9                	test   %ecx,%ecx
  8004f4:	78 0a                	js     800500 <vprintfmt+0x25c>
  8004f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8004fb:	e9 89 00 00 00       	jmp    800589 <vprintfmt+0x2e5>
				putch('-', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	57                   	push   %edi
  800504:	6a 2d                	push   $0x2d
  800506:	ff d6                	call   *%esi
				num = -(long long) num;
  800508:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80050b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050e:	f7 da                	neg    %edx
  800510:	83 d1 00             	adc    $0x0,%ecx
  800513:	f7 d9                	neg    %ecx
  800515:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 6a                	jmp    800589 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80051f:	8d 45 14             	lea    0x14(%ebp),%eax
  800522:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800525:	e8 22 fd ff ff       	call   80024c <getuint>
  80052a:	89 d1                	mov    %edx,%ecx
  80052c:	89 c2                	mov    %eax,%edx
  80052e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800533:	eb 54                	jmp    800589 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800535:	8d 45 14             	lea    0x14(%ebp),%eax
  800538:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053b:	e8 0c fd ff ff       	call   80024c <getuint>
  800540:	89 d1                	mov    %edx,%ecx
  800542:	89 c2                	mov    %eax,%edx
  800544:	bb 08 00 00 00       	mov    $0x8,%ebx
  800549:	eb 3e                	jmp    800589 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	57                   	push   %edi
  80054f:	6a 30                	push   $0x30
  800551:	ff d6                	call   *%esi
			putch('x', putdat);
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	57                   	push   %edi
  800557:	6a 78                	push   $0x78
  800559:	ff d6                	call   *%esi
			num = (unsigned long long)
  80055b:	8b 55 14             	mov    0x14(%ebp),%edx
  80055e:	8d 42 04             	lea    0x4(%edx),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	8b 12                	mov    (%edx),%edx
  800566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 14                	jmp    800589 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800575:	8d 45 14             	lea    0x14(%ebp),%eax
  800578:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80057b:	e8 cc fc ff ff       	call   80024c <getuint>
  800580:	89 d1                	mov    %edx,%ecx
  800582:	89 c2                	mov    %eax,%edx
  800584:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 d8             	pushl  -0x28(%ebp)
  800594:	53                   	push   %ebx
  800595:	51                   	push   %ecx
  800596:	52                   	push   %edx
  800597:	89 fa                	mov    %edi,%edx
  800599:	89 f0                	mov    %esi,%eax
  80059b:	e8 08 fc ff ff       	call   8001a8 <printnum>
			break;
  8005a0:	83 c4 20             	add    $0x20,%esp
  8005a3:	e9 10 fd ff ff       	jmp    8002b8 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	57                   	push   %edi
  8005ac:	52                   	push   %edx
  8005ad:	ff d6                	call   *%esi
			break;
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	e9 01 fd ff ff       	jmp    8002b8 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 25                	push   $0x25
  8005bd:	ff d6                	call   *%esi
  8005bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005c2:	83 ea 02             	sub    $0x2,%edx
  8005c5:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005c8:	8a 02                	mov    (%edx),%al
  8005ca:	4a                   	dec    %edx
  8005cb:	3c 25                	cmp    $0x25,%al
  8005cd:	75 f9                	jne    8005c8 <vprintfmt+0x324>
  8005cf:	83 c2 02             	add    $0x2,%edx
  8005d2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005d5:	e9 de fc ff ff       	jmp    8002b8 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5f                   	pop    %edi
  8005e0:	c9                   	leave  
  8005e1:	c3                   	ret    

008005e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005e2:	55                   	push   %ebp
  8005e3:	89 e5                	mov    %esp,%ebp
  8005e5:	83 ec 18             	sub    $0x18,%esp
  8005e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	74 37                	je     800629 <vsnprintf+0x47>
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	7e 33                	jle    800629 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8005fd:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800601:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800604:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800607:	ff 75 14             	pushl  0x14(%ebp)
  80060a:	ff 75 10             	pushl  0x10(%ebp)
  80060d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800610:	50                   	push   %eax
  800611:	68 88 02 80 00       	push   $0x800288
  800616:	e8 89 fc ff ff       	call   8002a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80061b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80061e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800621:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	eb 05                	jmp    80062e <vsnprintf+0x4c>
  800629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80062e:	c9                   	leave  
  80062f:	c3                   	ret    

00800630 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80063c:	50                   	push   %eax
  80063d:	ff 75 10             	pushl  0x10(%ebp)
  800640:	ff 75 0c             	pushl  0xc(%ebp)
  800643:	ff 75 08             	pushl  0x8(%ebp)
  800646:	e8 97 ff ff ff       	call   8005e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  80064b:	c9                   	leave  
  80064c:	c3                   	ret    

0080064d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800659:	50                   	push   %eax
  80065a:	ff 75 10             	pushl  0x10(%ebp)
  80065d:	ff 75 0c             	pushl  0xc(%ebp)
  800660:	ff 75 08             	pushl  0x8(%ebp)
  800663:	e8 3c fc ff ff       	call   8002a4 <vprintfmt>
	va_end(ap);
  800668:	83 c4 10             	add    $0x10,%esp
}
  80066b:	c9                   	leave  
  80066c:	c3                   	ret    
  80066d:	00 00                	add    %al,(%eax)
	...

00800670 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	8b 55 08             	mov    0x8(%ebp),%edx
  800676:	b8 00 00 00 00       	mov    $0x0,%eax
  80067b:	eb 01                	jmp    80067e <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  80067d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80067e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800682:	75 f9                	jne    80067d <strlen+0xd>
		n++;
	return n;
}
  800684:	c9                   	leave  
  800685:	c3                   	ret    

00800686 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80068c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068f:	b8 00 00 00 00       	mov    $0x0,%eax
  800694:	eb 01                	jmp    800697 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800696:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800697:	39 d0                	cmp    %edx,%eax
  800699:	74 06                	je     8006a1 <strnlen+0x1b>
  80069b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80069f:	75 f5                	jne    800696 <strnlen+0x10>
		n++;
	return n;
}
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a9:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ac:	8a 01                	mov    (%ecx),%al
  8006ae:	88 02                	mov    %al,(%edx)
  8006b0:	42                   	inc    %edx
  8006b1:	41                   	inc    %ecx
  8006b2:	84 c0                	test   %al,%al
  8006b4:	75 f6                	jne    8006ac <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	c9                   	leave  
  8006ba:	c3                   	ret    

008006bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	53                   	push   %ebx
  8006bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006c2:	53                   	push   %ebx
  8006c3:	e8 a8 ff ff ff       	call   800670 <strlen>
	strcpy(dst + len, src);
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006ce:	50                   	push   %eax
  8006cf:	e8 cf ff ff ff       	call   8006a3 <strcpy>
	return dst;
}
  8006d4:	89 d8                	mov    %ebx,%eax
  8006d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	56                   	push   %esi
  8006df:	53                   	push   %ebx
  8006e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	eb 0c                	jmp    8006fc <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006f0:	8a 02                	mov    (%edx),%al
  8006f2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8006f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8006fb:	41                   	inc    %ecx
  8006fc:	39 d9                	cmp    %ebx,%ecx
  8006fe:	75 f0                	jne    8006f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800700:	89 f0                	mov    %esi,%eax
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	56                   	push   %esi
  80070a:	53                   	push   %ebx
  80070b:	8b 75 08             	mov    0x8(%ebp),%esi
  80070e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800711:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800714:	85 c9                	test   %ecx,%ecx
  800716:	75 04                	jne    80071c <strlcpy+0x16>
  800718:	89 f0                	mov    %esi,%eax
  80071a:	eb 14                	jmp    800730 <strlcpy+0x2a>
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	eb 04                	jmp    800724 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800720:	88 10                	mov    %dl,(%eax)
  800722:	40                   	inc    %eax
  800723:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800724:	49                   	dec    %ecx
  800725:	74 06                	je     80072d <strlcpy+0x27>
  800727:	8a 13                	mov    (%ebx),%dl
  800729:	84 d2                	test   %dl,%dl
  80072b:	75 f3                	jne    800720 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80072d:	c6 00 00             	movb   $0x0,(%eax)
  800730:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073f:	eb 02                	jmp    800743 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800741:	42                   	inc    %edx
  800742:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800743:	8a 02                	mov    (%edx),%al
  800745:	84 c0                	test   %al,%al
  800747:	74 04                	je     80074d <strcmp+0x17>
  800749:	3a 01                	cmp    (%ecx),%al
  80074b:	74 f4                	je     800741 <strcmp+0xb>
  80074d:	0f b6 c0             	movzbl %al,%eax
  800750:	0f b6 11             	movzbl (%ecx),%edx
  800753:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800761:	8b 55 10             	mov    0x10(%ebp),%edx
  800764:	eb 03                	jmp    800769 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800766:	4a                   	dec    %edx
  800767:	41                   	inc    %ecx
  800768:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800769:	85 d2                	test   %edx,%edx
  80076b:	75 07                	jne    800774 <strncmp+0x1d>
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
  800772:	eb 14                	jmp    800788 <strncmp+0x31>
  800774:	8a 01                	mov    (%ecx),%al
  800776:	84 c0                	test   %al,%al
  800778:	74 04                	je     80077e <strncmp+0x27>
  80077a:	3a 03                	cmp    (%ebx),%al
  80077c:	74 e8                	je     800766 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80077e:	0f b6 d0             	movzbl %al,%edx
  800781:	0f b6 03             	movzbl (%ebx),%eax
  800784:	29 c2                	sub    %eax,%edx
  800786:	89 d0                	mov    %edx,%eax
}
  800788:	5b                   	pop    %ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 45 08             	mov    0x8(%ebp),%eax
  800791:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800794:	eb 05                	jmp    80079b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800796:	38 ca                	cmp    %cl,%dl
  800798:	74 0c                	je     8007a6 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80079a:	40                   	inc    %eax
  80079b:	8a 10                	mov    (%eax),%dl
  80079d:	84 d2                	test   %dl,%dl
  80079f:	75 f5                	jne    800796 <strchr+0xb>
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007b1:	eb 05                	jmp    8007b8 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007b3:	38 ca                	cmp    %cl,%dl
  8007b5:	74 07                	je     8007be <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007b7:	40                   	inc    %eax
  8007b8:	8a 10                	mov    (%eax),%dl
  8007ba:	84 d2                	test   %dl,%dl
  8007bc:	75 f5                	jne    8007b3 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	57                   	push   %edi
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007cf:	85 db                	test   %ebx,%ebx
  8007d1:	74 36                	je     800809 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007d3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007d9:	75 29                	jne    800804 <memset+0x44>
  8007db:	f6 c3 03             	test   $0x3,%bl
  8007de:	75 24                	jne    800804 <memset+0x44>
		c &= 0xFF;
  8007e0:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007e3:	89 d6                	mov    %edx,%esi
  8007e5:	c1 e6 08             	shl    $0x8,%esi
  8007e8:	89 d0                	mov    %edx,%eax
  8007ea:	c1 e0 18             	shl    $0x18,%eax
  8007ed:	89 d1                	mov    %edx,%ecx
  8007ef:	c1 e1 10             	shl    $0x10,%ecx
  8007f2:	09 c8                	or     %ecx,%eax
  8007f4:	09 c2                	or     %eax,%edx
  8007f6:	89 f0                	mov    %esi,%eax
  8007f8:	09 d0                	or     %edx,%eax
  8007fa:	89 d9                	mov    %ebx,%ecx
  8007fc:	c1 e9 02             	shr    $0x2,%ecx
  8007ff:	fc                   	cld    
  800800:	f3 ab                	rep stos %eax,%es:(%edi)
  800802:	eb 05                	jmp    800809 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800804:	89 d9                	mov    %ebx,%ecx
  800806:	fc                   	cld    
  800807:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800809:	89 f8                	mov    %edi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5f                   	pop    %edi
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	57                   	push   %edi
  800814:	56                   	push   %esi
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80081b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80081e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800820:	39 c6                	cmp    %eax,%esi
  800822:	73 36                	jae    80085a <memmove+0x4a>
  800824:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800827:	39 d0                	cmp    %edx,%eax
  800829:	73 2f                	jae    80085a <memmove+0x4a>
		s += n;
		d += n;
  80082b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80082e:	f6 c2 03             	test   $0x3,%dl
  800831:	75 1b                	jne    80084e <memmove+0x3e>
  800833:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800839:	75 13                	jne    80084e <memmove+0x3e>
  80083b:	f6 c1 03             	test   $0x3,%cl
  80083e:	75 0e                	jne    80084e <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800840:	8d 7e fc             	lea    -0x4(%esi),%edi
  800843:	8d 72 fc             	lea    -0x4(%edx),%esi
  800846:	c1 e9 02             	shr    $0x2,%ecx
  800849:	fd                   	std    
  80084a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80084c:	eb 09                	jmp    800857 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80084e:	8d 7e ff             	lea    -0x1(%esi),%edi
  800851:	8d 72 ff             	lea    -0x1(%edx),%esi
  800854:	fd                   	std    
  800855:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800857:	fc                   	cld    
  800858:	eb 20                	jmp    80087a <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80085a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800860:	75 15                	jne    800877 <memmove+0x67>
  800862:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800868:	75 0d                	jne    800877 <memmove+0x67>
  80086a:	f6 c1 03             	test   $0x3,%cl
  80086d:	75 08                	jne    800877 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80086f:	c1 e9 02             	shr    $0x2,%ecx
  800872:	fc                   	cld    
  800873:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800875:	eb 03                	jmp    80087a <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800877:	fc                   	cld    
  800878:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800881:	ff 75 10             	pushl  0x10(%ebp)
  800884:	ff 75 0c             	pushl  0xc(%ebp)
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 81 ff ff ff       	call   800810 <memmove>
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	83 ec 04             	sub    $0x4,%esp
  800898:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80089b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80089e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a1:	eb 1b                	jmp    8008be <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008a3:	8a 1a                	mov    (%edx),%bl
  8008a5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008a8:	8a 19                	mov    (%ecx),%bl
  8008aa:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008ad:	74 0d                	je     8008bc <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008af:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008b3:	0f b6 c3             	movzbl %bl,%eax
  8008b6:	29 c2                	sub    %eax,%edx
  8008b8:	89 d0                	mov    %edx,%eax
  8008ba:	eb 0d                	jmp    8008c9 <memcmp+0x38>
		s1++, s2++;
  8008bc:	42                   	inc    %edx
  8008bd:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008be:	48                   	dec    %eax
  8008bf:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008c2:	75 df                	jne    8008a3 <memcmp+0x12>
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008c9:	83 c4 04             	add    $0x4,%esp
  8008cc:	5b                   	pop    %ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	03 55 10             	add    0x10(%ebp),%edx
  8008dd:	eb 05                	jmp    8008e4 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008df:	38 08                	cmp    %cl,(%eax)
  8008e1:	74 05                	je     8008e8 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008e3:	40                   	inc    %eax
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	72 f7                	jb     8008df <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 04             	sub    $0x4,%esp
  8008f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8008f9:	eb 01                	jmp    8008fc <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8008fb:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8008fc:	8a 01                	mov    (%ecx),%al
  8008fe:	3c 20                	cmp    $0x20,%al
  800900:	74 f9                	je     8008fb <strtol+0x11>
  800902:	3c 09                	cmp    $0x9,%al
  800904:	74 f5                	je     8008fb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800906:	3c 2b                	cmp    $0x2b,%al
  800908:	75 0a                	jne    800914 <strtol+0x2a>
		s++;
  80090a:	41                   	inc    %ecx
  80090b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800912:	eb 17                	jmp    80092b <strtol+0x41>
	else if (*s == '-')
  800914:	3c 2d                	cmp    $0x2d,%al
  800916:	74 09                	je     800921 <strtol+0x37>
  800918:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80091f:	eb 0a                	jmp    80092b <strtol+0x41>
		s++, neg = 1;
  800921:	8d 49 01             	lea    0x1(%ecx),%ecx
  800924:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80092b:	85 f6                	test   %esi,%esi
  80092d:	74 05                	je     800934 <strtol+0x4a>
  80092f:	83 fe 10             	cmp    $0x10,%esi
  800932:	75 1a                	jne    80094e <strtol+0x64>
  800934:	8a 01                	mov    (%ecx),%al
  800936:	3c 30                	cmp    $0x30,%al
  800938:	75 10                	jne    80094a <strtol+0x60>
  80093a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80093e:	75 0a                	jne    80094a <strtol+0x60>
		s += 2, base = 16;
  800940:	83 c1 02             	add    $0x2,%ecx
  800943:	be 10 00 00 00       	mov    $0x10,%esi
  800948:	eb 04                	jmp    80094e <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80094a:	85 f6                	test   %esi,%esi
  80094c:	74 07                	je     800955 <strtol+0x6b>
  80094e:	bf 00 00 00 00       	mov    $0x0,%edi
  800953:	eb 13                	jmp    800968 <strtol+0x7e>
  800955:	3c 30                	cmp    $0x30,%al
  800957:	74 07                	je     800960 <strtol+0x76>
  800959:	be 0a 00 00 00       	mov    $0xa,%esi
  80095e:	eb ee                	jmp    80094e <strtol+0x64>
		s++, base = 8;
  800960:	41                   	inc    %ecx
  800961:	be 08 00 00 00       	mov    $0x8,%esi
  800966:	eb e6                	jmp    80094e <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800968:	8a 11                	mov    (%ecx),%dl
  80096a:	88 d3                	mov    %dl,%bl
  80096c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80096f:	3c 09                	cmp    $0x9,%al
  800971:	77 08                	ja     80097b <strtol+0x91>
			dig = *s - '0';
  800973:	0f be c2             	movsbl %dl,%eax
  800976:	8d 50 d0             	lea    -0x30(%eax),%edx
  800979:	eb 1c                	jmp    800997 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80097b:	8d 43 9f             	lea    -0x61(%ebx),%eax
  80097e:	3c 19                	cmp    $0x19,%al
  800980:	77 08                	ja     80098a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800982:	0f be c2             	movsbl %dl,%eax
  800985:	8d 50 a9             	lea    -0x57(%eax),%edx
  800988:	eb 0d                	jmp    800997 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80098a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  80098d:	3c 19                	cmp    $0x19,%al
  80098f:	77 15                	ja     8009a6 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800991:	0f be c2             	movsbl %dl,%eax
  800994:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800997:	39 f2                	cmp    %esi,%edx
  800999:	7d 0b                	jge    8009a6 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  80099b:	41                   	inc    %ecx
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	0f af c6             	imul   %esi,%eax
  8009a1:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009a4:	eb c2                	jmp    800968 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009a6:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009ac:	74 05                	je     8009b3 <strtol+0xc9>
		*endptr = (char *) s;
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009b7:	74 04                	je     8009bd <strtol+0xd3>
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	f7 df                	neg    %edi
}
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	83 c4 04             	add    $0x4,%esp
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    
	...

008009c8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d8:	89 fa                	mov    %edi,%edx
  8009da:	89 f9                	mov    %edi,%ecx
  8009dc:	89 fb                	mov    %edi,%ebx
  8009de:	89 fe                	mov    %edi,%esi
  8009e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 04             	sub    $0x4,%esp
  8009f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	89 fb                	mov    %edi,%ebx
  8009ff:	89 fe                	mov    %edi,%esi
  800a01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a03:	83 c4 04             	add    $0x4,%esp
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	83 ec 0c             	sub    $0xc,%esp
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a21:	89 f9                	mov    %edi,%ecx
  800a23:	89 fb                	mov    %edi,%ebx
  800a25:	89 fe                	mov    %edi,%esi
  800a27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	7e 17                	jle    800a44 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a2d:	83 ec 0c             	sub    $0xc,%esp
  800a30:	50                   	push   %eax
  800a31:	6a 0d                	push   $0xd
  800a33:	68 ff 12 80 00       	push   $0x8012ff
  800a38:	6a 23                	push   $0x23
  800a3a:	68 1c 13 80 00       	push   $0x80131c
  800a3f:	e8 38 02 00 00       	call   800c7c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a5b:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a63:	be 00 00 00 00       	mov    $0x0,%esi
  800a68:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 0c             	sub    $0xc,%esp
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
  800a88:	89 fb                	mov    %edi,%ebx
  800a8a:	89 fe                	mov    %edi,%esi
  800a8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	7e 17                	jle    800aa9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a92:	83 ec 0c             	sub    $0xc,%esp
  800a95:	50                   	push   %eax
  800a96:	6a 0a                	push   $0xa
  800a98:	68 ff 12 80 00       	push   $0x8012ff
  800a9d:	6a 23                	push   $0x23
  800a9f:	68 1c 13 80 00       	push   $0x80131c
  800aa4:	e8 d3 01 00 00       	call   800c7c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ac5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aca:	89 fb                	mov    %edi,%ebx
  800acc:	89 fe                	mov    %edi,%esi
  800ace:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	7e 17                	jle    800aeb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	50                   	push   %eax
  800ad8:	6a 09                	push   $0x9
  800ada:	68 ff 12 80 00       	push   $0x8012ff
  800adf:	6a 23                	push   $0x23
  800ae1:	68 1c 13 80 00       	push   $0x80131c
  800ae6:	e8 91 01 00 00       	call   800c7c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 08 00 00 00       	mov    $0x8,%eax
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0c:	89 fb                	mov    %edi,%ebx
  800b0e:	89 fe                	mov    %edi,%esi
  800b10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b12:	85 c0                	test   %eax,%eax
  800b14:	7e 17                	jle    800b2d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	50                   	push   %eax
  800b1a:	6a 08                	push   $0x8
  800b1c:	68 ff 12 80 00       	push   $0x8012ff
  800b21:	6a 23                	push   $0x23
  800b23:	68 1c 13 80 00       	push   $0x80131c
  800b28:	e8 4f 01 00 00       	call   800c7c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	b8 06 00 00 00       	mov    $0x6,%eax
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4e:	89 fb                	mov    %edi,%ebx
  800b50:	89 fe                	mov    %edi,%esi
  800b52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b54:	85 c0                	test   %eax,%eax
  800b56:	7e 17                	jle    800b6f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b58:	83 ec 0c             	sub    $0xc,%esp
  800b5b:	50                   	push   %eax
  800b5c:	6a 06                	push   $0x6
  800b5e:	68 ff 12 80 00       	push   $0x8012ff
  800b63:	6a 23                	push   $0x23
  800b65:	68 1c 13 80 00       	push   $0x80131c
  800b6a:	e8 0d 01 00 00       	call   800c7c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8c:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 05                	push   $0x5
  800ba0:	68 ff 12 80 00       	push   $0x8012ff
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 1c 13 80 00       	push   $0x80131c
  800bac:	e8 cb 00 00 00       	call   800c7c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd5:	89 fe                	mov    %edi,%esi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 ff 12 80 00       	push   $0x8012ff
  800be8:	6a 23                	push   $0x23
  800bea:	68 1c 13 80 00       	push   $0x80131c
  800bef:	e8 88 00 00 00       	call   800c7c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c07:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0c:	89 fa                	mov    %edi,%edx
  800c0e:	89 f9                	mov    %edi,%ecx
  800c10:	89 fb                	mov    %edi,%ebx
  800c12:	89 fe                	mov    %edi,%esi
  800c14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b8 02 00 00 00       	mov    $0x2,%eax
  800c26:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2b:	89 fa                	mov    %edi,%edx
  800c2d:	89 f9                	mov    %edi,%ecx
  800c2f:	89 fb                	mov    %edi,%ebx
  800c31:	89 fe                	mov    %edi,%esi
  800c33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c50:	89 f9                	mov    %edi,%ecx
  800c52:	89 fb                	mov    %edi,%ebx
  800c54:	89 fe                	mov    %edi,%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 03                	push   $0x3
  800c62:	68 ff 12 80 00       	push   $0x8012ff
  800c67:	6a 23                	push   $0x23
  800c69:	68 1c 13 80 00       	push   $0x80131c
  800c6e:	e8 09 00 00 00       	call   800c7c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    
	...

00800c7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800c83:	8d 45 14             	lea    0x14(%ebp),%eax
  800c86:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c89:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800c8f:	e8 87 ff ff ff       	call   800c1b <sys_getenvid>
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	ff 75 0c             	pushl  0xc(%ebp)
  800c9a:	ff 75 08             	pushl  0x8(%ebp)
  800c9d:	53                   	push   %ebx
  800c9e:	50                   	push   %eax
  800c9f:	68 2c 13 80 00       	push   $0x80132c
  800ca4:	e8 a8 f4 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca9:	83 c4 18             	add    $0x18,%esp
  800cac:	ff 75 f8             	pushl  -0x8(%ebp)
  800caf:	ff 75 10             	pushl  0x10(%ebp)
  800cb2:	e8 49 f4 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  800cb7:	c7 04 24 50 13 80 00 	movl   $0x801350,(%esp)
  800cbe:	e8 8e f4 ff ff       	call   800151 <cprintf>
  800cc3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cc6:	cc                   	int3   
  800cc7:	eb fd                	jmp    800cc6 <_panic+0x4a>
  800cc9:	00 00                	add    %al,(%eax)
	...

00800ccc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	83 ec 28             	sub    $0x28,%esp
  800cd4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800cdb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce5:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ceb:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800ced:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf8:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	75 21                	jne    800d20 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cff:	39 d1                	cmp    %edx,%ecx
  800d01:	76 49                	jbe    800d4c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d03:	f7 f1                	div    %ecx
  800d05:	89 c1                	mov    %eax,%ecx
  800d07:	31 c0                	xor    %eax,%eax
  800d09:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d0c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d12:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d15:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d18:	83 c4 28             	add    $0x28,%esp
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    
  800d1f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d20:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d23:	0f 87 97 00 00 00    	ja     800dc0 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d29:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d2c:	83 f0 1f             	xor    $0x1f,%eax
  800d2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d32:	75 34                	jne    800d68 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d34:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d37:	72 08                	jb     800d41 <__udivdi3+0x75>
  800d39:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d3c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d3f:	77 7f                	ja     800dc0 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d41:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d46:	31 c0                	xor    %eax,%eax
  800d48:	eb c2                	jmp    800d0c <__udivdi3+0x40>
  800d4a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	74 79                	je     800dcc <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d53:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d56:	89 fa                	mov    %edi,%edx
  800d58:	f7 f1                	div    %ecx
  800d5a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d5f:	f7 f1                	div    %ecx
  800d61:	89 c1                	mov    %eax,%ecx
  800d63:	89 f0                	mov    %esi,%eax
  800d65:	eb a5                	jmp    800d0c <__udivdi3+0x40>
  800d67:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d68:	b8 20 00 00 00       	mov    $0x20,%eax
  800d6d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d73:	89 fa                	mov    %edi,%edx
  800d75:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d78:	d3 e2                	shl    %cl,%edx
  800d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d80:	d3 e8                	shr    %cl,%eax
  800d82:	89 d7                	mov    %edx,%edi
  800d84:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d86:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d89:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d8c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d91:	d3 e0                	shl    %cl,%eax
  800d93:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d96:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d99:	d3 ea                	shr    %cl,%edx
  800d9b:	09 d0                	or     %edx,%eax
  800d9d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800da0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800da3:	d3 ea                	shr    %cl,%edx
  800da5:	f7 f7                	div    %edi
  800da7:	89 d7                	mov    %edx,%edi
  800da9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800dac:	f7 e6                	mul    %esi
  800dae:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800db0:	39 d7                	cmp    %edx,%edi
  800db2:	72 38                	jb     800dec <__udivdi3+0x120>
  800db4:	74 27                	je     800ddd <__udivdi3+0x111>
  800db6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800db9:	31 c0                	xor    %eax,%eax
  800dbb:	e9 4c ff ff ff       	jmp    800d0c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dc0:	31 c9                	xor    %ecx,%ecx
  800dc2:	31 c0                	xor    %eax,%eax
  800dc4:	e9 43 ff ff ff       	jmp    800d0c <__udivdi3+0x40>
  800dc9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd1:	31 d2                	xor    %edx,%edx
  800dd3:	f7 75 f4             	divl   -0xc(%ebp)
  800dd6:	89 c1                	mov    %eax,%ecx
  800dd8:	e9 76 ff ff ff       	jmp    800d53 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ddd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800de0:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	39 f0                	cmp    %esi,%eax
  800de7:	73 cd                	jae    800db6 <__udivdi3+0xea>
  800de9:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800def:	49                   	dec    %ecx
  800df0:	31 c0                	xor    %eax,%eax
  800df2:	e9 15 ff ff ff       	jmp    800d0c <__udivdi3+0x40>
	...

00800df8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	83 ec 30             	sub    $0x30,%esp
  800e00:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800e07:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e14:	8b 45 10             	mov    0x10(%ebp),%eax
  800e17:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e1d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800e1f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800e22:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800e25:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e28:	85 d2                	test   %edx,%edx
  800e2a:	75 1c                	jne    800e48 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800e2c:	89 fa                	mov    %edi,%edx
  800e2e:	39 f8                	cmp    %edi,%eax
  800e30:	0f 86 c2 00 00 00    	jbe    800ef8 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e3a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e3d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e44:	eb 12                	jmp    800e58 <__umoddi3+0x60>
  800e46:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e48:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e4b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e4e:	76 18                	jbe    800e68 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e50:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e53:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e56:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e58:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e5b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e5e:	83 c4 30             	add    $0x30,%esp
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e68:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e6c:	83 f0 1f             	xor    $0x1f,%eax
  800e6f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e72:	0f 84 ac 00 00 00    	je     800f24 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e78:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e83:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e86:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e89:	d3 e2                	shl    %cl,%edx
  800e8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e8e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e91:	d3 e8                	shr    %cl,%eax
  800e93:	89 d6                	mov    %edx,%esi
  800e95:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e9a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e9d:	d3 e0                	shl    %cl,%eax
  800e9f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ea2:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800ea5:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ea7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eaa:	d3 e0                	shl    %cl,%eax
  800eac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eaf:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eb2:	d3 ea                	shr    %cl,%edx
  800eb4:	09 d0                	or     %edx,%eax
  800eb6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800eb9:	d3 ea                	shr    %cl,%edx
  800ebb:	f7 f6                	div    %esi
  800ebd:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800ec0:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ec3:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800ec6:	0f 82 8d 00 00 00    	jb     800f59 <__umoddi3+0x161>
  800ecc:	0f 84 91 00 00 00    	je     800f63 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ed2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ed5:	29 c7                	sub    %eax,%edi
  800ed7:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ed9:	89 f2                	mov    %esi,%edx
  800edb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ede:	d3 e2                	shl    %cl,%edx
  800ee0:	89 f8                	mov    %edi,%eax
  800ee2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ee5:	d3 e8                	shr    %cl,%eax
  800ee7:	09 c2                	or     %eax,%edx
  800ee9:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800eec:	d3 ee                	shr    %cl,%esi
  800eee:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ef1:	e9 62 ff ff ff       	jmp    800e58 <__umoddi3+0x60>
  800ef6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	74 15                	je     800f14 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f02:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f05:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0a:	f7 f1                	div    %ecx
  800f0c:	e9 29 ff ff ff       	jmp    800e3a <__umoddi3+0x42>
  800f11:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f14:	b8 01 00 00 00       	mov    $0x1,%eax
  800f19:	31 d2                	xor    %edx,%edx
  800f1b:	f7 75 ec             	divl   -0x14(%ebp)
  800f1e:	89 c1                	mov    %eax,%ecx
  800f20:	eb dd                	jmp    800eff <__umoddi3+0x107>
  800f22:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f27:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800f2a:	72 19                	jb     800f45 <__umoddi3+0x14d>
  800f2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f2f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800f32:	76 11                	jbe    800f45 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f37:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f3a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f3d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f40:	e9 13 ff ff ff       	jmp    800e58 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f45:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f4e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f54:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f57:	eb db                	jmp    800f34 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f59:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f5c:	19 f2                	sbb    %esi,%edx
  800f5e:	e9 6f ff ff ff       	jmp    800ed2 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f63:	39 c7                	cmp    %eax,%edi
  800f65:	72 f2                	jb     800f59 <__umoddi3+0x161>
  800f67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6a:	e9 63 ff ff ff       	jmp    800ed2 <__umoddi3+0xda>
