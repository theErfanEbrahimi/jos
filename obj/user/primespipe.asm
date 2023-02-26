
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 0f 02 00 00       	call   800240 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	83 ec 04             	sub    $0x4,%esp
  800043:	6a 04                	push   $0x4
  800045:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	53                   	push   %ebx
  80004a:	e8 fa 13 00 00       	call   801449 <readn>
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	83 f8 04             	cmp    $0x4,%eax
  800055:	74 21                	je     800078 <primeproc+0x44>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800057:	83 ec 0c             	sub    $0xc,%esp
  80005a:	89 c2                	mov    %eax,%edx
  80005c:	85 c0                	test   %eax,%eax
  80005e:	7e 05                	jle    800065 <primeproc+0x31>
  800060:	ba 00 00 00 00       	mov    $0x0,%edx
  800065:	52                   	push   %edx
  800066:	50                   	push   %eax
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	6a 15                	push   $0x15
  80006e:	68 cf 22 80 00       	push   $0x8022cf
  800073:	e8 2c 02 00 00       	call   8002a4 <_panic>

	cprintf("%d\n", p);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	ff 75 ec             	pushl  -0x14(%ebp)
  80007e:	68 e1 22 80 00       	push   $0x8022e1
  800083:	e8 bd 02 00 00       	call   800345 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800088:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80008b:	89 04 24             	mov    %eax,(%esp)
  80008e:	e8 97 1a 00 00       	call   801b2a <pipe>
  800093:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <primeproc+0x7b>
		panic("pipe: %e", i);
  80009d:	50                   	push   %eax
  80009e:	68 e5 22 80 00       	push   $0x8022e5
  8000a3:	6a 1b                	push   $0x1b
  8000a5:	68 cf 22 80 00       	push   $0x8022cf
  8000aa:	e8 f5 01 00 00       	call   8002a4 <_panic>
	if ((id = fork()) < 0)
  8000af:	e8 d6 0d 00 00       	call   800e8a <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <primeproc+0x96>
		panic("fork: %e", id);
  8000b8:	50                   	push   %eax
  8000b9:	68 ee 22 80 00       	push   $0x8022ee
  8000be:	6a 1d                	push   $0x1d
  8000c0:	68 cf 22 80 00       	push   $0x8022cf
  8000c5:	e8 da 01 00 00       	call   8002a4 <_panic>
	if (id == 0) {
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 1f                	jne    8000ed <primeproc+0xb9>
		close(fd);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 41 14 00 00       	call   801518 <close>
		close(pfd[1]);
  8000d7:	83 c4 04             	add    $0x4,%esp
  8000da:	ff 75 e8             	pushl  -0x18(%ebp)
  8000dd:	e8 36 14 00 00       	call   801518 <close>
		fd = pfd[0];
  8000e2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		goto top;
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	e9 53 ff ff ff       	jmp    800040 <primeproc+0xc>
	}

	close(pfd[0]);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f3:	e8 20 14 00 00       	call   801518 <close>
	wfd = pfd[1];
  8000f8:	8b 7d e8             	mov    -0x18(%ebp),%edi
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	8d 75 f0             	lea    -0x10(%ebp),%esi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	6a 04                	push   $0x4
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	e8 3c 13 00 00       	call   801449 <readn>
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	83 f8 04             	cmp    $0x4,%eax
  800113:	74 25                	je     80013a <primeproc+0x106>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800115:	83 ec 04             	sub    $0x4,%esp
  800118:	89 c2                	mov    %eax,%edx
  80011a:	85 c0                	test   %eax,%eax
  80011c:	7e 05                	jle    800123 <primeproc+0xef>
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	52                   	push   %edx
  800124:	50                   	push   %eax
  800125:	53                   	push   %ebx
  800126:	ff 75 ec             	pushl  -0x14(%ebp)
  800129:	68 f7 22 80 00       	push   $0x8022f7
  80012e:	6a 2b                	push   $0x2b
  800130:	68 cf 22 80 00       	push   $0x8022cf
  800135:	e8 6a 01 00 00       	call   8002a4 <_panic>
		if (i%p)
  80013a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80013d:	99                   	cltd   
  80013e:	f7 7d ec             	idivl  -0x14(%ebp)
  800141:	85 d2                	test   %edx,%edx
  800143:	74 bc                	je     800101 <primeproc+0xcd>
			if ((r=write(wfd, &i, 4)) != 4)
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	6a 04                	push   $0x4
  80014a:	56                   	push   %esi
  80014b:	57                   	push   %edi
  80014c:	e8 ef 11 00 00       	call   801340 <write>
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	83 f8 04             	cmp    $0x4,%eax
  800157:	74 a8                	je     800101 <primeproc+0xcd>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	89 c2                	mov    %eax,%edx
  80015e:	85 c0                	test   %eax,%eax
  800160:	7e 05                	jle    800167 <primeproc+0x133>
  800162:	ba 00 00 00 00       	mov    $0x0,%edx
  800167:	52                   	push   %edx
  800168:	50                   	push   %eax
  800169:	ff 75 ec             	pushl  -0x14(%ebp)
  80016c:	68 13 23 80 00       	push   $0x802313
  800171:	6a 2e                	push   $0x2e
  800173:	68 cf 22 80 00       	push   $0x8022cf
  800178:	e8 27 01 00 00       	call   8002a4 <_panic>

0080017d <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 24             	sub    $0x24,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800183:	c7 05 00 30 80 00 2d 	movl   $0x80232d,0x803000
  80018a:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 94 19 00 00       	call   801b2a <pipe>
  800196:	89 45 fc             	mov    %eax,-0x4(%ebp)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	85 c0                	test   %eax,%eax
  80019e:	79 12                	jns    8001b2 <umain+0x35>
		panic("pipe: %e", i);
  8001a0:	50                   	push   %eax
  8001a1:	68 e5 22 80 00       	push   $0x8022e5
  8001a6:	6a 3a                	push   $0x3a
  8001a8:	68 cf 22 80 00       	push   $0x8022cf
  8001ad:	e8 f2 00 00 00       	call   8002a4 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001b2:	e8 d3 0c 00 00       	call   800e8a <fork>
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	79 12                	jns    8001cd <umain+0x50>
		panic("fork: %e", id);
  8001bb:	50                   	push   %eax
  8001bc:	68 ee 22 80 00       	push   $0x8022ee
  8001c1:	6a 3e                	push   $0x3e
  8001c3:	68 cf 22 80 00       	push   $0x8022cf
  8001c8:	e8 d7 00 00 00       	call   8002a4 <_panic>

	if (id == 0) {
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	75 19                	jne    8001ea <umain+0x6d>
		close(p[1]);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 f8             	pushl  -0x8(%ebp)
  8001d7:	e8 3c 13 00 00       	call   801518 <close>
		primeproc(p[0]);
  8001dc:	83 c4 04             	add    $0x4,%esp
  8001df:	ff 75 f4             	pushl  -0xc(%ebp)
  8001e2:	e8 4d fe ff ff       	call   800034 <primeproc>
  8001e7:	83 c4 10             	add    $0x10,%esp
	}

	close(p[0]);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8001f0:	e8 23 13 00 00       	call   801518 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f5:	c7 45 fc 02 00 00 00 	movl   $0x2,-0x4(%ebp)
  8001fc:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	6a 04                	push   $0x4
  800204:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	ff 75 f8             	pushl  -0x8(%ebp)
  80020b:	e8 30 11 00 00       	call   801340 <write>
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	83 f8 04             	cmp    $0x4,%eax
  800216:	74 21                	je     800239 <umain+0xbc>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	89 c2                	mov    %eax,%edx
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 05                	jle    800226 <umain+0xa9>
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	68 38 23 80 00       	push   $0x802338
  80022d:	6a 4a                	push   $0x4a
  80022f:	68 cf 22 80 00       	push   $0x8022cf
  800234:	e8 6b 00 00 00       	call   8002a4 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800239:	ff 45 fc             	incl   -0x4(%ebp)
  80023c:	eb c1                	jmp    8001ff <umain+0x82>
	...

00800240 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	8b 75 08             	mov    0x8(%ebp),%esi
  800248:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80024b:	e8 bf 0b 00 00       	call   800e0f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800250:	25 ff 03 00 00       	and    $0x3ff,%eax
  800255:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80025c:	c1 e0 07             	shl    $0x7,%eax
  80025f:	29 d0                	sub    %edx,%eax
  800261:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800266:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80026b:	85 f6                	test   %esi,%esi
  80026d:	7e 07                	jle    800276 <libmain+0x36>
		binaryname = argv[0];
  80026f:	8b 03                	mov    (%ebx),%eax
  800271:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	53                   	push   %ebx
  80027a:	56                   	push   %esi
  80027b:	e8 fd fe ff ff       	call   80017d <umain>

	// exit gracefully
	exit();
  800280:	e8 0b 00 00 00       	call   800290 <exit>
  800285:	83 c4 10             	add    $0x10,%esp
}
  800288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    
	...

00800290 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800296:	6a 00                	push   $0x0
  800298:	e8 91 0b 00 00       	call   800e2e <sys_env_destroy>
  80029d:	83 c4 10             	add    $0x10,%esp
}
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    
	...

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8002ae:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b1:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002b7:	e8 53 0b 00 00       	call   800e0f <sys_getenvid>
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	ff 75 0c             	pushl  0xc(%ebp)
  8002c2:	ff 75 08             	pushl  0x8(%ebp)
  8002c5:	53                   	push   %ebx
  8002c6:	50                   	push   %eax
  8002c7:	68 5c 23 80 00       	push   $0x80235c
  8002cc:	e8 74 00 00 00       	call   800345 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d1:	83 c4 18             	add    $0x18,%esp
  8002d4:	ff 75 f8             	pushl  -0x8(%ebp)
  8002d7:	ff 75 10             	pushl  0x10(%ebp)
  8002da:	e8 15 00 00 00       	call   8002f4 <vcprintf>
	cprintf("\n");
  8002df:	c7 04 24 e3 22 80 00 	movl   $0x8022e3,(%esp)
  8002e6:	e8 5a 00 00 00       	call   800345 <cprintf>
  8002eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ee:	cc                   	int3   
  8002ef:	eb fd                	jmp    8002ee <_panic+0x4a>
  8002f1:	00 00                	add    %al,(%eax)
	...

008002f4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002fd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800304:	00 00 00 
	b.cnt = 0;
  800307:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80030e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	68 5c 03 80 00       	push   $0x80035c
  800323:	e8 70 01 00 00       	call   800498 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800328:	83 c4 08             	add    $0x8,%esp
  80032b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800331:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800337:	50                   	push   %eax
  800338:	e8 9e 08 00 00       	call   800bdb <sys_cputs>
  80033d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80034e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800351:	50                   	push   %eax
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	e8 9a ff ff ff       	call   8002f4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	53                   	push   %ebx
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800366:	8b 03                	mov    (%ebx),%eax
  800368:	8b 55 08             	mov    0x8(%ebp),%edx
  80036b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80036f:	40                   	inc    %eax
  800370:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800372:	3d ff 00 00 00       	cmp    $0xff,%eax
  800377:	75 1a                	jne    800393 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	68 ff 00 00 00       	push   $0xff
  800381:	8d 43 08             	lea    0x8(%ebx),%eax
  800384:	50                   	push   %eax
  800385:	e8 51 08 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  80038a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800390:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800393:	ff 43 04             	incl   0x4(%ebx)
}
  800396:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800399:	c9                   	leave  
  80039a:	c3                   	ret    
	...

0080039c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	57                   	push   %edi
  8003a0:	56                   	push   %esi
  8003a1:	53                   	push   %ebx
  8003a2:	83 ec 1c             	sub    $0x1c,%esp
  8003a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8003a8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003b7:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003bd:	89 d6                	mov    %edx,%esi
  8003bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8003c4:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8003c7:	72 04                	jb     8003cd <printnum+0x31>
  8003c9:	39 c2                	cmp    %eax,%edx
  8003cb:	77 3f                	ja     80040c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003cd:	83 ec 0c             	sub    $0xc,%esp
  8003d0:	ff 75 18             	pushl  0x18(%ebp)
  8003d3:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003d6:	50                   	push   %eax
  8003d7:	52                   	push   %edx
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e3:	e8 fc 1b 00 00       	call   801fe4 <__udivdi3>
  8003e8:	83 c4 18             	add    $0x18,%esp
  8003eb:	52                   	push   %edx
  8003ec:	50                   	push   %eax
  8003ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8003f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8003f3:	e8 a4 ff ff ff       	call   80039c <printnum>
  8003f8:	83 c4 20             	add    $0x20,%esp
  8003fb:	eb 14                	jmp    800411 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	ff 75 e8             	pushl  -0x18(%ebp)
  800403:	ff 75 18             	pushl  0x18(%ebp)
  800406:	ff 55 ec             	call   *-0x14(%ebp)
  800409:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040c:	4b                   	dec    %ebx
  80040d:	85 db                	test   %ebx,%ebx
  80040f:	7f ec                	jg     8003fd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	ff 75 e8             	pushl  -0x18(%ebp)
  800417:	83 ec 04             	sub    $0x4,%esp
  80041a:	57                   	push   %edi
  80041b:	56                   	push   %esi
  80041c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041f:	ff 75 e0             	pushl  -0x20(%ebp)
  800422:	e8 e9 1c 00 00       	call   802110 <__umoddi3>
  800427:	83 c4 14             	add    $0x14,%esp
  80042a:	0f be 80 7f 23 80 00 	movsbl 0x80237f(%eax),%eax
  800431:	50                   	push   %eax
  800432:	ff 55 ec             	call   *-0x14(%ebp)
  800435:	83 c4 10             	add    $0x10,%esp
}
  800438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043b:	5b                   	pop    %ebx
  80043c:	5e                   	pop    %esi
  80043d:	5f                   	pop    %edi
  80043e:	c9                   	leave  
  80043f:	c3                   	ret    

00800440 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800445:	83 fa 01             	cmp    $0x1,%edx
  800448:	7e 0e                	jle    800458 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80044a:	8b 10                	mov    (%eax),%edx
  80044c:	8d 42 08             	lea    0x8(%edx),%eax
  80044f:	89 01                	mov    %eax,(%ecx)
  800451:	8b 02                	mov    (%edx),%eax
  800453:	8b 52 04             	mov    0x4(%edx),%edx
  800456:	eb 22                	jmp    80047a <getuint+0x3a>
	else if (lflag)
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 10                	je     80046c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80045c:	8b 10                	mov    (%eax),%edx
  80045e:	8d 42 04             	lea    0x4(%edx),%eax
  800461:	89 01                	mov    %eax,(%ecx)
  800463:	8b 02                	mov    (%edx),%eax
  800465:	ba 00 00 00 00       	mov    $0x0,%edx
  80046a:	eb 0e                	jmp    80047a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	8d 42 04             	lea    0x4(%edx),%eax
  800471:	89 01                	mov    %eax,(%ecx)
  800473:	8b 02                	mov    (%edx),%eax
  800475:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047a:	c9                   	leave  
  80047b:	c3                   	ret    

0080047c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800482:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800485:	8b 11                	mov    (%ecx),%edx
  800487:	3b 51 04             	cmp    0x4(%ecx),%edx
  80048a:	73 0a                	jae    800496 <sprintputch+0x1a>
		*b->buf++ = ch;
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	88 02                	mov    %al,(%edx)
  800491:	8d 42 01             	lea    0x1(%edx),%eax
  800494:	89 01                	mov    %eax,(%ecx)
}
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 3c             	sub    $0x3c,%esp
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004aa:	eb 1a                	jmp    8004c6 <vprintfmt+0x2e>
  8004ac:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8004af:	eb 15                	jmp    8004c6 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b1:	84 c0                	test   %al,%al
  8004b3:	0f 84 15 03 00 00    	je     8007ce <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	57                   	push   %edi
  8004bd:	0f b6 c0             	movzbl %al,%eax
  8004c0:	50                   	push   %eax
  8004c1:	ff d6                	call   *%esi
  8004c3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c6:	8a 03                	mov    (%ebx),%al
  8004c8:	43                   	inc    %ebx
  8004c9:	3c 25                	cmp    $0x25,%al
  8004cb:	75 e4                	jne    8004b1 <vprintfmt+0x19>
  8004cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004db:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8004e9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8004ed:	eb 0a                	jmp    8004f9 <vprintfmt+0x61>
  8004ef:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8004f6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8a 03                	mov    (%ebx),%al
  8004fb:	0f b6 d0             	movzbl %al,%edx
  8004fe:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800501:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800504:	83 e8 23             	sub    $0x23,%eax
  800507:	3c 55                	cmp    $0x55,%al
  800509:	0f 87 9c 02 00 00    	ja     8007ab <vprintfmt+0x313>
  80050f:	0f b6 c0             	movzbl %al,%eax
  800512:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  800519:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80051d:	eb d7                	jmp    8004f6 <vprintfmt+0x5e>
  80051f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800523:	eb d1                	jmp    8004f6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800525:	89 d9                	mov    %ebx,%ecx
  800527:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80052e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800531:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800534:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800538:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80053b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80053f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800540:	8d 42 d0             	lea    -0x30(%edx),%eax
  800543:	83 f8 09             	cmp    $0x9,%eax
  800546:	77 21                	ja     800569 <vprintfmt+0xd1>
  800548:	eb e4                	jmp    80052e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054a:	8b 55 14             	mov    0x14(%ebp),%edx
  80054d:	8d 42 04             	lea    0x4(%edx),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	8b 12                	mov    (%edx),%edx
  800555:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800558:	eb 12                	jmp    80056c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	79 96                	jns    8004f6 <vprintfmt+0x5e>
  800560:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800567:	eb 8d                	jmp    8004f6 <vprintfmt+0x5e>
  800569:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80056c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800570:	79 84                	jns    8004f6 <vprintfmt+0x5e>
  800572:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80057f:	e9 72 ff ff ff       	jmp    8004f6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800584:	ff 45 d4             	incl   -0x2c(%ebp)
  800587:	e9 6a ff ff ff       	jmp    8004f6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058c:	8b 55 14             	mov    0x14(%ebp),%edx
  80058f:	8d 42 04             	lea    0x4(%edx),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	ff 32                	pushl  (%edx)
  80059b:	ff d6                	call   *%esi
			break;
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	e9 07 ff ff ff       	jmp    8004ac <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005a5:	8b 55 14             	mov    0x14(%ebp),%edx
  8005a8:	8d 42 04             	lea    0x4(%edx),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ae:	8b 02                	mov    (%edx),%eax
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	79 02                	jns    8005b6 <vprintfmt+0x11e>
  8005b4:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b6:	83 f8 0f             	cmp    $0xf,%eax
  8005b9:	7f 0b                	jg     8005c6 <vprintfmt+0x12e>
  8005bb:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	75 15                	jne    8005db <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8005c6:	50                   	push   %eax
  8005c7:	68 90 23 80 00       	push   $0x802390
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	e8 6e 02 00 00       	call   800841 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	e9 d1 fe ff ff       	jmp    8004ac <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005db:	52                   	push   %edx
  8005dc:	68 95 28 80 00       	push   $0x802895
  8005e1:	57                   	push   %edi
  8005e2:	56                   	push   %esi
  8005e3:	e8 59 02 00 00       	call   800841 <printfmt>
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	e9 bc fe ff ff       	jmp    8004ac <vprintfmt+0x14>
  8005f0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8005fc:	8d 42 04             	lea    0x4(%edx),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800602:	8b 1a                	mov    (%edx),%ebx
  800604:	85 db                	test   %ebx,%ebx
  800606:	75 05                	jne    80060d <vprintfmt+0x175>
  800608:	bb 99 23 80 00       	mov    $0x802399,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80060d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800611:	7e 66                	jle    800679 <vprintfmt+0x1e1>
  800613:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800617:	74 60                	je     800679 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	51                   	push   %ecx
  80061d:	53                   	push   %ebx
  80061e:	e8 57 02 00 00       	call   80087a <strnlen>
  800623:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800626:	29 c1                	sub    %eax,%ecx
  800628:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800632:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800635:	eb 0f                	jmp    800646 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80063e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800640:	ff 4d d8             	decl   -0x28(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	7f eb                	jg     800637 <vprintfmt+0x19f>
  80064c:	eb 2b                	jmp    800679 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800655:	74 15                	je     80066c <vprintfmt+0x1d4>
  800657:	8d 42 e0             	lea    -0x20(%edx),%eax
  80065a:	83 f8 5e             	cmp    $0x5e,%eax
  80065d:	76 0d                	jbe    80066c <vprintfmt+0x1d4>
					putch('?', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	6a 3f                	push   $0x3f
  800665:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	eb 0a                	jmp    800676 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	57                   	push   %edi
  800670:	52                   	push   %edx
  800671:	ff d6                	call   *%esi
  800673:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	ff 4d d8             	decl   -0x28(%ebp)
  800679:	8a 03                	mov    (%ebx),%al
  80067b:	43                   	inc    %ebx
  80067c:	84 c0                	test   %al,%al
  80067e:	74 1b                	je     80069b <vprintfmt+0x203>
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	78 c8                	js     80064e <vprintfmt+0x1b6>
  800686:	ff 4d dc             	decl   -0x24(%ebp)
  800689:	79 c3                	jns    80064e <vprintfmt+0x1b6>
  80068b:	eb 0e                	jmp    80069b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	57                   	push   %edi
  800691:	6a 20                	push   $0x20
  800693:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800695:	ff 4d d8             	decl   -0x28(%ebp)
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80069f:	7f ec                	jg     80068d <vprintfmt+0x1f5>
  8006a1:	e9 06 fe ff ff       	jmp    8004ac <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006aa:	7e 10                	jle    8006bc <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8006ac:	8b 55 14             	mov    0x14(%ebp),%edx
  8006af:	8d 42 08             	lea    0x8(%edx),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b5:	8b 02                	mov    (%edx),%eax
  8006b7:	8b 52 04             	mov    0x4(%edx),%edx
  8006ba:	eb 20                	jmp    8006dc <vprintfmt+0x244>
	else if (lflag)
  8006bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006c0:	74 0e                	je     8006d0 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	99                   	cltd   
  8006ce:	eb 0c                	jmp    8006dc <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d9:	8b 00                	mov    (%eax),%eax
  8006db:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006dc:	89 d1                	mov    %edx,%ecx
  8006de:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8006e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	78 0a                	js     8006f4 <vprintfmt+0x25c>
  8006ea:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8006ef:	e9 89 00 00 00       	jmp    80077d <vprintfmt+0x2e5>
				putch('-', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	57                   	push   %edi
  8006f8:	6a 2d                	push   $0x2d
  8006fa:	ff d6                	call   *%esi
				num = -(long long) num;
  8006fc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8006ff:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800702:	f7 da                	neg    %edx
  800704:	83 d1 00             	adc    $0x0,%ecx
  800707:	f7 d9                	neg    %ecx
  800709:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 6a                	jmp    80077d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800719:	e8 22 fd ff ff       	call   800440 <getuint>
  80071e:	89 d1                	mov    %edx,%ecx
  800720:	89 c2                	mov    %eax,%edx
  800722:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800727:	eb 54                	jmp    80077d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800729:	8d 45 14             	lea    0x14(%ebp),%eax
  80072c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072f:	e8 0c fd ff ff       	call   800440 <getuint>
  800734:	89 d1                	mov    %edx,%ecx
  800736:	89 c2                	mov    %eax,%edx
  800738:	bb 08 00 00 00       	mov    $0x8,%ebx
  80073d:	eb 3e                	jmp    80077d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	57                   	push   %edi
  800743:	6a 30                	push   $0x30
  800745:	ff d6                	call   *%esi
			putch('x', putdat);
  800747:	83 c4 08             	add    $0x8,%esp
  80074a:	57                   	push   %edi
  80074b:	6a 78                	push   $0x78
  80074d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80074f:	8b 55 14             	mov    0x14(%ebp),%edx
  800752:	8d 42 04             	lea    0x4(%edx),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
  800758:	8b 12                	mov    (%edx),%edx
  80075a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	eb 14                	jmp    80077d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
  80076c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80076f:	e8 cc fc ff ff       	call   800440 <getuint>
  800774:	89 d1                	mov    %edx,%ecx
  800776:	89 c2                	mov    %eax,%edx
  800778:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800784:	50                   	push   %eax
  800785:	ff 75 d8             	pushl  -0x28(%ebp)
  800788:	53                   	push   %ebx
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	89 fa                	mov    %edi,%edx
  80078d:	89 f0                	mov    %esi,%eax
  80078f:	e8 08 fc ff ff       	call   80039c <printnum>
			break;
  800794:	83 c4 20             	add    $0x20,%esp
  800797:	e9 10 fd ff ff       	jmp    8004ac <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	57                   	push   %edi
  8007a0:	52                   	push   %edx
  8007a1:	ff d6                	call   *%esi
			break;
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	e9 01 fd ff ff       	jmp    8004ac <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	57                   	push   %edi
  8007af:	6a 25                	push   $0x25
  8007b1:	ff d6                	call   *%esi
  8007b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8007b6:	83 ea 02             	sub    $0x2,%edx
  8007b9:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bc:	8a 02                	mov    (%edx),%al
  8007be:	4a                   	dec    %edx
  8007bf:	3c 25                	cmp    $0x25,%al
  8007c1:	75 f9                	jne    8007bc <vprintfmt+0x324>
  8007c3:	83 c2 02             	add    $0x2,%edx
  8007c6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8007c9:	e9 de fc ff ff       	jmp    8004ac <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8007ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5f                   	pop    %edi
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	74 37                	je     80081d <vsnprintf+0x47>
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	7e 33                	jle    80081d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007f1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8007f8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fb:	ff 75 14             	pushl  0x14(%ebp)
  8007fe:	ff 75 10             	pushl  0x10(%ebp)
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	68 7c 04 80 00       	push   $0x80047c
  80080a:	e8 89 fc ff ff       	call   800498 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800812:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800815:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	eb 05                	jmp    800822 <vsnprintf+0x4c>
  80081d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800822:	c9                   	leave  
  800823:	c3                   	ret    

00800824 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80082a:	8d 45 14             	lea    0x14(%ebp),%eax
  80082d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800830:	50                   	push   %eax
  800831:	ff 75 10             	pushl  0x10(%ebp)
  800834:	ff 75 0c             	pushl  0xc(%ebp)
  800837:	ff 75 08             	pushl  0x8(%ebp)
  80083a:	e8 97 ff ff ff       	call   8007d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
  80084a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80084d:	50                   	push   %eax
  80084e:	ff 75 10             	pushl  0x10(%ebp)
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	ff 75 08             	pushl  0x8(%ebp)
  800857:	e8 3c fc ff ff       	call   800498 <vprintfmt>
	va_end(ap);
  80085c:	83 c4 10             	add    $0x10,%esp
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    
  800861:	00 00                	add    %al,(%eax)
	...

00800864 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 55 08             	mov    0x8(%ebp),%edx
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	eb 01                	jmp    800872 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800871:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800872:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800876:	75 f9                	jne    800871 <strlen+0xd>
		n++;
	return n;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
  800888:	eb 01                	jmp    80088b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80088a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 06                	je     800895 <strnlen+0x1b>
  80088f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800893:	75 f5                	jne    80088a <strnlen+0x10>
		n++;
	return n;
}
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a0:	8a 01                	mov    (%ecx),%al
  8008a2:	88 02                	mov    %al,(%edx)
  8008a4:	42                   	inc    %edx
  8008a5:	41                   	inc    %ecx
  8008a6:	84 c0                	test   %al,%al
  8008a8:	75 f6                	jne    8008a0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	53                   	push   %ebx
  8008b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b6:	53                   	push   %ebx
  8008b7:	e8 a8 ff ff ff       	call   800864 <strlen>
	strcpy(dst + len, src);
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008c2:	50                   	push   %eax
  8008c3:	e8 cf ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008c8:	89 d8                	mov    %ebx,%eax
  8008ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e2:	eb 0c                	jmp    8008f0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008e4:	8a 02                	mov    (%edx),%al
  8008e6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ef:	41                   	inc    %ecx
  8008f0:	39 d9                	cmp    %ebx,%ecx
  8008f2:	75 f0                	jne    8008e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	75 04                	jne    800910 <strlcpy+0x16>
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	eb 14                	jmp    800924 <strlcpy+0x2a>
  800910:	89 f0                	mov    %esi,%eax
  800912:	eb 04                	jmp    800918 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800914:	88 10                	mov    %dl,(%eax)
  800916:	40                   	inc    %eax
  800917:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800918:	49                   	dec    %ecx
  800919:	74 06                	je     800921 <strlcpy+0x27>
  80091b:	8a 13                	mov    (%ebx),%dl
  80091d:	84 d2                	test   %dl,%dl
  80091f:	75 f3                	jne    800914 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800921:	c6 00 00             	movb   $0x0,(%eax)
  800924:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
  800930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800933:	eb 02                	jmp    800937 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800935:	42                   	inc    %edx
  800936:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800937:	8a 02                	mov    (%edx),%al
  800939:	84 c0                	test   %al,%al
  80093b:	74 04                	je     800941 <strcmp+0x17>
  80093d:	3a 01                	cmp    (%ecx),%al
  80093f:	74 f4                	je     800935 <strcmp+0xb>
  800941:	0f b6 c0             	movzbl %al,%eax
  800944:	0f b6 11             	movzbl (%ecx),%edx
  800947:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800955:	8b 55 10             	mov    0x10(%ebp),%edx
  800958:	eb 03                	jmp    80095d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80095a:	4a                   	dec    %edx
  80095b:	41                   	inc    %ecx
  80095c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095d:	85 d2                	test   %edx,%edx
  80095f:	75 07                	jne    800968 <strncmp+0x1d>
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
  800966:	eb 14                	jmp    80097c <strncmp+0x31>
  800968:	8a 01                	mov    (%ecx),%al
  80096a:	84 c0                	test   %al,%al
  80096c:	74 04                	je     800972 <strncmp+0x27>
  80096e:	3a 03                	cmp    (%ebx),%al
  800970:	74 e8                	je     80095a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800972:	0f b6 d0             	movzbl %al,%edx
  800975:	0f b6 03             	movzbl (%ebx),%eax
  800978:	29 c2                	sub    %eax,%edx
  80097a:	89 d0                	mov    %edx,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800988:	eb 05                	jmp    80098f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 0c                	je     80099a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098e:	40                   	inc    %eax
  80098f:	8a 10                	mov    (%eax),%dl
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f5                	jne    80098a <strchr+0xb>
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009a5:	eb 05                	jmp    8009ac <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8009a7:	38 ca                	cmp    %cl,%dl
  8009a9:	74 07                	je     8009b2 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ab:	40                   	inc    %eax
  8009ac:	8a 10                	mov    (%eax),%dl
  8009ae:	84 d2                	test   %dl,%dl
  8009b0:	75 f5                	jne    8009a7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	57                   	push   %edi
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	74 36                	je     8009fd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cd:	75 29                	jne    8009f8 <memset+0x44>
  8009cf:	f6 c3 03             	test   $0x3,%bl
  8009d2:	75 24                	jne    8009f8 <memset+0x44>
		c &= 0xFF;
  8009d4:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d7:	89 d6                	mov    %edx,%esi
  8009d9:	c1 e6 08             	shl    $0x8,%esi
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	c1 e0 18             	shl    $0x18,%eax
  8009e1:	89 d1                	mov    %edx,%ecx
  8009e3:	c1 e1 10             	shl    $0x10,%ecx
  8009e6:	09 c8                	or     %ecx,%eax
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	89 f0                	mov    %esi,%eax
  8009ec:	09 d0                	or     %edx,%eax
  8009ee:	89 d9                	mov    %ebx,%ecx
  8009f0:	c1 e9 02             	shr    $0x2,%ecx
  8009f3:	fc                   	cld    
  8009f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f8:	89 d9                	mov    %ebx,%ecx
  8009fa:	fc                   	cld    
  8009fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009fd:	89 f8                	mov    %edi,%eax
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a12:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a14:	39 c6                	cmp    %eax,%esi
  800a16:	73 36                	jae    800a4e <memmove+0x4a>
  800a18:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a1b:	39 d0                	cmp    %edx,%eax
  800a1d:	73 2f                	jae    800a4e <memmove+0x4a>
		s += n;
		d += n;
  800a1f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a22:	f6 c2 03             	test   $0x3,%dl
  800a25:	75 1b                	jne    800a42 <memmove+0x3e>
  800a27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2d:	75 13                	jne    800a42 <memmove+0x3e>
  800a2f:	f6 c1 03             	test   $0x3,%cl
  800a32:	75 0e                	jne    800a42 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800a34:	8d 7e fc             	lea    -0x4(%esi),%edi
  800a37:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
  800a3d:	fd                   	std    
  800a3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a40:	eb 09                	jmp    800a4b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a42:	8d 7e ff             	lea    -0x1(%esi),%edi
  800a45:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a48:	fd                   	std    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4b:	fc                   	cld    
  800a4c:	eb 20                	jmp    800a6e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a54:	75 15                	jne    800a6b <memmove+0x67>
  800a56:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5c:	75 0d                	jne    800a6b <memmove+0x67>
  800a5e:	f6 c1 03             	test   $0x3,%cl
  800a61:	75 08                	jne    800a6b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800a63:	c1 e9 02             	shr    $0x2,%ecx
  800a66:	fc                   	cld    
  800a67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a69:	eb 03                	jmp    800a6e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a6b:	fc                   	cld    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a75:	ff 75 10             	pushl  0x10(%ebp)
  800a78:	ff 75 0c             	pushl  0xc(%ebp)
  800a7b:	ff 75 08             	pushl  0x8(%ebp)
  800a7e:	e8 81 ff ff ff       	call   800a04 <memmove>
}
  800a83:	c9                   	leave  
  800a84:	c3                   	ret    

00800a85 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	53                   	push   %ebx
  800a89:	83 ec 04             	sub    $0x4,%esp
  800a8c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a95:	eb 1b                	jmp    800ab2 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800a97:	8a 1a                	mov    (%edx),%bl
  800a99:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800a9c:	8a 19                	mov    (%ecx),%bl
  800a9e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800aa1:	74 0d                	je     800ab0 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800aa3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800aa7:	0f b6 c3             	movzbl %bl,%eax
  800aaa:	29 c2                	sub    %eax,%edx
  800aac:	89 d0                	mov    %edx,%eax
  800aae:	eb 0d                	jmp    800abd <memcmp+0x38>
		s1++, s2++;
  800ab0:	42                   	inc    %edx
  800ab1:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab2:	48                   	dec    %eax
  800ab3:	83 f8 ff             	cmp    $0xffffffff,%eax
  800ab6:	75 df                	jne    800a97 <memcmp+0x12>
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800abd:	83 c4 04             	add    $0x4,%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	03 55 10             	add    0x10(%ebp),%edx
  800ad1:	eb 05                	jmp    800ad8 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad3:	38 08                	cmp    %cl,(%eax)
  800ad5:	74 05                	je     800adc <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad7:	40                   	inc    %eax
  800ad8:	39 d0                	cmp    %edx,%eax
  800ada:	72 f7                	jb     800ad3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 04             	sub    $0x4,%esp
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 75 10             	mov    0x10(%ebp),%esi
  800aed:	eb 01                	jmp    800af0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800aef:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af0:	8a 01                	mov    (%ecx),%al
  800af2:	3c 20                	cmp    $0x20,%al
  800af4:	74 f9                	je     800aef <strtol+0x11>
  800af6:	3c 09                	cmp    $0x9,%al
  800af8:	74 f5                	je     800aef <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afa:	3c 2b                	cmp    $0x2b,%al
  800afc:	75 0a                	jne    800b08 <strtol+0x2a>
		s++;
  800afe:	41                   	inc    %ecx
  800aff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b06:	eb 17                	jmp    800b1f <strtol+0x41>
	else if (*s == '-')
  800b08:	3c 2d                	cmp    $0x2d,%al
  800b0a:	74 09                	je     800b15 <strtol+0x37>
  800b0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b13:	eb 0a                	jmp    800b1f <strtol+0x41>
		s++, neg = 1;
  800b15:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b18:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	85 f6                	test   %esi,%esi
  800b21:	74 05                	je     800b28 <strtol+0x4a>
  800b23:	83 fe 10             	cmp    $0x10,%esi
  800b26:	75 1a                	jne    800b42 <strtol+0x64>
  800b28:	8a 01                	mov    (%ecx),%al
  800b2a:	3c 30                	cmp    $0x30,%al
  800b2c:	75 10                	jne    800b3e <strtol+0x60>
  800b2e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b32:	75 0a                	jne    800b3e <strtol+0x60>
		s += 2, base = 16;
  800b34:	83 c1 02             	add    $0x2,%ecx
  800b37:	be 10 00 00 00       	mov    $0x10,%esi
  800b3c:	eb 04                	jmp    800b42 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800b3e:	85 f6                	test   %esi,%esi
  800b40:	74 07                	je     800b49 <strtol+0x6b>
  800b42:	bf 00 00 00 00       	mov    $0x0,%edi
  800b47:	eb 13                	jmp    800b5c <strtol+0x7e>
  800b49:	3c 30                	cmp    $0x30,%al
  800b4b:	74 07                	je     800b54 <strtol+0x76>
  800b4d:	be 0a 00 00 00       	mov    $0xa,%esi
  800b52:	eb ee                	jmp    800b42 <strtol+0x64>
		s++, base = 8;
  800b54:	41                   	inc    %ecx
  800b55:	be 08 00 00 00       	mov    $0x8,%esi
  800b5a:	eb e6                	jmp    800b42 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5c:	8a 11                	mov    (%ecx),%dl
  800b5e:	88 d3                	mov    %dl,%bl
  800b60:	8d 42 d0             	lea    -0x30(%edx),%eax
  800b63:	3c 09                	cmp    $0x9,%al
  800b65:	77 08                	ja     800b6f <strtol+0x91>
			dig = *s - '0';
  800b67:	0f be c2             	movsbl %dl,%eax
  800b6a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800b6d:	eb 1c                	jmp    800b8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b6f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800b72:	3c 19                	cmp    $0x19,%al
  800b74:	77 08                	ja     800b7e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800b76:	0f be c2             	movsbl %dl,%eax
  800b79:	8d 50 a9             	lea    -0x57(%eax),%edx
  800b7c:	eb 0d                	jmp    800b8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b7e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800b81:	3c 19                	cmp    $0x19,%al
  800b83:	77 15                	ja     800b9a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800b85:	0f be c2             	movsbl %dl,%eax
  800b88:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800b8b:	39 f2                	cmp    %esi,%edx
  800b8d:	7d 0b                	jge    800b9a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800b8f:	41                   	inc    %ecx
  800b90:	89 f8                	mov    %edi,%eax
  800b92:	0f af c6             	imul   %esi,%eax
  800b95:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800b98:	eb c2                	jmp    800b5c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800b9a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	74 05                	je     800ba7 <strtol+0xc9>
		*endptr = (char *) s;
  800ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800ba7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bab:	74 04                	je     800bb1 <strtol+0xd3>
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	f7 df                	neg    %edi
}
  800bb1:	89 f8                	mov    %edi,%eax
  800bb3:	83 c4 04             	add    $0x4,%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    
	...

00800bbc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcc:	89 fa                	mov    %edi,%edx
  800bce:	89 f9                	mov    %edi,%ecx
  800bd0:	89 fb                	mov    %edi,%ebx
  800bd2:	89 fe                	mov    %edi,%esi
  800bd4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 04             	sub    $0x4,%esp
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bf 00 00 00 00       	mov    $0x0,%edi
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	89 fb                	mov    %edi,%ebx
  800bf3:	89 fe                	mov    %edi,%esi
  800bf5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf7:	83 c4 04             	add    $0x4,%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c10:	bf 00 00 00 00       	mov    $0x0,%edi
  800c15:	89 f9                	mov    %edi,%ecx
  800c17:	89 fb                	mov    %edi,%ebx
  800c19:	89 fe                	mov    %edi,%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 0d                	push   $0xd
  800c27:	68 7f 26 80 00       	push   $0x80267f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 9c 26 80 00       	push   $0x80269c
  800c33:	e8 6c f6 ff ff       	call   8002a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c57:	be 00 00 00 00       	mov    $0x0,%esi
  800c5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c72:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800c84:	7e 17                	jle    800c9d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 0a                	push   $0xa
  800c8c:	68 7f 26 80 00       	push   $0x80267f
  800c91:	6a 23                	push   $0x23
  800c93:	68 9c 26 80 00       	push   $0x80269c
  800c98:	e8 07 f6 ff ff       	call   8002a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cb4:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800cc6:	7e 17                	jle    800cdf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 09                	push   $0x9
  800cce:	68 7f 26 80 00       	push   $0x80267f
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 9c 26 80 00       	push   $0x80269c
  800cda:	e8 c5 f5 ff ff       	call   8002a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800d00:	89 fb                	mov    %edi,%ebx
  800d02:	89 fe                	mov    %edi,%esi
  800d04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 17                	jle    800d21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 08                	push   $0x8
  800d10:	68 7f 26 80 00       	push   $0x80267f
  800d15:	6a 23                	push   $0x23
  800d17:	68 9c 26 80 00       	push   $0x80269c
  800d1c:	e8 83 f5 ff ff       	call   8002a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d42:	89 fb                	mov    %edi,%ebx
  800d44:	89 fe                	mov    %edi,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 06                	push   $0x6
  800d52:	68 7f 26 80 00       	push   $0x80267f
  800d57:	6a 23                	push   $0x23
  800d59:	68 9c 26 80 00       	push   $0x80269c
  800d5e:	e8 41 f5 ff ff       	call   8002a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d80:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	b8 05 00 00 00       	mov    $0x5,%eax
  800d88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7e 17                	jle    800da5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	50                   	push   %eax
  800d92:	6a 05                	push   $0x5
  800d94:	68 7f 26 80 00       	push   $0x80267f
  800d99:	6a 23                	push   $0x23
  800d9b:	68 9c 26 80 00       	push   $0x80269c
  800da0:	e8 ff f4 ff ff       	call   8002a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800dc4:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc9:	89 fe                	mov    %edi,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 04                	push   $0x4
  800dd7:	68 7f 26 80 00       	push   $0x80267f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 9c 26 80 00       	push   $0x80269c
  800de3:	e8 bc f4 ff ff       	call   8002a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800e00:	89 fa                	mov    %edi,%edx
  800e02:	89 f9                	mov    %edi,%ecx
  800e04:	89 fb                	mov    %edi,%ebx
  800e06:	89 fe                	mov    %edi,%esi
  800e08:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	c9                   	leave  
  800e0e:	c3                   	ret    

00800e0f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e15:	b8 02 00 00 00       	mov    $0x2,%eax
  800e1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e1f:	89 fa                	mov    %edi,%edx
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	89 fb                	mov    %edi,%ebx
  800e25:	89 fe                	mov    %edi,%esi
  800e27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800e3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e44:	89 f9                	mov    %edi,%ecx
  800e46:	89 fb                	mov    %edi,%ebx
  800e48:	89 fe                	mov    %edi,%esi
  800e4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7e 17                	jle    800e67 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 03                	push   $0x3
  800e56:	68 7f 26 80 00       	push   $0x80267f
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 9c 26 80 00       	push   $0x80269c
  800e62:	e8 3d f4 ff ff       	call   8002a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    
	...

00800e70 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e76:	68 aa 26 80 00       	push   $0x8026aa
  800e7b:	68 92 00 00 00       	push   $0x92
  800e80:	68 c0 26 80 00       	push   $0x8026c0
  800e85:	e8 1a f4 ff ff       	call   8002a4 <_panic>

00800e8a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800e93:	68 2b 10 80 00       	push   $0x80102b
  800e98:	e8 5b 0f 00 00       	call   801df8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e9d:	ba 07 00 00 00       	mov    $0x7,%edx
  800ea2:	89 d0                	mov    %edx,%eax
  800ea4:	cd 30                	int    $0x30
  800ea6:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 25                	jne    800ed4 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800eaf:	e8 5b ff ff ff       	call   800e0f <sys_getenvid>
  800eb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ec0:	c1 e0 07             	shl    $0x7,%eax
  800ec3:	29 d0                	sub    %edx,%eax
  800ec5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eca:	a3 04 40 80 00       	mov    %eax,0x804004
  800ecf:	e9 4d 01 00 00       	jmp    801021 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	79 12                	jns    800eea <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800ed8:	50                   	push   %eax
  800ed9:	68 cb 26 80 00       	push   $0x8026cb
  800ede:	6a 77                	push   $0x77
  800ee0:	68 c0 26 80 00       	push   $0x8026c0
  800ee5:	e8 ba f3 ff ff       	call   8002a4 <_panic>
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800eef:	89 d8                	mov    %ebx,%eax
  800ef1:	c1 e8 16             	shr    $0x16,%eax
  800ef4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800efb:	a8 01                	test   $0x1,%al
  800efd:	0f 84 ab 00 00 00    	je     800fae <fork+0x124>
  800f03:	89 da                	mov    %ebx,%edx
  800f05:	c1 ea 0c             	shr    $0xc,%edx
  800f08:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f0f:	a8 01                	test   $0x1,%al
  800f11:	0f 84 97 00 00 00    	je     800fae <fork+0x124>
  800f17:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f1e:	a8 04                	test   $0x4,%al
  800f20:	0f 84 88 00 00 00    	je     800fae <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800f26:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800f2d:	89 d6                	mov    %edx,%esi
  800f2f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800f32:	89 c2                	mov    %eax,%edx
  800f34:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800f3a:	a9 02 08 00 00       	test   $0x802,%eax
  800f3f:	74 0f                	je     800f50 <fork+0xc6>
  800f41:	f6 c4 04             	test   $0x4,%ah
  800f44:	75 0a                	jne    800f50 <fork+0xc6>
		perm &= ~PTE_W;
  800f46:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800f4b:	89 c2                	mov    %eax,%edx
  800f4d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800f50:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800f56:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f59:	83 ec 0c             	sub    $0xc,%esp
  800f5c:	52                   	push   %edx
  800f5d:	56                   	push   %esi
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	6a 00                	push   $0x0
  800f62:	e8 04 fe ff ff       	call   800d6b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800f67:	83 c4 20             	add    $0x20,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 14                	jns    800f82 <fork+0xf8>
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	68 14 27 80 00       	push   $0x802714
  800f76:	6a 52                	push   $0x52
  800f78:	68 c0 26 80 00       	push   $0x8026c0
  800f7d:	e8 22 f3 ff ff       	call   8002a4 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	ff 75 f0             	pushl  -0x10(%ebp)
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 d8 fd ff ff       	call   800d6b <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 14                	jns    800fae <fork+0x124>
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 38 27 80 00       	push   $0x802738
  800fa2:	6a 55                	push   $0x55
  800fa4:	68 c0 26 80 00       	push   $0x8026c0
  800fa9:	e8 f6 f2 ff ff       	call   8002a4 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fba:	0f 85 2f ff ff ff    	jne    800eef <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	6a 07                	push   $0x7
  800fc5:	68 00 f0 bf ee       	push   $0xeebff000
  800fca:	57                   	push   %edi
  800fcb:	e8 dd fd ff ff       	call   800dad <sys_page_alloc>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	79 15                	jns    800fec <fork+0x162>
		panic("sys_page_alloc: %e", r);
  800fd7:	50                   	push   %eax
  800fd8:	68 e9 26 80 00       	push   $0x8026e9
  800fdd:	68 83 00 00 00       	push   $0x83
  800fe2:	68 c0 26 80 00       	push   $0x8026c0
  800fe7:	e8 b8 f2 ff ff       	call   8002a4 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	68 78 1e 80 00       	push   $0x801e78
  800ff4:	57                   	push   %edi
  800ff5:	e8 69 fc ff ff       	call   800c63 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	6a 02                	push   $0x2
  800fff:	57                   	push   %edi
  801000:	e8 e2 fc ff ff       	call   800ce7 <sys_env_set_status>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 15                	jns    801021 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  80100c:	50                   	push   %eax
  80100d:	68 fc 26 80 00       	push   $0x8026fc
  801012:	68 89 00 00 00       	push   $0x89
  801017:	68 c0 26 80 00       	push   $0x8026c0
  80101c:	e8 83 f2 ff ff       	call   8002a4 <_panic>
	return envid;
	//panic("fork not implemented");
}
  801021:	89 f8                	mov    %edi,%eax
  801023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	53                   	push   %ebx
  80102f:	83 ec 04             	sub    $0x4,%esp
  801032:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  801035:	8b 1a                	mov    (%edx),%ebx
  801037:	89 d8                	mov    %ebx,%eax
  801039:	c1 e8 0c             	shr    $0xc,%eax
  80103c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  801043:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801047:	74 05                	je     80104e <pgfault+0x23>
  801049:	f6 c4 08             	test   $0x8,%ah
  80104c:	75 14                	jne    801062 <pgfault+0x37>
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	68 5c 27 80 00       	push   $0x80275c
  801056:	6a 1e                	push   $0x1e
  801058:	68 c0 26 80 00       	push   $0x8026c0
  80105d:	e8 42 f2 ff ff       	call   8002a4 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	6a 07                	push   $0x7
  801067:	68 00 f0 7f 00       	push   $0x7ff000
  80106c:	6a 00                	push   $0x0
  80106e:	e8 3a fd ff ff       	call   800dad <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	79 14                	jns    80108e <pgfault+0x63>
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	68 88 27 80 00       	push   $0x802788
  801082:	6a 2a                	push   $0x2a
  801084:	68 c0 26 80 00       	push   $0x8026c0
  801089:	e8 16 f2 ff ff       	call   8002a4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  80108e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	68 00 10 00 00       	push   $0x1000
  80109c:	53                   	push   %ebx
  80109d:	68 00 f0 7f 00       	push   $0x7ff000
  8010a2:	e8 5d f9 ff ff       	call   800a04 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  8010a7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010ae:	53                   	push   %ebx
  8010af:	6a 00                	push   $0x0
  8010b1:	68 00 f0 7f 00       	push   $0x7ff000
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 ae fc ff ff       	call   800d6b <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  8010bd:	83 c4 20             	add    $0x20,%esp
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	79 14                	jns    8010d8 <pgfault+0xad>
  8010c4:	83 ec 04             	sub    $0x4,%esp
  8010c7:	68 ac 27 80 00       	push   $0x8027ac
  8010cc:	6a 2e                	push   $0x2e
  8010ce:	68 c0 26 80 00       	push   $0x8026c0
  8010d3:	e8 cc f1 ff ff       	call   8002a4 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	68 00 f0 7f 00       	push   $0x7ff000
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 42 fc ff ff       	call   800d29 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 14                	jns    801102 <pgfault+0xd7>
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	68 cc 27 80 00       	push   $0x8027cc
  8010f6:	6a 32                	push   $0x32
  8010f8:	68 c0 26 80 00       	push   $0x8026c0
  8010fd:	e8 a2 f1 ff ff       	call   8002a4 <_panic>
	//panic("pgfault not implemented");
}
  801102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801105:	c9                   	leave  
  801106:	c3                   	ret    
	...

00801108 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	05 00 00 00 30       	add    $0x30000000,%eax
  801113:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	e8 e5 ff ff ff       	call   801108 <fd2num>
  801123:	83 c4 04             	add    $0x4,%esp
  801126:	c1 e0 0c             	shl    $0xc,%eax
  801129:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80112e:	c9                   	leave  
  80112f:	c3                   	ret    

00801130 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	53                   	push   %ebx
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801137:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  80113c:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80113e:	89 d0                	mov    %edx,%eax
  801140:	c1 e8 16             	shr    $0x16,%eax
  801143:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80114a:	a8 01                	test   $0x1,%al
  80114c:	74 10                	je     80115e <fd_alloc+0x2e>
  80114e:	89 d0                	mov    %edx,%eax
  801150:	c1 e8 0c             	shr    $0xc,%eax
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	a8 01                	test   $0x1,%al
  80115c:	75 09                	jne    801167 <fd_alloc+0x37>
			*fd_store = fd;
  80115e:	89 0b                	mov    %ecx,(%ebx)
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
  801165:	eb 19                	jmp    801180 <fd_alloc+0x50>
			return 0;
  801167:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80116d:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801173:	75 c7                	jne    80113c <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801175:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80117b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801180:	5b                   	pop    %ebx
  801181:	c9                   	leave  
  801182:	c3                   	ret    

00801183 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801189:	83 f8 1f             	cmp    $0x1f,%eax
  80118c:	77 35                	ja     8011c3 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80118e:	c1 e0 0c             	shl    $0xc,%eax
  801191:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801197:	89 d0                	mov    %edx,%eax
  801199:	c1 e8 16             	shr    $0x16,%eax
  80119c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a3:	a8 01                	test   $0x1,%al
  8011a5:	74 1c                	je     8011c3 <fd_lookup+0x40>
  8011a7:	89 d0                	mov    %edx,%eax
  8011a9:	c1 e8 0c             	shr    $0xc,%eax
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	a8 01                	test   $0x1,%al
  8011b5:	74 0c                	je     8011c3 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	89 10                	mov    %edx,(%eax)
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c1:	eb 05                	jmp    8011c8 <fd_lookup+0x45>
	return 0;
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 a7 ff ff ff       	call   801183 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 0e                	js     8011f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e9:	89 50 04             	mov    %edx,0x4(%eax)
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801200:	ba 00 00 00 00       	mov    $0x0,%edx
  801205:	eb 0e                	jmp    801215 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801207:	3b 08                	cmp    (%eax),%ecx
  801209:	75 09                	jne    801214 <dev_lookup+0x21>
			*dev = devtab[i];
  80120b:	89 03                	mov    %eax,(%ebx)
  80120d:	b8 00 00 00 00       	mov    $0x0,%eax
  801212:	eb 31                	jmp    801245 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801214:	42                   	inc    %edx
  801215:	8b 04 95 6c 28 80 00 	mov    0x80286c(,%edx,4),%eax
  80121c:	85 c0                	test   %eax,%eax
  80121e:	75 e7                	jne    801207 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801220:	a1 04 40 80 00       	mov    0x804004,%eax
  801225:	8b 40 48             	mov    0x48(%eax),%eax
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	51                   	push   %ecx
  80122c:	50                   	push   %eax
  80122d:	68 f0 27 80 00       	push   $0x8027f0
  801232:	e8 0e f1 ff ff       	call   800345 <cprintf>
	*dev = 0;
  801237:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801242:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801245:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801248:	c9                   	leave  
  801249:	c3                   	ret    

0080124a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	53                   	push   %ebx
  80124e:	83 ec 14             	sub    $0x14,%esp
  801251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	ff 75 08             	pushl  0x8(%ebp)
  80125b:	e8 23 ff ff ff       	call   801183 <fd_lookup>
  801260:	83 c4 08             	add    $0x8,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 55                	js     8012bc <fstat+0x72>
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801271:	ff 30                	pushl  (%eax)
  801273:	e8 7b ff ff ff       	call   8011f3 <dev_lookup>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 3d                	js     8012bc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80127f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801282:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801286:	75 07                	jne    80128f <fstat+0x45>
  801288:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80128d:	eb 2d                	jmp    8012bc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801292:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801299:	00 00 00 
	stat->st_isdir = 0;
  80129c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a3:	00 00 00 
	stat->st_dev = dev;
  8012a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012a9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	53                   	push   %ebx
  8012b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b6:	ff 50 14             	call   *0x14(%eax)
  8012b9:	83 c4 10             	add    $0x10,%esp
}
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	53                   	push   %ebx
  8012d0:	e8 ae fe ff ff       	call   801183 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 5f                	js     80133b <ftruncate+0x7a>
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e6:	ff 30                	pushl  (%eax)
  8012e8:	e8 06 ff ff ff       	call   8011f3 <dev_lookup>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 47                	js     80133b <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fb:	75 21                	jne    80131e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801302:	8b 40 48             	mov    0x48(%eax),%eax
  801305:	83 ec 04             	sub    $0x4,%esp
  801308:	53                   	push   %ebx
  801309:	50                   	push   %eax
  80130a:	68 10 28 80 00       	push   $0x802810
  80130f:	e8 31 f0 ff ff       	call   800345 <cprintf>
  801314:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	eb 1d                	jmp    80133b <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80131e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801321:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801325:	75 07                	jne    80132e <ftruncate+0x6d>
  801327:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132c:	eb 0d                	jmp    80133b <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	50                   	push   %eax
  801335:	ff 52 18             	call   *0x18(%edx)
  801338:	83 c4 10             	add    $0x10,%esp
}
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	53                   	push   %ebx
  801344:	83 ec 14             	sub    $0x14,%esp
  801347:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	53                   	push   %ebx
  80134f:	e8 2f fe ff ff       	call   801183 <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 62                	js     8013bd <write+0x7d>
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	ff 30                	pushl  (%eax)
  801367:	e8 87 fe ff ff       	call   8011f3 <dev_lookup>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 4a                	js     8013bd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80137a:	75 21                	jne    80139d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80137c:	a1 04 40 80 00       	mov    0x804004,%eax
  801381:	8b 40 48             	mov    0x48(%eax),%eax
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	53                   	push   %ebx
  801388:	50                   	push   %eax
  801389:	68 31 28 80 00       	push   $0x802831
  80138e:	e8 b2 ef ff ff       	call   800345 <cprintf>
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	eb 20                	jmp    8013bd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80139d:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8013a0:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8013a4:	75 07                	jne    8013ad <write+0x6d>
  8013a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ab:	eb 10                	jmp    8013bd <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	ff 75 10             	pushl  0x10(%ebp)
  8013b3:	ff 75 0c             	pushl  0xc(%ebp)
  8013b6:	50                   	push   %eax
  8013b7:	ff 52 0c             	call   *0xc(%edx)
  8013ba:	83 c4 10             	add    $0x10,%esp
}
  8013bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c0:	c9                   	leave  
  8013c1:	c3                   	ret    

008013c2 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 14             	sub    $0x14,%esp
  8013c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	53                   	push   %ebx
  8013d1:	e8 ad fd ff ff       	call   801183 <fd_lookup>
  8013d6:	83 c4 08             	add    $0x8,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 67                	js     801444 <read+0x82>
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e7:	ff 30                	pushl  (%eax)
  8013e9:	e8 05 fe ff ff       	call   8011f3 <dev_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 4f                	js     801444 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f8:	8b 42 08             	mov    0x8(%edx),%eax
  8013fb:	83 e0 03             	and    $0x3,%eax
  8013fe:	83 f8 01             	cmp    $0x1,%eax
  801401:	75 21                	jne    801424 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801403:	a1 04 40 80 00       	mov    0x804004,%eax
  801408:	8b 40 48             	mov    0x48(%eax),%eax
  80140b:	83 ec 04             	sub    $0x4,%esp
  80140e:	53                   	push   %ebx
  80140f:	50                   	push   %eax
  801410:	68 4e 28 80 00       	push   $0x80284e
  801415:	e8 2b ef ff ff       	call   800345 <cprintf>
  80141a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	eb 20                	jmp    801444 <read+0x82>
	}
	if (!dev->dev_read)
  801424:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801427:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80142b:	75 07                	jne    801434 <read+0x72>
  80142d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801432:	eb 10                	jmp    801444 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	ff 75 10             	pushl  0x10(%ebp)
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	52                   	push   %edx
  80143e:	ff 50 08             	call   *0x8(%eax)
  801441:	83 c4 10             	add    $0x10,%esp
}
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	57                   	push   %edi
  80144d:	56                   	push   %esi
  80144e:	53                   	push   %ebx
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801455:	8b 75 10             	mov    0x10(%ebp),%esi
  801458:	bb 00 00 00 00       	mov    $0x0,%ebx
  80145d:	eb 21                	jmp    801480 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	89 f0                	mov    %esi,%eax
  801464:	29 d0                	sub    %edx,%eax
  801466:	50                   	push   %eax
  801467:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80146a:	50                   	push   %eax
  80146b:	ff 75 08             	pushl  0x8(%ebp)
  80146e:	e8 4f ff ff ff       	call   8013c2 <read>
		if (m < 0)
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 0e                	js     801488 <readn+0x3f>
			return m;
		if (m == 0)
  80147a:	85 c0                	test   %eax,%eax
  80147c:	74 08                	je     801486 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147e:	01 c3                	add    %eax,%ebx
  801480:	89 da                	mov    %ebx,%edx
  801482:	39 f3                	cmp    %esi,%ebx
  801484:	72 d9                	jb     80145f <readn+0x16>
  801486:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5f                   	pop    %edi
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	83 ec 20             	sub    $0x20,%esp
  801498:	8b 75 08             	mov    0x8(%ebp),%esi
  80149b:	8a 45 0c             	mov    0xc(%ebp),%al
  80149e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	56                   	push   %esi
  8014a6:	e8 5d fc ff ff       	call   801108 <fd2num>
  8014ab:	89 04 24             	mov    %eax,(%esp)
  8014ae:	e8 d0 fc ff ff       	call   801183 <fd_lookup>
  8014b3:	89 c3                	mov    %eax,%ebx
  8014b5:	83 c4 08             	add    $0x8,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 05                	js     8014c1 <fd_close+0x31>
  8014bc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014bf:	74 0d                	je     8014ce <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014c1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014c5:	75 48                	jne    80150f <fd_close+0x7f>
  8014c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014cc:	eb 41                	jmp    80150f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	ff 36                	pushl  (%esi)
  8014d7:	e8 17 fd ff ff       	call   8011f3 <dev_lookup>
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 1c                	js     801501 <fd_close+0x71>
		if (dev->dev_close)
  8014e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e8:	8b 40 10             	mov    0x10(%eax),%eax
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	75 07                	jne    8014f6 <fd_close+0x66>
  8014ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f4:	eb 0b                	jmp    801501 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	56                   	push   %esi
  8014fa:	ff d0                	call   *%eax
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	56                   	push   %esi
  801505:	6a 00                	push   $0x0
  801507:	e8 1d f8 ff ff       	call   800d29 <sys_page_unmap>
  80150c:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80150f:	89 d8                	mov    %ebx,%eax
  801511:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801514:	5b                   	pop    %ebx
  801515:	5e                   	pop    %esi
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	ff 75 08             	pushl  0x8(%ebp)
  801525:	e8 59 fc ff ff       	call   801183 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 10                	js     801541 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	6a 01                	push   $0x1
  801536:	ff 75 fc             	pushl  -0x4(%ebp)
  801539:	e8 52 ff ff ff       	call   801490 <fd_close>
  80153e:	83 c4 10             	add    $0x10,%esp
}
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	6a 00                	push   $0x0
  80154d:	ff 75 08             	pushl  0x8(%ebp)
  801550:	e8 4a 03 00 00       	call   80189f <open>
  801555:	89 c6                	mov    %eax,%esi
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 1b                	js     801579 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	ff 75 0c             	pushl  0xc(%ebp)
  801564:	50                   	push   %eax
  801565:	e8 e0 fc ff ff       	call   80124a <fstat>
  80156a:	89 c3                	mov    %eax,%ebx
	close(fd);
  80156c:	89 34 24             	mov    %esi,(%esp)
  80156f:	e8 a4 ff ff ff       	call   801518 <close>
  801574:	89 de                	mov    %ebx,%esi
  801576:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801579:	89 f0                	mov    %esi,%eax
  80157b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 1c             	sub    $0x1c,%esp
  80158b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 e9 fb ff ff       	call   801183 <fd_lookup>
  80159a:	89 c3                	mov    %eax,%ebx
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	0f 88 bd 00 00 00    	js     801664 <dup+0xe2>
		return r;
	close(newfdnum);
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	57                   	push   %edi
  8015ab:	e8 68 ff ff ff       	call   801518 <close>

	newfd = INDEX2FD(newfdnum);
  8015b0:	89 f8                	mov    %edi,%eax
  8015b2:	c1 e0 0c             	shl    $0xc,%eax
  8015b5:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8015bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8015be:	e8 55 fb ff ff       	call   801118 <fd2data>
  8015c3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015c5:	89 34 24             	mov    %esi,(%esp)
  8015c8:	e8 4b fb ff ff       	call   801118 <fd2data>
  8015cd:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	c1 e8 16             	shr    $0x16,%eax
  8015d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015dc:	83 c4 14             	add    $0x14,%esp
  8015df:	a8 01                	test   $0x1,%al
  8015e1:	74 36                	je     801619 <dup+0x97>
  8015e3:	89 da                	mov    %ebx,%edx
  8015e5:	c1 ea 0c             	shr    $0xc,%edx
  8015e8:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015ef:	a8 01                	test   $0x1,%al
  8015f1:	74 26                	je     801619 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f3:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801602:	50                   	push   %eax
  801603:	ff 75 e0             	pushl  -0x20(%ebp)
  801606:	6a 00                	push   $0x0
  801608:	53                   	push   %ebx
  801609:	6a 00                	push   $0x0
  80160b:	e8 5b f7 ff ff       	call   800d6b <sys_page_map>
  801610:	89 c3                	mov    %eax,%ebx
  801612:	83 c4 20             	add    $0x20,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 30                	js     801649 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801619:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	c1 e8 0c             	shr    $0xc,%eax
  801621:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	25 07 0e 00 00       	and    $0xe07,%eax
  801630:	50                   	push   %eax
  801631:	56                   	push   %esi
  801632:	6a 00                	push   $0x0
  801634:	52                   	push   %edx
  801635:	6a 00                	push   $0x0
  801637:	e8 2f f7 ff ff       	call   800d6b <sys_page_map>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 20             	add    $0x20,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 04                	js     801649 <dup+0xc7>
		goto err;
  801645:	89 fb                	mov    %edi,%ebx
  801647:	eb 1b                	jmp    801664 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	56                   	push   %esi
  80164d:	6a 00                	push   $0x0
  80164f:	e8 d5 f6 ff ff       	call   800d29 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	ff 75 e0             	pushl  -0x20(%ebp)
  80165a:	6a 00                	push   $0x0
  80165c:	e8 c8 f6 ff ff       	call   800d29 <sys_page_unmap>
  801661:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801664:	89 d8                	mov    %ebx,%eax
  801666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	53                   	push   %ebx
  80167e:	e8 95 fe ff ff       	call   801518 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801683:	43                   	inc    %ebx
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	83 fb 20             	cmp    $0x20,%ebx
  80168a:	75 ee                	jne    80167a <close_all+0xc>
		close(i);
}
  80168c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    
  801691:	00 00                	add    %al,(%eax)
	...

00801694 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	56                   	push   %esi
  801698:	53                   	push   %ebx
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80169d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a4:	75 12                	jne    8016b8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	6a 01                	push   $0x1
  8016ab:	e8 f0 07 00 00       	call   801ea0 <ipc_find_env>
  8016b0:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b8:	6a 07                	push   $0x7
  8016ba:	68 00 50 80 00       	push   $0x805000
  8016bf:	53                   	push   %ebx
  8016c0:	ff 35 00 40 80 00    	pushl  0x804000
  8016c6:	e8 1a 08 00 00       	call   801ee5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016cb:	83 c4 0c             	add    $0xc,%esp
  8016ce:	6a 00                	push   $0x0
  8016d0:	56                   	push   %esi
  8016d1:	6a 00                	push   $0x0
  8016d3:	e8 62 08 00 00       	call   801f3a <ipc_recv>
}
  8016d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016db:	5b                   	pop    %ebx
  8016dc:	5e                   	pop    %esi
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ef:	e8 a0 ff ff ff       	call   801694 <fsipc>
}
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801702:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170f:	ba 00 00 00 00       	mov    $0x0,%edx
  801714:	b8 02 00 00 00       	mov    $0x2,%eax
  801719:	e8 76 ff ff ff       	call   801694 <fsipc>
}
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    

00801720 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	8b 40 0c             	mov    0xc(%eax),%eax
  80172c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801731:	ba 00 00 00 00       	mov    $0x0,%edx
  801736:	b8 06 00 00 00       	mov    $0x6,%eax
  80173b:	e8 54 ff ff ff       	call   801694 <fsipc>
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 40 0c             	mov    0xc(%eax),%eax
  801752:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 05 00 00 00       	mov    $0x5,%eax
  801761:	e8 2e ff ff ff       	call   801694 <fsipc>
  801766:	85 c0                	test   %eax,%eax
  801768:	78 2c                	js     801796 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	68 00 50 80 00       	push   $0x805000
  801772:	53                   	push   %ebx
  801773:	e8 1f f1 ff ff       	call   800897 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801778:	a1 80 50 80 00       	mov    0x805080,%eax
  80177d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801783:	a1 84 50 80 00       	mov    0x805084,%eax
  801788:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
  801793:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  801796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	53                   	push   %ebx
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8017b0:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017b6:	53                   	push   %ebx
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	68 08 50 80 00       	push   $0x805008
  8017bf:	e8 40 f2 ff ff       	call   800a04 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8017ce:	e8 c1 fe ff ff       	call   801694 <fsipc>
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 3d                	js     801817 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  8017da:	39 c3                	cmp    %eax,%ebx
  8017dc:	73 19                	jae    8017f7 <devfile_write+0x5c>
  8017de:	68 7c 28 80 00       	push   $0x80287c
  8017e3:	68 83 28 80 00       	push   $0x802883
  8017e8:	68 97 00 00 00       	push   $0x97
  8017ed:	68 98 28 80 00       	push   $0x802898
  8017f2:	e8 ad ea ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  8017f7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017fc:	7e 19                	jle    801817 <devfile_write+0x7c>
  8017fe:	68 a3 28 80 00       	push   $0x8028a3
  801803:	68 83 28 80 00       	push   $0x802883
  801808:	68 98 00 00 00       	push   $0x98
  80180d:	68 98 28 80 00       	push   $0x802898
  801812:	e8 8d ea ff ff       	call   8002a4 <_panic>
	
	return r;
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80182f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 03 00 00 00       	mov    $0x3,%eax
  80183f:	e8 50 fe ff ff       	call   801694 <fsipc>
  801844:	89 c3                	mov    %eax,%ebx
  801846:	85 c0                	test   %eax,%eax
  801848:	78 4c                	js     801896 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  80184a:	39 de                	cmp    %ebx,%esi
  80184c:	73 16                	jae    801864 <devfile_read+0x48>
  80184e:	68 7c 28 80 00       	push   $0x80287c
  801853:	68 83 28 80 00       	push   $0x802883
  801858:	6a 7c                	push   $0x7c
  80185a:	68 98 28 80 00       	push   $0x802898
  80185f:	e8 40 ea ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  801864:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  80186a:	7e 16                	jle    801882 <devfile_read+0x66>
  80186c:	68 a3 28 80 00       	push   $0x8028a3
  801871:	68 83 28 80 00       	push   $0x802883
  801876:	6a 7d                	push   $0x7d
  801878:	68 98 28 80 00       	push   $0x802898
  80187d:	e8 22 ea ff ff       	call   8002a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801882:	83 ec 04             	sub    $0x4,%esp
  801885:	50                   	push   %eax
  801886:	68 00 50 80 00       	push   $0x805000
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	e8 71 f1 ff ff       	call   800a04 <memmove>
  801893:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801896:	89 d8                	mov    %ebx,%eax
  801898:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 1c             	sub    $0x1c,%esp
  8018a7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018aa:	56                   	push   %esi
  8018ab:	e8 b4 ef ff ff       	call   800864 <strlen>
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b8:	7e 07                	jle    8018c1 <open+0x22>
  8018ba:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018bf:	eb 63                	jmp    801924 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c7:	50                   	push   %eax
  8018c8:	e8 63 f8 ff ff       	call   801130 <fd_alloc>
  8018cd:	89 c3                	mov    %eax,%ebx
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 4e                	js     801924 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	56                   	push   %esi
  8018da:	68 00 50 80 00       	push   $0x805000
  8018df:	e8 b3 ef ff ff       	call   800897 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f4:	e8 9b fd ff ff       	call   801694 <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	79 12                	jns    801914 <open+0x75>
		fd_close(fd, 0);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	6a 00                	push   $0x0
  801907:	ff 75 f4             	pushl  -0xc(%ebp)
  80190a:	e8 81 fb ff ff       	call   801490 <fd_close>
		return r;
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	eb 10                	jmp    801924 <open+0x85>
	}

	return fd2num(fd);
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 f4             	pushl  -0xc(%ebp)
  80191a:	e8 e9 f7 ff ff       	call   801108 <fd2num>
  80191f:	89 c3                	mov    %eax,%ebx
  801921:	83 c4 10             	add    $0x10,%esp
}
  801924:	89 d8                	mov    %ebx,%eax
  801926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    
  80192d:	00 00                	add    %al,(%eax)
	...

00801930 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	ff 75 08             	pushl  0x8(%ebp)
  80193e:	e8 d5 f7 ff ff       	call   801118 <fd2data>
  801943:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	68 af 28 80 00       	push   $0x8028af
  80194d:	53                   	push   %ebx
  80194e:	e8 44 ef ff ff       	call   800897 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801953:	8b 46 04             	mov    0x4(%esi),%eax
  801956:	2b 06                	sub    (%esi),%eax
  801958:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80195e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801965:	00 00 00 
	stat->st_dev = &devpipe;
  801968:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80196f:	30 80 00 
	return 0;
}
  801972:	b8 00 00 00 00       	mov    $0x0,%eax
  801977:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5e                   	pop    %esi
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	53                   	push   %ebx
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801988:	53                   	push   %ebx
  801989:	6a 00                	push   $0x0
  80198b:	e8 99 f3 ff ff       	call   800d29 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801990:	89 1c 24             	mov    %ebx,(%esp)
  801993:	e8 80 f7 ff ff       	call   801118 <fd2data>
  801998:	83 c4 08             	add    $0x8,%esp
  80199b:	50                   	push   %eax
  80199c:	6a 00                	push   $0x0
  80199e:	e8 86 f3 ff ff       	call   800d29 <sys_page_unmap>
}
  8019a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a6:	c9                   	leave  
  8019a7:	c3                   	ret    

008019a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	57                   	push   %edi
  8019ac:	56                   	push   %esi
  8019ad:	53                   	push   %ebx
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8019bb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c4:	e8 db 05 00 00       	call   801fa4 <pageref>
  8019c9:	89 c3                	mov    %eax,%ebx
  8019cb:	89 3c 24             	mov    %edi,(%esp)
  8019ce:	e8 d1 05 00 00       	call   801fa4 <pageref>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	39 c3                	cmp    %eax,%ebx
  8019d8:	0f 94 c0             	sete   %al
  8019db:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  8019de:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e4:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  8019e7:	39 c6                	cmp    %eax,%esi
  8019e9:	74 1b                	je     801a06 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  8019eb:	83 f9 01             	cmp    $0x1,%ecx
  8019ee:	75 c6                	jne    8019b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f0:	8b 42 58             	mov    0x58(%edx),%eax
  8019f3:	6a 01                	push   $0x1
  8019f5:	50                   	push   %eax
  8019f6:	56                   	push   %esi
  8019f7:	68 b6 28 80 00       	push   $0x8028b6
  8019fc:	e8 44 e9 ff ff       	call   800345 <cprintf>
  801a01:	83 c4 10             	add    $0x10,%esp
  801a04:	eb b0                	jmp    8019b6 <_pipeisclosed+0xe>
	}
}
  801a06:	89 c8                	mov    %ecx,%eax
  801a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5f                   	pop    %edi
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	57                   	push   %edi
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 18             	sub    $0x18,%esp
  801a19:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a1c:	56                   	push   %esi
  801a1d:	e8 f6 f6 ff ff       	call   801118 <fd2data>
  801a22:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a2a:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	eb 40                	jmp    801a74 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
  801a39:	eb 40                	jmp    801a7b <devpipe_write+0x6b>
  801a3b:	89 da                	mov    %ebx,%edx
  801a3d:	89 f0                	mov    %esi,%eax
  801a3f:	e8 64 ff ff ff       	call   8019a8 <_pipeisclosed>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	75 ec                	jne    801a34 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a48:	e8 a3 f3 ff ff       	call   800df0 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a4d:	8b 53 04             	mov    0x4(%ebx),%edx
  801a50:	8b 03                	mov    (%ebx),%eax
  801a52:	83 c0 20             	add    $0x20,%eax
  801a55:	39 c2                	cmp    %eax,%edx
  801a57:	73 e2                	jae    801a3b <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a59:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a5f:	79 05                	jns    801a66 <devpipe_write+0x56>
  801a61:	4a                   	dec    %edx
  801a62:	83 ca e0             	or     $0xffffffe0,%edx
  801a65:	42                   	inc    %edx
  801a66:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801a69:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801a6c:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a70:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	47                   	inc    %edi
  801a74:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a77:	75 d4                	jne    801a4d <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a79:	89 f8                	mov    %edi,%eax
}
  801a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5f                   	pop    %edi
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	57                   	push   %edi
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	83 ec 18             	sub    $0x18,%esp
  801a8c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a8f:	57                   	push   %edi
  801a90:	e8 83 f6 ff ff       	call   801118 <fd2data>
  801a95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a9d:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb 41                	jmp    801ae8 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801aa7:	89 f0                	mov    %esi,%eax
  801aa9:	eb 44                	jmp    801aef <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aab:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab0:	eb 3d                	jmp    801aef <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ab2:	85 f6                	test   %esi,%esi
  801ab4:	75 f1                	jne    801aa7 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab6:	89 da                	mov    %ebx,%edx
  801ab8:	89 f8                	mov    %edi,%eax
  801aba:	e8 e9 fe ff ff       	call   8019a8 <_pipeisclosed>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	75 e8                	jne    801aab <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ac3:	e8 28 f3 ff ff       	call   800df0 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac8:	8b 03                	mov    (%ebx),%eax
  801aca:	3b 43 04             	cmp    0x4(%ebx),%eax
  801acd:	74 e3                	je     801ab2 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801acf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ad4:	79 05                	jns    801adb <devpipe_read+0x58>
  801ad6:	48                   	dec    %eax
  801ad7:	83 c8 e0             	or     $0xffffffe0,%eax
  801ada:	40                   	inc    %eax
  801adb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801adf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ae2:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801ae5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae7:	46                   	inc    %esi
  801ae8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aeb:	75 db                	jne    801ac8 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aed:	89 f0                	mov    %esi,%eax
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801afd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b00:	50                   	push   %eax
  801b01:	ff 75 08             	pushl  0x8(%ebp)
  801b04:	e8 7a f6 ff ff       	call   801183 <fd_lookup>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 18                	js     801b28 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	ff 75 fc             	pushl  -0x4(%ebp)
  801b16:	e8 fd f5 ff ff       	call   801118 <fd2data>
  801b1b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b20:	e8 83 fe ff ff       	call   8019a8 <_pipeisclosed>
  801b25:	83 c4 10             	add    $0x10,%esp
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	57                   	push   %edi
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	83 ec 28             	sub    $0x28,%esp
  801b33:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b39:	50                   	push   %eax
  801b3a:	e8 f1 f5 ff ff       	call   801130 <fd_alloc>
  801b3f:	89 c3                	mov    %eax,%ebx
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	0f 88 24 01 00 00    	js     801c70 <pipe+0x146>
  801b4c:	83 ec 04             	sub    $0x4,%esp
  801b4f:	68 07 04 00 00       	push   $0x407
  801b54:	ff 75 f0             	pushl  -0x10(%ebp)
  801b57:	6a 00                	push   $0x0
  801b59:	e8 4f f2 ff ff       	call   800dad <sys_page_alloc>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	0f 88 05 01 00 00    	js     801c70 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b71:	50                   	push   %eax
  801b72:	e8 b9 f5 ff ff       	call   801130 <fd_alloc>
  801b77:	89 c3                	mov    %eax,%ebx
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	0f 88 dc 00 00 00    	js     801c60 <pipe+0x136>
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 ec             	pushl  -0x14(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 17 f2 ff ff       	call   800dad <sys_page_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	0f 88 bd 00 00 00    	js     801c60 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba9:	e8 6a f5 ff ff       	call   801118 <fd2data>
  801bae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb0:	83 c4 0c             	add    $0xc,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	50                   	push   %eax
  801bb9:	6a 00                	push   $0x0
  801bbb:	e8 ed f1 ff ff       	call   800dad <sys_page_alloc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	0f 88 83 00 00 00    	js     801c50 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcd:	83 ec 0c             	sub    $0xc,%esp
  801bd0:	ff 75 ec             	pushl  -0x14(%ebp)
  801bd3:	e8 40 f5 ff ff       	call   801118 <fd2data>
  801bd8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bdf:	50                   	push   %eax
  801be0:	6a 00                	push   $0x0
  801be2:	56                   	push   %esi
  801be3:	6a 00                	push   $0x0
  801be5:	e8 81 f1 ff ff       	call   800d6b <sys_page_map>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 20             	add    $0x20,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	78 4f                	js     801c42 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bf3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bfc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c01:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c11:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c16:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	ff 75 f0             	pushl  -0x10(%ebp)
  801c23:	e8 e0 f4 ff ff       	call   801108 <fd2num>
  801c28:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c2a:	83 c4 04             	add    $0x4,%esp
  801c2d:	ff 75 ec             	pushl  -0x14(%ebp)
  801c30:	e8 d3 f4 ff ff       	call   801108 <fd2num>
  801c35:	89 47 04             	mov    %eax,0x4(%edi)
  801c38:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	eb 2e                	jmp    801c70 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	56                   	push   %esi
  801c46:	6a 00                	push   $0x0
  801c48:	e8 dc f0 ff ff       	call   800d29 <sys_page_unmap>
  801c4d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	ff 75 ec             	pushl  -0x14(%ebp)
  801c56:	6a 00                	push   $0x0
  801c58:	e8 cc f0 ff ff       	call   800d29 <sys_page_unmap>
  801c5d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	ff 75 f0             	pushl  -0x10(%ebp)
  801c66:	6a 00                	push   $0x0
  801c68:	e8 bc f0 ff ff       	call   800d29 <sys_page_unmap>
  801c6d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c75:	5b                   	pop    %ebx
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    
	...

00801c7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c8c:	68 c9 28 80 00       	push   $0x8028c9
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	e8 fe eb ff ff       	call   800897 <strcpy>
	return 0;
}
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    

00801ca0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801cac:	be 00 00 00 00       	mov    $0x0,%esi
  801cb1:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801cb7:	eb 2c                	jmp    801ce5 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cbc:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801cbe:	83 fb 7f             	cmp    $0x7f,%ebx
  801cc1:	76 05                	jbe    801cc8 <devcons_write+0x28>
  801cc3:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cc8:	83 ec 04             	sub    $0x4,%esp
  801ccb:	53                   	push   %ebx
  801ccc:	03 45 0c             	add    0xc(%ebp),%eax
  801ccf:	50                   	push   %eax
  801cd0:	57                   	push   %edi
  801cd1:	e8 2e ed ff ff       	call   800a04 <memmove>
		sys_cputs(buf, m);
  801cd6:	83 c4 08             	add    $0x8,%esp
  801cd9:	53                   	push   %ebx
  801cda:	57                   	push   %edi
  801cdb:	e8 fb ee ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce0:	01 de                	add    %ebx,%esi
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cea:	72 cd                	jb     801cb9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5f                   	pop    %edi
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfd:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d00:	6a 01                	push   $0x1
  801d02:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801d05:	50                   	push   %eax
  801d06:	e8 d0 ee ff ff       	call   800bdb <sys_cputs>
  801d0b:	83 c4 10             	add    $0x10,%esp
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d1a:	74 27                	je     801d43 <devcons_read+0x33>
  801d1c:	eb 05                	jmp    801d23 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d1e:	e8 cd f0 ff ff       	call   800df0 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d23:	e8 94 ee ff ff       	call   800bbc <sys_cgetc>
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	74 f0                	je     801d1e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 16                	js     801d48 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d32:	83 f8 04             	cmp    $0x4,%eax
  801d35:	74 0c                	je     801d43 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3a:	88 10                	mov    %dl,(%eax)
  801d3c:	ba 01 00 00 00       	mov    $0x1,%edx
  801d41:	eb 05                	jmp    801d48 <devcons_read+0x38>
	return 1;
  801d43:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d48:	89 d0                	mov    %edx,%eax
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d52:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	e8 d5 f3 ff ff       	call   801130 <fd_alloc>
  801d5b:	83 c4 10             	add    $0x10,%esp
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 3b                	js     801d9d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d62:	83 ec 04             	sub    $0x4,%esp
  801d65:	68 07 04 00 00       	push   $0x407
  801d6a:	ff 75 fc             	pushl  -0x4(%ebp)
  801d6d:	6a 00                	push   $0x0
  801d6f:	e8 39 f0 ff ff       	call   800dad <sys_page_alloc>
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 22                	js     801d9d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d7b:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801d80:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801d83:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	ff 75 fc             	pushl  -0x4(%ebp)
  801d95:	e8 6e f3 ff ff       	call   801108 <fd2num>
  801d9a:	83 c4 10             	add    $0x10,%esp
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	ff 75 08             	pushl  0x8(%ebp)
  801dac:	e8 d2 f3 ff ff       	call   801183 <fd_lookup>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	78 11                	js     801dc9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801dbb:	8b 00                	mov    (%eax),%eax
  801dbd:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801dc3:	0f 94 c0             	sete   %al
  801dc6:	0f b6 c0             	movzbl %al,%eax
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dd1:	6a 01                	push   $0x1
  801dd3:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801dd6:	50                   	push   %eax
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 e4 f5 ff ff       	call   8013c2 <read>
	if (r < 0)
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 0f                	js     801df4 <getchar+0x29>
		return r;
	if (r < 1)
  801de5:	85 c0                	test   %eax,%eax
  801de7:	75 07                	jne    801df0 <getchar+0x25>
  801de9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dee:	eb 04                	jmp    801df4 <getchar+0x29>
		return -E_EOF;
	return c;
  801df0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    
	...

00801df8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dfe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e05:	75 64                	jne    801e6b <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801e07:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0c:	8b 40 48             	mov    0x48(%eax),%eax
  801e0f:	83 ec 04             	sub    $0x4,%esp
  801e12:	6a 07                	push   $0x7
  801e14:	68 00 f0 bf ee       	push   $0xeebff000
  801e19:	50                   	push   %eax
  801e1a:	e8 8e ef ff ff       	call   800dad <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	79 14                	jns    801e3a <set_pgfault_handler+0x42>
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	68 d8 28 80 00       	push   $0x8028d8
  801e2e:	6a 22                	push   $0x22
  801e30:	68 41 29 80 00       	push   $0x802941
  801e35:	e8 6a e4 ff ff       	call   8002a4 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  801e3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3f:	8b 40 48             	mov    0x48(%eax),%eax
  801e42:	83 ec 08             	sub    $0x8,%esp
  801e45:	68 78 1e 80 00       	push   $0x801e78
  801e4a:	50                   	push   %eax
  801e4b:	e8 13 ee ff ff       	call   800c63 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	79 14                	jns    801e6b <set_pgfault_handler+0x73>
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	68 08 29 80 00       	push   $0x802908
  801e5f:	6a 25                	push   $0x25
  801e61:	68 41 29 80 00       	push   $0x802941
  801e66:	e8 39 e4 ff ff       	call   8002a4 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    
  801e75:	00 00                	add    %al,(%eax)
	...

00801e78 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e78:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e79:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e7e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e80:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801e83:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e87:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e8a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801e8e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801e92:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801e94:	83 c4 08             	add    $0x8,%esp
	popal
  801e97:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e98:	83 c4 04             	add    $0x4,%esp
	popfl
  801e9b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e9c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801e9d:	c3                   	ret    
	...

00801ea0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	53                   	push   %ebx
  801ea4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ea7:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801eac:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801eb3:	89 c8                	mov    %ecx,%eax
  801eb5:	c1 e0 07             	shl    $0x7,%eax
  801eb8:	29 d0                	sub    %edx,%eax
  801eba:	89 c2                	mov    %eax,%edx
  801ebc:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801ec2:	8b 40 50             	mov    0x50(%eax),%eax
  801ec5:	39 d8                	cmp    %ebx,%eax
  801ec7:	75 0b                	jne    801ed4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801ec9:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801ecf:	8b 40 40             	mov    0x40(%eax),%eax
  801ed2:	eb 0e                	jmp    801ee2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed4:	41                   	inc    %ecx
  801ed5:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801edb:	75 cf                	jne    801eac <ipc_find_env+0xc>
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ee2:	5b                   	pop    %ebx
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	57                   	push   %edi
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 0c             	sub    $0xc,%esp
  801eee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ef4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ef7:	85 db                	test   %ebx,%ebx
  801ef9:	75 05                	jne    801f00 <ipc_send+0x1b>
  801efb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f00:	56                   	push   %esi
  801f01:	53                   	push   %ebx
  801f02:	57                   	push   %edi
  801f03:	ff 75 08             	pushl  0x8(%ebp)
  801f06:	e8 35 ed ff ff       	call   800c40 <sys_ipc_try_send>
		if (r == 0) {		//success
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	74 20                	je     801f32 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801f12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f15:	75 07                	jne    801f1e <ipc_send+0x39>
			sys_yield();
  801f17:	e8 d4 ee ff ff       	call   800df0 <sys_yield>
  801f1c:	eb e2                	jmp    801f00 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801f1e:	83 ec 04             	sub    $0x4,%esp
  801f21:	68 50 29 80 00       	push   $0x802950
  801f26:	6a 41                	push   $0x41
  801f28:	68 74 29 80 00       	push   $0x802974
  801f2d:	e8 72 e3 ff ff       	call   8002a4 <_panic>
		}
	}
}
  801f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	56                   	push   %esi
  801f3e:	53                   	push   %ebx
  801f3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f45:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	75 05                	jne    801f51 <ipc_recv+0x17>
  801f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801f51:	83 ec 0c             	sub    $0xc,%esp
  801f54:	50                   	push   %eax
  801f55:	e8 a5 ec ff ff       	call   800bff <sys_ipc_recv>
	if (r < 0) {				
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	79 16                	jns    801f77 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801f61:	85 db                	test   %ebx,%ebx
  801f63:	74 06                	je     801f6b <ipc_recv+0x31>
  801f65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801f6b:	85 f6                	test   %esi,%esi
  801f6d:	74 2c                	je     801f9b <ipc_recv+0x61>
  801f6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f75:	eb 24                	jmp    801f9b <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801f77:	85 db                	test   %ebx,%ebx
  801f79:	74 0a                	je     801f85 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801f7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801f80:	8b 40 74             	mov    0x74(%eax),%eax
  801f83:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801f85:	85 f6                	test   %esi,%esi
  801f87:	74 0a                	je     801f93 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801f89:	a1 04 40 80 00       	mov    0x804004,%eax
  801f8e:	8b 40 78             	mov    0x78(%eax),%eax
  801f91:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801f93:	a1 04 40 80 00       	mov    0x804004,%eax
  801f98:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9e:	5b                   	pop    %ebx
  801f9f:	5e                   	pop    %esi
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    
	...

00801fa4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faa:	89 d0                	mov    %edx,%eax
  801fac:	c1 e8 16             	shr    $0x16,%eax
  801faf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fb6:	a8 01                	test   $0x1,%al
  801fb8:	74 20                	je     801fda <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fba:	89 d0                	mov    %edx,%eax
  801fbc:	c1 e8 0c             	shr    $0xc,%eax
  801fbf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc6:	a8 01                	test   $0x1,%al
  801fc8:	74 10                	je     801fda <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fca:	c1 e8 0c             	shr    $0xc,%eax
  801fcd:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fd4:	ef 
  801fd5:	0f b7 c0             	movzwl %ax,%eax
  801fd8:	eb 05                	jmp    801fdf <pageref+0x3b>
  801fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    
  801fe1:	00 00                	add    %al,(%eax)
	...

00801fe4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	83 ec 28             	sub    $0x28,%esp
  801fec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801ff3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffd:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802000:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802003:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802005:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  802007:	8b 45 08             	mov    0x8(%ebp),%eax
  80200a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  80200d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802010:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802013:	85 ff                	test   %edi,%edi
  802015:	75 21                	jne    802038 <__udivdi3+0x54>
    {
      if (d0 > n1)
  802017:	39 d1                	cmp    %edx,%ecx
  802019:	76 49                	jbe    802064 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80201b:	f7 f1                	div    %ecx
  80201d:	89 c1                	mov    %eax,%ecx
  80201f:	31 c0                	xor    %eax,%eax
  802021:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802024:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  802027:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80202a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80202d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802030:	83 c4 28             	add    $0x28,%esp
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	c9                   	leave  
  802036:	c3                   	ret    
  802037:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802038:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80203b:	0f 87 97 00 00 00    	ja     8020d8 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802041:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802044:	83 f0 1f             	xor    $0x1f,%eax
  802047:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80204a:	75 34                	jne    802080 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80204c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80204f:	72 08                	jb     802059 <__udivdi3+0x75>
  802051:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802054:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802057:	77 7f                	ja     8020d8 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802059:	b9 01 00 00 00       	mov    $0x1,%ecx
  80205e:	31 c0                	xor    %eax,%eax
  802060:	eb c2                	jmp    802024 <__udivdi3+0x40>
  802062:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802067:	85 c0                	test   %eax,%eax
  802069:	74 79                	je     8020e4 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80206b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	f7 f1                	div    %ecx
  802072:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802074:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802077:	f7 f1                	div    %ecx
  802079:	89 c1                	mov    %eax,%ecx
  80207b:	89 f0                	mov    %esi,%eax
  80207d:	eb a5                	jmp    802024 <__udivdi3+0x40>
  80207f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802080:	b8 20 00 00 00       	mov    $0x20,%eax
  802085:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802088:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80208b:	89 fa                	mov    %edi,%edx
  80208d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802090:	d3 e2                	shl    %cl,%edx
  802092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802095:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802098:	d3 e8                	shr    %cl,%eax
  80209a:	89 d7                	mov    %edx,%edi
  80209c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80209e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8020a1:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8020a4:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020a9:	d3 e0                	shl    %cl,%eax
  8020ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8020ae:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8020b1:	d3 ea                	shr    %cl,%edx
  8020b3:	09 d0                	or     %edx,%eax
  8020b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8020bb:	d3 ea                	shr    %cl,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 d7                	mov    %edx,%edi
  8020c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8020c4:	f7 e6                	mul    %esi
  8020c6:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020c8:	39 d7                	cmp    %edx,%edi
  8020ca:	72 38                	jb     802104 <__udivdi3+0x120>
  8020cc:	74 27                	je     8020f5 <__udivdi3+0x111>
  8020ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020d1:	31 c0                	xor    %eax,%eax
  8020d3:	e9 4c ff ff ff       	jmp    802024 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020d8:	31 c9                	xor    %ecx,%ecx
  8020da:	31 c0                	xor    %eax,%eax
  8020dc:	e9 43 ff ff ff       	jmp    802024 <__udivdi3+0x40>
  8020e1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e9:	31 d2                	xor    %edx,%edx
  8020eb:	f7 75 f4             	divl   -0xc(%ebp)
  8020ee:	89 c1                	mov    %eax,%ecx
  8020f0:	e9 76 ff ff ff       	jmp    80206b <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020f8:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8020fb:	d3 e0                	shl    %cl,%eax
  8020fd:	39 f0                	cmp    %esi,%eax
  8020ff:	73 cd                	jae    8020ce <__udivdi3+0xea>
  802101:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802104:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802107:	49                   	dec    %ecx
  802108:	31 c0                	xor    %eax,%eax
  80210a:	e9 15 ff ff ff       	jmp    802024 <__udivdi3+0x40>
	...

00802110 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	57                   	push   %edi
  802114:	56                   	push   %esi
  802115:	83 ec 30             	sub    $0x30,%esp
  802118:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80211f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802126:	8b 75 08             	mov    0x8(%ebp),%esi
  802129:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80212c:	8b 45 10             	mov    0x10(%ebp),%eax
  80212f:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802132:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802135:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802137:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  80213a:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  80213d:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802140:	85 d2                	test   %edx,%edx
  802142:	75 1c                	jne    802160 <__umoddi3+0x50>
    {
      if (d0 > n1)
  802144:	89 fa                	mov    %edi,%edx
  802146:	39 f8                	cmp    %edi,%eax
  802148:	0f 86 c2 00 00 00    	jbe    802210 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80214e:	89 f0                	mov    %esi,%eax
  802150:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  802152:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802155:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80215c:	eb 12                	jmp    802170 <__umoddi3+0x60>
  80215e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802160:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802163:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802166:	76 18                	jbe    802180 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802168:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  80216b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80216e:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802170:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802173:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802176:	83 c4 30             	add    $0x30,%esp
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	c9                   	leave  
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802180:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802184:	83 f0 1f             	xor    $0x1f,%eax
  802187:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80218a:	0f 84 ac 00 00 00    	je     80223c <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802190:	b8 20 00 00 00       	mov    $0x20,%eax
  802195:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802198:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80219b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80219e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021a1:	d3 e2                	shl    %cl,%edx
  8021a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021a6:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021a9:	d3 e8                	shr    %cl,%eax
  8021ab:	89 d6                	mov    %edx,%esi
  8021ad:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  8021af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021b2:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021b5:	d3 e0                	shl    %cl,%eax
  8021b7:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021ba:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8021bd:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c2:	d3 e0                	shl    %cl,%eax
  8021c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021c7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021ca:	d3 ea                	shr    %cl,%edx
  8021cc:	09 d0                	or     %edx,%eax
  8021ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8021d1:	d3 ea                	shr    %cl,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8021d8:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021db:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8021de:	0f 82 8d 00 00 00    	jb     802271 <__umoddi3+0x161>
  8021e4:	0f 84 91 00 00 00    	je     80227b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021ed:	29 c7                	sub    %eax,%edi
  8021ef:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021f1:	89 f2                	mov    %esi,%edx
  8021f3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021f6:	d3 e2                	shl    %cl,%edx
  8021f8:	89 f8                	mov    %edi,%eax
  8021fa:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021fd:	d3 e8                	shr    %cl,%eax
  8021ff:	09 c2                	or     %eax,%edx
  802201:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  802204:	d3 ee                	shr    %cl,%esi
  802206:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  802209:	e9 62 ff ff ff       	jmp    802170 <__umoddi3+0x60>
  80220e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802210:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802213:	85 c0                	test   %eax,%eax
  802215:	74 15                	je     80222c <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802217:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80221a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80221d:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80221f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802222:	f7 f1                	div    %ecx
  802224:	e9 29 ff ff ff       	jmp    802152 <__umoddi3+0x42>
  802229:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80222c:	b8 01 00 00 00       	mov    $0x1,%eax
  802231:	31 d2                	xor    %edx,%edx
  802233:	f7 75 ec             	divl   -0x14(%ebp)
  802236:	89 c1                	mov    %eax,%ecx
  802238:	eb dd                	jmp    802217 <__umoddi3+0x107>
  80223a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80223c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  802242:	72 19                	jb     80225d <__umoddi3+0x14d>
  802244:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802247:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80224a:	76 11                	jbe    80225d <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80224c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80224f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  802252:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802255:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802258:	e9 13 ff ff ff       	jmp    802170 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80225d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802263:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802266:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802269:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80226c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80226f:	eb db                	jmp    80224c <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802271:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802274:	19 f2                	sbb    %esi,%edx
  802276:	e9 6f ff ff ff       	jmp    8021ea <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80227b:	39 c7                	cmp    %eax,%edi
  80227d:	72 f2                	jb     802271 <__umoddi3+0x161>
  80227f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802282:	e9 63 ff ff ff       	jmp    8021ea <__umoddi3+0xda>
