
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 93 01 00 00       	call   8001c4 <libmain>
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
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 20 22 80 00       	push   $0x802220
  800041:	e8 83 02 00 00       	call   8002c9 <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 5d 1a 00 00       	call   801aae <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 6e 22 80 00       	push   $0x80226e
  80005e:	6a 0d                	push   $0xd
  800060:	68 77 22 80 00       	push   $0x802277
  800065:	e8 be 01 00 00       	call   800228 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 9f 0d 00 00       	call   800e0e <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 8c 22 80 00       	push   $0x80228c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 77 22 80 00       	push   $0x802277
  800082:	e8 a1 01 00 00       	call   800228 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 6a                	jne    8000f5 <umain+0xc1>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	e8 06 14 00 00       	call   80149c <close>
  800096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	eb 10                	jmp    8000b0 <umain+0x7c>
		for (i = 0; i < 200; i++) {
			if (i % 10 == 0)
  8000a0:	ba 0a 00 00 00       	mov    $0xa,%edx
  8000a5:	89 d8                	mov    %ebx,%eax
  8000a7:	89 d1                	mov    %edx,%ecx
  8000a9:	99                   	cltd   
  8000aa:	f7 f9                	idiv   %ecx
  8000ac:	85 d2                	test   %edx,%edx
  8000ae:	75 11                	jne    8000c1 <umain+0x8d>
				cprintf("%d.", i);
  8000b0:	83 ec 08             	sub    $0x8,%esp
  8000b3:	53                   	push   %ebx
  8000b4:	68 95 22 80 00       	push   $0x802295
  8000b9:	e8 0b 02 00 00       	call   8002c9 <cprintf>
  8000be:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 0a                	push   $0xa
  8000c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8000c9:	e8 38 14 00 00       	call   801506 <dup>
			sys_yield();
  8000ce:	e8 a1 0c 00 00       	call   800d74 <sys_yield>
			close(10);
  8000d3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000da:	e8 bd 13 00 00       	call   80149c <close>
			sys_yield();
  8000df:	e8 90 0c 00 00       	call   800d74 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000e4:	43                   	inc    %ebx
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	81 fb c7 00 00 00    	cmp    $0xc7,%ebx
  8000ee:	7e b0                	jle    8000a0 <umain+0x6c>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000f0:	e8 1f 01 00 00       	call   800214 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  8000f5:	89 f0                	mov    %esi,%eax
  8000f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800103:	c1 e0 07             	shl    $0x7,%eax
  800106:	29 d0                	sub    %edx,%eax
  800108:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  80010e:	eb 2f                	jmp    80013f <umain+0x10b>
	while (kid->env_status == ENV_RUNNABLE)
		if (pipeisclosed(p[0]) != 0) {
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	ff 75 f0             	pushl  -0x10(%ebp)
  800116:	e8 60 19 00 00       	call   801a7b <pipeisclosed>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 1d                	je     80013f <umain+0x10b>
			cprintf("\nRACE: pipe appears closed\n");
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	68 99 22 80 00       	push   $0x802299
  80012a:	e8 9a 01 00 00       	call   8002c9 <cprintf>
			sys_env_destroy(r);
  80012f:	89 34 24             	mov    %esi,(%esp)
  800132:	e8 7b 0c 00 00       	call   800db2 <sys_env_destroy>
			exit();
  800137:	e8 d8 00 00 00       	call   800214 <exit>
  80013c:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  80013f:	8b 43 54             	mov    0x54(%ebx),%eax
  800142:	83 f8 02             	cmp    $0x2,%eax
  800145:	74 c9                	je     800110 <umain+0xdc>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 b5 22 80 00       	push   $0x8022b5
  80014f:	e8 75 01 00 00       	call   8002c9 <cprintf>
	if (pipeisclosed(p[0]))
  800154:	83 c4 04             	add    $0x4,%esp
  800157:	ff 75 f0             	pushl  -0x10(%ebp)
  80015a:	e8 1c 19 00 00       	call   801a7b <pipeisclosed>
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	85 c0                	test   %eax,%eax
  800164:	74 14                	je     80017a <umain+0x146>
		panic("somehow the other end of p[0] got closed!");
  800166:	83 ec 04             	sub    $0x4,%esp
  800169:	68 44 22 80 00       	push   $0x802244
  80016e:	6a 40                	push   $0x40
  800170:	68 77 22 80 00       	push   $0x802277
  800175:	e8 ae 00 00 00       	call   800228 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	ff 75 f0             	pushl  -0x10(%ebp)
  800184:	e8 7e 0f 00 00       	call   801107 <fd_lookup>
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	85 c0                	test   %eax,%eax
  80018e:	79 12                	jns    8001a2 <umain+0x16e>
		panic("cannot look up p[0]: %e", r);
  800190:	50                   	push   %eax
  800191:	68 cb 22 80 00       	push   $0x8022cb
  800196:	6a 42                	push   $0x42
  800198:	68 77 22 80 00       	push   $0x802277
  80019d:	e8 86 00 00 00       	call   800228 <_panic>
	(void) fd2data(fd);
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a8:	e8 ef 0e 00 00       	call   80109c <fd2data>
	cprintf("race didn't happen\n");
  8001ad:	c7 04 24 e3 22 80 00 	movl   $0x8022e3,(%esp)
  8001b4:	e8 10 01 00 00       	call   8002c9 <cprintf>
  8001b9:	83 c4 10             	add    $0x10,%esp
}
  8001bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    
	...

008001c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8001cf:	e8 bf 0b 00 00       	call   800d93 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001e0:	c1 e0 07             	shl    $0x7,%eax
  8001e3:	29 d0                	sub    %edx,%eax
  8001e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ea:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ef:	85 f6                	test   %esi,%esi
  8001f1:	7e 07                	jle    8001fa <libmain+0x36>
		binaryname = argv[0];
  8001f3:	8b 03                	mov    (%ebx),%eax
  8001f5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	53                   	push   %ebx
  8001fe:	56                   	push   %esi
  8001ff:	e8 30 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800204:	e8 0b 00 00 00       	call   800214 <exit>
  800209:	83 c4 10             	add    $0x10,%esp
}
  80020c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	c9                   	leave  
  800212:	c3                   	ret    
	...

00800214 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80021a:	6a 00                	push   $0x0
  80021c:	e8 91 0b 00 00       	call   800db2 <sys_env_destroy>
  800221:	83 c4 10             	add    $0x10,%esp
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    
	...

00800228 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80022f:	8d 45 14             	lea    0x14(%ebp),%eax
  800232:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800235:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80023b:	e8 53 0b 00 00       	call   800d93 <sys_getenvid>
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	53                   	push   %ebx
  80024a:	50                   	push   %eax
  80024b:	68 04 23 80 00       	push   $0x802304
  800250:	e8 74 00 00 00       	call   8002c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	ff 75 f8             	pushl  -0x8(%ebp)
  80025b:	ff 75 10             	pushl  0x10(%ebp)
  80025e:	e8 15 00 00 00       	call   800278 <vcprintf>
	cprintf("\n");
  800263:	c7 04 24 67 28 80 00 	movl   $0x802867,(%esp)
  80026a:	e8 5a 00 00 00       	call   8002c9 <cprintf>
  80026f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800272:	cc                   	int3   
  800273:	eb fd                	jmp    800272 <_panic+0x4a>
  800275:	00 00                	add    %al,(%eax)
	...

00800278 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800281:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800288:	00 00 00 
	b.cnt = 0;
  80028b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800292:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a1:	50                   	push   %eax
  8002a2:	68 e0 02 80 00       	push   $0x8002e0
  8002a7:	e8 70 01 00 00       	call   80041c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ac:	83 c4 08             	add    $0x8,%esp
  8002af:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8002b5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002bb:	50                   	push   %eax
  8002bc:	e8 9e 08 00 00       	call   800b5f <sys_cputs>
  8002c1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8002c7:	c9                   	leave  
  8002c8:	c3                   	ret    

008002c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002cf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 9a ff ff ff       	call   800278 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 04             	sub    $0x4,%esp
  8002e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ea:	8b 03                	mov    (%ebx),%eax
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002f3:	40                   	inc    %eax
  8002f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 51 08 00 00       	call   800b5f <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	ff 43 04             	incl   0x4(%ebx)
}
  80031a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    
	...

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 1c             	sub    $0x1c,%esp
  800329:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80032c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80032f:	8b 45 08             	mov    0x8(%ebp),%eax
  800332:	8b 55 0c             	mov    0xc(%ebp),%edx
  800335:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800338:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80033b:	8b 55 10             	mov    0x10(%ebp),%edx
  80033e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	89 d6                	mov    %edx,%esi
  800343:	bf 00 00 00 00       	mov    $0x0,%edi
  800348:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80034b:	72 04                	jb     800351 <printnum+0x31>
  80034d:	39 c2                	cmp    %eax,%edx
  80034f:	77 3f                	ja     800390 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 18             	pushl  0x18(%ebp)
  800357:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80035a:	50                   	push   %eax
  80035b:	52                   	push   %edx
  80035c:	83 ec 08             	sub    $0x8,%esp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	ff 75 e4             	pushl  -0x1c(%ebp)
  800364:	ff 75 e0             	pushl  -0x20(%ebp)
  800367:	e8 fc 1b 00 00       	call   801f68 <__udivdi3>
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	52                   	push   %edx
  800370:	50                   	push   %eax
  800371:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800374:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800377:	e8 a4 ff ff ff       	call   800320 <printnum>
  80037c:	83 c4 20             	add    $0x20,%esp
  80037f:	eb 14                	jmp    800395 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	ff 75 e8             	pushl  -0x18(%ebp)
  800387:	ff 75 18             	pushl  0x18(%ebp)
  80038a:	ff 55 ec             	call   *-0x14(%ebp)
  80038d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800390:	4b                   	dec    %ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ec                	jg     800381 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	ff 75 e8             	pushl  -0x18(%ebp)
  80039b:	83 ec 04             	sub    $0x4,%esp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a6:	e8 e9 1c 00 00       	call   802094 <__umoddi3>
  8003ab:	83 c4 14             	add    $0x14,%esp
  8003ae:	0f be 80 27 23 80 00 	movsbl 0x802327(%eax),%eax
  8003b5:	50                   	push   %eax
  8003b6:	ff 55 ec             	call   *-0x14(%ebp)
  8003b9:	83 c4 10             	add    $0x10,%esp
}
  8003bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bf:	5b                   	pop    %ebx
  8003c0:	5e                   	pop    %esi
  8003c1:	5f                   	pop    %edi
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003c9:	83 fa 01             	cmp    $0x1,%edx
  8003cc:	7e 0e                	jle    8003dc <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 42 08             	lea    0x8(%edx),%eax
  8003d3:	89 01                	mov    %eax,(%ecx)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	eb 22                	jmp    8003fe <getuint+0x3a>
	else if (lflag)
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	74 10                	je     8003f0 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 42 04             	lea    0x4(%edx),%eax
  8003e5:	89 01                	mov    %eax,(%ecx)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 0e                	jmp    8003fe <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 42 04             	lea    0x4(%edx),%eax
  8003f5:	89 01                	mov    %eax,(%ecx)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800406:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800409:	8b 11                	mov    (%ecx),%edx
  80040b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80040e:	73 0a                	jae    80041a <sprintputch+0x1a>
		*b->buf++ = ch;
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
  800413:	88 02                	mov    %al,(%edx)
  800415:	8d 42 01             	lea    0x1(%edx),%eax
  800418:	89 01                	mov    %eax,(%ecx)
}
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	57                   	push   %edi
  800420:	56                   	push   %esi
  800421:	53                   	push   %ebx
  800422:	83 ec 3c             	sub    $0x3c,%esp
  800425:	8b 75 08             	mov    0x8(%ebp),%esi
  800428:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80042b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80042e:	eb 1a                	jmp    80044a <vprintfmt+0x2e>
  800430:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800433:	eb 15                	jmp    80044a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800435:	84 c0                	test   %al,%al
  800437:	0f 84 15 03 00 00    	je     800752 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	57                   	push   %edi
  800441:	0f b6 c0             	movzbl %al,%eax
  800444:	50                   	push   %eax
  800445:	ff d6                	call   *%esi
  800447:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044a:	8a 03                	mov    (%ebx),%al
  80044c:	43                   	inc    %ebx
  80044d:	3c 25                	cmp    $0x25,%al
  80044f:	75 e4                	jne    800435 <vprintfmt+0x19>
  800451:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800458:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80045f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800466:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80046d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800471:	eb 0a                	jmp    80047d <vprintfmt+0x61>
  800473:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80047a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8a 03                	mov    (%ebx),%al
  80047f:	0f b6 d0             	movzbl %al,%edx
  800482:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800485:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800488:	83 e8 23             	sub    $0x23,%eax
  80048b:	3c 55                	cmp    $0x55,%al
  80048d:	0f 87 9c 02 00 00    	ja     80072f <vprintfmt+0x313>
  800493:	0f b6 c0             	movzbl %al,%eax
  800496:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  80049d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8004a1:	eb d7                	jmp    80047a <vprintfmt+0x5e>
  8004a3:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8004a7:	eb d1                	jmp    80047a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8004a9:	89 d9                	mov    %ebx,%ecx
  8004ab:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004b5:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004b8:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8004bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8004bf:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8004c3:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8004c4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004c7:	83 f8 09             	cmp    $0x9,%eax
  8004ca:	77 21                	ja     8004ed <vprintfmt+0xd1>
  8004cc:	eb e4                	jmp    8004b2 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ce:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d1:	8d 42 04             	lea    0x4(%edx),%eax
  8004d4:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d7:	8b 12                	mov    (%edx),%edx
  8004d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004dc:	eb 12                	jmp    8004f0 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8004de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e2:	79 96                	jns    80047a <vprintfmt+0x5e>
  8004e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004eb:	eb 8d                	jmp    80047a <vprintfmt+0x5e>
  8004ed:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f4:	79 84                	jns    80047a <vprintfmt+0x5e>
  8004f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fc:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800503:	e9 72 ff ff ff       	jmp    80047a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800508:	ff 45 d4             	incl   -0x2c(%ebp)
  80050b:	e9 6a ff ff ff       	jmp    80047a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800510:	8b 55 14             	mov    0x14(%ebp),%edx
  800513:	8d 42 04             	lea    0x4(%edx),%eax
  800516:	89 45 14             	mov    %eax,0x14(%ebp)
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	ff 32                	pushl  (%edx)
  80051f:	ff d6                	call   *%esi
			break;
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	e9 07 ff ff ff       	jmp    800430 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800529:	8b 55 14             	mov    0x14(%ebp),%edx
  80052c:	8d 42 04             	lea    0x4(%edx),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
  800532:	8b 02                	mov    (%edx),%eax
  800534:	85 c0                	test   %eax,%eax
  800536:	79 02                	jns    80053a <vprintfmt+0x11e>
  800538:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053a:	83 f8 0f             	cmp    $0xf,%eax
  80053d:	7f 0b                	jg     80054a <vprintfmt+0x12e>
  80053f:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800546:	85 d2                	test   %edx,%edx
  800548:	75 15                	jne    80055f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80054a:	50                   	push   %eax
  80054b:	68 38 23 80 00       	push   $0x802338
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	e8 6e 02 00 00       	call   8007c5 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	e9 d1 fe ff ff       	jmp    800430 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80055f:	52                   	push   %edx
  800560:	68 35 28 80 00       	push   $0x802835
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	e8 59 02 00 00       	call   8007c5 <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	e9 bc fe ff ff       	jmp    800430 <vprintfmt+0x14>
  800574:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800577:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80057a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057d:	8b 55 14             	mov    0x14(%ebp),%edx
  800580:	8d 42 04             	lea    0x4(%edx),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
  800586:	8b 1a                	mov    (%edx),%ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	75 05                	jne    800591 <vprintfmt+0x175>
  80058c:	bb 41 23 80 00       	mov    $0x802341,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800591:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800595:	7e 66                	jle    8005fd <vprintfmt+0x1e1>
  800597:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80059b:	74 60                	je     8005fd <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	51                   	push   %ecx
  8005a1:	53                   	push   %ebx
  8005a2:	e8 57 02 00 00       	call   8007fe <strnlen>
  8005a7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005aa:	29 c1                	sub    %eax,%ecx
  8005ac:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005b9:	eb 0f                	jmp    8005ca <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	ff 75 c4             	pushl  -0x3c(%ebp)
  8005c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	ff 4d d8             	decl   -0x28(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ce:	7f eb                	jg     8005bb <vprintfmt+0x19f>
  8005d0:	eb 2b                	jmp    8005fd <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	74 15                	je     8005f0 <vprintfmt+0x1d4>
  8005db:	8d 42 e0             	lea    -0x20(%edx),%eax
  8005de:	83 f8 5e             	cmp    $0x5e,%eax
  8005e1:	76 0d                	jbe    8005f0 <vprintfmt+0x1d4>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	57                   	push   %edi
  8005e7:	6a 3f                	push   $0x3f
  8005e9:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb 0a                	jmp    8005fa <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	57                   	push   %edi
  8005f4:	52                   	push   %edx
  8005f5:	ff d6                	call   *%esi
  8005f7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fa:	ff 4d d8             	decl   -0x28(%ebp)
  8005fd:	8a 03                	mov    (%ebx),%al
  8005ff:	43                   	inc    %ebx
  800600:	84 c0                	test   %al,%al
  800602:	74 1b                	je     80061f <vprintfmt+0x203>
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	78 c8                	js     8005d2 <vprintfmt+0x1b6>
  80060a:	ff 4d dc             	decl   -0x24(%ebp)
  80060d:	79 c3                	jns    8005d2 <vprintfmt+0x1b6>
  80060f:	eb 0e                	jmp    80061f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	57                   	push   %edi
  800615:	6a 20                	push   $0x20
  800617:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800619:	ff 4d d8             	decl   -0x28(%ebp)
  80061c:	83 c4 10             	add    $0x10,%esp
  80061f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800623:	7f ec                	jg     800611 <vprintfmt+0x1f5>
  800625:	e9 06 fe ff ff       	jmp    800430 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80062e:	7e 10                	jle    800640 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800630:	8b 55 14             	mov    0x14(%ebp),%edx
  800633:	8d 42 08             	lea    0x8(%edx),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
  800639:	8b 02                	mov    (%edx),%eax
  80063b:	8b 52 04             	mov    0x4(%edx),%edx
  80063e:	eb 20                	jmp    800660 <vprintfmt+0x244>
	else if (lflag)
  800640:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800644:	74 0e                	je     800654 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	99                   	cltd   
  800652:	eb 0c                	jmp    800660 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800660:	89 d1                	mov    %edx,%ecx
  800662:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800664:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800667:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80066a:	85 c9                	test   %ecx,%ecx
  80066c:	78 0a                	js     800678 <vprintfmt+0x25c>
  80066e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800673:	e9 89 00 00 00       	jmp    800701 <vprintfmt+0x2e5>
				putch('-', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	57                   	push   %edi
  80067c:	6a 2d                	push   $0x2d
  80067e:	ff d6                	call   *%esi
				num = -(long long) num;
  800680:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800683:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800686:	f7 da                	neg    %edx
  800688:	83 d1 00             	adc    $0x0,%ecx
  80068b:	f7 d9                	neg    %ecx
  80068d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	eb 6a                	jmp    800701 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80069d:	e8 22 fd ff ff       	call   8003c4 <getuint>
  8006a2:	89 d1                	mov    %edx,%ecx
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006ab:	eb 54                	jmp    800701 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b3:	e8 0c fd ff ff       	call   8003c4 <getuint>
  8006b8:	89 d1                	mov    %edx,%ecx
  8006ba:	89 c2                	mov    %eax,%edx
  8006bc:	bb 08 00 00 00       	mov    $0x8,%ebx
  8006c1:	eb 3e                	jmp    800701 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	57                   	push   %edi
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	57                   	push   %edi
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d3:	8b 55 14             	mov    0x14(%ebp),%edx
  8006d6:	8d 42 04             	lea    0x4(%edx),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dc:	8b 12                	mov    (%edx),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e3:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 14                	jmp    800701 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006f3:	e8 cc fc ff ff       	call   8003c4 <getuint>
  8006f8:	89 d1                	mov    %edx,%ecx
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	ff 75 d8             	pushl  -0x28(%ebp)
  80070c:	53                   	push   %ebx
  80070d:	51                   	push   %ecx
  80070e:	52                   	push   %edx
  80070f:	89 fa                	mov    %edi,%edx
  800711:	89 f0                	mov    %esi,%eax
  800713:	e8 08 fc ff ff       	call   800320 <printnum>
			break;
  800718:	83 c4 20             	add    $0x20,%esp
  80071b:	e9 10 fd ff ff       	jmp    800430 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	57                   	push   %edi
  800724:	52                   	push   %edx
  800725:	ff d6                	call   *%esi
			break;
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	e9 01 fd ff ff       	jmp    800430 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	57                   	push   %edi
  800733:	6a 25                	push   $0x25
  800735:	ff d6                	call   *%esi
  800737:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80073a:	83 ea 02             	sub    $0x2,%edx
  80073d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	8a 02                	mov    (%edx),%al
  800742:	4a                   	dec    %edx
  800743:	3c 25                	cmp    $0x25,%al
  800745:	75 f9                	jne    800740 <vprintfmt+0x324>
  800747:	83 c2 02             	add    $0x2,%edx
  80074a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80074d:	e9 de fc ff ff       	jmp    800430 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 18             	sub    $0x18,%esp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
  800763:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800766:	85 d2                	test   %edx,%edx
  800768:	74 37                	je     8007a1 <vsnprintf+0x47>
  80076a:	85 c0                	test   %eax,%eax
  80076c:	7e 33                	jle    8007a1 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800775:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800779:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80077c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	ff 75 14             	pushl  0x14(%ebp)
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800788:	50                   	push   %eax
  800789:	68 00 04 80 00       	push   $0x800400
  80078e:	e8 89 fc ff ff       	call   80041c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800799:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x4c>
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007b4:	50                   	push   %eax
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	ff 75 08             	pushl  0x8(%ebp)
  8007be:	e8 97 ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 3c fc ff ff       	call   80041c <vprintfmt>
	va_end(ap);
  8007e0:	83 c4 10             	add    $0x10,%esp
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800824:	8a 01                	mov    (%ecx),%al
  800826:	88 02                	mov    %al,(%edx)
  800828:	42                   	inc    %edx
  800829:	41                   	inc    %ecx
  80082a:	84 c0                	test   %al,%al
  80082c:	75 f6                	jne    800824 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 a8 ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800846:	50                   	push   %eax
  800847:	e8 cf ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800861:	b9 00 00 00 00       	mov    $0x0,%ecx
  800866:	eb 0c                	jmp    800874 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800868:	8a 02                	mov    (%edx),%al
  80086a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 3a 01             	cmpb   $0x1,(%edx)
  800870:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800873:	41                   	inc    %ecx
  800874:	39 d9                	cmp    %ebx,%ecx
  800876:	75 f0                	jne    800868 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	75 04                	jne    800894 <strlcpy+0x16>
  800890:	89 f0                	mov    %esi,%eax
  800892:	eb 14                	jmp    8008a8 <strlcpy+0x2a>
  800894:	89 f0                	mov    %esi,%eax
  800896:	eb 04                	jmp    80089c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800898:	88 10                	mov    %dl,(%eax)
  80089a:	40                   	inc    %eax
  80089b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089c:	49                   	dec    %ecx
  80089d:	74 06                	je     8008a5 <strlcpy+0x27>
  80089f:	8a 13                	mov    (%ebx),%dl
  8008a1:	84 d2                	test   %dl,%dl
  8008a3:	75 f3                	jne    800898 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008a5:	c6 00 00             	movb   $0x0,(%eax)
  8008a8:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b7:	eb 02                	jmp    8008bb <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8008b9:	42                   	inc    %edx
  8008ba:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	8a 02                	mov    (%edx),%al
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x17>
  8008c1:	3a 01                	cmp    (%ecx),%al
  8008c3:	74 f4                	je     8008b9 <strcmp+0xb>
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 11             	movzbl (%ecx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
  8008dc:	eb 03                	jmp    8008e1 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8008de:	4a                   	dec    %edx
  8008df:	41                   	inc    %ecx
  8008e0:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	75 07                	jne    8008ec <strncmp+0x1d>
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb 14                	jmp    800900 <strncmp+0x31>
  8008ec:	8a 01                	mov    (%ecx),%al
  8008ee:	84 c0                	test   %al,%al
  8008f0:	74 04                	je     8008f6 <strncmp+0x27>
  8008f2:	3a 03                	cmp    (%ebx),%al
  8008f4:	74 e8                	je     8008de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 d0             	movzbl %al,%edx
  8008f9:	0f b6 03             	movzbl (%ebx),%eax
  8008fc:	29 c2                	sub    %eax,%edx
  8008fe:	89 d0                	mov    %edx,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80090c:	eb 05                	jmp    800913 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0c                	je     80091e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	40                   	inc    %eax
  800913:	8a 10                	mov    (%eax),%dl
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f5                	jne    80090e <strchr+0xb>
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800929:	eb 05                	jmp    800930 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80092b:	38 ca                	cmp    %cl,%dl
  80092d:	74 07                	je     800936 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092f:	40                   	inc    %eax
  800930:	8a 10                	mov    (%eax),%dl
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f5                	jne    80092b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 45 0c             	mov    0xc(%ebp),%eax
  800944:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800947:	85 db                	test   %ebx,%ebx
  800949:	74 36                	je     800981 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800951:	75 29                	jne    80097c <memset+0x44>
  800953:	f6 c3 03             	test   $0x3,%bl
  800956:	75 24                	jne    80097c <memset+0x44>
		c &= 0xFF;
  800958:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80095b:	89 d6                	mov    %edx,%esi
  80095d:	c1 e6 08             	shl    $0x8,%esi
  800960:	89 d0                	mov    %edx,%eax
  800962:	c1 e0 18             	shl    $0x18,%eax
  800965:	89 d1                	mov    %edx,%ecx
  800967:	c1 e1 10             	shl    $0x10,%ecx
  80096a:	09 c8                	or     %ecx,%eax
  80096c:	09 c2                	or     %eax,%edx
  80096e:	89 f0                	mov    %esi,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	89 d9                	mov    %ebx,%ecx
  800974:	c1 e9 02             	shr    $0x2,%ecx
  800977:	fc                   	cld    
  800978:	f3 ab                	rep stos %eax,%es:(%edi)
  80097a:	eb 05                	jmp    800981 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097c:	89 d9                	mov    %ebx,%ecx
  80097e:	fc                   	cld    
  80097f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800981:	89 f8                	mov    %edi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800993:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800996:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800998:	39 c6                	cmp    %eax,%esi
  80099a:	73 36                	jae    8009d2 <memmove+0x4a>
  80099c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099f:	39 d0                	cmp    %edx,%eax
  8009a1:	73 2f                	jae    8009d2 <memmove+0x4a>
		s += n;
		d += n;
  8009a3:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	f6 c2 03             	test   $0x3,%dl
  8009a9:	75 1b                	jne    8009c6 <memmove+0x3e>
  8009ab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b1:	75 13                	jne    8009c6 <memmove+0x3e>
  8009b3:	f6 c1 03             	test   $0x3,%cl
  8009b6:	75 0e                	jne    8009c6 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8009b8:	8d 7e fc             	lea    -0x4(%esi),%edi
  8009bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009be:	c1 e9 02             	shr    $0x2,%ecx
  8009c1:	fd                   	std    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 09                	jmp    8009cf <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c6:	8d 7e ff             	lea    -0x1(%esi),%edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 20                	jmp    8009f2 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 15                	jne    8009ef <memmove+0x67>
  8009da:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e0:	75 0d                	jne    8009ef <memmove+0x67>
  8009e2:	f6 c1 03             	test   $0x3,%cl
  8009e5:	75 08                	jne    8009ef <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
  8009ea:	fc                   	cld    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 03                	jmp    8009f2 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f9:	ff 75 10             	pushl  0x10(%ebp)
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	ff 75 08             	pushl  0x8(%ebp)
  800a02:	e8 81 ff ff ff       	call   800988 <memmove>
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 04             	sub    $0x4,%esp
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	eb 1b                	jmp    800a36 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800a1b:	8a 1a                	mov    (%edx),%bl
  800a1d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800a20:	8a 19                	mov    (%ecx),%bl
  800a22:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800a25:	74 0d                	je     800a34 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800a27:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800a2b:	0f b6 c3             	movzbl %bl,%eax
  800a2e:	29 c2                	sub    %eax,%edx
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	eb 0d                	jmp    800a41 <memcmp+0x38>
		s1++, s2++;
  800a34:	42                   	inc    %edx
  800a35:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a36:	48                   	dec    %eax
  800a37:	83 f8 ff             	cmp    $0xffffffff,%eax
  800a3a:	75 df                	jne    800a1b <memcmp+0x12>
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a41:	83 c4 04             	add    $0x4,%esp
  800a44:	5b                   	pop    %ebx
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a50:	89 c2                	mov    %eax,%edx
  800a52:	03 55 10             	add    0x10(%ebp),%edx
  800a55:	eb 05                	jmp    800a5c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	40                   	inc    %eax
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	72 f7                	jb     800a57 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	83 ec 04             	sub    $0x4,%esp
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	8b 75 10             	mov    0x10(%ebp),%esi
  800a71:	eb 01                	jmp    800a74 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a73:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	8a 01                	mov    (%ecx),%al
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 f9                	je     800a73 <strtol+0x11>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	74 f5                	je     800a73 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7e:	3c 2b                	cmp    $0x2b,%al
  800a80:	75 0a                	jne    800a8c <strtol+0x2a>
		s++;
  800a82:	41                   	inc    %ecx
  800a83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a8a:	eb 17                	jmp    800aa3 <strtol+0x41>
	else if (*s == '-')
  800a8c:	3c 2d                	cmp    $0x2d,%al
  800a8e:	74 09                	je     800a99 <strtol+0x37>
  800a90:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a97:	eb 0a                	jmp    800aa3 <strtol+0x41>
		s++, neg = 1;
  800a99:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a9c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa3:	85 f6                	test   %esi,%esi
  800aa5:	74 05                	je     800aac <strtol+0x4a>
  800aa7:	83 fe 10             	cmp    $0x10,%esi
  800aaa:	75 1a                	jne    800ac6 <strtol+0x64>
  800aac:	8a 01                	mov    (%ecx),%al
  800aae:	3c 30                	cmp    $0x30,%al
  800ab0:	75 10                	jne    800ac2 <strtol+0x60>
  800ab2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab6:	75 0a                	jne    800ac2 <strtol+0x60>
		s += 2, base = 16;
  800ab8:	83 c1 02             	add    $0x2,%ecx
  800abb:	be 10 00 00 00       	mov    $0x10,%esi
  800ac0:	eb 04                	jmp    800ac6 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800ac2:	85 f6                	test   %esi,%esi
  800ac4:	74 07                	je     800acd <strtol+0x6b>
  800ac6:	bf 00 00 00 00       	mov    $0x0,%edi
  800acb:	eb 13                	jmp    800ae0 <strtol+0x7e>
  800acd:	3c 30                	cmp    $0x30,%al
  800acf:	74 07                	je     800ad8 <strtol+0x76>
  800ad1:	be 0a 00 00 00       	mov    $0xa,%esi
  800ad6:	eb ee                	jmp    800ac6 <strtol+0x64>
		s++, base = 8;
  800ad8:	41                   	inc    %ecx
  800ad9:	be 08 00 00 00       	mov    $0x8,%esi
  800ade:	eb e6                	jmp    800ac6 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae0:	8a 11                	mov    (%ecx),%dl
  800ae2:	88 d3                	mov    %dl,%bl
  800ae4:	8d 42 d0             	lea    -0x30(%edx),%eax
  800ae7:	3c 09                	cmp    $0x9,%al
  800ae9:	77 08                	ja     800af3 <strtol+0x91>
			dig = *s - '0';
  800aeb:	0f be c2             	movsbl %dl,%eax
  800aee:	8d 50 d0             	lea    -0x30(%eax),%edx
  800af1:	eb 1c                	jmp    800b0f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af3:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800af6:	3c 19                	cmp    $0x19,%al
  800af8:	77 08                	ja     800b02 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800afa:	0f be c2             	movsbl %dl,%eax
  800afd:	8d 50 a9             	lea    -0x57(%eax),%edx
  800b00:	eb 0d                	jmp    800b0f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800b05:	3c 19                	cmp    $0x19,%al
  800b07:	77 15                	ja     800b1e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800b09:	0f be c2             	movsbl %dl,%eax
  800b0c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800b0f:	39 f2                	cmp    %esi,%edx
  800b11:	7d 0b                	jge    800b1e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800b13:	41                   	inc    %ecx
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	0f af c6             	imul   %esi,%eax
  800b19:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800b1c:	eb c2                	jmp    800ae0 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800b1e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 05                	je     800b2b <strtol+0xc9>
		*endptr = (char *) s;
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800b2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b2f:	74 04                	je     800b35 <strtol+0xd3>
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	f7 df                	neg    %edi
}
  800b35:	89 f8                	mov    %edi,%eax
  800b37:	83 c4 04             	add    $0x4,%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    
	...

00800b40 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b50:	89 fa                	mov    %edi,%edx
  800b52:	89 f9                	mov    %edi,%ecx
  800b54:	89 fb                	mov    %edi,%ebx
  800b56:	89 fe                	mov    %edi,%esi
  800b58:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b73:	89 f8                	mov    %edi,%eax
  800b75:	89 fb                	mov    %edi,%ebx
  800b77:	89 fe                	mov    %edi,%esi
  800b79:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7b:	83 c4 04             	add    $0x4,%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b94:	bf 00 00 00 00       	mov    $0x0,%edi
  800b99:	89 f9                	mov    %edi,%ecx
  800b9b:	89 fb                	mov    %edi,%ebx
  800b9d:	89 fe                	mov    %edi,%esi
  800b9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 17                	jle    800bbc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	50                   	push   %eax
  800ba9:	6a 0d                	push   $0xd
  800bab:	68 1f 26 80 00       	push   $0x80261f
  800bb0:	6a 23                	push   $0x23
  800bb2:	68 3c 26 80 00       	push   $0x80263c
  800bb7:	e8 6c f6 ff ff       	call   800228 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800bbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd3:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bdb:	be 00 00 00 00       	mov    $0x0,%esi
  800be0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800bf6:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c08:	7e 17                	jle    800c21 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 0a                	push   $0xa
  800c10:	68 1f 26 80 00       	push   $0x80261f
  800c15:	6a 23                	push   $0x23
  800c17:	68 3c 26 80 00       	push   $0x80263c
  800c1c:	e8 07 f6 ff ff       	call   800228 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c38:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800c4a:	7e 17                	jle    800c63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 09                	push   $0x9
  800c52:	68 1f 26 80 00       	push   $0x80261f
  800c57:	6a 23                	push   $0x23
  800c59:	68 3c 26 80 00       	push   $0x80263c
  800c5e:	e8 c5 f5 ff ff       	call   800228 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c84:	89 fb                	mov    %edi,%ebx
  800c86:	89 fe                	mov    %edi,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 08                	push   $0x8
  800c94:	68 1f 26 80 00       	push   $0x80261f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 3c 26 80 00       	push   $0x80263c
  800ca0:	e8 83 f5 ff ff       	call   800228 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc6:	89 fb                	mov    %edi,%ebx
  800cc8:	89 fe                	mov    %edi,%esi
  800cca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 17                	jle    800ce7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 06                	push   $0x6
  800cd6:	68 1f 26 80 00       	push   $0x80261f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 3c 26 80 00       	push   $0x80263c
  800ce2:	e8 41 f5 ff ff       	call   800228 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d01:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d04:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7e 17                	jle    800d29 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 05                	push   $0x5
  800d18:	68 1f 26 80 00       	push   $0x80261f
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 3c 26 80 00       	push   $0x80263c
  800d24:	e8 ff f4 ff ff       	call   800228 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	b8 04 00 00 00       	mov    $0x4,%eax
  800d48:	bf 00 00 00 00       	mov    $0x0,%edi
  800d4d:	89 fe                	mov    %edi,%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 04                	push   $0x4
  800d5b:	68 1f 26 80 00       	push   $0x80261f
  800d60:	6a 23                	push   $0x23
  800d62:	68 3c 26 80 00       	push   $0x80263c
  800d67:	e8 bc f4 ff ff       	call   800228 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d84:	89 fa                	mov    %edi,%edx
  800d86:	89 f9                	mov    %edi,%ecx
  800d88:	89 fb                	mov    %edi,%ebx
  800d8a:	89 fe                	mov    %edi,%esi
  800d8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800da3:	89 fa                	mov    %edi,%edx
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	89 fb                	mov    %edi,%ebx
  800da9:	89 fe                	mov    %edi,%esi
  800dab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc8:	89 f9                	mov    %edi,%ecx
  800dca:	89 fb                	mov    %edi,%ebx
  800dcc:	89 fe                	mov    %edi,%esi
  800dce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 17                	jle    800deb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 03                	push   $0x3
  800dda:	68 1f 26 80 00       	push   $0x80261f
  800ddf:	6a 23                	push   $0x23
  800de1:	68 3c 26 80 00       	push   $0x80263c
  800de6:	e8 3d f4 ff ff       	call   800228 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
	...

00800df4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dfa:	68 4a 26 80 00       	push   $0x80264a
  800dff:	68 92 00 00 00       	push   $0x92
  800e04:	68 60 26 80 00       	push   $0x802660
  800e09:	e8 1a f4 ff ff       	call   800228 <_panic>

00800e0e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800e17:	68 af 0f 80 00       	push   $0x800faf
  800e1c:	e8 5b 0f 00 00       	call   801d7c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e21:	ba 07 00 00 00       	mov    $0x7,%edx
  800e26:	89 d0                	mov    %edx,%eax
  800e28:	cd 30                	int    $0x30
  800e2a:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	75 25                	jne    800e58 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800e33:	e8 5b ff ff ff       	call   800d93 <sys_getenvid>
  800e38:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e44:	c1 e0 07             	shl    $0x7,%eax
  800e47:	29 d0                	sub    %edx,%eax
  800e49:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e4e:	a3 04 40 80 00       	mov    %eax,0x804004
  800e53:	e9 4d 01 00 00       	jmp    800fa5 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 12                	jns    800e6e <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800e5c:	50                   	push   %eax
  800e5d:	68 6b 26 80 00       	push   $0x80266b
  800e62:	6a 77                	push   $0x77
  800e64:	68 60 26 80 00       	push   $0x802660
  800e69:	e8 ba f3 ff ff       	call   800228 <_panic>
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800e73:	89 d8                	mov    %ebx,%eax
  800e75:	c1 e8 16             	shr    $0x16,%eax
  800e78:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7f:	a8 01                	test   $0x1,%al
  800e81:	0f 84 ab 00 00 00    	je     800f32 <fork+0x124>
  800e87:	89 da                	mov    %ebx,%edx
  800e89:	c1 ea 0c             	shr    $0xc,%edx
  800e8c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e93:	a8 01                	test   $0x1,%al
  800e95:	0f 84 97 00 00 00    	je     800f32 <fork+0x124>
  800e9b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800ea2:	a8 04                	test   $0x4,%al
  800ea4:	0f 84 88 00 00 00    	je     800f32 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800eaa:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800eb1:	89 d6                	mov    %edx,%esi
  800eb3:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800ebe:	a9 02 08 00 00       	test   $0x802,%eax
  800ec3:	74 0f                	je     800ed4 <fork+0xc6>
  800ec5:	f6 c4 04             	test   $0x4,%ah
  800ec8:	75 0a                	jne    800ed4 <fork+0xc6>
		perm &= ~PTE_W;
  800eca:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800ed4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800eda:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	52                   	push   %edx
  800ee1:	56                   	push   %esi
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	6a 00                	push   $0x0
  800ee6:	e8 04 fe ff ff       	call   800cef <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800eeb:	83 c4 20             	add    $0x20,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	79 14                	jns    800f06 <fork+0xf8>
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	68 b4 26 80 00       	push   $0x8026b4
  800efa:	6a 52                	push   $0x52
  800efc:	68 60 26 80 00       	push   $0x802660
  800f01:	e8 22 f3 ff ff       	call   800228 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	ff 75 f0             	pushl  -0x10(%ebp)
  800f0c:	56                   	push   %esi
  800f0d:	6a 00                	push   $0x0
  800f0f:	56                   	push   %esi
  800f10:	6a 00                	push   $0x0
  800f12:	e8 d8 fd ff ff       	call   800cef <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800f17:	83 c4 20             	add    $0x20,%esp
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 14                	jns    800f32 <fork+0x124>
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	68 d8 26 80 00       	push   $0x8026d8
  800f26:	6a 55                	push   $0x55
  800f28:	68 60 26 80 00       	push   $0x802660
  800f2d:	e8 f6 f2 ff ff       	call   800228 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f38:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f3e:	0f 85 2f ff ff ff    	jne    800e73 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800f44:	83 ec 04             	sub    $0x4,%esp
  800f47:	6a 07                	push   $0x7
  800f49:	68 00 f0 bf ee       	push   $0xeebff000
  800f4e:	57                   	push   %edi
  800f4f:	e8 dd fd ff ff       	call   800d31 <sys_page_alloc>
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	79 15                	jns    800f70 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800f5b:	50                   	push   %eax
  800f5c:	68 89 26 80 00       	push   $0x802689
  800f61:	68 83 00 00 00       	push   $0x83
  800f66:	68 60 26 80 00       	push   $0x802660
  800f6b:	e8 b8 f2 ff ff       	call   800228 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	68 fc 1d 80 00       	push   $0x801dfc
  800f78:	57                   	push   %edi
  800f79:	e8 69 fc ff ff       	call   800be7 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800f7e:	83 c4 08             	add    $0x8,%esp
  800f81:	6a 02                	push   $0x2
  800f83:	57                   	push   %edi
  800f84:	e8 e2 fc ff ff       	call   800c6b <sys_env_set_status>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 15                	jns    800fa5 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800f90:	50                   	push   %eax
  800f91:	68 9c 26 80 00       	push   $0x80269c
  800f96:	68 89 00 00 00       	push   $0x89
  800f9b:	68 60 26 80 00       	push   $0x802660
  800fa0:	e8 83 f2 ff ff       	call   800228 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800fb9:	8b 1a                	mov    (%edx),%ebx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	c1 e8 0c             	shr    $0xc,%eax
  800fc0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800fc7:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fcb:	74 05                	je     800fd2 <pgfault+0x23>
  800fcd:	f6 c4 08             	test   $0x8,%ah
  800fd0:	75 14                	jne    800fe6 <pgfault+0x37>
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	68 fc 26 80 00       	push   $0x8026fc
  800fda:	6a 1e                	push   $0x1e
  800fdc:	68 60 26 80 00       	push   $0x802660
  800fe1:	e8 42 f2 ff ff       	call   800228 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	6a 07                	push   $0x7
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 3a fd ff ff       	call   800d31 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	79 14                	jns    801012 <pgfault+0x63>
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	68 28 27 80 00       	push   $0x802728
  801006:	6a 2a                	push   $0x2a
  801008:	68 60 26 80 00       	push   $0x802660
  80100d:	e8 16 f2 ff ff       	call   800228 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  801012:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	68 00 10 00 00       	push   $0x1000
  801020:	53                   	push   %ebx
  801021:	68 00 f0 7f 00       	push   $0x7ff000
  801026:	e8 5d f9 ff ff       	call   800988 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  80102b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801032:	53                   	push   %ebx
  801033:	6a 00                	push   $0x0
  801035:	68 00 f0 7f 00       	push   $0x7ff000
  80103a:	6a 00                	push   $0x0
  80103c:	e8 ae fc ff ff       	call   800cef <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	79 14                	jns    80105c <pgfault+0xad>
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	68 4c 27 80 00       	push   $0x80274c
  801050:	6a 2e                	push   $0x2e
  801052:	68 60 26 80 00       	push   $0x802660
  801057:	e8 cc f1 ff ff       	call   800228 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	68 00 f0 7f 00       	push   $0x7ff000
  801064:	6a 00                	push   $0x0
  801066:	e8 42 fc ff ff       	call   800cad <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 14                	jns    801086 <pgfault+0xd7>
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	68 6c 27 80 00       	push   $0x80276c
  80107a:	6a 32                	push   $0x32
  80107c:	68 60 26 80 00       	push   $0x802660
  801081:	e8 a2 f1 ff ff       	call   800228 <_panic>
	//panic("pgfault not implemented");
}
  801086:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801089:	c9                   	leave  
  80108a:	c3                   	ret    
	...

0080108c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	05 00 00 00 30       	add    $0x30000000,%eax
  801097:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	e8 e5 ff ff ff       	call   80108c <fd2num>
  8010a7:	83 c4 04             	add    $0x4,%esp
  8010aa:	c1 e0 0c             	shl    $0xc,%eax
  8010ad:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	53                   	push   %ebx
  8010b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010bb:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8010c0:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010c2:	89 d0                	mov    %edx,%eax
  8010c4:	c1 e8 16             	shr    $0x16,%eax
  8010c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ce:	a8 01                	test   $0x1,%al
  8010d0:	74 10                	je     8010e2 <fd_alloc+0x2e>
  8010d2:	89 d0                	mov    %edx,%eax
  8010d4:	c1 e8 0c             	shr    $0xc,%eax
  8010d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010de:	a8 01                	test   $0x1,%al
  8010e0:	75 09                	jne    8010eb <fd_alloc+0x37>
			*fd_store = fd;
  8010e2:	89 0b                	mov    %ecx,(%ebx)
  8010e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e9:	eb 19                	jmp    801104 <fd_alloc+0x50>
			return 0;
  8010eb:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f1:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8010f7:	75 c7                	jne    8010c0 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801104:	5b                   	pop    %ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80110d:	83 f8 1f             	cmp    $0x1f,%eax
  801110:	77 35                	ja     801147 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801112:	c1 e0 0c             	shl    $0xc,%eax
  801115:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80111b:	89 d0                	mov    %edx,%eax
  80111d:	c1 e8 16             	shr    $0x16,%eax
  801120:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801127:	a8 01                	test   $0x1,%al
  801129:	74 1c                	je     801147 <fd_lookup+0x40>
  80112b:	89 d0                	mov    %edx,%eax
  80112d:	c1 e8 0c             	shr    $0xc,%eax
  801130:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801137:	a8 01                	test   $0x1,%al
  801139:	74 0c                	je     801147 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80113b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113e:	89 10                	mov    %edx,(%eax)
  801140:	b8 00 00 00 00       	mov    $0x0,%eax
  801145:	eb 05                	jmp    80114c <fd_lookup+0x45>
	return 0;
  801147:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801154:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	ff 75 08             	pushl  0x8(%ebp)
  80115b:	e8 a7 ff ff ff       	call   801107 <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 0e                	js     801175 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116d:	89 50 04             	mov    %edx,0x4(%eax)
  801170:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801184:	ba 00 00 00 00       	mov    $0x0,%edx
  801189:	eb 0e                	jmp    801199 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80118b:	3b 08                	cmp    (%eax),%ecx
  80118d:	75 09                	jne    801198 <dev_lookup+0x21>
			*dev = devtab[i];
  80118f:	89 03                	mov    %eax,(%ebx)
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	eb 31                	jmp    8011c9 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801198:	42                   	inc    %edx
  801199:	8b 04 95 0c 28 80 00 	mov    0x80280c(,%edx,4),%eax
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	75 e7                	jne    80118b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	51                   	push   %ecx
  8011b0:	50                   	push   %eax
  8011b1:	68 90 27 80 00       	push   $0x802790
  8011b6:	e8 0e f1 ff ff       	call   8002c9 <cprintf>
	*dev = 0;
  8011bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c6:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  8011c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 14             	sub    $0x14,%esp
  8011d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	50                   	push   %eax
  8011dc:	ff 75 08             	pushl  0x8(%ebp)
  8011df:	e8 23 ff ff ff       	call   801107 <fd_lookup>
  8011e4:	83 c4 08             	add    $0x8,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 55                	js     801240 <fstat+0x72>
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f5:	ff 30                	pushl  (%eax)
  8011f7:	e8 7b ff ff ff       	call   801177 <dev_lookup>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 3d                	js     801240 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801203:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801206:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80120a:	75 07                	jne    801213 <fstat+0x45>
  80120c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801211:	eb 2d                	jmp    801240 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801213:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801216:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80121d:	00 00 00 
	stat->st_isdir = 0;
  801220:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801227:	00 00 00 
	stat->st_dev = dev;
  80122a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80122d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801233:	83 ec 08             	sub    $0x8,%esp
  801236:	53                   	push   %ebx
  801237:	ff 75 f4             	pushl  -0xc(%ebp)
  80123a:	ff 50 14             	call   *0x14(%eax)
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	53                   	push   %ebx
  801249:	83 ec 14             	sub    $0x14,%esp
  80124c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	53                   	push   %ebx
  801254:	e8 ae fe ff ff       	call   801107 <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 5f                	js     8012bf <ftruncate+0x7a>
  801260:	83 ec 08             	sub    $0x8,%esp
  801263:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126a:	ff 30                	pushl  (%eax)
  80126c:	e8 06 ff ff ff       	call   801177 <dev_lookup>
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	85 c0                	test   %eax,%eax
  801276:	78 47                	js     8012bf <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127f:	75 21                	jne    8012a2 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801281:	a1 04 40 80 00       	mov    0x804004,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	53                   	push   %ebx
  80128d:	50                   	push   %eax
  80128e:	68 b0 27 80 00       	push   $0x8027b0
  801293:	e8 31 f0 ff ff       	call   8002c9 <cprintf>
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	eb 1d                	jmp    8012bf <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012a2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012a5:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8012a9:	75 07                	jne    8012b2 <ftruncate+0x6d>
  8012ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b0:	eb 0d                	jmp    8012bf <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	ff 75 0c             	pushl  0xc(%ebp)
  8012b8:	50                   	push   %eax
  8012b9:	ff 52 18             	call   *0x18(%edx)
  8012bc:	83 c4 10             	add    $0x10,%esp
}
  8012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	53                   	push   %ebx
  8012c8:	83 ec 14             	sub    $0x14,%esp
  8012cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	53                   	push   %ebx
  8012d3:	e8 2f fe ff ff       	call   801107 <fd_lookup>
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 62                	js     801341 <write+0x7d>
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	e8 87 fe ff ff       	call   801177 <dev_lookup>
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 4a                	js     801341 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fe:	75 21                	jne    801321 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801300:	a1 04 40 80 00       	mov    0x804004,%eax
  801305:	8b 40 48             	mov    0x48(%eax),%eax
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	50                   	push   %eax
  80130d:	68 d1 27 80 00       	push   $0x8027d1
  801312:	e8 b2 ef ff ff       	call   8002c9 <cprintf>
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	eb 20                	jmp    801341 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801321:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801324:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801328:	75 07                	jne    801331 <write+0x6d>
  80132a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132f:	eb 10                	jmp    801341 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801331:	83 ec 04             	sub    $0x4,%esp
  801334:	ff 75 10             	pushl  0x10(%ebp)
  801337:	ff 75 0c             	pushl  0xc(%ebp)
  80133a:	50                   	push   %eax
  80133b:	ff 52 0c             	call   *0xc(%edx)
  80133e:	83 c4 10             	add    $0x10,%esp
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	83 ec 14             	sub    $0x14,%esp
  80134d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	53                   	push   %ebx
  801355:	e8 ad fd ff ff       	call   801107 <fd_lookup>
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 67                	js     8013c8 <read+0x82>
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	ff 30                	pushl  (%eax)
  80136d:	e8 05 fe ff ff       	call   801177 <dev_lookup>
  801372:	83 c4 10             	add    $0x10,%esp
  801375:	85 c0                	test   %eax,%eax
  801377:	78 4f                	js     8013c8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801379:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80137c:	8b 42 08             	mov    0x8(%edx),%eax
  80137f:	83 e0 03             	and    $0x3,%eax
  801382:	83 f8 01             	cmp    $0x1,%eax
  801385:	75 21                	jne    8013a8 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801387:	a1 04 40 80 00       	mov    0x804004,%eax
  80138c:	8b 40 48             	mov    0x48(%eax),%eax
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	53                   	push   %ebx
  801393:	50                   	push   %eax
  801394:	68 ee 27 80 00       	push   $0x8027ee
  801399:	e8 2b ef ff ff       	call   8002c9 <cprintf>
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	eb 20                	jmp    8013c8 <read+0x82>
	}
	if (!dev->dev_read)
  8013a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013ab:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8013af:	75 07                	jne    8013b8 <read+0x72>
  8013b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013b6:	eb 10                	jmp    8013c8 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	ff 75 10             	pushl  0x10(%ebp)
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	52                   	push   %edx
  8013c2:	ff 50 08             	call   *0x8(%eax)
  8013c5:	83 c4 10             	add    $0x10,%esp
}
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 0c             	sub    $0xc,%esp
  8013d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8013dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e1:	eb 21                	jmp    801404 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	89 f0                	mov    %esi,%eax
  8013e8:	29 d0                	sub    %edx,%eax
  8013ea:	50                   	push   %eax
  8013eb:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8013ee:	50                   	push   %eax
  8013ef:	ff 75 08             	pushl  0x8(%ebp)
  8013f2:	e8 4f ff ff ff       	call   801346 <read>
		if (m < 0)
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 0e                	js     80140c <readn+0x3f>
			return m;
		if (m == 0)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 08                	je     80140a <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801402:	01 c3                	add    %eax,%ebx
  801404:	89 da                	mov    %ebx,%edx
  801406:	39 f3                	cmp    %esi,%ebx
  801408:	72 d9                	jb     8013e3 <readn+0x16>
  80140a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	c9                   	leave  
  801413:	c3                   	ret    

00801414 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 20             	sub    $0x20,%esp
  80141c:	8b 75 08             	mov    0x8(%ebp),%esi
  80141f:	8a 45 0c             	mov    0xc(%ebp),%al
  801422:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	56                   	push   %esi
  80142a:	e8 5d fc ff ff       	call   80108c <fd2num>
  80142f:	89 04 24             	mov    %eax,(%esp)
  801432:	e8 d0 fc ff ff       	call   801107 <fd_lookup>
  801437:	89 c3                	mov    %eax,%ebx
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 05                	js     801445 <fd_close+0x31>
  801440:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801443:	74 0d                	je     801452 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801445:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801449:	75 48                	jne    801493 <fd_close+0x7f>
  80144b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801450:	eb 41                	jmp    801493 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 36                	pushl  (%esi)
  80145b:	e8 17 fd ff ff       	call   801177 <dev_lookup>
  801460:	89 c3                	mov    %eax,%ebx
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 1c                	js     801485 <fd_close+0x71>
		if (dev->dev_close)
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	8b 40 10             	mov    0x10(%eax),%eax
  80146f:	85 c0                	test   %eax,%eax
  801471:	75 07                	jne    80147a <fd_close+0x66>
  801473:	bb 00 00 00 00       	mov    $0x0,%ebx
  801478:	eb 0b                	jmp    801485 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80147a:	83 ec 0c             	sub    $0xc,%esp
  80147d:	56                   	push   %esi
  80147e:	ff d0                	call   *%eax
  801480:	89 c3                	mov    %eax,%ebx
  801482:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	56                   	push   %esi
  801489:	6a 00                	push   $0x0
  80148b:	e8 1d f8 ff ff       	call   800cad <sys_page_unmap>
  801490:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801493:	89 d8                	mov    %ebx,%eax
  801495:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	c9                   	leave  
  80149b:	c3                   	ret    

0080149c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 75 08             	pushl  0x8(%ebp)
  8014a9:	e8 59 fc ff ff       	call   801107 <fd_lookup>
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 10                	js     8014c5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	6a 01                	push   $0x1
  8014ba:	ff 75 fc             	pushl  -0x4(%ebp)
  8014bd:	e8 52 ff ff ff       	call   801414 <fd_close>
  8014c2:	83 c4 10             	add    $0x10,%esp
}
  8014c5:	c9                   	leave  
  8014c6:	c3                   	ret    

008014c7 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	56                   	push   %esi
  8014cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	6a 00                	push   $0x0
  8014d1:	ff 75 08             	pushl  0x8(%ebp)
  8014d4:	e8 4a 03 00 00       	call   801823 <open>
  8014d9:	89 c6                	mov    %eax,%esi
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 1b                	js     8014fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	ff 75 0c             	pushl  0xc(%ebp)
  8014e8:	50                   	push   %eax
  8014e9:	e8 e0 fc ff ff       	call   8011ce <fstat>
  8014ee:	89 c3                	mov    %eax,%ebx
	close(fd);
  8014f0:	89 34 24             	mov    %esi,(%esp)
  8014f3:	e8 a4 ff ff ff       	call   80149c <close>
  8014f8:	89 de                	mov    %ebx,%esi
  8014fa:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014fd:	89 f0                	mov    %esi,%eax
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	57                   	push   %edi
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
  80150c:	83 ec 1c             	sub    $0x1c,%esp
  80150f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	ff 75 08             	pushl  0x8(%ebp)
  801519:	e8 e9 fb ff ff       	call   801107 <fd_lookup>
  80151e:	89 c3                	mov    %eax,%ebx
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	85 c0                	test   %eax,%eax
  801525:	0f 88 bd 00 00 00    	js     8015e8 <dup+0xe2>
		return r;
	close(newfdnum);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	57                   	push   %edi
  80152f:	e8 68 ff ff ff       	call   80149c <close>

	newfd = INDEX2FD(newfdnum);
  801534:	89 f8                	mov    %edi,%eax
  801536:	c1 e0 0c             	shl    $0xc,%eax
  801539:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80153f:	ff 75 f0             	pushl  -0x10(%ebp)
  801542:	e8 55 fb ff ff       	call   80109c <fd2data>
  801547:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801549:	89 34 24             	mov    %esi,(%esp)
  80154c:	e8 4b fb ff ff       	call   80109c <fd2data>
  801551:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801554:	89 d8                	mov    %ebx,%eax
  801556:	c1 e8 16             	shr    $0x16,%eax
  801559:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801560:	83 c4 14             	add    $0x14,%esp
  801563:	a8 01                	test   $0x1,%al
  801565:	74 36                	je     80159d <dup+0x97>
  801567:	89 da                	mov    %ebx,%edx
  801569:	c1 ea 0c             	shr    $0xc,%edx
  80156c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801573:	a8 01                	test   $0x1,%al
  801575:	74 26                	je     80159d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801577:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80157e:	83 ec 0c             	sub    $0xc,%esp
  801581:	25 07 0e 00 00       	and    $0xe07,%eax
  801586:	50                   	push   %eax
  801587:	ff 75 e0             	pushl  -0x20(%ebp)
  80158a:	6a 00                	push   $0x0
  80158c:	53                   	push   %ebx
  80158d:	6a 00                	push   $0x0
  80158f:	e8 5b f7 ff ff       	call   800cef <sys_page_map>
  801594:	89 c3                	mov    %eax,%ebx
  801596:	83 c4 20             	add    $0x20,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 30                	js     8015cd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80159d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a0:	89 d0                	mov    %edx,%eax
  8015a2:	c1 e8 0c             	shr    $0xc,%eax
  8015a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b4:	50                   	push   %eax
  8015b5:	56                   	push   %esi
  8015b6:	6a 00                	push   $0x0
  8015b8:	52                   	push   %edx
  8015b9:	6a 00                	push   $0x0
  8015bb:	e8 2f f7 ff ff       	call   800cef <sys_page_map>
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	83 c4 20             	add    $0x20,%esp
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 04                	js     8015cd <dup+0xc7>
		goto err;
  8015c9:	89 fb                	mov    %edi,%ebx
  8015cb:	eb 1b                	jmp    8015e8 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	56                   	push   %esi
  8015d1:	6a 00                	push   $0x0
  8015d3:	e8 d5 f6 ff ff       	call   800cad <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d8:	83 c4 08             	add    $0x8,%esp
  8015db:	ff 75 e0             	pushl  -0x20(%ebp)
  8015de:	6a 00                	push   $0x0
  8015e0:	e8 c8 f6 ff ff       	call   800cad <sys_page_unmap>
  8015e5:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 04             	sub    $0x4,%esp
  8015f9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	53                   	push   %ebx
  801602:	e8 95 fe ff ff       	call   80149c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801607:	43                   	inc    %ebx
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	83 fb 20             	cmp    $0x20,%ebx
  80160e:	75 ee                	jne    8015fe <close_all+0xc>
		close(i);
}
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    
  801615:	00 00                	add    %al,(%eax)
	...

00801618 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801621:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801628:	75 12                	jne    80163c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	6a 01                	push   $0x1
  80162f:	e8 f0 07 00 00       	call   801e24 <ipc_find_env>
  801634:	a3 00 40 80 00       	mov    %eax,0x804000
  801639:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80163c:	6a 07                	push   $0x7
  80163e:	68 00 50 80 00       	push   $0x805000
  801643:	53                   	push   %ebx
  801644:	ff 35 00 40 80 00    	pushl  0x804000
  80164a:	e8 1a 08 00 00       	call   801e69 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164f:	83 c4 0c             	add    $0xc,%esp
  801652:	6a 00                	push   $0x0
  801654:	56                   	push   %esi
  801655:	6a 00                	push   $0x0
  801657:	e8 62 08 00 00       	call   801ebe <ipc_recv>
}
  80165c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	b8 08 00 00 00       	mov    $0x8,%eax
  801673:	e8 a0 ff ff ff       	call   801618 <fsipc>
}
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	8b 40 0c             	mov    0xc(%eax),%eax
  801686:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80168b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801693:	ba 00 00 00 00       	mov    $0x0,%edx
  801698:	b8 02 00 00 00       	mov    $0x2,%eax
  80169d:	e8 76 ff ff ff       	call   801618 <fsipc>
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8016bf:	e8 54 ff ff ff       	call   801618 <fsipc>
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 04             	sub    $0x4,%esp
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016db:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e5:	e8 2e ff ff ff       	call   801618 <fsipc>
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 2c                	js     80171a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	68 00 50 80 00       	push   $0x805000
  8016f6:	53                   	push   %ebx
  8016f7:	e8 1f f1 ff ff       	call   80081b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016fc:	a1 80 50 80 00       	mov    0x805080,%eax
  801701:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801707:	a1 84 50 80 00       	mov    0x805084,%eax
  80170c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801712:	b8 00 00 00 00       	mov    $0x0,%eax
  801717:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80171a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	53                   	push   %ebx
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
  80172c:	8b 40 0c             	mov    0xc(%eax),%eax
  80172f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801734:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80173a:	53                   	push   %ebx
  80173b:	ff 75 0c             	pushl  0xc(%ebp)
  80173e:	68 08 50 80 00       	push   $0x805008
  801743:	e8 40 f2 ff ff       	call   800988 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 04 00 00 00       	mov    $0x4,%eax
  801752:	e8 c1 fe ff ff       	call   801618 <fsipc>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 3d                	js     80179b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80175e:	39 c3                	cmp    %eax,%ebx
  801760:	73 19                	jae    80177b <devfile_write+0x5c>
  801762:	68 1c 28 80 00       	push   $0x80281c
  801767:	68 23 28 80 00       	push   $0x802823
  80176c:	68 97 00 00 00       	push   $0x97
  801771:	68 38 28 80 00       	push   $0x802838
  801776:	e8 ad ea ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  80177b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801780:	7e 19                	jle    80179b <devfile_write+0x7c>
  801782:	68 43 28 80 00       	push   $0x802843
  801787:	68 23 28 80 00       	push   $0x802823
  80178c:	68 98 00 00 00       	push   $0x98
  801791:	68 38 28 80 00       	push   $0x802838
  801796:	e8 8d ea ff ff       	call   800228 <_panic>
	
	return r;
}
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	56                   	push   %esi
  8017a4:	53                   	push   %ebx
  8017a5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017b3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017be:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c3:	e8 50 fe ff ff       	call   801618 <fsipc>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 4c                	js     80181a <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8017ce:	39 de                	cmp    %ebx,%esi
  8017d0:	73 16                	jae    8017e8 <devfile_read+0x48>
  8017d2:	68 1c 28 80 00       	push   $0x80281c
  8017d7:	68 23 28 80 00       	push   $0x802823
  8017dc:	6a 7c                	push   $0x7c
  8017de:	68 38 28 80 00       	push   $0x802838
  8017e3:	e8 40 ea ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  8017e8:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8017ee:	7e 16                	jle    801806 <devfile_read+0x66>
  8017f0:	68 43 28 80 00       	push   $0x802843
  8017f5:	68 23 28 80 00       	push   $0x802823
  8017fa:	6a 7d                	push   $0x7d
  8017fc:	68 38 28 80 00       	push   $0x802838
  801801:	e8 22 ea ff ff       	call   800228 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	50                   	push   %eax
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	e8 71 f1 ff ff       	call   800988 <memmove>
  801817:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 1c             	sub    $0x1c,%esp
  80182b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80182e:	56                   	push   %esi
  80182f:	e8 b4 ef ff ff       	call   8007e8 <strlen>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80183c:	7e 07                	jle    801845 <open+0x22>
  80183e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801843:	eb 63                	jmp    8018a8 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	50                   	push   %eax
  80184c:	e8 63 f8 ff ff       	call   8010b4 <fd_alloc>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	78 4e                	js     8018a8 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	56                   	push   %esi
  80185e:	68 00 50 80 00       	push   $0x805000
  801863:	e8 b3 ef ff ff       	call   80081b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801870:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801873:	b8 01 00 00 00       	mov    $0x1,%eax
  801878:	e8 9b fd ff ff       	call   801618 <fsipc>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	79 12                	jns    801898 <open+0x75>
		fd_close(fd, 0);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	6a 00                	push   $0x0
  80188b:	ff 75 f4             	pushl  -0xc(%ebp)
  80188e:	e8 81 fb ff ff       	call   801414 <fd_close>
		return r;
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	eb 10                	jmp    8018a8 <open+0x85>
	}

	return fd2num(fd);
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	ff 75 f4             	pushl  -0xc(%ebp)
  80189e:	e8 e9 f7 ff ff       	call   80108c <fd2num>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	83 c4 10             	add    $0x10,%esp
}
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    
  8018b1:	00 00                	add    %al,(%eax)
	...

008018b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	56                   	push   %esi
  8018b8:	53                   	push   %ebx
  8018b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 d5 f7 ff ff       	call   80109c <fd2data>
  8018c7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018c9:	83 c4 08             	add    $0x8,%esp
  8018cc:	68 4f 28 80 00       	push   $0x80284f
  8018d1:	53                   	push   %ebx
  8018d2:	e8 44 ef ff ff       	call   80081b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018d7:	8b 46 04             	mov    0x4(%esi),%eax
  8018da:	2b 06                	sub    (%esi),%eax
  8018dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018e9:	00 00 00 
	stat->st_dev = &devpipe;
  8018ec:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018f3:	30 80 00 
	return 0;
}
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 0c             	sub    $0xc,%esp
  801909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80190c:	53                   	push   %ebx
  80190d:	6a 00                	push   $0x0
  80190f:	e8 99 f3 ff ff       	call   800cad <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801914:	89 1c 24             	mov    %ebx,(%esp)
  801917:	e8 80 f7 ff ff       	call   80109c <fd2data>
  80191c:	83 c4 08             	add    $0x8,%esp
  80191f:	50                   	push   %eax
  801920:	6a 00                	push   $0x0
  801922:	e8 86 f3 ff ff       	call   800cad <sys_page_unmap>
}
  801927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	57                   	push   %edi
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801938:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80193a:	a1 04 40 80 00       	mov    0x804004,%eax
  80193f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801942:	83 ec 0c             	sub    $0xc,%esp
  801945:	ff 75 f0             	pushl  -0x10(%ebp)
  801948:	e8 db 05 00 00       	call   801f28 <pageref>
  80194d:	89 c3                	mov    %eax,%ebx
  80194f:	89 3c 24             	mov    %edi,(%esp)
  801952:	e8 d1 05 00 00       	call   801f28 <pageref>
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	39 c3                	cmp    %eax,%ebx
  80195c:	0f 94 c0             	sete   %al
  80195f:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801962:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801968:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  80196b:	39 c6                	cmp    %eax,%esi
  80196d:	74 1b                	je     80198a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  80196f:	83 f9 01             	cmp    $0x1,%ecx
  801972:	75 c6                	jne    80193a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801974:	8b 42 58             	mov    0x58(%edx),%eax
  801977:	6a 01                	push   $0x1
  801979:	50                   	push   %eax
  80197a:	56                   	push   %esi
  80197b:	68 56 28 80 00       	push   $0x802856
  801980:	e8 44 e9 ff ff       	call   8002c9 <cprintf>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	eb b0                	jmp    80193a <_pipeisclosed+0xe>
	}
}
  80198a:	89 c8                	mov    %ecx,%eax
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 18             	sub    $0x18,%esp
  80199d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a0:	56                   	push   %esi
  8019a1:	e8 f6 f6 ff ff       	call   80109c <fd2data>
  8019a6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	eb 40                	jmp    8019f8 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bd:	eb 40                	jmp    8019ff <devpipe_write+0x6b>
  8019bf:	89 da                	mov    %ebx,%edx
  8019c1:	89 f0                	mov    %esi,%eax
  8019c3:	e8 64 ff ff ff       	call   80192c <_pipeisclosed>
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	75 ec                	jne    8019b8 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019cc:	e8 a3 f3 ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d1:	8b 53 04             	mov    0x4(%ebx),%edx
  8019d4:	8b 03                	mov    (%ebx),%eax
  8019d6:	83 c0 20             	add    $0x20,%eax
  8019d9:	39 c2                	cmp    %eax,%edx
  8019db:	73 e2                	jae    8019bf <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019dd:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019e3:	79 05                	jns    8019ea <devpipe_write+0x56>
  8019e5:	4a                   	dec    %edx
  8019e6:	83 ca e0             	or     $0xffffffe0,%edx
  8019e9:	42                   	inc    %edx
  8019ea:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019ed:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8019f0:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019f4:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f7:	47                   	inc    %edi
  8019f8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019fb:	75 d4                	jne    8019d1 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019fd:	89 f8                	mov    %edi,%eax
}
  8019ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 18             	sub    $0x18,%esp
  801a10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a13:	57                   	push   %edi
  801a14:	e8 83 f6 ff ff       	call   80109c <fd2data>
  801a19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a21:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	eb 41                	jmp    801a6c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a2b:	89 f0                	mov    %esi,%eax
  801a2d:	eb 44                	jmp    801a73 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a34:	eb 3d                	jmp    801a73 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a36:	85 f6                	test   %esi,%esi
  801a38:	75 f1                	jne    801a2b <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a3a:	89 da                	mov    %ebx,%edx
  801a3c:	89 f8                	mov    %edi,%eax
  801a3e:	e8 e9 fe ff ff       	call   80192c <_pipeisclosed>
  801a43:	85 c0                	test   %eax,%eax
  801a45:	75 e8                	jne    801a2f <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a47:	e8 28 f3 ff ff       	call   800d74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a4c:	8b 03                	mov    (%ebx),%eax
  801a4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a51:	74 e3                	je     801a36 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a53:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a58:	79 05                	jns    801a5f <devpipe_read+0x58>
  801a5a:	48                   	dec    %eax
  801a5b:	83 c8 e0             	or     $0xffffffe0,%eax
  801a5e:	40                   	inc    %eax
  801a5f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a63:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a66:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801a69:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6b:	46                   	inc    %esi
  801a6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a6f:	75 db                	jne    801a4c <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a71:	89 f0                	mov    %esi,%eax
}
  801a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5f                   	pop    %edi
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a81:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a84:	50                   	push   %eax
  801a85:	ff 75 08             	pushl  0x8(%ebp)
  801a88:	e8 7a f6 ff ff       	call   801107 <fd_lookup>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 18                	js     801aac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	ff 75 fc             	pushl  -0x4(%ebp)
  801a9a:	e8 fd f5 ff ff       	call   80109c <fd2data>
  801a9f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801aa1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801aa4:	e8 83 fe ff ff       	call   80192c <_pipeisclosed>
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 28             	sub    $0x28,%esp
  801ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801abd:	50                   	push   %eax
  801abe:	e8 f1 f5 ff ff       	call   8010b4 <fd_alloc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	0f 88 24 01 00 00    	js     801bf4 <pipe+0x146>
  801ad0:	83 ec 04             	sub    $0x4,%esp
  801ad3:	68 07 04 00 00       	push   $0x407
  801ad8:	ff 75 f0             	pushl  -0x10(%ebp)
  801adb:	6a 00                	push   $0x0
  801add:	e8 4f f2 ff ff       	call   800d31 <sys_page_alloc>
  801ae2:	89 c3                	mov    %eax,%ebx
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	0f 88 05 01 00 00    	js     801bf4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af5:	50                   	push   %eax
  801af6:	e8 b9 f5 ff ff       	call   8010b4 <fd_alloc>
  801afb:	89 c3                	mov    %eax,%ebx
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	0f 88 dc 00 00 00    	js     801be4 <pipe+0x136>
  801b08:	83 ec 04             	sub    $0x4,%esp
  801b0b:	68 07 04 00 00       	push   $0x407
  801b10:	ff 75 ec             	pushl  -0x14(%ebp)
  801b13:	6a 00                	push   $0x0
  801b15:	e8 17 f2 ff ff       	call   800d31 <sys_page_alloc>
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	0f 88 bd 00 00 00    	js     801be4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b2d:	e8 6a f5 ff ff       	call   80109c <fd2data>
  801b32:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b34:	83 c4 0c             	add    $0xc,%esp
  801b37:	68 07 04 00 00       	push   $0x407
  801b3c:	50                   	push   %eax
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 ed f1 ff ff       	call   800d31 <sys_page_alloc>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	0f 88 83 00 00 00    	js     801bd4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	ff 75 ec             	pushl  -0x14(%ebp)
  801b57:	e8 40 f5 ff ff       	call   80109c <fd2data>
  801b5c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b63:	50                   	push   %eax
  801b64:	6a 00                	push   $0x0
  801b66:	56                   	push   %esi
  801b67:	6a 00                	push   $0x0
  801b69:	e8 81 f1 ff ff       	call   800cef <sys_page_map>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 20             	add    $0x20,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 4f                	js     801bc6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b77:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b80:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b8c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b95:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b9a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba7:	e8 e0 f4 ff ff       	call   80108c <fd2num>
  801bac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bae:	83 c4 04             	add    $0x4,%esp
  801bb1:	ff 75 ec             	pushl  -0x14(%ebp)
  801bb4:	e8 d3 f4 ff ff       	call   80108c <fd2num>
  801bb9:	89 47 04             	mov    %eax,0x4(%edi)
  801bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	eb 2e                	jmp    801bf4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801bc6:	83 ec 08             	sub    $0x8,%esp
  801bc9:	56                   	push   %esi
  801bca:	6a 00                	push   $0x0
  801bcc:	e8 dc f0 ff ff       	call   800cad <sys_page_unmap>
  801bd1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	ff 75 ec             	pushl  -0x14(%ebp)
  801bda:	6a 00                	push   $0x0
  801bdc:	e8 cc f0 ff ff       	call   800cad <sys_page_unmap>
  801be1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801be4:	83 ec 08             	sub    $0x8,%esp
  801be7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bea:	6a 00                	push   $0x0
  801bec:	e8 bc f0 ff ff       	call   800cad <sys_page_unmap>
  801bf1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    
	...

00801c00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c03:	b8 00 00 00 00       	mov    $0x0,%eax
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c10:	68 6e 28 80 00       	push   $0x80286e
  801c15:	ff 75 0c             	pushl  0xc(%ebp)
  801c18:	e8 fe eb ff ff       	call   80081b <strcpy>
	return 0;
}
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	57                   	push   %edi
  801c28:	56                   	push   %esi
  801c29:	53                   	push   %ebx
  801c2a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801c30:	be 00 00 00 00       	mov    $0x0,%esi
  801c35:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801c3b:	eb 2c                	jmp    801c69 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c40:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c42:	83 fb 7f             	cmp    $0x7f,%ebx
  801c45:	76 05                	jbe    801c4c <devcons_write+0x28>
  801c47:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c4c:	83 ec 04             	sub    $0x4,%esp
  801c4f:	53                   	push   %ebx
  801c50:	03 45 0c             	add    0xc(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	57                   	push   %edi
  801c55:	e8 2e ed ff ff       	call   800988 <memmove>
		sys_cputs(buf, m);
  801c5a:	83 c4 08             	add    $0x8,%esp
  801c5d:	53                   	push   %ebx
  801c5e:	57                   	push   %edi
  801c5f:	e8 fb ee ff ff       	call   800b5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c64:	01 de                	add    %ebx,%esi
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	89 f0                	mov    %esi,%eax
  801c6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c6e:	72 cd                	jb     801c3d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c84:	6a 01                	push   $0x1
  801c86:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	e8 d0 ee ff ff       	call   800b5f <sys_cputs>
  801c8f:	83 c4 10             	add    $0x10,%esp
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9e:	74 27                	je     801cc7 <devcons_read+0x33>
  801ca0:	eb 05                	jmp    801ca7 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ca2:	e8 cd f0 ff ff       	call   800d74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca7:	e8 94 ee ff ff       	call   800b40 <sys_cgetc>
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	74 f0                	je     801ca2 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 16                	js     801ccc <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb6:	83 f8 04             	cmp    $0x4,%eax
  801cb9:	74 0c                	je     801cc7 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	88 10                	mov    %dl,(%eax)
  801cc0:	ba 01 00 00 00       	mov    $0x1,%edx
  801cc5:	eb 05                	jmp    801ccc <devcons_read+0x38>
	return 1;
  801cc7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ccc:	89 d0                	mov    %edx,%eax
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801cd9:	50                   	push   %eax
  801cda:	e8 d5 f3 ff ff       	call   8010b4 <fd_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	78 3b                	js     801d21 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce6:	83 ec 04             	sub    $0x4,%esp
  801ce9:	68 07 04 00 00       	push   $0x407
  801cee:	ff 75 fc             	pushl  -0x4(%ebp)
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 39 f0 ff ff       	call   800d31 <sys_page_alloc>
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 22                	js     801d21 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cff:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d04:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801d07:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801d09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d0c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d13:	83 ec 0c             	sub    $0xc,%esp
  801d16:	ff 75 fc             	pushl  -0x4(%ebp)
  801d19:	e8 6e f3 ff ff       	call   80108c <fd2num>
  801d1e:	83 c4 10             	add    $0x10,%esp
}
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d29:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	ff 75 08             	pushl  0x8(%ebp)
  801d30:	e8 d2 f3 ff ff       	call   801107 <fd_lookup>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 11                	js     801d4d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d3f:	8b 00                	mov    (%eax),%eax
  801d41:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801d47:	0f 94 c0             	sete   %al
  801d4a:	0f b6 c0             	movzbl %al,%eax
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d55:	6a 01                	push   $0x1
  801d57:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801d5a:	50                   	push   %eax
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 e4 f5 ff ff       	call   801346 <read>
	if (r < 0)
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 0f                	js     801d78 <getchar+0x29>
		return r;
	if (r < 1)
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	75 07                	jne    801d74 <getchar+0x25>
  801d6d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d72:	eb 04                	jmp    801d78 <getchar+0x29>
		return -E_EOF;
	return c;
  801d74:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    
	...

00801d7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d82:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d89:	75 64                	jne    801def <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801d8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801d90:	8b 40 48             	mov    0x48(%eax),%eax
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	6a 07                	push   $0x7
  801d98:	68 00 f0 bf ee       	push   $0xeebff000
  801d9d:	50                   	push   %eax
  801d9e:	e8 8e ef ff ff       	call   800d31 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	85 c0                	test   %eax,%eax
  801da8:	79 14                	jns    801dbe <set_pgfault_handler+0x42>
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	68 7c 28 80 00       	push   $0x80287c
  801db2:	6a 22                	push   $0x22
  801db4:	68 e5 28 80 00       	push   $0x8028e5
  801db9:	e8 6a e4 ff ff       	call   800228 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  801dbe:	a1 04 40 80 00       	mov    0x804004,%eax
  801dc3:	8b 40 48             	mov    0x48(%eax),%eax
  801dc6:	83 ec 08             	sub    $0x8,%esp
  801dc9:	68 fc 1d 80 00       	push   $0x801dfc
  801dce:	50                   	push   %eax
  801dcf:	e8 13 ee ff ff       	call   800be7 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	79 14                	jns    801def <set_pgfault_handler+0x73>
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	68 ac 28 80 00       	push   $0x8028ac
  801de3:	6a 25                	push   $0x25
  801de5:	68 e5 28 80 00       	push   $0x8028e5
  801dea:	e8 39 e4 ff ff       	call   800228 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    
  801df9:	00 00                	add    %al,(%eax)
	...

00801dfc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dfc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dfd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e02:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e04:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801e07:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e0b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e0e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801e12:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801e16:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801e18:	83 c4 08             	add    $0x8,%esp
	popal
  801e1b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e1c:	83 c4 04             	add    $0x4,%esp
	popfl
  801e1f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e20:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801e21:	c3                   	ret    
	...

00801e24 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	53                   	push   %ebx
  801e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e2b:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e30:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801e37:	89 c8                	mov    %ecx,%eax
  801e39:	c1 e0 07             	shl    $0x7,%eax
  801e3c:	29 d0                	sub    %edx,%eax
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801e46:	8b 40 50             	mov    0x50(%eax),%eax
  801e49:	39 d8                	cmp    %ebx,%eax
  801e4b:	75 0b                	jne    801e58 <ipc_find_env+0x34>
			return envs[i].env_id;
  801e4d:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801e53:	8b 40 40             	mov    0x40(%eax),%eax
  801e56:	eb 0e                	jmp    801e66 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e58:	41                   	inc    %ecx
  801e59:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801e5f:	75 cf                	jne    801e30 <ipc_find_env+0xc>
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e66:	5b                   	pop    %ebx
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	57                   	push   %edi
  801e6d:	56                   	push   %esi
  801e6e:	53                   	push   %ebx
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e78:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801e7b:	85 db                	test   %ebx,%ebx
  801e7d:	75 05                	jne    801e84 <ipc_send+0x1b>
  801e7f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	57                   	push   %edi
  801e87:	ff 75 08             	pushl  0x8(%ebp)
  801e8a:	e8 35 ed ff ff       	call   800bc4 <sys_ipc_try_send>
		if (r == 0) {		//success
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	74 20                	je     801eb6 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801e96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e99:	75 07                	jne    801ea2 <ipc_send+0x39>
			sys_yield();
  801e9b:	e8 d4 ee ff ff       	call   800d74 <sys_yield>
  801ea0:	eb e2                	jmp    801e84 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801ea2:	83 ec 04             	sub    $0x4,%esp
  801ea5:	68 f4 28 80 00       	push   $0x8028f4
  801eaa:	6a 41                	push   $0x41
  801eac:	68 18 29 80 00       	push   $0x802918
  801eb1:	e8 72 e3 ff ff       	call   800228 <_panic>
		}
	}
}
  801eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5f                   	pop    %edi
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec9:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	75 05                	jne    801ed5 <ipc_recv+0x17>
  801ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	50                   	push   %eax
  801ed9:	e8 a5 ec ff ff       	call   800b83 <sys_ipc_recv>
	if (r < 0) {				
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	85 c0                	test   %eax,%eax
  801ee3:	79 16                	jns    801efb <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801ee5:	85 db                	test   %ebx,%ebx
  801ee7:	74 06                	je     801eef <ipc_recv+0x31>
  801ee9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801eef:	85 f6                	test   %esi,%esi
  801ef1:	74 2c                	je     801f1f <ipc_recv+0x61>
  801ef3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801ef9:	eb 24                	jmp    801f1f <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	74 0a                	je     801f09 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801eff:	a1 04 40 80 00       	mov    0x804004,%eax
  801f04:	8b 40 74             	mov    0x74(%eax),%eax
  801f07:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801f09:	85 f6                	test   %esi,%esi
  801f0b:	74 0a                	je     801f17 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801f0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801f12:	8b 40 78             	mov    0x78(%eax),%eax
  801f15:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801f17:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	c9                   	leave  
  801f25:	c3                   	ret    
	...

00801f28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2e:	89 d0                	mov    %edx,%eax
  801f30:	c1 e8 16             	shr    $0x16,%eax
  801f33:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f3a:	a8 01                	test   $0x1,%al
  801f3c:	74 20                	je     801f5e <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f3e:	89 d0                	mov    %edx,%eax
  801f40:	c1 e8 0c             	shr    $0xc,%eax
  801f43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f4a:	a8 01                	test   $0x1,%al
  801f4c:	74 10                	je     801f5e <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f4e:	c1 e8 0c             	shr    $0xc,%eax
  801f51:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f58:	ef 
  801f59:	0f b7 c0             	movzwl %ax,%eax
  801f5c:	eb 05                	jmp    801f63 <pageref+0x3b>
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    
  801f65:	00 00                	add    %al,(%eax)
	...

00801f68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	57                   	push   %edi
  801f6c:	56                   	push   %esi
  801f6d:	83 ec 28             	sub    $0x28,%esp
  801f70:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801f77:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801f7e:	8b 45 10             	mov    0x10(%ebp),%eax
  801f81:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801f87:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801f89:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f94:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f97:	85 ff                	test   %edi,%edi
  801f99:	75 21                	jne    801fbc <__udivdi3+0x54>
    {
      if (d0 > n1)
  801f9b:	39 d1                	cmp    %edx,%ecx
  801f9d:	76 49                	jbe    801fe8 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f9f:	f7 f1                	div    %ecx
  801fa1:	89 c1                	mov    %eax,%ecx
  801fa3:	31 c0                	xor    %eax,%eax
  801fa5:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fa8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801fab:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fb4:	83 c4 28             	add    $0x28,%esp
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    
  801fbb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fbc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801fbf:	0f 87 97 00 00 00    	ja     80205c <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fc5:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801fc8:	83 f0 1f             	xor    $0x1f,%eax
  801fcb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fce:	75 34                	jne    802004 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fd0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801fd3:	72 08                	jb     801fdd <__udivdi3+0x75>
  801fd5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801fd8:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fdb:	77 7f                	ja     80205c <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fdd:	b9 01 00 00 00       	mov    $0x1,%ecx
  801fe2:	31 c0                	xor    %eax,%eax
  801fe4:	eb c2                	jmp    801fa8 <__udivdi3+0x40>
  801fe6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801feb:	85 c0                	test   %eax,%eax
  801fed:	74 79                	je     802068 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ff2:	89 fa                	mov    %edi,%edx
  801ff4:	f7 f1                	div    %ecx
  801ff6:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ffb:	f7 f1                	div    %ecx
  801ffd:	89 c1                	mov    %eax,%ecx
  801fff:	89 f0                	mov    %esi,%eax
  802001:	eb a5                	jmp    801fa8 <__udivdi3+0x40>
  802003:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802004:	b8 20 00 00 00       	mov    $0x20,%eax
  802009:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  80200c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80200f:	89 fa                	mov    %edi,%edx
  802011:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802014:	d3 e2                	shl    %cl,%edx
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80201c:	d3 e8                	shr    %cl,%eax
  80201e:	89 d7                	mov    %edx,%edi
  802020:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802022:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802025:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802028:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80202a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80202d:	d3 e0                	shl    %cl,%eax
  80202f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802032:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802035:	d3 ea                	shr    %cl,%edx
  802037:	09 d0                	or     %edx,%eax
  802039:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80203c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80203f:	d3 ea                	shr    %cl,%edx
  802041:	f7 f7                	div    %edi
  802043:	89 d7                	mov    %edx,%edi
  802045:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802048:	f7 e6                	mul    %esi
  80204a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80204c:	39 d7                	cmp    %edx,%edi
  80204e:	72 38                	jb     802088 <__udivdi3+0x120>
  802050:	74 27                	je     802079 <__udivdi3+0x111>
  802052:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802055:	31 c0                	xor    %eax,%eax
  802057:	e9 4c ff ff ff       	jmp    801fa8 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80205c:	31 c9                	xor    %ecx,%ecx
  80205e:	31 c0                	xor    %eax,%eax
  802060:	e9 43 ff ff ff       	jmp    801fa8 <__udivdi3+0x40>
  802065:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802068:	b8 01 00 00 00       	mov    $0x1,%eax
  80206d:	31 d2                	xor    %edx,%edx
  80206f:	f7 75 f4             	divl   -0xc(%ebp)
  802072:	89 c1                	mov    %eax,%ecx
  802074:	e9 76 ff ff ff       	jmp    801fef <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802079:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80207c:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80207f:	d3 e0                	shl    %cl,%eax
  802081:	39 f0                	cmp    %esi,%eax
  802083:	73 cd                	jae    802052 <__udivdi3+0xea>
  802085:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802088:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80208b:	49                   	dec    %ecx
  80208c:	31 c0                	xor    %eax,%eax
  80208e:	e9 15 ff ff ff       	jmp    801fa8 <__udivdi3+0x40>
	...

00802094 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	57                   	push   %edi
  802098:	56                   	push   %esi
  802099:	83 ec 30             	sub    $0x30,%esp
  80209c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8020a3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8020aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b3:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8020b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020b9:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8020bb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8020be:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8020c1:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020c4:	85 d2                	test   %edx,%edx
  8020c6:	75 1c                	jne    8020e4 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	39 f8                	cmp    %edi,%eax
  8020cc:	0f 86 c2 00 00 00    	jbe    802194 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020d2:	89 f0                	mov    %esi,%eax
  8020d4:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8020d6:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8020d9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8020e0:	eb 12                	jmp    8020f4 <__umoddi3+0x60>
  8020e2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8020e7:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8020ea:	76 18                	jbe    802104 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8020ec:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8020ef:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8020f2:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8020f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8020fa:	83 c4 30             	add    $0x30,%esp
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	c9                   	leave  
  802100:	c3                   	ret    
  802101:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802104:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802108:	83 f0 1f             	xor    $0x1f,%eax
  80210b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80210e:	0f 84 ac 00 00 00    	je     8021c0 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802114:	b8 20 00 00 00       	mov    $0x20,%eax
  802119:	2b 45 dc             	sub    -0x24(%ebp),%eax
  80211c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80211f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802122:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802125:	d3 e2                	shl    %cl,%edx
  802127:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80212a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80212d:	d3 e8                	shr    %cl,%eax
  80212f:	89 d6                	mov    %edx,%esi
  802131:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  802133:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802136:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802139:	d3 e0                	shl    %cl,%eax
  80213b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80213e:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802141:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802143:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802146:	d3 e0                	shl    %cl,%eax
  802148:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80214e:	d3 ea                	shr    %cl,%edx
  802150:	09 d0                	or     %edx,%eax
  802152:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802155:	d3 ea                	shr    %cl,%edx
  802157:	f7 f6                	div    %esi
  802159:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  80215c:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80215f:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  802162:	0f 82 8d 00 00 00    	jb     8021f5 <__umoddi3+0x161>
  802168:	0f 84 91 00 00 00    	je     8021ff <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80216e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802171:	29 c7                	sub    %eax,%edi
  802173:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802175:	89 f2                	mov    %esi,%edx
  802177:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80217a:	d3 e2                	shl    %cl,%edx
  80217c:	89 f8                	mov    %edi,%eax
  80217e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802181:	d3 e8                	shr    %cl,%eax
  802183:	09 c2                	or     %eax,%edx
  802185:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  802188:	d3 ee                	shr    %cl,%esi
  80218a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80218d:	e9 62 ff ff ff       	jmp    8020f4 <__umoddi3+0x60>
  802192:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802194:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802197:	85 c0                	test   %eax,%eax
  802199:	74 15                	je     8021b0 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80219b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80219e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021a1:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a6:	f7 f1                	div    %ecx
  8021a8:	e9 29 ff ff ff       	jmp    8020d6 <__umoddi3+0x42>
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b5:	31 d2                	xor    %edx,%edx
  8021b7:	f7 75 ec             	divl   -0x14(%ebp)
  8021ba:	89 c1                	mov    %eax,%ecx
  8021bc:	eb dd                	jmp    80219b <__umoddi3+0x107>
  8021be:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8021c6:	72 19                	jb     8021e1 <__umoddi3+0x14d>
  8021c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021cb:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8021ce:	76 11                	jbe    8021e1 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8021d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8021d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021d9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8021dc:	e9 13 ff ff ff       	jmp    8020f4 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8021ea:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8021ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8021f3:	eb db                	jmp    8021d0 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021f5:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8021f8:	19 f2                	sbb    %esi,%edx
  8021fa:	e9 6f ff ff ff       	jmp    80216e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021ff:	39 c7                	cmp    %eax,%edi
  802201:	72 f2                	jb     8021f5 <__umoddi3+0x161>
  802203:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802206:	e9 63 ff ff ff       	jmp    80216e <__umoddi3+0xda>
