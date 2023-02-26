
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	6a 64                	push   $0x64
  80003c:	68 0c 00 10 f0       	push   $0xf010000c
  800041:	e8 89 00 00 00       	call   8000cf <sys_cputs>
  800046:	83 c4 10             	add    $0x10,%esp
}
  800049:	c9                   	leave  
  80004a:	c3                   	ret    
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	8b 75 08             	mov    0x8(%ebp),%esi
  800054:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800057:	e8 a7 02 00 00       	call   800303 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800068:	c1 e0 07             	shl    $0x7,%eax
  80006b:	29 d0                	sub    %edx,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 f6                	test   %esi,%esi
  800079:	7e 07                	jle    800082 <libmain+0x36>
		binaryname = argv[0];
  80007b:	8b 03                	mov    (%ebx),%eax
  80007d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	53                   	push   %ebx
  800086:	56                   	push   %esi
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	c9                   	leave  
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 79 02 00 00       	call   800322 <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    
	...

008000b0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bb:	bf 00 00 00 00       	mov    $0x0,%edi
  8000c0:	89 fa                	mov    %edi,%edx
  8000c2:	89 f9                	mov    %edi,%ecx
  8000c4:	89 fb                	mov    %edi,%ebx
  8000c6:	89 fe                	mov    %edi,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 04             	sub    $0x4,%esp
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	bf 00 00 00 00       	mov    $0x0,%edi
  8000e3:	89 f8                	mov    %edi,%eax
  8000e5:	89 fb                	mov    %edi,%ebx
  8000e7:	89 fe                	mov    %edi,%esi
  8000e9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000eb:	83 c4 04             	add    $0x4,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800104:	bf 00 00 00 00       	mov    $0x0,%edi
  800109:	89 f9                	mov    %edi,%ecx
  80010b:	89 fb                	mov    %edi,%ebx
  80010d:	89 fe                	mov    %edi,%esi
  80010f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800111:	85 c0                	test   %eax,%eax
  800113:	7e 17                	jle    80012c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 0d                	push   $0xd
  80011b:	68 2a 0f 80 00       	push   $0x800f2a
  800120:	6a 23                	push   $0x23
  800122:	68 47 0f 80 00       	push   $0x800f47
  800127:	e8 38 02 00 00       	call   800364 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
  80013a:	8b 55 08             	mov    0x8(%ebp),%edx
  80013d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800143:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	b8 0c 00 00 00       	mov    $0xc,%eax
  80014b:	be 00 00 00 00       	mov    $0x0,%esi
  800150:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 0c             	sub    $0xc,%esp
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800166:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016b:	bf 00 00 00 00       	mov    $0x0,%edi
  800170:	89 fb                	mov    %edi,%ebx
  800172:	89 fe                	mov    %edi,%esi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 0a                	push   $0xa
  800180:	68 2a 0f 80 00       	push   $0x800f2a
  800185:	6a 23                	push   $0x23
  800187:	68 47 0f 80 00       	push   $0x800f47
  80018c:	e8 d3 01 00 00       	call   800364 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a8:	b8 09 00 00 00       	mov    $0x9,%eax
  8001ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8001b2:	89 fb                	mov    %edi,%ebx
  8001b4:	89 fe                	mov    %edi,%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 09                	push   $0x9
  8001c2:	68 2a 0f 80 00       	push   $0x800f2a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 47 0f 80 00       	push   $0x800f47
  8001ce:	e8 91 01 00 00       	call   800364 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8001ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f4:	89 fb                	mov    %edi,%ebx
  8001f6:	89 fe                	mov    %edi,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 08                	push   $0x8
  800204:	68 2a 0f 80 00       	push   $0x800f2a
  800209:	6a 23                	push   $0x23
  80020b:	68 47 0f 80 00       	push   $0x800f47
  800210:	e8 4f 01 00 00       	call   800364 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	8b 55 08             	mov    0x8(%ebp),%edx
  800229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	b8 06 00 00 00       	mov    $0x6,%eax
  800231:	bf 00 00 00 00       	mov    $0x0,%edi
  800236:	89 fb                	mov    %edi,%ebx
  800238:	89 fe                	mov    %edi,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 06                	push   $0x6
  800246:	68 2a 0f 80 00       	push   $0x800f2a
  80024b:	6a 23                	push   $0x23
  80024d:	68 47 0f 80 00       	push   $0x800f47
  800252:	e8 0d 01 00 00       	call   800364 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800271:	8b 7d 14             	mov    0x14(%ebp),%edi
  800274:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800277:	b8 05 00 00 00       	mov    $0x5,%eax
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 05                	push   $0x5
  800288:	68 2a 0f 80 00       	push   $0x800f2a
  80028d:	6a 23                	push   $0x23
  80028f:	68 47 0f 80 00       	push   $0x800f47
  800294:	e8 cb 00 00 00       	call   800364 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8002b8:	bf 00 00 00 00       	mov    $0x0,%edi
  8002bd:	89 fe                	mov    %edi,%esi
  8002bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7e 17                	jle    8002dc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	50                   	push   %eax
  8002c9:	6a 04                	push   $0x4
  8002cb:	68 2a 0f 80 00       	push   $0x800f2a
  8002d0:	6a 23                	push   $0x23
  8002d2:	68 47 0f 80 00       	push   $0x800f47
  8002d7:	e8 88 00 00 00       	call   800364 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ea:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f4:	89 fa                	mov    %edi,%edx
  8002f6:	89 f9                	mov    %edi,%ecx
  8002f8:	89 fb                	mov    %edi,%ebx
  8002fa:	89 fe                	mov    %edi,%esi
  8002fc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800309:	b8 02 00 00 00       	mov    $0x2,%eax
  80030e:	bf 00 00 00 00       	mov    $0x0,%edi
  800313:	89 fa                	mov    %edi,%edx
  800315:	89 f9                	mov    %edi,%ecx
  800317:	89 fb                	mov    %edi,%ebx
  800319:	89 fe                	mov    %edi,%esi
  80031b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032e:	b8 03 00 00 00       	mov    $0x3,%eax
  800333:	bf 00 00 00 00       	mov    $0x0,%edi
  800338:	89 f9                	mov    %edi,%ecx
  80033a:	89 fb                	mov    %edi,%ebx
  80033c:	89 fe                	mov    %edi,%esi
  80033e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 17                	jle    80035b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 03                	push   $0x3
  80034a:	68 2a 0f 80 00       	push   $0x800f2a
  80034f:	6a 23                	push   $0x23
  800351:	68 47 0f 80 00       	push   $0x800f47
  800356:	e8 09 00 00 00       	call   800364 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80035b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	c9                   	leave  
  800362:	c3                   	ret    
	...

00800364 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	53                   	push   %ebx
  800368:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80036b:	8d 45 14             	lea    0x14(%ebp),%eax
  80036e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800371:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800377:	e8 87 ff ff ff       	call   800303 <sys_getenvid>
  80037c:	83 ec 0c             	sub    $0xc,%esp
  80037f:	ff 75 0c             	pushl  0xc(%ebp)
  800382:	ff 75 08             	pushl  0x8(%ebp)
  800385:	53                   	push   %ebx
  800386:	50                   	push   %eax
  800387:	68 58 0f 80 00       	push   $0x800f58
  80038c:	e8 74 00 00 00       	call   800405 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800391:	83 c4 18             	add    $0x18,%esp
  800394:	ff 75 f8             	pushl  -0x8(%ebp)
  800397:	ff 75 10             	pushl  0x10(%ebp)
  80039a:	e8 15 00 00 00       	call   8003b4 <vcprintf>
	cprintf("\n");
  80039f:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  8003a6:	e8 5a 00 00 00       	call   800405 <cprintf>
  8003ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ae:	cc                   	int3   
  8003af:	eb fd                	jmp    8003ae <_panic+0x4a>
  8003b1:	00 00                	add    %al,(%eax)
	...

008003b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bd:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003c4:	00 00 00 
	b.cnt = 0;
  8003c7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	68 1c 04 80 00       	push   $0x80041c
  8003e3:	e8 70 01 00 00       	call   800558 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e8:	83 c4 08             	add    $0x8,%esp
  8003eb:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003f1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003f7:	50                   	push   %eax
  8003f8:	e8 d2 fc ff ff       	call   8000cf <sys_cputs>
  8003fd:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80040e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800411:	50                   	push   %eax
  800412:	ff 75 08             	pushl  0x8(%ebp)
  800415:	e8 9a ff ff ff       	call   8003b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	53                   	push   %ebx
  800420:	83 ec 04             	sub    $0x4,%esp
  800423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800426:	8b 03                	mov    (%ebx),%eax
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80042f:	40                   	inc    %eax
  800430:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800432:	3d ff 00 00 00       	cmp    $0xff,%eax
  800437:	75 1a                	jne    800453 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	68 ff 00 00 00       	push   $0xff
  800441:	8d 43 08             	lea    0x8(%ebx),%eax
  800444:	50                   	push   %eax
  800445:	e8 85 fc ff ff       	call   8000cf <sys_cputs>
		b->idx = 0;
  80044a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800450:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800453:	ff 43 04             	incl   0x4(%ebx)
}
  800456:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800459:	c9                   	leave  
  80045a:	c3                   	ret    
	...

0080045c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	83 ec 1c             	sub    $0x1c,%esp
  800465:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800468:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800477:	8b 55 10             	mov    0x10(%ebp),%edx
  80047a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80047d:	89 d6                	mov    %edx,%esi
  80047f:	bf 00 00 00 00       	mov    $0x0,%edi
  800484:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800487:	72 04                	jb     80048d <printnum+0x31>
  800489:	39 c2                	cmp    %eax,%edx
  80048b:	77 3f                	ja     8004cc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80048d:	83 ec 0c             	sub    $0xc,%esp
  800490:	ff 75 18             	pushl  0x18(%ebp)
  800493:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800496:	50                   	push   %eax
  800497:	52                   	push   %edx
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a3:	e8 d4 07 00 00       	call   800c7c <__udivdi3>
  8004a8:	83 c4 18             	add    $0x18,%esp
  8004ab:	52                   	push   %edx
  8004ac:	50                   	push   %eax
  8004ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004b3:	e8 a4 ff ff ff       	call   80045c <printnum>
  8004b8:	83 c4 20             	add    $0x20,%esp
  8004bb:	eb 14                	jmp    8004d1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 e8             	pushl  -0x18(%ebp)
  8004c3:	ff 75 18             	pushl  0x18(%ebp)
  8004c6:	ff 55 ec             	call   *-0x14(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cc:	4b                   	dec    %ebx
  8004cd:	85 db                	test   %ebx,%ebx
  8004cf:	7f ec                	jg     8004bd <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 e8             	pushl  -0x18(%ebp)
  8004d7:	83 ec 04             	sub    $0x4,%esp
  8004da:	57                   	push   %edi
  8004db:	56                   	push   %esi
  8004dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004df:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e2:	e8 c1 08 00 00       	call   800da8 <__umoddi3>
  8004e7:	83 c4 14             	add    $0x14,%esp
  8004ea:	0f be 80 7d 0f 80 00 	movsbl 0x800f7d(%eax),%eax
  8004f1:	50                   	push   %eax
  8004f2:	ff 55 ec             	call   *-0x14(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
}
  8004f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fb:	5b                   	pop    %ebx
  8004fc:	5e                   	pop    %esi
  8004fd:	5f                   	pop    %edi
  8004fe:	c9                   	leave  
  8004ff:	c3                   	ret    

00800500 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800505:	83 fa 01             	cmp    $0x1,%edx
  800508:	7e 0e                	jle    800518 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	8d 42 08             	lea    0x8(%edx),%eax
  80050f:	89 01                	mov    %eax,(%ecx)
  800511:	8b 02                	mov    (%edx),%eax
  800513:	8b 52 04             	mov    0x4(%edx),%edx
  800516:	eb 22                	jmp    80053a <getuint+0x3a>
	else if (lflag)
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 10                	je     80052c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80051c:	8b 10                	mov    (%eax),%edx
  80051e:	8d 42 04             	lea    0x4(%edx),%eax
  800521:	89 01                	mov    %eax,(%ecx)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	eb 0e                	jmp    80053a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	8d 42 04             	lea    0x4(%edx),%eax
  800531:	89 01                	mov    %eax,(%ecx)
  800533:	8b 02                	mov    (%edx),%eax
  800535:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800542:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800545:	8b 11                	mov    (%ecx),%edx
  800547:	3b 51 04             	cmp    0x4(%ecx),%edx
  80054a:	73 0a                	jae    800556 <sprintputch+0x1a>
		*b->buf++ = ch;
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	88 02                	mov    %al,(%edx)
  800551:	8d 42 01             	lea    0x1(%edx),%eax
  800554:	89 01                	mov    %eax,(%ecx)
}
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	57                   	push   %edi
  80055c:	56                   	push   %esi
  80055d:	53                   	push   %ebx
  80055e:	83 ec 3c             	sub    $0x3c,%esp
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800567:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056a:	eb 1a                	jmp    800586 <vprintfmt+0x2e>
  80056c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80056f:	eb 15                	jmp    800586 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800571:	84 c0                	test   %al,%al
  800573:	0f 84 15 03 00 00    	je     80088e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	0f b6 c0             	movzbl %al,%eax
  800580:	50                   	push   %eax
  800581:	ff d6                	call   *%esi
  800583:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800586:	8a 03                	mov    (%ebx),%al
  800588:	43                   	inc    %ebx
  800589:	3c 25                	cmp    $0x25,%al
  80058b:	75 e4                	jne    800571 <vprintfmt+0x19>
  80058d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800594:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005a9:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005ad:	eb 0a                	jmp    8005b9 <vprintfmt+0x61>
  8005af:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005b6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8a 03                	mov    (%ebx),%al
  8005bb:	0f b6 d0             	movzbl %al,%edx
  8005be:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005c1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005c4:	83 e8 23             	sub    $0x23,%eax
  8005c7:	3c 55                	cmp    $0x55,%al
  8005c9:	0f 87 9c 02 00 00    	ja     80086b <vprintfmt+0x313>
  8005cf:	0f b6 c0             	movzbl %al,%eax
  8005d2:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005d9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005dd:	eb d7                	jmp    8005b6 <vprintfmt+0x5e>
  8005df:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005e3:	eb d1                	jmp    8005b6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005e5:	89 d9                	mov    %ebx,%ecx
  8005e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ee:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005f4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005fb:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005ff:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800600:	8d 42 d0             	lea    -0x30(%edx),%eax
  800603:	83 f8 09             	cmp    $0x9,%eax
  800606:	77 21                	ja     800629 <vprintfmt+0xd1>
  800608:	eb e4                	jmp    8005ee <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80060a:	8b 55 14             	mov    0x14(%ebp),%edx
  80060d:	8d 42 04             	lea    0x4(%edx),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	8b 12                	mov    (%edx),%edx
  800615:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800618:	eb 12                	jmp    80062c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	79 96                	jns    8005b6 <vprintfmt+0x5e>
  800620:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800627:	eb 8d                	jmp    8005b6 <vprintfmt+0x5e>
  800629:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80062c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800630:	79 84                	jns    8005b6 <vprintfmt+0x5e>
  800632:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80063f:	e9 72 ff ff ff       	jmp    8005b6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800644:	ff 45 d4             	incl   -0x2c(%ebp)
  800647:	e9 6a ff ff ff       	jmp    8005b6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064c:	8b 55 14             	mov    0x14(%ebp),%edx
  80064f:	8d 42 04             	lea    0x4(%edx),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	57                   	push   %edi
  800659:	ff 32                	pushl  (%edx)
  80065b:	ff d6                	call   *%esi
			break;
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	e9 07 ff ff ff       	jmp    80056c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800665:	8b 55 14             	mov    0x14(%ebp),%edx
  800668:	8d 42 04             	lea    0x4(%edx),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
  80066e:	8b 02                	mov    (%edx),%eax
  800670:	85 c0                	test   %eax,%eax
  800672:	79 02                	jns    800676 <vprintfmt+0x11e>
  800674:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800676:	83 f8 0f             	cmp    $0xf,%eax
  800679:	7f 0b                	jg     800686 <vprintfmt+0x12e>
  80067b:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800682:	85 d2                	test   %edx,%edx
  800684:	75 15                	jne    80069b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800686:	50                   	push   %eax
  800687:	68 8e 0f 80 00       	push   $0x800f8e
  80068c:	57                   	push   %edi
  80068d:	56                   	push   %esi
  80068e:	e8 6e 02 00 00       	call   800901 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	e9 d1 fe ff ff       	jmp    80056c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80069b:	52                   	push   %edx
  80069c:	68 97 0f 80 00       	push   $0x800f97
  8006a1:	57                   	push   %edi
  8006a2:	56                   	push   %esi
  8006a3:	e8 59 02 00 00       	call   800901 <printfmt>
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	e9 bc fe ff ff       	jmp    80056c <vprintfmt+0x14>
  8006b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8006bc:	8d 42 04             	lea    0x4(%edx),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c2:	8b 1a                	mov    (%edx),%ebx
  8006c4:	85 db                	test   %ebx,%ebx
  8006c6:	75 05                	jne    8006cd <vprintfmt+0x175>
  8006c8:	bb 9a 0f 80 00       	mov    $0x800f9a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006d1:	7e 66                	jle    800739 <vprintfmt+0x1e1>
  8006d3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006d7:	74 60                	je     800739 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	51                   	push   %ecx
  8006dd:	53                   	push   %ebx
  8006de:	e8 57 02 00 00       	call   80093a <strnlen>
  8006e3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006f5:	eb 0f                	jmp    800706 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	57                   	push   %edi
  8006fb:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	ff 4d d8             	decl   -0x28(%ebp)
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070a:	7f eb                	jg     8006f7 <vprintfmt+0x19f>
  80070c:	eb 2b                	jmp    800739 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	74 15                	je     80072c <vprintfmt+0x1d4>
  800717:	8d 42 e0             	lea    -0x20(%edx),%eax
  80071a:	83 f8 5e             	cmp    $0x5e,%eax
  80071d:	76 0d                	jbe    80072c <vprintfmt+0x1d4>
					putch('?', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 3f                	push   $0x3f
  800725:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb 0a                	jmp    800736 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	57                   	push   %edi
  800730:	52                   	push   %edx
  800731:	ff d6                	call   *%esi
  800733:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800736:	ff 4d d8             	decl   -0x28(%ebp)
  800739:	8a 03                	mov    (%ebx),%al
  80073b:	43                   	inc    %ebx
  80073c:	84 c0                	test   %al,%al
  80073e:	74 1b                	je     80075b <vprintfmt+0x203>
  800740:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800744:	78 c8                	js     80070e <vprintfmt+0x1b6>
  800746:	ff 4d dc             	decl   -0x24(%ebp)
  800749:	79 c3                	jns    80070e <vprintfmt+0x1b6>
  80074b:	eb 0e                	jmp    80075b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	57                   	push   %edi
  800751:	6a 20                	push   $0x20
  800753:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800755:	ff 4d d8             	decl   -0x28(%ebp)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075f:	7f ec                	jg     80074d <vprintfmt+0x1f5>
  800761:	e9 06 fe ff ff       	jmp    80056c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800766:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80076a:	7e 10                	jle    80077c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80076c:	8b 55 14             	mov    0x14(%ebp),%edx
  80076f:	8d 42 08             	lea    0x8(%edx),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
  800775:	8b 02                	mov    (%edx),%eax
  800777:	8b 52 04             	mov    0x4(%edx),%edx
  80077a:	eb 20                	jmp    80079c <vprintfmt+0x244>
	else if (lflag)
  80077c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800780:	74 0e                	je     800790 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	99                   	cltd   
  80078e:	eb 0c                	jmp    80079c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80079c:	89 d1                	mov    %edx,%ecx
  80079e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8007a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007a6:	85 c9                	test   %ecx,%ecx
  8007a8:	78 0a                	js     8007b4 <vprintfmt+0x25c>
  8007aa:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007af:	e9 89 00 00 00       	jmp    80083d <vprintfmt+0x2e5>
				putch('-', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	57                   	push   %edi
  8007b8:	6a 2d                	push   $0x2d
  8007ba:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bc:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c2:	f7 da                	neg    %edx
  8007c4:	83 d1 00             	adc    $0x0,%ecx
  8007c7:	f7 d9                	neg    %ecx
  8007c9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	eb 6a                	jmp    80083d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d9:	e8 22 fd ff ff       	call   800500 <getuint>
  8007de:	89 d1                	mov    %edx,%ecx
  8007e0:	89 c2                	mov    %eax,%edx
  8007e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007e7:	eb 54                	jmp    80083d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ef:	e8 0c fd ff ff       	call   800500 <getuint>
  8007f4:	89 d1                	mov    %edx,%ecx
  8007f6:	89 c2                	mov    %eax,%edx
  8007f8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007fd:	eb 3e                	jmp    80083d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	57                   	push   %edi
  800803:	6a 30                	push   $0x30
  800805:	ff d6                	call   *%esi
			putch('x', putdat);
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	57                   	push   %edi
  80080b:	6a 78                	push   $0x78
  80080d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80080f:	8b 55 14             	mov    0x14(%ebp),%edx
  800812:	8d 42 04             	lea    0x4(%edx),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
  800818:	8b 12                	mov    (%edx),%edx
  80081a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	eb 14                	jmp    80083d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800829:	8d 45 14             	lea    0x14(%ebp),%eax
  80082c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80082f:	e8 cc fc ff ff       	call   800500 <getuint>
  800834:	89 d1                	mov    %edx,%ecx
  800836:	89 c2                	mov    %eax,%edx
  800838:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083d:	83 ec 0c             	sub    $0xc,%esp
  800840:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	ff 75 d8             	pushl  -0x28(%ebp)
  800848:	53                   	push   %ebx
  800849:	51                   	push   %ecx
  80084a:	52                   	push   %edx
  80084b:	89 fa                	mov    %edi,%edx
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	e8 08 fc ff ff       	call   80045c <printnum>
			break;
  800854:	83 c4 20             	add    $0x20,%esp
  800857:	e9 10 fd ff ff       	jmp    80056c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	57                   	push   %edi
  800860:	52                   	push   %edx
  800861:	ff d6                	call   *%esi
			break;
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	e9 01 fd ff ff       	jmp    80056c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	57                   	push   %edi
  80086f:	6a 25                	push   $0x25
  800871:	ff d6                	call   *%esi
  800873:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800876:	83 ea 02             	sub    $0x2,%edx
  800879:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087c:	8a 02                	mov    (%edx),%al
  80087e:	4a                   	dec    %edx
  80087f:	3c 25                	cmp    $0x25,%al
  800881:	75 f9                	jne    80087c <vprintfmt+0x324>
  800883:	83 c2 02             	add    $0x2,%edx
  800886:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800889:	e9 de fc ff ff       	jmp    80056c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80088e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5f                   	pop    %edi
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 18             	sub    $0x18,%esp
  80089c:	8b 55 08             	mov    0x8(%ebp),%edx
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	74 37                	je     8008dd <vsnprintf+0x47>
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	7e 33                	jle    8008dd <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008b8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bb:	ff 75 14             	pushl  0x14(%ebp)
  8008be:	ff 75 10             	pushl  0x10(%ebp)
  8008c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c4:	50                   	push   %eax
  8008c5:	68 3c 05 80 00       	push   $0x80053c
  8008ca:	e8 89 fc ff ff       	call   800558 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	eb 05                	jmp    8008e2 <vsnprintf+0x4c>
  8008dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008f0:	50                   	push   %eax
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 97 ff ff ff       	call   800896 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800907:	8d 45 14             	lea    0x14(%ebp),%eax
  80090a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80090d:	50                   	push   %eax
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 3c fc ff ff       	call   800558 <vprintfmt>
	va_end(ap);
  80091c:	83 c4 10             	add    $0x10,%esp
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    
  800921:	00 00                	add    %al,(%eax)
	...

00800924 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 55 08             	mov    0x8(%ebp),%edx
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
  80092f:	eb 01                	jmp    800932 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800931:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800932:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800936:	75 f9                	jne    800931 <strlen+0xd>
		n++;
	return n;
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
  800948:	eb 01                	jmp    80094b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80094a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094b:	39 d0                	cmp    %edx,%eax
  80094d:	74 06                	je     800955 <strnlen+0x1b>
  80094f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800953:	75 f5                	jne    80094a <strnlen+0x10>
		n++;
	return n;
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800960:	8a 01                	mov    (%ecx),%al
  800962:	88 02                	mov    %al,(%edx)
  800964:	42                   	inc    %edx
  800965:	41                   	inc    %ecx
  800966:	84 c0                	test   %al,%al
  800968:	75 f6                	jne    800960 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800976:	53                   	push   %ebx
  800977:	e8 a8 ff ff ff       	call   800924 <strlen>
	strcpy(dst + len, src);
  80097c:	ff 75 0c             	pushl  0xc(%ebp)
  80097f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800982:	50                   	push   %eax
  800983:	e8 cf ff ff ff       	call   800957 <strcpy>
	return dst;
}
  800988:	89 d8                	mov    %ebx,%eax
  80098a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 75 08             	mov    0x8(%ebp),%esi
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80099d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a2:	eb 0c                	jmp    8009b0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009a4:	8a 02                	mov    (%edx),%al
  8009a6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8009ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009af:	41                   	inc    %ecx
  8009b0:	39 d9                	cmp    %ebx,%ecx
  8009b2:	75 f0                	jne    8009a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b4:	89 f0                	mov    %esi,%eax
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c8:	85 c9                	test   %ecx,%ecx
  8009ca:	75 04                	jne    8009d0 <strlcpy+0x16>
  8009cc:	89 f0                	mov    %esi,%eax
  8009ce:	eb 14                	jmp    8009e4 <strlcpy+0x2a>
  8009d0:	89 f0                	mov    %esi,%eax
  8009d2:	eb 04                	jmp    8009d8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d4:	88 10                	mov    %dl,(%eax)
  8009d6:	40                   	inc    %eax
  8009d7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d8:	49                   	dec    %ecx
  8009d9:	74 06                	je     8009e1 <strlcpy+0x27>
  8009db:	8a 13                	mov    (%ebx),%dl
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	75 f3                	jne    8009d4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009e1:	c6 00 00             	movb   $0x0,(%eax)
  8009e4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f3:	eb 02                	jmp    8009f7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009f5:	42                   	inc    %edx
  8009f6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f7:	8a 02                	mov    (%edx),%al
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 04                	je     800a01 <strcmp+0x17>
  8009fd:	3a 01                	cmp    (%ecx),%al
  8009ff:	74 f4                	je     8009f5 <strcmp+0xb>
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 11             	movzbl (%ecx),%edx
  800a07:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a15:	8b 55 10             	mov    0x10(%ebp),%edx
  800a18:	eb 03                	jmp    800a1d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a1a:	4a                   	dec    %edx
  800a1b:	41                   	inc    %ecx
  800a1c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1d:	85 d2                	test   %edx,%edx
  800a1f:	75 07                	jne    800a28 <strncmp+0x1d>
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	eb 14                	jmp    800a3c <strncmp+0x31>
  800a28:	8a 01                	mov    (%ecx),%al
  800a2a:	84 c0                	test   %al,%al
  800a2c:	74 04                	je     800a32 <strncmp+0x27>
  800a2e:	3a 03                	cmp    (%ebx),%al
  800a30:	74 e8                	je     800a1a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a32:	0f b6 d0             	movzbl %al,%edx
  800a35:	0f b6 03             	movzbl (%ebx),%eax
  800a38:	29 c2                	sub    %eax,%edx
  800a3a:	89 d0                	mov    %edx,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a48:	eb 05                	jmp    800a4f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a4a:	38 ca                	cmp    %cl,%dl
  800a4c:	74 0c                	je     800a5a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4e:	40                   	inc    %eax
  800a4f:	8a 10                	mov    (%eax),%dl
  800a51:	84 d2                	test   %dl,%dl
  800a53:	75 f5                	jne    800a4a <strchr+0xb>
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a65:	eb 05                	jmp    800a6c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a67:	38 ca                	cmp    %cl,%dl
  800a69:	74 07                	je     800a72 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6b:	40                   	inc    %eax
  800a6c:	8a 10                	mov    (%eax),%dl
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	75 f5                	jne    800a67 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a83:	85 db                	test   %ebx,%ebx
  800a85:	74 36                	je     800abd <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8d:	75 29                	jne    800ab8 <memset+0x44>
  800a8f:	f6 c3 03             	test   $0x3,%bl
  800a92:	75 24                	jne    800ab8 <memset+0x44>
		c &= 0xFF;
  800a94:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a97:	89 d6                	mov    %edx,%esi
  800a99:	c1 e6 08             	shl    $0x8,%esi
  800a9c:	89 d0                	mov    %edx,%eax
  800a9e:	c1 e0 18             	shl    $0x18,%eax
  800aa1:	89 d1                	mov    %edx,%ecx
  800aa3:	c1 e1 10             	shl    $0x10,%ecx
  800aa6:	09 c8                	or     %ecx,%eax
  800aa8:	09 c2                	or     %eax,%edx
  800aaa:	89 f0                	mov    %esi,%eax
  800aac:	09 d0                	or     %edx,%eax
  800aae:	89 d9                	mov    %ebx,%ecx
  800ab0:	c1 e9 02             	shr    $0x2,%ecx
  800ab3:	fc                   	cld    
  800ab4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab6:	eb 05                	jmp    800abd <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab8:	89 d9                	mov    %ebx,%ecx
  800aba:	fc                   	cld    
  800abb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abd:	89 f8                	mov    %edi,%eax
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5f                   	pop    %edi
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800acf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ad2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad4:	39 c6                	cmp    %eax,%esi
  800ad6:	73 36                	jae    800b0e <memmove+0x4a>
  800ad8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adb:	39 d0                	cmp    %edx,%eax
  800add:	73 2f                	jae    800b0e <memmove+0x4a>
		s += n;
		d += n;
  800adf:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae2:	f6 c2 03             	test   $0x3,%dl
  800ae5:	75 1b                	jne    800b02 <memmove+0x3e>
  800ae7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aed:	75 13                	jne    800b02 <memmove+0x3e>
  800aef:	f6 c1 03             	test   $0x3,%cl
  800af2:	75 0e                	jne    800b02 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800af4:	8d 7e fc             	lea    -0x4(%esi),%edi
  800af7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afa:	c1 e9 02             	shr    $0x2,%ecx
  800afd:	fd                   	std    
  800afe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b00:	eb 09                	jmp    800b0b <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b02:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b05:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b08:	fd                   	std    
  800b09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0b:	fc                   	cld    
  800b0c:	eb 20                	jmp    800b2e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b14:	75 15                	jne    800b2b <memmove+0x67>
  800b16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1c:	75 0d                	jne    800b2b <memmove+0x67>
  800b1e:	f6 c1 03             	test   $0x3,%cl
  800b21:	75 08                	jne    800b2b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b23:	c1 e9 02             	shr    $0x2,%ecx
  800b26:	fc                   	cld    
  800b27:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b29:	eb 03                	jmp    800b2e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2b:	fc                   	cld    
  800b2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b35:	ff 75 10             	pushl  0x10(%ebp)
  800b38:	ff 75 0c             	pushl  0xc(%ebp)
  800b3b:	ff 75 08             	pushl  0x8(%ebp)
  800b3e:	e8 81 ff ff ff       	call   800ac4 <memmove>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	53                   	push   %ebx
  800b49:	83 ec 04             	sub    $0x4,%esp
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	eb 1b                	jmp    800b72 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b57:	8a 1a                	mov    (%edx),%bl
  800b59:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b5c:	8a 19                	mov    (%ecx),%bl
  800b5e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b61:	74 0d                	je     800b70 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b63:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b67:	0f b6 c3             	movzbl %bl,%eax
  800b6a:	29 c2                	sub    %eax,%edx
  800b6c:	89 d0                	mov    %edx,%eax
  800b6e:	eb 0d                	jmp    800b7d <memcmp+0x38>
		s1++, s2++;
  800b70:	42                   	inc    %edx
  800b71:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b72:	48                   	dec    %eax
  800b73:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b76:	75 df                	jne    800b57 <memcmp+0x12>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b7d:	83 c4 04             	add    $0x4,%esp
  800b80:	5b                   	pop    %ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	03 55 10             	add    0x10(%ebp),%edx
  800b91:	eb 05                	jmp    800b98 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b93:	38 08                	cmp    %cl,(%eax)
  800b95:	74 05                	je     800b9c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b97:	40                   	inc    %eax
  800b98:	39 d0                	cmp    %edx,%eax
  800b9a:	72 f7                	jb     800b93 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 04             	sub    $0x4,%esp
  800ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baa:	8b 75 10             	mov    0x10(%ebp),%esi
  800bad:	eb 01                	jmp    800bb0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800baf:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb0:	8a 01                	mov    (%ecx),%al
  800bb2:	3c 20                	cmp    $0x20,%al
  800bb4:	74 f9                	je     800baf <strtol+0x11>
  800bb6:	3c 09                	cmp    $0x9,%al
  800bb8:	74 f5                	je     800baf <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bba:	3c 2b                	cmp    $0x2b,%al
  800bbc:	75 0a                	jne    800bc8 <strtol+0x2a>
		s++;
  800bbe:	41                   	inc    %ecx
  800bbf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bc6:	eb 17                	jmp    800bdf <strtol+0x41>
	else if (*s == '-')
  800bc8:	3c 2d                	cmp    $0x2d,%al
  800bca:	74 09                	je     800bd5 <strtol+0x37>
  800bcc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd3:	eb 0a                	jmp    800bdf <strtol+0x41>
		s++, neg = 1;
  800bd5:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bd8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdf:	85 f6                	test   %esi,%esi
  800be1:	74 05                	je     800be8 <strtol+0x4a>
  800be3:	83 fe 10             	cmp    $0x10,%esi
  800be6:	75 1a                	jne    800c02 <strtol+0x64>
  800be8:	8a 01                	mov    (%ecx),%al
  800bea:	3c 30                	cmp    $0x30,%al
  800bec:	75 10                	jne    800bfe <strtol+0x60>
  800bee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf2:	75 0a                	jne    800bfe <strtol+0x60>
		s += 2, base = 16;
  800bf4:	83 c1 02             	add    $0x2,%ecx
  800bf7:	be 10 00 00 00       	mov    $0x10,%esi
  800bfc:	eb 04                	jmp    800c02 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bfe:	85 f6                	test   %esi,%esi
  800c00:	74 07                	je     800c09 <strtol+0x6b>
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
  800c07:	eb 13                	jmp    800c1c <strtol+0x7e>
  800c09:	3c 30                	cmp    $0x30,%al
  800c0b:	74 07                	je     800c14 <strtol+0x76>
  800c0d:	be 0a 00 00 00       	mov    $0xa,%esi
  800c12:	eb ee                	jmp    800c02 <strtol+0x64>
		s++, base = 8;
  800c14:	41                   	inc    %ecx
  800c15:	be 08 00 00 00       	mov    $0x8,%esi
  800c1a:	eb e6                	jmp    800c02 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c1c:	8a 11                	mov    (%ecx),%dl
  800c1e:	88 d3                	mov    %dl,%bl
  800c20:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c23:	3c 09                	cmp    $0x9,%al
  800c25:	77 08                	ja     800c2f <strtol+0x91>
			dig = *s - '0';
  800c27:	0f be c2             	movsbl %dl,%eax
  800c2a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c2d:	eb 1c                	jmp    800c4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c2f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c32:	3c 19                	cmp    $0x19,%al
  800c34:	77 08                	ja     800c3e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c36:	0f be c2             	movsbl %dl,%eax
  800c39:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c3c:	eb 0d                	jmp    800c4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c41:	3c 19                	cmp    $0x19,%al
  800c43:	77 15                	ja     800c5a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c45:	0f be c2             	movsbl %dl,%eax
  800c48:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c4b:	39 f2                	cmp    %esi,%edx
  800c4d:	7d 0b                	jge    800c5a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c4f:	41                   	inc    %ecx
  800c50:	89 f8                	mov    %edi,%eax
  800c52:	0f af c6             	imul   %esi,%eax
  800c55:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c58:	eb c2                	jmp    800c1c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c5a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c60:	74 05                	je     800c67 <strtol+0xc9>
		*endptr = (char *) s;
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c6b:	74 04                	je     800c71 <strtol+0xd3>
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	f7 df                	neg    %edi
}
  800c71:	89 f8                	mov    %edi,%eax
  800c73:	83 c4 04             	add    $0x4,%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    
	...

00800c7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	83 ec 28             	sub    $0x28,%esp
  800c84:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c8b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c92:	8b 45 10             	mov    0x10(%ebp),%eax
  800c95:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c9b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800c9d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca8:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cab:	85 ff                	test   %edi,%edi
  800cad:	75 21                	jne    800cd0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800caf:	39 d1                	cmp    %edx,%ecx
  800cb1:	76 49                	jbe    800cfc <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cb3:	f7 f1                	div    %ecx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	31 c0                	xor    %eax,%eax
  800cb9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cbc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cbf:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cc8:	83 c4 28             	add    $0x28,%esp
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    
  800ccf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cd0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cd3:	0f 87 97 00 00 00    	ja     800d70 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cd9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cdc:	83 f0 1f             	xor    $0x1f,%eax
  800cdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ce2:	75 34                	jne    800d18 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ce7:	72 08                	jb     800cf1 <__udivdi3+0x75>
  800ce9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800cec:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800cef:	77 7f                	ja     800d70 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cf1:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf6:	31 c0                	xor    %eax,%eax
  800cf8:	eb c2                	jmp    800cbc <__udivdi3+0x40>
  800cfa:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cff:	85 c0                	test   %eax,%eax
  800d01:	74 79                	je     800d7c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d03:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d06:	89 fa                	mov    %edi,%edx
  800d08:	f7 f1                	div    %ecx
  800d0a:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d0f:	f7 f1                	div    %ecx
  800d11:	89 c1                	mov    %eax,%ecx
  800d13:	89 f0                	mov    %esi,%eax
  800d15:	eb a5                	jmp    800cbc <__udivdi3+0x40>
  800d17:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d18:	b8 20 00 00 00       	mov    $0x20,%eax
  800d1d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d23:	89 fa                	mov    %edi,%edx
  800d25:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d28:	d3 e2                	shl    %cl,%edx
  800d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d30:	d3 e8                	shr    %cl,%eax
  800d32:	89 d7                	mov    %edx,%edi
  800d34:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d36:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d39:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d3c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d41:	d3 e0                	shl    %cl,%eax
  800d43:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d46:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d49:	d3 ea                	shr    %cl,%edx
  800d4b:	09 d0                	or     %edx,%eax
  800d4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d50:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d53:	d3 ea                	shr    %cl,%edx
  800d55:	f7 f7                	div    %edi
  800d57:	89 d7                	mov    %edx,%edi
  800d59:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d5c:	f7 e6                	mul    %esi
  800d5e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d60:	39 d7                	cmp    %edx,%edi
  800d62:	72 38                	jb     800d9c <__udivdi3+0x120>
  800d64:	74 27                	je     800d8d <__udivdi3+0x111>
  800d66:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d69:	31 c0                	xor    %eax,%eax
  800d6b:	e9 4c ff ff ff       	jmp    800cbc <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d70:	31 c9                	xor    %ecx,%ecx
  800d72:	31 c0                	xor    %eax,%eax
  800d74:	e9 43 ff ff ff       	jmp    800cbc <__udivdi3+0x40>
  800d79:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	f7 75 f4             	divl   -0xc(%ebp)
  800d86:	89 c1                	mov    %eax,%ecx
  800d88:	e9 76 ff ff ff       	jmp    800d03 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d90:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	39 f0                	cmp    %esi,%eax
  800d97:	73 cd                	jae    800d66 <__udivdi3+0xea>
  800d99:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d9c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d9f:	49                   	dec    %ecx
  800da0:	31 c0                	xor    %eax,%eax
  800da2:	e9 15 ff ff ff       	jmp    800cbc <__udivdi3+0x40>
	...

00800da8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	83 ec 30             	sub    $0x30,%esp
  800db0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800db7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dbe:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dcd:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dcf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dd2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dd5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd8:	85 d2                	test   %edx,%edx
  800dda:	75 1c                	jne    800df8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800ddc:	89 fa                	mov    %edi,%edx
  800dde:	39 f8                	cmp    %edi,%eax
  800de0:	0f 86 c2 00 00 00    	jbe    800ea8 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de6:	89 f0                	mov    %esi,%eax
  800de8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dea:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800ded:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800df4:	eb 12                	jmp    800e08 <__umoddi3+0x60>
  800df6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dfb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800dfe:	76 18                	jbe    800e18 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e00:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e03:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e06:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e08:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e0e:	83 c4 30             	add    $0x30,%esp
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e18:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e1c:	83 f0 1f             	xor    $0x1f,%eax
  800e1f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e22:	0f 84 ac 00 00 00    	je     800ed4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e28:	b8 20 00 00 00       	mov    $0x20,%eax
  800e2d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e33:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e36:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e39:	d3 e2                	shl    %cl,%edx
  800e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e3e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e41:	d3 e8                	shr    %cl,%eax
  800e43:	89 d6                	mov    %edx,%esi
  800e45:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e47:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e4a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e4d:	d3 e0                	shl    %cl,%eax
  800e4f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e52:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e55:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e5a:	d3 e0                	shl    %cl,%eax
  800e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e62:	d3 ea                	shr    %cl,%edx
  800e64:	09 d0                	or     %edx,%eax
  800e66:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e69:	d3 ea                	shr    %cl,%edx
  800e6b:	f7 f6                	div    %esi
  800e6d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e70:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e73:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e76:	0f 82 8d 00 00 00    	jb     800f09 <__umoddi3+0x161>
  800e7c:	0f 84 91 00 00 00    	je     800f13 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e82:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e85:	29 c7                	sub    %eax,%edi
  800e87:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e89:	89 f2                	mov    %esi,%edx
  800e8b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e8e:	d3 e2                	shl    %cl,%edx
  800e90:	89 f8                	mov    %edi,%eax
  800e92:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e95:	d3 e8                	shr    %cl,%eax
  800e97:	09 c2                	or     %eax,%edx
  800e99:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800e9c:	d3 ee                	shr    %cl,%esi
  800e9e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ea1:	e9 62 ff ff ff       	jmp    800e08 <__umoddi3+0x60>
  800ea6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eab:	85 c0                	test   %eax,%eax
  800ead:	74 15                	je     800ec4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eaf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eb2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eb5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eba:	f7 f1                	div    %ecx
  800ebc:	e9 29 ff ff ff       	jmp    800dea <__umoddi3+0x42>
  800ec1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec9:	31 d2                	xor    %edx,%edx
  800ecb:	f7 75 ec             	divl   -0x14(%ebp)
  800ece:	89 c1                	mov    %eax,%ecx
  800ed0:	eb dd                	jmp    800eaf <__umoddi3+0x107>
  800ed2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800eda:	72 19                	jb     800ef5 <__umoddi3+0x14d>
  800edc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800edf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ee2:	76 11                	jbe    800ef5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800eea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800eed:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ef0:	e9 13 ff ff ff       	jmp    800e08 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800efe:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f04:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f07:	eb db                	jmp    800ee4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f09:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f0c:	19 f2                	sbb    %esi,%edx
  800f0e:	e9 6f ff ff ff       	jmp    800e82 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f13:	39 c7                	cmp    %eax,%edi
  800f15:	72 f2                	jb     800f09 <__umoddi3+0x161>
  800f17:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f1a:	e9 63 ff ff ff       	jmp    800e82 <__umoddi3+0xda>
