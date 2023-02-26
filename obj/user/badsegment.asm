
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c9                   	leave  
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80004b:	e8 a7 02 00 00       	call   8002f7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800050:	25 ff 03 00 00       	and    $0x3ff,%eax
  800055:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	29 d0                	sub    %edx,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 f6                	test   %esi,%esi
  80006d:	7e 07                	jle    800076 <libmain+0x36>
		binaryname = argv[0];
  80006f:	8b 03                	mov    (%ebx),%eax
  800071:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
  800085:	83 c4 10             	add    $0x10,%esp
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 79 02 00 00       	call   800316 <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    
	...

008000a4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000af:	bf 00 00 00 00       	mov    $0x0,%edi
  8000b4:	89 fa                	mov    %edi,%edx
  8000b6:	89 f9                	mov    %edi,%ecx
  8000b8:	89 fb                	mov    %edi,%ebx
  8000ba:	89 fe                	mov    %edi,%esi
  8000bc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 04             	sub    $0x4,%esp
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8000d7:	89 f8                	mov    %edi,%eax
  8000d9:	89 fb                	mov    %edi,%ebx
  8000db:	89 fe                	mov    %edi,%esi
  8000dd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000df:	83 c4 04             	add    $0x4,%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8000f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8000fd:	89 f9                	mov    %edi,%ecx
  8000ff:	89 fb                	mov    %edi,%ebx
  800101:	89 fe                	mov    %edi,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 0d                	push   $0xd
  80010f:	68 2a 0f 80 00       	push   $0x800f2a
  800114:	6a 23                	push   $0x23
  800116:	68 47 0f 80 00       	push   $0x800f47
  80011b:	e8 38 02 00 00       	call   800358 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
  80012e:	8b 55 08             	mov    0x8(%ebp),%edx
  800131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800134:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800137:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80013f:	be 00 00 00 00       	mov    $0x0,%esi
  800144:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015f:	bf 00 00 00 00       	mov    $0x0,%edi
  800164:	89 fb                	mov    %edi,%ebx
  800166:	89 fe                	mov    %edi,%esi
  800168:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80016a:	85 c0                	test   %eax,%eax
  80016c:	7e 17                	jle    800185 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	50                   	push   %eax
  800172:	6a 0a                	push   $0xa
  800174:	68 2a 0f 80 00       	push   $0x800f2a
  800179:	6a 23                	push   $0x23
  80017b:	68 47 0f 80 00       	push   $0x800f47
  800180:	e8 d3 01 00 00       	call   800358 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019c:	b8 09 00 00 00       	mov    $0x9,%eax
  8001a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a6:	89 fb                	mov    %edi,%ebx
  8001a8:	89 fe                	mov    %edi,%esi
  8001aa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	7e 17                	jle    8001c7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	50                   	push   %eax
  8001b4:	6a 09                	push   $0x9
  8001b6:	68 2a 0f 80 00       	push   $0x800f2a
  8001bb:	6a 23                	push   $0x23
  8001bd:	68 47 0f 80 00       	push   $0x800f47
  8001c2:	e8 91 01 00 00       	call   800358 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ca:	5b                   	pop    %ebx
  8001cb:	5e                   	pop    %esi
  8001cc:	5f                   	pop    %edi
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 08 00 00 00       	mov    $0x8,%eax
  8001e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e8:	89 fb                	mov    %edi,%ebx
  8001ea:	89 fe                	mov    %edi,%esi
  8001ec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7e 17                	jle    800209 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	50                   	push   %eax
  8001f6:	6a 08                	push   $0x8
  8001f8:	68 2a 0f 80 00       	push   $0x800f2a
  8001fd:	6a 23                	push   $0x23
  8001ff:	68 47 0f 80 00       	push   $0x800f47
  800204:	e8 4f 01 00 00       	call   800358 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	bf 00 00 00 00       	mov    $0x0,%edi
  80022a:	89 fb                	mov    %edi,%ebx
  80022c:	89 fe                	mov    %edi,%esi
  80022e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7e 17                	jle    80024b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	50                   	push   %eax
  800238:	6a 06                	push   $0x6
  80023a:	68 2a 0f 80 00       	push   $0x800f2a
  80023f:	6a 23                	push   $0x23
  800241:	68 47 0f 80 00       	push   $0x800f47
  800246:	e8 0d 01 00 00       	call   800358 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
  80025f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800262:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800265:	8b 7d 14             	mov    0x14(%ebp),%edi
  800268:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026b:	b8 05 00 00 00       	mov    $0x5,%eax
  800270:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800272:	85 c0                	test   %eax,%eax
  800274:	7e 17                	jle    80028d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	50                   	push   %eax
  80027a:	6a 05                	push   $0x5
  80027c:	68 2a 0f 80 00       	push   $0x800f2a
  800281:	6a 23                	push   $0x23
  800283:	68 47 0f 80 00       	push   $0x800f47
  800288:	e8 cb 00 00 00       	call   800358 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8002ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b1:	89 fe                	mov    %edi,%esi
  8002b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b5:	85 c0                	test   %eax,%eax
  8002b7:	7e 17                	jle    8002d0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b9:	83 ec 0c             	sub    $0xc,%esp
  8002bc:	50                   	push   %eax
  8002bd:	6a 04                	push   $0x4
  8002bf:	68 2a 0f 80 00       	push   $0x800f2a
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 47 0f 80 00       	push   $0x800f47
  8002cb:	e8 88 00 00 00       	call   800358 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e8:	89 fa                	mov    %edi,%edx
  8002ea:	89 f9                	mov    %edi,%ecx
  8002ec:	89 fb                	mov    %edi,%ebx
  8002ee:	89 fe                	mov    %edi,%esi
  8002f0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	b8 02 00 00 00       	mov    $0x2,%eax
  800302:	bf 00 00 00 00       	mov    $0x0,%edi
  800307:	89 fa                	mov    %edi,%edx
  800309:	89 f9                	mov    %edi,%ecx
  80030b:	89 fb                	mov    %edi,%ebx
  80030d:	89 fe                	mov    %edi,%esi
  80030f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	b8 03 00 00 00       	mov    $0x3,%eax
  800327:	bf 00 00 00 00       	mov    $0x0,%edi
  80032c:	89 f9                	mov    %edi,%ecx
  80032e:	89 fb                	mov    %edi,%ebx
  800330:	89 fe                	mov    %edi,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 03                	push   $0x3
  80033e:	68 2a 0f 80 00       	push   $0x800f2a
  800343:	6a 23                	push   $0x23
  800345:	68 47 0f 80 00       	push   $0x800f47
  80034a:	e8 09 00 00 00       	call   800358 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	c9                   	leave  
  800356:	c3                   	ret    
	...

00800358 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80035f:	8d 45 14             	lea    0x14(%ebp),%eax
  800362:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800365:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80036b:	e8 87 ff ff ff       	call   8002f7 <sys_getenvid>
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	53                   	push   %ebx
  80037a:	50                   	push   %eax
  80037b:	68 58 0f 80 00       	push   $0x800f58
  800380:	e8 74 00 00 00       	call   8003f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	ff 75 f8             	pushl  -0x8(%ebp)
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	e8 15 00 00 00       	call   8003a8 <vcprintf>
	cprintf("\n");
  800393:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  80039a:	e8 5a 00 00 00       	call   8003f9 <cprintf>
  80039f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003a2:	cc                   	int3   
  8003a3:	eb fd                	jmp    8003a2 <_panic+0x4a>
  8003a5:	00 00                	add    %al,(%eax)
	...

008003a8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003b8:	00 00 00 
	b.cnt = 0;
  8003bb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c5:	ff 75 0c             	pushl  0xc(%ebp)
  8003c8:	ff 75 08             	pushl  0x8(%ebp)
  8003cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d1:	50                   	push   %eax
  8003d2:	68 10 04 80 00       	push   $0x800410
  8003d7:	e8 70 01 00 00       	call   80054c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003dc:	83 c4 08             	add    $0x8,%esp
  8003df:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003e5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003eb:	50                   	push   %eax
  8003ec:	e8 d2 fc ff ff       	call   8000c3 <sys_cputs>
  8003f1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003f7:	c9                   	leave  
  8003f8:	c3                   	ret    

008003f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ff:	8d 45 0c             	lea    0xc(%ebp),%eax
  800402:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800405:	50                   	push   %eax
  800406:	ff 75 08             	pushl  0x8(%ebp)
  800409:	e8 9a ff ff ff       	call   8003a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	53                   	push   %ebx
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80041a:	8b 03                	mov    (%ebx),%eax
  80041c:	8b 55 08             	mov    0x8(%ebp),%edx
  80041f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800423:	40                   	inc    %eax
  800424:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800426:	3d ff 00 00 00       	cmp    $0xff,%eax
  80042b:	75 1a                	jne    800447 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 ff 00 00 00       	push   $0xff
  800435:	8d 43 08             	lea    0x8(%ebx),%eax
  800438:	50                   	push   %eax
  800439:	e8 85 fc ff ff       	call   8000c3 <sys_cputs>
		b->idx = 0;
  80043e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800444:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800447:	ff 43 04             	incl   0x4(%ebx)
}
  80044a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    
	...

00800450 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 1c             	sub    $0x1c,%esp
  800459:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80045c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80045f:	8b 45 08             	mov    0x8(%ebp),%eax
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80046b:	8b 55 10             	mov    0x10(%ebp),%edx
  80046e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800471:	89 d6                	mov    %edx,%esi
  800473:	bf 00 00 00 00       	mov    $0x0,%edi
  800478:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80047b:	72 04                	jb     800481 <printnum+0x31>
  80047d:	39 c2                	cmp    %eax,%edx
  80047f:	77 3f                	ja     8004c0 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800481:	83 ec 0c             	sub    $0xc,%esp
  800484:	ff 75 18             	pushl  0x18(%ebp)
  800487:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80048a:	50                   	push   %eax
  80048b:	52                   	push   %edx
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	57                   	push   %edi
  800490:	56                   	push   %esi
  800491:	ff 75 e4             	pushl  -0x1c(%ebp)
  800494:	ff 75 e0             	pushl  -0x20(%ebp)
  800497:	e8 d4 07 00 00       	call   800c70 <__udivdi3>
  80049c:	83 c4 18             	add    $0x18,%esp
  80049f:	52                   	push   %edx
  8004a0:	50                   	push   %eax
  8004a1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004a7:	e8 a4 ff ff ff       	call   800450 <printnum>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	eb 14                	jmp    8004c5 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 e8             	pushl  -0x18(%ebp)
  8004b7:	ff 75 18             	pushl  0x18(%ebp)
  8004ba:	ff 55 ec             	call   *-0x14(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c0:	4b                   	dec    %ebx
  8004c1:	85 db                	test   %ebx,%ebx
  8004c3:	7f ec                	jg     8004b1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	ff 75 e8             	pushl  -0x18(%ebp)
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	57                   	push   %edi
  8004cf:	56                   	push   %esi
  8004d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d6:	e8 c1 08 00 00       	call   800d9c <__umoddi3>
  8004db:	83 c4 14             	add    $0x14,%esp
  8004de:	0f be 80 7d 0f 80 00 	movsbl 0x800f7d(%eax),%eax
  8004e5:	50                   	push   %eax
  8004e6:	ff 55 ec             	call   *-0x14(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
}
  8004ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ef:	5b                   	pop    %ebx
  8004f0:	5e                   	pop    %esi
  8004f1:	5f                   	pop    %edi
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004f9:	83 fa 01             	cmp    $0x1,%edx
  8004fc:	7e 0e                	jle    80050c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 42 08             	lea    0x8(%edx),%eax
  800503:	89 01                	mov    %eax,(%ecx)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	8b 52 04             	mov    0x4(%edx),%edx
  80050a:	eb 22                	jmp    80052e <getuint+0x3a>
	else if (lflag)
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 10                	je     800520 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 42 04             	lea    0x4(%edx),%eax
  800515:	89 01                	mov    %eax,(%ecx)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
  80051e:	eb 0e                	jmp    80052e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 42 04             	lea    0x4(%edx),%eax
  800525:	89 01                	mov    %eax,(%ecx)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800536:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800539:	8b 11                	mov    (%ecx),%edx
  80053b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80053e:	73 0a                	jae    80054a <sprintputch+0x1a>
		*b->buf++ = ch;
  800540:	8b 45 08             	mov    0x8(%ebp),%eax
  800543:	88 02                	mov    %al,(%edx)
  800545:	8d 42 01             	lea    0x1(%edx),%eax
  800548:	89 01                	mov    %eax,(%ecx)
}
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	57                   	push   %edi
  800550:	56                   	push   %esi
  800551:	53                   	push   %ebx
  800552:	83 ec 3c             	sub    $0x3c,%esp
  800555:	8b 75 08             	mov    0x8(%ebp),%esi
  800558:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80055b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80055e:	eb 1a                	jmp    80057a <vprintfmt+0x2e>
  800560:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800563:	eb 15                	jmp    80057a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800565:	84 c0                	test   %al,%al
  800567:	0f 84 15 03 00 00    	je     800882 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	57                   	push   %edi
  800571:	0f b6 c0             	movzbl %al,%eax
  800574:	50                   	push   %eax
  800575:	ff d6                	call   *%esi
  800577:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80057a:	8a 03                	mov    (%ebx),%al
  80057c:	43                   	inc    %ebx
  80057d:	3c 25                	cmp    $0x25,%al
  80057f:	75 e4                	jne    800565 <vprintfmt+0x19>
  800581:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800588:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80058f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800596:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80059d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005a1:	eb 0a                	jmp    8005ad <vprintfmt+0x61>
  8005a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005aa:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8a 03                	mov    (%ebx),%al
  8005af:	0f b6 d0             	movzbl %al,%edx
  8005b2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005b5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005b8:	83 e8 23             	sub    $0x23,%eax
  8005bb:	3c 55                	cmp    $0x55,%al
  8005bd:	0f 87 9c 02 00 00    	ja     80085f <vprintfmt+0x313>
  8005c3:	0f b6 c0             	movzbl %al,%eax
  8005c6:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005cd:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005d1:	eb d7                	jmp    8005aa <vprintfmt+0x5e>
  8005d3:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005d7:	eb d1                	jmp    8005aa <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005d9:	89 d9                	mov    %ebx,%ecx
  8005db:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005e2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e5:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005e8:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005ef:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005f3:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005f4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005f7:	83 f8 09             	cmp    $0x9,%eax
  8005fa:	77 21                	ja     80061d <vprintfmt+0xd1>
  8005fc:	eb e4                	jmp    8005e2 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fe:	8b 55 14             	mov    0x14(%ebp),%edx
  800601:	8d 42 04             	lea    0x4(%edx),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
  800607:	8b 12                	mov    (%edx),%edx
  800609:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060c:	eb 12                	jmp    800620 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80060e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800612:	79 96                	jns    8005aa <vprintfmt+0x5e>
  800614:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80061b:	eb 8d                	jmp    8005aa <vprintfmt+0x5e>
  80061d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800620:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800624:	79 84                	jns    8005aa <vprintfmt+0x5e>
  800626:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800633:	e9 72 ff ff ff       	jmp    8005aa <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800638:	ff 45 d4             	incl   -0x2c(%ebp)
  80063b:	e9 6a ff ff ff       	jmp    8005aa <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800640:	8b 55 14             	mov    0x14(%ebp),%edx
  800643:	8d 42 04             	lea    0x4(%edx),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	ff 32                	pushl  (%edx)
  80064f:	ff d6                	call   *%esi
			break;
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	e9 07 ff ff ff       	jmp    800560 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800659:	8b 55 14             	mov    0x14(%ebp),%edx
  80065c:	8d 42 04             	lea    0x4(%edx),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	8b 02                	mov    (%edx),%eax
  800664:	85 c0                	test   %eax,%eax
  800666:	79 02                	jns    80066a <vprintfmt+0x11e>
  800668:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066a:	83 f8 0f             	cmp    $0xf,%eax
  80066d:	7f 0b                	jg     80067a <vprintfmt+0x12e>
  80066f:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800676:	85 d2                	test   %edx,%edx
  800678:	75 15                	jne    80068f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80067a:	50                   	push   %eax
  80067b:	68 8e 0f 80 00       	push   $0x800f8e
  800680:	57                   	push   %edi
  800681:	56                   	push   %esi
  800682:	e8 6e 02 00 00       	call   8008f5 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	e9 d1 fe ff ff       	jmp    800560 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80068f:	52                   	push   %edx
  800690:	68 97 0f 80 00       	push   $0x800f97
  800695:	57                   	push   %edi
  800696:	56                   	push   %esi
  800697:	e8 59 02 00 00       	call   8008f5 <printfmt>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	e9 bc fe ff ff       	jmp    800560 <vprintfmt+0x14>
  8006a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ad:	8b 55 14             	mov    0x14(%ebp),%edx
  8006b0:	8d 42 04             	lea    0x4(%edx),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b6:	8b 1a                	mov    (%edx),%ebx
  8006b8:	85 db                	test   %ebx,%ebx
  8006ba:	75 05                	jne    8006c1 <vprintfmt+0x175>
  8006bc:	bb 9a 0f 80 00       	mov    $0x800f9a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006c5:	7e 66                	jle    80072d <vprintfmt+0x1e1>
  8006c7:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006cb:	74 60                	je     80072d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	51                   	push   %ecx
  8006d1:	53                   	push   %ebx
  8006d2:	e8 57 02 00 00       	call   80092e <strnlen>
  8006d7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006da:	29 c1                	sub    %eax,%ecx
  8006dc:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006e9:	eb 0f                	jmp    8006fa <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	ff 4d d8             	decl   -0x28(%ebp)
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fe:	7f eb                	jg     8006eb <vprintfmt+0x19f>
  800700:	eb 2b                	jmp    80072d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800705:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800709:	74 15                	je     800720 <vprintfmt+0x1d4>
  80070b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80070e:	83 f8 5e             	cmp    $0x5e,%eax
  800711:	76 0d                	jbe    800720 <vprintfmt+0x1d4>
					putch('?', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	57                   	push   %edi
  800717:	6a 3f                	push   $0x3f
  800719:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 0a                	jmp    80072a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	57                   	push   %edi
  800724:	52                   	push   %edx
  800725:	ff d6                	call   *%esi
  800727:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072a:	ff 4d d8             	decl   -0x28(%ebp)
  80072d:	8a 03                	mov    (%ebx),%al
  80072f:	43                   	inc    %ebx
  800730:	84 c0                	test   %al,%al
  800732:	74 1b                	je     80074f <vprintfmt+0x203>
  800734:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800738:	78 c8                	js     800702 <vprintfmt+0x1b6>
  80073a:	ff 4d dc             	decl   -0x24(%ebp)
  80073d:	79 c3                	jns    800702 <vprintfmt+0x1b6>
  80073f:	eb 0e                	jmp    80074f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	57                   	push   %edi
  800745:	6a 20                	push   $0x20
  800747:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800749:	ff 4d d8             	decl   -0x28(%ebp)
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800753:	7f ec                	jg     800741 <vprintfmt+0x1f5>
  800755:	e9 06 fe ff ff       	jmp    800560 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80075e:	7e 10                	jle    800770 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800760:	8b 55 14             	mov    0x14(%ebp),%edx
  800763:	8d 42 08             	lea    0x8(%edx),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
  800769:	8b 02                	mov    (%edx),%eax
  80076b:	8b 52 04             	mov    0x4(%edx),%edx
  80076e:	eb 20                	jmp    800790 <vprintfmt+0x244>
	else if (lflag)
  800770:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800774:	74 0e                	je     800784 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8d 50 04             	lea    0x4(%eax),%edx
  80077c:	89 55 14             	mov    %edx,0x14(%ebp)
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	99                   	cltd   
  800782:	eb 0c                	jmp    800790 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8d 50 04             	lea    0x4(%eax),%edx
  80078a:	89 55 14             	mov    %edx,0x14(%ebp)
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800790:	89 d1                	mov    %edx,%ecx
  800792:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800794:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800797:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80079a:	85 c9                	test   %ecx,%ecx
  80079c:	78 0a                	js     8007a8 <vprintfmt+0x25c>
  80079e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007a3:	e9 89 00 00 00       	jmp    800831 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	57                   	push   %edi
  8007ac:	6a 2d                	push   $0x2d
  8007ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007b3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007b6:	f7 da                	neg    %edx
  8007b8:	83 d1 00             	adc    $0x0,%ecx
  8007bb:	f7 d9                	neg    %ecx
  8007bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	eb 6a                	jmp    800831 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007cd:	e8 22 fd ff ff       	call   8004f4 <getuint>
  8007d2:	89 d1                	mov    %edx,%ecx
  8007d4:	89 c2                	mov    %eax,%edx
  8007d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007db:	eb 54                	jmp    800831 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e3:	e8 0c fd ff ff       	call   8004f4 <getuint>
  8007e8:	89 d1                	mov    %edx,%ecx
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007f1:	eb 3e                	jmp    800831 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	57                   	push   %edi
  8007f7:	6a 30                	push   $0x30
  8007f9:	ff d6                	call   *%esi
			putch('x', putdat);
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	57                   	push   %edi
  8007ff:	6a 78                	push   $0x78
  800801:	ff d6                	call   *%esi
			num = (unsigned long long)
  800803:	8b 55 14             	mov    0x14(%ebp),%edx
  800806:	8d 42 04             	lea    0x4(%edx),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
  80080c:	8b 12                	mov    (%edx),%edx
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800813:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	eb 14                	jmp    800831 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800823:	e8 cc fc ff ff       	call   8004f4 <getuint>
  800828:	89 d1                	mov    %edx,%ecx
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800831:	83 ec 0c             	sub    $0xc,%esp
  800834:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	ff 75 d8             	pushl  -0x28(%ebp)
  80083c:	53                   	push   %ebx
  80083d:	51                   	push   %ecx
  80083e:	52                   	push   %edx
  80083f:	89 fa                	mov    %edi,%edx
  800841:	89 f0                	mov    %esi,%eax
  800843:	e8 08 fc ff ff       	call   800450 <printnum>
			break;
  800848:	83 c4 20             	add    $0x20,%esp
  80084b:	e9 10 fd ff ff       	jmp    800560 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	57                   	push   %edi
  800854:	52                   	push   %edx
  800855:	ff d6                	call   *%esi
			break;
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	e9 01 fd ff ff       	jmp    800560 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	57                   	push   %edi
  800863:	6a 25                	push   $0x25
  800865:	ff d6                	call   *%esi
  800867:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80086a:	83 ea 02             	sub    $0x2,%edx
  80086d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800870:	8a 02                	mov    (%edx),%al
  800872:	4a                   	dec    %edx
  800873:	3c 25                	cmp    $0x25,%al
  800875:	75 f9                	jne    800870 <vprintfmt+0x324>
  800877:	83 c2 02             	add    $0x2,%edx
  80087a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80087d:	e9 de fc ff ff       	jmp    800560 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800882:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 18             	sub    $0x18,%esp
  800890:	8b 55 08             	mov    0x8(%ebp),%edx
  800893:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800896:	85 d2                	test   %edx,%edx
  800898:	74 37                	je     8008d1 <vsnprintf+0x47>
  80089a:	85 c0                	test   %eax,%eax
  80089c:	7e 33                	jle    8008d1 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008ac:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008af:	ff 75 14             	pushl  0x14(%ebp)
  8008b2:	ff 75 10             	pushl  0x10(%ebp)
  8008b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b8:	50                   	push   %eax
  8008b9:	68 30 05 80 00       	push   $0x800530
  8008be:	e8 89 fc ff ff       	call   80054c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	eb 05                	jmp    8008d6 <vsnprintf+0x4c>
  8008d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 97 ff ff ff       	call   80088a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800901:	50                   	push   %eax
  800902:	ff 75 10             	pushl  0x10(%ebp)
  800905:	ff 75 0c             	pushl  0xc(%ebp)
  800908:	ff 75 08             	pushl  0x8(%ebp)
  80090b:	e8 3c fc ff ff       	call   80054c <vprintfmt>
	va_end(ap);
  800910:	83 c4 10             	add    $0x10,%esp
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    
  800915:	00 00                	add    %al,(%eax)
	...

00800918 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 55 08             	mov    0x8(%ebp),%edx
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	eb 01                	jmp    800926 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800925:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80092a:	75 f9                	jne    800925 <strlen+0xd>
		n++;
	return n;
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
  80093c:	eb 01                	jmp    80093f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80093e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093f:	39 d0                	cmp    %edx,%eax
  800941:	74 06                	je     800949 <strnlen+0x1b>
  800943:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800947:	75 f5                	jne    80093e <strnlen+0x10>
		n++;
	return n;
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800951:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	8a 01                	mov    (%ecx),%al
  800956:	88 02                	mov    %al,(%edx)
  800958:	42                   	inc    %edx
  800959:	41                   	inc    %ecx
  80095a:	84 c0                	test   %al,%al
  80095c:	75 f6                	jne    800954 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096a:	53                   	push   %ebx
  80096b:	e8 a8 ff ff ff       	call   800918 <strlen>
	strcpy(dst + len, src);
  800970:	ff 75 0c             	pushl  0xc(%ebp)
  800973:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800976:	50                   	push   %eax
  800977:	e8 cf ff ff ff       	call   80094b <strcpy>
	return dst;
}
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 75 08             	mov    0x8(%ebp),%esi
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800991:	b9 00 00 00 00       	mov    $0x0,%ecx
  800996:	eb 0c                	jmp    8009a4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800998:	8a 02                	mov    (%edx),%al
  80099a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	41                   	inc    %ecx
  8009a4:	39 d9                	cmp    %ebx,%ecx
  8009a6:	75 f0                	jne    800998 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a8:	89 f0                	mov    %esi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	75 04                	jne    8009c4 <strlcpy+0x16>
  8009c0:	89 f0                	mov    %esi,%eax
  8009c2:	eb 14                	jmp    8009d8 <strlcpy+0x2a>
  8009c4:	89 f0                	mov    %esi,%eax
  8009c6:	eb 04                	jmp    8009cc <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c8:	88 10                	mov    %dl,(%eax)
  8009ca:	40                   	inc    %eax
  8009cb:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009cc:	49                   	dec    %ecx
  8009cd:	74 06                	je     8009d5 <strlcpy+0x27>
  8009cf:	8a 13                	mov    (%ebx),%dl
  8009d1:	84 d2                	test   %dl,%dl
  8009d3:	75 f3                	jne    8009c8 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009d5:	c6 00 00             	movb   $0x0,(%eax)
  8009d8:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e7:	eb 02                	jmp    8009eb <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009e9:	42                   	inc    %edx
  8009ea:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009eb:	8a 02                	mov    (%edx),%al
  8009ed:	84 c0                	test   %al,%al
  8009ef:	74 04                	je     8009f5 <strcmp+0x17>
  8009f1:	3a 01                	cmp    (%ecx),%al
  8009f3:	74 f4                	je     8009e9 <strcmp+0xb>
  8009f5:	0f b6 c0             	movzbl %al,%eax
  8009f8:	0f b6 11             	movzbl (%ecx),%edx
  8009fb:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a09:	8b 55 10             	mov    0x10(%ebp),%edx
  800a0c:	eb 03                	jmp    800a11 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a0e:	4a                   	dec    %edx
  800a0f:	41                   	inc    %ecx
  800a10:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a11:	85 d2                	test   %edx,%edx
  800a13:	75 07                	jne    800a1c <strncmp+0x1d>
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 14                	jmp    800a30 <strncmp+0x31>
  800a1c:	8a 01                	mov    (%ecx),%al
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 04                	je     800a26 <strncmp+0x27>
  800a22:	3a 03                	cmp    (%ebx),%al
  800a24:	74 e8                	je     800a0e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a26:	0f b6 d0             	movzbl %al,%edx
  800a29:	0f b6 03             	movzbl (%ebx),%eax
  800a2c:	29 c2                	sub    %eax,%edx
  800a2e:	89 d0                	mov    %edx,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a3c:	eb 05                	jmp    800a43 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 0c                	je     800a4e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	40                   	inc    %eax
  800a43:	8a 10                	mov    (%eax),%dl
  800a45:	84 d2                	test   %dl,%dl
  800a47:	75 f5                	jne    800a3e <strchr+0xb>
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a59:	eb 05                	jmp    800a60 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a5b:	38 ca                	cmp    %cl,%dl
  800a5d:	74 07                	je     800a66 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5f:	40                   	inc    %eax
  800a60:	8a 10                	mov    (%eax),%dl
  800a62:	84 d2                	test   %dl,%dl
  800a64:	75 f5                	jne    800a5b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a77:	85 db                	test   %ebx,%ebx
  800a79:	74 36                	je     800ab1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a81:	75 29                	jne    800aac <memset+0x44>
  800a83:	f6 c3 03             	test   $0x3,%bl
  800a86:	75 24                	jne    800aac <memset+0x44>
		c &= 0xFF;
  800a88:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a8b:	89 d6                	mov    %edx,%esi
  800a8d:	c1 e6 08             	shl    $0x8,%esi
  800a90:	89 d0                	mov    %edx,%eax
  800a92:	c1 e0 18             	shl    $0x18,%eax
  800a95:	89 d1                	mov    %edx,%ecx
  800a97:	c1 e1 10             	shl    $0x10,%ecx
  800a9a:	09 c8                	or     %ecx,%eax
  800a9c:	09 c2                	or     %eax,%edx
  800a9e:	89 f0                	mov    %esi,%eax
  800aa0:	09 d0                	or     %edx,%eax
  800aa2:	89 d9                	mov    %ebx,%ecx
  800aa4:	c1 e9 02             	shr    $0x2,%ecx
  800aa7:	fc                   	cld    
  800aa8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aaa:	eb 05                	jmp    800ab1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aac:	89 d9                	mov    %ebx,%ecx
  800aae:	fc                   	cld    
  800aaf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab1:	89 f8                	mov    %edi,%eax
  800ab3:	5b                   	pop    %ebx
  800ab4:	5e                   	pop    %esi
  800ab5:	5f                   	pop    %edi
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ac6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ac8:	39 c6                	cmp    %eax,%esi
  800aca:	73 36                	jae    800b02 <memmove+0x4a>
  800acc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800acf:	39 d0                	cmp    %edx,%eax
  800ad1:	73 2f                	jae    800b02 <memmove+0x4a>
		s += n;
		d += n;
  800ad3:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f6 c2 03             	test   $0x3,%dl
  800ad9:	75 1b                	jne    800af6 <memmove+0x3e>
  800adb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae1:	75 13                	jne    800af6 <memmove+0x3e>
  800ae3:	f6 c1 03             	test   $0x3,%cl
  800ae6:	75 0e                	jne    800af6 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800ae8:	8d 7e fc             	lea    -0x4(%esi),%edi
  800aeb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aee:	c1 e9 02             	shr    $0x2,%ecx
  800af1:	fd                   	std    
  800af2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af4:	eb 09                	jmp    800aff <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af6:	8d 7e ff             	lea    -0x1(%esi),%edi
  800af9:	8d 72 ff             	lea    -0x1(%edx),%esi
  800afc:	fd                   	std    
  800afd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aff:	fc                   	cld    
  800b00:	eb 20                	jmp    800b22 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b08:	75 15                	jne    800b1f <memmove+0x67>
  800b0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b10:	75 0d                	jne    800b1f <memmove+0x67>
  800b12:	f6 c1 03             	test   $0x3,%cl
  800b15:	75 08                	jne    800b1f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b17:	c1 e9 02             	shr    $0x2,%ecx
  800b1a:	fc                   	cld    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 03                	jmp    800b22 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1f:	fc                   	cld    
  800b20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b29:	ff 75 10             	pushl  0x10(%ebp)
  800b2c:	ff 75 0c             	pushl  0xc(%ebp)
  800b2f:	ff 75 08             	pushl  0x8(%ebp)
  800b32:	e8 81 ff ff ff       	call   800ab8 <memmove>
}
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 04             	sub    $0x4,%esp
  800b40:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	eb 1b                	jmp    800b66 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b4b:	8a 1a                	mov    (%edx),%bl
  800b4d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b50:	8a 19                	mov    (%ecx),%bl
  800b52:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b55:	74 0d                	je     800b64 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b57:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b5b:	0f b6 c3             	movzbl %bl,%eax
  800b5e:	29 c2                	sub    %eax,%edx
  800b60:	89 d0                	mov    %edx,%eax
  800b62:	eb 0d                	jmp    800b71 <memcmp+0x38>
		s1++, s2++;
  800b64:	42                   	inc    %edx
  800b65:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b66:	48                   	dec    %eax
  800b67:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b6a:	75 df                	jne    800b4b <memcmp+0x12>
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b71:	83 c4 04             	add    $0x4,%esp
  800b74:	5b                   	pop    %ebx
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	03 55 10             	add    0x10(%ebp),%edx
  800b85:	eb 05                	jmp    800b8c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b87:	38 08                	cmp    %cl,(%eax)
  800b89:	74 05                	je     800b90 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8b:	40                   	inc    %eax
  800b8c:	39 d0                	cmp    %edx,%eax
  800b8e:	72 f7                	jb     800b87 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 04             	sub    $0x4,%esp
  800b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9e:	8b 75 10             	mov    0x10(%ebp),%esi
  800ba1:	eb 01                	jmp    800ba4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800ba3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba4:	8a 01                	mov    (%ecx),%al
  800ba6:	3c 20                	cmp    $0x20,%al
  800ba8:	74 f9                	je     800ba3 <strtol+0x11>
  800baa:	3c 09                	cmp    $0x9,%al
  800bac:	74 f5                	je     800ba3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bae:	3c 2b                	cmp    $0x2b,%al
  800bb0:	75 0a                	jne    800bbc <strtol+0x2a>
		s++;
  800bb2:	41                   	inc    %ecx
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bba:	eb 17                	jmp    800bd3 <strtol+0x41>
	else if (*s == '-')
  800bbc:	3c 2d                	cmp    $0x2d,%al
  800bbe:	74 09                	je     800bc9 <strtol+0x37>
  800bc0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bc7:	eb 0a                	jmp    800bd3 <strtol+0x41>
		s++, neg = 1;
  800bc9:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bcc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd3:	85 f6                	test   %esi,%esi
  800bd5:	74 05                	je     800bdc <strtol+0x4a>
  800bd7:	83 fe 10             	cmp    $0x10,%esi
  800bda:	75 1a                	jne    800bf6 <strtol+0x64>
  800bdc:	8a 01                	mov    (%ecx),%al
  800bde:	3c 30                	cmp    $0x30,%al
  800be0:	75 10                	jne    800bf2 <strtol+0x60>
  800be2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800be6:	75 0a                	jne    800bf2 <strtol+0x60>
		s += 2, base = 16;
  800be8:	83 c1 02             	add    $0x2,%ecx
  800beb:	be 10 00 00 00       	mov    $0x10,%esi
  800bf0:	eb 04                	jmp    800bf6 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bf2:	85 f6                	test   %esi,%esi
  800bf4:	74 07                	je     800bfd <strtol+0x6b>
  800bf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfb:	eb 13                	jmp    800c10 <strtol+0x7e>
  800bfd:	3c 30                	cmp    $0x30,%al
  800bff:	74 07                	je     800c08 <strtol+0x76>
  800c01:	be 0a 00 00 00       	mov    $0xa,%esi
  800c06:	eb ee                	jmp    800bf6 <strtol+0x64>
		s++, base = 8;
  800c08:	41                   	inc    %ecx
  800c09:	be 08 00 00 00       	mov    $0x8,%esi
  800c0e:	eb e6                	jmp    800bf6 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c10:	8a 11                	mov    (%ecx),%dl
  800c12:	88 d3                	mov    %dl,%bl
  800c14:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c17:	3c 09                	cmp    $0x9,%al
  800c19:	77 08                	ja     800c23 <strtol+0x91>
			dig = *s - '0';
  800c1b:	0f be c2             	movsbl %dl,%eax
  800c1e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c21:	eb 1c                	jmp    800c3f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c23:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c26:	3c 19                	cmp    $0x19,%al
  800c28:	77 08                	ja     800c32 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c2a:	0f be c2             	movsbl %dl,%eax
  800c2d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c30:	eb 0d                	jmp    800c3f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c32:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c35:	3c 19                	cmp    $0x19,%al
  800c37:	77 15                	ja     800c4e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c39:	0f be c2             	movsbl %dl,%eax
  800c3c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c3f:	39 f2                	cmp    %esi,%edx
  800c41:	7d 0b                	jge    800c4e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c43:	41                   	inc    %ecx
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	0f af c6             	imul   %esi,%eax
  800c49:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c4c:	eb c2                	jmp    800c10 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c4e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c54:	74 05                	je     800c5b <strtol+0xc9>
		*endptr = (char *) s;
  800c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c59:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5f:	74 04                	je     800c65 <strtol+0xd3>
  800c61:	89 c7                	mov    %eax,%edi
  800c63:	f7 df                	neg    %edi
}
  800c65:	89 f8                	mov    %edi,%eax
  800c67:	83 c4 04             	add    $0x4,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    
	...

00800c70 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	83 ec 28             	sub    $0x28,%esp
  800c78:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c7f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c86:	8b 45 10             	mov    0x10(%ebp),%eax
  800c89:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c8f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800c91:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800c99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c9f:	85 ff                	test   %edi,%edi
  800ca1:	75 21                	jne    800cc4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800ca3:	39 d1                	cmp    %edx,%ecx
  800ca5:	76 49                	jbe    800cf0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca7:	f7 f1                	div    %ecx
  800ca9:	89 c1                	mov    %eax,%ecx
  800cab:	31 c0                	xor    %eax,%eax
  800cad:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cb9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cbc:	83 c4 28             	add    $0x28,%esp
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    
  800cc3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cc4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cc7:	0f 87 97 00 00 00    	ja     800d64 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ccd:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cd0:	83 f0 1f             	xor    $0x1f,%eax
  800cd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cd6:	75 34                	jne    800d0c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cd8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cdb:	72 08                	jb     800ce5 <__udivdi3+0x75>
  800cdd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ce0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ce3:	77 7f                	ja     800d64 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ce5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cea:	31 c0                	xor    %eax,%eax
  800cec:	eb c2                	jmp    800cb0 <__udivdi3+0x40>
  800cee:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	74 79                	je     800d70 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cfa:	89 fa                	mov    %edi,%edx
  800cfc:	f7 f1                	div    %ecx
  800cfe:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d03:	f7 f1                	div    %ecx
  800d05:	89 c1                	mov    %eax,%ecx
  800d07:	89 f0                	mov    %esi,%eax
  800d09:	eb a5                	jmp    800cb0 <__udivdi3+0x40>
  800d0b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d11:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d17:	89 fa                	mov    %edi,%edx
  800d19:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d1c:	d3 e2                	shl    %cl,%edx
  800d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d21:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d24:	d3 e8                	shr    %cl,%eax
  800d26:	89 d7                	mov    %edx,%edi
  800d28:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d2a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d2d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d30:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d32:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d35:	d3 e0                	shl    %cl,%eax
  800d37:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d3a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d3d:	d3 ea                	shr    %cl,%edx
  800d3f:	09 d0                	or     %edx,%eax
  800d41:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d44:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d47:	d3 ea                	shr    %cl,%edx
  800d49:	f7 f7                	div    %edi
  800d4b:	89 d7                	mov    %edx,%edi
  800d4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d50:	f7 e6                	mul    %esi
  800d52:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d54:	39 d7                	cmp    %edx,%edi
  800d56:	72 38                	jb     800d90 <__udivdi3+0x120>
  800d58:	74 27                	je     800d81 <__udivdi3+0x111>
  800d5a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d5d:	31 c0                	xor    %eax,%eax
  800d5f:	e9 4c ff ff ff       	jmp    800cb0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d64:	31 c9                	xor    %ecx,%ecx
  800d66:	31 c0                	xor    %eax,%eax
  800d68:	e9 43 ff ff ff       	jmp    800cb0 <__udivdi3+0x40>
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d70:	b8 01 00 00 00       	mov    $0x1,%eax
  800d75:	31 d2                	xor    %edx,%edx
  800d77:	f7 75 f4             	divl   -0xc(%ebp)
  800d7a:	89 c1                	mov    %eax,%ecx
  800d7c:	e9 76 ff ff ff       	jmp    800cf7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d84:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d87:	d3 e0                	shl    %cl,%eax
  800d89:	39 f0                	cmp    %esi,%eax
  800d8b:	73 cd                	jae    800d5a <__udivdi3+0xea>
  800d8d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d90:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d93:	49                   	dec    %ecx
  800d94:	31 c0                	xor    %eax,%eax
  800d96:	e9 15 ff ff ff       	jmp    800cb0 <__udivdi3+0x40>
	...

00800d9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	83 ec 30             	sub    $0x30,%esp
  800da4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800db2:	8b 75 08             	mov    0x8(%ebp),%esi
  800db5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dc1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dc3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dc6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dc9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dcc:	85 d2                	test   %edx,%edx
  800dce:	75 1c                	jne    800dec <__umoddi3+0x50>
    {
      if (d0 > n1)
  800dd0:	89 fa                	mov    %edi,%edx
  800dd2:	39 f8                	cmp    %edi,%eax
  800dd4:	0f 86 c2 00 00 00    	jbe    800e9c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dde:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800de1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800de8:	eb 12                	jmp    800dfc <__umoddi3+0x60>
  800dea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800def:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800df2:	76 18                	jbe    800e0c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800df7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800dfa:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dfc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800dff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e02:	83 c4 30             	add    $0x30,%esp
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    
  800e09:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e0c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e10:	83 f0 1f             	xor    $0x1f,%eax
  800e13:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e16:	0f 84 ac 00 00 00    	je     800ec8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e21:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e27:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e2a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e2d:	d3 e2                	shl    %cl,%edx
  800e2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e32:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e35:	d3 e8                	shr    %cl,%eax
  800e37:	89 d6                	mov    %edx,%esi
  800e39:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e3e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e41:	d3 e0                	shl    %cl,%eax
  800e43:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e46:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e49:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4e:	d3 e0                	shl    %cl,%eax
  800e50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e53:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e56:	d3 ea                	shr    %cl,%edx
  800e58:	09 d0                	or     %edx,%eax
  800e5a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e5d:	d3 ea                	shr    %cl,%edx
  800e5f:	f7 f6                	div    %esi
  800e61:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e64:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e67:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e6a:	0f 82 8d 00 00 00    	jb     800efd <__umoddi3+0x161>
  800e70:	0f 84 91 00 00 00    	je     800f07 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e76:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e79:	29 c7                	sub    %eax,%edi
  800e7b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e7d:	89 f2                	mov    %esi,%edx
  800e7f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e82:	d3 e2                	shl    %cl,%edx
  800e84:	89 f8                	mov    %edi,%eax
  800e86:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e89:	d3 e8                	shr    %cl,%eax
  800e8b:	09 c2                	or     %eax,%edx
  800e8d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800e90:	d3 ee                	shr    %cl,%esi
  800e92:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800e95:	e9 62 ff ff ff       	jmp    800dfc <__umoddi3+0x60>
  800e9a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	74 15                	je     800eb8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ea9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eae:	f7 f1                	div    %ecx
  800eb0:	e9 29 ff ff ff       	jmp    800dde <__umoddi3+0x42>
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	f7 75 ec             	divl   -0x14(%ebp)
  800ec2:	89 c1                	mov    %eax,%ecx
  800ec4:	eb dd                	jmp    800ea3 <__umoddi3+0x107>
  800ec6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ecb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ece:	72 19                	jb     800ee9 <__umoddi3+0x14d>
  800ed0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ed6:	76 11                	jbe    800ee9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800edb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800ede:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ee1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ee4:	e9 13 ff ff ff       	jmp    800dfc <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eef:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800ef2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ef8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800efb:	eb db                	jmp    800ed8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800efd:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f00:	19 f2                	sbb    %esi,%edx
  800f02:	e9 6f ff ff ff       	jmp    800e76 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f07:	39 c7                	cmp    %eax,%edi
  800f09:	72 f2                	jb     800efd <__umoddi3+0x161>
  800f0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0e:	e9 63 ff ff ff       	jmp    800e76 <__umoddi3+0xda>
