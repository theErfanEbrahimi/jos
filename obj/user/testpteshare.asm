
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 53 01 00 00       	call   800184 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003a:	ff 35 04 30 80 00    	pushl  0x803004
  800040:	68 00 00 00 a0       	push   $0xa0000000
  800045:	e8 91 07 00 00       	call   8007db <strcpy>
	exit();
  80004a:	e8 85 01 00 00       	call   8001d4 <exit>
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	53                   	push   %ebx
  800058:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005f:	74 05                	je     800066 <umain+0x12>
		childofspawn();
  800061:	e8 ce ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	68 07 04 00 00       	push   $0x407
  80006e:	68 00 00 00 a0       	push   $0xa0000000
  800073:	6a 00                	push   $0x0
  800075:	e8 77 0c 00 00       	call   800cf1 <sys_page_alloc>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 12                	jns    800093 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800081:	50                   	push   %eax
  800082:	68 00 28 80 00       	push   $0x802800
  800087:	6a 13                	push   $0x13
  800089:	68 13 28 80 00       	push   $0x802813
  80008e:	e8 55 01 00 00       	call   8001e8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800093:	e8 36 0d 00 00       	call   800dce <fork>
  800098:	89 c3                	mov    %eax,%ebx
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <umain+0x5c>
		panic("fork: %e", r);
  80009e:	50                   	push   %eax
  80009f:	68 27 28 80 00       	push   $0x802827
  8000a4:	6a 17                	push   $0x17
  8000a6:	68 13 28 80 00       	push   $0x802813
  8000ab:	e8 38 01 00 00       	call   8001e8 <_panic>
	if (r == 0) {
  8000b0:	85 c0                	test   %eax,%eax
  8000b2:	75 1b                	jne    8000cf <umain+0x7b>
		strcpy(VA, msg);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	ff 35 00 30 80 00    	pushl  0x803000
  8000bd:	68 00 00 00 a0       	push   $0xa0000000
  8000c2:	e8 14 07 00 00       	call   8007db <strcpy>
		exit();
  8000c7:	e8 08 01 00 00       	call   8001d4 <exit>
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	53                   	push   %ebx
  8000d3:	e8 44 15 00 00       	call   80161c <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 00 30 80 00    	pushl  0x803000
  8000e1:	68 00 00 00 a0       	push   $0xa0000000
  8000e6:	e8 83 07 00 00       	call   80086e <strcmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	75 07                	jne    8000f9 <umain+0xa5>
  8000f2:	b8 30 28 80 00       	mov    $0x802830,%eax
  8000f7:	eb 05                	jmp    8000fe <umain+0xaa>
  8000f9:	b8 36 28 80 00       	mov    $0x802836,%eax
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	50                   	push   %eax
  800102:	68 3c 28 80 00       	push   $0x80283c
  800107:	e8 7d 01 00 00       	call   800289 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010c:	6a 00                	push   $0x0
  80010e:	68 57 28 80 00       	push   $0x802857
  800113:	68 5c 28 80 00       	push   $0x80285c
  800118:	68 5b 28 80 00       	push   $0x80285b
  80011d:	e8 79 14 00 00       	call   80159b <spawnl>
  800122:	83 c4 20             	add    $0x20,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0xe7>
		panic("spawn: %e", r);
  800129:	50                   	push   %eax
  80012a:	68 69 28 80 00       	push   $0x802869
  80012f:	6a 21                	push   $0x21
  800131:	68 13 28 80 00       	push   $0x802813
  800136:	e8 ad 00 00 00       	call   8001e8 <_panic>
	wait(r);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 d8 14 00 00       	call   80161c <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff 35 04 30 80 00    	pushl  0x803004
  80014d:	68 00 00 00 a0       	push   $0xa0000000
  800152:	e8 17 07 00 00       	call   80086e <strcmp>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	85 c0                	test   %eax,%eax
  80015c:	75 07                	jne    800165 <umain+0x111>
  80015e:	b8 30 28 80 00       	mov    $0x802830,%eax
  800163:	eb 05                	jmp    80016a <umain+0x116>
  800165:	b8 36 28 80 00       	mov    $0x802836,%eax
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	50                   	push   %eax
  80016e:	68 73 28 80 00       	push   $0x802873
  800173:	e8 11 01 00 00       	call   800289 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800178:	cc                   	int3   
  800179:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  80017c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	8b 75 08             	mov    0x8(%ebp),%esi
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80018f:	e8 bf 0b 00 00       	call   800d53 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800194:	25 ff 03 00 00       	and    $0x3ff,%eax
  800199:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001a0:	c1 e0 07             	shl    $0x7,%eax
  8001a3:	29 d0                	sub    %edx,%eax
  8001a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001aa:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001af:	85 f6                	test   %esi,%esi
  8001b1:	7e 07                	jle    8001ba <libmain+0x36>
		binaryname = argv[0];
  8001b3:	8b 03                	mov    (%ebx),%eax
  8001b5:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	53                   	push   %ebx
  8001be:	56                   	push   %esi
  8001bf:	e8 90 fe ff ff       	call   800054 <umain>

	// exit gracefully
	exit();
  8001c4:	e8 0b 00 00 00       	call   8001d4 <exit>
  8001c9:	83 c4 10             	add    $0x10,%esp
}
  8001cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    
	...

008001d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8001da:	6a 00                	push   $0x0
  8001dc:	e8 91 0b 00 00       	call   800d72 <sys_env_destroy>
  8001e1:	83 c4 10             	add    $0x10,%esp
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    
	...

008001e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8001f2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f5:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8001fb:	e8 53 0b 00 00       	call   800d53 <sys_getenvid>
  800200:	83 ec 0c             	sub    $0xc,%esp
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	53                   	push   %ebx
  80020a:	50                   	push   %eax
  80020b:	68 b8 28 80 00       	push   $0x8028b8
  800210:	e8 74 00 00 00       	call   800289 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800215:	83 c4 18             	add    $0x18,%esp
  800218:	ff 75 f8             	pushl  -0x8(%ebp)
  80021b:	ff 75 10             	pushl  0x10(%ebp)
  80021e:	e8 15 00 00 00       	call   800238 <vcprintf>
	cprintf("\n");
  800223:	c7 04 24 22 2f 80 00 	movl   $0x802f22,(%esp)
  80022a:	e8 5a 00 00 00       	call   800289 <cprintf>
  80022f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800232:	cc                   	int3   
  800233:	eb fd                	jmp    800232 <_panic+0x4a>
  800235:	00 00                	add    %al,(%eax)
	...

00800238 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800241:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800248:	00 00 00 
	b.cnt = 0;
  80024b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800252:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800255:	ff 75 0c             	pushl  0xc(%ebp)
  800258:	ff 75 08             	pushl  0x8(%ebp)
  80025b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800261:	50                   	push   %eax
  800262:	68 a0 02 80 00       	push   $0x8002a0
  800267:	e8 70 01 00 00       	call   8003dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026c:	83 c4 08             	add    $0x8,%esp
  80026f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800275:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80027b:	50                   	push   %eax
  80027c:	e8 9e 08 00 00       	call   800b1f <sys_cputs>
  800281:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800292:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9a ff ff ff       	call   800238 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002aa:	8b 03                	mov    (%ebx),%eax
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002b3:	40                   	inc    %eax
  8002b4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002bb:	75 1a                	jne    8002d7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	68 ff 00 00 00       	push   $0xff
  8002c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c8:	50                   	push   %eax
  8002c9:	e8 51 08 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  8002ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002d7:	ff 43 04             	incl   0x4(%ebx)
}
  8002da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 1c             	sub    $0x1c,%esp
  8002e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8002ec:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8002fe:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800301:	89 d6                	mov    %edx,%esi
  800303:	bf 00 00 00 00       	mov    $0x0,%edi
  800308:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80030b:	72 04                	jb     800311 <printnum+0x31>
  80030d:	39 c2                	cmp    %eax,%edx
  80030f:	77 3f                	ja     800350 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800311:	83 ec 0c             	sub    $0xc,%esp
  800314:	ff 75 18             	pushl  0x18(%ebp)
  800317:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80031a:	50                   	push   %eax
  80031b:	52                   	push   %edx
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	ff 75 e4             	pushl  -0x1c(%ebp)
  800324:	ff 75 e0             	pushl  -0x20(%ebp)
  800327:	e8 24 22 00 00       	call   802550 <__udivdi3>
  80032c:	83 c4 18             	add    $0x18,%esp
  80032f:	52                   	push   %edx
  800330:	50                   	push   %eax
  800331:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800334:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800337:	e8 a4 ff ff ff       	call   8002e0 <printnum>
  80033c:	83 c4 20             	add    $0x20,%esp
  80033f:	eb 14                	jmp    800355 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	ff 75 e8             	pushl  -0x18(%ebp)
  800347:	ff 75 18             	pushl  0x18(%ebp)
  80034a:	ff 55 ec             	call   *-0x14(%ebp)
  80034d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800350:	4b                   	dec    %ebx
  800351:	85 db                	test   %ebx,%ebx
  800353:	7f ec                	jg     800341 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	ff 75 e8             	pushl  -0x18(%ebp)
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	ff 75 e4             	pushl  -0x1c(%ebp)
  800363:	ff 75 e0             	pushl  -0x20(%ebp)
  800366:	e8 11 23 00 00       	call   80267c <__umoddi3>
  80036b:	83 c4 14             	add    $0x14,%esp
  80036e:	0f be 80 db 28 80 00 	movsbl 0x8028db(%eax),%eax
  800375:	50                   	push   %eax
  800376:	ff 55 ec             	call   *-0x14(%ebp)
  800379:	83 c4 10             	add    $0x10,%esp
}
  80037c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800389:	83 fa 01             	cmp    $0x1,%edx
  80038c:	7e 0e                	jle    80039c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 42 08             	lea    0x8(%edx),%eax
  800393:	89 01                	mov    %eax,(%ecx)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	8b 52 04             	mov    0x4(%edx),%edx
  80039a:	eb 22                	jmp    8003be <getuint+0x3a>
	else if (lflag)
  80039c:	85 d2                	test   %edx,%edx
  80039e:	74 10                	je     8003b0 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 42 04             	lea    0x4(%edx),%eax
  8003a5:	89 01                	mov    %eax,(%ecx)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	eb 0e                	jmp    8003be <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 42 04             	lea    0x4(%edx),%eax
  8003b5:	89 01                	mov    %eax,(%ecx)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8003c6:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8003c9:	8b 11                	mov    (%ecx),%edx
  8003cb:	3b 51 04             	cmp    0x4(%ecx),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1a>
		*b->buf++ = ch;
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	88 02                	mov    %al,(%edx)
  8003d5:	8d 42 01             	lea    0x1(%edx),%eax
  8003d8:	89 01                	mov    %eax,(%ecx)
}
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	57                   	push   %edi
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 3c             	sub    $0x3c,%esp
  8003e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003ee:	eb 1a                	jmp    80040a <vprintfmt+0x2e>
  8003f0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8003f3:	eb 15                	jmp    80040a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f5:	84 c0                	test   %al,%al
  8003f7:	0f 84 15 03 00 00    	je     800712 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	57                   	push   %edi
  800401:	0f b6 c0             	movzbl %al,%eax
  800404:	50                   	push   %eax
  800405:	ff d6                	call   *%esi
  800407:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040a:	8a 03                	mov    (%ebx),%al
  80040c:	43                   	inc    %ebx
  80040d:	3c 25                	cmp    $0x25,%al
  80040f:	75 e4                	jne    8003f5 <vprintfmt+0x19>
  800411:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800418:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80041f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800426:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80042d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800431:	eb 0a                	jmp    80043d <vprintfmt+0x61>
  800433:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80043a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8a 03                	mov    (%ebx),%al
  80043f:	0f b6 d0             	movzbl %al,%edx
  800442:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800445:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800448:	83 e8 23             	sub    $0x23,%eax
  80044b:	3c 55                	cmp    $0x55,%al
  80044d:	0f 87 9c 02 00 00    	ja     8006ef <vprintfmt+0x313>
  800453:	0f b6 c0             	movzbl %al,%eax
  800456:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
  80045d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800461:	eb d7                	jmp    80043a <vprintfmt+0x5e>
  800463:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800467:	eb d1                	jmp    80043a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800469:	89 d9                	mov    %ebx,%ecx
  80046b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800472:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800475:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800478:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80047c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80047f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800483:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800484:	8d 42 d0             	lea    -0x30(%edx),%eax
  800487:	83 f8 09             	cmp    $0x9,%eax
  80048a:	77 21                	ja     8004ad <vprintfmt+0xd1>
  80048c:	eb e4                	jmp    800472 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048e:	8b 55 14             	mov    0x14(%ebp),%edx
  800491:	8d 42 04             	lea    0x4(%edx),%eax
  800494:	89 45 14             	mov    %eax,0x14(%ebp)
  800497:	8b 12                	mov    (%edx),%edx
  800499:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80049c:	eb 12                	jmp    8004b0 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80049e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a2:	79 96                	jns    80043a <vprintfmt+0x5e>
  8004a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x5e>
  8004ad:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b4:	79 84                	jns    80043a <vprintfmt+0x5e>
  8004b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bc:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004c3:	e9 72 ff ff ff       	jmp    80043a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c8:	ff 45 d4             	incl   -0x2c(%ebp)
  8004cb:	e9 6a ff ff ff       	jmp    80043a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d0:	8b 55 14             	mov    0x14(%ebp),%edx
  8004d3:	8d 42 04             	lea    0x4(%edx),%eax
  8004d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	57                   	push   %edi
  8004dd:	ff 32                	pushl  (%edx)
  8004df:	ff d6                	call   *%esi
			break;
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	e9 07 ff ff ff       	jmp    8003f0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ec:	8d 42 04             	lea    0x4(%edx),%eax
  8004ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f2:	8b 02                	mov    (%edx),%eax
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	79 02                	jns    8004fa <vprintfmt+0x11e>
  8004f8:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004fa:	83 f8 0f             	cmp    $0xf,%eax
  8004fd:	7f 0b                	jg     80050a <vprintfmt+0x12e>
  8004ff:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	75 15                	jne    80051f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80050a:	50                   	push   %eax
  80050b:	68 ec 28 80 00       	push   $0x8028ec
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 6e 02 00 00       	call   800785 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	e9 d1 fe ff ff       	jmp    8003f0 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80051f:	52                   	push   %edx
  800520:	68 65 2d 80 00       	push   $0x802d65
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	e8 59 02 00 00       	call   800785 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	e9 bc fe ff ff       	jmp    8003f0 <vprintfmt+0x14>
  800534:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800537:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80053a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053d:	8b 55 14             	mov    0x14(%ebp),%edx
  800540:	8d 42 04             	lea    0x4(%edx),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	8b 1a                	mov    (%edx),%ebx
  800548:	85 db                	test   %ebx,%ebx
  80054a:	75 05                	jne    800551 <vprintfmt+0x175>
  80054c:	bb f5 28 80 00       	mov    $0x8028f5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800551:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800555:	7e 66                	jle    8005bd <vprintfmt+0x1e1>
  800557:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80055b:	74 60                	je     8005bd <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	51                   	push   %ecx
  800561:	53                   	push   %ebx
  800562:	e8 57 02 00 00       	call   8007be <strnlen>
  800567:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80056a:	29 c1                	sub    %eax,%ecx
  80056c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800576:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800579:	eb 0f                	jmp    80058a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800582:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	ff 4d d8             	decl   -0x28(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058e:	7f eb                	jg     80057b <vprintfmt+0x19f>
  800590:	eb 2b                	jmp    8005bd <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800599:	74 15                	je     8005b0 <vprintfmt+0x1d4>
  80059b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80059e:	83 f8 5e             	cmp    $0x5e,%eax
  8005a1:	76 0d                	jbe    8005b0 <vprintfmt+0x1d4>
					putch('?', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	57                   	push   %edi
  8005a7:	6a 3f                	push   $0x3f
  8005a9:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	eb 0a                	jmp    8005ba <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	57                   	push   %edi
  8005b4:	52                   	push   %edx
  8005b5:	ff d6                	call   *%esi
  8005b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	ff 4d d8             	decl   -0x28(%ebp)
  8005bd:	8a 03                	mov    (%ebx),%al
  8005bf:	43                   	inc    %ebx
  8005c0:	84 c0                	test   %al,%al
  8005c2:	74 1b                	je     8005df <vprintfmt+0x203>
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	78 c8                	js     800592 <vprintfmt+0x1b6>
  8005ca:	ff 4d dc             	decl   -0x24(%ebp)
  8005cd:	79 c3                	jns    800592 <vprintfmt+0x1b6>
  8005cf:	eb 0e                	jmp    8005df <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	57                   	push   %edi
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d9:	ff 4d d8             	decl   -0x28(%ebp)
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e3:	7f ec                	jg     8005d1 <vprintfmt+0x1f5>
  8005e5:	e9 06 fe ff ff       	jmp    8003f0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ea:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8005ee:	7e 10                	jle    800600 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8005f0:	8b 55 14             	mov    0x14(%ebp),%edx
  8005f3:	8d 42 08             	lea    0x8(%edx),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f9:	8b 02                	mov    (%edx),%eax
  8005fb:	8b 52 04             	mov    0x4(%edx),%edx
  8005fe:	eb 20                	jmp    800620 <vprintfmt+0x244>
	else if (lflag)
  800600:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800604:	74 0e                	je     800614 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	99                   	cltd   
  800612:	eb 0c                	jmp    800620 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800620:	89 d1                	mov    %edx,%ecx
  800622:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800624:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800627:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80062a:	85 c9                	test   %ecx,%ecx
  80062c:	78 0a                	js     800638 <vprintfmt+0x25c>
  80062e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800633:	e9 89 00 00 00       	jmp    8006c1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	57                   	push   %edi
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800643:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800646:	f7 da                	neg    %edx
  800648:	83 d1 00             	adc    $0x0,%ecx
  80064b:	f7 d9                	neg    %ecx
  80064d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	eb 6a                	jmp    8006c1 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80065d:	e8 22 fd ff ff       	call   800384 <getuint>
  800662:	89 d1                	mov    %edx,%ecx
  800664:	89 c2                	mov    %eax,%edx
  800666:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80066b:	eb 54                	jmp    8006c1 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800673:	e8 0c fd ff ff       	call   800384 <getuint>
  800678:	89 d1                	mov    %edx,%ecx
  80067a:	89 c2                	mov    %eax,%edx
  80067c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800681:	eb 3e                	jmp    8006c1 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	57                   	push   %edi
  800687:	6a 30                	push   $0x30
  800689:	ff d6                	call   *%esi
			putch('x', putdat);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	57                   	push   %edi
  80068f:	6a 78                	push   $0x78
  800691:	ff d6                	call   *%esi
			num = (unsigned long long)
  800693:	8b 55 14             	mov    0x14(%ebp),%edx
  800696:	8d 42 04             	lea    0x4(%edx),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
  80069c:	8b 12                	mov    (%edx),%edx
  80069e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a3:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 14                	jmp    8006c1 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b3:	e8 cc fc ff ff       	call   800384 <getuint>
  8006b8:	89 d1                	mov    %edx,%ecx
  8006ba:	89 c2                	mov    %eax,%edx
  8006bc:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cc:	53                   	push   %ebx
  8006cd:	51                   	push   %ecx
  8006ce:	52                   	push   %edx
  8006cf:	89 fa                	mov    %edi,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 08 fc ff ff       	call   8002e0 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	e9 10 fd ff ff       	jmp    8003f0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	57                   	push   %edi
  8006e4:	52                   	push   %edx
  8006e5:	ff d6                	call   *%esi
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	e9 01 fd ff ff       	jmp    8003f0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	57                   	push   %edi
  8006f3:	6a 25                	push   $0x25
  8006f5:	ff d6                	call   *%esi
  8006f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8006fa:	83 ea 02             	sub    $0x2,%edx
  8006fd:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800700:	8a 02                	mov    (%edx),%al
  800702:	4a                   	dec    %edx
  800703:	3c 25                	cmp    $0x25,%al
  800705:	75 f9                	jne    800700 <vprintfmt+0x324>
  800707:	83 c2 02             	add    $0x2,%edx
  80070a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80070d:	e9 de fc ff ff       	jmp    8003f0 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800726:	85 d2                	test   %edx,%edx
  800728:	74 37                	je     800761 <vsnprintf+0x47>
  80072a:	85 c0                	test   %eax,%eax
  80072c:	7e 33                	jle    800761 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800735:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800739:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80073c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073f:	ff 75 14             	pushl  0x14(%ebp)
  800742:	ff 75 10             	pushl  0x10(%ebp)
  800745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	68 c0 03 80 00       	push   $0x8003c0
  80074e:	e8 89 fc ff ff       	call   8003dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb 05                	jmp    800766 <vsnprintf+0x4c>
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076e:	8d 45 14             	lea    0x14(%ebp),%eax
  800771:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 97 ff ff ff       	call   80071a <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800791:	50                   	push   %eax
  800792:	ff 75 10             	pushl  0x10(%ebp)
  800795:	ff 75 0c             	pushl  0xc(%ebp)
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 3c fc ff ff       	call   8003dc <vprintfmt>
	va_end(ap);
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
  8007a5:	00 00                	add    %al,(%eax)
	...

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 01                	jmp    8007b6 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8007b5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8007ba:	75 f9                	jne    8007b5 <strlen+0xd>
		n++;
	return n;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 01                	jmp    8007cf <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8007ce:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 06                	je     8007d9 <strnlen+0x1b>
  8007d3:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8007d7:	75 f5                	jne    8007ce <strnlen+0x10>
		n++;
	return n;
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e1:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e4:	8a 01                	mov    (%ecx),%al
  8007e6:	88 02                	mov    %al,(%edx)
  8007e8:	42                   	inc    %edx
  8007e9:	41                   	inc    %ecx
  8007ea:	84 c0                	test   %al,%al
  8007ec:	75 f6                	jne    8007e4 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	53                   	push   %ebx
  8007fb:	e8 a8 ff ff ff       	call   8007a8 <strlen>
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800806:	50                   	push   %eax
  800807:	e8 cf ff ff ff       	call   8007db <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	eb 0c                	jmp    800834 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800828:	8a 02                	mov    (%edx),%al
  80082a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082d:	80 3a 01             	cmpb   $0x1,(%edx)
  800830:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800833:	41                   	inc    %ecx
  800834:	39 d9                	cmp    %ebx,%ecx
  800836:	75 f0                	jne    800828 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800838:	89 f0                	mov    %esi,%eax
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	75 04                	jne    800854 <strlcpy+0x16>
  800850:	89 f0                	mov    %esi,%eax
  800852:	eb 14                	jmp    800868 <strlcpy+0x2a>
  800854:	89 f0                	mov    %esi,%eax
  800856:	eb 04                	jmp    80085c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800858:	88 10                	mov    %dl,(%eax)
  80085a:	40                   	inc    %eax
  80085b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085c:	49                   	dec    %ecx
  80085d:	74 06                	je     800865 <strlcpy+0x27>
  80085f:	8a 13                	mov    (%ebx),%dl
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f3                	jne    800858 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
  800868:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 55 08             	mov    0x8(%ebp),%edx
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	eb 02                	jmp    80087b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800879:	42                   	inc    %edx
  80087a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	8a 02                	mov    (%edx),%al
  80087d:	84 c0                	test   %al,%al
  80087f:	74 04                	je     800885 <strcmp+0x17>
  800881:	3a 01                	cmp    (%ecx),%al
  800883:	74 f4                	je     800879 <strcmp+0xb>
  800885:	0f b6 c0             	movzbl %al,%eax
  800888:	0f b6 11             	movzbl (%ecx),%edx
  80088b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800896:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800899:	8b 55 10             	mov    0x10(%ebp),%edx
  80089c:	eb 03                	jmp    8008a1 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80089e:	4a                   	dec    %edx
  80089f:	41                   	inc    %ecx
  8008a0:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	85 d2                	test   %edx,%edx
  8008a3:	75 07                	jne    8008ac <strncmp+0x1d>
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	eb 14                	jmp    8008c0 <strncmp+0x31>
  8008ac:	8a 01                	mov    (%ecx),%al
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 04                	je     8008b6 <strncmp+0x27>
  8008b2:	3a 03                	cmp    (%ebx),%al
  8008b4:	74 e8                	je     80089e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 d0             	movzbl %al,%edx
  8008b9:	0f b6 03             	movzbl (%ebx),%eax
  8008bc:	29 c2                	sub    %eax,%edx
  8008be:	89 d0                	mov    %edx,%eax
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008cc:	eb 05                	jmp    8008d3 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 0c                	je     8008de <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	40                   	inc    %eax
  8008d3:	8a 10                	mov    (%eax),%dl
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f5                	jne    8008ce <strchr+0xb>
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8008e9:	eb 05                	jmp    8008f0 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	74 07                	je     8008f6 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ef:	40                   	inc    %eax
  8008f0:	8a 10                	mov    (%eax),%dl
  8008f2:	84 d2                	test   %dl,%dl
  8008f4:	75 f5                	jne    8008eb <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800901:	8b 45 0c             	mov    0xc(%ebp),%eax
  800904:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800907:	85 db                	test   %ebx,%ebx
  800909:	74 36                	je     800941 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800911:	75 29                	jne    80093c <memset+0x44>
  800913:	f6 c3 03             	test   $0x3,%bl
  800916:	75 24                	jne    80093c <memset+0x44>
		c &= 0xFF;
  800918:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091b:	89 d6                	mov    %edx,%esi
  80091d:	c1 e6 08             	shl    $0x8,%esi
  800920:	89 d0                	mov    %edx,%eax
  800922:	c1 e0 18             	shl    $0x18,%eax
  800925:	89 d1                	mov    %edx,%ecx
  800927:	c1 e1 10             	shl    $0x10,%ecx
  80092a:	09 c8                	or     %ecx,%eax
  80092c:	09 c2                	or     %eax,%edx
  80092e:	89 f0                	mov    %esi,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	89 d9                	mov    %ebx,%ecx
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 05                	jmp    800941 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	89 d9                	mov    %ebx,%ecx
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800956:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 36                	jae    800992 <memmove+0x4a>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2f                	jae    800992 <memmove+0x4a>
		s += n;
		d += n;
  800963:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	f6 c2 03             	test   $0x3,%dl
  800969:	75 1b                	jne    800986 <memmove+0x3e>
  80096b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800971:	75 13                	jne    800986 <memmove+0x3e>
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 0e                	jne    800986 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800978:	8d 7e fc             	lea    -0x4(%esi),%edi
  80097b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	fd                   	std    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 09                	jmp    80098f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800986:	8d 7e ff             	lea    -0x1(%esi),%edi
  800989:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098c:	fd                   	std    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098f:	fc                   	cld    
  800990:	eb 20                	jmp    8009b2 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 15                	jne    8009af <memmove+0x67>
  80099a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a0:	75 0d                	jne    8009af <memmove+0x67>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 08                	jne    8009af <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 03                	jmp    8009b2 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009af:	fc                   	cld    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b2:	5e                   	pop    %esi
  8009b3:	5f                   	pop    %edi
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	ff 75 0c             	pushl  0xc(%ebp)
  8009bf:	ff 75 08             	pushl  0x8(%ebp)
  8009c2:	e8 81 ff ff ff       	call   800948 <memmove>
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d9:	eb 1b                	jmp    8009f6 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8009db:	8a 1a                	mov    (%edx),%bl
  8009dd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8009e0:	8a 19                	mov    (%ecx),%bl
  8009e2:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8009e5:	74 0d                	je     8009f4 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8009e7:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8009eb:	0f b6 c3             	movzbl %bl,%eax
  8009ee:	29 c2                	sub    %eax,%edx
  8009f0:	89 d0                	mov    %edx,%eax
  8009f2:	eb 0d                	jmp    800a01 <memcmp+0x38>
		s1++, s2++;
  8009f4:	42                   	inc    %edx
  8009f5:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	48                   	dec    %eax
  8009f7:	83 f8 ff             	cmp    $0xffffffff,%eax
  8009fa:	75 df                	jne    8009db <memcmp+0x12>
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a01:	83 c4 04             	add    $0x4,%esp
  800a04:	5b                   	pop    %ebx
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a10:	89 c2                	mov    %eax,%edx
  800a12:	03 55 10             	add    0x10(%ebp),%edx
  800a15:	eb 05                	jmp    800a1c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a17:	38 08                	cmp    %cl,(%eax)
  800a19:	74 05                	je     800a20 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1b:	40                   	inc    %eax
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	72 f7                	jb     800a17 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	83 ec 04             	sub    $0x4,%esp
  800a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800a31:	eb 01                	jmp    800a34 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800a33:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	8a 01                	mov    (%ecx),%al
  800a36:	3c 20                	cmp    $0x20,%al
  800a38:	74 f9                	je     800a33 <strtol+0x11>
  800a3a:	3c 09                	cmp    $0x9,%al
  800a3c:	74 f5                	je     800a33 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3e:	3c 2b                	cmp    $0x2b,%al
  800a40:	75 0a                	jne    800a4c <strtol+0x2a>
		s++;
  800a42:	41                   	inc    %ecx
  800a43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a4a:	eb 17                	jmp    800a63 <strtol+0x41>
	else if (*s == '-')
  800a4c:	3c 2d                	cmp    $0x2d,%al
  800a4e:	74 09                	je     800a59 <strtol+0x37>
  800a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a57:	eb 0a                	jmp    800a63 <strtol+0x41>
		s++, neg = 1;
  800a59:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a5c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a63:	85 f6                	test   %esi,%esi
  800a65:	74 05                	je     800a6c <strtol+0x4a>
  800a67:	83 fe 10             	cmp    $0x10,%esi
  800a6a:	75 1a                	jne    800a86 <strtol+0x64>
  800a6c:	8a 01                	mov    (%ecx),%al
  800a6e:	3c 30                	cmp    $0x30,%al
  800a70:	75 10                	jne    800a82 <strtol+0x60>
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	75 0a                	jne    800a82 <strtol+0x60>
		s += 2, base = 16;
  800a78:	83 c1 02             	add    $0x2,%ecx
  800a7b:	be 10 00 00 00       	mov    $0x10,%esi
  800a80:	eb 04                	jmp    800a86 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800a82:	85 f6                	test   %esi,%esi
  800a84:	74 07                	je     800a8d <strtol+0x6b>
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 13                	jmp    800aa0 <strtol+0x7e>
  800a8d:	3c 30                	cmp    $0x30,%al
  800a8f:	74 07                	je     800a98 <strtol+0x76>
  800a91:	be 0a 00 00 00       	mov    $0xa,%esi
  800a96:	eb ee                	jmp    800a86 <strtol+0x64>
		s++, base = 8;
  800a98:	41                   	inc    %ecx
  800a99:	be 08 00 00 00       	mov    $0x8,%esi
  800a9e:	eb e6                	jmp    800a86 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa0:	8a 11                	mov    (%ecx),%dl
  800aa2:	88 d3                	mov    %dl,%bl
  800aa4:	8d 42 d0             	lea    -0x30(%edx),%eax
  800aa7:	3c 09                	cmp    $0x9,%al
  800aa9:	77 08                	ja     800ab3 <strtol+0x91>
			dig = *s - '0';
  800aab:	0f be c2             	movsbl %dl,%eax
  800aae:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ab1:	eb 1c                	jmp    800acf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab3:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800ab6:	3c 19                	cmp    $0x19,%al
  800ab8:	77 08                	ja     800ac2 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800aba:	0f be c2             	movsbl %dl,%eax
  800abd:	8d 50 a9             	lea    -0x57(%eax),%edx
  800ac0:	eb 0d                	jmp    800acf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac2:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800ac5:	3c 19                	cmp    $0x19,%al
  800ac7:	77 15                	ja     800ade <strtol+0xbc>
			dig = *s - 'A' + 10;
  800ac9:	0f be c2             	movsbl %dl,%eax
  800acc:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800acf:	39 f2                	cmp    %esi,%edx
  800ad1:	7d 0b                	jge    800ade <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800ad3:	41                   	inc    %ecx
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	0f af c6             	imul   %esi,%eax
  800ad9:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800adc:	eb c2                	jmp    800aa0 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800ade:	89 f8                	mov    %edi,%eax

	if (endptr)
  800ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae4:	74 05                	je     800aeb <strtol+0xc9>
		*endptr = (char *) s;
  800ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae9:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800aeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800aef:	74 04                	je     800af5 <strtol+0xd3>
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	f7 df                	neg    %edi
}
  800af5:	89 f8                	mov    %edi,%eax
  800af7:	83 c4 04             	add    $0x4,%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    
	...

00800b00 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b10:	89 fa                	mov    %edi,%edx
  800b12:	89 f9                	mov    %edi,%ecx
  800b14:	89 fb                	mov    %edi,%ebx
  800b16:	89 fe                	mov    %edi,%esi
  800b18:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 04             	sub    $0x4,%esp
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	89 f8                	mov    %edi,%eax
  800b35:	89 fb                	mov    %edi,%ebx
  800b37:	89 fe                	mov    %edi,%esi
  800b39:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3b:	83 c4 04             	add    $0x4,%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800b54:	bf 00 00 00 00       	mov    $0x0,%edi
  800b59:	89 f9                	mov    %edi,%ecx
  800b5b:	89 fb                	mov    %edi,%ebx
  800b5d:	89 fe                	mov    %edi,%esi
  800b5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7e 17                	jle    800b7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	50                   	push   %eax
  800b69:	6a 0d                	push   $0xd
  800b6b:	68 df 2b 80 00       	push   $0x802bdf
  800b70:	6a 23                	push   $0x23
  800b72:	68 fc 2b 80 00       	push   $0x802bfc
  800b77:	e8 6c f6 ff ff       	call   8001e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7f:	5b                   	pop    %ebx
  800b80:	5e                   	pop    %esi
  800b81:	5f                   	pop    %edi
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b8 0c 00 00 00       	mov    $0xc,%eax
  800b9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ba0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc0:	89 fb                	mov    %edi,%ebx
  800bc2:	89 fe                	mov    %edi,%esi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 0a                	push   $0xa
  800bd0:	68 df 2b 80 00       	push   $0x802bdf
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 fc 2b 80 00       	push   $0x802bfc
  800bdc:	e8 07 f6 ff ff       	call   8001e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  800c02:	89 fb                	mov    %edi,%ebx
  800c04:	89 fe                	mov    %edi,%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 09                	push   $0x9
  800c12:	68 df 2b 80 00       	push   $0x802bdf
  800c17:	6a 23                	push   $0x23
  800c19:	68 fc 2b 80 00       	push   $0x802bfc
  800c1e:	e8 c5 f5 ff ff       	call   8001e8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c3a:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c4c:	7e 17                	jle    800c65 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 08                	push   $0x8
  800c54:	68 df 2b 80 00       	push   $0x802bdf
  800c59:	6a 23                	push   $0x23
  800c5b:	68 fc 2b 80 00       	push   $0x802bfc
  800c60:	e8 83 f5 ff ff       	call   8001e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
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
  800c7c:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c8e:	7e 17                	jle    800ca7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 06                	push   $0x6
  800c96:	68 df 2b 80 00       	push   $0x802bdf
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 fc 2b 80 00       	push   $0x802bfc
  800ca2:	e8 41 f5 ff ff       	call   8001e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc4:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 05                	push   $0x5
  800cd8:	68 df 2b 80 00       	push   $0x802bdf
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 fc 2b 80 00       	push   $0x802bfc
  800ce4:	e8 ff f4 ff ff       	call   8001e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	b8 04 00 00 00       	mov    $0x4,%eax
  800d08:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0d:	89 fe                	mov    %edi,%esi
  800d0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7e 17                	jle    800d2c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 04                	push   $0x4
  800d1b:	68 df 2b 80 00       	push   $0x802bdf
  800d20:	6a 23                	push   $0x23
  800d22:	68 fc 2b 80 00       	push   $0x802bfc
  800d27:	e8 bc f4 ff ff       	call   8001e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d44:	89 fa                	mov    %edi,%edx
  800d46:	89 f9                	mov    %edi,%ecx
  800d48:	89 fb                	mov    %edi,%ebx
  800d4a:	89 fe                	mov    %edi,%esi
  800d4c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d59:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d63:	89 fa                	mov    %edi,%edx
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 fb                	mov    %edi,%ebx
  800d69:	89 fe                	mov    %edi,%esi
  800d6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    

00800d72 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d83:	bf 00 00 00 00       	mov    $0x0,%edi
  800d88:	89 f9                	mov    %edi,%ecx
  800d8a:	89 fb                	mov    %edi,%ebx
  800d8c:	89 fe                	mov    %edi,%esi
  800d8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7e 17                	jle    800dab <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 03                	push   $0x3
  800d9a:	68 df 2b 80 00       	push   $0x802bdf
  800d9f:	6a 23                	push   $0x23
  800da1:	68 fc 2b 80 00       	push   $0x802bfc
  800da6:	e8 3d f4 ff ff       	call   8001e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    
	...

00800db4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dba:	68 0a 2c 80 00       	push   $0x802c0a
  800dbf:	68 92 00 00 00       	push   $0x92
  800dc4:	68 20 2c 80 00       	push   $0x802c20
  800dc9:	e8 1a f4 ff ff       	call   8001e8 <_panic>

00800dce <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800dd7:	68 6f 0f 80 00       	push   $0x800f6f
  800ddc:	e8 93 08 00 00       	call   801674 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800de1:	ba 07 00 00 00       	mov    $0x7,%edx
  800de6:	89 d0                	mov    %edx,%eax
  800de8:	cd 30                	int    $0x30
  800dea:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	75 25                	jne    800e18 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800df3:	e8 5b ff ff ff       	call   800d53 <sys_getenvid>
  800df8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800dfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e04:	c1 e0 07             	shl    $0x7,%eax
  800e07:	29 d0                	sub    %edx,%eax
  800e09:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e0e:	a3 04 40 80 00       	mov    %eax,0x804004
  800e13:	e9 4d 01 00 00       	jmp    800f65 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800e1c:	50                   	push   %eax
  800e1d:	68 2b 2c 80 00       	push   $0x802c2b
  800e22:	6a 77                	push   $0x77
  800e24:	68 20 2c 80 00       	push   $0x802c20
  800e29:	e8 ba f3 ff ff       	call   8001e8 <_panic>
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800e33:	89 d8                	mov    %ebx,%eax
  800e35:	c1 e8 16             	shr    $0x16,%eax
  800e38:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e3f:	a8 01                	test   $0x1,%al
  800e41:	0f 84 ab 00 00 00    	je     800ef2 <fork+0x124>
  800e47:	89 da                	mov    %ebx,%edx
  800e49:	c1 ea 0c             	shr    $0xc,%edx
  800e4c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e53:	a8 01                	test   $0x1,%al
  800e55:	0f 84 97 00 00 00    	je     800ef2 <fork+0x124>
  800e5b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800e62:	a8 04                	test   $0x4,%al
  800e64:	0f 84 88 00 00 00    	je     800ef2 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800e6a:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800e71:	89 d6                	mov    %edx,%esi
  800e73:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800e7e:	a9 02 08 00 00       	test   $0x802,%eax
  800e83:	74 0f                	je     800e94 <fork+0xc6>
  800e85:	f6 c4 04             	test   $0x4,%ah
  800e88:	75 0a                	jne    800e94 <fork+0xc6>
		perm &= ~PTE_W;
  800e8a:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800e8f:	89 c2                	mov    %eax,%edx
  800e91:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800e94:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e9a:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	52                   	push   %edx
  800ea1:	56                   	push   %esi
  800ea2:	57                   	push   %edi
  800ea3:	56                   	push   %esi
  800ea4:	6a 00                	push   $0x0
  800ea6:	e8 04 fe ff ff       	call   800caf <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800eab:	83 c4 20             	add    $0x20,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	79 14                	jns    800ec6 <fork+0xf8>
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	68 60 2c 80 00       	push   $0x802c60
  800eba:	6a 52                	push   $0x52
  800ebc:	68 20 2c 80 00       	push   $0x802c20
  800ec1:	e8 22 f3 ff ff       	call   8001e8 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	ff 75 f0             	pushl  -0x10(%ebp)
  800ecc:	56                   	push   %esi
  800ecd:	6a 00                	push   $0x0
  800ecf:	56                   	push   %esi
  800ed0:	6a 00                	push   $0x0
  800ed2:	e8 d8 fd ff ff       	call   800caf <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800ed7:	83 c4 20             	add    $0x20,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	79 14                	jns    800ef2 <fork+0x124>
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	68 84 2c 80 00       	push   $0x802c84
  800ee6:	6a 55                	push   $0x55
  800ee8:	68 20 2c 80 00       	push   $0x802c20
  800eed:	e8 f6 f2 ff ff       	call   8001e8 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800ef2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ef8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800efe:	0f 85 2f ff ff ff    	jne    800e33 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	6a 07                	push   $0x7
  800f09:	68 00 f0 bf ee       	push   $0xeebff000
  800f0e:	57                   	push   %edi
  800f0f:	e8 dd fd ff ff       	call   800cf1 <sys_page_alloc>
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	79 15                	jns    800f30 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800f1b:	50                   	push   %eax
  800f1c:	68 00 28 80 00       	push   $0x802800
  800f21:	68 83 00 00 00       	push   $0x83
  800f26:	68 20 2c 80 00       	push   $0x802c20
  800f2b:	e8 b8 f2 ff ff       	call   8001e8 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	68 f4 16 80 00       	push   $0x8016f4
  800f38:	57                   	push   %edi
  800f39:	e8 69 fc ff ff       	call   800ba7 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800f3e:	83 c4 08             	add    $0x8,%esp
  800f41:	6a 02                	push   $0x2
  800f43:	57                   	push   %edi
  800f44:	e8 e2 fc ff ff       	call   800c2b <sys_env_set_status>
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	79 15                	jns    800f65 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800f50:	50                   	push   %eax
  800f51:	68 49 2c 80 00       	push   $0x802c49
  800f56:	68 89 00 00 00       	push   $0x89
  800f5b:	68 20 2c 80 00       	push   $0x802c20
  800f60:	e8 83 f2 ff ff       	call   8001e8 <_panic>
	return envid;
	//panic("fork not implemented");
}
  800f65:	89 f8                	mov    %edi,%eax
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800f79:	8b 1a                	mov    (%edx),%ebx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	c1 e8 0c             	shr    $0xc,%eax
  800f80:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800f87:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f8b:	74 05                	je     800f92 <pgfault+0x23>
  800f8d:	f6 c4 08             	test   $0x8,%ah
  800f90:	75 14                	jne    800fa6 <pgfault+0x37>
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 a8 2c 80 00       	push   $0x802ca8
  800f9a:	6a 1e                	push   $0x1e
  800f9c:	68 20 2c 80 00       	push   $0x802c20
  800fa1:	e8 42 f2 ff ff       	call   8001e8 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	68 00 f0 7f 00       	push   $0x7ff000
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 3a fd ff ff       	call   800cf1 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 14                	jns    800fd2 <pgfault+0x63>
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	68 d4 2c 80 00       	push   $0x802cd4
  800fc6:	6a 2a                	push   $0x2a
  800fc8:	68 20 2c 80 00       	push   $0x802c20
  800fcd:	e8 16 f2 ff ff       	call   8001e8 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800fd2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 00 10 00 00       	push   $0x1000
  800fe0:	53                   	push   %ebx
  800fe1:	68 00 f0 7f 00       	push   $0x7ff000
  800fe6:	e8 5d f9 ff ff       	call   800948 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800feb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ff2:	53                   	push   %ebx
  800ff3:	6a 00                	push   $0x0
  800ff5:	68 00 f0 7f 00       	push   $0x7ff000
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 ae fc ff ff       	call   800caf <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  801001:	83 c4 20             	add    $0x20,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	79 14                	jns    80101c <pgfault+0xad>
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	68 f8 2c 80 00       	push   $0x802cf8
  801010:	6a 2e                	push   $0x2e
  801012:	68 20 2c 80 00       	push   $0x802c20
  801017:	e8 cc f1 ff ff       	call   8001e8 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	68 00 f0 7f 00       	push   $0x7ff000
  801024:	6a 00                	push   $0x0
  801026:	e8 42 fc ff ff       	call   800c6d <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	79 14                	jns    801046 <pgfault+0xd7>
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	68 18 2d 80 00       	push   $0x802d18
  80103a:	6a 32                	push   $0x32
  80103c:	68 20 2c 80 00       	push   $0x802c20
  801041:	e8 a2 f1 ff ff       	call   8001e8 <_panic>
	//panic("pgfault not implemented");
}
  801046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801049:	c9                   	leave  
  80104a:	c3                   	ret    
	...

0080104c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801058:	6a 00                	push   $0x0
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	e8 51 0e 00 00       	call   801eb3 <open>
  801062:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 0b                	jns    80107a <spawn+0x2e>
  80106f:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801075:	e9 13 05 00 00       	jmp    80158d <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	68 00 02 00 00       	push   $0x200
  801082:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  80108f:	e8 c9 09 00 00       	call   801a5d <readn>
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	3d 00 02 00 00       	cmp    $0x200,%eax
  80109c:	75 0c                	jne    8010aa <spawn+0x5e>
  80109e:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  8010a5:	45 4c 46 
  8010a8:	74 38                	je     8010e2 <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8010b3:	e8 74 0a 00 00       	call   801b2c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8010b8:	83 c4 0c             	add    $0xc,%esp
  8010bb:	68 7f 45 4c 46       	push   $0x464c457f
  8010c0:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  8010c6:	68 39 2d 80 00       	push   $0x802d39
  8010cb:	e8 b9 f1 ff ff       	call   800289 <cprintf>
  8010d0:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  8010d7:	ff ff ff 
		return -E_NOT_EXEC;
  8010da:	83 c4 10             	add    $0x10,%esp
  8010dd:	e9 ab 04 00 00       	jmp    80158d <spawn+0x541>
  8010e2:	ba 07 00 00 00       	mov    $0x7,%edx
  8010e7:	89 d0                	mov    %edx,%eax
  8010e9:	cd 30                	int    $0x30
  8010eb:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	0f 88 94 04 00 00    	js     80158d <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8010f9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801105:	c1 e0 07             	shl    $0x7,%eax
  801108:	29 d0                	sub    %edx,%eax
  80110a:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  801110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	6a 44                	push   $0x44
  80111a:	50                   	push   %eax
  80111b:	52                   	push   %edx
  80111c:	e8 95 f8 ff ff       	call   8009b6 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801121:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  801127:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	be 00 00 00 00       	mov    $0x0,%esi
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	eb 11                	jmp    80114d <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	50                   	push   %eax
  801140:	e8 63 f6 ff ff       	call   8007a8 <strlen>
  801145:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801149:	46                   	inc    %esi
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801150:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  801153:	85 c0                	test   %eax,%eax
  801155:	75 e5                	jne    80113c <spawn+0xf0>
  801157:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  80115d:	89 f1                	mov    %esi,%ecx
  80115f:	c1 e1 02             	shl    $0x2,%ecx
  801162:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801168:	b8 00 10 40 00       	mov    $0x401000,%eax
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801171:	89 f8                	mov    %edi,%eax
  801173:	83 e0 fc             	and    $0xfffffffc,%eax
  801176:	29 c8                	sub    %ecx,%eax
  801178:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  80117e:	83 e8 04             	sub    $0x4,%eax
  801181:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801187:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80118d:	83 e8 0c             	sub    $0xc,%eax
  801190:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801195:	0f 86 c1 03 00 00    	jbe    80155c <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	6a 07                	push   $0x7
  8011a0:	68 00 00 40 00       	push   $0x400000
  8011a5:	6a 00                	push   $0x0
  8011a7:	e8 45 fb ff ff       	call   800cf1 <sys_page_alloc>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 88 aa 03 00 00    	js     801561 <spawn+0x515>
  8011b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bc:	eb 35                	jmp    8011f3 <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8011be:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8011c4:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  8011ca:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d4:	ff 34 99             	pushl  (%ecx,%ebx,4)
  8011d7:	57                   	push   %edi
  8011d8:	e8 fe f5 ff ff       	call   8007db <strcpy>
		string_store += strlen(argv[i]) + 1;
  8011dd:	83 c4 04             	add    $0x4,%esp
  8011e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e3:	ff 34 98             	pushl  (%eax,%ebx,4)
  8011e6:	e8 bd f5 ff ff       	call   8007a8 <strlen>
  8011eb:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8011ef:	43                   	inc    %ebx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	39 f3                	cmp    %esi,%ebx
  8011f5:	7c c7                	jl     8011be <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8011f7:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  8011fd:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801203:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80120a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801210:	74 19                	je     80122b <spawn+0x1df>
  801212:	68 ac 2d 80 00       	push   $0x802dac
  801217:	68 53 2d 80 00       	push   $0x802d53
  80121c:	68 f2 00 00 00       	push   $0xf2
  801221:	68 68 2d 80 00       	push   $0x802d68
  801226:	e8 bd ef ff ff       	call   8001e8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80122b:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801231:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801236:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80123c:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80123f:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  801245:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  801248:	89 d0                	mov    %edx,%eax
  80124a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80124f:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801255:	83 ec 0c             	sub    $0xc,%esp
  801258:	6a 07                	push   $0x7
  80125a:	68 00 d0 bf ee       	push   $0xeebfd000
  80125f:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801265:	68 00 00 40 00       	push   $0x400000
  80126a:	6a 00                	push   $0x0
  80126c:	e8 3e fa ff ff       	call   800caf <sys_page_map>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 20             	add    $0x20,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	78 1c                	js     801296 <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	68 00 00 40 00       	push   $0x400000
  801282:	6a 00                	push   $0x0
  801284:	e8 e4 f9 ff ff       	call   800c6d <sys_page_unmap>
  801289:	89 c3                	mov    %eax,%ebx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	0f 89 d3 02 00 00    	jns    801569 <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	68 00 00 40 00       	push   $0x400000
  80129e:	6a 00                	push   $0x0
  8012a0:	e8 c8 f9 ff ff       	call   800c6d <sys_page_unmap>
  8012a5:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	e9 da 02 00 00       	jmp    80158d <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8012b3:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  8012b9:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  8012bd:	0f 85 79 01 00 00    	jne    80143c <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8012c3:	8b 42 f8             	mov    -0x8(%edx),%eax
  8012c6:	83 e0 02             	and    $0x2,%eax
  8012c9:	83 f8 01             	cmp    $0x1,%eax
  8012cc:	19 c0                	sbb    %eax,%eax
  8012ce:	83 e0 fe             	and    $0xfffffffe,%eax
  8012d1:	83 c0 07             	add    $0x7,%eax
  8012d4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8012da:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  8012dd:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  8012e3:	8b 42 f0             	mov    -0x10(%edx),%eax
  8012e6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8012ec:	8b 4a f4             	mov    -0xc(%edx),%ecx
  8012ef:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  8012f5:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801300:	74 16                	je     801318 <spawn+0x2cc>
		va -= i;
  801302:	29 d0                	sub    %edx,%eax
		memsz += i;
  801304:	01 d1                	add    %edx,%ecx
  801306:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  80130c:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  801312:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  801318:	89 c7                	mov    %eax,%edi
  80131a:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801321:	00 00 00 
  801324:	e9 01 01 00 00       	jmp    80142a <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  801329:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80132f:	77 27                	ja     801358 <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801331:	83 ec 04             	sub    $0x4,%esp
  801334:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80133a:	57                   	push   %edi
  80133b:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801341:	e8 ab f9 ff ff       	call   800cf1 <sys_page_alloc>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	0f 89 c7 00 00 00    	jns    80141a <spawn+0x3ce>
  801353:	e9 dd 01 00 00       	jmp    801535 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	6a 07                	push   $0x7
  80135d:	68 00 00 40 00       	push   $0x400000
  801362:	6a 00                	push   $0x0
  801364:	e8 88 f9 ff ff       	call   800cf1 <sys_page_alloc>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	0f 88 bf 01 00 00    	js     801535 <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  80137f:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801382:	50                   	push   %eax
  801383:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801389:	e8 50 04 00 00       	call   8017de <seek>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	0f 88 9a 01 00 00    	js     801535 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8013a4:	29 f0                	sub    %esi,%eax
  8013a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013ab:	76 05                	jbe    8013b2 <spawn+0x366>
  8013ad:	b8 00 10 00 00       	mov    $0x1000,%eax
  8013b2:	50                   	push   %eax
  8013b3:	68 00 00 40 00       	push   $0x400000
  8013b8:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8013be:	e8 9a 06 00 00       	call   801a5d <readn>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	0f 88 65 01 00 00    	js     801535 <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8013d9:	57                   	push   %edi
  8013da:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8013e0:	68 00 00 40 00       	push   $0x400000
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 c3 f8 ff ff       	call   800caf <sys_page_map>
  8013ec:	83 c4 20             	add    $0x20,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	79 15                	jns    801408 <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  8013f3:	50                   	push   %eax
  8013f4:	68 74 2d 80 00       	push   $0x802d74
  8013f9:	68 25 01 00 00       	push   $0x125
  8013fe:	68 68 2d 80 00       	push   $0x802d68
  801403:	e8 e0 ed ff ff       	call   8001e8 <_panic>
			sys_page_unmap(0, UTEMP);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	68 00 00 40 00       	push   $0x400000
  801410:	6a 00                	push   $0x0
  801412:	e8 56 f8 ff ff       	call   800c6d <sys_page_unmap>
  801417:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80141a:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  801421:	10 00 00 
  801424:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80142a:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801430:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  801436:	0f 87 ed fe ff ff    	ja     801329 <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80143c:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  801442:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  801449:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801450:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  801456:	0f 8c 57 fe ff ff    	jl     8012b3 <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801465:	e8 c2 06 00 00       	call   801b2c <close>
  80146a:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80146f:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  801472:	89 d8                	mov    %ebx,%eax
  801474:	c1 e8 16             	shr    $0x16,%eax
  801477:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147e:	a8 01                	test   $0x1,%al
  801480:	74 3e                	je     8014c0 <spawn+0x474>
  801482:	89 da                	mov    %ebx,%edx
  801484:	c1 ea 0c             	shr    $0xc,%edx
  801487:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80148e:	a8 01                	test   $0x1,%al
  801490:	74 2e                	je     8014c0 <spawn+0x474>
  801492:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801499:	f6 c4 04             	test   $0x4,%ah
  80149c:	74 22                	je     8014c0 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80149e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014a5:	83 ec 0c             	sub    $0xc,%esp
  8014a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ad:	50                   	push   %eax
  8014ae:	53                   	push   %ebx
  8014af:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8014b5:	53                   	push   %ebx
  8014b6:	6a 00                	push   $0x0
  8014b8:	e8 f2 f7 ff ff       	call   800caf <sys_page_map>
  8014bd:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  8014c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014c6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8014cc:	75 a4                	jne    801472 <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8014ce:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  8014d5:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  8014e1:	50                   	push   %eax
  8014e2:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8014e8:	e8 fc f6 ff ff       	call   800be9 <sys_env_set_trapframe>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	79 15                	jns    801509 <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  8014f4:	50                   	push   %eax
  8014f5:	68 91 2d 80 00       	push   $0x802d91
  8014fa:	68 86 00 00 00       	push   $0x86
  8014ff:	68 68 2d 80 00       	push   $0x802d68
  801504:	e8 df ec ff ff       	call   8001e8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	6a 02                	push   $0x2
  80150e:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801514:	e8 12 f7 ff ff       	call   800c2b <sys_env_set_status>
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	79 6d                	jns    80158d <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  801520:	50                   	push   %eax
  801521:	68 49 2c 80 00       	push   $0x802c49
  801526:	68 89 00 00 00       	push   $0x89
  80152b:	68 68 2d 80 00       	push   $0x802d68
  801530:	e8 b3 ec ff ff       	call   8001e8 <_panic>

	return child;

error:
	sys_env_destroy(child);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  80153e:	e8 2f f8 ff ff       	call   800d72 <sys_env_destroy>
	close(fd);
  801543:	83 c4 04             	add    $0x4,%esp
  801546:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  80154c:	e8 db 05 00 00       	call   801b2c <close>
  801551:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb 31                	jmp    80158d <spawn+0x541>
  80155c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801561:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801567:	eb 24                	jmp    80158d <spawn+0x541>
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  801572:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  801578:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  80157e:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  801585:	00 00 00 
  801588:	e9 bc fe ff ff       	jmp    801449 <spawn+0x3fd>
	return r;
}
  80158d:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 1c             	sub    $0x1c,%esp
  8015a4:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8015a6:	8d 45 10             	lea    0x10(%ebp),%eax
  8015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8015ac:	be 00 00 00 00       	mov    $0x0,%esi
  8015b1:	eb 01                	jmp    8015b4 <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  8015b3:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8015b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015b7:	8d 42 04             	lea    0x4(%edx),%eax
  8015ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8015bd:	83 3a 00             	cmpl   $0x0,(%edx)
  8015c0:	75 f1                	jne    8015b3 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8015c2:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  8015c9:	83 e0 f0             	and    $0xfffffff0,%eax
  8015cc:	29 c4                	sub    %eax,%esp
  8015ce:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8015d2:	89 c3                	mov    %eax,%ebx
  8015d4:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  8015d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015da:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  8015dc:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  8015e3:	00 

	va_start(vl, arg0);
  8015e4:	8d 45 10             	lea    0x10(%ebp),%eax
  8015e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8015ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ef:	eb 0f                	jmp    801600 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  8015f1:	41                   	inc    %ecx
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	8d 50 04             	lea    0x4(%eax),%edx
  8015f8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8015fb:	8b 00                	mov    (%eax),%eax
  8015fd:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801600:	39 f1                	cmp    %esi,%ecx
  801602:	75 ed                	jne    8015f1 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	53                   	push   %ebx
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 3c fa ff ff       	call   80104c <spawn>
  801610:	89 fc                	mov    %edi,%esp
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	c9                   	leave  
  801619:	c3                   	ret    
	...

0080161c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	56                   	push   %esi
  801620:	53                   	push   %ebx
  801621:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801624:	85 f6                	test   %esi,%esi
  801626:	75 16                	jne    80163e <wait+0x22>
  801628:	68 d2 2d 80 00       	push   $0x802dd2
  80162d:	68 53 2d 80 00       	push   $0x802d53
  801632:	6a 09                	push   $0x9
  801634:	68 dd 2d 80 00       	push   $0x802ddd
  801639:	e8 aa eb ff ff       	call   8001e8 <_panic>
	e = &envs[ENVX(envid)];
  80163e:	89 f0                	mov    %esi,%eax
  801640:	25 ff 03 00 00       	and    $0x3ff,%eax
  801645:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80164c:	c1 e0 07             	shl    $0x7,%eax
  80164f:	29 d0                	sub    %edx,%eax
  801651:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  801657:	eb 05                	jmp    80165e <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  801659:	e8 d6 f6 ff ff       	call   800d34 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80165e:	8b 43 48             	mov    0x48(%ebx),%eax
  801661:	39 c6                	cmp    %eax,%esi
  801663:	75 07                	jne    80166c <wait+0x50>
  801665:	8b 43 54             	mov    0x54(%ebx),%eax
  801668:	85 c0                	test   %eax,%eax
  80166a:	75 ed                	jne    801659 <wait+0x3d>
		sys_yield();
}
  80166c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	c9                   	leave  
  801672:	c3                   	ret    
	...

00801674 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80167a:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801681:	75 64                	jne    8016e7 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801683:	a1 04 40 80 00       	mov    0x804004,%eax
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	6a 07                	push   $0x7
  801690:	68 00 f0 bf ee       	push   $0xeebff000
  801695:	50                   	push   %eax
  801696:	e8 56 f6 ff ff       	call   800cf1 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	79 14                	jns    8016b6 <set_pgfault_handler+0x42>
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	68 e8 2d 80 00       	push   $0x802de8
  8016aa:	6a 22                	push   $0x22
  8016ac:	68 51 2e 80 00       	push   $0x802e51
  8016b1:	e8 32 eb ff ff       	call   8001e8 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  8016b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bb:	8b 40 48             	mov    0x48(%eax),%eax
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	68 f4 16 80 00       	push   $0x8016f4
  8016c6:	50                   	push   %eax
  8016c7:	e8 db f4 ff ff       	call   800ba7 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	79 14                	jns    8016e7 <set_pgfault_handler+0x73>
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	68 18 2e 80 00       	push   $0x802e18
  8016db:	6a 25                	push   $0x25
  8016dd:	68 51 2e 80 00       	push   $0x802e51
  8016e2:	e8 01 eb ff ff       	call   8001e8 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	a3 08 40 80 00       	mov    %eax,0x804008
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    
  8016f1:	00 00                	add    %al,(%eax)
	...

008016f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016f5:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8016fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016fc:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  8016ff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801703:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801706:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  80170a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  80170e:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801710:	83 c4 08             	add    $0x8,%esp
	popal
  801713:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801714:	83 c4 04             	add    $0x4,%esp
	popfl
  801717:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801718:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801719:	c3                   	ret    
	...

0080171c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	05 00 00 00 30       	add    $0x30000000,%eax
  801727:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80172f:	ff 75 08             	pushl  0x8(%ebp)
  801732:	e8 e5 ff ff ff       	call   80171c <fd2num>
  801737:	83 c4 04             	add    $0x4,%esp
  80173a:	c1 e0 0c             	shl    $0xc,%eax
  80173d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80174b:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801750:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801752:	89 d0                	mov    %edx,%eax
  801754:	c1 e8 16             	shr    $0x16,%eax
  801757:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80175e:	a8 01                	test   $0x1,%al
  801760:	74 10                	je     801772 <fd_alloc+0x2e>
  801762:	89 d0                	mov    %edx,%eax
  801764:	c1 e8 0c             	shr    $0xc,%eax
  801767:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80176e:	a8 01                	test   $0x1,%al
  801770:	75 09                	jne    80177b <fd_alloc+0x37>
			*fd_store = fd;
  801772:	89 0b                	mov    %ecx,(%ebx)
  801774:	b8 00 00 00 00       	mov    $0x0,%eax
  801779:	eb 19                	jmp    801794 <fd_alloc+0x50>
			return 0;
  80177b:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801781:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801787:	75 c7                	jne    801750 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801789:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80178f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801794:	5b                   	pop    %ebx
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80179d:	83 f8 1f             	cmp    $0x1f,%eax
  8017a0:	77 35                	ja     8017d7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017a2:	c1 e0 0c             	shl    $0xc,%eax
  8017a5:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017ab:	89 d0                	mov    %edx,%eax
  8017ad:	c1 e8 16             	shr    $0x16,%eax
  8017b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017b7:	a8 01                	test   $0x1,%al
  8017b9:	74 1c                	je     8017d7 <fd_lookup+0x40>
  8017bb:	89 d0                	mov    %edx,%eax
  8017bd:	c1 e8 0c             	shr    $0xc,%eax
  8017c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c7:	a8 01                	test   $0x1,%al
  8017c9:	74 0c                	je     8017d7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ce:	89 10                	mov    %edx,(%eax)
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d5:	eb 05                	jmp    8017dc <fd_lookup+0x45>
	return 0;
  8017d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017e7:	50                   	push   %eax
  8017e8:	ff 75 08             	pushl  0x8(%ebp)
  8017eb:	e8 a7 ff ff ff       	call   801797 <fd_lookup>
  8017f0:	83 c4 08             	add    $0x8,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 0e                	js     801805 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017fd:	89 50 04             	mov    %edx,0x4(%eax)
  801800:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	eb 0e                	jmp    801829 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80181b:	3b 08                	cmp    (%eax),%ecx
  80181d:	75 09                	jne    801828 <dev_lookup+0x21>
			*dev = devtab[i];
  80181f:	89 03                	mov    %eax,(%ebx)
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
  801826:	eb 31                	jmp    801859 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801828:	42                   	inc    %edx
  801829:	8b 04 95 dc 2e 80 00 	mov    0x802edc(,%edx,4),%eax
  801830:	85 c0                	test   %eax,%eax
  801832:	75 e7                	jne    80181b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801834:	a1 04 40 80 00       	mov    0x804004,%eax
  801839:	8b 40 48             	mov    0x48(%eax),%eax
  80183c:	83 ec 04             	sub    $0x4,%esp
  80183f:	51                   	push   %ecx
  801840:	50                   	push   %eax
  801841:	68 60 2e 80 00       	push   $0x802e60
  801846:	e8 3e ea ff ff       	call   800289 <cprintf>
	*dev = 0;
  80184b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801856:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 14             	sub    $0x14,%esp
  801865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	pushl  0x8(%ebp)
  80186f:	e8 23 ff ff ff       	call   801797 <fd_lookup>
  801874:	83 c4 08             	add    $0x8,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 55                	js     8018d0 <fstat+0x72>
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	ff 30                	pushl  (%eax)
  801887:	e8 7b ff ff ff       	call   801807 <dev_lookup>
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 3d                	js     8018d0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801893:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801896:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80189a:	75 07                	jne    8018a3 <fstat+0x45>
  80189c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018a1:	eb 2d                	jmp    8018d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018ad:	00 00 00 
	stat->st_isdir = 0;
  8018b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b7:	00 00 00 
	stat->st_dev = dev;
  8018ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8018bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	ff 50 14             	call   *0x14(%eax)
  8018cd:	83 c4 10             	add    $0x10,%esp
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 14             	sub    $0x14,%esp
  8018dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	53                   	push   %ebx
  8018e4:	e8 ae fe ff ff       	call   801797 <fd_lookup>
  8018e9:	83 c4 08             	add    $0x8,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 5f                	js     80194f <ftruncate+0x7a>
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fa:	ff 30                	pushl  (%eax)
  8018fc:	e8 06 ff ff ff       	call   801807 <dev_lookup>
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 47                	js     80194f <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80190f:	75 21                	jne    801932 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801911:	a1 04 40 80 00       	mov    0x804004,%eax
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	83 ec 04             	sub    $0x4,%esp
  80191c:	53                   	push   %ebx
  80191d:	50                   	push   %eax
  80191e:	68 80 2e 80 00       	push   $0x802e80
  801923:	e8 61 e9 ff ff       	call   800289 <cprintf>
  801928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	eb 1d                	jmp    80194f <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801932:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801935:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801939:	75 07                	jne    801942 <ftruncate+0x6d>
  80193b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801940:	eb 0d                	jmp    80194f <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801942:	83 ec 08             	sub    $0x8,%esp
  801945:	ff 75 0c             	pushl  0xc(%ebp)
  801948:	50                   	push   %eax
  801949:	ff 52 18             	call   *0x18(%edx)
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 14             	sub    $0x14,%esp
  80195b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	53                   	push   %ebx
  801963:	e8 2f fe ff ff       	call   801797 <fd_lookup>
  801968:	83 c4 08             	add    $0x8,%esp
  80196b:	85 c0                	test   %eax,%eax
  80196d:	78 62                	js     8019d1 <write+0x7d>
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801975:	50                   	push   %eax
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	ff 30                	pushl  (%eax)
  80197b:	e8 87 fe ff ff       	call   801807 <dev_lookup>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 4a                	js     8019d1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80198e:	75 21                	jne    8019b1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801990:	a1 04 40 80 00       	mov    0x804004,%eax
  801995:	8b 40 48             	mov    0x48(%eax),%eax
  801998:	83 ec 04             	sub    $0x4,%esp
  80199b:	53                   	push   %ebx
  80199c:	50                   	push   %eax
  80199d:	68 a1 2e 80 00       	push   $0x802ea1
  8019a2:	e8 e2 e8 ff ff       	call   800289 <cprintf>
  8019a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	eb 20                	jmp    8019d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019b1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8019b4:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8019b8:	75 07                	jne    8019c1 <write+0x6d>
  8019ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019bf:	eb 10                	jmp    8019d1 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	ff 75 10             	pushl  0x10(%ebp)
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	50                   	push   %eax
  8019cb:	ff 52 0c             	call   *0xc(%edx)
  8019ce:	83 c4 10             	add    $0x10,%esp
}
  8019d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	53                   	push   %ebx
  8019da:	83 ec 14             	sub    $0x14,%esp
  8019dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	53                   	push   %ebx
  8019e5:	e8 ad fd ff ff       	call   801797 <fd_lookup>
  8019ea:	83 c4 08             	add    $0x8,%esp
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 67                	js     801a58 <read+0x82>
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8019f7:	50                   	push   %eax
  8019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fb:	ff 30                	pushl  (%eax)
  8019fd:	e8 05 fe ff ff       	call   801807 <dev_lookup>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 4f                	js     801a58 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0c:	8b 42 08             	mov    0x8(%edx),%eax
  801a0f:	83 e0 03             	and    $0x3,%eax
  801a12:	83 f8 01             	cmp    $0x1,%eax
  801a15:	75 21                	jne    801a38 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a17:	a1 04 40 80 00       	mov    0x804004,%eax
  801a1c:	8b 40 48             	mov    0x48(%eax),%eax
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	53                   	push   %ebx
  801a23:	50                   	push   %eax
  801a24:	68 be 2e 80 00       	push   $0x802ebe
  801a29:	e8 5b e8 ff ff       	call   800289 <cprintf>
  801a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	eb 20                	jmp    801a58 <read+0x82>
	}
	if (!dev->dev_read)
  801a38:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801a3b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  801a3f:	75 07                	jne    801a48 <read+0x72>
  801a41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a46:	eb 10                	jmp    801a58 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a48:	83 ec 04             	sub    $0x4,%esp
  801a4b:	ff 75 10             	pushl  0x10(%ebp)
  801a4e:	ff 75 0c             	pushl  0xc(%ebp)
  801a51:	52                   	push   %edx
  801a52:	ff 50 08             	call   *0x8(%eax)
  801a55:	83 c4 10             	add    $0x10,%esp
}
  801a58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	57                   	push   %edi
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a69:	8b 75 10             	mov    0x10(%ebp),%esi
  801a6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a71:	eb 21                	jmp    801a94 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a73:	83 ec 04             	sub    $0x4,%esp
  801a76:	89 f0                	mov    %esi,%eax
  801a78:	29 d0                	sub    %edx,%eax
  801a7a:	50                   	push   %eax
  801a7b:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801a7e:	50                   	push   %eax
  801a7f:	ff 75 08             	pushl  0x8(%ebp)
  801a82:	e8 4f ff ff ff       	call   8019d6 <read>
		if (m < 0)
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 0e                	js     801a9c <readn+0x3f>
			return m;
		if (m == 0)
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	74 08                	je     801a9a <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a92:	01 c3                	add    %eax,%ebx
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	39 f3                	cmp    %esi,%ebx
  801a98:	72 d9                	jb     801a73 <readn+0x16>
  801a9a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 20             	sub    $0x20,%esp
  801aac:	8b 75 08             	mov    0x8(%ebp),%esi
  801aaf:	8a 45 0c             	mov    0xc(%ebp),%al
  801ab2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	56                   	push   %esi
  801aba:	e8 5d fc ff ff       	call   80171c <fd2num>
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 d0 fc ff ff       	call   801797 <fd_lookup>
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	83 c4 08             	add    $0x8,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 05                	js     801ad5 <fd_close+0x31>
  801ad0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ad3:	74 0d                	je     801ae2 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801ad5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801ad9:	75 48                	jne    801b23 <fd_close+0x7f>
  801adb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae0:	eb 41                	jmp    801b23 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ae2:	83 ec 08             	sub    $0x8,%esp
  801ae5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae8:	50                   	push   %eax
  801ae9:	ff 36                	pushl  (%esi)
  801aeb:	e8 17 fd ff ff       	call   801807 <dev_lookup>
  801af0:	89 c3                	mov    %eax,%ebx
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 1c                	js     801b15 <fd_close+0x71>
		if (dev->dev_close)
  801af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afc:	8b 40 10             	mov    0x10(%eax),%eax
  801aff:	85 c0                	test   %eax,%eax
  801b01:	75 07                	jne    801b0a <fd_close+0x66>
  801b03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b08:	eb 0b                	jmp    801b15 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	56                   	push   %esi
  801b0e:	ff d0                	call   *%eax
  801b10:	89 c3                	mov    %eax,%ebx
  801b12:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b15:	83 ec 08             	sub    $0x8,%esp
  801b18:	56                   	push   %esi
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 4d f1 ff ff       	call   800c6d <sys_page_unmap>
  801b20:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801b23:	89 d8                	mov    %ebx,%eax
  801b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b32:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b35:	50                   	push   %eax
  801b36:	ff 75 08             	pushl  0x8(%ebp)
  801b39:	e8 59 fc ff ff       	call   801797 <fd_lookup>
  801b3e:	83 c4 08             	add    $0x8,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 10                	js     801b55 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801b45:	83 ec 08             	sub    $0x8,%esp
  801b48:	6a 01                	push   $0x1
  801b4a:	ff 75 fc             	pushl  -0x4(%ebp)
  801b4d:	e8 52 ff ff ff       	call   801aa4 <fd_close>
  801b52:	83 c4 10             	add    $0x10,%esp
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	6a 00                	push   $0x0
  801b61:	ff 75 08             	pushl  0x8(%ebp)
  801b64:	e8 4a 03 00 00       	call   801eb3 <open>
  801b69:	89 c6                	mov    %eax,%esi
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 1b                	js     801b8d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	50                   	push   %eax
  801b79:	e8 e0 fc ff ff       	call   80185e <fstat>
  801b7e:	89 c3                	mov    %eax,%ebx
	close(fd);
  801b80:	89 34 24             	mov    %esi,(%esp)
  801b83:	e8 a4 ff ff ff       	call   801b2c <close>
  801b88:	89 de                	mov    %ebx,%esi
  801b8a:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801b8d:	89 f0                	mov    %esi,%eax
  801b8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
  801b9f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ba2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba5:	50                   	push   %eax
  801ba6:	ff 75 08             	pushl  0x8(%ebp)
  801ba9:	e8 e9 fb ff ff       	call   801797 <fd_lookup>
  801bae:	89 c3                	mov    %eax,%ebx
  801bb0:	83 c4 08             	add    $0x8,%esp
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	0f 88 bd 00 00 00    	js     801c78 <dup+0xe2>
		return r;
	close(newfdnum);
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	57                   	push   %edi
  801bbf:	e8 68 ff ff ff       	call   801b2c <close>

	newfd = INDEX2FD(newfdnum);
  801bc4:	89 f8                	mov    %edi,%eax
  801bc6:	c1 e0 0c             	shl    $0xc,%eax
  801bc9:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801bcf:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd2:	e8 55 fb ff ff       	call   80172c <fd2data>
  801bd7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bd9:	89 34 24             	mov    %esi,(%esp)
  801bdc:	e8 4b fb ff ff       	call   80172c <fd2data>
  801be1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	c1 e8 16             	shr    $0x16,%eax
  801be9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bf0:	83 c4 14             	add    $0x14,%esp
  801bf3:	a8 01                	test   $0x1,%al
  801bf5:	74 36                	je     801c2d <dup+0x97>
  801bf7:	89 da                	mov    %ebx,%edx
  801bf9:	c1 ea 0c             	shr    $0xc,%edx
  801bfc:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c03:	a8 01                	test   $0x1,%al
  801c05:	74 26                	je     801c2d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c07:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	25 07 0e 00 00       	and    $0xe07,%eax
  801c16:	50                   	push   %eax
  801c17:	ff 75 e0             	pushl  -0x20(%ebp)
  801c1a:	6a 00                	push   $0x0
  801c1c:	53                   	push   %ebx
  801c1d:	6a 00                	push   $0x0
  801c1f:	e8 8b f0 ff ff       	call   800caf <sys_page_map>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 20             	add    $0x20,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 30                	js     801c5d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c2d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c30:	89 d0                	mov    %edx,%eax
  801c32:	c1 e8 0c             	shr    $0xc,%eax
  801c35:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c3c:	83 ec 0c             	sub    $0xc,%esp
  801c3f:	25 07 0e 00 00       	and    $0xe07,%eax
  801c44:	50                   	push   %eax
  801c45:	56                   	push   %esi
  801c46:	6a 00                	push   $0x0
  801c48:	52                   	push   %edx
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 5f f0 ff ff       	call   800caf <sys_page_map>
  801c50:	89 c3                	mov    %eax,%ebx
  801c52:	83 c4 20             	add    $0x20,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 04                	js     801c5d <dup+0xc7>
		goto err;
  801c59:	89 fb                	mov    %edi,%ebx
  801c5b:	eb 1b                	jmp    801c78 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c5d:	83 ec 08             	sub    $0x8,%esp
  801c60:	56                   	push   %esi
  801c61:	6a 00                	push   $0x0
  801c63:	e8 05 f0 ff ff       	call   800c6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c68:	83 c4 08             	add    $0x8,%esp
  801c6b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 f8 ef ff ff       	call   800c6d <sys_page_unmap>
  801c75:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	53                   	push   %ebx
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	53                   	push   %ebx
  801c92:	e8 95 fe ff ff       	call   801b2c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c97:	43                   	inc    %ebx
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	83 fb 20             	cmp    $0x20,%ebx
  801c9e:	75 ee                	jne    801c8e <close_all+0xc>
		close(i);
}
  801ca0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    
  801ca5:	00 00                	add    %al,(%eax)
	...

00801ca8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cb1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801cb8:	75 12                	jne    801ccc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cba:	83 ec 0c             	sub    $0xc,%esp
  801cbd:	6a 01                	push   $0x1
  801cbf:	e8 48 07 00 00       	call   80240c <ipc_find_env>
  801cc4:	a3 00 40 80 00       	mov    %eax,0x804000
  801cc9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ccc:	6a 07                	push   $0x7
  801cce:	68 00 50 80 00       	push   $0x805000
  801cd3:	53                   	push   %ebx
  801cd4:	ff 35 00 40 80 00    	pushl  0x804000
  801cda:	e8 72 07 00 00       	call   802451 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cdf:	83 c4 0c             	add    $0xc,%esp
  801ce2:	6a 00                	push   $0x0
  801ce4:	56                   	push   %esi
  801ce5:	6a 00                	push   $0x0
  801ce7:	e8 ba 07 00 00       	call   8024a6 <ipc_recv>
}
  801cec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfe:	b8 08 00 00 00       	mov    $0x8,%eax
  801d03:	e8 a0 ff ff ff       	call   801ca8 <fsipc>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	8b 40 0c             	mov    0xc(%eax),%eax
  801d16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d23:	ba 00 00 00 00       	mov    $0x0,%edx
  801d28:	b8 02 00 00 00       	mov    $0x2,%eax
  801d2d:	e8 76 ff ff ff       	call   801ca8 <fsipc>
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d40:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d45:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4a:	b8 06 00 00 00       	mov    $0x6,%eax
  801d4f:	e8 54 ff ff ff       	call   801ca8 <fsipc>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	53                   	push   %ebx
  801d5a:	83 ec 04             	sub    $0x4,%esp
  801d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	8b 40 0c             	mov    0xc(%eax),%eax
  801d66:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d70:	b8 05 00 00 00       	mov    $0x5,%eax
  801d75:	e8 2e ff ff ff       	call   801ca8 <fsipc>
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 2c                	js     801daa <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d7e:	83 ec 08             	sub    $0x8,%esp
  801d81:	68 00 50 80 00       	push   $0x805000
  801d86:	53                   	push   %ebx
  801d87:	e8 4f ea ff ff       	call   8007db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d8c:	a1 80 50 80 00       	mov    0x805080,%eax
  801d91:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d97:	a1 84 50 80 00       	mov    0x805084,%eax
  801d9c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
  801da7:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  801daa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	53                   	push   %ebx
  801db3:	83 ec 08             	sub    $0x8,%esp
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801db9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbc:	8b 40 0c             	mov    0xc(%eax),%eax
  801dbf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801dc4:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801dca:	53                   	push   %ebx
  801dcb:	ff 75 0c             	pushl  0xc(%ebp)
  801dce:	68 08 50 80 00       	push   $0x805008
  801dd3:	e8 70 eb ff ff       	call   800948 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801ddd:	b8 04 00 00 00       	mov    $0x4,%eax
  801de2:	e8 c1 fe ff ff       	call   801ca8 <fsipc>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 3d                	js     801e2b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801dee:	39 c3                	cmp    %eax,%ebx
  801df0:	73 19                	jae    801e0b <devfile_write+0x5c>
  801df2:	68 ec 2e 80 00       	push   $0x802eec
  801df7:	68 53 2d 80 00       	push   $0x802d53
  801dfc:	68 97 00 00 00       	push   $0x97
  801e01:	68 f3 2e 80 00       	push   $0x802ef3
  801e06:	e8 dd e3 ff ff       	call   8001e8 <_panic>
	assert(r <= PGSIZE);
  801e0b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e10:	7e 19                	jle    801e2b <devfile_write+0x7c>
  801e12:	68 fe 2e 80 00       	push   $0x802efe
  801e17:	68 53 2d 80 00       	push   $0x802d53
  801e1c:	68 98 00 00 00       	push   $0x98
  801e21:	68 f3 2e 80 00       	push   $0x802ef3
  801e26:	e8 bd e3 ff ff       	call   8001e8 <_panic>
	
	return r;
}
  801e2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
  801e35:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e38:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801e43:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e49:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4e:	b8 03 00 00 00       	mov    $0x3,%eax
  801e53:	e8 50 fe ff ff       	call   801ca8 <fsipc>
  801e58:	89 c3                	mov    %eax,%ebx
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 4c                	js     801eaa <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801e5e:	39 de                	cmp    %ebx,%esi
  801e60:	73 16                	jae    801e78 <devfile_read+0x48>
  801e62:	68 ec 2e 80 00       	push   $0x802eec
  801e67:	68 53 2d 80 00       	push   $0x802d53
  801e6c:	6a 7c                	push   $0x7c
  801e6e:	68 f3 2e 80 00       	push   $0x802ef3
  801e73:	e8 70 e3 ff ff       	call   8001e8 <_panic>
	assert(r <= PGSIZE);
  801e78:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801e7e:	7e 16                	jle    801e96 <devfile_read+0x66>
  801e80:	68 fe 2e 80 00       	push   $0x802efe
  801e85:	68 53 2d 80 00       	push   $0x802d53
  801e8a:	6a 7d                	push   $0x7d
  801e8c:	68 f3 2e 80 00       	push   $0x802ef3
  801e91:	e8 52 e3 ff ff       	call   8001e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	50                   	push   %eax
  801e9a:	68 00 50 80 00       	push   $0x805000
  801e9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ea2:	e8 a1 ea ff ff       	call   800948 <memmove>
  801ea7:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801eaa:	89 d8                	mov    %ebx,%eax
  801eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ebe:	56                   	push   %esi
  801ebf:	e8 e4 e8 ff ff       	call   8007a8 <strlen>
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ecc:	7e 07                	jle    801ed5 <open+0x22>
  801ece:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ed3:	eb 63                	jmp    801f38 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	e8 63 f8 ff ff       	call   801744 <fd_alloc>
  801ee1:	89 c3                	mov    %eax,%ebx
  801ee3:	83 c4 10             	add    $0x10,%esp
  801ee6:	85 c0                	test   %eax,%eax
  801ee8:	78 4e                	js     801f38 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	56                   	push   %esi
  801eee:	68 00 50 80 00       	push   $0x805000
  801ef3:	e8 e3 e8 ff ff       	call   8007db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f03:	b8 01 00 00 00       	mov    $0x1,%eax
  801f08:	e8 9b fd ff ff       	call   801ca8 <fsipc>
  801f0d:	89 c3                	mov    %eax,%ebx
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	79 12                	jns    801f28 <open+0x75>
		fd_close(fd, 0);
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	6a 00                	push   $0x0
  801f1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1e:	e8 81 fb ff ff       	call   801aa4 <fd_close>
		return r;
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	eb 10                	jmp    801f38 <open+0x85>
	}

	return fd2num(fd);
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2e:	e8 e9 f7 ff ff       	call   80171c <fd2num>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
}
  801f38:	89 d8                	mov    %ebx,%eax
  801f3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    
  801f41:	00 00                	add    %al,(%eax)
	...

00801f44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	ff 75 08             	pushl  0x8(%ebp)
  801f52:	e8 d5 f7 ff ff       	call   80172c <fd2data>
  801f57:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f59:	83 c4 08             	add    $0x8,%esp
  801f5c:	68 0a 2f 80 00       	push   $0x802f0a
  801f61:	53                   	push   %ebx
  801f62:	e8 74 e8 ff ff       	call   8007db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f67:	8b 46 04             	mov    0x4(%esi),%eax
  801f6a:	2b 06                	sub    (%esi),%eax
  801f6c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f72:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f79:	00 00 00 
	stat->st_dev = &devpipe;
  801f7c:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801f83:	30 80 00 
	return 0;
}
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f9c:	53                   	push   %ebx
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 c9 ec ff ff       	call   800c6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa4:	89 1c 24             	mov    %ebx,(%esp)
  801fa7:	e8 80 f7 ff ff       	call   80172c <fd2data>
  801fac:	83 c4 08             	add    $0x8,%esp
  801faf:	50                   	push   %eax
  801fb0:	6a 00                	push   $0x0
  801fb2:	e8 b6 ec ff ff       	call   800c6d <sys_page_unmap>
}
  801fb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 0c             	sub    $0xc,%esp
  801fc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801fc8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fca:	a1 04 40 80 00       	mov    0x804004,%eax
  801fcf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	ff 75 f0             	pushl  -0x10(%ebp)
  801fd8:	e8 33 05 00 00       	call   802510 <pageref>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	89 3c 24             	mov    %edi,(%esp)
  801fe2:	e8 29 05 00 00       	call   802510 <pageref>
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	39 c3                	cmp    %eax,%ebx
  801fec:	0f 94 c0             	sete   %al
  801fef:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801ff2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ff8:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801ffb:	39 c6                	cmp    %eax,%esi
  801ffd:	74 1b                	je     80201a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801fff:	83 f9 01             	cmp    $0x1,%ecx
  802002:	75 c6                	jne    801fca <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802004:	8b 42 58             	mov    0x58(%edx),%eax
  802007:	6a 01                	push   $0x1
  802009:	50                   	push   %eax
  80200a:	56                   	push   %esi
  80200b:	68 11 2f 80 00       	push   $0x802f11
  802010:	e8 74 e2 ff ff       	call   800289 <cprintf>
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	eb b0                	jmp    801fca <_pipeisclosed+0xe>
	}
}
  80201a:	89 c8                	mov    %ecx,%eax
  80201c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 18             	sub    $0x18,%esp
  80202d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802030:	56                   	push   %esi
  802031:	e8 f6 f6 ff ff       	call   80172c <fd2data>
  802036:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  802038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80203e:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	eb 40                	jmp    802088 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802048:	b8 00 00 00 00       	mov    $0x0,%eax
  80204d:	eb 40                	jmp    80208f <devpipe_write+0x6b>
  80204f:	89 da                	mov    %ebx,%edx
  802051:	89 f0                	mov    %esi,%eax
  802053:	e8 64 ff ff ff       	call   801fbc <_pipeisclosed>
  802058:	85 c0                	test   %eax,%eax
  80205a:	75 ec                	jne    802048 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80205c:	e8 d3 ec ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802061:	8b 53 04             	mov    0x4(%ebx),%edx
  802064:	8b 03                	mov    (%ebx),%eax
  802066:	83 c0 20             	add    $0x20,%eax
  802069:	39 c2                	cmp    %eax,%edx
  80206b:	73 e2                	jae    80204f <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80206d:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802073:	79 05                	jns    80207a <devpipe_write+0x56>
  802075:	4a                   	dec    %edx
  802076:	83 ca e0             	or     $0xffffffe0,%edx
  802079:	42                   	inc    %edx
  80207a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80207d:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  802080:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802084:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802087:	47                   	inc    %edi
  802088:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80208b:	75 d4                	jne    802061 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80208d:	89 f8                	mov    %edi,%eax
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	57                   	push   %edi
  80209b:	56                   	push   %esi
  80209c:	53                   	push   %ebx
  80209d:	83 ec 18             	sub    $0x18,%esp
  8020a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020a3:	57                   	push   %edi
  8020a4:	e8 83 f6 ff ff       	call   80172c <fd2data>
  8020a9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8020ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8020b1:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	eb 41                	jmp    8020fc <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8020bb:	89 f0                	mov    %esi,%eax
  8020bd:	eb 44                	jmp    802103 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c4:	eb 3d                	jmp    802103 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020c6:	85 f6                	test   %esi,%esi
  8020c8:	75 f1                	jne    8020bb <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020ca:	89 da                	mov    %ebx,%edx
  8020cc:	89 f8                	mov    %edi,%eax
  8020ce:	e8 e9 fe ff ff       	call   801fbc <_pipeisclosed>
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	75 e8                	jne    8020bf <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020d7:	e8 58 ec ff ff       	call   800d34 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020dc:	8b 03                	mov    (%ebx),%eax
  8020de:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020e1:	74 e3                	je     8020c6 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020e3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8020e8:	79 05                	jns    8020ef <devpipe_read+0x58>
  8020ea:	48                   	dec    %eax
  8020eb:	83 c8 e0             	or     $0xffffffe0,%eax
  8020ee:	40                   	inc    %eax
  8020ef:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8020f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020f6:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  8020f9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020fb:	46                   	inc    %esi
  8020fc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020ff:	75 db                	jne    8020dc <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802101:	89 f0                	mov    %esi,%eax
}
  802103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802106:	5b                   	pop    %ebx
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802111:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802114:	50                   	push   %eax
  802115:	ff 75 08             	pushl  0x8(%ebp)
  802118:	e8 7a f6 ff ff       	call   801797 <fd_lookup>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	78 18                	js     80213c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802124:	83 ec 0c             	sub    $0xc,%esp
  802127:	ff 75 fc             	pushl  -0x4(%ebp)
  80212a:	e8 fd f5 ff ff       	call   80172c <fd2data>
  80212f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802131:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802134:	e8 83 fe ff ff       	call   801fbc <_pipeisclosed>
  802139:	83 c4 10             	add    $0x10,%esp
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	57                   	push   %edi
  802142:	56                   	push   %esi
  802143:	53                   	push   %ebx
  802144:	83 ec 28             	sub    $0x28,%esp
  802147:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80214a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80214d:	50                   	push   %eax
  80214e:	e8 f1 f5 ff ff       	call   801744 <fd_alloc>
  802153:	89 c3                	mov    %eax,%ebx
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	85 c0                	test   %eax,%eax
  80215a:	0f 88 24 01 00 00    	js     802284 <pipe+0x146>
  802160:	83 ec 04             	sub    $0x4,%esp
  802163:	68 07 04 00 00       	push   $0x407
  802168:	ff 75 f0             	pushl  -0x10(%ebp)
  80216b:	6a 00                	push   $0x0
  80216d:	e8 7f eb ff ff       	call   800cf1 <sys_page_alloc>
  802172:	89 c3                	mov    %eax,%ebx
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	0f 88 05 01 00 00    	js     802284 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802185:	50                   	push   %eax
  802186:	e8 b9 f5 ff ff       	call   801744 <fd_alloc>
  80218b:	89 c3                	mov    %eax,%ebx
  80218d:	83 c4 10             	add    $0x10,%esp
  802190:	85 c0                	test   %eax,%eax
  802192:	0f 88 dc 00 00 00    	js     802274 <pipe+0x136>
  802198:	83 ec 04             	sub    $0x4,%esp
  80219b:	68 07 04 00 00       	push   $0x407
  8021a0:	ff 75 ec             	pushl  -0x14(%ebp)
  8021a3:	6a 00                	push   $0x0
  8021a5:	e8 47 eb ff ff       	call   800cf1 <sys_page_alloc>
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	83 c4 10             	add    $0x10,%esp
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	0f 88 bd 00 00 00    	js     802274 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021b7:	83 ec 0c             	sub    $0xc,%esp
  8021ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8021bd:	e8 6a f5 ff ff       	call   80172c <fd2data>
  8021c2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c4:	83 c4 0c             	add    $0xc,%esp
  8021c7:	68 07 04 00 00       	push   $0x407
  8021cc:	50                   	push   %eax
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 1d eb ff ff       	call   800cf1 <sys_page_alloc>
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	83 c4 10             	add    $0x10,%esp
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	0f 88 83 00 00 00    	js     802264 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e1:	83 ec 0c             	sub    $0xc,%esp
  8021e4:	ff 75 ec             	pushl  -0x14(%ebp)
  8021e7:	e8 40 f5 ff ff       	call   80172c <fd2data>
  8021ec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021f3:	50                   	push   %eax
  8021f4:	6a 00                	push   $0x0
  8021f6:	56                   	push   %esi
  8021f7:	6a 00                	push   $0x0
  8021f9:	e8 b1 ea ff ff       	call   800caf <sys_page_map>
  8021fe:	89 c3                	mov    %eax,%ebx
  802200:	83 c4 20             	add    $0x20,%esp
  802203:	85 c0                	test   %eax,%eax
  802205:	78 4f                	js     802256 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802207:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80220d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802210:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802215:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80221c:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802222:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802225:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802227:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80222a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802231:	83 ec 0c             	sub    $0xc,%esp
  802234:	ff 75 f0             	pushl  -0x10(%ebp)
  802237:	e8 e0 f4 ff ff       	call   80171c <fd2num>
  80223c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80223e:	83 c4 04             	add    $0x4,%esp
  802241:	ff 75 ec             	pushl  -0x14(%ebp)
  802244:	e8 d3 f4 ff ff       	call   80171c <fd2num>
  802249:	89 47 04             	mov    %eax,0x4(%edi)
  80224c:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  802251:	83 c4 10             	add    $0x10,%esp
  802254:	eb 2e                	jmp    802284 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802256:	83 ec 08             	sub    $0x8,%esp
  802259:	56                   	push   %esi
  80225a:	6a 00                	push   $0x0
  80225c:	e8 0c ea ff ff       	call   800c6d <sys_page_unmap>
  802261:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802264:	83 ec 08             	sub    $0x8,%esp
  802267:	ff 75 ec             	pushl  -0x14(%ebp)
  80226a:	6a 00                	push   $0x0
  80226c:	e8 fc e9 ff ff       	call   800c6d <sys_page_unmap>
  802271:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802274:	83 ec 08             	sub    $0x8,%esp
  802277:	ff 75 f0             	pushl  -0x10(%ebp)
  80227a:	6a 00                	push   $0x0
  80227c:	e8 ec e9 ff ff       	call   800c6d <sys_page_unmap>
  802281:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802284:	89 d8                	mov    %ebx,%eax
  802286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802289:	5b                   	pop    %ebx
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	c9                   	leave  
  80228d:	c3                   	ret    
	...

00802290 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a0:	68 29 2f 80 00       	push   $0x802f29
  8022a5:	ff 75 0c             	pushl  0xc(%ebp)
  8022a8:	e8 2e e5 ff ff       	call   8007db <strcpy>
	return 0;
}
  8022ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	57                   	push   %edi
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
  8022ba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  8022c0:	be 00 00 00 00       	mov    $0x0,%esi
  8022c5:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  8022cb:	eb 2c                	jmp    8022f9 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8022d2:	83 fb 7f             	cmp    $0x7f,%ebx
  8022d5:	76 05                	jbe    8022dc <devcons_write+0x28>
  8022d7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022dc:	83 ec 04             	sub    $0x4,%esp
  8022df:	53                   	push   %ebx
  8022e0:	03 45 0c             	add    0xc(%ebp),%eax
  8022e3:	50                   	push   %eax
  8022e4:	57                   	push   %edi
  8022e5:	e8 5e e6 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  8022ea:	83 c4 08             	add    $0x8,%esp
  8022ed:	53                   	push   %ebx
  8022ee:	57                   	push   %edi
  8022ef:	e8 2b e8 ff ff       	call   800b1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f4:	01 de                	add    %ebx,%esi
  8022f6:	83 c4 10             	add    $0x10,%esp
  8022f9:	89 f0                	mov    %esi,%eax
  8022fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022fe:	72 cd                	jb     8022cd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	c9                   	leave  
  802307:	c3                   	ret    

00802308 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802308:	55                   	push   %ebp
  802309:	89 e5                	mov    %esp,%ebp
  80230b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80230e:	8b 45 08             	mov    0x8(%ebp),%eax
  802311:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802314:	6a 01                	push   $0x1
  802316:	8d 45 ff             	lea    -0x1(%ebp),%eax
  802319:	50                   	push   %eax
  80231a:	e8 00 e8 ff ff       	call   800b1f <sys_cputs>
  80231f:	83 c4 10             	add    $0x10,%esp
}
  802322:	c9                   	leave  
  802323:	c3                   	ret    

00802324 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802324:	55                   	push   %ebp
  802325:	89 e5                	mov    %esp,%ebp
  802327:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80232a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232e:	74 27                	je     802357 <devcons_read+0x33>
  802330:	eb 05                	jmp    802337 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802332:	e8 fd e9 ff ff       	call   800d34 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802337:	e8 c4 e7 ff ff       	call   800b00 <sys_cgetc>
  80233c:	89 c2                	mov    %eax,%edx
  80233e:	85 c0                	test   %eax,%eax
  802340:	74 f0                	je     802332 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  802342:	85 c0                	test   %eax,%eax
  802344:	78 16                	js     80235c <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802346:	83 f8 04             	cmp    $0x4,%eax
  802349:	74 0c                	je     802357 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  80234b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80234e:	88 10                	mov    %dl,(%eax)
  802350:	ba 01 00 00 00       	mov    $0x1,%edx
  802355:	eb 05                	jmp    80235c <devcons_read+0x38>
	return 1;
  802357:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80235c:	89 d0                	mov    %edx,%eax
  80235e:	c9                   	leave  
  80235f:	c3                   	ret    

00802360 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802366:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802369:	50                   	push   %eax
  80236a:	e8 d5 f3 ff ff       	call   801744 <fd_alloc>
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	78 3b                	js     8023b1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802376:	83 ec 04             	sub    $0x4,%esp
  802379:	68 07 04 00 00       	push   $0x407
  80237e:	ff 75 fc             	pushl  -0x4(%ebp)
  802381:	6a 00                	push   $0x0
  802383:	e8 69 e9 ff ff       	call   800cf1 <sys_page_alloc>
  802388:	83 c4 10             	add    $0x10,%esp
  80238b:	85 c0                	test   %eax,%eax
  80238d:	78 22                	js     8023b1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80238f:	a1 44 30 80 00       	mov    0x803044,%eax
  802394:	8b 55 fc             	mov    -0x4(%ebp),%edx
  802397:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  802399:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80239c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023a3:	83 ec 0c             	sub    $0xc,%esp
  8023a6:	ff 75 fc             	pushl  -0x4(%ebp)
  8023a9:	e8 6e f3 ff ff       	call   80171c <fd2num>
  8023ae:	83 c4 10             	add    $0x10,%esp
}
  8023b1:	c9                   	leave  
  8023b2:	c3                   	ret    

008023b3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023b3:	55                   	push   %ebp
  8023b4:	89 e5                	mov    %esp,%ebp
  8023b6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023b9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8023bc:	50                   	push   %eax
  8023bd:	ff 75 08             	pushl  0x8(%ebp)
  8023c0:	e8 d2 f3 ff ff       	call   801797 <fd_lookup>
  8023c5:	83 c4 10             	add    $0x10,%esp
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	78 11                	js     8023dd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8023cf:	8b 00                	mov    (%eax),%eax
  8023d1:	3b 05 44 30 80 00    	cmp    0x803044,%eax
  8023d7:	0f 94 c0             	sete   %al
  8023da:	0f b6 c0             	movzbl %al,%eax
}
  8023dd:	c9                   	leave  
  8023de:	c3                   	ret    

008023df <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  8023df:	55                   	push   %ebp
  8023e0:	89 e5                	mov    %esp,%ebp
  8023e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023e5:	6a 01                	push   $0x1
  8023e7:	8d 45 ff             	lea    -0x1(%ebp),%eax
  8023ea:	50                   	push   %eax
  8023eb:	6a 00                	push   $0x0
  8023ed:	e8 e4 f5 ff ff       	call   8019d6 <read>
	if (r < 0)
  8023f2:	83 c4 10             	add    $0x10,%esp
  8023f5:	85 c0                	test   %eax,%eax
  8023f7:	78 0f                	js     802408 <getchar+0x29>
		return r;
	if (r < 1)
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	75 07                	jne    802404 <getchar+0x25>
  8023fd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802402:	eb 04                	jmp    802408 <getchar+0x29>
		return -E_EOF;
	return c;
  802404:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  802408:	c9                   	leave  
  802409:	c3                   	ret    
	...

0080240c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	53                   	push   %ebx
  802410:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802413:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802418:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  80241f:	89 c8                	mov    %ecx,%eax
  802421:	c1 e0 07             	shl    $0x7,%eax
  802424:	29 d0                	sub    %edx,%eax
  802426:	89 c2                	mov    %eax,%edx
  802428:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  80242e:	8b 40 50             	mov    0x50(%eax),%eax
  802431:	39 d8                	cmp    %ebx,%eax
  802433:	75 0b                	jne    802440 <ipc_find_env+0x34>
			return envs[i].env_id;
  802435:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  80243b:	8b 40 40             	mov    0x40(%eax),%eax
  80243e:	eb 0e                	jmp    80244e <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802440:	41                   	inc    %ecx
  802441:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  802447:	75 cf                	jne    802418 <ipc_find_env+0xc>
  802449:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80244e:	5b                   	pop    %ebx
  80244f:	c9                   	leave  
  802450:	c3                   	ret    

00802451 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	57                   	push   %edi
  802455:	56                   	push   %esi
  802456:	53                   	push   %ebx
  802457:	83 ec 0c             	sub    $0xc,%esp
  80245a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80245d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802460:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802463:	85 db                	test   %ebx,%ebx
  802465:	75 05                	jne    80246c <ipc_send+0x1b>
  802467:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80246c:	56                   	push   %esi
  80246d:	53                   	push   %ebx
  80246e:	57                   	push   %edi
  80246f:	ff 75 08             	pushl  0x8(%ebp)
  802472:	e8 0d e7 ff ff       	call   800b84 <sys_ipc_try_send>
		if (r == 0) {		//success
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	85 c0                	test   %eax,%eax
  80247c:	74 20                	je     80249e <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80247e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802481:	75 07                	jne    80248a <ipc_send+0x39>
			sys_yield();
  802483:	e8 ac e8 ff ff       	call   800d34 <sys_yield>
  802488:	eb e2                	jmp    80246c <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  80248a:	83 ec 04             	sub    $0x4,%esp
  80248d:	68 38 2f 80 00       	push   $0x802f38
  802492:	6a 41                	push   $0x41
  802494:	68 5c 2f 80 00       	push   $0x802f5c
  802499:	e8 4a dd ff ff       	call   8001e8 <_panic>
		}
	}
}
  80249e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	c9                   	leave  
  8024a5:	c3                   	ret    

008024a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024a6:	55                   	push   %ebp
  8024a7:	89 e5                	mov    %esp,%ebp
  8024a9:	56                   	push   %esi
  8024aa:	53                   	push   %ebx
  8024ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8024ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	75 05                	jne    8024bd <ipc_recv+0x17>
  8024b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  8024bd:	83 ec 0c             	sub    $0xc,%esp
  8024c0:	50                   	push   %eax
  8024c1:	e8 7d e6 ff ff       	call   800b43 <sys_ipc_recv>
	if (r < 0) {				
  8024c6:	83 c4 10             	add    $0x10,%esp
  8024c9:	85 c0                	test   %eax,%eax
  8024cb:	79 16                	jns    8024e3 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  8024cd:	85 db                	test   %ebx,%ebx
  8024cf:	74 06                	je     8024d7 <ipc_recv+0x31>
  8024d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8024d7:	85 f6                	test   %esi,%esi
  8024d9:	74 2c                	je     802507 <ipc_recv+0x61>
  8024db:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8024e1:	eb 24                	jmp    802507 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8024e3:	85 db                	test   %ebx,%ebx
  8024e5:	74 0a                	je     8024f1 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8024e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8024ec:	8b 40 74             	mov    0x74(%eax),%eax
  8024ef:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  8024f1:	85 f6                	test   %esi,%esi
  8024f3:	74 0a                	je     8024ff <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8024f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8024fa:	8b 40 78             	mov    0x78(%eax),%eax
  8024fd:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8024ff:	a1 04 40 80 00       	mov    0x804004,%eax
  802504:	8b 40 70             	mov    0x70(%eax),%eax
}
  802507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250a:	5b                   	pop    %ebx
  80250b:	5e                   	pop    %esi
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    
	...

00802510 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802516:	89 d0                	mov    %edx,%eax
  802518:	c1 e8 16             	shr    $0x16,%eax
  80251b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802522:	a8 01                	test   $0x1,%al
  802524:	74 20                	je     802546 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802526:	89 d0                	mov    %edx,%eax
  802528:	c1 e8 0c             	shr    $0xc,%eax
  80252b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802532:	a8 01                	test   $0x1,%al
  802534:	74 10                	je     802546 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802536:	c1 e8 0c             	shr    $0xc,%eax
  802539:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802540:	ef 
  802541:	0f b7 c0             	movzwl %ax,%eax
  802544:	eb 05                	jmp    80254b <pageref+0x3b>
  802546:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80254b:	c9                   	leave  
  80254c:	c3                   	ret    
  80254d:	00 00                	add    %al,(%eax)
	...

00802550 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	57                   	push   %edi
  802554:	56                   	push   %esi
  802555:	83 ec 28             	sub    $0x28,%esp
  802558:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80255f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802566:	8b 45 10             	mov    0x10(%ebp),%eax
  802569:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80256c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80256f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802571:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  802573:	8b 45 08             	mov    0x8(%ebp),%eax
  802576:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  802579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80257c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80257f:	85 ff                	test   %edi,%edi
  802581:	75 21                	jne    8025a4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  802583:	39 d1                	cmp    %edx,%ecx
  802585:	76 49                	jbe    8025d0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802587:	f7 f1                	div    %ecx
  802589:	89 c1                	mov    %eax,%ecx
  80258b:	31 c0                	xor    %eax,%eax
  80258d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802590:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  802593:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802599:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80259c:	83 c4 28             	add    $0x28,%esp
  80259f:	5e                   	pop    %esi
  8025a0:	5f                   	pop    %edi
  8025a1:	c9                   	leave  
  8025a2:	c3                   	ret    
  8025a3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025a4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8025a7:	0f 87 97 00 00 00    	ja     802644 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025ad:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8025b0:	83 f0 1f             	xor    $0x1f,%eax
  8025b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8025b6:	75 34                	jne    8025ec <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025b8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8025bb:	72 08                	jb     8025c5 <__udivdi3+0x75>
  8025bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8025c0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8025c3:	77 7f                	ja     802644 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025c5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8025ca:	31 c0                	xor    %eax,%eax
  8025cc:	eb c2                	jmp    802590 <__udivdi3+0x40>
  8025ce:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d3:	85 c0                	test   %eax,%eax
  8025d5:	74 79                	je     802650 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8025da:	89 fa                	mov    %edi,%edx
  8025dc:	f7 f1                	div    %ecx
  8025de:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8025e3:	f7 f1                	div    %ecx
  8025e5:	89 c1                	mov    %eax,%ecx
  8025e7:	89 f0                	mov    %esi,%eax
  8025e9:	eb a5                	jmp    802590 <__udivdi3+0x40>
  8025eb:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8025f1:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8025f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8025f7:	89 fa                	mov    %edi,%edx
  8025f9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8025fc:	d3 e2                	shl    %cl,%edx
  8025fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802601:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802604:	d3 e8                	shr    %cl,%eax
  802606:	89 d7                	mov    %edx,%edi
  802608:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80260a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80260d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802610:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802612:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802615:	d3 e0                	shl    %cl,%eax
  802617:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80261a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80261d:	d3 ea                	shr    %cl,%edx
  80261f:	09 d0                	or     %edx,%eax
  802621:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802624:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802627:	d3 ea                	shr    %cl,%edx
  802629:	f7 f7                	div    %edi
  80262b:	89 d7                	mov    %edx,%edi
  80262d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802630:	f7 e6                	mul    %esi
  802632:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802634:	39 d7                	cmp    %edx,%edi
  802636:	72 38                	jb     802670 <__udivdi3+0x120>
  802638:	74 27                	je     802661 <__udivdi3+0x111>
  80263a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80263d:	31 c0                	xor    %eax,%eax
  80263f:	e9 4c ff ff ff       	jmp    802590 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802644:	31 c9                	xor    %ecx,%ecx
  802646:	31 c0                	xor    %eax,%eax
  802648:	e9 43 ff ff ff       	jmp    802590 <__udivdi3+0x40>
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802650:	b8 01 00 00 00       	mov    $0x1,%eax
  802655:	31 d2                	xor    %edx,%edx
  802657:	f7 75 f4             	divl   -0xc(%ebp)
  80265a:	89 c1                	mov    %eax,%ecx
  80265c:	e9 76 ff ff ff       	jmp    8025d7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802661:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802664:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802667:	d3 e0                	shl    %cl,%eax
  802669:	39 f0                	cmp    %esi,%eax
  80266b:	73 cd                	jae    80263a <__udivdi3+0xea>
  80266d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802670:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802673:	49                   	dec    %ecx
  802674:	31 c0                	xor    %eax,%eax
  802676:	e9 15 ff ff ff       	jmp    802590 <__udivdi3+0x40>
	...

0080267c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80267c:	55                   	push   %ebp
  80267d:	89 e5                	mov    %esp,%ebp
  80267f:	57                   	push   %edi
  802680:	56                   	push   %esi
  802681:	83 ec 30             	sub    $0x30,%esp
  802684:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80268b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802692:	8b 75 08             	mov    0x8(%ebp),%esi
  802695:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802698:	8b 45 10             	mov    0x10(%ebp),%eax
  80269b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80269e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026a1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8026a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8026a6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8026a9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ac:	85 d2                	test   %edx,%edx
  8026ae:	75 1c                	jne    8026cc <__umoddi3+0x50>
    {
      if (d0 > n1)
  8026b0:	89 fa                	mov    %edi,%edx
  8026b2:	39 f8                	cmp    %edi,%eax
  8026b4:	0f 86 c2 00 00 00    	jbe    80277c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026ba:	89 f0                	mov    %esi,%eax
  8026bc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8026be:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8026c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8026c8:	eb 12                	jmp    8026dc <__umoddi3+0x60>
  8026ca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8026cf:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8026d2:	76 18                	jbe    8026ec <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8026d4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8026d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8026da:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8026df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8026e2:	83 c4 30             	add    $0x30,%esp
  8026e5:	5e                   	pop    %esi
  8026e6:	5f                   	pop    %edi
  8026e7:	c9                   	leave  
  8026e8:	c3                   	ret    
  8026e9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026ec:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8026f0:	83 f0 1f             	xor    $0x1f,%eax
  8026f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8026f6:	0f 84 ac 00 00 00    	je     8027a8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026fc:	b8 20 00 00 00       	mov    $0x20,%eax
  802701:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802704:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802707:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80270a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80270d:	d3 e2                	shl    %cl,%edx
  80270f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802712:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802715:	d3 e8                	shr    %cl,%eax
  802717:	89 d6                	mov    %edx,%esi
  802719:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80271b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80271e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802721:	d3 e0                	shl    %cl,%eax
  802723:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802726:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802729:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80272b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80272e:	d3 e0                	shl    %cl,%eax
  802730:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802733:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802736:	d3 ea                	shr    %cl,%edx
  802738:	09 d0                	or     %edx,%eax
  80273a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80273d:	d3 ea                	shr    %cl,%edx
  80273f:	f7 f6                	div    %esi
  802741:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802744:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802747:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80274a:	0f 82 8d 00 00 00    	jb     8027dd <__umoddi3+0x161>
  802750:	0f 84 91 00 00 00    	je     8027e7 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802756:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802759:	29 c7                	sub    %eax,%edi
  80275b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80275d:	89 f2                	mov    %esi,%edx
  80275f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802762:	d3 e2                	shl    %cl,%edx
  802764:	89 f8                	mov    %edi,%eax
  802766:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802769:	d3 e8                	shr    %cl,%eax
  80276b:	09 c2                	or     %eax,%edx
  80276d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  802770:	d3 ee                	shr    %cl,%esi
  802772:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  802775:	e9 62 ff ff ff       	jmp    8026dc <__umoddi3+0x60>
  80277a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80277c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80277f:	85 c0                	test   %eax,%eax
  802781:	74 15                	je     802798 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802783:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802786:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802789:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80278b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80278e:	f7 f1                	div    %ecx
  802790:	e9 29 ff ff ff       	jmp    8026be <__umoddi3+0x42>
  802795:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802798:	b8 01 00 00 00       	mov    $0x1,%eax
  80279d:	31 d2                	xor    %edx,%edx
  80279f:	f7 75 ec             	divl   -0x14(%ebp)
  8027a2:	89 c1                	mov    %eax,%ecx
  8027a4:	eb dd                	jmp    802783 <__umoddi3+0x107>
  8027a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027ab:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8027ae:	72 19                	jb     8027c9 <__umoddi3+0x14d>
  8027b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027b3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8027b6:	76 11                	jbe    8027c9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8027b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027bb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8027be:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027c1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8027c4:	e9 13 ff ff ff       	jmp    8026dc <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027cf:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8027d2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8027d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8027d8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8027db:	eb db                	jmp    8027b8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027dd:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8027e0:	19 f2                	sbb    %esi,%edx
  8027e2:	e9 6f ff ff ff       	jmp    802756 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027e7:	39 c7                	cmp    %eax,%edi
  8027e9:	72 f2                	jb     8027dd <__umoddi3+0x161>
  8027eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027ee:	e9 63 ff ff ff       	jmp    802756 <__umoddi3+0xda>
