
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 37 02 00 00       	call   800268 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 04             	sub    $0x4,%esp
  80003b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 b7 0e 00 00       	call   800efc <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	43                   	inc    %ebx
  800046:	83 fb 0a             	cmp    $0xa,%ebx
  800049:	75 f5                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	6a 00                	push   $0x0
  800050:	e8 37 13 00 00       	call   80138c <close>
	if ((r = opencons()) < 0)
  800055:	e8 62 01 00 00       	call   8001bc <opencons>
  80005a:	83 c4 10             	add    $0x10,%esp
  80005d:	85 c0                	test   %eax,%eax
  80005f:	79 12                	jns    800073 <umain+0x3f>
		panic("opencons: %e", r);
  800061:	50                   	push   %eax
  800062:	68 00 20 80 00       	push   $0x802000
  800067:	6a 0f                	push   $0xf
  800069:	68 0d 20 80 00       	push   $0x80200d
  80006e:	e8 59 02 00 00       	call   8002cc <_panic>
	if (r != 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 12                	je     800089 <umain+0x55>
		panic("first opencons used fd %d", r);
  800077:	50                   	push   %eax
  800078:	68 1c 20 80 00       	push   $0x80201c
  80007d:	6a 11                	push   $0x11
  80007f:	68 0d 20 80 00       	push   $0x80200d
  800084:	e8 43 02 00 00       	call   8002cc <_panic>
	if ((r = dup(0, 1)) < 0)
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 01                	push   $0x1
  80008e:	6a 00                	push   $0x0
  800090:	e8 61 13 00 00       	call   8013f6 <dup>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 12                	jns    8000ae <umain+0x7a>
		panic("dup: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 36 20 80 00       	push   $0x802036
  8000a2:	6a 13                	push   $0x13
  8000a4:	68 0d 20 80 00       	push   $0x80200d
  8000a9:	e8 1e 02 00 00       	call   8002cc <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	68 3e 20 80 00       	push   $0x80203e
  8000b6:	e8 d1 07 00 00       	call   80088c <readline>
		if (buf != NULL)
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	85 c0                	test   %eax,%eax
  8000c0:	74 15                	je     8000d7 <umain+0xa3>
			fprintf(1, "%s\n", buf);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	50                   	push   %eax
  8000c6:	68 4c 20 80 00       	push   $0x80204c
  8000cb:	6a 01                	push   $0x1
  8000cd:	e8 9b 17 00 00       	call   80186d <fprintf>
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	eb d7                	jmp    8000ae <umain+0x7a>
		else
			fprintf(1, "(end of file received)\n");
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 50 20 80 00       	push   $0x802050
  8000df:	6a 01                	push   $0x1
  8000e1:	e8 87 17 00 00       	call   80186d <fprintf>
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	eb c3                	jmp    8000ae <umain+0x7a>
	...

008000ec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000fc:	68 68 20 80 00       	push   $0x802068
  800101:	ff 75 0c             	pushl  0xc(%ebp)
  800104:	e8 9a 08 00 00       	call   8009a3 <strcpy>
	return 0;
}
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  80011c:	be 00 00 00 00       	mov    $0x0,%esi
  800121:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  800127:	eb 2c                	jmp    800155 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800129:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80012c:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80012e:	83 fb 7f             	cmp    $0x7f,%ebx
  800131:	76 05                	jbe    800138 <devcons_write+0x28>
  800133:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800138:	83 ec 04             	sub    $0x4,%esp
  80013b:	53                   	push   %ebx
  80013c:	03 45 0c             	add    0xc(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	57                   	push   %edi
  800141:	e8 ca 09 00 00       	call   800b10 <memmove>
		sys_cputs(buf, m);
  800146:	83 c4 08             	add    $0x8,%esp
  800149:	53                   	push   %ebx
  80014a:	57                   	push   %edi
  80014b:	e8 97 0b 00 00       	call   800ce7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800150:	01 de                	add    %ebx,%esi
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	89 f0                	mov    %esi,%eax
  800157:	3b 75 10             	cmp    0x10(%ebp),%esi
  80015a:	72 cd                	jb     800129 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800170:	6a 01                	push   $0x1
  800172:	8d 45 ff             	lea    -0x1(%ebp),%eax
  800175:	50                   	push   %eax
  800176:	e8 6c 0b 00 00       	call   800ce7 <sys_cputs>
  80017b:	83 c4 10             	add    $0x10,%esp
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800186:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80018a:	74 27                	je     8001b3 <devcons_read+0x33>
  80018c:	eb 05                	jmp    800193 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80018e:	e8 69 0d 00 00       	call   800efc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800193:	e8 30 0b 00 00       	call   800cc8 <sys_cgetc>
  800198:	89 c2                	mov    %eax,%edx
  80019a:	85 c0                	test   %eax,%eax
  80019c:	74 f0                	je     80018e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	78 16                	js     8001b8 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001a2:	83 f8 04             	cmp    $0x4,%eax
  8001a5:	74 0c                	je     8001b3 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  8001a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001aa:	88 10                	mov    %dl,(%eax)
  8001ac:	ba 01 00 00 00       	mov    $0x1,%edx
  8001b1:	eb 05                	jmp    8001b8 <devcons_read+0x38>
	return 1;
  8001b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8001b8:	89 d0                	mov    %edx,%eax
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8001c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 d9 0d 00 00       	call   800fa4 <fd_alloc>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	78 3b                	js     80020d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	68 07 04 00 00       	push   $0x407
  8001da:	ff 75 fc             	pushl  -0x4(%ebp)
  8001dd:	6a 00                	push   $0x0
  8001df:	e8 d5 0c 00 00       	call   800eb9 <sys_page_alloc>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	85 c0                	test   %eax,%eax
  8001e9:	78 22                	js     80020d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8001eb:	a1 00 30 80 00       	mov    0x803000,%eax
  8001f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8001f3:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  8001f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8001f8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	ff 75 fc             	pushl  -0x4(%ebp)
  800205:	e8 72 0d 00 00       	call   800f7c <fd2num>
  80020a:	83 c4 10             	add    $0x10,%esp
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800215:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 d6 0d 00 00       	call   800ff7 <fd_lookup>
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	85 c0                	test   %eax,%eax
  800226:	78 11                	js     800239 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800228:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80022b:	8b 00                	mov    (%eax),%eax
  80022d:	3b 05 00 30 80 00    	cmp    0x803000,%eax
  800233:	0f 94 c0             	sete   %al
  800236:	0f b6 c0             	movzbl %al,%eax
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800241:	6a 01                	push   $0x1
  800243:	8d 45 ff             	lea    -0x1(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	6a 00                	push   $0x0
  800249:	e8 e8 0f 00 00       	call   801236 <read>
	if (r < 0)
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	85 c0                	test   %eax,%eax
  800253:	78 0f                	js     800264 <getchar+0x29>
		return r;
	if (r < 1)
  800255:	85 c0                	test   %eax,%eax
  800257:	75 07                	jne    800260 <getchar+0x25>
  800259:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80025e:	eb 04                	jmp    800264 <getchar+0x29>
		return -E_EOF;
	return c;
  800260:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	8b 75 08             	mov    0x8(%ebp),%esi
  800270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800273:	e8 a3 0c 00 00       	call   800f1b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800278:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800284:	c1 e0 07             	shl    $0x7,%eax
  800287:	29 d0                	sub    %edx,%eax
  800289:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80028e:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800293:	85 f6                	test   %esi,%esi
  800295:	7e 07                	jle    80029e <libmain+0x36>
		binaryname = argv[0];
  800297:	8b 03                	mov    (%ebx),%eax
  800299:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	53                   	push   %ebx
  8002a2:	56                   	push   %esi
  8002a3:	e8 8c fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8002a8:	e8 0b 00 00 00       	call   8002b8 <exit>
  8002ad:	83 c4 10             	add    $0x10,%esp
}
  8002b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    
	...

008002b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8002be:	6a 00                	push   $0x0
  8002c0:	e8 75 0c 00 00       	call   800f3a <sys_env_destroy>
  8002c5:	83 c4 10             	add    $0x10,%esp
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8002d6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d9:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  8002df:	e8 37 0c 00 00       	call   800f1b <sys_getenvid>
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ea:	ff 75 08             	pushl  0x8(%ebp)
  8002ed:	53                   	push   %ebx
  8002ee:	50                   	push   %eax
  8002ef:	68 80 20 80 00       	push   $0x802080
  8002f4:	e8 74 00 00 00       	call   80036d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	ff 75 f8             	pushl  -0x8(%ebp)
  8002ff:	ff 75 10             	pushl  0x10(%ebp)
  800302:	e8 15 00 00 00       	call   80031c <vcprintf>
	cprintf("\n");
  800307:	c7 04 24 66 20 80 00 	movl   $0x802066,(%esp)
  80030e:	e8 5a 00 00 00       	call   80036d <cprintf>
  800313:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800316:	cc                   	int3   
  800317:	eb fd                	jmp    800316 <_panic+0x4a>
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800325:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  80032c:	00 00 00 
	b.cnt = 0;
  80032f:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800336:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800339:	ff 75 0c             	pushl  0xc(%ebp)
  80033c:	ff 75 08             	pushl  0x8(%ebp)
  80033f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800345:	50                   	push   %eax
  800346:	68 84 03 80 00       	push   $0x800384
  80034b:	e8 70 01 00 00       	call   8004c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800350:	83 c4 08             	add    $0x8,%esp
  800353:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800359:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80035f:	50                   	push   %eax
  800360:	e8 82 09 00 00       	call   800ce7 <sys_cputs>
  800365:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800373:	8d 45 0c             	lea    0xc(%ebp),%eax
  800376:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 9a ff ff ff       	call   80031c <vcprintf>
	va_end(ap);

	return cnt;
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 03                	mov    (%ebx),%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800397:	40                   	inc    %eax
  800398:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039f:	75 1a                	jne    8003bb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	68 ff 00 00 00       	push   $0xff
  8003a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ac:	50                   	push   %eax
  8003ad:	e8 35 09 00 00       	call   800ce7 <sys_cputs>
		b->idx = 0;
  8003b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bb:	ff 43 04             	incl   0x4(%ebx)
}
  8003be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    
	...

008003c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	83 ec 1c             	sub    $0x1c,%esp
  8003cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8003d0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003df:	8b 55 10             	mov    0x10(%ebp),%edx
  8003e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e5:	89 d6                	mov    %edx,%esi
  8003e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8003ec:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8003ef:	72 04                	jb     8003f5 <printnum+0x31>
  8003f1:	39 c2                	cmp    %eax,%edx
  8003f3:	77 3f                	ja     800434 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f5:	83 ec 0c             	sub    $0xc,%esp
  8003f8:	ff 75 18             	pushl  0x18(%ebp)
  8003fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8003fe:	50                   	push   %eax
  8003ff:	52                   	push   %edx
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	ff 75 e4             	pushl  -0x1c(%ebp)
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	e8 3c 19 00 00       	call   801d4c <__udivdi3>
  800410:	83 c4 18             	add    $0x18,%esp
  800413:	52                   	push   %edx
  800414:	50                   	push   %eax
  800415:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800418:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80041b:	e8 a4 ff ff ff       	call   8003c4 <printnum>
  800420:	83 c4 20             	add    $0x20,%esp
  800423:	eb 14                	jmp    800439 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 e8             	pushl  -0x18(%ebp)
  80042b:	ff 75 18             	pushl  0x18(%ebp)
  80042e:	ff 55 ec             	call   *-0x14(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800434:	4b                   	dec    %ebx
  800435:	85 db                	test   %ebx,%ebx
  800437:	7f ec                	jg     800425 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	ff 75 e8             	pushl  -0x18(%ebp)
  80043f:	83 ec 04             	sub    $0x4,%esp
  800442:	57                   	push   %edi
  800443:	56                   	push   %esi
  800444:	ff 75 e4             	pushl  -0x1c(%ebp)
  800447:	ff 75 e0             	pushl  -0x20(%ebp)
  80044a:	e8 29 1a 00 00       	call   801e78 <__umoddi3>
  80044f:	83 c4 14             	add    $0x14,%esp
  800452:	0f be 80 a3 20 80 00 	movsbl 0x8020a3(%eax),%eax
  800459:	50                   	push   %eax
  80045a:	ff 55 ec             	call   *-0x14(%ebp)
  80045d:	83 c4 10             	add    $0x10,%esp
}
  800460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800463:	5b                   	pop    %ebx
  800464:	5e                   	pop    %esi
  800465:	5f                   	pop    %edi
  800466:	c9                   	leave  
  800467:	c3                   	ret    

00800468 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80046d:	83 fa 01             	cmp    $0x1,%edx
  800470:	7e 0e                	jle    800480 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 42 08             	lea    0x8(%edx),%eax
  800477:	89 01                	mov    %eax,(%ecx)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	8b 52 04             	mov    0x4(%edx),%edx
  80047e:	eb 22                	jmp    8004a2 <getuint+0x3a>
	else if (lflag)
  800480:	85 d2                	test   %edx,%edx
  800482:	74 10                	je     800494 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800484:	8b 10                	mov    (%eax),%edx
  800486:	8d 42 04             	lea    0x4(%edx),%eax
  800489:	89 01                	mov    %eax,(%ecx)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	eb 0e                	jmp    8004a2 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 42 04             	lea    0x4(%edx),%eax
  800499:	89 01                	mov    %eax,(%ecx)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8004aa:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8004ad:	8b 11                	mov    (%ecx),%edx
  8004af:	3b 51 04             	cmp    0x4(%ecx),%edx
  8004b2:	73 0a                	jae    8004be <sprintputch+0x1a>
		*b->buf++ = ch;
  8004b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b7:	88 02                	mov    %al,(%edx)
  8004b9:	8d 42 01             	lea    0x1(%edx),%eax
  8004bc:	89 01                	mov    %eax,(%ecx)
}
  8004be:	c9                   	leave  
  8004bf:	c3                   	ret    

008004c0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
  8004c6:	83 ec 3c             	sub    $0x3c,%esp
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8004cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8004d2:	eb 1a                	jmp    8004ee <vprintfmt+0x2e>
  8004d4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8004d7:	eb 15                	jmp    8004ee <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d9:	84 c0                	test   %al,%al
  8004db:	0f 84 15 03 00 00    	je     8007f6 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	57                   	push   %edi
  8004e5:	0f b6 c0             	movzbl %al,%eax
  8004e8:	50                   	push   %eax
  8004e9:	ff d6                	call   *%esi
  8004eb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ee:	8a 03                	mov    (%ebx),%al
  8004f0:	43                   	inc    %ebx
  8004f1:	3c 25                	cmp    $0x25,%al
  8004f3:	75 e4                	jne    8004d9 <vprintfmt+0x19>
  8004f5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800503:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80050a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800511:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800515:	eb 0a                	jmp    800521 <vprintfmt+0x61>
  800517:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80051e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8a 03                	mov    (%ebx),%al
  800523:	0f b6 d0             	movzbl %al,%edx
  800526:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800529:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  80052c:	83 e8 23             	sub    $0x23,%eax
  80052f:	3c 55                	cmp    $0x55,%al
  800531:	0f 87 9c 02 00 00    	ja     8007d3 <vprintfmt+0x313>
  800537:	0f b6 c0             	movzbl %al,%eax
  80053a:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  800541:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800545:	eb d7                	jmp    80051e <vprintfmt+0x5e>
  800547:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80054b:	eb d1                	jmp    80051e <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80054d:	89 d9                	mov    %ebx,%ecx
  80054f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800556:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800559:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80055c:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800563:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800567:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800568:	8d 42 d0             	lea    -0x30(%edx),%eax
  80056b:	83 f8 09             	cmp    $0x9,%eax
  80056e:	77 21                	ja     800591 <vprintfmt+0xd1>
  800570:	eb e4                	jmp    800556 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800572:	8b 55 14             	mov    0x14(%ebp),%edx
  800575:	8d 42 04             	lea    0x4(%edx),%eax
  800578:	89 45 14             	mov    %eax,0x14(%ebp)
  80057b:	8b 12                	mov    (%edx),%edx
  80057d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800580:	eb 12                	jmp    800594 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800582:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800586:	79 96                	jns    80051e <vprintfmt+0x5e>
  800588:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80058f:	eb 8d                	jmp    80051e <vprintfmt+0x5e>
  800591:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800594:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800598:	79 84                	jns    80051e <vprintfmt+0x5e>
  80059a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005a7:	e9 72 ff ff ff       	jmp    80051e <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ac:	ff 45 d4             	incl   -0x2c(%ebp)
  8005af:	e9 6a ff ff ff       	jmp    80051e <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b4:	8b 55 14             	mov    0x14(%ebp),%edx
  8005b7:	8d 42 04             	lea    0x4(%edx),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	57                   	push   %edi
  8005c1:	ff 32                	pushl  (%edx)
  8005c3:	ff d6                	call   *%esi
			break;
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	e9 07 ff ff ff       	jmp    8004d4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cd:	8b 55 14             	mov    0x14(%ebp),%edx
  8005d0:	8d 42 04             	lea    0x4(%edx),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d6:	8b 02                	mov    (%edx),%eax
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	79 02                	jns    8005de <vprintfmt+0x11e>
  8005dc:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005de:	83 f8 0f             	cmp    $0xf,%eax
  8005e1:	7f 0b                	jg     8005ee <vprintfmt+0x12e>
  8005e3:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	75 15                	jne    800603 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8005ee:	50                   	push   %eax
  8005ef:	68 b4 20 80 00       	push   $0x8020b4
  8005f4:	57                   	push   %edi
  8005f5:	56                   	push   %esi
  8005f6:	e8 6e 02 00 00       	call   800869 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	e9 d1 fe ff ff       	jmp    8004d4 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800603:	52                   	push   %edx
  800604:	68 81 24 80 00       	push   $0x802481
  800609:	57                   	push   %edi
  80060a:	56                   	push   %esi
  80060b:	e8 59 02 00 00       	call   800869 <printfmt>
  800610:	83 c4 10             	add    $0x10,%esp
  800613:	e9 bc fe ff ff       	jmp    8004d4 <vprintfmt+0x14>
  800618:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061b:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80061e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800621:	8b 55 14             	mov    0x14(%ebp),%edx
  800624:	8d 42 04             	lea    0x4(%edx),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
  80062a:	8b 1a                	mov    (%edx),%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	75 05                	jne    800635 <vprintfmt+0x175>
  800630:	bb bd 20 80 00       	mov    $0x8020bd,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800635:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800639:	7e 66                	jle    8006a1 <vprintfmt+0x1e1>
  80063b:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80063f:	74 60                	je     8006a1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	51                   	push   %ecx
  800645:	53                   	push   %ebx
  800646:	e8 3b 03 00 00       	call   800986 <strnlen>
  80064b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80064e:	29 c1                	sub    %eax,%ecx
  800650:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80065a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80065d:	eb 0f                	jmp    80066e <vprintfmt+0x1ae>
					putch(padc, putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	ff 75 c4             	pushl  -0x3c(%ebp)
  800666:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800668:	ff 4d d8             	decl   -0x28(%ebp)
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800672:	7f eb                	jg     80065f <vprintfmt+0x19f>
  800674:	eb 2b                	jmp    8006a1 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800676:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	74 15                	je     800694 <vprintfmt+0x1d4>
  80067f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800682:	83 f8 5e             	cmp    $0x5e,%eax
  800685:	76 0d                	jbe    800694 <vprintfmt+0x1d4>
					putch('?', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	57                   	push   %edi
  80068b:	6a 3f                	push   $0x3f
  80068d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb 0a                	jmp    80069e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	57                   	push   %edi
  800698:	52                   	push   %edx
  800699:	ff d6                	call   *%esi
  80069b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069e:	ff 4d d8             	decl   -0x28(%ebp)
  8006a1:	8a 03                	mov    (%ebx),%al
  8006a3:	43                   	inc    %ebx
  8006a4:	84 c0                	test   %al,%al
  8006a6:	74 1b                	je     8006c3 <vprintfmt+0x203>
  8006a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ac:	78 c8                	js     800676 <vprintfmt+0x1b6>
  8006ae:	ff 4d dc             	decl   -0x24(%ebp)
  8006b1:	79 c3                	jns    800676 <vprintfmt+0x1b6>
  8006b3:	eb 0e                	jmp    8006c3 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	57                   	push   %edi
  8006b9:	6a 20                	push   $0x20
  8006bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bd:	ff 4d d8             	decl   -0x28(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c7:	7f ec                	jg     8006b5 <vprintfmt+0x1f5>
  8006c9:	e9 06 fe ff ff       	jmp    8004d4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ce:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8006d2:	7e 10                	jle    8006e4 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8006d4:	8b 55 14             	mov    0x14(%ebp),%edx
  8006d7:	8d 42 08             	lea    0x8(%edx),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dd:	8b 02                	mov    (%edx),%eax
  8006df:	8b 52 04             	mov    0x4(%edx),%edx
  8006e2:	eb 20                	jmp    800704 <vprintfmt+0x244>
	else if (lflag)
  8006e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006e8:	74 0e                	je     8006f8 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	99                   	cltd   
  8006f6:	eb 0c                	jmp    800704 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800704:	89 d1                	mov    %edx,%ecx
  800706:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800708:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80070b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80070e:	85 c9                	test   %ecx,%ecx
  800710:	78 0a                	js     80071c <vprintfmt+0x25c>
  800712:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800717:	e9 89 00 00 00       	jmp    8007a5 <vprintfmt+0x2e5>
				putch('-', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	57                   	push   %edi
  800720:	6a 2d                	push   $0x2d
  800722:	ff d6                	call   *%esi
				num = -(long long) num;
  800724:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800727:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80072a:	f7 da                	neg    %edx
  80072c:	83 d1 00             	adc    $0x0,%ecx
  80072f:	f7 d9                	neg    %ecx
  800731:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 6a                	jmp    8007a5 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800741:	e8 22 fd ff ff       	call   800468 <getuint>
  800746:	89 d1                	mov    %edx,%ecx
  800748:	89 c2                	mov    %eax,%edx
  80074a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80074f:	eb 54                	jmp    8007a5 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800757:	e8 0c fd ff ff       	call   800468 <getuint>
  80075c:	89 d1                	mov    %edx,%ecx
  80075e:	89 c2                	mov    %eax,%edx
  800760:	bb 08 00 00 00       	mov    $0x8,%ebx
  800765:	eb 3e                	jmp    8007a5 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	57                   	push   %edi
  80076b:	6a 30                	push   $0x30
  80076d:	ff d6                	call   *%esi
			putch('x', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	57                   	push   %edi
  800773:	6a 78                	push   $0x78
  800775:	ff d6                	call   *%esi
			num = (unsigned long long)
  800777:	8b 55 14             	mov    0x14(%ebp),%edx
  80077a:	8d 42 04             	lea    0x4(%edx),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
  800780:	8b 12                	mov    (%edx),%edx
  800782:	b9 00 00 00 00       	mov    $0x0,%ecx
  800787:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 14                	jmp    8007a5 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800797:	e8 cc fc ff ff       	call   800468 <getuint>
  80079c:	89 d1                	mov    %edx,%ecx
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8007b0:	53                   	push   %ebx
  8007b1:	51                   	push   %ecx
  8007b2:	52                   	push   %edx
  8007b3:	89 fa                	mov    %edi,%edx
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	e8 08 fc ff ff       	call   8003c4 <printnum>
			break;
  8007bc:	83 c4 20             	add    $0x20,%esp
  8007bf:	e9 10 fd ff ff       	jmp    8004d4 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	57                   	push   %edi
  8007c8:	52                   	push   %edx
  8007c9:	ff d6                	call   *%esi
			break;
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	e9 01 fd ff ff       	jmp    8004d4 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	57                   	push   %edi
  8007d7:	6a 25                	push   $0x25
  8007d9:	ff d6                	call   *%esi
  8007db:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8007de:	83 ea 02             	sub    $0x2,%edx
  8007e1:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e4:	8a 02                	mov    (%edx),%al
  8007e6:	4a                   	dec    %edx
  8007e7:	3c 25                	cmp    $0x25,%al
  8007e9:	75 f9                	jne    8007e4 <vprintfmt+0x324>
  8007eb:	83 c2 02             	add    $0x2,%edx
  8007ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8007f1:	e9 de fc ff ff       	jmp    8004d4 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8007f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5f                   	pop    %edi
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 18             	sub    $0x18,%esp
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80080a:	85 d2                	test   %edx,%edx
  80080c:	74 37                	je     800845 <vsnprintf+0x47>
  80080e:	85 c0                	test   %eax,%eax
  800810:	7e 33                	jle    800845 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800812:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800819:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80081d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800820:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800823:	ff 75 14             	pushl  0x14(%ebp)
  800826:	ff 75 10             	pushl  0x10(%ebp)
  800829:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082c:	50                   	push   %eax
  80082d:	68 a4 04 80 00       	push   $0x8004a4
  800832:	e8 89 fc ff ff       	call   8004c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	eb 05                	jmp    80084a <vsnprintf+0x4c>
  800845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 97 ff ff ff       	call   8007fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
  800872:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800875:	50                   	push   %eax
  800876:	ff 75 10             	pushl  0x10(%ebp)
  800879:	ff 75 0c             	pushl  0xc(%ebp)
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 3c fc ff ff       	call   8004c0 <vprintfmt>
	va_end(ap);
  800884:	83 c4 10             	add    $0x10,%esp
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    
  800889:	00 00                	add    %al,(%eax)
	...

0080088c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	83 ec 0c             	sub    $0xc,%esp
  800895:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800898:	85 c0                	test   %eax,%eax
  80089a:	74 13                	je     8008af <readline+0x23>
		fprintf(1, "%s", prompt);
  80089c:	83 ec 04             	sub    $0x4,%esp
  80089f:	50                   	push   %eax
  8008a0:	68 81 24 80 00       	push   $0x802481
  8008a5:	6a 01                	push   $0x1
  8008a7:	e8 c1 0f 00 00       	call   80186d <fprintf>
  8008ac:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	6a 00                	push   $0x0
  8008b4:	e8 56 f9 ff ff       	call   80020f <iscons>
  8008b9:	89 c7                	mov    %eax,%edi
  8008bb:	be 00 00 00 00       	mov    $0x0,%esi
  8008c0:	83 c4 10             	add    $0x10,%esp
	while (1) {
		c = getchar();
  8008c3:	e8 73 f9 ff ff       	call   80023b <getchar>
  8008c8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	79 27                	jns    8008f5 <readline+0x69>
			if (c != -E_EOF)
  8008ce:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8008d1:	75 0a                	jne    8008dd <readline+0x51>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	e9 8b 00 00 00       	jmp    800968 <readline+0xdc>
				cprintf("read error: %e\n", c);
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	50                   	push   %eax
  8008e1:	68 9f 23 80 00       	push   $0x80239f
  8008e6:	e8 82 fa ff ff       	call   80036d <cprintf>
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	eb 73                	jmp    800968 <readline+0xdc>
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8008f5:	83 f8 08             	cmp    $0x8,%eax
  8008f8:	74 05                	je     8008ff <readline+0x73>
  8008fa:	83 f8 7f             	cmp    $0x7f,%eax
  8008fd:	75 18                	jne    800917 <readline+0x8b>
  8008ff:	85 f6                	test   %esi,%esi
  800901:	7e 14                	jle    800917 <readline+0x8b>
			if (echoing)
  800903:	85 ff                	test   %edi,%edi
  800905:	74 0d                	je     800914 <readline+0x88>
				cputchar('\b');
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 08                	push   $0x8
  80090c:	e8 53 f8 ff ff       	call   800164 <cputchar>
  800911:	83 c4 10             	add    $0x10,%esp
			i--;
  800914:	4e                   	dec    %esi
  800915:	eb ac                	jmp    8008c3 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800917:	83 fb 1f             	cmp    $0x1f,%ebx
  80091a:	7e 21                	jle    80093d <readline+0xb1>
  80091c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800922:	7f 9f                	jg     8008c3 <readline+0x37>
			if (echoing)
  800924:	85 ff                	test   %edi,%edi
  800926:	74 0c                	je     800934 <readline+0xa8>
				cputchar(c);
  800928:	83 ec 0c             	sub    $0xc,%esp
  80092b:	53                   	push   %ebx
  80092c:	e8 33 f8 ff ff       	call   800164 <cputchar>
  800931:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800934:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  80093a:	46                   	inc    %esi
  80093b:	eb 86                	jmp    8008c3 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80093d:	83 fb 0a             	cmp    $0xa,%ebx
  800940:	74 09                	je     80094b <readline+0xbf>
  800942:	83 fb 0d             	cmp    $0xd,%ebx
  800945:	0f 85 78 ff ff ff    	jne    8008c3 <readline+0x37>
			if (echoing)
  80094b:	85 ff                	test   %edi,%edi
  80094d:	74 0d                	je     80095c <readline+0xd0>
				cputchar('\n');
  80094f:	83 ec 0c             	sub    $0xc,%esp
  800952:	6a 0a                	push   $0xa
  800954:	e8 0b f8 ff ff       	call   800164 <cputchar>
  800959:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80095c:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
  800963:	b8 00 40 80 00       	mov    $0x804000,%eax
			return buf;
		}
	}
}
  800968:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 01                	jmp    80097e <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  80097d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800982:	75 f9                	jne    80097d <strlen+0xd>
		n++;
	return n;
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
  800994:	eb 01                	jmp    800997 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800996:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800997:	39 d0                	cmp    %edx,%eax
  800999:	74 06                	je     8009a1 <strnlen+0x1b>
  80099b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80099f:	75 f5                	jne    800996 <strnlen+0x10>
		n++;
	return n;
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a9:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ac:	8a 01                	mov    (%ecx),%al
  8009ae:	88 02                	mov    %al,(%edx)
  8009b0:	42                   	inc    %edx
  8009b1:	41                   	inc    %ecx
  8009b2:	84 c0                	test   %al,%al
  8009b4:	75 f6                	jne    8009ac <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c2:	53                   	push   %ebx
  8009c3:	e8 a8 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009c8:	ff 75 0c             	pushl  0xc(%ebp)
  8009cb:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009ce:	50                   	push   %eax
  8009cf:	e8 cf ff ff ff       	call   8009a3 <strcpy>
	return dst;
}
  8009d4:	89 d8                	mov    %ebx,%eax
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009ee:	eb 0c                	jmp    8009fc <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009f0:	8a 02                	mov    (%edx),%al
  8009f2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fb:	41                   	inc    %ecx
  8009fc:	39 d9                	cmp    %ebx,%ecx
  8009fe:	75 f0                	jne    8009f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a00:	89 f0                	mov    %esi,%eax
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a11:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a14:	85 c9                	test   %ecx,%ecx
  800a16:	75 04                	jne    800a1c <strlcpy+0x16>
  800a18:	89 f0                	mov    %esi,%eax
  800a1a:	eb 14                	jmp    800a30 <strlcpy+0x2a>
  800a1c:	89 f0                	mov    %esi,%eax
  800a1e:	eb 04                	jmp    800a24 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a20:	88 10                	mov    %dl,(%eax)
  800a22:	40                   	inc    %eax
  800a23:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a24:	49                   	dec    %ecx
  800a25:	74 06                	je     800a2d <strlcpy+0x27>
  800a27:	8a 13                	mov    (%ebx),%dl
  800a29:	84 d2                	test   %dl,%dl
  800a2b:	75 f3                	jne    800a20 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a2d:	c6 00 00             	movb   $0x0,(%eax)
  800a30:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3f:	eb 02                	jmp    800a43 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800a41:	42                   	inc    %edx
  800a42:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a43:	8a 02                	mov    (%edx),%al
  800a45:	84 c0                	test   %al,%al
  800a47:	74 04                	je     800a4d <strcmp+0x17>
  800a49:	3a 01                	cmp    (%ecx),%al
  800a4b:	74 f4                	je     800a41 <strcmp+0xb>
  800a4d:	0f b6 c0             	movzbl %al,%eax
  800a50:	0f b6 11             	movzbl (%ecx),%edx
  800a53:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a61:	8b 55 10             	mov    0x10(%ebp),%edx
  800a64:	eb 03                	jmp    800a69 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a66:	4a                   	dec    %edx
  800a67:	41                   	inc    %ecx
  800a68:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	85 d2                	test   %edx,%edx
  800a6b:	75 07                	jne    800a74 <strncmp+0x1d>
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	eb 14                	jmp    800a88 <strncmp+0x31>
  800a74:	8a 01                	mov    (%ecx),%al
  800a76:	84 c0                	test   %al,%al
  800a78:	74 04                	je     800a7e <strncmp+0x27>
  800a7a:	3a 03                	cmp    (%ebx),%al
  800a7c:	74 e8                	je     800a66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7e:	0f b6 d0             	movzbl %al,%edx
  800a81:	0f b6 03             	movzbl (%ebx),%eax
  800a84:	29 c2                	sub    %eax,%edx
  800a86:	89 d0                	mov    %edx,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a94:	eb 05                	jmp    800a9b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0c                	je     800aa6 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	40                   	inc    %eax
  800a9b:	8a 10                	mov    (%eax),%dl
  800a9d:	84 d2                	test   %dl,%dl
  800a9f:	75 f5                	jne    800a96 <strchr+0xb>
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ab1:	eb 05                	jmp    800ab8 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800ab3:	38 ca                	cmp    %cl,%dl
  800ab5:	74 07                	je     800abe <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ab7:	40                   	inc    %eax
  800ab8:	8a 10                	mov    (%eax),%dl
  800aba:	84 d2                	test   %dl,%dl
  800abc:	75 f5                	jne    800ab3 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800acf:	85 db                	test   %ebx,%ebx
  800ad1:	74 36                	je     800b09 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad9:	75 29                	jne    800b04 <memset+0x44>
  800adb:	f6 c3 03             	test   $0x3,%bl
  800ade:	75 24                	jne    800b04 <memset+0x44>
		c &= 0xFF;
  800ae0:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	c1 e6 08             	shl    $0x8,%esi
  800ae8:	89 d0                	mov    %edx,%eax
  800aea:	c1 e0 18             	shl    $0x18,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	c1 e1 10             	shl    $0x10,%ecx
  800af2:	09 c8                	or     %ecx,%eax
  800af4:	09 c2                	or     %eax,%edx
  800af6:	89 f0                	mov    %esi,%eax
  800af8:	09 d0                	or     %edx,%eax
  800afa:	89 d9                	mov    %ebx,%ecx
  800afc:	c1 e9 02             	shr    $0x2,%ecx
  800aff:	fc                   	cld    
  800b00:	f3 ab                	rep stos %eax,%es:(%edi)
  800b02:	eb 05                	jmp    800b09 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b04:	89 d9                	mov    %ebx,%ecx
  800b06:	fc                   	cld    
  800b07:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b09:	89 f8                	mov    %edi,%eax
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b1e:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b20:	39 c6                	cmp    %eax,%esi
  800b22:	73 36                	jae    800b5a <memmove+0x4a>
  800b24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b27:	39 d0                	cmp    %edx,%eax
  800b29:	73 2f                	jae    800b5a <memmove+0x4a>
		s += n;
		d += n;
  800b2b:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2e:	f6 c2 03             	test   $0x3,%dl
  800b31:	75 1b                	jne    800b4e <memmove+0x3e>
  800b33:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b39:	75 13                	jne    800b4e <memmove+0x3e>
  800b3b:	f6 c1 03             	test   $0x3,%cl
  800b3e:	75 0e                	jne    800b4e <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800b40:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b43:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b46:	c1 e9 02             	shr    $0x2,%ecx
  800b49:	fd                   	std    
  800b4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4c:	eb 09                	jmp    800b57 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4e:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b51:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b54:	fd                   	std    
  800b55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b57:	fc                   	cld    
  800b58:	eb 20                	jmp    800b7a <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b60:	75 15                	jne    800b77 <memmove+0x67>
  800b62:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b68:	75 0d                	jne    800b77 <memmove+0x67>
  800b6a:	f6 c1 03             	test   $0x3,%cl
  800b6d:	75 08                	jne    800b77 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b6f:	c1 e9 02             	shr    $0x2,%ecx
  800b72:	fc                   	cld    
  800b73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b75:	eb 03                	jmp    800b7a <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b77:	fc                   	cld    
  800b78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b81:	ff 75 10             	pushl  0x10(%ebp)
  800b84:	ff 75 0c             	pushl  0xc(%ebp)
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 81 ff ff ff       	call   800b10 <memmove>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	83 ec 04             	sub    $0x4,%esp
  800b98:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	eb 1b                	jmp    800bbe <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800ba3:	8a 1a                	mov    (%edx),%bl
  800ba5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800ba8:	8a 19                	mov    (%ecx),%bl
  800baa:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800bad:	74 0d                	je     800bbc <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800baf:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800bb3:	0f b6 c3             	movzbl %bl,%eax
  800bb6:	29 c2                	sub    %eax,%edx
  800bb8:	89 d0                	mov    %edx,%eax
  800bba:	eb 0d                	jmp    800bc9 <memcmp+0x38>
		s1++, s2++;
  800bbc:	42                   	inc    %edx
  800bbd:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbe:	48                   	dec    %eax
  800bbf:	83 f8 ff             	cmp    $0xffffffff,%eax
  800bc2:	75 df                	jne    800ba3 <memcmp+0x12>
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bc9:	83 c4 04             	add    $0x4,%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	03 55 10             	add    0x10(%ebp),%edx
  800bdd:	eb 05                	jmp    800be4 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bdf:	38 08                	cmp    %cl,(%eax)
  800be1:	74 05                	je     800be8 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be3:	40                   	inc    %eax
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	72 f7                	jb     800bdf <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 04             	sub    $0x4,%esp
  800bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf6:	8b 75 10             	mov    0x10(%ebp),%esi
  800bf9:	eb 01                	jmp    800bfc <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bfb:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	8a 01                	mov    (%ecx),%al
  800bfe:	3c 20                	cmp    $0x20,%al
  800c00:	74 f9                	je     800bfb <strtol+0x11>
  800c02:	3c 09                	cmp    $0x9,%al
  800c04:	74 f5                	je     800bfb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c06:	3c 2b                	cmp    $0x2b,%al
  800c08:	75 0a                	jne    800c14 <strtol+0x2a>
		s++;
  800c0a:	41                   	inc    %ecx
  800c0b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c12:	eb 17                	jmp    800c2b <strtol+0x41>
	else if (*s == '-')
  800c14:	3c 2d                	cmp    $0x2d,%al
  800c16:	74 09                	je     800c21 <strtol+0x37>
  800c18:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c1f:	eb 0a                	jmp    800c2b <strtol+0x41>
		s++, neg = 1;
  800c21:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c24:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2b:	85 f6                	test   %esi,%esi
  800c2d:	74 05                	je     800c34 <strtol+0x4a>
  800c2f:	83 fe 10             	cmp    $0x10,%esi
  800c32:	75 1a                	jne    800c4e <strtol+0x64>
  800c34:	8a 01                	mov    (%ecx),%al
  800c36:	3c 30                	cmp    $0x30,%al
  800c38:	75 10                	jne    800c4a <strtol+0x60>
  800c3a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c3e:	75 0a                	jne    800c4a <strtol+0x60>
		s += 2, base = 16;
  800c40:	83 c1 02             	add    $0x2,%ecx
  800c43:	be 10 00 00 00       	mov    $0x10,%esi
  800c48:	eb 04                	jmp    800c4e <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800c4a:	85 f6                	test   %esi,%esi
  800c4c:	74 07                	je     800c55 <strtol+0x6b>
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c53:	eb 13                	jmp    800c68 <strtol+0x7e>
  800c55:	3c 30                	cmp    $0x30,%al
  800c57:	74 07                	je     800c60 <strtol+0x76>
  800c59:	be 0a 00 00 00       	mov    $0xa,%esi
  800c5e:	eb ee                	jmp    800c4e <strtol+0x64>
		s++, base = 8;
  800c60:	41                   	inc    %ecx
  800c61:	be 08 00 00 00       	mov    $0x8,%esi
  800c66:	eb e6                	jmp    800c4e <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c68:	8a 11                	mov    (%ecx),%dl
  800c6a:	88 d3                	mov    %dl,%bl
  800c6c:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c6f:	3c 09                	cmp    $0x9,%al
  800c71:	77 08                	ja     800c7b <strtol+0x91>
			dig = *s - '0';
  800c73:	0f be c2             	movsbl %dl,%eax
  800c76:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c79:	eb 1c                	jmp    800c97 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c7b:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c7e:	3c 19                	cmp    $0x19,%al
  800c80:	77 08                	ja     800c8a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c82:	0f be c2             	movsbl %dl,%eax
  800c85:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c88:	eb 0d                	jmp    800c97 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c8a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c8d:	3c 19                	cmp    $0x19,%al
  800c8f:	77 15                	ja     800ca6 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c91:	0f be c2             	movsbl %dl,%eax
  800c94:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c97:	39 f2                	cmp    %esi,%edx
  800c99:	7d 0b                	jge    800ca6 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c9b:	41                   	inc    %ecx
  800c9c:	89 f8                	mov    %edi,%eax
  800c9e:	0f af c6             	imul   %esi,%eax
  800ca1:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800ca4:	eb c2                	jmp    800c68 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800ca6:	89 f8                	mov    %edi,%eax

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 05                	je     800cb3 <strtol+0xc9>
		*endptr = (char *) s;
  800cae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb1:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800cb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cb7:	74 04                	je     800cbd <strtol+0xd3>
  800cb9:	89 c7                	mov    %eax,%edi
  800cbb:	f7 df                	neg    %edi
}
  800cbd:	89 f8                	mov    %edi,%eax
  800cbf:	83 c4 04             	add    $0x4,%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    
	...

00800cc8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd8:	89 fa                	mov    %edi,%edx
  800cda:	89 f9                	mov    %edi,%ecx
  800cdc:	89 fb                	mov    %edi,%ebx
  800cde:	89 fe                	mov    %edi,%esi
  800ce0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 04             	sub    $0x4,%esp
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cfb:	89 f8                	mov    %edi,%eax
  800cfd:	89 fb                	mov    %edi,%ebx
  800cff:	89 fe                	mov    %edi,%esi
  800d01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d03:	83 c4 04             	add    $0x4,%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	89 fb                	mov    %edi,%ebx
  800d25:	89 fe                	mov    %edi,%esi
  800d27:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 0d                	push   $0xd
  800d33:	68 af 23 80 00       	push   $0x8023af
  800d38:	6a 23                	push   $0x23
  800d3a:	68 cc 23 80 00       	push   $0x8023cc
  800d3f:	e8 88 f5 ff ff       	call   8002cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5b:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d63:	be 00 00 00 00       	mov    $0x0,%esi
  800d68:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d7e:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d90:	7e 17                	jle    800da9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 0a                	push   $0xa
  800d98:	68 af 23 80 00       	push   $0x8023af
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 cc 23 80 00       	push   $0x8023cc
  800da4:	e8 23 f5 ff ff       	call   8002cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800dc0:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800dd2:	7e 17                	jle    800deb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 09                	push   $0x9
  800dda:	68 af 23 80 00       	push   $0x8023af
  800ddf:	6a 23                	push   $0x23
  800de1:	68 cc 23 80 00       	push   $0x8023cc
  800de6:	e8 e1 f4 ff ff       	call   8002cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b8 08 00 00 00       	mov    $0x8,%eax
  800e07:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0c:	89 fb                	mov    %edi,%ebx
  800e0e:	89 fe                	mov    %edi,%esi
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 08                	push   $0x8
  800e1c:	68 af 23 80 00       	push   $0x8023af
  800e21:	6a 23                	push   $0x23
  800e23:	68 cc 23 80 00       	push   $0x8023cc
  800e28:	e8 9f f4 ff ff       	call   8002cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e44:	b8 06 00 00 00       	mov    $0x6,%eax
  800e49:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4e:	89 fb                	mov    %edi,%ebx
  800e50:	89 fe                	mov    %edi,%esi
  800e52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 17                	jle    800e6f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 06                	push   $0x6
  800e5e:	68 af 23 80 00       	push   $0x8023af
  800e63:	6a 23                	push   $0x23
  800e65:	68 cc 23 80 00       	push   $0x8023cc
  800e6a:	e8 5d f4 ff ff       	call   8002cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8c:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 17                	jle    800eb1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	50                   	push   %eax
  800e9e:	6a 05                	push   $0x5
  800ea0:	68 af 23 80 00       	push   $0x8023af
  800ea5:	6a 23                	push   $0x23
  800ea7:	68 cc 23 80 00       	push   $0x8023cc
  800eac:	e8 1b f4 ff ff       	call   8002cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecb:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed5:	89 fe                	mov    %edi,%esi
  800ed7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 17                	jle    800ef4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	50                   	push   %eax
  800ee1:	6a 04                	push   $0x4
  800ee3:	68 af 23 80 00       	push   $0x8023af
  800ee8:	6a 23                	push   $0x23
  800eea:	68 cc 23 80 00       	push   $0x8023cc
  800eef:	e8 d8 f3 ff ff       	call   8002cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 fb                	mov    %edi,%ebx
  800f12:	89 fe                	mov    %edi,%esi
  800f14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f21:	b8 02 00 00 00       	mov    $0x2,%eax
  800f26:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2b:	89 fa                	mov    %edi,%edx
  800f2d:	89 f9                	mov    %edi,%ecx
  800f2f:	89 fb                	mov    %edi,%ebx
  800f31:	89 fe                	mov    %edi,%esi
  800f33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	b8 03 00 00 00       	mov    $0x3,%eax
  800f4b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f50:	89 f9                	mov    %edi,%ecx
  800f52:	89 fb                	mov    %edi,%ebx
  800f54:	89 fe                	mov    %edi,%esi
  800f56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7e 17                	jle    800f73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	50                   	push   %eax
  800f60:	6a 03                	push   $0x3
  800f62:	68 af 23 80 00       	push   $0x8023af
  800f67:	6a 23                	push   $0x23
  800f69:	68 cc 23 80 00       	push   $0x8023cc
  800f6e:	e8 59 f3 ff ff       	call   8002cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    
	...

00800f7c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	05 00 00 00 30       	add    $0x30000000,%eax
  800f87:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	e8 e5 ff ff ff       	call   800f7c <fd2num>
  800f97:	83 c4 04             	add    $0x4,%esp
  800f9a:	c1 e0 0c             	shl    $0xc,%eax
  800f9d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	53                   	push   %ebx
  800fa8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fab:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800fb0:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fb2:	89 d0                	mov    %edx,%eax
  800fb4:	c1 e8 16             	shr    $0x16,%eax
  800fb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fbe:	a8 01                	test   $0x1,%al
  800fc0:	74 10                	je     800fd2 <fd_alloc+0x2e>
  800fc2:	89 d0                	mov    %edx,%eax
  800fc4:	c1 e8 0c             	shr    $0xc,%eax
  800fc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fce:	a8 01                	test   $0x1,%al
  800fd0:	75 09                	jne    800fdb <fd_alloc+0x37>
			*fd_store = fd;
  800fd2:	89 0b                	mov    %ecx,(%ebx)
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	eb 19                	jmp    800ff4 <fd_alloc+0x50>
			return 0;
  800fdb:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fe1:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  800fe7:	75 c7                	jne    800fb0 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800fef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800ff4:	5b                   	pop    %ebx
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ffd:	83 f8 1f             	cmp    $0x1f,%eax
  801000:	77 35                	ja     801037 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801002:	c1 e0 0c             	shl    $0xc,%eax
  801005:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	c1 e8 16             	shr    $0x16,%eax
  801010:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801017:	a8 01                	test   $0x1,%al
  801019:	74 1c                	je     801037 <fd_lookup+0x40>
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	c1 e8 0c             	shr    $0xc,%eax
  801020:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801027:	a8 01                	test   $0x1,%al
  801029:	74 0c                	je     801037 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80102b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102e:	89 10                	mov    %edx,(%eax)
  801030:	b8 00 00 00 00       	mov    $0x0,%eax
  801035:	eb 05                	jmp    80103c <fd_lookup+0x45>
	return 0;
  801037:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801044:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	ff 75 08             	pushl  0x8(%ebp)
  80104b:	e8 a7 ff ff ff       	call   800ff7 <fd_lookup>
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	85 c0                	test   %eax,%eax
  801055:	78 0e                	js     801065 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80105d:	89 50 04             	mov    %edx,0x4(%eax)
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	53                   	push   %ebx
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801071:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801074:	ba 00 00 00 00       	mov    $0x0,%edx
  801079:	eb 0e                	jmp    801089 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80107b:	3b 08                	cmp    (%eax),%ecx
  80107d:	75 09                	jne    801088 <dev_lookup+0x21>
			*dev = devtab[i];
  80107f:	89 03                	mov    %eax,(%ebx)
  801081:	b8 00 00 00 00       	mov    $0x0,%eax
  801086:	eb 31                	jmp    8010b9 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801088:	42                   	inc    %edx
  801089:	8b 04 95 58 24 80 00 	mov    0x802458(,%edx,4),%eax
  801090:	85 c0                	test   %eax,%eax
  801092:	75 e7                	jne    80107b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801094:	a1 04 44 80 00       	mov    0x804404,%eax
  801099:	8b 40 48             	mov    0x48(%eax),%eax
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	51                   	push   %ecx
  8010a0:	50                   	push   %eax
  8010a1:	68 dc 23 80 00       	push   $0x8023dc
  8010a6:	e8 c2 f2 ff ff       	call   80036d <cprintf>
	*dev = 0;
  8010ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b6:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 14             	sub    $0x14,%esp
  8010c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 08             	pushl  0x8(%ebp)
  8010cf:	e8 23 ff ff ff       	call   800ff7 <fd_lookup>
  8010d4:	83 c4 08             	add    $0x8,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 55                	js     801130 <fstat+0x72>
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010e5:	ff 30                	pushl  (%eax)
  8010e7:	e8 7b ff ff ff       	call   801067 <dev_lookup>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	78 3d                	js     801130 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8010f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8010f6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8010fa:	75 07                	jne    801103 <fstat+0x45>
  8010fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801101:	eb 2d                	jmp    801130 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801103:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801106:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80110d:	00 00 00 
	stat->st_isdir = 0;
  801110:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801117:	00 00 00 
	stat->st_dev = dev;
  80111a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80111d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	53                   	push   %ebx
  801127:	ff 75 f4             	pushl  -0xc(%ebp)
  80112a:	ff 50 14             	call   *0x14(%eax)
  80112d:	83 c4 10             	add    $0x10,%esp
}
  801130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	53                   	push   %ebx
  801139:	83 ec 14             	sub    $0x14,%esp
  80113c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	53                   	push   %ebx
  801144:	e8 ae fe ff ff       	call   800ff7 <fd_lookup>
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 5f                	js     8011af <ftruncate+0x7a>
  801150:	83 ec 08             	sub    $0x8,%esp
  801153:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	ff 30                	pushl  (%eax)
  80115c:	e8 06 ff ff ff       	call   801067 <dev_lookup>
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 47                	js     8011af <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116f:	75 21                	jne    801192 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801171:	a1 04 44 80 00       	mov    0x804404,%eax
  801176:	8b 40 48             	mov    0x48(%eax),%eax
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	53                   	push   %ebx
  80117d:	50                   	push   %eax
  80117e:	68 fc 23 80 00       	push   $0x8023fc
  801183:	e8 e5 f1 ff ff       	call   80036d <cprintf>
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	eb 1d                	jmp    8011af <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801192:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801195:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801199:	75 07                	jne    8011a2 <ftruncate+0x6d>
  80119b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a0:	eb 0d                	jmp    8011af <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	ff 75 0c             	pushl  0xc(%ebp)
  8011a8:	50                   	push   %eax
  8011a9:	ff 52 18             	call   *0x18(%edx)
  8011ac:	83 c4 10             	add    $0x10,%esp
}
  8011af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 14             	sub    $0x14,%esp
  8011bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	53                   	push   %ebx
  8011c3:	e8 2f fe ff ff       	call   800ff7 <fd_lookup>
  8011c8:	83 c4 08             	add    $0x8,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 62                	js     801231 <write+0x7d>
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d9:	ff 30                	pushl  (%eax)
  8011db:	e8 87 fe ff ff       	call   801067 <dev_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 4a                	js     801231 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ee:	75 21                	jne    801211 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f0:	a1 04 44 80 00       	mov    0x804404,%eax
  8011f5:	8b 40 48             	mov    0x48(%eax),%eax
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	53                   	push   %ebx
  8011fc:	50                   	push   %eax
  8011fd:	68 1d 24 80 00       	push   $0x80241d
  801202:	e8 66 f1 ff ff       	call   80036d <cprintf>
  801207:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	eb 20                	jmp    801231 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801211:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801214:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801218:	75 07                	jne    801221 <write+0x6d>
  80121a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80121f:	eb 10                	jmp    801231 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	ff 75 10             	pushl  0x10(%ebp)
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	50                   	push   %eax
  80122b:	ff 52 0c             	call   *0xc(%edx)
  80122e:	83 c4 10             	add    $0x10,%esp
}
  801231:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 14             	sub    $0x14,%esp
  80123d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	53                   	push   %ebx
  801245:	e8 ad fd ff ff       	call   800ff7 <fd_lookup>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 67                	js     8012b8 <read+0x82>
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	ff 30                	pushl  (%eax)
  80125d:	e8 05 fe ff ff       	call   801067 <dev_lookup>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 4f                	js     8012b8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801269:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126c:	8b 42 08             	mov    0x8(%edx),%eax
  80126f:	83 e0 03             	and    $0x3,%eax
  801272:	83 f8 01             	cmp    $0x1,%eax
  801275:	75 21                	jne    801298 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801277:	a1 04 44 80 00       	mov    0x804404,%eax
  80127c:	8b 40 48             	mov    0x48(%eax),%eax
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	53                   	push   %ebx
  801283:	50                   	push   %eax
  801284:	68 3a 24 80 00       	push   $0x80243a
  801289:	e8 df f0 ff ff       	call   80036d <cprintf>
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 20                	jmp    8012b8 <read+0x82>
	}
	if (!dev->dev_read)
  801298:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80129b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80129f:	75 07                	jne    8012a8 <read+0x72>
  8012a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012a6:	eb 10                	jmp    8012b8 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	ff 75 10             	pushl  0x10(%ebp)
  8012ae:	ff 75 0c             	pushl  0xc(%ebp)
  8012b1:	52                   	push   %edx
  8012b2:	ff 50 08             	call   *0x8(%eax)
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8012cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d1:	eb 21                	jmp    8012f4 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d3:	83 ec 04             	sub    $0x4,%esp
  8012d6:	89 f0                	mov    %esi,%eax
  8012d8:	29 d0                	sub    %edx,%eax
  8012da:	50                   	push   %eax
  8012db:	8d 04 17             	lea    (%edi,%edx,1),%eax
  8012de:	50                   	push   %eax
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 4f ff ff ff       	call   801236 <read>
		if (m < 0)
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 0e                	js     8012fc <readn+0x3f>
			return m;
		if (m == 0)
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	74 08                	je     8012fa <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f2:	01 c3                	add    %eax,%ebx
  8012f4:	89 da                	mov    %ebx,%edx
  8012f6:	39 f3                	cmp    %esi,%ebx
  8012f8:	72 d9                	jb     8012d3 <readn+0x16>
  8012fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	56                   	push   %esi
  801308:	53                   	push   %ebx
  801309:	83 ec 20             	sub    $0x20,%esp
  80130c:	8b 75 08             	mov    0x8(%ebp),%esi
  80130f:	8a 45 0c             	mov    0xc(%ebp),%al
  801312:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	56                   	push   %esi
  80131a:	e8 5d fc ff ff       	call   800f7c <fd2num>
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	e8 d0 fc ff ff       	call   800ff7 <fd_lookup>
  801327:	89 c3                	mov    %eax,%ebx
  801329:	83 c4 08             	add    $0x8,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 05                	js     801335 <fd_close+0x31>
  801330:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801333:	74 0d                	je     801342 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801335:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801339:	75 48                	jne    801383 <fd_close+0x7f>
  80133b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801340:	eb 41                	jmp    801383 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 36                	pushl  (%esi)
  80134b:	e8 17 fd ff ff       	call   801067 <dev_lookup>
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 1c                	js     801375 <fd_close+0x71>
		if (dev->dev_close)
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	8b 40 10             	mov    0x10(%eax),%eax
  80135f:	85 c0                	test   %eax,%eax
  801361:	75 07                	jne    80136a <fd_close+0x66>
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
  801368:	eb 0b                	jmp    801375 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	56                   	push   %esi
  80136e:	ff d0                	call   *%eax
  801370:	89 c3                	mov    %eax,%ebx
  801372:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	56                   	push   %esi
  801379:	6a 00                	push   $0x0
  80137b:	e8 b5 fa ff ff       	call   800e35 <sys_page_unmap>
  801380:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801383:	89 d8                	mov    %ebx,%eax
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801392:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 59 fc ff ff       	call   800ff7 <fd_lookup>
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 10                	js     8013b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	6a 01                	push   $0x1
  8013aa:	ff 75 fc             	pushl  -0x4(%ebp)
  8013ad:	e8 52 ff ff ff       	call   801304 <fd_close>
  8013b2:	83 c4 10             	add    $0x10,%esp
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	56                   	push   %esi
  8013bb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	6a 00                	push   $0x0
  8013c1:	ff 75 08             	pushl  0x8(%ebp)
  8013c4:	e8 4a 03 00 00       	call   801713 <open>
  8013c9:	89 c6                	mov    %eax,%esi
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	78 1b                	js     8013ed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d2:	83 ec 08             	sub    $0x8,%esp
  8013d5:	ff 75 0c             	pushl  0xc(%ebp)
  8013d8:	50                   	push   %eax
  8013d9:	e8 e0 fc ff ff       	call   8010be <fstat>
  8013de:	89 c3                	mov    %eax,%ebx
	close(fd);
  8013e0:	89 34 24             	mov    %esi,(%esp)
  8013e3:	e8 a4 ff ff ff       	call   80138c <close>
  8013e8:	89 de                	mov    %ebx,%esi
  8013ea:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8013ed:	89 f0                	mov    %esi,%eax
  8013ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	57                   	push   %edi
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 1c             	sub    $0x1c,%esp
  8013ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801402:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	ff 75 08             	pushl  0x8(%ebp)
  801409:	e8 e9 fb ff ff       	call   800ff7 <fd_lookup>
  80140e:	89 c3                	mov    %eax,%ebx
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	0f 88 bd 00 00 00    	js     8014d8 <dup+0xe2>
		return r;
	close(newfdnum);
  80141b:	83 ec 0c             	sub    $0xc,%esp
  80141e:	57                   	push   %edi
  80141f:	e8 68 ff ff ff       	call   80138c <close>

	newfd = INDEX2FD(newfdnum);
  801424:	89 f8                	mov    %edi,%eax
  801426:	c1 e0 0c             	shl    $0xc,%eax
  801429:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  80142f:	ff 75 f0             	pushl  -0x10(%ebp)
  801432:	e8 55 fb ff ff       	call   800f8c <fd2data>
  801437:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801439:	89 34 24             	mov    %esi,(%esp)
  80143c:	e8 4b fb ff ff       	call   800f8c <fd2data>
  801441:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801444:	89 d8                	mov    %ebx,%eax
  801446:	c1 e8 16             	shr    $0x16,%eax
  801449:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801450:	83 c4 14             	add    $0x14,%esp
  801453:	a8 01                	test   $0x1,%al
  801455:	74 36                	je     80148d <dup+0x97>
  801457:	89 da                	mov    %ebx,%edx
  801459:	c1 ea 0c             	shr    $0xc,%edx
  80145c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801463:	a8 01                	test   $0x1,%al
  801465:	74 26                	je     80148d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801467:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	25 07 0e 00 00       	and    $0xe07,%eax
  801476:	50                   	push   %eax
  801477:	ff 75 e0             	pushl  -0x20(%ebp)
  80147a:	6a 00                	push   $0x0
  80147c:	53                   	push   %ebx
  80147d:	6a 00                	push   $0x0
  80147f:	e8 f3 f9 ff ff       	call   800e77 <sys_page_map>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	83 c4 20             	add    $0x20,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 30                	js     8014bd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801490:	89 d0                	mov    %edx,%eax
  801492:	c1 e8 0c             	shr    $0xc,%eax
  801495:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149c:	83 ec 0c             	sub    $0xc,%esp
  80149f:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a4:	50                   	push   %eax
  8014a5:	56                   	push   %esi
  8014a6:	6a 00                	push   $0x0
  8014a8:	52                   	push   %edx
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 c7 f9 ff ff       	call   800e77 <sys_page_map>
  8014b0:	89 c3                	mov    %eax,%ebx
  8014b2:	83 c4 20             	add    $0x20,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 04                	js     8014bd <dup+0xc7>
		goto err;
  8014b9:	89 fb                	mov    %edi,%ebx
  8014bb:	eb 1b                	jmp    8014d8 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	56                   	push   %esi
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 6d f9 ff ff       	call   800e35 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014c8:	83 c4 08             	add    $0x8,%esp
  8014cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 60 f9 ff ff       	call   800e35 <sys_page_unmap>
  8014d5:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5e                   	pop    %esi
  8014df:	5f                   	pop    %edi
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	e8 95 fe ff ff       	call   80138c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f7:	43                   	inc    %ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	83 fb 20             	cmp    $0x20,%ebx
  8014fe:	75 ee                	jne    8014ee <close_all+0xc>
		close(i);
}
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    
  801505:	00 00                	add    %al,(%eax)
	...

00801508 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	89 c3                	mov    %eax,%ebx
  80150f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801511:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  801518:	75 12                	jne    80152c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	6a 01                	push   $0x1
  80151f:	e8 e4 06 00 00       	call   801c08 <ipc_find_env>
  801524:	a3 00 44 80 00       	mov    %eax,0x804400
  801529:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80152c:	6a 07                	push   $0x7
  80152e:	68 00 50 80 00       	push   $0x805000
  801533:	53                   	push   %ebx
  801534:	ff 35 00 44 80 00    	pushl  0x804400
  80153a:	e8 0e 07 00 00       	call   801c4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80153f:	83 c4 0c             	add    $0xc,%esp
  801542:	6a 00                	push   $0x0
  801544:	56                   	push   %esi
  801545:	6a 00                	push   $0x0
  801547:	e8 56 07 00 00       	call   801ca2 <ipc_recv>
}
  80154c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801559:	ba 00 00 00 00       	mov    $0x0,%edx
  80155e:	b8 08 00 00 00       	mov    $0x8,%eax
  801563:	e8 a0 ff ff ff       	call   801508 <fsipc>
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	8b 40 0c             	mov    0xc(%eax),%eax
  801576:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80157b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 02 00 00 00       	mov    $0x2,%eax
  80158d:	e8 76 ff ff ff       	call   801508 <fsipc>
}
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8015af:	e8 54 ff ff ff       	call   801508 <fsipc>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8015d5:	e8 2e ff ff ff       	call   801508 <fsipc>
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 2c                	js     80160a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	68 00 50 80 00       	push   $0x805000
  8015e6:	53                   	push   %ebx
  8015e7:	e8 b7 f3 ff ff       	call   8009a3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8015f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8015fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801602:	b8 00 00 00 00       	mov    $0x0,%eax
  801607:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80160a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160d:	c9                   	leave  
  80160e:	c3                   	ret    

0080160f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	53                   	push   %ebx
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	8b 40 0c             	mov    0xc(%eax),%eax
  80161f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  801624:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80162a:	53                   	push   %ebx
  80162b:	ff 75 0c             	pushl  0xc(%ebp)
  80162e:	68 08 50 80 00       	push   $0x805008
  801633:	e8 d8 f4 ff ff       	call   800b10 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801638:	ba 00 00 00 00       	mov    $0x0,%edx
  80163d:	b8 04 00 00 00       	mov    $0x4,%eax
  801642:	e8 c1 fe ff ff       	call   801508 <fsipc>
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 3d                	js     80168b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  80164e:	39 c3                	cmp    %eax,%ebx
  801650:	73 19                	jae    80166b <devfile_write+0x5c>
  801652:	68 68 24 80 00       	push   $0x802468
  801657:	68 6f 24 80 00       	push   $0x80246f
  80165c:	68 97 00 00 00       	push   $0x97
  801661:	68 84 24 80 00       	push   $0x802484
  801666:	e8 61 ec ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  80166b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801670:	7e 19                	jle    80168b <devfile_write+0x7c>
  801672:	68 8f 24 80 00       	push   $0x80248f
  801677:	68 6f 24 80 00       	push   $0x80246f
  80167c:	68 98 00 00 00       	push   $0x98
  801681:	68 84 24 80 00       	push   $0x802484
  801686:	e8 41 ec ff ff       	call   8002cc <_panic>
	
	return r;
}
  80168b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	8b 40 0c             	mov    0xc(%eax),%eax
  80169e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016a3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	b8 03 00 00 00       	mov    $0x3,%eax
  8016b3:	e8 50 fe ff ff       	call   801508 <fsipc>
  8016b8:	89 c3                	mov    %eax,%ebx
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 4c                	js     80170a <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8016be:	39 de                	cmp    %ebx,%esi
  8016c0:	73 16                	jae    8016d8 <devfile_read+0x48>
  8016c2:	68 68 24 80 00       	push   $0x802468
  8016c7:	68 6f 24 80 00       	push   $0x80246f
  8016cc:	6a 7c                	push   $0x7c
  8016ce:	68 84 24 80 00       	push   $0x802484
  8016d3:	e8 f4 eb ff ff       	call   8002cc <_panic>
	assert(r <= PGSIZE);
  8016d8:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8016de:	7e 16                	jle    8016f6 <devfile_read+0x66>
  8016e0:	68 8f 24 80 00       	push   $0x80248f
  8016e5:	68 6f 24 80 00       	push   $0x80246f
  8016ea:	6a 7d                	push   $0x7d
  8016ec:	68 84 24 80 00       	push   $0x802484
  8016f1:	e8 d6 eb ff ff       	call   8002cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016f6:	83 ec 04             	sub    $0x4,%esp
  8016f9:	50                   	push   %eax
  8016fa:	68 00 50 80 00       	push   $0x805000
  8016ff:	ff 75 0c             	pushl  0xc(%ebp)
  801702:	e8 09 f4 ff ff       	call   800b10 <memmove>
  801707:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80170a:	89 d8                	mov    %ebx,%eax
  80170c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170f:	5b                   	pop    %ebx
  801710:	5e                   	pop    %esi
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	83 ec 1c             	sub    $0x1c,%esp
  80171b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80171e:	56                   	push   %esi
  80171f:	e8 4c f2 ff ff       	call   800970 <strlen>
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80172c:	7e 07                	jle    801735 <open+0x22>
  80172e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801733:	eb 63                	jmp    801798 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	e8 63 f8 ff ff       	call   800fa4 <fd_alloc>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	78 4e                	js     801798 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	56                   	push   %esi
  80174e:	68 00 50 80 00       	push   $0x805000
  801753:	e8 4b f2 ff ff       	call   8009a3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801763:	b8 01 00 00 00       	mov    $0x1,%eax
  801768:	e8 9b fd ff ff       	call   801508 <fsipc>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	83 c4 10             	add    $0x10,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	79 12                	jns    801788 <open+0x75>
		fd_close(fd, 0);
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	6a 00                	push   $0x0
  80177b:	ff 75 f4             	pushl  -0xc(%ebp)
  80177e:	e8 81 fb ff ff       	call   801304 <fd_close>
		return r;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	eb 10                	jmp    801798 <open+0x85>
	}

	return fd2num(fd);
  801788:	83 ec 0c             	sub    $0xc,%esp
  80178b:	ff 75 f4             	pushl  -0xc(%ebp)
  80178e:	e8 e9 f7 ff ff       	call   800f7c <fd2num>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	83 c4 10             	add    $0x10,%esp
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    
  8017a1:	00 00                	add    %al,(%eax)
	...

008017a4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017ad:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017b1:	7e 2c                	jle    8017df <writebuf+0x3b>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	ff 70 04             	pushl  0x4(%eax)
  8017b9:	8d 40 10             	lea    0x10(%eax),%eax
  8017bc:	50                   	push   %eax
  8017bd:	ff 33                	pushl  (%ebx)
  8017bf:	e8 f0 f9 ff ff       	call   8011b4 <write>
		if (result > 0)
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	7e 03                	jle    8017ce <writebuf+0x2a>
			b->result += result;
  8017cb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017ce:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017d1:	74 0c                	je     8017df <writebuf+0x3b>
			b->error = (result < 0 ? result : 0);
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	7e 05                	jle    8017dc <writebuf+0x38>
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dc:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <vfprintf>:
	}
}

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	81 ec 14 01 00 00    	sub    $0x114,%esp
	struct printbuf b;

	b.fd = fd;
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
	b.idx = 0;
  8017f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017fe:	00 00 00 
	b.result = 0;
  801801:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801808:	00 00 00 
	b.error = 1;
  80180b:	c7 85 f8 fe ff ff 01 	movl   $0x1,-0x108(%ebp)
  801812:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801815:	ff 75 10             	pushl  0x10(%ebp)
  801818:	ff 75 0c             	pushl  0xc(%ebp)
  80181b:	8d 9d ec fe ff ff    	lea    -0x114(%ebp),%ebx
  801821:	53                   	push   %ebx
  801822:	68 87 18 80 00       	push   $0x801887
  801827:	e8 94 ec ff ff       	call   8004c0 <vprintfmt>
	if (b.idx > 0)
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	83 bd f0 fe ff ff 00 	cmpl   $0x0,-0x110(%ebp)
  801836:	7e 07                	jle    80183f <vfprintf+0x5b>
		writebuf(&b);
  801838:	89 d8                	mov    %ebx,%eax
  80183a:	e8 65 ff ff ff       	call   8017a4 <writebuf>

	return (b.result ? b.result : b.error);
  80183f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801845:	85 c0                	test   %eax,%eax
  801847:	75 06                	jne    80184f <vfprintf+0x6b>
  801849:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
}
  80184f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <printf>:
	return cnt;
}

int
printf(const char *fmt, ...)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80185a:	8d 45 0c             	lea    0xc(%ebp),%eax
  80185d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(1, fmt, ap);
  801860:	50                   	push   %eax
  801861:	ff 75 08             	pushl  0x8(%ebp)
  801864:	6a 01                	push   $0x1
  801866:	e8 79 ff ff ff       	call   8017e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <fprintf>:
	return (b.result ? b.result : b.error);
}

int
fprintf(int fd, const char *fmt, ...)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801873:	8d 45 10             	lea    0x10(%ebp),%eax
  801876:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vfprintf(fd, fmt, ap);
  801879:	50                   	push   %eax
  80187a:	ff 75 0c             	pushl  0xc(%ebp)
  80187d:	ff 75 08             	pushl  0x8(%ebp)
  801880:	e8 5f ff ff ff       	call   8017e4 <vfprintf>
	va_end(ap);

	return cnt;
}
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <putch>:
	}
}

static void
putch(int ch, void *thunk)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801891:	8b 43 04             	mov    0x4(%ebx),%eax
  801894:	8b 55 08             	mov    0x8(%ebp),%edx
  801897:	88 54 18 10          	mov    %dl,0x10(%eax,%ebx,1)
  80189b:	40                   	inc    %eax
  80189c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80189f:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018a4:	75 0e                	jne    8018b4 <putch+0x2d>
		writebuf(b);
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	e8 f7 fe ff ff       	call   8017a4 <writebuf>
		b->idx = 0;
  8018ad:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018b4:	83 c4 04             	add    $0x4,%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    
	...

008018bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 bd f6 ff ff       	call   800f8c <fd2data>
  8018cf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d1:	83 c4 08             	add    $0x8,%esp
  8018d4:	68 9b 24 80 00       	push   $0x80249b
  8018d9:	53                   	push   %ebx
  8018da:	e8 c4 f0 ff ff       	call   8009a3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018df:	8b 46 04             	mov    0x4(%esi),%eax
  8018e2:	2b 06                	sub    (%esi),%eax
  8018e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f1:	00 00 00 
	stat->st_dev = &devpipe;
  8018f4:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8018fb:	30 80 00 
	return 0;
}
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801914:	53                   	push   %ebx
  801915:	6a 00                	push   $0x0
  801917:	e8 19 f5 ff ff       	call   800e35 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80191c:	89 1c 24             	mov    %ebx,(%esp)
  80191f:	e8 68 f6 ff ff       	call   800f8c <fd2data>
  801924:	83 c4 08             	add    $0x8,%esp
  801927:	50                   	push   %eax
  801928:	6a 00                	push   $0x0
  80192a:	e8 06 f5 ff ff       	call   800e35 <sys_page_unmap>
}
  80192f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	57                   	push   %edi
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801940:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801942:	a1 04 44 80 00       	mov    0x804404,%eax
  801947:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	ff 75 f0             	pushl  -0x10(%ebp)
  801950:	e8 b7 03 00 00       	call   801d0c <pageref>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	89 3c 24             	mov    %edi,(%esp)
  80195a:	e8 ad 03 00 00       	call   801d0c <pageref>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	39 c3                	cmp    %eax,%ebx
  801964:	0f 94 c0             	sete   %al
  801967:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  80196a:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801970:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801973:	39 c6                	cmp    %eax,%esi
  801975:	74 1b                	je     801992 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801977:	83 f9 01             	cmp    $0x1,%ecx
  80197a:	75 c6                	jne    801942 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80197c:	8b 42 58             	mov    0x58(%edx),%eax
  80197f:	6a 01                	push   $0x1
  801981:	50                   	push   %eax
  801982:	56                   	push   %esi
  801983:	68 a2 24 80 00       	push   $0x8024a2
  801988:	e8 e0 e9 ff ff       	call   80036d <cprintf>
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	eb b0                	jmp    801942 <_pipeisclosed+0xe>
	}
}
  801992:	89 c8                	mov    %ecx,%eax
  801994:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5f                   	pop    %edi
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	57                   	push   %edi
  8019a0:	56                   	push   %esi
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 18             	sub    $0x18,%esp
  8019a5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019a8:	56                   	push   %esi
  8019a9:	e8 de f5 ff ff       	call   800f8c <fd2data>
  8019ae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8019b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019b6:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	eb 40                	jmp    801a00 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c5:	eb 40                	jmp    801a07 <devpipe_write+0x6b>
  8019c7:	89 da                	mov    %ebx,%edx
  8019c9:	89 f0                	mov    %esi,%eax
  8019cb:	e8 64 ff ff ff       	call   801934 <_pipeisclosed>
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	75 ec                	jne    8019c0 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019d4:	e8 23 f5 ff ff       	call   800efc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d9:	8b 53 04             	mov    0x4(%ebx),%edx
  8019dc:	8b 03                	mov    (%ebx),%eax
  8019de:	83 c0 20             	add    $0x20,%eax
  8019e1:	39 c2                	cmp    %eax,%edx
  8019e3:	73 e2                	jae    8019c7 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e5:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019eb:	79 05                	jns    8019f2 <devpipe_write+0x56>
  8019ed:	4a                   	dec    %edx
  8019ee:	83 ca e0             	or     $0xffffffe0,%edx
  8019f1:	42                   	inc    %edx
  8019f2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8019f5:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8019f8:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019fc:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ff:	47                   	inc    %edi
  801a00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a03:	75 d4                	jne    8019d9 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a05:	89 f8                	mov    %edi,%eax
}
  801a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0a:	5b                   	pop    %ebx
  801a0b:	5e                   	pop    %esi
  801a0c:	5f                   	pop    %edi
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	57                   	push   %edi
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	83 ec 18             	sub    $0x18,%esp
  801a18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1b:	57                   	push   %edi
  801a1c:	e8 6b f5 ff ff       	call   800f8c <fd2data>
  801a21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a29:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	eb 41                	jmp    801a74 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a33:	89 f0                	mov    %esi,%eax
  801a35:	eb 44                	jmp    801a7b <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a37:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3c:	eb 3d                	jmp    801a7b <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	75 f1                	jne    801a33 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a42:	89 da                	mov    %ebx,%edx
  801a44:	89 f8                	mov    %edi,%eax
  801a46:	e8 e9 fe ff ff       	call   801934 <_pipeisclosed>
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	75 e8                	jne    801a37 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a4f:	e8 a8 f4 ff ff       	call   800efc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a54:	8b 03                	mov    (%ebx),%eax
  801a56:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a59:	74 e3                	je     801a3e <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a5b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a60:	79 05                	jns    801a67 <devpipe_read+0x58>
  801a62:	48                   	dec    %eax
  801a63:	83 c8 e0             	or     $0xffffffe0,%eax
  801a66:	40                   	inc    %eax
  801a67:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a6e:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801a71:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a73:	46                   	inc    %esi
  801a74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a77:	75 db                	jne    801a54 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a79:	89 f0                	mov    %esi,%eax
}
  801a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7e:	5b                   	pop    %ebx
  801a7f:	5e                   	pop    %esi
  801a80:	5f                   	pop    %edi
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a89:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a8c:	50                   	push   %eax
  801a8d:	ff 75 08             	pushl  0x8(%ebp)
  801a90:	e8 62 f5 ff ff       	call   800ff7 <fd_lookup>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 18                	js     801ab4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	ff 75 fc             	pushl  -0x4(%ebp)
  801aa2:	e8 e5 f4 ff ff       	call   800f8c <fd2data>
  801aa7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801aac:	e8 83 fe ff ff       	call   801934 <_pipeisclosed>
  801ab1:	83 c4 10             	add    $0x10,%esp
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 28             	sub    $0x28,%esp
  801abf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac5:	50                   	push   %eax
  801ac6:	e8 d9 f4 ff ff       	call   800fa4 <fd_alloc>
  801acb:	89 c3                	mov    %eax,%ebx
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	0f 88 24 01 00 00    	js     801bfc <pipe+0x146>
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	68 07 04 00 00       	push   $0x407
  801ae0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 cf f3 ff ff       	call   800eb9 <sys_page_alloc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	0f 88 05 01 00 00    	js     801bfc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	e8 a1 f4 ff ff       	call   800fa4 <fd_alloc>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	0f 88 dc 00 00 00    	js     801bec <pipe+0x136>
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	68 07 04 00 00       	push   $0x407
  801b18:	ff 75 ec             	pushl  -0x14(%ebp)
  801b1b:	6a 00                	push   $0x0
  801b1d:	e8 97 f3 ff ff       	call   800eb9 <sys_page_alloc>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	85 c0                	test   %eax,%eax
  801b29:	0f 88 bd 00 00 00    	js     801bec <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	ff 75 f0             	pushl  -0x10(%ebp)
  801b35:	e8 52 f4 ff ff       	call   800f8c <fd2data>
  801b3a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3c:	83 c4 0c             	add    $0xc,%esp
  801b3f:	68 07 04 00 00       	push   $0x407
  801b44:	50                   	push   %eax
  801b45:	6a 00                	push   $0x0
  801b47:	e8 6d f3 ff ff       	call   800eb9 <sys_page_alloc>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 c0                	test   %eax,%eax
  801b53:	0f 88 83 00 00 00    	js     801bdc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	ff 75 ec             	pushl  -0x14(%ebp)
  801b5f:	e8 28 f4 ff ff       	call   800f8c <fd2data>
  801b64:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b6b:	50                   	push   %eax
  801b6c:	6a 00                	push   $0x0
  801b6e:	56                   	push   %esi
  801b6f:	6a 00                	push   $0x0
  801b71:	e8 01 f3 ff ff       	call   800e77 <sys_page_map>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 20             	add    $0x20,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 4f                	js     801bce <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b88:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b94:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b9d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ba2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	ff 75 f0             	pushl  -0x10(%ebp)
  801baf:	e8 c8 f3 ff ff       	call   800f7c <fd2num>
  801bb4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bb6:	83 c4 04             	add    $0x4,%esp
  801bb9:	ff 75 ec             	pushl  -0x14(%ebp)
  801bbc:	e8 bb f3 ff ff       	call   800f7c <fd2num>
  801bc1:	89 47 04             	mov    %eax,0x4(%edi)
  801bc4:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	eb 2e                	jmp    801bfc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	56                   	push   %esi
  801bd2:	6a 00                	push   $0x0
  801bd4:	e8 5c f2 ff ff       	call   800e35 <sys_page_unmap>
  801bd9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	ff 75 ec             	pushl  -0x14(%ebp)
  801be2:	6a 00                	push   $0x0
  801be4:	e8 4c f2 ff ff       	call   800e35 <sys_page_unmap>
  801be9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bec:	83 ec 08             	sub    $0x8,%esp
  801bef:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf2:	6a 00                	push   $0x0
  801bf4:	e8 3c f2 ff ff       	call   800e35 <sys_page_unmap>
  801bf9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    
	...

00801c08 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c0f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c14:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  801c1b:	89 c8                	mov    %ecx,%eax
  801c1d:	c1 e0 07             	shl    $0x7,%eax
  801c20:	29 d0                	sub    %edx,%eax
  801c22:	89 c2                	mov    %eax,%edx
  801c24:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  801c2a:	8b 40 50             	mov    0x50(%eax),%eax
  801c2d:	39 d8                	cmp    %ebx,%eax
  801c2f:	75 0b                	jne    801c3c <ipc_find_env+0x34>
			return envs[i].env_id;
  801c31:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801c37:	8b 40 40             	mov    0x40(%eax),%eax
  801c3a:	eb 0e                	jmp    801c4a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3c:	41                   	inc    %ecx
  801c3d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801c43:	75 cf                	jne    801c14 <ipc_find_env+0xc>
  801c45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801c4a:	5b                   	pop    %ebx
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 0c             	sub    $0xc,%esp
  801c56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801c5f:	85 db                	test   %ebx,%ebx
  801c61:	75 05                	jne    801c68 <ipc_send+0x1b>
  801c63:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	57                   	push   %edi
  801c6b:	ff 75 08             	pushl  0x8(%ebp)
  801c6e:	e8 d9 f0 ff ff       	call   800d4c <sys_ipc_try_send>
		if (r == 0) {		//success
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	74 20                	je     801c9a <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  801c7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7d:	75 07                	jne    801c86 <ipc_send+0x39>
			sys_yield();
  801c7f:	e8 78 f2 ff ff       	call   800efc <sys_yield>
  801c84:	eb e2                	jmp    801c68 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	68 bc 24 80 00       	push   $0x8024bc
  801c8e:	6a 41                	push   $0x41
  801c90:	68 e0 24 80 00       	push   $0x8024e0
  801c95:	e8 32 e6 ff ff       	call   8002cc <_panic>
		}
	}
}
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cad:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	75 05                	jne    801cb9 <ipc_recv+0x17>
  801cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	50                   	push   %eax
  801cbd:	e8 49 f0 ff ff       	call   800d0b <sys_ipc_recv>
	if (r < 0) {				
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	79 16                	jns    801cdf <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  801cc9:	85 db                	test   %ebx,%ebx
  801ccb:	74 06                	je     801cd3 <ipc_recv+0x31>
  801ccd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  801cd3:	85 f6                	test   %esi,%esi
  801cd5:	74 2c                	je     801d03 <ipc_recv+0x61>
  801cd7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801cdd:	eb 24                	jmp    801d03 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  801cdf:	85 db                	test   %ebx,%ebx
  801ce1:	74 0a                	je     801ced <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801ce3:	a1 04 44 80 00       	mov    0x804404,%eax
  801ce8:	8b 40 74             	mov    0x74(%eax),%eax
  801ceb:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  801ced:	85 f6                	test   %esi,%esi
  801cef:	74 0a                	je     801cfb <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801cf1:	a1 04 44 80 00       	mov    0x804404,%eax
  801cf6:	8b 40 78             	mov    0x78(%eax),%eax
  801cf9:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  801cfb:	a1 04 44 80 00       	mov    0x804404,%eax
  801d00:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d06:	5b                   	pop    %ebx
  801d07:	5e                   	pop    %esi
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    
	...

00801d0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d12:	89 d0                	mov    %edx,%eax
  801d14:	c1 e8 16             	shr    $0x16,%eax
  801d17:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d1e:	a8 01                	test   $0x1,%al
  801d20:	74 20                	je     801d42 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d22:	89 d0                	mov    %edx,%eax
  801d24:	c1 e8 0c             	shr    $0xc,%eax
  801d27:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d2e:	a8 01                	test   $0x1,%al
  801d30:	74 10                	je     801d42 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d32:	c1 e8 0c             	shr    $0xc,%eax
  801d35:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d3c:	ef 
  801d3d:	0f b7 c0             	movzwl %ax,%eax
  801d40:	eb 05                	jmp    801d47 <pageref+0x3b>
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    
  801d49:	00 00                	add    %al,(%eax)
	...

00801d4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	83 ec 28             	sub    $0x28,%esp
  801d54:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d5b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801d62:	8b 45 10             	mov    0x10(%ebp),%eax
  801d65:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801d6b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801d6d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801d75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d78:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d7b:	85 ff                	test   %edi,%edi
  801d7d:	75 21                	jne    801da0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801d7f:	39 d1                	cmp    %edx,%ecx
  801d81:	76 49                	jbe    801dcc <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d83:	f7 f1                	div    %ecx
  801d85:	89 c1                	mov    %eax,%ecx
  801d87:	31 c0                	xor    %eax,%eax
  801d89:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d8c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801d8f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d92:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801d95:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d98:	83 c4 28             	add    $0x28,%esp
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    
  801d9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801da3:	0f 87 97 00 00 00    	ja     801e40 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801da9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801dac:	83 f0 1f             	xor    $0x1f,%eax
  801daf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801db2:	75 34                	jne    801de8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801db4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801db7:	72 08                	jb     801dc1 <__udivdi3+0x75>
  801db9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801dbc:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801dbf:	77 7f                	ja     801e40 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dc1:	b9 01 00 00 00       	mov    $0x1,%ecx
  801dc6:	31 c0                	xor    %eax,%eax
  801dc8:	eb c2                	jmp    801d8c <__udivdi3+0x40>
  801dca:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	74 79                	je     801e4c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dd6:	89 fa                	mov    %edi,%edx
  801dd8:	f7 f1                	div    %ecx
  801dda:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ddf:	f7 f1                	div    %ecx
  801de1:	89 c1                	mov    %eax,%ecx
  801de3:	89 f0                	mov    %esi,%eax
  801de5:	eb a5                	jmp    801d8c <__udivdi3+0x40>
  801de7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801de8:	b8 20 00 00 00       	mov    $0x20,%eax
  801ded:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  801df0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801df3:	89 fa                	mov    %edi,%edx
  801df5:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801df8:	d3 e2                	shl    %cl,%edx
  801dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfd:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801e00:	d3 e8                	shr    %cl,%eax
  801e02:	89 d7                	mov    %edx,%edi
  801e04:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e06:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801e09:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e0c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e11:	d3 e0                	shl    %cl,%eax
  801e13:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801e16:	8a 4d f0             	mov    -0x10(%ebp),%cl
  801e19:	d3 ea                	shr    %cl,%edx
  801e1b:	09 d0                	or     %edx,%eax
  801e1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e20:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e23:	d3 ea                	shr    %cl,%edx
  801e25:	f7 f7                	div    %edi
  801e27:	89 d7                	mov    %edx,%edi
  801e29:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801e2c:	f7 e6                	mul    %esi
  801e2e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e30:	39 d7                	cmp    %edx,%edi
  801e32:	72 38                	jb     801e6c <__udivdi3+0x120>
  801e34:	74 27                	je     801e5d <__udivdi3+0x111>
  801e36:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801e39:	31 c0                	xor    %eax,%eax
  801e3b:	e9 4c ff ff ff       	jmp    801d8c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e40:	31 c9                	xor    %ecx,%ecx
  801e42:	31 c0                	xor    %eax,%eax
  801e44:	e9 43 ff ff ff       	jmp    801d8c <__udivdi3+0x40>
  801e49:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e51:	31 d2                	xor    %edx,%edx
  801e53:	f7 75 f4             	divl   -0xc(%ebp)
  801e56:	89 c1                	mov    %eax,%ecx
  801e58:	e9 76 ff ff ff       	jmp    801dd3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e60:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801e63:	d3 e0                	shl    %cl,%eax
  801e65:	39 f0                	cmp    %esi,%eax
  801e67:	73 cd                	jae    801e36 <__udivdi3+0xea>
  801e69:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e6c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801e6f:	49                   	dec    %ecx
  801e70:	31 c0                	xor    %eax,%eax
  801e72:	e9 15 ff ff ff       	jmp    801d8c <__udivdi3+0x40>
	...

00801e78 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	57                   	push   %edi
  801e7c:	56                   	push   %esi
  801e7d:	83 ec 30             	sub    $0x30,%esp
  801e80:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801e87:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801e8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e94:	8b 45 10             	mov    0x10(%ebp),%eax
  801e97:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  801e9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801e9d:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801e9f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801ea2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801ea5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ea8:	85 d2                	test   %edx,%edx
  801eaa:	75 1c                	jne    801ec8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  801eac:	89 fa                	mov    %edi,%edx
  801eae:	39 f8                	cmp    %edi,%eax
  801eb0:	0f 86 c2 00 00 00    	jbe    801f78 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eb6:	89 f0                	mov    %esi,%eax
  801eb8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  801eba:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801ebd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801ec4:	eb 12                	jmp    801ed8 <__umoddi3+0x60>
  801ec6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ec8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801ecb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801ece:	76 18                	jbe    801ee8 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801ed0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801ed3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801ed6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801edb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801ede:	83 c4 30             	add    $0x30,%esp
  801ee1:	5e                   	pop    %esi
  801ee2:	5f                   	pop    %edi
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    
  801ee5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee8:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  801eec:	83 f0 1f             	xor    $0x1f,%eax
  801eef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ef2:	0f 84 ac 00 00 00    	je     801fa4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ef8:	b8 20 00 00 00       	mov    $0x20,%eax
  801efd:	2b 45 dc             	sub    -0x24(%ebp),%eax
  801f00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f03:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f06:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801f09:	d3 e2                	shl    %cl,%edx
  801f0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f0e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801f11:	d3 e8                	shr    %cl,%eax
  801f13:	89 d6                	mov    %edx,%esi
  801f15:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  801f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f1a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801f1d:	d3 e0                	shl    %cl,%eax
  801f1f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f22:	8b 7d f4             	mov    -0xc(%ebp),%edi
  801f25:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f27:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2a:	d3 e0                	shl    %cl,%eax
  801f2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f2f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801f32:	d3 ea                	shr    %cl,%edx
  801f34:	09 d0                	or     %edx,%eax
  801f36:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801f39:	d3 ea                	shr    %cl,%edx
  801f3b:	f7 f6                	div    %esi
  801f3d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  801f40:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f43:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  801f46:	0f 82 8d 00 00 00    	jb     801fd9 <__umoddi3+0x161>
  801f4c:	0f 84 91 00 00 00    	je     801fe3 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f52:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801f55:	29 c7                	sub    %eax,%edi
  801f57:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f59:	89 f2                	mov    %esi,%edx
  801f5b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801f5e:	d3 e2                	shl    %cl,%edx
  801f60:	89 f8                	mov    %edi,%eax
  801f62:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801f65:	d3 e8                	shr    %cl,%eax
  801f67:	09 c2                	or     %eax,%edx
  801f69:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801f6c:	d3 ee                	shr    %cl,%esi
  801f6e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801f71:	e9 62 ff ff ff       	jmp    801ed8 <__umoddi3+0x60>
  801f76:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	74 15                	je     801f94 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f82:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f85:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	f7 f1                	div    %ecx
  801f8c:	e9 29 ff ff ff       	jmp    801eba <__umoddi3+0x42>
  801f91:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f94:	b8 01 00 00 00       	mov    $0x1,%eax
  801f99:	31 d2                	xor    %edx,%edx
  801f9b:	f7 75 ec             	divl   -0x14(%ebp)
  801f9e:	89 c1                	mov    %eax,%ecx
  801fa0:	eb dd                	jmp    801f7f <__umoddi3+0x107>
  801fa2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  801faa:	72 19                	jb     801fc5 <__umoddi3+0x14d>
  801fac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801faf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801fb2:	76 11                	jbe    801fc5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801fb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fb7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  801fba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801fbd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801fc0:	e9 13 ff ff ff       	jmp    801ed8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fc5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801fce:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801fd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801fd4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801fd7:	eb db                	jmp    801fb4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fd9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801fdc:	19 f2                	sbb    %esi,%edx
  801fde:	e9 6f ff ff ff       	jmp    801f52 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fe3:	39 c7                	cmp    %eax,%edi
  801fe5:	72 f2                	jb     801fd9 <__umoddi3+0x161>
  801fe7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fea:	e9 63 ff ff ff       	jmp    801f52 <__umoddi3+0xda>
