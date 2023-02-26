
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
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
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 e2 0b 00 00       	call   800c23 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
		while (1) {
			ipc_recv(&who, 0, 0);
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 bf 0c 00 00       	call   800d1e <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 80 10 80 00       	push   $0x801080
  80006b:	e8 e9 00 00 00       	call   800159 <cprintf>
		}
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  80007e:	50                   	push   %eax
  80007f:	68 91 10 80 00       	push   $0x801091
  800084:	e8 d0 00 00 00       	call   800159 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  800098:	e8 2c 0c 00 00       	call   800cc9 <ipc_send>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	eb ea                	jmp    80008c <umain+0x58>
	...

008000a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000af:	e8 6f 0b 00 00       	call   800c23 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c0:	c1 e0 07             	shl    $0x7,%eax
  8000c3:	29 d0                	sub    %edx,%eax
  8000c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ca:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 f6                	test   %esi,%esi
  8000d1:	7e 07                	jle    8000da <libmain+0x36>
		binaryname = argv[0];
  8000d3:	8b 03                	mov    (%ebx),%eax
  8000d5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	53                   	push   %ebx
  8000de:	56                   	push   %esi
  8000df:	e8 50 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0b 00 00 00       	call   8000f4 <exit>
  8000e9:	83 c4 10             	add    $0x10,%esp
}
  8000ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 41 0b 00 00       	call   800c42 <sys_env_destroy>
  800101:	83 c4 10             	add    $0x10,%esp
}
  800104:	c9                   	leave  
  800105:	c3                   	ret    
	...

00800108 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800111:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800118:	00 00 00 
	b.cnt = 0;
  80011b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800122:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800125:	ff 75 0c             	pushl  0xc(%ebp)
  800128:	ff 75 08             	pushl  0x8(%ebp)
  80012b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800131:	50                   	push   %eax
  800132:	68 70 01 80 00       	push   $0x800170
  800137:	e8 70 01 00 00       	call   8002ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013c:	83 c4 08             	add    $0x8,%esp
  80013f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800145:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 9e 08 00 00       	call   8009ef <sys_cputs>
  800151:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800162:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800165:	50                   	push   %eax
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	e8 9a ff ff ff       	call   800108 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800183:	40                   	inc    %eax
  800184:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800186:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018b:	75 1a                	jne    8001a7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	68 ff 00 00 00       	push   $0xff
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 51 08 00 00       	call   8009ef <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a7:	ff 43 04             	incl   0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    
	...

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 1c             	sub    $0x1c,%esp
  8001b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8001bc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8001ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d1:	89 d6                	mov    %edx,%esi
  8001d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001d8:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8001db:	72 04                	jb     8001e1 <printnum+0x31>
  8001dd:	39 c2                	cmp    %eax,%edx
  8001df:	77 3f                	ja     800220 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 18             	pushl  0x18(%ebp)
  8001e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8001ea:	50                   	push   %eax
  8001eb:	52                   	push   %edx
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f7:	e8 dc 0b 00 00       	call   800dd8 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800204:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800207:	e8 a4 ff ff ff       	call   8001b0 <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 14                	jmp    800225 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	ff 75 e8             	pushl  -0x18(%ebp)
  800217:	ff 75 18             	pushl  0x18(%ebp)
  80021a:	ff 55 ec             	call   *-0x14(%ebp)
  80021d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	4b                   	dec    %ebx
  800221:	85 db                	test   %ebx,%ebx
  800223:	7f ec                	jg     800211 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	ff 75 e8             	pushl  -0x18(%ebp)
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	ff 75 e4             	pushl  -0x1c(%ebp)
  800233:	ff 75 e0             	pushl  -0x20(%ebp)
  800236:	e8 c9 0c 00 00       	call   800f04 <__umoddi3>
  80023b:	83 c4 14             	add    $0x14,%esp
  80023e:	0f be 80 b2 10 80 00 	movsbl 0x8010b2(%eax),%eax
  800245:	50                   	push   %eax
  800246:	ff 55 ec             	call   *-0x14(%ebp)
  800249:	83 c4 10             	add    $0x10,%esp
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 42 08             	lea    0x8(%edx),%eax
  800263:	89 01                	mov    %eax,(%ecx)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x3a>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 42 04             	lea    0x4(%edx),%eax
  800275:	89 01                	mov    %eax,(%ecx)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 42 04             	lea    0x4(%edx),%eax
  800285:	89 01                	mov    %eax,(%ecx)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800296:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800299:	8b 11                	mov    (%ecx),%edx
  80029b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80029e:	73 0a                	jae    8002aa <sprintputch+0x1a>
		*b->buf++ = ch;
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
  8002a5:	8d 42 01             	lea    0x1(%edx),%eax
  8002a8:	89 01                	mov    %eax,(%ecx)
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 3c             	sub    $0x3c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002be:	eb 1a                	jmp    8002da <vprintfmt+0x2e>
  8002c0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8002c3:	eb 15                	jmp    8002da <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c5:	84 c0                	test   %al,%al
  8002c7:	0f 84 15 03 00 00    	je     8005e2 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	57                   	push   %edi
  8002d1:	0f b6 c0             	movzbl %al,%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d6                	call   *%esi
  8002d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002da:	8a 03                	mov    (%ebx),%al
  8002dc:	43                   	inc    %ebx
  8002dd:	3c 25                	cmp    $0x25,%al
  8002df:	75 e4                	jne    8002c5 <vprintfmt+0x19>
  8002e1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002e8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8002ef:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8002f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002fd:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800301:	eb 0a                	jmp    80030d <vprintfmt+0x61>
  800303:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80030a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8a 03                	mov    (%ebx),%al
  80030f:	0f b6 d0             	movzbl %al,%edx
  800312:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800315:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800318:	83 e8 23             	sub    $0x23,%eax
  80031b:	3c 55                	cmp    $0x55,%al
  80031d:	0f 87 9c 02 00 00    	ja     8005bf <vprintfmt+0x313>
  800323:	0f b6 c0             	movzbl %al,%eax
  800326:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  80032d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800331:	eb d7                	jmp    80030a <vprintfmt+0x5e>
  800333:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800337:	eb d1                	jmp    80030a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800339:	89 d9                	mov    %ebx,%ecx
  80033b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800342:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800345:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800348:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80034c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80034f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800353:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800354:	8d 42 d0             	lea    -0x30(%edx),%eax
  800357:	83 f8 09             	cmp    $0x9,%eax
  80035a:	77 21                	ja     80037d <vprintfmt+0xd1>
  80035c:	eb e4                	jmp    800342 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035e:	8b 55 14             	mov    0x14(%ebp),%edx
  800361:	8d 42 04             	lea    0x4(%edx),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
  800367:	8b 12                	mov    (%edx),%edx
  800369:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80036c:	eb 12                	jmp    800380 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80036e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800372:	79 96                	jns    80030a <vprintfmt+0x5e>
  800374:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037b:	eb 8d                	jmp    80030a <vprintfmt+0x5e>
  80037d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800380:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800384:	79 84                	jns    80030a <vprintfmt+0x5e>
  800386:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800389:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800393:	e9 72 ff ff ff       	jmp    80030a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800398:	ff 45 d4             	incl   -0x2c(%ebp)
  80039b:	e9 6a ff ff ff       	jmp    80030a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8003a3:	8d 42 04             	lea    0x4(%edx),%eax
  8003a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	57                   	push   %edi
  8003ad:	ff 32                	pushl  (%edx)
  8003af:	ff d6                	call   *%esi
			break;
  8003b1:	83 c4 10             	add    $0x10,%esp
  8003b4:	e9 07 ff ff ff       	jmp    8002c0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bc:	8d 42 04             	lea    0x4(%edx),%eax
  8003bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	79 02                	jns    8003ca <vprintfmt+0x11e>
  8003c8:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ca:	83 f8 0f             	cmp    $0xf,%eax
  8003cd:	7f 0b                	jg     8003da <vprintfmt+0x12e>
  8003cf:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8003d6:	85 d2                	test   %edx,%edx
  8003d8:	75 15                	jne    8003ef <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 c3 10 80 00       	push   $0x8010c3
  8003e0:	57                   	push   %edi
  8003e1:	56                   	push   %esi
  8003e2:	e8 6e 02 00 00       	call   800655 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	e9 d1 fe ff ff       	jmp    8002c0 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8003ef:	52                   	push   %edx
  8003f0:	68 cc 10 80 00       	push   $0x8010cc
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	e8 59 02 00 00       	call   800655 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	e9 bc fe ff ff       	jmp    8002c0 <vprintfmt+0x14>
  800404:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800407:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80040a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040d:	8b 55 14             	mov    0x14(%ebp),%edx
  800410:	8d 42 04             	lea    0x4(%edx),%eax
  800413:	89 45 14             	mov    %eax,0x14(%ebp)
  800416:	8b 1a                	mov    (%edx),%ebx
  800418:	85 db                	test   %ebx,%ebx
  80041a:	75 05                	jne    800421 <vprintfmt+0x175>
  80041c:	bb cf 10 80 00       	mov    $0x8010cf,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800421:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800425:	7e 66                	jle    80048d <vprintfmt+0x1e1>
  800427:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80042b:	74 60                	je     80048d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	51                   	push   %ecx
  800431:	53                   	push   %ebx
  800432:	e8 57 02 00 00       	call   80068e <strnlen>
  800437:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80043a:	29 c1                	sub    %eax,%ecx
  80043c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800446:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800449:	eb 0f                	jmp    80045a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	57                   	push   %edi
  80044f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800452:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	ff 4d d8             	decl   -0x28(%ebp)
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045e:	7f eb                	jg     80044b <vprintfmt+0x19f>
  800460:	eb 2b                	jmp    80048d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800462:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800465:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800469:	74 15                	je     800480 <vprintfmt+0x1d4>
  80046b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80046e:	83 f8 5e             	cmp    $0x5e,%eax
  800471:	76 0d                	jbe    800480 <vprintfmt+0x1d4>
					putch('?', putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	57                   	push   %edi
  800477:	6a 3f                	push   $0x3f
  800479:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	eb 0a                	jmp    80048a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	57                   	push   %edi
  800484:	52                   	push   %edx
  800485:	ff d6                	call   *%esi
  800487:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048a:	ff 4d d8             	decl   -0x28(%ebp)
  80048d:	8a 03                	mov    (%ebx),%al
  80048f:	43                   	inc    %ebx
  800490:	84 c0                	test   %al,%al
  800492:	74 1b                	je     8004af <vprintfmt+0x203>
  800494:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800498:	78 c8                	js     800462 <vprintfmt+0x1b6>
  80049a:	ff 4d dc             	decl   -0x24(%ebp)
  80049d:	79 c3                	jns    800462 <vprintfmt+0x1b6>
  80049f:	eb 0e                	jmp    8004af <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	57                   	push   %edi
  8004a5:	6a 20                	push   $0x20
  8004a7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004a9:	ff 4d d8             	decl   -0x28(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b3:	7f ec                	jg     8004a1 <vprintfmt+0x1f5>
  8004b5:	e9 06 fe ff ff       	jmp    8002c0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ba:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8004be:	7e 10                	jle    8004d0 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8004c0:	8b 55 14             	mov    0x14(%ebp),%edx
  8004c3:	8d 42 08             	lea    0x8(%edx),%eax
  8004c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ce:	eb 20                	jmp    8004f0 <vprintfmt+0x244>
	else if (lflag)
  8004d0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d4:	74 0e                	je     8004e4 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	99                   	cltd   
  8004e2:	eb 0c                	jmp    8004f0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8004f0:	89 d1                	mov    %edx,%ecx
  8004f2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8004f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004f7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fa:	85 c9                	test   %ecx,%ecx
  8004fc:	78 0a                	js     800508 <vprintfmt+0x25c>
  8004fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800503:	e9 89 00 00 00       	jmp    800591 <vprintfmt+0x2e5>
				putch('-', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	57                   	push   %edi
  80050c:	6a 2d                	push   $0x2d
  80050e:	ff d6                	call   *%esi
				num = -(long long) num;
  800510:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800513:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800516:	f7 da                	neg    %edx
  800518:	83 d1 00             	adc    $0x0,%ecx
  80051b:	f7 d9                	neg    %ecx
  80051d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb 6a                	jmp    800591 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800527:	8d 45 14             	lea    0x14(%ebp),%eax
  80052a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80052d:	e8 22 fd ff ff       	call   800254 <getuint>
  800532:	89 d1                	mov    %edx,%ecx
  800534:	89 c2                	mov    %eax,%edx
  800536:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80053b:	eb 54                	jmp    800591 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80053d:	8d 45 14             	lea    0x14(%ebp),%eax
  800540:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800543:	e8 0c fd ff ff       	call   800254 <getuint>
  800548:	89 d1                	mov    %edx,%ecx
  80054a:	89 c2                	mov    %eax,%edx
  80054c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800551:	eb 3e                	jmp    800591 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	57                   	push   %edi
  800557:	6a 30                	push   $0x30
  800559:	ff d6                	call   *%esi
			putch('x', putdat);
  80055b:	83 c4 08             	add    $0x8,%esp
  80055e:	57                   	push   %edi
  80055f:	6a 78                	push   $0x78
  800561:	ff d6                	call   *%esi
			num = (unsigned long long)
  800563:	8b 55 14             	mov    0x14(%ebp),%edx
  800566:	8d 42 04             	lea    0x4(%edx),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	8b 12                	mov    (%edx),%edx
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 14                	jmp    800591 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80057d:	8d 45 14             	lea    0x14(%ebp),%eax
  800580:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800583:	e8 cc fc ff ff       	call   800254 <getuint>
  800588:	89 d1                	mov    %edx,%ecx
  80058a:	89 c2                	mov    %eax,%edx
  80058c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800591:	83 ec 0c             	sub    $0xc,%esp
  800594:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	ff 75 d8             	pushl  -0x28(%ebp)
  80059c:	53                   	push   %ebx
  80059d:	51                   	push   %ecx
  80059e:	52                   	push   %edx
  80059f:	89 fa                	mov    %edi,%edx
  8005a1:	89 f0                	mov    %esi,%eax
  8005a3:	e8 08 fc ff ff       	call   8001b0 <printnum>
			break;
  8005a8:	83 c4 20             	add    $0x20,%esp
  8005ab:	e9 10 fd ff ff       	jmp    8002c0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	57                   	push   %edi
  8005b4:	52                   	push   %edx
  8005b5:	ff d6                	call   *%esi
			break;
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	e9 01 fd ff ff       	jmp    8002c0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 25                	push   $0x25
  8005c5:	ff d6                	call   *%esi
  8005c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8005ca:	83 ea 02             	sub    $0x2,%edx
  8005cd:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005d0:	8a 02                	mov    (%edx),%al
  8005d2:	4a                   	dec    %edx
  8005d3:	3c 25                	cmp    $0x25,%al
  8005d5:	75 f9                	jne    8005d0 <vprintfmt+0x324>
  8005d7:	83 c2 02             	add    $0x2,%edx
  8005da:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8005dd:	e9 de fc ff ff       	jmp    8002c0 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8005e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e5:	5b                   	pop    %ebx
  8005e6:	5e                   	pop    %esi
  8005e7:	5f                   	pop    %edi
  8005e8:	c9                   	leave  
  8005e9:	c3                   	ret    

008005ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8005ea:	55                   	push   %ebp
  8005eb:	89 e5                	mov    %esp,%ebp
  8005ed:	83 ec 18             	sub    $0x18,%esp
  8005f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	74 37                	je     800631 <vsnprintf+0x47>
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	7e 33                	jle    800631 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8005fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800605:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800609:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80060c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80060f:	ff 75 14             	pushl  0x14(%ebp)
  800612:	ff 75 10             	pushl  0x10(%ebp)
  800615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800618:	50                   	push   %eax
  800619:	68 90 02 80 00       	push   $0x800290
  80061e:	e8 89 fc ff ff       	call   8002ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800626:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800629:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	eb 05                	jmp    800636 <vsnprintf+0x4c>
  800631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800636:	c9                   	leave  
  800637:	c3                   	ret    

00800638 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800644:	50                   	push   %eax
  800645:	ff 75 10             	pushl  0x10(%ebp)
  800648:	ff 75 0c             	pushl  0xc(%ebp)
  80064b:	ff 75 08             	pushl  0x8(%ebp)
  80064e:	e8 97 ff ff ff       	call   8005ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800653:	c9                   	leave  
  800654:	c3                   	ret    

00800655 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800661:	50                   	push   %eax
  800662:	ff 75 10             	pushl  0x10(%ebp)
  800665:	ff 75 0c             	pushl  0xc(%ebp)
  800668:	ff 75 08             	pushl  0x8(%ebp)
  80066b:	e8 3c fc ff ff       	call   8002ac <vprintfmt>
	va_end(ap);
  800670:	83 c4 10             	add    $0x10,%esp
}
  800673:	c9                   	leave  
  800674:	c3                   	ret    
  800675:	00 00                	add    %al,(%eax)
	...

00800678 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	b8 00 00 00 00       	mov    $0x0,%eax
  800683:	eb 01                	jmp    800686 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800685:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800686:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80068a:	75 f9                	jne    800685 <strlen+0xd>
		n++;
	return n;
}
  80068c:	c9                   	leave  
  80068d:	c3                   	ret    

0080068e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
  800697:	b8 00 00 00 00       	mov    $0x0,%eax
  80069c:	eb 01                	jmp    80069f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80069e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80069f:	39 d0                	cmp    %edx,%eax
  8006a1:	74 06                	je     8006a9 <strnlen+0x1b>
  8006a3:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8006a7:	75 f5                	jne    80069e <strnlen+0x10>
		n++;
	return n;
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b1:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006b4:	8a 01                	mov    (%ecx),%al
  8006b6:	88 02                	mov    %al,(%edx)
  8006b8:	42                   	inc    %edx
  8006b9:	41                   	inc    %ecx
  8006ba:	84 c0                	test   %al,%al
  8006bc:	75 f6                	jne    8006b4 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	53                   	push   %ebx
  8006c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006ca:	53                   	push   %ebx
  8006cb:	e8 a8 ff ff ff       	call   800678 <strlen>
	strcpy(dst + len, src);
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8006d6:	50                   	push   %eax
  8006d7:	e8 cf ff ff ff       	call   8006ab <strcpy>
	return dst;
}
  8006dc:	89 d8                	mov    %ebx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	56                   	push   %esi
  8006e7:	53                   	push   %ebx
  8006e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f6:	eb 0c                	jmp    800704 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8006f8:	8a 02                	mov    (%edx),%al
  8006fa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8006fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800700:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800703:	41                   	inc    %ecx
  800704:	39 d9                	cmp    %ebx,%ecx
  800706:	75 f0                	jne    8006f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800708:	89 f0                	mov    %esi,%eax
  80070a:	5b                   	pop    %ebx
  80070b:	5e                   	pop    %esi
  80070c:	c9                   	leave  
  80070d:	c3                   	ret    

0080070e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	56                   	push   %esi
  800712:	53                   	push   %ebx
  800713:	8b 75 08             	mov    0x8(%ebp),%esi
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800719:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80071c:	85 c9                	test   %ecx,%ecx
  80071e:	75 04                	jne    800724 <strlcpy+0x16>
  800720:	89 f0                	mov    %esi,%eax
  800722:	eb 14                	jmp    800738 <strlcpy+0x2a>
  800724:	89 f0                	mov    %esi,%eax
  800726:	eb 04                	jmp    80072c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800728:	88 10                	mov    %dl,(%eax)
  80072a:	40                   	inc    %eax
  80072b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80072c:	49                   	dec    %ecx
  80072d:	74 06                	je     800735 <strlcpy+0x27>
  80072f:	8a 13                	mov    (%ebx),%dl
  800731:	84 d2                	test   %dl,%dl
  800733:	75 f3                	jne    800728 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800735:	c6 00 00             	movb   $0x0,(%eax)
  800738:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	eb 02                	jmp    80074b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800749:	42                   	inc    %edx
  80074a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80074b:	8a 02                	mov    (%edx),%al
  80074d:	84 c0                	test   %al,%al
  80074f:	74 04                	je     800755 <strcmp+0x17>
  800751:	3a 01                	cmp    (%ecx),%al
  800753:	74 f4                	je     800749 <strcmp+0xb>
  800755:	0f b6 c0             	movzbl %al,%eax
  800758:	0f b6 11             	movzbl (%ecx),%edx
  80075b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800769:	8b 55 10             	mov    0x10(%ebp),%edx
  80076c:	eb 03                	jmp    800771 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80076e:	4a                   	dec    %edx
  80076f:	41                   	inc    %ecx
  800770:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800771:	85 d2                	test   %edx,%edx
  800773:	75 07                	jne    80077c <strncmp+0x1d>
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 14                	jmp    800790 <strncmp+0x31>
  80077c:	8a 01                	mov    (%ecx),%al
  80077e:	84 c0                	test   %al,%al
  800780:	74 04                	je     800786 <strncmp+0x27>
  800782:	3a 03                	cmp    (%ebx),%al
  800784:	74 e8                	je     80076e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800786:	0f b6 d0             	movzbl %al,%edx
  800789:	0f b6 03             	movzbl (%ebx),%eax
  80078c:	29 c2                	sub    %eax,%edx
  80078e:	89 d0                	mov    %edx,%eax
}
  800790:	5b                   	pop    %ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80079c:	eb 05                	jmp    8007a3 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80079e:	38 ca                	cmp    %cl,%dl
  8007a0:	74 0c                	je     8007ae <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007a2:	40                   	inc    %eax
  8007a3:	8a 10                	mov    (%eax),%dl
  8007a5:	84 d2                	test   %dl,%dl
  8007a7:	75 f5                	jne    80079e <strchr+0xb>
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007b9:	eb 05                	jmp    8007c0 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8007bb:	38 ca                	cmp    %cl,%dl
  8007bd:	74 07                	je     8007c6 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8007bf:	40                   	inc    %eax
  8007c0:	8a 10                	mov    (%eax),%dl
  8007c2:	84 d2                	test   %dl,%dl
  8007c4:	75 f5                	jne    8007bb <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	57                   	push   %edi
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8007d7:	85 db                	test   %ebx,%ebx
  8007d9:	74 36                	je     800811 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8007db:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8007e1:	75 29                	jne    80080c <memset+0x44>
  8007e3:	f6 c3 03             	test   $0x3,%bl
  8007e6:	75 24                	jne    80080c <memset+0x44>
		c &= 0xFF;
  8007e8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8007eb:	89 d6                	mov    %edx,%esi
  8007ed:	c1 e6 08             	shl    $0x8,%esi
  8007f0:	89 d0                	mov    %edx,%eax
  8007f2:	c1 e0 18             	shl    $0x18,%eax
  8007f5:	89 d1                	mov    %edx,%ecx
  8007f7:	c1 e1 10             	shl    $0x10,%ecx
  8007fa:	09 c8                	or     %ecx,%eax
  8007fc:	09 c2                	or     %eax,%edx
  8007fe:	89 f0                	mov    %esi,%eax
  800800:	09 d0                	or     %edx,%eax
  800802:	89 d9                	mov    %ebx,%ecx
  800804:	c1 e9 02             	shr    $0x2,%ecx
  800807:	fc                   	cld    
  800808:	f3 ab                	rep stos %eax,%es:(%edi)
  80080a:	eb 05                	jmp    800811 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80080c:	89 d9                	mov    %ebx,%ecx
  80080e:	fc                   	cld    
  80080f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800811:	89 f8                	mov    %edi,%eax
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5f                   	pop    %edi
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	57                   	push   %edi
  80081c:	56                   	push   %esi
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800823:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800826:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800828:	39 c6                	cmp    %eax,%esi
  80082a:	73 36                	jae    800862 <memmove+0x4a>
  80082c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80082f:	39 d0                	cmp    %edx,%eax
  800831:	73 2f                	jae    800862 <memmove+0x4a>
		s += n;
		d += n;
  800833:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800836:	f6 c2 03             	test   $0x3,%dl
  800839:	75 1b                	jne    800856 <memmove+0x3e>
  80083b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800841:	75 13                	jne    800856 <memmove+0x3e>
  800843:	f6 c1 03             	test   $0x3,%cl
  800846:	75 0e                	jne    800856 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800848:	8d 7e fc             	lea    -0x4(%esi),%edi
  80084b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80084e:	c1 e9 02             	shr    $0x2,%ecx
  800851:	fd                   	std    
  800852:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800854:	eb 09                	jmp    80085f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800856:	8d 7e ff             	lea    -0x1(%esi),%edi
  800859:	8d 72 ff             	lea    -0x1(%edx),%esi
  80085c:	fd                   	std    
  80085d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80085f:	fc                   	cld    
  800860:	eb 20                	jmp    800882 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800862:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800868:	75 15                	jne    80087f <memmove+0x67>
  80086a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800870:	75 0d                	jne    80087f <memmove+0x67>
  800872:	f6 c1 03             	test   $0x3,%cl
  800875:	75 08                	jne    80087f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800877:	c1 e9 02             	shr    $0x2,%ecx
  80087a:	fc                   	cld    
  80087b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087d:	eb 03                	jmp    800882 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80087f:	fc                   	cld    
  800880:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800889:	ff 75 10             	pushl  0x10(%ebp)
  80088c:	ff 75 0c             	pushl  0xc(%ebp)
  80088f:	ff 75 08             	pushl  0x8(%ebp)
  800892:	e8 81 ff ff ff       	call   800818 <memmove>
}
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	83 ec 04             	sub    $0x4,%esp
  8008a0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8008a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a9:	eb 1b                	jmp    8008c6 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8008ab:	8a 1a                	mov    (%edx),%bl
  8008ad:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8008b0:	8a 19                	mov    (%ecx),%bl
  8008b2:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8008b5:	74 0d                	je     8008c4 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8008b7:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8008bb:	0f b6 c3             	movzbl %bl,%eax
  8008be:	29 c2                	sub    %eax,%edx
  8008c0:	89 d0                	mov    %edx,%eax
  8008c2:	eb 0d                	jmp    8008d1 <memcmp+0x38>
		s1++, s2++;
  8008c4:	42                   	inc    %edx
  8008c5:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008c6:	48                   	dec    %eax
  8008c7:	83 f8 ff             	cmp    $0xffffffff,%eax
  8008ca:	75 df                	jne    8008ab <memcmp+0x12>
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8008d1:	83 c4 04             	add    $0x4,%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	03 55 10             	add    0x10(%ebp),%edx
  8008e5:	eb 05                	jmp    8008ec <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8008e7:	38 08                	cmp    %cl,(%eax)
  8008e9:	74 05                	je     8008f0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8008eb:	40                   	inc    %eax
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	72 f7                	jb     8008e7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	57                   	push   %edi
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
  8008f8:	83 ec 04             	sub    $0x4,%esp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800901:	eb 01                	jmp    800904 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800903:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800904:	8a 01                	mov    (%ecx),%al
  800906:	3c 20                	cmp    $0x20,%al
  800908:	74 f9                	je     800903 <strtol+0x11>
  80090a:	3c 09                	cmp    $0x9,%al
  80090c:	74 f5                	je     800903 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  80090e:	3c 2b                	cmp    $0x2b,%al
  800910:	75 0a                	jne    80091c <strtol+0x2a>
		s++;
  800912:	41                   	inc    %ecx
  800913:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80091a:	eb 17                	jmp    800933 <strtol+0x41>
	else if (*s == '-')
  80091c:	3c 2d                	cmp    $0x2d,%al
  80091e:	74 09                	je     800929 <strtol+0x37>
  800920:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800927:	eb 0a                	jmp    800933 <strtol+0x41>
		s++, neg = 1;
  800929:	8d 49 01             	lea    0x1(%ecx),%ecx
  80092c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800933:	85 f6                	test   %esi,%esi
  800935:	74 05                	je     80093c <strtol+0x4a>
  800937:	83 fe 10             	cmp    $0x10,%esi
  80093a:	75 1a                	jne    800956 <strtol+0x64>
  80093c:	8a 01                	mov    (%ecx),%al
  80093e:	3c 30                	cmp    $0x30,%al
  800940:	75 10                	jne    800952 <strtol+0x60>
  800942:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800946:	75 0a                	jne    800952 <strtol+0x60>
		s += 2, base = 16;
  800948:	83 c1 02             	add    $0x2,%ecx
  80094b:	be 10 00 00 00       	mov    $0x10,%esi
  800950:	eb 04                	jmp    800956 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800952:	85 f6                	test   %esi,%esi
  800954:	74 07                	je     80095d <strtol+0x6b>
  800956:	bf 00 00 00 00       	mov    $0x0,%edi
  80095b:	eb 13                	jmp    800970 <strtol+0x7e>
  80095d:	3c 30                	cmp    $0x30,%al
  80095f:	74 07                	je     800968 <strtol+0x76>
  800961:	be 0a 00 00 00       	mov    $0xa,%esi
  800966:	eb ee                	jmp    800956 <strtol+0x64>
		s++, base = 8;
  800968:	41                   	inc    %ecx
  800969:	be 08 00 00 00       	mov    $0x8,%esi
  80096e:	eb e6                	jmp    800956 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800970:	8a 11                	mov    (%ecx),%dl
  800972:	88 d3                	mov    %dl,%bl
  800974:	8d 42 d0             	lea    -0x30(%edx),%eax
  800977:	3c 09                	cmp    $0x9,%al
  800979:	77 08                	ja     800983 <strtol+0x91>
			dig = *s - '0';
  80097b:	0f be c2             	movsbl %dl,%eax
  80097e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800981:	eb 1c                	jmp    80099f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800983:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800986:	3c 19                	cmp    $0x19,%al
  800988:	77 08                	ja     800992 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80098a:	0f be c2             	movsbl %dl,%eax
  80098d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800990:	eb 0d                	jmp    80099f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800992:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800995:	3c 19                	cmp    $0x19,%al
  800997:	77 15                	ja     8009ae <strtol+0xbc>
			dig = *s - 'A' + 10;
  800999:	0f be c2             	movsbl %dl,%eax
  80099c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80099f:	39 f2                	cmp    %esi,%edx
  8009a1:	7d 0b                	jge    8009ae <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009a3:	41                   	inc    %ecx
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	0f af c6             	imul   %esi,%eax
  8009a9:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8009ac:	eb c2                	jmp    800970 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8009ae:	89 f8                	mov    %edi,%eax

	if (endptr)
  8009b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009b4:	74 05                	je     8009bb <strtol+0xc9>
		*endptr = (char *) s;
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8009bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8009bf:	74 04                	je     8009c5 <strtol+0xd3>
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	f7 df                	neg    %edi
}
  8009c5:	89 f8                	mov    %edi,%eax
  8009c7:	83 c4 04             	add    $0x4,%esp
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8009db:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e0:	89 fa                	mov    %edi,%edx
  8009e2:	89 f9                	mov    %edi,%ecx
  8009e4:	89 fb                	mov    %edi,%ebx
  8009e6:	89 fe                	mov    %edi,%esi
  8009e8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	83 ec 04             	sub    $0x4,%esp
  8009f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8009fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800a03:	89 f8                	mov    %edi,%eax
  800a05:	89 fb                	mov    %edi,%ebx
  800a07:	89 fe                	mov    %edi,%esi
  800a09:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a0b:	83 c4 04             	add    $0x4,%esp
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	83 ec 0c             	sub    $0xc,%esp
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	89 f9                	mov    %edi,%ecx
  800a2b:	89 fb                	mov    %edi,%ebx
  800a2d:	89 fe                	mov    %edi,%esi
  800a2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a31:	85 c0                	test   %eax,%eax
  800a33:	7e 17                	jle    800a4c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a35:	83 ec 0c             	sub    $0xc,%esp
  800a38:	50                   	push   %eax
  800a39:	6a 0d                	push   $0xd
  800a3b:	68 bf 13 80 00       	push   $0x8013bf
  800a40:	6a 23                	push   $0x23
  800a42:	68 dc 13 80 00       	push   $0x8013dc
  800a47:	e8 3c 03 00 00       	call   800d88 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800a4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a63:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800a6b:	be 00 00 00 00       	mov    $0x0,%esi
  800a70:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 0c             	sub    $0xc,%esp
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	89 fb                	mov    %edi,%ebx
  800a92:	89 fe                	mov    %edi,%esi
  800a94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a96:	85 c0                	test   %eax,%eax
  800a98:	7e 17                	jle    800ab1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9a:	83 ec 0c             	sub    $0xc,%esp
  800a9d:	50                   	push   %eax
  800a9e:	6a 0a                	push   $0xa
  800aa0:	68 bf 13 80 00       	push   $0x8013bf
  800aa5:	6a 23                	push   $0x23
  800aa7:	68 dc 13 80 00       	push   $0x8013dc
  800aac:	e8 d7 02 00 00       	call   800d88 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ab1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	b8 09 00 00 00       	mov    $0x9,%eax
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad2:	89 fb                	mov    %edi,%ebx
  800ad4:	89 fe                	mov    %edi,%esi
  800ad6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	7e 17                	jle    800af3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	6a 09                	push   $0x9
  800ae2:	68 bf 13 80 00       	push   $0x8013bf
  800ae7:	6a 23                	push   $0x23
  800ae9:	68 dc 13 80 00       	push   $0x8013dc
  800aee:	e8 95 02 00 00       	call   800d88 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800b0a:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800b1c:	7e 17                	jle    800b35 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	50                   	push   %eax
  800b22:	6a 08                	push   $0x8
  800b24:	68 bf 13 80 00       	push   $0x8013bf
  800b29:	6a 23                	push   $0x23
  800b2b:	68 dc 13 80 00       	push   $0x8013dc
  800b30:	e8 53 02 00 00       	call   800d88 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
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
  800b4c:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800b5e:	7e 17                	jle    800b77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 06                	push   $0x6
  800b66:	68 bf 13 80 00       	push   $0x8013bf
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 dc 13 80 00       	push   $0x8013dc
  800b72:	e8 11 02 00 00       	call   800d88 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b91:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b94:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b97:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 bf 13 80 00       	push   $0x8013bf
  800bad:	6a 23                	push   $0x23
  800baf:	68 dc 13 80 00       	push   $0x8013dc
  800bb4:	e8 cf 01 00 00       	call   800d88 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdd:	89 fe                	mov    %edi,%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 04                	push   $0x4
  800beb:	68 bf 13 80 00       	push   $0x8013bf
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 dc 13 80 00       	push   $0x8013dc
  800bf7:	e8 8c 01 00 00       	call   800d88 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	89 fa                	mov    %edi,%edx
  800c16:	89 f9                	mov    %edi,%ecx
  800c18:	89 fb                	mov    %edi,%ebx
  800c1a:	89 fe                	mov    %edi,%esi
  800c1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	89 fa                	mov    %edi,%edx
  800c35:	89 f9                	mov    %edi,%ecx
  800c37:	89 fb                	mov    %edi,%ebx
  800c39:	89 fe                	mov    %edi,%esi
  800c3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
  800c58:	89 f9                	mov    %edi,%ecx
  800c5a:	89 fb                	mov    %edi,%ebx
  800c5c:	89 fe                	mov    %edi,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 03                	push   $0x3
  800c6a:	68 bf 13 80 00       	push   $0x8013bf
  800c6f:	6a 23                	push   $0x23
  800c71:	68 dc 13 80 00       	push   $0x8013dc
  800c76:	e8 0d 01 00 00       	call   800d88 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    
	...

00800c84 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800c90:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  800c97:	89 c8                	mov    %ecx,%eax
  800c99:	c1 e0 07             	shl    $0x7,%eax
  800c9c:	29 d0                	sub    %edx,%eax
  800c9e:	89 c2                	mov    %eax,%edx
  800ca0:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  800ca6:	8b 40 50             	mov    0x50(%eax),%eax
  800ca9:	39 d8                	cmp    %ebx,%eax
  800cab:	75 0b                	jne    800cb8 <ipc_find_env+0x34>
			return envs[i].env_id;
  800cad:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  800cb3:	8b 40 40             	mov    0x40(%eax),%eax
  800cb6:	eb 0e                	jmp    800cc6 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800cb8:	41                   	inc    %ecx
  800cb9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  800cbf:	75 cf                	jne    800c90 <ipc_find_env+0xc>
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	75 05                	jne    800ce4 <ipc_send+0x1b>
  800cdf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	57                   	push   %edi
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	e8 65 fd ff ff       	call   800a54 <sys_ipc_try_send>
		if (r == 0) {		//success
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	74 20                	je     800d16 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  800cf6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800cf9:	75 07                	jne    800d02 <ipc_send+0x39>
			sys_yield();
  800cfb:	e8 04 ff ff ff       	call   800c04 <sys_yield>
  800d00:	eb e2                	jmp    800ce4 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  800d02:	83 ec 04             	sub    $0x4,%esp
  800d05:	68 ec 13 80 00       	push   $0x8013ec
  800d0a:	6a 41                	push   $0x41
  800d0c:	68 0f 14 80 00       	push   $0x80140f
  800d11:	e8 72 00 00 00       	call   800d88 <_panic>
		}
	}
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d29:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	75 05                	jne    800d35 <ipc_recv+0x17>
  800d30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	e8 d5 fc ff ff       	call   800a13 <sys_ipc_recv>
	if (r < 0) {				
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	85 c0                	test   %eax,%eax
  800d43:	79 16                	jns    800d5b <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  800d45:	85 db                	test   %ebx,%ebx
  800d47:	74 06                	je     800d4f <ipc_recv+0x31>
  800d49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  800d4f:	85 f6                	test   %esi,%esi
  800d51:	74 2c                	je     800d7f <ipc_recv+0x61>
  800d53:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800d59:	eb 24                	jmp    800d7f <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  800d5b:	85 db                	test   %ebx,%ebx
  800d5d:	74 0a                	je     800d69 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  800d5f:	a1 04 20 80 00       	mov    0x802004,%eax
  800d64:	8b 40 74             	mov    0x74(%eax),%eax
  800d67:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  800d69:	85 f6                	test   %esi,%esi
  800d6b:	74 0a                	je     800d77 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  800d6d:	a1 04 20 80 00       	mov    0x802004,%eax
  800d72:	8b 40 78             	mov    0x78(%eax),%eax
  800d75:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  800d77:	a1 04 20 80 00       	mov    0x802004,%eax
  800d7c:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    
	...

00800d88 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800d8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800d92:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d95:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d9b:	e8 83 fe ff ff       	call   800c23 <sys_getenvid>
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	ff 75 08             	pushl  0x8(%ebp)
  800da9:	53                   	push   %ebx
  800daa:	50                   	push   %eax
  800dab:	68 1c 14 80 00       	push   $0x80141c
  800db0:	e8 a4 f3 ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800db5:	83 c4 18             	add    $0x18,%esp
  800db8:	ff 75 f8             	pushl  -0x8(%ebp)
  800dbb:	ff 75 10             	pushl  0x10(%ebp)
  800dbe:	e8 45 f3 ff ff       	call   800108 <vcprintf>
	cprintf("\n");
  800dc3:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  800dca:	e8 8a f3 ff ff       	call   800159 <cprintf>
  800dcf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dd2:	cc                   	int3   
  800dd3:	eb fd                	jmp    800dd2 <_panic+0x4a>
  800dd5:	00 00                	add    %al,(%eax)
	...

00800dd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	83 ec 28             	sub    $0x28,%esp
  800de0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800de7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800dee:	8b 45 10             	mov    0x10(%ebp),%eax
  800df1:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800df7:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800df9:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800e01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e04:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e07:	85 ff                	test   %edi,%edi
  800e09:	75 21                	jne    800e2c <__udivdi3+0x54>
    {
      if (d0 > n1)
  800e0b:	39 d1                	cmp    %edx,%ecx
  800e0d:	76 49                	jbe    800e58 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e0f:	f7 f1                	div    %ecx
  800e11:	89 c1                	mov    %eax,%ecx
  800e13:	31 c0                	xor    %eax,%eax
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e18:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800e1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e21:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e24:	83 c4 28             	add    $0x28,%esp
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    
  800e2b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e2c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800e2f:	0f 87 97 00 00 00    	ja     800ecc <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e35:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e38:	83 f0 1f             	xor    $0x1f,%eax
  800e3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e3e:	75 34                	jne    800e74 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e40:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800e43:	72 08                	jb     800e4d <__udivdi3+0x75>
  800e45:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e48:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e4b:	77 7f                	ja     800ecc <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e4d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800e52:	31 c0                	xor    %eax,%eax
  800e54:	eb c2                	jmp    800e18 <__udivdi3+0x40>
  800e56:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	74 79                	je     800ed8 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e62:	89 fa                	mov    %edi,%edx
  800e64:	f7 f1                	div    %ecx
  800e66:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e6b:	f7 f1                	div    %ecx
  800e6d:	89 c1                	mov    %eax,%ecx
  800e6f:	89 f0                	mov    %esi,%eax
  800e71:	eb a5                	jmp    800e18 <__udivdi3+0x40>
  800e73:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e74:	b8 20 00 00 00       	mov    $0x20,%eax
  800e79:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e84:	d3 e2                	shl    %cl,%edx
  800e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e89:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e8c:	d3 e8                	shr    %cl,%eax
  800e8e:	89 d7                	mov    %edx,%edi
  800e90:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800e92:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800e95:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e98:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e9d:	d3 e0                	shl    %cl,%eax
  800e9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ea2:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800ea5:	d3 ea                	shr    %cl,%edx
  800ea7:	09 d0                	or     %edx,%eax
  800ea9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eaf:	d3 ea                	shr    %cl,%edx
  800eb1:	f7 f7                	div    %edi
  800eb3:	89 d7                	mov    %edx,%edi
  800eb5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800eb8:	f7 e6                	mul    %esi
  800eba:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebc:	39 d7                	cmp    %edx,%edi
  800ebe:	72 38                	jb     800ef8 <__udivdi3+0x120>
  800ec0:	74 27                	je     800ee9 <__udivdi3+0x111>
  800ec2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ec5:	31 c0                	xor    %eax,%eax
  800ec7:	e9 4c ff ff ff       	jmp    800e18 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ecc:	31 c9                	xor    %ecx,%ecx
  800ece:	31 c0                	xor    %eax,%eax
  800ed0:	e9 43 ff ff ff       	jmp    800e18 <__udivdi3+0x40>
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ed8:	b8 01 00 00 00       	mov    $0x1,%eax
  800edd:	31 d2                	xor    %edx,%edx
  800edf:	f7 75 f4             	divl   -0xc(%ebp)
  800ee2:	89 c1                	mov    %eax,%ecx
  800ee4:	e9 76 ff ff ff       	jmp    800e5f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eec:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eef:	d3 e0                	shl    %cl,%eax
  800ef1:	39 f0                	cmp    %esi,%eax
  800ef3:	73 cd                	jae    800ec2 <__udivdi3+0xea>
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800efb:	49                   	dec    %ecx
  800efc:	31 c0                	xor    %eax,%eax
  800efe:	e9 15 ff ff ff       	jmp    800e18 <__udivdi3+0x40>
	...

00800f04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	83 ec 30             	sub    $0x30,%esp
  800f0c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800f13:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f20:	8b 45 10             	mov    0x10(%ebp),%eax
  800f23:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f29:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800f2b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800f2e:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800f31:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f34:	85 d2                	test   %edx,%edx
  800f36:	75 1c                	jne    800f54 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	39 f8                	cmp    %edi,%eax
  800f3c:	0f 86 c2 00 00 00    	jbe    801004 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f42:	89 f0                	mov    %esi,%eax
  800f44:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800f46:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800f49:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f50:	eb 12                	jmp    800f64 <__umoddi3+0x60>
  800f52:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f54:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f57:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800f5a:	76 18                	jbe    800f74 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f5c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800f5f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f62:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f64:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f6a:	83 c4 30             	add    $0x30,%esp
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    
  800f71:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f74:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800f78:	83 f0 1f             	xor    $0x1f,%eax
  800f7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f7e:	0f 84 ac 00 00 00    	je     801030 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f84:	b8 20 00 00 00       	mov    $0x20,%eax
  800f89:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800f8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f8f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f92:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f95:	d3 e2                	shl    %cl,%edx
  800f97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f9d:	d3 e8                	shr    %cl,%eax
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800fa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800fa9:	d3 e0                	shl    %cl,%eax
  800fab:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fae:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800fb1:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb6:	d3 e0                	shl    %cl,%eax
  800fb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fbb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fbe:	d3 ea                	shr    %cl,%edx
  800fc0:	09 d0                	or     %edx,%eax
  800fc2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fc5:	d3 ea                	shr    %cl,%edx
  800fc7:	f7 f6                	div    %esi
  800fc9:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800fcc:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fcf:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800fd2:	0f 82 8d 00 00 00    	jb     801065 <__umoddi3+0x161>
  800fd8:	0f 84 91 00 00 00    	je     80106f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fde:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800fe1:	29 c7                	sub    %eax,%edi
  800fe3:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fe5:	89 f2                	mov    %esi,%edx
  800fe7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fea:	d3 e2                	shl    %cl,%edx
  800fec:	89 f8                	mov    %edi,%eax
  800fee:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800ff1:	d3 e8                	shr    %cl,%eax
  800ff3:	09 c2                	or     %eax,%edx
  800ff5:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800ff8:	d3 ee                	shr    %cl,%esi
  800ffa:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ffd:	e9 62 ff ff ff       	jmp    800f64 <__umoddi3+0x60>
  801002:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801004:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801007:	85 c0                	test   %eax,%eax
  801009:	74 15                	je     801020 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80100b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801011:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801016:	f7 f1                	div    %ecx
  801018:	e9 29 ff ff ff       	jmp    800f46 <__umoddi3+0x42>
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
  801025:	31 d2                	xor    %edx,%edx
  801027:	f7 75 ec             	divl   -0x14(%ebp)
  80102a:	89 c1                	mov    %eax,%ecx
  80102c:	eb dd                	jmp    80100b <__umoddi3+0x107>
  80102e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801030:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801033:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801036:	72 19                	jb     801051 <__umoddi3+0x14d>
  801038:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80103b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80103e:	76 11                	jbe    801051 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801040:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801043:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801046:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801049:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80104c:	e9 13 ff ff ff       	jmp    800f64 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801051:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801057:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80105a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  80105d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801060:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801063:	eb db                	jmp    801040 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801065:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801068:	19 f2                	sbb    %esi,%edx
  80106a:	e9 6f ff ff ff       	jmp    800fde <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80106f:	39 c7                	cmp    %eax,%edi
  801071:	72 f2                	jb     801065 <__umoddi3+0x161>
  801073:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801076:	e9 63 ff ff ff       	jmp    800fde <__umoddi3+0xda>
