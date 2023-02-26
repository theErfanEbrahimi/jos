
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 0f 01 00 00       	call   800140 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800043:	eb 2d                	jmp    800072 <cat+0x3e>
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
		if ((r = write(1, buf, n)) != n)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	53                   	push   %ebx
  800049:	68 20 40 80 00       	push   $0x804020
  80004e:	6a 01                	push   $0x1
  800050:	e8 53 0f 00 00       	call   800fa8 <write>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	39 c3                	cmp    %eax,%ebx
  80005a:	74 16                	je     800072 <cat+0x3e>
			panic("write error copying %s: %e", s, r);
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	50                   	push   %eax
  800060:	57                   	push   %edi
  800061:	68 60 1f 80 00       	push   $0x801f60
  800066:	6a 0d                	push   $0xd
  800068:	68 7b 1f 80 00       	push   $0x801f7b
  80006d:	e8 32 01 00 00       	call   8001a4 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	68 00 20 00 00       	push   $0x2000
  80007a:	68 20 40 80 00       	push   $0x804020
  80007f:	56                   	push   %esi
  800080:	e8 a5 0f 00 00       	call   80102a <read>
  800085:	89 c3                	mov    %eax,%ebx
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	85 c0                	test   %eax,%eax
  80008c:	7f b7                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 16                	jns    8000a8 <cat+0x74>
		panic("error reading %s: %e", s, n);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	50                   	push   %eax
  800096:	57                   	push   %edi
  800097:	68 86 1f 80 00       	push   $0x801f86
  80009c:	6a 0f                	push   $0xf
  80009e:	68 7b 1f 80 00       	push   $0x801f7b
  8000a3:	e8 fc 00 00 00       	call   8001a4 <_panic>
}
  8000a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <umain>:

void
umain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 0c             	sub    $0xc,%esp
	int f, i;

	binaryname = "cat";
  8000b9:	c7 05 00 30 80 00 9b 	movl   $0x801f9b,0x803000
  8000c0:	1f 80 00 
	if (argc == 1)
  8000c3:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000c7:	74 07                	je     8000d0 <umain+0x20>
  8000c9:	be 01 00 00 00       	mov    $0x1,%esi
  8000ce:	eb 61                	jmp    800131 <umain+0x81>
		cat(0, "<stdin>");
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	68 9f 1f 80 00       	push   $0x801f9f
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 55 ff ff ff       	call   800034 <cat>
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	eb 52                	jmp    800136 <umain+0x86>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	6a 00                	push   $0x0
  8000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ec:	ff 34 b0             	pushl  (%eax,%esi,4)
  8000ef:	e8 13 14 00 00       	call   801507 <open>
  8000f4:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  8000f6:	83 c4 10             	add    $0x10,%esp
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	79 19                	jns    800116 <umain+0x66>
				printf("can't open %s: %e\n", argv[i], f);
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	50                   	push   %eax
  800101:	8b 45 0c             	mov    0xc(%ebp),%eax
  800104:	ff 34 b0             	pushl  (%eax,%esi,4)
  800107:	68 a7 1f 80 00       	push   $0x801fa7
  80010c:	e8 37 15 00 00       	call   801648 <printf>
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	eb 1a                	jmp    800130 <umain+0x80>
			else {
				cat(f, argv[i]);
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011c:	ff 34 b0             	pushl  (%eax,%esi,4)
  80011f:	53                   	push   %ebx
  800120:	e8 0f ff ff ff       	call   800034 <cat>
				close(f);
  800125:	89 1c 24             	mov    %ebx,(%esp)
  800128:	e8 53 10 00 00       	call   801180 <close>
  80012d:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800130:	46                   	inc    %esi
  800131:	3b 75 08             	cmp    0x8(%ebp),%esi
  800134:	7c ae                	jl     8000e4 <umain+0x34>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  800136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    
	...

00800140 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	8b 75 08             	mov    0x8(%ebp),%esi
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80014b:	e8 bf 0b 00 00       	call   800d0f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800150:	25 ff 03 00 00       	and    $0x3ff,%eax
  800155:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80015c:	c1 e0 07             	shl    $0x7,%eax
  80015f:	29 d0                	sub    %edx,%eax
  800161:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800166:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016b:	85 f6                	test   %esi,%esi
  80016d:	7e 07                	jle    800176 <libmain+0x36>
		binaryname = argv[0];
  80016f:	8b 03                	mov    (%ebx),%eax
  800171:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	53                   	push   %ebx
  80017a:	56                   	push   %esi
  80017b:	e8 30 ff ff ff       	call   8000b0 <umain>

	// exit gracefully
	exit();
  800180:	e8 0b 00 00 00       	call   800190 <exit>
  800185:	83 c4 10             	add    $0x10,%esp
}
  800188:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    
	...

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800196:	6a 00                	push   $0x0
  800198:	e8 91 0b 00 00       	call   800d2e <sys_env_destroy>
  80019d:	83 c4 10             	add    $0x10,%esp
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
	...

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8001ae:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b1:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001b7:	e8 53 0b 00 00       	call   800d0f <sys_getenvid>
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	53                   	push   %ebx
  8001c6:	50                   	push   %eax
  8001c7:	68 c4 1f 80 00       	push   $0x801fc4
  8001cc:	e8 74 00 00 00       	call   800245 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d1:	83 c4 18             	add    $0x18,%esp
  8001d4:	ff 75 f8             	pushl  -0x8(%ebp)
  8001d7:	ff 75 10             	pushl  0x10(%ebp)
  8001da:	e8 15 00 00 00       	call   8001f4 <vcprintf>
	cprintf("\n");
  8001df:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  8001e6:	e8 5a 00 00 00       	call   800245 <cprintf>
  8001eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ee:	cc                   	int3   
  8001ef:	eb fd                	jmp    8001ee <_panic+0x4a>
  8001f1:	00 00                	add    %al,(%eax)
	...

008001f4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800204:	00 00 00 
	b.cnt = 0;
  800207:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80020e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800211:	ff 75 0c             	pushl  0xc(%ebp)
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021d:	50                   	push   %eax
  80021e:	68 5c 02 80 00       	push   $0x80025c
  800223:	e8 70 01 00 00       	call   800398 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800228:	83 c4 08             	add    $0x8,%esp
  80022b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800231:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800237:	50                   	push   %eax
  800238:	e8 9e 08 00 00       	call   800adb <sys_cputs>
  80023d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80024e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800251:	50                   	push   %eax
  800252:	ff 75 08             	pushl  0x8(%ebp)
  800255:	e8 9a ff ff ff       	call   8001f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	53                   	push   %ebx
  800260:	83 ec 04             	sub    $0x4,%esp
  800263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800266:	8b 03                	mov    (%ebx),%eax
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80026f:	40                   	inc    %eax
  800270:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800272:	3d ff 00 00 00       	cmp    $0xff,%eax
  800277:	75 1a                	jne    800293 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	68 ff 00 00 00       	push   $0xff
  800281:	8d 43 08             	lea    0x8(%ebx),%eax
  800284:	50                   	push   %eax
  800285:	e8 51 08 00 00       	call   800adb <sys_cputs>
		b->idx = 0;
  80028a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800290:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800293:	ff 43 04             	incl   0x4(%ebx)
}
  800296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800299:	c9                   	leave  
  80029a:	c3                   	ret    
	...

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 1c             	sub    $0x1c,%esp
  8002a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002a8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	89 d6                	mov    %edx,%esi
  8002bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8002c4:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8002c7:	72 04                	jb     8002cd <printnum+0x31>
  8002c9:	39 c2                	cmp    %eax,%edx
  8002cb:	77 3f                	ja     80030c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	ff 75 18             	pushl  0x18(%ebp)
  8002d3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002d6:	50                   	push   %eax
  8002d7:	52                   	push   %edx
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e3:	e8 d4 19 00 00       	call   801cbc <__udivdi3>
  8002e8:	83 c4 18             	add    $0x18,%esp
  8002eb:	52                   	push   %edx
  8002ec:	50                   	push   %eax
  8002ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8002f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002f3:	e8 a4 ff ff ff       	call   80029c <printnum>
  8002f8:	83 c4 20             	add    $0x20,%esp
  8002fb:	eb 14                	jmp    800311 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	ff 75 e8             	pushl  -0x18(%ebp)
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff 55 ec             	call   *-0x14(%ebp)
  800309:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030c:	4b                   	dec    %ebx
  80030d:	85 db                	test   %ebx,%ebx
  80030f:	7f ec                	jg     8002fd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	ff 75 e8             	pushl  -0x18(%ebp)
  800317:	83 ec 04             	sub    $0x4,%esp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031f:	ff 75 e0             	pushl  -0x20(%ebp)
  800322:	e8 c1 1a 00 00       	call   801de8 <__umoddi3>
  800327:	83 c4 14             	add    $0x14,%esp
  80032a:	0f be 80 e7 1f 80 00 	movsbl 0x801fe7(%eax),%eax
  800331:	50                   	push   %eax
  800332:	ff 55 ec             	call   *-0x14(%ebp)
  800335:	83 c4 10             	add    $0x10,%esp
}
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	c9                   	leave  
  80033f:	c3                   	ret    

00800340 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 42 08             	lea    0x8(%edx),%eax
  80034f:	89 01                	mov    %eax,(%ecx)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x3a>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 42 04             	lea    0x4(%edx),%eax
  800361:	89 01                	mov    %eax,(%ecx)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 42 04             	lea    0x4(%edx),%eax
  800371:	89 01                	mov    %eax,(%ecx)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800382:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800385:	8b 11                	mov    (%ecx),%edx
  800387:	3b 51 04             	cmp    0x4(%ecx),%edx
  80038a:	73 0a                	jae    800396 <sprintputch+0x1a>
		*b->buf++ = ch;
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	88 02                	mov    %al,(%edx)
  800391:	8d 42 01             	lea    0x1(%edx),%eax
  800394:	89 01                	mov    %eax,(%ecx)
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 3c             	sub    $0x3c,%esp
  8003a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003aa:	eb 1a                	jmp    8003c6 <vprintfmt+0x2e>
  8003ac:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8003af:	eb 15                	jmp    8003c6 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b1:	84 c0                	test   %al,%al
  8003b3:	0f 84 15 03 00 00    	je     8006ce <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	57                   	push   %edi
  8003bd:	0f b6 c0             	movzbl %al,%eax
  8003c0:	50                   	push   %eax
  8003c1:	ff d6                	call   *%esi
  8003c3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c6:	8a 03                	mov    (%ebx),%al
  8003c8:	43                   	inc    %ebx
  8003c9:	3c 25                	cmp    $0x25,%al
  8003cb:	75 e4                	jne    8003b1 <vprintfmt+0x19>
  8003cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003db:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8003ed:	eb 0a                	jmp    8003f9 <vprintfmt+0x61>
  8003ef:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8003f6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8a 03                	mov    (%ebx),%al
  8003fb:	0f b6 d0             	movzbl %al,%edx
  8003fe:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800401:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800404:	83 e8 23             	sub    $0x23,%eax
  800407:	3c 55                	cmp    $0x55,%al
  800409:	0f 87 9c 02 00 00    	ja     8006ab <vprintfmt+0x313>
  80040f:	0f b6 c0             	movzbl %al,%eax
  800412:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  800419:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80041d:	eb d7                	jmp    8003f6 <vprintfmt+0x5e>
  80041f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800423:	eb d1                	jmp    8003f6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800425:	89 d9                	mov    %ebx,%ecx
  800427:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800431:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800434:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800438:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80043b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80043f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800440:	8d 42 d0             	lea    -0x30(%edx),%eax
  800443:	83 f8 09             	cmp    $0x9,%eax
  800446:	77 21                	ja     800469 <vprintfmt+0xd1>
  800448:	eb e4                	jmp    80042e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80044a:	8b 55 14             	mov    0x14(%ebp),%edx
  80044d:	8d 42 04             	lea    0x4(%edx),%eax
  800450:	89 45 14             	mov    %eax,0x14(%ebp)
  800453:	8b 12                	mov    (%edx),%edx
  800455:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800458:	eb 12                	jmp    80046c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80045a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045e:	79 96                	jns    8003f6 <vprintfmt+0x5e>
  800460:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800467:	eb 8d                	jmp    8003f6 <vprintfmt+0x5e>
  800469:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80046c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800470:	79 84                	jns    8003f6 <vprintfmt+0x5e>
  800472:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800475:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800478:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80047f:	e9 72 ff ff ff       	jmp    8003f6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800484:	ff 45 d4             	incl   -0x2c(%ebp)
  800487:	e9 6a ff ff ff       	jmp    8003f6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048c:	8b 55 14             	mov    0x14(%ebp),%edx
  80048f:	8d 42 04             	lea    0x4(%edx),%eax
  800492:	89 45 14             	mov    %eax,0x14(%ebp)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	57                   	push   %edi
  800499:	ff 32                	pushl  (%edx)
  80049b:	ff d6                	call   *%esi
			break;
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	e9 07 ff ff ff       	jmp    8003ac <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a5:	8b 55 14             	mov    0x14(%ebp),%edx
  8004a8:	8d 42 04             	lea    0x4(%edx),%eax
  8004ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ae:	8b 02                	mov    (%edx),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	79 02                	jns    8004b6 <vprintfmt+0x11e>
  8004b4:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b6:	83 f8 0f             	cmp    $0xf,%eax
  8004b9:	7f 0b                	jg     8004c6 <vprintfmt+0x12e>
  8004bb:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  8004c2:	85 d2                	test   %edx,%edx
  8004c4:	75 15                	jne    8004db <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8004c6:	50                   	push   %eax
  8004c7:	68 f8 1f 80 00       	push   $0x801ff8
  8004cc:	57                   	push   %edi
  8004cd:	56                   	push   %esi
  8004ce:	e8 6e 02 00 00       	call   800741 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	e9 d1 fe ff ff       	jmp    8003ac <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004db:	52                   	push   %edx
  8004dc:	68 b1 23 80 00       	push   $0x8023b1
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	e8 59 02 00 00       	call   800741 <printfmt>
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	e9 bc fe ff ff       	jmp    8003ac <vprintfmt+0x14>
  8004f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004fc:	8d 42 04             	lea    0x4(%edx),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	8b 1a                	mov    (%edx),%ebx
  800504:	85 db                	test   %ebx,%ebx
  800506:	75 05                	jne    80050d <vprintfmt+0x175>
  800508:	bb 01 20 80 00       	mov    $0x802001,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80050d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800511:	7e 66                	jle    800579 <vprintfmt+0x1e1>
  800513:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800517:	74 60                	je     800579 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	51                   	push   %ecx
  80051d:	53                   	push   %ebx
  80051e:	e8 57 02 00 00       	call   80077a <strnlen>
  800523:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800532:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800535:	eb 0f                	jmp    800546 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	57                   	push   %edi
  80053b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80053e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800540:	ff 4d d8             	decl   -0x28(%ebp)
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054a:	7f eb                	jg     800537 <vprintfmt+0x19f>
  80054c:	eb 2b                	jmp    800579 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800555:	74 15                	je     80056c <vprintfmt+0x1d4>
  800557:	8d 42 e0             	lea    -0x20(%edx),%eax
  80055a:	83 f8 5e             	cmp    $0x5e,%eax
  80055d:	76 0d                	jbe    80056c <vprintfmt+0x1d4>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	57                   	push   %edi
  800563:	6a 3f                	push   $0x3f
  800565:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	eb 0a                	jmp    800576 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	57                   	push   %edi
  800570:	52                   	push   %edx
  800571:	ff d6                	call   *%esi
  800573:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800576:	ff 4d d8             	decl   -0x28(%ebp)
  800579:	8a 03                	mov    (%ebx),%al
  80057b:	43                   	inc    %ebx
  80057c:	84 c0                	test   %al,%al
  80057e:	74 1b                	je     80059b <vprintfmt+0x203>
  800580:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800584:	78 c8                	js     80054e <vprintfmt+0x1b6>
  800586:	ff 4d dc             	decl   -0x24(%ebp)
  800589:	79 c3                	jns    80054e <vprintfmt+0x1b6>
  80058b:	eb 0e                	jmp    80059b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	57                   	push   %edi
  800591:	6a 20                	push   $0x20
  800593:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800595:	ff 4d d8             	decl   -0x28(%ebp)
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059f:	7f ec                	jg     80058d <vprintfmt+0x1f5>
  8005a1:	e9 06 fe ff ff       	jmp    8003ac <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005aa:	7e 10                	jle    8005bc <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8005ac:	8b 55 14             	mov    0x14(%ebp),%edx
  8005af:	8d 42 08             	lea    0x8(%edx),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b5:	8b 02                	mov    (%edx),%eax
  8005b7:	8b 52 04             	mov    0x4(%edx),%edx
  8005ba:	eb 20                	jmp    8005dc <vprintfmt+0x244>
	else if (lflag)
  8005bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c0:	74 0e                	je     8005d0 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	99                   	cltd   
  8005ce:	eb 0c                	jmp    8005dc <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 50 04             	lea    0x4(%eax),%edx
  8005d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	89 d1                	mov    %edx,%ecx
  8005de:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8005e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e6:	85 c9                	test   %ecx,%ecx
  8005e8:	78 0a                	js     8005f4 <vprintfmt+0x25c>
  8005ea:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005ef:	e9 89 00 00 00       	jmp    80067d <vprintfmt+0x2e5>
				putch('-', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	57                   	push   %edi
  8005f8:	6a 2d                	push   $0x2d
  8005fa:	ff d6                	call   *%esi
				num = -(long long) num;
  8005fc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8005ff:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800602:	f7 da                	neg    %edx
  800604:	83 d1 00             	adc    $0x0,%ecx
  800607:	f7 d9                	neg    %ecx
  800609:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 6a                	jmp    80067d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800619:	e8 22 fd ff ff       	call   800340 <getuint>
  80061e:	89 d1                	mov    %edx,%ecx
  800620:	89 c2                	mov    %eax,%edx
  800622:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800627:	eb 54                	jmp    80067d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062f:	e8 0c fd ff ff       	call   800340 <getuint>
  800634:	89 d1                	mov    %edx,%ecx
  800636:	89 c2                	mov    %eax,%edx
  800638:	bb 08 00 00 00       	mov    $0x8,%ebx
  80063d:	eb 3e                	jmp    80067d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 30                	push   $0x30
  800645:	ff d6                	call   *%esi
			putch('x', putdat);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	57                   	push   %edi
  80064b:	6a 78                	push   $0x78
  80064d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064f:	8b 55 14             	mov    0x14(%ebp),%edx
  800652:	8d 42 04             	lea    0x4(%edx),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
  800658:	8b 12                	mov    (%edx),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb 14                	jmp    80067d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80066f:	e8 cc fc ff ff       	call   800340 <getuint>
  800674:	89 d1                	mov    %edx,%ecx
  800676:	89 c2                	mov    %eax,%edx
  800678:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067d:	83 ec 0c             	sub    $0xc,%esp
  800680:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	ff 75 d8             	pushl  -0x28(%ebp)
  800688:	53                   	push   %ebx
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	89 fa                	mov    %edi,%edx
  80068d:	89 f0                	mov    %esi,%eax
  80068f:	e8 08 fc ff ff       	call   80029c <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	e9 10 fd ff ff       	jmp    8003ac <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	57                   	push   %edi
  8006a0:	52                   	push   %edx
  8006a1:	ff d6                	call   *%esi
			break;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	e9 01 fd ff ff       	jmp    8003ac <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	6a 25                	push   $0x25
  8006b1:	ff d6                	call   *%esi
  8006b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8006b6:	83 ea 02             	sub    $0x2,%edx
  8006b9:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bc:	8a 02                	mov    (%edx),%al
  8006be:	4a                   	dec    %edx
  8006bf:	3c 25                	cmp    $0x25,%al
  8006c1:	75 f9                	jne    8006bc <vprintfmt+0x324>
  8006c3:	83 c2 02             	add    $0x2,%edx
  8006c6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8006c9:	e9 de fc ff ff       	jmp    8003ac <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	74 37                	je     80071d <vsnprintf+0x47>
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	7e 33                	jle    80071d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006f1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8006f8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 7c 03 80 00       	push   $0x80037c
  80070a:	e8 89 fc ff ff       	call   800398 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x4c>
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	pushl  0x10(%ebp)
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	ff 75 08             	pushl  0x8(%ebp)
  80073a:	e8 97 ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 3c fc ff ff       	call   800398 <vprintfmt>
	va_end(ap);
  80075c:	83 c4 10             	add    $0x10,%esp
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    
  800761:	00 00                	add    %al,(%eax)
	...

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 01                	jmp    800772 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800771:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800776:	75 f9                	jne    800771 <strlen+0xd>
		n++;
	return n;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 01                	jmp    80078b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80078a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1b>
  80078f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800793:	75 f5                	jne    80078a <strnlen+0x10>
		n++;
	return n;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	8a 01                	mov    (%ecx),%al
  8007a2:	88 02                	mov    %al,(%edx)
  8007a4:	42                   	inc    %edx
  8007a5:	41                   	inc    %ecx
  8007a6:	84 c0                	test   %al,%al
  8007a8:	75 f6                	jne    8007a0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b6:	53                   	push   %ebx
  8007b7:	e8 a8 ff ff ff       	call   800764 <strlen>
	strcpy(dst + len, src);
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007c2:	50                   	push   %eax
  8007c3:	e8 cf ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007c8:	89 d8                	mov    %ebx,%eax
  8007ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e2:	eb 0c                	jmp    8007f0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8007e4:	8a 02                	mov    (%edx),%al
  8007e6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ef:	41                   	inc    %ecx
  8007f0:	39 d9                	cmp    %ebx,%ecx
  8007f2:	75 f0                	jne    8007e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	85 c9                	test   %ecx,%ecx
  80080a:	75 04                	jne    800810 <strlcpy+0x16>
  80080c:	89 f0                	mov    %esi,%eax
  80080e:	eb 14                	jmp    800824 <strlcpy+0x2a>
  800810:	89 f0                	mov    %esi,%eax
  800812:	eb 04                	jmp    800818 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800814:	88 10                	mov    %dl,(%eax)
  800816:	40                   	inc    %eax
  800817:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800818:	49                   	dec    %ecx
  800819:	74 06                	je     800821 <strlcpy+0x27>
  80081b:	8a 13                	mov    (%ebx),%dl
  80081d:	84 d2                	test   %dl,%dl
  80081f:	75 f3                	jne    800814 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
  800824:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 55 08             	mov    0x8(%ebp),%edx
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	eb 02                	jmp    800837 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800835:	42                   	inc    %edx
  800836:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	8a 02                	mov    (%edx),%al
  800839:	84 c0                	test   %al,%al
  80083b:	74 04                	je     800841 <strcmp+0x17>
  80083d:	3a 01                	cmp    (%ecx),%al
  80083f:	74 f4                	je     800835 <strcmp+0xb>
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 11             	movzbl (%ecx),%edx
  800847:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800855:	8b 55 10             	mov    0x10(%ebp),%edx
  800858:	eb 03                	jmp    80085d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80085a:	4a                   	dec    %edx
  80085b:	41                   	inc    %ecx
  80085c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	85 d2                	test   %edx,%edx
  80085f:	75 07                	jne    800868 <strncmp+0x1d>
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 14                	jmp    80087c <strncmp+0x31>
  800868:	8a 01                	mov    (%ecx),%al
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strncmp+0x27>
  80086e:	3a 03                	cmp    (%ebx),%al
  800870:	74 e8                	je     80085a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 d0             	movzbl %al,%edx
  800875:	0f b6 03             	movzbl (%ebx),%eax
  800878:	29 c2                	sub    %eax,%edx
  80087a:	89 d0                	mov    %edx,%eax
}
  80087c:	5b                   	pop    %ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800888:	eb 05                	jmp    80088f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 0c                	je     80089a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	40                   	inc    %eax
  80088f:	8a 10                	mov    (%eax),%dl
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f5                	jne    80088a <strchr+0xb>
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008a5:	eb 05                	jmp    8008ac <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8008a7:	38 ca                	cmp    %cl,%dl
  8008a9:	74 07                	je     8008b2 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ab:	40                   	inc    %eax
  8008ac:	8a 10                	mov    (%eax),%dl
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f5                	jne    8008a7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8008c3:	85 db                	test   %ebx,%ebx
  8008c5:	74 36                	je     8008fd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cd:	75 29                	jne    8008f8 <memset+0x44>
  8008cf:	f6 c3 03             	test   $0x3,%bl
  8008d2:	75 24                	jne    8008f8 <memset+0x44>
		c &= 0xFF;
  8008d4:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d7:	89 d6                	mov    %edx,%esi
  8008d9:	c1 e6 08             	shl    $0x8,%esi
  8008dc:	89 d0                	mov    %edx,%eax
  8008de:	c1 e0 18             	shl    $0x18,%eax
  8008e1:	89 d1                	mov    %edx,%ecx
  8008e3:	c1 e1 10             	shl    $0x10,%ecx
  8008e6:	09 c8                	or     %ecx,%eax
  8008e8:	09 c2                	or     %eax,%edx
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	09 d0                	or     %edx,%eax
  8008ee:	89 d9                	mov    %ebx,%ecx
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 05                	jmp    8008fd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	89 d9                	mov    %ebx,%ecx
  8008fa:	fc                   	cld    
  8008fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800912:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800914:	39 c6                	cmp    %eax,%esi
  800916:	73 36                	jae    80094e <memmove+0x4a>
  800918:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	73 2f                	jae    80094e <memmove+0x4a>
		s += n;
		d += n;
  80091f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 1b                	jne    800942 <memmove+0x3e>
  800927:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092d:	75 13                	jne    800942 <memmove+0x3e>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0e                	jne    800942 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800934:	8d 7e fc             	lea    -0x4(%esi),%edi
  800937:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093a:	c1 e9 02             	shr    $0x2,%ecx
  80093d:	fd                   	std    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 09                	jmp    80094b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800942:	8d 7e ff             	lea    -0x1(%esi),%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 20                	jmp    80096e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800954:	75 15                	jne    80096b <memmove+0x67>
  800956:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095c:	75 0d                	jne    80096b <memmove+0x67>
  80095e:	f6 c1 03             	test   $0x3,%cl
  800961:	75 08                	jne    80096b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800963:	c1 e9 02             	shr    $0x2,%ecx
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 03                	jmp    80096e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096b:	fc                   	cld    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800975:	ff 75 10             	pushl  0x10(%ebp)
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	ff 75 08             	pushl  0x8(%ebp)
  80097e:	e8 81 ff ff ff       	call   800904 <memmove>
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	83 ec 04             	sub    $0x4,%esp
  80098c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80098f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800995:	eb 1b                	jmp    8009b2 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800997:	8a 1a                	mov    (%edx),%bl
  800999:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80099c:	8a 19                	mov    (%ecx),%bl
  80099e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8009a1:	74 0d                	je     8009b0 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8009a3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8009a7:	0f b6 c3             	movzbl %bl,%eax
  8009aa:	29 c2                	sub    %eax,%edx
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	eb 0d                	jmp    8009bd <memcmp+0x38>
		s1++, s2++;
  8009b0:	42                   	inc    %edx
  8009b1:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	48                   	dec    %eax
  8009b3:	83 f8 ff             	cmp    $0xffffffff,%eax
  8009b6:	75 df                	jne    800997 <memcmp+0x12>
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8009bd:	83 c4 04             	add    $0x4,%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	03 55 10             	add    0x10(%ebp),%edx
  8009d1:	eb 05                	jmp    8009d8 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d3:	38 08                	cmp    %cl,(%eax)
  8009d5:	74 05                	je     8009dc <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d7:	40                   	inc    %eax
  8009d8:	39 d0                	cmp    %edx,%eax
  8009da:	72 f7                	jb     8009d3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	83 ec 04             	sub    $0x4,%esp
  8009e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8009ed:	eb 01                	jmp    8009f0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009ef:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	8a 01                	mov    (%ecx),%al
  8009f2:	3c 20                	cmp    $0x20,%al
  8009f4:	74 f9                	je     8009ef <strtol+0x11>
  8009f6:	3c 09                	cmp    $0x9,%al
  8009f8:	74 f5                	je     8009ef <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fa:	3c 2b                	cmp    $0x2b,%al
  8009fc:	75 0a                	jne    800a08 <strtol+0x2a>
		s++;
  8009fe:	41                   	inc    %ecx
  8009ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a06:	eb 17                	jmp    800a1f <strtol+0x41>
	else if (*s == '-')
  800a08:	3c 2d                	cmp    $0x2d,%al
  800a0a:	74 09                	je     800a15 <strtol+0x37>
  800a0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a13:	eb 0a                	jmp    800a1f <strtol+0x41>
		s++, neg = 1;
  800a15:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a18:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1f:	85 f6                	test   %esi,%esi
  800a21:	74 05                	je     800a28 <strtol+0x4a>
  800a23:	83 fe 10             	cmp    $0x10,%esi
  800a26:	75 1a                	jne    800a42 <strtol+0x64>
  800a28:	8a 01                	mov    (%ecx),%al
  800a2a:	3c 30                	cmp    $0x30,%al
  800a2c:	75 10                	jne    800a3e <strtol+0x60>
  800a2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a32:	75 0a                	jne    800a3e <strtol+0x60>
		s += 2, base = 16;
  800a34:	83 c1 02             	add    $0x2,%ecx
  800a37:	be 10 00 00 00       	mov    $0x10,%esi
  800a3c:	eb 04                	jmp    800a42 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800a3e:	85 f6                	test   %esi,%esi
  800a40:	74 07                	je     800a49 <strtol+0x6b>
  800a42:	bf 00 00 00 00       	mov    $0x0,%edi
  800a47:	eb 13                	jmp    800a5c <strtol+0x7e>
  800a49:	3c 30                	cmp    $0x30,%al
  800a4b:	74 07                	je     800a54 <strtol+0x76>
  800a4d:	be 0a 00 00 00       	mov    $0xa,%esi
  800a52:	eb ee                	jmp    800a42 <strtol+0x64>
		s++, base = 8;
  800a54:	41                   	inc    %ecx
  800a55:	be 08 00 00 00       	mov    $0x8,%esi
  800a5a:	eb e6                	jmp    800a42 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	8a 11                	mov    (%ecx),%dl
  800a5e:	88 d3                	mov    %dl,%bl
  800a60:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a63:	3c 09                	cmp    $0x9,%al
  800a65:	77 08                	ja     800a6f <strtol+0x91>
			dig = *s - '0';
  800a67:	0f be c2             	movsbl %dl,%eax
  800a6a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a6d:	eb 1c                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a72:	3c 19                	cmp    $0x19,%al
  800a74:	77 08                	ja     800a7e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a76:	0f be c2             	movsbl %dl,%eax
  800a79:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a7c:	eb 0d                	jmp    800a8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a81:	3c 19                	cmp    $0x19,%al
  800a83:	77 15                	ja     800a9a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a85:	0f be c2             	movsbl %dl,%eax
  800a88:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a8b:	39 f2                	cmp    %esi,%edx
  800a8d:	7d 0b                	jge    800a9a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a8f:	41                   	inc    %ecx
  800a90:	89 f8                	mov    %edi,%eax
  800a92:	0f af c6             	imul   %esi,%eax
  800a95:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a98:	eb c2                	jmp    800a5c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a9a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa0:	74 05                	je     800aa7 <strtol+0xc9>
		*endptr = (char *) s;
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800aab:	74 04                	je     800ab1 <strtol+0xd3>
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	f7 df                	neg    %edi
}
  800ab1:	89 f8                	mov    %edi,%eax
  800ab3:	83 c4 04             	add    $0x4,%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    
	...

00800abc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  800acc:	89 fa                	mov    %edi,%edx
  800ace:	89 f9                	mov    %edi,%ecx
  800ad0:	89 fb                	mov    %edi,%ebx
  800ad2:	89 fe                	mov    %edi,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	bf 00 00 00 00       	mov    $0x0,%edi
  800aef:	89 f8                	mov    %edi,%eax
  800af1:	89 fb                	mov    %edi,%ebx
  800af3:	89 fe                	mov    %edi,%esi
  800af5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	83 c4 04             	add    $0x4,%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b10:	bf 00 00 00 00       	mov    $0x0,%edi
  800b15:	89 f9                	mov    %edi,%ecx
  800b17:	89 fb                	mov    %edi,%ebx
  800b19:	89 fe                	mov    %edi,%esi
  800b1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 17                	jle    800b38 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	50                   	push   %eax
  800b25:	6a 0d                	push   $0xd
  800b27:	68 df 22 80 00       	push   $0x8022df
  800b2c:	6a 23                	push   $0x23
  800b2e:	68 fc 22 80 00       	push   $0x8022fc
  800b33:	e8 6c f6 ff ff       	call   8001a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800b38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b57:	be 00 00 00 00       	mov    $0x0,%esi
  800b5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b77:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7c:	89 fb                	mov    %edi,%ebx
  800b7e:	89 fe                	mov    %edi,%esi
  800b80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 0a                	push   $0xa
  800b8c:	68 df 22 80 00       	push   $0x8022df
  800b91:	6a 23                	push   $0x23
  800b93:	68 fc 22 80 00       	push   $0x8022fc
  800b98:	e8 07 f6 ff ff       	call   8001a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800bb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbe:	89 fb                	mov    %edi,%ebx
  800bc0:	89 fe                	mov    %edi,%esi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 09                	push   $0x9
  800bce:	68 df 22 80 00       	push   $0x8022df
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 fc 22 80 00       	push   $0x8022fc
  800bda:	e8 c5 f5 ff ff       	call   8001a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800c00:	89 fb                	mov    %edi,%ebx
  800c02:	89 fe                	mov    %edi,%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 08                	push   $0x8
  800c10:	68 df 22 80 00       	push   $0x8022df
  800c15:	6a 23                	push   $0x23
  800c17:	68 fc 22 80 00       	push   $0x8022fc
  800c1c:	e8 83 f5 ff ff       	call   8001a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c38:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c42:	89 fb                	mov    %edi,%ebx
  800c44:	89 fe                	mov    %edi,%esi
  800c46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 06                	push   $0x6
  800c52:	68 df 22 80 00       	push   $0x8022df
  800c57:	6a 23                	push   $0x23
  800c59:	68 fc 22 80 00       	push   $0x8022fc
  800c5e:	e8 41 f5 ff ff       	call   8001a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c80:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	b8 05 00 00 00       	mov    $0x5,%eax
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 05                	push   $0x5
  800c94:	68 df 22 80 00       	push   $0x8022df
  800c99:	6a 23                	push   $0x23
  800c9b:	68 fc 22 80 00       	push   $0x8022fc
  800ca0:	e8 ff f4 ff ff       	call   8001a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc4:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc9:	89 fe                	mov    %edi,%esi
  800ccb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 17                	jle    800ce8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 04                	push   $0x4
  800cd7:	68 df 22 80 00       	push   $0x8022df
  800cdc:	6a 23                	push   $0x23
  800cde:	68 fc 22 80 00       	push   $0x8022fc
  800ce3:	e8 bc f4 ff ff       	call   8001a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800d00:	89 fa                	mov    %edi,%edx
  800d02:	89 f9                	mov    %edi,%ecx
  800d04:	89 fb                	mov    %edi,%ebx
  800d06:	89 fe                	mov    %edi,%esi
  800d08:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d1f:	89 fa                	mov    %edi,%edx
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	89 fb                	mov    %edi,%ebx
  800d25:	89 fe                	mov    %edi,%esi
  800d27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d44:	89 f9                	mov    %edi,%ecx
  800d46:	89 fb                	mov    %edi,%ebx
  800d48:	89 fe                	mov    %edi,%esi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 03                	push   $0x3
  800d56:	68 df 22 80 00       	push   $0x8022df
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 fc 22 80 00       	push   $0x8022fc
  800d62:	e8 3d f4 ff ff       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    
	...

00800d70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d83:	ff 75 08             	pushl  0x8(%ebp)
  800d86:	e8 e5 ff ff ff       	call   800d70 <fd2num>
  800d8b:	83 c4 04             	add    $0x4,%esp
  800d8e:	c1 e0 0c             	shl    $0xc,%eax
  800d91:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d96:	c9                   	leave  
  800d97:	c3                   	ret    

00800d98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	53                   	push   %ebx
  800d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d9f:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800da4:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da6:	89 d0                	mov    %edx,%eax
  800da8:	c1 e8 16             	shr    $0x16,%eax
  800dab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800db2:	a8 01                	test   $0x1,%al
  800db4:	74 10                	je     800dc6 <fd_alloc+0x2e>
  800db6:	89 d0                	mov    %edx,%eax
  800db8:	c1 e8 0c             	shr    $0xc,%eax
  800dbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc2:	a8 01                	test   $0x1,%al
  800dc4:	75 09                	jne    800dcf <fd_alloc+0x37>
			*fd_store = fd;
  800dc6:	89 0b                	mov    %ecx,(%ebx)
  800dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcd:	eb 19                	jmp    800de8 <fd_alloc+0x50>
			return 0;
  800dcf:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd5:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  800ddb:	75 c7                	jne    800da4 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ddd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800de3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800de8:	5b                   	pop    %ebx
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df1:	83 f8 1f             	cmp    $0x1f,%eax
  800df4:	77 35                	ja     800e2b <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df6:	c1 e0 0c             	shl    $0xc,%eax
  800df9:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	c1 e8 16             	shr    $0x16,%eax
  800e04:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e0b:	a8 01                	test   $0x1,%al
  800e0d:	74 1c                	je     800e2b <fd_lookup+0x40>
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	c1 e8 0c             	shr    $0xc,%eax
  800e14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1b:	a8 01                	test   $0x1,%al
  800e1d:	74 0c                	je     800e2b <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e22:	89 10                	mov    %edx,(%eax)
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
  800e29:	eb 05                	jmp    800e30 <fd_lookup+0x45>
	return 0;
  800e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e38:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800e3b:	50                   	push   %eax
  800e3c:	ff 75 08             	pushl  0x8(%ebp)
  800e3f:	e8 a7 ff ff ff       	call   800deb <fd_lookup>
  800e44:	83 c4 08             	add    $0x8,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 0e                	js     800e59 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e51:	89 50 04             	mov    %edx,0x4(%eax)
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	eb 0e                	jmp    800e7d <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e6f:	3b 08                	cmp    (%eax),%ecx
  800e71:	75 09                	jne    800e7c <dev_lookup+0x21>
			*dev = devtab[i];
  800e73:	89 03                	mov    %eax,(%ebx)
  800e75:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7a:	eb 31                	jmp    800ead <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e7c:	42                   	inc    %edx
  800e7d:	8b 04 95 88 23 80 00 	mov    0x802388(,%edx,4),%eax
  800e84:	85 c0                	test   %eax,%eax
  800e86:	75 e7                	jne    800e6f <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e88:	a1 20 60 80 00       	mov    0x806020,%eax
  800e8d:	8b 40 48             	mov    0x48(%eax),%eax
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	51                   	push   %ecx
  800e94:	50                   	push   %eax
  800e95:	68 0c 23 80 00       	push   $0x80230c
  800e9a:	e8 a6 f3 ff ff       	call   800245 <cprintf>
	*dev = 0;
  800e9f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eaa:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  800ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 14             	sub    $0x14,%esp
  800eb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebf:	50                   	push   %eax
  800ec0:	ff 75 08             	pushl  0x8(%ebp)
  800ec3:	e8 23 ff ff ff       	call   800deb <fd_lookup>
  800ec8:	83 c4 08             	add    $0x8,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 55                	js     800f24 <fstat+0x72>
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed9:	ff 30                	pushl  (%eax)
  800edb:	e8 7b ff ff ff       	call   800e5b <dev_lookup>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 3d                	js     800f24 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800ee7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800eee:	75 07                	jne    800ef7 <fstat+0x45>
  800ef0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ef5:	eb 2d                	jmp    800f24 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ef7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800efa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800f01:	00 00 00 
	stat->st_isdir = 0;
  800f04:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f0b:	00 00 00 
	stat->st_dev = dev;
  800f0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f11:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	53                   	push   %ebx
  800f1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f1e:	ff 50 14             	call   *0x14(%eax)
  800f21:	83 c4 10             	add    $0x10,%esp
}
  800f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 14             	sub    $0x14,%esp
  800f30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f36:	50                   	push   %eax
  800f37:	53                   	push   %ebx
  800f38:	e8 ae fe ff ff       	call   800deb <fd_lookup>
  800f3d:	83 c4 08             	add    $0x8,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 5f                	js     800fa3 <ftruncate+0x7a>
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4e:	ff 30                	pushl  (%eax)
  800f50:	e8 06 ff ff ff       	call   800e5b <dev_lookup>
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 47                	js     800fa3 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f5f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800f63:	75 21                	jne    800f86 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800f65:	a1 20 60 80 00       	mov    0x806020,%eax
  800f6a:	8b 40 48             	mov    0x48(%eax),%eax
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	53                   	push   %ebx
  800f71:	50                   	push   %eax
  800f72:	68 2c 23 80 00       	push   $0x80232c
  800f77:	e8 c9 f2 ff ff       	call   800245 <cprintf>
  800f7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	eb 1d                	jmp    800fa3 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800f86:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800f89:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800f8d:	75 07                	jne    800f96 <ftruncate+0x6d>
  800f8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f94:	eb 0d                	jmp    800fa3 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	ff 75 0c             	pushl  0xc(%ebp)
  800f9c:	50                   	push   %eax
  800f9d:	ff 52 18             	call   *0x18(%edx)
  800fa0:	83 c4 10             	add    $0x10,%esp
}
  800fa3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 14             	sub    $0x14,%esp
  800faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	53                   	push   %ebx
  800fb7:	e8 2f fe ff ff       	call   800deb <fd_lookup>
  800fbc:	83 c4 08             	add    $0x8,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 62                	js     801025 <write+0x7d>
  800fc3:	83 ec 08             	sub    $0x8,%esp
  800fc6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	ff 30                	pushl  (%eax)
  800fcf:	e8 87 fe ff ff       	call   800e5b <dev_lookup>
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	78 4a                	js     801025 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fde:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800fe2:	75 21                	jne    801005 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800fe4:	a1 20 60 80 00       	mov    0x806020,%eax
  800fe9:	8b 40 48             	mov    0x48(%eax),%eax
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	53                   	push   %ebx
  800ff0:	50                   	push   %eax
  800ff1:	68 4d 23 80 00       	push   $0x80234d
  800ff6:	e8 4a f2 ff ff       	call   800245 <cprintf>
  800ffb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	eb 20                	jmp    801025 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801005:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801008:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80100c:	75 07                	jne    801015 <write+0x6d>
  80100e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801013:	eb 10                	jmp    801025 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	ff 75 10             	pushl  0x10(%ebp)
  80101b:	ff 75 0c             	pushl  0xc(%ebp)
  80101e:	50                   	push   %eax
  80101f:	ff 52 0c             	call   *0xc(%edx)
  801022:	83 c4 10             	add    $0x10,%esp
}
  801025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	53                   	push   %ebx
  80102e:	83 ec 14             	sub    $0x14,%esp
  801031:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801034:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801037:	50                   	push   %eax
  801038:	53                   	push   %ebx
  801039:	e8 ad fd ff ff       	call   800deb <fd_lookup>
  80103e:	83 c4 08             	add    $0x8,%esp
  801041:	85 c0                	test   %eax,%eax
  801043:	78 67                	js     8010ac <read+0x82>
  801045:	83 ec 08             	sub    $0x8,%esp
  801048:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	ff 30                	pushl  (%eax)
  801051:	e8 05 fe ff ff       	call   800e5b <dev_lookup>
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 4f                	js     8010ac <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801060:	8b 42 08             	mov    0x8(%edx),%eax
  801063:	83 e0 03             	and    $0x3,%eax
  801066:	83 f8 01             	cmp    $0x1,%eax
  801069:	75 21                	jne    80108c <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106b:	a1 20 60 80 00       	mov    0x806020,%eax
  801070:	8b 40 48             	mov    0x48(%eax),%eax
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	53                   	push   %ebx
  801077:	50                   	push   %eax
  801078:	68 6a 23 80 00       	push   $0x80236a
  80107d:	e8 c3 f1 ff ff       	call   800245 <cprintf>
  801082:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	eb 20                	jmp    8010ac <read+0x82>
	}
	if (!dev->dev_read)
  80108c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80108f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  801093:	75 07                	jne    80109c <read+0x72>
  801095:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80109a:	eb 10                	jmp    8010ac <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	ff 75 10             	pushl  0x10(%ebp)
  8010a2:	ff 75 0c             	pushl  0xc(%ebp)
  8010a5:	52                   	push   %edx
  8010a6:	ff 50 08             	call   *0x8(%eax)
  8010a9:	83 c4 10             	add    $0x10,%esp
}
  8010ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010bd:	8b 75 10             	mov    0x10(%ebp),%esi
  8010c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c5:	eb 21                	jmp    8010e8 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	89 f0                	mov    %esi,%eax
  8010cc:	29 d0                	sub    %edx,%eax
  8010ce:	50                   	push   %eax
  8010cf:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8010d2:	50                   	push   %eax
  8010d3:	ff 75 08             	pushl  0x8(%ebp)
  8010d6:	e8 4f ff ff ff       	call   80102a <read>
		if (m < 0)
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 0e                	js     8010f0 <readn+0x3f>
			return m;
		if (m == 0)
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	74 08                	je     8010ee <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e6:	01 c3                	add    %eax,%ebx
  8010e8:	89 da                	mov    %ebx,%edx
  8010ea:	39 f3                	cmp    %esi,%ebx
  8010ec:	72 d9                	jb     8010c7 <readn+0x16>
  8010ee:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 20             	sub    $0x20,%esp
  801100:	8b 75 08             	mov    0x8(%ebp),%esi
  801103:	8a 45 0c             	mov    0xc(%ebp),%al
  801106:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	56                   	push   %esi
  80110e:	e8 5d fc ff ff       	call   800d70 <fd2num>
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	e8 d0 fc ff ff       	call   800deb <fd_lookup>
  80111b:	89 c3                	mov    %eax,%ebx
  80111d:	83 c4 08             	add    $0x8,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 05                	js     801129 <fd_close+0x31>
  801124:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801127:	74 0d                	je     801136 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801129:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80112d:	75 48                	jne    801177 <fd_close+0x7f>
  80112f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801134:	eb 41                	jmp    801177 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801136:	83 ec 08             	sub    $0x8,%esp
  801139:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	ff 36                	pushl  (%esi)
  80113f:	e8 17 fd ff ff       	call   800e5b <dev_lookup>
  801144:	89 c3                	mov    %eax,%ebx
  801146:	83 c4 10             	add    $0x10,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 1c                	js     801169 <fd_close+0x71>
		if (dev->dev_close)
  80114d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801150:	8b 40 10             	mov    0x10(%eax),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	75 07                	jne    80115e <fd_close+0x66>
  801157:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115c:	eb 0b                	jmp    801169 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	56                   	push   %esi
  801162:	ff d0                	call   *%eax
  801164:	89 c3                	mov    %eax,%ebx
  801166:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	56                   	push   %esi
  80116d:	6a 00                	push   $0x0
  80116f:	e8 b5 fa ff ff       	call   800c29 <sys_page_unmap>
  801174:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801177:	89 d8                	mov    %ebx,%eax
  801179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801186:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	ff 75 08             	pushl  0x8(%ebp)
  80118d:	e8 59 fc ff ff       	call   800deb <fd_lookup>
  801192:	83 c4 08             	add    $0x8,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 10                	js     8011a9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	6a 01                	push   $0x1
  80119e:	ff 75 fc             	pushl  -0x4(%ebp)
  8011a1:	e8 52 ff ff ff       	call   8010f8 <fd_close>
  8011a6:	83 c4 10             	add    $0x10,%esp
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	6a 00                	push   $0x0
  8011b5:	ff 75 08             	pushl  0x8(%ebp)
  8011b8:	e8 4a 03 00 00       	call   801507 <open>
  8011bd:	89 c6                	mov    %eax,%esi
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 1b                	js     8011e1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8011c6:	83 ec 08             	sub    $0x8,%esp
  8011c9:	ff 75 0c             	pushl  0xc(%ebp)
  8011cc:	50                   	push   %eax
  8011cd:	e8 e0 fc ff ff       	call   800eb2 <fstat>
  8011d2:	89 c3                	mov    %eax,%ebx
	close(fd);
  8011d4:	89 34 24             	mov    %esi,(%esp)
  8011d7:	e8 a4 ff ff ff       	call   801180 <close>
  8011dc:	89 de                	mov    %ebx,%esi
  8011de:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8011e1:	89 f0                	mov    %esi,%eax
  8011e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
  8011f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 e9 fb ff ff       	call   800deb <fd_lookup>
  801202:	89 c3                	mov    %eax,%ebx
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	0f 88 bd 00 00 00    	js     8012cc <dup+0xe2>
		return r;
	close(newfdnum);
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	57                   	push   %edi
  801213:	e8 68 ff ff ff       	call   801180 <close>

	newfd = INDEX2FD(newfdnum);
  801218:	89 f8                	mov    %edi,%eax
  80121a:	c1 e0 0c             	shl    $0xc,%eax
  80121d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801223:	ff 75 f0             	pushl  -0x10(%ebp)
  801226:	e8 55 fb ff ff       	call   800d80 <fd2data>
  80122b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80122d:	89 34 24             	mov    %esi,(%esp)
  801230:	e8 4b fb ff ff       	call   800d80 <fd2data>
  801235:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	c1 e8 16             	shr    $0x16,%eax
  80123d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801244:	83 c4 14             	add    $0x14,%esp
  801247:	a8 01                	test   $0x1,%al
  801249:	74 36                	je     801281 <dup+0x97>
  80124b:	89 da                	mov    %ebx,%edx
  80124d:	c1 ea 0c             	shr    $0xc,%edx
  801250:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801257:	a8 01                	test   $0x1,%al
  801259:	74 26                	je     801281 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80125b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	25 07 0e 00 00       	and    $0xe07,%eax
  80126a:	50                   	push   %eax
  80126b:	ff 75 e0             	pushl  -0x20(%ebp)
  80126e:	6a 00                	push   $0x0
  801270:	53                   	push   %ebx
  801271:	6a 00                	push   $0x0
  801273:	e8 f3 f9 ff ff       	call   800c6b <sys_page_map>
  801278:	89 c3                	mov    %eax,%ebx
  80127a:	83 c4 20             	add    $0x20,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 30                	js     8012b1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801281:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801284:	89 d0                	mov    %edx,%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
  801289:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801290:	83 ec 0c             	sub    $0xc,%esp
  801293:	25 07 0e 00 00       	and    $0xe07,%eax
  801298:	50                   	push   %eax
  801299:	56                   	push   %esi
  80129a:	6a 00                	push   $0x0
  80129c:	52                   	push   %edx
  80129d:	6a 00                	push   $0x0
  80129f:	e8 c7 f9 ff ff       	call   800c6b <sys_page_map>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 20             	add    $0x20,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 04                	js     8012b1 <dup+0xc7>
		goto err;
  8012ad:	89 fb                	mov    %edi,%ebx
  8012af:	eb 1b                	jmp    8012cc <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	56                   	push   %esi
  8012b5:	6a 00                	push   $0x0
  8012b7:	e8 6d f9 ff ff       	call   800c29 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8012c2:	6a 00                	push   $0x0
  8012c4:	e8 60 f9 ff ff       	call   800c29 <sys_page_unmap>
  8012c9:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 04             	sub    $0x4,%esp
  8012dd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8012e2:	83 ec 0c             	sub    $0xc,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	e8 95 fe ff ff       	call   801180 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012eb:	43                   	inc    %ebx
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	83 fb 20             	cmp    $0x20,%ebx
  8012f2:	75 ee                	jne    8012e2 <close_all+0xc>
		close(i);
}
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    
  8012f9:	00 00                	add    %al,(%eax)
	...

008012fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	89 c3                	mov    %eax,%ebx
  801303:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801305:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130c:	75 12                	jne    801320 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130e:	83 ec 0c             	sub    $0xc,%esp
  801311:	6a 01                	push   $0x1
  801313:	e8 60 08 00 00       	call   801b78 <ipc_find_env>
  801318:	a3 00 40 80 00       	mov    %eax,0x804000
  80131d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801320:	6a 07                	push   $0x7
  801322:	68 00 70 80 00       	push   $0x807000
  801327:	53                   	push   %ebx
  801328:	ff 35 00 40 80 00    	pushl  0x804000
  80132e:	e8 8a 08 00 00       	call   801bbd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801333:	83 c4 0c             	add    $0xc,%esp
  801336:	6a 00                	push   $0x0
  801338:	56                   	push   %esi
  801339:	6a 00                	push   $0x0
  80133b:	e8 d2 08 00 00       	call   801c12 <ipc_recv>
}
  801340:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80134d:	ba 00 00 00 00       	mov    $0x0,%edx
  801352:	b8 08 00 00 00       	mov    $0x8,%eax
  801357:	e8 a0 ff ff ff       	call   8012fc <fsipc>
}
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 40 0c             	mov    0xc(%eax),%eax
  80136a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801377:	ba 00 00 00 00       	mov    $0x0,%edx
  80137c:	b8 02 00 00 00       	mov    $0x2,%eax
  801381:	e8 76 ff ff ff       	call   8012fc <fsipc>
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80138e:	8b 45 08             	mov    0x8(%ebp),%eax
  801391:	8b 40 0c             	mov    0xc(%eax),%eax
  801394:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801399:	ba 00 00 00 00       	mov    $0x0,%edx
  80139e:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a3:	e8 54 ff ff ff       	call   8012fc <fsipc>
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ba:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c9:	e8 2e ff ff ff       	call   8012fc <fsipc>
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 2c                	js     8013fe <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	68 00 70 80 00       	push   $0x807000
  8013da:	53                   	push   %ebx
  8013db:	e8 b7 f3 ff ff       	call   800797 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e0:	a1 80 70 80 00       	mov    0x807080,%eax
  8013e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013eb:	a1 84 70 80 00       	mov    0x807084,%eax
  8013f0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	53                   	push   %ebx
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	8b 40 0c             	mov    0xc(%eax),%eax
  801413:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = n;
  801418:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80141e:	53                   	push   %ebx
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	68 08 70 80 00       	push   $0x807008
  801427:	e8 d8 f4 ff ff       	call   800904 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 04 00 00 00       	mov    $0x4,%eax
  801436:	e8 c1 fe ff ff       	call   8012fc <fsipc>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 3d                	js     80147f <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801442:	39 c3                	cmp    %eax,%ebx
  801444:	73 19                	jae    80145f <devfile_write+0x5c>
  801446:	68 98 23 80 00       	push   $0x802398
  80144b:	68 9f 23 80 00       	push   $0x80239f
  801450:	68 97 00 00 00       	push   $0x97
  801455:	68 b4 23 80 00       	push   $0x8023b4
  80145a:	e8 45 ed ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  80145f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801464:	7e 19                	jle    80147f <devfile_write+0x7c>
  801466:	68 bf 23 80 00       	push   $0x8023bf
  80146b:	68 9f 23 80 00       	push   $0x80239f
  801470:	68 98 00 00 00       	push   $0x98
  801475:	68 b4 23 80 00       	push   $0x8023b4
  80147a:	e8 25 ed ff ff       	call   8001a4 <_panic>
	
	return r;
}
  80147f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80148c:	8b 45 08             	mov    0x8(%ebp),%eax
  80148f:	8b 40 0c             	mov    0xc(%eax),%eax
  801492:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801497:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149d:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a7:	e8 50 fe ff ff       	call   8012fc <fsipc>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 4c                	js     8014fe <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8014b2:	39 de                	cmp    %ebx,%esi
  8014b4:	73 16                	jae    8014cc <devfile_read+0x48>
  8014b6:	68 98 23 80 00       	push   $0x802398
  8014bb:	68 9f 23 80 00       	push   $0x80239f
  8014c0:	6a 7c                	push   $0x7c
  8014c2:	68 b4 23 80 00       	push   $0x8023b4
  8014c7:	e8 d8 ec ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  8014cc:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8014d2:	7e 16                	jle    8014ea <devfile_read+0x66>
  8014d4:	68 bf 23 80 00       	push   $0x8023bf
  8014d9:	68 9f 23 80 00       	push   $0x80239f
  8014de:	6a 7d                	push   $0x7d
  8014e0:	68 b4 23 80 00       	push   $0x8023b4
  8014e5:	e8 ba ec ff ff       	call   8001a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	50                   	push   %eax
  8014ee:	68 00 70 80 00       	push   $0x807000
  8014f3:	ff 75 0c             	pushl  0xc(%ebp)
  8014f6:	e8 09 f4 ff ff       	call   800904 <memmove>
  8014fb:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014fe:	89 d8                	mov    %ebx,%eax
  801500:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801503:	5b                   	pop    %ebx
  801504:	5e                   	pop    %esi
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	83 ec 1c             	sub    $0x1c,%esp
  80150f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801512:	56                   	push   %esi
  801513:	e8 4c f2 ff ff       	call   800764 <strlen>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801520:	7e 07                	jle    801529 <open+0x22>
  801522:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801527:	eb 63                	jmp    80158c <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	e8 63 f8 ff ff       	call   800d98 <fd_alloc>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 4e                	js     80158c <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	56                   	push   %esi
  801542:	68 00 70 80 00       	push   $0x807000
  801547:	e8 4b f2 ff ff       	call   800797 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80154c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154f:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801554:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801557:	b8 01 00 00 00       	mov    $0x1,%eax
  80155c:	e8 9b fd ff ff       	call   8012fc <fsipc>
  801561:	89 c3                	mov    %eax,%ebx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	79 12                	jns    80157c <open+0x75>
		fd_close(fd, 0);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	6a 00                	push   $0x0
  80156f:	ff 75 f4             	pushl  -0xc(%ebp)
  801572:	e8 81 fb ff ff       	call   8010f8 <fd_close>
		return r;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb 10                	jmp    80158c <open+0x85>
	}

	return fd2num(fd);
  80157c:	83 ec 0c             	sub    $0xc,%esp
  80157f:	ff 75 f4             	pushl  -0xc(%ebp)
  801582:	e8 e9 f7 ff ff       	call   800d70 <fd2num>
  801587:	89 c3                	mov    %eax,%ebx
  801589:	83 c4 10             	add    $0x10,%esp
}
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	c9                   	leave  
  801594:	c3                   	ret    
  801595:	00 00                	add    %al,(%eax)
	...

00801598 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8015a1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015a5:	7e 2c                	jle    8015d3 <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	ff 70 04             	pushl  0x4(%eax)
  8015ad:	8d 40 10             	lea    0x10(%eax),%eax
  8015b0:	50                   	push   %eax
  8015b1:	ff 33                	pushl  (%ebx)
  8015b3:	e8 f0 f9 ff ff       	call   800fa8 <write>
		if (result > 0)
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	7e 03                	jle    8015c2 <writebuf+0x2a>
			b->result += result;
  8015bf:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8015c2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8015c5:	74 0c                	je     8015d3 <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	7e 05                	jle    8015d0 <writebuf+0x38>
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8015d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  8015eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015f2:	00 00 00 
	b.result = 0;
  8015f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015fc:	00 00 00 
	b.error = 1;
  8015ff:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  801606:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	ff 75 0c             	pushl  0xc(%ebp)
  80160f:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  801615:	53                   	push   %ebx
  801616:	68 7b 16 80 00       	push   $0x80167b
  80161b:	e8 78 ed ff ff       	call   800398 <vprintfmt>
	if (b.idx > 0)
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  80162a:	7e 07                	jle    801633 <vfprintf+0x5b>
		writebuf(&b);
  80162c:	89 d8                	mov    %ebx,%eax
  80162e:	e8 65 ff ff ff       	call   801598 <writebuf>

	return (b.result ? b.result : b.error);
  801633:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801639:	85 c0                	test   %eax,%eax
  80163b:	75 06                	jne    801643 <vfprintf+0x6b>
  80163d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  801643:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80164e:	8d 45 0c             	lea    0xc(%ebp),%eax
  801651:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  801654:	50                   	push   %eax
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	6a 01                	push   $0x1
  80165a:	e8 79 ff ff ff       	call   8015d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801667:	8d 45 10             	lea    0x10(%ebp),%eax
  80166a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  80166d:	50                   	push   %eax
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 5f ff ff ff       	call   8015d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801685:	8b 43 04             	mov    0x4(%ebx),%eax
  801688:	8b 55 08             	mov    0x8(%ebp),%edx
  80168b:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  80168f:	40                   	inc    %eax
  801690:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801693:	3d 00 01 00 00       	cmp    $0x100,%eax
  801698:	75 0e                	jne    8016a8 <putch+0x2d>
		writebuf(b);
  80169a:	89 d8                	mov    %ebx,%eax
  80169c:	e8 f7 fe ff ff       	call   801598 <writebuf>
		b->idx = 0;
  8016a1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016a8:	83 c4 04             	add    $0x4,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    
	...

008016b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	ff 75 08             	pushl  0x8(%ebp)
  8016be:	e8 bd f6 ff ff       	call   800d80 <fd2data>
  8016c3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016c5:	83 c4 08             	add    $0x8,%esp
  8016c8:	68 cb 23 80 00       	push   $0x8023cb
  8016cd:	53                   	push   %ebx
  8016ce:	e8 c4 f0 ff ff       	call   800797 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d3:	8b 46 04             	mov    0x4(%esi),%eax
  8016d6:	2b 06                	sub    (%esi),%eax
  8016d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e5:	00 00 00 
	stat->st_dev = &devpipe;
  8016e8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ef:	30 80 00 
	return 0;
}
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801708:	53                   	push   %ebx
  801709:	6a 00                	push   $0x0
  80170b:	e8 19 f5 ff ff       	call   800c29 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801710:	89 1c 24             	mov    %ebx,(%esp)
  801713:	e8 68 f6 ff ff       	call   800d80 <fd2data>
  801718:	83 c4 08             	add    $0x8,%esp
  80171b:	50                   	push   %eax
  80171c:	6a 00                	push   $0x0
  80171e:	e8 06 f5 ff ff       	call   800c29 <sys_page_unmap>
}
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	57                   	push   %edi
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801734:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801736:	a1 20 60 80 00       	mov    0x806020,%eax
  80173b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	ff 75 f0             	pushl  -0x10(%ebp)
  801744:	e8 33 05 00 00       	call   801c7c <pageref>
  801749:	89 c3                	mov    %eax,%ebx
  80174b:	89 3c 24             	mov    %edi,(%esp)
  80174e:	e8 29 05 00 00       	call   801c7c <pageref>
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	39 c3                	cmp    %eax,%ebx
  801758:	0f 94 c0             	sete   %al
  80175b:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  80175e:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801764:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801767:	39 c6                	cmp    %eax,%esi
  801769:	74 1b                	je     801786 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  80176b:	83 f9 01             	cmp    $0x1,%ecx
  80176e:	75 c6                	jne    801736 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801770:	8b 42 58             	mov    0x58(%edx),%eax
  801773:	6a 01                	push   $0x1
  801775:	50                   	push   %eax
  801776:	56                   	push   %esi
  801777:	68 d2 23 80 00       	push   $0x8023d2
  80177c:	e8 c4 ea ff ff       	call   800245 <cprintf>
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	eb b0                	jmp    801736 <_pipeisclosed+0xe>
	}
}
  801786:	89 c8                	mov    %ecx,%eax
  801788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	57                   	push   %edi
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 18             	sub    $0x18,%esp
  801799:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80179c:	56                   	push   %esi
  80179d:	e8 de f5 ff ff       	call   800d80 <fd2data>
  8017a2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017aa:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 40                	jmp    8017f4 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b9:	eb 40                	jmp    8017fb <devpipe_write+0x6b>
  8017bb:	89 da                	mov    %ebx,%edx
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	e8 64 ff ff ff       	call   801728 <_pipeisclosed>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	75 ec                	jne    8017b4 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017c8:	e8 23 f5 ff ff       	call   800cf0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017cd:	8b 53 04             	mov    0x4(%ebx),%edx
  8017d0:	8b 03                	mov    (%ebx),%eax
  8017d2:	83 c0 20             	add    $0x20,%eax
  8017d5:	39 c2                	cmp    %eax,%edx
  8017d7:	73 e2                	jae    8017bb <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017d9:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017df:	79 05                	jns    8017e6 <devpipe_write+0x56>
  8017e1:	4a                   	dec    %edx
  8017e2:	83 ca e0             	or     $0xffffffe0,%edx
  8017e5:	42                   	inc    %edx
  8017e6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8017e9:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8017ec:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017f0:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f3:	47                   	inc    %edi
  8017f4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017f7:	75 d4                	jne    8017cd <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017f9:	89 f8                	mov    %edi,%eax
}
  8017fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	c9                   	leave  
  801802:	c3                   	ret    

00801803 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 18             	sub    $0x18,%esp
  80180c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80180f:	57                   	push   %edi
  801810:	e8 6b f5 ff ff       	call   800d80 <fd2data>
  801815:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801817:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80181d:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	eb 41                	jmp    801868 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801827:	89 f0                	mov    %esi,%eax
  801829:	eb 44                	jmp    80186f <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80182b:	b8 00 00 00 00       	mov    $0x0,%eax
  801830:	eb 3d                	jmp    80186f <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801832:	85 f6                	test   %esi,%esi
  801834:	75 f1                	jne    801827 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801836:	89 da                	mov    %ebx,%edx
  801838:	89 f8                	mov    %edi,%eax
  80183a:	e8 e9 fe ff ff       	call   801728 <_pipeisclosed>
  80183f:	85 c0                	test   %eax,%eax
  801841:	75 e8                	jne    80182b <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801843:	e8 a8 f4 ff ff       	call   800cf0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801848:	8b 03                	mov    (%ebx),%eax
  80184a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80184d:	74 e3                	je     801832 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80184f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801854:	79 05                	jns    80185b <devpipe_read+0x58>
  801856:	48                   	dec    %eax
  801857:	83 c8 e0             	or     $0xffffffe0,%eax
  80185a:	40                   	inc    %eax
  80185b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80185f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801862:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801865:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801867:	46                   	inc    %esi
  801868:	3b 75 10             	cmp    0x10(%ebp),%esi
  80186b:	75 db                	jne    801848 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80186d:	89 f0                	mov    %esi,%eax
}
  80186f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801872:	5b                   	pop    %ebx
  801873:	5e                   	pop    %esi
  801874:	5f                   	pop    %edi
  801875:	c9                   	leave  
  801876:	c3                   	ret    

00801877 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	ff 75 08             	pushl  0x8(%ebp)
  801884:	e8 62 f5 ff ff       	call   800deb <fd_lookup>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 18                	js     8018a8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 fc             	pushl  -0x4(%ebp)
  801896:	e8 e5 f4 ff ff       	call   800d80 <fd2data>
  80189b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80189d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018a0:	e8 83 fe ff ff       	call   801728 <_pipeisclosed>
  8018a5:	83 c4 10             	add    $0x10,%esp
}
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	57                   	push   %edi
  8018ae:	56                   	push   %esi
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 28             	sub    $0x28,%esp
  8018b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	e8 d9 f4 ff ff       	call   800d98 <fd_alloc>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	0f 88 24 01 00 00    	js     8019f0 <pipe+0x146>
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	68 07 04 00 00       	push   $0x407
  8018d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 cf f3 ff ff       	call   800cad <sys_page_alloc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	0f 88 05 01 00 00    	js     8019f0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018eb:	83 ec 0c             	sub    $0xc,%esp
  8018ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	e8 a1 f4 ff ff       	call   800d98 <fd_alloc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	0f 88 dc 00 00 00    	js     8019e0 <pipe+0x136>
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	68 07 04 00 00       	push   $0x407
  80190c:	ff 75 ec             	pushl  -0x14(%ebp)
  80190f:	6a 00                	push   $0x0
  801911:	e8 97 f3 ff ff       	call   800cad <sys_page_alloc>
  801916:	89 c3                	mov    %eax,%ebx
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	0f 88 bd 00 00 00    	js     8019e0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f0             	pushl  -0x10(%ebp)
  801929:	e8 52 f4 ff ff       	call   800d80 <fd2data>
  80192e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801930:	83 c4 0c             	add    $0xc,%esp
  801933:	68 07 04 00 00       	push   $0x407
  801938:	50                   	push   %eax
  801939:	6a 00                	push   $0x0
  80193b:	e8 6d f3 ff ff       	call   800cad <sys_page_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	85 c0                	test   %eax,%eax
  801947:	0f 88 83 00 00 00    	js     8019d0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	ff 75 ec             	pushl  -0x14(%ebp)
  801953:	e8 28 f4 ff ff       	call   800d80 <fd2data>
  801958:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80195f:	50                   	push   %eax
  801960:	6a 00                	push   $0x0
  801962:	56                   	push   %esi
  801963:	6a 00                	push   $0x0
  801965:	e8 01 f3 ff ff       	call   800c6b <sys_page_map>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 20             	add    $0x20,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	78 4f                	js     8019c2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801973:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80197e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801981:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801988:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801991:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801993:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801996:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019a3:	e8 c8 f3 ff ff       	call   800d70 <fd2num>
  8019a8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019aa:	83 c4 04             	add    $0x4,%esp
  8019ad:	ff 75 ec             	pushl  -0x14(%ebp)
  8019b0:	e8 bb f3 ff ff       	call   800d70 <fd2num>
  8019b5:	89 47 04             	mov    %eax,0x4(%edi)
  8019b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	eb 2e                	jmp    8019f0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	56                   	push   %esi
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 5c f2 ff ff       	call   800c29 <sys_page_unmap>
  8019cd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	ff 75 ec             	pushl  -0x14(%ebp)
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 4c f2 ff ff       	call   800c29 <sys_page_unmap>
  8019dd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e6:	6a 00                	push   $0x0
  8019e8:	e8 3c f2 ff ff       	call   800c29 <sys_page_unmap>
  8019ed:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    
	...

008019fc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a0c:	68 ea 23 80 00       	push   $0x8023ea
  801a11:	ff 75 0c             	pushl  0xc(%ebp)
  801a14:	e8 7e ed ff ff       	call   800797 <strcpy>
	return 0;
}
  801a19:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	57                   	push   %edi
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801a2c:	be 00 00 00 00       	mov    $0x0,%esi
  801a31:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801a37:	eb 2c                	jmp    801a65 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a3c:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a3e:	83 fb 7f             	cmp    $0x7f,%ebx
  801a41:	76 05                	jbe    801a48 <devcons_write+0x28>
  801a43:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	03 45 0c             	add    0xc(%ebp),%eax
  801a4f:	50                   	push   %eax
  801a50:	57                   	push   %edi
  801a51:	e8 ae ee ff ff       	call   800904 <memmove>
		sys_cputs(buf, m);
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	53                   	push   %ebx
  801a5a:	57                   	push   %edi
  801a5b:	e8 7b f0 ff ff       	call   800adb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a60:	01 de                	add    %ebx,%esi
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	89 f0                	mov    %esi,%eax
  801a67:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a6a:	72 cd                	jb     801a39 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a80:	6a 01                	push   $0x1
  801a82:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	e8 50 f0 ff ff       	call   800adb <sys_cputs>
  801a8b:	83 c4 10             	add    $0x10,%esp
}
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a9a:	74 27                	je     801ac3 <devcons_read+0x33>
  801a9c:	eb 05                	jmp    801aa3 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a9e:	e8 4d f2 ff ff       	call   800cf0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801aa3:	e8 14 f0 ff ff       	call   800abc <sys_cgetc>
  801aa8:	89 c2                	mov    %eax,%edx
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	74 f0                	je     801a9e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 16                	js     801ac8 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ab2:	83 f8 04             	cmp    $0x4,%eax
  801ab5:	74 0c                	je     801ac3 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aba:	88 10                	mov    %dl,(%eax)
  801abc:	ba 01 00 00 00       	mov    $0x1,%edx
  801ac1:	eb 05                	jmp    801ac8 <devcons_read+0x38>
	return 1;
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ac8:	89 d0                	mov    %edx,%eax
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ad5:	50                   	push   %eax
  801ad6:	e8 bd f2 ff ff       	call   800d98 <fd_alloc>
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 3b                	js     801b1d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 07 04 00 00       	push   $0x407
  801aea:	ff 75 fc             	pushl  -0x4(%ebp)
  801aed:	6a 00                	push   $0x0
  801aef:	e8 b9 f1 ff ff       	call   800cad <sys_page_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 22                	js     801b1d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801afb:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801b00:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801b03:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b08:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	ff 75 fc             	pushl  -0x4(%ebp)
  801b15:	e8 56 f2 ff ff       	call   800d70 <fd2num>
  801b1a:	83 c4 10             	add    $0x10,%esp
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b25:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b28:	50                   	push   %eax
  801b29:	ff 75 08             	pushl  0x8(%ebp)
  801b2c:	e8 ba f2 ff ff       	call   800deb <fd_lookup>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 11                	js     801b49 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b38:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b3b:	8b 00                	mov    (%eax),%eax
  801b3d:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801b43:	0f 94 c0             	sete   %al
  801b46:	0f b6 c0             	movzbl %al,%eax
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b51:	6a 01                	push   $0x1
  801b53:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	6a 00                	push   $0x0
  801b59:	e8 cc f4 ff ff       	call   80102a <read>
	if (r < 0)
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 0f                	js     801b74 <getchar+0x29>
		return r;
	if (r < 1)
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 07                	jne    801b70 <getchar+0x25>
  801b69:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b6e:	eb 04                	jmp    801b74 <getchar+0x29>
		return -E_EOF;
	return c;
  801b70:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    
	...

00801b78 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	53                   	push   %ebx
  801b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b84:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801b8b:	89 c8                	mov    %ecx,%eax
  801b8d:	c1 e0 07             	shl    $0x7,%eax
  801b90:	29 d0                	sub    %edx,%eax
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801b9a:	8b 40 50             	mov    0x50(%eax),%eax
  801b9d:	39 d8                	cmp    %ebx,%eax
  801b9f:	75 0b                	jne    801bac <ipc_find_env+0x34>
			return envs[i].env_id;
  801ba1:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801ba7:	8b 40 40             	mov    0x40(%eax),%eax
  801baa:	eb 0e                	jmp    801bba <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bac:	41                   	inc    %ecx
  801bad:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801bb3:	75 cf                	jne    801b84 <ipc_find_env+0xc>
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801bba:	5b                   	pop    %ebx
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801bcf:	85 db                	test   %ebx,%ebx
  801bd1:	75 05                	jne    801bd8 <ipc_send+0x1b>
  801bd3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bd8:	56                   	push   %esi
  801bd9:	53                   	push   %ebx
  801bda:	57                   	push   %edi
  801bdb:	ff 75 08             	pushl  0x8(%ebp)
  801bde:	e8 5d ef ff ff       	call   800b40 <sys_ipc_try_send>
		if (r == 0) {		//success
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	85 c0                	test   %eax,%eax
  801be8:	74 20                	je     801c0a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801bea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bed:	75 07                	jne    801bf6 <ipc_send+0x39>
			sys_yield();
  801bef:	e8 fc f0 ff ff       	call   800cf0 <sys_yield>
  801bf4:	eb e2                	jmp    801bd8 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801bf6:	83 ec 04             	sub    $0x4,%esp
  801bf9:	68 f8 23 80 00       	push   $0x8023f8
  801bfe:	6a 41                	push   $0x41
  801c00:	68 1c 24 80 00       	push   $0x80241c
  801c05:	e8 9a e5 ff ff       	call   8001a4 <_panic>
		}
	}
}
  801c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	c9                   	leave  
  801c11:	c3                   	ret    

00801c12 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c20:	85 c0                	test   %eax,%eax
  801c22:	75 05                	jne    801c29 <ipc_recv+0x17>
  801c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	50                   	push   %eax
  801c2d:	e8 cd ee ff ff       	call   800aff <sys_ipc_recv>
	if (r < 0) {				
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	79 16                	jns    801c4f <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801c39:	85 db                	test   %ebx,%ebx
  801c3b:	74 06                	je     801c43 <ipc_recv+0x31>
  801c3d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801c43:	85 f6                	test   %esi,%esi
  801c45:	74 2c                	je     801c73 <ipc_recv+0x61>
  801c47:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c4d:	eb 24                	jmp    801c73 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801c4f:	85 db                	test   %ebx,%ebx
  801c51:	74 0a                	je     801c5d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c53:	a1 20 60 80 00       	mov    0x806020,%eax
  801c58:	8b 40 74             	mov    0x74(%eax),%eax
  801c5b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801c5d:	85 f6                	test   %esi,%esi
  801c5f:	74 0a                	je     801c6b <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801c61:	a1 20 60 80 00       	mov    0x806020,%eax
  801c66:	8b 40 78             	mov    0x78(%eax),%eax
  801c69:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801c6b:	a1 20 60 80 00       	mov    0x806020,%eax
  801c70:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    
	...

00801c7c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c82:	89 d0                	mov    %edx,%eax
  801c84:	c1 e8 16             	shr    $0x16,%eax
  801c87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c8e:	a8 01                	test   $0x1,%al
  801c90:	74 20                	je     801cb2 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c92:	89 d0                	mov    %edx,%eax
  801c94:	c1 e8 0c             	shr    $0xc,%eax
  801c97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c9e:	a8 01                	test   $0x1,%al
  801ca0:	74 10                	je     801cb2 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca2:	c1 e8 0c             	shr    $0xc,%eax
  801ca5:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cac:	ef 
  801cad:	0f b7 c0             	movzwl %ax,%eax
  801cb0:	eb 05                	jmp    801cb7 <pageref+0x3b>
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    
  801cb9:	00 00                	add    %al,(%eax)
	...

00801cbc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	57                   	push   %edi
  801cc0:	56                   	push   %esi
  801cc1:	83 ec 28             	sub    $0x28,%esp
  801cc4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801ccb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd5:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cdb:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801cdd:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce8:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ceb:	85 ff                	test   %edi,%edi
  801ced:	75 21                	jne    801d10 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801cef:	39 d1                	cmp    %edx,%ecx
  801cf1:	76 49                	jbe    801d3c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cf3:	f7 f1                	div    %ecx
  801cf5:	89 c1                	mov    %eax,%ecx
  801cf7:	31 c0                	xor    %eax,%eax
  801cf9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cfc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801cff:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d02:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d05:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d08:	83 c4 28             	add    $0x28,%esp
  801d0b:	5e                   	pop    %esi
  801d0c:	5f                   	pop    %edi
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    
  801d0f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d10:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801d13:	0f 87 97 00 00 00    	ja     801db0 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d19:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d1c:	83 f0 1f             	xor    $0x1f,%eax
  801d1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d22:	75 34                	jne    801d58 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d24:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801d27:	72 08                	jb     801d31 <__udivdi3+0x75>
  801d29:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801d2c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801d2f:	77 7f                	ja     801db0 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d31:	b9 01 00 00 00       	mov    $0x1,%ecx
  801d36:	31 c0                	xor    %eax,%eax
  801d38:	eb c2                	jmp    801cfc <__udivdi3+0x40>
  801d3a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	74 79                	je     801dbc <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d46:	89 fa                	mov    %edi,%edx
  801d48:	f7 f1                	div    %ecx
  801d4a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d4f:	f7 f1                	div    %ecx
  801d51:	89 c1                	mov    %eax,%ecx
  801d53:	89 f0                	mov    %esi,%eax
  801d55:	eb a5                	jmp    801cfc <__udivdi3+0x40>
  801d57:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d58:	b8 20 00 00 00       	mov    $0x20,%eax
  801d5d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801d60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d63:	89 fa                	mov    %edi,%edx
  801d65:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801d68:	d3 e2                	shl    %cl,%edx
  801d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801d70:	d3 e8                	shr    %cl,%eax
  801d72:	89 d7                	mov    %edx,%edi
  801d74:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d76:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801d79:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801d7c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d81:	d3 e0                	shl    %cl,%eax
  801d83:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801d86:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801d89:	d3 ea                	shr    %cl,%edx
  801d8b:	09 d0                	or     %edx,%eax
  801d8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d90:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d93:	d3 ea                	shr    %cl,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 d7                	mov    %edx,%edi
  801d99:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801d9c:	f7 e6                	mul    %esi
  801d9e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da0:	39 d7                	cmp    %edx,%edi
  801da2:	72 38                	jb     801ddc <__udivdi3+0x120>
  801da4:	74 27                	je     801dcd <__udivdi3+0x111>
  801da6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801da9:	31 c0                	xor    %eax,%eax
  801dab:	e9 4c ff ff ff       	jmp    801cfc <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801db0:	31 c9                	xor    %ecx,%ecx
  801db2:	31 c0                	xor    %eax,%eax
  801db4:	e9 43 ff ff ff       	jmp    801cfc <__udivdi3+0x40>
  801db9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc1:	31 d2                	xor    %edx,%edx
  801dc3:	f7 75 f4             	divl   -0xc(%ebp)
  801dc6:	89 c1                	mov    %eax,%ecx
  801dc8:	e9 76 ff ff ff       	jmp    801d43 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dd0:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801dd3:	d3 e0                	shl    %cl,%eax
  801dd5:	39 f0                	cmp    %esi,%eax
  801dd7:	73 cd                	jae    801da6 <__udivdi3+0xea>
  801dd9:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ddc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801ddf:	49                   	dec    %ecx
  801de0:	31 c0                	xor    %eax,%eax
  801de2:	e9 15 ff ff ff       	jmp    801cfc <__udivdi3+0x40>
	...

00801de8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	83 ec 30             	sub    $0x30,%esp
  801df0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801df7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801dfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801e01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e04:	8b 45 10             	mov    0x10(%ebp),%eax
  801e07:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801e0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e0d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801e0f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801e12:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801e15:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e18:	85 d2                	test   %edx,%edx
  801e1a:	75 1c                	jne    801e38 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801e1c:	89 fa                	mov    %edi,%edx
  801e1e:	39 f8                	cmp    %edi,%eax
  801e20:	0f 86 c2 00 00 00    	jbe    801ee8 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e26:	89 f0                	mov    %esi,%eax
  801e28:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801e2a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801e2d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e34:	eb 12                	jmp    801e48 <__umoddi3+0x60>
  801e36:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e38:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e3b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801e3e:	76 18                	jbe    801e58 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801e40:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801e43:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e46:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e48:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e4b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801e4e:	83 c4 30             	add    $0x30,%esp
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e58:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801e5c:	83 f0 1f             	xor    $0x1f,%eax
  801e5f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801e62:	0f 84 ac 00 00 00    	je     801f14 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e68:	b8 20 00 00 00       	mov    $0x20,%eax
  801e6d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801e70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e73:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e76:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801e79:	d3 e2                	shl    %cl,%edx
  801e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e7e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e81:	d3 e8                	shr    %cl,%eax
  801e83:	89 d6                	mov    %edx,%esi
  801e85:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  801e87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e8a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801e8d:	d3 e0                	shl    %cl,%eax
  801e8f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e92:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801e95:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e9a:	d3 e0                	shl    %cl,%eax
  801e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e9f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801ea2:	d3 ea                	shr    %cl,%edx
  801ea4:	09 d0                	or     %edx,%eax
  801ea6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801ea9:	d3 ea                	shr    %cl,%edx
  801eab:	f7 f6                	div    %esi
  801ead:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801eb0:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eb3:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801eb6:	0f 82 8d 00 00 00    	jb     801f49 <__umoddi3+0x161>
  801ebc:	0f 84 91 00 00 00    	je     801f53 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801ec2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ec5:	29 c7                	sub    %eax,%edi
  801ec7:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ec9:	89 f2                	mov    %esi,%edx
  801ecb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801ece:	d3 e2                	shl    %cl,%edx
  801ed0:	89 f8                	mov    %edi,%eax
  801ed2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801ed5:	d3 e8                	shr    %cl,%eax
  801ed7:	09 c2                	or     %eax,%edx
  801ed9:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801edc:	d3 ee                	shr    %cl,%esi
  801ede:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801ee1:	e9 62 ff ff ff       	jmp    801e48 <__umoddi3+0x60>
  801ee6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	74 15                	je     801f04 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801eef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801ef5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efa:	f7 f1                	div    %ecx
  801efc:	e9 29 ff ff ff       	jmp    801e2a <__umoddi3+0x42>
  801f01:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f04:	b8 01 00 00 00       	mov    $0x1,%eax
  801f09:	31 d2                	xor    %edx,%edx
  801f0b:	f7 75 ec             	divl   -0x14(%ebp)
  801f0e:	89 c1                	mov    %eax,%ecx
  801f10:	eb dd                	jmp    801eef <__umoddi3+0x107>
  801f12:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f17:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801f1a:	72 19                	jb     801f35 <__umoddi3+0x14d>
  801f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f1f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801f22:	76 11                	jbe    801f35 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801f24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f27:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801f2a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f2d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801f30:	e9 13 ff ff ff       	jmp    801e48 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f35:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801f3e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801f41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801f44:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801f47:	eb db                	jmp    801f24 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f49:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801f4c:	19 f2                	sbb    %esi,%edx
  801f4e:	e9 6f ff ff ff       	jmp    801ec2 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f53:	39 c7                	cmp    %eax,%edi
  801f55:	72 f2                	jb     801f49 <__umoddi3+0x161>
  801f57:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f5a:	e9 63 ff ff ff       	jmp    801ec2 <__umoddi3+0xda>
