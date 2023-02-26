
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c9                   	leave  
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	8b 75 08             	mov    0x8(%ebp),%esi
  800044:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800047:	e8 a7 02 00 00       	call   8002f3 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	29 d0                	sub    %edx,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 f6                	test   %esi,%esi
  800069:	7e 07                	jle    800072 <libmain+0x36>
		binaryname = argv[0];
  80006b:	8b 03                	mov    (%ebx),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
  800081:	83 c4 10             	add    $0x10,%esp
}
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	c9                   	leave  
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 79 02 00 00       	call   800312 <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    
	...

008000a0 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8000b0:	89 fa                	mov    %edi,%edx
  8000b2:	89 f9                	mov    %edi,%ecx
  8000b4:	89 fb                	mov    %edi,%ebx
  8000b6:	89 fe                	mov    %edi,%esi
  8000b8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 04             	sub    $0x4,%esp
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8000d3:	89 f8                	mov    %edi,%eax
  8000d5:	89 fb                	mov    %edi,%ebx
  8000d7:	89 fe                	mov    %edi,%esi
  8000d9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	83 c4 04             	add    $0x4,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8000f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8000f9:	89 f9                	mov    %edi,%ecx
  8000fb:	89 fb                	mov    %edi,%ebx
  8000fd:	89 fe                	mov    %edi,%esi
  8000ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 0d                	push   $0xd
  80010b:	68 2a 0f 80 00       	push   $0x800f2a
  800110:	6a 23                	push   $0x23
  800112:	68 47 0f 80 00       	push   $0x800f47
  800117:	e8 38 02 00 00       	call   800354 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	8b 55 08             	mov    0x8(%ebp),%edx
  80012d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800130:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800133:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800136:	b8 0c 00 00 00       	mov    $0xc,%eax
  80013b:	be 00 00 00 00       	mov    $0x0,%esi
  800140:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	8b 55 08             	mov    0x8(%ebp),%edx
  800153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015b:	bf 00 00 00 00       	mov    $0x0,%edi
  800160:	89 fb                	mov    %edi,%ebx
  800162:	89 fe                	mov    %edi,%esi
  800164:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800166:	85 c0                	test   %eax,%eax
  800168:	7e 17                	jle    800181 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	50                   	push   %eax
  80016e:	6a 0a                	push   $0xa
  800170:	68 2a 0f 80 00       	push   $0x800f2a
  800175:	6a 23                	push   $0x23
  800177:	68 47 0f 80 00       	push   $0x800f47
  80017c:	e8 d3 01 00 00       	call   800354 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800198:	b8 09 00 00 00       	mov    $0x9,%eax
  80019d:	bf 00 00 00 00       	mov    $0x0,%edi
  8001a2:	89 fb                	mov    %edi,%ebx
  8001a4:	89 fe                	mov    %edi,%esi
  8001a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	7e 17                	jle    8001c3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ac:	83 ec 0c             	sub    $0xc,%esp
  8001af:	50                   	push   %eax
  8001b0:	6a 09                	push   $0x9
  8001b2:	68 2a 0f 80 00       	push   $0x800f2a
  8001b7:	6a 23                	push   $0x23
  8001b9:	68 47 0f 80 00       	push   $0x800f47
  8001be:	e8 91 01 00 00       	call   800354 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	57                   	push   %edi
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 08 00 00 00       	mov    $0x8,%eax
  8001df:	bf 00 00 00 00       	mov    $0x0,%edi
  8001e4:	89 fb                	mov    %edi,%ebx
  8001e6:	89 fe                	mov    %edi,%esi
  8001e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	7e 17                	jle    800205 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	50                   	push   %eax
  8001f2:	6a 08                	push   $0x8
  8001f4:	68 2a 0f 80 00       	push   $0x800f2a
  8001f9:	6a 23                	push   $0x23
  8001fb:	68 47 0f 80 00       	push   $0x800f47
  800200:	e8 4f 01 00 00       	call   800354 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5f                   	pop    %edi
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	57                   	push   %edi
  800211:	56                   	push   %esi
  800212:	53                   	push   %ebx
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	8b 55 08             	mov    0x8(%ebp),%edx
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021c:	b8 06 00 00 00       	mov    $0x6,%eax
  800221:	bf 00 00 00 00       	mov    $0x0,%edi
  800226:	89 fb                	mov    %edi,%ebx
  800228:	89 fe                	mov    %edi,%esi
  80022a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022c:	85 c0                	test   %eax,%eax
  80022e:	7e 17                	jle    800247 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	50                   	push   %eax
  800234:	6a 06                	push   $0x6
  800236:	68 2a 0f 80 00       	push   $0x800f2a
  80023b:	6a 23                	push   $0x23
  80023d:	68 47 0f 80 00       	push   $0x800f47
  800242:	e8 0d 01 00 00       	call   800354 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	57                   	push   %edi
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800261:	8b 7d 14             	mov    0x14(%ebp),%edi
  800264:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	b8 05 00 00 00       	mov    $0x5,%eax
  80026c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026e:	85 c0                	test   %eax,%eax
  800270:	7e 17                	jle    800289 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	50                   	push   %eax
  800276:	6a 05                	push   $0x5
  800278:	68 2a 0f 80 00       	push   $0x800f2a
  80027d:	6a 23                	push   $0x23
  80027f:	68 47 0f 80 00       	push   $0x800f47
  800284:	e8 cb 00 00 00       	call   800354 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8002a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8002ad:	89 fe                	mov    %edi,%esi
  8002af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	7e 17                	jle    8002cc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 04                	push   $0x4
  8002bb:	68 2a 0f 80 00       	push   $0x800f2a
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 47 0f 80 00       	push   $0x800f47
  8002c7:	e8 88 00 00 00       	call   800354 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    

008002d4 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002df:	bf 00 00 00 00       	mov    $0x0,%edi
  8002e4:	89 fa                	mov    %edi,%edx
  8002e6:	89 f9                	mov    %edi,%ecx
  8002e8:	89 fb                	mov    %edi,%ebx
  8002ea:	89 fe                	mov    %edi,%esi
  8002ec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8002fe:	bf 00 00 00 00       	mov    $0x0,%edi
  800303:	89 fa                	mov    %edi,%edx
  800305:	89 f9                	mov    %edi,%ecx
  800307:	89 fb                	mov    %edi,%ebx
  800309:	89 fe                	mov    %edi,%esi
  80030b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031e:	b8 03 00 00 00       	mov    $0x3,%eax
  800323:	bf 00 00 00 00       	mov    $0x0,%edi
  800328:	89 f9                	mov    %edi,%ecx
  80032a:	89 fb                	mov    %edi,%ebx
  80032c:	89 fe                	mov    %edi,%esi
  80032e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800330:	85 c0                	test   %eax,%eax
  800332:	7e 17                	jle    80034b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 03                	push   $0x3
  80033a:	68 2a 0f 80 00       	push   $0x800f2a
  80033f:	6a 23                	push   $0x23
  800341:	68 47 0f 80 00       	push   $0x800f47
  800346:	e8 09 00 00 00       	call   800354 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	c9                   	leave  
  800352:	c3                   	ret    
	...

00800354 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	53                   	push   %ebx
  800358:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80035b:	8d 45 14             	lea    0x14(%ebp),%eax
  80035e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800361:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800367:	e8 87 ff ff ff       	call   8002f3 <sys_getenvid>
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	53                   	push   %ebx
  800376:	50                   	push   %eax
  800377:	68 58 0f 80 00       	push   $0x800f58
  80037c:	e8 74 00 00 00       	call   8003f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800381:	83 c4 18             	add    $0x18,%esp
  800384:	ff 75 f8             	pushl  -0x8(%ebp)
  800387:	ff 75 10             	pushl  0x10(%ebp)
  80038a:	e8 15 00 00 00       	call   8003a4 <vcprintf>
	cprintf("\n");
  80038f:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  800396:	e8 5a 00 00 00       	call   8003f5 <cprintf>
  80039b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80039e:	cc                   	int3   
  80039f:	eb fd                	jmp    80039e <_panic+0x4a>
  8003a1:	00 00                	add    %al,(%eax)
	...

008003a4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ad:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003b4:	00 00 00 
	b.cnt = 0;
  8003b7:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c1:	ff 75 0c             	pushl  0xc(%ebp)
  8003c4:	ff 75 08             	pushl  0x8(%ebp)
  8003c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cd:	50                   	push   %eax
  8003ce:	68 0c 04 80 00       	push   $0x80040c
  8003d3:	e8 70 01 00 00       	call   800548 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d8:	83 c4 08             	add    $0x8,%esp
  8003db:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003e1:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003e7:	50                   	push   %eax
  8003e8:	e8 d2 fc ff ff       	call   8000bf <sys_cputs>
  8003ed:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8003fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800401:	50                   	push   %eax
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	e8 9a ff ff ff       	call   8003a4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	53                   	push   %ebx
  800410:	83 ec 04             	sub    $0x4,%esp
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800416:	8b 03                	mov    (%ebx),%eax
  800418:	8b 55 08             	mov    0x8(%ebp),%edx
  80041b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80041f:	40                   	inc    %eax
  800420:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800422:	3d ff 00 00 00       	cmp    $0xff,%eax
  800427:	75 1a                	jne    800443 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	68 ff 00 00 00       	push   $0xff
  800431:	8d 43 08             	lea    0x8(%ebx),%eax
  800434:	50                   	push   %eax
  800435:	e8 85 fc ff ff       	call   8000bf <sys_cputs>
		b->idx = 0;
  80043a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800440:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800443:	ff 43 04             	incl   0x4(%ebx)
}
  800446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800449:	c9                   	leave  
  80044a:	c3                   	ret    
	...

0080044c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	57                   	push   %edi
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	83 ec 1c             	sub    $0x1c,%esp
  800455:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800458:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800461:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800464:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800467:	8b 55 10             	mov    0x10(%ebp),%edx
  80046a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046d:	89 d6                	mov    %edx,%esi
  80046f:	bf 00 00 00 00       	mov    $0x0,%edi
  800474:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800477:	72 04                	jb     80047d <printnum+0x31>
  800479:	39 c2                	cmp    %eax,%edx
  80047b:	77 3f                	ja     8004bc <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80047d:	83 ec 0c             	sub    $0xc,%esp
  800480:	ff 75 18             	pushl  0x18(%ebp)
  800483:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800486:	50                   	push   %eax
  800487:	52                   	push   %edx
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	57                   	push   %edi
  80048c:	56                   	push   %esi
  80048d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800490:	ff 75 e0             	pushl  -0x20(%ebp)
  800493:	e8 d4 07 00 00       	call   800c6c <__udivdi3>
  800498:	83 c4 18             	add    $0x18,%esp
  80049b:	52                   	push   %edx
  80049c:	50                   	push   %eax
  80049d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004a3:	e8 a4 ff ff ff       	call   80044c <printnum>
  8004a8:	83 c4 20             	add    $0x20,%esp
  8004ab:	eb 14                	jmp    8004c1 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 e8             	pushl  -0x18(%ebp)
  8004b3:	ff 75 18             	pushl  0x18(%ebp)
  8004b6:	ff 55 ec             	call   *-0x14(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004bc:	4b                   	dec    %ebx
  8004bd:	85 db                	test   %ebx,%ebx
  8004bf:	7f ec                	jg     8004ad <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 e8             	pushl  -0x18(%ebp)
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	57                   	push   %edi
  8004cb:	56                   	push   %esi
  8004cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	e8 c1 08 00 00       	call   800d98 <__umoddi3>
  8004d7:	83 c4 14             	add    $0x14,%esp
  8004da:	0f be 80 7d 0f 80 00 	movsbl 0x800f7d(%eax),%eax
  8004e1:	50                   	push   %eax
  8004e2:	ff 55 ec             	call   *-0x14(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
}
  8004e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5f                   	pop    %edi
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  8004f5:	83 fa 01             	cmp    $0x1,%edx
  8004f8:	7e 0e                	jle    800508 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  8004fa:	8b 10                	mov    (%eax),%edx
  8004fc:	8d 42 08             	lea    0x8(%edx),%eax
  8004ff:	89 01                	mov    %eax,(%ecx)
  800501:	8b 02                	mov    (%edx),%eax
  800503:	8b 52 04             	mov    0x4(%edx),%edx
  800506:	eb 22                	jmp    80052a <getuint+0x3a>
	else if (lflag)
  800508:	85 d2                	test   %edx,%edx
  80050a:	74 10                	je     80051c <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  80050c:	8b 10                	mov    (%eax),%edx
  80050e:	8d 42 04             	lea    0x4(%edx),%eax
  800511:	89 01                	mov    %eax,(%ecx)
  800513:	8b 02                	mov    (%edx),%eax
  800515:	ba 00 00 00 00       	mov    $0x0,%edx
  80051a:	eb 0e                	jmp    80052a <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  80051c:	8b 10                	mov    (%eax),%edx
  80051e:	8d 42 04             	lea    0x4(%edx),%eax
  800521:	89 01                	mov    %eax,(%ecx)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    

0080052c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800532:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800535:	8b 11                	mov    (%ecx),%edx
  800537:	3b 51 04             	cmp    0x4(%ecx),%edx
  80053a:	73 0a                	jae    800546 <sprintputch+0x1a>
		*b->buf++ = ch;
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	88 02                	mov    %al,(%edx)
  800541:	8d 42 01             	lea    0x1(%edx),%eax
  800544:	89 01                	mov    %eax,(%ecx)
}
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	57                   	push   %edi
  80054c:	56                   	push   %esi
  80054d:	53                   	push   %ebx
  80054e:	83 ec 3c             	sub    $0x3c,%esp
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800557:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80055a:	eb 1a                	jmp    800576 <vprintfmt+0x2e>
  80055c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80055f:	eb 15                	jmp    800576 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800561:	84 c0                	test   %al,%al
  800563:	0f 84 15 03 00 00    	je     80087e <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	57                   	push   %edi
  80056d:	0f b6 c0             	movzbl %al,%eax
  800570:	50                   	push   %eax
  800571:	ff d6                	call   *%esi
  800573:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800576:	8a 03                	mov    (%ebx),%al
  800578:	43                   	inc    %ebx
  800579:	3c 25                	cmp    $0x25,%al
  80057b:	75 e4                	jne    800561 <vprintfmt+0x19>
  80057d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800584:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80058b:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800592:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800599:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  80059d:	eb 0a                	jmp    8005a9 <vprintfmt+0x61>
  80059f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005a6:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8a 03                	mov    (%ebx),%al
  8005ab:	0f b6 d0             	movzbl %al,%edx
  8005ae:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005b1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005b4:	83 e8 23             	sub    $0x23,%eax
  8005b7:	3c 55                	cmp    $0x55,%al
  8005b9:	0f 87 9c 02 00 00    	ja     80085b <vprintfmt+0x313>
  8005bf:	0f b6 c0             	movzbl %al,%eax
  8005c2:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005c9:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005cd:	eb d7                	jmp    8005a6 <vprintfmt+0x5e>
  8005cf:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005d3:	eb d1                	jmp    8005a6 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005d5:	89 d9                	mov    %ebx,%ecx
  8005d7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005de:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e1:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005e4:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005eb:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005ef:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005f0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005f3:	83 f8 09             	cmp    $0x9,%eax
  8005f6:	77 21                	ja     800619 <vprintfmt+0xd1>
  8005f8:	eb e4                	jmp    8005de <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005fa:	8b 55 14             	mov    0x14(%ebp),%edx
  8005fd:	8d 42 04             	lea    0x4(%edx),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	8b 12                	mov    (%edx),%edx
  800605:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800608:	eb 12                	jmp    80061c <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	79 96                	jns    8005a6 <vprintfmt+0x5e>
  800610:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800617:	eb 8d                	jmp    8005a6 <vprintfmt+0x5e>
  800619:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	79 84                	jns    8005a6 <vprintfmt+0x5e>
  800622:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800625:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800628:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80062f:	e9 72 ff ff ff       	jmp    8005a6 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800634:	ff 45 d4             	incl   -0x2c(%ebp)
  800637:	e9 6a ff ff ff       	jmp    8005a6 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063c:	8b 55 14             	mov    0x14(%ebp),%edx
  80063f:	8d 42 04             	lea    0x4(%edx),%eax
  800642:	89 45 14             	mov    %eax,0x14(%ebp)
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	57                   	push   %edi
  800649:	ff 32                	pushl  (%edx)
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	e9 07 ff ff ff       	jmp    80055c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800655:	8b 55 14             	mov    0x14(%ebp),%edx
  800658:	8d 42 04             	lea    0x4(%edx),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
  80065e:	8b 02                	mov    (%edx),%eax
  800660:	85 c0                	test   %eax,%eax
  800662:	79 02                	jns    800666 <vprintfmt+0x11e>
  800664:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x12e>
  80066b:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 15                	jne    80068b <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 8e 0f 80 00       	push   $0x800f8e
  80067c:	57                   	push   %edi
  80067d:	56                   	push   %esi
  80067e:	e8 6e 02 00 00       	call   8008f1 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	e9 d1 fe ff ff       	jmp    80055c <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80068b:	52                   	push   %edx
  80068c:	68 97 0f 80 00       	push   $0x800f97
  800691:	57                   	push   %edi
  800692:	56                   	push   %esi
  800693:	e8 59 02 00 00       	call   8008f1 <printfmt>
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	e9 bc fe ff ff       	jmp    80055c <vprintfmt+0x14>
  8006a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ac:	8d 42 04             	lea    0x4(%edx),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b2:	8b 1a                	mov    (%edx),%ebx
  8006b4:	85 db                	test   %ebx,%ebx
  8006b6:	75 05                	jne    8006bd <vprintfmt+0x175>
  8006b8:	bb 9a 0f 80 00       	mov    $0x800f9a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006bd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006c1:	7e 66                	jle    800729 <vprintfmt+0x1e1>
  8006c3:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006c7:	74 60                	je     800729 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	51                   	push   %ecx
  8006cd:	53                   	push   %ebx
  8006ce:	e8 57 02 00 00       	call   80092a <strnlen>
  8006d3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006d6:	29 c1                	sub    %eax,%ecx
  8006d8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006e2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006e5:	eb 0f                	jmp    8006f6 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	57                   	push   %edi
  8006eb:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	ff 4d d8             	decl   -0x28(%ebp)
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006fa:	7f eb                	jg     8006e7 <vprintfmt+0x19f>
  8006fc:	eb 2b                	jmp    800729 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800701:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800705:	74 15                	je     80071c <vprintfmt+0x1d4>
  800707:	8d 42 e0             	lea    -0x20(%edx),%eax
  80070a:	83 f8 5e             	cmp    $0x5e,%eax
  80070d:	76 0d                	jbe    80071c <vprintfmt+0x1d4>
					putch('?', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	57                   	push   %edi
  800713:	6a 3f                	push   $0x3f
  800715:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 0a                	jmp    800726 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	57                   	push   %edi
  800720:	52                   	push   %edx
  800721:	ff d6                	call   *%esi
  800723:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800726:	ff 4d d8             	decl   -0x28(%ebp)
  800729:	8a 03                	mov    (%ebx),%al
  80072b:	43                   	inc    %ebx
  80072c:	84 c0                	test   %al,%al
  80072e:	74 1b                	je     80074b <vprintfmt+0x203>
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	78 c8                	js     8006fe <vprintfmt+0x1b6>
  800736:	ff 4d dc             	decl   -0x24(%ebp)
  800739:	79 c3                	jns    8006fe <vprintfmt+0x1b6>
  80073b:	eb 0e                	jmp    80074b <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	57                   	push   %edi
  800741:	6a 20                	push   $0x20
  800743:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800745:	ff 4d d8             	decl   -0x28(%ebp)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80074f:	7f ec                	jg     80073d <vprintfmt+0x1f5>
  800751:	e9 06 fe ff ff       	jmp    80055c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800756:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80075a:	7e 10                	jle    80076c <vprintfmt+0x224>
		return va_arg(*ap, long long);
  80075c:	8b 55 14             	mov    0x14(%ebp),%edx
  80075f:	8d 42 08             	lea    0x8(%edx),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
  800765:	8b 02                	mov    (%edx),%eax
  800767:	8b 52 04             	mov    0x4(%edx),%edx
  80076a:	eb 20                	jmp    80078c <vprintfmt+0x244>
	else if (lflag)
  80076c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800770:	74 0e                	je     800780 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	99                   	cltd   
  80077e:	eb 0c                	jmp    80078c <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80078c:	89 d1                	mov    %edx,%ecx
  80078e:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  800790:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800793:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	78 0a                	js     8007a4 <vprintfmt+0x25c>
  80079a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80079f:	e9 89 00 00 00       	jmp    80082d <vprintfmt+0x2e5>
				putch('-', putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	57                   	push   %edi
  8007a8:	6a 2d                	push   $0x2d
  8007aa:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ac:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007b2:	f7 da                	neg    %edx
  8007b4:	83 d1 00             	adc    $0x0,%ecx
  8007b7:	f7 d9                	neg    %ecx
  8007b9:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 6a                	jmp    80082d <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c9:	e8 22 fd ff ff       	call   8004f0 <getuint>
  8007ce:	89 d1                	mov    %edx,%ecx
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007d7:	eb 54                	jmp    80082d <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007df:	e8 0c fd ff ff       	call   8004f0 <getuint>
  8007e4:	89 d1                	mov    %edx,%ecx
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007ed:	eb 3e                	jmp    80082d <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	57                   	push   %edi
  8007f3:	6a 30                	push   $0x30
  8007f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	57                   	push   %edi
  8007fb:	6a 78                	push   $0x78
  8007fd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007ff:	8b 55 14             	mov    0x14(%ebp),%edx
  800802:	8d 42 04             	lea    0x4(%edx),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
  800808:	8b 12                	mov    (%edx),%edx
  80080a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	eb 14                	jmp    80082d <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800819:	8d 45 14             	lea    0x14(%ebp),%eax
  80081c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80081f:	e8 cc fc ff ff       	call   8004f0 <getuint>
  800824:	89 d1                	mov    %edx,%ecx
  800826:	89 c2                	mov    %eax,%edx
  800828:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80082d:	83 ec 0c             	sub    $0xc,%esp
  800830:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	ff 75 d8             	pushl  -0x28(%ebp)
  800838:	53                   	push   %ebx
  800839:	51                   	push   %ecx
  80083a:	52                   	push   %edx
  80083b:	89 fa                	mov    %edi,%edx
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	e8 08 fc ff ff       	call   80044c <printnum>
			break;
  800844:	83 c4 20             	add    $0x20,%esp
  800847:	e9 10 fd ff ff       	jmp    80055c <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	57                   	push   %edi
  800850:	52                   	push   %edx
  800851:	ff d6                	call   *%esi
			break;
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	e9 01 fd ff ff       	jmp    80055c <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	57                   	push   %edi
  80085f:	6a 25                	push   $0x25
  800861:	ff d6                	call   *%esi
  800863:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800866:	83 ea 02             	sub    $0x2,%edx
  800869:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086c:	8a 02                	mov    (%edx),%al
  80086e:	4a                   	dec    %edx
  80086f:	3c 25                	cmp    $0x25,%al
  800871:	75 f9                	jne    80086c <vprintfmt+0x324>
  800873:	83 c2 02             	add    $0x2,%edx
  800876:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800879:	e9 de fc ff ff       	jmp    80055c <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80087e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5f                   	pop    %edi
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 18             	sub    $0x18,%esp
  80088c:	8b 55 08             	mov    0x8(%ebp),%edx
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800892:	85 d2                	test   %edx,%edx
  800894:	74 37                	je     8008cd <vsnprintf+0x47>
  800896:	85 c0                	test   %eax,%eax
  800898:	7e 33                	jle    8008cd <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a1:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008a8:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ab:	ff 75 14             	pushl  0x14(%ebp)
  8008ae:	ff 75 10             	pushl  0x10(%ebp)
  8008b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b4:	50                   	push   %eax
  8008b5:	68 2c 05 80 00       	push   $0x80052c
  8008ba:	e8 89 fc ff ff       	call   800548 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	eb 05                	jmp    8008d2 <vsnprintf+0x4c>
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008da:	8d 45 14             	lea    0x14(%ebp),%eax
  8008dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 97 ff ff ff       	call   800886 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8008fd:	50                   	push   %eax
  8008fe:	ff 75 10             	pushl  0x10(%ebp)
  800901:	ff 75 0c             	pushl  0xc(%ebp)
  800904:	ff 75 08             	pushl  0x8(%ebp)
  800907:	e8 3c fc ff ff       	call   800548 <vprintfmt>
	va_end(ap);
  80090c:	83 c4 10             	add    $0x10,%esp
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    
  800911:	00 00                	add    %al,(%eax)
	...

00800914 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 55 08             	mov    0x8(%ebp),%edx
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
  80091f:	eb 01                	jmp    800922 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800921:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800922:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800926:	75 f9                	jne    800921 <strlen+0xd>
		n++;
	return n;
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
  800938:	eb 01                	jmp    80093b <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80093a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	74 06                	je     800945 <strnlen+0x1b>
  80093f:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800943:	75 f5                	jne    80093a <strnlen+0x10>
		n++;
	return n;
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800950:	8a 01                	mov    (%ecx),%al
  800952:	88 02                	mov    %al,(%edx)
  800954:	42                   	inc    %edx
  800955:	41                   	inc    %ecx
  800956:	84 c0                	test   %al,%al
  800958:	75 f6                	jne    800950 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800966:	53                   	push   %ebx
  800967:	e8 a8 ff ff ff       	call   800914 <strlen>
	strcpy(dst + len, src);
  80096c:	ff 75 0c             	pushl  0xc(%ebp)
  80096f:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800972:	50                   	push   %eax
  800973:	e8 cf ff ff ff       	call   800947 <strcpy>
	return dst;
}
  800978:	89 d8                	mov    %ebx,%eax
  80097a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80098d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800992:	eb 0c                	jmp    8009a0 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800994:	8a 02                	mov    (%edx),%al
  800996:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800999:	80 3a 01             	cmpb   $0x1,(%edx)
  80099c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099f:	41                   	inc    %ecx
  8009a0:	39 d9                	cmp    %ebx,%ecx
  8009a2:	75 f0                	jne    800994 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a4:	89 f0                	mov    %esi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	75 04                	jne    8009c0 <strlcpy+0x16>
  8009bc:	89 f0                	mov    %esi,%eax
  8009be:	eb 14                	jmp    8009d4 <strlcpy+0x2a>
  8009c0:	89 f0                	mov    %esi,%eax
  8009c2:	eb 04                	jmp    8009c8 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c4:	88 10                	mov    %dl,(%eax)
  8009c6:	40                   	inc    %eax
  8009c7:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c8:	49                   	dec    %ecx
  8009c9:	74 06                	je     8009d1 <strlcpy+0x27>
  8009cb:	8a 13                	mov    (%ebx),%dl
  8009cd:	84 d2                	test   %dl,%dl
  8009cf:	75 f3                	jne    8009c4 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009d1:	c6 00 00             	movb   $0x0,(%eax)
  8009d4:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e3:	eb 02                	jmp    8009e7 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009e5:	42                   	inc    %edx
  8009e6:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e7:	8a 02                	mov    (%edx),%al
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 04                	je     8009f1 <strcmp+0x17>
  8009ed:	3a 01                	cmp    (%ecx),%al
  8009ef:	74 f4                	je     8009e5 <strcmp+0xb>
  8009f1:	0f b6 c0             	movzbl %al,%eax
  8009f4:	0f b6 11             	movzbl (%ecx),%edx
  8009f7:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a05:	8b 55 10             	mov    0x10(%ebp),%edx
  800a08:	eb 03                	jmp    800a0d <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a0a:	4a                   	dec    %edx
  800a0b:	41                   	inc    %ecx
  800a0c:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a0d:	85 d2                	test   %edx,%edx
  800a0f:	75 07                	jne    800a18 <strncmp+0x1d>
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	eb 14                	jmp    800a2c <strncmp+0x31>
  800a18:	8a 01                	mov    (%ecx),%al
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 04                	je     800a22 <strncmp+0x27>
  800a1e:	3a 03                	cmp    (%ebx),%al
  800a20:	74 e8                	je     800a0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a22:	0f b6 d0             	movzbl %al,%edx
  800a25:	0f b6 03             	movzbl (%ebx),%eax
  800a28:	29 c2                	sub    %eax,%edx
  800a2a:	89 d0                	mov    %edx,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a38:	eb 05                	jmp    800a3f <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a3a:	38 ca                	cmp    %cl,%dl
  800a3c:	74 0c                	je     800a4a <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3e:	40                   	inc    %eax
  800a3f:	8a 10                	mov    (%eax),%dl
  800a41:	84 d2                	test   %dl,%dl
  800a43:	75 f5                	jne    800a3a <strchr+0xb>
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a55:	eb 05                	jmp    800a5c <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a57:	38 ca                	cmp    %cl,%dl
  800a59:	74 07                	je     800a62 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5b:	40                   	inc    %eax
  800a5c:	8a 10                	mov    (%eax),%dl
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	75 f5                	jne    800a57 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a73:	85 db                	test   %ebx,%ebx
  800a75:	74 36                	je     800aad <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 29                	jne    800aa8 <memset+0x44>
  800a7f:	f6 c3 03             	test   $0x3,%bl
  800a82:	75 24                	jne    800aa8 <memset+0x44>
		c &= 0xFF;
  800a84:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a87:	89 d6                	mov    %edx,%esi
  800a89:	c1 e6 08             	shl    $0x8,%esi
  800a8c:	89 d0                	mov    %edx,%eax
  800a8e:	c1 e0 18             	shl    $0x18,%eax
  800a91:	89 d1                	mov    %edx,%ecx
  800a93:	c1 e1 10             	shl    $0x10,%ecx
  800a96:	09 c8                	or     %ecx,%eax
  800a98:	09 c2                	or     %eax,%edx
  800a9a:	89 f0                	mov    %esi,%eax
  800a9c:	09 d0                	or     %edx,%eax
  800a9e:	89 d9                	mov    %ebx,%ecx
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
  800aa3:	fc                   	cld    
  800aa4:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa6:	eb 05                	jmp    800aad <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	89 d9                	mov    %ebx,%ecx
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	c9                   	leave  
  800ab3:	c3                   	ret    

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ac2:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ac4:	39 c6                	cmp    %eax,%esi
  800ac6:	73 36                	jae    800afe <memmove+0x4a>
  800ac8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800acb:	39 d0                	cmp    %edx,%eax
  800acd:	73 2f                	jae    800afe <memmove+0x4a>
		s += n;
		d += n;
  800acf:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad2:	f6 c2 03             	test   $0x3,%dl
  800ad5:	75 1b                	jne    800af2 <memmove+0x3e>
  800ad7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800add:	75 13                	jne    800af2 <memmove+0x3e>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 0e                	jne    800af2 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800ae4:	8d 7e fc             	lea    -0x4(%esi),%edi
  800ae7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aea:	c1 e9 02             	shr    $0x2,%ecx
  800aed:	fd                   	std    
  800aee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af0:	eb 09                	jmp    800afb <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af2:	8d 7e ff             	lea    -0x1(%esi),%edi
  800af5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af8:	fd                   	std    
  800af9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afb:	fc                   	cld    
  800afc:	eb 20                	jmp    800b1e <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b04:	75 15                	jne    800b1b <memmove+0x67>
  800b06:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0c:	75 0d                	jne    800b1b <memmove+0x67>
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 08                	jne    800b1b <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b13:	c1 e9 02             	shr    $0x2,%ecx
  800b16:	fc                   	cld    
  800b17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b19:	eb 03                	jmp    800b1e <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1b:	fc                   	cld    
  800b1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b25:	ff 75 10             	pushl  0x10(%ebp)
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	ff 75 08             	pushl  0x8(%ebp)
  800b2e:	e8 81 ff ff ff       	call   800ab4 <memmove>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	53                   	push   %ebx
  800b39:	83 ec 04             	sub    $0x4,%esp
  800b3c:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	eb 1b                	jmp    800b62 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b47:	8a 1a                	mov    (%edx),%bl
  800b49:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b4c:	8a 19                	mov    (%ecx),%bl
  800b4e:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b51:	74 0d                	je     800b60 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b53:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b57:	0f b6 c3             	movzbl %bl,%eax
  800b5a:	29 c2                	sub    %eax,%edx
  800b5c:	89 d0                	mov    %edx,%eax
  800b5e:	eb 0d                	jmp    800b6d <memcmp+0x38>
		s1++, s2++;
  800b60:	42                   	inc    %edx
  800b61:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b62:	48                   	dec    %eax
  800b63:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b66:	75 df                	jne    800b47 <memcmp+0x12>
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b6d:	83 c4 04             	add    $0x4,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	03 55 10             	add    0x10(%ebp),%edx
  800b81:	eb 05                	jmp    800b88 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b83:	38 08                	cmp    %cl,(%eax)
  800b85:	74 05                	je     800b8c <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b87:	40                   	inc    %eax
  800b88:	39 d0                	cmp    %edx,%eax
  800b8a:	72 f7                	jb     800b83 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 04             	sub    $0x4,%esp
  800b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9a:	8b 75 10             	mov    0x10(%ebp),%esi
  800b9d:	eb 01                	jmp    800ba0 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800b9f:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	8a 01                	mov    (%ecx),%al
  800ba2:	3c 20                	cmp    $0x20,%al
  800ba4:	74 f9                	je     800b9f <strtol+0x11>
  800ba6:	3c 09                	cmp    $0x9,%al
  800ba8:	74 f5                	je     800b9f <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800baa:	3c 2b                	cmp    $0x2b,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x2a>
		s++;
  800bae:	41                   	inc    %ecx
  800baf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb6:	eb 17                	jmp    800bcf <strtol+0x41>
	else if (*s == '-')
  800bb8:	3c 2d                	cmp    $0x2d,%al
  800bba:	74 09                	je     800bc5 <strtol+0x37>
  800bbc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bc3:	eb 0a                	jmp    800bcf <strtol+0x41>
		s++, neg = 1;
  800bc5:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bc8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcf:	85 f6                	test   %esi,%esi
  800bd1:	74 05                	je     800bd8 <strtol+0x4a>
  800bd3:	83 fe 10             	cmp    $0x10,%esi
  800bd6:	75 1a                	jne    800bf2 <strtol+0x64>
  800bd8:	8a 01                	mov    (%ecx),%al
  800bda:	3c 30                	cmp    $0x30,%al
  800bdc:	75 10                	jne    800bee <strtol+0x60>
  800bde:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800be2:	75 0a                	jne    800bee <strtol+0x60>
		s += 2, base = 16;
  800be4:	83 c1 02             	add    $0x2,%ecx
  800be7:	be 10 00 00 00       	mov    $0x10,%esi
  800bec:	eb 04                	jmp    800bf2 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bee:	85 f6                	test   %esi,%esi
  800bf0:	74 07                	je     800bf9 <strtol+0x6b>
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf7:	eb 13                	jmp    800c0c <strtol+0x7e>
  800bf9:	3c 30                	cmp    $0x30,%al
  800bfb:	74 07                	je     800c04 <strtol+0x76>
  800bfd:	be 0a 00 00 00       	mov    $0xa,%esi
  800c02:	eb ee                	jmp    800bf2 <strtol+0x64>
		s++, base = 8;
  800c04:	41                   	inc    %ecx
  800c05:	be 08 00 00 00       	mov    $0x8,%esi
  800c0a:	eb e6                	jmp    800bf2 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0c:	8a 11                	mov    (%ecx),%dl
  800c0e:	88 d3                	mov    %dl,%bl
  800c10:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c13:	3c 09                	cmp    $0x9,%al
  800c15:	77 08                	ja     800c1f <strtol+0x91>
			dig = *s - '0';
  800c17:	0f be c2             	movsbl %dl,%eax
  800c1a:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c1d:	eb 1c                	jmp    800c3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c1f:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c22:	3c 19                	cmp    $0x19,%al
  800c24:	77 08                	ja     800c2e <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c26:	0f be c2             	movsbl %dl,%eax
  800c29:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c2c:	eb 0d                	jmp    800c3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c2e:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c31:	3c 19                	cmp    $0x19,%al
  800c33:	77 15                	ja     800c4a <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c35:	0f be c2             	movsbl %dl,%eax
  800c38:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c3b:	39 f2                	cmp    %esi,%edx
  800c3d:	7d 0b                	jge    800c4a <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c3f:	41                   	inc    %ecx
  800c40:	89 f8                	mov    %edi,%eax
  800c42:	0f af c6             	imul   %esi,%eax
  800c45:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c48:	eb c2                	jmp    800c0c <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c4a:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c50:	74 05                	je     800c57 <strtol+0xc9>
		*endptr = (char *) s;
  800c52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c55:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5b:	74 04                	je     800c61 <strtol+0xd3>
  800c5d:	89 c7                	mov    %eax,%edi
  800c5f:	f7 df                	neg    %edi
}
  800c61:	89 f8                	mov    %edi,%eax
  800c63:	83 c4 04             	add    $0x4,%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    
	...

00800c6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	83 ec 28             	sub    $0x28,%esp
  800c74:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c7b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c82:	8b 45 10             	mov    0x10(%ebp),%eax
  800c85:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c8b:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800c8d:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c98:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800c9b:	85 ff                	test   %edi,%edi
  800c9d:	75 21                	jne    800cc0 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800c9f:	39 d1                	cmp    %edx,%ecx
  800ca1:	76 49                	jbe    800cec <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ca3:	f7 f1                	div    %ecx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	31 c0                	xor    %eax,%eax
  800ca9:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cac:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800caf:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cb2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cb5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cb8:	83 c4 28             	add    $0x28,%esp
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    
  800cbf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cc0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cc3:	0f 87 97 00 00 00    	ja     800d60 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cc9:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ccc:	83 f0 1f             	xor    $0x1f,%eax
  800ccf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cd2:	75 34                	jne    800d08 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cd4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cd7:	72 08                	jb     800ce1 <__udivdi3+0x75>
  800cd9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800cdc:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800cdf:	77 7f                	ja     800d60 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ce1:	b9 01 00 00 00       	mov    $0x1,%ecx
  800ce6:	31 c0                	xor    %eax,%eax
  800ce8:	eb c2                	jmp    800cac <__udivdi3+0x40>
  800cea:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	74 79                	je     800d6c <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cf6:	89 fa                	mov    %edi,%edx
  800cf8:	f7 f1                	div    %ecx
  800cfa:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cff:	f7 f1                	div    %ecx
  800d01:	89 c1                	mov    %eax,%ecx
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	eb a5                	jmp    800cac <__udivdi3+0x40>
  800d07:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d08:	b8 20 00 00 00       	mov    $0x20,%eax
  800d0d:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d13:	89 fa                	mov    %edi,%edx
  800d15:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d18:	d3 e2                	shl    %cl,%edx
  800d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1d:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d20:	d3 e8                	shr    %cl,%eax
  800d22:	89 d7                	mov    %edx,%edi
  800d24:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d26:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d29:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d2c:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d31:	d3 e0                	shl    %cl,%eax
  800d33:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d36:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d39:	d3 ea                	shr    %cl,%edx
  800d3b:	09 d0                	or     %edx,%eax
  800d3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d40:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	f7 f7                	div    %edi
  800d47:	89 d7                	mov    %edx,%edi
  800d49:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d4c:	f7 e6                	mul    %esi
  800d4e:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d50:	39 d7                	cmp    %edx,%edi
  800d52:	72 38                	jb     800d8c <__udivdi3+0x120>
  800d54:	74 27                	je     800d7d <__udivdi3+0x111>
  800d56:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d59:	31 c0                	xor    %eax,%eax
  800d5b:	e9 4c ff ff ff       	jmp    800cac <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d60:	31 c9                	xor    %ecx,%ecx
  800d62:	31 c0                	xor    %eax,%eax
  800d64:	e9 43 ff ff ff       	jmp    800cac <__udivdi3+0x40>
  800d69:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d71:	31 d2                	xor    %edx,%edx
  800d73:	f7 75 f4             	divl   -0xc(%ebp)
  800d76:	89 c1                	mov    %eax,%ecx
  800d78:	e9 76 ff ff ff       	jmp    800cf3 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d80:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	39 f0                	cmp    %esi,%eax
  800d87:	73 cd                	jae    800d56 <__udivdi3+0xea>
  800d89:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d8c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d8f:	49                   	dec    %ecx
  800d90:	31 c0                	xor    %eax,%eax
  800d92:	e9 15 ff ff ff       	jmp    800cac <__udivdi3+0x40>
	...

00800d98 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	56                   	push   %esi
  800d9d:	83 ec 30             	sub    $0x30,%esp
  800da0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800da7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dae:	8b 75 08             	mov    0x8(%ebp),%esi
  800db1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db4:	8b 45 10             	mov    0x10(%ebp),%eax
  800db7:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dbd:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dbf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dc2:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dc5:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dc8:	85 d2                	test   %edx,%edx
  800dca:	75 1c                	jne    800de8 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800dcc:	89 fa                	mov    %edi,%edx
  800dce:	39 f8                	cmp    %edi,%eax
  800dd0:	0f 86 c2 00 00 00    	jbe    800e98 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd6:	89 f0                	mov    %esi,%eax
  800dd8:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dda:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800ddd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800de4:	eb 12                	jmp    800df8 <__umoddi3+0x60>
  800de6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800deb:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800dee:	76 18                	jbe    800e08 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800df0:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800df3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800df6:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800dfb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dfe:	83 c4 30             	add    $0x30,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e08:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e0c:	83 f0 1f             	xor    $0x1f,%eax
  800e0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e12:	0f 84 ac 00 00 00    	je     800ec4 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e18:	b8 20 00 00 00       	mov    $0x20,%eax
  800e1d:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e23:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e26:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e29:	d3 e2                	shl    %cl,%edx
  800e2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e2e:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e31:	d3 e8                	shr    %cl,%eax
  800e33:	89 d6                	mov    %edx,%esi
  800e35:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e3a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e3d:	d3 e0                	shl    %cl,%eax
  800e3f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e42:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e45:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4a:	d3 e0                	shl    %cl,%eax
  800e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e52:	d3 ea                	shr    %cl,%edx
  800e54:	09 d0                	or     %edx,%eax
  800e56:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e59:	d3 ea                	shr    %cl,%edx
  800e5b:	f7 f6                	div    %esi
  800e5d:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e60:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e63:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e66:	0f 82 8d 00 00 00    	jb     800ef9 <__umoddi3+0x161>
  800e6c:	0f 84 91 00 00 00    	je     800f03 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e72:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e75:	29 c7                	sub    %eax,%edi
  800e77:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e79:	89 f2                	mov    %esi,%edx
  800e7b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e7e:	d3 e2                	shl    %cl,%edx
  800e80:	89 f8                	mov    %edi,%eax
  800e82:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e85:	d3 e8                	shr    %cl,%eax
  800e87:	09 c2                	or     %eax,%edx
  800e89:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800e8c:	d3 ee                	shr    %cl,%esi
  800e8e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800e91:	e9 62 ff ff ff       	jmp    800df8 <__umoddi3+0x60>
  800e96:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	74 15                	je     800eb4 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea2:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ea5:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eaa:	f7 f1                	div    %ecx
  800eac:	e9 29 ff ff ff       	jmp    800dda <__umoddi3+0x42>
  800eb1:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb9:	31 d2                	xor    %edx,%edx
  800ebb:	f7 75 ec             	divl   -0x14(%ebp)
  800ebe:	89 c1                	mov    %eax,%ecx
  800ec0:	eb dd                	jmp    800e9f <__umoddi3+0x107>
  800ec2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ec4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ec7:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800eca:	72 19                	jb     800ee5 <__umoddi3+0x14d>
  800ecc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ecf:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ed2:	76 11                	jbe    800ee5 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ed4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800eda:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800edd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ee0:	e9 13 ff ff ff       	jmp    800df8 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eeb:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800eee:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800ef1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ef4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ef7:	eb db                	jmp    800ed4 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800ef9:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800efc:	19 f2                	sbb    %esi,%edx
  800efe:	e9 6f ff ff ff       	jmp    800e72 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f03:	39 c7                	cmp    %eax,%edi
  800f05:	72 f2                	jb     800ef9 <__umoddi3+0x161>
  800f07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0a:	e9 63 ff ff ff       	jmp    800e72 <__umoddi3+0xda>
