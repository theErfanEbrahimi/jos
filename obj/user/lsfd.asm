
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 db 00 00 00       	call   80010c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  80003a:	68 80 20 80 00       	push   $0x802080
  80003f:	e8 7d 01 00 00       	call   8001c1 <cprintf>
	exit();
  800044:	e8 13 01 00 00       	call   80015c <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void
umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80005a:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
  800060:	50                   	push   %eax
  800061:	ff 75 0c             	pushl  0xc(%ebp)
  800064:	8d 45 08             	lea    0x8(%ebp),%eax
  800067:	50                   	push   %eax
  800068:	e8 7f 0c 00 00       	call   800cec <argstart>
  80006d:	bf 00 00 00 00       	mov    $0x0,%edi
	while ((i = argnext(&args)) >= 0)
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
  80007b:	eb 11                	jmp    80008e <umain+0x40>
		if (i == '1')
  80007d:	83 f8 31             	cmp    $0x31,%eax
  800080:	75 07                	jne    800089 <umain+0x3b>
  800082:	bf 01 00 00 00       	mov    $0x1,%edi
  800087:	eb 05                	jmp    80008e <umain+0x40>
			usefprint = 1;
		else
			usage();
  800089:	e8 a6 ff ff ff       	call   800034 <usage>
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	53                   	push   %ebx
  800092:	e8 10 0d 00 00       	call   800da7 <argnext>
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 df                	jns    80007d <umain+0x2f>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000a3:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	e8 c7 0e 00 00       	call   800f7a <fstat>
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	78 44                	js     8000fe <umain+0xb0>
			if (usefprint)
  8000ba:	85 ff                	test   %edi,%edi
  8000bc:	74 22                	je     8000e0 <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000be:	83 ec 04             	sub    $0x4,%esp
  8000c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000c4:	ff 70 04             	pushl  0x4(%eax)
  8000c7:	ff 75 e8             	pushl  -0x18(%ebp)
  8000ca:	ff 75 ec             	pushl  -0x14(%ebp)
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	68 94 20 80 00       	push   $0x802094
  8000d4:	6a 01                	push   $0x1
  8000d6:	e8 4e 16 00 00       	call   801729 <fprintf>
  8000db:	83 c4 20             	add    $0x20,%esp
  8000de:	eb 1e                	jmp    8000fe <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000e6:	ff 70 04             	pushl  0x4(%eax)
  8000e9:	ff 75 e8             	pushl  -0x18(%ebp)
  8000ec:	ff 75 ec             	pushl  -0x14(%ebp)
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	68 94 20 80 00       	push   $0x802094
  8000f6:	e8 c6 00 00 00       	call   8001c1 <cprintf>
  8000fb:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fe:	43                   	inc    %ebx
  8000ff:	83 fb 20             	cmp    $0x20,%ebx
  800102:	75 a5                	jne    8000a9 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	8b 75 08             	mov    0x8(%ebp),%esi
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800117:	e8 6f 0b 00 00       	call   800c8b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80011c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800121:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800128:	c1 e0 07             	shl    $0x7,%eax
  80012b:	29 d0                	sub    %edx,%eax
  80012d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800132:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800137:	85 f6                	test   %esi,%esi
  800139:	7e 07                	jle    800142 <libmain+0x36>
		binaryname = argv[0];
  80013b:	8b 03                	mov    (%ebx),%eax
  80013d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800142:	83 ec 08             	sub    $0x8,%esp
  800145:	53                   	push   %ebx
  800146:	56                   	push   %esi
  800147:	e8 02 ff ff ff       	call   80004e <umain>

	// exit gracefully
	exit();
  80014c:	e8 0b 00 00 00       	call   80015c <exit>
  800151:	83 c4 10             	add    $0x10,%esp
}
  800154:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	c9                   	leave  
  80015a:	c3                   	ret    
	...

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800162:	6a 00                	push   $0x0
  800164:	e8 41 0b 00 00       	call   800caa <sys_env_destroy>
  800169:	83 c4 10             	add    $0x10,%esp
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
	...

00800170 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800179:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800180:	00 00 00 
	b.cnt = 0;
  800183:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80018a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018d:	ff 75 0c             	pushl  0xc(%ebp)
  800190:	ff 75 08             	pushl  0x8(%ebp)
  800193:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800199:	50                   	push   %eax
  80019a:	68 d8 01 80 00       	push   $0x8001d8
  80019f:	e8 70 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a4:	83 c4 08             	add    $0x8,%esp
  8001a7:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8001ad:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 9e 08 00 00       	call   800a57 <sys_cputs>
  8001b9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8001cd:	50                   	push   %eax
  8001ce:	ff 75 08             	pushl  0x8(%ebp)
  8001d1:	e8 9a ff ff ff       	call   800170 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e2:	8b 03                	mov    (%ebx),%eax
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001eb:	40                   	inc    %eax
  8001ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	75 1a                	jne    80020f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	68 ff 00 00 00       	push   $0xff
  8001fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800200:	50                   	push   %eax
  800201:	e8 51 08 00 00       	call   800a57 <sys_cputs>
		b->idx = 0;
  800206:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80020f:	ff 43 04             	incl   0x4(%ebx)
}
  800212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800215:	c9                   	leave  
  800216:	c3                   	ret    
	...

00800218 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 1c             	sub    $0x1c,%esp
  800221:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800224:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800230:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800233:	8b 55 10             	mov    0x10(%ebp),%edx
  800236:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800239:	89 d6                	mov    %edx,%esi
  80023b:	bf 00 00 00 00       	mov    $0x0,%edi
  800240:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800243:	72 04                	jb     800249 <printnum+0x31>
  800245:	39 c2                	cmp    %eax,%edx
  800247:	77 3f                	ja     800288 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800252:	50                   	push   %eax
  800253:	52                   	push   %edx
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025c:	ff 75 e0             	pushl  -0x20(%ebp)
  80025f:	e8 70 1b 00 00       	call   801dd4 <__udivdi3>
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	52                   	push   %edx
  800268:	50                   	push   %eax
  800269:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80026c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80026f:	e8 a4 ff ff ff       	call   800218 <printnum>
  800274:	83 c4 20             	add    $0x20,%esp
  800277:	eb 14                	jmp    80028d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	ff 75 e8             	pushl  -0x18(%ebp)
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff 55 ec             	call   *-0x14(%ebp)
  800285:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	4b                   	dec    %ebx
  800289:	85 db                	test   %ebx,%ebx
  80028b:	7f ec                	jg     800279 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 e8             	pushl  -0x18(%ebp)
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029b:	ff 75 e0             	pushl  -0x20(%ebp)
  80029e:	e8 5d 1c 00 00       	call   801f00 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 c6 20 80 00 	movsbl 0x8020c6(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff 55 ec             	call   *-0x14(%ebp)
  8002b1:	83 c4 10             	add    $0x10,%esp
}
  8002b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 42 08             	lea    0x8(%edx),%eax
  8002cb:	89 01                	mov    %eax,(%ecx)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x3a>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 42 04             	lea    0x4(%edx),%eax
  8002dd:	89 01                	mov    %eax,(%ecx)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 42 04             	lea    0x4(%edx),%eax
  8002ed:	89 01                	mov    %eax,(%ecx)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8002fe:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800301:	8b 11                	mov    (%ecx),%edx
  800303:	3b 51 04             	cmp    0x4(%ecx),%edx
  800306:	73 0a                	jae    800312 <sprintputch+0x1a>
		*b->buf++ = ch;
  800308:	8b 45 08             	mov    0x8(%ebp),%eax
  80030b:	88 02                	mov    %al,(%edx)
  80030d:	8d 42 01             	lea    0x1(%edx),%eax
  800310:	89 01                	mov    %eax,(%ecx)
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 3c             	sub    $0x3c,%esp
  80031d:	8b 75 08             	mov    0x8(%ebp),%esi
  800320:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800323:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800326:	eb 1a                	jmp    800342 <vprintfmt+0x2e>
  800328:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80032b:	eb 15                	jmp    800342 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032d:	84 c0                	test   %al,%al
  80032f:	0f 84 15 03 00 00    	je     80064a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	57                   	push   %edi
  800339:	0f b6 c0             	movzbl %al,%eax
  80033c:	50                   	push   %eax
  80033d:	ff d6                	call   *%esi
  80033f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800342:	8a 03                	mov    (%ebx),%al
  800344:	43                   	inc    %ebx
  800345:	3c 25                	cmp    $0x25,%al
  800347:	75 e4                	jne    80032d <vprintfmt+0x19>
  800349:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800350:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800357:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80035e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800365:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800369:	eb 0a                	jmp    800375 <vprintfmt+0x61>
  80036b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800372:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8a 03                	mov    (%ebx),%al
  800377:	0f b6 d0             	movzbl %al,%edx
  80037a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  80037d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800380:	83 e8 23             	sub    $0x23,%eax
  800383:	3c 55                	cmp    $0x55,%al
  800385:	0f 87 9c 02 00 00    	ja     800627 <vprintfmt+0x313>
  80038b:	0f b6 c0             	movzbl %al,%eax
  80038e:	ff 24 85 00 22 80 00 	jmp    *0x802200(,%eax,4)
  800395:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800399:	eb d7                	jmp    800372 <vprintfmt+0x5e>
  80039b:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80039f:	eb d1                	jmp    800372 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8003a1:	89 d9                	mov    %ebx,%ecx
  8003a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003aa:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003ad:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8003b0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8003b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8003b7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8003bb:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8003bc:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003bf:	83 f8 09             	cmp    $0x9,%eax
  8003c2:	77 21                	ja     8003e5 <vprintfmt+0xd1>
  8003c4:	eb e4                	jmp    8003aa <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c6:	8b 55 14             	mov    0x14(%ebp),%edx
  8003c9:	8d 42 04             	lea    0x4(%edx),%eax
  8003cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8003cf:	8b 12                	mov    (%edx),%edx
  8003d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8003d4:	eb 12                	jmp    8003e8 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8003d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003da:	79 96                	jns    800372 <vprintfmt+0x5e>
  8003dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e3:	eb 8d                	jmp    800372 <vprintfmt+0x5e>
  8003e5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003ec:	79 84                	jns    800372 <vprintfmt+0x5e>
  8003ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f4:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003fb:	e9 72 ff ff ff       	jmp    800372 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800400:	ff 45 d4             	incl   -0x2c(%ebp)
  800403:	e9 6a ff ff ff       	jmp    800372 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 55 14             	mov    0x14(%ebp),%edx
  80040b:	8d 42 04             	lea    0x4(%edx),%eax
  80040e:	89 45 14             	mov    %eax,0x14(%ebp)
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	57                   	push   %edi
  800415:	ff 32                	pushl  (%edx)
  800417:	ff d6                	call   *%esi
			break;
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	e9 07 ff ff ff       	jmp    800328 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800421:	8b 55 14             	mov    0x14(%ebp),%edx
  800424:	8d 42 04             	lea    0x4(%edx),%eax
  800427:	89 45 14             	mov    %eax,0x14(%ebp)
  80042a:	8b 02                	mov    (%edx),%eax
  80042c:	85 c0                	test   %eax,%eax
  80042e:	79 02                	jns    800432 <vprintfmt+0x11e>
  800430:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800432:	83 f8 0f             	cmp    $0xf,%eax
  800435:	7f 0b                	jg     800442 <vprintfmt+0x12e>
  800437:	8b 14 85 60 23 80 00 	mov    0x802360(,%eax,4),%edx
  80043e:	85 d2                	test   %edx,%edx
  800440:	75 15                	jne    800457 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800442:	50                   	push   %eax
  800443:	68 d7 20 80 00       	push   $0x8020d7
  800448:	57                   	push   %edi
  800449:	56                   	push   %esi
  80044a:	e8 6e 02 00 00       	call   8006bd <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	e9 d1 fe ff ff       	jmp    800328 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800457:	52                   	push   %edx
  800458:	68 91 24 80 00       	push   $0x802491
  80045d:	57                   	push   %edi
  80045e:	56                   	push   %esi
  80045f:	e8 59 02 00 00       	call   8006bd <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	e9 bc fe ff ff       	jmp    800328 <vprintfmt+0x14>
  80046c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80046f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800472:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 55 14             	mov    0x14(%ebp),%edx
  800478:	8d 42 04             	lea    0x4(%edx),%eax
  80047b:	89 45 14             	mov    %eax,0x14(%ebp)
  80047e:	8b 1a                	mov    (%edx),%ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	75 05                	jne    800489 <vprintfmt+0x175>
  800484:	bb e0 20 80 00       	mov    $0x8020e0,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800489:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80048d:	7e 66                	jle    8004f5 <vprintfmt+0x1e1>
  80048f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800493:	74 60                	je     8004f5 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	51                   	push   %ecx
  800499:	53                   	push   %ebx
  80049a:	e8 57 02 00 00       	call   8006f6 <strnlen>
  80049f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8004a2:	29 c1                	sub    %eax,%ecx
  8004a4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8004ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004b1:	eb 0f                	jmp    8004c2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	57                   	push   %edi
  8004b7:	ff 75 c4             	pushl  -0x3c(%ebp)
  8004ba:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	ff 4d d8             	decl   -0x28(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c6:	7f eb                	jg     8004b3 <vprintfmt+0x19f>
  8004c8:	eb 2b                	jmp    8004f5 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	74 15                	je     8004e8 <vprintfmt+0x1d4>
  8004d3:	8d 42 e0             	lea    -0x20(%edx),%eax
  8004d6:	83 f8 5e             	cmp    $0x5e,%eax
  8004d9:	76 0d                	jbe    8004e8 <vprintfmt+0x1d4>
					putch('?', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	57                   	push   %edi
  8004df:	6a 3f                	push   $0x3f
  8004e1:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 0a                	jmp    8004f2 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	57                   	push   %edi
  8004ec:	52                   	push   %edx
  8004ed:	ff d6                	call   *%esi
  8004ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f2:	ff 4d d8             	decl   -0x28(%ebp)
  8004f5:	8a 03                	mov    (%ebx),%al
  8004f7:	43                   	inc    %ebx
  8004f8:	84 c0                	test   %al,%al
  8004fa:	74 1b                	je     800517 <vprintfmt+0x203>
  8004fc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800500:	78 c8                	js     8004ca <vprintfmt+0x1b6>
  800502:	ff 4d dc             	decl   -0x24(%ebp)
  800505:	79 c3                	jns    8004ca <vprintfmt+0x1b6>
  800507:	eb 0e                	jmp    800517 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	57                   	push   %edi
  80050d:	6a 20                	push   $0x20
  80050f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800511:	ff 4d d8             	decl   -0x28(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051b:	7f ec                	jg     800509 <vprintfmt+0x1f5>
  80051d:	e9 06 fe ff ff       	jmp    800328 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800522:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800526:	7e 10                	jle    800538 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800528:	8b 55 14             	mov    0x14(%ebp),%edx
  80052b:	8d 42 08             	lea    0x8(%edx),%eax
  80052e:	89 45 14             	mov    %eax,0x14(%ebp)
  800531:	8b 02                	mov    (%edx),%eax
  800533:	8b 52 04             	mov    0x4(%edx),%edx
  800536:	eb 20                	jmp    800558 <vprintfmt+0x244>
	else if (lflag)
  800538:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053c:	74 0e                	je     80054c <vprintfmt+0x238>
		return va_arg(*ap, long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	99                   	cltd   
  80054a:	eb 0c                	jmp    800558 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800558:	89 d1                	mov    %edx,%ecx
  80055a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  80055c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	78 0a                	js     800570 <vprintfmt+0x25c>
  800566:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80056b:	e9 89 00 00 00       	jmp    8005f9 <vprintfmt+0x2e5>
				putch('-', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	57                   	push   %edi
  800574:	6a 2d                	push   $0x2d
  800576:	ff d6                	call   *%esi
				num = -(long long) num;
  800578:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80057b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057e:	f7 da                	neg    %edx
  800580:	83 d1 00             	adc    $0x0,%ecx
  800583:	f7 d9                	neg    %ecx
  800585:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	eb 6a                	jmp    8005f9 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058f:	8d 45 14             	lea    0x14(%ebp),%eax
  800592:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800595:	e8 22 fd ff ff       	call   8002bc <getuint>
  80059a:	89 d1                	mov    %edx,%ecx
  80059c:	89 c2                	mov    %eax,%edx
  80059e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8005a3:	eb 54                	jmp    8005f9 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ab:	e8 0c fd ff ff       	call   8002bc <getuint>
  8005b0:	89 d1                	mov    %edx,%ecx
  8005b2:	89 c2                	mov    %eax,%edx
  8005b4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8005b9:	eb 3e                	jmp    8005f9 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	6a 30                	push   $0x30
  8005c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 78                	push   $0x78
  8005c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8005ce:	8d 42 04             	lea    0x4(%edx),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d4:	8b 12                	mov    (%edx),%edx
  8005d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005db:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	eb 14                	jmp    8005f9 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005eb:	e8 cc fc ff ff       	call   8002bc <getuint>
  8005f0:	89 d1                	mov    %edx,%ecx
  8005f2:	89 c2                	mov    %eax,%edx
  8005f4:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800600:	50                   	push   %eax
  800601:	ff 75 d8             	pushl  -0x28(%ebp)
  800604:	53                   	push   %ebx
  800605:	51                   	push   %ecx
  800606:	52                   	push   %edx
  800607:	89 fa                	mov    %edi,%edx
  800609:	89 f0                	mov    %esi,%eax
  80060b:	e8 08 fc ff ff       	call   800218 <printnum>
			break;
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	e9 10 fd ff ff       	jmp    800328 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	57                   	push   %edi
  80061c:	52                   	push   %edx
  80061d:	ff d6                	call   *%esi
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	e9 01 fd ff ff       	jmp    800328 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 25                	push   $0x25
  80062d:	ff d6                	call   *%esi
  80062f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800632:	83 ea 02             	sub    $0x2,%edx
  800635:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800638:	8a 02                	mov    (%edx),%al
  80063a:	4a                   	dec    %edx
  80063b:	3c 25                	cmp    $0x25,%al
  80063d:	75 f9                	jne    800638 <vprintfmt+0x324>
  80063f:	83 c2 02             	add    $0x2,%edx
  800642:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800645:	e9 de fc ff ff       	jmp    800328 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	c9                   	leave  
  800651:	c3                   	ret    

00800652 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	83 ec 18             	sub    $0x18,%esp
  800658:	8b 55 08             	mov    0x8(%ebp),%edx
  80065b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80065e:	85 d2                	test   %edx,%edx
  800660:	74 37                	je     800699 <vsnprintf+0x47>
  800662:	85 c0                	test   %eax,%eax
  800664:	7e 33                	jle    800699 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800666:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80066d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800671:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800674:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800677:	ff 75 14             	pushl  0x14(%ebp)
  80067a:	ff 75 10             	pushl  0x10(%ebp)
  80067d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800680:	50                   	push   %eax
  800681:	68 f8 02 80 00       	push   $0x8002f8
  800686:	e8 89 fc ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800691:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	eb 05                	jmp    80069e <vsnprintf+0x4c>
  800699:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80069e:	c9                   	leave  
  80069f:	c3                   	ret    

008006a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8006ac:	50                   	push   %eax
  8006ad:	ff 75 10             	pushl  0x10(%ebp)
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	ff 75 08             	pushl  0x8(%ebp)
  8006b6:	e8 97 ff ff ff       	call   800652 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 10             	pushl  0x10(%ebp)
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	ff 75 08             	pushl  0x8(%ebp)
  8006d3:	e8 3c fc ff ff       	call   800314 <vprintfmt>
	va_end(ap);
  8006d8:	83 c4 10             	add    $0x10,%esp
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    
  8006dd:	00 00                	add    %al,(%eax)
	...

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 01                	jmp    8006ee <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8006ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8006f2:	75 f9                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 01                	jmp    800707 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800706:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	39 d0                	cmp    %edx,%eax
  800709:	74 06                	je     800711 <strnlen+0x1b>
  80070b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80070f:	75 f5                	jne    800706 <strnlen+0x10>
		n++;
	return n;
}
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800719:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	8a 01                	mov    (%ecx),%al
  80071e:	88 02                	mov    %al,(%edx)
  800720:	42                   	inc    %edx
  800721:	41                   	inc    %ecx
  800722:	84 c0                	test   %al,%al
  800724:	75 f6                	jne    80071c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800732:	53                   	push   %ebx
  800733:	e8 a8 ff ff ff       	call   8006e0 <strlen>
	strcpy(dst + len, src);
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80073e:	50                   	push   %eax
  80073f:	e8 cf ff ff ff       	call   800713 <strcpy>
	return dst;
}
  800744:	89 d8                	mov    %ebx,%eax
  800746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	56                   	push   %esi
  80074f:	53                   	push   %ebx
  800750:	8b 75 08             	mov    0x8(%ebp),%esi
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
  800756:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075e:	eb 0c                	jmp    80076c <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800760:	8a 02                	mov    (%edx),%al
  800762:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800765:	80 3a 01             	cmpb   $0x1,(%edx)
  800768:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	41                   	inc    %ecx
  80076c:	39 d9                	cmp    %ebx,%ecx
  80076e:	75 f0                	jne    800760 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800770:	89 f0                	mov    %esi,%eax
  800772:	5b                   	pop    %ebx
  800773:	5e                   	pop    %esi
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800781:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800784:	85 c9                	test   %ecx,%ecx
  800786:	75 04                	jne    80078c <strlcpy+0x16>
  800788:	89 f0                	mov    %esi,%eax
  80078a:	eb 14                	jmp    8007a0 <strlcpy+0x2a>
  80078c:	89 f0                	mov    %esi,%eax
  80078e:	eb 04                	jmp    800794 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800790:	88 10                	mov    %dl,(%eax)
  800792:	40                   	inc    %eax
  800793:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800794:	49                   	dec    %ecx
  800795:	74 06                	je     80079d <strlcpy+0x27>
  800797:	8a 13                	mov    (%ebx),%dl
  800799:	84 d2                	test   %dl,%dl
  80079b:	75 f3                	jne    800790 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  80079d:	c6 00 00             	movb   $0x0,(%eax)
  8007a0:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	eb 02                	jmp    8007b3 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8007b1:	42                   	inc    %edx
  8007b2:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	8a 02                	mov    (%edx),%al
  8007b5:	84 c0                	test   %al,%al
  8007b7:	74 04                	je     8007bd <strcmp+0x17>
  8007b9:	3a 01                	cmp    (%ecx),%al
  8007bb:	74 f4                	je     8007b1 <strcmp+0xb>
  8007bd:	0f b6 c0             	movzbl %al,%eax
  8007c0:	0f b6 11             	movzbl (%ecx),%edx
  8007c3:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d4:	eb 03                	jmp    8007d9 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8007d6:	4a                   	dec    %edx
  8007d7:	41                   	inc    %ecx
  8007d8:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	75 07                	jne    8007e4 <strncmp+0x1d>
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e2:	eb 14                	jmp    8007f8 <strncmp+0x31>
  8007e4:	8a 01                	mov    (%ecx),%al
  8007e6:	84 c0                	test   %al,%al
  8007e8:	74 04                	je     8007ee <strncmp+0x27>
  8007ea:	3a 03                	cmp    (%ebx),%al
  8007ec:	74 e8                	je     8007d6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 d0             	movzbl %al,%edx
  8007f1:	0f b6 03             	movzbl (%ebx),%eax
  8007f4:	29 c2                	sub    %eax,%edx
  8007f6:	89 d0                	mov    %edx,%eax
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800804:	eb 05                	jmp    80080b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800806:	38 ca                	cmp    %cl,%dl
  800808:	74 0c                	je     800816 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080a:	40                   	inc    %eax
  80080b:	8a 10                	mov    (%eax),%dl
  80080d:	84 d2                	test   %dl,%dl
  80080f:	75 f5                	jne    800806 <strchr+0xb>
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800821:	eb 05                	jmp    800828 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800823:	38 ca                	cmp    %cl,%dl
  800825:	74 07                	je     80082e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800827:	40                   	inc    %eax
  800828:	8a 10                	mov    (%eax),%dl
  80082a:	84 d2                	test   %dl,%dl
  80082c:	75 f5                	jne    800823 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	57                   	push   %edi
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	8b 7d 08             	mov    0x8(%ebp),%edi
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  80083f:	85 db                	test   %ebx,%ebx
  800841:	74 36                	je     800879 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800843:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800849:	75 29                	jne    800874 <memset+0x44>
  80084b:	f6 c3 03             	test   $0x3,%bl
  80084e:	75 24                	jne    800874 <memset+0x44>
		c &= 0xFF;
  800850:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800853:	89 d6                	mov    %edx,%esi
  800855:	c1 e6 08             	shl    $0x8,%esi
  800858:	89 d0                	mov    %edx,%eax
  80085a:	c1 e0 18             	shl    $0x18,%eax
  80085d:	89 d1                	mov    %edx,%ecx
  80085f:	c1 e1 10             	shl    $0x10,%ecx
  800862:	09 c8                	or     %ecx,%eax
  800864:	09 c2                	or     %eax,%edx
  800866:	89 f0                	mov    %esi,%eax
  800868:	09 d0                	or     %edx,%eax
  80086a:	89 d9                	mov    %ebx,%ecx
  80086c:	c1 e9 02             	shr    $0x2,%ecx
  80086f:	fc                   	cld    
  800870:	f3 ab                	rep stos %eax,%es:(%edi)
  800872:	eb 05                	jmp    800879 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800874:	89 d9                	mov    %ebx,%ecx
  800876:	fc                   	cld    
  800877:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800879:	89 f8                	mov    %edi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	57                   	push   %edi
  800884:	56                   	push   %esi
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80088b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80088e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800890:	39 c6                	cmp    %eax,%esi
  800892:	73 36                	jae    8008ca <memmove+0x4a>
  800894:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800897:	39 d0                	cmp    %edx,%eax
  800899:	73 2f                	jae    8008ca <memmove+0x4a>
		s += n;
		d += n;
  80089b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089e:	f6 c2 03             	test   $0x3,%dl
  8008a1:	75 1b                	jne    8008be <memmove+0x3e>
  8008a3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a9:	75 13                	jne    8008be <memmove+0x3e>
  8008ab:	f6 c1 03             	test   $0x3,%cl
  8008ae:	75 0e                	jne    8008be <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  8008b0:	8d 7e fc             	lea    -0x4(%esi),%edi
  8008b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fd                   	std    
  8008ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bc:	eb 09                	jmp    8008c7 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008be:	8d 7e ff             	lea    -0x1(%esi),%edi
  8008c1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c4:	fd                   	std    
  8008c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c7:	fc                   	cld    
  8008c8:	eb 20                	jmp    8008ea <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 15                	jne    8008e7 <memmove+0x67>
  8008d2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d8:	75 0d                	jne    8008e7 <memmove+0x67>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 08                	jne    8008e7 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	fc                   	cld    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 03                	jmp    8008ea <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e7:	fc                   	cld    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 81 ff ff ff       	call   800880 <memmove>
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	83 ec 04             	sub    $0x4,%esp
  800908:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800911:	eb 1b                	jmp    80092e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800913:	8a 1a                	mov    (%edx),%bl
  800915:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800918:	8a 19                	mov    (%ecx),%bl
  80091a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  80091d:	74 0d                	je     80092c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  80091f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800923:	0f b6 c3             	movzbl %bl,%eax
  800926:	29 c2                	sub    %eax,%edx
  800928:	89 d0                	mov    %edx,%eax
  80092a:	eb 0d                	jmp    800939 <memcmp+0x38>
		s1++, s2++;
  80092c:	42                   	inc    %edx
  80092d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	48                   	dec    %eax
  80092f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800932:	75 df                	jne    800913 <memcmp+0x12>
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800939:	83 c4 04             	add    $0x4,%esp
  80093c:	5b                   	pop    %ebx
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800948:	89 c2                	mov    %eax,%edx
  80094a:	03 55 10             	add    0x10(%ebp),%edx
  80094d:	eb 05                	jmp    800954 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094f:	38 08                	cmp    %cl,(%eax)
  800951:	74 05                	je     800958 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800953:	40                   	inc    %eax
  800954:	39 d0                	cmp    %edx,%eax
  800956:	72 f7                	jb     80094f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	83 ec 04             	sub    $0x4,%esp
  800963:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800966:	8b 75 10             	mov    0x10(%ebp),%esi
  800969:	eb 01                	jmp    80096c <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80096b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096c:	8a 01                	mov    (%ecx),%al
  80096e:	3c 20                	cmp    $0x20,%al
  800970:	74 f9                	je     80096b <strtol+0x11>
  800972:	3c 09                	cmp    $0x9,%al
  800974:	74 f5                	je     80096b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800976:	3c 2b                	cmp    $0x2b,%al
  800978:	75 0a                	jne    800984 <strtol+0x2a>
		s++;
  80097a:	41                   	inc    %ecx
  80097b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800982:	eb 17                	jmp    80099b <strtol+0x41>
	else if (*s == '-')
  800984:	3c 2d                	cmp    $0x2d,%al
  800986:	74 09                	je     800991 <strtol+0x37>
  800988:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80098f:	eb 0a                	jmp    80099b <strtol+0x41>
		s++, neg = 1;
  800991:	8d 49 01             	lea    0x1(%ecx),%ecx
  800994:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099b:	85 f6                	test   %esi,%esi
  80099d:	74 05                	je     8009a4 <strtol+0x4a>
  80099f:	83 fe 10             	cmp    $0x10,%esi
  8009a2:	75 1a                	jne    8009be <strtol+0x64>
  8009a4:	8a 01                	mov    (%ecx),%al
  8009a6:	3c 30                	cmp    $0x30,%al
  8009a8:	75 10                	jne    8009ba <strtol+0x60>
  8009aa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ae:	75 0a                	jne    8009ba <strtol+0x60>
		s += 2, base = 16;
  8009b0:	83 c1 02             	add    $0x2,%ecx
  8009b3:	be 10 00 00 00       	mov    $0x10,%esi
  8009b8:	eb 04                	jmp    8009be <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  8009ba:	85 f6                	test   %esi,%esi
  8009bc:	74 07                	je     8009c5 <strtol+0x6b>
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 13                	jmp    8009d8 <strtol+0x7e>
  8009c5:	3c 30                	cmp    $0x30,%al
  8009c7:	74 07                	je     8009d0 <strtol+0x76>
  8009c9:	be 0a 00 00 00       	mov    $0xa,%esi
  8009ce:	eb ee                	jmp    8009be <strtol+0x64>
		s++, base = 8;
  8009d0:	41                   	inc    %ecx
  8009d1:	be 08 00 00 00       	mov    $0x8,%esi
  8009d6:	eb e6                	jmp    8009be <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d8:	8a 11                	mov    (%ecx),%dl
  8009da:	88 d3                	mov    %dl,%bl
  8009dc:	8d 42 d0             	lea    -0x30(%edx),%eax
  8009df:	3c 09                	cmp    $0x9,%al
  8009e1:	77 08                	ja     8009eb <strtol+0x91>
			dig = *s - '0';
  8009e3:	0f be c2             	movsbl %dl,%eax
  8009e6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8009e9:	eb 1c                	jmp    800a07 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009eb:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8009ee:	3c 19                	cmp    $0x19,%al
  8009f0:	77 08                	ja     8009fa <strtol+0xa0>
			dig = *s - 'a' + 10;
  8009f2:	0f be c2             	movsbl %dl,%eax
  8009f5:	8d 50 a9             	lea    -0x57(%eax),%edx
  8009f8:	eb 0d                	jmp    800a07 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fa:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8009fd:	3c 19                	cmp    $0x19,%al
  8009ff:	77 15                	ja     800a16 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800a01:	0f be c2             	movsbl %dl,%eax
  800a04:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800a07:	39 f2                	cmp    %esi,%edx
  800a09:	7d 0b                	jge    800a16 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800a0b:	41                   	inc    %ecx
  800a0c:	89 f8                	mov    %edi,%eax
  800a0e:	0f af c6             	imul   %esi,%eax
  800a11:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800a14:	eb c2                	jmp    8009d8 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800a16:	89 f8                	mov    %edi,%eax

	if (endptr)
  800a18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1c:	74 05                	je     800a23 <strtol+0xc9>
		*endptr = (char *) s;
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a21:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800a23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800a27:	74 04                	je     800a2d <strtol+0xd3>
  800a29:	89 c7                	mov    %eax,%edi
  800a2b:	f7 df                	neg    %edi
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	83 c4 04             	add    $0x4,%esp
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    
	...

00800a38 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	89 fa                	mov    %edi,%edx
  800a4a:	89 f9                	mov    %edi,%ecx
  800a4c:	89 fb                	mov    %edi,%ebx
  800a4e:	89 fe                	mov    %edi,%esi
  800a50:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 04             	sub    $0x4,%esp
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	89 f8                	mov    %edi,%eax
  800a6d:	89 fb                	mov    %edi,%ebx
  800a6f:	89 fe                	mov    %edi,%esi
  800a71:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a73:	83 c4 04             	add    $0x4,%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 0c             	sub    $0xc,%esp
  800a84:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	b8 0d 00 00 00       	mov    $0xd,%eax
  800a8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a91:	89 f9                	mov    %edi,%ecx
  800a93:	89 fb                	mov    %edi,%ebx
  800a95:	89 fe                	mov    %edi,%esi
  800a97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	7e 17                	jle    800ab4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	50                   	push   %eax
  800aa1:	6a 0d                	push   $0xd
  800aa3:	68 bf 23 80 00       	push   $0x8023bf
  800aa8:	6a 23                	push   $0x23
  800aaa:	68 dc 23 80 00       	push   $0x8023dc
  800aaf:	e8 8c 11 00 00       	call   801c40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800acb:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ad3:	be 00 00 00 00       	mov    $0x0,%esi
  800ad8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
  800af8:	89 fb                	mov    %edi,%ebx
  800afa:	89 fe                	mov    %edi,%esi
  800afc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800afe:	85 c0                	test   %eax,%eax
  800b00:	7e 17                	jle    800b19 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	50                   	push   %eax
  800b06:	6a 0a                	push   $0xa
  800b08:	68 bf 23 80 00       	push   $0x8023bf
  800b0d:	6a 23                	push   $0x23
  800b0f:	68 dc 23 80 00       	push   $0x8023dc
  800b14:	e8 27 11 00 00       	call   801c40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	b8 09 00 00 00       	mov    $0x9,%eax
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3a:	89 fb                	mov    %edi,%ebx
  800b3c:	89 fe                	mov    %edi,%esi
  800b3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b40:	85 c0                	test   %eax,%eax
  800b42:	7e 17                	jle    800b5b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b44:	83 ec 0c             	sub    $0xc,%esp
  800b47:	50                   	push   %eax
  800b48:	6a 09                	push   $0x9
  800b4a:	68 bf 23 80 00       	push   $0x8023bf
  800b4f:	6a 23                	push   $0x23
  800b51:	68 dc 23 80 00       	push   $0x8023dc
  800b56:	e8 e5 10 00 00       	call   801c40 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800b5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b8 08 00 00 00       	mov    $0x8,%eax
  800b77:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7c:	89 fb                	mov    %edi,%ebx
  800b7e:	89 fe                	mov    %edi,%esi
  800b80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 08                	push   $0x8
  800b8c:	68 bf 23 80 00       	push   $0x8023bf
  800b91:	6a 23                	push   $0x23
  800b93:	68 dc 23 80 00       	push   $0x8023dc
  800b98:	e8 a3 10 00 00       	call   801c40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbe:	89 fb                	mov    %edi,%ebx
  800bc0:	89 fe                	mov    %edi,%esi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 06                	push   $0x6
  800bce:	68 bf 23 80 00       	push   $0x8023bf
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 dc 23 80 00       	push   $0x8023dc
  800bda:	e8 61 10 00 00       	call   801c40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfc:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	b8 05 00 00 00       	mov    $0x5,%eax
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 05                	push   $0x5
  800c10:	68 bf 23 80 00       	push   $0x8023bf
  800c15:	6a 23                	push   $0x23
  800c17:	68 dc 23 80 00       	push   $0x8023dc
  800c1c:	e8 1f 10 00 00       	call   801c40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
  800c45:	89 fe                	mov    %edi,%esi
  800c47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7e 17                	jle    800c64 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 04                	push   $0x4
  800c53:	68 bf 23 80 00       	push   $0x8023bf
  800c58:	6a 23                	push   $0x23
  800c5a:	68 dc 23 80 00       	push   $0x8023dc
  800c5f:	e8 dc 0f 00 00       	call   801c40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c77:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7c:	89 fa                	mov    %edi,%edx
  800c7e:	89 f9                	mov    %edi,%ecx
  800c80:	89 fb                	mov    %edi,%ebx
  800c82:	89 fe                	mov    %edi,%esi
  800c84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	b8 02 00 00 00       	mov    $0x2,%eax
  800c96:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9b:	89 fa                	mov    %edi,%edx
  800c9d:	89 f9                	mov    %edi,%ecx
  800c9f:	89 fb                	mov    %edi,%ebx
  800ca1:	89 fe                	mov    %edi,%esi
  800ca3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc0:	89 f9                	mov    %edi,%ecx
  800cc2:	89 fb                	mov    %edi,%ebx
  800cc4:	89 fe                	mov    %edi,%esi
  800cc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 17                	jle    800ce3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 03                	push   $0x3
  800cd2:	68 bf 23 80 00       	push   $0x8023bf
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 dc 23 80 00       	push   $0x8023dc
  800cde:	e8 5d 0f 00 00       	call   801c40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    
	...

00800cec <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	8b 55 10             	mov    0x10(%ebp),%edx
	args->argc = argc;
  800cf8:	89 02                	mov    %eax,(%edx)
	args->argv = (const char **) argv;
  800cfa:	89 4a 04             	mov    %ecx,0x4(%edx)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800cfd:	83 38 01             	cmpl   $0x1,(%eax)
  800d00:	7e 0b                	jle    800d0d <argstart+0x21>
  800d02:	85 c9                	test   %ecx,%ecx
  800d04:	74 07                	je     800d0d <argstart+0x21>
  800d06:	b8 91 20 80 00       	mov    $0x802091,%eax
  800d0b:	eb 05                	jmp    800d12 <argstart+0x26>
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	89 42 08             	mov    %eax,0x8(%edx)
	args->argvalue = 0;
  800d15:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	53                   	push   %ebx
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800d28:	8b 43 08             	mov    0x8(%ebx),%eax
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	74 55                	je     800d84 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  800d2f:	80 38 00             	cmpb   $0x0,(%eax)
  800d32:	74 0c                	je     800d40 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800d34:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800d37:	c7 43 08 91 20 80 00 	movl   $0x802091,0x8(%ebx)
  800d3e:	eb 41                	jmp    800d81 <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  800d40:	8b 0b                	mov    (%ebx),%ecx
  800d42:	83 39 01             	cmpl   $0x1,(%ecx)
  800d45:	7e 2c                	jle    800d73 <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  800d47:	8b 53 04             	mov    0x4(%ebx),%edx
  800d4a:	8b 42 04             	mov    0x4(%edx),%eax
  800d4d:	89 43 0c             	mov    %eax,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	8b 01                	mov    (%ecx),%eax
  800d55:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800d5c:	50                   	push   %eax
  800d5d:	8d 42 08             	lea    0x8(%edx),%eax
  800d60:	50                   	push   %eax
  800d61:	83 c2 04             	add    $0x4,%edx
  800d64:	52                   	push   %edx
  800d65:	e8 16 fb ff ff       	call   800880 <memmove>
		(*args->argc)--;
  800d6a:	8b 03                	mov    (%ebx),%eax
  800d6c:	ff 08                	decl   (%eax)
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	eb 0e                	jmp    800d81 <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  800d73:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800d7a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800d81:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800d92:	8b 42 0c             	mov    0xc(%edx),%eax
  800d95:	85 c0                	test   %eax,%eax
  800d97:	75 0c                	jne    800da5 <argvalue+0x1c>
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	52                   	push   %edx
  800d9d:	e8 7c ff ff ff       	call   800d1e <argnextvalue>
  800da2:	83 c4 10             	add    $0x10,%esp
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <argnext>:
	args->argvalue = 0;
}

int
argnext(struct Argstate *args)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800daf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800db6:	8b 43 08             	mov    0x8(%ebx),%eax
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	75 07                	jne    800dc4 <argnext+0x1d>
  800dbd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800dc2:	eb 6a                	jmp    800e2e <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800dc4:	80 38 00             	cmpb   $0x0,(%eax)
  800dc7:	75 4d                	jne    800e16 <argnext+0x6f>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800dc9:	8b 03                	mov    (%ebx),%eax
  800dcb:	83 38 01             	cmpl   $0x1,(%eax)
  800dce:	74 52                	je     800e22 <argnext+0x7b>
  800dd0:	8b 4b 04             	mov    0x4(%ebx),%ecx
  800dd3:	8b 51 04             	mov    0x4(%ecx),%edx
  800dd6:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800dd9:	75 47                	jne    800e22 <argnext+0x7b>
  800ddb:	8d 72 01             	lea    0x1(%edx),%esi
  800dde:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  800de2:	74 3e                	je     800e22 <argnext+0x7b>
		    || args->argv[1][0] != '-'
		    || args->argv[1][1] == '\0')
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800de4:	89 73 08             	mov    %esi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	8b 00                	mov    (%eax),%eax
  800dec:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800df3:	50                   	push   %eax
  800df4:	8d 41 08             	lea    0x8(%ecx),%eax
  800df7:	50                   	push   %eax
  800df8:	8d 41 04             	lea    0x4(%ecx),%eax
  800dfb:	50                   	push   %eax
  800dfc:	e8 7f fa ff ff       	call   800880 <memmove>
		(*args->argc)--;
  800e01:	8b 03                	mov    (%ebx),%eax
  800e03:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e05:	8b 43 08             	mov    0x8(%ebx),%eax
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e0e:	75 06                	jne    800e16 <argnext+0x6f>
  800e10:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e14:	74 0c                	je     800e22 <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e16:	8b 43 08             	mov    0x8(%ebx),%eax
  800e19:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  800e1c:	40                   	inc    %eax
  800e1d:	89 43 08             	mov    %eax,0x8(%ebx)
  800e20:	eb 0c                	jmp    800e2e <argnext+0x87>
	return arg;

    endofargs:
	args->curarg = 0;
  800e22:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800e29:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	return -1;
}
  800e2e:	89 d0                	mov    %edx,%eax
  800e30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    
	...

00800e38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	05 00 00 00 30       	add    $0x30000000,%eax
  800e43:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800e46:	c9                   	leave  
  800e47:	c3                   	ret    

00800e48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e4b:	ff 75 08             	pushl  0x8(%ebp)
  800e4e:	e8 e5 ff ff ff       	call   800e38 <fd2num>
  800e53:	83 c4 04             	add    $0x4,%esp
  800e56:	c1 e0 0c             	shl    $0xc,%eax
  800e59:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e5e:	c9                   	leave  
  800e5f:	c3                   	ret    

00800e60 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	53                   	push   %ebx
  800e64:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e67:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800e6c:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e6e:	89 d0                	mov    %edx,%eax
  800e70:	c1 e8 16             	shr    $0x16,%eax
  800e73:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7a:	a8 01                	test   $0x1,%al
  800e7c:	74 10                	je     800e8e <fd_alloc+0x2e>
  800e7e:	89 d0                	mov    %edx,%eax
  800e80:	c1 e8 0c             	shr    $0xc,%eax
  800e83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8a:	a8 01                	test   $0x1,%al
  800e8c:	75 09                	jne    800e97 <fd_alloc+0x37>
			*fd_store = fd;
  800e8e:	89 0b                	mov    %ecx,(%ebx)
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	eb 19                	jmp    800eb0 <fd_alloc+0x50>
			return 0;
  800e97:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e9d:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  800ea3:	75 c7                	jne    800e6c <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800eab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800eb9:	83 f8 1f             	cmp    $0x1f,%eax
  800ebc:	77 35                	ja     800ef3 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ebe:	c1 e0 0c             	shl    $0xc,%eax
  800ec1:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ec7:	89 d0                	mov    %edx,%eax
  800ec9:	c1 e8 16             	shr    $0x16,%eax
  800ecc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed3:	a8 01                	test   $0x1,%al
  800ed5:	74 1c                	je     800ef3 <fd_lookup+0x40>
  800ed7:	89 d0                	mov    %edx,%eax
  800ed9:	c1 e8 0c             	shr    $0xc,%eax
  800edc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee3:	a8 01                	test   $0x1,%al
  800ee5:	74 0c                	je     800ef3 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	89 10                	mov    %edx,(%eax)
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	eb 05                	jmp    800ef8 <fd_lookup+0x45>
	return 0;
  800ef3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f00:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	ff 75 08             	pushl  0x8(%ebp)
  800f07:	e8 a7 ff ff ff       	call   800eb3 <fd_lookup>
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	78 0e                	js     800f21 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800f13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f19:	89 50 04             	mov    %edx,0x4(%eax)
  800f1c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	53                   	push   %ebx
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f30:	ba 00 00 00 00       	mov    $0x0,%edx
  800f35:	eb 0e                	jmp    800f45 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f37:	3b 08                	cmp    (%eax),%ecx
  800f39:	75 09                	jne    800f44 <dev_lookup+0x21>
			*dev = devtab[i];
  800f3b:	89 03                	mov    %eax,(%ebx)
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb 31                	jmp    800f75 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f44:	42                   	inc    %edx
  800f45:	8b 04 95 68 24 80 00 	mov    0x802468(,%edx,4),%eax
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	75 e7                	jne    800f37 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f50:	a1 04 40 80 00       	mov    0x804004,%eax
  800f55:	8b 40 48             	mov    0x48(%eax),%eax
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	51                   	push   %ecx
  800f5c:	50                   	push   %eax
  800f5d:	68 ec 23 80 00       	push   $0x8023ec
  800f62:	e8 5a f2 ff ff       	call   8001c1 <cprintf>
	*dev = 0;
  800f67:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800f6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f72:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  800f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 14             	sub    $0x14,%esp
  800f81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 23 ff ff ff       	call   800eb3 <fd_lookup>
  800f90:	83 c4 08             	add    $0x8,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 55                	js     800fec <fstat+0x72>
  800f97:	83 ec 08             	sub    $0x8,%esp
  800f9a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  800f9d:	50                   	push   %eax
  800f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa1:	ff 30                	pushl  (%eax)
  800fa3:	e8 7b ff ff ff       	call   800f23 <dev_lookup>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	78 3d                	js     800fec <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800faf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fb2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800fb6:	75 07                	jne    800fbf <fstat+0x45>
  800fb8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800fbd:	eb 2d                	jmp    800fec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800fbf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800fc2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800fc9:	00 00 00 
	stat->st_isdir = 0;
  800fcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fd3:	00 00 00 
	stat->st_dev = dev;
  800fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800fdf:	83 ec 08             	sub    $0x8,%esp
  800fe2:	53                   	push   %ebx
  800fe3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe6:	ff 50 14             	call   *0x14(%eax)
  800fe9:	83 c4 10             	add    $0x10,%esp
}
  800fec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	53                   	push   %ebx
  800ff5:	83 ec 14             	sub    $0x14,%esp
  800ff8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	53                   	push   %ebx
  801000:	e8 ae fe ff ff       	call   800eb3 <fd_lookup>
  801005:	83 c4 08             	add    $0x8,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 5f                	js     80106b <ftruncate+0x7a>
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801012:	50                   	push   %eax
  801013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801016:	ff 30                	pushl  (%eax)
  801018:	e8 06 ff ff ff       	call   800f23 <dev_lookup>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	78 47                	js     80106b <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80102b:	75 21                	jne    80104e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80102d:	a1 04 40 80 00       	mov    0x804004,%eax
  801032:	8b 40 48             	mov    0x48(%eax),%eax
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	53                   	push   %ebx
  801039:	50                   	push   %eax
  80103a:	68 0c 24 80 00       	push   $0x80240c
  80103f:	e8 7d f1 ff ff       	call   8001c1 <cprintf>
  801044:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	eb 1d                	jmp    80106b <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80104e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801051:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801055:	75 07                	jne    80105e <ftruncate+0x6d>
  801057:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80105c:	eb 0d                	jmp    80106b <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80105e:	83 ec 08             	sub    $0x8,%esp
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	50                   	push   %eax
  801065:	ff 52 18             	call   *0x18(%edx)
  801068:	83 c4 10             	add    $0x10,%esp
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	83 ec 14             	sub    $0x14,%esp
  801077:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80107d:	50                   	push   %eax
  80107e:	53                   	push   %ebx
  80107f:	e8 2f fe ff ff       	call   800eb3 <fd_lookup>
  801084:	83 c4 08             	add    $0x8,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 62                	js     8010ed <write+0x7d>
  80108b:	83 ec 08             	sub    $0x8,%esp
  80108e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801095:	ff 30                	pushl  (%eax)
  801097:	e8 87 fe ff ff       	call   800f23 <dev_lookup>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 4a                	js     8010ed <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010aa:	75 21                	jne    8010cd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b1:	8b 40 48             	mov    0x48(%eax),%eax
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	53                   	push   %ebx
  8010b8:	50                   	push   %eax
  8010b9:	68 2d 24 80 00       	push   $0x80242d
  8010be:	e8 fe f0 ff ff       	call   8001c1 <cprintf>
  8010c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	eb 20                	jmp    8010ed <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010cd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8010d0:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8010d4:	75 07                	jne    8010dd <write+0x6d>
  8010d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010db:	eb 10                	jmp    8010ed <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	ff 75 10             	pushl  0x10(%ebp)
  8010e3:	ff 75 0c             	pushl  0xc(%ebp)
  8010e6:	50                   	push   %eax
  8010e7:	ff 52 0c             	call   *0xc(%edx)
  8010ea:	83 c4 10             	add    $0x10,%esp
}
  8010ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 14             	sub    $0x14,%esp
  8010f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	53                   	push   %ebx
  801101:	e8 ad fd ff ff       	call   800eb3 <fd_lookup>
  801106:	83 c4 08             	add    $0x8,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 67                	js     801174 <read+0x82>
  80110d:	83 ec 08             	sub    $0x8,%esp
  801110:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801117:	ff 30                	pushl  (%eax)
  801119:	e8 05 fe ff ff       	call   800f23 <dev_lookup>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 4f                	js     801174 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801125:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801128:	8b 42 08             	mov    0x8(%edx),%eax
  80112b:	83 e0 03             	and    $0x3,%eax
  80112e:	83 f8 01             	cmp    $0x1,%eax
  801131:	75 21                	jne    801154 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801133:	a1 04 40 80 00       	mov    0x804004,%eax
  801138:	8b 40 48             	mov    0x48(%eax),%eax
  80113b:	83 ec 04             	sub    $0x4,%esp
  80113e:	53                   	push   %ebx
  80113f:	50                   	push   %eax
  801140:	68 4a 24 80 00       	push   $0x80244a
  801145:	e8 77 f0 ff ff       	call   8001c1 <cprintf>
  80114a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	eb 20                	jmp    801174 <read+0x82>
	}
	if (!dev->dev_read)
  801154:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801157:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80115b:	75 07                	jne    801164 <read+0x72>
  80115d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801162:	eb 10                	jmp    801174 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	ff 75 10             	pushl  0x10(%ebp)
  80116a:	ff 75 0c             	pushl  0xc(%ebp)
  80116d:	52                   	push   %edx
  80116e:	ff 50 08             	call   *0x8(%eax)
  801171:	83 c4 10             	add    $0x10,%esp
}
  801174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801185:	8b 75 10             	mov    0x10(%ebp),%esi
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	eb 21                	jmp    8011b0 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	89 f0                	mov    %esi,%eax
  801194:	29 d0                	sub    %edx,%eax
  801196:	50                   	push   %eax
  801197:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80119a:	50                   	push   %eax
  80119b:	ff 75 08             	pushl  0x8(%ebp)
  80119e:	e8 4f ff ff ff       	call   8010f2 <read>
		if (m < 0)
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 0e                	js     8011b8 <readn+0x3f>
			return m;
		if (m == 0)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	74 08                	je     8011b6 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ae:	01 c3                	add    %eax,%ebx
  8011b0:	89 da                	mov    %ebx,%edx
  8011b2:	39 f3                	cmp    %esi,%ebx
  8011b4:	72 d9                	jb     80118f <readn+0x16>
  8011b6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 20             	sub    $0x20,%esp
  8011c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8011cb:	8a 45 0c             	mov    0xc(%ebp),%al
  8011ce:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	56                   	push   %esi
  8011d6:	e8 5d fc ff ff       	call   800e38 <fd2num>
  8011db:	89 04 24             	mov    %eax,(%esp)
  8011de:	e8 d0 fc ff ff       	call   800eb3 <fd_lookup>
  8011e3:	89 c3                	mov    %eax,%ebx
  8011e5:	83 c4 08             	add    $0x8,%esp
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 05                	js     8011f1 <fd_close+0x31>
  8011ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ef:	74 0d                	je     8011fe <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8011f1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011f5:	75 48                	jne    80123f <fd_close+0x7f>
  8011f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fc:	eb 41                	jmp    80123f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	ff 36                	pushl  (%esi)
  801207:	e8 17 fd ff ff       	call   800f23 <dev_lookup>
  80120c:	89 c3                	mov    %eax,%ebx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 1c                	js     801231 <fd_close+0x71>
		if (dev->dev_close)
  801215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801218:	8b 40 10             	mov    0x10(%eax),%eax
  80121b:	85 c0                	test   %eax,%eax
  80121d:	75 07                	jne    801226 <fd_close+0x66>
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801224:	eb 0b                	jmp    801231 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	56                   	push   %esi
  80122a:	ff d0                	call   *%eax
  80122c:	89 c3                	mov    %eax,%ebx
  80122e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	56                   	push   %esi
  801235:	6a 00                	push   $0x0
  801237:	e8 69 f9 ff ff       	call   800ba5 <sys_page_unmap>
  80123c:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80123f:	89 d8                	mov    %ebx,%eax
  801241:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 59 fc ff ff       	call   800eb3 <fd_lookup>
  80125a:	83 c4 08             	add    $0x8,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 10                	js     801271 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	6a 01                	push   $0x1
  801266:	ff 75 fc             	pushl  -0x4(%ebp)
  801269:	e8 52 ff ff ff       	call   8011c0 <fd_close>
  80126e:	83 c4 10             	add    $0x10,%esp
}
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	6a 00                	push   $0x0
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 4a 03 00 00       	call   8015cf <open>
  801285:	89 c6                	mov    %eax,%esi
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 1b                	js     8012a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	ff 75 0c             	pushl  0xc(%ebp)
  801294:	50                   	push   %eax
  801295:	e8 e0 fc ff ff       	call   800f7a <fstat>
  80129a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80129c:	89 34 24             	mov    %esi,(%esp)
  80129f:	e8 a4 ff ff ff       	call   801248 <close>
  8012a4:	89 de                	mov    %ebx,%esi
  8012a6:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8012a9:	89 f0                	mov    %esi,%eax
  8012ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    

008012b2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	57                   	push   %edi
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 1c             	sub    $0x1c,%esp
  8012bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	ff 75 08             	pushl  0x8(%ebp)
  8012c5:	e8 e9 fb ff ff       	call   800eb3 <fd_lookup>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 bd 00 00 00    	js     801394 <dup+0xe2>
		return r;
	close(newfdnum);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	57                   	push   %edi
  8012db:	e8 68 ff ff ff       	call   801248 <close>

	newfd = INDEX2FD(newfdnum);
  8012e0:	89 f8                	mov    %edi,%eax
  8012e2:	c1 e0 0c             	shl    $0xc,%eax
  8012e5:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8012eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ee:	e8 55 fb ff ff       	call   800e48 <fd2data>
  8012f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012f5:	89 34 24             	mov    %esi,(%esp)
  8012f8:	e8 4b fb ff ff       	call   800e48 <fd2data>
  8012fd:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801300:	89 d8                	mov    %ebx,%eax
  801302:	c1 e8 16             	shr    $0x16,%eax
  801305:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80130c:	83 c4 14             	add    $0x14,%esp
  80130f:	a8 01                	test   $0x1,%al
  801311:	74 36                	je     801349 <dup+0x97>
  801313:	89 da                	mov    %ebx,%edx
  801315:	c1 ea 0c             	shr    $0xc,%edx
  801318:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80131f:	a8 01                	test   $0x1,%al
  801321:	74 26                	je     801349 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801323:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80132a:	83 ec 0c             	sub    $0xc,%esp
  80132d:	25 07 0e 00 00       	and    $0xe07,%eax
  801332:	50                   	push   %eax
  801333:	ff 75 e0             	pushl  -0x20(%ebp)
  801336:	6a 00                	push   $0x0
  801338:	53                   	push   %ebx
  801339:	6a 00                	push   $0x0
  80133b:	e8 a7 f8 ff ff       	call   800be7 <sys_page_map>
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 20             	add    $0x20,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 30                	js     801379 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801349:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80134c:	89 d0                	mov    %edx,%eax
  80134e:	c1 e8 0c             	shr    $0xc,%eax
  801351:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	25 07 0e 00 00       	and    $0xe07,%eax
  801360:	50                   	push   %eax
  801361:	56                   	push   %esi
  801362:	6a 00                	push   $0x0
  801364:	52                   	push   %edx
  801365:	6a 00                	push   $0x0
  801367:	e8 7b f8 ff ff       	call   800be7 <sys_page_map>
  80136c:	89 c3                	mov    %eax,%ebx
  80136e:	83 c4 20             	add    $0x20,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 04                	js     801379 <dup+0xc7>
		goto err;
  801375:	89 fb                	mov    %edi,%ebx
  801377:	eb 1b                	jmp    801394 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	56                   	push   %esi
  80137d:	6a 00                	push   $0x0
  80137f:	e8 21 f8 ff ff       	call   800ba5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801384:	83 c4 08             	add    $0x8,%esp
  801387:	ff 75 e0             	pushl  -0x20(%ebp)
  80138a:	6a 00                	push   $0x0
  80138c:	e8 14 f8 ff ff       	call   800ba5 <sys_page_unmap>
  801391:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801394:	89 d8                	mov    %ebx,%eax
  801396:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5f                   	pop    %edi
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 95 fe ff ff       	call   801248 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	43                   	inc    %ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	83 fb 20             	cmp    $0x20,%ebx
  8013ba:	75 ee                	jne    8013aa <close_all+0xc>
		close(i);
}
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    
  8013c1:	00 00                	add    %al,(%eax)
	...

008013c4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013cd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d4:	75 12                	jne    8013e8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	6a 01                	push   $0x1
  8013db:	e8 b0 08 00 00       	call   801c90 <ipc_find_env>
  8013e0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013e5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013e8:	6a 07                	push   $0x7
  8013ea:	68 00 50 80 00       	push   $0x805000
  8013ef:	53                   	push   %ebx
  8013f0:	ff 35 00 40 80 00    	pushl  0x804000
  8013f6:	e8 da 08 00 00       	call   801cd5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013fb:	83 c4 0c             	add    $0xc,%esp
  8013fe:	6a 00                	push   $0x0
  801400:	56                   	push   %esi
  801401:	6a 00                	push   $0x0
  801403:	e8 22 09 00 00       	call   801d2a <ipc_recv>
}
  801408:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	b8 08 00 00 00       	mov    $0x8,%eax
  80141f:	e8 a0 ff ff ff       	call   8013c4 <fsipc>
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	8b 40 0c             	mov    0xc(%eax),%eax
  801432:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 02 00 00 00       	mov    $0x2,%eax
  801449:	e8 76 ff ff ff       	call   8013c4 <fsipc>
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	8b 40 0c             	mov    0xc(%eax),%eax
  80145c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801461:	ba 00 00 00 00       	mov    $0x0,%edx
  801466:	b8 06 00 00 00       	mov    $0x6,%eax
  80146b:	e8 54 ff ff ff       	call   8013c4 <fsipc>
}
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	53                   	push   %ebx
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	8b 40 0c             	mov    0xc(%eax),%eax
  801482:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801487:	ba 00 00 00 00       	mov    $0x0,%edx
  80148c:	b8 05 00 00 00       	mov    $0x5,%eax
  801491:	e8 2e ff ff ff       	call   8013c4 <fsipc>
  801496:	85 c0                	test   %eax,%eax
  801498:	78 2c                	js     8014c6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	68 00 50 80 00       	push   $0x805000
  8014a2:	53                   	push   %ebx
  8014a3:	e8 6b f2 ff ff       	call   800713 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8014be:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c3:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8014c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8014e0:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014e6:	53                   	push   %ebx
  8014e7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ea:	68 08 50 80 00       	push   $0x805008
  8014ef:	e8 8c f3 ff ff       	call   800880 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fe:	e8 c1 fe ff ff       	call   8013c4 <fsipc>
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 3d                	js     801547 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80150a:	39 c3                	cmp    %eax,%ebx
  80150c:	73 19                	jae    801527 <devfile_write+0x5c>
  80150e:	68 78 24 80 00       	push   $0x802478
  801513:	68 7f 24 80 00       	push   $0x80247f
  801518:	68 97 00 00 00       	push   $0x97
  80151d:	68 94 24 80 00       	push   $0x802494
  801522:	e8 19 07 00 00       	call   801c40 <_panic>
	assert(r <= PGSIZE);
  801527:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152c:	7e 19                	jle    801547 <devfile_write+0x7c>
  80152e:	68 9f 24 80 00       	push   $0x80249f
  801533:	68 7f 24 80 00       	push   $0x80247f
  801538:	68 98 00 00 00       	push   $0x98
  80153d:	68 94 24 80 00       	push   $0x802494
  801542:	e8 f9 06 00 00       	call   801c40 <_panic>
	
	return r;
}
  801547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	8b 40 0c             	mov    0xc(%eax),%eax
  80155a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801565:	ba 00 00 00 00       	mov    $0x0,%edx
  80156a:	b8 03 00 00 00       	mov    $0x3,%eax
  80156f:	e8 50 fe ff ff       	call   8013c4 <fsipc>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 4c                	js     8015c6 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  80157a:	39 de                	cmp    %ebx,%esi
  80157c:	73 16                	jae    801594 <devfile_read+0x48>
  80157e:	68 78 24 80 00       	push   $0x802478
  801583:	68 7f 24 80 00       	push   $0x80247f
  801588:	6a 7c                	push   $0x7c
  80158a:	68 94 24 80 00       	push   $0x802494
  80158f:	e8 ac 06 00 00       	call   801c40 <_panic>
	assert(r <= PGSIZE);
  801594:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  80159a:	7e 16                	jle    8015b2 <devfile_read+0x66>
  80159c:	68 9f 24 80 00       	push   $0x80249f
  8015a1:	68 7f 24 80 00       	push   $0x80247f
  8015a6:	6a 7d                	push   $0x7d
  8015a8:	68 94 24 80 00       	push   $0x802494
  8015ad:	e8 8e 06 00 00       	call   801c40 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	50                   	push   %eax
  8015b6:	68 00 50 80 00       	push   $0x805000
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	e8 bd f2 ff ff       	call   800880 <memmove>
  8015c3:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015c6:	89 d8                	mov    %ebx,%eax
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 1c             	sub    $0x1c,%esp
  8015d7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015da:	56                   	push   %esi
  8015db:	e8 00 f1 ff ff       	call   8006e0 <strlen>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e8:	7e 07                	jle    8015f1 <open+0x22>
  8015ea:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015ef:	eb 63                	jmp    801654 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	e8 63 f8 ff ff       	call   800e60 <fd_alloc>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 4e                	js     801654 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	56                   	push   %esi
  80160a:	68 00 50 80 00       	push   $0x805000
  80160f:	e8 ff f0 ff ff       	call   800713 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801614:	8b 45 0c             	mov    0xc(%ebp),%eax
  801617:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	b8 01 00 00 00       	mov    $0x1,%eax
  801624:	e8 9b fd ff ff       	call   8013c4 <fsipc>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	79 12                	jns    801644 <open+0x75>
		fd_close(fd, 0);
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	6a 00                	push   $0x0
  801637:	ff 75 f4             	pushl  -0xc(%ebp)
  80163a:	e8 81 fb ff ff       	call   8011c0 <fd_close>
		return r;
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 10                	jmp    801654 <open+0x85>
	}

	return fd2num(fd);
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	ff 75 f4             	pushl  -0xc(%ebp)
  80164a:	e8 e9 f7 ff ff       	call   800e38 <fd2num>
  80164f:	89 c3                	mov    %eax,%ebx
  801651:	83 c4 10             	add    $0x10,%esp
}
  801654:	89 d8                	mov    %ebx,%eax
  801656:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    
  80165d:	00 00                	add    %al,(%eax)
	...

00801660 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	53                   	push   %ebx
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801669:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80166d:	7e 2c                	jle    80169b <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	ff 70 04             	pushl  0x4(%eax)
  801675:	8d 40 10             	lea    0x10(%eax),%eax
  801678:	50                   	push   %eax
  801679:	ff 33                	pushl  (%ebx)
  80167b:	e8 f0 f9 ff ff       	call   801070 <write>
		if (result > 0)
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	7e 03                	jle    80168a <writebuf+0x2a>
			b->result += result;
  801687:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80168a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80168d:	74 0c                	je     80169b <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  80168f:	85 c0                	test   %eax,%eax
  801691:	7e 05                	jle    801698 <writebuf+0x38>
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
  801698:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80169b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	53                   	push   %ebx
  8016a4:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  8016aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ad:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  8016b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016ba:	00 00 00 
	b.result = 0;
  8016bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016c4:	00 00 00 
	b.error = 1;
  8016c7:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  8016ce:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016d1:	ff 75 10             	pushl  0x10(%ebp)
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  8016dd:	53                   	push   %ebx
  8016de:	68 43 17 80 00       	push   $0x801743
  8016e3:	e8 2c ec ff ff       	call   800314 <vprintfmt>
	if (b.idx > 0)
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  8016f2:	7e 07                	jle    8016fb <vfprintf+0x5b>
		writebuf(&b);
  8016f4:	89 d8                	mov    %ebx,%eax
  8016f6:	e8 65 ff ff ff       	call   801660 <writebuf>

	return (b.result ? b.result : b.error);
  8016fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801701:	85 c0                	test   %eax,%eax
  801703:	75 06                	jne    80170b <vfprintf+0x6b>
  801705:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  80170b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801716:	8d 45 0c             	lea    0xc(%ebp),%eax
  801719:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  80171c:	50                   	push   %eax
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	6a 01                	push   $0x1
  801722:	e8 79 ff ff ff       	call   8016a0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80172f:	8d 45 10             	lea    0x10(%ebp),%eax
  801732:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  801735:	50                   	push   %eax
  801736:	ff 75 0c             	pushl  0xc(%ebp)
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 5f ff ff ff       	call   8016a0 <vfprintf>
	va_end(ap);

	return cnt;
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	53                   	push   %ebx
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80174d:	8b 43 04             	mov    0x4(%ebx),%eax
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
  801753:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  801757:	40                   	inc    %eax
  801758:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80175b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801760:	75 0e                	jne    801770 <putch+0x2d>
		writebuf(b);
  801762:	89 d8                	mov    %ebx,%eax
  801764:	e8 f7 fe ff ff       	call   801660 <writebuf>
		b->idx = 0;
  801769:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801770:	83 c4 04             	add    $0x4,%esp
  801773:	5b                   	pop    %ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    
	...

00801778 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801780:	83 ec 0c             	sub    $0xc,%esp
  801783:	ff 75 08             	pushl  0x8(%ebp)
  801786:	e8 bd f6 ff ff       	call   800e48 <fd2data>
  80178b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80178d:	83 c4 08             	add    $0x8,%esp
  801790:	68 ab 24 80 00       	push   $0x8024ab
  801795:	53                   	push   %ebx
  801796:	e8 78 ef ff ff       	call   800713 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80179b:	8b 46 04             	mov    0x4(%esi),%eax
  80179e:	2b 06                	sub    (%esi),%eax
  8017a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ad:	00 00 00 
	stat->st_dev = &devpipe;
  8017b0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8017b7:	30 80 00 
	return 0;
}
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c2:	5b                   	pop    %ebx
  8017c3:	5e                   	pop    %esi
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017d0:	53                   	push   %ebx
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 cd f3 ff ff       	call   800ba5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d8:	89 1c 24             	mov    %ebx,(%esp)
  8017db:	e8 68 f6 ff ff       	call   800e48 <fd2data>
  8017e0:	83 c4 08             	add    $0x8,%esp
  8017e3:	50                   	push   %eax
  8017e4:	6a 00                	push   $0x0
  8017e6:	e8 ba f3 ff ff       	call   800ba5 <sys_page_unmap>
}
  8017eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	57                   	push   %edi
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8017fc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017fe:	a1 04 40 80 00       	mov    0x804004,%eax
  801803:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	ff 75 f0             	pushl  -0x10(%ebp)
  80180c:	e8 83 05 00 00       	call   801d94 <pageref>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	89 3c 24             	mov    %edi,(%esp)
  801816:	e8 79 05 00 00       	call   801d94 <pageref>
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	39 c3                	cmp    %eax,%ebx
  801820:	0f 94 c0             	sete   %al
  801823:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801826:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80182c:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  80182f:	39 c6                	cmp    %eax,%esi
  801831:	74 1b                	je     80184e <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801833:	83 f9 01             	cmp    $0x1,%ecx
  801836:	75 c6                	jne    8017fe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801838:	8b 42 58             	mov    0x58(%edx),%eax
  80183b:	6a 01                	push   $0x1
  80183d:	50                   	push   %eax
  80183e:	56                   	push   %esi
  80183f:	68 b2 24 80 00       	push   $0x8024b2
  801844:	e8 78 e9 ff ff       	call   8001c1 <cprintf>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	eb b0                	jmp    8017fe <_pipeisclosed+0xe>
	}
}
  80184e:	89 c8                	mov    %ecx,%eax
  801850:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5f                   	pop    %edi
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	57                   	push   %edi
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	83 ec 18             	sub    $0x18,%esp
  801861:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801864:	56                   	push   %esi
  801865:	e8 de f5 ff ff       	call   800e48 <fd2data>
  80186a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801872:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	eb 40                	jmp    8018bc <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
  801881:	eb 40                	jmp    8018c3 <devpipe_write+0x6b>
  801883:	89 da                	mov    %ebx,%edx
  801885:	89 f0                	mov    %esi,%eax
  801887:	e8 64 ff ff ff       	call   8017f0 <_pipeisclosed>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	75 ec                	jne    80187c <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801890:	e8 d7 f3 ff ff       	call   800c6c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801895:	8b 53 04             	mov    0x4(%ebx),%edx
  801898:	8b 03                	mov    (%ebx),%eax
  80189a:	83 c0 20             	add    $0x20,%eax
  80189d:	39 c2                	cmp    %eax,%edx
  80189f:	73 e2                	jae    801883 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018a1:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018a7:	79 05                	jns    8018ae <devpipe_write+0x56>
  8018a9:	4a                   	dec    %edx
  8018aa:	83 ca e0             	or     $0xffffffe0,%edx
  8018ad:	42                   	inc    %edx
  8018ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8018b1:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8018b4:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b8:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018bb:	47                   	inc    %edi
  8018bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018bf:	75 d4                	jne    801895 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018c1:	89 f8                	mov    %edi,%eax
}
  8018c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 18             	sub    $0x18,%esp
  8018d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018d7:	57                   	push   %edi
  8018d8:	e8 6b f5 ff ff       	call   800e48 <fd2data>
  8018dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8018df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8018e5:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	eb 41                	jmp    801930 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8018ef:	89 f0                	mov    %esi,%eax
  8018f1:	eb 44                	jmp    801937 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f8:	eb 3d                	jmp    801937 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018fa:	85 f6                	test   %esi,%esi
  8018fc:	75 f1                	jne    8018ef <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018fe:	89 da                	mov    %ebx,%edx
  801900:	89 f8                	mov    %edi,%eax
  801902:	e8 e9 fe ff ff       	call   8017f0 <_pipeisclosed>
  801907:	85 c0                	test   %eax,%eax
  801909:	75 e8                	jne    8018f3 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80190b:	e8 5c f3 ff ff       	call   800c6c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801910:	8b 03                	mov    (%ebx),%eax
  801912:	3b 43 04             	cmp    0x4(%ebx),%eax
  801915:	74 e3                	je     8018fa <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801917:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80191c:	79 05                	jns    801923 <devpipe_read+0x58>
  80191e:	48                   	dec    %eax
  80191f:	83 c8 e0             	or     $0xffffffe0,%eax
  801922:	40                   	inc    %eax
  801923:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801927:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80192a:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  80192d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192f:	46                   	inc    %esi
  801930:	3b 75 10             	cmp    0x10(%ebp),%esi
  801933:	75 db                	jne    801910 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801935:	89 f0                	mov    %esi,%eax
}
  801937:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	c9                   	leave  
  80193e:	c3                   	ret    

0080193f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801945:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 62 f5 ff ff       	call   800eb3 <fd_lookup>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	78 18                	js     801970 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 fc             	pushl  -0x4(%ebp)
  80195e:	e8 e5 f4 ff ff       	call   800e48 <fd2data>
  801963:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801965:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801968:	e8 83 fe ff ff       	call   8017f0 <_pipeisclosed>
  80196d:	83 c4 10             	add    $0x10,%esp
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 28             	sub    $0x28,%esp
  80197b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80197e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801981:	50                   	push   %eax
  801982:	e8 d9 f4 ff ff       	call   800e60 <fd_alloc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 24 01 00 00    	js     801ab8 <pipe+0x146>
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	68 07 04 00 00       	push   $0x407
  80199c:	ff 75 f0             	pushl  -0x10(%ebp)
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 83 f2 ff ff       	call   800c29 <sys_page_alloc>
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	0f 88 05 01 00 00    	js     801ab8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019b9:	50                   	push   %eax
  8019ba:	e8 a1 f4 ff ff       	call   800e60 <fd_alloc>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 dc 00 00 00    	js     801aa8 <pipe+0x136>
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	68 07 04 00 00       	push   $0x407
  8019d4:	ff 75 ec             	pushl  -0x14(%ebp)
  8019d7:	6a 00                	push   $0x0
  8019d9:	e8 4b f2 ff ff       	call   800c29 <sys_page_alloc>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	0f 88 bd 00 00 00    	js     801aa8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f1:	e8 52 f4 ff ff       	call   800e48 <fd2data>
  8019f6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f8:	83 c4 0c             	add    $0xc,%esp
  8019fb:	68 07 04 00 00       	push   $0x407
  801a00:	50                   	push   %eax
  801a01:	6a 00                	push   $0x0
  801a03:	e8 21 f2 ff ff       	call   800c29 <sys_page_alloc>
  801a08:	89 c3                	mov    %eax,%ebx
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	0f 88 83 00 00 00    	js     801a98 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	ff 75 ec             	pushl  -0x14(%ebp)
  801a1b:	e8 28 f4 ff ff       	call   800e48 <fd2data>
  801a20:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a27:	50                   	push   %eax
  801a28:	6a 00                	push   $0x0
  801a2a:	56                   	push   %esi
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 b5 f1 ff ff       	call   800be7 <sys_page_map>
  801a32:	89 c3                	mov    %eax,%ebx
  801a34:	83 c4 20             	add    $0x20,%esp
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 4f                	js     801a8a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a3b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a44:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a49:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a50:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a56:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a59:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a5e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6b:	e8 c8 f3 ff ff       	call   800e38 <fd2num>
  801a70:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a72:	83 c4 04             	add    $0x4,%esp
  801a75:	ff 75 ec             	pushl  -0x14(%ebp)
  801a78:	e8 bb f3 ff ff       	call   800e38 <fd2num>
  801a7d:	89 47 04             	mov    %eax,0x4(%edi)
  801a80:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	eb 2e                	jmp    801ab8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	56                   	push   %esi
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 10 f1 ff ff       	call   800ba5 <sys_page_unmap>
  801a95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	ff 75 ec             	pushl  -0x14(%ebp)
  801a9e:	6a 00                	push   $0x0
  801aa0:	e8 00 f1 ff ff       	call   800ba5 <sys_page_unmap>
  801aa5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	ff 75 f0             	pushl  -0x10(%ebp)
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 f0 f0 ff ff       	call   800ba5 <sys_page_unmap>
  801ab5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ab8:	89 d8                	mov    %ebx,%eax
  801aba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abd:	5b                   	pop    %ebx
  801abe:	5e                   	pop    %esi
  801abf:	5f                   	pop    %edi
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    
	...

00801ac4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ad4:	68 ca 24 80 00       	push   $0x8024ca
  801ad9:	ff 75 0c             	pushl  0xc(%ebp)
  801adc:	e8 32 ec ff ff       	call   800713 <strcpy>
	return 0;
}
  801ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	57                   	push   %edi
  801aec:	56                   	push   %esi
  801aed:	53                   	push   %ebx
  801aee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801af4:	be 00 00 00 00       	mov    $0x0,%esi
  801af9:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801aff:	eb 2c                	jmp    801b2d <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b04:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b06:	83 fb 7f             	cmp    $0x7f,%ebx
  801b09:	76 05                	jbe    801b10 <devcons_write+0x28>
  801b0b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	53                   	push   %ebx
  801b14:	03 45 0c             	add    0xc(%ebp),%eax
  801b17:	50                   	push   %eax
  801b18:	57                   	push   %edi
  801b19:	e8 62 ed ff ff       	call   800880 <memmove>
		sys_cputs(buf, m);
  801b1e:	83 c4 08             	add    $0x8,%esp
  801b21:	53                   	push   %ebx
  801b22:	57                   	push   %edi
  801b23:	e8 2f ef ff ff       	call   800a57 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b28:	01 de                	add    %ebx,%esi
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	89 f0                	mov    %esi,%eax
  801b2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b32:	72 cd                	jb     801b01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5e                   	pop    %esi
  801b39:	5f                   	pop    %edi
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b48:	6a 01                	push   $0x1
  801b4a:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 04 ef ff ff       	call   800a57 <sys_cputs>
  801b53:	83 c4 10             	add    $0x10,%esp
}
  801b56:	c9                   	leave  
  801b57:	c3                   	ret    

00801b58 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b62:	74 27                	je     801b8b <devcons_read+0x33>
  801b64:	eb 05                	jmp    801b6b <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b66:	e8 01 f1 ff ff       	call   800c6c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b6b:	e8 c8 ee ff ff       	call   800a38 <sys_cgetc>
  801b70:	89 c2                	mov    %eax,%edx
  801b72:	85 c0                	test   %eax,%eax
  801b74:	74 f0                	je     801b66 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 16                	js     801b90 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b7a:	83 f8 04             	cmp    $0x4,%eax
  801b7d:	74 0c                	je     801b8b <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b82:	88 10                	mov    %dl,(%eax)
  801b84:	ba 01 00 00 00       	mov    $0x1,%edx
  801b89:	eb 05                	jmp    801b90 <devcons_read+0x38>
	return 1;
  801b8b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b90:	89 d0                	mov    %edx,%eax
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b9a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b9d:	50                   	push   %eax
  801b9e:	e8 bd f2 ff ff       	call   800e60 <fd_alloc>
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 3b                	js     801be5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801baa:	83 ec 04             	sub    $0x4,%esp
  801bad:	68 07 04 00 00       	push   $0x407
  801bb2:	ff 75 fc             	pushl  -0x4(%ebp)
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 6d f0 ff ff       	call   800c29 <sys_page_alloc>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 22                	js     801be5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bc3:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801bc8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801bcb:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bd0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 fc             	pushl  -0x4(%ebp)
  801bdd:	e8 56 f2 ff ff       	call   800e38 <fd2num>
  801be2:	83 c4 10             	add    $0x10,%esp
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bed:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	ff 75 08             	pushl  0x8(%ebp)
  801bf4:	e8 ba f2 ff ff       	call   800eb3 <fd_lookup>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 11                	js     801c11 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c03:	8b 00                	mov    (%eax),%eax
  801c05:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801c0b:	0f 94 c0             	sete   %al
  801c0e:	0f b6 c0             	movzbl %al,%eax
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c19:	6a 01                	push   $0x1
  801c1b:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	6a 00                	push   $0x0
  801c21:	e8 cc f4 ff ff       	call   8010f2 <read>
	if (r < 0)
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 0f                	js     801c3c <getchar+0x29>
		return r;
	if (r < 1)
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	75 07                	jne    801c38 <getchar+0x25>
  801c31:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c36:	eb 04                	jmp    801c3c <getchar+0x29>
		return -E_EOF;
	return c;
  801c38:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    
	...

00801c40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	53                   	push   %ebx
  801c44:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  801c47:	8d 45 14             	lea    0x14(%ebp),%eax
  801c4a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c4d:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c53:	e8 33 f0 ff ff       	call   800c8b <sys_getenvid>
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 0c             	pushl  0xc(%ebp)
  801c5e:	ff 75 08             	pushl  0x8(%ebp)
  801c61:	53                   	push   %ebx
  801c62:	50                   	push   %eax
  801c63:	68 d8 24 80 00       	push   $0x8024d8
  801c68:	e8 54 e5 ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c6d:	83 c4 18             	add    $0x18,%esp
  801c70:	ff 75 f8             	pushl  -0x8(%ebp)
  801c73:	ff 75 10             	pushl  0x10(%ebp)
  801c76:	e8 f5 e4 ff ff       	call   800170 <vcprintf>
	cprintf("\n");
  801c7b:	c7 04 24 90 20 80 00 	movl   $0x802090,(%esp)
  801c82:	e8 3a e5 ff ff       	call   8001c1 <cprintf>
  801c87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c8a:	cc                   	int3   
  801c8b:	eb fd                	jmp    801c8a <_panic+0x4a>
  801c8d:	00 00                	add    %al,(%eax)
	...

00801c90 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	53                   	push   %ebx
  801c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c97:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c9c:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801ca3:	89 c8                	mov    %ecx,%eax
  801ca5:	c1 e0 07             	shl    $0x7,%eax
  801ca8:	29 d0                	sub    %edx,%eax
  801caa:	89 c2                	mov    %eax,%edx
  801cac:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801cb2:	8b 40 50             	mov    0x50(%eax),%eax
  801cb5:	39 d8                	cmp    %ebx,%eax
  801cb7:	75 0b                	jne    801cc4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801cb9:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801cbf:	8b 40 40             	mov    0x40(%eax),%eax
  801cc2:	eb 0e                	jmp    801cd2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc4:	41                   	inc    %ecx
  801cc5:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801ccb:	75 cf                	jne    801c9c <ipc_find_env+0xc>
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801cd2:	5b                   	pop    %ebx
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ce1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ce7:	85 db                	test   %ebx,%ebx
  801ce9:	75 05                	jne    801cf0 <ipc_send+0x1b>
  801ceb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	57                   	push   %edi
  801cf3:	ff 75 08             	pushl  0x8(%ebp)
  801cf6:	e8 c1 ed ff ff       	call   800abc <sys_ipc_try_send>
		if (r == 0) {		//success
  801cfb:	83 c4 10             	add    $0x10,%esp
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	74 20                	je     801d22 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801d02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d05:	75 07                	jne    801d0e <ipc_send+0x39>
			sys_yield();
  801d07:	e8 60 ef ff ff       	call   800c6c <sys_yield>
  801d0c:	eb e2                	jmp    801cf0 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	68 fc 24 80 00       	push   $0x8024fc
  801d16:	6a 41                	push   $0x41
  801d18:	68 20 25 80 00       	push   $0x802520
  801d1d:	e8 1e ff ff ff       	call   801c40 <_panic>
		}
	}
}
  801d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5f                   	pop    %edi
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	56                   	push   %esi
  801d2e:	53                   	push   %ebx
  801d2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d35:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 05                	jne    801d41 <ipc_recv+0x17>
  801d3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	50                   	push   %eax
  801d45:	e8 31 ed ff ff       	call   800a7b <sys_ipc_recv>
	if (r < 0) {				
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	79 16                	jns    801d67 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801d51:	85 db                	test   %ebx,%ebx
  801d53:	74 06                	je     801d5b <ipc_recv+0x31>
  801d55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801d5b:	85 f6                	test   %esi,%esi
  801d5d:	74 2c                	je     801d8b <ipc_recv+0x61>
  801d5f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801d65:	eb 24                	jmp    801d8b <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801d67:	85 db                	test   %ebx,%ebx
  801d69:	74 0a                	je     801d75 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801d6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801d70:	8b 40 74             	mov    0x74(%eax),%eax
  801d73:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801d75:	85 f6                	test   %esi,%esi
  801d77:	74 0a                	je     801d83 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801d79:	a1 04 40 80 00       	mov    0x804004,%eax
  801d7e:	8b 40 78             	mov    0x78(%eax),%eax
  801d81:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801d83:	a1 04 40 80 00       	mov    0x804004,%eax
  801d88:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    
	...

00801d94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	c1 e8 16             	shr    $0x16,%eax
  801d9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da6:	a8 01                	test   $0x1,%al
  801da8:	74 20                	je     801dca <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	c1 e8 0c             	shr    $0xc,%eax
  801daf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801db6:	a8 01                	test   $0x1,%al
  801db8:	74 10                	je     801dca <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dba:	c1 e8 0c             	shr    $0xc,%eax
  801dbd:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dc4:	ef 
  801dc5:	0f b7 c0             	movzwl %ax,%eax
  801dc8:	eb 05                	jmp    801dcf <pageref+0x3b>
  801dca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    
  801dd1:	00 00                	add    %al,(%eax)
	...

00801dd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	57                   	push   %edi
  801dd8:	56                   	push   %esi
  801dd9:	83 ec 28             	sub    $0x28,%esp
  801ddc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801de3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801dea:	8b 45 10             	mov    0x10(%ebp),%eax
  801ded:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801df0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801df3:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801df5:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e00:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e03:	85 ff                	test   %edi,%edi
  801e05:	75 21                	jne    801e28 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801e07:	39 d1                	cmp    %edx,%ecx
  801e09:	76 49                	jbe    801e54 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e0b:	f7 f1                	div    %ecx
  801e0d:	89 c1                	mov    %eax,%ecx
  801e0f:	31 c0                	xor    %eax,%eax
  801e11:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e14:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801e17:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e1a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e20:	83 c4 28             	add    $0x28,%esp
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    
  801e27:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e28:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801e2b:	0f 87 97 00 00 00    	ja     801ec8 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e31:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801e34:	83 f0 1f             	xor    $0x1f,%eax
  801e37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e3a:	75 34                	jne    801e70 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e3c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801e3f:	72 08                	jb     801e49 <__udivdi3+0x75>
  801e41:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801e44:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e47:	77 7f                	ja     801ec8 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e49:	b9 01 00 00 00       	mov    $0x1,%ecx
  801e4e:	31 c0                	xor    %eax,%eax
  801e50:	eb c2                	jmp    801e14 <__udivdi3+0x40>
  801e52:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e57:	85 c0                	test   %eax,%eax
  801e59:	74 79                	je     801ed4 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e5e:	89 fa                	mov    %edi,%edx
  801e60:	f7 f1                	div    %ecx
  801e62:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e67:	f7 f1                	div    %ecx
  801e69:	89 c1                	mov    %eax,%ecx
  801e6b:	89 f0                	mov    %esi,%eax
  801e6d:	eb a5                	jmp    801e14 <__udivdi3+0x40>
  801e6f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e70:	b8 20 00 00 00       	mov    $0x20,%eax
  801e75:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801e78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801e7b:	89 fa                	mov    %edi,%edx
  801e7d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e80:	d3 e2                	shl    %cl,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801e88:	d3 e8                	shr    %cl,%eax
  801e8a:	89 d7                	mov    %edx,%edi
  801e8c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e8e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801e91:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e94:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e99:	d3 e0                	shl    %cl,%eax
  801e9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801e9e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801ea1:	d3 ea                	shr    %cl,%edx
  801ea3:	09 d0                	or     %edx,%eax
  801ea5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ea8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	f7 f7                	div    %edi
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801eb4:	f7 e6                	mul    %esi
  801eb6:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eb8:	39 d7                	cmp    %edx,%edi
  801eba:	72 38                	jb     801ef4 <__udivdi3+0x120>
  801ebc:	74 27                	je     801ee5 <__udivdi3+0x111>
  801ebe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801ec1:	31 c0                	xor    %eax,%eax
  801ec3:	e9 4c ff ff ff       	jmp    801e14 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ec8:	31 c9                	xor    %ecx,%ecx
  801eca:	31 c0                	xor    %eax,%eax
  801ecc:	e9 43 ff ff ff       	jmp    801e14 <__udivdi3+0x40>
  801ed1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ed4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed9:	31 d2                	xor    %edx,%edx
  801edb:	f7 75 f4             	divl   -0xc(%ebp)
  801ede:	89 c1                	mov    %eax,%ecx
  801ee0:	e9 76 ff ff ff       	jmp    801e5b <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ee8:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801eeb:	d3 e0                	shl    %cl,%eax
  801eed:	39 f0                	cmp    %esi,%eax
  801eef:	73 cd                	jae    801ebe <__udivdi3+0xea>
  801ef1:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ef4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801ef7:	49                   	dec    %ecx
  801ef8:	31 c0                	xor    %eax,%eax
  801efa:	e9 15 ff ff ff       	jmp    801e14 <__udivdi3+0x40>
	...

00801f00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	57                   	push   %edi
  801f04:	56                   	push   %esi
  801f05:	83 ec 30             	sub    $0x30,%esp
  801f08:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801f0f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801f16:	8b 75 08             	mov    0x8(%ebp),%esi
  801f19:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f1f:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801f22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f25:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801f27:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801f2a:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801f2d:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f30:	85 d2                	test   %edx,%edx
  801f32:	75 1c                	jne    801f50 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801f34:	89 fa                	mov    %edi,%edx
  801f36:	39 f8                	cmp    %edi,%eax
  801f38:	0f 86 c2 00 00 00    	jbe    802000 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f3e:	89 f0                	mov    %esi,%eax
  801f40:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801f42:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801f45:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801f4c:	eb 12                	jmp    801f60 <__umoddi3+0x60>
  801f4e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f50:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f53:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801f56:	76 18                	jbe    801f70 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801f58:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801f5b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801f5e:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f60:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801f63:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801f66:	83 c4 30             	add    $0x30,%esp
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	c9                   	leave  
  801f6c:	c3                   	ret    
  801f6d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f70:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801f74:	83 f0 1f             	xor    $0x1f,%eax
  801f77:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f7a:	0f 84 ac 00 00 00    	je     80202c <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f80:	b8 20 00 00 00       	mov    $0x20,%eax
  801f85:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801f88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f8b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f8e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801f91:	d3 e2                	shl    %cl,%edx
  801f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f96:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801f99:	d3 e8                	shr    %cl,%eax
  801f9b:	89 d6                	mov    %edx,%esi
  801f9d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  801f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801fa5:	d3 e0                	shl    %cl,%eax
  801fa7:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801faa:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801fad:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801faf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fb2:	d3 e0                	shl    %cl,%eax
  801fb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801fba:	d3 ea                	shr    %cl,%edx
  801fbc:	09 d0                	or     %edx,%eax
  801fbe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801fc1:	d3 ea                	shr    %cl,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801fc8:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fcb:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801fce:	0f 82 8d 00 00 00    	jb     802061 <__umoddi3+0x161>
  801fd4:	0f 84 91 00 00 00    	je     80206b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fda:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801fdd:	29 c7                	sub    %eax,%edi
  801fdf:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801fe6:	d3 e2                	shl    %cl,%edx
  801fe8:	89 f8                	mov    %edi,%eax
  801fea:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801fed:	d3 e8                	shr    %cl,%eax
  801fef:	09 c2                	or     %eax,%edx
  801ff1:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801ff4:	d3 ee                	shr    %cl,%esi
  801ff6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801ff9:	e9 62 ff ff ff       	jmp    801f60 <__umoddi3+0x60>
  801ffe:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802000:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802003:	85 c0                	test   %eax,%eax
  802005:	74 15                	je     80201c <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802007:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80200a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80200d:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	f7 f1                	div    %ecx
  802014:	e9 29 ff ff ff       	jmp    801f42 <__umoddi3+0x42>
  802019:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80201c:	b8 01 00 00 00       	mov    $0x1,%eax
  802021:	31 d2                	xor    %edx,%edx
  802023:	f7 75 ec             	divl   -0x14(%ebp)
  802026:	89 c1                	mov    %eax,%ecx
  802028:	eb dd                	jmp    802007 <__umoddi3+0x107>
  80202a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80202c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80202f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  802032:	72 19                	jb     80204d <__umoddi3+0x14d>
  802034:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802037:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80203a:	76 11                	jbe    80204d <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80203c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  802042:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802045:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802048:	e9 13 ff ff ff       	jmp    801f60 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80204d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802050:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802053:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802056:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802059:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80205c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80205f:	eb db                	jmp    80203c <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802061:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802064:	19 f2                	sbb    %esi,%edx
  802066:	e9 6f ff ff ff       	jmp    801fda <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80206b:	39 c7                	cmp    %eax,%edi
  80206d:	72 f2                	jb     802061 <__umoddi3+0x161>
  80206f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802072:	e9 63 ff ff ff       	jmp    801fda <__umoddi3+0xda>
