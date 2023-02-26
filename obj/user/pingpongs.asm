
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cf 00 00 00       	call   800100 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 9e 0c 00 00       	call   800ce0 <sfork>
  800042:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 42                	je     80008b <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80004f:	e8 2b 0c 00 00       	call   800c7f <sys_getenvid>
  800054:	83 ec 04             	sub    $0x4,%esp
  800057:	56                   	push   %esi
  800058:	50                   	push   %eax
  800059:	68 20 14 80 00       	push   $0x801420
  80005e:	e8 52 01 00 00       	call   8001b5 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800063:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800066:	e8 14 0c 00 00       	call   800c7f <sys_getenvid>
  80006b:	83 c4 0c             	add    $0xc,%esp
  80006e:	56                   	push   %esi
  80006f:	50                   	push   %eax
  800070:	68 3a 14 80 00       	push   $0x80143a
  800075:	e8 3b 01 00 00       	call   8001b5 <cprintf>
		ipc_send(who, 0, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	6a 00                	push   $0x0
  800080:	ff 75 f0             	pushl  -0x10(%ebp)
  800083:	e8 35 0f 00 00       	call   800fbd <ipc_send>
  800088:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008b:	83 ec 04             	sub    $0x4,%esp
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800095:	50                   	push   %eax
  800096:	e8 77 0f 00 00       	call   801012 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009b:	a1 08 20 80 00       	mov    0x802008,%eax
  8000a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000a3:	8b 70 48             	mov    0x48(%eax),%esi
  8000a6:	8b 7d f0             	mov    -0x10(%ebp),%edi
  8000a9:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8000af:	e8 cb 0b 00 00       	call   800c7f <sys_getenvid>
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	56                   	push   %esi
  8000b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8000bb:	57                   	push   %edi
  8000bc:	53                   	push   %ebx
  8000bd:	50                   	push   %eax
  8000be:	68 50 14 80 00       	push   $0x801450
  8000c3:	e8 ed 00 00 00       	call   8001b5 <cprintf>
		if (val == 10)
  8000c8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cd:	83 c4 20             	add    $0x20,%esp
  8000d0:	83 f8 0a             	cmp    $0xa,%eax
  8000d3:	74 20                	je     8000f5 <umain+0xc1>
			return;
		++val;
  8000d5:	40                   	inc    %eax
  8000d6:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000db:	6a 00                	push   $0x0
  8000dd:	6a 00                	push   $0x0
  8000df:	6a 00                	push   $0x0
  8000e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8000e4:	e8 d4 0e 00 00       	call   800fbd <ipc_send>
		if (val == 10)
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f3:	75 96                	jne    80008b <umain+0x57>
			return;
	}

}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	8b 75 08             	mov    0x8(%ebp),%esi
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80010b:	e8 6f 0b 00 00       	call   800c7f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800110:	25 ff 03 00 00       	and    $0x3ff,%eax
  800115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011c:	c1 e0 07             	shl    $0x7,%eax
  80011f:	29 d0                	sub    %edx,%eax
  800121:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800126:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012b:	85 f6                	test   %esi,%esi
  80012d:	7e 07                	jle    800136 <libmain+0x36>
		binaryname = argv[0];
  80012f:	8b 03                	mov    (%ebx),%eax
  800131:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	53                   	push   %ebx
  80013a:	56                   	push   %esi
  80013b:	e8 f4 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800140:	e8 0b 00 00 00       	call   800150 <exit>
  800145:	83 c4 10             	add    $0x10,%esp
}
  800148:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800156:	6a 00                	push   $0x0
  800158:	e8 41 0b 00 00       	call   800c9e <sys_env_destroy>
  80015d:	83 c4 10             	add    $0x10,%esp
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    
	...

00800164 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	68 cc 01 80 00       	push   $0x8001cc
  800193:	e8 70 01 00 00       	call   800308 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	83 c4 08             	add    $0x8,%esp
  80019b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001a1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 9e 08 00 00       	call   800a4b <sys_cputs>
  8001ad:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001be:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 9a ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d6:	8b 03                	mov    (%ebx),%eax
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001df:	40                   	inc    %eax
  8001e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e7:	75 1a                	jne    800203 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 51 08 00 00       	call   800a4b <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800200:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800203:	ff 43 04             	incl   0x4(%ebx)
}
  800206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800209:	c9                   	leave  
  80020a:	c3                   	ret    
	...

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800218:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800221:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800224:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800227:	8b 55 10             	mov    0x10(%ebp),%edx
  80022a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	89 d6                	mov    %edx,%esi
  80022f:	bf 00 00 00 00       	mov    $0x0,%edi
  800234:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800237:	72 04                	jb     80023d <printnum+0x31>
  800239:	39 c2                	cmp    %eax,%edx
  80023b:	77 3f                	ja     80027c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 18             	pushl  0x18(%ebp)
  800243:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800246:	50                   	push   %eax
  800247:	52                   	push   %edx
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800250:	ff 75 e0             	pushl  -0x20(%ebp)
  800253:	e8 1c 0f 00 00       	call   801174 <__udivdi3>
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800260:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800263:	e8 a4 ff ff ff       	call   80020c <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 14                	jmp    800281 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e8             	pushl  -0x18(%ebp)
  800273:	ff 75 18             	pushl  0x18(%ebp)
  800276:	ff 55 ec             	call   *-0x14(%ebp)
  800279:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027c:	4b                   	dec    %ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f ec                	jg     80026d <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 e8             	pushl  -0x18(%ebp)
  800287:	83 ec 04             	sub    $0x4,%esp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028f:	ff 75 e0             	pushl  -0x20(%ebp)
  800292:	e8 09 10 00 00       	call   8012a0 <__umoddi3>
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	0f be 80 80 14 80 00 	movsbl 0x801480(%eax),%eax
  8002a1:	50                   	push   %eax
  8002a2:	ff 55 ec             	call   *-0x14(%ebp)
  8002a5:	83 c4 10             	add    $0x10,%esp
}
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002b5:	83 fa 01             	cmp    $0x1,%edx
  8002b8:	7e 0e                	jle    8002c8 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 42 08             	lea    0x8(%edx),%eax
  8002bf:	89 01                	mov    %eax,(%ecx)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	8b 52 04             	mov    0x4(%edx),%edx
  8002c6:	eb 22                	jmp    8002ea <getuint+0x3a>
	else if (lflag)
  8002c8:	85 d2                	test   %edx,%edx
  8002ca:	74 10                	je     8002dc <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 42 04             	lea    0x4(%edx),%eax
  8002d1:	89 01                	mov    %eax,(%ecx)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 0e                	jmp    8002ea <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 42 04             	lea    0x4(%edx),%eax
  8002e1:	89 01                	mov    %eax,(%ecx)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002f2:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8002f5:	8b 11                	mov    (%ecx),%edx
  8002f7:	3b 51 04             	cmp    0x4(%ecx),%edx
  8002fa:	73 0a                	jae    800306 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
  800301:	8d 42 01             	lea    0x1(%edx),%eax
  800304:	89 01                	mov    %eax,(%ecx)
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	57                   	push   %edi
  80030c:	56                   	push   %esi
  80030d:	53                   	push   %ebx
  80030e:	83 ec 3c             	sub    $0x3c,%esp
  800311:	8b 75 08             	mov    0x8(%ebp),%esi
  800314:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800317:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031a:	eb 1a                	jmp    800336 <vprintfmt+0x2e>
  80031c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80031f:	eb 15                	jmp    800336 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800321:	84 c0                	test   %al,%al
  800323:	0f 84 15 03 00 00    	je     80063e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	57                   	push   %edi
  80032d:	0f b6 c0             	movzbl %al,%eax
  800330:	50                   	push   %eax
  800331:	ff d6                	call   *%esi
  800333:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800336:	8a 03                	mov    (%ebx),%al
  800338:	43                   	inc    %ebx
  800339:	3c 25                	cmp    $0x25,%al
  80033b:	75 e4                	jne    800321 <vprintfmt+0x19>
  80033d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800344:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80034b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800352:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800359:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80035d:	eb 0a                	jmp    800369 <vprintfmt+0x61>
  80035f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800366:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8a 03                	mov    (%ebx),%al
  80036b:	0f b6 d0             	movzbl %al,%edx
  80036e:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800371:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800374:	83 e8 23             	sub    $0x23,%eax
  800377:	3c 55                	cmp    $0x55,%al
  800379:	0f 87 9c 02 00 00    	ja     80061b <vprintfmt+0x313>
  80037f:	0f b6 c0             	movzbl %al,%eax
  800382:	ff 24 85 c0 15 80 00 	jmp    *0x8015c0(,%eax,4)
  800389:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80038d:	eb d7                	jmp    800366 <vprintfmt+0x5e>
  80038f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800393:	eb d1                	jmp    800366 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800395:	89 d9                	mov    %ebx,%ecx
  800397:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003a1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003a4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003ab:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003af:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003b0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003b3:	83 f8 09             	cmp    $0x9,%eax
  8003b6:	77 21                	ja     8003d9 <vprintfmt+0xd1>
  8003b8:	eb e4                	jmp    80039e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ba:	8b 55 14             	mov    0x14(%ebp),%edx
  8003bd:	8d 42 04             	lea    0x4(%edx),%eax
  8003c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8003c3:	8b 12                	mov    (%edx),%edx
  8003c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003c8:	eb 12                	jmp    8003dc <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ce:	79 96                	jns    800366 <vprintfmt+0x5e>
  8003d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d7:	eb 8d                	jmp    800366 <vprintfmt+0x5e>
  8003d9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003e0:	79 84                	jns    800366 <vprintfmt+0x5e>
  8003e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003ef:	e9 72 ff ff ff       	jmp    800366 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f4:	ff 45 d4             	incl   -0x2c(%ebp)
  8003f7:	e9 6a ff ff ff       	jmp    800366 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ff:	8d 42 04             	lea    0x4(%edx),%eax
  800402:	89 45 14             	mov    %eax,0x14(%ebp)
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	57                   	push   %edi
  800409:	ff 32                	pushl  (%edx)
  80040b:	ff d6                	call   *%esi
			break;
  80040d:	83 c4 10             	add    $0x10,%esp
  800410:	e9 07 ff ff ff       	jmp    80031c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800415:	8b 55 14             	mov    0x14(%ebp),%edx
  800418:	8d 42 04             	lea    0x4(%edx),%eax
  80041b:	89 45 14             	mov    %eax,0x14(%ebp)
  80041e:	8b 02                	mov    (%edx),%eax
  800420:	85 c0                	test   %eax,%eax
  800422:	79 02                	jns    800426 <vprintfmt+0x11e>
  800424:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 0f             	cmp    $0xf,%eax
  800429:	7f 0b                	jg     800436 <vprintfmt+0x12e>
  80042b:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	75 15                	jne    80044b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800436:	50                   	push   %eax
  800437:	68 91 14 80 00       	push   $0x801491
  80043c:	57                   	push   %edi
  80043d:	56                   	push   %esi
  80043e:	e8 6e 02 00 00       	call   8006b1 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	e9 d1 fe ff ff       	jmp    80031c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	52                   	push   %edx
  80044c:	68 9a 14 80 00       	push   $0x80149a
  800451:	57                   	push   %edi
  800452:	56                   	push   %esi
  800453:	e8 59 02 00 00       	call   8006b1 <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	e9 bc fe ff ff       	jmp    80031c <vprintfmt+0x14>
  800460:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800463:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800466:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 55 14             	mov    0x14(%ebp),%edx
  80046c:	8d 42 04             	lea    0x4(%edx),%eax
  80046f:	89 45 14             	mov    %eax,0x14(%ebp)
  800472:	8b 1a                	mov    (%edx),%ebx
  800474:	85 db                	test   %ebx,%ebx
  800476:	75 05                	jne    80047d <vprintfmt+0x175>
  800478:	bb 9d 14 80 00       	mov    $0x80149d,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80047d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800481:	7e 66                	jle    8004e9 <vprintfmt+0x1e1>
  800483:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800487:	74 60                	je     8004e9 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	51                   	push   %ecx
  80048d:	53                   	push   %ebx
  80048e:	e8 57 02 00 00       	call   8006ea <strnlen>
  800493:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800496:	29 c1                	sub    %eax,%ecx
  800498:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004a5:	eb 0f                	jmp    8004b6 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	57                   	push   %edi
  8004ab:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b0:	ff 4d d8             	decl   -0x28(%ebp)
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	7f eb                	jg     8004a7 <vprintfmt+0x19f>
  8004bc:	eb 2b                	jmp    8004e9 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	74 15                	je     8004dc <vprintfmt+0x1d4>
  8004c7:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004ca:	83 f8 5e             	cmp    $0x5e,%eax
  8004cd:	76 0d                	jbe    8004dc <vprintfmt+0x1d4>
					putch('?', putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	57                   	push   %edi
  8004d3:	6a 3f                	push   $0x3f
  8004d5:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	eb 0a                	jmp    8004e6 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	57                   	push   %edi
  8004e0:	52                   	push   %edx
  8004e1:	ff d6                	call   *%esi
  8004e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e6:	ff 4d d8             	decl   -0x28(%ebp)
  8004e9:	8a 03                	mov    (%ebx),%al
  8004eb:	43                   	inc    %ebx
  8004ec:	84 c0                	test   %al,%al
  8004ee:	74 1b                	je     80050b <vprintfmt+0x203>
  8004f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f4:	78 c8                	js     8004be <vprintfmt+0x1b6>
  8004f6:	ff 4d dc             	decl   -0x24(%ebp)
  8004f9:	79 c3                	jns    8004be <vprintfmt+0x1b6>
  8004fb:	eb 0e                	jmp    80050b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	57                   	push   %edi
  800501:	6a 20                	push   $0x20
  800503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800505:	ff 4d d8             	decl   -0x28(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050f:	7f ec                	jg     8004fd <vprintfmt+0x1f5>
  800511:	e9 06 fe ff ff       	jmp    80031c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800516:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80051a:	7e 10                	jle    80052c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80051c:	8b 55 14             	mov    0x14(%ebp),%edx
  80051f:	8d 42 08             	lea    0x8(%edx),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	8b 02                	mov    (%edx),%eax
  800527:	8b 52 04             	mov    0x4(%edx),%edx
  80052a:	eb 20                	jmp    80054c <vprintfmt+0x244>
	else if (lflag)
  80052c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800530:	74 0e                	je     800540 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	99                   	cltd   
  80053e:	eb 0c                	jmp    80054c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800550:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800553:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800556:	85 c9                	test   %ecx,%ecx
  800558:	78 0a                	js     800564 <vprintfmt+0x25c>
  80055a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80055f:	e9 89 00 00 00       	jmp    8005ed <vprintfmt+0x2e5>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	57                   	push   %edi
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800572:	f7 da                	neg    %edx
  800574:	83 d1 00             	adc    $0x0,%ecx
  800577:	f7 d9                	neg    %ecx
  800579:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	eb 6a                	jmp    8005ed <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	8d 45 14             	lea    0x14(%ebp),%eax
  800586:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800589:	e8 22 fd ff ff       	call   8002b0 <getuint>
  80058e:	89 d1                	mov    %edx,%ecx
  800590:	89 c2                	mov    %eax,%edx
  800592:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800597:	eb 54                	jmp    8005ed <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80059f:	e8 0c fd ff ff       	call   8002b0 <getuint>
  8005a4:	89 d1                	mov    %edx,%ecx
  8005a6:	89 c2                	mov    %eax,%edx
  8005a8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005ad:	eb 3e                	jmp    8005ed <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	6a 30                	push   $0x30
  8005b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 78                	push   $0x78
  8005bd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005bf:	8b 55 14             	mov    0x14(%ebp),%edx
  8005c2:	8d 42 04             	lea    0x4(%edx),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c8:	8b 12                	mov    (%edx),%edx
  8005ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb 14                	jmp    8005ed <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005df:	e8 cc fc ff ff       	call   8002b0 <getuint>
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
  8005e8:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8005f4:	50                   	push   %eax
  8005f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8005f8:	53                   	push   %ebx
  8005f9:	51                   	push   %ecx
  8005fa:	52                   	push   %edx
  8005fb:	89 fa                	mov    %edi,%edx
  8005fd:	89 f0                	mov    %esi,%eax
  8005ff:	e8 08 fc ff ff       	call   80020c <printnum>
			break;
  800604:	83 c4 20             	add    $0x20,%esp
  800607:	e9 10 fd ff ff       	jmp    80031c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	57                   	push   %edi
  800610:	52                   	push   %edx
  800611:	ff d6                	call   *%esi
			break;
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	e9 01 fd ff ff       	jmp    80031c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	57                   	push   %edi
  80061f:	6a 25                	push   $0x25
  800621:	ff d6                	call   *%esi
  800623:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800626:	83 ea 02             	sub    $0x2,%edx
  800629:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062c:	8a 02                	mov    (%edx),%al
  80062e:	4a                   	dec    %edx
  80062f:	3c 25                	cmp    $0x25,%al
  800631:	75 f9                	jne    80062c <vprintfmt+0x324>
  800633:	83 c2 02             	add    $0x2,%edx
  800636:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800639:	e9 de fc ff ff       	jmp    80031c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	c9                   	leave  
  800645:	c3                   	ret    

00800646 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	83 ec 18             	sub    $0x18,%esp
  80064c:	8b 55 08             	mov    0x8(%ebp),%edx
  80064f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800652:	85 d2                	test   %edx,%edx
  800654:	74 37                	je     80068d <vsnprintf+0x47>
  800656:	85 c0                	test   %eax,%eax
  800658:	7e 33                	jle    80068d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800661:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800665:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800668:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066b:	ff 75 14             	pushl  0x14(%ebp)
  80066e:	ff 75 10             	pushl  0x10(%ebp)
  800671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800674:	50                   	push   %eax
  800675:	68 ec 02 80 00       	push   $0x8002ec
  80067a:	e8 89 fc ff ff       	call   800308 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800682:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800685:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 05                	jmp    800692 <vsnprintf+0x4c>
  80068d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800694:	55                   	push   %ebp
  800695:	89 e5                	mov    %esp,%ebp
  800697:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006a0:	50                   	push   %eax
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	ff 75 08             	pushl  0x8(%ebp)
  8006aa:	e8 97 ff ff ff       	call   800646 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006bd:	50                   	push   %eax
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	e8 3c fc ff ff       	call   800308 <vprintfmt>
	va_end(ap);
  8006cc:	83 c4 10             	add    $0x10,%esp
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    
  8006d1:	00 00                	add    %al,(%eax)
	...

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	eb 01                	jmp    8006e2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006e6:	75 f9                	jne    8006e1 <strlen+0xd>
		n++;
	return n;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 01                	jmp    8006fb <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8006fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fb:	39 d0                	cmp    %edx,%eax
  8006fd:	74 06                	je     800705 <strnlen+0x1b>
  8006ff:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800703:	75 f5                	jne    8006fa <strnlen+0x10>
		n++;
	return n;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800710:	8a 01                	mov    (%ecx),%al
  800712:	88 02                	mov    %al,(%edx)
  800714:	42                   	inc    %edx
  800715:	41                   	inc    %ecx
  800716:	84 c0                	test   %al,%al
  800718:	75 f6                	jne    800710 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800726:	53                   	push   %ebx
  800727:	e8 a8 ff ff ff       	call   8006d4 <strlen>
	strcpy(dst + len, src);
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800732:	50                   	push   %eax
  800733:	e8 cf ff ff ff       	call   800707 <strcpy>
	return dst;
}
  800738:	89 d8                	mov    %ebx,%eax
  80073a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 75 08             	mov    0x8(%ebp),%esi
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	eb 0c                	jmp    800760 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800754:	8a 02                	mov    (%edx),%al
  800756:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800759:	80 3a 01             	cmpb   $0x1,(%edx)
  80075c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075f:	41                   	inc    %ecx
  800760:	39 d9                	cmp    %ebx,%ecx
  800762:	75 f0                	jne    800754 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800764:	89 f0                	mov    %esi,%eax
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
  80076f:	8b 75 08             	mov    0x8(%ebp),%esi
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800775:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800778:	85 c9                	test   %ecx,%ecx
  80077a:	75 04                	jne    800780 <strlcpy+0x16>
  80077c:	89 f0                	mov    %esi,%eax
  80077e:	eb 14                	jmp    800794 <strlcpy+0x2a>
  800780:	89 f0                	mov    %esi,%eax
  800782:	eb 04                	jmp    800788 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800784:	88 10                	mov    %dl,(%eax)
  800786:	40                   	inc    %eax
  800787:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800788:	49                   	dec    %ecx
  800789:	74 06                	je     800791 <strlcpy+0x27>
  80078b:	8a 13                	mov    (%ebx),%dl
  80078d:	84 d2                	test   %dl,%dl
  80078f:	75 f3                	jne    800784 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800791:	c6 00 00             	movb   $0x0,(%eax)
  800794:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a3:	eb 02                	jmp    8007a7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007a5:	42                   	inc    %edx
  8007a6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a7:	8a 02                	mov    (%edx),%al
  8007a9:	84 c0                	test   %al,%al
  8007ab:	74 04                	je     8007b1 <strcmp+0x17>
  8007ad:	3a 01                	cmp    (%ecx),%al
  8007af:	74 f4                	je     8007a5 <strcmp+0xb>
  8007b1:	0f b6 c0             	movzbl %al,%eax
  8007b4:	0f b6 11             	movzbl (%ecx),%edx
  8007b7:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c8:	eb 03                	jmp    8007cd <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007ca:	4a                   	dec    %edx
  8007cb:	41                   	inc    %ecx
  8007cc:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	75 07                	jne    8007d8 <strncmp+0x1d>
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	eb 14                	jmp    8007ec <strncmp+0x31>
  8007d8:	8a 01                	mov    (%ecx),%al
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strncmp+0x27>
  8007de:	3a 03                	cmp    (%ebx),%al
  8007e0:	74 e8                	je     8007ca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 d0             	movzbl %al,%edx
  8007e5:	0f b6 03             	movzbl (%ebx),%eax
  8007e8:	29 c2                	sub    %eax,%edx
  8007ea:	89 d0                	mov    %edx,%eax
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    

008007ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8007f8:	eb 05                	jmp    8007ff <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8007fa:	38 ca                	cmp    %cl,%dl
  8007fc:	74 0c                	je     80080a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fe:	40                   	inc    %eax
  8007ff:	8a 10                	mov    (%eax),%dl
  800801:	84 d2                	test   %dl,%dl
  800803:	75 f5                	jne    8007fa <strchr+0xb>
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800815:	eb 05                	jmp    80081c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800817:	38 ca                	cmp    %cl,%dl
  800819:	74 07                	je     800822 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80081b:	40                   	inc    %eax
  80081c:	8a 10                	mov    (%eax),%dl
  80081e:	84 d2                	test   %dl,%dl
  800820:	75 f5                	jne    800817 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	57                   	push   %edi
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800830:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800833:	85 db                	test   %ebx,%ebx
  800835:	74 36                	je     80086d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800837:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80083d:	75 29                	jne    800868 <memset+0x44>
  80083f:	f6 c3 03             	test   $0x3,%bl
  800842:	75 24                	jne    800868 <memset+0x44>
		c &= 0xFF;
  800844:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800847:	89 d6                	mov    %edx,%esi
  800849:	c1 e6 08             	shl    $0x8,%esi
  80084c:	89 d0                	mov    %edx,%eax
  80084e:	c1 e0 18             	shl    $0x18,%eax
  800851:	89 d1                	mov    %edx,%ecx
  800853:	c1 e1 10             	shl    $0x10,%ecx
  800856:	09 c8                	or     %ecx,%eax
  800858:	09 c2                	or     %eax,%edx
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	09 d0                	or     %edx,%eax
  80085e:	89 d9                	mov    %ebx,%ecx
  800860:	c1 e9 02             	shr    $0x2,%ecx
  800863:	fc                   	cld    
  800864:	f3 ab                	rep stos %eax,%es:(%edi)
  800866:	eb 05                	jmp    80086d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800868:	89 d9                	mov    %ebx,%ecx
  80086a:	fc                   	cld    
  80086b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80086d:	89 f8                	mov    %edi,%eax
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5f                   	pop    %edi
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	57                   	push   %edi
  800878:	56                   	push   %esi
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80087f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800882:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800884:	39 c6                	cmp    %eax,%esi
  800886:	73 36                	jae    8008be <memmove+0x4a>
  800888:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	73 2f                	jae    8008be <memmove+0x4a>
		s += n;
		d += n;
  80088f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800892:	f6 c2 03             	test   $0x3,%dl
  800895:	75 1b                	jne    8008b2 <memmove+0x3e>
  800897:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089d:	75 13                	jne    8008b2 <memmove+0x3e>
  80089f:	f6 c1 03             	test   $0x3,%cl
  8008a2:	75 0e                	jne    8008b2 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008a4:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008aa:	c1 e9 02             	shr    $0x2,%ecx
  8008ad:	fd                   	std    
  8008ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b0:	eb 09                	jmp    8008bb <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b2:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008b5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b8:	fd                   	std    
  8008b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bb:	fc                   	cld    
  8008bc:	eb 20                	jmp    8008de <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c4:	75 15                	jne    8008db <memmove+0x67>
  8008c6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cc:	75 0d                	jne    8008db <memmove+0x67>
  8008ce:	f6 c1 03             	test   $0x3,%cl
  8008d1:	75 08                	jne    8008db <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008d3:	c1 e9 02             	shr    $0x2,%ecx
  8008d6:	fc                   	cld    
  8008d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d9:	eb 03                	jmp    8008de <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008db:	fc                   	cld    
  8008dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008de:	5e                   	pop    %esi
  8008df:	5f                   	pop    %edi
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 81 ff ff ff       	call   800874 <memmove>
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	83 ec 04             	sub    $0x4,%esp
  8008fc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800905:	eb 1b                	jmp    800922 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800907:	8a 1a                	mov    (%edx),%bl
  800909:	88 5d fb             	mov    %bl,-0x5(%ebp)
  80090c:	8a 19                	mov    (%ecx),%bl
  80090e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800911:	74 0d                	je     800920 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800913:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800917:	0f b6 c3             	movzbl %bl,%eax
  80091a:	29 c2                	sub    %eax,%edx
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	eb 0d                	jmp    80092d <memcmp+0x38>
		s1++, s2++;
  800920:	42                   	inc    %edx
  800921:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800922:	48                   	dec    %eax
  800923:	83 f8 ff             	cmp    $0xffffffff,%eax
  800926:	75 df                	jne    800907 <memcmp+0x12>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80092d:	83 c4 04             	add    $0x4,%esp
  800930:	5b                   	pop    %ebx
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80093c:	89 c2                	mov    %eax,%edx
  80093e:	03 55 10             	add    0x10(%ebp),%edx
  800941:	eb 05                	jmp    800948 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800943:	38 08                	cmp    %cl,(%eax)
  800945:	74 05                	je     80094c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800947:	40                   	inc    %eax
  800948:	39 d0                	cmp    %edx,%eax
  80094a:	72 f7                	jb     800943 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	83 ec 04             	sub    $0x4,%esp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 75 10             	mov    0x10(%ebp),%esi
  80095d:	eb 01                	jmp    800960 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80095f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800960:	8a 01                	mov    (%ecx),%al
  800962:	3c 20                	cmp    $0x20,%al
  800964:	74 f9                	je     80095f <strtol+0x11>
  800966:	3c 09                	cmp    $0x9,%al
  800968:	74 f5                	je     80095f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096a:	3c 2b                	cmp    $0x2b,%al
  80096c:	75 0a                	jne    800978 <strtol+0x2a>
		s++;
  80096e:	41                   	inc    %ecx
  80096f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800976:	eb 17                	jmp    80098f <strtol+0x41>
	else if (*s == '-')
  800978:	3c 2d                	cmp    $0x2d,%al
  80097a:	74 09                	je     800985 <strtol+0x37>
  80097c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800983:	eb 0a                	jmp    80098f <strtol+0x41>
		s++, neg = 1;
  800985:	8d 49 01             	lea    0x1(%ecx),%ecx
  800988:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098f:	85 f6                	test   %esi,%esi
  800991:	74 05                	je     800998 <strtol+0x4a>
  800993:	83 fe 10             	cmp    $0x10,%esi
  800996:	75 1a                	jne    8009b2 <strtol+0x64>
  800998:	8a 01                	mov    (%ecx),%al
  80099a:	3c 30                	cmp    $0x30,%al
  80099c:	75 10                	jne    8009ae <strtol+0x60>
  80099e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a2:	75 0a                	jne    8009ae <strtol+0x60>
		s += 2, base = 16;
  8009a4:	83 c1 02             	add    $0x2,%ecx
  8009a7:	be 10 00 00 00       	mov    $0x10,%esi
  8009ac:	eb 04                	jmp    8009b2 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009ae:	85 f6                	test   %esi,%esi
  8009b0:	74 07                	je     8009b9 <strtol+0x6b>
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b7:	eb 13                	jmp    8009cc <strtol+0x7e>
  8009b9:	3c 30                	cmp    $0x30,%al
  8009bb:	74 07                	je     8009c4 <strtol+0x76>
  8009bd:	be 0a 00 00 00       	mov    $0xa,%esi
  8009c2:	eb ee                	jmp    8009b2 <strtol+0x64>
		s++, base = 8;
  8009c4:	41                   	inc    %ecx
  8009c5:	be 08 00 00 00       	mov    $0x8,%esi
  8009ca:	eb e6                	jmp    8009b2 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cc:	8a 11                	mov    (%ecx),%dl
  8009ce:	88 d3                	mov    %dl,%bl
  8009d0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009d3:	3c 09                	cmp    $0x9,%al
  8009d5:	77 08                	ja     8009df <strtol+0x91>
			dig = *s - '0';
  8009d7:	0f be c2             	movsbl %dl,%eax
  8009da:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009dd:	eb 1c                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009df:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009e2:	3c 19                	cmp    $0x19,%al
  8009e4:	77 08                	ja     8009ee <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009e6:	0f be c2             	movsbl %dl,%eax
  8009e9:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009ec:	eb 0d                	jmp    8009fb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ee:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009f1:	3c 19                	cmp    $0x19,%al
  8009f3:	77 15                	ja     800a0a <strtol+0xbc>
			dig = *s - 'A' + 10;
  8009f5:	0f be c2             	movsbl %dl,%eax
  8009f8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8009fb:	39 f2                	cmp    %esi,%edx
  8009fd:	7d 0b                	jge    800a0a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8009ff:	41                   	inc    %ecx
  800a00:	89 f8                	mov    %edi,%eax
  800a02:	0f af c6             	imul   %esi,%eax
  800a05:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a08:	eb c2                	jmp    8009cc <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a0a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a10:	74 05                	je     800a17 <strtol+0xc9>
		*endptr = (char *) s;
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a15:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a1b:	74 04                	je     800a21 <strtol+0xd3>
  800a1d:	89 c7                	mov    %eax,%edi
  800a1f:	f7 df                	neg    %edi
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	83 c4 04             	add    $0x4,%esp
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    
	...

00800a2c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a32:	b8 01 00 00 00       	mov    $0x1,%eax
  800a37:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3c:	89 fa                	mov    %edi,%edx
  800a3e:	89 f9                	mov    %edi,%ecx
  800a40:	89 fb                	mov    %edi,%ebx
  800a42:	89 fe                	mov    %edi,%esi
  800a44:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	83 ec 04             	sub    $0x4,%esp
  800a54:	8b 55 08             	mov    0x8(%ebp),%edx
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5f:	89 f8                	mov    %edi,%eax
  800a61:	89 fb                	mov    %edi,%ebx
  800a63:	89 fe                	mov    %edi,%esi
  800a65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a67:	83 c4 04             	add    $0x4,%esp
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 0c             	sub    $0xc,%esp
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
  800a85:	89 f9                	mov    %edi,%ecx
  800a87:	89 fb                	mov    %edi,%ebx
  800a89:	89 fe                	mov    %edi,%esi
  800a8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	7e 17                	jle    800aa8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a91:	83 ec 0c             	sub    $0xc,%esp
  800a94:	50                   	push   %eax
  800a95:	6a 0d                	push   $0xd
  800a97:	68 7f 17 80 00       	push   $0x80177f
  800a9c:	6a 23                	push   $0x23
  800a9e:	68 9c 17 80 00       	push   $0x80179c
  800aa3:	e8 d4 05 00 00       	call   80107c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	c9                   	leave  
  800aaf:	c3                   	ret    

00800ab0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800abf:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ac7:	be 00 00 00 00       	mov    $0x0,%esi
  800acc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aec:	89 fb                	mov    %edi,%ebx
  800aee:	89 fe                	mov    %edi,%esi
  800af0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af2:	85 c0                	test   %eax,%eax
  800af4:	7e 17                	jle    800b0d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	50                   	push   %eax
  800afa:	6a 0a                	push   $0xa
  800afc:	68 7f 17 80 00       	push   $0x80177f
  800b01:	6a 23                	push   $0x23
  800b03:	68 9c 17 80 00       	push   $0x80179c
  800b08:	e8 6f 05 00 00       	call   80107c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    

00800b15 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b8 09 00 00 00       	mov    $0x9,%eax
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2e:	89 fb                	mov    %edi,%ebx
  800b30:	89 fe                	mov    %edi,%esi
  800b32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b34:	85 c0                	test   %eax,%eax
  800b36:	7e 17                	jle    800b4f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 09                	push   $0x9
  800b3e:	68 7f 17 80 00       	push   $0x80177f
  800b43:	6a 23                	push   $0x23
  800b45:	68 9c 17 80 00       	push   $0x80179c
  800b4a:	e8 2d 05 00 00       	call   80107c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b70:	89 fb                	mov    %edi,%ebx
  800b72:	89 fe                	mov    %edi,%esi
  800b74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7e 17                	jle    800b91 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 08                	push   $0x8
  800b80:	68 7f 17 80 00       	push   $0x80177f
  800b85:	6a 23                	push   $0x23
  800b87:	68 9c 17 80 00       	push   $0x80179c
  800b8c:	e8 eb 04 00 00       	call   80107c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb2:	89 fb                	mov    %edi,%ebx
  800bb4:	89 fe                	mov    %edi,%esi
  800bb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 17                	jle    800bd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 06                	push   $0x6
  800bc2:	68 7f 17 80 00       	push   $0x80177f
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 9c 17 80 00       	push   $0x80179c
  800bce:	e8 a9 04 00 00       	call   80107c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bed:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 05                	push   $0x5
  800c04:	68 7f 17 80 00       	push   $0x80177f
  800c09:	6a 23                	push   $0x23
  800c0b:	68 9c 17 80 00       	push   $0x80179c
  800c10:	e8 67 04 00 00       	call   80107c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c34:	bf 00 00 00 00       	mov    $0x0,%edi
  800c39:	89 fe                	mov    %edi,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 04                	push   $0x4
  800c47:	68 7f 17 80 00       	push   $0x80177f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 9c 17 80 00       	push   $0x80179c
  800c53:	e8 24 04 00 00       	call   80107c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c70:	89 fa                	mov    %edi,%edx
  800c72:	89 f9                	mov    %edi,%ecx
  800c74:	89 fb                	mov    %edi,%ebx
  800c76:	89 fe                	mov    %edi,%esi
  800c78:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c8f:	89 fa                	mov    %edi,%edx
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	89 fb                	mov    %edi,%ebx
  800c95:	89 fe                	mov    %edi,%esi
  800c97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	b8 03 00 00 00       	mov    $0x3,%eax
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb4:	89 f9                	mov    %edi,%ecx
  800cb6:	89 fb                	mov    %edi,%ebx
  800cb8:	89 fe                	mov    %edi,%esi
  800cba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbc:	85 c0                	test   %eax,%eax
  800cbe:	7e 17                	jle    800cd7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 03                	push   $0x3
  800cc6:	68 7f 17 80 00       	push   $0x80177f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 9c 17 80 00       	push   $0x80179c
  800cd2:	e8 a5 03 00 00       	call   80107c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    
	...

00800ce0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ce6:	68 aa 17 80 00       	push   $0x8017aa
  800ceb:	68 92 00 00 00       	push   $0x92
  800cf0:	68 c0 17 80 00       	push   $0x8017c0
  800cf5:	e8 82 03 00 00       	call   80107c <_panic>

00800cfa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800d03:	68 9b 0e 80 00       	push   $0x800e9b
  800d08:	e8 bf 03 00 00       	call   8010cc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800d0d:	ba 07 00 00 00       	mov    $0x7,%edx
  800d12:	89 d0                	mov    %edx,%eax
  800d14:	cd 30                	int    $0x30
  800d16:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800d18:	83 c4 10             	add    $0x10,%esp
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	75 25                	jne    800d44 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800d1f:	e8 5b ff ff ff       	call   800c7f <sys_getenvid>
  800d24:	25 ff 03 00 00       	and    $0x3ff,%eax
  800d29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d30:	c1 e0 07             	shl    $0x7,%eax
  800d33:	29 d0                	sub    %edx,%eax
  800d35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d3a:	a3 08 20 80 00       	mov    %eax,0x802008
  800d3f:	e9 4d 01 00 00       	jmp    800e91 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800d44:	85 c0                	test   %eax,%eax
  800d46:	79 12                	jns    800d5a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800d48:	50                   	push   %eax
  800d49:	68 cb 17 80 00       	push   $0x8017cb
  800d4e:	6a 77                	push   $0x77
  800d50:	68 c0 17 80 00       	push   $0x8017c0
  800d55:	e8 22 03 00 00       	call   80107c <_panic>
  800d5a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800d5f:	89 d8                	mov    %ebx,%eax
  800d61:	c1 e8 16             	shr    $0x16,%eax
  800d64:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d6b:	a8 01                	test   $0x1,%al
  800d6d:	0f 84 ab 00 00 00    	je     800e1e <fork+0x124>
  800d73:	89 da                	mov    %ebx,%edx
  800d75:	c1 ea 0c             	shr    $0xc,%edx
  800d78:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d7f:	a8 01                	test   $0x1,%al
  800d81:	0f 84 97 00 00 00    	je     800e1e <fork+0x124>
  800d87:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800d8e:	a8 04                	test   $0x4,%al
  800d90:	0f 84 88 00 00 00    	je     800e1e <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800d96:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800d9d:	89 d6                	mov    %edx,%esi
  800d9f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800da2:	89 c2                	mov    %eax,%edx
  800da4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800daa:	a9 02 08 00 00       	test   $0x802,%eax
  800daf:	74 0f                	je     800dc0 <fork+0xc6>
  800db1:	f6 c4 04             	test   $0x4,%ah
  800db4:	75 0a                	jne    800dc0 <fork+0xc6>
		perm &= ~PTE_W;
  800db6:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800dc0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800dc6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	52                   	push   %edx
  800dcd:	56                   	push   %esi
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 04 fe ff ff       	call   800bdb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800dd7:	83 c4 20             	add    $0x20,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	79 14                	jns    800df2 <fork+0xf8>
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	68 14 18 80 00       	push   $0x801814
  800de6:	6a 52                	push   $0x52
  800de8:	68 c0 17 80 00       	push   $0x8017c0
  800ded:	e8 8a 02 00 00       	call   80107c <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	56                   	push   %esi
  800df9:	6a 00                	push   $0x0
  800dfb:	56                   	push   %esi
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 d8 fd ff ff       	call   800bdb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800e03:	83 c4 20             	add    $0x20,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	79 14                	jns    800e1e <fork+0x124>
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 38 18 80 00       	push   $0x801838
  800e12:	6a 55                	push   $0x55
  800e14:	68 c0 17 80 00       	push   $0x8017c0
  800e19:	e8 5e 02 00 00       	call   80107c <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800e1e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800e24:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800e2a:	0f 85 2f ff ff ff    	jne    800d5f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	6a 07                	push   $0x7
  800e35:	68 00 f0 bf ee       	push   $0xeebff000
  800e3a:	57                   	push   %edi
  800e3b:	e8 dd fd ff ff       	call   800c1d <sys_page_alloc>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 15                	jns    800e5c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800e47:	50                   	push   %eax
  800e48:	68 e9 17 80 00       	push   $0x8017e9
  800e4d:	68 83 00 00 00       	push   $0x83
  800e52:	68 c0 17 80 00       	push   $0x8017c0
  800e57:	e8 20 02 00 00       	call   80107c <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	68 4c 11 80 00       	push   $0x80114c
  800e64:	57                   	push   %edi
  800e65:	e8 69 fc ff ff       	call   800ad3 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800e6a:	83 c4 08             	add    $0x8,%esp
  800e6d:	6a 02                	push   $0x2
  800e6f:	57                   	push   %edi
  800e70:	e8 e2 fc ff ff       	call   800b57 <sys_env_set_status>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	79 15                	jns    800e91 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  800e7c:	50                   	push   %eax
  800e7d:	68 fc 17 80 00       	push   $0x8017fc
  800e82:	68 89 00 00 00       	push   $0x89
  800e87:	68 c0 17 80 00       	push   $0x8017c0
  800e8c:	e8 eb 01 00 00       	call   80107c <_panic>
	return envid;
	//panic("fork not implemented");
}
  800e91:	89 f8                	mov    %edi,%eax
  800e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  800ea5:	8b 1a                	mov    (%edx),%ebx
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	c1 e8 0c             	shr    $0xc,%eax
  800eac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  800eb3:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800eb7:	74 05                	je     800ebe <pgfault+0x23>
  800eb9:	f6 c4 08             	test   $0x8,%ah
  800ebc:	75 14                	jne    800ed2 <pgfault+0x37>
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	68 5c 18 80 00       	push   $0x80185c
  800ec6:	6a 1e                	push   $0x1e
  800ec8:	68 c0 17 80 00       	push   $0x8017c0
  800ecd:	e8 aa 01 00 00       	call   80107c <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	6a 07                	push   $0x7
  800ed7:	68 00 f0 7f 00       	push   $0x7ff000
  800edc:	6a 00                	push   $0x0
  800ede:	e8 3a fd ff ff       	call   800c1d <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	79 14                	jns    800efe <pgfault+0x63>
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	68 88 18 80 00       	push   $0x801888
  800ef2:	6a 2a                	push   $0x2a
  800ef4:	68 c0 17 80 00       	push   $0x8017c0
  800ef9:	e8 7e 01 00 00       	call   80107c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  800efe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	68 00 10 00 00       	push   $0x1000
  800f0c:	53                   	push   %ebx
  800f0d:	68 00 f0 7f 00       	push   $0x7ff000
  800f12:	e8 5d f9 ff ff       	call   800874 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  800f17:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1e:	53                   	push   %ebx
  800f1f:	6a 00                	push   $0x0
  800f21:	68 00 f0 7f 00       	push   $0x7ff000
  800f26:	6a 00                	push   $0x0
  800f28:	e8 ae fc ff ff       	call   800bdb <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  800f2d:	83 c4 20             	add    $0x20,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	79 14                	jns    800f48 <pgfault+0xad>
  800f34:	83 ec 04             	sub    $0x4,%esp
  800f37:	68 ac 18 80 00       	push   $0x8018ac
  800f3c:	6a 2e                	push   $0x2e
  800f3e:	68 c0 17 80 00       	push   $0x8017c0
  800f43:	e8 34 01 00 00       	call   80107c <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  800f48:	83 ec 08             	sub    $0x8,%esp
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	6a 00                	push   $0x0
  800f52:	e8 42 fc ff ff       	call   800b99 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	79 14                	jns    800f72 <pgfault+0xd7>
  800f5e:	83 ec 04             	sub    $0x4,%esp
  800f61:	68 cc 18 80 00       	push   $0x8018cc
  800f66:	6a 32                	push   $0x32
  800f68:	68 c0 17 80 00       	push   $0x8017c0
  800f6d:	e8 0a 01 00 00       	call   80107c <_panic>
	//panic("pgfault not implemented");
}
  800f72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    
	...

00800f78 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	53                   	push   %ebx
  800f7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f7f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800f84:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  800f8b:	89 c8                	mov    %ecx,%eax
  800f8d:	c1 e0 07             	shl    $0x7,%eax
  800f90:	29 d0                	sub    %edx,%eax
  800f92:	89 c2                	mov    %eax,%edx
  800f94:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  800f9a:	8b 40 50             	mov    0x50(%eax),%eax
  800f9d:	39 d8                	cmp    %ebx,%eax
  800f9f:	75 0b                	jne    800fac <ipc_find_env+0x34>
			return envs[i].env_id;
  800fa1:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  800fa7:	8b 40 40             	mov    0x40(%eax),%eax
  800faa:	eb 0e                	jmp    800fba <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800fac:	41                   	inc    %ecx
  800fad:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  800fb3:	75 cf                	jne    800f84 <ipc_find_env+0xc>
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  800fba:	5b                   	pop    %ebx
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 0c             	sub    $0xc,%esp
  800fc6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  800fcf:	85 db                	test   %ebx,%ebx
  800fd1:	75 05                	jne    800fd8 <ipc_send+0x1b>
  800fd3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	57                   	push   %edi
  800fdb:	ff 75 08             	pushl  0x8(%ebp)
  800fde:	e8 cd fa ff ff       	call   800ab0 <sys_ipc_try_send>
		if (r == 0) {		//success
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	74 20                	je     80100a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  800fea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800fed:	75 07                	jne    800ff6 <ipc_send+0x39>
			sys_yield();
  800fef:	e8 6c fc ff ff       	call   800c60 <sys_yield>
  800ff4:	eb e2                	jmp    800fd8 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  800ff6:	83 ec 04             	sub    $0x4,%esp
  800ff9:	68 f0 18 80 00       	push   $0x8018f0
  800ffe:	6a 41                	push   $0x41
  801000:	68 13 19 80 00       	push   $0x801913
  801005:	e8 72 00 00 00       	call   80107c <_panic>
		}
	}
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
  801017:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80101a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101d:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801020:	85 c0                	test   %eax,%eax
  801022:	75 05                	jne    801029 <ipc_recv+0x17>
  801024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	50                   	push   %eax
  80102d:	e8 3d fa ff ff       	call   800a6f <sys_ipc_recv>
	if (r < 0) {				
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 16                	jns    80104f <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801039:	85 db                	test   %ebx,%ebx
  80103b:	74 06                	je     801043 <ipc_recv+0x31>
  80103d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801043:	85 f6                	test   %esi,%esi
  801045:	74 2c                	je     801073 <ipc_recv+0x61>
  801047:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80104d:	eb 24                	jmp    801073 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  80104f:	85 db                	test   %ebx,%ebx
  801051:	74 0a                	je     80105d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801053:	a1 08 20 80 00       	mov    0x802008,%eax
  801058:	8b 40 74             	mov    0x74(%eax),%eax
  80105b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  80105d:	85 f6                	test   %esi,%esi
  80105f:	74 0a                	je     80106b <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801061:	a1 08 20 80 00       	mov    0x802008,%eax
  801066:	8b 40 78             	mov    0x78(%eax),%eax
  801069:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80106b:	a1 08 20 80 00       	mov    0x802008,%eax
  801070:	8b 40 70             	mov    0x70(%eax),%eax
}
  801073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	c9                   	leave  
  801079:	c3                   	ret    
	...

0080107c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	53                   	push   %ebx
  801080:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  801083:	8d 45 14             	lea    0x14(%ebp),%eax
  801086:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801089:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80108f:	e8 eb fb ff ff       	call   800c7f <sys_getenvid>
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	53                   	push   %ebx
  80109e:	50                   	push   %eax
  80109f:	68 20 19 80 00       	push   $0x801920
  8010a4:	e8 0c f1 ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a9:	83 c4 18             	add    $0x18,%esp
  8010ac:	ff 75 f8             	pushl  -0x8(%ebp)
  8010af:	ff 75 10             	pushl  0x10(%ebp)
  8010b2:	e8 ad f0 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  8010b7:	c7 04 24 e7 17 80 00 	movl   $0x8017e7,(%esp)
  8010be:	e8 f2 f0 ff ff       	call   8001b5 <cprintf>
  8010c3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c6:	cc                   	int3   
  8010c7:	eb fd                	jmp    8010c6 <_panic+0x4a>
  8010c9:	00 00                	add    %al,(%eax)
	...

008010cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010d2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010d9:	75 64                	jne    80113f <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  8010db:	a1 08 20 80 00       	mov    0x802008,%eax
  8010e0:	8b 40 48             	mov    0x48(%eax),%eax
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	6a 07                	push   $0x7
  8010e8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ed:	50                   	push   %eax
  8010ee:	e8 2a fb ff ff       	call   800c1d <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	79 14                	jns    80110e <set_pgfault_handler+0x42>
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	68 44 19 80 00       	push   $0x801944
  801102:	6a 22                	push   $0x22
  801104:	68 b0 19 80 00       	push   $0x8019b0
  801109:	e8 6e ff ff ff       	call   80107c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  80110e:	a1 08 20 80 00       	mov    0x802008,%eax
  801113:	8b 40 48             	mov    0x48(%eax),%eax
  801116:	83 ec 08             	sub    $0x8,%esp
  801119:	68 4c 11 80 00       	push   $0x80114c
  80111e:	50                   	push   %eax
  80111f:	e8 af f9 ff ff       	call   800ad3 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 14                	jns    80113f <set_pgfault_handler+0x73>
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	68 74 19 80 00       	push   $0x801974
  801133:	6a 25                	push   $0x25
  801135:	68 b0 19 80 00       	push   $0x8019b0
  80113a:	e8 3d ff ff ff       	call   80107c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    
  801149:	00 00                	add    %al,(%eax)
	...

0080114c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80114c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114d:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801152:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801154:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801157:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80115b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80115e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801162:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801166:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801168:	83 c4 08             	add    $0x8,%esp
	popal
  80116b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80116c:	83 c4 04             	add    $0x4,%esp
	popfl
  80116f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801170:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801171:	c3                   	ret    
	...

00801174 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	57                   	push   %edi
  801178:	56                   	push   %esi
  801179:	83 ec 28             	sub    $0x28,%esp
  80117c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801183:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80118a:	8b 45 10             	mov    0x10(%ebp),%eax
  80118d:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801193:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801195:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801197:	8b 45 08             	mov    0x8(%ebp),%eax
  80119a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  80119d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011a3:	85 ff                	test   %edi,%edi
  8011a5:	75 21                	jne    8011c8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  8011a7:	39 d1                	cmp    %edx,%ecx
  8011a9:	76 49                	jbe    8011f4 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011ab:	f7 f1                	div    %ecx
  8011ad:	89 c1                	mov    %eax,%ecx
  8011af:	31 c0                	xor    %eax,%eax
  8011b1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011b4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8011b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011c0:	83 c4 28             	add    $0x28,%esp
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    
  8011c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011c8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8011cb:	0f 87 97 00 00 00    	ja     801268 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8011d1:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8011d4:	83 f0 1f             	xor    $0x1f,%eax
  8011d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011da:	75 34                	jne    801210 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8011dc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8011df:	72 08                	jb     8011e9 <__udivdi3+0x75>
  8011e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011e4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8011e7:	77 7f                	ja     801268 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011e9:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011ee:	31 c0                	xor    %eax,%eax
  8011f0:	eb c2                	jmp    8011b4 <__udivdi3+0x40>
  8011f2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8011f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	74 79                	je     801274 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8011fe:	89 fa                	mov    %edi,%edx
  801200:	f7 f1                	div    %ecx
  801202:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801204:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801207:	f7 f1                	div    %ecx
  801209:	89 c1                	mov    %eax,%ecx
  80120b:	89 f0                	mov    %esi,%eax
  80120d:	eb a5                	jmp    8011b4 <__udivdi3+0x40>
  80120f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801210:	b8 20 00 00 00       	mov    $0x20,%eax
  801215:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80121b:	89 fa                	mov    %edi,%edx
  80121d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801220:	d3 e2                	shl    %cl,%edx
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801228:	d3 e8                	shr    %cl,%eax
  80122a:	89 d7                	mov    %edx,%edi
  80122c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80122e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801231:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801234:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801236:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801239:	d3 e0                	shl    %cl,%eax
  80123b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80123e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801241:	d3 ea                	shr    %cl,%edx
  801243:	09 d0                	or     %edx,%eax
  801245:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801248:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80124b:	d3 ea                	shr    %cl,%edx
  80124d:	f7 f7                	div    %edi
  80124f:	89 d7                	mov    %edx,%edi
  801251:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801254:	f7 e6                	mul    %esi
  801256:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801258:	39 d7                	cmp    %edx,%edi
  80125a:	72 38                	jb     801294 <__udivdi3+0x120>
  80125c:	74 27                	je     801285 <__udivdi3+0x111>
  80125e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801261:	31 c0                	xor    %eax,%eax
  801263:	e9 4c ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801268:	31 c9                	xor    %ecx,%ecx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	e9 43 ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
  801271:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801274:	b8 01 00 00 00       	mov    $0x1,%eax
  801279:	31 d2                	xor    %edx,%edx
  80127b:	f7 75 f4             	divl   -0xc(%ebp)
  80127e:	89 c1                	mov    %eax,%ecx
  801280:	e9 76 ff ff ff       	jmp    8011fb <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801285:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801288:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80128b:	d3 e0                	shl    %cl,%eax
  80128d:	39 f0                	cmp    %esi,%eax
  80128f:	73 cd                	jae    80125e <__udivdi3+0xea>
  801291:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801294:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801297:	49                   	dec    %ecx
  801298:	31 c0                	xor    %eax,%eax
  80129a:	e9 15 ff ff ff       	jmp    8011b4 <__udivdi3+0x40>
	...

008012a0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	83 ec 30             	sub    $0x30,%esp
  8012a8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8012af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bf:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8012c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8012c5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8012c7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8012ca:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8012cd:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8012d0:	85 d2                	test   %edx,%edx
  8012d2:	75 1c                	jne    8012f0 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8012d4:	89 fa                	mov    %edi,%edx
  8012d6:	39 f8                	cmp    %edi,%eax
  8012d8:	0f 86 c2 00 00 00    	jbe    8013a0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8012e2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8012e5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012ec:	eb 12                	jmp    801300 <__umoddi3+0x60>
  8012ee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8012f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012f3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8012f6:	76 18                	jbe    801310 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8012f8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8012fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8012fe:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801300:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801303:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801306:	83 c4 30             	add    $0x30,%esp
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	c9                   	leave  
  80130c:	c3                   	ret    
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801310:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801314:	83 f0 1f             	xor    $0x1f,%eax
  801317:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80131a:	0f 84 ac 00 00 00    	je     8013cc <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801320:	b8 20 00 00 00       	mov    $0x20,%eax
  801325:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80132b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80132e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801331:	d3 e2                	shl    %cl,%edx
  801333:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801336:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801339:	d3 e8                	shr    %cl,%eax
  80133b:	89 d6                	mov    %edx,%esi
  80133d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80133f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801342:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801345:	d3 e0                	shl    %cl,%eax
  801347:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80134a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  80134d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80134f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801352:	d3 e0                	shl    %cl,%eax
  801354:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801357:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80135a:	d3 ea                	shr    %cl,%edx
  80135c:	09 d0                	or     %edx,%eax
  80135e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801361:	d3 ea                	shr    %cl,%edx
  801363:	f7 f6                	div    %esi
  801365:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801368:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80136b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80136e:	0f 82 8d 00 00 00    	jb     801401 <__umoddi3+0x161>
  801374:	0f 84 91 00 00 00    	je     80140b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80137a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80137d:	29 c7                	sub    %eax,%edi
  80137f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801381:	89 f2                	mov    %esi,%edx
  801383:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801386:	d3 e2                	shl    %cl,%edx
  801388:	89 f8                	mov    %edi,%eax
  80138a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80138d:	d3 e8                	shr    %cl,%eax
  80138f:	09 c2                	or     %eax,%edx
  801391:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801394:	d3 ee                	shr    %cl,%esi
  801396:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801399:	e9 62 ff ff ff       	jmp    801300 <__umoddi3+0x60>
  80139e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8013a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 15                	je     8013bc <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8013a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8013ad:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b2:	f7 f1                	div    %ecx
  8013b4:	e9 29 ff ff ff       	jmp    8012e2 <__umoddi3+0x42>
  8013b9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8013bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	f7 75 ec             	divl   -0x14(%ebp)
  8013c6:	89 c1                	mov    %eax,%ecx
  8013c8:	eb dd                	jmp    8013a7 <__umoddi3+0x107>
  8013ca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cf:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8013d2:	72 19                	jb     8013ed <__umoddi3+0x14d>
  8013d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8013da:	76 11                	jbe    8013ed <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013df:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8013e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8013e8:	e9 13 ff ff ff       	jmp    801300 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8013f6:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8013f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8013fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8013ff:	eb db                	jmp    8013dc <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801401:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801404:	19 f2                	sbb    %esi,%edx
  801406:	e9 6f ff ff ff       	jmp    80137a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80140b:	39 c7                	cmp    %eax,%edi
  80140d:	72 f2                	jb     801401 <__umoddi3+0x161>
  80140f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801412:	e9 63 ff ff ff       	jmp    80137a <__umoddi3+0xda>
