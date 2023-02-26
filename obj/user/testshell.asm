
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 4f 04 00 00       	call   800480 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 84 00 00 00    	sub    $0x84,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	53                   	push   %ebx
  80004a:	57                   	push   %edi
  80004b:	e8 ba 13 00 00       	call   80140a <seek>
	seek(kfd, off);
  800050:	83 c4 08             	add    $0x8,%esp
  800053:	53                   	push   %ebx
  800054:	56                   	push   %esi
  800055:	e8 b0 13 00 00       	call   80140a <seek>

	cprintf("shell produced incorrect output.\n");
  80005a:	c7 04 24 80 29 80 00 	movl   $0x802980,(%esp)
  800061:	e8 1f 05 00 00       	call   800585 <cprintf>
	cprintf("expected:\n===\n");
  800066:	c7 04 24 eb 29 80 00 	movl   $0x8029eb,(%esp)
  80006d:	e8 13 05 00 00       	call   800585 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 5d 90             	lea    -0x70(%ebp),%ebx
  800078:	eb 0d                	jmp    800087 <wrong+0x53>
		sys_cputs(buf, n);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	50                   	push   %eax
  80007e:	53                   	push   %ebx
  80007f:	e8 97 0d 00 00       	call   800e1b <sys_cputs>
  800084:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800087:	83 ec 04             	sub    $0x4,%esp
  80008a:	6a 63                	push   $0x63
  80008c:	53                   	push   %ebx
  80008d:	56                   	push   %esi
  80008e:	e8 6f 15 00 00       	call   801602 <read>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	7f e0                	jg     80007a <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 fa 29 80 00       	push   $0x8029fa
  8000a2:	e8 de 04 00 00       	call   800585 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	8d 5d 90             	lea    -0x70(%ebp),%ebx
  8000ad:	eb 0d                	jmp    8000bc <wrong+0x88>
		sys_cputs(buf, n);
  8000af:	83 ec 08             	sub    $0x8,%esp
  8000b2:	50                   	push   %eax
  8000b3:	53                   	push   %ebx
  8000b4:	e8 62 0d 00 00       	call   800e1b <sys_cputs>
  8000b9:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	6a 63                	push   $0x63
  8000c1:	53                   	push   %ebx
  8000c2:	57                   	push   %edi
  8000c3:	e8 3a 15 00 00       	call   801602 <read>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f e0                	jg     8000af <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	68 f5 29 80 00       	push   $0x8029f5
  8000d7:	e8 a9 04 00 00       	call   800585 <cprintf>
	exit();
  8000dc:	e8 ef 03 00 00       	call   8004d0 <exit>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 28             	sub    $0x28,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 5c 16 00 00       	call   801758 <close>
	close(1);
  8000fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800103:	e8 50 16 00 00       	call   801758 <close>
	opencons();
  800108:	e8 c7 02 00 00       	call   8003d4 <opencons>
	opencons();
  80010d:	e8 c2 02 00 00       	call   8003d4 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800112:	83 c4 08             	add    $0x8,%esp
  800115:	6a 00                	push   $0x0
  800117:	68 08 2a 80 00       	push   $0x802a08
  80011c:	e8 be 19 00 00       	call   801adf <open>
  800121:	89 c6                	mov    %eax,%esi
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	85 c0                	test   %eax,%eax
  800128:	79 12                	jns    80013c <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  80012a:	50                   	push   %eax
  80012b:	68 15 2a 80 00       	push   $0x802a15
  800130:	6a 13                	push   $0x13
  800132:	68 2b 2a 80 00       	push   $0x802a2b
  800137:	e8 a8 03 00 00       	call   8004e4 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 f2 21 00 00       	call   80233a <pipe>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	79 12                	jns    800161 <umain+0x75>
		panic("pipe: %e", wfd);
  80014f:	50                   	push   %eax
  800150:	68 3c 2a 80 00       	push   $0x802a3c
  800155:	6a 15                	push   $0x15
  800157:	68 2b 2a 80 00       	push   $0x802a2b
  80015c:	e8 83 03 00 00       	call   8004e4 <_panic>
	wfd = pfds[1];
  800161:	8b 7d ec             	mov    -0x14(%ebp),%edi

	cprintf("running sh -x < testshell.sh | cat\n");
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	68 a4 29 80 00       	push   $0x8029a4
  80016c:	e8 14 04 00 00       	call   800585 <cprintf>
	if ((r = fork()) < 0)
  800171:	e8 54 0f 00 00       	call   8010ca <fork>
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	85 c0                	test   %eax,%eax
  80017b:	79 12                	jns    80018f <umain+0xa3>
		panic("fork: %e", r);
  80017d:	50                   	push   %eax
  80017e:	68 45 2a 80 00       	push   $0x802a45
  800183:	6a 1a                	push   $0x1a
  800185:	68 2b 2a 80 00       	push   $0x802a2b
  80018a:	e8 55 03 00 00       	call   8004e4 <_panic>
	if (r == 0) {
  80018f:	85 c0                	test   %eax,%eax
  800191:	75 7d                	jne    800210 <umain+0x124>
		dup(rfd, 0);
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	6a 00                	push   $0x0
  800198:	56                   	push   %esi
  800199:	e8 24 16 00 00       	call   8017c2 <dup>
		dup(wfd, 1);
  80019e:	83 c4 08             	add    $0x8,%esp
  8001a1:	6a 01                	push   $0x1
  8001a3:	57                   	push   %edi
  8001a4:	e8 19 16 00 00       	call   8017c2 <dup>
		close(rfd);
  8001a9:	89 34 24             	mov    %esi,(%esp)
  8001ac:	e8 a7 15 00 00       	call   801758 <close>
		close(wfd);
  8001b1:	89 3c 24             	mov    %edi,(%esp)
  8001b4:	e8 9f 15 00 00       	call   801758 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b9:	6a 00                	push   $0x0
  8001bb:	68 4e 2a 80 00       	push   $0x802a4e
  8001c0:	68 12 2a 80 00       	push   $0x802a12
  8001c5:	68 51 2a 80 00       	push   $0x802a51
  8001ca:	e8 f0 1e 00 00       	call   8020bf <spawnl>
  8001cf:	89 c3                	mov    %eax,%ebx
  8001d1:	83 c4 20             	add    $0x20,%esp
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	79 12                	jns    8001ea <umain+0xfe>
			panic("spawn: %e", r);
  8001d8:	50                   	push   %eax
  8001d9:	68 55 2a 80 00       	push   $0x802a55
  8001de:	6a 21                	push   $0x21
  8001e0:	68 2b 2a 80 00       	push   $0x802a2b
  8001e5:	e8 fa 02 00 00       	call   8004e4 <_panic>
		close(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 64 15 00 00       	call   801758 <close>
		close(1);
  8001f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fb:	e8 58 15 00 00       	call   801758 <close>
		wait(r);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 84 22 00 00       	call   80248c <wait>
		exit();
  800208:	e8 c3 02 00 00       	call   8004d0 <exit>
  80020d:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	56                   	push   %esi
  800214:	e8 3f 15 00 00       	call   801758 <close>
	close(wfd);
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	e8 37 15 00 00       	call   801758 <close>

	rfd = pfds[0];
  800221:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800224:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800227:	83 c4 08             	add    $0x8,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	68 5f 2a 80 00       	push   $0x802a5f
  800231:	e8 a9 18 00 00       	call   801adf <open>
  800236:	89 c6                	mov    %eax,%esi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 12                	jns    800251 <umain+0x165>
		panic("open testshell.key for reading: %e", kfd);
  80023f:	50                   	push   %eax
  800240:	68 c8 29 80 00       	push   $0x8029c8
  800245:	6a 2c                	push   $0x2c
  800247:	68 2b 2a 80 00       	push   $0x802a2b
  80024c:	e8 93 02 00 00       	call   8004e4 <_panic>
  800251:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800258:	bf 01 00 00 00       	mov    $0x1,%edi

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025d:	83 ec 04             	sub    $0x4,%esp
  800260:	6a 01                	push   $0x1
  800262:	8d 45 f3             	lea    -0xd(%ebp),%eax
  800265:	50                   	push   %eax
  800266:	ff 75 e0             	pushl  -0x20(%ebp)
  800269:	e8 94 13 00 00       	call   801602 <read>
  80026e:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  800270:	83 c4 0c             	add    $0xc,%esp
  800273:	6a 01                	push   $0x1
  800275:	8d 45 f2             	lea    -0xe(%ebp),%eax
  800278:	50                   	push   %eax
  800279:	56                   	push   %esi
  80027a:	e8 83 13 00 00       	call   801602 <read>
		if (n1 < 0)
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	85 db                	test   %ebx,%ebx
  800284:	79 12                	jns    800298 <umain+0x1ac>
			panic("reading testshell.out: %e", n1);
  800286:	53                   	push   %ebx
  800287:	68 6d 2a 80 00       	push   $0x802a6d
  80028c:	6a 33                	push   $0x33
  80028e:	68 2b 2a 80 00       	push   $0x802a2b
  800293:	e8 4c 02 00 00       	call   8004e4 <_panic>
		if (n2 < 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	79 12                	jns    8002ae <umain+0x1c2>
			panic("reading testshell.key: %e", n2);
  80029c:	50                   	push   %eax
  80029d:	68 87 2a 80 00       	push   $0x802a87
  8002a2:	6a 35                	push   $0x35
  8002a4:	68 2b 2a 80 00       	push   $0x802a2b
  8002a9:	e8 36 02 00 00       	call   8004e4 <_panic>
		if (n1 == 0 && n2 == 0)
  8002ae:	85 db                	test   %ebx,%ebx
  8002b0:	75 06                	jne    8002b8 <umain+0x1cc>
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	75 14                	jne    8002ca <umain+0x1de>
  8002b6:	eb 33                	jmp    8002eb <umain+0x1ff>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b8:	83 fb 01             	cmp    $0x1,%ebx
  8002bb:	75 0d                	jne    8002ca <umain+0x1de>
  8002bd:	83 f8 01             	cmp    $0x1,%eax
  8002c0:	75 08                	jne    8002ca <umain+0x1de>
  8002c2:	8a 45 f3             	mov    -0xd(%ebp),%al
  8002c5:	3a 45 f2             	cmp    -0xe(%ebp),%al
  8002c8:	74 12                	je     8002dc <umain+0x1f0>
			wrong(rfd, kfd, nloff);
  8002ca:	83 ec 04             	sub    $0x4,%esp
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	56                   	push   %esi
  8002d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d4:	e8 5b fd ff ff       	call   800034 <wrong>
  8002d9:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
  8002dc:	80 7d f3 0a          	cmpb   $0xa,-0xd(%ebp)
  8002e0:	75 03                	jne    8002e5 <umain+0x1f9>
  8002e2:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8002e5:	47                   	inc    %edi
  8002e6:	e9 72 ff ff ff       	jmp    80025d <umain+0x171>
			nloff = off+1;
	}
	cprintf("shell ran correctly\n");
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	68 a1 2a 80 00       	push   $0x802aa1
  8002f3:	e8 8d 02 00 00       	call   800585 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8002f8:	cc                   	int3   
  8002f9:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8002fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800307:	b8 00 00 00 00       	mov    $0x0,%eax
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800314:	68 b6 2a 80 00       	push   $0x802ab6
  800319:	ff 75 0c             	pushl  0xc(%ebp)
  80031c:	e8 b6 07 00 00       	call   800ad7 <strcpy>
	return 0;
}
  800321:	b8 00 00 00 00       	mov    $0x0,%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800334:	be 00 00 00 00       	mov    $0x0,%esi
  800339:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  80033f:	eb 2c                	jmp    80036d <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800341:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800344:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800346:	83 fb 7f             	cmp    $0x7f,%ebx
  800349:	76 05                	jbe    800350 <devcons_write+0x28>
  80034b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	53                   	push   %ebx
  800354:	03 45 0c             	add    0xc(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	57                   	push   %edi
  800359:	e8 e6 08 00 00       	call   800c44 <memmove>
		sys_cputs(buf, m);
  80035e:	83 c4 08             	add    $0x8,%esp
  800361:	53                   	push   %ebx
  800362:	57                   	push   %edi
  800363:	e8 b3 0a 00 00       	call   800e1b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800368:	01 de                	add    %ebx,%esi
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	89 f0                	mov    %esi,%eax
  80036f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800372:	72 cd                	jb     800341 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800374:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800382:	8b 45 08             	mov    0x8(%ebp),%eax
  800385:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800388:	6a 01                	push   $0x1
  80038a:	8d 45 ff             	lea    -0x1(%ebp),%eax
  80038d:	50                   	push   %eax
  80038e:	e8 88 0a 00 00       	call   800e1b <sys_cputs>
  800393:	83 c4 10             	add    $0x10,%esp
}
  800396:	c9                   	leave  
  800397:	c3                   	ret    

00800398 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80039e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8003a2:	74 27                	je     8003cb <devcons_read+0x33>
  8003a4:	eb 05                	jmp    8003ab <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8003a6:	e8 85 0c 00 00       	call   801030 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8003ab:	e8 4c 0a 00 00       	call   800dfc <sys_cgetc>
  8003b0:	89 c2                	mov    %eax,%edx
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	74 f0                	je     8003a6 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8003b6:	85 c0                	test   %eax,%eax
  8003b8:	78 16                	js     8003d0 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8003ba:	83 f8 04             	cmp    $0x4,%eax
  8003bd:	74 0c                	je     8003cb <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  8003bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c2:	88 10                	mov    %dl,(%eax)
  8003c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8003c9:	eb 05                	jmp    8003d0 <devcons_read+0x38>
	return 1;
  8003cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d0:	89 d0                	mov    %edx,%eax
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8003da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 8d 0f 00 00       	call   801370 <fd_alloc>
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	78 3b                	js     800425 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8003ea:	83 ec 04             	sub    $0x4,%esp
  8003ed:	68 07 04 00 00       	push   $0x407
  8003f2:	ff 75 fc             	pushl  -0x4(%ebp)
  8003f5:	6a 00                	push   $0x0
  8003f7:	e8 f1 0b 00 00       	call   800fed <sys_page_alloc>
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	85 c0                	test   %eax,%eax
  800401:	78 22                	js     800425 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800403:	a1 00 40 80 00       	mov    0x804000,%eax
  800408:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80040b:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  80040d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800410:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800417:	83 ec 0c             	sub    $0xc,%esp
  80041a:	ff 75 fc             	pushl  -0x4(%ebp)
  80041d:	e8 26 0f 00 00       	call   801348 <fd2num>
  800422:	83 c4 10             	add    $0x10,%esp
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80042d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800430:	50                   	push   %eax
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 8a 0f 00 00       	call   8013c3 <fd_lookup>
  800439:	83 c4 10             	add    $0x10,%esp
  80043c:	85 c0                	test   %eax,%eax
  80043e:	78 11                	js     800451 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800440:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800443:	8b 00                	mov    (%eax),%eax
  800445:	3b 05 00 40 80 00    	cmp    0x804000,%eax
  80044b:	0f 94 c0             	sete   %al
  80044e:	0f b6 c0             	movzbl %al,%eax
}
  800451:	c9                   	leave  
  800452:	c3                   	ret    

00800453 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800459:	6a 01                	push   $0x1
  80045b:	8d 45 ff             	lea    -0x1(%ebp),%eax
  80045e:	50                   	push   %eax
  80045f:	6a 00                	push   $0x0
  800461:	e8 9c 11 00 00       	call   801602 <read>
	if (r < 0)
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 c0                	test   %eax,%eax
  80046b:	78 0f                	js     80047c <getchar+0x29>
		return r;
	if (r < 1)
  80046d:	85 c0                	test   %eax,%eax
  80046f:	75 07                	jne    800478 <getchar+0x25>
  800471:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800476:	eb 04                	jmp    80047c <getchar+0x29>
		return -E_EOF;
	return c;
  800478:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  80047c:	c9                   	leave  
  80047d:	c3                   	ret    
	...

00800480 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	8b 75 08             	mov    0x8(%ebp),%esi
  800488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80048b:	e8 bf 0b 00 00       	call   80104f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800490:	25 ff 03 00 00       	and    $0x3ff,%eax
  800495:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80049c:	c1 e0 07             	shl    $0x7,%eax
  80049f:	29 d0                	sub    %edx,%eax
  8004a1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a6:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004ab:	85 f6                	test   %esi,%esi
  8004ad:	7e 07                	jle    8004b6 <libmain+0x36>
		binaryname = argv[0];
  8004af:	8b 03                	mov    (%ebx),%eax
  8004b1:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	53                   	push   %ebx
  8004ba:	56                   	push   %esi
  8004bb:	e8 2c fc ff ff       	call   8000ec <umain>

	// exit gracefully
	exit();
  8004c0:	e8 0b 00 00 00       	call   8004d0 <exit>
  8004c5:	83 c4 10             	add    $0x10,%esp
}
  8004c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5e                   	pop    %esi
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    
	...

008004d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8004d6:	6a 00                	push   $0x0
  8004d8:	e8 91 0b 00 00       	call   80106e <sys_env_destroy>
  8004dd:	83 c4 10             	add    $0x10,%esp
}
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    
	...

008004e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8004eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ee:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f1:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8004f7:	e8 53 0b 00 00       	call   80104f <sys_getenvid>
  8004fc:	83 ec 0c             	sub    $0xc,%esp
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	ff 75 08             	pushl  0x8(%ebp)
  800505:	53                   	push   %ebx
  800506:	50                   	push   %eax
  800507:	68 cc 2a 80 00       	push   $0x802acc
  80050c:	e8 74 00 00 00       	call   800585 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800511:	83 c4 18             	add    $0x18,%esp
  800514:	ff 75 f8             	pushl  -0x8(%ebp)
  800517:	ff 75 10             	pushl  0x10(%ebp)
  80051a:	e8 15 00 00 00       	call   800534 <vcprintf>
	cprintf("\n");
  80051f:	c7 04 24 f8 29 80 00 	movl   $0x8029f8,(%esp)
  800526:	e8 5a 00 00 00       	call   800585 <cprintf>
  80052b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80052e:	cc                   	int3   
  80052f:	eb fd                	jmp    80052e <_panic+0x4a>
  800531:	00 00                	add    %al,(%eax)
	...

00800534 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80053d:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800544:	00 00 00 
	b.cnt = 0;
  800547:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  80054e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80055d:	50                   	push   %eax
  80055e:	68 9c 05 80 00       	push   $0x80059c
  800563:	e8 70 01 00 00       	call   8006d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800568:	83 c4 08             	add    $0x8,%esp
  80056b:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800571:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800577:	50                   	push   %eax
  800578:	e8 9e 08 00 00       	call   800e1b <sys_cputs>
  80057d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800583:	c9                   	leave  
  800584:	c3                   	ret    

00800585 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
  800588:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80058b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80058e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 9a ff ff ff       	call   800534 <vcprintf>
	va_end(ap);

	return cnt;
}
  80059a:	c9                   	leave  
  80059b:	c3                   	ret    

0080059c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	53                   	push   %ebx
  8005a0:	83 ec 04             	sub    $0x4,%esp
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005a6:	8b 03                	mov    (%ebx),%eax
  8005a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005af:	40                   	inc    %eax
  8005b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005b7:	75 1a                	jne    8005d3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	68 ff 00 00 00       	push   $0xff
  8005c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8005c4:	50                   	push   %eax
  8005c5:	e8 51 08 00 00       	call   800e1b <sys_cputs>
		b->idx = 0;
  8005ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8005d3:	ff 43 04             	incl   0x4(%ebx)
}
  8005d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    
	...

008005dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	57                   	push   %edi
  8005e0:	56                   	push   %esi
  8005e1:	53                   	push   %ebx
  8005e2:	83 ec 1c             	sub    $0x1c,%esp
  8005e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8005e8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f7:	8b 55 10             	mov    0x10(%ebp),%edx
  8005fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005fd:	89 d6                	mov    %edx,%esi
  8005ff:	bf 00 00 00 00       	mov    $0x0,%edi
  800604:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800607:	72 04                	jb     80060d <printnum+0x31>
  800609:	39 c2                	cmp    %eax,%edx
  80060b:	77 3f                	ja     80064c <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	ff 75 18             	pushl  0x18(%ebp)
  800613:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800616:	50                   	push   %eax
  800617:	52                   	push   %edx
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	57                   	push   %edi
  80061c:	56                   	push   %esi
  80061d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800620:	ff 75 e0             	pushl  -0x20(%ebp)
  800623:	e8 a8 20 00 00       	call   8026d0 <__udivdi3>
  800628:	83 c4 18             	add    $0x18,%esp
  80062b:	52                   	push   %edx
  80062c:	50                   	push   %eax
  80062d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800630:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800633:	e8 a4 ff ff ff       	call   8005dc <printnum>
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	eb 14                	jmp    800651 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	ff 75 e8             	pushl  -0x18(%ebp)
  800643:	ff 75 18             	pushl  0x18(%ebp)
  800646:	ff 55 ec             	call   *-0x14(%ebp)
  800649:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80064c:	4b                   	dec    %ebx
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7f ec                	jg     80063d <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 e8             	pushl  -0x18(%ebp)
  800657:	83 ec 04             	sub    $0x4,%esp
  80065a:	57                   	push   %edi
  80065b:	56                   	push   %esi
  80065c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065f:	ff 75 e0             	pushl  -0x20(%ebp)
  800662:	e8 95 21 00 00       	call   8027fc <__umoddi3>
  800667:	83 c4 14             	add    $0x14,%esp
  80066a:	0f be 80 ef 2a 80 00 	movsbl 0x802aef(%eax),%eax
  800671:	50                   	push   %eax
  800672:	ff 55 ec             	call   *-0x14(%ebp)
  800675:	83 c4 10             	add    $0x10,%esp
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	c9                   	leave  
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800685:	83 fa 01             	cmp    $0x1,%edx
  800688:	7e 0e                	jle    800698 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	8d 42 08             	lea    0x8(%edx),%eax
  80068f:	89 01                	mov    %eax,(%ecx)
  800691:	8b 02                	mov    (%edx),%eax
  800693:	8b 52 04             	mov    0x4(%edx),%edx
  800696:	eb 22                	jmp    8006ba <getuint+0x3a>
	else if (lflag)
  800698:	85 d2                	test   %edx,%edx
  80069a:	74 10                	je     8006ac <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8d 42 04             	lea    0x4(%edx),%eax
  8006a1:	89 01                	mov    %eax,(%ecx)
  8006a3:	8b 02                	mov    (%edx),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006aa:	eb 0e                	jmp    8006ba <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8d 42 04             	lea    0x4(%edx),%eax
  8006b1:	89 01                	mov    %eax,(%ecx)
  8006b3:	8b 02                	mov    (%edx),%eax
  8006b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8006c2:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8006c5:	8b 11                	mov    (%ecx),%edx
  8006c7:	3b 51 04             	cmp    0x4(%ecx),%edx
  8006ca:	73 0a                	jae    8006d6 <sprintputch+0x1a>
		*b->buf++ = ch;
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	88 02                	mov    %al,(%edx)
  8006d1:	8d 42 01             	lea    0x1(%edx),%eax
  8006d4:	89 01                	mov    %eax,(%ecx)
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	57                   	push   %edi
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	83 ec 3c             	sub    $0x3c,%esp
  8006e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8006e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006ea:	eb 1a                	jmp    800706 <vprintfmt+0x2e>
  8006ec:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8006ef:	eb 15                	jmp    800706 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f1:	84 c0                	test   %al,%al
  8006f3:	0f 84 15 03 00 00    	je     800a0e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	0f b6 c0             	movzbl %al,%eax
  800700:	50                   	push   %eax
  800701:	ff d6                	call   *%esi
  800703:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800706:	8a 03                	mov    (%ebx),%al
  800708:	43                   	inc    %ebx
  800709:	3c 25                	cmp    $0x25,%al
  80070b:	75 e4                	jne    8006f1 <vprintfmt+0x19>
  80070d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800714:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80071b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800722:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800729:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80072d:	eb 0a                	jmp    800739 <vprintfmt+0x61>
  80072f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800736:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8a 03                	mov    (%ebx),%al
  80073b:	0f b6 d0             	movzbl %al,%edx
  80073e:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800741:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800744:	83 e8 23             	sub    $0x23,%eax
  800747:	3c 55                	cmp    $0x55,%al
  800749:	0f 87 9c 02 00 00    	ja     8009eb <vprintfmt+0x313>
  80074f:	0f b6 c0             	movzbl %al,%eax
  800752:	ff 24 85 40 2c 80 00 	jmp    *0x802c40(,%eax,4)
  800759:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  80075d:	eb d7                	jmp    800736 <vprintfmt+0x5e>
  80075f:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800763:	eb d1                	jmp    800736 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800765:	89 d9                	mov    %ebx,%ecx
  800767:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80076e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800771:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800774:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800778:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80077b:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80077f:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800780:	8d 42 d0             	lea    -0x30(%edx),%eax
  800783:	83 f8 09             	cmp    $0x9,%eax
  800786:	77 21                	ja     8007a9 <vprintfmt+0xd1>
  800788:	eb e4                	jmp    80076e <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80078a:	8b 55 14             	mov    0x14(%ebp),%edx
  80078d:	8d 42 04             	lea    0x4(%edx),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
  800793:	8b 12                	mov    (%edx),%edx
  800795:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800798:	eb 12                	jmp    8007ac <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80079a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80079e:	79 96                	jns    800736 <vprintfmt+0x5e>
  8007a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8007a7:	eb 8d                	jmp    800736 <vprintfmt+0x5e>
  8007a9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8007ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007b0:	79 84                	jns    800736 <vprintfmt+0x5e>
  8007b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007bf:	e9 72 ff ff ff       	jmp    800736 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c4:	ff 45 d4             	incl   -0x2c(%ebp)
  8007c7:	e9 6a ff ff ff       	jmp    800736 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007cc:	8b 55 14             	mov    0x14(%ebp),%edx
  8007cf:	8d 42 04             	lea    0x4(%edx),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	57                   	push   %edi
  8007d9:	ff 32                	pushl  (%edx)
  8007db:	ff d6                	call   *%esi
			break;
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	e9 07 ff ff ff       	jmp    8006ec <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007e5:	8b 55 14             	mov    0x14(%ebp),%edx
  8007e8:	8d 42 04             	lea    0x4(%edx),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ee:	8b 02                	mov    (%edx),%eax
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	79 02                	jns    8007f6 <vprintfmt+0x11e>
  8007f4:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007f6:	83 f8 0f             	cmp    $0xf,%eax
  8007f9:	7f 0b                	jg     800806 <vprintfmt+0x12e>
  8007fb:	8b 14 85 a0 2d 80 00 	mov    0x802da0(,%eax,4),%edx
  800802:	85 d2                	test   %edx,%edx
  800804:	75 15                	jne    80081b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800806:	50                   	push   %eax
  800807:	68 00 2b 80 00       	push   $0x802b00
  80080c:	57                   	push   %edi
  80080d:	56                   	push   %esi
  80080e:	e8 6e 02 00 00       	call   800a81 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	e9 d1 fe ff ff       	jmp    8006ec <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80081b:	52                   	push   %edx
  80081c:	68 15 30 80 00       	push   $0x803015
  800821:	57                   	push   %edi
  800822:	56                   	push   %esi
  800823:	e8 59 02 00 00       	call   800a81 <printfmt>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	e9 bc fe ff ff       	jmp    8006ec <vprintfmt+0x14>
  800830:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800833:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800836:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800839:	8b 55 14             	mov    0x14(%ebp),%edx
  80083c:	8d 42 04             	lea    0x4(%edx),%eax
  80083f:	89 45 14             	mov    %eax,0x14(%ebp)
  800842:	8b 1a                	mov    (%edx),%ebx
  800844:	85 db                	test   %ebx,%ebx
  800846:	75 05                	jne    80084d <vprintfmt+0x175>
  800848:	bb 09 2b 80 00       	mov    $0x802b09,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  80084d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800851:	7e 66                	jle    8008b9 <vprintfmt+0x1e1>
  800853:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800857:	74 60                	je     8008b9 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	51                   	push   %ecx
  80085d:	53                   	push   %ebx
  80085e:	e8 57 02 00 00       	call   800aba <strnlen>
  800863:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800866:	29 c1                	sub    %eax,%ecx
  800868:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800872:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800875:	eb 0f                	jmp    800886 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	57                   	push   %edi
  80087b:	ff 75 c4             	pushl  -0x3c(%ebp)
  80087e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800880:	ff 4d d8             	decl   -0x28(%ebp)
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80088a:	7f eb                	jg     800877 <vprintfmt+0x19f>
  80088c:	eb 2b                	jmp    8008b9 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80088e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800891:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800895:	74 15                	je     8008ac <vprintfmt+0x1d4>
  800897:	8d 42 e0             	lea    -0x20(%edx),%eax
  80089a:	83 f8 5e             	cmp    $0x5e,%eax
  80089d:	76 0d                	jbe    8008ac <vprintfmt+0x1d4>
					putch('?', putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	57                   	push   %edi
  8008a3:	6a 3f                	push   $0x3f
  8008a5:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	eb 0a                	jmp    8008b6 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	57                   	push   %edi
  8008b0:	52                   	push   %edx
  8008b1:	ff d6                	call   *%esi
  8008b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008b6:	ff 4d d8             	decl   -0x28(%ebp)
  8008b9:	8a 03                	mov    (%ebx),%al
  8008bb:	43                   	inc    %ebx
  8008bc:	84 c0                	test   %al,%al
  8008be:	74 1b                	je     8008db <vprintfmt+0x203>
  8008c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c4:	78 c8                	js     80088e <vprintfmt+0x1b6>
  8008c6:	ff 4d dc             	decl   -0x24(%ebp)
  8008c9:	79 c3                	jns    80088e <vprintfmt+0x1b6>
  8008cb:	eb 0e                	jmp    8008db <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	57                   	push   %edi
  8008d1:	6a 20                	push   $0x20
  8008d3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008d5:	ff 4d d8             	decl   -0x28(%ebp)
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008df:	7f ec                	jg     8008cd <vprintfmt+0x1f5>
  8008e1:	e9 06 fe ff ff       	jmp    8006ec <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008e6:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8008ea:	7e 10                	jle    8008fc <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8008ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8008ef:	8d 42 08             	lea    0x8(%edx),%eax
  8008f2:	89 45 14             	mov    %eax,0x14(%ebp)
  8008f5:	8b 02                	mov    (%edx),%eax
  8008f7:	8b 52 04             	mov    0x4(%edx),%edx
  8008fa:	eb 20                	jmp    80091c <vprintfmt+0x244>
	else if (lflag)
  8008fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800900:	74 0e                	je     800910 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	8b 00                	mov    (%eax),%eax
  80090d:	99                   	cltd   
  80090e:	eb 0c                	jmp    80091c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8d 50 04             	lea    0x4(%eax),%edx
  800916:	89 55 14             	mov    %edx,0x14(%ebp)
  800919:	8b 00                	mov    (%eax),%eax
  80091b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80091c:	89 d1                	mov    %edx,%ecx
  80091e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800920:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800923:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	78 0a                	js     800934 <vprintfmt+0x25c>
  80092a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80092f:	e9 89 00 00 00       	jmp    8009bd <vprintfmt+0x2e5>
				putch('-', putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	57                   	push   %edi
  800938:	6a 2d                	push   $0x2d
  80093a:	ff d6                	call   *%esi
				num = -(long long) num;
  80093c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80093f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800942:	f7 da                	neg    %edx
  800944:	83 d1 00             	adc    $0x0,%ecx
  800947:	f7 d9                	neg    %ecx
  800949:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	eb 6a                	jmp    8009bd <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
  800956:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800959:	e8 22 fd ff ff       	call   800680 <getuint>
  80095e:	89 d1                	mov    %edx,%ecx
  800960:	89 c2                	mov    %eax,%edx
  800962:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800967:	eb 54                	jmp    8009bd <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800969:	8d 45 14             	lea    0x14(%ebp),%eax
  80096c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80096f:	e8 0c fd ff ff       	call   800680 <getuint>
  800974:	89 d1                	mov    %edx,%ecx
  800976:	89 c2                	mov    %eax,%edx
  800978:	bb 08 00 00 00       	mov    $0x8,%ebx
  80097d:	eb 3e                	jmp    8009bd <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	57                   	push   %edi
  800983:	6a 30                	push   $0x30
  800985:	ff d6                	call   *%esi
			putch('x', putdat);
  800987:	83 c4 08             	add    $0x8,%esp
  80098a:	57                   	push   %edi
  80098b:	6a 78                	push   $0x78
  80098d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80098f:	8b 55 14             	mov    0x14(%ebp),%edx
  800992:	8d 42 04             	lea    0x4(%edx),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
  800998:	8b 12                	mov    (%edx),%edx
  80099a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009a4:	83 c4 10             	add    $0x10,%esp
  8009a7:	eb 14                	jmp    8009bd <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009af:	e8 cc fc ff ff       	call   800680 <getuint>
  8009b4:	89 d1                	mov    %edx,%ecx
  8009b6:	89 c2                	mov    %eax,%edx
  8009b8:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009bd:	83 ec 0c             	sub    $0xc,%esp
  8009c0:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8009c4:	50                   	push   %eax
  8009c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c8:	53                   	push   %ebx
  8009c9:	51                   	push   %ecx
  8009ca:	52                   	push   %edx
  8009cb:	89 fa                	mov    %edi,%edx
  8009cd:	89 f0                	mov    %esi,%eax
  8009cf:	e8 08 fc ff ff       	call   8005dc <printnum>
			break;
  8009d4:	83 c4 20             	add    $0x20,%esp
  8009d7:	e9 10 fd ff ff       	jmp    8006ec <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	57                   	push   %edi
  8009e0:	52                   	push   %edx
  8009e1:	ff d6                	call   *%esi
			break;
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	e9 01 fd ff ff       	jmp    8006ec <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009eb:	83 ec 08             	sub    $0x8,%esp
  8009ee:	57                   	push   %edi
  8009ef:	6a 25                	push   $0x25
  8009f1:	ff d6                	call   *%esi
  8009f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8009f6:	83 ea 02             	sub    $0x2,%edx
  8009f9:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009fc:	8a 02                	mov    (%edx),%al
  8009fe:	4a                   	dec    %edx
  8009ff:	3c 25                	cmp    $0x25,%al
  800a01:	75 f9                	jne    8009fc <vprintfmt+0x324>
  800a03:	83 c2 02             	add    $0x2,%edx
  800a06:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800a09:	e9 de fc ff ff       	jmp    8006ec <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800a0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5f                   	pop    %edi
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 18             	sub    $0x18,%esp
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 37                	je     800a5d <vsnprintf+0x47>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	7e 33                	jle    800a5d <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a2a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a31:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a35:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800a38:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a3b:	ff 75 14             	pushl  0x14(%ebp)
  800a3e:	ff 75 10             	pushl  0x10(%ebp)
  800a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a44:	50                   	push   %eax
  800a45:	68 bc 06 80 00       	push   $0x8006bc
  800a4a:	e8 89 fc ff ff       	call   8006d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a52:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a58:	83 c4 10             	add    $0x10,%esp
  800a5b:	eb 05                	jmp    800a62 <vsnprintf+0x4c>
  800a5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a70:	50                   	push   %eax
  800a71:	ff 75 10             	pushl  0x10(%ebp)
  800a74:	ff 75 0c             	pushl  0xc(%ebp)
  800a77:	ff 75 08             	pushl  0x8(%ebp)
  800a7a:	e8 97 ff ff ff       	call   800a16 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a87:	8d 45 14             	lea    0x14(%ebp),%eax
  800a8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800a8d:	50                   	push   %eax
  800a8e:	ff 75 10             	pushl  0x10(%ebp)
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	ff 75 08             	pushl  0x8(%ebp)
  800a97:	e8 3c fc ff ff       	call   8006d8 <vprintfmt>
	va_end(ap);
  800a9c:	83 c4 10             	add    $0x10,%esp
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    
  800aa1:	00 00                	add    %al,(%eax)
	...

00800aa4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	eb 01                	jmp    800ab2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800ab1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800ab6:	75 f9                	jne    800ab1 <strlen+0xd>
		n++;
	return n;
}
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	eb 01                	jmp    800acb <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800aca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800acb:	39 d0                	cmp    %edx,%eax
  800acd:	74 06                	je     800ad5 <strnlen+0x1b>
  800acf:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800ad3:	75 f5                	jne    800aca <strnlen+0x10>
		n++;
	return n;
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae0:	8a 01                	mov    (%ecx),%al
  800ae2:	88 02                	mov    %al,(%edx)
  800ae4:	42                   	inc    %edx
  800ae5:	41                   	inc    %ecx
  800ae6:	84 c0                	test   %al,%al
  800ae8:	75 f6                	jne    800ae0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800af6:	53                   	push   %ebx
  800af7:	e8 a8 ff ff ff       	call   800aa4 <strlen>
	strcpy(dst + len, src);
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b02:	50                   	push   %eax
  800b03:	e8 cf ff ff ff       	call   800ad7 <strcpy>
	return dst;
}
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 75 08             	mov    0x8(%ebp),%esi
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b22:	eb 0c                	jmp    800b30 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800b24:	8a 02                	mov    (%edx),%al
  800b26:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b29:	80 3a 01             	cmpb   $0x1,(%edx)
  800b2c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b2f:	41                   	inc    %ecx
  800b30:	39 d9                	cmp    %ebx,%ecx
  800b32:	75 f0                	jne    800b24 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b34:	89 f0                	mov    %esi,%eax
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 75 08             	mov    0x8(%ebp),%esi
  800b42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b48:	85 c9                	test   %ecx,%ecx
  800b4a:	75 04                	jne    800b50 <strlcpy+0x16>
  800b4c:	89 f0                	mov    %esi,%eax
  800b4e:	eb 14                	jmp    800b64 <strlcpy+0x2a>
  800b50:	89 f0                	mov    %esi,%eax
  800b52:	eb 04                	jmp    800b58 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b54:	88 10                	mov    %dl,(%eax)
  800b56:	40                   	inc    %eax
  800b57:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b58:	49                   	dec    %ecx
  800b59:	74 06                	je     800b61 <strlcpy+0x27>
  800b5b:	8a 13                	mov    (%ebx),%dl
  800b5d:	84 d2                	test   %dl,%dl
  800b5f:	75 f3                	jne    800b54 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800b61:	c6 00 00             	movb   $0x0,(%eax)
  800b64:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	eb 02                	jmp    800b77 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800b75:	42                   	inc    %edx
  800b76:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b77:	8a 02                	mov    (%edx),%al
  800b79:	84 c0                	test   %al,%al
  800b7b:	74 04                	je     800b81 <strcmp+0x17>
  800b7d:	3a 01                	cmp    (%ecx),%al
  800b7f:	74 f4                	je     800b75 <strcmp+0xb>
  800b81:	0f b6 c0             	movzbl %al,%eax
  800b84:	0f b6 11             	movzbl (%ecx),%edx
  800b87:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b95:	8b 55 10             	mov    0x10(%ebp),%edx
  800b98:	eb 03                	jmp    800b9d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800b9a:	4a                   	dec    %edx
  800b9b:	41                   	inc    %ecx
  800b9c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b9d:	85 d2                	test   %edx,%edx
  800b9f:	75 07                	jne    800ba8 <strncmp+0x1d>
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	eb 14                	jmp    800bbc <strncmp+0x31>
  800ba8:	8a 01                	mov    (%ecx),%al
  800baa:	84 c0                	test   %al,%al
  800bac:	74 04                	je     800bb2 <strncmp+0x27>
  800bae:	3a 03                	cmp    (%ebx),%al
  800bb0:	74 e8                	je     800b9a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb2:	0f b6 d0             	movzbl %al,%edx
  800bb5:	0f b6 03             	movzbl (%ebx),%eax
  800bb8:	29 c2                	sub    %eax,%edx
  800bba:	89 d0                	mov    %edx,%eax
}
  800bbc:	5b                   	pop    %ebx
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800bc8:	eb 05                	jmp    800bcf <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800bca:	38 ca                	cmp    %cl,%dl
  800bcc:	74 0c                	je     800bda <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bce:	40                   	inc    %eax
  800bcf:	8a 10                	mov    (%eax),%dl
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	75 f5                	jne    800bca <strchr+0xb>
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800be5:	eb 05                	jmp    800bec <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800be7:	38 ca                	cmp    %cl,%dl
  800be9:	74 07                	je     800bf2 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800beb:	40                   	inc    %eax
  800bec:	8a 10                	mov    (%eax),%dl
  800bee:	84 d2                	test   %dl,%dl
  800bf0:	75 f5                	jne    800be7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	74 36                	je     800c3d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0d:	75 29                	jne    800c38 <memset+0x44>
  800c0f:	f6 c3 03             	test   $0x3,%bl
  800c12:	75 24                	jne    800c38 <memset+0x44>
		c &= 0xFF;
  800c14:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	c1 e6 08             	shl    $0x8,%esi
  800c1c:	89 d0                	mov    %edx,%eax
  800c1e:	c1 e0 18             	shl    $0x18,%eax
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	c1 e1 10             	shl    $0x10,%ecx
  800c26:	09 c8                	or     %ecx,%eax
  800c28:	09 c2                	or     %eax,%edx
  800c2a:	89 f0                	mov    %esi,%eax
  800c2c:	09 d0                	or     %edx,%eax
  800c2e:	89 d9                	mov    %ebx,%ecx
  800c30:	c1 e9 02             	shr    $0x2,%ecx
  800c33:	fc                   	cld    
  800c34:	f3 ab                	rep stos %eax,%es:(%edi)
  800c36:	eb 05                	jmp    800c3d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c38:	89 d9                	mov    %ebx,%ecx
  800c3a:	fc                   	cld    
  800c3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c3d:	89 f8                	mov    %edi,%eax
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800c4f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c52:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c54:	39 c6                	cmp    %eax,%esi
  800c56:	73 36                	jae    800c8e <memmove+0x4a>
  800c58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	73 2f                	jae    800c8e <memmove+0x4a>
		s += n;
		d += n;
  800c5f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c62:	f6 c2 03             	test   $0x3,%dl
  800c65:	75 1b                	jne    800c82 <memmove+0x3e>
  800c67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c6d:	75 13                	jne    800c82 <memmove+0x3e>
  800c6f:	f6 c1 03             	test   $0x3,%cl
  800c72:	75 0e                	jne    800c82 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800c74:	8d 7e fc             	lea    -0x4(%esi),%edi
  800c77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c7a:	c1 e9 02             	shr    $0x2,%ecx
  800c7d:	fd                   	std    
  800c7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c80:	eb 09                	jmp    800c8b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c82:	8d 7e ff             	lea    -0x1(%esi),%edi
  800c85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c88:	fd                   	std    
  800c89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8b:	fc                   	cld    
  800c8c:	eb 20                	jmp    800cae <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c94:	75 15                	jne    800cab <memmove+0x67>
  800c96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9c:	75 0d                	jne    800cab <memmove+0x67>
  800c9e:	f6 c1 03             	test   $0x3,%cl
  800ca1:	75 08                	jne    800cab <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800ca3:	c1 e9 02             	shr    $0x2,%ecx
  800ca6:	fc                   	cld    
  800ca7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca9:	eb 03                	jmp    800cae <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cab:	fc                   	cld    
  800cac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	ff 75 08             	pushl  0x8(%ebp)
  800cbe:	e8 81 ff ff ff       	call   800c44 <memmove>
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    

00800cc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 04             	sub    $0x4,%esp
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	eb 1b                	jmp    800cf2 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800cd7:	8a 1a                	mov    (%edx),%bl
  800cd9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800cdc:	8a 19                	mov    (%ecx),%bl
  800cde:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800ce1:	74 0d                	je     800cf0 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800ce3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800ce7:	0f b6 c3             	movzbl %bl,%eax
  800cea:	29 c2                	sub    %eax,%edx
  800cec:	89 d0                	mov    %edx,%eax
  800cee:	eb 0d                	jmp    800cfd <memcmp+0x38>
		s1++, s2++;
  800cf0:	42                   	inc    %edx
  800cf1:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf2:	48                   	dec    %eax
  800cf3:	83 f8 ff             	cmp    $0xffffffff,%eax
  800cf6:	75 df                	jne    800cd7 <memcmp+0x12>
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cfd:	83 c4 04             	add    $0x4,%esp
  800d00:	5b                   	pop    %ebx
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	8b 45 08             	mov    0x8(%ebp),%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	03 55 10             	add    0x10(%ebp),%edx
  800d11:	eb 05                	jmp    800d18 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800d13:	38 08                	cmp    %cl,(%eax)
  800d15:	74 05                	je     800d1c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d17:	40                   	inc    %eax
  800d18:	39 d0                	cmp    %edx,%eax
  800d1a:	72 f7                	jb     800d13 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 04             	sub    $0x4,%esp
  800d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2a:	8b 75 10             	mov    0x10(%ebp),%esi
  800d2d:	eb 01                	jmp    800d30 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800d2f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d30:	8a 01                	mov    (%ecx),%al
  800d32:	3c 20                	cmp    $0x20,%al
  800d34:	74 f9                	je     800d2f <strtol+0x11>
  800d36:	3c 09                	cmp    $0x9,%al
  800d38:	74 f5                	je     800d2f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d3a:	3c 2b                	cmp    $0x2b,%al
  800d3c:	75 0a                	jne    800d48 <strtol+0x2a>
		s++;
  800d3e:	41                   	inc    %ecx
  800d3f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d46:	eb 17                	jmp    800d5f <strtol+0x41>
	else if (*s == '-')
  800d48:	3c 2d                	cmp    $0x2d,%al
  800d4a:	74 09                	je     800d55 <strtol+0x37>
  800d4c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d53:	eb 0a                	jmp    800d5f <strtol+0x41>
		s++, neg = 1;
  800d55:	8d 49 01             	lea    0x1(%ecx),%ecx
  800d58:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d5f:	85 f6                	test   %esi,%esi
  800d61:	74 05                	je     800d68 <strtol+0x4a>
  800d63:	83 fe 10             	cmp    $0x10,%esi
  800d66:	75 1a                	jne    800d82 <strtol+0x64>
  800d68:	8a 01                	mov    (%ecx),%al
  800d6a:	3c 30                	cmp    $0x30,%al
  800d6c:	75 10                	jne    800d7e <strtol+0x60>
  800d6e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d72:	75 0a                	jne    800d7e <strtol+0x60>
		s += 2, base = 16;
  800d74:	83 c1 02             	add    $0x2,%ecx
  800d77:	be 10 00 00 00       	mov    $0x10,%esi
  800d7c:	eb 04                	jmp    800d82 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800d7e:	85 f6                	test   %esi,%esi
  800d80:	74 07                	je     800d89 <strtol+0x6b>
  800d82:	bf 00 00 00 00       	mov    $0x0,%edi
  800d87:	eb 13                	jmp    800d9c <strtol+0x7e>
  800d89:	3c 30                	cmp    $0x30,%al
  800d8b:	74 07                	je     800d94 <strtol+0x76>
  800d8d:	be 0a 00 00 00       	mov    $0xa,%esi
  800d92:	eb ee                	jmp    800d82 <strtol+0x64>
		s++, base = 8;
  800d94:	41                   	inc    %ecx
  800d95:	be 08 00 00 00       	mov    $0x8,%esi
  800d9a:	eb e6                	jmp    800d82 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d9c:	8a 11                	mov    (%ecx),%dl
  800d9e:	88 d3                	mov    %dl,%bl
  800da0:	8d 42 d0             	lea    -0x30(%edx),%eax
  800da3:	3c 09                	cmp    $0x9,%al
  800da5:	77 08                	ja     800daf <strtol+0x91>
			dig = *s - '0';
  800da7:	0f be c2             	movsbl %dl,%eax
  800daa:	8d 50 d0             	lea    -0x30(%eax),%edx
  800dad:	eb 1c                	jmp    800dcb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800daf:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800db2:	3c 19                	cmp    $0x19,%al
  800db4:	77 08                	ja     800dbe <strtol+0xa0>
			dig = *s - 'a' + 10;
  800db6:	0f be c2             	movsbl %dl,%eax
  800db9:	8d 50 a9             	lea    -0x57(%eax),%edx
  800dbc:	eb 0d                	jmp    800dcb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800dbe:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800dc1:	3c 19                	cmp    $0x19,%al
  800dc3:	77 15                	ja     800dda <strtol+0xbc>
			dig = *s - 'A' + 10;
  800dc5:	0f be c2             	movsbl %dl,%eax
  800dc8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800dcb:	39 f2                	cmp    %esi,%edx
  800dcd:	7d 0b                	jge    800dda <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800dcf:	41                   	inc    %ecx
  800dd0:	89 f8                	mov    %edi,%eax
  800dd2:	0f af c6             	imul   %esi,%eax
  800dd5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800dd8:	eb c2                	jmp    800d9c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800dda:	89 f8                	mov    %edi,%eax

	if (endptr)
  800ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de0:	74 05                	je     800de7 <strtol+0xc9>
		*endptr = (char *) s;
  800de2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800de7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800deb:	74 04                	je     800df1 <strtol+0xd3>
  800ded:	89 c7                	mov    %eax,%edi
  800def:	f7 df                	neg    %edi
}
  800df1:	89 f8                	mov    %edi,%eax
  800df3:	83 c4 04             	add    $0x4,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    
	...

00800dfc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	89 f9                	mov    %edi,%ecx
  800e10:	89 fb                	mov    %edi,%ebx
  800e12:	89 fe                	mov    %edi,%esi
  800e14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2f:	89 f8                	mov    %edi,%eax
  800e31:	89 fb                	mov    %edi,%ebx
  800e33:	89 fe                	mov    %edi,%esi
  800e35:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e37:	83 c4 04             	add    $0x4,%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e50:	bf 00 00 00 00       	mov    $0x0,%edi
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	89 fb                	mov    %edi,%ebx
  800e59:	89 fe                	mov    %edi,%esi
  800e5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	7e 17                	jle    800e78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	50                   	push   %eax
  800e65:	6a 0d                	push   $0xd
  800e67:	68 ff 2d 80 00       	push   $0x802dff
  800e6c:	6a 23                	push   $0x23
  800e6e:	68 1c 2e 80 00       	push   $0x802e1c
  800e73:	e8 6c f6 ff ff       	call   8004e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e92:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e97:	be 00 00 00 00       	mov    $0x0,%esi
  800e9c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ebc:	89 fb                	mov    %edi,%ebx
  800ebe:	89 fe                	mov    %edi,%esi
  800ec0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	7e 17                	jle    800edd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	50                   	push   %eax
  800eca:	6a 0a                	push   $0xa
  800ecc:	68 ff 2d 80 00       	push   $0x802dff
  800ed1:	6a 23                	push   $0x23
  800ed3:	68 1c 2e 80 00       	push   $0x802e1c
  800ed8:	e8 07 f6 ff ff       	call   8004e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef9:	bf 00 00 00 00       	mov    $0x0,%edi
  800efe:	89 fb                	mov    %edi,%ebx
  800f00:	89 fe                	mov    %edi,%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 17                	jle    800f1f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 09                	push   $0x9
  800f0e:	68 ff 2d 80 00       	push   $0x802dff
  800f13:	6a 23                	push   $0x23
  800f15:	68 1c 2e 80 00       	push   $0x802e1c
  800f1a:	e8 c5 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 0c             	sub    $0xc,%esp
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f36:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f40:	89 fb                	mov    %edi,%ebx
  800f42:	89 fe                	mov    %edi,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 08                	push   $0x8
  800f50:	68 ff 2d 80 00       	push   $0x802dff
  800f55:	6a 23                	push   $0x23
  800f57:	68 1c 2e 80 00       	push   $0x802e1c
  800f5c:	e8 83 f5 ff ff       	call   8004e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f78:	b8 06 00 00 00       	mov    $0x6,%eax
  800f7d:	bf 00 00 00 00       	mov    $0x0,%edi
  800f82:	89 fb                	mov    %edi,%ebx
  800f84:	89 fe                	mov    %edi,%esi
  800f86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	7e 17                	jle    800fa3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	50                   	push   %eax
  800f90:	6a 06                	push   $0x6
  800f92:	68 ff 2d 80 00       	push   $0x802dff
  800f97:	6a 23                	push   $0x23
  800f99:	68 1c 2e 80 00       	push   $0x802e1c
  800f9e:	e8 41 f5 ff ff       	call   8004e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fc0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800fc8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	7e 17                	jle    800fe5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	50                   	push   %eax
  800fd2:	6a 05                	push   $0x5
  800fd4:	68 ff 2d 80 00       	push   $0x802dff
  800fd9:	6a 23                	push   $0x23
  800fdb:	68 1c 2e 80 00       	push   $0x802e1c
  800fe0:	e8 ff f4 ff ff       	call   8004e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	57                   	push   %edi
  800ff1:	56                   	push   %esi
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fff:	b8 04 00 00 00       	mov    $0x4,%eax
  801004:	bf 00 00 00 00       	mov    $0x0,%edi
  801009:	89 fe                	mov    %edi,%esi
  80100b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 17                	jle    801028 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	50                   	push   %eax
  801015:	6a 04                	push   $0x4
  801017:	68 ff 2d 80 00       	push   $0x802dff
  80101c:	6a 23                	push   $0x23
  80101e:	68 1c 2e 80 00       	push   $0x802e1c
  801023:	e8 bc f4 ff ff       	call   8004e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102b:	5b                   	pop    %ebx
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	c9                   	leave  
  80102f:	c3                   	ret    

00801030 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801036:	b8 0b 00 00 00       	mov    $0xb,%eax
  80103b:	bf 00 00 00 00       	mov    $0x0,%edi
  801040:	89 fa                	mov    %edi,%edx
  801042:	89 f9                	mov    %edi,%ecx
  801044:	89 fb                	mov    %edi,%ebx
  801046:	89 fe                	mov    %edi,%esi
  801048:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801055:	b8 02 00 00 00       	mov    $0x2,%eax
  80105a:	bf 00 00 00 00       	mov    $0x0,%edi
  80105f:	89 fa                	mov    %edi,%edx
  801061:	89 f9                	mov    %edi,%ecx
  801063:	89 fb                	mov    %edi,%ebx
  801065:	89 fe                	mov    %edi,%esi
  801067:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107a:	b8 03 00 00 00       	mov    $0x3,%eax
  80107f:	bf 00 00 00 00       	mov    $0x0,%edi
  801084:	89 f9                	mov    %edi,%ecx
  801086:	89 fb                	mov    %edi,%ebx
  801088:	89 fe                	mov    %edi,%esi
  80108a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108c:	85 c0                	test   %eax,%eax
  80108e:	7e 17                	jle    8010a7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	50                   	push   %eax
  801094:	6a 03                	push   $0x3
  801096:	68 ff 2d 80 00       	push   $0x802dff
  80109b:	6a 23                	push   $0x23
  80109d:	68 1c 2e 80 00       	push   $0x802e1c
  8010a2:	e8 3d f4 ff ff       	call   8004e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    
	...

008010b0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010b6:	68 2a 2e 80 00       	push   $0x802e2a
  8010bb:	68 92 00 00 00       	push   $0x92
  8010c0:	68 40 2e 80 00       	push   $0x802e40
  8010c5:	e8 1a f4 ff ff       	call   8004e4 <_panic>

008010ca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  8010d3:	68 6b 12 80 00       	push   $0x80126b
  8010d8:	e8 07 14 00 00       	call   8024e4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010dd:	ba 07 00 00 00       	mov    $0x7,%edx
  8010e2:	89 d0                	mov    %edx,%eax
  8010e4:	cd 30                	int    $0x30
  8010e6:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	75 25                	jne    801114 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  8010ef:	e8 5b ff ff ff       	call   80104f <sys_getenvid>
  8010f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801100:	c1 e0 07             	shl    $0x7,%eax
  801103:	29 d0                	sub    %edx,%eax
  801105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80110a:	a3 04 50 80 00       	mov    %eax,0x805004
  80110f:	e9 4d 01 00 00       	jmp    801261 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  801114:	85 c0                	test   %eax,%eax
  801116:	79 12                	jns    80112a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  801118:	50                   	push   %eax
  801119:	68 4b 2e 80 00       	push   $0x802e4b
  80111e:	6a 77                	push   $0x77
  801120:	68 40 2e 80 00       	push   $0x802e40
  801125:	e8 ba f3 ff ff       	call   8004e4 <_panic>
  80112a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  80112f:	89 d8                	mov    %ebx,%eax
  801131:	c1 e8 16             	shr    $0x16,%eax
  801134:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113b:	a8 01                	test   $0x1,%al
  80113d:	0f 84 ab 00 00 00    	je     8011ee <fork+0x124>
  801143:	89 da                	mov    %ebx,%edx
  801145:	c1 ea 0c             	shr    $0xc,%edx
  801148:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80114f:	a8 01                	test   $0x1,%al
  801151:	0f 84 97 00 00 00    	je     8011ee <fork+0x124>
  801157:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80115e:	a8 04                	test   $0x4,%al
  801160:	0f 84 88 00 00 00    	je     8011ee <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  801166:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  80116d:	89 d6                	mov    %edx,%esi
  80116f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  801172:	89 c2                	mov    %eax,%edx
  801174:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  80117a:	a9 02 08 00 00       	test   $0x802,%eax
  80117f:	74 0f                	je     801190 <fork+0xc6>
  801181:	f6 c4 04             	test   $0x4,%ah
  801184:	75 0a                	jne    801190 <fork+0xc6>
		perm &= ~PTE_W;
  801186:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  801190:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801196:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	52                   	push   %edx
  80119d:	56                   	push   %esi
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	6a 00                	push   $0x0
  8011a2:	e8 04 fe ff ff       	call   800fab <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 14                	jns    8011c2 <fork+0xf8>
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	68 94 2e 80 00       	push   $0x802e94
  8011b6:	6a 52                	push   $0x52
  8011b8:	68 40 2e 80 00       	push   $0x802e40
  8011bd:	e8 22 f3 ff ff       	call   8004e4 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c8:	56                   	push   %esi
  8011c9:	6a 00                	push   $0x0
  8011cb:	56                   	push   %esi
  8011cc:	6a 00                	push   $0x0
  8011ce:	e8 d8 fd ff ff       	call   800fab <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  8011d3:	83 c4 20             	add    $0x20,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	79 14                	jns    8011ee <fork+0x124>
  8011da:	83 ec 04             	sub    $0x4,%esp
  8011dd:	68 b8 2e 80 00       	push   $0x802eb8
  8011e2:	6a 55                	push   $0x55
  8011e4:	68 40 2e 80 00       	push   $0x802e40
  8011e9:	e8 f6 f2 ff ff       	call   8004e4 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8011ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011f4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011fa:	0f 85 2f ff ff ff    	jne    80112f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	6a 07                	push   $0x7
  801205:	68 00 f0 bf ee       	push   $0xeebff000
  80120a:	57                   	push   %edi
  80120b:	e8 dd fd ff ff       	call   800fed <sys_page_alloc>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	79 15                	jns    80122c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  801217:	50                   	push   %eax
  801218:	68 69 2e 80 00       	push   $0x802e69
  80121d:	68 83 00 00 00       	push   $0x83
  801222:	68 40 2e 80 00       	push   $0x802e40
  801227:	e8 b8 f2 ff ff       	call   8004e4 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	68 64 25 80 00       	push   $0x802564
  801234:	57                   	push   %edi
  801235:	e8 69 fc ff ff       	call   800ea3 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	6a 02                	push   $0x2
  80123f:	57                   	push   %edi
  801240:	e8 e2 fc ff ff       	call   800f27 <sys_env_set_status>
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	79 15                	jns    801261 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  80124c:	50                   	push   %eax
  80124d:	68 7c 2e 80 00       	push   $0x802e7c
  801252:	68 89 00 00 00       	push   $0x89
  801257:	68 40 2e 80 00       	push   $0x802e40
  80125c:	e8 83 f2 ff ff       	call   8004e4 <_panic>
	return envid;
	//panic("fork not implemented");
}
  801261:	89 f8                	mov    %edi,%eax
  801263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  801275:	8b 1a                	mov    (%edx),%ebx
  801277:	89 d8                	mov    %ebx,%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
  80127c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  801283:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801287:	74 05                	je     80128e <pgfault+0x23>
  801289:	f6 c4 08             	test   $0x8,%ah
  80128c:	75 14                	jne    8012a2 <pgfault+0x37>
  80128e:	83 ec 04             	sub    $0x4,%esp
  801291:	68 dc 2e 80 00       	push   $0x802edc
  801296:	6a 1e                	push   $0x1e
  801298:	68 40 2e 80 00       	push   $0x802e40
  80129d:	e8 42 f2 ff ff       	call   8004e4 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  8012a2:	83 ec 04             	sub    $0x4,%esp
  8012a5:	6a 07                	push   $0x7
  8012a7:	68 00 f0 7f 00       	push   $0x7ff000
  8012ac:	6a 00                	push   $0x0
  8012ae:	e8 3a fd ff ff       	call   800fed <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	79 14                	jns    8012ce <pgfault+0x63>
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	68 08 2f 80 00       	push   $0x802f08
  8012c2:	6a 2a                	push   $0x2a
  8012c4:	68 40 2e 80 00       	push   $0x802e40
  8012c9:	e8 16 f2 ff ff       	call   8004e4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  8012ce:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  8012d4:	83 ec 04             	sub    $0x4,%esp
  8012d7:	68 00 10 00 00       	push   $0x1000
  8012dc:	53                   	push   %ebx
  8012dd:	68 00 f0 7f 00       	push   $0x7ff000
  8012e2:	e8 5d f9 ff ff       	call   800c44 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  8012e7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012ee:	53                   	push   %ebx
  8012ef:	6a 00                	push   $0x0
  8012f1:	68 00 f0 7f 00       	push   $0x7ff000
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 ae fc ff ff       	call   800fab <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  8012fd:	83 c4 20             	add    $0x20,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	79 14                	jns    801318 <pgfault+0xad>
  801304:	83 ec 04             	sub    $0x4,%esp
  801307:	68 2c 2f 80 00       	push   $0x802f2c
  80130c:	6a 2e                	push   $0x2e
  80130e:	68 40 2e 80 00       	push   $0x802e40
  801313:	e8 cc f1 ff ff       	call   8004e4 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	68 00 f0 7f 00       	push   $0x7ff000
  801320:	6a 00                	push   $0x0
  801322:	e8 42 fc ff ff       	call   800f69 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	79 14                	jns    801342 <pgfault+0xd7>
  80132e:	83 ec 04             	sub    $0x4,%esp
  801331:	68 4c 2f 80 00       	push   $0x802f4c
  801336:	6a 32                	push   $0x32
  801338:	68 40 2e 80 00       	push   $0x802e40
  80133d:	e8 a2 f1 ff ff       	call   8004e4 <_panic>
	//panic("pgfault not implemented");
}
  801342:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801345:	c9                   	leave  
  801346:	c3                   	ret    
	...

00801348 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	8b 45 08             	mov    0x8(%ebp),%eax
  80134e:	05 00 00 00 30       	add    $0x30000000,%eax
  801353:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80135b:	ff 75 08             	pushl  0x8(%ebp)
  80135e:	e8 e5 ff ff ff       	call   801348 <fd2num>
  801363:	83 c4 04             	add    $0x4,%esp
  801366:	c1 e0 0c             	shl    $0xc,%eax
  801369:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	53                   	push   %ebx
  801374:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801377:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  80137c:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80137e:	89 d0                	mov    %edx,%eax
  801380:	c1 e8 16             	shr    $0x16,%eax
  801383:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138a:	a8 01                	test   $0x1,%al
  80138c:	74 10                	je     80139e <fd_alloc+0x2e>
  80138e:	89 d0                	mov    %edx,%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
  801393:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139a:	a8 01                	test   $0x1,%al
  80139c:	75 09                	jne    8013a7 <fd_alloc+0x37>
			*fd_store = fd;
  80139e:	89 0b                	mov    %ecx,(%ebx)
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a5:	eb 19                	jmp    8013c0 <fd_alloc+0x50>
			return 0;
  8013a7:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ad:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8013b3:	75 c7                	jne    80137c <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8013c0:	5b                   	pop    %ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013c9:	83 f8 1f             	cmp    $0x1f,%eax
  8013cc:	77 35                	ja     801403 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013ce:	c1 e0 0c             	shl    $0xc,%eax
  8013d1:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013d7:	89 d0                	mov    %edx,%eax
  8013d9:	c1 e8 16             	shr    $0x16,%eax
  8013dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e3:	a8 01                	test   $0x1,%al
  8013e5:	74 1c                	je     801403 <fd_lookup+0x40>
  8013e7:	89 d0                	mov    %edx,%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
  8013ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f3:	a8 01                	test   $0x1,%al
  8013f5:	74 0c                	je     801403 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fa:	89 10                	mov    %edx,(%eax)
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	eb 05                	jmp    801408 <fd_lookup+0x45>
	return 0;
  801403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801410:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	ff 75 08             	pushl  0x8(%ebp)
  801417:	e8 a7 ff ff ff       	call   8013c3 <fd_lookup>
  80141c:	83 c4 08             	add    $0x8,%esp
  80141f:	85 c0                	test   %eax,%eax
  801421:	78 0e                	js     801431 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801423:	8b 55 0c             	mov    0xc(%ebp),%edx
  801426:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801429:	89 50 04             	mov    %edx,0x4(%eax)
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	53                   	push   %ebx
  801437:	83 ec 04             	sub    $0x4,%esp
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801440:	ba 00 00 00 00       	mov    $0x0,%edx
  801445:	eb 0e                	jmp    801455 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801447:	3b 08                	cmp    (%eax),%ecx
  801449:	75 09                	jne    801454 <dev_lookup+0x21>
			*dev = devtab[i];
  80144b:	89 03                	mov    %eax,(%ebx)
  80144d:	b8 00 00 00 00       	mov    $0x0,%eax
  801452:	eb 31                	jmp    801485 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801454:	42                   	inc    %edx
  801455:	8b 04 95 ec 2f 80 00 	mov    0x802fec(,%edx,4),%eax
  80145c:	85 c0                	test   %eax,%eax
  80145e:	75 e7                	jne    801447 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801460:	a1 04 50 80 00       	mov    0x805004,%eax
  801465:	8b 40 48             	mov    0x48(%eax),%eax
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	51                   	push   %ecx
  80146c:	50                   	push   %eax
  80146d:	68 70 2f 80 00       	push   $0x802f70
  801472:	e8 0e f1 ff ff       	call   800585 <cprintf>
	*dev = 0;
  801477:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801482:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 14             	sub    $0x14,%esp
  801491:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 75 08             	pushl  0x8(%ebp)
  80149b:	e8 23 ff ff ff       	call   8013c3 <fd_lookup>
  8014a0:	83 c4 08             	add    $0x8,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 55                	js     8014fc <fstat+0x72>
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b1:	ff 30                	pushl  (%eax)
  8014b3:	e8 7b ff ff ff       	call   801433 <dev_lookup>
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 3d                	js     8014fc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8014bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014c2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014c6:	75 07                	jne    8014cf <fstat+0x45>
  8014c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014cd:	eb 2d                	jmp    8014fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014d9:	00 00 00 
	stat->st_isdir = 0;
  8014dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014e3:	00 00 00 
	stat->st_dev = dev;
  8014e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014e9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f6:	ff 50 14             	call   *0x14(%eax)
  8014f9:	83 c4 10             	add    $0x10,%esp
}
  8014fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	53                   	push   %ebx
  801505:	83 ec 14             	sub    $0x14,%esp
  801508:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150e:	50                   	push   %eax
  80150f:	53                   	push   %ebx
  801510:	e8 ae fe ff ff       	call   8013c3 <fd_lookup>
  801515:	83 c4 08             	add    $0x8,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 5f                	js     80157b <ftruncate+0x7a>
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801526:	ff 30                	pushl  (%eax)
  801528:	e8 06 ff ff ff       	call   801433 <dev_lookup>
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 47                	js     80157b <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801537:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153b:	75 21                	jne    80155e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153d:	a1 04 50 80 00       	mov    0x805004,%eax
  801542:	8b 40 48             	mov    0x48(%eax),%eax
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	53                   	push   %ebx
  801549:	50                   	push   %eax
  80154a:	68 90 2f 80 00       	push   $0x802f90
  80154f:	e8 31 f0 ff ff       	call   800585 <cprintf>
  801554:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	eb 1d                	jmp    80157b <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80155e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801561:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801565:	75 07                	jne    80156e <ftruncate+0x6d>
  801567:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80156c:	eb 0d                	jmp    80157b <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	ff 75 0c             	pushl  0xc(%ebp)
  801574:	50                   	push   %eax
  801575:	ff 52 18             	call   *0x18(%edx)
  801578:	83 c4 10             	add    $0x10,%esp
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	53                   	push   %ebx
  801584:	83 ec 14             	sub    $0x14,%esp
  801587:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	53                   	push   %ebx
  80158f:	e8 2f fe ff ff       	call   8013c3 <fd_lookup>
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 62                	js     8015fd <write+0x7d>
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	ff 30                	pushl  (%eax)
  8015a7:	e8 87 fe ff ff       	call   801433 <dev_lookup>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 4a                	js     8015fd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ba:	75 21                	jne    8015dd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015bc:	a1 04 50 80 00       	mov    0x805004,%eax
  8015c1:	8b 40 48             	mov    0x48(%eax),%eax
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	50                   	push   %eax
  8015c9:	68 b1 2f 80 00       	push   $0x802fb1
  8015ce:	e8 b2 ef ff ff       	call   800585 <cprintf>
  8015d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb 20                	jmp    8015fd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015dd:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8015e0:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8015e4:	75 07                	jne    8015ed <write+0x6d>
  8015e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015eb:	eb 10                	jmp    8015fd <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	ff 75 10             	pushl  0x10(%ebp)
  8015f3:	ff 75 0c             	pushl  0xc(%ebp)
  8015f6:	50                   	push   %eax
  8015f7:	ff 52 0c             	call   *0xc(%edx)
  8015fa:	83 c4 10             	add    $0x10,%esp
}
  8015fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	53                   	push   %ebx
  801606:	83 ec 14             	sub    $0x14,%esp
  801609:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160f:	50                   	push   %eax
  801610:	53                   	push   %ebx
  801611:	e8 ad fd ff ff       	call   8013c3 <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 67                	js     801684 <read+0x82>
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801627:	ff 30                	pushl  (%eax)
  801629:	e8 05 fe ff ff       	call   801433 <dev_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 4f                	js     801684 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801635:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801638:	8b 42 08             	mov    0x8(%edx),%eax
  80163b:	83 e0 03             	and    $0x3,%eax
  80163e:	83 f8 01             	cmp    $0x1,%eax
  801641:	75 21                	jne    801664 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801643:	a1 04 50 80 00       	mov    0x805004,%eax
  801648:	8b 40 48             	mov    0x48(%eax),%eax
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	53                   	push   %ebx
  80164f:	50                   	push   %eax
  801650:	68 ce 2f 80 00       	push   $0x802fce
  801655:	e8 2b ef ff ff       	call   800585 <cprintf>
  80165a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 20                	jmp    801684 <read+0x82>
	}
	if (!dev->dev_read)
  801664:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801667:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80166b:	75 07                	jne    801674 <read+0x72>
  80166d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801672:	eb 10                	jmp    801684 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801674:	83 ec 04             	sub    $0x4,%esp
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	52                   	push   %edx
  80167e:	ff 50 08             	call   *0x8(%eax)
  801681:	83 c4 10             	add    $0x10,%esp
}
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	57                   	push   %edi
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
  801698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169d:	eb 21                	jmp    8016c0 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	89 f0                	mov    %esi,%eax
  8016a4:	29 d0                	sub    %edx,%eax
  8016a6:	50                   	push   %eax
  8016a7:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8016aa:	50                   	push   %eax
  8016ab:	ff 75 08             	pushl  0x8(%ebp)
  8016ae:	e8 4f ff ff ff       	call   801602 <read>
		if (m < 0)
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 0e                	js     8016c8 <readn+0x3f>
			return m;
		if (m == 0)
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	74 08                	je     8016c6 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016be:	01 c3                	add    %eax,%ebx
  8016c0:	89 da                	mov    %ebx,%edx
  8016c2:	39 f3                	cmp    %esi,%ebx
  8016c4:	72 d9                	jb     80169f <readn+0x16>
  8016c6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5f                   	pop    %edi
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	56                   	push   %esi
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 20             	sub    $0x20,%esp
  8016d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016db:	8a 45 0c             	mov    0xc(%ebp),%al
  8016de:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	56                   	push   %esi
  8016e6:	e8 5d fc ff ff       	call   801348 <fd2num>
  8016eb:	89 04 24             	mov    %eax,(%esp)
  8016ee:	e8 d0 fc ff ff       	call   8013c3 <fd_lookup>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 08             	add    $0x8,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 05                	js     801701 <fd_close+0x31>
  8016fc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016ff:	74 0d                	je     80170e <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801701:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801705:	75 48                	jne    80174f <fd_close+0x7f>
  801707:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170c:	eb 41                	jmp    80174f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	ff 36                	pushl  (%esi)
  801717:	e8 17 fd ff ff       	call   801433 <dev_lookup>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	78 1c                	js     801741 <fd_close+0x71>
		if (dev->dev_close)
  801725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801728:	8b 40 10             	mov    0x10(%eax),%eax
  80172b:	85 c0                	test   %eax,%eax
  80172d:	75 07                	jne    801736 <fd_close+0x66>
  80172f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801734:	eb 0b                	jmp    801741 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801736:	83 ec 0c             	sub    $0xc,%esp
  801739:	56                   	push   %esi
  80173a:	ff d0                	call   *%eax
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	56                   	push   %esi
  801745:	6a 00                	push   $0x0
  801747:	e8 1d f8 ff ff       	call   800f69 <sys_page_unmap>
  80174c:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80174f:	89 d8                	mov    %ebx,%eax
  801751:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	e8 59 fc ff ff       	call   8013c3 <fd_lookup>
  80176a:	83 c4 08             	add    $0x8,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 10                	js     801781 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	6a 01                	push   $0x1
  801776:	ff 75 fc             	pushl  -0x4(%ebp)
  801779:	e8 52 ff ff ff       	call   8016d0 <fd_close>
  80177e:	83 c4 10             	add    $0x10,%esp
}
  801781:	c9                   	leave  
  801782:	c3                   	ret    

00801783 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	6a 00                	push   $0x0
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 4a 03 00 00       	call   801adf <open>
  801795:	89 c6                	mov    %eax,%esi
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 1b                	js     8017b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	50                   	push   %eax
  8017a5:	e8 e0 fc ff ff       	call   80148a <fstat>
  8017aa:	89 c3                	mov    %eax,%ebx
	close(fd);
  8017ac:	89 34 24             	mov    %esi,(%esp)
  8017af:	e8 a4 ff ff ff       	call   801758 <close>
  8017b4:	89 de                	mov    %ebx,%esi
  8017b6:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8017b9:	89 f0                	mov    %esi,%eax
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	57                   	push   %edi
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	83 ec 1c             	sub    $0x1c,%esp
  8017cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d1:	50                   	push   %eax
  8017d2:	ff 75 08             	pushl  0x8(%ebp)
  8017d5:	e8 e9 fb ff ff       	call   8013c3 <fd_lookup>
  8017da:	89 c3                	mov    %eax,%ebx
  8017dc:	83 c4 08             	add    $0x8,%esp
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	0f 88 bd 00 00 00    	js     8018a4 <dup+0xe2>
		return r;
	close(newfdnum);
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	57                   	push   %edi
  8017eb:	e8 68 ff ff ff       	call   801758 <close>

	newfd = INDEX2FD(newfdnum);
  8017f0:	89 f8                	mov    %edi,%eax
  8017f2:	c1 e0 0c             	shl    $0xc,%eax
  8017f5:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8017fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fe:	e8 55 fb ff ff       	call   801358 <fd2data>
  801803:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801805:	89 34 24             	mov    %esi,(%esp)
  801808:	e8 4b fb ff ff       	call   801358 <fd2data>
  80180d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801810:	89 d8                	mov    %ebx,%eax
  801812:	c1 e8 16             	shr    $0x16,%eax
  801815:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80181c:	83 c4 14             	add    $0x14,%esp
  80181f:	a8 01                	test   $0x1,%al
  801821:	74 36                	je     801859 <dup+0x97>
  801823:	89 da                	mov    %ebx,%edx
  801825:	c1 ea 0c             	shr    $0xc,%edx
  801828:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80182f:	a8 01                	test   $0x1,%al
  801831:	74 26                	je     801859 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801833:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	25 07 0e 00 00       	and    $0xe07,%eax
  801842:	50                   	push   %eax
  801843:	ff 75 e0             	pushl  -0x20(%ebp)
  801846:	6a 00                	push   $0x0
  801848:	53                   	push   %ebx
  801849:	6a 00                	push   $0x0
  80184b:	e8 5b f7 ff ff       	call   800fab <sys_page_map>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 20             	add    $0x20,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	78 30                	js     801889 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801859:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80185c:	89 d0                	mov    %edx,%eax
  80185e:	c1 e8 0c             	shr    $0xc,%eax
  801861:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801868:	83 ec 0c             	sub    $0xc,%esp
  80186b:	25 07 0e 00 00       	and    $0xe07,%eax
  801870:	50                   	push   %eax
  801871:	56                   	push   %esi
  801872:	6a 00                	push   $0x0
  801874:	52                   	push   %edx
  801875:	6a 00                	push   $0x0
  801877:	e8 2f f7 ff ff       	call   800fab <sys_page_map>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 20             	add    $0x20,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	78 04                	js     801889 <dup+0xc7>
		goto err;
  801885:	89 fb                	mov    %edi,%ebx
  801887:	eb 1b                	jmp    8018a4 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	56                   	push   %esi
  80188d:	6a 00                	push   $0x0
  80188f:	e8 d5 f6 ff ff       	call   800f69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801894:	83 c4 08             	add    $0x8,%esp
  801897:	ff 75 e0             	pushl  -0x20(%ebp)
  80189a:	6a 00                	push   $0x0
  80189c:	e8 c8 f6 ff ff       	call   800f69 <sys_page_unmap>
  8018a1:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8018a4:	89 d8                	mov    %ebx,%eax
  8018a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	53                   	push   %ebx
  8018be:	e8 95 fe ff ff       	call   801758 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018c3:	43                   	inc    %ebx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	83 fb 20             	cmp    $0x20,%ebx
  8018ca:	75 ee                	jne    8018ba <close_all+0xc>
		close(i);
}
  8018cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    
  8018d1:	00 00                	add    %al,(%eax)
	...

008018d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	56                   	push   %esi
  8018d8:	53                   	push   %ebx
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018dd:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8018e4:	75 12                	jne    8018f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	6a 01                	push   $0x1
  8018eb:	e8 9c 0c 00 00       	call   80258c <ipc_find_env>
  8018f0:	a3 00 50 80 00       	mov    %eax,0x805000
  8018f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f8:	6a 07                	push   $0x7
  8018fa:	68 00 60 80 00       	push   $0x806000
  8018ff:	53                   	push   %ebx
  801900:	ff 35 00 50 80 00    	pushl  0x805000
  801906:	e8 c6 0c 00 00       	call   8025d1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80190b:	83 c4 0c             	add    $0xc,%esp
  80190e:	6a 00                	push   $0x0
  801910:	56                   	push   %esi
  801911:	6a 00                	push   $0x0
  801913:	e8 0e 0d 00 00       	call   802626 <ipc_recv>
}
  801918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	b8 08 00 00 00       	mov    $0x8,%eax
  80192f:	e8 a0 ff ff ff       	call   8018d4 <fsipc>
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 40 0c             	mov    0xc(%eax),%eax
  801942:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 02 00 00 00       	mov    $0x2,%eax
  801959:	e8 76 ff ff ff       	call   8018d4 <fsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	8b 40 0c             	mov    0xc(%eax),%eax
  80196c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801971:	ba 00 00 00 00       	mov    $0x0,%edx
  801976:	b8 06 00 00 00       	mov    $0x6,%eax
  80197b:	e8 54 ff ff ff       	call   8018d4 <fsipc>
}
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80198c:	8b 45 08             	mov    0x8(%ebp),%eax
  80198f:	8b 40 0c             	mov    0xc(%eax),%eax
  801992:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801997:	ba 00 00 00 00       	mov    $0x0,%edx
  80199c:	b8 05 00 00 00       	mov    $0x5,%eax
  8019a1:	e8 2e ff ff ff       	call   8018d4 <fsipc>
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 2c                	js     8019d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	68 00 60 80 00       	push   $0x806000
  8019b2:	53                   	push   %ebx
  8019b3:	e8 1f f1 ff ff       	call   800ad7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019b8:	a1 80 60 80 00       	mov    0x806080,%eax
  8019bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019c3:	a1 84 60 80 00       	mov    0x806084,%eax
  8019c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8019ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d3:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	53                   	push   %ebx
  8019df:	83 ec 08             	sub    $0x8,%esp
  8019e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019eb:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = n;
  8019f0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019f6:	53                   	push   %ebx
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	68 08 60 80 00       	push   $0x806008
  8019ff:	e8 40 f2 ff ff       	call   800c44 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801a04:	ba 00 00 00 00       	mov    $0x0,%edx
  801a09:	b8 04 00 00 00       	mov    $0x4,%eax
  801a0e:	e8 c1 fe ff ff       	call   8018d4 <fsipc>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 3d                	js     801a57 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801a1a:	39 c3                	cmp    %eax,%ebx
  801a1c:	73 19                	jae    801a37 <devfile_write+0x5c>
  801a1e:	68 fc 2f 80 00       	push   $0x802ffc
  801a23:	68 03 30 80 00       	push   $0x803003
  801a28:	68 97 00 00 00       	push   $0x97
  801a2d:	68 18 30 80 00       	push   $0x803018
  801a32:	e8 ad ea ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801a37:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a3c:	7e 19                	jle    801a57 <devfile_write+0x7c>
  801a3e:	68 23 30 80 00       	push   $0x803023
  801a43:	68 03 30 80 00       	push   $0x803003
  801a48:	68 98 00 00 00       	push   $0x98
  801a4d:	68 18 30 80 00       	push   $0x803018
  801a52:	e8 8d ea ff ff       	call   8004e4 <_panic>
	
	return r;
}
  801a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a6f:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a75:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a7f:	e8 50 fe ff ff       	call   8018d4 <fsipc>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 4c                	js     801ad6 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801a8a:	39 de                	cmp    %ebx,%esi
  801a8c:	73 16                	jae    801aa4 <devfile_read+0x48>
  801a8e:	68 fc 2f 80 00       	push   $0x802ffc
  801a93:	68 03 30 80 00       	push   $0x803003
  801a98:	6a 7c                	push   $0x7c
  801a9a:	68 18 30 80 00       	push   $0x803018
  801a9f:	e8 40 ea ff ff       	call   8004e4 <_panic>
	assert(r <= PGSIZE);
  801aa4:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801aaa:	7e 16                	jle    801ac2 <devfile_read+0x66>
  801aac:	68 23 30 80 00       	push   $0x803023
  801ab1:	68 03 30 80 00       	push   $0x803003
  801ab6:	6a 7d                	push   $0x7d
  801ab8:	68 18 30 80 00       	push   $0x803018
  801abd:	e8 22 ea ff ff       	call   8004e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	50                   	push   %eax
  801ac6:	68 00 60 80 00       	push   $0x806000
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	e8 71 f1 ff ff       	call   800c44 <memmove>
  801ad3:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 1c             	sub    $0x1c,%esp
  801ae7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aea:	56                   	push   %esi
  801aeb:	e8 b4 ef ff ff       	call   800aa4 <strlen>
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801af8:	7e 07                	jle    801b01 <open+0x22>
  801afa:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801aff:	eb 63                	jmp    801b64 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b07:	50                   	push   %eax
  801b08:	e8 63 f8 ff ff       	call   801370 <fd_alloc>
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 4e                	js     801b64 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	56                   	push   %esi
  801b1a:	68 00 60 80 00       	push   $0x806000
  801b1f:	e8 b3 ef ff ff       	call   800ad7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b34:	e8 9b fd ff ff       	call   8018d4 <fsipc>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	79 12                	jns    801b54 <open+0x75>
		fd_close(fd, 0);
  801b42:	83 ec 08             	sub    $0x8,%esp
  801b45:	6a 00                	push   $0x0
  801b47:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4a:	e8 81 fb ff ff       	call   8016d0 <fd_close>
		return r;
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	eb 10                	jmp    801b64 <open+0x85>
	}

	return fd2num(fd);
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5a:	e8 e9 f7 ff ff       	call   801348 <fd2num>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	83 c4 10             	add    $0x10,%esp
}
  801b64:	89 d8                	mov    %ebx,%eax
  801b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	c9                   	leave  
  801b6c:	c3                   	ret    
  801b6d:	00 00                	add    %al,(%eax)
	...

00801b70 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801b7c:	6a 00                	push   $0x0
  801b7e:	ff 75 08             	pushl  0x8(%ebp)
  801b81:	e8 59 ff ff ff       	call   801adf <open>
  801b86:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	79 0b                	jns    801b9e <spawn+0x2e>
  801b93:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801b99:	e9 13 05 00 00       	jmp    8020b1 <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	68 00 02 00 00       	push   $0x200
  801ba6:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  801bac:	50                   	push   %eax
  801bad:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801bb3:	e8 d1 fa ff ff       	call   801689 <readn>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	3d 00 02 00 00       	cmp    $0x200,%eax
  801bc0:	75 0c                	jne    801bce <spawn+0x5e>
  801bc2:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  801bc9:	45 4c 46 
  801bcc:	74 38                	je     801c06 <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  801bce:	83 ec 0c             	sub    $0xc,%esp
  801bd1:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801bd7:	e8 7c fb ff ff       	call   801758 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801bdc:	83 c4 0c             	add    $0xc,%esp
  801bdf:	68 7f 45 4c 46       	push   $0x464c457f
  801be4:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  801bea:	68 2f 30 80 00       	push   $0x80302f
  801bef:	e8 91 e9 ff ff       	call   800585 <cprintf>
  801bf4:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  801bfb:	ff ff ff 
		return -E_NOT_EXEC;
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	e9 ab 04 00 00       	jmp    8020b1 <spawn+0x541>
  801c06:	ba 07 00 00 00       	mov    $0x7,%edx
  801c0b:	89 d0                	mov    %edx,%eax
  801c0d:	cd 30                	int    $0x30
  801c0f:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 88 94 04 00 00    	js     8020b1 <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801c1d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c22:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c29:	c1 e0 07             	shl    $0x7,%eax
  801c2c:	29 d0                	sub    %edx,%eax
  801c2e:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  801c34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c39:	83 ec 04             	sub    $0x4,%esp
  801c3c:	6a 44                	push   $0x44
  801c3e:	50                   	push   %eax
  801c3f:	52                   	push   %edx
  801c40:	e8 6d f0 ff ff       	call   800cb2 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  801c45:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  801c4b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  801c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c56:	be 00 00 00 00       	mov    $0x0,%esi
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	eb 11                	jmp    801c71 <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801c60:	83 ec 0c             	sub    $0xc,%esp
  801c63:	50                   	push   %eax
  801c64:	e8 3b ee ff ff       	call   800aa4 <strlen>
  801c69:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801c6d:	46                   	inc    %esi
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c74:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  801c77:	85 c0                	test   %eax,%eax
  801c79:	75 e5                	jne    801c60 <spawn+0xf0>
  801c7b:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801c81:	89 f1                	mov    %esi,%ecx
  801c83:	c1 e1 02             	shl    $0x2,%ecx
  801c86:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801c8c:	b8 00 10 40 00       	mov    $0x401000,%eax
  801c91:	89 c7                	mov    %eax,%edi
  801c93:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c95:	89 f8                	mov    %edi,%eax
  801c97:	83 e0 fc             	and    $0xfffffffc,%eax
  801c9a:	29 c8                	sub    %ecx,%eax
  801c9c:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  801ca2:	83 e8 04             	sub    $0x4,%eax
  801ca5:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801cab:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801cb1:	83 e8 0c             	sub    $0xc,%eax
  801cb4:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801cb9:	0f 86 c1 03 00 00    	jbe    802080 <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801cbf:	83 ec 04             	sub    $0x4,%esp
  801cc2:	6a 07                	push   $0x7
  801cc4:	68 00 00 40 00       	push   $0x400000
  801cc9:	6a 00                	push   $0x0
  801ccb:	e8 1d f3 ff ff       	call   800fed <sys_page_alloc>
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	0f 88 aa 03 00 00    	js     802085 <spawn+0x515>
  801cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce0:	eb 35                	jmp    801d17 <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801ce2:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ce8:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  801cee:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf8:	ff 34 99             	pushl  (%ecx,%ebx,4)
  801cfb:	57                   	push   %edi
  801cfc:	e8 d6 ed ff ff       	call   800ad7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801d01:	83 c4 04             	add    $0x4,%esp
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	ff 34 98             	pushl  (%eax,%ebx,4)
  801d0a:	e8 95 ed ff ff       	call   800aa4 <strlen>
  801d0f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d13:	43                   	inc    %ebx
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	39 f3                	cmp    %esi,%ebx
  801d19:	7c c7                	jl     801ce2 <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801d1b:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801d21:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801d27:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801d2e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801d34:	74 19                	je     801d4f <spawn+0x1df>
  801d36:	68 8c 30 80 00       	push   $0x80308c
  801d3b:	68 03 30 80 00       	push   $0x803003
  801d40:	68 f2 00 00 00       	push   $0xf2
  801d45:	68 49 30 80 00       	push   $0x803049
  801d4a:	e8 95 e7 ff ff       	call   8004e4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801d4f:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801d55:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801d5a:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801d60:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801d63:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  801d69:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  801d6c:	89 d0                	mov    %edx,%eax
  801d6e:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801d73:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	6a 07                	push   $0x7
  801d7e:	68 00 d0 bf ee       	push   $0xeebfd000
  801d83:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801d89:	68 00 00 40 00       	push   $0x400000
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 16 f2 ff ff       	call   800fab <sys_page_map>
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	83 c4 20             	add    $0x20,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 1c                	js     801dba <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d9e:	83 ec 08             	sub    $0x8,%esp
  801da1:	68 00 00 40 00       	push   $0x400000
  801da6:	6a 00                	push   $0x0
  801da8:	e8 bc f1 ff ff       	call   800f69 <sys_page_unmap>
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	0f 89 d3 02 00 00    	jns    80208d <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	68 00 00 40 00       	push   $0x400000
  801dc2:	6a 00                	push   $0x0
  801dc4:	e8 a0 f1 ff ff       	call   800f69 <sys_page_unmap>
  801dc9:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	e9 da 02 00 00       	jmp    8020b1 <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801dd7:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801ddd:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  801de1:	0f 85 79 01 00 00    	jne    801f60 <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801de7:	8b 42 f8             	mov    -0x8(%edx),%eax
  801dea:	83 e0 02             	and    $0x2,%eax
  801ded:	83 f8 01             	cmp    $0x1,%eax
  801df0:	19 c0                	sbb    %eax,%eax
  801df2:	83 e0 fe             	and    $0xfffffffe,%eax
  801df5:	83 c0 07             	add    $0x7,%eax
  801df8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801dfe:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  801e01:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801e07:	8b 42 f0             	mov    -0x10(%edx),%eax
  801e0a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801e10:	8b 4a f4             	mov    -0xc(%edx),%ecx
  801e13:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801e19:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801e1c:	89 c2                	mov    %eax,%edx
  801e1e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e24:	74 16                	je     801e3c <spawn+0x2cc>
		va -= i;
  801e26:	29 d0                	sub    %edx,%eax
		memsz += i;
  801e28:	01 d1                	add    %edx,%ecx
  801e2a:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  801e30:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  801e36:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  801e3c:	89 c7                	mov    %eax,%edi
  801e3e:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801e45:	00 00 00 
  801e48:	e9 01 01 00 00       	jmp    801f4e <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  801e4d:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801e53:	77 27                	ja     801e7c <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e55:	83 ec 04             	sub    $0x4,%esp
  801e58:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e5e:	57                   	push   %edi
  801e5f:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801e65:	e8 83 f1 ff ff       	call   800fed <sys_page_alloc>
  801e6a:	89 c3                	mov    %eax,%ebx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	85 c0                	test   %eax,%eax
  801e71:	0f 89 c7 00 00 00    	jns    801f3e <spawn+0x3ce>
  801e77:	e9 dd 01 00 00       	jmp    802059 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e7c:	83 ec 04             	sub    $0x4,%esp
  801e7f:	6a 07                	push   $0x7
  801e81:	68 00 00 40 00       	push   $0x400000
  801e86:	6a 00                	push   $0x0
  801e88:	e8 60 f1 ff ff       	call   800fed <sys_page_alloc>
  801e8d:	89 c3                	mov    %eax,%ebx
  801e8f:	83 c4 10             	add    $0x10,%esp
  801e92:	85 c0                	test   %eax,%eax
  801e94:	0f 88 bf 01 00 00    	js     802059 <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e9a:	83 ec 08             	sub    $0x8,%esp
  801e9d:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  801ea3:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801ea6:	50                   	push   %eax
  801ea7:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801ead:	e8 58 f5 ff ff       	call   80140a <seek>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 9a 01 00 00    	js     802059 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ebf:	83 ec 04             	sub    $0x4,%esp
  801ec2:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ec8:	29 f0                	sub    %esi,%eax
  801eca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ecf:	76 05                	jbe    801ed6 <spawn+0x366>
  801ed1:	b8 00 10 00 00       	mov    $0x1000,%eax
  801ed6:	50                   	push   %eax
  801ed7:	68 00 00 40 00       	push   $0x400000
  801edc:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801ee2:	e8 a2 f7 ff ff       	call   801689 <readn>
  801ee7:	89 c3                	mov    %eax,%ebx
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	85 c0                	test   %eax,%eax
  801eee:	0f 88 65 01 00 00    	js     802059 <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ef4:	83 ec 0c             	sub    $0xc,%esp
  801ef7:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801efd:	57                   	push   %edi
  801efe:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801f04:	68 00 00 40 00       	push   $0x400000
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 9b f0 ff ff       	call   800fab <sys_page_map>
  801f10:	83 c4 20             	add    $0x20,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 15                	jns    801f2c <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  801f17:	50                   	push   %eax
  801f18:	68 55 30 80 00       	push   $0x803055
  801f1d:	68 25 01 00 00       	push   $0x125
  801f22:	68 49 30 80 00       	push   $0x803049
  801f27:	e8 b8 e5 ff ff       	call   8004e4 <_panic>
			sys_page_unmap(0, UTEMP);
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	68 00 00 40 00       	push   $0x400000
  801f34:	6a 00                	push   $0x0
  801f36:	e8 2e f0 ff ff       	call   800f69 <sys_page_unmap>
  801f3b:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f3e:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  801f45:	10 00 00 
  801f48:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801f4e:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801f54:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  801f5a:	0f 87 ed fe ff ff    	ja     801e4d <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f60:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  801f66:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  801f6d:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801f74:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  801f7a:	0f 8c 57 fe ff ff    	jl     801dd7 <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f80:	83 ec 0c             	sub    $0xc,%esp
  801f83:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801f89:	e8 ca f7 ff ff       	call   801758 <close>
  801f8e:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801f93:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  801f96:	89 d8                	mov    %ebx,%eax
  801f98:	c1 e8 16             	shr    $0x16,%eax
  801f9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801fa2:	a8 01                	test   $0x1,%al
  801fa4:	74 3e                	je     801fe4 <spawn+0x474>
  801fa6:	89 da                	mov    %ebx,%edx
  801fa8:	c1 ea 0c             	shr    $0xc,%edx
  801fab:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fb2:	a8 01                	test   $0x1,%al
  801fb4:	74 2e                	je     801fe4 <spawn+0x474>
  801fb6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fbd:	f6 c4 04             	test   $0x4,%ah
  801fc0:	74 22                	je     801fe4 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801fc2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801fc9:	83 ec 0c             	sub    $0xc,%esp
  801fcc:	25 07 0e 00 00       	and    $0xe07,%eax
  801fd1:	50                   	push   %eax
  801fd2:	53                   	push   %ebx
  801fd3:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801fd9:	53                   	push   %ebx
  801fda:	6a 00                	push   $0x0
  801fdc:	e8 ca ef ff ff       	call   800fab <sys_page_map>
  801fe1:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  801fe4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fea:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ff0:	75 a4                	jne    801f96 <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801ff2:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  801ff9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ffc:	83 ec 08             	sub    $0x8,%esp
  801fff:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  802005:	50                   	push   %eax
  802006:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  80200c:	e8 d4 ee ff ff       	call   800ee5 <sys_env_set_trapframe>
  802011:	83 c4 10             	add    $0x10,%esp
  802014:	85 c0                	test   %eax,%eax
  802016:	79 15                	jns    80202d <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  802018:	50                   	push   %eax
  802019:	68 72 30 80 00       	push   $0x803072
  80201e:	68 86 00 00 00       	push   $0x86
  802023:	68 49 30 80 00       	push   $0x803049
  802028:	e8 b7 e4 ff ff       	call   8004e4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80202d:	83 ec 08             	sub    $0x8,%esp
  802030:	6a 02                	push   $0x2
  802032:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  802038:	e8 ea ee ff ff       	call   800f27 <sys_env_set_status>
  80203d:	83 c4 10             	add    $0x10,%esp
  802040:	85 c0                	test   %eax,%eax
  802042:	79 6d                	jns    8020b1 <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  802044:	50                   	push   %eax
  802045:	68 7c 2e 80 00       	push   $0x802e7c
  80204a:	68 89 00 00 00       	push   $0x89
  80204f:	68 49 30 80 00       	push   $0x803049
  802054:	e8 8b e4 ff ff       	call   8004e4 <_panic>

	return child;

error:
	sys_env_destroy(child);
  802059:	83 ec 0c             	sub    $0xc,%esp
  80205c:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  802062:	e8 07 f0 ff ff       	call   80106e <sys_env_destroy>
	close(fd);
  802067:	83 c4 04             	add    $0x4,%esp
  80206a:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  802070:	e8 e3 f6 ff ff       	call   801758 <close>
  802075:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	eb 31                	jmp    8020b1 <spawn+0x541>
  802080:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  802085:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  80208b:	eb 24                	jmp    8020b1 <spawn+0x541>
  80208d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802090:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  802096:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  80209c:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  8020a2:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  8020a9:	00 00 00 
  8020ac:	e9 bc fe ff ff       	jmp    801f6d <spawn+0x3fd>
	return r;
}
  8020b1:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  8020b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ba:	5b                   	pop    %ebx
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	57                   	push   %edi
  8020c3:	56                   	push   %esi
  8020c4:	53                   	push   %ebx
  8020c5:	83 ec 1c             	sub    $0x1c,%esp
  8020c8:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8020ca:	8d 45 10             	lea    0x10(%ebp),%eax
  8020cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8020d0:	be 00 00 00 00       	mov    $0x0,%esi
  8020d5:	eb 01                	jmp    8020d8 <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  8020d7:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020db:	8d 42 04             	lea    0x4(%edx),%eax
  8020de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8020e1:	83 3a 00             	cmpl   $0x0,(%edx)
  8020e4:	75 f1                	jne    8020d7 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020e6:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  8020ed:	83 e0 f0             	and    $0xfffffff0,%eax
  8020f0:	29 c4                	sub    %eax,%esp
  8020f2:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  8020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fe:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  802100:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  802107:	00 

	va_start(vl, arg0);
  802108:	8d 45 10             	lea    0x10(%ebp),%eax
  80210b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80210e:	b9 00 00 00 00       	mov    $0x0,%ecx
  802113:	eb 0f                	jmp    802124 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  802115:	41                   	inc    %ecx
  802116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802119:	8d 50 04             	lea    0x4(%eax),%edx
  80211c:	89 55 f0             	mov    %edx,-0x10(%ebp)
  80211f:	8b 00                	mov    (%eax),%eax
  802121:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802124:	39 f1                	cmp    %esi,%ecx
  802126:	75 ed                	jne    802115 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802128:	83 ec 08             	sub    $0x8,%esp
  80212b:	53                   	push   %ebx
  80212c:	ff 75 08             	pushl  0x8(%ebp)
  80212f:	e8 3c fa ff ff       	call   801b70 <spawn>
  802134:	89 fc                	mov    %edi,%esp
}
  802136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802139:	5b                   	pop    %ebx
  80213a:	5e                   	pop    %esi
  80213b:	5f                   	pop    %edi
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    
	...

00802140 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	56                   	push   %esi
  802144:	53                   	push   %ebx
  802145:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802148:	83 ec 0c             	sub    $0xc,%esp
  80214b:	ff 75 08             	pushl  0x8(%ebp)
  80214e:	e8 05 f2 ff ff       	call   801358 <fd2data>
  802153:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802155:	83 c4 08             	add    $0x8,%esp
  802158:	68 b2 30 80 00       	push   $0x8030b2
  80215d:	53                   	push   %ebx
  80215e:	e8 74 e9 ff ff       	call   800ad7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802163:	8b 46 04             	mov    0x4(%esi),%eax
  802166:	2b 06                	sub    (%esi),%eax
  802168:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80216e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802175:	00 00 00 
	stat->st_dev = &devpipe;
  802178:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80217f:	40 80 00 
	return 0;
}
  802182:	b8 00 00 00 00       	mov    $0x0,%eax
  802187:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80218a:	5b                   	pop    %ebx
  80218b:	5e                   	pop    %esi
  80218c:	c9                   	leave  
  80218d:	c3                   	ret    

0080218e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	53                   	push   %ebx
  802192:	83 ec 0c             	sub    $0xc,%esp
  802195:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802198:	53                   	push   %ebx
  802199:	6a 00                	push   $0x0
  80219b:	e8 c9 ed ff ff       	call   800f69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021a0:	89 1c 24             	mov    %ebx,(%esp)
  8021a3:	e8 b0 f1 ff ff       	call   801358 <fd2data>
  8021a8:	83 c4 08             	add    $0x8,%esp
  8021ab:	50                   	push   %eax
  8021ac:	6a 00                	push   $0x0
  8021ae:	e8 b6 ed ff ff       	call   800f69 <sys_page_unmap>
}
  8021b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	57                   	push   %edi
  8021bc:	56                   	push   %esi
  8021bd:	53                   	push   %ebx
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8021c4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021c6:	a1 04 50 80 00       	mov    0x805004,%eax
  8021cb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8021ce:	83 ec 0c             	sub    $0xc,%esp
  8021d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d4:	e8 b7 04 00 00       	call   802690 <pageref>
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	89 3c 24             	mov    %edi,(%esp)
  8021de:	e8 ad 04 00 00       	call   802690 <pageref>
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	39 c3                	cmp    %eax,%ebx
  8021e8:	0f 94 c0             	sete   %al
  8021eb:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  8021ee:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8021f4:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  8021f7:	39 c6                	cmp    %eax,%esi
  8021f9:	74 1b                	je     802216 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  8021fb:	83 f9 01             	cmp    $0x1,%ecx
  8021fe:	75 c6                	jne    8021c6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802200:	8b 42 58             	mov    0x58(%edx),%eax
  802203:	6a 01                	push   $0x1
  802205:	50                   	push   %eax
  802206:	56                   	push   %esi
  802207:	68 b9 30 80 00       	push   $0x8030b9
  80220c:	e8 74 e3 ff ff       	call   800585 <cprintf>
  802211:	83 c4 10             	add    $0x10,%esp
  802214:	eb b0                	jmp    8021c6 <_pipeisclosed+0xe>
	}
}
  802216:	89 c8                	mov    %ecx,%eax
  802218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5f                   	pop    %edi
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	57                   	push   %edi
  802224:	56                   	push   %esi
  802225:	53                   	push   %ebx
  802226:	83 ec 18             	sub    $0x18,%esp
  802229:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80222c:	56                   	push   %esi
  80222d:	e8 26 f1 ff ff       	call   801358 <fd2data>
  802232:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  802234:	8b 45 0c             	mov    0xc(%ebp),%eax
  802237:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80223a:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  80223f:	83 c4 10             	add    $0x10,%esp
  802242:	eb 40                	jmp    802284 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
  802249:	eb 40                	jmp    80228b <devpipe_write+0x6b>
  80224b:	89 da                	mov    %ebx,%edx
  80224d:	89 f0                	mov    %esi,%eax
  80224f:	e8 64 ff ff ff       	call   8021b8 <_pipeisclosed>
  802254:	85 c0                	test   %eax,%eax
  802256:	75 ec                	jne    802244 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802258:	e8 d3 ed ff ff       	call   801030 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80225d:	8b 53 04             	mov    0x4(%ebx),%edx
  802260:	8b 03                	mov    (%ebx),%eax
  802262:	83 c0 20             	add    $0x20,%eax
  802265:	39 c2                	cmp    %eax,%edx
  802267:	73 e2                	jae    80224b <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802269:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80226f:	79 05                	jns    802276 <devpipe_write+0x56>
  802271:	4a                   	dec    %edx
  802272:	83 ca e0             	or     $0xffffffe0,%edx
  802275:	42                   	inc    %edx
  802276:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802279:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  80227c:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802280:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802283:	47                   	inc    %edi
  802284:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802287:	75 d4                	jne    80225d <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802289:	89 f8                	mov    %edi,%eax
}
  80228b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228e:	5b                   	pop    %ebx
  80228f:	5e                   	pop    %esi
  802290:	5f                   	pop    %edi
  802291:	c9                   	leave  
  802292:	c3                   	ret    

00802293 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802293:	55                   	push   %ebp
  802294:	89 e5                	mov    %esp,%ebp
  802296:	57                   	push   %edi
  802297:	56                   	push   %esi
  802298:	53                   	push   %ebx
  802299:	83 ec 18             	sub    $0x18,%esp
  80229c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80229f:	57                   	push   %edi
  8022a0:	e8 b3 f0 ff ff       	call   801358 <fd2data>
  8022a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8022ad:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	eb 41                	jmp    8022f8 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8022b7:	89 f0                	mov    %esi,%eax
  8022b9:	eb 44                	jmp    8022ff <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c0:	eb 3d                	jmp    8022ff <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022c2:	85 f6                	test   %esi,%esi
  8022c4:	75 f1                	jne    8022b7 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022c6:	89 da                	mov    %ebx,%edx
  8022c8:	89 f8                	mov    %edi,%eax
  8022ca:	e8 e9 fe ff ff       	call   8021b8 <_pipeisclosed>
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	75 e8                	jne    8022bb <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022d3:	e8 58 ed ff ff       	call   801030 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022d8:	8b 03                	mov    (%ebx),%eax
  8022da:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022dd:	74 e3                	je     8022c2 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022df:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022e4:	79 05                	jns    8022eb <devpipe_read+0x58>
  8022e6:	48                   	dec    %eax
  8022e7:	83 c8 e0             	or     $0xffffffe0,%eax
  8022ea:	40                   	inc    %eax
  8022eb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022f2:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  8022f5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022f7:	46                   	inc    %esi
  8022f8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022fb:	75 db                	jne    8022d8 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022fd:	89 f0                	mov    %esi,%eax
}
  8022ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802302:	5b                   	pop    %ebx
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	ff 75 08             	pushl  0x8(%ebp)
  802314:	e8 aa f0 ff ff       	call   8013c3 <fd_lookup>
  802319:	83 c4 10             	add    $0x10,%esp
  80231c:	85 c0                	test   %eax,%eax
  80231e:	78 18                	js     802338 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802320:	83 ec 0c             	sub    $0xc,%esp
  802323:	ff 75 fc             	pushl  -0x4(%ebp)
  802326:	e8 2d f0 ff ff       	call   801358 <fd2data>
  80232b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80232d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802330:	e8 83 fe ff ff       	call   8021b8 <_pipeisclosed>
  802335:	83 c4 10             	add    $0x10,%esp
}
  802338:	c9                   	leave  
  802339:	c3                   	ret    

0080233a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	57                   	push   %edi
  80233e:	56                   	push   %esi
  80233f:	53                   	push   %ebx
  802340:	83 ec 28             	sub    $0x28,%esp
  802343:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802346:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802349:	50                   	push   %eax
  80234a:	e8 21 f0 ff ff       	call   801370 <fd_alloc>
  80234f:	89 c3                	mov    %eax,%ebx
  802351:	83 c4 10             	add    $0x10,%esp
  802354:	85 c0                	test   %eax,%eax
  802356:	0f 88 24 01 00 00    	js     802480 <pipe+0x146>
  80235c:	83 ec 04             	sub    $0x4,%esp
  80235f:	68 07 04 00 00       	push   $0x407
  802364:	ff 75 f0             	pushl  -0x10(%ebp)
  802367:	6a 00                	push   $0x0
  802369:	e8 7f ec ff ff       	call   800fed <sys_page_alloc>
  80236e:	89 c3                	mov    %eax,%ebx
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	85 c0                	test   %eax,%eax
  802375:	0f 88 05 01 00 00    	js     802480 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80237b:	83 ec 0c             	sub    $0xc,%esp
  80237e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802381:	50                   	push   %eax
  802382:	e8 e9 ef ff ff       	call   801370 <fd_alloc>
  802387:	89 c3                	mov    %eax,%ebx
  802389:	83 c4 10             	add    $0x10,%esp
  80238c:	85 c0                	test   %eax,%eax
  80238e:	0f 88 dc 00 00 00    	js     802470 <pipe+0x136>
  802394:	83 ec 04             	sub    $0x4,%esp
  802397:	68 07 04 00 00       	push   $0x407
  80239c:	ff 75 ec             	pushl  -0x14(%ebp)
  80239f:	6a 00                	push   $0x0
  8023a1:	e8 47 ec ff ff       	call   800fed <sys_page_alloc>
  8023a6:	89 c3                	mov    %eax,%ebx
  8023a8:	83 c4 10             	add    $0x10,%esp
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	0f 88 bd 00 00 00    	js     802470 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023b3:	83 ec 0c             	sub    $0xc,%esp
  8023b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8023b9:	e8 9a ef ff ff       	call   801358 <fd2data>
  8023be:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c0:	83 c4 0c             	add    $0xc,%esp
  8023c3:	68 07 04 00 00       	push   $0x407
  8023c8:	50                   	push   %eax
  8023c9:	6a 00                	push   $0x0
  8023cb:	e8 1d ec ff ff       	call   800fed <sys_page_alloc>
  8023d0:	89 c3                	mov    %eax,%ebx
  8023d2:	83 c4 10             	add    $0x10,%esp
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	0f 88 83 00 00 00    	js     802460 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023dd:	83 ec 0c             	sub    $0xc,%esp
  8023e0:	ff 75 ec             	pushl  -0x14(%ebp)
  8023e3:	e8 70 ef ff ff       	call   801358 <fd2data>
  8023e8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023ef:	50                   	push   %eax
  8023f0:	6a 00                	push   $0x0
  8023f2:	56                   	push   %esi
  8023f3:	6a 00                	push   $0x0
  8023f5:	e8 b1 eb ff ff       	call   800fab <sys_page_map>
  8023fa:	89 c3                	mov    %eax,%ebx
  8023fc:	83 c4 20             	add    $0x20,%esp
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 4f                	js     802452 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802403:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802409:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80240c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80240e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802411:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802418:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80241e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802421:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802423:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802426:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80242d:	83 ec 0c             	sub    $0xc,%esp
  802430:	ff 75 f0             	pushl  -0x10(%ebp)
  802433:	e8 10 ef ff ff       	call   801348 <fd2num>
  802438:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80243a:	83 c4 04             	add    $0x4,%esp
  80243d:	ff 75 ec             	pushl  -0x14(%ebp)
  802440:	e8 03 ef ff ff       	call   801348 <fd2num>
  802445:	89 47 04             	mov    %eax,0x4(%edi)
  802448:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  80244d:	83 c4 10             	add    $0x10,%esp
  802450:	eb 2e                	jmp    802480 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802452:	83 ec 08             	sub    $0x8,%esp
  802455:	56                   	push   %esi
  802456:	6a 00                	push   $0x0
  802458:	e8 0c eb ff ff       	call   800f69 <sys_page_unmap>
  80245d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802460:	83 ec 08             	sub    $0x8,%esp
  802463:	ff 75 ec             	pushl  -0x14(%ebp)
  802466:	6a 00                	push   $0x0
  802468:	e8 fc ea ff ff       	call   800f69 <sys_page_unmap>
  80246d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802470:	83 ec 08             	sub    $0x8,%esp
  802473:	ff 75 f0             	pushl  -0x10(%ebp)
  802476:	6a 00                	push   $0x0
  802478:	e8 ec ea ff ff       	call   800f69 <sys_page_unmap>
  80247d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802480:	89 d8                	mov    %ebx,%eax
  802482:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802485:	5b                   	pop    %ebx
  802486:	5e                   	pop    %esi
  802487:	5f                   	pop    %edi
  802488:	c9                   	leave  
  802489:	c3                   	ret    
	...

0080248c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
  80248f:	56                   	push   %esi
  802490:	53                   	push   %ebx
  802491:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802494:	85 f6                	test   %esi,%esi
  802496:	75 16                	jne    8024ae <wait+0x22>
  802498:	68 d1 30 80 00       	push   $0x8030d1
  80249d:	68 03 30 80 00       	push   $0x803003
  8024a2:	6a 09                	push   $0x9
  8024a4:	68 dc 30 80 00       	push   $0x8030dc
  8024a9:	e8 36 e0 ff ff       	call   8004e4 <_panic>
	e = &envs[ENVX(envid)];
  8024ae:	89 f0                	mov    %esi,%eax
  8024b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8024b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8024bc:	c1 e0 07             	shl    $0x7,%eax
  8024bf:	29 d0                	sub    %edx,%eax
  8024c1:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  8024c7:	eb 05                	jmp    8024ce <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  8024c9:	e8 62 eb ff ff       	call   801030 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024ce:	8b 43 48             	mov    0x48(%ebx),%eax
  8024d1:	39 c6                	cmp    %eax,%esi
  8024d3:	75 07                	jne    8024dc <wait+0x50>
  8024d5:	8b 43 54             	mov    0x54(%ebx),%eax
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	75 ed                	jne    8024c9 <wait+0x3d>
		sys_yield();
}
  8024dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	c9                   	leave  
  8024e2:	c3                   	ret    
	...

008024e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024ea:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024f1:	75 64                	jne    802557 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  8024f3:	a1 04 50 80 00       	mov    0x805004,%eax
  8024f8:	8b 40 48             	mov    0x48(%eax),%eax
  8024fb:	83 ec 04             	sub    $0x4,%esp
  8024fe:	6a 07                	push   $0x7
  802500:	68 00 f0 bf ee       	push   $0xeebff000
  802505:	50                   	push   %eax
  802506:	e8 e2 ea ff ff       	call   800fed <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  80250b:	83 c4 10             	add    $0x10,%esp
  80250e:	85 c0                	test   %eax,%eax
  802510:	79 14                	jns    802526 <set_pgfault_handler+0x42>
  802512:	83 ec 04             	sub    $0x4,%esp
  802515:	68 e8 30 80 00       	push   $0x8030e8
  80251a:	6a 22                	push   $0x22
  80251c:	68 51 31 80 00       	push   $0x803151
  802521:	e8 be df ff ff       	call   8004e4 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  802526:	a1 04 50 80 00       	mov    0x805004,%eax
  80252b:	8b 40 48             	mov    0x48(%eax),%eax
  80252e:	83 ec 08             	sub    $0x8,%esp
  802531:	68 64 25 80 00       	push   $0x802564
  802536:	50                   	push   %eax
  802537:	e8 67 e9 ff ff       	call   800ea3 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  80253c:	83 c4 10             	add    $0x10,%esp
  80253f:	85 c0                	test   %eax,%eax
  802541:	79 14                	jns    802557 <set_pgfault_handler+0x73>
  802543:	83 ec 04             	sub    $0x4,%esp
  802546:	68 18 31 80 00       	push   $0x803118
  80254b:	6a 25                	push   $0x25
  80254d:	68 51 31 80 00       	push   $0x803151
  802552:	e8 8d df ff ff       	call   8004e4 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802557:	8b 45 08             	mov    0x8(%ebp),%eax
  80255a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80255f:	c9                   	leave  
  802560:	c3                   	ret    
  802561:	00 00                	add    %al,(%eax)
	...

00802564 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802564:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802565:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80256a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80256c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  80256f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802573:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802576:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  80257a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  80257e:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  802580:	83 c4 08             	add    $0x8,%esp
	popal
  802583:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802584:	83 c4 04             	add    $0x4,%esp
	popfl
  802587:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802588:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  802589:	c3                   	ret    
	...

0080258c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80258c:	55                   	push   %ebp
  80258d:	89 e5                	mov    %esp,%ebp
  80258f:	53                   	push   %ebx
  802590:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802593:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802598:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  80259f:	89 c8                	mov    %ecx,%eax
  8025a1:	c1 e0 07             	shl    $0x7,%eax
  8025a4:	29 d0                	sub    %edx,%eax
  8025a6:	89 c2                	mov    %eax,%edx
  8025a8:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  8025ae:	8b 40 50             	mov    0x50(%eax),%eax
  8025b1:	39 d8                	cmp    %ebx,%eax
  8025b3:	75 0b                	jne    8025c0 <ipc_find_env+0x34>
			return envs[i].env_id;
  8025b5:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  8025bb:	8b 40 40             	mov    0x40(%eax),%eax
  8025be:	eb 0e                	jmp    8025ce <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025c0:	41                   	inc    %ecx
  8025c1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  8025c7:	75 cf                	jne    802598 <ipc_find_env+0xc>
  8025c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8025ce:	5b                   	pop    %ebx
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    

008025d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025d1:	55                   	push   %ebp
  8025d2:	89 e5                	mov    %esp,%ebp
  8025d4:	57                   	push   %edi
  8025d5:	56                   	push   %esi
  8025d6:	53                   	push   %ebx
  8025d7:	83 ec 0c             	sub    $0xc,%esp
  8025da:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025e0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8025e3:	85 db                	test   %ebx,%ebx
  8025e5:	75 05                	jne    8025ec <ipc_send+0x1b>
  8025e7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8025ec:	56                   	push   %esi
  8025ed:	53                   	push   %ebx
  8025ee:	57                   	push   %edi
  8025ef:	ff 75 08             	pushl  0x8(%ebp)
  8025f2:	e8 89 e8 ff ff       	call   800e80 <sys_ipc_try_send>
		if (r == 0) {		//success
  8025f7:	83 c4 10             	add    $0x10,%esp
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	74 20                	je     80261e <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8025fe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802601:	75 07                	jne    80260a <ipc_send+0x39>
			sys_yield();
  802603:	e8 28 ea ff ff       	call   801030 <sys_yield>
  802608:	eb e2                	jmp    8025ec <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  80260a:	83 ec 04             	sub    $0x4,%esp
  80260d:	68 60 31 80 00       	push   $0x803160
  802612:	6a 41                	push   $0x41
  802614:	68 84 31 80 00       	push   $0x803184
  802619:	e8 c6 de ff ff       	call   8004e4 <_panic>
		}
	}
}
  80261e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802621:	5b                   	pop    %ebx
  802622:	5e                   	pop    %esi
  802623:	5f                   	pop    %edi
  802624:	c9                   	leave  
  802625:	c3                   	ret    

00802626 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	56                   	push   %esi
  80262a:	53                   	push   %ebx
  80262b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80262e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802631:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802634:	85 c0                	test   %eax,%eax
  802636:	75 05                	jne    80263d <ipc_recv+0x17>
  802638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  80263d:	83 ec 0c             	sub    $0xc,%esp
  802640:	50                   	push   %eax
  802641:	e8 f9 e7 ff ff       	call   800e3f <sys_ipc_recv>
	if (r < 0) {				
  802646:	83 c4 10             	add    $0x10,%esp
  802649:	85 c0                	test   %eax,%eax
  80264b:	79 16                	jns    802663 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  80264d:	85 db                	test   %ebx,%ebx
  80264f:	74 06                	je     802657 <ipc_recv+0x31>
  802651:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  802657:	85 f6                	test   %esi,%esi
  802659:	74 2c                	je     802687 <ipc_recv+0x61>
  80265b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802661:	eb 24                	jmp    802687 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  802663:	85 db                	test   %ebx,%ebx
  802665:	74 0a                	je     802671 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802667:	a1 04 50 80 00       	mov    0x805004,%eax
  80266c:	8b 40 74             	mov    0x74(%eax),%eax
  80266f:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  802671:	85 f6                	test   %esi,%esi
  802673:	74 0a                	je     80267f <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802675:	a1 04 50 80 00       	mov    0x805004,%eax
  80267a:	8b 40 78             	mov    0x78(%eax),%eax
  80267d:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80267f:	a1 04 50 80 00       	mov    0x805004,%eax
  802684:	8b 40 70             	mov    0x70(%eax),%eax
}
  802687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	c9                   	leave  
  80268d:	c3                   	ret    
	...

00802690 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802690:	55                   	push   %ebp
  802691:	89 e5                	mov    %esp,%ebp
  802693:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802696:	89 d0                	mov    %edx,%eax
  802698:	c1 e8 16             	shr    $0x16,%eax
  80269b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8026a2:	a8 01                	test   $0x1,%al
  8026a4:	74 20                	je     8026c6 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026a6:	89 d0                	mov    %edx,%eax
  8026a8:	c1 e8 0c             	shr    $0xc,%eax
  8026ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026b2:	a8 01                	test   $0x1,%al
  8026b4:	74 10                	je     8026c6 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026b6:	c1 e8 0c             	shr    $0xc,%eax
  8026b9:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026c0:	ef 
  8026c1:	0f b7 c0             	movzwl %ax,%eax
  8026c4:	eb 05                	jmp    8026cb <pageref+0x3b>
  8026c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026cb:	c9                   	leave  
  8026cc:	c3                   	ret    
  8026cd:	00 00                	add    %al,(%eax)
	...

008026d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	57                   	push   %edi
  8026d4:	56                   	push   %esi
  8026d5:	83 ec 28             	sub    $0x28,%esp
  8026d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8026df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8026e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8026e9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8026ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8026ef:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8026f1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  8026f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  8026f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026fc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ff:	85 ff                	test   %edi,%edi
  802701:	75 21                	jne    802724 <__udivdi3+0x54>
    {
      if (d0 > n1)
  802703:	39 d1                	cmp    %edx,%ecx
  802705:	76 49                	jbe    802750 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802707:	f7 f1                	div    %ecx
  802709:	89 c1                	mov    %eax,%ecx
  80270b:	31 c0                	xor    %eax,%eax
  80270d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802710:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  802713:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802716:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802719:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80271c:	83 c4 28             	add    $0x28,%esp
  80271f:	5e                   	pop    %esi
  802720:	5f                   	pop    %edi
  802721:	c9                   	leave  
  802722:	c3                   	ret    
  802723:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802724:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802727:	0f 87 97 00 00 00    	ja     8027c4 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80272d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802730:	83 f0 1f             	xor    $0x1f,%eax
  802733:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802736:	75 34                	jne    80276c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802738:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80273b:	72 08                	jb     802745 <__udivdi3+0x75>
  80273d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802740:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802743:	77 7f                	ja     8027c4 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802745:	b9 01 00 00 00       	mov    $0x1,%ecx
  80274a:	31 c0                	xor    %eax,%eax
  80274c:	eb c2                	jmp    802710 <__udivdi3+0x40>
  80274e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802753:	85 c0                	test   %eax,%eax
  802755:	74 79                	je     8027d0 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802757:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80275a:	89 fa                	mov    %edi,%edx
  80275c:	f7 f1                	div    %ecx
  80275e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802763:	f7 f1                	div    %ecx
  802765:	89 c1                	mov    %eax,%ecx
  802767:	89 f0                	mov    %esi,%eax
  802769:	eb a5                	jmp    802710 <__udivdi3+0x40>
  80276b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80276c:	b8 20 00 00 00       	mov    $0x20,%eax
  802771:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802777:	89 fa                	mov    %edi,%edx
  802779:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80277c:	d3 e2                	shl    %cl,%edx
  80277e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802781:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802784:	d3 e8                	shr    %cl,%eax
  802786:	89 d7                	mov    %edx,%edi
  802788:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80278a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80278d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802790:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802792:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802795:	d3 e0                	shl    %cl,%eax
  802797:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80279a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80279d:	d3 ea                	shr    %cl,%edx
  80279f:	09 d0                	or     %edx,%eax
  8027a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027a4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8027a7:	d3 ea                	shr    %cl,%edx
  8027a9:	f7 f7                	div    %edi
  8027ab:	89 d7                	mov    %edx,%edi
  8027ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8027b0:	f7 e6                	mul    %esi
  8027b2:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027b4:	39 d7                	cmp    %edx,%edi
  8027b6:	72 38                	jb     8027f0 <__udivdi3+0x120>
  8027b8:	74 27                	je     8027e1 <__udivdi3+0x111>
  8027ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8027bd:	31 c0                	xor    %eax,%eax
  8027bf:	e9 4c ff ff ff       	jmp    802710 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027c4:	31 c9                	xor    %ecx,%ecx
  8027c6:	31 c0                	xor    %eax,%eax
  8027c8:	e9 43 ff ff ff       	jmp    802710 <__udivdi3+0x40>
  8027cd:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d5:	31 d2                	xor    %edx,%edx
  8027d7:	f7 75 f4             	divl   -0xc(%ebp)
  8027da:	89 c1                	mov    %eax,%ecx
  8027dc:	e9 76 ff ff ff       	jmp    802757 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8027e4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	39 f0                	cmp    %esi,%eax
  8027eb:	73 cd                	jae    8027ba <__udivdi3+0xea>
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027f0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8027f3:	49                   	dec    %ecx
  8027f4:	31 c0                	xor    %eax,%eax
  8027f6:	e9 15 ff ff ff       	jmp    802710 <__udivdi3+0x40>
	...

008027fc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	57                   	push   %edi
  802800:	56                   	push   %esi
  802801:	83 ec 30             	sub    $0x30,%esp
  802804:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80280b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802812:	8b 75 08             	mov    0x8(%ebp),%esi
  802815:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802818:	8b 45 10             	mov    0x10(%ebp),%eax
  80281b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80281e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802821:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802823:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  802826:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  802829:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80282c:	85 d2                	test   %edx,%edx
  80282e:	75 1c                	jne    80284c <__umoddi3+0x50>
    {
      if (d0 > n1)
  802830:	89 fa                	mov    %edi,%edx
  802832:	39 f8                	cmp    %edi,%eax
  802834:	0f 86 c2 00 00 00    	jbe    8028fc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80283a:	89 f0                	mov    %esi,%eax
  80283c:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80283e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802841:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802848:	eb 12                	jmp    80285c <__umoddi3+0x60>
  80284a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80284c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80284f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802852:	76 18                	jbe    80286c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802854:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  802857:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80285a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80285c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80285f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802862:	83 c4 30             	add    $0x30,%esp
  802865:	5e                   	pop    %esi
  802866:	5f                   	pop    %edi
  802867:	c9                   	leave  
  802868:	c3                   	ret    
  802869:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80286c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802870:	83 f0 1f             	xor    $0x1f,%eax
  802873:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802876:	0f 84 ac 00 00 00    	je     802928 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80287c:	b8 20 00 00 00       	mov    $0x20,%eax
  802881:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802884:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802887:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80288a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80288d:	d3 e2                	shl    %cl,%edx
  80288f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802892:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802895:	d3 e8                	shr    %cl,%eax
  802897:	89 d6                	mov    %edx,%esi
  802899:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80289b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80289e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8028a1:	d3 e0                	shl    %cl,%eax
  8028a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8028a6:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8028a9:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028ae:	d3 e0                	shl    %cl,%eax
  8028b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028b3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8028b6:	d3 ea                	shr    %cl,%edx
  8028b8:	09 d0                	or     %edx,%eax
  8028ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8028bd:	d3 ea                	shr    %cl,%edx
  8028bf:	f7 f6                	div    %esi
  8028c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8028c4:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028c7:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8028ca:	0f 82 8d 00 00 00    	jb     80295d <__umoddi3+0x161>
  8028d0:	0f 84 91 00 00 00    	je     802967 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028d6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8028d9:	29 c7                	sub    %eax,%edi
  8028db:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028dd:	89 f2                	mov    %esi,%edx
  8028df:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8028e2:	d3 e2                	shl    %cl,%edx
  8028e4:	89 f8                	mov    %edi,%eax
  8028e6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8028e9:	d3 e8                	shr    %cl,%eax
  8028eb:	09 c2                	or     %eax,%edx
  8028ed:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8028f0:	d3 ee                	shr    %cl,%esi
  8028f2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8028f5:	e9 62 ff ff ff       	jmp    80285c <__umoddi3+0x60>
  8028fa:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8028ff:	85 c0                	test   %eax,%eax
  802901:	74 15                	je     802918 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802903:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802906:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802909:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80290b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80290e:	f7 f1                	div    %ecx
  802910:	e9 29 ff ff ff       	jmp    80283e <__umoddi3+0x42>
  802915:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802918:	b8 01 00 00 00       	mov    $0x1,%eax
  80291d:	31 d2                	xor    %edx,%edx
  80291f:	f7 75 ec             	divl   -0x14(%ebp)
  802922:	89 c1                	mov    %eax,%ecx
  802924:	eb dd                	jmp    802903 <__umoddi3+0x107>
  802926:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802928:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80292b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80292e:	72 19                	jb     802949 <__umoddi3+0x14d>
  802930:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802933:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  802936:	76 11                	jbe    802949 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  802938:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80293b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80293e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802941:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802944:	e9 13 ff ff ff       	jmp    80285c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802949:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80294c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80294f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802952:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802955:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802958:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80295b:	eb db                	jmp    802938 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80295d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802960:	19 f2                	sbb    %esi,%edx
  802962:	e9 6f ff ff ff       	jmp    8028d6 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802967:	39 c7                	cmp    %eax,%edi
  802969:	72 f2                	jb     80295d <__umoddi3+0x161>
  80296b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80296e:	e9 63 ff ff ff       	jmp    8028d6 <__umoddi3+0xda>
