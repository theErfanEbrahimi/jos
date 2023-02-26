
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8a 5d 0c             	mov    0xc(%ebp),%bl
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800042:	56                   	push   %esi
  800043:	e8 6c 06 00 00       	call   8006b4 <strlen>
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	83 f8 02             	cmp    $0x2,%eax
  80004e:	7f 35                	jg     800085 <forkchild+0x51>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	0f be c3             	movsbl %bl,%eax
  800056:	50                   	push   %eax
  800057:	56                   	push   %esi
  800058:	68 00 13 80 00       	push   $0x801300
  80005d:	6a 04                	push   $0x4
  80005f:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800062:	53                   	push   %ebx
  800063:	e8 0c 06 00 00       	call   800674 <snprintf>
	if (fork() == 0) {
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	e8 6a 0c 00 00       	call   800cda <fork>
  800070:	85 c0                	test   %eax,%eax
  800072:	75 11                	jne    800085 <forkchild+0x51>
		forktree(nxt);
  800074:	83 ec 0c             	sub    $0xc,%esp
  800077:	53                   	push   %ebx
  800078:	e8 0f 00 00 00       	call   80008c <forktree>
		exit();
  80007d:	e8 ae 00 00 00       	call   800130 <exit>
  800082:	83 c4 10             	add    $0x10,%esp
	}
}
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <forktree>:

void
forktree(const char *cur)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	53                   	push   %ebx
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800096:	e8 c4 0b 00 00       	call   800c5f <sys_getenvid>
  80009b:	83 ec 04             	sub    $0x4,%esp
  80009e:	53                   	push   %ebx
  80009f:	50                   	push   %eax
  8000a0:	68 05 13 80 00       	push   $0x801305
  8000a5:	e8 eb 00 00 00       	call   800195 <cprintf>

	forkchild(cur, '0');
  8000aa:	83 c4 08             	add    $0x8,%esp
  8000ad:	6a 30                	push   $0x30
  8000af:	53                   	push   %ebx
  8000b0:	e8 7f ff ff ff       	call   800034 <forkchild>
	forkchild(cur, '1');
  8000b5:	83 c4 08             	add    $0x8,%esp
  8000b8:	6a 31                	push   $0x31
  8000ba:	53                   	push   %ebx
  8000bb:	e8 74 ff ff ff       	call   800034 <forkchild>
  8000c0:	83 c4 10             	add    $0x10,%esp
}
  8000c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <umain>:

void
umain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000ce:	68 15 13 80 00       	push   $0x801315
  8000d3:	e8 b4 ff ff ff       	call   80008c <forktree>
  8000d8:	83 c4 10             	add    $0x10,%esp
}
  8000db:	c9                   	leave  
  8000dc:	c3                   	ret    
  8000dd:	00 00                	add    %al,(%eax)
	...

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000eb:	e8 6f 0b 00 00       	call   800c5f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000fc:	c1 e0 07             	shl    $0x7,%eax
  8000ff:	29 d0                	sub    %edx,%eax
  800101:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800106:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010b:	85 f6                	test   %esi,%esi
  80010d:	7e 07                	jle    800116 <libmain+0x36>
		binaryname = argv[0];
  80010f:	8b 03                	mov    (%ebx),%eax
  800111:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	53                   	push   %ebx
  80011a:	56                   	push   %esi
  80011b:	e8 a8 ff ff ff       	call   8000c8 <umain>

	// exit gracefully
	exit();
  800120:	e8 0b 00 00 00       	call   800130 <exit>
  800125:	83 c4 10             	add    $0x10,%esp
}
  800128:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    
	...

00800130 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800136:	6a 00                	push   $0x0
  800138:	e8 41 0b 00 00       	call   800c7e <sys_env_destroy>
  80013d:	83 c4 10             	add    $0x10,%esp
}
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800154:	00 00 00 
	b.cnt = 0;
  800157:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80015e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016d:	50                   	push   %eax
  80016e:	68 ac 01 80 00       	push   $0x8001ac
  800173:	e8 70 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800178:	83 c4 08             	add    $0x8,%esp
  80017b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800181:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800187:	50                   	push   %eax
  800188:	e8 9e 08 00 00       	call   800a2b <sys_cputs>
  80018d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80019e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	e8 9a ff ff ff       	call   800144 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 1a                	jne    8001e3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 51 08 00 00       	call   800a2b <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e3:	ff 43 04             	incl   0x4(%ebx)
}
  8001e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    
	...

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001f8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800201:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800204:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800207:	8b 55 10             	mov    0x10(%ebp),%edx
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	bf 00 00 00 00       	mov    $0x0,%edi
  800214:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800217:	72 04                	jb     80021d <printnum+0x31>
  800219:	39 c2                	cmp    %eax,%edx
  80021b:	77 3f                	ja     80025c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800226:	50                   	push   %eax
  800227:	52                   	push   %edx
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800230:	ff 75 e0             	pushl  -0x20(%ebp)
  800233:	e8 18 0e 00 00       	call   801050 <__udivdi3>
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	52                   	push   %edx
  80023c:	50                   	push   %eax
  80023d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800240:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800243:	e8 a4 ff ff ff       	call   8001ec <printnum>
  800248:	83 c4 20             	add    $0x20,%esp
  80024b:	eb 14                	jmp    800261 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	ff 75 e8             	pushl  -0x18(%ebp)
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff 55 ec             	call   *-0x14(%ebp)
  800259:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025c:	4b                   	dec    %ebx
  80025d:	85 db                	test   %ebx,%ebx
  80025f:	7f ec                	jg     80024d <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 e8             	pushl  -0x18(%ebp)
  800267:	83 ec 04             	sub    $0x4,%esp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	e8 05 0f 00 00       	call   80117c <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 20 13 80 00 	movsbl 0x801320(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff 55 ec             	call   *-0x14(%ebp)
  800285:	83 c4 10             	add    $0x10,%esp
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 42 08             	lea    0x8(%edx),%eax
  80029f:	89 01                	mov    %eax,(%ecx)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x3a>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 42 04             	lea    0x4(%edx),%eax
  8002b1:	89 01                	mov    %eax,(%ecx)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 42 04             	lea    0x4(%edx),%eax
  8002c1:	89 01                	mov    %eax,(%ecx)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002d2:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002d5:	8b 11                	mov    (%ecx),%edx
  8002d7:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002da:	73 0a                	jae    8002e6 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
  8002e1:	8d 42 01             	lea    0x1(%edx),%eax
  8002e4:	89 01                	mov    %eax,(%ecx)
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 3c             	sub    $0x3c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	eb 1a                	jmp    800316 <vprintfmt+0x2e>
  8002fc:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002ff:	eb 15                	jmp    800316 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800301:	84 c0                	test   %al,%al
  800303:	0f 84 15 03 00 00    	je     80061e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	57                   	push   %edi
  80030d:	0f b6 c0             	movzbl %al,%eax
  800310:	50                   	push   %eax
  800311:	ff d6                	call   *%esi
  800313:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800316:	8a 03                	mov    (%ebx),%al
  800318:	43                   	inc    %ebx
  800319:	3c 25                	cmp    $0x25,%al
  80031b:	75 e4                	jne    800301 <vprintfmt+0x19>
  80031d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800324:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80032b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800332:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800339:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80033d:	eb 0a                	jmp    800349 <vprintfmt+0x61>
  80033f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800346:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8a 03                	mov    (%ebx),%al
  80034b:	0f b6 d0             	movzbl %al,%edx
  80034e:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800351:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800354:	83 e8 23             	sub    $0x23,%eax
  800357:	3c 55                	cmp    $0x55,%al
  800359:	0f 87 9c 02 00 00    	ja     8005fb <vprintfmt+0x313>
  80035f:	0f b6 c0             	movzbl %al,%eax
  800362:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
  800369:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80036d:	eb d7                	jmp    800346 <vprintfmt+0x5e>
  80036f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800373:	eb d1                	jmp    800346 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800375:	89 d9                	mov    %ebx,%ecx
  800377:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800381:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800384:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800388:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80038b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80038f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800390:	8d 42 d0             	lea    -0x30(%edx),%eax
  800393:	83 f8 09             	cmp    $0x9,%eax
  800396:	77 21                	ja     8003b9 <vprintfmt+0xd1>
  800398:	eb e4                	jmp    80037e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039a:	8b 55 14             	mov    0x14(%ebp),%edx
  80039d:	8d 42 04             	lea    0x4(%edx),%eax
  8003a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a3:	8b 12                	mov    (%edx),%edx
  8003a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003a8:	eb 12                	jmp    8003bc <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ae:	79 96                	jns    800346 <vprintfmt+0x5e>
  8003b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b7:	eb 8d                	jmp    800346 <vprintfmt+0x5e>
  8003b9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003c0:	79 84                	jns    800346 <vprintfmt+0x5e>
  8003c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003cf:	e9 72 ff ff ff       	jmp    800346 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d4:	ff 45 d4             	incl   -0x2c(%ebp)
  8003d7:	e9 6a ff ff ff       	jmp    800346 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003df:	8d 42 04             	lea    0x4(%edx),%eax
  8003e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	57                   	push   %edi
  8003e9:	ff 32                	pushl  (%edx)
  8003eb:	ff d6                	call   *%esi
			break;
  8003ed:	83 c4 10             	add    $0x10,%esp
  8003f0:	e9 07 ff ff ff       	jmp    8002fc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f5:	8b 55 14             	mov    0x14(%ebp),%edx
  8003f8:	8d 42 04             	lea    0x4(%edx),%eax
  8003fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8003fe:	8b 02                	mov    (%edx),%eax
  800400:	85 c0                	test   %eax,%eax
  800402:	79 02                	jns    800406 <vprintfmt+0x11e>
  800404:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x12e>
  80040b:	8b 14 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 15                	jne    80042b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 31 13 80 00       	push   $0x801331
  80041c:	57                   	push   %edi
  80041d:	56                   	push   %esi
  80041e:	e8 6e 02 00 00       	call   800691 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	e9 d1 fe ff ff       	jmp    8002fc <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 3a 13 80 00       	push   $0x80133a
  800431:	57                   	push   %edi
  800432:	56                   	push   %esi
  800433:	e8 59 02 00 00       	call   800691 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
  80043b:	e9 bc fe ff ff       	jmp    8002fc <vprintfmt+0x14>
  800440:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800443:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800446:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800449:	8b 55 14             	mov    0x14(%ebp),%edx
  80044c:	8d 42 04             	lea    0x4(%edx),%eax
  80044f:	89 45 14             	mov    %eax,0x14(%ebp)
  800452:	8b 1a                	mov    (%edx),%ebx
  800454:	85 db                	test   %ebx,%ebx
  800456:	75 05                	jne    80045d <vprintfmt+0x175>
  800458:	bb 3d 13 80 00       	mov    $0x80133d,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80045d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800461:	7e 66                	jle    8004c9 <vprintfmt+0x1e1>
  800463:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800467:	74 60                	je     8004c9 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	51                   	push   %ecx
  80046d:	53                   	push   %ebx
  80046e:	e8 57 02 00 00       	call   8006ca <strnlen>
  800473:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800476:	29 c1                	sub    %eax,%ecx
  800478:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800482:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800485:	eb 0f                	jmp    800496 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	57                   	push   %edi
  80048b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80048e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800490:	ff 4d d8             	decl   -0x28(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049a:	7f eb                	jg     800487 <vprintfmt+0x19f>
  80049c:	eb 2b                	jmp    8004c9 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a5:	74 15                	je     8004bc <vprintfmt+0x1d4>
  8004a7:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004aa:	83 f8 5e             	cmp    $0x5e,%eax
  8004ad:	76 0d                	jbe    8004bc <vprintfmt+0x1d4>
					putch('?', putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	57                   	push   %edi
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	eb 0a                	jmp    8004c6 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	57                   	push   %edi
  8004c0:	52                   	push   %edx
  8004c1:	ff d6                	call   *%esi
  8004c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c6:	ff 4d d8             	decl   -0x28(%ebp)
  8004c9:	8a 03                	mov    (%ebx),%al
  8004cb:	43                   	inc    %ebx
  8004cc:	84 c0                	test   %al,%al
  8004ce:	74 1b                	je     8004eb <vprintfmt+0x203>
  8004d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d4:	78 c8                	js     80049e <vprintfmt+0x1b6>
  8004d6:	ff 4d dc             	decl   -0x24(%ebp)
  8004d9:	79 c3                	jns    80049e <vprintfmt+0x1b6>
  8004db:	eb 0e                	jmp    8004eb <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	57                   	push   %edi
  8004e1:	6a 20                	push   $0x20
  8004e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e5:	ff 4d d8             	decl   -0x28(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ef:	7f ec                	jg     8004dd <vprintfmt+0x1f5>
  8004f1:	e9 06 fe ff ff       	jmp    8002fc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004fa:	7e 10                	jle    80050c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ff:	8d 42 08             	lea    0x8(%edx),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	8b 52 04             	mov    0x4(%edx),%edx
  80050a:	eb 20                	jmp    80052c <vprintfmt+0x244>
	else if (lflag)
  80050c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800510:	74 0e                	je     800520 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	99                   	cltd   
  80051e:	eb 0c                	jmp    80052c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80052c:	89 d1                	mov    %edx,%ecx
  80052e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800530:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800533:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800536:	85 c9                	test   %ecx,%ecx
  800538:	78 0a                	js     800544 <vprintfmt+0x25c>
  80053a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80053f:	e9 89 00 00 00       	jmp    8005cd <vprintfmt+0x2e5>
				putch('-', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	57                   	push   %edi
  800548:	6a 2d                	push   $0x2d
  80054a:	ff d6                	call   *%esi
				num = -(long long) num;
  80054c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80054f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800552:	f7 da                	neg    %edx
  800554:	83 d1 00             	adc    $0x0,%ecx
  800557:	f7 d9                	neg    %ecx
  800559:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb 6a                	jmp    8005cd <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800563:	8d 45 14             	lea    0x14(%ebp),%eax
  800566:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800569:	e8 22 fd ff ff       	call   800290 <getuint>
  80056e:	89 d1                	mov    %edx,%ecx
  800570:	89 c2                	mov    %eax,%edx
  800572:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800577:	eb 54                	jmp    8005cd <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800579:	8d 45 14             	lea    0x14(%ebp),%eax
  80057c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80057f:	e8 0c fd ff ff       	call   800290 <getuint>
  800584:	89 d1                	mov    %edx,%ecx
  800586:	89 c2                	mov    %eax,%edx
  800588:	bb 08 00 00 00       	mov    $0x8,%ebx
  80058d:	eb 3e                	jmp    8005cd <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	57                   	push   %edi
  800593:	6a 30                	push   $0x30
  800595:	ff d6                	call   *%esi
			putch('x', putdat);
  800597:	83 c4 08             	add    $0x8,%esp
  80059a:	57                   	push   %edi
  80059b:	6a 78                	push   $0x78
  80059d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80059f:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a2:	8d 42 04             	lea    0x4(%edx),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a8:	8b 12                	mov    (%edx),%edx
  8005aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005af:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb 14                	jmp    8005cd <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005bf:	e8 cc fc ff ff       	call   800290 <getuint>
  8005c4:	89 d1                	mov    %edx,%ecx
  8005c6:	89 c2                	mov    %eax,%edx
  8005c8:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8005d8:	53                   	push   %ebx
  8005d9:	51                   	push   %ecx
  8005da:	52                   	push   %edx
  8005db:	89 fa                	mov    %edi,%edx
  8005dd:	89 f0                	mov    %esi,%eax
  8005df:	e8 08 fc ff ff       	call   8001ec <printnum>
			break;
  8005e4:	83 c4 20             	add    $0x20,%esp
  8005e7:	e9 10 fd ff ff       	jmp    8002fc <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	52                   	push   %edx
  8005f1:	ff d6                	call   *%esi
			break;
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	e9 01 fd ff ff       	jmp    8002fc <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	57                   	push   %edi
  8005ff:	6a 25                	push   $0x25
  800601:	ff d6                	call   *%esi
  800603:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800606:	83 ea 02             	sub    $0x2,%edx
  800609:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80060c:	8a 02                	mov    (%edx),%al
  80060e:	4a                   	dec    %edx
  80060f:	3c 25                	cmp    $0x25,%al
  800611:	75 f9                	jne    80060c <vprintfmt+0x324>
  800613:	83 c2 02             	add    $0x2,%edx
  800616:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800619:	e9 de fc ff ff       	jmp    8002fc <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80061e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800621:	5b                   	pop    %ebx
  800622:	5e                   	pop    %esi
  800623:	5f                   	pop    %edi
  800624:	c9                   	leave  
  800625:	c3                   	ret    

00800626 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	83 ec 18             	sub    $0x18,%esp
  80062c:	8b 55 08             	mov    0x8(%ebp),%edx
  80062f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800632:	85 d2                	test   %edx,%edx
  800634:	74 37                	je     80066d <vsnprintf+0x47>
  800636:	85 c0                	test   %eax,%eax
  800638:	7e 33                	jle    80066d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800641:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800645:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800648:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80064b:	ff 75 14             	pushl  0x14(%ebp)
  80064e:	ff 75 10             	pushl  0x10(%ebp)
  800651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800654:	50                   	push   %eax
  800655:	68 cc 02 80 00       	push   $0x8002cc
  80065a:	e8 89 fc ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800662:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800665:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	eb 05                	jmp    800672 <vsnprintf+0x4c>
  80066d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800672:	c9                   	leave  
  800673:	c3                   	ret    

00800674 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800680:	50                   	push   %eax
  800681:	ff 75 10             	pushl  0x10(%ebp)
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 97 ff ff ff       	call   800626 <vsnprintf>
	va_end(ap);

	return rc;
}
  80068f:	c9                   	leave  
  800690:	c3                   	ret    

00800691 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80069d:	50                   	push   %eax
  80069e:	ff 75 10             	pushl  0x10(%ebp)
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	ff 75 08             	pushl  0x8(%ebp)
  8006a7:	e8 3c fc ff ff       	call   8002e8 <vprintfmt>
	va_end(ap);
  8006ac:	83 c4 10             	add    $0x10,%esp
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    
  8006b1:	00 00                	add    %al,(%eax)
	...

008006b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bf:	eb 01                	jmp    8006c2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006c1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006c6:	75 f9                	jne    8006c1 <strlen+0xd>
		n++;
	return n;
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d8:	eb 01                	jmp    8006db <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8006da:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006db:	39 d0                	cmp    %edx,%eax
  8006dd:	74 06                	je     8006e5 <strnlen+0x1b>
  8006df:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8006e3:	75 f5                	jne    8006da <strnlen+0x10>
		n++;
	return n;
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ed:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f0:	8a 01                	mov    (%ecx),%al
  8006f2:	88 02                	mov    %al,(%edx)
  8006f4:	42                   	inc    %edx
  8006f5:	41                   	inc    %ecx
  8006f6:	84 c0                	test   %al,%al
  8006f8:	75 f6                	jne    8006f0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	53                   	push   %ebx
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800706:	53                   	push   %ebx
  800707:	e8 a8 ff ff ff       	call   8006b4 <strlen>
	strcpy(dst + len, src);
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800712:	50                   	push   %eax
  800713:	e8 cf ff ff ff       	call   8006e7 <strcpy>
	return dst;
}
  800718:	89 d8                	mov    %ebx,%eax
  80071a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	8b 75 08             	mov    0x8(%ebp),%esi
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	eb 0c                	jmp    800740 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800734:	8a 02                	mov    (%edx),%al
  800736:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800739:	80 3a 01             	cmpb   $0x1,(%edx)
  80073c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80073f:	41                   	inc    %ecx
  800740:	39 d9                	cmp    %ebx,%ecx
  800742:	75 f0                	jne    800734 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800744:	89 f0                	mov    %esi,%eax
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
  80074f:	8b 75 08             	mov    0x8(%ebp),%esi
  800752:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800755:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800758:	85 c9                	test   %ecx,%ecx
  80075a:	75 04                	jne    800760 <strlcpy+0x16>
  80075c:	89 f0                	mov    %esi,%eax
  80075e:	eb 14                	jmp    800774 <strlcpy+0x2a>
  800760:	89 f0                	mov    %esi,%eax
  800762:	eb 04                	jmp    800768 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800764:	88 10                	mov    %dl,(%eax)
  800766:	40                   	inc    %eax
  800767:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800768:	49                   	dec    %ecx
  800769:	74 06                	je     800771 <strlcpy+0x27>
  80076b:	8a 13                	mov    (%ebx),%dl
  80076d:	84 d2                	test   %dl,%dl
  80076f:	75 f3                	jne    800764 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800771:	c6 00 00             	movb   $0x0,(%eax)
  800774:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 55 08             	mov    0x8(%ebp),%edx
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	eb 02                	jmp    800787 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800785:	42                   	inc    %edx
  800786:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800787:	8a 02                	mov    (%edx),%al
  800789:	84 c0                	test   %al,%al
  80078b:	74 04                	je     800791 <strcmp+0x17>
  80078d:	3a 01                	cmp    (%ecx),%al
  80078f:	74 f4                	je     800785 <strcmp+0xb>
  800791:	0f b6 c0             	movzbl %al,%eax
  800794:	0f b6 11             	movzbl (%ecx),%edx
  800797:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a8:	eb 03                	jmp    8007ad <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007aa:	4a                   	dec    %edx
  8007ab:	41                   	inc    %ecx
  8007ac:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	75 07                	jne    8007b8 <strncmp+0x1d>
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 14                	jmp    8007cc <strncmp+0x31>
  8007b8:	8a 01                	mov    (%ecx),%al
  8007ba:	84 c0                	test   %al,%al
  8007bc:	74 04                	je     8007c2 <strncmp+0x27>
  8007be:	3a 03                	cmp    (%ebx),%al
  8007c0:	74 e8                	je     8007aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c2:	0f b6 d0             	movzbl %al,%edx
  8007c5:	0f b6 03             	movzbl (%ebx),%eax
  8007c8:	29 c2                	sub    %eax,%edx
  8007ca:	89 d0                	mov    %edx,%eax
}
  8007cc:	5b                   	pop    %ebx
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007d8:	eb 05                	jmp    8007df <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8007da:	38 ca                	cmp    %cl,%dl
  8007dc:	74 0c                	je     8007ea <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007de:	40                   	inc    %eax
  8007df:	8a 10                	mov    (%eax),%dl
  8007e1:	84 d2                	test   %dl,%dl
  8007e3:	75 f5                	jne    8007da <strchr+0xb>
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007f5:	eb 05                	jmp    8007fc <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007f7:	38 ca                	cmp    %cl,%dl
  8007f9:	74 07                	je     800802 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007fb:	40                   	inc    %eax
  8007fc:	8a 10                	mov    (%eax),%dl
  8007fe:	84 d2                	test   %dl,%dl
  800800:	75 f5                	jne    8007f7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	57                   	push   %edi
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800810:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800813:	85 db                	test   %ebx,%ebx
  800815:	74 36                	je     80084d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800817:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081d:	75 29                	jne    800848 <memset+0x44>
  80081f:	f6 c3 03             	test   $0x3,%bl
  800822:	75 24                	jne    800848 <memset+0x44>
		c &= 0xFF;
  800824:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800827:	89 d6                	mov    %edx,%esi
  800829:	c1 e6 08             	shl    $0x8,%esi
  80082c:	89 d0                	mov    %edx,%eax
  80082e:	c1 e0 18             	shl    $0x18,%eax
  800831:	89 d1                	mov    %edx,%ecx
  800833:	c1 e1 10             	shl    $0x10,%ecx
  800836:	09 c8                	or     %ecx,%eax
  800838:	09 c2                	or     %eax,%edx
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	09 d0                	or     %edx,%eax
  80083e:	89 d9                	mov    %ebx,%ecx
  800840:	c1 e9 02             	shr    $0x2,%ecx
  800843:	fc                   	cld    
  800844:	f3 ab                	rep stos %eax,%es:(%edi)
  800846:	eb 05                	jmp    80084d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800848:	89 d9                	mov    %ebx,%ecx
  80084a:	fc                   	cld    
  80084b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084d:	89 f8                	mov    %edi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	57                   	push   %edi
  800858:	56                   	push   %esi
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80085f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800862:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800864:	39 c6                	cmp    %eax,%esi
  800866:	73 36                	jae    80089e <memmove+0x4a>
  800868:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80086b:	39 d0                	cmp    %edx,%eax
  80086d:	73 2f                	jae    80089e <memmove+0x4a>
		s += n;
		d += n;
  80086f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800872:	f6 c2 03             	test   $0x3,%dl
  800875:	75 1b                	jne    800892 <memmove+0x3e>
  800877:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087d:	75 13                	jne    800892 <memmove+0x3e>
  80087f:	f6 c1 03             	test   $0x3,%cl
  800882:	75 0e                	jne    800892 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800884:	8d 7e fc             	lea    -0x4(%esi),%edi
  800887:	8d 72 fc             	lea    -0x4(%edx),%esi
  80088a:	c1 e9 02             	shr    $0x2,%ecx
  80088d:	fd                   	std    
  80088e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800890:	eb 09                	jmp    80089b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800892:	8d 7e ff             	lea    -0x1(%esi),%edi
  800895:	8d 72 ff             	lea    -0x1(%edx),%esi
  800898:	fd                   	std    
  800899:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80089b:	fc                   	cld    
  80089c:	eb 20                	jmp    8008be <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a4:	75 15                	jne    8008bb <memmove+0x67>
  8008a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ac:	75 0d                	jne    8008bb <memmove+0x67>
  8008ae:	f6 c1 03             	test   $0x3,%cl
  8008b1:	75 08                	jne    8008bb <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008b3:	c1 e9 02             	shr    $0x2,%ecx
  8008b6:	fc                   	cld    
  8008b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b9:	eb 03                	jmp    8008be <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008bb:	fc                   	cld    
  8008bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 81 ff ff ff       	call   800854 <memmove>
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	83 ec 04             	sub    $0x4,%esp
  8008dc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008df:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	eb 1b                	jmp    800902 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008e7:	8a 1a                	mov    (%edx),%bl
  8008e9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008ec:	8a 19                	mov    (%ecx),%bl
  8008ee:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008f1:	74 0d                	je     800900 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008f3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008f7:	0f b6 c3             	movzbl %bl,%eax
  8008fa:	29 c2                	sub    %eax,%edx
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	eb 0d                	jmp    80090d <memcmp+0x38>
		s1++, s2++;
  800900:	42                   	inc    %edx
  800901:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800902:	48                   	dec    %eax
  800903:	83 f8 ff             	cmp    $0xffffffff,%eax
  800906:	75 df                	jne    8008e7 <memcmp+0x12>
  800908:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80090d:	83 c4 04             	add    $0x4,%esp
  800910:	5b                   	pop    %ebx
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80091c:	89 c2                	mov    %eax,%edx
  80091e:	03 55 10             	add    0x10(%ebp),%edx
  800921:	eb 05                	jmp    800928 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800923:	38 08                	cmp    %cl,(%eax)
  800925:	74 05                	je     80092c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800927:	40                   	inc    %eax
  800928:	39 d0                	cmp    %edx,%eax
  80092a:	72 f7                	jb     800923 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	83 ec 04             	sub    $0x4,%esp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 75 10             	mov    0x10(%ebp),%esi
  80093d:	eb 01                	jmp    800940 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80093f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800940:	8a 01                	mov    (%ecx),%al
  800942:	3c 20                	cmp    $0x20,%al
  800944:	74 f9                	je     80093f <strtol+0x11>
  800946:	3c 09                	cmp    $0x9,%al
  800948:	74 f5                	je     80093f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  80094a:	3c 2b                	cmp    $0x2b,%al
  80094c:	75 0a                	jne    800958 <strtol+0x2a>
		s++;
  80094e:	41                   	inc    %ecx
  80094f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800956:	eb 17                	jmp    80096f <strtol+0x41>
	else if (*s == '-')
  800958:	3c 2d                	cmp    $0x2d,%al
  80095a:	74 09                	je     800965 <strtol+0x37>
  80095c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800963:	eb 0a                	jmp    80096f <strtol+0x41>
		s++, neg = 1;
  800965:	8d 49 01             	lea    0x1(%ecx),%ecx
  800968:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80096f:	85 f6                	test   %esi,%esi
  800971:	74 05                	je     800978 <strtol+0x4a>
  800973:	83 fe 10             	cmp    $0x10,%esi
  800976:	75 1a                	jne    800992 <strtol+0x64>
  800978:	8a 01                	mov    (%ecx),%al
  80097a:	3c 30                	cmp    $0x30,%al
  80097c:	75 10                	jne    80098e <strtol+0x60>
  80097e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800982:	75 0a                	jne    80098e <strtol+0x60>
		s += 2, base = 16;
  800984:	83 c1 02             	add    $0x2,%ecx
  800987:	be 10 00 00 00       	mov    $0x10,%esi
  80098c:	eb 04                	jmp    800992 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80098e:	85 f6                	test   %esi,%esi
  800990:	74 07                	je     800999 <strtol+0x6b>
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb 13                	jmp    8009ac <strtol+0x7e>
  800999:	3c 30                	cmp    $0x30,%al
  80099b:	74 07                	je     8009a4 <strtol+0x76>
  80099d:	be 0a 00 00 00       	mov    $0xa,%esi
  8009a2:	eb ee                	jmp    800992 <strtol+0x64>
		s++, base = 8;
  8009a4:	41                   	inc    %ecx
  8009a5:	be 08 00 00 00       	mov    $0x8,%esi
  8009aa:	eb e6                	jmp    800992 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ac:	8a 11                	mov    (%ecx),%dl
  8009ae:	88 d3                	mov    %dl,%bl
  8009b0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009b3:	3c 09                	cmp    $0x9,%al
  8009b5:	77 08                	ja     8009bf <strtol+0x91>
			dig = *s - '0';
  8009b7:	0f be c2             	movsbl %dl,%eax
  8009ba:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009bd:	eb 1c                	jmp    8009db <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009bf:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009c2:	3c 19                	cmp    $0x19,%al
  8009c4:	77 08                	ja     8009ce <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009c6:	0f be c2             	movsbl %dl,%eax
  8009c9:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009cc:	eb 0d                	jmp    8009db <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ce:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009d1:	3c 19                	cmp    $0x19,%al
  8009d3:	77 15                	ja     8009ea <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009d5:	0f be c2             	movsbl %dl,%eax
  8009d8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8009db:	39 f2                	cmp    %esi,%edx
  8009dd:	7d 0b                	jge    8009ea <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009df:	41                   	inc    %ecx
  8009e0:	89 f8                	mov    %edi,%eax
  8009e2:	0f af c6             	imul   %esi,%eax
  8009e5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009e8:	eb c2                	jmp    8009ac <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009ea:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f0:	74 05                	je     8009f7 <strtol+0xc9>
		*endptr = (char *) s;
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009fb:	74 04                	je     800a01 <strtol+0xd3>
  8009fd:	89 c7                	mov    %eax,%edi
  8009ff:	f7 df                	neg    %edi
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	83 c4 04             	add    $0x4,%esp
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    
	...

00800a0c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a12:	b8 01 00 00 00       	mov    $0x1,%eax
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1c:	89 fa                	mov    %edi,%edx
  800a1e:	89 f9                	mov    %edi,%ecx
  800a20:	89 fb                	mov    %edi,%ebx
  800a22:	89 fe                	mov    %edi,%esi
  800a24:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	83 ec 04             	sub    $0x4,%esp
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	89 fb                	mov    %edi,%ebx
  800a43:	89 fe                	mov    %edi,%esi
  800a45:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a47:	83 c4 04             	add    $0x4,%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	83 ec 0c             	sub    $0xc,%esp
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
  800a65:	89 f9                	mov    %edi,%ecx
  800a67:	89 fb                	mov    %edi,%ebx
  800a69:	89 fe                	mov    %edi,%esi
  800a6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	7e 17                	jle    800a88 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a71:	83 ec 0c             	sub    $0xc,%esp
  800a74:	50                   	push   %eax
  800a75:	6a 0d                	push   $0xd
  800a77:	68 1f 16 80 00       	push   $0x80161f
  800a7c:	6a 23                	push   $0x23
  800a7e:	68 3c 16 80 00       	push   $0x80163c
  800a83:	e8 d0 04 00 00       	call   800f58 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a9f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800aa7:	be 00 00 00 00       	mov    $0x0,%esi
  800aac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  800acc:	89 fb                	mov    %edi,%ebx
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	7e 17                	jle    800aed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad6:	83 ec 0c             	sub    $0xc,%esp
  800ad9:	50                   	push   %eax
  800ada:	6a 0a                	push   $0xa
  800adc:	68 1f 16 80 00       	push   $0x80161f
  800ae1:	6a 23                	push   $0x23
  800ae3:	68 3c 16 80 00       	push   $0x80163c
  800ae8:	e8 6b 04 00 00       	call   800f58 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	8b 55 08             	mov    0x8(%ebp),%edx
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b8 09 00 00 00       	mov    $0x9,%eax
  800b09:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0e:	89 fb                	mov    %edi,%ebx
  800b10:	89 fe                	mov    %edi,%esi
  800b12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b14:	85 c0                	test   %eax,%eax
  800b16:	7e 17                	jle    800b2f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	50                   	push   %eax
  800b1c:	6a 09                	push   $0x9
  800b1e:	68 1f 16 80 00       	push   $0x80161f
  800b23:	6a 23                	push   $0x23
  800b25:	68 3c 16 80 00       	push   $0x80163c
  800b2a:	e8 29 04 00 00       	call   800f58 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b50:	89 fb                	mov    %edi,%ebx
  800b52:	89 fe                	mov    %edi,%esi
  800b54:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	7e 17                	jle    800b71 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	50                   	push   %eax
  800b5e:	6a 08                	push   $0x8
  800b60:	68 1f 16 80 00       	push   $0x80161f
  800b65:	6a 23                	push   $0x23
  800b67:	68 3c 16 80 00       	push   $0x80163c
  800b6c:	e8 e7 03 00 00       	call   800f58 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b92:	89 fb                	mov    %edi,%ebx
  800b94:	89 fe                	mov    %edi,%esi
  800b96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	7e 17                	jle    800bb3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9c:	83 ec 0c             	sub    $0xc,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 06                	push   $0x6
  800ba2:	68 1f 16 80 00       	push   $0x80161f
  800ba7:	6a 23                	push   $0x23
  800ba9:	68 3c 16 80 00       	push   $0x80163c
  800bae:	e8 a5 03 00 00       	call   800f58 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 05                	push   $0x5
  800be4:	68 1f 16 80 00       	push   $0x80161f
  800be9:	6a 23                	push   $0x23
  800beb:	68 3c 16 80 00       	push   $0x80163c
  800bf0:	e8 63 03 00 00       	call   800f58 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c14:	bf 00 00 00 00       	mov    $0x0,%edi
  800c19:	89 fe                	mov    %edi,%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 04                	push   $0x4
  800c27:	68 1f 16 80 00       	push   $0x80161f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 3c 16 80 00       	push   $0x80163c
  800c33:	e8 20 03 00 00       	call   800f58 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c50:	89 fa                	mov    %edi,%edx
  800c52:	89 f9                	mov    %edi,%ecx
  800c54:	89 fb                	mov    %edi,%ebx
  800c56:	89 fe                	mov    %edi,%esi
  800c58:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6f:	89 fa                	mov    %edi,%edx
  800c71:	89 f9                	mov    %edi,%ecx
  800c73:	89 fb                	mov    %edi,%ebx
  800c75:	89 fe                	mov    %edi,%esi
  800c77:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c94:	89 f9                	mov    %edi,%ecx
  800c96:	89 fb                	mov    %edi,%ebx
  800c98:	89 fe                	mov    %edi,%esi
  800c9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 03                	push   $0x3
  800ca6:	68 1f 16 80 00       	push   $0x80161f
  800cab:	6a 23                	push   $0x23
  800cad:	68 3c 16 80 00       	push   $0x80163c
  800cb2:	e8 a1 02 00 00       	call   800f58 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    
	...

00800cc0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800cc6:	68 4a 16 80 00       	push   $0x80164a
  800ccb:	68 92 00 00 00       	push   $0x92
  800cd0:	68 60 16 80 00       	push   $0x801660
  800cd5:	e8 7e 02 00 00       	call   800f58 <_panic>

00800cda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800ce3:	68 7b 0e 80 00       	push   $0x800e7b
  800ce8:	e8 bb 02 00 00       	call   800fa8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ced:	ba 07 00 00 00       	mov    $0x7,%edx
  800cf2:	89 d0                	mov    %edx,%eax
  800cf4:	cd 30                	int    $0x30
  800cf6:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 25                	jne    800d24 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800cff:	e8 5b ff ff ff       	call   800c5f <sys_getenvid>
  800d04:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d10:	c1 e0 07             	shl    $0x7,%eax
  800d13:	29 d0                	sub    %edx,%eax
  800d15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d1a:	a3 04 20 80 00       	mov    %eax,0x802004
  800d1f:	e9 4d 01 00 00       	jmp    800e71 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800d24:	85 c0                	test   %eax,%eax
  800d26:	79 12                	jns    800d3a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d28:	50                   	push   %eax
  800d29:	68 6b 16 80 00       	push   $0x80166b
  800d2e:	6a 77                	push   $0x77
  800d30:	68 60 16 80 00       	push   $0x801660
  800d35:	e8 1e 02 00 00       	call   800f58 <_panic>
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800d3f:	89 d8                	mov    %ebx,%eax
  800d41:	c1 e8 16             	shr    $0x16,%eax
  800d44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d4b:	a8 01                	test   $0x1,%al
  800d4d:	0f 84 ab 00 00 00    	je     800dfe <fork+0x124>
  800d53:	89 da                	mov    %ebx,%edx
  800d55:	c1 ea 0c             	shr    $0xc,%edx
  800d58:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d5f:	a8 01                	test   $0x1,%al
  800d61:	0f 84 97 00 00 00    	je     800dfe <fork+0x124>
  800d67:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d6e:	a8 04                	test   $0x4,%al
  800d70:	0f 84 88 00 00 00    	je     800dfe <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800d76:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800d7d:	89 d6                	mov    %edx,%esi
  800d7f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800d8a:	a9 02 08 00 00       	test   $0x802,%eax
  800d8f:	74 0f                	je     800da0 <fork+0xc6>
  800d91:	f6 c4 04             	test   $0x4,%ah
  800d94:	75 0a                	jne    800da0 <fork+0xc6>
		perm &= ~PTE_W;
  800d96:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800da0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800da6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	52                   	push   %edx
  800dad:	56                   	push   %esi
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	6a 00                	push   $0x0
  800db2:	e8 04 fe ff ff       	call   800bbb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800db7:	83 c4 20             	add    $0x20,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	79 14                	jns    800dd2 <fork+0xf8>
  800dbe:	83 ec 04             	sub    $0x4,%esp
  800dc1:	68 b4 16 80 00       	push   $0x8016b4
  800dc6:	6a 52                	push   $0x52
  800dc8:	68 60 16 80 00       	push   $0x801660
  800dcd:	e8 86 01 00 00       	call   800f58 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd8:	56                   	push   %esi
  800dd9:	6a 00                	push   $0x0
  800ddb:	56                   	push   %esi
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 d8 fd ff ff       	call   800bbb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800de3:	83 c4 20             	add    $0x20,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	79 14                	jns    800dfe <fork+0x124>
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 d8 16 80 00       	push   $0x8016d8
  800df2:	6a 55                	push   $0x55
  800df4:	68 60 16 80 00       	push   $0x801660
  800df9:	e8 5a 01 00 00       	call   800f58 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800dfe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800e04:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800e0a:	0f 85 2f ff ff ff    	jne    800d3f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	6a 07                	push   $0x7
  800e15:	68 00 f0 bf ee       	push   $0xeebff000
  800e1a:	57                   	push   %edi
  800e1b:	e8 dd fd ff ff       	call   800bfd <sys_page_alloc>
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 15                	jns    800e3c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800e27:	50                   	push   %eax
  800e28:	68 89 16 80 00       	push   $0x801689
  800e2d:	68 83 00 00 00       	push   $0x83
  800e32:	68 60 16 80 00       	push   $0x801660
  800e37:	e8 1c 01 00 00       	call   800f58 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	68 28 10 80 00       	push   $0x801028
  800e44:	57                   	push   %edi
  800e45:	e8 69 fc ff ff       	call   800ab3 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800e4a:	83 c4 08             	add    $0x8,%esp
  800e4d:	6a 02                	push   $0x2
  800e4f:	57                   	push   %edi
  800e50:	e8 e2 fc ff ff       	call   800b37 <sys_env_set_status>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 15                	jns    800e71 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800e5c:	50                   	push   %eax
  800e5d:	68 9c 16 80 00       	push   $0x80169c
  800e62:	68 89 00 00 00       	push   $0x89
  800e67:	68 60 16 80 00       	push   $0x801660
  800e6c:	e8 e7 00 00 00       	call   800f58 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 04             	sub    $0x4,%esp
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800e85:	8b 1a                	mov    (%edx),%ebx
  800e87:	89 d8                	mov    %ebx,%eax
  800e89:	c1 e8 0c             	shr    $0xc,%eax
  800e8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800e93:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e97:	74 05                	je     800e9e <pgfault+0x23>
  800e99:	f6 c4 08             	test   $0x8,%ah
  800e9c:	75 14                	jne    800eb2 <pgfault+0x37>
  800e9e:	83 ec 04             	sub    $0x4,%esp
  800ea1:	68 fc 16 80 00       	push   $0x8016fc
  800ea6:	6a 1e                	push   $0x1e
  800ea8:	68 60 16 80 00       	push   $0x801660
  800ead:	e8 a6 00 00 00       	call   800f58 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	6a 07                	push   $0x7
  800eb7:	68 00 f0 7f 00       	push   $0x7ff000
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 3a fd ff ff       	call   800bfd <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	79 14                	jns    800ede <pgfault+0x63>
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 28 17 80 00       	push   $0x801728
  800ed2:	6a 2a                	push   $0x2a
  800ed4:	68 60 16 80 00       	push   $0x801660
  800ed9:	e8 7a 00 00 00       	call   800f58 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800ede:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800ee4:	83 ec 04             	sub    $0x4,%esp
  800ee7:	68 00 10 00 00       	push   $0x1000
  800eec:	53                   	push   %ebx
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	e8 5d f9 ff ff       	call   800854 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800ef7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efe:	53                   	push   %ebx
  800eff:	6a 00                	push   $0x0
  800f01:	68 00 f0 7f 00       	push   $0x7ff000
  800f06:	6a 00                	push   $0x0
  800f08:	e8 ae fc ff ff       	call   800bbb <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800f0d:	83 c4 20             	add    $0x20,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 14                	jns    800f28 <pgfault+0xad>
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 4c 17 80 00       	push   $0x80174c
  800f1c:	6a 2e                	push   $0x2e
  800f1e:	68 60 16 80 00       	push   $0x801660
  800f23:	e8 30 00 00 00       	call   800f58 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f28:	83 ec 08             	sub    $0x8,%esp
  800f2b:	68 00 f0 7f 00       	push   $0x7ff000
  800f30:	6a 00                	push   $0x0
  800f32:	e8 42 fc ff ff       	call   800b79 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 14                	jns    800f52 <pgfault+0xd7>
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	68 6c 17 80 00       	push   $0x80176c
  800f46:	6a 32                	push   $0x32
  800f48:	68 60 16 80 00       	push   $0x801660
  800f4d:	e8 06 00 00 00       	call   800f58 <_panic>
	//panic("pgfault not implemented");
}
  800f52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    
	...

00800f58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800f5f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f62:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f65:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f6b:	e8 ef fc ff ff       	call   800c5f <sys_getenvid>
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	ff 75 0c             	pushl  0xc(%ebp)
  800f76:	ff 75 08             	pushl  0x8(%ebp)
  800f79:	53                   	push   %ebx
  800f7a:	50                   	push   %eax
  800f7b:	68 90 17 80 00       	push   $0x801790
  800f80:	e8 10 f2 ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f85:	83 c4 18             	add    $0x18,%esp
  800f88:	ff 75 f8             	pushl  -0x8(%ebp)
  800f8b:	ff 75 10             	pushl  0x10(%ebp)
  800f8e:	e8 b1 f1 ff ff       	call   800144 <vcprintf>
	cprintf("\n");
  800f93:	c7 04 24 14 13 80 00 	movl   $0x801314,(%esp)
  800f9a:	e8 f6 f1 ff ff       	call   800195 <cprintf>
  800f9f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fa2:	cc                   	int3   
  800fa3:	eb fd                	jmp    800fa2 <_panic+0x4a>
  800fa5:	00 00                	add    %al,(%eax)
	...

00800fa8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fae:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fb5:	75 64                	jne    80101b <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800fb7:	a1 04 20 80 00       	mov    0x802004,%eax
  800fbc:	8b 40 48             	mov    0x48(%eax),%eax
  800fbf:	83 ec 04             	sub    $0x4,%esp
  800fc2:	6a 07                	push   $0x7
  800fc4:	68 00 f0 bf ee       	push   $0xeebff000
  800fc9:	50                   	push   %eax
  800fca:	e8 2e fc ff ff       	call   800bfd <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 14                	jns    800fea <set_pgfault_handler+0x42>
  800fd6:	83 ec 04             	sub    $0x4,%esp
  800fd9:	68 b4 17 80 00       	push   $0x8017b4
  800fde:	6a 22                	push   $0x22
  800fe0:	68 20 18 80 00       	push   $0x801820
  800fe5:	e8 6e ff ff ff       	call   800f58 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800fea:	a1 04 20 80 00       	mov    0x802004,%eax
  800fef:	8b 40 48             	mov    0x48(%eax),%eax
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	68 28 10 80 00       	push   $0x801028
  800ffa:	50                   	push   %eax
  800ffb:	e8 b3 fa ff ff       	call   800ab3 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 14                	jns    80101b <set_pgfault_handler+0x73>
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	68 e4 17 80 00       	push   $0x8017e4
  80100f:	6a 25                	push   $0x25
  801011:	68 20 18 80 00       	push   $0x801820
  801016:	e8 3d ff ff ff       	call   800f58 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801023:	c9                   	leave  
  801024:	c3                   	ret    
  801025:	00 00                	add    %al,(%eax)
	...

00801028 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801028:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801029:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80102e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801030:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801033:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801037:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80103a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  80103e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801042:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801044:	83 c4 08             	add    $0x8,%esp
	popal
  801047:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801048:	83 c4 04             	add    $0x4,%esp
	popfl
  80104b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80104c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  80104d:	c3                   	ret    
	...

00801050 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	83 ec 28             	sub    $0x28,%esp
  801058:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80105f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801066:	8b 45 10             	mov    0x10(%ebp),%eax
  801069:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80106c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80106f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801071:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801079:	8b 55 0c             	mov    0xc(%ebp),%edx
  80107c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80107f:	85 ff                	test   %edi,%edi
  801081:	75 21                	jne    8010a4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801083:	39 d1                	cmp    %edx,%ecx
  801085:	76 49                	jbe    8010d0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801087:	f7 f1                	div    %ecx
  801089:	89 c1                	mov    %eax,%ecx
  80108b:	31 c0                	xor    %eax,%eax
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801090:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801093:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801096:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801099:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80109c:	83 c4 28             	add    $0x28,%esp
  80109f:	5e                   	pop    %esi
  8010a0:	5f                   	pop    %edi
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    
  8010a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010a4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8010a7:	0f 87 97 00 00 00    	ja     801144 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010ad:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8010b0:	83 f0 1f             	xor    $0x1f,%eax
  8010b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010b6:	75 34                	jne    8010ec <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010b8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8010bb:	72 08                	jb     8010c5 <__udivdi3+0x75>
  8010bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8010c0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8010c3:	77 7f                	ja     801144 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010c5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ca:	31 c0                	xor    %eax,%eax
  8010cc:	eb c2                	jmp    801090 <__udivdi3+0x40>
  8010ce:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	74 79                	je     801150 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8010da:	89 fa                	mov    %edi,%edx
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010e3:	f7 f1                	div    %ecx
  8010e5:	89 c1                	mov    %eax,%ecx
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	eb a5                	jmp    801090 <__udivdi3+0x40>
  8010eb:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8010f1:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8010f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8010f7:	89 fa                	mov    %edi,%edx
  8010f9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8010fc:	d3 e2                	shl    %cl,%edx
  8010fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801101:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801104:	d3 e8                	shr    %cl,%eax
  801106:	89 d7                	mov    %edx,%edi
  801108:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80110a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80110d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801110:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801112:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801115:	d3 e0                	shl    %cl,%eax
  801117:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80111a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80111d:	d3 ea                	shr    %cl,%edx
  80111f:	09 d0                	or     %edx,%eax
  801121:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801124:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801127:	d3 ea                	shr    %cl,%edx
  801129:	f7 f7                	div    %edi
  80112b:	89 d7                	mov    %edx,%edi
  80112d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801130:	f7 e6                	mul    %esi
  801132:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801134:	39 d7                	cmp    %edx,%edi
  801136:	72 38                	jb     801170 <__udivdi3+0x120>
  801138:	74 27                	je     801161 <__udivdi3+0x111>
  80113a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80113d:	31 c0                	xor    %eax,%eax
  80113f:	e9 4c ff ff ff       	jmp    801090 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801144:	31 c9                	xor    %ecx,%ecx
  801146:	31 c0                	xor    %eax,%eax
  801148:	e9 43 ff ff ff       	jmp    801090 <__udivdi3+0x40>
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801150:	b8 01 00 00 00       	mov    $0x1,%eax
  801155:	31 d2                	xor    %edx,%edx
  801157:	f7 75 f4             	divl   -0xc(%ebp)
  80115a:	89 c1                	mov    %eax,%ecx
  80115c:	e9 76 ff ff ff       	jmp    8010d7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801161:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801164:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801167:	d3 e0                	shl    %cl,%eax
  801169:	39 f0                	cmp    %esi,%eax
  80116b:	73 cd                	jae    80113a <__udivdi3+0xea>
  80116d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801170:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801173:	49                   	dec    %ecx
  801174:	31 c0                	xor    %eax,%eax
  801176:	e9 15 ff ff ff       	jmp    801090 <__udivdi3+0x40>
	...

0080117c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	83 ec 30             	sub    $0x30,%esp
  801184:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80118b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801192:	8b 75 08             	mov    0x8(%ebp),%esi
  801195:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801198:	8b 45 10             	mov    0x10(%ebp),%eax
  80119b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80119e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011a1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8011a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8011a6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8011a9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011ac:	85 d2                	test   %edx,%edx
  8011ae:	75 1c                	jne    8011cc <__umoddi3+0x50>
    {
      if (d0 > n1)
  8011b0:	89 fa                	mov    %edi,%edx
  8011b2:	39 f8                	cmp    %edi,%eax
  8011b4:	0f 86 c2 00 00 00    	jbe    80127c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011ba:	89 f0                	mov    %esi,%eax
  8011bc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8011be:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8011c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011c8:	eb 12                	jmp    8011dc <__umoddi3+0x60>
  8011ca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8011cf:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8011d2:	76 18                	jbe    8011ec <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8011d4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8011d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8011da:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8011df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8011e2:	83 c4 30             	add    $0x30,%esp
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    
  8011e9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8011ec:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8011f0:	83 f0 1f             	xor    $0x1f,%eax
  8011f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011f6:	0f 84 ac 00 00 00    	je     8012a8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011fc:	b8 20 00 00 00       	mov    $0x20,%eax
  801201:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801204:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801207:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80120a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80120d:	d3 e2                	shl    %cl,%edx
  80120f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801212:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801215:	d3 e8                	shr    %cl,%eax
  801217:	89 d6                	mov    %edx,%esi
  801219:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80121b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80121e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801221:	d3 e0                	shl    %cl,%eax
  801223:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801226:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801229:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80122b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80122e:	d3 e0                	shl    %cl,%eax
  801230:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801233:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801236:	d3 ea                	shr    %cl,%edx
  801238:	09 d0                	or     %edx,%eax
  80123a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80123d:	d3 ea                	shr    %cl,%edx
  80123f:	f7 f6                	div    %esi
  801241:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801244:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801247:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80124a:	0f 82 8d 00 00 00    	jb     8012dd <__umoddi3+0x161>
  801250:	0f 84 91 00 00 00    	je     8012e7 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801256:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801259:	29 c7                	sub    %eax,%edi
  80125b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80125d:	89 f2                	mov    %esi,%edx
  80125f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801262:	d3 e2                	shl    %cl,%edx
  801264:	89 f8                	mov    %edi,%eax
  801266:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801269:	d3 e8                	shr    %cl,%eax
  80126b:	09 c2                	or     %eax,%edx
  80126d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801270:	d3 ee                	shr    %cl,%esi
  801272:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801275:	e9 62 ff ff ff       	jmp    8011dc <__umoddi3+0x60>
  80127a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80127c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80127f:	85 c0                	test   %eax,%eax
  801281:	74 15                	je     801298 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801283:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801286:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801289:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128e:	f7 f1                	div    %ecx
  801290:	e9 29 ff ff ff       	jmp    8011be <__umoddi3+0x42>
  801295:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801298:	b8 01 00 00 00       	mov    $0x1,%eax
  80129d:	31 d2                	xor    %edx,%edx
  80129f:	f7 75 ec             	divl   -0x14(%ebp)
  8012a2:	89 c1                	mov    %eax,%ecx
  8012a4:	eb dd                	jmp    801283 <__umoddi3+0x107>
  8012a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8012a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ab:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8012ae:	72 19                	jb     8012c9 <__umoddi3+0x14d>
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8012b6:	76 11                	jbe    8012c9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8012be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012c1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012c4:	e9 13 ff ff ff       	jmp    8011dc <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cf:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8012d2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8012d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8012db:	eb db                	jmp    8012b8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012dd:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8012e0:	19 f2                	sbb    %esi,%edx
  8012e2:	e9 6f ff ff ff       	jmp    801256 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012e7:	39 c7                	cmp    %eax,%edi
  8012e9:	72 f2                	jb     8012dd <__umoddi3+0x161>
  8012eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ee:	e9 63 ff ff ff       	jmp    801256 <__umoddi3+0xda>
