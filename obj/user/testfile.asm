
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 c7 05 00 00       	call   8005f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	50                   	push   %eax
  80003e:	68 00 50 80 00       	push   $0x805000
  800043:	e8 07 0c 00 00       	call   800c4f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800048:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800055:	e8 ce 11 00 00       	call   801228 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005a:	6a 07                	push   $0x7
  80005c:	68 00 50 80 00       	push   $0x805000
  800061:	6a 01                	push   $0x1
  800063:	50                   	push   %eax
  800064:	e8 04 12 00 00       	call   80126d <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800069:	83 c4 1c             	add    $0x1c,%esp
  80006c:	6a 00                	push   $0x0
  80006e:	68 00 c0 cc cc       	push   $0xccccc000
  800073:	6a 00                	push   $0x0
  800075:	e8 48 12 00 00       	call   8012c2 <ipc_recv>
}
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <umain>:

void
umain(int argc, char **argv)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008b:	ba 00 00 00 00       	mov    $0x0,%edx
  800090:	b8 00 23 80 00       	mov    $0x802300,%eax
  800095:	e8 9a ff ff ff       	call   800034 <xopen>
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 17                	jns    8000b5 <umain+0x36>
  80009e:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a1:	74 26                	je     8000c9 <umain+0x4a>
		panic("serve_open /not-found: %e", r);
  8000a3:	50                   	push   %eax
  8000a4:	68 0b 23 80 00       	push   $0x80230b
  8000a9:	6a 20                	push   $0x20
  8000ab:	68 25 23 80 00       	push   $0x802325
  8000b0:	e8 a7 05 00 00       	call   80065c <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	68 c0 24 80 00       	push   $0x8024c0
  8000bd:	6a 22                	push   $0x22
  8000bf:	68 25 23 80 00       	push   $0x802325
  8000c4:	e8 93 05 00 00       	call   80065c <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 35 23 80 00       	mov    $0x802335,%eax
  8000d3:	e8 5c ff ff ff       	call   800034 <xopen>
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	79 12                	jns    8000ee <umain+0x6f>
		panic("serve_open /newmotd: %e", r);
  8000dc:	50                   	push   %eax
  8000dd:	68 3e 23 80 00       	push   $0x80233e
  8000e2:	6a 25                	push   $0x25
  8000e4:	68 25 23 80 00       	push   $0x802325
  8000e9:	e8 6e 05 00 00       	call   80065c <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000ee:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000f5:	75 12                	jne    800109 <umain+0x8a>
  8000f7:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000fe:	75 09                	jne    800109 <umain+0x8a>
  800100:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800107:	74 14                	je     80011d <umain+0x9e>
		panic("serve_open did not fill struct Fd correctly\n");
  800109:	83 ec 04             	sub    $0x4,%esp
  80010c:	68 e4 24 80 00       	push   $0x8024e4
  800111:	6a 27                	push   $0x27
  800113:	68 25 23 80 00       	push   $0x802325
  800118:	e8 3f 05 00 00       	call   80065c <_panic>
	cprintf("serve_open is good\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 56 23 80 00       	push   $0x802356
  800125:	e8 d3 05 00 00       	call   8006fd <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  80012a:	83 c4 08             	add    $0x8,%esp
  80012d:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	68 00 c0 cc cc       	push   $0xccccc000
  800139:	ff 15 1c 30 80 00    	call   *0x80301c
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	85 c0                	test   %eax,%eax
  800144:	79 12                	jns    800158 <umain+0xd9>
		panic("file_stat: %e", r);
  800146:	50                   	push   %eax
  800147:	68 6a 23 80 00       	push   $0x80236a
  80014c:	6a 2b                	push   $0x2b
  80014e:	68 25 23 80 00       	push   $0x802325
  800153:	e8 04 05 00 00       	call   80065c <_panic>
	if (strlen(msg) != st.st_size)
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 35 00 30 80 00    	pushl  0x803000
  800161:	e8 b6 0a 00 00       	call   800c1c <strlen>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80016c:	74 25                	je     800193 <umain+0x114>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	ff 35 00 30 80 00    	pushl  0x803000
  800177:	e8 a0 0a 00 00       	call   800c1c <strlen>
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	ff 75 d8             	pushl  -0x28(%ebp)
  800182:	68 14 25 80 00       	push   $0x802514
  800187:	6a 2d                	push   $0x2d
  800189:	68 25 23 80 00       	push   $0x802325
  80018e:	e8 c9 04 00 00       	call   80065c <_panic>
	cprintf("file_stat is good\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 78 23 80 00       	push   $0x802378
  80019b:	e8 5d 05 00 00       	call   8006fd <cprintf>

	memset(buf, 0, sizeof buf);
  8001a0:	83 c4 0c             	add    $0xc,%esp
  8001a3:	68 00 02 00 00       	push   $0x200
  8001a8:	6a 00                	push   $0x0
  8001aa:	8d 9d 58 fd ff ff    	lea    -0x2a8(%ebp),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	e8 b6 0b 00 00       	call   800d6c <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001b6:	83 c4 0c             	add    $0xc,%esp
  8001b9:	68 00 02 00 00       	push   $0x200
  8001be:	53                   	push   %ebx
  8001bf:	68 00 c0 cc cc       	push   $0xccccc000
  8001c4:	ff 15 10 30 80 00    	call   *0x803010
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	85 c0                	test   %eax,%eax
  8001cf:	79 12                	jns    8001e3 <umain+0x164>
		panic("file_read: %e", r);
  8001d1:	50                   	push   %eax
  8001d2:	68 8b 23 80 00       	push   $0x80238b
  8001d7:	6a 32                	push   $0x32
  8001d9:	68 25 23 80 00       	push   $0x802325
  8001de:	e8 79 04 00 00       	call   80065c <_panic>
	if (strcmp(buf, msg) != 0)
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	ff 35 00 30 80 00    	pushl  0x803000
  8001ec:	8d 85 58 fd ff ff    	lea    -0x2a8(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 ea 0a 00 00       	call   800ce2 <strcmp>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	74 14                	je     800213 <umain+0x194>
		panic("file_read returned wrong data");
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	68 99 23 80 00       	push   $0x802399
  800207:	6a 34                	push   $0x34
  800209:	68 25 23 80 00       	push   $0x802325
  80020e:	e8 49 04 00 00       	call   80065c <_panic>
	cprintf("file_read is good\n");
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	68 b7 23 80 00       	push   $0x8023b7
  80021b:	e8 dd 04 00 00       	call   8006fd <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800220:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800227:	ff 15 18 30 80 00    	call   *0x803018
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	85 c0                	test   %eax,%eax
  800232:	79 12                	jns    800246 <umain+0x1c7>
		panic("file_close: %e", r);
  800234:	50                   	push   %eax
  800235:	68 ca 23 80 00       	push   $0x8023ca
  80023a:	6a 38                	push   $0x38
  80023c:	68 25 23 80 00       	push   $0x802325
  800241:	e8 16 04 00 00       	call   80065c <_panic>
	cprintf("file_close is good\n");
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	68 d9 23 80 00       	push   $0x8023d9
  80024e:	e8 aa 04 00 00       	call   8006fd <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  800253:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  800258:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80025b:	fc                   	cld    
  80025c:	a5                   	movsl  %ds:(%esi),%es:(%edi)
  80025d:	a5                   	movsl  %ds:(%esi),%es:(%edi)
  80025e:	a5                   	movsl  %ds:(%esi),%es:(%edi)
  80025f:	a5                   	movsl  %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  800260:	83 c4 08             	add    $0x8,%esp
  800263:	68 00 c0 cc cc       	push   $0xccccc000
  800268:	6a 00                	push   $0x0
  80026a:	e8 72 0e 00 00       	call   8010e1 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80026f:	83 c4 0c             	add    $0xc,%esp
  800272:	68 00 02 00 00       	push   $0x200
  800277:	8d 85 58 fd ff ff    	lea    -0x2a8(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800281:	50                   	push   %eax
  800282:	ff 15 10 30 80 00    	call   *0x803010
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80028e:	74 12                	je     8002a2 <umain+0x223>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800290:	50                   	push   %eax
  800291:	68 3c 25 80 00       	push   $0x80253c
  800296:	6a 43                	push   $0x43
  800298:	68 25 23 80 00       	push   $0x802325
  80029d:	e8 ba 03 00 00       	call   80065c <_panic>
	cprintf("stale fileid is good\n");
  8002a2:	83 ec 0c             	sub    $0xc,%esp
  8002a5:	68 ed 23 80 00       	push   $0x8023ed
  8002aa:	e8 4e 04 00 00       	call   8006fd <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002af:	ba 02 01 00 00       	mov    $0x102,%edx
  8002b4:	b8 03 24 80 00       	mov    $0x802403,%eax
  8002b9:	e8 76 fd ff ff       	call   800034 <xopen>
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	79 12                	jns    8002d7 <umain+0x258>
		panic("serve_open /new-file: %e", r);
  8002c5:	50                   	push   %eax
  8002c6:	68 0d 24 80 00       	push   $0x80240d
  8002cb:	6a 48                	push   $0x48
  8002cd:	68 25 23 80 00       	push   $0x802325
  8002d2:	e8 85 03 00 00       	call   80065c <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002d7:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	ff 35 00 30 80 00    	pushl  0x803000
  8002e6:	e8 31 09 00 00       	call   800c1c <strlen>
  8002eb:	83 c4 0c             	add    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	ff 35 00 30 80 00    	pushl  0x803000
  8002f5:	68 00 c0 cc cc       	push   $0xccccc000
  8002fa:	ff d3                	call   *%ebx
  8002fc:	89 c3                	mov    %eax,%ebx
  8002fe:	83 c4 04             	add    $0x4,%esp
  800301:	ff 35 00 30 80 00    	pushl  0x803000
  800307:	e8 10 09 00 00       	call   800c1c <strlen>
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	39 c3                	cmp    %eax,%ebx
  800311:	74 12                	je     800325 <umain+0x2a6>
		panic("file_write: %e", r);
  800313:	53                   	push   %ebx
  800314:	68 26 24 80 00       	push   $0x802426
  800319:	6a 4b                	push   $0x4b
  80031b:	68 25 23 80 00       	push   $0x802325
  800320:	e8 37 03 00 00       	call   80065c <_panic>
	cprintf("file_write is good\n");
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	68 35 24 80 00       	push   $0x802435
  80032d:	e8 cb 03 00 00       	call   8006fd <cprintf>

	FVA->fd_offset = 0;
  800332:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800339:	00 00 00 
	memset(buf, 0, sizeof buf);
  80033c:	83 c4 0c             	add    $0xc,%esp
  80033f:	68 00 02 00 00       	push   $0x200
  800344:	6a 00                	push   $0x0
  800346:	8d 9d 58 fd ff ff    	lea    -0x2a8(%ebp),%ebx
  80034c:	53                   	push   %ebx
  80034d:	e8 1a 0a 00 00       	call   800d6c <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800352:	83 c4 0c             	add    $0xc,%esp
  800355:	68 00 02 00 00       	push   $0x200
  80035a:	53                   	push   %ebx
  80035b:	68 00 c0 cc cc       	push   $0xccccc000
  800360:	ff 15 10 30 80 00    	call   *0x803010
  800366:	89 c3                	mov    %eax,%ebx
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	85 c0                	test   %eax,%eax
  80036d:	79 12                	jns    800381 <umain+0x302>
		panic("file_read after file_write: %e", r);
  80036f:	50                   	push   %eax
  800370:	68 74 25 80 00       	push   $0x802574
  800375:	6a 51                	push   $0x51
  800377:	68 25 23 80 00       	push   $0x802325
  80037c:	e8 db 02 00 00       	call   80065c <_panic>
	if (r != strlen(msg))
  800381:	83 ec 0c             	sub    $0xc,%esp
  800384:	ff 35 00 30 80 00    	pushl  0x803000
  80038a:	e8 8d 08 00 00       	call   800c1c <strlen>
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	39 c3                	cmp    %eax,%ebx
  800394:	74 12                	je     8003a8 <umain+0x329>
		panic("file_read after file_write returned wrong length: %d", r);
  800396:	53                   	push   %ebx
  800397:	68 94 25 80 00       	push   $0x802594
  80039c:	6a 53                	push   $0x53
  80039e:	68 25 23 80 00       	push   $0x802325
  8003a3:	e8 b4 02 00 00       	call   80065c <_panic>
	if (strcmp(buf, msg) != 0)
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	ff 35 00 30 80 00    	pushl  0x803000
  8003b1:	8d 85 58 fd ff ff    	lea    -0x2a8(%ebp),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 25 09 00 00       	call   800ce2 <strcmp>
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	74 14                	je     8003d8 <umain+0x359>
		panic("file_read after file_write returned wrong data");
  8003c4:	83 ec 04             	sub    $0x4,%esp
  8003c7:	68 cc 25 80 00       	push   $0x8025cc
  8003cc:	6a 55                	push   $0x55
  8003ce:	68 25 23 80 00       	push   $0x802325
  8003d3:	e8 84 02 00 00       	call   80065c <_panic>
	cprintf("file_read after file_write is good\n");
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	68 fc 25 80 00       	push   $0x8025fc
  8003e0:	e8 18 03 00 00       	call   8006fd <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e5:	83 c4 08             	add    $0x8,%esp
  8003e8:	6a 00                	push   $0x0
  8003ea:	68 00 23 80 00       	push   $0x802300
  8003ef:	e8 cf 16 00 00       	call   801ac3 <open>
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	79 17                	jns    800412 <umain+0x393>
  8003fb:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8003fe:	74 26                	je     800426 <umain+0x3a7>
		panic("open /not-found: %e", r);
  800400:	50                   	push   %eax
  800401:	68 11 23 80 00       	push   $0x802311
  800406:	6a 5a                	push   $0x5a
  800408:	68 25 23 80 00       	push   $0x802325
  80040d:	e8 4a 02 00 00       	call   80065c <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800412:	83 ec 04             	sub    $0x4,%esp
  800415:	68 49 24 80 00       	push   $0x802449
  80041a:	6a 5c                	push   $0x5c
  80041c:	68 25 23 80 00       	push   $0x802325
  800421:	e8 36 02 00 00       	call   80065c <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	6a 00                	push   $0x0
  80042b:	68 35 23 80 00       	push   $0x802335
  800430:	e8 8e 16 00 00       	call   801ac3 <open>
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	85 c0                	test   %eax,%eax
  80043a:	79 12                	jns    80044e <umain+0x3cf>
		panic("open /newmotd: %e", r);
  80043c:	50                   	push   %eax
  80043d:	68 44 23 80 00       	push   $0x802344
  800442:	6a 5f                	push   $0x5f
  800444:	68 25 23 80 00       	push   $0x802325
  800449:	e8 0e 02 00 00       	call   80065c <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80044e:	c1 e0 0c             	shl    $0xc,%eax
  800451:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800457:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80045e:	75 0c                	jne    80046c <umain+0x3ed>
  800460:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
  800464:	75 06                	jne    80046c <umain+0x3ed>
  800466:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
  80046a:	74 14                	je     800480 <umain+0x401>
		panic("open did not fill struct Fd correctly\n");
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	68 20 26 80 00       	push   $0x802620
  800474:	6a 62                	push   $0x62
  800476:	68 25 23 80 00       	push   $0x802325
  80047b:	e8 dc 01 00 00       	call   80065c <_panic>
	cprintf("open is good\n");
  800480:	83 ec 0c             	sub    $0xc,%esp
  800483:	68 5c 23 80 00       	push   $0x80235c
  800488:	e8 70 02 00 00       	call   8006fd <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048d:	83 c4 08             	add    $0x8,%esp
  800490:	68 01 01 00 00       	push   $0x101
  800495:	68 64 24 80 00       	push   $0x802464
  80049a:	e8 24 16 00 00       	call   801ac3 <open>
  80049f:	89 c6                	mov    %eax,%esi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	79 12                	jns    8004ba <umain+0x43b>
		panic("creat /big: %e", f);
  8004a8:	50                   	push   %eax
  8004a9:	68 69 24 80 00       	push   $0x802469
  8004ae:	6a 67                	push   $0x67
  8004b0:	68 25 23 80 00       	push   $0x802325
  8004b5:	e8 a2 01 00 00       	call   80065c <_panic>
	memset(buf, 0, sizeof(buf));
  8004ba:	83 ec 04             	sub    $0x4,%esp
  8004bd:	68 00 02 00 00       	push   $0x200
  8004c2:	6a 00                	push   $0x0
  8004c4:	8d 85 58 fd ff ff    	lea    -0x2a8(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 9c 08 00 00       	call   800d6c <memset>
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8d bd 58 fd ff ff    	lea    -0x2a8(%ebp),%edi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8004de:	89 9d 58 fd ff ff    	mov    %ebx,-0x2a8(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004e4:	83 ec 04             	sub    $0x4,%esp
  8004e7:	68 00 02 00 00       	push   $0x200
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	e8 71 10 00 00       	call   801564 <write>
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	79 16                	jns    800510 <umain+0x491>
			panic("write /big@%d: %e", i, r);
  8004fa:	83 ec 0c             	sub    $0xc,%esp
  8004fd:	50                   	push   %eax
  8004fe:	53                   	push   %ebx
  8004ff:	68 78 24 80 00       	push   $0x802478
  800504:	6a 6c                	push   $0x6c
  800506:	68 25 23 80 00       	push   $0x802325
  80050b:	e8 4c 01 00 00       	call   80065c <_panic>
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
{
  800510:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  800516:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800518:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80051d:	75 bf                	jne    8004de <umain+0x45f>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	56                   	push   %esi
  800523:	e8 14 12 00 00       	call   80173c <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800528:	83 c4 08             	add    $0x8,%esp
  80052b:	6a 00                	push   $0x0
  80052d:	68 64 24 80 00       	push   $0x802464
  800532:	e8 8c 15 00 00       	call   801ac3 <open>
  800537:	89 c6                	mov    %eax,%esi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	79 12                	jns    800552 <umain+0x4d3>
		panic("open /big: %e", f);
  800540:	50                   	push   %eax
  800541:	68 8a 24 80 00       	push   $0x80248a
  800546:	6a 71                	push   $0x71
  800548:	68 25 23 80 00       	push   $0x802325
  80054d:	e8 0a 01 00 00       	call   80065c <_panic>
  800552:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800557:	89 1f                	mov    %ebx,(%edi)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800559:	83 ec 04             	sub    $0x4,%esp
  80055c:	68 00 02 00 00       	push   $0x200
  800561:	8d 85 58 fd ff ff    	lea    -0x2a8(%ebp),%eax
  800567:	50                   	push   %eax
  800568:	56                   	push   %esi
  800569:	e8 ff 10 00 00       	call   80166d <readn>
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	79 16                	jns    80058b <umain+0x50c>
			panic("read /big@%d: %e", i, r);
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	50                   	push   %eax
  800579:	53                   	push   %ebx
  80057a:	68 98 24 80 00       	push   $0x802498
  80057f:	6a 75                	push   $0x75
  800581:	68 25 23 80 00       	push   $0x802325
  800586:	e8 d1 00 00 00       	call   80065c <_panic>
		if (r != sizeof(buf))
  80058b:	3d 00 02 00 00       	cmp    $0x200,%eax
  800590:	74 1b                	je     8005ad <umain+0x52e>
			panic("read /big from %d returned %d < %d bytes",
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	68 00 02 00 00       	push   $0x200
  80059a:	50                   	push   %eax
  80059b:	53                   	push   %ebx
  80059c:	68 48 26 80 00       	push   $0x802648
  8005a1:	6a 78                	push   $0x78
  8005a3:	68 25 23 80 00       	push   $0x802325
  8005a8:	e8 af 00 00 00       	call   80065c <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005ad:	8b 07                	mov    (%edi),%eax
  8005af:	39 d8                	cmp    %ebx,%eax
  8005b1:	74 16                	je     8005c9 <umain+0x54a>
			panic("read /big from %d returned bad data %d",
  8005b3:	83 ec 0c             	sub    $0xc,%esp
  8005b6:	50                   	push   %eax
  8005b7:	53                   	push   %ebx
  8005b8:	68 74 26 80 00       	push   $0x802674
  8005bd:	6a 7b                	push   $0x7b
  8005bf:	68 25 23 80 00       	push   $0x802325
  8005c4:	e8 93 00 00 00       	call   80065c <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005c9:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  8005cf:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  8005d5:	7e 80                	jle    800557 <umain+0x4d8>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	56                   	push   %esi
  8005db:	e8 5c 11 00 00       	call   80173c <close>
	cprintf("large file is good\n");
  8005e0:	c7 04 24 a9 24 80 00 	movl   $0x8024a9,(%esp)
  8005e7:	e8 11 01 00 00       	call   8006fd <cprintf>
  8005ec:	83 c4 10             	add    $0x10,%esp
}
  8005ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    
	...

008005f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	56                   	push   %esi
  8005fc:	53                   	push   %ebx
  8005fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800600:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800603:	e8 bf 0b 00 00       	call   8011c7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800608:	25 ff 03 00 00       	and    $0x3ff,%eax
  80060d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800614:	c1 e0 07             	shl    $0x7,%eax
  800617:	29 d0                	sub    %edx,%eax
  800619:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80061e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800623:	85 f6                	test   %esi,%esi
  800625:	7e 07                	jle    80062e <libmain+0x36>
		binaryname = argv[0];
  800627:	8b 03                	mov    (%ebx),%eax
  800629:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	56                   	push   %esi
  800633:	e8 47 fa ff ff       	call   80007f <umain>

	// exit gracefully
	exit();
  800638:	e8 0b 00 00 00       	call   800648 <exit>
  80063d:	83 c4 10             	add    $0x10,%esp
}
  800640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	c9                   	leave  
  800646:	c3                   	ret    
	...

00800648 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80064e:	6a 00                	push   $0x0
  800650:	e8 91 0b 00 00       	call   8011e6 <sys_env_destroy>
  800655:	83 c4 10             	add    $0x10,%esp
}
  800658:	c9                   	leave  
  800659:	c3                   	ret    
	...

0080065c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	53                   	push   %ebx
  800660:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800669:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  80066f:	e8 53 0b 00 00       	call   8011c7 <sys_getenvid>
  800674:	83 ec 0c             	sub    $0xc,%esp
  800677:	ff 75 0c             	pushl  0xc(%ebp)
  80067a:	ff 75 08             	pushl  0x8(%ebp)
  80067d:	53                   	push   %ebx
  80067e:	50                   	push   %eax
  80067f:	68 cc 26 80 00       	push   $0x8026cc
  800684:	e8 74 00 00 00       	call   8006fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800689:	83 c4 18             	add    $0x18,%esp
  80068c:	ff 75 f8             	pushl  -0x8(%ebp)
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	e8 15 00 00 00       	call   8006ac <vcprintf>
	cprintf("\n");
  800697:	c7 04 24 37 2b 80 00 	movl   $0x802b37,(%esp)
  80069e:	e8 5a 00 00 00       	call   8006fd <cprintf>
  8006a3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006a6:	cc                   	int3   
  8006a7:	eb fd                	jmp    8006a6 <_panic+0x4a>
  8006a9:	00 00                	add    %al,(%eax)
	...

008006ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006b5:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8006bc:	00 00 00 
	b.cnt = 0;
  8006bf:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8006c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	68 14 07 80 00       	push   $0x800714
  8006db:	e8 70 01 00 00       	call   800850 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006e0:	83 c4 08             	add    $0x8,%esp
  8006e3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8006e9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8006ef:	50                   	push   %eax
  8006f0:	e8 9e 08 00 00       	call   800f93 <sys_cputs>
  8006f5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8006fb:	c9                   	leave  
  8006fc:	c3                   	ret    

008006fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800703:	8d 45 0c             	lea    0xc(%ebp),%eax
  800706:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800709:	50                   	push   %eax
  80070a:	ff 75 08             	pushl  0x8(%ebp)
  80070d:	e8 9a ff ff ff       	call   8006ac <vcprintf>
	va_end(ap);

	return cnt;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	53                   	push   %ebx
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80071e:	8b 03                	mov    (%ebx),%eax
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800727:	40                   	inc    %eax
  800728:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80072a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80072f:	75 1a                	jne    80074b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	68 ff 00 00 00       	push   $0xff
  800739:	8d 43 08             	lea    0x8(%ebx),%eax
  80073c:	50                   	push   %eax
  80073d:	e8 51 08 00 00       	call   800f93 <sys_cputs>
		b->idx = 0;
  800742:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800748:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80074b:	ff 43 04             	incl   0x4(%ebx)
}
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    
	...

00800754 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	57                   	push   %edi
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	83 ec 1c             	sub    $0x1c,%esp
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
  800769:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80076c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076f:	8b 55 10             	mov    0x10(%ebp),%edx
  800772:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800775:	89 d6                	mov    %edx,%esi
  800777:	bf 00 00 00 00       	mov    $0x0,%edi
  80077c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80077f:	72 04                	jb     800785 <printnum+0x31>
  800781:	39 c2                	cmp    %eax,%edx
  800783:	77 3f                	ja     8007c4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800785:	83 ec 0c             	sub    $0xc,%esp
  800788:	ff 75 18             	pushl  0x18(%ebp)
  80078b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80078e:	50                   	push   %eax
  80078f:	52                   	push   %edx
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	57                   	push   %edi
  800794:	56                   	push   %esi
  800795:	ff 75 e4             	pushl  -0x1c(%ebp)
  800798:	ff 75 e0             	pushl  -0x20(%ebp)
  80079b:	e8 bc 18 00 00       	call   80205c <__udivdi3>
  8007a0:	83 c4 18             	add    $0x18,%esp
  8007a3:	52                   	push   %edx
  8007a4:	50                   	push   %eax
  8007a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	e8 a4 ff ff ff       	call   800754 <printnum>
  8007b0:	83 c4 20             	add    $0x20,%esp
  8007b3:	eb 14                	jmp    8007c9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e8             	pushl  -0x18(%ebp)
  8007bb:	ff 75 18             	pushl  0x18(%ebp)
  8007be:	ff 55 ec             	call   *-0x14(%ebp)
  8007c1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c4:	4b                   	dec    %ebx
  8007c5:	85 db                	test   %ebx,%ebx
  8007c7:	7f ec                	jg     8007b5 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	ff 75 e8             	pushl  -0x18(%ebp)
  8007cf:	83 ec 04             	sub    $0x4,%esp
  8007d2:	57                   	push   %edi
  8007d3:	56                   	push   %esi
  8007d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007da:	e8 a9 19 00 00       	call   802188 <__umoddi3>
  8007df:	83 c4 14             	add    $0x14,%esp
  8007e2:	0f be 80 ef 26 80 00 	movsbl 0x8026ef(%eax),%eax
  8007e9:	50                   	push   %eax
  8007ea:	ff 55 ec             	call   *-0x14(%ebp)
  8007ed:	83 c4 10             	add    $0x10,%esp
}
  8007f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5f                   	pop    %edi
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8007fd:	83 fa 01             	cmp    $0x1,%edx
  800800:	7e 0e                	jle    800810 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800802:	8b 10                	mov    (%eax),%edx
  800804:	8d 42 08             	lea    0x8(%edx),%eax
  800807:	89 01                	mov    %eax,(%ecx)
  800809:	8b 02                	mov    (%edx),%eax
  80080b:	8b 52 04             	mov    0x4(%edx),%edx
  80080e:	eb 22                	jmp    800832 <getuint+0x3a>
	else if (lflag)
  800810:	85 d2                	test   %edx,%edx
  800812:	74 10                	je     800824 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800814:	8b 10                	mov    (%eax),%edx
  800816:	8d 42 04             	lea    0x4(%edx),%eax
  800819:	89 01                	mov    %eax,(%ecx)
  80081b:	8b 02                	mov    (%edx),%eax
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	eb 0e                	jmp    800832 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800824:	8b 10                	mov    (%eax),%edx
  800826:	8d 42 04             	lea    0x4(%edx),%eax
  800829:	89 01                	mov    %eax,(%ecx)
  80082b:	8b 02                	mov    (%edx),%eax
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80083a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80083d:	8b 11                	mov    (%ecx),%edx
  80083f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800842:	73 0a                	jae    80084e <sprintputch+0x1a>
		*b->buf++ = ch;
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	88 02                	mov    %al,(%edx)
  800849:	8d 42 01             	lea    0x1(%edx),%eax
  80084c:	89 01                	mov    %eax,(%ecx)
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	57                   	push   %edi
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	83 ec 3c             	sub    $0x3c,%esp
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80085f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800862:	eb 1a                	jmp    80087e <vprintfmt+0x2e>
  800864:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800867:	eb 15                	jmp    80087e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800869:	84 c0                	test   %al,%al
  80086b:	0f 84 15 03 00 00    	je     800b86 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	57                   	push   %edi
  800875:	0f b6 c0             	movzbl %al,%eax
  800878:	50                   	push   %eax
  800879:	ff d6                	call   *%esi
  80087b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80087e:	8a 03                	mov    (%ebx),%al
  800880:	43                   	inc    %ebx
  800881:	3c 25                	cmp    $0x25,%al
  800883:	75 e4                	jne    800869 <vprintfmt+0x19>
  800885:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80088c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800893:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80089a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008a1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8008a5:	eb 0a                	jmp    8008b1 <vprintfmt+0x61>
  8008a7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8008ae:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8008b1:	8a 03                	mov    (%ebx),%al
  8008b3:	0f b6 d0             	movzbl %al,%edx
  8008b6:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8008b9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8008bc:	83 e8 23             	sub    $0x23,%eax
  8008bf:	3c 55                	cmp    $0x55,%al
  8008c1:	0f 87 9c 02 00 00    	ja     800b63 <vprintfmt+0x313>
  8008c7:	0f b6 c0             	movzbl %al,%eax
  8008ca:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
  8008d1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8008d5:	eb d7                	jmp    8008ae <vprintfmt+0x5e>
  8008d7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8008db:	eb d1                	jmp    8008ae <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8008dd:	89 d9                	mov    %ebx,%ecx
  8008df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008e6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8008e9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8008ec:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8008f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8008f3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8008f7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8008f8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8008fb:	83 f8 09             	cmp    $0x9,%eax
  8008fe:	77 21                	ja     800921 <vprintfmt+0xd1>
  800900:	eb e4                	jmp    8008e6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800902:	8b 55 14             	mov    0x14(%ebp),%edx
  800905:	8d 42 04             	lea    0x4(%edx),%eax
  800908:	89 45 14             	mov    %eax,0x14(%ebp)
  80090b:	8b 12                	mov    (%edx),%edx
  80090d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800910:	eb 12                	jmp    800924 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800912:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800916:	79 96                	jns    8008ae <vprintfmt+0x5e>
  800918:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80091f:	eb 8d                	jmp    8008ae <vprintfmt+0x5e>
  800921:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800924:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800928:	79 84                	jns    8008ae <vprintfmt+0x5e>
  80092a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80092d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800930:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800937:	e9 72 ff ff ff       	jmp    8008ae <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80093c:	ff 45 d4             	incl   -0x2c(%ebp)
  80093f:	e9 6a ff ff ff       	jmp    8008ae <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800944:	8b 55 14             	mov    0x14(%ebp),%edx
  800947:	8d 42 04             	lea    0x4(%edx),%eax
  80094a:	89 45 14             	mov    %eax,0x14(%ebp)
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	57                   	push   %edi
  800951:	ff 32                	pushl  (%edx)
  800953:	ff d6                	call   *%esi
			break;
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	e9 07 ff ff ff       	jmp    800864 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80095d:	8b 55 14             	mov    0x14(%ebp),%edx
  800960:	8d 42 04             	lea    0x4(%edx),%eax
  800963:	89 45 14             	mov    %eax,0x14(%ebp)
  800966:	8b 02                	mov    (%edx),%eax
  800968:	85 c0                	test   %eax,%eax
  80096a:	79 02                	jns    80096e <vprintfmt+0x11e>
  80096c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80096e:	83 f8 0f             	cmp    $0xf,%eax
  800971:	7f 0b                	jg     80097e <vprintfmt+0x12e>
  800973:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  80097a:	85 d2                	test   %edx,%edx
  80097c:	75 15                	jne    800993 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80097e:	50                   	push   %eax
  80097f:	68 00 27 80 00       	push   $0x802700
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	e8 6e 02 00 00       	call   800bf9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80098b:	83 c4 10             	add    $0x10,%esp
  80098e:	e9 d1 fe ff ff       	jmp    800864 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800993:	52                   	push   %edx
  800994:	68 05 2b 80 00       	push   $0x802b05
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	e8 59 02 00 00       	call   800bf9 <printfmt>
  8009a0:	83 c4 10             	add    $0x10,%esp
  8009a3:	e9 bc fe ff ff       	jmp    800864 <vprintfmt+0x14>
  8009a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8009ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009b1:	8b 55 14             	mov    0x14(%ebp),%edx
  8009b4:	8d 42 04             	lea    0x4(%edx),%eax
  8009b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ba:	8b 1a                	mov    (%edx),%ebx
  8009bc:	85 db                	test   %ebx,%ebx
  8009be:	75 05                	jne    8009c5 <vprintfmt+0x175>
  8009c0:	bb 09 27 80 00       	mov    $0x802709,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8009c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8009c9:	7e 66                	jle    800a31 <vprintfmt+0x1e1>
  8009cb:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8009cf:	74 60                	je     800a31 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	51                   	push   %ecx
  8009d5:	53                   	push   %ebx
  8009d6:	e8 57 02 00 00       	call   800c32 <strnlen>
  8009db:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8009de:	29 c1                	sub    %eax,%ecx
  8009e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8009ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8009ed:	eb 0f                	jmp    8009fe <vprintfmt+0x1ae>
					putch(padc, putdat);
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	57                   	push   %edi
  8009f3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8009f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f8:	ff 4d d8             	decl   -0x28(%ebp)
  8009fb:	83 c4 10             	add    $0x10,%esp
  8009fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a02:	7f eb                	jg     8009ef <vprintfmt+0x19f>
  800a04:	eb 2b                	jmp    800a31 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a06:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800a09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a0d:	74 15                	je     800a24 <vprintfmt+0x1d4>
  800a0f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800a12:	83 f8 5e             	cmp    $0x5e,%eax
  800a15:	76 0d                	jbe    800a24 <vprintfmt+0x1d4>
					putch('?', putdat);
  800a17:	83 ec 08             	sub    $0x8,%esp
  800a1a:	57                   	push   %edi
  800a1b:	6a 3f                	push   $0x3f
  800a1d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1f:	83 c4 10             	add    $0x10,%esp
  800a22:	eb 0a                	jmp    800a2e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a24:	83 ec 08             	sub    $0x8,%esp
  800a27:	57                   	push   %edi
  800a28:	52                   	push   %edx
  800a29:	ff d6                	call   *%esi
  800a2b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a2e:	ff 4d d8             	decl   -0x28(%ebp)
  800a31:	8a 03                	mov    (%ebx),%al
  800a33:	43                   	inc    %ebx
  800a34:	84 c0                	test   %al,%al
  800a36:	74 1b                	je     800a53 <vprintfmt+0x203>
  800a38:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a3c:	78 c8                	js     800a06 <vprintfmt+0x1b6>
  800a3e:	ff 4d dc             	decl   -0x24(%ebp)
  800a41:	79 c3                	jns    800a06 <vprintfmt+0x1b6>
  800a43:	eb 0e                	jmp    800a53 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a45:	83 ec 08             	sub    $0x8,%esp
  800a48:	57                   	push   %edi
  800a49:	6a 20                	push   $0x20
  800a4b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a4d:	ff 4d d8             	decl   -0x28(%ebp)
  800a50:	83 c4 10             	add    $0x10,%esp
  800a53:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a57:	7f ec                	jg     800a45 <vprintfmt+0x1f5>
  800a59:	e9 06 fe ff ff       	jmp    800864 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a5e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800a62:	7e 10                	jle    800a74 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800a64:	8b 55 14             	mov    0x14(%ebp),%edx
  800a67:	8d 42 08             	lea    0x8(%edx),%eax
  800a6a:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6d:	8b 02                	mov    (%edx),%eax
  800a6f:	8b 52 04             	mov    0x4(%edx),%edx
  800a72:	eb 20                	jmp    800a94 <vprintfmt+0x244>
	else if (lflag)
  800a74:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a78:	74 0e                	je     800a88 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7d:	8d 50 04             	lea    0x4(%eax),%edx
  800a80:	89 55 14             	mov    %edx,0x14(%ebp)
  800a83:	8b 00                	mov    (%eax),%eax
  800a85:	99                   	cltd   
  800a86:	eb 0c                	jmp    800a94 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 04             	lea    0x4(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 00                	mov    (%eax),%eax
  800a93:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a94:	89 d1                	mov    %edx,%ecx
  800a96:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800a98:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a9b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a9e:	85 c9                	test   %ecx,%ecx
  800aa0:	78 0a                	js     800aac <vprintfmt+0x25c>
  800aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa7:	e9 89 00 00 00       	jmp    800b35 <vprintfmt+0x2e5>
				putch('-', putdat);
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	57                   	push   %edi
  800ab0:	6a 2d                	push   $0x2d
  800ab2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ab4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800ab7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800aba:	f7 da                	neg    %edx
  800abc:	83 d1 00             	adc    $0x0,%ecx
  800abf:	f7 d9                	neg    %ecx
  800ac1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac6:	83 c4 10             	add    $0x10,%esp
  800ac9:	eb 6a                	jmp    800b35 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800acb:	8d 45 14             	lea    0x14(%ebp),%eax
  800ace:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ad1:	e8 22 fd ff ff       	call   8007f8 <getuint>
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adf:	eb 54                	jmp    800b35 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ae1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ae7:	e8 0c fd ff ff       	call   8007f8 <getuint>
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af5:	eb 3e                	jmp    800b35 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800af7:	83 ec 08             	sub    $0x8,%esp
  800afa:	57                   	push   %edi
  800afb:	6a 30                	push   $0x30
  800afd:	ff d6                	call   *%esi
			putch('x', putdat);
  800aff:	83 c4 08             	add    $0x8,%esp
  800b02:	57                   	push   %edi
  800b03:	6a 78                	push   $0x78
  800b05:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b07:	8b 55 14             	mov    0x14(%ebp),%edx
  800b0a:	8d 42 04             	lea    0x4(%edx),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	8b 12                	mov    (%edx),%edx
  800b12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b17:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	eb 14                	jmp    800b35 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b21:	8d 45 14             	lea    0x14(%ebp),%eax
  800b24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b27:	e8 cc fc ff ff       	call   8007f8 <getuint>
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800b3c:	50                   	push   %eax
  800b3d:	ff 75 d8             	pushl  -0x28(%ebp)
  800b40:	53                   	push   %ebx
  800b41:	51                   	push   %ecx
  800b42:	52                   	push   %edx
  800b43:	89 fa                	mov    %edi,%edx
  800b45:	89 f0                	mov    %esi,%eax
  800b47:	e8 08 fc ff ff       	call   800754 <printnum>
			break;
  800b4c:	83 c4 20             	add    $0x20,%esp
  800b4f:	e9 10 fd ff ff       	jmp    800864 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b54:	83 ec 08             	sub    $0x8,%esp
  800b57:	57                   	push   %edi
  800b58:	52                   	push   %edx
  800b59:	ff d6                	call   *%esi
			break;
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	e9 01 fd ff ff       	jmp    800864 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	57                   	push   %edi
  800b67:	6a 25                	push   $0x25
  800b69:	ff d6                	call   *%esi
  800b6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800b6e:	83 ea 02             	sub    $0x2,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b74:	8a 02                	mov    (%edx),%al
  800b76:	4a                   	dec    %edx
  800b77:	3c 25                	cmp    $0x25,%al
  800b79:	75 f9                	jne    800b74 <vprintfmt+0x324>
  800b7b:	83 c2 02             	add    $0x2,%edx
  800b7e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800b81:	e9 de fc ff ff       	jmp    800864 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 18             	sub    $0x18,%esp
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b9a:	85 d2                	test   %edx,%edx
  800b9c:	74 37                	je     800bd5 <vsnprintf+0x47>
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 33                	jle    800bd5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ba2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ba9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800bad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800bb0:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bb3:	ff 75 14             	pushl  0x14(%ebp)
  800bb6:	ff 75 10             	pushl  0x10(%ebp)
  800bb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbc:	50                   	push   %eax
  800bbd:	68 34 08 80 00       	push   $0x800834
  800bc2:	e8 89 fc ff ff       	call   800850 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bcd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	eb 05                	jmp    800bda <vsnprintf+0x4c>
  800bd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800be2:	8d 45 14             	lea    0x14(%ebp),%eax
  800be5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800be8:	50                   	push   %eax
  800be9:	ff 75 10             	pushl  0x10(%ebp)
  800bec:	ff 75 0c             	pushl  0xc(%ebp)
  800bef:	ff 75 08             	pushl  0x8(%ebp)
  800bf2:	e8 97 ff ff ff       	call   800b8e <vsnprintf>
	va_end(ap);

	return rc;
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800bff:	8d 45 14             	lea    0x14(%ebp),%eax
  800c02:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800c05:	50                   	push   %eax
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	ff 75 08             	pushl  0x8(%ebp)
  800c0f:	e8 3c fc ff ff       	call   800850 <vprintfmt>
	va_end(ap);
  800c14:	83 c4 10             	add    $0x10,%esp
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    
  800c19:	00 00                	add    %al,(%eax)
	...

00800c1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	eb 01                	jmp    800c2a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800c29:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800c2e:	75 f9                	jne    800c29 <strlen+0xd>
		n++;
	return n;
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c40:	eb 01                	jmp    800c43 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800c42:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c43:	39 d0                	cmp    %edx,%eax
  800c45:	74 06                	je     800c4d <strnlen+0x1b>
  800c47:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800c4b:	75 f5                	jne    800c42 <strnlen+0x10>
		n++;
	return n;
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c58:	8a 01                	mov    (%ecx),%al
  800c5a:	88 02                	mov    %al,(%edx)
  800c5c:	42                   	inc    %edx
  800c5d:	41                   	inc    %ecx
  800c5e:	84 c0                	test   %al,%al
  800c60:	75 f6                	jne    800c58 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	53                   	push   %ebx
  800c6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c6e:	53                   	push   %ebx
  800c6f:	e8 a8 ff ff ff       	call   800c1c <strlen>
	strcpy(dst + len, src);
  800c74:	ff 75 0c             	pushl  0xc(%ebp)
  800c77:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c7a:	50                   	push   %eax
  800c7b:	e8 cf ff ff ff       	call   800c4f <strcpy>
	return dst;
}
  800c80:	89 d8                	mov    %ebx,%eax
  800c82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9a:	eb 0c                	jmp    800ca8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800c9c:	8a 02                	mov    (%edx),%al
  800c9e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ca1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ca4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca7:	41                   	inc    %ecx
  800ca8:	39 d9                	cmp    %ebx,%ecx
  800caa:	75 f0                	jne    800c9c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cac:	89 f0                	mov    %esi,%eax
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	8b 75 08             	mov    0x8(%ebp),%esi
  800cba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc0:	85 c9                	test   %ecx,%ecx
  800cc2:	75 04                	jne    800cc8 <strlcpy+0x16>
  800cc4:	89 f0                	mov    %esi,%eax
  800cc6:	eb 14                	jmp    800cdc <strlcpy+0x2a>
  800cc8:	89 f0                	mov    %esi,%eax
  800cca:	eb 04                	jmp    800cd0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ccc:	88 10                	mov    %dl,(%eax)
  800cce:	40                   	inc    %eax
  800ccf:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cd0:	49                   	dec    %ecx
  800cd1:	74 06                	je     800cd9 <strlcpy+0x27>
  800cd3:	8a 13                	mov    (%ebx),%dl
  800cd5:	84 d2                	test   %dl,%dl
  800cd7:	75 f3                	jne    800ccc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800cd9:	c6 00 00             	movb   $0x0,(%eax)
  800cdc:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	eb 02                	jmp    800cef <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800ced:	42                   	inc    %edx
  800cee:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cef:	8a 02                	mov    (%edx),%al
  800cf1:	84 c0                	test   %al,%al
  800cf3:	74 04                	je     800cf9 <strcmp+0x17>
  800cf5:	3a 01                	cmp    (%ecx),%al
  800cf7:	74 f4                	je     800ced <strcmp+0xb>
  800cf9:	0f b6 c0             	movzbl %al,%eax
  800cfc:	0f b6 11             	movzbl (%ecx),%edx
  800cff:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	53                   	push   %ebx
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d0d:	8b 55 10             	mov    0x10(%ebp),%edx
  800d10:	eb 03                	jmp    800d15 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800d12:	4a                   	dec    %edx
  800d13:	41                   	inc    %ecx
  800d14:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d15:	85 d2                	test   %edx,%edx
  800d17:	75 07                	jne    800d20 <strncmp+0x1d>
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1e:	eb 14                	jmp    800d34 <strncmp+0x31>
  800d20:	8a 01                	mov    (%ecx),%al
  800d22:	84 c0                	test   %al,%al
  800d24:	74 04                	je     800d2a <strncmp+0x27>
  800d26:	3a 03                	cmp    (%ebx),%al
  800d28:	74 e8                	je     800d12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d2a:	0f b6 d0             	movzbl %al,%edx
  800d2d:	0f b6 03             	movzbl (%ebx),%eax
  800d30:	29 c2                	sub    %eax,%edx
  800d32:	89 d0                	mov    %edx,%eax
}
  800d34:	5b                   	pop    %ebx
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800d40:	eb 05                	jmp    800d47 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800d42:	38 ca                	cmp    %cl,%dl
  800d44:	74 0c                	je     800d52 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d46:	40                   	inc    %eax
  800d47:	8a 10                	mov    (%eax),%dl
  800d49:	84 d2                	test   %dl,%dl
  800d4b:	75 f5                	jne    800d42 <strchr+0xb>
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800d5d:	eb 05                	jmp    800d64 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800d5f:	38 ca                	cmp    %cl,%dl
  800d61:	74 07                	je     800d6a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d63:	40                   	inc    %eax
  800d64:	8a 10                	mov    (%eax),%dl
  800d66:	84 d2                	test   %dl,%dl
  800d68:	75 f5                	jne    800d5f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d6a:	c9                   	leave  
  800d6b:	c3                   	ret    

00800d6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800d7b:	85 db                	test   %ebx,%ebx
  800d7d:	74 36                	je     800db5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d85:	75 29                	jne    800db0 <memset+0x44>
  800d87:	f6 c3 03             	test   $0x3,%bl
  800d8a:	75 24                	jne    800db0 <memset+0x44>
		c &= 0xFF;
  800d8c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	c1 e6 08             	shl    $0x8,%esi
  800d94:	89 d0                	mov    %edx,%eax
  800d96:	c1 e0 18             	shl    $0x18,%eax
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	c1 e1 10             	shl    $0x10,%ecx
  800d9e:	09 c8                	or     %ecx,%eax
  800da0:	09 c2                	or     %eax,%edx
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	09 d0                	or     %edx,%eax
  800da6:	89 d9                	mov    %ebx,%ecx
  800da8:	c1 e9 02             	shr    $0x2,%ecx
  800dab:	fc                   	cld    
  800dac:	f3 ab                	rep stos %eax,%es:(%edi)
  800dae:	eb 05                	jmp    800db5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800db0:	89 d9                	mov    %ebx,%ecx
  800db2:	fc                   	cld    
  800db3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800db5:	89 f8                	mov    %edi,%eax
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800dc7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dca:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dcc:	39 c6                	cmp    %eax,%esi
  800dce:	73 36                	jae    800e06 <memmove+0x4a>
  800dd0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dd3:	39 d0                	cmp    %edx,%eax
  800dd5:	73 2f                	jae    800e06 <memmove+0x4a>
		s += n;
		d += n;
  800dd7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dda:	f6 c2 03             	test   $0x3,%dl
  800ddd:	75 1b                	jne    800dfa <memmove+0x3e>
  800ddf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800de5:	75 13                	jne    800dfa <memmove+0x3e>
  800de7:	f6 c1 03             	test   $0x3,%cl
  800dea:	75 0e                	jne    800dfa <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800dec:	8d 7e fc             	lea    -0x4(%esi),%edi
  800def:	8d 72 fc             	lea    -0x4(%edx),%esi
  800df2:	c1 e9 02             	shr    $0x2,%ecx
  800df5:	fd                   	std    
  800df6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800df8:	eb 09                	jmp    800e03 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dfa:	8d 7e ff             	lea    -0x1(%esi),%edi
  800dfd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e00:	fd                   	std    
  800e01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e03:	fc                   	cld    
  800e04:	eb 20                	jmp    800e26 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e0c:	75 15                	jne    800e23 <memmove+0x67>
  800e0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e14:	75 0d                	jne    800e23 <memmove+0x67>
  800e16:	f6 c1 03             	test   $0x3,%cl
  800e19:	75 08                	jne    800e23 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800e1b:	c1 e9 02             	shr    $0x2,%ecx
  800e1e:	fc                   	cld    
  800e1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e21:	eb 03                	jmp    800e26 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e23:	fc                   	cld    
  800e24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e2d:	ff 75 10             	pushl  0x10(%ebp)
  800e30:	ff 75 0c             	pushl  0xc(%ebp)
  800e33:	ff 75 08             	pushl  0x8(%ebp)
  800e36:	e8 81 ff ff ff       	call   800dbc <memmove>
}
  800e3b:	c9                   	leave  
  800e3c:	c3                   	ret    

00800e3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	53                   	push   %ebx
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	eb 1b                	jmp    800e6a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800e4f:	8a 1a                	mov    (%edx),%bl
  800e51:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800e54:	8a 19                	mov    (%ecx),%bl
  800e56:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800e59:	74 0d                	je     800e68 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800e5b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800e5f:	0f b6 c3             	movzbl %bl,%eax
  800e62:	29 c2                	sub    %eax,%edx
  800e64:	89 d0                	mov    %edx,%eax
  800e66:	eb 0d                	jmp    800e75 <memcmp+0x38>
		s1++, s2++;
  800e68:	42                   	inc    %edx
  800e69:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6a:	48                   	dec    %eax
  800e6b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800e6e:	75 df                	jne    800e4f <memcmp+0x12>
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e75:	83 c4 04             	add    $0x4,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	03 55 10             	add    0x10(%ebp),%edx
  800e89:	eb 05                	jmp    800e90 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e8b:	38 08                	cmp    %cl,(%eax)
  800e8d:	74 05                	je     800e94 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e8f:	40                   	inc    %eax
  800e90:	39 d0                	cmp    %edx,%eax
  800e92:	72 f7                	jb     800e8b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea2:	8b 75 10             	mov    0x10(%ebp),%esi
  800ea5:	eb 01                	jmp    800ea8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ea7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea8:	8a 01                	mov    (%ecx),%al
  800eaa:	3c 20                	cmp    $0x20,%al
  800eac:	74 f9                	je     800ea7 <strtol+0x11>
  800eae:	3c 09                	cmp    $0x9,%al
  800eb0:	74 f5                	je     800ea7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb2:	3c 2b                	cmp    $0x2b,%al
  800eb4:	75 0a                	jne    800ec0 <strtol+0x2a>
		s++;
  800eb6:	41                   	inc    %ecx
  800eb7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ebe:	eb 17                	jmp    800ed7 <strtol+0x41>
	else if (*s == '-')
  800ec0:	3c 2d                	cmp    $0x2d,%al
  800ec2:	74 09                	je     800ecd <strtol+0x37>
  800ec4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ecb:	eb 0a                	jmp    800ed7 <strtol+0x41>
		s++, neg = 1;
  800ecd:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ed0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed7:	85 f6                	test   %esi,%esi
  800ed9:	74 05                	je     800ee0 <strtol+0x4a>
  800edb:	83 fe 10             	cmp    $0x10,%esi
  800ede:	75 1a                	jne    800efa <strtol+0x64>
  800ee0:	8a 01                	mov    (%ecx),%al
  800ee2:	3c 30                	cmp    $0x30,%al
  800ee4:	75 10                	jne    800ef6 <strtol+0x60>
  800ee6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800eea:	75 0a                	jne    800ef6 <strtol+0x60>
		s += 2, base = 16;
  800eec:	83 c1 02             	add    $0x2,%ecx
  800eef:	be 10 00 00 00       	mov    $0x10,%esi
  800ef4:	eb 04                	jmp    800efa <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800ef6:	85 f6                	test   %esi,%esi
  800ef8:	74 07                	je     800f01 <strtol+0x6b>
  800efa:	bf 00 00 00 00       	mov    $0x0,%edi
  800eff:	eb 13                	jmp    800f14 <strtol+0x7e>
  800f01:	3c 30                	cmp    $0x30,%al
  800f03:	74 07                	je     800f0c <strtol+0x76>
  800f05:	be 0a 00 00 00       	mov    $0xa,%esi
  800f0a:	eb ee                	jmp    800efa <strtol+0x64>
		s++, base = 8;
  800f0c:	41                   	inc    %ecx
  800f0d:	be 08 00 00 00       	mov    $0x8,%esi
  800f12:	eb e6                	jmp    800efa <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f14:	8a 11                	mov    (%ecx),%dl
  800f16:	88 d3                	mov    %dl,%bl
  800f18:	8d 42 d0             	lea    -0x30(%edx),%eax
  800f1b:	3c 09                	cmp    $0x9,%al
  800f1d:	77 08                	ja     800f27 <strtol+0x91>
			dig = *s - '0';
  800f1f:	0f be c2             	movsbl %dl,%eax
  800f22:	8d 50 d0             	lea    -0x30(%eax),%edx
  800f25:	eb 1c                	jmp    800f43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f27:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800f2a:	3c 19                	cmp    $0x19,%al
  800f2c:	77 08                	ja     800f36 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800f2e:	0f be c2             	movsbl %dl,%eax
  800f31:	8d 50 a9             	lea    -0x57(%eax),%edx
  800f34:	eb 0d                	jmp    800f43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f36:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800f39:	3c 19                	cmp    $0x19,%al
  800f3b:	77 15                	ja     800f52 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800f3d:	0f be c2             	movsbl %dl,%eax
  800f40:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800f43:	39 f2                	cmp    %esi,%edx
  800f45:	7d 0b                	jge    800f52 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800f47:	41                   	inc    %ecx
  800f48:	89 f8                	mov    %edi,%eax
  800f4a:	0f af c6             	imul   %esi,%eax
  800f4d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800f50:	eb c2                	jmp    800f14 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800f52:	89 f8                	mov    %edi,%eax

	if (endptr)
  800f54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f58:	74 05                	je     800f5f <strtol+0xc9>
		*endptr = (char *) s;
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800f5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f63:	74 04                	je     800f69 <strtol+0xd3>
  800f65:	89 c7                	mov    %eax,%edi
  800f67:	f7 df                	neg    %edi
}
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	83 c4 04             	add    $0x4,%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    
	...

00800f74 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f84:	89 fa                	mov    %edi,%edx
  800f86:	89 f9                	mov    %edi,%ecx
  800f88:	89 fb                	mov    %edi,%ebx
  800f8a:	89 fe                	mov    %edi,%esi
  800f8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa7:	89 f8                	mov    %edi,%eax
  800fa9:	89 fb                	mov    %edi,%ebx
  800fab:	89 fe                	mov    %edi,%esi
  800fad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faf:	83 c4 04             	add    $0x4,%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fc8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fcd:	89 f9                	mov    %edi,%ecx
  800fcf:	89 fb                	mov    %edi,%ebx
  800fd1:	89 fe                	mov    %edi,%esi
  800fd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	7e 17                	jle    800ff0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	50                   	push   %eax
  800fdd:	6a 0d                	push   $0xd
  800fdf:	68 ff 29 80 00       	push   $0x8029ff
  800fe4:	6a 23                	push   $0x23
  800fe6:	68 1c 2a 80 00       	push   $0x802a1c
  800feb:	e8 6c f6 ff ff       	call   80065c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801004:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801007:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80100f:	be 00 00 00 00       	mov    $0x0,%esi
  801014:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80102f:	bf 00 00 00 00       	mov    $0x0,%edi
  801034:	89 fb                	mov    %edi,%ebx
  801036:	89 fe                	mov    %edi,%esi
  801038:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80103a:	85 c0                	test   %eax,%eax
  80103c:	7e 17                	jle    801055 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	50                   	push   %eax
  801042:	6a 0a                	push   $0xa
  801044:	68 ff 29 80 00       	push   $0x8029ff
  801049:	6a 23                	push   $0x23
  80104b:	68 1c 2a 80 00       	push   $0x802a1c
  801050:	e8 07 f6 ff ff       	call   80065c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106c:	b8 09 00 00 00       	mov    $0x9,%eax
  801071:	bf 00 00 00 00       	mov    $0x0,%edi
  801076:	89 fb                	mov    %edi,%ebx
  801078:	89 fe                	mov    %edi,%esi
  80107a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80107c:	85 c0                	test   %eax,%eax
  80107e:	7e 17                	jle    801097 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	50                   	push   %eax
  801084:	6a 09                	push   $0x9
  801086:	68 ff 29 80 00       	push   $0x8029ff
  80108b:	6a 23                	push   $0x23
  80108d:	68 1c 2a 80 00       	push   $0x802a1c
  801092:	e8 c5 f5 ff ff       	call   80065c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8010b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b8:	89 fb                	mov    %edi,%ebx
  8010ba:	89 fe                	mov    %edi,%esi
  8010bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	7e 17                	jle    8010d9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	50                   	push   %eax
  8010c6:	6a 08                	push   $0x8
  8010c8:	68 ff 29 80 00       	push   $0x8029ff
  8010cd:	6a 23                	push   $0x23
  8010cf:	68 1c 2a 80 00       	push   $0x802a1c
  8010d4:	e8 83 f5 ff ff       	call   80065c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f5:	bf 00 00 00 00       	mov    $0x0,%edi
  8010fa:	89 fb                	mov    %edi,%ebx
  8010fc:	89 fe                	mov    %edi,%esi
  8010fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801100:	85 c0                	test   %eax,%eax
  801102:	7e 17                	jle    80111b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	50                   	push   %eax
  801108:	6a 06                	push   $0x6
  80110a:	68 ff 29 80 00       	push   $0x8029ff
  80110f:	6a 23                	push   $0x23
  801111:	68 1c 2a 80 00       	push   $0x802a1c
  801116:	e8 41 f5 ff ff       	call   80065c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	8b 55 08             	mov    0x8(%ebp),%edx
  80112f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801132:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801135:	8b 7d 14             	mov    0x14(%ebp),%edi
  801138:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113b:	b8 05 00 00 00       	mov    $0x5,%eax
  801140:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	7e 17                	jle    80115d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	50                   	push   %eax
  80114a:	6a 05                	push   $0x5
  80114c:	68 ff 29 80 00       	push   $0x8029ff
  801151:	6a 23                	push   $0x23
  801153:	68 1c 2a 80 00       	push   $0x802a1c
  801158:	e8 ff f4 ff ff       	call   80065c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	8b 55 08             	mov    0x8(%ebp),%edx
  801171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801174:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	b8 04 00 00 00       	mov    $0x4,%eax
  80117c:	bf 00 00 00 00       	mov    $0x0,%edi
  801181:	89 fe                	mov    %edi,%esi
  801183:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801185:	85 c0                	test   %eax,%eax
  801187:	7e 17                	jle    8011a0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	50                   	push   %eax
  80118d:	6a 04                	push   $0x4
  80118f:	68 ff 29 80 00       	push   $0x8029ff
  801194:	6a 23                	push   $0x23
  801196:	68 1c 2a 80 00       	push   $0x802a1c
  80119b:	e8 bc f4 ff ff       	call   80065c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	89 f9                	mov    %edi,%ecx
  8011bc:	89 fb                	mov    %edi,%ebx
  8011be:	89 fe                	mov    %edi,%esi
  8011c0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cd:	b8 02 00 00 00       	mov    $0x2,%eax
  8011d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011d7:	89 fa                	mov    %edi,%edx
  8011d9:	89 f9                	mov    %edi,%ecx
  8011db:	89 fb                	mov    %edi,%ebx
  8011dd:	89 fe                	mov    %edi,%esi
  8011df:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	c9                   	leave  
  8011e5:	c3                   	ret    

008011e6 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 0c             	sub    $0xc,%esp
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8011fc:	89 f9                	mov    %edi,%ecx
  8011fe:	89 fb                	mov    %edi,%ebx
  801200:	89 fe                	mov    %edi,%esi
  801202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801204:	85 c0                	test   %eax,%eax
  801206:	7e 17                	jle    80121f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	50                   	push   %eax
  80120c:	6a 03                	push   $0x3
  80120e:	68 ff 29 80 00       	push   $0x8029ff
  801213:	6a 23                	push   $0x23
  801215:	68 1c 2a 80 00       	push   $0x802a1c
  80121a:	e8 3d f4 ff ff       	call   80065c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80121f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801222:	5b                   	pop    %ebx
  801223:	5e                   	pop    %esi
  801224:	5f                   	pop    %edi
  801225:	c9                   	leave  
  801226:	c3                   	ret    
	...

00801228 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80122f:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801234:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  80123b:	89 c8                	mov    %ecx,%eax
  80123d:	c1 e0 07             	shl    $0x7,%eax
  801240:	29 d0                	sub    %edx,%eax
  801242:	89 c2                	mov    %eax,%edx
  801244:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  80124a:	8b 40 50             	mov    0x50(%eax),%eax
  80124d:	39 d8                	cmp    %ebx,%eax
  80124f:	75 0b                	jne    80125c <ipc_find_env+0x34>
			return envs[i].env_id;
  801251:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  801257:	8b 40 40             	mov    0x40(%eax),%eax
  80125a:	eb 0e                	jmp    80126a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80125c:	41                   	inc    %ecx
  80125d:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  801263:	75 cf                	jne    801234 <ipc_find_env+0xc>
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80126a:	5b                   	pop    %ebx
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	57                   	push   %edi
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801279:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  80127f:	85 db                	test   %ebx,%ebx
  801281:	75 05                	jne    801288 <ipc_send+0x1b>
  801283:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	57                   	push   %edi
  80128b:	ff 75 08             	pushl  0x8(%ebp)
  80128e:	e8 65 fd ff ff       	call   800ff8 <sys_ipc_try_send>
		if (r == 0) {		//success
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	74 20                	je     8012ba <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80129a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80129d:	75 07                	jne    8012a6 <ipc_send+0x39>
			sys_yield();
  80129f:	e8 04 ff ff ff       	call   8011a8 <sys_yield>
  8012a4:	eb e2                	jmp    801288 <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	68 2c 2a 80 00       	push   $0x802a2c
  8012ae:	6a 41                	push   $0x41
  8012b0:	68 4f 2a 80 00       	push   $0x802a4f
  8012b5:	e8 a2 f3 ff ff       	call   80065c <_panic>
		}
	}
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cd:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	75 05                	jne    8012d9 <ipc_recv+0x17>
  8012d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	50                   	push   %eax
  8012dd:	e8 d5 fc ff ff       	call   800fb7 <sys_ipc_recv>
	if (r < 0) {				
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 16                	jns    8012ff <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  8012e9:	85 db                	test   %ebx,%ebx
  8012eb:	74 06                	je     8012f3 <ipc_recv+0x31>
  8012ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8012f3:	85 f6                	test   %esi,%esi
  8012f5:	74 2c                	je     801323 <ipc_recv+0x61>
  8012f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012fd:	eb 24                	jmp    801323 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8012ff:	85 db                	test   %ebx,%ebx
  801301:	74 0a                	je     80130d <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  801303:	a1 04 40 80 00       	mov    0x804004,%eax
  801308:	8b 40 74             	mov    0x74(%eax),%eax
  80130b:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  80130d:	85 f6                	test   %esi,%esi
  80130f:	74 0a                	je     80131b <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  801311:	a1 04 40 80 00       	mov    0x804004,%eax
  801316:	8b 40 78             	mov    0x78(%eax),%eax
  801319:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  80131b:	a1 04 40 80 00       	mov    0x804004,%eax
  801320:	8b 40 70             	mov    0x70(%eax),%eax
}
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	c9                   	leave  
  801329:	c3                   	ret    
	...

0080132c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	05 00 00 00 30       	add    $0x30000000,%eax
  801337:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 e5 ff ff ff       	call   80132c <fd2num>
  801347:	83 c4 04             	add    $0x4,%esp
  80134a:	c1 e0 0c             	shl    $0xc,%eax
  80134d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	53                   	push   %ebx
  801358:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80135b:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  801360:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801362:	89 d0                	mov    %edx,%eax
  801364:	c1 e8 16             	shr    $0x16,%eax
  801367:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80136e:	a8 01                	test   $0x1,%al
  801370:	74 10                	je     801382 <fd_alloc+0x2e>
  801372:	89 d0                	mov    %edx,%eax
  801374:	c1 e8 0c             	shr    $0xc,%eax
  801377:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137e:	a8 01                	test   $0x1,%al
  801380:	75 09                	jne    80138b <fd_alloc+0x37>
			*fd_store = fd;
  801382:	89 0b                	mov    %ecx,(%ebx)
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	eb 19                	jmp    8013a4 <fd_alloc+0x50>
			return 0;
  80138b:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801391:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  801397:	75 c7                	jne    801360 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801399:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80139f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8013a4:	5b                   	pop    %ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013ad:	83 f8 1f             	cmp    $0x1f,%eax
  8013b0:	77 35                	ja     8013e7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013b2:	c1 e0 0c             	shl    $0xc,%eax
  8013b5:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013bb:	89 d0                	mov    %edx,%eax
  8013bd:	c1 e8 16             	shr    $0x16,%eax
  8013c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c7:	a8 01                	test   $0x1,%al
  8013c9:	74 1c                	je     8013e7 <fd_lookup+0x40>
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	c1 e8 0c             	shr    $0xc,%eax
  8013d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d7:	a8 01                	test   $0x1,%al
  8013d9:	74 0c                	je     8013e7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013de:	89 10                	mov    %edx,(%eax)
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e5:	eb 05                	jmp    8013ec <fd_lookup+0x45>
	return 0;
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	ff 75 08             	pushl  0x8(%ebp)
  8013fb:	e8 a7 ff ff ff       	call   8013a7 <fd_lookup>
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	78 0e                	js     801415 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80140d:	89 50 04             	mov    %edx,0x4(%eax)
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801424:	ba 00 00 00 00       	mov    $0x0,%edx
  801429:	eb 0e                	jmp    801439 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80142b:	3b 08                	cmp    (%eax),%ecx
  80142d:	75 09                	jne    801438 <dev_lookup+0x21>
			*dev = devtab[i];
  80142f:	89 03                	mov    %eax,(%ebx)
  801431:	b8 00 00 00 00       	mov    $0x0,%eax
  801436:	eb 31                	jmp    801469 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801438:	42                   	inc    %edx
  801439:	8b 04 95 dc 2a 80 00 	mov    0x802adc(,%edx,4),%eax
  801440:	85 c0                	test   %eax,%eax
  801442:	75 e7                	jne    80142b <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801444:	a1 04 40 80 00       	mov    0x804004,%eax
  801449:	8b 40 48             	mov    0x48(%eax),%eax
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	51                   	push   %ecx
  801450:	50                   	push   %eax
  801451:	68 5c 2a 80 00       	push   $0x802a5c
  801456:	e8 a2 f2 ff ff       	call   8006fd <cprintf>
	*dev = 0;
  80145b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801466:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  801469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 23 ff ff ff       	call   8013a7 <fd_lookup>
  801484:	83 c4 08             	add    $0x8,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 55                	js     8014e0 <fstat+0x72>
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801495:	ff 30                	pushl  (%eax)
  801497:	e8 7b ff ff ff       	call   801417 <dev_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 3d                	js     8014e0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8014a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014aa:	75 07                	jne    8014b3 <fstat+0x45>
  8014ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b1:	eb 2d                	jmp    8014e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014bd:	00 00 00 
	stat->st_isdir = 0;
  8014c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014c7:	00 00 00 
	stat->st_dev = dev;
  8014ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014cd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	53                   	push   %ebx
  8014d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014da:	ff 50 14             	call   *0x14(%eax)
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	53                   	push   %ebx
  8014e9:	83 ec 14             	sub    $0x14,%esp
  8014ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	53                   	push   %ebx
  8014f4:	e8 ae fe ff ff       	call   8013a7 <fd_lookup>
  8014f9:	83 c4 08             	add    $0x8,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 5f                	js     80155f <ftruncate+0x7a>
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150a:	ff 30                	pushl  (%eax)
  80150c:	e8 06 ff ff ff       	call   801417 <dev_lookup>
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	78 47                	js     80155f <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151f:	75 21                	jne    801542 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801521:	a1 04 40 80 00       	mov    0x804004,%eax
  801526:	8b 40 48             	mov    0x48(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	53                   	push   %ebx
  80152d:	50                   	push   %eax
  80152e:	68 7c 2a 80 00       	push   $0x802a7c
  801533:	e8 c5 f1 ff ff       	call   8006fd <cprintf>
  801538:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb 1d                	jmp    80155f <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801542:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801545:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  801549:	75 07                	jne    801552 <ftruncate+0x6d>
  80154b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801550:	eb 0d                	jmp    80155f <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	ff 75 0c             	pushl  0xc(%ebp)
  801558:	50                   	push   %eax
  801559:	ff 52 18             	call   *0x18(%edx)
  80155c:	83 c4 10             	add    $0x10,%esp
}
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	53                   	push   %ebx
  801568:	83 ec 14             	sub    $0x14,%esp
  80156b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	53                   	push   %ebx
  801573:	e8 2f fe ff ff       	call   8013a7 <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 62                	js     8015e1 <write+0x7d>
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801589:	ff 30                	pushl  (%eax)
  80158b:	e8 87 fe ff ff       	call   801417 <dev_lookup>
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 4a                	js     8015e1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159e:	75 21                	jne    8015c1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a5:	8b 40 48             	mov    0x48(%eax),%eax
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	50                   	push   %eax
  8015ad:	68 a0 2a 80 00       	push   $0x802aa0
  8015b2:	e8 46 f1 ff ff       	call   8006fd <cprintf>
  8015b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 20                	jmp    8015e1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c1:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8015c4:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  8015c8:	75 07                	jne    8015d1 <write+0x6d>
  8015ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015cf:	eb 10                	jmp    8015e1 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	ff 75 10             	pushl  0x10(%ebp)
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	50                   	push   %eax
  8015db:	ff 52 0c             	call   *0xc(%edx)
  8015de:	83 c4 10             	add    $0x10,%esp
}
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 14             	sub    $0x14,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	53                   	push   %ebx
  8015f5:	e8 ad fd ff ff       	call   8013a7 <fd_lookup>
  8015fa:	83 c4 08             	add    $0x8,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 67                	js     801668 <read+0x82>
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160b:	ff 30                	pushl  (%eax)
  80160d:	e8 05 fe ff ff       	call   801417 <dev_lookup>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 4f                	js     801668 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161c:	8b 42 08             	mov    0x8(%edx),%eax
  80161f:	83 e0 03             	and    $0x3,%eax
  801622:	83 f8 01             	cmp    $0x1,%eax
  801625:	75 21                	jne    801648 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801627:	a1 04 40 80 00       	mov    0x804004,%eax
  80162c:	8b 40 48             	mov    0x48(%eax),%eax
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	53                   	push   %ebx
  801633:	50                   	push   %eax
  801634:	68 bd 2a 80 00       	push   $0x802abd
  801639:	e8 bf f0 ff ff       	call   8006fd <cprintf>
  80163e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	eb 20                	jmp    801668 <read+0x82>
	}
	if (!dev->dev_read)
  801648:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80164b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80164f:	75 07                	jne    801658 <read+0x72>
  801651:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801656:	eb 10                	jmp    801668 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 10             	pushl  0x10(%ebp)
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	52                   	push   %edx
  801662:	ff 50 08             	call   *0x8(%eax)
  801665:	83 c4 10             	add    $0x10,%esp
}
  801668:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	57                   	push   %edi
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801679:	8b 75 10             	mov    0x10(%ebp),%esi
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801681:	eb 21                	jmp    8016a4 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	89 f0                	mov    %esi,%eax
  801688:	29 d0                	sub    %edx,%eax
  80168a:	50                   	push   %eax
  80168b:	8d 04 17             	lea    (%edi,%edx,1),%eax
  80168e:	50                   	push   %eax
  80168f:	ff 75 08             	pushl  0x8(%ebp)
  801692:	e8 4f ff ff ff       	call   8015e6 <read>
		if (m < 0)
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	85 c0                	test   %eax,%eax
  80169c:	78 0e                	js     8016ac <readn+0x3f>
			return m;
		if (m == 0)
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	74 08                	je     8016aa <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a2:	01 c3                	add    %eax,%ebx
  8016a4:	89 da                	mov    %ebx,%edx
  8016a6:	39 f3                	cmp    %esi,%ebx
  8016a8:	72 d9                	jb     801683 <readn+0x16>
  8016aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 20             	sub    $0x20,%esp
  8016bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bf:	8a 45 0c             	mov    0xc(%ebp),%al
  8016c2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	56                   	push   %esi
  8016ca:	e8 5d fc ff ff       	call   80132c <fd2num>
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	e8 d0 fc ff ff       	call   8013a7 <fd_lookup>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 08             	add    $0x8,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 05                	js     8016e5 <fd_close+0x31>
  8016e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016e3:	74 0d                	je     8016f2 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8016e5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8016e9:	75 48                	jne    801733 <fd_close+0x7f>
  8016eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f0:	eb 41                	jmp    801733 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	ff 36                	pushl  (%esi)
  8016fb:	e8 17 fd ff ff       	call   801417 <dev_lookup>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	78 1c                	js     801725 <fd_close+0x71>
		if (dev->dev_close)
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	8b 40 10             	mov    0x10(%eax),%eax
  80170f:	85 c0                	test   %eax,%eax
  801711:	75 07                	jne    80171a <fd_close+0x66>
  801713:	bb 00 00 00 00       	mov    $0x0,%ebx
  801718:	eb 0b                	jmp    801725 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	56                   	push   %esi
  80171e:	ff d0                	call   *%eax
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	56                   	push   %esi
  801729:	6a 00                	push   $0x0
  80172b:	e8 b1 f9 ff ff       	call   8010e1 <sys_page_unmap>
  801730:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801733:	89 d8                	mov    %ebx,%eax
  801735:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	c9                   	leave  
  80173b:	c3                   	ret    

0080173c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801742:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	ff 75 08             	pushl  0x8(%ebp)
  801749:	e8 59 fc ff ff       	call   8013a7 <fd_lookup>
  80174e:	83 c4 08             	add    $0x8,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 10                	js     801765 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	6a 01                	push   $0x1
  80175a:	ff 75 fc             	pushl  -0x4(%ebp)
  80175d:	e8 52 ff ff ff       	call   8016b4 <fd_close>
  801762:	83 c4 10             	add    $0x10,%esp
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	56                   	push   %esi
  80176b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	6a 00                	push   $0x0
  801771:	ff 75 08             	pushl  0x8(%ebp)
  801774:	e8 4a 03 00 00       	call   801ac3 <open>
  801779:	89 c6                	mov    %eax,%esi
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 1b                	js     80179d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	ff 75 0c             	pushl  0xc(%ebp)
  801788:	50                   	push   %eax
  801789:	e8 e0 fc ff ff       	call   80146e <fstat>
  80178e:	89 c3                	mov    %eax,%ebx
	close(fd);
  801790:	89 34 24             	mov    %esi,(%esp)
  801793:	e8 a4 ff ff ff       	call   80173c <close>
  801798:	89 de                	mov    %ebx,%esi
  80179a:	83 c4 10             	add    $0x10,%esp
	return r;
}
  80179d:	89 f0                	mov    %esi,%eax
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	57                   	push   %edi
  8017aa:	56                   	push   %esi
  8017ab:	53                   	push   %ebx
  8017ac:	83 ec 1c             	sub    $0x1c,%esp
  8017af:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b5:	50                   	push   %eax
  8017b6:	ff 75 08             	pushl  0x8(%ebp)
  8017b9:	e8 e9 fb ff ff       	call   8013a7 <fd_lookup>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 08             	add    $0x8,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	0f 88 bd 00 00 00    	js     801888 <dup+0xe2>
		return r;
	close(newfdnum);
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	57                   	push   %edi
  8017cf:	e8 68 ff ff ff       	call   80173c <close>

	newfd = INDEX2FD(newfdnum);
  8017d4:	89 f8                	mov    %edi,%eax
  8017d6:	c1 e0 0c             	shl    $0xc,%eax
  8017d9:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  8017df:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e2:	e8 55 fb ff ff       	call   80133c <fd2data>
  8017e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017e9:	89 34 24             	mov    %esi,(%esp)
  8017ec:	e8 4b fb ff ff       	call   80133c <fd2data>
  8017f1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	c1 e8 16             	shr    $0x16,%eax
  8017f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801800:	83 c4 14             	add    $0x14,%esp
  801803:	a8 01                	test   $0x1,%al
  801805:	74 36                	je     80183d <dup+0x97>
  801807:	89 da                	mov    %ebx,%edx
  801809:	c1 ea 0c             	shr    $0xc,%edx
  80180c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801813:	a8 01                	test   $0x1,%al
  801815:	74 26                	je     80183d <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801817:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80181e:	83 ec 0c             	sub    $0xc,%esp
  801821:	25 07 0e 00 00       	and    $0xe07,%eax
  801826:	50                   	push   %eax
  801827:	ff 75 e0             	pushl  -0x20(%ebp)
  80182a:	6a 00                	push   $0x0
  80182c:	53                   	push   %ebx
  80182d:	6a 00                	push   $0x0
  80182f:	e8 ef f8 ff ff       	call   801123 <sys_page_map>
  801834:	89 c3                	mov    %eax,%ebx
  801836:	83 c4 20             	add    $0x20,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 30                	js     80186d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80183d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801840:	89 d0                	mov    %edx,%eax
  801842:	c1 e8 0c             	shr    $0xc,%eax
  801845:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80184c:	83 ec 0c             	sub    $0xc,%esp
  80184f:	25 07 0e 00 00       	and    $0xe07,%eax
  801854:	50                   	push   %eax
  801855:	56                   	push   %esi
  801856:	6a 00                	push   $0x0
  801858:	52                   	push   %edx
  801859:	6a 00                	push   $0x0
  80185b:	e8 c3 f8 ff ff       	call   801123 <sys_page_map>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	83 c4 20             	add    $0x20,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	78 04                	js     80186d <dup+0xc7>
		goto err;
  801869:	89 fb                	mov    %edi,%ebx
  80186b:	eb 1b                	jmp    801888 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	56                   	push   %esi
  801871:	6a 00                	push   $0x0
  801873:	e8 69 f8 ff ff       	call   8010e1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801878:	83 c4 08             	add    $0x8,%esp
  80187b:	ff 75 e0             	pushl  -0x20(%ebp)
  80187e:	6a 00                	push   $0x0
  801880:	e8 5c f8 ff ff       	call   8010e1 <sys_page_unmap>
  801885:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801888:	89 d8                	mov    %ebx,%eax
  80188a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5f                   	pop    %edi
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 04             	sub    $0x4,%esp
  801899:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	53                   	push   %ebx
  8018a2:	e8 95 fe ff ff       	call   80173c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018a7:	43                   	inc    %ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	83 fb 20             	cmp    $0x20,%ebx
  8018ae:	75 ee                	jne    80189e <close_all+0xc>
		close(i);
}
  8018b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    
  8018b5:	00 00                	add    %al,(%eax)
	...

008018b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	89 c3                	mov    %eax,%ebx
  8018bf:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018c8:	75 12                	jne    8018dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018ca:	83 ec 0c             	sub    $0xc,%esp
  8018cd:	6a 01                	push   $0x1
  8018cf:	e8 54 f9 ff ff       	call   801228 <ipc_find_env>
  8018d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018dc:	6a 07                	push   $0x7
  8018de:	68 00 50 80 00       	push   $0x805000
  8018e3:	53                   	push   %ebx
  8018e4:	ff 35 00 40 80 00    	pushl  0x804000
  8018ea:	e8 7e f9 ff ff       	call   80126d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ef:	83 c4 0c             	add    $0xc,%esp
  8018f2:	6a 00                	push   $0x0
  8018f4:	56                   	push   %esi
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 c6 f9 ff ff       	call   8012c2 <ipc_recv>
}
  8018fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
  80190e:	b8 08 00 00 00       	mov    $0x8,%eax
  801913:	e8 a0 ff ff ff       	call   8018b8 <fsipc>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
  801926:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 02 00 00 00       	mov    $0x2,%eax
  80193d:	e8 76 ff ff ff       	call   8018b8 <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	8b 40 0c             	mov    0xc(%eax),%eax
  801950:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801955:	ba 00 00 00 00       	mov    $0x0,%edx
  80195a:	b8 06 00 00 00       	mov    $0x6,%eax
  80195f:	e8 54 ff ff ff       	call   8018b8 <fsipc>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	8b 40 0c             	mov    0xc(%eax),%eax
  801976:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 05 00 00 00       	mov    $0x5,%eax
  801985:	e8 2e ff ff ff       	call   8018b8 <fsipc>
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 2c                	js     8019ba <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	53                   	push   %ebx
  801997:	e8 b3 f2 ff ff       	call   800c4f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199c:	a1 80 50 80 00       	mov    0x805080,%eax
  8019a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a7:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b7:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = n;
  8019d4:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019da:	53                   	push   %ebx
  8019db:	ff 75 0c             	pushl  0xc(%ebp)
  8019de:	68 08 50 80 00       	push   $0x805008
  8019e3:	e8 d4 f3 ff ff       	call   800dbc <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f2:	e8 c1 fe ff ff       	call   8018b8 <fsipc>
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	78 3d                	js     801a3b <devfile_write+0x7c>
		return r;
	assert(r <= n);
  8019fe:	39 c3                	cmp    %eax,%ebx
  801a00:	73 19                	jae    801a1b <devfile_write+0x5c>
  801a02:	68 ec 2a 80 00       	push   $0x802aec
  801a07:	68 f3 2a 80 00       	push   $0x802af3
  801a0c:	68 97 00 00 00       	push   $0x97
  801a11:	68 08 2b 80 00       	push   $0x802b08
  801a16:	e8 41 ec ff ff       	call   80065c <_panic>
	assert(r <= PGSIZE);
  801a1b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a20:	7e 19                	jle    801a3b <devfile_write+0x7c>
  801a22:	68 13 2b 80 00       	push   $0x802b13
  801a27:	68 f3 2a 80 00       	push   $0x802af3
  801a2c:	68 98 00 00 00       	push   $0x98
  801a31:	68 08 2b 80 00       	push   $0x802b08
  801a36:	e8 21 ec ff ff       	call   80065c <_panic>
	
	return r;
}
  801a3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a63:	e8 50 fe ff ff       	call   8018b8 <fsipc>
  801a68:	89 c3                	mov    %eax,%ebx
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 4c                	js     801aba <devfile_read+0x7a>
		return r;
	assert(r <= n);
  801a6e:	39 de                	cmp    %ebx,%esi
  801a70:	73 16                	jae    801a88 <devfile_read+0x48>
  801a72:	68 ec 2a 80 00       	push   $0x802aec
  801a77:	68 f3 2a 80 00       	push   $0x802af3
  801a7c:	6a 7c                	push   $0x7c
  801a7e:	68 08 2b 80 00       	push   $0x802b08
  801a83:	e8 d4 eb ff ff       	call   80065c <_panic>
	assert(r <= PGSIZE);
  801a88:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  801a8e:	7e 16                	jle    801aa6 <devfile_read+0x66>
  801a90:	68 13 2b 80 00       	push   $0x802b13
  801a95:	68 f3 2a 80 00       	push   $0x802af3
  801a9a:	6a 7d                	push   $0x7d
  801a9c:	68 08 2b 80 00       	push   $0x802b08
  801aa1:	e8 b6 eb ff ff       	call   80065c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa6:	83 ec 04             	sub    $0x4,%esp
  801aa9:	50                   	push   %eax
  801aaa:	68 00 50 80 00       	push   $0x805000
  801aaf:	ff 75 0c             	pushl  0xc(%ebp)
  801ab2:	e8 05 f3 ff ff       	call   800dbc <memmove>
  801ab7:	83 c4 10             	add    $0x10,%esp
	return r;
}
  801aba:	89 d8                	mov    %ebx,%eax
  801abc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 1c             	sub    $0x1c,%esp
  801acb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ace:	56                   	push   %esi
  801acf:	e8 48 f1 ff ff       	call   800c1c <strlen>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801adc:	7e 07                	jle    801ae5 <open+0x22>
  801ade:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ae3:	eb 63                	jmp    801b48 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aeb:	50                   	push   %eax
  801aec:	e8 63 f8 ff ff       	call   801354 <fd_alloc>
  801af1:	89 c3                	mov    %eax,%ebx
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	85 c0                	test   %eax,%eax
  801af8:	78 4e                	js     801b48 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	56                   	push   %esi
  801afe:	68 00 50 80 00       	push   $0x805000
  801b03:	e8 47 f1 ff ff       	call   800c4f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b13:	b8 01 00 00 00       	mov    $0x1,%eax
  801b18:	e8 9b fd ff ff       	call   8018b8 <fsipc>
  801b1d:	89 c3                	mov    %eax,%ebx
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	85 c0                	test   %eax,%eax
  801b24:	79 12                	jns    801b38 <open+0x75>
		fd_close(fd, 0);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	6a 00                	push   $0x0
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	e8 81 fb ff ff       	call   8016b4 <fd_close>
		return r;
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	eb 10                	jmp    801b48 <open+0x85>
	}

	return fd2num(fd);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	e8 e9 f7 ff ff       	call   80132c <fd2num>
  801b43:	89 c3                	mov    %eax,%ebx
  801b45:	83 c4 10             	add    $0x10,%esp
}
  801b48:	89 d8                	mov    %ebx,%eax
  801b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    
  801b51:	00 00                	add    %al,(%eax)
	...

00801b54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5c:	83 ec 0c             	sub    $0xc,%esp
  801b5f:	ff 75 08             	pushl  0x8(%ebp)
  801b62:	e8 d5 f7 ff ff       	call   80133c <fd2data>
  801b67:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b69:	83 c4 08             	add    $0x8,%esp
  801b6c:	68 1f 2b 80 00       	push   $0x802b1f
  801b71:	53                   	push   %ebx
  801b72:	e8 d8 f0 ff ff       	call   800c4f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b77:	8b 46 04             	mov    0x4(%esi),%eax
  801b7a:	2b 06                	sub    (%esi),%eax
  801b7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b82:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b89:	00 00 00 
	stat->st_dev = &devpipe;
  801b8c:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b93:	30 80 00 
	return 0;
}
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	53                   	push   %ebx
  801ba6:	83 ec 0c             	sub    $0xc,%esp
  801ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bac:	53                   	push   %ebx
  801bad:	6a 00                	push   $0x0
  801baf:	e8 2d f5 ff ff       	call   8010e1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb4:	89 1c 24             	mov    %ebx,(%esp)
  801bb7:	e8 80 f7 ff ff       	call   80133c <fd2data>
  801bbc:	83 c4 08             	add    $0x8,%esp
  801bbf:	50                   	push   %eax
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 1a f5 ff ff       	call   8010e1 <sys_page_unmap>
}
  801bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bca:	c9                   	leave  
  801bcb:	c3                   	ret    

00801bcc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801bd8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bda:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801be2:	83 ec 0c             	sub    $0xc,%esp
  801be5:	ff 75 f0             	pushl  -0x10(%ebp)
  801be8:	e8 2f 04 00 00       	call   80201c <pageref>
  801bed:	89 c3                	mov    %eax,%ebx
  801bef:	89 3c 24             	mov    %edi,(%esp)
  801bf2:	e8 25 04 00 00       	call   80201c <pageref>
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	39 c3                	cmp    %eax,%ebx
  801bfc:	0f 94 c0             	sete   %al
  801bff:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  801c02:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c08:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  801c0b:	39 c6                	cmp    %eax,%esi
  801c0d:	74 1b                	je     801c2a <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  801c0f:	83 f9 01             	cmp    $0x1,%ecx
  801c12:	75 c6                	jne    801bda <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c14:	8b 42 58             	mov    0x58(%edx),%eax
  801c17:	6a 01                	push   $0x1
  801c19:	50                   	push   %eax
  801c1a:	56                   	push   %esi
  801c1b:	68 26 2b 80 00       	push   $0x802b26
  801c20:	e8 d8 ea ff ff       	call   8006fd <cprintf>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb b0                	jmp    801bda <_pipeisclosed+0xe>
	}
}
  801c2a:	89 c8                	mov    %ecx,%eax
  801c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 18             	sub    $0x18,%esp
  801c3d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c40:	56                   	push   %esi
  801c41:	e8 f6 f6 ff ff       	call   80133c <fd2data>
  801c46:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801c48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801c4e:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	eb 40                	jmp    801c98 <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5d:	eb 40                	jmp    801c9f <devpipe_write+0x6b>
  801c5f:	89 da                	mov    %ebx,%edx
  801c61:	89 f0                	mov    %esi,%eax
  801c63:	e8 64 ff ff ff       	call   801bcc <_pipeisclosed>
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	75 ec                	jne    801c58 <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c6c:	e8 37 f5 ff ff       	call   8011a8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c71:	8b 53 04             	mov    0x4(%ebx),%edx
  801c74:	8b 03                	mov    (%ebx),%eax
  801c76:	83 c0 20             	add    $0x20,%eax
  801c79:	39 c2                	cmp    %eax,%edx
  801c7b:	73 e2                	jae    801c5f <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c7d:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c83:	79 05                	jns    801c8a <devpipe_write+0x56>
  801c85:	4a                   	dec    %edx
  801c86:	83 ca e0             	or     $0xffffffe0,%edx
  801c89:	42                   	inc    %edx
  801c8a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801c8d:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  801c90:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c94:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	47                   	inc    %edi
  801c98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9b:	75 d4                	jne    801c71 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c9d:	89 f8                	mov    %edi,%eax
}
  801c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	83 ec 18             	sub    $0x18,%esp
  801cb0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cb3:	57                   	push   %edi
  801cb4:	e8 83 f6 ff ff       	call   80133c <fd2data>
  801cb9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801cc1:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	eb 41                	jmp    801d0c <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ccb:	89 f0                	mov    %esi,%eax
  801ccd:	eb 44                	jmp    801d13 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd4:	eb 3d                	jmp    801d13 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd6:	85 f6                	test   %esi,%esi
  801cd8:	75 f1                	jne    801ccb <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cda:	89 da                	mov    %ebx,%edx
  801cdc:	89 f8                	mov    %edi,%eax
  801cde:	e8 e9 fe ff ff       	call   801bcc <_pipeisclosed>
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	75 e8                	jne    801ccf <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ce7:	e8 bc f4 ff ff       	call   8011a8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cec:	8b 03                	mov    (%ebx),%eax
  801cee:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cf1:	74 e3                	je     801cd6 <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cf8:	79 05                	jns    801cff <devpipe_read+0x58>
  801cfa:	48                   	dec    %eax
  801cfb:	83 c8 e0             	or     $0xffffffe0,%eax
  801cfe:	40                   	inc    %eax
  801cff:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d06:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  801d09:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0b:	46                   	inc    %esi
  801d0c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d0f:	75 db                	jne    801cec <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d11:	89 f0                	mov    %esi,%eax
}
  801d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d21:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	e8 7a f6 ff ff       	call   8013a7 <fd_lookup>
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 18                	js     801d4c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	ff 75 fc             	pushl  -0x4(%ebp)
  801d3a:	e8 fd f5 ff ff       	call   80133c <fd2data>
  801d3f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d41:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d44:	e8 83 fe ff ff       	call   801bcc <_pipeisclosed>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 28             	sub    $0x28,%esp
  801d57:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d5d:	50                   	push   %eax
  801d5e:	e8 f1 f5 ff ff       	call   801354 <fd_alloc>
  801d63:	89 c3                	mov    %eax,%ebx
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	0f 88 24 01 00 00    	js     801e94 <pipe+0x146>
  801d70:	83 ec 04             	sub    $0x4,%esp
  801d73:	68 07 04 00 00       	push   $0x407
  801d78:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7b:	6a 00                	push   $0x0
  801d7d:	e8 e3 f3 ff ff       	call   801165 <sys_page_alloc>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 88 05 01 00 00    	js     801e94 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d8f:	83 ec 0c             	sub    $0xc,%esp
  801d92:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d95:	50                   	push   %eax
  801d96:	e8 b9 f5 ff ff       	call   801354 <fd_alloc>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	0f 88 dc 00 00 00    	js     801e84 <pipe+0x136>
  801da8:	83 ec 04             	sub    $0x4,%esp
  801dab:	68 07 04 00 00       	push   $0x407
  801db0:	ff 75 ec             	pushl  -0x14(%ebp)
  801db3:	6a 00                	push   $0x0
  801db5:	e8 ab f3 ff ff       	call   801165 <sys_page_alloc>
  801dba:	89 c3                	mov    %eax,%ebx
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	0f 88 bd 00 00 00    	js     801e84 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcd:	e8 6a f5 ff ff       	call   80133c <fd2data>
  801dd2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd4:	83 c4 0c             	add    $0xc,%esp
  801dd7:	68 07 04 00 00       	push   $0x407
  801ddc:	50                   	push   %eax
  801ddd:	6a 00                	push   $0x0
  801ddf:	e8 81 f3 ff ff       	call   801165 <sys_page_alloc>
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	0f 88 83 00 00 00    	js     801e74 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	ff 75 ec             	pushl  -0x14(%ebp)
  801df7:	e8 40 f5 ff ff       	call   80133c <fd2data>
  801dfc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e03:	50                   	push   %eax
  801e04:	6a 00                	push   $0x0
  801e06:	56                   	push   %esi
  801e07:	6a 00                	push   $0x0
  801e09:	e8 15 f3 ff ff       	call   801123 <sys_page_map>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	83 c4 20             	add    $0x20,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 4f                	js     801e66 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e17:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e20:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e25:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e2c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e35:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801e3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 f0             	pushl  -0x10(%ebp)
  801e47:	e8 e0 f4 ff ff       	call   80132c <fd2num>
  801e4c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e4e:	83 c4 04             	add    $0x4,%esp
  801e51:	ff 75 ec             	pushl  -0x14(%ebp)
  801e54:	e8 d3 f4 ff ff       	call   80132c <fd2num>
  801e59:	89 47 04             	mov    %eax,0x4(%edi)
  801e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	eb 2e                	jmp    801e94 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e66:	83 ec 08             	sub    $0x8,%esp
  801e69:	56                   	push   %esi
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 70 f2 ff ff       	call   8010e1 <sys_page_unmap>
  801e71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e74:	83 ec 08             	sub    $0x8,%esp
  801e77:	ff 75 ec             	pushl  -0x14(%ebp)
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 60 f2 ff ff       	call   8010e1 <sys_page_unmap>
  801e81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e84:	83 ec 08             	sub    $0x8,%esp
  801e87:	ff 75 f0             	pushl  -0x10(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 50 f2 ff ff       	call   8010e1 <sys_page_unmap>
  801e91:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801e94:	89 d8                	mov    %ebx,%eax
  801e96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e99:	5b                   	pop    %ebx
  801e9a:	5e                   	pop    %esi
  801e9b:	5f                   	pop    %edi
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    
	...

00801ea0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb0:	68 3e 2b 80 00       	push   $0x802b3e
  801eb5:	ff 75 0c             	pushl  0xc(%ebp)
  801eb8:	e8 92 ed ff ff       	call   800c4f <strcpy>
	return 0;
}
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  801ed0:	be 00 00 00 00       	mov    $0x0,%esi
  801ed5:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  801edb:	eb 2c                	jmp    801f09 <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ee2:	83 fb 7f             	cmp    $0x7f,%ebx
  801ee5:	76 05                	jbe    801eec <devcons_write+0x28>
  801ee7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	53                   	push   %ebx
  801ef0:	03 45 0c             	add    0xc(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	57                   	push   %edi
  801ef5:	e8 c2 ee ff ff       	call   800dbc <memmove>
		sys_cputs(buf, m);
  801efa:	83 c4 08             	add    $0x8,%esp
  801efd:	53                   	push   %ebx
  801efe:	57                   	push   %edi
  801eff:	e8 8f f0 ff ff       	call   800f93 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f04:	01 de                	add    %ebx,%esi
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	89 f0                	mov    %esi,%eax
  801f0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f0e:	72 cd                	jb     801edd <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f24:	6a 01                	push   $0x1
  801f26:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	e8 64 f0 ff ff       	call   800f93 <sys_cputs>
  801f2f:	83 c4 10             	add    $0x10,%esp
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f3e:	74 27                	je     801f67 <devcons_read+0x33>
  801f40:	eb 05                	jmp    801f47 <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f42:	e8 61 f2 ff ff       	call   8011a8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f47:	e8 28 f0 ff ff       	call   800f74 <sys_cgetc>
  801f4c:	89 c2                	mov    %eax,%edx
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	74 f0                	je     801f42 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 16                	js     801f6c <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f56:	83 f8 04             	cmp    $0x4,%eax
  801f59:	74 0c                	je     801f67 <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  801f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5e:	88 10                	mov    %dl,(%eax)
  801f60:	ba 01 00 00 00       	mov    $0x1,%edx
  801f65:	eb 05                	jmp    801f6c <devcons_read+0x38>
	return 1;
  801f67:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801f6c:	89 d0                	mov    %edx,%eax
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f76:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f79:	50                   	push   %eax
  801f7a:	e8 d5 f3 ff ff       	call   801354 <fd_alloc>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 3b                	js     801fc1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f86:	83 ec 04             	sub    $0x4,%esp
  801f89:	68 07 04 00 00       	push   $0x407
  801f8e:	ff 75 fc             	pushl  -0x4(%ebp)
  801f91:	6a 00                	push   $0x0
  801f93:	e8 cd f1 ff ff       	call   801165 <sys_page_alloc>
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	78 22                	js     801fc1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f9f:	a1 40 30 80 00       	mov    0x803040,%eax
  801fa4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801fa7:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  801fa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fac:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb3:	83 ec 0c             	sub    $0xc,%esp
  801fb6:	ff 75 fc             	pushl  -0x4(%ebp)
  801fb9:	e8 6e f3 ff ff       	call   80132c <fd2num>
  801fbe:	83 c4 10             	add    $0x10,%esp
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fcc:	50                   	push   %eax
  801fcd:	ff 75 08             	pushl  0x8(%ebp)
  801fd0:	e8 d2 f3 ff ff       	call   8013a7 <fd_lookup>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 11                	js     801fed <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fdf:	8b 00                	mov    (%eax),%eax
  801fe1:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  801fe7:	0f 94 c0             	sete   %al
  801fea:	0f b6 c0             	movzbl %al,%eax
}
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    

00801fef <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ff5:	6a 01                	push   $0x1
  801ff7:	8d 45 ff             	lea    -0x1(%ebp),%eax
  801ffa:	50                   	push   %eax
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 e4 f5 ff ff       	call   8015e6 <read>
	if (r < 0)
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 0f                	js     802018 <getchar+0x29>
		return r;
	if (r < 1)
  802009:	85 c0                	test   %eax,%eax
  80200b:	75 07                	jne    802014 <getchar+0x25>
  80200d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802012:	eb 04                	jmp    802018 <getchar+0x29>
		return -E_EOF;
	return c;
  802014:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    
	...

0080201c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802022:	89 d0                	mov    %edx,%eax
  802024:	c1 e8 16             	shr    $0x16,%eax
  802027:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80202e:	a8 01                	test   $0x1,%al
  802030:	74 20                	je     802052 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802032:	89 d0                	mov    %edx,%eax
  802034:	c1 e8 0c             	shr    $0xc,%eax
  802037:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80203e:	a8 01                	test   $0x1,%al
  802040:	74 10                	je     802052 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802042:	c1 e8 0c             	shr    $0xc,%eax
  802045:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80204c:	ef 
  80204d:	0f b7 c0             	movzwl %ax,%eax
  802050:	eb 05                	jmp    802057 <pageref+0x3b>
  802052:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802057:	c9                   	leave  
  802058:	c3                   	ret    
  802059:	00 00                	add    %al,(%eax)
	...

0080205c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	57                   	push   %edi
  802060:	56                   	push   %esi
  802061:	83 ec 28             	sub    $0x28,%esp
  802064:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80206b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  802072:	8b 45 10             	mov    0x10(%ebp),%eax
  802075:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  802078:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80207b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  80207d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  80207f:	8b 45 08             	mov    0x8(%ebp),%eax
  802082:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  802085:	8b 55 0c             	mov    0xc(%ebp),%edx
  802088:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80208b:	85 ff                	test   %edi,%edi
  80208d:	75 21                	jne    8020b0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  80208f:	39 d1                	cmp    %edx,%ecx
  802091:	76 49                	jbe    8020dc <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802093:	f7 f1                	div    %ecx
  802095:	89 c1                	mov    %eax,%ecx
  802097:	31 c0                	xor    %eax,%eax
  802099:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80209c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80209f:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8020a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8020a8:	83 c4 28             	add    $0x28,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020b0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8020b3:	0f 87 97 00 00 00    	ja     802150 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020b9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020bc:	83 f0 1f             	xor    $0x1f,%eax
  8020bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020c2:	75 34                	jne    8020f8 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020c4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8020c7:	72 08                	jb     8020d1 <__udivdi3+0x75>
  8020c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8020cc:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8020cf:	77 7f                	ja     802150 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020d1:	b9 01 00 00 00       	mov    $0x1,%ecx
  8020d6:	31 c0                	xor    %eax,%eax
  8020d8:	eb c2                	jmp    80209c <__udivdi3+0x40>
  8020da:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	74 79                	je     80215c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8020e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020e6:	89 fa                	mov    %edi,%edx
  8020e8:	f7 f1                	div    %ecx
  8020ea:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8020ef:	f7 f1                	div    %ecx
  8020f1:	89 c1                	mov    %eax,%ecx
  8020f3:	89 f0                	mov    %esi,%eax
  8020f5:	eb a5                	jmp    80209c <__udivdi3+0x40>
  8020f7:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020f8:	b8 20 00 00 00       	mov    $0x20,%eax
  8020fd:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802100:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802103:	89 fa                	mov    %edi,%edx
  802105:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802108:	d3 e2                	shl    %cl,%edx
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802110:	d3 e8                	shr    %cl,%eax
  802112:	89 d7                	mov    %edx,%edi
  802114:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802116:	8b 75 f4             	mov    -0xc(%ebp),%esi
  802119:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80211c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80211e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802121:	d3 e0                	shl    %cl,%eax
  802123:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802126:	8a 4d f0             	mov    -0x10(%ebp),%cl
  802129:	d3 ea                	shr    %cl,%edx
  80212b:	09 d0                	or     %edx,%eax
  80212d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802130:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802133:	d3 ea                	shr    %cl,%edx
  802135:	f7 f7                	div    %edi
  802137:	89 d7                	mov    %edx,%edi
  802139:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  80213c:	f7 e6                	mul    %esi
  80213e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802140:	39 d7                	cmp    %edx,%edi
  802142:	72 38                	jb     80217c <__udivdi3+0x120>
  802144:	74 27                	je     80216d <__udivdi3+0x111>
  802146:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802149:	31 c0                	xor    %eax,%eax
  80214b:	e9 4c ff ff ff       	jmp    80209c <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802150:	31 c9                	xor    %ecx,%ecx
  802152:	31 c0                	xor    %eax,%eax
  802154:	e9 43 ff ff ff       	jmp    80209c <__udivdi3+0x40>
  802159:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80215c:	b8 01 00 00 00       	mov    $0x1,%eax
  802161:	31 d2                	xor    %edx,%edx
  802163:	f7 75 f4             	divl   -0xc(%ebp)
  802166:	89 c1                	mov    %eax,%ecx
  802168:	e9 76 ff ff ff       	jmp    8020e3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80216d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802170:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802173:	d3 e0                	shl    %cl,%eax
  802175:	39 f0                	cmp    %esi,%eax
  802177:	73 cd                	jae    802146 <__udivdi3+0xea>
  802179:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80217c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80217f:	49                   	dec    %ecx
  802180:	31 c0                	xor    %eax,%eax
  802182:	e9 15 ff ff ff       	jmp    80209c <__udivdi3+0x40>
	...

00802188 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	57                   	push   %edi
  80218c:	56                   	push   %esi
  80218d:	83 ec 30             	sub    $0x30,%esp
  802190:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  802197:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80219e:	8b 75 08             	mov    0x8(%ebp),%esi
  8021a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021a7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  8021aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021ad:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  8021af:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  8021b2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  8021b5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021b8:	85 d2                	test   %edx,%edx
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  8021bc:	89 fa                	mov    %edi,%edx
  8021be:	39 f8                	cmp    %edi,%eax
  8021c0:	0f 86 c2 00 00 00    	jbe    802288 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021c6:	89 f0                	mov    %esi,%eax
  8021c8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8021ca:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8021cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8021d4:	eb 12                	jmp    8021e8 <__umoddi3+0x60>
  8021d6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8021db:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8021de:	76 18                	jbe    8021f8 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8021e0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8021e3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8021e6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8021eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8021ee:	83 c4 30             	add    $0x30,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021f8:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8021fc:	83 f0 1f             	xor    $0x1f,%eax
  8021ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802202:	0f 84 ac 00 00 00    	je     8022b4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802208:	b8 20 00 00 00       	mov    $0x20,%eax
  80220d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  802210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802213:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802216:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802219:	d3 e2                	shl    %cl,%edx
  80221b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80221e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802221:	d3 e8                	shr    %cl,%eax
  802223:	89 d6                	mov    %edx,%esi
  802225:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  802227:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80222a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802232:	8b 7d f4             	mov    -0xc(%ebp),%edi
  802235:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802237:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223a:	d3 e0                	shl    %cl,%eax
  80223c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80223f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  802242:	d3 ea                	shr    %cl,%edx
  802244:	09 d0                	or     %edx,%eax
  802246:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802249:	d3 ea                	shr    %cl,%edx
  80224b:	f7 f6                	div    %esi
  80224d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  802250:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802253:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  802256:	0f 82 8d 00 00 00    	jb     8022e9 <__umoddi3+0x161>
  80225c:	0f 84 91 00 00 00    	je     8022f3 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802262:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802265:	29 c7                	sub    %eax,%edi
  802267:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802269:	89 f2                	mov    %esi,%edx
  80226b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  80226e:	d3 e2                	shl    %cl,%edx
  802270:	89 f8                	mov    %edi,%eax
  802272:	8a 4d dc             	mov    -0x24(%ebp),%cl
  802275:	d3 e8                	shr    %cl,%eax
  802277:	09 c2                	or     %eax,%edx
  802279:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  80227c:	d3 ee                	shr    %cl,%esi
  80227e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  802281:	e9 62 ff ff ff       	jmp    8021e8 <__umoddi3+0x60>
  802286:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802288:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80228b:	85 c0                	test   %eax,%eax
  80228d:	74 15                	je     8022a4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80228f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802292:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802295:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802297:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229a:	f7 f1                	div    %ecx
  80229c:	e9 29 ff ff ff       	jmp    8021ca <__umoddi3+0x42>
  8022a1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a9:	31 d2                	xor    %edx,%edx
  8022ab:	f7 75 ec             	divl   -0x14(%ebp)
  8022ae:	89 c1                	mov    %eax,%ecx
  8022b0:	eb dd                	jmp    80228f <__umoddi3+0x107>
  8022b2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022b7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  8022ba:	72 19                	jb     8022d5 <__umoddi3+0x14d>
  8022bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022bf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8022c2:	76 11                	jbe    8022d5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8022c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022c7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8022ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022cd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8022d0:	e9 13 ff ff ff       	jmp    8021e8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8022d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022db:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8022de:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8022e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8022e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8022e7:	eb db                	jmp    8022c4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022e9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8022ec:	19 f2                	sbb    %esi,%edx
  8022ee:	e9 6f ff ff ff       	jmp    802262 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022f3:	39 c7                	cmp    %eax,%edi
  8022f5:	72 f2                	jb     8022e9 <__umoddi3+0x161>
  8022f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022fa:	e9 63 ff ff ff       	jmp    802262 <__umoddi3+0xda>
