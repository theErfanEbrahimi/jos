
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 79 0c 00 00       	call   800cba <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 25                	je     80006f <umain+0x3b>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 f0 0b 00 00       	call   800c3f <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 e0 13 80 00       	push   $0x8013e0
  800059:	e8 17 01 00 00       	call   800175 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	e8 11 0f 00 00       	call   800f7d <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	6a 00                	push   $0x0
  800074:	6a 00                	push   $0x0
  800076:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800079:	50                   	push   %eax
  80007a:	e8 53 0f 00 00       	call   800fd2 <ipc_recv>
  80007f:	89 c6                	mov    %eax,%esi
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800084:	e8 b6 0b 00 00       	call   800c3f <sys_getenvid>
  800089:	53                   	push   %ebx
  80008a:	56                   	push   %esi
  80008b:	50                   	push   %eax
  80008c:	68 f6 13 80 00       	push   $0x8013f6
  800091:	e8 df 00 00 00       	call   800175 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fe 0a             	cmp    $0xa,%esi
  80009c:	74 18                	je     8000b6 <umain+0x82>
			return;
		i++;
  80009e:	8d 5e 01             	lea    0x1(%esi),%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a9:	e8 cf 0e 00 00       	call   800f7d <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 b9                	jne    80006f <umain+0x3b>
			return;
	}

}
  8000b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000cb:	e8 6f 0b 00 00       	call   800c3f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	29 d0                	sub    %edx,%eax
  8000e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000eb:	85 f6                	test   %esi,%esi
  8000ed:	7e 07                	jle    8000f6 <libmain+0x36>
		binaryname = argv[0];
  8000ef:	8b 03                	mov    (%ebx),%eax
  8000f1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	53                   	push   %ebx
  8000fa:	56                   	push   %esi
  8000fb:	e8 34 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
  800105:	83 c4 10             	add    $0x10,%esp
}
  800108:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 41 0b 00 00       	call   800c5e <sys_env_destroy>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    
	...

00800124 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800134:	00 00 00 
	b.cnt = 0;
  800137:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80013e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	ff 75 08             	pushl  0x8(%ebp)
  800147:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014d:	50                   	push   %eax
  80014e:	68 8c 01 80 00       	push   $0x80018c
  800153:	e8 70 01 00 00       	call   8002c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	83 c4 08             	add    $0x8,%esp
  80015b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800161:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800167:	50                   	push   %eax
  800168:	e8 9e 08 00 00       	call   800a0b <sys_cputs>
  80016d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80017e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800181:	50                   	push   %eax
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	e8 9a ff ff ff       	call   800124 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80019f:	40                   	inc    %eax
  8001a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	75 1a                	jne    8001c3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	68 ff 00 00 00       	push   $0xff
  8001b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 51 08 00 00       	call   800a0b <sys_cputs>
		b->idx = 0;
  8001ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c3:	ff 43 04             	incl   0x4(%ebx)
}
  8001c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    
	...

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
  8001d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001d8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ed:	89 d6                	mov    %edx,%esi
  8001ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f4:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001f7:	72 04                	jb     8001fd <printnum+0x31>
  8001f9:	39 c2                	cmp    %eax,%edx
  8001fb:	77 3f                	ja     80023c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800206:	50                   	push   %eax
  800207:	52                   	push   %edx
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	e8 1c 0f 00 00       	call   801134 <__udivdi3>
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	52                   	push   %edx
  80021c:	50                   	push   %eax
  80021d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800220:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800223:	e8 a4 ff ff ff       	call   8001cc <printnum>
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	eb 14                	jmp    800241 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	ff 75 e8             	pushl  -0x18(%ebp)
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff 55 ec             	call   *-0x14(%ebp)
  800239:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023c:	4b                   	dec    %ebx
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	7f ec                	jg     80022d <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	ff 75 e8             	pushl  -0x18(%ebp)
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024f:	ff 75 e0             	pushl  -0x20(%ebp)
  800252:	e8 09 10 00 00       	call   801260 <__umoddi3>
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	0f be 80 13 14 80 00 	movsbl 0x801413(%eax),%eax
  800261:	50                   	push   %eax
  800262:	ff 55 ec             	call   *-0x14(%ebp)
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800275:	83 fa 01             	cmp    $0x1,%edx
  800278:	7e 0e                	jle    800288 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 42 08             	lea    0x8(%edx),%eax
  80027f:	89 01                	mov    %eax,(%ecx)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	8b 52 04             	mov    0x4(%edx),%edx
  800286:	eb 22                	jmp    8002aa <getuint+0x3a>
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 10                	je     80029c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 42 04             	lea    0x4(%edx),%eax
  800291:	89 01                	mov    %eax,(%ecx)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	eb 0e                	jmp    8002aa <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 42 04             	lea    0x4(%edx),%eax
  8002a1:	89 01                	mov    %eax,(%ecx)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002b2:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002b5:	8b 11                	mov    (%ecx),%edx
  8002b7:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002ba:	73 0a                	jae    8002c6 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
  8002c1:	8d 42 01             	lea    0x1(%edx),%eax
  8002c4:	89 01                	mov    %eax,(%ecx)
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 3c             	sub    $0x3c,%esp
  8002d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002da:	eb 1a                	jmp    8002f6 <vprintfmt+0x2e>
  8002dc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002df:	eb 15                	jmp    8002f6 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e1:	84 c0                	test   %al,%al
  8002e3:	0f 84 15 03 00 00    	je     8005fe <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	57                   	push   %edi
  8002ed:	0f b6 c0             	movzbl %al,%eax
  8002f0:	50                   	push   %eax
  8002f1:	ff d6                	call   *%esi
  8002f3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f6:	8a 03                	mov    (%ebx),%al
  8002f8:	43                   	inc    %ebx
  8002f9:	3c 25                	cmp    $0x25,%al
  8002fb:	75 e4                	jne    8002e1 <vprintfmt+0x19>
  8002fd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800304:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80030b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800312:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800319:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80031d:	eb 0a                	jmp    800329 <vprintfmt+0x61>
  80031f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800326:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8a 03                	mov    (%ebx),%al
  80032b:	0f b6 d0             	movzbl %al,%edx
  80032e:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800331:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800334:	83 e8 23             	sub    $0x23,%eax
  800337:	3c 55                	cmp    $0x55,%al
  800339:	0f 87 9c 02 00 00    	ja     8005db <vprintfmt+0x313>
  80033f:	0f b6 c0             	movzbl %al,%eax
  800342:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  800349:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80034d:	eb d7                	jmp    800326 <vprintfmt+0x5e>
  80034f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800353:	eb d1                	jmp    800326 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800355:	89 d9                	mov    %ebx,%ecx
  800357:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800361:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800364:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800368:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80036b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80036f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800370:	8d 42 d0             	lea    -0x30(%edx),%eax
  800373:	83 f8 09             	cmp    $0x9,%eax
  800376:	77 21                	ja     800399 <vprintfmt+0xd1>
  800378:	eb e4                	jmp    80035e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037a:	8b 55 14             	mov    0x14(%ebp),%edx
  80037d:	8d 42 04             	lea    0x4(%edx),%eax
  800380:	89 45 14             	mov    %eax,0x14(%ebp)
  800383:	8b 12                	mov    (%edx),%edx
  800385:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800388:	eb 12                	jmp    80039c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80038a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80038e:	79 96                	jns    800326 <vprintfmt+0x5e>
  800390:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800397:	eb 8d                	jmp    800326 <vprintfmt+0x5e>
  800399:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80039c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003a0:	79 84                	jns    800326 <vprintfmt+0x5e>
  8003a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003af:	e9 72 ff ff ff       	jmp    800326 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b4:	ff 45 d4             	incl   -0x2c(%ebp)
  8003b7:	e9 6a ff ff ff       	jmp    800326 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bf:	8d 42 04             	lea    0x4(%edx),%eax
  8003c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	57                   	push   %edi
  8003c9:	ff 32                	pushl  (%edx)
  8003cb:	ff d6                	call   *%esi
			break;
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	e9 07 ff ff ff       	jmp    8002dc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d5:	8b 55 14             	mov    0x14(%ebp),%edx
  8003d8:	8d 42 04             	lea    0x4(%edx),%eax
  8003db:	89 45 14             	mov    %eax,0x14(%ebp)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	79 02                	jns    8003e6 <vprintfmt+0x11e>
  8003e4:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x12e>
  8003eb:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 15                	jne    80040b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 24 14 80 00       	push   $0x801424
  8003fc:	57                   	push   %edi
  8003fd:	56                   	push   %esi
  8003fe:	e8 6e 02 00 00       	call   800671 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	e9 d1 fe ff ff       	jmp    8002dc <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80040b:	52                   	push   %edx
  80040c:	68 2d 14 80 00       	push   $0x80142d
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	e8 59 02 00 00       	call   800671 <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	e9 bc fe ff ff       	jmp    8002dc <vprintfmt+0x14>
  800420:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800423:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800426:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 55 14             	mov    0x14(%ebp),%edx
  80042c:	8d 42 04             	lea    0x4(%edx),%eax
  80042f:	89 45 14             	mov    %eax,0x14(%ebp)
  800432:	8b 1a                	mov    (%edx),%ebx
  800434:	85 db                	test   %ebx,%ebx
  800436:	75 05                	jne    80043d <vprintfmt+0x175>
  800438:	bb 30 14 80 00       	mov    $0x801430,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80043d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800441:	7e 66                	jle    8004a9 <vprintfmt+0x1e1>
  800443:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800447:	74 60                	je     8004a9 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	51                   	push   %ecx
  80044d:	53                   	push   %ebx
  80044e:	e8 57 02 00 00       	call   8006aa <strnlen>
  800453:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800456:	29 c1                	sub    %eax,%ecx
  800458:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800462:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800465:	eb 0f                	jmp    800476 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	57                   	push   %edi
  80046b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80046e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	ff 4d d8             	decl   -0x28(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047a:	7f eb                	jg     800467 <vprintfmt+0x19f>
  80047c:	eb 2b                	jmp    8004a9 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	74 15                	je     80049c <vprintfmt+0x1d4>
  800487:	8d 42 e0             	lea    -0x20(%edx),%eax
  80048a:	83 f8 5e             	cmp    $0x5e,%eax
  80048d:	76 0d                	jbe    80049c <vprintfmt+0x1d4>
					putch('?', putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	57                   	push   %edi
  800493:	6a 3f                	push   $0x3f
  800495:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	eb 0a                	jmp    8004a6 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	57                   	push   %edi
  8004a0:	52                   	push   %edx
  8004a1:	ff d6                	call   *%esi
  8004a3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	ff 4d d8             	decl   -0x28(%ebp)
  8004a9:	8a 03                	mov    (%ebx),%al
  8004ab:	43                   	inc    %ebx
  8004ac:	84 c0                	test   %al,%al
  8004ae:	74 1b                	je     8004cb <vprintfmt+0x203>
  8004b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b4:	78 c8                	js     80047e <vprintfmt+0x1b6>
  8004b6:	ff 4d dc             	decl   -0x24(%ebp)
  8004b9:	79 c3                	jns    80047e <vprintfmt+0x1b6>
  8004bb:	eb 0e                	jmp    8004cb <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	57                   	push   %edi
  8004c1:	6a 20                	push   $0x20
  8004c3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c5:	ff 4d d8             	decl   -0x28(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cf:	7f ec                	jg     8004bd <vprintfmt+0x1f5>
  8004d1:	e9 06 fe ff ff       	jmp    8002dc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004d6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004da:	7e 10                	jle    8004ec <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004dc:	8b 55 14             	mov    0x14(%ebp),%edx
  8004df:	8d 42 08             	lea    0x8(%edx),%eax
  8004e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e5:	8b 02                	mov    (%edx),%eax
  8004e7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ea:	eb 20                	jmp    80050c <vprintfmt+0x244>
	else if (lflag)
  8004ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f0:	74 0e                	je     800500 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	99                   	cltd   
  8004fe:	eb 0c                	jmp    80050c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80050c:	89 d1                	mov    %edx,%ecx
  80050e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800510:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800513:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800516:	85 c9                	test   %ecx,%ecx
  800518:	78 0a                	js     800524 <vprintfmt+0x25c>
  80051a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80051f:	e9 89 00 00 00       	jmp    8005ad <vprintfmt+0x2e5>
				putch('-', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	57                   	push   %edi
  800528:	6a 2d                	push   $0x2d
  80052a:	ff d6                	call   *%esi
				num = -(long long) num;
  80052c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80052f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800532:	f7 da                	neg    %edx
  800534:	83 d1 00             	adc    $0x0,%ecx
  800537:	f7 d9                	neg    %ecx
  800539:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	eb 6a                	jmp    8005ad <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800543:	8d 45 14             	lea    0x14(%ebp),%eax
  800546:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800549:	e8 22 fd ff ff       	call   800270 <getuint>
  80054e:	89 d1                	mov    %edx,%ecx
  800550:	89 c2                	mov    %eax,%edx
  800552:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800557:	eb 54                	jmp    8005ad <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800559:	8d 45 14             	lea    0x14(%ebp),%eax
  80055c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80055f:	e8 0c fd ff ff       	call   800270 <getuint>
  800564:	89 d1                	mov    %edx,%ecx
  800566:	89 c2                	mov    %eax,%edx
  800568:	bb 08 00 00 00       	mov    $0x8,%ebx
  80056d:	eb 3e                	jmp    8005ad <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	57                   	push   %edi
  800573:	6a 30                	push   $0x30
  800575:	ff d6                	call   *%esi
			putch('x', putdat);
  800577:	83 c4 08             	add    $0x8,%esp
  80057a:	57                   	push   %edi
  80057b:	6a 78                	push   $0x78
  80057d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80057f:	8b 55 14             	mov    0x14(%ebp),%edx
  800582:	8d 42 04             	lea    0x4(%edx),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	8b 12                	mov    (%edx),%edx
  80058a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	eb 14                	jmp    8005ad <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80059f:	e8 cc fc ff ff       	call   800270 <getuint>
  8005a4:	89 d1                	mov    %edx,%ecx
  8005a6:	89 c2                	mov    %eax,%edx
  8005a8:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ad:	83 ec 0c             	sub    $0xc,%esp
  8005b0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005b4:	50                   	push   %eax
  8005b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b8:	53                   	push   %ebx
  8005b9:	51                   	push   %ecx
  8005ba:	52                   	push   %edx
  8005bb:	89 fa                	mov    %edi,%edx
  8005bd:	89 f0                	mov    %esi,%eax
  8005bf:	e8 08 fc ff ff       	call   8001cc <printnum>
			break;
  8005c4:	83 c4 20             	add    $0x20,%esp
  8005c7:	e9 10 fd ff ff       	jmp    8002dc <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	57                   	push   %edi
  8005d0:	52                   	push   %edx
  8005d1:	ff d6                	call   *%esi
			break;
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	e9 01 fd ff ff       	jmp    8002dc <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 25                	push   $0x25
  8005e1:	ff d6                	call   *%esi
  8005e3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005e6:	83 ea 02             	sub    $0x2,%edx
  8005e9:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ec:	8a 02                	mov    (%edx),%al
  8005ee:	4a                   	dec    %edx
  8005ef:	3c 25                	cmp    $0x25,%al
  8005f1:	75 f9                	jne    8005ec <vprintfmt+0x324>
  8005f3:	83 c2 02             	add    $0x2,%edx
  8005f6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005f9:	e9 de fc ff ff       	jmp    8002dc <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800601:	5b                   	pop    %ebx
  800602:	5e                   	pop    %esi
  800603:	5f                   	pop    %edi
  800604:	c9                   	leave  
  800605:	c3                   	ret    

00800606 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	83 ec 18             	sub    $0x18,%esp
  80060c:	8b 55 08             	mov    0x8(%ebp),%edx
  80060f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800612:	85 d2                	test   %edx,%edx
  800614:	74 37                	je     80064d <vsnprintf+0x47>
  800616:	85 c0                	test   %eax,%eax
  800618:	7e 33                	jle    80064d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80061a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800621:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800625:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800628:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80062b:	ff 75 14             	pushl  0x14(%ebp)
  80062e:	ff 75 10             	pushl  0x10(%ebp)
  800631:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	68 ac 02 80 00       	push   $0x8002ac
  80063a:	e8 89 fc ff ff       	call   8002c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80063f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800642:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800645:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb 05                	jmp    800652 <vsnprintf+0x4c>
  80064d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800652:	c9                   	leave  
  800653:	c3                   	ret    

00800654 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800660:	50                   	push   %eax
  800661:	ff 75 10             	pushl  0x10(%ebp)
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	ff 75 08             	pushl  0x8(%ebp)
  80066a:	e8 97 ff ff ff       	call   800606 <vsnprintf>
	va_end(ap);

	return rc;
}
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80067d:	50                   	push   %eax
  80067e:	ff 75 10             	pushl  0x10(%ebp)
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	ff 75 08             	pushl  0x8(%ebp)
  800687:	e8 3c fc ff ff       	call   8002c8 <vprintfmt>
	va_end(ap);
  80068c:	83 c4 10             	add    $0x10,%esp
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    
  800691:	00 00                	add    %al,(%eax)
	...

00800694 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	8b 55 08             	mov    0x8(%ebp),%edx
  80069a:	b8 00 00 00 00       	mov    $0x0,%eax
  80069f:	eb 01                	jmp    8006a2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006a6:	75 f9                	jne    8006a1 <strlen+0xd>
		n++;
	return n;
}
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b8:	eb 01                	jmp    8006bb <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8006ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006bb:	39 d0                	cmp    %edx,%eax
  8006bd:	74 06                	je     8006c5 <strnlen+0x1b>
  8006bf:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8006c3:	75 f5                	jne    8006ba <strnlen+0x10>
		n++;
	return n;
}
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d0:	8a 01                	mov    (%ecx),%al
  8006d2:	88 02                	mov    %al,(%edx)
  8006d4:	42                   	inc    %edx
  8006d5:	41                   	inc    %ecx
  8006d6:	84 c0                	test   %al,%al
  8006d8:	75 f6                	jne    8006d0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	53                   	push   %ebx
  8006e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006e6:	53                   	push   %ebx
  8006e7:	e8 a8 ff ff ff       	call   800694 <strlen>
	strcpy(dst + len, src);
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006f2:	50                   	push   %eax
  8006f3:	e8 cf ff ff ff       	call   8006c7 <strcpy>
	return dst;
}
  8006f8:	89 d8                	mov    %ebx,%eax
  8006fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	8b 75 08             	mov    0x8(%ebp),%esi
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80070d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800712:	eb 0c                	jmp    800720 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800714:	8a 02                	mov    (%edx),%al
  800716:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800719:	80 3a 01             	cmpb   $0x1,(%edx)
  80071c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80071f:	41                   	inc    %ecx
  800720:	39 d9                	cmp    %ebx,%ecx
  800722:	75 f0                	jne    800714 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800724:	89 f0                	mov    %esi,%eax
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	56                   	push   %esi
  80072e:	53                   	push   %ebx
  80072f:	8b 75 08             	mov    0x8(%ebp),%esi
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800735:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800738:	85 c9                	test   %ecx,%ecx
  80073a:	75 04                	jne    800740 <strlcpy+0x16>
  80073c:	89 f0                	mov    %esi,%eax
  80073e:	eb 14                	jmp    800754 <strlcpy+0x2a>
  800740:	89 f0                	mov    %esi,%eax
  800742:	eb 04                	jmp    800748 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800744:	88 10                	mov    %dl,(%eax)
  800746:	40                   	inc    %eax
  800747:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800748:	49                   	dec    %ecx
  800749:	74 06                	je     800751 <strlcpy+0x27>
  80074b:	8a 13                	mov    (%ebx),%dl
  80074d:	84 d2                	test   %dl,%dl
  80074f:	75 f3                	jne    800744 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800751:	c6 00 00             	movb   $0x0,(%eax)
  800754:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 55 08             	mov    0x8(%ebp),%edx
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	eb 02                	jmp    800767 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800765:	42                   	inc    %edx
  800766:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800767:	8a 02                	mov    (%edx),%al
  800769:	84 c0                	test   %al,%al
  80076b:	74 04                	je     800771 <strcmp+0x17>
  80076d:	3a 01                	cmp    (%ecx),%al
  80076f:	74 f4                	je     800765 <strcmp+0xb>
  800771:	0f b6 c0             	movzbl %al,%eax
  800774:	0f b6 11             	movzbl (%ecx),%edx
  800777:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	8b 55 10             	mov    0x10(%ebp),%edx
  800788:	eb 03                	jmp    80078d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80078a:	4a                   	dec    %edx
  80078b:	41                   	inc    %ecx
  80078c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80078d:	85 d2                	test   %edx,%edx
  80078f:	75 07                	jne    800798 <strncmp+0x1d>
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	eb 14                	jmp    8007ac <strncmp+0x31>
  800798:	8a 01                	mov    (%ecx),%al
  80079a:	84 c0                	test   %al,%al
  80079c:	74 04                	je     8007a2 <strncmp+0x27>
  80079e:	3a 03                	cmp    (%ebx),%al
  8007a0:	74 e8                	je     80078a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a2:	0f b6 d0             	movzbl %al,%edx
  8007a5:	0f b6 03             	movzbl (%ebx),%eax
  8007a8:	29 c2                	sub    %eax,%edx
  8007aa:	89 d0                	mov    %edx,%eax
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007b8:	eb 05                	jmp    8007bf <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8007ba:	38 ca                	cmp    %cl,%dl
  8007bc:	74 0c                	je     8007ca <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007be:	40                   	inc    %eax
  8007bf:	8a 10                	mov    (%eax),%dl
  8007c1:	84 d2                	test   %dl,%dl
  8007c3:	75 f5                	jne    8007ba <strchr+0xb>
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007d5:	eb 05                	jmp    8007dc <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007d7:	38 ca                	cmp    %cl,%dl
  8007d9:	74 07                	je     8007e2 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007db:	40                   	inc    %eax
  8007dc:	8a 10                	mov    (%eax),%dl
  8007de:	84 d2                	test   %dl,%dl
  8007e0:	75 f5                	jne    8007d7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	57                   	push   %edi
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007f3:	85 db                	test   %ebx,%ebx
  8007f5:	74 36                	je     80082d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007fd:	75 29                	jne    800828 <memset+0x44>
  8007ff:	f6 c3 03             	test   $0x3,%bl
  800802:	75 24                	jne    800828 <memset+0x44>
		c &= 0xFF;
  800804:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800807:	89 d6                	mov    %edx,%esi
  800809:	c1 e6 08             	shl    $0x8,%esi
  80080c:	89 d0                	mov    %edx,%eax
  80080e:	c1 e0 18             	shl    $0x18,%eax
  800811:	89 d1                	mov    %edx,%ecx
  800813:	c1 e1 10             	shl    $0x10,%ecx
  800816:	09 c8                	or     %ecx,%eax
  800818:	09 c2                	or     %eax,%edx
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	09 d0                	or     %edx,%eax
  80081e:	89 d9                	mov    %ebx,%ecx
  800820:	c1 e9 02             	shr    $0x2,%ecx
  800823:	fc                   	cld    
  800824:	f3 ab                	rep stos %eax,%es:(%edi)
  800826:	eb 05                	jmp    80082d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800828:	89 d9                	mov    %ebx,%ecx
  80082a:	fc                   	cld    
  80082b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80082d:	89 f8                	mov    %edi,%eax
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5f                   	pop    %edi
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	57                   	push   %edi
  800838:	56                   	push   %esi
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80083f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800842:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800844:	39 c6                	cmp    %eax,%esi
  800846:	73 36                	jae    80087e <memmove+0x4a>
  800848:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80084b:	39 d0                	cmp    %edx,%eax
  80084d:	73 2f                	jae    80087e <memmove+0x4a>
		s += n;
		d += n;
  80084f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800852:	f6 c2 03             	test   $0x3,%dl
  800855:	75 1b                	jne    800872 <memmove+0x3e>
  800857:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80085d:	75 13                	jne    800872 <memmove+0x3e>
  80085f:	f6 c1 03             	test   $0x3,%cl
  800862:	75 0e                	jne    800872 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800864:	8d 7e fc             	lea    -0x4(%esi),%edi
  800867:	8d 72 fc             	lea    -0x4(%edx),%esi
  80086a:	c1 e9 02             	shr    $0x2,%ecx
  80086d:	fd                   	std    
  80086e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800870:	eb 09                	jmp    80087b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800872:	8d 7e ff             	lea    -0x1(%esi),%edi
  800875:	8d 72 ff             	lea    -0x1(%edx),%esi
  800878:	fd                   	std    
  800879:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80087b:	fc                   	cld    
  80087c:	eb 20                	jmp    80089e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800884:	75 15                	jne    80089b <memmove+0x67>
  800886:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088c:	75 0d                	jne    80089b <memmove+0x67>
  80088e:	f6 c1 03             	test   $0x3,%cl
  800891:	75 08                	jne    80089b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800893:	c1 e9 02             	shr    $0x2,%ecx
  800896:	fc                   	cld    
  800897:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800899:	eb 03                	jmp    80089e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80089b:	fc                   	cld    
  80089c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008a5:	ff 75 10             	pushl  0x10(%ebp)
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	e8 81 ff ff ff       	call   800834 <memmove>
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	83 ec 04             	sub    $0x4,%esp
  8008bc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	eb 1b                	jmp    8008e2 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008c7:	8a 1a                	mov    (%edx),%bl
  8008c9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008cc:	8a 19                	mov    (%ecx),%bl
  8008ce:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008d1:	74 0d                	je     8008e0 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008d3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008d7:	0f b6 c3             	movzbl %bl,%eax
  8008da:	29 c2                	sub    %eax,%edx
  8008dc:	89 d0                	mov    %edx,%eax
  8008de:	eb 0d                	jmp    8008ed <memcmp+0x38>
		s1++, s2++;
  8008e0:	42                   	inc    %edx
  8008e1:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e2:	48                   	dec    %eax
  8008e3:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008e6:	75 df                	jne    8008c7 <memcmp+0x12>
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008ed:	83 c4 04             	add    $0x4,%esp
  8008f0:	5b                   	pop    %ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	03 55 10             	add    0x10(%ebp),%edx
  800901:	eb 05                	jmp    800908 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800903:	38 08                	cmp    %cl,(%eax)
  800905:	74 05                	je     80090c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800907:	40                   	inc    %eax
  800908:	39 d0                	cmp    %edx,%eax
  80090a:	72 f7                	jb     800903 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	57                   	push   %edi
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	83 ec 04             	sub    $0x4,%esp
  800917:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091a:	8b 75 10             	mov    0x10(%ebp),%esi
  80091d:	eb 01                	jmp    800920 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80091f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800920:	8a 01                	mov    (%ecx),%al
  800922:	3c 20                	cmp    $0x20,%al
  800924:	74 f9                	je     80091f <strtol+0x11>
  800926:	3c 09                	cmp    $0x9,%al
  800928:	74 f5                	je     80091f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  80092a:	3c 2b                	cmp    $0x2b,%al
  80092c:	75 0a                	jne    800938 <strtol+0x2a>
		s++;
  80092e:	41                   	inc    %ecx
  80092f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800936:	eb 17                	jmp    80094f <strtol+0x41>
	else if (*s == '-')
  800938:	3c 2d                	cmp    $0x2d,%al
  80093a:	74 09                	je     800945 <strtol+0x37>
  80093c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800943:	eb 0a                	jmp    80094f <strtol+0x41>
		s++, neg = 1;
  800945:	8d 49 01             	lea    0x1(%ecx),%ecx
  800948:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094f:	85 f6                	test   %esi,%esi
  800951:	74 05                	je     800958 <strtol+0x4a>
  800953:	83 fe 10             	cmp    $0x10,%esi
  800956:	75 1a                	jne    800972 <strtol+0x64>
  800958:	8a 01                	mov    (%ecx),%al
  80095a:	3c 30                	cmp    $0x30,%al
  80095c:	75 10                	jne    80096e <strtol+0x60>
  80095e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800962:	75 0a                	jne    80096e <strtol+0x60>
		s += 2, base = 16;
  800964:	83 c1 02             	add    $0x2,%ecx
  800967:	be 10 00 00 00       	mov    $0x10,%esi
  80096c:	eb 04                	jmp    800972 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80096e:	85 f6                	test   %esi,%esi
  800970:	74 07                	je     800979 <strtol+0x6b>
  800972:	bf 00 00 00 00       	mov    $0x0,%edi
  800977:	eb 13                	jmp    80098c <strtol+0x7e>
  800979:	3c 30                	cmp    $0x30,%al
  80097b:	74 07                	je     800984 <strtol+0x76>
  80097d:	be 0a 00 00 00       	mov    $0xa,%esi
  800982:	eb ee                	jmp    800972 <strtol+0x64>
		s++, base = 8;
  800984:	41                   	inc    %ecx
  800985:	be 08 00 00 00       	mov    $0x8,%esi
  80098a:	eb e6                	jmp    800972 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80098c:	8a 11                	mov    (%ecx),%dl
  80098e:	88 d3                	mov    %dl,%bl
  800990:	8d 42 d0             	lea    -0x30(%edx),%eax
  800993:	3c 09                	cmp    $0x9,%al
  800995:	77 08                	ja     80099f <strtol+0x91>
			dig = *s - '0';
  800997:	0f be c2             	movsbl %dl,%eax
  80099a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80099d:	eb 1c                	jmp    8009bb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80099f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009a2:	3c 19                	cmp    $0x19,%al
  8009a4:	77 08                	ja     8009ae <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009a6:	0f be c2             	movsbl %dl,%eax
  8009a9:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009ac:	eb 0d                	jmp    8009bb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ae:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009b1:	3c 19                	cmp    $0x19,%al
  8009b3:	77 15                	ja     8009ca <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009b5:	0f be c2             	movsbl %dl,%eax
  8009b8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8009bb:	39 f2                	cmp    %esi,%edx
  8009bd:	7d 0b                	jge    8009ca <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009bf:	41                   	inc    %ecx
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	0f af c6             	imul   %esi,%eax
  8009c5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009c8:	eb c2                	jmp    80098c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009ca:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009d0:	74 05                	je     8009d7 <strtol+0xc9>
		*endptr = (char *) s;
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009db:	74 04                	je     8009e1 <strtol+0xd3>
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	f7 df                	neg    %edi
}
  8009e1:	89 f8                	mov    %edi,%eax
  8009e3:	83 c4 04             	add    $0x4,%esp
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    
	...

008009ec <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fc:	89 fa                	mov    %edi,%edx
  8009fe:	89 f9                	mov    %edi,%ecx
  800a00:	89 fb                	mov    %edi,%ebx
  800a02:	89 fe                	mov    %edi,%esi
  800a04:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	83 ec 04             	sub    $0x4,%esp
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	89 fb                	mov    %edi,%ebx
  800a23:	89 fe                	mov    %edi,%esi
  800a25:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a27:	83 c4 04             	add    $0x4,%esp
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	83 ec 0c             	sub    $0xc,%esp
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
  800a45:	89 f9                	mov    %edi,%ecx
  800a47:	89 fb                	mov    %edi,%ebx
  800a49:	89 fe                	mov    %edi,%esi
  800a4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	7e 17                	jle    800a68 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a51:	83 ec 0c             	sub    $0xc,%esp
  800a54:	50                   	push   %eax
  800a55:	6a 0d                	push   $0xd
  800a57:	68 1f 17 80 00       	push   $0x80171f
  800a5c:	6a 23                	push   $0x23
  800a5e:	68 3c 17 80 00       	push   $0x80173c
  800a63:	e8 d4 05 00 00       	call   80103c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 55 08             	mov    0x8(%ebp),%edx
  800a79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a7f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a87:	be 00 00 00 00       	mov    $0x0,%esi
  800a8c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	89 fb                	mov    %edi,%ebx
  800aae:	89 fe                	mov    %edi,%esi
  800ab0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	7e 17                	jle    800acd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	50                   	push   %eax
  800aba:	6a 0a                	push   $0xa
  800abc:	68 1f 17 80 00       	push   $0x80171f
  800ac1:	6a 23                	push   $0x23
  800ac3:	68 3c 17 80 00       	push   $0x80173c
  800ac8:	e8 6f 05 00 00       	call   80103c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800acd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    

00800ad5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ae9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aee:	89 fb                	mov    %edi,%ebx
  800af0:	89 fe                	mov    %edi,%esi
  800af2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af4:	85 c0                	test   %eax,%eax
  800af6:	7e 17                	jle    800b0f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af8:	83 ec 0c             	sub    $0xc,%esp
  800afb:	50                   	push   %eax
  800afc:	6a 09                	push   $0x9
  800afe:	68 1f 17 80 00       	push   $0x80171f
  800b03:	6a 23                	push   $0x23
  800b05:	68 3c 17 80 00       	push   $0x80173c
  800b0a:	e8 2d 05 00 00       	call   80103c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	c9                   	leave  
  800b16:	c3                   	ret    

00800b17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b30:	89 fb                	mov    %edi,%ebx
  800b32:	89 fe                	mov    %edi,%esi
  800b34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b36:	85 c0                	test   %eax,%eax
  800b38:	7e 17                	jle    800b51 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	50                   	push   %eax
  800b3e:	6a 08                	push   $0x8
  800b40:	68 1f 17 80 00       	push   $0x80171f
  800b45:	6a 23                	push   $0x23
  800b47:	68 3c 17 80 00       	push   $0x80173c
  800b4c:	e8 eb 04 00 00       	call   80103c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b8 06 00 00 00       	mov    $0x6,%eax
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b72:	89 fb                	mov    %edi,%ebx
  800b74:	89 fe                	mov    %edi,%esi
  800b76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 17                	jle    800b93 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 06                	push   $0x6
  800b82:	68 1f 17 80 00       	push   $0x80171f
  800b87:	6a 23                	push   $0x23
  800b89:	68 3c 17 80 00       	push   $0x80173c
  800b8e:	e8 a9 04 00 00       	call   80103c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 05                	push   $0x5
  800bc4:	68 1f 17 80 00       	push   $0x80171f
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 3c 17 80 00       	push   $0x80173c
  800bd0:	e8 67 04 00 00       	call   80103c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf9:	89 fe                	mov    %edi,%esi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 04                	push   $0x4
  800c07:	68 1f 17 80 00       	push   $0x80171f
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 3c 17 80 00       	push   $0x80173c
  800c13:	e8 24 04 00 00       	call   80103c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c30:	89 fa                	mov    %edi,%edx
  800c32:	89 f9                	mov    %edi,%ecx
  800c34:	89 fb                	mov    %edi,%ebx
  800c36:	89 fe                	mov    %edi,%esi
  800c38:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	89 fa                	mov    %edi,%edx
  800c51:	89 f9                	mov    %edi,%ecx
  800c53:	89 fb                	mov    %edi,%ebx
  800c55:	89 fe                	mov    %edi,%esi
  800c57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c74:	89 f9                	mov    %edi,%ecx
  800c76:	89 fb                	mov    %edi,%ebx
  800c78:	89 fe                	mov    %edi,%esi
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 03                	push   $0x3
  800c86:	68 1f 17 80 00       	push   $0x80171f
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 3c 17 80 00       	push   $0x80173c
  800c92:	e8 a5 03 00 00       	call   80103c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    
	...

00800ca0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ca6:	68 4a 17 80 00       	push   $0x80174a
  800cab:	68 92 00 00 00       	push   $0x92
  800cb0:	68 60 17 80 00       	push   $0x801760
  800cb5:	e8 82 03 00 00       	call   80103c <_panic>

00800cba <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800cc3:	68 5b 0e 80 00       	push   $0x800e5b
  800cc8:	e8 bf 03 00 00       	call   80108c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ccd:	ba 07 00 00 00       	mov    $0x7,%edx
  800cd2:	89 d0                	mov    %edx,%eax
  800cd4:	cd 30                	int    $0x30
  800cd6:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	75 25                	jne    800d04 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800cdf:	e8 5b ff ff ff       	call   800c3f <sys_getenvid>
  800ce4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ce9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800cf0:	c1 e0 07             	shl    $0x7,%eax
  800cf3:	29 d0                	sub    %edx,%eax
  800cf5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800cfa:	a3 04 20 80 00       	mov    %eax,0x802004
  800cff:	e9 4d 01 00 00       	jmp    800e51 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800d04:	85 c0                	test   %eax,%eax
  800d06:	79 12                	jns    800d1a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d08:	50                   	push   %eax
  800d09:	68 6b 17 80 00       	push   $0x80176b
  800d0e:	6a 77                	push   $0x77
  800d10:	68 60 17 80 00       	push   $0x801760
  800d15:	e8 22 03 00 00       	call   80103c <_panic>
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800d1f:	89 d8                	mov    %ebx,%eax
  800d21:	c1 e8 16             	shr    $0x16,%eax
  800d24:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d2b:	a8 01                	test   $0x1,%al
  800d2d:	0f 84 ab 00 00 00    	je     800dde <fork+0x124>
  800d33:	89 da                	mov    %ebx,%edx
  800d35:	c1 ea 0c             	shr    $0xc,%edx
  800d38:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d3f:	a8 01                	test   $0x1,%al
  800d41:	0f 84 97 00 00 00    	je     800dde <fork+0x124>
  800d47:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d4e:	a8 04                	test   $0x4,%al
  800d50:	0f 84 88 00 00 00    	je     800dde <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800d56:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800d6a:	a9 02 08 00 00       	test   $0x802,%eax
  800d6f:	74 0f                	je     800d80 <fork+0xc6>
  800d71:	f6 c4 04             	test   $0x4,%ah
  800d74:	75 0a                	jne    800d80 <fork+0xc6>
		perm &= ~PTE_W;
  800d76:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800d80:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	52                   	push   %edx
  800d8d:	56                   	push   %esi
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	6a 00                	push   $0x0
  800d92:	e8 04 fe ff ff       	call   800b9b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800d97:	83 c4 20             	add    $0x20,%esp
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	79 14                	jns    800db2 <fork+0xf8>
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 b4 17 80 00       	push   $0x8017b4
  800da6:	6a 52                	push   $0x52
  800da8:	68 60 17 80 00       	push   $0x801760
  800dad:	e8 8a 02 00 00       	call   80103c <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800db2:	83 ec 0c             	sub    $0xc,%esp
  800db5:	ff 75 f0             	pushl  -0x10(%ebp)
  800db8:	56                   	push   %esi
  800db9:	6a 00                	push   $0x0
  800dbb:	56                   	push   %esi
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 d8 fd ff ff       	call   800b9b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800dc3:	83 c4 20             	add    $0x20,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	79 14                	jns    800dde <fork+0x124>
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 d8 17 80 00       	push   $0x8017d8
  800dd2:	6a 55                	push   $0x55
  800dd4:	68 60 17 80 00       	push   $0x801760
  800dd9:	e8 5e 02 00 00       	call   80103c <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800dde:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800de4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800dea:	0f 85 2f ff ff ff    	jne    800d1f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	6a 07                	push   $0x7
  800df5:	68 00 f0 bf ee       	push   $0xeebff000
  800dfa:	57                   	push   %edi
  800dfb:	e8 dd fd ff ff       	call   800bdd <sys_page_alloc>
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 15                	jns    800e1c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800e07:	50                   	push   %eax
  800e08:	68 89 17 80 00       	push   $0x801789
  800e0d:	68 83 00 00 00       	push   $0x83
  800e12:	68 60 17 80 00       	push   $0x801760
  800e17:	e8 20 02 00 00       	call   80103c <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800e1c:	83 ec 08             	sub    $0x8,%esp
  800e1f:	68 0c 11 80 00       	push   $0x80110c
  800e24:	57                   	push   %edi
  800e25:	e8 69 fc ff ff       	call   800a93 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800e2a:	83 c4 08             	add    $0x8,%esp
  800e2d:	6a 02                	push   $0x2
  800e2f:	57                   	push   %edi
  800e30:	e8 e2 fc ff ff       	call   800b17 <sys_env_set_status>
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	79 15                	jns    800e51 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800e3c:	50                   	push   %eax
  800e3d:	68 9c 17 80 00       	push   $0x80179c
  800e42:	68 89 00 00 00       	push   $0x89
  800e47:	68 60 17 80 00       	push   $0x801760
  800e4c:	e8 eb 01 00 00       	call   80103c <_panic>
	return envid;
	//panic("fork not implemented");
}
  800e51:	89 f8                	mov    %edi,%eax
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800e65:	8b 1a                	mov    (%edx),%ebx
  800e67:	89 d8                	mov    %ebx,%eax
  800e69:	c1 e8 0c             	shr    $0xc,%eax
  800e6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800e73:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e77:	74 05                	je     800e7e <pgfault+0x23>
  800e79:	f6 c4 08             	test   $0x8,%ah
  800e7c:	75 14                	jne    800e92 <pgfault+0x37>
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	68 fc 17 80 00       	push   $0x8017fc
  800e86:	6a 1e                	push   $0x1e
  800e88:	68 60 17 80 00       	push   $0x801760
  800e8d:	e8 aa 01 00 00       	call   80103c <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	6a 07                	push   $0x7
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 3a fd ff ff       	call   800bdd <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	79 14                	jns    800ebe <pgfault+0x63>
  800eaa:	83 ec 04             	sub    $0x4,%esp
  800ead:	68 28 18 80 00       	push   $0x801828
  800eb2:	6a 2a                	push   $0x2a
  800eb4:	68 60 17 80 00       	push   $0x801760
  800eb9:	e8 7e 01 00 00       	call   80103c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800ebe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800ec4:	83 ec 04             	sub    $0x4,%esp
  800ec7:	68 00 10 00 00       	push   $0x1000
  800ecc:	53                   	push   %ebx
  800ecd:	68 00 f0 7f 00       	push   $0x7ff000
  800ed2:	e8 5d f9 ff ff       	call   800834 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800ed7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ede:	53                   	push   %ebx
  800edf:	6a 00                	push   $0x0
  800ee1:	68 00 f0 7f 00       	push   $0x7ff000
  800ee6:	6a 00                	push   $0x0
  800ee8:	e8 ae fc ff ff       	call   800b9b <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800eed:	83 c4 20             	add    $0x20,%esp
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	79 14                	jns    800f08 <pgfault+0xad>
  800ef4:	83 ec 04             	sub    $0x4,%esp
  800ef7:	68 4c 18 80 00       	push   $0x80184c
  800efc:	6a 2e                	push   $0x2e
  800efe:	68 60 17 80 00       	push   $0x801760
  800f03:	e8 34 01 00 00       	call   80103c <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	68 00 f0 7f 00       	push   $0x7ff000
  800f10:	6a 00                	push   $0x0
  800f12:	e8 42 fc ff ff       	call   800b59 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800f17:	83 c4 10             	add    $0x10,%esp
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 14                	jns    800f32 <pgfault+0xd7>
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	68 6c 18 80 00       	push   $0x80186c
  800f26:	6a 32                	push   $0x32
  800f28:	68 60 17 80 00       	push   $0x801760
  800f2d:	e8 0a 01 00 00       	call   80103c <_panic>
	//panic("pgfault not implemented");
}
  800f32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    
	...

00800f38 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	53                   	push   %ebx
  800f3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f3f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800f44:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  800f4b:	89 c8                	mov    %ecx,%eax
  800f4d:	c1 e0 07             	shl    $0x7,%eax
  800f50:	29 d0                	sub    %edx,%eax
  800f52:	89 c2                	mov    %eax,%edx
  800f54:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  800f5a:	8b 40 50             	mov    0x50(%eax),%eax
  800f5d:	39 d8                	cmp    %ebx,%eax
  800f5f:	75 0b                	jne    800f6c <ipc_find_env+0x34>
			return envs[i].env_id;
  800f61:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  800f67:	8b 40 40             	mov    0x40(%eax),%eax
  800f6a:	eb 0e                	jmp    800f7a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f6c:	41                   	inc    %ecx
  800f6d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  800f73:	75 cf                	jne    800f44 <ipc_find_env+0xc>
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	57                   	push   %edi
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800f8f:	85 db                	test   %ebx,%ebx
  800f91:	75 05                	jne    800f98 <ipc_send+0x1b>
  800f93:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	57                   	push   %edi
  800f9b:	ff 75 08             	pushl  0x8(%ebp)
  800f9e:	e8 cd fa ff ff       	call   800a70 <sys_ipc_try_send>
		if (r == 0) {		//success
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	74 20                	je     800fca <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  800faa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800fad:	75 07                	jne    800fb6 <ipc_send+0x39>
			sys_yield();
  800faf:	e8 6c fc ff ff       	call   800c20 <sys_yield>
  800fb4:	eb e2                	jmp    800f98 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 90 18 80 00       	push   $0x801890
  800fbe:	6a 41                	push   $0x41
  800fc0:	68 b3 18 80 00       	push   $0x8018b3
  800fc5:	e8 72 00 00 00       	call   80103c <_panic>
		}
	}
}
  800fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5f                   	pop    %edi
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	75 05                	jne    800fe9 <ipc_recv+0x17>
  800fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	50                   	push   %eax
  800fed:	e8 3d fa ff ff       	call   800a2f <sys_ipc_recv>
	if (r < 0) {				
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 16                	jns    80100f <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  800ff9:	85 db                	test   %ebx,%ebx
  800ffb:	74 06                	je     801003 <ipc_recv+0x31>
  800ffd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801003:	85 f6                	test   %esi,%esi
  801005:	74 2c                	je     801033 <ipc_recv+0x61>
  801007:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80100d:	eb 24                	jmp    801033 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  80100f:	85 db                	test   %ebx,%ebx
  801011:	74 0a                	je     80101d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801013:	a1 04 20 80 00       	mov    0x802004,%eax
  801018:	8b 40 74             	mov    0x74(%eax),%eax
  80101b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  80101d:	85 f6                	test   %esi,%esi
  80101f:	74 0a                	je     80102b <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801021:	a1 04 20 80 00       	mov    0x802004,%eax
  801026:	8b 40 78             	mov    0x78(%eax),%eax
  801029:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80102b:	a1 04 20 80 00       	mov    0x802004,%eax
  801030:	8b 40 70             	mov    0x70(%eax),%eax
}
  801033:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	c9                   	leave  
  801039:	c3                   	ret    
	...

0080103c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	53                   	push   %ebx
  801040:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  801043:	8d 45 14             	lea    0x14(%ebp),%eax
  801046:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801049:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80104f:	e8 eb fb ff ff       	call   800c3f <sys_getenvid>
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	53                   	push   %ebx
  80105e:	50                   	push   %eax
  80105f:	68 c0 18 80 00       	push   $0x8018c0
  801064:	e8 0c f1 ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801069:	83 c4 18             	add    $0x18,%esp
  80106c:	ff 75 f8             	pushl  -0x8(%ebp)
  80106f:	ff 75 10             	pushl  0x10(%ebp)
  801072:	e8 ad f0 ff ff       	call   800124 <vcprintf>
	cprintf("\n");
  801077:	c7 04 24 87 17 80 00 	movl   $0x801787,(%esp)
  80107e:	e8 f2 f0 ff ff       	call   800175 <cprintf>
  801083:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801086:	cc                   	int3   
  801087:	eb fd                	jmp    801086 <_panic+0x4a>
  801089:	00 00                	add    %al,(%eax)
	...

0080108c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801092:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801099:	75 64                	jne    8010ff <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  80109b:	a1 04 20 80 00       	mov    0x802004,%eax
  8010a0:	8b 40 48             	mov    0x48(%eax),%eax
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	6a 07                	push   $0x7
  8010a8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ad:	50                   	push   %eax
  8010ae:	e8 2a fb ff ff       	call   800bdd <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 14                	jns    8010ce <set_pgfault_handler+0x42>
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	68 e4 18 80 00       	push   $0x8018e4
  8010c2:	6a 22                	push   $0x22
  8010c4:	68 50 19 80 00       	push   $0x801950
  8010c9:	e8 6e ff ff ff       	call   80103c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  8010ce:	a1 04 20 80 00       	mov    0x802004,%eax
  8010d3:	8b 40 48             	mov    0x48(%eax),%eax
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	68 0c 11 80 00       	push   $0x80110c
  8010de:	50                   	push   %eax
  8010df:	e8 af f9 ff ff       	call   800a93 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 14                	jns    8010ff <set_pgfault_handler+0x73>
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 14 19 80 00       	push   $0x801914
  8010f3:	6a 25                	push   $0x25
  8010f5:	68 50 19 80 00       	push   $0x801950
  8010fa:	e8 3d ff ff ff       	call   80103c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    
  801109:	00 00                	add    %al,(%eax)
	...

0080110c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80110c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80110d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801112:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801114:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801117:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80111b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80111e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801122:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801126:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801128:	83 c4 08             	add    $0x8,%esp
	popal
  80112b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80112c:	83 c4 04             	add    $0x4,%esp
	popfl
  80112f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801130:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801131:	c3                   	ret    
	...

00801134 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	83 ec 28             	sub    $0x28,%esp
  80113c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801143:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80114a:	8b 45 10             	mov    0x10(%ebp),%eax
  80114d:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801150:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801153:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801155:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801157:	8b 45 08             	mov    0x8(%ebp),%eax
  80115a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  80115d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801160:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801163:	85 ff                	test   %edi,%edi
  801165:	75 21                	jne    801188 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801167:	39 d1                	cmp    %edx,%ecx
  801169:	76 49                	jbe    8011b4 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80116b:	f7 f1                	div    %ecx
  80116d:	89 c1                	mov    %eax,%ecx
  80116f:	31 c0                	xor    %eax,%eax
  801171:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801174:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801177:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80117a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80117d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801180:	83 c4 28             	add    $0x28,%esp
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	c9                   	leave  
  801186:	c3                   	ret    
  801187:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801188:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80118b:	0f 87 97 00 00 00    	ja     801228 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801191:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801194:	83 f0 1f             	xor    $0x1f,%eax
  801197:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80119a:	75 34                	jne    8011d0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80119c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80119f:	72 08                	jb     8011a9 <__udivdi3+0x75>
  8011a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011a4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8011a7:	77 7f                	ja     801228 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011a9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011ae:	31 c0                	xor    %eax,%eax
  8011b0:	eb c2                	jmp    801174 <__udivdi3+0x40>
  8011b2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8011b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	74 79                	je     801234 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011be:	89 fa                	mov    %edi,%edx
  8011c0:	f7 f1                	div    %ecx
  8011c2:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011c7:	f7 f1                	div    %ecx
  8011c9:	89 c1                	mov    %eax,%ecx
  8011cb:	89 f0                	mov    %esi,%eax
  8011cd:	eb a5                	jmp    801174 <__udivdi3+0x40>
  8011cf:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d5:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8011d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8011db:	89 fa                	mov    %edi,%edx
  8011dd:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8011e0:	d3 e2                	shl    %cl,%edx
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e5:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8011e8:	d3 e8                	shr    %cl,%eax
  8011ea:	89 d7                	mov    %edx,%edi
  8011ec:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8011ee:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8011f1:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8011f4:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8011f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011f9:	d3 e0                	shl    %cl,%eax
  8011fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011fe:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801201:	d3 ea                	shr    %cl,%edx
  801203:	09 d0                	or     %edx,%eax
  801205:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801208:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80120b:	d3 ea                	shr    %cl,%edx
  80120d:	f7 f7                	div    %edi
  80120f:	89 d7                	mov    %edx,%edi
  801211:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801214:	f7 e6                	mul    %esi
  801216:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801218:	39 d7                	cmp    %edx,%edi
  80121a:	72 38                	jb     801254 <__udivdi3+0x120>
  80121c:	74 27                	je     801245 <__udivdi3+0x111>
  80121e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801221:	31 c0                	xor    %eax,%eax
  801223:	e9 4c ff ff ff       	jmp    801174 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801228:	31 c9                	xor    %ecx,%ecx
  80122a:	31 c0                	xor    %eax,%eax
  80122c:	e9 43 ff ff ff       	jmp    801174 <__udivdi3+0x40>
  801231:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801234:	b8 01 00 00 00       	mov    $0x1,%eax
  801239:	31 d2                	xor    %edx,%edx
  80123b:	f7 75 f4             	divl   -0xc(%ebp)
  80123e:	89 c1                	mov    %eax,%ecx
  801240:	e9 76 ff ff ff       	jmp    8011bb <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801245:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801248:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80124b:	d3 e0                	shl    %cl,%eax
  80124d:	39 f0                	cmp    %esi,%eax
  80124f:	73 cd                	jae    80121e <__udivdi3+0xea>
  801251:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801254:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801257:	49                   	dec    %ecx
  801258:	31 c0                	xor    %eax,%eax
  80125a:	e9 15 ff ff ff       	jmp    801174 <__udivdi3+0x40>
	...

00801260 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	83 ec 30             	sub    $0x30,%esp
  801268:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80126f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801276:	8b 75 08             	mov    0x8(%ebp),%esi
  801279:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80127c:	8b 45 10             	mov    0x10(%ebp),%eax
  80127f:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801282:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801285:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801287:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  80128a:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  80128d:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801290:	85 d2                	test   %edx,%edx
  801292:	75 1c                	jne    8012b0 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801294:	89 fa                	mov    %edi,%edx
  801296:	39 f8                	cmp    %edi,%eax
  801298:	0f 86 c2 00 00 00    	jbe    801360 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80129e:	89 f0                	mov    %esi,%eax
  8012a0:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8012a2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8012a5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012ac:	eb 12                	jmp    8012c0 <__umoddi3+0x60>
  8012ae:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8012b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012b3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8012b6:	76 18                	jbe    8012d0 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8012b8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8012bb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8012be:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8012c6:	83 c4 30             	add    $0x30,%esp
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8012d0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8012d4:	83 f0 1f             	xor    $0x1f,%eax
  8012d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8012da:	0f 84 ac 00 00 00    	je     80138c <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8012e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e5:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8012e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012ee:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8012f1:	d3 e2                	shl    %cl,%edx
  8012f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012f6:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8012f9:	d3 e8                	shr    %cl,%eax
  8012fb:	89 d6                	mov    %edx,%esi
  8012fd:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  8012ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801302:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801305:	d3 e0                	shl    %cl,%eax
  801307:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80130a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  80130d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80130f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801312:	d3 e0                	shl    %cl,%eax
  801314:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801317:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80131a:	d3 ea                	shr    %cl,%edx
  80131c:	09 d0                	or     %edx,%eax
  80131e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801321:	d3 ea                	shr    %cl,%edx
  801323:	f7 f6                	div    %esi
  801325:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801328:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80132b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80132e:	0f 82 8d 00 00 00    	jb     8013c1 <__umoddi3+0x161>
  801334:	0f 84 91 00 00 00    	je     8013cb <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80133a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80133d:	29 c7                	sub    %eax,%edi
  80133f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801341:	89 f2                	mov    %esi,%edx
  801343:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801346:	d3 e2                	shl    %cl,%edx
  801348:	89 f8                	mov    %edi,%eax
  80134a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80134d:	d3 e8                	shr    %cl,%eax
  80134f:	09 c2                	or     %eax,%edx
  801351:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801354:	d3 ee                	shr    %cl,%esi
  801356:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801359:	e9 62 ff ff ff       	jmp    8012c0 <__umoddi3+0x60>
  80135e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801360:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801363:	85 c0                	test   %eax,%eax
  801365:	74 15                	je     80137c <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801367:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80136d:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	f7 f1                	div    %ecx
  801374:	e9 29 ff ff ff       	jmp    8012a2 <__umoddi3+0x42>
  801379:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80137c:	b8 01 00 00 00       	mov    $0x1,%eax
  801381:	31 d2                	xor    %edx,%edx
  801383:	f7 75 ec             	divl   -0x14(%ebp)
  801386:	89 c1                	mov    %eax,%ecx
  801388:	eb dd                	jmp    801367 <__umoddi3+0x107>
  80138a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80138c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801392:	72 19                	jb     8013ad <__umoddi3+0x14d>
  801394:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801397:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80139a:	76 11                	jbe    8013ad <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80139c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8013a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8013a8:	e9 13 ff ff ff       	jmp    8012c0 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8013b6:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8013b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8013bf:	eb db                	jmp    80139c <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8013c1:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8013c4:	19 f2                	sbb    %esi,%edx
  8013c6:	e9 6f ff ff ff       	jmp    80133a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013cb:	39 c7                	cmp    %eax,%edi
  8013cd:	72 f2                	jb     8013c1 <__umoddi3+0x161>
  8013cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013d2:	e9 63 ff ff ff       	jmp    80133a <__umoddi3+0xda>
