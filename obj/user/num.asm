
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 4f 01 00 00       	call   800180 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800043:	8d 5d f3             	lea    -0xd(%ebp),%ebx
  800046:	eb 6a                	jmp    8000b2 <num+0x7e>
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 26                	je     800077 <num+0x43>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	68 a0 1f 80 00       	push   $0x801fa0
  800065:	e8 1e 16 00 00       	call   801688 <printf>
			bol = 0;
  80006a:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800071:	00 00 00 
  800074:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800077:	83 ec 04             	sub    $0x4,%esp
  80007a:	6a 01                	push   $0x1
  80007c:	53                   	push   %ebx
  80007d:	6a 01                	push   $0x1
  80007f:	e8 64 0f 00 00       	call   800fe8 <write>
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	83 f8 01             	cmp    $0x1,%eax
  80008a:	74 16                	je     8000a2 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	57                   	push   %edi
  800091:	68 a5 1f 80 00       	push   $0x801fa5
  800096:	6a 13                	push   $0x13
  800098:	68 c0 1f 80 00       	push   $0x801fc0
  80009d:	e8 42 01 00 00       	call   8001e4 <_panic>
		if (c == '\n')
  8000a2:	80 7d f3 0a          	cmpb   $0xa,-0xd(%ebp)
  8000a6:	75 0a                	jne    8000b2 <num+0x7e>
			bol = 1;
  8000a8:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000af:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	6a 01                	push   $0x1
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	e8 ac 0f 00 00       	call   80106a <read>
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	7f 83                	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	79 16                	jns    8000df <num+0xab>
		panic("error reading %s: %e", s, n);
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	50                   	push   %eax
  8000cd:	57                   	push   %edi
  8000ce:	68 cb 1f 80 00       	push   $0x801fcb
  8000d3:	6a 18                	push   $0x18
  8000d5:	68 c0 1f 80 00       	push   $0x801fc0
  8000da:	e8 05 01 00 00       	call   8001e4 <_panic>
}
  8000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <umain>:

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	int f, i;

	binaryname = "num";
  8000f0:	c7 05 04 30 80 00 e0 	movl   $0x801fe0,0x803004
  8000f7:	1f 80 00 
	if (argc == 1)
  8000fa:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000fe:	74 0d                	je     80010d <umain+0x26>
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
  800103:	83 c6 04             	add    $0x4,%esi
  800106:	bf 01 00 00 00       	mov    $0x1,%edi
  80010b:	eb 61                	jmp    80016e <umain+0x87>
		num(0, "<stdin>");
  80010d:	83 ec 08             	sub    $0x8,%esp
  800110:	68 e4 1f 80 00       	push   $0x801fe4
  800115:	6a 00                	push   $0x0
  800117:	e8 18 ff ff ff       	call   800034 <num>
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	eb 52                	jmp    800173 <umain+0x8c>
  800121:	89 75 f0             	mov    %esi,-0x10(%ebp)
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	6a 00                	push   $0x0
  800129:	ff 36                	pushl  (%esi)
  80012b:	e8 17 14 00 00       	call   801547 <open>
  800130:	89 c3                	mov    %eax,%ebx
  800132:	83 c6 04             	add    $0x4,%esi
			if (f < 0)
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	85 c0                	test   %eax,%eax
  80013a:	79 1a                	jns    800156 <umain+0x6f>
				panic("can't open %s: %e", argv[i], f);
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	50                   	push   %eax
  800140:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800143:	ff 30                	pushl  (%eax)
  800145:	68 ec 1f 80 00       	push   $0x801fec
  80014a:	6a 27                	push   $0x27
  80014c:	68 c0 1f 80 00       	push   $0x801fc0
  800151:	e8 8e 00 00 00       	call   8001e4 <_panic>
			else {
				num(f, argv[i]);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	ff 76 fc             	pushl  -0x4(%esi)
  80015c:	50                   	push   %eax
  80015d:	e8 d2 fe ff ff       	call   800034 <num>
				close(f);
  800162:	89 1c 24             	mov    %ebx,(%esp)
  800165:	e8 56 10 00 00       	call   8011c0 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	47                   	inc    %edi
  80016b:	83 c4 10             	add    $0x10,%esp
  80016e:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800171:	7c ae                	jl     800121 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800173:	e8 58 00 00 00       	call   8001d0 <exit>
}
  800178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	8b 75 08             	mov    0x8(%ebp),%esi
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80018b:	e8 bf 0b 00 00       	call   800d4f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800190:	25 ff 03 00 00       	and    $0x3ff,%eax
  800195:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80019c:	c1 e0 07             	shl    $0x7,%eax
  80019f:	29 d0                	sub    %edx,%eax
  8001a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a6:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ab:	85 f6                	test   %esi,%esi
  8001ad:	7e 07                	jle    8001b6 <libmain+0x36>
		binaryname = argv[0];
  8001af:	8b 03                	mov    (%ebx),%eax
  8001b1:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	53                   	push   %ebx
  8001ba:	56                   	push   %esi
  8001bb:	e8 27 ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  8001c0:	e8 0b 00 00 00       	call   8001d0 <exit>
  8001c5:	83 c4 10             	add    $0x10,%esp
}
  8001c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    
	...

008001d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8001d6:	6a 00                	push   $0x0
  8001d8:	e8 91 0b 00 00       	call   800d6e <sys_env_destroy>
  8001dd:	83 c4 10             	add    $0x10,%esp
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    
	...

008001e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8001eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8001ee:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f1:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8001f7:	e8 53 0b 00 00       	call   800d4f <sys_getenvid>
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	53                   	push   %ebx
  800206:	50                   	push   %eax
  800207:	68 08 20 80 00       	push   $0x802008
  80020c:	e8 74 00 00 00       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	ff 75 f8             	pushl  -0x8(%ebp)
  800217:	ff 75 10             	pushl  0x10(%ebp)
  80021a:	e8 15 00 00 00       	call   800234 <vcprintf>
	cprintf("\n");
  80021f:	c7 04 24 23 24 80 00 	movl   $0x802423,(%esp)
  800226:	e8 5a 00 00 00       	call   800285 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022e:	cc                   	int3   
  80022f:	eb fd                	jmp    80022e <_panic+0x4a>
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800244:	00 00 00 
	b.cnt = 0;
  800247:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80024e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	68 9c 02 80 00       	push   $0x80029c
  800263:	e8 70 01 00 00       	call   8003d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800268:	83 c4 08             	add    $0x8,%esp
  80026b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800271:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800277:	50                   	push   %eax
  800278:	e8 9e 08 00 00       	call   800b1b <sys_cputs>
  80027d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80028e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 9a ff ff ff       	call   800234 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 04             	sub    $0x4,%esp
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a6:	8b 03                	mov    (%ebx),%eax
  8002a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002af:	40                   	inc    %eax
  8002b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b7:	75 1a                	jne    8002d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	68 ff 00 00 00       	push   $0xff
  8002c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c4:	50                   	push   %eax
  8002c5:	e8 51 08 00 00       	call   800b1b <sys_cputs>
		b->idx = 0;
  8002ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002d3:	ff 43 04             	incl   0x4(%ebx)
}
  8002d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d9:	c9                   	leave  
  8002da:	c3                   	ret    
	...

008002dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 1c             	sub    $0x1c,%esp
  8002e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002e8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fd:	89 d6                	mov    %edx,%esi
  8002ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800304:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800307:	72 04                	jb     80030d <printnum+0x31>
  800309:	39 c2                	cmp    %eax,%edx
  80030b:	77 3f                	ja     80034c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	ff 75 18             	pushl  0x18(%ebp)
  800313:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800316:	50                   	push   %eax
  800317:	52                   	push   %edx
  800318:	83 ec 08             	sub    $0x8,%esp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800320:	ff 75 e0             	pushl  -0x20(%ebp)
  800323:	e8 d4 19 00 00       	call   801cfc <__udivdi3>
  800328:	83 c4 18             	add    $0x18,%esp
  80032b:	52                   	push   %edx
  80032c:	50                   	push   %eax
  80032d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800330:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800333:	e8 a4 ff ff ff       	call   8002dc <printnum>
  800338:	83 c4 20             	add    $0x20,%esp
  80033b:	eb 14                	jmp    800351 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	ff 75 e8             	pushl  -0x18(%ebp)
  800343:	ff 75 18             	pushl  0x18(%ebp)
  800346:	ff 55 ec             	call   *-0x14(%ebp)
  800349:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034c:	4b                   	dec    %ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f ec                	jg     80033d <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	ff 75 e8             	pushl  -0x18(%ebp)
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035f:	ff 75 e0             	pushl  -0x20(%ebp)
  800362:	e8 c1 1a 00 00       	call   801e28 <__umoddi3>
  800367:	83 c4 14             	add    $0x14,%esp
  80036a:	0f be 80 2b 20 80 00 	movsbl 0x80202b(%eax),%eax
  800371:	50                   	push   %eax
  800372:	ff 55 ec             	call   *-0x14(%ebp)
  800375:	83 c4 10             	add    $0x10,%esp
}
  800378:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800385:	83 fa 01             	cmp    $0x1,%edx
  800388:	7e 0e                	jle    800398 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 42 08             	lea    0x8(%edx),%eax
  80038f:	89 01                	mov    %eax,(%ecx)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	8b 52 04             	mov    0x4(%edx),%edx
  800396:	eb 22                	jmp    8003ba <getuint+0x3a>
	else if (lflag)
  800398:	85 d2                	test   %edx,%edx
  80039a:	74 10                	je     8003ac <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80039c:	8b 10                	mov    (%eax),%edx
  80039e:	8d 42 04             	lea    0x4(%edx),%eax
  8003a1:	89 01                	mov    %eax,(%ecx)
  8003a3:	8b 02                	mov    (%edx),%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	eb 0e                	jmp    8003ba <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	8d 42 04             	lea    0x4(%edx),%eax
  8003b1:	89 01                	mov    %eax,(%ecx)
  8003b3:	8b 02                	mov    (%edx),%eax
  8003b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8003c2:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8003c5:	8b 11                	mov    (%ecx),%edx
  8003c7:	3b 51 04             	cmp    0x4(%ecx),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	88 02                	mov    %al,(%edx)
  8003d1:	8d 42 01             	lea    0x1(%edx),%eax
  8003d4:	89 01                	mov    %eax,(%ecx)
}
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
  8003de:	83 ec 3c             	sub    $0x3c,%esp
  8003e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ea:	eb 1a                	jmp    800406 <vprintfmt+0x2e>
  8003ec:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8003ef:	eb 15                	jmp    800406 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f1:	84 c0                	test   %al,%al
  8003f3:	0f 84 15 03 00 00    	je     80070e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	57                   	push   %edi
  8003fd:	0f b6 c0             	movzbl %al,%eax
  800400:	50                   	push   %eax
  800401:	ff d6                	call   *%esi
  800403:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800406:	8a 03                	mov    (%ebx),%al
  800408:	43                   	inc    %ebx
  800409:	3c 25                	cmp    $0x25,%al
  80040b:	75 e4                	jne    8003f1 <vprintfmt+0x19>
  80040d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80041b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800422:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800429:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80042d:	eb 0a                	jmp    800439 <vprintfmt+0x61>
  80042f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800436:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8a 03                	mov    (%ebx),%al
  80043b:	0f b6 d0             	movzbl %al,%edx
  80043e:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800441:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800444:	83 e8 23             	sub    $0x23,%eax
  800447:	3c 55                	cmp    $0x55,%al
  800449:	0f 87 9c 02 00 00    	ja     8006eb <vprintfmt+0x313>
  80044f:	0f b6 c0             	movzbl %al,%eax
  800452:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  800459:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80045d:	eb d7                	jmp    800436 <vprintfmt+0x5e>
  80045f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800463:	eb d1                	jmp    800436 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800465:	89 d9                	mov    %ebx,%ecx
  800467:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800471:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800474:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800478:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80047b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80047f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800480:	8d 42 d0             	lea    -0x30(%edx),%eax
  800483:	83 f8 09             	cmp    $0x9,%eax
  800486:	77 21                	ja     8004a9 <vprintfmt+0xd1>
  800488:	eb e4                	jmp    80046e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048a:	8b 55 14             	mov    0x14(%ebp),%edx
  80048d:	8d 42 04             	lea    0x4(%edx),%eax
  800490:	89 45 14             	mov    %eax,0x14(%ebp)
  800493:	8b 12                	mov    (%edx),%edx
  800495:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800498:	eb 12                	jmp    8004ac <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80049a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049e:	79 96                	jns    800436 <vprintfmt+0x5e>
  8004a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004a7:	eb 8d                	jmp    800436 <vprintfmt+0x5e>
  8004a9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	79 84                	jns    800436 <vprintfmt+0x5e>
  8004b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004bf:	e9 72 ff ff ff       	jmp    800436 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c4:	ff 45 d4             	incl   -0x2c(%ebp)
  8004c7:	e9 6a ff ff ff       	jmp    800436 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cc:	8b 55 14             	mov    0x14(%ebp),%edx
  8004cf:	8d 42 04             	lea    0x4(%edx),%eax
  8004d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	57                   	push   %edi
  8004d9:	ff 32                	pushl  (%edx)
  8004db:	ff d6                	call   *%esi
			break;
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	e9 07 ff ff ff       	jmp    8003ec <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 55 14             	mov    0x14(%ebp),%edx
  8004e8:	8d 42 04             	lea    0x4(%edx),%eax
  8004eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	79 02                	jns    8004f6 <vprintfmt+0x11e>
  8004f4:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f6:	83 f8 0f             	cmp    $0xf,%eax
  8004f9:	7f 0b                	jg     800506 <vprintfmt+0x12e>
  8004fb:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  800502:	85 d2                	test   %edx,%edx
  800504:	75 15                	jne    80051b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800506:	50                   	push   %eax
  800507:	68 3c 20 80 00       	push   $0x80203c
  80050c:	57                   	push   %edi
  80050d:	56                   	push   %esi
  80050e:	e8 6e 02 00 00       	call   800781 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	e9 d1 fe ff ff       	jmp    8003ec <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	68 f1 23 80 00       	push   $0x8023f1
  800521:	57                   	push   %edi
  800522:	56                   	push   %esi
  800523:	e8 59 02 00 00       	call   800781 <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	e9 bc fe ff ff       	jmp    8003ec <vprintfmt+0x14>
  800530:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800533:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800536:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 55 14             	mov    0x14(%ebp),%edx
  80053c:	8d 42 04             	lea    0x4(%edx),%eax
  80053f:	89 45 14             	mov    %eax,0x14(%ebp)
  800542:	8b 1a                	mov    (%edx),%ebx
  800544:	85 db                	test   %ebx,%ebx
  800546:	75 05                	jne    80054d <vprintfmt+0x175>
  800548:	bb 45 20 80 00       	mov    $0x802045,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800551:	7e 66                	jle    8005b9 <vprintfmt+0x1e1>
  800553:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800557:	74 60                	je     8005b9 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	51                   	push   %ecx
  80055d:	53                   	push   %ebx
  80055e:	e8 57 02 00 00       	call   8007ba <strnlen>
  800563:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800572:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800575:	eb 0f                	jmp    800586 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	57                   	push   %edi
  80057b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80057e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800580:	ff 4d d8             	decl   -0x28(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058a:	7f eb                	jg     800577 <vprintfmt+0x19f>
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	74 15                	je     8005ac <vprintfmt+0x1d4>
  800597:	8d 42 e0             	lea    -0x20(%edx),%eax
  80059a:	83 f8 5e             	cmp    $0x5e,%eax
  80059d:	76 0d                	jbe    8005ac <vprintfmt+0x1d4>
					putch('?', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	57                   	push   %edi
  8005a3:	6a 3f                	push   $0x3f
  8005a5:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	57                   	push   %edi
  8005b0:	52                   	push   %edx
  8005b1:	ff d6                	call   *%esi
  8005b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d d8             	decl   -0x28(%ebp)
  8005b9:	8a 03                	mov    (%ebx),%al
  8005bb:	43                   	inc    %ebx
  8005bc:	84 c0                	test   %al,%al
  8005be:	74 1b                	je     8005db <vprintfmt+0x203>
  8005c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c4:	78 c8                	js     80058e <vprintfmt+0x1b6>
  8005c6:	ff 4d dc             	decl   -0x24(%ebp)
  8005c9:	79 c3                	jns    80058e <vprintfmt+0x1b6>
  8005cb:	eb 0e                	jmp    8005db <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	57                   	push   %edi
  8005d1:	6a 20                	push   $0x20
  8005d3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d5:	ff 4d d8             	decl   -0x28(%ebp)
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005df:	7f ec                	jg     8005cd <vprintfmt+0x1f5>
  8005e1:	e9 06 fe ff ff       	jmp    8003ec <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005ea:	7e 10                	jle    8005fc <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8005ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ef:	8d 42 08             	lea    0x8(%edx),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f5:	8b 02                	mov    (%edx),%eax
  8005f7:	8b 52 04             	mov    0x4(%edx),%edx
  8005fa:	eb 20                	jmp    80061c <vprintfmt+0x244>
	else if (lflag)
  8005fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800600:	74 0e                	je     800610 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 04             	lea    0x4(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 00                	mov    (%eax),%eax
  80060d:	99                   	cltd   
  80060e:	eb 0c                	jmp    80061c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	89 d1                	mov    %edx,%ecx
  80061e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800620:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800623:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800626:	85 c9                	test   %ecx,%ecx
  800628:	78 0a                	js     800634 <vprintfmt+0x25c>
  80062a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80062f:	e9 89 00 00 00       	jmp    8006bd <vprintfmt+0x2e5>
				putch('-', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	57                   	push   %edi
  800638:	6a 2d                	push   $0x2d
  80063a:	ff d6                	call   *%esi
				num = -(long long) num;
  80063c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80063f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800642:	f7 da                	neg    %edx
  800644:	83 d1 00             	adc    $0x0,%ecx
  800647:	f7 d9                	neg    %ecx
  800649:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	eb 6a                	jmp    8006bd <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800659:	e8 22 fd ff ff       	call   800380 <getuint>
  80065e:	89 d1                	mov    %edx,%ecx
  800660:	89 c2                	mov    %eax,%edx
  800662:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800667:	eb 54                	jmp    8006bd <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80066f:	e8 0c fd ff ff       	call   800380 <getuint>
  800674:	89 d1                	mov    %edx,%ecx
  800676:	89 c2                	mov    %eax,%edx
  800678:	bb 08 00 00 00       	mov    $0x8,%ebx
  80067d:	eb 3e                	jmp    8006bd <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	57                   	push   %edi
  800683:	6a 30                	push   $0x30
  800685:	ff d6                	call   *%esi
			putch('x', putdat);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	57                   	push   %edi
  80068b:	6a 78                	push   $0x78
  80068d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068f:	8b 55 14             	mov    0x14(%ebp),%edx
  800692:	8d 42 04             	lea    0x4(%edx),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
  800698:	8b 12                	mov    (%edx),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb 14                	jmp    8006bd <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006af:	e8 cc fc ff ff       	call   800380 <getuint>
  8006b4:	89 d1                	mov    %edx,%ecx
  8006b6:	89 c2                	mov    %eax,%edx
  8006b8:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c8:	53                   	push   %ebx
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 fa                	mov    %edi,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 08 fc ff ff       	call   8002dc <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	e9 10 fd ff ff       	jmp    8003ec <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	57                   	push   %edi
  8006e0:	52                   	push   %edx
  8006e1:	ff d6                	call   *%esi
			break;
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	e9 01 fd ff ff       	jmp    8003ec <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	6a 25                	push   $0x25
  8006f1:	ff d6                	call   *%esi
  8006f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8006f6:	83 ea 02             	sub    $0x2,%edx
  8006f9:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	8a 02                	mov    (%edx),%al
  8006fe:	4a                   	dec    %edx
  8006ff:	3c 25                	cmp    $0x25,%al
  800701:	75 f9                	jne    8006fc <vprintfmt+0x324>
  800703:	83 c2 02             	add    $0x2,%edx
  800706:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800709:	e9 de fc ff ff       	jmp    8003ec <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 55 08             	mov    0x8(%ebp),%edx
  80071f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800722:	85 d2                	test   %edx,%edx
  800724:	74 37                	je     80075d <vsnprintf+0x47>
  800726:	85 c0                	test   %eax,%eax
  800728:	7e 33                	jle    80075d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800731:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800735:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800738:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 bc 03 80 00       	push   $0x8003bc
  80074a:	e8 89 fc ff ff       	call   8003d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 05                	jmp    800762 <vsnprintf+0x4c>
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
  80076d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800770:	50                   	push   %eax
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 97 ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
  80078a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 3c fc ff ff       	call   8003d8 <vprintfmt>
	va_end(ap);
  80079c:	83 c4 10             	add    $0x10,%esp
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    
  8007a1:	00 00                	add    %al,(%eax)
	...

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 01                	jmp    8007b2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8007b1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007b6:	75 f9                	jne    8007b1 <strlen+0xd>
		n++;
	return n;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 01                	jmp    8007cb <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8007ca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	39 d0                	cmp    %edx,%eax
  8007cd:	74 06                	je     8007d5 <strnlen+0x1b>
  8007cf:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8007d3:	75 f5                	jne    8007ca <strnlen+0x10>
		n++;
	return n;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e0:	8a 01                	mov    (%ecx),%al
  8007e2:	88 02                	mov    %al,(%edx)
  8007e4:	42                   	inc    %edx
  8007e5:	41                   	inc    %ecx
  8007e6:	84 c0                	test   %al,%al
  8007e8:	75 f6                	jne    8007e0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f6:	53                   	push   %ebx
  8007f7:	e8 a8 ff ff ff       	call   8007a4 <strlen>
	strcpy(dst + len, src);
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800802:	50                   	push   %eax
  800803:	e8 cf ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800808:	89 d8                	mov    %ebx,%eax
  80080a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	eb 0c                	jmp    800830 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800824:	8a 02                	mov    (%edx),%al
  800826:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800829:	80 3a 01             	cmpb   $0x1,(%edx)
  80082c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082f:	41                   	inc    %ecx
  800830:	39 d9                	cmp    %ebx,%ecx
  800832:	75 f0                	jne    800824 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800834:	89 f0                	mov    %esi,%eax
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	75 04                	jne    800850 <strlcpy+0x16>
  80084c:	89 f0                	mov    %esi,%eax
  80084e:	eb 14                	jmp    800864 <strlcpy+0x2a>
  800850:	89 f0                	mov    %esi,%eax
  800852:	eb 04                	jmp    800858 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800854:	88 10                	mov    %dl,(%eax)
  800856:	40                   	inc    %eax
  800857:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800858:	49                   	dec    %ecx
  800859:	74 06                	je     800861 <strlcpy+0x27>
  80085b:	8a 13                	mov    (%ebx),%dl
  80085d:	84 d2                	test   %dl,%dl
  80085f:	75 f3                	jne    800854 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
  800864:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 55 08             	mov    0x8(%ebp),%edx
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	eb 02                	jmp    800877 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800875:	42                   	inc    %edx
  800876:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800877:	8a 02                	mov    (%edx),%al
  800879:	84 c0                	test   %al,%al
  80087b:	74 04                	je     800881 <strcmp+0x17>
  80087d:	3a 01                	cmp    (%ecx),%al
  80087f:	74 f4                	je     800875 <strcmp+0xb>
  800881:	0f b6 c0             	movzbl %al,%eax
  800884:	0f b6 11             	movzbl (%ecx),%edx
  800887:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800895:	8b 55 10             	mov    0x10(%ebp),%edx
  800898:	eb 03                	jmp    80089d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80089a:	4a                   	dec    %edx
  80089b:	41                   	inc    %ecx
  80089c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089d:	85 d2                	test   %edx,%edx
  80089f:	75 07                	jne    8008a8 <strncmp+0x1d>
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	eb 14                	jmp    8008bc <strncmp+0x31>
  8008a8:	8a 01                	mov    (%ecx),%al
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 04                	je     8008b2 <strncmp+0x27>
  8008ae:	3a 03                	cmp    (%ebx),%al
  8008b0:	74 e8                	je     80089a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 d0             	movzbl %al,%edx
  8008b5:	0f b6 03             	movzbl (%ebx),%eax
  8008b8:	29 c2                	sub    %eax,%edx
  8008ba:	89 d0                	mov    %edx,%eax
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008c8:	eb 05                	jmp    8008cf <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0c                	je     8008da <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ce:	40                   	inc    %eax
  8008cf:	8a 10                	mov    (%eax),%dl
  8008d1:	84 d2                	test   %dl,%dl
  8008d3:	75 f5                	jne    8008ca <strchr+0xb>
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008e5:	eb 05                	jmp    8008ec <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 07                	je     8008f2 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	40                   	inc    %eax
  8008ec:	8a 10                	mov    (%eax),%dl
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	75 f5                	jne    8008e7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	57                   	push   %edi
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800900:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800903:	85 db                	test   %ebx,%ebx
  800905:	74 36                	je     80093d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800907:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090d:	75 29                	jne    800938 <memset+0x44>
  80090f:	f6 c3 03             	test   $0x3,%bl
  800912:	75 24                	jne    800938 <memset+0x44>
		c &= 0xFF;
  800914:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 08             	shl    $0x8,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 18             	shl    $0x18,%eax
  800921:	89 d1                	mov    %edx,%ecx
  800923:	c1 e1 10             	shl    $0x10,%ecx
  800926:	09 c8                	or     %ecx,%eax
  800928:	09 c2                	or     %eax,%edx
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	09 d0                	or     %edx,%eax
  80092e:	89 d9                	mov    %ebx,%ecx
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 05                	jmp    80093d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	89 d9                	mov    %ebx,%ecx
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800952:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800954:	39 c6                	cmp    %eax,%esi
  800956:	73 36                	jae    80098e <memmove+0x4a>
  800958:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095b:	39 d0                	cmp    %edx,%eax
  80095d:	73 2f                	jae    80098e <memmove+0x4a>
		s += n;
		d += n;
  80095f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	f6 c2 03             	test   $0x3,%dl
  800965:	75 1b                	jne    800982 <memmove+0x3e>
  800967:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096d:	75 13                	jne    800982 <memmove+0x3e>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0e                	jne    800982 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800974:	8d 7e fc             	lea    -0x4(%esi),%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 09                	jmp    80098b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800982:	8d 7e ff             	lea    -0x1(%esi),%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 20                	jmp    8009ae <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 15                	jne    8009ab <memmove+0x67>
  800996:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099c:	75 0d                	jne    8009ab <memmove+0x67>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 08                	jne    8009ab <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 03                	jmp    8009ae <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 81 ff ff ff       	call   800944 <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	83 ec 04             	sub    $0x4,%esp
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8009cf:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	eb 1b                	jmp    8009f2 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8009d7:	8a 1a                	mov    (%edx),%bl
  8009d9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8009dc:	8a 19                	mov    (%ecx),%bl
  8009de:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8009e1:	74 0d                	je     8009f0 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8009e3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8009e7:	0f b6 c3             	movzbl %bl,%eax
  8009ea:	29 c2                	sub    %eax,%edx
  8009ec:	89 d0                	mov    %edx,%eax
  8009ee:	eb 0d                	jmp    8009fd <memcmp+0x38>
		s1++, s2++;
  8009f0:	42                   	inc    %edx
  8009f1:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	48                   	dec    %eax
  8009f3:	83 f8 ff             	cmp    $0xffffffff,%eax
  8009f6:	75 df                	jne    8009d7 <memcmp+0x12>
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8009fd:	83 c4 04             	add    $0x4,%esp
  800a00:	5b                   	pop    %ebx
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0c:	89 c2                	mov    %eax,%edx
  800a0e:	03 55 10             	add    0x10(%ebp),%edx
  800a11:	eb 05                	jmp    800a18 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	38 08                	cmp    %cl,(%eax)
  800a15:	74 05                	je     800a1c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	40                   	inc    %eax
  800a18:	39 d0                	cmp    %edx,%eax
  800a1a:	72 f7                	jb     800a13 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	83 ec 04             	sub    $0x4,%esp
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 75 10             	mov    0x10(%ebp),%esi
  800a2d:	eb 01                	jmp    800a30 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a2f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a30:	8a 01                	mov    (%ecx),%al
  800a32:	3c 20                	cmp    $0x20,%al
  800a34:	74 f9                	je     800a2f <strtol+0x11>
  800a36:	3c 09                	cmp    $0x9,%al
  800a38:	74 f5                	je     800a2f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3a:	3c 2b                	cmp    $0x2b,%al
  800a3c:	75 0a                	jne    800a48 <strtol+0x2a>
		s++;
  800a3e:	41                   	inc    %ecx
  800a3f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a46:	eb 17                	jmp    800a5f <strtol+0x41>
	else if (*s == '-')
  800a48:	3c 2d                	cmp    $0x2d,%al
  800a4a:	74 09                	je     800a55 <strtol+0x37>
  800a4c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a53:	eb 0a                	jmp    800a5f <strtol+0x41>
		s++, neg = 1;
  800a55:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a58:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5f:	85 f6                	test   %esi,%esi
  800a61:	74 05                	je     800a68 <strtol+0x4a>
  800a63:	83 fe 10             	cmp    $0x10,%esi
  800a66:	75 1a                	jne    800a82 <strtol+0x64>
  800a68:	8a 01                	mov    (%ecx),%al
  800a6a:	3c 30                	cmp    $0x30,%al
  800a6c:	75 10                	jne    800a7e <strtol+0x60>
  800a6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a72:	75 0a                	jne    800a7e <strtol+0x60>
		s += 2, base = 16;
  800a74:	83 c1 02             	add    $0x2,%ecx
  800a77:	be 10 00 00 00       	mov    $0x10,%esi
  800a7c:	eb 04                	jmp    800a82 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800a7e:	85 f6                	test   %esi,%esi
  800a80:	74 07                	je     800a89 <strtol+0x6b>
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	eb 13                	jmp    800a9c <strtol+0x7e>
  800a89:	3c 30                	cmp    $0x30,%al
  800a8b:	74 07                	je     800a94 <strtol+0x76>
  800a8d:	be 0a 00 00 00       	mov    $0xa,%esi
  800a92:	eb ee                	jmp    800a82 <strtol+0x64>
		s++, base = 8;
  800a94:	41                   	inc    %ecx
  800a95:	be 08 00 00 00       	mov    $0x8,%esi
  800a9a:	eb e6                	jmp    800a82 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9c:	8a 11                	mov    (%ecx),%dl
  800a9e:	88 d3                	mov    %dl,%bl
  800aa0:	8d 42 d0             	lea    -0x30(%edx),%eax
  800aa3:	3c 09                	cmp    $0x9,%al
  800aa5:	77 08                	ja     800aaf <strtol+0x91>
			dig = *s - '0';
  800aa7:	0f be c2             	movsbl %dl,%eax
  800aaa:	8d 50 d0             	lea    -0x30(%eax),%edx
  800aad:	eb 1c                	jmp    800acb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aaf:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800ab2:	3c 19                	cmp    $0x19,%al
  800ab4:	77 08                	ja     800abe <strtol+0xa0>
			dig = *s - 'a' + 10;
  800ab6:	0f be c2             	movsbl %dl,%eax
  800ab9:	8d 50 a9             	lea    -0x57(%eax),%edx
  800abc:	eb 0d                	jmp    800acb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800ac1:	3c 19                	cmp    $0x19,%al
  800ac3:	77 15                	ja     800ada <strtol+0xbc>
			dig = *s - 'A' + 10;
  800ac5:	0f be c2             	movsbl %dl,%eax
  800ac8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800acb:	39 f2                	cmp    %esi,%edx
  800acd:	7d 0b                	jge    800ada <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800acf:	41                   	inc    %ecx
  800ad0:	89 f8                	mov    %edi,%eax
  800ad2:	0f af c6             	imul   %esi,%eax
  800ad5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800ad8:	eb c2                	jmp    800a9c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800ada:	89 f8                	mov    %edi,%eax

	if (endptr)
  800adc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae0:	74 05                	je     800ae7 <strtol+0xc9>
		*endptr = (char *) s;
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800ae7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800aeb:	74 04                	je     800af1 <strtol+0xd3>
  800aed:	89 c7                	mov    %eax,%edi
  800aef:	f7 df                	neg    %edi
}
  800af1:	89 f8                	mov    %edi,%eax
  800af3:	83 c4 04             	add    $0x4,%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    
	...

00800afc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 01 00 00 00       	mov    $0x1,%eax
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0c:	89 fa                	mov    %edi,%edx
  800b0e:	89 f9                	mov    %edi,%ecx
  800b10:	89 fb                	mov    %edi,%ebx
  800b12:	89 fe                	mov    %edi,%esi
  800b14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	c9                   	leave  
  800b1a:	c3                   	ret    

00800b1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 04             	sub    $0x4,%esp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	89 f8                	mov    %edi,%eax
  800b31:	89 fb                	mov    %edi,%ebx
  800b33:	89 fe                	mov    %edi,%esi
  800b35:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b37:	83 c4 04             	add    $0x4,%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
  800b55:	89 f9                	mov    %edi,%ecx
  800b57:	89 fb                	mov    %edi,%ebx
  800b59:	89 fe                	mov    %edi,%esi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 0d                	push   $0xd
  800b67:	68 1f 23 80 00       	push   $0x80231f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 3c 23 80 00       	push   $0x80233c
  800b73:	e8 6c f6 ff ff       	call   8001e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b97:	be 00 00 00 00       	mov    $0x0,%esi
  800b9c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbc:	89 fb                	mov    %edi,%ebx
  800bbe:	89 fe                	mov    %edi,%esi
  800bc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 0a                	push   $0xa
  800bcc:	68 1f 23 80 00       	push   $0x80231f
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 3c 23 80 00       	push   $0x80233c
  800bd8:	e8 07 f6 ff ff       	call   8001e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	b8 09 00 00 00       	mov    $0x9,%eax
  800bf9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfe:	89 fb                	mov    %edi,%ebx
  800c00:	89 fe                	mov    %edi,%esi
  800c02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 17                	jle    800c1f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 09                	push   $0x9
  800c0e:	68 1f 23 80 00       	push   $0x80231f
  800c13:	6a 23                	push   $0x23
  800c15:	68 3c 23 80 00       	push   $0x80233c
  800c1a:	e8 c5 f5 ff ff       	call   8001e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c40:	89 fb                	mov    %edi,%ebx
  800c42:	89 fe                	mov    %edi,%esi
  800c44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 17                	jle    800c61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 08                	push   $0x8
  800c50:	68 1f 23 80 00       	push   $0x80231f
  800c55:	6a 23                	push   $0x23
  800c57:	68 3c 23 80 00       	push   $0x80233c
  800c5c:	e8 83 f5 ff ff       	call   8001e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c82:	89 fb                	mov    %edi,%ebx
  800c84:	89 fe                	mov    %edi,%esi
  800c86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 17                	jle    800ca3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 06                	push   $0x6
  800c92:	68 1f 23 80 00       	push   $0x80231f
  800c97:	6a 23                	push   $0x23
  800c99:	68 3c 23 80 00       	push   $0x80233c
  800c9e:	e8 41 f5 ff ff       	call   8001e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 17                	jle    800ce5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 05                	push   $0x5
  800cd4:	68 1f 23 80 00       	push   $0x80231f
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 3c 23 80 00       	push   $0x80233c
  800ce0:	e8 ff f4 ff ff       	call   8001e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	b8 04 00 00 00       	mov    $0x4,%eax
  800d04:	bf 00 00 00 00       	mov    $0x0,%edi
  800d09:	89 fe                	mov    %edi,%esi
  800d0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 17                	jle    800d28 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	50                   	push   %eax
  800d15:	6a 04                	push   $0x4
  800d17:	68 1f 23 80 00       	push   $0x80231f
  800d1c:	6a 23                	push   $0x23
  800d1e:	68 3c 23 80 00       	push   $0x80233c
  800d23:	e8 bc f4 ff ff       	call   8001e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d40:	89 fa                	mov    %edi,%edx
  800d42:	89 f9                	mov    %edi,%ecx
  800d44:	89 fb                	mov    %edi,%ebx
  800d46:	89 fe                	mov    %edi,%esi
  800d48:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5f:	89 fa                	mov    %edi,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	89 fb                	mov    %edi,%ebx
  800d65:	89 fe                	mov    %edi,%esi
  800d67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d84:	89 f9                	mov    %edi,%ecx
  800d86:	89 fb                	mov    %edi,%ebx
  800d88:	89 fe                	mov    %edi,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 03                	push   $0x3
  800d96:	68 1f 23 80 00       	push   $0x80231f
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 3c 23 80 00       	push   $0x80233c
  800da2:	e8 3d f4 ff ff       	call   8001e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    
	...

00800db0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc3:	ff 75 08             	pushl  0x8(%ebp)
  800dc6:	e8 e5 ff ff ff       	call   800db0 <fd2num>
  800dcb:	83 c4 04             	add    $0x4,%esp
  800dce:	c1 e0 0c             	shl    $0xc,%eax
  800dd1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ddf:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800de4:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800de6:	89 d0                	mov    %edx,%eax
  800de8:	c1 e8 16             	shr    $0x16,%eax
  800deb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800df2:	a8 01                	test   $0x1,%al
  800df4:	74 10                	je     800e06 <fd_alloc+0x2e>
  800df6:	89 d0                	mov    %edx,%eax
  800df8:	c1 e8 0c             	shr    $0xc,%eax
  800dfb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e02:	a8 01                	test   $0x1,%al
  800e04:	75 09                	jne    800e0f <fd_alloc+0x37>
			*fd_store = fd;
  800e06:	89 0b                	mov    %ecx,(%ebx)
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0d:	eb 19                	jmp    800e28 <fd_alloc+0x50>
			return 0;
  800e0f:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e15:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  800e1b:	75 c7                	jne    800de4 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800e28:	5b                   	pop    %ebx
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e31:	83 f8 1f             	cmp    $0x1f,%eax
  800e34:	77 35                	ja     800e6b <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e36:	c1 e0 0c             	shl    $0xc,%eax
  800e39:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	c1 e8 16             	shr    $0x16,%eax
  800e44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e4b:	a8 01                	test   $0x1,%al
  800e4d:	74 1c                	je     800e6b <fd_lookup+0x40>
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	c1 e8 0c             	shr    $0xc,%eax
  800e54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5b:	a8 01                	test   $0x1,%al
  800e5d:	74 0c                	je     800e6b <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e62:	89 10                	mov    %edx,(%eax)
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	eb 05                	jmp    800e70 <fd_lookup+0x45>
	return 0;
  800e6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e78:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	ff 75 08             	pushl  0x8(%ebp)
  800e7f:	e8 a7 ff ff ff       	call   800e2b <fd_lookup>
  800e84:	83 c4 08             	add    $0x8,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	78 0e                	js     800e99 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e91:	89 50 04             	mov    %edx,0x4(%eax)
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ea8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ead:	eb 0e                	jmp    800ebd <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eaf:	3b 08                	cmp    (%eax),%ecx
  800eb1:	75 09                	jne    800ebc <dev_lookup+0x21>
			*dev = devtab[i];
  800eb3:	89 03                	mov    %eax,(%ebx)
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	eb 31                	jmp    800eed <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ebc:	42                   	inc    %edx
  800ebd:	8b 04 95 c8 23 80 00 	mov    0x8023c8(,%edx,4),%eax
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	75 e7                	jne    800eaf <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec8:	a1 08 40 80 00       	mov    0x804008,%eax
  800ecd:	8b 40 48             	mov    0x48(%eax),%eax
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	51                   	push   %ecx
  800ed4:	50                   	push   %eax
  800ed5:	68 4c 23 80 00       	push   $0x80234c
  800eda:	e8 a6 f3 ff ff       	call   800285 <cprintf>
	*dev = 0;
  800edf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eea:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 14             	sub    $0x14,%esp
  800ef9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800efc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eff:	50                   	push   %eax
  800f00:	ff 75 08             	pushl  0x8(%ebp)
  800f03:	e8 23 ff ff ff       	call   800e2b <fd_lookup>
  800f08:	83 c4 08             	add    $0x8,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	78 55                	js     800f64 <fstat+0x72>
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f19:	ff 30                	pushl  (%eax)
  800f1b:	e8 7b ff ff ff       	call   800e9b <dev_lookup>
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 3d                	js     800f64 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800f27:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f2a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800f2e:	75 07                	jne    800f37 <fstat+0x45>
  800f30:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f35:	eb 2d                	jmp    800f64 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800f37:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800f3a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800f41:	00 00 00 
	stat->st_isdir = 0;
  800f44:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f4b:	00 00 00 
	stat->st_dev = dev;
  800f4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f51:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800f57:	83 ec 08             	sub    $0x8,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5e:	ff 50 14             	call   *0x14(%eax)
  800f61:	83 c4 10             	add    $0x10,%esp
}
  800f64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 14             	sub    $0x14,%esp
  800f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	53                   	push   %ebx
  800f78:	e8 ae fe ff ff       	call   800e2b <fd_lookup>
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 5f                	js     800fe3 <ftruncate+0x7a>
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8e:	ff 30                	pushl  (%eax)
  800f90:	e8 06 ff ff ff       	call   800e9b <dev_lookup>
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 47                	js     800fe3 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800fa3:	75 21                	jne    800fc6 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800fa5:	a1 08 40 80 00       	mov    0x804008,%eax
  800faa:	8b 40 48             	mov    0x48(%eax),%eax
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	50                   	push   %eax
  800fb2:	68 6c 23 80 00       	push   $0x80236c
  800fb7:	e8 c9 f2 ff ff       	call   800285 <cprintf>
  800fbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	eb 1d                	jmp    800fe3 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800fc6:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800fc9:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800fcd:	75 07                	jne    800fd6 <ftruncate+0x6d>
  800fcf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800fd4:	eb 0d                	jmp    800fe3 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	ff 75 0c             	pushl  0xc(%ebp)
  800fdc:	50                   	push   %eax
  800fdd:	ff 52 18             	call   *0x18(%edx)
  800fe0:	83 c4 10             	add    $0x10,%esp
}
  800fe3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 14             	sub    $0x14,%esp
  800fef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff5:	50                   	push   %eax
  800ff6:	53                   	push   %ebx
  800ff7:	e8 2f fe ff ff       	call   800e2b <fd_lookup>
  800ffc:	83 c4 08             	add    $0x8,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 62                	js     801065 <write+0x7d>
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100d:	ff 30                	pushl  (%eax)
  80100f:	e8 87 fe ff ff       	call   800e9b <dev_lookup>
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 4a                	js     801065 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801022:	75 21                	jne    801045 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801024:	a1 08 40 80 00       	mov    0x804008,%eax
  801029:	8b 40 48             	mov    0x48(%eax),%eax
  80102c:	83 ec 04             	sub    $0x4,%esp
  80102f:	53                   	push   %ebx
  801030:	50                   	push   %eax
  801031:	68 8d 23 80 00       	push   $0x80238d
  801036:	e8 4a f2 ff ff       	call   800285 <cprintf>
  80103b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	eb 20                	jmp    801065 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801045:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801048:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  80104c:	75 07                	jne    801055 <write+0x6d>
  80104e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801053:	eb 10                	jmp    801065 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	ff 75 10             	pushl  0x10(%ebp)
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	50                   	push   %eax
  80105f:	ff 52 0c             	call   *0xc(%edx)
  801062:	83 c4 10             	add    $0x10,%esp
}
  801065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	53                   	push   %ebx
  80106e:	83 ec 14             	sub    $0x14,%esp
  801071:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801077:	50                   	push   %eax
  801078:	53                   	push   %ebx
  801079:	e8 ad fd ff ff       	call   800e2b <fd_lookup>
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 67                	js     8010ec <read+0x82>
  801085:	83 ec 08             	sub    $0x8,%esp
  801088:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80108b:	50                   	push   %eax
  80108c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108f:	ff 30                	pushl  (%eax)
  801091:	e8 05 fe ff ff       	call   800e9b <dev_lookup>
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	78 4f                	js     8010ec <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80109d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010a0:	8b 42 08             	mov    0x8(%edx),%eax
  8010a3:	83 e0 03             	and    $0x3,%eax
  8010a6:	83 f8 01             	cmp    $0x1,%eax
  8010a9:	75 21                	jne    8010cc <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b0:	8b 40 48             	mov    0x48(%eax),%eax
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	53                   	push   %ebx
  8010b7:	50                   	push   %eax
  8010b8:	68 aa 23 80 00       	push   $0x8023aa
  8010bd:	e8 c3 f1 ff ff       	call   800285 <cprintf>
  8010c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	eb 20                	jmp    8010ec <read+0x82>
	}
	if (!dev->dev_read)
  8010cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010cf:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8010d3:	75 07                	jne    8010dc <read+0x72>
  8010d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010da:	eb 10                	jmp    8010ec <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	ff 75 10             	pushl  0x10(%ebp)
  8010e2:	ff 75 0c             	pushl  0xc(%ebp)
  8010e5:	52                   	push   %edx
  8010e6:	ff 50 08             	call   *0x8(%eax)
  8010e9:	83 c4 10             	add    $0x10,%esp
}
  8010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010fd:	8b 75 10             	mov    0x10(%ebp),%esi
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	eb 21                	jmp    801128 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	29 d0                	sub    %edx,%eax
  80110e:	50                   	push   %eax
  80110f:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801112:	50                   	push   %eax
  801113:	ff 75 08             	pushl  0x8(%ebp)
  801116:	e8 4f ff ff ff       	call   80106a <read>
		if (m < 0)
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	78 0e                	js     801130 <readn+0x3f>
			return m;
		if (m == 0)
  801122:	85 c0                	test   %eax,%eax
  801124:	74 08                	je     80112e <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801126:	01 c3                	add    %eax,%ebx
  801128:	89 da                	mov    %ebx,%edx
  80112a:	39 f3                	cmp    %esi,%ebx
  80112c:	72 d9                	jb     801107 <readn+0x16>
  80112e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 20             	sub    $0x20,%esp
  801140:	8b 75 08             	mov    0x8(%ebp),%esi
  801143:	8a 45 0c             	mov    0xc(%ebp),%al
  801146:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801149:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	56                   	push   %esi
  80114e:	e8 5d fc ff ff       	call   800db0 <fd2num>
  801153:	89 04 24             	mov    %eax,(%esp)
  801156:	e8 d0 fc ff ff       	call   800e2b <fd_lookup>
  80115b:	89 c3                	mov    %eax,%ebx
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 05                	js     801169 <fd_close+0x31>
  801164:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801167:	74 0d                	je     801176 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801169:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80116d:	75 48                	jne    8011b7 <fd_close+0x7f>
  80116f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801174:	eb 41                	jmp    8011b7 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	ff 36                	pushl  (%esi)
  80117f:	e8 17 fd ff ff       	call   800e9b <dev_lookup>
  801184:	89 c3                	mov    %eax,%ebx
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 1c                	js     8011a9 <fd_close+0x71>
		if (dev->dev_close)
  80118d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801190:	8b 40 10             	mov    0x10(%eax),%eax
  801193:	85 c0                	test   %eax,%eax
  801195:	75 07                	jne    80119e <fd_close+0x66>
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	eb 0b                	jmp    8011a9 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	56                   	push   %esi
  8011a2:	ff d0                	call   *%eax
  8011a4:	89 c3                	mov    %eax,%ebx
  8011a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	56                   	push   %esi
  8011ad:	6a 00                	push   $0x0
  8011af:	e8 b5 fa ff ff       	call   800c69 <sys_page_unmap>
  8011b4:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8011b7:	89 d8                	mov    %ebx,%eax
  8011b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 08             	pushl  0x8(%ebp)
  8011cd:	e8 59 fc ff ff       	call   800e2b <fd_lookup>
  8011d2:	83 c4 08             	add    $0x8,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 10                	js     8011e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	6a 01                	push   $0x1
  8011de:	ff 75 fc             	pushl  -0x4(%ebp)
  8011e1:	e8 52 ff ff ff       	call   801138 <fd_close>
  8011e6:	83 c4 10             	add    $0x10,%esp
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	6a 00                	push   $0x0
  8011f5:	ff 75 08             	pushl  0x8(%ebp)
  8011f8:	e8 4a 03 00 00       	call   801547 <open>
  8011fd:	89 c6                	mov    %eax,%esi
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 1b                	js     801221 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	50                   	push   %eax
  80120d:	e8 e0 fc ff ff       	call   800ef2 <fstat>
  801212:	89 c3                	mov    %eax,%ebx
	close(fd);
  801214:	89 34 24             	mov    %esi,(%esp)
  801217:	e8 a4 ff ff ff       	call   8011c0 <close>
  80121c:	89 de                	mov    %ebx,%esi
  80121e:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801221:	89 f0                	mov    %esi,%eax
  801223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	57                   	push   %edi
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
  801230:	83 ec 1c             	sub    $0x1c,%esp
  801233:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801236:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 e9 fb ff ff       	call   800e2b <fd_lookup>
  801242:	89 c3                	mov    %eax,%ebx
  801244:	83 c4 08             	add    $0x8,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	0f 88 bd 00 00 00    	js     80130c <dup+0xe2>
		return r;
	close(newfdnum);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	57                   	push   %edi
  801253:	e8 68 ff ff ff       	call   8011c0 <close>

	newfd = INDEX2FD(newfdnum);
  801258:	89 f8                	mov    %edi,%eax
  80125a:	c1 e0 0c             	shl    $0xc,%eax
  80125d:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801263:	ff 75 f0             	pushl  -0x10(%ebp)
  801266:	e8 55 fb ff ff       	call   800dc0 <fd2data>
  80126b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80126d:	89 34 24             	mov    %esi,(%esp)
  801270:	e8 4b fb ff ff       	call   800dc0 <fd2data>
  801275:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	c1 e8 16             	shr    $0x16,%eax
  80127d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801284:	83 c4 14             	add    $0x14,%esp
  801287:	a8 01                	test   $0x1,%al
  801289:	74 36                	je     8012c1 <dup+0x97>
  80128b:	89 da                	mov    %ebx,%edx
  80128d:	c1 ea 0c             	shr    $0xc,%edx
  801290:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801297:	a8 01                	test   $0x1,%al
  801299:	74 26                	je     8012c1 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80129b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012aa:	50                   	push   %eax
  8012ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8012ae:	6a 00                	push   $0x0
  8012b0:	53                   	push   %ebx
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 f3 f9 ff ff       	call   800cab <sys_page_map>
  8012b8:	89 c3                	mov    %eax,%ebx
  8012ba:	83 c4 20             	add    $0x20,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 30                	js     8012f1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012c4:	89 d0                	mov    %edx,%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
  8012c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d8:	50                   	push   %eax
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	52                   	push   %edx
  8012dd:	6a 00                	push   $0x0
  8012df:	e8 c7 f9 ff ff       	call   800cab <sys_page_map>
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 20             	add    $0x20,%esp
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 04                	js     8012f1 <dup+0xc7>
		goto err;
  8012ed:	89 fb                	mov    %edi,%ebx
  8012ef:	eb 1b                	jmp    80130c <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	56                   	push   %esi
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 6d f9 ff ff       	call   800c69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801302:	6a 00                	push   $0x0
  801304:	e8 60 f9 ff ff       	call   800c69 <sys_page_unmap>
  801309:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	53                   	push   %ebx
  801326:	e8 95 fe ff ff       	call   8011c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80132b:	43                   	inc    %ebx
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	83 fb 20             	cmp    $0x20,%ebx
  801332:	75 ee                	jne    801322 <close_all+0xc>
		close(i);
}
  801334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801337:	c9                   	leave  
  801338:	c3                   	ret    
  801339:	00 00                	add    %al,(%eax)
	...

0080133c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	89 c3                	mov    %eax,%ebx
  801343:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801345:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80134c:	75 12                	jne    801360 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	6a 01                	push   $0x1
  801353:	e8 60 08 00 00       	call   801bb8 <ipc_find_env>
  801358:	a3 04 40 80 00       	mov    %eax,0x804004
  80135d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801360:	6a 07                	push   $0x7
  801362:	68 00 50 80 00       	push   $0x805000
  801367:	53                   	push   %ebx
  801368:	ff 35 04 40 80 00    	pushl  0x804004
  80136e:	e8 8a 08 00 00       	call   801bfd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801373:	83 c4 0c             	add    $0xc,%esp
  801376:	6a 00                	push   $0x0
  801378:	56                   	push   %esi
  801379:	6a 00                	push   $0x0
  80137b:	e8 d2 08 00 00       	call   801c52 <ipc_recv>
}
  801380:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	b8 08 00 00 00       	mov    $0x8,%eax
  801397:	e8 a0 ff ff ff       	call   80133c <fsipc>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013aa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c1:	e8 76 ff ff ff       	call   80133c <fsipc>
}
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e3:	e8 54 ff ff ff       	call   80133c <fsipc>
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 04             	sub    $0x4,%esp
  8013f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 05 00 00 00       	mov    $0x5,%eax
  801409:	e8 2e ff ff ff       	call   80133c <fsipc>
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 2c                	js     80143e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	68 00 50 80 00       	push   $0x805000
  80141a:	53                   	push   %ebx
  80141b:	e8 b7 f3 ff ff       	call   8007d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801420:	a1 80 50 80 00       	mov    0x805080,%eax
  801425:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80142b:	a1 84 50 80 00       	mov    0x805084,%eax
  801430:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
  80143b:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80144d:	8b 45 08             	mov    0x8(%ebp),%eax
  801450:	8b 40 0c             	mov    0xc(%eax),%eax
  801453:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801458:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80145e:	53                   	push   %ebx
  80145f:	ff 75 0c             	pushl  0xc(%ebp)
  801462:	68 08 50 80 00       	push   $0x805008
  801467:	e8 d8 f4 ff ff       	call   800944 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80146c:	ba 00 00 00 00       	mov    $0x0,%edx
  801471:	b8 04 00 00 00       	mov    $0x4,%eax
  801476:	e8 c1 fe ff ff       	call   80133c <fsipc>
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 3d                	js     8014bf <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801482:	39 c3                	cmp    %eax,%ebx
  801484:	73 19                	jae    80149f <devfile_write+0x5c>
  801486:	68 d8 23 80 00       	push   $0x8023d8
  80148b:	68 df 23 80 00       	push   $0x8023df
  801490:	68 97 00 00 00       	push   $0x97
  801495:	68 f4 23 80 00       	push   $0x8023f4
  80149a:	e8 45 ed ff ff       	call   8001e4 <_panic>
	assert(r <= PGSIZE);
  80149f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014a4:	7e 19                	jle    8014bf <devfile_write+0x7c>
  8014a6:	68 ff 23 80 00       	push   $0x8023ff
  8014ab:	68 df 23 80 00       	push   $0x8023df
  8014b0:	68 98 00 00 00       	push   $0x98
  8014b5:	68 f4 23 80 00       	push   $0x8023f4
  8014ba:	e8 25 ed ff ff       	call   8001e4 <_panic>
	
	return r;
}
  8014bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014d7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e7:	e8 50 fe ff ff       	call   80133c <fsipc>
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 4c                	js     80153e <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8014f2:	39 de                	cmp    %ebx,%esi
  8014f4:	73 16                	jae    80150c <devfile_read+0x48>
  8014f6:	68 d8 23 80 00       	push   $0x8023d8
  8014fb:	68 df 23 80 00       	push   $0x8023df
  801500:	6a 7c                	push   $0x7c
  801502:	68 f4 23 80 00       	push   $0x8023f4
  801507:	e8 d8 ec ff ff       	call   8001e4 <_panic>
	assert(r <= PGSIZE);
  80150c:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801512:	7e 16                	jle    80152a <devfile_read+0x66>
  801514:	68 ff 23 80 00       	push   $0x8023ff
  801519:	68 df 23 80 00       	push   $0x8023df
  80151e:	6a 7d                	push   $0x7d
  801520:	68 f4 23 80 00       	push   $0x8023f4
  801525:	e8 ba ec ff ff       	call   8001e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	50                   	push   %eax
  80152e:	68 00 50 80 00       	push   $0x805000
  801533:	ff 75 0c             	pushl  0xc(%ebp)
  801536:	e8 09 f4 ff ff       	call   800944 <memmove>
  80153b:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80153e:	89 d8                	mov    %ebx,%eax
  801540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	c9                   	leave  
  801546:	c3                   	ret    

00801547 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801547:	55                   	push   %ebp
  801548:	89 e5                	mov    %esp,%ebp
  80154a:	56                   	push   %esi
  80154b:	53                   	push   %ebx
  80154c:	83 ec 1c             	sub    $0x1c,%esp
  80154f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801552:	56                   	push   %esi
  801553:	e8 4c f2 ff ff       	call   8007a4 <strlen>
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801560:	7e 07                	jle    801569 <open+0x22>
  801562:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801567:	eb 63                	jmp    8015cc <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	e8 63 f8 ff ff       	call   800dd8 <fd_alloc>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 4e                	js     8015cc <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	56                   	push   %esi
  801582:	68 00 50 80 00       	push   $0x805000
  801587:	e8 4b f2 ff ff       	call   8007d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80158c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801597:	b8 01 00 00 00       	mov    $0x1,%eax
  80159c:	e8 9b fd ff ff       	call   80133c <fsipc>
  8015a1:	89 c3                	mov    %eax,%ebx
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	79 12                	jns    8015bc <open+0x75>
		fd_close(fd, 0);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	6a 00                	push   $0x0
  8015af:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b2:	e8 81 fb ff ff       	call   801138 <fd_close>
		return r;
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 10                	jmp    8015cc <open+0x85>
	}

	return fd2num(fd);
  8015bc:	83 ec 0c             	sub    $0xc,%esp
  8015bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c2:	e8 e9 f7 ff ff       	call   800db0 <fd2num>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
}
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    
  8015d5:	00 00                	add    %al,(%eax)
	...

008015d8 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8015e1:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015e5:	7e 2c                	jle    801613 <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	ff 70 04             	pushl  0x4(%eax)
  8015ed:	8d 40 10             	lea    0x10(%eax),%eax
  8015f0:	50                   	push   %eax
  8015f1:	ff 33                	pushl  (%ebx)
  8015f3:	e8 f0 f9 ff ff       	call   800fe8 <write>
		if (result > 0)
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	7e 03                	jle    801602 <writebuf+0x2a>
			b->result += result;
  8015ff:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801602:	3b 43 04             	cmp    0x4(%ebx),%eax
  801605:	74 0c                	je     801613 <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  801607:	85 c0                	test   %eax,%eax
  801609:	7e 05                	jle    801610 <writebuf+0x38>
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
  801610:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	53                   	push   %ebx
  80161c:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  801622:	8b 45 08             	mov    0x8(%ebp),%eax
  801625:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  80162b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801632:	00 00 00 
	b.result = 0;
  801635:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80163c:	00 00 00 
	b.error = 1;
  80163f:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  801646:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801649:	ff 75 10             	pushl  0x10(%ebp)
  80164c:	ff 75 0c             	pushl  0xc(%ebp)
  80164f:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  801655:	53                   	push   %ebx
  801656:	68 bb 16 80 00       	push   $0x8016bb
  80165b:	e8 78 ed ff ff       	call   8003d8 <vprintfmt>
	if (b.idx > 0)
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  80166a:	7e 07                	jle    801673 <vfprintf+0x5b>
		writebuf(&b);
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	e8 65 ff ff ff       	call   8015d8 <writebuf>

	return (b.result ? b.result : b.error);
  801673:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801679:	85 c0                	test   %eax,%eax
  80167b:	75 06                	jne    801683 <vfprintf+0x6b>
  80167d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  801683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80168e:	8d 45 0c             	lea    0xc(%ebp),%eax
  801691:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  801694:	50                   	push   %eax
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	6a 01                	push   $0x1
  80169a:	e8 79 ff ff ff       	call   801618 <vfprintf>
	va_end(ap);

	return cnt;
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a7:	8d 45 10             	lea    0x10(%ebp),%eax
  8016aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  8016ad:	50                   	push   %eax
  8016ae:	ff 75 0c             	pushl  0xc(%ebp)
  8016b1:	ff 75 08             	pushl  0x8(%ebp)
  8016b4:	e8 5f ff ff ff       	call   801618 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 04             	sub    $0x4,%esp
  8016c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cb:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  8016cf:	40                   	inc    %eax
  8016d0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8016d3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016d8:	75 0e                	jne    8016e8 <putch+0x2d>
		writebuf(b);
  8016da:	89 d8                	mov    %ebx,%eax
  8016dc:	e8 f7 fe ff ff       	call   8015d8 <writebuf>
		b->idx = 0;
  8016e1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016e8:	83 c4 04             	add    $0x4,%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    
	...

008016f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	ff 75 08             	pushl  0x8(%ebp)
  8016fe:	e8 bd f6 ff ff       	call   800dc0 <fd2data>
  801703:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801705:	83 c4 08             	add    $0x8,%esp
  801708:	68 0b 24 80 00       	push   $0x80240b
  80170d:	53                   	push   %ebx
  80170e:	e8 c4 f0 ff ff       	call   8007d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801713:	8b 46 04             	mov    0x4(%esi),%eax
  801716:	2b 06                	sub    (%esi),%eax
  801718:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80171e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801725:	00 00 00 
	stat->st_dev = &devpipe;
  801728:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  80172f:	30 80 00 
	return 0;
}
  801732:	b8 00 00 00 00       	mov    $0x0,%eax
  801737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 0c             	sub    $0xc,%esp
  801745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801748:	53                   	push   %ebx
  801749:	6a 00                	push   $0x0
  80174b:	e8 19 f5 ff ff       	call   800c69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801750:	89 1c 24             	mov    %ebx,(%esp)
  801753:	e8 68 f6 ff ff       	call   800dc0 <fd2data>
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	50                   	push   %eax
  80175c:	6a 00                	push   $0x0
  80175e:	e8 06 f5 ff ff       	call   800c69 <sys_page_unmap>
}
  801763:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	57                   	push   %edi
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801774:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801776:	a1 08 40 80 00       	mov    0x804008,%eax
  80177b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	ff 75 f0             	pushl  -0x10(%ebp)
  801784:	e8 33 05 00 00       	call   801cbc <pageref>
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	89 3c 24             	mov    %edi,(%esp)
  80178e:	e8 29 05 00 00       	call   801cbc <pageref>
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	39 c3                	cmp    %eax,%ebx
  801798:	0f 94 c0             	sete   %al
  80179b:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  80179e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8017a4:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  8017a7:	39 c6                	cmp    %eax,%esi
  8017a9:	74 1b                	je     8017c6 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  8017ab:	83 f9 01             	cmp    $0x1,%ecx
  8017ae:	75 c6                	jne    801776 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017b0:	8b 42 58             	mov    0x58(%edx),%eax
  8017b3:	6a 01                	push   $0x1
  8017b5:	50                   	push   %eax
  8017b6:	56                   	push   %esi
  8017b7:	68 12 24 80 00       	push   $0x802412
  8017bc:	e8 c4 ea ff ff       	call   800285 <cprintf>
  8017c1:	83 c4 10             	add    $0x10,%esp
  8017c4:	eb b0                	jmp    801776 <_pipeisclosed+0xe>
	}
}
  8017c6:	89 c8                	mov    %ecx,%eax
  8017c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5f                   	pop    %edi
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	57                   	push   %edi
  8017d4:	56                   	push   %esi
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 18             	sub    $0x18,%esp
  8017d9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017dc:	56                   	push   %esi
  8017dd:	e8 de f5 ff ff       	call   800dc0 <fd2data>
  8017e2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017ea:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	eb 40                	jmp    801834 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f9:	eb 40                	jmp    80183b <devpipe_write+0x6b>
  8017fb:	89 da                	mov    %ebx,%edx
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	e8 64 ff ff ff       	call   801768 <_pipeisclosed>
  801804:	85 c0                	test   %eax,%eax
  801806:	75 ec                	jne    8017f4 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801808:	e8 23 f5 ff ff       	call   800d30 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80180d:	8b 53 04             	mov    0x4(%ebx),%edx
  801810:	8b 03                	mov    (%ebx),%eax
  801812:	83 c0 20             	add    $0x20,%eax
  801815:	39 c2                	cmp    %eax,%edx
  801817:	73 e2                	jae    8017fb <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801819:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80181f:	79 05                	jns    801826 <devpipe_write+0x56>
  801821:	4a                   	dec    %edx
  801822:	83 ca e0             	or     $0xffffffe0,%edx
  801825:	42                   	inc    %edx
  801826:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801829:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  80182c:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801830:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801833:	47                   	inc    %edi
  801834:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801837:	75 d4                	jne    80180d <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801839:	89 f8                	mov    %edi,%eax
}
  80183b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	53                   	push   %ebx
  801849:	83 ec 18             	sub    $0x18,%esp
  80184c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80184f:	57                   	push   %edi
  801850:	e8 6b f5 ff ff       	call   800dc0 <fd2data>
  801855:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80185d:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb 41                	jmp    8018a8 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801867:	89 f0                	mov    %esi,%eax
  801869:	eb 44                	jmp    8018af <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	eb 3d                	jmp    8018af <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801872:	85 f6                	test   %esi,%esi
  801874:	75 f1                	jne    801867 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801876:	89 da                	mov    %ebx,%edx
  801878:	89 f8                	mov    %edi,%eax
  80187a:	e8 e9 fe ff ff       	call   801768 <_pipeisclosed>
  80187f:	85 c0                	test   %eax,%eax
  801881:	75 e8                	jne    80186b <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801883:	e8 a8 f4 ff ff       	call   800d30 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801888:	8b 03                	mov    (%ebx),%eax
  80188a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80188d:	74 e3                	je     801872 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80188f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801894:	79 05                	jns    80189b <devpipe_read+0x58>
  801896:	48                   	dec    %eax
  801897:	83 c8 e0             	or     $0xffffffe0,%eax
  80189a:	40                   	inc    %eax
  80189b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80189f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018a2:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  8018a5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a7:	46                   	inc    %esi
  8018a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ab:	75 db                	jne    801888 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018ad:	89 f0                	mov    %esi,%eax
}
  8018af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b2:	5b                   	pop    %ebx
  8018b3:	5e                   	pop    %esi
  8018b4:	5f                   	pop    %edi
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	ff 75 08             	pushl  0x8(%ebp)
  8018c4:	e8 62 f5 ff ff       	call   800e2b <fd_lookup>
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 18                	js     8018e8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018d0:	83 ec 0c             	sub    $0xc,%esp
  8018d3:	ff 75 fc             	pushl  -0x4(%ebp)
  8018d6:	e8 e5 f4 ff ff       	call   800dc0 <fd2data>
  8018db:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018e0:	e8 83 fe ff ff       	call   801768 <_pipeisclosed>
  8018e5:	83 c4 10             	add    $0x10,%esp
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	83 ec 28             	sub    $0x28,%esp
  8018f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	e8 d9 f4 ff ff       	call   800dd8 <fd_alloc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	0f 88 24 01 00 00    	js     801a30 <pipe+0x146>
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	68 07 04 00 00       	push   $0x407
  801914:	ff 75 f0             	pushl  -0x10(%ebp)
  801917:	6a 00                	push   $0x0
  801919:	e8 cf f3 ff ff       	call   800ced <sys_page_alloc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	0f 88 05 01 00 00    	js     801a30 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	e8 a1 f4 ff ff       	call   800dd8 <fd_alloc>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	0f 88 dc 00 00 00    	js     801a20 <pipe+0x136>
  801944:	83 ec 04             	sub    $0x4,%esp
  801947:	68 07 04 00 00       	push   $0x407
  80194c:	ff 75 ec             	pushl  -0x14(%ebp)
  80194f:	6a 00                	push   $0x0
  801951:	e8 97 f3 ff ff       	call   800ced <sys_page_alloc>
  801956:	89 c3                	mov    %eax,%ebx
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 88 bd 00 00 00    	js     801a20 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff 75 f0             	pushl  -0x10(%ebp)
  801969:	e8 52 f4 ff ff       	call   800dc0 <fd2data>
  80196e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801970:	83 c4 0c             	add    $0xc,%esp
  801973:	68 07 04 00 00       	push   $0x407
  801978:	50                   	push   %eax
  801979:	6a 00                	push   $0x0
  80197b:	e8 6d f3 ff ff       	call   800ced <sys_page_alloc>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	0f 88 83 00 00 00    	js     801a10 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80198d:	83 ec 0c             	sub    $0xc,%esp
  801990:	ff 75 ec             	pushl  -0x14(%ebp)
  801993:	e8 28 f4 ff ff       	call   800dc0 <fd2data>
  801998:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80199f:	50                   	push   %eax
  8019a0:	6a 00                	push   $0x0
  8019a2:	56                   	push   %esi
  8019a3:	6a 00                	push   $0x0
  8019a5:	e8 01 f3 ff ff       	call   800cab <sys_page_map>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	83 c4 20             	add    $0x20,%esp
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 4f                	js     801a02 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019b3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8019b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019c8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8019ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019d1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019dd:	83 ec 0c             	sub    $0xc,%esp
  8019e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e3:	e8 c8 f3 ff ff       	call   800db0 <fd2num>
  8019e8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019ea:	83 c4 04             	add    $0x4,%esp
  8019ed:	ff 75 ec             	pushl  -0x14(%ebp)
  8019f0:	e8 bb f3 ff ff       	call   800db0 <fd2num>
  8019f5:	89 47 04             	mov    %eax,0x4(%edi)
  8019f8:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	eb 2e                	jmp    801a30 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	56                   	push   %esi
  801a06:	6a 00                	push   $0x0
  801a08:	e8 5c f2 ff ff       	call   800c69 <sys_page_unmap>
  801a0d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	ff 75 ec             	pushl  -0x14(%ebp)
  801a16:	6a 00                	push   $0x0
  801a18:	e8 4c f2 ff ff       	call   800c69 <sys_page_unmap>
  801a1d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a20:	83 ec 08             	sub    $0x8,%esp
  801a23:	ff 75 f0             	pushl  -0x10(%ebp)
  801a26:	6a 00                	push   $0x0
  801a28:	e8 3c f2 ff ff       	call   800c69 <sys_page_unmap>
  801a2d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a35:	5b                   	pop    %ebx
  801a36:	5e                   	pop    %esi
  801a37:	5f                   	pop    %edi
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    
	...

00801a3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a4c:	68 2a 24 80 00       	push   $0x80242a
  801a51:	ff 75 0c             	pushl  0xc(%ebp)
  801a54:	e8 7e ed ff ff       	call   8007d7 <strcpy>
	return 0;
}
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801a6c:	be 00 00 00 00       	mov    $0x0,%esi
  801a71:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801a77:	eb 2c                	jmp    801aa5 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a7c:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a7e:	83 fb 7f             	cmp    $0x7f,%ebx
  801a81:	76 05                	jbe    801a88 <devcons_write+0x28>
  801a83:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a88:	83 ec 04             	sub    $0x4,%esp
  801a8b:	53                   	push   %ebx
  801a8c:	03 45 0c             	add    0xc(%ebp),%eax
  801a8f:	50                   	push   %eax
  801a90:	57                   	push   %edi
  801a91:	e8 ae ee ff ff       	call   800944 <memmove>
		sys_cputs(buf, m);
  801a96:	83 c4 08             	add    $0x8,%esp
  801a99:	53                   	push   %ebx
  801a9a:	57                   	push   %edi
  801a9b:	e8 7b f0 ff ff       	call   800b1b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa0:	01 de                	add    %ebx,%esi
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	89 f0                	mov    %esi,%eax
  801aa7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aaa:	72 cd                	jb     801a79 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5f                   	pop    %edi
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ac0:	6a 01                	push   $0x1
  801ac2:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801ac5:	50                   	push   %eax
  801ac6:	e8 50 f0 ff ff       	call   800b1b <sys_cputs>
  801acb:	83 c4 10             	add    $0x10,%esp
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ad6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ada:	74 27                	je     801b03 <devcons_read+0x33>
  801adc:	eb 05                	jmp    801ae3 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ade:	e8 4d f2 ff ff       	call   800d30 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ae3:	e8 14 f0 ff ff       	call   800afc <sys_cgetc>
  801ae8:	89 c2                	mov    %eax,%edx
  801aea:	85 c0                	test   %eax,%eax
  801aec:	74 f0                	je     801ade <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 16                	js     801b08 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801af2:	83 f8 04             	cmp    $0x4,%eax
  801af5:	74 0c                	je     801b03 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afa:	88 10                	mov    %dl,(%eax)
  801afc:	ba 01 00 00 00       	mov    $0x1,%edx
  801b01:	eb 05                	jmp    801b08 <devcons_read+0x38>
	return 1;
  801b03:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b08:	89 d0                	mov    %edx,%eax
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b12:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	e8 bd f2 ff ff       	call   800dd8 <fd_alloc>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 3b                	js     801b5d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b22:	83 ec 04             	sub    $0x4,%esp
  801b25:	68 07 04 00 00       	push   $0x407
  801b2a:	ff 75 fc             	pushl  -0x4(%ebp)
  801b2d:	6a 00                	push   $0x0
  801b2f:	e8 b9 f1 ff ff       	call   800ced <sys_page_alloc>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 22                	js     801b5d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b3b:	a1 40 30 80 00       	mov    0x803040,%eax
  801b40:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801b43:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801b45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 fc             	pushl  -0x4(%ebp)
  801b55:	e8 56 f2 ff ff       	call   800db0 <fd2num>
  801b5a:	83 c4 10             	add    $0x10,%esp
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b65:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	ff 75 08             	pushl  0x8(%ebp)
  801b6c:	e8 ba f2 ff ff       	call   800e2b <fd_lookup>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	78 11                	js     801b89 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b78:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b7b:	8b 00                	mov    (%eax),%eax
  801b7d:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  801b83:	0f 94 c0             	sete   %al
  801b86:	0f b6 c0             	movzbl %al,%eax
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b91:	6a 01                	push   $0x1
  801b93:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	6a 00                	push   $0x0
  801b99:	e8 cc f4 ff ff       	call   80106a <read>
	if (r < 0)
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 0f                	js     801bb4 <getchar+0x29>
		return r;
	if (r < 1)
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	75 07                	jne    801bb0 <getchar+0x25>
  801ba9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801bae:	eb 04                	jmp    801bb4 <getchar+0x29>
		return -E_EOF;
	return c;
  801bb0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    
	...

00801bb8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bbf:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bc4:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801bcb:	89 c8                	mov    %ecx,%eax
  801bcd:	c1 e0 07             	shl    $0x7,%eax
  801bd0:	29 d0                	sub    %edx,%eax
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801bda:	8b 40 50             	mov    0x50(%eax),%eax
  801bdd:	39 d8                	cmp    %ebx,%eax
  801bdf:	75 0b                	jne    801bec <ipc_find_env+0x34>
			return envs[i].env_id;
  801be1:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801be7:	8b 40 40             	mov    0x40(%eax),%eax
  801bea:	eb 0e                	jmp    801bfa <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bec:	41                   	inc    %ecx
  801bed:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801bf3:	75 cf                	jne    801bc4 <ipc_find_env+0xc>
  801bf5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801bfa:	5b                   	pop    %ebx
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	57                   	push   %edi
  801c01:	56                   	push   %esi
  801c02:	53                   	push   %ebx
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c0c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c0f:	85 db                	test   %ebx,%ebx
  801c11:	75 05                	jne    801c18 <ipc_send+0x1b>
  801c13:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c18:	56                   	push   %esi
  801c19:	53                   	push   %ebx
  801c1a:	57                   	push   %edi
  801c1b:	ff 75 08             	pushl  0x8(%ebp)
  801c1e:	e8 5d ef ff ff       	call   800b80 <sys_ipc_try_send>
		if (r == 0) {		//success
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	74 20                	je     801c4a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c2a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c2d:	75 07                	jne    801c36 <ipc_send+0x39>
			sys_yield();
  801c2f:	e8 fc f0 ff ff       	call   800d30 <sys_yield>
  801c34:	eb e2                	jmp    801c18 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801c36:	83 ec 04             	sub    $0x4,%esp
  801c39:	68 38 24 80 00       	push   $0x802438
  801c3e:	6a 41                	push   $0x41
  801c40:	68 5c 24 80 00       	push   $0x80245c
  801c45:	e8 9a e5 ff ff       	call   8001e4 <_panic>
		}
	}
}
  801c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c60:	85 c0                	test   %eax,%eax
  801c62:	75 05                	jne    801c69 <ipc_recv+0x17>
  801c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	50                   	push   %eax
  801c6d:	e8 cd ee ff ff       	call   800b3f <sys_ipc_recv>
	if (r < 0) {				
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	79 16                	jns    801c8f <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801c79:	85 db                	test   %ebx,%ebx
  801c7b:	74 06                	je     801c83 <ipc_recv+0x31>
  801c7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801c83:	85 f6                	test   %esi,%esi
  801c85:	74 2c                	je     801cb3 <ipc_recv+0x61>
  801c87:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c8d:	eb 24                	jmp    801cb3 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801c8f:	85 db                	test   %ebx,%ebx
  801c91:	74 0a                	je     801c9d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801c93:	a1 08 40 80 00       	mov    0x804008,%eax
  801c98:	8b 40 74             	mov    0x74(%eax),%eax
  801c9b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801c9d:	85 f6                	test   %esi,%esi
  801c9f:	74 0a                	je     801cab <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801ca1:	a1 08 40 80 00       	mov    0x804008,%eax
  801ca6:	8b 40 78             	mov    0x78(%eax),%eax
  801ca9:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801cab:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801cb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    
	...

00801cbc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	c1 e8 16             	shr    $0x16,%eax
  801cc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cce:	a8 01                	test   $0x1,%al
  801cd0:	74 20                	je     801cf2 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cd2:	89 d0                	mov    %edx,%eax
  801cd4:	c1 e8 0c             	shr    $0xc,%eax
  801cd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cde:	a8 01                	test   $0x1,%al
  801ce0:	74 10                	je     801cf2 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ce2:	c1 e8 0c             	shr    $0xc,%eax
  801ce5:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801cec:	ef 
  801ced:	0f b7 c0             	movzwl %ax,%eax
  801cf0:	eb 05                	jmp    801cf7 <pageref+0x3b>
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    
  801cf9:	00 00                	add    %al,(%eax)
	...

00801cfc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	57                   	push   %edi
  801d00:	56                   	push   %esi
  801d01:	83 ec 28             	sub    $0x28,%esp
  801d04:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d0b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801d12:	8b 45 10             	mov    0x10(%ebp),%eax
  801d15:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801d1b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801d1d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801d25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d28:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d2b:	85 ff                	test   %edi,%edi
  801d2d:	75 21                	jne    801d50 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801d2f:	39 d1                	cmp    %edx,%ecx
  801d31:	76 49                	jbe    801d7c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d33:	f7 f1                	div    %ecx
  801d35:	89 c1                	mov    %eax,%ecx
  801d37:	31 c0                	xor    %eax,%eax
  801d39:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d3c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801d3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d42:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d45:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d48:	83 c4 28             	add    $0x28,%esp
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    
  801d4f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d50:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801d53:	0f 87 97 00 00 00    	ja     801df0 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d59:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d5c:	83 f0 1f             	xor    $0x1f,%eax
  801d5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d62:	75 34                	jne    801d98 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d64:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801d67:	72 08                	jb     801d71 <__udivdi3+0x75>
  801d69:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801d6c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801d6f:	77 7f                	ja     801df0 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d71:	b9 01 00 00 00       	mov    $0x1,%ecx
  801d76:	31 c0                	xor    %eax,%eax
  801d78:	eb c2                	jmp    801d3c <__udivdi3+0x40>
  801d7a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	74 79                	je     801dfc <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d83:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d86:	89 fa                	mov    %edi,%edx
  801d88:	f7 f1                	div    %ecx
  801d8a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d8f:	f7 f1                	div    %ecx
  801d91:	89 c1                	mov    %eax,%ecx
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	eb a5                	jmp    801d3c <__udivdi3+0x40>
  801d97:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d98:	b8 20 00 00 00       	mov    $0x20,%eax
  801d9d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801da0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801da3:	89 fa                	mov    %edi,%edx
  801da5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801da8:	d3 e2                	shl    %cl,%edx
  801daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dad:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801db0:	d3 e8                	shr    %cl,%eax
  801db2:	89 d7                	mov    %edx,%edi
  801db4:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801db6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801db9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801dbc:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dbe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dc1:	d3 e0                	shl    %cl,%eax
  801dc3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801dc6:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801dc9:	d3 ea                	shr    %cl,%edx
  801dcb:	09 d0                	or     %edx,%eax
  801dcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dd3:	d3 ea                	shr    %cl,%edx
  801dd5:	f7 f7                	div    %edi
  801dd7:	89 d7                	mov    %edx,%edi
  801dd9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801ddc:	f7 e6                	mul    %esi
  801dde:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801de0:	39 d7                	cmp    %edx,%edi
  801de2:	72 38                	jb     801e1c <__udivdi3+0x120>
  801de4:	74 27                	je     801e0d <__udivdi3+0x111>
  801de6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801de9:	31 c0                	xor    %eax,%eax
  801deb:	e9 4c ff ff ff       	jmp    801d3c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801df0:	31 c9                	xor    %ecx,%ecx
  801df2:	31 c0                	xor    %eax,%eax
  801df4:	e9 43 ff ff ff       	jmp    801d3c <__udivdi3+0x40>
  801df9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	f7 75 f4             	divl   -0xc(%ebp)
  801e06:	89 c1                	mov    %eax,%ecx
  801e08:	e9 76 ff ff ff       	jmp    801d83 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e10:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e13:	d3 e0                	shl    %cl,%eax
  801e15:	39 f0                	cmp    %esi,%eax
  801e17:	73 cd                	jae    801de6 <__udivdi3+0xea>
  801e19:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e1c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801e1f:	49                   	dec    %ecx
  801e20:	31 c0                	xor    %eax,%eax
  801e22:	e9 15 ff ff ff       	jmp    801d3c <__udivdi3+0x40>
	...

00801e28 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	57                   	push   %edi
  801e2c:	56                   	push   %esi
  801e2d:	83 ec 30             	sub    $0x30,%esp
  801e30:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801e37:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e44:	8b 45 10             	mov    0x10(%ebp),%eax
  801e47:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801e4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e4d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801e4f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801e52:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801e55:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e58:	85 d2                	test   %edx,%edx
  801e5a:	75 1c                	jne    801e78 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801e5c:	89 fa                	mov    %edi,%edx
  801e5e:	39 f8                	cmp    %edi,%eax
  801e60:	0f 86 c2 00 00 00    	jbe    801f28 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e66:	89 f0                	mov    %esi,%eax
  801e68:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801e6a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801e6d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e74:	eb 12                	jmp    801e88 <__umoddi3+0x60>
  801e76:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e78:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e7b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801e7e:	76 18                	jbe    801e98 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801e80:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801e83:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e86:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e88:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801e8e:	83 c4 30             	add    $0x30,%esp
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    
  801e95:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e98:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801e9c:	83 f0 1f             	xor    $0x1f,%eax
  801e9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ea2:	0f 84 ac 00 00 00    	je     801f54 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea8:	b8 20 00 00 00       	mov    $0x20,%eax
  801ead:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801eb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eb3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801eb6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801eb9:	d3 e2                	shl    %cl,%edx
  801ebb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ebe:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801ec1:	d3 e8                	shr    %cl,%eax
  801ec3:	89 d6                	mov    %edx,%esi
  801ec5:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  801ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801eca:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801ecd:	d3 e0                	shl    %cl,%eax
  801ecf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ed2:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801ed5:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ed7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eda:	d3 e0                	shl    %cl,%eax
  801edc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801edf:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801ee2:	d3 ea                	shr    %cl,%edx
  801ee4:	09 d0                	or     %edx,%eax
  801ee6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801ee9:	d3 ea                	shr    %cl,%edx
  801eeb:	f7 f6                	div    %esi
  801eed:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801ef0:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ef3:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801ef6:	0f 82 8d 00 00 00    	jb     801f89 <__umoddi3+0x161>
  801efc:	0f 84 91 00 00 00    	je     801f93 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f02:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f05:	29 c7                	sub    %eax,%edi
  801f07:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f09:	89 f2                	mov    %esi,%edx
  801f0b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801f0e:	d3 e2                	shl    %cl,%edx
  801f10:	89 f8                	mov    %edi,%eax
  801f12:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801f15:	d3 e8                	shr    %cl,%eax
  801f17:	09 c2                	or     %eax,%edx
  801f19:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801f1c:	d3 ee                	shr    %cl,%esi
  801f1e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801f21:	e9 62 ff ff ff       	jmp    801e88 <__umoddi3+0x60>
  801f26:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	74 15                	je     801f44 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f32:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f35:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	f7 f1                	div    %ecx
  801f3c:	e9 29 ff ff ff       	jmp    801e6a <__umoddi3+0x42>
  801f41:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f44:	b8 01 00 00 00       	mov    $0x1,%eax
  801f49:	31 d2                	xor    %edx,%edx
  801f4b:	f7 75 ec             	divl   -0x14(%ebp)
  801f4e:	89 c1                	mov    %eax,%ecx
  801f50:	eb dd                	jmp    801f2f <__umoddi3+0x107>
  801f52:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f57:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801f5a:	72 19                	jb     801f75 <__umoddi3+0x14d>
  801f5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f5f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801f62:	76 11                	jbe    801f75 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f67:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801f6a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f6d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801f70:	e9 13 ff ff ff       	jmp    801e88 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f75:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801f7e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801f84:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801f87:	eb db                	jmp    801f64 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f89:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801f8c:	19 f2                	sbb    %esi,%edx
  801f8e:	e9 6f ff ff ff       	jmp    801f02 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f93:	39 c7                	cmp    %eax,%edi
  801f95:	72 f2                	jb     801f89 <__umoddi3+0x161>
  801f97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f9a:	e9 63 ff ff ff       	jmp    801f02 <__umoddi3+0xda>
