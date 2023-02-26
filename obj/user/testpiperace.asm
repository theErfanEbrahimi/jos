
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 d7 01 00 00       	call   800208 <libmain>
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
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	68 60 22 80 00       	push   $0x802260
  800041:	e8 c7 02 00 00       	call   80030d <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 e5 1b 00 00       	call   801c36 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 79 22 80 00       	push   $0x802279
  80005e:	6a 0d                	push   $0xd
  800060:	68 82 22 80 00       	push   $0x802282
  800065:	e8 02 02 00 00       	call   80026c <_panic>
	max = 200;
	if ((r = fork()) < 0)
  80006a:	e8 e3 0d 00 00       	call   800e52 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 96 22 80 00       	push   $0x802296
  80007b:	6a 10                	push   $0x10
  80007d:	68 82 22 80 00       	push   $0x802282
  800082:	e8 e5 01 00 00       	call   80026c <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 59                	jne    8000e4 <umain+0xb0>
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	e8 4e 15 00 00       	call   8015e4 <close>
  800096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80009b:	83 c4 10             	add    $0x10,%esp
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009e:	83 ec 0c             	sub    $0xc,%esp
  8000a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a4:	e8 5a 1b 00 00       	call   801c03 <pipeisclosed>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	85 c0                	test   %eax,%eax
  8000ae:	74 15                	je     8000c5 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000b0:	83 ec 0c             	sub    $0xc,%esp
  8000b3:	68 9f 22 80 00       	push   $0x80229f
  8000b8:	e8 50 02 00 00       	call   80030d <cprintf>
				exit();
  8000bd:	e8 96 01 00 00       	call   800258 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c5:	e8 ee 0c 00 00       	call   800db8 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000ca:	43                   	inc    %ebx
  8000cb:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000d1:	75 cb                	jne    80009e <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	6a 00                	push   $0x0
  8000d8:	6a 00                	push   $0x0
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 89 10 00 00       	call   80116a <ipc_recv>
  8000e1:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	56                   	push   %esi
  8000e8:	68 ba 22 80 00       	push   $0x8022ba
  8000ed:	e8 1b 02 00 00       	call   80030d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000f2:	89 f2                	mov    %esi,%edx
  8000f4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  8000fa:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  800101:	c1 e2 07             	shl    $0x7,%edx
  800104:	29 c2                	sub    %eax,%edx
	cprintf("kid is %d\n", kid-envs);
  800106:	83 c4 08             	add    $0x8,%esp
  800109:	8d 9a 00 00 c0 ee    	lea    -0x11400000(%edx),%ebx
  80010f:	c1 fa 02             	sar    $0x2,%edx
  800112:	89 d0                	mov    %edx,%eax
  800114:	c1 e0 05             	shl    $0x5,%eax
  800117:	89 d1                	mov    %edx,%ecx
  800119:	c1 e1 0a             	shl    $0xa,%ecx
  80011c:	01 c8                	add    %ecx,%eax
  80011e:	01 d0                	add    %edx,%eax
  800120:	89 c1                	mov    %eax,%ecx
  800122:	c1 e1 0f             	shl    $0xf,%ecx
  800125:	01 c8                	add    %ecx,%eax
  800127:	c1 e0 05             	shl    $0x5,%eax
  80012a:	01 d0                	add    %edx,%eax
  80012c:	f7 d8                	neg    %eax
  80012e:	50                   	push   %eax
  80012f:	68 c5 22 80 00       	push   $0x8022c5
  800134:	e8 d4 01 00 00       	call   80030d <cprintf>
	dup(p[0], 10);
  800139:	83 c4 08             	add    $0x8,%esp
  80013c:	6a 0a                	push   $0xa
  80013e:	ff 75 f0             	pushl  -0x10(%ebp)
  800141:	e8 08 15 00 00       	call   80164e <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	eb 10                	jmp    80015b <umain+0x127>
		dup(p[0], 10);
  80014b:	83 ec 08             	sub    $0x8,%esp
  80014e:	6a 0a                	push   $0xa
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 f6 14 00 00       	call   80164e <dup>
  800158:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  80015b:	8b 43 54             	mov    0x54(%ebx),%eax
  80015e:	83 f8 02             	cmp    $0x2,%eax
  800161:	74 e8                	je     80014b <umain+0x117>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 d0 22 80 00       	push   $0x8022d0
  80016b:	e8 9d 01 00 00       	call   80030d <cprintf>
	if (pipeisclosed(p[0]))
  800170:	83 c4 04             	add    $0x4,%esp
  800173:	ff 75 f0             	pushl  -0x10(%ebp)
  800176:	e8 88 1a 00 00       	call   801c03 <pipeisclosed>
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	85 c0                	test   %eax,%eax
  800180:	74 14                	je     800196 <umain+0x162>
		panic("somehow the other end of p[0] got closed!");
  800182:	83 ec 04             	sub    $0x4,%esp
  800185:	68 2c 23 80 00       	push   $0x80232c
  80018a:	6a 3a                	push   $0x3a
  80018c:	68 82 22 80 00       	push   $0x802282
  800191:	e8 d6 00 00 00       	call   80026c <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	ff 75 f0             	pushl  -0x10(%ebp)
  8001a0:	e8 aa 10 00 00       	call   80124f <fd_lookup>
  8001a5:	83 c4 10             	add    $0x10,%esp
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	79 12                	jns    8001be <umain+0x18a>
		panic("cannot look up p[0]: %e", r);
  8001ac:	50                   	push   %eax
  8001ad:	68 e6 22 80 00       	push   $0x8022e6
  8001b2:	6a 3c                	push   $0x3c
  8001b4:	68 82 22 80 00       	push   $0x802282
  8001b9:	e8 ae 00 00 00       	call   80026c <_panic>
	va = fd2data(fd);
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	ff 75 ec             	pushl  -0x14(%ebp)
  8001c4:	e8 1b 10 00 00       	call   8011e4 <fd2data>
	if (pageref(va) != 3+1)
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 2b 18 00 00       	call   8019fc <pageref>
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	83 f8 04             	cmp    $0x4,%eax
  8001d7:	74 12                	je     8001eb <umain+0x1b7>
		cprintf("\nchild detected race\n");
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	68 fe 22 80 00       	push   $0x8022fe
  8001e1:	e8 27 01 00 00       	call   80030d <cprintf>
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	eb 15                	jmp    800200 <umain+0x1cc>
	else
		cprintf("\nrace didn't happen\n", max);
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	68 c8 00 00 00       	push   $0xc8
  8001f3:	68 14 23 80 00       	push   $0x802314
  8001f8:	e8 10 01 00 00       	call   80030d <cprintf>
  8001fd:	83 c4 10             	add    $0x10,%esp
}
  800200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	c9                   	leave  
  800206:	c3                   	ret    
	...

00800208 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	8b 75 08             	mov    0x8(%ebp),%esi
  800210:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800213:	e8 bf 0b 00 00       	call   800dd7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800218:	25 ff 03 00 00       	and    $0x3ff,%eax
  80021d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800224:	c1 e0 07             	shl    $0x7,%eax
  800227:	29 d0                	sub    %edx,%eax
  800229:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80022e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800233:	85 f6                	test   %esi,%esi
  800235:	7e 07                	jle    80023e <libmain+0x36>
		binaryname = argv[0];
  800237:	8b 03                	mov    (%ebx),%eax
  800239:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80023e:	83 ec 08             	sub    $0x8,%esp
  800241:	53                   	push   %ebx
  800242:	56                   	push   %esi
  800243:	e8 ec fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800248:	e8 0b 00 00 00       	call   800258 <exit>
  80024d:	83 c4 10             	add    $0x10,%esp
}
  800250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	c9                   	leave  
  800256:	c3                   	ret    
	...

00800258 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80025e:	6a 00                	push   $0x0
  800260:	e8 91 0b 00 00       	call   800df6 <sys_env_destroy>
  800265:	83 c4 10             	add    $0x10,%esp
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	53                   	push   %ebx
  800270:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
  800276:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800279:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80027f:	e8 53 0b 00 00       	call   800dd7 <sys_getenvid>
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	ff 75 0c             	pushl  0xc(%ebp)
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	53                   	push   %ebx
  80028e:	50                   	push   %eax
  80028f:	68 60 23 80 00       	push   $0x802360
  800294:	e8 74 00 00 00       	call   80030d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	ff 75 f8             	pushl  -0x8(%ebp)
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	e8 15 00 00 00       	call   8002bc <vcprintf>
	cprintf("\n");
  8002a7:	c7 04 24 77 22 80 00 	movl   $0x802277,(%esp)
  8002ae:	e8 5a 00 00 00       	call   80030d <cprintf>
  8002b3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002b6:	cc                   	int3   
  8002b7:	eb fd                	jmp    8002b6 <_panic+0x4a>
  8002b9:	00 00                	add    %al,(%eax)
	...

008002bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c5:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8002cc:	00 00 00 
	b.cnt = 0;
  8002cf:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8002d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	ff 75 08             	pushl  0x8(%ebp)
  8002df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e5:	50                   	push   %eax
  8002e6:	68 24 03 80 00       	push   $0x800324
  8002eb:	e8 70 01 00 00       	call   800460 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f0:	83 c4 08             	add    $0x8,%esp
  8002f3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8002f9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	e8 9e 08 00 00       	call   800ba3 <sys_cputs>
  800305:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800313:	8d 45 0c             	lea    0xc(%ebp),%eax
  800316:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	e8 9a ff ff ff       	call   8002bc <vcprintf>
	va_end(ap);

	return cnt;
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	53                   	push   %ebx
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80032e:	8b 03                	mov    (%ebx),%eax
  800330:	8b 55 08             	mov    0x8(%ebp),%edx
  800333:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800337:	40                   	inc    %eax
  800338:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80033a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80033f:	75 1a                	jne    80035b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	68 ff 00 00 00       	push   $0xff
  800349:	8d 43 08             	lea    0x8(%ebx),%eax
  80034c:	50                   	push   %eax
  80034d:	e8 51 08 00 00       	call   800ba3 <sys_cputs>
		b->idx = 0;
  800352:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800358:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80035b:	ff 43 04             	incl   0x4(%ebx)
}
  80035e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800361:	c9                   	leave  
  800362:	c3                   	ret    
	...

00800364 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 1c             	sub    $0x1c,%esp
  80036d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800370:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	8b 55 0c             	mov    0xc(%ebp),%edx
  800379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80037f:	8b 55 10             	mov    0x10(%ebp),%edx
  800382:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800385:	89 d6                	mov    %edx,%esi
  800387:	bf 00 00 00 00       	mov    $0x0,%edi
  80038c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80038f:	72 04                	jb     800395 <printnum+0x31>
  800391:	39 c2                	cmp    %eax,%edx
  800393:	77 3f                	ja     8003d4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	ff 75 18             	pushl  0x18(%ebp)
  80039b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80039e:	50                   	push   %eax
  80039f:	52                   	push   %edx
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ab:	e8 fc 1b 00 00       	call   801fac <__udivdi3>
  8003b0:	83 c4 18             	add    $0x18,%esp
  8003b3:	52                   	push   %edx
  8003b4:	50                   	push   %eax
  8003b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8003b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8003bb:	e8 a4 ff ff ff       	call   800364 <printnum>
  8003c0:	83 c4 20             	add    $0x20,%esp
  8003c3:	eb 14                	jmp    8003d9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e8             	pushl  -0x18(%ebp)
  8003cb:	ff 75 18             	pushl  0x18(%ebp)
  8003ce:	ff 55 ec             	call   *-0x14(%ebp)
  8003d1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d4:	4b                   	dec    %ebx
  8003d5:	85 db                	test   %ebx,%ebx
  8003d7:	7f ec                	jg     8003c5 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 e8             	pushl  -0x18(%ebp)
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	57                   	push   %edi
  8003e3:	56                   	push   %esi
  8003e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ea:	e8 e9 1c 00 00       	call   8020d8 <__umoddi3>
  8003ef:	83 c4 14             	add    $0x14,%esp
  8003f2:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  8003f9:	50                   	push   %eax
  8003fa:	ff 55 ec             	call   *-0x14(%ebp)
  8003fd:	83 c4 10             	add    $0x10,%esp
}
  800400:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800403:	5b                   	pop    %ebx
  800404:	5e                   	pop    %esi
  800405:	5f                   	pop    %edi
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80040d:	83 fa 01             	cmp    $0x1,%edx
  800410:	7e 0e                	jle    800420 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 42 08             	lea    0x8(%edx),%eax
  800417:	89 01                	mov    %eax,(%ecx)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	8b 52 04             	mov    0x4(%edx),%edx
  80041e:	eb 22                	jmp    800442 <getuint+0x3a>
	else if (lflag)
  800420:	85 d2                	test   %edx,%edx
  800422:	74 10                	je     800434 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800424:	8b 10                	mov    (%eax),%edx
  800426:	8d 42 04             	lea    0x4(%edx),%eax
  800429:	89 01                	mov    %eax,(%ecx)
  80042b:	8b 02                	mov    (%edx),%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	eb 0e                	jmp    800442 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800434:	8b 10                	mov    (%eax),%edx
  800436:	8d 42 04             	lea    0x4(%edx),%eax
  800439:	89 01                	mov    %eax,(%ecx)
  80043b:	8b 02                	mov    (%edx),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80044a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80044d:	8b 11                	mov    (%ecx),%edx
  80044f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800452:	73 0a                	jae    80045e <sprintputch+0x1a>
		*b->buf++ = ch;
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	88 02                	mov    %al,(%edx)
  800459:	8d 42 01             	lea    0x1(%edx),%eax
  80045c:	89 01                	mov    %eax,(%ecx)
}
  80045e:	c9                   	leave  
  80045f:	c3                   	ret    

00800460 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	57                   	push   %edi
  800464:	56                   	push   %esi
  800465:	53                   	push   %ebx
  800466:	83 ec 3c             	sub    $0x3c,%esp
  800469:	8b 75 08             	mov    0x8(%ebp),%esi
  80046c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80046f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800472:	eb 1a                	jmp    80048e <vprintfmt+0x2e>
  800474:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800477:	eb 15                	jmp    80048e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800479:	84 c0                	test   %al,%al
  80047b:	0f 84 15 03 00 00    	je     800796 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	57                   	push   %edi
  800485:	0f b6 c0             	movzbl %al,%eax
  800488:	50                   	push   %eax
  800489:	ff d6                	call   *%esi
  80048b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80048e:	8a 03                	mov    (%ebx),%al
  800490:	43                   	inc    %ebx
  800491:	3c 25                	cmp    $0x25,%al
  800493:	75 e4                	jne    800479 <vprintfmt+0x19>
  800495:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80049c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004a3:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004b1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8004b5:	eb 0a                	jmp    8004c1 <vprintfmt+0x61>
  8004b7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8004be:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8a 03                	mov    (%ebx),%al
  8004c3:	0f b6 d0             	movzbl %al,%edx
  8004c6:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8004c9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8004cc:	83 e8 23             	sub    $0x23,%eax
  8004cf:	3c 55                	cmp    $0x55,%al
  8004d1:	0f 87 9c 02 00 00    	ja     800773 <vprintfmt+0x313>
  8004d7:	0f b6 c0             	movzbl %al,%eax
  8004da:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  8004e1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8004e5:	eb d7                	jmp    8004be <vprintfmt+0x5e>
  8004e7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8004eb:	eb d1                	jmp    8004be <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8004ed:	89 d9                	mov    %ebx,%ecx
  8004ef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004f9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004fc:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800500:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800503:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800507:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800508:	8d 42 d0             	lea    -0x30(%edx),%eax
  80050b:	83 f8 09             	cmp    $0x9,%eax
  80050e:	77 21                	ja     800531 <vprintfmt+0xd1>
  800510:	eb e4                	jmp    8004f6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800512:	8b 55 14             	mov    0x14(%ebp),%edx
  800515:	8d 42 04             	lea    0x4(%edx),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
  80051b:	8b 12                	mov    (%edx),%edx
  80051d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800520:	eb 12                	jmp    800534 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	79 96                	jns    8004be <vprintfmt+0x5e>
  800528:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052f:	eb 8d                	jmp    8004be <vprintfmt+0x5e>
  800531:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800534:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800538:	79 84                	jns    8004be <vprintfmt+0x5e>
  80053a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800540:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800547:	e9 72 ff ff ff       	jmp    8004be <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054c:	ff 45 d4             	incl   -0x2c(%ebp)
  80054f:	e9 6a ff ff ff       	jmp    8004be <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800554:	8b 55 14             	mov    0x14(%ebp),%edx
  800557:	8d 42 04             	lea    0x4(%edx),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	57                   	push   %edi
  800561:	ff 32                	pushl  (%edx)
  800563:	ff d6                	call   *%esi
			break;
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	e9 07 ff ff ff       	jmp    800474 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056d:	8b 55 14             	mov    0x14(%ebp),%edx
  800570:	8d 42 04             	lea    0x4(%edx),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	8b 02                	mov    (%edx),%eax
  800578:	85 c0                	test   %eax,%eax
  80057a:	79 02                	jns    80057e <vprintfmt+0x11e>
  80057c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057e:	83 f8 0f             	cmp    $0xf,%eax
  800581:	7f 0b                	jg     80058e <vprintfmt+0x12e>
  800583:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  80058a:	85 d2                	test   %edx,%edx
  80058c:	75 15                	jne    8005a3 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80058e:	50                   	push   %eax
  80058f:	68 94 23 80 00       	push   $0x802394
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	e8 6e 02 00 00       	call   800809 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	e9 d1 fe ff ff       	jmp    800474 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a3:	52                   	push   %edx
  8005a4:	68 c5 28 80 00       	push   $0x8028c5
  8005a9:	57                   	push   %edi
  8005aa:	56                   	push   %esi
  8005ab:	e8 59 02 00 00       	call   800809 <printfmt>
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	e9 bc fe ff ff       	jmp    800474 <vprintfmt+0x14>
  8005b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005be:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c1:	8b 55 14             	mov    0x14(%ebp),%edx
  8005c4:	8d 42 04             	lea    0x4(%edx),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ca:	8b 1a                	mov    (%edx),%ebx
  8005cc:	85 db                	test   %ebx,%ebx
  8005ce:	75 05                	jne    8005d5 <vprintfmt+0x175>
  8005d0:	bb 9d 23 80 00       	mov    $0x80239d,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8005d5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8005d9:	7e 66                	jle    800641 <vprintfmt+0x1e1>
  8005db:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8005df:	74 60                	je     800641 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	51                   	push   %ecx
  8005e5:	53                   	push   %ebx
  8005e6:	e8 57 02 00 00       	call   800842 <strnlen>
  8005eb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005ee:	29 c1                	sub    %eax,%ecx
  8005f0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005fa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005fd:	eb 0f                	jmp    80060e <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	57                   	push   %edi
  800603:	ff 75 c4             	pushl  -0x3c(%ebp)
  800606:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800608:	ff 4d d8             	decl   -0x28(%ebp)
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800612:	7f eb                	jg     8005ff <vprintfmt+0x19f>
  800614:	eb 2b                	jmp    800641 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061d:	74 15                	je     800634 <vprintfmt+0x1d4>
  80061f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800622:	83 f8 5e             	cmp    $0x5e,%eax
  800625:	76 0d                	jbe    800634 <vprintfmt+0x1d4>
					putch('?', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 3f                	push   $0x3f
  80062d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	eb 0a                	jmp    80063e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	57                   	push   %edi
  800638:	52                   	push   %edx
  800639:	ff d6                	call   *%esi
  80063b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063e:	ff 4d d8             	decl   -0x28(%ebp)
  800641:	8a 03                	mov    (%ebx),%al
  800643:	43                   	inc    %ebx
  800644:	84 c0                	test   %al,%al
  800646:	74 1b                	je     800663 <vprintfmt+0x203>
  800648:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064c:	78 c8                	js     800616 <vprintfmt+0x1b6>
  80064e:	ff 4d dc             	decl   -0x24(%ebp)
  800651:	79 c3                	jns    800616 <vprintfmt+0x1b6>
  800653:	eb 0e                	jmp    800663 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	57                   	push   %edi
  800659:	6a 20                	push   $0x20
  80065b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	ff 4d d8             	decl   -0x28(%ebp)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800667:	7f ec                	jg     800655 <vprintfmt+0x1f5>
  800669:	e9 06 fe ff ff       	jmp    800474 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800672:	7e 10                	jle    800684 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800674:	8b 55 14             	mov    0x14(%ebp),%edx
  800677:	8d 42 08             	lea    0x8(%edx),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
  80067d:	8b 02                	mov    (%edx),%eax
  80067f:	8b 52 04             	mov    0x4(%edx),%edx
  800682:	eb 20                	jmp    8006a4 <vprintfmt+0x244>
	else if (lflag)
  800684:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800688:	74 0e                	je     800698 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	99                   	cltd   
  800696:	eb 0c                	jmp    8006a4 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a4:	89 d1                	mov    %edx,%ecx
  8006a6:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8006a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006ab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006ae:	85 c9                	test   %ecx,%ecx
  8006b0:	78 0a                	js     8006bc <vprintfmt+0x25c>
  8006b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006b7:	e9 89 00 00 00       	jmp    800745 <vprintfmt+0x2e5>
				putch('-', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	57                   	push   %edi
  8006c0:	6a 2d                	push   $0x2d
  8006c2:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8006c7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ca:	f7 da                	neg    %edx
  8006cc:	83 d1 00             	adc    $0x0,%ecx
  8006cf:	f7 d9                	neg    %ecx
  8006d1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 6a                	jmp    800745 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006e1:	e8 22 fd ff ff       	call   800408 <getuint>
  8006e6:	89 d1                	mov    %edx,%ecx
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006ef:	eb 54                	jmp    800745 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006f7:	e8 0c fd ff ff       	call   800408 <getuint>
  8006fc:	89 d1                	mov    %edx,%ecx
  8006fe:	89 c2                	mov    %eax,%edx
  800700:	bb 08 00 00 00       	mov    $0x8,%ebx
  800705:	eb 3e                	jmp    800745 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	57                   	push   %edi
  80070b:	6a 30                	push   $0x30
  80070d:	ff d6                	call   *%esi
			putch('x', putdat);
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	57                   	push   %edi
  800713:	6a 78                	push   $0x78
  800715:	ff d6                	call   *%esi
			num = (unsigned long long)
  800717:	8b 55 14             	mov    0x14(%ebp),%edx
  80071a:	8d 42 04             	lea    0x4(%edx),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	8b 12                	mov    (%edx),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	eb 14                	jmp    800745 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
  800734:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800737:	e8 cc fc ff ff       	call   800408 <getuint>
  80073c:	89 d1                	mov    %edx,%ecx
  80073e:	89 c2                	mov    %eax,%edx
  800740:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800745:	83 ec 0c             	sub    $0xc,%esp
  800748:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	ff 75 d8             	pushl  -0x28(%ebp)
  800750:	53                   	push   %ebx
  800751:	51                   	push   %ecx
  800752:	52                   	push   %edx
  800753:	89 fa                	mov    %edi,%edx
  800755:	89 f0                	mov    %esi,%eax
  800757:	e8 08 fc ff ff       	call   800364 <printnum>
			break;
  80075c:	83 c4 20             	add    $0x20,%esp
  80075f:	e9 10 fd ff ff       	jmp    800474 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	57                   	push   %edi
  800768:	52                   	push   %edx
  800769:	ff d6                	call   *%esi
			break;
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	e9 01 fd ff ff       	jmp    800474 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	57                   	push   %edi
  800777:	6a 25                	push   $0x25
  800779:	ff d6                	call   *%esi
  80077b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80077e:	83 ea 02             	sub    $0x2,%edx
  800781:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800784:	8a 02                	mov    (%edx),%al
  800786:	4a                   	dec    %edx
  800787:	3c 25                	cmp    $0x25,%al
  800789:	75 f9                	jne    800784 <vprintfmt+0x324>
  80078b:	83 c2 02             	add    $0x2,%edx
  80078e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800791:	e9 de fc ff ff       	jmp    800474 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800796:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5f                   	pop    %edi
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	74 37                	je     8007e5 <vsnprintf+0x47>
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	7e 33                	jle    8007e5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007b9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8007c0:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	ff 75 14             	pushl  0x14(%ebp)
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	68 44 04 80 00       	push   $0x800444
  8007d2:	e8 89 fc ff ff       	call   800460 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 05                	jmp    8007ea <vsnprintf+0x4c>
  8007e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007f8:	50                   	push   %eax
  8007f9:	ff 75 10             	pushl  0x10(%ebp)
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	ff 75 08             	pushl  0x8(%ebp)
  800802:	e8 97 ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
  800812:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800815:	50                   	push   %eax
  800816:	ff 75 10             	pushl  0x10(%ebp)
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	ff 75 08             	pushl  0x8(%ebp)
  80081f:	e8 3c fc ff ff       	call   800460 <vprintfmt>
	va_end(ap);
  800824:	83 c4 10             	add    $0x10,%esp
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    
  800829:	00 00                	add    %al,(%eax)
	...

0080082c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 55 08             	mov    0x8(%ebp),%edx
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
  800837:	eb 01                	jmp    80083a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800839:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80083e:	75 f9                	jne    800839 <strlen+0xd>
		n++;
	return n;
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
  800850:	eb 01                	jmp    800853 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800852:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800853:	39 d0                	cmp    %edx,%eax
  800855:	74 06                	je     80085d <strnlen+0x1b>
  800857:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80085b:	75 f5                	jne    800852 <strnlen+0x10>
		n++;
	return n;
}
  80085d:	c9                   	leave  
  80085e:	c3                   	ret    

0080085f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800865:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800868:	8a 01                	mov    (%ecx),%al
  80086a:	88 02                	mov    %al,(%edx)
  80086c:	42                   	inc    %edx
  80086d:	41                   	inc    %ecx
  80086e:	84 c0                	test   %al,%al
  800870:	75 f6                	jne    800868 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087e:	53                   	push   %ebx
  80087f:	e8 a8 ff ff ff       	call   80082c <strlen>
	strcpy(dst + len, src);
  800884:	ff 75 0c             	pushl  0xc(%ebp)
  800887:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80088a:	50                   	push   %eax
  80088b:	e8 cf ff ff ff       	call   80085f <strcpy>
	return dst;
}
  800890:	89 d8                	mov    %ebx,%eax
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 75 08             	mov    0x8(%ebp),%esi
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008aa:	eb 0c                	jmp    8008b8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008ac:	8a 02                	mov    (%edx),%al
  8008ae:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b7:	41                   	inc    %ecx
  8008b8:	39 d9                	cmp    %ebx,%ecx
  8008ba:	75 f0                	jne    8008ac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	75 04                	jne    8008d8 <strlcpy+0x16>
  8008d4:	89 f0                	mov    %esi,%eax
  8008d6:	eb 14                	jmp    8008ec <strlcpy+0x2a>
  8008d8:	89 f0                	mov    %esi,%eax
  8008da:	eb 04                	jmp    8008e0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dc:	88 10                	mov    %dl,(%eax)
  8008de:	40                   	inc    %eax
  8008df:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e0:	49                   	dec    %ecx
  8008e1:	74 06                	je     8008e9 <strlcpy+0x27>
  8008e3:	8a 13                	mov    (%ebx),%dl
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	75 f3                	jne    8008dc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008e9:	c6 00 00             	movb   $0x0,(%eax)
  8008ec:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fb:	eb 02                	jmp    8008ff <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8008fd:	42                   	inc    %edx
  8008fe:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ff:	8a 02                	mov    (%edx),%al
  800901:	84 c0                	test   %al,%al
  800903:	74 04                	je     800909 <strcmp+0x17>
  800905:	3a 01                	cmp    (%ecx),%al
  800907:	74 f4                	je     8008fd <strcmp+0xb>
  800909:	0f b6 c0             	movzbl %al,%eax
  80090c:	0f b6 11             	movzbl (%ecx),%edx
  80090f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091d:	8b 55 10             	mov    0x10(%ebp),%edx
  800920:	eb 03                	jmp    800925 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800922:	4a                   	dec    %edx
  800923:	41                   	inc    %ecx
  800924:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800925:	85 d2                	test   %edx,%edx
  800927:	75 07                	jne    800930 <strncmp+0x1d>
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 14                	jmp    800944 <strncmp+0x31>
  800930:	8a 01                	mov    (%ecx),%al
  800932:	84 c0                	test   %al,%al
  800934:	74 04                	je     80093a <strncmp+0x27>
  800936:	3a 03                	cmp    (%ebx),%al
  800938:	74 e8                	je     800922 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093a:	0f b6 d0             	movzbl %al,%edx
  80093d:	0f b6 03             	movzbl (%ebx),%eax
  800940:	29 c2                	sub    %eax,%edx
  800942:	89 d0                	mov    %edx,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800950:	eb 05                	jmp    800957 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 0c                	je     800962 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800956:	40                   	inc    %eax
  800957:	8a 10                	mov    (%eax),%dl
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f5                	jne    800952 <strchr+0xb>
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80096d:	eb 05                	jmp    800974 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80096f:	38 ca                	cmp    %cl,%dl
  800971:	74 07                	je     80097a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800973:	40                   	inc    %eax
  800974:	8a 10                	mov    (%eax),%dl
  800976:	84 d2                	test   %dl,%dl
  800978:	75 f5                	jne    80096f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 7d 08             	mov    0x8(%ebp),%edi
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80098b:	85 db                	test   %ebx,%ebx
  80098d:	74 36                	je     8009c5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800995:	75 29                	jne    8009c0 <memset+0x44>
  800997:	f6 c3 03             	test   $0x3,%bl
  80099a:	75 24                	jne    8009c0 <memset+0x44>
		c &= 0xFF;
  80099c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	c1 e6 08             	shl    $0x8,%esi
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	c1 e0 18             	shl    $0x18,%eax
  8009a9:	89 d1                	mov    %edx,%ecx
  8009ab:	c1 e1 10             	shl    $0x10,%ecx
  8009ae:	09 c8                	or     %ecx,%eax
  8009b0:	09 c2                	or     %eax,%edx
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	09 d0                	or     %edx,%eax
  8009b6:	89 d9                	mov    %ebx,%ecx
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
  8009bb:	fc                   	cld    
  8009bc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009be:	eb 05                	jmp    8009c5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c0:	89 d9                	mov    %ebx,%ecx
  8009c2:	fc                   	cld    
  8009c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c5:	89 f8                	mov    %edi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8009d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009da:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009dc:	39 c6                	cmp    %eax,%esi
  8009de:	73 36                	jae    800a16 <memmove+0x4a>
  8009e0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e3:	39 d0                	cmp    %edx,%eax
  8009e5:	73 2f                	jae    800a16 <memmove+0x4a>
		s += n;
		d += n;
  8009e7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f6 c2 03             	test   $0x3,%dl
  8009ed:	75 1b                	jne    800a0a <memmove+0x3e>
  8009ef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f5:	75 13                	jne    800a0a <memmove+0x3e>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 0e                	jne    800a0a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8009fc:	8d 7e fc             	lea    -0x4(%esi),%edi
  8009ff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a02:	c1 e9 02             	shr    $0x2,%ecx
  800a05:	fd                   	std    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a08:	eb 09                	jmp    800a13 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0a:	8d 7e ff             	lea    -0x1(%esi),%edi
  800a0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a10:	fd                   	std    
  800a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a13:	fc                   	cld    
  800a14:	eb 20                	jmp    800a36 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1c:	75 15                	jne    800a33 <memmove+0x67>
  800a1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a24:	75 0d                	jne    800a33 <memmove+0x67>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 08                	jne    800a33 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
  800a2e:	fc                   	cld    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 03                	jmp    800a36 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3d:	ff 75 10             	pushl  0x10(%ebp)
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	ff 75 08             	pushl  0x8(%ebp)
  800a46:	e8 81 ff ff ff       	call   8009cc <memmove>
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	83 ec 04             	sub    $0x4,%esp
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	eb 1b                	jmp    800a7a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800a5f:	8a 1a                	mov    (%edx),%bl
  800a61:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800a64:	8a 19                	mov    (%ecx),%bl
  800a66:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800a69:	74 0d                	je     800a78 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800a6b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800a6f:	0f b6 c3             	movzbl %bl,%eax
  800a72:	29 c2                	sub    %eax,%edx
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	eb 0d                	jmp    800a85 <memcmp+0x38>
		s1++, s2++;
  800a78:	42                   	inc    %edx
  800a79:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7a:	48                   	dec    %eax
  800a7b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800a7e:	75 df                	jne    800a5f <memcmp+0x12>
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a85:	83 c4 04             	add    $0x4,%esp
  800a88:	5b                   	pop    %ebx
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a94:	89 c2                	mov    %eax,%edx
  800a96:	03 55 10             	add    0x10(%ebp),%edx
  800a99:	eb 05                	jmp    800aa0 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9b:	38 08                	cmp    %cl,(%eax)
  800a9d:	74 05                	je     800aa4 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9f:	40                   	inc    %eax
  800aa0:	39 d0                	cmp    %edx,%eax
  800aa2:	72 f7                	jb     800a9b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 04             	sub    $0x4,%esp
  800aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab2:	8b 75 10             	mov    0x10(%ebp),%esi
  800ab5:	eb 01                	jmp    800ab8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ab7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	8a 01                	mov    (%ecx),%al
  800aba:	3c 20                	cmp    $0x20,%al
  800abc:	74 f9                	je     800ab7 <strtol+0x11>
  800abe:	3c 09                	cmp    $0x9,%al
  800ac0:	74 f5                	je     800ab7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac2:	3c 2b                	cmp    $0x2b,%al
  800ac4:	75 0a                	jne    800ad0 <strtol+0x2a>
		s++;
  800ac6:	41                   	inc    %ecx
  800ac7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ace:	eb 17                	jmp    800ae7 <strtol+0x41>
	else if (*s == '-')
  800ad0:	3c 2d                	cmp    $0x2d,%al
  800ad2:	74 09                	je     800add <strtol+0x37>
  800ad4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800adb:	eb 0a                	jmp    800ae7 <strtol+0x41>
		s++, neg = 1;
  800add:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ae0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	85 f6                	test   %esi,%esi
  800ae9:	74 05                	je     800af0 <strtol+0x4a>
  800aeb:	83 fe 10             	cmp    $0x10,%esi
  800aee:	75 1a                	jne    800b0a <strtol+0x64>
  800af0:	8a 01                	mov    (%ecx),%al
  800af2:	3c 30                	cmp    $0x30,%al
  800af4:	75 10                	jne    800b06 <strtol+0x60>
  800af6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800afa:	75 0a                	jne    800b06 <strtol+0x60>
		s += 2, base = 16;
  800afc:	83 c1 02             	add    $0x2,%ecx
  800aff:	be 10 00 00 00       	mov    $0x10,%esi
  800b04:	eb 04                	jmp    800b0a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800b06:	85 f6                	test   %esi,%esi
  800b08:	74 07                	je     800b11 <strtol+0x6b>
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0f:	eb 13                	jmp    800b24 <strtol+0x7e>
  800b11:	3c 30                	cmp    $0x30,%al
  800b13:	74 07                	je     800b1c <strtol+0x76>
  800b15:	be 0a 00 00 00       	mov    $0xa,%esi
  800b1a:	eb ee                	jmp    800b0a <strtol+0x64>
		s++, base = 8;
  800b1c:	41                   	inc    %ecx
  800b1d:	be 08 00 00 00       	mov    $0x8,%esi
  800b22:	eb e6                	jmp    800b0a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b24:	8a 11                	mov    (%ecx),%dl
  800b26:	88 d3                	mov    %dl,%bl
  800b28:	8d 42 d0             	lea    -0x30(%edx),%eax
  800b2b:	3c 09                	cmp    $0x9,%al
  800b2d:	77 08                	ja     800b37 <strtol+0x91>
			dig = *s - '0';
  800b2f:	0f be c2             	movsbl %dl,%eax
  800b32:	8d 50 d0             	lea    -0x30(%eax),%edx
  800b35:	eb 1c                	jmp    800b53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b37:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800b3a:	3c 19                	cmp    $0x19,%al
  800b3c:	77 08                	ja     800b46 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800b3e:	0f be c2             	movsbl %dl,%eax
  800b41:	8d 50 a9             	lea    -0x57(%eax),%edx
  800b44:	eb 0d                	jmp    800b53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800b49:	3c 19                	cmp    $0x19,%al
  800b4b:	77 15                	ja     800b62 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800b4d:	0f be c2             	movsbl %dl,%eax
  800b50:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800b53:	39 f2                	cmp    %esi,%edx
  800b55:	7d 0b                	jge    800b62 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800b57:	41                   	inc    %ecx
  800b58:	89 f8                	mov    %edi,%eax
  800b5a:	0f af c6             	imul   %esi,%eax
  800b5d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800b60:	eb c2                	jmp    800b24 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800b62:	89 f8                	mov    %edi,%eax

	if (endptr)
  800b64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b68:	74 05                	je     800b6f <strtol+0xc9>
		*endptr = (char *) s;
  800b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800b6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b73:	74 04                	je     800b79 <strtol+0xd3>
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	f7 df                	neg    %edi
}
  800b79:	89 f8                	mov    %edi,%eax
  800b7b:	83 c4 04             	add    $0x4,%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    
	...

00800b84 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b94:	89 fa                	mov    %edi,%edx
  800b96:	89 f9                	mov    %edi,%ecx
  800b98:	89 fb                	mov    %edi,%ebx
  800b9a:	89 fe                	mov    %edi,%esi
  800b9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 04             	sub    $0x4,%esp
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb7:	89 f8                	mov    %edi,%eax
  800bb9:	89 fb                	mov    %edi,%ebx
  800bbb:	89 fe                	mov    %edi,%esi
  800bbd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbf:	83 c4 04             	add    $0x4,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800bd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdd:	89 f9                	mov    %edi,%ecx
  800bdf:	89 fb                	mov    %edi,%ebx
  800be1:	89 fe                	mov    %edi,%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 0d                	push   $0xd
  800bef:	68 7f 26 80 00       	push   $0x80267f
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 9c 26 80 00       	push   $0x80269c
  800bfb:	e8 6c f6 ff ff       	call   80026c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c1f:	be 00 00 00 00       	mov    $0x0,%esi
  800c24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c44:	89 fb                	mov    %edi,%ebx
  800c46:	89 fe                	mov    %edi,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 0a                	push   $0xa
  800c54:	68 7f 26 80 00       	push   $0x80267f
  800c59:	6a 23                	push   $0x23
  800c5b:	68 9c 26 80 00       	push   $0x80269c
  800c60:	e8 07 f6 ff ff       	call   80026c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c81:	bf 00 00 00 00       	mov    $0x0,%edi
  800c86:	89 fb                	mov    %edi,%ebx
  800c88:	89 fe                	mov    %edi,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 09                	push   $0x9
  800c96:	68 7f 26 80 00       	push   $0x80267f
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 9c 26 80 00       	push   $0x80269c
  800ca2:	e8 c5 f5 ff ff       	call   80026c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc8:	89 fb                	mov    %edi,%ebx
  800cca:	89 fe                	mov    %edi,%esi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 08                	push   $0x8
  800cd8:	68 7f 26 80 00       	push   $0x80267f
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 9c 26 80 00       	push   $0x80269c
  800ce4:	e8 83 f5 ff ff       	call   80026c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	b8 06 00 00 00       	mov    $0x6,%eax
  800d05:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0a:	89 fb                	mov    %edi,%ebx
  800d0c:	89 fe                	mov    %edi,%esi
  800d0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7e 17                	jle    800d2b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d14:	83 ec 0c             	sub    $0xc,%esp
  800d17:	50                   	push   %eax
  800d18:	6a 06                	push   $0x6
  800d1a:	68 7f 26 80 00       	push   $0x80267f
  800d1f:	6a 23                	push   $0x23
  800d21:	68 9c 26 80 00       	push   $0x80269c
  800d26:	e8 41 f5 ff ff       	call   80026c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d45:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d48:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 17                	jle    800d6d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 05                	push   $0x5
  800d5c:	68 7f 26 80 00       	push   $0x80267f
  800d61:	6a 23                	push   $0x23
  800d63:	68 9c 26 80 00       	push   $0x80269c
  800d68:	e8 ff f4 ff ff       	call   80026c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	57                   	push   %edi
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d91:	89 fe                	mov    %edi,%esi
  800d93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7e 17                	jle    800db0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 04                	push   $0x4
  800d9f:	68 7f 26 80 00       	push   $0x80267f
  800da4:	6a 23                	push   $0x23
  800da6:	68 9c 26 80 00       	push   $0x80269c
  800dab:	e8 bc f4 ff ff       	call   80026c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbe:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc3:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	89 f9                	mov    %edi,%ecx
  800dcc:	89 fb                	mov    %edi,%ebx
  800dce:	89 fe                	mov    %edi,%esi
  800dd0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	b8 02 00 00 00       	mov    $0x2,%eax
  800de2:	bf 00 00 00 00       	mov    $0x0,%edi
  800de7:	89 fa                	mov    %edi,%edx
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 fb                	mov    %edi,%ebx
  800ded:	89 fe                	mov    %edi,%esi
  800def:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    

00800df6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b8 03 00 00 00       	mov    $0x3,%eax
  800e07:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0c:	89 f9                	mov    %edi,%ecx
  800e0e:	89 fb                	mov    %edi,%ebx
  800e10:	89 fe                	mov    %edi,%esi
  800e12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 17                	jle    800e2f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	50                   	push   %eax
  800e1c:	6a 03                	push   $0x3
  800e1e:	68 7f 26 80 00       	push   $0x80267f
  800e23:	6a 23                	push   $0x23
  800e25:	68 9c 26 80 00       	push   $0x80269c
  800e2a:	e8 3d f4 ff ff       	call   80026c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    
	...

00800e38 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e3e:	68 aa 26 80 00       	push   $0x8026aa
  800e43:	68 92 00 00 00       	push   $0x92
  800e48:	68 c0 26 80 00       	push   $0x8026c0
  800e4d:	e8 1a f4 ff ff       	call   80026c <_panic>

00800e52 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800e5b:	68 f3 0f 80 00       	push   $0x800ff3
  800e60:	e8 9f 10 00 00       	call   801f04 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e65:	ba 07 00 00 00       	mov    $0x7,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	cd 30                	int    $0x30
  800e6e:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	85 c0                	test   %eax,%eax
  800e75:	75 25                	jne    800e9c <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800e77:	e8 5b ff ff ff       	call   800dd7 <sys_getenvid>
  800e7c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e88:	c1 e0 07             	shl    $0x7,%eax
  800e8b:	29 d0                	sub    %edx,%eax
  800e8d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e92:	a3 04 40 80 00       	mov    %eax,0x804004
  800e97:	e9 4d 01 00 00       	jmp    800fe9 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	79 12                	jns    800eb2 <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800ea0:	50                   	push   %eax
  800ea1:	68 cb 26 80 00       	push   $0x8026cb
  800ea6:	6a 77                	push   $0x77
  800ea8:	68 c0 26 80 00       	push   $0x8026c0
  800ead:	e8 ba f3 ff ff       	call   80026c <_panic>
  800eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	c1 e8 16             	shr    $0x16,%eax
  800ebc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec3:	a8 01                	test   $0x1,%al
  800ec5:	0f 84 ab 00 00 00    	je     800f76 <fork+0x124>
  800ecb:	89 da                	mov    %ebx,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800ed7:	a8 01                	test   $0x1,%al
  800ed9:	0f 84 97 00 00 00    	je     800f76 <fork+0x124>
  800edf:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800ee6:	a8 04                	test   $0x4,%al
  800ee8:	0f 84 88 00 00 00    	je     800f76 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800eee:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800ef5:	89 d6                	mov    %edx,%esi
  800ef7:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800f02:	a9 02 08 00 00       	test   $0x802,%eax
  800f07:	74 0f                	je     800f18 <fork+0xc6>
  800f09:	f6 c4 04             	test   $0x4,%ah
  800f0c:	75 0a                	jne    800f18 <fork+0xc6>
		perm &= ~PTE_W;
  800f0e:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800f13:	89 c2                	mov    %eax,%edx
  800f15:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800f18:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800f1e:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	52                   	push   %edx
  800f25:	56                   	push   %esi
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 04 fe ff ff       	call   800d33 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	79 14                	jns    800f4a <fork+0xf8>
  800f36:	83 ec 04             	sub    $0x4,%esp
  800f39:	68 14 27 80 00       	push   $0x802714
  800f3e:	6a 52                	push   $0x52
  800f40:	68 c0 26 80 00       	push   $0x8026c0
  800f45:	e8 22 f3 ff ff       	call   80026c <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800f50:	56                   	push   %esi
  800f51:	6a 00                	push   $0x0
  800f53:	56                   	push   %esi
  800f54:	6a 00                	push   $0x0
  800f56:	e8 d8 fd ff ff       	call   800d33 <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 14                	jns    800f76 <fork+0x124>
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	68 38 27 80 00       	push   $0x802738
  800f6a:	6a 55                	push   $0x55
  800f6c:	68 c0 26 80 00       	push   $0x8026c0
  800f71:	e8 f6 f2 ff ff       	call   80026c <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f76:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f7c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f82:	0f 85 2f ff ff ff    	jne    800eb7 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	6a 07                	push   $0x7
  800f8d:	68 00 f0 bf ee       	push   $0xeebff000
  800f92:	57                   	push   %edi
  800f93:	e8 dd fd ff ff       	call   800d75 <sys_page_alloc>
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	79 15                	jns    800fb4 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800f9f:	50                   	push   %eax
  800fa0:	68 e9 26 80 00       	push   $0x8026e9
  800fa5:	68 83 00 00 00       	push   $0x83
  800faa:	68 c0 26 80 00       	push   $0x8026c0
  800faf:	e8 b8 f2 ff ff       	call   80026c <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	68 84 1f 80 00       	push   $0x801f84
  800fbc:	57                   	push   %edi
  800fbd:	e8 69 fc ff ff       	call   800c2b <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	6a 02                	push   $0x2
  800fc7:	57                   	push   %edi
  800fc8:	e8 e2 fc ff ff       	call   800caf <sys_env_set_status>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 15                	jns    800fe9 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800fd4:	50                   	push   %eax
  800fd5:	68 fc 26 80 00       	push   $0x8026fc
  800fda:	68 89 00 00 00       	push   $0x89
  800fdf:	68 c0 26 80 00       	push   $0x8026c0
  800fe4:	e8 83 f2 ff ff       	call   80026c <_panic>
	return envid;
	//panic("fork not implemented");
}
  800fe9:	89 f8                	mov    %edi,%eax
  800feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800ffd:	8b 1a                	mov    (%edx),%ebx
  800fff:	89 d8                	mov    %ebx,%eax
  801001:	c1 e8 0c             	shr    $0xc,%eax
  801004:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  80100b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80100f:	74 05                	je     801016 <pgfault+0x23>
  801011:	f6 c4 08             	test   $0x8,%ah
  801014:	75 14                	jne    80102a <pgfault+0x37>
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	68 5c 27 80 00       	push   $0x80275c
  80101e:	6a 1e                	push   $0x1e
  801020:	68 c0 26 80 00       	push   $0x8026c0
  801025:	e8 42 f2 ff ff       	call   80026c <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	6a 07                	push   $0x7
  80102f:	68 00 f0 7f 00       	push   $0x7ff000
  801034:	6a 00                	push   $0x0
  801036:	e8 3a fd ff ff       	call   800d75 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	79 14                	jns    801056 <pgfault+0x63>
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	68 88 27 80 00       	push   $0x802788
  80104a:	6a 2a                	push   $0x2a
  80104c:	68 c0 26 80 00       	push   $0x8026c0
  801051:	e8 16 f2 ff ff       	call   80026c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  801056:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	68 00 10 00 00       	push   $0x1000
  801064:	53                   	push   %ebx
  801065:	68 00 f0 7f 00       	push   $0x7ff000
  80106a:	e8 5d f9 ff ff       	call   8009cc <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  80106f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801076:	53                   	push   %ebx
  801077:	6a 00                	push   $0x0
  801079:	68 00 f0 7f 00       	push   $0x7ff000
  80107e:	6a 00                	push   $0x0
  801080:	e8 ae fc ff ff       	call   800d33 <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  801085:	83 c4 20             	add    $0x20,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	79 14                	jns    8010a0 <pgfault+0xad>
  80108c:	83 ec 04             	sub    $0x4,%esp
  80108f:	68 ac 27 80 00       	push   $0x8027ac
  801094:	6a 2e                	push   $0x2e
  801096:	68 c0 26 80 00       	push   $0x8026c0
  80109b:	e8 cc f1 ff ff       	call   80026c <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	68 00 f0 7f 00       	push   $0x7ff000
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 42 fc ff ff       	call   800cf1 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 14                	jns    8010ca <pgfault+0xd7>
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	68 cc 27 80 00       	push   $0x8027cc
  8010be:	6a 32                	push   $0x32
  8010c0:	68 c0 26 80 00       	push   $0x8026c0
  8010c5:	e8 a2 f1 ff ff       	call   80026c <_panic>
	//panic("pgfault not implemented");
}
  8010ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    
	...

008010d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010d7:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8010dc:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  8010e3:	89 c8                	mov    %ecx,%eax
  8010e5:	c1 e0 07             	shl    $0x7,%eax
  8010e8:	29 d0                	sub    %edx,%eax
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  8010f2:	8b 40 50             	mov    0x50(%eax),%eax
  8010f5:	39 d8                	cmp    %ebx,%eax
  8010f7:	75 0b                	jne    801104 <ipc_find_env+0x34>
			return envs[i].env_id;
  8010f9:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  8010ff:	8b 40 40             	mov    0x40(%eax),%eax
  801102:	eb 0e                	jmp    801112 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801104:	41                   	inc    %ecx
  801105:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  80110b:	75 cf                	jne    8010dc <ipc_find_env+0xc>
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801112:	5b                   	pop    %ebx
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801121:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801124:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801127:	85 db                	test   %ebx,%ebx
  801129:	75 05                	jne    801130 <ipc_send+0x1b>
  80112b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801130:	56                   	push   %esi
  801131:	53                   	push   %ebx
  801132:	57                   	push   %edi
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	e8 cd fa ff ff       	call   800c08 <sys_ipc_try_send>
		if (r == 0) {		//success
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	74 20                	je     801162 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801142:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801145:	75 07                	jne    80114e <ipc_send+0x39>
			sys_yield();
  801147:	e8 6c fc ff ff       	call   800db8 <sys_yield>
  80114c:	eb e2                	jmp    801130 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	68 f0 27 80 00       	push   $0x8027f0
  801156:	6a 41                	push   $0x41
  801158:	68 13 28 80 00       	push   $0x802813
  80115d:	e8 0a f1 ff ff       	call   80026c <_panic>
		}
	}
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801172:	8b 45 0c             	mov    0xc(%ebp),%eax
  801175:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801178:	85 c0                	test   %eax,%eax
  80117a:	75 05                	jne    801181 <ipc_recv+0x17>
  80117c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	50                   	push   %eax
  801185:	e8 3d fa ff ff       	call   800bc7 <sys_ipc_recv>
	if (r < 0) {				
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	79 16                	jns    8011a7 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801191:	85 db                	test   %ebx,%ebx
  801193:	74 06                	je     80119b <ipc_recv+0x31>
  801195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  80119b:	85 f6                	test   %esi,%esi
  80119d:	74 2c                	je     8011cb <ipc_recv+0x61>
  80119f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8011a5:	eb 24                	jmp    8011cb <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	74 0a                	je     8011b5 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8011ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b0:	8b 40 74             	mov    0x74(%eax),%eax
  8011b3:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  8011b5:	85 f6                	test   %esi,%esi
  8011b7:	74 0a                	je     8011c3 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8011b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011be:	8b 40 78             	mov    0x78(%eax),%eax
  8011c1:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8011c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    
	...

008011d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	05 00 00 00 30       	add    $0x30000000,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 e5 ff ff ff       	call   8011d4 <fd2num>
  8011ef:	83 c4 04             	add    $0x4,%esp
  8011f2:	c1 e0 0c             	shl    $0xc,%eax
  8011f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	53                   	push   %ebx
  801200:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801203:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801208:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120a:	89 d0                	mov    %edx,%eax
  80120c:	c1 e8 16             	shr    $0x16,%eax
  80120f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801216:	a8 01                	test   $0x1,%al
  801218:	74 10                	je     80122a <fd_alloc+0x2e>
  80121a:	89 d0                	mov    %edx,%eax
  80121c:	c1 e8 0c             	shr    $0xc,%eax
  80121f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801226:	a8 01                	test   $0x1,%al
  801228:	75 09                	jne    801233 <fd_alloc+0x37>
			*fd_store = fd;
  80122a:	89 0b                	mov    %ecx,(%ebx)
  80122c:	b8 00 00 00 00       	mov    $0x0,%eax
  801231:	eb 19                	jmp    80124c <fd_alloc+0x50>
			return 0;
  801233:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801239:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80123f:	75 c7                	jne    801208 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801241:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801247:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80124c:	5b                   	pop    %ebx
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801255:	83 f8 1f             	cmp    $0x1f,%eax
  801258:	77 35                	ja     80128f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125a:	c1 e0 0c             	shl    $0xc,%eax
  80125d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801263:	89 d0                	mov    %edx,%eax
  801265:	c1 e8 16             	shr    $0x16,%eax
  801268:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126f:	a8 01                	test   $0x1,%al
  801271:	74 1c                	je     80128f <fd_lookup+0x40>
  801273:	89 d0                	mov    %edx,%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80127f:	a8 01                	test   $0x1,%al
  801281:	74 0c                	je     80128f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801283:	8b 45 0c             	mov    0xc(%ebp),%eax
  801286:	89 10                	mov    %edx,(%eax)
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
  80128d:	eb 05                	jmp    801294 <fd_lookup+0x45>
	return 0;
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 a7 ff ff ff       	call   80124f <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 0e                	js     8012bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b5:	89 50 04             	mov    %edx,0x4(%eax)
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	eb 0e                	jmp    8012e1 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012d3:	3b 08                	cmp    (%eax),%ecx
  8012d5:	75 09                	jne    8012e0 <dev_lookup+0x21>
			*dev = devtab[i];
  8012d7:	89 03                	mov    %eax,(%ebx)
  8012d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012de:	eb 31                	jmp    801311 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e0:	42                   	inc    %edx
  8012e1:	8b 04 95 9c 28 80 00 	mov    0x80289c(,%edx,4),%eax
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	75 e7                	jne    8012d3 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f1:	8b 40 48             	mov    0x48(%eax),%eax
  8012f4:	83 ec 04             	sub    $0x4,%esp
  8012f7:	51                   	push   %ecx
  8012f8:	50                   	push   %eax
  8012f9:	68 20 28 80 00       	push   $0x802820
  8012fe:	e8 0a f0 ff ff       	call   80030d <cprintf>
	*dev = 0;
  801303:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130e:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 23 ff ff ff       	call   80124f <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 55                	js     801388 <fstat+0x72>
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 7b ff ff ff       	call   8012bf <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 3d                	js     801388 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80134b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80134e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801352:	75 07                	jne    80135b <fstat+0x45>
  801354:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801359:	eb 2d                	jmp    801388 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80135b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801365:	00 00 00 
	stat->st_isdir = 0;
  801368:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136f:	00 00 00 
	stat->st_dev = dev;
  801372:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801375:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	53                   	push   %ebx
  80137f:	ff 75 f4             	pushl  -0xc(%ebp)
  801382:	ff 50 14             	call   *0x14(%eax)
  801385:	83 c4 10             	add    $0x10,%esp
}
  801388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	53                   	push   %ebx
  801391:	83 ec 14             	sub    $0x14,%esp
  801394:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	53                   	push   %ebx
  80139c:	e8 ae fe ff ff       	call   80124f <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 5f                	js     801407 <ftruncate+0x7a>
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b2:	ff 30                	pushl  (%eax)
  8013b4:	e8 06 ff ff ff       	call   8012bf <dev_lookup>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 47                	js     801407 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c7:	75 21                	jne    8013ea <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ce:	8b 40 48             	mov    0x48(%eax),%eax
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	53                   	push   %ebx
  8013d5:	50                   	push   %eax
  8013d6:	68 40 28 80 00       	push   $0x802840
  8013db:	e8 2d ef ff ff       	call   80030d <cprintf>
  8013e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	eb 1d                	jmp    801407 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013ea:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013ed:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8013f1:	75 07                	jne    8013fa <ftruncate+0x6d>
  8013f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f8:	eb 0d                	jmp    801407 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	50                   	push   %eax
  801401:	ff 52 18             	call   *0x18(%edx)
  801404:	83 c4 10             	add    $0x10,%esp
}
  801407:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    

0080140c <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	53                   	push   %ebx
  801410:	83 ec 14             	sub    $0x14,%esp
  801413:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	53                   	push   %ebx
  80141b:	e8 2f fe ff ff       	call   80124f <fd_lookup>
  801420:	83 c4 08             	add    $0x8,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 62                	js     801489 <write+0x7d>
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801431:	ff 30                	pushl  (%eax)
  801433:	e8 87 fe ff ff       	call   8012bf <dev_lookup>
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 4a                	js     801489 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801446:	75 21                	jne    801469 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801448:	a1 04 40 80 00       	mov    0x804004,%eax
  80144d:	8b 40 48             	mov    0x48(%eax),%eax
  801450:	83 ec 04             	sub    $0x4,%esp
  801453:	53                   	push   %ebx
  801454:	50                   	push   %eax
  801455:	68 61 28 80 00       	push   $0x802861
  80145a:	e8 ae ee ff ff       	call   80030d <cprintf>
  80145f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	eb 20                	jmp    801489 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801469:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80146c:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801470:	75 07                	jne    801479 <write+0x6d>
  801472:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801477:	eb 10                	jmp    801489 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801479:	83 ec 04             	sub    $0x4,%esp
  80147c:	ff 75 10             	pushl  0x10(%ebp)
  80147f:	ff 75 0c             	pushl  0xc(%ebp)
  801482:	50                   	push   %eax
  801483:	ff 52 0c             	call   *0xc(%edx)
  801486:	83 c4 10             	add    $0x10,%esp
}
  801489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	53                   	push   %ebx
  801492:	83 ec 14             	sub    $0x14,%esp
  801495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801498:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	53                   	push   %ebx
  80149d:	e8 ad fd ff ff       	call   80124f <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 67                	js     801510 <read+0x82>
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b3:	ff 30                	pushl  (%eax)
  8014b5:	e8 05 fe ff ff       	call   8012bf <dev_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 4f                	js     801510 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c4:	8b 42 08             	mov    0x8(%edx),%eax
  8014c7:	83 e0 03             	and    $0x3,%eax
  8014ca:	83 f8 01             	cmp    $0x1,%eax
  8014cd:	75 21                	jne    8014f0 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d4:	8b 40 48             	mov    0x48(%eax),%eax
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	53                   	push   %ebx
  8014db:	50                   	push   %eax
  8014dc:	68 7e 28 80 00       	push   $0x80287e
  8014e1:	e8 27 ee ff ff       	call   80030d <cprintf>
  8014e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb 20                	jmp    801510 <read+0x82>
	}
	if (!dev->dev_read)
  8014f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014f3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8014f7:	75 07                	jne    801500 <read+0x72>
  8014f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014fe:	eb 10                	jmp    801510 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	52                   	push   %edx
  80150a:	ff 50 08             	call   *0x8(%eax)
  80150d:	83 c4 10             	add    $0x10,%esp
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801521:	8b 75 10             	mov    0x10(%ebp),%esi
  801524:	bb 00 00 00 00       	mov    $0x0,%ebx
  801529:	eb 21                	jmp    80154c <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	89 f0                	mov    %esi,%eax
  801530:	29 d0                	sub    %edx,%eax
  801532:	50                   	push   %eax
  801533:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801536:	50                   	push   %eax
  801537:	ff 75 08             	pushl  0x8(%ebp)
  80153a:	e8 4f ff ff ff       	call   80148e <read>
		if (m < 0)
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 0e                	js     801554 <readn+0x3f>
			return m;
		if (m == 0)
  801546:	85 c0                	test   %eax,%eax
  801548:	74 08                	je     801552 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154a:	01 c3                	add    %eax,%ebx
  80154c:	89 da                	mov    %ebx,%edx
  80154e:	39 f3                	cmp    %esi,%ebx
  801550:	72 d9                	jb     80152b <readn+0x16>
  801552:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 20             	sub    $0x20,%esp
  801564:	8b 75 08             	mov    0x8(%ebp),%esi
  801567:	8a 45 0c             	mov    0xc(%ebp),%al
  80156a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	56                   	push   %esi
  801572:	e8 5d fc ff ff       	call   8011d4 <fd2num>
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 d0 fc ff ff       	call   80124f <fd_lookup>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 05                	js     80158d <fd_close+0x31>
  801588:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80158b:	74 0d                	je     80159a <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80158d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801591:	75 48                	jne    8015db <fd_close+0x7f>
  801593:	bb 00 00 00 00       	mov    $0x0,%ebx
  801598:	eb 41                	jmp    8015db <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a0:	50                   	push   %eax
  8015a1:	ff 36                	pushl  (%esi)
  8015a3:	e8 17 fd ff ff       	call   8012bf <dev_lookup>
  8015a8:	89 c3                	mov    %eax,%ebx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 1c                	js     8015cd <fd_close+0x71>
		if (dev->dev_close)
  8015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b4:	8b 40 10             	mov    0x10(%eax),%eax
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	75 07                	jne    8015c2 <fd_close+0x66>
  8015bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c0:	eb 0b                	jmp    8015cd <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	56                   	push   %esi
  8015c6:	ff d0                	call   *%eax
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	56                   	push   %esi
  8015d1:	6a 00                	push   $0x0
  8015d3:	e8 19 f7 ff ff       	call   800cf1 <sys_page_unmap>
  8015d8:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015db:	89 d8                	mov    %ebx,%eax
  8015dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	ff 75 08             	pushl  0x8(%ebp)
  8015f1:	e8 59 fc ff ff       	call   80124f <fd_lookup>
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 10                	js     80160d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	6a 01                	push   $0x1
  801602:	ff 75 fc             	pushl  -0x4(%ebp)
  801605:	e8 52 ff ff ff       	call   80155c <fd_close>
  80160a:	83 c4 10             	add    $0x10,%esp
}
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	56                   	push   %esi
  801613:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	6a 00                	push   $0x0
  801619:	ff 75 08             	pushl  0x8(%ebp)
  80161c:	e8 4a 03 00 00       	call   80196b <open>
  801621:	89 c6                	mov    %eax,%esi
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 1b                	js     801645 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	ff 75 0c             	pushl  0xc(%ebp)
  801630:	50                   	push   %eax
  801631:	e8 e0 fc ff ff       	call   801316 <fstat>
  801636:	89 c3                	mov    %eax,%ebx
	close(fd);
  801638:	89 34 24             	mov    %esi,(%esp)
  80163b:	e8 a4 ff ff ff       	call   8015e4 <close>
  801640:	89 de                	mov    %ebx,%esi
  801642:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801645:	89 f0                	mov    %esi,%eax
  801647:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	57                   	push   %edi
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	83 ec 1c             	sub    $0x1c,%esp
  801657:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80165a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 e9 fb ff ff       	call   80124f <fd_lookup>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	83 c4 08             	add    $0x8,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	0f 88 bd 00 00 00    	js     801730 <dup+0xe2>
		return r;
	close(newfdnum);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	57                   	push   %edi
  801677:	e8 68 ff ff ff       	call   8015e4 <close>

	newfd = INDEX2FD(newfdnum);
  80167c:	89 f8                	mov    %edi,%eax
  80167e:	c1 e0 0c             	shl    $0xc,%eax
  801681:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801687:	ff 75 f0             	pushl  -0x10(%ebp)
  80168a:	e8 55 fb ff ff       	call   8011e4 <fd2data>
  80168f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801691:	89 34 24             	mov    %esi,(%esp)
  801694:	e8 4b fb ff ff       	call   8011e4 <fd2data>
  801699:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80169c:	89 d8                	mov    %ebx,%eax
  80169e:	c1 e8 16             	shr    $0x16,%eax
  8016a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016a8:	83 c4 14             	add    $0x14,%esp
  8016ab:	a8 01                	test   $0x1,%al
  8016ad:	74 36                	je     8016e5 <dup+0x97>
  8016af:	89 da                	mov    %ebx,%edx
  8016b1:	c1 ea 0c             	shr    $0xc,%edx
  8016b4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016bb:	a8 01                	test   $0x1,%al
  8016bd:	74 26                	je     8016e5 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016bf:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016c6:	83 ec 0c             	sub    $0xc,%esp
  8016c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ce:	50                   	push   %eax
  8016cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8016d2:	6a 00                	push   $0x0
  8016d4:	53                   	push   %ebx
  8016d5:	6a 00                	push   $0x0
  8016d7:	e8 57 f6 ff ff       	call   800d33 <sys_page_map>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	83 c4 20             	add    $0x20,%esp
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 30                	js     801715 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	c1 e8 0c             	shr    $0xc,%eax
  8016ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fc:	50                   	push   %eax
  8016fd:	56                   	push   %esi
  8016fe:	6a 00                	push   $0x0
  801700:	52                   	push   %edx
  801701:	6a 00                	push   $0x0
  801703:	e8 2b f6 ff ff       	call   800d33 <sys_page_map>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 04                	js     801715 <dup+0xc7>
		goto err;
  801711:	89 fb                	mov    %edi,%ebx
  801713:	eb 1b                	jmp    801730 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	56                   	push   %esi
  801719:	6a 00                	push   $0x0
  80171b:	e8 d1 f5 ff ff       	call   800cf1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801720:	83 c4 08             	add    $0x8,%esp
  801723:	ff 75 e0             	pushl  -0x20(%ebp)
  801726:	6a 00                	push   $0x0
  801728:	e8 c4 f5 ff ff       	call   800cf1 <sys_page_unmap>
  80172d:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5f                   	pop    %edi
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	53                   	push   %ebx
  80174a:	e8 95 fe ff ff       	call   8015e4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80174f:	43                   	inc    %ebx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	83 fb 20             	cmp    $0x20,%ebx
  801756:	75 ee                	jne    801746 <close_all+0xc>
		close(i);
}
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    
  80175d:	00 00                	add    %al,(%eax)
	...

00801760 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	89 c3                	mov    %eax,%ebx
  801767:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801769:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801770:	75 12                	jne    801784 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	6a 01                	push   $0x1
  801777:	e8 54 f9 ff ff       	call   8010d0 <ipc_find_env>
  80177c:	a3 00 40 80 00       	mov    %eax,0x804000
  801781:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801784:	6a 07                	push   $0x7
  801786:	68 00 50 80 00       	push   $0x805000
  80178b:	53                   	push   %ebx
  80178c:	ff 35 00 40 80 00    	pushl  0x804000
  801792:	e8 7e f9 ff ff       	call   801115 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801797:	83 c4 0c             	add    $0xc,%esp
  80179a:	6a 00                	push   $0x0
  80179c:	56                   	push   %esi
  80179d:	6a 00                	push   $0x0
  80179f:	e8 c6 f9 ff ff       	call   80116a <ipc_recv>
}
  8017a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8017bb:	e8 a0 ff ff ff       	call   801760 <fsipc>
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e5:	e8 76 ff ff ff       	call   801760 <fsipc>
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 06 00 00 00       	mov    $0x6,%eax
  801807:	e8 54 ff ff ff       	call   801760 <fsipc>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 05 00 00 00       	mov    $0x5,%eax
  80182d:	e8 2e ff ff ff       	call   801760 <fsipc>
  801832:	85 c0                	test   %eax,%eax
  801834:	78 2c                	js     801862 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	68 00 50 80 00       	push   $0x805000
  80183e:	53                   	push   %ebx
  80183f:	e8 1b f0 ff ff       	call   80085f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801844:	a1 80 50 80 00       	mov    0x805080,%eax
  801849:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184f:	a1 84 50 80 00       	mov    0x805084,%eax
  801854:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
  80185f:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  801862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801865:	c9                   	leave  
  801866:	c3                   	ret    

00801867 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  80187c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801882:	53                   	push   %ebx
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	68 08 50 80 00       	push   $0x805008
  80188b:	e8 3c f1 ff ff       	call   8009cc <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801890:	ba 00 00 00 00       	mov    $0x0,%edx
  801895:	b8 04 00 00 00       	mov    $0x4,%eax
  80189a:	e8 c1 fe ff ff       	call   801760 <fsipc>
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	78 3d                	js     8018e3 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  8018a6:	39 c3                	cmp    %eax,%ebx
  8018a8:	73 19                	jae    8018c3 <devfile_write+0x5c>
  8018aa:	68 ac 28 80 00       	push   $0x8028ac
  8018af:	68 b3 28 80 00       	push   $0x8028b3
  8018b4:	68 97 00 00 00       	push   $0x97
  8018b9:	68 c8 28 80 00       	push   $0x8028c8
  8018be:	e8 a9 e9 ff ff       	call   80026c <_panic>
	assert(r <= PGSIZE);
  8018c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c8:	7e 19                	jle    8018e3 <devfile_write+0x7c>
  8018ca:	68 d3 28 80 00       	push   $0x8028d3
  8018cf:	68 b3 28 80 00       	push   $0x8028b3
  8018d4:	68 98 00 00 00       	push   $0x98
  8018d9:	68 c8 28 80 00       	push   $0x8028c8
  8018de:	e8 89 e9 ff ff       	call   80026c <_panic>
	
	return r;
}
  8018e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018fb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 03 00 00 00       	mov    $0x3,%eax
  80190b:	e8 50 fe ff ff       	call   801760 <fsipc>
  801910:	89 c3                	mov    %eax,%ebx
  801912:	85 c0                	test   %eax,%eax
  801914:	78 4c                	js     801962 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801916:	39 de                	cmp    %ebx,%esi
  801918:	73 16                	jae    801930 <devfile_read+0x48>
  80191a:	68 ac 28 80 00       	push   $0x8028ac
  80191f:	68 b3 28 80 00       	push   $0x8028b3
  801924:	6a 7c                	push   $0x7c
  801926:	68 c8 28 80 00       	push   $0x8028c8
  80192b:	e8 3c e9 ff ff       	call   80026c <_panic>
	assert(r <= PGSIZE);
  801930:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801936:	7e 16                	jle    80194e <devfile_read+0x66>
  801938:	68 d3 28 80 00       	push   $0x8028d3
  80193d:	68 b3 28 80 00       	push   $0x8028b3
  801942:	6a 7d                	push   $0x7d
  801944:	68 c8 28 80 00       	push   $0x8028c8
  801949:	e8 1e e9 ff ff       	call   80026c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	50                   	push   %eax
  801952:	68 00 50 80 00       	push   $0x805000
  801957:	ff 75 0c             	pushl  0xc(%ebp)
  80195a:	e8 6d f0 ff ff       	call   8009cc <memmove>
  80195f:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801962:	89 d8                	mov    %ebx,%eax
  801964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801967:	5b                   	pop    %ebx
  801968:	5e                   	pop    %esi
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	83 ec 1c             	sub    $0x1c,%esp
  801973:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801976:	56                   	push   %esi
  801977:	e8 b0 ee ff ff       	call   80082c <strlen>
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801984:	7e 07                	jle    80198d <open+0x22>
  801986:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80198b:	eb 63                	jmp    8019f0 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80198d:	83 ec 0c             	sub    $0xc,%esp
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	e8 63 f8 ff ff       	call   8011fc <fd_alloc>
  801999:	89 c3                	mov    %eax,%ebx
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 4e                	js     8019f0 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	56                   	push   %esi
  8019a6:	68 00 50 80 00       	push   $0x805000
  8019ab:	e8 af ee ff ff       	call   80085f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019c0:	e8 9b fd ff ff       	call   801760 <fsipc>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	79 12                	jns    8019e0 <open+0x75>
		fd_close(fd, 0);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	6a 00                	push   $0x0
  8019d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d6:	e8 81 fb ff ff       	call   80155c <fd_close>
		return r;
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	eb 10                	jmp    8019f0 <open+0x85>
	}

	return fd2num(fd);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e6:	e8 e9 f7 ff ff       	call   8011d4 <fd2num>
  8019eb:	89 c3                	mov    %eax,%ebx
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	89 d8                	mov    %ebx,%eax
  8019f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    
  8019f9:	00 00                	add    %al,(%eax)
	...

008019fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a02:	89 d0                	mov    %edx,%eax
  801a04:	c1 e8 16             	shr    $0x16,%eax
  801a07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a0e:	a8 01                	test   $0x1,%al
  801a10:	74 20                	je     801a32 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801a12:	89 d0                	mov    %edx,%eax
  801a14:	c1 e8 0c             	shr    $0xc,%eax
  801a17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801a1e:	a8 01                	test   $0x1,%al
  801a20:	74 10                	je     801a32 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801a22:	c1 e8 0c             	shr    $0xc,%eax
  801a25:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801a2c:	ef 
  801a2d:	0f b7 c0             	movzwl %ax,%eax
  801a30:	eb 05                	jmp    801a37 <pageref+0x3b>
  801a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    
  801a39:	00 00                	add    %al,(%eax)
	...

00801a3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	ff 75 08             	pushl  0x8(%ebp)
  801a4a:	e8 95 f7 ff ff       	call   8011e4 <fd2data>
  801a4f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a51:	83 c4 08             	add    $0x8,%esp
  801a54:	68 df 28 80 00       	push   $0x8028df
  801a59:	53                   	push   %ebx
  801a5a:	e8 00 ee ff ff       	call   80085f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a5f:	8b 46 04             	mov    0x4(%esi),%eax
  801a62:	2b 06                	sub    (%esi),%eax
  801a64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a71:	00 00 00 
	stat->st_dev = &devpipe;
  801a74:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a7b:	30 80 00 
	return 0;
}
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a94:	53                   	push   %ebx
  801a95:	6a 00                	push   $0x0
  801a97:	e8 55 f2 ff ff       	call   800cf1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a9c:	89 1c 24             	mov    %ebx,(%esp)
  801a9f:	e8 40 f7 ff ff       	call   8011e4 <fd2data>
  801aa4:	83 c4 08             	add    $0x8,%esp
  801aa7:	50                   	push   %eax
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 42 f2 ff ff       	call   800cf1 <sys_page_unmap>
}
  801aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	57                   	push   %edi
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 0c             	sub    $0xc,%esp
  801abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801ac0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ad0:	e8 27 ff ff ff       	call   8019fc <pageref>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	89 3c 24             	mov    %edi,(%esp)
  801ada:	e8 1d ff ff ff       	call   8019fc <pageref>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	39 c3                	cmp    %eax,%ebx
  801ae4:	0f 94 c0             	sete   %al
  801ae7:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801aea:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af0:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801af3:	39 c6                	cmp    %eax,%esi
  801af5:	74 1b                	je     801b12 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801af7:	83 f9 01             	cmp    $0x1,%ecx
  801afa:	75 c6                	jne    801ac2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801afc:	8b 42 58             	mov    0x58(%edx),%eax
  801aff:	6a 01                	push   $0x1
  801b01:	50                   	push   %eax
  801b02:	56                   	push   %esi
  801b03:	68 e6 28 80 00       	push   $0x8028e6
  801b08:	e8 00 e8 ff ff       	call   80030d <cprintf>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	eb b0                	jmp    801ac2 <_pipeisclosed+0xe>
	}
}
  801b12:	89 c8                	mov    %ecx,%eax
  801b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	57                   	push   %edi
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 18             	sub    $0x18,%esp
  801b25:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b28:	56                   	push   %esi
  801b29:	e8 b6 f6 ff ff       	call   8011e4 <fd2data>
  801b2e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b36:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb 40                	jmp    801b80 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
  801b45:	eb 40                	jmp    801b87 <devpipe_write+0x6b>
  801b47:	89 da                	mov    %ebx,%edx
  801b49:	89 f0                	mov    %esi,%eax
  801b4b:	e8 64 ff ff ff       	call   801ab4 <_pipeisclosed>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	75 ec                	jne    801b40 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b54:	e8 5f f2 ff ff       	call   800db8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b59:	8b 53 04             	mov    0x4(%ebx),%edx
  801b5c:	8b 03                	mov    (%ebx),%eax
  801b5e:	83 c0 20             	add    $0x20,%eax
  801b61:	39 c2                	cmp    %eax,%edx
  801b63:	73 e2                	jae    801b47 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b65:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b6b:	79 05                	jns    801b72 <devpipe_write+0x56>
  801b6d:	4a                   	dec    %edx
  801b6e:	83 ca e0             	or     $0xffffffe0,%edx
  801b71:	42                   	inc    %edx
  801b72:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b75:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801b78:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b7c:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7f:	47                   	inc    %edi
  801b80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b83:	75 d4                	jne    801b59 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b85:	89 f8                	mov    %edi,%eax
}
  801b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5f                   	pop    %edi
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	57                   	push   %edi
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	83 ec 18             	sub    $0x18,%esp
  801b98:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9b:	57                   	push   %edi
  801b9c:	e8 43 f6 ff ff       	call   8011e4 <fd2data>
  801ba1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801ba9:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	eb 41                	jmp    801bf4 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	eb 44                	jmp    801bfb <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbc:	eb 3d                	jmp    801bfb <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bbe:	85 f6                	test   %esi,%esi
  801bc0:	75 f1                	jne    801bb3 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc2:	89 da                	mov    %ebx,%edx
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	e8 e9 fe ff ff       	call   801ab4 <_pipeisclosed>
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	75 e8                	jne    801bb7 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bcf:	e8 e4 f1 ff ff       	call   800db8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bd4:	8b 03                	mov    (%ebx),%eax
  801bd6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd9:	74 e3                	je     801bbe <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bdb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801be0:	79 05                	jns    801be7 <devpipe_read+0x58>
  801be2:	48                   	dec    %eax
  801be3:	83 c8 e0             	or     $0xffffffe0,%eax
  801be6:	40                   	inc    %eax
  801be7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801beb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bee:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801bf1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bf3:	46                   	inc    %esi
  801bf4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf7:	75 db                	jne    801bd4 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bf9:	89 f0                	mov    %esi,%eax
}
  801bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c09:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c0c:	50                   	push   %eax
  801c0d:	ff 75 08             	pushl  0x8(%ebp)
  801c10:	e8 3a f6 ff ff       	call   80124f <fd_lookup>
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 18                	js     801c34 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 fc             	pushl  -0x4(%ebp)
  801c22:	e8 bd f5 ff ff       	call   8011e4 <fd2data>
  801c27:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c2c:	e8 83 fe ff ff       	call   801ab4 <_pipeisclosed>
  801c31:	83 c4 10             	add    $0x10,%esp
}
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	57                   	push   %edi
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 28             	sub    $0x28,%esp
  801c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c45:	50                   	push   %eax
  801c46:	e8 b1 f5 ff ff       	call   8011fc <fd_alloc>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	0f 88 24 01 00 00    	js     801d7c <pipe+0x146>
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	68 07 04 00 00       	push   $0x407
  801c60:	ff 75 f0             	pushl  -0x10(%ebp)
  801c63:	6a 00                	push   $0x0
  801c65:	e8 0b f1 ff ff       	call   800d75 <sys_page_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 05 01 00 00    	js     801d7c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c7d:	50                   	push   %eax
  801c7e:	e8 79 f5 ff ff       	call   8011fc <fd_alloc>
  801c83:	89 c3                	mov    %eax,%ebx
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 c0                	test   %eax,%eax
  801c8a:	0f 88 dc 00 00 00    	js     801d6c <pipe+0x136>
  801c90:	83 ec 04             	sub    $0x4,%esp
  801c93:	68 07 04 00 00       	push   $0x407
  801c98:	ff 75 ec             	pushl  -0x14(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 d3 f0 ff ff       	call   800d75 <sys_page_alloc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	83 c4 10             	add    $0x10,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	0f 88 bd 00 00 00    	js     801d6c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb5:	e8 2a f5 ff ff       	call   8011e4 <fd2data>
  801cba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbc:	83 c4 0c             	add    $0xc,%esp
  801cbf:	68 07 04 00 00       	push   $0x407
  801cc4:	50                   	push   %eax
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 a9 f0 ff ff       	call   800d75 <sys_page_alloc>
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	83 c4 10             	add    $0x10,%esp
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	0f 88 83 00 00 00    	js     801d5c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	ff 75 ec             	pushl  -0x14(%ebp)
  801cdf:	e8 00 f5 ff ff       	call   8011e4 <fd2data>
  801ce4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ceb:	50                   	push   %eax
  801cec:	6a 00                	push   $0x0
  801cee:	56                   	push   %esi
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 3d f0 ff ff       	call   800d33 <sys_page_map>
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	83 c4 20             	add    $0x20,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 4f                	js     801d4e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d08:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d0d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d1d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d22:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d29:	83 ec 0c             	sub    $0xc,%esp
  801d2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2f:	e8 a0 f4 ff ff       	call   8011d4 <fd2num>
  801d34:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801d36:	83 c4 04             	add    $0x4,%esp
  801d39:	ff 75 ec             	pushl  -0x14(%ebp)
  801d3c:	e8 93 f4 ff ff       	call   8011d4 <fd2num>
  801d41:	89 47 04             	mov    %eax,0x4(%edi)
  801d44:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	eb 2e                	jmp    801d7c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	56                   	push   %esi
  801d52:	6a 00                	push   $0x0
  801d54:	e8 98 ef ff ff       	call   800cf1 <sys_page_unmap>
  801d59:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	ff 75 ec             	pushl  -0x14(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 88 ef ff ff       	call   800cf1 <sys_page_unmap>
  801d69:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 78 ef ff ff       	call   800cf1 <sys_page_unmap>
  801d79:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d7c:	89 d8                	mov    %ebx,%eax
  801d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d81:	5b                   	pop    %ebx
  801d82:	5e                   	pop    %esi
  801d83:	5f                   	pop    %edi
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    
	...

00801d88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    

00801d92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d98:	68 fe 28 80 00       	push   $0x8028fe
  801d9d:	ff 75 0c             	pushl  0xc(%ebp)
  801da0:	e8 ba ea ff ff       	call   80085f <strcpy>
	return 0;
}
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
  801daa:	c9                   	leave  
  801dab:	c3                   	ret    

00801dac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	57                   	push   %edi
  801db0:	56                   	push   %esi
  801db1:	53                   	push   %ebx
  801db2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801db8:	be 00 00 00 00       	mov    $0x0,%esi
  801dbd:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801dc3:	eb 2c                	jmp    801df1 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dc8:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801dca:	83 fb 7f             	cmp    $0x7f,%ebx
  801dcd:	76 05                	jbe    801dd4 <devcons_write+0x28>
  801dcf:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd4:	83 ec 04             	sub    $0x4,%esp
  801dd7:	53                   	push   %ebx
  801dd8:	03 45 0c             	add    0xc(%ebp),%eax
  801ddb:	50                   	push   %eax
  801ddc:	57                   	push   %edi
  801ddd:	e8 ea eb ff ff       	call   8009cc <memmove>
		sys_cputs(buf, m);
  801de2:	83 c4 08             	add    $0x8,%esp
  801de5:	53                   	push   %ebx
  801de6:	57                   	push   %edi
  801de7:	e8 b7 ed ff ff       	call   800ba3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dec:	01 de                	add    %ebx,%esi
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df6:	72 cd                	jb     801dc5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e0c:	6a 01                	push   $0x1
  801e0e:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801e11:	50                   	push   %eax
  801e12:	e8 8c ed ff ff       	call   800ba3 <sys_cputs>
  801e17:	83 c4 10             	add    $0x10,%esp
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e26:	74 27                	je     801e4f <devcons_read+0x33>
  801e28:	eb 05                	jmp    801e2f <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e2a:	e8 89 ef ff ff       	call   800db8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2f:	e8 50 ed ff ff       	call   800b84 <sys_cgetc>
  801e34:	89 c2                	mov    %eax,%edx
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 f0                	je     801e2a <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 16                	js     801e54 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3e:	83 f8 04             	cmp    $0x4,%eax
  801e41:	74 0c                	je     801e4f <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e46:	88 10                	mov    %dl,(%eax)
  801e48:	ba 01 00 00 00       	mov    $0x1,%edx
  801e4d:	eb 05                	jmp    801e54 <devcons_read+0x38>
	return 1;
  801e4f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e54:	89 d0                	mov    %edx,%eax
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	e8 95 f3 ff ff       	call   8011fc <fd_alloc>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 3b                	js     801ea9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6e:	83 ec 04             	sub    $0x4,%esp
  801e71:	68 07 04 00 00       	push   $0x407
  801e76:	ff 75 fc             	pushl  -0x4(%ebp)
  801e79:	6a 00                	push   $0x0
  801e7b:	e8 f5 ee ff ff       	call   800d75 <sys_page_alloc>
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 22                	js     801ea9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e87:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801e8c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801e8f:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801e91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9b:	83 ec 0c             	sub    $0xc,%esp
  801e9e:	ff 75 fc             	pushl  -0x4(%ebp)
  801ea1:	e8 2e f3 ff ff       	call   8011d4 <fd2num>
  801ea6:	83 c4 10             	add    $0x10,%esp
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801eb4:	50                   	push   %eax
  801eb5:	ff 75 08             	pushl  0x8(%ebp)
  801eb8:	e8 92 f3 ff ff       	call   80124f <fd_lookup>
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 11                	js     801ed5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ec7:	8b 00                	mov    (%eax),%eax
  801ec9:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801ecf:	0f 94 c0             	sete   %al
  801ed2:	0f b6 c0             	movzbl %al,%eax
}
  801ed5:	c9                   	leave  
  801ed6:	c3                   	ret    

00801ed7 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801edd:	6a 01                	push   $0x1
  801edf:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	e8 a4 f5 ff ff       	call   80148e <read>
	if (r < 0)
  801eea:	83 c4 10             	add    $0x10,%esp
  801eed:	85 c0                	test   %eax,%eax
  801eef:	78 0f                	js     801f00 <getchar+0x29>
		return r;
	if (r < 1)
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	75 07                	jne    801efc <getchar+0x25>
  801ef5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801efa:	eb 04                	jmp    801f00 <getchar+0x29>
		return -E_EOF;
	return c;
  801efc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    
	...

00801f04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f0a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f11:	75 64                	jne    801f77 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801f13:	a1 04 40 80 00       	mov    0x804004,%eax
  801f18:	8b 40 48             	mov    0x48(%eax),%eax
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	6a 07                	push   $0x7
  801f20:	68 00 f0 bf ee       	push   $0xeebff000
  801f25:	50                   	push   %eax
  801f26:	e8 4a ee ff ff       	call   800d75 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  801f2b:	83 c4 10             	add    $0x10,%esp
  801f2e:	85 c0                	test   %eax,%eax
  801f30:	79 14                	jns    801f46 <set_pgfault_handler+0x42>
  801f32:	83 ec 04             	sub    $0x4,%esp
  801f35:	68 0c 29 80 00       	push   $0x80290c
  801f3a:	6a 22                	push   $0x22
  801f3c:	68 78 29 80 00       	push   $0x802978
  801f41:	e8 26 e3 ff ff       	call   80026c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  801f46:	a1 04 40 80 00       	mov    0x804004,%eax
  801f4b:	8b 40 48             	mov    0x48(%eax),%eax
  801f4e:	83 ec 08             	sub    $0x8,%esp
  801f51:	68 84 1f 80 00       	push   $0x801f84
  801f56:	50                   	push   %eax
  801f57:	e8 cf ec ff ff       	call   800c2b <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	79 14                	jns    801f77 <set_pgfault_handler+0x73>
  801f63:	83 ec 04             	sub    $0x4,%esp
  801f66:	68 3c 29 80 00       	push   $0x80293c
  801f6b:	6a 25                	push   $0x25
  801f6d:	68 78 29 80 00       	push   $0x802978
  801f72:	e8 f5 e2 ff ff       	call   80026c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f77:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    
  801f81:	00 00                	add    %al,(%eax)
	...

00801f84 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f84:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f85:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801f8f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f93:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f96:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801f9a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801f9e:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801fa0:	83 c4 08             	add    $0x8,%esp
	popal
  801fa3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801fa4:	83 c4 04             	add    $0x4,%esp
	popfl
  801fa7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fa8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801fa9:	c3                   	ret    
	...

00801fac <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	83 ec 28             	sub    $0x28,%esp
  801fb4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801fbb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801fc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc5:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801fc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fcb:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801fcd:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd8:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fdb:	85 ff                	test   %edi,%edi
  801fdd:	75 21                	jne    802000 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801fdf:	39 d1                	cmp    %edx,%ecx
  801fe1:	76 49                	jbe    80202c <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe3:	f7 f1                	div    %ecx
  801fe5:	89 c1                	mov    %eax,%ecx
  801fe7:	31 c0                	xor    %eax,%eax
  801fe9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fec:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801fef:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ff5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ff8:	83 c4 28             	add    $0x28,%esp
  801ffb:	5e                   	pop    %esi
  801ffc:	5f                   	pop    %edi
  801ffd:	c9                   	leave  
  801ffe:	c3                   	ret    
  801fff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802000:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802003:	0f 87 97 00 00 00    	ja     8020a0 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802009:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80200c:	83 f0 1f             	xor    $0x1f,%eax
  80200f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802012:	75 34                	jne    802048 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802014:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802017:	72 08                	jb     802021 <__udivdi3+0x75>
  802019:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80201c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80201f:	77 7f                	ja     8020a0 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802021:	b9 01 00 00 00       	mov    $0x1,%ecx
  802026:	31 c0                	xor    %eax,%eax
  802028:	eb c2                	jmp    801fec <__udivdi3+0x40>
  80202a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80202c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202f:	85 c0                	test   %eax,%eax
  802031:	74 79                	je     8020ac <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802033:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802036:	89 fa                	mov    %edi,%edx
  802038:	f7 f1                	div    %ecx
  80203a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80203c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80203f:	f7 f1                	div    %ecx
  802041:	89 c1                	mov    %eax,%ecx
  802043:	89 f0                	mov    %esi,%eax
  802045:	eb a5                	jmp    801fec <__udivdi3+0x40>
  802047:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802048:	b8 20 00 00 00       	mov    $0x20,%eax
  80204d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802050:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802053:	89 fa                	mov    %edi,%edx
  802055:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802058:	d3 e2                	shl    %cl,%edx
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802060:	d3 e8                	shr    %cl,%eax
  802062:	89 d7                	mov    %edx,%edi
  802064:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802066:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802069:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80206c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80206e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802071:	d3 e0                	shl    %cl,%eax
  802073:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802076:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802079:	d3 ea                	shr    %cl,%edx
  80207b:	09 d0                	or     %edx,%eax
  80207d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802080:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802083:	d3 ea                	shr    %cl,%edx
  802085:	f7 f7                	div    %edi
  802087:	89 d7                	mov    %edx,%edi
  802089:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  80208c:	f7 e6                	mul    %esi
  80208e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802090:	39 d7                	cmp    %edx,%edi
  802092:	72 38                	jb     8020cc <__udivdi3+0x120>
  802094:	74 27                	je     8020bd <__udivdi3+0x111>
  802096:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802099:	31 c0                	xor    %eax,%eax
  80209b:	e9 4c ff ff ff       	jmp    801fec <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020a0:	31 c9                	xor    %ecx,%ecx
  8020a2:	31 c0                	xor    %eax,%eax
  8020a4:	e9 43 ff ff ff       	jmp    801fec <__udivdi3+0x40>
  8020a9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	f7 75 f4             	divl   -0xc(%ebp)
  8020b6:	89 c1                	mov    %eax,%ecx
  8020b8:	e9 76 ff ff ff       	jmp    802033 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020c0:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	39 f0                	cmp    %esi,%eax
  8020c7:	73 cd                	jae    802096 <__udivdi3+0xea>
  8020c9:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020cf:	49                   	dec    %ecx
  8020d0:	31 c0                	xor    %eax,%eax
  8020d2:	e9 15 ff ff ff       	jmp    801fec <__udivdi3+0x40>
	...

008020d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	57                   	push   %edi
  8020dc:	56                   	push   %esi
  8020dd:	83 ec 30             	sub    $0x30,%esp
  8020e0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8020e7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8020ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8020fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020fd:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8020ff:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  802102:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  802105:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802108:	85 d2                	test   %edx,%edx
  80210a:	75 1c                	jne    802128 <__umoddi3+0x50>
    {
      if (d0 > n1)
  80210c:	89 fa                	mov    %edi,%edx
  80210e:	39 f8                	cmp    %edi,%eax
  802110:	0f 86 c2 00 00 00    	jbe    8021d8 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802116:	89 f0                	mov    %esi,%eax
  802118:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80211a:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  80211d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802124:	eb 12                	jmp    802138 <__umoddi3+0x60>
  802126:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802128:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80212b:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  80212e:	76 18                	jbe    802148 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802130:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  802133:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802136:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802138:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80213b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80213e:	83 c4 30             	add    $0x30,%esp
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	c9                   	leave  
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802148:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  80214c:	83 f0 1f             	xor    $0x1f,%eax
  80214f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802152:	0f 84 ac 00 00 00    	je     802204 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802158:	b8 20 00 00 00       	mov    $0x20,%eax
  80215d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802160:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802163:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802166:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802169:	d3 e2                	shl    %cl,%edx
  80216b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80216e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802171:	d3 e8                	shr    %cl,%eax
  802173:	89 d6                	mov    %edx,%esi
  802175:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  802177:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80217a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80217d:	d3 e0                	shl    %cl,%eax
  80217f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802182:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802185:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802187:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80218a:	d3 e0                	shl    %cl,%eax
  80218c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80218f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802192:	d3 ea                	shr    %cl,%edx
  802194:	09 d0                	or     %edx,%eax
  802196:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802199:	d3 ea                	shr    %cl,%edx
  80219b:	f7 f6                	div    %esi
  80219d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8021a0:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a3:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8021a6:	0f 82 8d 00 00 00    	jb     802239 <__umoddi3+0x161>
  8021ac:	0f 84 91 00 00 00    	je     802243 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021b5:	29 c7                	sub    %eax,%edi
  8021b7:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021b9:	89 f2                	mov    %esi,%edx
  8021bb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021be:	d3 e2                	shl    %cl,%edx
  8021c0:	89 f8                	mov    %edi,%eax
  8021c2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021c5:	d3 e8                	shr    %cl,%eax
  8021c7:	09 c2                	or     %eax,%edx
  8021c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8021cc:	d3 ee                	shr    %cl,%esi
  8021ce:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8021d1:	e9 62 ff ff ff       	jmp    802138 <__umoddi3+0x60>
  8021d6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	74 15                	je     8021f4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021e5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ea:	f7 f1                	div    %ecx
  8021ec:	e9 29 ff ff ff       	jmp    80211a <__umoddi3+0x42>
  8021f1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f9:	31 d2                	xor    %edx,%edx
  8021fb:	f7 75 ec             	divl   -0x14(%ebp)
  8021fe:	89 c1                	mov    %eax,%ecx
  802200:	eb dd                	jmp    8021df <__umoddi3+0x107>
  802202:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802204:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802207:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80220a:	72 19                	jb     802225 <__umoddi3+0x14d>
  80220c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80220f:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  802212:	76 11                	jbe    802225 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  802214:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802217:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80221a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80221d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802220:	e9 13 ff ff ff       	jmp    802138 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802225:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80222e:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802231:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802234:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  802237:	eb db                	jmp    802214 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802239:	2b 45 cc             	sub    -0x34(%ebp),%eax
  80223c:	19 f2                	sbb    %esi,%edx
  80223e:	e9 6f ff ff ff       	jmp    8021b2 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802243:	39 c7                	cmp    %eax,%edi
  802245:	72 f2                	jb     802239 <__umoddi3+0x161>
  802247:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80224a:	e9 63 ff ff ff       	jmp    8021b2 <__umoddi3+0xda>
