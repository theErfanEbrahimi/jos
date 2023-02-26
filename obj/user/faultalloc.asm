
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 9b 00 00 00       	call   8000cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80003a:	68 6d 00 80 00       	push   $0x80006d
  80003f:	e8 b8 0c 00 00       	call   800cfc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800044:	83 c4 08             	add    $0x8,%esp
  800047:	68 ef be ad de       	push   $0xdeadbeef
  80004c:	68 60 10 80 00       	push   $0x801060
  800051:	e8 7b 01 00 00       	call   8001d1 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  800056:	83 c4 08             	add    $0x8,%esp
  800059:	68 fe bf fe ca       	push   $0xcafebffe
  80005e:	68 60 10 80 00       	push   $0x801060
  800063:	e8 69 01 00 00       	call   8001d1 <cprintf>
  800068:	83 c4 10             	add    $0x10,%esp
}
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	53                   	push   %ebx
  800071:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800074:	8b 45 08             	mov    0x8(%ebp),%eax
  800077:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800079:	53                   	push   %ebx
  80007a:	68 64 10 80 00       	push   $0x801064
  80007f:	e8 4d 01 00 00       	call   8001d1 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800084:	83 c4 0c             	add    $0xc,%esp
  800087:	6a 07                	push   $0x7
  800089:	89 d8                	mov    %ebx,%eax
  80008b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800090:	50                   	push   %eax
  800091:	6a 00                	push   $0x0
  800093:	e8 a1 0b 00 00       	call   800c39 <sys_page_alloc>
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	85 c0                	test   %eax,%eax
  80009d:	79 16                	jns    8000b5 <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	50                   	push   %eax
  8000a3:	53                   	push   %ebx
  8000a4:	68 80 10 80 00       	push   $0x801080
  8000a9:	6a 0e                	push   $0xe
  8000ab:	68 6e 10 80 00       	push   $0x80106e
  8000b0:	e8 7b 00 00 00       	call   800130 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000b5:	53                   	push   %ebx
  8000b6:	68 ac 10 80 00       	push   $0x8010ac
  8000bb:	6a 64                	push   $0x64
  8000bd:	53                   	push   %ebx
  8000be:	e8 ed 05 00 00       	call   8006b0 <snprintf>
  8000c3:	83 c4 10             	add    $0x10,%esp
}
  8000c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    
	...

008000cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000d7:	e8 bf 0b 00 00       	call   800c9b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e8:	c1 e0 07             	shl    $0x7,%eax
  8000eb:	29 d0                	sub    %edx,%eax
  8000ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f7:	85 f6                	test   %esi,%esi
  8000f9:	7e 07                	jle    800102 <libmain+0x36>
		binaryname = argv[0];
  8000fb:	8b 03                	mov    (%ebx),%eax
  8000fd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	53                   	push   %ebx
  800106:	56                   	push   %esi
  800107:	e8 28 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010c:	e8 0b 00 00 00       	call   80011c <exit>
  800111:	83 c4 10             	add    $0x10,%esp
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	c9                   	leave  
  80011a:	c3                   	ret    
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800122:	6a 00                	push   $0x0
  800124:	e8 91 0b 00 00       	call   800cba <sys_env_destroy>
  800129:	83 c4 10             	add    $0x10,%esp
}
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    
	...

00800130 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	53                   	push   %ebx
  800134:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800137:	8d 45 14             	lea    0x14(%ebp),%eax
  80013a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800143:	e8 53 0b 00 00       	call   800c9b <sys_getenvid>
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	ff 75 0c             	pushl  0xc(%ebp)
  80014e:	ff 75 08             	pushl  0x8(%ebp)
  800151:	53                   	push   %ebx
  800152:	50                   	push   %eax
  800153:	68 d8 10 80 00       	push   $0x8010d8
  800158:	e8 74 00 00 00       	call   8001d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015d:	83 c4 18             	add    $0x18,%esp
  800160:	ff 75 f8             	pushl  -0x8(%ebp)
  800163:	ff 75 10             	pushl  0x10(%ebp)
  800166:	e8 15 00 00 00       	call   800180 <vcprintf>
	cprintf("\n");
  80016b:	c7 04 24 62 10 80 00 	movl   $0x801062,(%esp)
  800172:	e8 5a 00 00 00       	call   8001d1 <cprintf>
  800177:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017a:	cc                   	int3   
  80017b:	eb fd                	jmp    80017a <_panic+0x4a>
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800189:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800190:	00 00 00 
	b.cnt = 0;
  800193:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80019a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019d:	ff 75 0c             	pushl  0xc(%ebp)
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a9:	50                   	push   %eax
  8001aa:	68 e8 01 80 00       	push   $0x8001e8
  8001af:	e8 70 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b4:	83 c4 08             	add    $0x8,%esp
  8001b7:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001bd:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001c3:	50                   	push   %eax
  8001c4:	e8 9e 08 00 00       	call   800a67 <sys_cputs>
  8001c9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001da:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9a ff ff ff       	call   800180 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f2:	8b 03                	mov    (%ebx),%eax
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001fb:	40                   	inc    %eax
  8001fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800203:	75 1a                	jne    80021f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 43 08             	lea    0x8(%ebx),%eax
  800210:	50                   	push   %eax
  800211:	e8 51 08 00 00       	call   800a67 <sys_cputs>
		b->idx = 0;
  800216:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80021c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80021f:	ff 43 04             	incl   0x4(%ebx)
}
  800222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800225:	c9                   	leave  
  800226:	c3                   	ret    
	...

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800234:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800240:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800243:	8b 55 10             	mov    0x10(%ebp),%edx
  800246:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800249:	89 d6                	mov    %edx,%esi
  80024b:	bf 00 00 00 00       	mov    $0x0,%edi
  800250:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800253:	72 04                	jb     800259 <printnum+0x31>
  800255:	39 c2                	cmp    %eax,%edx
  800257:	77 3f                	ja     800298 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800262:	50                   	push   %eax
  800263:	52                   	push   %edx
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026c:	ff 75 e0             	pushl  -0x20(%ebp)
  80026f:	e8 30 0b 00 00       	call   800da4 <__udivdi3>
  800274:	83 c4 18             	add    $0x18,%esp
  800277:	52                   	push   %edx
  800278:	50                   	push   %eax
  800279:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80027c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80027f:	e8 a4 ff ff ff       	call   800228 <printnum>
  800284:	83 c4 20             	add    $0x20,%esp
  800287:	eb 14                	jmp    80029d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	ff 75 e8             	pushl  -0x18(%ebp)
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	ff 55 ec             	call   *-0x14(%ebp)
  800295:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800298:	4b                   	dec    %ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f ec                	jg     800289 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	ff 75 e8             	pushl  -0x18(%ebp)
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	e8 1d 0c 00 00       	call   800ed0 <__umoddi3>
  8002b3:	83 c4 14             	add    $0x14,%esp
  8002b6:	0f be 80 fb 10 80 00 	movsbl 0x8010fb(%eax),%eax
  8002bd:	50                   	push   %eax
  8002be:	ff 55 ec             	call   *-0x14(%ebp)
  8002c1:	83 c4 10             	add    $0x10,%esp
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7e 0e                	jle    8002e4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 42 08             	lea    0x8(%edx),%eax
  8002db:	89 01                	mov    %eax,(%ecx)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	eb 22                	jmp    800306 <getuint+0x3a>
	else if (lflag)
  8002e4:	85 d2                	test   %edx,%edx
  8002e6:	74 10                	je     8002f8 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 42 04             	lea    0x4(%edx),%eax
  8002ed:	89 01                	mov    %eax,(%ecx)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	eb 0e                	jmp    800306 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 42 04             	lea    0x4(%edx),%eax
  8002fd:	89 01                	mov    %eax,(%ecx)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80030e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800311:	8b 11                	mov    (%ecx),%edx
  800313:	3b 51 04             	cmp    0x4(%ecx),%edx
  800316:	73 0a                	jae    800322 <sprintputch+0x1a>
		*b->buf++ = ch;
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	88 02                	mov    %al,(%edx)
  80031d:	8d 42 01             	lea    0x1(%edx),%eax
  800320:	89 01                	mov    %eax,(%ecx)
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 3c             	sub    $0x3c,%esp
  80032d:	8b 75 08             	mov    0x8(%ebp),%esi
  800330:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800333:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800336:	eb 1a                	jmp    800352 <vprintfmt+0x2e>
  800338:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80033b:	eb 15                	jmp    800352 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033d:	84 c0                	test   %al,%al
  80033f:	0f 84 15 03 00 00    	je     80065a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	57                   	push   %edi
  800349:	0f b6 c0             	movzbl %al,%eax
  80034c:	50                   	push   %eax
  80034d:	ff d6                	call   *%esi
  80034f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800352:	8a 03                	mov    (%ebx),%al
  800354:	43                   	inc    %ebx
  800355:	3c 25                	cmp    $0x25,%al
  800357:	75 e4                	jne    80033d <vprintfmt+0x19>
  800359:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800360:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800367:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80036e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800375:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800379:	eb 0a                	jmp    800385 <vprintfmt+0x61>
  80037b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800382:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8a 03                	mov    (%ebx),%al
  800387:	0f b6 d0             	movzbl %al,%edx
  80038a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  80038d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800390:	83 e8 23             	sub    $0x23,%eax
  800393:	3c 55                	cmp    $0x55,%al
  800395:	0f 87 9c 02 00 00    	ja     800637 <vprintfmt+0x313>
  80039b:	0f b6 c0             	movzbl %al,%eax
  80039e:	ff 24 85 40 12 80 00 	jmp    *0x801240(,%eax,4)
  8003a5:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8003a9:	eb d7                	jmp    800382 <vprintfmt+0x5e>
  8003ab:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8003af:	eb d1                	jmp    800382 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8003b1:	89 d9                	mov    %ebx,%ecx
  8003b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ba:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003bd:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003c0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003c7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003cb:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003cc:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003cf:	83 f8 09             	cmp    $0x9,%eax
  8003d2:	77 21                	ja     8003f5 <vprintfmt+0xd1>
  8003d4:	eb e4                	jmp    8003ba <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d6:	8b 55 14             	mov    0x14(%ebp),%edx
  8003d9:	8d 42 04             	lea    0x4(%edx),%eax
  8003dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8003df:	8b 12                	mov    (%edx),%edx
  8003e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003e4:	eb 12                	jmp    8003f8 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ea:	79 96                	jns    800382 <vprintfmt+0x5e>
  8003ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f3:	eb 8d                	jmp    800382 <vprintfmt+0x5e>
  8003f5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003fc:	79 84                	jns    800382 <vprintfmt+0x5e>
  8003fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80040b:	e9 72 ff ff ff       	jmp    800382 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800410:	ff 45 d4             	incl   -0x2c(%ebp)
  800413:	e9 6a ff ff ff       	jmp    800382 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 55 14             	mov    0x14(%ebp),%edx
  80041b:	8d 42 04             	lea    0x4(%edx),%eax
  80041e:	89 45 14             	mov    %eax,0x14(%ebp)
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	57                   	push   %edi
  800425:	ff 32                	pushl  (%edx)
  800427:	ff d6                	call   *%esi
			break;
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	e9 07 ff ff ff       	jmp    800338 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800431:	8b 55 14             	mov    0x14(%ebp),%edx
  800434:	8d 42 04             	lea    0x4(%edx),%eax
  800437:	89 45 14             	mov    %eax,0x14(%ebp)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	79 02                	jns    800442 <vprintfmt+0x11e>
  800440:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800442:	83 f8 0f             	cmp    $0xf,%eax
  800445:	7f 0b                	jg     800452 <vprintfmt+0x12e>
  800447:	8b 14 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%edx
  80044e:	85 d2                	test   %edx,%edx
  800450:	75 15                	jne    800467 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800452:	50                   	push   %eax
  800453:	68 0c 11 80 00       	push   $0x80110c
  800458:	57                   	push   %edi
  800459:	56                   	push   %esi
  80045a:	e8 6e 02 00 00       	call   8006cd <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	e9 d1 fe ff ff       	jmp    800338 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800467:	52                   	push   %edx
  800468:	68 15 11 80 00       	push   $0x801115
  80046d:	57                   	push   %edi
  80046e:	56                   	push   %esi
  80046f:	e8 59 02 00 00       	call   8006cd <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	e9 bc fe ff ff       	jmp    800338 <vprintfmt+0x14>
  80047c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80047f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800482:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800485:	8b 55 14             	mov    0x14(%ebp),%edx
  800488:	8d 42 04             	lea    0x4(%edx),%eax
  80048b:	89 45 14             	mov    %eax,0x14(%ebp)
  80048e:	8b 1a                	mov    (%edx),%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	75 05                	jne    800499 <vprintfmt+0x175>
  800494:	bb 18 11 80 00       	mov    $0x801118,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800499:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80049d:	7e 66                	jle    800505 <vprintfmt+0x1e1>
  80049f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8004a3:	74 60                	je     800505 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	51                   	push   %ecx
  8004a9:	53                   	push   %ebx
  8004aa:	e8 57 02 00 00       	call   800706 <strnlen>
  8004af:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8004b2:	29 c1                	sub    %eax,%ecx
  8004b4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004c1:	eb 0f                	jmp    8004d2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	57                   	push   %edi
  8004c7:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	ff 4d d8             	decl   -0x28(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d6:	7f eb                	jg     8004c3 <vprintfmt+0x19f>
  8004d8:	eb 2b                	jmp    800505 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	74 15                	je     8004f8 <vprintfmt+0x1d4>
  8004e3:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 0d                	jbe    8004f8 <vprintfmt+0x1d4>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	57                   	push   %edi
  8004ef:	6a 3f                	push   $0x3f
  8004f1:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 0a                	jmp    800502 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	57                   	push   %edi
  8004fc:	52                   	push   %edx
  8004fd:	ff d6                	call   *%esi
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	ff 4d d8             	decl   -0x28(%ebp)
  800505:	8a 03                	mov    (%ebx),%al
  800507:	43                   	inc    %ebx
  800508:	84 c0                	test   %al,%al
  80050a:	74 1b                	je     800527 <vprintfmt+0x203>
  80050c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800510:	78 c8                	js     8004da <vprintfmt+0x1b6>
  800512:	ff 4d dc             	decl   -0x24(%ebp)
  800515:	79 c3                	jns    8004da <vprintfmt+0x1b6>
  800517:	eb 0e                	jmp    800527 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	57                   	push   %edi
  80051d:	6a 20                	push   $0x20
  80051f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800521:	ff 4d d8             	decl   -0x28(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052b:	7f ec                	jg     800519 <vprintfmt+0x1f5>
  80052d:	e9 06 fe ff ff       	jmp    800338 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800532:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800536:	7e 10                	jle    800548 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800538:	8b 55 14             	mov    0x14(%ebp),%edx
  80053b:	8d 42 08             	lea    0x8(%edx),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	8b 02                	mov    (%edx),%eax
  800543:	8b 52 04             	mov    0x4(%edx),%edx
  800546:	eb 20                	jmp    800568 <vprintfmt+0x244>
	else if (lflag)
  800548:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054c:	74 0e                	je     80055c <vprintfmt+0x238>
		return va_arg(*ap, long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 50 04             	lea    0x4(%eax),%edx
  800554:	89 55 14             	mov    %edx,0x14(%ebp)
  800557:	8b 00                	mov    (%eax),%eax
  800559:	99                   	cltd   
  80055a:	eb 0c                	jmp    800568 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 50 04             	lea    0x4(%eax),%edx
  800562:	89 55 14             	mov    %edx,0x14(%ebp)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800568:	89 d1                	mov    %edx,%ecx
  80056a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  80056c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	85 c9                	test   %ecx,%ecx
  800574:	78 0a                	js     800580 <vprintfmt+0x25c>
  800576:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80057b:	e9 89 00 00 00       	jmp    800609 <vprintfmt+0x2e5>
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	57                   	push   %edi
  800584:	6a 2d                	push   $0x2d
  800586:	ff d6                	call   *%esi
				num = -(long long) num;
  800588:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80058e:	f7 da                	neg    %edx
  800590:	83 d1 00             	adc    $0x0,%ecx
  800593:	f7 d9                	neg    %ecx
  800595:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 6a                	jmp    800609 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059f:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005a5:	e8 22 fd ff ff       	call   8002cc <getuint>
  8005aa:	89 d1                	mov    %edx,%ecx
  8005ac:	89 c2                	mov    %eax,%edx
  8005ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005b3:	eb 54                	jmp    800609 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005bb:	e8 0c fd ff ff       	call   8002cc <getuint>
  8005c0:	89 d1                	mov    %edx,%ecx
  8005c2:	89 c2                	mov    %eax,%edx
  8005c4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005c9:	eb 3e                	jmp    800609 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	57                   	push   %edi
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	57                   	push   %edi
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005db:	8b 55 14             	mov    0x14(%ebp),%edx
  8005de:	8d 42 04             	lea    0x4(%edx),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e4:	8b 12                	mov    (%edx),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005eb:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb 14                	jmp    800609 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005fb:	e8 cc fc ff ff       	call   8002cc <getuint>
  800600:	89 d1                	mov    %edx,%ecx
  800602:	89 c2                	mov    %eax,%edx
  800604:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800610:	50                   	push   %eax
  800611:	ff 75 d8             	pushl  -0x28(%ebp)
  800614:	53                   	push   %ebx
  800615:	51                   	push   %ecx
  800616:	52                   	push   %edx
  800617:	89 fa                	mov    %edi,%edx
  800619:	89 f0                	mov    %esi,%eax
  80061b:	e8 08 fc ff ff       	call   800228 <printnum>
			break;
  800620:	83 c4 20             	add    $0x20,%esp
  800623:	e9 10 fd ff ff       	jmp    800338 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	57                   	push   %edi
  80062c:	52                   	push   %edx
  80062d:	ff d6                	call   *%esi
			break;
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	e9 01 fd ff ff       	jmp    800338 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 25                	push   $0x25
  80063d:	ff d6                	call   *%esi
  80063f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800642:	83 ea 02             	sub    $0x2,%edx
  800645:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800648:	8a 02                	mov    (%edx),%al
  80064a:	4a                   	dec    %edx
  80064b:	3c 25                	cmp    $0x25,%al
  80064d:	75 f9                	jne    800648 <vprintfmt+0x324>
  80064f:	83 c2 02             	add    $0x2,%edx
  800652:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800655:	e9 de fc ff ff       	jmp    800338 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80065a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	c9                   	leave  
  800661:	c3                   	ret    

00800662 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	83 ec 18             	sub    $0x18,%esp
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80066e:	85 d2                	test   %edx,%edx
  800670:	74 37                	je     8006a9 <vsnprintf+0x47>
  800672:	85 c0                	test   %eax,%eax
  800674:	7e 33                	jle    8006a9 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800676:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80067d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800681:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800684:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800687:	ff 75 14             	pushl  0x14(%ebp)
  80068a:	ff 75 10             	pushl  0x10(%ebp)
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	68 08 03 80 00       	push   $0x800308
  800696:	e8 89 fc ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	eb 05                	jmp    8006ae <vsnprintf+0x4c>
  8006a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006bc:	50                   	push   %eax
  8006bd:	ff 75 10             	pushl  0x10(%ebp)
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	ff 75 08             	pushl  0x8(%ebp)
  8006c6:	e8 97 ff ff ff       	call   800662 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	ff 75 08             	pushl  0x8(%ebp)
  8006e3:	e8 3c fc ff ff       	call   800324 <vprintfmt>
	va_end(ap);
  8006e8:	83 c4 10             	add    $0x10,%esp
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    
  8006ed:	00 00                	add    %al,(%eax)
	...

008006f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fb:	eb 01                	jmp    8006fe <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800702:	75 f9                	jne    8006fd <strlen+0xd>
		n++;
	return n;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	eb 01                	jmp    800717 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800716:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	39 d0                	cmp    %edx,%eax
  800719:	74 06                	je     800721 <strnlen+0x1b>
  80071b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80071f:	75 f5                	jne    800716 <strnlen+0x10>
		n++;
	return n;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072c:	8a 01                	mov    (%ecx),%al
  80072e:	88 02                	mov    %al,(%edx)
  800730:	42                   	inc    %edx
  800731:	41                   	inc    %ecx
  800732:	84 c0                	test   %al,%al
  800734:	75 f6                	jne    80072c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	53                   	push   %ebx
  800743:	e8 a8 ff ff ff       	call   8006f0 <strlen>
	strcpy(dst + len, src);
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80074e:	50                   	push   %eax
  80074f:	e8 cf ff ff ff       	call   800723 <strcpy>
	return dst;
}
  800754:	89 d8                	mov    %ebx,%eax
  800756:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 75 08             	mov    0x8(%ebp),%esi
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	eb 0c                	jmp    80077c <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800770:	8a 02                	mov    (%edx),%al
  800772:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 3a 01             	cmpb   $0x1,(%edx)
  800778:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	41                   	inc    %ecx
  80077c:	39 d9                	cmp    %ebx,%ecx
  80077e:	75 f0                	jne    800770 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800780:	89 f0                	mov    %esi,%eax
  800782:	5b                   	pop    %ebx
  800783:	5e                   	pop    %esi
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800791:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800794:	85 c9                	test   %ecx,%ecx
  800796:	75 04                	jne    80079c <strlcpy+0x16>
  800798:	89 f0                	mov    %esi,%eax
  80079a:	eb 14                	jmp    8007b0 <strlcpy+0x2a>
  80079c:	89 f0                	mov    %esi,%eax
  80079e:	eb 04                	jmp    8007a4 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a0:	88 10                	mov    %dl,(%eax)
  8007a2:	40                   	inc    %eax
  8007a3:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a4:	49                   	dec    %ecx
  8007a5:	74 06                	je     8007ad <strlcpy+0x27>
  8007a7:	8a 13                	mov    (%ebx),%dl
  8007a9:	84 d2                	test   %dl,%dl
  8007ab:	75 f3                	jne    8007a0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8007ad:	c6 00 00             	movb   $0x0,(%eax)
  8007b0:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	eb 02                	jmp    8007c3 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007c1:	42                   	inc    %edx
  8007c2:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	8a 02                	mov    (%edx),%al
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x17>
  8007c9:	3a 01                	cmp    (%ecx),%al
  8007cb:	74 f4                	je     8007c1 <strcmp+0xb>
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 11             	movzbl (%ecx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e4:	eb 03                	jmp    8007e9 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007e6:	4a                   	dec    %edx
  8007e7:	41                   	inc    %ecx
  8007e8:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	75 07                	jne    8007f4 <strncmp+0x1d>
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	eb 14                	jmp    800808 <strncmp+0x31>
  8007f4:	8a 01                	mov    (%ecx),%al
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strncmp+0x27>
  8007fa:	3a 03                	cmp    (%ebx),%al
  8007fc:	74 e8                	je     8007e6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 d0             	movzbl %al,%edx
  800801:	0f b6 03             	movzbl (%ebx),%eax
  800804:	29 c2                	sub    %eax,%edx
  800806:	89 d0                	mov    %edx,%eax
}
  800808:	5b                   	pop    %ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800814:	eb 05                	jmp    80081b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800816:	38 ca                	cmp    %cl,%dl
  800818:	74 0c                	je     800826 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081a:	40                   	inc    %eax
  80081b:	8a 10                	mov    (%eax),%dl
  80081d:	84 d2                	test   %dl,%dl
  80081f:	75 f5                	jne    800816 <strchr+0xb>
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800831:	eb 05                	jmp    800838 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 07                	je     80083e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800837:	40                   	inc    %eax
  800838:	8a 10                	mov    (%eax),%dl
  80083a:	84 d2                	test   %dl,%dl
  80083c:	75 f5                	jne    800833 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    

00800840 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 7d 08             	mov    0x8(%ebp),%edi
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80084f:	85 db                	test   %ebx,%ebx
  800851:	74 36                	je     800889 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800853:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800859:	75 29                	jne    800884 <memset+0x44>
  80085b:	f6 c3 03             	test   $0x3,%bl
  80085e:	75 24                	jne    800884 <memset+0x44>
		c &= 0xFF;
  800860:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 08             	shl    $0x8,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 18             	shl    $0x18,%eax
  80086d:	89 d1                	mov    %edx,%ecx
  80086f:	c1 e1 10             	shl    $0x10,%ecx
  800872:	09 c8                	or     %ecx,%eax
  800874:	09 c2                	or     %eax,%edx
  800876:	89 f0                	mov    %esi,%eax
  800878:	09 d0                	or     %edx,%eax
  80087a:	89 d9                	mov    %ebx,%ecx
  80087c:	c1 e9 02             	shr    $0x2,%ecx
  80087f:	fc                   	cld    
  800880:	f3 ab                	rep stos %eax,%es:(%edi)
  800882:	eb 05                	jmp    800889 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800884:	89 d9                	mov    %ebx,%ecx
  800886:	fc                   	cld    
  800887:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800889:	89 f8                	mov    %edi,%eax
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	57                   	push   %edi
  800894:	56                   	push   %esi
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80089b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80089e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8008a0:	39 c6                	cmp    %eax,%esi
  8008a2:	73 36                	jae    8008da <memmove+0x4a>
  8008a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	73 2f                	jae    8008da <memmove+0x4a>
		s += n;
		d += n;
  8008ab:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ae:	f6 c2 03             	test   $0x3,%dl
  8008b1:	75 1b                	jne    8008ce <memmove+0x3e>
  8008b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b9:	75 13                	jne    8008ce <memmove+0x3e>
  8008bb:	f6 c1 03             	test   $0x3,%cl
  8008be:	75 0e                	jne    8008ce <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008c0:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008c3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c6:	c1 e9 02             	shr    $0x2,%ecx
  8008c9:	fd                   	std    
  8008ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cc:	eb 09                	jmp    8008d7 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ce:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008d1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d4:	fd                   	std    
  8008d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d7:	fc                   	cld    
  8008d8:	eb 20                	jmp    8008fa <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e0:	75 15                	jne    8008f7 <memmove+0x67>
  8008e2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e8:	75 0d                	jne    8008f7 <memmove+0x67>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 08                	jne    8008f7 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
  8008f2:	fc                   	cld    
  8008f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f5:	eb 03                	jmp    8008fa <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f7:	fc                   	cld    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800901:	ff 75 10             	pushl  0x10(%ebp)
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	ff 75 08             	pushl  0x8(%ebp)
  80090a:	e8 81 ff ff ff       	call   800890 <memmove>
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	53                   	push   %ebx
  800915:	83 ec 04             	sub    $0x4,%esp
  800918:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80091e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800921:	eb 1b                	jmp    80093e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800923:	8a 1a                	mov    (%edx),%bl
  800925:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800928:	8a 19                	mov    (%ecx),%bl
  80092a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  80092d:	74 0d                	je     80093c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80092f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800933:	0f b6 c3             	movzbl %bl,%eax
  800936:	29 c2                	sub    %eax,%edx
  800938:	89 d0                	mov    %edx,%eax
  80093a:	eb 0d                	jmp    800949 <memcmp+0x38>
		s1++, s2++;
  80093c:	42                   	inc    %edx
  80093d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093e:	48                   	dec    %eax
  80093f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800942:	75 df                	jne    800923 <memcmp+0x12>
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800949:	83 c4 04             	add    $0x4,%esp
  80094c:	5b                   	pop    %ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800958:	89 c2                	mov    %eax,%edx
  80095a:	03 55 10             	add    0x10(%ebp),%edx
  80095d:	eb 05                	jmp    800964 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095f:	38 08                	cmp    %cl,(%eax)
  800961:	74 05                	je     800968 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800963:	40                   	inc    %eax
  800964:	39 d0                	cmp    %edx,%eax
  800966:	72 f7                	jb     80095f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	83 ec 04             	sub    $0x4,%esp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 75 10             	mov    0x10(%ebp),%esi
  800979:	eb 01                	jmp    80097c <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80097b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	8a 01                	mov    (%ecx),%al
  80097e:	3c 20                	cmp    $0x20,%al
  800980:	74 f9                	je     80097b <strtol+0x11>
  800982:	3c 09                	cmp    $0x9,%al
  800984:	74 f5                	je     80097b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800986:	3c 2b                	cmp    $0x2b,%al
  800988:	75 0a                	jne    800994 <strtol+0x2a>
		s++;
  80098a:	41                   	inc    %ecx
  80098b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800992:	eb 17                	jmp    8009ab <strtol+0x41>
	else if (*s == '-')
  800994:	3c 2d                	cmp    $0x2d,%al
  800996:	74 09                	je     8009a1 <strtol+0x37>
  800998:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80099f:	eb 0a                	jmp    8009ab <strtol+0x41>
		s++, neg = 1;
  8009a1:	8d 49 01             	lea    0x1(%ecx),%ecx
  8009a4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ab:	85 f6                	test   %esi,%esi
  8009ad:	74 05                	je     8009b4 <strtol+0x4a>
  8009af:	83 fe 10             	cmp    $0x10,%esi
  8009b2:	75 1a                	jne    8009ce <strtol+0x64>
  8009b4:	8a 01                	mov    (%ecx),%al
  8009b6:	3c 30                	cmp    $0x30,%al
  8009b8:	75 10                	jne    8009ca <strtol+0x60>
  8009ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009be:	75 0a                	jne    8009ca <strtol+0x60>
		s += 2, base = 16;
  8009c0:	83 c1 02             	add    $0x2,%ecx
  8009c3:	be 10 00 00 00       	mov    $0x10,%esi
  8009c8:	eb 04                	jmp    8009ce <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009ca:	85 f6                	test   %esi,%esi
  8009cc:	74 07                	je     8009d5 <strtol+0x6b>
  8009ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d3:	eb 13                	jmp    8009e8 <strtol+0x7e>
  8009d5:	3c 30                	cmp    $0x30,%al
  8009d7:	74 07                	je     8009e0 <strtol+0x76>
  8009d9:	be 0a 00 00 00       	mov    $0xa,%esi
  8009de:	eb ee                	jmp    8009ce <strtol+0x64>
		s++, base = 8;
  8009e0:	41                   	inc    %ecx
  8009e1:	be 08 00 00 00       	mov    $0x8,%esi
  8009e6:	eb e6                	jmp    8009ce <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e8:	8a 11                	mov    (%ecx),%dl
  8009ea:	88 d3                	mov    %dl,%bl
  8009ec:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009ef:	3c 09                	cmp    $0x9,%al
  8009f1:	77 08                	ja     8009fb <strtol+0x91>
			dig = *s - '0';
  8009f3:	0f be c2             	movsbl %dl,%eax
  8009f6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009f9:	eb 1c                	jmp    800a17 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fb:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009fe:	3c 19                	cmp    $0x19,%al
  800a00:	77 08                	ja     800a0a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800a02:	0f be c2             	movsbl %dl,%eax
  800a05:	8d 50 a9             	lea    -0x57(%eax),%edx
  800a08:	eb 0d                	jmp    800a17 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800a0d:	3c 19                	cmp    $0x19,%al
  800a0f:	77 15                	ja     800a26 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a11:	0f be c2             	movsbl %dl,%eax
  800a14:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a17:	39 f2                	cmp    %esi,%edx
  800a19:	7d 0b                	jge    800a26 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a1b:	41                   	inc    %ecx
  800a1c:	89 f8                	mov    %edi,%eax
  800a1e:	0f af c6             	imul   %esi,%eax
  800a21:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a24:	eb c2                	jmp    8009e8 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a26:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2c:	74 05                	je     800a33 <strtol+0xc9>
		*endptr = (char *) s;
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a33:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a37:	74 04                	je     800a3d <strtol+0xd3>
  800a39:	89 c7                	mov    %eax,%edi
  800a3b:	f7 df                	neg    %edi
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	83 c4 04             	add    $0x4,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    
	...

00800a48 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
  800a58:	89 fa                	mov    %edi,%edx
  800a5a:	89 f9                	mov    %edi,%ecx
  800a5c:	89 fb                	mov    %edi,%ebx
  800a5e:	89 fe                	mov    %edi,%esi
  800a60:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 04             	sub    $0x4,%esp
  800a70:	8b 55 08             	mov    0x8(%ebp),%edx
  800a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	89 f8                	mov    %edi,%eax
  800a7d:	89 fb                	mov    %edi,%ebx
  800a7f:	89 fe                	mov    %edi,%esi
  800a81:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a83:	83 c4 04             	add    $0x4,%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 0c             	sub    $0xc,%esp
  800a94:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a9c:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa1:	89 f9                	mov    %edi,%ecx
  800aa3:	89 fb                	mov    %edi,%ebx
  800aa5:	89 fe                	mov    %edi,%esi
  800aa7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	7e 17                	jle    800ac4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	50                   	push   %eax
  800ab1:	6a 0d                	push   $0xd
  800ab3:	68 ff 13 80 00       	push   $0x8013ff
  800ab8:	6a 23                	push   $0x23
  800aba:	68 1c 14 80 00       	push   $0x80141c
  800abf:	e8 6c f6 ff ff       	call   800130 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800adb:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ae3:	be 00 00 00 00       	mov    $0x0,%esi
  800ae8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
  800b08:	89 fb                	mov    %edi,%ebx
  800b0a:	89 fe                	mov    %edi,%esi
  800b0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	7e 17                	jle    800b29 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b12:	83 ec 0c             	sub    $0xc,%esp
  800b15:	50                   	push   %eax
  800b16:	6a 0a                	push   $0xa
  800b18:	68 ff 13 80 00       	push   $0x8013ff
  800b1d:	6a 23                	push   $0x23
  800b1f:	68 1c 14 80 00       	push   $0x80141c
  800b24:	e8 07 f6 ff ff       	call   800130 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	b8 09 00 00 00       	mov    $0x9,%eax
  800b45:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4a:	89 fb                	mov    %edi,%ebx
  800b4c:	89 fe                	mov    %edi,%esi
  800b4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7e 17                	jle    800b6b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	50                   	push   %eax
  800b58:	6a 09                	push   $0x9
  800b5a:	68 ff 13 80 00       	push   $0x8013ff
  800b5f:	6a 23                	push   $0x23
  800b61:	68 1c 14 80 00       	push   $0x80141c
  800b66:	e8 c5 f5 ff ff       	call   800130 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 08 00 00 00       	mov    $0x8,%eax
  800b87:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8c:	89 fb                	mov    %edi,%ebx
  800b8e:	89 fe                	mov    %edi,%esi
  800b90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 08                	push   $0x8
  800b9c:	68 ff 13 80 00       	push   $0x8013ff
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 1c 14 80 00       	push   $0x80141c
  800ba8:	e8 83 f5 ff ff       	call   800130 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bce:	89 fb                	mov    %edi,%ebx
  800bd0:	89 fe                	mov    %edi,%esi
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 06                	push   $0x6
  800bde:	68 ff 13 80 00       	push   $0x8013ff
  800be3:	6a 23                	push   $0x23
  800be5:	68 1c 14 80 00       	push   $0x80141c
  800bea:	e8 41 f5 ff ff       	call   800130 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 05                	push   $0x5
  800c20:	68 ff 13 80 00       	push   $0x8013ff
  800c25:	6a 23                	push   $0x23
  800c27:	68 1c 14 80 00       	push   $0x80141c
  800c2c:	e8 ff f4 ff ff       	call   800130 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c50:	bf 00 00 00 00       	mov    $0x0,%edi
  800c55:	89 fe                	mov    %edi,%esi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 04                	push   $0x4
  800c63:	68 ff 13 80 00       	push   $0x8013ff
  800c68:	6a 23                	push   $0x23
  800c6a:	68 1c 14 80 00       	push   $0x80141c
  800c6f:	e8 bc f4 ff ff       	call   800130 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c87:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8c:	89 fa                	mov    %edi,%edx
  800c8e:	89 f9                	mov    %edi,%ecx
  800c90:	89 fb                	mov    %edi,%ebx
  800c92:	89 fe                	mov    %edi,%esi
  800c94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	89 fa                	mov    %edi,%edx
  800cad:	89 f9                	mov    %edi,%ecx
  800caf:	89 fb                	mov    %edi,%ebx
  800cb1:	89 fe                	mov    %edi,%esi
  800cb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	89 fb                	mov    %edi,%ebx
  800cd4:	89 fe                	mov    %edi,%esi
  800cd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 03                	push   $0x3
  800ce2:	68 ff 13 80 00       	push   $0x8013ff
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 1c 14 80 00       	push   $0x80141c
  800cee:	e8 3d f4 ff ff       	call   800130 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    
	...

00800cfc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d02:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d09:	75 64                	jne    800d6f <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800d0b:	a1 04 20 80 00       	mov    0x802004,%eax
  800d10:	8b 40 48             	mov    0x48(%eax),%eax
  800d13:	83 ec 04             	sub    $0x4,%esp
  800d16:	6a 07                	push   $0x7
  800d18:	68 00 f0 bf ee       	push   $0xeebff000
  800d1d:	50                   	push   %eax
  800d1e:	e8 16 ff ff ff       	call   800c39 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	85 c0                	test   %eax,%eax
  800d28:	79 14                	jns    800d3e <set_pgfault_handler+0x42>
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	68 2c 14 80 00       	push   $0x80142c
  800d32:	6a 22                	push   $0x22
  800d34:	68 98 14 80 00       	push   $0x801498
  800d39:	e8 f2 f3 ff ff       	call   800130 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800d3e:	a1 04 20 80 00       	mov    0x802004,%eax
  800d43:	8b 40 48             	mov    0x48(%eax),%eax
  800d46:	83 ec 08             	sub    $0x8,%esp
  800d49:	68 7c 0d 80 00       	push   $0x800d7c
  800d4e:	50                   	push   %eax
  800d4f:	e8 9b fd ff ff       	call   800aef <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 14                	jns    800d6f <set_pgfault_handler+0x73>
  800d5b:	83 ec 04             	sub    $0x4,%esp
  800d5e:	68 5c 14 80 00       	push   $0x80145c
  800d63:	6a 25                	push   $0x25
  800d65:	68 98 14 80 00       	push   $0x801498
  800d6a:	e8 c1 f3 ff ff       	call   800130 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    
  800d79:	00 00                	add    %al,(%eax)
	...

00800d7c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d7c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d7d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d82:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d84:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  800d87:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d8b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d8e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  800d92:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  800d96:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  800d98:	83 c4 08             	add    $0x8,%esp
	popal
  800d9b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800d9c:	83 c4 04             	add    $0x4,%esp
	popfl
  800d9f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800da0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  800da1:	c3                   	ret    
	...

00800da4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	83 ec 28             	sub    $0x28,%esp
  800dac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800db3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800dba:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbd:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dc3:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dc5:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd3:	85 ff                	test   %edi,%edi
  800dd5:	75 21                	jne    800df8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800dd7:	39 d1                	cmp    %edx,%ecx
  800dd9:	76 49                	jbe    800e24 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 c1                	mov    %eax,%ecx
  800ddf:	31 c0                	xor    %eax,%eax
  800de1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800de7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ded:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800df0:	83 c4 28             	add    $0x28,%esp
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    
  800df7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800dfb:	0f 87 97 00 00 00    	ja     800e98 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e01:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e04:	83 f0 1f             	xor    $0x1f,%eax
  800e07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e0a:	75 34                	jne    800e40 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e0c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800e0f:	72 08                	jb     800e19 <__udivdi3+0x75>
  800e11:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e14:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e17:	77 7f                	ja     800e98 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e19:	b9 01 00 00 00       	mov    $0x1,%ecx
  800e1e:	31 c0                	xor    %eax,%eax
  800e20:	eb c2                	jmp    800de4 <__udivdi3+0x40>
  800e22:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e27:	85 c0                	test   %eax,%eax
  800e29:	74 79                	je     800ea4 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	f7 f1                	div    %ecx
  800e32:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e37:	f7 f1                	div    %ecx
  800e39:	89 c1                	mov    %eax,%ecx
  800e3b:	89 f0                	mov    %esi,%eax
  800e3d:	eb a5                	jmp    800de4 <__udivdi3+0x40>
  800e3f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e40:	b8 20 00 00 00       	mov    $0x20,%eax
  800e45:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e4b:	89 fa                	mov    %edi,%edx
  800e4d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e50:	d3 e2                	shl    %cl,%edx
  800e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e55:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e58:	d3 e8                	shr    %cl,%eax
  800e5a:	89 d7                	mov    %edx,%edi
  800e5c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800e5e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800e61:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e64:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e66:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e69:	d3 e0                	shl    %cl,%eax
  800e6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e6e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e71:	d3 ea                	shr    %cl,%edx
  800e73:	09 d0                	or     %edx,%eax
  800e75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e78:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e7b:	d3 ea                	shr    %cl,%edx
  800e7d:	f7 f7                	div    %edi
  800e7f:	89 d7                	mov    %edx,%edi
  800e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e84:	f7 e6                	mul    %esi
  800e86:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e88:	39 d7                	cmp    %edx,%edi
  800e8a:	72 38                	jb     800ec4 <__udivdi3+0x120>
  800e8c:	74 27                	je     800eb5 <__udivdi3+0x111>
  800e8e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e91:	31 c0                	xor    %eax,%eax
  800e93:	e9 4c ff ff ff       	jmp    800de4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e98:	31 c9                	xor    %ecx,%ecx
  800e9a:	31 c0                	xor    %eax,%eax
  800e9c:	e9 43 ff ff ff       	jmp    800de4 <__udivdi3+0x40>
  800ea1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea9:	31 d2                	xor    %edx,%edx
  800eab:	f7 75 f4             	divl   -0xc(%ebp)
  800eae:	89 c1                	mov    %eax,%ecx
  800eb0:	e9 76 ff ff ff       	jmp    800e2b <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb8:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ebb:	d3 e0                	shl    %cl,%eax
  800ebd:	39 f0                	cmp    %esi,%eax
  800ebf:	73 cd                	jae    800e8e <__udivdi3+0xea>
  800ec1:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ec4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ec7:	49                   	dec    %ecx
  800ec8:	31 c0                	xor    %eax,%eax
  800eca:	e9 15 ff ff ff       	jmp    800de4 <__udivdi3+0x40>
	...

00800ed0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	83 ec 30             	sub    $0x30,%esp
  800ed8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800edf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800ee6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ee9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800eec:	8b 45 10             	mov    0x10(%ebp),%eax
  800eef:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ef5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800ef7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800efa:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800efd:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f00:	85 d2                	test   %edx,%edx
  800f02:	75 1c                	jne    800f20 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800f04:	89 fa                	mov    %edi,%edx
  800f06:	39 f8                	cmp    %edi,%eax
  800f08:	0f 86 c2 00 00 00    	jbe    800fd0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800f12:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800f15:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f1c:	eb 12                	jmp    800f30 <__umoddi3+0x60>
  800f1e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f20:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f23:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800f26:	76 18                	jbe    800f40 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f28:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800f2b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f2e:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f30:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f36:	83 c4 30             	add    $0x30,%esp
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f40:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800f44:	83 f0 1f             	xor    $0x1f,%eax
  800f47:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f4a:	0f 84 ac 00 00 00    	je     800ffc <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f50:	b8 20 00 00 00       	mov    $0x20,%eax
  800f55:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f5b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f5e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f61:	d3 e2                	shl    %cl,%edx
  800f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f66:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f69:	d3 e8                	shr    %cl,%eax
  800f6b:	89 d6                	mov    %edx,%esi
  800f6d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f72:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f75:	d3 e0                	shl    %cl,%eax
  800f77:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f7a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800f7d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f82:	d3 e0                	shl    %cl,%eax
  800f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f87:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f8a:	d3 ea                	shr    %cl,%edx
  800f8c:	09 d0                	or     %edx,%eax
  800f8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f91:	d3 ea                	shr    %cl,%edx
  800f93:	f7 f6                	div    %esi
  800f95:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800f98:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f9b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800f9e:	0f 82 8d 00 00 00    	jb     801031 <__umoddi3+0x161>
  800fa4:	0f 84 91 00 00 00    	je     80103b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800faa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800fad:	29 c7                	sub    %eax,%edi
  800faf:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fb1:	89 f2                	mov    %esi,%edx
  800fb3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fb6:	d3 e2                	shl    %cl,%edx
  800fb8:	89 f8                	mov    %edi,%eax
  800fba:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800fbd:	d3 e8                	shr    %cl,%eax
  800fbf:	09 c2                	or     %eax,%edx
  800fc1:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800fc4:	d3 ee                	shr    %cl,%esi
  800fc6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800fc9:	e9 62 ff ff ff       	jmp    800f30 <__umoddi3+0x60>
  800fce:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	74 15                	je     800fec <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fda:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fdd:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	f7 f1                	div    %ecx
  800fe4:	e9 29 ff ff ff       	jmp    800f12 <__umoddi3+0x42>
  800fe9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	f7 75 ec             	divl   -0x14(%ebp)
  800ff6:	89 c1                	mov    %eax,%ecx
  800ff8:	eb dd                	jmp    800fd7 <__umoddi3+0x107>
  800ffa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ffc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fff:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801002:	72 19                	jb     80101d <__umoddi3+0x14d>
  801004:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801007:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80100a:	76 11                	jbe    80101d <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80100c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80100f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801012:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801015:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801018:	e9 13 ff ff ff       	jmp    800f30 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80101d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801026:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801029:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80102c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80102f:	eb db                	jmp    80100c <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801031:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801034:	19 f2                	sbb    %esi,%edx
  801036:	e9 6f ff ff ff       	jmp    800faa <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80103b:	39 c7                	cmp    %eax,%edi
  80103d:	72 f2                	jb     801031 <__umoddi3+0x161>
  80103f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801042:	e9 63 ff ff ff       	jmp    800faa <__umoddi3+0xda>
