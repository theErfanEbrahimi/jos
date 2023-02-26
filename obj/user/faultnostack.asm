
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	68 70 03 80 00       	push   $0x800370
  80003f:	6a 00                	push   $0x0
  800041:	e8 1d 01 00 00       	call   800163 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800046:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004d:	00 00 00 
  800050:	83 c4 10             	add    $0x10,%esp
}
  800053:	c9                   	leave  
  800054:	c3                   	ret    
  800055:	00 00                	add    %al,(%eax)
	...

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	56                   	push   %esi
  80005c:	53                   	push   %ebx
  80005d:	8b 75 08             	mov    0x8(%ebp),%esi
  800060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800063:	e8 a7 02 00 00       	call   80030f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	29 d0                	sub    %edx,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 f6                	test   %esi,%esi
  800085:	7e 07                	jle    80008e <libmain+0x36>
		binaryname = argv[0];
  800087:	8b 03                	mov    (%ebx),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	53                   	push   %ebx
  800092:	56                   	push   %esi
  800093:	e8 9c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800098:	e8 0b 00 00 00       	call   8000a8 <exit>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 79 02 00 00       	call   80032e <sys_env_destroy>
  8000b5:	83 c4 10             	add    $0x10,%esp
}
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    
	...

008000bc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8000cc:	89 fa                	mov    %edi,%edx
  8000ce:	89 f9                	mov    %edi,%ecx
  8000d0:	89 fb                	mov    %edi,%ebx
  8000d2:	89 fe                	mov    %edi,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 04             	sub    $0x4,%esp
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8000ef:	89 f8                	mov    %edi,%eax
  8000f1:	89 fb                	mov    %edi,%ebx
  8000f3:	89 fe                	mov    %edi,%esi
  8000f5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f7:	83 c4 04             	add    $0x4,%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800110:	bf 00 00 00 00       	mov    $0x0,%edi
  800115:	89 f9                	mov    %edi,%ecx
  800117:	89 fb                	mov    %edi,%ebx
  800119:	89 fe                	mov    %edi,%esi
  80011b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011d:	85 c0                	test   %eax,%eax
  80011f:	7e 17                	jle    800138 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	50                   	push   %eax
  800125:	6a 0d                	push   $0xd
  800127:	68 ea 0f 80 00       	push   $0x800fea
  80012c:	6a 23                	push   $0x23
  80012e:	68 07 10 80 00       	push   $0x801007
  800133:	e8 60 02 00 00       	call   800398 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80014c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80014f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	b8 0c 00 00 00       	mov    $0xc,%eax
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	b8 0a 00 00 00       	mov    $0xa,%eax
  800177:	bf 00 00 00 00       	mov    $0x0,%edi
  80017c:	89 fb                	mov    %edi,%ebx
  80017e:	89 fe                	mov    %edi,%esi
  800180:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 0a                	push   $0xa
  80018c:	68 ea 0f 80 00       	push   $0x800fea
  800191:	6a 23                	push   $0x23
  800193:	68 07 10 80 00       	push   $0x801007
  800198:	e8 fb 01 00 00       	call   800398 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8001b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8001be:	89 fb                	mov    %edi,%ebx
  8001c0:	89 fe                	mov    %edi,%esi
  8001c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 09                	push   $0x9
  8001ce:	68 ea 0f 80 00       	push   $0x800fea
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 07 10 80 00       	push   $0x801007
  8001da:	e8 b9 01 00 00       	call   800398 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8001fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800200:	89 fb                	mov    %edi,%ebx
  800202:	89 fe                	mov    %edi,%esi
  800204:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 08                	push   $0x8
  800210:	68 ea 0f 80 00       	push   $0x800fea
  800215:	6a 23                	push   $0x23
  800217:	68 07 10 80 00       	push   $0x801007
  80021c:	e8 77 01 00 00       	call   800398 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	b8 06 00 00 00       	mov    $0x6,%eax
  80023d:	bf 00 00 00 00       	mov    $0x0,%edi
  800242:	89 fb                	mov    %edi,%ebx
  800244:	89 fe                	mov    %edi,%esi
  800246:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 06                	push   $0x6
  800252:	68 ea 0f 80 00       	push   $0x800fea
  800257:	6a 23                	push   $0x23
  800259:	68 07 10 80 00       	push   $0x801007
  80025e:	e8 35 01 00 00       	call   800398 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80027d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800280:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800283:	b8 05 00 00 00       	mov    $0x5,%eax
  800288:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 05                	push   $0x5
  800294:	68 ea 0f 80 00       	push   $0x800fea
  800299:	6a 23                	push   $0x23
  80029b:	68 07 10 80 00       	push   $0x801007
  8002a0:	e8 f3 00 00 00       	call   800398 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bf:	b8 04 00 00 00       	mov    $0x4,%eax
  8002c4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002c9:	89 fe                	mov    %edi,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 04                	push   $0x4
  8002d7:	68 ea 0f 80 00       	push   $0x800fea
  8002dc:	6a 23                	push   $0x23
  8002de:	68 07 10 80 00       	push   $0x801007
  8002e3:	e8 b0 00 00 00       	call   800398 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800300:	89 fa                	mov    %edi,%edx
  800302:	89 f9                	mov    %edi,%ecx
  800304:	89 fb                	mov    %edi,%ebx
  800306:	89 fe                	mov    %edi,%esi
  800308:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800315:	b8 02 00 00 00       	mov    $0x2,%eax
  80031a:	bf 00 00 00 00       	mov    $0x0,%edi
  80031f:	89 fa                	mov    %edi,%edx
  800321:	89 f9                	mov    %edi,%ecx
  800323:	89 fb                	mov    %edi,%ebx
  800325:	89 fe                	mov    %edi,%esi
  800327:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b8 03 00 00 00       	mov    $0x3,%eax
  80033f:	bf 00 00 00 00       	mov    $0x0,%edi
  800344:	89 f9                	mov    %edi,%ecx
  800346:	89 fb                	mov    %edi,%ebx
  800348:	89 fe                	mov    %edi,%esi
  80034a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 17                	jle    800367 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	50                   	push   %eax
  800354:	6a 03                	push   $0x3
  800356:	68 ea 0f 80 00       	push   $0x800fea
  80035b:	6a 23                	push   $0x23
  80035d:	68 07 10 80 00       	push   $0x801007
  800362:	e8 31 00 00 00       	call   800398 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    
	...

00800370 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800370:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800371:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800376:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800378:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  80037b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80037f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800382:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  800386:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  80038a:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  80038c:	83 c4 08             	add    $0x8,%esp
	popal
  80038f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800390:	83 c4 04             	add    $0x4,%esp
	popfl
  800393:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800394:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  800395:	c3                   	ret    
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	53                   	push   %ebx
  80039c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80039f:	8d 45 14             	lea    0x14(%ebp),%eax
  8003a2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a5:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003ab:	e8 5f ff ff ff       	call   80030f <sys_getenvid>
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	53                   	push   %ebx
  8003ba:	50                   	push   %eax
  8003bb:	68 18 10 80 00       	push   $0x801018
  8003c0:	e8 74 00 00 00       	call   800439 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c5:	83 c4 18             	add    $0x18,%esp
  8003c8:	ff 75 f8             	pushl  -0x8(%ebp)
  8003cb:	ff 75 10             	pushl  0x10(%ebp)
  8003ce:	e8 15 00 00 00       	call   8003e8 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 3b 10 80 00 	movl   $0x80103b,(%esp)
  8003da:	e8 5a 00 00 00       	call   800439 <cprintf>
  8003df:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e2:	cc                   	int3   
  8003e3:	eb fd                	jmp    8003e2 <_panic+0x4a>
  8003e5:	00 00                	add    %al,(%eax)
	...

008003e8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003f1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003f8:	00 00 00 
	b.cnt = 0;
  8003fb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  800402:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800405:	ff 75 0c             	pushl  0xc(%ebp)
  800408:	ff 75 08             	pushl  0x8(%ebp)
  80040b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800411:	50                   	push   %eax
  800412:	68 50 04 80 00       	push   $0x800450
  800417:	e8 70 01 00 00       	call   80058c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80041c:	83 c4 08             	add    $0x8,%esp
  80041f:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800425:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80042b:	50                   	push   %eax
  80042c:	e8 aa fc ff ff       	call   8000db <sys_cputs>
  800431:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800437:	c9                   	leave  
  800438:	c3                   	ret    

00800439 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800442:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800445:	50                   	push   %eax
  800446:	ff 75 08             	pushl  0x8(%ebp)
  800449:	e8 9a ff ff ff       	call   8003e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80044e:	c9                   	leave  
  80044f:	c3                   	ret    

00800450 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	53                   	push   %ebx
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80045a:	8b 03                	mov    (%ebx),%eax
  80045c:	8b 55 08             	mov    0x8(%ebp),%edx
  80045f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800463:	40                   	inc    %eax
  800464:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800466:	3d ff 00 00 00       	cmp    $0xff,%eax
  80046b:	75 1a                	jne    800487 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	68 ff 00 00 00       	push   $0xff
  800475:	8d 43 08             	lea    0x8(%ebx),%eax
  800478:	50                   	push   %eax
  800479:	e8 5d fc ff ff       	call   8000db <sys_cputs>
		b->idx = 0;
  80047e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800484:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800487:	ff 43 04             	incl   0x4(%ebx)
}
  80048a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048d:	c9                   	leave  
  80048e:	c3                   	ret    
	...

00800490 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 1c             	sub    $0x1c,%esp
  800499:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80049c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80049f:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ab:	8b 55 10             	mov    0x10(%ebp),%edx
  8004ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b1:	89 d6                	mov    %edx,%esi
  8004b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8004b8:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8004bb:	72 04                	jb     8004c1 <printnum+0x31>
  8004bd:	39 c2                	cmp    %eax,%edx
  8004bf:	77 3f                	ja     800500 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c1:	83 ec 0c             	sub    $0xc,%esp
  8004c4:	ff 75 18             	pushl  0x18(%ebp)
  8004c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8004ca:	50                   	push   %eax
  8004cb:	52                   	push   %edx
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	57                   	push   %edi
  8004d0:	56                   	push   %esi
  8004d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d7:	e8 54 08 00 00       	call   800d30 <__udivdi3>
  8004dc:	83 c4 18             	add    $0x18,%esp
  8004df:	52                   	push   %edx
  8004e0:	50                   	push   %eax
  8004e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004e7:	e8 a4 ff ff ff       	call   800490 <printnum>
  8004ec:	83 c4 20             	add    $0x20,%esp
  8004ef:	eb 14                	jmp    800505 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 e8             	pushl  -0x18(%ebp)
  8004f7:	ff 75 18             	pushl  0x18(%ebp)
  8004fa:	ff 55 ec             	call   *-0x14(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800500:	4b                   	dec    %ebx
  800501:	85 db                	test   %ebx,%ebx
  800503:	7f ec                	jg     8004f1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 e8             	pushl  -0x18(%ebp)
  80050b:	83 ec 04             	sub    $0x4,%esp
  80050e:	57                   	push   %edi
  80050f:	56                   	push   %esi
  800510:	ff 75 e4             	pushl  -0x1c(%ebp)
  800513:	ff 75 e0             	pushl  -0x20(%ebp)
  800516:	e8 41 09 00 00       	call   800e5c <__umoddi3>
  80051b:	83 c4 14             	add    $0x14,%esp
  80051e:	0f be 80 3d 10 80 00 	movsbl 0x80103d(%eax),%eax
  800525:	50                   	push   %eax
  800526:	ff 55 ec             	call   *-0x14(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
}
  80052c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	5f                   	pop    %edi
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800539:	83 fa 01             	cmp    $0x1,%edx
  80053c:	7e 0e                	jle    80054c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80053e:	8b 10                	mov    (%eax),%edx
  800540:	8d 42 08             	lea    0x8(%edx),%eax
  800543:	89 01                	mov    %eax,(%ecx)
  800545:	8b 02                	mov    (%edx),%eax
  800547:	8b 52 04             	mov    0x4(%edx),%edx
  80054a:	eb 22                	jmp    80056e <getuint+0x3a>
	else if (lflag)
  80054c:	85 d2                	test   %edx,%edx
  80054e:	74 10                	je     800560 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800550:	8b 10                	mov    (%eax),%edx
  800552:	8d 42 04             	lea    0x4(%edx),%eax
  800555:	89 01                	mov    %eax,(%ecx)
  800557:	8b 02                	mov    (%edx),%eax
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	eb 0e                	jmp    80056e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800560:	8b 10                	mov    (%eax),%edx
  800562:	8d 42 04             	lea    0x4(%edx),%eax
  800565:	89 01                	mov    %eax,(%ecx)
  800567:	8b 02                	mov    (%edx),%eax
  800569:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80056e:	c9                   	leave  
  80056f:	c3                   	ret    

00800570 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800576:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800579:	8b 11                	mov    (%ecx),%edx
  80057b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80057e:	73 0a                	jae    80058a <sprintputch+0x1a>
		*b->buf++ = ch;
  800580:	8b 45 08             	mov    0x8(%ebp),%eax
  800583:	88 02                	mov    %al,(%edx)
  800585:	8d 42 01             	lea    0x1(%edx),%eax
  800588:	89 01                	mov    %eax,(%ecx)
}
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	53                   	push   %ebx
  800592:	83 ec 3c             	sub    $0x3c,%esp
  800595:	8b 75 08             	mov    0x8(%ebp),%esi
  800598:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80059b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059e:	eb 1a                	jmp    8005ba <vprintfmt+0x2e>
  8005a0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8005a3:	eb 15                	jmp    8005ba <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a5:	84 c0                	test   %al,%al
  8005a7:	0f 84 15 03 00 00    	je     8008c2 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	57                   	push   %edi
  8005b1:	0f b6 c0             	movzbl %al,%eax
  8005b4:	50                   	push   %eax
  8005b5:	ff d6                	call   *%esi
  8005b7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ba:	8a 03                	mov    (%ebx),%al
  8005bc:	43                   	inc    %ebx
  8005bd:	3c 25                	cmp    $0x25,%al
  8005bf:	75 e4                	jne    8005a5 <vprintfmt+0x19>
  8005c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005cf:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005dd:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005e1:	eb 0a                	jmp    8005ed <vprintfmt+0x61>
  8005e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005ea:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8a 03                	mov    (%ebx),%al
  8005ef:	0f b6 d0             	movzbl %al,%edx
  8005f2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005f5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005f8:	83 e8 23             	sub    $0x23,%eax
  8005fb:	3c 55                	cmp    $0x55,%al
  8005fd:	0f 87 9c 02 00 00    	ja     80089f <vprintfmt+0x313>
  800603:	0f b6 c0             	movzbl %al,%eax
  800606:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  80060d:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800611:	eb d7                	jmp    8005ea <vprintfmt+0x5e>
  800613:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  800617:	eb d1                	jmp    8005ea <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800619:	89 d9                	mov    %ebx,%ecx
  80061b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800622:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800625:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800628:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  80062f:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800633:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800634:	8d 42 d0             	lea    -0x30(%edx),%eax
  800637:	83 f8 09             	cmp    $0x9,%eax
  80063a:	77 21                	ja     80065d <vprintfmt+0xd1>
  80063c:	eb e4                	jmp    800622 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80063e:	8b 55 14             	mov    0x14(%ebp),%edx
  800641:	8d 42 04             	lea    0x4(%edx),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
  800647:	8b 12                	mov    (%edx),%edx
  800649:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064c:	eb 12                	jmp    800660 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80064e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800652:	79 96                	jns    8005ea <vprintfmt+0x5e>
  800654:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80065b:	eb 8d                	jmp    8005ea <vprintfmt+0x5e>
  80065d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800660:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800664:	79 84                	jns    8005ea <vprintfmt+0x5e>
  800666:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800673:	e9 72 ff ff ff       	jmp    8005ea <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800678:	ff 45 d4             	incl   -0x2c(%ebp)
  80067b:	e9 6a ff ff ff       	jmp    8005ea <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800680:	8b 55 14             	mov    0x14(%ebp),%edx
  800683:	8d 42 04             	lea    0x4(%edx),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	57                   	push   %edi
  80068d:	ff 32                	pushl  (%edx)
  80068f:	ff d6                	call   *%esi
			break;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	e9 07 ff ff ff       	jmp    8005a0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800699:	8b 55 14             	mov    0x14(%ebp),%edx
  80069c:	8d 42 04             	lea    0x4(%edx),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a2:	8b 02                	mov    (%edx),%eax
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	79 02                	jns    8006aa <vprintfmt+0x11e>
  8006a8:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006aa:	83 f8 0f             	cmp    $0xf,%eax
  8006ad:	7f 0b                	jg     8006ba <vprintfmt+0x12e>
  8006af:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  8006b6:	85 d2                	test   %edx,%edx
  8006b8:	75 15                	jne    8006cf <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8006ba:	50                   	push   %eax
  8006bb:	68 4e 10 80 00       	push   $0x80104e
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	e8 6e 02 00 00       	call   800935 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	e9 d1 fe ff ff       	jmp    8005a0 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006cf:	52                   	push   %edx
  8006d0:	68 57 10 80 00       	push   $0x801057
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	e8 59 02 00 00       	call   800935 <printfmt>
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	e9 bc fe ff ff       	jmp    8005a0 <vprintfmt+0x14>
  8006e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ed:	8b 55 14             	mov    0x14(%ebp),%edx
  8006f0:	8d 42 04             	lea    0x4(%edx),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f6:	8b 1a                	mov    (%edx),%ebx
  8006f8:	85 db                	test   %ebx,%ebx
  8006fa:	75 05                	jne    800701 <vprintfmt+0x175>
  8006fc:	bb 5a 10 80 00       	mov    $0x80105a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800701:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800705:	7e 66                	jle    80076d <vprintfmt+0x1e1>
  800707:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  80070b:	74 60                	je     80076d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	51                   	push   %ecx
  800711:	53                   	push   %ebx
  800712:	e8 57 02 00 00       	call   80096e <strnlen>
  800717:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80071a:	29 c1                	sub    %eax,%ecx
  80071c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800726:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800729:	eb 0f                	jmp    80073a <vprintfmt+0x1ae>
					putch(padc, putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	57                   	push   %edi
  80072f:	ff 75 c4             	pushl  -0x3c(%ebp)
  800732:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800734:	ff 4d d8             	decl   -0x28(%ebp)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073e:	7f eb                	jg     80072b <vprintfmt+0x19f>
  800740:	eb 2b                	jmp    80076d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800742:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800745:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800749:	74 15                	je     800760 <vprintfmt+0x1d4>
  80074b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80074e:	83 f8 5e             	cmp    $0x5e,%eax
  800751:	76 0d                	jbe    800760 <vprintfmt+0x1d4>
					putch('?', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	57                   	push   %edi
  800757:	6a 3f                	push   $0x3f
  800759:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 0a                	jmp    80076a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	57                   	push   %edi
  800764:	52                   	push   %edx
  800765:	ff d6                	call   *%esi
  800767:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076a:	ff 4d d8             	decl   -0x28(%ebp)
  80076d:	8a 03                	mov    (%ebx),%al
  80076f:	43                   	inc    %ebx
  800770:	84 c0                	test   %al,%al
  800772:	74 1b                	je     80078f <vprintfmt+0x203>
  800774:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800778:	78 c8                	js     800742 <vprintfmt+0x1b6>
  80077a:	ff 4d dc             	decl   -0x24(%ebp)
  80077d:	79 c3                	jns    800742 <vprintfmt+0x1b6>
  80077f:	eb 0e                	jmp    80078f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	57                   	push   %edi
  800785:	6a 20                	push   $0x20
  800787:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800789:	ff 4d d8             	decl   -0x28(%ebp)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800793:	7f ec                	jg     800781 <vprintfmt+0x1f5>
  800795:	e9 06 fe ff ff       	jmp    8005a0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80079e:	7e 10                	jle    8007b0 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  8007a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8007a3:	8d 42 08             	lea    0x8(%edx),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	8b 52 04             	mov    0x4(%edx),%edx
  8007ae:	eb 20                	jmp    8007d0 <vprintfmt+0x244>
	else if (lflag)
  8007b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b4:	74 0e                	je     8007c4 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 50 04             	lea    0x4(%eax),%edx
  8007bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	99                   	cltd   
  8007c2:	eb 0c                	jmp    8007d0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d0:	89 d1                	mov    %edx,%ecx
  8007d2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8007d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007da:	85 c9                	test   %ecx,%ecx
  8007dc:	78 0a                	js     8007e8 <vprintfmt+0x25c>
  8007de:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007e3:	e9 89 00 00 00       	jmp    800871 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	57                   	push   %edi
  8007ec:	6a 2d                	push   $0x2d
  8007ee:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007f6:	f7 da                	neg    %edx
  8007f8:	83 d1 00             	adc    $0x0,%ecx
  8007fb:	f7 d9                	neg    %ecx
  8007fd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	eb 6a                	jmp    800871 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
  80080a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80080d:	e8 22 fd ff ff       	call   800534 <getuint>
  800812:	89 d1                	mov    %edx,%ecx
  800814:	89 c2                	mov    %eax,%edx
  800816:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80081b:	eb 54                	jmp    800871 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800823:	e8 0c fd ff ff       	call   800534 <getuint>
  800828:	89 d1                	mov    %edx,%ecx
  80082a:	89 c2                	mov    %eax,%edx
  80082c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800831:	eb 3e                	jmp    800871 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	57                   	push   %edi
  800837:	6a 30                	push   $0x30
  800839:	ff d6                	call   *%esi
			putch('x', putdat);
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	57                   	push   %edi
  80083f:	6a 78                	push   $0x78
  800841:	ff d6                	call   *%esi
			num = (unsigned long long)
  800843:	8b 55 14             	mov    0x14(%ebp),%edx
  800846:	8d 42 04             	lea    0x4(%edx),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
  80084c:	8b 12                	mov    (%edx),%edx
  80084e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800853:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 14                	jmp    800871 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085d:	8d 45 14             	lea    0x14(%ebp),%eax
  800860:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800863:	e8 cc fc ff ff       	call   800534 <getuint>
  800868:	89 d1                	mov    %edx,%ecx
  80086a:	89 c2                	mov    %eax,%edx
  80086c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800871:	83 ec 0c             	sub    $0xc,%esp
  800874:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800878:	50                   	push   %eax
  800879:	ff 75 d8             	pushl  -0x28(%ebp)
  80087c:	53                   	push   %ebx
  80087d:	51                   	push   %ecx
  80087e:	52                   	push   %edx
  80087f:	89 fa                	mov    %edi,%edx
  800881:	89 f0                	mov    %esi,%eax
  800883:	e8 08 fc ff ff       	call   800490 <printnum>
			break;
  800888:	83 c4 20             	add    $0x20,%esp
  80088b:	e9 10 fd ff ff       	jmp    8005a0 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	57                   	push   %edi
  800894:	52                   	push   %edx
  800895:	ff d6                	call   *%esi
			break;
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	e9 01 fd ff ff       	jmp    8005a0 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	57                   	push   %edi
  8008a3:	6a 25                	push   $0x25
  8008a5:	ff d6                	call   *%esi
  8008a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008aa:	83 ea 02             	sub    $0x2,%edx
  8008ad:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b0:	8a 02                	mov    (%edx),%al
  8008b2:	4a                   	dec    %edx
  8008b3:	3c 25                	cmp    $0x25,%al
  8008b5:	75 f9                	jne    8008b0 <vprintfmt+0x324>
  8008b7:	83 c2 02             	add    $0x2,%edx
  8008ba:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8008bd:	e9 de fc ff ff       	jmp    8005a0 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8008c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 18             	sub    $0x18,%esp
  8008d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	74 37                	je     800911 <vsnprintf+0x47>
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	7e 33                	jle    800911 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008e5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008ec:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ef:	ff 75 14             	pushl  0x14(%ebp)
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f8:	50                   	push   %eax
  8008f9:	68 70 05 80 00       	push   $0x800570
  8008fe:	e8 89 fc ff ff       	call   80058c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800903:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800906:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800909:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb 05                	jmp    800916 <vsnprintf+0x4c>
  800911:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091e:	8d 45 14             	lea    0x14(%ebp),%eax
  800921:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800924:	50                   	push   %eax
  800925:	ff 75 10             	pushl  0x10(%ebp)
  800928:	ff 75 0c             	pushl  0xc(%ebp)
  80092b:	ff 75 08             	pushl  0x8(%ebp)
  80092e:	e8 97 ff ff ff       	call   8008ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80093b:	8d 45 14             	lea    0x14(%ebp),%eax
  80093e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800941:	50                   	push   %eax
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 3c fc ff ff       	call   80058c <vprintfmt>
	va_end(ap);
  800950:	83 c4 10             	add    $0x10,%esp
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    
  800955:	00 00                	add    %al,(%eax)
	...

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb 01                	jmp    800966 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800965:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800966:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80096a:	75 f9                	jne    800965 <strlen+0xd>
		n++;
	return n;
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
  80097c:	eb 01                	jmp    80097f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80097e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	74 06                	je     800989 <strnlen+0x1b>
  800983:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800987:	75 f5                	jne    80097e <strnlen+0x10>
		n++;
	return n;
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800991:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800994:	8a 01                	mov    (%ecx),%al
  800996:	88 02                	mov    %al,(%edx)
  800998:	42                   	inc    %edx
  800999:	41                   	inc    %ecx
  80099a:	84 c0                	test   %al,%al
  80099c:	75 f6                	jne    800994 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	53                   	push   %ebx
  8009a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009aa:	53                   	push   %ebx
  8009ab:	e8 a8 ff ff ff       	call   800958 <strlen>
	strcpy(dst + len, src);
  8009b0:	ff 75 0c             	pushl  0xc(%ebp)
  8009b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009b6:	50                   	push   %eax
  8009b7:	e8 cf ff ff ff       	call   80098b <strcpy>
	return dst;
}
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d6:	eb 0c                	jmp    8009e4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009d8:	8a 02                	mov    (%edx),%al
  8009da:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8009e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e3:	41                   	inc    %ecx
  8009e4:	39 d9                	cmp    %ebx,%ecx
  8009e6:	75 f0                	jne    8009d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e8:	89 f0                	mov    %esi,%eax
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fc:	85 c9                	test   %ecx,%ecx
  8009fe:	75 04                	jne    800a04 <strlcpy+0x16>
  800a00:	89 f0                	mov    %esi,%eax
  800a02:	eb 14                	jmp    800a18 <strlcpy+0x2a>
  800a04:	89 f0                	mov    %esi,%eax
  800a06:	eb 04                	jmp    800a0c <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a08:	88 10                	mov    %dl,(%eax)
  800a0a:	40                   	inc    %eax
  800a0b:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a0c:	49                   	dec    %ecx
  800a0d:	74 06                	je     800a15 <strlcpy+0x27>
  800a0f:	8a 13                	mov    (%ebx),%dl
  800a11:	84 d2                	test   %dl,%dl
  800a13:	75 f3                	jne    800a08 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800a15:	c6 00 00             	movb   $0x0,(%eax)
  800a18:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 55 08             	mov    0x8(%ebp),%edx
  800a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a27:	eb 02                	jmp    800a2b <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800a29:	42                   	inc    %edx
  800a2a:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2b:	8a 02                	mov    (%edx),%al
  800a2d:	84 c0                	test   %al,%al
  800a2f:	74 04                	je     800a35 <strcmp+0x17>
  800a31:	3a 01                	cmp    (%ecx),%al
  800a33:	74 f4                	je     800a29 <strcmp+0xb>
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 11             	movzbl (%ecx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a49:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4c:	eb 03                	jmp    800a51 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a4e:	4a                   	dec    %edx
  800a4f:	41                   	inc    %ecx
  800a50:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a51:	85 d2                	test   %edx,%edx
  800a53:	75 07                	jne    800a5c <strncmp+0x1d>
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	eb 14                	jmp    800a70 <strncmp+0x31>
  800a5c:	8a 01                	mov    (%ecx),%al
  800a5e:	84 c0                	test   %al,%al
  800a60:	74 04                	je     800a66 <strncmp+0x27>
  800a62:	3a 03                	cmp    (%ebx),%al
  800a64:	74 e8                	je     800a4e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a66:	0f b6 d0             	movzbl %al,%edx
  800a69:	0f b6 03             	movzbl (%ebx),%eax
  800a6c:	29 c2                	sub    %eax,%edx
  800a6e:	89 d0                	mov    %edx,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a7c:	eb 05                	jmp    800a83 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a7e:	38 ca                	cmp    %cl,%dl
  800a80:	74 0c                	je     800a8e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a82:	40                   	inc    %eax
  800a83:	8a 10                	mov    (%eax),%dl
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f5                	jne    800a7e <strchr+0xb>
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a99:	eb 05                	jmp    800aa0 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a9b:	38 ca                	cmp    %cl,%dl
  800a9d:	74 07                	je     800aa6 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a9f:	40                   	inc    %eax
  800aa0:	8a 10                	mov    (%eax),%dl
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	75 f5                	jne    800a9b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    

00800aa8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800ab7:	85 db                	test   %ebx,%ebx
  800ab9:	74 36                	je     800af1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac1:	75 29                	jne    800aec <memset+0x44>
  800ac3:	f6 c3 03             	test   $0x3,%bl
  800ac6:	75 24                	jne    800aec <memset+0x44>
		c &= 0xFF;
  800ac8:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	c1 e6 08             	shl    $0x8,%esi
  800ad0:	89 d0                	mov    %edx,%eax
  800ad2:	c1 e0 18             	shl    $0x18,%eax
  800ad5:	89 d1                	mov    %edx,%ecx
  800ad7:	c1 e1 10             	shl    $0x10,%ecx
  800ada:	09 c8                	or     %ecx,%eax
  800adc:	09 c2                	or     %eax,%edx
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	09 d0                	or     %edx,%eax
  800ae2:	89 d9                	mov    %ebx,%ecx
  800ae4:	c1 e9 02             	shr    $0x2,%ecx
  800ae7:	fc                   	cld    
  800ae8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aea:	eb 05                	jmp    800af1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aec:	89 d9                	mov    %ebx,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af1:	89 f8                	mov    %edi,%eax
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b06:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b08:	39 c6                	cmp    %eax,%esi
  800b0a:	73 36                	jae    800b42 <memmove+0x4a>
  800b0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0f:	39 d0                	cmp    %edx,%eax
  800b11:	73 2f                	jae    800b42 <memmove+0x4a>
		s += n;
		d += n;
  800b13:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f6 c2 03             	test   $0x3,%dl
  800b19:	75 1b                	jne    800b36 <memmove+0x3e>
  800b1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b21:	75 13                	jne    800b36 <memmove+0x3e>
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 0e                	jne    800b36 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800b28:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
  800b31:	fd                   	std    
  800b32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b34:	eb 09                	jmp    800b3f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b36:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b39:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b3c:	fd                   	std    
  800b3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3f:	fc                   	cld    
  800b40:	eb 20                	jmp    800b62 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b48:	75 15                	jne    800b5f <memmove+0x67>
  800b4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b50:	75 0d                	jne    800b5f <memmove+0x67>
  800b52:	f6 c1 03             	test   $0x3,%cl
  800b55:	75 08                	jne    800b5f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b57:	c1 e9 02             	shr    $0x2,%ecx
  800b5a:	fc                   	cld    
  800b5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5d:	eb 03                	jmp    800b62 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5f:	fc                   	cld    
  800b60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b69:	ff 75 10             	pushl  0x10(%ebp)
  800b6c:	ff 75 0c             	pushl  0xc(%ebp)
  800b6f:	ff 75 08             	pushl  0x8(%ebp)
  800b72:	e8 81 ff ff ff       	call   800af8 <memmove>
}
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 04             	sub    $0x4,%esp
  800b80:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b89:	eb 1b                	jmp    800ba6 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b8b:	8a 1a                	mov    (%edx),%bl
  800b8d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b90:	8a 19                	mov    (%ecx),%bl
  800b92:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b95:	74 0d                	je     800ba4 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b97:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b9b:	0f b6 c3             	movzbl %bl,%eax
  800b9e:	29 c2                	sub    %eax,%edx
  800ba0:	89 d0                	mov    %edx,%eax
  800ba2:	eb 0d                	jmp    800bb1 <memcmp+0x38>
		s1++, s2++;
  800ba4:	42                   	inc    %edx
  800ba5:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba6:	48                   	dec    %eax
  800ba7:	83 f8 ff             	cmp    $0xffffffff,%eax
  800baa:	75 df                	jne    800b8b <memcmp+0x12>
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bb1:	83 c4 04             	add    $0x4,%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc0:	89 c2                	mov    %eax,%edx
  800bc2:	03 55 10             	add    0x10(%ebp),%edx
  800bc5:	eb 05                	jmp    800bcc <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	38 08                	cmp    %cl,(%eax)
  800bc9:	74 05                	je     800bd0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcb:	40                   	inc    %eax
  800bcc:	39 d0                	cmp    %edx,%eax
  800bce:	72 f7                	jb     800bc7 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 04             	sub    $0x4,%esp
  800bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bde:	8b 75 10             	mov    0x10(%ebp),%esi
  800be1:	eb 01                	jmp    800be4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800be3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be4:	8a 01                	mov    (%ecx),%al
  800be6:	3c 20                	cmp    $0x20,%al
  800be8:	74 f9                	je     800be3 <strtol+0x11>
  800bea:	3c 09                	cmp    $0x9,%al
  800bec:	74 f5                	je     800be3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bee:	3c 2b                	cmp    $0x2b,%al
  800bf0:	75 0a                	jne    800bfc <strtol+0x2a>
		s++;
  800bf2:	41                   	inc    %ecx
  800bf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bfa:	eb 17                	jmp    800c13 <strtol+0x41>
	else if (*s == '-')
  800bfc:	3c 2d                	cmp    $0x2d,%al
  800bfe:	74 09                	je     800c09 <strtol+0x37>
  800c00:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c07:	eb 0a                	jmp    800c13 <strtol+0x41>
		s++, neg = 1;
  800c09:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c0c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c13:	85 f6                	test   %esi,%esi
  800c15:	74 05                	je     800c1c <strtol+0x4a>
  800c17:	83 fe 10             	cmp    $0x10,%esi
  800c1a:	75 1a                	jne    800c36 <strtol+0x64>
  800c1c:	8a 01                	mov    (%ecx),%al
  800c1e:	3c 30                	cmp    $0x30,%al
  800c20:	75 10                	jne    800c32 <strtol+0x60>
  800c22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c26:	75 0a                	jne    800c32 <strtol+0x60>
		s += 2, base = 16;
  800c28:	83 c1 02             	add    $0x2,%ecx
  800c2b:	be 10 00 00 00       	mov    $0x10,%esi
  800c30:	eb 04                	jmp    800c36 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800c32:	85 f6                	test   %esi,%esi
  800c34:	74 07                	je     800c3d <strtol+0x6b>
  800c36:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3b:	eb 13                	jmp    800c50 <strtol+0x7e>
  800c3d:	3c 30                	cmp    $0x30,%al
  800c3f:	74 07                	je     800c48 <strtol+0x76>
  800c41:	be 0a 00 00 00       	mov    $0xa,%esi
  800c46:	eb ee                	jmp    800c36 <strtol+0x64>
		s++, base = 8;
  800c48:	41                   	inc    %ecx
  800c49:	be 08 00 00 00       	mov    $0x8,%esi
  800c4e:	eb e6                	jmp    800c36 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c50:	8a 11                	mov    (%ecx),%dl
  800c52:	88 d3                	mov    %dl,%bl
  800c54:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c57:	3c 09                	cmp    $0x9,%al
  800c59:	77 08                	ja     800c63 <strtol+0x91>
			dig = *s - '0';
  800c5b:	0f be c2             	movsbl %dl,%eax
  800c5e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c61:	eb 1c                	jmp    800c7f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c63:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c66:	3c 19                	cmp    $0x19,%al
  800c68:	77 08                	ja     800c72 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c6a:	0f be c2             	movsbl %dl,%eax
  800c6d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c70:	eb 0d                	jmp    800c7f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c72:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c75:	3c 19                	cmp    $0x19,%al
  800c77:	77 15                	ja     800c8e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c79:	0f be c2             	movsbl %dl,%eax
  800c7c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c7f:	39 f2                	cmp    %esi,%edx
  800c81:	7d 0b                	jge    800c8e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c83:	41                   	inc    %ecx
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	0f af c6             	imul   %esi,%eax
  800c89:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c8c:	eb c2                	jmp    800c50 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c8e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c94:	74 05                	je     800c9b <strtol+0xc9>
		*endptr = (char *) s;
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c99:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c9f:	74 04                	je     800ca5 <strtol+0xd3>
  800ca1:	89 c7                	mov    %eax,%edi
  800ca3:	f7 df                	neg    %edi
}
  800ca5:	89 f8                	mov    %edi,%eax
  800ca7:	83 c4 04             	add    $0x4,%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    
	...

00800cb0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cb6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cbd:	75 64                	jne    800d23 <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  800cbf:	a1 04 20 80 00       	mov    0x802004,%eax
  800cc4:	8b 40 48             	mov    0x48(%eax),%eax
  800cc7:	83 ec 04             	sub    $0x4,%esp
  800cca:	6a 07                	push   $0x7
  800ccc:	68 00 f0 bf ee       	push   $0xeebff000
  800cd1:	50                   	push   %eax
  800cd2:	e8 d6 f5 ff ff       	call   8002ad <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	79 14                	jns    800cf2 <set_pgfault_handler+0x42>
  800cde:	83 ec 04             	sub    $0x4,%esp
  800ce1:	68 40 13 80 00       	push   $0x801340
  800ce6:	6a 22                	push   $0x22
  800ce8:	68 ac 13 80 00       	push   $0x8013ac
  800ced:	e8 a6 f6 ff ff       	call   800398 <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  800cf2:	a1 04 20 80 00       	mov    0x802004,%eax
  800cf7:	8b 40 48             	mov    0x48(%eax),%eax
  800cfa:	83 ec 08             	sub    $0x8,%esp
  800cfd:	68 70 03 80 00       	push   $0x800370
  800d02:	50                   	push   %eax
  800d03:	e8 5b f4 ff ff       	call   800163 <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	79 14                	jns    800d23 <set_pgfault_handler+0x73>
  800d0f:	83 ec 04             	sub    $0x4,%esp
  800d12:	68 70 13 80 00       	push   $0x801370
  800d17:	6a 25                	push   $0x25
  800d19:	68 ac 13 80 00       	push   $0x8013ac
  800d1e:	e8 75 f6 ff ff       	call   800398 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    
  800d2d:	00 00                	add    %al,(%eax)
	...

00800d30 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	83 ec 28             	sub    $0x28,%esp
  800d38:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800d3f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800d46:	8b 45 10             	mov    0x10(%ebp),%eax
  800d49:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d4f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800d51:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d5f:	85 ff                	test   %edi,%edi
  800d61:	75 21                	jne    800d84 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800d63:	39 d1                	cmp    %edx,%ecx
  800d65:	76 49                	jbe    800db0 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d67:	f7 f1                	div    %ecx
  800d69:	89 c1                	mov    %eax,%ecx
  800d6b:	31 c0                	xor    %eax,%eax
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d70:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800d73:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d76:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d79:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d7c:	83 c4 28             	add    $0x28,%esp
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    
  800d83:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d84:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d87:	0f 87 97 00 00 00    	ja     800e24 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d8d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d90:	83 f0 1f             	xor    $0x1f,%eax
  800d93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d96:	75 34                	jne    800dcc <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d98:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d9b:	72 08                	jb     800da5 <__udivdi3+0x75>
  800d9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800da0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800da3:	77 7f                	ja     800e24 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800da5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800daa:	31 c0                	xor    %eax,%eax
  800dac:	eb c2                	jmp    800d70 <__udivdi3+0x40>
  800dae:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db3:	85 c0                	test   %eax,%eax
  800db5:	74 79                	je     800e30 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800db7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800dba:	89 fa                	mov    %edi,%edx
  800dbc:	f7 f1                	div    %ecx
  800dbe:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dc3:	f7 f1                	div    %ecx
  800dc5:	89 c1                	mov    %eax,%ecx
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	eb a5                	jmp    800d70 <__udivdi3+0x40>
  800dcb:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd1:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dd7:	89 fa                	mov    %edi,%edx
  800dd9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ddc:	d3 e2                	shl    %cl,%edx
  800dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de1:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800de4:	d3 e8                	shr    %cl,%eax
  800de6:	89 d7                	mov    %edx,%edi
  800de8:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800dea:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800ded:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800df0:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800df5:	d3 e0                	shl    %cl,%eax
  800df7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800dfa:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800dfd:	d3 ea                	shr    %cl,%edx
  800dff:	09 d0                	or     %edx,%eax
  800e01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e04:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	f7 f7                	div    %edi
  800e0b:	89 d7                	mov    %edx,%edi
  800e0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e10:	f7 e6                	mul    %esi
  800e12:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e14:	39 d7                	cmp    %edx,%edi
  800e16:	72 38                	jb     800e50 <__udivdi3+0x120>
  800e18:	74 27                	je     800e41 <__udivdi3+0x111>
  800e1a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e1d:	31 c0                	xor    %eax,%eax
  800e1f:	e9 4c ff ff ff       	jmp    800d70 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e24:	31 c9                	xor    %ecx,%ecx
  800e26:	31 c0                	xor    %eax,%eax
  800e28:	e9 43 ff ff ff       	jmp    800d70 <__udivdi3+0x40>
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e30:	b8 01 00 00 00       	mov    $0x1,%eax
  800e35:	31 d2                	xor    %edx,%edx
  800e37:	f7 75 f4             	divl   -0xc(%ebp)
  800e3a:	89 c1                	mov    %eax,%ecx
  800e3c:	e9 76 ff ff ff       	jmp    800db7 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e44:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e47:	d3 e0                	shl    %cl,%eax
  800e49:	39 f0                	cmp    %esi,%eax
  800e4b:	73 cd                	jae    800e1a <__udivdi3+0xea>
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e50:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800e53:	49                   	dec    %ecx
  800e54:	31 c0                	xor    %eax,%eax
  800e56:	e9 15 ff ff ff       	jmp    800d70 <__udivdi3+0x40>
	...

00800e5c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	83 ec 30             	sub    $0x30,%esp
  800e64:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800e6b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e72:	8b 75 08             	mov    0x8(%ebp),%esi
  800e75:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e78:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800e7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e81:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800e83:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800e86:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800e89:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e8c:	85 d2                	test   %edx,%edx
  800e8e:	75 1c                	jne    800eac <__umoddi3+0x50>
    {
      if (d0 > n1)
  800e90:	89 fa                	mov    %edi,%edx
  800e92:	39 f8                	cmp    %edi,%eax
  800e94:	0f 86 c2 00 00 00    	jbe    800f5c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e9a:	89 f0                	mov    %esi,%eax
  800e9c:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e9e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800ea1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800ea8:	eb 12                	jmp    800ebc <__umoddi3+0x60>
  800eaa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800eaf:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800eb2:	76 18                	jbe    800ecc <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800eb4:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800eb7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800eba:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ebc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800ebf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ec2:	83 c4 30             	add    $0x30,%esp
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    
  800ec9:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ecc:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800ed0:	83 f0 1f             	xor    $0x1f,%eax
  800ed3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ed6:	0f 84 ac 00 00 00    	je     800f88 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800edc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee1:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800ee4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ee7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eea:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800eed:	d3 e2                	shl    %cl,%edx
  800eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef2:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	89 d6                	mov    %edx,%esi
  800ef9:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800efb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efe:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f01:	d3 e0                	shl    %cl,%eax
  800f03:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f06:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800f09:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f0e:	d3 e0                	shl    %cl,%eax
  800f10:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f13:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f16:	d3 ea                	shr    %cl,%edx
  800f18:	09 d0                	or     %edx,%eax
  800f1a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f1d:	d3 ea                	shr    %cl,%edx
  800f1f:	f7 f6                	div    %esi
  800f21:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800f24:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f27:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800f2a:	0f 82 8d 00 00 00    	jb     800fbd <__umoddi3+0x161>
  800f30:	0f 84 91 00 00 00    	je     800fc7 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f36:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f39:	29 c7                	sub    %eax,%edi
  800f3b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800f42:	d3 e2                	shl    %cl,%edx
  800f44:	89 f8                	mov    %edi,%eax
  800f46:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800f49:	d3 e8                	shr    %cl,%eax
  800f4b:	09 c2                	or     %eax,%edx
  800f4d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800f50:	d3 ee                	shr    %cl,%esi
  800f52:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800f55:	e9 62 ff ff ff       	jmp    800ebc <__umoddi3+0x60>
  800f5a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	74 15                	je     800f78 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f66:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f69:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6e:	f7 f1                	div    %ecx
  800f70:	e9 29 ff ff ff       	jmp    800e9e <__umoddi3+0x42>
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f78:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	f7 75 ec             	divl   -0x14(%ebp)
  800f82:	89 c1                	mov    %eax,%ecx
  800f84:	eb dd                	jmp    800f63 <__umoddi3+0x107>
  800f86:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f8b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800f8e:	72 19                	jb     800fa9 <__umoddi3+0x14d>
  800f90:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f93:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800f96:	76 11                	jbe    800fa9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f9b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f9e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800fa1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800fa4:	e9 13 ff ff ff       	jmp    800ebc <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fa9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800faf:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800fb2:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800fb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fb8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800fbb:	eb db                	jmp    800f98 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fbd:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800fc0:	19 f2                	sbb    %esi,%edx
  800fc2:	e9 6f ff ff ff       	jmp    800f36 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc7:	39 c7                	cmp    %eax,%edi
  800fc9:	72 f2                	jb     800fbd <__umoddi3+0x161>
  800fcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fce:	e9 63 ff ff ff       	jmp    800f36 <__umoddi3+0xda>
