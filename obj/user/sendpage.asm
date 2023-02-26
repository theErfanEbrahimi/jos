
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 67 01 00 00       	call   800198 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 53 0d 00 00       	call   800d92 <fork>
  80003f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 9d 00 00 00    	jne    8000e7 <umain+0xb3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	83 ec 04             	sub    $0x4,%esp
  80004d:	6a 00                	push   $0x0
  80004f:	68 00 00 b0 00       	push   $0xb00000
  800054:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800057:	50                   	push   %eax
  800058:	e8 4d 10 00 00       	call   8010aa <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005d:	83 c4 0c             	add    $0xc,%esp
  800060:	68 00 00 b0 00       	push   $0xb00000
  800065:	ff 75 fc             	pushl  -0x4(%ebp)
  800068:	68 c0 14 80 00       	push   $0x8014c0
  80006d:	e8 db 01 00 00       	call   80024d <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800072:	83 c4 04             	add    $0x4,%esp
  800075:	ff 35 00 20 80 00    	pushl  0x802000
  80007b:	e8 ec 06 00 00       	call   80076c <strlen>
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	50                   	push   %eax
  800084:	ff 35 00 20 80 00    	pushl  0x802000
  80008a:	68 00 00 b0 00       	push   $0xb00000
  80008f:	e8 bf 07 00 00       	call   800853 <strncmp>
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	75 10                	jne    8000ab <umain+0x77>
			cprintf("child received correct message\n");
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	68 d4 14 80 00       	push   $0x8014d4
  8000a3:	e8 a5 01 00 00       	call   80024d <cprintf>
  8000a8:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	ff 35 04 20 80 00    	pushl  0x802004
  8000b4:	e8 b3 06 00 00       	call   80076c <strlen>
  8000b9:	83 c4 0c             	add    $0xc,%esp
  8000bc:	40                   	inc    %eax
  8000bd:	50                   	push   %eax
  8000be:	ff 35 04 20 80 00    	pushl  0x802004
  8000c4:	68 00 00 b0 00       	push   $0xb00000
  8000c9:	e8 ac 08 00 00       	call   80097a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000ce:	6a 07                	push   $0x7
  8000d0:	68 00 00 b0 00       	push   $0xb00000
  8000d5:	6a 00                	push   $0x0
  8000d7:	ff 75 fc             	pushl  -0x4(%ebp)
  8000da:	e8 76 0f 00 00       	call   801055 <ipc_send>
		return;
  8000df:	83 c4 20             	add    $0x20,%esp
  8000e2:	e9 ad 00 00 00       	jmp    800194 <umain+0x160>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 b6 0b 00 00       	call   800cb5 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 00 20 80 00    	pushl  0x802000
  800108:	e8 5f 06 00 00       	call   80076c <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	40                   	inc    %eax
  800111:	50                   	push   %eax
  800112:	ff 35 00 20 80 00    	pushl  0x802000
  800118:	68 00 00 a0 00       	push   $0xa00000
  80011d:	e8 58 08 00 00       	call   80097a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800122:	6a 07                	push   $0x7
  800124:	68 00 00 a0 00       	push   $0xa00000
  800129:	6a 00                	push   $0x0
  80012b:	ff 75 fc             	pushl  -0x4(%ebp)
  80012e:	e8 22 0f 00 00       	call   801055 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800133:	83 c4 1c             	add    $0x1c,%esp
  800136:	6a 00                	push   $0x0
  800138:	68 00 00 a0 00       	push   $0xa00000
  80013d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	e8 64 0f 00 00       	call   8010aa <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	68 00 00 a0 00       	push   $0xa00000
  80014e:	ff 75 fc             	pushl  -0x4(%ebp)
  800151:	68 c0 14 80 00       	push   $0x8014c0
  800156:	e8 f2 00 00 00       	call   80024d <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015b:	83 c4 04             	add    $0x4,%esp
  80015e:	ff 35 04 20 80 00    	pushl  0x802004
  800164:	e8 03 06 00 00       	call   80076c <strlen>
  800169:	83 c4 0c             	add    $0xc,%esp
  80016c:	50                   	push   %eax
  80016d:	ff 35 04 20 80 00    	pushl  0x802004
  800173:	68 00 00 a0 00       	push   $0xa00000
  800178:	e8 d6 06 00 00       	call   800853 <strncmp>
  80017d:	83 c4 10             	add    $0x10,%esp
  800180:	85 c0                	test   %eax,%eax
  800182:	75 10                	jne    800194 <umain+0x160>
		cprintf("parent received correct message\n");
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	68 f4 14 80 00       	push   $0x8014f4
  80018c:	e8 bc 00 00 00       	call   80024d <cprintf>
  800191:	83 c4 10             	add    $0x10,%esp
	return;
}
  800194:	c9                   	leave  
  800195:	c3                   	ret    
	...

00800198 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	8b 75 08             	mov    0x8(%ebp),%esi
  8001a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8001a3:	e8 6f 0b 00 00       	call   800d17 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001a8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001b4:	c1 e0 07             	shl    $0x7,%eax
  8001b7:	29 d0                	sub    %edx,%eax
  8001b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001be:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c3:	85 f6                	test   %esi,%esi
  8001c5:	7e 07                	jle    8001ce <libmain+0x36>
		binaryname = argv[0];
  8001c7:	8b 03                	mov    (%ebx),%eax
  8001c9:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	53                   	push   %ebx
  8001d2:	56                   	push   %esi
  8001d3:	e8 5c fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001d8:	e8 0b 00 00 00       	call   8001e8 <exit>
  8001dd:	83 c4 10             	add    $0x10,%esp
}
  8001e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    
	...

008001e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8001ee:	6a 00                	push   $0x0
  8001f0:	e8 41 0b 00 00       	call   800d36 <sys_env_destroy>
  8001f5:	83 c4 10             	add    $0x10,%esp
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    
	...

008001fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800205:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80020c:	00 00 00 
	b.cnt = 0;
  80020f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800216:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800219:	ff 75 0c             	pushl  0xc(%ebp)
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	68 64 02 80 00       	push   $0x800264
  80022b:	e8 70 01 00 00       	call   8003a0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	83 c4 08             	add    $0x8,%esp
  800233:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800239:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80023f:	50                   	push   %eax
  800240:	e8 9e 08 00 00       	call   800ae3 <sys_cputs>
  800245:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800253:	8d 45 0c             	lea    0xc(%ebp),%eax
  800256:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800259:	50                   	push   %eax
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	e8 9a ff ff ff       	call   8001fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	53                   	push   %ebx
  800268:	83 ec 04             	sub    $0x4,%esp
  80026b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80026e:	8b 03                	mov    (%ebx),%eax
  800270:	8b 55 08             	mov    0x8(%ebp),%edx
  800273:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800277:	40                   	inc    %eax
  800278:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80027a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027f:	75 1a                	jne    80029b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	68 ff 00 00 00       	push   $0xff
  800289:	8d 43 08             	lea    0x8(%ebx),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 51 08 00 00       	call   800ae3 <sys_cputs>
		b->idx = 0;
  800292:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800298:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80029b:	ff 43 04             	incl   0x4(%ebx)
}
  80029e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    
	...

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 1c             	sub    $0x1c,%esp
  8002ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8002c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c5:	89 d6                	mov    %edx,%esi
  8002c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8002cc:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8002cf:	72 04                	jb     8002d5 <printnum+0x31>
  8002d1:	39 c2                	cmp    %eax,%edx
  8002d3:	77 3f                	ja     800314 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	ff 75 18             	pushl  0x18(%ebp)
  8002db:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002de:	50                   	push   %eax
  8002df:	52                   	push   %edx
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	e8 1c 0f 00 00       	call   80120c <__udivdi3>
  8002f0:	83 c4 18             	add    $0x18,%esp
  8002f3:	52                   	push   %edx
  8002f4:	50                   	push   %eax
  8002f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8002f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002fb:	e8 a4 ff ff ff       	call   8002a4 <printnum>
  800300:	83 c4 20             	add    $0x20,%esp
  800303:	eb 14                	jmp    800319 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e8             	pushl  -0x18(%ebp)
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff 55 ec             	call   *-0x14(%ebp)
  800311:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800314:	4b                   	dec    %ebx
  800315:	85 db                	test   %ebx,%ebx
  800317:	7f ec                	jg     800305 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	ff 75 e8             	pushl  -0x18(%ebp)
  80031f:	83 ec 04             	sub    $0x4,%esp
  800322:	57                   	push   %edi
  800323:	56                   	push   %esi
  800324:	ff 75 e4             	pushl  -0x1c(%ebp)
  800327:	ff 75 e0             	pushl  -0x20(%ebp)
  80032a:	e8 09 10 00 00       	call   801338 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 80 6e 15 80 00 	movsbl 0x80156e(%eax),%eax
  800339:	50                   	push   %eax
  80033a:	ff 55 ec             	call   *-0x14(%ebp)
  80033d:	83 c4 10             	add    $0x10,%esp
}
  800340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80034d:	83 fa 01             	cmp    $0x1,%edx
  800350:	7e 0e                	jle    800360 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 42 08             	lea    0x8(%edx),%eax
  800357:	89 01                	mov    %eax,(%ecx)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	8b 52 04             	mov    0x4(%edx),%edx
  80035e:	eb 22                	jmp    800382 <getuint+0x3a>
	else if (lflag)
  800360:	85 d2                	test   %edx,%edx
  800362:	74 10                	je     800374 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 42 04             	lea    0x4(%edx),%eax
  800369:	89 01                	mov    %eax,(%ecx)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	eb 0e                	jmp    800382 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 42 04             	lea    0x4(%edx),%eax
  800379:	89 01                	mov    %eax,(%ecx)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80038a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80038d:	8b 11                	mov    (%ecx),%edx
  80038f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800392:	73 0a                	jae    80039e <sprintputch+0x1a>
		*b->buf++ = ch;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	88 02                	mov    %al,(%edx)
  800399:	8d 42 01             	lea    0x1(%edx),%eax
  80039c:	89 01                	mov    %eax,(%ecx)
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	53                   	push   %ebx
  8003a6:	83 ec 3c             	sub    $0x3c,%esp
  8003a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b2:	eb 1a                	jmp    8003ce <vprintfmt+0x2e>
  8003b4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8003b7:	eb 15                	jmp    8003ce <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b9:	84 c0                	test   %al,%al
  8003bb:	0f 84 15 03 00 00    	je     8006d6 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	57                   	push   %edi
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	50                   	push   %eax
  8003c9:	ff d6                	call   *%esi
  8003cb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ce:	8a 03                	mov    (%ebx),%al
  8003d0:	43                   	inc    %ebx
  8003d1:	3c 25                	cmp    $0x25,%al
  8003d3:	75 e4                	jne    8003b9 <vprintfmt+0x19>
  8003d5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e3:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8003f5:	eb 0a                	jmp    800401 <vprintfmt+0x61>
  8003f7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8003fe:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8a 03                	mov    (%ebx),%al
  800403:	0f b6 d0             	movzbl %al,%edx
  800406:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800409:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80040c:	83 e8 23             	sub    $0x23,%eax
  80040f:	3c 55                	cmp    $0x55,%al
  800411:	0f 87 9c 02 00 00    	ja     8006b3 <vprintfmt+0x313>
  800417:	0f b6 c0             	movzbl %al,%eax
  80041a:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
  800421:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800425:	eb d7                	jmp    8003fe <vprintfmt+0x5e>
  800427:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80042b:	eb d1                	jmp    8003fe <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80042d:	89 d9                	mov    %ebx,%ecx
  80042f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800436:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800439:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80043c:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800440:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800443:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800447:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800448:	8d 42 d0             	lea    -0x30(%edx),%eax
  80044b:	83 f8 09             	cmp    $0x9,%eax
  80044e:	77 21                	ja     800471 <vprintfmt+0xd1>
  800450:	eb e4                	jmp    800436 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800452:	8b 55 14             	mov    0x14(%ebp),%edx
  800455:	8d 42 04             	lea    0x4(%edx),%eax
  800458:	89 45 14             	mov    %eax,0x14(%ebp)
  80045b:	8b 12                	mov    (%edx),%edx
  80045d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800460:	eb 12                	jmp    800474 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800462:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800466:	79 96                	jns    8003fe <vprintfmt+0x5e>
  800468:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80046f:	eb 8d                	jmp    8003fe <vprintfmt+0x5e>
  800471:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	79 84                	jns    8003fe <vprintfmt+0x5e>
  80047a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800480:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800487:	e9 72 ff ff ff       	jmp    8003fe <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048c:	ff 45 d4             	incl   -0x2c(%ebp)
  80048f:	e9 6a ff ff ff       	jmp    8003fe <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 55 14             	mov    0x14(%ebp),%edx
  800497:	8d 42 04             	lea    0x4(%edx),%eax
  80049a:	89 45 14             	mov    %eax,0x14(%ebp)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	57                   	push   %edi
  8004a1:	ff 32                	pushl  (%edx)
  8004a3:	ff d6                	call   *%esi
			break;
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	e9 07 ff ff ff       	jmp    8003b4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ad:	8b 55 14             	mov    0x14(%ebp),%edx
  8004b0:	8d 42 04             	lea    0x4(%edx),%eax
  8004b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b6:	8b 02                	mov    (%edx),%eax
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	79 02                	jns    8004be <vprintfmt+0x11e>
  8004bc:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x12e>
  8004c3:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 15                	jne    8004e3 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 7f 15 80 00       	push   $0x80157f
  8004d4:	57                   	push   %edi
  8004d5:	56                   	push   %esi
  8004d6:	e8 6e 02 00 00       	call   800749 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	e9 d1 fe ff ff       	jmp    8003b4 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e3:	52                   	push   %edx
  8004e4:	68 88 15 80 00       	push   $0x801588
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	e8 59 02 00 00       	call   800749 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	e9 bc fe ff ff       	jmp    8003b4 <vprintfmt+0x14>
  8004f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800501:	8b 55 14             	mov    0x14(%ebp),%edx
  800504:	8d 42 04             	lea    0x4(%edx),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	8b 1a                	mov    (%edx),%ebx
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	75 05                	jne    800515 <vprintfmt+0x175>
  800510:	bb 8b 15 80 00       	mov    $0x80158b,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800515:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800519:	7e 66                	jle    800581 <vprintfmt+0x1e1>
  80051b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80051f:	74 60                	je     800581 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	51                   	push   %ecx
  800525:	53                   	push   %ebx
  800526:	e8 57 02 00 00       	call   800782 <strnlen>
  80052b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80053a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x1ae>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	57                   	push   %edi
  800543:	ff 75 c4             	pushl  -0x3c(%ebp)
  800546:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	ff 4d d8             	decl   -0x28(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800552:	7f eb                	jg     80053f <vprintfmt+0x19f>
  800554:	eb 2b                	jmp    800581 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800556:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055d:	74 15                	je     800574 <vprintfmt+0x1d4>
  80055f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800562:	83 f8 5e             	cmp    $0x5e,%eax
  800565:	76 0d                	jbe    800574 <vprintfmt+0x1d4>
					putch('?', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	eb 0a                	jmp    80057e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	57                   	push   %edi
  800578:	52                   	push   %edx
  800579:	ff d6                	call   *%esi
  80057b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	ff 4d d8             	decl   -0x28(%ebp)
  800581:	8a 03                	mov    (%ebx),%al
  800583:	43                   	inc    %ebx
  800584:	84 c0                	test   %al,%al
  800586:	74 1b                	je     8005a3 <vprintfmt+0x203>
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	78 c8                	js     800556 <vprintfmt+0x1b6>
  80058e:	ff 4d dc             	decl   -0x24(%ebp)
  800591:	79 c3                	jns    800556 <vprintfmt+0x1b6>
  800593:	eb 0e                	jmp    8005a3 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	6a 20                	push   $0x20
  80059b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059d:	ff 4d d8             	decl   -0x28(%ebp)
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a7:	7f ec                	jg     800595 <vprintfmt+0x1f5>
  8005a9:	e9 06 fe ff ff       	jmp    8003b4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ae:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005b2:	7e 10                	jle    8005c4 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8005b4:	8b 55 14             	mov    0x14(%ebp),%edx
  8005b7:	8d 42 08             	lea    0x8(%edx),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	8b 02                	mov    (%edx),%eax
  8005bf:	8b 52 04             	mov    0x4(%edx),%edx
  8005c2:	eb 20                	jmp    8005e4 <vprintfmt+0x244>
	else if (lflag)
  8005c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c8:	74 0e                	je     8005d8 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	99                   	cltd   
  8005d6:	eb 0c                	jmp    8005e4 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8005e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005eb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	78 0a                	js     8005fc <vprintfmt+0x25c>
  8005f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005f7:	e9 89 00 00 00       	jmp    800685 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	57                   	push   %edi
  800600:	6a 2d                	push   $0x2d
  800602:	ff d6                	call   *%esi
				num = -(long long) num;
  800604:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800607:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80060a:	f7 da                	neg    %edx
  80060c:	83 d1 00             	adc    $0x0,%ecx
  80060f:	f7 d9                	neg    %ecx
  800611:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb 6a                	jmp    800685 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800621:	e8 22 fd ff ff       	call   800348 <getuint>
  800626:	89 d1                	mov    %edx,%ecx
  800628:	89 c2                	mov    %eax,%edx
  80062a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80062f:	eb 54                	jmp    800685 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800637:	e8 0c fd ff ff       	call   800348 <getuint>
  80063c:	89 d1                	mov    %edx,%ecx
  80063e:	89 c2                	mov    %eax,%edx
  800640:	bb 08 00 00 00       	mov    $0x8,%ebx
  800645:	eb 3e                	jmp    800685 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	57                   	push   %edi
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	57                   	push   %edi
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
  800657:	8b 55 14             	mov    0x14(%ebp),%edx
  80065a:	8d 42 04             	lea    0x4(%edx),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	8b 12                	mov    (%edx),%edx
  800662:	b9 00 00 00 00       	mov    $0x0,%ecx
  800667:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066c:	83 c4 10             	add    $0x10,%esp
  80066f:	eb 14                	jmp    800685 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800677:	e8 cc fc ff ff       	call   800348 <getuint>
  80067c:	89 d1                	mov    %edx,%ecx
  80067e:	89 c2                	mov    %eax,%edx
  800680:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80068c:	50                   	push   %eax
  80068d:	ff 75 d8             	pushl  -0x28(%ebp)
  800690:	53                   	push   %ebx
  800691:	51                   	push   %ecx
  800692:	52                   	push   %edx
  800693:	89 fa                	mov    %edi,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 08 fc ff ff       	call   8002a4 <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
  80069f:	e9 10 fd ff ff       	jmp    8003b4 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	57                   	push   %edi
  8006a8:	52                   	push   %edx
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	e9 01 fd ff ff       	jmp    8003b4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	57                   	push   %edi
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
  8006bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8006be:	83 ea 02             	sub    $0x2,%edx
  8006c1:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	8a 02                	mov    (%edx),%al
  8006c6:	4a                   	dec    %edx
  8006c7:	3c 25                	cmp    $0x25,%al
  8006c9:	75 f9                	jne    8006c4 <vprintfmt+0x324>
  8006cb:	83 c2 02             	add    $0x2,%edx
  8006ce:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8006d1:	e9 de fc ff ff       	jmp    8003b4 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8006d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d9:	5b                   	pop    %ebx
  8006da:	5e                   	pop    %esi
  8006db:	5f                   	pop    %edi
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 18             	sub    $0x18,%esp
  8006e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	74 37                	je     800725 <vsnprintf+0x47>
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	7e 33                	jle    800725 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006f9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800700:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800703:	ff 75 14             	pushl  0x14(%ebp)
  800706:	ff 75 10             	pushl  0x10(%ebp)
  800709:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80070c:	50                   	push   %eax
  80070d:	68 84 03 80 00       	push   $0x800384
  800712:	e8 89 fc ff ff       	call   8003a0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb 05                	jmp    80072a <vsnprintf+0x4c>
  800725:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800738:	50                   	push   %eax
  800739:	ff 75 10             	pushl  0x10(%ebp)
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	ff 75 08             	pushl  0x8(%ebp)
  800742:	e8 97 ff ff ff       	call   8006de <vsnprintf>
	va_end(ap);

	return rc;
}
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800755:	50                   	push   %eax
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	ff 75 0c             	pushl  0xc(%ebp)
  80075c:	ff 75 08             	pushl  0x8(%ebp)
  80075f:	e8 3c fc ff ff       	call   8003a0 <vprintfmt>
	va_end(ap);
  800764:	83 c4 10             	add    $0x10,%esp
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    
  800769:	00 00                	add    %al,(%eax)
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 01                	jmp    80077a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800779:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80077e:	75 f9                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 01                	jmp    800793 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800792:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 06                	je     80079d <strnlen+0x1b>
  800797:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80079b:	75 f5                	jne    800792 <strnlen+0x10>
		n++;
	return n;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a8:	8a 01                	mov    (%ecx),%al
  8007aa:	88 02                	mov    %al,(%edx)
  8007ac:	42                   	inc    %edx
  8007ad:	41                   	inc    %ecx
  8007ae:	84 c0                	test   %al,%al
  8007b0:	75 f6                	jne    8007a8 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 a8 ff ff ff       	call   80076c <strlen>
	strcpy(dst + len, src);
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007ca:	50                   	push   %eax
  8007cb:	e8 cf ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007d0:	89 d8                	mov    %ebx,%eax
  8007d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ea:	eb 0c                	jmp    8007f8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8007ec:	8a 02                	mov    (%edx),%al
  8007ee:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	41                   	inc    %ecx
  8007f8:	39 d9                	cmp    %ebx,%ecx
  8007fa:	75 f0                	jne    8007ec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	85 c9                	test   %ecx,%ecx
  800812:	75 04                	jne    800818 <strlcpy+0x16>
  800814:	89 f0                	mov    %esi,%eax
  800816:	eb 14                	jmp    80082c <strlcpy+0x2a>
  800818:	89 f0                	mov    %esi,%eax
  80081a:	eb 04                	jmp    800820 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081c:	88 10                	mov    %dl,(%eax)
  80081e:	40                   	inc    %eax
  80081f:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800820:	49                   	dec    %ecx
  800821:	74 06                	je     800829 <strlcpy+0x27>
  800823:	8a 13                	mov    (%ebx),%dl
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f3                	jne    80081c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
  80082c:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 55 08             	mov    0x8(%ebp),%edx
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083b:	eb 02                	jmp    80083f <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  80083d:	42                   	inc    %edx
  80083e:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083f:	8a 02                	mov    (%edx),%al
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x17>
  800845:	3a 01                	cmp    (%ecx),%al
  800847:	74 f4                	je     80083d <strcmp+0xb>
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 11             	movzbl (%ecx),%edx
  80084f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085d:	8b 55 10             	mov    0x10(%ebp),%edx
  800860:	eb 03                	jmp    800865 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800862:	4a                   	dec    %edx
  800863:	41                   	inc    %ecx
  800864:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	85 d2                	test   %edx,%edx
  800867:	75 07                	jne    800870 <strncmp+0x1d>
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
  80086e:	eb 14                	jmp    800884 <strncmp+0x31>
  800870:	8a 01                	mov    (%ecx),%al
  800872:	84 c0                	test   %al,%al
  800874:	74 04                	je     80087a <strncmp+0x27>
  800876:	3a 03                	cmp    (%ebx),%al
  800878:	74 e8                	je     800862 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087a:	0f b6 d0             	movzbl %al,%edx
  80087d:	0f b6 03             	movzbl (%ebx),%eax
  800880:	29 c2                	sub    %eax,%edx
  800882:	89 d0                	mov    %edx,%eax
}
  800884:	5b                   	pop    %ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800890:	eb 05                	jmp    800897 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 0c                	je     8008a2 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800896:	40                   	inc    %eax
  800897:	8a 10                	mov    (%eax),%dl
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f5                	jne    800892 <strchr+0xb>
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008ad:	eb 05                	jmp    8008b4 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 07                	je     8008ba <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b3:	40                   	inc    %eax
  8008b4:	8a 10                	mov    (%eax),%dl
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f5                	jne    8008af <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8008cb:	85 db                	test   %ebx,%ebx
  8008cd:	74 36                	je     800905 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d5:	75 29                	jne    800900 <memset+0x44>
  8008d7:	f6 c3 03             	test   $0x3,%bl
  8008da:	75 24                	jne    800900 <memset+0x44>
		c &= 0xFF;
  8008dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008df:	89 d6                	mov    %edx,%esi
  8008e1:	c1 e6 08             	shl    $0x8,%esi
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	c1 e0 18             	shl    $0x18,%eax
  8008e9:	89 d1                	mov    %edx,%ecx
  8008eb:	c1 e1 10             	shl    $0x10,%ecx
  8008ee:	09 c8                	or     %ecx,%eax
  8008f0:	09 c2                	or     %eax,%edx
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	09 d0                	or     %edx,%eax
  8008f6:	89 d9                	mov    %ebx,%ecx
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb 05                	jmp    800905 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800900:	89 d9                	mov    %ebx,%ecx
  800902:	fc                   	cld    
  800903:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800905:	89 f8                	mov    %edi,%eax
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	57                   	push   %edi
  800910:	56                   	push   %esi
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80091a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80091c:	39 c6                	cmp    %eax,%esi
  80091e:	73 36                	jae    800956 <memmove+0x4a>
  800920:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800923:	39 d0                	cmp    %edx,%eax
  800925:	73 2f                	jae    800956 <memmove+0x4a>
		s += n;
		d += n;
  800927:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f6 c2 03             	test   $0x3,%dl
  80092d:	75 1b                	jne    80094a <memmove+0x3e>
  80092f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800935:	75 13                	jne    80094a <memmove+0x3e>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0e                	jne    80094a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  80093c:	8d 7e fc             	lea    -0x4(%esi),%edi
  80093f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800942:	c1 e9 02             	shr    $0x2,%ecx
  800945:	fd                   	std    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 09                	jmp    800953 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094a:	8d 7e ff             	lea    -0x1(%esi),%edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 20                	jmp    800976 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095c:	75 15                	jne    800973 <memmove+0x67>
  80095e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800964:	75 0d                	jne    800973 <memmove+0x67>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 08                	jne    800973 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80096b:	c1 e9 02             	shr    $0x2,%ecx
  80096e:	fc                   	cld    
  80096f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800971:	eb 03                	jmp    800976 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097d:	ff 75 10             	pushl  0x10(%ebp)
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	ff 75 08             	pushl  0x8(%ebp)
  800986:	e8 81 ff ff ff       	call   80090c <memmove>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800997:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80099a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099d:	eb 1b                	jmp    8009ba <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80099f:	8a 1a                	mov    (%edx),%bl
  8009a1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8009a4:	8a 19                	mov    (%ecx),%bl
  8009a6:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8009a9:	74 0d                	je     8009b8 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8009ab:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8009af:	0f b6 c3             	movzbl %bl,%eax
  8009b2:	29 c2                	sub    %eax,%edx
  8009b4:	89 d0                	mov    %edx,%eax
  8009b6:	eb 0d                	jmp    8009c5 <memcmp+0x38>
		s1++, s2++;
  8009b8:	42                   	inc    %edx
  8009b9:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	48                   	dec    %eax
  8009bb:	83 f8 ff             	cmp    $0xffffffff,%eax
  8009be:	75 df                	jne    80099f <memcmp+0x12>
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8009c5:	83 c4 04             	add    $0x4,%esp
  8009c8:	5b                   	pop    %ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d4:	89 c2                	mov    %eax,%edx
  8009d6:	03 55 10             	add    0x10(%ebp),%edx
  8009d9:	eb 05                	jmp    8009e0 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009db:	38 08                	cmp    %cl,(%eax)
  8009dd:	74 05                	je     8009e4 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	40                   	inc    %eax
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	72 f7                	jb     8009db <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	53                   	push   %ebx
  8009ec:	83 ec 04             	sub    $0x4,%esp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8009f5:	eb 01                	jmp    8009f8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009f7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	8a 01                	mov    (%ecx),%al
  8009fa:	3c 20                	cmp    $0x20,%al
  8009fc:	74 f9                	je     8009f7 <strtol+0x11>
  8009fe:	3c 09                	cmp    $0x9,%al
  800a00:	74 f5                	je     8009f7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a02:	3c 2b                	cmp    $0x2b,%al
  800a04:	75 0a                	jne    800a10 <strtol+0x2a>
		s++;
  800a06:	41                   	inc    %ecx
  800a07:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a0e:	eb 17                	jmp    800a27 <strtol+0x41>
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	74 09                	je     800a1d <strtol+0x37>
  800a14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a1b:	eb 0a                	jmp    800a27 <strtol+0x41>
		s++, neg = 1;
  800a1d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a20:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	85 f6                	test   %esi,%esi
  800a29:	74 05                	je     800a30 <strtol+0x4a>
  800a2b:	83 fe 10             	cmp    $0x10,%esi
  800a2e:	75 1a                	jne    800a4a <strtol+0x64>
  800a30:	8a 01                	mov    (%ecx),%al
  800a32:	3c 30                	cmp    $0x30,%al
  800a34:	75 10                	jne    800a46 <strtol+0x60>
  800a36:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3a:	75 0a                	jne    800a46 <strtol+0x60>
		s += 2, base = 16;
  800a3c:	83 c1 02             	add    $0x2,%ecx
  800a3f:	be 10 00 00 00       	mov    $0x10,%esi
  800a44:	eb 04                	jmp    800a4a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800a46:	85 f6                	test   %esi,%esi
  800a48:	74 07                	je     800a51 <strtol+0x6b>
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4f:	eb 13                	jmp    800a64 <strtol+0x7e>
  800a51:	3c 30                	cmp    $0x30,%al
  800a53:	74 07                	je     800a5c <strtol+0x76>
  800a55:	be 0a 00 00 00       	mov    $0xa,%esi
  800a5a:	eb ee                	jmp    800a4a <strtol+0x64>
		s++, base = 8;
  800a5c:	41                   	inc    %ecx
  800a5d:	be 08 00 00 00       	mov    $0x8,%esi
  800a62:	eb e6                	jmp    800a4a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	8a 11                	mov    (%ecx),%dl
  800a66:	88 d3                	mov    %dl,%bl
  800a68:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	77 08                	ja     800a77 <strtol+0x91>
			dig = *s - '0';
  800a6f:	0f be c2             	movsbl %dl,%eax
  800a72:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a75:	eb 1c                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a77:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a7a:	3c 19                	cmp    $0x19,%al
  800a7c:	77 08                	ja     800a86 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a7e:	0f be c2             	movsbl %dl,%eax
  800a81:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a84:	eb 0d                	jmp    800a93 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a89:	3c 19                	cmp    $0x19,%al
  800a8b:	77 15                	ja     800aa2 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a8d:	0f be c2             	movsbl %dl,%eax
  800a90:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a93:	39 f2                	cmp    %esi,%edx
  800a95:	7d 0b                	jge    800aa2 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a97:	41                   	inc    %ecx
  800a98:	89 f8                	mov    %edi,%eax
  800a9a:	0f af c6             	imul   %esi,%eax
  800a9d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800aa0:	eb c2                	jmp    800a64 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800aa2:	89 f8                	mov    %edi,%eax

	if (endptr)
  800aa4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa8:	74 05                	je     800aaf <strtol+0xc9>
		*endptr = (char *) s;
  800aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aad:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800aaf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ab3:	74 04                	je     800ab9 <strtol+0xd3>
  800ab5:	89 c7                	mov    %eax,%edi
  800ab7:	f7 df                	neg    %edi
}
  800ab9:	89 f8                	mov    %edi,%eax
  800abb:	83 c4 04             	add    $0x4,%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    
	...

00800ac4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad4:	89 fa                	mov    %edi,%edx
  800ad6:	89 f9                	mov    %edi,%ecx
  800ad8:	89 fb                	mov    %edi,%ebx
  800ada:	89 fe                	mov    %edi,%esi
  800adc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	89 f8                	mov    %edi,%eax
  800af9:	89 fb                	mov    %edi,%ebx
  800afb:	89 fe                	mov    %edi,%esi
  800afd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aff:	83 c4 04             	add    $0x4,%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 0c             	sub    $0xc,%esp
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b13:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1d:	89 f9                	mov    %edi,%ecx
  800b1f:	89 fb                	mov    %edi,%ebx
  800b21:	89 fe                	mov    %edi,%esi
  800b23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 17                	jle    800b40 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	50                   	push   %eax
  800b2d:	6a 0d                	push   $0xd
  800b2f:	68 7f 18 80 00       	push   $0x80187f
  800b34:	6a 23                	push   $0x23
  800b36:	68 9c 18 80 00       	push   $0x80189c
  800b3b:	e8 d4 05 00 00       	call   801114 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b57:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b5f:	be 00 00 00 00       	mov    $0x0,%esi
  800b64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b84:	89 fb                	mov    %edi,%ebx
  800b86:	89 fe                	mov    %edi,%esi
  800b88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 17                	jle    800ba5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 0a                	push   $0xa
  800b94:	68 7f 18 80 00       	push   $0x80187f
  800b99:	6a 23                	push   $0x23
  800b9b:	68 9c 18 80 00       	push   $0x80189c
  800ba0:	e8 6f 05 00 00       	call   801114 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800bc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc6:	89 fb                	mov    %edi,%ebx
  800bc8:	89 fe                	mov    %edi,%esi
  800bca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 09                	push   $0x9
  800bd6:	68 7f 18 80 00       	push   $0x80187f
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 9c 18 80 00       	push   $0x80189c
  800be2:	e8 2d 05 00 00       	call   801114 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 08 00 00 00       	mov    $0x8,%eax
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
  800c08:	89 fb                	mov    %edi,%ebx
  800c0a:	89 fe                	mov    %edi,%esi
  800c0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 17                	jle    800c29 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 08                	push   $0x8
  800c18:	68 7f 18 80 00       	push   $0x80187f
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 9c 18 80 00       	push   $0x80189c
  800c24:	e8 eb 04 00 00       	call   801114 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	b8 06 00 00 00       	mov    $0x6,%eax
  800c45:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4a:	89 fb                	mov    %edi,%ebx
  800c4c:	89 fe                	mov    %edi,%esi
  800c4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 06                	push   $0x6
  800c5a:	68 7f 18 80 00       	push   $0x80187f
  800c5f:	6a 23                	push   $0x23
  800c61:	68 9c 18 80 00       	push   $0x80189c
  800c66:	e8 a9 04 00 00       	call   801114 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c88:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7e 17                	jle    800cad <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	6a 05                	push   $0x5
  800c9c:	68 7f 18 80 00       	push   $0x80187f
  800ca1:	6a 23                	push   $0x23
  800ca3:	68 9c 18 80 00       	push   $0x80189c
  800ca8:	e8 67 04 00 00       	call   801114 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccc:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd1:	89 fe                	mov    %edi,%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 04                	push   $0x4
  800cdf:	68 7f 18 80 00       	push   $0x80187f
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 9c 18 80 00       	push   $0x80189c
  800ceb:	e8 24 04 00 00       	call   801114 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d03:	bf 00 00 00 00       	mov    $0x0,%edi
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	89 f9                	mov    %edi,%ecx
  800d0c:	89 fb                	mov    %edi,%ebx
  800d0e:	89 fe                	mov    %edi,%esi
  800d10:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d22:	bf 00 00 00 00       	mov    $0x0,%edi
  800d27:	89 fa                	mov    %edi,%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 fb                	mov    %edi,%ebx
  800d2d:	89 fe                	mov    %edi,%esi
  800d2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 03 00 00 00       	mov    $0x3,%eax
  800d47:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4c:	89 f9                	mov    %edi,%ecx
  800d4e:	89 fb                	mov    %edi,%ebx
  800d50:	89 fe                	mov    %edi,%esi
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 17                	jle    800d6f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 03                	push   $0x3
  800d5e:	68 7f 18 80 00       	push   $0x80187f
  800d63:	6a 23                	push   $0x23
  800d65:	68 9c 18 80 00       	push   $0x80189c
  800d6a:	e8 a5 03 00 00       	call   801114 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    
	...

00800d78 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d7e:	68 aa 18 80 00       	push   $0x8018aa
  800d83:	68 92 00 00 00       	push   $0x92
  800d88:	68 c0 18 80 00       	push   $0x8018c0
  800d8d:	e8 82 03 00 00       	call   801114 <_panic>

00800d92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800d9b:	68 33 0f 80 00       	push   $0x800f33
  800da0:	e8 bf 03 00 00       	call   801164 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800da5:	ba 07 00 00 00       	mov    $0x7,%edx
  800daa:	89 d0                	mov    %edx,%eax
  800dac:	cd 30                	int    $0x30
  800dae:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	75 25                	jne    800ddc <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800db7:	e8 5b ff ff ff       	call   800d17 <sys_getenvid>
  800dbc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800dc8:	c1 e0 07             	shl    $0x7,%eax
  800dcb:	29 d0                	sub    %edx,%eax
  800dcd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800dd2:	a3 0c 20 80 00       	mov    %eax,0x80200c
  800dd7:	e9 4d 01 00 00       	jmp    800f29 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	79 12                	jns    800df2 <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800de0:	50                   	push   %eax
  800de1:	68 cb 18 80 00       	push   $0x8018cb
  800de6:	6a 77                	push   $0x77
  800de8:	68 c0 18 80 00       	push   $0x8018c0
  800ded:	e8 22 03 00 00       	call   801114 <_panic>
  800df2:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800df7:	89 d8                	mov    %ebx,%eax
  800df9:	c1 e8 16             	shr    $0x16,%eax
  800dfc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e03:	a8 01                	test   $0x1,%al
  800e05:	0f 84 ab 00 00 00    	je     800eb6 <fork+0x124>
  800e0b:	89 da                	mov    %ebx,%edx
  800e0d:	c1 ea 0c             	shr    $0xc,%edx
  800e10:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e17:	a8 01                	test   $0x1,%al
  800e19:	0f 84 97 00 00 00    	je     800eb6 <fork+0x124>
  800e1f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e26:	a8 04                	test   $0x4,%al
  800e28:	0f 84 88 00 00 00    	je     800eb6 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800e2e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800e35:	89 d6                	mov    %edx,%esi
  800e37:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800e42:	a9 02 08 00 00       	test   $0x802,%eax
  800e47:	74 0f                	je     800e58 <fork+0xc6>
  800e49:	f6 c4 04             	test   $0x4,%ah
  800e4c:	75 0a                	jne    800e58 <fork+0xc6>
		perm &= ~PTE_W;
  800e4e:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800e58:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e5e:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	52                   	push   %edx
  800e65:	56                   	push   %esi
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	6a 00                	push   $0x0
  800e6a:	e8 04 fe ff ff       	call   800c73 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800e6f:	83 c4 20             	add    $0x20,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 14                	jns    800e8a <fork+0xf8>
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 14 19 80 00       	push   $0x801914
  800e7e:	6a 52                	push   $0x52
  800e80:	68 c0 18 80 00       	push   $0x8018c0
  800e85:	e8 8a 02 00 00       	call   801114 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e90:	56                   	push   %esi
  800e91:	6a 00                	push   $0x0
  800e93:	56                   	push   %esi
  800e94:	6a 00                	push   $0x0
  800e96:	e8 d8 fd ff ff       	call   800c73 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800e9b:	83 c4 20             	add    $0x20,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	79 14                	jns    800eb6 <fork+0x124>
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	68 38 19 80 00       	push   $0x801938
  800eaa:	6a 55                	push   $0x55
  800eac:	68 c0 18 80 00       	push   $0x8018c0
  800eb1:	e8 5e 02 00 00       	call   801114 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800eb6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ebc:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ec2:	0f 85 2f ff ff ff    	jne    800df7 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800ec8:	83 ec 04             	sub    $0x4,%esp
  800ecb:	6a 07                	push   $0x7
  800ecd:	68 00 f0 bf ee       	push   $0xeebff000
  800ed2:	57                   	push   %edi
  800ed3:	e8 dd fd ff ff       	call   800cb5 <sys_page_alloc>
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	79 15                	jns    800ef4 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800edf:	50                   	push   %eax
  800ee0:	68 e9 18 80 00       	push   $0x8018e9
  800ee5:	68 83 00 00 00       	push   $0x83
  800eea:	68 c0 18 80 00       	push   $0x8018c0
  800eef:	e8 20 02 00 00       	call   801114 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	68 e4 11 80 00       	push   $0x8011e4
  800efc:	57                   	push   %edi
  800efd:	e8 69 fc ff ff       	call   800b6b <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800f02:	83 c4 08             	add    $0x8,%esp
  800f05:	6a 02                	push   $0x2
  800f07:	57                   	push   %edi
  800f08:	e8 e2 fc ff ff       	call   800bef <sys_env_set_status>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 15                	jns    800f29 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 fc 18 80 00       	push   $0x8018fc
  800f1a:	68 89 00 00 00       	push   $0x89
  800f1f:	68 c0 18 80 00       	push   $0x8018c0
  800f24:	e8 eb 01 00 00       	call   801114 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800f29:	89 f8                	mov    %edi,%eax
  800f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	53                   	push   %ebx
  800f37:	83 ec 04             	sub    $0x4,%esp
  800f3a:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800f3d:	8b 1a                	mov    (%edx),%ebx
  800f3f:	89 d8                	mov    %ebx,%eax
  800f41:	c1 e8 0c             	shr    $0xc,%eax
  800f44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800f4b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f4f:	74 05                	je     800f56 <pgfault+0x23>
  800f51:	f6 c4 08             	test   $0x8,%ah
  800f54:	75 14                	jne    800f6a <pgfault+0x37>
  800f56:	83 ec 04             	sub    $0x4,%esp
  800f59:	68 5c 19 80 00       	push   $0x80195c
  800f5e:	6a 1e                	push   $0x1e
  800f60:	68 c0 18 80 00       	push   $0x8018c0
  800f65:	e8 aa 01 00 00       	call   801114 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800f6a:	83 ec 04             	sub    $0x4,%esp
  800f6d:	6a 07                	push   $0x7
  800f6f:	68 00 f0 7f 00       	push   $0x7ff000
  800f74:	6a 00                	push   $0x0
  800f76:	e8 3a fd ff ff       	call   800cb5 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 14                	jns    800f96 <pgfault+0x63>
  800f82:	83 ec 04             	sub    $0x4,%esp
  800f85:	68 88 19 80 00       	push   $0x801988
  800f8a:	6a 2a                	push   $0x2a
  800f8c:	68 c0 18 80 00       	push   $0x8018c0
  800f91:	e8 7e 01 00 00       	call   801114 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800f96:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	68 00 10 00 00       	push   $0x1000
  800fa4:	53                   	push   %ebx
  800fa5:	68 00 f0 7f 00       	push   $0x7ff000
  800faa:	e8 5d f9 ff ff       	call   80090c <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800faf:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb6:	53                   	push   %ebx
  800fb7:	6a 00                	push   $0x0
  800fb9:	68 00 f0 7f 00       	push   $0x7ff000
  800fbe:	6a 00                	push   $0x0
  800fc0:	e8 ae fc ff ff       	call   800c73 <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800fc5:	83 c4 20             	add    $0x20,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 14                	jns    800fe0 <pgfault+0xad>
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 ac 19 80 00       	push   $0x8019ac
  800fd4:	6a 2e                	push   $0x2e
  800fd6:	68 c0 18 80 00       	push   $0x8018c0
  800fdb:	e8 34 01 00 00       	call   801114 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	68 00 f0 7f 00       	push   $0x7ff000
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 42 fc ff ff       	call   800c31 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 14                	jns    80100a <pgfault+0xd7>
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 cc 19 80 00       	push   $0x8019cc
  800ffe:	6a 32                	push   $0x32
  801000:	68 c0 18 80 00       	push   $0x8018c0
  801005:	e8 0a 01 00 00       	call   801114 <_panic>
	//panic("pgfault not implemented");
}
  80100a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    
	...

00801010 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801017:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80101c:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801023:	89 c8                	mov    %ecx,%eax
  801025:	c1 e0 07             	shl    $0x7,%eax
  801028:	29 d0                	sub    %edx,%eax
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801032:	8b 40 50             	mov    0x50(%eax),%eax
  801035:	39 d8                	cmp    %ebx,%eax
  801037:	75 0b                	jne    801044 <ipc_find_env+0x34>
			return envs[i].env_id;
  801039:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  80103f:	8b 40 40             	mov    0x40(%eax),%eax
  801042:	eb 0e                	jmp    801052 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801044:	41                   	inc    %ecx
  801045:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  80104b:	75 cf                	jne    80101c <ipc_find_env+0xc>
  80104d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801052:	5b                   	pop    %ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801061:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801064:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801067:	85 db                	test   %ebx,%ebx
  801069:	75 05                	jne    801070 <ipc_send+0x1b>
  80106b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	57                   	push   %edi
  801073:	ff 75 08             	pushl  0x8(%ebp)
  801076:	e8 cd fa ff ff       	call   800b48 <sys_ipc_try_send>
		if (r == 0) {		//success
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	74 20                	je     8010a2 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801082:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801085:	75 07                	jne    80108e <ipc_send+0x39>
			sys_yield();
  801087:	e8 6c fc ff ff       	call   800cf8 <sys_yield>
  80108c:	eb e2                	jmp    801070 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	68 f0 19 80 00       	push   $0x8019f0
  801096:	6a 41                	push   $0x41
  801098:	68 13 1a 80 00       	push   $0x801a13
  80109d:	e8 72 00 00 00       	call   801114 <_panic>
		}
	}
}
  8010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	c9                   	leave  
  8010a9:	c3                   	ret    

008010aa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
  8010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b5:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	75 05                	jne    8010c1 <ipc_recv+0x17>
  8010bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	50                   	push   %eax
  8010c5:	e8 3d fa ff ff       	call   800b07 <sys_ipc_recv>
	if (r < 0) {				
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	79 16                	jns    8010e7 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  8010d1:	85 db                	test   %ebx,%ebx
  8010d3:	74 06                	je     8010db <ipc_recv+0x31>
  8010d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8010db:	85 f6                	test   %esi,%esi
  8010dd:	74 2c                	je     80110b <ipc_recv+0x61>
  8010df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8010e5:	eb 24                	jmp    80110b <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8010e7:	85 db                	test   %ebx,%ebx
  8010e9:	74 0a                	je     8010f5 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8010eb:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010f0:	8b 40 74             	mov    0x74(%eax),%eax
  8010f3:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  8010f5:	85 f6                	test   %esi,%esi
  8010f7:	74 0a                	je     801103 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8010f9:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010fe:	8b 40 78             	mov    0x78(%eax),%eax
  801101:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801103:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801108:	8b 40 70             	mov    0x70(%eax),%eax
}
  80110b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80110e:	5b                   	pop    %ebx
  80110f:	5e                   	pop    %esi
  801110:	c9                   	leave  
  801111:	c3                   	ret    
	...

00801114 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	53                   	push   %ebx
  801118:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80111b:	8d 45 14             	lea    0x14(%ebp),%eax
  80111e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801121:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  801127:	e8 eb fb ff ff       	call   800d17 <sys_getenvid>
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	ff 75 08             	pushl  0x8(%ebp)
  801135:	53                   	push   %ebx
  801136:	50                   	push   %eax
  801137:	68 20 1a 80 00       	push   $0x801a20
  80113c:	e8 0c f1 ff ff       	call   80024d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801141:	83 c4 18             	add    $0x18,%esp
  801144:	ff 75 f8             	pushl  -0x8(%ebp)
  801147:	ff 75 10             	pushl  0x10(%ebp)
  80114a:	e8 ad f0 ff ff       	call   8001fc <vcprintf>
	cprintf("\n");
  80114f:	c7 04 24 e7 18 80 00 	movl   $0x8018e7,(%esp)
  801156:	e8 f2 f0 ff ff       	call   80024d <cprintf>
  80115b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80115e:	cc                   	int3   
  80115f:	eb fd                	jmp    80115e <_panic+0x4a>
  801161:	00 00                	add    %al,(%eax)
	...

00801164 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80116a:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801171:	75 64                	jne    8011d7 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801173:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801178:	8b 40 48             	mov    0x48(%eax),%eax
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	6a 07                	push   $0x7
  801180:	68 00 f0 bf ee       	push   $0xeebff000
  801185:	50                   	push   %eax
  801186:	e8 2a fb ff ff       	call   800cb5 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	79 14                	jns    8011a6 <set_pgfault_handler+0x42>
  801192:	83 ec 04             	sub    $0x4,%esp
  801195:	68 44 1a 80 00       	push   $0x801a44
  80119a:	6a 22                	push   $0x22
  80119c:	68 b0 1a 80 00       	push   $0x801ab0
  8011a1:	e8 6e ff ff ff       	call   801114 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  8011a6:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8011ab:	8b 40 48             	mov    0x48(%eax),%eax
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	68 e4 11 80 00       	push   $0x8011e4
  8011b6:	50                   	push   %eax
  8011b7:	e8 af f9 ff ff       	call   800b6b <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 14                	jns    8011d7 <set_pgfault_handler+0x73>
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	68 74 1a 80 00       	push   $0x801a74
  8011cb:	6a 25                	push   $0x25
  8011cd:	68 b0 1a 80 00       	push   $0x801ab0
  8011d2:	e8 3d ff ff ff       	call   801114 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    
  8011e1:	00 00                	add    %al,(%eax)
	...

008011e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011e5:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8011ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011ec:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  8011ef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011f3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011f6:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  8011fa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  8011fe:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801200:	83 c4 08             	add    $0x8,%esp
	popal
  801203:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801204:	83 c4 04             	add    $0x4,%esp
	popfl
  801207:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801208:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801209:	c3                   	ret    
	...

0080120c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	57                   	push   %edi
  801210:	56                   	push   %esi
  801211:	83 ec 28             	sub    $0x28,%esp
  801214:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80121b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801222:	8b 45 10             	mov    0x10(%ebp),%eax
  801225:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80122b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80122d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801235:	8b 55 0c             	mov    0xc(%ebp),%edx
  801238:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80123b:	85 ff                	test   %edi,%edi
  80123d:	75 21                	jne    801260 <__udivdi3+0x54>
    {
      if (d0 > n1)
  80123f:	39 d1                	cmp    %edx,%ecx
  801241:	76 49                	jbe    80128c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801243:	f7 f1                	div    %ecx
  801245:	89 c1                	mov    %eax,%ecx
  801247:	31 c0                	xor    %eax,%eax
  801249:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80124c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80124f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801252:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801255:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801258:	83 c4 28             	add    $0x28,%esp
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    
  80125f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801260:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801263:	0f 87 97 00 00 00    	ja     801300 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801269:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80126c:	83 f0 1f             	xor    $0x1f,%eax
  80126f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801272:	75 34                	jne    8012a8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801274:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801277:	72 08                	jb     801281 <__udivdi3+0x75>
  801279:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80127c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80127f:	77 7f                	ja     801300 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801281:	b9 01 00 00 00       	mov    $0x1,%ecx
  801286:	31 c0                	xor    %eax,%eax
  801288:	eb c2                	jmp    80124c <__udivdi3+0x40>
  80128a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	74 79                	je     80130c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801293:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801296:	89 fa                	mov    %edi,%edx
  801298:	f7 f1                	div    %ecx
  80129a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80129c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80129f:	f7 f1                	div    %ecx
  8012a1:	89 c1                	mov    %eax,%ecx
  8012a3:	89 f0                	mov    %esi,%eax
  8012a5:	eb a5                	jmp    80124c <__udivdi3+0x40>
  8012a7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8012a8:	b8 20 00 00 00       	mov    $0x20,%eax
  8012ad:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8012b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8012b3:	89 fa                	mov    %edi,%edx
  8012b5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8012b8:	d3 e2                	shl    %cl,%edx
  8012ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bd:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8012c0:	d3 e8                	shr    %cl,%eax
  8012c2:	89 d7                	mov    %edx,%edi
  8012c4:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8012c6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8012c9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8012cc:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8012ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012d1:	d3 e0                	shl    %cl,%eax
  8012d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8012d6:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8012d9:	d3 ea                	shr    %cl,%edx
  8012db:	09 d0                	or     %edx,%eax
  8012dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8012e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012e3:	d3 ea                	shr    %cl,%edx
  8012e5:	f7 f7                	div    %edi
  8012e7:	89 d7                	mov    %edx,%edi
  8012e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8012ec:	f7 e6                	mul    %esi
  8012ee:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012f0:	39 d7                	cmp    %edx,%edi
  8012f2:	72 38                	jb     80132c <__udivdi3+0x120>
  8012f4:	74 27                	je     80131d <__udivdi3+0x111>
  8012f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8012f9:	31 c0                	xor    %eax,%eax
  8012fb:	e9 4c ff ff ff       	jmp    80124c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801300:	31 c9                	xor    %ecx,%ecx
  801302:	31 c0                	xor    %eax,%eax
  801304:	e9 43 ff ff ff       	jmp    80124c <__udivdi3+0x40>
  801309:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80130c:	b8 01 00 00 00       	mov    $0x1,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 75 f4             	divl   -0xc(%ebp)
  801316:	89 c1                	mov    %eax,%ecx
  801318:	e9 76 ff ff ff       	jmp    801293 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80131d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801320:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801323:	d3 e0                	shl    %cl,%eax
  801325:	39 f0                	cmp    %esi,%eax
  801327:	73 cd                	jae    8012f6 <__udivdi3+0xea>
  801329:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80132c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80132f:	49                   	dec    %ecx
  801330:	31 c0                	xor    %eax,%eax
  801332:	e9 15 ff ff ff       	jmp    80124c <__udivdi3+0x40>
	...

00801338 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	83 ec 30             	sub    $0x30,%esp
  801340:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801347:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80134e:	8b 75 08             	mov    0x8(%ebp),%esi
  801351:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801354:	8b 45 10             	mov    0x10(%ebp),%eax
  801357:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80135a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80135d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80135f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801362:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801365:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801368:	85 d2                	test   %edx,%edx
  80136a:	75 1c                	jne    801388 <__umoddi3+0x50>
    {
      if (d0 > n1)
  80136c:	89 fa                	mov    %edi,%edx
  80136e:	39 f8                	cmp    %edi,%eax
  801370:	0f 86 c2 00 00 00    	jbe    801438 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801376:	89 f0                	mov    %esi,%eax
  801378:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80137a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  80137d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801384:	eb 12                	jmp    801398 <__umoddi3+0x60>
  801386:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801388:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80138b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  80138e:	76 18                	jbe    8013a8 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801390:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801393:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801396:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801398:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80139b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80139e:	83 c4 30             	add    $0x30,%esp
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    
  8013a5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8013a8:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8013ac:	83 f0 1f             	xor    $0x1f,%eax
  8013af:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013b2:	0f 84 ac 00 00 00    	je     801464 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013b8:	b8 20 00 00 00       	mov    $0x20,%eax
  8013bd:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8013c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8013c6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8013c9:	d3 e2                	shl    %cl,%edx
  8013cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013ce:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8013d1:	d3 e8                	shr    %cl,%eax
  8013d3:	89 d6                	mov    %edx,%esi
  8013d5:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  8013d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013da:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8013dd:	d3 e0                	shl    %cl,%eax
  8013df:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8013e2:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8013e5:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ea:	d3 e0                	shl    %cl,%eax
  8013ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ef:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8013f2:	d3 ea                	shr    %cl,%edx
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8013f9:	d3 ea                	shr    %cl,%edx
  8013fb:	f7 f6                	div    %esi
  8013fd:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801400:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801403:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801406:	0f 82 8d 00 00 00    	jb     801499 <__umoddi3+0x161>
  80140c:	0f 84 91 00 00 00    	je     8014a3 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801412:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801415:	29 c7                	sub    %eax,%edi
  801417:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801419:	89 f2                	mov    %esi,%edx
  80141b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	89 f8                	mov    %edi,%eax
  801422:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801425:	d3 e8                	shr    %cl,%eax
  801427:	09 c2                	or     %eax,%edx
  801429:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  80142c:	d3 ee                	shr    %cl,%esi
  80142e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801431:	e9 62 ff ff ff       	jmp    801398 <__umoddi3+0x60>
  801436:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80143b:	85 c0                	test   %eax,%eax
  80143d:	74 15                	je     801454 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80143f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801442:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801445:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144a:	f7 f1                	div    %ecx
  80144c:	e9 29 ff ff ff       	jmp    80137a <__umoddi3+0x42>
  801451:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801454:	b8 01 00 00 00       	mov    $0x1,%eax
  801459:	31 d2                	xor    %edx,%edx
  80145b:	f7 75 ec             	divl   -0x14(%ebp)
  80145e:	89 c1                	mov    %eax,%ecx
  801460:	eb dd                	jmp    80143f <__umoddi3+0x107>
  801462:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801464:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801467:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80146a:	72 19                	jb     801485 <__umoddi3+0x14d>
  80146c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801472:	76 11                	jbe    801485 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801474:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801477:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80147a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80147d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801480:	e9 13 ff ff ff       	jmp    801398 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801485:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80148e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801494:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801497:	eb db                	jmp    801474 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801499:	2b 45 cc             	sub    -0x34(%ebp),%eax
  80149c:	19 f2                	sbb    %esi,%edx
  80149e:	e9 6f ff ff ff       	jmp    801412 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014a3:	39 c7                	cmp    %eax,%edi
  8014a5:	72 f2                	jb     801499 <__umoddi3+0x161>
  8014a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014aa:	e9 63 ff ff ff       	jmp    801412 <__umoddi3+0xda>
