
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
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
  800037:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	6a 07                	push   $0x7
  80003c:	68 00 f0 bf ee       	push   $0xeebff000
  800041:	6a 00                	push   $0x0
  800043:	e8 75 02 00 00       	call   8002bd <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800048:	83 c4 08             	add    $0x8,%esp
  80004b:	68 20 00 10 f0       	push   $0xf0100020
  800050:	6a 00                	push   $0x0
  800052:	e8 1c 01 00 00       	call   800173 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800057:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005e:	00 00 00 
  800061:	83 c4 10             	add    $0x10,%esp
}
  800064:	c9                   	leave  
  800065:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 75 08             	mov    0x8(%ebp),%esi
  800070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800073:	e8 a7 02 00 00       	call   80031f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	29 d0                	sub    %edx,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 f6                	test   %esi,%esi
  800095:	7e 07                	jle    80009e <libmain+0x36>
		binaryname = argv[0];
  800097:	8b 03                	mov    (%ebx),%eax
  800099:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	56                   	push   %esi
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 79 02 00 00       	call   80033e <sys_env_destroy>
  8000c5:	83 c4 10             	add    $0x10,%esp
}
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    
	...

008000cc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8000dc:	89 fa                	mov    %edi,%edx
  8000de:	89 f9                	mov    %edi,%ecx
  8000e0:	89 fb                	mov    %edi,%ebx
  8000e2:	89 fe                	mov    %edi,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 04             	sub    $0x4,%esp
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8000ff:	89 f8                	mov    %edi,%eax
  800101:	89 fb                	mov    %edi,%ebx
  800103:	89 fe                	mov    %edi,%esi
  800105:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800107:	83 c4 04             	add    $0x4,%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800120:	bf 00 00 00 00       	mov    $0x0,%edi
  800125:	89 f9                	mov    %edi,%ecx
  800127:	89 fb                	mov    %edi,%ebx
  800129:	89 fe                	mov    %edi,%esi
  80012b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7e 17                	jle    800148 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	50                   	push   %eax
  800135:	6a 0d                	push   $0xd
  800137:	68 4a 0f 80 00       	push   $0x800f4a
  80013c:	6a 23                	push   $0x23
  80013e:	68 67 0f 80 00       	push   $0x800f67
  800143:	e8 38 02 00 00       	call   800380 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	8b 55 08             	mov    0x8(%ebp),%edx
  800159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80015f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800162:	b8 0c 00 00 00       	mov    $0xc,%eax
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	b8 0a 00 00 00       	mov    $0xa,%eax
  800187:	bf 00 00 00 00       	mov    $0x0,%edi
  80018c:	89 fb                	mov    %edi,%ebx
  80018e:	89 fe                	mov    %edi,%esi
  800190:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7e 17                	jle    8001ad <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 0a                	push   $0xa
  80019c:	68 4a 0f 80 00       	push   $0x800f4a
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 67 0f 80 00       	push   $0x800f67
  8001a8:	e8 d3 01 00 00       	call   800380 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8001c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ce:	89 fb                	mov    %edi,%ebx
  8001d0:	89 fe                	mov    %edi,%esi
  8001d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7e 17                	jle    8001ef <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 09                	push   $0x9
  8001de:	68 4a 0f 80 00       	push   $0x800f4a
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 67 0f 80 00       	push   $0x800f67
  8001ea:	e8 91 01 00 00       	call   800380 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800206:	b8 08 00 00 00       	mov    $0x8,%eax
  80020b:	bf 00 00 00 00       	mov    $0x0,%edi
  800210:	89 fb                	mov    %edi,%ebx
  800212:	89 fe                	mov    %edi,%esi
  800214:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 17                	jle    800231 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 08                	push   $0x8
  800220:	68 4a 0f 80 00       	push   $0x800f4a
  800225:	6a 23                	push   $0x23
  800227:	68 67 0f 80 00       	push   $0x800f67
  80022c:	e8 4f 01 00 00       	call   800380 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800248:	b8 06 00 00 00       	mov    $0x6,%eax
  80024d:	bf 00 00 00 00       	mov    $0x0,%edi
  800252:	89 fb                	mov    %edi,%ebx
  800254:	89 fe                	mov    %edi,%esi
  800256:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 17                	jle    800273 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 06                	push   $0x6
  800262:	68 4a 0f 80 00       	push   $0x800f4a
  800267:	6a 23                	push   $0x23
  800269:	68 67 0f 80 00       	push   $0x800f67
  80026e:	e8 0d 01 00 00       	call   800380 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80028d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800290:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	b8 05 00 00 00       	mov    $0x5,%eax
  800298:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 17                	jle    8002b5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 05                	push   $0x5
  8002a4:	68 4a 0f 80 00       	push   $0x800f4a
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 67 0f 80 00       	push   $0x800f67
  8002b0:	e8 cb 00 00 00       	call   800380 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8002d4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002d9:	89 fe                	mov    %edi,%esi
  8002db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	7e 17                	jle    8002f8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 04                	push   $0x4
  8002e7:	68 4a 0f 80 00       	push   $0x800f4a
  8002ec:	6a 23                	push   $0x23
  8002ee:	68 67 0f 80 00       	push   $0x800f67
  8002f3:	e8 88 00 00 00       	call   800380 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	b8 0b 00 00 00       	mov    $0xb,%eax
  80030b:	bf 00 00 00 00       	mov    $0x0,%edi
  800310:	89 fa                	mov    %edi,%edx
  800312:	89 f9                	mov    %edi,%ecx
  800314:	89 fb                	mov    %edi,%ebx
  800316:	89 fe                	mov    %edi,%esi
  800318:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    

0080031f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	57                   	push   %edi
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800325:	b8 02 00 00 00       	mov    $0x2,%eax
  80032a:	bf 00 00 00 00       	mov    $0x0,%edi
  80032f:	89 fa                	mov    %edi,%edx
  800331:	89 f9                	mov    %edi,%ecx
  800333:	89 fb                	mov    %edi,%ebx
  800335:	89 fe                	mov    %edi,%esi
  800337:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034a:	b8 03 00 00 00       	mov    $0x3,%eax
  80034f:	bf 00 00 00 00       	mov    $0x0,%edi
  800354:	89 f9                	mov    %edi,%ecx
  800356:	89 fb                	mov    %edi,%ebx
  800358:	89 fe                	mov    %edi,%esi
  80035a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80035c:	85 c0                	test   %eax,%eax
  80035e:	7e 17                	jle    800377 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	50                   	push   %eax
  800364:	6a 03                	push   $0x3
  800366:	68 4a 0f 80 00       	push   $0x800f4a
  80036b:	6a 23                	push   $0x23
  80036d:	68 67 0f 80 00       	push   $0x800f67
  800372:	e8 09 00 00 00       	call   800380 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    
	...

00800380 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	53                   	push   %ebx
  800384:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
  80038a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800393:	e8 87 ff ff ff       	call   80031f <sys_getenvid>
  800398:	83 ec 0c             	sub    $0xc,%esp
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	53                   	push   %ebx
  8003a2:	50                   	push   %eax
  8003a3:	68 78 0f 80 00       	push   $0x800f78
  8003a8:	e8 74 00 00 00       	call   800421 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ad:	83 c4 18             	add    $0x18,%esp
  8003b0:	ff 75 f8             	pushl  -0x8(%ebp)
  8003b3:	ff 75 10             	pushl  0x10(%ebp)
  8003b6:	e8 15 00 00 00       	call   8003d0 <vcprintf>
	cprintf("\n");
  8003bb:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  8003c2:	e8 5a 00 00 00       	call   800421 <cprintf>
  8003c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ca:	cc                   	int3   
  8003cb:	eb fd                	jmp    8003ca <_panic+0x4a>
  8003cd:	00 00                	add    %al,(%eax)
	...

008003d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d9:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003e0:	00 00 00 
	b.cnt = 0;
  8003e3:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ed:	ff 75 0c             	pushl  0xc(%ebp)
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f9:	50                   	push   %eax
  8003fa:	68 38 04 80 00       	push   $0x800438
  8003ff:	e8 70 01 00 00       	call   800574 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	83 c4 08             	add    $0x8,%esp
  800407:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  80040d:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  800413:	50                   	push   %eax
  800414:	e8 d2 fc ff ff       	call   8000eb <sys_cputs>
  800419:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800427:	8d 45 0c             	lea    0xc(%ebp),%eax
  80042a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80042d:	50                   	push   %eax
  80042e:	ff 75 08             	pushl  0x8(%ebp)
  800431:	e8 9a ff ff ff       	call   8003d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800436:	c9                   	leave  
  800437:	c3                   	ret    

00800438 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	53                   	push   %ebx
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800442:	8b 03                	mov    (%ebx),%eax
  800444:	8b 55 08             	mov    0x8(%ebp),%edx
  800447:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80044b:	40                   	inc    %eax
  80044c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80044e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800453:	75 1a                	jne    80046f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	68 ff 00 00 00       	push   $0xff
  80045d:	8d 43 08             	lea    0x8(%ebx),%eax
  800460:	50                   	push   %eax
  800461:	e8 85 fc ff ff       	call   8000eb <sys_cputs>
		b->idx = 0;
  800466:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80046c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80046f:	ff 43 04             	incl   0x4(%ebx)
}
  800472:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800475:	c9                   	leave  
  800476:	c3                   	ret    
	...

00800478 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	57                   	push   %edi
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 1c             	sub    $0x1c,%esp
  800481:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800484:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800493:	8b 55 10             	mov    0x10(%ebp),%edx
  800496:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800499:	89 d6                	mov    %edx,%esi
  80049b:	bf 00 00 00 00       	mov    $0x0,%edi
  8004a0:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8004a3:	72 04                	jb     8004a9 <printnum+0x31>
  8004a5:	39 c2                	cmp    %eax,%edx
  8004a7:	77 3f                	ja     8004e8 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004a9:	83 ec 0c             	sub    $0xc,%esp
  8004ac:	ff 75 18             	pushl  0x18(%ebp)
  8004af:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8004b2:	50                   	push   %eax
  8004b3:	52                   	push   %edx
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	57                   	push   %edi
  8004b8:	56                   	push   %esi
  8004b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bf:	e8 d4 07 00 00       	call   800c98 <__udivdi3>
  8004c4:	83 c4 18             	add    $0x18,%esp
  8004c7:	52                   	push   %edx
  8004c8:	50                   	push   %eax
  8004c9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004cf:	e8 a4 ff ff ff       	call   800478 <printnum>
  8004d4:	83 c4 20             	add    $0x20,%esp
  8004d7:	eb 14                	jmp    8004ed <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 e8             	pushl  -0x18(%ebp)
  8004df:	ff 75 18             	pushl  0x18(%ebp)
  8004e2:	ff 55 ec             	call   *-0x14(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004e8:	4b                   	dec    %ebx
  8004e9:	85 db                	test   %ebx,%ebx
  8004eb:	7f ec                	jg     8004d9 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 e8             	pushl  -0x18(%ebp)
  8004f3:	83 ec 04             	sub    $0x4,%esp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	e8 c1 08 00 00       	call   800dc4 <__umoddi3>
  800503:	83 c4 14             	add    $0x14,%esp
  800506:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  80050d:	50                   	push   %eax
  80050e:	ff 55 ec             	call   *-0x14(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800517:	5b                   	pop    %ebx
  800518:	5e                   	pop    %esi
  800519:	5f                   	pop    %edi
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800521:	83 fa 01             	cmp    $0x1,%edx
  800524:	7e 0e                	jle    800534 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800526:	8b 10                	mov    (%eax),%edx
  800528:	8d 42 08             	lea    0x8(%edx),%eax
  80052b:	89 01                	mov    %eax,(%ecx)
  80052d:	8b 02                	mov    (%edx),%eax
  80052f:	8b 52 04             	mov    0x4(%edx),%edx
  800532:	eb 22                	jmp    800556 <getuint+0x3a>
	else if (lflag)
  800534:	85 d2                	test   %edx,%edx
  800536:	74 10                	je     800548 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800538:	8b 10                	mov    (%eax),%edx
  80053a:	8d 42 04             	lea    0x4(%edx),%eax
  80053d:	89 01                	mov    %eax,(%ecx)
  80053f:	8b 02                	mov    (%edx),%eax
  800541:	ba 00 00 00 00       	mov    $0x0,%edx
  800546:	eb 0e                	jmp    800556 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800548:	8b 10                	mov    (%eax),%edx
  80054a:	8d 42 04             	lea    0x4(%edx),%eax
  80054d:	89 01                	mov    %eax,(%ecx)
  80054f:	8b 02                	mov    (%edx),%eax
  800551:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800556:	c9                   	leave  
  800557:	c3                   	ret    

00800558 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80055e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800561:	8b 11                	mov    (%ecx),%edx
  800563:	3b 51 04             	cmp    0x4(%ecx),%edx
  800566:	73 0a                	jae    800572 <sprintputch+0x1a>
		*b->buf++ = ch;
  800568:	8b 45 08             	mov    0x8(%ebp),%eax
  80056b:	88 02                	mov    %al,(%edx)
  80056d:	8d 42 01             	lea    0x1(%edx),%eax
  800570:	89 01                	mov    %eax,(%ecx)
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 3c             	sub    $0x3c,%esp
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800586:	eb 1a                	jmp    8005a2 <vprintfmt+0x2e>
  800588:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80058b:	eb 15                	jmp    8005a2 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80058d:	84 c0                	test   %al,%al
  80058f:	0f 84 15 03 00 00    	je     8008aa <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	0f b6 c0             	movzbl %al,%eax
  80059c:	50                   	push   %eax
  80059d:	ff d6                	call   *%esi
  80059f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a2:	8a 03                	mov    (%ebx),%al
  8005a4:	43                   	inc    %ebx
  8005a5:	3c 25                	cmp    $0x25,%al
  8005a7:	75 e4                	jne    80058d <vprintfmt+0x19>
  8005a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005b7:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005be:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005c5:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005c9:	eb 0a                	jmp    8005d5 <vprintfmt+0x61>
  8005cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005d2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8a 03                	mov    (%ebx),%al
  8005d7:	0f b6 d0             	movzbl %al,%edx
  8005da:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005dd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005e0:	83 e8 23             	sub    $0x23,%eax
  8005e3:	3c 55                	cmp    $0x55,%al
  8005e5:	0f 87 9c 02 00 00    	ja     800887 <vprintfmt+0x313>
  8005eb:	0f b6 c0             	movzbl %al,%eax
  8005ee:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005f5:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005f9:	eb d7                	jmp    8005d2 <vprintfmt+0x5e>
  8005fb:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005ff:	eb d1                	jmp    8005d2 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  800601:	89 d9                	mov    %ebx,%ecx
  800603:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80060a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80060d:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800610:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800614:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800617:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  80061b:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  80061c:	8d 42 d0             	lea    -0x30(%edx),%eax
  80061f:	83 f8 09             	cmp    $0x9,%eax
  800622:	77 21                	ja     800645 <vprintfmt+0xd1>
  800624:	eb e4                	jmp    80060a <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800626:	8b 55 14             	mov    0x14(%ebp),%edx
  800629:	8d 42 04             	lea    0x4(%edx),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
  80062f:	8b 12                	mov    (%edx),%edx
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	eb 12                	jmp    800648 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800636:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063a:	79 96                	jns    8005d2 <vprintfmt+0x5e>
  80063c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800643:	eb 8d                	jmp    8005d2 <vprintfmt+0x5e>
  800645:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800648:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064c:	79 84                	jns    8005d2 <vprintfmt+0x5e>
  80064e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80065b:	e9 72 ff ff ff       	jmp    8005d2 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800660:	ff 45 d4             	incl   -0x2c(%ebp)
  800663:	e9 6a ff ff ff       	jmp    8005d2 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800668:	8b 55 14             	mov    0x14(%ebp),%edx
  80066b:	8d 42 04             	lea    0x4(%edx),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	57                   	push   %edi
  800675:	ff 32                	pushl  (%edx)
  800677:	ff d6                	call   *%esi
			break;
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	e9 07 ff ff ff       	jmp    800588 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800681:	8b 55 14             	mov    0x14(%ebp),%edx
  800684:	8d 42 04             	lea    0x4(%edx),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
  80068a:	8b 02                	mov    (%edx),%eax
  80068c:	85 c0                	test   %eax,%eax
  80068e:	79 02                	jns    800692 <vprintfmt+0x11e>
  800690:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800692:	83 f8 0f             	cmp    $0xf,%eax
  800695:	7f 0b                	jg     8006a2 <vprintfmt+0x12e>
  800697:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	75 15                	jne    8006b7 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8006a2:	50                   	push   %eax
  8006a3:	68 ae 0f 80 00       	push   $0x800fae
  8006a8:	57                   	push   %edi
  8006a9:	56                   	push   %esi
  8006aa:	e8 6e 02 00 00       	call   80091d <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	e9 d1 fe ff ff       	jmp    800588 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006b7:	52                   	push   %edx
  8006b8:	68 b7 0f 80 00       	push   $0x800fb7
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	e8 59 02 00 00       	call   80091d <printfmt>
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	e9 bc fe ff ff       	jmp    800588 <vprintfmt+0x14>
  8006cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006cf:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d5:	8b 55 14             	mov    0x14(%ebp),%edx
  8006d8:	8d 42 04             	lea    0x4(%edx),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
  8006de:	8b 1a                	mov    (%edx),%ebx
  8006e0:	85 db                	test   %ebx,%ebx
  8006e2:	75 05                	jne    8006e9 <vprintfmt+0x175>
  8006e4:	bb ba 0f 80 00       	mov    $0x800fba,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006ed:	7e 66                	jle    800755 <vprintfmt+0x1e1>
  8006ef:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006f3:	74 60                	je     800755 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	51                   	push   %ecx
  8006f9:	53                   	push   %ebx
  8006fa:	e8 57 02 00 00       	call   800956 <strnlen>
  8006ff:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800702:	29 c1                	sub    %eax,%ecx
  800704:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80070e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800711:	eb 0f                	jmp    800722 <vprintfmt+0x1ae>
					putch(padc, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	57                   	push   %edi
  800717:	ff 75 c4             	pushl  -0x3c(%ebp)
  80071a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80071c:	ff 4d d8             	decl   -0x28(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800726:	7f eb                	jg     800713 <vprintfmt+0x19f>
  800728:	eb 2b                	jmp    800755 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072a:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  80072d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800731:	74 15                	je     800748 <vprintfmt+0x1d4>
  800733:	8d 42 e0             	lea    -0x20(%edx),%eax
  800736:	83 f8 5e             	cmp    $0x5e,%eax
  800739:	76 0d                	jbe    800748 <vprintfmt+0x1d4>
					putch('?', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	57                   	push   %edi
  80073f:	6a 3f                	push   $0x3f
  800741:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb 0a                	jmp    800752 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	57                   	push   %edi
  80074c:	52                   	push   %edx
  80074d:	ff d6                	call   *%esi
  80074f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	ff 4d d8             	decl   -0x28(%ebp)
  800755:	8a 03                	mov    (%ebx),%al
  800757:	43                   	inc    %ebx
  800758:	84 c0                	test   %al,%al
  80075a:	74 1b                	je     800777 <vprintfmt+0x203>
  80075c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800760:	78 c8                	js     80072a <vprintfmt+0x1b6>
  800762:	ff 4d dc             	decl   -0x24(%ebp)
  800765:	79 c3                	jns    80072a <vprintfmt+0x1b6>
  800767:	eb 0e                	jmp    800777 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	57                   	push   %edi
  80076d:	6a 20                	push   $0x20
  80076f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800771:	ff 4d d8             	decl   -0x28(%ebp)
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077b:	7f ec                	jg     800769 <vprintfmt+0x1f5>
  80077d:	e9 06 fe ff ff       	jmp    800588 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800782:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800786:	7e 10                	jle    800798 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800788:	8b 55 14             	mov    0x14(%ebp),%edx
  80078b:	8d 42 08             	lea    0x8(%edx),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
  800791:	8b 02                	mov    (%edx),%eax
  800793:	8b 52 04             	mov    0x4(%edx),%edx
  800796:	eb 20                	jmp    8007b8 <vprintfmt+0x244>
	else if (lflag)
  800798:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80079c:	74 0e                	je     8007ac <vprintfmt+0x238>
		return va_arg(*ap, long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a7:	8b 00                	mov    (%eax),%eax
  8007a9:	99                   	cltd   
  8007aa:	eb 0c                	jmp    8007b8 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 50 04             	lea    0x4(%eax),%edx
  8007b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b8:	89 d1                	mov    %edx,%ecx
  8007ba:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8007bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007c2:	85 c9                	test   %ecx,%ecx
  8007c4:	78 0a                	js     8007d0 <vprintfmt+0x25c>
  8007c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007cb:	e9 89 00 00 00       	jmp    800859 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	57                   	push   %edi
  8007d4:	6a 2d                	push   $0x2d
  8007d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007d8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007db:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007de:	f7 da                	neg    %edx
  8007e0:	83 d1 00             	adc    $0x0,%ecx
  8007e3:	f7 d9                	neg    %ecx
  8007e5:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	eb 6a                	jmp    800859 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f5:	e8 22 fd ff ff       	call   80051c <getuint>
  8007fa:	89 d1                	mov    %edx,%ecx
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800803:	eb 54                	jmp    800859 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800805:	8d 45 14             	lea    0x14(%ebp),%eax
  800808:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80080b:	e8 0c fd ff ff       	call   80051c <getuint>
  800810:	89 d1                	mov    %edx,%ecx
  800812:	89 c2                	mov    %eax,%edx
  800814:	bb 08 00 00 00       	mov    $0x8,%ebx
  800819:	eb 3e                	jmp    800859 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	57                   	push   %edi
  80081f:	6a 30                	push   $0x30
  800821:	ff d6                	call   *%esi
			putch('x', putdat);
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	57                   	push   %edi
  800827:	6a 78                	push   $0x78
  800829:	ff d6                	call   *%esi
			num = (unsigned long long)
  80082b:	8b 55 14             	mov    0x14(%ebp),%edx
  80082e:	8d 42 04             	lea    0x4(%edx),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
  800834:	8b 12                	mov    (%edx),%edx
  800836:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	eb 14                	jmp    800859 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80084b:	e8 cc fc ff ff       	call   80051c <getuint>
  800850:	89 d1                	mov    %edx,%ecx
  800852:	89 c2                	mov    %eax,%edx
  800854:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800859:	83 ec 0c             	sub    $0xc,%esp
  80085c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	ff 75 d8             	pushl  -0x28(%ebp)
  800864:	53                   	push   %ebx
  800865:	51                   	push   %ecx
  800866:	52                   	push   %edx
  800867:	89 fa                	mov    %edi,%edx
  800869:	89 f0                	mov    %esi,%eax
  80086b:	e8 08 fc ff ff       	call   800478 <printnum>
			break;
  800870:	83 c4 20             	add    $0x20,%esp
  800873:	e9 10 fd ff ff       	jmp    800588 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	57                   	push   %edi
  80087c:	52                   	push   %edx
  80087d:	ff d6                	call   *%esi
			break;
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	e9 01 fd ff ff       	jmp    800588 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	57                   	push   %edi
  80088b:	6a 25                	push   $0x25
  80088d:	ff d6                	call   *%esi
  80088f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800892:	83 ea 02             	sub    $0x2,%edx
  800895:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800898:	8a 02                	mov    (%edx),%al
  80089a:	4a                   	dec    %edx
  80089b:	3c 25                	cmp    $0x25,%al
  80089d:	75 f9                	jne    800898 <vprintfmt+0x324>
  80089f:	83 c2 02             	add    $0x2,%edx
  8008a2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8008a5:	e9 de fc ff ff       	jmp    800588 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  8008aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5f                   	pop    %edi
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 18             	sub    $0x18,%esp
  8008b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	74 37                	je     8008f9 <vsnprintf+0x47>
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	7e 33                	jle    8008f9 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008cd:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008d4:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d7:	ff 75 14             	pushl  0x14(%ebp)
  8008da:	ff 75 10             	pushl  0x10(%ebp)
  8008dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e0:	50                   	push   %eax
  8008e1:	68 58 05 80 00       	push   $0x800558
  8008e6:	e8 89 fc ff ff       	call   800574 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ee:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	eb 05                	jmp    8008fe <vsnprintf+0x4c>
  8008f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
  800909:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80090c:	50                   	push   %eax
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	ff 75 0c             	pushl  0xc(%ebp)
  800913:	ff 75 08             	pushl  0x8(%ebp)
  800916:	e8 97 ff ff ff       	call   8008b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
  800926:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800929:	50                   	push   %eax
  80092a:	ff 75 10             	pushl  0x10(%ebp)
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 3c fc ff ff       	call   800574 <vprintfmt>
	va_end(ap);
  800938:	83 c4 10             	add    $0x10,%esp
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    
  80093d:	00 00                	add    %al,(%eax)
	...

00800940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb 01                	jmp    80094e <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  80094d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800952:	75 f9                	jne    80094d <strlen+0xd>
		n++;
	return n;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
  800964:	eb 01                	jmp    800967 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800966:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	39 d0                	cmp    %edx,%eax
  800969:	74 06                	je     800971 <strnlen+0x1b>
  80096b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80096f:	75 f5                	jne    800966 <strnlen+0x10>
		n++;
	return n;
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800979:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097c:	8a 01                	mov    (%ecx),%al
  80097e:	88 02                	mov    %al,(%edx)
  800980:	42                   	inc    %edx
  800981:	41                   	inc    %ecx
  800982:	84 c0                	test   %al,%al
  800984:	75 f6                	jne    80097c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800992:	53                   	push   %ebx
  800993:	e8 a8 ff ff ff       	call   800940 <strlen>
	strcpy(dst + len, src);
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80099e:	50                   	push   %eax
  80099f:	e8 cf ff ff ff       	call   800973 <strcpy>
	return dst;
}
  8009a4:	89 d8                	mov    %ebx,%eax
  8009a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009be:	eb 0c                	jmp    8009cc <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009c0:	8a 02                	mov    (%edx),%al
  8009c2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cb:	41                   	inc    %ecx
  8009cc:	39 d9                	cmp    %ebx,%ecx
  8009ce:	75 f0                	jne    8009c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	89 f0                	mov    %esi,%eax
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 75 08             	mov    0x8(%ebp),%esi
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	75 04                	jne    8009ec <strlcpy+0x16>
  8009e8:	89 f0                	mov    %esi,%eax
  8009ea:	eb 14                	jmp    800a00 <strlcpy+0x2a>
  8009ec:	89 f0                	mov    %esi,%eax
  8009ee:	eb 04                	jmp    8009f4 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f0:	88 10                	mov    %dl,(%eax)
  8009f2:	40                   	inc    %eax
  8009f3:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f4:	49                   	dec    %ecx
  8009f5:	74 06                	je     8009fd <strlcpy+0x27>
  8009f7:	8a 13                	mov    (%ebx),%dl
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	75 f3                	jne    8009f0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009fd:	c6 00 00             	movb   $0x0,(%eax)
  800a00:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0f:	eb 02                	jmp    800a13 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800a11:	42                   	inc    %edx
  800a12:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a13:	8a 02                	mov    (%edx),%al
  800a15:	84 c0                	test   %al,%al
  800a17:	74 04                	je     800a1d <strcmp+0x17>
  800a19:	3a 01                	cmp    (%ecx),%al
  800a1b:	74 f4                	je     800a11 <strcmp+0xb>
  800a1d:	0f b6 c0             	movzbl %al,%eax
  800a20:	0f b6 11             	movzbl (%ecx),%edx
  800a23:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a31:	8b 55 10             	mov    0x10(%ebp),%edx
  800a34:	eb 03                	jmp    800a39 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a36:	4a                   	dec    %edx
  800a37:	41                   	inc    %ecx
  800a38:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a39:	85 d2                	test   %edx,%edx
  800a3b:	75 07                	jne    800a44 <strncmp+0x1d>
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	eb 14                	jmp    800a58 <strncmp+0x31>
  800a44:	8a 01                	mov    (%ecx),%al
  800a46:	84 c0                	test   %al,%al
  800a48:	74 04                	je     800a4e <strncmp+0x27>
  800a4a:	3a 03                	cmp    (%ebx),%al
  800a4c:	74 e8                	je     800a36 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4e:	0f b6 d0             	movzbl %al,%edx
  800a51:	0f b6 03             	movzbl (%ebx),%eax
  800a54:	29 c2                	sub    %eax,%edx
  800a56:	89 d0                	mov    %edx,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a64:	eb 05                	jmp    800a6b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	74 0c                	je     800a76 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	40                   	inc    %eax
  800a6b:	8a 10                	mov    (%eax),%dl
  800a6d:	84 d2                	test   %dl,%dl
  800a6f:	75 f5                	jne    800a66 <strchr+0xb>
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a81:	eb 05                	jmp    800a88 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a83:	38 ca                	cmp    %cl,%dl
  800a85:	74 07                	je     800a8e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a87:	40                   	inc    %eax
  800a88:	8a 10                	mov    (%eax),%dl
  800a8a:	84 d2                	test   %dl,%dl
  800a8c:	75 f5                	jne    800a83 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
  800a96:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	74 36                	je     800ad9 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa9:	75 29                	jne    800ad4 <memset+0x44>
  800aab:	f6 c3 03             	test   $0x3,%bl
  800aae:	75 24                	jne    800ad4 <memset+0x44>
		c &= 0xFF;
  800ab0:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab3:	89 d6                	mov    %edx,%esi
  800ab5:	c1 e6 08             	shl    $0x8,%esi
  800ab8:	89 d0                	mov    %edx,%eax
  800aba:	c1 e0 18             	shl    $0x18,%eax
  800abd:	89 d1                	mov    %edx,%ecx
  800abf:	c1 e1 10             	shl    $0x10,%ecx
  800ac2:	09 c8                	or     %ecx,%eax
  800ac4:	09 c2                	or     %eax,%edx
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	09 d0                	or     %edx,%eax
  800aca:	89 d9                	mov    %ebx,%ecx
  800acc:	c1 e9 02             	shr    $0x2,%ecx
  800acf:	fc                   	cld    
  800ad0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad2:	eb 05                	jmp    800ad9 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad4:	89 d9                	mov    %ebx,%ecx
  800ad6:	fc                   	cld    
  800ad7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad9:	89 f8                	mov    %edi,%eax
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aee:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800af0:	39 c6                	cmp    %eax,%esi
  800af2:	73 36                	jae    800b2a <memmove+0x4a>
  800af4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af7:	39 d0                	cmp    %edx,%eax
  800af9:	73 2f                	jae    800b2a <memmove+0x4a>
		s += n;
		d += n;
  800afb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afe:	f6 c2 03             	test   $0x3,%dl
  800b01:	75 1b                	jne    800b1e <memmove+0x3e>
  800b03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b09:	75 13                	jne    800b1e <memmove+0x3e>
  800b0b:	f6 c1 03             	test   $0x3,%cl
  800b0e:	75 0e                	jne    800b1e <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800b10:	8d 7e fc             	lea    -0x4(%esi),%edi
  800b13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b16:	c1 e9 02             	shr    $0x2,%ecx
  800b19:	fd                   	std    
  800b1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1c:	eb 09                	jmp    800b27 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1e:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b21:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b24:	fd                   	std    
  800b25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b27:	fc                   	cld    
  800b28:	eb 20                	jmp    800b4a <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b30:	75 15                	jne    800b47 <memmove+0x67>
  800b32:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b38:	75 0d                	jne    800b47 <memmove+0x67>
  800b3a:	f6 c1 03             	test   $0x3,%cl
  800b3d:	75 08                	jne    800b47 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
  800b42:	fc                   	cld    
  800b43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b45:	eb 03                	jmp    800b4a <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b47:	fc                   	cld    
  800b48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b51:	ff 75 10             	pushl  0x10(%ebp)
  800b54:	ff 75 0c             	pushl  0xc(%ebp)
  800b57:	ff 75 08             	pushl  0x8(%ebp)
  800b5a:	e8 81 ff ff ff       	call   800ae0 <memmove>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	53                   	push   %ebx
  800b65:	83 ec 04             	sub    $0x4,%esp
  800b68:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	eb 1b                	jmp    800b8e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b73:	8a 1a                	mov    (%edx),%bl
  800b75:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b78:	8a 19                	mov    (%ecx),%bl
  800b7a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b7d:	74 0d                	je     800b8c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b7f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b83:	0f b6 c3             	movzbl %bl,%eax
  800b86:	29 c2                	sub    %eax,%edx
  800b88:	89 d0                	mov    %edx,%eax
  800b8a:	eb 0d                	jmp    800b99 <memcmp+0x38>
		s1++, s2++;
  800b8c:	42                   	inc    %edx
  800b8d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8e:	48                   	dec    %eax
  800b8f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b92:	75 df                	jne    800b73 <memcmp+0x12>
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b99:	83 c4 04             	add    $0x4,%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba8:	89 c2                	mov    %eax,%edx
  800baa:	03 55 10             	add    0x10(%ebp),%edx
  800bad:	eb 05                	jmp    800bb4 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800baf:	38 08                	cmp    %cl,(%eax)
  800bb1:	74 05                	je     800bb8 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb3:	40                   	inc    %eax
  800bb4:	39 d0                	cmp    %edx,%eax
  800bb6:	72 f7                	jb     800baf <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 04             	sub    $0x4,%esp
  800bc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc6:	8b 75 10             	mov    0x10(%ebp),%esi
  800bc9:	eb 01                	jmp    800bcc <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bcb:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcc:	8a 01                	mov    (%ecx),%al
  800bce:	3c 20                	cmp    $0x20,%al
  800bd0:	74 f9                	je     800bcb <strtol+0x11>
  800bd2:	3c 09                	cmp    $0x9,%al
  800bd4:	74 f5                	je     800bcb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd6:	3c 2b                	cmp    $0x2b,%al
  800bd8:	75 0a                	jne    800be4 <strtol+0x2a>
		s++;
  800bda:	41                   	inc    %ecx
  800bdb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800be2:	eb 17                	jmp    800bfb <strtol+0x41>
	else if (*s == '-')
  800be4:	3c 2d                	cmp    $0x2d,%al
  800be6:	74 09                	je     800bf1 <strtol+0x37>
  800be8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bef:	eb 0a                	jmp    800bfb <strtol+0x41>
		s++, neg = 1;
  800bf1:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bf4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfb:	85 f6                	test   %esi,%esi
  800bfd:	74 05                	je     800c04 <strtol+0x4a>
  800bff:	83 fe 10             	cmp    $0x10,%esi
  800c02:	75 1a                	jne    800c1e <strtol+0x64>
  800c04:	8a 01                	mov    (%ecx),%al
  800c06:	3c 30                	cmp    $0x30,%al
  800c08:	75 10                	jne    800c1a <strtol+0x60>
  800c0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0e:	75 0a                	jne    800c1a <strtol+0x60>
		s += 2, base = 16;
  800c10:	83 c1 02             	add    $0x2,%ecx
  800c13:	be 10 00 00 00       	mov    $0x10,%esi
  800c18:	eb 04                	jmp    800c1e <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800c1a:	85 f6                	test   %esi,%esi
  800c1c:	74 07                	je     800c25 <strtol+0x6b>
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c23:	eb 13                	jmp    800c38 <strtol+0x7e>
  800c25:	3c 30                	cmp    $0x30,%al
  800c27:	74 07                	je     800c30 <strtol+0x76>
  800c29:	be 0a 00 00 00       	mov    $0xa,%esi
  800c2e:	eb ee                	jmp    800c1e <strtol+0x64>
		s++, base = 8;
  800c30:	41                   	inc    %ecx
  800c31:	be 08 00 00 00       	mov    $0x8,%esi
  800c36:	eb e6                	jmp    800c1e <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c38:	8a 11                	mov    (%ecx),%dl
  800c3a:	88 d3                	mov    %dl,%bl
  800c3c:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c3f:	3c 09                	cmp    $0x9,%al
  800c41:	77 08                	ja     800c4b <strtol+0x91>
			dig = *s - '0';
  800c43:	0f be c2             	movsbl %dl,%eax
  800c46:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c49:	eb 1c                	jmp    800c67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c4b:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c4e:	3c 19                	cmp    $0x19,%al
  800c50:	77 08                	ja     800c5a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c52:	0f be c2             	movsbl %dl,%eax
  800c55:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c58:	eb 0d                	jmp    800c67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c5a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c5d:	3c 19                	cmp    $0x19,%al
  800c5f:	77 15                	ja     800c76 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c61:	0f be c2             	movsbl %dl,%eax
  800c64:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c67:	39 f2                	cmp    %esi,%edx
  800c69:	7d 0b                	jge    800c76 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c6b:	41                   	inc    %ecx
  800c6c:	89 f8                	mov    %edi,%eax
  800c6e:	0f af c6             	imul   %esi,%eax
  800c71:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c74:	eb c2                	jmp    800c38 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c76:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7c:	74 05                	je     800c83 <strtol+0xc9>
		*endptr = (char *) s;
  800c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c81:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c87:	74 04                	je     800c8d <strtol+0xd3>
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	f7 df                	neg    %edi
}
  800c8d:	89 f8                	mov    %edi,%eax
  800c8f:	83 c4 04             	add    $0x4,%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    
	...

00800c98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	83 ec 28             	sub    $0x28,%esp
  800ca0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ca7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb1:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800cb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cb7:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800cb9:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc4:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cc7:	85 ff                	test   %edi,%edi
  800cc9:	75 21                	jne    800cec <__udivdi3+0x54>
    {
      if (d0 > n1)
  800ccb:	39 d1                	cmp    %edx,%ecx
  800ccd:	76 49                	jbe    800d18 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ccf:	f7 f1                	div    %ecx
  800cd1:	89 c1                	mov    %eax,%ecx
  800cd3:	31 c0                	xor    %eax,%eax
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cd8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cdb:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cde:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ce1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ce4:	83 c4 28             	add    $0x28,%esp
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    
  800ceb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cec:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cef:	0f 87 97 00 00 00    	ja     800d8c <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cf5:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cf8:	83 f0 1f             	xor    $0x1f,%eax
  800cfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cfe:	75 34                	jne    800d34 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d00:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800d03:	72 08                	jb     800d0d <__udivdi3+0x75>
  800d05:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d08:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d0b:	77 7f                	ja     800d8c <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800d0d:	b9 01 00 00 00       	mov    $0x1,%ecx
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	eb c2                	jmp    800cd8 <__udivdi3+0x40>
  800d16:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	74 79                	je     800d98 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d22:	89 fa                	mov    %edi,%edx
  800d24:	f7 f1                	div    %ecx
  800d26:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 c1                	mov    %eax,%ecx
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	eb a5                	jmp    800cd8 <__udivdi3+0x40>
  800d33:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d34:	b8 20 00 00 00       	mov    $0x20,%eax
  800d39:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d3f:	89 fa                	mov    %edi,%edx
  800d41:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d44:	d3 e2                	shl    %cl,%edx
  800d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d49:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d4c:	d3 e8                	shr    %cl,%eax
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d52:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d55:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d58:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d5d:	d3 e0                	shl    %cl,%eax
  800d5f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d62:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d65:	d3 ea                	shr    %cl,%edx
  800d67:	09 d0                	or     %edx,%eax
  800d69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d6c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d6f:	d3 ea                	shr    %cl,%edx
  800d71:	f7 f7                	div    %edi
  800d73:	89 d7                	mov    %edx,%edi
  800d75:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d78:	f7 e6                	mul    %esi
  800d7a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7c:	39 d7                	cmp    %edx,%edi
  800d7e:	72 38                	jb     800db8 <__udivdi3+0x120>
  800d80:	74 27                	je     800da9 <__udivdi3+0x111>
  800d82:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d85:	31 c0                	xor    %eax,%eax
  800d87:	e9 4c ff ff ff       	jmp    800cd8 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d8c:	31 c9                	xor    %ecx,%ecx
  800d8e:	31 c0                	xor    %eax,%eax
  800d90:	e9 43 ff ff ff       	jmp    800cd8 <__udivdi3+0x40>
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d98:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	f7 75 f4             	divl   -0xc(%ebp)
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	e9 76 ff ff ff       	jmp    800d1f <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dac:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800daf:	d3 e0                	shl    %cl,%eax
  800db1:	39 f0                	cmp    %esi,%eax
  800db3:	73 cd                	jae    800d82 <__udivdi3+0xea>
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800db8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800dbb:	49                   	dec    %ecx
  800dbc:	31 c0                	xor    %eax,%eax
  800dbe:	e9 15 ff ff ff       	jmp    800cd8 <__udivdi3+0x40>
	...

00800dc4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	83 ec 30             	sub    $0x30,%esp
  800dcc:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dd3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dda:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800de0:	8b 45 10             	mov    0x10(%ebp),%eax
  800de3:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800de9:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800deb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dee:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800df1:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df4:	85 d2                	test   %edx,%edx
  800df6:	75 1c                	jne    800e14 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	39 f8                	cmp    %edi,%eax
  800dfc:	0f 86 c2 00 00 00    	jbe    800ec4 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e02:	89 f0                	mov    %esi,%eax
  800e04:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800e06:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800e09:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800e10:	eb 12                	jmp    800e24 <__umoddi3+0x60>
  800e12:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e14:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800e17:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e1a:	76 18                	jbe    800e34 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e1c:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e1f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e22:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e24:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e27:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e2a:	83 c4 30             	add    $0x30,%esp
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    
  800e31:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e34:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e38:	83 f0 1f             	xor    $0x1f,%eax
  800e3b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e3e:	0f 84 ac 00 00 00    	je     800ef0 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e44:	b8 20 00 00 00       	mov    $0x20,%eax
  800e49:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e4f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e52:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e55:	d3 e2                	shl    %cl,%edx
  800e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e5a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e5d:	d3 e8                	shr    %cl,%eax
  800e5f:	89 d6                	mov    %edx,%esi
  800e61:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e66:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e69:	d3 e0                	shl    %cl,%eax
  800e6b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e6e:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e71:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e76:	d3 e0                	shl    %cl,%eax
  800e78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e7b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e7e:	d3 ea                	shr    %cl,%edx
  800e80:	09 d0                	or     %edx,%eax
  800e82:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e85:	d3 ea                	shr    %cl,%edx
  800e87:	f7 f6                	div    %esi
  800e89:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e8c:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e8f:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e92:	0f 82 8d 00 00 00    	jb     800f25 <__umoddi3+0x161>
  800e98:	0f 84 91 00 00 00    	je     800f2f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e9e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ea1:	29 c7                	sub    %eax,%edi
  800ea3:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ea5:	89 f2                	mov    %esi,%edx
  800ea7:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800eaa:	d3 e2                	shl    %cl,%edx
  800eac:	89 f8                	mov    %edi,%eax
  800eae:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800eb1:	d3 e8                	shr    %cl,%eax
  800eb3:	09 c2                	or     %eax,%edx
  800eb5:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800eb8:	d3 ee                	shr    %cl,%esi
  800eba:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ebd:	e9 62 ff ff ff       	jmp    800e24 <__umoddi3+0x60>
  800ec2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ec4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	74 15                	je     800ee0 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800ecb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ece:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800ed1:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed6:	f7 f1                	div    %ecx
  800ed8:	e9 29 ff ff ff       	jmp    800e06 <__umoddi3+0x42>
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee5:	31 d2                	xor    %edx,%edx
  800ee7:	f7 75 ec             	divl   -0x14(%ebp)
  800eea:	89 c1                	mov    %eax,%ecx
  800eec:	eb dd                	jmp    800ecb <__umoddi3+0x107>
  800eee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ef6:	72 19                	jb     800f11 <__umoddi3+0x14d>
  800ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800efb:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800efe:	76 11                	jbe    800f11 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f03:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800f06:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f09:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800f0c:	e9 13 ff ff ff       	jmp    800e24 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f17:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f1a:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f20:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f23:	eb db                	jmp    800f00 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f25:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f28:	19 f2                	sbb    %esi,%edx
  800f2a:	e9 6f ff ff ff       	jmp    800e9e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2f:	39 c7                	cmp    %eax,%edi
  800f31:	72 f2                	jb     800f25 <__umoddi3+0x161>
  800f33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f36:	e9 63 ff ff ff       	jmp    800e9e <__umoddi3+0xda>
