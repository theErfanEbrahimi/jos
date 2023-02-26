
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 a7 01 00 00       	call   8001d8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 07                	push   $0x7
  800044:	53                   	push   %ebx
  800045:	56                   	push   %esi
  800046:	e8 fa 0c 00 00       	call   800d45 <sys_page_alloc>
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800052:	50                   	push   %eax
  800053:	68 c0 10 80 00       	push   $0x8010c0
  800058:	6a 20                	push   $0x20
  80005a:	68 d3 10 80 00       	push   $0x8010d3
  80005f:	e8 d8 01 00 00       	call   80023c <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	6a 07                	push   $0x7
  800069:	68 00 00 40 00       	push   $0x400000
  80006e:	6a 00                	push   $0x0
  800070:	53                   	push   %ebx
  800071:	56                   	push   %esi
  800072:	e8 8c 0c 00 00       	call   800d03 <sys_page_map>
  800077:	83 c4 20             	add    $0x20,%esp
  80007a:	85 c0                	test   %eax,%eax
  80007c:	79 12                	jns    800090 <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007e:	50                   	push   %eax
  80007f:	68 e3 10 80 00       	push   $0x8010e3
  800084:	6a 22                	push   $0x22
  800086:	68 d3 10 80 00       	push   $0x8010d3
  80008b:	e8 ac 01 00 00       	call   80023c <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800090:	83 ec 04             	sub    $0x4,%esp
  800093:	68 00 10 00 00       	push   $0x1000
  800098:	53                   	push   %ebx
  800099:	68 00 00 40 00       	push   $0x400000
  80009e:	e8 f9 08 00 00       	call   80099c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	68 00 00 40 00       	push   $0x400000
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 0f 0c 00 00       	call   800cc1 <sys_page_unmap>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 12                	jns    8000cb <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b9:	50                   	push   %eax
  8000ba:	68 f4 10 80 00       	push   $0x8010f4
  8000bf:	6a 25                	push   $0x25
  8000c1:	68 d3 10 80 00       	push   $0x8010d3
  8000c6:	e8 71 01 00 00       	call   80023c <_panic>
}
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 14             	sub    $0x14,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	ba 07 00 00 00       	mov    $0x7,%edx
  8000de:	89 d0                	mov    %edx,%eax
  8000e0:	cd 30                	int    $0x30
  8000e2:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	79 12                	jns    8000fa <dumbfork+0x28>
		panic("sys_exofork: %e", envid);
  8000e8:	50                   	push   %eax
  8000e9:	68 07 11 80 00       	push   $0x801107
  8000ee:	6a 37                	push   $0x37
  8000f0:	68 d3 10 80 00       	push   $0x8010d3
  8000f5:	e8 42 01 00 00       	call   80023c <_panic>
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 22                	jne    800120 <dumbfork+0x4e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 a4 0c 00 00       	call   800da7 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	29 d0                	sub    %edx,%eax
  800114:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800119:	a3 04 20 80 00       	mov    %eax,0x802004
  80011e:	eb 5d                	jmp    80017d <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800120:	c7 45 f8 00 00 80 00 	movl   $0x800000,-0x8(%ebp)
  800127:	eb 14                	jmp    80013d <dumbfork+0x6b>
		duppage(envid, addr);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	50                   	push   %eax
  80012d:	53                   	push   %ebx
  80012e:	e8 01 ff ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800133:	81 45 f8 00 10 00 00 	addl   $0x1000,-0x8(%ebp)
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800140:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800145:	72 e2                	jb     800129 <dumbfork+0x57>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800147:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80014a:	83 ec 08             	sub    $0x8,%esp
  80014d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800152:	50                   	push   %eax
  800153:	53                   	push   %ebx
  800154:	e8 db fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800159:	83 c4 08             	add    $0x8,%esp
  80015c:	6a 02                	push   $0x2
  80015e:	53                   	push   %ebx
  80015f:	e8 1b 0b 00 00       	call   800c7f <sys_env_set_status>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	85 c0                	test   %eax,%eax
  800169:	79 12                	jns    80017d <dumbfork+0xab>
		panic("sys_env_set_status: %e", r);
  80016b:	50                   	push   %eax
  80016c:	68 17 11 80 00       	push   $0x801117
  800171:	6a 4c                	push   $0x4c
  800173:	68 d3 10 80 00       	push   $0x8010d3
  800178:	e8 bf 00 00 00       	call   80023c <_panic>

	return envid;
}
  80017d:	89 d8                	mov    %ebx,%eax
  80017f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800189:	e8 44 ff ff ff       	call   8000d2 <dumbfork>
  80018e:	89 c6                	mov    %eax,%esi
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	eb 28                	jmp    8001bf <umain+0x3b>

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800197:	85 f6                	test   %esi,%esi
  800199:	74 07                	je     8001a2 <umain+0x1e>
  80019b:	b8 2e 11 80 00       	mov    $0x80112e,%eax
  8001a0:	eb 05                	jmp    8001a7 <umain+0x23>
  8001a2:	b8 35 11 80 00       	mov    $0x801135,%eax
  8001a7:	83 ec 04             	sub    $0x4,%esp
  8001aa:	50                   	push   %eax
  8001ab:	53                   	push   %ebx
  8001ac:	68 3b 11 80 00       	push   $0x80113b
  8001b1:	e8 27 01 00 00       	call   8002dd <cprintf>
		sys_yield();
  8001b6:	e8 cd 0b 00 00       	call   800d88 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bb:	43                   	inc    %ebx
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	83 fe 01             	cmp    $0x1,%esi
  8001c2:	19 c0                	sbb    %eax,%eax
  8001c4:	83 e0 0a             	and    $0xa,%eax
  8001c7:	83 c0 0a             	add    $0xa,%eax
  8001ca:	39 c3                	cmp    %eax,%ebx
  8001cc:	7c c9                	jl     800197 <umain+0x13>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    
  8001d5:	00 00                	add    %al,(%eax)
	...

008001d8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8001e3:	e8 bf 0b 00 00       	call   800da7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001f4:	c1 e0 07             	shl    $0x7,%eax
  8001f7:	29 d0                	sub    %edx,%eax
  8001f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001fe:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800203:	85 f6                	test   %esi,%esi
  800205:	7e 07                	jle    80020e <libmain+0x36>
		binaryname = argv[0];
  800207:	8b 03                	mov    (%ebx),%eax
  800209:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	53                   	push   %ebx
  800212:	56                   	push   %esi
  800213:	e8 6c ff ff ff       	call   800184 <umain>

	// exit gracefully
	exit();
  800218:	e8 0b 00 00 00       	call   800228 <exit>
  80021d:	83 c4 10             	add    $0x10,%esp
}
  800220:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	c9                   	leave  
  800226:	c3                   	ret    
	...

00800228 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80022e:	6a 00                	push   $0x0
  800230:	e8 91 0b 00 00       	call   800dc6 <sys_env_destroy>
  800235:	83 c4 10             	add    $0x10,%esp
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    
	...

0080023c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800243:	8d 45 14             	lea    0x14(%ebp),%eax
  800246:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800249:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80024f:	e8 53 0b 00 00       	call   800da7 <sys_getenvid>
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	53                   	push   %ebx
  80025e:	50                   	push   %eax
  80025f:	68 58 11 80 00       	push   $0x801158
  800264:	e8 74 00 00 00       	call   8002dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	ff 75 f8             	pushl  -0x8(%ebp)
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	e8 15 00 00 00       	call   80028c <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 4b 11 80 00 	movl   $0x80114b,(%esp)
  80027e:	e8 5a 00 00 00       	call   8002dd <cprintf>
  800283:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800286:	cc                   	int3   
  800287:	eb fd                	jmp    800286 <_panic+0x4a>
  800289:	00 00                	add    %al,(%eax)
	...

0080028c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800295:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80029c:	00 00 00 
	b.cnt = 0;
  80029f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8002a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	ff 75 08             	pushl  0x8(%ebp)
  8002af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b5:	50                   	push   %eax
  8002b6:	68 f4 02 80 00       	push   $0x8002f4
  8002bb:	e8 70 01 00 00       	call   800430 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c0:	83 c4 08             	add    $0x8,%esp
  8002c3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8002c9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8002cf:	50                   	push   %eax
  8002d0:	e8 9e 08 00 00       	call   800b73 <sys_cputs>
  8002d5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	e8 9a ff ff ff       	call   80028c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 04             	sub    $0x4,%esp
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fe:	8b 03                	mov    (%ebx),%eax
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800307:	40                   	inc    %eax
  800308:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030f:	75 1a                	jne    80032b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	68 ff 00 00 00       	push   $0xff
  800319:	8d 43 08             	lea    0x8(%ebx),%eax
  80031c:	50                   	push   %eax
  80031d:	e8 51 08 00 00       	call   800b73 <sys_cputs>
		b->idx = 0;
  800322:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800328:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80032b:	ff 43 04             	incl   0x4(%ebx)
}
  80032e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800331:	c9                   	leave  
  800332:	c3                   	ret    
	...

00800334 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 1c             	sub    $0x1c,%esp
  80033d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800340:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	8b 55 0c             	mov    0xc(%ebp),%edx
  800349:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80034f:	8b 55 10             	mov    0x10(%ebp),%edx
  800352:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800355:	89 d6                	mov    %edx,%esi
  800357:	bf 00 00 00 00       	mov    $0x0,%edi
  80035c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80035f:	72 04                	jb     800365 <printnum+0x31>
  800361:	39 c2                	cmp    %eax,%edx
  800363:	77 3f                	ja     8003a4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	ff 75 18             	pushl  0x18(%ebp)
  80036b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80036e:	50                   	push   %eax
  80036f:	52                   	push   %edx
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	ff 75 e4             	pushl  -0x1c(%ebp)
  800378:	ff 75 e0             	pushl  -0x20(%ebp)
  80037b:	e8 88 0a 00 00       	call   800e08 <__udivdi3>
  800380:	83 c4 18             	add    $0x18,%esp
  800383:	52                   	push   %edx
  800384:	50                   	push   %eax
  800385:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800388:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80038b:	e8 a4 ff ff ff       	call   800334 <printnum>
  800390:	83 c4 20             	add    $0x20,%esp
  800393:	eb 14                	jmp    8003a9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	ff 75 e8             	pushl  -0x18(%ebp)
  80039b:	ff 75 18             	pushl  0x18(%ebp)
  80039e:	ff 55 ec             	call   *-0x14(%ebp)
  8003a1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a4:	4b                   	dec    %ebx
  8003a5:	85 db                	test   %ebx,%ebx
  8003a7:	7f ec                	jg     800395 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	ff 75 e8             	pushl  -0x18(%ebp)
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ba:	e8 75 0b 00 00       	call   800f34 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 7b 11 80 00 	movsbl 0x80117b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff 55 ec             	call   *-0x14(%ebp)
  8003cd:	83 c4 10             	add    $0x10,%esp
}
  8003d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d3:	5b                   	pop    %ebx
  8003d4:	5e                   	pop    %esi
  8003d5:	5f                   	pop    %edi
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8003dd:	83 fa 01             	cmp    $0x1,%edx
  8003e0:	7e 0e                	jle    8003f0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 42 08             	lea    0x8(%edx),%eax
  8003e7:	89 01                	mov    %eax,(%ecx)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	8b 52 04             	mov    0x4(%edx),%edx
  8003ee:	eb 22                	jmp    800412 <getuint+0x3a>
	else if (lflag)
  8003f0:	85 d2                	test   %edx,%edx
  8003f2:	74 10                	je     800404 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 42 04             	lea    0x4(%edx),%eax
  8003f9:	89 01                	mov    %eax,(%ecx)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800402:	eb 0e                	jmp    800412 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 42 04             	lea    0x4(%edx),%eax
  800409:	89 01                	mov    %eax,(%ecx)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80041a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80041d:	8b 11                	mov    (%ecx),%edx
  80041f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800422:	73 0a                	jae    80042e <sprintputch+0x1a>
		*b->buf++ = ch;
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	88 02                	mov    %al,(%edx)
  800429:	8d 42 01             	lea    0x1(%edx),%eax
  80042c:	89 01                	mov    %eax,(%ecx)
}
  80042e:	c9                   	leave  
  80042f:	c3                   	ret    

00800430 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	57                   	push   %edi
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	83 ec 3c             	sub    $0x3c,%esp
  800439:	8b 75 08             	mov    0x8(%ebp),%esi
  80043c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800442:	eb 1a                	jmp    80045e <vprintfmt+0x2e>
  800444:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800447:	eb 15                	jmp    80045e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800449:	84 c0                	test   %al,%al
  80044b:	0f 84 15 03 00 00    	je     800766 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	57                   	push   %edi
  800455:	0f b6 c0             	movzbl %al,%eax
  800458:	50                   	push   %eax
  800459:	ff d6                	call   *%esi
  80045b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045e:	8a 03                	mov    (%ebx),%al
  800460:	43                   	inc    %ebx
  800461:	3c 25                	cmp    $0x25,%al
  800463:	75 e4                	jne    800449 <vprintfmt+0x19>
  800465:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80046c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800473:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80047a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800481:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800485:	eb 0a                	jmp    800491 <vprintfmt+0x61>
  800487:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80048e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8a 03                	mov    (%ebx),%al
  800493:	0f b6 d0             	movzbl %al,%edx
  800496:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800499:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80049c:	83 e8 23             	sub    $0x23,%eax
  80049f:	3c 55                	cmp    $0x55,%al
  8004a1:	0f 87 9c 02 00 00    	ja     800743 <vprintfmt+0x313>
  8004a7:	0f b6 c0             	movzbl %al,%eax
  8004aa:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
  8004b1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8004b5:	eb d7                	jmp    80048e <vprintfmt+0x5e>
  8004b7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8004bb:	eb d1                	jmp    80048e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8004bd:	89 d9                	mov    %ebx,%ecx
  8004bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004c9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8004cc:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8004d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8004d3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8004d7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8004d8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8004db:	83 f8 09             	cmp    $0x9,%eax
  8004de:	77 21                	ja     800501 <vprintfmt+0xd1>
  8004e0:	eb e4                	jmp    8004c6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e2:	8b 55 14             	mov    0x14(%ebp),%edx
  8004e5:	8d 42 04             	lea    0x4(%edx),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	8b 12                	mov    (%edx),%edx
  8004ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f0:	eb 12                	jmp    800504 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8004f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f6:	79 96                	jns    80048e <vprintfmt+0x5e>
  8004f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ff:	eb 8d                	jmp    80048e <vprintfmt+0x5e>
  800501:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800504:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800508:	79 84                	jns    80048e <vprintfmt+0x5e>
  80050a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800517:	e9 72 ff ff ff       	jmp    80048e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051c:	ff 45 d4             	incl   -0x2c(%ebp)
  80051f:	e9 6a ff ff ff       	jmp    80048e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800524:	8b 55 14             	mov    0x14(%ebp),%edx
  800527:	8d 42 04             	lea    0x4(%edx),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	57                   	push   %edi
  800531:	ff 32                	pushl  (%edx)
  800533:	ff d6                	call   *%esi
			break;
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	e9 07 ff ff ff       	jmp    800444 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053d:	8b 55 14             	mov    0x14(%ebp),%edx
  800540:	8d 42 04             	lea    0x4(%edx),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	8b 02                	mov    (%edx),%eax
  800548:	85 c0                	test   %eax,%eax
  80054a:	79 02                	jns    80054e <vprintfmt+0x11e>
  80054c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80054e:	83 f8 0f             	cmp    $0xf,%eax
  800551:	7f 0b                	jg     80055e <vprintfmt+0x12e>
  800553:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  80055a:	85 d2                	test   %edx,%edx
  80055c:	75 15                	jne    800573 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80055e:	50                   	push   %eax
  80055f:	68 8c 11 80 00       	push   $0x80118c
  800564:	57                   	push   %edi
  800565:	56                   	push   %esi
  800566:	e8 6e 02 00 00       	call   8007d9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	e9 d1 fe ff ff       	jmp    800444 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800573:	52                   	push   %edx
  800574:	68 95 11 80 00       	push   $0x801195
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	e8 59 02 00 00       	call   8007d9 <printfmt>
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	e9 bc fe ff ff       	jmp    800444 <vprintfmt+0x14>
  800588:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80058e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800591:	8b 55 14             	mov    0x14(%ebp),%edx
  800594:	8d 42 04             	lea    0x4(%edx),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
  80059a:	8b 1a                	mov    (%edx),%ebx
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	75 05                	jne    8005a5 <vprintfmt+0x175>
  8005a0:	bb 98 11 80 00       	mov    $0x801198,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8005a5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8005a9:	7e 66                	jle    800611 <vprintfmt+0x1e1>
  8005ab:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8005af:	74 60                	je     800611 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	51                   	push   %ecx
  8005b5:	53                   	push   %ebx
  8005b6:	e8 57 02 00 00       	call   800812 <strnlen>
  8005bb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8005be:	29 c1                	sub    %eax,%ecx
  8005c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005ca:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005cd:	eb 0f                	jmp    8005de <vprintfmt+0x1ae>
					putch(padc, putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	57                   	push   %edi
  8005d3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8005d6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	ff 4d d8             	decl   -0x28(%ebp)
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e2:	7f eb                	jg     8005cf <vprintfmt+0x19f>
  8005e4:	eb 2b                	jmp    800611 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ed:	74 15                	je     800604 <vprintfmt+0x1d4>
  8005ef:	8d 42 e0             	lea    -0x20(%edx),%eax
  8005f2:	83 f8 5e             	cmp    $0x5e,%eax
  8005f5:	76 0d                	jbe    800604 <vprintfmt+0x1d4>
					putch('?', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 3f                	push   $0x3f
  8005fd:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	eb 0a                	jmp    80060e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	57                   	push   %edi
  800608:	52                   	push   %edx
  800609:	ff d6                	call   *%esi
  80060b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	ff 4d d8             	decl   -0x28(%ebp)
  800611:	8a 03                	mov    (%ebx),%al
  800613:	43                   	inc    %ebx
  800614:	84 c0                	test   %al,%al
  800616:	74 1b                	je     800633 <vprintfmt+0x203>
  800618:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061c:	78 c8                	js     8005e6 <vprintfmt+0x1b6>
  80061e:	ff 4d dc             	decl   -0x24(%ebp)
  800621:	79 c3                	jns    8005e6 <vprintfmt+0x1b6>
  800623:	eb 0e                	jmp    800633 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	57                   	push   %edi
  800629:	6a 20                	push   $0x20
  80062b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062d:	ff 4d d8             	decl   -0x28(%ebp)
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800637:	7f ec                	jg     800625 <vprintfmt+0x1f5>
  800639:	e9 06 fe ff ff       	jmp    800444 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800642:	7e 10                	jle    800654 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800644:	8b 55 14             	mov    0x14(%ebp),%edx
  800647:	8d 42 08             	lea    0x8(%edx),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	8b 02                	mov    (%edx),%eax
  80064f:	8b 52 04             	mov    0x4(%edx),%edx
  800652:	eb 20                	jmp    800674 <vprintfmt+0x244>
	else if (lflag)
  800654:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800658:	74 0e                	je     800668 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	99                   	cltd   
  800666:	eb 0c                	jmp    800674 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	89 d1                	mov    %edx,%ecx
  800676:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800678:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80067b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	78 0a                	js     80068c <vprintfmt+0x25c>
  800682:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800687:	e9 89 00 00 00       	jmp    800715 <vprintfmt+0x2e5>
				putch('-', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	57                   	push   %edi
  800690:	6a 2d                	push   $0x2d
  800692:	ff d6                	call   *%esi
				num = -(long long) num;
  800694:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800697:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80069a:	f7 da                	neg    %edx
  80069c:	83 d1 00             	adc    $0x0,%ecx
  80069f:	f7 d9                	neg    %ecx
  8006a1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	eb 6a                	jmp    800715 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b1:	e8 22 fd ff ff       	call   8003d8 <getuint>
  8006b6:	89 d1                	mov    %edx,%ecx
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006bf:	eb 54                	jmp    800715 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006c7:	e8 0c fd ff ff       	call   8003d8 <getuint>
  8006cc:	89 d1                	mov    %edx,%ecx
  8006ce:	89 c2                	mov    %eax,%edx
  8006d0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8006d5:	eb 3e                	jmp    800715 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 30                	push   $0x30
  8006dd:	ff d6                	call   *%esi
			putch('x', putdat);
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 78                	push   $0x78
  8006e5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006e7:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ea:	8d 42 04             	lea    0x4(%edx),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f0:	8b 12                	mov    (%edx),%edx
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 14                	jmp    800715 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
  800704:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800707:	e8 cc fc ff ff       	call   8003d8 <getuint>
  80070c:	89 d1                	mov    %edx,%ecx
  80070e:	89 c2                	mov    %eax,%edx
  800710:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800715:	83 ec 0c             	sub    $0xc,%esp
  800718:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	ff 75 d8             	pushl  -0x28(%ebp)
  800720:	53                   	push   %ebx
  800721:	51                   	push   %ecx
  800722:	52                   	push   %edx
  800723:	89 fa                	mov    %edi,%edx
  800725:	89 f0                	mov    %esi,%eax
  800727:	e8 08 fc ff ff       	call   800334 <printnum>
			break;
  80072c:	83 c4 20             	add    $0x20,%esp
  80072f:	e9 10 fd ff ff       	jmp    800444 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	57                   	push   %edi
  800738:	52                   	push   %edx
  800739:	ff d6                	call   *%esi
			break;
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	e9 01 fd ff ff       	jmp    800444 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	57                   	push   %edi
  800747:	6a 25                	push   $0x25
  800749:	ff d6                	call   *%esi
  80074b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80074e:	83 ea 02             	sub    $0x2,%edx
  800751:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	8a 02                	mov    (%edx),%al
  800756:	4a                   	dec    %edx
  800757:	3c 25                	cmp    $0x25,%al
  800759:	75 f9                	jne    800754 <vprintfmt+0x324>
  80075b:	83 c2 02             	add    $0x2,%edx
  80075e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800761:	e9 de fc ff ff       	jmp    800444 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 18             	sub    $0x18,%esp
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 37                	je     8007b5 <vsnprintf+0x47>
  80077e:	85 c0                	test   %eax,%eax
  800780:	7e 33                	jle    8007b5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800782:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800789:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80078d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800790:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800793:	ff 75 14             	pushl  0x14(%ebp)
  800796:	ff 75 10             	pushl  0x10(%ebp)
  800799:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	68 14 04 80 00       	push   $0x800414
  8007a2:	e8 89 fc ff ff       	call   800430 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb 05                	jmp    8007ba <vsnprintf+0x4c>
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007c8:	50                   	push   %eax
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	ff 75 08             	pushl  0x8(%ebp)
  8007d2:	e8 97 ff ff ff       	call   80076e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 3c fc ff ff       	call   800430 <vprintfmt>
	va_end(ap);
  8007f4:	83 c4 10             	add    $0x10,%esp
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    
  8007f9:	00 00                	add    %al,(%eax)
	...

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 01                	jmp    80080a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800809:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80080e:	75 f9                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 01                	jmp    800823 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800822:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	39 d0                	cmp    %edx,%eax
  800825:	74 06                	je     80082d <strnlen+0x1b>
  800827:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80082b:	75 f5                	jne    800822 <strnlen+0x10>
		n++;
	return n;
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800838:	8a 01                	mov    (%ecx),%al
  80083a:	88 02                	mov    %al,(%edx)
  80083c:	42                   	inc    %edx
  80083d:	41                   	inc    %ecx
  80083e:	84 c0                	test   %al,%al
  800840:	75 f6                	jne    800838 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084e:	53                   	push   %ebx
  80084f:	e8 a8 ff ff ff       	call   8007fc <strlen>
	strcpy(dst + len, src);
  800854:	ff 75 0c             	pushl  0xc(%ebp)
  800857:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80085a:	50                   	push   %eax
  80085b:	e8 cf ff ff ff       	call   80082f <strcpy>
	return dst;
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	eb 0c                	jmp    800888 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80087c:	8a 02                	mov    (%edx),%al
  80087e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800881:	80 3a 01             	cmpb   $0x1,(%edx)
  800884:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	41                   	inc    %ecx
  800888:	39 d9                	cmp    %ebx,%ecx
  80088a:	75 f0                	jne    80087c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	5b                   	pop    %ebx
  80088f:	5e                   	pop    %esi
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 75 08             	mov    0x8(%ebp),%esi
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80089d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	85 c9                	test   %ecx,%ecx
  8008a2:	75 04                	jne    8008a8 <strlcpy+0x16>
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	eb 14                	jmp    8008bc <strlcpy+0x2a>
  8008a8:	89 f0                	mov    %esi,%eax
  8008aa:	eb 04                	jmp    8008b0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ac:	88 10                	mov    %dl,(%eax)
  8008ae:	40                   	inc    %eax
  8008af:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b0:	49                   	dec    %ecx
  8008b1:	74 06                	je     8008b9 <strlcpy+0x27>
  8008b3:	8a 13                	mov    (%ebx),%dl
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f3                	jne    8008ac <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 00 00             	movb   $0x0,(%eax)
  8008bc:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8008c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cb:	eb 02                	jmp    8008cf <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8008cd:	42                   	inc    %edx
  8008ce:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	8a 02                	mov    (%edx),%al
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x17>
  8008d5:	3a 01                	cmp    (%ecx),%al
  8008d7:	74 f4                	je     8008cd <strcmp+0xb>
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 11             	movzbl (%ecx),%edx
  8008df:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f0:	eb 03                	jmp    8008f5 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8008f2:	4a                   	dec    %edx
  8008f3:	41                   	inc    %ecx
  8008f4:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	75 07                	jne    800900 <strncmp+0x1d>
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb 14                	jmp    800914 <strncmp+0x31>
  800900:	8a 01                	mov    (%ecx),%al
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strncmp+0x27>
  800906:	3a 03                	cmp    (%ebx),%al
  800908:	74 e8                	je     8008f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 d0             	movzbl %al,%edx
  80090d:	0f b6 03             	movzbl (%ebx),%eax
  800910:	29 c2                	sub    %eax,%edx
  800912:	89 d0                	mov    %edx,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800920:	eb 05                	jmp    800927 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800922:	38 ca                	cmp    %cl,%dl
  800924:	74 0c                	je     800932 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800926:	40                   	inc    %eax
  800927:	8a 10                	mov    (%eax),%dl
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f5                	jne    800922 <strchr+0xb>
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80093d:	eb 05                	jmp    800944 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	74 07                	je     80094a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800943:	40                   	inc    %eax
  800944:	8a 10                	mov    (%eax),%dl
  800946:	84 d2                	test   %dl,%dl
  800948:	75 f5                	jne    80093f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80095b:	85 db                	test   %ebx,%ebx
  80095d:	74 36                	je     800995 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800965:	75 29                	jne    800990 <memset+0x44>
  800967:	f6 c3 03             	test   $0x3,%bl
  80096a:	75 24                	jne    800990 <memset+0x44>
		c &= 0xFF;
  80096c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80096f:	89 d6                	mov    %edx,%esi
  800971:	c1 e6 08             	shl    $0x8,%esi
  800974:	89 d0                	mov    %edx,%eax
  800976:	c1 e0 18             	shl    $0x18,%eax
  800979:	89 d1                	mov    %edx,%ecx
  80097b:	c1 e1 10             	shl    $0x10,%ecx
  80097e:	09 c8                	or     %ecx,%eax
  800980:	09 c2                	or     %eax,%edx
  800982:	89 f0                	mov    %esi,%eax
  800984:	09 d0                	or     %edx,%eax
  800986:	89 d9                	mov    %ebx,%ecx
  800988:	c1 e9 02             	shr    $0x2,%ecx
  80098b:	fc                   	cld    
  80098c:	f3 ab                	rep stos %eax,%es:(%edi)
  80098e:	eb 05                	jmp    800995 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800990:	89 d9                	mov    %ebx,%ecx
  800992:	fc                   	cld    
  800993:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800995:	89 f8                	mov    %edi,%eax
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8009a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009aa:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009ac:	39 c6                	cmp    %eax,%esi
  8009ae:	73 36                	jae    8009e6 <memmove+0x4a>
  8009b0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b3:	39 d0                	cmp    %edx,%eax
  8009b5:	73 2f                	jae    8009e6 <memmove+0x4a>
		s += n;
		d += n;
  8009b7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f6 c2 03             	test   $0x3,%dl
  8009bd:	75 1b                	jne    8009da <memmove+0x3e>
  8009bf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c5:	75 13                	jne    8009da <memmove+0x3e>
  8009c7:	f6 c1 03             	test   $0x3,%cl
  8009ca:	75 0e                	jne    8009da <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8009cc:	8d 7e fc             	lea    -0x4(%esi),%edi
  8009cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
  8009d5:	fd                   	std    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb 09                	jmp    8009e3 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009da:	8d 7e ff             	lea    -0x1(%esi),%edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 20                	jmp    800a06 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 15                	jne    800a03 <memmove+0x67>
  8009ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f4:	75 0d                	jne    800a03 <memmove+0x67>
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 08                	jne    800a03 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
  8009fe:	fc                   	cld    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 03                	jmp    800a06 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	fc                   	cld    
  800a04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0d:	ff 75 10             	pushl  0x10(%ebp)
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	ff 75 08             	pushl  0x8(%ebp)
  800a16:	e8 81 ff ff ff       	call   80099c <memmove>
}
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	53                   	push   %ebx
  800a21:	83 ec 04             	sub    $0x4,%esp
  800a24:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	eb 1b                	jmp    800a4a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800a2f:	8a 1a                	mov    (%edx),%bl
  800a31:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800a34:	8a 19                	mov    (%ecx),%bl
  800a36:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800a39:	74 0d                	je     800a48 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800a3b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800a3f:	0f b6 c3             	movzbl %bl,%eax
  800a42:	29 c2                	sub    %eax,%edx
  800a44:	89 d0                	mov    %edx,%eax
  800a46:	eb 0d                	jmp    800a55 <memcmp+0x38>
		s1++, s2++;
  800a48:	42                   	inc    %edx
  800a49:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	48                   	dec    %eax
  800a4b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800a4e:	75 df                	jne    800a2f <memcmp+0x12>
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a55:	83 c4 04             	add    $0x4,%esp
  800a58:	5b                   	pop    %ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a64:	89 c2                	mov    %eax,%edx
  800a66:	03 55 10             	add    0x10(%ebp),%edx
  800a69:	eb 05                	jmp    800a70 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6b:	38 08                	cmp    %cl,(%eax)
  800a6d:	74 05                	je     800a74 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6f:	40                   	inc    %eax
  800a70:	39 d0                	cmp    %edx,%eax
  800a72:	72 f7                	jb     800a6b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	83 ec 04             	sub    $0x4,%esp
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
  800a85:	eb 01                	jmp    800a88 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a87:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a88:	8a 01                	mov    (%ecx),%al
  800a8a:	3c 20                	cmp    $0x20,%al
  800a8c:	74 f9                	je     800a87 <strtol+0x11>
  800a8e:	3c 09                	cmp    $0x9,%al
  800a90:	74 f5                	je     800a87 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a92:	3c 2b                	cmp    $0x2b,%al
  800a94:	75 0a                	jne    800aa0 <strtol+0x2a>
		s++;
  800a96:	41                   	inc    %ecx
  800a97:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a9e:	eb 17                	jmp    800ab7 <strtol+0x41>
	else if (*s == '-')
  800aa0:	3c 2d                	cmp    $0x2d,%al
  800aa2:	74 09                	je     800aad <strtol+0x37>
  800aa4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aab:	eb 0a                	jmp    800ab7 <strtol+0x41>
		s++, neg = 1;
  800aad:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ab0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab7:	85 f6                	test   %esi,%esi
  800ab9:	74 05                	je     800ac0 <strtol+0x4a>
  800abb:	83 fe 10             	cmp    $0x10,%esi
  800abe:	75 1a                	jne    800ada <strtol+0x64>
  800ac0:	8a 01                	mov    (%ecx),%al
  800ac2:	3c 30                	cmp    $0x30,%al
  800ac4:	75 10                	jne    800ad6 <strtol+0x60>
  800ac6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aca:	75 0a                	jne    800ad6 <strtol+0x60>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	be 10 00 00 00       	mov    $0x10,%esi
  800ad4:	eb 04                	jmp    800ada <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800ad6:	85 f6                	test   %esi,%esi
  800ad8:	74 07                	je     800ae1 <strtol+0x6b>
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	eb 13                	jmp    800af4 <strtol+0x7e>
  800ae1:	3c 30                	cmp    $0x30,%al
  800ae3:	74 07                	je     800aec <strtol+0x76>
  800ae5:	be 0a 00 00 00       	mov    $0xa,%esi
  800aea:	eb ee                	jmp    800ada <strtol+0x64>
		s++, base = 8;
  800aec:	41                   	inc    %ecx
  800aed:	be 08 00 00 00       	mov    $0x8,%esi
  800af2:	eb e6                	jmp    800ada <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af4:	8a 11                	mov    (%ecx),%dl
  800af6:	88 d3                	mov    %dl,%bl
  800af8:	8d 42 d0             	lea    -0x30(%edx),%eax
  800afb:	3c 09                	cmp    $0x9,%al
  800afd:	77 08                	ja     800b07 <strtol+0x91>
			dig = *s - '0';
  800aff:	0f be c2             	movsbl %dl,%eax
  800b02:	8d 50 d0             	lea    -0x30(%eax),%edx
  800b05:	eb 1c                	jmp    800b23 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b07:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800b0a:	3c 19                	cmp    $0x19,%al
  800b0c:	77 08                	ja     800b16 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800b0e:	0f be c2             	movsbl %dl,%eax
  800b11:	8d 50 a9             	lea    -0x57(%eax),%edx
  800b14:	eb 0d                	jmp    800b23 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b16:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800b19:	3c 19                	cmp    $0x19,%al
  800b1b:	77 15                	ja     800b32 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800b1d:	0f be c2             	movsbl %dl,%eax
  800b20:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800b23:	39 f2                	cmp    %esi,%edx
  800b25:	7d 0b                	jge    800b32 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800b27:	41                   	inc    %ecx
  800b28:	89 f8                	mov    %edi,%eax
  800b2a:	0f af c6             	imul   %esi,%eax
  800b2d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800b30:	eb c2                	jmp    800af4 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800b32:	89 f8                	mov    %edi,%eax

	if (endptr)
  800b34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b38:	74 05                	je     800b3f <strtol+0xc9>
		*endptr = (char *) s;
  800b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800b3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b43:	74 04                	je     800b49 <strtol+0xd3>
  800b45:	89 c7                	mov    %eax,%edi
  800b47:	f7 df                	neg    %edi
}
  800b49:	89 f8                	mov    %edi,%eax
  800b4b:	83 c4 04             	add    $0x4,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    
	...

00800b54 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b64:	89 fa                	mov    %edi,%edx
  800b66:	89 f9                	mov    %edi,%ecx
  800b68:	89 fb                	mov    %edi,%ebx
  800b6a:	89 fe                	mov    %edi,%esi
  800b6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 04             	sub    $0x4,%esp
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	89 f8                	mov    %edi,%eax
  800b89:	89 fb                	mov    %edi,%ebx
  800b8b:	89 fe                	mov    %edi,%esi
  800b8d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8f:	83 c4 04             	add    $0x4,%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ba8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bad:	89 f9                	mov    %edi,%ecx
  800baf:	89 fb                	mov    %edi,%ebx
  800bb1:	89 fe                	mov    %edi,%esi
  800bb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7e 17                	jle    800bd0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	50                   	push   %eax
  800bbd:	6a 0d                	push   $0xd
  800bbf:	68 80 14 80 00       	push   $0x801480
  800bc4:	6a 23                	push   $0x23
  800bc6:	68 9d 14 80 00       	push   $0x80149d
  800bcb:	e8 6c f6 ff ff       	call   80023c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be7:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bef:	be 00 00 00 00       	mov    $0x0,%esi
  800bf4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	89 fb                	mov    %edi,%ebx
  800c16:	89 fe                	mov    %edi,%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 0a                	push   $0xa
  800c24:	68 80 14 80 00       	push   $0x801480
  800c29:	6a 23                	push   $0x23
  800c2b:	68 9d 14 80 00       	push   $0x80149d
  800c30:	e8 07 f6 ff ff       	call   80023c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c51:	bf 00 00 00 00       	mov    $0x0,%edi
  800c56:	89 fb                	mov    %edi,%ebx
  800c58:	89 fe                	mov    %edi,%esi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 09                	push   $0x9
  800c66:	68 80 14 80 00       	push   $0x801480
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 9d 14 80 00       	push   $0x80149d
  800c72:	e8 c5 f5 ff ff       	call   80023c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
  800c98:	89 fb                	mov    %edi,%ebx
  800c9a:	89 fe                	mov    %edi,%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 08                	push   $0x8
  800ca8:	68 80 14 80 00       	push   $0x801480
  800cad:	6a 23                	push   $0x23
  800caf:	68 9d 14 80 00       	push   $0x80149d
  800cb4:	e8 83 f5 ff ff       	call   80023c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd5:	bf 00 00 00 00       	mov    $0x0,%edi
  800cda:	89 fb                	mov    %edi,%ebx
  800cdc:	89 fe                	mov    %edi,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 06                	push   $0x6
  800cea:	68 80 14 80 00       	push   $0x801480
  800cef:	6a 23                	push   $0x23
  800cf1:	68 9d 14 80 00       	push   $0x80149d
  800cf6:	e8 41 f5 ff ff       	call   80023c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d18:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 05                	push   $0x5
  800d2c:	68 80 14 80 00       	push   $0x801480
  800d31:	6a 23                	push   $0x23
  800d33:	68 9d 14 80 00       	push   $0x80149d
  800d38:	e8 ff f4 ff ff       	call   80023c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d61:	89 fe                	mov    %edi,%esi
  800d63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 17                	jle    800d80 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	83 ec 0c             	sub    $0xc,%esp
  800d6c:	50                   	push   %eax
  800d6d:	6a 04                	push   $0x4
  800d6f:	68 80 14 80 00       	push   $0x801480
  800d74:	6a 23                	push   $0x23
  800d76:	68 9d 14 80 00       	push   $0x80149d
  800d7b:	e8 bc f4 ff ff       	call   80023c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d93:	bf 00 00 00 00       	mov    $0x0,%edi
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	89 f9                	mov    %edi,%ecx
  800d9c:	89 fb                	mov    %edi,%ebx
  800d9e:	89 fe                	mov    %edi,%esi
  800da0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b8 02 00 00 00       	mov    $0x2,%eax
  800db2:	bf 00 00 00 00       	mov    $0x0,%edi
  800db7:	89 fa                	mov    %edi,%edx
  800db9:	89 f9                	mov    %edi,%ecx
  800dbb:	89 fb                	mov    %edi,%ebx
  800dbd:	89 fe                	mov    %edi,%esi
  800dbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddc:	89 f9                	mov    %edi,%ecx
  800dde:	89 fb                	mov    %edi,%ebx
  800de0:	89 fe                	mov    %edi,%esi
  800de2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 17                	jle    800dff <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 03                	push   $0x3
  800dee:	68 80 14 80 00       	push   $0x801480
  800df3:	6a 23                	push   $0x23
  800df5:	68 9d 14 80 00       	push   $0x80149d
  800dfa:	e8 3d f4 ff ff       	call   80023c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    
	...

00800e08 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	83 ec 28             	sub    $0x28,%esp
  800e10:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800e17:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800e1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e21:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e27:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800e29:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800e31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e34:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e37:	85 ff                	test   %edi,%edi
  800e39:	75 21                	jne    800e5c <__udivdi3+0x54>
    {
      if (d0 > n1)
  800e3b:	39 d1                	cmp    %edx,%ecx
  800e3d:	76 49                	jbe    800e88 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e3f:	f7 f1                	div    %ecx
  800e41:	89 c1                	mov    %eax,%ecx
  800e43:	31 c0                	xor    %eax,%eax
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e48:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800e4b:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800e51:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800e54:	83 c4 28             	add    $0x28,%esp
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    
  800e5b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e5c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800e5f:	0f 87 97 00 00 00    	ja     800efc <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e65:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e68:	83 f0 1f             	xor    $0x1f,%eax
  800e6b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e6e:	75 34                	jne    800ea4 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e70:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800e73:	72 08                	jb     800e7d <__udivdi3+0x75>
  800e75:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e78:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e7b:	77 7f                	ja     800efc <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e7d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800e82:	31 c0                	xor    %eax,%eax
  800e84:	eb c2                	jmp    800e48 <__udivdi3+0x40>
  800e86:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	74 79                	je     800f08 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e92:	89 fa                	mov    %edi,%edx
  800e94:	f7 f1                	div    %ecx
  800e96:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e9b:	f7 f1                	div    %ecx
  800e9d:	89 c1                	mov    %eax,%ecx
  800e9f:	89 f0                	mov    %esi,%eax
  800ea1:	eb a5                	jmp    800e48 <__udivdi3+0x40>
  800ea3:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ea4:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea9:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800eaf:	89 fa                	mov    %edi,%edx
  800eb1:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eb4:	d3 e2                	shl    %cl,%edx
  800eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb9:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800ebc:	d3 e8                	shr    %cl,%eax
  800ebe:	89 d7                	mov    %edx,%edi
  800ec0:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800ec2:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800ec5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ec8:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800eca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ecd:	d3 e0                	shl    %cl,%eax
  800ecf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ed2:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800ed5:	d3 ea                	shr    %cl,%edx
  800ed7:	09 d0                	or     %edx,%eax
  800ed9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800edc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800edf:	d3 ea                	shr    %cl,%edx
  800ee1:	f7 f7                	div    %edi
  800ee3:	89 d7                	mov    %edx,%edi
  800ee5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800ee8:	f7 e6                	mul    %esi
  800eea:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eec:	39 d7                	cmp    %edx,%edi
  800eee:	72 38                	jb     800f28 <__udivdi3+0x120>
  800ef0:	74 27                	je     800f19 <__udivdi3+0x111>
  800ef2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ef5:	31 c0                	xor    %eax,%eax
  800ef7:	e9 4c ff ff ff       	jmp    800e48 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800efc:	31 c9                	xor    %ecx,%ecx
  800efe:	31 c0                	xor    %eax,%eax
  800f00:	e9 43 ff ff ff       	jmp    800e48 <__udivdi3+0x40>
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f08:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0d:	31 d2                	xor    %edx,%edx
  800f0f:	f7 75 f4             	divl   -0xc(%ebp)
  800f12:	89 c1                	mov    %eax,%ecx
  800f14:	e9 76 ff ff ff       	jmp    800e8f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1c:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f1f:	d3 e0                	shl    %cl,%eax
  800f21:	39 f0                	cmp    %esi,%eax
  800f23:	73 cd                	jae    800ef2 <__udivdi3+0xea>
  800f25:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f28:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800f2b:	49                   	dec    %ecx
  800f2c:	31 c0                	xor    %eax,%eax
  800f2e:	e9 15 ff ff ff       	jmp    800e48 <__udivdi3+0x40>
	...

00800f34 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	83 ec 30             	sub    $0x30,%esp
  800f3c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800f43:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f4a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f50:	8b 45 10             	mov    0x10(%ebp),%eax
  800f53:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800f56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f59:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800f5b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800f5e:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800f61:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f64:	85 d2                	test   %edx,%edx
  800f66:	75 1c                	jne    800f84 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800f68:	89 fa                	mov    %edi,%edx
  800f6a:	39 f8                	cmp    %edi,%eax
  800f6c:	0f 86 c2 00 00 00    	jbe    801034 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f72:	89 f0                	mov    %esi,%eax
  800f74:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800f76:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800f79:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f80:	eb 12                	jmp    800f94 <__umoddi3+0x60>
  800f82:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f84:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f87:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800f8a:	76 18                	jbe    800fa4 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f8c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800f8f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f92:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f94:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f9a:	83 c4 30             	add    $0x30,%esp
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fa4:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800fa8:	83 f0 1f             	xor    $0x1f,%eax
  800fab:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fae:	0f 84 ac 00 00 00    	je     801060 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb9:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800fbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fbf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fc2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800fc5:	d3 e2                	shl    %cl,%edx
  800fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fca:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fcd:	d3 e8                	shr    %cl,%eax
  800fcf:	89 d6                	mov    %edx,%esi
  800fd1:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800fd9:	d3 e0                	shl    %cl,%eax
  800fdb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fde:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800fe1:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fe3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe6:	d3 e0                	shl    %cl,%eax
  800fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800feb:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fee:	d3 ea                	shr    %cl,%edx
  800ff0:	09 d0                	or     %edx,%eax
  800ff2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ff5:	d3 ea                	shr    %cl,%edx
  800ff7:	f7 f6                	div    %esi
  800ff9:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800ffc:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fff:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801002:	0f 82 8d 00 00 00    	jb     801095 <__umoddi3+0x161>
  801008:	0f 84 91 00 00 00    	je     80109f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80100e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801011:	29 c7                	sub    %eax,%edi
  801013:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801015:	89 f2                	mov    %esi,%edx
  801017:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80101a:	d3 e2                	shl    %cl,%edx
  80101c:	89 f8                	mov    %edi,%eax
  80101e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801021:	d3 e8                	shr    %cl,%eax
  801023:	09 c2                	or     %eax,%edx
  801025:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801028:	d3 ee                	shr    %cl,%esi
  80102a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80102d:	e9 62 ff ff ff       	jmp    800f94 <__umoddi3+0x60>
  801032:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801034:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801037:	85 c0                	test   %eax,%eax
  801039:	74 15                	je     801050 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80103b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80103e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801041:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801046:	f7 f1                	div    %ecx
  801048:	e9 29 ff ff ff       	jmp    800f76 <__umoddi3+0x42>
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801050:	b8 01 00 00 00       	mov    $0x1,%eax
  801055:	31 d2                	xor    %edx,%edx
  801057:	f7 75 ec             	divl   -0x14(%ebp)
  80105a:	89 c1                	mov    %eax,%ecx
  80105c:	eb dd                	jmp    80103b <__umoddi3+0x107>
  80105e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801060:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801063:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801066:	72 19                	jb     801081 <__umoddi3+0x14d>
  801068:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80106b:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80106e:	76 11                	jbe    801081 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801070:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801073:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801076:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801079:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80107c:	e9 13 ff ff ff       	jmp    800f94 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801081:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801084:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801087:	2b 45 ec             	sub    -0x14(%ebp),%eax
  80108a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  80108d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801090:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801093:	eb db                	jmp    801070 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801095:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801098:	19 f2                	sbb    %esi,%edx
  80109a:	e9 6f ff ff ff       	jmp    80100e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80109f:	39 c7                	cmp    %eax,%edi
  8010a1:	72 f2                	jb     801095 <__umoddi3+0x161>
  8010a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010a6:	e9 63 ff ff ff       	jmp    80100e <__umoddi3+0xda>
