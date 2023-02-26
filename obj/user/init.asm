
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 63 03 00 00       	call   800394 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80003f:	ba 00 00 00 00       	mov    $0x0,%edx
  800044:	b9 00 00 00 00       	mov    $0x0,%ecx
  800049:	eb 0a                	jmp    800055 <sum+0x21>
	int i, tot = 0;
	for (i = 0; i < n; i++)
		tot ^= i * s[i];
  80004b:	0f be 04 32          	movsbl (%edx,%esi,1),%eax
  80004f:	0f af c2             	imul   %edx,%eax
  800052:	31 c1                	xor    %eax,%ecx

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800054:	42                   	inc    %edx
  800055:	39 da                	cmp    %ebx,%edx
  800057:	7c f2                	jl     80004b <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  800059:	89 c8                	mov    %ecx,%eax
  80005b:	5b                   	pop    %ebx
  80005c:	5e                   	pop    %esi
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <umain>:

void
umain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	57                   	push   %edi
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006e:	68 60 25 80 00       	push   $0x802560
  800073:	e8 21 04 00 00       	call   800499 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800078:	68 70 17 00 00       	push   $0x1770
  80007d:	68 00 30 80 00       	push   $0x803000
  800082:	e8 ad ff ff ff       	call   800034 <sum>
  800087:	83 c4 18             	add    $0x18,%esp
  80008a:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80008f:	74 18                	je     8000a9 <umain+0x4a>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800091:	83 ec 04             	sub    $0x4,%esp
  800094:	68 9e 98 0f 00       	push   $0xf989e
  800099:	50                   	push   %eax
  80009a:	68 28 26 80 00       	push   $0x802628
  80009f:	e8 f5 03 00 00       	call   800499 <cprintf>
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	eb 10                	jmp    8000b9 <umain+0x5a>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 6f 25 80 00       	push   $0x80256f
  8000b1:	e8 e3 03 00 00       	call   800499 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b9:	68 70 17 00 00       	push   $0x1770
  8000be:	68 20 50 80 00       	push   $0x805020
  8000c3:	e8 6c ff ff ff       	call   800034 <sum>
  8000c8:	83 c4 08             	add    $0x8,%esp
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	74 13                	je     8000e2 <umain+0x83>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	50                   	push   %eax
  8000d3:	68 64 26 80 00       	push   $0x802664
  8000d8:	e8 bc 03 00 00       	call   800499 <cprintf>
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	eb 10                	jmp    8000f2 <umain+0x93>
	else
		cprintf("init: bss seems okay\n");
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	68 86 25 80 00       	push   $0x802586
  8000ea:	e8 aa 03 00 00       	call   800499 <cprintf>
  8000ef:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	68 9c 25 80 00       	push   $0x80259c
  8000fa:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
  800100:	50                   	push   %eax
  800101:	e8 fd 08 00 00       	call   800a03 <strcat>
  800106:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	8d b5 f4 fe ff ff    	lea    -0x10c(%ebp),%esi
  800114:	eb 2f                	jmp    800145 <umain+0xe6>
		strcat(args, " '");
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	68 a8 25 80 00       	push   $0x8025a8
  80011e:	56                   	push   %esi
  80011f:	e8 df 08 00 00       	call   800a03 <strcat>
		strcat(args, argv[i]);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012a:	ff 34 98             	pushl  (%eax,%ebx,4)
  80012d:	56                   	push   %esi
  80012e:	e8 d0 08 00 00       	call   800a03 <strcat>
		strcat(args, "'");
  800133:	83 c4 08             	add    $0x8,%esp
  800136:	68 a9 25 80 00       	push   $0x8025a9
  80013b:	56                   	push   %esi
  80013c:	e8 c2 08 00 00       	call   800a03 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800141:	43                   	inc    %ebx
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	39 fb                	cmp    %edi,%ebx
  800147:	7c cd                	jl     800116 <umain+0xb7>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	68 ab 25 80 00       	push   $0x8025ab
  800158:	e8 3c 03 00 00       	call   800499 <cprintf>

	cprintf("init: running sh\n");
  80015d:	c7 04 24 af 25 80 00 	movl   $0x8025af,(%esp)
  800164:	e8 30 03 00 00       	call   800499 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800170:	e8 5f 12 00 00       	call   8013d4 <close>
	if ((r = opencons()) < 0)
  800175:	e8 6e 01 00 00       	call   8002e8 <opencons>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	79 12                	jns    800193 <umain+0x134>
		panic("opencons: %e", r);
  800181:	50                   	push   %eax
  800182:	68 c1 25 80 00       	push   $0x8025c1
  800187:	6a 37                	push   $0x37
  800189:	68 ce 25 80 00       	push   $0x8025ce
  80018e:	e8 65 02 00 00       	call   8003f8 <_panic>
	if (r != 0)
  800193:	85 c0                	test   %eax,%eax
  800195:	74 12                	je     8001a9 <umain+0x14a>
		panic("first opencons used fd %d", r);
  800197:	50                   	push   %eax
  800198:	68 da 25 80 00       	push   $0x8025da
  80019d:	6a 39                	push   $0x39
  80019f:	68 ce 25 80 00       	push   $0x8025ce
  8001a4:	e8 4f 02 00 00       	call   8003f8 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	6a 01                	push   $0x1
  8001ae:	6a 00                	push   $0x0
  8001b0:	e8 89 12 00 00       	call   80143e <dup>
  8001b5:	83 c4 10             	add    $0x10,%esp
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	79 12                	jns    8001ce <umain+0x16f>
		panic("dup: %e", r);
  8001bc:	50                   	push   %eax
  8001bd:	68 f4 25 80 00       	push   $0x8025f4
  8001c2:	6a 3b                	push   $0x3b
  8001c4:	68 ce 25 80 00       	push   $0x8025ce
  8001c9:	e8 2a 02 00 00       	call   8003f8 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	68 fc 25 80 00       	push   $0x8025fc
  8001d6:	e8 be 02 00 00       	call   800499 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001db:	83 c4 0c             	add    $0xc,%esp
  8001de:	6a 00                	push   $0x0
  8001e0:	68 10 26 80 00       	push   $0x802610
  8001e5:	68 0f 26 80 00       	push   $0x80260f
  8001ea:	e8 4c 1b 00 00       	call   801d3b <spawnl>
		if (r < 0) {
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	79 13                	jns    800209 <umain+0x1aa>
			cprintf("init: spawn sh: %e\n", r);
  8001f6:	83 ec 08             	sub    $0x8,%esp
  8001f9:	50                   	push   %eax
  8001fa:	68 13 26 80 00       	push   $0x802613
  8001ff:	e8 95 02 00 00       	call   800499 <cprintf>
			continue;
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	eb c5                	jmp    8001ce <umain+0x16f>
		}
		wait(r);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	50                   	push   %eax
  80020d:	e8 f6 1e 00 00       	call   802108 <wait>
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	eb b7                	jmp    8001ce <umain+0x16f>
	...

00800218 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021b:	b8 00 00 00 00       	mov    $0x0,%eax
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800228:	68 93 26 80 00       	push   $0x802693
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	e8 b6 07 00 00       	call   8009eb <strcpy>
	return 0;
}
  800235:	b8 00 00 00 00       	mov    $0x0,%eax
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800248:	be 00 00 00 00       	mov    $0x0,%esi
  80024d:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  800253:	eb 2c                	jmp    800281 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80025a:	83 fb 7f             	cmp    $0x7f,%ebx
  80025d:	76 05                	jbe    800264 <devcons_write+0x28>
  80025f:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800264:	83 ec 04             	sub    $0x4,%esp
  800267:	53                   	push   %ebx
  800268:	03 45 0c             	add    0xc(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	57                   	push   %edi
  80026d:	e8 e6 08 00 00       	call   800b58 <memmove>
		sys_cputs(buf, m);
  800272:	83 c4 08             	add    $0x8,%esp
  800275:	53                   	push   %ebx
  800276:	57                   	push   %edi
  800277:	e8 b3 0a 00 00       	call   800d2f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80027c:	01 de                	add    %ebx,%esi
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	89 f0                	mov    %esi,%eax
  800283:	3b 75 10             	cmp    0x10(%ebp),%esi
  800286:	72 cd                	jb     800255 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80029c:	6a 01                	push   $0x1
  80029e:	8d 45 ff             	lea    -0x1(%ebp),%eax
  8002a1:	50                   	push   %eax
  8002a2:	e8 88 0a 00 00       	call   800d2f <sys_cputs>
  8002a7:	83 c4 10             	add    $0x10,%esp
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002b6:	74 27                	je     8002df <devcons_read+0x33>
  8002b8:	eb 05                	jmp    8002bf <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002ba:	e8 85 0c 00 00       	call   800f44 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002bf:	e8 4c 0a 00 00       	call   800d10 <sys_cgetc>
  8002c4:	89 c2                	mov    %eax,%edx
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	74 f0                	je     8002ba <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	78 16                	js     8002e4 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002ce:	83 f8 04             	cmp    $0x4,%eax
  8002d1:	74 0c                	je     8002df <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d6:	88 10                	mov    %dl,(%eax)
  8002d8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002dd:	eb 05                	jmp    8002e4 <devcons_read+0x38>
	return 1;
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	89 d0                	mov    %edx,%eax
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8002ee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8002f1:	50                   	push   %eax
  8002f2:	e8 f5 0c 00 00       	call   800fec <fd_alloc>
  8002f7:	83 c4 10             	add    $0x10,%esp
  8002fa:	85 c0                	test   %eax,%eax
  8002fc:	78 3b                	js     800339 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8002fe:	83 ec 04             	sub    $0x4,%esp
  800301:	68 07 04 00 00       	push   $0x407
  800306:	ff 75 fc             	pushl  -0x4(%ebp)
  800309:	6a 00                	push   $0x0
  80030b:	e8 f1 0b 00 00       	call   800f01 <sys_page_alloc>
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	85 c0                	test   %eax,%eax
  800315:	78 22                	js     800339 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800317:	a1 70 47 80 00       	mov    0x804770,%eax
  80031c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80031f:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  800321:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800324:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	ff 75 fc             	pushl  -0x4(%ebp)
  800331:	e8 8e 0c 00 00       	call   800fc4 <fd2num>
  800336:	83 c4 10             	add    $0x10,%esp
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800341:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800344:	50                   	push   %eax
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 f2 0c 00 00       	call   80103f <fd_lookup>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	85 c0                	test   %eax,%eax
  800352:	78 11                	js     800365 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800354:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800357:	8b 00                	mov    (%eax),%eax
  800359:	3b 05 70 47 80 00    	cmp    0x804770,%eax
  80035f:	0f 94 c0             	sete   %al
  800362:	0f b6 c0             	movzbl %al,%eax
}
  800365:	c9                   	leave  
  800366:	c3                   	ret    

00800367 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80036d:	6a 01                	push   $0x1
  80036f:	8d 45 ff             	lea    -0x1(%ebp),%eax
  800372:	50                   	push   %eax
  800373:	6a 00                	push   $0x0
  800375:	e8 04 0f 00 00       	call   80127e <read>
	if (r < 0)
  80037a:	83 c4 10             	add    $0x10,%esp
  80037d:	85 c0                	test   %eax,%eax
  80037f:	78 0f                	js     800390 <getchar+0x29>
		return r;
	if (r < 1)
  800381:	85 c0                	test   %eax,%eax
  800383:	75 07                	jne    80038c <getchar+0x25>
  800385:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80038a:	eb 04                	jmp    800390 <getchar+0x29>
		return -E_EOF;
	return c;
  80038c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    
	...

00800394 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	8b 75 08             	mov    0x8(%ebp),%esi
  80039c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80039f:	e8 bf 0b 00 00       	call   800f63 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8003a4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003b0:	c1 e0 07             	shl    $0x7,%eax
  8003b3:	29 d0                	sub    %edx,%eax
  8003b5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003ba:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003bf:	85 f6                	test   %esi,%esi
  8003c1:	7e 07                	jle    8003ca <libmain+0x36>
		binaryname = argv[0];
  8003c3:	8b 03                	mov    (%ebx),%eax
  8003c5:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	56                   	push   %esi
  8003cf:	e8 8b fc ff ff       	call   80005f <umain>

	// exit gracefully
	exit();
  8003d4:	e8 0b 00 00 00       	call   8003e4 <exit>
  8003d9:	83 c4 10             	add    $0x10,%esp
}
  8003dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003df:	5b                   	pop    %ebx
  8003e0:	5e                   	pop    %esi
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    
	...

008003e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8003ea:	6a 00                	push   $0x0
  8003ec:	e8 91 0b 00 00       	call   800f82 <sys_env_destroy>
  8003f1:	83 c4 10             	add    $0x10,%esp
}
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    
	...

008003f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800402:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800405:	8b 1d 8c 47 80 00    	mov    0x80478c,%ebx
  80040b:	e8 53 0b 00 00       	call   800f63 <sys_getenvid>
  800410:	83 ec 0c             	sub    $0xc,%esp
  800413:	ff 75 0c             	pushl  0xc(%ebp)
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	53                   	push   %ebx
  80041a:	50                   	push   %eax
  80041b:	68 ac 26 80 00       	push   $0x8026ac
  800420:	e8 74 00 00 00       	call   800499 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800425:	83 c4 18             	add    $0x18,%esp
  800428:	ff 75 f8             	pushl  -0x8(%ebp)
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	e8 15 00 00 00       	call   800448 <vcprintf>
	cprintf("\n");
  800433:	c7 04 24 7e 2b 80 00 	movl   $0x802b7e,(%esp)
  80043a:	e8 5a 00 00 00       	call   800499 <cprintf>
  80043f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800442:	cc                   	int3   
  800443:	eb fd                	jmp    800442 <_panic+0x4a>
  800445:	00 00                	add    %al,(%eax)
	...

00800448 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800451:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  800458:	00 00 00 
	b.cnt = 0;
  80045b:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800462:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800465:	ff 75 0c             	pushl  0xc(%ebp)
  800468:	ff 75 08             	pushl  0x8(%ebp)
  80046b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800471:	50                   	push   %eax
  800472:	68 b0 04 80 00       	push   $0x8004b0
  800477:	e8 70 01 00 00       	call   8005ec <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80047c:	83 c4 08             	add    $0x8,%esp
  80047f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800485:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	e8 9e 08 00 00       	call   800d2f <sys_cputs>
  800491:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    

00800499 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80049f:	8d 45 0c             	lea    0xc(%ebp),%eax
  8004a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  8004a5:	50                   	push   %eax
  8004a6:	ff 75 08             	pushl  0x8(%ebp)
  8004a9:	e8 9a ff ff ff       	call   800448 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 04             	sub    $0x4,%esp
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004ba:	8b 03                	mov    (%ebx),%eax
  8004bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004c3:	40                   	inc    %eax
  8004c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004cb:	75 1a                	jne    8004e7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	68 ff 00 00 00       	push   $0xff
  8004d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8004d8:	50                   	push   %eax
  8004d9:	e8 51 08 00 00       	call   800d2f <sys_cputs>
		b->idx = 0;
  8004de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8004e7:	ff 43 04             	incl   0x4(%ebx)
}
  8004ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    
	...

008004f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 1c             	sub    $0x1c,%esp
  8004f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8004fc:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8004ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800502:	8b 55 0c             	mov    0xc(%ebp),%edx
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800508:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80050b:	8b 55 10             	mov    0x10(%ebp),%edx
  80050e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800511:	89 d6                	mov    %edx,%esi
  800513:	bf 00 00 00 00       	mov    $0x0,%edi
  800518:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80051b:	72 04                	jb     800521 <printnum+0x31>
  80051d:	39 c2                	cmp    %eax,%edx
  80051f:	77 3f                	ja     800560 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800521:	83 ec 0c             	sub    $0xc,%esp
  800524:	ff 75 18             	pushl  0x18(%ebp)
  800527:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80052a:	50                   	push   %eax
  80052b:	52                   	push   %edx
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	57                   	push   %edi
  800530:	56                   	push   %esi
  800531:	ff 75 e4             	pushl  -0x1c(%ebp)
  800534:	ff 75 e0             	pushl  -0x20(%ebp)
  800537:	e8 68 1d 00 00       	call   8022a4 <__udivdi3>
  80053c:	83 c4 18             	add    $0x18,%esp
  80053f:	52                   	push   %edx
  800540:	50                   	push   %eax
  800541:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800544:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800547:	e8 a4 ff ff ff       	call   8004f0 <printnum>
  80054c:	83 c4 20             	add    $0x20,%esp
  80054f:	eb 14                	jmp    800565 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 e8             	pushl  -0x18(%ebp)
  800557:	ff 75 18             	pushl  0x18(%ebp)
  80055a:	ff 55 ec             	call   *-0x14(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800560:	4b                   	dec    %ebx
  800561:	85 db                	test   %ebx,%ebx
  800563:	7f ec                	jg     800551 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	ff 75 e8             	pushl  -0x18(%ebp)
  80056b:	83 ec 04             	sub    $0x4,%esp
  80056e:	57                   	push   %edi
  80056f:	56                   	push   %esi
  800570:	ff 75 e4             	pushl  -0x1c(%ebp)
  800573:	ff 75 e0             	pushl  -0x20(%ebp)
  800576:	e8 55 1e 00 00       	call   8023d0 <__umoddi3>
  80057b:	83 c4 14             	add    $0x14,%esp
  80057e:	0f be 80 cf 26 80 00 	movsbl 0x8026cf(%eax),%eax
  800585:	50                   	push   %eax
  800586:	ff 55 ec             	call   *-0x14(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
}
  80058c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80058f:	5b                   	pop    %ebx
  800590:	5e                   	pop    %esi
  800591:	5f                   	pop    %edi
  800592:	c9                   	leave  
  800593:	c3                   	ret    

00800594 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800594:	55                   	push   %ebp
  800595:	89 e5                	mov    %esp,%ebp
  800597:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800599:	83 fa 01             	cmp    $0x1,%edx
  80059c:	7e 0e                	jle    8005ac <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80059e:	8b 10                	mov    (%eax),%edx
  8005a0:	8d 42 08             	lea    0x8(%edx),%eax
  8005a3:	89 01                	mov    %eax,(%ecx)
  8005a5:	8b 02                	mov    (%edx),%eax
  8005a7:	8b 52 04             	mov    0x4(%edx),%edx
  8005aa:	eb 22                	jmp    8005ce <getuint+0x3a>
	else if (lflag)
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	74 10                	je     8005c0 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	8d 42 04             	lea    0x4(%edx),%eax
  8005b5:	89 01                	mov    %eax,(%ecx)
  8005b7:	8b 02                	mov    (%edx),%eax
  8005b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005be:	eb 0e                	jmp    8005ce <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	8d 42 04             	lea    0x4(%edx),%eax
  8005c5:	89 01                	mov    %eax,(%ecx)
  8005c7:	8b 02                	mov    (%edx),%eax
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ce:	c9                   	leave  
  8005cf:	c3                   	ret    

008005d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  8005d6:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  8005d9:	8b 11                	mov    (%ecx),%edx
  8005db:	3b 51 04             	cmp    0x4(%ecx),%edx
  8005de:	73 0a                	jae    8005ea <sprintputch+0x1a>
		*b->buf++ = ch;
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	88 02                	mov    %al,(%edx)
  8005e5:	8d 42 01             	lea    0x1(%edx),%eax
  8005e8:	89 01                	mov    %eax,(%ecx)
}
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	57                   	push   %edi
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	83 ec 3c             	sub    $0x3c,%esp
  8005f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005fe:	eb 1a                	jmp    80061a <vprintfmt+0x2e>
  800600:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800603:	eb 15                	jmp    80061a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800605:	84 c0                	test   %al,%al
  800607:	0f 84 15 03 00 00    	je     800922 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	0f b6 c0             	movzbl %al,%eax
  800614:	50                   	push   %eax
  800615:	ff d6                	call   *%esi
  800617:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061a:	8a 03                	mov    (%ebx),%al
  80061c:	43                   	inc    %ebx
  80061d:	3c 25                	cmp    $0x25,%al
  80061f:	75 e4                	jne    800605 <vprintfmt+0x19>
  800621:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800628:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80062f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800636:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80063d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  800641:	eb 0a                	jmp    80064d <vprintfmt+0x61>
  800643:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  80064a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8a 03                	mov    (%ebx),%al
  80064f:	0f b6 d0             	movzbl %al,%edx
  800652:	8d 4b 01             	lea    0x1(%ebx),%ecx
  800655:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800658:	83 e8 23             	sub    $0x23,%eax
  80065b:	3c 55                	cmp    $0x55,%al
  80065d:	0f 87 9c 02 00 00    	ja     8008ff <vprintfmt+0x313>
  800663:	0f b6 c0             	movzbl %al,%eax
  800666:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
  80066d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800671:	eb d7                	jmp    80064a <vprintfmt+0x5e>
  800673:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800677:	eb d1                	jmp    80064a <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800679:	89 d9                	mov    %ebx,%ecx
  80067b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800682:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800685:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800688:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80068c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80068f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800693:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800694:	8d 42 d0             	lea    -0x30(%edx),%eax
  800697:	83 f8 09             	cmp    $0x9,%eax
  80069a:	77 21                	ja     8006bd <vprintfmt+0xd1>
  80069c:	eb e4                	jmp    800682 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80069e:	8b 55 14             	mov    0x14(%ebp),%edx
  8006a1:	8d 42 04             	lea    0x4(%edx),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a7:	8b 12                	mov    (%edx),%edx
  8006a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ac:	eb 12                	jmp    8006c0 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  8006ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b2:	79 96                	jns    80064a <vprintfmt+0x5e>
  8006b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006bb:	eb 8d                	jmp    80064a <vprintfmt+0x5e>
  8006bd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c4:	79 84                	jns    80064a <vprintfmt+0x5e>
  8006c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8006d3:	e9 72 ff ff ff       	jmp    80064a <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d8:	ff 45 d4             	incl   -0x2c(%ebp)
  8006db:	e9 6a ff ff ff       	jmp    80064a <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006e0:	8b 55 14             	mov    0x14(%ebp),%edx
  8006e3:	8d 42 04             	lea    0x4(%edx),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	57                   	push   %edi
  8006ed:	ff 32                	pushl  (%edx)
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	e9 07 ff ff ff       	jmp    800600 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8006fc:	8d 42 04             	lea    0x4(%edx),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800702:	8b 02                	mov    (%edx),%eax
  800704:	85 c0                	test   %eax,%eax
  800706:	79 02                	jns    80070a <vprintfmt+0x11e>
  800708:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070a:	83 f8 0f             	cmp    $0xf,%eax
  80070d:	7f 0b                	jg     80071a <vprintfmt+0x12e>
  80070f:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800716:	85 d2                	test   %edx,%edx
  800718:	75 15                	jne    80072f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80071a:	50                   	push   %eax
  80071b:	68 e0 26 80 00       	push   $0x8026e0
  800720:	57                   	push   %edi
  800721:	56                   	push   %esi
  800722:	e8 6e 02 00 00       	call   800995 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	e9 d1 fe ff ff       	jmp    800600 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80072f:	52                   	push   %edx
  800730:	68 b1 2a 80 00       	push   $0x802ab1
  800735:	57                   	push   %edi
  800736:	56                   	push   %esi
  800737:	e8 59 02 00 00       	call   800995 <printfmt>
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	e9 bc fe ff ff       	jmp    800600 <vprintfmt+0x14>
  800744:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800747:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80074a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074d:	8b 55 14             	mov    0x14(%ebp),%edx
  800750:	8d 42 04             	lea    0x4(%edx),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
  800756:	8b 1a                	mov    (%edx),%ebx
  800758:	85 db                	test   %ebx,%ebx
  80075a:	75 05                	jne    800761 <vprintfmt+0x175>
  80075c:	bb e9 26 80 00       	mov    $0x8026e9,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800761:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800765:	7e 66                	jle    8007cd <vprintfmt+0x1e1>
  800767:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80076b:	74 60                	je     8007cd <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	51                   	push   %ecx
  800771:	53                   	push   %ebx
  800772:	e8 57 02 00 00       	call   8009ce <strnlen>
  800777:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80077a:	29 c1                	sub    %eax,%ecx
  80077c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800786:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800789:	eb 0f                	jmp    80079a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	57                   	push   %edi
  80078f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800792:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800794:	ff 4d d8             	decl   -0x28(%ebp)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80079e:	7f eb                	jg     80078b <vprintfmt+0x19f>
  8007a0:	eb 2b                	jmp    8007cd <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a2:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  8007a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007a9:	74 15                	je     8007c0 <vprintfmt+0x1d4>
  8007ab:	8d 42 e0             	lea    -0x20(%edx),%eax
  8007ae:	83 f8 5e             	cmp    $0x5e,%eax
  8007b1:	76 0d                	jbe    8007c0 <vprintfmt+0x1d4>
					putch('?', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	6a 3f                	push   $0x3f
  8007b9:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 0a                	jmp    8007ca <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	57                   	push   %edi
  8007c4:	52                   	push   %edx
  8007c5:	ff d6                	call   *%esi
  8007c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ca:	ff 4d d8             	decl   -0x28(%ebp)
  8007cd:	8a 03                	mov    (%ebx),%al
  8007cf:	43                   	inc    %ebx
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 1b                	je     8007ef <vprintfmt+0x203>
  8007d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d8:	78 c8                	js     8007a2 <vprintfmt+0x1b6>
  8007da:	ff 4d dc             	decl   -0x24(%ebp)
  8007dd:	79 c3                	jns    8007a2 <vprintfmt+0x1b6>
  8007df:	eb 0e                	jmp    8007ef <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	57                   	push   %edi
  8007e5:	6a 20                	push   $0x20
  8007e7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e9:	ff 4d d8             	decl   -0x28(%ebp)
  8007ec:	83 c4 10             	add    $0x10,%esp
  8007ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007f3:	7f ec                	jg     8007e1 <vprintfmt+0x1f5>
  8007f5:	e9 06 fe ff ff       	jmp    800600 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fa:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8007fe:	7e 10                	jle    800810 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800800:	8b 55 14             	mov    0x14(%ebp),%edx
  800803:	8d 42 08             	lea    0x8(%edx),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
  800809:	8b 02                	mov    (%edx),%eax
  80080b:	8b 52 04             	mov    0x4(%edx),%edx
  80080e:	eb 20                	jmp    800830 <vprintfmt+0x244>
	else if (lflag)
  800810:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800814:	74 0e                	je     800824 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	99                   	cltd   
  800822:	eb 0c                	jmp    800830 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8d 50 04             	lea    0x4(%eax),%edx
  80082a:	89 55 14             	mov    %edx,0x14(%ebp)
  80082d:	8b 00                	mov    (%eax),%eax
  80082f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800830:	89 d1                	mov    %edx,%ecx
  800832:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800834:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800837:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	78 0a                	js     800848 <vprintfmt+0x25c>
  80083e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800843:	e9 89 00 00 00       	jmp    8008d1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	57                   	push   %edi
  80084c:	6a 2d                	push   $0x2d
  80084e:	ff d6                	call   *%esi
				num = -(long long) num;
  800850:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800853:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800856:	f7 da                	neg    %edx
  800858:	83 d1 00             	adc    $0x0,%ecx
  80085b:	f7 d9                	neg    %ecx
  80085d:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	eb 6a                	jmp    8008d1 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80086d:	e8 22 fd ff ff       	call   800594 <getuint>
  800872:	89 d1                	mov    %edx,%ecx
  800874:	89 c2                	mov    %eax,%edx
  800876:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80087b:	eb 54                	jmp    8008d1 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800883:	e8 0c fd ff ff       	call   800594 <getuint>
  800888:	89 d1                	mov    %edx,%ecx
  80088a:	89 c2                	mov    %eax,%edx
  80088c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800891:	eb 3e                	jmp    8008d1 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	57                   	push   %edi
  800897:	6a 30                	push   $0x30
  800899:	ff d6                	call   *%esi
			putch('x', putdat);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	57                   	push   %edi
  80089f:	6a 78                	push   $0x78
  8008a1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008a3:	8b 55 14             	mov    0x14(%ebp),%edx
  8008a6:	8d 42 04             	lea    0x4(%edx),%eax
  8008a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ac:	8b 12                	mov    (%edx),%edx
  8008ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b3:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 14                	jmp    8008d1 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008c3:	e8 cc fc ff ff       	call   800594 <getuint>
  8008c8:	89 d1                	mov    %edx,%ecx
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d1:	83 ec 0c             	sub    $0xc,%esp
  8008d4:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8008d8:	50                   	push   %eax
  8008d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8008dc:	53                   	push   %ebx
  8008dd:	51                   	push   %ecx
  8008de:	52                   	push   %edx
  8008df:	89 fa                	mov    %edi,%edx
  8008e1:	89 f0                	mov    %esi,%eax
  8008e3:	e8 08 fc ff ff       	call   8004f0 <printnum>
			break;
  8008e8:	83 c4 20             	add    $0x20,%esp
  8008eb:	e9 10 fd ff ff       	jmp    800600 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	57                   	push   %edi
  8008f4:	52                   	push   %edx
  8008f5:	ff d6                	call   *%esi
			break;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	e9 01 fd ff ff       	jmp    800600 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	57                   	push   %edi
  800903:	6a 25                	push   $0x25
  800905:	ff d6                	call   *%esi
  800907:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80090a:	83 ea 02             	sub    $0x2,%edx
  80090d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800910:	8a 02                	mov    (%edx),%al
  800912:	4a                   	dec    %edx
  800913:	3c 25                	cmp    $0x25,%al
  800915:	75 f9                	jne    800910 <vprintfmt+0x324>
  800917:	83 c2 02             	add    $0x2,%edx
  80091a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80091d:	e9 de fc ff ff       	jmp    800600 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800922:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 18             	sub    $0x18,%esp
  800930:	8b 55 08             	mov    0x8(%ebp),%edx
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800936:	85 d2                	test   %edx,%edx
  800938:	74 37                	je     800971 <vsnprintf+0x47>
  80093a:	85 c0                	test   %eax,%eax
  80093c:	7e 33                	jle    800971 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800945:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800949:	89 45 f8             	mov    %eax,-0x8(%ebp)
  80094c:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094f:	ff 75 14             	pushl  0x14(%ebp)
  800952:	ff 75 10             	pushl  0x10(%ebp)
  800955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800958:	50                   	push   %eax
  800959:	68 d0 05 80 00       	push   $0x8005d0
  80095e:	e8 89 fc ff ff       	call   8005ec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800966:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800969:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	eb 05                	jmp    800976 <vsnprintf+0x4c>
  800971:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
  800981:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800984:	50                   	push   %eax
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 97 ff ff ff       	call   80092a <vsnprintf>
	va_end(ap);

	return rc;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80099b:	8d 45 14             	lea    0x14(%ebp),%eax
  80099e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8009a1:	50                   	push   %eax
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 3c fc ff ff       	call   8005ec <vprintfmt>
	va_end(ap);
  8009b0:	83 c4 10             	add    $0x10,%esp
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    
  8009b5:	00 00                	add    %al,(%eax)
	...

008009b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c3:	eb 01                	jmp    8009c6 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  8009c5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  8009ca:	75 f9                	jne    8009c5 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb 01                	jmp    8009df <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  8009de:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009df:	39 d0                	cmp    %edx,%eax
  8009e1:	74 06                	je     8009e9 <strnlen+0x1b>
  8009e3:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  8009e7:	75 f5                	jne    8009de <strnlen+0x10>
		n++;
	return n;
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f4:	8a 01                	mov    (%ecx),%al
  8009f6:	88 02                	mov    %al,(%edx)
  8009f8:	42                   	inc    %edx
  8009f9:	41                   	inc    %ecx
  8009fa:	84 c0                	test   %al,%al
  8009fc:	75 f6                	jne    8009f4 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0a:	53                   	push   %ebx
  800a0b:	e8 a8 ff ff ff       	call   8009b8 <strlen>
	strcpy(dst + len, src);
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a16:	50                   	push   %eax
  800a17:	e8 cf ff ff ff       	call   8009eb <strcpy>
	return dst;
}
  800a1c:	89 d8                	mov    %ebx,%eax
  800a1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800a31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a36:	eb 0c                	jmp    800a44 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800a38:	8a 02                	mov    (%edx),%al
  800a3a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3d:	80 3a 01             	cmpb   $0x1,(%edx)
  800a40:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a43:	41                   	inc    %ecx
  800a44:	39 d9                	cmp    %ebx,%ecx
  800a46:	75 f0                	jne    800a38 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a48:	89 f0                	mov    %esi,%eax
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 75 08             	mov    0x8(%ebp),%esi
  800a56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5c:	85 c9                	test   %ecx,%ecx
  800a5e:	75 04                	jne    800a64 <strlcpy+0x16>
  800a60:	89 f0                	mov    %esi,%eax
  800a62:	eb 14                	jmp    800a78 <strlcpy+0x2a>
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	eb 04                	jmp    800a6c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a68:	88 10                	mov    %dl,(%eax)
  800a6a:	40                   	inc    %eax
  800a6b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a6c:	49                   	dec    %ecx
  800a6d:	74 06                	je     800a75 <strlcpy+0x27>
  800a6f:	8a 13                	mov    (%ebx),%dl
  800a71:	84 d2                	test   %dl,%dl
  800a73:	75 f3                	jne    800a68 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a75:	c6 00 00             	movb   $0x0,(%eax)
  800a78:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 55 08             	mov    0x8(%ebp),%edx
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a87:	eb 02                	jmp    800a8b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800a89:	42                   	inc    %edx
  800a8a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8b:	8a 02                	mov    (%edx),%al
  800a8d:	84 c0                	test   %al,%al
  800a8f:	74 04                	je     800a95 <strcmp+0x17>
  800a91:	3a 01                	cmp    (%ecx),%al
  800a93:	74 f4                	je     800a89 <strcmp+0xb>
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 11             	movzbl (%ecx),%edx
  800a9b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa9:	8b 55 10             	mov    0x10(%ebp),%edx
  800aac:	eb 03                	jmp    800ab1 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800aae:	4a                   	dec    %edx
  800aaf:	41                   	inc    %ecx
  800ab0:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab1:	85 d2                	test   %edx,%edx
  800ab3:	75 07                	jne    800abc <strncmp+0x1d>
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	eb 14                	jmp    800ad0 <strncmp+0x31>
  800abc:	8a 01                	mov    (%ecx),%al
  800abe:	84 c0                	test   %al,%al
  800ac0:	74 04                	je     800ac6 <strncmp+0x27>
  800ac2:	3a 03                	cmp    (%ebx),%al
  800ac4:	74 e8                	je     800aae <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac6:	0f b6 d0             	movzbl %al,%edx
  800ac9:	0f b6 03             	movzbl (%ebx),%eax
  800acc:	29 c2                	sub    %eax,%edx
  800ace:	89 d0                	mov    %edx,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800adc:	eb 05                	jmp    800ae3 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800ade:	38 ca                	cmp    %cl,%dl
  800ae0:	74 0c                	je     800aee <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae2:	40                   	inc    %eax
  800ae3:	8a 10                	mov    (%eax),%dl
  800ae5:	84 d2                	test   %dl,%dl
  800ae7:	75 f5                	jne    800ade <strchr+0xb>
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800af9:	eb 05                	jmp    800b00 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800afb:	38 ca                	cmp    %cl,%dl
  800afd:	74 07                	je     800b06 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aff:	40                   	inc    %eax
  800b00:	8a 10                	mov    (%eax),%dl
  800b02:	84 d2                	test   %dl,%dl
  800b04:	75 f5                	jne    800afb <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	74 36                	je     800b51 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b21:	75 29                	jne    800b4c <memset+0x44>
  800b23:	f6 c3 03             	test   $0x3,%bl
  800b26:	75 24                	jne    800b4c <memset+0x44>
		c &= 0xFF;
  800b28:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	c1 e6 08             	shl    $0x8,%esi
  800b30:	89 d0                	mov    %edx,%eax
  800b32:	c1 e0 18             	shl    $0x18,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	c1 e1 10             	shl    $0x10,%ecx
  800b3a:	09 c8                	or     %ecx,%eax
  800b3c:	09 c2                	or     %eax,%edx
  800b3e:	89 f0                	mov    %esi,%eax
  800b40:	09 d0                	or     %edx,%eax
  800b42:	89 d9                	mov    %ebx,%ecx
  800b44:	c1 e9 02             	shr    $0x2,%ecx
  800b47:	fc                   	cld    
  800b48:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4a:	eb 05                	jmp    800b51 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4c:	89 d9                	mov    %ebx,%ecx
  800b4e:	fc                   	cld    
  800b4f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b51:	89 f8                	mov    %edi,%eax
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b63:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b66:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b68:	39 c6                	cmp    %eax,%esi
  800b6a:	73 36                	jae    800ba2 <memmove+0x4a>
  800b6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6f:	39 d0                	cmp    %edx,%eax
  800b71:	73 2f                	jae    800ba2 <memmove+0x4a>
		s += n;
		d += n;
  800b73:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f6 c2 03             	test   $0x3,%dl
  800b79:	75 1b                	jne    800b96 <memmove+0x3e>
  800b7b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b81:	75 13                	jne    800b96 <memmove+0x3e>
  800b83:	f6 c1 03             	test   $0x3,%cl
  800b86:	75 0e                	jne    800b96 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800b88:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8e:	c1 e9 02             	shr    $0x2,%ecx
  800b91:	fd                   	std    
  800b92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b94:	eb 09                	jmp    800b9f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b96:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b99:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9c:	fd                   	std    
  800b9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9f:	fc                   	cld    
  800ba0:	eb 20                	jmp    800bc2 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba8:	75 15                	jne    800bbf <memmove+0x67>
  800baa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb0:	75 0d                	jne    800bbf <memmove+0x67>
  800bb2:	f6 c1 03             	test   $0x3,%cl
  800bb5:	75 08                	jne    800bbf <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800bb7:	c1 e9 02             	shr    $0x2,%ecx
  800bba:	fc                   	cld    
  800bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbd:	eb 03                	jmp    800bc2 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbf:	fc                   	cld    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	ff 75 08             	pushl  0x8(%ebp)
  800bd2:	e8 81 ff ff ff       	call   800b58 <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 04             	sub    $0x4,%esp
  800be0:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	eb 1b                	jmp    800c06 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800beb:	8a 1a                	mov    (%edx),%bl
  800bed:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800bf0:	8a 19                	mov    (%ecx),%bl
  800bf2:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800bf5:	74 0d                	je     800c04 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800bf7:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800bfb:	0f b6 c3             	movzbl %bl,%eax
  800bfe:	29 c2                	sub    %eax,%edx
  800c00:	89 d0                	mov    %edx,%eax
  800c02:	eb 0d                	jmp    800c11 <memcmp+0x38>
		s1++, s2++;
  800c04:	42                   	inc    %edx
  800c05:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c06:	48                   	dec    %eax
  800c07:	83 f8 ff             	cmp    $0xffffffff,%eax
  800c0a:	75 df                	jne    800beb <memcmp+0x12>
  800c0c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c11:	83 c4 04             	add    $0x4,%esp
  800c14:	5b                   	pop    %ebx
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c20:	89 c2                	mov    %eax,%edx
  800c22:	03 55 10             	add    0x10(%ebp),%edx
  800c25:	eb 05                	jmp    800c2c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c27:	38 08                	cmp    %cl,(%eax)
  800c29:	74 05                	je     800c30 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2b:	40                   	inc    %eax
  800c2c:	39 d0                	cmp    %edx,%eax
  800c2e:	72 f7                	jb     800c27 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 04             	sub    $0x4,%esp
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 75 10             	mov    0x10(%ebp),%esi
  800c41:	eb 01                	jmp    800c44 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800c43:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	8a 01                	mov    (%ecx),%al
  800c46:	3c 20                	cmp    $0x20,%al
  800c48:	74 f9                	je     800c43 <strtol+0x11>
  800c4a:	3c 09                	cmp    $0x9,%al
  800c4c:	74 f5                	je     800c43 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4e:	3c 2b                	cmp    $0x2b,%al
  800c50:	75 0a                	jne    800c5c <strtol+0x2a>
		s++;
  800c52:	41                   	inc    %ecx
  800c53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c5a:	eb 17                	jmp    800c73 <strtol+0x41>
	else if (*s == '-')
  800c5c:	3c 2d                	cmp    $0x2d,%al
  800c5e:	74 09                	je     800c69 <strtol+0x37>
  800c60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c67:	eb 0a                	jmp    800c73 <strtol+0x41>
		s++, neg = 1;
  800c69:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c6c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c73:	85 f6                	test   %esi,%esi
  800c75:	74 05                	je     800c7c <strtol+0x4a>
  800c77:	83 fe 10             	cmp    $0x10,%esi
  800c7a:	75 1a                	jne    800c96 <strtol+0x64>
  800c7c:	8a 01                	mov    (%ecx),%al
  800c7e:	3c 30                	cmp    $0x30,%al
  800c80:	75 10                	jne    800c92 <strtol+0x60>
  800c82:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c86:	75 0a                	jne    800c92 <strtol+0x60>
		s += 2, base = 16;
  800c88:	83 c1 02             	add    $0x2,%ecx
  800c8b:	be 10 00 00 00       	mov    $0x10,%esi
  800c90:	eb 04                	jmp    800c96 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800c92:	85 f6                	test   %esi,%esi
  800c94:	74 07                	je     800c9d <strtol+0x6b>
  800c96:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9b:	eb 13                	jmp    800cb0 <strtol+0x7e>
  800c9d:	3c 30                	cmp    $0x30,%al
  800c9f:	74 07                	je     800ca8 <strtol+0x76>
  800ca1:	be 0a 00 00 00       	mov    $0xa,%esi
  800ca6:	eb ee                	jmp    800c96 <strtol+0x64>
		s++, base = 8;
  800ca8:	41                   	inc    %ecx
  800ca9:	be 08 00 00 00       	mov    $0x8,%esi
  800cae:	eb e6                	jmp    800c96 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb0:	8a 11                	mov    (%ecx),%dl
  800cb2:	88 d3                	mov    %dl,%bl
  800cb4:	8d 42 d0             	lea    -0x30(%edx),%eax
  800cb7:	3c 09                	cmp    $0x9,%al
  800cb9:	77 08                	ja     800cc3 <strtol+0x91>
			dig = *s - '0';
  800cbb:	0f be c2             	movsbl %dl,%eax
  800cbe:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cc1:	eb 1c                	jmp    800cdf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc3:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800cc6:	3c 19                	cmp    $0x19,%al
  800cc8:	77 08                	ja     800cd2 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800cca:	0f be c2             	movsbl %dl,%eax
  800ccd:	8d 50 a9             	lea    -0x57(%eax),%edx
  800cd0:	eb 0d                	jmp    800cdf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800cd5:	3c 19                	cmp    $0x19,%al
  800cd7:	77 15                	ja     800cee <strtol+0xbc>
			dig = *s - 'A' + 10;
  800cd9:	0f be c2             	movsbl %dl,%eax
  800cdc:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800cdf:	39 f2                	cmp    %esi,%edx
  800ce1:	7d 0b                	jge    800cee <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800ce3:	41                   	inc    %ecx
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	0f af c6             	imul   %esi,%eax
  800ce9:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800cec:	eb c2                	jmp    800cb0 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800cee:	89 f8                	mov    %edi,%eax

	if (endptr)
  800cf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf4:	74 05                	je     800cfb <strtol+0xc9>
		*endptr = (char *) s;
  800cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf9:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800cfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cff:	74 04                	je     800d05 <strtol+0xd3>
  800d01:	89 c7                	mov    %eax,%edi
  800d03:	f7 df                	neg    %edi
}
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	83 c4 04             	add    $0x4,%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    
	...

00800d10 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
  800d20:	89 fa                	mov    %edi,%edx
  800d22:	89 f9                	mov    %edi,%ecx
  800d24:	89 fb                	mov    %edi,%ebx
  800d26:	89 fe                	mov    %edi,%esi
  800d28:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 04             	sub    $0x4,%esp
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d43:	89 f8                	mov    %edi,%eax
  800d45:	89 fb                	mov    %edi,%ebx
  800d47:	89 fe                	mov    %edi,%esi
  800d49:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4b:	83 c4 04             	add    $0x4,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d64:	bf 00 00 00 00       	mov    $0x0,%edi
  800d69:	89 f9                	mov    %edi,%ecx
  800d6b:	89 fb                	mov    %edi,%ebx
  800d6d:	89 fe                	mov    %edi,%esi
  800d6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 17                	jle    800d8c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	50                   	push   %eax
  800d79:	6a 0d                	push   $0xd
  800d7b:	68 df 29 80 00       	push   $0x8029df
  800d80:	6a 23                	push   $0x23
  800d82:	68 fc 29 80 00       	push   $0x8029fc
  800d87:	e8 6c f6 ff ff       	call   8003f8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da3:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcb:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd0:	89 fb                	mov    %edi,%ebx
  800dd2:	89 fe                	mov    %edi,%esi
  800dd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 17                	jle    800df1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	50                   	push   %eax
  800dde:	6a 0a                	push   $0xa
  800de0:	68 df 29 80 00       	push   $0x8029df
  800de5:	6a 23                	push   $0x23
  800de7:	68 fc 29 80 00       	push   $0x8029fc
  800dec:	e8 07 f6 ff ff       	call   8003f8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800e12:	89 fb                	mov    %edi,%ebx
  800e14:	89 fe                	mov    %edi,%esi
  800e16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	7e 17                	jle    800e33 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	50                   	push   %eax
  800e20:	6a 09                	push   $0x9
  800e22:	68 df 29 80 00       	push   $0x8029df
  800e27:	6a 23                	push   $0x23
  800e29:	68 fc 29 80 00       	push   $0x8029fc
  800e2e:	e8 c5 f5 ff ff       	call   8003f8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5e                   	pop    %esi
  800e38:	5f                   	pop    %edi
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 0c             	sub    $0xc,%esp
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800e54:	89 fb                	mov    %edi,%ebx
  800e56:	89 fe                	mov    %edi,%esi
  800e58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	7e 17                	jle    800e75 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	50                   	push   %eax
  800e62:	6a 08                	push   $0x8
  800e64:	68 df 29 80 00       	push   $0x8029df
  800e69:	6a 23                	push   $0x23
  800e6b:	68 fc 29 80 00       	push   $0x8029fc
  800e70:	e8 83 f5 ff ff       	call   8003f8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e91:	bf 00 00 00 00       	mov    $0x0,%edi
  800e96:	89 fb                	mov    %edi,%ebx
  800e98:	89 fe                	mov    %edi,%esi
  800e9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7e 17                	jle    800eb7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea0:	83 ec 0c             	sub    $0xc,%esp
  800ea3:	50                   	push   %eax
  800ea4:	6a 06                	push   $0x6
  800ea6:	68 df 29 80 00       	push   $0x8029df
  800eab:	6a 23                	push   $0x23
  800ead:	68 fc 29 80 00       	push   $0x8029fc
  800eb2:	e8 41 f5 ff ff       	call   8003f8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    

00800ebf <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ece:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed4:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	b8 05 00 00 00       	mov    $0x5,%eax
  800edc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	7e 17                	jle    800ef9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	50                   	push   %eax
  800ee6:	6a 05                	push   $0x5
  800ee8:	68 df 29 80 00       	push   $0x8029df
  800eed:	6a 23                	push   $0x23
  800eef:	68 fc 29 80 00       	push   $0x8029fc
  800ef4:	e8 ff f4 ff ff       	call   8003f8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5f                   	pop    %edi
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	b8 04 00 00 00       	mov    $0x4,%eax
  800f18:	bf 00 00 00 00       	mov    $0x0,%edi
  800f1d:	89 fe                	mov    %edi,%esi
  800f1f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	7e 17                	jle    800f3c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	50                   	push   %eax
  800f29:	6a 04                	push   $0x4
  800f2b:	68 df 29 80 00       	push   $0x8029df
  800f30:	6a 23                	push   $0x23
  800f32:	68 fc 29 80 00       	push   $0x8029fc
  800f37:	e8 bc f4 ff ff       	call   8003f8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	57                   	push   %edi
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f54:	89 fa                	mov    %edi,%edx
  800f56:	89 f9                	mov    %edi,%ecx
  800f58:	89 fb                	mov    %edi,%ebx
  800f5a:	89 fe                	mov    %edi,%esi
  800f5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f69:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800f73:	89 fa                	mov    %edi,%edx
  800f75:	89 f9                	mov    %edi,%ecx
  800f77:	89 fb                	mov    %edi,%ebx
  800f79:	89 fe                	mov    %edi,%esi
  800f7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8e:	b8 03 00 00 00       	mov    $0x3,%eax
  800f93:	bf 00 00 00 00       	mov    $0x0,%edi
  800f98:	89 f9                	mov    %edi,%ecx
  800f9a:	89 fb                	mov    %edi,%ebx
  800f9c:	89 fe                	mov    %edi,%esi
  800f9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 17                	jle    800fbb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	50                   	push   %eax
  800fa8:	6a 03                	push   $0x3
  800faa:	68 df 29 80 00       	push   $0x8029df
  800faf:	6a 23                	push   $0x23
  800fb1:	68 fc 29 80 00       	push   $0x8029fc
  800fb6:	e8 3d f4 ff ff       	call   8003f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbe:	5b                   	pop    %ebx
  800fbf:	5e                   	pop    %esi
  800fc0:	5f                   	pop    %edi
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    
	...

00800fc4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	05 00 00 00 30       	add    $0x30000000,%eax
  800fcf:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800fd7:	ff 75 08             	pushl  0x8(%ebp)
  800fda:	e8 e5 ff ff ff       	call   800fc4 <fd2num>
  800fdf:	83 c4 04             	add    $0x4,%esp
  800fe2:	c1 e0 0c             	shl    $0xc,%eax
  800fe5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	53                   	push   %ebx
  800ff0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ff3:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  800ff8:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ffa:	89 d0                	mov    %edx,%eax
  800ffc:	c1 e8 16             	shr    $0x16,%eax
  800fff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801006:	a8 01                	test   $0x1,%al
  801008:	74 10                	je     80101a <fd_alloc+0x2e>
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	c1 e8 0c             	shr    $0xc,%eax
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	a8 01                	test   $0x1,%al
  801018:	75 09                	jne    801023 <fd_alloc+0x37>
			*fd_store = fd;
  80101a:	89 0b                	mov    %ecx,(%ebx)
  80101c:	b8 00 00 00 00       	mov    $0x0,%eax
  801021:	eb 19                	jmp    80103c <fd_alloc+0x50>
			return 0;
  801023:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801029:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  80102f:	75 c7                	jne    800ff8 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801031:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801037:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  80103c:	5b                   	pop    %ebx
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    

0080103f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801045:	83 f8 1f             	cmp    $0x1f,%eax
  801048:	77 35                	ja     80107f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80104a:	c1 e0 0c             	shl    $0xc,%eax
  80104d:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801053:	89 d0                	mov    %edx,%eax
  801055:	c1 e8 16             	shr    $0x16,%eax
  801058:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105f:	a8 01                	test   $0x1,%al
  801061:	74 1c                	je     80107f <fd_lookup+0x40>
  801063:	89 d0                	mov    %edx,%eax
  801065:	c1 e8 0c             	shr    $0xc,%eax
  801068:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106f:	a8 01                	test   $0x1,%al
  801071:	74 0c                	je     80107f <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801073:	8b 45 0c             	mov    0xc(%ebp),%eax
  801076:	89 10                	mov    %edx,(%eax)
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	eb 05                	jmp    801084 <fd_lookup+0x45>
	return 0;
  80107f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80108c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80108f:	50                   	push   %eax
  801090:	ff 75 08             	pushl  0x8(%ebp)
  801093:	e8 a7 ff ff ff       	call   80103f <fd_lookup>
  801098:	83 c4 08             	add    $0x8,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 0e                	js     8010ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80109f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010a5:	89 50 04             	mov    %edx,0x4(%eax)
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c1:	eb 0e                	jmp    8010d1 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8010c3:	3b 08                	cmp    (%eax),%ecx
  8010c5:	75 09                	jne    8010d0 <dev_lookup+0x21>
			*dev = devtab[i];
  8010c7:	89 03                	mov    %eax,(%ebx)
  8010c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ce:	eb 31                	jmp    801101 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010d0:	42                   	inc    %edx
  8010d1:	8b 04 95 88 2a 80 00 	mov    0x802a88(,%edx,4),%eax
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	75 e7                	jne    8010c3 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010dc:	a1 90 67 80 00       	mov    0x806790,%eax
  8010e1:	8b 40 48             	mov    0x48(%eax),%eax
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	51                   	push   %ecx
  8010e8:	50                   	push   %eax
  8010e9:	68 0c 2a 80 00       	push   $0x802a0c
  8010ee:	e8 a6 f3 ff ff       	call   800499 <cprintf>
	*dev = 0;
  8010f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fe:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	53                   	push   %ebx
  80110a:	83 ec 14             	sub    $0x14,%esp
  80110d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801110:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	ff 75 08             	pushl  0x8(%ebp)
  801117:	e8 23 ff ff ff       	call   80103f <fd_lookup>
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 55                	js     801178 <fstat+0x72>
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	ff 30                	pushl  (%eax)
  80112f:	e8 7b ff ff ff       	call   8010af <dev_lookup>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	78 3d                	js     801178 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  80113b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80113e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801142:	75 07                	jne    80114b <fstat+0x45>
  801144:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801149:	eb 2d                	jmp    801178 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80114b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80114e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801155:	00 00 00 
	stat->st_isdir = 0;
  801158:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80115f:	00 00 00 
	stat->st_dev = dev;
  801162:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801165:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	53                   	push   %ebx
  80116f:	ff 75 f4             	pushl  -0xc(%ebp)
  801172:	ff 50 14             	call   *0x14(%eax)
  801175:	83 c4 10             	add    $0x10,%esp
}
  801178:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	53                   	push   %ebx
  801181:	83 ec 14             	sub    $0x14,%esp
  801184:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	53                   	push   %ebx
  80118c:	e8 ae fe ff ff       	call   80103f <fd_lookup>
  801191:	83 c4 08             	add    $0x8,%esp
  801194:	85 c0                	test   %eax,%eax
  801196:	78 5f                	js     8011f7 <ftruncate+0x7a>
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80119e:	50                   	push   %eax
  80119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a2:	ff 30                	pushl  (%eax)
  8011a4:	e8 06 ff ff ff       	call   8010af <dev_lookup>
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 47                	js     8011f7 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b7:	75 21                	jne    8011da <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b9:	a1 90 67 80 00       	mov    0x806790,%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	83 ec 04             	sub    $0x4,%esp
  8011c4:	53                   	push   %ebx
  8011c5:	50                   	push   %eax
  8011c6:	68 2c 2a 80 00       	push   $0x802a2c
  8011cb:	e8 c9 f2 ff ff       	call   800499 <cprintf>
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	eb 1d                	jmp    8011f7 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8011da:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8011dd:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  8011e1:	75 07                	jne    8011ea <ftruncate+0x6d>
  8011e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011e8:	eb 0d                	jmp    8011f7 <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	50                   	push   %eax
  8011f1:	ff 52 18             	call   *0x18(%edx)
  8011f4:	83 c4 10             	add    $0x10,%esp
}
  8011f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    

008011fc <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	53                   	push   %ebx
  801200:	83 ec 14             	sub    $0x14,%esp
  801203:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801206:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801209:	50                   	push   %eax
  80120a:	53                   	push   %ebx
  80120b:	e8 2f fe ff ff       	call   80103f <fd_lookup>
  801210:	83 c4 08             	add    $0x8,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 62                	js     801279 <write+0x7d>
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801221:	ff 30                	pushl  (%eax)
  801223:	e8 87 fe ff ff       	call   8010af <dev_lookup>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 4a                	js     801279 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801232:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801236:	75 21                	jne    801259 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801238:	a1 90 67 80 00       	mov    0x806790,%eax
  80123d:	8b 40 48             	mov    0x48(%eax),%eax
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	53                   	push   %ebx
  801244:	50                   	push   %eax
  801245:	68 4d 2a 80 00       	push   $0x802a4d
  80124a:	e8 4a f2 ff ff       	call   800499 <cprintf>
  80124f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	eb 20                	jmp    801279 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801259:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80125c:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  801260:	75 07                	jne    801269 <write+0x6d>
  801262:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801267:	eb 10                	jmp    801279 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	ff 75 10             	pushl  0x10(%ebp)
  80126f:	ff 75 0c             	pushl  0xc(%ebp)
  801272:	50                   	push   %eax
  801273:	ff 52 0c             	call   *0xc(%edx)
  801276:	83 c4 10             	add    $0x10,%esp
}
  801279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	83 ec 14             	sub    $0x14,%esp
  801285:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	53                   	push   %ebx
  80128d:	e8 ad fd ff ff       	call   80103f <fd_lookup>
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 67                	js     801300 <read+0x82>
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a3:	ff 30                	pushl  (%eax)
  8012a5:	e8 05 fe ff ff       	call   8010af <dev_lookup>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 4f                	js     801300 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8012b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b4:	8b 42 08             	mov    0x8(%edx),%eax
  8012b7:	83 e0 03             	and    $0x3,%eax
  8012ba:	83 f8 01             	cmp    $0x1,%eax
  8012bd:	75 21                	jne    8012e0 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bf:	a1 90 67 80 00       	mov    0x806790,%eax
  8012c4:	8b 40 48             	mov    0x48(%eax),%eax
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	50                   	push   %eax
  8012cc:	68 6a 2a 80 00       	push   $0x802a6a
  8012d1:	e8 c3 f1 ff ff       	call   800499 <cprintf>
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb 20                	jmp    801300 <read+0x82>
	}
	if (!dev->dev_read)
  8012e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012e3:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  8012e7:	75 07                	jne    8012f0 <read+0x72>
  8012e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ee:	eb 10                	jmp    801300 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	ff 75 10             	pushl  0x10(%ebp)
  8012f6:	ff 75 0c             	pushl  0xc(%ebp)
  8012f9:	52                   	push   %edx
  8012fa:	ff 50 08             	call   *0x8(%eax)
  8012fd:	83 c4 10             	add    $0x10,%esp
}
  801300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801311:	8b 75 10             	mov    0x10(%ebp),%esi
  801314:	bb 00 00 00 00       	mov    $0x0,%ebx
  801319:	eb 21                	jmp    80133c <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  80131b:	83 ec 04             	sub    $0x4,%esp
  80131e:	89 f0                	mov    %esi,%eax
  801320:	29 d0                	sub    %edx,%eax
  801322:	50                   	push   %eax
  801323:	8d 04 17             	lea    (%edi,%edx,1),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 4f ff ff ff       	call   80127e <read>
		if (m < 0)
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 0e                	js     801344 <readn+0x3f>
			return m;
		if (m == 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	74 08                	je     801342 <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80133a:	01 c3                	add    %eax,%ebx
  80133c:	89 da                	mov    %ebx,%edx
  80133e:	39 f3                	cmp    %esi,%ebx
  801340:	72 d9                	jb     80131b <readn+0x16>
  801342:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
  801351:	83 ec 20             	sub    $0x20,%esp
  801354:	8b 75 08             	mov    0x8(%ebp),%esi
  801357:	8a 45 0c             	mov    0xc(%ebp),%al
  80135a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	56                   	push   %esi
  801362:	e8 5d fc ff ff       	call   800fc4 <fd2num>
  801367:	89 04 24             	mov    %eax,(%esp)
  80136a:	e8 d0 fc ff ff       	call   80103f <fd_lookup>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 08             	add    $0x8,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 05                	js     80137d <fd_close+0x31>
  801378:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80137b:	74 0d                	je     80138a <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  80137d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801381:	75 48                	jne    8013cb <fd_close+0x7f>
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
  801388:	eb 41                	jmp    8013cb <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	ff 36                	pushl  (%esi)
  801393:	e8 17 fd ff ff       	call   8010af <dev_lookup>
  801398:	89 c3                	mov    %eax,%ebx
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 1c                	js     8013bd <fd_close+0x71>
		if (dev->dev_close)
  8013a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a4:	8b 40 10             	mov    0x10(%eax),%eax
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	75 07                	jne    8013b2 <fd_close+0x66>
  8013ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b0:	eb 0b                	jmp    8013bd <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	56                   	push   %esi
  8013b6:	ff d0                	call   *%eax
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	56                   	push   %esi
  8013c1:	6a 00                	push   $0x0
  8013c3:	e8 b5 fa ff ff       	call   800e7d <sys_page_unmap>
  8013c8:	83 c4 10             	add    $0x10,%esp
	return r;
}
  8013cb:	89 d8                	mov    %ebx,%eax
  8013cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013da:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	e8 59 fc ff ff       	call   80103f <fd_lookup>
  8013e6:	83 c4 08             	add    $0x8,%esp
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 10                	js     8013fd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	6a 01                	push   $0x1
  8013f2:	ff 75 fc             	pushl  -0x4(%ebp)
  8013f5:	e8 52 ff ff ff       	call   80134c <fd_close>
  8013fa:	83 c4 10             	add    $0x10,%esp
}
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	6a 00                	push   $0x0
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 4a 03 00 00       	call   80175b <open>
  801411:	89 c6                	mov    %eax,%esi
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 1b                	js     801435 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	50                   	push   %eax
  801421:	e8 e0 fc ff ff       	call   801106 <fstat>
  801426:	89 c3                	mov    %eax,%ebx
	close(fd);
  801428:	89 34 24             	mov    %esi,(%esp)
  80142b:	e8 a4 ff ff ff       	call   8013d4 <close>
  801430:	89 de                	mov    %ebx,%esi
  801432:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801435:	89 f0                	mov    %esi,%eax
  801437:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143a:	5b                   	pop    %ebx
  80143b:	5e                   	pop    %esi
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	57                   	push   %edi
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 1c             	sub    $0x1c,%esp
  801447:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	ff 75 08             	pushl  0x8(%ebp)
  801451:	e8 e9 fb ff ff       	call   80103f <fd_lookup>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	0f 88 bd 00 00 00    	js     801520 <dup+0xe2>
		return r;
	close(newfdnum);
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	57                   	push   %edi
  801467:	e8 68 ff ff ff       	call   8013d4 <close>

	newfd = INDEX2FD(newfdnum);
  80146c:	89 f8                	mov    %edi,%eax
  80146e:	c1 e0 0c             	shl    $0xc,%eax
  801471:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  801477:	ff 75 f0             	pushl  -0x10(%ebp)
  80147a:	e8 55 fb ff ff       	call   800fd4 <fd2data>
  80147f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801481:	89 34 24             	mov    %esi,(%esp)
  801484:	e8 4b fb ff ff       	call   800fd4 <fd2data>
  801489:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	c1 e8 16             	shr    $0x16,%eax
  801491:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801498:	83 c4 14             	add    $0x14,%esp
  80149b:	a8 01                	test   $0x1,%al
  80149d:	74 36                	je     8014d5 <dup+0x97>
  80149f:	89 da                	mov    %ebx,%edx
  8014a1:	c1 ea 0c             	shr    $0xc,%edx
  8014a4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014ab:	a8 01                	test   $0x1,%al
  8014ad:	74 26                	je     8014d5 <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014af:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014be:	50                   	push   %eax
  8014bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	53                   	push   %ebx
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 f3 f9 ff ff       	call   800ebf <sys_page_map>
  8014cc:	89 c3                	mov    %eax,%ebx
  8014ce:	83 c4 20             	add    $0x20,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 30                	js     801505 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d8:	89 d0                	mov    %edx,%eax
  8014da:	c1 e8 0c             	shr    $0xc,%eax
  8014dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e4:	83 ec 0c             	sub    $0xc,%esp
  8014e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ec:	50                   	push   %eax
  8014ed:	56                   	push   %esi
  8014ee:	6a 00                	push   $0x0
  8014f0:	52                   	push   %edx
  8014f1:	6a 00                	push   $0x0
  8014f3:	e8 c7 f9 ff ff       	call   800ebf <sys_page_map>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	83 c4 20             	add    $0x20,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 04                	js     801505 <dup+0xc7>
		goto err;
  801501:	89 fb                	mov    %edi,%ebx
  801503:	eb 1b                	jmp    801520 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	56                   	push   %esi
  801509:	6a 00                	push   $0x0
  80150b:	e8 6d f9 ff ff       	call   800e7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801510:	83 c4 08             	add    $0x8,%esp
  801513:	ff 75 e0             	pushl  -0x20(%ebp)
  801516:	6a 00                	push   $0x0
  801518:	e8 60 f9 ff ff       	call   800e7d <sys_page_unmap>
  80151d:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801520:	89 d8                	mov    %ebx,%eax
  801522:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801536:	83 ec 0c             	sub    $0xc,%esp
  801539:	53                   	push   %ebx
  80153a:	e8 95 fe ff ff       	call   8013d4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80153f:	43                   	inc    %ebx
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	83 fb 20             	cmp    $0x20,%ebx
  801546:	75 ee                	jne    801536 <close_all+0xc>
		close(i);
}
  801548:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    
  80154d:	00 00                	add    %al,(%eax)
	...

00801550 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	89 c3                	mov    %eax,%ebx
  801557:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801559:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801560:	75 12                	jne    801574 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	6a 01                	push   $0x1
  801567:	e8 f4 0b 00 00       	call   802160 <ipc_find_env>
  80156c:	a3 00 50 80 00       	mov    %eax,0x805000
  801571:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801574:	6a 07                	push   $0x7
  801576:	68 00 70 80 00       	push   $0x807000
  80157b:	53                   	push   %ebx
  80157c:	ff 35 00 50 80 00    	pushl  0x805000
  801582:	e8 1e 0c 00 00       	call   8021a5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801587:	83 c4 0c             	add    $0xc,%esp
  80158a:	6a 00                	push   $0x0
  80158c:	56                   	push   %esi
  80158d:	6a 00                	push   $0x0
  80158f:	e8 66 0c 00 00       	call   8021fa <ipc_recv>
}
  801594:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ab:	e8 a0 ff ff ff       	call   801550 <fsipc>
}
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8015be:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8015c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c6:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8015d5:	e8 76 ff ff ff       	call   801550 <fsipc>
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e8:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8015ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8015f7:	e8 54 ff ff ff       	call   801550 <fsipc>
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	53                   	push   %ebx
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801608:	8b 45 08             	mov    0x8(%ebp),%eax
  80160b:	8b 40 0c             	mov    0xc(%eax),%eax
  80160e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801613:	ba 00 00 00 00       	mov    $0x0,%edx
  801618:	b8 05 00 00 00       	mov    $0x5,%eax
  80161d:	e8 2e ff ff ff       	call   801550 <fsipc>
  801622:	85 c0                	test   %eax,%eax
  801624:	78 2c                	js     801652 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	68 00 70 80 00       	push   $0x807000
  80162e:	53                   	push   %ebx
  80162f:	e8 b7 f3 ff ff       	call   8009eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801634:	a1 80 70 80 00       	mov    0x807080,%eax
  801639:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80163f:	a1 84 70 80 00       	mov    0x807084,%eax
  801644:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
  80164f:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  801652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	8b 40 0c             	mov    0xc(%eax),%eax
  801667:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = n;
  80166c:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801672:	53                   	push   %ebx
  801673:	ff 75 0c             	pushl  0xc(%ebp)
  801676:	68 08 70 80 00       	push   $0x807008
  80167b:	e8 d8 f4 ff ff       	call   800b58 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801680:	ba 00 00 00 00       	mov    $0x0,%edx
  801685:	b8 04 00 00 00       	mov    $0x4,%eax
  80168a:	e8 c1 fe ff ff       	call   801550 <fsipc>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 3d                	js     8016d3 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  801696:	39 c3                	cmp    %eax,%ebx
  801698:	73 19                	jae    8016b3 <devfile_write+0x5c>
  80169a:	68 98 2a 80 00       	push   $0x802a98
  80169f:	68 9f 2a 80 00       	push   $0x802a9f
  8016a4:	68 97 00 00 00       	push   $0x97
  8016a9:	68 b4 2a 80 00       	push   $0x802ab4
  8016ae:	e8 45 ed ff ff       	call   8003f8 <_panic>
	assert(r <= PGSIZE);
  8016b3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016b8:	7e 19                	jle    8016d3 <devfile_write+0x7c>
  8016ba:	68 bf 2a 80 00       	push   $0x802abf
  8016bf:	68 9f 2a 80 00       	push   $0x802a9f
  8016c4:	68 98 00 00 00       	push   $0x98
  8016c9:	68 b4 2a 80 00       	push   $0x802ab4
  8016ce:	e8 25 ed ff ff       	call   8003f8 <_panic>
	
	return r;
}
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	56                   	push   %esi
  8016dc:	53                   	push   %ebx
  8016dd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8016eb:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fb:	e8 50 fe ff ff       	call   801550 <fsipc>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	85 c0                	test   %eax,%eax
  801704:	78 4c                	js     801752 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801706:	39 de                	cmp    %ebx,%esi
  801708:	73 16                	jae    801720 <devfile_read+0x48>
  80170a:	68 98 2a 80 00       	push   $0x802a98
  80170f:	68 9f 2a 80 00       	push   $0x802a9f
  801714:	6a 7c                	push   $0x7c
  801716:	68 b4 2a 80 00       	push   $0x802ab4
  80171b:	e8 d8 ec ff ff       	call   8003f8 <_panic>
	assert(r <= PGSIZE);
  801720:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801726:	7e 16                	jle    80173e <devfile_read+0x66>
  801728:	68 bf 2a 80 00       	push   $0x802abf
  80172d:	68 9f 2a 80 00       	push   $0x802a9f
  801732:	6a 7d                	push   $0x7d
  801734:	68 b4 2a 80 00       	push   $0x802ab4
  801739:	e8 ba ec ff ff       	call   8003f8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	50                   	push   %eax
  801742:	68 00 70 80 00       	push   $0x807000
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	e8 09 f4 ff ff       	call   800b58 <memmove>
  80174f:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801752:	89 d8                	mov    %ebx,%eax
  801754:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	83 ec 1c             	sub    $0x1c,%esp
  801763:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801766:	56                   	push   %esi
  801767:	e8 4c f2 ff ff       	call   8009b8 <strlen>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801774:	7e 07                	jle    80177d <open+0x22>
  801776:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80177b:	eb 63                	jmp    8017e0 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801783:	50                   	push   %eax
  801784:	e8 63 f8 ff ff       	call   800fec <fd_alloc>
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 4e                	js     8017e0 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	56                   	push   %esi
  801796:	68 00 70 80 00       	push   $0x807000
  80179b:	e8 4b f2 ff ff       	call   8009eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b0:	e8 9b fd ff ff       	call   801550 <fsipc>
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 c0                	test   %eax,%eax
  8017bc:	79 12                	jns    8017d0 <open+0x75>
		fd_close(fd, 0);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	6a 00                	push   $0x0
  8017c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c6:	e8 81 fb ff ff       	call   80134c <fd_close>
		return r;
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	eb 10                	jmp    8017e0 <open+0x85>
	}

	return fd2num(fd);
  8017d0:	83 ec 0c             	sub    $0xc,%esp
  8017d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d6:	e8 e9 f7 ff ff       	call   800fc4 <fd2num>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	83 c4 10             	add    $0x10,%esp
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	c9                   	leave  
  8017e8:	c3                   	ret    
  8017e9:	00 00                	add    %al,(%eax)
	...

008017ec <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	57                   	push   %edi
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017f8:	6a 00                	push   $0x0
  8017fa:	ff 75 08             	pushl  0x8(%ebp)
  8017fd:	e8 59 ff ff ff       	call   80175b <open>
  801802:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	79 0b                	jns    80181a <spawn+0x2e>
  80180f:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801815:	e9 13 05 00 00       	jmp    801d2d <spawn+0x541>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80181a:	83 ec 04             	sub    $0x4,%esp
  80181d:	68 00 02 00 00       	push   $0x200
  801822:	8d 85 f4 fd ff ff    	lea    -0x20c(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  80182f:	e8 d1 fa ff ff       	call   801305 <readn>
  801834:	83 c4 10             	add    $0x10,%esp
  801837:	3d 00 02 00 00       	cmp    $0x200,%eax
  80183c:	75 0c                	jne    80184a <spawn+0x5e>
  80183e:	81 bd f4 fd ff ff 7f 	cmpl   $0x464c457f,-0x20c(%ebp)
  801845:	45 4c 46 
  801848:	74 38                	je     801882 <spawn+0x96>
	    || elf->e_magic != ELF_MAGIC) {
		close(fd);
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801853:	e8 7c fb ff ff       	call   8013d4 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801858:	83 c4 0c             	add    $0xc,%esp
  80185b:	68 7f 45 4c 46       	push   $0x464c457f
  801860:	ff b5 f4 fd ff ff    	pushl  -0x20c(%ebp)
  801866:	68 cb 2a 80 00       	push   $0x802acb
  80186b:	e8 29 ec ff ff       	call   800499 <cprintf>
  801870:	c7 85 9c fd ff ff f2 	movl   $0xfffffff2,-0x264(%ebp)
  801877:	ff ff ff 
		return -E_NOT_EXEC;
  80187a:	83 c4 10             	add    $0x10,%esp
  80187d:	e9 ab 04 00 00       	jmp    801d2d <spawn+0x541>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801882:	ba 07 00 00 00       	mov    $0x7,%edx
  801887:	89 d0                	mov    %edx,%eax
  801889:	cd 30                	int    $0x30
  80188b:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801891:	85 c0                	test   %eax,%eax
  801893:	0f 88 94 04 00 00    	js     801d2d <spawn+0x541>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801899:	25 ff 03 00 00       	and    $0x3ff,%eax
  80189e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8018a5:	c1 e0 07             	shl    $0x7,%eax
  8018a8:	29 d0                	sub    %edx,%eax
  8018aa:	8d 95 b0 fd ff ff    	lea    -0x250(%ebp),%edx
  8018b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	6a 44                	push   $0x44
  8018ba:	50                   	push   %eax
  8018bb:	52                   	push   %edx
  8018bc:	e8 05 f3 ff ff       	call   800bc6 <memcpy>
	child_tf.tf_eip = elf->e_entry;
  8018c1:	8b 85 0c fe ff ff    	mov    -0x1f4(%ebp),%eax
  8018c7:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  8018cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d2:	be 00 00 00 00       	mov    $0x0,%esi
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	eb 11                	jmp    8018ed <spawn+0x101>

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	50                   	push   %eax
  8018e0:	e8 d3 f0 ff ff       	call   8009b8 <strlen>
  8018e5:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018e9:	46                   	inc    %esi
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	8b 04 b2             	mov    (%edx,%esi,4),%eax
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	75 e5                	jne    8018dc <spawn+0xf0>
  8018f7:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  8018fd:	89 f1                	mov    %esi,%ecx
  8018ff:	c1 e1 02             	shl    $0x2,%ecx
  801902:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801908:	b8 00 10 40 00       	mov    $0x401000,%eax
  80190d:	89 c7                	mov    %eax,%edi
  80190f:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801911:	89 f8                	mov    %edi,%eax
  801913:	83 e0 fc             	and    $0xfffffffc,%eax
  801916:	29 c8                	sub    %ecx,%eax
  801918:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
  80191e:	83 e8 04             	sub    $0x4,%eax
  801921:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801927:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80192d:	83 e8 0c             	sub    $0xc,%eax
  801930:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801935:	0f 86 c1 03 00 00    	jbe    801cfc <spawn+0x510>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	6a 07                	push   $0x7
  801940:	68 00 00 40 00       	push   $0x400000
  801945:	6a 00                	push   $0x0
  801947:	e8 b5 f5 ff ff       	call   800f01 <sys_page_alloc>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	0f 88 aa 03 00 00    	js     801d01 <spawn+0x515>
  801957:	bb 00 00 00 00       	mov    $0x0,%ebx
  80195c:	eb 35                	jmp    801993 <spawn+0x1a7>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80195e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801964:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
  80196a:	89 44 9a fc          	mov    %eax,-0x4(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801974:	ff 34 99             	pushl  (%ecx,%ebx,4)
  801977:	57                   	push   %edi
  801978:	e8 6e f0 ff ff       	call   8009eb <strcpy>
		string_store += strlen(argv[i]) + 1;
  80197d:	83 c4 04             	add    $0x4,%esp
  801980:	8b 45 0c             	mov    0xc(%ebp),%eax
  801983:	ff 34 98             	pushl  (%eax,%ebx,4)
  801986:	e8 2d f0 ff ff       	call   8009b8 <strlen>
  80198b:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80198f:	43                   	inc    %ebx
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	39 f3                	cmp    %esi,%ebx
  801995:	7c c7                	jl     80195e <spawn+0x172>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801997:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80199d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  8019a3:	c7 04 0a 00 00 00 00 	movl   $0x0,(%edx,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8019aa:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8019b0:	74 19                	je     8019cb <spawn+0x1df>
  8019b2:	68 40 2b 80 00       	push   $0x802b40
  8019b7:	68 9f 2a 80 00       	push   $0x802a9f
  8019bc:	68 f2 00 00 00       	push   $0xf2
  8019c1:	68 e5 2a 80 00       	push   $0x802ae5
  8019c6:	e8 2d ea ff ff       	call   8003f8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019cb:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8019d1:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019d6:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  8019dc:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8019df:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
  8019e5:	89 4a f8             	mov    %ecx,-0x8(%edx)

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
  8019e8:	89 d0                	mov    %edx,%eax
  8019ea:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8019ef:	89 85 ec fd ff ff    	mov    %eax,-0x214(%ebp)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	6a 07                	push   $0x7
  8019fa:	68 00 d0 bf ee       	push   $0xeebfd000
  8019ff:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801a05:	68 00 00 40 00       	push   $0x400000
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 ae f4 ff ff       	call   800ebf <sys_page_map>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	83 c4 20             	add    $0x20,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 1c                	js     801a36 <spawn+0x24a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a1a:	83 ec 08             	sub    $0x8,%esp
  801a1d:	68 00 00 40 00       	push   $0x400000
  801a22:	6a 00                	push   $0x0
  801a24:	e8 54 f4 ff ff       	call   800e7d <sys_page_unmap>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	0f 89 d3 02 00 00    	jns    801d09 <spawn+0x51d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	68 00 00 40 00       	push   $0x400000
  801a3e:	6a 00                	push   $0x0
  801a40:	e8 38 f4 ff ff       	call   800e7d <sys_page_unmap>
  801a45:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	e9 da 02 00 00       	jmp    801d2d <spawn+0x541>
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a53:	8b 95 98 fd ff ff    	mov    -0x268(%ebp),%edx
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801a59:	83 7a e0 01          	cmpl   $0x1,-0x20(%edx)
  801a5d:	0f 85 79 01 00 00    	jne    801bdc <spawn+0x3f0>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a63:	8b 42 f8             	mov    -0x8(%edx),%eax
  801a66:	83 e0 02             	and    $0x2,%eax
  801a69:	83 f8 01             	cmp    $0x1,%eax
  801a6c:	19 c0                	sbb    %eax,%eax
  801a6e:	83 e0 fe             	and    $0xfffffffe,%eax
  801a71:	83 c0 07             	add    $0x7,%eax
  801a74:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a7a:	8b 4a e4             	mov    -0x1c(%edx),%ecx
  801a7d:	89 8d 8c fd ff ff    	mov    %ecx,-0x274(%ebp)
  801a83:	8b 42 f0             	mov    -0x10(%edx),%eax
  801a86:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a8c:	8b 4a f4             	mov    -0xc(%edx),%ecx
  801a8f:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
  801a95:	8b 42 e8             	mov    -0x18(%edx),%eax
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801a98:	89 c2                	mov    %eax,%edx
  801a9a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801aa0:	74 16                	je     801ab8 <spawn+0x2cc>
		va -= i;
  801aa2:	29 d0                	sub    %edx,%eax
		memsz += i;
  801aa4:	01 d1                	add    %edx,%ecx
  801aa6:	89 8d 94 fd ff ff    	mov    %ecx,-0x26c(%ebp)
		filesz += i;
  801aac:	01 95 90 fd ff ff    	add    %edx,-0x270(%ebp)
		fileoffset -= i;
  801ab2:	29 95 8c fd ff ff    	sub    %edx,-0x274(%ebp)
  801ab8:	89 c7                	mov    %eax,%edi
  801aba:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801ac1:	00 00 00 
  801ac4:	e9 01 01 00 00       	jmp    801bca <spawn+0x3de>
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
  801ac9:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801acf:	77 27                	ja     801af8 <spawn+0x30c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801ad1:	83 ec 04             	sub    $0x4,%esp
  801ad4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ada:	57                   	push   %edi
  801adb:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801ae1:	e8 1b f4 ff ff       	call   800f01 <sys_page_alloc>
  801ae6:	89 c3                	mov    %eax,%ebx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	0f 89 c7 00 00 00    	jns    801bba <spawn+0x3ce>
  801af3:	e9 dd 01 00 00       	jmp    801cd5 <spawn+0x4e9>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	6a 07                	push   $0x7
  801afd:	68 00 00 40 00       	push   $0x400000
  801b02:	6a 00                	push   $0x0
  801b04:	e8 f8 f3 ff ff       	call   800f01 <sys_page_alloc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	0f 88 bf 01 00 00    	js     801cd5 <spawn+0x4e9>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
  801b1f:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801b22:	50                   	push   %eax
  801b23:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801b29:	e8 58 f5 ff ff       	call   801086 <seek>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	0f 88 9a 01 00 00    	js     801cd5 <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b3b:	83 ec 04             	sub    $0x4,%esp
  801b3e:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b44:	29 f0                	sub    %esi,%eax
  801b46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b4b:	76 05                	jbe    801b52 <spawn+0x366>
  801b4d:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b52:	50                   	push   %eax
  801b53:	68 00 00 40 00       	push   $0x400000
  801b58:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801b5e:	e8 a2 f7 ff ff       	call   801305 <readn>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	0f 88 65 01 00 00    	js     801cd5 <spawn+0x4e9>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b79:	57                   	push   %edi
  801b7a:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801b80:	68 00 00 40 00       	push   $0x400000
  801b85:	6a 00                	push   $0x0
  801b87:	e8 33 f3 ff ff       	call   800ebf <sys_page_map>
  801b8c:	83 c4 20             	add    $0x20,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	79 15                	jns    801ba8 <spawn+0x3bc>
				panic("spawn: sys_page_map data: %e", r);
  801b93:	50                   	push   %eax
  801b94:	68 f1 2a 80 00       	push   $0x802af1
  801b99:	68 25 01 00 00       	push   $0x125
  801b9e:	68 e5 2a 80 00       	push   $0x802ae5
  801ba3:	e8 50 e8 ff ff       	call   8003f8 <_panic>
			sys_page_unmap(0, UTEMP);
  801ba8:	83 ec 08             	sub    $0x8,%esp
  801bab:	68 00 00 40 00       	push   $0x400000
  801bb0:	6a 00                	push   $0x0
  801bb2:	e8 c6 f2 ff ff       	call   800e7d <sys_page_unmap>
  801bb7:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bba:	81 85 88 fd ff ff 00 	addl   $0x1000,-0x278(%ebp)
  801bc1:	10 00 00 
  801bc4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801bca:	8b b5 88 fd ff ff    	mov    -0x278(%ebp),%esi
  801bd0:	39 b5 94 fd ff ff    	cmp    %esi,-0x26c(%ebp)
  801bd6:	0f 87 ed fe ff ff    	ja     801ac9 <spawn+0x2dd>
	if ((r = init_stack(child, argv, ROUNDDOWN(&child_tf.tf_esp, 4))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bdc:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
  801be2:	83 85 98 fd ff ff 20 	addl   $0x20,-0x268(%ebp)
  801be9:	0f b7 85 20 fe ff ff 	movzwl -0x1e0(%ebp),%eax
  801bf0:	39 85 70 fd ff ff    	cmp    %eax,-0x290(%ebp)
  801bf6:	0f 8c 57 fe ff ff    	jl     801a53 <spawn+0x267>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801c05:	e8 ca f7 ff ff       	call   8013d4 <close>
  801c0a:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801c0f:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
		if((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  801c12:	89 d8                	mov    %ebx,%eax
  801c14:	c1 e8 16             	shr    $0x16,%eax
  801c17:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c1e:	a8 01                	test   $0x1,%al
  801c20:	74 3e                	je     801c60 <spawn+0x474>
  801c22:	89 da                	mov    %ebx,%edx
  801c24:	c1 ea 0c             	shr    $0xc,%edx
  801c27:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c2e:	a8 01                	test   $0x1,%al
  801c30:	74 2e                	je     801c60 <spawn+0x474>
  801c32:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c39:	f6 c4 04             	test   $0x4,%ah
  801c3c:	74 22                	je     801c60 <spawn+0x474>
			sys_page_map(0, (void *)addr, child, (void *)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801c3e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	25 07 0e 00 00       	and    $0xe07,%eax
  801c4d:	50                   	push   %eax
  801c4e:	53                   	push   %ebx
  801c4f:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801c55:	53                   	push   %ebx
  801c56:	6a 00                	push   $0x0
  801c58:	e8 62 f2 ff ff       	call   800ebf <sys_page_map>
  801c5d:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uint8_t* addr;	
	for(addr = (uint8_t *)UTEXT; addr <(uint8_t *)UXSTACKTOP; addr += PGSIZE)
  801c60:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c66:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801c6c:	75 a4                	jne    801c12 <spawn+0x426>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801c6e:	81 8d e8 fd ff ff 00 	orl    $0x3000,-0x218(%ebp)
  801c75:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	8d 85 b0 fd ff ff    	lea    -0x250(%ebp),%eax
  801c81:	50                   	push   %eax
  801c82:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801c88:	e8 6c f1 ff ff       	call   800df9 <sys_env_set_trapframe>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	79 15                	jns    801ca9 <spawn+0x4bd>
		panic("sys_env_set_trapframe: %e", r);
  801c94:	50                   	push   %eax
  801c95:	68 0e 2b 80 00       	push   $0x802b0e
  801c9a:	68 86 00 00 00       	push   $0x86
  801c9f:	68 e5 2a 80 00       	push   $0x802ae5
  801ca4:	e8 4f e7 ff ff       	call   8003f8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ca9:	83 ec 08             	sub    $0x8,%esp
  801cac:	6a 02                	push   $0x2
  801cae:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801cb4:	e8 82 f1 ff ff       	call   800e3b <sys_env_set_status>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	79 6d                	jns    801d2d <spawn+0x541>
		panic("sys_env_set_status: %e", r);
  801cc0:	50                   	push   %eax
  801cc1:	68 28 2b 80 00       	push   $0x802b28
  801cc6:	68 89 00 00 00       	push   $0x89
  801ccb:	68 e5 2a 80 00       	push   $0x802ae5
  801cd0:	e8 23 e7 ff ff       	call   8003f8 <_panic>

	return child;

error:
	sys_env_destroy(child);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff b5 9c fd ff ff    	pushl  -0x264(%ebp)
  801cde:	e8 9f f2 ff ff       	call   800f82 <sys_env_destroy>
	close(fd);
  801ce3:	83 c4 04             	add    $0x4,%esp
  801ce6:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
  801cec:	e8 e3 f6 ff ff       	call   8013d4 <close>
  801cf1:	89 9d 9c fd ff ff    	mov    %ebx,-0x264(%ebp)
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	eb 31                	jmp    801d2d <spawn+0x541>
  801cfc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801d01:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
  801d07:	eb 24                	jmp    801d2d <spawn+0x541>
  801d09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0c:	03 85 10 fe ff ff    	add    -0x1f0(%ebp),%eax
  801d12:	8d 80 20 fe ff ff    	lea    -0x1e0(%eax),%eax
  801d18:	89 85 98 fd ff ff    	mov    %eax,-0x268(%ebp)
  801d1e:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
  801d25:	00 00 00 
  801d28:	e9 bc fe ff ff       	jmp    801be9 <spawn+0x3fd>
	return r;
}
  801d2d:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
  801d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d36:	5b                   	pop    %ebx
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	c9                   	leave  
  801d3a:	c3                   	ret    

00801d3b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d3b:	55                   	push   %ebp
  801d3c:	89 e5                	mov    %esp,%ebp
  801d3e:	57                   	push   %edi
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 1c             	sub    $0x1c,%esp
  801d44:	89 e7                	mov    %esp,%edi
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801d46:	8d 45 10             	lea    0x10(%ebp),%eax
  801d49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d4c:	be 00 00 00 00       	mov    $0x0,%esi
  801d51:	eb 01                	jmp    801d54 <spawnl+0x19>
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d53:	46                   	inc    %esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d57:	8d 42 04             	lea    0x4(%edx),%eax
  801d5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d5d:	83 3a 00             	cmpl   $0x0,(%edx)
  801d60:	75 f1                	jne    801d53 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d62:	8d 04 b5 26 00 00 00 	lea    0x26(,%esi,4),%eax
  801d69:	83 e0 f0             	and    $0xfffffff0,%eax
  801d6c:	29 c4                	sub    %eax,%esp
  801d6e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 e3 f0             	and    $0xfffffff0,%ebx
	argv[0] = arg0;
  801d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7a:	89 03                	mov    %eax,(%ebx)
	argv[argc+1] = NULL;
  801d7c:	c7 44 b3 04 00 00 00 	movl   $0x0,0x4(%ebx,%esi,4)
  801d83:	00 

	va_start(vl, arg0);
  801d84:	8d 45 10             	lea    0x10(%ebp),%eax
  801d87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d8f:	eb 0f                	jmp    801da0 <spawnl+0x65>
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
  801d91:	41                   	inc    %ecx
  801d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d95:	8d 50 04             	lea    0x4(%eax),%edx
  801d98:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801d9b:	8b 00                	mov    (%eax),%eax
  801d9d:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801da0:	39 f1                	cmp    %esi,%ecx
  801da2:	75 ed                	jne    801d91 <spawnl+0x56>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801da4:	83 ec 08             	sub    $0x8,%esp
  801da7:	53                   	push   %ebx
  801da8:	ff 75 08             	pushl  0x8(%ebp)
  801dab:	e8 3c fa ff ff       	call   8017ec <spawn>
  801db0:	89 fc                	mov    %edi,%esp
}
  801db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    
	...

00801dbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc4:	83 ec 0c             	sub    $0xc,%esp
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 05 f2 ff ff       	call   800fd4 <fd2data>
  801dcf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801dd1:	83 c4 08             	add    $0x8,%esp
  801dd4:	68 66 2b 80 00       	push   $0x802b66
  801dd9:	53                   	push   %ebx
  801dda:	e8 0c ec ff ff       	call   8009eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ddf:	8b 46 04             	mov    0x4(%esi),%eax
  801de2:	2b 06                	sub    (%esi),%eax
  801de4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801dea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801df1:	00 00 00 
	stat->st_dev = &devpipe;
  801df4:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801dfb:	47 80 00 
	return 0;
}
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801e03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e06:	5b                   	pop    %ebx
  801e07:	5e                   	pop    %esi
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e14:	53                   	push   %ebx
  801e15:	6a 00                	push   $0x0
  801e17:	e8 61 f0 ff ff       	call   800e7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e1c:	89 1c 24             	mov    %ebx,(%esp)
  801e1f:	e8 b0 f1 ff ff       	call   800fd4 <fd2data>
  801e24:	83 c4 08             	add    $0x8,%esp
  801e27:	50                   	push   %eax
  801e28:	6a 00                	push   $0x0
  801e2a:	e8 4e f0 ff ff       	call   800e7d <sys_page_unmap>
}
  801e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	57                   	push   %edi
  801e38:	56                   	push   %esi
  801e39:	53                   	push   %ebx
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801e40:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e42:	a1 90 67 80 00       	mov    0x806790,%eax
  801e47:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e50:	e8 0f 04 00 00       	call   802264 <pageref>
  801e55:	89 c3                	mov    %eax,%ebx
  801e57:	89 3c 24             	mov    %edi,(%esp)
  801e5a:	e8 05 04 00 00       	call   802264 <pageref>
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	39 c3                	cmp    %eax,%ebx
  801e64:	0f 94 c0             	sete   %al
  801e67:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801e6a:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801e70:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801e73:	39 c6                	cmp    %eax,%esi
  801e75:	74 1b                	je     801e92 <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801e77:	83 f9 01             	cmp    $0x1,%ecx
  801e7a:	75 c6                	jne    801e42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e7c:	8b 42 58             	mov    0x58(%edx),%eax
  801e7f:	6a 01                	push   $0x1
  801e81:	50                   	push   %eax
  801e82:	56                   	push   %esi
  801e83:	68 6d 2b 80 00       	push   $0x802b6d
  801e88:	e8 0c e6 ff ff       	call   800499 <cprintf>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	eb b0                	jmp    801e42 <_pipeisclosed+0xe>
	}
}
  801e92:	89 c8                	mov    %ecx,%eax
  801e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	c9                   	leave  
  801e9b:	c3                   	ret    

00801e9c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	57                   	push   %edi
  801ea0:	56                   	push   %esi
  801ea1:	53                   	push   %ebx
  801ea2:	83 ec 18             	sub    $0x18,%esp
  801ea5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ea8:	56                   	push   %esi
  801ea9:	e8 26 f1 ff ff       	call   800fd4 <fd2data>
  801eae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801eb6:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	eb 40                	jmp    801f00 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec5:	eb 40                	jmp    801f07 <devpipe_write+0x6b>
  801ec7:	89 da                	mov    %ebx,%edx
  801ec9:	89 f0                	mov    %esi,%eax
  801ecb:	e8 64 ff ff ff       	call   801e34 <_pipeisclosed>
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	75 ec                	jne    801ec0 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ed4:	e8 6b f0 ff ff       	call   800f44 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ed9:	8b 53 04             	mov    0x4(%ebx),%edx
  801edc:	8b 03                	mov    (%ebx),%eax
  801ede:	83 c0 20             	add    $0x20,%eax
  801ee1:	39 c2                	cmp    %eax,%edx
  801ee3:	73 e2                	jae    801ec7 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee5:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801eeb:	79 05                	jns    801ef2 <devpipe_write+0x56>
  801eed:	4a                   	dec    %edx
  801eee:	83 ca e0             	or     $0xffffffe0,%edx
  801ef1:	42                   	inc    %edx
  801ef2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ef5:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801ef8:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801efc:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eff:	47                   	inc    %edi
  801f00:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f03:	75 d4                	jne    801ed9 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f05:	89 f8                	mov    %edi,%eax
}
  801f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	c9                   	leave  
  801f0e:	c3                   	ret    

00801f0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	57                   	push   %edi
  801f13:	56                   	push   %esi
  801f14:	53                   	push   %ebx
  801f15:	83 ec 18             	sub    $0x18,%esp
  801f18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f1b:	57                   	push   %edi
  801f1c:	e8 b3 f0 ff ff       	call   800fd4 <fd2data>
  801f21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801f29:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801f2e:	83 c4 10             	add    $0x10,%esp
  801f31:	eb 41                	jmp    801f74 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	eb 44                	jmp    801f7b <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3c:	eb 3d                	jmp    801f7b <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f3e:	85 f6                	test   %esi,%esi
  801f40:	75 f1                	jne    801f33 <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f42:	89 da                	mov    %ebx,%edx
  801f44:	89 f8                	mov    %edi,%eax
  801f46:	e8 e9 fe ff ff       	call   801e34 <_pipeisclosed>
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	75 e8                	jne    801f37 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f4f:	e8 f0 ef ff ff       	call   800f44 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f54:	8b 03                	mov    (%ebx),%eax
  801f56:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f59:	74 e3                	je     801f3e <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f5b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f60:	79 05                	jns    801f67 <devpipe_read+0x58>
  801f62:	48                   	dec    %eax
  801f63:	83 c8 e0             	or     $0xffffffe0,%eax
  801f66:	40                   	inc    %eax
  801f67:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f6e:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801f71:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f73:	46                   	inc    %esi
  801f74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f77:	75 db                	jne    801f54 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f79:	89 f0                	mov    %esi,%eax
}
  801f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7e:	5b                   	pop    %ebx
  801f7f:	5e                   	pop    %esi
  801f80:	5f                   	pop    %edi
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f89:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	ff 75 08             	pushl  0x8(%ebp)
  801f90:	e8 aa f0 ff ff       	call   80103f <fd_lookup>
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	78 18                	js     801fb4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	ff 75 fc             	pushl  -0x4(%ebp)
  801fa2:	e8 2d f0 ff ff       	call   800fd4 <fd2data>
  801fa7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fac:	e8 83 fe ff ff       	call   801e34 <_pipeisclosed>
  801fb1:	83 c4 10             	add    $0x10,%esp
}
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	57                   	push   %edi
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 28             	sub    $0x28,%esp
  801fbf:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	e8 21 f0 ff ff       	call   800fec <fd_alloc>
  801fcb:	89 c3                	mov    %eax,%ebx
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	0f 88 24 01 00 00    	js     8020fc <pipe+0x146>
  801fd8:	83 ec 04             	sub    $0x4,%esp
  801fdb:	68 07 04 00 00       	push   $0x407
  801fe0:	ff 75 f0             	pushl  -0x10(%ebp)
  801fe3:	6a 00                	push   $0x0
  801fe5:	e8 17 ef ff ff       	call   800f01 <sys_page_alloc>
  801fea:	89 c3                	mov    %eax,%ebx
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	0f 88 05 01 00 00    	js     8020fc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ff7:	83 ec 0c             	sub    $0xc,%esp
  801ffa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ffd:	50                   	push   %eax
  801ffe:	e8 e9 ef ff ff       	call   800fec <fd_alloc>
  802003:	89 c3                	mov    %eax,%ebx
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	0f 88 dc 00 00 00    	js     8020ec <pipe+0x136>
  802010:	83 ec 04             	sub    $0x4,%esp
  802013:	68 07 04 00 00       	push   $0x407
  802018:	ff 75 ec             	pushl  -0x14(%ebp)
  80201b:	6a 00                	push   $0x0
  80201d:	e8 df ee ff ff       	call   800f01 <sys_page_alloc>
  802022:	89 c3                	mov    %eax,%ebx
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	0f 88 bd 00 00 00    	js     8020ec <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	ff 75 f0             	pushl  -0x10(%ebp)
  802035:	e8 9a ef ff ff       	call   800fd4 <fd2data>
  80203a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203c:	83 c4 0c             	add    $0xc,%esp
  80203f:	68 07 04 00 00       	push   $0x407
  802044:	50                   	push   %eax
  802045:	6a 00                	push   $0x0
  802047:	e8 b5 ee ff ff       	call   800f01 <sys_page_alloc>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	0f 88 83 00 00 00    	js     8020dc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802059:	83 ec 0c             	sub    $0xc,%esp
  80205c:	ff 75 ec             	pushl  -0x14(%ebp)
  80205f:	e8 70 ef ff ff       	call   800fd4 <fd2data>
  802064:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80206b:	50                   	push   %eax
  80206c:	6a 00                	push   $0x0
  80206e:	56                   	push   %esi
  80206f:	6a 00                	push   $0x0
  802071:	e8 49 ee ff ff       	call   800ebf <sys_page_map>
  802076:	89 c3                	mov    %eax,%ebx
  802078:	83 c4 20             	add    $0x20,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	78 4f                	js     8020ce <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80207f:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802085:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802088:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80208a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80208d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802094:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80209a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80209d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80209f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020a2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8020af:	e8 10 ef ff ff       	call   800fc4 <fd2num>
  8020b4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020b6:	83 c4 04             	add    $0x4,%esp
  8020b9:	ff 75 ec             	pushl  -0x14(%ebp)
  8020bc:	e8 03 ef ff ff       	call   800fc4 <fd2num>
  8020c1:	89 47 04             	mov    %eax,0x4(%edi)
  8020c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	eb 2e                	jmp    8020fc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8020ce:	83 ec 08             	sub    $0x8,%esp
  8020d1:	56                   	push   %esi
  8020d2:	6a 00                	push   $0x0
  8020d4:	e8 a4 ed ff ff       	call   800e7d <sys_page_unmap>
  8020d9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020dc:	83 ec 08             	sub    $0x8,%esp
  8020df:	ff 75 ec             	pushl  -0x14(%ebp)
  8020e2:	6a 00                	push   $0x0
  8020e4:	e8 94 ed ff ff       	call   800e7d <sys_page_unmap>
  8020e9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020ec:	83 ec 08             	sub    $0x8,%esp
  8020ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f2:	6a 00                	push   $0x0
  8020f4:	e8 84 ed ff ff       	call   800e7d <sys_page_unmap>
  8020f9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5f                   	pop    %edi
  802104:	c9                   	leave  
  802105:	c3                   	ret    
	...

00802108 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802110:	85 f6                	test   %esi,%esi
  802112:	75 16                	jne    80212a <wait+0x22>
  802114:	68 85 2b 80 00       	push   $0x802b85
  802119:	68 9f 2a 80 00       	push   $0x802a9f
  80211e:	6a 09                	push   $0x9
  802120:	68 90 2b 80 00       	push   $0x802b90
  802125:	e8 ce e2 ff ff       	call   8003f8 <_panic>
	e = &envs[ENVX(envid)];
  80212a:	89 f0                	mov    %esi,%eax
  80212c:	25 ff 03 00 00       	and    $0x3ff,%eax
  802131:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802138:	c1 e0 07             	shl    $0x7,%eax
  80213b:	29 d0                	sub    %edx,%eax
  80213d:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
  802143:	eb 05                	jmp    80214a <wait+0x42>
	while (e->env_id == envid && e->env_status != ENV_FREE)
		sys_yield();
  802145:	e8 fa ed ff ff       	call   800f44 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80214a:	8b 43 48             	mov    0x48(%ebx),%eax
  80214d:	39 c6                	cmp    %eax,%esi
  80214f:	75 07                	jne    802158 <wait+0x50>
  802151:	8b 43 54             	mov    0x54(%ebx),%eax
  802154:	85 c0                	test   %eax,%eax
  802156:	75 ed                	jne    802145 <wait+0x3d>
		sys_yield();
}
  802158:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	c9                   	leave  
  80215e:	c3                   	ret    
	...

00802160 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	53                   	push   %ebx
  802164:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802167:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80216c:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  802173:	89 c8                	mov    %ecx,%eax
  802175:	c1 e0 07             	shl    $0x7,%eax
  802178:	29 d0                	sub    %edx,%eax
  80217a:	89 c2                	mov    %eax,%edx
  80217c:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  802182:	8b 40 50             	mov    0x50(%eax),%eax
  802185:	39 d8                	cmp    %ebx,%eax
  802187:	75 0b                	jne    802194 <ipc_find_env+0x34>
			return envs[i].env_id;
  802189:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  80218f:	8b 40 40             	mov    0x40(%eax),%eax
  802192:	eb 0e                	jmp    8021a2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802194:	41                   	inc    %ecx
  802195:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  80219b:	75 cf                	jne    80216c <ipc_find_env+0xc>
  80219d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8021a2:	5b                   	pop    %ebx
  8021a3:	c9                   	leave  
  8021a4:	c3                   	ret    

008021a5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	57                   	push   %edi
  8021a9:	56                   	push   %esi
  8021aa:	53                   	push   %ebx
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021b4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8021b7:	85 db                	test   %ebx,%ebx
  8021b9:	75 05                	jne    8021c0 <ipc_send+0x1b>
  8021bb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	57                   	push   %edi
  8021c3:	ff 75 08             	pushl  0x8(%ebp)
  8021c6:	e8 c9 eb ff ff       	call   800d94 <sys_ipc_try_send>
		if (r == 0) {		//success
  8021cb:	83 c4 10             	add    $0x10,%esp
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	74 20                	je     8021f2 <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  8021d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021d5:	75 07                	jne    8021de <ipc_send+0x39>
			sys_yield();
  8021d7:	e8 68 ed ff ff       	call   800f44 <sys_yield>
  8021dc:	eb e2                	jmp    8021c0 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  8021de:	83 ec 04             	sub    $0x4,%esp
  8021e1:	68 9c 2b 80 00       	push   $0x802b9c
  8021e6:	6a 41                	push   $0x41
  8021e8:	68 c0 2b 80 00       	push   $0x802bc0
  8021ed:	e8 06 e2 ff ff       	call   8003f8 <_panic>
		}
	}
}
  8021f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	56                   	push   %esi
  8021fe:	53                   	push   %ebx
  8021ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802202:	8b 45 0c             	mov    0xc(%ebp),%eax
  802205:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802208:	85 c0                	test   %eax,%eax
  80220a:	75 05                	jne    802211 <ipc_recv+0x17>
  80220c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  802211:	83 ec 0c             	sub    $0xc,%esp
  802214:	50                   	push   %eax
  802215:	e8 39 eb ff ff       	call   800d53 <sys_ipc_recv>
	if (r < 0) {				
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	85 c0                	test   %eax,%eax
  80221f:	79 16                	jns    802237 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  802221:	85 db                	test   %ebx,%ebx
  802223:	74 06                	je     80222b <ipc_recv+0x31>
  802225:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  80222b:	85 f6                	test   %esi,%esi
  80222d:	74 2c                	je     80225b <ipc_recv+0x61>
  80222f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802235:	eb 24                	jmp    80225b <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  802237:	85 db                	test   %ebx,%ebx
  802239:	74 0a                	je     802245 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  80223b:	a1 90 67 80 00       	mov    0x806790,%eax
  802240:	8b 40 74             	mov    0x74(%eax),%eax
  802243:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  802245:	85 f6                	test   %esi,%esi
  802247:	74 0a                	je     802253 <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  802249:	a1 90 67 80 00       	mov    0x806790,%eax
  80224e:	8b 40 78             	mov    0x78(%eax),%eax
  802251:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  802253:	a1 90 67 80 00       	mov    0x806790,%eax
  802258:	8b 40 70             	mov    0x70(%eax),%eax
}
  80225b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	c9                   	leave  
  802261:	c3                   	ret    
	...

00802264 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	c1 e8 16             	shr    $0x16,%eax
  80226f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802276:	a8 01                	test   $0x1,%al
  802278:	74 20                	je     80229a <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	c1 e8 0c             	shr    $0xc,%eax
  80227f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802286:	a8 01                	test   $0x1,%al
  802288:	74 10                	je     80229a <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80228a:	c1 e8 0c             	shr    $0xc,%eax
  80228d:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802294:	ef 
  802295:	0f b7 c0             	movzwl %ax,%eax
  802298:	eb 05                	jmp    80229f <pageref+0x3b>
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    
  8022a1:	00 00                	add    %al,(%eax)
	...

008022a4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	57                   	push   %edi
  8022a8:	56                   	push   %esi
  8022a9:	83 ec 28             	sub    $0x28,%esp
  8022ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8022b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8022ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8022bd:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8022c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8022c3:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8022c5:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  8022c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  8022cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022d0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022d3:	85 ff                	test   %edi,%edi
  8022d5:	75 21                	jne    8022f8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  8022d7:	39 d1                	cmp    %edx,%ecx
  8022d9:	76 49                	jbe    802324 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022db:	f7 f1                	div    %ecx
  8022dd:	89 c1                	mov    %eax,%ecx
  8022df:	31 c0                	xor    %eax,%eax
  8022e1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022e4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8022e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8022ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8022f0:	83 c4 28             	add    $0x28,%esp
  8022f3:	5e                   	pop    %esi
  8022f4:	5f                   	pop    %edi
  8022f5:	c9                   	leave  
  8022f6:	c3                   	ret    
  8022f7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022f8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8022fb:	0f 87 97 00 00 00    	ja     802398 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802301:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802304:	83 f0 1f             	xor    $0x1f,%eax
  802307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80230a:	75 34                	jne    802340 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80230c:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80230f:	72 08                	jb     802319 <__udivdi3+0x75>
  802311:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802314:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802317:	77 7f                	ja     802398 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802319:	b9 01 00 00 00       	mov    $0x1,%ecx
  80231e:	31 c0                	xor    %eax,%eax
  802320:	eb c2                	jmp    8022e4 <__udivdi3+0x40>
  802322:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802324:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802327:	85 c0                	test   %eax,%eax
  802329:	74 79                	je     8023a4 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80232b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80232e:	89 fa                	mov    %edi,%edx
  802330:	f7 f1                	div    %ecx
  802332:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802334:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802337:	f7 f1                	div    %ecx
  802339:	89 c1                	mov    %eax,%ecx
  80233b:	89 f0                	mov    %esi,%eax
  80233d:	eb a5                	jmp    8022e4 <__udivdi3+0x40>
  80233f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802340:	b8 20 00 00 00       	mov    $0x20,%eax
  802345:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802348:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80234b:	89 fa                	mov    %edi,%edx
  80234d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802350:	d3 e2                	shl    %cl,%edx
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802358:	d3 e8                	shr    %cl,%eax
  80235a:	89 d7                	mov    %edx,%edi
  80235c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80235e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802361:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802364:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802366:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802369:	d3 e0                	shl    %cl,%eax
  80236b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80236e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802371:	d3 ea                	shr    %cl,%edx
  802373:	09 d0                	or     %edx,%eax
  802375:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802378:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	f7 f7                	div    %edi
  80237f:	89 d7                	mov    %edx,%edi
  802381:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802384:	f7 e6                	mul    %esi
  802386:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802388:	39 d7                	cmp    %edx,%edi
  80238a:	72 38                	jb     8023c4 <__udivdi3+0x120>
  80238c:	74 27                	je     8023b5 <__udivdi3+0x111>
  80238e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802391:	31 c0                	xor    %eax,%eax
  802393:	e9 4c ff ff ff       	jmp    8022e4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802398:	31 c9                	xor    %ecx,%ecx
  80239a:	31 c0                	xor    %eax,%eax
  80239c:	e9 43 ff ff ff       	jmp    8022e4 <__udivdi3+0x40>
  8023a1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a9:	31 d2                	xor    %edx,%edx
  8023ab:	f7 75 f4             	divl   -0xc(%ebp)
  8023ae:	89 c1                	mov    %eax,%ecx
  8023b0:	e9 76 ff ff ff       	jmp    80232b <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8023b8:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8023bb:	d3 e0                	shl    %cl,%eax
  8023bd:	39 f0                	cmp    %esi,%eax
  8023bf:	73 cd                	jae    80238e <__udivdi3+0xea>
  8023c1:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8023c7:	49                   	dec    %ecx
  8023c8:	31 c0                	xor    %eax,%eax
  8023ca:	e9 15 ff ff ff       	jmp    8022e4 <__udivdi3+0x40>
	...

008023d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	57                   	push   %edi
  8023d4:	56                   	push   %esi
  8023d5:	83 ec 30             	sub    $0x30,%esp
  8023d8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8023df:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8023e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8023e9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8023ef:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8023f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023f5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8023f7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8023fa:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8023fd:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802400:	85 d2                	test   %edx,%edx
  802402:	75 1c                	jne    802420 <__umoddi3+0x50>
    {
      if (d0 > n1)
  802404:	89 fa                	mov    %edi,%edx
  802406:	39 f8                	cmp    %edi,%eax
  802408:	0f 86 c2 00 00 00    	jbe    8024d0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80240e:	89 f0                	mov    %esi,%eax
  802410:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  802412:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  802415:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80241c:	eb 12                	jmp    802430 <__umoddi3+0x60>
  80241e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802420:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802423:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  802426:	76 18                	jbe    802440 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  802428:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  80242b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80242e:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802430:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802433:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802436:	83 c4 30             	add    $0x30,%esp
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	c9                   	leave  
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802440:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  802444:	83 f0 1f             	xor    $0x1f,%eax
  802447:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80244a:	0f 84 ac 00 00 00    	je     8024fc <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802450:	b8 20 00 00 00       	mov    $0x20,%eax
  802455:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802458:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80245b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80245e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802461:	d3 e2                	shl    %cl,%edx
  802463:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802466:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802469:	d3 e8                	shr    %cl,%eax
  80246b:	89 d6                	mov    %edx,%esi
  80246d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80246f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802472:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802475:	d3 e0                	shl    %cl,%eax
  802477:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80247a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  80247d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80247f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802482:	d3 e0                	shl    %cl,%eax
  802484:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802487:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80248a:	d3 ea                	shr    %cl,%edx
  80248c:	09 d0                	or     %edx,%eax
  80248e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802491:	d3 ea                	shr    %cl,%edx
  802493:	f7 f6                	div    %esi
  802495:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802498:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80249b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80249e:	0f 82 8d 00 00 00    	jb     802531 <__umoddi3+0x161>
  8024a4:	0f 84 91 00 00 00    	je     80253b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024aa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8024ad:	29 c7                	sub    %eax,%edi
  8024af:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024b1:	89 f2                	mov    %esi,%edx
  8024b3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8024b6:	d3 e2                	shl    %cl,%edx
  8024b8:	89 f8                	mov    %edi,%eax
  8024ba:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8024bd:	d3 e8                	shr    %cl,%eax
  8024bf:	09 c2                	or     %eax,%edx
  8024c1:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  8024c4:	d3 ee                	shr    %cl,%esi
  8024c6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8024c9:	e9 62 ff ff ff       	jmp    802430 <__umoddi3+0x60>
  8024ce:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8024d3:	85 c0                	test   %eax,%eax
  8024d5:	74 15                	je     8024ec <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024da:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8024dd:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e2:	f7 f1                	div    %ecx
  8024e4:	e9 29 ff ff ff       	jmp    802412 <__umoddi3+0x42>
  8024e9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	f7 75 ec             	divl   -0x14(%ebp)
  8024f6:	89 c1                	mov    %eax,%ecx
  8024f8:	eb dd                	jmp    8024d7 <__umoddi3+0x107>
  8024fa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024ff:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  802502:	72 19                	jb     80251d <__umoddi3+0x14d>
  802504:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802507:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  80250a:	76 11                	jbe    80251d <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  80250c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80250f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  802512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802515:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  802518:	e9 13 ff ff ff       	jmp    802430 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80251d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802520:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802523:	2b 45 ec             	sub    -0x14(%ebp),%eax
  802526:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  802529:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80252c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80252f:	eb db                	jmp    80250c <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802531:	2b 45 cc             	sub    -0x34(%ebp),%eax
  802534:	19 f2                	sbb    %esi,%edx
  802536:	e9 6f ff ff ff       	jmp    8024aa <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80253b:	39 c7                	cmp    %eax,%edi
  80253d:	72 f2                	jb     802531 <__umoddi3+0x161>
  80253f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802542:	e9 63 ff ff ff       	jmp    8024aa <__umoddi3+0xda>
