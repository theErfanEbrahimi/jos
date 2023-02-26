
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 03 1a 00 00       	call   801a34 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c3                	mov    %al,%bl
  80003a:	b9 f7 01 00 00       	mov    $0x1f7,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003f:	89 ca                	mov    %ecx,%edx
  800041:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800042:	0f b6 d0             	movzbl %al,%edx
  800045:	89 d0                	mov    %edx,%eax
  800047:	25 c0 00 00 00       	and    $0xc0,%eax
  80004c:	83 f8 40             	cmp    $0x40,%eax
  80004f:	75 ee                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800051:	84 db                	test   %bl,%bl
  800053:	74 0c                	je     800061 <ide_wait_ready+0x2d>
  800055:	f6 c2 21             	test   $0x21,%dl
  800058:	74 07                	je     800061 <ide_wait_ready+0x2d>
  80005a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80005f:	eb 05                	jmp    800066 <ide_wait_ready+0x32>
  800061:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  800066:	5b                   	pop    %ebx
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  800072:	83 f8 01             	cmp    $0x1,%eax
  800075:	76 14                	jbe    80008b <ide_set_disk+0x22>
		panic("bad disk number");
  800077:	83 ec 04             	sub    $0x4,%esp
  80007a:	68 00 38 80 00       	push   $0x803800
  80007f:	6a 3a                	push   $0x3a
  800081:	68 10 38 80 00       	push   $0x803810
  800086:	e8 0d 1a 00 00       	call   801a98 <_panic>
	diskno = d;
  80008b:	a3 00 50 80 00       	mov    %eax,0x805000
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <ide_probe_disk1>:
	return 0;
}

bool
ide_probe_disk1(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	53                   	push   %ebx
  800096:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800099:	b8 00 00 00 00       	mov    $0x0,%eax
  80009e:	e8 91 ff ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000a3:	b0 f0                	mov    $0xf0,%al
  8000a5:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000aa:	ee                   	out    %al,(%dx)
  8000ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000b0:	b2 f7                	mov    $0xf7,%dl
  8000b2:	eb 09                	jmp    8000bd <ide_probe_disk1+0x2b>
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  8000b4:	41                   	inc    %ecx
	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  8000b5:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  8000bb:	74 05                	je     8000c2 <ide_probe_disk1+0x30>

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8000bd:	ec                   	in     (%dx),%al
  8000be:	a8 a1                	test   $0xa1,%al
  8000c0:	75 f2                	jne    8000b4 <ide_probe_disk1+0x22>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000c2:	b0 e0                	mov    $0xe0,%al
  8000c4:	ba f6 01 00 00       	mov    $0x1f6,%edx
  8000c9:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000ca:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000d0:	0f 9e c0             	setle  %al
  8000d3:	0f b6 d8             	movzbl %al,%ebx
  8000d6:	83 ec 08             	sub    $0x8,%esp
  8000d9:	53                   	push   %ebx
  8000da:	68 19 38 80 00       	push   $0x803819
  8000df:	e8 55 1a 00 00       	call   801b39 <cprintf>
	return (x < 1000);
}
  8000e4:	89 d8                	mov    %ebx,%eax
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <ide_write>:
	return 0;
}

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8000f7:	81 7d 10 00 01 00 00 	cmpl   $0x100,0x10(%ebp)
  8000fe:	76 16                	jbe    800116 <ide_write+0x2b>
  800100:	68 30 38 80 00       	push   $0x803830
  800105:	68 3d 38 80 00       	push   $0x80383d
  80010a:	6a 5d                	push   $0x5d
  80010c:	68 10 38 80 00       	push   $0x803810
  800111:	e8 82 19 00 00       	call   801a98 <_panic>

	ide_wait_ready(0);
  800116:	b8 00 00 00 00       	mov    $0x0,%eax
  80011b:	e8 14 ff ff ff       	call   800034 <ide_wait_ready>
  800120:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800125:	8a 45 10             	mov    0x10(%ebp),%al
  800128:	ee                   	out    %al,(%dx)
  800129:	b2 f3                	mov    $0xf3,%dl
  80012b:	88 d8                	mov    %bl,%al
  80012d:	ee                   	out    %al,(%dx)
  80012e:	0f b6 c7             	movzbl %bh,%eax
  800131:	b2 f4                	mov    $0xf4,%dl
  800133:	ee                   	out    %al,(%dx)
  800134:	89 d8                	mov    %ebx,%eax
  800136:	c1 e8 10             	shr    $0x10,%eax
  800139:	b2 f5                	mov    $0xf5,%dl
  80013b:	ee                   	out    %al,(%dx)
  80013c:	89 d8                	mov    %ebx,%eax
  80013e:	c1 e8 18             	shr    $0x18,%eax
  800141:	88 c2                	mov    %al,%dl
  800143:	83 e2 0f             	and    $0xf,%edx
  800146:	a0 00 50 80 00       	mov    0x805000,%al
  80014b:	83 e0 01             	and    $0x1,%eax
  80014e:	c1 e0 04             	shl    $0x4,%eax
  800151:	83 c8 e0             	or     $0xffffffe0,%eax
  800154:	09 d0                	or     %edx,%eax
  800156:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80015b:	ee                   	out    %al,(%dx)
  80015c:	b0 30                	mov    $0x30,%al
  80015e:	b2 f7                	mov    $0xf7,%dl
  800160:	ee                   	out    %al,(%dx)
  800161:	bf f0 01 00 00       	mov    $0x1f0,%edi
  800166:	bb 80 00 00 00       	mov    $0x80,%ebx
  80016b:	eb 22                	jmp    80018f <ide_write+0xa4>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80016d:	b8 01 00 00 00       	mov    $0x1,%eax
  800172:	e8 bd fe ff ff       	call   800034 <ide_wait_ready>
  800177:	85 c0                	test   %eax,%eax
  800179:	78 1f                	js     80019a <ide_write+0xaf>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80017b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80017e:	89 d9                	mov    %ebx,%ecx
  800180:	89 fa                	mov    %edi,%edx
  800182:	fc                   	cld    
  800183:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800185:	ff 4d 10             	decl   0x10(%ebp)
  800188:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  80018f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800193:	75 d8                	jne    80016d <ide_write+0x82>
  800195:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80019a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <ide_read>:
}


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001ae:	81 7d 10 00 01 00 00 	cmpl   $0x100,0x10(%ebp)
  8001b5:	76 16                	jbe    8001cd <ide_read+0x2b>
  8001b7:	68 30 38 80 00       	push   $0x803830
  8001bc:	68 3d 38 80 00       	push   $0x80383d
  8001c1:	6a 44                	push   $0x44
  8001c3:	68 10 38 80 00       	push   $0x803810
  8001c8:	e8 cb 18 00 00       	call   801a98 <_panic>

	ide_wait_ready(0);
  8001cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d2:	e8 5d fe ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001d7:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001dc:	8a 45 10             	mov    0x10(%ebp),%al
  8001df:	ee                   	out    %al,(%dx)
  8001e0:	b2 f3                	mov    $0xf3,%dl
  8001e2:	88 d8                	mov    %bl,%al
  8001e4:	ee                   	out    %al,(%dx)
  8001e5:	0f b6 c7             	movzbl %bh,%eax
  8001e8:	b2 f4                	mov    $0xf4,%dl
  8001ea:	ee                   	out    %al,(%dx)
  8001eb:	89 d8                	mov    %ebx,%eax
  8001ed:	c1 e8 10             	shr    $0x10,%eax
  8001f0:	b2 f5                	mov    $0xf5,%dl
  8001f2:	ee                   	out    %al,(%dx)
  8001f3:	89 d8                	mov    %ebx,%eax
  8001f5:	c1 e8 18             	shr    $0x18,%eax
  8001f8:	88 c2                	mov    %al,%dl
  8001fa:	83 e2 0f             	and    $0xf,%edx
  8001fd:	a0 00 50 80 00       	mov    0x805000,%al
  800202:	83 e0 01             	and    $0x1,%eax
  800205:	c1 e0 04             	shl    $0x4,%eax
  800208:	83 c8 e0             	or     $0xffffffe0,%eax
  80020b:	09 d0                	or     %edx,%eax
  80020d:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800212:	ee                   	out    %al,(%dx)
  800213:	b0 20                	mov    $0x20,%al
  800215:	b2 f7                	mov    $0xf7,%dl
  800217:	ee                   	out    %al,(%dx)
  800218:	be f0 01 00 00       	mov    $0x1f0,%esi
  80021d:	bb 80 00 00 00       	mov    $0x80,%ebx
  800222:	eb 22                	jmp    800246 <ide_read+0xa4>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800224:	b8 01 00 00 00       	mov    $0x1,%eax
  800229:	e8 06 fe ff ff       	call   800034 <ide_wait_ready>
  80022e:	85 c0                	test   %eax,%eax
  800230:	78 1f                	js     800251 <ide_read+0xaf>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  800232:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800235:	89 d9                	mov    %ebx,%ecx
  800237:	89 f2                	mov    %esi,%edx
  800239:	fc                   	cld    
  80023a:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80023c:	ff 4d 10             	decl   0x10(%ebp)
  80023f:	81 45 0c 00 02 00 00 	addl   $0x200,0xc(%ebp)
  800246:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80024a:	75 d8                	jne    800224 <ide_read+0x82>
  80024c:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
}
  800251:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800254:	5b                   	pop    %ebx
  800255:	5e                   	pop    %esi
  800256:	5f                   	pop    %edi
  800257:	c9                   	leave  
  800258:	c3                   	ret    
  800259:	00 00                	add    %al,(%eax)
	...

0080025c <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	89 d0                	mov    %edx,%eax
  800264:	c1 e8 16             	shr    $0x16,%eax
  800267:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80026e:	a8 01                	test   $0x1,%al
  800270:	75 07                	jne    800279 <va_is_mapped+0x1d>
  800272:	b8 00 00 00 00       	mov    $0x0,%eax
  800277:	eb 0f                	jmp    800288 <va_is_mapped+0x2c>
  800279:	89 d0                	mov    %edx,%eax
  80027b:	c1 e8 0c             	shr    $0xc,%eax
  80027e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800285:	83 e0 01             	and    $0x1,%eax
  800288:	0f b6 c0             	movzbl %al,%eax
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	c1 e8 0c             	shr    $0xc,%eax
  800296:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80029d:	c1 e8 06             	shr    $0x6,%eax
  8002a0:	83 e0 01             	and    $0x1,%eax
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	74 0f                	je     8002c1 <diskaddr+0x1c>
  8002b2:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8002b8:	85 d2                	test   %edx,%edx
  8002ba:	74 17                	je     8002d3 <diskaddr+0x2e>
  8002bc:	3b 42 04             	cmp    0x4(%edx),%eax
  8002bf:	72 12                	jb     8002d3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8002c1:	50                   	push   %eax
  8002c2:	68 54 38 80 00       	push   $0x803854
  8002c7:	6a 09                	push   $0x9
  8002c9:	68 5c 39 80 00       	push   $0x80395c
  8002ce:	e8 c5 17 00 00       	call   801a98 <_panic>
  8002d3:	c1 e0 0c             	shl    $0xc,%eax
  8002d6:	05 00 00 00 10       	add    $0x10000000,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  8002e5:	8b 11                	mov    (%ecx),%edx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8002e7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  8002ed:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8002f2:	76 1b                	jbe    80030f <bc_pgfault+0x32>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	ff 71 04             	pushl  0x4(%ecx)
  8002fa:	52                   	push   %edx
  8002fb:	ff 71 28             	pushl  0x28(%ecx)
  8002fe:	68 78 38 80 00       	push   $0x803878
  800303:	6a 27                	push   $0x27
  800305:	68 5c 39 80 00       	push   $0x80395c
  80030a:	e8 89 17 00 00       	call   801a98 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80030f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  800315:	89 c6                	mov    %eax,%esi
  800317:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80031a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80031f:	85 c0                	test   %eax,%eax
  800321:	74 17                	je     80033a <bc_pgfault+0x5d>
  800323:	3b 70 04             	cmp    0x4(%eax),%esi
  800326:	72 12                	jb     80033a <bc_pgfault+0x5d>
		panic("reading non-existent block %08x\n", blockno);
  800328:	56                   	push   %esi
  800329:	68 a8 38 80 00       	push   $0x8038a8
  80032e:	6a 2b                	push   $0x2b
  800330:	68 5c 39 80 00       	push   $0x80395c
  800335:	e8 5e 17 00 00       	call   801a98 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr, PGSIZE);
  80033a:	89 d3                	mov    %edx,%ebx
  80033c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, addr, PTE_W|PTE_U|PTE_P);
  800342:	83 ec 04             	sub    $0x4,%esp
  800345:	6a 07                	push   $0x7
  800347:	53                   	push   %ebx
  800348:	6a 00                	push   $0x0
  80034a:	e8 52 22 00 00       	call   8025a1 <sys_page_alloc>
	if((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  80034f:	83 c4 0c             	add    $0xc,%esp
  800352:	6a 08                	push   $0x8
  800354:	53                   	push   %ebx
  800355:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  80035c:	50                   	push   %eax
  80035d:	e8 40 fe ff ff       	call   8001a2 <ide_read>
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	85 c0                	test   %eax,%eax
  800367:	79 12                	jns    80037b <bc_pgfault+0x9e>
		panic("ide_read: %e", r);
  800369:	50                   	push   %eax
  80036a:	68 64 39 80 00       	push   $0x803964
  80036f:	6a 36                	push   $0x36
  800371:	68 5c 39 80 00       	push   $0x80395c
  800376:	e8 1d 17 00 00       	call   801a98 <_panic>
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80037b:	89 d8                	mov    %ebx,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
  800380:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800387:	83 ec 0c             	sub    $0xc,%esp
  80038a:	25 07 0e 00 00       	and    $0xe07,%eax
  80038f:	50                   	push   %eax
  800390:	53                   	push   %ebx
  800391:	6a 00                	push   $0x0
  800393:	53                   	push   %ebx
  800394:	6a 00                	push   $0x0
  800396:	e8 c4 21 00 00       	call   80255f <sys_page_map>
  80039b:	83 c4 20             	add    $0x20,%esp
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	79 12                	jns    8003b4 <bc_pgfault+0xd7>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8003a2:	50                   	push   %eax
  8003a3:	68 cc 38 80 00       	push   $0x8038cc
  8003a8:	6a 3a                	push   $0x3a
  8003aa:	68 5c 39 80 00       	push   $0x80395c
  8003af:	e8 e4 16 00 00       	call   801a98 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003b4:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003bb:	74 22                	je     8003df <bc_pgfault+0x102>
  8003bd:	83 ec 0c             	sub    $0xc,%esp
  8003c0:	56                   	push   %esi
  8003c1:	e8 aa 03 00 00       	call   800770 <block_is_free>
  8003c6:	83 c4 10             	add    $0x10,%esp
  8003c9:	84 c0                	test   %al,%al
  8003cb:	74 12                	je     8003df <bc_pgfault+0x102>
		panic("reading free block %08x\n", blockno);
  8003cd:	56                   	push   %esi
  8003ce:	68 71 39 80 00       	push   $0x803971
  8003d3:	6a 40                	push   $0x40
  8003d5:	68 5c 39 80 00       	push   $0x80395c
  8003da:	e8 b9 16 00 00       	call   801a98 <_panic>
}
  8003df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003ee:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  8003f4:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8003f9:	76 12                	jbe    80040d <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  8003fb:	56                   	push   %esi
  8003fc:	68 8a 39 80 00       	push   $0x80398a
  800401:	6a 50                	push   $0x50
  800403:	68 5c 39 80 00       	push   $0x80395c
  800408:	e8 8b 16 00 00       	call   801a98 <_panic>

	// LAB 5: Your code here.
	int r;
	addr = ROUNDDOWN(addr, PGSIZE);//hint
  80040d:	89 f3                	mov    %esi,%ebx
  80040f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(!va_is_mapped(addr) || !va_is_dirty(addr))return;//hint
  800415:	53                   	push   %ebx
  800416:	e8 41 fe ff ff       	call   80025c <va_is_mapped>
  80041b:	83 c4 04             	add    $0x4,%esp
  80041e:	84 c0                	test   %al,%al
  800420:	74 77                	je     800499 <flush_block+0xb3>
  800422:	53                   	push   %ebx
  800423:	e8 65 fe ff ff       	call   80028d <va_is_dirty>
  800428:	83 c4 04             	add    $0x4,%esp
  80042b:	84 c0                	test   %al,%al
  80042d:	74 6a                	je     800499 <flush_block+0xb3>
	if((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  80042f:	83 ec 04             	sub    $0x4,%esp
  800432:	6a 08                	push   $0x8
  800434:	53                   	push   %ebx
  800435:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  80043b:	c1 e8 0c             	shr    $0xc,%eax
  80043e:	c1 e0 03             	shl    $0x3,%eax
  800441:	50                   	push   %eax
  800442:	e8 a4 fc ff ff       	call   8000eb <ide_write>
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	85 c0                	test   %eax,%eax
  80044c:	79 12                	jns    800460 <flush_block+0x7a>
		panic("flush_block: ide_write failed! %e\n", r);
  80044e:	50                   	push   %eax
  80044f:	68 ec 38 80 00       	push   $0x8038ec
  800454:	6a 57                	push   $0x57
  800456:	68 5c 39 80 00       	push   $0x80395c
  80045b:	e8 38 16 00 00       	call   801a98 <_panic>
	if((r = sys_page_map(0,addr,0,addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)//hint
  800460:	89 d8                	mov    %ebx,%eax
  800462:	c1 e8 0c             	shr    $0xc,%eax
  800465:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80046c:	83 ec 0c             	sub    $0xc,%esp
  80046f:	25 07 0e 00 00       	and    $0xe07,%eax
  800474:	50                   	push   %eax
  800475:	53                   	push   %ebx
  800476:	6a 00                	push   $0x0
  800478:	53                   	push   %ebx
  800479:	6a 00                	push   $0x0
  80047b:	e8 df 20 00 00       	call   80255f <sys_page_map>
  800480:	83 c4 20             	add    $0x20,%esp
  800483:	85 c0                	test   %eax,%eax
  800485:	79 12                	jns    800499 <flush_block+0xb3>
		panic("flush_block: sys_page_map failed! %e\n",r);
  800487:	50                   	push   %eax
  800488:	68 10 39 80 00       	push   $0x803910
  80048d:	6a 59                	push   $0x59
  80048f:	68 5c 39 80 00       	push   $0x80395c
  800494:	e8 ff 15 00 00       	call   801a98 <_panic>

}
  800499:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	53                   	push   %ebx
  8004a4:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004aa:	68 dd 02 80 00       	push   $0x8002dd
  8004af:	e8 b0 21 00 00       	call   802664 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004bb:	e8 e5 fd ff ff       	call   8002a5 <diskaddr>
  8004c0:	83 c4 0c             	add    $0xc,%esp
  8004c3:	68 08 01 00 00       	push   $0x108
  8004c8:	50                   	push   %eax
  8004c9:	8d 85 ec fd ff ff    	lea    -0x214(%ebp),%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 23 1d 00 00       	call   8021f8 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004dc:	e8 c4 fd ff ff       	call   8002a5 <diskaddr>
  8004e1:	83 c4 08             	add    $0x8,%esp
  8004e4:	68 a5 39 80 00       	push   $0x8039a5
  8004e9:	50                   	push   %eax
  8004ea:	e8 9c 1b 00 00       	call   80208b <strcpy>
	flush_block(diskaddr(1));
  8004ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004f6:	e8 aa fd ff ff       	call   8002a5 <diskaddr>
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	e8 e3 fe ff ff       	call   8003e6 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800503:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050a:	e8 96 fd ff ff       	call   8002a5 <diskaddr>
  80050f:	50                   	push   %eax
  800510:	e8 47 fd ff ff       	call   80025c <va_is_mapped>
  800515:	83 c4 14             	add    $0x14,%esp
  800518:	84 c0                	test   %al,%al
  80051a:	75 16                	jne    800532 <bc_init+0x92>
  80051c:	68 c7 39 80 00       	push   $0x8039c7
  800521:	68 3d 38 80 00       	push   $0x80383d
  800526:	6a 6a                	push   $0x6a
  800528:	68 5c 39 80 00       	push   $0x80395c
  80052d:	e8 66 15 00 00       	call   801a98 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	6a 01                	push   $0x1
  800537:	e8 69 fd ff ff       	call   8002a5 <diskaddr>
  80053c:	50                   	push   %eax
  80053d:	e8 4b fd ff ff       	call   80028d <va_is_dirty>
  800542:	83 c4 14             	add    $0x14,%esp
  800545:	84 c0                	test   %al,%al
  800547:	74 16                	je     80055f <bc_init+0xbf>
  800549:	68 ac 39 80 00       	push   $0x8039ac
  80054e:	68 3d 38 80 00       	push   $0x80383d
  800553:	6a 6b                	push   $0x6b
  800555:	68 5c 39 80 00       	push   $0x80395c
  80055a:	e8 39 15 00 00       	call   801a98 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	6a 01                	push   $0x1
  800564:	e8 3c fd ff ff       	call   8002a5 <diskaddr>
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	50                   	push   %eax
  80056d:	6a 00                	push   $0x0
  80056f:	e8 a9 1f 00 00       	call   80251d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057b:	e8 25 fd ff ff       	call   8002a5 <diskaddr>
  800580:	50                   	push   %eax
  800581:	e8 d6 fc ff ff       	call   80025c <va_is_mapped>
  800586:	83 c4 14             	add    $0x14,%esp
  800589:	84 c0                	test   %al,%al
  80058b:	74 16                	je     8005a3 <bc_init+0x103>
  80058d:	68 c6 39 80 00       	push   $0x8039c6
  800592:	68 3d 38 80 00       	push   $0x80383d
  800597:	6a 6f                	push   $0x6f
  800599:	68 5c 39 80 00       	push   $0x80395c
  80059e:	e8 f5 14 00 00       	call   801a98 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005a3:	83 ec 0c             	sub    $0xc,%esp
  8005a6:	6a 01                	push   $0x1
  8005a8:	e8 f8 fc ff ff       	call   8002a5 <diskaddr>
  8005ad:	83 c4 08             	add    $0x8,%esp
  8005b0:	68 a5 39 80 00       	push   $0x8039a5
  8005b5:	50                   	push   %eax
  8005b6:	e8 63 1b 00 00       	call   80211e <strcmp>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	74 16                	je     8005d8 <bc_init+0x138>
  8005c2:	68 38 39 80 00       	push   $0x803938
  8005c7:	68 3d 38 80 00       	push   $0x80383d
  8005cc:	6a 72                	push   $0x72
  8005ce:	68 5c 39 80 00       	push   $0x80395c
  8005d3:	e8 c0 14 00 00       	call   801a98 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	6a 01                	push   $0x1
  8005dd:	e8 c3 fc ff ff       	call   8002a5 <diskaddr>
  8005e2:	83 c4 0c             	add    $0xc,%esp
  8005e5:	68 08 01 00 00       	push   $0x108
  8005ea:	8d 9d ec fd ff ff    	lea    -0x214(%ebp),%ebx
  8005f0:	53                   	push   %ebx
  8005f1:	50                   	push   %eax
  8005f2:	e8 01 1c 00 00       	call   8021f8 <memmove>
	flush_block(diskaddr(1));
  8005f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005fe:	e8 a2 fc ff ff       	call   8002a5 <diskaddr>
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 db fd ff ff       	call   8003e6 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80060b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800612:	e8 8e fc ff ff       	call   8002a5 <diskaddr>
  800617:	83 c4 0c             	add    $0xc,%esp
  80061a:	68 08 01 00 00       	push   $0x108
  80061f:	50                   	push   %eax
  800620:	53                   	push   %ebx
  800621:	e8 d2 1b 00 00       	call   8021f8 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800626:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062d:	e8 73 fc ff ff       	call   8002a5 <diskaddr>
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	68 a5 39 80 00       	push   $0x8039a5
  80063a:	50                   	push   %eax
  80063b:	e8 4b 1a 00 00       	call   80208b <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800640:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800647:	e8 59 fc ff ff       	call   8002a5 <diskaddr>
  80064c:	83 c0 14             	add    $0x14,%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 8f fd ff ff       	call   8003e6 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800657:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80065e:	e8 42 fc ff ff       	call   8002a5 <diskaddr>
  800663:	50                   	push   %eax
  800664:	e8 f3 fb ff ff       	call   80025c <va_is_mapped>
  800669:	83 c4 14             	add    $0x14,%esp
  80066c:	84 c0                	test   %al,%al
  80066e:	75 19                	jne    800689 <bc_init+0x1e9>
  800670:	68 c7 39 80 00       	push   $0x8039c7
  800675:	68 3d 38 80 00       	push   $0x80383d
  80067a:	68 83 00 00 00       	push   $0x83
  80067f:	68 5c 39 80 00       	push   $0x80395c
  800684:	e8 0f 14 00 00       	call   801a98 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800689:	83 ec 0c             	sub    $0xc,%esp
  80068c:	6a 01                	push   $0x1
  80068e:	e8 12 fc ff ff       	call   8002a5 <diskaddr>
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	50                   	push   %eax
  800697:	6a 00                	push   $0x0
  800699:	e8 7f 1e 00 00       	call   80251d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80069e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a5:	e8 fb fb ff ff       	call   8002a5 <diskaddr>
  8006aa:	50                   	push   %eax
  8006ab:	e8 ac fb ff ff       	call   80025c <va_is_mapped>
  8006b0:	83 c4 14             	add    $0x14,%esp
  8006b3:	84 c0                	test   %al,%al
  8006b5:	74 19                	je     8006d0 <bc_init+0x230>
  8006b7:	68 c6 39 80 00       	push   $0x8039c6
  8006bc:	68 3d 38 80 00       	push   $0x80383d
  8006c1:	68 8b 00 00 00       	push   $0x8b
  8006c6:	68 5c 39 80 00       	push   $0x80395c
  8006cb:	e8 c8 13 00 00       	call   801a98 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	6a 01                	push   $0x1
  8006d5:	e8 cb fb ff ff       	call   8002a5 <diskaddr>
  8006da:	83 c4 08             	add    $0x8,%esp
  8006dd:	68 a5 39 80 00       	push   $0x8039a5
  8006e2:	50                   	push   %eax
  8006e3:	e8 36 1a 00 00       	call   80211e <strcmp>
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 19                	je     800708 <bc_init+0x268>
  8006ef:	68 38 39 80 00       	push   $0x803938
  8006f4:	68 3d 38 80 00       	push   $0x80383d
  8006f9:	68 8e 00 00 00       	push   $0x8e
  8006fe:	68 5c 39 80 00       	push   $0x80395c
  800703:	e8 90 13 00 00       	call   801a98 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800708:	83 ec 0c             	sub    $0xc,%esp
  80070b:	6a 01                	push   $0x1
  80070d:	e8 93 fb ff ff       	call   8002a5 <diskaddr>
  800712:	83 c4 0c             	add    $0xc,%esp
  800715:	68 08 01 00 00       	push   $0x108
  80071a:	8d 95 ec fd ff ff    	lea    -0x214(%ebp),%edx
  800720:	52                   	push   %edx
  800721:	50                   	push   %eax
  800722:	e8 d1 1a 00 00       	call   8021f8 <memmove>
	flush_block(diskaddr(1));
  800727:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80072e:	e8 72 fb ff ff       	call   8002a5 <diskaddr>
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	e8 ab fc ff ff       	call   8003e6 <flush_block>

	cprintf("block cache is good\n");
  80073b:	c7 04 24 e1 39 80 00 	movl   $0x8039e1,(%esp)
  800742:	e8 f2 13 00 00       	call   801b39 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800747:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80074e:	e8 52 fb ff ff       	call   8002a5 <diskaddr>
  800753:	83 c4 0c             	add    $0xc,%esp
  800756:	68 08 01 00 00       	push   $0x108
  80075b:	50                   	push   %eax
  80075c:	8d 85 f4 fe ff ff    	lea    -0x10c(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	e8 90 1a 00 00       	call   8021f8 <memmove>
  800768:	83 c4 10             	add    $0x10,%esp
}
  80076b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 55 08             	mov    0x8(%ebp),%edx
	if (super == 0 || blockno >= super->s_nblocks)
  800777:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 27                	je     8007a7 <block_is_free+0x37>
  800780:	39 50 04             	cmp    %edx,0x4(%eax)
  800783:	76 22                	jbe    8007a7 <block_is_free+0x37>
  800785:	89 d3                	mov    %edx,%ebx
  800787:	c1 eb 05             	shr    $0x5,%ebx
  80078a:	89 d1                	mov    %edx,%ecx
  80078c:	83 e1 1f             	and    $0x1f,%ecx
  80078f:	b8 01 00 00 00       	mov    $0x1,%eax
  800794:	d3 e0                	shl    %cl,%eax
  800796:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80079c:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80079f:	0f 95 c0             	setne  %al
  8007a2:	0f b6 c0             	movzbl %al,%eax
  8007a5:	eb 05                	jmp    8007ac <block_is_free+0x3c>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	eb 01                	jmp    8007b5 <skip_slash+0x6>
	while (*p == '/')
		p++;
  8007b4:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8007b5:	80 38 2f             	cmpb   $0x2f,(%eax)
  8007b8:	74 fa                	je     8007b4 <skip_slash+0x5>
		p++;
	return p;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 04             	sub    $0x4,%esp
  8007c3:	bb 01 00 00 00       	mov    $0x1,%ebx
  8007c8:	eb 15                	jmp    8007df <fs_sync+0x23>
	int i;
	for (i = 1; i < super->s_nblocks; i++)
		flush_block(diskaddr(i));
  8007ca:	83 ec 0c             	sub    $0xc,%esp
  8007cd:	52                   	push   %edx
  8007ce:	e8 d2 fa ff ff       	call   8002a5 <diskaddr>
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 0b fc ff ff       	call   8003e6 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8007db:	43                   	inc    %ebx
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 da                	mov    %ebx,%edx
  8007e1:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007e6:	39 58 04             	cmp    %ebx,0x4(%eax)
  8007e9:	77 df                	ja     8007ca <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  8007eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//search bitmap
	for(uint32_t i = 3; i < super->s_nblocks; ++i){
  8007f5:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007fa:	8b 58 04             	mov    0x4(%eax),%ebx
  8007fd:	be 03 00 00 00       	mov    $0x3,%esi
  800802:	eb 40                	jmp    800844 <alloc_block+0x54>
		if(block_is_free(i)){
  800804:	56                   	push   %esi
  800805:	e8 66 ff ff ff       	call   800770 <block_is_free>
  80080a:	83 c4 04             	add    $0x4,%esp
  80080d:	84 c0                	test   %al,%al
  80080f:	74 32                	je     800843 <alloc_block+0x53>
			bitmap[i/32] &= ~(1 << (i%32));
  800811:	89 f2                	mov    %esi,%edx
  800813:	c1 ea 05             	shr    $0x5,%edx
  800816:	c1 e2 02             	shl    $0x2,%edx
  800819:	89 d3                	mov    %edx,%ebx
  80081b:	03 1d 04 a0 80 00    	add    0x80a004,%ebx
  800821:	89 f1                	mov    %esi,%ecx
  800823:	83 e1 1f             	and    $0x1f,%ecx
  800826:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  80082b:	d3 c0                	rol    %cl,%eax
  80082d:	21 03                	and    %eax,(%ebx)
			flush_block(&bitmap[i/32]);
  80082f:	83 ec 0c             	sub    $0xc,%esp
  800832:	03 15 04 a0 80 00    	add    0x80a004,%edx
  800838:	52                   	push   %edx
  800839:	e8 a8 fb ff ff       	call   8003e6 <flush_block>
			return i;
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	eb 0a                	jmp    80084d <alloc_block+0x5d>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//search bitmap
	for(uint32_t i = 3; i < super->s_nblocks; ++i){
  800843:	46                   	inc    %esi
  800844:	39 de                	cmp    %ebx,%esi
  800846:	72 bc                	jb     800804 <alloc_block+0x14>
  800848:	be f7 ff ff ff       	mov    $0xfffffff7,%esi
			flush_block(&bitmap[i/32]);
			return i;
		}
	}
	return -E_NO_DISK;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	83 ec 0c             	sub    $0xc,%esp
  80085f:	89 c7                	mov    %eax,%edi
  800861:	89 d3                	mov    %edx,%ebx
  800863:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800866:	8a 45 08             	mov    0x8(%ebp),%al
       // LAB 5: Your code here.
	//3 bad walk
	if(filebno >= NDIRECT + NINDIRECT)return -E_INVAL;
  800869:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80086f:	76 0a                	jbe    80087b <file_block_walk+0x25>
  800871:	be fd ff ff ff       	mov    $0xfffffffd,%esi
  800876:	e9 83 00 00 00       	jmp    8008fe <file_block_walk+0xa8>
	if(filebno < NDIRECT){
  80087b:	83 fa 09             	cmp    $0x9,%edx
  80087e:	77 13                	ja     800893 <file_block_walk+0x3d>
		*ppdiskbno = f->f_direct + filebno;
  800880:	8d 84 97 88 00 00 00 	lea    0x88(%edi,%edx,4),%eax
  800887:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80088a:	89 02                	mov    %eax,(%edx)
  80088c:	be 00 00 00 00       	mov    $0x0,%esi
  800891:	eb 6b                	jmp    8008fe <file_block_walk+0xa8>
	}else{
		if(alloc && (f->f_indirect == 0)){
  800893:	84 c0                	test   %al,%al
  800895:	74 38                	je     8008cf <file_block_walk+0x79>
  800897:	83 bf b0 00 00 00 00 	cmpl   $0x0,0xb0(%edi)
  80089e:	75 3f                	jne    8008df <file_block_walk+0x89>
			int r;
			if((r = alloc_block()) < 0)return r;
  8008a0:	e8 4b ff ff ff       	call   8007f0 <alloc_block>
  8008a5:	89 c6                	mov    %eax,%esi
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 53                	js     8008fe <file_block_walk+0xa8>
			memset(diskaddr(r), 0, BLKSIZE);
  8008ab:	83 ec 0c             	sub    $0xc,%esp
  8008ae:	50                   	push   %eax
  8008af:	e8 f1 f9 ff ff       	call   8002a5 <diskaddr>
  8008b4:	83 c4 0c             	add    $0xc,%esp
  8008b7:	68 00 10 00 00       	push   $0x1000
  8008bc:	6a 00                	push   $0x0
  8008be:	50                   	push   %eax
  8008bf:	e8 e4 18 00 00       	call   8021a8 <memset>
			f->f_indirect = r;
  8008c4:	89 b7 b0 00 00 00    	mov    %esi,0xb0(%edi)
	//3 bad walk
	if(filebno >= NDIRECT + NINDIRECT)return -E_INVAL;
	if(filebno < NDIRECT){
		*ppdiskbno = f->f_direct + filebno;
	}else{
		if(alloc && (f->f_indirect == 0)){
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	eb 10                	jmp    8008df <file_block_walk+0x89>
			int r;
			if((r = alloc_block()) < 0)return r;
			memset(diskaddr(r), 0, BLKSIZE);
			f->f_indirect = r;
		}else if(f->f_indirect == 0){
  8008cf:	83 bf b0 00 00 00 00 	cmpl   $0x0,0xb0(%edi)
  8008d6:	75 07                	jne    8008df <file_block_walk+0x89>
  8008d8:	be f5 ff ff ff       	mov    $0xfffffff5,%esi
  8008dd:	eb 1f                	jmp    8008fe <file_block_walk+0xa8>
			return -E_NOT_FOUND;
		}
		//set *ppdiskbno
		*ppdiskbno = ((uint32_t*)diskaddr(f->f_indirect)) + filebno - NDIRECT;//diskaddr return char*
  8008df:	83 ec 0c             	sub    $0xc,%esp
  8008e2:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  8008e8:	e8 b8 f9 ff ff       	call   8002a5 <diskaddr>
  8008ed:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8008f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008f4:	89 02                	mov    %eax,(%edx)
  8008f6:	be 00 00 00 00       	mov    $0x0,%esi
  8008fb:	83 c4 10             	add    $0x10,%esp
	
		//return 0 success
	return 0;


}
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	83 ec 10             	sub    $0x10,%esp
  800910:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800913:	be 00 00 00 00       	mov    $0x0,%esi
  800918:	eb 3a                	jmp    800954 <file_flush+0x4c>
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800920:	6a 00                	push   $0x0
  800922:	89 f2                	mov    %esi,%edx
  800924:	89 d8                	mov    %ebx,%eax
  800926:	e8 2b ff ff ff       	call   800856 <file_block_walk>
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	85 c0                	test   %eax,%eax
  800930:	78 21                	js     800953 <file_flush+0x4b>
  800932:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800935:	85 c0                	test   %eax,%eax
  800937:	74 1a                	je     800953 <file_flush+0x4b>
  800939:	8b 00                	mov    (%eax),%eax
  80093b:	85 c0                	test   %eax,%eax
  80093d:	74 14                	je     800953 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  80093f:	83 ec 0c             	sub    $0xc,%esp
  800942:	50                   	push   %eax
  800943:	e8 5d f9 ff ff       	call   8002a5 <diskaddr>
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 96 fa ff ff       	call   8003e6 <flush_block>
  800950:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800953:	46                   	inc    %esi
  800954:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80095a:	05 ff 0f 00 00       	add    $0xfff,%eax
  80095f:	79 05                	jns    800966 <file_flush+0x5e>
  800961:	05 ff 0f 00 00       	add    $0xfff,%eax
  800966:	c1 f8 0c             	sar    $0xc,%eax
  800969:	39 c6                	cmp    %eax,%esi
  80096b:	7c ad                	jl     80091a <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  80096d:	83 ec 0c             	sub    $0xc,%esp
  800970:	53                   	push   %ebx
  800971:	e8 70 fa ff ff       	call   8003e6 <flush_block>
	if (f->f_indirect)
  800976:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	85 c0                	test   %eax,%eax
  800981:	74 14                	je     800997 <file_flush+0x8f>
		flush_block(diskaddr(f->f_indirect));
  800983:	83 ec 0c             	sub    $0xc,%esp
  800986:	50                   	push   %eax
  800987:	e8 19 f9 ff ff       	call   8002a5 <diskaddr>
  80098c:	89 04 24             	mov    %eax,(%esp)
  80098f:	e8 52 fa ff ff       	call   8003e6 <flush_block>
  800994:	83 c4 10             	add    $0x10,%esp
}
  800997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 20             	sub    $0x20,%esp
       // LAB 5: Your code here.
	uint32_t *pdiskbno;
	int r;
	if((r = file_block_walk(f, filebno, &pdiskbno, 1) < 0))return r;
  8009a5:	8d 4d f8             	lea    -0x8(%ebp),%ecx
  8009a8:	6a 01                	push   $0x1
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	e8 a1 fe ff ff       	call   800856 <file_block_walk>
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	89 c3                	mov    %eax,%ebx
  8009ba:	c1 eb 1f             	shr    $0x1f,%ebx
  8009bd:	75 39                	jne    8009f8 <file_get_block+0x5a>

	if(*pdiskbno == 0){
  8009bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8009c2:	83 38 00             	cmpl   $0x0,(%eax)
  8009c5:	75 14                	jne    8009db <file_get_block+0x3d>
		if((r = alloc_block()) < 0)return r;
  8009c7:	e8 24 fe ff ff       	call   8007f0 <alloc_block>
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	79 04                	jns    8009d6 <file_get_block+0x38>
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	eb 22                	jmp    8009f8 <file_get_block+0x5a>

		*pdiskbno = r;
  8009d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8009d9:	89 10                	mov    %edx,(%eax)
	}
	*blk = (char*)diskaddr(*pdiskbno);
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8009e1:	ff 30                	pushl  (%eax)
  8009e3:	e8 bd f8 ff ff       	call   8002a5 <diskaddr>
  8009e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8009eb:	89 02                	mov    %eax,(%edx)
	flush_block(*blk);
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 f1 f9 ff ff       	call   8003e6 <flush_block>
  8009f5:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  8009f8:	89 d8                	mov    %ebx,%eax
  8009fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	83 ec 1c             	sub    $0x1c,%esp
  800a08:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a0b:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800a0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a11:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800a17:	39 d0                	cmp    %edx,%eax
  800a19:	7f 0a                	jg     800a25 <file_read+0x26>
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	e9 86 00 00 00       	jmp    800aab <file_read+0xac>
		return 0;

	count = MIN(count, f->f_size - offset);
  800a25:	29 d0                	sub    %edx,%eax
  800a27:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a2a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800a2d:	39 c1                	cmp    %eax,%ecx
  800a2f:	76 03                	jbe    800a34 <file_read+0x35>
  800a31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a34:	89 d6                	mov    %edx,%esi
  800a36:	03 55 e0             	add    -0x20(%ebp),%edx
  800a39:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a3c:	eb 63                	jmp    800aa1 <file_read+0xa2>

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800a3e:	83 ec 04             	sub    $0x4,%esp
  800a41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a44:	50                   	push   %eax
  800a45:	89 f0                	mov    %esi,%eax
  800a47:	85 f6                	test   %esi,%esi
  800a49:	79 06                	jns    800a51 <file_read+0x52>
  800a4b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800a51:	c1 f8 0c             	sar    $0xc,%eax
  800a54:	50                   	push   %eax
  800a55:	ff 75 08             	pushl  0x8(%ebp)
  800a58:	e8 41 ff ff ff       	call   80099e <file_get_block>
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 47                	js     800aab <file_read+0xac>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800a6b:	79 07                	jns    800a74 <file_read+0x75>
  800a6d:	48                   	dec    %eax
  800a6e:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800a73:	40                   	inc    %eax
  800a74:	89 c2                	mov    %eax,%edx
  800a76:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a79:	29 d8                	sub    %ebx,%eax
  800a7b:	89 c3                	mov    %eax,%ebx
  800a7d:	b8 00 10 00 00       	mov    $0x1000,%eax
  800a82:	29 d0                	sub    %edx,%eax
  800a84:	39 c3                	cmp    %eax,%ebx
  800a86:	76 02                	jbe    800a8a <file_read+0x8b>
  800a88:	89 c3                	mov    %eax,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800a8a:	83 ec 04             	sub    $0x4,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	89 d0                	mov    %edx,%eax
  800a90:	03 45 f0             	add    -0x10(%ebp),%eax
  800a93:	50                   	push   %eax
  800a94:	57                   	push   %edi
  800a95:	e8 5e 17 00 00       	call   8021f8 <memmove>
		pos += bn;
  800a9a:	01 de                	add    %ebx,%esi
		buf += bn;
  800a9c:	01 df                	add    %ebx,%edi
  800a9e:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	3b 75 dc             	cmp    -0x24(%ebp),%esi
  800aa6:	72 96                	jb     800a3e <file_read+0x3f>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  800aab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800abc:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800ac1:	8b 78 04             	mov    0x4(%eax),%edi
  800ac4:	be 00 00 00 00       	mov    $0x0,%esi
  800ac9:	bb 02 00 00 00       	mov    $0x2,%ebx
  800ace:	eb 2a                	jmp    800afa <check_bitmap+0x47>
		assert(!block_is_free(2+i));
  800ad0:	53                   	push   %ebx
  800ad1:	e8 9a fc ff ff       	call   800770 <block_is_free>
  800ad6:	83 c4 04             	add    $0x4,%esp
  800ad9:	81 c6 00 80 00 00    	add    $0x8000,%esi
  800adf:	43                   	inc    %ebx
  800ae0:	84 c0                	test   %al,%al
  800ae2:	74 16                	je     800afa <check_bitmap+0x47>
  800ae4:	68 f6 39 80 00       	push   $0x8039f6
  800ae9:	68 3d 38 80 00       	push   $0x80383d
  800aee:	6a 57                	push   $0x57
  800af0:	68 0a 3a 80 00       	push   $0x803a0a
  800af5:	e8 9e 0f 00 00       	call   801a98 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800afa:	39 fe                	cmp    %edi,%esi
  800afc:	72 d2                	jb     800ad0 <check_bitmap+0x1d>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800afe:	6a 00                	push   $0x0
  800b00:	e8 6b fc ff ff       	call   800770 <block_is_free>
  800b05:	83 c4 04             	add    $0x4,%esp
  800b08:	84 c0                	test   %al,%al
  800b0a:	74 16                	je     800b22 <check_bitmap+0x6f>
  800b0c:	68 12 3a 80 00       	push   $0x803a12
  800b11:	68 3d 38 80 00       	push   $0x80383d
  800b16:	6a 5a                	push   $0x5a
  800b18:	68 0a 3a 80 00       	push   $0x803a0a
  800b1d:	e8 76 0f 00 00       	call   801a98 <_panic>
	assert(!block_is_free(1));
  800b22:	6a 01                	push   $0x1
  800b24:	e8 47 fc ff ff       	call   800770 <block_is_free>
  800b29:	83 c4 04             	add    $0x4,%esp
  800b2c:	84 c0                	test   %al,%al
  800b2e:	74 16                	je     800b46 <check_bitmap+0x93>
  800b30:	68 24 3a 80 00       	push   $0x803a24
  800b35:	68 3d 38 80 00       	push   $0x80383d
  800b3a:	6a 5b                	push   $0x5b
  800b3c:	68 0a 3a 80 00       	push   $0x803a0a
  800b41:	e8 52 0f 00 00       	call   801a98 <_panic>

	cprintf("bitmap is good\n");
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	68 36 3a 80 00       	push   $0x803a36
  800b4e:	e8 e6 0f 00 00       	call   801b39 <cprintf>
  800b53:	83 c4 10             	add    $0x10,%esp
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800b67:	85 d2                	test   %edx,%edx
  800b69:	75 14                	jne    800b7f <free_block+0x21>
		panic("attempt to free zero block");
  800b6b:	83 ec 04             	sub    $0x4,%esp
  800b6e:	68 46 3a 80 00       	push   $0x803a46
  800b73:	6a 2d                	push   $0x2d
  800b75:	68 0a 3a 80 00       	push   $0x803a0a
  800b7a:	e8 19 0f 00 00       	call   801a98 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	c1 e8 05             	shr    $0x5,%eax
  800b84:	c1 e0 02             	shl    $0x2,%eax
  800b87:	03 05 04 a0 80 00    	add    0x80a004,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	83 e1 1f             	and    $0x1f,%ecx
  800b92:	ba 01 00 00 00       	mov    $0x1,%edx
  800b97:	d3 e2                	shl    %cl,%edx
  800b99:	09 10                	or     %edx,(%eax)
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 1c             	sub    $0x1c,%esp
  800ba6:	8b 7d 08             	mov    0x8(%ebp),%edi
	if (f->f_size > newsize)
  800ba9:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
  800baf:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800bb2:	0f 8e a5 00 00 00    	jle    800c5d <file_set_size+0xc0>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800bc0:	79 06                	jns    800bc8 <file_set_size+0x2b>
  800bc2:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 fe 0c             	sar    $0xc,%esi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	05 ff 0f 00 00       	add    $0xfff,%eax
  800bd5:	79 08                	jns    800bdf <file_set_size+0x42>
  800bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bda:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800bdf:	c1 f8 0c             	sar    $0xc,%eax
  800be2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be5:	89 c3                	mov    %eax,%ebx
  800be7:	eb 4a                	jmp    800c33 <file_set_size+0x96>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	6a 00                	push   $0x0
  800bee:	8d 4d f0             	lea    -0x10(%ebp),%ecx
  800bf1:	89 da                	mov    %ebx,%edx
  800bf3:	89 f8                	mov    %edi,%eax
  800bf5:	e8 5c fc ff ff       	call   800856 <file_block_walk>
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	78 20                	js     800c21 <file_set_size+0x84>
		return r;
	if (*ptr) {
  800c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c04:	8b 00                	mov    (%eax),%eax
  800c06:	85 c0                	test   %eax,%eax
  800c08:	74 28                	je     800c32 <file_set_size+0x95>
		free_block(*ptr);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	e8 4b ff ff ff       	call   800b5e <free_block>
		*ptr = 0;
  800c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	eb 11                	jmp    800c32 <file_set_size+0x95>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800c21:	83 ec 08             	sub    $0x8,%esp
  800c24:	50                   	push   %eax
  800c25:	68 61 3a 80 00       	push   $0x803a61
  800c2a:	e8 0a 0f 00 00       	call   801b39 <cprintf>
  800c2f:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800c32:	43                   	inc    %ebx
  800c33:	39 f3                	cmp    %esi,%ebx
  800c35:	72 b2                	jb     800be9 <file_set_size+0x4c>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800c37:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
  800c3b:	77 20                	ja     800c5d <file_set_size+0xc0>
  800c3d:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800c43:	85 c0                	test   %eax,%eax
  800c45:	74 16                	je     800c5d <file_set_size+0xc0>
		free_block(f->f_indirect);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	e8 0e ff ff ff       	call   800b5e <free_block>
		f->f_indirect = 0;
  800c50:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
  800c57:	00 00 00 
  800c5a:	83 c4 10             	add    $0x10,%esp
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c60:	89 87 80 00 00 00    	mov    %eax,0x80(%edi)
	flush_block(f);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	57                   	push   %edi
  800c6a:	e8 77 f7 ff ff       	call   8003e6 <flush_block>
	return 0;
}
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 1c             	sub    $0x1c,%esp
  800c85:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c88:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800c8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8e:	01 d8                	add    %ebx,%eax
  800c90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800c9c:	76 11                	jbe    800caf <file_write+0x33>
		if ((r = file_set_size(f, offset + count)) < 0)
  800c9e:	83 ec 08             	sub    $0x8,%esp
  800ca1:	50                   	push   %eax
  800ca2:	52                   	push   %edx
  800ca3:	e8 f5 fe ff ff       	call   800b9d <file_set_size>
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	85 c0                	test   %eax,%eax
  800cad:	78 71                	js     800d20 <file_write+0xa4>
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	eb 63                	jmp    800d16 <file_write+0x9a>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800cb3:	83 ec 04             	sub    $0x4,%esp
  800cb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb9:	50                   	push   %eax
  800cba:	89 f0                	mov    %esi,%eax
  800cbc:	85 f6                	test   %esi,%esi
  800cbe:	79 06                	jns    800cc6 <file_write+0x4a>
  800cc0:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800cc6:	c1 f8 0c             	sar    $0xc,%eax
  800cc9:	50                   	push   %eax
  800cca:	ff 75 08             	pushl  0x8(%ebp)
  800ccd:	e8 cc fc ff ff       	call   80099e <file_get_block>
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	78 47                	js     800d20 <file_write+0xa4>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800ce0:	79 07                	jns    800ce9 <file_write+0x6d>
  800ce2:	48                   	dec    %eax
  800ce3:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800ce8:	40                   	inc    %eax
  800ce9:	89 c2                	mov    %eax,%edx
  800ceb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cee:	29 d8                	sub    %ebx,%eax
  800cf0:	89 c3                	mov    %eax,%ebx
  800cf2:	b8 00 10 00 00       	mov    $0x1000,%eax
  800cf7:	29 d0                	sub    %edx,%eax
  800cf9:	39 c3                	cmp    %eax,%ebx
  800cfb:	76 02                	jbe    800cff <file_write+0x83>
  800cfd:	89 c3                	mov    %eax,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	53                   	push   %ebx
  800d03:	57                   	push   %edi
  800d04:	89 d0                	mov    %edx,%eax
  800d06:	03 45 f0             	add    -0x10(%ebp),%eax
  800d09:	50                   	push   %eax
  800d0a:	e8 e9 14 00 00       	call   8021f8 <memmove>
		pos += bn;
  800d0f:	01 de                	add    %ebx,%esi
		buf += bn;
  800d11:	01 df                	add    %ebx,%edi
  800d13:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800d16:	89 f3                	mov    %esi,%ebx
  800d18:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  800d1b:	77 96                	ja     800cb3 <file_write+0x37>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800d1d:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800d2e:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800d33:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800d39:	74 14                	je     800d4f <check_super+0x27>
		panic("bad file system magic number");
  800d3b:	83 ec 04             	sub    $0x4,%esp
  800d3e:	68 7e 3a 80 00       	push   $0x803a7e
  800d43:	6a 0f                	push   $0xf
  800d45:	68 0a 3a 80 00       	push   $0x803a0a
  800d4a:	e8 49 0d 00 00       	call   801a98 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800d4f:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800d56:	76 14                	jbe    800d6c <check_super+0x44>
		panic("file system is too large");
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	68 9b 3a 80 00       	push   $0x803a9b
  800d60:	6a 12                	push   $0x12
  800d62:	68 0a 3a 80 00       	push   $0x803a0a
  800d67:	e8 2c 0d 00 00       	call   801a98 <_panic>

	cprintf("superblock is good\n");
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	68 b4 3a 80 00       	push   $0x803ab4
  800d74:	e8 c0 0d 00 00       	call   801b39 <cprintf>
  800d79:	83 c4 10             	add    $0x10,%esp
}
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	81 ec ac 00 00 00    	sub    $0xac,%esp
  800d8a:	89 95 4c ff ff ff    	mov    %edx,-0xb4(%ebp)
  800d90:	89 8d 48 ff ff ff    	mov    %ecx,-0xb8(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800d96:	e8 14 fa ff ff       	call   8007af <skip_slash>
  800d9b:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	f = &super->s_root;
  800da1:	a1 08 a0 80 00       	mov    0x80a008,%eax
	dir = 0;
	name[0] = 0;
  800da6:	c6 85 74 ff ff ff 00 	movb   $0x0,-0x8c(%ebp)

	if (pdir)
  800dad:	83 bd 4c ff ff ff 00 	cmpl   $0x0,-0xb4(%ebp)
  800db4:	74 0c                	je     800dc2 <walk_path+0x44>
		*pdir = 0;
  800db6:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800dbc:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800dc2:	83 c0 08             	add    $0x8,%eax
  800dc5:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800dcb:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800dd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	e9 8b 01 00 00       	jmp    800f6c <walk_path+0x1ee>
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800de1:	43                   	inc    %ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800de2:	8a 03                	mov    (%ebx),%al
  800de4:	3c 2f                	cmp    $0x2f,%al
  800de6:	74 04                	je     800dec <walk_path+0x6e>
  800de8:	84 c0                	test   %al,%al
  800dea:	75 f5                	jne    800de1 <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800dec:	89 de                	mov    %ebx,%esi
  800dee:	2b b5 60 ff ff ff    	sub    -0xa0(%ebp),%esi
  800df4:	83 fe 7f             	cmp    $0x7f,%esi
  800df7:	7e 0a                	jle    800e03 <walk_path+0x85>
  800df9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800dfe:	e9 a6 01 00 00       	jmp    800fa9 <walk_path+0x22b>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	56                   	push   %esi
  800e07:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800e0d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800e13:	50                   	push   %eax
  800e14:	e8 df 13 00 00       	call   8021f8 <memmove>
		name[path - p] = '\0';
  800e19:	c6 84 35 74 ff ff ff 	movb   $0x0,-0x8c(%ebp,%esi,1)
  800e20:	00 
		path = skip_slash(path);
  800e21:	89 d8                	mov    %ebx,%eax
  800e23:	e8 87 f9 ff ff       	call   8007af <skip_slash>
  800e28:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  800e37:	83 ba 84 00 00 00 01 	cmpl   $0x1,0x84(%edx)
  800e3e:	0f 85 60 01 00 00    	jne    800fa4 <walk_path+0x226>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800e44:	8b 82 80 00 00 00    	mov    0x80(%edx),%eax
  800e4a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800e4f:	74 19                	je     800e6a <walk_path+0xec>
  800e51:	68 c8 3a 80 00       	push   $0x803ac8
  800e56:	68 3d 38 80 00       	push   $0x80383d
  800e5b:	68 d1 00 00 00       	push   $0xd1
  800e60:	68 0a 3a 80 00       	push   $0x803a0a
  800e65:	e8 2e 0c 00 00       	call   801a98 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	79 05                	jns    800e73 <walk_path+0xf5>
  800e6e:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e73:	c1 f8 0c             	sar    $0xc,%eax
  800e76:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
  800e7c:	c7 85 58 ff ff ff 00 	movl   $0x0,-0xa8(%ebp)
  800e83:	00 00 00 
  800e86:	eb 6b                	jmp    800ef3 <walk_path+0x175>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800e88:	83 ec 04             	sub    $0x4,%esp
  800e8b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff b5 58 ff ff ff    	pushl  -0xa8(%ebp)
  800e98:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
  800e9e:	e8 fb fa ff ff       	call   80099e <file_get_block>
  800ea3:	83 c4 10             	add    $0x10,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	78 59                	js     800f03 <walk_path+0x185>
			return r;
		f = (struct File*) blk;
  800eaa:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  800eb0:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  800ec1:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800ec7:	8d 34 13             	lea    (%ebx,%edx,1),%esi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	e8 4a 12 00 00       	call   80211e <strcmp>
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	0f 84 81 00 00 00    	je     800f60 <walk_path+0x1e2>
  800edf:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800ee5:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800eeb:	75 d4                	jne    800ec1 <walk_path+0x143>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800eed:	ff 85 58 ff ff ff    	incl   -0xa8(%ebp)
  800ef3:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800ef9:	39 85 58 ff ff ff    	cmp    %eax,-0xa8(%ebp)
  800eff:	75 87                	jne    800e88 <walk_path+0x10a>
  800f01:	eb 09                	jmp    800f0c <walk_path+0x18e>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800f03:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f06:	0f 85 9d 00 00 00    	jne    800fa9 <walk_path+0x22b>
  800f0c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800f12:	80 3a 00             	cmpb   $0x0,(%edx)
  800f15:	0f 85 89 00 00 00    	jne    800fa4 <walk_path+0x226>
				if (pdir)
  800f1b:	83 bd 4c ff ff ff 00 	cmpl   $0x0,-0xb4(%ebp)
  800f22:	74 0e                	je     800f32 <walk_path+0x1b4>
					*pdir = dir;
  800f24:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  800f2a:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800f30:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  800f32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800f36:	74 15                	je     800f4d <walk_path+0x1cf>
					strcpy(lastelem, name);
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	ff 75 08             	pushl  0x8(%ebp)
  800f45:	e8 41 11 00 00       	call   80208b <strcpy>
  800f4a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800f4d:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800f53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f59:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800f5e:	eb 49                	jmp    800fa9 <walk_path+0x22b>
  800f60:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f66:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800f6c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800f72:	80 3a 00             	cmpb   $0x0,(%edx)
  800f75:	74 07                	je     800f7e <walk_path+0x200>
  800f77:	89 d3                	mov    %edx,%ebx
  800f79:	e9 64 fe ff ff       	jmp    800de2 <walk_path+0x64>
			}
			return r;
		}
	}

	if (pdir)
  800f7e:	83 bd 4c ff ff ff 00 	cmpl   $0x0,-0xb4(%ebp)
  800f85:	74 08                	je     800f8f <walk_path+0x211>
		*pdir = dir;
  800f87:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800f8d:	89 02                	mov    %eax,(%edx)
	*pf = f;
  800f8f:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
  800f95:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800f9b:	89 10                	mov    %edx,(%eax)
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	eb 05                	jmp    800fa9 <walk_path+0x22b>
	return 0;
  800fa4:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  800fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800fb7:	6a 00                	push   $0x0
  800fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc4:	e8 b5 fd ff ff       	call   800d7e <walk_path>
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    

00800fcb <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	81 ec a8 00 00 00    	sub    $0xa8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800fd7:	8d 8d 6c ff ff ff    	lea    -0x94(%ebp),%ecx
  800fdd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
  800fe3:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	e8 8c fd ff ff       	call   800d7e <walk_path>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	75 0a                	jne    801003 <file_create+0x38>
  800ff9:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800ffe:	e9 f9 00 00 00       	jmp    8010fc <file_create+0x131>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801003:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801006:	0f 85 f0 00 00 00    	jne    8010fc <file_create+0x131>
  80100c:	8b 9d 70 ff ff ff    	mov    -0x90(%ebp),%ebx
  801012:	85 db                	test   %ebx,%ebx
  801014:	0f 84 e2 00 00 00    	je     8010fc <file_create+0x131>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80101a:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801020:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801025:	74 21                	je     801048 <file_create+0x7d>
  801027:	68 c8 3a 80 00       	push   $0x803ac8
  80102c:	68 3d 38 80 00       	push   $0x80383d
  801031:	68 ea 00 00 00       	push   $0xea
  801036:	68 0a 3a 80 00       	push   $0x803a0a
  80103b:	e8 58 0a 00 00       	call   801a98 <_panic>
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
  801040:	89 85 6c ff ff ff    	mov    %eax,-0x94(%ebp)
  801046:	eb 7e                	jmp    8010c6 <file_create+0xfb>
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
  801048:	85 c0                	test   %eax,%eax
  80104a:	79 05                	jns    801051 <file_create+0x86>
  80104c:	05 ff 0f 00 00       	add    $0xfff,%eax
  801051:	89 c7                	mov    %eax,%edi
  801053:	c1 ff 0c             	sar    $0xc,%edi
  801056:	be 00 00 00 00       	mov    $0x0,%esi
  80105b:	eb 37                	jmp    801094 <file_create+0xc9>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	e8 30 f9 ff ff       	call   80099e <file_get_block>
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 88 83 00 00 00    	js     8010fc <file_create+0x131>
			return r;
		f = (struct File*) blk;
  801079:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80107f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801085:	80 38 00             	cmpb   $0x0,(%eax)
  801088:	74 b6                	je     801040 <file_create+0x75>
				*file = &f[j];
  80108a:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80108f:	39 c2                	cmp    %eax,%edx
  801091:	75 f2                	jne    801085 <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801093:	46                   	inc    %esi
  801094:	39 fe                	cmp    %edi,%esi
  801096:	75 c5                	jne    80105d <file_create+0x92>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  801098:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  80109f:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	e8 eb f8 ff ff       	call   80099e <file_get_block>
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 42                	js     8010fc <file_create+0x131>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8010ba:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  8010c0:	89 85 6c ff ff ff    	mov    %eax,-0x94(%ebp)
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
  8010d6:	e8 b0 0f 00 00       	call   80208b <strcpy>
	*pf = f;
  8010db:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
  8010e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e4:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8010e6:	83 c4 04             	add    $0x4,%esp
  8010e9:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  8010ef:	e8 14 f8 ff ff       	call   800908 <file_flush>
  8010f4:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010f9:	83 c4 10             	add    $0x10,%esp
}
  8010fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  80110a:	e8 83 ef ff ff       	call   800092 <ide_probe_disk1>
  80110f:	84 c0                	test   %al,%al
  801111:	74 0f                	je     801122 <fs_init+0x1e>
		ide_set_disk(1);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	6a 01                	push   $0x1
  801118:	e8 4c ef ff ff       	call   800069 <ide_set_disk>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	eb 0d                	jmp    80112f <fs_init+0x2b>
	else
		ide_set_disk(0);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	6a 00                	push   $0x0
  801127:	e8 3d ef ff ff       	call   800069 <ide_set_disk>
  80112c:	83 c4 10             	add    $0x10,%esp
	bc_init();
  80112f:	e8 6c f3 ff ff       	call   8004a0 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	6a 01                	push   $0x1
  801139:	e8 67 f1 ff ff       	call   8002a5 <diskaddr>
  80113e:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  801143:	e8 e0 fb ff ff       	call   800d28 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  801148:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80114f:	e8 51 f1 ff ff       	call   8002a5 <diskaddr>
  801154:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  801159:	e8 55 f9 ff ff       	call   800ab3 <check_bitmap>
  80115e:	83 c4 10             	add    $0x10,%esp
	
}
  801161:	c9                   	leave  
  801162:	c3                   	ret    
	...

00801164 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	ba 00 00 00 00       	mov    $0x0,%edx
  80116c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801171:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  801176:	89 90 20 50 80 00    	mov    %edx,0x805020(%eax)
		opentab[i].o_fd = (struct Fd*) va;
  80117c:	89 88 2c 50 80 00    	mov    %ecx,0x80502c(%eax)
		va += PGSIZE;
  801182:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801188:	42                   	inc    %edx
  801189:	83 c0 10             	add    $0x10,%eax
  80118c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801192:	75 e2                	jne    801176 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80119c:	e8 1b f6 ff ff       	call   8007bc <fs_sync>
	return 0;
}
  8011a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <openfile_lookup>:
}

// Look up an open file for envid.
int 
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 18             	sub    $0x18,%esp
  8011b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8011b4:	89 f8                	mov    %edi,%eax
  8011b6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011bb:	89 c3                	mov    %eax,%ebx
  8011bd:	c1 e3 04             	shl    $0x4,%ebx
  8011c0:	8d b3 20 50 80 00    	lea    0x805020(%ebx),%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8011c6:	ff 76 0c             	pushl  0xc(%esi)
  8011c9:	e8 de 18 00 00       	call   802aac <pageref>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	83 f8 01             	cmp    $0x1,%eax
  8011d4:	7e 14                	jle    8011ea <openfile_lookup+0x42>
  8011d6:	3b bb 20 50 80 00    	cmp    0x805020(%ebx),%edi
  8011dc:	75 0c                	jne    8011ea <openfile_lookup+0x42>
		return -E_INVAL;
	*po = o;
  8011de:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e1:	89 30                	mov    %esi,(%eax)
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb 05                	jmp    8011ef <openfile_lookup+0x47>
	return 0;
  8011ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011fd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	8b 45 0c             	mov    0xc(%ebp),%eax
  801204:	ff 30                	pushl  (%eax)
  801206:	ff 75 08             	pushl  0x8(%ebp)
  801209:	e8 9a ff ff ff       	call   8011a8 <openfile_lookup>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 16                	js     80122b <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80121b:	ff 70 04             	pushl  0x4(%eax)
  80121e:	e8 e5 f6 ff ff       	call   800908 <file_flush>
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
  801228:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 18             	sub    $0x18,%esp
  801234:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801237:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 33                	pushl  (%ebx)
  80123d:	ff 75 08             	pushl  0x8(%ebp)
  801240:	e8 63 ff ff ff       	call   8011a8 <openfile_lookup>
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 3f                	js     80128b <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801252:	ff 70 04             	pushl  0x4(%eax)
  801255:	53                   	push   %ebx
  801256:	e8 30 0e 00 00       	call   80208b <strcpy>
	ret->ret_size = o->o_file->f_size;
  80125b:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80125e:	8b 42 04             	mov    0x4(%edx),%eax
  801261:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801267:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80126d:	8b 42 04             	mov    0x4(%edx),%eax
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  80127a:	0f 94 c0             	sete   %al
  80127d:	0f b6 c0             	movzbl %al,%eax
  801280:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80128b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 18             	sub    $0x18,%esp
  801297:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80129a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	ff 33                	pushl  (%ebx)
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 00 ff ff ff       	call   8011a8 <openfile_lookup>
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 2a                	js     8012db <serve_write+0x4b>
		return r;
	if((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  8012b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012b4:	8b 50 0c             	mov    0xc(%eax),%edx
  8012b7:	ff 72 04             	pushl  0x4(%edx)
  8012ba:	ff 73 04             	pushl  0x4(%ebx)
  8012bd:	8d 53 08             	lea    0x8(%ebx),%edx
  8012c0:	52                   	push   %edx
  8012c1:	ff 70 04             	pushl  0x4(%eax)
  8012c4:	e8 b3 f9 ff ff       	call   800c7c <file_write>
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 09                	js     8012db <serve_write+0x4b>
		return r;
	o->o_fd->fd_offset += r;
  8012d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8012d8:	01 50 04             	add    %edx,0x4(%eax)
	return r;
}
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 18             	sub    $0x18,%esp
  8012e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	struct OpenFile * o;
	int r;
	if((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012ec:	8d 45 f8             	lea    -0x8(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 33                	pushl  (%ebx)
  8012f2:	ff 75 08             	pushl  0x8(%ebp)
  8012f5:	e8 ae fe ff ff       	call   8011a8 <openfile_lookup>
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 27                	js     80132a <serve_read+0x48>
		return r;
	if((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801303:	8b 55 f8             	mov    -0x8(%ebp),%edx
  801306:	8b 42 0c             	mov    0xc(%edx),%eax
  801309:	ff 70 04             	pushl  0x4(%eax)
  80130c:	ff 73 04             	pushl  0x4(%ebx)
  80130f:	53                   	push   %ebx
  801310:	ff 72 04             	pushl  0x4(%edx)
  801313:	e8 e7 f6 ff ff       	call   8009ff <file_read>
  801318:	89 c2                	mov    %eax,%edx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 09                	js     80132a <serve_read+0x48>
		return r;
	o->o_fd->fd_offset += r;
  801321:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801324:	8b 40 0c             	mov    0xc(%eax),%eax
  801327:	01 50 04             	add    %edx,0x4(%eax)
	return r;
}
  80132a:	89 d0                	mov    %edx,%eax
  80132c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	53                   	push   %ebx
  801335:	83 ec 18             	sub    $0x18,%esp
  801338:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80133b:	8d 45 f8             	lea    -0x8(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 33                	pushl  (%ebx)
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 5f fe ff ff       	call   8011a8 <openfile_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 14                	js     801364 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	ff 73 04             	pushl  0x4(%ebx)
  801356:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801359:	ff 70 04             	pushl  0x4(%eax)
  80135c:	e8 3c f8 ff ff       	call   800b9d <file_set_size>
  801361:	83 c4 10             	add    $0x10,%esp
}
  801364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	56                   	push   %esi
  80136d:	53                   	push   %ebx
  80136e:	8b 75 08             	mov    0x8(%ebp),%esi
  801371:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  801376:	83 ec 0c             	sub    $0xc,%esp
  801379:	89 d8                	mov    %ebx,%eax
  80137b:	c1 e0 04             	shl    $0x4,%eax
  80137e:	ff b0 2c 50 80 00    	pushl  0x80502c(%eax)
  801384:	e8 23 17 00 00       	call   802aac <pageref>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	74 07                	je     801397 <openfile_alloc+0x2e>
  801390:	83 f8 01             	cmp    $0x1,%eax
  801393:	75 55                	jne    8013ea <openfile_alloc+0x81>
  801395:	eb 1e                	jmp    8013b5 <openfile_alloc+0x4c>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801397:	83 ec 04             	sub    $0x4,%esp
  80139a:	6a 07                	push   $0x7
  80139c:	89 d8                	mov    %ebx,%eax
  80139e:	c1 e0 04             	shl    $0x4,%eax
  8013a1:	ff b0 2c 50 80 00    	pushl  0x80502c(%eax)
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 f3 11 00 00       	call   8025a1 <sys_page_alloc>
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 43                	js     8013f8 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8013b5:	89 d8                	mov    %ebx,%eax
  8013b7:	c1 e0 04             	shl    $0x4,%eax
  8013ba:	81 80 20 50 80 00 00 	addl   $0x400,0x805020(%eax)
  8013c1:	04 00 00 
			*o = &opentab[i];
  8013c4:	8d 90 20 50 80 00    	lea    0x805020(%eax),%edx
  8013ca:	89 16                	mov    %edx,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	68 00 10 00 00       	push   $0x1000
  8013d4:	6a 00                	push   $0x0
  8013d6:	ff b0 2c 50 80 00    	pushl  0x80502c(%eax)
  8013dc:	e8 c7 0d 00 00       	call   8021a8 <memset>
			return (*o)->o_fileid;
  8013e1:	8b 06                	mov    (%esi),%eax
  8013e3:	8b 00                	mov    (%eax),%eax
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	eb 0e                	jmp    8013f8 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8013ea:	43                   	inc    %ebx
  8013eb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8013f1:	75 83                	jne    801376 <openfile_alloc+0xd>
  8013f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	81 ec 14 04 00 00    	sub    $0x414,%esp
  80140a:	8b 75 0c             	mov    0xc(%ebp),%esi

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  80140d:	68 00 04 00 00       	push   $0x400
  801412:	56                   	push   %esi
  801413:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  801419:	53                   	push   %ebx
  80141a:	e8 d9 0d 00 00       	call   8021f8 <memmove>
	path[MAXPATHLEN-1] = 0;
  80141f:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801423:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801429:	89 04 24             	mov    %eax,(%esp)
  80142c:	e8 38 ff ff ff       	call   801369 <openfile_alloc>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 c0                	test   %eax,%eax
  801436:	0f 88 05 01 00 00    	js     801541 <serve_open+0x142>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  80143c:	f6 86 01 04 00 00 01 	testb  $0x1,0x401(%esi)
  801443:	74 2d                	je     801472 <serve_open+0x73>
		if ((r = file_create(path, &f)) < 0) {
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	53                   	push   %ebx
  801450:	e8 76 fb ff ff       	call   800fcb <file_create>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	79 37                	jns    801493 <serve_open+0x94>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80145c:	f6 86 01 04 00 00 04 	testb  $0x4,0x401(%esi)
  801463:	0f 85 d8 00 00 00    	jne    801541 <serve_open+0x142>
  801469:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80146c:	0f 85 cf 00 00 00    	jne    801541 <serve_open+0x142>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	e8 29 fb ff ff       	call   800fb1 <file_open>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	0f 88 ae 00 00 00    	js     801541 <serve_open+0x142>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801493:	f6 86 01 04 00 00 02 	testb  $0x2,0x401(%esi)
  80149a:	74 1b                	je     8014b7 <serve_open+0xb8>
		if ((r = file_set_size(f, 0)) < 0) {
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	6a 00                	push   $0x0
  8014a1:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014a7:	e8 f1 f6 ff ff       	call   800b9d <file_set_size>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	0f 88 8a 00 00 00    	js     801541 <serve_open+0x142>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	e8 e4 fa ff ff       	call   800fb1 <file_open>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 6d                	js     801541 <serve_open+0x142>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8014d4:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8014da:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014e0:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8014e3:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014e9:	8b 50 0c             	mov    0xc(%eax),%edx
  8014ec:	8b 00                	mov    (%eax),%eax
  8014ee:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8014f1:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8014f7:	8b 50 0c             	mov    0xc(%eax),%edx
  8014fa:	8b 86 00 04 00 00    	mov    0x400(%esi),%eax
  801500:	83 e0 03             	and    $0x3,%eax
  801503:	89 42 08             	mov    %eax,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801506:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80150c:	8b 50 0c             	mov    0xc(%eax),%edx
  80150f:	a1 68 90 80 00       	mov    0x809068,%eax
  801514:	89 02                	mov    %eax,(%edx)
	o->o_mode = req->req_omode;
  801516:	8b 96 00 04 00 00    	mov    0x400(%esi),%edx
  80151c:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801522:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801525:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80152b:	8b 50 0c             	mov    0xc(%eax),%edx
  80152e:	8b 45 10             	mov    0x10(%ebp),%eax
  801531:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  801541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8d 5d f8             	lea    -0x8(%ebp),%ebx
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801552:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801559:	83 ec 04             	sub    $0x4,%esp
  80155c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	ff 35 20 90 80 00    	pushl  0x809020
  801566:	53                   	push   %ebx
  801567:	e8 3a 12 00 00       	call   8027a6 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	f6 45 f4 01          	testb  $0x1,-0xc(%ebp)
  801573:	75 15                	jne    80158a <serve+0x42>
			cprintf("Invalid request from %08x: no argument page\n",
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	ff 75 f8             	pushl  -0x8(%ebp)
  80157b:	68 e8 3a 80 00       	push   $0x803ae8
  801580:	e8 b4 05 00 00       	call   801b39 <cprintf>
				whom);
			continue; // just leave it hanging...
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	eb c8                	jmp    801552 <serve+0xa>
		}

		pg = NULL;
  80158a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		if (req == FSREQ_OPEN) {
  801591:	83 f8 01             	cmp    $0x1,%eax
  801594:	75 1b                	jne    8015b1 <serve+0x69>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 35 20 90 80 00    	pushl  0x809020
  8015a4:	ff 75 f8             	pushl  -0x8(%ebp)
  8015a7:	e8 53 fe ff ff       	call   8013ff <serve_open>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb 3c                	jmp    8015ed <serve+0xa5>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015b1:	83 f8 08             	cmp    $0x8,%eax
  8015b4:	77 1e                	ja     8015d4 <serve+0x8c>
  8015b6:	8b 14 85 40 90 80 00 	mov    0x809040(,%eax,4),%edx
  8015bd:	85 d2                	test   %edx,%edx
  8015bf:	74 13                	je     8015d4 <serve+0x8c>
			r = handlers[req](whom, fsreq);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	ff 35 20 90 80 00    	pushl  0x809020
  8015ca:	ff 75 f8             	pushl  -0x8(%ebp)
  8015cd:	ff d2                	call   *%edx
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	eb 19                	jmp    8015ed <serve+0xa5>
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	ff 75 f8             	pushl  -0x8(%ebp)
  8015da:	50                   	push   %eax
  8015db:	68 18 3b 80 00       	push   $0x803b18
  8015e0:	e8 54 05 00 00       	call   801b39 <cprintf>
  8015e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ea:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 f8             	pushl  -0x8(%ebp)
  8015f7:	e8 55 11 00 00       	call   802751 <ipc_send>
		sys_page_unmap(0, fsreq);
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	ff 35 20 90 80 00    	pushl  0x809020
  801605:	6a 00                	push   $0x0
  801607:	e8 11 0f 00 00       	call   80251d <sys_page_unmap>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	e9 3e ff ff ff       	jmp    801552 <serve+0xa>

00801614 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80161a:	c7 05 64 90 80 00 3b 	movl   $0x803b3b,0x809064
  801621:	3b 80 00 
	cprintf("FS is running\n");
  801624:	68 3e 3b 80 00       	push   $0x803b3e
  801629:	e8 0b 05 00 00       	call   801b39 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80162e:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801633:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801638:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80163a:	c7 04 24 4d 3b 80 00 	movl   $0x803b4d,(%esp)
  801641:	e8 f3 04 00 00       	call   801b39 <cprintf>

	serve_init();
  801646:	e8 19 fb ff ff       	call   801164 <serve_init>
	fs_init();
  80164b:	e8 b4 fa ff ff       	call   801104 <fs_init>
        fs_test();
  801650:	e8 0b 00 00 00       	call   801660 <fs_test>
	serve();
  801655:	e8 ee fe ff ff       	call   801548 <serve>
  80165a:	83 c4 10             	add    $0x10,%esp
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    
	...

00801660 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	83 ec 14             	sub    $0x14,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801668:	6a 07                	push   $0x7
  80166a:	68 00 10 00 00       	push   $0x1000
  80166f:	6a 00                	push   $0x0
  801671:	e8 2b 0f 00 00       	call   8025a1 <sys_page_alloc>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	79 12                	jns    80168f <fs_test+0x2f>
		panic("sys_page_alloc: %e", r);
  80167d:	50                   	push   %eax
  80167e:	68 5c 3b 80 00       	push   $0x803b5c
  801683:	6a 12                	push   $0x12
  801685:	68 6f 3b 80 00       	push   $0x803b6f
  80168a:	e8 09 04 00 00       	call   801a98 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	68 00 10 00 00       	push   $0x1000
  801697:	ff 35 04 a0 80 00    	pushl  0x80a004
  80169d:	68 00 10 00 00       	push   $0x1000
  8016a2:	e8 51 0b 00 00       	call   8021f8 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016a7:	e8 44 f1 ff ff       	call   8007f0 <alloc_block>
  8016ac:	89 c2                	mov    %eax,%edx
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	79 12                	jns    8016c7 <fs_test+0x67>
		panic("alloc_block: %e", r);
  8016b5:	50                   	push   %eax
  8016b6:	68 79 3b 80 00       	push   $0x803b79
  8016bb:	6a 17                	push   $0x17
  8016bd:	68 6f 3b 80 00       	push   $0x803b6f
  8016c2:	e8 d1 03 00 00       	call   801a98 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016c7:	85 d2                	test   %edx,%edx
  8016c9:	79 03                	jns    8016ce <fs_test+0x6e>
  8016cb:	8d 42 1f             	lea    0x1f(%edx),%eax
  8016ce:	c1 f8 05             	sar    $0x5,%eax
  8016d1:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  8016d8:	8b b3 00 10 00 00    	mov    0x1000(%ebx),%esi
  8016de:	89 d1                	mov    %edx,%ecx
  8016e0:	81 e1 1f 00 00 80    	and    $0x8000001f,%ecx
  8016e6:	79 05                	jns    8016ed <fs_test+0x8d>
  8016e8:	49                   	dec    %ecx
  8016e9:	83 c9 e0             	or     $0xffffffe0,%ecx
  8016ec:	41                   	inc    %ecx
  8016ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	d3 e2                	shl    %cl,%edx
  8016f6:	85 d6                	test   %edx,%esi
  8016f8:	75 16                	jne    801710 <fs_test+0xb0>
  8016fa:	68 89 3b 80 00       	push   $0x803b89
  8016ff:	68 3d 38 80 00       	push   $0x80383d
  801704:	6a 19                	push   $0x19
  801706:	68 6f 3b 80 00       	push   $0x803b6f
  80170b:	e8 88 03 00 00       	call   801a98 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801710:	89 d8                	mov    %ebx,%eax
  801712:	03 05 04 a0 80 00    	add    0x80a004,%eax
  801718:	85 10                	test   %edx,(%eax)
  80171a:	74 16                	je     801732 <fs_test+0xd2>
  80171c:	68 04 3d 80 00       	push   $0x803d04
  801721:	68 3d 38 80 00       	push   $0x80383d
  801726:	6a 1b                	push   $0x1b
  801728:	68 6f 3b 80 00       	push   $0x803b6f
  80172d:	e8 66 03 00 00       	call   801a98 <_panic>
	cprintf("alloc_block is good\n");
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	68 a4 3b 80 00       	push   $0x803ba4
  80173a:	e8 fa 03 00 00       	call   801b39 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80173f:	83 c4 08             	add    $0x8,%esp
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	68 b9 3b 80 00       	push   $0x803bb9
  80174b:	e8 61 f8 ff ff       	call   800fb1 <file_open>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	79 17                	jns    80176e <fs_test+0x10e>
  801757:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80175a:	74 2a                	je     801786 <fs_test+0x126>
		panic("file_open /not-found: %e", r);
  80175c:	50                   	push   %eax
  80175d:	68 c4 3b 80 00       	push   $0x803bc4
  801762:	6a 1f                	push   $0x1f
  801764:	68 6f 3b 80 00       	push   $0x803b6f
  801769:	e8 2a 03 00 00       	call   801a98 <_panic>
	else if (r == 0)
  80176e:	85 c0                	test   %eax,%eax
  801770:	75 14                	jne    801786 <fs_test+0x126>
		panic("file_open /not-found succeeded!");
  801772:	83 ec 04             	sub    $0x4,%esp
  801775:	68 24 3d 80 00       	push   $0x803d24
  80177a:	6a 21                	push   $0x21
  80177c:	68 6f 3b 80 00       	push   $0x803b6f
  801781:	e8 12 03 00 00       	call   801a98 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	68 dd 3b 80 00       	push   $0x803bdd
  801792:	e8 1a f8 ff ff       	call   800fb1 <file_open>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	79 12                	jns    8017b0 <fs_test+0x150>
		panic("file_open /newmotd: %e", r);
  80179e:	50                   	push   %eax
  80179f:	68 e6 3b 80 00       	push   $0x803be6
  8017a4:	6a 23                	push   $0x23
  8017a6:	68 6f 3b 80 00       	push   $0x803b6f
  8017ab:	e8 e8 02 00 00       	call   801a98 <_panic>
	cprintf("file_open is good\n");
  8017b0:	83 ec 0c             	sub    $0xc,%esp
  8017b3:	68 fd 3b 80 00       	push   $0x803bfd
  8017b8:	e8 7c 03 00 00       	call   801b39 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017bd:	83 c4 0c             	add    $0xc,%esp
  8017c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c3:	50                   	push   %eax
  8017c4:	6a 00                	push   $0x0
  8017c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c9:	e8 d0 f1 ff ff       	call   80099e <file_get_block>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	79 12                	jns    8017e7 <fs_test+0x187>
		panic("file_get_block: %e", r);
  8017d5:	50                   	push   %eax
  8017d6:	68 10 3c 80 00       	push   $0x803c10
  8017db:	6a 27                	push   $0x27
  8017dd:	68 6f 3b 80 00       	push   $0x803b6f
  8017e2:	e8 b1 02 00 00       	call   801a98 <_panic>
	if (strcmp(blk, msg) != 0)
  8017e7:	8b 1d 90 3d 80 00    	mov    0x803d90,%ebx
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	53                   	push   %ebx
  8017f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f4:	e8 25 09 00 00       	call   80211e <strcmp>
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	74 14                	je     801814 <fs_test+0x1b4>
		panic("file_get_block returned wrong data");
  801800:	83 ec 04             	sub    $0x4,%esp
  801803:	68 44 3d 80 00       	push   $0x803d44
  801808:	6a 29                	push   $0x29
  80180a:	68 6f 3b 80 00       	push   $0x803b6f
  80180f:	e8 84 02 00 00       	call   801a98 <_panic>
	cprintf("file_get_block is good\n");
  801814:	83 ec 0c             	sub    $0xc,%esp
  801817:	68 23 3c 80 00       	push   $0x803c23
  80181c:	e8 18 03 00 00       	call   801b39 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801821:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801824:	8a 02                	mov    (%edx),%al
  801826:	88 02                	mov    %al,(%edx)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182b:	c1 e8 0c             	shr    $0xc,%eax
  80182e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	a8 40                	test   $0x40,%al
  80183a:	75 16                	jne    801852 <fs_test+0x1f2>
  80183c:	68 3c 3c 80 00       	push   $0x803c3c
  801841:	68 3d 38 80 00       	push   $0x80383d
  801846:	6a 2d                	push   $0x2d
  801848:	68 6f 3b 80 00       	push   $0x803b6f
  80184d:	e8 46 02 00 00       	call   801a98 <_panic>
	file_flush(f);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	ff 75 f4             	pushl  -0xc(%ebp)
  801858:	e8 ab f0 ff ff       	call   800908 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80185d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801860:	c1 e8 0c             	shr    $0xc,%eax
  801863:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	a8 40                	test   $0x40,%al
  80186f:	74 16                	je     801887 <fs_test+0x227>
  801871:	68 3b 3c 80 00       	push   $0x803c3b
  801876:	68 3d 38 80 00       	push   $0x80383d
  80187b:	6a 2f                	push   $0x2f
  80187d:	68 6f 3b 80 00       	push   $0x803b6f
  801882:	e8 11 02 00 00       	call   801a98 <_panic>
	cprintf("file_flush is good\n");
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	68 57 3c 80 00       	push   $0x803c57
  80188f:	e8 a5 02 00 00       	call   801b39 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801894:	83 c4 08             	add    $0x8,%esp
  801897:	6a 00                	push   $0x0
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	e8 fc f2 ff ff       	call   800b9d <file_set_size>
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	79 12                	jns    8018ba <fs_test+0x25a>
		panic("file_set_size: %e", r);
  8018a8:	50                   	push   %eax
  8018a9:	68 6b 3c 80 00       	push   $0x803c6b
  8018ae:	6a 33                	push   $0x33
  8018b0:	68 6f 3b 80 00       	push   $0x803b6f
  8018b5:	e8 de 01 00 00       	call   801a98 <_panic>
	assert(f->f_direct[0] == 0);
  8018ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bd:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018c4:	74 16                	je     8018dc <fs_test+0x27c>
  8018c6:	68 7d 3c 80 00       	push   $0x803c7d
  8018cb:	68 3d 38 80 00       	push   $0x80383d
  8018d0:	6a 34                	push   $0x34
  8018d2:	68 6f 3b 80 00       	push   $0x803b6f
  8018d7:	e8 bc 01 00 00       	call   801a98 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018dc:	c1 e8 0c             	shr    $0xc,%eax
  8018df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e6:	a8 40                	test   $0x40,%al
  8018e8:	74 16                	je     801900 <fs_test+0x2a0>
  8018ea:	68 91 3c 80 00       	push   $0x803c91
  8018ef:	68 3d 38 80 00       	push   $0x80383d
  8018f4:	6a 35                	push   $0x35
  8018f6:	68 6f 3b 80 00       	push   $0x803b6f
  8018fb:	e8 98 01 00 00       	call   801a98 <_panic>
	cprintf("file_truncate is good\n");
  801900:	83 ec 0c             	sub    $0xc,%esp
  801903:	68 ab 3c 80 00       	push   $0x803cab
  801908:	e8 2c 02 00 00       	call   801b39 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80190d:	89 1c 24             	mov    %ebx,(%esp)
  801910:	e8 43 07 00 00       	call   802058 <strlen>
  801915:	83 c4 08             	add    $0x8,%esp
  801918:	50                   	push   %eax
  801919:	ff 75 f4             	pushl  -0xc(%ebp)
  80191c:	e8 7c f2 ff ff       	call   800b9d <file_set_size>
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	79 12                	jns    80193a <fs_test+0x2da>
		panic("file_set_size 2: %e", r);
  801928:	50                   	push   %eax
  801929:	68 c2 3c 80 00       	push   $0x803cc2
  80192e:	6a 39                	push   $0x39
  801930:	68 6f 3b 80 00       	push   $0x803b6f
  801935:	e8 5e 01 00 00       	call   801a98 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80193a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193d:	89 d0                	mov    %edx,%eax
  80193f:	c1 e8 0c             	shr    $0xc,%eax
  801942:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801949:	a8 40                	test   $0x40,%al
  80194b:	74 16                	je     801963 <fs_test+0x303>
  80194d:	68 91 3c 80 00       	push   $0x803c91
  801952:	68 3d 38 80 00       	push   $0x80383d
  801957:	6a 3a                	push   $0x3a
  801959:	68 6f 3b 80 00       	push   $0x803b6f
  80195e:	e8 35 01 00 00       	call   801a98 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801963:	83 ec 04             	sub    $0x4,%esp
  801966:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801969:	50                   	push   %eax
  80196a:	6a 00                	push   $0x0
  80196c:	52                   	push   %edx
  80196d:	e8 2c f0 ff ff       	call   80099e <file_get_block>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	79 12                	jns    80198b <fs_test+0x32b>
		panic("file_get_block 2: %e", r);
  801979:	50                   	push   %eax
  80197a:	68 d6 3c 80 00       	push   $0x803cd6
  80197f:	6a 3c                	push   $0x3c
  801981:	68 6f 3b 80 00       	push   $0x803b6f
  801986:	e8 0d 01 00 00       	call   801a98 <_panic>
	strcpy(blk, msg);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	53                   	push   %ebx
  80198f:	ff 75 f0             	pushl  -0x10(%ebp)
  801992:	e8 f4 06 00 00       	call   80208b <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801997:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199a:	c1 e8 0c             	shr    $0xc,%eax
  80199d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	a8 40                	test   $0x40,%al
  8019a9:	75 16                	jne    8019c1 <fs_test+0x361>
  8019ab:	68 3c 3c 80 00       	push   $0x803c3c
  8019b0:	68 3d 38 80 00       	push   $0x80383d
  8019b5:	6a 3e                	push   $0x3e
  8019b7:	68 6f 3b 80 00       	push   $0x803b6f
  8019bc:	e8 d7 00 00 00       	call   801a98 <_panic>
	file_flush(f);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c7:	e8 3c ef ff ff       	call   800908 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cf:	c1 e8 0c             	shr    $0xc,%eax
  8019d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	a8 40                	test   $0x40,%al
  8019de:	74 16                	je     8019f6 <fs_test+0x396>
  8019e0:	68 3b 3c 80 00       	push   $0x803c3b
  8019e5:	68 3d 38 80 00       	push   $0x80383d
  8019ea:	6a 40                	push   $0x40
  8019ec:	68 6f 3b 80 00       	push   $0x803b6f
  8019f1:	e8 a2 00 00 00       	call   801a98 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f9:	c1 e8 0c             	shr    $0xc,%eax
  8019fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a03:	a8 40                	test   $0x40,%al
  801a05:	74 16                	je     801a1d <fs_test+0x3bd>
  801a07:	68 91 3c 80 00       	push   $0x803c91
  801a0c:	68 3d 38 80 00       	push   $0x80383d
  801a11:	6a 41                	push   $0x41
  801a13:	68 6f 3b 80 00       	push   $0x803b6f
  801a18:	e8 7b 00 00 00       	call   801a98 <_panic>
	cprintf("file rewrite is good\n");
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	68 eb 3c 80 00       	push   $0x803ceb
  801a25:	e8 0f 01 00 00       	call   801b39 <cprintf>
  801a2a:	83 c4 10             	add    $0x10,%esp
}
  801a2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a30:	5b                   	pop    %ebx
  801a31:	5e                   	pop    %esi
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  801a3f:	e8 bf 0b 00 00       	call   802603 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  801a44:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a49:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801a50:	c1 e0 07             	shl    $0x7,%eax
  801a53:	29 d0                	sub    %edx,%eax
  801a55:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a5a:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a5f:	85 f6                	test   %esi,%esi
  801a61:	7e 07                	jle    801a6a <libmain+0x36>
		binaryname = argv[0];
  801a63:	8b 03                	mov    (%ebx),%eax
  801a65:	a3 64 90 80 00       	mov    %eax,0x809064

	// call user main routine
	umain(argc, argv);
  801a6a:	83 ec 08             	sub    $0x8,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	56                   	push   %esi
  801a6f:	e8 a0 fb ff ff       	call   801614 <umain>

	// exit gracefully
	exit();
  801a74:	e8 0b 00 00 00       	call   801a84 <exit>
  801a79:	83 c4 10             	add    $0x10,%esp
}
  801a7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    
	...

00801a84 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 91 0b 00 00       	call   802622 <sys_env_destroy>
  801a91:	83 c4 10             	add    $0x10,%esp
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    
	...

00801a98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	53                   	push   %ebx
  801a9c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  801a9f:	8d 45 14             	lea    0x14(%ebp),%eax
  801aa2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801aa5:	8b 1d 64 90 80 00    	mov    0x809064,%ebx
  801aab:	e8 53 0b 00 00       	call   802603 <sys_getenvid>
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	ff 75 0c             	pushl  0xc(%ebp)
  801ab6:	ff 75 08             	pushl  0x8(%ebp)
  801ab9:	53                   	push   %ebx
  801aba:	50                   	push   %eax
  801abb:	68 a0 3d 80 00       	push   $0x803da0
  801ac0:	e8 74 00 00 00       	call   801b39 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ac5:	83 c4 18             	add    $0x18,%esp
  801ac8:	ff 75 f8             	pushl  -0x8(%ebp)
  801acb:	ff 75 10             	pushl  0x10(%ebp)
  801ace:	e8 15 00 00 00       	call   801ae8 <vcprintf>
	cprintf("\n");
  801ad3:	c7 04 24 aa 39 80 00 	movl   $0x8039aa,(%esp)
  801ada:	e8 5a 00 00 00       	call   801b39 <cprintf>
  801adf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ae2:	cc                   	int3   
  801ae3:	eb fd                	jmp    801ae2 <_panic+0x4a>
  801ae5:	00 00                	add    %al,(%eax)
	...

00801ae8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801af1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  801af8:	00 00 00 
	b.cnt = 0;
  801afb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  801b02:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b05:	ff 75 0c             	pushl  0xc(%ebp)
  801b08:	ff 75 08             	pushl  0x8(%ebp)
  801b0b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b11:	50                   	push   %eax
  801b12:	68 50 1b 80 00       	push   $0x801b50
  801b17:	e8 70 01 00 00       	call   801c8c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b1c:	83 c4 08             	add    $0x8,%esp
  801b1f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  801b25:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  801b2b:	50                   	push   %eax
  801b2c:	e8 9e 08 00 00       	call   8023cf <sys_cputs>
  801b31:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  801b37:	c9                   	leave  
  801b38:	c3                   	ret    

00801b39 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b3f:	8d 45 0c             	lea    0xc(%ebp),%eax
  801b42:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  801b45:	50                   	push   %eax
  801b46:	ff 75 08             	pushl  0x8(%ebp)
  801b49:	e8 9a ff ff ff       	call   801ae8 <vcprintf>
	va_end(ap);

	return cnt;
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b5a:	8b 03                	mov    (%ebx),%eax
  801b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  801b5f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801b63:	40                   	inc    %eax
  801b64:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801b66:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b6b:	75 1a                	jne    801b87 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  801b6d:	83 ec 08             	sub    $0x8,%esp
  801b70:	68 ff 00 00 00       	push   $0xff
  801b75:	8d 43 08             	lea    0x8(%ebx),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 51 08 00 00       	call   8023cf <sys_cputs>
		b->idx = 0;
  801b7e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b84:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b87:	ff 43 04             	incl   0x4(%ebx)
}
  801b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    
	...

00801b90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	83 ec 1c             	sub    $0x1c,%esp
  801b99:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b9c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801bab:	8b 55 10             	mov    0x10(%ebp),%edx
  801bae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bb1:	89 d6                	mov    %edx,%esi
  801bb3:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb8:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  801bbb:	72 04                	jb     801bc1 <printnum+0x31>
  801bbd:	39 c2                	cmp    %eax,%edx
  801bbf:	77 3f                	ja     801c00 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 18             	pushl  0x18(%ebp)
  801bc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801bca:	50                   	push   %eax
  801bcb:	52                   	push   %edx
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bd7:	e8 64 19 00 00       	call   803540 <__udivdi3>
  801bdc:	83 c4 18             	add    $0x18,%esp
  801bdf:	52                   	push   %edx
  801be0:	50                   	push   %eax
  801be1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801be7:	e8 a4 ff ff ff       	call   801b90 <printnum>
  801bec:	83 c4 20             	add    $0x20,%esp
  801bef:	eb 14                	jmp    801c05 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801bf1:	83 ec 08             	sub    $0x8,%esp
  801bf4:	ff 75 e8             	pushl  -0x18(%ebp)
  801bf7:	ff 75 18             	pushl  0x18(%ebp)
  801bfa:	ff 55 ec             	call   *-0x14(%ebp)
  801bfd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c00:	4b                   	dec    %ebx
  801c01:	85 db                	test   %ebx,%ebx
  801c03:	7f ec                	jg     801bf1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	ff 75 e8             	pushl  -0x18(%ebp)
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	57                   	push   %edi
  801c0f:	56                   	push   %esi
  801c10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c13:	ff 75 e0             	pushl  -0x20(%ebp)
  801c16:	e8 51 1a 00 00       	call   80366c <__umoddi3>
  801c1b:	83 c4 14             	add    $0x14,%esp
  801c1e:	0f be 80 c3 3d 80 00 	movsbl 0x803dc3(%eax),%eax
  801c25:	50                   	push   %eax
  801c26:	ff 55 ec             	call   *-0x14(%ebp)
  801c29:	83 c4 10             	add    $0x10,%esp
}
  801c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  801c39:	83 fa 01             	cmp    $0x1,%edx
  801c3c:	7e 0e                	jle    801c4c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  801c3e:	8b 10                	mov    (%eax),%edx
  801c40:	8d 42 08             	lea    0x8(%edx),%eax
  801c43:	89 01                	mov    %eax,(%ecx)
  801c45:	8b 02                	mov    (%edx),%eax
  801c47:	8b 52 04             	mov    0x4(%edx),%edx
  801c4a:	eb 22                	jmp    801c6e <getuint+0x3a>
	else if (lflag)
  801c4c:	85 d2                	test   %edx,%edx
  801c4e:	74 10                	je     801c60 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  801c50:	8b 10                	mov    (%eax),%edx
  801c52:	8d 42 04             	lea    0x4(%edx),%eax
  801c55:	89 01                	mov    %eax,(%ecx)
  801c57:	8b 02                	mov    (%edx),%eax
  801c59:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5e:	eb 0e                	jmp    801c6e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  801c60:	8b 10                	mov    (%eax),%edx
  801c62:	8d 42 04             	lea    0x4(%edx),%eax
  801c65:	89 01                	mov    %eax,(%ecx)
  801c67:	8b 02                	mov    (%edx),%eax
  801c69:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  801c76:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  801c79:	8b 11                	mov    (%ecx),%edx
  801c7b:	3b 51 04             	cmp    0x4(%ecx),%edx
  801c7e:	73 0a                	jae    801c8a <sprintputch+0x1a>
		*b->buf++ = ch;
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	88 02                	mov    %al,(%edx)
  801c85:	8d 42 01             	lea    0x1(%edx),%eax
  801c88:	89 01                	mov    %eax,(%ecx)
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	83 ec 3c             	sub    $0x3c,%esp
  801c95:	8b 75 08             	mov    0x8(%ebp),%esi
  801c98:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c9e:	eb 1a                	jmp    801cba <vprintfmt+0x2e>
  801ca0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  801ca3:	eb 15                	jmp    801cba <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801ca5:	84 c0                	test   %al,%al
  801ca7:	0f 84 15 03 00 00    	je     801fc2 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	57                   	push   %edi
  801cb1:	0f b6 c0             	movzbl %al,%eax
  801cb4:	50                   	push   %eax
  801cb5:	ff d6                	call   *%esi
  801cb7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801cba:	8a 03                	mov    (%ebx),%al
  801cbc:	43                   	inc    %ebx
  801cbd:	3c 25                	cmp    $0x25,%al
  801cbf:	75 e4                	jne    801ca5 <vprintfmt+0x19>
  801cc1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801cc8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801ccf:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801cd6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  801cdd:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  801ce1:	eb 0a                	jmp    801ced <vprintfmt+0x61>
  801ce3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  801cea:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  801ced:	8a 03                	mov    (%ebx),%al
  801cef:	0f b6 d0             	movzbl %al,%edx
  801cf2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  801cf5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  801cf8:	83 e8 23             	sub    $0x23,%eax
  801cfb:	3c 55                	cmp    $0x55,%al
  801cfd:	0f 87 9c 02 00 00    	ja     801f9f <vprintfmt+0x313>
  801d03:	0f b6 c0             	movzbl %al,%eax
  801d06:	ff 24 85 00 3f 80 00 	jmp    *0x803f00(,%eax,4)
  801d0d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  801d11:	eb d7                	jmp    801cea <vprintfmt+0x5e>
  801d13:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  801d17:	eb d1                	jmp    801cea <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d22:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801d25:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  801d28:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  801d2c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  801d2f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  801d33:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  801d34:	8d 42 d0             	lea    -0x30(%edx),%eax
  801d37:	83 f8 09             	cmp    $0x9,%eax
  801d3a:	77 21                	ja     801d5d <vprintfmt+0xd1>
  801d3c:	eb e4                	jmp    801d22 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d3e:	8b 55 14             	mov    0x14(%ebp),%edx
  801d41:	8d 42 04             	lea    0x4(%edx),%eax
  801d44:	89 45 14             	mov    %eax,0x14(%ebp)
  801d47:	8b 12                	mov    (%edx),%edx
  801d49:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d4c:	eb 12                	jmp    801d60 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  801d4e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d52:	79 96                	jns    801cea <vprintfmt+0x5e>
  801d54:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d5b:	eb 8d                	jmp    801cea <vprintfmt+0x5e>
  801d5d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  801d60:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d64:	79 84                	jns    801cea <vprintfmt+0x5e>
  801d66:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d6c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  801d73:	e9 72 ff ff ff       	jmp    801cea <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801d78:	ff 45 d4             	incl   -0x2c(%ebp)
  801d7b:	e9 6a ff ff ff       	jmp    801cea <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801d80:	8b 55 14             	mov    0x14(%ebp),%edx
  801d83:	8d 42 04             	lea    0x4(%edx),%eax
  801d86:	89 45 14             	mov    %eax,0x14(%ebp)
  801d89:	83 ec 08             	sub    $0x8,%esp
  801d8c:	57                   	push   %edi
  801d8d:	ff 32                	pushl  (%edx)
  801d8f:	ff d6                	call   *%esi
			break;
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	e9 07 ff ff ff       	jmp    801ca0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801d99:	8b 55 14             	mov    0x14(%ebp),%edx
  801d9c:	8d 42 04             	lea    0x4(%edx),%eax
  801d9f:	89 45 14             	mov    %eax,0x14(%ebp)
  801da2:	8b 02                	mov    (%edx),%eax
  801da4:	85 c0                	test   %eax,%eax
  801da6:	79 02                	jns    801daa <vprintfmt+0x11e>
  801da8:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801daa:	83 f8 0f             	cmp    $0xf,%eax
  801dad:	7f 0b                	jg     801dba <vprintfmt+0x12e>
  801daf:	8b 14 85 60 40 80 00 	mov    0x804060(,%eax,4),%edx
  801db6:	85 d2                	test   %edx,%edx
  801db8:	75 15                	jne    801dcf <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  801dba:	50                   	push   %eax
  801dbb:	68 d4 3d 80 00       	push   $0x803dd4
  801dc0:	57                   	push   %edi
  801dc1:	56                   	push   %esi
  801dc2:	e8 6e 02 00 00       	call   802035 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801dc7:	83 c4 10             	add    $0x10,%esp
  801dca:	e9 d1 fe ff ff       	jmp    801ca0 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801dcf:	52                   	push   %edx
  801dd0:	68 4f 38 80 00       	push   $0x80384f
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	e8 59 02 00 00       	call   802035 <printfmt>
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	e9 bc fe ff ff       	jmp    801ca0 <vprintfmt+0x14>
  801de4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801de7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801dea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ded:	8b 55 14             	mov    0x14(%ebp),%edx
  801df0:	8d 42 04             	lea    0x4(%edx),%eax
  801df3:	89 45 14             	mov    %eax,0x14(%ebp)
  801df6:	8b 1a                	mov    (%edx),%ebx
  801df8:	85 db                	test   %ebx,%ebx
  801dfa:	75 05                	jne    801e01 <vprintfmt+0x175>
  801dfc:	bb dd 3d 80 00       	mov    $0x803ddd,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  801e01:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801e05:	7e 66                	jle    801e6d <vprintfmt+0x1e1>
  801e07:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  801e0b:	74 60                	je     801e6d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e0d:	83 ec 08             	sub    $0x8,%esp
  801e10:	51                   	push   %ecx
  801e11:	53                   	push   %ebx
  801e12:	e8 57 02 00 00       	call   80206e <strnlen>
  801e17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e1a:	29 c1                	sub    %eax,%ecx
  801e1c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  801e26:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  801e29:	eb 0f                	jmp    801e3a <vprintfmt+0x1ae>
					putch(padc, putdat);
  801e2b:	83 ec 08             	sub    $0x8,%esp
  801e2e:	57                   	push   %edi
  801e2f:	ff 75 c4             	pushl  -0x3c(%ebp)
  801e32:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801e34:	ff 4d d8             	decl   -0x28(%ebp)
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e3e:	7f eb                	jg     801e2b <vprintfmt+0x19f>
  801e40:	eb 2b                	jmp    801e6d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801e42:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  801e45:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e49:	74 15                	je     801e60 <vprintfmt+0x1d4>
  801e4b:	8d 42 e0             	lea    -0x20(%edx),%eax
  801e4e:	83 f8 5e             	cmp    $0x5e,%eax
  801e51:	76 0d                	jbe    801e60 <vprintfmt+0x1d4>
					putch('?', putdat);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	57                   	push   %edi
  801e57:	6a 3f                	push   $0x3f
  801e59:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	eb 0a                	jmp    801e6a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801e60:	83 ec 08             	sub    $0x8,%esp
  801e63:	57                   	push   %edi
  801e64:	52                   	push   %edx
  801e65:	ff d6                	call   *%esi
  801e67:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801e6a:	ff 4d d8             	decl   -0x28(%ebp)
  801e6d:	8a 03                	mov    (%ebx),%al
  801e6f:	43                   	inc    %ebx
  801e70:	84 c0                	test   %al,%al
  801e72:	74 1b                	je     801e8f <vprintfmt+0x203>
  801e74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e78:	78 c8                	js     801e42 <vprintfmt+0x1b6>
  801e7a:	ff 4d dc             	decl   -0x24(%ebp)
  801e7d:	79 c3                	jns    801e42 <vprintfmt+0x1b6>
  801e7f:	eb 0e                	jmp    801e8f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e81:	83 ec 08             	sub    $0x8,%esp
  801e84:	57                   	push   %edi
  801e85:	6a 20                	push   $0x20
  801e87:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e89:	ff 4d d8             	decl   -0x28(%ebp)
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801e93:	7f ec                	jg     801e81 <vprintfmt+0x1f5>
  801e95:	e9 06 fe ff ff       	jmp    801ca0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e9a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801e9e:	7e 10                	jle    801eb0 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  801ea0:	8b 55 14             	mov    0x14(%ebp),%edx
  801ea3:	8d 42 08             	lea    0x8(%edx),%eax
  801ea6:	89 45 14             	mov    %eax,0x14(%ebp)
  801ea9:	8b 02                	mov    (%edx),%eax
  801eab:	8b 52 04             	mov    0x4(%edx),%edx
  801eae:	eb 20                	jmp    801ed0 <vprintfmt+0x244>
	else if (lflag)
  801eb0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801eb4:	74 0e                	je     801ec4 <vprintfmt+0x238>
		return va_arg(*ap, long);
  801eb6:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb9:	8d 50 04             	lea    0x4(%eax),%edx
  801ebc:	89 55 14             	mov    %edx,0x14(%ebp)
  801ebf:	8b 00                	mov    (%eax),%eax
  801ec1:	99                   	cltd   
  801ec2:	eb 0c                	jmp    801ed0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  801ec4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ec7:	8d 50 04             	lea    0x4(%eax),%edx
  801eca:	89 55 14             	mov    %edx,0x14(%ebp)
  801ecd:	8b 00                	mov    (%eax),%eax
  801ecf:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ed0:	89 d1                	mov    %edx,%ecx
  801ed2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  801ed4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801ed7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801eda:	85 c9                	test   %ecx,%ecx
  801edc:	78 0a                	js     801ee8 <vprintfmt+0x25c>
  801ede:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ee3:	e9 89 00 00 00       	jmp    801f71 <vprintfmt+0x2e5>
				putch('-', putdat);
  801ee8:	83 ec 08             	sub    $0x8,%esp
  801eeb:	57                   	push   %edi
  801eec:	6a 2d                	push   $0x2d
  801eee:	ff d6                	call   *%esi
				num = -(long long) num;
  801ef0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  801ef3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801ef6:	f7 da                	neg    %edx
  801ef8:	83 d1 00             	adc    $0x0,%ecx
  801efb:	f7 d9                	neg    %ecx
  801efd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	eb 6a                	jmp    801f71 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801f07:	8d 45 14             	lea    0x14(%ebp),%eax
  801f0a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801f0d:	e8 22 fd ff ff       	call   801c34 <getuint>
  801f12:	89 d1                	mov    %edx,%ecx
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801f1b:	eb 54                	jmp    801f71 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801f1d:	8d 45 14             	lea    0x14(%ebp),%eax
  801f20:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801f23:	e8 0c fd ff ff       	call   801c34 <getuint>
  801f28:	89 d1                	mov    %edx,%ecx
  801f2a:	89 c2                	mov    %eax,%edx
  801f2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801f31:	eb 3e                	jmp    801f71 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801f33:	83 ec 08             	sub    $0x8,%esp
  801f36:	57                   	push   %edi
  801f37:	6a 30                	push   $0x30
  801f39:	ff d6                	call   *%esi
			putch('x', putdat);
  801f3b:	83 c4 08             	add    $0x8,%esp
  801f3e:	57                   	push   %edi
  801f3f:	6a 78                	push   $0x78
  801f41:	ff d6                	call   *%esi
			num = (unsigned long long)
  801f43:	8b 55 14             	mov    0x14(%ebp),%edx
  801f46:	8d 42 04             	lea    0x4(%edx),%eax
  801f49:	89 45 14             	mov    %eax,0x14(%ebp)
  801f4c:	8b 12                	mov    (%edx),%edx
  801f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f53:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	eb 14                	jmp    801f71 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f5d:	8d 45 14             	lea    0x14(%ebp),%eax
  801f60:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801f63:	e8 cc fc ff ff       	call   801c34 <getuint>
  801f68:	89 d1                	mov    %edx,%ecx
  801f6a:	89 c2                	mov    %eax,%edx
  801f6c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f71:	83 ec 0c             	sub    $0xc,%esp
  801f74:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  801f78:	50                   	push   %eax
  801f79:	ff 75 d8             	pushl  -0x28(%ebp)
  801f7c:	53                   	push   %ebx
  801f7d:	51                   	push   %ecx
  801f7e:	52                   	push   %edx
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	89 f0                	mov    %esi,%eax
  801f83:	e8 08 fc ff ff       	call   801b90 <printnum>
			break;
  801f88:	83 c4 20             	add    $0x20,%esp
  801f8b:	e9 10 fd ff ff       	jmp    801ca0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f90:	83 ec 08             	sub    $0x8,%esp
  801f93:	57                   	push   %edi
  801f94:	52                   	push   %edx
  801f95:	ff d6                	call   *%esi
			break;
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	e9 01 fd ff ff       	jmp    801ca0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f9f:	83 ec 08             	sub    $0x8,%esp
  801fa2:	57                   	push   %edi
  801fa3:	6a 25                	push   $0x25
  801fa5:	ff d6                	call   *%esi
  801fa7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801faa:	83 ea 02             	sub    $0x2,%edx
  801fad:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  801fb0:	8a 02                	mov    (%edx),%al
  801fb2:	4a                   	dec    %edx
  801fb3:	3c 25                	cmp    $0x25,%al
  801fb5:	75 f9                	jne    801fb0 <vprintfmt+0x324>
  801fb7:	83 c2 02             	add    $0x2,%edx
  801fba:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801fbd:	e9 de fc ff ff       	jmp    801ca0 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  801fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc5:	5b                   	pop    %ebx
  801fc6:	5e                   	pop    %esi
  801fc7:	5f                   	pop    %edi
  801fc8:	c9                   	leave  
  801fc9:	c3                   	ret    

00801fca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	83 ec 18             	sub    $0x18,%esp
  801fd0:	8b 55 08             	mov    0x8(%ebp),%edx
  801fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801fd6:	85 d2                	test   %edx,%edx
  801fd8:	74 37                	je     802011 <vsnprintf+0x47>
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	7e 33                	jle    802011 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801fde:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801fe5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801fe9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  801fec:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fef:	ff 75 14             	pushl  0x14(%ebp)
  801ff2:	ff 75 10             	pushl  0x10(%ebp)
  801ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff8:	50                   	push   %eax
  801ff9:	68 70 1c 80 00       	push   $0x801c70
  801ffe:	e8 89 fc ff ff       	call   801c8c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802003:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802006:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802009:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	eb 05                	jmp    802016 <vsnprintf+0x4c>
  802011:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80201e:	8d 45 14             	lea    0x14(%ebp),%eax
  802021:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  802024:	50                   	push   %eax
  802025:	ff 75 10             	pushl  0x10(%ebp)
  802028:	ff 75 0c             	pushl  0xc(%ebp)
  80202b:	ff 75 08             	pushl  0x8(%ebp)
  80202e:	e8 97 ff ff ff       	call   801fca <vsnprintf>
	va_end(ap);

	return rc;
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    

00802035 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802035:	55                   	push   %ebp
  802036:	89 e5                	mov    %esp,%ebp
  802038:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80203b:	8d 45 14             	lea    0x14(%ebp),%eax
  80203e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  802041:	50                   	push   %eax
  802042:	ff 75 10             	pushl  0x10(%ebp)
  802045:	ff 75 0c             	pushl  0xc(%ebp)
  802048:	ff 75 08             	pushl  0x8(%ebp)
  80204b:	e8 3c fc ff ff       	call   801c8c <vprintfmt>
	va_end(ap);
  802050:	83 c4 10             	add    $0x10,%esp
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    
  802055:	00 00                	add    %al,(%eax)
	...

00802058 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	8b 55 08             	mov    0x8(%ebp),%edx
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
  802063:	eb 01                	jmp    802066 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  802065:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802066:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80206a:	75 f9                	jne    802065 <strlen+0xd>
		n++;
	return n;
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802074:	8b 55 0c             	mov    0xc(%ebp),%edx
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
  80207c:	eb 01                	jmp    80207f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80207e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80207f:	39 d0                	cmp    %edx,%eax
  802081:	74 06                	je     802089 <strnlen+0x1b>
  802083:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  802087:	75 f5                	jne    80207e <strnlen+0x10>
		n++;
	return n;
}
  802089:	c9                   	leave  
  80208a:	c3                   	ret    

0080208b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80208b:	55                   	push   %ebp
  80208c:	89 e5                	mov    %esp,%ebp
  80208e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802091:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802094:	8a 01                	mov    (%ecx),%al
  802096:	88 02                	mov    %al,(%edx)
  802098:	42                   	inc    %edx
  802099:	41                   	inc    %ecx
  80209a:	84 c0                	test   %al,%al
  80209c:	75 f6                	jne    802094 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80209e:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a1:	c9                   	leave  
  8020a2:	c3                   	ret    

008020a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	53                   	push   %ebx
  8020a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8020aa:	53                   	push   %ebx
  8020ab:	e8 a8 ff ff ff       	call   802058 <strlen>
	strcpy(dst + len, src);
  8020b0:	ff 75 0c             	pushl  0xc(%ebp)
  8020b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8020b6:	50                   	push   %eax
  8020b7:	e8 cf ff ff ff       	call   80208b <strcpy>
	return dst;
}
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	56                   	push   %esi
  8020c7:	53                   	push   %ebx
  8020c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020d6:	eb 0c                	jmp    8020e4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8020d8:	8a 02                	mov    (%edx),%al
  8020da:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8020dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8020e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020e3:	41                   	inc    %ecx
  8020e4:	39 d9                	cmp    %ebx,%ecx
  8020e6:	75 f0                	jne    8020d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8020e8:	89 f0                	mov    %esi,%eax
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8020fc:	85 c9                	test   %ecx,%ecx
  8020fe:	75 04                	jne    802104 <strlcpy+0x16>
  802100:	89 f0                	mov    %esi,%eax
  802102:	eb 14                	jmp    802118 <strlcpy+0x2a>
  802104:	89 f0                	mov    %esi,%eax
  802106:	eb 04                	jmp    80210c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802108:	88 10                	mov    %dl,(%eax)
  80210a:	40                   	inc    %eax
  80210b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80210c:	49                   	dec    %ecx
  80210d:	74 06                	je     802115 <strlcpy+0x27>
  80210f:	8a 13                	mov    (%ebx),%dl
  802111:	84 d2                	test   %dl,%dl
  802113:	75 f3                	jne    802108 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  802115:	c6 00 00             	movb   $0x0,(%eax)
  802118:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  80211a:	5b                   	pop    %ebx
  80211b:	5e                   	pop    %esi
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	8b 55 08             	mov    0x8(%ebp),%edx
  802124:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802127:	eb 02                	jmp    80212b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  802129:	42                   	inc    %edx
  80212a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80212b:	8a 02                	mov    (%edx),%al
  80212d:	84 c0                	test   %al,%al
  80212f:	74 04                	je     802135 <strcmp+0x17>
  802131:	3a 01                	cmp    (%ecx),%al
  802133:	74 f4                	je     802129 <strcmp+0xb>
  802135:	0f b6 c0             	movzbl %al,%eax
  802138:	0f b6 11             	movzbl (%ecx),%edx
  80213b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80213d:	c9                   	leave  
  80213e:	c3                   	ret    

0080213f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	53                   	push   %ebx
  802143:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802149:	8b 55 10             	mov    0x10(%ebp),%edx
  80214c:	eb 03                	jmp    802151 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  80214e:	4a                   	dec    %edx
  80214f:	41                   	inc    %ecx
  802150:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802151:	85 d2                	test   %edx,%edx
  802153:	75 07                	jne    80215c <strncmp+0x1d>
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
  80215a:	eb 14                	jmp    802170 <strncmp+0x31>
  80215c:	8a 01                	mov    (%ecx),%al
  80215e:	84 c0                	test   %al,%al
  802160:	74 04                	je     802166 <strncmp+0x27>
  802162:	3a 03                	cmp    (%ebx),%al
  802164:	74 e8                	je     80214e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802166:	0f b6 d0             	movzbl %al,%edx
  802169:	0f b6 03             	movzbl (%ebx),%eax
  80216c:	29 c2                	sub    %eax,%edx
  80216e:	89 d0                	mov    %edx,%eax
}
  802170:	5b                   	pop    %ebx
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	8b 45 08             	mov    0x8(%ebp),%eax
  802179:	8a 4d 0c             	mov    0xc(%ebp),%cl
  80217c:	eb 05                	jmp    802183 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  80217e:	38 ca                	cmp    %cl,%dl
  802180:	74 0c                	je     80218e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802182:	40                   	inc    %eax
  802183:	8a 10                	mov    (%eax),%dl
  802185:	84 d2                	test   %dl,%dl
  802187:	75 f5                	jne    80217e <strchr+0xb>
  802189:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
  802196:	8a 4d 0c             	mov    0xc(%ebp),%cl
  802199:	eb 05                	jmp    8021a0 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  80219b:	38 ca                	cmp    %cl,%dl
  80219d:	74 07                	je     8021a6 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80219f:	40                   	inc    %eax
  8021a0:	8a 10                	mov    (%eax),%dl
  8021a2:	84 d2                	test   %dl,%dl
  8021a4:	75 f5                	jne    80219b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    

008021a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	57                   	push   %edi
  8021ac:	56                   	push   %esi
  8021ad:	53                   	push   %ebx
  8021ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  8021b7:	85 db                	test   %ebx,%ebx
  8021b9:	74 36                	je     8021f1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8021bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021c1:	75 29                	jne    8021ec <memset+0x44>
  8021c3:	f6 c3 03             	test   $0x3,%bl
  8021c6:	75 24                	jne    8021ec <memset+0x44>
		c &= 0xFF;
  8021c8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8021cb:	89 d6                	mov    %edx,%esi
  8021cd:	c1 e6 08             	shl    $0x8,%esi
  8021d0:	89 d0                	mov    %edx,%eax
  8021d2:	c1 e0 18             	shl    $0x18,%eax
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	c1 e1 10             	shl    $0x10,%ecx
  8021da:	09 c8                	or     %ecx,%eax
  8021dc:	09 c2                	or     %eax,%edx
  8021de:	89 f0                	mov    %esi,%eax
  8021e0:	09 d0                	or     %edx,%eax
  8021e2:	89 d9                	mov    %ebx,%ecx
  8021e4:	c1 e9 02             	shr    $0x2,%ecx
  8021e7:	fc                   	cld    
  8021e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8021ea:	eb 05                	jmp    8021f1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8021ec:	89 d9                	mov    %ebx,%ecx
  8021ee:	fc                   	cld    
  8021ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8021f1:	89 f8                	mov    %edi,%eax
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	c9                   	leave  
  8021f7:	c3                   	ret    

008021f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	57                   	push   %edi
  8021fc:	56                   	push   %esi
  8021fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802200:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  802203:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  802206:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  802208:	39 c6                	cmp    %eax,%esi
  80220a:	73 36                	jae    802242 <memmove+0x4a>
  80220c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80220f:	39 d0                	cmp    %edx,%eax
  802211:	73 2f                	jae    802242 <memmove+0x4a>
		s += n;
		d += n;
  802213:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802216:	f6 c2 03             	test   $0x3,%dl
  802219:	75 1b                	jne    802236 <memmove+0x3e>
  80221b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802221:	75 13                	jne    802236 <memmove+0x3e>
  802223:	f6 c1 03             	test   $0x3,%cl
  802226:	75 0e                	jne    802236 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  802228:	8d 7e fc             	lea    -0x4(%esi),%edi
  80222b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80222e:	c1 e9 02             	shr    $0x2,%ecx
  802231:	fd                   	std    
  802232:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802234:	eb 09                	jmp    80223f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802236:	8d 7e ff             	lea    -0x1(%esi),%edi
  802239:	8d 72 ff             	lea    -0x1(%edx),%esi
  80223c:	fd                   	std    
  80223d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80223f:	fc                   	cld    
  802240:	eb 20                	jmp    802262 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802242:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802248:	75 15                	jne    80225f <memmove+0x67>
  80224a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802250:	75 0d                	jne    80225f <memmove+0x67>
  802252:	f6 c1 03             	test   $0x3,%cl
  802255:	75 08                	jne    80225f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  802257:	c1 e9 02             	shr    $0x2,%ecx
  80225a:	fc                   	cld    
  80225b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80225d:	eb 03                	jmp    802262 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80225f:	fc                   	cld    
  802260:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	c9                   	leave  
  802265:	c3                   	ret    

00802266 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802269:	ff 75 10             	pushl  0x10(%ebp)
  80226c:	ff 75 0c             	pushl  0xc(%ebp)
  80226f:	ff 75 08             	pushl  0x8(%ebp)
  802272:	e8 81 ff ff ff       	call   8021f8 <memmove>
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	53                   	push   %ebx
  80227d:	83 ec 04             	sub    $0x4,%esp
  802280:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  802283:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  802286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802289:	eb 1b                	jmp    8022a6 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  80228b:	8a 1a                	mov    (%edx),%bl
  80228d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  802290:	8a 19                	mov    (%ecx),%bl
  802292:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  802295:	74 0d                	je     8022a4 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  802297:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  80229b:	0f b6 c3             	movzbl %bl,%eax
  80229e:	29 c2                	sub    %eax,%edx
  8022a0:	89 d0                	mov    %edx,%eax
  8022a2:	eb 0d                	jmp    8022b1 <memcmp+0x38>
		s1++, s2++;
  8022a4:	42                   	inc    %edx
  8022a5:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8022a6:	48                   	dec    %eax
  8022a7:	83 f8 ff             	cmp    $0xffffffff,%eax
  8022aa:	75 df                	jne    80228b <memcmp+0x12>
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8022b1:	83 c4 04             	add    $0x4,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8022c0:	89 c2                	mov    %eax,%edx
  8022c2:	03 55 10             	add    0x10(%ebp),%edx
  8022c5:	eb 05                	jmp    8022cc <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8022c7:	38 08                	cmp    %cl,(%eax)
  8022c9:	74 05                	je     8022d0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8022cb:	40                   	inc    %eax
  8022cc:	39 d0                	cmp    %edx,%eax
  8022ce:	72 f7                	jb     8022c7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	57                   	push   %edi
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
  8022d8:	83 ec 04             	sub    $0x4,%esp
  8022db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022de:	8b 75 10             	mov    0x10(%ebp),%esi
  8022e1:	eb 01                	jmp    8022e4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  8022e3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8022e4:	8a 01                	mov    (%ecx),%al
  8022e6:	3c 20                	cmp    $0x20,%al
  8022e8:	74 f9                	je     8022e3 <strtol+0x11>
  8022ea:	3c 09                	cmp    $0x9,%al
  8022ec:	74 f5                	je     8022e3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  8022ee:	3c 2b                	cmp    $0x2b,%al
  8022f0:	75 0a                	jne    8022fc <strtol+0x2a>
		s++;
  8022f2:	41                   	inc    %ecx
  8022f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8022fa:	eb 17                	jmp    802313 <strtol+0x41>
	else if (*s == '-')
  8022fc:	3c 2d                	cmp    $0x2d,%al
  8022fe:	74 09                	je     802309 <strtol+0x37>
  802300:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802307:	eb 0a                	jmp    802313 <strtol+0x41>
		s++, neg = 1;
  802309:	8d 49 01             	lea    0x1(%ecx),%ecx
  80230c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802313:	85 f6                	test   %esi,%esi
  802315:	74 05                	je     80231c <strtol+0x4a>
  802317:	83 fe 10             	cmp    $0x10,%esi
  80231a:	75 1a                	jne    802336 <strtol+0x64>
  80231c:	8a 01                	mov    (%ecx),%al
  80231e:	3c 30                	cmp    $0x30,%al
  802320:	75 10                	jne    802332 <strtol+0x60>
  802322:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802326:	75 0a                	jne    802332 <strtol+0x60>
		s += 2, base = 16;
  802328:	83 c1 02             	add    $0x2,%ecx
  80232b:	be 10 00 00 00       	mov    $0x10,%esi
  802330:	eb 04                	jmp    802336 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  802332:	85 f6                	test   %esi,%esi
  802334:	74 07                	je     80233d <strtol+0x6b>
  802336:	bf 00 00 00 00       	mov    $0x0,%edi
  80233b:	eb 13                	jmp    802350 <strtol+0x7e>
  80233d:	3c 30                	cmp    $0x30,%al
  80233f:	74 07                	je     802348 <strtol+0x76>
  802341:	be 0a 00 00 00       	mov    $0xa,%esi
  802346:	eb ee                	jmp    802336 <strtol+0x64>
		s++, base = 8;
  802348:	41                   	inc    %ecx
  802349:	be 08 00 00 00       	mov    $0x8,%esi
  80234e:	eb e6                	jmp    802336 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802350:	8a 11                	mov    (%ecx),%dl
  802352:	88 d3                	mov    %dl,%bl
  802354:	8d 42 d0             	lea    -0x30(%edx),%eax
  802357:	3c 09                	cmp    $0x9,%al
  802359:	77 08                	ja     802363 <strtol+0x91>
			dig = *s - '0';
  80235b:	0f be c2             	movsbl %dl,%eax
  80235e:	8d 50 d0             	lea    -0x30(%eax),%edx
  802361:	eb 1c                	jmp    80237f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  802363:	8d 43 9f             	lea    -0x61(%ebx),%eax
  802366:	3c 19                	cmp    $0x19,%al
  802368:	77 08                	ja     802372 <strtol+0xa0>
			dig = *s - 'a' + 10;
  80236a:	0f be c2             	movsbl %dl,%eax
  80236d:	8d 50 a9             	lea    -0x57(%eax),%edx
  802370:	eb 0d                	jmp    80237f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802372:	8d 43 bf             	lea    -0x41(%ebx),%eax
  802375:	3c 19                	cmp    $0x19,%al
  802377:	77 15                	ja     80238e <strtol+0xbc>
			dig = *s - 'A' + 10;
  802379:	0f be c2             	movsbl %dl,%eax
  80237c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  80237f:	39 f2                	cmp    %esi,%edx
  802381:	7d 0b                	jge    80238e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  802383:	41                   	inc    %ecx
  802384:	89 f8                	mov    %edi,%eax
  802386:	0f af c6             	imul   %esi,%eax
  802389:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  80238c:	eb c2                	jmp    802350 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  80238e:	89 f8                	mov    %edi,%eax

	if (endptr)
  802390:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802394:	74 05                	je     80239b <strtol+0xc9>
		*endptr = (char *) s;
  802396:	8b 55 0c             	mov    0xc(%ebp),%edx
  802399:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  80239b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80239f:	74 04                	je     8023a5 <strtol+0xd3>
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	f7 df                	neg    %edi
}
  8023a5:	89 f8                	mov    %edi,%eax
  8023a7:	83 c4 04             	add    $0x4,%esp
  8023aa:	5b                   	pop    %ebx
  8023ab:	5e                   	pop    %esi
  8023ac:	5f                   	pop    %edi
  8023ad:	c9                   	leave  
  8023ae:	c3                   	ret    
	...

008023b0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8023b0:	55                   	push   %ebp
  8023b1:	89 e5                	mov    %esp,%ebp
  8023b3:	57                   	push   %edi
  8023b4:	56                   	push   %esi
  8023b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8023c0:	89 fa                	mov    %edi,%edx
  8023c2:	89 f9                	mov    %edi,%ecx
  8023c4:	89 fb                	mov    %edi,%ebx
  8023c6:	89 fe                	mov    %edi,%esi
  8023c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8023ca:	5b                   	pop    %ebx
  8023cb:	5e                   	pop    %esi
  8023cc:	5f                   	pop    %edi
  8023cd:	c9                   	leave  
  8023ce:	c3                   	ret    

008023cf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8023cf:	55                   	push   %ebp
  8023d0:	89 e5                	mov    %esp,%ebp
  8023d2:	57                   	push   %edi
  8023d3:	56                   	push   %esi
  8023d4:	53                   	push   %ebx
  8023d5:	83 ec 04             	sub    $0x4,%esp
  8023d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8023db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023de:	bf 00 00 00 00       	mov    $0x0,%edi
  8023e3:	89 f8                	mov    %edi,%eax
  8023e5:	89 fb                	mov    %edi,%ebx
  8023e7:	89 fe                	mov    %edi,%esi
  8023e9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8023eb:	83 c4 04             	add    $0x4,%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	c9                   	leave  
  8023f2:	c3                   	ret    

008023f3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	57                   	push   %edi
  8023f7:	56                   	push   %esi
  8023f8:	53                   	push   %ebx
  8023f9:	83 ec 0c             	sub    $0xc,%esp
  8023fc:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  802404:	bf 00 00 00 00       	mov    $0x0,%edi
  802409:	89 f9                	mov    %edi,%ecx
  80240b:	89 fb                	mov    %edi,%ebx
  80240d:	89 fe                	mov    %edi,%esi
  80240f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802411:	85 c0                	test   %eax,%eax
  802413:	7e 17                	jle    80242c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802415:	83 ec 0c             	sub    $0xc,%esp
  802418:	50                   	push   %eax
  802419:	6a 0d                	push   $0xd
  80241b:	68 bf 40 80 00       	push   $0x8040bf
  802420:	6a 23                	push   $0x23
  802422:	68 dc 40 80 00       	push   $0x8040dc
  802427:	e8 6c f6 ff ff       	call   801a98 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80242c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80242f:	5b                   	pop    %ebx
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	c9                   	leave  
  802433:	c3                   	ret    

00802434 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802434:	55                   	push   %ebp
  802435:	89 e5                	mov    %esp,%ebp
  802437:	57                   	push   %edi
  802438:	56                   	push   %esi
  802439:	53                   	push   %ebx
  80243a:	8b 55 08             	mov    0x8(%ebp),%edx
  80243d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802440:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802443:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802446:	b8 0c 00 00 00       	mov    $0xc,%eax
  80244b:	be 00 00 00 00       	mov    $0x0,%esi
  802450:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802452:	5b                   	pop    %ebx
  802453:	5e                   	pop    %esi
  802454:	5f                   	pop    %edi
  802455:	c9                   	leave  
  802456:	c3                   	ret    

00802457 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	57                   	push   %edi
  80245b:	56                   	push   %esi
  80245c:	53                   	push   %ebx
  80245d:	83 ec 0c             	sub    $0xc,%esp
  802460:	8b 55 08             	mov    0x8(%ebp),%edx
  802463:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802466:	b8 0a 00 00 00       	mov    $0xa,%eax
  80246b:	bf 00 00 00 00       	mov    $0x0,%edi
  802470:	89 fb                	mov    %edi,%ebx
  802472:	89 fe                	mov    %edi,%esi
  802474:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802476:	85 c0                	test   %eax,%eax
  802478:	7e 17                	jle    802491 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80247a:	83 ec 0c             	sub    $0xc,%esp
  80247d:	50                   	push   %eax
  80247e:	6a 0a                	push   $0xa
  802480:	68 bf 40 80 00       	push   $0x8040bf
  802485:	6a 23                	push   $0x23
  802487:	68 dc 40 80 00       	push   $0x8040dc
  80248c:	e8 07 f6 ff ff       	call   801a98 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802494:	5b                   	pop    %ebx
  802495:	5e                   	pop    %esi
  802496:	5f                   	pop    %edi
  802497:	c9                   	leave  
  802498:	c3                   	ret    

00802499 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802499:	55                   	push   %ebp
  80249a:	89 e5                	mov    %esp,%ebp
  80249c:	57                   	push   %edi
  80249d:	56                   	push   %esi
  80249e:	53                   	push   %ebx
  80249f:	83 ec 0c             	sub    $0xc,%esp
  8024a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8024a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024a8:	b8 09 00 00 00       	mov    $0x9,%eax
  8024ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8024b2:	89 fb                	mov    %edi,%ebx
  8024b4:	89 fe                	mov    %edi,%esi
  8024b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024b8:	85 c0                	test   %eax,%eax
  8024ba:	7e 17                	jle    8024d3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024bc:	83 ec 0c             	sub    $0xc,%esp
  8024bf:	50                   	push   %eax
  8024c0:	6a 09                	push   $0x9
  8024c2:	68 bf 40 80 00       	push   $0x8040bf
  8024c7:	6a 23                	push   $0x23
  8024c9:	68 dc 40 80 00       	push   $0x8040dc
  8024ce:	e8 c5 f5 ff ff       	call   801a98 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8024d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d6:	5b                   	pop    %ebx
  8024d7:	5e                   	pop    %esi
  8024d8:	5f                   	pop    %edi
  8024d9:	c9                   	leave  
  8024da:	c3                   	ret    

008024db <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024db:	55                   	push   %ebp
  8024dc:	89 e5                	mov    %esp,%ebp
  8024de:	57                   	push   %edi
  8024df:	56                   	push   %esi
  8024e0:	53                   	push   %ebx
  8024e1:	83 ec 0c             	sub    $0xc,%esp
  8024e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8024e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8024ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8024f4:	89 fb                	mov    %edi,%ebx
  8024f6:	89 fe                	mov    %edi,%esi
  8024f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024fa:	85 c0                	test   %eax,%eax
  8024fc:	7e 17                	jle    802515 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024fe:	83 ec 0c             	sub    $0xc,%esp
  802501:	50                   	push   %eax
  802502:	6a 08                	push   $0x8
  802504:	68 bf 40 80 00       	push   $0x8040bf
  802509:	6a 23                	push   $0x23
  80250b:	68 dc 40 80 00       	push   $0x8040dc
  802510:	e8 83 f5 ff ff       	call   801a98 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802515:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802518:	5b                   	pop    %ebx
  802519:	5e                   	pop    %esi
  80251a:	5f                   	pop    %edi
  80251b:	c9                   	leave  
  80251c:	c3                   	ret    

0080251d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80251d:	55                   	push   %ebp
  80251e:	89 e5                	mov    %esp,%ebp
  802520:	57                   	push   %edi
  802521:	56                   	push   %esi
  802522:	53                   	push   %ebx
  802523:	83 ec 0c             	sub    $0xc,%esp
  802526:	8b 55 08             	mov    0x8(%ebp),%edx
  802529:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80252c:	b8 06 00 00 00       	mov    $0x6,%eax
  802531:	bf 00 00 00 00       	mov    $0x0,%edi
  802536:	89 fb                	mov    %edi,%ebx
  802538:	89 fe                	mov    %edi,%esi
  80253a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80253c:	85 c0                	test   %eax,%eax
  80253e:	7e 17                	jle    802557 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802540:	83 ec 0c             	sub    $0xc,%esp
  802543:	50                   	push   %eax
  802544:	6a 06                	push   $0x6
  802546:	68 bf 40 80 00       	push   $0x8040bf
  80254b:	6a 23                	push   $0x23
  80254d:	68 dc 40 80 00       	push   $0x8040dc
  802552:	e8 41 f5 ff ff       	call   801a98 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802557:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5f                   	pop    %edi
  80255d:	c9                   	leave  
  80255e:	c3                   	ret    

0080255f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80255f:	55                   	push   %ebp
  802560:	89 e5                	mov    %esp,%ebp
  802562:	57                   	push   %edi
  802563:	56                   	push   %esi
  802564:	53                   	push   %ebx
  802565:	83 ec 0c             	sub    $0xc,%esp
  802568:	8b 55 08             	mov    0x8(%ebp),%edx
  80256b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802571:	8b 7d 14             	mov    0x14(%ebp),%edi
  802574:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802577:	b8 05 00 00 00       	mov    $0x5,%eax
  80257c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80257e:	85 c0                	test   %eax,%eax
  802580:	7e 17                	jle    802599 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802582:	83 ec 0c             	sub    $0xc,%esp
  802585:	50                   	push   %eax
  802586:	6a 05                	push   $0x5
  802588:	68 bf 40 80 00       	push   $0x8040bf
  80258d:	6a 23                	push   $0x23
  80258f:	68 dc 40 80 00       	push   $0x8040dc
  802594:	e8 ff f4 ff ff       	call   801a98 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802599:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5f                   	pop    %edi
  80259f:	c9                   	leave  
  8025a0:	c3                   	ret    

008025a1 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8025a1:	55                   	push   %ebp
  8025a2:	89 e5                	mov    %esp,%ebp
  8025a4:	57                   	push   %edi
  8025a5:	56                   	push   %esi
  8025a6:	53                   	push   %ebx
  8025a7:	83 ec 0c             	sub    $0xc,%esp
  8025aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8025b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8025bd:	89 fe                	mov    %edi,%esi
  8025bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025c1:	85 c0                	test   %eax,%eax
  8025c3:	7e 17                	jle    8025dc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025c5:	83 ec 0c             	sub    $0xc,%esp
  8025c8:	50                   	push   %eax
  8025c9:	6a 04                	push   $0x4
  8025cb:	68 bf 40 80 00       	push   $0x8040bf
  8025d0:	6a 23                	push   $0x23
  8025d2:	68 dc 40 80 00       	push   $0x8040dc
  8025d7:	e8 bc f4 ff ff       	call   801a98 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
  8025e7:	57                   	push   %edi
  8025e8:	56                   	push   %esi
  8025e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ea:	b8 0b 00 00 00       	mov    $0xb,%eax
  8025ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8025f4:	89 fa                	mov    %edi,%edx
  8025f6:	89 f9                	mov    %edi,%ecx
  8025f8:	89 fb                	mov    %edi,%ebx
  8025fa:	89 fe                	mov    %edi,%esi
  8025fc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8025fe:	5b                   	pop    %ebx
  8025ff:	5e                   	pop    %esi
  802600:	5f                   	pop    %edi
  802601:	c9                   	leave  
  802602:	c3                   	ret    

00802603 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  802603:	55                   	push   %ebp
  802604:	89 e5                	mov    %esp,%ebp
  802606:	57                   	push   %edi
  802607:	56                   	push   %esi
  802608:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802609:	b8 02 00 00 00       	mov    $0x2,%eax
  80260e:	bf 00 00 00 00       	mov    $0x0,%edi
  802613:	89 fa                	mov    %edi,%edx
  802615:	89 f9                	mov    %edi,%ecx
  802617:	89 fb                	mov    %edi,%ebx
  802619:	89 fe                	mov    %edi,%esi
  80261b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	c9                   	leave  
  802621:	c3                   	ret    

00802622 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  802622:	55                   	push   %ebp
  802623:	89 e5                	mov    %esp,%ebp
  802625:	57                   	push   %edi
  802626:	56                   	push   %esi
  802627:	53                   	push   %ebx
  802628:	83 ec 0c             	sub    $0xc,%esp
  80262b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80262e:	b8 03 00 00 00       	mov    $0x3,%eax
  802633:	bf 00 00 00 00       	mov    $0x0,%edi
  802638:	89 f9                	mov    %edi,%ecx
  80263a:	89 fb                	mov    %edi,%ebx
  80263c:	89 fe                	mov    %edi,%esi
  80263e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802640:	85 c0                	test   %eax,%eax
  802642:	7e 17                	jle    80265b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802644:	83 ec 0c             	sub    $0xc,%esp
  802647:	50                   	push   %eax
  802648:	6a 03                	push   $0x3
  80264a:	68 bf 40 80 00       	push   $0x8040bf
  80264f:	6a 23                	push   $0x23
  802651:	68 dc 40 80 00       	push   $0x8040dc
  802656:	e8 3d f4 ff ff       	call   801a98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80265b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80265e:	5b                   	pop    %ebx
  80265f:	5e                   	pop    %esi
  802660:	5f                   	pop    %edi
  802661:	c9                   	leave  
  802662:	c3                   	ret    
	...

00802664 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802664:	55                   	push   %ebp
  802665:	89 e5                	mov    %esp,%ebp
  802667:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80266a:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802671:	75 64                	jne    8026d7 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  802673:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802678:	8b 40 48             	mov    0x48(%eax),%eax
  80267b:	83 ec 04             	sub    $0x4,%esp
  80267e:	6a 07                	push   $0x7
  802680:	68 00 f0 bf ee       	push   $0xeebff000
  802685:	50                   	push   %eax
  802686:	e8 16 ff ff ff       	call   8025a1 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  80268b:	83 c4 10             	add    $0x10,%esp
  80268e:	85 c0                	test   %eax,%eax
  802690:	79 14                	jns    8026a6 <set_pgfault_handler+0x42>
  802692:	83 ec 04             	sub    $0x4,%esp
  802695:	68 ec 40 80 00       	push   $0x8040ec
  80269a:	6a 22                	push   $0x22
  80269c:	68 55 41 80 00       	push   $0x804155
  8026a1:	e8 f2 f3 ff ff       	call   801a98 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  8026a6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026ab:	8b 40 48             	mov    0x48(%eax),%eax
  8026ae:	83 ec 08             	sub    $0x8,%esp
  8026b1:	68 e4 26 80 00       	push   $0x8026e4
  8026b6:	50                   	push   %eax
  8026b7:	e8 9b fd ff ff       	call   802457 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  8026bc:	83 c4 10             	add    $0x10,%esp
  8026bf:	85 c0                	test   %eax,%eax
  8026c1:	79 14                	jns    8026d7 <set_pgfault_handler+0x73>
  8026c3:	83 ec 04             	sub    $0x4,%esp
  8026c6:	68 1c 41 80 00       	push   $0x80411c
  8026cb:	6a 25                	push   $0x25
  8026cd:	68 55 41 80 00       	push   $0x804155
  8026d2:	e8 c1 f3 ff ff       	call   801a98 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026da:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  8026df:	c9                   	leave  
  8026e0:	c3                   	ret    
  8026e1:	00 00                	add    %al,(%eax)
	...

008026e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026e5:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8026ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026ec:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  8026ef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8026f3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8026f6:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  8026fa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  8026fe:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  802700:	83 c4 08             	add    $0x8,%esp
	popal
  802703:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802704:	83 c4 04             	add    $0x4,%esp
	popfl
  802707:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802708:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  802709:	c3                   	ret    
	...

0080270c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	53                   	push   %ebx
  802710:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802713:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802718:	8d 14 8d 00 00 00 00 	lea    0x0(,%ecx,4),%edx
  80271f:	89 c8                	mov    %ecx,%eax
  802721:	c1 e0 07             	shl    $0x7,%eax
  802724:	29 d0                	sub    %edx,%eax
  802726:	89 c2                	mov    %eax,%edx
  802728:	8d 80 00 00 c0 ee    	lea    -0x11400000(%eax),%eax
  80272e:	8b 40 50             	mov    0x50(%eax),%eax
  802731:	39 d8                	cmp    %ebx,%eax
  802733:	75 0b                	jne    802740 <ipc_find_env+0x34>
			return envs[i].env_id;
  802735:	8d 82 08 00 c0 ee    	lea    -0x113ffff8(%edx),%eax
  80273b:	8b 40 40             	mov    0x40(%eax),%eax
  80273e:	eb 0e                	jmp    80274e <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802740:	41                   	inc    %ecx
  802741:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
  802747:	75 cf                	jne    802718 <ipc_find_env+0xc>
  802749:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  80274e:	5b                   	pop    %ebx
  80274f:	c9                   	leave  
  802750:	c3                   	ret    

00802751 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802751:	55                   	push   %ebp
  802752:	89 e5                	mov    %esp,%ebp
  802754:	57                   	push   %edi
  802755:	56                   	push   %esi
  802756:	53                   	push   %ebx
  802757:	83 ec 0c             	sub    $0xc,%esp
  80275a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80275d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802760:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  802763:	85 db                	test   %ebx,%ebx
  802765:	75 05                	jne    80276c <ipc_send+0x1b>
  802767:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		pg = (void *)-1;
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80276c:	56                   	push   %esi
  80276d:	53                   	push   %ebx
  80276e:	57                   	push   %edi
  80276f:	ff 75 08             	pushl  0x8(%ebp)
  802772:	e8 bd fc ff ff       	call   802434 <sys_ipc_try_send>
		if (r == 0) {		//success
  802777:	83 c4 10             	add    $0x10,%esp
  80277a:	85 c0                	test   %eax,%eax
  80277c:	74 20                	je     80279e <ipc_send+0x4d>
			return;
		} else if (r == -E_IPC_NOT_RECV) {	
  80277e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802781:	75 07                	jne    80278a <ipc_send+0x39>
			sys_yield();
  802783:	e8 5c fe ff ff       	call   8025e4 <sys_yield>
  802788:	eb e2                	jmp    80276c <ipc_send+0x1b>
		} else {			//other err
			panic("ipc_send: sys_ipc_try_send failed\n");
  80278a:	83 ec 04             	sub    $0x4,%esp
  80278d:	68 64 41 80 00       	push   $0x804164
  802792:	6a 41                	push   $0x41
  802794:	68 87 41 80 00       	push   $0x804187
  802799:	e8 fa f2 ff ff       	call   801a98 <_panic>
		}
	}
}
  80279e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a1:	5b                   	pop    %ebx
  8027a2:	5e                   	pop    %esi
  8027a3:	5f                   	pop    %edi
  8027a4:	c9                   	leave  
  8027a5:	c3                   	ret    

008027a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	56                   	push   %esi
  8027aa:	53                   	push   %ebx
  8027ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8027ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b1:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg == NULL) {
  8027b4:	85 c0                	test   %eax,%eax
  8027b6:	75 05                	jne    8027bd <ipc_recv+0x17>
  8027b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pg = (void *)-1;
	}
	int r = sys_ipc_recv(pg);
  8027bd:	83 ec 0c             	sub    $0xc,%esp
  8027c0:	50                   	push   %eax
  8027c1:	e8 2d fc ff ff       	call   8023f3 <sys_ipc_recv>
	if (r < 0) {				
  8027c6:	83 c4 10             	add    $0x10,%esp
  8027c9:	85 c0                	test   %eax,%eax
  8027cb:	79 16                	jns    8027e3 <ipc_recv+0x3d>
		if (from_env_store) *from_env_store = 0;
  8027cd:	85 db                	test   %ebx,%ebx
  8027cf:	74 06                	je     8027d7 <ipc_recv+0x31>
  8027d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store) *perm_store = 0;
  8027d7:	85 f6                	test   %esi,%esi
  8027d9:	74 2c                	je     802807 <ipc_recv+0x61>
  8027db:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8027e1:	eb 24                	jmp    802807 <ipc_recv+0x61>
		return r;
	}
	if (from_env_store)
  8027e3:	85 db                	test   %ebx,%ebx
  8027e5:	74 0a                	je     8027f1 <ipc_recv+0x4b>
		*from_env_store = thisenv->env_ipc_from;
  8027e7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027ec:	8b 40 74             	mov    0x74(%eax),%eax
  8027ef:	89 03                	mov    %eax,(%ebx)
	if (perm_store)
  8027f1:	85 f6                	test   %esi,%esi
  8027f3:	74 0a                	je     8027ff <ipc_recv+0x59>
		*perm_store = thisenv->env_ipc_perm;
  8027f5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027fa:	8b 40 78             	mov    0x78(%eax),%eax
  8027fd:	89 06                	mov    %eax,(%esi)
	return thisenv->env_ipc_value;
  8027ff:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802804:	8b 40 70             	mov    0x70(%eax),%eax
}
  802807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80280a:	5b                   	pop    %ebx
  80280b:	5e                   	pop    %esi
  80280c:	c9                   	leave  
  80280d:	c3                   	ret    
	...

00802810 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802810:	55                   	push   %ebp
  802811:	89 e5                	mov    %esp,%ebp
  802813:	56                   	push   %esi
  802814:	53                   	push   %ebx
  802815:	89 c3                	mov    %eax,%ebx
  802817:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802819:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802820:	75 12                	jne    802834 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802822:	83 ec 0c             	sub    $0xc,%esp
  802825:	6a 01                	push   $0x1
  802827:	e8 e0 fe ff ff       	call   80270c <ipc_find_env>
  80282c:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802831:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802834:	6a 07                	push   $0x7
  802836:	68 00 b0 80 00       	push   $0x80b000
  80283b:	53                   	push   %ebx
  80283c:	ff 35 00 a0 80 00    	pushl  0x80a000
  802842:	e8 0a ff ff ff       	call   802751 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802847:	83 c4 0c             	add    $0xc,%esp
  80284a:	6a 00                	push   $0x0
  80284c:	56                   	push   %esi
  80284d:	6a 00                	push   $0x0
  80284f:	e8 52 ff ff ff       	call   8027a6 <ipc_recv>
}
  802854:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802857:	5b                   	pop    %ebx
  802858:	5e                   	pop    %esi
  802859:	c9                   	leave  
  80285a:	c3                   	ret    

0080285b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80285b:	55                   	push   %ebp
  80285c:	89 e5                	mov    %esp,%ebp
  80285e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802861:	ba 00 00 00 00       	mov    $0x0,%edx
  802866:	b8 08 00 00 00       	mov    $0x8,%eax
  80286b:	e8 a0 ff ff ff       	call   802810 <fsipc>
}
  802870:	c9                   	leave  
  802871:	c3                   	ret    

00802872 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802872:	55                   	push   %ebp
  802873:	89 e5                	mov    %esp,%ebp
  802875:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802878:	8b 45 08             	mov    0x8(%ebp),%eax
  80287b:	8b 40 0c             	mov    0xc(%eax),%eax
  80287e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802883:	8b 45 0c             	mov    0xc(%ebp),%eax
  802886:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80288b:	ba 00 00 00 00       	mov    $0x0,%edx
  802890:	b8 02 00 00 00       	mov    $0x2,%eax
  802895:	e8 76 ff ff ff       	call   802810 <fsipc>
}
  80289a:	c9                   	leave  
  80289b:	c3                   	ret    

0080289c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80289c:	55                   	push   %ebp
  80289d:	89 e5                	mov    %esp,%ebp
  80289f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8028a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8028a8:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8028ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8028b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8028b7:	e8 54 ff ff ff       	call   802810 <fsipc>
}
  8028bc:	c9                   	leave  
  8028bd:	c3                   	ret    

008028be <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8028be:	55                   	push   %ebp
  8028bf:	89 e5                	mov    %esp,%ebp
  8028c1:	53                   	push   %ebx
  8028c2:	83 ec 04             	sub    $0x4,%esp
  8028c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8028c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8028cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8028ce:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8028d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8028d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8028dd:	e8 2e ff ff ff       	call   802810 <fsipc>
  8028e2:	85 c0                	test   %eax,%eax
  8028e4:	78 2c                	js     802912 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8028e6:	83 ec 08             	sub    $0x8,%esp
  8028e9:	68 00 b0 80 00       	push   $0x80b000
  8028ee:	53                   	push   %ebx
  8028ef:	e8 97 f7 ff ff       	call   80208b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8028f4:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8028f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8028ff:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802904:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  80290a:	b8 00 00 00 00       	mov    $0x0,%eax
  80290f:	83 c4 10             	add    $0x10,%esp
	return 0;
}
  802912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802915:	c9                   	leave  
  802916:	c3                   	ret    

00802917 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802917:	55                   	push   %ebp
  802918:	89 e5                	mov    %esp,%ebp
  80291a:	53                   	push   %ebx
  80291b:	83 ec 08             	sub    $0x8,%esp
  80291e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802921:	8b 45 08             	mov    0x8(%ebp),%eax
  802924:	8b 40 0c             	mov    0xc(%eax),%eax
  802927:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.write.req_n = n;
  80292c:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802932:	53                   	push   %ebx
  802933:	ff 75 0c             	pushl  0xc(%ebp)
  802936:	68 08 b0 80 00       	push   $0x80b008
  80293b:	e8 b8 f8 ff ff       	call   8021f8 <memmove>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802940:	ba 00 00 00 00       	mov    $0x0,%edx
  802945:	b8 04 00 00 00       	mov    $0x4,%eax
  80294a:	e8 c1 fe ff ff       	call   802810 <fsipc>
  80294f:	83 c4 10             	add    $0x10,%esp
  802952:	85 c0                	test   %eax,%eax
  802954:	78 3d                	js     802993 <devfile_write+0x7c>
		return r;
	assert(r <= n);
  802956:	39 c3                	cmp    %eax,%ebx
  802958:	73 19                	jae    802973 <devfile_write+0x5c>
  80295a:	68 91 41 80 00       	push   $0x804191
  80295f:	68 3d 38 80 00       	push   $0x80383d
  802964:	68 97 00 00 00       	push   $0x97
  802969:	68 98 41 80 00       	push   $0x804198
  80296e:	e8 25 f1 ff ff       	call   801a98 <_panic>
	assert(r <= PGSIZE);
  802973:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802978:	7e 19                	jle    802993 <devfile_write+0x7c>
  80297a:	68 a3 41 80 00       	push   $0x8041a3
  80297f:	68 3d 38 80 00       	push   $0x80383d
  802984:	68 98 00 00 00       	push   $0x98
  802989:	68 98 41 80 00       	push   $0x804198
  80298e:	e8 05 f1 ff ff       	call   801a98 <_panic>
	
	return r;
}
  802993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802996:	c9                   	leave  
  802997:	c3                   	ret    

00802998 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802998:	55                   	push   %ebp
  802999:	89 e5                	mov    %esp,%ebp
  80299b:	56                   	push   %esi
  80299c:	53                   	push   %ebx
  80299d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8029a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8029a6:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8029ab:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8029b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8029b6:	b8 03 00 00 00       	mov    $0x3,%eax
  8029bb:	e8 50 fe ff ff       	call   802810 <fsipc>
  8029c0:	89 c3                	mov    %eax,%ebx
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	78 4c                	js     802a12 <devfile_read+0x7a>
		return r;
	assert(r <= n);
  8029c6:	39 de                	cmp    %ebx,%esi
  8029c8:	73 16                	jae    8029e0 <devfile_read+0x48>
  8029ca:	68 91 41 80 00       	push   $0x804191
  8029cf:	68 3d 38 80 00       	push   $0x80383d
  8029d4:	6a 7c                	push   $0x7c
  8029d6:	68 98 41 80 00       	push   $0x804198
  8029db:	e8 b8 f0 ff ff       	call   801a98 <_panic>
	assert(r <= PGSIZE);
  8029e0:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  8029e6:	7e 16                	jle    8029fe <devfile_read+0x66>
  8029e8:	68 a3 41 80 00       	push   $0x8041a3
  8029ed:	68 3d 38 80 00       	push   $0x80383d
  8029f2:	6a 7d                	push   $0x7d
  8029f4:	68 98 41 80 00       	push   $0x804198
  8029f9:	e8 9a f0 ff ff       	call   801a98 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8029fe:	83 ec 04             	sub    $0x4,%esp
  802a01:	50                   	push   %eax
  802a02:	68 00 b0 80 00       	push   $0x80b000
  802a07:	ff 75 0c             	pushl  0xc(%ebp)
  802a0a:	e8 e9 f7 ff ff       	call   8021f8 <memmove>
  802a0f:	83 c4 10             	add    $0x10,%esp
	return r;
}
  802a12:	89 d8                	mov    %ebx,%eax
  802a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a17:	5b                   	pop    %ebx
  802a18:	5e                   	pop    %esi
  802a19:	c9                   	leave  
  802a1a:	c3                   	ret    

00802a1b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802a1b:	55                   	push   %ebp
  802a1c:	89 e5                	mov    %esp,%ebp
  802a1e:	56                   	push   %esi
  802a1f:	53                   	push   %ebx
  802a20:	83 ec 1c             	sub    $0x1c,%esp
  802a23:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802a26:	56                   	push   %esi
  802a27:	e8 2c f6 ff ff       	call   802058 <strlen>
  802a2c:	83 c4 10             	add    $0x10,%esp
  802a2f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802a34:	7e 07                	jle    802a3d <open+0x22>
  802a36:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802a3b:	eb 63                	jmp    802aa0 <open+0x85>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802a3d:	83 ec 0c             	sub    $0xc,%esp
  802a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a43:	50                   	push   %eax
  802a44:	e8 cb 00 00 00       	call   802b14 <fd_alloc>
  802a49:	89 c3                	mov    %eax,%ebx
  802a4b:	83 c4 10             	add    $0x10,%esp
  802a4e:	85 c0                	test   %eax,%eax
  802a50:	78 4e                	js     802aa0 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802a52:	83 ec 08             	sub    $0x8,%esp
  802a55:	56                   	push   %esi
  802a56:	68 00 b0 80 00       	push   $0x80b000
  802a5b:	e8 2b f6 ff ff       	call   80208b <strcpy>
	fsipcbuf.open.req_omode = mode;
  802a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a63:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a6b:	b8 01 00 00 00       	mov    $0x1,%eax
  802a70:	e8 9b fd ff ff       	call   802810 <fsipc>
  802a75:	89 c3                	mov    %eax,%ebx
  802a77:	83 c4 10             	add    $0x10,%esp
  802a7a:	85 c0                	test   %eax,%eax
  802a7c:	79 12                	jns    802a90 <open+0x75>
		fd_close(fd, 0);
  802a7e:	83 ec 08             	sub    $0x8,%esp
  802a81:	6a 00                	push   $0x0
  802a83:	ff 75 f4             	pushl  -0xc(%ebp)
  802a86:	e8 e9 03 00 00       	call   802e74 <fd_close>
		return r;
  802a8b:	83 c4 10             	add    $0x10,%esp
  802a8e:	eb 10                	jmp    802aa0 <open+0x85>
	}

	return fd2num(fd);
  802a90:	83 ec 0c             	sub    $0xc,%esp
  802a93:	ff 75 f4             	pushl  -0xc(%ebp)
  802a96:	e8 51 00 00 00       	call   802aec <fd2num>
  802a9b:	89 c3                	mov    %eax,%ebx
  802a9d:	83 c4 10             	add    $0x10,%esp
}
  802aa0:	89 d8                	mov    %ebx,%eax
  802aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aa5:	5b                   	pop    %ebx
  802aa6:	5e                   	pop    %esi
  802aa7:	c9                   	leave  
  802aa8:	c3                   	ret    
  802aa9:	00 00                	add    %al,(%eax)
	...

00802aac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802aac:	55                   	push   %ebp
  802aad:	89 e5                	mov    %esp,%ebp
  802aaf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ab2:	89 d0                	mov    %edx,%eax
  802ab4:	c1 e8 16             	shr    $0x16,%eax
  802ab7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802abe:	a8 01                	test   $0x1,%al
  802ac0:	74 20                	je     802ae2 <pageref+0x36>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ac2:	89 d0                	mov    %edx,%eax
  802ac4:	c1 e8 0c             	shr    $0xc,%eax
  802ac7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802ace:	a8 01                	test   $0x1,%al
  802ad0:	74 10                	je     802ae2 <pageref+0x36>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ad2:	c1 e8 0c             	shr    $0xc,%eax
  802ad5:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802adc:	ef 
  802add:	0f b7 c0             	movzwl %ax,%eax
  802ae0:	eb 05                	jmp    802ae7 <pageref+0x3b>
  802ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ae7:	c9                   	leave  
  802ae8:	c3                   	ret    
  802ae9:	00 00                	add    %al,(%eax)
	...

00802aec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802aec:	55                   	push   %ebp
  802aed:	89 e5                	mov    %esp,%ebp
  802aef:	8b 45 08             	mov    0x8(%ebp),%eax
  802af2:	05 00 00 00 30       	add    $0x30000000,%eax
  802af7:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  802afa:	c9                   	leave  
  802afb:	c3                   	ret    

00802afc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802afc:	55                   	push   %ebp
  802afd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802aff:	ff 75 08             	pushl  0x8(%ebp)
  802b02:	e8 e5 ff ff ff       	call   802aec <fd2num>
  802b07:	83 c4 04             	add    $0x4,%esp
  802b0a:	c1 e0 0c             	shl    $0xc,%eax
  802b0d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802b12:	c9                   	leave  
  802b13:	c3                   	ret    

00802b14 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802b14:	55                   	push   %ebp
  802b15:	89 e5                	mov    %esp,%ebp
  802b17:	53                   	push   %ebx
  802b18:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802b1b:	ba 00 00 00 d0       	mov    $0xd0000000,%edx
  802b20:	89 d1                	mov    %edx,%ecx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802b22:	89 d0                	mov    %edx,%eax
  802b24:	c1 e8 16             	shr    $0x16,%eax
  802b27:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b2e:	a8 01                	test   $0x1,%al
  802b30:	74 10                	je     802b42 <fd_alloc+0x2e>
  802b32:	89 d0                	mov    %edx,%eax
  802b34:	c1 e8 0c             	shr    $0xc,%eax
  802b37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b3e:	a8 01                	test   $0x1,%al
  802b40:	75 09                	jne    802b4b <fd_alloc+0x37>
			*fd_store = fd;
  802b42:	89 0b                	mov    %ecx,(%ebx)
  802b44:	b8 00 00 00 00       	mov    $0x0,%eax
  802b49:	eb 19                	jmp    802b64 <fd_alloc+0x50>
			return 0;
  802b4b:	81 c2 00 10 00 00    	add    $0x1000,%edx
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802b51:	81 fa 00 00 02 d0    	cmp    $0xd0020000,%edx
  802b57:	75 c7                	jne    802b20 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802b59:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802b5f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  802b64:	5b                   	pop    %ebx
  802b65:	c9                   	leave  
  802b66:	c3                   	ret    

00802b67 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802b67:	55                   	push   %ebp
  802b68:	89 e5                	mov    %esp,%ebp
  802b6a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802b6d:	83 f8 1f             	cmp    $0x1f,%eax
  802b70:	77 35                	ja     802ba7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802b72:	c1 e0 0c             	shl    $0xc,%eax
  802b75:	8d 90 00 00 00 d0    	lea    -0x30000000(%eax),%edx
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802b7b:	89 d0                	mov    %edx,%eax
  802b7d:	c1 e8 16             	shr    $0x16,%eax
  802b80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b87:	a8 01                	test   $0x1,%al
  802b89:	74 1c                	je     802ba7 <fd_lookup+0x40>
  802b8b:	89 d0                	mov    %edx,%eax
  802b8d:	c1 e8 0c             	shr    $0xc,%eax
  802b90:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b97:	a8 01                	test   $0x1,%al
  802b99:	74 0c                	je     802ba7 <fd_lookup+0x40>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b9e:	89 10                	mov    %edx,(%eax)
  802ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  802ba5:	eb 05                	jmp    802bac <fd_lookup+0x45>
	return 0;
  802ba7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802bac:	c9                   	leave  
  802bad:	c3                   	ret    

00802bae <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  802bae:	55                   	push   %ebp
  802baf:	89 e5                	mov    %esp,%ebp
  802bb1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bb4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bb7:	50                   	push   %eax
  802bb8:	ff 75 08             	pushl  0x8(%ebp)
  802bbb:	e8 a7 ff ff ff       	call   802b67 <fd_lookup>
  802bc0:	83 c4 08             	add    $0x8,%esp
  802bc3:	85 c0                	test   %eax,%eax
  802bc5:	78 0e                	js     802bd5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  802bca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802bcd:	89 50 04             	mov    %edx,0x4(%eax)
  802bd0:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  802bd5:	c9                   	leave  
  802bd6:	c3                   	ret    

00802bd7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802bd7:	55                   	push   %ebp
  802bd8:	89 e5                	mov    %esp,%ebp
  802bda:	53                   	push   %ebx
  802bdb:	83 ec 04             	sub    $0x4,%esp
  802bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802be1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802be4:	ba 00 00 00 00       	mov    $0x0,%edx
  802be9:	eb 0e                	jmp    802bf9 <dev_lookup+0x22>
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  802beb:	3b 08                	cmp    (%eax),%ecx
  802bed:	75 09                	jne    802bf8 <dev_lookup+0x21>
			*dev = devtab[i];
  802bef:	89 03                	mov    %eax,(%ebx)
  802bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  802bf6:	eb 31                	jmp    802c29 <dev_lookup+0x52>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802bf8:	42                   	inc    %edx
  802bf9:	8b 04 95 30 42 80 00 	mov    0x804230(,%edx,4),%eax
  802c00:	85 c0                	test   %eax,%eax
  802c02:	75 e7                	jne    802beb <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802c04:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802c09:	8b 40 48             	mov    0x48(%eax),%eax
  802c0c:	83 ec 04             	sub    $0x4,%esp
  802c0f:	51                   	push   %ecx
  802c10:	50                   	push   %eax
  802c11:	68 b0 41 80 00       	push   $0x8041b0
  802c16:	e8 1e ef ff ff       	call   801b39 <cprintf>
	*dev = 0;
  802c1b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802c21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c26:	83 c4 10             	add    $0x10,%esp
	return -E_INVAL;
}
  802c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c2c:	c9                   	leave  
  802c2d:	c3                   	ret    

00802c2e <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  802c2e:	55                   	push   %ebp
  802c2f:	89 e5                	mov    %esp,%ebp
  802c31:	53                   	push   %ebx
  802c32:	83 ec 14             	sub    $0x14,%esp
  802c35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c3b:	50                   	push   %eax
  802c3c:	ff 75 08             	pushl  0x8(%ebp)
  802c3f:	e8 23 ff ff ff       	call   802b67 <fd_lookup>
  802c44:	83 c4 08             	add    $0x8,%esp
  802c47:	85 c0                	test   %eax,%eax
  802c49:	78 55                	js     802ca0 <fstat+0x72>
  802c4b:	83 ec 08             	sub    $0x8,%esp
  802c4e:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802c51:	50                   	push   %eax
  802c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c55:	ff 30                	pushl  (%eax)
  802c57:	e8 7b ff ff ff       	call   802bd7 <dev_lookup>
  802c5c:	83 c4 10             	add    $0x10,%esp
  802c5f:	85 c0                	test   %eax,%eax
  802c61:	78 3d                	js     802ca0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  802c63:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802c66:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802c6a:	75 07                	jne    802c73 <fstat+0x45>
  802c6c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802c71:	eb 2d                	jmp    802ca0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802c73:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802c76:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802c7d:	00 00 00 
	stat->st_isdir = 0;
  802c80:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802c87:	00 00 00 
	stat->st_dev = dev;
  802c8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802c8d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802c93:	83 ec 08             	sub    $0x8,%esp
  802c96:	53                   	push   %ebx
  802c97:	ff 75 f4             	pushl  -0xc(%ebp)
  802c9a:	ff 50 14             	call   *0x14(%eax)
  802c9d:	83 c4 10             	add    $0x10,%esp
}
  802ca0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ca3:	c9                   	leave  
  802ca4:	c3                   	ret    

00802ca5 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  802ca5:	55                   	push   %ebp
  802ca6:	89 e5                	mov    %esp,%ebp
  802ca8:	53                   	push   %ebx
  802ca9:	83 ec 14             	sub    $0x14,%esp
  802cac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802caf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cb2:	50                   	push   %eax
  802cb3:	53                   	push   %ebx
  802cb4:	e8 ae fe ff ff       	call   802b67 <fd_lookup>
  802cb9:	83 c4 08             	add    $0x8,%esp
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	78 5f                	js     802d1f <ftruncate+0x7a>
  802cc0:	83 ec 08             	sub    $0x8,%esp
  802cc3:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802cc6:	50                   	push   %eax
  802cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cca:	ff 30                	pushl  (%eax)
  802ccc:	e8 06 ff ff ff       	call   802bd7 <dev_lookup>
  802cd1:	83 c4 10             	add    $0x10,%esp
  802cd4:	85 c0                	test   %eax,%eax
  802cd6:	78 47                	js     802d1f <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cdb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cdf:	75 21                	jne    802d02 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802ce1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ce6:	8b 40 48             	mov    0x48(%eax),%eax
  802ce9:	83 ec 04             	sub    $0x4,%esp
  802cec:	53                   	push   %ebx
  802ced:	50                   	push   %eax
  802cee:	68 d0 41 80 00       	push   $0x8041d0
  802cf3:	e8 41 ee ff ff       	call   801b39 <cprintf>
  802cf8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802cfd:	83 c4 10             	add    $0x10,%esp
  802d00:	eb 1d                	jmp    802d1f <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  802d02:	8b 55 f8             	mov    -0x8(%ebp),%edx
  802d05:	83 7a 18 00          	cmpl   $0x0,0x18(%edx)
  802d09:	75 07                	jne    802d12 <ftruncate+0x6d>
  802d0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d10:	eb 0d                	jmp    802d1f <ftruncate+0x7a>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802d12:	83 ec 08             	sub    $0x8,%esp
  802d15:	ff 75 0c             	pushl  0xc(%ebp)
  802d18:	50                   	push   %eax
  802d19:	ff 52 18             	call   *0x18(%edx)
  802d1c:	83 c4 10             	add    $0x10,%esp
}
  802d1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d22:	c9                   	leave  
  802d23:	c3                   	ret    

00802d24 <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802d24:	55                   	push   %ebp
  802d25:	89 e5                	mov    %esp,%ebp
  802d27:	53                   	push   %ebx
  802d28:	83 ec 14             	sub    $0x14,%esp
  802d2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d31:	50                   	push   %eax
  802d32:	53                   	push   %ebx
  802d33:	e8 2f fe ff ff       	call   802b67 <fd_lookup>
  802d38:	83 c4 08             	add    $0x8,%esp
  802d3b:	85 c0                	test   %eax,%eax
  802d3d:	78 62                	js     802da1 <write+0x7d>
  802d3f:	83 ec 08             	sub    $0x8,%esp
  802d42:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802d45:	50                   	push   %eax
  802d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d49:	ff 30                	pushl  (%eax)
  802d4b:	e8 87 fe ff ff       	call   802bd7 <dev_lookup>
  802d50:	83 c4 10             	add    $0x10,%esp
  802d53:	85 c0                	test   %eax,%eax
  802d55:	78 4a                	js     802da1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d5a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d5e:	75 21                	jne    802d81 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802d60:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d65:	8b 40 48             	mov    0x48(%eax),%eax
  802d68:	83 ec 04             	sub    $0x4,%esp
  802d6b:	53                   	push   %ebx
  802d6c:	50                   	push   %eax
  802d6d:	68 f4 41 80 00       	push   $0x8041f4
  802d72:	e8 c2 ed ff ff       	call   801b39 <cprintf>
  802d77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  802d7c:	83 c4 10             	add    $0x10,%esp
  802d7f:	eb 20                	jmp    802da1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802d81:	8b 55 f8             	mov    -0x8(%ebp),%edx
  802d84:	83 7a 0c 00          	cmpl   $0x0,0xc(%edx)
  802d88:	75 07                	jne    802d91 <write+0x6d>
  802d8a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802d8f:	eb 10                	jmp    802da1 <write+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802d91:	83 ec 04             	sub    $0x4,%esp
  802d94:	ff 75 10             	pushl  0x10(%ebp)
  802d97:	ff 75 0c             	pushl  0xc(%ebp)
  802d9a:	50                   	push   %eax
  802d9b:	ff 52 0c             	call   *0xc(%edx)
  802d9e:	83 c4 10             	add    $0x10,%esp
}
  802da1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802da4:	c9                   	leave  
  802da5:	c3                   	ret    

00802da6 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802da6:	55                   	push   %ebp
  802da7:	89 e5                	mov    %esp,%ebp
  802da9:	53                   	push   %ebx
  802daa:	83 ec 14             	sub    $0x14,%esp
  802dad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802db3:	50                   	push   %eax
  802db4:	53                   	push   %ebx
  802db5:	e8 ad fd ff ff       	call   802b67 <fd_lookup>
  802dba:	83 c4 08             	add    $0x8,%esp
  802dbd:	85 c0                	test   %eax,%eax
  802dbf:	78 67                	js     802e28 <read+0x82>
  802dc1:	83 ec 08             	sub    $0x8,%esp
  802dc4:	8d 45 f8             	lea    -0x8(%ebp),%eax
  802dc7:	50                   	push   %eax
  802dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dcb:	ff 30                	pushl  (%eax)
  802dcd:	e8 05 fe ff ff       	call   802bd7 <dev_lookup>
  802dd2:	83 c4 10             	add    $0x10,%esp
  802dd5:	85 c0                	test   %eax,%eax
  802dd7:	78 4f                	js     802e28 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ddc:	8b 42 08             	mov    0x8(%edx),%eax
  802ddf:	83 e0 03             	and    $0x3,%eax
  802de2:	83 f8 01             	cmp    $0x1,%eax
  802de5:	75 21                	jne    802e08 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802de7:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802dec:	8b 40 48             	mov    0x48(%eax),%eax
  802def:	83 ec 04             	sub    $0x4,%esp
  802df2:	53                   	push   %ebx
  802df3:	50                   	push   %eax
  802df4:	68 11 42 80 00       	push   $0x804211
  802df9:	e8 3b ed ff ff       	call   801b39 <cprintf>
  802dfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  802e03:	83 c4 10             	add    $0x10,%esp
  802e06:	eb 20                	jmp    802e28 <read+0x82>
	}
	if (!dev->dev_read)
  802e08:	8b 45 f8             	mov    -0x8(%ebp),%eax
  802e0b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  802e0f:	75 07                	jne    802e18 <read+0x72>
  802e11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e16:	eb 10                	jmp    802e28 <read+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802e18:	83 ec 04             	sub    $0x4,%esp
  802e1b:	ff 75 10             	pushl  0x10(%ebp)
  802e1e:	ff 75 0c             	pushl  0xc(%ebp)
  802e21:	52                   	push   %edx
  802e22:	ff 50 08             	call   *0x8(%eax)
  802e25:	83 c4 10             	add    $0x10,%esp
}
  802e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e2b:	c9                   	leave  
  802e2c:	c3                   	ret    

00802e2d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802e2d:	55                   	push   %ebp
  802e2e:	89 e5                	mov    %esp,%ebp
  802e30:	57                   	push   %edi
  802e31:	56                   	push   %esi
  802e32:	53                   	push   %ebx
  802e33:	83 ec 0c             	sub    $0xc,%esp
  802e36:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e39:	8b 75 10             	mov    0x10(%ebp),%esi
  802e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e41:	eb 21                	jmp    802e64 <readn+0x37>
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
		m = read(fdnum, (char*)buf + tot, n - tot);
  802e43:	83 ec 04             	sub    $0x4,%esp
  802e46:	89 f0                	mov    %esi,%eax
  802e48:	29 d0                	sub    %edx,%eax
  802e4a:	50                   	push   %eax
  802e4b:	8d 04 17             	lea    (%edi,%edx,1),%eax
  802e4e:	50                   	push   %eax
  802e4f:	ff 75 08             	pushl  0x8(%ebp)
  802e52:	e8 4f ff ff ff       	call   802da6 <read>
		if (m < 0)
  802e57:	83 c4 10             	add    $0x10,%esp
  802e5a:	85 c0                	test   %eax,%eax
  802e5c:	78 0e                	js     802e6c <readn+0x3f>
			return m;
		if (m == 0)
  802e5e:	85 c0                	test   %eax,%eax
  802e60:	74 08                	je     802e6a <readn+0x3d>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e62:	01 c3                	add    %eax,%ebx
  802e64:	89 da                	mov    %ebx,%edx
  802e66:	39 f3                	cmp    %esi,%ebx
  802e68:	72 d9                	jb     802e43 <readn+0x16>
  802e6a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802e6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e6f:	5b                   	pop    %ebx
  802e70:	5e                   	pop    %esi
  802e71:	5f                   	pop    %edi
  802e72:	c9                   	leave  
  802e73:	c3                   	ret    

00802e74 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802e74:	55                   	push   %ebp
  802e75:	89 e5                	mov    %esp,%ebp
  802e77:	56                   	push   %esi
  802e78:	53                   	push   %ebx
  802e79:	83 ec 20             	sub    $0x20,%esp
  802e7c:	8b 75 08             	mov    0x8(%ebp),%esi
  802e7f:	8a 45 0c             	mov    0xc(%ebp),%al
  802e82:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e88:	50                   	push   %eax
  802e89:	56                   	push   %esi
  802e8a:	e8 5d fc ff ff       	call   802aec <fd2num>
  802e8f:	89 04 24             	mov    %eax,(%esp)
  802e92:	e8 d0 fc ff ff       	call   802b67 <fd_lookup>
  802e97:	89 c3                	mov    %eax,%ebx
  802e99:	83 c4 08             	add    $0x8,%esp
  802e9c:	85 c0                	test   %eax,%eax
  802e9e:	78 05                	js     802ea5 <fd_close+0x31>
  802ea0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802ea3:	74 0d                	je     802eb2 <fd_close+0x3e>
	    || fd != fd2)
		return (must_exist ? r : 0);
  802ea5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802ea9:	75 48                	jne    802ef3 <fd_close+0x7f>
  802eab:	bb 00 00 00 00       	mov    $0x0,%ebx
  802eb0:	eb 41                	jmp    802ef3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802eb2:	83 ec 08             	sub    $0x8,%esp
  802eb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802eb8:	50                   	push   %eax
  802eb9:	ff 36                	pushl  (%esi)
  802ebb:	e8 17 fd ff ff       	call   802bd7 <dev_lookup>
  802ec0:	89 c3                	mov    %eax,%ebx
  802ec2:	83 c4 10             	add    $0x10,%esp
  802ec5:	85 c0                	test   %eax,%eax
  802ec7:	78 1c                	js     802ee5 <fd_close+0x71>
		if (dev->dev_close)
  802ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ecc:	8b 40 10             	mov    0x10(%eax),%eax
  802ecf:	85 c0                	test   %eax,%eax
  802ed1:	75 07                	jne    802eda <fd_close+0x66>
  802ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ed8:	eb 0b                	jmp    802ee5 <fd_close+0x71>
			r = (*dev->dev_close)(fd);
  802eda:	83 ec 0c             	sub    $0xc,%esp
  802edd:	56                   	push   %esi
  802ede:	ff d0                	call   *%eax
  802ee0:	89 c3                	mov    %eax,%ebx
  802ee2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802ee5:	83 ec 08             	sub    $0x8,%esp
  802ee8:	56                   	push   %esi
  802ee9:	6a 00                	push   $0x0
  802eeb:	e8 2d f6 ff ff       	call   80251d <sys_page_unmap>
  802ef0:	83 c4 10             	add    $0x10,%esp
	return r;
}
  802ef3:	89 d8                	mov    %ebx,%eax
  802ef5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ef8:	5b                   	pop    %ebx
  802ef9:	5e                   	pop    %esi
  802efa:	c9                   	leave  
  802efb:	c3                   	ret    

00802efc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802efc:	55                   	push   %ebp
  802efd:	89 e5                	mov    %esp,%ebp
  802eff:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f02:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802f05:	50                   	push   %eax
  802f06:	ff 75 08             	pushl  0x8(%ebp)
  802f09:	e8 59 fc ff ff       	call   802b67 <fd_lookup>
  802f0e:	83 c4 08             	add    $0x8,%esp
  802f11:	85 c0                	test   %eax,%eax
  802f13:	78 10                	js     802f25 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802f15:	83 ec 08             	sub    $0x8,%esp
  802f18:	6a 01                	push   $0x1
  802f1a:	ff 75 fc             	pushl  -0x4(%ebp)
  802f1d:	e8 52 ff ff ff       	call   802e74 <fd_close>
  802f22:	83 c4 10             	add    $0x10,%esp
}
  802f25:	c9                   	leave  
  802f26:	c3                   	ret    

00802f27 <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  802f27:	55                   	push   %ebp
  802f28:	89 e5                	mov    %esp,%ebp
  802f2a:	56                   	push   %esi
  802f2b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802f2c:	83 ec 08             	sub    $0x8,%esp
  802f2f:	6a 00                	push   $0x0
  802f31:	ff 75 08             	pushl  0x8(%ebp)
  802f34:	e8 e2 fa ff ff       	call   802a1b <open>
  802f39:	89 c6                	mov    %eax,%esi
  802f3b:	83 c4 10             	add    $0x10,%esp
  802f3e:	85 c0                	test   %eax,%eax
  802f40:	78 1b                	js     802f5d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802f42:	83 ec 08             	sub    $0x8,%esp
  802f45:	ff 75 0c             	pushl  0xc(%ebp)
  802f48:	50                   	push   %eax
  802f49:	e8 e0 fc ff ff       	call   802c2e <fstat>
  802f4e:	89 c3                	mov    %eax,%ebx
	close(fd);
  802f50:	89 34 24             	mov    %esi,(%esp)
  802f53:	e8 a4 ff ff ff       	call   802efc <close>
  802f58:	89 de                	mov    %ebx,%esi
  802f5a:	83 c4 10             	add    $0x10,%esp
	return r;
}
  802f5d:	89 f0                	mov    %esi,%eax
  802f5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f62:	5b                   	pop    %ebx
  802f63:	5e                   	pop    %esi
  802f64:	c9                   	leave  
  802f65:	c3                   	ret    

00802f66 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802f66:	55                   	push   %ebp
  802f67:	89 e5                	mov    %esp,%ebp
  802f69:	57                   	push   %edi
  802f6a:	56                   	push   %esi
  802f6b:	53                   	push   %ebx
  802f6c:	83 ec 1c             	sub    $0x1c,%esp
  802f6f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802f72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f75:	50                   	push   %eax
  802f76:	ff 75 08             	pushl  0x8(%ebp)
  802f79:	e8 e9 fb ff ff       	call   802b67 <fd_lookup>
  802f7e:	89 c3                	mov    %eax,%ebx
  802f80:	83 c4 08             	add    $0x8,%esp
  802f83:	85 c0                	test   %eax,%eax
  802f85:	0f 88 bd 00 00 00    	js     803048 <dup+0xe2>
		return r;
	close(newfdnum);
  802f8b:	83 ec 0c             	sub    $0xc,%esp
  802f8e:	57                   	push   %edi
  802f8f:	e8 68 ff ff ff       	call   802efc <close>

	newfd = INDEX2FD(newfdnum);
  802f94:	89 f8                	mov    %edi,%eax
  802f96:	c1 e0 0c             	shl    $0xc,%eax
  802f99:	8d b0 00 00 00 d0    	lea    -0x30000000(%eax),%esi
	ova = fd2data(oldfd);
  802f9f:	ff 75 f0             	pushl  -0x10(%ebp)
  802fa2:	e8 55 fb ff ff       	call   802afc <fd2data>
  802fa7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802fa9:	89 34 24             	mov    %esi,(%esp)
  802fac:	e8 4b fb ff ff       	call   802afc <fd2data>
  802fb1:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802fb4:	89 d8                	mov    %ebx,%eax
  802fb6:	c1 e8 16             	shr    $0x16,%eax
  802fb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802fc0:	83 c4 14             	add    $0x14,%esp
  802fc3:	a8 01                	test   $0x1,%al
  802fc5:	74 36                	je     802ffd <dup+0x97>
  802fc7:	89 da                	mov    %ebx,%edx
  802fc9:	c1 ea 0c             	shr    $0xc,%edx
  802fcc:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802fd3:	a8 01                	test   $0x1,%al
  802fd5:	74 26                	je     802ffd <dup+0x97>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802fd7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802fde:	83 ec 0c             	sub    $0xc,%esp
  802fe1:	25 07 0e 00 00       	and    $0xe07,%eax
  802fe6:	50                   	push   %eax
  802fe7:	ff 75 e0             	pushl  -0x20(%ebp)
  802fea:	6a 00                	push   $0x0
  802fec:	53                   	push   %ebx
  802fed:	6a 00                	push   $0x0
  802fef:	e8 6b f5 ff ff       	call   80255f <sys_page_map>
  802ff4:	89 c3                	mov    %eax,%ebx
  802ff6:	83 c4 20             	add    $0x20,%esp
  802ff9:	85 c0                	test   %eax,%eax
  802ffb:	78 30                	js     80302d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802ffd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803000:	89 d0                	mov    %edx,%eax
  803002:	c1 e8 0c             	shr    $0xc,%eax
  803005:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80300c:	83 ec 0c             	sub    $0xc,%esp
  80300f:	25 07 0e 00 00       	and    $0xe07,%eax
  803014:	50                   	push   %eax
  803015:	56                   	push   %esi
  803016:	6a 00                	push   $0x0
  803018:	52                   	push   %edx
  803019:	6a 00                	push   $0x0
  80301b:	e8 3f f5 ff ff       	call   80255f <sys_page_map>
  803020:	89 c3                	mov    %eax,%ebx
  803022:	83 c4 20             	add    $0x20,%esp
  803025:	85 c0                	test   %eax,%eax
  803027:	78 04                	js     80302d <dup+0xc7>
		goto err;
  803029:	89 fb                	mov    %edi,%ebx
  80302b:	eb 1b                	jmp    803048 <dup+0xe2>

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80302d:	83 ec 08             	sub    $0x8,%esp
  803030:	56                   	push   %esi
  803031:	6a 00                	push   $0x0
  803033:	e8 e5 f4 ff ff       	call   80251d <sys_page_unmap>
	sys_page_unmap(0, nva);
  803038:	83 c4 08             	add    $0x8,%esp
  80303b:	ff 75 e0             	pushl  -0x20(%ebp)
  80303e:	6a 00                	push   $0x0
  803040:	e8 d8 f4 ff ff       	call   80251d <sys_page_unmap>
  803045:	83 c4 10             	add    $0x10,%esp
	return r;
}
  803048:	89 d8                	mov    %ebx,%eax
  80304a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80304d:	5b                   	pop    %ebx
  80304e:	5e                   	pop    %esi
  80304f:	5f                   	pop    %edi
  803050:	c9                   	leave  
  803051:	c3                   	ret    

00803052 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  803052:	55                   	push   %ebp
  803053:	89 e5                	mov    %esp,%ebp
  803055:	53                   	push   %ebx
  803056:	83 ec 04             	sub    $0x4,%esp
  803059:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  80305e:	83 ec 0c             	sub    $0xc,%esp
  803061:	53                   	push   %ebx
  803062:	e8 95 fe ff ff       	call   802efc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  803067:	43                   	inc    %ebx
  803068:	83 c4 10             	add    $0x10,%esp
  80306b:	83 fb 20             	cmp    $0x20,%ebx
  80306e:	75 ee                	jne    80305e <close_all+0xc>
		close(i);
}
  803070:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803073:	c9                   	leave  
  803074:	c3                   	ret    
  803075:	00 00                	add    %al,(%eax)
	...

00803078 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803078:	55                   	push   %ebp
  803079:	89 e5                	mov    %esp,%ebp
  80307b:	56                   	push   %esi
  80307c:	53                   	push   %ebx
  80307d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803080:	83 ec 0c             	sub    $0xc,%esp
  803083:	ff 75 08             	pushl  0x8(%ebp)
  803086:	e8 71 fa ff ff       	call   802afc <fd2data>
  80308b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80308d:	83 c4 08             	add    $0x8,%esp
  803090:	68 40 42 80 00       	push   $0x804240
  803095:	53                   	push   %ebx
  803096:	e8 f0 ef ff ff       	call   80208b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80309b:	8b 46 04             	mov    0x4(%esi),%eax
  80309e:	2b 06                	sub    (%esi),%eax
  8030a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8030a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8030ad:	00 00 00 
	stat->st_dev = &devpipe;
  8030b0:	c7 83 88 00 00 00 84 	movl   $0x809084,0x88(%ebx)
  8030b7:	90 80 00 
	return 0;
}
  8030ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8030bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030c2:	5b                   	pop    %ebx
  8030c3:	5e                   	pop    %esi
  8030c4:	c9                   	leave  
  8030c5:	c3                   	ret    

008030c6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8030c6:	55                   	push   %ebp
  8030c7:	89 e5                	mov    %esp,%ebp
  8030c9:	53                   	push   %ebx
  8030ca:	83 ec 0c             	sub    $0xc,%esp
  8030cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8030d0:	53                   	push   %ebx
  8030d1:	6a 00                	push   $0x0
  8030d3:	e8 45 f4 ff ff       	call   80251d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8030d8:	89 1c 24             	mov    %ebx,(%esp)
  8030db:	e8 1c fa ff ff       	call   802afc <fd2data>
  8030e0:	83 c4 08             	add    $0x8,%esp
  8030e3:	50                   	push   %eax
  8030e4:	6a 00                	push   $0x0
  8030e6:	e8 32 f4 ff ff       	call   80251d <sys_page_unmap>
}
  8030eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030ee:	c9                   	leave  
  8030ef:	c3                   	ret    

008030f0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8030f0:	55                   	push   %ebp
  8030f1:	89 e5                	mov    %esp,%ebp
  8030f3:	57                   	push   %edi
  8030f4:	56                   	push   %esi
  8030f5:	53                   	push   %ebx
  8030f6:	83 ec 0c             	sub    $0xc,%esp
  8030f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8030fc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8030fe:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803103:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  803106:	83 ec 0c             	sub    $0xc,%esp
  803109:	ff 75 f0             	pushl  -0x10(%ebp)
  80310c:	e8 9b f9 ff ff       	call   802aac <pageref>
  803111:	89 c3                	mov    %eax,%ebx
  803113:	89 3c 24             	mov    %edi,(%esp)
  803116:	e8 91 f9 ff ff       	call   802aac <pageref>
  80311b:	83 c4 10             	add    $0x10,%esp
  80311e:	39 c3                	cmp    %eax,%ebx
  803120:	0f 94 c0             	sete   %al
  803123:	0f b6 c8             	movzbl %al,%ecx
		nn = thisenv->env_runs;
  803126:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  80312c:	8b 42 58             	mov    0x58(%edx),%eax
		if (n == nn)
  80312f:	39 c6                	cmp    %eax,%esi
  803131:	74 1b                	je     80314e <_pipeisclosed+0x5e>
			return ret;
		if (n != nn && ret == 1)
  803133:	83 f9 01             	cmp    $0x1,%ecx
  803136:	75 c6                	jne    8030fe <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803138:	8b 42 58             	mov    0x58(%edx),%eax
  80313b:	6a 01                	push   $0x1
  80313d:	50                   	push   %eax
  80313e:	56                   	push   %esi
  80313f:	68 47 42 80 00       	push   $0x804247
  803144:	e8 f0 e9 ff ff       	call   801b39 <cprintf>
  803149:	83 c4 10             	add    $0x10,%esp
  80314c:	eb b0                	jmp    8030fe <_pipeisclosed+0xe>
	}
}
  80314e:	89 c8                	mov    %ecx,%eax
  803150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803153:	5b                   	pop    %ebx
  803154:	5e                   	pop    %esi
  803155:	5f                   	pop    %edi
  803156:	c9                   	leave  
  803157:	c3                   	ret    

00803158 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803158:	55                   	push   %ebp
  803159:	89 e5                	mov    %esp,%ebp
  80315b:	57                   	push   %edi
  80315c:	56                   	push   %esi
  80315d:	53                   	push   %ebx
  80315e:	83 ec 18             	sub    $0x18,%esp
  803161:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803164:	56                   	push   %esi
  803165:	e8 92 f9 ff ff       	call   802afc <fd2data>
  80316a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  80316c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80316f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  803172:	bf 00 00 00 00       	mov    $0x0,%edi
	for (i = 0; i < n; i++) {
  803177:	83 c4 10             	add    $0x10,%esp
  80317a:	eb 40                	jmp    8031bc <devpipe_write+0x64>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80317c:	b8 00 00 00 00       	mov    $0x0,%eax
  803181:	eb 40                	jmp    8031c3 <devpipe_write+0x6b>
  803183:	89 da                	mov    %ebx,%edx
  803185:	89 f0                	mov    %esi,%eax
  803187:	e8 64 ff ff ff       	call   8030f0 <_pipeisclosed>
  80318c:	85 c0                	test   %eax,%eax
  80318e:	75 ec                	jne    80317c <devpipe_write+0x24>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803190:	e8 4f f4 ff ff       	call   8025e4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803195:	8b 53 04             	mov    0x4(%ebx),%edx
  803198:	8b 03                	mov    (%ebx),%eax
  80319a:	83 c0 20             	add    $0x20,%eax
  80319d:	39 c2                	cmp    %eax,%edx
  80319f:	73 e2                	jae    803183 <devpipe_write+0x2b>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8031a1:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8031a7:	79 05                	jns    8031ae <devpipe_write+0x56>
  8031a9:	4a                   	dec    %edx
  8031aa:	83 ca e0             	or     $0xffffffe0,%edx
  8031ad:	42                   	inc    %edx
  8031ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8031b1:	8a 04 0f             	mov    (%edi,%ecx,1),%al
  8031b4:	88 44 13 08          	mov    %al,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8031b8:	ff 43 04             	incl   0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031bb:	47                   	inc    %edi
  8031bc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8031bf:	75 d4                	jne    803195 <devpipe_write+0x3d>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8031c1:	89 f8                	mov    %edi,%eax
}
  8031c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031c6:	5b                   	pop    %ebx
  8031c7:	5e                   	pop    %esi
  8031c8:	5f                   	pop    %edi
  8031c9:	c9                   	leave  
  8031ca:	c3                   	ret    

008031cb <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8031cb:	55                   	push   %ebp
  8031cc:	89 e5                	mov    %esp,%ebp
  8031ce:	57                   	push   %edi
  8031cf:	56                   	push   %esi
  8031d0:	53                   	push   %ebx
  8031d1:	83 ec 18             	sub    $0x18,%esp
  8031d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8031d7:	57                   	push   %edi
  8031d8:	e8 1f f9 ff ff       	call   802afc <fd2data>
  8031dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
  8031df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8031e5:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < n; i++) {
  8031ea:	83 c4 10             	add    $0x10,%esp
  8031ed:	eb 41                	jmp    803230 <devpipe_read+0x65>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8031ef:	89 f0                	mov    %esi,%eax
  8031f1:	eb 44                	jmp    803237 <devpipe_read+0x6c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8031f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8031f8:	eb 3d                	jmp    803237 <devpipe_read+0x6c>
	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8031fa:	85 f6                	test   %esi,%esi
  8031fc:	75 f1                	jne    8031ef <devpipe_read+0x24>
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8031fe:	89 da                	mov    %ebx,%edx
  803200:	89 f8                	mov    %edi,%eax
  803202:	e8 e9 fe ff ff       	call   8030f0 <_pipeisclosed>
  803207:	85 c0                	test   %eax,%eax
  803209:	75 e8                	jne    8031f3 <devpipe_read+0x28>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80320b:	e8 d4 f3 ff ff       	call   8025e4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803210:	8b 03                	mov    (%ebx),%eax
  803212:	3b 43 04             	cmp    0x4(%ebx),%eax
  803215:	74 e3                	je     8031fa <devpipe_read+0x2f>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803217:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80321c:	79 05                	jns    803223 <devpipe_read+0x58>
  80321e:	48                   	dec    %eax
  80321f:	83 c8 e0             	or     $0xffffffe0,%eax
  803222:	40                   	inc    %eax
  803223:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  803227:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80322a:	88 04 16             	mov    %al,(%esi,%edx,1)
		p->p_rpos++;
  80322d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80322f:	46                   	inc    %esi
  803230:	3b 75 10             	cmp    0x10(%ebp),%esi
  803233:	75 db                	jne    803210 <devpipe_read+0x45>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803235:	89 f0                	mov    %esi,%eax
}
  803237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80323a:	5b                   	pop    %ebx
  80323b:	5e                   	pop    %esi
  80323c:	5f                   	pop    %edi
  80323d:	c9                   	leave  
  80323e:	c3                   	ret    

0080323f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80323f:	55                   	push   %ebp
  803240:	89 e5                	mov    %esp,%ebp
  803242:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803245:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803248:	50                   	push   %eax
  803249:	ff 75 08             	pushl  0x8(%ebp)
  80324c:	e8 16 f9 ff ff       	call   802b67 <fd_lookup>
  803251:	83 c4 10             	add    $0x10,%esp
  803254:	85 c0                	test   %eax,%eax
  803256:	78 18                	js     803270 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803258:	83 ec 0c             	sub    $0xc,%esp
  80325b:	ff 75 fc             	pushl  -0x4(%ebp)
  80325e:	e8 99 f8 ff ff       	call   802afc <fd2data>
  803263:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803265:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803268:	e8 83 fe ff ff       	call   8030f0 <_pipeisclosed>
  80326d:	83 c4 10             	add    $0x10,%esp
}
  803270:	c9                   	leave  
  803271:	c3                   	ret    

00803272 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803272:	55                   	push   %ebp
  803273:	89 e5                	mov    %esp,%ebp
  803275:	57                   	push   %edi
  803276:	56                   	push   %esi
  803277:	53                   	push   %ebx
  803278:	83 ec 28             	sub    $0x28,%esp
  80327b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80327e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803281:	50                   	push   %eax
  803282:	e8 8d f8 ff ff       	call   802b14 <fd_alloc>
  803287:	89 c3                	mov    %eax,%ebx
  803289:	83 c4 10             	add    $0x10,%esp
  80328c:	85 c0                	test   %eax,%eax
  80328e:	0f 88 24 01 00 00    	js     8033b8 <pipe+0x146>
  803294:	83 ec 04             	sub    $0x4,%esp
  803297:	68 07 04 00 00       	push   $0x407
  80329c:	ff 75 f0             	pushl  -0x10(%ebp)
  80329f:	6a 00                	push   $0x0
  8032a1:	e8 fb f2 ff ff       	call   8025a1 <sys_page_alloc>
  8032a6:	89 c3                	mov    %eax,%ebx
  8032a8:	83 c4 10             	add    $0x10,%esp
  8032ab:	85 c0                	test   %eax,%eax
  8032ad:	0f 88 05 01 00 00    	js     8033b8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8032b3:	83 ec 0c             	sub    $0xc,%esp
  8032b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8032b9:	50                   	push   %eax
  8032ba:	e8 55 f8 ff ff       	call   802b14 <fd_alloc>
  8032bf:	89 c3                	mov    %eax,%ebx
  8032c1:	83 c4 10             	add    $0x10,%esp
  8032c4:	85 c0                	test   %eax,%eax
  8032c6:	0f 88 dc 00 00 00    	js     8033a8 <pipe+0x136>
  8032cc:	83 ec 04             	sub    $0x4,%esp
  8032cf:	68 07 04 00 00       	push   $0x407
  8032d4:	ff 75 ec             	pushl  -0x14(%ebp)
  8032d7:	6a 00                	push   $0x0
  8032d9:	e8 c3 f2 ff ff       	call   8025a1 <sys_page_alloc>
  8032de:	89 c3                	mov    %eax,%ebx
  8032e0:	83 c4 10             	add    $0x10,%esp
  8032e3:	85 c0                	test   %eax,%eax
  8032e5:	0f 88 bd 00 00 00    	js     8033a8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8032eb:	83 ec 0c             	sub    $0xc,%esp
  8032ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8032f1:	e8 06 f8 ff ff       	call   802afc <fd2data>
  8032f6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032f8:	83 c4 0c             	add    $0xc,%esp
  8032fb:	68 07 04 00 00       	push   $0x407
  803300:	50                   	push   %eax
  803301:	6a 00                	push   $0x0
  803303:	e8 99 f2 ff ff       	call   8025a1 <sys_page_alloc>
  803308:	89 c3                	mov    %eax,%ebx
  80330a:	83 c4 10             	add    $0x10,%esp
  80330d:	85 c0                	test   %eax,%eax
  80330f:	0f 88 83 00 00 00    	js     803398 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803315:	83 ec 0c             	sub    $0xc,%esp
  803318:	ff 75 ec             	pushl  -0x14(%ebp)
  80331b:	e8 dc f7 ff ff       	call   802afc <fd2data>
  803320:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803327:	50                   	push   %eax
  803328:	6a 00                	push   $0x0
  80332a:	56                   	push   %esi
  80332b:	6a 00                	push   $0x0
  80332d:	e8 2d f2 ff ff       	call   80255f <sys_page_map>
  803332:	89 c3                	mov    %eax,%ebx
  803334:	83 c4 20             	add    $0x20,%esp
  803337:	85 c0                	test   %eax,%eax
  803339:	78 4f                	js     80338a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80333b:	8b 15 84 90 80 00    	mov    0x809084,%edx
  803341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803344:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803349:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803350:	8b 15 84 90 80 00    	mov    0x809084,%edx
  803356:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803359:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80335b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80335e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803365:	83 ec 0c             	sub    $0xc,%esp
  803368:	ff 75 f0             	pushl  -0x10(%ebp)
  80336b:	e8 7c f7 ff ff       	call   802aec <fd2num>
  803370:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803372:	83 c4 04             	add    $0x4,%esp
  803375:	ff 75 ec             	pushl  -0x14(%ebp)
  803378:	e8 6f f7 ff ff       	call   802aec <fd2num>
  80337d:	89 47 04             	mov    %eax,0x4(%edi)
  803380:	bb 00 00 00 00       	mov    $0x0,%ebx
	return 0;
  803385:	83 c4 10             	add    $0x10,%esp
  803388:	eb 2e                	jmp    8033b8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80338a:	83 ec 08             	sub    $0x8,%esp
  80338d:	56                   	push   %esi
  80338e:	6a 00                	push   $0x0
  803390:	e8 88 f1 ff ff       	call   80251d <sys_page_unmap>
  803395:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803398:	83 ec 08             	sub    $0x8,%esp
  80339b:	ff 75 ec             	pushl  -0x14(%ebp)
  80339e:	6a 00                	push   $0x0
  8033a0:	e8 78 f1 ff ff       	call   80251d <sys_page_unmap>
  8033a5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8033a8:	83 ec 08             	sub    $0x8,%esp
  8033ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8033ae:	6a 00                	push   $0x0
  8033b0:	e8 68 f1 ff ff       	call   80251d <sys_page_unmap>
  8033b5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8033b8:	89 d8                	mov    %ebx,%eax
  8033ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033bd:	5b                   	pop    %ebx
  8033be:	5e                   	pop    %esi
  8033bf:	5f                   	pop    %edi
  8033c0:	c9                   	leave  
  8033c1:	c3                   	ret    
	...

008033c4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8033c4:	55                   	push   %ebp
  8033c5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8033c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8033cc:	c9                   	leave  
  8033cd:	c3                   	ret    

008033ce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8033ce:	55                   	push   %ebp
  8033cf:	89 e5                	mov    %esp,%ebp
  8033d1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8033d4:	68 5f 42 80 00       	push   $0x80425f
  8033d9:	ff 75 0c             	pushl  0xc(%ebp)
  8033dc:	e8 aa ec ff ff       	call   80208b <strcpy>
	return 0;
}
  8033e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8033e6:	c9                   	leave  
  8033e7:	c3                   	ret    

008033e8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8033e8:	55                   	push   %ebp
  8033e9:	89 e5                	mov    %esp,%ebp
  8033eb:	57                   	push   %edi
  8033ec:	56                   	push   %esi
  8033ed:	53                   	push   %ebx
  8033ee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  8033f4:	be 00 00 00 00       	mov    $0x0,%esi
  8033f9:	8d bd 74 ff ff ff    	lea    -0x8c(%ebp),%edi
  8033ff:	eb 2c                	jmp    80342d <devcons_write+0x45>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803401:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803404:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  803406:	83 fb 7f             	cmp    $0x7f,%ebx
  803409:	76 05                	jbe    803410 <devcons_write+0x28>
  80340b:	bb 7f 00 00 00       	mov    $0x7f,%ebx
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803410:	83 ec 04             	sub    $0x4,%esp
  803413:	53                   	push   %ebx
  803414:	03 45 0c             	add    0xc(%ebp),%eax
  803417:	50                   	push   %eax
  803418:	57                   	push   %edi
  803419:	e8 da ed ff ff       	call   8021f8 <memmove>
		sys_cputs(buf, m);
  80341e:	83 c4 08             	add    $0x8,%esp
  803421:	53                   	push   %ebx
  803422:	57                   	push   %edi
  803423:	e8 a7 ef ff ff       	call   8023cf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803428:	01 de                	add    %ebx,%esi
  80342a:	83 c4 10             	add    $0x10,%esp
  80342d:	89 f0                	mov    %esi,%eax
  80342f:	3b 75 10             	cmp    0x10(%ebp),%esi
  803432:	72 cd                	jb     803401 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803434:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803437:	5b                   	pop    %ebx
  803438:	5e                   	pop    %esi
  803439:	5f                   	pop    %edi
  80343a:	c9                   	leave  
  80343b:	c3                   	ret    

0080343c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80343c:	55                   	push   %ebp
  80343d:	89 e5                	mov    %esp,%ebp
  80343f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803442:	8b 45 08             	mov    0x8(%ebp),%eax
  803445:	88 45 ff             	mov    %al,-0x1(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803448:	6a 01                	push   $0x1
  80344a:	8d 45 ff             	lea    -0x1(%ebp),%eax
  80344d:	50                   	push   %eax
  80344e:	e8 7c ef ff ff       	call   8023cf <sys_cputs>
  803453:	83 c4 10             	add    $0x10,%esp
}
  803456:	c9                   	leave  
  803457:	c3                   	ret    

00803458 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803458:	55                   	push   %ebp
  803459:	89 e5                	mov    %esp,%ebp
  80345b:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80345e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803462:	74 27                	je     80348b <devcons_read+0x33>
  803464:	eb 05                	jmp    80346b <devcons_read+0x13>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803466:	e8 79 f1 ff ff       	call   8025e4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80346b:	e8 40 ef ff ff       	call   8023b0 <sys_cgetc>
  803470:	89 c2                	mov    %eax,%edx
  803472:	85 c0                	test   %eax,%eax
  803474:	74 f0                	je     803466 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  803476:	85 c0                	test   %eax,%eax
  803478:	78 16                	js     803490 <devcons_read+0x38>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80347a:	83 f8 04             	cmp    $0x4,%eax
  80347d:	74 0c                	je     80348b <devcons_read+0x33>
		return 0;
	*(char*)vbuf = c;
  80347f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803482:	88 10                	mov    %dl,(%eax)
  803484:	ba 01 00 00 00       	mov    $0x1,%edx
  803489:	eb 05                	jmp    803490 <devcons_read+0x38>
	return 1;
  80348b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  803490:	89 d0                	mov    %edx,%eax
  803492:	c9                   	leave  
  803493:	c3                   	ret    

00803494 <opencons>:
	return fd->fd_dev_id == devcons.dev_id;
}

int
opencons(void)
{
  803494:	55                   	push   %ebp
  803495:	89 e5                	mov    %esp,%ebp
  803497:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80349a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80349d:	50                   	push   %eax
  80349e:	e8 71 f6 ff ff       	call   802b14 <fd_alloc>
  8034a3:	83 c4 10             	add    $0x10,%esp
  8034a6:	85 c0                	test   %eax,%eax
  8034a8:	78 3b                	js     8034e5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8034aa:	83 ec 04             	sub    $0x4,%esp
  8034ad:	68 07 04 00 00       	push   $0x407
  8034b2:	ff 75 fc             	pushl  -0x4(%ebp)
  8034b5:	6a 00                	push   $0x0
  8034b7:	e8 e5 f0 ff ff       	call   8025a1 <sys_page_alloc>
  8034bc:	83 c4 10             	add    $0x10,%esp
  8034bf:	85 c0                	test   %eax,%eax
  8034c1:	78 22                	js     8034e5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8034c3:	a1 a0 90 80 00       	mov    0x8090a0,%eax
  8034c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8034cb:	89 02                	mov    %eax,(%edx)
	fd->fd_omode = O_RDWR;
  8034cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8034d0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8034d7:	83 ec 0c             	sub    $0xc,%esp
  8034da:	ff 75 fc             	pushl  -0x4(%ebp)
  8034dd:	e8 0a f6 ff ff       	call   802aec <fd2num>
  8034e2:	83 c4 10             	add    $0x10,%esp
}
  8034e5:	c9                   	leave  
  8034e6:	c3                   	ret    

008034e7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8034e7:	55                   	push   %ebp
  8034e8:	89 e5                	mov    %esp,%ebp
  8034ea:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8034ed:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8034f0:	50                   	push   %eax
  8034f1:	ff 75 08             	pushl  0x8(%ebp)
  8034f4:	e8 6e f6 ff ff       	call   802b67 <fd_lookup>
  8034f9:	83 c4 10             	add    $0x10,%esp
  8034fc:	85 c0                	test   %eax,%eax
  8034fe:	78 11                	js     803511 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803500:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803503:	8b 00                	mov    (%eax),%eax
  803505:	3b 05 a0 90 80 00    	cmp    0x8090a0,%eax
  80350b:	0f 94 c0             	sete   %al
  80350e:	0f b6 c0             	movzbl %al,%eax
}
  803511:	c9                   	leave  
  803512:	c3                   	ret    

00803513 <getchar>:
	sys_cputs(&c, 1);
}

int
getchar(void)
{
  803513:	55                   	push   %ebp
  803514:	89 e5                	mov    %esp,%ebp
  803516:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803519:	6a 01                	push   $0x1
  80351b:	8d 45 ff             	lea    -0x1(%ebp),%eax
  80351e:	50                   	push   %eax
  80351f:	6a 00                	push   $0x0
  803521:	e8 80 f8 ff ff       	call   802da6 <read>
	if (r < 0)
  803526:	83 c4 10             	add    $0x10,%esp
  803529:	85 c0                	test   %eax,%eax
  80352b:	78 0f                	js     80353c <getchar+0x29>
		return r;
	if (r < 1)
  80352d:	85 c0                	test   %eax,%eax
  80352f:	75 07                	jne    803538 <getchar+0x25>
  803531:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  803536:	eb 04                	jmp    80353c <getchar+0x29>
		return -E_EOF;
	return c;
  803538:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
  80353c:	c9                   	leave  
  80353d:	c3                   	ret    
	...

00803540 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803540:	55                   	push   %ebp
  803541:	89 e5                	mov    %esp,%ebp
  803543:	57                   	push   %edi
  803544:	56                   	push   %esi
  803545:	83 ec 28             	sub    $0x28,%esp
  803548:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80354f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  803556:	8b 45 10             	mov    0x10(%ebp),%eax
  803559:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80355c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80355f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  803561:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  803563:	8b 45 08             	mov    0x8(%ebp),%eax
  803566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  803569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80356c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80356f:	85 ff                	test   %edi,%edi
  803571:	75 21                	jne    803594 <__udivdi3+0x54>
    {
      if (d0 > n1)
  803573:	39 d1                	cmp    %edx,%ecx
  803575:	76 49                	jbe    8035c0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803577:	f7 f1                	div    %ecx
  803579:	89 c1                	mov    %eax,%ecx
  80357b:	31 c0                	xor    %eax,%eax
  80357d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803580:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  803583:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  803589:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80358c:	83 c4 28             	add    $0x28,%esp
  80358f:	5e                   	pop    %esi
  803590:	5f                   	pop    %edi
  803591:	c9                   	leave  
  803592:	c3                   	ret    
  803593:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803594:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  803597:	0f 87 97 00 00 00    	ja     803634 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80359d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8035a0:	83 f0 1f             	xor    $0x1f,%eax
  8035a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8035a6:	75 34                	jne    8035dc <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8035a8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  8035ab:	72 08                	jb     8035b5 <__udivdi3+0x75>
  8035ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8035b0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8035b3:	77 7f                	ja     803634 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8035b5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8035ba:	31 c0                	xor    %eax,%eax
  8035bc:	eb c2                	jmp    803580 <__udivdi3+0x40>
  8035be:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8035c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035c3:	85 c0                	test   %eax,%eax
  8035c5:	74 79                	je     803640 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8035c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8035ca:	89 fa                	mov    %edi,%edx
  8035cc:	f7 f1                	div    %ecx
  8035ce:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8035d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8035d3:	f7 f1                	div    %ecx
  8035d5:	89 c1                	mov    %eax,%ecx
  8035d7:	89 f0                	mov    %esi,%eax
  8035d9:	eb a5                	jmp    803580 <__udivdi3+0x40>
  8035db:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8035dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8035e1:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8035e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8035e7:	89 fa                	mov    %edi,%edx
  8035e9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8035ec:	d3 e2                	shl    %cl,%edx
  8035ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035f1:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8035f4:	d3 e8                	shr    %cl,%eax
  8035f6:	89 d7                	mov    %edx,%edi
  8035f8:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8035fa:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8035fd:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803600:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803602:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803605:	d3 e0                	shl    %cl,%eax
  803607:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80360a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  80360d:	d3 ea                	shr    %cl,%edx
  80360f:	09 d0                	or     %edx,%eax
  803611:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803614:	8b 55 e8             	mov    -0x18(%ebp),%edx
  803617:	d3 ea                	shr    %cl,%edx
  803619:	f7 f7                	div    %edi
  80361b:	89 d7                	mov    %edx,%edi
  80361d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  803620:	f7 e6                	mul    %esi
  803622:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803624:	39 d7                	cmp    %edx,%edi
  803626:	72 38                	jb     803660 <__udivdi3+0x120>
  803628:	74 27                	je     803651 <__udivdi3+0x111>
  80362a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80362d:	31 c0                	xor    %eax,%eax
  80362f:	e9 4c ff ff ff       	jmp    803580 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803634:	31 c9                	xor    %ecx,%ecx
  803636:	31 c0                	xor    %eax,%eax
  803638:	e9 43 ff ff ff       	jmp    803580 <__udivdi3+0x40>
  80363d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803640:	b8 01 00 00 00       	mov    $0x1,%eax
  803645:	31 d2                	xor    %edx,%edx
  803647:	f7 75 f4             	divl   -0xc(%ebp)
  80364a:	89 c1                	mov    %eax,%ecx
  80364c:	e9 76 ff ff ff       	jmp    8035c7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803651:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803654:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803657:	d3 e0                	shl    %cl,%eax
  803659:	39 f0                	cmp    %esi,%eax
  80365b:	73 cd                	jae    80362a <__udivdi3+0xea>
  80365d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803660:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  803663:	49                   	dec    %ecx
  803664:	31 c0                	xor    %eax,%eax
  803666:	e9 15 ff ff ff       	jmp    803580 <__udivdi3+0x40>
	...

0080366c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80366c:	55                   	push   %ebp
  80366d:	89 e5                	mov    %esp,%ebp
  80366f:	57                   	push   %edi
  803670:	56                   	push   %esi
  803671:	83 ec 30             	sub    $0x30,%esp
  803674:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80367b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  803682:	8b 75 08             	mov    0x8(%ebp),%esi
  803685:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803688:	8b 45 10             	mov    0x10(%ebp),%eax
  80368b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80368e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803691:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  803693:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  803696:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  803699:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80369c:	85 d2                	test   %edx,%edx
  80369e:	75 1c                	jne    8036bc <__umoddi3+0x50>
    {
      if (d0 > n1)
  8036a0:	89 fa                	mov    %edi,%edx
  8036a2:	39 f8                	cmp    %edi,%eax
  8036a4:	0f 86 c2 00 00 00    	jbe    80376c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8036aa:	89 f0                	mov    %esi,%eax
  8036ac:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  8036ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  8036b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8036b8:	eb 12                	jmp    8036cc <__umoddi3+0x60>
  8036ba:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8036bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8036bf:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  8036c2:	76 18                	jbe    8036dc <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  8036c4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  8036c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8036ca:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8036cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8036cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8036d2:	83 c4 30             	add    $0x30,%esp
  8036d5:	5e                   	pop    %esi
  8036d6:	5f                   	pop    %edi
  8036d7:	c9                   	leave  
  8036d8:	c3                   	ret    
  8036d9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8036dc:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8036e0:	83 f0 1f             	xor    $0x1f,%eax
  8036e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8036e6:	0f 84 ac 00 00 00    	je     803798 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8036ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8036f1:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8036f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8036f7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8036fa:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8036fd:	d3 e2                	shl    %cl,%edx
  8036ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  803702:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803705:	d3 e8                	shr    %cl,%eax
  803707:	89 d6                	mov    %edx,%esi
  803709:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  80370b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80370e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  803711:	d3 e0                	shl    %cl,%eax
  803713:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803716:	8b 7d f4             	mov    -0xc(%ebp),%edi
  803719:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80371b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80371e:	d3 e0                	shl    %cl,%eax
  803720:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803723:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803726:	d3 ea                	shr    %cl,%edx
  803728:	09 d0                	or     %edx,%eax
  80372a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80372d:	d3 ea                	shr    %cl,%edx
  80372f:	f7 f6                	div    %esi
  803731:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  803734:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803737:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  80373a:	0f 82 8d 00 00 00    	jb     8037cd <__umoddi3+0x161>
  803740:	0f 84 91 00 00 00    	je     8037d7 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803746:	8b 75 f0             	mov    -0x10(%ebp),%esi
  803749:	29 c7                	sub    %eax,%edi
  80374b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80374d:	89 f2                	mov    %esi,%edx
  80374f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  803752:	d3 e2                	shl    %cl,%edx
  803754:	89 f8                	mov    %edi,%eax
  803756:	8a 4d dc             	mov    -0x24(%ebp),%cl
  803759:	d3 e8                	shr    %cl,%eax
  80375b:	09 c2                	or     %eax,%edx
  80375d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  803760:	d3 ee                	shr    %cl,%esi
  803762:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  803765:	e9 62 ff ff ff       	jmp    8036cc <__umoddi3+0x60>
  80376a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80376c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80376f:	85 c0                	test   %eax,%eax
  803771:	74 15                	je     803788 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803773:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803776:	8b 55 e8             	mov    -0x18(%ebp),%edx
  803779:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80377b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80377e:	f7 f1                	div    %ecx
  803780:	e9 29 ff ff ff       	jmp    8036ae <__umoddi3+0x42>
  803785:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803788:	b8 01 00 00 00       	mov    $0x1,%eax
  80378d:	31 d2                	xor    %edx,%edx
  80378f:	f7 75 ec             	divl   -0x14(%ebp)
  803792:	89 c1                	mov    %eax,%ecx
  803794:	eb dd                	jmp    803773 <__umoddi3+0x107>
  803796:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803798:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80379b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80379e:	72 19                	jb     8037b9 <__umoddi3+0x14d>
  8037a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8037a3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  8037a6:	76 11                	jbe    8037b9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  8037a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8037ab:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  8037ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8037b1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8037b4:	e9 13 ff ff ff       	jmp    8036cc <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8037b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8037bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037bf:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8037c2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  8037c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8037c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8037cb:	eb db                	jmp    8037a8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8037cd:	2b 45 cc             	sub    -0x34(%ebp),%eax
  8037d0:	19 f2                	sbb    %esi,%edx
  8037d2:	e9 6f ff ff ff       	jmp    803746 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8037d7:	39 c7                	cmp    %eax,%edi
  8037d9:	72 f2                	jb     8037cd <__umoddi3+0x161>
  8037db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8037de:	e9 63 ff ff ff       	jmp    803746 <__umoddi3+0xda>
