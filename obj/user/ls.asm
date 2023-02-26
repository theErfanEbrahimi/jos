
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <usage>:
	printf("\n");
}

void
usage(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  80003a:	68 40 22 80 00       	push   $0x802240
  80003f:	e8 d8 18 00 00       	call   80191c <printf>
	exit();
  800044:	e8 cf 02 00 00       	call   800318 <exit>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	53                   	push   %ebx
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800058:	8a 45 0c             	mov    0xc(%ebp),%al
  80005b:	88 45 fb             	mov    %al,-0x5(%ebp)
	const char *sep;

	if(flag['l'])
  80005e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800065:	74 1e                	je     800085 <ls1+0x37>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800067:	3c 01                	cmp    $0x1,%al
  800069:	19 c0                	sbb    %eax,%eax
  80006b:	83 e0 c9             	and    $0xffffffc9,%eax
  80006e:	83 c0 64             	add    $0x64,%eax
  800071:	83 ec 04             	sub    $0x4,%esp
  800074:	50                   	push   %eax
  800075:	ff 75 10             	pushl  0x10(%ebp)
  800078:	68 5c 22 80 00       	push   $0x80225c
  80007d:	e8 9a 18 00 00       	call   80191c <printf>
  800082:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800085:	85 db                	test   %ebx,%ebx
  800087:	74 36                	je     8000bf <ls1+0x71>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800089:	80 3b 00             	cmpb   $0x0,(%ebx)
  80008c:	74 1a                	je     8000a8 <ls1+0x5a>
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	53                   	push   %ebx
  800092:	e8 55 08 00 00       	call   8008ec <strlen>
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  80009f:	74 07                	je     8000a8 <ls1+0x5a>
  8000a1:	b8 65 22 80 00       	mov    $0x802265,%eax
  8000a6:	eb 05                	jmp    8000ad <ls1+0x5f>
  8000a8:	b8 5b 22 80 00       	mov    $0x80225b,%eax
			sep = "/";
		else
			sep = "";
		printf("%s%s", prefix, sep);
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	50                   	push   %eax
  8000b1:	53                   	push   %ebx
  8000b2:	68 67 22 80 00       	push   $0x802267
  8000b7:	e8 60 18 00 00       	call   80191c <printf>
  8000bc:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000bf:	83 ec 08             	sub    $0x8,%esp
  8000c2:	ff 75 14             	pushl  0x14(%ebp)
  8000c5:	68 d1 26 80 00       	push   $0x8026d1
  8000ca:	e8 4d 18 00 00       	call   80191c <printf>
	if(flag['F'] && isdir)
  8000cf:	83 c4 10             	add    $0x10,%esp
  8000d2:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000d9:	74 16                	je     8000f1 <ls1+0xa3>
  8000db:	80 7d fb 00          	cmpb   $0x0,-0x5(%ebp)
  8000df:	74 10                	je     8000f1 <ls1+0xa3>
		printf("/");
  8000e1:	83 ec 0c             	sub    $0xc,%esp
  8000e4:	68 65 22 80 00       	push   $0x802265
  8000e9:	e8 2e 18 00 00       	call   80191c <printf>
  8000ee:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	68 5a 22 80 00       	push   $0x80225a
  8000f9:	e8 1e 18 00 00       	call   80191c <printf>
  8000fe:	83 c4 10             	add    $0x10,%esp
}
  800101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800112:	8b 7d 08             	mov    0x8(%ebp),%edi
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800118:	6a 00                	push   $0x0
  80011a:	57                   	push   %edi
  80011b:	e8 bb 16 00 00       	call   8017db <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 43                	jns    80016c <lsdir+0x66>
		panic("open %s: %e", path, fd);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	50                   	push   %eax
  80012d:	57                   	push   %edi
  80012e:	68 6c 22 80 00       	push   $0x80226c
  800133:	6a 1d                	push   $0x1d
  800135:	68 78 22 80 00       	push   $0x802278
  80013a:	e8 ed 01 00 00       	call   80032c <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013f:	80 bd f4 fe ff ff 00 	cmpb   $0x0,-0x10c(%ebp)
  800146:	74 24                	je     80016c <lsdir+0x66>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800148:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
  80014e:	50                   	push   %eax
  80014f:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
  800155:	83 bd 78 ff ff ff 01 	cmpl   $0x1,-0x88(%ebp)
  80015c:	0f 94 c0             	sete   %al
  80015f:	0f b6 c0             	movzbl %al,%eax
  800162:	50                   	push   %eax
  800163:	56                   	push   %esi
  800164:	e8 e5 fe ff ff       	call   80004e <ls1>
  800169:	83 c4 10             	add    $0x10,%esp
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	68 00 01 00 00       	push   $0x100
  800174:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	53                   	push   %ebx
  80017c:	e8 04 12 00 00       	call   801385 <readn>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	3d 00 01 00 00       	cmp    $0x100,%eax
  800189:	74 b4                	je     80013f <lsdir+0x39>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018b:	85 c0                	test   %eax,%eax
  80018d:	7e 12                	jle    8001a1 <lsdir+0x9b>
		panic("short read in directory %s", path);
  80018f:	57                   	push   %edi
  800190:	68 82 22 80 00       	push   $0x802282
  800195:	6a 22                	push   $0x22
  800197:	68 78 22 80 00       	push   $0x802278
  80019c:	e8 8b 01 00 00       	call   80032c <_panic>
	if (n < 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	79 16                	jns    8001bb <lsdir+0xb5>
		panic("error reading directory %s: %e", path, n);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	57                   	push   %edi
  8001aa:	68 ac 22 80 00       	push   $0x8022ac
  8001af:	6a 24                	push   $0x24
  8001b1:	68 78 22 80 00       	push   $0x802278
  8001b6:	e8 71 01 00 00       	call   80032c <_panic>
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	53                   	push   %ebx
  8001c7:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001d0:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  8001d6:	50                   	push   %eax
  8001d7:	53                   	push   %ebx
  8001d8:	e8 a2 12 00 00       	call   80147f <stat>
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	79 16                	jns    8001fa <ls+0x37>
		panic("stat %s: %e", path, r);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	50                   	push   %eax
  8001e8:	53                   	push   %ebx
  8001e9:	68 9d 22 80 00       	push   $0x80229d
  8001ee:	6a 0f                	push   $0xf
  8001f0:	68 78 22 80 00       	push   $0x802278
  8001f5:	e8 32 01 00 00       	call   80032c <_panic>
	if (st.st_isdir && !flag['d'])
  8001fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	74 1a                	je     80021b <ls+0x58>
  800201:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800208:	75 11                	jne    80021b <ls+0x58>
		lsdir(path, prefix);
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	ff 75 0c             	pushl  0xc(%ebp)
  800210:	53                   	push   %ebx
  800211:	e8 f0 fe ff ff       	call   800106 <lsdir>
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
		panic("stat %s: %e", path, r);
	if (st.st_isdir && !flag['d'])
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	eb 17                	jmp    800232 <ls+0x6f>
		lsdir(path, prefix);
	else
		ls1(0, st.st_isdir, st.st_size, path);
  80021b:	53                   	push   %ebx
  80021c:	ff 75 f0             	pushl  -0x10(%ebp)
  80021f:	85 c0                	test   %eax,%eax
  800221:	0f 95 c0             	setne  %al
  800224:	0f b6 c0             	movzbl %al,%eax
  800227:	50                   	push   %eax
  800228:	6a 00                	push   $0x0
  80022a:	e8 1f fe ff ff       	call   80004e <ls1>
  80022f:	83 c4 10             	add    $0x10,%esp
}
  800232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <umain>:
	exit();
}

void
umain(int argc, char **argv)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 14             	sub    $0x14,%esp
  80023f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800242:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	56                   	push   %esi
  800247:	8d 45 08             	lea    0x8(%ebp),%eax
  80024a:	50                   	push   %eax
  80024b:	e8 a8 0c 00 00       	call   800ef8 <argstart>
	while ((i = argnext(&args)) >= 0)
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 1d                	jmp    800272 <umain+0x3b>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x2d>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x2d>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 09                	jne    80026d <umain+0x36>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
  80026b:	eb 05                	jmp    800272 <umain+0x3b>
			break;
		default:
			usage();
  80026d:	e8 c2 fd ff ff       	call   800034 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800278:	50                   	push   %eax
  800279:	e8 35 0d 00 00       	call   800fb3 <argnext>
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	85 c0                	test   %eax,%eax
  800283:	79 d0                	jns    800255 <umain+0x1e>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800285:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800289:	74 07                	je     800292 <umain+0x5b>
  80028b:	bb 01 00 00 00       	mov    $0x1,%ebx
  800290:	eb 28                	jmp    8002ba <umain+0x83>
		ls("/", "");
  800292:	83 ec 08             	sub    $0x8,%esp
  800295:	68 5b 22 80 00       	push   $0x80225b
  80029a:	68 65 22 80 00       	push   $0x802265
  80029f:	e8 1f ff ff ff       	call   8001c3 <ls>
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	eb 16                	jmp    8002bf <umain+0x88>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a9:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	50                   	push   %eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 0d ff ff ff       	call   8001c3 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b6:	43                   	inc    %ebx
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bd:	7c ea                	jl     8002a9 <umain+0x72>
			ls(argv[i], argv[i]);
	}
}
  8002bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    
	...

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  8002d3:	e8 bf 0b 00 00       	call   800e97 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8002d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e4:	c1 e0 07             	shl    $0x7,%eax
  8002e7:	29 d0                	sub    %edx,%eax
  8002e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002ee:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f3:	85 f6                	test   %esi,%esi
  8002f5:	7e 07                	jle    8002fe <libmain+0x36>
		binaryname = argv[0];
  8002f7:	8b 03                	mov    (%ebx),%eax
  8002f9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	53                   	push   %ebx
  800302:	56                   	push   %esi
  800303:	e8 2f ff ff ff       	call   800237 <umain>

	// exit gracefully
	exit();
  800308:	e8 0b 00 00 00       	call   800318 <exit>
  80030d:	83 c4 10             	add    $0x10,%esp
}
  800310:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	c9                   	leave  
  800316:	c3                   	ret    
	...

00800318 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80031e:	6a 00                	push   $0x0
  800320:	e8 91 0b 00 00       	call   800eb6 <sys_env_destroy>
  800325:	83 c4 10             	add    $0x10,%esp
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    
	...

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	53                   	push   %ebx
  800330:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800333:	8d 45 14             	lea    0x14(%ebp),%eax
  800336:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800339:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80033f:	e8 53 0b 00 00       	call   800e97 <sys_getenvid>
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	ff 75 0c             	pushl  0xc(%ebp)
  80034a:	ff 75 08             	pushl  0x8(%ebp)
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	68 d8 22 80 00       	push   $0x8022d8
  800354:	e8 74 00 00 00       	call   8003cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	ff 75 f8             	pushl  -0x8(%ebp)
  80035f:	ff 75 10             	pushl  0x10(%ebp)
  800362:	e8 15 00 00 00       	call   80037c <vcprintf>
	cprintf("\n");
  800367:	c7 04 24 5a 22 80 00 	movl   $0x80225a,(%esp)
  80036e:	e8 5a 00 00 00       	call   8003cd <cprintf>
  800373:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800376:	cc                   	int3   
  800377:	eb fd                	jmp    800376 <_panic+0x4a>
  800379:	00 00                	add    %al,(%eax)
	...

0080037c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800385:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80038c:	00 00 00 
	b.cnt = 0;
  80038f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800396:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800399:	ff 75 0c             	pushl  0xc(%ebp)
  80039c:	ff 75 08             	pushl  0x8(%ebp)
  80039f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a5:	50                   	push   %eax
  8003a6:	68 e4 03 80 00       	push   $0x8003e4
  8003ab:	e8 70 01 00 00       	call   800520 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b0:	83 c4 08             	add    $0x8,%esp
  8003b3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003b9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003bf:	50                   	push   %eax
  8003c0:	e8 9e 08 00 00       	call   800c63 <sys_cputs>
  8003c5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8003d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8003d9:	50                   	push   %eax
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	e8 9a ff ff ff       	call   80037c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 04             	sub    $0x4,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 03                	mov    (%ebx),%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f7:	40                   	inc    %eax
  8003f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 1a                	jne    80041b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	68 ff 00 00 00       	push   $0xff
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	50                   	push   %eax
  80040d:	e8 51 08 00 00       	call   800c63 <sys_cputs>
		b->idx = 0;
  800412:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800418:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80041b:	ff 43 04             	incl   0x4(%ebx)
}
  80041e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800421:	c9                   	leave  
  800422:	c3                   	ret    
	...

00800424 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 1c             	sub    $0x1c,%esp
  80042d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800430:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
  800436:	8b 55 0c             	mov    0xc(%ebp),%edx
  800439:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80043f:	8b 55 10             	mov    0x10(%ebp),%edx
  800442:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800445:	89 d6                	mov    %edx,%esi
  800447:	bf 00 00 00 00       	mov    $0x0,%edi
  80044c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80044f:	72 04                	jb     800455 <printnum+0x31>
  800451:	39 c2                	cmp    %eax,%edx
  800453:	77 3f                	ja     800494 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	ff 75 18             	pushl  0x18(%ebp)
  80045b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80045e:	50                   	push   %eax
  80045f:	52                   	push   %edx
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	57                   	push   %edi
  800464:	56                   	push   %esi
  800465:	ff 75 e4             	pushl  -0x1c(%ebp)
  800468:	ff 75 e0             	pushl  -0x20(%ebp)
  80046b:	e8 20 1b 00 00       	call   801f90 <__udivdi3>
  800470:	83 c4 18             	add    $0x18,%esp
  800473:	52                   	push   %edx
  800474:	50                   	push   %eax
  800475:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800478:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80047b:	e8 a4 ff ff ff       	call   800424 <printnum>
  800480:	83 c4 20             	add    $0x20,%esp
  800483:	eb 14                	jmp    800499 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 e8             	pushl  -0x18(%ebp)
  80048b:	ff 75 18             	pushl  0x18(%ebp)
  80048e:	ff 55 ec             	call   *-0x14(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800494:	4b                   	dec    %ebx
  800495:	85 db                	test   %ebx,%ebx
  800497:	7f ec                	jg     800485 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	ff 75 e8             	pushl  -0x18(%ebp)
  80049f:	83 ec 04             	sub    $0x4,%esp
  8004a2:	57                   	push   %edi
  8004a3:	56                   	push   %esi
  8004a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	e8 0d 1c 00 00       	call   8020bc <__umoddi3>
  8004af:	83 c4 14             	add    $0x14,%esp
  8004b2:	0f be 80 fb 22 80 00 	movsbl 0x8022fb(%eax),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 55 ec             	call   *-0x14(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
}
  8004c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c3:	5b                   	pop    %ebx
  8004c4:	5e                   	pop    %esi
  8004c5:	5f                   	pop    %edi
  8004c6:	c9                   	leave  
  8004c7:	c3                   	ret    

008004c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004cd:	83 fa 01             	cmp    $0x1,%edx
  8004d0:	7e 0e                	jle    8004e0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 42 08             	lea    0x8(%edx),%eax
  8004d7:	89 01                	mov    %eax,(%ecx)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	8b 52 04             	mov    0x4(%edx),%edx
  8004de:	eb 22                	jmp    800502 <getuint+0x3a>
	else if (lflag)
  8004e0:	85 d2                	test   %edx,%edx
  8004e2:	74 10                	je     8004f4 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 42 04             	lea    0x4(%edx),%eax
  8004e9:	89 01                	mov    %eax,(%ecx)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f2:	eb 0e                	jmp    800502 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	8d 42 04             	lea    0x4(%edx),%eax
  8004f9:	89 01                	mov    %eax,(%ecx)
  8004fb:	8b 02                	mov    (%edx),%eax
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80050a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80050d:	8b 11                	mov    (%ecx),%edx
  80050f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800512:	73 0a                	jae    80051e <sprintputch+0x1a>
		*b->buf++ = ch;
  800514:	8b 45 08             	mov    0x8(%ebp),%eax
  800517:	88 02                	mov    %al,(%edx)
  800519:	8d 42 01             	lea    0x1(%edx),%eax
  80051c:	89 01                	mov    %eax,(%ecx)
}
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	57                   	push   %edi
  800524:	56                   	push   %esi
  800525:	53                   	push   %ebx
  800526:	83 ec 3c             	sub    $0x3c,%esp
  800529:	8b 75 08             	mov    0x8(%ebp),%esi
  80052c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80052f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800532:	eb 1a                	jmp    80054e <vprintfmt+0x2e>
  800534:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800537:	eb 15                	jmp    80054e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800539:	84 c0                	test   %al,%al
  80053b:	0f 84 15 03 00 00    	je     800856 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	57                   	push   %edi
  800545:	0f b6 c0             	movzbl %al,%eax
  800548:	50                   	push   %eax
  800549:	ff d6                	call   *%esi
  80054b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054e:	8a 03                	mov    (%ebx),%al
  800550:	43                   	inc    %ebx
  800551:	3c 25                	cmp    $0x25,%al
  800553:	75 e4                	jne    800539 <vprintfmt+0x19>
  800555:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80055c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800563:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80056a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800571:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800575:	eb 0a                	jmp    800581 <vprintfmt+0x61>
  800577:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80057e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8a 03                	mov    (%ebx),%al
  800583:	0f b6 d0             	movzbl %al,%edx
  800586:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800589:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80058c:	83 e8 23             	sub    $0x23,%eax
  80058f:	3c 55                	cmp    $0x55,%al
  800591:	0f 87 9c 02 00 00    	ja     800833 <vprintfmt+0x313>
  800597:	0f b6 c0             	movzbl %al,%eax
  80059a:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  8005a1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005a5:	eb d7                	jmp    80057e <vprintfmt+0x5e>
  8005a7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005ab:	eb d1                	jmp    80057e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005ad:	89 d9                	mov    %ebx,%ecx
  8005af:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005b9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005bc:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005c3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005c7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005c8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005cb:	83 f8 09             	cmp    $0x9,%eax
  8005ce:	77 21                	ja     8005f1 <vprintfmt+0xd1>
  8005d0:	eb e4                	jmp    8005b6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d2:	8b 55 14             	mov    0x14(%ebp),%edx
  8005d5:	8d 42 04             	lea    0x4(%edx),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005db:	8b 12                	mov    (%edx),%edx
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e0:	eb 12                	jmp    8005f4 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	79 96                	jns    80057e <vprintfmt+0x5e>
  8005e8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005ef:	eb 8d                	jmp    80057e <vprintfmt+0x5e>
  8005f1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f8:	79 84                	jns    80057e <vprintfmt+0x5e>
  8005fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800607:	e9 72 ff ff ff       	jmp    80057e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80060c:	ff 45 d4             	incl   -0x2c(%ebp)
  80060f:	e9 6a ff ff ff       	jmp    80057e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800614:	8b 55 14             	mov    0x14(%ebp),%edx
  800617:	8d 42 04             	lea    0x4(%edx),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	ff 32                	pushl  (%edx)
  800623:	ff d6                	call   *%esi
			break;
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	e9 07 ff ff ff       	jmp    800534 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062d:	8b 55 14             	mov    0x14(%ebp),%edx
  800630:	8d 42 04             	lea    0x4(%edx),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
  800636:	8b 02                	mov    (%edx),%eax
  800638:	85 c0                	test   %eax,%eax
  80063a:	79 02                	jns    80063e <vprintfmt+0x11e>
  80063c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063e:	83 f8 0f             	cmp    $0xf,%eax
  800641:	7f 0b                	jg     80064e <vprintfmt+0x12e>
  800643:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	75 15                	jne    800663 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80064e:	50                   	push   %eax
  80064f:	68 0c 23 80 00       	push   $0x80230c
  800654:	57                   	push   %edi
  800655:	56                   	push   %esi
  800656:	e8 6e 02 00 00       	call   8008c9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	e9 d1 fe ff ff       	jmp    800534 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800663:	52                   	push   %edx
  800664:	68 d1 26 80 00       	push   $0x8026d1
  800669:	57                   	push   %edi
  80066a:	56                   	push   %esi
  80066b:	e8 59 02 00 00       	call   8008c9 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	e9 bc fe ff ff       	jmp    800534 <vprintfmt+0x14>
  800678:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80067e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800681:	8b 55 14             	mov    0x14(%ebp),%edx
  800684:	8d 42 04             	lea    0x4(%edx),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
  80068a:	8b 1a                	mov    (%edx),%ebx
  80068c:	85 db                	test   %ebx,%ebx
  80068e:	75 05                	jne    800695 <vprintfmt+0x175>
  800690:	bb 15 23 80 00       	mov    $0x802315,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800695:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800699:	7e 66                	jle    800701 <vprintfmt+0x1e1>
  80069b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80069f:	74 60                	je     800701 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	51                   	push   %ecx
  8006a5:	53                   	push   %ebx
  8006a6:	e8 57 02 00 00       	call   800902 <strnlen>
  8006ab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006ae:	29 c1                	sub    %eax,%ecx
  8006b0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006bd:	eb 0f                	jmp    8006ce <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	57                   	push   %edi
  8006c3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c8:	ff 4d d8             	decl   -0x28(%ebp)
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	7f eb                	jg     8006bf <vprintfmt+0x19f>
  8006d4:	eb 2b                	jmp    800701 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d6:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8006d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006dd:	74 15                	je     8006f4 <vprintfmt+0x1d4>
  8006df:	8d 42 e0             	lea    -0x20(%edx),%eax
  8006e2:	83 f8 5e             	cmp    $0x5e,%eax
  8006e5:	76 0d                	jbe    8006f4 <vprintfmt+0x1d4>
					putch('?', putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	6a 3f                	push   $0x3f
  8006ed:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 0a                	jmp    8006fe <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	57                   	push   %edi
  8006f8:	52                   	push   %edx
  8006f9:	ff d6                	call   *%esi
  8006fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	ff 4d d8             	decl   -0x28(%ebp)
  800701:	8a 03                	mov    (%ebx),%al
  800703:	43                   	inc    %ebx
  800704:	84 c0                	test   %al,%al
  800706:	74 1b                	je     800723 <vprintfmt+0x203>
  800708:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070c:	78 c8                	js     8006d6 <vprintfmt+0x1b6>
  80070e:	ff 4d dc             	decl   -0x24(%ebp)
  800711:	79 c3                	jns    8006d6 <vprintfmt+0x1b6>
  800713:	eb 0e                	jmp    800723 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	57                   	push   %edi
  800719:	6a 20                	push   $0x20
  80071b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071d:	ff 4d d8             	decl   -0x28(%ebp)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800727:	7f ec                	jg     800715 <vprintfmt+0x1f5>
  800729:	e9 06 fe ff ff       	jmp    800534 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800732:	7e 10                	jle    800744 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800734:	8b 55 14             	mov    0x14(%ebp),%edx
  800737:	8d 42 08             	lea    0x8(%edx),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
  80073d:	8b 02                	mov    (%edx),%eax
  80073f:	8b 52 04             	mov    0x4(%edx),%edx
  800742:	eb 20                	jmp    800764 <vprintfmt+0x244>
	else if (lflag)
  800744:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800748:	74 0e                	je     800758 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 50 04             	lea    0x4(%eax),%edx
  800750:	89 55 14             	mov    %edx,0x14(%ebp)
  800753:	8b 00                	mov    (%eax),%eax
  800755:	99                   	cltd   
  800756:	eb 0c                	jmp    800764 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 00                	mov    (%eax),%eax
  800763:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800764:	89 d1                	mov    %edx,%ecx
  800766:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800768:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80076b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80076e:	85 c9                	test   %ecx,%ecx
  800770:	78 0a                	js     80077c <vprintfmt+0x25c>
  800772:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800777:	e9 89 00 00 00       	jmp    800805 <vprintfmt+0x2e5>
				putch('-', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	57                   	push   %edi
  800780:	6a 2d                	push   $0x2d
  800782:	ff d6                	call   *%esi
				num = -(long long) num;
  800784:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800787:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80078a:	f7 da                	neg    %edx
  80078c:	83 d1 00             	adc    $0x0,%ecx
  80078f:	f7 d9                	neg    %ecx
  800791:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 6a                	jmp    800805 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007a1:	e8 22 fd ff ff       	call   8004c8 <getuint>
  8007a6:	89 d1                	mov    %edx,%ecx
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007af:	eb 54                	jmp    800805 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007b7:	e8 0c fd ff ff       	call   8004c8 <getuint>
  8007bc:	89 d1                	mov    %edx,%ecx
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007c5:	eb 3e                	jmp    800805 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	57                   	push   %edi
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	57                   	push   %edi
  8007d3:	6a 78                	push   $0x78
  8007d5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007d7:	8b 55 14             	mov    0x14(%ebp),%edx
  8007da:	8d 42 04             	lea    0x4(%edx),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e0:	8b 12                	mov    (%edx),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ec:	83 c4 10             	add    $0x10,%esp
  8007ef:	eb 14                	jmp    800805 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f7:	e8 cc fc ff ff       	call   8004c8 <getuint>
  8007fc:	89 d1                	mov    %edx,%ecx
  8007fe:	89 c2                	mov    %eax,%edx
  800800:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800805:	83 ec 0c             	sub    $0xc,%esp
  800808:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	ff 75 d8             	pushl  -0x28(%ebp)
  800810:	53                   	push   %ebx
  800811:	51                   	push   %ecx
  800812:	52                   	push   %edx
  800813:	89 fa                	mov    %edi,%edx
  800815:	89 f0                	mov    %esi,%eax
  800817:	e8 08 fc ff ff       	call   800424 <printnum>
			break;
  80081c:	83 c4 20             	add    $0x20,%esp
  80081f:	e9 10 fd ff ff       	jmp    800534 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	57                   	push   %edi
  800828:	52                   	push   %edx
  800829:	ff d6                	call   *%esi
			break;
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	e9 01 fd ff ff       	jmp    800534 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	57                   	push   %edi
  800837:	6a 25                	push   $0x25
  800839:	ff d6                	call   *%esi
  80083b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80083e:	83 ea 02             	sub    $0x2,%edx
  800841:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800844:	8a 02                	mov    (%edx),%al
  800846:	4a                   	dec    %edx
  800847:	3c 25                	cmp    $0x25,%al
  800849:	75 f9                	jne    800844 <vprintfmt+0x324>
  80084b:	83 c2 02             	add    $0x2,%edx
  80084e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800851:	e9 de fc ff ff       	jmp    800534 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800856:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	5f                   	pop    %edi
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 18             	sub    $0x18,%esp
  800864:	8b 55 08             	mov    0x8(%ebp),%edx
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80086a:	85 d2                	test   %edx,%edx
  80086c:	74 37                	je     8008a5 <vsnprintf+0x47>
  80086e:	85 c0                	test   %eax,%eax
  800870:	7e 33                	jle    8008a5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800872:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800879:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80087d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800880:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800883:	ff 75 14             	pushl  0x14(%ebp)
  800886:	ff 75 10             	pushl  0x10(%ebp)
  800889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	68 04 05 80 00       	push   $0x800504
  800892:	e8 89 fc ff ff       	call   800520 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	eb 05                	jmp    8008aa <vsnprintf+0x4c>
  8008a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008b8:	50                   	push   %eax
  8008b9:	ff 75 10             	pushl  0x10(%ebp)
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	ff 75 08             	pushl  0x8(%ebp)
  8008c2:	e8 97 ff ff ff       	call   80085e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8008cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008d5:	50                   	push   %eax
  8008d6:	ff 75 10             	pushl  0x10(%ebp)
  8008d9:	ff 75 0c             	pushl  0xc(%ebp)
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 3c fc ff ff       	call   800520 <vprintfmt>
	va_end(ap);
  8008e4:	83 c4 10             	add    $0x10,%esp
}
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    
  8008e9:	00 00                	add    %al,(%eax)
	...

008008ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	eb 01                	jmp    8008fa <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8008f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fa:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8008fe:	75 f9                	jne    8008f9 <strlen+0xd>
		n++;
	return n;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 01                	jmp    800913 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800912:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	39 d0                	cmp    %edx,%eax
  800915:	74 06                	je     80091d <strnlen+0x1b>
  800917:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80091b:	75 f5                	jne    800912 <strnlen+0x10>
		n++;
	return n;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800925:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800928:	8a 01                	mov    (%ecx),%al
  80092a:	88 02                	mov    %al,(%edx)
  80092c:	42                   	inc    %edx
  80092d:	41                   	inc    %ecx
  80092e:	84 c0                	test   %al,%al
  800930:	75 f6                	jne    800928 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093e:	53                   	push   %ebx
  80093f:	e8 a8 ff ff ff       	call   8008ec <strlen>
	strcpy(dst + len, src);
  800944:	ff 75 0c             	pushl  0xc(%ebp)
  800947:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80094a:	50                   	push   %eax
  80094b:	e8 cf ff ff ff       	call   80091f <strcpy>
	return dst;
}
  800950:	89 d8                	mov    %ebx,%eax
  800952:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 75 08             	mov    0x8(%ebp),%esi
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800962:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800965:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096a:	eb 0c                	jmp    800978 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80096c:	8a 02                	mov    (%edx),%al
  80096e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800971:	80 3a 01             	cmpb   $0x1,(%edx)
  800974:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800977:	41                   	inc    %ecx
  800978:	39 d9                	cmp    %ebx,%ecx
  80097a:	75 f0                	jne    80096c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800990:	85 c9                	test   %ecx,%ecx
  800992:	75 04                	jne    800998 <strlcpy+0x16>
  800994:	89 f0                	mov    %esi,%eax
  800996:	eb 14                	jmp    8009ac <strlcpy+0x2a>
  800998:	89 f0                	mov    %esi,%eax
  80099a:	eb 04                	jmp    8009a0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099c:	88 10                	mov    %dl,(%eax)
  80099e:	40                   	inc    %eax
  80099f:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a0:	49                   	dec    %ecx
  8009a1:	74 06                	je     8009a9 <strlcpy+0x27>
  8009a3:	8a 13                	mov    (%ebx),%dl
  8009a5:	84 d2                	test   %dl,%dl
  8009a7:	75 f3                	jne    80099c <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009a9:	c6 00 00             	movb   $0x0,(%eax)
  8009ac:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bb:	eb 02                	jmp    8009bf <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009bd:	42                   	inc    %edx
  8009be:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bf:	8a 02                	mov    (%edx),%al
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 04                	je     8009c9 <strcmp+0x17>
  8009c5:	3a 01                	cmp    (%ecx),%al
  8009c7:	74 f4                	je     8009bd <strcmp+0xb>
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 11             	movzbl (%ecx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e0:	eb 03                	jmp    8009e5 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009e2:	4a                   	dec    %edx
  8009e3:	41                   	inc    %ecx
  8009e4:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e5:	85 d2                	test   %edx,%edx
  8009e7:	75 07                	jne    8009f0 <strncmp+0x1d>
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	eb 14                	jmp    800a04 <strncmp+0x31>
  8009f0:	8a 01                	mov    (%ecx),%al
  8009f2:	84 c0                	test   %al,%al
  8009f4:	74 04                	je     8009fa <strncmp+0x27>
  8009f6:	3a 03                	cmp    (%ebx),%al
  8009f8:	74 e8                	je     8009e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	0f b6 d0             	movzbl %al,%edx
  8009fd:	0f b6 03             	movzbl (%ebx),%eax
  800a00:	29 c2                	sub    %eax,%edx
  800a02:	89 d0                	mov    %edx,%eax
}
  800a04:	5b                   	pop    %ebx
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a10:	eb 05                	jmp    800a17 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	74 0c                	je     800a22 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a16:	40                   	inc    %eax
  800a17:	8a 10                	mov    (%eax),%dl
  800a19:	84 d2                	test   %dl,%dl
  800a1b:	75 f5                	jne    800a12 <strchr+0xb>
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a2d:	eb 05                	jmp    800a34 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a2f:	38 ca                	cmp    %cl,%dl
  800a31:	74 07                	je     800a3a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a33:	40                   	inc    %eax
  800a34:	8a 10                	mov    (%eax),%dl
  800a36:	84 d2                	test   %dl,%dl
  800a38:	75 f5                	jne    800a2f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	74 36                	je     800a85 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a55:	75 29                	jne    800a80 <memset+0x44>
  800a57:	f6 c3 03             	test   $0x3,%bl
  800a5a:	75 24                	jne    800a80 <memset+0x44>
		c &= 0xFF;
  800a5c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a5f:	89 d6                	mov    %edx,%esi
  800a61:	c1 e6 08             	shl    $0x8,%esi
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	c1 e0 18             	shl    $0x18,%eax
  800a69:	89 d1                	mov    %edx,%ecx
  800a6b:	c1 e1 10             	shl    $0x10,%ecx
  800a6e:	09 c8                	or     %ecx,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	89 f0                	mov    %esi,%eax
  800a74:	09 d0                	or     %edx,%eax
  800a76:	89 d9                	mov    %ebx,%ecx
  800a78:	c1 e9 02             	shr    $0x2,%ecx
  800a7b:	fc                   	cld    
  800a7c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7e:	eb 05                	jmp    800a85 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a80:	89 d9                	mov    %ebx,%ecx
  800a82:	fc                   	cld    
  800a83:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a85:	89 f8                	mov    %edi,%eax
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	c9                   	leave  
  800a8b:	c3                   	ret    

00800a8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a9a:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a9c:	39 c6                	cmp    %eax,%esi
  800a9e:	73 36                	jae    800ad6 <memmove+0x4a>
  800aa0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	73 2f                	jae    800ad6 <memmove+0x4a>
		s += n;
		d += n;
  800aa7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f6 c2 03             	test   $0x3,%dl
  800aad:	75 1b                	jne    800aca <memmove+0x3e>
  800aaf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab5:	75 13                	jne    800aca <memmove+0x3e>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0e                	jne    800aca <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800abc:	8d 7e fc             	lea    -0x4(%esi),%edi
  800abf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fd                   	std    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac8:	eb 09                	jmp    800ad3 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	8d 7e ff             	lea    -0x1(%esi),%edi
  800acd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad0:	fd                   	std    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad3:	fc                   	cld    
  800ad4:	eb 20                	jmp    800af6 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adc:	75 15                	jne    800af3 <memmove+0x67>
  800ade:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae4:	75 0d                	jne    800af3 <memmove+0x67>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 08                	jne    800af3 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af1:	eb 03                	jmp    800af6 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800afd:	ff 75 10             	pushl  0x10(%ebp)
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	ff 75 08             	pushl  0x8(%ebp)
  800b06:	e8 81 ff ff ff       	call   800a8c <memmove>
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	53                   	push   %ebx
  800b11:	83 ec 04             	sub    $0x4,%esp
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	eb 1b                	jmp    800b3a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b1f:	8a 1a                	mov    (%edx),%bl
  800b21:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b24:	8a 19                	mov    (%ecx),%bl
  800b26:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b29:	74 0d                	je     800b38 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b2b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b2f:	0f b6 c3             	movzbl %bl,%eax
  800b32:	29 c2                	sub    %eax,%edx
  800b34:	89 d0                	mov    %edx,%eax
  800b36:	eb 0d                	jmp    800b45 <memcmp+0x38>
		s1++, s2++;
  800b38:	42                   	inc    %edx
  800b39:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	48                   	dec    %eax
  800b3b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b3e:	75 df                	jne    800b1f <memcmp+0x12>
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b45:	83 c4 04             	add    $0x4,%esp
  800b48:	5b                   	pop    %ebx
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b54:	89 c2                	mov    %eax,%edx
  800b56:	03 55 10             	add    0x10(%ebp),%edx
  800b59:	eb 05                	jmp    800b60 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5b:	38 08                	cmp    %cl,(%eax)
  800b5d:	74 05                	je     800b64 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5f:	40                   	inc    %eax
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	72 f7                	jb     800b5b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 04             	sub    $0x4,%esp
  800b6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b72:	8b 75 10             	mov    0x10(%ebp),%esi
  800b75:	eb 01                	jmp    800b78 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800b77:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b78:	8a 01                	mov    (%ecx),%al
  800b7a:	3c 20                	cmp    $0x20,%al
  800b7c:	74 f9                	je     800b77 <strtol+0x11>
  800b7e:	3c 09                	cmp    $0x9,%al
  800b80:	74 f5                	je     800b77 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b82:	3c 2b                	cmp    $0x2b,%al
  800b84:	75 0a                	jne    800b90 <strtol+0x2a>
		s++;
  800b86:	41                   	inc    %ecx
  800b87:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b8e:	eb 17                	jmp    800ba7 <strtol+0x41>
	else if (*s == '-')
  800b90:	3c 2d                	cmp    $0x2d,%al
  800b92:	74 09                	je     800b9d <strtol+0x37>
  800b94:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b9b:	eb 0a                	jmp    800ba7 <strtol+0x41>
		s++, neg = 1;
  800b9d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ba0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	85 f6                	test   %esi,%esi
  800ba9:	74 05                	je     800bb0 <strtol+0x4a>
  800bab:	83 fe 10             	cmp    $0x10,%esi
  800bae:	75 1a                	jne    800bca <strtol+0x64>
  800bb0:	8a 01                	mov    (%ecx),%al
  800bb2:	3c 30                	cmp    $0x30,%al
  800bb4:	75 10                	jne    800bc6 <strtol+0x60>
  800bb6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bba:	75 0a                	jne    800bc6 <strtol+0x60>
		s += 2, base = 16;
  800bbc:	83 c1 02             	add    $0x2,%ecx
  800bbf:	be 10 00 00 00       	mov    $0x10,%esi
  800bc4:	eb 04                	jmp    800bca <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bc6:	85 f6                	test   %esi,%esi
  800bc8:	74 07                	je     800bd1 <strtol+0x6b>
  800bca:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcf:	eb 13                	jmp    800be4 <strtol+0x7e>
  800bd1:	3c 30                	cmp    $0x30,%al
  800bd3:	74 07                	je     800bdc <strtol+0x76>
  800bd5:	be 0a 00 00 00       	mov    $0xa,%esi
  800bda:	eb ee                	jmp    800bca <strtol+0x64>
		s++, base = 8;
  800bdc:	41                   	inc    %ecx
  800bdd:	be 08 00 00 00       	mov    $0x8,%esi
  800be2:	eb e6                	jmp    800bca <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be4:	8a 11                	mov    (%ecx),%dl
  800be6:	88 d3                	mov    %dl,%bl
  800be8:	8d 42 d0             	lea    -0x30(%edx),%eax
  800beb:	3c 09                	cmp    $0x9,%al
  800bed:	77 08                	ja     800bf7 <strtol+0x91>
			dig = *s - '0';
  800bef:	0f be c2             	movsbl %dl,%eax
  800bf2:	8d 50 d0             	lea    -0x30(%eax),%edx
  800bf5:	eb 1c                	jmp    800c13 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bf7:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800bfa:	3c 19                	cmp    $0x19,%al
  800bfc:	77 08                	ja     800c06 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800bfe:	0f be c2             	movsbl %dl,%eax
  800c01:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c04:	eb 0d                	jmp    800c13 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c06:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c09:	3c 19                	cmp    $0x19,%al
  800c0b:	77 15                	ja     800c22 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c0d:	0f be c2             	movsbl %dl,%eax
  800c10:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c13:	39 f2                	cmp    %esi,%edx
  800c15:	7d 0b                	jge    800c22 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c17:	41                   	inc    %ecx
  800c18:	89 f8                	mov    %edi,%eax
  800c1a:	0f af c6             	imul   %esi,%eax
  800c1d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c20:	eb c2                	jmp    800be4 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c22:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c28:	74 05                	je     800c2f <strtol+0xc9>
		*endptr = (char *) s;
  800c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c2f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c33:	74 04                	je     800c39 <strtol+0xd3>
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	f7 df                	neg    %edi
}
  800c39:	89 f8                	mov    %edi,%eax
  800c3b:	83 c4 04             	add    $0x4,%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    
	...

00800c44 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c54:	89 fa                	mov    %edi,%edx
  800c56:	89 f9                	mov    %edi,%ecx
  800c58:	89 fb                	mov    %edi,%ebx
  800c5a:	89 fe                	mov    %edi,%esi
  800c5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 04             	sub    $0x4,%esp
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
  800c77:	89 f8                	mov    %edi,%eax
  800c79:	89 fb                	mov    %edi,%ebx
  800c7b:	89 fe                	mov    %edi,%esi
  800c7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7f:	83 c4 04             	add    $0x4,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c98:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9d:	89 f9                	mov    %edi,%ecx
  800c9f:	89 fb                	mov    %edi,%ebx
  800ca1:	89 fe                	mov    %edi,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 0d                	push   $0xd
  800caf:	68 ff 25 80 00       	push   $0x8025ff
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 1c 26 80 00       	push   $0x80261c
  800cbb:	e8 6c f6 ff ff       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	c9                   	leave  
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd7:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cff:	bf 00 00 00 00       	mov    $0x0,%edi
  800d04:	89 fb                	mov    %edi,%ebx
  800d06:	89 fe                	mov    %edi,%esi
  800d08:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0a                	push   $0xa
  800d14:	68 ff 25 80 00       	push   $0x8025ff
  800d19:	6a 23                	push   $0x23
  800d1b:	68 1c 26 80 00       	push   $0x80261c
  800d20:	e8 07 f6 ff ff       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    

00800d2d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	bf 00 00 00 00       	mov    $0x0,%edi
  800d46:	89 fb                	mov    %edi,%ebx
  800d48:	89 fe                	mov    %edi,%esi
  800d4a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 09                	push   $0x9
  800d56:	68 ff 25 80 00       	push   $0x8025ff
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 1c 26 80 00       	push   $0x80261c
  800d62:	e8 c5 f5 ff ff       	call   80032c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d83:	bf 00 00 00 00       	mov    $0x0,%edi
  800d88:	89 fb                	mov    %edi,%ebx
  800d8a:	89 fe                	mov    %edi,%esi
  800d8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 17                	jle    800da9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 08                	push   $0x8
  800d98:	68 ff 25 80 00       	push   $0x8025ff
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 1c 26 80 00       	push   $0x80261c
  800da4:	e8 83 f5 ff ff       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc5:	bf 00 00 00 00       	mov    $0x0,%edi
  800dca:	89 fb                	mov    %edi,%ebx
  800dcc:	89 fe                	mov    %edi,%esi
  800dce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 17                	jle    800deb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 06                	push   $0x6
  800dda:	68 ff 25 80 00       	push   $0x8025ff
  800ddf:	6a 23                	push   $0x23
  800de1:	68 1c 26 80 00       	push   $0x80261c
  800de6:	e8 41 f5 ff ff       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e08:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 05                	push   $0x5
  800e1c:	68 ff 25 80 00       	push   $0x8025ff
  800e21:	6a 23                	push   $0x23
  800e23:	68 1c 26 80 00       	push   $0x80261c
  800e28:	e8 ff f4 ff ff       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e47:	b8 04 00 00 00       	mov    $0x4,%eax
  800e4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e51:	89 fe                	mov    %edi,%esi
  800e53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7e 17                	jle    800e70 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	83 ec 0c             	sub    $0xc,%esp
  800e5c:	50                   	push   %eax
  800e5d:	6a 04                	push   $0x4
  800e5f:	68 ff 25 80 00       	push   $0x8025ff
  800e64:	6a 23                	push   $0x23
  800e66:	68 1c 26 80 00       	push   $0x80261c
  800e6b:	e8 bc f4 ff ff       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e83:	bf 00 00 00 00       	mov    $0x0,%edi
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	89 f9                	mov    %edi,%ecx
  800e8c:	89 fb                	mov    %edi,%ebx
  800e8e:	89 fe                	mov    %edi,%esi
  800e90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea7:	89 fa                	mov    %edi,%edx
  800ea9:	89 f9                	mov    %edi,%ecx
  800eab:	89 fb                	mov    %edi,%ebx
  800ead:	89 fe                	mov    %edi,%esi
  800eaf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec7:	bf 00 00 00 00       	mov    $0x0,%edi
  800ecc:	89 f9                	mov    %edi,%ecx
  800ece:	89 fb                	mov    %edi,%ebx
  800ed0:	89 fe                	mov    %edi,%esi
  800ed2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 17                	jle    800eef <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	50                   	push   %eax
  800edc:	6a 03                	push   $0x3
  800ede:	68 ff 25 80 00       	push   $0x8025ff
  800ee3:	6a 23                	push   $0x23
  800ee5:	68 1c 26 80 00       	push   $0x80261c
  800eea:	e8 3d f4 ff ff       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    
	...

00800ef8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f01:	8b 55 10             	mov    0x10(%ebp),%edx
	args->argc = argc;
  800f04:	89 02                	mov    %eax,(%edx)
	args->argv = (const char **) argv;
  800f06:	89 4a 04             	mov    %ecx,0x4(%edx)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800f09:	83 38 01             	cmpl   $0x1,(%eax)
  800f0c:	7e 0b                	jle    800f19 <argstart+0x21>
  800f0e:	85 c9                	test   %ecx,%ecx
  800f10:	74 07                	je     800f19 <argstart+0x21>
  800f12:	b8 5b 22 80 00       	mov    $0x80225b,%eax
  800f17:	eb 05                	jmp    800f1e <argstart+0x26>
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	89 42 08             	mov    %eax,0x8(%edx)
	args->argvalue = 0;
  800f21:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800f34:	8b 43 08             	mov    0x8(%ebx),%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	74 55                	je     800f90 <argnextvalue+0x66>
		return 0;
	if (*args->curarg) {
  800f3b:	80 38 00             	cmpb   $0x0,(%eax)
  800f3e:	74 0c                	je     800f4c <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800f40:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f43:	c7 43 08 5b 22 80 00 	movl   $0x80225b,0x8(%ebx)
  800f4a:	eb 41                	jmp    800f8d <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  800f4c:	8b 0b                	mov    (%ebx),%ecx
  800f4e:	83 39 01             	cmpl   $0x1,(%ecx)
  800f51:	7e 2c                	jle    800f7f <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  800f53:	8b 53 04             	mov    0x4(%ebx),%edx
  800f56:	8b 42 04             	mov    0x4(%edx),%eax
  800f59:	89 43 0c             	mov    %eax,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	8b 01                	mov    (%ecx),%eax
  800f61:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800f68:	50                   	push   %eax
  800f69:	8d 42 08             	lea    0x8(%edx),%eax
  800f6c:	50                   	push   %eax
  800f6d:	83 c2 04             	add    $0x4,%edx
  800f70:	52                   	push   %edx
  800f71:	e8 16 fb ff ff       	call   800a8c <memmove>
		(*args->argc)--;
  800f76:	8b 03                	mov    (%ebx),%eax
  800f78:	ff 08                	decl   (%eax)
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	eb 0e                	jmp    800f8d <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  800f7f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f86:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800f8d:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800f90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f9e:	8b 42 0c             	mov    0xc(%edx),%eax
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	75 0c                	jne    800fb1 <argvalue+0x1c>
  800fa5:	83 ec 0c             	sub    $0xc,%esp
  800fa8:	52                   	push   %edx
  800fa9:	e8 7c ff ff ff       	call   800f2a <argnextvalue>
  800fae:	83 c4 10             	add    $0x10,%esp
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <argnext>:
	args->argvalue = 0;
}

int
argnext(struct Argstate *args)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fbb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fc2:	8b 43 08             	mov    0x8(%ebx),%eax
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	75 07                	jne    800fd0 <argnext+0x1d>
  800fc9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800fce:	eb 6a                	jmp    80103a <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fd0:	80 38 00             	cmpb   $0x0,(%eax)
  800fd3:	75 4d                	jne    801022 <argnext+0x6f>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fd5:	8b 03                	mov    (%ebx),%eax
  800fd7:	83 38 01             	cmpl   $0x1,(%eax)
  800fda:	74 52                	je     80102e <argnext+0x7b>
  800fdc:	8b 4b 04             	mov    0x4(%ebx),%ecx
  800fdf:	8b 51 04             	mov    0x4(%ecx),%edx
  800fe2:	80 3a 2d             	cmpb   $0x2d,(%edx)
  800fe5:	75 47                	jne    80102e <argnext+0x7b>
  800fe7:	8d 72 01             	lea    0x1(%edx),%esi
  800fea:	80 7a 01 00          	cmpb   $0x0,0x1(%edx)
  800fee:	74 3e                	je     80102e <argnext+0x7b>
		    || args->argv[1][0] != '-'
		    || args->argv[1][1] == '\0')
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800ff0:	89 73 08             	mov    %esi,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	8b 00                	mov    (%eax),%eax
  800ff8:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800fff:	50                   	push   %eax
  801000:	8d 41 08             	lea    0x8(%ecx),%eax
  801003:	50                   	push   %eax
  801004:	8d 41 04             	lea    0x4(%ecx),%eax
  801007:	50                   	push   %eax
  801008:	e8 7f fa ff ff       	call   800a8c <memmove>
		(*args->argc)--;
  80100d:	8b 03                	mov    (%ebx),%eax
  80100f:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801011:	8b 43 08             	mov    0x8(%ebx),%eax
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	80 38 2d             	cmpb   $0x2d,(%eax)
  80101a:	75 06                	jne    801022 <argnext+0x6f>
  80101c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801020:	74 0c                	je     80102e <argnext+0x7b>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801022:	8b 43 08             	mov    0x8(%ebx),%eax
  801025:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801028:	40                   	inc    %eax
  801029:	89 43 08             	mov    %eax,0x8(%ebx)
  80102c:	eb 0c                	jmp    80103a <argnext+0x87>
	return arg;

    endofargs:
	args->curarg = 0;
  80102e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801035:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	return -1;
}
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	c9                   	leave  
  801042:	c3                   	ret    
	...

00801044 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	05 00 00 00 30       	add    $0x30000000,%eax
  80104f:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	e8 e5 ff ff ff       	call   801044 <fd2num>
  80105f:	83 c4 04             	add    $0x4,%esp
  801062:	c1 e0 0c             	shl    $0xc,%eax
  801065:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	53                   	push   %ebx
  801070:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801073:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801078:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	c1 e8 16             	shr    $0x16,%eax
  80107f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801086:	a8 01                	test   $0x1,%al
  801088:	74 10                	je     80109a <fd_alloc+0x2e>
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	c1 e8 0c             	shr    $0xc,%eax
  80108f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801096:	a8 01                	test   $0x1,%al
  801098:	75 09                	jne    8010a3 <fd_alloc+0x37>
			*fd_store = fd;
  80109a:	89 0b                	mov    %ecx,(%ebx)
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a1:	eb 19                	jmp    8010bc <fd_alloc+0x50>
			return 0;
  8010a3:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010a9:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  8010af:	75 c7                	jne    801078 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010bc:	5b                   	pop    %ebx
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010c5:	83 f8 1f             	cmp    $0x1f,%eax
  8010c8:	77 35                	ja     8010ff <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ca:	c1 e0 0c             	shl    $0xc,%eax
  8010cd:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010d3:	89 d0                	mov    %edx,%eax
  8010d5:	c1 e8 16             	shr    $0x16,%eax
  8010d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010df:	a8 01                	test   $0x1,%al
  8010e1:	74 1c                	je     8010ff <fd_lookup+0x40>
  8010e3:	89 d0                	mov    %edx,%eax
  8010e5:	c1 e8 0c             	shr    $0xc,%eax
  8010e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ef:	a8 01                	test   $0x1,%al
  8010f1:	74 0c                	je     8010ff <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f6:	89 10                	mov    %edx,(%eax)
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fd:	eb 05                	jmp    801104 <fd_lookup+0x45>
	return 0;
  8010ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80110c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	e8 a7 ff ff ff       	call   8010bf <fd_lookup>
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 0e                	js     80112d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80111f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801122:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801125:	89 50 04             	mov    %edx,0x4(%eax)
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	53                   	push   %ebx
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801139:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80113c:	ba 00 00 00 00       	mov    $0x0,%edx
  801141:	eb 0e                	jmp    801151 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801143:	3b 08                	cmp    (%eax),%ecx
  801145:	75 09                	jne    801150 <dev_lookup+0x21>
			*dev = devtab[i];
  801147:	89 03                	mov    %eax,(%ebx)
  801149:	b8 00 00 00 00       	mov    $0x0,%eax
  80114e:	eb 31                	jmp    801181 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801150:	42                   	inc    %edx
  801151:	8b 04 95 a8 26 80 00 	mov    0x8026a8(,%edx,4),%eax
  801158:	85 c0                	test   %eax,%eax
  80115a:	75 e7                	jne    801143 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80115c:	a1 20 44 80 00       	mov    0x804420,%eax
  801161:	8b 40 48             	mov    0x48(%eax),%eax
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	51                   	push   %ecx
  801168:	50                   	push   %eax
  801169:	68 2c 26 80 00       	push   $0x80262c
  80116e:	e8 5a f2 ff ff       	call   8003cd <cprintf>
	*dev = 0;
  801173:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801179:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117e:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 14             	sub    $0x14,%esp
  80118d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	ff 75 08             	pushl  0x8(%ebp)
  801197:	e8 23 ff ff ff       	call   8010bf <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 55                	js     8011f8 <fstat+0x72>
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ad:	ff 30                	pushl  (%eax)
  8011af:	e8 7b ff ff ff       	call   80112f <dev_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 3d                	js     8011f8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011c2:	75 07                	jne    8011cb <fstat+0x45>
  8011c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011c9:	eb 2d                	jmp    8011f8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011d5:	00 00 00 
	stat->st_isdir = 0;
  8011d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011df:	00 00 00 
	stat->st_dev = dev;
  8011e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	53                   	push   %ebx
  8011ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f2:	ff 50 14             	call   *0x14(%eax)
  8011f5:	83 c4 10             	add    $0x10,%esp
}
  8011f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	53                   	push   %ebx
  801201:	83 ec 14             	sub    $0x14,%esp
  801204:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	53                   	push   %ebx
  80120c:	e8 ae fe ff ff       	call   8010bf <fd_lookup>
  801211:	83 c4 08             	add    $0x8,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 5f                	js     801277 <ftruncate+0x7a>
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801222:	ff 30                	pushl  (%eax)
  801224:	e8 06 ff ff ff       	call   80112f <dev_lookup>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 47                	js     801277 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801230:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801233:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801237:	75 21                	jne    80125a <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801239:	a1 20 44 80 00       	mov    0x804420,%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	53                   	push   %ebx
  801245:	50                   	push   %eax
  801246:	68 4c 26 80 00       	push   $0x80264c
  80124b:	e8 7d f1 ff ff       	call   8003cd <cprintf>
  801250:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	eb 1d                	jmp    801277 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80125a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80125d:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801261:	75 07                	jne    80126a <ftruncate+0x6d>
  801263:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801268:	eb 0d                	jmp    801277 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	ff 75 0c             	pushl  0xc(%ebp)
  801270:	50                   	push   %eax
  801271:	ff 52 18             	call   *0x18(%edx)
  801274:	83 c4 10             	add    $0x10,%esp
}
  801277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 2f fe ff ff       	call   8010bf <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 62                	js     8012f9 <write+0x7d>
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 87 fe ff ff       	call   80112f <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 4a                	js     8012f9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b6:	75 21                	jne    8012d9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b8:	a1 20 44 80 00       	mov    0x804420,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	50                   	push   %eax
  8012c5:	68 6d 26 80 00       	push   $0x80266d
  8012ca:	e8 fe f0 ff ff       	call   8003cd <cprintf>
  8012cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	eb 20                	jmp    8012f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d9:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012dc:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8012e0:	75 07                	jne    8012e9 <write+0x6d>
  8012e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e7:	eb 10                	jmp    8012f9 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	ff 75 10             	pushl  0x10(%ebp)
  8012ef:	ff 75 0c             	pushl  0xc(%ebp)
  8012f2:	50                   	push   %eax
  8012f3:	ff 52 0c             	call   *0xc(%edx)
  8012f6:	83 c4 10             	add    $0x10,%esp
}
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 14             	sub    $0x14,%esp
  801305:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	53                   	push   %ebx
  80130d:	e8 ad fd ff ff       	call   8010bf <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 67                	js     801380 <read+0x82>
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801323:	ff 30                	pushl  (%eax)
  801325:	e8 05 fe ff ff       	call   80112f <dev_lookup>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 4f                	js     801380 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801331:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801334:	8b 42 08             	mov    0x8(%edx),%eax
  801337:	83 e0 03             	and    $0x3,%eax
  80133a:	83 f8 01             	cmp    $0x1,%eax
  80133d:	75 21                	jne    801360 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80133f:	a1 20 44 80 00       	mov    0x804420,%eax
  801344:	8b 40 48             	mov    0x48(%eax),%eax
  801347:	83 ec 04             	sub    $0x4,%esp
  80134a:	53                   	push   %ebx
  80134b:	50                   	push   %eax
  80134c:	68 8a 26 80 00       	push   $0x80268a
  801351:	e8 77 f0 ff ff       	call   8003cd <cprintf>
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	eb 20                	jmp    801380 <read+0x82>
	}
	if (!dev->dev_read)
  801360:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801363:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  801367:	75 07                	jne    801370 <read+0x72>
  801369:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136e:	eb 10                	jmp    801380 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	ff 75 10             	pushl  0x10(%ebp)
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	52                   	push   %edx
  80137a:	ff 50 08             	call   *0x8(%eax)
  80137d:	83 c4 10             	add    $0x10,%esp
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	83 ec 0c             	sub    $0xc,%esp
  80138e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801391:	8b 75 10             	mov    0x10(%ebp),%esi
  801394:	bb 00 00 00 00       	mov    $0x0,%ebx
  801399:	eb 21                	jmp    8013bc <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	29 d0                	sub    %edx,%eax
  8013a2:	50                   	push   %eax
  8013a3:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8013a6:	50                   	push   %eax
  8013a7:	ff 75 08             	pushl  0x8(%ebp)
  8013aa:	e8 4f ff ff ff       	call   8012fe <read>
		if (m < 0)
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 0e                	js     8013c4 <readn+0x3f>
			return m;
		if (m == 0)
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 08                	je     8013c2 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ba:	01 c3                	add    %eax,%ebx
  8013bc:	89 da                	mov    %ebx,%edx
  8013be:	39 f3                	cmp    %esi,%ebx
  8013c0:	72 d9                	jb     80139b <readn+0x16>
  8013c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 20             	sub    $0x20,%esp
  8013d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d7:	8a 45 0c             	mov    0xc(%ebp),%al
  8013da:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	56                   	push   %esi
  8013e2:	e8 5d fc ff ff       	call   801044 <fd2num>
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 d0 fc ff ff       	call   8010bf <fd_lookup>
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 05                	js     8013fd <fd_close+0x31>
  8013f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013fb:	74 0d                	je     80140a <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013fd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801401:	75 48                	jne    80144b <fd_close+0x7f>
  801403:	bb 00 00 00 00       	mov    $0x0,%ebx
  801408:	eb 41                	jmp    80144b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	ff 36                	pushl  (%esi)
  801413:	e8 17 fd ff ff       	call   80112f <dev_lookup>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 1c                	js     80143d <fd_close+0x71>
		if (dev->dev_close)
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	8b 40 10             	mov    0x10(%eax),%eax
  801427:	85 c0                	test   %eax,%eax
  801429:	75 07                	jne    801432 <fd_close+0x66>
  80142b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801430:	eb 0b                	jmp    80143d <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	56                   	push   %esi
  801436:	ff d0                	call   *%eax
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	56                   	push   %esi
  801441:	6a 00                	push   $0x0
  801443:	e8 69 f9 ff ff       	call   800db1 <sys_page_unmap>
  801448:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	ff 75 08             	pushl  0x8(%ebp)
  801461:	e8 59 fc ff ff       	call   8010bf <fd_lookup>
  801466:	83 c4 08             	add    $0x8,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 10                	js     80147d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	6a 01                	push   $0x1
  801472:	ff 75 fc             	pushl  -0x4(%ebp)
  801475:	e8 52 ff ff ff       	call   8013cc <fd_close>
  80147a:	83 c4 10             	add    $0x10,%esp
}
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	6a 00                	push   $0x0
  801489:	ff 75 08             	pushl  0x8(%ebp)
  80148c:	e8 4a 03 00 00       	call   8017db <open>
  801491:	89 c6                	mov    %eax,%esi
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 1b                	js     8014b5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	50                   	push   %eax
  8014a1:	e8 e0 fc ff ff       	call   801186 <fstat>
  8014a6:	89 c3                	mov    %eax,%ebx
	close(fd);
  8014a8:	89 34 24             	mov    %esi,(%esp)
  8014ab:	e8 a4 ff ff ff       	call   801454 <close>
  8014b0:	89 de                	mov    %ebx,%esi
  8014b2:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014b5:	89 f0                	mov    %esi,%eax
  8014b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 1c             	sub    $0x1c,%esp
  8014c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	ff 75 08             	pushl  0x8(%ebp)
  8014d1:	e8 e9 fb ff ff       	call   8010bf <fd_lookup>
  8014d6:	89 c3                	mov    %eax,%ebx
  8014d8:	83 c4 08             	add    $0x8,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	0f 88 bd 00 00 00    	js     8015a0 <dup+0xe2>
		return r;
	close(newfdnum);
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	57                   	push   %edi
  8014e7:	e8 68 ff ff ff       	call   801454 <close>

	newfd = INDEX2FD(newfdnum);
  8014ec:	89 f8                	mov    %edi,%eax
  8014ee:	c1 e0 0c             	shl    $0xc,%eax
  8014f1:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8014f7:	ff 75 f0             	pushl  -0x10(%ebp)
  8014fa:	e8 55 fb ff ff       	call   801054 <fd2data>
  8014ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801501:	89 34 24             	mov    %esi,(%esp)
  801504:	e8 4b fb ff ff       	call   801054 <fd2data>
  801509:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150c:	89 d8                	mov    %ebx,%eax
  80150e:	c1 e8 16             	shr    $0x16,%eax
  801511:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801518:	83 c4 14             	add    $0x14,%esp
  80151b:	a8 01                	test   $0x1,%al
  80151d:	74 36                	je     801555 <dup+0x97>
  80151f:	89 da                	mov    %ebx,%edx
  801521:	c1 ea 0c             	shr    $0xc,%edx
  801524:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80152b:	a8 01                	test   $0x1,%al
  80152d:	74 26                	je     801555 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	25 07 0e 00 00       	and    $0xe07,%eax
  80153e:	50                   	push   %eax
  80153f:	ff 75 e0             	pushl  -0x20(%ebp)
  801542:	6a 00                	push   $0x0
  801544:	53                   	push   %ebx
  801545:	6a 00                	push   $0x0
  801547:	e8 a7 f8 ff ff       	call   800df3 <sys_page_map>
  80154c:	89 c3                	mov    %eax,%ebx
  80154e:	83 c4 20             	add    $0x20,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 30                	js     801585 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801555:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801558:	89 d0                	mov    %edx,%eax
  80155a:	c1 e8 0c             	shr    $0xc,%eax
  80155d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	25 07 0e 00 00       	and    $0xe07,%eax
  80156c:	50                   	push   %eax
  80156d:	56                   	push   %esi
  80156e:	6a 00                	push   $0x0
  801570:	52                   	push   %edx
  801571:	6a 00                	push   $0x0
  801573:	e8 7b f8 ff ff       	call   800df3 <sys_page_map>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	83 c4 20             	add    $0x20,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 04                	js     801585 <dup+0xc7>
		goto err;
  801581:	89 fb                	mov    %edi,%ebx
  801583:	eb 1b                	jmp    8015a0 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	56                   	push   %esi
  801589:	6a 00                	push   $0x0
  80158b:	e8 21 f8 ff ff       	call   800db1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	ff 75 e0             	pushl  -0x20(%ebp)
  801596:	6a 00                	push   $0x0
  801598:	e8 14 f8 ff ff       	call   800db1 <sys_page_unmap>
  80159d:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	c9                   	leave  
  8015a9:	c3                   	ret    

008015aa <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	e8 95 fe ff ff       	call   801454 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bf:	43                   	inc    %ebx
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	83 fb 20             	cmp    $0x20,%ebx
  8015c6:	75 ee                	jne    8015b6 <close_all+0xc>
		close(i);
}
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    
  8015cd:	00 00                	add    %al,(%eax)
	...

008015d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e0:	75 12                	jne    8015f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	6a 01                	push   $0x1
  8015e7:	e8 60 08 00 00       	call   801e4c <ipc_find_env>
  8015ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f4:	6a 07                	push   $0x7
  8015f6:	68 00 50 80 00       	push   $0x805000
  8015fb:	53                   	push   %ebx
  8015fc:	ff 35 00 40 80 00    	pushl  0x804000
  801602:	e8 8a 08 00 00       	call   801e91 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801607:	83 c4 0c             	add    $0xc,%esp
  80160a:	6a 00                	push   $0x0
  80160c:	56                   	push   %esi
  80160d:	6a 00                	push   $0x0
  80160f:	e8 d2 08 00 00       	call   801ee6 <ipc_recv>
}
  801614:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801621:	ba 00 00 00 00       	mov    $0x0,%edx
  801626:	b8 08 00 00 00       	mov    $0x8,%eax
  80162b:	e8 a0 ff ff ff       	call   8015d0 <fsipc>
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801638:	8b 45 08             	mov    0x8(%ebp),%eax
  80163b:	8b 40 0c             	mov    0xc(%eax),%eax
  80163e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801643:	8b 45 0c             	mov    0xc(%ebp),%eax
  801646:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	b8 02 00 00 00       	mov    $0x2,%eax
  801655:	e8 76 ff ff ff       	call   8015d0 <fsipc>
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 40 0c             	mov    0xc(%eax),%eax
  801668:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80166d:	ba 00 00 00 00       	mov    $0x0,%edx
  801672:	b8 06 00 00 00       	mov    $0x6,%eax
  801677:	e8 54 ff ff ff       	call   8015d0 <fsipc>
}
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	8b 40 0c             	mov    0xc(%eax),%eax
  80168e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801693:	ba 00 00 00 00       	mov    $0x0,%edx
  801698:	b8 05 00 00 00       	mov    $0x5,%eax
  80169d:	e8 2e ff ff ff       	call   8015d0 <fsipc>
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 2c                	js     8016d2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	68 00 50 80 00       	push   $0x805000
  8016ae:	53                   	push   %ebx
  8016af:	e8 6b f2 ff ff       	call   80091f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016b4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016bf:	a1 84 50 80 00       	mov    0x805084,%eax
  8016c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8016ec:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016f2:	53                   	push   %ebx
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	68 08 50 80 00       	push   $0x805008
  8016fb:	e8 8c f3 ff ff       	call   800a8c <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	b8 04 00 00 00       	mov    $0x4,%eax
  80170a:	e8 c1 fe ff ff       	call   8015d0 <fsipc>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 3d                	js     801753 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801716:	39 c3                	cmp    %eax,%ebx
  801718:	73 19                	jae    801733 <devfile_write+0x5c>
  80171a:	68 b8 26 80 00       	push   $0x8026b8
  80171f:	68 bf 26 80 00       	push   $0x8026bf
  801724:	68 97 00 00 00       	push   $0x97
  801729:	68 d4 26 80 00       	push   $0x8026d4
  80172e:	e8 f9 eb ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  801733:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801738:	7e 19                	jle    801753 <devfile_write+0x7c>
  80173a:	68 df 26 80 00       	push   $0x8026df
  80173f:	68 bf 26 80 00       	push   $0x8026bf
  801744:	68 98 00 00 00       	push   $0x98
  801749:	68 d4 26 80 00       	push   $0x8026d4
  80174e:	e8 d9 eb ff ff       	call   80032c <_panic>
	
	return r;
}
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801771:	ba 00 00 00 00       	mov    $0x0,%edx
  801776:	b8 03 00 00 00       	mov    $0x3,%eax
  80177b:	e8 50 fe ff ff       	call   8015d0 <fsipc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	85 c0                	test   %eax,%eax
  801784:	78 4c                	js     8017d2 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801786:	39 de                	cmp    %ebx,%esi
  801788:	73 16                	jae    8017a0 <devfile_read+0x48>
  80178a:	68 b8 26 80 00       	push   $0x8026b8
  80178f:	68 bf 26 80 00       	push   $0x8026bf
  801794:	6a 7c                	push   $0x7c
  801796:	68 d4 26 80 00       	push   $0x8026d4
  80179b:	e8 8c eb ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  8017a0:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8017a6:	7e 16                	jle    8017be <devfile_read+0x66>
  8017a8:	68 df 26 80 00       	push   $0x8026df
  8017ad:	68 bf 26 80 00       	push   $0x8026bf
  8017b2:	6a 7d                	push   $0x7d
  8017b4:	68 d4 26 80 00       	push   $0x8026d4
  8017b9:	e8 6e eb ff ff       	call   80032c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	50                   	push   %eax
  8017c2:	68 00 50 80 00       	push   $0x805000
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	e8 bd f2 ff ff       	call   800a8c <memmove>
  8017cf:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8017d2:	89 d8                	mov    %ebx,%eax
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 1c             	sub    $0x1c,%esp
  8017e3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e6:	56                   	push   %esi
  8017e7:	e8 00 f1 ff ff       	call   8008ec <strlen>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f4:	7e 07                	jle    8017fd <open+0x22>
  8017f6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8017fb:	eb 63                	jmp    801860 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	e8 63 f8 ff ff       	call   80106c <fd_alloc>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 4e                	js     801860 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	56                   	push   %esi
  801816:	68 00 50 80 00       	push   $0x805000
  80181b:	e8 ff f0 ff ff       	call   80091f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801820:	8b 45 0c             	mov    0xc(%ebp),%eax
  801823:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801828:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182b:	b8 01 00 00 00       	mov    $0x1,%eax
  801830:	e8 9b fd ff ff       	call   8015d0 <fsipc>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	79 12                	jns    801850 <open+0x75>
		fd_close(fd, 0);
  80183e:	83 ec 08             	sub    $0x8,%esp
  801841:	6a 00                	push   $0x0
  801843:	ff 75 f4             	pushl  -0xc(%ebp)
  801846:	e8 81 fb ff ff       	call   8013cc <fd_close>
		return r;
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	eb 10                	jmp    801860 <open+0x85>
	}

	return fd2num(fd);
  801850:	83 ec 0c             	sub    $0xc,%esp
  801853:	ff 75 f4             	pushl  -0xc(%ebp)
  801856:	e8 e9 f7 ff ff       	call   801044 <fd2num>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
}
  801860:	89 d8                	mov    %ebx,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	c9                   	leave  
  801868:	c3                   	ret    
  801869:	00 00                	add    %al,(%eax)
	...

0080186c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	53                   	push   %ebx
  801870:	83 ec 04             	sub    $0x4,%esp
  801873:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801875:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801879:	7e 2c                	jle    8018a7 <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	ff 70 04             	pushl  0x4(%eax)
  801881:	8d 40 10             	lea    0x10(%eax),%eax
  801884:	50                   	push   %eax
  801885:	ff 33                	pushl  (%ebx)
  801887:	e8 f0 f9 ff ff       	call   80127c <write>
		if (result > 0)
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	7e 03                	jle    801896 <writebuf+0x2a>
			b->result += result;
  801893:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801896:	3b 43 04             	cmp    0x4(%ebx),%eax
  801899:	74 0c                	je     8018a7 <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  80189b:	85 c0                	test   %eax,%eax
  80189d:	7e 05                	jle    8018a4 <writebuf+0x38>
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8018a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018aa:	c9                   	leave  
  8018ab:	c3                   	ret    

008018ac <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  8018b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b9:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  8018bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018c6:	00 00 00 
	b.result = 0;
  8018c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8018d0:	00 00 00 
	b.error = 1;
  8018d3:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  8018da:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  8018e9:	53                   	push   %ebx
  8018ea:	68 4f 19 80 00       	push   $0x80194f
  8018ef:	e8 2c ec ff ff       	call   800520 <vprintfmt>
	if (b.idx > 0)
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  8018fe:	7e 07                	jle    801907 <vfprintf+0x5b>
		writebuf(&b);
  801900:	89 d8                	mov    %ebx,%eax
  801902:	e8 65 ff ff ff       	call   80186c <writebuf>

	return (b.result ? b.result : b.error);
  801907:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80190d:	85 c0                	test   %eax,%eax
  80190f:	75 06                	jne    801917 <vfprintf+0x6b>
  801911:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801922:	8d 45 0c             	lea    0xc(%ebp),%eax
  801925:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  801928:	50                   	push   %eax
  801929:	ff 75 08             	pushl  0x8(%ebp)
  80192c:	6a 01                	push   $0x1
  80192e:	e8 79 ff ff ff       	call   8018ac <vfprintf>
	va_end(ap);

	return cnt;
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80193b:	8d 45 10             	lea    0x10(%ebp),%eax
  80193e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  801941:	50                   	push   %eax
  801942:	ff 75 0c             	pushl  0xc(%ebp)
  801945:	ff 75 08             	pushl  0x8(%ebp)
  801948:	e8 5f ff ff ff       	call   8018ac <vfprintf>
	va_end(ap);

	return cnt;
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	53                   	push   %ebx
  801953:	83 ec 04             	sub    $0x4,%esp
  801956:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801959:	8b 43 04             	mov    0x4(%ebx),%eax
  80195c:	8b 55 08             	mov    0x8(%ebp),%edx
  80195f:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  801963:	40                   	inc    %eax
  801964:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801967:	3d 00 01 00 00       	cmp    $0x100,%eax
  80196c:	75 0e                	jne    80197c <putch+0x2d>
		writebuf(b);
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	e8 f7 fe ff ff       	call   80186c <writebuf>
		b->idx = 0;
  801975:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80197c:	83 c4 04             	add    $0x4,%esp
  80197f:	5b                   	pop    %ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    
	...

00801984 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	ff 75 08             	pushl  0x8(%ebp)
  801992:	e8 bd f6 ff ff       	call   801054 <fd2data>
  801997:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	68 eb 26 80 00       	push   $0x8026eb
  8019a1:	53                   	push   %ebx
  8019a2:	e8 78 ef ff ff       	call   80091f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019a7:	8b 46 04             	mov    0x4(%esi),%eax
  8019aa:	2b 06                	sub    (%esi),%eax
  8019ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b9:	00 00 00 
	stat->st_dev = &devpipe;
  8019bc:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019c3:	30 80 00 
	return 0;
}
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 0c             	sub    $0xc,%esp
  8019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019dc:	53                   	push   %ebx
  8019dd:	6a 00                	push   $0x0
  8019df:	e8 cd f3 ff ff       	call   800db1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019e4:	89 1c 24             	mov    %ebx,(%esp)
  8019e7:	e8 68 f6 ff ff       	call   801054 <fd2data>
  8019ec:	83 c4 08             	add    $0x8,%esp
  8019ef:	50                   	push   %eax
  8019f0:	6a 00                	push   $0x0
  8019f2:	e8 ba f3 ff ff       	call   800db1 <sys_page_unmap>
}
  8019f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a08:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a0a:	a1 20 44 80 00       	mov    0x804420,%eax
  801a0f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 f0             	pushl  -0x10(%ebp)
  801a18:	e8 33 05 00 00       	call   801f50 <pageref>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	89 3c 24             	mov    %edi,(%esp)
  801a22:	e8 29 05 00 00       	call   801f50 <pageref>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	39 c3                	cmp    %eax,%ebx
  801a2c:	0f 94 c0             	sete   %al
  801a2f:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801a32:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a38:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801a3b:	39 c6                	cmp    %eax,%esi
  801a3d:	74 1b                	je     801a5a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801a3f:	83 f9 01             	cmp    $0x1,%ecx
  801a42:	75 c6                	jne    801a0a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a44:	8b 42 58             	mov    0x58(%edx),%eax
  801a47:	6a 01                	push   $0x1
  801a49:	50                   	push   %eax
  801a4a:	56                   	push   %esi
  801a4b:	68 f2 26 80 00       	push   $0x8026f2
  801a50:	e8 78 e9 ff ff       	call   8003cd <cprintf>
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	eb b0                	jmp    801a0a <_pipeisclosed+0xe>
	}
}
  801a5a:	89 c8                	mov    %ecx,%eax
  801a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5f                   	pop    %edi
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	57                   	push   %edi
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 18             	sub    $0x18,%esp
  801a6d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a70:	56                   	push   %esi
  801a71:	e8 de f5 ff ff       	call   801054 <fd2data>
  801a76:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a7e:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	eb 40                	jmp    801ac8 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a88:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8d:	eb 40                	jmp    801acf <devpipe_write+0x6b>
  801a8f:	89 da                	mov    %ebx,%edx
  801a91:	89 f0                	mov    %esi,%eax
  801a93:	e8 64 ff ff ff       	call   8019fc <_pipeisclosed>
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	75 ec                	jne    801a88 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a9c:	e8 d7 f3 ff ff       	call   800e78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aa1:	8b 53 04             	mov    0x4(%ebx),%edx
  801aa4:	8b 03                	mov    (%ebx),%eax
  801aa6:	83 c0 20             	add    $0x20,%eax
  801aa9:	39 c2                	cmp    %eax,%edx
  801aab:	73 e2                	jae    801a8f <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aad:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ab3:	79 05                	jns    801aba <devpipe_write+0x56>
  801ab5:	4a                   	dec    %edx
  801ab6:	83 ca e0             	or     $0xffffffe0,%edx
  801ab9:	42                   	inc    %edx
  801aba:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801abd:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801ac0:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ac4:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac7:	47                   	inc    %edi
  801ac8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801acb:	75 d4                	jne    801aa1 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801acd:	89 f8                	mov    %edi,%eax
}
  801acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5f                   	pop    %edi
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	57                   	push   %edi
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	83 ec 18             	sub    $0x18,%esp
  801ae0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae3:	57                   	push   %edi
  801ae4:	e8 6b f5 ff ff       	call   801054 <fd2data>
  801ae9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801af1:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	eb 41                	jmp    801b3c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801afb:	89 f0                	mov    %esi,%eax
  801afd:	eb 44                	jmp    801b43 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
  801b04:	eb 3d                	jmp    801b43 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b06:	85 f6                	test   %esi,%esi
  801b08:	75 f1                	jne    801afb <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b0a:	89 da                	mov    %ebx,%edx
  801b0c:	89 f8                	mov    %edi,%eax
  801b0e:	e8 e9 fe ff ff       	call   8019fc <_pipeisclosed>
  801b13:	85 c0                	test   %eax,%eax
  801b15:	75 e8                	jne    801aff <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b17:	e8 5c f3 ff ff       	call   800e78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b1c:	8b 03                	mov    (%ebx),%eax
  801b1e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b21:	74 e3                	je     801b06 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b23:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b28:	79 05                	jns    801b2f <devpipe_read+0x58>
  801b2a:	48                   	dec    %eax
  801b2b:	83 c8 e0             	or     $0xffffffe0,%eax
  801b2e:	40                   	inc    %eax
  801b2f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b36:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801b39:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3b:	46                   	inc    %esi
  801b3c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b3f:	75 db                	jne    801b1c <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b41:	89 f0                	mov    %esi,%eax
}
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b51:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b54:	50                   	push   %eax
  801b55:	ff 75 08             	pushl  0x8(%ebp)
  801b58:	e8 62 f5 ff ff       	call   8010bf <fd_lookup>
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 18                	js     801b7c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	ff 75 fc             	pushl  -0x4(%ebp)
  801b6a:	e8 e5 f4 ff ff       	call   801054 <fd2data>
  801b6f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b74:	e8 83 fe ff ff       	call   8019fc <_pipeisclosed>
  801b79:	83 c4 10             	add    $0x10,%esp
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 28             	sub    $0x28,%esp
  801b87:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8d:	50                   	push   %eax
  801b8e:	e8 d9 f4 ff ff       	call   80106c <fd_alloc>
  801b93:	89 c3                	mov    %eax,%ebx
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	0f 88 24 01 00 00    	js     801cc4 <pipe+0x146>
  801ba0:	83 ec 04             	sub    $0x4,%esp
  801ba3:	68 07 04 00 00       	push   $0x407
  801ba8:	ff 75 f0             	pushl  -0x10(%ebp)
  801bab:	6a 00                	push   $0x0
  801bad:	e8 83 f2 ff ff       	call   800e35 <sys_page_alloc>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	0f 88 05 01 00 00    	js     801cc4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bc5:	50                   	push   %eax
  801bc6:	e8 a1 f4 ff ff       	call   80106c <fd_alloc>
  801bcb:	89 c3                	mov    %eax,%ebx
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	0f 88 dc 00 00 00    	js     801cb4 <pipe+0x136>
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	68 07 04 00 00       	push   $0x407
  801be0:	ff 75 ec             	pushl  -0x14(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 4b f2 ff ff       	call   800e35 <sys_page_alloc>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 88 bd 00 00 00    	js     801cb4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfd:	e8 52 f4 ff ff       	call   801054 <fd2data>
  801c02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 c4 0c             	add    $0xc,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	50                   	push   %eax
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 21 f2 ff ff       	call   800e35 <sys_page_alloc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 83 00 00 00    	js     801ca4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	ff 75 ec             	pushl  -0x14(%ebp)
  801c27:	e8 28 f4 ff ff       	call   801054 <fd2data>
  801c2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c33:	50                   	push   %eax
  801c34:	6a 00                	push   $0x0
  801c36:	56                   	push   %esi
  801c37:	6a 00                	push   $0x0
  801c39:	e8 b5 f1 ff ff       	call   800df3 <sys_page_map>
  801c3e:	89 c3                	mov    %eax,%ebx
  801c40:	83 c4 20             	add    $0x20,%esp
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 4f                	js     801c96 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c47:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c50:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c55:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c65:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f0             	pushl  -0x10(%ebp)
  801c77:	e8 c8 f3 ff ff       	call   801044 <fd2num>
  801c7c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c7e:	83 c4 04             	add    $0x4,%esp
  801c81:	ff 75 ec             	pushl  -0x14(%ebp)
  801c84:	e8 bb f3 ff ff       	call   801044 <fd2num>
  801c89:	89 47 04             	mov    %eax,0x4(%edi)
  801c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	eb 2e                	jmp    801cc4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c96:	83 ec 08             	sub    $0x8,%esp
  801c99:	56                   	push   %esi
  801c9a:	6a 00                	push   $0x0
  801c9c:	e8 10 f1 ff ff       	call   800db1 <sys_page_unmap>
  801ca1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca4:	83 ec 08             	sub    $0x8,%esp
  801ca7:	ff 75 ec             	pushl  -0x14(%ebp)
  801caa:	6a 00                	push   $0x0
  801cac:	e8 00 f1 ff ff       	call   800db1 <sys_page_unmap>
  801cb1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb4:	83 ec 08             	sub    $0x8,%esp
  801cb7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cba:	6a 00                	push   $0x0
  801cbc:	e8 f0 f0 ff ff       	call   800db1 <sys_page_unmap>
  801cc1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    
	...

00801cd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce0:	68 0a 27 80 00       	push   $0x80270a
  801ce5:	ff 75 0c             	pushl  0xc(%ebp)
  801ce8:	e8 32 ec ff ff       	call   80091f <strcpy>
	return 0;
}
  801ced:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf2:	c9                   	leave  
  801cf3:	c3                   	ret    

00801cf4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801d00:	be 00 00 00 00       	mov    $0x0,%esi
  801d05:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801d0b:	eb 2c                	jmp    801d39 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d10:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d12:	83 fb 7f             	cmp    $0x7f,%ebx
  801d15:	76 05                	jbe    801d1c <devcons_write+0x28>
  801d17:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1c:	83 ec 04             	sub    $0x4,%esp
  801d1f:	53                   	push   %ebx
  801d20:	03 45 0c             	add    0xc(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	57                   	push   %edi
  801d25:	e8 62 ed ff ff       	call   800a8c <memmove>
		sys_cputs(buf, m);
  801d2a:	83 c4 08             	add    $0x8,%esp
  801d2d:	53                   	push   %ebx
  801d2e:	57                   	push   %edi
  801d2f:	e8 2f ef ff ff       	call   800c63 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d34:	01 de                	add    %ebx,%esi
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d3e:	72 cd                	jb     801d0d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d54:	6a 01                	push   $0x1
  801d56:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801d59:	50                   	push   %eax
  801d5a:	e8 04 ef ff ff       	call   800c63 <sys_cputs>
  801d5f:	83 c4 10             	add    $0x10,%esp
}
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6e:	74 27                	je     801d97 <devcons_read+0x33>
  801d70:	eb 05                	jmp    801d77 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d72:	e8 01 f1 ff ff       	call   800e78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d77:	e8 c8 ee ff ff       	call   800c44 <sys_cgetc>
  801d7c:	89 c2                	mov    %eax,%edx
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	74 f0                	je     801d72 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801d82:	85 c0                	test   %eax,%eax
  801d84:	78 16                	js     801d9c <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d86:	83 f8 04             	cmp    $0x4,%eax
  801d89:	74 0c                	je     801d97 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8e:	88 10                	mov    %dl,(%eax)
  801d90:	ba 01 00 00 00       	mov    $0x1,%edx
  801d95:	eb 05                	jmp    801d9c <devcons_read+0x38>
	return 1;
  801d97:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d9c:	89 d0                	mov    %edx,%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801da6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801da9:	50                   	push   %eax
  801daa:	e8 bd f2 ff ff       	call   80106c <fd_alloc>
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 3b                	js     801df1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801db6:	83 ec 04             	sub    $0x4,%esp
  801db9:	68 07 04 00 00       	push   $0x407
  801dbe:	ff 75 fc             	pushl  -0x4(%ebp)
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 6d f0 ff ff       	call   800e35 <sys_page_alloc>
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 22                	js     801df1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dcf:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801dd4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801dd7:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801dd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ddc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	ff 75 fc             	pushl  -0x4(%ebp)
  801de9:	e8 56 f2 ff ff       	call   801044 <fd2num>
  801dee:	83 c4 10             	add    $0x10,%esp
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	ff 75 08             	pushl  0x8(%ebp)
  801e00:	e8 ba f2 ff ff       	call   8010bf <fd_lookup>
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	78 11                	js     801e1d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801e0f:	8b 00                	mov    (%eax),%eax
  801e11:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  801e17:	0f 94 c0             	sete   %al
  801e1a:	0f b6 c0             	movzbl %al,%eax
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e25:	6a 01                	push   $0x1
  801e27:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801e2a:	50                   	push   %eax
  801e2b:	6a 00                	push   $0x0
  801e2d:	e8 cc f4 ff ff       	call   8012fe <read>
	if (r < 0)
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 0f                	js     801e48 <getchar+0x29>
		return r;
	if (r < 1)
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	75 07                	jne    801e44 <getchar+0x25>
  801e3d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e42:	eb 04                	jmp    801e48 <getchar+0x29>
		return -E_EOF;
	return c;
  801e44:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    
	...

00801e4c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	53                   	push   %ebx
  801e50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e53:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e58:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801e5f:	89 c8                	mov    %ecx,%eax
  801e61:	c1 e0 07             	shl    $0x7,%eax
  801e64:	29 d0                	sub    %edx,%eax
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801e6e:	8b 40 50             	mov    0x50(%eax),%eax
  801e71:	39 d8                	cmp    %ebx,%eax
  801e73:	75 0b                	jne    801e80 <ipc_find_env+0x34>
			return envs[i].env_id;
  801e75:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801e7b:	8b 40 40             	mov    0x40(%eax),%eax
  801e7e:	eb 0e                	jmp    801e8e <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e80:	41                   	inc    %ecx
  801e81:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801e87:	75 cf                	jne    801e58 <ipc_find_env+0xc>
  801e89:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801e8e:	5b                   	pop    %ebx
  801e8f:	c9                   	leave  
  801e90:	c3                   	ret    

00801e91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	57                   	push   %edi
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ea3:	85 db                	test   %ebx,%ebx
  801ea5:	75 05                	jne    801eac <ipc_send+0x1b>
  801ea7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	57                   	push   %edi
  801eaf:	ff 75 08             	pushl  0x8(%ebp)
  801eb2:	e8 11 ee ff ff       	call   800cc8 <sys_ipc_try_send>
		if (r == 0) {		//success
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	74 20                	je     801ede <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801ebe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec1:	75 07                	jne    801eca <ipc_send+0x39>
			sys_yield();
  801ec3:	e8 b0 ef ff ff       	call   800e78 <sys_yield>
  801ec8:	eb e2                	jmp    801eac <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801eca:	83 ec 04             	sub    $0x4,%esp
  801ecd:	68 18 27 80 00       	push   $0x802718
  801ed2:	6a 41                	push   $0x41
  801ed4:	68 3c 27 80 00       	push   $0x80273c
  801ed9:	e8 4e e4 ff ff       	call   80032c <_panic>
		}
	}
}
  801ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	c9                   	leave  
  801ee5:	c3                   	ret    

00801ee6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	75 05                	jne    801efd <ipc_recv+0x17>
  801ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	50                   	push   %eax
  801f01:	e8 81 ed ff ff       	call   800c87 <sys_ipc_recv>
	if (r < 0) {				
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	79 16                	jns    801f23 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801f0d:	85 db                	test   %ebx,%ebx
  801f0f:	74 06                	je     801f17 <ipc_recv+0x31>
  801f11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801f17:	85 f6                	test   %esi,%esi
  801f19:	74 2c                	je     801f47 <ipc_recv+0x61>
  801f1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801f21:	eb 24                	jmp    801f47 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801f23:	85 db                	test   %ebx,%ebx
  801f25:	74 0a                	je     801f31 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801f27:	a1 20 44 80 00       	mov    0x804420,%eax
  801f2c:	8b 40 74             	mov    0x74(%eax),%eax
  801f2f:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801f31:	85 f6                	test   %esi,%esi
  801f33:	74 0a                	je     801f3f <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801f35:	a1 20 44 80 00       	mov    0x804420,%eax
  801f3a:	8b 40 78             	mov    0x78(%eax),%eax
  801f3d:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801f3f:	a1 20 44 80 00       	mov    0x804420,%eax
  801f44:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    
	...

00801f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f56:	89 d0                	mov    %edx,%eax
  801f58:	c1 e8 16             	shr    $0x16,%eax
  801f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f62:	a8 01                	test   $0x1,%al
  801f64:	74 20                	je     801f86 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f66:	89 d0                	mov    %edx,%eax
  801f68:	c1 e8 0c             	shr    $0xc,%eax
  801f6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f72:	a8 01                	test   $0x1,%al
  801f74:	74 10                	je     801f86 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f76:	c1 e8 0c             	shr    $0xc,%eax
  801f79:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f80:	ef 
  801f81:	0f b7 c0             	movzwl %ax,%eax
  801f84:	eb 05                	jmp    801f8b <pageref+0x3b>
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8b:	c9                   	leave  
  801f8c:	c3                   	ret    
  801f8d:	00 00                	add    %al,(%eax)
	...

00801f90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	83 ec 28             	sub    $0x28,%esp
  801f98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801f9f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801fa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa9:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801fac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801faf:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801fb1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801fb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbc:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fbf:	85 ff                	test   %edi,%edi
  801fc1:	75 21                	jne    801fe4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801fc3:	39 d1                	cmp    %edx,%ecx
  801fc5:	76 49                	jbe    802010 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc7:	f7 f1                	div    %ecx
  801fc9:	89 c1                	mov    %eax,%ecx
  801fcb:	31 c0                	xor    %eax,%eax
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801fd3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fd6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801fdc:	83 c4 28             	add    $0x28,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fe4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801fe7:	0f 87 97 00 00 00    	ja     802084 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fed:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ff0:	83 f0 1f             	xor    $0x1f,%eax
  801ff3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ff6:	75 34                	jne    80202c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801ffb:	72 08                	jb     802005 <__udivdi3+0x75>
  801ffd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802000:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802003:	77 7f                	ja     802084 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802005:	b9 01 00 00 00       	mov    $0x1,%ecx
  80200a:	31 c0                	xor    %eax,%eax
  80200c:	eb c2                	jmp    801fd0 <__udivdi3+0x40>
  80200e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802013:	85 c0                	test   %eax,%eax
  802015:	74 79                	je     802090 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802017:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	f7 f1                	div    %ecx
  80201e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802020:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802023:	f7 f1                	div    %ecx
  802025:	89 c1                	mov    %eax,%ecx
  802027:	89 f0                	mov    %esi,%eax
  802029:	eb a5                	jmp    801fd0 <__udivdi3+0x40>
  80202b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80202c:	b8 20 00 00 00       	mov    $0x20,%eax
  802031:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802034:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802037:	89 fa                	mov    %edi,%edx
  802039:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80203c:	d3 e2                	shl    %cl,%edx
  80203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802041:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802044:	d3 e8                	shr    %cl,%eax
  802046:	89 d7                	mov    %edx,%edi
  802048:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80204a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80204d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802050:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802052:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802055:	d3 e0                	shl    %cl,%eax
  802057:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80205a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80205d:	d3 ea                	shr    %cl,%edx
  80205f:	09 d0                	or     %edx,%eax
  802061:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802064:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802067:	d3 ea                	shr    %cl,%edx
  802069:	f7 f7                	div    %edi
  80206b:	89 d7                	mov    %edx,%edi
  80206d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802070:	f7 e6                	mul    %esi
  802072:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802074:	39 d7                	cmp    %edx,%edi
  802076:	72 38                	jb     8020b0 <__udivdi3+0x120>
  802078:	74 27                	je     8020a1 <__udivdi3+0x111>
  80207a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80207d:	31 c0                	xor    %eax,%eax
  80207f:	e9 4c ff ff ff       	jmp    801fd0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802084:	31 c9                	xor    %ecx,%ecx
  802086:	31 c0                	xor    %eax,%eax
  802088:	e9 43 ff ff ff       	jmp    801fd0 <__udivdi3+0x40>
  80208d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802090:	b8 01 00 00 00       	mov    $0x1,%eax
  802095:	31 d2                	xor    %edx,%edx
  802097:	f7 75 f4             	divl   -0xc(%ebp)
  80209a:	89 c1                	mov    %eax,%ecx
  80209c:	e9 76 ff ff ff       	jmp    802017 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020a4:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8020a7:	d3 e0                	shl    %cl,%eax
  8020a9:	39 f0                	cmp    %esi,%eax
  8020ab:	73 cd                	jae    80207a <__udivdi3+0xea>
  8020ad:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020b3:	49                   	dec    %ecx
  8020b4:	31 c0                	xor    %eax,%eax
  8020b6:	e9 15 ff ff ff       	jmp    801fd0 <__udivdi3+0x40>
	...

008020bc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	57                   	push   %edi
  8020c0:	56                   	push   %esi
  8020c1:	83 ec 30             	sub    $0x30,%esp
  8020c4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8020cb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8020d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020db:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8020de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020e1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8020e3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8020e6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8020e9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ec:	85 d2                	test   %edx,%edx
  8020ee:	75 1c                	jne    80210c <__umoddi3+0x50>
    {
      if (d0 > n1)
  8020f0:	89 fa                	mov    %edi,%edx
  8020f2:	39 f8                	cmp    %edi,%eax
  8020f4:	0f 86 c2 00 00 00    	jbe    8021bc <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020fa:	89 f0                	mov    %esi,%eax
  8020fc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8020fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802101:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802108:	eb 12                	jmp    80211c <__umoddi3+0x60>
  80210a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80210c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80210f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802112:	76 18                	jbe    80212c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802114:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  802117:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80211a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80211c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80211f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802122:	83 c4 30             	add    $0x30,%esp
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	c9                   	leave  
  802128:	c3                   	ret    
  802129:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80212c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802130:	83 f0 1f             	xor    $0x1f,%eax
  802133:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802136:	0f 84 ac 00 00 00    	je     8021e8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80213c:	b8 20 00 00 00       	mov    $0x20,%eax
  802141:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802144:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802147:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80214a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80214d:	d3 e2                	shl    %cl,%edx
  80214f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802152:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802155:	d3 e8                	shr    %cl,%eax
  802157:	89 d6                	mov    %edx,%esi
  802159:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80215b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80215e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802161:	d3 e0                	shl    %cl,%eax
  802163:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802166:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802169:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80216b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216e:	d3 e0                	shl    %cl,%eax
  802170:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802173:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802176:	d3 ea                	shr    %cl,%edx
  802178:	09 d0                	or     %edx,%eax
  80217a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80217d:	d3 ea                	shr    %cl,%edx
  80217f:	f7 f6                	div    %esi
  802181:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802184:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802187:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80218a:	0f 82 8d 00 00 00    	jb     80221d <__umoddi3+0x161>
  802190:	0f 84 91 00 00 00    	je     802227 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802196:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802199:	29 c7                	sub    %eax,%edi
  80219b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8021a2:	d3 e2                	shl    %cl,%edx
  8021a4:	89 f8                	mov    %edi,%eax
  8021a6:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8021a9:	d3 e8                	shr    %cl,%eax
  8021ab:	09 c2                	or     %eax,%edx
  8021ad:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8021b0:	d3 ee                	shr    %cl,%esi
  8021b2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8021b5:	e9 62 ff ff ff       	jmp    80211c <__umoddi3+0x60>
  8021ba:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	74 15                	je     8021d8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021c9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	f7 f1                	div    %ecx
  8021d0:	e9 29 ff ff ff       	jmp    8020fe <__umoddi3+0x42>
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8021dd:	31 d2                	xor    %edx,%edx
  8021df:	f7 75 ec             	divl   -0x14(%ebp)
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	eb dd                	jmp    8021c3 <__umoddi3+0x107>
  8021e6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021eb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8021ee:	72 19                	jb     802209 <__umoddi3+0x14d>
  8021f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021f3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8021f6:	76 11                	jbe    802209 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8021f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021fb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8021fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802201:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802204:	e9 13 ff ff ff       	jmp    80211c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802209:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80220c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802212:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802215:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802218:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80221b:	eb db                	jmp    8021f8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80221d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802220:	19 f2                	sbb    %esi,%edx
  802222:	e9 6f ff ff ff       	jmp    802196 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802227:	39 c7                	cmp    %eax,%edi
  802229:	72 f2                	jb     80221d <__umoddi3+0x161>
  80222b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80222e:	e9 63 ff ff ff       	jmp    802196 <__umoddi3+0xda>
