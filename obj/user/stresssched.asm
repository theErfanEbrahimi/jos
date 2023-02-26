
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 bf 00 00 00       	call   8000f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800039:	e8 81 0c 00 00       	call   800cbf <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800045:	e8 f0 0c 00 00       	call   800d3a <fork>
  80004a:	85 c0                	test   %eax,%eax
  80004c:	74 12                	je     800060 <umain+0x2c>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004e:	43                   	inc    %ebx
  80004f:	83 fb 14             	cmp    $0x14,%ebx
  800052:	75 f1                	jne    800045 <umain+0x11>
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800054:	e8 47 0c 00 00       	call   800ca0 <sys_yield>
  800059:	e9 8a 00 00 00       	jmp    8000e8 <umain+0xb4>
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  80005e:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006e:	c1 e0 07             	shl    $0x7,%eax
  800071:	29 d0                	sub    %edx,%eax
  800073:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  800078:	8b 40 50             	mov    0x50(%eax),%eax
  80007b:	85 c0                	test   %eax,%eax
  80007d:	75 df                	jne    80005e <umain+0x2a>
  80007f:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800084:	e8 17 0c 00 00       	call   800ca0 <sys_yield>
  800089:	ba 00 00 00 00       	mov    $0x0,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008e:	a1 04 20 80 00       	mov    0x802004,%eax
  800093:	40                   	inc    %eax
  800094:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  800099:	42                   	inc    %edx
  80009a:	81 fa 10 27 00 00    	cmp    $0x2710,%edx
  8000a0:	75 ec                	jne    80008e <umain+0x5a>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a2:	43                   	inc    %ebx
  8000a3:	83 fb 0a             	cmp    $0xa,%ebx
  8000a6:	75 dc                	jne    800084 <umain+0x50>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ad:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b2:	74 17                	je     8000cb <umain+0x97>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b4:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b9:	50                   	push   %eax
  8000ba:	68 20 13 80 00       	push   $0x801320
  8000bf:	6a 21                	push   $0x21
  8000c1:	68 48 13 80 00       	push   $0x801348
  8000c6:	e8 89 00 00 00       	call   800154 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000cb:	a1 08 20 80 00       	mov    0x802008,%eax
  8000d0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d3:	8b 40 48             	mov    0x48(%eax),%eax
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	52                   	push   %edx
  8000da:	50                   	push   %eax
  8000db:	68 5b 13 80 00       	push   $0x80135b
  8000e0:	e8 10 01 00 00       	call   8001f5 <cprintf>
  8000e5:	83 c4 10             	add    $0x10,%esp

}
  8000e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    
	...

008000f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000fb:	e8 bf 0b 00 00       	call   800cbf <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800100:	25 ff 03 00 00       	and    $0x3ff,%eax
  800105:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80010c:	c1 e0 07             	shl    $0x7,%eax
  80010f:	29 d0                	sub    %edx,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 f6                	test   %esi,%esi
  80011d:	7e 07                	jle    800126 <libmain+0x36>
		binaryname = argv[0];
  80011f:	8b 03                	mov    (%ebx),%eax
  800121:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	53                   	push   %ebx
  80012a:	56                   	push   %esi
  80012b:	e8 04 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800130:	e8 0b 00 00 00       	call   800140 <exit>
  800135:	83 c4 10             	add    $0x10,%esp
}
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    
	...

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800146:	6a 00                	push   $0x0
  800148:	e8 91 0b 00 00       	call   800cde <sys_env_destroy>
  80014d:	83 c4 10             	add    $0x10,%esp
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80015b:	8d 45 14             	lea    0x14(%ebp),%eax
  80015e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800161:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800167:	e8 53 0b 00 00       	call   800cbf <sys_getenvid>
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	53                   	push   %ebx
  800176:	50                   	push   %eax
  800177:	68 84 13 80 00       	push   $0x801384
  80017c:	e8 74 00 00 00       	call   8001f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	ff 75 f8             	pushl  -0x8(%ebp)
  800187:	ff 75 10             	pushl  0x10(%ebp)
  80018a:	e8 15 00 00 00       	call   8001a4 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 77 13 80 00 	movl   $0x801377,(%esp)
  800196:	e8 5a 00 00 00       	call   8001f5 <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019e:	cc                   	int3   
  80019f:	eb fd                	jmp    80019e <_panic+0x4a>
  8001a1:	00 00                	add    %al,(%eax)
	...

008001a4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ad:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8001b4:	00 00 00 
	b.cnt = 0;
  8001b7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8001be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cd:	50                   	push   %eax
  8001ce:	68 0c 02 80 00       	push   $0x80020c
  8001d3:	e8 70 01 00 00       	call   800348 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d8:	83 c4 08             	add    $0x8,%esp
  8001db:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001e1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	e8 9e 08 00 00       	call   800a8b <sys_cputs>
  8001ed:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    

008001f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9a ff ff ff       	call   8001a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	53                   	push   %ebx
  800210:	83 ec 04             	sub    $0x4,%esp
  800213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800216:	8b 03                	mov    (%ebx),%eax
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021f:	40                   	inc    %eax
  800220:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800222:	3d ff 00 00 00       	cmp    $0xff,%eax
  800227:	75 1a                	jne    800243 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	68 ff 00 00 00       	push   $0xff
  800231:	8d 43 08             	lea    0x8(%ebx),%eax
  800234:	50                   	push   %eax
  800235:	e8 51 08 00 00       	call   800a8b <sys_cputs>
		b->idx = 0;
  80023a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800240:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800243:	ff 43 04             	incl   0x4(%ebx)
}
  800246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800249:	c9                   	leave  
  80024a:	c3                   	ret    
	...

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 1c             	sub    $0x1c,%esp
  800255:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800258:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800261:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800264:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800267:	8b 55 10             	mov    0x10(%ebp),%edx
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026d:	89 d6                	mov    %edx,%esi
  80026f:	bf 00 00 00 00       	mov    $0x0,%edi
  800274:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800277:	72 04                	jb     80027d <printnum+0x31>
  800279:	39 c2                	cmp    %eax,%edx
  80027b:	77 3f                	ja     8002bc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	ff 75 18             	pushl  0x18(%ebp)
  800283:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800286:	50                   	push   %eax
  800287:	52                   	push   %edx
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	e8 c8 0d 00 00       	call   801060 <__udivdi3>
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	52                   	push   %edx
  80029c:	50                   	push   %eax
  80029d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8002a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002a3:	e8 a4 ff ff ff       	call   80024c <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 14                	jmp    8002c1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	ff 75 e8             	pushl  -0x18(%ebp)
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	ff 55 ec             	call   *-0x14(%ebp)
  8002b9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bc:	4b                   	dec    %ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f ec                	jg     8002ad <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e8             	pushl  -0x18(%ebp)
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	57                   	push   %edi
  8002cb:	56                   	push   %esi
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	e8 b5 0e 00 00       	call   80118c <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 a7 13 80 00 	movsbl 0x8013a7(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff 55 ec             	call   *-0x14(%ebp)
  8002e5:	83 c4 10             	add    $0x10,%esp
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7e 0e                	jle    800308 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 42 08             	lea    0x8(%edx),%eax
  8002ff:	89 01                	mov    %eax,(%ecx)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	8b 52 04             	mov    0x4(%edx),%edx
  800306:	eb 22                	jmp    80032a <getuint+0x3a>
	else if (lflag)
  800308:	85 d2                	test   %edx,%edx
  80030a:	74 10                	je     80031c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 42 04             	lea    0x4(%edx),%eax
  800311:	89 01                	mov    %eax,(%ecx)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb 0e                	jmp    80032a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 42 04             	lea    0x4(%edx),%eax
  800321:	89 01                	mov    %eax,(%ecx)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032a:	c9                   	leave  
  80032b:	c3                   	ret    

0080032c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800332:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800335:	8b 11                	mov    (%ecx),%edx
  800337:	3b 51 04             	cmp    0x4(%ecx),%edx
  80033a:	73 0a                	jae    800346 <sprintputch+0x1a>
		*b->buf++ = ch;
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
  800341:	8d 42 01             	lea    0x1(%edx),%eax
  800344:	89 01                	mov    %eax,(%ecx)
}
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 3c             	sub    $0x3c,%esp
  800351:	8b 75 08             	mov    0x8(%ebp),%esi
  800354:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800357:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035a:	eb 1a                	jmp    800376 <vprintfmt+0x2e>
  80035c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80035f:	eb 15                	jmp    800376 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800361:	84 c0                	test   %al,%al
  800363:	0f 84 15 03 00 00    	je     80067e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800369:	83 ec 08             	sub    $0x8,%esp
  80036c:	57                   	push   %edi
  80036d:	0f b6 c0             	movzbl %al,%eax
  800370:	50                   	push   %eax
  800371:	ff d6                	call   *%esi
  800373:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800376:	8a 03                	mov    (%ebx),%al
  800378:	43                   	inc    %ebx
  800379:	3c 25                	cmp    $0x25,%al
  80037b:	75 e4                	jne    800361 <vprintfmt+0x19>
  80037d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800384:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800392:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800399:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80039d:	eb 0a                	jmp    8003a9 <vprintfmt+0x61>
  80039f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8003a6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8a 03                	mov    (%ebx),%al
  8003ab:	0f b6 d0             	movzbl %al,%edx
  8003ae:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8003b1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8003b4:	83 e8 23             	sub    $0x23,%eax
  8003b7:	3c 55                	cmp    $0x55,%al
  8003b9:	0f 87 9c 02 00 00    	ja     80065b <vprintfmt+0x313>
  8003bf:	0f b6 c0             	movzbl %al,%eax
  8003c2:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
  8003c9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8003cd:	eb d7                	jmp    8003a6 <vprintfmt+0x5e>
  8003cf:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8003d3:	eb d1                	jmp    8003a6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8003d5:	89 d9                	mov    %ebx,%ecx
  8003d7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003e1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003e4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003eb:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003ef:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003f0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003f3:	83 f8 09             	cmp    $0x9,%eax
  8003f6:	77 21                	ja     800419 <vprintfmt+0xd1>
  8003f8:	eb e4                	jmp    8003de <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fa:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fd:	8d 42 04             	lea    0x4(%edx),%eax
  800400:	89 45 14             	mov    %eax,0x14(%ebp)
  800403:	8b 12                	mov    (%edx),%edx
  800405:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800408:	eb 12                	jmp    80041c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80040a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80040e:	79 96                	jns    8003a6 <vprintfmt+0x5e>
  800410:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800417:	eb 8d                	jmp    8003a6 <vprintfmt+0x5e>
  800419:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800420:	79 84                	jns    8003a6 <vprintfmt+0x5e>
  800422:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800428:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80042f:	e9 72 ff ff ff       	jmp    8003a6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800434:	ff 45 d4             	incl   -0x2c(%ebp)
  800437:	e9 6a ff ff ff       	jmp    8003a6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043c:	8b 55 14             	mov    0x14(%ebp),%edx
  80043f:	8d 42 04             	lea    0x4(%edx),%eax
  800442:	89 45 14             	mov    %eax,0x14(%ebp)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	57                   	push   %edi
  800449:	ff 32                	pushl  (%edx)
  80044b:	ff d6                	call   *%esi
			break;
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	e9 07 ff ff ff       	jmp    80035c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	8b 55 14             	mov    0x14(%ebp),%edx
  800458:	8d 42 04             	lea    0x4(%edx),%eax
  80045b:	89 45 14             	mov    %eax,0x14(%ebp)
  80045e:	8b 02                	mov    (%edx),%eax
  800460:	85 c0                	test   %eax,%eax
  800462:	79 02                	jns    800466 <vprintfmt+0x11e>
  800464:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800466:	83 f8 0f             	cmp    $0xf,%eax
  800469:	7f 0b                	jg     800476 <vprintfmt+0x12e>
  80046b:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	75 15                	jne    80048b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800476:	50                   	push   %eax
  800477:	68 b8 13 80 00       	push   $0x8013b8
  80047c:	57                   	push   %edi
  80047d:	56                   	push   %esi
  80047e:	e8 6e 02 00 00       	call   8006f1 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	e9 d1 fe ff ff       	jmp    80035c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80048b:	52                   	push   %edx
  80048c:	68 c1 13 80 00       	push   $0x8013c1
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	e8 59 02 00 00       	call   8006f1 <printfmt>
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	e9 bc fe ff ff       	jmp    80035c <vprintfmt+0x14>
  8004a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ac:	8d 42 04             	lea    0x4(%edx),%eax
  8004af:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b2:	8b 1a                	mov    (%edx),%ebx
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	75 05                	jne    8004bd <vprintfmt+0x175>
  8004b8:	bb c4 13 80 00       	mov    $0x8013c4,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004bd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8004c1:	7e 66                	jle    800529 <vprintfmt+0x1e1>
  8004c3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8004c7:	74 60                	je     800529 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	51                   	push   %ecx
  8004cd:	53                   	push   %ebx
  8004ce:	e8 57 02 00 00       	call   80072a <strnlen>
  8004d3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8004d6:	29 c1                	sub    %eax,%ecx
  8004d8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004e2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	57                   	push   %edi
  8004eb:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	ff 4d d8             	decl   -0x28(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fa:	7f eb                	jg     8004e7 <vprintfmt+0x19f>
  8004fc:	eb 2b                	jmp    800529 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800501:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800505:	74 15                	je     80051c <vprintfmt+0x1d4>
  800507:	8d 42 e0             	lea    -0x20(%edx),%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 0d                	jbe    80051c <vprintfmt+0x1d4>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	57                   	push   %edi
  800513:	6a 3f                	push   $0x3f
  800515:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	eb 0a                	jmp    800526 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	57                   	push   %edi
  800520:	52                   	push   %edx
  800521:	ff d6                	call   *%esi
  800523:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800526:	ff 4d d8             	decl   -0x28(%ebp)
  800529:	8a 03                	mov    (%ebx),%al
  80052b:	43                   	inc    %ebx
  80052c:	84 c0                	test   %al,%al
  80052e:	74 1b                	je     80054b <vprintfmt+0x203>
  800530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800534:	78 c8                	js     8004fe <vprintfmt+0x1b6>
  800536:	ff 4d dc             	decl   -0x24(%ebp)
  800539:	79 c3                	jns    8004fe <vprintfmt+0x1b6>
  80053b:	eb 0e                	jmp    80054b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	57                   	push   %edi
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	ff 4d d8             	decl   -0x28(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054f:	7f ec                	jg     80053d <vprintfmt+0x1f5>
  800551:	e9 06 fe ff ff       	jmp    80035c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800556:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80055a:	7e 10                	jle    80056c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80055c:	8b 55 14             	mov    0x14(%ebp),%edx
  80055f:	8d 42 08             	lea    0x8(%edx),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
  800565:	8b 02                	mov    (%edx),%eax
  800567:	8b 52 04             	mov    0x4(%edx),%edx
  80056a:	eb 20                	jmp    80058c <vprintfmt+0x244>
	else if (lflag)
  80056c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800570:	74 0e                	je     800580 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	99                   	cltd   
  80057e:	eb 0c                	jmp    80058c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058c:	89 d1                	mov    %edx,%ecx
  80058e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800590:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800593:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800596:	85 c9                	test   %ecx,%ecx
  800598:	78 0a                	js     8005a4 <vprintfmt+0x25c>
  80059a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80059f:	e9 89 00 00 00       	jmp    80062d <vprintfmt+0x2e5>
				putch('-', putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	57                   	push   %edi
  8005a8:	6a 2d                	push   $0x2d
  8005aa:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ac:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8005af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005b2:	f7 da                	neg    %edx
  8005b4:	83 d1 00             	adc    $0x0,%ecx
  8005b7:	f7 d9                	neg    %ecx
  8005b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb 6a                	jmp    80062d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c9:	e8 22 fd ff ff       	call   8002f0 <getuint>
  8005ce:	89 d1                	mov    %edx,%ecx
  8005d0:	89 c2                	mov    %eax,%edx
  8005d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005d7:	eb 54                	jmp    80062d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005df:	e8 0c fd ff ff       	call   8002f0 <getuint>
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
  8005e8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005ed:	eb 3e                	jmp    80062d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 30                	push   $0x30
  8005f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 78                	push   $0x78
  8005fd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ff:	8b 55 14             	mov    0x14(%ebp),%edx
  800602:	8d 42 04             	lea    0x4(%edx),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
  800608:	8b 12                	mov    (%edx),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	eb 14                	jmp    80062d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800619:	8d 45 14             	lea    0x14(%ebp),%eax
  80061c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80061f:	e8 cc fc ff ff       	call   8002f0 <getuint>
  800624:	89 d1                	mov    %edx,%ecx
  800626:	89 c2                	mov    %eax,%edx
  800628:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	ff 75 d8             	pushl  -0x28(%ebp)
  800638:	53                   	push   %ebx
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	89 fa                	mov    %edi,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 08 fc ff ff       	call   80024c <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	e9 10 fd ff ff       	jmp    80035c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	57                   	push   %edi
  800650:	52                   	push   %edx
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	e9 01 fd ff ff       	jmp    80035c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	6a 25                	push   $0x25
  800661:	ff d6                	call   *%esi
  800663:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800666:	83 ea 02             	sub    $0x2,%edx
  800669:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066c:	8a 02                	mov    (%edx),%al
  80066e:	4a                   	dec    %edx
  80066f:	3c 25                	cmp    $0x25,%al
  800671:	75 f9                	jne    80066c <vprintfmt+0x324>
  800673:	83 c2 02             	add    $0x2,%edx
  800676:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800679:	e9 de fc ff ff       	jmp    80035c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80067e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	c9                   	leave  
  800685:	c3                   	ret    

00800686 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	83 ec 18             	sub    $0x18,%esp
  80068c:	8b 55 08             	mov    0x8(%ebp),%edx
  80068f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800692:	85 d2                	test   %edx,%edx
  800694:	74 37                	je     8006cd <vsnprintf+0x47>
  800696:	85 c0                	test   %eax,%eax
  800698:	7e 33                	jle    8006cd <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006a1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8006a8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ab:	ff 75 14             	pushl  0x14(%ebp)
  8006ae:	ff 75 10             	pushl  0x10(%ebp)
  8006b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	68 2c 03 80 00       	push   $0x80032c
  8006ba:	e8 89 fc ff ff       	call   800348 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	eb 05                	jmp    8006d2 <vsnprintf+0x4c>
  8006cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006e0:	50                   	push   %eax
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 97 ff ff ff       	call   800686 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006fd:	50                   	push   %eax
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 3c fc ff ff       	call   800348 <vprintfmt>
	va_end(ap);
  80070c:	83 c4 10             	add    $0x10,%esp
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
  800711:	00 00                	add    %al,(%eax)
	...

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 01                	jmp    800722 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800721:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800726:	75 f9                	jne    800721 <strlen+0xd>
		n++;
	return n;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	eb 01                	jmp    80073b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80073a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	39 d0                	cmp    %edx,%eax
  80073d:	74 06                	je     800745 <strnlen+0x1b>
  80073f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800743:	75 f5                	jne    80073a <strnlen+0x10>
		n++;
	return n;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800750:	8a 01                	mov    (%ecx),%al
  800752:	88 02                	mov    %al,(%edx)
  800754:	42                   	inc    %edx
  800755:	41                   	inc    %ecx
  800756:	84 c0                	test   %al,%al
  800758:	75 f6                	jne    800750 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800766:	53                   	push   %ebx
  800767:	e8 a8 ff ff ff       	call   800714 <strlen>
	strcpy(dst + len, src);
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800772:	50                   	push   %eax
  800773:	e8 cf ff ff ff       	call   800747 <strcpy>
	return dst;
}
  800778:	89 d8                	mov    %ebx,%eax
  80077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80078d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800792:	eb 0c                	jmp    8007a0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800794:	8a 02                	mov    (%edx),%al
  800796:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800799:	80 3a 01             	cmpb   $0x1,(%edx)
  80079c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	41                   	inc    %ecx
  8007a0:	39 d9                	cmp    %ebx,%ecx
  8007a2:	75 f0                	jne    800794 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a4:	89 f0                	mov    %esi,%eax
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 c9                	test   %ecx,%ecx
  8007ba:	75 04                	jne    8007c0 <strlcpy+0x16>
  8007bc:	89 f0                	mov    %esi,%eax
  8007be:	eb 14                	jmp    8007d4 <strlcpy+0x2a>
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	eb 04                	jmp    8007c8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	88 10                	mov    %dl,(%eax)
  8007c6:	40                   	inc    %eax
  8007c7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c8:	49                   	dec    %ecx
  8007c9:	74 06                	je     8007d1 <strlcpy+0x27>
  8007cb:	8a 13                	mov    (%ebx),%dl
  8007cd:	84 d2                	test   %dl,%dl
  8007cf:	75 f3                	jne    8007c4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007d1:	c6 00 00             	movb   $0x0,(%eax)
  8007d4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	eb 02                	jmp    8007e7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007e5:	42                   	inc    %edx
  8007e6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e7:	8a 02                	mov    (%edx),%al
  8007e9:	84 c0                	test   %al,%al
  8007eb:	74 04                	je     8007f1 <strcmp+0x17>
  8007ed:	3a 01                	cmp    (%ecx),%al
  8007ef:	74 f4                	je     8007e5 <strcmp+0xb>
  8007f1:	0f b6 c0             	movzbl %al,%eax
  8007f4:	0f b6 11             	movzbl (%ecx),%edx
  8007f7:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800805:	8b 55 10             	mov    0x10(%ebp),%edx
  800808:	eb 03                	jmp    80080d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80080a:	4a                   	dec    %edx
  80080b:	41                   	inc    %ecx
  80080c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080d:	85 d2                	test   %edx,%edx
  80080f:	75 07                	jne    800818 <strncmp+0x1d>
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 14                	jmp    80082c <strncmp+0x31>
  800818:	8a 01                	mov    (%ecx),%al
  80081a:	84 c0                	test   %al,%al
  80081c:	74 04                	je     800822 <strncmp+0x27>
  80081e:	3a 03                	cmp    (%ebx),%al
  800820:	74 e8                	je     80080a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 d0             	movzbl %al,%edx
  800825:	0f b6 03             	movzbl (%ebx),%eax
  800828:	29 c2                	sub    %eax,%edx
  80082a:	89 d0                	mov    %edx,%eax
}
  80082c:	5b                   	pop    %ebx
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800838:	eb 05                	jmp    80083f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80083a:	38 ca                	cmp    %cl,%dl
  80083c:	74 0c                	je     80084a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083e:	40                   	inc    %eax
  80083f:	8a 10                	mov    (%eax),%dl
  800841:	84 d2                	test   %dl,%dl
  800843:	75 f5                	jne    80083a <strchr+0xb>
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800855:	eb 05                	jmp    80085c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	74 07                	je     800862 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80085b:	40                   	inc    %eax
  80085c:	8a 10                	mov    (%eax),%dl
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f5                	jne    800857 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800870:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800873:	85 db                	test   %ebx,%ebx
  800875:	74 36                	je     8008ad <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800877:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087d:	75 29                	jne    8008a8 <memset+0x44>
  80087f:	f6 c3 03             	test   $0x3,%bl
  800882:	75 24                	jne    8008a8 <memset+0x44>
		c &= 0xFF;
  800884:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800887:	89 d6                	mov    %edx,%esi
  800889:	c1 e6 08             	shl    $0x8,%esi
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	c1 e0 18             	shl    $0x18,%eax
  800891:	89 d1                	mov    %edx,%ecx
  800893:	c1 e1 10             	shl    $0x10,%ecx
  800896:	09 c8                	or     %ecx,%eax
  800898:	09 c2                	or     %eax,%edx
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	09 d0                	or     %edx,%eax
  80089e:	89 d9                	mov    %ebx,%ecx
  8008a0:	c1 e9 02             	shr    $0x2,%ecx
  8008a3:	fc                   	cld    
  8008a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a6:	eb 05                	jmp    8008ad <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a8:	89 d9                	mov    %ebx,%ecx
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8008c2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008c4:	39 c6                	cmp    %eax,%esi
  8008c6:	73 36                	jae    8008fe <memmove+0x4a>
  8008c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cb:	39 d0                	cmp    %edx,%eax
  8008cd:	73 2f                	jae    8008fe <memmove+0x4a>
		s += n;
		d += n;
  8008cf:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	f6 c2 03             	test   $0x3,%dl
  8008d5:	75 1b                	jne    8008f2 <memmove+0x3e>
  8008d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dd:	75 13                	jne    8008f2 <memmove+0x3e>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 0e                	jne    8008f2 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008e4:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008e7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
  8008ed:	fd                   	std    
  8008ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f0:	eb 09                	jmp    8008fb <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f2:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008f5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f8:	fd                   	std    
  8008f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fb:	fc                   	cld    
  8008fc:	eb 20                	jmp    80091e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800904:	75 15                	jne    80091b <memmove+0x67>
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 0d                	jne    80091b <memmove+0x67>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 08                	jne    80091b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	fc                   	cld    
  800917:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800919:	eb 03                	jmp    80091e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091b:	fc                   	cld    
  80091c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800925:	ff 75 10             	pushl  0x10(%ebp)
  800928:	ff 75 0c             	pushl  0xc(%ebp)
  80092b:	ff 75 08             	pushl  0x8(%ebp)
  80092e:	e8 81 ff ff ff       	call   8008b4 <memmove>
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	53                   	push   %ebx
  800939:	83 ec 04             	sub    $0x4,%esp
  80093c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800945:	eb 1b                	jmp    800962 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800947:	8a 1a                	mov    (%edx),%bl
  800949:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80094c:	8a 19                	mov    (%ecx),%bl
  80094e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800951:	74 0d                	je     800960 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800953:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800957:	0f b6 c3             	movzbl %bl,%eax
  80095a:	29 c2                	sub    %eax,%edx
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	eb 0d                	jmp    80096d <memcmp+0x38>
		s1++, s2++;
  800960:	42                   	inc    %edx
  800961:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	48                   	dec    %eax
  800963:	83 f8 ff             	cmp    $0xffffffff,%eax
  800966:	75 df                	jne    800947 <memcmp+0x12>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80096d:	83 c4 04             	add    $0x4,%esp
  800970:	5b                   	pop    %ebx
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	03 55 10             	add    0x10(%ebp),%edx
  800981:	eb 05                	jmp    800988 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800983:	38 08                	cmp    %cl,(%eax)
  800985:	74 05                	je     80098c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800987:	40                   	inc    %eax
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	72 f7                	jb     800983 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	83 ec 04             	sub    $0x4,%esp
  800997:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099a:	8b 75 10             	mov    0x10(%ebp),%esi
  80099d:	eb 01                	jmp    8009a0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80099f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a0:	8a 01                	mov    (%ecx),%al
  8009a2:	3c 20                	cmp    $0x20,%al
  8009a4:	74 f9                	je     80099f <strtol+0x11>
  8009a6:	3c 09                	cmp    $0x9,%al
  8009a8:	74 f5                	je     80099f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009aa:	3c 2b                	cmp    $0x2b,%al
  8009ac:	75 0a                	jne    8009b8 <strtol+0x2a>
		s++;
  8009ae:	41                   	inc    %ecx
  8009af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009b6:	eb 17                	jmp    8009cf <strtol+0x41>
	else if (*s == '-')
  8009b8:	3c 2d                	cmp    $0x2d,%al
  8009ba:	74 09                	je     8009c5 <strtol+0x37>
  8009bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009c3:	eb 0a                	jmp    8009cf <strtol+0x41>
		s++, neg = 1;
  8009c5:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009c8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cf:	85 f6                	test   %esi,%esi
  8009d1:	74 05                	je     8009d8 <strtol+0x4a>
  8009d3:	83 fe 10             	cmp    $0x10,%esi
  8009d6:	75 1a                	jne    8009f2 <strtol+0x64>
  8009d8:	8a 01                	mov    (%ecx),%al
  8009da:	3c 30                	cmp    $0x30,%al
  8009dc:	75 10                	jne    8009ee <strtol+0x60>
  8009de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e2:	75 0a                	jne    8009ee <strtol+0x60>
		s += 2, base = 16;
  8009e4:	83 c1 02             	add    $0x2,%ecx
  8009e7:	be 10 00 00 00       	mov    $0x10,%esi
  8009ec:	eb 04                	jmp    8009f2 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009ee:	85 f6                	test   %esi,%esi
  8009f0:	74 07                	je     8009f9 <strtol+0x6b>
  8009f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f7:	eb 13                	jmp    800a0c <strtol+0x7e>
  8009f9:	3c 30                	cmp    $0x30,%al
  8009fb:	74 07                	je     800a04 <strtol+0x76>
  8009fd:	be 0a 00 00 00       	mov    $0xa,%esi
  800a02:	eb ee                	jmp    8009f2 <strtol+0x64>
		s++, base = 8;
  800a04:	41                   	inc    %ecx
  800a05:	be 08 00 00 00       	mov    $0x8,%esi
  800a0a:	eb e6                	jmp    8009f2 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0c:	8a 11                	mov    (%ecx),%dl
  800a0e:	88 d3                	mov    %dl,%bl
  800a10:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a13:	3c 09                	cmp    $0x9,%al
  800a15:	77 08                	ja     800a1f <strtol+0x91>
			dig = *s - '0';
  800a17:	0f be c2             	movsbl %dl,%eax
  800a1a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a1d:	eb 1c                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a1f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a22:	3c 19                	cmp    $0x19,%al
  800a24:	77 08                	ja     800a2e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a26:	0f be c2             	movsbl %dl,%eax
  800a29:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a2c:	eb 0d                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a31:	3c 19                	cmp    $0x19,%al
  800a33:	77 15                	ja     800a4a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a35:	0f be c2             	movsbl %dl,%eax
  800a38:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a3b:	39 f2                	cmp    %esi,%edx
  800a3d:	7d 0b                	jge    800a4a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a3f:	41                   	inc    %ecx
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	0f af c6             	imul   %esi,%eax
  800a45:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a48:	eb c2                	jmp    800a0c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a4a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a50:	74 05                	je     800a57 <strtol+0xc9>
		*endptr = (char *) s;
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a55:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a5b:	74 04                	je     800a61 <strtol+0xd3>
  800a5d:	89 c7                	mov    %eax,%edi
  800a5f:	f7 df                	neg    %edi
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	83 c4 04             	add    $0x4,%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    
	...

00800a6c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b8 01 00 00 00       	mov    $0x1,%eax
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7c:	89 fa                	mov    %edi,%edx
  800a7e:	89 f9                	mov    %edi,%ecx
  800a80:	89 fb                	mov    %edi,%ebx
  800a82:	89 fe                	mov    %edi,%esi
  800a84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 04             	sub    $0x4,%esp
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9f:	89 f8                	mov    %edi,%eax
  800aa1:	89 fb                	mov    %edi,%ebx
  800aa3:	89 fe                	mov    %edi,%esi
  800aa5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa7:	83 c4 04             	add    $0x4,%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 0c             	sub    $0xc,%esp
  800ab8:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	89 f9                	mov    %edi,%ecx
  800ac7:	89 fb                	mov    %edi,%ebx
  800ac9:	89 fe                	mov    %edi,%esi
  800acb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800acd:	85 c0                	test   %eax,%eax
  800acf:	7e 17                	jle    800ae8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad1:	83 ec 0c             	sub    $0xc,%esp
  800ad4:	50                   	push   %eax
  800ad5:	6a 0d                	push   $0xd
  800ad7:	68 9f 16 80 00       	push   $0x80169f
  800adc:	6a 23                	push   $0x23
  800ade:	68 bc 16 80 00       	push   $0x8016bc
  800ae3:	e8 6c f6 ff ff       	call   800154 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 55 08             	mov    0x8(%ebp),%edx
  800af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aff:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b07:	be 00 00 00 00       	mov    $0x0,%esi
  800b0c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2c:	89 fb                	mov    %edi,%ebx
  800b2e:	89 fe                	mov    %edi,%esi
  800b30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b32:	85 c0                	test   %eax,%eax
  800b34:	7e 17                	jle    800b4d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	50                   	push   %eax
  800b3a:	6a 0a                	push   $0xa
  800b3c:	68 9f 16 80 00       	push   $0x80169f
  800b41:	6a 23                	push   $0x23
  800b43:	68 bc 16 80 00       	push   $0x8016bc
  800b48:	e8 07 f6 ff ff       	call   800154 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	b8 09 00 00 00       	mov    $0x9,%eax
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	89 fb                	mov    %edi,%ebx
  800b70:	89 fe                	mov    %edi,%esi
  800b72:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b74:	85 c0                	test   %eax,%eax
  800b76:	7e 17                	jle    800b8f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 09                	push   $0x9
  800b7e:	68 9f 16 80 00       	push   $0x80169f
  800b83:	6a 23                	push   $0x23
  800b85:	68 bc 16 80 00       	push   $0x8016bc
  800b8a:	e8 c5 f5 ff ff       	call   800154 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb0:	89 fb                	mov    %edi,%ebx
  800bb2:	89 fe                	mov    %edi,%esi
  800bb4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	7e 17                	jle    800bd1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 08                	push   $0x8
  800bc0:	68 9f 16 80 00       	push   $0x80169f
  800bc5:	6a 23                	push   $0x23
  800bc7:	68 bc 16 80 00       	push   $0x8016bc
  800bcc:	e8 83 f5 ff ff       	call   800154 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	8b 55 08             	mov    0x8(%ebp),%edx
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bed:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf2:	89 fb                	mov    %edi,%ebx
  800bf4:	89 fe                	mov    %edi,%esi
  800bf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 17                	jle    800c13 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 06                	push   $0x6
  800c02:	68 9f 16 80 00       	push   $0x80169f
  800c07:	6a 23                	push   $0x23
  800c09:	68 bc 16 80 00       	push   $0x8016bc
  800c0e:	e8 41 f5 ff ff       	call   800154 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c30:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c33:	b8 05 00 00 00       	mov    $0x5,%eax
  800c38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 17                	jle    800c55 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	50                   	push   %eax
  800c42:	6a 05                	push   $0x5
  800c44:	68 9f 16 80 00       	push   $0x80169f
  800c49:	6a 23                	push   $0x23
  800c4b:	68 bc 16 80 00       	push   $0x8016bc
  800c50:	e8 ff f4 ff ff       	call   800154 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	c9                   	leave  
  800c5c:	c3                   	ret    

00800c5d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c74:	bf 00 00 00 00       	mov    $0x0,%edi
  800c79:	89 fe                	mov    %edi,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 04                	push   $0x4
  800c87:	68 9f 16 80 00       	push   $0x80169f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 bc 16 80 00       	push   $0x8016bc
  800c93:	e8 bc f4 ff ff       	call   800154 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cab:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb0:	89 fa                	mov    %edi,%edx
  800cb2:	89 f9                	mov    %edi,%ecx
  800cb4:	89 fb                	mov    %edi,%ebx
  800cb6:	89 fe                	mov    %edi,%esi
  800cb8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cca:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccf:	89 fa                	mov    %edi,%edx
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	89 fb                	mov    %edi,%ebx
  800cd5:	89 fe                	mov    %edi,%esi
  800cd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	b8 03 00 00 00       	mov    $0x3,%eax
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf4:	89 f9                	mov    %edi,%ecx
  800cf6:	89 fb                	mov    %edi,%ebx
  800cf8:	89 fe                	mov    %edi,%esi
  800cfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 17                	jle    800d17 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 03                	push   $0x3
  800d06:	68 9f 16 80 00       	push   $0x80169f
  800d0b:	6a 23                	push   $0x23
  800d0d:	68 bc 16 80 00       	push   $0x8016bc
  800d12:	e8 3d f4 ff ff       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    
	...

00800d20 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d26:	68 ca 16 80 00       	push   $0x8016ca
  800d2b:	68 92 00 00 00       	push   $0x92
  800d30:	68 e0 16 80 00       	push   $0x8016e0
  800d35:	e8 1a f4 ff ff       	call   800154 <_panic>

00800d3a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800d43:	68 db 0e 80 00       	push   $0x800edb
  800d48:	e8 6b 02 00 00       	call   800fb8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800d4d:	ba 07 00 00 00       	mov    $0x7,%edx
  800d52:	89 d0                	mov    %edx,%eax
  800d54:	cd 30                	int    $0x30
  800d56:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	75 25                	jne    800d84 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800d5f:	e8 5b ff ff ff       	call   800cbf <sys_getenvid>
  800d64:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d70:	c1 e0 07             	shl    $0x7,%eax
  800d73:	29 d0                	sub    %edx,%eax
  800d75:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d7a:	a3 08 20 80 00       	mov    %eax,0x802008
  800d7f:	e9 4d 01 00 00       	jmp    800ed1 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800d84:	85 c0                	test   %eax,%eax
  800d86:	79 12                	jns    800d9a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d88:	50                   	push   %eax
  800d89:	68 eb 16 80 00       	push   $0x8016eb
  800d8e:	6a 77                	push   $0x77
  800d90:	68 e0 16 80 00       	push   $0x8016e0
  800d95:	e8 ba f3 ff ff       	call   800154 <_panic>
  800d9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800d9f:	89 d8                	mov    %ebx,%eax
  800da1:	c1 e8 16             	shr    $0x16,%eax
  800da4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dab:	a8 01                	test   $0x1,%al
  800dad:	0f 84 ab 00 00 00    	je     800e5e <fork+0x124>
  800db3:	89 da                	mov    %ebx,%edx
  800db5:	c1 ea 0c             	shr    $0xc,%edx
  800db8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800dbf:	a8 01                	test   $0x1,%al
  800dc1:	0f 84 97 00 00 00    	je     800e5e <fork+0x124>
  800dc7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800dce:	a8 04                	test   $0x4,%al
  800dd0:	0f 84 88 00 00 00    	je     800e5e <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800dd6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800ddd:	89 d6                	mov    %edx,%esi
  800ddf:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800dea:	a9 02 08 00 00       	test   $0x802,%eax
  800def:	74 0f                	je     800e00 <fork+0xc6>
  800df1:	f6 c4 04             	test   $0x4,%ah
  800df4:	75 0a                	jne    800e00 <fork+0xc6>
		perm &= ~PTE_W;
  800df6:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800e00:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e06:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	52                   	push   %edx
  800e0d:	56                   	push   %esi
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	6a 00                	push   $0x0
  800e12:	e8 04 fe ff ff       	call   800c1b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 14                	jns    800e32 <fork+0xf8>
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 34 17 80 00       	push   $0x801734
  800e26:	6a 52                	push   $0x52
  800e28:	68 e0 16 80 00       	push   $0x8016e0
  800e2d:	e8 22 f3 ff ff       	call   800154 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	ff 75 f0             	pushl  -0x10(%ebp)
  800e38:	56                   	push   %esi
  800e39:	6a 00                	push   $0x0
  800e3b:	56                   	push   %esi
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 d8 fd ff ff       	call   800c1b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800e43:	83 c4 20             	add    $0x20,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 14                	jns    800e5e <fork+0x124>
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 58 17 80 00       	push   $0x801758
  800e52:	6a 55                	push   $0x55
  800e54:	68 e0 16 80 00       	push   $0x8016e0
  800e59:	e8 f6 f2 ff ff       	call   800154 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800e5e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800e64:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800e6a:	0f 85 2f ff ff ff    	jne    800d9f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	6a 07                	push   $0x7
  800e75:	68 00 f0 bf ee       	push   $0xeebff000
  800e7a:	57                   	push   %edi
  800e7b:	e8 dd fd ff ff       	call   800c5d <sys_page_alloc>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	85 c0                	test   %eax,%eax
  800e85:	79 15                	jns    800e9c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800e87:	50                   	push   %eax
  800e88:	68 09 17 80 00       	push   $0x801709
  800e8d:	68 83 00 00 00       	push   $0x83
  800e92:	68 e0 16 80 00       	push   $0x8016e0
  800e97:	e8 b8 f2 ff ff       	call   800154 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	68 38 10 80 00       	push   $0x801038
  800ea4:	57                   	push   %edi
  800ea5:	e8 69 fc ff ff       	call   800b13 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800eaa:	83 c4 08             	add    $0x8,%esp
  800ead:	6a 02                	push   $0x2
  800eaf:	57                   	push   %edi
  800eb0:	e8 e2 fc ff ff       	call   800b97 <sys_env_set_status>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	79 15                	jns    800ed1 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800ebc:	50                   	push   %eax
  800ebd:	68 1c 17 80 00       	push   $0x80171c
  800ec2:	68 89 00 00 00       	push   $0x89
  800ec7:	68 e0 16 80 00       	push   $0x8016e0
  800ecc:	e8 83 f2 ff ff       	call   800154 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800ed1:	89 f8                	mov    %edi,%eax
  800ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	53                   	push   %ebx
  800edf:	83 ec 04             	sub    $0x4,%esp
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800ee5:	8b 1a                	mov    (%edx),%ebx
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	c1 e8 0c             	shr    $0xc,%eax
  800eec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800ef3:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ef7:	74 05                	je     800efe <pgfault+0x23>
  800ef9:	f6 c4 08             	test   $0x8,%ah
  800efc:	75 14                	jne    800f12 <pgfault+0x37>
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	68 7c 17 80 00       	push   $0x80177c
  800f06:	6a 1e                	push   $0x1e
  800f08:	68 e0 16 80 00       	push   $0x8016e0
  800f0d:	e8 42 f2 ff ff       	call   800154 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800f12:	83 ec 04             	sub    $0x4,%esp
  800f15:	6a 07                	push   $0x7
  800f17:	68 00 f0 7f 00       	push   $0x7ff000
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 3a fd ff ff       	call   800c5d <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800f23:	83 c4 10             	add    $0x10,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	79 14                	jns    800f3e <pgfault+0x63>
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	68 a8 17 80 00       	push   $0x8017a8
  800f32:	6a 2a                	push   $0x2a
  800f34:	68 e0 16 80 00       	push   $0x8016e0
  800f39:	e8 16 f2 ff ff       	call   800154 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800f3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	68 00 10 00 00       	push   $0x1000
  800f4c:	53                   	push   %ebx
  800f4d:	68 00 f0 7f 00       	push   $0x7ff000
  800f52:	e8 5d f9 ff ff       	call   8008b4 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800f57:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5e:	53                   	push   %ebx
  800f5f:	6a 00                	push   $0x0
  800f61:	68 00 f0 7f 00       	push   $0x7ff000
  800f66:	6a 00                	push   $0x0
  800f68:	e8 ae fc ff ff       	call   800c1b <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	79 14                	jns    800f88 <pgfault+0xad>
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 cc 17 80 00       	push   $0x8017cc
  800f7c:	6a 2e                	push   $0x2e
  800f7e:	68 e0 16 80 00       	push   $0x8016e0
  800f83:	e8 cc f1 ff ff       	call   800154 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	6a 00                	push   $0x0
  800f92:	e8 42 fc ff ff       	call   800bd9 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	79 14                	jns    800fb2 <pgfault+0xd7>
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	68 ec 17 80 00       	push   $0x8017ec
  800fa6:	6a 32                	push   $0x32
  800fa8:	68 e0 16 80 00       	push   $0x8016e0
  800fad:	e8 a2 f1 ff ff       	call   800154 <_panic>
	//panic("pgfault not implemented");
}
  800fb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    
	...

00800fb8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fbe:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800fc5:	75 64                	jne    80102b <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800fc7:	a1 08 20 80 00       	mov    0x802008,%eax
  800fcc:	8b 40 48             	mov    0x48(%eax),%eax
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	6a 07                	push   $0x7
  800fd4:	68 00 f0 bf ee       	push   $0xeebff000
  800fd9:	50                   	push   %eax
  800fda:	e8 7e fc ff ff       	call   800c5d <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 14                	jns    800ffa <set_pgfault_handler+0x42>
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 10 18 80 00       	push   $0x801810
  800fee:	6a 22                	push   $0x22
  800ff0:	68 7c 18 80 00       	push   $0x80187c
  800ff5:	e8 5a f1 ff ff       	call   800154 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800ffa:	a1 08 20 80 00       	mov    0x802008,%eax
  800fff:	8b 40 48             	mov    0x48(%eax),%eax
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	68 38 10 80 00       	push   $0x801038
  80100a:	50                   	push   %eax
  80100b:	e8 03 fb ff ff       	call   800b13 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	79 14                	jns    80102b <set_pgfault_handler+0x73>
  801017:	83 ec 04             	sub    $0x4,%esp
  80101a:	68 40 18 80 00       	push   $0x801840
  80101f:	6a 25                	push   $0x25
  801021:	68 7c 18 80 00       	push   $0x80187c
  801026:	e8 29 f1 ff ff       	call   800154 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    
  801035:	00 00                	add    %al,(%eax)
	...

00801038 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801038:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801039:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80103e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801040:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801043:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801047:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80104a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  80104e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801052:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801054:	83 c4 08             	add    $0x8,%esp
	popal
  801057:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801058:	83 c4 04             	add    $0x4,%esp
	popfl
  80105b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80105c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  80105d:	c3                   	ret    
	...

00801060 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	83 ec 28             	sub    $0x28,%esp
  801068:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80106f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801076:	8b 45 10             	mov    0x10(%ebp),%eax
  801079:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80107c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80107f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801081:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801089:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80108f:	85 ff                	test   %edi,%edi
  801091:	75 21                	jne    8010b4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801093:	39 d1                	cmp    %edx,%ecx
  801095:	76 49                	jbe    8010e0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801097:	f7 f1                	div    %ecx
  801099:	89 c1                	mov    %eax,%ecx
  80109b:	31 c0                	xor    %eax,%eax
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8010a0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8010a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8010a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8010ac:	83 c4 28             	add    $0x28,%esp
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    
  8010b3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010b4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8010b7:	0f 87 97 00 00 00    	ja     801154 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010bd:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8010c0:	83 f0 1f             	xor    $0x1f,%eax
  8010c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c6:	75 34                	jne    8010fc <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010c8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8010cb:	72 08                	jb     8010d5 <__udivdi3+0x75>
  8010cd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8010d0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8010d3:	77 7f                	ja     801154 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010d5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010da:	31 c0                	xor    %eax,%eax
  8010dc:	eb c2                	jmp    8010a0 <__udivdi3+0x40>
  8010de:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	74 79                	je     801160 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8010ea:	89 fa                	mov    %edi,%edx
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8010f3:	f7 f1                	div    %ecx
  8010f5:	89 c1                	mov    %eax,%ecx
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	eb a5                	jmp    8010a0 <__udivdi3+0x40>
  8010fb:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8010fc:	b8 20 00 00 00       	mov    $0x20,%eax
  801101:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801104:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801107:	89 fa                	mov    %edi,%edx
  801109:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80110c:	d3 e2                	shl    %cl,%edx
  80110e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801111:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801114:	d3 e8                	shr    %cl,%eax
  801116:	89 d7                	mov    %edx,%edi
  801118:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80111a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80111d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801120:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801122:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801125:	d3 e0                	shl    %cl,%eax
  801127:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80112a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80112d:	d3 ea                	shr    %cl,%edx
  80112f:	09 d0                	or     %edx,%eax
  801131:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801134:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801137:	d3 ea                	shr    %cl,%edx
  801139:	f7 f7                	div    %edi
  80113b:	89 d7                	mov    %edx,%edi
  80113d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801140:	f7 e6                	mul    %esi
  801142:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801144:	39 d7                	cmp    %edx,%edi
  801146:	72 38                	jb     801180 <__udivdi3+0x120>
  801148:	74 27                	je     801171 <__udivdi3+0x111>
  80114a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80114d:	31 c0                	xor    %eax,%eax
  80114f:	e9 4c ff ff ff       	jmp    8010a0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801154:	31 c9                	xor    %ecx,%ecx
  801156:	31 c0                	xor    %eax,%eax
  801158:	e9 43 ff ff ff       	jmp    8010a0 <__udivdi3+0x40>
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801160:	b8 01 00 00 00       	mov    $0x1,%eax
  801165:	31 d2                	xor    %edx,%edx
  801167:	f7 75 f4             	divl   -0xc(%ebp)
  80116a:	89 c1                	mov    %eax,%ecx
  80116c:	e9 76 ff ff ff       	jmp    8010e7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801171:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801174:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801177:	d3 e0                	shl    %cl,%eax
  801179:	39 f0                	cmp    %esi,%eax
  80117b:	73 cd                	jae    80114a <__udivdi3+0xea>
  80117d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801180:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801183:	49                   	dec    %ecx
  801184:	31 c0                	xor    %eax,%eax
  801186:	e9 15 ff ff ff       	jmp    8010a0 <__udivdi3+0x40>
	...

0080118c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	57                   	push   %edi
  801190:	56                   	push   %esi
  801191:	83 ec 30             	sub    $0x30,%esp
  801194:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80119b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ab:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8011ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011b1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8011b3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8011b6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8011b9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011bc:	85 d2                	test   %edx,%edx
  8011be:	75 1c                	jne    8011dc <__umoddi3+0x50>
    {
      if (d0 > n1)
  8011c0:	89 fa                	mov    %edi,%edx
  8011c2:	39 f8                	cmp    %edi,%eax
  8011c4:	0f 86 c2 00 00 00    	jbe    80128c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011ca:	89 f0                	mov    %esi,%eax
  8011cc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8011ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8011d1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011d8:	eb 12                	jmp    8011ec <__umoddi3+0x60>
  8011da:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8011df:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8011e2:	76 18                	jbe    8011fc <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8011e4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8011e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8011ea:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8011ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8011f2:	83 c4 30             	add    $0x30,%esp
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    
  8011f9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8011fc:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801200:	83 f0 1f             	xor    $0x1f,%eax
  801203:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801206:	0f 84 ac 00 00 00    	je     8012b8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80120c:	b8 20 00 00 00       	mov    $0x20,%eax
  801211:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801214:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801217:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80121a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80121d:	d3 e2                	shl    %cl,%edx
  80121f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801222:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801225:	d3 e8                	shr    %cl,%eax
  801227:	89 d6                	mov    %edx,%esi
  801229:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80122b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80122e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801231:	d3 e0                	shl    %cl,%eax
  801233:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801236:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801239:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80123b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123e:	d3 e0                	shl    %cl,%eax
  801240:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801243:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801246:	d3 ea                	shr    %cl,%edx
  801248:	09 d0                	or     %edx,%eax
  80124a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80124d:	d3 ea                	shr    %cl,%edx
  80124f:	f7 f6                	div    %esi
  801251:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801254:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801257:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80125a:	0f 82 8d 00 00 00    	jb     8012ed <__umoddi3+0x161>
  801260:	0f 84 91 00 00 00    	je     8012f7 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801266:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801269:	29 c7                	sub    %eax,%edi
  80126b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80126d:	89 f2                	mov    %esi,%edx
  80126f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801272:	d3 e2                	shl    %cl,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801279:	d3 e8                	shr    %cl,%eax
  80127b:	09 c2                	or     %eax,%edx
  80127d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801280:	d3 ee                	shr    %cl,%esi
  801282:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801285:	e9 62 ff ff ff       	jmp    8011ec <__umoddi3+0x60>
  80128a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80128c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	74 15                	je     8012a8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801293:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801296:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801299:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80129b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129e:	f7 f1                	div    %ecx
  8012a0:	e9 29 ff ff ff       	jmp    8011ce <__umoddi3+0x42>
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8012a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ad:	31 d2                	xor    %edx,%edx
  8012af:	f7 75 ec             	divl   -0x14(%ebp)
  8012b2:	89 c1                	mov    %eax,%ecx
  8012b4:	eb dd                	jmp    801293 <__umoddi3+0x107>
  8012b6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8012b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012bb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8012be:	72 19                	jb     8012d9 <__umoddi3+0x14d>
  8012c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8012c6:	76 11                	jbe    8012d9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8012c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8012ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012d1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8012d4:	e9 13 ff ff ff       	jmp    8011ec <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8012e2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8012e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8012eb:	eb db                	jmp    8012c8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012ed:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8012f0:	19 f2                	sbb    %esi,%edx
  8012f2:	e9 6f ff ff ff       	jmp    801266 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012f7:	39 c7                	cmp    %eax,%edi
  8012f9:	72 f2                	jb     8012ed <__umoddi3+0x161>
  8012fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012fe:	e9 63 ff ff ff       	jmp    801266 <__umoddi3+0xda>
