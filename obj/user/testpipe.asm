
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 83 02 00 00       	call   8002b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 60 	movl   $0x802360,0x803004
  800043:	23 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	50                   	push   %eax
  80004a:	e8 4f 1b 00 00       	call   801b9e <pipe>
  80004f:	89 c3                	mov    %eax,%ebx
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x36>
		panic("pipe: %e", i);
  800058:	50                   	push   %eax
  800059:	68 6c 23 80 00       	push   $0x80236c
  80005e:	6a 0e                	push   $0xe
  800060:	68 75 23 80 00       	push   $0x802375
  800065:	e8 ae 02 00 00       	call   800318 <_panic>

	if ((pid = fork()) < 0)
  80006a:	e8 8f 0e 00 00       	call   800efe <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x53>
		panic("fork: %e", i);
  800075:	53                   	push   %ebx
  800076:	68 85 23 80 00       	push   $0x802385
  80007b:	6a 11                	push   $0x11
  80007d:	68 75 23 80 00       	push   $0x802375
  800082:	e8 91 02 00 00       	call   800318 <_panic>

	if (pid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 85 b8 00 00 00    	jne    800147 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	8b 40 48             	mov    0x48(%eax),%eax
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	ff 75 90             	pushl  -0x70(%ebp)
  80009d:	50                   	push   %eax
  80009e:	68 8e 23 80 00       	push   $0x80238e
  8000a3:	e8 11 03 00 00       	call   8003b9 <cprintf>
		close(p[1]);
  8000a8:	83 c4 04             	add    $0x4,%esp
  8000ab:	ff 75 90             	pushl  -0x70(%ebp)
  8000ae:	e8 d9 14 00 00       	call   80158c <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b8:	8b 40 48             	mov    0x48(%eax),%eax
  8000bb:	83 c4 0c             	add    $0xc,%esp
  8000be:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c1:	50                   	push   %eax
  8000c2:	68 ab 23 80 00       	push   $0x8023ab
  8000c7:	e8 ed 02 00 00       	call   8003b9 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cc:	83 c4 0c             	add    $0xc,%esp
  8000cf:	6a 63                	push   $0x63
  8000d1:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d4:	50                   	push   %eax
  8000d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d8:	e8 e0 13 00 00       	call   8014bd <readn>
  8000dd:	89 c3                	mov    %eax,%ebx
		if (i < 0)
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <umain+0xc4>
			panic("read: %e", i);
  8000e6:	50                   	push   %eax
  8000e7:	68 c8 23 80 00       	push   $0x8023c8
  8000ec:	6a 19                	push   $0x19
  8000ee:	68 75 23 80 00       	push   $0x802375
  8000f3:	e8 20 02 00 00       	call   800318 <_panic>
		buf[i] = 0;
  8000f8:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	ff 35 00 30 80 00    	pushl  0x803000
  800106:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800109:	50                   	push   %eax
  80010a:	e8 8f 08 00 00       	call   80099e <strcmp>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	75 12                	jne    800128 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	68 d1 23 80 00       	push   $0x8023d1
  80011e:	e8 96 02 00 00       	call   8003b9 <cprintf>
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	eb 15                	jmp    80013d <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	53                   	push   %ebx
  800130:	68 ed 23 80 00       	push   $0x8023ed
  800135:	e8 7f 02 00 00       	call   8003b9 <cprintf>
  80013a:	83 c4 10             	add    $0x10,%esp
		exit();
  80013d:	e8 c2 01 00 00       	call   800304 <exit>
  800142:	e9 94 00 00 00       	jmp    8001db <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800147:	a1 04 40 80 00       	mov    0x804004,%eax
  80014c:	8b 40 48             	mov    0x48(%eax),%eax
  80014f:	83 ec 04             	sub    $0x4,%esp
  800152:	ff 75 8c             	pushl  -0x74(%ebp)
  800155:	50                   	push   %eax
  800156:	68 8e 23 80 00       	push   $0x80238e
  80015b:	e8 59 02 00 00       	call   8003b9 <cprintf>
		close(p[0]);
  800160:	83 c4 04             	add    $0x4,%esp
  800163:	ff 75 8c             	pushl  -0x74(%ebp)
  800166:	e8 21 14 00 00       	call   80158c <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016b:	a1 04 40 80 00       	mov    0x804004,%eax
  800170:	8b 40 48             	mov    0x48(%eax),%eax
  800173:	83 c4 0c             	add    $0xc,%esp
  800176:	ff 75 90             	pushl  -0x70(%ebp)
  800179:	50                   	push   %eax
  80017a:	68 00 24 80 00       	push   $0x802400
  80017f:	e8 35 02 00 00       	call   8003b9 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800184:	83 c4 04             	add    $0x4,%esp
  800187:	ff 35 00 30 80 00    	pushl  0x803000
  80018d:	e8 46 07 00 00       	call   8008d8 <strlen>
  800192:	83 c4 0c             	add    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	ff 35 00 30 80 00    	pushl  0x803000
  80019c:	ff 75 90             	pushl  -0x70(%ebp)
  80019f:	e8 10 12 00 00       	call   8013b4 <write>
  8001a4:	89 c3                	mov    %eax,%ebx
  8001a6:	83 c4 04             	add    $0x4,%esp
  8001a9:	ff 35 00 30 80 00    	pushl  0x803000
  8001af:	e8 24 07 00 00       	call   8008d8 <strlen>
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	39 c3                	cmp    %eax,%ebx
  8001b9:	74 12                	je     8001cd <umain+0x199>
			panic("write: %e", i);
  8001bb:	53                   	push   %ebx
  8001bc:	68 1d 24 80 00       	push   $0x80241d
  8001c1:	6a 25                	push   $0x25
  8001c3:	68 75 23 80 00       	push   $0x802375
  8001c8:	e8 4b 01 00 00       	call   800318 <_panic>
		close(p[1]);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	ff 75 90             	pushl  -0x70(%ebp)
  8001d3:	e8 b4 13 00 00       	call   80158c <close>
  8001d8:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	56                   	push   %esi
  8001df:	e8 0c 1b 00 00       	call   801cf0 <wait>

	binaryname = "pipewriteeof";
  8001e4:	c7 05 04 30 80 00 27 	movl   $0x802427,0x803004
  8001eb:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ee:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 a5 19 00 00       	call   801b9e <pipe>
  8001f9:	89 c3                	mov    %eax,%ebx
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	85 c0                	test   %eax,%eax
  800200:	79 12                	jns    800214 <umain+0x1e0>
		panic("pipe: %e", i);
  800202:	50                   	push   %eax
  800203:	68 6c 23 80 00       	push   $0x80236c
  800208:	6a 2c                	push   $0x2c
  80020a:	68 75 23 80 00       	push   $0x802375
  80020f:	e8 04 01 00 00       	call   800318 <_panic>

	if ((pid = fork()) < 0)
  800214:	e8 e5 0c 00 00       	call   800efe <fork>
  800219:	89 c6                	mov    %eax,%esi
  80021b:	85 c0                	test   %eax,%eax
  80021d:	79 12                	jns    800231 <umain+0x1fd>
		panic("fork: %e", i);
  80021f:	53                   	push   %ebx
  800220:	68 85 23 80 00       	push   $0x802385
  800225:	6a 2f                	push   $0x2f
  800227:	68 75 23 80 00       	push   $0x802375
  80022c:	e8 e7 00 00 00       	call   800318 <_panic>

	if (pid == 0) {
  800231:	85 c0                	test   %eax,%eax
  800233:	75 4a                	jne    80027f <umain+0x24b>
		close(p[0]);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 8c             	pushl  -0x74(%ebp)
  80023b:	e8 4c 13 00 00       	call   80158c <close>
  800240:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	68 34 24 80 00       	push   $0x802434
  80024b:	e8 69 01 00 00       	call   8003b9 <cprintf>
			if (write(p[1], "x", 1) != 1)
  800250:	83 c4 0c             	add    $0xc,%esp
  800253:	6a 01                	push   $0x1
  800255:	68 36 24 80 00       	push   $0x802436
  80025a:	ff 75 90             	pushl  -0x70(%ebp)
  80025d:	e8 52 11 00 00       	call   8013b4 <write>
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	83 f8 01             	cmp    $0x1,%eax
  800268:	74 d9                	je     800243 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 38 24 80 00       	push   $0x802438
  800272:	e8 42 01 00 00       	call   8003b9 <cprintf>
		exit();
  800277:	e8 88 00 00 00       	call   800304 <exit>
  80027c:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	ff 75 8c             	pushl  -0x74(%ebp)
  800285:	e8 02 13 00 00       	call   80158c <close>
	close(p[1]);
  80028a:	83 c4 04             	add    $0x4,%esp
  80028d:	ff 75 90             	pushl  -0x70(%ebp)
  800290:	e8 f7 12 00 00       	call   80158c <close>
	wait(pid);
  800295:	89 34 24             	mov    %esi,(%esp)
  800298:	e8 53 1a 00 00       	call   801cf0 <wait>

	cprintf("pipe tests passed\n");
  80029d:	c7 04 24 55 24 80 00 	movl   $0x802455,(%esp)
  8002a4:	e8 10 01 00 00       	call   8003b9 <cprintf>
  8002a9:	83 c4 10             	add    $0x10,%esp
}
  8002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    
	...

008002b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8002bf:	e8 bf 0b 00 00       	call   800e83 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8002c4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002d0:	c1 e0 07             	shl    $0x7,%eax
  8002d3:	29 d0                	sub    %edx,%eax
  8002d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002da:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002df:	85 f6                	test   %esi,%esi
  8002e1:	7e 07                	jle    8002ea <libmain+0x36>
		binaryname = argv[0];
  8002e3:	8b 03                	mov    (%ebx),%eax
  8002e5:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	53                   	push   %ebx
  8002ee:	56                   	push   %esi
  8002ef:	e8 40 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002f4:	e8 0b 00 00 00       	call   800304 <exit>
  8002f9:	83 c4 10             	add    $0x10,%esp
}
  8002fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	c9                   	leave  
  800302:	c3                   	ret    
	...

00800304 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80030a:	6a 00                	push   $0x0
  80030c:	e8 91 0b 00 00       	call   800ea2 <sys_env_destroy>
  800311:	83 c4 10             	add    $0x10,%esp
}
  800314:	c9                   	leave  
  800315:	c3                   	ret    
	...

00800318 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	53                   	push   %ebx
  80031c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80031f:	8d 45 14             	lea    0x14(%ebp),%eax
  800322:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800325:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80032b:	e8 53 0b 00 00       	call   800e83 <sys_getenvid>
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	ff 75 0c             	pushl  0xc(%ebp)
  800336:	ff 75 08             	pushl  0x8(%ebp)
  800339:	53                   	push   %ebx
  80033a:	50                   	push   %eax
  80033b:	68 b8 24 80 00       	push   $0x8024b8
  800340:	e8 74 00 00 00       	call   8003b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800345:	83 c4 18             	add    $0x18,%esp
  800348:	ff 75 f8             	pushl  -0x8(%ebp)
  80034b:	ff 75 10             	pushl  0x10(%ebp)
  80034e:	e8 15 00 00 00       	call   800368 <vcprintf>
	cprintf("\n");
  800353:	c7 04 24 a9 23 80 00 	movl   $0x8023a9,(%esp)
  80035a:	e8 5a 00 00 00       	call   8003b9 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800362:	cc                   	int3   
  800363:	eb fd                	jmp    800362 <_panic+0x4a>
  800365:	00 00                	add    %al,(%eax)
	...

00800368 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800371:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800378:	00 00 00 
	b.cnt = 0;
  80037b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800382:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800391:	50                   	push   %eax
  800392:	68 d0 03 80 00       	push   $0x8003d0
  800397:	e8 70 01 00 00       	call   80050c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039c:	83 c4 08             	add    $0x8,%esp
  80039f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003a5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 9e 08 00 00       	call   800c4f <sys_cputs>
  8003b1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003bf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8003c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8003c5:	50                   	push   %eax
  8003c6:	ff 75 08             	pushl  0x8(%ebp)
  8003c9:	e8 9a ff ff ff       	call   800368 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 04             	sub    $0x4,%esp
  8003d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003da:	8b 03                	mov    (%ebx),%eax
  8003dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003e3:	40                   	inc    %eax
  8003e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003eb:	75 1a                	jne    800407 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	68 ff 00 00 00       	push   $0xff
  8003f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f8:	50                   	push   %eax
  8003f9:	e8 51 08 00 00       	call   800c4f <sys_cputs>
		b->idx = 0;
  8003fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800404:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800407:	ff 43 04             	incl   0x4(%ebx)
}
  80040a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    
	...

00800410 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	57                   	push   %edi
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
  800416:	83 ec 1c             	sub    $0x1c,%esp
  800419:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80041c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	8b 55 0c             	mov    0xc(%ebp),%edx
  800425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800428:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80042b:	8b 55 10             	mov    0x10(%ebp),%edx
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800431:	89 d6                	mov    %edx,%esi
  800433:	bf 00 00 00 00       	mov    $0x0,%edi
  800438:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80043b:	72 04                	jb     800441 <printnum+0x31>
  80043d:	39 c2                	cmp    %eax,%edx
  80043f:	77 3f                	ja     800480 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80044a:	50                   	push   %eax
  80044b:	52                   	push   %edx
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	ff 75 e4             	pushl  -0x1c(%ebp)
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	e8 54 1c 00 00       	call   8020b0 <__udivdi3>
  80045c:	83 c4 18             	add    $0x18,%esp
  80045f:	52                   	push   %edx
  800460:	50                   	push   %eax
  800461:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800464:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800467:	e8 a4 ff ff ff       	call   800410 <printnum>
  80046c:	83 c4 20             	add    $0x20,%esp
  80046f:	eb 14                	jmp    800485 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 e8             	pushl  -0x18(%ebp)
  800477:	ff 75 18             	pushl  0x18(%ebp)
  80047a:	ff 55 ec             	call   *-0x14(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800480:	4b                   	dec    %ebx
  800481:	85 db                	test   %ebx,%ebx
  800483:	7f ec                	jg     800471 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 e8             	pushl  -0x18(%ebp)
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	57                   	push   %edi
  80048f:	56                   	push   %esi
  800490:	ff 75 e4             	pushl  -0x1c(%ebp)
  800493:	ff 75 e0             	pushl  -0x20(%ebp)
  800496:	e8 41 1d 00 00       	call   8021dc <__umoddi3>
  80049b:	83 c4 14             	add    $0x14,%esp
  80049e:	0f be 80 db 24 80 00 	movsbl 0x8024db(%eax),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 55 ec             	call   *-0x14(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
}
  8004ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5f                   	pop    %edi
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004b9:	83 fa 01             	cmp    $0x1,%edx
  8004bc:	7e 0e                	jle    8004cc <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004be:	8b 10                	mov    (%eax),%edx
  8004c0:	8d 42 08             	lea    0x8(%edx),%eax
  8004c3:	89 01                	mov    %eax,(%ecx)
  8004c5:	8b 02                	mov    (%edx),%eax
  8004c7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ca:	eb 22                	jmp    8004ee <getuint+0x3a>
	else if (lflag)
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 10                	je     8004e0 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 42 04             	lea    0x4(%edx),%eax
  8004d5:	89 01                	mov    %eax,(%ecx)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004de:	eb 0e                	jmp    8004ee <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	8d 42 04             	lea    0x4(%edx),%eax
  8004e5:	89 01                	mov    %eax,(%ecx)
  8004e7:	8b 02                	mov    (%edx),%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8004f6:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8004f9:	8b 11                	mov    (%ecx),%edx
  8004fb:	3b 51 04             	cmp    0x4(%ecx),%edx
  8004fe:	73 0a                	jae    80050a <sprintputch+0x1a>
		*b->buf++ = ch;
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	88 02                	mov    %al,(%edx)
  800505:	8d 42 01             	lea    0x1(%edx),%eax
  800508:	89 01                	mov    %eax,(%ecx)
}
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 3c             	sub    $0x3c,%esp
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80051b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80051e:	eb 1a                	jmp    80053a <vprintfmt+0x2e>
  800520:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800523:	eb 15                	jmp    80053a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800525:	84 c0                	test   %al,%al
  800527:	0f 84 15 03 00 00    	je     800842 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	57                   	push   %edi
  800531:	0f b6 c0             	movzbl %al,%eax
  800534:	50                   	push   %eax
  800535:	ff d6                	call   *%esi
  800537:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053a:	8a 03                	mov    (%ebx),%al
  80053c:	43                   	inc    %ebx
  80053d:	3c 25                	cmp    $0x25,%al
  80053f:	75 e4                	jne    800525 <vprintfmt+0x19>
  800541:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800548:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80054f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800556:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80055d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800561:	eb 0a                	jmp    80056d <vprintfmt+0x61>
  800563:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80056a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8a 03                	mov    (%ebx),%al
  80056f:	0f b6 d0             	movzbl %al,%edx
  800572:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800575:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800578:	83 e8 23             	sub    $0x23,%eax
  80057b:	3c 55                	cmp    $0x55,%al
  80057d:	0f 87 9c 02 00 00    	ja     80081f <vprintfmt+0x313>
  800583:	0f b6 c0             	movzbl %al,%eax
  800586:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  80058d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800591:	eb d7                	jmp    80056a <vprintfmt+0x5e>
  800593:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800597:	eb d1                	jmp    80056a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800599:	89 d9                	mov    %ebx,%ecx
  80059b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005a5:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005a8:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005af:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005b3:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005b4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005b7:	83 f8 09             	cmp    $0x9,%eax
  8005ba:	77 21                	ja     8005dd <vprintfmt+0xd1>
  8005bc:	eb e4                	jmp    8005a2 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005be:	8b 55 14             	mov    0x14(%ebp),%edx
  8005c1:	8d 42 04             	lea    0x4(%edx),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c7:	8b 12                	mov    (%edx),%edx
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	eb 12                	jmp    8005e0 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8005ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d2:	79 96                	jns    80056a <vprintfmt+0x5e>
  8005d4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005db:	eb 8d                	jmp    80056a <vprintfmt+0x5e>
  8005dd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e4:	79 84                	jns    80056a <vprintfmt+0x5e>
  8005e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005f3:	e9 72 ff ff ff       	jmp    80056a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f8:	ff 45 d4             	incl   -0x2c(%ebp)
  8005fb:	e9 6a ff ff ff       	jmp    80056a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800600:	8b 55 14             	mov    0x14(%ebp),%edx
  800603:	8d 42 04             	lea    0x4(%edx),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	57                   	push   %edi
  80060d:	ff 32                	pushl  (%edx)
  80060f:	ff d6                	call   *%esi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	e9 07 ff ff ff       	jmp    800520 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800619:	8b 55 14             	mov    0x14(%ebp),%edx
  80061c:	8d 42 04             	lea    0x4(%edx),%eax
  80061f:	89 45 14             	mov    %eax,0x14(%ebp)
  800622:	8b 02                	mov    (%edx),%eax
  800624:	85 c0                	test   %eax,%eax
  800626:	79 02                	jns    80062a <vprintfmt+0x11e>
  800628:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062a:	83 f8 0f             	cmp    $0xf,%eax
  80062d:	7f 0b                	jg     80063a <vprintfmt+0x12e>
  80062f:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800636:	85 d2                	test   %edx,%edx
  800638:	75 15                	jne    80064f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80063a:	50                   	push   %eax
  80063b:	68 ec 24 80 00       	push   $0x8024ec
  800640:	57                   	push   %edi
  800641:	56                   	push   %esi
  800642:	e8 6e 02 00 00       	call   8008b5 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	e9 d1 fe ff ff       	jmp    800520 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80064f:	52                   	push   %edx
  800650:	68 f5 29 80 00       	push   $0x8029f5
  800655:	57                   	push   %edi
  800656:	56                   	push   %esi
  800657:	e8 59 02 00 00       	call   8008b5 <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	e9 bc fe ff ff       	jmp    800520 <vprintfmt+0x14>
  800664:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800667:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80066a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066d:	8b 55 14             	mov    0x14(%ebp),%edx
  800670:	8d 42 04             	lea    0x4(%edx),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
  800676:	8b 1a                	mov    (%edx),%ebx
  800678:	85 db                	test   %ebx,%ebx
  80067a:	75 05                	jne    800681 <vprintfmt+0x175>
  80067c:	bb f5 24 80 00       	mov    $0x8024f5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800681:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800685:	7e 66                	jle    8006ed <vprintfmt+0x1e1>
  800687:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80068b:	74 60                	je     8006ed <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	51                   	push   %ecx
  800691:	53                   	push   %ebx
  800692:	e8 57 02 00 00       	call   8008ee <strnlen>
  800697:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80069a:	29 c1                	sub    %eax,%ecx
  80069c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006a6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006a9:	eb 0f                	jmp    8006ba <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	57                   	push   %edi
  8006af:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b4:	ff 4d d8             	decl   -0x28(%ebp)
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006be:	7f eb                	jg     8006ab <vprintfmt+0x19f>
  8006c0:	eb 2b                	jmp    8006ed <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c2:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8006c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c9:	74 15                	je     8006e0 <vprintfmt+0x1d4>
  8006cb:	8d 42 e0             	lea    -0x20(%edx),%eax
  8006ce:	83 f8 5e             	cmp    $0x5e,%eax
  8006d1:	76 0d                	jbe    8006e0 <vprintfmt+0x1d4>
					putch('?', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	57                   	push   %edi
  8006d7:	6a 3f                	push   $0x3f
  8006d9:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 0a                	jmp    8006ea <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	57                   	push   %edi
  8006e4:	52                   	push   %edx
  8006e5:	ff d6                	call   *%esi
  8006e7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	ff 4d d8             	decl   -0x28(%ebp)
  8006ed:	8a 03                	mov    (%ebx),%al
  8006ef:	43                   	inc    %ebx
  8006f0:	84 c0                	test   %al,%al
  8006f2:	74 1b                	je     80070f <vprintfmt+0x203>
  8006f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f8:	78 c8                	js     8006c2 <vprintfmt+0x1b6>
  8006fa:	ff 4d dc             	decl   -0x24(%ebp)
  8006fd:	79 c3                	jns    8006c2 <vprintfmt+0x1b6>
  8006ff:	eb 0e                	jmp    80070f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	6a 20                	push   $0x20
  800707:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800709:	ff 4d d8             	decl   -0x28(%ebp)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800713:	7f ec                	jg     800701 <vprintfmt+0x1f5>
  800715:	e9 06 fe ff ff       	jmp    800520 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80071a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80071e:	7e 10                	jle    800730 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800720:	8b 55 14             	mov    0x14(%ebp),%edx
  800723:	8d 42 08             	lea    0x8(%edx),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
  800729:	8b 02                	mov    (%edx),%eax
  80072b:	8b 52 04             	mov    0x4(%edx),%edx
  80072e:	eb 20                	jmp    800750 <vprintfmt+0x244>
	else if (lflag)
  800730:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800734:	74 0e                	je     800744 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	99                   	cltd   
  800742:	eb 0c                	jmp    800750 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800750:	89 d1                	mov    %edx,%ecx
  800752:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800754:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800757:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	78 0a                	js     800768 <vprintfmt+0x25c>
  80075e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800763:	e9 89 00 00 00       	jmp    8007f1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	57                   	push   %edi
  80076c:	6a 2d                	push   $0x2d
  80076e:	ff d6                	call   *%esi
				num = -(long long) num;
  800770:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800773:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800776:	f7 da                	neg    %edx
  800778:	83 d1 00             	adc    $0x0,%ecx
  80077b:	f7 d9                	neg    %ecx
  80077d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb 6a                	jmp    8007f1 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
  80078a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078d:	e8 22 fd ff ff       	call   8004b4 <getuint>
  800792:	89 d1                	mov    %edx,%ecx
  800794:	89 c2                	mov    %eax,%edx
  800796:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80079b:	eb 54                	jmp    8007f1 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007a3:	e8 0c fd ff ff       	call   8004b4 <getuint>
  8007a8:	89 d1                	mov    %edx,%ecx
  8007aa:	89 c2                	mov    %eax,%edx
  8007ac:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007b1:	eb 3e                	jmp    8007f1 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	6a 30                	push   $0x30
  8007b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	57                   	push   %edi
  8007bf:	6a 78                	push   $0x78
  8007c1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007c3:	8b 55 14             	mov    0x14(%ebp),%edx
  8007c6:	8d 42 04             	lea    0x4(%edx),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cc:	8b 12                	mov    (%edx),%edx
  8007ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d3:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 14                	jmp    8007f1 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e3:	e8 cc fc ff ff       	call   8004b4 <getuint>
  8007e8:	89 d1                	mov    %edx,%ecx
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f1:	83 ec 0c             	sub    $0xc,%esp
  8007f4:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8007fc:	53                   	push   %ebx
  8007fd:	51                   	push   %ecx
  8007fe:	52                   	push   %edx
  8007ff:	89 fa                	mov    %edi,%edx
  800801:	89 f0                	mov    %esi,%eax
  800803:	e8 08 fc ff ff       	call   800410 <printnum>
			break;
  800808:	83 c4 20             	add    $0x20,%esp
  80080b:	e9 10 fd ff ff       	jmp    800520 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	57                   	push   %edi
  800814:	52                   	push   %edx
  800815:	ff d6                	call   *%esi
			break;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	e9 01 fd ff ff       	jmp    800520 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	57                   	push   %edi
  800823:	6a 25                	push   $0x25
  800825:	ff d6                	call   *%esi
  800827:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80082a:	83 ea 02             	sub    $0x2,%edx
  80082d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800830:	8a 02                	mov    (%edx),%al
  800832:	4a                   	dec    %edx
  800833:	3c 25                	cmp    $0x25,%al
  800835:	75 f9                	jne    800830 <vprintfmt+0x324>
  800837:	83 c2 02             	add    $0x2,%edx
  80083a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80083d:	e9 de fc ff ff       	jmp    800520 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800842:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800845:	5b                   	pop    %ebx
  800846:	5e                   	pop    %esi
  800847:	5f                   	pop    %edi
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 18             	sub    $0x18,%esp
  800850:	8b 55 08             	mov    0x8(%ebp),%edx
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800856:	85 d2                	test   %edx,%edx
  800858:	74 37                	je     800891 <vsnprintf+0x47>
  80085a:	85 c0                	test   %eax,%eax
  80085c:	7e 33                	jle    800891 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800865:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800869:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80086c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086f:	ff 75 14             	pushl  0x14(%ebp)
  800872:	ff 75 10             	pushl  0x10(%ebp)
  800875:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800878:	50                   	push   %eax
  800879:	68 f0 04 80 00       	push   $0x8004f0
  80087e:	e8 89 fc ff ff       	call   80050c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800886:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800889:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	eb 05                	jmp    800896 <vsnprintf+0x4c>
  800891:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089e:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008a4:	50                   	push   %eax
  8008a5:	ff 75 10             	pushl  0x10(%ebp)
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	e8 97 ff ff ff       	call   80084a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8008bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008be:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008c1:	50                   	push   %eax
  8008c2:	ff 75 10             	pushl  0x10(%ebp)
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	ff 75 08             	pushl  0x8(%ebp)
  8008cb:	e8 3c fc ff ff       	call   80050c <vprintfmt>
	va_end(ap);
  8008d0:	83 c4 10             	add    $0x10,%esp
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    
  8008d5:	00 00                	add    %al,(%eax)
	...

008008d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 55 08             	mov    0x8(%ebp),%edx
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e3:	eb 01                	jmp    8008e6 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8008e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008ea:	75 f9                	jne    8008e5 <strlen+0xd>
		n++;
	return n;
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 01                	jmp    8008ff <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8008fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ff:	39 d0                	cmp    %edx,%eax
  800901:	74 06                	je     800909 <strnlen+0x1b>
  800903:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800907:	75 f5                	jne    8008fe <strnlen+0x10>
		n++;
	return n;
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800911:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800914:	8a 01                	mov    (%ecx),%al
  800916:	88 02                	mov    %al,(%edx)
  800918:	42                   	inc    %edx
  800919:	41                   	inc    %ecx
  80091a:	84 c0                	test   %al,%al
  80091c:	75 f6                	jne    800914 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092a:	53                   	push   %ebx
  80092b:	e8 a8 ff ff ff       	call   8008d8 <strlen>
	strcpy(dst + len, src);
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800936:	50                   	push   %eax
  800937:	e8 cf ff ff ff       	call   80090b <strcpy>
	return dst;
}
  80093c:	89 d8                	mov    %ebx,%eax
  80093e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 75 08             	mov    0x8(%ebp),%esi
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800951:	b9 00 00 00 00       	mov    $0x0,%ecx
  800956:	eb 0c                	jmp    800964 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800958:	8a 02                	mov    (%edx),%al
  80095a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095d:	80 3a 01             	cmpb   $0x1,(%edx)
  800960:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800963:	41                   	inc    %ecx
  800964:	39 d9                	cmp    %ebx,%ecx
  800966:	75 f0                	jne    800958 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800968:	89 f0                	mov    %esi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 75 08             	mov    0x8(%ebp),%esi
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	85 c9                	test   %ecx,%ecx
  80097e:	75 04                	jne    800984 <strlcpy+0x16>
  800980:	89 f0                	mov    %esi,%eax
  800982:	eb 14                	jmp    800998 <strlcpy+0x2a>
  800984:	89 f0                	mov    %esi,%eax
  800986:	eb 04                	jmp    80098c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800988:	88 10                	mov    %dl,(%eax)
  80098a:	40                   	inc    %eax
  80098b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80098c:	49                   	dec    %ecx
  80098d:	74 06                	je     800995 <strlcpy+0x27>
  80098f:	8a 13                	mov    (%ebx),%dl
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f3                	jne    800988 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800995:	c6 00 00             	movb   $0x0,(%eax)
  800998:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a7:	eb 02                	jmp    8009ab <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009a9:	42                   	inc    %edx
  8009aa:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ab:	8a 02                	mov    (%edx),%al
  8009ad:	84 c0                	test   %al,%al
  8009af:	74 04                	je     8009b5 <strcmp+0x17>
  8009b1:	3a 01                	cmp    (%ecx),%al
  8009b3:	74 f4                	je     8009a9 <strcmp+0xb>
  8009b5:	0f b6 c0             	movzbl %al,%eax
  8009b8:	0f b6 11             	movzbl (%ecx),%edx
  8009bb:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009cc:	eb 03                	jmp    8009d1 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009ce:	4a                   	dec    %edx
  8009cf:	41                   	inc    %ecx
  8009d0:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d1:	85 d2                	test   %edx,%edx
  8009d3:	75 07                	jne    8009dc <strncmp+0x1d>
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	eb 14                	jmp    8009f0 <strncmp+0x31>
  8009dc:	8a 01                	mov    (%ecx),%al
  8009de:	84 c0                	test   %al,%al
  8009e0:	74 04                	je     8009e6 <strncmp+0x27>
  8009e2:	3a 03                	cmp    (%ebx),%al
  8009e4:	74 e8                	je     8009ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e6:	0f b6 d0             	movzbl %al,%edx
  8009e9:	0f b6 03             	movzbl (%ebx),%eax
  8009ec:	29 c2                	sub    %eax,%edx
  8009ee:	89 d0                	mov    %edx,%eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009fc:	eb 05                	jmp    800a03 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 0c                	je     800a0e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	40                   	inc    %eax
  800a03:	8a 10                	mov    (%eax),%dl
  800a05:	84 d2                	test   %dl,%dl
  800a07:	75 f5                	jne    8009fe <strchr+0xb>
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a19:	eb 05                	jmp    800a20 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a1b:	38 ca                	cmp    %cl,%dl
  800a1d:	74 07                	je     800a26 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1f:	40                   	inc    %eax
  800a20:	8a 10                	mov    (%eax),%dl
  800a22:	84 d2                	test   %dl,%dl
  800a24:	75 f5                	jne    800a1b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	74 36                	je     800a71 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a41:	75 29                	jne    800a6c <memset+0x44>
  800a43:	f6 c3 03             	test   $0x3,%bl
  800a46:	75 24                	jne    800a6c <memset+0x44>
		c &= 0xFF;
  800a48:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a4b:	89 d6                	mov    %edx,%esi
  800a4d:	c1 e6 08             	shl    $0x8,%esi
  800a50:	89 d0                	mov    %edx,%eax
  800a52:	c1 e0 18             	shl    $0x18,%eax
  800a55:	89 d1                	mov    %edx,%ecx
  800a57:	c1 e1 10             	shl    $0x10,%ecx
  800a5a:	09 c8                	or     %ecx,%eax
  800a5c:	09 c2                	or     %eax,%edx
  800a5e:	89 f0                	mov    %esi,%eax
  800a60:	09 d0                	or     %edx,%eax
  800a62:	89 d9                	mov    %ebx,%ecx
  800a64:	c1 e9 02             	shr    $0x2,%ecx
  800a67:	fc                   	cld    
  800a68:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6a:	eb 05                	jmp    800a71 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6c:	89 d9                	mov    %ebx,%ecx
  800a6e:	fc                   	cld    
  800a6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a71:	89 f8                	mov    %edi,%eax
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5f                   	pop    %edi
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a86:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a88:	39 c6                	cmp    %eax,%esi
  800a8a:	73 36                	jae    800ac2 <memmove+0x4a>
  800a8c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8f:	39 d0                	cmp    %edx,%eax
  800a91:	73 2f                	jae    800ac2 <memmove+0x4a>
		s += n;
		d += n;
  800a93:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	f6 c2 03             	test   $0x3,%dl
  800a99:	75 1b                	jne    800ab6 <memmove+0x3e>
  800a9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa1:	75 13                	jne    800ab6 <memmove+0x3e>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	75 0e                	jne    800ab6 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800aa8:	8d 7e fc             	lea    -0x4(%esi),%edi
  800aab:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aae:	c1 e9 02             	shr    $0x2,%ecx
  800ab1:	fd                   	std    
  800ab2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab4:	eb 09                	jmp    800abf <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab6:	8d 7e ff             	lea    -0x1(%esi),%edi
  800ab9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800abc:	fd                   	std    
  800abd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abf:	fc                   	cld    
  800ac0:	eb 20                	jmp    800ae2 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac8:	75 15                	jne    800adf <memmove+0x67>
  800aca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad0:	75 0d                	jne    800adf <memmove+0x67>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 08                	jne    800adf <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
  800ada:	fc                   	cld    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb 03                	jmp    800ae2 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800adf:	fc                   	cld    
  800ae0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	e8 81 ff ff ff       	call   800a78 <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	53                   	push   %ebx
  800afd:	83 ec 04             	sub    $0x4,%esp
  800b00:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b09:	eb 1b                	jmp    800b26 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b0b:	8a 1a                	mov    (%edx),%bl
  800b0d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b10:	8a 19                	mov    (%ecx),%bl
  800b12:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b15:	74 0d                	je     800b24 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b17:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b1b:	0f b6 c3             	movzbl %bl,%eax
  800b1e:	29 c2                	sub    %eax,%edx
  800b20:	89 d0                	mov    %edx,%eax
  800b22:	eb 0d                	jmp    800b31 <memcmp+0x38>
		s1++, s2++;
  800b24:	42                   	inc    %edx
  800b25:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b26:	48                   	dec    %eax
  800b27:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b2a:	75 df                	jne    800b0b <memcmp+0x12>
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b31:	83 c4 04             	add    $0x4,%esp
  800b34:	5b                   	pop    %ebx
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	03 55 10             	add    0x10(%ebp),%edx
  800b45:	eb 05                	jmp    800b4c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b47:	38 08                	cmp    %cl,(%eax)
  800b49:	74 05                	je     800b50 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4b:	40                   	inc    %eax
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	72 f7                	jb     800b47 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	83 ec 04             	sub    $0x4,%esp
  800b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5e:	8b 75 10             	mov    0x10(%ebp),%esi
  800b61:	eb 01                	jmp    800b64 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800b63:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b64:	8a 01                	mov    (%ecx),%al
  800b66:	3c 20                	cmp    $0x20,%al
  800b68:	74 f9                	je     800b63 <strtol+0x11>
  800b6a:	3c 09                	cmp    $0x9,%al
  800b6c:	74 f5                	je     800b63 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b6e:	3c 2b                	cmp    $0x2b,%al
  800b70:	75 0a                	jne    800b7c <strtol+0x2a>
		s++;
  800b72:	41                   	inc    %ecx
  800b73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b7a:	eb 17                	jmp    800b93 <strtol+0x41>
	else if (*s == '-')
  800b7c:	3c 2d                	cmp    $0x2d,%al
  800b7e:	74 09                	je     800b89 <strtol+0x37>
  800b80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b87:	eb 0a                	jmp    800b93 <strtol+0x41>
		s++, neg = 1;
  800b89:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b8c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b93:	85 f6                	test   %esi,%esi
  800b95:	74 05                	je     800b9c <strtol+0x4a>
  800b97:	83 fe 10             	cmp    $0x10,%esi
  800b9a:	75 1a                	jne    800bb6 <strtol+0x64>
  800b9c:	8a 01                	mov    (%ecx),%al
  800b9e:	3c 30                	cmp    $0x30,%al
  800ba0:	75 10                	jne    800bb2 <strtol+0x60>
  800ba2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba6:	75 0a                	jne    800bb2 <strtol+0x60>
		s += 2, base = 16;
  800ba8:	83 c1 02             	add    $0x2,%ecx
  800bab:	be 10 00 00 00       	mov    $0x10,%esi
  800bb0:	eb 04                	jmp    800bb6 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bb2:	85 f6                	test   %esi,%esi
  800bb4:	74 07                	je     800bbd <strtol+0x6b>
  800bb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bbb:	eb 13                	jmp    800bd0 <strtol+0x7e>
  800bbd:	3c 30                	cmp    $0x30,%al
  800bbf:	74 07                	je     800bc8 <strtol+0x76>
  800bc1:	be 0a 00 00 00       	mov    $0xa,%esi
  800bc6:	eb ee                	jmp    800bb6 <strtol+0x64>
		s++, base = 8;
  800bc8:	41                   	inc    %ecx
  800bc9:	be 08 00 00 00       	mov    $0x8,%esi
  800bce:	eb e6                	jmp    800bb6 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd0:	8a 11                	mov    (%ecx),%dl
  800bd2:	88 d3                	mov    %dl,%bl
  800bd4:	8d 42 d0             	lea    -0x30(%edx),%eax
  800bd7:	3c 09                	cmp    $0x9,%al
  800bd9:	77 08                	ja     800be3 <strtol+0x91>
			dig = *s - '0';
  800bdb:	0f be c2             	movsbl %dl,%eax
  800bde:	8d 50 d0             	lea    -0x30(%eax),%edx
  800be1:	eb 1c                	jmp    800bff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be3:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800be6:	3c 19                	cmp    $0x19,%al
  800be8:	77 08                	ja     800bf2 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800bea:	0f be c2             	movsbl %dl,%eax
  800bed:	8d 50 a9             	lea    -0x57(%eax),%edx
  800bf0:	eb 0d                	jmp    800bff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bf2:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800bf5:	3c 19                	cmp    $0x19,%al
  800bf7:	77 15                	ja     800c0e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800bf9:	0f be c2             	movsbl %dl,%eax
  800bfc:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800bff:	39 f2                	cmp    %esi,%edx
  800c01:	7d 0b                	jge    800c0e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c03:	41                   	inc    %ecx
  800c04:	89 f8                	mov    %edi,%eax
  800c06:	0f af c6             	imul   %esi,%eax
  800c09:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c0c:	eb c2                	jmp    800bd0 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c0e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xc9>
		*endptr = (char *) s;
  800c16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c19:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c1f:	74 04                	je     800c25 <strtol+0xd3>
  800c21:	89 c7                	mov    %eax,%edi
  800c23:	f7 df                	neg    %edi
}
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	83 c4 04             	add    $0x4,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    
	...

00800c30 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c40:	89 fa                	mov    %edi,%edx
  800c42:	89 f9                	mov    %edi,%ecx
  800c44:	89 fb                	mov    %edi,%ebx
  800c46:	89 fe                	mov    %edi,%esi
  800c48:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 04             	sub    $0x4,%esp
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	89 f8                	mov    %edi,%eax
  800c65:	89 fb                	mov    %edi,%ebx
  800c67:	89 fe                	mov    %edi,%esi
  800c69:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6b:	83 c4 04             	add    $0x4,%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 0c             	sub    $0xc,%esp
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c84:	bf 00 00 00 00       	mov    $0x0,%edi
  800c89:	89 f9                	mov    %edi,%ecx
  800c8b:	89 fb                	mov    %edi,%ebx
  800c8d:	89 fe                	mov    %edi,%esi
  800c8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 0d                	push   $0xd
  800c9b:	68 df 27 80 00       	push   $0x8027df
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 fc 27 80 00       	push   $0x8027fc
  800ca7:	e8 6c f6 ff ff       	call   800318 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ceb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cf0:	89 fb                	mov    %edi,%ebx
  800cf2:	89 fe                	mov    %edi,%esi
  800cf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 17                	jle    800d11 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 0a                	push   $0xa
  800d00:	68 df 27 80 00       	push   $0x8027df
  800d05:	6a 23                	push   $0x23
  800d07:	68 fc 27 80 00       	push   $0x8027fc
  800d0c:	e8 07 f6 ff ff       	call   800318 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d32:	89 fb                	mov    %edi,%ebx
  800d34:	89 fe                	mov    %edi,%esi
  800d36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 17                	jle    800d53 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 09                	push   $0x9
  800d42:	68 df 27 80 00       	push   $0x8027df
  800d47:	6a 23                	push   $0x23
  800d49:	68 fc 27 80 00       	push   $0x8027fc
  800d4e:	e8 c5 f5 ff ff       	call   800318 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d74:	89 fb                	mov    %edi,%ebx
  800d76:	89 fe                	mov    %edi,%esi
  800d78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 17                	jle    800d95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 08                	push   $0x8
  800d84:	68 df 27 80 00       	push   $0x8027df
  800d89:	6a 23                	push   $0x23
  800d8b:	68 fc 27 80 00       	push   $0x8027fc
  800d90:	e8 83 f5 ff ff       	call   800318 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	b8 06 00 00 00       	mov    $0x6,%eax
  800db1:	bf 00 00 00 00       	mov    $0x0,%edi
  800db6:	89 fb                	mov    %edi,%ebx
  800db8:	89 fe                	mov    %edi,%esi
  800dba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 17                	jle    800dd7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	50                   	push   %eax
  800dc4:	6a 06                	push   $0x6
  800dc6:	68 df 27 80 00       	push   $0x8027df
  800dcb:	6a 23                	push   $0x23
  800dcd:	68 fc 27 80 00       	push   $0x8027fc
  800dd2:	e8 41 f5 ff ff       	call   800318 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	c9                   	leave  
  800dde:	c3                   	ret    

00800ddf <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df7:	b8 05 00 00 00       	mov    $0x5,%eax
  800dfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7e 17                	jle    800e19 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	50                   	push   %eax
  800e06:	6a 05                	push   $0x5
  800e08:	68 df 27 80 00       	push   $0x8027df
  800e0d:	6a 23                	push   $0x23
  800e0f:	68 fc 27 80 00       	push   $0x8027fc
  800e14:	e8 ff f4 ff ff       	call   800318 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	57                   	push   %edi
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	b8 04 00 00 00       	mov    $0x4,%eax
  800e38:	bf 00 00 00 00       	mov    $0x0,%edi
  800e3d:	89 fe                	mov    %edi,%esi
  800e3f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e41:	85 c0                	test   %eax,%eax
  800e43:	7e 17                	jle    800e5c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 04                	push   $0x4
  800e4b:	68 df 27 80 00       	push   $0x8027df
  800e50:	6a 23                	push   $0x23
  800e52:	68 fc 27 80 00       	push   $0x8027fc
  800e57:	e8 bc f4 ff ff       	call   800318 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	57                   	push   %edi
  800e68:	56                   	push   %esi
  800e69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e6f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e74:	89 fa                	mov    %edi,%edx
  800e76:	89 f9                	mov    %edi,%ecx
  800e78:	89 fb                	mov    %edi,%ebx
  800e7a:	89 fe                	mov    %edi,%esi
  800e7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	b8 02 00 00 00       	mov    $0x2,%eax
  800e8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e93:	89 fa                	mov    %edi,%edx
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	89 fb                	mov    %edi,%ebx
  800e99:	89 fe                	mov    %edi,%esi
  800e9b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb8:	89 f9                	mov    %edi,%ecx
  800eba:	89 fb                	mov    %edi,%ebx
  800ebc:	89 fe                	mov    %edi,%esi
  800ebe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	7e 17                	jle    800edb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	50                   	push   %eax
  800ec8:	6a 03                	push   $0x3
  800eca:	68 df 27 80 00       	push   $0x8027df
  800ecf:	6a 23                	push   $0x23
  800ed1:	68 fc 27 80 00       	push   $0x8027fc
  800ed6:	e8 3d f4 ff ff       	call   800318 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    
	...

00800ee4 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800eea:	68 0a 28 80 00       	push   $0x80280a
  800eef:	68 92 00 00 00       	push   $0x92
  800ef4:	68 20 28 80 00       	push   $0x802820
  800ef9:	e8 1a f4 ff ff       	call   800318 <_panic>

00800efe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  800f07:	68 9f 10 80 00       	push   $0x80109f
  800f0c:	e8 b3 0f 00 00       	call   801ec4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f11:	ba 07 00 00 00       	mov    $0x7,%edx
  800f16:	89 d0                	mov    %edx,%eax
  800f18:	cd 30                	int    $0x30
  800f1a:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	75 25                	jne    800f48 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  800f23:	e8 5b ff ff ff       	call   800e83 <sys_getenvid>
  800f28:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f34:	c1 e0 07             	shl    $0x7,%eax
  800f37:	29 d0                	sub    %edx,%eax
  800f39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3e:	a3 04 40 80 00       	mov    %eax,0x804004
  800f43:	e9 4d 01 00 00       	jmp    801095 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	79 12                	jns    800f5e <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  800f4c:	50                   	push   %eax
  800f4d:	68 2b 28 80 00       	push   $0x80282b
  800f52:	6a 77                	push   $0x77
  800f54:	68 20 28 80 00       	push   $0x802820
  800f59:	e8 ba f3 ff ff       	call   800318 <_panic>
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 16             	shr    $0x16,%eax
  800f68:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6f:	a8 01                	test   $0x1,%al
  800f71:	0f 84 ab 00 00 00    	je     801022 <fork+0x124>
  800f77:	89 da                	mov    %ebx,%edx
  800f79:	c1 ea 0c             	shr    $0xc,%edx
  800f7c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f83:	a8 01                	test   $0x1,%al
  800f85:	0f 84 97 00 00 00    	je     801022 <fork+0x124>
  800f8b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f92:	a8 04                	test   $0x4,%al
  800f94:	0f 84 88 00 00 00    	je     801022 <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  800f9a:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  800fa1:	89 d6                	mov    %edx,%esi
  800fa3:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  800fae:	a9 02 08 00 00       	test   $0x802,%eax
  800fb3:	74 0f                	je     800fc4 <fork+0xc6>
  800fb5:	f6 c4 04             	test   $0x4,%ah
  800fb8:	75 0a                	jne    800fc4 <fork+0xc6>
		perm &= ~PTE_W;
  800fba:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  800fbf:	89 c2                	mov    %eax,%edx
  800fc1:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  800fc4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fca:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	52                   	push   %edx
  800fd1:	56                   	push   %esi
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 04 fe ff ff       	call   800ddf <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  800fdb:	83 c4 20             	add    $0x20,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 14                	jns    800ff6 <fork+0xf8>
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 74 28 80 00       	push   $0x802874
  800fea:	6a 52                	push   $0x52
  800fec:	68 20 28 80 00       	push   $0x802820
  800ff1:	e8 22 f3 ff ff       	call   800318 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	ff 75 f0             	pushl  -0x10(%ebp)
  800ffc:	56                   	push   %esi
  800ffd:	6a 00                	push   $0x0
  800fff:	56                   	push   %esi
  801000:	6a 00                	push   $0x0
  801002:	e8 d8 fd ff ff       	call   800ddf <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  801007:	83 c4 20             	add    $0x20,%esp
  80100a:	85 c0                	test   %eax,%eax
  80100c:	79 14                	jns    801022 <fork+0x124>
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	68 98 28 80 00       	push   $0x802898
  801016:	6a 55                	push   $0x55
  801018:	68 20 28 80 00       	push   $0x802820
  80101d:	e8 f6 f2 ff ff       	call   800318 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801022:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801028:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80102e:	0f 85 2f ff ff ff    	jne    800f63 <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	6a 07                	push   $0x7
  801039:	68 00 f0 bf ee       	push   $0xeebff000
  80103e:	57                   	push   %edi
  80103f:	e8 dd fd ff ff       	call   800e21 <sys_page_alloc>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 15                	jns    801060 <fork+0x162>
		panic("sys_page_alloc: %e", r);
  80104b:	50                   	push   %eax
  80104c:	68 49 28 80 00       	push   $0x802849
  801051:	68 83 00 00 00       	push   $0x83
  801056:	68 20 28 80 00       	push   $0x802820
  80105b:	e8 b8 f2 ff ff       	call   800318 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	68 44 1f 80 00       	push   $0x801f44
  801068:	57                   	push   %edi
  801069:	e8 69 fc ff ff       	call   800cd7 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	6a 02                	push   $0x2
  801073:	57                   	push   %edi
  801074:	e8 e2 fc ff ff       	call   800d5b <sys_env_set_status>
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	85 c0                	test   %eax,%eax
  80107e:	79 15                	jns    801095 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  801080:	50                   	push   %eax
  801081:	68 5c 28 80 00       	push   $0x80285c
  801086:	68 89 00 00 00       	push   $0x89
  80108b:	68 20 28 80 00       	push   $0x802820
  801090:	e8 83 f2 ff ff       	call   800318 <_panic>
	return envid;
	//panic("fork not implemented");
}
  801095:	89 f8                	mov    %edi,%eax
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  8010a9:	8b 1a                	mov    (%edx),%ebx
  8010ab:	89 d8                	mov    %ebx,%eax
  8010ad:	c1 e8 0c             	shr    $0xc,%eax
  8010b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  8010b7:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  8010bb:	74 05                	je     8010c2 <pgfault+0x23>
  8010bd:	f6 c4 08             	test   $0x8,%ah
  8010c0:	75 14                	jne    8010d6 <pgfault+0x37>
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	68 bc 28 80 00       	push   $0x8028bc
  8010ca:	6a 1e                	push   $0x1e
  8010cc:	68 20 28 80 00       	push   $0x802820
  8010d1:	e8 42 f2 ff ff       	call   800318 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  8010d6:	83 ec 04             	sub    $0x4,%esp
  8010d9:	6a 07                	push   $0x7
  8010db:	68 00 f0 7f 00       	push   $0x7ff000
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 3a fd ff ff       	call   800e21 <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 14                	jns    801102 <pgfault+0x63>
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	68 e8 28 80 00       	push   $0x8028e8
  8010f6:	6a 2a                	push   $0x2a
  8010f8:	68 20 28 80 00       	push   $0x802820
  8010fd:	e8 16 f2 ff ff       	call   800318 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  801102:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	68 00 10 00 00       	push   $0x1000
  801110:	53                   	push   %ebx
  801111:	68 00 f0 7f 00       	push   $0x7ff000
  801116:	e8 5d f9 ff ff       	call   800a78 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  80111b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801122:	53                   	push   %ebx
  801123:	6a 00                	push   $0x0
  801125:	68 00 f0 7f 00       	push   $0x7ff000
  80112a:	6a 00                	push   $0x0
  80112c:	e8 ae fc ff ff       	call   800ddf <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  801131:	83 c4 20             	add    $0x20,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	79 14                	jns    80114c <pgfault+0xad>
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	68 0c 29 80 00       	push   $0x80290c
  801140:	6a 2e                	push   $0x2e
  801142:	68 20 28 80 00       	push   $0x802820
  801147:	e8 cc f1 ff ff       	call   800318 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	68 00 f0 7f 00       	push   $0x7ff000
  801154:	6a 00                	push   $0x0
  801156:	e8 42 fc ff ff       	call   800d9d <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	79 14                	jns    801176 <pgfault+0xd7>
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	68 2c 29 80 00       	push   $0x80292c
  80116a:	6a 32                	push   $0x32
  80116c:	68 20 28 80 00       	push   $0x802820
  801171:	e8 a2 f1 ff ff       	call   800318 <_panic>
	//panic("pgfault not implemented");
}
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    
	...

0080117c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	05 00 00 00 30       	add    $0x30000000,%eax
  801187:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118f:	ff 75 08             	pushl  0x8(%ebp)
  801192:	e8 e5 ff ff ff       	call   80117c <fd2num>
  801197:	83 c4 04             	add    $0x4,%esp
  80119a:	c1 e0 0c             	shl    $0xc,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011ab:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  8011b0:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	c1 e8 16             	shr    $0x16,%eax
  8011b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011be:	a8 01                	test   $0x1,%al
  8011c0:	74 10                	je     8011d2 <fd_alloc+0x2e>
  8011c2:	89 d0                	mov    %edx,%eax
  8011c4:	c1 e8 0c             	shr    $0xc,%eax
  8011c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011ce:	a8 01                	test   $0x1,%al
  8011d0:	75 09                	jne    8011db <fd_alloc+0x37>
			*fd_store = fd;
  8011d2:	89 0b                	mov    %ecx,(%ebx)
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d9:	eb 19                	jmp    8011f4 <fd_alloc+0x50>
			return 0;
  8011db:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e1:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8011e7:	75 c7                	jne    8011b0 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011f4:	5b                   	pop    %ebx
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fd:	83 f8 1f             	cmp    $0x1f,%eax
  801200:	77 35                	ja     801237 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801202:	c1 e0 0c             	shl    $0xc,%eax
  801205:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80120b:	89 d0                	mov    %edx,%eax
  80120d:	c1 e8 16             	shr    $0x16,%eax
  801210:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801217:	a8 01                	test   $0x1,%al
  801219:	74 1c                	je     801237 <fd_lookup+0x40>
  80121b:	89 d0                	mov    %edx,%eax
  80121d:	c1 e8 0c             	shr    $0xc,%eax
  801220:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801227:	a8 01                	test   $0x1,%al
  801229:	74 0c                	je     801237 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122e:	89 10                	mov    %edx,(%eax)
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
  801235:	eb 05                	jmp    80123c <fd_lookup+0x45>
	return 0;
  801237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801244:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 a7 ff ff ff       	call   8011f7 <fd_lookup>
  801250:	83 c4 08             	add    $0x8,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 0e                	js     801265 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80125d:	89 50 04             	mov    %edx,0x4(%eax)
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	53                   	push   %ebx
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801274:	ba 00 00 00 00       	mov    $0x0,%edx
  801279:	eb 0e                	jmp    801289 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80127b:	3b 08                	cmp    (%eax),%ecx
  80127d:	75 09                	jne    801288 <dev_lookup+0x21>
			*dev = devtab[i];
  80127f:	89 03                	mov    %eax,(%ebx)
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	eb 31                	jmp    8012b9 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801288:	42                   	inc    %edx
  801289:	8b 04 95 cc 29 80 00 	mov    0x8029cc(,%edx,4),%eax
  801290:	85 c0                	test   %eax,%eax
  801292:	75 e7                	jne    80127b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801294:	a1 04 40 80 00       	mov    0x804004,%eax
  801299:	8b 40 48             	mov    0x48(%eax),%eax
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	51                   	push   %ecx
  8012a0:	50                   	push   %eax
  8012a1:	68 50 29 80 00       	push   $0x802950
  8012a6:	e8 0e f1 ff ff       	call   8003b9 <cprintf>
	*dev = 0;
  8012ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  8012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 14             	sub    $0x14,%esp
  8012c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 23 ff ff ff       	call   8011f7 <fd_lookup>
  8012d4:	83 c4 08             	add    $0x8,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 55                	js     801330 <fstat+0x72>
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e5:	ff 30                	pushl  (%eax)
  8012e7:	e8 7b ff ff ff       	call   801267 <dev_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 3d                	js     801330 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fa:	75 07                	jne    801303 <fstat+0x45>
  8012fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801301:	eb 2d                	jmp    801330 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801303:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801306:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80130d:	00 00 00 
	stat->st_isdir = 0;
  801310:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801317:	00 00 00 
	stat->st_dev = dev;
  80131a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80131d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	53                   	push   %ebx
  801327:	ff 75 f4             	pushl  -0xc(%ebp)
  80132a:	ff 50 14             	call   *0x14(%eax)
  80132d:	83 c4 10             	add    $0x10,%esp
}
  801330:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 14             	sub    $0x14,%esp
  80133c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	53                   	push   %ebx
  801344:	e8 ae fe ff ff       	call   8011f7 <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 5f                	js     8013af <ftruncate+0x7a>
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135a:	ff 30                	pushl  (%eax)
  80135c:	e8 06 ff ff ff       	call   801267 <dev_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 47                	js     8013af <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80136f:	75 21                	jne    801392 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801371:	a1 04 40 80 00       	mov    0x804004,%eax
  801376:	8b 40 48             	mov    0x48(%eax),%eax
  801379:	83 ec 04             	sub    $0x4,%esp
  80137c:	53                   	push   %ebx
  80137d:	50                   	push   %eax
  80137e:	68 70 29 80 00       	push   $0x802970
  801383:	e8 31 f0 ff ff       	call   8003b9 <cprintf>
  801388:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	eb 1d                	jmp    8013af <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801392:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801395:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801399:	75 07                	jne    8013a2 <ftruncate+0x6d>
  80139b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a0:	eb 0d                	jmp    8013af <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	ff 75 0c             	pushl  0xc(%ebp)
  8013a8:	50                   	push   %eax
  8013a9:	ff 52 18             	call   *0x18(%edx)
  8013ac:	83 c4 10             	add    $0x10,%esp
}
  8013af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 14             	sub    $0x14,%esp
  8013bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	53                   	push   %ebx
  8013c3:	e8 2f fe ff ff       	call   8011f7 <fd_lookup>
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 62                	js     801431 <write+0x7d>
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d9:	ff 30                	pushl  (%eax)
  8013db:	e8 87 fe ff ff       	call   801267 <dev_lookup>
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 4a                	js     801431 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013ee:	75 21                	jne    801411 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f5:	8b 40 48             	mov    0x48(%eax),%eax
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	50                   	push   %eax
  8013fd:	68 91 29 80 00       	push   $0x802991
  801402:	e8 b2 ef ff ff       	call   8003b9 <cprintf>
  801407:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	eb 20                	jmp    801431 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801411:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801414:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801418:	75 07                	jne    801421 <write+0x6d>
  80141a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80141f:	eb 10                	jmp    801431 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	ff 75 10             	pushl  0x10(%ebp)
  801427:	ff 75 0c             	pushl  0xc(%ebp)
  80142a:	50                   	push   %eax
  80142b:	ff 52 0c             	call   *0xc(%edx)
  80142e:	83 c4 10             	add    $0x10,%esp
}
  801431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	53                   	push   %ebx
  80143a:	83 ec 14             	sub    $0x14,%esp
  80143d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801440:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801443:	50                   	push   %eax
  801444:	53                   	push   %ebx
  801445:	e8 ad fd ff ff       	call   8011f7 <fd_lookup>
  80144a:	83 c4 08             	add    $0x8,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 67                	js     8014b8 <read+0x82>
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145b:	ff 30                	pushl  (%eax)
  80145d:	e8 05 fe ff ff       	call   801267 <dev_lookup>
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 4f                	js     8014b8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801469:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146c:	8b 42 08             	mov    0x8(%edx),%eax
  80146f:	83 e0 03             	and    $0x3,%eax
  801472:	83 f8 01             	cmp    $0x1,%eax
  801475:	75 21                	jne    801498 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801477:	a1 04 40 80 00       	mov    0x804004,%eax
  80147c:	8b 40 48             	mov    0x48(%eax),%eax
  80147f:	83 ec 04             	sub    $0x4,%esp
  801482:	53                   	push   %ebx
  801483:	50                   	push   %eax
  801484:	68 ae 29 80 00       	push   $0x8029ae
  801489:	e8 2b ef ff ff       	call   8003b9 <cprintf>
  80148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	eb 20                	jmp    8014b8 <read+0x82>
	}
	if (!dev->dev_read)
  801498:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80149b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80149f:	75 07                	jne    8014a8 <read+0x72>
  8014a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a6:	eb 10                	jmp    8014b8 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a8:	83 ec 04             	sub    $0x4,%esp
  8014ab:	ff 75 10             	pushl  0x10(%ebp)
  8014ae:	ff 75 0c             	pushl  0xc(%ebp)
  8014b1:	52                   	push   %edx
  8014b2:	ff 50 08             	call   *0x8(%eax)
  8014b5:	83 c4 10             	add    $0x10,%esp
}
  8014b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    

008014bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	57                   	push   %edi
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8014cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d1:	eb 21                	jmp    8014f4 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	29 d0                	sub    %edx,%eax
  8014da:	50                   	push   %eax
  8014db:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8014de:	50                   	push   %eax
  8014df:	ff 75 08             	pushl  0x8(%ebp)
  8014e2:	e8 4f ff ff ff       	call   801436 <read>
		if (m < 0)
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 0e                	js     8014fc <readn+0x3f>
			return m;
		if (m == 0)
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 08                	je     8014fa <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f2:	01 c3                	add    %eax,%ebx
  8014f4:	89 da                	mov    %ebx,%edx
  8014f6:	39 f3                	cmp    %esi,%ebx
  8014f8:	72 d9                	jb     8014d3 <readn+0x16>
  8014fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ff:	5b                   	pop    %ebx
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	c9                   	leave  
  801503:	c3                   	ret    

00801504 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	56                   	push   %esi
  801508:	53                   	push   %ebx
  801509:	83 ec 20             	sub    $0x20,%esp
  80150c:	8b 75 08             	mov    0x8(%ebp),%esi
  80150f:	8a 45 0c             	mov    0xc(%ebp),%al
  801512:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801515:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	56                   	push   %esi
  80151a:	e8 5d fc ff ff       	call   80117c <fd2num>
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 d0 fc ff ff       	call   8011f7 <fd_lookup>
  801527:	89 c3                	mov    %eax,%ebx
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 05                	js     801535 <fd_close+0x31>
  801530:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801533:	74 0d                	je     801542 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801535:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801539:	75 48                	jne    801583 <fd_close+0x7f>
  80153b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801540:	eb 41                	jmp    801583 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	ff 36                	pushl  (%esi)
  80154b:	e8 17 fd ff ff       	call   801267 <dev_lookup>
  801550:	89 c3                	mov    %eax,%ebx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 1c                	js     801575 <fd_close+0x71>
		if (dev->dev_close)
  801559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155c:	8b 40 10             	mov    0x10(%eax),%eax
  80155f:	85 c0                	test   %eax,%eax
  801561:	75 07                	jne    80156a <fd_close+0x66>
  801563:	bb 00 00 00 00       	mov    $0x0,%ebx
  801568:	eb 0b                	jmp    801575 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	56                   	push   %esi
  80156e:	ff d0                	call   *%eax
  801570:	89 c3                	mov    %eax,%ebx
  801572:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	6a 00                	push   $0x0
  80157b:	e8 1d f8 ff ff       	call   800d9d <sys_page_unmap>
  801580:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801583:	89 d8                	mov    %ebx,%eax
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801592:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	e8 59 fc ff ff       	call   8011f7 <fd_lookup>
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 10                	js     8015b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8015a5:	83 ec 08             	sub    $0x8,%esp
  8015a8:	6a 01                	push   $0x1
  8015aa:	ff 75 fc             	pushl  -0x4(%ebp)
  8015ad:	e8 52 ff ff ff       	call   801504 <fd_close>
  8015b2:	83 c4 10             	add    $0x10,%esp
}
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	6a 00                	push   $0x0
  8015c1:	ff 75 08             	pushl  0x8(%ebp)
  8015c4:	e8 4a 03 00 00       	call   801913 <open>
  8015c9:	89 c6                	mov    %eax,%esi
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 1b                	js     8015ed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	50                   	push   %eax
  8015d9:	e8 e0 fc ff ff       	call   8012be <fstat>
  8015de:	89 c3                	mov    %eax,%ebx
	close(fd);
  8015e0:	89 34 24             	mov    %esi,(%esp)
  8015e3:	e8 a4 ff ff ff       	call   80158c <close>
  8015e8:	89 de                	mov    %ebx,%esi
  8015ea:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015ed:	89 f0                	mov    %esi,%eax
  8015ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f2:	5b                   	pop    %ebx
  8015f3:	5e                   	pop    %esi
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	57                   	push   %edi
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 1c             	sub    $0x1c,%esp
  8015ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	ff 75 08             	pushl  0x8(%ebp)
  801609:	e8 e9 fb ff ff       	call   8011f7 <fd_lookup>
  80160e:	89 c3                	mov    %eax,%ebx
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	0f 88 bd 00 00 00    	js     8016d8 <dup+0xe2>
		return r;
	close(newfdnum);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	57                   	push   %edi
  80161f:	e8 68 ff ff ff       	call   80158c <close>

	newfd = INDEX2FD(newfdnum);
  801624:	89 f8                	mov    %edi,%eax
  801626:	c1 e0 0c             	shl    $0xc,%eax
  801629:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80162f:	ff 75 f0             	pushl  -0x10(%ebp)
  801632:	e8 55 fb ff ff       	call   80118c <fd2data>
  801637:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801639:	89 34 24             	mov    %esi,(%esp)
  80163c:	e8 4b fb ff ff       	call   80118c <fd2data>
  801641:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801644:	89 d8                	mov    %ebx,%eax
  801646:	c1 e8 16             	shr    $0x16,%eax
  801649:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801650:	83 c4 14             	add    $0x14,%esp
  801653:	a8 01                	test   $0x1,%al
  801655:	74 36                	je     80168d <dup+0x97>
  801657:	89 da                	mov    %ebx,%edx
  801659:	c1 ea 0c             	shr    $0xc,%edx
  80165c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801663:	a8 01                	test   $0x1,%al
  801665:	74 26                	je     80168d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801667:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	25 07 0e 00 00       	and    $0xe07,%eax
  801676:	50                   	push   %eax
  801677:	ff 75 e0             	pushl  -0x20(%ebp)
  80167a:	6a 00                	push   $0x0
  80167c:	53                   	push   %ebx
  80167d:	6a 00                	push   $0x0
  80167f:	e8 5b f7 ff ff       	call   800ddf <sys_page_map>
  801684:	89 c3                	mov    %eax,%ebx
  801686:	83 c4 20             	add    $0x20,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 30                	js     8016bd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80168d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801690:	89 d0                	mov    %edx,%eax
  801692:	c1 e8 0c             	shr    $0xc,%eax
  801695:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80169c:	83 ec 0c             	sub    $0xc,%esp
  80169f:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a4:	50                   	push   %eax
  8016a5:	56                   	push   %esi
  8016a6:	6a 00                	push   $0x0
  8016a8:	52                   	push   %edx
  8016a9:	6a 00                	push   $0x0
  8016ab:	e8 2f f7 ff ff       	call   800ddf <sys_page_map>
  8016b0:	89 c3                	mov    %eax,%ebx
  8016b2:	83 c4 20             	add    $0x20,%esp
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 04                	js     8016bd <dup+0xc7>
		goto err;
  8016b9:	89 fb                	mov    %edi,%ebx
  8016bb:	eb 1b                	jmp    8016d8 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	56                   	push   %esi
  8016c1:	6a 00                	push   $0x0
  8016c3:	e8 d5 f6 ff ff       	call   800d9d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8016ce:	6a 00                	push   $0x0
  8016d0:	e8 c8 f6 ff ff       	call   800d9d <sys_page_unmap>
  8016d5:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8016d8:	89 d8                	mov    %ebx,%eax
  8016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dd:	5b                   	pop    %ebx
  8016de:	5e                   	pop    %esi
  8016df:	5f                   	pop    %edi
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016ee:	83 ec 0c             	sub    $0xc,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	e8 95 fe ff ff       	call   80158c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f7:	43                   	inc    %ebx
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	83 fb 20             	cmp    $0x20,%ebx
  8016fe:	75 ee                	jne    8016ee <close_all+0xc>
		close(i);
}
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    
  801705:	00 00                	add    %al,(%eax)
	...

00801708 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	89 c3                	mov    %eax,%ebx
  80170f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801711:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801718:	75 12                	jne    80172c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	6a 01                	push   $0x1
  80171f:	e8 48 08 00 00       	call   801f6c <ipc_find_env>
  801724:	a3 00 40 80 00       	mov    %eax,0x804000
  801729:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80172c:	6a 07                	push   $0x7
  80172e:	68 00 50 80 00       	push   $0x805000
  801733:	53                   	push   %ebx
  801734:	ff 35 00 40 80 00    	pushl  0x804000
  80173a:	e8 72 08 00 00       	call   801fb1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80173f:	83 c4 0c             	add    $0xc,%esp
  801742:	6a 00                	push   $0x0
  801744:	56                   	push   %esi
  801745:	6a 00                	push   $0x0
  801747:	e8 ba 08 00 00       	call   802006 <ipc_recv>
}
  80174c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 08 00 00 00       	mov    $0x8,%eax
  801763:	e8 a0 ff ff ff       	call   801708 <fsipc>
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	8b 40 0c             	mov    0xc(%eax),%eax
  801776:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801783:	ba 00 00 00 00       	mov    $0x0,%edx
  801788:	b8 02 00 00 00       	mov    $0x2,%eax
  80178d:	e8 76 ff ff ff       	call   801708 <fsipc>
}
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8017af:	e8 54 ff ff ff       	call   801708 <fsipc>
}
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 04             	sub    $0x4,%esp
  8017bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d5:	e8 2e ff ff ff       	call   801708 <fsipc>
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 2c                	js     80180a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	68 00 50 80 00       	push   $0x805000
  8017e6:	53                   	push   %ebx
  8017e7:	e8 1f f1 ff ff       	call   80090b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
  801807:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80180a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 40 0c             	mov    0xc(%eax),%eax
  80181f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801824:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80182a:	53                   	push   %ebx
  80182b:	ff 75 0c             	pushl  0xc(%ebp)
  80182e:	68 08 50 80 00       	push   $0x805008
  801833:	e8 40 f2 ff ff       	call   800a78 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801838:	ba 00 00 00 00       	mov    $0x0,%edx
  80183d:	b8 04 00 00 00       	mov    $0x4,%eax
  801842:	e8 c1 fe ff ff       	call   801708 <fsipc>
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 3d                	js     80188b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80184e:	39 c3                	cmp    %eax,%ebx
  801850:	73 19                	jae    80186b <devfile_write+0x5c>
  801852:	68 dc 29 80 00       	push   $0x8029dc
  801857:	68 e3 29 80 00       	push   $0x8029e3
  80185c:	68 97 00 00 00       	push   $0x97
  801861:	68 f8 29 80 00       	push   $0x8029f8
  801866:	e8 ad ea ff ff       	call   800318 <_panic>
	assert(r <= PGSIZE);
  80186b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801870:	7e 19                	jle    80188b <devfile_write+0x7c>
  801872:	68 03 2a 80 00       	push   $0x802a03
  801877:	68 e3 29 80 00       	push   $0x8029e3
  80187c:	68 98 00 00 00       	push   $0x98
  801881:	68 f8 29 80 00       	push   $0x8029f8
  801886:	e8 8d ea ff ff       	call   800318 <_panic>
	
	return r;
}
  80188b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b3:	e8 50 fe ff ff       	call   801708 <fsipc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 4c                	js     80190a <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8018be:	39 de                	cmp    %ebx,%esi
  8018c0:	73 16                	jae    8018d8 <devfile_read+0x48>
  8018c2:	68 dc 29 80 00       	push   $0x8029dc
  8018c7:	68 e3 29 80 00       	push   $0x8029e3
  8018cc:	6a 7c                	push   $0x7c
  8018ce:	68 f8 29 80 00       	push   $0x8029f8
  8018d3:	e8 40 ea ff ff       	call   800318 <_panic>
	assert(r <= PGSIZE);
  8018d8:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8018de:	7e 16                	jle    8018f6 <devfile_read+0x66>
  8018e0:	68 03 2a 80 00       	push   $0x802a03
  8018e5:	68 e3 29 80 00       	push   $0x8029e3
  8018ea:	6a 7d                	push   $0x7d
  8018ec:	68 f8 29 80 00       	push   $0x8029f8
  8018f1:	e8 22 ea ff ff       	call   800318 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	50                   	push   %eax
  8018fa:	68 00 50 80 00       	push   $0x805000
  8018ff:	ff 75 0c             	pushl  0xc(%ebp)
  801902:	e8 71 f1 ff ff       	call   800a78 <memmove>
  801907:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80190a:	89 d8                	mov    %ebx,%eax
  80190c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	56                   	push   %esi
  801917:	53                   	push   %ebx
  801918:	83 ec 1c             	sub    $0x1c,%esp
  80191b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80191e:	56                   	push   %esi
  80191f:	e8 b4 ef ff ff       	call   8008d8 <strlen>
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192c:	7e 07                	jle    801935 <open+0x22>
  80192e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801933:	eb 63                	jmp    801998 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	e8 63 f8 ff ff       	call   8011a4 <fd_alloc>
  801941:	89 c3                	mov    %eax,%ebx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	85 c0                	test   %eax,%eax
  801948:	78 4e                	js     801998 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	56                   	push   %esi
  80194e:	68 00 50 80 00       	push   $0x805000
  801953:	e8 b3 ef ff ff       	call   80090b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801963:	b8 01 00 00 00       	mov    $0x1,%eax
  801968:	e8 9b fd ff ff       	call   801708 <fsipc>
  80196d:	89 c3                	mov    %eax,%ebx
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	85 c0                	test   %eax,%eax
  801974:	79 12                	jns    801988 <open+0x75>
		fd_close(fd, 0);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	6a 00                	push   $0x0
  80197b:	ff 75 f4             	pushl  -0xc(%ebp)
  80197e:	e8 81 fb ff ff       	call   801504 <fd_close>
		return r;
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	eb 10                	jmp    801998 <open+0x85>
	}

	return fd2num(fd);
  801988:	83 ec 0c             	sub    $0xc,%esp
  80198b:	ff 75 f4             	pushl  -0xc(%ebp)
  80198e:	e8 e9 f7 ff ff       	call   80117c <fd2num>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
}
  801998:	89 d8                	mov    %ebx,%eax
  80199a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    
  8019a1:	00 00                	add    %al,(%eax)
	...

008019a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	56                   	push   %esi
  8019a8:	53                   	push   %ebx
  8019a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff 75 08             	pushl  0x8(%ebp)
  8019b2:	e8 d5 f7 ff ff       	call   80118c <fd2data>
  8019b7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	68 0f 2a 80 00       	push   $0x802a0f
  8019c1:	53                   	push   %ebx
  8019c2:	e8 44 ef ff ff       	call   80090b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019c7:	8b 46 04             	mov    0x4(%esi),%eax
  8019ca:	2b 06                	sub    (%esi),%eax
  8019cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d9:	00 00 00 
	stat->st_dev = &devpipe;
  8019dc:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8019e3:	30 80 00 
	return 0;
}
  8019e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019fc:	53                   	push   %ebx
  8019fd:	6a 00                	push   $0x0
  8019ff:	e8 99 f3 ff ff       	call   800d9d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a04:	89 1c 24             	mov    %ebx,(%esp)
  801a07:	e8 80 f7 ff ff       	call   80118c <fd2data>
  801a0c:	83 c4 08             	add    $0x8,%esp
  801a0f:	50                   	push   %eax
  801a10:	6a 00                	push   $0x0
  801a12:	e8 86 f3 ff ff       	call   800d9d <sys_page_unmap>
}
  801a17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	57                   	push   %edi
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a28:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a2f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	ff 75 f0             	pushl  -0x10(%ebp)
  801a38:	e8 33 06 00 00       	call   802070 <pageref>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	89 3c 24             	mov    %edi,(%esp)
  801a42:	e8 29 06 00 00       	call   802070 <pageref>
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	39 c3                	cmp    %eax,%ebx
  801a4c:	0f 94 c0             	sete   %al
  801a4f:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801a52:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a58:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801a5b:	39 c6                	cmp    %eax,%esi
  801a5d:	74 1b                	je     801a7a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801a5f:	83 f9 01             	cmp    $0x1,%ecx
  801a62:	75 c6                	jne    801a2a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a64:	8b 42 58             	mov    0x58(%edx),%eax
  801a67:	6a 01                	push   $0x1
  801a69:	50                   	push   %eax
  801a6a:	56                   	push   %esi
  801a6b:	68 16 2a 80 00       	push   $0x802a16
  801a70:	e8 44 e9 ff ff       	call   8003b9 <cprintf>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	eb b0                	jmp    801a2a <_pipeisclosed+0xe>
	}
}
  801a7a:	89 c8                	mov    %ecx,%eax
  801a7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	57                   	push   %edi
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 18             	sub    $0x18,%esp
  801a8d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a90:	56                   	push   %esi
  801a91:	e8 f6 f6 ff ff       	call   80118c <fd2data>
  801a96:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a9e:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb 40                	jmp    801ae8 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aad:	eb 40                	jmp    801aef <devpipe_write+0x6b>
  801aaf:	89 da                	mov    %ebx,%edx
  801ab1:	89 f0                	mov    %esi,%eax
  801ab3:	e8 64 ff ff ff       	call   801a1c <_pipeisclosed>
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	75 ec                	jne    801aa8 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801abc:	e8 a3 f3 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac1:	8b 53 04             	mov    0x4(%ebx),%edx
  801ac4:	8b 03                	mov    (%ebx),%eax
  801ac6:	83 c0 20             	add    $0x20,%eax
  801ac9:	39 c2                	cmp    %eax,%edx
  801acb:	73 e2                	jae    801aaf <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801acd:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ad3:	79 05                	jns    801ada <devpipe_write+0x56>
  801ad5:	4a                   	dec    %edx
  801ad6:	83 ca e0             	or     $0xffffffe0,%edx
  801ad9:	42                   	inc    %edx
  801ada:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801add:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801ae0:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae4:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae7:	47                   	inc    %edi
  801ae8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801aeb:	75 d4                	jne    801ac1 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aed:	89 f8                	mov    %edi,%eax
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	53                   	push   %ebx
  801afd:	83 ec 18             	sub    $0x18,%esp
  801b00:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b03:	57                   	push   %edi
  801b04:	e8 83 f6 ff ff       	call   80118c <fd2data>
  801b09:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b11:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	eb 41                	jmp    801b5c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b1b:	89 f0                	mov    %esi,%eax
  801b1d:	eb 44                	jmp    801b63 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b24:	eb 3d                	jmp    801b63 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b26:	85 f6                	test   %esi,%esi
  801b28:	75 f1                	jne    801b1b <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	89 f8                	mov    %edi,%eax
  801b2e:	e8 e9 fe ff ff       	call   801a1c <_pipeisclosed>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	75 e8                	jne    801b1f <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b37:	e8 28 f3 ff ff       	call   800e64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b3c:	8b 03                	mov    (%ebx),%eax
  801b3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b41:	74 e3                	je     801b26 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b43:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b48:	79 05                	jns    801b4f <devpipe_read+0x58>
  801b4a:	48                   	dec    %eax
  801b4b:	83 c8 e0             	or     $0xffffffe0,%eax
  801b4e:	40                   	inc    %eax
  801b4f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b53:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b56:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801b59:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5b:	46                   	inc    %esi
  801b5c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b5f:	75 db                	jne    801b3c <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b61:	89 f0                	mov    %esi,%eax
}
  801b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b66:	5b                   	pop    %ebx
  801b67:	5e                   	pop    %esi
  801b68:	5f                   	pop    %edi
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b71:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b74:	50                   	push   %eax
  801b75:	ff 75 08             	pushl  0x8(%ebp)
  801b78:	e8 7a f6 ff ff       	call   8011f7 <fd_lookup>
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 18                	js     801b9c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b84:	83 ec 0c             	sub    $0xc,%esp
  801b87:	ff 75 fc             	pushl  -0x4(%ebp)
  801b8a:	e8 fd f5 ff ff       	call   80118c <fd2data>
  801b8f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b94:	e8 83 fe ff ff       	call   801a1c <_pipeisclosed>
  801b99:	83 c4 10             	add    $0x10,%esp
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 28             	sub    $0x28,%esp
  801ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801baa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	e8 f1 f5 ff ff       	call   8011a4 <fd_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 24 01 00 00    	js     801ce4 <pipe+0x146>
  801bc0:	83 ec 04             	sub    $0x4,%esp
  801bc3:	68 07 04 00 00       	push   $0x407
  801bc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 4f f2 ff ff       	call   800e21 <sys_page_alloc>
  801bd2:	89 c3                	mov    %eax,%ebx
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	0f 88 05 01 00 00    	js     801ce4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801be5:	50                   	push   %eax
  801be6:	e8 b9 f5 ff ff       	call   8011a4 <fd_alloc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 dc 00 00 00    	js     801cd4 <pipe+0x136>
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	68 07 04 00 00       	push   $0x407
  801c00:	ff 75 ec             	pushl  -0x14(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 17 f2 ff ff       	call   800e21 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 bd 00 00 00    	js     801cd4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1d:	e8 6a f5 ff ff       	call   80118c <fd2data>
  801c22:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c24:	83 c4 0c             	add    $0xc,%esp
  801c27:	68 07 04 00 00       	push   $0x407
  801c2c:	50                   	push   %eax
  801c2d:	6a 00                	push   $0x0
  801c2f:	e8 ed f1 ff ff       	call   800e21 <sys_page_alloc>
  801c34:	89 c3                	mov    %eax,%ebx
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	0f 88 83 00 00 00    	js     801cc4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	ff 75 ec             	pushl  -0x14(%ebp)
  801c47:	e8 40 f5 ff ff       	call   80118c <fd2data>
  801c4c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c53:	50                   	push   %eax
  801c54:	6a 00                	push   $0x0
  801c56:	56                   	push   %esi
  801c57:	6a 00                	push   $0x0
  801c59:	e8 81 f1 ff ff       	call   800ddf <sys_page_map>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	83 c4 20             	add    $0x20,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	78 4f                	js     801cb6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c67:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c70:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c75:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c85:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c8a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c91:	83 ec 0c             	sub    $0xc,%esp
  801c94:	ff 75 f0             	pushl  -0x10(%ebp)
  801c97:	e8 e0 f4 ff ff       	call   80117c <fd2num>
  801c9c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c9e:	83 c4 04             	add    $0x4,%esp
  801ca1:	ff 75 ec             	pushl  -0x14(%ebp)
  801ca4:	e8 d3 f4 ff ff       	call   80117c <fd2num>
  801ca9:	89 47 04             	mov    %eax,0x4(%edi)
  801cac:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	eb 2e                	jmp    801ce4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cb6:	83 ec 08             	sub    $0x8,%esp
  801cb9:	56                   	push   %esi
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 dc f0 ff ff       	call   800d9d <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc4:	83 ec 08             	sub    $0x8,%esp
  801cc7:	ff 75 ec             	pushl  -0x14(%ebp)
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 cc f0 ff ff       	call   800d9d <sys_page_unmap>
  801cd1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd4:	83 ec 08             	sub    $0x8,%esp
  801cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 bc f0 ff ff       	call   800d9d <sys_page_unmap>
  801ce1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ce4:	89 d8                	mov    %ebx,%eax
  801ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	c9                   	leave  
  801ced:	c3                   	ret    
	...

00801cf0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801cf8:	85 f6                	test   %esi,%esi
  801cfa:	75 16                	jne    801d12 <wait+0x22>
  801cfc:	68 2e 2a 80 00       	push   $0x802a2e
  801d01:	68 e3 29 80 00       	push   $0x8029e3
  801d06:	6a 09                	push   $0x9
  801d08:	68 39 2a 80 00       	push   $0x802a39
  801d0d:	e8 06 e6 ff ff       	call   800318 <_panic>
	e = &envs[ENVX(envid)];
  801d12:	89 f0                	mov    %esi,%eax
  801d14:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801d20:	c1 e0 07             	shl    $0x7,%eax
  801d23:	29 d0                	sub    %edx,%eax
  801d25:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  801d2b:	eb 05                	jmp    801d32 <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  801d2d:	e8 32 f1 ff ff       	call   800e64 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d32:	8b 43 48             	mov    0x48(%ebx),%eax
  801d35:	39 c6                	cmp    %eax,%esi
  801d37:	75 07                	jne    801d40 <wait+0x50>
  801d39:	8b 43 54             	mov    0x54(%ebx),%eax
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	75 ed                	jne    801d2d <wait+0x3d>
		sys_yield();
}
  801d40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    
	...

00801d48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d58:	68 44 2a 80 00       	push   $0x802a44
  801d5d:	ff 75 0c             	pushl  0xc(%ebp)
  801d60:	e8 a6 eb ff ff       	call   80090b <strcpy>
	return 0;
}
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801d78:	be 00 00 00 00       	mov    $0x0,%esi
  801d7d:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801d83:	eb 2c                	jmp    801db1 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d88:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d8a:	83 fb 7f             	cmp    $0x7f,%ebx
  801d8d:	76 05                	jbe    801d94 <devcons_write+0x28>
  801d8f:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	53                   	push   %ebx
  801d98:	03 45 0c             	add    0xc(%ebp),%eax
  801d9b:	50                   	push   %eax
  801d9c:	57                   	push   %edi
  801d9d:	e8 d6 ec ff ff       	call   800a78 <memmove>
		sys_cputs(buf, m);
  801da2:	83 c4 08             	add    $0x8,%esp
  801da5:	53                   	push   %ebx
  801da6:	57                   	push   %edi
  801da7:	e8 a3 ee ff ff       	call   800c4f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dac:	01 de                	add    %ebx,%esi
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	89 f0                	mov    %esi,%eax
  801db3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db6:	72 cd                	jb     801d85 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dcc:	6a 01                	push   $0x1
  801dce:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801dd1:	50                   	push   %eax
  801dd2:	e8 78 ee ff ff       	call   800c4f <sys_cputs>
  801dd7:	83 c4 10             	add    $0x10,%esp
}
  801dda:	c9                   	leave  
  801ddb:	c3                   	ret    

00801ddc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801de2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de6:	74 27                	je     801e0f <devcons_read+0x33>
  801de8:	eb 05                	jmp    801def <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dea:	e8 75 f0 ff ff       	call   800e64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801def:	e8 3c ee ff ff       	call   800c30 <sys_cgetc>
  801df4:	89 c2                	mov    %eax,%edx
  801df6:	85 c0                	test   %eax,%eax
  801df8:	74 f0                	je     801dea <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 16                	js     801e14 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dfe:	83 f8 04             	cmp    $0x4,%eax
  801e01:	74 0c                	je     801e0f <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801e03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e06:	88 10                	mov    %dl,(%eax)
  801e08:	ba 01 00 00 00       	mov    $0x1,%edx
  801e0d:	eb 05                	jmp    801e14 <devcons_read+0x38>
	return 1;
  801e0f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e14:	89 d0                	mov    %edx,%eax
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e1e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	e8 7d f3 ff ff       	call   8011a4 <fd_alloc>
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 3b                	js     801e69 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2e:	83 ec 04             	sub    $0x4,%esp
  801e31:	68 07 04 00 00       	push   $0x407
  801e36:	ff 75 fc             	pushl  -0x4(%ebp)
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 e1 ef ff ff       	call   800e21 <sys_page_alloc>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 22                	js     801e69 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e47:	a1 40 30 80 00       	mov    0x803040,%eax
  801e4c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801e4f:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801e51:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e54:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e5b:	83 ec 0c             	sub    $0xc,%esp
  801e5e:	ff 75 fc             	pushl  -0x4(%ebp)
  801e61:	e8 16 f3 ff ff       	call   80117c <fd2num>
  801e66:	83 c4 10             	add    $0x10,%esp
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e71:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801e74:	50                   	push   %eax
  801e75:	ff 75 08             	pushl  0x8(%ebp)
  801e78:	e8 7a f3 ff ff       	call   8011f7 <fd_lookup>
  801e7d:	83 c4 10             	add    $0x10,%esp
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 11                	js     801e95 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e87:	8b 00                	mov    (%eax),%eax
  801e89:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  801e8f:	0f 94 c0             	sete   %al
  801e92:	0f b6 c0             	movzbl %al,%eax
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e9d:	6a 01                	push   $0x1
  801e9f:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801ea2:	50                   	push   %eax
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 8c f5 ff ff       	call   801436 <read>
	if (r < 0)
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 0f                	js     801ec0 <getchar+0x29>
		return r;
	if (r < 1)
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	75 07                	jne    801ebc <getchar+0x25>
  801eb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eba:	eb 04                	jmp    801ec0 <getchar+0x29>
		return -E_EOF;
	return c;
  801ebc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    
	...

00801ec4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eca:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed1:	75 64                	jne    801f37 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801ed3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed8:	8b 40 48             	mov    0x48(%eax),%eax
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	6a 07                	push   $0x7
  801ee0:	68 00 f0 bf ee       	push   $0xeebff000
  801ee5:	50                   	push   %eax
  801ee6:	e8 36 ef ff ff       	call   800e21 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	79 14                	jns    801f06 <set_pgfault_handler+0x42>
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	68 50 2a 80 00       	push   $0x802a50
  801efa:	6a 22                	push   $0x22
  801efc:	68 b9 2a 80 00       	push   $0x802ab9
  801f01:	e8 12 e4 ff ff       	call   800318 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  801f06:	a1 04 40 80 00       	mov    0x804004,%eax
  801f0b:	8b 40 48             	mov    0x48(%eax),%eax
  801f0e:	83 ec 08             	sub    $0x8,%esp
  801f11:	68 44 1f 80 00       	push   $0x801f44
  801f16:	50                   	push   %eax
  801f17:	e8 bb ed ff ff       	call   800cd7 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	79 14                	jns    801f37 <set_pgfault_handler+0x73>
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	68 80 2a 80 00       	push   $0x802a80
  801f2b:	6a 25                	push   $0x25
  801f2d:	68 b9 2a 80 00       	push   $0x802ab9
  801f32:	e8 e1 e3 ff ff       	call   800318 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f37:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    
  801f41:	00 00                	add    %al,(%eax)
	...

00801f44 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f44:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f45:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f4a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  801f4f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f53:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f56:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  801f5a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  801f5e:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  801f60:	83 c4 08             	add    $0x8,%esp
	popal
  801f63:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f64:	83 c4 04             	add    $0x4,%esp
	popfl
  801f67:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f68:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  801f69:	c3                   	ret    
	...

00801f6c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	53                   	push   %ebx
  801f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f73:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f78:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801f7f:	89 c8                	mov    %ecx,%eax
  801f81:	c1 e0 07             	shl    $0x7,%eax
  801f84:	29 d0                	sub    %edx,%eax
  801f86:	89 c2                	mov    %eax,%edx
  801f88:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801f8e:	8b 40 50             	mov    0x50(%eax),%eax
  801f91:	39 d8                	cmp    %ebx,%eax
  801f93:	75 0b                	jne    801fa0 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f95:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801f9b:	8b 40 40             	mov    0x40(%eax),%eax
  801f9e:	eb 0e                	jmp    801fae <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa0:	41                   	inc    %ecx
  801fa1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801fa7:	75 cf                	jne    801f78 <ipc_find_env+0xc>
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801fae:	5b                   	pop    %ebx
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	57                   	push   %edi
  801fb5:	56                   	push   %esi
  801fb6:	53                   	push   %ebx
  801fb7:	83 ec 0c             	sub    $0xc,%esp
  801fba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801fc3:	85 db                	test   %ebx,%ebx
  801fc5:	75 05                	jne    801fcc <ipc_send+0x1b>
  801fc7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	57                   	push   %edi
  801fcf:	ff 75 08             	pushl  0x8(%ebp)
  801fd2:	e8 dd ec ff ff       	call   800cb4 <sys_ipc_try_send>
		if (r == 0) {		//success
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	74 20                	je     801ffe <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801fde:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fe1:	75 07                	jne    801fea <ipc_send+0x39>
			sys_yield();
  801fe3:	e8 7c ee ff ff       	call   800e64 <sys_yield>
  801fe8:	eb e2                	jmp    801fcc <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	68 c8 2a 80 00       	push   $0x802ac8
  801ff2:	6a 41                	push   $0x41
  801ff4:	68 ec 2a 80 00       	push   $0x802aec
  801ff9:	e8 1a e3 ff ff       	call   800318 <_panic>
		}
	}
}
  801ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5f                   	pop    %edi
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80200e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802011:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802014:	85 c0                	test   %eax,%eax
  802016:	75 05                	jne    80201d <ipc_recv+0x17>
  802018:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  80201d:	83 ec 0c             	sub    $0xc,%esp
  802020:	50                   	push   %eax
  802021:	e8 4d ec ff ff       	call   800c73 <sys_ipc_recv>
	if (r < 0) {				
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	85 c0                	test   %eax,%eax
  80202b:	79 16                	jns    802043 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  80202d:	85 db                	test   %ebx,%ebx
  80202f:	74 06                	je     802037 <ipc_recv+0x31>
  802031:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  802037:	85 f6                	test   %esi,%esi
  802039:	74 2c                	je     802067 <ipc_recv+0x61>
  80203b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802041:	eb 24                	jmp    802067 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  802043:	85 db                	test   %ebx,%ebx
  802045:	74 0a                	je     802051 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802047:	a1 04 40 80 00       	mov    0x804004,%eax
  80204c:	8b 40 74             	mov    0x74(%eax),%eax
  80204f:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  802051:	85 f6                	test   %esi,%esi
  802053:	74 0a                	je     80205f <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802055:	a1 04 40 80 00       	mov    0x804004,%eax
  80205a:	8b 40 78             	mov    0x78(%eax),%eax
  80205d:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80205f:	a1 04 40 80 00       	mov    0x804004,%eax
  802064:	8b 40 70             	mov    0x70(%eax),%eax
}
  802067:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    
	...

00802070 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802076:	89 d0                	mov    %edx,%eax
  802078:	c1 e8 16             	shr    $0x16,%eax
  80207b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802082:	a8 01                	test   $0x1,%al
  802084:	74 20                	je     8020a6 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802086:	89 d0                	mov    %edx,%eax
  802088:	c1 e8 0c             	shr    $0xc,%eax
  80208b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802092:	a8 01                	test   $0x1,%al
  802094:	74 10                	je     8020a6 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802096:	c1 e8 0c             	shr    $0xc,%eax
  802099:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020a0:	ef 
  8020a1:	0f b7 c0             	movzwl %ax,%eax
  8020a4:	eb 05                	jmp    8020ab <pageref+0x3b>
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ab:	c9                   	leave  
  8020ac:	c3                   	ret    
  8020ad:	00 00                	add    %al,(%eax)
	...

008020b0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	83 ec 28             	sub    $0x28,%esp
  8020b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8020bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8020c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8020cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020cf:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8020d1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  8020d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  8020d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020dc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020df:	85 ff                	test   %edi,%edi
  8020e1:	75 21                	jne    802104 <__udivdi3+0x54>
    {
      if (d0 > n1)
  8020e3:	39 d1                	cmp    %edx,%ecx
  8020e5:	76 49                	jbe    802130 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020e7:	f7 f1                	div    %ecx
  8020e9:	89 c1                	mov    %eax,%ecx
  8020eb:	31 c0                	xor    %eax,%eax
  8020ed:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020f0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8020f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8020f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8020fc:	83 c4 28             	add    $0x28,%esp
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	c9                   	leave  
  802102:	c3                   	ret    
  802103:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802104:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802107:	0f 87 97 00 00 00    	ja     8021a4 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80210d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802110:	83 f0 1f             	xor    $0x1f,%eax
  802113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802116:	75 34                	jne    80214c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802118:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80211b:	72 08                	jb     802125 <__udivdi3+0x75>
  80211d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802120:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802123:	77 7f                	ja     8021a4 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802125:	b9 01 00 00 00       	mov    $0x1,%ecx
  80212a:	31 c0                	xor    %eax,%eax
  80212c:	eb c2                	jmp    8020f0 <__udivdi3+0x40>
  80212e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802130:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802133:	85 c0                	test   %eax,%eax
  802135:	74 79                	je     8021b0 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802137:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	f7 f1                	div    %ecx
  80213e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802140:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802143:	f7 f1                	div    %ecx
  802145:	89 c1                	mov    %eax,%ecx
  802147:	89 f0                	mov    %esi,%eax
  802149:	eb a5                	jmp    8020f0 <__udivdi3+0x40>
  80214b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80214c:	b8 20 00 00 00       	mov    $0x20,%eax
  802151:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802154:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802157:	89 fa                	mov    %edi,%edx
  802159:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80215c:	d3 e2                	shl    %cl,%edx
  80215e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802161:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802164:	d3 e8                	shr    %cl,%eax
  802166:	89 d7                	mov    %edx,%edi
  802168:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80216a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80216d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802170:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802172:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802175:	d3 e0                	shl    %cl,%eax
  802177:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80217a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80217d:	d3 ea                	shr    %cl,%edx
  80217f:	09 d0                	or     %edx,%eax
  802181:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802184:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802187:	d3 ea                	shr    %cl,%edx
  802189:	f7 f7                	div    %edi
  80218b:	89 d7                	mov    %edx,%edi
  80218d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802190:	f7 e6                	mul    %esi
  802192:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802194:	39 d7                	cmp    %edx,%edi
  802196:	72 38                	jb     8021d0 <__udivdi3+0x120>
  802198:	74 27                	je     8021c1 <__udivdi3+0x111>
  80219a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80219d:	31 c0                	xor    %eax,%eax
  80219f:	e9 4c ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021a4:	31 c9                	xor    %ecx,%ecx
  8021a6:	31 c0                	xor    %eax,%eax
  8021a8:	e9 43 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b5:	31 d2                	xor    %edx,%edx
  8021b7:	f7 75 f4             	divl   -0xc(%ebp)
  8021ba:	89 c1                	mov    %eax,%ecx
  8021bc:	e9 76 ff ff ff       	jmp    802137 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021c4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	39 f0                	cmp    %esi,%eax
  8021cb:	73 cd                	jae    80219a <__udivdi3+0xea>
  8021cd:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021d0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8021d3:	49                   	dec    %ecx
  8021d4:	31 c0                	xor    %eax,%eax
  8021d6:	e9 15 ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
	...

008021dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	83 ec 30             	sub    $0x30,%esp
  8021e4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8021eb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8021f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8021fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802201:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802203:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  802206:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  802209:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80220c:	85 d2                	test   %edx,%edx
  80220e:	75 1c                	jne    80222c <__umoddi3+0x50>
    {
      if (d0 > n1)
  802210:	89 fa                	mov    %edi,%edx
  802212:	39 f8                	cmp    %edi,%eax
  802214:	0f 86 c2 00 00 00    	jbe    8022dc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80221a:	89 f0                	mov    %esi,%eax
  80221c:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80221e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802221:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802228:	eb 12                	jmp    80223c <__umoddi3+0x60>
  80222a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80222c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80222f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802232:	76 18                	jbe    80224c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802234:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  802237:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80223a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80223c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80223f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802242:	83 c4 30             	add    $0x30,%esp
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	c9                   	leave  
  802248:	c3                   	ret    
  802249:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80224c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802250:	83 f0 1f             	xor    $0x1f,%eax
  802253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802256:	0f 84 ac 00 00 00    	je     802308 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80225c:	b8 20 00 00 00       	mov    $0x20,%eax
  802261:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802264:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802267:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80226a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80226d:	d3 e2                	shl    %cl,%edx
  80226f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802272:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802275:	d3 e8                	shr    %cl,%eax
  802277:	89 d6                	mov    %edx,%esi
  802279:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80227b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80227e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802281:	d3 e0                	shl    %cl,%eax
  802283:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802286:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802289:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80228b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80228e:	d3 e0                	shl    %cl,%eax
  802290:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802293:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802296:	d3 ea                	shr    %cl,%edx
  802298:	09 d0                	or     %edx,%eax
  80229a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80229d:	d3 ea                	shr    %cl,%edx
  80229f:	f7 f6                	div    %esi
  8022a1:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8022a4:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022a7:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8022aa:	0f 82 8d 00 00 00    	jb     80233d <__umoddi3+0x161>
  8022b0:	0f 84 91 00 00 00    	je     802347 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022b6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022b9:	29 c7                	sub    %eax,%edi
  8022bb:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022bd:	89 f2                	mov    %esi,%edx
  8022bf:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8022c2:	d3 e2                	shl    %cl,%edx
  8022c4:	89 f8                	mov    %edi,%eax
  8022c6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8022c9:	d3 e8                	shr    %cl,%eax
  8022cb:	09 c2                	or     %eax,%edx
  8022cd:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8022d0:	d3 ee                	shr    %cl,%esi
  8022d2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8022d5:	e9 62 ff ff ff       	jmp    80223c <__umoddi3+0x60>
  8022da:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	74 15                	je     8022f8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022e9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ee:	f7 f1                	div    %ecx
  8022f0:	e9 29 ff ff ff       	jmp    80221e <__umoddi3+0x42>
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	f7 75 ec             	divl   -0x14(%ebp)
  802302:	89 c1                	mov    %eax,%ecx
  802304:	eb dd                	jmp    8022e3 <__umoddi3+0x107>
  802306:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802308:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80230e:	72 19                	jb     802329 <__umoddi3+0x14d>
  802310:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802313:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  802316:	76 11                	jbe    802329 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  802318:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80231b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80231e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802321:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802324:	e9 13 ff ff ff       	jmp    80223c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802329:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80232c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802332:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802335:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802338:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80233b:	eb db                	jmp    802318 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80233d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802340:	19 f2                	sbb    %esi,%edx
  802342:	e9 6f ff ff ff       	jmp    8022b6 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802347:	39 c7                	cmp    %eax,%edi
  802349:	72 f2                	jb     80233d <__umoddi3+0x161>
  80234b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80234e:	e9 63 ff ff ff       	jmp    8022b6 <__umoddi3+0xda>
