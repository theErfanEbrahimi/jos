
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c9                   	leave  
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	8b 75 08             	mov    0x8(%ebp),%esi
  80004c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80004f:	e8 a7 02 00 00       	call   8002fb <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800060:	c1 e0 07             	shl    $0x7,%eax
  800063:	29 d0                	sub    %edx,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 f6                	test   %esi,%esi
  800071:	7e 07                	jle    80007a <libmain+0x36>
		binaryname = argv[0];
  800073:	8b 03                	mov    (%ebx),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	53                   	push   %ebx
  80007e:	56                   	push   %esi
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
  800089:	83 c4 10             	add    $0x10,%esp
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	c9                   	leave  
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 79 02 00 00       	call   80031a <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    
	...

008000a8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8000b8:	89 fa                	mov    %edi,%edx
  8000ba:	89 f9                	mov    %edi,%ecx
  8000bc:	89 fb                	mov    %edi,%ebx
  8000be:	89 fe                	mov    %edi,%esi
  8000c0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	83 ec 04             	sub    $0x4,%esp
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d6:	bf 00 00 00 00       	mov    $0x0,%edi
  8000db:	89 f8                	mov    %edi,%eax
  8000dd:	89 fb                	mov    %edi,%ebx
  8000df:	89 fe                	mov    %edi,%esi
  8000e1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e3:	83 c4 04             	add    $0x4,%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8000fc:	bf 00 00 00 00       	mov    $0x0,%edi
  800101:	89 f9                	mov    %edi,%ecx
  800103:	89 fb                	mov    %edi,%ebx
  800105:	89 fe                	mov    %edi,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 0d                	push   $0xd
  800113:	68 2a 0f 80 00       	push   $0x800f2a
  800118:	6a 23                	push   $0x23
  80011a:	68 47 0f 80 00       	push   $0x800f47
  80011f:	e8 38 02 00 00       	call   80035c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	8b 55 08             	mov    0x8(%ebp),%edx
  800135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800138:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80013b:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800143:	be 00 00 00 00       	mov    $0x0,%esi
  800148:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800163:	bf 00 00 00 00       	mov    $0x0,%edi
  800168:	89 fb                	mov    %edi,%ebx
  80016a:	89 fe                	mov    %edi,%esi
  80016c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 0a                	push   $0xa
  800178:	68 2a 0f 80 00       	push   $0x800f2a
  80017d:	6a 23                	push   $0x23
  80017f:	68 47 0f 80 00       	push   $0x800f47
  800184:	e8 d3 01 00 00       	call   80035c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a0:	b8 09 00 00 00       	mov    $0x9,%eax
  8001a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8001aa:	89 fb                	mov    %edi,%ebx
  8001ac:	89 fe                	mov    %edi,%esi
  8001ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 09                	push   $0x9
  8001ba:	68 2a 0f 80 00       	push   $0x800f2a
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 47 0f 80 00       	push   $0x800f47
  8001c6:	e8 91 01 00 00       	call   80035c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8001e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ec:	89 fb                	mov    %edi,%ebx
  8001ee:	89 fe                	mov    %edi,%esi
  8001f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 08                	push   $0x8
  8001fc:	68 2a 0f 80 00       	push   $0x800f2a
  800201:	6a 23                	push   $0x23
  800203:	68 47 0f 80 00       	push   $0x800f47
  800208:	e8 4f 01 00 00       	call   80035c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	8b 55 08             	mov    0x8(%ebp),%edx
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800224:	b8 06 00 00 00       	mov    $0x6,%eax
  800229:	bf 00 00 00 00       	mov    $0x0,%edi
  80022e:	89 fb                	mov    %edi,%ebx
  800230:	89 fe                	mov    %edi,%esi
  800232:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 06                	push   $0x6
  80023e:	68 2a 0f 80 00       	push   $0x800f2a
  800243:	6a 23                	push   $0x23
  800245:	68 47 0f 80 00       	push   $0x800f47
  80024a:	e8 0d 01 00 00       	call   80035c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800269:	8b 7d 14             	mov    0x14(%ebp),%edi
  80026c:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026f:	b8 05 00 00 00       	mov    $0x5,%eax
  800274:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 05                	push   $0x5
  800280:	68 2a 0f 80 00       	push   $0x800f2a
  800285:	6a 23                	push   $0x23
  800287:	68 47 0f 80 00       	push   $0x800f47
  80028c:	e8 cb 00 00 00       	call   80035c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	83 ec 0c             	sub    $0xc,%esp
  8002a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8002b0:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b5:	89 fe                	mov    %edi,%esi
  8002b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	7e 17                	jle    8002d4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	50                   	push   %eax
  8002c1:	6a 04                	push   $0x4
  8002c3:	68 2a 0f 80 00       	push   $0x800f2a
  8002c8:	6a 23                	push   $0x23
  8002ca:	68 47 0f 80 00       	push   $0x800f47
  8002cf:	e8 88 00 00 00       	call   80035c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8002ec:	89 fa                	mov    %edi,%edx
  8002ee:	89 f9                	mov    %edi,%ecx
  8002f0:	89 fb                	mov    %edi,%ebx
  8002f2:	89 fe                	mov    %edi,%esi
  8002f4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	57                   	push   %edi
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800301:	b8 02 00 00 00       	mov    $0x2,%eax
  800306:	bf 00 00 00 00       	mov    $0x0,%edi
  80030b:	89 fa                	mov    %edi,%edx
  80030d:	89 f9                	mov    %edi,%ecx
  80030f:	89 fb                	mov    %edi,%ebx
  800311:	89 fe                	mov    %edi,%esi
  800313:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	b8 03 00 00 00       	mov    $0x3,%eax
  80032b:	bf 00 00 00 00       	mov    $0x0,%edi
  800330:	89 f9                	mov    %edi,%ecx
  800332:	89 fb                	mov    %edi,%ebx
  800334:	89 fe                	mov    %edi,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 03                	push   $0x3
  800342:	68 2a 0f 80 00       	push   $0x800f2a
  800347:	6a 23                	push   $0x23
  800349:	68 47 0f 80 00       	push   $0x800f47
  80034e:	e8 09 00 00 00       	call   80035c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	c9                   	leave  
  80035a:	c3                   	ret    
	...

0080035c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	53                   	push   %ebx
  800360:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800363:	8d 45 14             	lea    0x14(%ebp),%eax
  800366:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800369:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80036f:	e8 87 ff ff ff       	call   8002fb <sys_getenvid>
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	53                   	push   %ebx
  80037e:	50                   	push   %eax
  80037f:	68 58 0f 80 00       	push   $0x800f58
  800384:	e8 74 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800389:	83 c4 18             	add    $0x18,%esp
  80038c:	ff 75 f8             	pushl  -0x8(%ebp)
  80038f:	ff 75 10             	pushl  0x10(%ebp)
  800392:	e8 15 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800397:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  80039e:	e8 5a 00 00 00       	call   8003fd <cprintf>
  8003a3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003a6:	cc                   	int3   
  8003a7:	eb fd                	jmp    8003a6 <_panic+0x4a>
  8003a9:	00 00                	add    %al,(%eax)
	...

008003ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 14 04 80 00       	push   $0x800414
  8003db:	e8 70 01 00 00       	call   800550 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003e9:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 d2 fc ff ff       	call   8000c7 <sys_cputs>
  8003f5:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
  800406:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800409:	50                   	push   %eax
  80040a:	ff 75 08             	pushl  0x8(%ebp)
  80040d:	e8 9a ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	53                   	push   %ebx
  800418:	83 ec 04             	sub    $0x4,%esp
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80041e:	8b 03                	mov    (%ebx),%eax
  800420:	8b 55 08             	mov    0x8(%ebp),%edx
  800423:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800427:	40                   	inc    %eax
  800428:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80042a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80042f:	75 1a                	jne    80044b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800431:	83 ec 08             	sub    $0x8,%esp
  800434:	68 ff 00 00 00       	push   $0xff
  800439:	8d 43 08             	lea    0x8(%ebx),%eax
  80043c:	50                   	push   %eax
  80043d:	e8 85 fc ff ff       	call   8000c7 <sys_cputs>
		b->idx = 0;
  800442:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800448:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80044b:	ff 43 04             	incl   0x4(%ebx)
}
  80044e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800451:	c9                   	leave  
  800452:	c3                   	ret    
	...

00800454 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 1c             	sub    $0x1c,%esp
  80045d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800460:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800463:	8b 45 08             	mov    0x8(%ebp),%eax
  800466:	8b 55 0c             	mov    0xc(%ebp),%edx
  800469:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80046f:	8b 55 10             	mov    0x10(%ebp),%edx
  800472:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800475:	89 d6                	mov    %edx,%esi
  800477:	bf 00 00 00 00       	mov    $0x0,%edi
  80047c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80047f:	72 04                	jb     800485 <printnum+0x31>
  800481:	39 c2                	cmp    %eax,%edx
  800483:	77 3f                	ja     8004c4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800485:	83 ec 0c             	sub    $0xc,%esp
  800488:	ff 75 18             	pushl  0x18(%ebp)
  80048b:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80048e:	50                   	push   %eax
  80048f:	52                   	push   %edx
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	ff 75 e4             	pushl  -0x1c(%ebp)
  800498:	ff 75 e0             	pushl  -0x20(%ebp)
  80049b:	e8 d4 07 00 00       	call   800c74 <__udivdi3>
  8004a0:	83 c4 18             	add    $0x18,%esp
  8004a3:	52                   	push   %edx
  8004a4:	50                   	push   %eax
  8004a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004ab:	e8 a4 ff ff ff       	call   800454 <printnum>
  8004b0:	83 c4 20             	add    $0x20,%esp
  8004b3:	eb 14                	jmp    8004c9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 e8             	pushl  -0x18(%ebp)
  8004bb:	ff 75 18             	pushl  0x18(%ebp)
  8004be:	ff 55 ec             	call   *-0x14(%ebp)
  8004c1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c4:	4b                   	dec    %ebx
  8004c5:	85 db                	test   %ebx,%ebx
  8004c7:	7f ec                	jg     8004b5 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 e8             	pushl  -0x18(%ebp)
  8004cf:	83 ec 04             	sub    $0x4,%esp
  8004d2:	57                   	push   %edi
  8004d3:	56                   	push   %esi
  8004d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004da:	e8 c1 08 00 00       	call   800da0 <__umoddi3>
  8004df:	83 c4 14             	add    $0x14,%esp
  8004e2:	0f be 80 7d 0f 80 00 	movsbl 0x800f7d(%eax),%eax
  8004e9:	50                   	push   %eax
  8004ea:	ff 55 ec             	call   *-0x14(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
}
  8004f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5f                   	pop    %edi
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    

008004f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004fd:	83 fa 01             	cmp    $0x1,%edx
  800500:	7e 0e                	jle    800510 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800502:	8b 10                	mov    (%eax),%edx
  800504:	8d 42 08             	lea    0x8(%edx),%eax
  800507:	89 01                	mov    %eax,(%ecx)
  800509:	8b 02                	mov    (%edx),%eax
  80050b:	8b 52 04             	mov    0x4(%edx),%edx
  80050e:	eb 22                	jmp    800532 <getuint+0x3a>
	else if (lflag)
  800510:	85 d2                	test   %edx,%edx
  800512:	74 10                	je     800524 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800514:	8b 10                	mov    (%eax),%edx
  800516:	8d 42 04             	lea    0x4(%edx),%eax
  800519:	89 01                	mov    %eax,(%ecx)
  80051b:	8b 02                	mov    (%edx),%eax
  80051d:	ba 00 00 00 00       	mov    $0x0,%edx
  800522:	eb 0e                	jmp    800532 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800524:	8b 10                	mov    (%eax),%edx
  800526:	8d 42 04             	lea    0x4(%edx),%eax
  800529:	89 01                	mov    %eax,(%ecx)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80053a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80053d:	8b 11                	mov    (%ecx),%edx
  80053f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800542:	73 0a                	jae    80054e <sprintputch+0x1a>
		*b->buf++ = ch;
  800544:	8b 45 08             	mov    0x8(%ebp),%eax
  800547:	88 02                	mov    %al,(%edx)
  800549:	8d 42 01             	lea    0x1(%edx),%eax
  80054c:	89 01                	mov    %eax,(%ecx)
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	57                   	push   %edi
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 3c             	sub    $0x3c,%esp
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800562:	eb 1a                	jmp    80057e <vprintfmt+0x2e>
  800564:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800567:	eb 15                	jmp    80057e <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800569:	84 c0                	test   %al,%al
  80056b:	0f 84 15 03 00 00    	je     800886 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	57                   	push   %edi
  800575:	0f b6 c0             	movzbl %al,%eax
  800578:	50                   	push   %eax
  800579:	ff d6                	call   *%esi
  80057b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057e:	8a 03                	mov    (%ebx),%al
  800580:	43                   	inc    %ebx
  800581:	3c 25                	cmp    $0x25,%al
  800583:	75 e4                	jne    800569 <vprintfmt+0x19>
  800585:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80058c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800593:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80059a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005a1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005a5:	eb 0a                	jmp    8005b1 <vprintfmt+0x61>
  8005a7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005ae:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8a 03                	mov    (%ebx),%al
  8005b3:	0f b6 d0             	movzbl %al,%edx
  8005b6:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005b9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005bc:	83 e8 23             	sub    $0x23,%eax
  8005bf:	3c 55                	cmp    $0x55,%al
  8005c1:	0f 87 9c 02 00 00    	ja     800863 <vprintfmt+0x313>
  8005c7:	0f b6 c0             	movzbl %al,%eax
  8005ca:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005d1:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005d5:	eb d7                	jmp    8005ae <vprintfmt+0x5e>
  8005d7:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005db:	eb d1                	jmp    8005ae <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005dd:	89 d9                	mov    %ebx,%ecx
  8005df:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e9:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005ec:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005f3:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005f7:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005f8:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005fb:	83 f8 09             	cmp    $0x9,%eax
  8005fe:	77 21                	ja     800621 <vprintfmt+0xd1>
  800600:	eb e4                	jmp    8005e6 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800602:	8b 55 14             	mov    0x14(%ebp),%edx
  800605:	8d 42 04             	lea    0x4(%edx),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
  80060b:	8b 12                	mov    (%edx),%edx
  80060d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800610:	eb 12                	jmp    800624 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	79 96                	jns    8005ae <vprintfmt+0x5e>
  800618:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80061f:	eb 8d                	jmp    8005ae <vprintfmt+0x5e>
  800621:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800624:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800628:	79 84                	jns    8005ae <vprintfmt+0x5e>
  80062a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800630:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800637:	e9 72 ff ff ff       	jmp    8005ae <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063c:	ff 45 d4             	incl   -0x2c(%ebp)
  80063f:	e9 6a ff ff ff       	jmp    8005ae <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800644:	8b 55 14             	mov    0x14(%ebp),%edx
  800647:	8d 42 04             	lea    0x4(%edx),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	57                   	push   %edi
  800651:	ff 32                	pushl  (%edx)
  800653:	ff d6                	call   *%esi
			break;
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	e9 07 ff ff ff       	jmp    800564 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065d:	8b 55 14             	mov    0x14(%ebp),%edx
  800660:	8d 42 04             	lea    0x4(%edx),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
  800666:	8b 02                	mov    (%edx),%eax
  800668:	85 c0                	test   %eax,%eax
  80066a:	79 02                	jns    80066e <vprintfmt+0x11e>
  80066c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 0f             	cmp    $0xf,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x12e>
  800673:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 15                	jne    800693 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80067e:	50                   	push   %eax
  80067f:	68 8e 0f 80 00       	push   $0x800f8e
  800684:	57                   	push   %edi
  800685:	56                   	push   %esi
  800686:	e8 6e 02 00 00       	call   8008f9 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	e9 d1 fe ff ff       	jmp    800564 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800693:	52                   	push   %edx
  800694:	68 97 0f 80 00       	push   $0x800f97
  800699:	57                   	push   %edi
  80069a:	56                   	push   %esi
  80069b:	e8 59 02 00 00       	call   8008f9 <printfmt>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	e9 bc fe ff ff       	jmp    800564 <vprintfmt+0x14>
  8006a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b1:	8b 55 14             	mov    0x14(%ebp),%edx
  8006b4:	8d 42 04             	lea    0x4(%edx),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ba:	8b 1a                	mov    (%edx),%ebx
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	75 05                	jne    8006c5 <vprintfmt+0x175>
  8006c0:	bb 9a 0f 80 00       	mov    $0x800f9a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006c9:	7e 66                	jle    800731 <vprintfmt+0x1e1>
  8006cb:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006cf:	74 60                	je     800731 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	51                   	push   %ecx
  8006d5:	53                   	push   %ebx
  8006d6:	e8 57 02 00 00       	call   800932 <strnlen>
  8006db:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006ea:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006ed:	eb 0f                	jmp    8006fe <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	57                   	push   %edi
  8006f3:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	ff 4d d8             	decl   -0x28(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800702:	7f eb                	jg     8006ef <vprintfmt+0x19f>
  800704:	eb 2b                	jmp    800731 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800709:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80070d:	74 15                	je     800724 <vprintfmt+0x1d4>
  80070f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800712:	83 f8 5e             	cmp    $0x5e,%eax
  800715:	76 0d                	jbe    800724 <vprintfmt+0x1d4>
					putch('?', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	57                   	push   %edi
  80071b:	6a 3f                	push   $0x3f
  80071d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 0a                	jmp    80072e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	57                   	push   %edi
  800728:	52                   	push   %edx
  800729:	ff d6                	call   *%esi
  80072b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072e:	ff 4d d8             	decl   -0x28(%ebp)
  800731:	8a 03                	mov    (%ebx),%al
  800733:	43                   	inc    %ebx
  800734:	84 c0                	test   %al,%al
  800736:	74 1b                	je     800753 <vprintfmt+0x203>
  800738:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80073c:	78 c8                	js     800706 <vprintfmt+0x1b6>
  80073e:	ff 4d dc             	decl   -0x24(%ebp)
  800741:	79 c3                	jns    800706 <vprintfmt+0x1b6>
  800743:	eb 0e                	jmp    800753 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	57                   	push   %edi
  800749:	6a 20                	push   $0x20
  80074b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074d:	ff 4d d8             	decl   -0x28(%ebp)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800757:	7f ec                	jg     800745 <vprintfmt+0x1f5>
  800759:	e9 06 fe ff ff       	jmp    800564 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800762:	7e 10                	jle    800774 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800764:	8b 55 14             	mov    0x14(%ebp),%edx
  800767:	8d 42 08             	lea    0x8(%edx),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	8b 02                	mov    (%edx),%eax
  80076f:	8b 52 04             	mov    0x4(%edx),%edx
  800772:	eb 20                	jmp    800794 <vprintfmt+0x244>
	else if (lflag)
  800774:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800778:	74 0e                	je     800788 <vprintfmt+0x238>
		return va_arg(*ap, long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	99                   	cltd   
  800786:	eb 0c                	jmp    800794 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 50 04             	lea    0x4(%eax),%edx
  80078e:	89 55 14             	mov    %edx,0x14(%ebp)
  800791:	8b 00                	mov    (%eax),%eax
  800793:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800794:	89 d1                	mov    %edx,%ecx
  800796:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800798:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80079b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80079e:	85 c9                	test   %ecx,%ecx
  8007a0:	78 0a                	js     8007ac <vprintfmt+0x25c>
  8007a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007a7:	e9 89 00 00 00       	jmp    800835 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	57                   	push   %edi
  8007b0:	6a 2d                	push   $0x2d
  8007b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007b7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007ba:	f7 da                	neg    %edx
  8007bc:	83 d1 00             	adc    $0x0,%ecx
  8007bf:	f7 d9                	neg    %ecx
  8007c1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 6a                	jmp    800835 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d1:	e8 22 fd ff ff       	call   8004f8 <getuint>
  8007d6:	89 d1                	mov    %edx,%ecx
  8007d8:	89 c2                	mov    %eax,%edx
  8007da:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007df:	eb 54                	jmp    800835 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e7:	e8 0c fd ff ff       	call   8004f8 <getuint>
  8007ec:	89 d1                	mov    %edx,%ecx
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007f5:	eb 3e                	jmp    800835 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	57                   	push   %edi
  8007fb:	6a 30                	push   $0x30
  8007fd:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ff:	83 c4 08             	add    $0x8,%esp
  800802:	57                   	push   %edi
  800803:	6a 78                	push   $0x78
  800805:	ff d6                	call   *%esi
			num = (unsigned long long)
  800807:	8b 55 14             	mov    0x14(%ebp),%edx
  80080a:	8d 42 04             	lea    0x4(%edx),%eax
  80080d:	89 45 14             	mov    %eax,0x14(%ebp)
  800810:	8b 12                	mov    (%edx),%edx
  800812:	b9 00 00 00 00       	mov    $0x0,%ecx
  800817:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081c:	83 c4 10             	add    $0x10,%esp
  80081f:	eb 14                	jmp    800835 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800821:	8d 45 14             	lea    0x14(%ebp),%eax
  800824:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800827:	e8 cc fc ff ff       	call   8004f8 <getuint>
  80082c:	89 d1                	mov    %edx,%ecx
  80082e:	89 c2                	mov    %eax,%edx
  800830:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800835:	83 ec 0c             	sub    $0xc,%esp
  800838:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	ff 75 d8             	pushl  -0x28(%ebp)
  800840:	53                   	push   %ebx
  800841:	51                   	push   %ecx
  800842:	52                   	push   %edx
  800843:	89 fa                	mov    %edi,%edx
  800845:	89 f0                	mov    %esi,%eax
  800847:	e8 08 fc ff ff       	call   800454 <printnum>
			break;
  80084c:	83 c4 20             	add    $0x20,%esp
  80084f:	e9 10 fd ff ff       	jmp    800564 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	57                   	push   %edi
  800858:	52                   	push   %edx
  800859:	ff d6                	call   *%esi
			break;
  80085b:	83 c4 10             	add    $0x10,%esp
  80085e:	e9 01 fd ff ff       	jmp    800564 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	57                   	push   %edi
  800867:	6a 25                	push   $0x25
  800869:	ff d6                	call   *%esi
  80086b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80086e:	83 ea 02             	sub    $0x2,%edx
  800871:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800874:	8a 02                	mov    (%edx),%al
  800876:	4a                   	dec    %edx
  800877:	3c 25                	cmp    $0x25,%al
  800879:	75 f9                	jne    800874 <vprintfmt+0x324>
  80087b:	83 c2 02             	add    $0x2,%edx
  80087e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800881:	e9 de fc ff ff       	jmp    800564 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800886:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5f                   	pop    %edi
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 18             	sub    $0x18,%esp
  800894:	8b 55 08             	mov    0x8(%ebp),%edx
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80089a:	85 d2                	test   %edx,%edx
  80089c:	74 37                	je     8008d5 <vsnprintf+0x47>
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	7e 33                	jle    8008d5 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008b0:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b3:	ff 75 14             	pushl  0x14(%ebp)
  8008b6:	ff 75 10             	pushl  0x10(%ebp)
  8008b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	68 34 05 80 00       	push   $0x800534
  8008c2:	e8 89 fc ff ff       	call   800550 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 05                	jmp    8008da <vsnprintf+0x4c>
  8008d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e8:	50                   	push   %eax
  8008e9:	ff 75 10             	pushl  0x10(%ebp)
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 97 ff ff ff       	call   80088e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800902:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800905:	50                   	push   %eax
  800906:	ff 75 10             	pushl  0x10(%ebp)
  800909:	ff 75 0c             	pushl  0xc(%ebp)
  80090c:	ff 75 08             	pushl  0x8(%ebp)
  80090f:	e8 3c fc ff ff       	call   800550 <vprintfmt>
	va_end(ap);
  800914:	83 c4 10             	add    $0x10,%esp
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    
  800919:	00 00                	add    %al,(%eax)
	...

0080091c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 55 08             	mov    0x8(%ebp),%edx
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 01                	jmp    80092a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800929:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80092e:	75 f9                	jne    800929 <strlen+0xd>
		n++;
	return n;
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800938:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093b:	b8 00 00 00 00       	mov    $0x0,%eax
  800940:	eb 01                	jmp    800943 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800942:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800943:	39 d0                	cmp    %edx,%eax
  800945:	74 06                	je     80094d <strnlen+0x1b>
  800947:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80094b:	75 f5                	jne    800942 <strnlen+0x10>
		n++;
	return n;
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800955:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800958:	8a 01                	mov    (%ecx),%al
  80095a:	88 02                	mov    %al,(%edx)
  80095c:	42                   	inc    %edx
  80095d:	41                   	inc    %ecx
  80095e:	84 c0                	test   %al,%al
  800960:	75 f6                	jne    800958 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096e:	53                   	push   %ebx
  80096f:	e8 a8 ff ff ff       	call   80091c <strlen>
	strcpy(dst + len, src);
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80097a:	50                   	push   %eax
  80097b:	e8 cf ff ff ff       	call   80094f <strcpy>
	return dst;
}
  800980:	89 d8                	mov    %ebx,%eax
  800982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 75 08             	mov    0x8(%ebp),%esi
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800995:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099a:	eb 0c                	jmp    8009a8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  80099c:	8a 02                	mov    (%edx),%al
  80099e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a1:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a7:	41                   	inc    %ecx
  8009a8:	39 d9                	cmp    %ebx,%ecx
  8009aa:	75 f0                	jne    80099c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	75 04                	jne    8009c8 <strlcpy+0x16>
  8009c4:	89 f0                	mov    %esi,%eax
  8009c6:	eb 14                	jmp    8009dc <strlcpy+0x2a>
  8009c8:	89 f0                	mov    %esi,%eax
  8009ca:	eb 04                	jmp    8009d0 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cc:	88 10                	mov    %dl,(%eax)
  8009ce:	40                   	inc    %eax
  8009cf:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d0:	49                   	dec    %ecx
  8009d1:	74 06                	je     8009d9 <strlcpy+0x27>
  8009d3:	8a 13                	mov    (%ebx),%dl
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	75 f3                	jne    8009cc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009d9:	c6 00 00             	movb   $0x0,(%eax)
  8009dc:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009eb:	eb 02                	jmp    8009ef <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009ed:	42                   	inc    %edx
  8009ee:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ef:	8a 02                	mov    (%edx),%al
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 04                	je     8009f9 <strcmp+0x17>
  8009f5:	3a 01                	cmp    (%ecx),%al
  8009f7:	74 f4                	je     8009ed <strcmp+0xb>
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 11             	movzbl (%ecx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a0d:	8b 55 10             	mov    0x10(%ebp),%edx
  800a10:	eb 03                	jmp    800a15 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a12:	4a                   	dec    %edx
  800a13:	41                   	inc    %ecx
  800a14:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a15:	85 d2                	test   %edx,%edx
  800a17:	75 07                	jne    800a20 <strncmp+0x1d>
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	eb 14                	jmp    800a34 <strncmp+0x31>
  800a20:	8a 01                	mov    (%ecx),%al
  800a22:	84 c0                	test   %al,%al
  800a24:	74 04                	je     800a2a <strncmp+0x27>
  800a26:	3a 03                	cmp    (%ebx),%al
  800a28:	74 e8                	je     800a12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2a:	0f b6 d0             	movzbl %al,%edx
  800a2d:	0f b6 03             	movzbl (%ebx),%eax
  800a30:	29 c2                	sub    %eax,%edx
  800a32:	89 d0                	mov    %edx,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a40:	eb 05                	jmp    800a47 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	74 0c                	je     800a52 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a46:	40                   	inc    %eax
  800a47:	8a 10                	mov    (%eax),%dl
  800a49:	84 d2                	test   %dl,%dl
  800a4b:	75 f5                	jne    800a42 <strchr+0xb>
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a5d:	eb 05                	jmp    800a64 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	74 07                	je     800a6a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a63:	40                   	inc    %eax
  800a64:	8a 10                	mov    (%eax),%dl
  800a66:	84 d2                	test   %dl,%dl
  800a68:	75 f5                	jne    800a5f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	74 36                	je     800ab5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 29                	jne    800ab0 <memset+0x44>
  800a87:	f6 c3 03             	test   $0x3,%bl
  800a8a:	75 24                	jne    800ab0 <memset+0x44>
		c &= 0xFF;
  800a8c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a8f:	89 d6                	mov    %edx,%esi
  800a91:	c1 e6 08             	shl    $0x8,%esi
  800a94:	89 d0                	mov    %edx,%eax
  800a96:	c1 e0 18             	shl    $0x18,%eax
  800a99:	89 d1                	mov    %edx,%ecx
  800a9b:	c1 e1 10             	shl    $0x10,%ecx
  800a9e:	09 c8                	or     %ecx,%eax
  800aa0:	09 c2                	or     %eax,%edx
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	09 d0                	or     %edx,%eax
  800aa6:	89 d9                	mov    %ebx,%ecx
  800aa8:	c1 e9 02             	shr    $0x2,%ecx
  800aab:	fc                   	cld    
  800aac:	f3 ab                	rep stos %eax,%es:(%edi)
  800aae:	eb 05                	jmp    800ab5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab0:	89 d9                	mov    %ebx,%ecx
  800ab2:	fc                   	cld    
  800ab3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab5:	89 f8                	mov    %edi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aca:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800acc:	39 c6                	cmp    %eax,%esi
  800ace:	73 36                	jae    800b06 <memmove+0x4a>
  800ad0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad3:	39 d0                	cmp    %edx,%eax
  800ad5:	73 2f                	jae    800b06 <memmove+0x4a>
		s += n;
		d += n;
  800ad7:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ada:	f6 c2 03             	test   $0x3,%dl
  800add:	75 1b                	jne    800afa <memmove+0x3e>
  800adf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae5:	75 13                	jne    800afa <memmove+0x3e>
  800ae7:	f6 c1 03             	test   $0x3,%cl
  800aea:	75 0e                	jne    800afa <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800aec:	8d 7e fc             	lea    -0x4(%esi),%edi
  800aef:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af2:	c1 e9 02             	shr    $0x2,%ecx
  800af5:	fd                   	std    
  800af6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af8:	eb 09                	jmp    800b03 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afa:	8d 7e ff             	lea    -0x1(%esi),%edi
  800afd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b00:	fd                   	std    
  800b01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b03:	fc                   	cld    
  800b04:	eb 20                	jmp    800b26 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0c:	75 15                	jne    800b23 <memmove+0x67>
  800b0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b14:	75 0d                	jne    800b23 <memmove+0x67>
  800b16:	f6 c1 03             	test   $0x3,%cl
  800b19:	75 08                	jne    800b23 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
  800b1e:	fc                   	cld    
  800b1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b21:	eb 03                	jmp    800b26 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b23:	fc                   	cld    
  800b24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b2d:	ff 75 10             	pushl  0x10(%ebp)
  800b30:	ff 75 0c             	pushl  0xc(%ebp)
  800b33:	ff 75 08             	pushl  0x8(%ebp)
  800b36:	e8 81 ff ff ff       	call   800abc <memmove>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	53                   	push   %ebx
  800b41:	83 ec 04             	sub    $0x4,%esp
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	eb 1b                	jmp    800b6a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b4f:	8a 1a                	mov    (%edx),%bl
  800b51:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b54:	8a 19                	mov    (%ecx),%bl
  800b56:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b59:	74 0d                	je     800b68 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b5b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b5f:	0f b6 c3             	movzbl %bl,%eax
  800b62:	29 c2                	sub    %eax,%edx
  800b64:	89 d0                	mov    %edx,%eax
  800b66:	eb 0d                	jmp    800b75 <memcmp+0x38>
		s1++, s2++;
  800b68:	42                   	inc    %edx
  800b69:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6a:	48                   	dec    %eax
  800b6b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b6e:	75 df                	jne    800b4f <memcmp+0x12>
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b75:	83 c4 04             	add    $0x4,%esp
  800b78:	5b                   	pop    %ebx
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	03 55 10             	add    0x10(%ebp),%edx
  800b89:	eb 05                	jmp    800b90 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8b:	38 08                	cmp    %cl,(%eax)
  800b8d:	74 05                	je     800b94 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8f:	40                   	inc    %eax
  800b90:	39 d0                	cmp    %edx,%eax
  800b92:	72 f7                	jb     800b8b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 04             	sub    $0x4,%esp
  800b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba2:	8b 75 10             	mov    0x10(%ebp),%esi
  800ba5:	eb 01                	jmp    800ba8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ba7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba8:	8a 01                	mov    (%ecx),%al
  800baa:	3c 20                	cmp    $0x20,%al
  800bac:	74 f9                	je     800ba7 <strtol+0x11>
  800bae:	3c 09                	cmp    $0x9,%al
  800bb0:	74 f5                	je     800ba7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb2:	3c 2b                	cmp    $0x2b,%al
  800bb4:	75 0a                	jne    800bc0 <strtol+0x2a>
		s++;
  800bb6:	41                   	inc    %ecx
  800bb7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bbe:	eb 17                	jmp    800bd7 <strtol+0x41>
	else if (*s == '-')
  800bc0:	3c 2d                	cmp    $0x2d,%al
  800bc2:	74 09                	je     800bcd <strtol+0x37>
  800bc4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bcb:	eb 0a                	jmp    800bd7 <strtol+0x41>
		s++, neg = 1;
  800bcd:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bd0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd7:	85 f6                	test   %esi,%esi
  800bd9:	74 05                	je     800be0 <strtol+0x4a>
  800bdb:	83 fe 10             	cmp    $0x10,%esi
  800bde:	75 1a                	jne    800bfa <strtol+0x64>
  800be0:	8a 01                	mov    (%ecx),%al
  800be2:	3c 30                	cmp    $0x30,%al
  800be4:	75 10                	jne    800bf6 <strtol+0x60>
  800be6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bea:	75 0a                	jne    800bf6 <strtol+0x60>
		s += 2, base = 16;
  800bec:	83 c1 02             	add    $0x2,%ecx
  800bef:	be 10 00 00 00       	mov    $0x10,%esi
  800bf4:	eb 04                	jmp    800bfa <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bf6:	85 f6                	test   %esi,%esi
  800bf8:	74 07                	je     800c01 <strtol+0x6b>
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb 13                	jmp    800c14 <strtol+0x7e>
  800c01:	3c 30                	cmp    $0x30,%al
  800c03:	74 07                	je     800c0c <strtol+0x76>
  800c05:	be 0a 00 00 00       	mov    $0xa,%esi
  800c0a:	eb ee                	jmp    800bfa <strtol+0x64>
		s++, base = 8;
  800c0c:	41                   	inc    %ecx
  800c0d:	be 08 00 00 00       	mov    $0x8,%esi
  800c12:	eb e6                	jmp    800bfa <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c14:	8a 11                	mov    (%ecx),%dl
  800c16:	88 d3                	mov    %dl,%bl
  800c18:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c1b:	3c 09                	cmp    $0x9,%al
  800c1d:	77 08                	ja     800c27 <strtol+0x91>
			dig = *s - '0';
  800c1f:	0f be c2             	movsbl %dl,%eax
  800c22:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c25:	eb 1c                	jmp    800c43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c27:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c2a:	3c 19                	cmp    $0x19,%al
  800c2c:	77 08                	ja     800c36 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c2e:	0f be c2             	movsbl %dl,%eax
  800c31:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c34:	eb 0d                	jmp    800c43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c36:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c39:	3c 19                	cmp    $0x19,%al
  800c3b:	77 15                	ja     800c52 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c3d:	0f be c2             	movsbl %dl,%eax
  800c40:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c43:	39 f2                	cmp    %esi,%edx
  800c45:	7d 0b                	jge    800c52 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c47:	41                   	inc    %ecx
  800c48:	89 f8                	mov    %edi,%eax
  800c4a:	0f af c6             	imul   %esi,%eax
  800c4d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c50:	eb c2                	jmp    800c14 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c52:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c58:	74 05                	je     800c5f <strtol+0xc9>
		*endptr = (char *) s;
  800c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c5f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c63:	74 04                	je     800c69 <strtol+0xd3>
  800c65:	89 c7                	mov    %eax,%edi
  800c67:	f7 df                	neg    %edi
}
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	83 c4 04             	add    $0x4,%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    
	...

00800c74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	83 ec 28             	sub    $0x28,%esp
  800c7c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c83:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8d:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c93:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800c95:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800c9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca0:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ca3:	85 ff                	test   %edi,%edi
  800ca5:	75 21                	jne    800cc8 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800ca7:	39 d1                	cmp    %edx,%ecx
  800ca9:	76 49                	jbe    800cf4 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cab:	f7 f1                	div    %ecx
  800cad:	89 c1                	mov    %eax,%ecx
  800caf:	31 c0                	xor    %eax,%eax
  800cb1:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cb7:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cc0:	83 c4 28             	add    $0x28,%esp
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    
  800cc7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cc8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ccb:	0f 87 97 00 00 00    	ja     800d68 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cd1:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cd4:	83 f0 1f             	xor    $0x1f,%eax
  800cd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cda:	75 34                	jne    800d10 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cdc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cdf:	72 08                	jb     800ce9 <__udivdi3+0x75>
  800ce1:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ce4:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ce7:	77 7f                	ja     800d68 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ce9:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cee:	31 c0                	xor    %eax,%eax
  800cf0:	eb c2                	jmp    800cb4 <__udivdi3+0x40>
  800cf2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	74 79                	je     800d74 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cfe:	89 fa                	mov    %edi,%edx
  800d00:	f7 f1                	div    %ecx
  800d02:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d07:	f7 f1                	div    %ecx
  800d09:	89 c1                	mov    %eax,%ecx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	eb a5                	jmp    800cb4 <__udivdi3+0x40>
  800d0f:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d10:	b8 20 00 00 00       	mov    $0x20,%eax
  800d15:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d1b:	89 fa                	mov    %edi,%edx
  800d1d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d20:	d3 e2                	shl    %cl,%edx
  800d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d25:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d28:	d3 e8                	shr    %cl,%eax
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d2e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d31:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d34:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d36:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d39:	d3 e0                	shl    %cl,%eax
  800d3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d3e:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d41:	d3 ea                	shr    %cl,%edx
  800d43:	09 d0                	or     %edx,%eax
  800d45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d48:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d4b:	d3 ea                	shr    %cl,%edx
  800d4d:	f7 f7                	div    %edi
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d54:	f7 e6                	mul    %esi
  800d56:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d58:	39 d7                	cmp    %edx,%edi
  800d5a:	72 38                	jb     800d94 <__udivdi3+0x120>
  800d5c:	74 27                	je     800d85 <__udivdi3+0x111>
  800d5e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d61:	31 c0                	xor    %eax,%eax
  800d63:	e9 4c ff ff ff       	jmp    800cb4 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d68:	31 c9                	xor    %ecx,%ecx
  800d6a:	31 c0                	xor    %eax,%eax
  800d6c:	e9 43 ff ff ff       	jmp    800cb4 <__udivdi3+0x40>
  800d71:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d74:	b8 01 00 00 00       	mov    $0x1,%eax
  800d79:	31 d2                	xor    %edx,%edx
  800d7b:	f7 75 f4             	divl   -0xc(%ebp)
  800d7e:	89 c1                	mov    %eax,%ecx
  800d80:	e9 76 ff ff ff       	jmp    800cfb <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d88:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d8b:	d3 e0                	shl    %cl,%eax
  800d8d:	39 f0                	cmp    %esi,%eax
  800d8f:	73 cd                	jae    800d5e <__udivdi3+0xea>
  800d91:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d94:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d97:	49                   	dec    %ecx
  800d98:	31 c0                	xor    %eax,%eax
  800d9a:	e9 15 ff ff ff       	jmp    800cb4 <__udivdi3+0x40>
	...

00800da0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	83 ec 30             	sub    $0x30,%esp
  800da8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800daf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800db6:	8b 75 08             	mov    0x8(%ebp),%esi
  800db9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbf:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dc5:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dc7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dca:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dcd:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd0:	85 d2                	test   %edx,%edx
  800dd2:	75 1c                	jne    800df0 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800dd4:	89 fa                	mov    %edi,%edx
  800dd6:	39 f8                	cmp    %edi,%eax
  800dd8:	0f 86 c2 00 00 00    	jbe    800ea0 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dde:	89 f0                	mov    %esi,%eax
  800de0:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800de2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800de5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dec:	eb 12                	jmp    800e00 <__umoddi3+0x60>
  800dee:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df3:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800df6:	76 18                	jbe    800e10 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800dfb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800dfe:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e00:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e03:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e06:	83 c4 30             	add    $0x30,%esp
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    
  800e0d:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e10:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e14:	83 f0 1f             	xor    $0x1f,%eax
  800e17:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e1a:	0f 84 ac 00 00 00    	je     800ecc <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e20:	b8 20 00 00 00       	mov    $0x20,%eax
  800e25:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e2e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e31:	d3 e2                	shl    %cl,%edx
  800e33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e36:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e39:	d3 e8                	shr    %cl,%eax
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e42:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e45:	d3 e0                	shl    %cl,%eax
  800e47:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e4a:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e4d:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e52:	d3 e0                	shl    %cl,%eax
  800e54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e57:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e5a:	d3 ea                	shr    %cl,%edx
  800e5c:	09 d0                	or     %edx,%eax
  800e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e61:	d3 ea                	shr    %cl,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e68:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6b:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e6e:	0f 82 8d 00 00 00    	jb     800f01 <__umoddi3+0x161>
  800e74:	0f 84 91 00 00 00    	je     800f0b <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e7a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e7d:	29 c7                	sub    %eax,%edi
  800e7f:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e81:	89 f2                	mov    %esi,%edx
  800e83:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e86:	d3 e2                	shl    %cl,%edx
  800e88:	89 f8                	mov    %edi,%eax
  800e8a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e8d:	d3 e8                	shr    %cl,%eax
  800e8f:	09 c2                	or     %eax,%edx
  800e91:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800e94:	d3 ee                	shr    %cl,%esi
  800e96:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800e99:	e9 62 ff ff ff       	jmp    800e00 <__umoddi3+0x60>
  800e9e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	74 15                	je     800ebc <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ea7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eaa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ead:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb2:	f7 f1                	div    %ecx
  800eb4:	e9 29 ff ff ff       	jmp    800de2 <__umoddi3+0x42>
  800eb9:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 75 ec             	divl   -0x14(%ebp)
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	eb dd                	jmp    800ea7 <__umoddi3+0x107>
  800eca:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ecf:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ed2:	72 19                	jb     800eed <__umoddi3+0x14d>
  800ed4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed7:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800eda:	76 11                	jbe    800eed <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800edc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800edf:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800ee2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ee5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ee8:	e9 13 ff ff ff       	jmp    800e00 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800eed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef3:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800ef6:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800efc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800eff:	eb db                	jmp    800edc <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f01:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f04:	19 f2                	sbb    %esi,%edx
  800f06:	e9 6f ff ff ff       	jmp    800e7a <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0b:	39 c7                	cmp    %eax,%edi
  800f0d:	72 f2                	jb     800f01 <__umoddi3+0x161>
  800f0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f12:	e9 63 ff ff ff       	jmp    800e7a <__umoddi3+0xda>
