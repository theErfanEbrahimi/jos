
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 e0 12 80 00       	push   $0x8012e0
  800040:	e8 28 01 00 00       	call   80016d <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 68 0c 00 00       	call   800cb2 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 58 13 80 00       	push   $0x801358
  80005b:	e8 0d 01 00 00       	call   80016d <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 08 13 80 00       	push   $0x801308
  80006d:	e8 fb 00 00 00       	call   80016d <cprintf>
	sys_yield();
  800072:	e8 a1 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  800077:	e8 9c 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  80007c:	e8 97 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  800081:	e8 92 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  800086:	e8 8d 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  80008b:	e8 88 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  800090:	e8 83 0b 00 00       	call   800c18 <sys_yield>
	sys_yield();
  800095:	e8 7e 0b 00 00       	call   800c18 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 30 13 80 00 	movl   $0x801330,(%esp)
  8000a1:	e8 c7 00 00 00       	call   80016d <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 a8 0b 00 00       	call   800c56 <sys_env_destroy>
  8000ae:	83 c4 10             	add    $0x10,%esp
}
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000c3:	e8 6f 0b 00 00       	call   800c37 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d4:	c1 e0 07             	shl    $0x7,%eax
  8000d7:	29 d0                	sub    %edx,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	7e 07                	jle    8000ee <libmain+0x36>
		binaryname = argv[0];
  8000e7:	8b 03                	mov    (%ebx),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	53                   	push   %ebx
  8000f2:	56                   	push   %esi
  8000f3:	e8 3c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0b 00 00 00       	call   800108 <exit>
  8000fd:	83 c4 10             	add    $0x10,%esp
}
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 41 0b 00 00       	call   800c56 <sys_env_destroy>
  800115:	83 c4 10             	add    $0x10,%esp
}
  800118:	c9                   	leave  
  800119:	c3                   	ret    
	...

0080011c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800125:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80012c:	00 00 00 
	b.cnt = 0;
  80012f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800136:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	68 84 01 80 00       	push   $0x800184
  80014b:	e8 70 01 00 00       	call   8002c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	83 c4 08             	add    $0x8,%esp
  800153:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800159:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	e8 9e 08 00 00       	call   800a03 <sys_cputs>
  800165:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
  800176:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800179:	50                   	push   %eax
  80017a:	ff 75 08             	pushl  0x8(%ebp)
  80017d:	e8 9a ff ff ff       	call   80011c <vcprintf>
	va_end(ap);

	return cnt;
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800197:	40                   	inc    %eax
  800198:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 51 08 00 00       	call   800a03 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	ff 43 04             	incl   0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    
	...

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 1c             	sub    $0x1c,%esp
  8001cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001d0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001df:	8b 55 10             	mov    0x10(%ebp),%edx
  8001e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e5:	89 d6                	mov    %edx,%esi
  8001e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ec:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001ef:	72 04                	jb     8001f5 <printnum+0x31>
  8001f1:	39 c2                	cmp    %eax,%edx
  8001f3:	77 3f                	ja     800234 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001fe:	50                   	push   %eax
  8001ff:	52                   	push   %edx
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	ff 75 e4             	pushl  -0x1c(%ebp)
  800208:	ff 75 e0             	pushl  -0x20(%ebp)
  80020b:	e8 18 0e 00 00       	call   801028 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800218:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80021b:	e8 a4 ff ff ff       	call   8001c4 <printnum>
  800220:	83 c4 20             	add    $0x20,%esp
  800223:	eb 14                	jmp    800239 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	ff 75 e8             	pushl  -0x18(%ebp)
  80022b:	ff 75 18             	pushl  0x18(%ebp)
  80022e:	ff 55 ec             	call   *-0x14(%ebp)
  800231:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	4b                   	dec    %ebx
  800235:	85 db                	test   %ebx,%ebx
  800237:	7f ec                	jg     800225 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	ff 75 e8             	pushl  -0x18(%ebp)
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	57                   	push   %edi
  800243:	56                   	push   %esi
  800244:	ff 75 e4             	pushl  -0x1c(%ebp)
  800247:	ff 75 e0             	pushl  -0x20(%ebp)
  80024a:	e8 05 0f 00 00       	call   801154 <__umoddi3>
  80024f:	83 c4 14             	add    $0x14,%esp
  800252:	0f be 80 80 13 80 00 	movsbl 0x801380(%eax),%eax
  800259:	50                   	push   %eax
  80025a:	ff 55 ec             	call   *-0x14(%ebp)
  80025d:	83 c4 10             	add    $0x10,%esp
}
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80026d:	83 fa 01             	cmp    $0x1,%edx
  800270:	7e 0e                	jle    800280 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 42 08             	lea    0x8(%edx),%eax
  800277:	89 01                	mov    %eax,(%ecx)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	8b 52 04             	mov    0x4(%edx),%edx
  80027e:	eb 22                	jmp    8002a2 <getuint+0x3a>
	else if (lflag)
  800280:	85 d2                	test   %edx,%edx
  800282:	74 10                	je     800294 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 42 04             	lea    0x4(%edx),%eax
  800289:	89 01                	mov    %eax,(%ecx)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	eb 0e                	jmp    8002a2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 42 04             	lea    0x4(%edx),%eax
  800299:	89 01                	mov    %eax,(%ecx)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002aa:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002ad:	8b 11                	mov    (%ecx),%edx
  8002af:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002b2:	73 0a                	jae    8002be <sprintputch+0x1a>
		*b->buf++ = ch;
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	88 02                	mov    %al,(%edx)
  8002b9:	8d 42 01             	lea    0x1(%edx),%eax
  8002bc:	89 01                	mov    %eax,(%ecx)
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d2:	eb 1a                	jmp    8002ee <vprintfmt+0x2e>
  8002d4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002d7:	eb 15                	jmp    8002ee <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d9:	84 c0                	test   %al,%al
  8002db:	0f 84 15 03 00 00    	je     8005f6 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	57                   	push   %edi
  8002e5:	0f b6 c0             	movzbl %al,%eax
  8002e8:	50                   	push   %eax
  8002e9:	ff d6                	call   *%esi
  8002eb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ee:	8a 03                	mov    (%ebx),%al
  8002f0:	43                   	inc    %ebx
  8002f1:	3c 25                	cmp    $0x25,%al
  8002f3:	75 e4                	jne    8002d9 <vprintfmt+0x19>
  8002f5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800303:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80030a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800311:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800315:	eb 0a                	jmp    800321 <vprintfmt+0x61>
  800317:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80031e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8a 03                	mov    (%ebx),%al
  800323:	0f b6 d0             	movzbl %al,%edx
  800326:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800329:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80032c:	83 e8 23             	sub    $0x23,%eax
  80032f:	3c 55                	cmp    $0x55,%al
  800331:	0f 87 9c 02 00 00    	ja     8005d3 <vprintfmt+0x313>
  800337:	0f b6 c0             	movzbl %al,%eax
  80033a:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
  800341:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800345:	eb d7                	jmp    80031e <vprintfmt+0x5e>
  800347:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80034b:	eb d1                	jmp    80031e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80034d:	89 d9                	mov    %ebx,%ecx
  80034f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800356:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800359:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80035c:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800360:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800363:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800367:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800368:	8d 42 d0             	lea    -0x30(%edx),%eax
  80036b:	83 f8 09             	cmp    $0x9,%eax
  80036e:	77 21                	ja     800391 <vprintfmt+0xd1>
  800370:	eb e4                	jmp    800356 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800372:	8b 55 14             	mov    0x14(%ebp),%edx
  800375:	8d 42 04             	lea    0x4(%edx),%eax
  800378:	89 45 14             	mov    %eax,0x14(%ebp)
  80037b:	8b 12                	mov    (%edx),%edx
  80037d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800380:	eb 12                	jmp    800394 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800382:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800386:	79 96                	jns    80031e <vprintfmt+0x5e>
  800388:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038f:	eb 8d                	jmp    80031e <vprintfmt+0x5e>
  800391:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800394:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800398:	79 84                	jns    80031e <vprintfmt+0x5e>
  80039a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003a7:	e9 72 ff ff ff       	jmp    80031e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ac:	ff 45 d4             	incl   -0x2c(%ebp)
  8003af:	e9 6a ff ff ff       	jmp    80031e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 55 14             	mov    0x14(%ebp),%edx
  8003b7:	8d 42 04             	lea    0x4(%edx),%eax
  8003ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	57                   	push   %edi
  8003c1:	ff 32                	pushl  (%edx)
  8003c3:	ff d6                	call   *%esi
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
  8003c8:	e9 07 ff ff ff       	jmp    8002d4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8003d0:	8d 42 04             	lea    0x4(%edx),%eax
  8003d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	79 02                	jns    8003de <vprintfmt+0x11e>
  8003dc:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003de:	83 f8 0f             	cmp    $0xf,%eax
  8003e1:	7f 0b                	jg     8003ee <vprintfmt+0x12e>
  8003e3:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	75 15                	jne    800403 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003ee:	50                   	push   %eax
  8003ef:	68 91 13 80 00       	push   $0x801391
  8003f4:	57                   	push   %edi
  8003f5:	56                   	push   %esi
  8003f6:	e8 6e 02 00 00       	call   800669 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	e9 d1 fe ff ff       	jmp    8002d4 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800403:	52                   	push   %edx
  800404:	68 9a 13 80 00       	push   $0x80139a
  800409:	57                   	push   %edi
  80040a:	56                   	push   %esi
  80040b:	e8 59 02 00 00       	call   800669 <printfmt>
  800410:	83 c4 10             	add    $0x10,%esp
  800413:	e9 bc fe ff ff       	jmp    8002d4 <vprintfmt+0x14>
  800418:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80041b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80041e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800421:	8b 55 14             	mov    0x14(%ebp),%edx
  800424:	8d 42 04             	lea    0x4(%edx),%eax
  800427:	89 45 14             	mov    %eax,0x14(%ebp)
  80042a:	8b 1a                	mov    (%edx),%ebx
  80042c:	85 db                	test   %ebx,%ebx
  80042e:	75 05                	jne    800435 <vprintfmt+0x175>
  800430:	bb 9d 13 80 00       	mov    $0x80139d,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800435:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800439:	7e 66                	jle    8004a1 <vprintfmt+0x1e1>
  80043b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80043f:	74 60                	je     8004a1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	51                   	push   %ecx
  800445:	53                   	push   %ebx
  800446:	e8 57 02 00 00       	call   8006a2 <strnlen>
  80044b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80044e:	29 c1                	sub    %eax,%ecx
  800450:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80045a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80045d:	eb 0f                	jmp    80046e <vprintfmt+0x1ae>
					putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	57                   	push   %edi
  800463:	ff 75 c4             	pushl  -0x3c(%ebp)
  800466:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	ff 4d d8             	decl   -0x28(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	7f eb                	jg     80045f <vprintfmt+0x19f>
  800474:	eb 2b                	jmp    8004a1 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800476:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800479:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047d:	74 15                	je     800494 <vprintfmt+0x1d4>
  80047f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800482:	83 f8 5e             	cmp    $0x5e,%eax
  800485:	76 0d                	jbe    800494 <vprintfmt+0x1d4>
					putch('?', putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	eb 0a                	jmp    80049e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	57                   	push   %edi
  800498:	52                   	push   %edx
  800499:	ff d6                	call   *%esi
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	ff 4d d8             	decl   -0x28(%ebp)
  8004a1:	8a 03                	mov    (%ebx),%al
  8004a3:	43                   	inc    %ebx
  8004a4:	84 c0                	test   %al,%al
  8004a6:	74 1b                	je     8004c3 <vprintfmt+0x203>
  8004a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ac:	78 c8                	js     800476 <vprintfmt+0x1b6>
  8004ae:	ff 4d dc             	decl   -0x24(%ebp)
  8004b1:	79 c3                	jns    800476 <vprintfmt+0x1b6>
  8004b3:	eb 0e                	jmp    8004c3 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	57                   	push   %edi
  8004b9:	6a 20                	push   $0x20
  8004bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004bd:	ff 4d d8             	decl   -0x28(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c7:	7f ec                	jg     8004b5 <vprintfmt+0x1f5>
  8004c9:	e9 06 fe ff ff       	jmp    8002d4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ce:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004d2:	7e 10                	jle    8004e4 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004d4:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d7:	8d 42 08             	lea    0x8(%edx),%eax
  8004da:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	8b 52 04             	mov    0x4(%edx),%edx
  8004e2:	eb 20                	jmp    800504 <vprintfmt+0x244>
	else if (lflag)
  8004e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e8:	74 0e                	je     8004f8 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	99                   	cltd   
  8004f6:	eb 0c                	jmp    800504 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 00                	mov    (%eax),%eax
  800503:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800504:	89 d1                	mov    %edx,%ecx
  800506:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800508:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80050e:	85 c9                	test   %ecx,%ecx
  800510:	78 0a                	js     80051c <vprintfmt+0x25c>
  800512:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800517:	e9 89 00 00 00       	jmp    8005a5 <vprintfmt+0x2e5>
				putch('-', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	57                   	push   %edi
  800520:	6a 2d                	push   $0x2d
  800522:	ff d6                	call   *%esi
				num = -(long long) num;
  800524:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800527:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052a:	f7 da                	neg    %edx
  80052c:	83 d1 00             	adc    $0x0,%ecx
  80052f:	f7 d9                	neg    %ecx
  800531:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 6a                	jmp    8005a5 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80053b:	8d 45 14             	lea    0x14(%ebp),%eax
  80053e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800541:	e8 22 fd ff ff       	call   800268 <getuint>
  800546:	89 d1                	mov    %edx,%ecx
  800548:	89 c2                	mov    %eax,%edx
  80054a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80054f:	eb 54                	jmp    8005a5 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800551:	8d 45 14             	lea    0x14(%ebp),%eax
  800554:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800557:	e8 0c fd ff ff       	call   800268 <getuint>
  80055c:	89 d1                	mov    %edx,%ecx
  80055e:	89 c2                	mov    %eax,%edx
  800560:	bb 08 00 00 00       	mov    $0x8,%ebx
  800565:	eb 3e                	jmp    8005a5 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	6a 30                	push   $0x30
  80056d:	ff d6                	call   *%esi
			putch('x', putdat);
  80056f:	83 c4 08             	add    $0x8,%esp
  800572:	57                   	push   %edi
  800573:	6a 78                	push   $0x78
  800575:	ff d6                	call   *%esi
			num = (unsigned long long)
  800577:	8b 55 14             	mov    0x14(%ebp),%edx
  80057a:	8d 42 04             	lea    0x4(%edx),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	8b 12                	mov    (%edx),%edx
  800582:	b9 00 00 00 00       	mov    $0x0,%ecx
  800587:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	eb 14                	jmp    8005a5 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800591:	8d 45 14             	lea    0x14(%ebp),%eax
  800594:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800597:	e8 cc fc ff ff       	call   800268 <getuint>
  80059c:	89 d1                	mov    %edx,%ecx
  80059e:	89 c2                	mov    %eax,%edx
  8005a0:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005ac:	50                   	push   %eax
  8005ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b0:	53                   	push   %ebx
  8005b1:	51                   	push   %ecx
  8005b2:	52                   	push   %edx
  8005b3:	89 fa                	mov    %edi,%edx
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	e8 08 fc ff ff       	call   8001c4 <printnum>
			break;
  8005bc:	83 c4 20             	add    $0x20,%esp
  8005bf:	e9 10 fd ff ff       	jmp    8002d4 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	57                   	push   %edi
  8005c8:	52                   	push   %edx
  8005c9:	ff d6                	call   *%esi
			break;
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	e9 01 fd ff ff       	jmp    8002d4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 25                	push   $0x25
  8005d9:	ff d6                	call   *%esi
  8005db:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005de:	83 ea 02             	sub    $0x2,%edx
  8005e1:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005e4:	8a 02                	mov    (%edx),%al
  8005e6:	4a                   	dec    %edx
  8005e7:	3c 25                	cmp    $0x25,%al
  8005e9:	75 f9                	jne    8005e4 <vprintfmt+0x324>
  8005eb:	83 c2 02             	add    $0x2,%edx
  8005ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005f1:	e9 de fc ff ff       	jmp    8002d4 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f9:	5b                   	pop    %ebx
  8005fa:	5e                   	pop    %esi
  8005fb:	5f                   	pop    %edi
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    

008005fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 18             	sub    $0x18,%esp
  800604:	8b 55 08             	mov    0x8(%ebp),%edx
  800607:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 37                	je     800645 <vsnprintf+0x47>
  80060e:	85 c0                	test   %eax,%eax
  800610:	7e 33                	jle    800645 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800612:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800619:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80061d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800620:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800623:	ff 75 14             	pushl  0x14(%ebp)
  800626:	ff 75 10             	pushl  0x10(%ebp)
  800629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	68 a4 02 80 00       	push   $0x8002a4
  800632:	e8 89 fc ff ff       	call   8002c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80063a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80063d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb 05                	jmp    80064a <vsnprintf+0x4c>
  800645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800658:	50                   	push   %eax
  800659:	ff 75 10             	pushl  0x10(%ebp)
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	ff 75 08             	pushl  0x8(%ebp)
  800662:	e8 97 ff ff ff       	call   8005fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800667:	c9                   	leave  
  800668:	c3                   	ret    

00800669 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800675:	50                   	push   %eax
  800676:	ff 75 10             	pushl  0x10(%ebp)
  800679:	ff 75 0c             	pushl  0xc(%ebp)
  80067c:	ff 75 08             	pushl  0x8(%ebp)
  80067f:	e8 3c fc ff ff       	call   8002c0 <vprintfmt>
	va_end(ap);
  800684:	83 c4 10             	add    $0x10,%esp
}
  800687:	c9                   	leave  
  800688:	c3                   	ret    
  800689:	00 00                	add    %al,(%eax)
	...

0080068c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
  80068f:	8b 55 08             	mov    0x8(%ebp),%edx
  800692:	b8 00 00 00 00       	mov    $0x0,%eax
  800697:	eb 01                	jmp    80069a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800699:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80069a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80069e:	75 f9                	jne    800699 <strlen+0xd>
		n++;
	return n;
}
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    

008006a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b0:	eb 01                	jmp    8006b3 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8006b2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b3:	39 d0                	cmp    %edx,%eax
  8006b5:	74 06                	je     8006bd <strnlen+0x1b>
  8006b7:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8006bb:	75 f5                	jne    8006b2 <strnlen+0x10>
		n++;
	return n;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006c5:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006c8:	8a 01                	mov    (%ecx),%al
  8006ca:	88 02                	mov    %al,(%edx)
  8006cc:	42                   	inc    %edx
  8006cd:	41                   	inc    %ecx
  8006ce:	84 c0                	test   %al,%al
  8006d0:	75 f6                	jne    8006c8 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	53                   	push   %ebx
  8006db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006de:	53                   	push   %ebx
  8006df:	e8 a8 ff ff ff       	call   80068c <strlen>
	strcpy(dst + len, src);
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006ea:	50                   	push   %eax
  8006eb:	e8 cf ff ff ff       	call   8006bf <strcpy>
	return dst;
}
  8006f0:	89 d8                	mov    %ebx,%eax
  8006f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	56                   	push   %esi
  8006fb:	53                   	push   %ebx
  8006fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800702:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	eb 0c                	jmp    800718 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80070c:	8a 02                	mov    (%edx),%al
  80070e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800711:	80 3a 01             	cmpb   $0x1,(%edx)
  800714:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800717:	41                   	inc    %ecx
  800718:	39 d9                	cmp    %ebx,%ecx
  80071a:	75 f0                	jne    80070c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800730:	85 c9                	test   %ecx,%ecx
  800732:	75 04                	jne    800738 <strlcpy+0x16>
  800734:	89 f0                	mov    %esi,%eax
  800736:	eb 14                	jmp    80074c <strlcpy+0x2a>
  800738:	89 f0                	mov    %esi,%eax
  80073a:	eb 04                	jmp    800740 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073c:	88 10                	mov    %dl,(%eax)
  80073e:	40                   	inc    %eax
  80073f:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800740:	49                   	dec    %ecx
  800741:	74 06                	je     800749 <strlcpy+0x27>
  800743:	8a 13                	mov    (%ebx),%dl
  800745:	84 d2                	test   %dl,%dl
  800747:	75 f3                	jne    80073c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800749:	c6 00 00             	movb   $0x0,(%eax)
  80074c:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 55 08             	mov    0x8(%ebp),%edx
  800758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075b:	eb 02                	jmp    80075f <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  80075d:	42                   	inc    %edx
  80075e:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80075f:	8a 02                	mov    (%edx),%al
  800761:	84 c0                	test   %al,%al
  800763:	74 04                	je     800769 <strcmp+0x17>
  800765:	3a 01                	cmp    (%ecx),%al
  800767:	74 f4                	je     80075d <strcmp+0xb>
  800769:	0f b6 c0             	movzbl %al,%eax
  80076c:	0f b6 11             	movzbl (%ecx),%edx
  80076f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	8b 55 10             	mov    0x10(%ebp),%edx
  800780:	eb 03                	jmp    800785 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800782:	4a                   	dec    %edx
  800783:	41                   	inc    %ecx
  800784:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800785:	85 d2                	test   %edx,%edx
  800787:	75 07                	jne    800790 <strncmp+0x1d>
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
  80078e:	eb 14                	jmp    8007a4 <strncmp+0x31>
  800790:	8a 01                	mov    (%ecx),%al
  800792:	84 c0                	test   %al,%al
  800794:	74 04                	je     80079a <strncmp+0x27>
  800796:	3a 03                	cmp    (%ebx),%al
  800798:	74 e8                	je     800782 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80079a:	0f b6 d0             	movzbl %al,%edx
  80079d:	0f b6 03             	movzbl (%ebx),%eax
  8007a0:	29 c2                	sub    %eax,%edx
  8007a2:	89 d0                	mov    %edx,%eax
}
  8007a4:	5b                   	pop    %ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007b0:	eb 05                	jmp    8007b7 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8007b2:	38 ca                	cmp    %cl,%dl
  8007b4:	74 0c                	je     8007c2 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007b6:	40                   	inc    %eax
  8007b7:	8a 10                	mov    (%eax),%dl
  8007b9:	84 d2                	test   %dl,%dl
  8007bb:	75 f5                	jne    8007b2 <strchr+0xb>
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007cd:	eb 05                	jmp    8007d4 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007cf:	38 ca                	cmp    %cl,%dl
  8007d1:	74 07                	je     8007da <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007d3:	40                   	inc    %eax
  8007d4:	8a 10                	mov    (%eax),%dl
  8007d6:	84 d2                	test   %dl,%dl
  8007d8:	75 f5                	jne    8007cf <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	57                   	push   %edi
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007eb:	85 db                	test   %ebx,%ebx
  8007ed:	74 36                	je     800825 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007f5:	75 29                	jne    800820 <memset+0x44>
  8007f7:	f6 c3 03             	test   $0x3,%bl
  8007fa:	75 24                	jne    800820 <memset+0x44>
		c &= 0xFF;
  8007fc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007ff:	89 d6                	mov    %edx,%esi
  800801:	c1 e6 08             	shl    $0x8,%esi
  800804:	89 d0                	mov    %edx,%eax
  800806:	c1 e0 18             	shl    $0x18,%eax
  800809:	89 d1                	mov    %edx,%ecx
  80080b:	c1 e1 10             	shl    $0x10,%ecx
  80080e:	09 c8                	or     %ecx,%eax
  800810:	09 c2                	or     %eax,%edx
  800812:	89 f0                	mov    %esi,%eax
  800814:	09 d0                	or     %edx,%eax
  800816:	89 d9                	mov    %ebx,%ecx
  800818:	c1 e9 02             	shr    $0x2,%ecx
  80081b:	fc                   	cld    
  80081c:	f3 ab                	rep stos %eax,%es:(%edi)
  80081e:	eb 05                	jmp    800825 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800820:	89 d9                	mov    %ebx,%ecx
  800822:	fc                   	cld    
  800823:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800825:	89 f8                	mov    %edi,%eax
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5f                   	pop    %edi
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800837:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80083a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80083c:	39 c6                	cmp    %eax,%esi
  80083e:	73 36                	jae    800876 <memmove+0x4a>
  800840:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800843:	39 d0                	cmp    %edx,%eax
  800845:	73 2f                	jae    800876 <memmove+0x4a>
		s += n;
		d += n;
  800847:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80084a:	f6 c2 03             	test   $0x3,%dl
  80084d:	75 1b                	jne    80086a <memmove+0x3e>
  80084f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800855:	75 13                	jne    80086a <memmove+0x3e>
  800857:	f6 c1 03             	test   $0x3,%cl
  80085a:	75 0e                	jne    80086a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  80085c:	8d 7e fc             	lea    -0x4(%esi),%edi
  80085f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800862:	c1 e9 02             	shr    $0x2,%ecx
  800865:	fd                   	std    
  800866:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800868:	eb 09                	jmp    800873 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80086a:	8d 7e ff             	lea    -0x1(%esi),%edi
  80086d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800870:	fd                   	std    
  800871:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800873:	fc                   	cld    
  800874:	eb 20                	jmp    800896 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800876:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087c:	75 15                	jne    800893 <memmove+0x67>
  80087e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800884:	75 0d                	jne    800893 <memmove+0x67>
  800886:	f6 c1 03             	test   $0x3,%cl
  800889:	75 08                	jne    800893 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80088b:	c1 e9 02             	shr    $0x2,%ecx
  80088e:	fc                   	cld    
  80088f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800891:	eb 03                	jmp    800896 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800893:	fc                   	cld    
  800894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80089d:	ff 75 10             	pushl  0x10(%ebp)
  8008a0:	ff 75 0c             	pushl  0xc(%ebp)
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 81 ff ff ff       	call   80082c <memmove>
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	83 ec 04             	sub    $0x4,%esp
  8008b4:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008b7:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008bd:	eb 1b                	jmp    8008da <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008bf:	8a 1a                	mov    (%edx),%bl
  8008c1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008c4:	8a 19                	mov    (%ecx),%bl
  8008c6:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008c9:	74 0d                	je     8008d8 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008cb:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008cf:	0f b6 c3             	movzbl %bl,%eax
  8008d2:	29 c2                	sub    %eax,%edx
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	eb 0d                	jmp    8008e5 <memcmp+0x38>
		s1++, s2++;
  8008d8:	42                   	inc    %edx
  8008d9:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008da:	48                   	dec    %eax
  8008db:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008de:	75 df                	jne    8008bf <memcmp+0x12>
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008e5:	83 c4 04             	add    $0x4,%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	03 55 10             	add    0x10(%ebp),%edx
  8008f9:	eb 05                	jmp    800900 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008fb:	38 08                	cmp    %cl,(%eax)
  8008fd:	74 05                	je     800904 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008ff:	40                   	inc    %eax
  800900:	39 d0                	cmp    %edx,%eax
  800902:	72 f7                	jb     8008fb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	83 ec 04             	sub    $0x4,%esp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 75 10             	mov    0x10(%ebp),%esi
  800915:	eb 01                	jmp    800918 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800917:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800918:	8a 01                	mov    (%ecx),%al
  80091a:	3c 20                	cmp    $0x20,%al
  80091c:	74 f9                	je     800917 <strtol+0x11>
  80091e:	3c 09                	cmp    $0x9,%al
  800920:	74 f5                	je     800917 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800922:	3c 2b                	cmp    $0x2b,%al
  800924:	75 0a                	jne    800930 <strtol+0x2a>
		s++;
  800926:	41                   	inc    %ecx
  800927:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80092e:	eb 17                	jmp    800947 <strtol+0x41>
	else if (*s == '-')
  800930:	3c 2d                	cmp    $0x2d,%al
  800932:	74 09                	je     80093d <strtol+0x37>
  800934:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80093b:	eb 0a                	jmp    800947 <strtol+0x41>
		s++, neg = 1;
  80093d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800940:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800947:	85 f6                	test   %esi,%esi
  800949:	74 05                	je     800950 <strtol+0x4a>
  80094b:	83 fe 10             	cmp    $0x10,%esi
  80094e:	75 1a                	jne    80096a <strtol+0x64>
  800950:	8a 01                	mov    (%ecx),%al
  800952:	3c 30                	cmp    $0x30,%al
  800954:	75 10                	jne    800966 <strtol+0x60>
  800956:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80095a:	75 0a                	jne    800966 <strtol+0x60>
		s += 2, base = 16;
  80095c:	83 c1 02             	add    $0x2,%ecx
  80095f:	be 10 00 00 00       	mov    $0x10,%esi
  800964:	eb 04                	jmp    80096a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800966:	85 f6                	test   %esi,%esi
  800968:	74 07                	je     800971 <strtol+0x6b>
  80096a:	bf 00 00 00 00       	mov    $0x0,%edi
  80096f:	eb 13                	jmp    800984 <strtol+0x7e>
  800971:	3c 30                	cmp    $0x30,%al
  800973:	74 07                	je     80097c <strtol+0x76>
  800975:	be 0a 00 00 00       	mov    $0xa,%esi
  80097a:	eb ee                	jmp    80096a <strtol+0x64>
		s++, base = 8;
  80097c:	41                   	inc    %ecx
  80097d:	be 08 00 00 00       	mov    $0x8,%esi
  800982:	eb e6                	jmp    80096a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800984:	8a 11                	mov    (%ecx),%dl
  800986:	88 d3                	mov    %dl,%bl
  800988:	8d 42 d0             	lea    -0x30(%edx),%eax
  80098b:	3c 09                	cmp    $0x9,%al
  80098d:	77 08                	ja     800997 <strtol+0x91>
			dig = *s - '0';
  80098f:	0f be c2             	movsbl %dl,%eax
  800992:	8d 50 d0             	lea    -0x30(%eax),%edx
  800995:	eb 1c                	jmp    8009b3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800997:	8d 43 9f             	lea    -0x61(%ebx),%eax
  80099a:	3c 19                	cmp    $0x19,%al
  80099c:	77 08                	ja     8009a6 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80099e:	0f be c2             	movsbl %dl,%eax
  8009a1:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009a4:	eb 0d                	jmp    8009b3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009a6:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009a9:	3c 19                	cmp    $0x19,%al
  8009ab:	77 15                	ja     8009c2 <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009ad:	0f be c2             	movsbl %dl,%eax
  8009b0:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8009b3:	39 f2                	cmp    %esi,%edx
  8009b5:	7d 0b                	jge    8009c2 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009b7:	41                   	inc    %ecx
  8009b8:	89 f8                	mov    %edi,%eax
  8009ba:	0f af c6             	imul   %esi,%eax
  8009bd:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009c0:	eb c2                	jmp    800984 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009c2:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009c8:	74 05                	je     8009cf <strtol+0xc9>
		*endptr = (char *) s;
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009d3:	74 04                	je     8009d9 <strtol+0xd3>
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	f7 df                	neg    %edi
}
  8009d9:	89 f8                	mov    %edi,%eax
  8009db:	83 c4 04             	add    $0x4,%esp
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    
	...

008009e4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f4:	89 fa                	mov    %edi,%edx
  8009f6:	89 f9                	mov    %edi,%ecx
  8009f8:	89 fb                	mov    %edi,%ebx
  8009fa:	89 fe                	mov    %edi,%esi
  8009fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	83 ec 04             	sub    $0x4,%esp
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	89 fb                	mov    %edi,%ebx
  800a1b:	89 fe                	mov    %edi,%esi
  800a1d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a1f:	83 c4 04             	add    $0x4,%esp
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5f                   	pop    %edi
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	83 ec 0c             	sub    $0xc,%esp
  800a30:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	89 f9                	mov    %edi,%ecx
  800a3f:	89 fb                	mov    %edi,%ebx
  800a41:	89 fe                	mov    %edi,%esi
  800a43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	7e 17                	jle    800a60 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	50                   	push   %eax
  800a4d:	6a 0d                	push   $0xd
  800a4f:	68 7f 16 80 00       	push   $0x80167f
  800a54:	6a 23                	push   $0x23
  800a56:	68 9c 16 80 00       	push   $0x80169c
  800a5b:	e8 d0 04 00 00       	call   800f30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a77:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a7f:	be 00 00 00 00       	mov    $0x0,%esi
  800a84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 0c             	sub    $0xc,%esp
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa4:	89 fb                	mov    %edi,%ebx
  800aa6:	89 fe                	mov    %edi,%esi
  800aa8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	7e 17                	jle    800ac5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	50                   	push   %eax
  800ab2:	6a 0a                	push   $0xa
  800ab4:	68 7f 16 80 00       	push   $0x80167f
  800ab9:	6a 23                	push   $0x23
  800abb:	68 9c 16 80 00       	push   $0x80169c
  800ac0:	e8 6b 04 00 00       	call   800f30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	b8 09 00 00 00       	mov    $0x9,%eax
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae6:	89 fb                	mov    %edi,%ebx
  800ae8:	89 fe                	mov    %edi,%esi
  800aea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aec:	85 c0                	test   %eax,%eax
  800aee:	7e 17                	jle    800b07 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	50                   	push   %eax
  800af4:	6a 09                	push   $0x9
  800af6:	68 7f 16 80 00       	push   $0x80167f
  800afb:	6a 23                	push   $0x23
  800afd:	68 9c 16 80 00       	push   $0x80169c
  800b02:	e8 29 04 00 00       	call   800f30 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
  800b28:	89 fb                	mov    %edi,%ebx
  800b2a:	89 fe                	mov    %edi,%esi
  800b2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	7e 17                	jle    800b49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	50                   	push   %eax
  800b36:	6a 08                	push   $0x8
  800b38:	68 7f 16 80 00       	push   $0x80167f
  800b3d:	6a 23                	push   $0x23
  800b3f:	68 9c 16 80 00       	push   $0x80169c
  800b44:	e8 e7 03 00 00       	call   800f30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    

00800b51 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	b8 06 00 00 00       	mov    $0x6,%eax
  800b65:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6a:	89 fb                	mov    %edi,%ebx
  800b6c:	89 fe                	mov    %edi,%esi
  800b6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b70:	85 c0                	test   %eax,%eax
  800b72:	7e 17                	jle    800b8b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	50                   	push   %eax
  800b78:	6a 06                	push   $0x6
  800b7a:	68 7f 16 80 00       	push   $0x80167f
  800b7f:	6a 23                	push   $0x23
  800b81:	68 9c 16 80 00       	push   $0x80169c
  800b86:	e8 a5 03 00 00       	call   800f30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba8:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	7e 17                	jle    800bcd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	6a 05                	push   $0x5
  800bbc:	68 7f 16 80 00       	push   $0x80167f
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 9c 16 80 00       	push   $0x80169c
  800bc8:	e8 63 03 00 00       	call   800f30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bec:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf1:	89 fe                	mov    %edi,%esi
  800bf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 17                	jle    800c10 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 04                	push   $0x4
  800bff:	68 7f 16 80 00       	push   $0x80167f
  800c04:	6a 23                	push   $0x23
  800c06:	68 9c 16 80 00       	push   $0x80169c
  800c0b:	e8 20 03 00 00       	call   800f30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
  800c28:	89 fa                	mov    %edi,%edx
  800c2a:	89 f9                	mov    %edi,%ecx
  800c2c:	89 fb                	mov    %edi,%ebx
  800c2e:	89 fe                	mov    %edi,%esi
  800c30:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c42:	bf 00 00 00 00       	mov    $0x0,%edi
  800c47:	89 fa                	mov    %edi,%edx
  800c49:	89 f9                	mov    %edi,%ecx
  800c4b:	89 fb                	mov    %edi,%ebx
  800c4d:	89 fe                	mov    %edi,%esi
  800c4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b8 03 00 00 00       	mov    $0x3,%eax
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6c:	89 f9                	mov    %edi,%ecx
  800c6e:	89 fb                	mov    %edi,%ebx
  800c70:	89 fe                	mov    %edi,%esi
  800c72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7e 17                	jle    800c8f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 03                	push   $0x3
  800c7e:	68 7f 16 80 00       	push   $0x80167f
  800c83:	6a 23                	push   $0x23
  800c85:	68 9c 16 80 00       	push   $0x80169c
  800c8a:	e8 a1 02 00 00       	call   800f30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    
	...

00800c98 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800c9e:	68 aa 16 80 00       	push   $0x8016aa
  800ca3:	68 92 00 00 00       	push   $0x92
  800ca8:	68 c0 16 80 00       	push   $0x8016c0
  800cad:	e8 7e 02 00 00       	call   800f30 <_panic>

00800cb2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800cbb:	68 53 0e 80 00       	push   $0x800e53
  800cc0:	e8 bb 02 00 00       	call   800f80 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800cc5:	ba 07 00 00 00       	mov    $0x7,%edx
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	cd 30                	int    $0x30
  800cce:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	75 25                	jne    800cfc <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800cd7:	e8 5b ff ff ff       	call   800c37 <sys_getenvid>
  800cdc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ce1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ce8:	c1 e0 07             	shl    $0x7,%eax
  800ceb:	29 d0                	sub    %edx,%eax
  800ced:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800cf2:	a3 04 20 80 00       	mov    %eax,0x802004
  800cf7:	e9 4d 01 00 00       	jmp    800e49 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	79 12                	jns    800d12 <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d00:	50                   	push   %eax
  800d01:	68 cb 16 80 00       	push   $0x8016cb
  800d06:	6a 77                	push   $0x77
  800d08:	68 c0 16 80 00       	push   $0x8016c0
  800d0d:	e8 1e 02 00 00       	call   800f30 <_panic>
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800d17:	89 d8                	mov    %ebx,%eax
  800d19:	c1 e8 16             	shr    $0x16,%eax
  800d1c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d23:	a8 01                	test   $0x1,%al
  800d25:	0f 84 ab 00 00 00    	je     800dd6 <fork+0x124>
  800d2b:	89 da                	mov    %ebx,%edx
  800d2d:	c1 ea 0c             	shr    $0xc,%edx
  800d30:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d37:	a8 01                	test   $0x1,%al
  800d39:	0f 84 97 00 00 00    	je     800dd6 <fork+0x124>
  800d3f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d46:	a8 04                	test   $0x4,%al
  800d48:	0f 84 88 00 00 00    	je     800dd6 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800d4e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800d55:	89 d6                	mov    %edx,%esi
  800d57:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800d62:	a9 02 08 00 00       	test   $0x802,%eax
  800d67:	74 0f                	je     800d78 <fork+0xc6>
  800d69:	f6 c4 04             	test   $0x4,%ah
  800d6c:	75 0a                	jne    800d78 <fork+0xc6>
		perm &= ~PTE_W;
  800d6e:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800d78:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d7e:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	52                   	push   %edx
  800d85:	56                   	push   %esi
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 04 fe ff ff       	call   800b93 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800d8f:	83 c4 20             	add    $0x20,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	79 14                	jns    800daa <fork+0xf8>
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 14 17 80 00       	push   $0x801714
  800d9e:	6a 52                	push   $0x52
  800da0:	68 c0 16 80 00       	push   $0x8016c0
  800da5:	e8 86 01 00 00       	call   800f30 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	ff 75 f0             	pushl  -0x10(%ebp)
  800db0:	56                   	push   %esi
  800db1:	6a 00                	push   $0x0
  800db3:	56                   	push   %esi
  800db4:	6a 00                	push   $0x0
  800db6:	e8 d8 fd ff ff       	call   800b93 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800dbb:	83 c4 20             	add    $0x20,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	79 14                	jns    800dd6 <fork+0x124>
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	68 38 17 80 00       	push   $0x801738
  800dca:	6a 55                	push   $0x55
  800dcc:	68 c0 16 80 00       	push   $0x8016c0
  800dd1:	e8 5a 01 00 00       	call   800f30 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800dd6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ddc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800de2:	0f 85 2f ff ff ff    	jne    800d17 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	6a 07                	push   $0x7
  800ded:	68 00 f0 bf ee       	push   $0xeebff000
  800df2:	57                   	push   %edi
  800df3:	e8 dd fd ff ff       	call   800bd5 <sys_page_alloc>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 15                	jns    800e14 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800dff:	50                   	push   %eax
  800e00:	68 e9 16 80 00       	push   $0x8016e9
  800e05:	68 83 00 00 00       	push   $0x83
  800e0a:	68 c0 16 80 00       	push   $0x8016c0
  800e0f:	e8 1c 01 00 00       	call   800f30 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	68 00 10 80 00       	push   $0x801000
  800e1c:	57                   	push   %edi
  800e1d:	e8 69 fc ff ff       	call   800a8b <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800e22:	83 c4 08             	add    $0x8,%esp
  800e25:	6a 02                	push   $0x2
  800e27:	57                   	push   %edi
  800e28:	e8 e2 fc ff ff       	call   800b0f <sys_env_set_status>
  800e2d:	83 c4 10             	add    $0x10,%esp
  800e30:	85 c0                	test   %eax,%eax
  800e32:	79 15                	jns    800e49 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800e34:	50                   	push   %eax
  800e35:	68 fc 16 80 00       	push   $0x8016fc
  800e3a:	68 89 00 00 00       	push   $0x89
  800e3f:	68 c0 16 80 00       	push   $0x8016c0
  800e44:	e8 e7 00 00 00       	call   800f30 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800e49:	89 f8                	mov    %edi,%eax
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800e5d:	8b 1a                	mov    (%edx),%ebx
  800e5f:	89 d8                	mov    %ebx,%eax
  800e61:	c1 e8 0c             	shr    $0xc,%eax
  800e64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800e6b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e6f:	74 05                	je     800e76 <pgfault+0x23>
  800e71:	f6 c4 08             	test   $0x8,%ah
  800e74:	75 14                	jne    800e8a <pgfault+0x37>
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 5c 17 80 00       	push   $0x80175c
  800e7e:	6a 1e                	push   $0x1e
  800e80:	68 c0 16 80 00       	push   $0x8016c0
  800e85:	e8 a6 00 00 00       	call   800f30 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	6a 07                	push   $0x7
  800e8f:	68 00 f0 7f 00       	push   $0x7ff000
  800e94:	6a 00                	push   $0x0
  800e96:	e8 3a fd ff ff       	call   800bd5 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	79 14                	jns    800eb6 <pgfault+0x63>
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	68 88 17 80 00       	push   $0x801788
  800eaa:	6a 2a                	push   $0x2a
  800eac:	68 c0 16 80 00       	push   $0x8016c0
  800eb1:	e8 7a 00 00 00       	call   800f30 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800eb6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	68 00 10 00 00       	push   $0x1000
  800ec4:	53                   	push   %ebx
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	e8 5d f9 ff ff       	call   80082c <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800ecf:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed6:	53                   	push   %ebx
  800ed7:	6a 00                	push   $0x0
  800ed9:	68 00 f0 7f 00       	push   $0x7ff000
  800ede:	6a 00                	push   $0x0
  800ee0:	e8 ae fc ff ff       	call   800b93 <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800ee5:	83 c4 20             	add    $0x20,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 14                	jns    800f00 <pgfault+0xad>
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	68 ac 17 80 00       	push   $0x8017ac
  800ef4:	6a 2e                	push   $0x2e
  800ef6:	68 c0 16 80 00       	push   $0x8016c0
  800efb:	e8 30 00 00 00       	call   800f30 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	68 00 f0 7f 00       	push   $0x7ff000
  800f08:	6a 00                	push   $0x0
  800f0a:	e8 42 fc ff ff       	call   800b51 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	79 14                	jns    800f2a <pgfault+0xd7>
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	68 cc 17 80 00       	push   $0x8017cc
  800f1e:	6a 32                	push   $0x32
  800f20:	68 c0 16 80 00       	push   $0x8016c0
  800f25:	e8 06 00 00 00       	call   800f30 <_panic>
	//panic("pgfault not implemented");
}
  800f2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    
	...

00800f30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	53                   	push   %ebx
  800f34:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800f37:	8d 45 14             	lea    0x14(%ebp),%eax
  800f3a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f3d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f43:	e8 ef fc ff ff       	call   800c37 <sys_getenvid>
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	ff 75 0c             	pushl  0xc(%ebp)
  800f4e:	ff 75 08             	pushl  0x8(%ebp)
  800f51:	53                   	push   %ebx
  800f52:	50                   	push   %eax
  800f53:	68 f0 17 80 00       	push   $0x8017f0
  800f58:	e8 10 f2 ff ff       	call   80016d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f5d:	83 c4 18             	add    $0x18,%esp
  800f60:	ff 75 f8             	pushl  -0x8(%ebp)
  800f63:	ff 75 10             	pushl  0x10(%ebp)
  800f66:	e8 b1 f1 ff ff       	call   80011c <vcprintf>
	cprintf("\n");
  800f6b:	c7 04 24 74 13 80 00 	movl   $0x801374,(%esp)
  800f72:	e8 f6 f1 ff ff       	call   80016d <cprintf>
  800f77:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f7a:	cc                   	int3   
  800f7b:	eb fd                	jmp    800f7a <_panic+0x4a>
  800f7d:	00 00                	add    %al,(%eax)
	...

00800f80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f86:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f8d:	75 64                	jne    800ff3 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800f8f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f94:	8b 40 48             	mov    0x48(%eax),%eax
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	6a 07                	push   $0x7
  800f9c:	68 00 f0 bf ee       	push   $0xeebff000
  800fa1:	50                   	push   %eax
  800fa2:	e8 2e fc ff ff       	call   800bd5 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 14                	jns    800fc2 <set_pgfault_handler+0x42>
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 14 18 80 00       	push   $0x801814
  800fb6:	6a 22                	push   $0x22
  800fb8:	68 80 18 80 00       	push   $0x801880
  800fbd:	e8 6e ff ff ff       	call   800f30 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800fc2:	a1 04 20 80 00       	mov    0x802004,%eax
  800fc7:	8b 40 48             	mov    0x48(%eax),%eax
  800fca:	83 ec 08             	sub    $0x8,%esp
  800fcd:	68 00 10 80 00       	push   $0x801000
  800fd2:	50                   	push   %eax
  800fd3:	e8 b3 fa ff ff       	call   800a8b <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 14                	jns    800ff3 <set_pgfault_handler+0x73>
  800fdf:	83 ec 04             	sub    $0x4,%esp
  800fe2:	68 44 18 80 00       	push   $0x801844
  800fe7:	6a 25                	push   $0x25
  800fe9:	68 80 18 80 00       	push   $0x801880
  800fee:	e8 3d ff ff ff       	call   800f30 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    
  800ffd:	00 00                	add    %al,(%eax)
	...

00801000 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801000:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801001:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801006:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801008:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  80100b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80100f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801012:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801016:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  80101a:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  80101c:	83 c4 08             	add    $0x8,%esp
	popal
  80101f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801020:	83 c4 04             	add    $0x4,%esp
	popfl
  801023:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801024:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801025:	c3                   	ret    
	...

00801028 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	57                   	push   %edi
  80102c:	56                   	push   %esi
  80102d:	83 ec 28             	sub    $0x28,%esp
  801030:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801037:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80103e:	8b 45 10             	mov    0x10(%ebp),%eax
  801041:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801044:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801047:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801049:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801051:	8b 55 0c             	mov    0xc(%ebp),%edx
  801054:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801057:	85 ff                	test   %edi,%edi
  801059:	75 21                	jne    80107c <__udivdi3+0x54>
    {
      if (d0 > n1)
  80105b:	39 d1                	cmp    %edx,%ecx
  80105d:	76 49                	jbe    8010a8 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80105f:	f7 f1                	div    %ecx
  801061:	89 c1                	mov    %eax,%ecx
  801063:	31 c0                	xor    %eax,%eax
  801065:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801068:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80106b:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80106e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801071:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801074:	83 c4 28             	add    $0x28,%esp
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	c9                   	leave  
  80107a:	c3                   	ret    
  80107b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80107c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80107f:	0f 87 97 00 00 00    	ja     80111c <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801085:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801088:	83 f0 1f             	xor    $0x1f,%eax
  80108b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80108e:	75 34                	jne    8010c4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801090:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801093:	72 08                	jb     80109d <__udivdi3+0x75>
  801095:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801098:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80109b:	77 7f                	ja     80111c <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80109d:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010a2:	31 c0                	xor    %eax,%eax
  8010a4:	eb c2                	jmp    801068 <__udivdi3+0x40>
  8010a6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	74 79                	je     801128 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010af:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8010b2:	89 fa                	mov    %edi,%edx
  8010b4:	f7 f1                	div    %ecx
  8010b6:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010bb:	f7 f1                	div    %ecx
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	89 f0                	mov    %esi,%eax
  8010c1:	eb a5                	jmp    801068 <__udivdi3+0x40>
  8010c3:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010c4:	b8 20 00 00 00       	mov    $0x20,%eax
  8010c9:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8010cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010cf:	89 fa                	mov    %edi,%edx
  8010d1:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8010d4:	d3 e2                	shl    %cl,%edx
  8010d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d9:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8010dc:	d3 e8                	shr    %cl,%eax
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8010e2:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8010e5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8010e8:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8010ed:	d3 e0                	shl    %cl,%eax
  8010ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8010f2:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8010f5:	d3 ea                	shr    %cl,%edx
  8010f7:	09 d0                	or     %edx,%eax
  8010f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8010fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8010ff:	d3 ea                	shr    %cl,%edx
  801101:	f7 f7                	div    %edi
  801103:	89 d7                	mov    %edx,%edi
  801105:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801108:	f7 e6                	mul    %esi
  80110a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80110c:	39 d7                	cmp    %edx,%edi
  80110e:	72 38                	jb     801148 <__udivdi3+0x120>
  801110:	74 27                	je     801139 <__udivdi3+0x111>
  801112:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801115:	31 c0                	xor    %eax,%eax
  801117:	e9 4c ff ff ff       	jmp    801068 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80111c:	31 c9                	xor    %ecx,%ecx
  80111e:	31 c0                	xor    %eax,%eax
  801120:	e9 43 ff ff ff       	jmp    801068 <__udivdi3+0x40>
  801125:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801128:	b8 01 00 00 00       	mov    $0x1,%eax
  80112d:	31 d2                	xor    %edx,%edx
  80112f:	f7 75 f4             	divl   -0xc(%ebp)
  801132:	89 c1                	mov    %eax,%ecx
  801134:	e9 76 ff ff ff       	jmp    8010af <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801139:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80113c:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80113f:	d3 e0                	shl    %cl,%eax
  801141:	39 f0                	cmp    %esi,%eax
  801143:	73 cd                	jae    801112 <__udivdi3+0xea>
  801145:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801148:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80114b:	49                   	dec    %ecx
  80114c:	31 c0                	xor    %eax,%eax
  80114e:	e9 15 ff ff ff       	jmp    801068 <__udivdi3+0x40>
	...

00801154 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	83 ec 30             	sub    $0x30,%esp
  80115c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801163:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80116a:	8b 75 08             	mov    0x8(%ebp),%esi
  80116d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801170:	8b 45 10             	mov    0x10(%ebp),%eax
  801173:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801176:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801179:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80117b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  80117e:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801181:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801184:	85 d2                	test   %edx,%edx
  801186:	75 1c                	jne    8011a4 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801188:	89 fa                	mov    %edi,%edx
  80118a:	39 f8                	cmp    %edi,%eax
  80118c:	0f 86 c2 00 00 00    	jbe    801254 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801192:	89 f0                	mov    %esi,%eax
  801194:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801196:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801199:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011a0:	eb 12                	jmp    8011b4 <__umoddi3+0x60>
  8011a2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8011a7:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8011aa:	76 18                	jbe    8011c4 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8011ac:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8011af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8011b2:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8011b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8011ba:	83 c4 30             	add    $0x30,%esp
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    
  8011c1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8011c4:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8011c8:	83 f0 1f             	xor    $0x1f,%eax
  8011cb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011ce:	0f 84 ac 00 00 00    	je     801280 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011d4:	b8 20 00 00 00       	mov    $0x20,%eax
  8011d9:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8011dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011df:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8011e2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8011e5:	d3 e2                	shl    %cl,%edx
  8011e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011ea:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8011ed:	d3 e8                	shr    %cl,%eax
  8011ef:	89 d6                	mov    %edx,%esi
  8011f1:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  8011f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011f6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8011f9:	d3 e0                	shl    %cl,%eax
  8011fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011fe:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801201:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801203:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801206:	d3 e0                	shl    %cl,%eax
  801208:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80120e:	d3 ea                	shr    %cl,%edx
  801210:	09 d0                	or     %edx,%eax
  801212:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801215:	d3 ea                	shr    %cl,%edx
  801217:	f7 f6                	div    %esi
  801219:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  80121c:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80121f:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801222:	0f 82 8d 00 00 00    	jb     8012b5 <__umoddi3+0x161>
  801228:	0f 84 91 00 00 00    	je     8012bf <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80122e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801231:	29 c7                	sub    %eax,%edi
  801233:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801235:	89 f2                	mov    %esi,%edx
  801237:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80123a:	d3 e2                	shl    %cl,%edx
  80123c:	89 f8                	mov    %edi,%eax
  80123e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801241:	d3 e8                	shr    %cl,%eax
  801243:	09 c2                	or     %eax,%edx
  801245:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801248:	d3 ee                	shr    %cl,%esi
  80124a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80124d:	e9 62 ff ff ff       	jmp    8011b4 <__umoddi3+0x60>
  801252:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801257:	85 c0                	test   %eax,%eax
  801259:	74 15                	je     801270 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80125b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80125e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801261:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801266:	f7 f1                	div    %ecx
  801268:	e9 29 ff ff ff       	jmp    801196 <__umoddi3+0x42>
  80126d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801270:	b8 01 00 00 00       	mov    $0x1,%eax
  801275:	31 d2                	xor    %edx,%edx
  801277:	f7 75 ec             	divl   -0x14(%ebp)
  80127a:	89 c1                	mov    %eax,%ecx
  80127c:	eb dd                	jmp    80125b <__umoddi3+0x107>
  80127e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801280:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801283:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801286:	72 19                	jb     8012a1 <__umoddi3+0x14d>
  801288:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80128e:	76 11                	jbe    8012a1 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801290:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801293:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801296:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801299:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80129c:	e9 13 ff ff ff       	jmp    8011b4 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8012aa:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8012ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8012b3:	eb db                	jmp    801290 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012b5:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8012b8:	19 f2                	sbb    %esi,%edx
  8012ba:	e9 6f ff ff ff       	jmp    80122e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012bf:	39 c7                	cmp    %eax,%edi
  8012c1:	72 f2                	jb     8012b5 <__umoddi3+0x161>
  8012c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012c6:	e9 63 ff ff ff       	jmp    80122e <__umoddi3+0xda>
