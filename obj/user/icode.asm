
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
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
  800039:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 20 	movl   $0x802420,0x803000
  800046:	24 80 00 

	cprintf("icode startup\n");
  800049:	68 26 24 80 00       	push   $0x802426
  80004e:	e8 ea 01 00 00       	call   80023d <cprintf>

	cprintf("icode: open /motd\n");
  800053:	c7 04 24 35 24 80 00 	movl   $0x802435,(%esp)
  80005a:	e8 de 01 00 00       	call   80023d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005f:	83 c4 08             	add    $0x8,%esp
  800062:	6a 00                	push   $0x0
  800064:	68 48 24 80 00       	push   $0x802448
  800069:	e8 91 14 00 00       	call   8014ff <open>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	79 12                	jns    800089 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800077:	50                   	push   %eax
  800078:	68 4e 24 80 00       	push   $0x80244e
  80007d:	6a 0f                	push   $0xf
  80007f:	68 64 24 80 00       	push   $0x802464
  800084:	e8 13 01 00 00       	call   80019c <_panic>

	cprintf("icode: read /motd\n");
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	68 71 24 80 00       	push   $0x802471
  800091:	e8 a7 01 00 00       	call   80023d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d b5 f7 fd ff ff    	lea    -0x209(%ebp),%esi
  80009f:	eb 0d                	jmp    8000ae <umain+0x7a>
		sys_cputs(buf, n);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	50                   	push   %eax
  8000a5:	56                   	push   %esi
  8000a6:	e8 28 0a 00 00       	call   800ad3 <sys_cputs>
  8000ab:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	68 00 02 00 00       	push   $0x200
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
  8000b8:	e8 65 0f 00 00       	call   801022 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	7f dd                	jg     8000a1 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	68 84 24 80 00       	push   $0x802484
  8000cc:	e8 6c 01 00 00       	call   80023d <cprintf>
	close(fd);
  8000d1:	89 1c 24             	mov    %ebx,(%esp)
  8000d4:	e8 9f 10 00 00       	call   801178 <close>

	cprintf("icode: spawn /init\n");
  8000d9:	c7 04 24 98 24 80 00 	movl   $0x802498,(%esp)
  8000e0:	e8 58 01 00 00       	call   80023d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	68 ac 24 80 00       	push   $0x8024ac
  8000f1:	68 b5 24 80 00       	push   $0x8024b5
  8000f6:	68 bf 24 80 00       	push   $0x8024bf
  8000fb:	68 be 24 80 00       	push   $0x8024be
  800100:	e8 da 19 00 00       	call   801adf <spawnl>
  800105:	83 c4 20             	add    $0x20,%esp
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 12                	jns    80011e <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010c:	50                   	push   %eax
  80010d:	68 c4 24 80 00       	push   $0x8024c4
  800112:	6a 1a                	push   $0x1a
  800114:	68 64 24 80 00       	push   $0x802464
  800119:	e8 7e 00 00 00       	call   80019c <_panic>

	cprintf("icode: exiting\n");
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 db 24 80 00       	push   $0x8024db
  800126:	e8 12 01 00 00       	call   80023d <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
}
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	8b 75 08             	mov    0x8(%ebp),%esi
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800143:	e8 bf 0b 00 00       	call   800d07 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800154:	c1 e0 07             	shl    $0x7,%eax
  800157:	29 d0                	sub    %edx,%eax
  800159:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800163:	85 f6                	test   %esi,%esi
  800165:	7e 07                	jle    80016e <libmain+0x36>
		binaryname = argv[0];
  800167:	8b 03                	mov    (%ebx),%eax
  800169:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	53                   	push   %ebx
  800172:	56                   	push   %esi
  800173:	e8 bc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800178:	e8 0b 00 00 00       	call   800188 <exit>
  80017d:	83 c4 10             	add    $0x10,%esp
}
  800180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	c9                   	leave  
  800186:	c3                   	ret    
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80018e:	6a 00                	push   $0x0
  800190:	e8 91 0b 00 00       	call   800d26 <sys_env_destroy>
  800195:	83 c4 10             	add    $0x10,%esp
}
  800198:	c9                   	leave  
  800199:	c3                   	ret    
	...

0080019c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8001a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8001a6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a9:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001af:	e8 53 0b 00 00       	call   800d07 <sys_getenvid>
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	53                   	push   %ebx
  8001be:	50                   	push   %eax
  8001bf:	68 f8 24 80 00       	push   $0x8024f8
  8001c4:	e8 74 00 00 00       	call   80023d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	ff 75 f8             	pushl  -0x8(%ebp)
  8001cf:	ff 75 10             	pushl  0x10(%ebp)
  8001d2:	e8 15 00 00 00       	call   8001ec <vcprintf>
	cprintf("\n");
  8001d7:	c7 04 24 be 29 80 00 	movl   $0x8029be,(%esp)
  8001de:	e8 5a 00 00 00       	call   80023d <cprintf>
  8001e3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e6:	cc                   	int3   
  8001e7:	eb fd                	jmp    8001e6 <_panic+0x4a>
  8001e9:	00 00                	add    %al,(%eax)
	...

008001ec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f5:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8001fc:	00 00 00 
	b.cnt = 0;
  8001ff:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800206:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	68 54 02 80 00       	push   $0x800254
  80021b:	e8 70 01 00 00       	call   800390 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800220:	83 c4 08             	add    $0x8,%esp
  800223:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800229:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80022f:	50                   	push   %eax
  800230:	e8 9e 08 00 00       	call   800ad3 <sys_cputs>
  800235:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800243:	8d 45 0c             	lea    0xc(%ebp),%eax
  800246:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800249:	50                   	push   %eax
  80024a:	ff 75 08             	pushl  0x8(%ebp)
  80024d:	e8 9a ff ff ff       	call   8001ec <vcprintf>
	va_end(ap);

	return cnt;
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	53                   	push   %ebx
  800258:	83 ec 04             	sub    $0x4,%esp
  80025b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025e:	8b 03                	mov    (%ebx),%eax
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800267:	40                   	inc    %eax
  800268:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80026a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026f:	75 1a                	jne    80028b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	68 ff 00 00 00       	push   $0xff
  800279:	8d 43 08             	lea    0x8(%ebx),%eax
  80027c:	50                   	push   %eax
  80027d:	e8 51 08 00 00       	call   800ad3 <sys_cputs>
		b->idx = 0;
  800282:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800288:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80028b:	ff 43 04             	incl   0x4(%ebx)
}
  80028e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800291:	c9                   	leave  
  800292:	c3                   	ret    
	...

00800294 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 1c             	sub    $0x1c,%esp
  80029d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002a0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002af:	8b 55 10             	mov    0x10(%ebp),%edx
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b5:	89 d6                	mov    %edx,%esi
  8002b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8002bc:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8002bf:	72 04                	jb     8002c5 <printnum+0x31>
  8002c1:	39 c2                	cmp    %eax,%edx
  8002c3:	77 3f                	ja     800304 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	ff 75 18             	pushl  0x18(%ebp)
  8002cb:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8002ce:	50                   	push   %eax
  8002cf:	52                   	push   %edx
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002db:	e8 8c 1e 00 00       	call   80216c <__udivdi3>
  8002e0:	83 c4 18             	add    $0x18,%esp
  8002e3:	52                   	push   %edx
  8002e4:	50                   	push   %eax
  8002e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8002e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002eb:	e8 a4 ff ff ff       	call   800294 <printnum>
  8002f0:	83 c4 20             	add    $0x20,%esp
  8002f3:	eb 14                	jmp    800309 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	ff 75 e8             	pushl  -0x18(%ebp)
  8002fb:	ff 75 18             	pushl  0x18(%ebp)
  8002fe:	ff 55 ec             	call   *-0x14(%ebp)
  800301:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800304:	4b                   	dec    %ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f ec                	jg     8002f5 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	ff 75 e8             	pushl  -0x18(%ebp)
  80030f:	83 ec 04             	sub    $0x4,%esp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	ff 75 e4             	pushl  -0x1c(%ebp)
  800317:	ff 75 e0             	pushl  -0x20(%ebp)
  80031a:	e8 79 1f 00 00       	call   802298 <__umoddi3>
  80031f:	83 c4 14             	add    $0x14,%esp
  800322:	0f be 80 1b 25 80 00 	movsbl 0x80251b(%eax),%eax
  800329:	50                   	push   %eax
  80032a:	ff 55 ec             	call   *-0x14(%ebp)
  80032d:	83 c4 10             	add    $0x10,%esp
}
  800330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80033d:	83 fa 01             	cmp    $0x1,%edx
  800340:	7e 0e                	jle    800350 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800342:	8b 10                	mov    (%eax),%edx
  800344:	8d 42 08             	lea    0x8(%edx),%eax
  800347:	89 01                	mov    %eax,(%ecx)
  800349:	8b 02                	mov    (%edx),%eax
  80034b:	8b 52 04             	mov    0x4(%edx),%edx
  80034e:	eb 22                	jmp    800372 <getuint+0x3a>
	else if (lflag)
  800350:	85 d2                	test   %edx,%edx
  800352:	74 10                	je     800364 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 42 04             	lea    0x4(%edx),%eax
  800359:	89 01                	mov    %eax,(%ecx)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 0e                	jmp    800372 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 42 04             	lea    0x4(%edx),%eax
  800369:	89 01                	mov    %eax,(%ecx)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80037a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80037d:	8b 11                	mov    (%ecx),%edx
  80037f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800382:	73 0a                	jae    80038e <sprintputch+0x1a>
		*b->buf++ = ch;
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	88 02                	mov    %al,(%edx)
  800389:	8d 42 01             	lea    0x1(%edx),%eax
  80038c:	89 01                	mov    %eax,(%ecx)
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	57                   	push   %edi
  800394:	56                   	push   %esi
  800395:	53                   	push   %ebx
  800396:	83 ec 3c             	sub    $0x3c,%esp
  800399:	8b 75 08             	mov    0x8(%ebp),%esi
  80039c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80039f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a2:	eb 1a                	jmp    8003be <vprintfmt+0x2e>
  8003a4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8003a7:	eb 15                	jmp    8003be <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a9:	84 c0                	test   %al,%al
  8003ab:	0f 84 15 03 00 00    	je     8006c6 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	57                   	push   %edi
  8003b5:	0f b6 c0             	movzbl %al,%eax
  8003b8:	50                   	push   %eax
  8003b9:	ff d6                	call   *%esi
  8003bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003be:	8a 03                	mov    (%ebx),%al
  8003c0:	43                   	inc    %ebx
  8003c1:	3c 25                	cmp    $0x25,%al
  8003c3:	75 e4                	jne    8003a9 <vprintfmt+0x19>
  8003c5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8003cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d3:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8003e5:	eb 0a                	jmp    8003f1 <vprintfmt+0x61>
  8003e7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8003ee:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8a 03                	mov    (%ebx),%al
  8003f3:	0f b6 d0             	movzbl %al,%edx
  8003f6:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8003f9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8003fc:	83 e8 23             	sub    $0x23,%eax
  8003ff:	3c 55                	cmp    $0x55,%al
  800401:	0f 87 9c 02 00 00    	ja     8006a3 <vprintfmt+0x313>
  800407:	0f b6 c0             	movzbl %al,%eax
  80040a:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  800411:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800415:	eb d7                	jmp    8003ee <vprintfmt+0x5e>
  800417:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80041b:	eb d1                	jmp    8003ee <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80041d:	89 d9                	mov    %ebx,%ecx
  80041f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800426:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800429:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80042c:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800430:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800433:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800437:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800438:	8d 42 d0             	lea    -0x30(%edx),%eax
  80043b:	83 f8 09             	cmp    $0x9,%eax
  80043e:	77 21                	ja     800461 <vprintfmt+0xd1>
  800440:	eb e4                	jmp    800426 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800442:	8b 55 14             	mov    0x14(%ebp),%edx
  800445:	8d 42 04             	lea    0x4(%edx),%eax
  800448:	89 45 14             	mov    %eax,0x14(%ebp)
  80044b:	8b 12                	mov    (%edx),%edx
  80044d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800450:	eb 12                	jmp    800464 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	79 96                	jns    8003ee <vprintfmt+0x5e>
  800458:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045f:	eb 8d                	jmp    8003ee <vprintfmt+0x5e>
  800461:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800464:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800468:	79 84                	jns    8003ee <vprintfmt+0x5e>
  80046a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800470:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800477:	e9 72 ff ff ff       	jmp    8003ee <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80047c:	ff 45 d4             	incl   -0x2c(%ebp)
  80047f:	e9 6a ff ff ff       	jmp    8003ee <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800484:	8b 55 14             	mov    0x14(%ebp),%edx
  800487:	8d 42 04             	lea    0x4(%edx),%eax
  80048a:	89 45 14             	mov    %eax,0x14(%ebp)
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	57                   	push   %edi
  800491:	ff 32                	pushl  (%edx)
  800493:	ff d6                	call   *%esi
			break;
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	e9 07 ff ff ff       	jmp    8003a4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049d:	8b 55 14             	mov    0x14(%ebp),%edx
  8004a0:	8d 42 04             	lea    0x4(%edx),%eax
  8004a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a6:	8b 02                	mov    (%edx),%eax
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	79 02                	jns    8004ae <vprintfmt+0x11e>
  8004ac:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ae:	83 f8 0f             	cmp    $0xf,%eax
  8004b1:	7f 0b                	jg     8004be <vprintfmt+0x12e>
  8004b3:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  8004ba:	85 d2                	test   %edx,%edx
  8004bc:	75 15                	jne    8004d3 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8004be:	50                   	push   %eax
  8004bf:	68 2c 25 80 00       	push   $0x80252c
  8004c4:	57                   	push   %edi
  8004c5:	56                   	push   %esi
  8004c6:	e8 6e 02 00 00       	call   800739 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	e9 d1 fe ff ff       	jmp    8003a4 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004d3:	52                   	push   %edx
  8004d4:	68 f1 28 80 00       	push   $0x8028f1
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	e8 59 02 00 00       	call   800739 <printfmt>
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	e9 bc fe ff ff       	jmp    8003a4 <vprintfmt+0x14>
  8004e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004eb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 55 14             	mov    0x14(%ebp),%edx
  8004f4:	8d 42 04             	lea    0x4(%edx),%eax
  8004f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fa:	8b 1a                	mov    (%edx),%ebx
  8004fc:	85 db                	test   %ebx,%ebx
  8004fe:	75 05                	jne    800505 <vprintfmt+0x175>
  800500:	bb 35 25 80 00       	mov    $0x802535,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800505:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800509:	7e 66                	jle    800571 <vprintfmt+0x1e1>
  80050b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80050f:	74 60                	je     800571 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	51                   	push   %ecx
  800515:	53                   	push   %ebx
  800516:	e8 57 02 00 00       	call   800772 <strnlen>
  80051b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80051e:	29 c1                	sub    %eax,%ecx
  800520:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80052a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80052d:	eb 0f                	jmp    80053e <vprintfmt+0x1ae>
					putch(padc, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	57                   	push   %edi
  800533:	ff 75 c4             	pushl  -0x3c(%ebp)
  800536:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	ff 4d d8             	decl   -0x28(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	7f eb                	jg     80052f <vprintfmt+0x19f>
  800544:	eb 2b                	jmp    800571 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054d:	74 15                	je     800564 <vprintfmt+0x1d4>
  80054f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800552:	83 f8 5e             	cmp    $0x5e,%eax
  800555:	76 0d                	jbe    800564 <vprintfmt+0x1d4>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	57                   	push   %edi
  80055b:	6a 3f                	push   $0x3f
  80055d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	eb 0a                	jmp    80056e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	57                   	push   %edi
  800568:	52                   	push   %edx
  800569:	ff d6                	call   *%esi
  80056b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056e:	ff 4d d8             	decl   -0x28(%ebp)
  800571:	8a 03                	mov    (%ebx),%al
  800573:	43                   	inc    %ebx
  800574:	84 c0                	test   %al,%al
  800576:	74 1b                	je     800593 <vprintfmt+0x203>
  800578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057c:	78 c8                	js     800546 <vprintfmt+0x1b6>
  80057e:	ff 4d dc             	decl   -0x24(%ebp)
  800581:	79 c3                	jns    800546 <vprintfmt+0x1b6>
  800583:	eb 0e                	jmp    800593 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	57                   	push   %edi
  800589:	6a 20                	push   $0x20
  80058b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058d:	ff 4d d8             	decl   -0x28(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800597:	7f ec                	jg     800585 <vprintfmt+0x1f5>
  800599:	e9 06 fe ff ff       	jmp    8003a4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005a2:	7e 10                	jle    8005b4 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8005a4:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a7:	8d 42 08             	lea    0x8(%edx),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ad:	8b 02                	mov    (%edx),%eax
  8005af:	8b 52 04             	mov    0x4(%edx),%edx
  8005b2:	eb 20                	jmp    8005d4 <vprintfmt+0x244>
	else if (lflag)
  8005b4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b8:	74 0e                	je     8005c8 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	99                   	cltd   
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	89 d1                	mov    %edx,%ecx
  8005d6:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8005d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005de:	85 c9                	test   %ecx,%ecx
  8005e0:	78 0a                	js     8005ec <vprintfmt+0x25c>
  8005e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005e7:	e9 89 00 00 00       	jmp    800675 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8005f7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 d1 00             	adc    $0x0,%ecx
  8005ff:	f7 d9                	neg    %ecx
  800601:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 6a                	jmp    800675 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800611:	e8 22 fd ff ff       	call   800338 <getuint>
  800616:	89 d1                	mov    %edx,%ecx
  800618:	89 c2                	mov    %eax,%edx
  80061a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80061f:	eb 54                	jmp    800675 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800627:	e8 0c fd ff ff       	call   800338 <getuint>
  80062c:	89 d1                	mov    %edx,%ecx
  80062e:	89 c2                	mov    %eax,%edx
  800630:	bb 08 00 00 00       	mov    $0x8,%ebx
  800635:	eb 3e                	jmp    800675 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 30                	push   $0x30
  80063d:	ff d6                	call   *%esi
			putch('x', putdat);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 78                	push   $0x78
  800645:	ff d6                	call   *%esi
			num = (unsigned long long)
  800647:	8b 55 14             	mov    0x14(%ebp),%edx
  80064a:	8d 42 04             	lea    0x4(%edx),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
  800650:	8b 12                	mov    (%edx),%edx
  800652:	b9 00 00 00 00       	mov    $0x0,%ecx
  800657:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 14                	jmp    800675 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800667:	e8 cc fc ff ff       	call   800338 <getuint>
  80066c:	89 d1                	mov    %edx,%ecx
  80066e:	89 c2                	mov    %eax,%edx
  800670:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800675:	83 ec 0c             	sub    $0xc,%esp
  800678:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	ff 75 d8             	pushl  -0x28(%ebp)
  800680:	53                   	push   %ebx
  800681:	51                   	push   %ecx
  800682:	52                   	push   %edx
  800683:	89 fa                	mov    %edi,%edx
  800685:	89 f0                	mov    %esi,%eax
  800687:	e8 08 fc ff ff       	call   800294 <printnum>
			break;
  80068c:	83 c4 20             	add    $0x20,%esp
  80068f:	e9 10 fd ff ff       	jmp    8003a4 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	57                   	push   %edi
  800698:	52                   	push   %edx
  800699:	ff d6                	call   *%esi
			break;
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	e9 01 fd ff ff       	jmp    8003a4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	57                   	push   %edi
  8006a7:	6a 25                	push   $0x25
  8006a9:	ff d6                	call   *%esi
  8006ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8006ae:	83 ea 02             	sub    $0x2,%edx
  8006b1:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b4:	8a 02                	mov    (%edx),%al
  8006b6:	4a                   	dec    %edx
  8006b7:	3c 25                	cmp    $0x25,%al
  8006b9:	75 f9                	jne    8006b4 <vprintfmt+0x324>
  8006bb:	83 c2 02             	add    $0x2,%edx
  8006be:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8006c1:	e9 de fc ff ff       	jmp    8003a4 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8006c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 18             	sub    $0x18,%esp
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	74 37                	je     800715 <vsnprintf+0x47>
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	7e 33                	jle    800715 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8006e9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8006f0:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f3:	ff 75 14             	pushl  0x14(%ebp)
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fc:	50                   	push   %eax
  8006fd:	68 74 03 80 00       	push   $0x800374
  800702:	e8 89 fc ff ff       	call   800390 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 05                	jmp    80071a <vsnprintf+0x4c>
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 10             	pushl  0x10(%ebp)
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 97 ff ff ff       	call   8006ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800745:	50                   	push   %eax
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	ff 75 08             	pushl  0x8(%ebp)
  80074f:	e8 3c fc ff ff       	call   800390 <vprintfmt>
	va_end(ap);
  800754:	83 c4 10             	add    $0x10,%esp
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    
  800759:	00 00                	add    %al,(%eax)
	...

0080075c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 55 08             	mov    0x8(%ebp),%edx
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 01                	jmp    80076a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800769:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80076e:	75 f9                	jne    800769 <strlen+0xd>
		n++;
	return n;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
  800780:	eb 01                	jmp    800783 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800782:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	39 d0                	cmp    %edx,%eax
  800785:	74 06                	je     80078d <strnlen+0x1b>
  800787:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80078b:	75 f5                	jne    800782 <strnlen+0x10>
		n++;
	return n;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800798:	8a 01                	mov    (%ecx),%al
  80079a:	88 02                	mov    %al,(%edx)
  80079c:	42                   	inc    %edx
  80079d:	41                   	inc    %ecx
  80079e:	84 c0                	test   %al,%al
  8007a0:	75 f6                	jne    800798 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 a8 ff ff ff       	call   80075c <strlen>
	strcpy(dst + len, src);
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007ba:	50                   	push   %eax
  8007bb:	e8 cf ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007c0:	89 d8                	mov    %ebx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	56                   	push   %esi
  8007cb:	53                   	push   %ebx
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	eb 0c                	jmp    8007e8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8007dc:	8a 02                	mov    (%edx),%al
  8007de:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	41                   	inc    %ecx
  8007e8:	39 d9                	cmp    %ebx,%ecx
  8007ea:	75 f0                	jne    8007dc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	85 c9                	test   %ecx,%ecx
  800802:	75 04                	jne    800808 <strlcpy+0x16>
  800804:	89 f0                	mov    %esi,%eax
  800806:	eb 14                	jmp    80081c <strlcpy+0x2a>
  800808:	89 f0                	mov    %esi,%eax
  80080a:	eb 04                	jmp    800810 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080c:	88 10                	mov    %dl,(%eax)
  80080e:	40                   	inc    %eax
  80080f:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800810:	49                   	dec    %ecx
  800811:	74 06                	je     800819 <strlcpy+0x27>
  800813:	8a 13                	mov    (%ebx),%dl
  800815:	84 d2                	test   %dl,%dl
  800817:	75 f3                	jne    80080c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 00 00             	movb   $0x0,(%eax)
  80081c:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 55 08             	mov    0x8(%ebp),%edx
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	eb 02                	jmp    80082f <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  80082d:	42                   	inc    %edx
  80082e:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082f:	8a 02                	mov    (%edx),%al
  800831:	84 c0                	test   %al,%al
  800833:	74 04                	je     800839 <strcmp+0x17>
  800835:	3a 01                	cmp    (%ecx),%al
  800837:	74 f4                	je     80082d <strcmp+0xb>
  800839:	0f b6 c0             	movzbl %al,%eax
  80083c:	0f b6 11             	movzbl (%ecx),%edx
  80083f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084d:	8b 55 10             	mov    0x10(%ebp),%edx
  800850:	eb 03                	jmp    800855 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800852:	4a                   	dec    %edx
  800853:	41                   	inc    %ecx
  800854:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800855:	85 d2                	test   %edx,%edx
  800857:	75 07                	jne    800860 <strncmp+0x1d>
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 14                	jmp    800874 <strncmp+0x31>
  800860:	8a 01                	mov    (%ecx),%al
  800862:	84 c0                	test   %al,%al
  800864:	74 04                	je     80086a <strncmp+0x27>
  800866:	3a 03                	cmp    (%ebx),%al
  800868:	74 e8                	je     800852 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 d0             	movzbl %al,%edx
  80086d:	0f b6 03             	movzbl (%ebx),%eax
  800870:	29 c2                	sub    %eax,%edx
  800872:	89 d0                	mov    %edx,%eax
}
  800874:	5b                   	pop    %ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800880:	eb 05                	jmp    800887 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800882:	38 ca                	cmp    %cl,%dl
  800884:	74 0c                	je     800892 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800886:	40                   	inc    %eax
  800887:	8a 10                	mov    (%eax),%dl
  800889:	84 d2                	test   %dl,%dl
  80088b:	75 f5                	jne    800882 <strchr+0xb>
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80089d:	eb 05                	jmp    8008a4 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80089f:	38 ca                	cmp    %cl,%dl
  8008a1:	74 07                	je     8008aa <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a3:	40                   	inc    %eax
  8008a4:	8a 10                	mov    (%eax),%dl
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	75 f5                	jne    80089f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	57                   	push   %edi
  8008b0:	56                   	push   %esi
  8008b1:	53                   	push   %ebx
  8008b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8008bb:	85 db                	test   %ebx,%ebx
  8008bd:	74 36                	je     8008f5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c5:	75 29                	jne    8008f0 <memset+0x44>
  8008c7:	f6 c3 03             	test   $0x3,%bl
  8008ca:	75 24                	jne    8008f0 <memset+0x44>
		c &= 0xFF;
  8008cc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cf:	89 d6                	mov    %edx,%esi
  8008d1:	c1 e6 08             	shl    $0x8,%esi
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	c1 e0 18             	shl    $0x18,%eax
  8008d9:	89 d1                	mov    %edx,%ecx
  8008db:	c1 e1 10             	shl    $0x10,%ecx
  8008de:	09 c8                	or     %ecx,%eax
  8008e0:	09 c2                	or     %eax,%edx
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	09 d0                	or     %edx,%eax
  8008e6:	89 d9                	mov    %ebx,%ecx
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	fc                   	cld    
  8008ec:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ee:	eb 05                	jmp    8008f5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f0:	89 d9                	mov    %ebx,%ecx
  8008f2:	fc                   	cld    
  8008f3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f5:	89 f8                	mov    %edi,%eax
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800907:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80090a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80090c:	39 c6                	cmp    %eax,%esi
  80090e:	73 36                	jae    800946 <memmove+0x4a>
  800910:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800913:	39 d0                	cmp    %edx,%eax
  800915:	73 2f                	jae    800946 <memmove+0x4a>
		s += n;
		d += n;
  800917:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f6 c2 03             	test   $0x3,%dl
  80091d:	75 1b                	jne    80093a <memmove+0x3e>
  80091f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800925:	75 13                	jne    80093a <memmove+0x3e>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0e                	jne    80093a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  80092c:	8d 7e fc             	lea    -0x4(%esi),%edi
  80092f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fd                   	std    
  800936:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800938:	eb 09                	jmp    800943 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093a:	8d 7e ff             	lea    -0x1(%esi),%edi
  80093d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800940:	fd                   	std    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800943:	fc                   	cld    
  800944:	eb 20                	jmp    800966 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094c:	75 15                	jne    800963 <memmove+0x67>
  80094e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800954:	75 0d                	jne    800963 <memmove+0x67>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 08                	jne    800963 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	fc                   	cld    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 03                	jmp    800966 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800963:	fc                   	cld    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096d:	ff 75 10             	pushl  0x10(%ebp)
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	ff 75 08             	pushl  0x8(%ebp)
  800976:	e8 81 ff ff ff       	call   8008fc <memmove>
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	83 ec 04             	sub    $0x4,%esp
  800984:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800987:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	eb 1b                	jmp    8009aa <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80098f:	8a 1a                	mov    (%edx),%bl
  800991:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800994:	8a 19                	mov    (%ecx),%bl
  800996:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800999:	74 0d                	je     8009a8 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80099b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80099f:	0f b6 c3             	movzbl %bl,%eax
  8009a2:	29 c2                	sub    %eax,%edx
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	eb 0d                	jmp    8009b5 <memcmp+0x38>
		s1++, s2++;
  8009a8:	42                   	inc    %edx
  8009a9:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009aa:	48                   	dec    %eax
  8009ab:	83 f8 ff             	cmp    $0xffffffff,%eax
  8009ae:	75 df                	jne    80098f <memcmp+0x12>
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8009b5:	83 c4 04             	add    $0x4,%esp
  8009b8:	5b                   	pop    %ebx
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c4:	89 c2                	mov    %eax,%edx
  8009c6:	03 55 10             	add    0x10(%ebp),%edx
  8009c9:	eb 05                	jmp    8009d0 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	38 08                	cmp    %cl,(%eax)
  8009cd:	74 05                	je     8009d4 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	40                   	inc    %eax
  8009d0:	39 d0                	cmp    %edx,%eax
  8009d2:	72 f7                	jb     8009cb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	83 ec 04             	sub    $0x4,%esp
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8009e5:	eb 01                	jmp    8009e8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8009e7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	8a 01                	mov    (%ecx),%al
  8009ea:	3c 20                	cmp    $0x20,%al
  8009ec:	74 f9                	je     8009e7 <strtol+0x11>
  8009ee:	3c 09                	cmp    $0x9,%al
  8009f0:	74 f5                	je     8009e7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f2:	3c 2b                	cmp    $0x2b,%al
  8009f4:	75 0a                	jne    800a00 <strtol+0x2a>
		s++;
  8009f6:	41                   	inc    %ecx
  8009f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8009fe:	eb 17                	jmp    800a17 <strtol+0x41>
	else if (*s == '-')
  800a00:	3c 2d                	cmp    $0x2d,%al
  800a02:	74 09                	je     800a0d <strtol+0x37>
  800a04:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a0b:	eb 0a                	jmp    800a17 <strtol+0x41>
		s++, neg = 1;
  800a0d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a10:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a17:	85 f6                	test   %esi,%esi
  800a19:	74 05                	je     800a20 <strtol+0x4a>
  800a1b:	83 fe 10             	cmp    $0x10,%esi
  800a1e:	75 1a                	jne    800a3a <strtol+0x64>
  800a20:	8a 01                	mov    (%ecx),%al
  800a22:	3c 30                	cmp    $0x30,%al
  800a24:	75 10                	jne    800a36 <strtol+0x60>
  800a26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2a:	75 0a                	jne    800a36 <strtol+0x60>
		s += 2, base = 16;
  800a2c:	83 c1 02             	add    $0x2,%ecx
  800a2f:	be 10 00 00 00       	mov    $0x10,%esi
  800a34:	eb 04                	jmp    800a3a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800a36:	85 f6                	test   %esi,%esi
  800a38:	74 07                	je     800a41 <strtol+0x6b>
  800a3a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3f:	eb 13                	jmp    800a54 <strtol+0x7e>
  800a41:	3c 30                	cmp    $0x30,%al
  800a43:	74 07                	je     800a4c <strtol+0x76>
  800a45:	be 0a 00 00 00       	mov    $0xa,%esi
  800a4a:	eb ee                	jmp    800a3a <strtol+0x64>
		s++, base = 8;
  800a4c:	41                   	inc    %ecx
  800a4d:	be 08 00 00 00       	mov    $0x8,%esi
  800a52:	eb e6                	jmp    800a3a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a54:	8a 11                	mov    (%ecx),%dl
  800a56:	88 d3                	mov    %dl,%bl
  800a58:	8d 42 d0             	lea    -0x30(%edx),%eax
  800a5b:	3c 09                	cmp    $0x9,%al
  800a5d:	77 08                	ja     800a67 <strtol+0x91>
			dig = *s - '0';
  800a5f:	0f be c2             	movsbl %dl,%eax
  800a62:	8d 50 d0             	lea    -0x30(%eax),%edx
  800a65:	eb 1c                	jmp    800a83 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a67:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800a6a:	3c 19                	cmp    $0x19,%al
  800a6c:	77 08                	ja     800a76 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a6e:	0f be c2             	movsbl %dl,%eax
  800a71:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a74:	eb 0d                	jmp    800a83 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a76:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a79:	3c 19                	cmp    $0x19,%al
  800a7b:	77 15                	ja     800a92 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a7d:	0f be c2             	movsbl %dl,%eax
  800a80:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a83:	39 f2                	cmp    %esi,%edx
  800a85:	7d 0b                	jge    800a92 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a87:	41                   	inc    %ecx
  800a88:	89 f8                	mov    %edi,%eax
  800a8a:	0f af c6             	imul   %esi,%eax
  800a8d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a90:	eb c2                	jmp    800a54 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a92:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a98:	74 05                	je     800a9f <strtol+0xc9>
		*endptr = (char *) s;
  800a9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800aa3:	74 04                	je     800aa9 <strtol+0xd3>
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	f7 df                	neg    %edi
}
  800aa9:	89 f8                	mov    %edi,%eax
  800aab:	83 c4 04             	add    $0x4,%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    
	...

00800ab4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b8 01 00 00 00       	mov    $0x1,%eax
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac4:	89 fa                	mov    %edi,%edx
  800ac6:	89 f9                	mov    %edi,%ecx
  800ac8:	89 fb                	mov    %edi,%ebx
  800aca:	89 fe                	mov    %edi,%esi
  800acc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae7:	89 f8                	mov    %edi,%eax
  800ae9:	89 fb                	mov    %edi,%ebx
  800aeb:	89 fe                	mov    %edi,%esi
  800aed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aef:	83 c4 04             	add    $0x4,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b08:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0d:	89 f9                	mov    %edi,%ecx
  800b0f:	89 fb                	mov    %edi,%ebx
  800b11:	89 fe                	mov    %edi,%esi
  800b13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 17                	jle    800b30 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	50                   	push   %eax
  800b1d:	6a 0d                	push   $0xd
  800b1f:	68 1f 28 80 00       	push   $0x80281f
  800b24:	6a 23                	push   $0x23
  800b26:	68 3c 28 80 00       	push   $0x80283c
  800b2b:	e8 6c f6 ff ff       	call   80019c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b47:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b4f:	be 00 00 00 00       	mov    $0x0,%esi
  800b54:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b74:	89 fb                	mov    %edi,%ebx
  800b76:	89 fe                	mov    %edi,%esi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 0a                	push   $0xa
  800b84:	68 1f 28 80 00       	push   $0x80281f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 3c 28 80 00       	push   $0x80283c
  800b90:	e8 07 f6 ff ff       	call   80019c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 09 00 00 00       	mov    $0x9,%eax
  800bb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb6:	89 fb                	mov    %edi,%ebx
  800bb8:	89 fe                	mov    %edi,%esi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 09                	push   $0x9
  800bc6:	68 1f 28 80 00       	push   $0x80281f
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 3c 28 80 00       	push   $0x80283c
  800bd2:	e8 c5 f5 ff ff       	call   80019c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf8:	89 fb                	mov    %edi,%ebx
  800bfa:	89 fe                	mov    %edi,%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 08                	push   $0x8
  800c08:	68 1f 28 80 00       	push   $0x80281f
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 3c 28 80 00       	push   $0x80283c
  800c14:	e8 83 f5 ff ff       	call   80019c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	b8 06 00 00 00       	mov    $0x6,%eax
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3a:	89 fb                	mov    %edi,%ebx
  800c3c:	89 fe                	mov    %edi,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 06                	push   $0x6
  800c4a:	68 1f 28 80 00       	push   $0x80281f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 3c 28 80 00       	push   $0x80283c
  800c56:	e8 41 f5 ff ff       	call   80019c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c78:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 05                	push   $0x5
  800c8c:	68 1f 28 80 00       	push   $0x80281f
  800c91:	6a 23                	push   $0x23
  800c93:	68 3c 28 80 00       	push   $0x80283c
  800c98:	e8 ff f4 ff ff       	call   80019c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cbc:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc1:	89 fe                	mov    %edi,%esi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 1f 28 80 00       	push   $0x80281f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 28 80 00       	push   $0x80283c
  800cdb:	e8 bc f4 ff ff       	call   80019c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf8:	89 fa                	mov    %edi,%edx
  800cfa:	89 f9                	mov    %edi,%ecx
  800cfc:	89 fb                	mov    %edi,%ebx
  800cfe:	89 fe                	mov    %edi,%esi
  800d00:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    

00800d07 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d12:	bf 00 00 00 00       	mov    $0x0,%edi
  800d17:	89 fa                	mov    %edi,%edx
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	89 fb                	mov    %edi,%ebx
  800d1d:	89 fe                	mov    %edi,%esi
  800d1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    

00800d26 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b8 03 00 00 00       	mov    $0x3,%eax
  800d37:	bf 00 00 00 00       	mov    $0x0,%edi
  800d3c:	89 f9                	mov    %edi,%ecx
  800d3e:	89 fb                	mov    %edi,%ebx
  800d40:	89 fe                	mov    %edi,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 03                	push   $0x3
  800d4e:	68 1f 28 80 00       	push   $0x80281f
  800d53:	6a 23                	push   $0x23
  800d55:	68 3c 28 80 00       	push   $0x80283c
  800d5a:	e8 3d f4 ff ff       	call   80019c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    
	...

00800d68 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d73:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d7b:	ff 75 08             	pushl  0x8(%ebp)
  800d7e:	e8 e5 ff ff ff       	call   800d68 <fd2num>
  800d83:	83 c4 04             	add    $0x4,%esp
  800d86:	c1 e0 0c             	shl    $0xc,%eax
  800d89:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d97:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800d9c:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9e:	89 d0                	mov    %edx,%eax
  800da0:	c1 e8 16             	shr    $0x16,%eax
  800da3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800daa:	a8 01                	test   $0x1,%al
  800dac:	74 10                	je     800dbe <fd_alloc+0x2e>
  800dae:	89 d0                	mov    %edx,%eax
  800db0:	c1 e8 0c             	shr    $0xc,%eax
  800db3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dba:	a8 01                	test   $0x1,%al
  800dbc:	75 09                	jne    800dc7 <fd_alloc+0x37>
			*fd_store = fd;
  800dbe:	89 0b                	mov    %ecx,(%ebx)
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc5:	eb 19                	jmp    800de0 <fd_alloc+0x50>
			return 0;
  800dc7:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dcd:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  800dd3:	75 c7                	jne    800d9c <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ddb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800de0:	5b                   	pop    %ebx
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    

00800de3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de9:	83 f8 1f             	cmp    $0x1f,%eax
  800dec:	77 35                	ja     800e23 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dee:	c1 e0 0c             	shl    $0xc,%eax
  800df1:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df7:	89 d0                	mov    %edx,%eax
  800df9:	c1 e8 16             	shr    $0x16,%eax
  800dfc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e03:	a8 01                	test   $0x1,%al
  800e05:	74 1c                	je     800e23 <fd_lookup+0x40>
  800e07:	89 d0                	mov    %edx,%eax
  800e09:	c1 e8 0c             	shr    $0xc,%eax
  800e0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e13:	a8 01                	test   $0x1,%al
  800e15:	74 0c                	je     800e23 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	89 10                	mov    %edx,(%eax)
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	eb 05                	jmp    800e28 <fd_lookup+0x45>
	return 0;
  800e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e30:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800e33:	50                   	push   %eax
  800e34:	ff 75 08             	pushl  0x8(%ebp)
  800e37:	e8 a7 ff ff ff       	call   800de3 <fd_lookup>
  800e3c:	83 c4 08             	add    $0x8,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 0e                	js     800e51 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800e43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e49:	89 50 04             	mov    %edx,0x4(%eax)
  800e4c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e60:	ba 00 00 00 00       	mov    $0x0,%edx
  800e65:	eb 0e                	jmp    800e75 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e67:	3b 08                	cmp    (%eax),%ecx
  800e69:	75 09                	jne    800e74 <dev_lookup+0x21>
			*dev = devtab[i];
  800e6b:	89 03                	mov    %eax,(%ebx)
  800e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e72:	eb 31                	jmp    800ea5 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e74:	42                   	inc    %edx
  800e75:	8b 04 95 c8 28 80 00 	mov    0x8028c8(,%edx,4),%eax
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	75 e7                	jne    800e67 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e80:	a1 04 40 80 00       	mov    0x804004,%eax
  800e85:	8b 40 48             	mov    0x48(%eax),%eax
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	51                   	push   %ecx
  800e8c:	50                   	push   %eax
  800e8d:	68 4c 28 80 00       	push   $0x80284c
  800e92:	e8 a6 f3 ff ff       	call   80023d <cprintf>
	*dev = 0;
  800e97:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea2:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  800ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	53                   	push   %ebx
  800eae:	83 ec 14             	sub    $0x14,%esp
  800eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb7:	50                   	push   %eax
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 23 ff ff ff       	call   800de3 <fd_lookup>
  800ec0:	83 c4 08             	add    $0x8,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 55                	js     800f1c <fstat+0x72>
  800ec7:	83 ec 08             	sub    $0x8,%esp
  800eca:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800ecd:	50                   	push   %eax
  800ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed1:	ff 30                	pushl  (%eax)
  800ed3:	e8 7b ff ff ff       	call   800e53 <dev_lookup>
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	78 3d                	js     800f1c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800edf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ee2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ee6:	75 07                	jne    800eef <fstat+0x45>
  800ee8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800eed:	eb 2d                	jmp    800f1c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800eef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ef2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ef9:	00 00 00 
	stat->st_isdir = 0;
  800efc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f03:	00 00 00 
	stat->st_dev = dev;
  800f06:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f09:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800f0f:	83 ec 08             	sub    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	ff 75 f4             	pushl  -0xc(%ebp)
  800f16:	ff 50 14             	call   *0x14(%eax)
  800f19:	83 c4 10             	add    $0x10,%esp
}
  800f1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	53                   	push   %ebx
  800f25:	83 ec 14             	sub    $0x14,%esp
  800f28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f2e:	50                   	push   %eax
  800f2f:	53                   	push   %ebx
  800f30:	e8 ae fe ff ff       	call   800de3 <fd_lookup>
  800f35:	83 c4 08             	add    $0x8,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	78 5f                	js     800f9b <ftruncate+0x7a>
  800f3c:	83 ec 08             	sub    $0x8,%esp
  800f3f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800f42:	50                   	push   %eax
  800f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f46:	ff 30                	pushl  (%eax)
  800f48:	e8 06 ff ff ff       	call   800e53 <dev_lookup>
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 47                	js     800f9b <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f57:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800f5b:	75 21                	jne    800f7e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800f5d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f62:	8b 40 48             	mov    0x48(%eax),%eax
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	53                   	push   %ebx
  800f69:	50                   	push   %eax
  800f6a:	68 6c 28 80 00       	push   $0x80286c
  800f6f:	e8 c9 f2 ff ff       	call   80023d <cprintf>
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	eb 1d                	jmp    800f9b <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800f7e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800f81:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  800f85:	75 07                	jne    800f8e <ftruncate+0x6d>
  800f87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f8c:	eb 0d                	jmp    800f9b <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	ff 75 0c             	pushl  0xc(%ebp)
  800f94:	50                   	push   %eax
  800f95:	ff 52 18             	call   *0x18(%edx)
  800f98:	83 c4 10             	add    $0x10,%esp
}
  800f9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 14             	sub    $0x14,%esp
  800fa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800faa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	53                   	push   %ebx
  800faf:	e8 2f fe ff ff       	call   800de3 <fd_lookup>
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 62                	js     80101d <write+0x7d>
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc5:	ff 30                	pushl  (%eax)
  800fc7:	e8 87 fe ff ff       	call   800e53 <dev_lookup>
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 4a                	js     80101d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800fda:	75 21                	jne    800ffd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800fdc:	a1 04 40 80 00       	mov    0x804004,%eax
  800fe1:	8b 40 48             	mov    0x48(%eax),%eax
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	50                   	push   %eax
  800fe9:	68 8d 28 80 00       	push   $0x80288d
  800fee:	e8 4a f2 ff ff       	call   80023d <cprintf>
  800ff3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	eb 20                	jmp    80101d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ffd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801000:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801004:	75 07                	jne    80100d <write+0x6d>
  801006:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80100b:	eb 10                	jmp    80101d <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	ff 75 10             	pushl  0x10(%ebp)
  801013:	ff 75 0c             	pushl  0xc(%ebp)
  801016:	50                   	push   %eax
  801017:	ff 52 0c             	call   *0xc(%edx)
  80101a:	83 c4 10             	add    $0x10,%esp
}
  80101d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	53                   	push   %ebx
  801026:	83 ec 14             	sub    $0x14,%esp
  801029:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80102c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102f:	50                   	push   %eax
  801030:	53                   	push   %ebx
  801031:	e8 ad fd ff ff       	call   800de3 <fd_lookup>
  801036:	83 c4 08             	add    $0x8,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 67                	js     8010a4 <read+0x82>
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801043:	50                   	push   %eax
  801044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801047:	ff 30                	pushl  (%eax)
  801049:	e8 05 fe ff ff       	call   800e53 <dev_lookup>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	78 4f                	js     8010a4 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801055:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801058:	8b 42 08             	mov    0x8(%edx),%eax
  80105b:	83 e0 03             	and    $0x3,%eax
  80105e:	83 f8 01             	cmp    $0x1,%eax
  801061:	75 21                	jne    801084 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801063:	a1 04 40 80 00       	mov    0x804004,%eax
  801068:	8b 40 48             	mov    0x48(%eax),%eax
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	53                   	push   %ebx
  80106f:	50                   	push   %eax
  801070:	68 aa 28 80 00       	push   $0x8028aa
  801075:	e8 c3 f1 ff ff       	call   80023d <cprintf>
  80107a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	eb 20                	jmp    8010a4 <read+0x82>
	}
	if (!dev->dev_read)
  801084:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801087:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80108b:	75 07                	jne    801094 <read+0x72>
  80108d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801092:	eb 10                	jmp    8010a4 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	ff 75 10             	pushl  0x10(%ebp)
  80109a:	ff 75 0c             	pushl  0xc(%ebp)
  80109d:	52                   	push   %edx
  80109e:	ff 50 08             	call   *0x8(%eax)
  8010a1:	83 c4 10             	add    $0x10,%esp
}
  8010a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a7:	c9                   	leave  
  8010a8:	c3                   	ret    

008010a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	57                   	push   %edi
  8010ad:	56                   	push   %esi
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010b5:	8b 75 10             	mov    0x10(%ebp),%esi
  8010b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bd:	eb 21                	jmp    8010e0 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	89 f0                	mov    %esi,%eax
  8010c4:	29 d0                	sub    %edx,%eax
  8010c6:	50                   	push   %eax
  8010c7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8010ca:	50                   	push   %eax
  8010cb:	ff 75 08             	pushl  0x8(%ebp)
  8010ce:	e8 4f ff ff ff       	call   801022 <read>
		if (m < 0)
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 0e                	js     8010e8 <readn+0x3f>
			return m;
		if (m == 0)
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	74 08                	je     8010e6 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010de:	01 c3                	add    %eax,%ebx
  8010e0:	89 da                	mov    %ebx,%edx
  8010e2:	39 f3                	cmp    %esi,%ebx
  8010e4:	72 d9                	jb     8010bf <readn+0x16>
  8010e6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	c9                   	leave  
  8010ef:	c3                   	ret    

008010f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 20             	sub    $0x20,%esp
  8010f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010fb:	8a 45 0c             	mov    0xc(%ebp),%al
  8010fe:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	56                   	push   %esi
  801106:	e8 5d fc ff ff       	call   800d68 <fd2num>
  80110b:	89 04 24             	mov    %eax,(%esp)
  80110e:	e8 d0 fc ff ff       	call   800de3 <fd_lookup>
  801113:	89 c3                	mov    %eax,%ebx
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 05                	js     801121 <fd_close+0x31>
  80111c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80111f:	74 0d                	je     80112e <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801121:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801125:	75 48                	jne    80116f <fd_close+0x7f>
  801127:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112c:	eb 41                	jmp    80116f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	ff 36                	pushl  (%esi)
  801137:	e8 17 fd ff ff       	call   800e53 <dev_lookup>
  80113c:	89 c3                	mov    %eax,%ebx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 1c                	js     801161 <fd_close+0x71>
		if (dev->dev_close)
  801145:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801148:	8b 40 10             	mov    0x10(%eax),%eax
  80114b:	85 c0                	test   %eax,%eax
  80114d:	75 07                	jne    801156 <fd_close+0x66>
  80114f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801154:	eb 0b                	jmp    801161 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	56                   	push   %esi
  80115a:	ff d0                	call   *%eax
  80115c:	89 c3                	mov    %eax,%ebx
  80115e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	56                   	push   %esi
  801165:	6a 00                	push   $0x0
  801167:	e8 b5 fa ff ff       	call   800c21 <sys_page_unmap>
  80116c:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80116f:	89 d8                	mov    %ebx,%eax
  801171:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	ff 75 08             	pushl  0x8(%ebp)
  801185:	e8 59 fc ff ff       	call   800de3 <fd_lookup>
  80118a:	83 c4 08             	add    $0x8,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 10                	js     8011a1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	6a 01                	push   $0x1
  801196:	ff 75 fc             	pushl  -0x4(%ebp)
  801199:	e8 52 ff ff ff       	call   8010f0 <fd_close>
  80119e:	83 c4 10             	add    $0x10,%esp
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	6a 00                	push   $0x0
  8011ad:	ff 75 08             	pushl  0x8(%ebp)
  8011b0:	e8 4a 03 00 00       	call   8014ff <open>
  8011b5:	89 c6                	mov    %eax,%esi
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 1b                	js     8011d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	ff 75 0c             	pushl  0xc(%ebp)
  8011c4:	50                   	push   %eax
  8011c5:	e8 e0 fc ff ff       	call   800eaa <fstat>
  8011ca:	89 c3                	mov    %eax,%ebx
	close(fd);
  8011cc:	89 34 24             	mov    %esi,(%esp)
  8011cf:	e8 a4 ff ff ff       	call   801178 <close>
  8011d4:	89 de                	mov    %ebx,%esi
  8011d6:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011de:	5b                   	pop    %ebx
  8011df:	5e                   	pop    %esi
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
  8011eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 e9 fb ff ff       	call   800de3 <fd_lookup>
  8011fa:	89 c3                	mov    %eax,%ebx
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	0f 88 bd 00 00 00    	js     8012c4 <dup+0xe2>
		return r;
	close(newfdnum);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	57                   	push   %edi
  80120b:	e8 68 ff ff ff       	call   801178 <close>

	newfd = INDEX2FD(newfdnum);
  801210:	89 f8                	mov    %edi,%eax
  801212:	c1 e0 0c             	shl    $0xc,%eax
  801215:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80121b:	ff 75 f0             	pushl  -0x10(%ebp)
  80121e:	e8 55 fb ff ff       	call   800d78 <fd2data>
  801223:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801225:	89 34 24             	mov    %esi,(%esp)
  801228:	e8 4b fb ff ff       	call   800d78 <fd2data>
  80122d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801230:	89 d8                	mov    %ebx,%eax
  801232:	c1 e8 16             	shr    $0x16,%eax
  801235:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80123c:	83 c4 14             	add    $0x14,%esp
  80123f:	a8 01                	test   $0x1,%al
  801241:	74 36                	je     801279 <dup+0x97>
  801243:	89 da                	mov    %ebx,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80124f:	a8 01                	test   $0x1,%al
  801251:	74 26                	je     801279 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801253:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	25 07 0e 00 00       	and    $0xe07,%eax
  801262:	50                   	push   %eax
  801263:	ff 75 e0             	pushl  -0x20(%ebp)
  801266:	6a 00                	push   $0x0
  801268:	53                   	push   %ebx
  801269:	6a 00                	push   $0x0
  80126b:	e8 f3 f9 ff ff       	call   800c63 <sys_page_map>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 20             	add    $0x20,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 30                	js     8012a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801279:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80127c:	89 d0                	mov    %edx,%eax
  80127e:	c1 e8 0c             	shr    $0xc,%eax
  801281:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	25 07 0e 00 00       	and    $0xe07,%eax
  801290:	50                   	push   %eax
  801291:	56                   	push   %esi
  801292:	6a 00                	push   $0x0
  801294:	52                   	push   %edx
  801295:	6a 00                	push   $0x0
  801297:	e8 c7 f9 ff ff       	call   800c63 <sys_page_map>
  80129c:	89 c3                	mov    %eax,%ebx
  80129e:	83 c4 20             	add    $0x20,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 04                	js     8012a9 <dup+0xc7>
		goto err;
  8012a5:	89 fb                	mov    %edi,%ebx
  8012a7:	eb 1b                	jmp    8012c4 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	56                   	push   %esi
  8012ad:	6a 00                	push   $0x0
  8012af:	e8 6d f9 ff ff       	call   800c21 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8012ba:	6a 00                	push   $0x0
  8012bc:	e8 60 f9 ff ff       	call   800c21 <sys_page_unmap>
  8012c1:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	53                   	push   %ebx
  8012de:	e8 95 fe ff ff       	call   801178 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e3:	43                   	inc    %ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	83 fb 20             	cmp    $0x20,%ebx
  8012ea:	75 ee                	jne    8012da <close_all+0xc>
		close(i);
}
  8012ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    
  8012f1:	00 00                	add    %al,(%eax)
	...

008012f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801304:	75 12                	jne    801318 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	6a 01                	push   $0x1
  80130b:	e8 18 0d 00 00       	call   802028 <ipc_find_env>
  801310:	a3 00 40 80 00       	mov    %eax,0x804000
  801315:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801318:	6a 07                	push   $0x7
  80131a:	68 00 50 80 00       	push   $0x805000
  80131f:	53                   	push   %ebx
  801320:	ff 35 00 40 80 00    	pushl  0x804000
  801326:	e8 42 0d 00 00       	call   80206d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132b:	83 c4 0c             	add    $0xc,%esp
  80132e:	6a 00                	push   $0x0
  801330:	56                   	push   %esi
  801331:	6a 00                	push   $0x0
  801333:	e8 8a 0d 00 00       	call   8020c2 <ipc_recv>
}
  801338:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801345:	ba 00 00 00 00       	mov    $0x0,%edx
  80134a:	b8 08 00 00 00       	mov    $0x8,%eax
  80134f:	e8 a0 ff ff ff       	call   8012f4 <fsipc>
}
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80135c:	8b 45 08             	mov    0x8(%ebp),%eax
  80135f:	8b 40 0c             	mov    0xc(%eax),%eax
  801362:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	b8 02 00 00 00       	mov    $0x2,%eax
  801379:	e8 76 ff ff ff       	call   8012f4 <fsipc>
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	8b 40 0c             	mov    0xc(%eax),%eax
  80138c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801391:	ba 00 00 00 00       	mov    $0x0,%edx
  801396:	b8 06 00 00 00       	mov    $0x6,%eax
  80139b:	e8 54 ff ff ff       	call   8012f4 <fsipc>
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8013c1:	e8 2e ff ff ff       	call   8012f4 <fsipc>
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 2c                	js     8013f6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	68 00 50 80 00       	push   $0x805000
  8013d2:	53                   	push   %ebx
  8013d3:	e8 b7 f3 ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013e3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f3:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8013f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801410:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801416:	53                   	push   %ebx
  801417:	ff 75 0c             	pushl  0xc(%ebp)
  80141a:	68 08 50 80 00       	push   $0x805008
  80141f:	e8 d8 f4 ff ff       	call   8008fc <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	b8 04 00 00 00       	mov    $0x4,%eax
  80142e:	e8 c1 fe ff ff       	call   8012f4 <fsipc>
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	85 c0                	test   %eax,%eax
  801438:	78 3d                	js     801477 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80143a:	39 c3                	cmp    %eax,%ebx
  80143c:	73 19                	jae    801457 <devfile_write+0x5c>
  80143e:	68 d8 28 80 00       	push   $0x8028d8
  801443:	68 df 28 80 00       	push   $0x8028df
  801448:	68 97 00 00 00       	push   $0x97
  80144d:	68 f4 28 80 00       	push   $0x8028f4
  801452:	e8 45 ed ff ff       	call   80019c <_panic>
	assert(r <= PGSIZE);
  801457:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80145c:	7e 19                	jle    801477 <devfile_write+0x7c>
  80145e:	68 ff 28 80 00       	push   $0x8028ff
  801463:	68 df 28 80 00       	push   $0x8028df
  801468:	68 98 00 00 00       	push   $0x98
  80146d:	68 f4 28 80 00       	push   $0x8028f4
  801472:	e8 25 ed ff ff       	call   80019c <_panic>
	
	return r;
}
  801477:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 03 00 00 00       	mov    $0x3,%eax
  80149f:	e8 50 fe ff ff       	call   8012f4 <fsipc>
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 4c                	js     8014f6 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8014aa:	39 de                	cmp    %ebx,%esi
  8014ac:	73 16                	jae    8014c4 <devfile_read+0x48>
  8014ae:	68 d8 28 80 00       	push   $0x8028d8
  8014b3:	68 df 28 80 00       	push   $0x8028df
  8014b8:	6a 7c                	push   $0x7c
  8014ba:	68 f4 28 80 00       	push   $0x8028f4
  8014bf:	e8 d8 ec ff ff       	call   80019c <_panic>
	assert(r <= PGSIZE);
  8014c4:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8014ca:	7e 16                	jle    8014e2 <devfile_read+0x66>
  8014cc:	68 ff 28 80 00       	push   $0x8028ff
  8014d1:	68 df 28 80 00       	push   $0x8028df
  8014d6:	6a 7d                	push   $0x7d
  8014d8:	68 f4 28 80 00       	push   $0x8028f4
  8014dd:	e8 ba ec ff ff       	call   80019c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	50                   	push   %eax
  8014e6:	68 00 50 80 00       	push   $0x805000
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	e8 09 f4 ff ff       	call   8008fc <memmove>
  8014f3:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014f6:	89 d8                	mov    %ebx,%eax
  8014f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 1c             	sub    $0x1c,%esp
  801507:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80150a:	56                   	push   %esi
  80150b:	e8 4c f2 ff ff       	call   80075c <strlen>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801518:	7e 07                	jle    801521 <open+0x22>
  80151a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80151f:	eb 63                	jmp    801584 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	e8 63 f8 ff ff       	call   800d90 <fd_alloc>
  80152d:	89 c3                	mov    %eax,%ebx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	78 4e                	js     801584 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	56                   	push   %esi
  80153a:	68 00 50 80 00       	push   $0x805000
  80153f:	e8 4b f2 ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801544:	8b 45 0c             	mov    0xc(%ebp),%eax
  801547:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80154c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154f:	b8 01 00 00 00       	mov    $0x1,%eax
  801554:	e8 9b fd ff ff       	call   8012f4 <fsipc>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	79 12                	jns    801574 <open+0x75>
		fd_close(fd, 0);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	6a 00                	push   $0x0
  801567:	ff 75 f4             	pushl  -0xc(%ebp)
  80156a:	e8 81 fb ff ff       	call   8010f0 <fd_close>
		return r;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb 10                	jmp    801584 <open+0x85>
	}

	return fd2num(fd);
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	ff 75 f4             	pushl  -0xc(%ebp)
  80157a:	e8 e9 f7 ff ff       	call   800d68 <fd2num>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	83 c4 10             	add    $0x10,%esp
}
  801584:	89 d8                	mov    %ebx,%eax
  801586:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    
  80158d:	00 00                	add    %al,(%eax)
	...

00801590 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80159c:	6a 00                	push   $0x0
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	e8 59 ff ff ff       	call   8014ff <open>
  8015a6:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	79 0b                	jns    8015be <spawn+0x2e>
  8015b3:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  8015b9:	e9 13 05 00 00       	jmp    801ad1 <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	68 00 02 00 00       	push   $0x200
  8015c6:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8015d3:	e8 d1 fa ff ff       	call   8010a9 <readn>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015e0:	75 0c                	jne    8015ee <spawn+0x5e>
  8015e2:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  8015e9:	45 4c 46 
  8015ec:	74 38                	je     801626 <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8015f7:	e8 7c fb ff ff       	call   801178 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015fc:	83 c4 0c             	add    $0xc,%esp
  8015ff:	68 7f 45 4c 46       	push   $0x464c457f
  801604:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  80160a:	68 0b 29 80 00       	push   $0x80290b
  80160f:	e8 29 ec ff ff       	call   80023d <cprintf>
  801614:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  80161b:	ff ff ff 
		return -E_NOT_EXEC;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	e9 ab 04 00 00       	jmp    801ad1 <spawn+0x541>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801626:	ba 07 00 00 00       	mov    $0x7,%edx
  80162b:	89 d0                	mov    %edx,%eax
  80162d:	cd 30                	int    $0x30
  80162f:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801635:	85 c0                	test   %eax,%eax
  801637:	0f 88 94 04 00 00    	js     801ad1 <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80163d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801642:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801649:	c1 e0 07             	shl    $0x7,%eax
  80164c:	29 d0                	sub    %edx,%eax
  80164e:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  801654:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	6a 44                	push   $0x44
  80165e:	50                   	push   %eax
  80165f:	52                   	push   %edx
  801660:	e8 05 f3 ff ff       	call   80096a <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801665:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  80166b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  801671:	bb 00 00 00 00       	mov    $0x0,%ebx
  801676:	be 00 00 00 00       	mov    $0x0,%esi
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	eb 11                	jmp    801691 <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	50                   	push   %eax
  801684:	e8 d3 f0 ff ff       	call   80075c <strlen>
  801689:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80168d:	46                   	inc    %esi
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	8b 55 0c             	mov    0xc(%ebp),%edx
  801694:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  801697:	85 c0                	test   %eax,%eax
  801699:	75 e5                	jne    801680 <spawn+0xf0>
  80169b:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8016a1:	89 f1                	mov    %esi,%ecx
  8016a3:	c1 e1 02             	shl    $0x2,%ecx
  8016a6:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016ac:	b8 00 10 40 00       	mov    $0x401000,%eax
  8016b1:	89 c7                	mov    %eax,%edi
  8016b3:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016b5:	89 f8                	mov    %edi,%eax
  8016b7:	83 e0 fc             	and    $0xfffffffc,%eax
  8016ba:	29 c8                	sub    %ecx,%eax
  8016bc:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  8016c2:	83 e8 04             	sub    $0x4,%eax
  8016c5:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016cb:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8016d1:	83 e8 0c             	sub    $0xc,%eax
  8016d4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016d9:	0f 86 c1 03 00 00    	jbe    801aa0 <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016df:	83 ec 04             	sub    $0x4,%esp
  8016e2:	6a 07                	push   $0x7
  8016e4:	68 00 00 40 00       	push   $0x400000
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 b5 f5 ff ff       	call   800ca5 <sys_page_alloc>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	0f 88 aa 03 00 00    	js     801aa5 <spawn+0x515>
  8016fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801700:	eb 35                	jmp    801737 <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801702:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801708:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  80170e:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801718:	ff 34 99             	pushl  (%ecx,%ebx,4)
  80171b:	57                   	push   %edi
  80171c:	e8 6e f0 ff ff       	call   80078f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801721:	83 c4 04             	add    $0x4,%esp
  801724:	8b 45 0c             	mov    0xc(%ebp),%eax
  801727:	ff 34 98             	pushl  (%eax,%ebx,4)
  80172a:	e8 2d f0 ff ff       	call   80075c <strlen>
  80172f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801733:	43                   	inc    %ebx
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	39 f3                	cmp    %esi,%ebx
  801739:	7c c7                	jl     801702 <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80173b:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801741:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801747:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80174e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801754:	74 19                	je     80176f <spawn+0x1df>
  801756:	68 80 29 80 00       	push   $0x802980
  80175b:	68 df 28 80 00       	push   $0x8028df
  801760:	68 f2 00 00 00       	push   $0xf2
  801765:	68 25 29 80 00       	push   $0x802925
  80176a:	e8 2d ea ff ff       	call   80019c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80176f:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801775:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80177a:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801780:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801783:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  801789:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  80178c:	89 d0                	mov    %edx,%eax
  80178e:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801793:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	6a 07                	push   $0x7
  80179e:	68 00 d0 bf ee       	push   $0xeebfd000
  8017a3:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8017a9:	68 00 00 40 00       	push   $0x400000
  8017ae:	6a 00                	push   $0x0
  8017b0:	e8 ae f4 ff ff       	call   800c63 <sys_page_map>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	83 c4 20             	add    $0x20,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	78 1c                	js     8017da <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	68 00 00 40 00       	push   $0x400000
  8017c6:	6a 00                	push   $0x0
  8017c8:	e8 54 f4 ff ff       	call   800c21 <sys_page_unmap>
  8017cd:	89 c3                	mov    %eax,%ebx
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	0f 89 d3 02 00 00    	jns    801aad <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	68 00 00 40 00       	push   $0x400000
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 38 f4 ff ff       	call   800c21 <sys_page_unmap>
  8017e9:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	e9 da 02 00 00       	jmp    801ad1 <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017f7:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8017fd:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  801801:	0f 85 79 01 00 00    	jne    801980 <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801807:	8b 42 f8             	mov    -0x8(%edx),%eax
  80180a:	83 e0 02             	and    $0x2,%eax
  80180d:	83 f8 01             	cmp    $0x1,%eax
  801810:	19 c0                	sbb    %eax,%eax
  801812:	83 e0 fe             	and    $0xfffffffe,%eax
  801815:	83 c0 07             	add    $0x7,%eax
  801818:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80181e:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  801821:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801827:	8b 42 f0             	mov    -0x10(%edx),%eax
  80182a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801830:	8b 4a f4             	mov    -0xc(%edx),%ecx
  801833:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801839:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801844:	74 16                	je     80185c <spawn+0x2cc>
		va -= i;
  801846:	29 d0                	sub    %edx,%eax
		memsz += i;
  801848:	01 d1                	add    %edx,%ecx
  80184a:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  801850:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  801856:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  80185c:	89 c7                	mov    %eax,%edi
  80185e:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801865:	00 00 00 
  801868:	e9 01 01 00 00       	jmp    80196e <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  80186d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801873:	77 27                	ja     80189c <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80187e:	57                   	push   %edi
  80187f:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801885:	e8 1b f4 ff ff       	call   800ca5 <sys_page_alloc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	0f 89 c7 00 00 00    	jns    80195e <spawn+0x3ce>
  801897:	e9 dd 01 00 00       	jmp    801a79 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80189c:	83 ec 04             	sub    $0x4,%esp
  80189f:	6a 07                	push   $0x7
  8018a1:	68 00 00 40 00       	push   $0x400000
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 f8 f3 ff ff       	call   800ca5 <sys_page_alloc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 bf 01 00 00    	js     801a79 <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  8018c3:	8d 04 16             	lea    (%esi,%edx,1),%eax
  8018c6:	50                   	push   %eax
  8018c7:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8018cd:	e8 58 f5 ff ff       	call   800e2a <seek>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	0f 88 9a 01 00 00    	js     801a79 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8018e8:	29 f0                	sub    %esi,%eax
  8018ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ef:	76 05                	jbe    8018f6 <spawn+0x366>
  8018f1:	b8 00 10 00 00       	mov    $0x1000,%eax
  8018f6:	50                   	push   %eax
  8018f7:	68 00 00 40 00       	push   $0x400000
  8018fc:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801902:	e8 a2 f7 ff ff       	call   8010a9 <readn>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	0f 88 65 01 00 00    	js     801a79 <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80191d:	57                   	push   %edi
  80191e:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801924:	68 00 00 40 00       	push   $0x400000
  801929:	6a 00                	push   $0x0
  80192b:	e8 33 f3 ff ff       	call   800c63 <sys_page_map>
  801930:	83 c4 20             	add    $0x20,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	79 15                	jns    80194c <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  801937:	50                   	push   %eax
  801938:	68 31 29 80 00       	push   $0x802931
  80193d:	68 25 01 00 00       	push   $0x125
  801942:	68 25 29 80 00       	push   $0x802925
  801947:	e8 50 e8 ff ff       	call   80019c <_panic>
			sys_page_unmap(0, UTEMP);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	68 00 00 40 00       	push   $0x400000
  801954:	6a 00                	push   $0x0
  801956:	e8 c6 f2 ff ff       	call   800c21 <sys_page_unmap>
  80195b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80195e:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  801965:	10 00 00 
  801968:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80196e:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801974:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  80197a:	0f 87 ed fe ff ff    	ja     80186d <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801980:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  801986:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  80198d:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801994:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  80199a:	0f 8c 57 fe ff ff    	jl     8017f7 <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8019a9:	e8 ca f7 ff ff       	call   801178 <close>
  8019ae:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8019b3:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	c1 e8 16             	shr    $0x16,%eax
  8019bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019c2:	a8 01                	test   $0x1,%al
  8019c4:	74 3e                	je     801a04 <spawn+0x474>
  8019c6:	89 da                	mov    %ebx,%edx
  8019c8:	c1 ea 0c             	shr    $0xc,%edx
  8019cb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019d2:	a8 01                	test   $0x1,%al
  8019d4:	74 2e                	je     801a04 <spawn+0x474>
  8019d6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019dd:	f6 c4 04             	test   $0x4,%ah
  8019e0:	74 22                	je     801a04 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8019e2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8019f1:	50                   	push   %eax
  8019f2:	53                   	push   %ebx
  8019f3:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8019f9:	53                   	push   %ebx
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 62 f2 ff ff       	call   800c63 <sys_page_map>
  801a01:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  801a04:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a0a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a10:	75 a4                	jne    8019b6 <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801a12:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  801a19:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  801a25:	50                   	push   %eax
  801a26:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801a2c:	e8 6c f1 ff ff       	call   800b9d <sys_env_set_trapframe>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	79 15                	jns    801a4d <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  801a38:	50                   	push   %eax
  801a39:	68 4e 29 80 00       	push   $0x80294e
  801a3e:	68 86 00 00 00       	push   $0x86
  801a43:	68 25 29 80 00       	push   $0x802925
  801a48:	e8 4f e7 ff ff       	call   80019c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	6a 02                	push   $0x2
  801a52:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801a58:	e8 82 f1 ff ff       	call   800bdf <sys_env_set_status>
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	79 6d                	jns    801ad1 <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  801a64:	50                   	push   %eax
  801a65:	68 68 29 80 00       	push   $0x802968
  801a6a:	68 89 00 00 00       	push   $0x89
  801a6f:	68 25 29 80 00       	push   $0x802925
  801a74:	e8 23 e7 ff ff       	call   80019c <_panic>

	return child;

error:
	sys_env_destroy(child);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801a82:	e8 9f f2 ff ff       	call   800d26 <sys_env_destroy>
	close(fd);
  801a87:	83 c4 04             	add    $0x4,%esp
  801a8a:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801a90:	e8 e3 f6 ff ff       	call   801178 <close>
  801a95:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	eb 31                	jmp    801ad1 <spawn+0x541>
  801aa0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801aa5:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801aab:	eb 24                	jmp    801ad1 <spawn+0x541>
  801aad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab0:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  801ab6:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  801abc:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  801ac2:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  801ac9:	00 00 00 
  801acc:	e9 bc fe ff ff       	jmp    80198d <spawn+0x3fd>
	return r;
}
  801ad1:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 1c             	sub    $0x1c,%esp
  801ae8:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801aea:	8d 45 10             	lea    0x10(%ebp),%eax
  801aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801af0:	be 00 00 00 00       	mov    $0x0,%esi
  801af5:	eb 01                	jmp    801af8 <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  801af7:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801af8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801afb:	8d 42 04             	lea    0x4(%edx),%eax
  801afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b01:	83 3a 00             	cmpl   $0x0,(%edx)
  801b04:	75 f1                	jne    801af7 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b06:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  801b0d:	83 e0 f0             	and    $0xfffffff0,%eax
  801b10:	29 c4                	sub    %eax,%esp
  801b12:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  801b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1e:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  801b20:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  801b27:	00 

	va_start(vl, arg0);
  801b28:	8d 45 10             	lea    0x10(%ebp),%eax
  801b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b33:	eb 0f                	jmp    801b44 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  801b35:	41                   	inc    %ecx
  801b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b39:	8d 50 04             	lea    0x4(%eax),%edx
  801b3c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b3f:	8b 00                	mov    (%eax),%eax
  801b41:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b44:	39 f1                	cmp    %esi,%ecx
  801b46:	75 ed                	jne    801b35 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	53                   	push   %ebx
  801b4c:	ff 75 08             	pushl  0x8(%ebp)
  801b4f:	e8 3c fa ff ff       	call   801590 <spawn>
  801b54:	89 fc                	mov    %edi,%esp
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    
	...

00801b60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 08             	pushl  0x8(%ebp)
  801b6e:	e8 05 f2 ff ff       	call   800d78 <fd2data>
  801b73:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b75:	83 c4 08             	add    $0x8,%esp
  801b78:	68 a6 29 80 00       	push   $0x8029a6
  801b7d:	53                   	push   %ebx
  801b7e:	e8 0c ec ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b83:	8b 46 04             	mov    0x4(%esi),%eax
  801b86:	2b 06                	sub    (%esi),%eax
  801b88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b95:	00 00 00 
	stat->st_dev = &devpipe;
  801b98:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b9f:	30 80 00 
	return 0;
}
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 0c             	sub    $0xc,%esp
  801bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bb8:	53                   	push   %ebx
  801bb9:	6a 00                	push   $0x0
  801bbb:	e8 61 f0 ff ff       	call   800c21 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc0:	89 1c 24             	mov    %ebx,(%esp)
  801bc3:	e8 b0 f1 ff ff       	call   800d78 <fd2data>
  801bc8:	83 c4 08             	add    $0x8,%esp
  801bcb:	50                   	push   %eax
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 4e f0 ff ff       	call   800c21 <sys_page_unmap>
}
  801bd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	53                   	push   %ebx
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801be4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be6:	a1 04 40 80 00       	mov    0x804004,%eax
  801beb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bee:	83 ec 0c             	sub    $0xc,%esp
  801bf1:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf4:	e8 33 05 00 00       	call   80212c <pageref>
  801bf9:	89 c3                	mov    %eax,%ebx
  801bfb:	89 3c 24             	mov    %edi,(%esp)
  801bfe:	e8 29 05 00 00       	call   80212c <pageref>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	39 c3                	cmp    %eax,%ebx
  801c08:	0f 94 c0             	sete   %al
  801c0b:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801c0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c14:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801c17:	39 c6                	cmp    %eax,%esi
  801c19:	74 1b                	je     801c36 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801c1b:	83 f9 01             	cmp    $0x1,%ecx
  801c1e:	75 c6                	jne    801be6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c20:	8b 42 58             	mov    0x58(%edx),%eax
  801c23:	6a 01                	push   $0x1
  801c25:	50                   	push   %eax
  801c26:	56                   	push   %esi
  801c27:	68 ad 29 80 00       	push   $0x8029ad
  801c2c:	e8 0c e6 ff ff       	call   80023d <cprintf>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	eb b0                	jmp    801be6 <_pipeisclosed+0xe>
	}
}
  801c36:	89 c8                	mov    %ecx,%eax
  801c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5f                   	pop    %edi
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	57                   	push   %edi
  801c44:	56                   	push   %esi
  801c45:	53                   	push   %ebx
  801c46:	83 ec 18             	sub    $0x18,%esp
  801c49:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c4c:	56                   	push   %esi
  801c4d:	e8 26 f1 ff ff       	call   800d78 <fd2data>
  801c52:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801c5a:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	eb 40                	jmp    801ca4 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
  801c69:	eb 40                	jmp    801cab <devpipe_write+0x6b>
  801c6b:	89 da                	mov    %ebx,%edx
  801c6d:	89 f0                	mov    %esi,%eax
  801c6f:	e8 64 ff ff ff       	call   801bd8 <_pipeisclosed>
  801c74:	85 c0                	test   %eax,%eax
  801c76:	75 ec                	jne    801c64 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c78:	e8 6b f0 ff ff       	call   800ce8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c7d:	8b 53 04             	mov    0x4(%ebx),%edx
  801c80:	8b 03                	mov    (%ebx),%eax
  801c82:	83 c0 20             	add    $0x20,%eax
  801c85:	39 c2                	cmp    %eax,%edx
  801c87:	73 e2                	jae    801c6b <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c89:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c8f:	79 05                	jns    801c96 <devpipe_write+0x56>
  801c91:	4a                   	dec    %edx
  801c92:	83 ca e0             	or     $0xffffffe0,%edx
  801c95:	42                   	inc    %edx
  801c96:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801c99:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801c9c:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca0:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca3:	47                   	inc    %edi
  801ca4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca7:	75 d4                	jne    801c7d <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ca9:	89 f8                	mov    %edi,%eax
}
  801cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cae:	5b                   	pop    %ebx
  801caf:	5e                   	pop    %esi
  801cb0:	5f                   	pop    %edi
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	57                   	push   %edi
  801cb7:	56                   	push   %esi
  801cb8:	53                   	push   %ebx
  801cb9:	83 ec 18             	sub    $0x18,%esp
  801cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cbf:	57                   	push   %edi
  801cc0:	e8 b3 f0 ff ff       	call   800d78 <fd2data>
  801cc5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801ccd:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	eb 41                	jmp    801d18 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801cd7:	89 f0                	mov    %esi,%eax
  801cd9:	eb 44                	jmp    801d1f <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce0:	eb 3d                	jmp    801d1f <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce2:	85 f6                	test   %esi,%esi
  801ce4:	75 f1                	jne    801cd7 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ce6:	89 da                	mov    %ebx,%edx
  801ce8:	89 f8                	mov    %edi,%eax
  801cea:	e8 e9 fe ff ff       	call   801bd8 <_pipeisclosed>
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	75 e8                	jne    801cdb <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cf3:	e8 f0 ef ff ff       	call   800ce8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cf8:	8b 03                	mov    (%ebx),%eax
  801cfa:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cfd:	74 e3                	je     801ce2 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cff:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d04:	79 05                	jns    801d0b <devpipe_read+0x58>
  801d06:	48                   	dec    %eax
  801d07:	83 c8 e0             	or     $0xffffffe0,%eax
  801d0a:	40                   	inc    %eax
  801d0b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d12:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801d15:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d17:	46                   	inc    %esi
  801d18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1b:	75 db                	jne    801cf8 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d1d:	89 f0                	mov    %esi,%eax
}
  801d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d30:	50                   	push   %eax
  801d31:	ff 75 08             	pushl  0x8(%ebp)
  801d34:	e8 aa f0 ff ff       	call   800de3 <fd_lookup>
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	78 18                	js     801d58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	ff 75 fc             	pushl  -0x4(%ebp)
  801d46:	e8 2d f0 ff ff       	call   800d78 <fd2data>
  801d4b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d50:	e8 83 fe ff ff       	call   801bd8 <_pipeisclosed>
  801d55:	83 c4 10             	add    $0x10,%esp
}
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	57                   	push   %edi
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	83 ec 28             	sub    $0x28,%esp
  801d63:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	e8 21 f0 ff ff       	call   800d90 <fd_alloc>
  801d6f:	89 c3                	mov    %eax,%ebx
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	0f 88 24 01 00 00    	js     801ea0 <pipe+0x146>
  801d7c:	83 ec 04             	sub    $0x4,%esp
  801d7f:	68 07 04 00 00       	push   $0x407
  801d84:	ff 75 f0             	pushl  -0x10(%ebp)
  801d87:	6a 00                	push   $0x0
  801d89:	e8 17 ef ff ff       	call   800ca5 <sys_page_alloc>
  801d8e:	89 c3                	mov    %eax,%ebx
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	0f 88 05 01 00 00    	js     801ea0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d9b:	83 ec 0c             	sub    $0xc,%esp
  801d9e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	e8 e9 ef ff ff       	call   800d90 <fd_alloc>
  801da7:	89 c3                	mov    %eax,%ebx
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	85 c0                	test   %eax,%eax
  801dae:	0f 88 dc 00 00 00    	js     801e90 <pipe+0x136>
  801db4:	83 ec 04             	sub    $0x4,%esp
  801db7:	68 07 04 00 00       	push   $0x407
  801dbc:	ff 75 ec             	pushl  -0x14(%ebp)
  801dbf:	6a 00                	push   $0x0
  801dc1:	e8 df ee ff ff       	call   800ca5 <sys_page_alloc>
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	0f 88 bd 00 00 00    	js     801e90 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dd3:	83 ec 0c             	sub    $0xc,%esp
  801dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd9:	e8 9a ef ff ff       	call   800d78 <fd2data>
  801dde:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de0:	83 c4 0c             	add    $0xc,%esp
  801de3:	68 07 04 00 00       	push   $0x407
  801de8:	50                   	push   %eax
  801de9:	6a 00                	push   $0x0
  801deb:	e8 b5 ee ff ff       	call   800ca5 <sys_page_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	0f 88 83 00 00 00    	js     801e80 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	ff 75 ec             	pushl  -0x14(%ebp)
  801e03:	e8 70 ef ff ff       	call   800d78 <fd2data>
  801e08:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e0f:	50                   	push   %eax
  801e10:	6a 00                	push   $0x0
  801e12:	56                   	push   %esi
  801e13:	6a 00                	push   $0x0
  801e15:	e8 49 ee ff ff       	call   800c63 <sys_page_map>
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	83 c4 20             	add    $0x20,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 4f                	js     801e72 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e2c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e41:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	ff 75 f0             	pushl  -0x10(%ebp)
  801e53:	e8 10 ef ff ff       	call   800d68 <fd2num>
  801e58:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e5a:	83 c4 04             	add    $0x4,%esp
  801e5d:	ff 75 ec             	pushl  -0x14(%ebp)
  801e60:	e8 03 ef ff ff       	call   800d68 <fd2num>
  801e65:	89 47 04             	mov    %eax,0x4(%edi)
  801e68:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801e6d:	83 c4 10             	add    $0x10,%esp
  801e70:	eb 2e                	jmp    801ea0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	56                   	push   %esi
  801e76:	6a 00                	push   $0x0
  801e78:	e8 a4 ed ff ff       	call   800c21 <sys_page_unmap>
  801e7d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e80:	83 ec 08             	sub    $0x8,%esp
  801e83:	ff 75 ec             	pushl  -0x14(%ebp)
  801e86:	6a 00                	push   $0x0
  801e88:	e8 94 ed ff ff       	call   800c21 <sys_page_unmap>
  801e8d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e90:	83 ec 08             	sub    $0x8,%esp
  801e93:	ff 75 f0             	pushl  -0x10(%ebp)
  801e96:	6a 00                	push   $0x0
  801e98:	e8 84 ed ff ff       	call   800c21 <sys_page_unmap>
  801e9d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ea0:	89 d8                	mov    %ebx,%eax
  801ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    
	...

00801eac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ebc:	68 c5 29 80 00       	push   $0x8029c5
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	e8 c6 e8 ff ff       	call   80078f <strcpy>
	return 0;
}
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	57                   	push   %edi
  801ed4:	56                   	push   %esi
  801ed5:	53                   	push   %ebx
  801ed6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801edc:	be 00 00 00 00       	mov    $0x0,%esi
  801ee1:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801ee7:	eb 2c                	jmp    801f15 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eec:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801eee:	83 fb 7f             	cmp    $0x7f,%ebx
  801ef1:	76 05                	jbe    801ef8 <devcons_write+0x28>
  801ef3:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef8:	83 ec 04             	sub    $0x4,%esp
  801efb:	53                   	push   %ebx
  801efc:	03 45 0c             	add    0xc(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	57                   	push   %edi
  801f01:	e8 f6 e9 ff ff       	call   8008fc <memmove>
		sys_cputs(buf, m);
  801f06:	83 c4 08             	add    $0x8,%esp
  801f09:	53                   	push   %ebx
  801f0a:	57                   	push   %edi
  801f0b:	e8 c3 eb ff ff       	call   800ad3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f10:	01 de                	add    %ebx,%esi
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1a:	72 cd                	jb     801ee9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2d:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f30:	6a 01                	push   $0x1
  801f32:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801f35:	50                   	push   %eax
  801f36:	e8 98 eb ff ff       	call   800ad3 <sys_cputs>
  801f3b:	83 c4 10             	add    $0x10,%esp
}
  801f3e:	c9                   	leave  
  801f3f:	c3                   	ret    

00801f40 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f4a:	74 27                	je     801f73 <devcons_read+0x33>
  801f4c:	eb 05                	jmp    801f53 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f4e:	e8 95 ed ff ff       	call   800ce8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f53:	e8 5c eb ff ff       	call   800ab4 <sys_cgetc>
  801f58:	89 c2                	mov    %eax,%edx
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	74 f0                	je     801f4e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	78 16                	js     801f78 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f62:	83 f8 04             	cmp    $0x4,%eax
  801f65:	74 0c                	je     801f73 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6a:	88 10                	mov    %dl,(%eax)
  801f6c:	ba 01 00 00 00       	mov    $0x1,%edx
  801f71:	eb 05                	jmp    801f78 <devcons_read+0x38>
	return 1;
  801f73:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801f78:	89 d0                	mov    %edx,%eax
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f82:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f85:	50                   	push   %eax
  801f86:	e8 05 ee ff ff       	call   800d90 <fd_alloc>
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 3b                	js     801fcd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	68 07 04 00 00       	push   $0x407
  801f9a:	ff 75 fc             	pushl  -0x4(%ebp)
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 01 ed ff ff       	call   800ca5 <sys_page_alloc>
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 22                	js     801fcd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fab:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801fb0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801fb3:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801fb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fb8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	ff 75 fc             	pushl  -0x4(%ebp)
  801fc5:	e8 9e ed ff ff       	call   800d68 <fd2num>
  801fca:	83 c4 10             	add    $0x10,%esp
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fd5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fd8:	50                   	push   %eax
  801fd9:	ff 75 08             	pushl  0x8(%ebp)
  801fdc:	e8 02 ee ff ff       	call   800de3 <fd_lookup>
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	78 11                	js     801ff9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fe8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801feb:	8b 00                	mov    (%eax),%eax
  801fed:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801ff3:	0f 94 c0             	sete   %al
  801ff6:	0f b6 c0             	movzbl %al,%eax
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802001:	6a 01                	push   $0x1
  802003:	8d 45 ff             	lea    -0x1(%ebp),%eax
  802006:	50                   	push   %eax
  802007:	6a 00                	push   $0x0
  802009:	e8 14 f0 ff ff       	call   801022 <read>
	if (r < 0)
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	78 0f                	js     802024 <getchar+0x29>
		return r;
	if (r < 1)
  802015:	85 c0                	test   %eax,%eax
  802017:	75 07                	jne    802020 <getchar+0x25>
  802019:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80201e:	eb 04                	jmp    802024 <getchar+0x29>
		return -E_EOF;
	return c;
  802020:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  802024:	c9                   	leave  
  802025:	c3                   	ret    
	...

00802028 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	53                   	push   %ebx
  80202c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80202f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802034:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  80203b:	89 c8                	mov    %ecx,%eax
  80203d:	c1 e0 07             	shl    $0x7,%eax
  802040:	29 d0                	sub    %edx,%eax
  802042:	89 c2                	mov    %eax,%edx
  802044:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  80204a:	8b 40 50             	mov    0x50(%eax),%eax
  80204d:	39 d8                	cmp    %ebx,%eax
  80204f:	75 0b                	jne    80205c <ipc_find_env+0x34>
			return envs[i].env_id;
  802051:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  802057:	8b 40 40             	mov    0x40(%eax),%eax
  80205a:	eb 0e                	jmp    80206a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205c:	41                   	inc    %ecx
  80205d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  802063:	75 cf                	jne    802034 <ipc_find_env+0xc>
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80206a:	5b                   	pop    %ebx
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    

0080206d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	57                   	push   %edi
  802071:	56                   	push   %esi
  802072:	53                   	push   %ebx
  802073:	83 ec 0c             	sub    $0xc,%esp
  802076:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802079:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80207c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80207f:	85 db                	test   %ebx,%ebx
  802081:	75 05                	jne    802088 <ipc_send+0x1b>
  802083:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802088:	56                   	push   %esi
  802089:	53                   	push   %ebx
  80208a:	57                   	push   %edi
  80208b:	ff 75 08             	pushl  0x8(%ebp)
  80208e:	e8 a5 ea ff ff       	call   800b38 <sys_ipc_try_send>
		if (r == 0) {		//success
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	85 c0                	test   %eax,%eax
  802098:	74 20                	je     8020ba <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80209a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80209d:	75 07                	jne    8020a6 <ipc_send+0x39>
			sys_yield();
  80209f:	e8 44 ec ff ff       	call   800ce8 <sys_yield>
  8020a4:	eb e2                	jmp    802088 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  8020a6:	83 ec 04             	sub    $0x4,%esp
  8020a9:	68 d4 29 80 00       	push   $0x8029d4
  8020ae:	6a 41                	push   $0x41
  8020b0:	68 f8 29 80 00       	push   $0x8029f8
  8020b5:	e8 e2 e0 ff ff       	call   80019c <_panic>
		}
	}
}
  8020ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
  8020c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	75 05                	jne    8020d9 <ipc_recv+0x17>
  8020d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  8020d9:	83 ec 0c             	sub    $0xc,%esp
  8020dc:	50                   	push   %eax
  8020dd:	e8 15 ea ff ff       	call   800af7 <sys_ipc_recv>
	if (r < 0) {				
  8020e2:	83 c4 10             	add    $0x10,%esp
  8020e5:	85 c0                	test   %eax,%eax
  8020e7:	79 16                	jns    8020ff <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  8020e9:	85 db                	test   %ebx,%ebx
  8020eb:	74 06                	je     8020f3 <ipc_recv+0x31>
  8020ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8020f3:	85 f6                	test   %esi,%esi
  8020f5:	74 2c                	je     802123 <ipc_recv+0x61>
  8020f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020fd:	eb 24                	jmp    802123 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8020ff:	85 db                	test   %ebx,%ebx
  802101:	74 0a                	je     80210d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802103:	a1 04 40 80 00       	mov    0x804004,%eax
  802108:	8b 40 74             	mov    0x74(%eax),%eax
  80210b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  80210d:	85 f6                	test   %esi,%esi
  80210f:	74 0a                	je     80211b <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802111:	a1 04 40 80 00       	mov    0x804004,%eax
  802116:	8b 40 78             	mov    0x78(%eax),%eax
  802119:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80211b:	a1 04 40 80 00       	mov    0x804004,%eax
  802120:	8b 40 70             	mov    0x70(%eax),%eax
}
  802123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802126:	5b                   	pop    %ebx
  802127:	5e                   	pop    %esi
  802128:	c9                   	leave  
  802129:	c3                   	ret    
	...

0080212c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80212c:	55                   	push   %ebp
  80212d:	89 e5                	mov    %esp,%ebp
  80212f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802132:	89 d0                	mov    %edx,%eax
  802134:	c1 e8 16             	shr    $0x16,%eax
  802137:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80213e:	a8 01                	test   $0x1,%al
  802140:	74 20                	je     802162 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802142:	89 d0                	mov    %edx,%eax
  802144:	c1 e8 0c             	shr    $0xc,%eax
  802147:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80214e:	a8 01                	test   $0x1,%al
  802150:	74 10                	je     802162 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802152:	c1 e8 0c             	shr    $0xc,%eax
  802155:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80215c:	ef 
  80215d:	0f b7 c0             	movzwl %ax,%eax
  802160:	eb 05                	jmp    802167 <pageref+0x3b>
  802162:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802167:	c9                   	leave  
  802168:	c3                   	ret    
  802169:	00 00                	add    %al,(%eax)
	...

0080216c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	57                   	push   %edi
  802170:	56                   	push   %esi
  802171:	83 ec 28             	sub    $0x28,%esp
  802174:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80217b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802182:	8b 45 10             	mov    0x10(%ebp),%eax
  802185:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802188:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80218b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80218d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
  802192:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  802195:	8b 55 0c             	mov    0xc(%ebp),%edx
  802198:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80219b:	85 ff                	test   %edi,%edi
  80219d:	75 21                	jne    8021c0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  80219f:	39 d1                	cmp    %edx,%ecx
  8021a1:	76 49                	jbe    8021ec <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a3:	f7 f1                	div    %ecx
  8021a5:	89 c1                	mov    %eax,%ecx
  8021a7:	31 c0                	xor    %eax,%eax
  8021a9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021ac:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8021af:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8021b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8021b8:	83 c4 28             	add    $0x28,%esp
  8021bb:	5e                   	pop    %esi
  8021bc:	5f                   	pop    %edi
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    
  8021bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021c0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8021c3:	0f 87 97 00 00 00    	ja     802260 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021c9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8021cc:	83 f0 1f             	xor    $0x1f,%eax
  8021cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021d2:	75 34                	jne    802208 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021d4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8021d7:	72 08                	jb     8021e1 <__udivdi3+0x75>
  8021d9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8021dc:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8021df:	77 7f                	ja     802260 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021e1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021e6:	31 c0                	xor    %eax,%eax
  8021e8:	eb c2                	jmp    8021ac <__udivdi3+0x40>
  8021ea:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	74 79                	je     80226c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8021f6:	89 fa                	mov    %edi,%edx
  8021f8:	f7 f1                	div    %ecx
  8021fa:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021ff:	f7 f1                	div    %ecx
  802201:	89 c1                	mov    %eax,%ecx
  802203:	89 f0                	mov    %esi,%eax
  802205:	eb a5                	jmp    8021ac <__udivdi3+0x40>
  802207:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802208:	b8 20 00 00 00       	mov    $0x20,%eax
  80220d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802210:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802213:	89 fa                	mov    %edi,%edx
  802215:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802218:	d3 e2                	shl    %cl,%edx
  80221a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802220:	d3 e8                	shr    %cl,%eax
  802222:	89 d7                	mov    %edx,%edi
  802224:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802226:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802229:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80222c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80222e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802231:	d3 e0                	shl    %cl,%eax
  802233:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802236:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802239:	d3 ea                	shr    %cl,%edx
  80223b:	09 d0                	or     %edx,%eax
  80223d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802240:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802243:	d3 ea                	shr    %cl,%edx
  802245:	f7 f7                	div    %edi
  802247:	89 d7                	mov    %edx,%edi
  802249:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  80224c:	f7 e6                	mul    %esi
  80224e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802250:	39 d7                	cmp    %edx,%edi
  802252:	72 38                	jb     80228c <__udivdi3+0x120>
  802254:	74 27                	je     80227d <__udivdi3+0x111>
  802256:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802259:	31 c0                	xor    %eax,%eax
  80225b:	e9 4c ff ff ff       	jmp    8021ac <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802260:	31 c9                	xor    %ecx,%ecx
  802262:	31 c0                	xor    %eax,%eax
  802264:	e9 43 ff ff ff       	jmp    8021ac <__udivdi3+0x40>
  802269:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80226c:	b8 01 00 00 00       	mov    $0x1,%eax
  802271:	31 d2                	xor    %edx,%edx
  802273:	f7 75 f4             	divl   -0xc(%ebp)
  802276:	89 c1                	mov    %eax,%ecx
  802278:	e9 76 ff ff ff       	jmp    8021f3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80227d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802280:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802283:	d3 e0                	shl    %cl,%eax
  802285:	39 f0                	cmp    %esi,%eax
  802287:	73 cd                	jae    802256 <__udivdi3+0xea>
  802289:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80228c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80228f:	49                   	dec    %ecx
  802290:	31 c0                	xor    %eax,%eax
  802292:	e9 15 ff ff ff       	jmp    8021ac <__udivdi3+0x40>
	...

00802298 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	57                   	push   %edi
  80229c:	56                   	push   %esi
  80229d:	83 ec 30             	sub    $0x30,%esp
  8022a0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8022a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8022b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8022ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022bd:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8022bf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8022c2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8022c5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022c8:	85 d2                	test   %edx,%edx
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8022cc:	89 fa                	mov    %edi,%edx
  8022ce:	39 f8                	cmp    %edi,%eax
  8022d0:	0f 86 c2 00 00 00    	jbe    802398 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d6:	89 f0                	mov    %esi,%eax
  8022d8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8022da:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8022dd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8022e4:	eb 12                	jmp    8022f8 <__umoddi3+0x60>
  8022e6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022eb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8022ee:	76 18                	jbe    802308 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8022f0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8022f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8022f6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8022fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8022fe:	83 c4 30             	add    $0x30,%esp
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	c9                   	leave  
  802304:	c3                   	ret    
  802305:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802308:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  80230c:	83 f0 1f             	xor    $0x1f,%eax
  80230f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802312:	0f 84 ac 00 00 00    	je     8023c4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802318:	b8 20 00 00 00       	mov    $0x20,%eax
  80231d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802323:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802326:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802329:	d3 e2                	shl    %cl,%edx
  80232b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80232e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802331:	d3 e8                	shr    %cl,%eax
  802333:	89 d6                	mov    %edx,%esi
  802335:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  802337:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80233a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80233d:	d3 e0                	shl    %cl,%eax
  80233f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802342:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802345:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80234a:	d3 e0                	shl    %cl,%eax
  80234c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80234f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802352:	d3 ea                	shr    %cl,%edx
  802354:	09 d0                	or     %edx,%eax
  802356:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802359:	d3 ea                	shr    %cl,%edx
  80235b:	f7 f6                	div    %esi
  80235d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802360:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802363:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  802366:	0f 82 8d 00 00 00    	jb     8023f9 <__umoddi3+0x161>
  80236c:	0f 84 91 00 00 00    	je     802403 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802372:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802375:	29 c7                	sub    %eax,%edi
  802377:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802379:	89 f2                	mov    %esi,%edx
  80237b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80237e:	d3 e2                	shl    %cl,%edx
  802380:	89 f8                	mov    %edi,%eax
  802382:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802385:	d3 e8                	shr    %cl,%eax
  802387:	09 c2                	or     %eax,%edx
  802389:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  80238c:	d3 ee                	shr    %cl,%esi
  80238e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  802391:	e9 62 ff ff ff       	jmp    8022f8 <__umoddi3+0x60>
  802396:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802398:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80239b:	85 c0                	test   %eax,%eax
  80239d:	74 15                	je     8023b4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80239f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8023a5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023aa:	f7 f1                	div    %ecx
  8023ac:	e9 29 ff ff ff       	jmp    8022da <__umoddi3+0x42>
  8023b1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b9:	31 d2                	xor    %edx,%edx
  8023bb:	f7 75 ec             	divl   -0x14(%ebp)
  8023be:	89 c1                	mov    %eax,%ecx
  8023c0:	eb dd                	jmp    80239f <__umoddi3+0x107>
  8023c2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8023ca:	72 19                	jb     8023e5 <__umoddi3+0x14d>
  8023cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023cf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8023d2:	76 11                	jbe    8023e5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8023d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023d7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8023da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8023dd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8023e0:	e9 13 ff ff ff       	jmp    8022f8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8023e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023eb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8023ee:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8023f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8023f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8023f7:	eb db                	jmp    8023d4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023f9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8023fc:	19 f2                	sbb    %esi,%edx
  8023fe:	e9 6f ff ff ff       	jmp    802372 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802403:	39 c7                	cmp    %eax,%edi
  802405:	72 f2                	jb     8023f9 <__umoddi3+0x161>
  802407:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80240a:	e9 63 ff ff ff       	jmp    802372 <__umoddi3+0xda>
