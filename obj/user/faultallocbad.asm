
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
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
  80003a:	68 58 00 80 00       	push   $0x800058
  80003f:	e8 a4 0c 00 00       	call   800ce8 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800044:	83 c4 08             	add    $0x8,%esp
  800047:	6a 04                	push   $0x4
  800049:	68 ef be ad de       	push   $0xdeadbeef
  80004e:	e8 00 0a 00 00       	call   800a53 <sys_cputs>
  800053:	83 c4 10             	add    $0x10,%esp
}
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	53                   	push   %ebx
  80005c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80005f:	8b 45 08             	mov    0x8(%ebp),%eax
  800062:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800064:	53                   	push   %ebx
  800065:	68 40 10 80 00       	push   $0x801040
  80006a:	e8 4e 01 00 00       	call   8001bd <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	6a 07                	push   $0x7
  800074:	89 d8                	mov    %ebx,%eax
  800076:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80007b:	50                   	push   %eax
  80007c:	6a 00                	push   $0x0
  80007e:	e8 a2 0b 00 00       	call   800c25 <sys_page_alloc>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	79 16                	jns    8000a0 <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	50                   	push   %eax
  80008e:	53                   	push   %ebx
  80008f:	68 60 10 80 00       	push   $0x801060
  800094:	6a 0f                	push   $0xf
  800096:	68 4a 10 80 00       	push   $0x80104a
  80009b:	e8 7c 00 00 00       	call   80011c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000a0:	53                   	push   %ebx
  8000a1:	68 8c 10 80 00       	push   $0x80108c
  8000a6:	6a 64                	push   $0x64
  8000a8:	53                   	push   %ebx
  8000a9:	e8 ee 05 00 00       	call   80069c <snprintf>
  8000ae:	83 c4 10             	add    $0x10,%esp
}
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8000c3:	e8 bf 0b 00 00       	call   800c87 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d4:	c1 e0 07             	shl    $0x7,%eax
  8000d7:	29 d0                	sub    %edx,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	7e 07                	jle    8000ee <libmain+0x36>
		binaryname = argv[0];
  8000e7:	8b 03                	mov    (%ebx),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	53                   	push   %ebx
  8000f2:	56                   	push   %esi
  8000f3:	e8 3c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0b 00 00 00       	call   800108 <exit>
  8000fd:	83 c4 10             	add    $0x10,%esp
}
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 91 0b 00 00       	call   800ca6 <sys_env_destroy>
  800115:	83 c4 10             	add    $0x10,%esp
}
  800118:	c9                   	leave  
  800119:	c3                   	ret    
	...

0080011c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	53                   	push   %ebx
  800120:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800123:	8d 45 14             	lea    0x14(%ebp),%eax
  800126:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800129:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80012f:	e8 53 0b 00 00       	call   800c87 <sys_getenvid>
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	53                   	push   %ebx
  80013e:	50                   	push   %eax
  80013f:	68 b8 10 80 00       	push   $0x8010b8
  800144:	e8 74 00 00 00       	call   8001bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800149:	83 c4 18             	add    $0x18,%esp
  80014c:	ff 75 f8             	pushl  -0x8(%ebp)
  80014f:	ff 75 10             	pushl  0x10(%ebp)
  800152:	e8 15 00 00 00       	call   80016c <vcprintf>
	cprintf("\n");
  800157:	c7 04 24 48 10 80 00 	movl   $0x801048,(%esp)
  80015e:	e8 5a 00 00 00       	call   8001bd <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800166:	cc                   	int3   
  800167:	eb fd                	jmp    800166 <_panic+0x4a>
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800175:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80017c:	00 00 00 
	b.cnt = 0;
  80017f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800189:	ff 75 0c             	pushl  0xc(%ebp)
  80018c:	ff 75 08             	pushl  0x8(%ebp)
  80018f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800195:	50                   	push   %eax
  800196:	68 d4 01 80 00       	push   $0x8001d4
  80019b:	e8 70 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	83 c4 08             	add    $0x8,%esp
  8001a3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001a9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 9e 08 00 00       	call   800a53 <sys_cputs>
  8001b5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001c9:	50                   	push   %eax
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	e8 9a ff ff ff       	call   80016c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001de:	8b 03                	mov    (%ebx),%eax
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e7:	40                   	inc    %eax
  8001e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ef:	75 1a                	jne    80020b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 51 08 00 00       	call   800a53 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800208:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020b:	ff 43 04             	incl   0x4(%ebx)
}
  80020e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800211:	c9                   	leave  
  800212:	c3                   	ret    
	...

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800220:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	8b 55 0c             	mov    0xc(%ebp),%edx
  800229:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80022f:	8b 55 10             	mov    0x10(%ebp),%edx
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	89 d6                	mov    %edx,%esi
  800237:	bf 00 00 00 00       	mov    $0x0,%edi
  80023c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80023f:	72 04                	jb     800245 <printnum+0x31>
  800241:	39 c2                	cmp    %eax,%edx
  800243:	77 3f                	ja     800284 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 18             	pushl  0x18(%ebp)
  80024b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80024e:	50                   	push   %eax
  80024f:	52                   	push   %edx
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	ff 75 e4             	pushl  -0x1c(%ebp)
  800258:	ff 75 e0             	pushl  -0x20(%ebp)
  80025b:	e8 30 0b 00 00       	call   800d90 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800268:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80026b:	e8 a4 ff ff ff       	call   800214 <printnum>
  800270:	83 c4 20             	add    $0x20,%esp
  800273:	eb 14                	jmp    800289 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	ff 75 e8             	pushl  -0x18(%ebp)
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	ff 55 ec             	call   *-0x14(%ebp)
  800281:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	4b                   	dec    %ebx
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f ec                	jg     800275 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	ff 75 e8             	pushl  -0x18(%ebp)
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	ff 75 e4             	pushl  -0x1c(%ebp)
  800297:	ff 75 e0             	pushl  -0x20(%ebp)
  80029a:	e8 1d 0c 00 00       	call   800ebc <__umoddi3>
  80029f:	83 c4 14             	add    $0x14,%esp
  8002a2:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8002a9:	50                   	push   %eax
  8002aa:	ff 55 ec             	call   *-0x14(%ebp)
  8002ad:	83 c4 10             	add    $0x10,%esp
}
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 42 08             	lea    0x8(%edx),%eax
  8002c7:	89 01                	mov    %eax,(%ecx)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x3a>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 42 04             	lea    0x4(%edx),%eax
  8002d9:	89 01                	mov    %eax,(%ecx)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 42 04             	lea    0x4(%edx),%eax
  8002e9:	89 01                	mov    %eax,(%ecx)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002fa:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002fd:	8b 11                	mov    (%ecx),%edx
  8002ff:	3b 51 04             	cmp    0x4(%ecx),%edx
  800302:	73 0a                	jae    80030e <sprintputch+0x1a>
		*b->buf++ = ch;
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
  800309:	8d 42 01             	lea    0x1(%edx),%eax
  80030c:	89 01                	mov    %eax,(%ecx)
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 3c             	sub    $0x3c,%esp
  800319:	8b 75 08             	mov    0x8(%ebp),%esi
  80031c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80031f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800322:	eb 1a                	jmp    80033e <vprintfmt+0x2e>
  800324:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800327:	eb 15                	jmp    80033e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800329:	84 c0                	test   %al,%al
  80032b:	0f 84 15 03 00 00    	je     800646 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	57                   	push   %edi
  800335:	0f b6 c0             	movzbl %al,%eax
  800338:	50                   	push   %eax
  800339:	ff d6                	call   *%esi
  80033b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033e:	8a 03                	mov    (%ebx),%al
  800340:	43                   	inc    %ebx
  800341:	3c 25                	cmp    $0x25,%al
  800343:	75 e4                	jne    800329 <vprintfmt+0x19>
  800345:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80034c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800353:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80035a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800361:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800365:	eb 0a                	jmp    800371 <vprintfmt+0x61>
  800367:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80036e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8a 03                	mov    (%ebx),%al
  800373:	0f b6 d0             	movzbl %al,%edx
  800376:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800379:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80037c:	83 e8 23             	sub    $0x23,%eax
  80037f:	3c 55                	cmp    $0x55,%al
  800381:	0f 87 9c 02 00 00    	ja     800623 <vprintfmt+0x313>
  800387:	0f b6 c0             	movzbl %al,%eax
  80038a:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  800391:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800395:	eb d7                	jmp    80036e <vprintfmt+0x5e>
  800397:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80039b:	eb d1                	jmp    80036e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80039d:	89 d9                	mov    %ebx,%ecx
  80039f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003a9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003ac:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003b3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003b7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003b8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003bb:	83 f8 09             	cmp    $0x9,%eax
  8003be:	77 21                	ja     8003e1 <vprintfmt+0xd1>
  8003c0:	eb e4                	jmp    8003a6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c2:	8b 55 14             	mov    0x14(%ebp),%edx
  8003c5:	8d 42 04             	lea    0x4(%edx),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8003cb:	8b 12                	mov    (%edx),%edx
  8003cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d0:	eb 12                	jmp    8003e4 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003d6:	79 96                	jns    80036e <vprintfmt+0x5e>
  8003d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003df:	eb 8d                	jmp    80036e <vprintfmt+0x5e>
  8003e1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003e8:	79 84                	jns    80036e <vprintfmt+0x5e>
  8003ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003f7:	e9 72 ff ff ff       	jmp    80036e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fc:	ff 45 d4             	incl   -0x2c(%ebp)
  8003ff:	e9 6a ff ff ff       	jmp    80036e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800404:	8b 55 14             	mov    0x14(%ebp),%edx
  800407:	8d 42 04             	lea    0x4(%edx),%eax
  80040a:	89 45 14             	mov    %eax,0x14(%ebp)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	57                   	push   %edi
  800411:	ff 32                	pushl  (%edx)
  800413:	ff d6                	call   *%esi
			break;
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	e9 07 ff ff ff       	jmp    800324 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041d:	8b 55 14             	mov    0x14(%ebp),%edx
  800420:	8d 42 04             	lea    0x4(%edx),%eax
  800423:	89 45 14             	mov    %eax,0x14(%ebp)
  800426:	8b 02                	mov    (%edx),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	79 02                	jns    80042e <vprintfmt+0x11e>
  80042c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042e:	83 f8 0f             	cmp    $0xf,%eax
  800431:	7f 0b                	jg     80043e <vprintfmt+0x12e>
  800433:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  80043a:	85 d2                	test   %edx,%edx
  80043c:	75 15                	jne    800453 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80043e:	50                   	push   %eax
  80043f:	68 ec 10 80 00       	push   $0x8010ec
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	e8 6e 02 00 00       	call   8006b9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 c4 10             	add    $0x10,%esp
  80044e:	e9 d1 fe ff ff       	jmp    800324 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800453:	52                   	push   %edx
  800454:	68 f5 10 80 00       	push   $0x8010f5
  800459:	57                   	push   %edi
  80045a:	56                   	push   %esi
  80045b:	e8 59 02 00 00       	call   8006b9 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	e9 bc fe ff ff       	jmp    800324 <vprintfmt+0x14>
  800468:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80046b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80046e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 55 14             	mov    0x14(%ebp),%edx
  800474:	8d 42 04             	lea    0x4(%edx),%eax
  800477:	89 45 14             	mov    %eax,0x14(%ebp)
  80047a:	8b 1a                	mov    (%edx),%ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	75 05                	jne    800485 <vprintfmt+0x175>
  800480:	bb f8 10 80 00       	mov    $0x8010f8,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800485:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800489:	7e 66                	jle    8004f1 <vprintfmt+0x1e1>
  80048b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80048f:	74 60                	je     8004f1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	51                   	push   %ecx
  800495:	53                   	push   %ebx
  800496:	e8 57 02 00 00       	call   8006f2 <strnlen>
  80049b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80049e:	29 c1                	sub    %eax,%ecx
  8004a0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004ad:	eb 0f                	jmp    8004be <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	57                   	push   %edi
  8004b3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004b6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	ff 4d d8             	decl   -0x28(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c2:	7f eb                	jg     8004af <vprintfmt+0x19f>
  8004c4:	eb 2b                	jmp    8004f1 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c6:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cd:	74 15                	je     8004e4 <vprintfmt+0x1d4>
  8004cf:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004d2:	83 f8 5e             	cmp    $0x5e,%eax
  8004d5:	76 0d                	jbe    8004e4 <vprintfmt+0x1d4>
					putch('?', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	57                   	push   %edi
  8004db:	6a 3f                	push   $0x3f
  8004dd:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb 0a                	jmp    8004ee <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	57                   	push   %edi
  8004e8:	52                   	push   %edx
  8004e9:	ff d6                	call   *%esi
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	ff 4d d8             	decl   -0x28(%ebp)
  8004f1:	8a 03                	mov    (%ebx),%al
  8004f3:	43                   	inc    %ebx
  8004f4:	84 c0                	test   %al,%al
  8004f6:	74 1b                	je     800513 <vprintfmt+0x203>
  8004f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fc:	78 c8                	js     8004c6 <vprintfmt+0x1b6>
  8004fe:	ff 4d dc             	decl   -0x24(%ebp)
  800501:	79 c3                	jns    8004c6 <vprintfmt+0x1b6>
  800503:	eb 0e                	jmp    800513 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	57                   	push   %edi
  800509:	6a 20                	push   $0x20
  80050b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050d:	ff 4d d8             	decl   -0x28(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800517:	7f ec                	jg     800505 <vprintfmt+0x1f5>
  800519:	e9 06 fe ff ff       	jmp    800324 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800522:	7e 10                	jle    800534 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800524:	8b 55 14             	mov    0x14(%ebp),%edx
  800527:	8d 42 08             	lea    0x8(%edx),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	8b 02                	mov    (%edx),%eax
  80052f:	8b 52 04             	mov    0x4(%edx),%edx
  800532:	eb 20                	jmp    800554 <vprintfmt+0x244>
	else if (lflag)
  800534:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800538:	74 0e                	je     800548 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	99                   	cltd   
  800546:	eb 0c                	jmp    800554 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800554:	89 d1                	mov    %edx,%ecx
  800556:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800558:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	78 0a                	js     80056c <vprintfmt+0x25c>
  800562:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800567:	e9 89 00 00 00       	jmp    8005f5 <vprintfmt+0x2e5>
				putch('-', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	57                   	push   %edi
  800570:	6a 2d                	push   $0x2d
  800572:	ff d6                	call   *%esi
				num = -(long long) num;
  800574:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800577:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057a:	f7 da                	neg    %edx
  80057c:	83 d1 00             	adc    $0x0,%ecx
  80057f:	f7 d9                	neg    %ecx
  800581:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	eb 6a                	jmp    8005f5 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800591:	e8 22 fd ff ff       	call   8002b8 <getuint>
  800596:	89 d1                	mov    %edx,%ecx
  800598:	89 c2                	mov    %eax,%edx
  80059a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80059f:	eb 54                	jmp    8005f5 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005a7:	e8 0c fd ff ff       	call   8002b8 <getuint>
  8005ac:	89 d1                	mov    %edx,%ecx
  8005ae:	89 c2                	mov    %eax,%edx
  8005b0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005b5:	eb 3e                	jmp    8005f5 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 30                	push   $0x30
  8005bd:	ff d6                	call   *%esi
			putch('x', putdat);
  8005bf:	83 c4 08             	add    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 78                	push   $0x78
  8005c5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005c7:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ca:	8d 42 04             	lea    0x4(%edx),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d0:	8b 12                	mov    (%edx),%edx
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	eb 14                	jmp    8005f5 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005e7:	e8 cc fc ff ff       	call   8002b8 <getuint>
  8005ec:	89 d1                	mov    %edx,%ecx
  8005ee:	89 c2                	mov    %eax,%edx
  8005f0:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005fc:	50                   	push   %eax
  8005fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800600:	53                   	push   %ebx
  800601:	51                   	push   %ecx
  800602:	52                   	push   %edx
  800603:	89 fa                	mov    %edi,%edx
  800605:	89 f0                	mov    %esi,%eax
  800607:	e8 08 fc ff ff       	call   800214 <printnum>
			break;
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	e9 10 fd ff ff       	jmp    800324 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	57                   	push   %edi
  800618:	52                   	push   %edx
  800619:	ff d6                	call   *%esi
			break;
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	e9 01 fd ff ff       	jmp    800324 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	57                   	push   %edi
  800627:	6a 25                	push   $0x25
  800629:	ff d6                	call   *%esi
  80062b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80062e:	83 ea 02             	sub    $0x2,%edx
  800631:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800634:	8a 02                	mov    (%edx),%al
  800636:	4a                   	dec    %edx
  800637:	3c 25                	cmp    $0x25,%al
  800639:	75 f9                	jne    800634 <vprintfmt+0x324>
  80063b:	83 c2 02             	add    $0x2,%edx
  80063e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800641:	e9 de fc ff ff       	jmp    800324 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	c9                   	leave  
  80064d:	c3                   	ret    

0080064e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	83 ec 18             	sub    $0x18,%esp
  800654:	8b 55 08             	mov    0x8(%ebp),%edx
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 37                	je     800695 <vsnprintf+0x47>
  80065e:	85 c0                	test   %eax,%eax
  800660:	7e 33                	jle    800695 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800662:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800669:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80066d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800670:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800673:	ff 75 14             	pushl  0x14(%ebp)
  800676:	ff 75 10             	pushl  0x10(%ebp)
  800679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	68 f4 02 80 00       	push   $0x8002f4
  800682:	e8 89 fc ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	eb 05                	jmp    80069a <vsnprintf+0x4c>
  800695:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80069a:	c9                   	leave  
  80069b:	c3                   	ret    

0080069c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006a8:	50                   	push   %eax
  8006a9:	ff 75 10             	pushl  0x10(%ebp)
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	ff 75 08             	pushl  0x8(%ebp)
  8006b2:	e8 97 ff ff ff       	call   80064e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b7:	c9                   	leave  
  8006b8:	c3                   	ret    

008006b9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006c5:	50                   	push   %eax
  8006c6:	ff 75 10             	pushl  0x10(%ebp)
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 3c fc ff ff       	call   800310 <vprintfmt>
	va_end(ap);
  8006d4:	83 c4 10             	add    $0x10,%esp
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    
  8006d9:	00 00                	add    %al,(%eax)
	...

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	eb 01                	jmp    8006ea <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006ee:	75 f9                	jne    8006e9 <strlen+0xd>
		n++;
	return n;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 01                	jmp    800703 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800702:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 d0                	cmp    %edx,%eax
  800705:	74 06                	je     80070d <strnlen+0x1b>
  800707:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80070b:	75 f5                	jne    800702 <strnlen+0x10>
		n++;
	return n;
}
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800715:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800718:	8a 01                	mov    (%ecx),%al
  80071a:	88 02                	mov    %al,(%edx)
  80071c:	42                   	inc    %edx
  80071d:	41                   	inc    %ecx
  80071e:	84 c0                	test   %al,%al
  800720:	75 f6                	jne    800718 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	53                   	push   %ebx
  80072f:	e8 a8 ff ff ff       	call   8006dc <strlen>
	strcpy(dst + len, src);
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80073a:	50                   	push   %eax
  80073b:	e8 cf ff ff ff       	call   80070f <strcpy>
	return dst;
}
  800740:	89 d8                	mov    %ebx,%eax
  800742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800752:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	eb 0c                	jmp    800768 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80075c:	8a 02                	mov    (%edx),%al
  80075e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800761:	80 3a 01             	cmpb   $0x1,(%edx)
  800764:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	41                   	inc    %ecx
  800768:	39 d9                	cmp    %ebx,%ecx
  80076a:	75 f0                	jne    80075c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076c:	89 f0                	mov    %esi,%eax
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	56                   	push   %esi
  800776:	53                   	push   %ebx
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800780:	85 c9                	test   %ecx,%ecx
  800782:	75 04                	jne    800788 <strlcpy+0x16>
  800784:	89 f0                	mov    %esi,%eax
  800786:	eb 14                	jmp    80079c <strlcpy+0x2a>
  800788:	89 f0                	mov    %esi,%eax
  80078a:	eb 04                	jmp    800790 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078c:	88 10                	mov    %dl,(%eax)
  80078e:	40                   	inc    %eax
  80078f:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800790:	49                   	dec    %ecx
  800791:	74 06                	je     800799 <strlcpy+0x27>
  800793:	8a 13                	mov    (%ebx),%dl
  800795:	84 d2                	test   %dl,%dl
  800797:	75 f3                	jne    80078c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
  80079c:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ab:	eb 02                	jmp    8007af <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007ad:	42                   	inc    %edx
  8007ae:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007af:	8a 02                	mov    (%edx),%al
  8007b1:	84 c0                	test   %al,%al
  8007b3:	74 04                	je     8007b9 <strcmp+0x17>
  8007b5:	3a 01                	cmp    (%ecx),%al
  8007b7:	74 f4                	je     8007ad <strcmp+0xb>
  8007b9:	0f b6 c0             	movzbl %al,%eax
  8007bc:	0f b6 11             	movzbl (%ecx),%edx
  8007bf:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d0:	eb 03                	jmp    8007d5 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007d2:	4a                   	dec    %edx
  8007d3:	41                   	inc    %ecx
  8007d4:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	75 07                	jne    8007e0 <strncmp+0x1d>
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	eb 14                	jmp    8007f4 <strncmp+0x31>
  8007e0:	8a 01                	mov    (%ecx),%al
  8007e2:	84 c0                	test   %al,%al
  8007e4:	74 04                	je     8007ea <strncmp+0x27>
  8007e6:	3a 03                	cmp    (%ebx),%al
  8007e8:	74 e8                	je     8007d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	0f b6 d0             	movzbl %al,%edx
  8007ed:	0f b6 03             	movzbl (%ebx),%eax
  8007f0:	29 c2                	sub    %eax,%edx
  8007f2:	89 d0                	mov    %edx,%eax
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800800:	eb 05                	jmp    800807 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800802:	38 ca                	cmp    %cl,%dl
  800804:	74 0c                	je     800812 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800806:	40                   	inc    %eax
  800807:	8a 10                	mov    (%eax),%dl
  800809:	84 d2                	test   %dl,%dl
  80080b:	75 f5                	jne    800802 <strchr+0xb>
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80081d:	eb 05                	jmp    800824 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80081f:	38 ca                	cmp    %cl,%dl
  800821:	74 07                	je     80082a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800823:	40                   	inc    %eax
  800824:	8a 10                	mov    (%eax),%dl
  800826:	84 d2                	test   %dl,%dl
  800828:	75 f5                	jne    80081f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 7d 08             	mov    0x8(%ebp),%edi
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80083b:	85 db                	test   %ebx,%ebx
  80083d:	74 36                	je     800875 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800845:	75 29                	jne    800870 <memset+0x44>
  800847:	f6 c3 03             	test   $0x3,%bl
  80084a:	75 24                	jne    800870 <memset+0x44>
		c &= 0xFF;
  80084c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80084f:	89 d6                	mov    %edx,%esi
  800851:	c1 e6 08             	shl    $0x8,%esi
  800854:	89 d0                	mov    %edx,%eax
  800856:	c1 e0 18             	shl    $0x18,%eax
  800859:	89 d1                	mov    %edx,%ecx
  80085b:	c1 e1 10             	shl    $0x10,%ecx
  80085e:	09 c8                	or     %ecx,%eax
  800860:	09 c2                	or     %eax,%edx
  800862:	89 f0                	mov    %esi,%eax
  800864:	09 d0                	or     %edx,%eax
  800866:	89 d9                	mov    %ebx,%ecx
  800868:	c1 e9 02             	shr    $0x2,%ecx
  80086b:	fc                   	cld    
  80086c:	f3 ab                	rep stos %eax,%es:(%edi)
  80086e:	eb 05                	jmp    800875 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800870:	89 d9                	mov    %ebx,%ecx
  800872:	fc                   	cld    
  800873:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800875:	89 f8                	mov    %edi,%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800887:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80088a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80088c:	39 c6                	cmp    %eax,%esi
  80088e:	73 36                	jae    8008c6 <memmove+0x4a>
  800890:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800893:	39 d0                	cmp    %edx,%eax
  800895:	73 2f                	jae    8008c6 <memmove+0x4a>
		s += n;
		d += n;
  800897:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089a:	f6 c2 03             	test   $0x3,%dl
  80089d:	75 1b                	jne    8008ba <memmove+0x3e>
  80089f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a5:	75 13                	jne    8008ba <memmove+0x3e>
  8008a7:	f6 c1 03             	test   $0x3,%cl
  8008aa:	75 0e                	jne    8008ba <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008ac:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b2:	c1 e9 02             	shr    $0x2,%ecx
  8008b5:	fd                   	std    
  8008b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b8:	eb 09                	jmp    8008c3 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ba:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008bd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c0:	fd                   	std    
  8008c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c3:	fc                   	cld    
  8008c4:	eb 20                	jmp    8008e6 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cc:	75 15                	jne    8008e3 <memmove+0x67>
  8008ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d4:	75 0d                	jne    8008e3 <memmove+0x67>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 08                	jne    8008e3 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008db:	c1 e9 02             	shr    $0x2,%ecx
  8008de:	fc                   	cld    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 03                	jmp    8008e6 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e3:	fc                   	cld    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 81 ff ff ff       	call   80087c <memmove>
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	83 ec 04             	sub    $0x4,%esp
  800904:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800907:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	eb 1b                	jmp    80092a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80090f:	8a 1a                	mov    (%edx),%bl
  800911:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800914:	8a 19                	mov    (%ecx),%bl
  800916:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800919:	74 0d                	je     800928 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80091b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80091f:	0f b6 c3             	movzbl %bl,%eax
  800922:	29 c2                	sub    %eax,%edx
  800924:	89 d0                	mov    %edx,%eax
  800926:	eb 0d                	jmp    800935 <memcmp+0x38>
		s1++, s2++;
  800928:	42                   	inc    %edx
  800929:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092a:	48                   	dec    %eax
  80092b:	83 f8 ff             	cmp    $0xffffffff,%eax
  80092e:	75 df                	jne    80090f <memcmp+0x12>
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800935:	83 c4 04             	add    $0x4,%esp
  800938:	5b                   	pop    %ebx
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800944:	89 c2                	mov    %eax,%edx
  800946:	03 55 10             	add    0x10(%ebp),%edx
  800949:	eb 05                	jmp    800950 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094b:	38 08                	cmp    %cl,(%eax)
  80094d:	74 05                	je     800954 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094f:	40                   	inc    %eax
  800950:	39 d0                	cmp    %edx,%eax
  800952:	72 f7                	jb     80094b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	83 ec 04             	sub    $0x4,%esp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 75 10             	mov    0x10(%ebp),%esi
  800965:	eb 01                	jmp    800968 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800967:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800968:	8a 01                	mov    (%ecx),%al
  80096a:	3c 20                	cmp    $0x20,%al
  80096c:	74 f9                	je     800967 <strtol+0x11>
  80096e:	3c 09                	cmp    $0x9,%al
  800970:	74 f5                	je     800967 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800972:	3c 2b                	cmp    $0x2b,%al
  800974:	75 0a                	jne    800980 <strtol+0x2a>
		s++;
  800976:	41                   	inc    %ecx
  800977:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80097e:	eb 17                	jmp    800997 <strtol+0x41>
	else if (*s == '-')
  800980:	3c 2d                	cmp    $0x2d,%al
  800982:	74 09                	je     80098d <strtol+0x37>
  800984:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80098b:	eb 0a                	jmp    800997 <strtol+0x41>
		s++, neg = 1;
  80098d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800990:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800997:	85 f6                	test   %esi,%esi
  800999:	74 05                	je     8009a0 <strtol+0x4a>
  80099b:	83 fe 10             	cmp    $0x10,%esi
  80099e:	75 1a                	jne    8009ba <strtol+0x64>
  8009a0:	8a 01                	mov    (%ecx),%al
  8009a2:	3c 30                	cmp    $0x30,%al
  8009a4:	75 10                	jne    8009b6 <strtol+0x60>
  8009a6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009aa:	75 0a                	jne    8009b6 <strtol+0x60>
		s += 2, base = 16;
  8009ac:	83 c1 02             	add    $0x2,%ecx
  8009af:	be 10 00 00 00       	mov    $0x10,%esi
  8009b4:	eb 04                	jmp    8009ba <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009b6:	85 f6                	test   %esi,%esi
  8009b8:	74 07                	je     8009c1 <strtol+0x6b>
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	eb 13                	jmp    8009d4 <strtol+0x7e>
  8009c1:	3c 30                	cmp    $0x30,%al
  8009c3:	74 07                	je     8009cc <strtol+0x76>
  8009c5:	be 0a 00 00 00       	mov    $0xa,%esi
  8009ca:	eb ee                	jmp    8009ba <strtol+0x64>
		s++, base = 8;
  8009cc:	41                   	inc    %ecx
  8009cd:	be 08 00 00 00       	mov    $0x8,%esi
  8009d2:	eb e6                	jmp    8009ba <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d4:	8a 11                	mov    (%ecx),%dl
  8009d6:	88 d3                	mov    %dl,%bl
  8009d8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009db:	3c 09                	cmp    $0x9,%al
  8009dd:	77 08                	ja     8009e7 <strtol+0x91>
			dig = *s - '0';
  8009df:	0f be c2             	movsbl %dl,%eax
  8009e2:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009e5:	eb 1c                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e7:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009ea:	3c 19                	cmp    $0x19,%al
  8009ec:	77 08                	ja     8009f6 <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009ee:	0f be c2             	movsbl %dl,%eax
  8009f1:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009f4:	eb 0d                	jmp    800a03 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009f9:	3c 19                	cmp    $0x19,%al
  8009fb:	77 15                	ja     800a12 <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009fd:	0f be c2             	movsbl %dl,%eax
  800a00:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a03:	39 f2                	cmp    %esi,%edx
  800a05:	7d 0b                	jge    800a12 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a07:	41                   	inc    %ecx
  800a08:	89 f8                	mov    %edi,%eax
  800a0a:	0f af c6             	imul   %esi,%eax
  800a0d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a10:	eb c2                	jmp    8009d4 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a12:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a18:	74 05                	je     800a1f <strtol+0xc9>
		*endptr = (char *) s;
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a23:	74 04                	je     800a29 <strtol+0xd3>
  800a25:	89 c7                	mov    %eax,%edi
  800a27:	f7 df                	neg    %edi
}
  800a29:	89 f8                	mov    %edi,%eax
  800a2b:	83 c4 04             	add    $0x4,%esp
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    
	...

00800a34 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a44:	89 fa                	mov    %edi,%edx
  800a46:	89 f9                	mov    %edi,%ecx
  800a48:	89 fb                	mov    %edi,%ebx
  800a4a:	89 fe                	mov    %edi,%esi
  800a4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	83 ec 04             	sub    $0x4,%esp
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
  800a67:	89 f8                	mov    %edi,%eax
  800a69:	89 fb                	mov    %edi,%ebx
  800a6b:	89 fe                	mov    %edi,%esi
  800a6d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6f:	83 c4 04             	add    $0x4,%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 0c             	sub    $0xc,%esp
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8d:	89 f9                	mov    %edi,%ecx
  800a8f:	89 fb                	mov    %edi,%ebx
  800a91:	89 fe                	mov    %edi,%esi
  800a93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a95:	85 c0                	test   %eax,%eax
  800a97:	7e 17                	jle    800ab0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	50                   	push   %eax
  800a9d:	6a 0d                	push   $0xd
  800a9f:	68 df 13 80 00       	push   $0x8013df
  800aa4:	6a 23                	push   $0x23
  800aa6:	68 fc 13 80 00       	push   $0x8013fc
  800aab:	e8 6c f6 ff ff       	call   80011c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ab0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ac7:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800acf:	be 00 00 00 00       	mov    $0x0,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	89 fb                	mov    %edi,%ebx
  800af6:	89 fe                	mov    %edi,%esi
  800af8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	7e 17                	jle    800b15 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	50                   	push   %eax
  800b02:	6a 0a                	push   $0xa
  800b04:	68 df 13 80 00       	push   $0x8013df
  800b09:	6a 23                	push   $0x23
  800b0b:	68 fc 13 80 00       	push   $0x8013fc
  800b10:	e8 07 f6 ff ff       	call   80011c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800b31:	bf 00 00 00 00       	mov    $0x0,%edi
  800b36:	89 fb                	mov    %edi,%ebx
  800b38:	89 fe                	mov    %edi,%esi
  800b3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	7e 17                	jle    800b57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	50                   	push   %eax
  800b44:	6a 09                	push   $0x9
  800b46:	68 df 13 80 00       	push   $0x8013df
  800b4b:	6a 23                	push   $0x23
  800b4d:	68 fc 13 80 00       	push   $0x8013fc
  800b52:	e8 c5 f5 ff ff       	call   80011c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b73:	bf 00 00 00 00       	mov    $0x0,%edi
  800b78:	89 fb                	mov    %edi,%ebx
  800b7a:	89 fe                	mov    %edi,%esi
  800b7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7e 17                	jle    800b99 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	50                   	push   %eax
  800b86:	6a 08                	push   $0x8
  800b88:	68 df 13 80 00       	push   $0x8013df
  800b8d:	6a 23                	push   $0x23
  800b8f:	68 fc 13 80 00       	push   $0x8013fc
  800b94:	e8 83 f5 ff ff       	call   80011c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb5:	bf 00 00 00 00       	mov    $0x0,%edi
  800bba:	89 fb                	mov    %edi,%ebx
  800bbc:	89 fe                	mov    %edi,%esi
  800bbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 06                	push   $0x6
  800bca:	68 df 13 80 00       	push   $0x8013df
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 fc 13 80 00       	push   $0x8013fc
  800bd6:	e8 41 f5 ff ff       	call   80011c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf8:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800c00:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 05                	push   $0x5
  800c0c:	68 df 13 80 00       	push   $0x8013df
  800c11:	6a 23                	push   $0x23
  800c13:	68 fc 13 80 00       	push   $0x8013fc
  800c18:	e8 ff f4 ff ff       	call   80011c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	b8 04 00 00 00       	mov    $0x4,%eax
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c41:	89 fe                	mov    %edi,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 04                	push   $0x4
  800c4f:	68 df 13 80 00       	push   $0x8013df
  800c54:	6a 23                	push   $0x23
  800c56:	68 fc 13 80 00       	push   $0x8013fc
  800c5b:	e8 bc f4 ff ff       	call   80011c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	bf 00 00 00 00       	mov    $0x0,%edi
  800c78:	89 fa                	mov    %edi,%edx
  800c7a:	89 f9                	mov    %edi,%ecx
  800c7c:	89 fb                	mov    %edi,%ebx
  800c7e:	89 fe                	mov    %edi,%esi
  800c80:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c92:	bf 00 00 00 00       	mov    $0x0,%edi
  800c97:	89 fa                	mov    %edi,%edx
  800c99:	89 f9                	mov    %edi,%ecx
  800c9b:	89 fb                	mov    %edi,%ebx
  800c9d:	89 fe                	mov    %edi,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    

00800ca6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbc:	89 f9                	mov    %edi,%ecx
  800cbe:	89 fb                	mov    %edi,%ebx
  800cc0:	89 fe                	mov    %edi,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 03                	push   $0x3
  800cce:	68 df 13 80 00       	push   $0x8013df
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 fc 13 80 00       	push   $0x8013fc
  800cda:	e8 3d f4 ff ff       	call   80011c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    
	...

00800ce8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cee:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cf5:	75 64                	jne    800d5b <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800cf7:	a1 04 20 80 00       	mov    0x802004,%eax
  800cfc:	8b 40 48             	mov    0x48(%eax),%eax
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	6a 07                	push   $0x7
  800d04:	68 00 f0 bf ee       	push   $0xeebff000
  800d09:	50                   	push   %eax
  800d0a:	e8 16 ff ff ff       	call   800c25 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	85 c0                	test   %eax,%eax
  800d14:	79 14                	jns    800d2a <set_pgfault_handler+0x42>
  800d16:	83 ec 04             	sub    $0x4,%esp
  800d19:	68 0c 14 80 00       	push   $0x80140c
  800d1e:	6a 22                	push   $0x22
  800d20:	68 78 14 80 00       	push   $0x801478
  800d25:	e8 f2 f3 ff ff       	call   80011c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800d2a:	a1 04 20 80 00       	mov    0x802004,%eax
  800d2f:	8b 40 48             	mov    0x48(%eax),%eax
  800d32:	83 ec 08             	sub    $0x8,%esp
  800d35:	68 68 0d 80 00       	push   $0x800d68
  800d3a:	50                   	push   %eax
  800d3b:	e8 9b fd ff ff       	call   800adb <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	79 14                	jns    800d5b <set_pgfault_handler+0x73>
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	68 3c 14 80 00       	push   $0x80143c
  800d4f:	6a 25                	push   $0x25
  800d51:	68 78 14 80 00       	push   $0x801478
  800d56:	e8 c1 f3 ff ff       	call   80011c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    
  800d65:	00 00                	add    %al,(%eax)
	...

00800d68 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d68:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d69:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d6e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d70:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  800d73:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800d77:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800d7a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  800d7e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  800d82:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  800d84:	83 c4 08             	add    $0x8,%esp
	popal
  800d87:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800d88:	83 c4 04             	add    $0x4,%esp
	popfl
  800d8b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d8c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  800d8d:	c3                   	ret    
	...

00800d90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	83 ec 28             	sub    $0x28,%esp
  800d98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800d9f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800da6:	8b 45 10             	mov    0x10(%ebp),%eax
  800da9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800daf:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800db1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dbf:	85 ff                	test   %edi,%edi
  800dc1:	75 21                	jne    800de4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800dc3:	39 d1                	cmp    %edx,%ecx
  800dc5:	76 49                	jbe    800e10 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dc7:	f7 f1                	div    %ecx
  800dc9:	89 c1                	mov    %eax,%ecx
  800dcb:	31 c0                	xor    %eax,%eax
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800dd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800dd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ddc:	83 c4 28             	add    $0x28,%esp
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    
  800de3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800de7:	0f 87 97 00 00 00    	ja     800e84 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ded:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800df0:	83 f0 1f             	xor    $0x1f,%eax
  800df3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800df6:	75 34                	jne    800e2c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800dfb:	72 08                	jb     800e05 <__udivdi3+0x75>
  800dfd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e00:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e03:	77 7f                	ja     800e84 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e05:	b9 01 00 00 00       	mov    $0x1,%ecx
  800e0a:	31 c0                	xor    %eax,%eax
  800e0c:	eb c2                	jmp    800dd0 <__udivdi3+0x40>
  800e0e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e13:	85 c0                	test   %eax,%eax
  800e15:	74 79                	je     800e90 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e17:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e23:	f7 f1                	div    %ecx
  800e25:	89 c1                	mov    %eax,%ecx
  800e27:	89 f0                	mov    %esi,%eax
  800e29:	eb a5                	jmp    800dd0 <__udivdi3+0x40>
  800e2b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800e34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e37:	89 fa                	mov    %edi,%edx
  800e39:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e3c:	d3 e2                	shl    %cl,%edx
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e44:	d3 e8                	shr    %cl,%eax
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800e4a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800e4d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e50:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800e52:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800e55:	d3 e0                	shl    %cl,%eax
  800e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e5a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800e5d:	d3 ea                	shr    %cl,%edx
  800e5f:	09 d0                	or     %edx,%eax
  800e61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e64:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	f7 f7                	div    %edi
  800e6b:	89 d7                	mov    %edx,%edi
  800e6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e70:	f7 e6                	mul    %esi
  800e72:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e74:	39 d7                	cmp    %edx,%edi
  800e76:	72 38                	jb     800eb0 <__udivdi3+0x120>
  800e78:	74 27                	je     800ea1 <__udivdi3+0x111>
  800e7a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e7d:	31 c0                	xor    %eax,%eax
  800e7f:	e9 4c ff ff ff       	jmp    800dd0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e84:	31 c9                	xor    %ecx,%ecx
  800e86:	31 c0                	xor    %eax,%eax
  800e88:	e9 43 ff ff ff       	jmp    800dd0 <__udivdi3+0x40>
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e90:	b8 01 00 00 00       	mov    $0x1,%eax
  800e95:	31 d2                	xor    %edx,%edx
  800e97:	f7 75 f4             	divl   -0xc(%ebp)
  800e9a:	89 c1                	mov    %eax,%ecx
  800e9c:	e9 76 ff ff ff       	jmp    800e17 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ea1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ea7:	d3 e0                	shl    %cl,%eax
  800ea9:	39 f0                	cmp    %esi,%eax
  800eab:	73 cd                	jae    800e7a <__udivdi3+0xea>
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eb0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800eb3:	49                   	dec    %ecx
  800eb4:	31 c0                	xor    %eax,%eax
  800eb6:	e9 15 ff ff ff       	jmp    800dd0 <__udivdi3+0x40>
	...

00800ebc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	83 ec 30             	sub    $0x30,%esp
  800ec4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800ecb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800ed2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  800edb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800ede:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ee1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800ee3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800ee6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800ee9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eec:	85 d2                	test   %edx,%edx
  800eee:	75 1c                	jne    800f0c <__umoddi3+0x50>
    {
      if (d0 > n1)
  800ef0:	89 fa                	mov    %edi,%edx
  800ef2:	39 f8                	cmp    %edi,%eax
  800ef4:	0f 86 c2 00 00 00    	jbe    800fbc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800efa:	89 f0                	mov    %esi,%eax
  800efc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800efe:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800f01:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800f08:	eb 12                	jmp    800f1c <__umoddi3+0x60>
  800f0a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f0c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f0f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800f12:	76 18                	jbe    800f2c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800f14:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800f17:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800f1a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f1c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f22:	83 c4 30             	add    $0x30,%esp
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    
  800f29:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f2c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800f30:	83 f0 1f             	xor    $0x1f,%eax
  800f33:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f36:	0f 84 ac 00 00 00    	je     800fe8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f41:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800f44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f47:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f4a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f4d:	d3 e2                	shl    %cl,%edx
  800f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f52:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f55:	d3 e8                	shr    %cl,%eax
  800f57:	89 d6                	mov    %edx,%esi
  800f59:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f61:	d3 e0                	shl    %cl,%eax
  800f63:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f66:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800f69:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6e:	d3 e0                	shl    %cl,%eax
  800f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f73:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f76:	d3 ea                	shr    %cl,%edx
  800f78:	09 d0                	or     %edx,%eax
  800f7a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f7d:	d3 ea                	shr    %cl,%edx
  800f7f:	f7 f6                	div    %esi
  800f81:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800f84:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f87:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800f8a:	0f 82 8d 00 00 00    	jb     80101d <__umoddi3+0x161>
  800f90:	0f 84 91 00 00 00    	je     801027 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f96:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f99:	29 c7                	sub    %eax,%edi
  800f9b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800fa2:	d3 e2                	shl    %cl,%edx
  800fa4:	89 f8                	mov    %edi,%eax
  800fa6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800fa9:	d3 e8                	shr    %cl,%eax
  800fab:	09 c2                	or     %eax,%edx
  800fad:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800fb0:	d3 ee                	shr    %cl,%esi
  800fb2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800fb5:	e9 62 ff ff ff       	jmp    800f1c <__umoddi3+0x60>
  800fba:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	74 15                	je     800fd8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fc9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fce:	f7 f1                	div    %ecx
  800fd0:	e9 29 ff ff ff       	jmp    800efe <__umoddi3+0x42>
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	f7 75 ec             	divl   -0x14(%ebp)
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	eb dd                	jmp    800fc3 <__umoddi3+0x107>
  800fe6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fe8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800feb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800fee:	72 19                	jb     801009 <__umoddi3+0x14d>
  800ff0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ff3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ff6:	76 11                	jbe    801009 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ff8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ffb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800ffe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801001:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801004:	e9 13 ff ff ff       	jmp    800f1c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801009:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801012:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801015:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801018:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80101b:	eb db                	jmp    800ff8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80101d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801020:	19 f2                	sbb    %esi,%edx
  801022:	e9 6f ff ff ff       	jmp    800f96 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801027:	39 c7                	cmp    %eax,%edi
  801029:	72 f2                	jb     80101d <__umoddi3+0x161>
  80102b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80102e:	e9 63 ff ff ff       	jmp    800f96 <__umoddi3+0xda>
