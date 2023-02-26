
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	6a 00                	push   $0x0
  80003f:	68 60 22 80 00       	push   $0x802260
  800044:	e8 d2 17 00 00       	call   80181b <open>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <umain+0x30>
		panic("open motd: %e", fd);
  800052:	50                   	push   %eax
  800053:	68 65 22 80 00       	push   $0x802265
  800058:	6a 0c                	push   $0xc
  80005a:	68 73 22 80 00       	push   $0x802273
  80005f:	e8 bc 01 00 00       	call   800220 <_panic>
	seek(fd, 0);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	6a 00                	push   $0x0
  800069:	50                   	push   %eax
  80006a:	e8 d7 10 00 00       	call   801146 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	68 00 02 00 00       	push   $0x200
  800077:	68 20 42 80 00       	push   $0x804220
  80007c:	53                   	push   %ebx
  80007d:	e8 43 13 00 00       	call   8013c5 <readn>
  800082:	89 c6                	mov    %eax,%esi
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	85 c0                	test   %eax,%eax
  800089:	7f 12                	jg     80009d <umain+0x69>
		panic("readn: %e", n);
  80008b:	50                   	push   %eax
  80008c:	68 88 22 80 00       	push   $0x802288
  800091:	6a 0f                	push   $0xf
  800093:	68 73 22 80 00       	push   $0x802273
  800098:	e8 83 01 00 00       	call   800220 <_panic>

	if ((r = fork()) < 0)
  80009d:	e8 64 0d 00 00       	call   800e06 <fork>
  8000a2:	89 c7                	mov    %eax,%edi
  8000a4:	85 c0                	test   %eax,%eax
  8000a6:	79 12                	jns    8000ba <umain+0x86>
		panic("fork: %e", r);
  8000a8:	50                   	push   %eax
  8000a9:	68 92 22 80 00       	push   $0x802292
  8000ae:	6a 12                	push   $0x12
  8000b0:	68 73 22 80 00       	push   $0x802273
  8000b5:	e8 66 01 00 00       	call   800220 <_panic>
	if (r == 0) {
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	0f 85 9d 00 00 00    	jne    80015f <umain+0x12b>
		seek(fd, 0);
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	53                   	push   %ebx
  8000c8:	e8 79 10 00 00       	call   801146 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cd:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  8000d4:	e8 e8 01 00 00       	call   8002c1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d9:	83 c4 0c             	add    $0xc,%esp
  8000dc:	68 00 02 00 00       	push   $0x200
  8000e1:	68 20 40 80 00       	push   $0x804020
  8000e6:	53                   	push   %ebx
  8000e7:	e8 d9 12 00 00       	call   8013c5 <readn>
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	39 c6                	cmp    %eax,%esi
  8000f1:	74 16                	je     800109 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	56                   	push   %esi
  8000f8:	68 14 23 80 00       	push   $0x802314
  8000fd:	6a 17                	push   $0x17
  8000ff:	68 73 22 80 00       	push   $0x802273
  800104:	e8 17 01 00 00       	call   800220 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800109:	83 ec 04             	sub    $0x4,%esp
  80010c:	56                   	push   %esi
  80010d:	68 20 40 80 00       	push   $0x804020
  800112:	68 20 42 80 00       	push   $0x804220
  800117:	e8 e5 08 00 00       	call   800a01 <memcmp>
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	85 c0                	test   %eax,%eax
  800121:	74 14                	je     800137 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	68 40 23 80 00       	push   $0x802340
  80012b:	6a 19                	push   $0x19
  80012d:	68 73 22 80 00       	push   $0x802273
  800132:	e8 e9 00 00 00       	call   800220 <_panic>
		cprintf("read in child succeeded\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 9b 22 80 00       	push   $0x80229b
  80013f:	e8 7d 01 00 00       	call   8002c1 <cprintf>
		seek(fd, 0);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	6a 00                	push   $0x0
  800149:	53                   	push   %ebx
  80014a:	e8 f7 0f 00 00       	call   801146 <seek>
		close(fd);
  80014f:	89 1c 24             	mov    %ebx,(%esp)
  800152:	e8 3d 13 00 00       	call   801494 <close>
		exit();
  800157:	e8 b0 00 00 00       	call   80020c <exit>
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	57                   	push   %edi
  800163:	e8 90 1a 00 00       	call   801bf8 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800168:	83 c4 0c             	add    $0xc,%esp
  80016b:	68 00 02 00 00       	push   $0x200
  800170:	68 20 40 80 00       	push   $0x804020
  800175:	53                   	push   %ebx
  800176:	e8 4a 12 00 00       	call   8013c5 <readn>
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	39 c6                	cmp    %eax,%esi
  800180:	74 16                	je     800198 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	56                   	push   %esi
  800187:	68 78 23 80 00       	push   $0x802378
  80018c:	6a 21                	push   $0x21
  80018e:	68 73 22 80 00       	push   $0x802273
  800193:	e8 88 00 00 00       	call   800220 <_panic>
	cprintf("read in parent succeeded\n");
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	68 b4 22 80 00       	push   $0x8022b4
  8001a0:	e8 1c 01 00 00       	call   8002c1 <cprintf>
	close(fd);
  8001a5:	89 1c 24             	mov    %ebx,(%esp)
  8001a8:	e8 e7 12 00 00       	call   801494 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8001b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5e                   	pop    %esi
  8001b6:	5f                   	pop    %edi
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8001c7:	e8 bf 0b 00 00       	call   800d8b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001d8:	c1 e0 07             	shl    $0x7,%eax
  8001db:	29 d0                	sub    %edx,%eax
  8001dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e2:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e7:	85 f6                	test   %esi,%esi
  8001e9:	7e 07                	jle    8001f2 <libmain+0x36>
		binaryname = argv[0];
  8001eb:	8b 03                	mov    (%ebx),%eax
  8001ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	53                   	push   %ebx
  8001f6:	56                   	push   %esi
  8001f7:	e8 38 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001fc:	e8 0b 00 00 00       	call   80020c <exit>
  800201:	83 c4 10             	add    $0x10,%esp
}
  800204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	c9                   	leave  
  80020a:	c3                   	ret    
	...

0080020c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800212:	6a 00                	push   $0x0
  800214:	e8 91 0b 00 00       	call   800daa <sys_env_destroy>
  800219:	83 c4 10             	add    $0x10,%esp
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    
	...

00800220 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 45 14             	lea    0x14(%ebp),%eax
  80022a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022d:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800233:	e8 53 0b 00 00       	call   800d8b <sys_getenvid>
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	68 a8 23 80 00       	push   $0x8023a8
  800248:	e8 74 00 00 00       	call   8002c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024d:	83 c4 18             	add    $0x18,%esp
  800250:	ff 75 f8             	pushl  -0x8(%ebp)
  800253:	ff 75 10             	pushl  0x10(%ebp)
  800256:	e8 15 00 00 00       	call   800270 <vcprintf>
	cprintf("\n");
  80025b:	c7 04 24 b2 22 80 00 	movl   $0x8022b2,(%esp)
  800262:	e8 5a 00 00 00       	call   8002c1 <cprintf>
  800267:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026a:	cc                   	int3   
  80026b:	eb fd                	jmp    80026a <_panic+0x4a>
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800279:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800280:	00 00 00 
	b.cnt = 0;
  800283:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80028a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028d:	ff 75 0c             	pushl  0xc(%ebp)
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800299:	50                   	push   %eax
  80029a:	68 d8 02 80 00       	push   $0x8002d8
  80029f:	e8 70 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a4:	83 c4 08             	add    $0x8,%esp
  8002a7:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8002ad:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002b3:	50                   	push   %eax
  8002b4:	e8 9e 08 00 00       	call   800b57 <sys_cputs>
  8002b9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    

008002c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8002cd:	50                   	push   %eax
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 9a ff ff ff       	call   800270 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 04             	sub    $0x4,%esp
  8002df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e2:	8b 03                	mov    (%ebx),%eax
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002eb:	40                   	inc    %eax
  8002ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f3:	75 1a                	jne    80030f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002f5:	83 ec 08             	sub    $0x8,%esp
  8002f8:	68 ff 00 00 00       	push   $0xff
  8002fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800300:	50                   	push   %eax
  800301:	e8 51 08 00 00       	call   800b57 <sys_cputs>
		b->idx = 0;
  800306:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80030c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80030f:	ff 43 04             	incl   0x4(%ebx)
}
  800312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800315:	c9                   	leave  
  800316:	c3                   	ret    
	...

00800318 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 1c             	sub    $0x1c,%esp
  800321:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800324:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800330:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800333:	8b 55 10             	mov    0x10(%ebp),%edx
  800336:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800339:	89 d6                	mov    %edx,%esi
  80033b:	bf 00 00 00 00       	mov    $0x0,%edi
  800340:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800343:	72 04                	jb     800349 <printnum+0x31>
  800345:	39 c2                	cmp    %eax,%edx
  800347:	77 3f                	ja     800388 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 18             	pushl  0x18(%ebp)
  80034f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800352:	50                   	push   %eax
  800353:	52                   	push   %edx
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035c:	ff 75 e0             	pushl  -0x20(%ebp)
  80035f:	e8 54 1c 00 00       	call   801fb8 <__udivdi3>
  800364:	83 c4 18             	add    $0x18,%esp
  800367:	52                   	push   %edx
  800368:	50                   	push   %eax
  800369:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80036c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80036f:	e8 a4 ff ff ff       	call   800318 <printnum>
  800374:	83 c4 20             	add    $0x20,%esp
  800377:	eb 14                	jmp    80038d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	ff 75 e8             	pushl  -0x18(%ebp)
  80037f:	ff 75 18             	pushl  0x18(%ebp)
  800382:	ff 55 ec             	call   *-0x14(%ebp)
  800385:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800388:	4b                   	dec    %ebx
  800389:	85 db                	test   %ebx,%ebx
  80038b:	7f ec                	jg     800379 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	ff 75 e8             	pushl  -0x18(%ebp)
  800393:	83 ec 04             	sub    $0x4,%esp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039b:	ff 75 e0             	pushl  -0x20(%ebp)
  80039e:	e8 41 1d 00 00       	call   8020e4 <__umoddi3>
  8003a3:	83 c4 14             	add    $0x14,%esp
  8003a6:	0f be 80 cb 23 80 00 	movsbl 0x8023cb(%eax),%eax
  8003ad:	50                   	push   %eax
  8003ae:	ff 55 ec             	call   *-0x14(%ebp)
  8003b1:	83 c4 10             	add    $0x10,%esp
}
  8003b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003c1:	83 fa 01             	cmp    $0x1,%edx
  8003c4:	7e 0e                	jle    8003d4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 42 08             	lea    0x8(%edx),%eax
  8003cb:	89 01                	mov    %eax,(%ecx)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	8b 52 04             	mov    0x4(%edx),%edx
  8003d2:	eb 22                	jmp    8003f6 <getuint+0x3a>
	else if (lflag)
  8003d4:	85 d2                	test   %edx,%edx
  8003d6:	74 10                	je     8003e8 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003d8:	8b 10                	mov    (%eax),%edx
  8003da:	8d 42 04             	lea    0x4(%edx),%eax
  8003dd:	89 01                	mov    %eax,(%ecx)
  8003df:	8b 02                	mov    (%edx),%eax
  8003e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e6:	eb 0e                	jmp    8003f6 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 42 04             	lea    0x4(%edx),%eax
  8003ed:	89 01                	mov    %eax,(%ecx)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8003fe:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800401:	8b 11                	mov    (%ecx),%edx
  800403:	3b 51 04             	cmp    0x4(%ecx),%edx
  800406:	73 0a                	jae    800412 <sprintputch+0x1a>
		*b->buf++ = ch;
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
  80040b:	88 02                	mov    %al,(%edx)
  80040d:	8d 42 01             	lea    0x1(%edx),%eax
  800410:	89 01                	mov    %eax,(%ecx)
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 3c             	sub    $0x3c,%esp
  80041d:	8b 75 08             	mov    0x8(%ebp),%esi
  800420:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800423:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800426:	eb 1a                	jmp    800442 <vprintfmt+0x2e>
  800428:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80042b:	eb 15                	jmp    800442 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042d:	84 c0                	test   %al,%al
  80042f:	0f 84 15 03 00 00    	je     80074a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	57                   	push   %edi
  800439:	0f b6 c0             	movzbl %al,%eax
  80043c:	50                   	push   %eax
  80043d:	ff d6                	call   *%esi
  80043f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800442:	8a 03                	mov    (%ebx),%al
  800444:	43                   	inc    %ebx
  800445:	3c 25                	cmp    $0x25,%al
  800447:	75 e4                	jne    80042d <vprintfmt+0x19>
  800449:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800450:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800457:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80045e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800465:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800469:	eb 0a                	jmp    800475 <vprintfmt+0x61>
  80046b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800472:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8a 03                	mov    (%ebx),%al
  800477:	0f b6 d0             	movzbl %al,%edx
  80047a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  80047d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800480:	83 e8 23             	sub    $0x23,%eax
  800483:	3c 55                	cmp    $0x55,%al
  800485:	0f 87 9c 02 00 00    	ja     800727 <vprintfmt+0x313>
  80048b:	0f b6 c0             	movzbl %al,%eax
  80048e:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  800495:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800499:	eb d7                	jmp    800472 <vprintfmt+0x5e>
  80049b:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80049f:	eb d1                	jmp    800472 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8004a1:	89 d9                	mov    %ebx,%ecx
  8004a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004aa:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004ad:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004b0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8004b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8004b7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8004bb:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8004bc:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004bf:	83 f8 09             	cmp    $0x9,%eax
  8004c2:	77 21                	ja     8004e5 <vprintfmt+0xd1>
  8004c4:	eb e4                	jmp    8004aa <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c6:	8b 55 14             	mov    0x14(%ebp),%edx
  8004c9:	8d 42 04             	lea    0x4(%edx),%eax
  8004cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cf:	8b 12                	mov    (%edx),%edx
  8004d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d4:	eb 12                	jmp    8004e8 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8004d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004da:	79 96                	jns    800472 <vprintfmt+0x5e>
  8004dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e3:	eb 8d                	jmp    800472 <vprintfmt+0x5e>
  8004e5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ec:	79 84                	jns    800472 <vprintfmt+0x5e>
  8004ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004fb:	e9 72 ff ff ff       	jmp    800472 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800500:	ff 45 d4             	incl   -0x2c(%ebp)
  800503:	e9 6a ff ff ff       	jmp    800472 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800508:	8b 55 14             	mov    0x14(%ebp),%edx
  80050b:	8d 42 04             	lea    0x4(%edx),%eax
  80050e:	89 45 14             	mov    %eax,0x14(%ebp)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	57                   	push   %edi
  800515:	ff 32                	pushl  (%edx)
  800517:	ff d6                	call   *%esi
			break;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	e9 07 ff ff ff       	jmp    800428 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800521:	8b 55 14             	mov    0x14(%ebp),%edx
  800524:	8d 42 04             	lea    0x4(%edx),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
  80052a:	8b 02                	mov    (%edx),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	79 02                	jns    800532 <vprintfmt+0x11e>
  800530:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800532:	83 f8 0f             	cmp    $0xf,%eax
  800535:	7f 0b                	jg     800542 <vprintfmt+0x12e>
  800537:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	75 15                	jne    800557 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800542:	50                   	push   %eax
  800543:	68 dc 23 80 00       	push   $0x8023dc
  800548:	57                   	push   %edi
  800549:	56                   	push   %esi
  80054a:	e8 6e 02 00 00       	call   8007bd <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	e9 d1 fe ff ff       	jmp    800428 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800557:	52                   	push   %edx
  800558:	68 d5 28 80 00       	push   $0x8028d5
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	e8 59 02 00 00       	call   8007bd <printfmt>
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	e9 bc fe ff ff       	jmp    800428 <vprintfmt+0x14>
  80056c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800572:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800575:	8b 55 14             	mov    0x14(%ebp),%edx
  800578:	8d 42 04             	lea    0x4(%edx),%eax
  80057b:	89 45 14             	mov    %eax,0x14(%ebp)
  80057e:	8b 1a                	mov    (%edx),%ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	75 05                	jne    800589 <vprintfmt+0x175>
  800584:	bb e5 23 80 00       	mov    $0x8023e5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800589:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80058d:	7e 66                	jle    8005f5 <vprintfmt+0x1e1>
  80058f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800593:	74 60                	je     8005f5 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	51                   	push   %ecx
  800599:	53                   	push   %ebx
  80059a:	e8 57 02 00 00       	call   8007f6 <strnlen>
  80059f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005a2:	29 c1                	sub    %eax,%ecx
  8005a4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005b1:	eb 0f                	jmp    8005c2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	57                   	push   %edi
  8005b7:	ff 75 c4             	pushl  -0x3c(%ebp)
  8005ba:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bc:	ff 4d d8             	decl   -0x28(%ebp)
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c6:	7f eb                	jg     8005b3 <vprintfmt+0x19f>
  8005c8:	eb 2b                	jmp    8005f5 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	74 15                	je     8005e8 <vprintfmt+0x1d4>
  8005d3:	8d 42 e0             	lea    -0x20(%edx),%eax
  8005d6:	83 f8 5e             	cmp    $0x5e,%eax
  8005d9:	76 0d                	jbe    8005e8 <vprintfmt+0x1d4>
					putch('?', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	eb 0a                	jmp    8005f2 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	57                   	push   %edi
  8005ec:	52                   	push   %edx
  8005ed:	ff d6                	call   *%esi
  8005ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f2:	ff 4d d8             	decl   -0x28(%ebp)
  8005f5:	8a 03                	mov    (%ebx),%al
  8005f7:	43                   	inc    %ebx
  8005f8:	84 c0                	test   %al,%al
  8005fa:	74 1b                	je     800617 <vprintfmt+0x203>
  8005fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800600:	78 c8                	js     8005ca <vprintfmt+0x1b6>
  800602:	ff 4d dc             	decl   -0x24(%ebp)
  800605:	79 c3                	jns    8005ca <vprintfmt+0x1b6>
  800607:	eb 0e                	jmp    800617 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	57                   	push   %edi
  80060d:	6a 20                	push   $0x20
  80060f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800611:	ff 4d d8             	decl   -0x28(%ebp)
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061b:	7f ec                	jg     800609 <vprintfmt+0x1f5>
  80061d:	e9 06 fe ff ff       	jmp    800428 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800622:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800626:	7e 10                	jle    800638 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800628:	8b 55 14             	mov    0x14(%ebp),%edx
  80062b:	8d 42 08             	lea    0x8(%edx),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
  800631:	8b 02                	mov    (%edx),%eax
  800633:	8b 52 04             	mov    0x4(%edx),%edx
  800636:	eb 20                	jmp    800658 <vprintfmt+0x244>
	else if (lflag)
  800638:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063c:	74 0e                	je     80064c <vprintfmt+0x238>
		return va_arg(*ap, long);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	99                   	cltd   
  80064a:	eb 0c                	jmp    800658 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800658:	89 d1                	mov    %edx,%ecx
  80065a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  80065c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80065f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	78 0a                	js     800670 <vprintfmt+0x25c>
  800666:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80066b:	e9 89 00 00 00       	jmp    8006f9 <vprintfmt+0x2e5>
				putch('-', putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	57                   	push   %edi
  800674:	6a 2d                	push   $0x2d
  800676:	ff d6                	call   *%esi
				num = -(long long) num;
  800678:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80067b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80067e:	f7 da                	neg    %edx
  800680:	83 d1 00             	adc    $0x0,%ecx
  800683:	f7 d9                	neg    %ecx
  800685:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 6a                	jmp    8006f9 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800695:	e8 22 fd ff ff       	call   8003bc <getuint>
  80069a:	89 d1                	mov    %edx,%ecx
  80069c:	89 c2                	mov    %eax,%edx
  80069e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006a3:	eb 54                	jmp    8006f9 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ab:	e8 0c fd ff ff       	call   8003bc <getuint>
  8006b0:	89 d1                	mov    %edx,%ecx
  8006b2:	89 c2                	mov    %eax,%edx
  8006b4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8006b9:	eb 3e                	jmp    8006f9 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	57                   	push   %edi
  8006bf:	6a 30                	push   $0x30
  8006c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	57                   	push   %edi
  8006c7:	6a 78                	push   $0x78
  8006c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ce:	8d 42 04             	lea    0x4(%edx),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d4:	8b 12                	mov    (%edx),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb 14                	jmp    8006f9 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006eb:	e8 cc fc ff ff       	call   8003bc <getuint>
  8006f0:	89 d1                	mov    %edx,%ecx
  8006f2:	89 c2                	mov    %eax,%edx
  8006f4:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800700:	50                   	push   %eax
  800701:	ff 75 d8             	pushl  -0x28(%ebp)
  800704:	53                   	push   %ebx
  800705:	51                   	push   %ecx
  800706:	52                   	push   %edx
  800707:	89 fa                	mov    %edi,%edx
  800709:	89 f0                	mov    %esi,%eax
  80070b:	e8 08 fc ff ff       	call   800318 <printnum>
			break;
  800710:	83 c4 20             	add    $0x20,%esp
  800713:	e9 10 fd ff ff       	jmp    800428 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	57                   	push   %edi
  80071c:	52                   	push   %edx
  80071d:	ff d6                	call   *%esi
			break;
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	e9 01 fd ff ff       	jmp    800428 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	57                   	push   %edi
  80072b:	6a 25                	push   $0x25
  80072d:	ff d6                	call   *%esi
  80072f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800732:	83 ea 02             	sub    $0x2,%edx
  800735:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	8a 02                	mov    (%edx),%al
  80073a:	4a                   	dec    %edx
  80073b:	3c 25                	cmp    $0x25,%al
  80073d:	75 f9                	jne    800738 <vprintfmt+0x324>
  80073f:	83 c2 02             	add    $0x2,%edx
  800742:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800745:	e9 de fc ff ff       	jmp    800428 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 18             	sub    $0x18,%esp
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80075e:	85 d2                	test   %edx,%edx
  800760:	74 37                	je     800799 <vsnprintf+0x47>
  800762:	85 c0                	test   %eax,%eax
  800764:	7e 33                	jle    800799 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80076d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800771:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800774:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	ff 75 14             	pushl  0x14(%ebp)
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	68 f8 03 80 00       	push   $0x8003f8
  800786:	e8 89 fc ff ff       	call   800414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800791:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	eb 05                	jmp    80079e <vsnprintf+0x4c>
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007ac:	50                   	push   %eax
  8007ad:	ff 75 10             	pushl  0x10(%ebp)
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 97 ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 10             	pushl  0x10(%ebp)
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	ff 75 08             	pushl  0x8(%ebp)
  8007d3:	e8 3c fc ff ff       	call   800414 <vprintfmt>
	va_end(ap);
  8007d8:	83 c4 10             	add    $0x10,%esp
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 01                	jmp    8007ee <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8007ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007f2:	75 f9                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	eb 01                	jmp    800807 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800806:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 d0                	cmp    %edx,%eax
  800809:	74 06                	je     800811 <strnlen+0x1b>
  80080b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80080f:	75 f5                	jne    800806 <strnlen+0x10>
		n++;
	return n;
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081c:	8a 01                	mov    (%ecx),%al
  80081e:	88 02                	mov    %al,(%edx)
  800820:	42                   	inc    %edx
  800821:	41                   	inc    %ecx
  800822:	84 c0                	test   %al,%al
  800824:	75 f6                	jne    80081c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	53                   	push   %ebx
  800833:	e8 a8 ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800838:	ff 75 0c             	pushl  0xc(%ebp)
  80083b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80083e:	50                   	push   %eax
  80083f:	e8 cf ff ff ff       	call   800813 <strcpy>
	return dst;
}
  800844:	89 d8                	mov    %ebx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
  800856:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	eb 0c                	jmp    80086c <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800860:	8a 02                	mov    (%edx),%al
  800862:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 3a 01             	cmpb   $0x1,(%edx)
  800868:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086b:	41                   	inc    %ecx
  80086c:	39 d9                	cmp    %ebx,%ecx
  80086e:	75 f0                	jne    800860 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 c9                	test   %ecx,%ecx
  800886:	75 04                	jne    80088c <strlcpy+0x16>
  800888:	89 f0                	mov    %esi,%eax
  80088a:	eb 14                	jmp    8008a0 <strlcpy+0x2a>
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	eb 04                	jmp    800894 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	88 10                	mov    %dl,(%eax)
  800892:	40                   	inc    %eax
  800893:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800894:	49                   	dec    %ecx
  800895:	74 06                	je     80089d <strlcpy+0x27>
  800897:	8a 13                	mov    (%ebx),%dl
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f3                	jne    800890 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80089d:	c6 00 00             	movb   $0x0,(%eax)
  8008a0:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	eb 02                	jmp    8008b3 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8008b1:	42                   	inc    %edx
  8008b2:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b3:	8a 02                	mov    (%edx),%al
  8008b5:	84 c0                	test   %al,%al
  8008b7:	74 04                	je     8008bd <strcmp+0x17>
  8008b9:	3a 01                	cmp    (%ecx),%al
  8008bb:	74 f4                	je     8008b1 <strcmp+0xb>
  8008bd:	0f b6 c0             	movzbl %al,%eax
  8008c0:	0f b6 11             	movzbl (%ecx),%edx
  8008c3:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d4:	eb 03                	jmp    8008d9 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8008d6:	4a                   	dec    %edx
  8008d7:	41                   	inc    %ecx
  8008d8:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	85 d2                	test   %edx,%edx
  8008db:	75 07                	jne    8008e4 <strncmp+0x1d>
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e2:	eb 14                	jmp    8008f8 <strncmp+0x31>
  8008e4:	8a 01                	mov    (%ecx),%al
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 04                	je     8008ee <strncmp+0x27>
  8008ea:	3a 03                	cmp    (%ebx),%al
  8008ec:	74 e8                	je     8008d6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 d0             	movzbl %al,%edx
  8008f1:	0f b6 03             	movzbl (%ebx),%eax
  8008f4:	29 c2                	sub    %eax,%edx
  8008f6:	89 d0                	mov    %edx,%eax
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	c9                   	leave  
  8008fa:	c3                   	ret    

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800904:	eb 05                	jmp    80090b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0c                	je     800916 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	40                   	inc    %eax
  80090b:	8a 10                	mov    (%eax),%dl
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f5                	jne    800906 <strchr+0xb>
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800921:	eb 05                	jmp    800928 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800923:	38 ca                	cmp    %cl,%dl
  800925:	74 07                	je     80092e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800927:	40                   	inc    %eax
  800928:	8a 10                	mov    (%eax),%dl
  80092a:	84 d2                	test   %dl,%dl
  80092c:	75 f5                	jne    800923 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80093f:	85 db                	test   %ebx,%ebx
  800941:	74 36                	je     800979 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800943:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800949:	75 29                	jne    800974 <memset+0x44>
  80094b:	f6 c3 03             	test   $0x3,%bl
  80094e:	75 24                	jne    800974 <memset+0x44>
		c &= 0xFF;
  800950:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800953:	89 d6                	mov    %edx,%esi
  800955:	c1 e6 08             	shl    $0x8,%esi
  800958:	89 d0                	mov    %edx,%eax
  80095a:	c1 e0 18             	shl    $0x18,%eax
  80095d:	89 d1                	mov    %edx,%ecx
  80095f:	c1 e1 10             	shl    $0x10,%ecx
  800962:	09 c8                	or     %ecx,%eax
  800964:	09 c2                	or     %eax,%edx
  800966:	89 f0                	mov    %esi,%eax
  800968:	09 d0                	or     %edx,%eax
  80096a:	89 d9                	mov    %ebx,%ecx
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	fc                   	cld    
  800970:	f3 ab                	rep stos %eax,%es:(%edi)
  800972:	eb 05                	jmp    800979 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800974:	89 d9                	mov    %ebx,%ecx
  800976:	fc                   	cld    
  800977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800979:	89 f8                	mov    %edi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80098e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800990:	39 c6                	cmp    %eax,%esi
  800992:	73 36                	jae    8009ca <memmove+0x4a>
  800994:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800997:	39 d0                	cmp    %edx,%eax
  800999:	73 2f                	jae    8009ca <memmove+0x4a>
		s += n;
		d += n;
  80099b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	f6 c2 03             	test   $0x3,%dl
  8009a1:	75 1b                	jne    8009be <memmove+0x3e>
  8009a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a9:	75 13                	jne    8009be <memmove+0x3e>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	75 0e                	jne    8009be <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8009b0:	8d 7e fc             	lea    -0x4(%esi),%edi
  8009b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	fd                   	std    
  8009ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bc:	eb 09                	jmp    8009c7 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009be:	8d 7e ff             	lea    -0x1(%esi),%edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 20                	jmp    8009ea <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d0:	75 15                	jne    8009e7 <memmove+0x67>
  8009d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d8:	75 0d                	jne    8009e7 <memmove+0x67>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 08                	jne    8009e7 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8009df:	c1 e9 02             	shr    $0x2,%ecx
  8009e2:	fc                   	cld    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 03                	jmp    8009ea <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f1:	ff 75 10             	pushl  0x10(%ebp)
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	ff 75 08             	pushl  0x8(%ebp)
  8009fa:	e8 81 ff ff ff       	call   800980 <memmove>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	83 ec 04             	sub    $0x4,%esp
  800a08:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a11:	eb 1b                	jmp    800a2e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800a13:	8a 1a                	mov    (%edx),%bl
  800a15:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800a18:	8a 19                	mov    (%ecx),%bl
  800a1a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800a1d:	74 0d                	je     800a2c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800a1f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800a23:	0f b6 c3             	movzbl %bl,%eax
  800a26:	29 c2                	sub    %eax,%edx
  800a28:	89 d0                	mov    %edx,%eax
  800a2a:	eb 0d                	jmp    800a39 <memcmp+0x38>
		s1++, s2++;
  800a2c:	42                   	inc    %edx
  800a2d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	48                   	dec    %eax
  800a2f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800a32:	75 df                	jne    800a13 <memcmp+0x12>
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a39:	83 c4 04             	add    $0x4,%esp
  800a3c:	5b                   	pop    %ebx
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	03 55 10             	add    0x10(%ebp),%edx
  800a4d:	eb 05                	jmp    800a54 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4f:	38 08                	cmp    %cl,(%eax)
  800a51:	74 05                	je     800a58 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a53:	40                   	inc    %eax
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	72 f7                	jb     800a4f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 04             	sub    $0x4,%esp
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a66:	8b 75 10             	mov    0x10(%ebp),%esi
  800a69:	eb 01                	jmp    800a6c <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a6b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	8a 01                	mov    (%ecx),%al
  800a6e:	3c 20                	cmp    $0x20,%al
  800a70:	74 f9                	je     800a6b <strtol+0x11>
  800a72:	3c 09                	cmp    $0x9,%al
  800a74:	74 f5                	je     800a6b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a76:	3c 2b                	cmp    $0x2b,%al
  800a78:	75 0a                	jne    800a84 <strtol+0x2a>
		s++;
  800a7a:	41                   	inc    %ecx
  800a7b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a82:	eb 17                	jmp    800a9b <strtol+0x41>
	else if (*s == '-')
  800a84:	3c 2d                	cmp    $0x2d,%al
  800a86:	74 09                	je     800a91 <strtol+0x37>
  800a88:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a8f:	eb 0a                	jmp    800a9b <strtol+0x41>
		s++, neg = 1;
  800a91:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a94:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9b:	85 f6                	test   %esi,%esi
  800a9d:	74 05                	je     800aa4 <strtol+0x4a>
  800a9f:	83 fe 10             	cmp    $0x10,%esi
  800aa2:	75 1a                	jne    800abe <strtol+0x64>
  800aa4:	8a 01                	mov    (%ecx),%al
  800aa6:	3c 30                	cmp    $0x30,%al
  800aa8:	75 10                	jne    800aba <strtol+0x60>
  800aaa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aae:	75 0a                	jne    800aba <strtol+0x60>
		s += 2, base = 16;
  800ab0:	83 c1 02             	add    $0x2,%ecx
  800ab3:	be 10 00 00 00       	mov    $0x10,%esi
  800ab8:	eb 04                	jmp    800abe <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800aba:	85 f6                	test   %esi,%esi
  800abc:	74 07                	je     800ac5 <strtol+0x6b>
  800abe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac3:	eb 13                	jmp    800ad8 <strtol+0x7e>
  800ac5:	3c 30                	cmp    $0x30,%al
  800ac7:	74 07                	je     800ad0 <strtol+0x76>
  800ac9:	be 0a 00 00 00       	mov    $0xa,%esi
  800ace:	eb ee                	jmp    800abe <strtol+0x64>
		s++, base = 8;
  800ad0:	41                   	inc    %ecx
  800ad1:	be 08 00 00 00       	mov    $0x8,%esi
  800ad6:	eb e6                	jmp    800abe <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad8:	8a 11                	mov    (%ecx),%dl
  800ada:	88 d3                	mov    %dl,%bl
  800adc:	8d 42 d0             	lea    -0x30(%edx),%eax
  800adf:	3c 09                	cmp    $0x9,%al
  800ae1:	77 08                	ja     800aeb <strtol+0x91>
			dig = *s - '0';
  800ae3:	0f be c2             	movsbl %dl,%eax
  800ae6:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ae9:	eb 1c                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aeb:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800aee:	3c 19                	cmp    $0x19,%al
  800af0:	77 08                	ja     800afa <strtol+0xa0>
			dig = *s - 'a' + 10;
  800af2:	0f be c2             	movsbl %dl,%eax
  800af5:	8d 50 a9             	lea    -0x57(%eax),%edx
  800af8:	eb 0d                	jmp    800b07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800afd:	3c 19                	cmp    $0x19,%al
  800aff:	77 15                	ja     800b16 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800b01:	0f be c2             	movsbl %dl,%eax
  800b04:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800b07:	39 f2                	cmp    %esi,%edx
  800b09:	7d 0b                	jge    800b16 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800b0b:	41                   	inc    %ecx
  800b0c:	89 f8                	mov    %edi,%eax
  800b0e:	0f af c6             	imul   %esi,%eax
  800b11:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800b14:	eb c2                	jmp    800ad8 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800b16:	89 f8                	mov    %edi,%eax

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 05                	je     800b23 <strtol+0xc9>
		*endptr = (char *) s;
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800b23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b27:	74 04                	je     800b2d <strtol+0xd3>
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	f7 df                	neg    %edi
}
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	83 c4 04             	add    $0x4,%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    
	...

00800b38 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	89 fa                	mov    %edi,%edx
  800b4a:	89 f9                	mov    %edi,%ecx
  800b4c:	89 fb                	mov    %edi,%ebx
  800b4e:	89 fe                	mov    %edi,%esi
  800b50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 04             	sub    $0x4,%esp
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6b:	89 f8                	mov    %edi,%eax
  800b6d:	89 fb                	mov    %edi,%ebx
  800b6f:	89 fe                	mov    %edi,%esi
  800b71:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b73:	83 c4 04             	add    $0x4,%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	89 f9                	mov    %edi,%ecx
  800b93:	89 fb                	mov    %edi,%ebx
  800b95:	89 fe                	mov    %edi,%esi
  800b97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 17                	jle    800bb4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	50                   	push   %eax
  800ba1:	6a 0d                	push   $0xd
  800ba3:	68 bf 26 80 00       	push   $0x8026bf
  800ba8:	6a 23                	push   $0x23
  800baa:	68 dc 26 80 00       	push   $0x8026dc
  800baf:	e8 6c f6 ff ff       	call   800220 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bd3:	be 00 00 00 00       	mov    $0x0,%esi
  800bd8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800bee:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c00:	7e 17                	jle    800c19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 0a                	push   $0xa
  800c08:	68 bf 26 80 00       	push   $0x8026bf
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 dc 26 80 00       	push   $0x8026dc
  800c14:	e8 07 f6 ff ff       	call   800220 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c30:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c42:	7e 17                	jle    800c5b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 09                	push   $0x9
  800c4a:	68 bf 26 80 00       	push   $0x8026bf
  800c4f:	6a 23                	push   $0x23
  800c51:	68 dc 26 80 00       	push   $0x8026dc
  800c56:	e8 c5 f5 ff ff       	call   800220 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 08 00 00 00       	mov    $0x8,%eax
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	89 fb                	mov    %edi,%ebx
  800c7e:	89 fe                	mov    %edi,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 08                	push   $0x8
  800c8c:	68 bf 26 80 00       	push   $0x8026bf
  800c91:	6a 23                	push   $0x23
  800c93:	68 dc 26 80 00       	push   $0x8026dc
  800c98:	e8 83 f5 ff ff       	call   800220 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbe:	89 fb                	mov    %edi,%ebx
  800cc0:	89 fe                	mov    %edi,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 06                	push   $0x6
  800cce:	68 bf 26 80 00       	push   $0x8026bf
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 dc 26 80 00       	push   $0x8026dc
  800cda:	e8 41 f5 ff ff       	call   800220 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfc:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	b8 05 00 00 00       	mov    $0x5,%eax
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 05                	push   $0x5
  800d10:	68 bf 26 80 00       	push   $0x8026bf
  800d15:	6a 23                	push   $0x23
  800d17:	68 dc 26 80 00       	push   $0x8026dc
  800d1c:	e8 ff f4 ff ff       	call   800220 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d40:	bf 00 00 00 00       	mov    $0x0,%edi
  800d45:	89 fe                	mov    %edi,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 04                	push   $0x4
  800d53:	68 bf 26 80 00       	push   $0x8026bf
  800d58:	6a 23                	push   $0x23
  800d5a:	68 dc 26 80 00       	push   $0x8026dc
  800d5f:	e8 bc f4 ff ff       	call   800220 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d77:	bf 00 00 00 00       	mov    $0x0,%edi
  800d7c:	89 fa                	mov    %edi,%edx
  800d7e:	89 f9                	mov    %edi,%ecx
  800d80:	89 fb                	mov    %edi,%ebx
  800d82:	89 fe                	mov    %edi,%esi
  800d84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d91:	b8 02 00 00 00       	mov    $0x2,%eax
  800d96:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9b:	89 fa                	mov    %edi,%edx
  800d9d:	89 f9                	mov    %edi,%ecx
  800d9f:	89 fb                	mov    %edi,%ebx
  800da1:	89 fe                	mov    %edi,%esi
  800da3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db6:	b8 03 00 00 00       	mov    $0x3,%eax
  800dbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	89 fb                	mov    %edi,%ebx
  800dc4:	89 fe                	mov    %edi,%esi
  800dc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 17                	jle    800de3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 03                	push   $0x3
  800dd2:	68 bf 26 80 00       	push   $0x8026bf
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 dc 26 80 00       	push   $0x8026dc
  800dde:	e8 3d f4 ff ff       	call   800220 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    
	...

00800dec <sfork>:
}

// Challenge!
int
sfork(void)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800df2:	68 ea 26 80 00       	push   $0x8026ea
  800df7:	68 92 00 00 00       	push   $0x92
  800dfc:	68 00 27 80 00       	push   $0x802700
  800e01:	e8 1a f4 ff ff       	call   800220 <_panic>

00800e06 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800e0f:	68 a7 0f 80 00       	push   $0x800fa7
  800e14:	e8 b3 0f 00 00       	call   801dcc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e19:	ba 07 00 00 00       	mov    $0x7,%edx
  800e1e:	89 d0                	mov    %edx,%eax
  800e20:	cd 30                	int    $0x30
  800e22:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	75 25                	jne    800e50 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800e2b:	e8 5b ff ff ff       	call   800d8b <sys_getenvid>
  800e30:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e3c:	c1 e0 07             	shl    $0x7,%eax
  800e3f:	29 d0                	sub    %edx,%eax
  800e41:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e46:	a3 20 44 80 00       	mov    %eax,0x804420
  800e4b:	e9 4d 01 00 00       	jmp    800f9d <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 12                	jns    800e66 <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800e54:	50                   	push   %eax
  800e55:	68 0b 27 80 00       	push   $0x80270b
  800e5a:	6a 77                	push   $0x77
  800e5c:	68 00 27 80 00       	push   $0x802700
  800e61:	e8 ba f3 ff ff       	call   800220 <_panic>
  800e66:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800e6b:	89 d8                	mov    %ebx,%eax
  800e6d:	c1 e8 16             	shr    $0x16,%eax
  800e70:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e77:	a8 01                	test   $0x1,%al
  800e79:	0f 84 ab 00 00 00    	je     800f2a <fork+0x124>
  800e7f:	89 da                	mov    %ebx,%edx
  800e81:	c1 ea 0c             	shr    $0xc,%edx
  800e84:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e8b:	a8 01                	test   $0x1,%al
  800e8d:	0f 84 97 00 00 00    	je     800f2a <fork+0x124>
  800e93:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e9a:	a8 04                	test   $0x4,%al
  800e9c:	0f 84 88 00 00 00    	je     800f2a <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800ea2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800ea9:	89 d6                	mov    %edx,%esi
  800eab:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800eb6:	a9 02 08 00 00       	test   $0x802,%eax
  800ebb:	74 0f                	je     800ecc <fork+0xc6>
  800ebd:	f6 c4 04             	test   $0x4,%ah
  800ec0:	75 0a                	jne    800ecc <fork+0xc6>
		perm &= ~PTE_W;
  800ec2:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800ec7:	89 c2                	mov    %eax,%edx
  800ec9:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800ecc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ed2:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	52                   	push   %edx
  800ed9:	56                   	push   %esi
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	6a 00                	push   $0x0
  800ede:	e8 04 fe ff ff       	call   800ce7 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800ee3:	83 c4 20             	add    $0x20,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 14                	jns    800efe <fork+0xf8>
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	68 54 27 80 00       	push   $0x802754
  800ef2:	6a 52                	push   $0x52
  800ef4:	68 00 27 80 00       	push   $0x802700
  800ef9:	e8 22 f3 ff ff       	call   800220 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	ff 75 f0             	pushl  -0x10(%ebp)
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	56                   	push   %esi
  800f08:	6a 00                	push   $0x0
  800f0a:	e8 d8 fd ff ff       	call   800ce7 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800f0f:	83 c4 20             	add    $0x20,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	79 14                	jns    800f2a <fork+0x124>
  800f16:	83 ec 04             	sub    $0x4,%esp
  800f19:	68 78 27 80 00       	push   $0x802778
  800f1e:	6a 55                	push   $0x55
  800f20:	68 00 27 80 00       	push   $0x802700
  800f25:	e8 f6 f2 ff ff       	call   800220 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f2a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f30:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f36:	0f 85 2f ff ff ff    	jne    800e6b <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	6a 07                	push   $0x7
  800f41:	68 00 f0 bf ee       	push   $0xeebff000
  800f46:	57                   	push   %edi
  800f47:	e8 dd fd ff ff       	call   800d29 <sys_page_alloc>
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 15                	jns    800f68 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800f53:	50                   	push   %eax
  800f54:	68 29 27 80 00       	push   $0x802729
  800f59:	68 83 00 00 00       	push   $0x83
  800f5e:	68 00 27 80 00       	push   $0x802700
  800f63:	e8 b8 f2 ff ff       	call   800220 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	68 4c 1e 80 00       	push   $0x801e4c
  800f70:	57                   	push   %edi
  800f71:	e8 69 fc ff ff       	call   800bdf <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800f76:	83 c4 08             	add    $0x8,%esp
  800f79:	6a 02                	push   $0x2
  800f7b:	57                   	push   %edi
  800f7c:	e8 e2 fc ff ff       	call   800c63 <sys_env_set_status>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 15                	jns    800f9d <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800f88:	50                   	push   %eax
  800f89:	68 3c 27 80 00       	push   $0x80273c
  800f8e:	68 89 00 00 00       	push   $0x89
  800f93:	68 00 27 80 00       	push   $0x802700
  800f98:	e8 83 f2 ff ff       	call   800220 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800f9d:	89 f8                	mov    %edi,%eax
  800f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa2:	5b                   	pop    %ebx
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800fb1:	8b 1a                	mov    (%edx),%ebx
  800fb3:	89 d8                	mov    %ebx,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800fbf:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fc3:	74 05                	je     800fca <pgfault+0x23>
  800fc5:	f6 c4 08             	test   $0x8,%ah
  800fc8:	75 14                	jne    800fde <pgfault+0x37>
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 9c 27 80 00       	push   $0x80279c
  800fd2:	6a 1e                	push   $0x1e
  800fd4:	68 00 27 80 00       	push   $0x802700
  800fd9:	e8 42 f2 ff ff       	call   800220 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800fde:	83 ec 04             	sub    $0x4,%esp
  800fe1:	6a 07                	push   $0x7
  800fe3:	68 00 f0 7f 00       	push   $0x7ff000
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 3a fd ff ff       	call   800d29 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	79 14                	jns    80100a <pgfault+0x63>
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 c8 27 80 00       	push   $0x8027c8
  800ffe:	6a 2a                	push   $0x2a
  801000:	68 00 27 80 00       	push   $0x802700
  801005:	e8 16 f2 ff ff       	call   800220 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  80100a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	68 00 10 00 00       	push   $0x1000
  801018:	53                   	push   %ebx
  801019:	68 00 f0 7f 00       	push   $0x7ff000
  80101e:	e8 5d f9 ff ff       	call   800980 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  801023:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80102a:	53                   	push   %ebx
  80102b:	6a 00                	push   $0x0
  80102d:	68 00 f0 7f 00       	push   $0x7ff000
  801032:	6a 00                	push   $0x0
  801034:	e8 ae fc ff ff       	call   800ce7 <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  801039:	83 c4 20             	add    $0x20,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	79 14                	jns    801054 <pgfault+0xad>
  801040:	83 ec 04             	sub    $0x4,%esp
  801043:	68 ec 27 80 00       	push   $0x8027ec
  801048:	6a 2e                	push   $0x2e
  80104a:	68 00 27 80 00       	push   $0x802700
  80104f:	e8 cc f1 ff ff       	call   800220 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  801054:	83 ec 08             	sub    $0x8,%esp
  801057:	68 00 f0 7f 00       	push   $0x7ff000
  80105c:	6a 00                	push   $0x0
  80105e:	e8 42 fc ff ff       	call   800ca5 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	79 14                	jns    80107e <pgfault+0xd7>
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	68 0c 28 80 00       	push   $0x80280c
  801072:	6a 32                	push   $0x32
  801074:	68 00 27 80 00       	push   $0x802700
  801079:	e8 a2 f1 ff ff       	call   800220 <_panic>
	//panic("pgfault not implemented");
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    
	...

00801084 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	05 00 00 00 30       	add    $0x30000000,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801097:	ff 75 08             	pushl  0x8(%ebp)
  80109a:	e8 e5 ff ff ff       	call   801084 <fd2num>
  80109f:	83 c4 04             	add    $0x4,%esp
  8010a2:	c1 e0 0c             	shl    $0xc,%eax
  8010a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	53                   	push   %ebx
  8010b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010b3:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8010b8:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ba:	89 d0                	mov    %edx,%eax
  8010bc:	c1 e8 16             	shr    $0x16,%eax
  8010bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c6:	a8 01                	test   $0x1,%al
  8010c8:	74 10                	je     8010da <fd_alloc+0x2e>
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	c1 e8 0c             	shr    $0xc,%eax
  8010cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d6:	a8 01                	test   $0x1,%al
  8010d8:	75 09                	jne    8010e3 <fd_alloc+0x37>
			*fd_store = fd;
  8010da:	89 0b                	mov    %ecx,(%ebx)
  8010dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e1:	eb 19                	jmp    8010fc <fd_alloc+0x50>
			return 0;
  8010e3:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e9:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8010ef:	75 c7                	jne    8010b8 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010fc:	5b                   	pop    %ebx
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801105:	83 f8 1f             	cmp    $0x1f,%eax
  801108:	77 35                	ja     80113f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80110a:	c1 e0 0c             	shl    $0xc,%eax
  80110d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801113:	89 d0                	mov    %edx,%eax
  801115:	c1 e8 16             	shr    $0x16,%eax
  801118:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111f:	a8 01                	test   $0x1,%al
  801121:	74 1c                	je     80113f <fd_lookup+0x40>
  801123:	89 d0                	mov    %edx,%eax
  801125:	c1 e8 0c             	shr    $0xc,%eax
  801128:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112f:	a8 01                	test   $0x1,%al
  801131:	74 0c                	je     80113f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801133:	8b 45 0c             	mov    0xc(%ebp),%eax
  801136:	89 10                	mov    %edx,(%eax)
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	eb 05                	jmp    801144 <fd_lookup+0x45>
	return 0;
  80113f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	ff 75 08             	pushl  0x8(%ebp)
  801153:	e8 a7 ff ff ff       	call   8010ff <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 0e                	js     80116d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801165:	89 50 04             	mov    %edx,0x4(%eax)
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80117c:	ba 00 00 00 00       	mov    $0x0,%edx
  801181:	eb 0e                	jmp    801191 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801183:	3b 08                	cmp    (%eax),%ecx
  801185:	75 09                	jne    801190 <dev_lookup+0x21>
			*dev = devtab[i];
  801187:	89 03                	mov    %eax,(%ebx)
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
  80118e:	eb 31                	jmp    8011c1 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801190:	42                   	inc    %edx
  801191:	8b 04 95 ac 28 80 00 	mov    0x8028ac(,%edx,4),%eax
  801198:	85 c0                	test   %eax,%eax
  80119a:	75 e7                	jne    801183 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80119c:	a1 20 44 80 00       	mov    0x804420,%eax
  8011a1:	8b 40 48             	mov    0x48(%eax),%eax
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	51                   	push   %ecx
  8011a8:	50                   	push   %eax
  8011a9:	68 30 28 80 00       	push   $0x802830
  8011ae:	e8 0e f1 ff ff       	call   8002c1 <cprintf>
	*dev = 0;
  8011b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011be:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  8011c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c4:	c9                   	leave  
  8011c5:	c3                   	ret    

008011c6 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	53                   	push   %ebx
  8011ca:	83 ec 14             	sub    $0x14,%esp
  8011cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 23 ff ff ff       	call   8010ff <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 55                	js     801238 <fstat+0x72>
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ed:	ff 30                	pushl  (%eax)
  8011ef:	e8 7b ff ff ff       	call   80116f <dev_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 3d                	js     801238 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011fe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801202:	75 07                	jne    80120b <fstat+0x45>
  801204:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801209:	eb 2d                	jmp    801238 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80120b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80120e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801215:	00 00 00 
	stat->st_isdir = 0;
  801218:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80121f:	00 00 00 
	stat->st_dev = dev;
  801222:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801225:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	53                   	push   %ebx
  80122f:	ff 75 f4             	pushl  -0xc(%ebp)
  801232:	ff 50 14             	call   *0x14(%eax)
  801235:	83 c4 10             	add    $0x10,%esp
}
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	53                   	push   %ebx
  801241:	83 ec 14             	sub    $0x14,%esp
  801244:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	53                   	push   %ebx
  80124c:	e8 ae fe ff ff       	call   8010ff <fd_lookup>
  801251:	83 c4 08             	add    $0x8,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 5f                	js     8012b7 <ftruncate+0x7a>
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801262:	ff 30                	pushl  (%eax)
  801264:	e8 06 ff ff ff       	call   80116f <dev_lookup>
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 47                	js     8012b7 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801273:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801277:	75 21                	jne    80129a <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801279:	a1 20 44 80 00       	mov    0x804420,%eax
  80127e:	8b 40 48             	mov    0x48(%eax),%eax
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	53                   	push   %ebx
  801285:	50                   	push   %eax
  801286:	68 50 28 80 00       	push   $0x802850
  80128b:	e8 31 f0 ff ff       	call   8002c1 <cprintf>
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	eb 1d                	jmp    8012b7 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80129a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80129d:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8012a1:	75 07                	jne    8012aa <ftruncate+0x6d>
  8012a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a8:	eb 0d                	jmp    8012b7 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	50                   	push   %eax
  8012b1:	ff 52 18             	call   *0x18(%edx)
  8012b4:	83 c4 10             	add    $0x10,%esp
}
  8012b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	53                   	push   %ebx
  8012cb:	e8 2f fe ff ff       	call   8010ff <fd_lookup>
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 62                	js     801339 <write+0x7d>
  8012d7:	83 ec 08             	sub    $0x8,%esp
  8012da:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e1:	ff 30                	pushl  (%eax)
  8012e3:	e8 87 fe ff ff       	call   80116f <dev_lookup>
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 4a                	js     801339 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f6:	75 21                	jne    801319 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f8:	a1 20 44 80 00       	mov    0x804420,%eax
  8012fd:	8b 40 48             	mov    0x48(%eax),%eax
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	53                   	push   %ebx
  801304:	50                   	push   %eax
  801305:	68 71 28 80 00       	push   $0x802871
  80130a:	e8 b2 ef ff ff       	call   8002c1 <cprintf>
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	eb 20                	jmp    801339 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801319:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80131c:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801320:	75 07                	jne    801329 <write+0x6d>
  801322:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801327:	eb 10                	jmp    801339 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801329:	83 ec 04             	sub    $0x4,%esp
  80132c:	ff 75 10             	pushl  0x10(%ebp)
  80132f:	ff 75 0c             	pushl  0xc(%ebp)
  801332:	50                   	push   %eax
  801333:	ff 52 0c             	call   *0xc(%edx)
  801336:	83 c4 10             	add    $0x10,%esp
}
  801339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 14             	sub    $0x14,%esp
  801345:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	53                   	push   %ebx
  80134d:	e8 ad fd ff ff       	call   8010ff <fd_lookup>
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 67                	js     8013c0 <read+0x82>
  801359:	83 ec 08             	sub    $0x8,%esp
  80135c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	ff 30                	pushl  (%eax)
  801365:	e8 05 fe ff ff       	call   80116f <dev_lookup>
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 4f                	js     8013c0 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801371:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801374:	8b 42 08             	mov    0x8(%edx),%eax
  801377:	83 e0 03             	and    $0x3,%eax
  80137a:	83 f8 01             	cmp    $0x1,%eax
  80137d:	75 21                	jne    8013a0 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80137f:	a1 20 44 80 00       	mov    0x804420,%eax
  801384:	8b 40 48             	mov    0x48(%eax),%eax
  801387:	83 ec 04             	sub    $0x4,%esp
  80138a:	53                   	push   %ebx
  80138b:	50                   	push   %eax
  80138c:	68 8e 28 80 00       	push   $0x80288e
  801391:	e8 2b ef ff ff       	call   8002c1 <cprintf>
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	eb 20                	jmp    8013c0 <read+0x82>
	}
	if (!dev->dev_read)
  8013a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013a3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8013a7:	75 07                	jne    8013b0 <read+0x72>
  8013a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ae:	eb 10                	jmp    8013c0 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b0:	83 ec 04             	sub    $0x4,%esp
  8013b3:	ff 75 10             	pushl  0x10(%ebp)
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	52                   	push   %edx
  8013ba:	ff 50 08             	call   *0x8(%eax)
  8013bd:	83 c4 10             	add    $0x10,%esp
}
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 0c             	sub    $0xc,%esp
  8013ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8013d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d9:	eb 21                	jmp    8013fc <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	29 d0                	sub    %edx,%eax
  8013e2:	50                   	push   %eax
  8013e3:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 75 08             	pushl  0x8(%ebp)
  8013ea:	e8 4f ff ff ff       	call   80133e <read>
		if (m < 0)
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 0e                	js     801404 <readn+0x3f>
			return m;
		if (m == 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	74 08                	je     801402 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fa:	01 c3                	add    %eax,%ebx
  8013fc:	89 da                	mov    %ebx,%edx
  8013fe:	39 f3                	cmp    %esi,%ebx
  801400:	72 d9                	jb     8013db <readn+0x16>
  801402:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801404:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 20             	sub    $0x20,%esp
  801414:	8b 75 08             	mov    0x8(%ebp),%esi
  801417:	8a 45 0c             	mov    0xc(%ebp),%al
  80141a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80141d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	56                   	push   %esi
  801422:	e8 5d fc ff ff       	call   801084 <fd2num>
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 d0 fc ff ff       	call   8010ff <fd_lookup>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	78 05                	js     80143d <fd_close+0x31>
  801438:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80143b:	74 0d                	je     80144a <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80143d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801441:	75 48                	jne    80148b <fd_close+0x7f>
  801443:	bb 00 00 00 00       	mov    $0x0,%ebx
  801448:	eb 41                	jmp    80148b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	ff 36                	pushl  (%esi)
  801453:	e8 17 fd ff ff       	call   80116f <dev_lookup>
  801458:	89 c3                	mov    %eax,%ebx
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 1c                	js     80147d <fd_close+0x71>
		if (dev->dev_close)
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	8b 40 10             	mov    0x10(%eax),%eax
  801467:	85 c0                	test   %eax,%eax
  801469:	75 07                	jne    801472 <fd_close+0x66>
  80146b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801470:	eb 0b                	jmp    80147d <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	56                   	push   %esi
  801476:	ff d0                	call   *%eax
  801478:	89 c3                	mov    %eax,%ebx
  80147a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	56                   	push   %esi
  801481:	6a 00                	push   $0x0
  801483:	e8 1d f8 ff ff       	call   800ca5 <sys_page_unmap>
  801488:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	ff 75 08             	pushl  0x8(%ebp)
  8014a1:	e8 59 fc ff ff       	call   8010ff <fd_lookup>
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 10                	js     8014bd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	6a 01                	push   $0x1
  8014b2:	ff 75 fc             	pushl  -0x4(%ebp)
  8014b5:	e8 52 ff ff ff       	call   80140c <fd_close>
  8014ba:	83 c4 10             	add    $0x10,%esp
}
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	6a 00                	push   $0x0
  8014c9:	ff 75 08             	pushl  0x8(%ebp)
  8014cc:	e8 4a 03 00 00       	call   80181b <open>
  8014d1:	89 c6                	mov    %eax,%esi
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 1b                	js     8014f5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	50                   	push   %eax
  8014e1:	e8 e0 fc ff ff       	call   8011c6 <fstat>
  8014e6:	89 c3                	mov    %eax,%ebx
	close(fd);
  8014e8:	89 34 24             	mov    %esi,(%esp)
  8014eb:	e8 a4 ff ff ff       	call   801494 <close>
  8014f0:	89 de                	mov    %ebx,%esi
  8014f2:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	57                   	push   %edi
  801502:	56                   	push   %esi
  801503:	53                   	push   %ebx
  801504:	83 ec 1c             	sub    $0x1c,%esp
  801507:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	ff 75 08             	pushl  0x8(%ebp)
  801511:	e8 e9 fb ff ff       	call   8010ff <fd_lookup>
  801516:	89 c3                	mov    %eax,%ebx
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	0f 88 bd 00 00 00    	js     8015e0 <dup+0xe2>
		return r;
	close(newfdnum);
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	57                   	push   %edi
  801527:	e8 68 ff ff ff       	call   801494 <close>

	newfd = INDEX2FD(newfdnum);
  80152c:	89 f8                	mov    %edi,%eax
  80152e:	c1 e0 0c             	shl    $0xc,%eax
  801531:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801537:	ff 75 f0             	pushl  -0x10(%ebp)
  80153a:	e8 55 fb ff ff       	call   801094 <fd2data>
  80153f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801541:	89 34 24             	mov    %esi,(%esp)
  801544:	e8 4b fb ff ff       	call   801094 <fd2data>
  801549:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	c1 e8 16             	shr    $0x16,%eax
  801551:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801558:	83 c4 14             	add    $0x14,%esp
  80155b:	a8 01                	test   $0x1,%al
  80155d:	74 36                	je     801595 <dup+0x97>
  80155f:	89 da                	mov    %ebx,%edx
  801561:	c1 ea 0c             	shr    $0xc,%edx
  801564:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80156b:	a8 01                	test   $0x1,%al
  80156d:	74 26                	je     801595 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80156f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	25 07 0e 00 00       	and    $0xe07,%eax
  80157e:	50                   	push   %eax
  80157f:	ff 75 e0             	pushl  -0x20(%ebp)
  801582:	6a 00                	push   $0x0
  801584:	53                   	push   %ebx
  801585:	6a 00                	push   $0x0
  801587:	e8 5b f7 ff ff       	call   800ce7 <sys_page_map>
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	83 c4 20             	add    $0x20,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 30                	js     8015c5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801595:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801598:	89 d0                	mov    %edx,%eax
  80159a:	c1 e8 0c             	shr    $0xc,%eax
  80159d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a4:	83 ec 0c             	sub    $0xc,%esp
  8015a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ac:	50                   	push   %eax
  8015ad:	56                   	push   %esi
  8015ae:	6a 00                	push   $0x0
  8015b0:	52                   	push   %edx
  8015b1:	6a 00                	push   $0x0
  8015b3:	e8 2f f7 ff ff       	call   800ce7 <sys_page_map>
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	83 c4 20             	add    $0x20,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 04                	js     8015c5 <dup+0xc7>
		goto err;
  8015c1:	89 fb                	mov    %edi,%ebx
  8015c3:	eb 1b                	jmp    8015e0 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	56                   	push   %esi
  8015c9:	6a 00                	push   $0x0
  8015cb:	e8 d5 f6 ff ff       	call   800ca5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 c8 f6 ff ff       	call   800ca5 <sys_page_unmap>
  8015dd:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5f                   	pop    %edi
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 04             	sub    $0x4,%esp
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015f6:	83 ec 0c             	sub    $0xc,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	e8 95 fe ff ff       	call   801494 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ff:	43                   	inc    %ebx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	83 fb 20             	cmp    $0x20,%ebx
  801606:	75 ee                	jne    8015f6 <close_all+0xc>
		close(i);
}
  801608:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    
  80160d:	00 00                	add    %al,(%eax)
	...

00801610 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	89 c3                	mov    %eax,%ebx
  801617:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801619:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801620:	75 12                	jne    801634 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801622:	83 ec 0c             	sub    $0xc,%esp
  801625:	6a 01                	push   $0x1
  801627:	e8 48 08 00 00       	call   801e74 <ipc_find_env>
  80162c:	a3 00 40 80 00       	mov    %eax,0x804000
  801631:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801634:	6a 07                	push   $0x7
  801636:	68 00 50 80 00       	push   $0x805000
  80163b:	53                   	push   %ebx
  80163c:	ff 35 00 40 80 00    	pushl  0x804000
  801642:	e8 72 08 00 00       	call   801eb9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801647:	83 c4 0c             	add    $0xc,%esp
  80164a:	6a 00                	push   $0x0
  80164c:	56                   	push   %esi
  80164d:	6a 00                	push   $0x0
  80164f:	e8 ba 08 00 00       	call   801f0e <ipc_recv>
}
  801654:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	b8 08 00 00 00       	mov    $0x8,%eax
  80166b:	e8 a0 ff ff ff       	call   801610 <fsipc>
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	8b 40 0c             	mov    0xc(%eax),%eax
  80167e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801683:	8b 45 0c             	mov    0xc(%ebp),%eax
  801686:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168b:	ba 00 00 00 00       	mov    $0x0,%edx
  801690:	b8 02 00 00 00       	mov    $0x2,%eax
  801695:	e8 76 ff ff ff       	call   801610 <fsipc>
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b7:	e8 54 ff ff ff       	call   801610 <fsipc>
}
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    

008016be <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 04             	sub    $0x4,%esp
  8016c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016dd:	e8 2e ff ff ff       	call   801610 <fsipc>
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 2c                	js     801712 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	68 00 50 80 00       	push   $0x805000
  8016ee:	53                   	push   %ebx
  8016ef:	e8 1f f1 ff ff       	call   800813 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801704:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
  80170f:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	8b 40 0c             	mov    0xc(%eax),%eax
  801727:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  80172c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801732:	53                   	push   %ebx
  801733:	ff 75 0c             	pushl  0xc(%ebp)
  801736:	68 08 50 80 00       	push   $0x805008
  80173b:	e8 40 f2 ff ff       	call   800980 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801740:	ba 00 00 00 00       	mov    $0x0,%edx
  801745:	b8 04 00 00 00       	mov    $0x4,%eax
  80174a:	e8 c1 fe ff ff       	call   801610 <fsipc>
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	78 3d                	js     801793 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801756:	39 c3                	cmp    %eax,%ebx
  801758:	73 19                	jae    801773 <devfile_write+0x5c>
  80175a:	68 bc 28 80 00       	push   $0x8028bc
  80175f:	68 c3 28 80 00       	push   $0x8028c3
  801764:	68 97 00 00 00       	push   $0x97
  801769:	68 d8 28 80 00       	push   $0x8028d8
  80176e:	e8 ad ea ff ff       	call   800220 <_panic>
	assert(r <= PGSIZE);
  801773:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801778:	7e 19                	jle    801793 <devfile_write+0x7c>
  80177a:	68 e3 28 80 00       	push   $0x8028e3
  80177f:	68 c3 28 80 00       	push   $0x8028c3
  801784:	68 98 00 00 00       	push   $0x98
  801789:	68 d8 28 80 00       	push   $0x8028d8
  80178e:	e8 8d ea ff ff       	call   800220 <_panic>
	
	return r;
}
  801793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8017bb:	e8 50 fe ff ff       	call   801610 <fsipc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 4c                	js     801812 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8017c6:	39 de                	cmp    %ebx,%esi
  8017c8:	73 16                	jae    8017e0 <devfile_read+0x48>
  8017ca:	68 bc 28 80 00       	push   $0x8028bc
  8017cf:	68 c3 28 80 00       	push   $0x8028c3
  8017d4:	6a 7c                	push   $0x7c
  8017d6:	68 d8 28 80 00       	push   $0x8028d8
  8017db:	e8 40 ea ff ff       	call   800220 <_panic>
	assert(r <= PGSIZE);
  8017e0:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8017e6:	7e 16                	jle    8017fe <devfile_read+0x66>
  8017e8:	68 e3 28 80 00       	push   $0x8028e3
  8017ed:	68 c3 28 80 00       	push   $0x8028c3
  8017f2:	6a 7d                	push   $0x7d
  8017f4:	68 d8 28 80 00       	push   $0x8028d8
  8017f9:	e8 22 ea ff ff       	call   800220 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017fe:	83 ec 04             	sub    $0x4,%esp
  801801:	50                   	push   %eax
  801802:	68 00 50 80 00       	push   $0x805000
  801807:	ff 75 0c             	pushl  0xc(%ebp)
  80180a:	e8 71 f1 ff ff       	call   800980 <memmove>
  80180f:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801812:	89 d8                	mov    %ebx,%eax
  801814:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801817:	5b                   	pop    %ebx
  801818:	5e                   	pop    %esi
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	56                   	push   %esi
  80181f:	53                   	push   %ebx
  801820:	83 ec 1c             	sub    $0x1c,%esp
  801823:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801826:	56                   	push   %esi
  801827:	e8 b4 ef ff ff       	call   8007e0 <strlen>
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801834:	7e 07                	jle    80183d <open+0x22>
  801836:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80183b:	eb 63                	jmp    8018a0 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	e8 63 f8 ff ff       	call   8010ac <fd_alloc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 4e                	js     8018a0 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	56                   	push   %esi
  801856:	68 00 50 80 00       	push   $0x805000
  80185b:	e8 b3 ef ff ff       	call   800813 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801868:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186b:	b8 01 00 00 00       	mov    $0x1,%eax
  801870:	e8 9b fd ff ff       	call   801610 <fsipc>
  801875:	89 c3                	mov    %eax,%ebx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	79 12                	jns    801890 <open+0x75>
		fd_close(fd, 0);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	6a 00                	push   $0x0
  801883:	ff 75 f4             	pushl  -0xc(%ebp)
  801886:	e8 81 fb ff ff       	call   80140c <fd_close>
		return r;
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	eb 10                	jmp    8018a0 <open+0x85>
	}

	return fd2num(fd);
  801890:	83 ec 0c             	sub    $0xc,%esp
  801893:	ff 75 f4             	pushl  -0xc(%ebp)
  801896:	e8 e9 f7 ff ff       	call   801084 <fd2num>
  80189b:	89 c3                	mov    %eax,%ebx
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    
  8018a9:	00 00                	add    %al,(%eax)
	...

008018ac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	ff 75 08             	pushl  0x8(%ebp)
  8018ba:	e8 d5 f7 ff ff       	call   801094 <fd2data>
  8018bf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c1:	83 c4 08             	add    $0x8,%esp
  8018c4:	68 ef 28 80 00       	push   $0x8028ef
  8018c9:	53                   	push   %ebx
  8018ca:	e8 44 ef ff ff       	call   800813 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018cf:	8b 46 04             	mov    0x4(%esi),%eax
  8018d2:	2b 06                	sub    (%esi),%eax
  8018d4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018da:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e1:	00 00 00 
	stat->st_dev = &devpipe;
  8018e4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018eb:	30 80 00 
	return 0;
}
  8018ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f6:	5b                   	pop    %ebx
  8018f7:	5e                   	pop    %esi
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801904:	53                   	push   %ebx
  801905:	6a 00                	push   $0x0
  801907:	e8 99 f3 ff ff       	call   800ca5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80190c:	89 1c 24             	mov    %ebx,(%esp)
  80190f:	e8 80 f7 ff ff       	call   801094 <fd2data>
  801914:	83 c4 08             	add    $0x8,%esp
  801917:	50                   	push   %eax
  801918:	6a 00                	push   $0x0
  80191a:	e8 86 f3 ff ff       	call   800ca5 <sys_page_unmap>
}
  80191f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801922:	c9                   	leave  
  801923:	c3                   	ret    

00801924 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	57                   	push   %edi
  801928:	56                   	push   %esi
  801929:	53                   	push   %ebx
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801930:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801932:	a1 20 44 80 00       	mov    0x804420,%eax
  801937:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	ff 75 f0             	pushl  -0x10(%ebp)
  801940:	e8 33 06 00 00       	call   801f78 <pageref>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	89 3c 24             	mov    %edi,(%esp)
  80194a:	e8 29 06 00 00       	call   801f78 <pageref>
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	39 c3                	cmp    %eax,%ebx
  801954:	0f 94 c0             	sete   %al
  801957:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  80195a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801960:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801963:	39 c6                	cmp    %eax,%esi
  801965:	74 1b                	je     801982 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801967:	83 f9 01             	cmp    $0x1,%ecx
  80196a:	75 c6                	jne    801932 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196c:	8b 42 58             	mov    0x58(%edx),%eax
  80196f:	6a 01                	push   $0x1
  801971:	50                   	push   %eax
  801972:	56                   	push   %esi
  801973:	68 f6 28 80 00       	push   $0x8028f6
  801978:	e8 44 e9 ff ff       	call   8002c1 <cprintf>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	eb b0                	jmp    801932 <_pipeisclosed+0xe>
	}
}
  801982:	89 c8                	mov    %ecx,%eax
  801984:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5f                   	pop    %edi
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	57                   	push   %edi
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	83 ec 18             	sub    $0x18,%esp
  801995:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801998:	56                   	push   %esi
  801999:	e8 f6 f6 ff ff       	call   801094 <fd2data>
  80199e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8019a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019a6:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	eb 40                	jmp    8019f0 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b5:	eb 40                	jmp    8019f7 <devpipe_write+0x6b>
  8019b7:	89 da                	mov    %ebx,%edx
  8019b9:	89 f0                	mov    %esi,%eax
  8019bb:	e8 64 ff ff ff       	call   801924 <_pipeisclosed>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	75 ec                	jne    8019b0 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019c4:	e8 a3 f3 ff ff       	call   800d6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019c9:	8b 53 04             	mov    0x4(%ebx),%edx
  8019cc:	8b 03                	mov    (%ebx),%eax
  8019ce:	83 c0 20             	add    $0x20,%eax
  8019d1:	39 c2                	cmp    %eax,%edx
  8019d3:	73 e2                	jae    8019b7 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019d5:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019db:	79 05                	jns    8019e2 <devpipe_write+0x56>
  8019dd:	4a                   	dec    %edx
  8019de:	83 ca e0             	or     $0xffffffe0,%edx
  8019e1:	42                   	inc    %edx
  8019e2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019e5:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8019e8:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ec:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ef:	47                   	inc    %edi
  8019f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019f3:	75 d4                	jne    8019c9 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019f5:	89 f8                	mov    %edi,%eax
}
  8019f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fa:	5b                   	pop    %ebx
  8019fb:	5e                   	pop    %esi
  8019fc:	5f                   	pop    %edi
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 18             	sub    $0x18,%esp
  801a08:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a0b:	57                   	push   %edi
  801a0c:	e8 83 f6 ff ff       	call   801094 <fd2data>
  801a11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a19:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	eb 41                	jmp    801a64 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a23:	89 f0                	mov    %esi,%eax
  801a25:	eb 44                	jmp    801a6b <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a27:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2c:	eb 3d                	jmp    801a6b <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a2e:	85 f6                	test   %esi,%esi
  801a30:	75 f1                	jne    801a23 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a32:	89 da                	mov    %ebx,%edx
  801a34:	89 f8                	mov    %edi,%eax
  801a36:	e8 e9 fe ff ff       	call   801924 <_pipeisclosed>
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	75 e8                	jne    801a27 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a3f:	e8 28 f3 ff ff       	call   800d6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a44:	8b 03                	mov    (%ebx),%eax
  801a46:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a49:	74 e3                	je     801a2e <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a50:	79 05                	jns    801a57 <devpipe_read+0x58>
  801a52:	48                   	dec    %eax
  801a53:	83 c8 e0             	or     $0xffffffe0,%eax
  801a56:	40                   	inc    %eax
  801a57:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a5e:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801a61:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a63:	46                   	inc    %esi
  801a64:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a67:	75 db                	jne    801a44 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a69:	89 f0                	mov    %esi,%eax
}
  801a6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5f                   	pop    %edi
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a79:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	ff 75 08             	pushl  0x8(%ebp)
  801a80:	e8 7a f6 ff ff       	call   8010ff <fd_lookup>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 18                	js     801aa4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	ff 75 fc             	pushl  -0x4(%ebp)
  801a92:	e8 fd f5 ff ff       	call   801094 <fd2data>
  801a97:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a9c:	e8 83 fe ff ff       	call   801924 <_pipeisclosed>
  801aa1:	83 c4 10             	add    $0x10,%esp
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	57                   	push   %edi
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	83 ec 28             	sub    $0x28,%esp
  801aaf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab5:	50                   	push   %eax
  801ab6:	e8 f1 f5 ff ff       	call   8010ac <fd_alloc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	0f 88 24 01 00 00    	js     801bec <pipe+0x146>
  801ac8:	83 ec 04             	sub    $0x4,%esp
  801acb:	68 07 04 00 00       	push   $0x407
  801ad0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 4f f2 ff ff       	call   800d29 <sys_page_alloc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	0f 88 05 01 00 00    	js     801bec <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aed:	50                   	push   %eax
  801aee:	e8 b9 f5 ff ff       	call   8010ac <fd_alloc>
  801af3:	89 c3                	mov    %eax,%ebx
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	85 c0                	test   %eax,%eax
  801afa:	0f 88 dc 00 00 00    	js     801bdc <pipe+0x136>
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	68 07 04 00 00       	push   $0x407
  801b08:	ff 75 ec             	pushl  -0x14(%ebp)
  801b0b:	6a 00                	push   $0x0
  801b0d:	e8 17 f2 ff ff       	call   800d29 <sys_page_alloc>
  801b12:	89 c3                	mov    %eax,%ebx
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	85 c0                	test   %eax,%eax
  801b19:	0f 88 bd 00 00 00    	js     801bdc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	ff 75 f0             	pushl  -0x10(%ebp)
  801b25:	e8 6a f5 ff ff       	call   801094 <fd2data>
  801b2a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b2c:	83 c4 0c             	add    $0xc,%esp
  801b2f:	68 07 04 00 00       	push   $0x407
  801b34:	50                   	push   %eax
  801b35:	6a 00                	push   $0x0
  801b37:	e8 ed f1 ff ff       	call   800d29 <sys_page_alloc>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	0f 88 83 00 00 00    	js     801bcc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	ff 75 ec             	pushl  -0x14(%ebp)
  801b4f:	e8 40 f5 ff ff       	call   801094 <fd2data>
  801b54:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b5b:	50                   	push   %eax
  801b5c:	6a 00                	push   $0x0
  801b5e:	56                   	push   %esi
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 81 f1 ff ff       	call   800ce7 <sys_page_map>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 20             	add    $0x20,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 4f                	js     801bbe <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b6f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b78:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b84:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b8d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b92:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9f:	e8 e0 f4 ff ff       	call   801084 <fd2num>
  801ba4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ba6:	83 c4 04             	add    $0x4,%esp
  801ba9:	ff 75 ec             	pushl  -0x14(%ebp)
  801bac:	e8 d3 f4 ff ff       	call   801084 <fd2num>
  801bb1:	89 47 04             	mov    %eax,0x4(%edi)
  801bb4:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	eb 2e                	jmp    801bec <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	56                   	push   %esi
  801bc2:	6a 00                	push   $0x0
  801bc4:	e8 dc f0 ff ff       	call   800ca5 <sys_page_unmap>
  801bc9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	ff 75 ec             	pushl  -0x14(%ebp)
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 cc f0 ff ff       	call   800ca5 <sys_page_unmap>
  801bd9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	ff 75 f0             	pushl  -0x10(%ebp)
  801be2:	6a 00                	push   $0x0
  801be4:	e8 bc f0 ff ff       	call   800ca5 <sys_page_unmap>
  801be9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    
	...

00801bf8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801c00:	85 f6                	test   %esi,%esi
  801c02:	75 16                	jne    801c1a <wait+0x22>
  801c04:	68 0e 29 80 00       	push   $0x80290e
  801c09:	68 c3 28 80 00       	push   $0x8028c3
  801c0e:	6a 09                	push   $0x9
  801c10:	68 19 29 80 00       	push   $0x802919
  801c15:	e8 06 e6 ff ff       	call   800220 <_panic>
	e = &envs[ENVX(envid)];
  801c1a:	89 f0                	mov    %esi,%eax
  801c1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c21:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c28:	c1 e0 07             	shl    $0x7,%eax
  801c2b:	29 d0                	sub    %edx,%eax
  801c2d:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  801c33:	eb 05                	jmp    801c3a <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  801c35:	e8 32 f1 ff ff       	call   800d6c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801c3a:	8b 43 48             	mov    0x48(%ebx),%eax
  801c3d:	39 c6                	cmp    %eax,%esi
  801c3f:	75 07                	jne    801c48 <wait+0x50>
  801c41:	8b 43 54             	mov    0x54(%ebx),%eax
  801c44:	85 c0                	test   %eax,%eax
  801c46:	75 ed                	jne    801c35 <wait+0x3d>
		sys_yield();
}
  801c48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4b:	5b                   	pop    %ebx
  801c4c:	5e                   	pop    %esi
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    
	...

00801c50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c53:	b8 00 00 00 00       	mov    $0x0,%eax
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c60:	68 24 29 80 00       	push   $0x802924
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	e8 a6 eb ff ff       	call   800813 <strcpy>
	return 0;
}
  801c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	57                   	push   %edi
  801c78:	56                   	push   %esi
  801c79:	53                   	push   %ebx
  801c7a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801c80:	be 00 00 00 00       	mov    $0x0,%esi
  801c85:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801c8b:	eb 2c                	jmp    801cb9 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c90:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c92:	83 fb 7f             	cmp    $0x7f,%ebx
  801c95:	76 05                	jbe    801c9c <devcons_write+0x28>
  801c97:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	53                   	push   %ebx
  801ca0:	03 45 0c             	add    0xc(%ebp),%eax
  801ca3:	50                   	push   %eax
  801ca4:	57                   	push   %edi
  801ca5:	e8 d6 ec ff ff       	call   800980 <memmove>
		sys_cputs(buf, m);
  801caa:	83 c4 08             	add    $0x8,%esp
  801cad:	53                   	push   %ebx
  801cae:	57                   	push   %edi
  801caf:	e8 a3 ee ff ff       	call   800b57 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb4:	01 de                	add    %ebx,%esi
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cbe:	72 cd                	jb     801c8d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cd4:	6a 01                	push   $0x1
  801cd6:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	e8 78 ee ff ff       	call   800b57 <sys_cputs>
  801cdf:	83 c4 10             	add    $0x10,%esp
}
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801cea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cee:	74 27                	je     801d17 <devcons_read+0x33>
  801cf0:	eb 05                	jmp    801cf7 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cf2:	e8 75 f0 ff ff       	call   800d6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cf7:	e8 3c ee ff ff       	call   800b38 <sys_cgetc>
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	74 f0                	je     801cf2 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 16                	js     801d1c <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d06:	83 f8 04             	cmp    $0x4,%eax
  801d09:	74 0c                	je     801d17 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0e:	88 10                	mov    %dl,(%eax)
  801d10:	ba 01 00 00 00       	mov    $0x1,%edx
  801d15:	eb 05                	jmp    801d1c <devcons_read+0x38>
	return 1;
  801d17:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d1c:	89 d0                	mov    %edx,%eax
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d26:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d29:	50                   	push   %eax
  801d2a:	e8 7d f3 ff ff       	call   8010ac <fd_alloc>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 3b                	js     801d71 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	68 07 04 00 00       	push   $0x407
  801d3e:	ff 75 fc             	pushl  -0x4(%ebp)
  801d41:	6a 00                	push   $0x0
  801d43:	e8 e1 ef ff ff       	call   800d29 <sys_page_alloc>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	78 22                	js     801d71 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d4f:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d54:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801d57:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d63:	83 ec 0c             	sub    $0xc,%esp
  801d66:	ff 75 fc             	pushl  -0x4(%ebp)
  801d69:	e8 16 f3 ff ff       	call   801084 <fd2num>
  801d6e:	83 c4 10             	add    $0x10,%esp
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d79:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	ff 75 08             	pushl  0x8(%ebp)
  801d80:	e8 7a f3 ff ff       	call   8010ff <fd_lookup>
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 11                	js     801d9d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d8f:	8b 00                	mov    (%eax),%eax
  801d91:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801d97:	0f 94 c0             	sete   %al
  801d9a:	0f b6 c0             	movzbl %al,%eax
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801da5:	6a 01                	push   $0x1
  801da7:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	6a 00                	push   $0x0
  801dad:	e8 8c f5 ff ff       	call   80133e <read>
	if (r < 0)
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 0f                	js     801dc8 <getchar+0x29>
		return r;
	if (r < 1)
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	75 07                	jne    801dc4 <getchar+0x25>
  801dbd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dc2:	eb 04                	jmp    801dc8 <getchar+0x29>
		return -E_EOF;
	return c;
  801dc4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    
	...

00801dcc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd9:	75 64                	jne    801e3f <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801ddb:	a1 20 44 80 00       	mov    0x804420,%eax
  801de0:	8b 40 48             	mov    0x48(%eax),%eax
  801de3:	83 ec 04             	sub    $0x4,%esp
  801de6:	6a 07                	push   $0x7
  801de8:	68 00 f0 bf ee       	push   $0xeebff000
  801ded:	50                   	push   %eax
  801dee:	e8 36 ef ff ff       	call   800d29 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	85 c0                	test   %eax,%eax
  801df8:	79 14                	jns    801e0e <set_pgfault_handler+0x42>
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	68 30 29 80 00       	push   $0x802930
  801e02:	6a 22                	push   $0x22
  801e04:	68 99 29 80 00       	push   $0x802999
  801e09:	e8 12 e4 ff ff       	call   800220 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  801e0e:	a1 20 44 80 00       	mov    0x804420,%eax
  801e13:	8b 40 48             	mov    0x48(%eax),%eax
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	68 4c 1e 80 00       	push   $0x801e4c
  801e1e:	50                   	push   %eax
  801e1f:	e8 bb ed ff ff       	call   800bdf <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	79 14                	jns    801e3f <set_pgfault_handler+0x73>
  801e2b:	83 ec 04             	sub    $0x4,%esp
  801e2e:	68 60 29 80 00       	push   $0x802960
  801e33:	6a 25                	push   $0x25
  801e35:	68 99 29 80 00       	push   $0x802999
  801e3a:	e8 e1 e3 ff ff       	call   800220 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e42:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e47:	c9                   	leave  
  801e48:	c3                   	ret    
  801e49:	00 00                	add    %al,(%eax)
	...

00801e4c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e4c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e4d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e52:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e54:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801e57:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e5b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e5e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801e62:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801e66:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801e68:	83 c4 08             	add    $0x8,%esp
	popal
  801e6b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e6c:	83 c4 04             	add    $0x4,%esp
	popfl
  801e6f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e70:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801e71:	c3                   	ret    
	...

00801e74 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	53                   	push   %ebx
  801e78:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e7b:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e80:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801e87:	89 c8                	mov    %ecx,%eax
  801e89:	c1 e0 07             	shl    $0x7,%eax
  801e8c:	29 d0                	sub    %edx,%eax
  801e8e:	89 c2                	mov    %eax,%edx
  801e90:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801e96:	8b 40 50             	mov    0x50(%eax),%eax
  801e99:	39 d8                	cmp    %ebx,%eax
  801e9b:	75 0b                	jne    801ea8 <ipc_find_env+0x34>
			return envs[i].env_id;
  801e9d:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801ea3:	8b 40 40             	mov    0x40(%eax),%eax
  801ea6:	eb 0e                	jmp    801eb6 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ea8:	41                   	inc    %ecx
  801ea9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801eaf:	75 cf                	jne    801e80 <ipc_find_env+0xc>
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801eb6:	5b                   	pop    %ebx
  801eb7:	c9                   	leave  
  801eb8:	c3                   	ret    

00801eb9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	57                   	push   %edi
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ecb:	85 db                	test   %ebx,%ebx
  801ecd:	75 05                	jne    801ed4 <ipc_send+0x1b>
  801ecf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ed4:	56                   	push   %esi
  801ed5:	53                   	push   %ebx
  801ed6:	57                   	push   %edi
  801ed7:	ff 75 08             	pushl  0x8(%ebp)
  801eda:	e8 dd ec ff ff       	call   800bbc <sys_ipc_try_send>
		if (r == 0) {		//success
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	74 20                	je     801f06 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801ee6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee9:	75 07                	jne    801ef2 <ipc_send+0x39>
			sys_yield();
  801eeb:	e8 7c ee ff ff       	call   800d6c <sys_yield>
  801ef0:	eb e2                	jmp    801ed4 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	68 a8 29 80 00       	push   $0x8029a8
  801efa:	6a 41                	push   $0x41
  801efc:	68 cc 29 80 00       	push   $0x8029cc
  801f01:	e8 1a e3 ff ff       	call   800220 <_panic>
		}
	}
}
  801f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5f                   	pop    %edi
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	75 05                	jne    801f25 <ipc_recv+0x17>
  801f20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	50                   	push   %eax
  801f29:	e8 4d ec ff ff       	call   800b7b <sys_ipc_recv>
	if (r < 0) {				
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	85 c0                	test   %eax,%eax
  801f33:	79 16                	jns    801f4b <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801f35:	85 db                	test   %ebx,%ebx
  801f37:	74 06                	je     801f3f <ipc_recv+0x31>
  801f39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801f3f:	85 f6                	test   %esi,%esi
  801f41:	74 2c                	je     801f6f <ipc_recv+0x61>
  801f43:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f49:	eb 24                	jmp    801f6f <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801f4b:	85 db                	test   %ebx,%ebx
  801f4d:	74 0a                	je     801f59 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801f4f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f54:	8b 40 74             	mov    0x74(%eax),%eax
  801f57:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801f59:	85 f6                	test   %esi,%esi
  801f5b:	74 0a                	je     801f67 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801f5d:	a1 20 44 80 00       	mov    0x804420,%eax
  801f62:	8b 40 78             	mov    0x78(%eax),%eax
  801f65:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801f67:	a1 20 44 80 00       	mov    0x804420,%eax
  801f6c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5e                   	pop    %esi
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    
	...

00801f78 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7e:	89 d0                	mov    %edx,%eax
  801f80:	c1 e8 16             	shr    $0x16,%eax
  801f83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f8a:	a8 01                	test   $0x1,%al
  801f8c:	74 20                	je     801fae <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c1 e8 0c             	shr    $0xc,%eax
  801f93:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f9a:	a8 01                	test   $0x1,%al
  801f9c:	74 10                	je     801fae <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f9e:	c1 e8 0c             	shr    $0xc,%eax
  801fa1:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fa8:	ef 
  801fa9:	0f b7 c0             	movzwl %ax,%eax
  801fac:	eb 05                	jmp    801fb3 <pageref+0x3b>
  801fae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    
  801fb5:	00 00                	add    %al,(%eax)
	...

00801fb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	57                   	push   %edi
  801fbc:	56                   	push   %esi
  801fbd:	83 ec 28             	sub    $0x28,%esp
  801fc0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801fc7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801fce:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd1:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801fd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fd7:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801fd9:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe4:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fe7:	85 ff                	test   %edi,%edi
  801fe9:	75 21                	jne    80200c <__udivdi3+0x54>
    {
      if (d0 > n1)
  801feb:	39 d1                	cmp    %edx,%ecx
  801fed:	76 49                	jbe    802038 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fef:	f7 f1                	div    %ecx
  801ff1:	89 c1                	mov    %eax,%ecx
  801ff3:	31 c0                	xor    %eax,%eax
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ff8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801ffb:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ffe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802001:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802004:	83 c4 28             	add    $0x28,%esp
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	c9                   	leave  
  80200a:	c3                   	ret    
  80200b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80200c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80200f:	0f 87 97 00 00 00    	ja     8020ac <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802015:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802018:	83 f0 1f             	xor    $0x1f,%eax
  80201b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80201e:	75 34                	jne    802054 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802020:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802023:	72 08                	jb     80202d <__udivdi3+0x75>
  802025:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802028:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80202b:	77 7f                	ja     8020ac <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80202d:	b9 01 00 00 00       	mov    $0x1,%ecx
  802032:	31 c0                	xor    %eax,%eax
  802034:	eb c2                	jmp    801ff8 <__udivdi3+0x40>
  802036:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203b:	85 c0                	test   %eax,%eax
  80203d:	74 79                	je     8020b8 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80203f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802042:	89 fa                	mov    %edi,%edx
  802044:	f7 f1                	div    %ecx
  802046:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802048:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80204b:	f7 f1                	div    %ecx
  80204d:	89 c1                	mov    %eax,%ecx
  80204f:	89 f0                	mov    %esi,%eax
  802051:	eb a5                	jmp    801ff8 <__udivdi3+0x40>
  802053:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802054:	b8 20 00 00 00       	mov    $0x20,%eax
  802059:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  80205c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80205f:	89 fa                	mov    %edi,%edx
  802061:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802064:	d3 e2                	shl    %cl,%edx
  802066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802069:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80206c:	d3 e8                	shr    %cl,%eax
  80206e:	89 d7                	mov    %edx,%edi
  802070:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802072:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802075:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802078:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80207a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80207d:	d3 e0                	shl    %cl,%eax
  80207f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802082:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802085:	d3 ea                	shr    %cl,%edx
  802087:	09 d0                	or     %edx,%eax
  802089:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80208c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80208f:	d3 ea                	shr    %cl,%edx
  802091:	f7 f7                	div    %edi
  802093:	89 d7                	mov    %edx,%edi
  802095:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802098:	f7 e6                	mul    %esi
  80209a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80209c:	39 d7                	cmp    %edx,%edi
  80209e:	72 38                	jb     8020d8 <__udivdi3+0x120>
  8020a0:	74 27                	je     8020c9 <__udivdi3+0x111>
  8020a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020a5:	31 c0                	xor    %eax,%eax
  8020a7:	e9 4c ff ff ff       	jmp    801ff8 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020ac:	31 c9                	xor    %ecx,%ecx
  8020ae:	31 c0                	xor    %eax,%eax
  8020b0:	e9 43 ff ff ff       	jmp    801ff8 <__udivdi3+0x40>
  8020b5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bd:	31 d2                	xor    %edx,%edx
  8020bf:	f7 75 f4             	divl   -0xc(%ebp)
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	e9 76 ff ff ff       	jmp    80203f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020cc:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8020cf:	d3 e0                	shl    %cl,%eax
  8020d1:	39 f0                	cmp    %esi,%eax
  8020d3:	73 cd                	jae    8020a2 <__udivdi3+0xea>
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020d8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020db:	49                   	dec    %ecx
  8020dc:	31 c0                	xor    %eax,%eax
  8020de:	e9 15 ff ff ff       	jmp    801ff8 <__udivdi3+0x40>
	...

008020e4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	57                   	push   %edi
  8020e8:	56                   	push   %esi
  8020e9:	83 ec 30             	sub    $0x30,%esp
  8020ec:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8020f3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8020fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8020fd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802100:	8b 45 10             	mov    0x10(%ebp),%eax
  802103:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802106:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802109:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80210b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  80210e:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  802111:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802114:	85 d2                	test   %edx,%edx
  802116:	75 1c                	jne    802134 <__umoddi3+0x50>
    {
      if (d0 > n1)
  802118:	89 fa                	mov    %edi,%edx
  80211a:	39 f8                	cmp    %edi,%eax
  80211c:	0f 86 c2 00 00 00    	jbe    8021e4 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802122:	89 f0                	mov    %esi,%eax
  802124:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  802126:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802129:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802130:	eb 12                	jmp    802144 <__umoddi3+0x60>
  802132:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802134:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802137:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  80213a:	76 18                	jbe    802154 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  80213c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  80213f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802142:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802144:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802147:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80214a:	83 c4 30             	add    $0x30,%esp
  80214d:	5e                   	pop    %esi
  80214e:	5f                   	pop    %edi
  80214f:	c9                   	leave  
  802150:	c3                   	ret    
  802151:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802154:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802158:	83 f0 1f             	xor    $0x1f,%eax
  80215b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80215e:	0f 84 ac 00 00 00    	je     802210 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802164:	b8 20 00 00 00       	mov    $0x20,%eax
  802169:	2b 45 dc             	sub    -0x24(%ebp),%eax
  80216c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80216f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802172:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802175:	d3 e2                	shl    %cl,%edx
  802177:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80217a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80217d:	d3 e8                	shr    %cl,%eax
  80217f:	89 d6                	mov    %edx,%esi
  802181:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  802183:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802186:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802189:	d3 e0                	shl    %cl,%eax
  80218b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80218e:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802191:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802193:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802196:	d3 e0                	shl    %cl,%eax
  802198:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80219b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80219e:	d3 ea                	shr    %cl,%edx
  8021a0:	09 d0                	or     %edx,%eax
  8021a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021a5:	d3 ea                	shr    %cl,%edx
  8021a7:	f7 f6                	div    %esi
  8021a9:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8021ac:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021af:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8021b2:	0f 82 8d 00 00 00    	jb     802245 <__umoddi3+0x161>
  8021b8:	0f 84 91 00 00 00    	je     80224f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021be:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021c1:	29 c7                	sub    %eax,%edi
  8021c3:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021c5:	89 f2                	mov    %esi,%edx
  8021c7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021ca:	d3 e2                	shl    %cl,%edx
  8021cc:	89 f8                	mov    %edi,%eax
  8021ce:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021d1:	d3 e8                	shr    %cl,%eax
  8021d3:	09 c2                	or     %eax,%edx
  8021d5:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8021d8:	d3 ee                	shr    %cl,%esi
  8021da:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8021dd:	e9 62 ff ff ff       	jmp    802144 <__umoddi3+0x60>
  8021e2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	74 15                	je     802200 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021f1:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f6:	f7 f1                	div    %ecx
  8021f8:	e9 29 ff ff ff       	jmp    802126 <__umoddi3+0x42>
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802200:	b8 01 00 00 00       	mov    $0x1,%eax
  802205:	31 d2                	xor    %edx,%edx
  802207:	f7 75 ec             	divl   -0x14(%ebp)
  80220a:	89 c1                	mov    %eax,%ecx
  80220c:	eb dd                	jmp    8021eb <__umoddi3+0x107>
  80220e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802210:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802213:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  802216:	72 19                	jb     802231 <__umoddi3+0x14d>
  802218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80221b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80221e:	76 11                	jbe    802231 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  802220:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802223:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  802226:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802229:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80222c:	e9 13 ff ff ff       	jmp    802144 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802231:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802237:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80223a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  80223d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802240:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  802243:	eb db                	jmp    802220 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802245:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802248:	19 f2                	sbb    %esi,%edx
  80224a:	e9 6f ff ff ff       	jmp    8021be <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80224f:	39 c7                	cmp    %eax,%edi
  802251:	72 f2                	jb     802245 <__umoddi3+0x161>
  802253:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802256:	e9 63 ff ff ff       	jmp    8021be <__umoddi3+0xda>
