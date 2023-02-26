
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4b 00 00 00       	call   80007c <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 60 23 80 00       	push   $0x802360
  800048:	e8 34 01 00 00       	call   800181 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004d:	83 c4 0c             	add    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	68 7e 23 80 00       	push   $0x80237e
  800057:	68 7e 23 80 00       	push   $0x80237e
  80005c:	e8 9a 11 00 00       	call   8011fb <spawnl>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	85 c0                	test   %eax,%eax
  800066:	79 12                	jns    80007a <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800068:	50                   	push   %eax
  800069:	68 84 23 80 00       	push   $0x802384
  80006e:	6a 09                	push   $0x9
  800070:	68 9c 23 80 00       	push   $0x80239c
  800075:	e8 66 00 00 00       	call   8000e0 <_panic>
}
  80007a:	c9                   	leave  
  80007b:	c3                   	ret    

0080007c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	8b 75 08             	mov    0x8(%ebp),%esi
  800084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800087:	e8 bf 0b 00 00       	call   800c4b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80008c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800091:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800098:	c1 e0 07             	shl    $0x7,%eax
  80009b:	29 d0                	sub    %edx,%eax
  80009d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	85 f6                	test   %esi,%esi
  8000a9:	7e 07                	jle    8000b2 <libmain+0x36>
		binaryname = argv[0];
  8000ab:	8b 03                	mov    (%ebx),%eax
  8000ad:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 78 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0b 00 00 00       	call   8000cc <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
}
  8000c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000d2:	6a 00                	push   $0x0
  8000d4:	e8 91 0b 00 00       	call   800c6a <sys_env_destroy>
  8000d9:	83 c4 10             	add    $0x10,%esp
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
	...

008000e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8000e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8000ea:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000ed:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8000f3:	e8 53 0b 00 00       	call   800c4b <sys_getenvid>
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	ff 75 0c             	pushl  0xc(%ebp)
  8000fe:	ff 75 08             	pushl  0x8(%ebp)
  800101:	53                   	push   %ebx
  800102:	50                   	push   %eax
  800103:	68 b8 23 80 00       	push   $0x8023b8
  800108:	e8 74 00 00 00       	call   800181 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80010d:	83 c4 18             	add    $0x18,%esp
  800110:	ff 75 f8             	pushl  -0x8(%ebp)
  800113:	ff 75 10             	pushl  0x10(%ebp)
  800116:	e8 15 00 00 00       	call   800130 <vcprintf>
	cprintf("\n");
  80011b:	c7 04 24 7e 28 80 00 	movl   $0x80287e,(%esp)
  800122:	e8 5a 00 00 00       	call   800181 <cprintf>
  800127:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80012a:	cc                   	int3   
  80012b:	eb fd                	jmp    80012a <_panic+0x4a>
  80012d:	00 00                	add    %al,(%eax)
	...

00800130 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800139:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800140:	00 00 00 
	b.cnt = 0;
  800143:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80014a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014d:	ff 75 0c             	pushl  0xc(%ebp)
  800150:	ff 75 08             	pushl  0x8(%ebp)
  800153:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800159:	50                   	push   %eax
  80015a:	68 98 01 80 00       	push   $0x800198
  80015f:	e8 70 01 00 00       	call   8002d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800164:	83 c4 08             	add    $0x8,%esp
  800167:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  80016d:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800173:	50                   	push   %eax
  800174:	e8 9e 08 00 00       	call   800a17 <sys_cputs>
  800179:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800187:	8d 45 0c             	lea    0xc(%ebp),%eax
  80018a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80018d:	50                   	push   %eax
  80018e:	ff 75 08             	pushl  0x8(%ebp)
  800191:	e8 9a ff ff ff       	call   800130 <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 04             	sub    $0x4,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 03                	mov    (%ebx),%eax
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ab:	40                   	inc    %eax
  8001ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 51 08 00 00       	call   800a17 <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	ff 43 04             	incl   0x4(%ebx)
}
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    
	...

008001d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 1c             	sub    $0x1c,%esp
  8001e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001e4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001f3:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	89 d6                	mov    %edx,%esi
  8001fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800200:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800203:	72 04                	jb     800209 <printnum+0x31>
  800205:	39 c2                	cmp    %eax,%edx
  800207:	77 3f                	ja     800248 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800212:	50                   	push   %eax
  800213:	52                   	push   %edx
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021c:	ff 75 e0             	pushl  -0x20(%ebp)
  80021f:	e8 8c 1e 00 00       	call   8020b0 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80022c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80022f:	e8 a4 ff ff ff       	call   8001d8 <printnum>
  800234:	83 c4 20             	add    $0x20,%esp
  800237:	eb 14                	jmp    80024d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	ff 75 e8             	pushl  -0x18(%ebp)
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	ff 55 ec             	call   *-0x14(%ebp)
  800245:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800248:	4b                   	dec    %ebx
  800249:	85 db                	test   %ebx,%ebx
  80024b:	7f ec                	jg     800239 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	ff 75 e8             	pushl  -0x18(%ebp)
  800253:	83 ec 04             	sub    $0x4,%esp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025b:	ff 75 e0             	pushl  -0x20(%ebp)
  80025e:	e8 79 1f 00 00       	call   8021dc <__umoddi3>
  800263:	83 c4 14             	add    $0x14,%esp
  800266:	0f be 80 db 23 80 00 	movsbl 0x8023db(%eax),%eax
  80026d:	50                   	push   %eax
  80026e:	ff 55 ec             	call   *-0x14(%ebp)
  800271:	83 c4 10             	add    $0x10,%esp
}
  800274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5f                   	pop    %edi
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 42 08             	lea    0x8(%edx),%eax
  80028b:	89 01                	mov    %eax,(%ecx)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x3a>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 42 04             	lea    0x4(%edx),%eax
  80029d:	89 01                	mov    %eax,(%ecx)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 42 04             	lea    0x4(%edx),%eax
  8002ad:	89 01                	mov    %eax,(%ecx)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002be:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002c1:	8b 11                	mov    (%ecx),%edx
  8002c3:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002c6:	73 0a                	jae    8002d2 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	88 02                	mov    %al,(%edx)
  8002cd:	8d 42 01             	lea    0x1(%edx),%eax
  8002d0:	89 01                	mov    %eax,(%ecx)
}
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 3c             	sub    $0x3c,%esp
  8002dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e6:	eb 1a                	jmp    800302 <vprintfmt+0x2e>
  8002e8:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002eb:	eb 15                	jmp    800302 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ed:	84 c0                	test   %al,%al
  8002ef:	0f 84 15 03 00 00    	je     80060a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	57                   	push   %edi
  8002f9:	0f b6 c0             	movzbl %al,%eax
  8002fc:	50                   	push   %eax
  8002fd:	ff d6                	call   *%esi
  8002ff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800302:	8a 03                	mov    (%ebx),%al
  800304:	43                   	inc    %ebx
  800305:	3c 25                	cmp    $0x25,%al
  800307:	75 e4                	jne    8002ed <vprintfmt+0x19>
  800309:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800310:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800317:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80031e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800325:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800329:	eb 0a                	jmp    800335 <vprintfmt+0x61>
  80032b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800332:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8a 03                	mov    (%ebx),%al
  800337:	0f b6 d0             	movzbl %al,%edx
  80033a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  80033d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800340:	83 e8 23             	sub    $0x23,%eax
  800343:	3c 55                	cmp    $0x55,%al
  800345:	0f 87 9c 02 00 00    	ja     8005e7 <vprintfmt+0x313>
  80034b:	0f b6 c0             	movzbl %al,%eax
  80034e:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  800355:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800359:	eb d7                	jmp    800332 <vprintfmt+0x5e>
  80035b:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80035f:	eb d1                	jmp    800332 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800361:	89 d9                	mov    %ebx,%ecx
  800363:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80036d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800370:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800374:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800377:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80037b:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  80037c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80037f:	83 f8 09             	cmp    $0x9,%eax
  800382:	77 21                	ja     8003a5 <vprintfmt+0xd1>
  800384:	eb e4                	jmp    80036a <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800386:	8b 55 14             	mov    0x14(%ebp),%edx
  800389:	8d 42 04             	lea    0x4(%edx),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
  80038f:	8b 12                	mov    (%edx),%edx
  800391:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800394:	eb 12                	jmp    8003a8 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800396:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80039a:	79 96                	jns    800332 <vprintfmt+0x5e>
  80039c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a3:	eb 8d                	jmp    800332 <vprintfmt+0x5e>
  8003a5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ac:	79 84                	jns    800332 <vprintfmt+0x5e>
  8003ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b4:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003bb:	e9 72 ff ff ff       	jmp    800332 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c0:	ff 45 d4             	incl   -0x2c(%ebp)
  8003c3:	e9 6a ff ff ff       	jmp    800332 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cb:	8d 42 04             	lea    0x4(%edx),%eax
  8003ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	57                   	push   %edi
  8003d5:	ff 32                	pushl  (%edx)
  8003d7:	ff d6                	call   *%esi
			break;
  8003d9:	83 c4 10             	add    $0x10,%esp
  8003dc:	e9 07 ff ff ff       	jmp    8002e8 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e1:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e4:	8d 42 04             	lea    0x4(%edx),%eax
  8003e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ea:	8b 02                	mov    (%edx),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	79 02                	jns    8003f2 <vprintfmt+0x11e>
  8003f0:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f2:	83 f8 0f             	cmp    $0xf,%eax
  8003f5:	7f 0b                	jg     800402 <vprintfmt+0x12e>
  8003f7:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	75 15                	jne    800417 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800402:	50                   	push   %eax
  800403:	68 ec 23 80 00       	push   $0x8023ec
  800408:	57                   	push   %edi
  800409:	56                   	push   %esi
  80040a:	e8 6e 02 00 00       	call   80067d <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	e9 d1 fe ff ff       	jmp    8002e8 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800417:	52                   	push   %edx
  800418:	68 36 27 80 00       	push   $0x802736
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	e8 59 02 00 00       	call   80067d <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	e9 bc fe ff ff       	jmp    8002e8 <vprintfmt+0x14>
  80042c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80042f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800432:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800435:	8b 55 14             	mov    0x14(%ebp),%edx
  800438:	8d 42 04             	lea    0x4(%edx),%eax
  80043b:	89 45 14             	mov    %eax,0x14(%ebp)
  80043e:	8b 1a                	mov    (%edx),%ebx
  800440:	85 db                	test   %ebx,%ebx
  800442:	75 05                	jne    800449 <vprintfmt+0x175>
  800444:	bb f5 23 80 00       	mov    $0x8023f5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800449:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80044d:	7e 66                	jle    8004b5 <vprintfmt+0x1e1>
  80044f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800453:	74 60                	je     8004b5 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	51                   	push   %ecx
  800459:	53                   	push   %ebx
  80045a:	e8 57 02 00 00       	call   8006b6 <strnlen>
  80045f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800462:	29 c1                	sub    %eax,%ecx
  800464:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80046e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800471:	eb 0f                	jmp    800482 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	57                   	push   %edi
  800477:	ff 75 c4             	pushl  -0x3c(%ebp)
  80047a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	ff 4d d8             	decl   -0x28(%ebp)
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800486:	7f eb                	jg     800473 <vprintfmt+0x19f>
  800488:	eb 2b                	jmp    8004b5 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048a:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  80048d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800491:	74 15                	je     8004a8 <vprintfmt+0x1d4>
  800493:	8d 42 e0             	lea    -0x20(%edx),%eax
  800496:	83 f8 5e             	cmp    $0x5e,%eax
  800499:	76 0d                	jbe    8004a8 <vprintfmt+0x1d4>
					putch('?', putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	57                   	push   %edi
  80049f:	6a 3f                	push   $0x3f
  8004a1:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	eb 0a                	jmp    8004b2 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	57                   	push   %edi
  8004ac:	52                   	push   %edx
  8004ad:	ff d6                	call   *%esi
  8004af:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b2:	ff 4d d8             	decl   -0x28(%ebp)
  8004b5:	8a 03                	mov    (%ebx),%al
  8004b7:	43                   	inc    %ebx
  8004b8:	84 c0                	test   %al,%al
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x203>
  8004bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c0:	78 c8                	js     80048a <vprintfmt+0x1b6>
  8004c2:	ff 4d dc             	decl   -0x24(%ebp)
  8004c5:	79 c3                	jns    80048a <vprintfmt+0x1b6>
  8004c7:	eb 0e                	jmp    8004d7 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	57                   	push   %edi
  8004cd:	6a 20                	push   $0x20
  8004cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d1:	ff 4d d8             	decl   -0x28(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004db:	7f ec                	jg     8004c9 <vprintfmt+0x1f5>
  8004dd:	e9 06 fe ff ff       	jmp    8002e8 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e2:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004e6:	7e 10                	jle    8004f8 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8004eb:	8d 42 08             	lea    0x8(%edx),%eax
  8004ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	8b 52 04             	mov    0x4(%edx),%edx
  8004f6:	eb 20                	jmp    800518 <vprintfmt+0x244>
	else if (lflag)
  8004f8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fc:	74 0e                	je     80050c <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	99                   	cltd   
  80050a:	eb 0c                	jmp    800518 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8d 50 04             	lea    0x4(%eax),%edx
  800512:	89 55 14             	mov    %edx,0x14(%ebp)
  800515:	8b 00                	mov    (%eax),%eax
  800517:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800518:	89 d1                	mov    %edx,%ecx
  80051a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  80051c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80051f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800522:	85 c9                	test   %ecx,%ecx
  800524:	78 0a                	js     800530 <vprintfmt+0x25c>
  800526:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80052b:	e9 89 00 00 00       	jmp    8005b9 <vprintfmt+0x2e5>
				putch('-', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	57                   	push   %edi
  800534:	6a 2d                	push   $0x2d
  800536:	ff d6                	call   *%esi
				num = -(long long) num;
  800538:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80053b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053e:	f7 da                	neg    %edx
  800540:	83 d1 00             	adc    $0x0,%ecx
  800543:	f7 d9                	neg    %ecx
  800545:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 6a                	jmp    8005b9 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80054f:	8d 45 14             	lea    0x14(%ebp),%eax
  800552:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800555:	e8 22 fd ff ff       	call   80027c <getuint>
  80055a:	89 d1                	mov    %edx,%ecx
  80055c:	89 c2                	mov    %eax,%edx
  80055e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800563:	eb 54                	jmp    8005b9 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800565:	8d 45 14             	lea    0x14(%ebp),%eax
  800568:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056b:	e8 0c fd ff ff       	call   80027c <getuint>
  800570:	89 d1                	mov    %edx,%ecx
  800572:	89 c2                	mov    %eax,%edx
  800574:	bb 08 00 00 00       	mov    $0x8,%ebx
  800579:	eb 3e                	jmp    8005b9 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	6a 30                	push   $0x30
  800581:	ff d6                	call   *%esi
			putch('x', putdat);
  800583:	83 c4 08             	add    $0x8,%esp
  800586:	57                   	push   %edi
  800587:	6a 78                	push   $0x78
  800589:	ff d6                	call   *%esi
			num = (unsigned long long)
  80058b:	8b 55 14             	mov    0x14(%ebp),%edx
  80058e:	8d 42 04             	lea    0x4(%edx),%eax
  800591:	89 45 14             	mov    %eax,0x14(%ebp)
  800594:	8b 12                	mov    (%edx),%edx
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	eb 14                	jmp    8005b9 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ab:	e8 cc fc ff ff       	call   80027c <getuint>
  8005b0:	89 d1                	mov    %edx,%ecx
  8005b2:	89 c2                	mov    %eax,%edx
  8005b4:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005c0:	50                   	push   %eax
  8005c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c4:	53                   	push   %ebx
  8005c5:	51                   	push   %ecx
  8005c6:	52                   	push   %edx
  8005c7:	89 fa                	mov    %edi,%edx
  8005c9:	89 f0                	mov    %esi,%eax
  8005cb:	e8 08 fc ff ff       	call   8001d8 <printnum>
			break;
  8005d0:	83 c4 20             	add    $0x20,%esp
  8005d3:	e9 10 fd ff ff       	jmp    8002e8 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	57                   	push   %edi
  8005dc:	52                   	push   %edx
  8005dd:	ff d6                	call   *%esi
			break;
  8005df:	83 c4 10             	add    $0x10,%esp
  8005e2:	e9 01 fd ff ff       	jmp    8002e8 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 25                	push   $0x25
  8005ed:	ff d6                	call   *%esi
  8005ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005f2:	83 ea 02             	sub    $0x2,%edx
  8005f5:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005f8:	8a 02                	mov    (%edx),%al
  8005fa:	4a                   	dec    %edx
  8005fb:	3c 25                	cmp    $0x25,%al
  8005fd:	75 f9                	jne    8005f8 <vprintfmt+0x324>
  8005ff:	83 c2 02             	add    $0x2,%edx
  800602:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800605:	e9 de fc ff ff       	jmp    8002e8 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80060a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80060d:	5b                   	pop    %ebx
  80060e:	5e                   	pop    %esi
  80060f:	5f                   	pop    %edi
  800610:	c9                   	leave  
  800611:	c3                   	ret    

00800612 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800612:	55                   	push   %ebp
  800613:	89 e5                	mov    %esp,%ebp
  800615:	83 ec 18             	sub    $0x18,%esp
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80061e:	85 d2                	test   %edx,%edx
  800620:	74 37                	je     800659 <vsnprintf+0x47>
  800622:	85 c0                	test   %eax,%eax
  800624:	7e 33                	jle    800659 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800626:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80062d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800631:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800634:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800637:	ff 75 14             	pushl  0x14(%ebp)
  80063a:	ff 75 10             	pushl  0x10(%ebp)
  80063d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	68 b8 02 80 00       	push   $0x8002b8
  800646:	e8 89 fc ff ff       	call   8002d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800651:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 05                	jmp    80065e <vsnprintf+0x4c>
  800659:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80065e:	c9                   	leave  
  80065f:	c3                   	ret    

00800660 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80066c:	50                   	push   %eax
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	ff 75 0c             	pushl  0xc(%ebp)
  800673:	ff 75 08             	pushl  0x8(%ebp)
  800676:	e8 97 ff ff ff       	call   800612 <vsnprintf>
	va_end(ap);

	return rc;
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800689:	50                   	push   %eax
  80068a:	ff 75 10             	pushl  0x10(%ebp)
  80068d:	ff 75 0c             	pushl  0xc(%ebp)
  800690:	ff 75 08             	pushl  0x8(%ebp)
  800693:	e8 3c fc ff ff       	call   8002d4 <vprintfmt>
	va_end(ap);
  800698:	83 c4 10             	add    $0x10,%esp
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    
  80069d:	00 00                	add    %al,(%eax)
	...

008006a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ab:	eb 01                	jmp    8006ae <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ae:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006b2:	75 f9                	jne    8006ad <strlen+0xd>
		n++;
	return n;
}
  8006b4:	c9                   	leave  
  8006b5:	c3                   	ret    

008006b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	eb 01                	jmp    8006c7 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8006c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c7:	39 d0                	cmp    %edx,%eax
  8006c9:	74 06                	je     8006d1 <strnlen+0x1b>
  8006cb:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8006cf:	75 f5                	jne    8006c6 <strnlen+0x10>
		n++;
	return n;
}
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d9:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006dc:	8a 01                	mov    (%ecx),%al
  8006de:	88 02                	mov    %al,(%edx)
  8006e0:	42                   	inc    %edx
  8006e1:	41                   	inc    %ecx
  8006e2:	84 c0                	test   %al,%al
  8006e4:	75 f6                	jne    8006dc <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	53                   	push   %ebx
  8006ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f2:	53                   	push   %ebx
  8006f3:	e8 a8 ff ff ff       	call   8006a0 <strlen>
	strcpy(dst + len, src);
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006fe:	50                   	push   %eax
  8006ff:	e8 cf ff ff ff       	call   8006d3 <strcpy>
	return dst;
}
  800704:	89 d8                	mov    %ebx,%eax
  800706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	56                   	push   %esi
  80070f:	53                   	push   %ebx
  800710:	8b 75 08             	mov    0x8(%ebp),%esi
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
  800716:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	eb 0c                	jmp    80072c <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800720:	8a 02                	mov    (%edx),%al
  800722:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800725:	80 3a 01             	cmpb   $0x1,(%edx)
  800728:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80072b:	41                   	inc    %ecx
  80072c:	39 d9                	cmp    %ebx,%ecx
  80072e:	75 f0                	jne    800720 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800730:	89 f0                	mov    %esi,%eax
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	8b 75 08             	mov    0x8(%ebp),%esi
  80073e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800741:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800744:	85 c9                	test   %ecx,%ecx
  800746:	75 04                	jne    80074c <strlcpy+0x16>
  800748:	89 f0                	mov    %esi,%eax
  80074a:	eb 14                	jmp    800760 <strlcpy+0x2a>
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	eb 04                	jmp    800754 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800750:	88 10                	mov    %dl,(%eax)
  800752:	40                   	inc    %eax
  800753:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800754:	49                   	dec    %ecx
  800755:	74 06                	je     80075d <strlcpy+0x27>
  800757:	8a 13                	mov    (%ebx),%dl
  800759:	84 d2                	test   %dl,%dl
  80075b:	75 f3                	jne    800750 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80075d:	c6 00 00             	movb   $0x0,(%eax)
  800760:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
  80076c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076f:	eb 02                	jmp    800773 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800771:	42                   	inc    %edx
  800772:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800773:	8a 02                	mov    (%edx),%al
  800775:	84 c0                	test   %al,%al
  800777:	74 04                	je     80077d <strcmp+0x17>
  800779:	3a 01                	cmp    (%ecx),%al
  80077b:	74 f4                	je     800771 <strcmp+0xb>
  80077d:	0f b6 c0             	movzbl %al,%eax
  800780:	0f b6 11             	movzbl (%ecx),%edx
  800783:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800791:	8b 55 10             	mov    0x10(%ebp),%edx
  800794:	eb 03                	jmp    800799 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800796:	4a                   	dec    %edx
  800797:	41                   	inc    %ecx
  800798:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800799:	85 d2                	test   %edx,%edx
  80079b:	75 07                	jne    8007a4 <strncmp+0x1d>
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	eb 14                	jmp    8007b8 <strncmp+0x31>
  8007a4:	8a 01                	mov    (%ecx),%al
  8007a6:	84 c0                	test   %al,%al
  8007a8:	74 04                	je     8007ae <strncmp+0x27>
  8007aa:	3a 03                	cmp    (%ebx),%al
  8007ac:	74 e8                	je     800796 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ae:	0f b6 d0             	movzbl %al,%edx
  8007b1:	0f b6 03             	movzbl (%ebx),%eax
  8007b4:	29 c2                	sub    %eax,%edx
  8007b6:	89 d0                	mov    %edx,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007c4:	eb 05                	jmp    8007cb <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8007c6:	38 ca                	cmp    %cl,%dl
  8007c8:	74 0c                	je     8007d6 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007ca:	40                   	inc    %eax
  8007cb:	8a 10                	mov    (%eax),%dl
  8007cd:	84 d2                	test   %dl,%dl
  8007cf:	75 f5                	jne    8007c6 <strchr+0xb>
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007e1:	eb 05                	jmp    8007e8 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007e3:	38 ca                	cmp    %cl,%dl
  8007e5:	74 07                	je     8007ee <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007e7:	40                   	inc    %eax
  8007e8:	8a 10                	mov    (%eax),%dl
  8007ea:	84 d2                	test   %dl,%dl
  8007ec:	75 f5                	jne    8007e3 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	57                   	push   %edi
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007ff:	85 db                	test   %ebx,%ebx
  800801:	74 36                	je     800839 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800803:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800809:	75 29                	jne    800834 <memset+0x44>
  80080b:	f6 c3 03             	test   $0x3,%bl
  80080e:	75 24                	jne    800834 <memset+0x44>
		c &= 0xFF;
  800810:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800813:	89 d6                	mov    %edx,%esi
  800815:	c1 e6 08             	shl    $0x8,%esi
  800818:	89 d0                	mov    %edx,%eax
  80081a:	c1 e0 18             	shl    $0x18,%eax
  80081d:	89 d1                	mov    %edx,%ecx
  80081f:	c1 e1 10             	shl    $0x10,%ecx
  800822:	09 c8                	or     %ecx,%eax
  800824:	09 c2                	or     %eax,%edx
  800826:	89 f0                	mov    %esi,%eax
  800828:	09 d0                	or     %edx,%eax
  80082a:	89 d9                	mov    %ebx,%ecx
  80082c:	c1 e9 02             	shr    $0x2,%ecx
  80082f:	fc                   	cld    
  800830:	f3 ab                	rep stos %eax,%es:(%edi)
  800832:	eb 05                	jmp    800839 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800834:	89 d9                	mov    %ebx,%ecx
  800836:	fc                   	cld    
  800837:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800839:	89 f8                	mov    %edi,%eax
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80084b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80084e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800850:	39 c6                	cmp    %eax,%esi
  800852:	73 36                	jae    80088a <memmove+0x4a>
  800854:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800857:	39 d0                	cmp    %edx,%eax
  800859:	73 2f                	jae    80088a <memmove+0x4a>
		s += n;
		d += n;
  80085b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80085e:	f6 c2 03             	test   $0x3,%dl
  800861:	75 1b                	jne    80087e <memmove+0x3e>
  800863:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800869:	75 13                	jne    80087e <memmove+0x3e>
  80086b:	f6 c1 03             	test   $0x3,%cl
  80086e:	75 0e                	jne    80087e <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800870:	8d 7e fc             	lea    -0x4(%esi),%edi
  800873:	8d 72 fc             	lea    -0x4(%edx),%esi
  800876:	c1 e9 02             	shr    $0x2,%ecx
  800879:	fd                   	std    
  80087a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087c:	eb 09                	jmp    800887 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80087e:	8d 7e ff             	lea    -0x1(%esi),%edi
  800881:	8d 72 ff             	lea    -0x1(%edx),%esi
  800884:	fd                   	std    
  800885:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800887:	fc                   	cld    
  800888:	eb 20                	jmp    8008aa <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800890:	75 15                	jne    8008a7 <memmove+0x67>
  800892:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800898:	75 0d                	jne    8008a7 <memmove+0x67>
  80089a:	f6 c1 03             	test   $0x3,%cl
  80089d:	75 08                	jne    8008a7 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80089f:	c1 e9 02             	shr    $0x2,%ecx
  8008a2:	fc                   	cld    
  8008a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008a5:	eb 03                	jmp    8008aa <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008a7:	fc                   	cld    
  8008a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008aa:	5e                   	pop    %esi
  8008ab:	5f                   	pop    %edi
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 81 ff ff ff       	call   800840 <memmove>
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	83 ec 04             	sub    $0x4,%esp
  8008c8:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d1:	eb 1b                	jmp    8008ee <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008d3:	8a 1a                	mov    (%edx),%bl
  8008d5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008d8:	8a 19                	mov    (%ecx),%bl
  8008da:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008dd:	74 0d                	je     8008ec <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008df:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008e3:	0f b6 c3             	movzbl %bl,%eax
  8008e6:	29 c2                	sub    %eax,%edx
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	eb 0d                	jmp    8008f9 <memcmp+0x38>
		s1++, s2++;
  8008ec:	42                   	inc    %edx
  8008ed:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ee:	48                   	dec    %eax
  8008ef:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008f2:	75 df                	jne    8008d3 <memcmp+0x12>
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008f9:	83 c4 04             	add    $0x4,%esp
  8008fc:	5b                   	pop    %ebx
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800908:	89 c2                	mov    %eax,%edx
  80090a:	03 55 10             	add    0x10(%ebp),%edx
  80090d:	eb 05                	jmp    800914 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80090f:	38 08                	cmp    %cl,(%eax)
  800911:	74 05                	je     800918 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800913:	40                   	inc    %eax
  800914:	39 d0                	cmp    %edx,%eax
  800916:	72 f7                	jb     80090f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	83 ec 04             	sub    $0x4,%esp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 75 10             	mov    0x10(%ebp),%esi
  800929:	eb 01                	jmp    80092c <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80092b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80092c:	8a 01                	mov    (%ecx),%al
  80092e:	3c 20                	cmp    $0x20,%al
  800930:	74 f9                	je     80092b <strtol+0x11>
  800932:	3c 09                	cmp    $0x9,%al
  800934:	74 f5                	je     80092b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800936:	3c 2b                	cmp    $0x2b,%al
  800938:	75 0a                	jne    800944 <strtol+0x2a>
		s++;
  80093a:	41                   	inc    %ecx
  80093b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800942:	eb 17                	jmp    80095b <strtol+0x41>
	else if (*s == '-')
  800944:	3c 2d                	cmp    $0x2d,%al
  800946:	74 09                	je     800951 <strtol+0x37>
  800948:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80094f:	eb 0a                	jmp    80095b <strtol+0x41>
		s++, neg = 1;
  800951:	8d 49 01             	lea    0x1(%ecx),%ecx
  800954:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80095b:	85 f6                	test   %esi,%esi
  80095d:	74 05                	je     800964 <strtol+0x4a>
  80095f:	83 fe 10             	cmp    $0x10,%esi
  800962:	75 1a                	jne    80097e <strtol+0x64>
  800964:	8a 01                	mov    (%ecx),%al
  800966:	3c 30                	cmp    $0x30,%al
  800968:	75 10                	jne    80097a <strtol+0x60>
  80096a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80096e:	75 0a                	jne    80097a <strtol+0x60>
		s += 2, base = 16;
  800970:	83 c1 02             	add    $0x2,%ecx
  800973:	be 10 00 00 00       	mov    $0x10,%esi
  800978:	eb 04                	jmp    80097e <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80097a:	85 f6                	test   %esi,%esi
  80097c:	74 07                	je     800985 <strtol+0x6b>
  80097e:	bf 00 00 00 00       	mov    $0x0,%edi
  800983:	eb 13                	jmp    800998 <strtol+0x7e>
  800985:	3c 30                	cmp    $0x30,%al
  800987:	74 07                	je     800990 <strtol+0x76>
  800989:	be 0a 00 00 00       	mov    $0xa,%esi
  80098e:	eb ee                	jmp    80097e <strtol+0x64>
		s++, base = 8;
  800990:	41                   	inc    %ecx
  800991:	be 08 00 00 00       	mov    $0x8,%esi
  800996:	eb e6                	jmp    80097e <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800998:	8a 11                	mov    (%ecx),%dl
  80099a:	88 d3                	mov    %dl,%bl
  80099c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80099f:	3c 09                	cmp    $0x9,%al
  8009a1:	77 08                	ja     8009ab <strtol+0x91>
			dig = *s - '0';
  8009a3:	0f be c2             	movsbl %dl,%eax
  8009a6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009a9:	eb 1c                	jmp    8009c7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ab:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009ae:	3c 19                	cmp    $0x19,%al
  8009b0:	77 08                	ja     8009ba <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009b2:	0f be c2             	movsbl %dl,%eax
  8009b5:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009b8:	eb 0d                	jmp    8009c7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ba:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009bd:	3c 19                	cmp    $0x19,%al
  8009bf:	77 15                	ja     8009d6 <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009c1:	0f be c2             	movsbl %dl,%eax
  8009c4:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8009c7:	39 f2                	cmp    %esi,%edx
  8009c9:	7d 0b                	jge    8009d6 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009cb:	41                   	inc    %ecx
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	0f af c6             	imul   %esi,%eax
  8009d1:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009d4:	eb c2                	jmp    800998 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009d6:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009dc:	74 05                	je     8009e3 <strtol+0xc9>
		*endptr = (char *) s;
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e1:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009e7:	74 04                	je     8009ed <strtol+0xd3>
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	f7 df                	neg    %edi
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	83 c4 04             	add    $0x4,%esp
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    
	...

008009f8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009fe:	b8 01 00 00 00       	mov    $0x1,%eax
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	89 fa                	mov    %edi,%edx
  800a0a:	89 f9                	mov    %edi,%ecx
  800a0c:	89 fb                	mov    %edi,%ebx
  800a0e:	89 fe                	mov    %edi,%esi
  800a10:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 04             	sub    $0x4,%esp
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2b:	89 f8                	mov    %edi,%eax
  800a2d:	89 fb                	mov    %edi,%ebx
  800a2f:	89 fe                	mov    %edi,%esi
  800a31:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a33:	83 c4 04             	add    $0x4,%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	83 ec 0c             	sub    $0xc,%esp
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a47:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	89 f9                	mov    %edi,%ecx
  800a53:	89 fb                	mov    %edi,%ebx
  800a55:	89 fe                	mov    %edi,%esi
  800a57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	7e 17                	jle    800a74 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	50                   	push   %eax
  800a61:	6a 0d                	push   $0xd
  800a63:	68 df 26 80 00       	push   $0x8026df
  800a68:	6a 23                	push   $0x23
  800a6a:	68 fc 26 80 00       	push   $0x8026fc
  800a6f:	e8 6c f6 ff ff       	call   8000e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 55 08             	mov    0x8(%ebp),%edx
  800a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a8b:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a93:	be 00 00 00 00       	mov    $0x0,%esi
  800a98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	83 ec 0c             	sub    $0xc,%esp
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	89 fb                	mov    %edi,%ebx
  800aba:	89 fe                	mov    %edi,%esi
  800abc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	7e 17                	jle    800ad9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	50                   	push   %eax
  800ac6:	6a 0a                	push   $0xa
  800ac8:	68 df 26 80 00       	push   $0x8026df
  800acd:	6a 23                	push   $0x23
  800acf:	68 fc 26 80 00       	push   $0x8026fc
  800ad4:	e8 07 f6 ff ff       	call   8000e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	8b 55 08             	mov    0x8(%ebp),%edx
  800aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	b8 09 00 00 00       	mov    $0x9,%eax
  800af5:	bf 00 00 00 00       	mov    $0x0,%edi
  800afa:	89 fb                	mov    %edi,%ebx
  800afc:	89 fe                	mov    %edi,%esi
  800afe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b00:	85 c0                	test   %eax,%eax
  800b02:	7e 17                	jle    800b1b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	50                   	push   %eax
  800b08:	6a 09                	push   $0x9
  800b0a:	68 df 26 80 00       	push   $0x8026df
  800b0f:	6a 23                	push   $0x23
  800b11:	68 fc 26 80 00       	push   $0x8026fc
  800b16:	e8 c5 f5 ff ff       	call   8000e0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800b32:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800b44:	7e 17                	jle    800b5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	50                   	push   %eax
  800b4a:	6a 08                	push   $0x8
  800b4c:	68 df 26 80 00       	push   $0x8026df
  800b51:	6a 23                	push   $0x23
  800b53:	68 fc 26 80 00       	push   $0x8026fc
  800b58:	e8 83 f5 ff ff       	call   8000e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
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
  800b74:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800b86:	7e 17                	jle    800b9f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b88:	83 ec 0c             	sub    $0xc,%esp
  800b8b:	50                   	push   %eax
  800b8c:	6a 06                	push   $0x6
  800b8e:	68 df 26 80 00       	push   $0x8026df
  800b93:	6a 23                	push   $0x23
  800b95:	68 fc 26 80 00       	push   $0x8026fc
  800b9a:	e8 41 f5 ff ff       	call   8000e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbc:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 05                	push   $0x5
  800bd0:	68 df 26 80 00       	push   $0x8026df
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 fc 26 80 00       	push   $0x8026fc
  800bdc:	e8 ff f4 ff ff       	call   8000e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	bf 00 00 00 00       	mov    $0x0,%edi
  800c05:	89 fe                	mov    %edi,%esi
  800c07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 04                	push   $0x4
  800c13:	68 df 26 80 00       	push   $0x8026df
  800c18:	6a 23                	push   $0x23
  800c1a:	68 fc 26 80 00       	push   $0x8026fc
  800c1f:	e8 bc f4 ff ff       	call   8000e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c37:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3c:	89 fa                	mov    %edi,%edx
  800c3e:	89 f9                	mov    %edi,%ecx
  800c40:	89 fb                	mov    %edi,%ebx
  800c42:	89 fe                	mov    %edi,%esi
  800c44:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	b8 02 00 00 00       	mov    $0x2,%eax
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	89 fa                	mov    %edi,%edx
  800c5d:	89 f9                	mov    %edi,%ecx
  800c5f:	89 fb                	mov    %edi,%ebx
  800c61:	89 fe                	mov    %edi,%esi
  800c63:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	b8 03 00 00 00       	mov    $0x3,%eax
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	89 fb                	mov    %edi,%ebx
  800c84:	89 fe                	mov    %edi,%esi
  800c86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 17                	jle    800ca3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 03                	push   $0x3
  800c92:	68 df 26 80 00       	push   $0x8026df
  800c97:	6a 23                	push   $0x23
  800c99:	68 fc 26 80 00       	push   $0x8026fc
  800c9e:	e8 3d f4 ff ff       	call   8000e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    
	...

00800cac <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  800cb8:	6a 00                	push   $0x0
  800cba:	ff 75 08             	pushl  0x8(%ebp)
  800cbd:	e8 51 0d 00 00       	call   801a13 <open>
  800cc2:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	79 0b                	jns    800cda <spawn+0x2e>
  800ccf:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  800cd5:	e9 13 05 00 00       	jmp    8011ed <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	68 00 02 00 00       	push   $0x200
  800ce2:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  800ce8:	50                   	push   %eax
  800ce9:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  800cef:	e8 c9 08 00 00       	call   8015bd <readn>
  800cf4:	83 c4 10             	add    $0x10,%esp
  800cf7:	3d 00 02 00 00       	cmp    $0x200,%eax
  800cfc:	75 0c                	jne    800d0a <spawn+0x5e>
  800cfe:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  800d05:	45 4c 46 
  800d08:	74 38                	je     800d42 <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  800d13:	e8 74 09 00 00       	call   80168c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  800d18:	83 c4 0c             	add    $0xc,%esp
  800d1b:	68 7f 45 4c 46       	push   $0x464c457f
  800d20:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  800d26:	68 0a 27 80 00       	push   $0x80270a
  800d2b:	e8 51 f4 ff ff       	call   800181 <cprintf>
  800d30:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  800d37:	ff ff ff 
		return -E_NOT_EXEC;
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	e9 ab 04 00 00       	jmp    8011ed <spawn+0x541>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800d42:	ba 07 00 00 00       	mov    $0x7,%edx
  800d47:	89 d0                	mov    %edx,%eax
  800d49:	cd 30                	int    $0x30
  800d4b:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	0f 88 94 04 00 00    	js     8011ed <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  800d59:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d65:	c1 e0 07             	shl    $0x7,%eax
  800d68:	29 d0                	sub    %edx,%eax
  800d6a:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  800d70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d75:	83 ec 04             	sub    $0x4,%esp
  800d78:	6a 44                	push   $0x44
  800d7a:	50                   	push   %eax
  800d7b:	52                   	push   %edx
  800d7c:	e8 2d fb ff ff       	call   8008ae <memcpy>
	child_tf.tf_eip = elf->e_entry;
  800d81:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  800d87:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  800d8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d92:	be 00 00 00 00       	mov    $0x0,%esi
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	eb 11                	jmp    800dad <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	e8 fb f8 ff ff       	call   8006a0 <strlen>
  800da5:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800da9:	46                   	inc    %esi
  800daa:	83 c4 10             	add    $0x10,%esp
  800dad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db0:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  800db3:	85 c0                	test   %eax,%eax
  800db5:	75 e5                	jne    800d9c <spawn+0xf0>
  800db7:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  800dbd:	89 f1                	mov    %esi,%ecx
  800dbf:	c1 e1 02             	shl    $0x2,%ecx
  800dc2:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  800dc8:	b8 00 10 40 00       	mov    $0x401000,%eax
  800dcd:	89 c7                	mov    %eax,%edi
  800dcf:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  800dd1:	89 f8                	mov    %edi,%eax
  800dd3:	83 e0 fc             	and    $0xfffffffc,%eax
  800dd6:	29 c8                	sub    %ecx,%eax
  800dd8:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  800dde:	83 e8 04             	sub    $0x4,%eax
  800de1:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  800de7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  800ded:	83 e8 0c             	sub    $0xc,%eax
  800df0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  800df5:	0f 86 c1 03 00 00    	jbe    8011bc <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	6a 07                	push   $0x7
  800e00:	68 00 00 40 00       	push   $0x400000
  800e05:	6a 00                	push   $0x0
  800e07:	e8 dd fd ff ff       	call   800be9 <sys_page_alloc>
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	0f 88 aa 03 00 00    	js     8011c1 <spawn+0x515>
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	eb 35                	jmp    800e53 <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  800e1e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  800e24:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  800e2a:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e34:	ff 34 99             	pushl  (%ecx,%ebx,4)
  800e37:	57                   	push   %edi
  800e38:	e8 96 f8 ff ff       	call   8006d3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  800e3d:	83 c4 04             	add    $0x4,%esp
  800e40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e43:	ff 34 98             	pushl  (%eax,%ebx,4)
  800e46:	e8 55 f8 ff ff       	call   8006a0 <strlen>
  800e4b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  800e4f:	43                   	inc    %ebx
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	39 f3                	cmp    %esi,%ebx
  800e55:	7c c7                	jl     800e1e <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  800e57:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  800e5d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  800e63:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  800e6a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  800e70:	74 19                	je     800e8b <spawn+0x1df>
  800e72:	68 94 27 80 00       	push   $0x802794
  800e77:	68 24 27 80 00       	push   $0x802724
  800e7c:	68 f2 00 00 00       	push   $0xf2
  800e81:	68 39 27 80 00       	push   $0x802739
  800e86:	e8 55 f2 ff ff       	call   8000e0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  800e8b:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  800e91:	2d 00 30 80 11       	sub    $0x11803000,%eax
  800e96:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  800e9c:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  800e9f:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  800ea5:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  800ea8:	89 d0                	mov    %edx,%eax
  800eaa:	2d 08 30 80 11       	sub    $0x11803008,%eax
  800eaf:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	6a 07                	push   $0x7
  800eba:	68 00 d0 bf ee       	push   $0xeebfd000
  800ebf:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  800ec5:	68 00 00 40 00       	push   $0x400000
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 d6 fc ff ff       	call   800ba7 <sys_page_map>
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	83 c4 20             	add    $0x20,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 1c                	js     800ef6 <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	68 00 00 40 00       	push   $0x400000
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 7c fc ff ff       	call   800b65 <sys_page_unmap>
  800ee9:	89 c3                	mov    %eax,%ebx
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	0f 89 d3 02 00 00    	jns    8011c9 <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  800ef6:	83 ec 08             	sub    $0x8,%esp
  800ef9:	68 00 00 40 00       	push   $0x400000
  800efe:	6a 00                	push   $0x0
  800f00:	e8 60 fc ff ff       	call   800b65 <sys_page_unmap>
  800f05:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	e9 da 02 00 00       	jmp    8011ed <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  800f13:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  800f19:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  800f1d:	0f 85 79 01 00 00    	jne    80109c <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  800f23:	8b 42 f8             	mov    -0x8(%edx),%eax
  800f26:	83 e0 02             	and    $0x2,%eax
  800f29:	83 f8 01             	cmp    $0x1,%eax
  800f2c:	19 c0                	sbb    %eax,%eax
  800f2e:	83 e0 fe             	and    $0xfffffffe,%eax
  800f31:	83 c0 07             	add    $0x7,%eax
  800f34:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  800f3a:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  800f3d:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  800f43:	8b 42 f0             	mov    -0x10(%edx),%eax
  800f46:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  800f4c:	8b 4a f4             	mov    -0xc(%edx),%ecx
  800f4f:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  800f55:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  800f58:	89 c2                	mov    %eax,%edx
  800f5a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  800f60:	74 16                	je     800f78 <spawn+0x2cc>
		va -= i;
  800f62:	29 d0                	sub    %edx,%eax
		memsz += i;
  800f64:	01 d1                	add    %edx,%ecx
  800f66:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  800f6c:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  800f72:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  800f78:	89 c7                	mov    %eax,%edi
  800f7a:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  800f81:	00 00 00 
  800f84:	e9 01 01 00 00       	jmp    80108a <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  800f89:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  800f8f:	77 27                	ja     800fb8 <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  800f9a:	57                   	push   %edi
  800f9b:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  800fa1:	e8 43 fc ff ff       	call   800be9 <sys_page_alloc>
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	0f 89 c7 00 00 00    	jns    80107a <spawn+0x3ce>
  800fb3:	e9 dd 01 00 00       	jmp    801195 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	6a 07                	push   $0x7
  800fbd:	68 00 00 40 00       	push   $0x400000
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 20 fc ff ff       	call   800be9 <sys_page_alloc>
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	0f 88 bf 01 00 00    	js     801195 <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  800fdf:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800fe2:	50                   	push   %eax
  800fe3:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  800fe9:	e8 50 03 00 00       	call   80133e <seek>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	0f 88 9a 01 00 00    	js     801195 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801004:	29 f0                	sub    %esi,%eax
  801006:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80100b:	76 05                	jbe    801012 <spawn+0x366>
  80100d:	b8 00 10 00 00       	mov    $0x1000,%eax
  801012:	50                   	push   %eax
  801013:	68 00 00 40 00       	push   $0x400000
  801018:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  80101e:	e8 9a 05 00 00       	call   8015bd <readn>
  801023:	89 c3                	mov    %eax,%ebx
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	85 c0                	test   %eax,%eax
  80102a:	0f 88 65 01 00 00    	js     801195 <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801030:	83 ec 0c             	sub    $0xc,%esp
  801033:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801039:	57                   	push   %edi
  80103a:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801040:	68 00 00 40 00       	push   $0x400000
  801045:	6a 00                	push   $0x0
  801047:	e8 5b fb ff ff       	call   800ba7 <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	79 15                	jns    801068 <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  801053:	50                   	push   %eax
  801054:	68 45 27 80 00       	push   $0x802745
  801059:	68 25 01 00 00       	push   $0x125
  80105e:	68 39 27 80 00       	push   $0x802739
  801063:	e8 78 f0 ff ff       	call   8000e0 <_panic>
			sys_page_unmap(0, UTEMP);
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	68 00 00 40 00       	push   $0x400000
  801070:	6a 00                	push   $0x0
  801072:	e8 ee fa ff ff       	call   800b65 <sys_page_unmap>
  801077:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80107a:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  801081:	10 00 00 
  801084:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80108a:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801090:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  801096:	0f 87 ed fe ff ff    	ja     800f89 <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80109c:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  8010a2:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  8010a9:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  8010b0:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  8010b6:	0f 8c 57 fe ff ff    	jl     800f13 <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8010c5:	e8 c2 05 00 00       	call   80168c <close>
  8010ca:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8010cf:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	c1 e8 16             	shr    $0x16,%eax
  8010d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010de:	a8 01                	test   $0x1,%al
  8010e0:	74 3e                	je     801120 <spawn+0x474>
  8010e2:	89 da                	mov    %ebx,%edx
  8010e4:	c1 ea 0c             	shr    $0xc,%edx
  8010e7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010ee:	a8 01                	test   $0x1,%al
  8010f0:	74 2e                	je     801120 <spawn+0x474>
  8010f2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010f9:	f6 c4 04             	test   $0x4,%ah
  8010fc:	74 22                	je     801120 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8010fe:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	25 07 0e 00 00       	and    $0xe07,%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801115:	53                   	push   %ebx
  801116:	6a 00                	push   $0x0
  801118:	e8 8a fa ff ff       	call   800ba7 <sys_page_map>
  80111d:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  801120:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801126:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80112c:	75 a4                	jne    8010d2 <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80112e:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  801135:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801148:	e8 94 f9 ff ff       	call   800ae1 <sys_env_set_trapframe>
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	79 15                	jns    801169 <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  801154:	50                   	push   %eax
  801155:	68 62 27 80 00       	push   $0x802762
  80115a:	68 86 00 00 00       	push   $0x86
  80115f:	68 39 27 80 00       	push   $0x802739
  801164:	e8 77 ef ff ff       	call   8000e0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	6a 02                	push   $0x2
  80116e:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801174:	e8 aa f9 ff ff       	call   800b23 <sys_env_set_status>
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 6d                	jns    8011ed <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  801180:	50                   	push   %eax
  801181:	68 7c 27 80 00       	push   $0x80277c
  801186:	68 89 00 00 00       	push   $0x89
  80118b:	68 39 27 80 00       	push   $0x802739
  801190:	e8 4b ef ff ff       	call   8000e0 <_panic>

	return child;

error:
	sys_env_destroy(child);
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  80119e:	e8 c7 fa ff ff       	call   800c6a <sys_env_destroy>
	close(fd);
  8011a3:	83 c4 04             	add    $0x4,%esp
  8011a6:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8011ac:	e8 db 04 00 00       	call   80168c <close>
  8011b1:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 31                	jmp    8011ed <spawn+0x541>
  8011bc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8011c1:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  8011c7:	eb 24                	jmp    8011ed <spawn+0x541>
  8011c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cc:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  8011d2:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  8011d8:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  8011de:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  8011e5:	00 00 00 
  8011e8:	e9 bc fe ff ff       	jmp    8010a9 <spawn+0x3fd>
	return r;
}
  8011ed:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  8011f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 1c             	sub    $0x1c,%esp
  801204:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801206:	8d 45 10             	lea    0x10(%ebp),%eax
  801209:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80120c:	be 00 00 00 00       	mov    $0x0,%esi
  801211:	eb 01                	jmp    801214 <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  801213:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801214:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801217:	8d 42 04             	lea    0x4(%edx),%eax
  80121a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80121d:	83 3a 00             	cmpl   $0x0,(%edx)
  801220:	75 f1                	jne    801213 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801222:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  801229:	83 e0 f0             	and    $0xfffffff0,%eax
  80122c:	29 c4                	sub    %eax,%esp
  80122e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801232:	89 c3                	mov    %eax,%ebx
  801234:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  80123c:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  801243:	00 

	va_start(vl, arg0);
  801244:	8d 45 10             	lea    0x10(%ebp),%eax
  801247:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80124a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80124f:	eb 0f                	jmp    801260 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  801251:	41                   	inc    %ecx
  801252:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801255:	8d 50 04             	lea    0x4(%eax),%edx
  801258:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80125b:	8b 00                	mov    (%eax),%eax
  80125d:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801260:	39 f1                	cmp    %esi,%ecx
  801262:	75 ed                	jne    801251 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	53                   	push   %ebx
  801268:	ff 75 08             	pushl  0x8(%ebp)
  80126b:	e8 3c fa ff ff       	call   800cac <spawn>
  801270:	89 fc                	mov    %edi,%esp
}
  801272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	c9                   	leave  
  801279:	c3                   	ret    
	...

0080127c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
  801282:	05 00 00 00 30       	add    $0x30000000,%eax
  801287:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80128f:	ff 75 08             	pushl  0x8(%ebp)
  801292:	e8 e5 ff ff ff       	call   80127c <fd2num>
  801297:	83 c4 04             	add    $0x4,%esp
  80129a:	c1 e0 0c             	shl    $0xc,%eax
  80129d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	53                   	push   %ebx
  8012a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ab:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8012b0:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b2:	89 d0                	mov    %edx,%eax
  8012b4:	c1 e8 16             	shr    $0x16,%eax
  8012b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012be:	a8 01                	test   $0x1,%al
  8012c0:	74 10                	je     8012d2 <fd_alloc+0x2e>
  8012c2:	89 d0                	mov    %edx,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
  8012c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ce:	a8 01                	test   $0x1,%al
  8012d0:	75 09                	jne    8012db <fd_alloc+0x37>
			*fd_store = fd;
  8012d2:	89 0b                	mov    %ecx,(%ebx)
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	eb 19                	jmp    8012f4 <fd_alloc+0x50>
			return 0;
  8012db:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e1:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8012e7:	75 c7                	jne    8012b0 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012f4:	5b                   	pop    %ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012fd:	83 f8 1f             	cmp    $0x1f,%eax
  801300:	77 35                	ja     801337 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801302:	c1 e0 0c             	shl    $0xc,%eax
  801305:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	c1 e8 16             	shr    $0x16,%eax
  801310:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801317:	a8 01                	test   $0x1,%al
  801319:	74 1c                	je     801337 <fd_lookup+0x40>
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	c1 e8 0c             	shr    $0xc,%eax
  801320:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801327:	a8 01                	test   $0x1,%al
  801329:	74 0c                	je     801337 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132e:	89 10                	mov    %edx,(%eax)
  801330:	b8 00 00 00 00       	mov    $0x0,%eax
  801335:	eb 05                	jmp    80133c <fd_lookup+0x45>
	return 0;
  801337:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801344:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 75 08             	pushl  0x8(%ebp)
  80134b:	e8 a7 ff ff ff       	call   8012f7 <fd_lookup>
  801350:	83 c4 08             	add    $0x8,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 0e                	js     801365 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801357:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80135d:	89 50 04             	mov    %edx,0x4(%eax)
  801360:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801365:	c9                   	leave  
  801366:	c3                   	ret    

00801367 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	53                   	push   %ebx
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801374:	ba 00 00 00 00       	mov    $0x0,%edx
  801379:	eb 0e                	jmp    801389 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80137b:	3b 08                	cmp    (%eax),%ecx
  80137d:	75 09                	jne    801388 <dev_lookup+0x21>
			*dev = devtab[i];
  80137f:	89 03                	mov    %eax,(%ebx)
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	eb 31                	jmp    8013b9 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801388:	42                   	inc    %edx
  801389:	8b 04 95 38 28 80 00 	mov    0x802838(,%edx,4),%eax
  801390:	85 c0                	test   %eax,%eax
  801392:	75 e7                	jne    80137b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801394:	a1 04 40 80 00       	mov    0x804004,%eax
  801399:	8b 40 48             	mov    0x48(%eax),%eax
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	51                   	push   %ecx
  8013a0:	50                   	push   %eax
  8013a1:	68 bc 27 80 00       	push   $0x8027bc
  8013a6:	e8 d6 ed ff ff       	call   800181 <cprintf>
	*dev = 0;
  8013ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b6:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  8013b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 14             	sub    $0x14,%esp
  8013c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 08             	pushl  0x8(%ebp)
  8013cf:	e8 23 ff ff ff       	call   8012f7 <fd_lookup>
  8013d4:	83 c4 08             	add    $0x8,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 55                	js     801430 <fstat+0x72>
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e5:	ff 30                	pushl  (%eax)
  8013e7:	e8 7b ff ff ff       	call   801367 <dev_lookup>
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 3d                	js     801430 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013fa:	75 07                	jne    801403 <fstat+0x45>
  8013fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801401:	eb 2d                	jmp    801430 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801403:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801406:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80140d:	00 00 00 
	stat->st_isdir = 0;
  801410:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801417:	00 00 00 
	stat->st_dev = dev;
  80141a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80141d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	53                   	push   %ebx
  801427:	ff 75 f4             	pushl  -0xc(%ebp)
  80142a:	ff 50 14             	call   *0x14(%eax)
  80142d:	83 c4 10             	add    $0x10,%esp
}
  801430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 14             	sub    $0x14,%esp
  80143c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	53                   	push   %ebx
  801444:	e8 ae fe ff ff       	call   8012f7 <fd_lookup>
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 5f                	js     8014af <ftruncate+0x7a>
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145a:	ff 30                	pushl  (%eax)
  80145c:	e8 06 ff ff ff       	call   801367 <dev_lookup>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 47                	js     8014af <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80146f:	75 21                	jne    801492 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801471:	a1 04 40 80 00       	mov    0x804004,%eax
  801476:	8b 40 48             	mov    0x48(%eax),%eax
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	53                   	push   %ebx
  80147d:	50                   	push   %eax
  80147e:	68 dc 27 80 00       	push   $0x8027dc
  801483:	e8 f9 ec ff ff       	call   800181 <cprintf>
  801488:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	eb 1d                	jmp    8014af <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801492:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801495:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801499:	75 07                	jne    8014a2 <ftruncate+0x6d>
  80149b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a0:	eb 0d                	jmp    8014af <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	ff 75 0c             	pushl  0xc(%ebp)
  8014a8:	50                   	push   %eax
  8014a9:	ff 52 18             	call   *0x18(%edx)
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    

008014b4 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 14             	sub    $0x14,%esp
  8014bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	53                   	push   %ebx
  8014c3:	e8 2f fe ff ff       	call   8012f7 <fd_lookup>
  8014c8:	83 c4 08             	add    $0x8,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 62                	js     801531 <write+0x7d>
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d9:	ff 30                	pushl  (%eax)
  8014db:	e8 87 fe ff ff       	call   801367 <dev_lookup>
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 4a                	js     801531 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014ee:	75 21                	jne    801511 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014f5:	8b 40 48             	mov    0x48(%eax),%eax
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	50                   	push   %eax
  8014fd:	68 fd 27 80 00       	push   $0x8027fd
  801502:	e8 7a ec ff ff       	call   800181 <cprintf>
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	eb 20                	jmp    801531 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801511:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801514:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801518:	75 07                	jne    801521 <write+0x6d>
  80151a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80151f:	eb 10                	jmp    801531 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	ff 75 10             	pushl  0x10(%ebp)
  801527:	ff 75 0c             	pushl  0xc(%ebp)
  80152a:	50                   	push   %eax
  80152b:	ff 52 0c             	call   *0xc(%edx)
  80152e:	83 c4 10             	add    $0x10,%esp
}
  801531:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 14             	sub    $0x14,%esp
  80153d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	53                   	push   %ebx
  801545:	e8 ad fd ff ff       	call   8012f7 <fd_lookup>
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 67                	js     8015b8 <read+0x82>
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155b:	ff 30                	pushl  (%eax)
  80155d:	e8 05 fe ff ff       	call   801367 <dev_lookup>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	85 c0                	test   %eax,%eax
  801567:	78 4f                	js     8015b8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801569:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156c:	8b 42 08             	mov    0x8(%edx),%eax
  80156f:	83 e0 03             	and    $0x3,%eax
  801572:	83 f8 01             	cmp    $0x1,%eax
  801575:	75 21                	jne    801598 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801577:	a1 04 40 80 00       	mov    0x804004,%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	53                   	push   %ebx
  801583:	50                   	push   %eax
  801584:	68 1a 28 80 00       	push   $0x80281a
  801589:	e8 f3 eb ff ff       	call   800181 <cprintf>
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	eb 20                	jmp    8015b8 <read+0x82>
	}
	if (!dev->dev_read)
  801598:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80159b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80159f:	75 07                	jne    8015a8 <read+0x72>
  8015a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a6:	eb 10                	jmp    8015b8 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	ff 75 10             	pushl  0x10(%ebp)
  8015ae:	ff 75 0c             	pushl  0xc(%ebp)
  8015b1:	52                   	push   %edx
  8015b2:	ff 50 08             	call   *0x8(%eax)
  8015b5:	83 c4 10             	add    $0x10,%esp
}
  8015b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	57                   	push   %edi
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8015cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d1:	eb 21                	jmp    8015f4 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d3:	83 ec 04             	sub    $0x4,%esp
  8015d6:	89 f0                	mov    %esi,%eax
  8015d8:	29 d0                	sub    %edx,%eax
  8015da:	50                   	push   %eax
  8015db:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8015de:	50                   	push   %eax
  8015df:	ff 75 08             	pushl  0x8(%ebp)
  8015e2:	e8 4f ff ff ff       	call   801536 <read>
		if (m < 0)
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 0e                	js     8015fc <readn+0x3f>
			return m;
		if (m == 0)
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	74 08                	je     8015fa <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f2:	01 c3                	add    %eax,%ebx
  8015f4:	89 da                	mov    %ebx,%edx
  8015f6:	39 f3                	cmp    %esi,%ebx
  8015f8:	72 d9                	jb     8015d3 <readn+0x16>
  8015fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 20             	sub    $0x20,%esp
  80160c:	8b 75 08             	mov    0x8(%ebp),%esi
  80160f:	8a 45 0c             	mov    0xc(%ebp),%al
  801612:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	56                   	push   %esi
  80161a:	e8 5d fc ff ff       	call   80127c <fd2num>
  80161f:	89 04 24             	mov    %eax,(%esp)
  801622:	e8 d0 fc ff ff       	call   8012f7 <fd_lookup>
  801627:	89 c3                	mov    %eax,%ebx
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 05                	js     801635 <fd_close+0x31>
  801630:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801633:	74 0d                	je     801642 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801635:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801639:	75 48                	jne    801683 <fd_close+0x7f>
  80163b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801640:	eb 41                	jmp    801683 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 36                	pushl  (%esi)
  80164b:	e8 17 fd ff ff       	call   801367 <dev_lookup>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 1c                	js     801675 <fd_close+0x71>
		if (dev->dev_close)
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	8b 40 10             	mov    0x10(%eax),%eax
  80165f:	85 c0                	test   %eax,%eax
  801661:	75 07                	jne    80166a <fd_close+0x66>
  801663:	bb 00 00 00 00       	mov    $0x0,%ebx
  801668:	eb 0b                	jmp    801675 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	56                   	push   %esi
  80166e:	ff d0                	call   *%eax
  801670:	89 c3                	mov    %eax,%ebx
  801672:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	56                   	push   %esi
  801679:	6a 00                	push   $0x0
  80167b:	e8 e5 f4 ff ff       	call   800b65 <sys_page_unmap>
  801680:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801683:	89 d8                	mov    %ebx,%eax
  801685:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801692:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 59 fc ff ff       	call   8012f7 <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 10                	js     8016b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	6a 01                	push   $0x1
  8016aa:	ff 75 fc             	pushl  -0x4(%ebp)
  8016ad:	e8 52 ff ff ff       	call   801604 <fd_close>
  8016b2:	83 c4 10             	add    $0x10,%esp
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016bc:	83 ec 08             	sub    $0x8,%esp
  8016bf:	6a 00                	push   $0x0
  8016c1:	ff 75 08             	pushl  0x8(%ebp)
  8016c4:	e8 4a 03 00 00       	call   801a13 <open>
  8016c9:	89 c6                	mov    %eax,%esi
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 1b                	js     8016ed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	50                   	push   %eax
  8016d9:	e8 e0 fc ff ff       	call   8013be <fstat>
  8016de:	89 c3                	mov    %eax,%ebx
	close(fd);
  8016e0:	89 34 24             	mov    %esi,(%esp)
  8016e3:	e8 a4 ff ff ff       	call   80168c <close>
  8016e8:	89 de                	mov    %ebx,%esi
  8016ea:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8016ed:	89 f0                	mov    %esi,%eax
  8016ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 1c             	sub    $0x1c,%esp
  8016ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801702:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	ff 75 08             	pushl  0x8(%ebp)
  801709:	e8 e9 fb ff ff       	call   8012f7 <fd_lookup>
  80170e:	89 c3                	mov    %eax,%ebx
  801710:	83 c4 08             	add    $0x8,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	0f 88 bd 00 00 00    	js     8017d8 <dup+0xe2>
		return r;
	close(newfdnum);
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	57                   	push   %edi
  80171f:	e8 68 ff ff ff       	call   80168c <close>

	newfd = INDEX2FD(newfdnum);
  801724:	89 f8                	mov    %edi,%eax
  801726:	c1 e0 0c             	shl    $0xc,%eax
  801729:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80172f:	ff 75 f0             	pushl  -0x10(%ebp)
  801732:	e8 55 fb ff ff       	call   80128c <fd2data>
  801737:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801739:	89 34 24             	mov    %esi,(%esp)
  80173c:	e8 4b fb ff ff       	call   80128c <fd2data>
  801741:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801744:	89 d8                	mov    %ebx,%eax
  801746:	c1 e8 16             	shr    $0x16,%eax
  801749:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801750:	83 c4 14             	add    $0x14,%esp
  801753:	a8 01                	test   $0x1,%al
  801755:	74 36                	je     80178d <dup+0x97>
  801757:	89 da                	mov    %ebx,%edx
  801759:	c1 ea 0c             	shr    $0xc,%edx
  80175c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801763:	a8 01                	test   $0x1,%al
  801765:	74 26                	je     80178d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801767:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	25 07 0e 00 00       	and    $0xe07,%eax
  801776:	50                   	push   %eax
  801777:	ff 75 e0             	pushl  -0x20(%ebp)
  80177a:	6a 00                	push   $0x0
  80177c:	53                   	push   %ebx
  80177d:	6a 00                	push   $0x0
  80177f:	e8 23 f4 ff ff       	call   800ba7 <sys_page_map>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	83 c4 20             	add    $0x20,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 30                	js     8017bd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80178d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801790:	89 d0                	mov    %edx,%eax
  801792:	c1 e8 0c             	shr    $0xc,%eax
  801795:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80179c:	83 ec 0c             	sub    $0xc,%esp
  80179f:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a4:	50                   	push   %eax
  8017a5:	56                   	push   %esi
  8017a6:	6a 00                	push   $0x0
  8017a8:	52                   	push   %edx
  8017a9:	6a 00                	push   $0x0
  8017ab:	e8 f7 f3 ff ff       	call   800ba7 <sys_page_map>
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	83 c4 20             	add    $0x20,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 04                	js     8017bd <dup+0xc7>
		goto err;
  8017b9:	89 fb                	mov    %edi,%ebx
  8017bb:	eb 1b                	jmp    8017d8 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	56                   	push   %esi
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 9d f3 ff ff       	call   800b65 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017c8:	83 c4 08             	add    $0x8,%esp
  8017cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 90 f3 ff ff       	call   800b65 <sys_page_unmap>
  8017d5:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5f                   	pop    %edi
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	53                   	push   %ebx
  8017e6:	83 ec 04             	sub    $0x4,%esp
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8017ee:	83 ec 0c             	sub    $0xc,%esp
  8017f1:	53                   	push   %ebx
  8017f2:	e8 95 fe ff ff       	call   80168c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017f7:	43                   	inc    %ebx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	83 fb 20             	cmp    $0x20,%ebx
  8017fe:	75 ee                	jne    8017ee <close_all+0xc>
		close(i);
}
  801800:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801803:	c9                   	leave  
  801804:	c3                   	ret    
  801805:	00 00                	add    %al,(%eax)
	...

00801808 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801811:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801818:	75 12                	jne    80182c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	6a 01                	push   $0x1
  80181f:	e8 48 07 00 00       	call   801f6c <ipc_find_env>
  801824:	a3 00 40 80 00       	mov    %eax,0x804000
  801829:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182c:	6a 07                	push   $0x7
  80182e:	68 00 50 80 00       	push   $0x805000
  801833:	53                   	push   %ebx
  801834:	ff 35 00 40 80 00    	pushl  0x804000
  80183a:	e8 72 07 00 00       	call   801fb1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183f:	83 c4 0c             	add    $0xc,%esp
  801842:	6a 00                	push   $0x0
  801844:	56                   	push   %esi
  801845:	6a 00                	push   $0x0
  801847:	e8 ba 07 00 00       	call   802006 <ipc_recv>
}
  80184c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184f:	5b                   	pop    %ebx
  801850:	5e                   	pop    %esi
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 08 00 00 00       	mov    $0x8,%eax
  801863:	e8 a0 ff ff ff       	call   801808 <fsipc>
}
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 40 0c             	mov    0xc(%eax),%eax
  801876:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80187b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 02 00 00 00       	mov    $0x2,%eax
  80188d:	e8 76 ff ff ff       	call   801808 <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8018af:	e8 54 ff ff ff       	call   801808 <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d5:	e8 2e ff ff ff       	call   801808 <fsipc>
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 2c                	js     80190a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	68 00 50 80 00       	push   $0x805000
  8018e6:	53                   	push   %ebx
  8018e7:	e8 e7 ed ff ff       	call   8006d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801902:	b8 00 00 00 00       	mov    $0x0,%eax
  801907:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80190a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801924:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80192a:	53                   	push   %ebx
  80192b:	ff 75 0c             	pushl  0xc(%ebp)
  80192e:	68 08 50 80 00       	push   $0x805008
  801933:	e8 08 ef ff ff       	call   800840 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801938:	ba 00 00 00 00       	mov    $0x0,%edx
  80193d:	b8 04 00 00 00       	mov    $0x4,%eax
  801942:	e8 c1 fe ff ff       	call   801808 <fsipc>
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 3d                	js     80198b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80194e:	39 c3                	cmp    %eax,%ebx
  801950:	73 19                	jae    80196b <devfile_write+0x5c>
  801952:	68 48 28 80 00       	push   $0x802848
  801957:	68 24 27 80 00       	push   $0x802724
  80195c:	68 97 00 00 00       	push   $0x97
  801961:	68 4f 28 80 00       	push   $0x80284f
  801966:	e8 75 e7 ff ff       	call   8000e0 <_panic>
	assert(r <= PGSIZE);
  80196b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801970:	7e 19                	jle    80198b <devfile_write+0x7c>
  801972:	68 5a 28 80 00       	push   $0x80285a
  801977:	68 24 27 80 00       	push   $0x802724
  80197c:	68 98 00 00 00       	push   $0x98
  801981:	68 4f 28 80 00       	push   $0x80284f
  801986:	e8 55 e7 ff ff       	call   8000e0 <_panic>
	
	return r;
}
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	8b 40 0c             	mov    0xc(%eax),%eax
  80199e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b3:	e8 50 fe ff ff       	call   801808 <fsipc>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 4c                	js     801a0a <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8019be:	39 de                	cmp    %ebx,%esi
  8019c0:	73 16                	jae    8019d8 <devfile_read+0x48>
  8019c2:	68 48 28 80 00       	push   $0x802848
  8019c7:	68 24 27 80 00       	push   $0x802724
  8019cc:	6a 7c                	push   $0x7c
  8019ce:	68 4f 28 80 00       	push   $0x80284f
  8019d3:	e8 08 e7 ff ff       	call   8000e0 <_panic>
	assert(r <= PGSIZE);
  8019d8:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8019de:	7e 16                	jle    8019f6 <devfile_read+0x66>
  8019e0:	68 5a 28 80 00       	push   $0x80285a
  8019e5:	68 24 27 80 00       	push   $0x802724
  8019ea:	6a 7d                	push   $0x7d
  8019ec:	68 4f 28 80 00       	push   $0x80284f
  8019f1:	e8 ea e6 ff ff       	call   8000e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f6:	83 ec 04             	sub    $0x4,%esp
  8019f9:	50                   	push   %eax
  8019fa:	68 00 50 80 00       	push   $0x805000
  8019ff:	ff 75 0c             	pushl  0xc(%ebp)
  801a02:	e8 39 ee ff ff       	call   800840 <memmove>
  801a07:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801a0a:	89 d8                	mov    %ebx,%eax
  801a0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	83 ec 1c             	sub    $0x1c,%esp
  801a1b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a1e:	56                   	push   %esi
  801a1f:	e8 7c ec ff ff       	call   8006a0 <strlen>
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2c:	7e 07                	jle    801a35 <open+0x22>
  801a2e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a33:	eb 63                	jmp    801a98 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a35:	83 ec 0c             	sub    $0xc,%esp
  801a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 63 f8 ff ff       	call   8012a4 <fd_alloc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 4e                	js     801a98 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	56                   	push   %esi
  801a4e:	68 00 50 80 00       	push   $0x805000
  801a53:	e8 7b ec ff ff       	call   8006d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a63:	b8 01 00 00 00       	mov    $0x1,%eax
  801a68:	e8 9b fd ff ff       	call   801808 <fsipc>
  801a6d:	89 c3                	mov    %eax,%ebx
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	79 12                	jns    801a88 <open+0x75>
		fd_close(fd, 0);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	6a 00                	push   $0x0
  801a7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7e:	e8 81 fb ff ff       	call   801604 <fd_close>
		return r;
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	eb 10                	jmp    801a98 <open+0x85>
	}

	return fd2num(fd);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8e:	e8 e9 f7 ff ff       	call   80127c <fd2num>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	83 c4 10             	add    $0x10,%esp
}
  801a98:	89 d8                	mov    %ebx,%eax
  801a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    
  801aa1:	00 00                	add    %al,(%eax)
	...

00801aa4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	ff 75 08             	pushl  0x8(%ebp)
  801ab2:	e8 d5 f7 ff ff       	call   80128c <fd2data>
  801ab7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab9:	83 c4 08             	add    $0x8,%esp
  801abc:	68 66 28 80 00       	push   $0x802866
  801ac1:	53                   	push   %ebx
  801ac2:	e8 0c ec ff ff       	call   8006d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac7:	8b 46 04             	mov    0x4(%esi),%eax
  801aca:	2b 06                	sub    (%esi),%eax
  801acc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad9:	00 00 00 
	stat->st_dev = &devpipe;
  801adc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ae3:	30 80 00 
	return 0;
}
  801ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  801aeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aee:	5b                   	pop    %ebx
  801aef:	5e                   	pop    %esi
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	53                   	push   %ebx
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801afc:	53                   	push   %ebx
  801afd:	6a 00                	push   $0x0
  801aff:	e8 61 f0 ff ff       	call   800b65 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b04:	89 1c 24             	mov    %ebx,(%esp)
  801b07:	e8 80 f7 ff ff       	call   80128c <fd2data>
  801b0c:	83 c4 08             	add    $0x8,%esp
  801b0f:	50                   	push   %eax
  801b10:	6a 00                	push   $0x0
  801b12:	e8 4e f0 ff ff       	call   800b65 <sys_page_unmap>
}
  801b17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	57                   	push   %edi
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 0c             	sub    $0xc,%esp
  801b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b28:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b32:	83 ec 0c             	sub    $0xc,%esp
  801b35:	ff 75 f0             	pushl  -0x10(%ebp)
  801b38:	e8 33 05 00 00       	call   802070 <pageref>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	89 3c 24             	mov    %edi,(%esp)
  801b42:	e8 29 05 00 00       	call   802070 <pageref>
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	39 c3                	cmp    %eax,%ebx
  801b4c:	0f 94 c0             	sete   %al
  801b4f:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801b52:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b58:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801b5b:	39 c6                	cmp    %eax,%esi
  801b5d:	74 1b                	je     801b7a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801b5f:	83 f9 01             	cmp    $0x1,%ecx
  801b62:	75 c6                	jne    801b2a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b64:	8b 42 58             	mov    0x58(%edx),%eax
  801b67:	6a 01                	push   $0x1
  801b69:	50                   	push   %eax
  801b6a:	56                   	push   %esi
  801b6b:	68 6d 28 80 00       	push   $0x80286d
  801b70:	e8 0c e6 ff ff       	call   800181 <cprintf>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	eb b0                	jmp    801b2a <_pipeisclosed+0xe>
	}
}
  801b7a:	89 c8                	mov    %ecx,%eax
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 18             	sub    $0x18,%esp
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b90:	56                   	push   %esi
  801b91:	e8 f6 f6 ff ff       	call   80128c <fd2data>
  801b96:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b9e:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb 40                	jmp    801be8 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bad:	eb 40                	jmp    801bef <devpipe_write+0x6b>
  801baf:	89 da                	mov    %ebx,%edx
  801bb1:	89 f0                	mov    %esi,%eax
  801bb3:	e8 64 ff ff ff       	call   801b1c <_pipeisclosed>
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	75 ec                	jne    801ba8 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bbc:	e8 6b f0 ff ff       	call   800c2c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bc1:	8b 53 04             	mov    0x4(%ebx),%edx
  801bc4:	8b 03                	mov    (%ebx),%eax
  801bc6:	83 c0 20             	add    $0x20,%eax
  801bc9:	39 c2                	cmp    %eax,%edx
  801bcb:	73 e2                	jae    801baf <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bcd:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801bd3:	79 05                	jns    801bda <devpipe_write+0x56>
  801bd5:	4a                   	dec    %edx
  801bd6:	83 ca e0             	or     $0xffffffe0,%edx
  801bd9:	42                   	inc    %edx
  801bda:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801bdd:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801be0:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be4:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be7:	47                   	inc    %edi
  801be8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801beb:	75 d4                	jne    801bc1 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bed:	89 f8                	mov    %edi,%eax
}
  801bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf2:	5b                   	pop    %ebx
  801bf3:	5e                   	pop    %esi
  801bf4:	5f                   	pop    %edi
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	57                   	push   %edi
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 18             	sub    $0x18,%esp
  801c00:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c03:	57                   	push   %edi
  801c04:	e8 83 f6 ff ff       	call   80128c <fd2data>
  801c09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801c11:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	eb 41                	jmp    801c5c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801c1b:	89 f0                	mov    %esi,%eax
  801c1d:	eb 44                	jmp    801c63 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c24:	eb 3d                	jmp    801c63 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c26:	85 f6                	test   %esi,%esi
  801c28:	75 f1                	jne    801c1b <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c2a:	89 da                	mov    %ebx,%edx
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	e8 e9 fe ff ff       	call   801b1c <_pipeisclosed>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	75 e8                	jne    801c1f <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c37:	e8 f0 ef ff ff       	call   800c2c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c3c:	8b 03                	mov    (%ebx),%eax
  801c3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c41:	74 e3                	je     801c26 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c43:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c48:	79 05                	jns    801c4f <devpipe_read+0x58>
  801c4a:	48                   	dec    %eax
  801c4b:	83 c8 e0             	or     $0xffffffe0,%eax
  801c4e:	40                   	inc    %eax
  801c4f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c53:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c56:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801c59:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5b:	46                   	inc    %esi
  801c5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c5f:	75 db                	jne    801c3c <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c61:	89 f0                	mov    %esi,%eax
}
  801c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5f                   	pop    %edi
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c71:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c74:	50                   	push   %eax
  801c75:	ff 75 08             	pushl  0x8(%ebp)
  801c78:	e8 7a f6 ff ff       	call   8012f7 <fd_lookup>
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 18                	js     801c9c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	ff 75 fc             	pushl  -0x4(%ebp)
  801c8a:	e8 fd f5 ff ff       	call   80128c <fd2data>
  801c8f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c94:	e8 83 fe ff ff       	call   801b1c <_pipeisclosed>
  801c99:	83 c4 10             	add    $0x10,%esp
}
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 28             	sub    $0x28,%esp
  801ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801caa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cad:	50                   	push   %eax
  801cae:	e8 f1 f5 ff ff       	call   8012a4 <fd_alloc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 24 01 00 00    	js     801de4 <pipe+0x146>
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	68 07 04 00 00       	push   $0x407
  801cc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 17 ef ff ff       	call   800be9 <sys_page_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 05 01 00 00    	js     801de4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cdf:	83 ec 0c             	sub    $0xc,%esp
  801ce2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ce5:	50                   	push   %eax
  801ce6:	e8 b9 f5 ff ff       	call   8012a4 <fd_alloc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	0f 88 dc 00 00 00    	js     801dd4 <pipe+0x136>
  801cf8:	83 ec 04             	sub    $0x4,%esp
  801cfb:	68 07 04 00 00       	push   $0x407
  801d00:	ff 75 ec             	pushl  -0x14(%ebp)
  801d03:	6a 00                	push   $0x0
  801d05:	e8 df ee ff ff       	call   800be9 <sys_page_alloc>
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	83 c4 10             	add    $0x10,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	0f 88 bd 00 00 00    	js     801dd4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1d:	e8 6a f5 ff ff       	call   80128c <fd2data>
  801d22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d24:	83 c4 0c             	add    $0xc,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	50                   	push   %eax
  801d2d:	6a 00                	push   $0x0
  801d2f:	e8 b5 ee ff ff       	call   800be9 <sys_page_alloc>
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 83 00 00 00    	js     801dc4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	ff 75 ec             	pushl  -0x14(%ebp)
  801d47:	e8 40 f5 ff ff       	call   80128c <fd2data>
  801d4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d53:	50                   	push   %eax
  801d54:	6a 00                	push   $0x0
  801d56:	56                   	push   %esi
  801d57:	6a 00                	push   $0x0
  801d59:	e8 49 ee ff ff       	call   800ba7 <sys_page_map>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	83 c4 20             	add    $0x20,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 4f                	js     801db6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d7c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d91:	83 ec 0c             	sub    $0xc,%esp
  801d94:	ff 75 f0             	pushl  -0x10(%ebp)
  801d97:	e8 e0 f4 ff ff       	call   80127c <fd2num>
  801d9c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d9e:	83 c4 04             	add    $0x4,%esp
  801da1:	ff 75 ec             	pushl  -0x14(%ebp)
  801da4:	e8 d3 f4 ff ff       	call   80127c <fd2num>
  801da9:	89 47 04             	mov    %eax,0x4(%edi)
  801dac:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	eb 2e                	jmp    801de4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801db6:	83 ec 08             	sub    $0x8,%esp
  801db9:	56                   	push   %esi
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 a4 ed ff ff       	call   800b65 <sys_page_unmap>
  801dc1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	ff 75 ec             	pushl  -0x14(%ebp)
  801dca:	6a 00                	push   $0x0
  801dcc:	e8 94 ed ff ff       	call   800b65 <sys_page_unmap>
  801dd1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 84 ed ff ff       	call   800b65 <sys_page_unmap>
  801de1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801de4:	89 d8                	mov    %ebx,%eax
  801de6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de9:	5b                   	pop    %ebx
  801dea:	5e                   	pop    %esi
  801deb:	5f                   	pop    %edi
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    
	...

00801df0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e00:	68 85 28 80 00       	push   $0x802885
  801e05:	ff 75 0c             	pushl  0xc(%ebp)
  801e08:	e8 c6 e8 ff ff       	call   8006d3 <strcpy>
	return 0;
}
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e12:	c9                   	leave  
  801e13:	c3                   	ret    

00801e14 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	57                   	push   %edi
  801e18:	56                   	push   %esi
  801e19:	53                   	push   %ebx
  801e1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801e20:	be 00 00 00 00       	mov    $0x0,%esi
  801e25:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801e2b:	eb 2c                	jmp    801e59 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e30:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e32:	83 fb 7f             	cmp    $0x7f,%ebx
  801e35:	76 05                	jbe    801e3c <devcons_write+0x28>
  801e37:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	53                   	push   %ebx
  801e40:	03 45 0c             	add    0xc(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	57                   	push   %edi
  801e45:	e8 f6 e9 ff ff       	call   800840 <memmove>
		sys_cputs(buf, m);
  801e4a:	83 c4 08             	add    $0x8,%esp
  801e4d:	53                   	push   %ebx
  801e4e:	57                   	push   %edi
  801e4f:	e8 c3 eb ff ff       	call   800a17 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e54:	01 de                	add    %ebx,%esi
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	89 f0                	mov    %esi,%eax
  801e5b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5e:	72 cd                	jb     801e2d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5f                   	pop    %edi
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e71:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e74:	6a 01                	push   $0x1
  801e76:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801e79:	50                   	push   %eax
  801e7a:	e8 98 eb ff ff       	call   800a17 <sys_cputs>
  801e7f:	83 c4 10             	add    $0x10,%esp
}
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e8e:	74 27                	je     801eb7 <devcons_read+0x33>
  801e90:	eb 05                	jmp    801e97 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e92:	e8 95 ed ff ff       	call   800c2c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e97:	e8 5c eb ff ff       	call   8009f8 <sys_cgetc>
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	74 f0                	je     801e92 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 16                	js     801ebc <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ea6:	83 f8 04             	cmp    $0x4,%eax
  801ea9:	74 0c                	je     801eb7 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eae:	88 10                	mov    %dl,(%eax)
  801eb0:	ba 01 00 00 00       	mov    $0x1,%edx
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x38>
	return 1;
  801eb7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ebc:	89 d0                	mov    %edx,%eax
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ec9:	50                   	push   %eax
  801eca:	e8 d5 f3 ff ff       	call   8012a4 <fd_alloc>
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 3b                	js     801f11 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed6:	83 ec 04             	sub    $0x4,%esp
  801ed9:	68 07 04 00 00       	push   $0x407
  801ede:	ff 75 fc             	pushl  -0x4(%ebp)
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 01 ed ff ff       	call   800be9 <sys_page_alloc>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 22                	js     801f11 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eef:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801ef4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801ef7:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801ef9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801efc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	ff 75 fc             	pushl  -0x4(%ebp)
  801f09:	e8 6e f3 ff ff       	call   80127c <fd2num>
  801f0e:	83 c4 10             	add    $0x10,%esp
}
  801f11:	c9                   	leave  
  801f12:	c3                   	ret    

00801f13 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f19:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	ff 75 08             	pushl  0x8(%ebp)
  801f20:	e8 d2 f3 ff ff       	call   8012f7 <fd_lookup>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 11                	js     801f3d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f2f:	8b 00                	mov    (%eax),%eax
  801f31:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801f37:	0f 94 c0             	sete   %al
  801f3a:	0f b6 c0             	movzbl %al,%eax
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f45:	6a 01                	push   $0x1
  801f47:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801f4a:	50                   	push   %eax
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 e4 f5 ff ff       	call   801536 <read>
	if (r < 0)
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 0f                	js     801f68 <getchar+0x29>
		return r;
	if (r < 1)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	75 07                	jne    801f64 <getchar+0x25>
  801f5d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f62:	eb 04                	jmp    801f68 <getchar+0x29>
		return -E_EOF;
	return c;
  801f64:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    
	...

00801f6c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	53                   	push   %ebx
  801f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f73:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f78:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801f7f:	89 c8                	mov    %ecx,%eax
  801f81:	c1 e0 07             	shl    $0x7,%eax
  801f84:	29 d0                	sub    %edx,%eax
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801f8e:	8b 40 50             	mov    0x50(%eax),%eax
  801f91:	39 d8                	cmp    %ebx,%eax
  801f93:	75 0b                	jne    801fa0 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f95:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801f9b:	8b 40 40             	mov    0x40(%eax),%eax
  801f9e:	eb 0e                	jmp    801fae <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa0:	41                   	inc    %ecx
  801fa1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801fa7:	75 cf                	jne    801f78 <ipc_find_env+0xc>
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801fae:	5b                   	pop    %ebx
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	57                   	push   %edi
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801fc3:	85 db                	test   %ebx,%ebx
  801fc5:	75 05                	jne    801fcc <ipc_send+0x1b>
  801fc7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	57                   	push   %edi
  801fcf:	ff 75 08             	pushl  0x8(%ebp)
  801fd2:	e8 a5 ea ff ff       	call   800a7c <sys_ipc_try_send>
		if (r == 0) {		//success
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	74 20                	je     801ffe <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801fde:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe1:	75 07                	jne    801fea <ipc_send+0x39>
			sys_yield();
  801fe3:	e8 44 ec ff ff       	call   800c2c <sys_yield>
  801fe8:	eb e2                	jmp    801fcc <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	68 94 28 80 00       	push   $0x802894
  801ff2:	6a 41                	push   $0x41
  801ff4:	68 b8 28 80 00       	push   $0x8028b8
  801ff9:	e8 e2 e0 ff ff       	call   8000e0 <_panic>
		}
	}
}
  801ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5f                   	pop    %edi
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80200e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802011:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802014:	85 c0                	test   %eax,%eax
  802016:	75 05                	jne    80201d <ipc_recv+0x17>
  802018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  80201d:	83 ec 0c             	sub    $0xc,%esp
  802020:	50                   	push   %eax
  802021:	e8 15 ea ff ff       	call   800a3b <sys_ipc_recv>
	if (r < 0) {				
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	85 c0                	test   %eax,%eax
  80202b:	79 16                	jns    802043 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  80202d:	85 db                	test   %ebx,%ebx
  80202f:	74 06                	je     802037 <ipc_recv+0x31>
  802031:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  802037:	85 f6                	test   %esi,%esi
  802039:	74 2c                	je     802067 <ipc_recv+0x61>
  80203b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802041:	eb 24                	jmp    802067 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  802043:	85 db                	test   %ebx,%ebx
  802045:	74 0a                	je     802051 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802047:	a1 04 40 80 00       	mov    0x804004,%eax
  80204c:	8b 40 74             	mov    0x74(%eax),%eax
  80204f:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  802051:	85 f6                	test   %esi,%esi
  802053:	74 0a                	je     80205f <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802055:	a1 04 40 80 00       	mov    0x804004,%eax
  80205a:	8b 40 78             	mov    0x78(%eax),%eax
  80205d:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80205f:	a1 04 40 80 00       	mov    0x804004,%eax
  802064:	8b 40 70             	mov    0x70(%eax),%eax
}
  802067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    
	...

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802076:	89 d0                	mov    %edx,%eax
  802078:	c1 e8 16             	shr    $0x16,%eax
  80207b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802082:	a8 01                	test   $0x1,%al
  802084:	74 20                	je     8020a6 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802086:	89 d0                	mov    %edx,%eax
  802088:	c1 e8 0c             	shr    $0xc,%eax
  80208b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802092:	a8 01                	test   $0x1,%al
  802094:	74 10                	je     8020a6 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802096:	c1 e8 0c             	shr    $0xc,%eax
  802099:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020a0:	ef 
  8020a1:	0f b7 c0             	movzwl %ax,%eax
  8020a4:	eb 05                	jmp    8020ab <pageref+0x3b>
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    
  8020ad:	00 00                	add    %al,(%eax)
	...

008020b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	83 ec 28             	sub    $0x28,%esp
  8020b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8020bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8020c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8020cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020cf:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8020d1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  8020d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  8020d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020dc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020df:	85 ff                	test   %edi,%edi
  8020e1:	75 21                	jne    802104 <__udivdi3+0x54>
    {
      if (d0 > n1)
  8020e3:	39 d1                	cmp    %edx,%ecx
  8020e5:	76 49                	jbe    802130 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020e7:	f7 f1                	div    %ecx
  8020e9:	89 c1                	mov    %eax,%ecx
  8020eb:	31 c0                	xor    %eax,%eax
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020f0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8020f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8020f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8020fc:	83 c4 28             	add    $0x28,%esp
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	c9                   	leave  
  802102:	c3                   	ret    
  802103:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802104:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802107:	0f 87 97 00 00 00    	ja     8021a4 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80210d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802110:	83 f0 1f             	xor    $0x1f,%eax
  802113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802116:	75 34                	jne    80214c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802118:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80211b:	72 08                	jb     802125 <__udivdi3+0x75>
  80211d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802120:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802123:	77 7f                	ja     8021a4 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802125:	b9 01 00 00 00       	mov    $0x1,%ecx
  80212a:	31 c0                	xor    %eax,%eax
  80212c:	eb c2                	jmp    8020f0 <__udivdi3+0x40>
  80212e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802133:	85 c0                	test   %eax,%eax
  802135:	74 79                	je     8021b0 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802137:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	f7 f1                	div    %ecx
  80213e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802140:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802143:	f7 f1                	div    %ecx
  802145:	89 c1                	mov    %eax,%ecx
  802147:	89 f0                	mov    %esi,%eax
  802149:	eb a5                	jmp    8020f0 <__udivdi3+0x40>
  80214b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80214c:	b8 20 00 00 00       	mov    $0x20,%eax
  802151:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802154:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802157:	89 fa                	mov    %edi,%edx
  802159:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80215c:	d3 e2                	shl    %cl,%edx
  80215e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802161:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802164:	d3 e8                	shr    %cl,%eax
  802166:	89 d7                	mov    %edx,%edi
  802168:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80216a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80216d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802170:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802172:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802175:	d3 e0                	shl    %cl,%eax
  802177:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80217a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80217d:	d3 ea                	shr    %cl,%edx
  80217f:	09 d0                	or     %edx,%eax
  802181:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802184:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802187:	d3 ea                	shr    %cl,%edx
  802189:	f7 f7                	div    %edi
  80218b:	89 d7                	mov    %edx,%edi
  80218d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802190:	f7 e6                	mul    %esi
  802192:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802194:	39 d7                	cmp    %edx,%edi
  802196:	72 38                	jb     8021d0 <__udivdi3+0x120>
  802198:	74 27                	je     8021c1 <__udivdi3+0x111>
  80219a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80219d:	31 c0                	xor    %eax,%eax
  80219f:	e9 4c ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021a4:	31 c9                	xor    %ecx,%ecx
  8021a6:	31 c0                	xor    %eax,%eax
  8021a8:	e9 43 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b5:	31 d2                	xor    %edx,%edx
  8021b7:	f7 75 f4             	divl   -0xc(%ebp)
  8021ba:	89 c1                	mov    %eax,%ecx
  8021bc:	e9 76 ff ff ff       	jmp    802137 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021c4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	39 f0                	cmp    %esi,%eax
  8021cb:	73 cd                	jae    80219a <__udivdi3+0xea>
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8021d3:	49                   	dec    %ecx
  8021d4:	31 c0                	xor    %eax,%eax
  8021d6:	e9 15 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
	...

008021dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	83 ec 30             	sub    $0x30,%esp
  8021e4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8021eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8021f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8021fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802201:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802203:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  802206:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  802209:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80220c:	85 d2                	test   %edx,%edx
  80220e:	75 1c                	jne    80222c <__umoddi3+0x50>
    {
      if (d0 > n1)
  802210:	89 fa                	mov    %edi,%edx
  802212:	39 f8                	cmp    %edi,%eax
  802214:	0f 86 c2 00 00 00    	jbe    8022dc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80221a:	89 f0                	mov    %esi,%eax
  80221c:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80221e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802221:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802228:	eb 12                	jmp    80223c <__umoddi3+0x60>
  80222a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80222c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80222f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802232:	76 18                	jbe    80224c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802234:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  802237:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80223a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80223c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80223f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802242:	83 c4 30             	add    $0x30,%esp
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	c9                   	leave  
  802248:	c3                   	ret    
  802249:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80224c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802250:	83 f0 1f             	xor    $0x1f,%eax
  802253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802256:	0f 84 ac 00 00 00    	je     802308 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80225c:	b8 20 00 00 00       	mov    $0x20,%eax
  802261:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802264:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802267:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80226a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80226d:	d3 e2                	shl    %cl,%edx
  80226f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802272:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802275:	d3 e8                	shr    %cl,%eax
  802277:	89 d6                	mov    %edx,%esi
  802279:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80227b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80227e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802281:	d3 e0                	shl    %cl,%eax
  802283:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802286:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802289:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80228b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80228e:	d3 e0                	shl    %cl,%eax
  802290:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802293:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802296:	d3 ea                	shr    %cl,%edx
  802298:	09 d0                	or     %edx,%eax
  80229a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80229d:	d3 ea                	shr    %cl,%edx
  80229f:	f7 f6                	div    %esi
  8022a1:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8022a4:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022a7:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8022aa:	0f 82 8d 00 00 00    	jb     80233d <__umoddi3+0x161>
  8022b0:	0f 84 91 00 00 00    	je     802347 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022b6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022b9:	29 c7                	sub    %eax,%edi
  8022bb:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8022c2:	d3 e2                	shl    %cl,%edx
  8022c4:	89 f8                	mov    %edi,%eax
  8022c6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8022c9:	d3 e8                	shr    %cl,%eax
  8022cb:	09 c2                	or     %eax,%edx
  8022cd:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8022d0:	d3 ee                	shr    %cl,%esi
  8022d2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8022d5:	e9 62 ff ff ff       	jmp    80223c <__umoddi3+0x60>
  8022da:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	74 15                	je     8022f8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022e9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ee:	f7 f1                	div    %ecx
  8022f0:	e9 29 ff ff ff       	jmp    80221e <__umoddi3+0x42>
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	f7 75 ec             	divl   -0x14(%ebp)
  802302:	89 c1                	mov    %eax,%ecx
  802304:	eb dd                	jmp    8022e3 <__umoddi3+0x107>
  802306:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80230e:	72 19                	jb     802329 <__umoddi3+0x14d>
  802310:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802313:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  802316:	76 11                	jbe    802329 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  802318:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80231b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80231e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802321:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802324:	e9 13 ff ff ff       	jmp    80223c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802329:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80232c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802332:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802335:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802338:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80233b:	eb db                	jmp    802318 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80233d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802340:	19 f2                	sbb    %esi,%edx
  802342:	e9 6f ff ff ff       	jmp    8022b6 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802347:	39 c7                	cmp    %eax,%edi
  802349:	72 f2                	jb     80233d <__umoddi3+0x161>
  80234b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80234e:	e9 63 ff ff ff       	jmp    8022b6 <__umoddi3+0xda>
