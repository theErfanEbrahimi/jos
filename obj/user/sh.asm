
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 7b 09 00 00       	call   8009ac <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
}


void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80003a:	68 00 32 80 00       	push   $0x803200
  80003f:	e8 6d 0a 00 00       	call   800ab1 <cprintf>
	exit();
  800044:	e8 b3 09 00 00       	call   8009fc <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
  80005a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  80005d:	85 f6                	test   %esi,%esi
  80005f:	75 22                	jne    800083 <_gettoken+0x35>
		if (debug > 1)
  800061:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800068:	0f 8e 2d 01 00 00    	jle    80019b <_gettoken+0x14d>
			cprintf("GETTOKEN NULL\n");
  80006e:	83 ec 0c             	sub    $0xc,%esp
  800071:	68 72 32 80 00       	push   $0x803272
  800076:	e8 36 0a 00 00       	call   800ab1 <cprintf>
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	e9 1d 01 00 00       	jmp    8001a0 <_gettoken+0x152>
		return 0;
	}

	if (debug > 1)
  800083:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80008a:	7e 11                	jle    80009d <_gettoken+0x4f>
		cprintf("GETTOKEN: %s\n", s);
  80008c:	83 ec 08             	sub    $0x8,%esp
  80008f:	56                   	push   %esi
  800090:	68 81 32 80 00       	push   $0x803281
  800095:	e8 17 0a 00 00       	call   800ab1 <cprintf>
  80009a:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80009d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  8000a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8000ac:	eb 04                	jmp    8000b2 <_gettoken+0x64>

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
  8000ae:	c6 06 00             	movb   $0x0,(%esi)
  8000b1:	46                   	inc    %esi
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	0f be 06             	movsbl (%esi),%eax
  8000b8:	50                   	push   %eax
  8000b9:	68 8f 32 80 00       	push   $0x80328f
  8000be:	e8 0c 11 00 00       	call   8011cf <strchr>
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 e4                	jne    8000ae <_gettoken+0x60>
  8000ca:	89 f3                	mov    %esi,%ebx
		*s++ = 0;
	if (*s == 0) {
  8000cc:	8a 06                	mov    (%esi),%al
  8000ce:	84 c0                	test   %al,%al
  8000d0:	75 27                	jne    8000f9 <_gettoken+0xab>
		if (debug > 1)
  8000d2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000d9:	0f 8e bc 00 00 00    	jle    80019b <_gettoken+0x14d>
			cprintf("EOL\n");
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	68 94 32 80 00       	push   $0x803294
  8000e7:	e8 c5 09 00 00       	call   800ab1 <cprintf>
  8000ec:	be 00 00 00 00       	mov    $0x0,%esi
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	e9 a7 00 00 00       	jmp    8001a0 <_gettoken+0x152>
		return 0;
	}
	if (strchr(SYMBOLS, *s)) {
  8000f9:	83 ec 08             	sub    $0x8,%esp
  8000fc:	0f be c0             	movsbl %al,%eax
  8000ff:	50                   	push   %eax
  800100:	68 a5 32 80 00       	push   $0x8032a5
  800105:	e8 c5 10 00 00       	call   8011cf <strchr>
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	85 c0                	test   %eax,%eax
  80010f:	74 2c                	je     80013d <_gettoken+0xef>
		t = *s;
  800111:	0f be 36             	movsbl (%esi),%esi
		*p1 = s;
  800114:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  800116:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  800119:	8d 43 01             	lea    0x1(%ebx),%eax
  80011c:	8b 55 10             	mov    0x10(%ebp),%edx
  80011f:	89 02                	mov    %eax,(%edx)
		if (debug > 1)
  800121:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800128:	7e 76                	jle    8001a0 <_gettoken+0x152>
			cprintf("TOK %c\n", t);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	56                   	push   %esi
  80012e:	68 99 32 80 00       	push   $0x803299
  800133:	e8 79 09 00 00       	call   800ab1 <cprintf>
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	eb 63                	jmp    8001a0 <_gettoken+0x152>
		return t;
	}
	*p1 = s;
  80013d:	89 37                	mov    %esi,(%edi)
  80013f:	eb 01                	jmp    800142 <_gettoken+0xf4>
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
  800141:	46                   	inc    %esi
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800142:	8a 06                	mov    (%esi),%al
  800144:	84 c0                	test   %al,%al
  800146:	74 18                	je     800160 <_gettoken+0x112>
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	0f be c0             	movsbl %al,%eax
  80014e:	50                   	push   %eax
  80014f:	68 a1 32 80 00       	push   $0x8032a1
  800154:	e8 76 10 00 00       	call   8011cf <strchr>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	74 e1                	je     800141 <_gettoken+0xf3>
		s++;
	*p2 = s;
  800160:	8b 45 10             	mov    0x10(%ebp),%eax
  800163:	89 30                	mov    %esi,(%eax)
	if (debug > 1) {
  800165:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80016c:	7f 07                	jg     800175 <_gettoken+0x127>
  80016e:	be 77 00 00 00       	mov    $0x77,%esi
  800173:	eb 2b                	jmp    8001a0 <_gettoken+0x152>
		t = **p2;
  800175:	0f be 1e             	movsbl (%esi),%ebx
		**p2 = 0;
  800178:	c6 06 00             	movb   $0x0,(%esi)
		cprintf("WORD: %s\n", *p1);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	ff 37                	pushl  (%edi)
  800180:	68 ad 32 80 00       	push   $0x8032ad
  800185:	e8 27 09 00 00       	call   800ab1 <cprintf>
		**p2 = t;
  80018a:	8b 55 10             	mov    0x10(%ebp),%edx
  80018d:	8b 02                	mov    (%edx),%eax
  80018f:	88 18                	mov    %bl,(%eax)
  800191:	be 77 00 00 00       	mov    $0x77,%esi
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	eb 05                	jmp    8001a0 <_gettoken+0x152>
  80019b:	be 00 00 00 00       	mov    $0x0,%esi
	}
	return 'w';
}
  8001a0:	89 f0                	mov    %esi,%eax
  8001a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a5:	5b                   	pop    %ebx
  8001a6:	5e                   	pop    %esi
  8001a7:	5f                   	pop    %edi
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	83 ec 08             	sub    $0x8,%esp
  8001b0:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001b3:	85 c0                	test   %eax,%eax
  8001b5:	74 22                	je     8001d9 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001b7:	83 ec 04             	sub    $0x4,%esp
  8001ba:	68 04 50 80 00       	push   $0x805004
  8001bf:	68 08 50 80 00       	push   $0x805008
  8001c4:	50                   	push   %eax
  8001c5:	e8 84 fe ff ff       	call   80004e <_gettoken>
  8001ca:	a3 0c 50 80 00       	mov    %eax,0x80500c
  8001cf:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	eb 3a                	jmp    800213 <gettoken+0x69>
	}
	c = nc;
  8001d9:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8001de:	a3 10 50 80 00       	mov    %eax,0x805010
	*p1 = np1;
  8001e3:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8001e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ec:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001ee:	83 ec 04             	sub    $0x4,%esp
  8001f1:	68 04 50 80 00       	push   $0x805004
  8001f6:	68 08 50 80 00       	push   $0x805008
  8001fb:	ff 35 04 50 80 00    	pushl  0x805004
  800201:	e8 48 fe ff ff       	call   80004e <_gettoken>
  800206:	a3 0c 50 80 00       	mov    %eax,0x80500c
	return c;
  80020b:	a1 10 50 80 00       	mov    0x805010,%eax
  800210:	83 c4 10             	add    $0x10,%esp
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800221:	6a 00                	push   $0x0
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	e8 7f ff ff ff       	call   8001aa <gettoken>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 75 b0             	lea    -0x50(%ebp),%esi

again:
  800231:	bf 00 00 00 00       	mov    $0x0,%edi
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	6a 00                	push   $0x0
  80023c:	e8 69 ff ff ff       	call   8001aa <gettoken>
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	83 f8 77             	cmp    $0x77,%eax
  800247:	74 2e                	je     800277 <runcmd+0x62>
  800249:	83 f8 77             	cmp    $0x77,%eax
  80024c:	7f 1b                	jg     800269 <runcmd+0x54>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 48                	je     80029b <runcmd+0x86>
  800253:	83 f8 3e             	cmp    $0x3e,%eax
  800256:	0f 84 bb 00 00 00    	je     800317 <runcmd+0x102>
  80025c:	85 c0                	test   %eax,%eax
  80025e:	0f 84 3d 02 00 00    	je     8004a1 <runcmd+0x28c>
  800264:	e9 26 02 00 00       	jmp    80048f <runcmd+0x27a>
  800269:	83 f8 7c             	cmp    $0x7c,%eax
  80026c:	0f 85 1d 02 00 00    	jne    80048f <runcmd+0x27a>
  800272:	e9 20 01 00 00       	jmp    800397 <runcmd+0x182>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800277:	83 ff 10             	cmp    $0x10,%edi
  80027a:	75 15                	jne    800291 <runcmd+0x7c>
				cprintf("too many arguments\n");
  80027c:	83 ec 0c             	sub    $0xc,%esp
  80027f:	68 b7 32 80 00       	push   $0x8032b7
  800284:	e8 28 08 00 00       	call   800ab1 <cprintf>
				exit();
  800289:	e8 6e 07 00 00       	call   8009fc <exit>
  80028e:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800291:	8b 45 b0             	mov    -0x50(%ebp),%eax
  800294:	89 44 bd b4          	mov    %eax,-0x4c(%ebp,%edi,4)
  800298:	47                   	inc    %edi
  800299:	eb 9b                	jmp    800236 <runcmd+0x21>
			break;

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	6a 00                	push   $0x0
  8002a1:	e8 04 ff ff ff       	call   8001aa <gettoken>
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	83 f8 77             	cmp    $0x77,%eax
  8002ac:	74 15                	je     8002c3 <runcmd+0xae>
				cprintf("syntax error: < not followed by word\n");
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	68 24 32 80 00       	push   $0x803224
  8002b6:	e8 f6 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002bb:	e8 3c 07 00 00       	call   8009fc <exit>
  8002c0:	83 c4 10             	add    $0x10,%esp
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			//open t
			if((fd = open(t, O_RDONLY)) < 0){
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	6a 00                	push   $0x0
  8002c8:	ff 75 b0             	pushl  -0x50(%ebp)
  8002cb:	e8 6b 1f 00 00       	call   80223b <open>
  8002d0:	89 c3                	mov    %eax,%ebx
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	79 1b                	jns    8002f4 <runcmd+0xdf>
				cprintf("open t:%s to fd:%e failed!\n", t,fd);
  8002d9:	83 ec 04             	sub    $0x4,%esp
  8002dc:	50                   	push   %eax
  8002dd:	ff 75 b0             	pushl  -0x50(%ebp)
  8002e0:	68 cb 32 80 00       	push   $0x8032cb
  8002e5:	e8 c7 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002ea:	e8 0d 07 00 00       	call   8009fc <exit>
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	eb 08                	jmp    8002fc <runcmd+0xe7>
			}
			//check fd
			if(fd != 0){
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	0f 84 3a ff ff ff    	je     800236 <runcmd+0x21>
				dup(fd,0);
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	6a 00                	push   $0x0
  800301:	53                   	push   %ebx
  800302:	e8 17 1c 00 00       	call   801f1e <dup>
				close(fd);
  800307:	89 1c 24             	mov    %ebx,(%esp)
  80030a:	e8 a5 1b 00 00       	call   801eb4 <close>
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	e9 1f ff ff ff       	jmp    800236 <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	56                   	push   %esi
  80031b:	6a 00                	push   $0x0
  80031d:	e8 88 fe ff ff       	call   8001aa <gettoken>
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	83 f8 77             	cmp    $0x77,%eax
  800328:	74 15                	je     80033f <runcmd+0x12a>
				cprintf("syntax error: > not followed by word\n");
  80032a:	83 ec 0c             	sub    $0xc,%esp
  80032d:	68 4c 32 80 00       	push   $0x80324c
  800332:	e8 7a 07 00 00       	call   800ab1 <cprintf>
				exit();
  800337:	e8 c0 06 00 00       	call   8009fc <exit>
  80033c:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	68 01 03 00 00       	push   $0x301
  800347:	ff 75 b0             	pushl  -0x50(%ebp)
  80034a:	e8 ec 1e 00 00       	call   80223b <open>
  80034f:	89 c3                	mov    %eax,%ebx
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	85 c0                	test   %eax,%eax
  800356:	79 1b                	jns    800373 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  800358:	83 ec 04             	sub    $0x4,%esp
  80035b:	50                   	push   %eax
  80035c:	ff 75 b0             	pushl  -0x50(%ebp)
  80035f:	68 e7 32 80 00       	push   $0x8032e7
  800364:	e8 48 07 00 00       	call   800ab1 <cprintf>
				exit();
  800369:	e8 8e 06 00 00       	call   8009fc <exit>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	eb 09                	jmp    80037c <runcmd+0x167>
			}
			if (fd != 1) {
  800373:	83 f8 01             	cmp    $0x1,%eax
  800376:	0f 84 ba fe ff ff    	je     800236 <runcmd+0x21>
				dup(fd, 1);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	6a 01                	push   $0x1
  800381:	53                   	push   %ebx
  800382:	e8 97 1b 00 00       	call   801f1e <dup>
				close(fd);
  800387:	89 1c 24             	mov    %ebx,(%esp)
  80038a:	e8 25 1b 00 00       	call   801eb4 <close>
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	e9 9f fe ff ff       	jmp    800236 <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800397:	83 ec 0c             	sub    $0xc,%esp
  80039a:	8d 85 a8 fb ff ff    	lea    -0x458(%ebp),%eax
  8003a0:	50                   	push   %eax
  8003a1:	e8 08 28 00 00       	call   802bae <pipe>
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	79 16                	jns    8003c3 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	50                   	push   %eax
  8003b1:	68 fd 32 80 00       	push   $0x8032fd
  8003b6:	e8 f6 06 00 00       	call   800ab1 <cprintf>
				exit();
  8003bb:	e8 3c 06 00 00       	call   8009fc <exit>
  8003c0:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003c3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003ca:	74 1c                	je     8003e8 <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003cc:	83 ec 04             	sub    $0x4,%esp
  8003cf:	ff b5 ac fb ff ff    	pushl  -0x454(%ebp)
  8003d5:	ff b5 a8 fb ff ff    	pushl  -0x458(%ebp)
  8003db:	68 06 33 80 00       	push   $0x803306
  8003e0:	e8 cc 06 00 00       	call   800ab1 <cprintf>
  8003e5:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003e8:	e8 ed 12 00 00       	call   8016da <fork>
  8003ed:	89 c3                	mov    %eax,%ebx
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	0f 88 80 00 00 00    	js     800477 <runcmd+0x262>
				cprintf("fork: %e", r);
				exit();
			}
			if (r == 0) {
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	75 3c                	jne    800437 <runcmd+0x222>
				if (p[0] != 0) {
  8003fb:	8b 85 a8 fb ff ff    	mov    -0x458(%ebp),%eax
  800401:	85 c0                	test   %eax,%eax
  800403:	74 1c                	je     800421 <runcmd+0x20c>
					dup(p[0], 0);
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	6a 00                	push   $0x0
  80040a:	50                   	push   %eax
  80040b:	e8 0e 1b 00 00       	call   801f1e <dup>
					close(p[0]);
  800410:	83 c4 04             	add    $0x4,%esp
  800413:	ff b5 a8 fb ff ff    	pushl  -0x458(%ebp)
  800419:	e8 96 1a 00 00       	call   801eb4 <close>
  80041e:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800421:	83 ec 0c             	sub    $0xc,%esp
  800424:	ff b5 ac fb ff ff    	pushl  -0x454(%ebp)
  80042a:	e8 85 1a 00 00       	call   801eb4 <close>
				goto again;
  80042f:	83 c4 10             	add    $0x10,%esp
  800432:	e9 fa fd ff ff       	jmp    800231 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800437:	8b 85 ac fb ff ff    	mov    -0x454(%ebp),%eax
  80043d:	83 f8 01             	cmp    $0x1,%eax
  800440:	74 1c                	je     80045e <runcmd+0x249>
					dup(p[1], 1);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	6a 01                	push   $0x1
  800447:	50                   	push   %eax
  800448:	e8 d1 1a 00 00       	call   801f1e <dup>
					close(p[1]);
  80044d:	83 c4 04             	add    $0x4,%esp
  800450:	ff b5 ac fb ff ff    	pushl  -0x454(%ebp)
  800456:	e8 59 1a 00 00       	call   801eb4 <close>
  80045b:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  80045e:	83 ec 0c             	sub    $0xc,%esp
  800461:	ff b5 a8 fb ff ff    	pushl  -0x458(%ebp)
  800467:	e8 48 1a 00 00       	call   801eb4 <close>
  80046c:	89 9d a0 fb ff ff    	mov    %ebx,-0x460(%ebp)
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 34                	jmp    8004ab <runcmd+0x296>
				exit();
			}
			if (debug)
				cprintf("PIPE: %d %d\n", p[0], p[1]);
			if ((r = fork()) < 0) {
				cprintf("fork: %e", r);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	50                   	push   %eax
  80047b:	68 13 33 80 00       	push   $0x803313
  800480:	e8 2c 06 00 00       	call   800ab1 <cprintf>
				exit();
  800485:	e8 72 05 00 00       	call   8009fc <exit>
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb a8                	jmp    800437 <runcmd+0x222>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80048f:	50                   	push   %eax
  800490:	68 1c 33 80 00       	push   $0x80331c
  800495:	6a 79                	push   $0x79
  800497:	68 38 33 80 00       	push   $0x803338
  80049c:	e8 6f 05 00 00       	call   800a10 <_panic>
  8004a1:	c7 85 a0 fb ff ff 00 	movl   $0x0,-0x460(%ebp)
  8004a8:	00 00 00 
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  8004ab:	85 ff                	test   %edi,%edi
  8004ad:	75 22                	jne    8004d1 <runcmd+0x2bc>
		if (debug)
  8004af:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b6:	0f 84 8f 01 00 00    	je     80064b <runcmd+0x436>
			cprintf("EMPTY COMMAND\n");
  8004bc:	83 ec 0c             	sub    $0xc,%esp
  8004bf:	68 42 33 80 00       	push   $0x803342
  8004c4:	e8 e8 05 00 00       	call   800ab1 <cprintf>
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	e9 7a 01 00 00       	jmp    80064b <runcmd+0x436>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004d1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8004d4:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004d7:	74 23                	je     8004fc <runcmd+0x2e7>
		argv0buf[0] = '/';
  8004d9:	c6 85 b0 fb ff ff 2f 	movb   $0x2f,-0x450(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	50                   	push   %eax
  8004e4:	8d 9d b0 fb ff ff    	lea    -0x450(%ebp),%ebx
  8004ea:	8d 85 b1 fb ff ff    	lea    -0x44f(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	e8 f1 0b 00 00       	call   8010e7 <strcpy>
		argv[0] = argv0buf;
  8004f6:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004fc:	c7 44 bd b4 00 00 00 	movl   $0x0,-0x4c(%ebp,%edi,4)
  800503:	00 

	// Print the command.
	if (debug) {
  800504:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80050b:	74 4c                	je     800559 <runcmd+0x344>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  80050d:	a1 24 54 80 00       	mov    0x805424,%eax
  800512:	8b 40 48             	mov    0x48(%eax),%eax
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	50                   	push   %eax
  800519:	68 51 33 80 00       	push   $0x803351
  80051e:	e8 8e 05 00 00       	call   800ab1 <cprintf>
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		for (i = 0; argv[i]; i++)
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	8d 75 b4             	lea    -0x4c(%ebp),%esi
  80052e:	eb 12                	jmp    800542 <runcmd+0x32d>
			cprintf(" %s", argv[i]);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	50                   	push   %eax
  800534:	68 d9 33 80 00       	push   $0x8033d9
  800539:	e8 73 05 00 00       	call   800ab1 <cprintf>
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  80053e:	43                   	inc    %ebx
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800545:	85 c0                	test   %eax,%eax
  800547:	75 e7                	jne    800530 <runcmd+0x31b>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	68 92 32 80 00       	push   $0x803292
  800551:	e8 5b 05 00 00       	call   800ab1 <cprintf>
  800556:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800559:	8d 45 b4             	lea    -0x4c(%ebp),%eax
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	50                   	push   %eax
  800560:	ff 75 b4             	pushl  -0x4c(%ebp)
  800563:	e8 7c 1e 00 00       	call   8023e4 <spawn>
  800568:	89 c3                	mov    %eax,%ebx
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	85 c0                	test   %eax,%eax
  80056f:	79 1b                	jns    80058c <runcmd+0x377>
		cprintf("spawn %s: %e\n", argv[0], r);
  800571:	83 ec 04             	sub    $0x4,%esp
  800574:	50                   	push   %eax
  800575:	ff 75 b4             	pushl  -0x4c(%ebp)
  800578:	68 5f 33 80 00       	push   $0x80335f
  80057d:	e8 2f 05 00 00       	call   800ab1 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800582:	e8 83 1a 00 00       	call   80200a <close_all>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	eb 56                	jmp    8005e2 <runcmd+0x3cd>
  80058c:	e8 79 1a 00 00       	call   80200a <close_all>
	if (r >= 0) {
		if (debug)
  800591:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800598:	74 1a                	je     8005b4 <runcmd+0x39f>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80059a:	a1 24 54 80 00       	mov    0x805424,%eax
  80059f:	8b 40 48             	mov    0x48(%eax),%eax
  8005a2:	53                   	push   %ebx
  8005a3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8005a6:	50                   	push   %eax
  8005a7:	68 6d 33 80 00       	push   $0x80336d
  8005ac:	e8 00 05 00 00       	call   800ab1 <cprintf>
  8005b1:	83 c4 10             	add    $0x10,%esp
		wait(r);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	e8 43 27 00 00       	call   802d00 <wait>
		if (debug)
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c7:	74 19                	je     8005e2 <runcmd+0x3cd>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	50                   	push   %eax
  8005d5:	68 82 33 80 00       	push   $0x803382
  8005da:	e8 d2 04 00 00       	call   800ab1 <cprintf>
  8005df:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005e2:	83 bd a0 fb ff ff 00 	cmpl   $0x0,-0x460(%ebp)
  8005e9:	74 5b                	je     800646 <runcmd+0x431>
		if (debug)
  8005eb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f2:	74 1f                	je     800613 <runcmd+0x3fe>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005f4:	a1 24 54 80 00       	mov    0x805424,%eax
  8005f9:	8b 40 48             	mov    0x48(%eax),%eax
  8005fc:	83 ec 04             	sub    $0x4,%esp
  8005ff:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800605:	50                   	push   %eax
  800606:	68 98 33 80 00       	push   $0x803398
  80060b:	e8 a1 04 00 00       	call   800ab1 <cprintf>
  800610:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  800613:	83 ec 0c             	sub    $0xc,%esp
  800616:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80061c:	e8 df 26 00 00       	call   802d00 <wait>
		if (debug)
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80062b:	74 19                	je     800646 <runcmd+0x431>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80062d:	a1 24 54 80 00       	mov    0x805424,%eax
  800632:	8b 40 48             	mov    0x48(%eax),%eax
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	50                   	push   %eax
  800639:	68 82 33 80 00       	push   $0x803382
  80063e:	e8 6e 04 00 00       	call   800ab1 <cprintf>
  800643:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800646:	e8 b1 03 00 00       	call   8009fc <exit>
}
  80064b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <umain>:
	exit();
}

void
umain(int argc, char **argv)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	57                   	push   %edi
  800657:	56                   	push   %esi
  800658:	53                   	push   %ebx
  800659:	83 ec 20             	sub    $0x20,%esp
  80065c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80065f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	56                   	push   %esi
  800664:	8d 45 08             	lea    0x8(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	e8 eb 12 00 00       	call   801958 <argstart>
  80066d:	bf 3f 00 00 00       	mov    $0x3f,%edi
  800672:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	while ((r = argnext(&args)) >= 0)
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	eb 2e                	jmp    8006ac <umain+0x59>
		switch (r) {
  80067e:	83 f8 69             	cmp    $0x69,%eax
  800681:	74 0c                	je     80068f <umain+0x3c>
  800683:	83 f8 78             	cmp    $0x78,%eax
  800686:	74 0e                	je     800696 <umain+0x43>
  800688:	83 f8 64             	cmp    $0x64,%eax
  80068b:	75 1a                	jne    8006a7 <umain+0x54>
  80068d:	eb 10                	jmp    80069f <umain+0x4c>
  80068f:	bf 01 00 00 00       	mov    $0x1,%edi
  800694:	eb 16                	jmp    8006ac <umain+0x59>
  800696:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  80069d:	eb 0d                	jmp    8006ac <umain+0x59>
		case 'd':
			debug++;
  80069f:	ff 05 00 50 80 00    	incl   0x805000
  8006a5:	eb 05                	jmp    8006ac <umain+0x59>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006a7:	e8 88 f9 ff ff       	call   800034 <usage>
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006b2:	50                   	push   %eax
  8006b3:	e8 5b 13 00 00       	call   801a13 <argnext>
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	79 bf                	jns    80067e <umain+0x2b>
  8006bf:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c1:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c5:	7e 05                	jle    8006cc <umain+0x79>
		usage();
  8006c7:	e8 68 f9 ff ff       	call   800034 <usage>
	if (argc == 2) {
  8006cc:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d0:	75 56                	jne    800728 <umain+0xd5>
		close(0);
  8006d2:	83 ec 0c             	sub    $0xc,%esp
  8006d5:	6a 00                	push   $0x0
  8006d7:	e8 d8 17 00 00       	call   801eb4 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006dc:	83 c4 08             	add    $0x8,%esp
  8006df:	6a 00                	push   $0x0
  8006e1:	ff 76 04             	pushl  0x4(%esi)
  8006e4:	e8 52 1b 00 00       	call   80223b <open>
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	79 1b                	jns    80070b <umain+0xb8>
			panic("open %s: %e", argv[1], r);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	50                   	push   %eax
  8006f4:	ff 76 04             	pushl  0x4(%esi)
  8006f7:	68 b5 33 80 00       	push   $0x8033b5
  8006fc:	68 29 01 00 00       	push   $0x129
  800701:	68 38 33 80 00       	push   $0x803338
  800706:	e8 05 03 00 00       	call   800a10 <_panic>
		assert(r == 0);
  80070b:	85 c0                	test   %eax,%eax
  80070d:	74 19                	je     800728 <umain+0xd5>
  80070f:	68 c1 33 80 00       	push   $0x8033c1
  800714:	68 c8 33 80 00       	push   $0x8033c8
  800719:	68 2a 01 00 00       	push   $0x12a
  80071e:	68 38 33 80 00       	push   $0x803338
  800723:	e8 e8 02 00 00       	call   800a10 <_panic>
	}
	if (interactive == '?')
  800728:	83 fb 3f             	cmp    $0x3f,%ebx
  80072b:	75 0f                	jne    80073c <umain+0xe9>
		interactive = iscons(0);
  80072d:	83 ec 0c             	sub    $0xc,%esp
  800730:	6a 00                	push   $0x0
  800732:	e8 1c 02 00 00       	call   800953 <iscons>
  800737:	89 c7                	mov    %eax,%edi
  800739:	83 c4 10             	add    $0x10,%esp

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80073c:	85 ff                	test   %edi,%edi
  80073e:	74 07                	je     800747 <umain+0xf4>
  800740:	b8 dd 33 80 00       	mov    $0x8033dd,%eax
  800745:	eb 05                	jmp    80074c <umain+0xf9>
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	e8 7b 08 00 00       	call   800fd0 <readline>
  800755:	89 c6                	mov    %eax,%esi
		if (buf == NULL) {
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	85 c0                	test   %eax,%eax
  80075c:	75 1e                	jne    80077c <umain+0x129>
			if (debug)
  80075e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800765:	74 10                	je     800777 <umain+0x124>
				cprintf("EXITING\n");
  800767:	83 ec 0c             	sub    $0xc,%esp
  80076a:	68 e0 33 80 00       	push   $0x8033e0
  80076f:	e8 3d 03 00 00       	call   800ab1 <cprintf>
  800774:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800777:	e8 80 02 00 00       	call   8009fc <exit>
		}
		if (debug)
  80077c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800783:	74 11                	je     800796 <umain+0x143>
			cprintf("LINE: %s\n", buf);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	56                   	push   %esi
  800789:	68 e9 33 80 00       	push   $0x8033e9
  80078e:	e8 1e 03 00 00       	call   800ab1 <cprintf>
  800793:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800796:	80 3e 23             	cmpb   $0x23,(%esi)
  800799:	74 a1                	je     80073c <umain+0xe9>
			continue;
		if (echocmds)
  80079b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079f:	74 11                	je     8007b2 <umain+0x15f>
			printf("# %s\n", buf);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	56                   	push   %esi
  8007a5:	68 f3 33 80 00       	push   $0x8033f3
  8007aa:	e8 cd 1b 00 00       	call   80237c <printf>
  8007af:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b9:	74 10                	je     8007cb <umain+0x178>
			cprintf("BEFORE FORK\n");
  8007bb:	83 ec 0c             	sub    $0xc,%esp
  8007be:	68 f9 33 80 00       	push   $0x8033f9
  8007c3:	e8 e9 02 00 00       	call   800ab1 <cprintf>
  8007c8:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cb:	e8 0a 0f 00 00       	call   8016da <fork>
  8007d0:	89 c3                	mov    %eax,%ebx
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	79 15                	jns    8007eb <umain+0x198>
			panic("fork: %e", r);
  8007d6:	50                   	push   %eax
  8007d7:	68 13 33 80 00       	push   $0x803313
  8007dc:	68 41 01 00 00       	push   $0x141
  8007e1:	68 38 33 80 00       	push   $0x803338
  8007e6:	e8 25 02 00 00       	call   800a10 <_panic>
		if (debug)
  8007eb:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f2:	74 11                	je     800805 <umain+0x1b2>
			cprintf("FORK: %d\n", r);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	50                   	push   %eax
  8007f8:	68 06 34 80 00       	push   $0x803406
  8007fd:	e8 af 02 00 00       	call   800ab1 <cprintf>
  800802:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800805:	85 db                	test   %ebx,%ebx
  800807:	75 16                	jne    80081f <umain+0x1cc>
			runcmd(buf);
  800809:	83 ec 0c             	sub    $0xc,%esp
  80080c:	56                   	push   %esi
  80080d:	e8 03 fa ff ff       	call   800215 <runcmd>
			exit();
  800812:	e8 e5 01 00 00       	call   8009fc <exit>
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	e9 1d ff ff ff       	jmp    80073c <umain+0xe9>
		} else
			wait(r);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	53                   	push   %ebx
  800823:	e8 d8 24 00 00       	call   802d00 <wait>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	e9 0c ff ff ff       	jmp    80073c <umain+0xe9>

00800830 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800840:	68 10 34 80 00       	push   $0x803410
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	e8 9a 08 00 00       	call   8010e7 <strcpy>
	return 0;
}
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	57                   	push   %edi
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800860:	be 00 00 00 00       	mov    $0x0,%esi
  800865:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  80086b:	eb 2c                	jmp    800899 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80086d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800870:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800872:	83 fb 7f             	cmp    $0x7f,%ebx
  800875:	76 05                	jbe    80087c <devcons_write+0x28>
  800877:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80087c:	83 ec 04             	sub    $0x4,%esp
  80087f:	53                   	push   %ebx
  800880:	03 45 0c             	add    0xc(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	57                   	push   %edi
  800885:	e8 ca 09 00 00       	call   801254 <memmove>
		sys_cputs(buf, m);
  80088a:	83 c4 08             	add    $0x8,%esp
  80088d:	53                   	push   %ebx
  80088e:	57                   	push   %edi
  80088f:	e8 97 0b 00 00       	call   80142b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800894:	01 de                	add    %ebx,%esi
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	89 f0                	mov    %esi,%eax
  80089b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80089e:	72 cd                	jb     80086d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008b4:	6a 01                	push   $0x1
  8008b6:	8d 45 ff             	lea    -0x1(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	e8 6c 0b 00 00       	call   80142b <sys_cputs>
  8008bf:	83 c4 10             	add    $0x10,%esp
}
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    

008008c4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008ce:	74 27                	je     8008f7 <devcons_read+0x33>
  8008d0:	eb 05                	jmp    8008d7 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008d2:	e8 69 0d 00 00       	call   801640 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008d7:	e8 30 0b 00 00       	call   80140c <sys_cgetc>
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	74 f0                	je     8008d2 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	78 16                	js     8008fc <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008e6:	83 f8 04             	cmp    $0x4,%eax
  8008e9:	74 0c                	je     8008f7 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	88 10                	mov    %dl,(%eax)
  8008f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8008f5:	eb 05                	jmp    8008fc <devcons_read+0x38>
	return 1;
  8008f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800906:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800909:	50                   	push   %eax
  80090a:	e8 bd 11 00 00       	call   801acc <fd_alloc>
  80090f:	83 c4 10             	add    $0x10,%esp
  800912:	85 c0                	test   %eax,%eax
  800914:	78 3b                	js     800951 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800916:	83 ec 04             	sub    $0x4,%esp
  800919:	68 07 04 00 00       	push   $0x407
  80091e:	ff 75 fc             	pushl  -0x4(%ebp)
  800921:	6a 00                	push   $0x0
  800923:	e8 d5 0c 00 00       	call   8015fd <sys_page_alloc>
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	85 c0                	test   %eax,%eax
  80092d:	78 22                	js     800951 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80092f:	a1 00 40 80 00       	mov    0x804000,%eax
  800934:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800937:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  800939:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80093c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800943:	83 ec 0c             	sub    $0xc,%esp
  800946:	ff 75 fc             	pushl  -0x4(%ebp)
  800949:	e8 56 11 00 00       	call   801aa4 <fd2num>
  80094e:	83 c4 10             	add    $0x10,%esp
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800959:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80095c:	50                   	push   %eax
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 ba 11 00 00       	call   801b1f <fd_lookup>
  800965:	83 c4 10             	add    $0x10,%esp
  800968:	85 c0                	test   %eax,%eax
  80096a:	78 11                	js     80097d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80096c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80096f:	8b 00                	mov    (%eax),%eax
  800971:	3b 05 00 40 80 00    	cmp    0x804000,%eax
  800977:	0f 94 c0             	sete   %al
  80097a:	0f b6 c0             	movzbl %al,%eax
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800985:	6a 01                	push   $0x1
  800987:	8d 45 ff             	lea    -0x1(%ebp),%eax
  80098a:	50                   	push   %eax
  80098b:	6a 00                	push   $0x0
  80098d:	e8 cc 13 00 00       	call   801d5e <read>
	if (r < 0)
  800992:	83 c4 10             	add    $0x10,%esp
  800995:	85 c0                	test   %eax,%eax
  800997:	78 0f                	js     8009a8 <getchar+0x29>
		return r;
	if (r < 1)
  800999:	85 c0                	test   %eax,%eax
  80099b:	75 07                	jne    8009a4 <getchar+0x25>
  80099d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8009a2:	eb 04                	jmp    8009a8 <getchar+0x29>
		return -E_EOF;
	return c;
  8009a4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    
	...

008009ac <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8009b7:	e8 a3 0c 00 00       	call   80165f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8009bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009c8:	c1 e0 07             	shl    $0x7,%eax
  8009cb:	29 d0                	sub    %edx,%eax
  8009cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d7:	85 f6                	test   %esi,%esi
  8009d9:	7e 07                	jle    8009e2 <libmain+0x36>
		binaryname = argv[0];
  8009db:	8b 03                	mov    (%ebx),%eax
  8009dd:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	53                   	push   %ebx
  8009e6:	56                   	push   %esi
  8009e7:	e8 67 fc ff ff       	call   800653 <umain>

	// exit gracefully
	exit();
  8009ec:	e8 0b 00 00 00       	call   8009fc <exit>
  8009f1:	83 c4 10             	add    $0x10,%esp
}
  8009f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    
	...

008009fc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800a02:	6a 00                	push   $0x0
  800a04:	e8 75 0c 00 00       	call   80167e <sys_env_destroy>
  800a09:	83 c4 10             	add    $0x10,%esp
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    
	...

00800a10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800a17:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1d:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  800a23:	e8 37 0c 00 00       	call   80165f <sys_getenvid>
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	ff 75 08             	pushl  0x8(%ebp)
  800a31:	53                   	push   %ebx
  800a32:	50                   	push   %eax
  800a33:	68 28 34 80 00       	push   $0x803428
  800a38:	e8 74 00 00 00       	call   800ab1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	ff 75 f8             	pushl  -0x8(%ebp)
  800a43:	ff 75 10             	pushl  0x10(%ebp)
  800a46:	e8 15 00 00 00       	call   800a60 <vcprintf>
	cprintf("\n");
  800a4b:	c7 04 24 92 32 80 00 	movl   $0x803292,(%esp)
  800a52:	e8 5a 00 00 00       	call   800ab1 <cprintf>
  800a57:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a5a:	cc                   	int3   
  800a5b:	eb fd                	jmp    800a5a <_panic+0x4a>
  800a5d:	00 00                	add    %al,(%eax)
	...

00800a60 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800a69:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800a70:	00 00 00 
	b.cnt = 0;
  800a73:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800a7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	ff 75 08             	pushl  0x8(%ebp)
  800a83:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 c8 0a 80 00       	push   $0x800ac8
  800a8f:	e8 70 01 00 00       	call   800c04 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800a9d:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 82 09 00 00       	call   80142b <sys_cputs>
  800aa9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ab7:	8d 45 0c             	lea    0xc(%ebp),%eax
  800aba:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800abd:	50                   	push   %eax
  800abe:	ff 75 08             	pushl  0x8(%ebp)
  800ac1:	e8 9a ff ff ff       	call   800a60 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	53                   	push   %ebx
  800acc:	83 ec 04             	sub    $0x4,%esp
  800acf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800ad2:	8b 03                	mov    (%ebx),%eax
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800adb:	40                   	inc    %eax
  800adc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800ade:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ae3:	75 1a                	jne    800aff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	68 ff 00 00 00       	push   $0xff
  800aed:	8d 43 08             	lea    0x8(%ebx),%eax
  800af0:	50                   	push   %eax
  800af1:	e8 35 09 00 00       	call   80142b <sys_cputs>
		b->idx = 0;
  800af6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800afc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800aff:	ff 43 04             	incl   0x4(%ebx)
}
  800b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    
	...

00800b08 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 1c             	sub    $0x1c,%esp
  800b11:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b14:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b23:	8b 55 10             	mov    0x10(%ebp),%edx
  800b26:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b30:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800b33:	72 04                	jb     800b39 <printnum+0x31>
  800b35:	39 c2                	cmp    %eax,%edx
  800b37:	77 3f                	ja     800b78 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	ff 75 18             	pushl  0x18(%ebp)
  800b3f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800b42:	50                   	push   %eax
  800b43:	52                   	push   %edx
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4c:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4f:	e8 f0 23 00 00       	call   802f44 <__udivdi3>
  800b54:	83 c4 18             	add    $0x18,%esp
  800b57:	52                   	push   %edx
  800b58:	50                   	push   %eax
  800b59:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5f:	e8 a4 ff ff ff       	call   800b08 <printnum>
  800b64:	83 c4 20             	add    $0x20,%esp
  800b67:	eb 14                	jmp    800b7d <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b69:	83 ec 08             	sub    $0x8,%esp
  800b6c:	ff 75 e8             	pushl  -0x18(%ebp)
  800b6f:	ff 75 18             	pushl  0x18(%ebp)
  800b72:	ff 55 ec             	call   *-0x14(%ebp)
  800b75:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b78:	4b                   	dec    %ebx
  800b79:	85 db                	test   %ebx,%ebx
  800b7b:	7f ec                	jg     800b69 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	ff 75 e8             	pushl  -0x18(%ebp)
  800b83:	83 ec 04             	sub    $0x4,%esp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8e:	e8 dd 24 00 00       	call   803070 <__umoddi3>
  800b93:	83 c4 14             	add    $0x14,%esp
  800b96:	0f be 80 4b 34 80 00 	movsbl 0x80344b(%eax),%eax
  800b9d:	50                   	push   %eax
  800b9e:	ff 55 ec             	call   *-0x14(%ebp)
  800ba1:	83 c4 10             	add    $0x10,%esp
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800bb1:	83 fa 01             	cmp    $0x1,%edx
  800bb4:	7e 0e                	jle    800bc4 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800bb6:	8b 10                	mov    (%eax),%edx
  800bb8:	8d 42 08             	lea    0x8(%edx),%eax
  800bbb:	89 01                	mov    %eax,(%ecx)
  800bbd:	8b 02                	mov    (%edx),%eax
  800bbf:	8b 52 04             	mov    0x4(%edx),%edx
  800bc2:	eb 22                	jmp    800be6 <getuint+0x3a>
	else if (lflag)
  800bc4:	85 d2                	test   %edx,%edx
  800bc6:	74 10                	je     800bd8 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800bc8:	8b 10                	mov    (%eax),%edx
  800bca:	8d 42 04             	lea    0x4(%edx),%eax
  800bcd:	89 01                	mov    %eax,(%ecx)
  800bcf:	8b 02                	mov    (%edx),%eax
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	eb 0e                	jmp    800be6 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800bd8:	8b 10                	mov    (%eax),%edx
  800bda:	8d 42 04             	lea    0x4(%edx),%eax
  800bdd:	89 01                	mov    %eax,(%ecx)
  800bdf:	8b 02                	mov    (%edx),%eax
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800bee:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800bf1:	8b 11                	mov    (%ecx),%edx
  800bf3:	3b 51 04             	cmp    0x4(%ecx),%edx
  800bf6:	73 0a                	jae    800c02 <sprintputch+0x1a>
		*b->buf++ = ch;
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	88 02                	mov    %al,(%edx)
  800bfd:	8d 42 01             	lea    0x1(%edx),%eax
  800c00:	89 01                	mov    %eax,(%ecx)
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 3c             	sub    $0x3c,%esp
  800c0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c10:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c16:	eb 1a                	jmp    800c32 <vprintfmt+0x2e>
  800c18:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800c1b:	eb 15                	jmp    800c32 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c1d:	84 c0                	test   %al,%al
  800c1f:	0f 84 15 03 00 00    	je     800f3a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800c25:	83 ec 08             	sub    $0x8,%esp
  800c28:	57                   	push   %edi
  800c29:	0f b6 c0             	movzbl %al,%eax
  800c2c:	50                   	push   %eax
  800c2d:	ff d6                	call   *%esi
  800c2f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c32:	8a 03                	mov    (%ebx),%al
  800c34:	43                   	inc    %ebx
  800c35:	3c 25                	cmp    $0x25,%al
  800c37:	75 e4                	jne    800c1d <vprintfmt+0x19>
  800c39:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800c40:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800c47:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800c4e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800c55:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800c59:	eb 0a                	jmp    800c65 <vprintfmt+0x61>
  800c5b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  800c62:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800c65:	8a 03                	mov    (%ebx),%al
  800c67:	0f b6 d0             	movzbl %al,%edx
  800c6a:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800c6d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800c70:	83 e8 23             	sub    $0x23,%eax
  800c73:	3c 55                	cmp    $0x55,%al
  800c75:	0f 87 9c 02 00 00    	ja     800f17 <vprintfmt+0x313>
  800c7b:	0f b6 c0             	movzbl %al,%eax
  800c7e:	ff 24 85 80 35 80 00 	jmp    *0x803580(,%eax,4)
  800c85:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800c89:	eb d7                	jmp    800c62 <vprintfmt+0x5e>
  800c8b:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800c8f:	eb d1                	jmp    800c62 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800c91:	89 d9                	mov    %ebx,%ecx
  800c93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c9a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800c9d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800ca0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800ca4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800ca7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800cab:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800cac:	8d 42 d0             	lea    -0x30(%edx),%eax
  800caf:	83 f8 09             	cmp    $0x9,%eax
  800cb2:	77 21                	ja     800cd5 <vprintfmt+0xd1>
  800cb4:	eb e4                	jmp    800c9a <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cb6:	8b 55 14             	mov    0x14(%ebp),%edx
  800cb9:	8d 42 04             	lea    0x4(%edx),%eax
  800cbc:	89 45 14             	mov    %eax,0x14(%ebp)
  800cbf:	8b 12                	mov    (%edx),%edx
  800cc1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800cc4:	eb 12                	jmp    800cd8 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800cc6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800cca:	79 96                	jns    800c62 <vprintfmt+0x5e>
  800ccc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800cd3:	eb 8d                	jmp    800c62 <vprintfmt+0x5e>
  800cd5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800cd8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800cdc:	79 84                	jns    800c62 <vprintfmt+0x5e>
  800cde:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ce1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ce4:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800ceb:	e9 72 ff ff ff       	jmp    800c62 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800cf0:	ff 45 d4             	incl   -0x2c(%ebp)
  800cf3:	e9 6a ff ff ff       	jmp    800c62 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cf8:	8b 55 14             	mov    0x14(%ebp),%edx
  800cfb:	8d 42 04             	lea    0x4(%edx),%eax
  800cfe:	89 45 14             	mov    %eax,0x14(%ebp)
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	57                   	push   %edi
  800d05:	ff 32                	pushl  (%edx)
  800d07:	ff d6                	call   *%esi
			break;
  800d09:	83 c4 10             	add    $0x10,%esp
  800d0c:	e9 07 ff ff ff       	jmp    800c18 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d11:	8b 55 14             	mov    0x14(%ebp),%edx
  800d14:	8d 42 04             	lea    0x4(%edx),%eax
  800d17:	89 45 14             	mov    %eax,0x14(%ebp)
  800d1a:	8b 02                	mov    (%edx),%eax
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	79 02                	jns    800d22 <vprintfmt+0x11e>
  800d20:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d22:	83 f8 0f             	cmp    $0xf,%eax
  800d25:	7f 0b                	jg     800d32 <vprintfmt+0x12e>
  800d27:	8b 14 85 e0 36 80 00 	mov    0x8036e0(,%eax,4),%edx
  800d2e:	85 d2                	test   %edx,%edx
  800d30:	75 15                	jne    800d47 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800d32:	50                   	push   %eax
  800d33:	68 5c 34 80 00       	push   $0x80345c
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	e8 6e 02 00 00       	call   800fad <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	e9 d1 fe ff ff       	jmp    800c18 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800d47:	52                   	push   %edx
  800d48:	68 da 33 80 00       	push   $0x8033da
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	e8 59 02 00 00       	call   800fad <printfmt>
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	e9 bc fe ff ff       	jmp    800c18 <vprintfmt+0x14>
  800d5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d5f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d62:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d65:	8b 55 14             	mov    0x14(%ebp),%edx
  800d68:	8d 42 04             	lea    0x4(%edx),%eax
  800d6b:	89 45 14             	mov    %eax,0x14(%ebp)
  800d6e:	8b 1a                	mov    (%edx),%ebx
  800d70:	85 db                	test   %ebx,%ebx
  800d72:	75 05                	jne    800d79 <vprintfmt+0x175>
  800d74:	bb 65 34 80 00       	mov    $0x803465,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800d79:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800d7d:	7e 66                	jle    800de5 <vprintfmt+0x1e1>
  800d7f:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  800d83:	74 60                	je     800de5 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d85:	83 ec 08             	sub    $0x8,%esp
  800d88:	51                   	push   %ecx
  800d89:	53                   	push   %ebx
  800d8a:	e8 3b 03 00 00       	call   8010ca <strnlen>
  800d8f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800d92:	29 c1                	sub    %eax,%ecx
  800d94:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800d9e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800da1:	eb 0f                	jmp    800db2 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	57                   	push   %edi
  800da7:	ff 75 c4             	pushl  -0x3c(%ebp)
  800daa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800dac:	ff 4d d8             	decl   -0x28(%ebp)
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800db6:	7f eb                	jg     800da3 <vprintfmt+0x19f>
  800db8:	eb 2b                	jmp    800de5 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dba:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800dbd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dc1:	74 15                	je     800dd8 <vprintfmt+0x1d4>
  800dc3:	8d 42 e0             	lea    -0x20(%edx),%eax
  800dc6:	83 f8 5e             	cmp    $0x5e,%eax
  800dc9:	76 0d                	jbe    800dd8 <vprintfmt+0x1d4>
					putch('?', putdat);
  800dcb:	83 ec 08             	sub    $0x8,%esp
  800dce:	57                   	push   %edi
  800dcf:	6a 3f                	push   $0x3f
  800dd1:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	eb 0a                	jmp    800de2 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	57                   	push   %edi
  800ddc:	52                   	push   %edx
  800ddd:	ff d6                	call   *%esi
  800ddf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800de2:	ff 4d d8             	decl   -0x28(%ebp)
  800de5:	8a 03                	mov    (%ebx),%al
  800de7:	43                   	inc    %ebx
  800de8:	84 c0                	test   %al,%al
  800dea:	74 1b                	je     800e07 <vprintfmt+0x203>
  800dec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800df0:	78 c8                	js     800dba <vprintfmt+0x1b6>
  800df2:	ff 4d dc             	decl   -0x24(%ebp)
  800df5:	79 c3                	jns    800dba <vprintfmt+0x1b6>
  800df7:	eb 0e                	jmp    800e07 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800df9:	83 ec 08             	sub    $0x8,%esp
  800dfc:	57                   	push   %edi
  800dfd:	6a 20                	push   $0x20
  800dff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e01:	ff 4d d8             	decl   -0x28(%ebp)
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e0b:	7f ec                	jg     800df9 <vprintfmt+0x1f5>
  800e0d:	e9 06 fe ff ff       	jmp    800c18 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e12:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800e16:	7e 10                	jle    800e28 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800e18:	8b 55 14             	mov    0x14(%ebp),%edx
  800e1b:	8d 42 08             	lea    0x8(%edx),%eax
  800e1e:	89 45 14             	mov    %eax,0x14(%ebp)
  800e21:	8b 02                	mov    (%edx),%eax
  800e23:	8b 52 04             	mov    0x4(%edx),%edx
  800e26:	eb 20                	jmp    800e48 <vprintfmt+0x244>
	else if (lflag)
  800e28:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e2c:	74 0e                	je     800e3c <vprintfmt+0x238>
		return va_arg(*ap, long);
  800e2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e31:	8d 50 04             	lea    0x4(%eax),%edx
  800e34:	89 55 14             	mov    %edx,0x14(%ebp)
  800e37:	8b 00                	mov    (%eax),%eax
  800e39:	99                   	cltd   
  800e3a:	eb 0c                	jmp    800e48 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800e3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e3f:	8d 50 04             	lea    0x4(%eax),%edx
  800e42:	89 55 14             	mov    %edx,0x14(%ebp)
  800e45:	8b 00                	mov    (%eax),%eax
  800e47:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800e48:	89 d1                	mov    %edx,%ecx
  800e4a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800e4c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800e4f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800e52:	85 c9                	test   %ecx,%ecx
  800e54:	78 0a                	js     800e60 <vprintfmt+0x25c>
  800e56:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e5b:	e9 89 00 00 00       	jmp    800ee9 <vprintfmt+0x2e5>
				putch('-', putdat);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	57                   	push   %edi
  800e64:	6a 2d                	push   $0x2d
  800e66:	ff d6                	call   *%esi
				num = -(long long) num;
  800e68:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800e6b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e6e:	f7 da                	neg    %edx
  800e70:	83 d1 00             	adc    $0x0,%ecx
  800e73:	f7 d9                	neg    %ecx
  800e75:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	eb 6a                	jmp    800ee9 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800e82:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e85:	e8 22 fd ff ff       	call   800bac <getuint>
  800e8a:	89 d1                	mov    %edx,%ecx
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e93:	eb 54                	jmp    800ee9 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800e95:	8d 45 14             	lea    0x14(%ebp),%eax
  800e98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e9b:	e8 0c fd ff ff       	call   800bac <getuint>
  800ea0:	89 d1                	mov    %edx,%ecx
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ea9:	eb 3e                	jmp    800ee9 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	57                   	push   %edi
  800eaf:	6a 30                	push   $0x30
  800eb1:	ff d6                	call   *%esi
			putch('x', putdat);
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	57                   	push   %edi
  800eb7:	6a 78                	push   $0x78
  800eb9:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ebb:	8b 55 14             	mov    0x14(%ebp),%edx
  800ebe:	8d 42 04             	lea    0x4(%edx),%eax
  800ec1:	89 45 14             	mov    %eax,0x14(%ebp)
  800ec4:	8b 12                	mov    (%edx),%edx
  800ec6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecb:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	eb 14                	jmp    800ee9 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ed5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ed8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800edb:	e8 cc fc ff ff       	call   800bac <getuint>
  800ee0:	89 d1                	mov    %edx,%ecx
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800ef0:	50                   	push   %eax
  800ef1:	ff 75 d8             	pushl  -0x28(%ebp)
  800ef4:	53                   	push   %ebx
  800ef5:	51                   	push   %ecx
  800ef6:	52                   	push   %edx
  800ef7:	89 fa                	mov    %edi,%edx
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	e8 08 fc ff ff       	call   800b08 <printnum>
			break;
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	e9 10 fd ff ff       	jmp    800c18 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	57                   	push   %edi
  800f0c:	52                   	push   %edx
  800f0d:	ff d6                	call   *%esi
			break;
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	e9 01 fd ff ff       	jmp    800c18 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f17:	83 ec 08             	sub    $0x8,%esp
  800f1a:	57                   	push   %edi
  800f1b:	6a 25                	push   $0x25
  800f1d:	ff d6                	call   *%esi
  800f1f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f22:	83 ea 02             	sub    $0x2,%edx
  800f25:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f28:	8a 02                	mov    (%edx),%al
  800f2a:	4a                   	dec    %edx
  800f2b:	3c 25                	cmp    $0x25,%al
  800f2d:	75 f9                	jne    800f28 <vprintfmt+0x324>
  800f2f:	83 c2 02             	add    $0x2,%edx
  800f32:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f35:	e9 de fc ff ff       	jmp    800c18 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 18             	sub    $0x18,%esp
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800f4e:	85 d2                	test   %edx,%edx
  800f50:	74 37                	je     800f89 <vsnprintf+0x47>
  800f52:	85 c0                	test   %eax,%eax
  800f54:	7e 33                	jle    800f89 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f56:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800f5d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800f61:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800f64:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f67:	ff 75 14             	pushl  0x14(%ebp)
  800f6a:	ff 75 10             	pushl  0x10(%ebp)
  800f6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f70:	50                   	push   %eax
  800f71:	68 e8 0b 80 00       	push   $0x800be8
  800f76:	e8 89 fc ff ff       	call   800c04 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	eb 05                	jmp    800f8e <vsnprintf+0x4c>
  800f89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f96:	8d 45 14             	lea    0x14(%ebp),%eax
  800f99:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800f9c:	50                   	push   %eax
  800f9d:	ff 75 10             	pushl  0x10(%ebp)
  800fa0:	ff 75 0c             	pushl  0xc(%ebp)
  800fa3:	ff 75 08             	pushl  0x8(%ebp)
  800fa6:	e8 97 ff ff ff       	call   800f42 <vsnprintf>
	va_end(ap);

	return rc;
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800fb3:	8d 45 14             	lea    0x14(%ebp),%eax
  800fb6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800fb9:	50                   	push   %eax
  800fba:	ff 75 10             	pushl  0x10(%ebp)
  800fbd:	ff 75 0c             	pushl  0xc(%ebp)
  800fc0:	ff 75 08             	pushl  0x8(%ebp)
  800fc3:	e8 3c fc ff ff       	call   800c04 <vprintfmt>
	va_end(ap);
  800fc8:	83 c4 10             	add    $0x10,%esp
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    
  800fcd:	00 00                	add    %al,(%eax)
	...

00800fd0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	74 13                	je     800ff3 <readline+0x23>
		fprintf(1, "%s", prompt);
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	50                   	push   %eax
  800fe4:	68 da 33 80 00       	push   $0x8033da
  800fe9:	6a 01                	push   $0x1
  800feb:	e8 a5 13 00 00       	call   802395 <fprintf>
  800ff0:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	6a 00                	push   $0x0
  800ff8:	e8 56 f9 ff ff       	call   800953 <iscons>
  800ffd:	89 c7                	mov    %eax,%edi
  800fff:	be 00 00 00 00       	mov    $0x0,%esi
  801004:	83 c4 10             	add    $0x10,%esp
	while (1) {
		c = getchar();
  801007:	e8 73 f9 ff ff       	call   80097f <getchar>
  80100c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80100e:	85 c0                	test   %eax,%eax
  801010:	79 27                	jns    801039 <readline+0x69>
			if (c != -E_EOF)
  801012:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801015:	75 0a                	jne    801021 <readline+0x51>
  801017:	b8 00 00 00 00       	mov    $0x0,%eax
  80101c:	e9 8b 00 00 00       	jmp    8010ac <readline+0xdc>
				cprintf("read error: %e\n", c);
  801021:	83 ec 08             	sub    $0x8,%esp
  801024:	50                   	push   %eax
  801025:	68 3f 37 80 00       	push   $0x80373f
  80102a:	e8 82 fa ff ff       	call   800ab1 <cprintf>
  80102f:	b8 00 00 00 00       	mov    $0x0,%eax
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	eb 73                	jmp    8010ac <readline+0xdc>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801039:	83 f8 08             	cmp    $0x8,%eax
  80103c:	74 05                	je     801043 <readline+0x73>
  80103e:	83 f8 7f             	cmp    $0x7f,%eax
  801041:	75 18                	jne    80105b <readline+0x8b>
  801043:	85 f6                	test   %esi,%esi
  801045:	7e 14                	jle    80105b <readline+0x8b>
			if (echoing)
  801047:	85 ff                	test   %edi,%edi
  801049:	74 0d                	je     801058 <readline+0x88>
				cputchar('\b');
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	6a 08                	push   $0x8
  801050:	e8 53 f8 ff ff       	call   8008a8 <cputchar>
  801055:	83 c4 10             	add    $0x10,%esp
			i--;
  801058:	4e                   	dec    %esi
  801059:	eb ac                	jmp    801007 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80105b:	83 fb 1f             	cmp    $0x1f,%ebx
  80105e:	7e 21                	jle    801081 <readline+0xb1>
  801060:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801066:	7f 9f                	jg     801007 <readline+0x37>
			if (echoing)
  801068:	85 ff                	test   %edi,%edi
  80106a:	74 0c                	je     801078 <readline+0xa8>
				cputchar(c);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	53                   	push   %ebx
  801070:	e8 33 f8 ff ff       	call   8008a8 <cputchar>
  801075:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801078:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  80107e:	46                   	inc    %esi
  80107f:	eb 86                	jmp    801007 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801081:	83 fb 0a             	cmp    $0xa,%ebx
  801084:	74 09                	je     80108f <readline+0xbf>
  801086:	83 fb 0d             	cmp    $0xd,%ebx
  801089:	0f 85 78 ff ff ff    	jne    801007 <readline+0x37>
			if (echoing)
  80108f:	85 ff                	test   %edi,%edi
  801091:	74 0d                	je     8010a0 <readline+0xd0>
				cputchar('\n');
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	6a 0a                	push   $0xa
  801098:	e8 0b f8 ff ff       	call   8008a8 <cputchar>
  80109d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8010a0:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
  8010a7:	b8 20 50 80 00       	mov    $0x805020,%eax
			return buf;
		}
	}
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bf:	eb 01                	jmp    8010c2 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8010c1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8010c2:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8010c6:	75 f9                	jne    8010c1 <strlen+0xd>
		n++;
	return n;
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d8:	eb 01                	jmp    8010db <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8010da:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8010db:	39 d0                	cmp    %edx,%eax
  8010dd:	74 06                	je     8010e5 <strnlen+0x1b>
  8010df:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8010e3:	75 f5                	jne    8010da <strnlen+0x10>
		n++;
	return n;
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8010f0:	8a 01                	mov    (%ecx),%al
  8010f2:	88 02                	mov    %al,(%edx)
  8010f4:	42                   	inc    %edx
  8010f5:	41                   	inc    %ecx
  8010f6:	84 c0                	test   %al,%al
  8010f8:	75 f6                	jne    8010f0 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	53                   	push   %ebx
  801103:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801106:	53                   	push   %ebx
  801107:	e8 a8 ff ff ff       	call   8010b4 <strlen>
	strcpy(dst + len, src);
  80110c:	ff 75 0c             	pushl  0xc(%ebp)
  80110f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801112:	50                   	push   %eax
  801113:	e8 cf ff ff ff       	call   8010e7 <strcpy>
	return dst;
}
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	8b 75 08             	mov    0x8(%ebp),%esi
  801127:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80112d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801132:	eb 0c                	jmp    801140 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  801134:	8a 02                	mov    (%edx),%al
  801136:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801139:	80 3a 01             	cmpb   $0x1,(%edx)
  80113c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80113f:	41                   	inc    %ecx
  801140:	39 d9                	cmp    %ebx,%ecx
  801142:	75 f0                	jne    801134 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801144:	89 f0                	mov    %esi,%eax
  801146:	5b                   	pop    %ebx
  801147:	5e                   	pop    %esi
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	8b 75 08             	mov    0x8(%ebp),%esi
  801152:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801155:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801158:	85 c9                	test   %ecx,%ecx
  80115a:	75 04                	jne    801160 <strlcpy+0x16>
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	eb 14                	jmp    801174 <strlcpy+0x2a>
  801160:	89 f0                	mov    %esi,%eax
  801162:	eb 04                	jmp    801168 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801164:	88 10                	mov    %dl,(%eax)
  801166:	40                   	inc    %eax
  801167:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801168:	49                   	dec    %ecx
  801169:	74 06                	je     801171 <strlcpy+0x27>
  80116b:	8a 13                	mov    (%ebx),%dl
  80116d:	84 d2                	test   %dl,%dl
  80116f:	75 f3                	jne    801164 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  801171:	c6 00 00             	movb   $0x0,(%eax)
  801174:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	eb 02                	jmp    801187 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  801185:	42                   	inc    %edx
  801186:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801187:	8a 02                	mov    (%edx),%al
  801189:	84 c0                	test   %al,%al
  80118b:	74 04                	je     801191 <strcmp+0x17>
  80118d:	3a 01                	cmp    (%ecx),%al
  80118f:	74 f4                	je     801185 <strcmp+0xb>
  801191:	0f b6 c0             	movzbl %al,%eax
  801194:	0f b6 11             	movzbl (%ecx),%edx
  801197:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	53                   	push   %ebx
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011a5:	8b 55 10             	mov    0x10(%ebp),%edx
  8011a8:	eb 03                	jmp    8011ad <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8011aa:	4a                   	dec    %edx
  8011ab:	41                   	inc    %ecx
  8011ac:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8011ad:	85 d2                	test   %edx,%edx
  8011af:	75 07                	jne    8011b8 <strncmp+0x1d>
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 14                	jmp    8011cc <strncmp+0x31>
  8011b8:	8a 01                	mov    (%ecx),%al
  8011ba:	84 c0                	test   %al,%al
  8011bc:	74 04                	je     8011c2 <strncmp+0x27>
  8011be:	3a 03                	cmp    (%ebx),%al
  8011c0:	74 e8                	je     8011aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011c2:	0f b6 d0             	movzbl %al,%edx
  8011c5:	0f b6 03             	movzbl (%ebx),%eax
  8011c8:	29 c2                	sub    %eax,%edx
  8011ca:	89 d0                	mov    %edx,%eax
}
  8011cc:	5b                   	pop    %ebx
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8011d8:	eb 05                	jmp    8011df <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  8011da:	38 ca                	cmp    %cl,%dl
  8011dc:	74 0c                	je     8011ea <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8011de:	40                   	inc    %eax
  8011df:	8a 10                	mov    (%eax),%dl
  8011e1:	84 d2                	test   %dl,%dl
  8011e3:	75 f5                	jne    8011da <strchr+0xb>
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8011f5:	eb 05                	jmp    8011fc <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  8011f7:	38 ca                	cmp    %cl,%dl
  8011f9:	74 07                	je     801202 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8011fb:	40                   	inc    %eax
  8011fc:	8a 10                	mov    (%eax),%dl
  8011fe:	84 d2                	test   %dl,%dl
  801200:	75 f5                	jne    8011f7 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801210:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  801213:	85 db                	test   %ebx,%ebx
  801215:	74 36                	je     80124d <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801217:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80121d:	75 29                	jne    801248 <memset+0x44>
  80121f:	f6 c3 03             	test   $0x3,%bl
  801222:	75 24                	jne    801248 <memset+0x44>
		c &= 0xFF;
  801224:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801227:	89 d6                	mov    %edx,%esi
  801229:	c1 e6 08             	shl    $0x8,%esi
  80122c:	89 d0                	mov    %edx,%eax
  80122e:	c1 e0 18             	shl    $0x18,%eax
  801231:	89 d1                	mov    %edx,%ecx
  801233:	c1 e1 10             	shl    $0x10,%ecx
  801236:	09 c8                	or     %ecx,%eax
  801238:	09 c2                	or     %eax,%edx
  80123a:	89 f0                	mov    %esi,%eax
  80123c:	09 d0                	or     %edx,%eax
  80123e:	89 d9                	mov    %ebx,%ecx
  801240:	c1 e9 02             	shr    $0x2,%ecx
  801243:	fc                   	cld    
  801244:	f3 ab                	rep stos %eax,%es:(%edi)
  801246:	eb 05                	jmp    80124d <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801248:	89 d9                	mov    %ebx,%ecx
  80124a:	fc                   	cld    
  80124b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80124d:	89 f8                	mov    %edi,%eax
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	57                   	push   %edi
  801258:	56                   	push   %esi
  801259:	8b 45 08             	mov    0x8(%ebp),%eax
  80125c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  80125f:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801262:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801264:	39 c6                	cmp    %eax,%esi
  801266:	73 36                	jae    80129e <memmove+0x4a>
  801268:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80126b:	39 d0                	cmp    %edx,%eax
  80126d:	73 2f                	jae    80129e <memmove+0x4a>
		s += n;
		d += n;
  80126f:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801272:	f6 c2 03             	test   $0x3,%dl
  801275:	75 1b                	jne    801292 <memmove+0x3e>
  801277:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80127d:	75 13                	jne    801292 <memmove+0x3e>
  80127f:	f6 c1 03             	test   $0x3,%cl
  801282:	75 0e                	jne    801292 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  801284:	8d 7e fc             	lea    -0x4(%esi),%edi
  801287:	8d 72 fc             	lea    -0x4(%edx),%esi
  80128a:	c1 e9 02             	shr    $0x2,%ecx
  80128d:	fd                   	std    
  80128e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801290:	eb 09                	jmp    80129b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801292:	8d 7e ff             	lea    -0x1(%esi),%edi
  801295:	8d 72 ff             	lea    -0x1(%edx),%esi
  801298:	fd                   	std    
  801299:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80129b:	fc                   	cld    
  80129c:	eb 20                	jmp    8012be <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80129e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012a4:	75 15                	jne    8012bb <memmove+0x67>
  8012a6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8012ac:	75 0d                	jne    8012bb <memmove+0x67>
  8012ae:	f6 c1 03             	test   $0x3,%cl
  8012b1:	75 08                	jne    8012bb <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  8012b3:	c1 e9 02             	shr    $0x2,%ecx
  8012b6:	fc                   	cld    
  8012b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8012b9:	eb 03                	jmp    8012be <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8012bb:	fc                   	cld    
  8012bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8012c5:	ff 75 10             	pushl  0x10(%ebp)
  8012c8:	ff 75 0c             	pushl  0xc(%ebp)
  8012cb:	ff 75 08             	pushl  0x8(%ebp)
  8012ce:	e8 81 ff ff ff       	call   801254 <memmove>
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  8012df:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  8012e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e5:	eb 1b                	jmp    801302 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  8012e7:	8a 1a                	mov    (%edx),%bl
  8012e9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  8012ec:	8a 19                	mov    (%ecx),%bl
  8012ee:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  8012f1:	74 0d                	je     801300 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  8012f3:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  8012f7:	0f b6 c3             	movzbl %bl,%eax
  8012fa:	29 c2                	sub    %eax,%edx
  8012fc:	89 d0                	mov    %edx,%eax
  8012fe:	eb 0d                	jmp    80130d <memcmp+0x38>
		s1++, s2++;
  801300:	42                   	inc    %edx
  801301:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801302:	48                   	dec    %eax
  801303:	83 f8 ff             	cmp    $0xffffffff,%eax
  801306:	75 df                	jne    8012e7 <memcmp+0x12>
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  80130d:	83 c4 04             	add    $0x4,%esp
  801310:	5b                   	pop    %ebx
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	03 55 10             	add    0x10(%ebp),%edx
  801321:	eb 05                	jmp    801328 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801323:	38 08                	cmp    %cl,(%eax)
  801325:	74 05                	je     80132c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801327:	40                   	inc    %eax
  801328:	39 d0                	cmp    %edx,%eax
  80132a:	72 f7                	jb     801323 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80132c:	c9                   	leave  
  80132d:	c3                   	ret    

0080132e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 04             	sub    $0x4,%esp
  801337:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133a:	8b 75 10             	mov    0x10(%ebp),%esi
  80133d:	eb 01                	jmp    801340 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  80133f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801340:	8a 01                	mov    (%ecx),%al
  801342:	3c 20                	cmp    $0x20,%al
  801344:	74 f9                	je     80133f <strtol+0x11>
  801346:	3c 09                	cmp    $0x9,%al
  801348:	74 f5                	je     80133f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  80134a:	3c 2b                	cmp    $0x2b,%al
  80134c:	75 0a                	jne    801358 <strtol+0x2a>
		s++;
  80134e:	41                   	inc    %ecx
  80134f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801356:	eb 17                	jmp    80136f <strtol+0x41>
	else if (*s == '-')
  801358:	3c 2d                	cmp    $0x2d,%al
  80135a:	74 09                	je     801365 <strtol+0x37>
  80135c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801363:	eb 0a                	jmp    80136f <strtol+0x41>
		s++, neg = 1;
  801365:	8d 49 01             	lea    0x1(%ecx),%ecx
  801368:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80136f:	85 f6                	test   %esi,%esi
  801371:	74 05                	je     801378 <strtol+0x4a>
  801373:	83 fe 10             	cmp    $0x10,%esi
  801376:	75 1a                	jne    801392 <strtol+0x64>
  801378:	8a 01                	mov    (%ecx),%al
  80137a:	3c 30                	cmp    $0x30,%al
  80137c:	75 10                	jne    80138e <strtol+0x60>
  80137e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801382:	75 0a                	jne    80138e <strtol+0x60>
		s += 2, base = 16;
  801384:	83 c1 02             	add    $0x2,%ecx
  801387:	be 10 00 00 00       	mov    $0x10,%esi
  80138c:	eb 04                	jmp    801392 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  80138e:	85 f6                	test   %esi,%esi
  801390:	74 07                	je     801399 <strtol+0x6b>
  801392:	bf 00 00 00 00       	mov    $0x0,%edi
  801397:	eb 13                	jmp    8013ac <strtol+0x7e>
  801399:	3c 30                	cmp    $0x30,%al
  80139b:	74 07                	je     8013a4 <strtol+0x76>
  80139d:	be 0a 00 00 00       	mov    $0xa,%esi
  8013a2:	eb ee                	jmp    801392 <strtol+0x64>
		s++, base = 8;
  8013a4:	41                   	inc    %ecx
  8013a5:	be 08 00 00 00       	mov    $0x8,%esi
  8013aa:	eb e6                	jmp    801392 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8013ac:	8a 11                	mov    (%ecx),%dl
  8013ae:	88 d3                	mov    %dl,%bl
  8013b0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8013b3:	3c 09                	cmp    $0x9,%al
  8013b5:	77 08                	ja     8013bf <strtol+0x91>
			dig = *s - '0';
  8013b7:	0f be c2             	movsbl %dl,%eax
  8013ba:	8d 50 d0             	lea    -0x30(%eax),%edx
  8013bd:	eb 1c                	jmp    8013db <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8013bf:	8d 43 9f             	lea    -0x61(%ebx),%eax
  8013c2:	3c 19                	cmp    $0x19,%al
  8013c4:	77 08                	ja     8013ce <strtol+0xa0>
			dig = *s - 'a' + 10;
  8013c6:	0f be c2             	movsbl %dl,%eax
  8013c9:	8d 50 a9             	lea    -0x57(%eax),%edx
  8013cc:	eb 0d                	jmp    8013db <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8013ce:	8d 43 bf             	lea    -0x41(%ebx),%eax
  8013d1:	3c 19                	cmp    $0x19,%al
  8013d3:	77 15                	ja     8013ea <strtol+0xbc>
			dig = *s - 'A' + 10;
  8013d5:	0f be c2             	movsbl %dl,%eax
  8013d8:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  8013db:	39 f2                	cmp    %esi,%edx
  8013dd:	7d 0b                	jge    8013ea <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  8013df:	41                   	inc    %ecx
  8013e0:	89 f8                	mov    %edi,%eax
  8013e2:	0f af c6             	imul   %esi,%eax
  8013e5:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  8013e8:	eb c2                	jmp    8013ac <strtol+0x7e>
		// we don't properly detect overflow!
	}
  8013ea:	89 f8                	mov    %edi,%eax

	if (endptr)
  8013ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013f0:	74 05                	je     8013f7 <strtol+0xc9>
		*endptr = (char *) s;
  8013f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f5:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  8013f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013fb:	74 04                	je     801401 <strtol+0xd3>
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	f7 df                	neg    %edi
}
  801401:	89 f8                	mov    %edi,%eax
  801403:	83 c4 04             	add    $0x4,%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	c9                   	leave  
  80140a:	c3                   	ret    
	...

0080140c <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	57                   	push   %edi
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801412:	b8 01 00 00 00       	mov    $0x1,%eax
  801417:	bf 00 00 00 00       	mov    $0x0,%edi
  80141c:	89 fa                	mov    %edi,%edx
  80141e:	89 f9                	mov    %edi,%ecx
  801420:	89 fb                	mov    %edi,%ebx
  801422:	89 fe                	mov    %edi,%esi
  801424:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801426:	5b                   	pop    %ebx
  801427:	5e                   	pop    %esi
  801428:	5f                   	pop    %edi
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	57                   	push   %edi
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	8b 55 08             	mov    0x8(%ebp),%edx
  801437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80143a:	bf 00 00 00 00       	mov    $0x0,%edi
  80143f:	89 f8                	mov    %edi,%eax
  801441:	89 fb                	mov    %edi,%ebx
  801443:	89 fe                	mov    %edi,%esi
  801445:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801447:	83 c4 04             	add    $0x4,%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80145b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801460:	bf 00 00 00 00       	mov    $0x0,%edi
  801465:	89 f9                	mov    %edi,%ecx
  801467:	89 fb                	mov    %edi,%ebx
  801469:	89 fe                	mov    %edi,%esi
  80146b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80146d:	85 c0                	test   %eax,%eax
  80146f:	7e 17                	jle    801488 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	50                   	push   %eax
  801475:	6a 0d                	push   $0xd
  801477:	68 4f 37 80 00       	push   $0x80374f
  80147c:	6a 23                	push   $0x23
  80147e:	68 6c 37 80 00       	push   $0x80376c
  801483:	e8 88 f5 ff ff       	call   800a10 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5f                   	pop    %edi
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	57                   	push   %edi
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	8b 55 08             	mov    0x8(%ebp),%edx
  801499:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80149c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80149f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014a7:	be 00 00 00 00       	mov    $0x0,%esi
  8014ac:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5f                   	pop    %edi
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	57                   	push   %edi
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8014cc:	89 fb                	mov    %edi,%ebx
  8014ce:	89 fe                	mov    %edi,%esi
  8014d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	7e 17                	jle    8014ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	50                   	push   %eax
  8014da:	6a 0a                	push   $0xa
  8014dc:	68 4f 37 80 00       	push   $0x80374f
  8014e1:	6a 23                	push   $0x23
  8014e3:	68 6c 37 80 00       	push   $0x80376c
  8014e8:	e8 23 f5 ff ff       	call   800a10 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8014ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f0:	5b                   	pop    %ebx
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	57                   	push   %edi
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801501:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801504:	b8 09 00 00 00       	mov    $0x9,%eax
  801509:	bf 00 00 00 00       	mov    $0x0,%edi
  80150e:	89 fb                	mov    %edi,%ebx
  801510:	89 fe                	mov    %edi,%esi
  801512:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801514:	85 c0                	test   %eax,%eax
  801516:	7e 17                	jle    80152f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	50                   	push   %eax
  80151c:	6a 09                	push   $0x9
  80151e:	68 4f 37 80 00       	push   $0x80374f
  801523:	6a 23                	push   $0x23
  801525:	68 6c 37 80 00       	push   $0x80376c
  80152a:	e8 e1 f4 ff ff       	call   800a10 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80152f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	57                   	push   %edi
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	8b 55 08             	mov    0x8(%ebp),%edx
  801543:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801546:	b8 08 00 00 00       	mov    $0x8,%eax
  80154b:	bf 00 00 00 00       	mov    $0x0,%edi
  801550:	89 fb                	mov    %edi,%ebx
  801552:	89 fe                	mov    %edi,%esi
  801554:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801556:	85 c0                	test   %eax,%eax
  801558:	7e 17                	jle    801571 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	50                   	push   %eax
  80155e:	6a 08                	push   $0x8
  801560:	68 4f 37 80 00       	push   $0x80374f
  801565:	6a 23                	push   $0x23
  801567:	68 6c 37 80 00       	push   $0x80376c
  80156c:	e8 9f f4 ff ff       	call   800a10 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	57                   	push   %edi
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	8b 55 08             	mov    0x8(%ebp),%edx
  801585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801588:	b8 06 00 00 00       	mov    $0x6,%eax
  80158d:	bf 00 00 00 00       	mov    $0x0,%edi
  801592:	89 fb                	mov    %edi,%ebx
  801594:	89 fe                	mov    %edi,%esi
  801596:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801598:	85 c0                	test   %eax,%eax
  80159a:	7e 17                	jle    8015b3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	50                   	push   %eax
  8015a0:	6a 06                	push   $0x6
  8015a2:	68 4f 37 80 00       	push   $0x80374f
  8015a7:	6a 23                	push   $0x23
  8015a9:	68 6c 37 80 00       	push   $0x80376c
  8015ae:	e8 5d f4 ff ff       	call   800a10 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8015b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b6:	5b                   	pop    %ebx
  8015b7:	5e                   	pop    %esi
  8015b8:	5f                   	pop    %edi
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	57                   	push   %edi
  8015bf:	56                   	push   %esi
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015d0:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	7e 17                	jle    8015f5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	50                   	push   %eax
  8015e2:	6a 05                	push   $0x5
  8015e4:	68 4f 37 80 00       	push   $0x80374f
  8015e9:	6a 23                	push   $0x23
  8015eb:	68 6c 37 80 00       	push   $0x80376c
  8015f0:	e8 1b f4 ff ff       	call   800a10 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5e                   	pop    %esi
  8015fa:	5f                   	pop    %edi
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	57                   	push   %edi
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8b 55 08             	mov    0x8(%ebp),%edx
  801609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80160f:	b8 04 00 00 00       	mov    $0x4,%eax
  801614:	bf 00 00 00 00       	mov    $0x0,%edi
  801619:	89 fe                	mov    %edi,%esi
  80161b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	7e 17                	jle    801638 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	50                   	push   %eax
  801625:	6a 04                	push   $0x4
  801627:	68 4f 37 80 00       	push   $0x80374f
  80162c:	6a 23                	push   $0x23
  80162e:	68 6c 37 80 00       	push   $0x80376c
  801633:	e8 d8 f3 ff ff       	call   800a10 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801646:	b8 0b 00 00 00       	mov    $0xb,%eax
  80164b:	bf 00 00 00 00       	mov    $0x0,%edi
  801650:	89 fa                	mov    %edi,%edx
  801652:	89 f9                	mov    %edi,%ecx
  801654:	89 fb                	mov    %edi,%ebx
  801656:	89 fe                	mov    %edi,%esi
  801658:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80165a:	5b                   	pop    %ebx
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	57                   	push   %edi
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801665:	b8 02 00 00 00       	mov    $0x2,%eax
  80166a:	bf 00 00 00 00       	mov    $0x0,%edi
  80166f:	89 fa                	mov    %edi,%edx
  801671:	89 f9                	mov    %edi,%ecx
  801673:	89 fb                	mov    %edi,%ebx
  801675:	89 fe                	mov    %edi,%esi
  801677:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80168a:	b8 03 00 00 00       	mov    $0x3,%eax
  80168f:	bf 00 00 00 00       	mov    $0x0,%edi
  801694:	89 f9                	mov    %edi,%ecx
  801696:	89 fb                	mov    %edi,%ebx
  801698:	89 fe                	mov    %edi,%esi
  80169a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80169c:	85 c0                	test   %eax,%eax
  80169e:	7e 17                	jle    8016b7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016a0:	83 ec 0c             	sub    $0xc,%esp
  8016a3:	50                   	push   %eax
  8016a4:	6a 03                	push   $0x3
  8016a6:	68 4f 37 80 00       	push   $0x80374f
  8016ab:	6a 23                	push   $0x23
  8016ad:	68 6c 37 80 00       	push   $0x80376c
  8016b2:	e8 59 f3 ff ff       	call   800a10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8016b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5e                   	pop    %esi
  8016bc:	5f                   	pop    %edi
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    
	...

008016c0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8016c6:	68 7a 37 80 00       	push   $0x80377a
  8016cb:	68 92 00 00 00       	push   $0x92
  8016d0:	68 90 37 80 00       	push   $0x803790
  8016d5:	e8 36 f3 ff ff       	call   800a10 <_panic>

008016da <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	57                   	push   %edi
  8016de:	56                   	push   %esi
  8016df:	53                   	push   %ebx
  8016e0:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	//1.set page fault handler
	set_pgfault_handler(pgfault);
  8016e3:	68 7b 18 80 00       	push   $0x80187b
  8016e8:	e8 6b 16 00 00       	call   802d58 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8016ed:	ba 07 00 00 00       	mov    $0x7,%edx
  8016f2:	89 d0                	mov    %edx,%eax
  8016f4:	cd 30                	int    $0x30
  8016f6:	89 c7                	mov    %eax,%edi
	//2.create a child env	
	envid_t envid = sys_exofork();//just the tf copy	
	if (envid == 0) {//must after code below excuted
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	75 25                	jne    801724 <fork+0x4a>
		thisenv = &envs[ENVX(sys_getenvid())];//fix "thisenv" in the child process
  8016ff:	e8 5b ff ff ff       	call   80165f <sys_getenvid>
  801704:	25 ff 03 00 00       	and    $0x3ff,%eax
  801709:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801710:	c1 e0 07             	shl    $0x7,%eax
  801713:	29 d0                	sub    %edx,%eax
  801715:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80171a:	a3 24 54 80 00       	mov    %eax,0x805424
  80171f:	e9 4d 01 00 00       	jmp    801871 <fork+0x197>
		return 0;
	}
	if (envid < 0) {
  801724:	85 c0                	test   %eax,%eax
  801726:	79 12                	jns    80173a <fork+0x60>
		panic("fork: sys_exofork: %e failed\n", envid);
  801728:	50                   	push   %eax
  801729:	68 9b 37 80 00       	push   $0x80379b
  80172e:	6a 77                	push   $0x77
  801730:	68 90 37 80 00       	push   $0x803790
  801735:	e8 d6 f2 ff ff       	call   800a10 <_panic>
  80173a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  80173f:	89 d8                	mov    %ebx,%eax
  801741:	c1 e8 16             	shr    $0x16,%eax
  801744:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80174b:	a8 01                	test   $0x1,%al
  80174d:	0f 84 ab 00 00 00    	je     8017fe <fork+0x124>
  801753:	89 da                	mov    %ebx,%edx
  801755:	c1 ea 0c             	shr    $0xc,%edx
  801758:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80175f:	a8 01                	test   $0x1,%al
  801761:	0f 84 97 00 00 00    	je     8017fe <fork+0x124>
  801767:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80176e:	a8 04                	test   $0x4,%al
  801770:	0f 84 88 00 00 00    	je     8017fe <fork+0x124>
{
	int r;

	// LAB 4: Your code here.
	//COW check, map page
	pte_t pte = uvpt[pn];
  801776:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
	void *addr = (void *) (pn * PGSIZE);
  80177d:	89 d6                	mov    %edx,%esi
  80177f:	c1 e6 0c             	shl    $0xc,%esi
	
	uint32_t perm = pte&0xfff;
  801782:	89 c2                	mov    %eax,%edx
  801784:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if(perm & (PTE_W | PTE_COW) && !(perm & PTE_SHARE)){
  80178a:	a9 02 08 00 00       	test   $0x802,%eax
  80178f:	74 0f                	je     8017a0 <fork+0xc6>
  801791:	f6 c4 04             	test   $0x4,%ah
  801794:	75 0a                	jne    8017a0 <fork+0xc6>
		perm &= ~PTE_W;
  801796:	25 fd 0f 00 00       	and    $0xffd,%eax
		perm |= PTE_COW;
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	80 ce 08             	or     $0x8,%dh
	}
	
	r = sys_page_map(0, addr, envid, addr, perm & PTE_SYSCALL);
  8017a0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8017a9:	83 ec 0c             	sub    $0xc,%esp
  8017ac:	52                   	push   %edx
  8017ad:	56                   	push   %esi
  8017ae:	57                   	push   %edi
  8017af:	56                   	push   %esi
  8017b0:	6a 00                	push   $0x0
  8017b2:	e8 04 fe ff ff       	call   8015bb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page child failed\n");
  8017b7:	83 c4 20             	add    $0x20,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	79 14                	jns    8017d2 <fork+0xf8>
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	68 e4 37 80 00       	push   $0x8037e4
  8017c6:	6a 52                	push   $0x52
  8017c8:	68 90 37 80 00       	push   $0x803790
  8017cd:	e8 3e f2 ff ff       	call   800a10 <_panic>
	//map self again : freeze parent and child
	r = sys_page_map(0, addr, 0, addr, perm & PTE_SYSCALL);
  8017d2:	83 ec 0c             	sub    $0xc,%esp
  8017d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d8:	56                   	push   %esi
  8017d9:	6a 00                	push   $0x0
  8017db:	56                   	push   %esi
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 d8 fd ff ff       	call   8015bb <sys_page_map>
	if(r < 0)panic("duppage: sys_map_page self failed\n");
  8017e3:	83 c4 20             	add    $0x20,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	79 14                	jns    8017fe <fork+0x124>
  8017ea:	83 ec 04             	sub    $0x4,%esp
  8017ed:	68 08 38 80 00       	push   $0x803808
  8017f2:	6a 55                	push   $0x55
  8017f4:	68 90 37 80 00       	push   $0x803790
  8017f9:	e8 12 f2 ff ff       	call   800a10 <_panic>
	if (envid < 0) {
		panic("fork: sys_exofork: %e failed\n", envid);
	}
	//COW mapping:duppage(envid, va's page):from 0 - USTACKTOP(under UTOP)
	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8017fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801804:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80180a:	0f 85 2f ff ff ff    	jne    80173f <fork+0x65>
			duppage(envid, PGNUM(addr));	//env already has page directory and page table
		}

	//child's exception stack
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801810:	83 ec 04             	sub    $0x4,%esp
  801813:	6a 07                	push   $0x7
  801815:	68 00 f0 bf ee       	push   $0xeebff000
  80181a:	57                   	push   %edi
  80181b:	e8 dd fd ff ff       	call   8015fd <sys_page_alloc>
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	79 15                	jns    80183c <fork+0x162>
		panic("sys_page_alloc: %e", r);
  801827:	50                   	push   %eax
  801828:	68 b9 37 80 00       	push   $0x8037b9
  80182d:	68 83 00 00 00       	push   $0x83
  801832:	68 90 37 80 00       	push   $0x803790
  801837:	e8 d4 f1 ff ff       	call   800a10 <_panic>
	//set child's pgfault_upcall
	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	68 d8 2d 80 00       	push   $0x802dd8
  801844:	57                   	push   %edi
  801845:	e8 69 fc ff ff       	call   8014b3 <sys_env_set_pgfault_upcall>
	//runnable
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	 
  80184a:	83 c4 08             	add    $0x8,%esp
  80184d:	6a 02                	push   $0x2
  80184f:	57                   	push   %edi
  801850:	e8 e2 fc ff ff       	call   801537 <sys_env_set_status>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	79 15                	jns    801871 <fork+0x197>
		panic("sys_env_set_status: %e", r);
  80185c:	50                   	push   %eax
  80185d:	68 cc 37 80 00       	push   $0x8037cc
  801862:	68 89 00 00 00       	push   $0x89
  801867:	68 90 37 80 00       	push   $0x803790
  80186c:	e8 9f f1 ff ff       	call   800a10 <_panic>
	return envid;
	//panic("fork not implemented");
}
  801871:	89 f8                	mov    %edi,%eax
  801873:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5f                   	pop    %edi
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	8b 55 08             	mov    0x8(%ebp),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	uint32_t write_err = err & FEC_WR;
	uint32_t COW = uvpt[PGNUM(addr)] & PTE_COW;
  801885:	8b 1a                	mov    (%edx),%ebx
  801887:	89 d8                	mov    %ebx,%eax
  801889:	c1 e8 0c             	shr    $0xc,%eax
  80188c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if(!(write_err && COW))panic("pgfault: not write to the COW page fault!\n");
  801893:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801897:	74 05                	je     80189e <pgfault+0x23>
  801899:	f6 c4 08             	test   $0x8,%ah
  80189c:	75 14                	jne    8018b2 <pgfault+0x37>
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	68 2c 38 80 00       	push   $0x80382c
  8018a6:	6a 1e                	push   $0x1e
  8018a8:	68 90 37 80 00       	push   $0x803790
  8018ad:	e8 5e f1 ff ff       	call   800a10 <_panic>

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	6a 07                	push   $0x7
  8018b7:	68 00 f0 7f 00       	push   $0x7ff000
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 3a fd ff ff       	call   8015fd <sys_page_alloc>
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	79 14                	jns    8018de <pgfault+0x63>
  8018ca:	83 ec 04             	sub    $0x4,%esp
  8018cd:	68 58 38 80 00       	push   $0x803858
  8018d2:	6a 2a                	push   $0x2a
  8018d4:	68 90 37 80 00       	push   $0x803790
  8018d9:	e8 32 f1 ff ff       	call   800a10 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//alloc a page by PFTEMP

	addr = ROUNDDOWN(addr, PGSIZE);
  8018de:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W);
	if(r < 0)panic("pgfault: sys_page_alloc failed!\n");
	//copy data
	memmove(PFTEMP, addr, PGSIZE);
  8018e4:	83 ec 04             	sub    $0x4,%esp
  8018e7:	68 00 10 00 00       	push   $0x1000
  8018ec:	53                   	push   %ebx
  8018ed:	68 00 f0 7f 00       	push   $0x7ff000
  8018f2:	e8 5d f9 ff ff       	call   801254 <memmove>
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_P | PTE_W);
  8018f7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018fe:	53                   	push   %ebx
  8018ff:	6a 00                	push   $0x0
  801901:	68 00 f0 7f 00       	push   $0x7ff000
  801906:	6a 00                	push   $0x0
  801908:	e8 ae fc ff ff       	call   8015bb <sys_page_map>
	if(r < 0)panic("pgfault: sys_page_map failed!\n");
  80190d:	83 c4 20             	add    $0x20,%esp
  801910:	85 c0                	test   %eax,%eax
  801912:	79 14                	jns    801928 <pgfault+0xad>
  801914:	83 ec 04             	sub    $0x4,%esp
  801917:	68 7c 38 80 00       	push   $0x80387c
  80191c:	6a 2e                	push   $0x2e
  80191e:	68 90 37 80 00       	push   $0x803790
  801923:	e8 e8 f0 ff ff       	call   800a10 <_panic>
	
	//remove PTE:PFTEMP
	r = sys_page_unmap(0, PFTEMP);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	68 00 f0 7f 00       	push   $0x7ff000
  801930:	6a 00                	push   $0x0
  801932:	e8 42 fc ff ff       	call   801579 <sys_page_unmap>
	if(r < 0)panic("pgfault: sys_page_unmap failed!\n");
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	85 c0                	test   %eax,%eax
  80193c:	79 14                	jns    801952 <pgfault+0xd7>
  80193e:	83 ec 04             	sub    $0x4,%esp
  801941:	68 9c 38 80 00       	push   $0x80389c
  801946:	6a 32                	push   $0x32
  801948:	68 90 37 80 00       	push   $0x803790
  80194d:	e8 be f0 ff ff       	call   800a10 <_panic>
	//panic("pgfault not implemented");
}
  801952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801955:	c9                   	leave  
  801956:	c3                   	ret    
	...

00801958 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801961:	8b 55 10             	mov    0x10(%ebp),%edx
	args->argc = argc;
  801964:	89 02                	mov    %eax,(%edx)
	args->argv = (const char **) argv;
  801966:	89 4a 04             	mov    %ecx,0x4(%edx)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801969:	83 38 01             	cmpl   $0x1,(%eax)
  80196c:	7e 0b                	jle    801979 <argstart+0x21>
  80196e:	85 c9                	test   %ecx,%ecx
  801970:	74 07                	je     801979 <argstart+0x21>
  801972:	b8 93 32 80 00       	mov    $0x803293,%eax
  801977:	eb 05                	jmp    80197e <argstart+0x26>
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
  80197e:	89 42 08             	mov    %eax,0x8(%edx)
	args->argvalue = 0;
  801981:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 04             	sub    $0x4,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801994:	8b 43 08             	mov    0x8(%ebx),%eax
  801997:	85 c0                	test   %eax,%eax
  801999:	74 55                	je     8019f0 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  80199b:	80 38 00             	cmpb   $0x0,(%eax)
  80199e:	74 0c                	je     8019ac <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8019a0:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8019a3:	c7 43 08 93 32 80 00 	movl   $0x803293,0x8(%ebx)
  8019aa:	eb 41                	jmp    8019ed <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  8019ac:	8b 0b                	mov    (%ebx),%ecx
  8019ae:	83 39 01             	cmpl   $0x1,(%ecx)
  8019b1:	7e 2c                	jle    8019df <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  8019b3:	8b 53 04             	mov    0x4(%ebx),%edx
  8019b6:	8b 42 04             	mov    0x4(%edx),%eax
  8019b9:	89 43 0c             	mov    %eax,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8019bc:	83 ec 04             	sub    $0x4,%esp
  8019bf:	8b 01                	mov    (%ecx),%eax
  8019c1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8019c8:	50                   	push   %eax
  8019c9:	8d 42 08             	lea    0x8(%edx),%eax
  8019cc:	50                   	push   %eax
  8019cd:	83 c2 04             	add    $0x4,%edx
  8019d0:	52                   	push   %edx
  8019d1:	e8 7e f8 ff ff       	call   801254 <memmove>
		(*args->argc)--;
  8019d6:	8b 03                	mov    (%ebx),%eax
  8019d8:	ff 08                	decl   (%eax)
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	eb 0e                	jmp    8019ed <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  8019df:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8019e6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8019ed:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  8019f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8019fe:	8b 42 0c             	mov    0xc(%edx),%eax
  801a01:	85 c0                	test   %eax,%eax
  801a03:	75 0c                	jne    801a11 <argvalue+0x1c>
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	52                   	push   %edx
  801a09:	e8 7c ff ff ff       	call   80198a <argnextvalue>
  801a0e:	83 c4 10             	add    $0x10,%esp
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <argnext>:
	args->argvalue = 0;
}

int
argnext(struct Argstate *args)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a1b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a22:	8b 43 08             	mov    0x8(%ebx),%eax
  801a25:	85 c0                	test   %eax,%eax
  801a27:	75 07                	jne    801a30 <argnext+0x1d>
  801a29:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a2e:	eb 6a                	jmp    801a9a <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801a30:	80 38 00             	cmpb   $0x0,(%eax)
  801a33:	75 4d                	jne    801a82 <argnext+0x6f>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a35:	8b 03                	mov    (%ebx),%eax
  801a37:	83 38 01             	cmpl   $0x1,(%eax)
  801a3a:	74 52                	je     801a8e <argnext+0x7b>
  801a3c:	8b 4b 04             	mov    0x4(%ebx),%ecx
  801a3f:	8b 51 04             	mov    0x4(%ecx),%edx
  801a42:	80 3a 2d             	cmpb   $0x2d,(%edx)
  801a45:	75 47                	jne    801a8e <argnext+0x7b>
  801a47:	8d 72 01             	lea    0x1(%edx),%esi
  801a4a:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  801a4e:	74 3e                	je     801a8e <argnext+0x7b>
		    || args->argv[1][0] != '-'
		    || args->argv[1][1] == '\0')
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a50:	89 73 08             	mov    %esi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a53:	83 ec 04             	sub    $0x4,%esp
  801a56:	8b 00                	mov    (%eax),%eax
  801a58:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801a5f:	50                   	push   %eax
  801a60:	8d 41 08             	lea    0x8(%ecx),%eax
  801a63:	50                   	push   %eax
  801a64:	8d 41 04             	lea    0x4(%ecx),%eax
  801a67:	50                   	push   %eax
  801a68:	e8 e7 f7 ff ff       	call   801254 <memmove>
		(*args->argc)--;
  801a6d:	8b 03                	mov    (%ebx),%eax
  801a6f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801a71:	8b 43 08             	mov    0x8(%ebx),%eax
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a7a:	75 06                	jne    801a82 <argnext+0x6f>
  801a7c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a80:	74 0c                	je     801a8e <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801a82:	8b 43 08             	mov    0x8(%ebx),%eax
  801a85:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801a88:	40                   	inc    %eax
  801a89:	89 43 08             	mov    %eax,0x8(%ebx)
  801a8c:	eb 0c                	jmp    801a9a <argnext+0x87>
	return arg;

    endofargs:
	args->curarg = 0;
  801a8e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801a95:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	return -1;
}
  801a9a:	89 d0                	mov    %edx,%eax
  801a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    
	...

00801aa4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	05 00 00 00 30       	add    $0x30000000,%eax
  801aaf:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801ab7:	ff 75 08             	pushl  0x8(%ebp)
  801aba:	e8 e5 ff ff ff       	call   801aa4 <fd2num>
  801abf:	83 c4 04             	add    $0x4,%esp
  801ac2:	c1 e0 0c             	shl    $0xc,%eax
  801ac5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	53                   	push   %ebx
  801ad0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ad3:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801ad8:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801ada:	89 d0                	mov    %edx,%eax
  801adc:	c1 e8 16             	shr    $0x16,%eax
  801adf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae6:	a8 01                	test   $0x1,%al
  801ae8:	74 10                	je     801afa <fd_alloc+0x2e>
  801aea:	89 d0                	mov    %edx,%eax
  801aec:	c1 e8 0c             	shr    $0xc,%eax
  801aef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801af6:	a8 01                	test   $0x1,%al
  801af8:	75 09                	jne    801b03 <fd_alloc+0x37>
			*fd_store = fd;
  801afa:	89 0b                	mov    %ecx,(%ebx)
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
  801b01:	eb 19                	jmp    801b1c <fd_alloc+0x50>
			return 0;
  801b03:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b09:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801b0f:	75 c7                	jne    801ad8 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b17:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801b1c:	5b                   	pop    %ebx
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b25:	83 f8 1f             	cmp    $0x1f,%eax
  801b28:	77 35                	ja     801b5f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b2a:	c1 e0 0c             	shl    $0xc,%eax
  801b2d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	c1 e8 16             	shr    $0x16,%eax
  801b38:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b3f:	a8 01                	test   $0x1,%al
  801b41:	74 1c                	je     801b5f <fd_lookup+0x40>
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	c1 e8 0c             	shr    $0xc,%eax
  801b48:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b4f:	a8 01                	test   $0x1,%al
  801b51:	74 0c                	je     801b5f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b56:	89 10                	mov    %edx,(%eax)
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5d:	eb 05                	jmp    801b64 <fd_lookup+0x45>
	return 0;
  801b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b6c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b6f:	50                   	push   %eax
  801b70:	ff 75 08             	pushl  0x8(%ebp)
  801b73:	e8 a7 ff ff ff       	call   801b1f <fd_lookup>
  801b78:	83 c4 08             	add    $0x8,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 0e                	js     801b8d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b85:	89 50 04             	mov    %edx,0x4(%eax)
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	53                   	push   %ebx
  801b93:	83 ec 04             	sub    $0x4,%esp
  801b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba1:	eb 0e                	jmp    801bb1 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801ba3:	3b 08                	cmp    (%eax),%ecx
  801ba5:	75 09                	jne    801bb0 <dev_lookup+0x21>
			*dev = devtab[i];
  801ba7:	89 03                	mov    %eax,(%ebx)
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	eb 31                	jmp    801be1 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801bb0:	42                   	inc    %edx
  801bb1:	8b 04 95 3c 39 80 00 	mov    0x80393c(,%edx,4),%eax
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	75 e7                	jne    801ba3 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801bbc:	a1 24 54 80 00       	mov    0x805424,%eax
  801bc1:	8b 40 48             	mov    0x48(%eax),%eax
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	51                   	push   %ecx
  801bc8:	50                   	push   %eax
  801bc9:	68 c0 38 80 00       	push   $0x8038c0
  801bce:	e8 de ee ff ff       	call   800ab1 <cprintf>
	*dev = 0;
  801bd3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bde:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801be1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	53                   	push   %ebx
  801bea:	83 ec 14             	sub    $0x14,%esp
  801bed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf3:	50                   	push   %eax
  801bf4:	ff 75 08             	pushl  0x8(%ebp)
  801bf7:	e8 23 ff ff ff       	call   801b1f <fd_lookup>
  801bfc:	83 c4 08             	add    $0x8,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 55                	js     801c58 <fstat+0x72>
  801c03:	83 ec 08             	sub    $0x8,%esp
  801c06:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801c09:	50                   	push   %eax
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	ff 30                	pushl  (%eax)
  801c0f:	e8 7b ff ff ff       	call   801b8f <dev_lookup>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	78 3d                	js     801c58 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801c1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c1e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c22:	75 07                	jne    801c2b <fstat+0x45>
  801c24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c29:	eb 2d                	jmp    801c58 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c2b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c2e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c35:	00 00 00 
	stat->st_isdir = 0;
  801c38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3f:	00 00 00 
	stat->st_dev = dev;
  801c42:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c45:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	53                   	push   %ebx
  801c4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c52:	ff 50 14             	call   *0x14(%eax)
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	53                   	push   %ebx
  801c61:	83 ec 14             	sub    $0x14,%esp
  801c64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6a:	50                   	push   %eax
  801c6b:	53                   	push   %ebx
  801c6c:	e8 ae fe ff ff       	call   801b1f <fd_lookup>
  801c71:	83 c4 08             	add    $0x8,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 5f                	js     801cd7 <ftruncate+0x7a>
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c82:	ff 30                	pushl  (%eax)
  801c84:	e8 06 ff ff ff       	call   801b8f <dev_lookup>
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 47                	js     801cd7 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c97:	75 21                	jne    801cba <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c99:	a1 24 54 80 00       	mov    0x805424,%eax
  801c9e:	8b 40 48             	mov    0x48(%eax),%eax
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	53                   	push   %ebx
  801ca5:	50                   	push   %eax
  801ca6:	68 e0 38 80 00       	push   $0x8038e0
  801cab:	e8 01 ee ff ff       	call   800ab1 <cprintf>
  801cb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	eb 1d                	jmp    801cd7 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801cba:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801cbd:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801cc1:	75 07                	jne    801cca <ftruncate+0x6d>
  801cc3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cc8:	eb 0d                	jmp    801cd7 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	ff 75 0c             	pushl  0xc(%ebp)
  801cd0:	50                   	push   %eax
  801cd1:	ff 52 18             	call   *0x18(%edx)
  801cd4:	83 c4 10             	add    $0x10,%esp
}
  801cd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cda:	c9                   	leave  
  801cdb:	c3                   	ret    

00801cdc <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 14             	sub    $0x14,%esp
  801ce3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	53                   	push   %ebx
  801ceb:	e8 2f fe ff ff       	call   801b1f <fd_lookup>
  801cf0:	83 c4 08             	add    $0x8,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 62                	js     801d59 <write+0x7d>
  801cf7:	83 ec 08             	sub    $0x8,%esp
  801cfa:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801cfd:	50                   	push   %eax
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	ff 30                	pushl  (%eax)
  801d03:	e8 87 fe ff ff       	call   801b8f <dev_lookup>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 4a                	js     801d59 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d16:	75 21                	jne    801d39 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801d18:	a1 24 54 80 00       	mov    0x805424,%eax
  801d1d:	8b 40 48             	mov    0x48(%eax),%eax
  801d20:	83 ec 04             	sub    $0x4,%esp
  801d23:	53                   	push   %ebx
  801d24:	50                   	push   %eax
  801d25:	68 01 39 80 00       	push   $0x803901
  801d2a:	e8 82 ed ff ff       	call   800ab1 <cprintf>
  801d2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	eb 20                	jmp    801d59 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801d39:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801d3c:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801d40:	75 07                	jne    801d49 <write+0x6d>
  801d42:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d47:	eb 10                	jmp    801d59 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	ff 75 10             	pushl  0x10(%ebp)
  801d4f:	ff 75 0c             	pushl  0xc(%ebp)
  801d52:	50                   	push   %eax
  801d53:	ff 52 0c             	call   *0xc(%edx)
  801d56:	83 c4 10             	add    $0x10,%esp
}
  801d59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	83 ec 14             	sub    $0x14,%esp
  801d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6b:	50                   	push   %eax
  801d6c:	53                   	push   %ebx
  801d6d:	e8 ad fd ff ff       	call   801b1f <fd_lookup>
  801d72:	83 c4 08             	add    $0x8,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 67                	js     801de0 <read+0x82>
  801d79:	83 ec 08             	sub    $0x8,%esp
  801d7c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801d7f:	50                   	push   %eax
  801d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d83:	ff 30                	pushl  (%eax)
  801d85:	e8 05 fe ff ff       	call   801b8f <dev_lookup>
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	78 4f                	js     801de0 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d94:	8b 42 08             	mov    0x8(%edx),%eax
  801d97:	83 e0 03             	and    $0x3,%eax
  801d9a:	83 f8 01             	cmp    $0x1,%eax
  801d9d:	75 21                	jne    801dc0 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801d9f:	a1 24 54 80 00       	mov    0x805424,%eax
  801da4:	8b 40 48             	mov    0x48(%eax),%eax
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	53                   	push   %ebx
  801dab:	50                   	push   %eax
  801dac:	68 1e 39 80 00       	push   $0x80391e
  801db1:	e8 fb ec ff ff       	call   800ab1 <cprintf>
  801db6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	eb 20                	jmp    801de0 <read+0x82>
	}
	if (!dev->dev_read)
  801dc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801dc3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  801dc7:	75 07                	jne    801dd0 <read+0x72>
  801dc9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801dce:	eb 10                	jmp    801de0 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801dd0:	83 ec 04             	sub    $0x4,%esp
  801dd3:	ff 75 10             	pushl  0x10(%ebp)
  801dd6:	ff 75 0c             	pushl  0xc(%ebp)
  801dd9:	52                   	push   %edx
  801dda:	ff 50 08             	call   *0x8(%eax)
  801ddd:	83 c4 10             	add    $0x10,%esp
}
  801de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	57                   	push   %edi
  801de9:	56                   	push   %esi
  801dea:	53                   	push   %ebx
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801df1:	8b 75 10             	mov    0x10(%ebp),%esi
  801df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df9:	eb 21                	jmp    801e1c <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  801dfb:	83 ec 04             	sub    $0x4,%esp
  801dfe:	89 f0                	mov    %esi,%eax
  801e00:	29 d0                	sub    %edx,%eax
  801e02:	50                   	push   %eax
  801e03:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801e06:	50                   	push   %eax
  801e07:	ff 75 08             	pushl  0x8(%ebp)
  801e0a:	e8 4f ff ff ff       	call   801d5e <read>
		if (m < 0)
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 0e                	js     801e24 <readn+0x3f>
			return m;
		if (m == 0)
  801e16:	85 c0                	test   %eax,%eax
  801e18:	74 08                	je     801e22 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e1a:	01 c3                	add    %eax,%ebx
  801e1c:	89 da                	mov    %ebx,%edx
  801e1e:	39 f3                	cmp    %esi,%ebx
  801e20:	72 d9                	jb     801dfb <readn+0x16>
  801e22:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	56                   	push   %esi
  801e30:	53                   	push   %ebx
  801e31:	83 ec 20             	sub    $0x20,%esp
  801e34:	8b 75 08             	mov    0x8(%ebp),%esi
  801e37:	8a 45 0c             	mov    0xc(%ebp),%al
  801e3a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801e3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	56                   	push   %esi
  801e42:	e8 5d fc ff ff       	call   801aa4 <fd2num>
  801e47:	89 04 24             	mov    %eax,(%esp)
  801e4a:	e8 d0 fc ff ff       	call   801b1f <fd_lookup>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	83 c4 08             	add    $0x8,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 05                	js     801e5d <fd_close+0x31>
  801e58:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e5b:	74 0d                	je     801e6a <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801e5d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801e61:	75 48                	jne    801eab <fd_close+0x7f>
  801e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e68:	eb 41                	jmp    801eab <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e6a:	83 ec 08             	sub    $0x8,%esp
  801e6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	ff 36                	pushl  (%esi)
  801e73:	e8 17 fd ff ff       	call   801b8f <dev_lookup>
  801e78:	89 c3                	mov    %eax,%ebx
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 1c                	js     801e9d <fd_close+0x71>
		if (dev->dev_close)
  801e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e84:	8b 40 10             	mov    0x10(%eax),%eax
  801e87:	85 c0                	test   %eax,%eax
  801e89:	75 07                	jne    801e92 <fd_close+0x66>
  801e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e90:	eb 0b                	jmp    801e9d <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	56                   	push   %esi
  801e96:	ff d0                	call   *%eax
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e9d:	83 ec 08             	sub    $0x8,%esp
  801ea0:	56                   	push   %esi
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 d1 f6 ff ff       	call   801579 <sys_page_unmap>
  801ea8:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801eab:	89 d8                	mov    %ebx,%eax
  801ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb0:	5b                   	pop    %ebx
  801eb1:	5e                   	pop    %esi
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ebd:	50                   	push   %eax
  801ebe:	ff 75 08             	pushl  0x8(%ebp)
  801ec1:	e8 59 fc ff ff       	call   801b1f <fd_lookup>
  801ec6:	83 c4 08             	add    $0x8,%esp
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	78 10                	js     801edd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801ecd:	83 ec 08             	sub    $0x8,%esp
  801ed0:	6a 01                	push   $0x1
  801ed2:	ff 75 fc             	pushl  -0x4(%ebp)
  801ed5:	e8 52 ff ff ff       	call   801e2c <fd_close>
  801eda:	83 c4 10             	add    $0x10,%esp
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	6a 00                	push   $0x0
  801ee9:	ff 75 08             	pushl  0x8(%ebp)
  801eec:	e8 4a 03 00 00       	call   80223b <open>
  801ef1:	89 c6                	mov    %eax,%esi
  801ef3:	83 c4 10             	add    $0x10,%esp
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 1b                	js     801f15 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801efa:	83 ec 08             	sub    $0x8,%esp
  801efd:	ff 75 0c             	pushl  0xc(%ebp)
  801f00:	50                   	push   %eax
  801f01:	e8 e0 fc ff ff       	call   801be6 <fstat>
  801f06:	89 c3                	mov    %eax,%ebx
	close(fd);
  801f08:	89 34 24             	mov    %esi,(%esp)
  801f0b:	e8 a4 ff ff ff       	call   801eb4 <close>
  801f10:	89 de                	mov    %ebx,%esi
  801f12:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801f15:	89 f0                	mov    %esi,%eax
  801f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801f2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f2d:	50                   	push   %eax
  801f2e:	ff 75 08             	pushl  0x8(%ebp)
  801f31:	e8 e9 fb ff ff       	call   801b1f <fd_lookup>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	83 c4 08             	add    $0x8,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	0f 88 bd 00 00 00    	js     802000 <dup+0xe2>
		return r;
	close(newfdnum);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	57                   	push   %edi
  801f47:	e8 68 ff ff ff       	call   801eb4 <close>

	newfd = INDEX2FD(newfdnum);
  801f4c:	89 f8                	mov    %edi,%eax
  801f4e:	c1 e0 0c             	shl    $0xc,%eax
  801f51:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801f57:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5a:	e8 55 fb ff ff       	call   801ab4 <fd2data>
  801f5f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801f61:	89 34 24             	mov    %esi,(%esp)
  801f64:	e8 4b fb ff ff       	call   801ab4 <fd2data>
  801f69:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	c1 e8 16             	shr    $0x16,%eax
  801f71:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f78:	83 c4 14             	add    $0x14,%esp
  801f7b:	a8 01                	test   $0x1,%al
  801f7d:	74 36                	je     801fb5 <dup+0x97>
  801f7f:	89 da                	mov    %ebx,%edx
  801f81:	c1 ea 0c             	shr    $0xc,%edx
  801f84:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801f8b:	a8 01                	test   $0x1,%al
  801f8d:	74 26                	je     801fb5 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f8f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	25 07 0e 00 00       	and    $0xe07,%eax
  801f9e:	50                   	push   %eax
  801f9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801fa2:	6a 00                	push   $0x0
  801fa4:	53                   	push   %ebx
  801fa5:	6a 00                	push   $0x0
  801fa7:	e8 0f f6 ff ff       	call   8015bb <sys_page_map>
  801fac:	89 c3                	mov    %eax,%ebx
  801fae:	83 c4 20             	add    $0x20,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 30                	js     801fe5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801fb5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fb8:	89 d0                	mov    %edx,%eax
  801fba:	c1 e8 0c             	shr    $0xc,%eax
  801fbd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801fc4:	83 ec 0c             	sub    $0xc,%esp
  801fc7:	25 07 0e 00 00       	and    $0xe07,%eax
  801fcc:	50                   	push   %eax
  801fcd:	56                   	push   %esi
  801fce:	6a 00                	push   $0x0
  801fd0:	52                   	push   %edx
  801fd1:	6a 00                	push   $0x0
  801fd3:	e8 e3 f5 ff ff       	call   8015bb <sys_page_map>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	83 c4 20             	add    $0x20,%esp
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	78 04                	js     801fe5 <dup+0xc7>
		goto err;
  801fe1:	89 fb                	mov    %edi,%ebx
  801fe3:	eb 1b                	jmp    802000 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801fe5:	83 ec 08             	sub    $0x8,%esp
  801fe8:	56                   	push   %esi
  801fe9:	6a 00                	push   $0x0
  801feb:	e8 89 f5 ff ff       	call   801579 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ff0:	83 c4 08             	add    $0x8,%esp
  801ff3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ff6:	6a 00                	push   $0x0
  801ff8:	e8 7c f5 ff ff       	call   801579 <sys_page_unmap>
  801ffd:	83 c4 10             	add    $0x10,%esp
	return r;
}
  802000:	89 d8                	mov    %ebx,%eax
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	53                   	push   %ebx
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802016:	83 ec 0c             	sub    $0xc,%esp
  802019:	53                   	push   %ebx
  80201a:	e8 95 fe ff ff       	call   801eb4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80201f:	43                   	inc    %ebx
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	83 fb 20             	cmp    $0x20,%ebx
  802026:	75 ee                	jne    802016 <close_all+0xc>
		close(i);
}
  802028:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    
  80202d:	00 00                	add    %al,(%eax)
	...

00802030 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	89 c3                	mov    %eax,%ebx
  802037:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802039:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802040:	75 12                	jne    802054 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	6a 01                	push   $0x1
  802047:	e8 b4 0d 00 00       	call   802e00 <ipc_find_env>
  80204c:	a3 20 54 80 00       	mov    %eax,0x805420
  802051:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802054:	6a 07                	push   $0x7
  802056:	68 00 60 80 00       	push   $0x806000
  80205b:	53                   	push   %ebx
  80205c:	ff 35 20 54 80 00    	pushl  0x805420
  802062:	e8 de 0d 00 00       	call   802e45 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802067:	83 c4 0c             	add    $0xc,%esp
  80206a:	6a 00                	push   $0x0
  80206c:	56                   	push   %esi
  80206d:	6a 00                	push   $0x0
  80206f:	e8 26 0e 00 00       	call   802e9a <ipc_recv>
}
  802074:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802077:	5b                   	pop    %ebx
  802078:	5e                   	pop    %esi
  802079:	c9                   	leave  
  80207a:	c3                   	ret    

0080207b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802081:	ba 00 00 00 00       	mov    $0x0,%edx
  802086:	b8 08 00 00 00       	mov    $0x8,%eax
  80208b:	e8 a0 ff ff ff       	call   802030 <fsipc>
}
  802090:	c9                   	leave  
  802091:	c3                   	ret    

00802092 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802098:	8b 45 08             	mov    0x8(%ebp),%eax
  80209b:	8b 40 0c             	mov    0xc(%eax),%eax
  80209e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8020a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a6:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8020ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8020b5:	e8 76 ff ff ff       	call   802030 <fsipc>
}
  8020ba:	c9                   	leave  
  8020bb:	c3                   	ret    

008020bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8020c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8020c8:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8020cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8020d7:	e8 54 ff ff ff       	call   802030 <fsipc>
}
  8020dc:	c9                   	leave  
  8020dd:	c3                   	ret    

008020de <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	53                   	push   %ebx
  8020e2:	83 ec 04             	sub    $0x4,%esp
  8020e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8020ee:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8020f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8020fd:	e8 2e ff ff ff       	call   802030 <fsipc>
  802102:	85 c0                	test   %eax,%eax
  802104:	78 2c                	js     802132 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802106:	83 ec 08             	sub    $0x8,%esp
  802109:	68 00 60 80 00       	push   $0x806000
  80210e:	53                   	push   %ebx
  80210f:	e8 d3 ef ff ff       	call   8010e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802114:	a1 80 60 80 00       	mov    0x806080,%eax
  802119:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80211f:	a1 84 60 80 00       	mov    0x806084,%eax
  802124:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80212a:	b8 00 00 00 00       	mov    $0x0,%eax
  80212f:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  802132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802135:	c9                   	leave  
  802136:	c3                   	ret    

00802137 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	53                   	push   %ebx
  80213b:	83 ec 08             	sub    $0x8,%esp
  80213e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802141:	8b 45 08             	mov    0x8(%ebp),%eax
  802144:	8b 40 0c             	mov    0xc(%eax),%eax
  802147:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = n;
  80214c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802152:	53                   	push   %ebx
  802153:	ff 75 0c             	pushl  0xc(%ebp)
  802156:	68 08 60 80 00       	push   $0x806008
  80215b:	e8 f4 f0 ff ff       	call   801254 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802160:	ba 00 00 00 00       	mov    $0x0,%edx
  802165:	b8 04 00 00 00       	mov    $0x4,%eax
  80216a:	e8 c1 fe ff ff       	call   802030 <fsipc>
  80216f:	83 c4 10             	add    $0x10,%esp
  802172:	85 c0                	test   %eax,%eax
  802174:	78 3d                	js     8021b3 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  802176:	39 c3                	cmp    %eax,%ebx
  802178:	73 19                	jae    802193 <devfile_write+0x5c>
  80217a:	68 4c 39 80 00       	push   $0x80394c
  80217f:	68 c8 33 80 00       	push   $0x8033c8
  802184:	68 97 00 00 00       	push   $0x97
  802189:	68 53 39 80 00       	push   $0x803953
  80218e:	e8 7d e8 ff ff       	call   800a10 <_panic>
	assert(r <= PGSIZE);
  802193:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802198:	7e 19                	jle    8021b3 <devfile_write+0x7c>
  80219a:	68 5e 39 80 00       	push   $0x80395e
  80219f:	68 c8 33 80 00       	push   $0x8033c8
  8021a4:	68 98 00 00 00       	push   $0x98
  8021a9:	68 53 39 80 00       	push   $0x803953
  8021ae:	e8 5d e8 ff ff       	call   800a10 <_panic>
	
	return r;
}
  8021b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	56                   	push   %esi
  8021bc:	53                   	push   %ebx
  8021bd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8021c6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8021cb:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8021d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8021d6:	b8 03 00 00 00       	mov    $0x3,%eax
  8021db:	e8 50 fe ff ff       	call   802030 <fsipc>
  8021e0:	89 c3                	mov    %eax,%ebx
  8021e2:	85 c0                	test   %eax,%eax
  8021e4:	78 4c                	js     802232 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8021e6:	39 de                	cmp    %ebx,%esi
  8021e8:	73 16                	jae    802200 <devfile_read+0x48>
  8021ea:	68 4c 39 80 00       	push   $0x80394c
  8021ef:	68 c8 33 80 00       	push   $0x8033c8
  8021f4:	6a 7c                	push   $0x7c
  8021f6:	68 53 39 80 00       	push   $0x803953
  8021fb:	e8 10 e8 ff ff       	call   800a10 <_panic>
	assert(r <= PGSIZE);
  802200:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  802206:	7e 16                	jle    80221e <devfile_read+0x66>
  802208:	68 5e 39 80 00       	push   $0x80395e
  80220d:	68 c8 33 80 00       	push   $0x8033c8
  802212:	6a 7d                	push   $0x7d
  802214:	68 53 39 80 00       	push   $0x803953
  802219:	e8 f2 e7 ff ff       	call   800a10 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80221e:	83 ec 04             	sub    $0x4,%esp
  802221:	50                   	push   %eax
  802222:	68 00 60 80 00       	push   $0x806000
  802227:	ff 75 0c             	pushl  0xc(%ebp)
  80222a:	e8 25 f0 ff ff       	call   801254 <memmove>
  80222f:	83 c4 10             	add    $0x10,%esp
	return r;
}
  802232:	89 d8                	mov    %ebx,%eax
  802234:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	c9                   	leave  
  80223a:	c3                   	ret    

0080223b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	56                   	push   %esi
  80223f:	53                   	push   %ebx
  802240:	83 ec 1c             	sub    $0x1c,%esp
  802243:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802246:	56                   	push   %esi
  802247:	e8 68 ee ff ff       	call   8010b4 <strlen>
  80224c:	83 c4 10             	add    $0x10,%esp
  80224f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802254:	7e 07                	jle    80225d <open+0x22>
  802256:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80225b:	eb 63                	jmp    8022c0 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80225d:	83 ec 0c             	sub    $0xc,%esp
  802260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802263:	50                   	push   %eax
  802264:	e8 63 f8 ff ff       	call   801acc <fd_alloc>
  802269:	89 c3                	mov    %eax,%ebx
  80226b:	83 c4 10             	add    $0x10,%esp
  80226e:	85 c0                	test   %eax,%eax
  802270:	78 4e                	js     8022c0 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802272:	83 ec 08             	sub    $0x8,%esp
  802275:	56                   	push   %esi
  802276:	68 00 60 80 00       	push   $0x806000
  80227b:	e8 67 ee ff ff       	call   8010e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802280:	8b 45 0c             	mov    0xc(%ebp),%eax
  802283:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802288:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80228b:	b8 01 00 00 00       	mov    $0x1,%eax
  802290:	e8 9b fd ff ff       	call   802030 <fsipc>
  802295:	89 c3                	mov    %eax,%ebx
  802297:	83 c4 10             	add    $0x10,%esp
  80229a:	85 c0                	test   %eax,%eax
  80229c:	79 12                	jns    8022b0 <open+0x75>
		fd_close(fd, 0);
  80229e:	83 ec 08             	sub    $0x8,%esp
  8022a1:	6a 00                	push   $0x0
  8022a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a6:	e8 81 fb ff ff       	call   801e2c <fd_close>
		return r;
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	eb 10                	jmp    8022c0 <open+0x85>
	}

	return fd2num(fd);
  8022b0:	83 ec 0c             	sub    $0xc,%esp
  8022b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b6:	e8 e9 f7 ff ff       	call   801aa4 <fd2num>
  8022bb:	89 c3                	mov    %eax,%ebx
  8022bd:	83 c4 10             	add    $0x10,%esp
}
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c5:	5b                   	pop    %ebx
  8022c6:	5e                   	pop    %esi
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    
  8022c9:	00 00                	add    %al,(%eax)
	...

008022cc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	53                   	push   %ebx
  8022d0:	83 ec 04             	sub    $0x4,%esp
  8022d3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8022d5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8022d9:	7e 2c                	jle    802307 <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8022db:	83 ec 04             	sub    $0x4,%esp
  8022de:	ff 70 04             	pushl  0x4(%eax)
  8022e1:	8d 40 10             	lea    0x10(%eax),%eax
  8022e4:	50                   	push   %eax
  8022e5:	ff 33                	pushl  (%ebx)
  8022e7:	e8 f0 f9 ff ff       	call   801cdc <write>
		if (result > 0)
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	7e 03                	jle    8022f6 <writebuf+0x2a>
			b->result += result;
  8022f3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8022f6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022f9:	74 0c                	je     802307 <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  8022fb:	85 c0                	test   %eax,%eax
  8022fd:	7e 05                	jle    802304 <writebuf+0x38>
  8022ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802304:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802307:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80230a:	c9                   	leave  
  80230b:	c3                   	ret    

0080230c <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80230c:	55                   	push   %ebp
  80230d:	89 e5                	mov    %esp,%ebp
  80230f:	53                   	push   %ebx
  802310:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  80231f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802326:	00 00 00 
	b.result = 0;
  802329:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  802330:	00 00 00 
	b.error = 1;
  802333:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  80233a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80233d:	ff 75 10             	pushl  0x10(%ebp)
  802340:	ff 75 0c             	pushl  0xc(%ebp)
  802343:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  802349:	53                   	push   %ebx
  80234a:	68 af 23 80 00       	push   $0x8023af
  80234f:	e8 b0 e8 ff ff       	call   800c04 <vprintfmt>
	if (b.idx > 0)
  802354:	83 c4 10             	add    $0x10,%esp
  802357:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  80235e:	7e 07                	jle    802367 <vfprintf+0x5b>
		writebuf(&b);
  802360:	89 d8                	mov    %ebx,%eax
  802362:	e8 65 ff ff ff       	call   8022cc <writebuf>

	return (b.result ? b.result : b.error);
  802367:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80236d:	85 c0                	test   %eax,%eax
  80236f:	75 06                	jne    802377 <vfprintf+0x6b>
  802371:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  802377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80237a:	c9                   	leave  
  80237b:	c3                   	ret    

0080237c <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  80237c:	55                   	push   %ebp
  80237d:	89 e5                	mov    %esp,%ebp
  80237f:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802382:	8d 45 0c             	lea    0xc(%ebp),%eax
  802385:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  802388:	50                   	push   %eax
  802389:	ff 75 08             	pushl  0x8(%ebp)
  80238c:	6a 01                	push   $0x1
  80238e:	e8 79 ff ff ff       	call   80230c <vfprintf>
	va_end(ap);

	return cnt;
}
  802393:	c9                   	leave  
  802394:	c3                   	ret    

00802395 <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  802395:	55                   	push   %ebp
  802396:	89 e5                	mov    %esp,%ebp
  802398:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80239b:	8d 45 10             	lea    0x10(%ebp),%eax
  80239e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  8023a1:	50                   	push   %eax
  8023a2:	ff 75 0c             	pushl  0xc(%ebp)
  8023a5:	ff 75 08             	pushl  0x8(%ebp)
  8023a8:	e8 5f ff ff ff       	call   80230c <vfprintf>
	va_end(ap);

	return cnt;
}
  8023ad:	c9                   	leave  
  8023ae:	c3                   	ret    

008023af <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	53                   	push   %ebx
  8023b3:	83 ec 04             	sub    $0x4,%esp
  8023b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023b9:	8b 43 04             	mov    0x4(%ebx),%eax
  8023bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8023bf:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  8023c3:	40                   	inc    %eax
  8023c4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8023c7:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023cc:	75 0e                	jne    8023dc <putch+0x2d>
		writebuf(b);
  8023ce:	89 d8                	mov    %ebx,%eax
  8023d0:	e8 f7 fe ff ff       	call   8022cc <writebuf>
		b->idx = 0;
  8023d5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023dc:	83 c4 04             	add    $0x4,%esp
  8023df:	5b                   	pop    %ebx
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    
	...

008023e4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	57                   	push   %edi
  8023e8:	56                   	push   %esi
  8023e9:	53                   	push   %ebx
  8023ea:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8023f0:	6a 00                	push   $0x0
  8023f2:	ff 75 08             	pushl  0x8(%ebp)
  8023f5:	e8 41 fe ff ff       	call   80223b <open>
  8023fa:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	85 c0                	test   %eax,%eax
  802405:	79 0b                	jns    802412 <spawn+0x2e>
  802407:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  80240d:	e9 13 05 00 00       	jmp    802925 <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802412:	83 ec 04             	sub    $0x4,%esp
  802415:	68 00 02 00 00       	push   $0x200
  80241a:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  802420:	50                   	push   %eax
  802421:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  802427:	e8 b9 f9 ff ff       	call   801de5 <readn>
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	3d 00 02 00 00       	cmp    $0x200,%eax
  802434:	75 0c                	jne    802442 <spawn+0x5e>
  802436:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  80243d:	45 4c 46 
  802440:	74 38                	je     80247a <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  802442:	83 ec 0c             	sub    $0xc,%esp
  802445:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  80244b:	e8 64 fa ff ff       	call   801eb4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802450:	83 c4 0c             	add    $0xc,%esp
  802453:	68 7f 45 4c 46       	push   $0x464c457f
  802458:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  80245e:	68 6a 39 80 00       	push   $0x80396a
  802463:	e8 49 e6 ff ff       	call   800ab1 <cprintf>
  802468:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  80246f:	ff ff ff 
		return -E_NOT_EXEC;
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	e9 ab 04 00 00       	jmp    802925 <spawn+0x541>
  80247a:	ba 07 00 00 00       	mov    $0x7,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	cd 30                	int    $0x30
  802483:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802489:	85 c0                	test   %eax,%eax
  80248b:	0f 88 94 04 00 00    	js     802925 <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802491:	25 ff 03 00 00       	and    $0x3ff,%eax
  802496:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80249d:	c1 e0 07             	shl    $0x7,%eax
  8024a0:	29 d0                	sub    %edx,%eax
  8024a2:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  8024a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ad:	83 ec 04             	sub    $0x4,%esp
  8024b0:	6a 44                	push   $0x44
  8024b2:	50                   	push   %eax
  8024b3:	52                   	push   %edx
  8024b4:	e8 09 ee ff ff       	call   8012c2 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  8024b9:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  8024bf:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  8024c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024ca:	be 00 00 00 00       	mov    $0x0,%esi
  8024cf:	83 c4 10             	add    $0x10,%esp
  8024d2:	eb 11                	jmp    8024e5 <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8024d4:	83 ec 0c             	sub    $0xc,%esp
  8024d7:	50                   	push   %eax
  8024d8:	e8 d7 eb ff ff       	call   8010b4 <strlen>
  8024dd:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024e1:	46                   	inc    %esi
  8024e2:	83 c4 10             	add    $0x10,%esp
  8024e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024e8:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	75 e5                	jne    8024d4 <spawn+0xf0>
  8024ef:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8024f5:	89 f1                	mov    %esi,%ecx
  8024f7:	c1 e1 02             	shl    $0x2,%ecx
  8024fa:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802500:	b8 00 10 40 00       	mov    $0x401000,%eax
  802505:	89 c7                	mov    %eax,%edi
  802507:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802509:	89 f8                	mov    %edi,%eax
  80250b:	83 e0 fc             	and    $0xfffffffc,%eax
  80250e:	29 c8                	sub    %ecx,%eax
  802510:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  802516:	83 e8 04             	sub    $0x4,%eax
  802519:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80251f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802525:	83 e8 0c             	sub    $0xc,%eax
  802528:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80252d:	0f 86 c1 03 00 00    	jbe    8028f4 <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802533:	83 ec 04             	sub    $0x4,%esp
  802536:	6a 07                	push   $0x7
  802538:	68 00 00 40 00       	push   $0x400000
  80253d:	6a 00                	push   $0x0
  80253f:	e8 b9 f0 ff ff       	call   8015fd <sys_page_alloc>
  802544:	83 c4 10             	add    $0x10,%esp
  802547:	85 c0                	test   %eax,%eax
  802549:	0f 88 aa 03 00 00    	js     8028f9 <spawn+0x515>
  80254f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802554:	eb 35                	jmp    80258b <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802556:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80255c:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  802562:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802566:	83 ec 08             	sub    $0x8,%esp
  802569:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256c:	ff 34 99             	pushl  (%ecx,%ebx,4)
  80256f:	57                   	push   %edi
  802570:	e8 72 eb ff ff       	call   8010e7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802575:	83 c4 04             	add    $0x4,%esp
  802578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80257b:	ff 34 98             	pushl  (%eax,%ebx,4)
  80257e:	e8 31 eb ff ff       	call   8010b4 <strlen>
  802583:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802587:	43                   	inc    %ebx
  802588:	83 c4 10             	add    $0x10,%esp
  80258b:	39 f3                	cmp    %esi,%ebx
  80258d:	7c c7                	jl     802556 <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80258f:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  802595:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80259b:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8025a2:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8025a8:	74 19                	je     8025c3 <spawn+0x1df>
  8025aa:	68 c8 39 80 00       	push   $0x8039c8
  8025af:	68 c8 33 80 00       	push   $0x8033c8
  8025b4:	68 f2 00 00 00       	push   $0xf2
  8025b9:	68 84 39 80 00       	push   $0x803984
  8025be:	e8 4d e4 ff ff       	call   800a10 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8025c3:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8025c9:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8025ce:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  8025d4:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8025d7:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  8025dd:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  8025e0:	89 d0                	mov    %edx,%eax
  8025e2:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8025e7:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8025ed:	83 ec 0c             	sub    $0xc,%esp
  8025f0:	6a 07                	push   $0x7
  8025f2:	68 00 d0 bf ee       	push   $0xeebfd000
  8025f7:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8025fd:	68 00 00 40 00       	push   $0x400000
  802602:	6a 00                	push   $0x0
  802604:	e8 b2 ef ff ff       	call   8015bb <sys_page_map>
  802609:	89 c3                	mov    %eax,%ebx
  80260b:	83 c4 20             	add    $0x20,%esp
  80260e:	85 c0                	test   %eax,%eax
  802610:	78 1c                	js     80262e <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802612:	83 ec 08             	sub    $0x8,%esp
  802615:	68 00 00 40 00       	push   $0x400000
  80261a:	6a 00                	push   $0x0
  80261c:	e8 58 ef ff ff       	call   801579 <sys_page_unmap>
  802621:	89 c3                	mov    %eax,%ebx
  802623:	83 c4 10             	add    $0x10,%esp
  802626:	85 c0                	test   %eax,%eax
  802628:	0f 89 d3 02 00 00    	jns    802901 <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80262e:	83 ec 08             	sub    $0x8,%esp
  802631:	68 00 00 40 00       	push   $0x400000
  802636:	6a 00                	push   $0x0
  802638:	e8 3c ef ff ff       	call   801579 <sys_page_unmap>
  80263d:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  802643:	83 c4 10             	add    $0x10,%esp
  802646:	e9 da 02 00 00       	jmp    802925 <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80264b:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  802651:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  802655:	0f 85 79 01 00 00    	jne    8027d4 <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80265b:	8b 42 f8             	mov    -0x8(%edx),%eax
  80265e:	83 e0 02             	and    $0x2,%eax
  802661:	83 f8 01             	cmp    $0x1,%eax
  802664:	19 c0                	sbb    %eax,%eax
  802666:	83 e0 fe             	and    $0xfffffffe,%eax
  802669:	83 c0 07             	add    $0x7,%eax
  80266c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802672:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  802675:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  80267b:	8b 42 f0             	mov    -0x10(%edx),%eax
  80267e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802684:	8b 4a f4             	mov    -0xc(%edx),%ecx
  802687:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  80268d:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802690:	89 c2                	mov    %eax,%edx
  802692:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802698:	74 16                	je     8026b0 <spawn+0x2cc>
		va -= i;
  80269a:	29 d0                	sub    %edx,%eax
		memsz += i;
  80269c:	01 d1                	add    %edx,%ecx
  80269e:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  8026a4:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  8026aa:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  8026b0:	89 c7                	mov    %eax,%edi
  8026b2:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  8026b9:	00 00 00 
  8026bc:	e9 01 01 00 00       	jmp    8027c2 <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  8026c1:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8026c7:	77 27                	ja     8026f0 <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8026c9:	83 ec 04             	sub    $0x4,%esp
  8026cc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026d2:	57                   	push   %edi
  8026d3:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8026d9:	e8 1f ef ff ff       	call   8015fd <sys_page_alloc>
  8026de:	89 c3                	mov    %eax,%ebx
  8026e0:	83 c4 10             	add    $0x10,%esp
  8026e3:	85 c0                	test   %eax,%eax
  8026e5:	0f 89 c7 00 00 00    	jns    8027b2 <spawn+0x3ce>
  8026eb:	e9 dd 01 00 00       	jmp    8028cd <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026f0:	83 ec 04             	sub    $0x4,%esp
  8026f3:	6a 07                	push   $0x7
  8026f5:	68 00 00 40 00       	push   $0x400000
  8026fa:	6a 00                	push   $0x0
  8026fc:	e8 fc ee ff ff       	call   8015fd <sys_page_alloc>
  802701:	89 c3                	mov    %eax,%ebx
  802703:	83 c4 10             	add    $0x10,%esp
  802706:	85 c0                	test   %eax,%eax
  802708:	0f 88 bf 01 00 00    	js     8028cd <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80270e:	83 ec 08             	sub    $0x8,%esp
  802711:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  802717:	8d 04 16             	lea    (%esi,%edx,1),%eax
  80271a:	50                   	push   %eax
  80271b:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  802721:	e8 40 f4 ff ff       	call   801b66 <seek>
  802726:	89 c3                	mov    %eax,%ebx
  802728:	83 c4 10             	add    $0x10,%esp
  80272b:	85 c0                	test   %eax,%eax
  80272d:	0f 88 9a 01 00 00    	js     8028cd <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802733:	83 ec 04             	sub    $0x4,%esp
  802736:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  80273c:	29 f0                	sub    %esi,%eax
  80273e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802743:	76 05                	jbe    80274a <spawn+0x366>
  802745:	b8 00 10 00 00       	mov    $0x1000,%eax
  80274a:	50                   	push   %eax
  80274b:	68 00 00 40 00       	push   $0x400000
  802750:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  802756:	e8 8a f6 ff ff       	call   801de5 <readn>
  80275b:	89 c3                	mov    %eax,%ebx
  80275d:	83 c4 10             	add    $0x10,%esp
  802760:	85 c0                	test   %eax,%eax
  802762:	0f 88 65 01 00 00    	js     8028cd <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802768:	83 ec 0c             	sub    $0xc,%esp
  80276b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802771:	57                   	push   %edi
  802772:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  802778:	68 00 00 40 00       	push   $0x400000
  80277d:	6a 00                	push   $0x0
  80277f:	e8 37 ee ff ff       	call   8015bb <sys_page_map>
  802784:	83 c4 20             	add    $0x20,%esp
  802787:	85 c0                	test   %eax,%eax
  802789:	79 15                	jns    8027a0 <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  80278b:	50                   	push   %eax
  80278c:	68 90 39 80 00       	push   $0x803990
  802791:	68 25 01 00 00       	push   $0x125
  802796:	68 84 39 80 00       	push   $0x803984
  80279b:	e8 70 e2 ff ff       	call   800a10 <_panic>
			sys_page_unmap(0, UTEMP);
  8027a0:	83 ec 08             	sub    $0x8,%esp
  8027a3:	68 00 00 40 00       	push   $0x400000
  8027a8:	6a 00                	push   $0x0
  8027aa:	e8 ca ed ff ff       	call   801579 <sys_page_unmap>
  8027af:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027b2:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  8027b9:	10 00 00 
  8027bc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8027c2:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  8027c8:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  8027ce:	0f 87 ed fe ff ff    	ja     8026c1 <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027d4:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  8027da:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  8027e1:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  8027e8:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  8027ee:	0f 8c 57 fe ff ff    	jl     80264b <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8027f4:	83 ec 0c             	sub    $0xc,%esp
  8027f7:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8027fd:	e8 b2 f6 ff ff       	call   801eb4 <close>
  802802:	bb 00 00 80 00       	mov    $0x800000,%ebx
  802807:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  80280a:	89 d8                	mov    %ebx,%eax
  80280c:	c1 e8 16             	shr    $0x16,%eax
  80280f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802816:	a8 01                	test   $0x1,%al
  802818:	74 3e                	je     802858 <spawn+0x474>
  80281a:	89 da                	mov    %ebx,%edx
  80281c:	c1 ea 0c             	shr    $0xc,%edx
  80281f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802826:	a8 01                	test   $0x1,%al
  802828:	74 2e                	je     802858 <spawn+0x474>
  80282a:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802831:	f6 c4 04             	test   $0x4,%ah
  802834:	74 22                	je     802858 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  802836:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80283d:	83 ec 0c             	sub    $0xc,%esp
  802840:	25 07 0e 00 00       	and    $0xe07,%eax
  802845:	50                   	push   %eax
  802846:	53                   	push   %ebx
  802847:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  80284d:	53                   	push   %ebx
  80284e:	6a 00                	push   $0x0
  802850:	e8 66 ed ff ff       	call   8015bb <sys_page_map>
  802855:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  802858:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80285e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  802864:	75 a4                	jne    80280a <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802866:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  80286d:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802870:	83 ec 08             	sub    $0x8,%esp
  802873:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  802879:	50                   	push   %eax
  80287a:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  802880:	e8 70 ec ff ff       	call   8014f5 <sys_env_set_trapframe>
  802885:	83 c4 10             	add    $0x10,%esp
  802888:	85 c0                	test   %eax,%eax
  80288a:	79 15                	jns    8028a1 <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  80288c:	50                   	push   %eax
  80288d:	68 ad 39 80 00       	push   $0x8039ad
  802892:	68 86 00 00 00       	push   $0x86
  802897:	68 84 39 80 00       	push   $0x803984
  80289c:	e8 6f e1 ff ff       	call   800a10 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8028a1:	83 ec 08             	sub    $0x8,%esp
  8028a4:	6a 02                	push   $0x2
  8028a6:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8028ac:	e8 86 ec ff ff       	call   801537 <sys_env_set_status>
  8028b1:	83 c4 10             	add    $0x10,%esp
  8028b4:	85 c0                	test   %eax,%eax
  8028b6:	79 6d                	jns    802925 <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  8028b8:	50                   	push   %eax
  8028b9:	68 cc 37 80 00       	push   $0x8037cc
  8028be:	68 89 00 00 00       	push   $0x89
  8028c3:	68 84 39 80 00       	push   $0x803984
  8028c8:	e8 43 e1 ff ff       	call   800a10 <_panic>

	return child;

error:
	sys_env_destroy(child);
  8028cd:	83 ec 0c             	sub    $0xc,%esp
  8028d0:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  8028d6:	e8 a3 ed ff ff       	call   80167e <sys_env_destroy>
	close(fd);
  8028db:	83 c4 04             	add    $0x4,%esp
  8028de:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  8028e4:	e8 cb f5 ff ff       	call   801eb4 <close>
  8028e9:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  8028ef:	83 c4 10             	add    $0x10,%esp
  8028f2:	eb 31                	jmp    802925 <spawn+0x541>
  8028f4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8028f9:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  8028ff:	eb 24                	jmp    802925 <spawn+0x541>
  802901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802904:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  80290a:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  802910:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  802916:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  80291d:	00 00 00 
  802920:	e9 bc fe ff ff       	jmp    8027e1 <spawn+0x3fd>
	return r;
}
  802925:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  80292b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80292e:	5b                   	pop    %ebx
  80292f:	5e                   	pop    %esi
  802930:	5f                   	pop    %edi
  802931:	c9                   	leave  
  802932:	c3                   	ret    

00802933 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802933:	55                   	push   %ebp
  802934:	89 e5                	mov    %esp,%ebp
  802936:	57                   	push   %edi
  802937:	56                   	push   %esi
  802938:	53                   	push   %ebx
  802939:	83 ec 1c             	sub    $0x1c,%esp
  80293c:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80293e:	8d 45 10             	lea    0x10(%ebp),%eax
  802941:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802944:	be 00 00 00 00       	mov    $0x0,%esi
  802949:	eb 01                	jmp    80294c <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  80294b:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80294c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80294f:	8d 42 04             	lea    0x4(%edx),%eax
  802952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802955:	83 3a 00             	cmpl   $0x0,(%edx)
  802958:	75 f1                	jne    80294b <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80295a:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  802961:	83 e0 f0             	and    $0xfffffff0,%eax
  802964:	29 c4                	sub    %eax,%esp
  802966:	8d 44 24 0f          	lea    0xf(%esp),%eax
  80296a:	89 c3                	mov    %eax,%ebx
  80296c:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  80296f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802972:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  802974:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  80297b:	00 

	va_start(vl, arg0);
  80297c:	8d 45 10             	lea    0x10(%ebp),%eax
  80297f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802982:	b9 00 00 00 00       	mov    $0x0,%ecx
  802987:	eb 0f                	jmp    802998 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  802989:	41                   	inc    %ecx
  80298a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80298d:	8d 50 04             	lea    0x4(%eax),%edx
  802990:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802993:	8b 00                	mov    (%eax),%eax
  802995:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802998:	39 f1                	cmp    %esi,%ecx
  80299a:	75 ed                	jne    802989 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80299c:	83 ec 08             	sub    $0x8,%esp
  80299f:	53                   	push   %ebx
  8029a0:	ff 75 08             	pushl  0x8(%ebp)
  8029a3:	e8 3c fa ff ff       	call   8023e4 <spawn>
  8029a8:	89 fc                	mov    %edi,%esp
}
  8029aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029ad:	5b                   	pop    %ebx
  8029ae:	5e                   	pop    %esi
  8029af:	5f                   	pop    %edi
  8029b0:	c9                   	leave  
  8029b1:	c3                   	ret    
	...

008029b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8029b4:	55                   	push   %ebp
  8029b5:	89 e5                	mov    %esp,%ebp
  8029b7:	56                   	push   %esi
  8029b8:	53                   	push   %ebx
  8029b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8029bc:	83 ec 0c             	sub    $0xc,%esp
  8029bf:	ff 75 08             	pushl  0x8(%ebp)
  8029c2:	e8 ed f0 ff ff       	call   801ab4 <fd2data>
  8029c7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8029c9:	83 c4 08             	add    $0x8,%esp
  8029cc:	68 ee 39 80 00       	push   $0x8039ee
  8029d1:	53                   	push   %ebx
  8029d2:	e8 10 e7 ff ff       	call   8010e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8029d7:	8b 46 04             	mov    0x4(%esi),%eax
  8029da:	2b 06                	sub    (%esi),%eax
  8029dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8029e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8029e9:	00 00 00 
	stat->st_dev = &devpipe;
  8029ec:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8029f3:	40 80 00 
	return 0;
}
  8029f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8029fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029fe:	5b                   	pop    %ebx
  8029ff:	5e                   	pop    %esi
  802a00:	c9                   	leave  
  802a01:	c3                   	ret    

00802a02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a02:	55                   	push   %ebp
  802a03:	89 e5                	mov    %esp,%ebp
  802a05:	53                   	push   %ebx
  802a06:	83 ec 0c             	sub    $0xc,%esp
  802a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a0c:	53                   	push   %ebx
  802a0d:	6a 00                	push   $0x0
  802a0f:	e8 65 eb ff ff       	call   801579 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a14:	89 1c 24             	mov    %ebx,(%esp)
  802a17:	e8 98 f0 ff ff       	call   801ab4 <fd2data>
  802a1c:	83 c4 08             	add    $0x8,%esp
  802a1f:	50                   	push   %eax
  802a20:	6a 00                	push   $0x0
  802a22:	e8 52 eb ff ff       	call   801579 <sys_page_unmap>
}
  802a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a2a:	c9                   	leave  
  802a2b:	c3                   	ret    

00802a2c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a2c:	55                   	push   %ebp
  802a2d:	89 e5                	mov    %esp,%ebp
  802a2f:	57                   	push   %edi
  802a30:	56                   	push   %esi
  802a31:	53                   	push   %ebx
  802a32:	83 ec 0c             	sub    $0xc,%esp
  802a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802a38:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a3a:	a1 24 54 80 00       	mov    0x805424,%eax
  802a3f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802a42:	83 ec 0c             	sub    $0xc,%esp
  802a45:	ff 75 f0             	pushl  -0x10(%ebp)
  802a48:	e8 b7 04 00 00       	call   802f04 <pageref>
  802a4d:	89 c3                	mov    %eax,%ebx
  802a4f:	89 3c 24             	mov    %edi,(%esp)
  802a52:	e8 ad 04 00 00       	call   802f04 <pageref>
  802a57:	83 c4 10             	add    $0x10,%esp
  802a5a:	39 c3                	cmp    %eax,%ebx
  802a5c:	0f 94 c0             	sete   %al
  802a5f:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  802a62:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802a68:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  802a6b:	39 c6                	cmp    %eax,%esi
  802a6d:	74 1b                	je     802a8a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  802a6f:	83 f9 01             	cmp    $0x1,%ecx
  802a72:	75 c6                	jne    802a3a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802a74:	8b 42 58             	mov    0x58(%edx),%eax
  802a77:	6a 01                	push   $0x1
  802a79:	50                   	push   %eax
  802a7a:	56                   	push   %esi
  802a7b:	68 f5 39 80 00       	push   $0x8039f5
  802a80:	e8 2c e0 ff ff       	call   800ab1 <cprintf>
  802a85:	83 c4 10             	add    $0x10,%esp
  802a88:	eb b0                	jmp    802a3a <_pipeisclosed+0xe>
	}
}
  802a8a:	89 c8                	mov    %ecx,%eax
  802a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a8f:	5b                   	pop    %ebx
  802a90:	5e                   	pop    %esi
  802a91:	5f                   	pop    %edi
  802a92:	c9                   	leave  
  802a93:	c3                   	ret    

00802a94 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802a94:	55                   	push   %ebp
  802a95:	89 e5                	mov    %esp,%ebp
  802a97:	57                   	push   %edi
  802a98:	56                   	push   %esi
  802a99:	53                   	push   %ebx
  802a9a:	83 ec 18             	sub    $0x18,%esp
  802a9d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802aa0:	56                   	push   %esi
  802aa1:	e8 0e f0 ff ff       	call   801ab4 <fd2data>
  802aa6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  802aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802aae:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  802ab3:	83 c4 10             	add    $0x10,%esp
  802ab6:	eb 40                	jmp    802af8 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  802abd:	eb 40                	jmp    802aff <devpipe_write+0x6b>
  802abf:	89 da                	mov    %ebx,%edx
  802ac1:	89 f0                	mov    %esi,%eax
  802ac3:	e8 64 ff ff ff       	call   802a2c <_pipeisclosed>
  802ac8:	85 c0                	test   %eax,%eax
  802aca:	75 ec                	jne    802ab8 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802acc:	e8 6f eb ff ff       	call   801640 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ad1:	8b 53 04             	mov    0x4(%ebx),%edx
  802ad4:	8b 03                	mov    (%ebx),%eax
  802ad6:	83 c0 20             	add    $0x20,%eax
  802ad9:	39 c2                	cmp    %eax,%edx
  802adb:	73 e2                	jae    802abf <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802add:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802ae3:	79 05                	jns    802aea <devpipe_write+0x56>
  802ae5:	4a                   	dec    %edx
  802ae6:	83 ca e0             	or     $0xffffffe0,%edx
  802ae9:	42                   	inc    %edx
  802aea:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802aed:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  802af0:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802af4:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802af7:	47                   	inc    %edi
  802af8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802afb:	75 d4                	jne    802ad1 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802afd:	89 f8                	mov    %edi,%eax
}
  802aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b02:	5b                   	pop    %ebx
  802b03:	5e                   	pop    %esi
  802b04:	5f                   	pop    %edi
  802b05:	c9                   	leave  
  802b06:	c3                   	ret    

00802b07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b07:	55                   	push   %ebp
  802b08:	89 e5                	mov    %esp,%ebp
  802b0a:	57                   	push   %edi
  802b0b:	56                   	push   %esi
  802b0c:	53                   	push   %ebx
  802b0d:	83 ec 18             	sub    $0x18,%esp
  802b10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b13:	57                   	push   %edi
  802b14:	e8 9b ef ff ff       	call   801ab4 <fd2data>
  802b19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  802b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802b21:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  802b26:	83 c4 10             	add    $0x10,%esp
  802b29:	eb 41                	jmp    802b6c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802b2b:	89 f0                	mov    %esi,%eax
  802b2d:	eb 44                	jmp    802b73 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802b34:	eb 3d                	jmp    802b73 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b36:	85 f6                	test   %esi,%esi
  802b38:	75 f1                	jne    802b2b <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b3a:	89 da                	mov    %ebx,%edx
  802b3c:	89 f8                	mov    %edi,%eax
  802b3e:	e8 e9 fe ff ff       	call   802a2c <_pipeisclosed>
  802b43:	85 c0                	test   %eax,%eax
  802b45:	75 e8                	jne    802b2f <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b47:	e8 f4 ea ff ff       	call   801640 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b4c:	8b 03                	mov    (%ebx),%eax
  802b4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802b51:	74 e3                	je     802b36 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b53:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802b58:	79 05                	jns    802b5f <devpipe_read+0x58>
  802b5a:	48                   	dec    %eax
  802b5b:	83 c8 e0             	or     $0xffffffe0,%eax
  802b5e:	40                   	inc    %eax
  802b5f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802b63:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b66:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  802b69:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b6b:	46                   	inc    %esi
  802b6c:	3b 75 10             	cmp    0x10(%ebp),%esi
  802b6f:	75 db                	jne    802b4c <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b71:	89 f0                	mov    %esi,%eax
}
  802b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b76:	5b                   	pop    %ebx
  802b77:	5e                   	pop    %esi
  802b78:	5f                   	pop    %edi
  802b79:	c9                   	leave  
  802b7a:	c3                   	ret    

00802b7b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802b7b:	55                   	push   %ebp
  802b7c:	89 e5                	mov    %esp,%ebp
  802b7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802b81:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802b84:	50                   	push   %eax
  802b85:	ff 75 08             	pushl  0x8(%ebp)
  802b88:	e8 92 ef ff ff       	call   801b1f <fd_lookup>
  802b8d:	83 c4 10             	add    $0x10,%esp
  802b90:	85 c0                	test   %eax,%eax
  802b92:	78 18                	js     802bac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802b94:	83 ec 0c             	sub    $0xc,%esp
  802b97:	ff 75 fc             	pushl  -0x4(%ebp)
  802b9a:	e8 15 ef ff ff       	call   801ab4 <fd2data>
  802b9f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802ba1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802ba4:	e8 83 fe ff ff       	call   802a2c <_pipeisclosed>
  802ba9:	83 c4 10             	add    $0x10,%esp
}
  802bac:	c9                   	leave  
  802bad:	c3                   	ret    

00802bae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	57                   	push   %edi
  802bb2:	56                   	push   %esi
  802bb3:	53                   	push   %ebx
  802bb4:	83 ec 28             	sub    $0x28,%esp
  802bb7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802bba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bbd:	50                   	push   %eax
  802bbe:	e8 09 ef ff ff       	call   801acc <fd_alloc>
  802bc3:	89 c3                	mov    %eax,%ebx
  802bc5:	83 c4 10             	add    $0x10,%esp
  802bc8:	85 c0                	test   %eax,%eax
  802bca:	0f 88 24 01 00 00    	js     802cf4 <pipe+0x146>
  802bd0:	83 ec 04             	sub    $0x4,%esp
  802bd3:	68 07 04 00 00       	push   $0x407
  802bd8:	ff 75 f0             	pushl  -0x10(%ebp)
  802bdb:	6a 00                	push   $0x0
  802bdd:	e8 1b ea ff ff       	call   8015fd <sys_page_alloc>
  802be2:	89 c3                	mov    %eax,%ebx
  802be4:	83 c4 10             	add    $0x10,%esp
  802be7:	85 c0                	test   %eax,%eax
  802be9:	0f 88 05 01 00 00    	js     802cf4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802bef:	83 ec 0c             	sub    $0xc,%esp
  802bf2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802bf5:	50                   	push   %eax
  802bf6:	e8 d1 ee ff ff       	call   801acc <fd_alloc>
  802bfb:	89 c3                	mov    %eax,%ebx
  802bfd:	83 c4 10             	add    $0x10,%esp
  802c00:	85 c0                	test   %eax,%eax
  802c02:	0f 88 dc 00 00 00    	js     802ce4 <pipe+0x136>
  802c08:	83 ec 04             	sub    $0x4,%esp
  802c0b:	68 07 04 00 00       	push   $0x407
  802c10:	ff 75 ec             	pushl  -0x14(%ebp)
  802c13:	6a 00                	push   $0x0
  802c15:	e8 e3 e9 ff ff       	call   8015fd <sys_page_alloc>
  802c1a:	89 c3                	mov    %eax,%ebx
  802c1c:	83 c4 10             	add    $0x10,%esp
  802c1f:	85 c0                	test   %eax,%eax
  802c21:	0f 88 bd 00 00 00    	js     802ce4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c27:	83 ec 0c             	sub    $0xc,%esp
  802c2a:	ff 75 f0             	pushl  -0x10(%ebp)
  802c2d:	e8 82 ee ff ff       	call   801ab4 <fd2data>
  802c32:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c34:	83 c4 0c             	add    $0xc,%esp
  802c37:	68 07 04 00 00       	push   $0x407
  802c3c:	50                   	push   %eax
  802c3d:	6a 00                	push   $0x0
  802c3f:	e8 b9 e9 ff ff       	call   8015fd <sys_page_alloc>
  802c44:	89 c3                	mov    %eax,%ebx
  802c46:	83 c4 10             	add    $0x10,%esp
  802c49:	85 c0                	test   %eax,%eax
  802c4b:	0f 88 83 00 00 00    	js     802cd4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c51:	83 ec 0c             	sub    $0xc,%esp
  802c54:	ff 75 ec             	pushl  -0x14(%ebp)
  802c57:	e8 58 ee ff ff       	call   801ab4 <fd2data>
  802c5c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802c63:	50                   	push   %eax
  802c64:	6a 00                	push   $0x0
  802c66:	56                   	push   %esi
  802c67:	6a 00                	push   $0x0
  802c69:	e8 4d e9 ff ff       	call   8015bb <sys_page_map>
  802c6e:	89 c3                	mov    %eax,%ebx
  802c70:	83 c4 20             	add    $0x20,%esp
  802c73:	85 c0                	test   %eax,%eax
  802c75:	78 4f                	js     802cc6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c77:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c80:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c8c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c92:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802c95:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802c9a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802ca1:	83 ec 0c             	sub    $0xc,%esp
  802ca4:	ff 75 f0             	pushl  -0x10(%ebp)
  802ca7:	e8 f8 ed ff ff       	call   801aa4 <fd2num>
  802cac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802cae:	83 c4 04             	add    $0x4,%esp
  802cb1:	ff 75 ec             	pushl  -0x14(%ebp)
  802cb4:	e8 eb ed ff ff       	call   801aa4 <fd2num>
  802cb9:	89 47 04             	mov    %eax,0x4(%edi)
  802cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  802cc1:	83 c4 10             	add    $0x10,%esp
  802cc4:	eb 2e                	jmp    802cf4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802cc6:	83 ec 08             	sub    $0x8,%esp
  802cc9:	56                   	push   %esi
  802cca:	6a 00                	push   $0x0
  802ccc:	e8 a8 e8 ff ff       	call   801579 <sys_page_unmap>
  802cd1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802cd4:	83 ec 08             	sub    $0x8,%esp
  802cd7:	ff 75 ec             	pushl  -0x14(%ebp)
  802cda:	6a 00                	push   $0x0
  802cdc:	e8 98 e8 ff ff       	call   801579 <sys_page_unmap>
  802ce1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802ce4:	83 ec 08             	sub    $0x8,%esp
  802ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  802cea:	6a 00                	push   $0x0
  802cec:	e8 88 e8 ff ff       	call   801579 <sys_page_unmap>
  802cf1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802cf4:	89 d8                	mov    %ebx,%eax
  802cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cf9:	5b                   	pop    %ebx
  802cfa:	5e                   	pop    %esi
  802cfb:	5f                   	pop    %edi
  802cfc:	c9                   	leave  
  802cfd:	c3                   	ret    
	...

00802d00 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802d00:	55                   	push   %ebp
  802d01:	89 e5                	mov    %esp,%ebp
  802d03:	56                   	push   %esi
  802d04:	53                   	push   %ebx
  802d05:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802d08:	85 f6                	test   %esi,%esi
  802d0a:	75 16                	jne    802d22 <wait+0x22>
  802d0c:	68 0d 3a 80 00       	push   $0x803a0d
  802d11:	68 c8 33 80 00       	push   $0x8033c8
  802d16:	6a 09                	push   $0x9
  802d18:	68 18 3a 80 00       	push   $0x803a18
  802d1d:	e8 ee dc ff ff       	call   800a10 <_panic>
	e = &envs[ENVX(envid)];
  802d22:	89 f0                	mov    %esi,%eax
  802d24:	25 ff 03 00 00       	and    $0x3ff,%eax
  802d29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802d30:	c1 e0 07             	shl    $0x7,%eax
  802d33:	29 d0                	sub    %edx,%eax
  802d35:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  802d3b:	eb 05                	jmp    802d42 <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  802d3d:	e8 fe e8 ff ff       	call   801640 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d42:	8b 43 48             	mov    0x48(%ebx),%eax
  802d45:	39 c6                	cmp    %eax,%esi
  802d47:	75 07                	jne    802d50 <wait+0x50>
  802d49:	8b 43 54             	mov    0x54(%ebx),%eax
  802d4c:	85 c0                	test   %eax,%eax
  802d4e:	75 ed                	jne    802d3d <wait+0x3d>
		sys_yield();
}
  802d50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d53:	5b                   	pop    %ebx
  802d54:	5e                   	pop    %esi
  802d55:	c9                   	leave  
  802d56:	c3                   	ret    
	...

00802d58 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d58:	55                   	push   %ebp
  802d59:	89 e5                	mov    %esp,%ebp
  802d5b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d5e:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802d65:	75 64                	jne    802dcb <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  802d67:	a1 24 54 80 00       	mov    0x805424,%eax
  802d6c:	8b 40 48             	mov    0x48(%eax),%eax
  802d6f:	83 ec 04             	sub    $0x4,%esp
  802d72:	6a 07                	push   $0x7
  802d74:	68 00 f0 bf ee       	push   $0xeebff000
  802d79:	50                   	push   %eax
  802d7a:	e8 7e e8 ff ff       	call   8015fd <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  802d7f:	83 c4 10             	add    $0x10,%esp
  802d82:	85 c0                	test   %eax,%eax
  802d84:	79 14                	jns    802d9a <set_pgfault_handler+0x42>
  802d86:	83 ec 04             	sub    $0x4,%esp
  802d89:	68 24 3a 80 00       	push   $0x803a24
  802d8e:	6a 22                	push   $0x22
  802d90:	68 8d 3a 80 00       	push   $0x803a8d
  802d95:	e8 76 dc ff ff       	call   800a10 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  802d9a:	a1 24 54 80 00       	mov    0x805424,%eax
  802d9f:	8b 40 48             	mov    0x48(%eax),%eax
  802da2:	83 ec 08             	sub    $0x8,%esp
  802da5:	68 d8 2d 80 00       	push   $0x802dd8
  802daa:	50                   	push   %eax
  802dab:	e8 03 e7 ff ff       	call   8014b3 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  802db0:	83 c4 10             	add    $0x10,%esp
  802db3:	85 c0                	test   %eax,%eax
  802db5:	79 14                	jns    802dcb <set_pgfault_handler+0x73>
  802db7:	83 ec 04             	sub    $0x4,%esp
  802dba:	68 54 3a 80 00       	push   $0x803a54
  802dbf:	6a 25                	push   $0x25
  802dc1:	68 8d 3a 80 00       	push   $0x803a8d
  802dc6:	e8 45 dc ff ff       	call   800a10 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  802dce:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802dd3:	c9                   	leave  
  802dd4:	c3                   	ret    
  802dd5:	00 00                	add    %al,(%eax)
	...

00802dd8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802dd8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802dd9:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802dde:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802de0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  802de3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802de7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802dea:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  802dee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  802df2:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  802df4:	83 c4 08             	add    $0x8,%esp
	popal
  802df7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802df8:	83 c4 04             	add    $0x4,%esp
	popfl
  802dfb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802dfc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  802dfd:	c3                   	ret    
	...

00802e00 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e00:	55                   	push   %ebp
  802e01:	89 e5                	mov    %esp,%ebp
  802e03:	53                   	push   %ebx
  802e04:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802e07:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802e0c:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  802e13:	89 c8                	mov    %ecx,%eax
  802e15:	c1 e0 07             	shl    $0x7,%eax
  802e18:	29 d0                	sub    %edx,%eax
  802e1a:	89 c2                	mov    %eax,%edx
  802e1c:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  802e22:	8b 40 50             	mov    0x50(%eax),%eax
  802e25:	39 d8                	cmp    %ebx,%eax
  802e27:	75 0b                	jne    802e34 <ipc_find_env+0x34>
			return envs[i].env_id;
  802e29:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  802e2f:	8b 40 40             	mov    0x40(%eax),%eax
  802e32:	eb 0e                	jmp    802e42 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802e34:	41                   	inc    %ecx
  802e35:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  802e3b:	75 cf                	jne    802e0c <ipc_find_env+0xc>
  802e3d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802e42:	5b                   	pop    %ebx
  802e43:	c9                   	leave  
  802e44:	c3                   	ret    

00802e45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e45:	55                   	push   %ebp
  802e46:	89 e5                	mov    %esp,%ebp
  802e48:	57                   	push   %edi
  802e49:	56                   	push   %esi
  802e4a:	53                   	push   %ebx
  802e4b:	83 ec 0c             	sub    $0xc,%esp
  802e4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802e54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802e57:	85 db                	test   %ebx,%ebx
  802e59:	75 05                	jne    802e60 <ipc_send+0x1b>
  802e5b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802e60:	56                   	push   %esi
  802e61:	53                   	push   %ebx
  802e62:	57                   	push   %edi
  802e63:	ff 75 08             	pushl  0x8(%ebp)
  802e66:	e8 25 e6 ff ff       	call   801490 <sys_ipc_try_send>
		if (r == 0) {		//success
  802e6b:	83 c4 10             	add    $0x10,%esp
  802e6e:	85 c0                	test   %eax,%eax
  802e70:	74 20                	je     802e92 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  802e72:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e75:	75 07                	jne    802e7e <ipc_send+0x39>
			sys_yield();
  802e77:	e8 c4 e7 ff ff       	call   801640 <sys_yield>
  802e7c:	eb e2                	jmp    802e60 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  802e7e:	83 ec 04             	sub    $0x4,%esp
  802e81:	68 9c 3a 80 00       	push   $0x803a9c
  802e86:	6a 41                	push   $0x41
  802e88:	68 c0 3a 80 00       	push   $0x803ac0
  802e8d:	e8 7e db ff ff       	call   800a10 <_panic>
		}
	}
}
  802e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e95:	5b                   	pop    %ebx
  802e96:	5e                   	pop    %esi
  802e97:	5f                   	pop    %edi
  802e98:	c9                   	leave  
  802e99:	c3                   	ret    

00802e9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e9a:	55                   	push   %ebp
  802e9b:	89 e5                	mov    %esp,%ebp
  802e9d:	56                   	push   %esi
  802e9e:	53                   	push   %ebx
  802e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ea5:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802ea8:	85 c0                	test   %eax,%eax
  802eaa:	75 05                	jne    802eb1 <ipc_recv+0x17>
  802eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  802eb1:	83 ec 0c             	sub    $0xc,%esp
  802eb4:	50                   	push   %eax
  802eb5:	e8 95 e5 ff ff       	call   80144f <sys_ipc_recv>
	if (r < 0) {				
  802eba:	83 c4 10             	add    $0x10,%esp
  802ebd:	85 c0                	test   %eax,%eax
  802ebf:	79 16                	jns    802ed7 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  802ec1:	85 db                	test   %ebx,%ebx
  802ec3:	74 06                	je     802ecb <ipc_recv+0x31>
  802ec5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  802ecb:	85 f6                	test   %esi,%esi
  802ecd:	74 2c                	je     802efb <ipc_recv+0x61>
  802ecf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802ed5:	eb 24                	jmp    802efb <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  802ed7:	85 db                	test   %ebx,%ebx
  802ed9:	74 0a                	je     802ee5 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  802edb:	a1 24 54 80 00       	mov    0x805424,%eax
  802ee0:	8b 40 74             	mov    0x74(%eax),%eax
  802ee3:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  802ee5:	85 f6                	test   %esi,%esi
  802ee7:	74 0a                	je     802ef3 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802ee9:	a1 24 54 80 00       	mov    0x805424,%eax
  802eee:	8b 40 78             	mov    0x78(%eax),%eax
  802ef1:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  802ef3:	a1 24 54 80 00       	mov    0x805424,%eax
  802ef8:	8b 40 70             	mov    0x70(%eax),%eax
}
  802efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802efe:	5b                   	pop    %ebx
  802eff:	5e                   	pop    %esi
  802f00:	c9                   	leave  
  802f01:	c3                   	ret    
	...

00802f04 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f04:	55                   	push   %ebp
  802f05:	89 e5                	mov    %esp,%ebp
  802f07:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f0a:	89 d0                	mov    %edx,%eax
  802f0c:	c1 e8 16             	shr    $0x16,%eax
  802f0f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802f16:	a8 01                	test   $0x1,%al
  802f18:	74 20                	je     802f3a <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f1a:	89 d0                	mov    %edx,%eax
  802f1c:	c1 e8 0c             	shr    $0xc,%eax
  802f1f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802f26:	a8 01                	test   $0x1,%al
  802f28:	74 10                	je     802f3a <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f2a:	c1 e8 0c             	shr    $0xc,%eax
  802f2d:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802f34:	ef 
  802f35:	0f b7 c0             	movzwl %ax,%eax
  802f38:	eb 05                	jmp    802f3f <pageref+0x3b>
  802f3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f3f:	c9                   	leave  
  802f40:	c3                   	ret    
  802f41:	00 00                	add    %al,(%eax)
	...

00802f44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802f44:	55                   	push   %ebp
  802f45:	89 e5                	mov    %esp,%ebp
  802f47:	57                   	push   %edi
  802f48:	56                   	push   %esi
  802f49:	83 ec 28             	sub    $0x28,%esp
  802f4c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  802f53:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802f5a:	8b 45 10             	mov    0x10(%ebp),%eax
  802f5d:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802f60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802f63:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  802f65:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  802f67:	8b 45 08             	mov    0x8(%ebp),%eax
  802f6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  802f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f70:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802f73:	85 ff                	test   %edi,%edi
  802f75:	75 21                	jne    802f98 <__udivdi3+0x54>
    {
      if (d0 > n1)
  802f77:	39 d1                	cmp    %edx,%ecx
  802f79:	76 49                	jbe    802fc4 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f7b:	f7 f1                	div    %ecx
  802f7d:	89 c1                	mov    %eax,%ecx
  802f7f:	31 c0                	xor    %eax,%eax
  802f81:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802f84:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  802f87:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802f8a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802f8d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802f90:	83 c4 28             	add    $0x28,%esp
  802f93:	5e                   	pop    %esi
  802f94:	5f                   	pop    %edi
  802f95:	c9                   	leave  
  802f96:	c3                   	ret    
  802f97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802f98:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802f9b:	0f 87 97 00 00 00    	ja     803038 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802fa1:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802fa4:	83 f0 1f             	xor    $0x1f,%eax
  802fa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802faa:	75 34                	jne    802fe0 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802fac:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  802faf:	72 08                	jb     802fb9 <__udivdi3+0x75>
  802fb1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802fb4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802fb7:	77 7f                	ja     803038 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802fb9:	b9 01 00 00 00       	mov    $0x1,%ecx
  802fbe:	31 c0                	xor    %eax,%eax
  802fc0:	eb c2                	jmp    802f84 <__udivdi3+0x40>
  802fc2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fc7:	85 c0                	test   %eax,%eax
  802fc9:	74 79                	je     803044 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802fcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802fce:	89 fa                	mov    %edi,%edx
  802fd0:	f7 f1                	div    %ecx
  802fd2:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802fd7:	f7 f1                	div    %ecx
  802fd9:	89 c1                	mov    %eax,%ecx
  802fdb:	89 f0                	mov    %esi,%eax
  802fdd:	eb a5                	jmp    802f84 <__udivdi3+0x40>
  802fdf:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802fe0:	b8 20 00 00 00       	mov    $0x20,%eax
  802fe5:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802fe8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802feb:	89 fa                	mov    %edi,%edx
  802fed:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802ff0:	d3 e2                	shl    %cl,%edx
  802ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ff5:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802ff8:	d3 e8                	shr    %cl,%eax
  802ffa:	89 d7                	mov    %edx,%edi
  802ffc:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802ffe:	8b 75 f4             	mov    -0xc(%ebp),%esi
  803001:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803004:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803006:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803009:	d3 e0                	shl    %cl,%eax
  80300b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80300e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  803011:	d3 ea                	shr    %cl,%edx
  803013:	09 d0                	or     %edx,%eax
  803015:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803018:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80301b:	d3 ea                	shr    %cl,%edx
  80301d:	f7 f7                	div    %edi
  80301f:	89 d7                	mov    %edx,%edi
  803021:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  803024:	f7 e6                	mul    %esi
  803026:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803028:	39 d7                	cmp    %edx,%edi
  80302a:	72 38                	jb     803064 <__udivdi3+0x120>
  80302c:	74 27                	je     803055 <__udivdi3+0x111>
  80302e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  803031:	31 c0                	xor    %eax,%eax
  803033:	e9 4c ff ff ff       	jmp    802f84 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803038:	31 c9                	xor    %ecx,%ecx
  80303a:	31 c0                	xor    %eax,%eax
  80303c:	e9 43 ff ff ff       	jmp    802f84 <__udivdi3+0x40>
  803041:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803044:	b8 01 00 00 00       	mov    $0x1,%eax
  803049:	31 d2                	xor    %edx,%edx
  80304b:	f7 75 f4             	divl   -0xc(%ebp)
  80304e:	89 c1                	mov    %eax,%ecx
  803050:	e9 76 ff ff ff       	jmp    802fcb <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803055:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803058:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80305b:	d3 e0                	shl    %cl,%eax
  80305d:	39 f0                	cmp    %esi,%eax
  80305f:	73 cd                	jae    80302e <__udivdi3+0xea>
  803061:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803064:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  803067:	49                   	dec    %ecx
  803068:	31 c0                	xor    %eax,%eax
  80306a:	e9 15 ff ff ff       	jmp    802f84 <__udivdi3+0x40>
	...

00803070 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803070:	55                   	push   %ebp
  803071:	89 e5                	mov    %esp,%ebp
  803073:	57                   	push   %edi
  803074:	56                   	push   %esi
  803075:	83 ec 30             	sub    $0x30,%esp
  803078:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80307f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803086:	8b 75 08             	mov    0x8(%ebp),%esi
  803089:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80308c:	8b 45 10             	mov    0x10(%ebp),%eax
  80308f:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  803092:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803095:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  803097:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  80309a:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  80309d:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030a0:	85 d2                	test   %edx,%edx
  8030a2:	75 1c                	jne    8030c0 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8030a4:	89 fa                	mov    %edi,%edx
  8030a6:	39 f8                	cmp    %edi,%eax
  8030a8:	0f 86 c2 00 00 00    	jbe    803170 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030ae:	89 f0                	mov    %esi,%eax
  8030b0:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8030b2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8030b5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8030bc:	eb 12                	jmp    8030d0 <__umoddi3+0x60>
  8030be:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8030c0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8030c3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8030c6:	76 18                	jbe    8030e0 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8030c8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8030cb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8030ce:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8030d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8030d6:	83 c4 30             	add    $0x30,%esp
  8030d9:	5e                   	pop    %esi
  8030da:	5f                   	pop    %edi
  8030db:	c9                   	leave  
  8030dc:	c3                   	ret    
  8030dd:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8030e0:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8030e4:	83 f0 1f             	xor    $0x1f,%eax
  8030e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8030ea:	0f 84 ac 00 00 00    	je     80319c <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8030f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8030f5:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8030f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8030fb:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8030fe:	8a 4d dc             	mov    -0x24(%ebp),%cl
  803101:	d3 e2                	shl    %cl,%edx
  803103:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803106:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803109:	d3 e8                	shr    %cl,%eax
  80310b:	89 d6                	mov    %edx,%esi
  80310d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80310f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803112:	8a 4d dc             	mov    -0x24(%ebp),%cl
  803115:	d3 e0                	shl    %cl,%eax
  803117:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80311a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  80311d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80311f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803122:	d3 e0                	shl    %cl,%eax
  803124:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803127:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80312a:	d3 ea                	shr    %cl,%edx
  80312c:	09 d0                	or     %edx,%eax
  80312e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803131:	d3 ea                	shr    %cl,%edx
  803133:	f7 f6                	div    %esi
  803135:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  803138:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80313b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80313e:	0f 82 8d 00 00 00    	jb     8031d1 <__umoddi3+0x161>
  803144:	0f 84 91 00 00 00    	je     8031db <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80314a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80314d:	29 c7                	sub    %eax,%edi
  80314f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803151:	89 f2                	mov    %esi,%edx
  803153:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803156:	d3 e2                	shl    %cl,%edx
  803158:	89 f8                	mov    %edi,%eax
  80315a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80315d:	d3 e8                	shr    %cl,%eax
  80315f:	09 c2                	or     %eax,%edx
  803161:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  803164:	d3 ee                	shr    %cl,%esi
  803166:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  803169:	e9 62 ff ff ff       	jmp    8030d0 <__umoddi3+0x60>
  80316e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803170:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803173:	85 c0                	test   %eax,%eax
  803175:	74 15                	je     80318c <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803177:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80317a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80317d:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80317f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803182:	f7 f1                	div    %ecx
  803184:	e9 29 ff ff ff       	jmp    8030b2 <__umoddi3+0x42>
  803189:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80318c:	b8 01 00 00 00       	mov    $0x1,%eax
  803191:	31 d2                	xor    %edx,%edx
  803193:	f7 75 ec             	divl   -0x14(%ebp)
  803196:	89 c1                	mov    %eax,%ecx
  803198:	eb dd                	jmp    803177 <__umoddi3+0x107>
  80319a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80319c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80319f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8031a2:	72 19                	jb     8031bd <__umoddi3+0x14d>
  8031a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031a7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8031aa:	76 11                	jbe    8031bd <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8031ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031af:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8031b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8031b5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8031b8:	e9 13 ff ff ff       	jmp    8030d0 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8031bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8031c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031c3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8031c6:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8031c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8031cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8031cf:	eb db                	jmp    8031ac <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8031d1:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8031d4:	19 f2                	sbb    %esi,%edx
  8031d6:	e9 6f ff ff ff       	jmp    80314a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031db:	39 c7                	cmp    %eax,%edi
  8031dd:	72 f2                	jb     8031d1 <__umoddi3+0x161>
  8031df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8031e2:	e9 63 ff ff ff       	jmp    80314a <__umoddi3+0xda>
