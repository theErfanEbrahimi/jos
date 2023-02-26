
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 a7 00 00 00       	call   8000d8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	68 c0 0f 80 00       	push   $0x800fc0
  80003f:	e8 99 01 00 00       	call   8001dd <cprintf>
  800044:	b8 00 00 00 00       	mov    $0x0,%eax
  800049:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  80004c:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800053:	00 
  800054:	74 12                	je     800068 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800056:	50                   	push   %eax
  800057:	68 3b 10 80 00       	push   $0x80103b
  80005c:	6a 11                	push   $0x11
  80005e:	68 58 10 80 00       	push   $0x801058
  800063:	e8 d4 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800068:	40                   	inc    %eax
  800069:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006e:	75 dc                	jne    80004c <umain+0x18>
  800070:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800075:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007c:	40                   	inc    %eax
  80007d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800082:	75 f1                	jne    800075 <umain+0x41>
  800084:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800089:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800090:	74 12                	je     8000a4 <umain+0x70>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800092:	50                   	push   %eax
  800093:	68 e0 0f 80 00       	push   $0x800fe0
  800098:	6a 16                	push   $0x16
  80009a:	68 58 10 80 00       	push   $0x801058
  80009f:	e8 98 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a4:	40                   	inc    %eax
  8000a5:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000aa:	75 dd                	jne    800089 <umain+0x55>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 08 10 80 00       	push   $0x801008
  8000b4:	e8 24 01 00 00       	call   8001dd <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c0:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c3:	83 c4 0c             	add    $0xc,%esp
  8000c6:	68 67 10 80 00       	push   $0x801067
  8000cb:	6a 1a                	push   $0x1a
  8000cd:	68 58 10 80 00       	push   $0x801058
  8000d2:	e8 65 00 00 00       	call   80013c <_panic>
	...

008000d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000e3:	e8 bf 0b 00 00       	call   800ca7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000f4:	c1 e0 07             	shl    $0x7,%eax
  8000f7:	29 d0                	sub    %edx,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 f6                	test   %esi,%esi
  800105:	7e 07                	jle    80010e <libmain+0x36>
		binaryname = argv[0];
  800107:	8b 03                	mov    (%ebx),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	53                   	push   %ebx
  800112:	56                   	push   %esi
  800113:	e8 1c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800118:	e8 0b 00 00 00       	call   800128 <exit>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	c9                   	leave  
  800126:	c3                   	ret    
	...

00800128 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80012e:	6a 00                	push   $0x0
  800130:	e8 91 0b 00 00       	call   800cc6 <sys_env_destroy>
  800135:	83 c4 10             	add    $0x10,%esp
}
  800138:	c9                   	leave  
  800139:	c3                   	ret    
	...

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	53                   	push   %ebx
  800140:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800143:	8d 45 14             	lea    0x14(%ebp),%eax
  800146:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800149:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80014f:	e8 53 0b 00 00       	call   800ca7 <sys_getenvid>
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	ff 75 0c             	pushl  0xc(%ebp)
  80015a:	ff 75 08             	pushl  0x8(%ebp)
  80015d:	53                   	push   %ebx
  80015e:	50                   	push   %eax
  80015f:	68 88 10 80 00       	push   $0x801088
  800164:	e8 74 00 00 00       	call   8001dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800169:	83 c4 18             	add    $0x18,%esp
  80016c:	ff 75 f8             	pushl  -0x8(%ebp)
  80016f:	ff 75 10             	pushl  0x10(%ebp)
  800172:	e8 15 00 00 00       	call   80018c <vcprintf>
	cprintf("\n");
  800177:	c7 04 24 56 10 80 00 	movl   $0x801056,(%esp)
  80017e:	e8 5a 00 00 00       	call   8001dd <cprintf>
  800183:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800186:	cc                   	int3   
  800187:	eb fd                	jmp    800186 <_panic+0x4a>
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800195:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80019c:	00 00 00 
	b.cnt = 0;
  80019f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8001a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	50                   	push   %eax
  8001b6:	68 f4 01 80 00       	push   $0x8001f4
  8001bb:	e8 70 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c0:	83 c4 08             	add    $0x8,%esp
  8001c3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001c9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	e8 9e 08 00 00       	call   800a73 <sys_cputs>
  8001d5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001e9:	50                   	push   %eax
  8001ea:	ff 75 08             	pushl  0x8(%ebp)
  8001ed:	e8 9a ff ff ff       	call   80018c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	40                   	inc    %eax
  800208:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	75 1a                	jne    80022b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	68 ff 00 00 00       	push   $0xff
  800219:	8d 43 08             	lea    0x8(%ebx),%eax
  80021c:	50                   	push   %eax
  80021d:	e8 51 08 00 00       	call   800a73 <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800228:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022b:	ff 43 04             	incl   0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    
	...

00800234 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 1c             	sub    $0x1c,%esp
  80023d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800240:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80024f:	8b 55 10             	mov    0x10(%ebp),%edx
  800252:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	89 d6                	mov    %edx,%esi
  800257:	bf 00 00 00 00       	mov    $0x0,%edi
  80025c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80025f:	72 04                	jb     800265 <printnum+0x31>
  800261:	39 c2                	cmp    %eax,%edx
  800263:	77 3f                	ja     8002a4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80026e:	50                   	push   %eax
  80026f:	52                   	push   %edx
  800270:	83 ec 08             	sub    $0x8,%esp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	e8 88 0a 00 00       	call   800d08 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800288:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80028b:	e8 a4 ff ff ff       	call   800234 <printnum>
  800290:	83 c4 20             	add    $0x20,%esp
  800293:	eb 14                	jmp    8002a9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	ff 75 e8             	pushl  -0x18(%ebp)
  80029b:	ff 75 18             	pushl  0x18(%ebp)
  80029e:	ff 55 ec             	call   *-0x14(%ebp)
  8002a1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a4:	4b                   	dec    %ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f ec                	jg     800295 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	ff 75 e8             	pushl  -0x18(%ebp)
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	e8 75 0b 00 00       	call   800e34 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 ab 10 80 00 	movsbl 0x8010ab(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff 55 ec             	call   *-0x14(%ebp)
  8002cd:	83 c4 10             	add    $0x10,%esp
}
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002dd:	83 fa 01             	cmp    $0x1,%edx
  8002e0:	7e 0e                	jle    8002f0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 42 08             	lea    0x8(%edx),%eax
  8002e7:	89 01                	mov    %eax,(%ecx)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ee:	eb 22                	jmp    800312 <getuint+0x3a>
	else if (lflag)
  8002f0:	85 d2                	test   %edx,%edx
  8002f2:	74 10                	je     800304 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 42 04             	lea    0x4(%edx),%eax
  8002f9:	89 01                	mov    %eax,(%ecx)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	eb 0e                	jmp    800312 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 42 04             	lea    0x4(%edx),%eax
  800309:	89 01                	mov    %eax,(%ecx)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80031a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80031d:	8b 11                	mov    (%ecx),%edx
  80031f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800322:	73 0a                	jae    80032e <sprintputch+0x1a>
		*b->buf++ = ch;
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	88 02                	mov    %al,(%edx)
  800329:	8d 42 01             	lea    0x1(%edx),%eax
  80032c:	89 01                	mov    %eax,(%ecx)
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 3c             	sub    $0x3c,%esp
  800339:	8b 75 08             	mov    0x8(%ebp),%esi
  80033c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80033f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800342:	eb 1a                	jmp    80035e <vprintfmt+0x2e>
  800344:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800347:	eb 15                	jmp    80035e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800349:	84 c0                	test   %al,%al
  80034b:	0f 84 15 03 00 00    	je     800666 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	57                   	push   %edi
  800355:	0f b6 c0             	movzbl %al,%eax
  800358:	50                   	push   %eax
  800359:	ff d6                	call   *%esi
  80035b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035e:	8a 03                	mov    (%ebx),%al
  800360:	43                   	inc    %ebx
  800361:	3c 25                	cmp    $0x25,%al
  800363:	75 e4                	jne    800349 <vprintfmt+0x19>
  800365:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80036c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800373:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80037a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800381:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800385:	eb 0a                	jmp    800391 <vprintfmt+0x61>
  800387:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80038e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8a 03                	mov    (%ebx),%al
  800393:	0f b6 d0             	movzbl %al,%edx
  800396:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800399:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 9c 02 00 00    	ja     800643 <vprintfmt+0x313>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  8003b1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8003b5:	eb d7                	jmp    80038e <vprintfmt+0x5e>
  8003b7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8003bb:	eb d1                	jmp    80038e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8003bd:	89 d9                	mov    %ebx,%ecx
  8003bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003c9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003cc:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003d3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003d7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003d8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003db:	83 f8 09             	cmp    $0x9,%eax
  8003de:	77 21                	ja     800401 <vprintfmt+0xd1>
  8003e0:	eb e4                	jmp    8003c6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e2:	8b 55 14             	mov    0x14(%ebp),%edx
  8003e5:	8d 42 04             	lea    0x4(%edx),%eax
  8003e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8003eb:	8b 12                	mov    (%edx),%edx
  8003ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003f0:	eb 12                	jmp    800404 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003f6:	79 96                	jns    80038e <vprintfmt+0x5e>
  8003f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ff:	eb 8d                	jmp    80038e <vprintfmt+0x5e>
  800401:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800404:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800408:	79 84                	jns    80038e <vprintfmt+0x5e>
  80040a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800417:	e9 72 ff ff ff       	jmp    80038e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041c:	ff 45 d4             	incl   -0x2c(%ebp)
  80041f:	e9 6a ff ff ff       	jmp    80038e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 55 14             	mov    0x14(%ebp),%edx
  800427:	8d 42 04             	lea    0x4(%edx),%eax
  80042a:	89 45 14             	mov    %eax,0x14(%ebp)
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	57                   	push   %edi
  800431:	ff 32                	pushl  (%edx)
  800433:	ff d6                	call   *%esi
			break;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	e9 07 ff ff ff       	jmp    800344 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043d:	8b 55 14             	mov    0x14(%ebp),%edx
  800440:	8d 42 04             	lea    0x4(%edx),%eax
  800443:	89 45 14             	mov    %eax,0x14(%ebp)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	79 02                	jns    80044e <vprintfmt+0x11e>
  80044c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044e:	83 f8 0f             	cmp    $0xf,%eax
  800451:	7f 0b                	jg     80045e <vprintfmt+0x12e>
  800453:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  80045a:	85 d2                	test   %edx,%edx
  80045c:	75 15                	jne    800473 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80045e:	50                   	push   %eax
  80045f:	68 bc 10 80 00       	push   $0x8010bc
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	e8 6e 02 00 00       	call   8006d9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	e9 d1 fe ff ff       	jmp    800344 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800473:	52                   	push   %edx
  800474:	68 c5 10 80 00       	push   $0x8010c5
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	e8 59 02 00 00       	call   8006d9 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	e9 bc fe ff ff       	jmp    800344 <vprintfmt+0x14>
  800488:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80048b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80048e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 55 14             	mov    0x14(%ebp),%edx
  800494:	8d 42 04             	lea    0x4(%edx),%eax
  800497:	89 45 14             	mov    %eax,0x14(%ebp)
  80049a:	8b 1a                	mov    (%edx),%ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	75 05                	jne    8004a5 <vprintfmt+0x175>
  8004a0:	bb c8 10 80 00       	mov    $0x8010c8,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004a5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8004a9:	7e 66                	jle    800511 <vprintfmt+0x1e1>
  8004ab:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8004af:	74 60                	je     800511 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	51                   	push   %ecx
  8004b5:	53                   	push   %ebx
  8004b6:	e8 57 02 00 00       	call   800712 <strnlen>
  8004bb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004ca:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004cd:	eb 0f                	jmp    8004de <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	57                   	push   %edi
  8004d3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	ff 4d d8             	decl   -0x28(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e2:	7f eb                	jg     8004cf <vprintfmt+0x19f>
  8004e4:	eb 2b                	jmp    800511 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ed:	74 15                	je     800504 <vprintfmt+0x1d4>
  8004ef:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004f2:	83 f8 5e             	cmp    $0x5e,%eax
  8004f5:	76 0d                	jbe    800504 <vprintfmt+0x1d4>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	57                   	push   %edi
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	eb 0a                	jmp    80050e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	57                   	push   %edi
  800508:	52                   	push   %edx
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	ff 4d d8             	decl   -0x28(%ebp)
  800511:	8a 03                	mov    (%ebx),%al
  800513:	43                   	inc    %ebx
  800514:	84 c0                	test   %al,%al
  800516:	74 1b                	je     800533 <vprintfmt+0x203>
  800518:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051c:	78 c8                	js     8004e6 <vprintfmt+0x1b6>
  80051e:	ff 4d dc             	decl   -0x24(%ebp)
  800521:	79 c3                	jns    8004e6 <vprintfmt+0x1b6>
  800523:	eb 0e                	jmp    800533 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	57                   	push   %edi
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052d:	ff 4d d8             	decl   -0x28(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800537:	7f ec                	jg     800525 <vprintfmt+0x1f5>
  800539:	e9 06 fe ff ff       	jmp    800344 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800542:	7e 10                	jle    800554 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800544:	8b 55 14             	mov    0x14(%ebp),%edx
  800547:	8d 42 08             	lea    0x8(%edx),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	8b 02                	mov    (%edx),%eax
  80054f:	8b 52 04             	mov    0x4(%edx),%edx
  800552:	eb 20                	jmp    800574 <vprintfmt+0x244>
	else if (lflag)
  800554:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800558:	74 0e                	je     800568 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 00                	mov    (%eax),%eax
  800565:	99                   	cltd   
  800566:	eb 0c                	jmp    800574 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800574:	89 d1                	mov    %edx,%ecx
  800576:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800578:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	78 0a                	js     80058c <vprintfmt+0x25c>
  800582:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800587:	e9 89 00 00 00       	jmp    800615 <vprintfmt+0x2e5>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	57                   	push   %edi
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800597:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059a:	f7 da                	neg    %edx
  80059c:	83 d1 00             	adc    $0x0,%ecx
  80059f:	f7 d9                	neg    %ecx
  8005a1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	eb 6a                	jmp    800615 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b1:	e8 22 fd ff ff       	call   8002d8 <getuint>
  8005b6:	89 d1                	mov    %edx,%ecx
  8005b8:	89 c2                	mov    %eax,%edx
  8005ba:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005bf:	eb 54                	jmp    800615 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c7:	e8 0c fd ff ff       	call   8002d8 <getuint>
  8005cc:	89 d1                	mov    %edx,%ecx
  8005ce:	89 c2                	mov    %eax,%edx
  8005d0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005d5:	eb 3e                	jmp    800615 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	57                   	push   %edi
  8005db:	6a 30                	push   $0x30
  8005dd:	ff d6                	call   *%esi
			putch('x', putdat);
  8005df:	83 c4 08             	add    $0x8,%esp
  8005e2:	57                   	push   %edi
  8005e3:	6a 78                	push   $0x78
  8005e5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e7:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ea:	8d 42 04             	lea    0x4(%edx),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f0:	8b 12                	mov    (%edx),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	eb 14                	jmp    800615 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800601:	8d 45 14             	lea    0x14(%ebp),%eax
  800604:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800607:	e8 cc fc ff ff       	call   8002d8 <getuint>
  80060c:	89 d1                	mov    %edx,%ecx
  80060e:	89 c2                	mov    %eax,%edx
  800610:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800615:	83 ec 0c             	sub    $0xc,%esp
  800618:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80061c:	50                   	push   %eax
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	53                   	push   %ebx
  800621:	51                   	push   %ecx
  800622:	52                   	push   %edx
  800623:	89 fa                	mov    %edi,%edx
  800625:	89 f0                	mov    %esi,%eax
  800627:	e8 08 fc ff ff       	call   800234 <printnum>
			break;
  80062c:	83 c4 20             	add    $0x20,%esp
  80062f:	e9 10 fd ff ff       	jmp    800344 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	57                   	push   %edi
  800638:	52                   	push   %edx
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	e9 01 fd ff ff       	jmp    800344 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	57                   	push   %edi
  800647:	6a 25                	push   $0x25
  800649:	ff d6                	call   *%esi
  80064b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80064e:	83 ea 02             	sub    $0x2,%edx
  800651:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800654:	8a 02                	mov    (%edx),%al
  800656:	4a                   	dec    %edx
  800657:	3c 25                	cmp    $0x25,%al
  800659:	75 f9                	jne    800654 <vprintfmt+0x324>
  80065b:	83 c2 02             	add    $0x2,%edx
  80065e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800661:	e9 de fc ff ff       	jmp    800344 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 18             	sub    $0x18,%esp
  800674:	8b 55 08             	mov    0x8(%ebp),%edx
  800677:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80067a:	85 d2                	test   %edx,%edx
  80067c:	74 37                	je     8006b5 <vsnprintf+0x47>
  80067e:	85 c0                	test   %eax,%eax
  800680:	7e 33                	jle    8006b5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800682:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800689:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80068d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800690:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800693:	ff 75 14             	pushl  0x14(%ebp)
  800696:	ff 75 10             	pushl  0x10(%ebp)
  800699:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069c:	50                   	push   %eax
  80069d:	68 14 03 80 00       	push   $0x800314
  8006a2:	e8 89 fc ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	eb 05                	jmp    8006ba <vsnprintf+0x4c>
  8006b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 10             	pushl  0x10(%ebp)
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 97 ff ff ff       	call   80066e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006df:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006e5:	50                   	push   %eax
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	ff 75 08             	pushl  0x8(%ebp)
  8006ef:	e8 3c fc ff ff       	call   800330 <vprintfmt>
	va_end(ap);
  8006f4:	83 c4 10             	add    $0x10,%esp
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    
  8006f9:	00 00                	add    %al,(%eax)
	...

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	eb 01                	jmp    80070a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800709:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80070e:	75 f9                	jne    800709 <strlen+0xd>
		n++;
	return n;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	eb 01                	jmp    800723 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800722:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	39 d0                	cmp    %edx,%eax
  800725:	74 06                	je     80072d <strnlen+0x1b>
  800727:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80072b:	75 f5                	jne    800722 <strnlen+0x10>
		n++;
	return n;
}
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800738:	8a 01                	mov    (%ecx),%al
  80073a:	88 02                	mov    %al,(%edx)
  80073c:	42                   	inc    %edx
  80073d:	41                   	inc    %ecx
  80073e:	84 c0                	test   %al,%al
  800740:	75 f6                	jne    800738 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074e:	53                   	push   %ebx
  80074f:	e8 a8 ff ff ff       	call   8006fc <strlen>
	strcpy(dst + len, src);
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80075a:	50                   	push   %eax
  80075b:	e8 cf ff ff ff       	call   80072f <strcpy>
	return dst;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800772:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800775:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077a:	eb 0c                	jmp    800788 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80077c:	8a 02                	mov    (%edx),%al
  80077e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800781:	80 3a 01             	cmpb   $0x1,(%edx)
  800784:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	41                   	inc    %ecx
  800788:	39 d9                	cmp    %ebx,%ecx
  80078a:	75 f0                	jne    80077c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078c:	89 f0                	mov    %esi,%eax
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	85 c9                	test   %ecx,%ecx
  8007a2:	75 04                	jne    8007a8 <strlcpy+0x16>
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	eb 14                	jmp    8007bc <strlcpy+0x2a>
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	eb 04                	jmp    8007b0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ac:	88 10                	mov    %dl,(%eax)
  8007ae:	40                   	inc    %eax
  8007af:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b0:	49                   	dec    %ecx
  8007b1:	74 06                	je     8007b9 <strlcpy+0x27>
  8007b3:	8a 13                	mov    (%ebx),%dl
  8007b5:	84 d2                	test   %dl,%dl
  8007b7:	75 f3                	jne    8007ac <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 00 00             	movb   $0x0,(%eax)
  8007bc:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	eb 02                	jmp    8007cf <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007cd:	42                   	inc    %edx
  8007ce:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cf:	8a 02                	mov    (%edx),%al
  8007d1:	84 c0                	test   %al,%al
  8007d3:	74 04                	je     8007d9 <strcmp+0x17>
  8007d5:	3a 01                	cmp    (%ecx),%al
  8007d7:	74 f4                	je     8007cd <strcmp+0xb>
  8007d9:	0f b6 c0             	movzbl %al,%eax
  8007dc:	0f b6 11             	movzbl (%ecx),%edx
  8007df:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f0:	eb 03                	jmp    8007f5 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007f2:	4a                   	dec    %edx
  8007f3:	41                   	inc    %ecx
  8007f4:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	75 07                	jne    800800 <strncmp+0x1d>
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	eb 14                	jmp    800814 <strncmp+0x31>
  800800:	8a 01                	mov    (%ecx),%al
  800802:	84 c0                	test   %al,%al
  800804:	74 04                	je     80080a <strncmp+0x27>
  800806:	3a 03                	cmp    (%ebx),%al
  800808:	74 e8                	je     8007f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080a:	0f b6 d0             	movzbl %al,%edx
  80080d:	0f b6 03             	movzbl (%ebx),%eax
  800810:	29 c2                	sub    %eax,%edx
  800812:	89 d0                	mov    %edx,%eax
}
  800814:	5b                   	pop    %ebx
  800815:	c9                   	leave  
  800816:	c3                   	ret    

00800817 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800820:	eb 05                	jmp    800827 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800822:	38 ca                	cmp    %cl,%dl
  800824:	74 0c                	je     800832 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800826:	40                   	inc    %eax
  800827:	8a 10                	mov    (%eax),%dl
  800829:	84 d2                	test   %dl,%dl
  80082b:	75 f5                	jne    800822 <strchr+0xb>
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80083d:	eb 05                	jmp    800844 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80083f:	38 ca                	cmp    %cl,%dl
  800841:	74 07                	je     80084a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800843:	40                   	inc    %eax
  800844:	8a 10                	mov    (%eax),%dl
  800846:	84 d2                	test   %dl,%dl
  800848:	75 f5                	jne    80083f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 7d 08             	mov    0x8(%ebp),%edi
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80085b:	85 db                	test   %ebx,%ebx
  80085d:	74 36                	je     800895 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800865:	75 29                	jne    800890 <memset+0x44>
  800867:	f6 c3 03             	test   $0x3,%bl
  80086a:	75 24                	jne    800890 <memset+0x44>
		c &= 0xFF;
  80086c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80086f:	89 d6                	mov    %edx,%esi
  800871:	c1 e6 08             	shl    $0x8,%esi
  800874:	89 d0                	mov    %edx,%eax
  800876:	c1 e0 18             	shl    $0x18,%eax
  800879:	89 d1                	mov    %edx,%ecx
  80087b:	c1 e1 10             	shl    $0x10,%ecx
  80087e:	09 c8                	or     %ecx,%eax
  800880:	09 c2                	or     %eax,%edx
  800882:	89 f0                	mov    %esi,%eax
  800884:	09 d0                	or     %edx,%eax
  800886:	89 d9                	mov    %ebx,%ecx
  800888:	c1 e9 02             	shr    $0x2,%ecx
  80088b:	fc                   	cld    
  80088c:	f3 ab                	rep stos %eax,%es:(%edi)
  80088e:	eb 05                	jmp    800895 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800890:	89 d9                	mov    %ebx,%ecx
  800892:	fc                   	cld    
  800893:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800895:	89 f8                	mov    %edi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	c9                   	leave  
  80089b:	c3                   	ret    

0080089c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8008a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008aa:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008ac:	39 c6                	cmp    %eax,%esi
  8008ae:	73 36                	jae    8008e6 <memmove+0x4a>
  8008b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b3:	39 d0                	cmp    %edx,%eax
  8008b5:	73 2f                	jae    8008e6 <memmove+0x4a>
		s += n;
		d += n;
  8008b7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ba:	f6 c2 03             	test   $0x3,%dl
  8008bd:	75 1b                	jne    8008da <memmove+0x3e>
  8008bf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c5:	75 13                	jne    8008da <memmove+0x3e>
  8008c7:	f6 c1 03             	test   $0x3,%cl
  8008ca:	75 0e                	jne    8008da <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008cc:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
  8008d5:	fd                   	std    
  8008d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d8:	eb 09                	jmp    8008e3 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008da:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008dd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e0:	fd                   	std    
  8008e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e3:	fc                   	cld    
  8008e4:	eb 20                	jmp    800906 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ec:	75 15                	jne    800903 <memmove+0x67>
  8008ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f4:	75 0d                	jne    800903 <memmove+0x67>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 08                	jne    800903 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 03                	jmp    800906 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800903:	fc                   	cld    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	ff 75 0c             	pushl  0xc(%ebp)
  800913:	ff 75 08             	pushl  0x8(%ebp)
  800916:	e8 81 ff ff ff       	call   80089c <memmove>
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	83 ec 04             	sub    $0x4,%esp
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	eb 1b                	jmp    80094a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80092f:	8a 1a                	mov    (%edx),%bl
  800931:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800934:	8a 19                	mov    (%ecx),%bl
  800936:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800939:	74 0d                	je     800948 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80093f:	0f b6 c3             	movzbl %bl,%eax
  800942:	29 c2                	sub    %eax,%edx
  800944:	89 d0                	mov    %edx,%eax
  800946:	eb 0d                	jmp    800955 <memcmp+0x38>
		s1++, s2++;
  800948:	42                   	inc    %edx
  800949:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	48                   	dec    %eax
  80094b:	83 f8 ff             	cmp    $0xffffffff,%eax
  80094e:	75 df                	jne    80092f <memcmp+0x12>
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800955:	83 c4 04             	add    $0x4,%esp
  800958:	5b                   	pop    %ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800964:	89 c2                	mov    %eax,%edx
  800966:	03 55 10             	add    0x10(%ebp),%edx
  800969:	eb 05                	jmp    800970 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096b:	38 08                	cmp    %cl,(%eax)
  80096d:	74 05                	je     800974 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	40                   	inc    %eax
  800970:	39 d0                	cmp    %edx,%eax
  800972:	72 f7                	jb     80096b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	83 ec 04             	sub    $0x4,%esp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 75 10             	mov    0x10(%ebp),%esi
  800985:	eb 01                	jmp    800988 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800987:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800988:	8a 01                	mov    (%ecx),%al
  80098a:	3c 20                	cmp    $0x20,%al
  80098c:	74 f9                	je     800987 <strtol+0x11>
  80098e:	3c 09                	cmp    $0x9,%al
  800990:	74 f5                	je     800987 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800992:	3c 2b                	cmp    $0x2b,%al
  800994:	75 0a                	jne    8009a0 <strtol+0x2a>
		s++;
  800996:	41                   	inc    %ecx
  800997:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80099e:	eb 17                	jmp    8009b7 <strtol+0x41>
	else if (*s == '-')
  8009a0:	3c 2d                	cmp    $0x2d,%al
  8009a2:	74 09                	je     8009ad <strtol+0x37>
  8009a4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009ab:	eb 0a                	jmp    8009b7 <strtol+0x41>
		s++, neg = 1;
  8009ad:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009b0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b7:	85 f6                	test   %esi,%esi
  8009b9:	74 05                	je     8009c0 <strtol+0x4a>
  8009bb:	83 fe 10             	cmp    $0x10,%esi
  8009be:	75 1a                	jne    8009da <strtol+0x64>
  8009c0:	8a 01                	mov    (%ecx),%al
  8009c2:	3c 30                	cmp    $0x30,%al
  8009c4:	75 10                	jne    8009d6 <strtol+0x60>
  8009c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ca:	75 0a                	jne    8009d6 <strtol+0x60>
		s += 2, base = 16;
  8009cc:	83 c1 02             	add    $0x2,%ecx
  8009cf:	be 10 00 00 00       	mov    $0x10,%esi
  8009d4:	eb 04                	jmp    8009da <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009d6:	85 f6                	test   %esi,%esi
  8009d8:	74 07                	je     8009e1 <strtol+0x6b>
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 13                	jmp    8009f4 <strtol+0x7e>
  8009e1:	3c 30                	cmp    $0x30,%al
  8009e3:	74 07                	je     8009ec <strtol+0x76>
  8009e5:	be 0a 00 00 00       	mov    $0xa,%esi
  8009ea:	eb ee                	jmp    8009da <strtol+0x64>
		s++, base = 8;
  8009ec:	41                   	inc    %ecx
  8009ed:	be 08 00 00 00       	mov    $0x8,%esi
  8009f2:	eb e6                	jmp    8009da <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f4:	8a 11                	mov    (%ecx),%dl
  8009f6:	88 d3                	mov    %dl,%bl
  8009f8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	77 08                	ja     800a07 <strtol+0x91>
			dig = *s - '0';
  8009ff:	0f be c2             	movsbl %dl,%eax
  800a02:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a05:	eb 1c                	jmp    800a23 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a07:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a0a:	3c 19                	cmp    $0x19,%al
  800a0c:	77 08                	ja     800a16 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a0e:	0f be c2             	movsbl %dl,%eax
  800a11:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a14:	eb 0d                	jmp    800a23 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a16:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a19:	3c 19                	cmp    $0x19,%al
  800a1b:	77 15                	ja     800a32 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a1d:	0f be c2             	movsbl %dl,%eax
  800a20:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a23:	39 f2                	cmp    %esi,%edx
  800a25:	7d 0b                	jge    800a32 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a27:	41                   	inc    %ecx
  800a28:	89 f8                	mov    %edi,%eax
  800a2a:	0f af c6             	imul   %esi,%eax
  800a2d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a30:	eb c2                	jmp    8009f4 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a32:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a38:	74 05                	je     800a3f <strtol+0xc9>
		*endptr = (char *) s;
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a43:	74 04                	je     800a49 <strtol+0xd3>
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	f7 df                	neg    %edi
}
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	83 c4 04             	add    $0x4,%esp
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    
	...

00800a54 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	89 fa                	mov    %edi,%edx
  800a66:	89 f9                	mov    %edi,%ecx
  800a68:	89 fb                	mov    %edi,%ebx
  800a6a:	89 fe                	mov    %edi,%esi
  800a6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6e:	5b                   	pop    %ebx
  800a6f:	5e                   	pop    %esi
  800a70:	5f                   	pop    %edi
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	83 ec 04             	sub    $0x4,%esp
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	89 f8                	mov    %edi,%eax
  800a89:	89 fb                	mov    %edi,%ebx
  800a8b:	89 fe                	mov    %edi,%esi
  800a8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8f:	83 c4 04             	add    $0x4,%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aad:	89 f9                	mov    %edi,%ecx
  800aaf:	89 fb                	mov    %edi,%ebx
  800ab1:	89 fe                	mov    %edi,%esi
  800ab3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab5:	85 c0                	test   %eax,%eax
  800ab7:	7e 17                	jle    800ad0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	50                   	push   %eax
  800abd:	6a 0d                	push   $0xd
  800abf:	68 c0 13 80 00       	push   $0x8013c0
  800ac4:	6a 23                	push   $0x23
  800ac6:	68 dd 13 80 00       	push   $0x8013dd
  800acb:	e8 6c f6 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ae7:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800aef:	be 00 00 00 00       	mov    $0x0,%esi
  800af4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b14:	89 fb                	mov    %edi,%ebx
  800b16:	89 fe                	mov    %edi,%esi
  800b18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	7e 17                	jle    800b35 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	50                   	push   %eax
  800b22:	6a 0a                	push   $0xa
  800b24:	68 c0 13 80 00       	push   $0x8013c0
  800b29:	6a 23                	push   $0x23
  800b2b:	68 dd 13 80 00       	push   $0x8013dd
  800b30:	e8 07 f6 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800b51:	bf 00 00 00 00       	mov    $0x0,%edi
  800b56:	89 fb                	mov    %edi,%ebx
  800b58:	89 fe                	mov    %edi,%esi
  800b5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 09                	push   $0x9
  800b66:	68 c0 13 80 00       	push   $0x8013c0
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 dd 13 80 00       	push   $0x8013dd
  800b72:	e8 c5 f5 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b93:	bf 00 00 00 00       	mov    $0x0,%edi
  800b98:	89 fb                	mov    %edi,%ebx
  800b9a:	89 fe                	mov    %edi,%esi
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 08                	push   $0x8
  800ba8:	68 c0 13 80 00       	push   $0x8013c0
  800bad:	6a 23                	push   $0x23
  800baf:	68 dd 13 80 00       	push   $0x8013dd
  800bb4:	e8 83 f5 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bda:	89 fb                	mov    %edi,%ebx
  800bdc:	89 fe                	mov    %edi,%esi
  800bde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 c0 13 80 00       	push   $0x8013c0
  800bef:	6a 23                	push   $0x23
  800bf1:	68 dd 13 80 00       	push   $0x8013dd
  800bf6:	e8 41 f5 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c18:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 05                	push   $0x5
  800c2c:	68 c0 13 80 00       	push   $0x8013c0
  800c31:	6a 23                	push   $0x23
  800c33:	68 dd 13 80 00       	push   $0x8013dd
  800c38:	e8 ff f4 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	b8 04 00 00 00       	mov    $0x4,%eax
  800c5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c61:	89 fe                	mov    %edi,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 04                	push   $0x4
  800c6f:	68 c0 13 80 00       	push   $0x8013c0
  800c74:	6a 23                	push   $0x23
  800c76:	68 dd 13 80 00       	push   $0x8013dd
  800c7b:	e8 bc f4 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
  800c98:	89 fa                	mov    %edi,%edx
  800c9a:	89 f9                	mov    %edi,%ecx
  800c9c:	89 fb                	mov    %edi,%ebx
  800c9e:	89 fe                	mov    %edi,%esi
  800ca0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	89 fa                	mov    %edi,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 fb                	mov    %edi,%ebx
  800cbd:	89 fe                	mov    %edi,%esi
  800cbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdc:	89 f9                	mov    %edi,%ecx
  800cde:	89 fb                	mov    %edi,%ebx
  800ce0:	89 fe                	mov    %edi,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 03                	push   $0x3
  800cee:	68 c0 13 80 00       	push   $0x8013c0
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 dd 13 80 00       	push   $0x8013dd
  800cfa:	e8 3d f4 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    
	...

00800d08 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	83 ec 28             	sub    $0x28,%esp
  800d10:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800d17:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d21:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d27:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800d29:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800d31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d34:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d37:	85 ff                	test   %edi,%edi
  800d39:	75 21                	jne    800d5c <__udivdi3+0x54>
    {
      if (d0 > n1)
  800d3b:	39 d1                	cmp    %edx,%ecx
  800d3d:	76 49                	jbe    800d88 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d3f:	f7 f1                	div    %ecx
  800d41:	89 c1                	mov    %eax,%ecx
  800d43:	31 c0                	xor    %eax,%eax
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d48:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d4b:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d51:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d54:	83 c4 28             	add    $0x28,%esp
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    
  800d5b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d5c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d5f:	0f 87 97 00 00 00    	ja     800dfc <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d65:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d68:	83 f0 1f             	xor    $0x1f,%eax
  800d6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d6e:	75 34                	jne    800da4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d70:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d73:	72 08                	jb     800d7d <__udivdi3+0x75>
  800d75:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d78:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d7b:	77 7f                	ja     800dfc <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d7d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d82:	31 c0                	xor    %eax,%eax
  800d84:	eb c2                	jmp    800d48 <__udivdi3+0x40>
  800d86:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	74 79                	je     800e08 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d92:	89 fa                	mov    %edi,%edx
  800d94:	f7 f1                	div    %ecx
  800d96:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c1                	mov    %eax,%ecx
  800d9f:	89 f0                	mov    %esi,%eax
  800da1:	eb a5                	jmp    800d48 <__udivdi3+0x40>
  800da3:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800da4:	b8 20 00 00 00       	mov    $0x20,%eax
  800da9:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800dac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800daf:	89 fa                	mov    %edi,%edx
  800db1:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800db4:	d3 e2                	shl    %cl,%edx
  800db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db9:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800dbc:	d3 e8                	shr    %cl,%eax
  800dbe:	89 d7                	mov    %edx,%edi
  800dc0:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800dc2:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800dc5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800dc8:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800dca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800dcd:	d3 e0                	shl    %cl,%eax
  800dcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800dd2:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800dd5:	d3 ea                	shr    %cl,%edx
  800dd7:	09 d0                	or     %edx,%eax
  800dd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ddc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ddf:	d3 ea                	shr    %cl,%edx
  800de1:	f7 f7                	div    %edi
  800de3:	89 d7                	mov    %edx,%edi
  800de5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800de8:	f7 e6                	mul    %esi
  800dea:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800dec:	39 d7                	cmp    %edx,%edi
  800dee:	72 38                	jb     800e28 <__udivdi3+0x120>
  800df0:	74 27                	je     800e19 <__udivdi3+0x111>
  800df2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800df5:	31 c0                	xor    %eax,%eax
  800df7:	e9 4c ff ff ff       	jmp    800d48 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800dfc:	31 c9                	xor    %ecx,%ecx
  800dfe:	31 c0                	xor    %eax,%eax
  800e00:	e9 43 ff ff ff       	jmp    800d48 <__udivdi3+0x40>
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e08:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0d:	31 d2                	xor    %edx,%edx
  800e0f:	f7 75 f4             	divl   -0xc(%ebp)
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	e9 76 ff ff ff       	jmp    800d8f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e1c:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e1f:	d3 e0                	shl    %cl,%eax
  800e21:	39 f0                	cmp    %esi,%eax
  800e23:	73 cd                	jae    800df2 <__udivdi3+0xea>
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e28:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e2b:	49                   	dec    %ecx
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	e9 15 ff ff ff       	jmp    800d48 <__udivdi3+0x40>
	...

00800e34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	83 ec 30             	sub    $0x30,%esp
  800e3c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800e43:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e50:	8b 45 10             	mov    0x10(%ebp),%eax
  800e53:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e59:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800e5b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800e5e:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800e61:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e64:	85 d2                	test   %edx,%edx
  800e66:	75 1c                	jne    800e84 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800e68:	89 fa                	mov    %edi,%edx
  800e6a:	39 f8                	cmp    %edi,%eax
  800e6c:	0f 86 c2 00 00 00    	jbe    800f34 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e72:	89 f0                	mov    %esi,%eax
  800e74:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e76:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e79:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e80:	eb 12                	jmp    800e94 <__umoddi3+0x60>
  800e82:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e84:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e87:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e8a:	76 18                	jbe    800ea4 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e8c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e8f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e92:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e94:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e9a:	83 c4 30             	add    $0x30,%esp
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    
  800ea1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ea4:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800ea8:	83 f0 1f             	xor    $0x1f,%eax
  800eab:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800eae:	0f 84 ac 00 00 00    	je     800f60 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb9:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800ebc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ebf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ec2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ec5:	d3 e2                	shl    %cl,%edx
  800ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eca:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ecd:	d3 e8                	shr    %cl,%eax
  800ecf:	89 d6                	mov    %edx,%esi
  800ed1:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800ed3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ed6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ed9:	d3 e0                	shl    %cl,%eax
  800edb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ede:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800ee1:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee6:	d3 e0                	shl    %cl,%eax
  800ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eeb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eee:	d3 ea                	shr    %cl,%edx
  800ef0:	09 d0                	or     %edx,%eax
  800ef2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ef5:	d3 ea                	shr    %cl,%edx
  800ef7:	f7 f6                	div    %esi
  800ef9:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800efc:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eff:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800f02:	0f 82 8d 00 00 00    	jb     800f95 <__umoddi3+0x161>
  800f08:	0f 84 91 00 00 00    	je     800f9f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f11:	29 c7                	sub    %eax,%edi
  800f13:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f15:	89 f2                	mov    %esi,%edx
  800f17:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f1a:	d3 e2                	shl    %cl,%edx
  800f1c:	89 f8                	mov    %edi,%eax
  800f1e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f21:	d3 e8                	shr    %cl,%eax
  800f23:	09 c2                	or     %eax,%edx
  800f25:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800f28:	d3 ee                	shr    %cl,%esi
  800f2a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800f2d:	e9 62 ff ff ff       	jmp    800e94 <__umoddi3+0x60>
  800f32:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	74 15                	je     800f50 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f3e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f41:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f46:	f7 f1                	div    %ecx
  800f48:	e9 29 ff ff ff       	jmp    800e76 <__umoddi3+0x42>
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	31 d2                	xor    %edx,%edx
  800f57:	f7 75 ec             	divl   -0x14(%ebp)
  800f5a:	89 c1                	mov    %eax,%ecx
  800f5c:	eb dd                	jmp    800f3b <__umoddi3+0x107>
  800f5e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f63:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800f66:	72 19                	jb     800f81 <__umoddi3+0x14d>
  800f68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f6b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800f6e:	76 11                	jbe    800f81 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f73:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f76:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f79:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f7c:	e9 13 ff ff ff       	jmp    800e94 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f81:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f87:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f8a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f90:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f93:	eb db                	jmp    800f70 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f95:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f98:	19 f2                	sbb    %esi,%edx
  800f9a:	e9 6f ff ff ff       	jmp    800f0e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f9f:	39 c7                	cmp    %eax,%edi
  800fa1:	72 f2                	jb     800f95 <__umoddi3+0x161>
  800fa3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa6:	e9 63 ff ff ff       	jmp    800f0e <__umoddi3+0xda>
