
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	68 00 00 10 00       	push   $0x100000
  80003f:	ff 35 00 20 80 00    	pushl  0x802000
  800045:	e8 89 00 00 00       	call   8000d3 <sys_cputs>
  80004a:	83 c4 10             	add    $0x10,%esp
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    
	...

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	8b 75 08             	mov    0x8(%ebp),%esi
  800058:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  80005b:	e8 a7 02 00 00       	call   800307 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800060:	25 ff 03 00 00       	and    $0x3ff,%eax
  800065:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	29 d0                	sub    %edx,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 f6                	test   %esi,%esi
  80007d:	7e 07                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	53                   	push   %ebx
  80008a:	56                   	push   %esi
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	e8 79 02 00 00       	call   800326 <sys_env_destroy>
  8000ad:	83 c4 10             	add    $0x10,%esp
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    
	...

008000b4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8000c4:	89 fa                	mov    %edi,%edx
  8000c6:	89 f9                	mov    %edi,%ecx
  8000c8:	89 fb                	mov    %edi,%ebx
  8000ca:	89 fe                	mov    %edi,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	c9                   	leave  
  8000d2:	c3                   	ret    

008000d3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 04             	sub    $0x4,%esp
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8000e7:	89 f8                	mov    %edi,%eax
  8000e9:	89 fb                	mov    %edi,%ebx
  8000eb:	89 fe                	mov    %edi,%esi
  8000ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ef:	83 c4 04             	add    $0x4,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b8 0d 00 00 00       	mov    $0xd,%eax
  800108:	bf 00 00 00 00       	mov    $0x0,%edi
  80010d:	89 f9                	mov    %edi,%ecx
  80010f:	89 fb                	mov    %edi,%ebx
  800111:	89 fe                	mov    %edi,%esi
  800113:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800115:	85 c0                	test   %eax,%eax
  800117:	7e 17                	jle    800130 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	50                   	push   %eax
  80011d:	6a 0d                	push   $0xd
  80011f:	68 58 0f 80 00       	push   $0x800f58
  800124:	6a 23                	push   $0x23
  800126:	68 75 0f 80 00       	push   $0x800f75
  80012b:	e8 38 02 00 00       	call   800368 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5f                   	pop    %edi
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
  80013e:	8b 55 08             	mov    0x8(%ebp),%edx
  800141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800144:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800147:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80014f:	be 00 00 00 00       	mov    $0x0,%esi
  800154:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016f:	bf 00 00 00 00       	mov    $0x0,%edi
  800174:	89 fb                	mov    %edi,%ebx
  800176:	89 fe                	mov    %edi,%esi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 0a                	push   $0xa
  800184:	68 58 0f 80 00       	push   $0x800f58
  800189:	6a 23                	push   $0x23
  80018b:	68 75 0f 80 00       	push   $0x800f75
  800190:	e8 d3 01 00 00       	call   800368 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8001b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8001b6:	89 fb                	mov    %edi,%ebx
  8001b8:	89 fe                	mov    %edi,%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 09                	push   $0x9
  8001c6:	68 58 0f 80 00       	push   $0x800f58
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 75 0f 80 00       	push   $0x800f75
  8001d2:	e8 91 01 00 00       	call   800368 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8001f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f8:	89 fb                	mov    %edi,%ebx
  8001fa:	89 fe                	mov    %edi,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 08                	push   $0x8
  800208:	68 58 0f 80 00       	push   $0x800f58
  80020d:	6a 23                	push   $0x23
  80020f:	68 75 0f 80 00       	push   $0x800f75
  800214:	e8 4f 01 00 00       	call   800368 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	b8 06 00 00 00       	mov    $0x6,%eax
  800235:	bf 00 00 00 00       	mov    $0x0,%edi
  80023a:	89 fb                	mov    %edi,%ebx
  80023c:	89 fe                	mov    %edi,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 06                	push   $0x6
  80024a:	68 58 0f 80 00       	push   $0x800f58
  80024f:	6a 23                	push   $0x23
  800251:	68 75 0f 80 00       	push   $0x800f75
  800256:	e8 0d 01 00 00       	call   800368 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800275:	8b 7d 14             	mov    0x14(%ebp),%edi
  800278:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027b:	b8 05 00 00 00       	mov    $0x5,%eax
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 05                	push   $0x5
  80028c:	68 58 0f 80 00       	push   $0x800f58
  800291:	6a 23                	push   $0x23
  800293:	68 75 0f 80 00       	push   $0x800f75
  800298:	e8 cb 00 00 00       	call   800368 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8002bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8002c1:	89 fe                	mov    %edi,%esi
  8002c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	7e 17                	jle    8002e0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c9:	83 ec 0c             	sub    $0xc,%esp
  8002cc:	50                   	push   %eax
  8002cd:	6a 04                	push   $0x4
  8002cf:	68 58 0f 80 00       	push   $0x800f58
  8002d4:	6a 23                	push   $0x23
  8002d6:	68 75 0f 80 00       	push   $0x800f75
  8002db:	e8 88 00 00 00       	call   800368 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ee:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f8:	89 fa                	mov    %edi,%edx
  8002fa:	89 f9                	mov    %edi,%ecx
  8002fc:	89 fb                	mov    %edi,%ebx
  8002fe:	89 fe                	mov    %edi,%esi
  800300:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030d:	b8 02 00 00 00       	mov    $0x2,%eax
  800312:	bf 00 00 00 00       	mov    $0x0,%edi
  800317:	89 fa                	mov    %edi,%edx
  800319:	89 f9                	mov    %edi,%ecx
  80031b:	89 fb                	mov    %edi,%ebx
  80031d:	89 fe                	mov    %edi,%esi
  80031f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	b8 03 00 00 00       	mov    $0x3,%eax
  800337:	bf 00 00 00 00       	mov    $0x0,%edi
  80033c:	89 f9                	mov    %edi,%ecx
  80033e:	89 fb                	mov    %edi,%ebx
  800340:	89 fe                	mov    %edi,%esi
  800342:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7e 17                	jle    80035f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800348:	83 ec 0c             	sub    $0xc,%esp
  80034b:	50                   	push   %eax
  80034c:	6a 03                	push   $0x3
  80034e:	68 58 0f 80 00       	push   $0x800f58
  800353:	6a 23                	push   $0x23
  800355:	68 75 0f 80 00       	push   $0x800f75
  80035a:	e8 09 00 00 00       	call   800368 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800362:	5b                   	pop    %ebx
  800363:	5e                   	pop    %esi
  800364:	5f                   	pop    %edi
  800365:	c9                   	leave  
  800366:	c3                   	ret    
	...

00800368 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	53                   	push   %ebx
  80036c:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  80036f:	8d 45 14             	lea    0x14(%ebp),%eax
  800372:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800375:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80037b:	e8 87 ff ff ff       	call   800307 <sys_getenvid>
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	ff 75 0c             	pushl  0xc(%ebp)
  800386:	ff 75 08             	pushl  0x8(%ebp)
  800389:	53                   	push   %ebx
  80038a:	50                   	push   %eax
  80038b:	68 84 0f 80 00       	push   $0x800f84
  800390:	e8 74 00 00 00       	call   800409 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800395:	83 c4 18             	add    $0x18,%esp
  800398:	ff 75 f8             	pushl  -0x8(%ebp)
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	e8 15 00 00 00       	call   8003b8 <vcprintf>
	cprintf("\n");
  8003a3:	c7 04 24 4c 0f 80 00 	movl   $0x800f4c,(%esp)
  8003aa:	e8 5a 00 00 00       	call   800409 <cprintf>
  8003af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003b2:	cc                   	int3   
  8003b3:	eb fd                	jmp    8003b2 <_panic+0x4a>
  8003b5:	00 00                	add    %al,(%eax)
	...

008003b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c1:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003c8:	00 00 00 
	b.cnt = 0;
  8003cb:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d5:	ff 75 0c             	pushl  0xc(%ebp)
  8003d8:	ff 75 08             	pushl  0x8(%ebp)
  8003db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e1:	50                   	push   %eax
  8003e2:	68 20 04 80 00       	push   $0x800420
  8003e7:	e8 70 01 00 00       	call   80055c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ec:	83 c4 08             	add    $0x8,%esp
  8003ef:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003f5:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003fb:	50                   	push   %eax
  8003fc:	e8 d2 fc ff ff       	call   8000d3 <sys_cputs>
  800401:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  800407:	c9                   	leave  
  800408:	c3                   	ret    

00800409 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800412:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800415:	50                   	push   %eax
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 9a ff ff ff       	call   8003b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	53                   	push   %ebx
  800424:	83 ec 04             	sub    $0x4,%esp
  800427:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042a:	8b 03                	mov    (%ebx),%eax
  80042c:	8b 55 08             	mov    0x8(%ebp),%edx
  80042f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800433:	40                   	inc    %eax
  800434:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800436:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043b:	75 1a                	jne    800457 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	68 ff 00 00 00       	push   $0xff
  800445:	8d 43 08             	lea    0x8(%ebx),%eax
  800448:	50                   	push   %eax
  800449:	e8 85 fc ff ff       	call   8000d3 <sys_cputs>
		b->idx = 0;
  80044e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800454:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800457:	ff 43 04             	incl   0x4(%ebx)
}
  80045a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    
	...

00800460 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	57                   	push   %edi
  800464:	56                   	push   %esi
  800465:	53                   	push   %ebx
  800466:	83 ec 1c             	sub    $0x1c,%esp
  800469:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80046c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80046f:	8b 45 08             	mov    0x8(%ebp),%eax
  800472:	8b 55 0c             	mov    0xc(%ebp),%edx
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80047b:	8b 55 10             	mov    0x10(%ebp),%edx
  80047e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800481:	89 d6                	mov    %edx,%esi
  800483:	bf 00 00 00 00       	mov    $0x0,%edi
  800488:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  80048b:	72 04                	jb     800491 <printnum+0x31>
  80048d:	39 c2                	cmp    %eax,%edx
  80048f:	77 3f                	ja     8004d0 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800491:	83 ec 0c             	sub    $0xc,%esp
  800494:	ff 75 18             	pushl  0x18(%ebp)
  800497:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80049a:	50                   	push   %eax
  80049b:	52                   	push   %edx
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a7:	e8 d4 07 00 00       	call   800c80 <__udivdi3>
  8004ac:	83 c4 18             	add    $0x18,%esp
  8004af:	52                   	push   %edx
  8004b0:	50                   	push   %eax
  8004b1:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004b7:	e8 a4 ff ff ff       	call   800460 <printnum>
  8004bc:	83 c4 20             	add    $0x20,%esp
  8004bf:	eb 14                	jmp    8004d5 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 e8             	pushl  -0x18(%ebp)
  8004c7:	ff 75 18             	pushl  0x18(%ebp)
  8004ca:	ff 55 ec             	call   *-0x14(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d0:	4b                   	dec    %ebx
  8004d1:	85 db                	test   %ebx,%ebx
  8004d3:	7f ec                	jg     8004c1 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 e8             	pushl  -0x18(%ebp)
  8004db:	83 ec 04             	sub    $0x4,%esp
  8004de:	57                   	push   %edi
  8004df:	56                   	push   %esi
  8004e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e6:	e8 c1 08 00 00       	call   800dac <__umoddi3>
  8004eb:	83 c4 14             	add    $0x14,%esp
  8004ee:	0f be 80 a7 0f 80 00 	movsbl 0x800fa7(%eax),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff 55 ec             	call   *-0x14(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
}
  8004fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ff:	5b                   	pop    %ebx
  800500:	5e                   	pop    %esi
  800501:	5f                   	pop    %edi
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800509:	83 fa 01             	cmp    $0x1,%edx
  80050c:	7e 0e                	jle    80051c <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  80050e:	8b 10                	mov    (%eax),%edx
  800510:	8d 42 08             	lea    0x8(%edx),%eax
  800513:	89 01                	mov    %eax,(%ecx)
  800515:	8b 02                	mov    (%edx),%eax
  800517:	8b 52 04             	mov    0x4(%edx),%edx
  80051a:	eb 22                	jmp    80053e <getuint+0x3a>
	else if (lflag)
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 10                	je     800530 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 42 04             	lea    0x4(%edx),%eax
  800525:	89 01                	mov    %eax,(%ecx)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
  80052e:	eb 0e                	jmp    80053e <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 42 04             	lea    0x4(%edx),%eax
  800535:	89 01                	mov    %eax,(%ecx)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053e:	c9                   	leave  
  80053f:	c3                   	ret    

00800540 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  800546:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800549:	8b 11                	mov    (%ecx),%edx
  80054b:	3b 51 04             	cmp    0x4(%ecx),%edx
  80054e:	73 0a                	jae    80055a <sprintputch+0x1a>
		*b->buf++ = ch;
  800550:	8b 45 08             	mov    0x8(%ebp),%eax
  800553:	88 02                	mov    %al,(%edx)
  800555:	8d 42 01             	lea    0x1(%edx),%eax
  800558:	89 01                	mov    %eax,(%ecx)
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	57                   	push   %edi
  800560:	56                   	push   %esi
  800561:	53                   	push   %ebx
  800562:	83 ec 3c             	sub    $0x3c,%esp
  800565:	8b 75 08             	mov    0x8(%ebp),%esi
  800568:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80056b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x2e>
  800570:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800573:	eb 15                	jmp    80058a <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800575:	84 c0                	test   %al,%al
  800577:	0f 84 15 03 00 00    	je     800892 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	50                   	push   %eax
  800585:	ff d6                	call   *%esi
  800587:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80058a:	8a 03                	mov    (%ebx),%al
  80058c:	43                   	inc    %ebx
  80058d:	3c 25                	cmp    $0x25,%al
  80058f:	75 e4                	jne    800575 <vprintfmt+0x19>
  800591:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800598:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059f:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8005a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005ad:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005b1:	eb 0a                	jmp    8005bd <vprintfmt+0x61>
  8005b3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005ba:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8a 03                	mov    (%ebx),%al
  8005bf:	0f b6 d0             	movzbl %al,%edx
  8005c2:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005c5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005c8:	83 e8 23             	sub    $0x23,%eax
  8005cb:	3c 55                	cmp    $0x55,%al
  8005cd:	0f 87 9c 02 00 00    	ja     80086f <vprintfmt+0x313>
  8005d3:	0f b6 c0             	movzbl %al,%eax
  8005d6:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005dd:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005e1:	eb d7                	jmp    8005ba <vprintfmt+0x5e>
  8005e3:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005e7:	eb d1                	jmp    8005ba <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005e9:	89 d9                	mov    %ebx,%ecx
  8005eb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005f2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f5:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005f8:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005ff:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800603:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800604:	8d 42 d0             	lea    -0x30(%edx),%eax
  800607:	83 f8 09             	cmp    $0x9,%eax
  80060a:	77 21                	ja     80062d <vprintfmt+0xd1>
  80060c:	eb e4                	jmp    8005f2 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80060e:	8b 55 14             	mov    0x14(%ebp),%edx
  800611:	8d 42 04             	lea    0x4(%edx),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
  800617:	8b 12                	mov    (%edx),%edx
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061c:	eb 12                	jmp    800630 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  80061e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800622:	79 96                	jns    8005ba <vprintfmt+0x5e>
  800624:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80062b:	eb 8d                	jmp    8005ba <vprintfmt+0x5e>
  80062d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800630:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800634:	79 84                	jns    8005ba <vprintfmt+0x5e>
  800636:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800639:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800643:	e9 72 ff ff ff       	jmp    8005ba <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800648:	ff 45 d4             	incl   -0x2c(%ebp)
  80064b:	e9 6a ff ff ff       	jmp    8005ba <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800650:	8b 55 14             	mov    0x14(%ebp),%edx
  800653:	8d 42 04             	lea    0x4(%edx),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	57                   	push   %edi
  80065d:	ff 32                	pushl  (%edx)
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	e9 07 ff ff ff       	jmp    800570 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800669:	8b 55 14             	mov    0x14(%ebp),%edx
  80066c:	8d 42 04             	lea    0x4(%edx),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	8b 02                	mov    (%edx),%eax
  800674:	85 c0                	test   %eax,%eax
  800676:	79 02                	jns    80067a <vprintfmt+0x11e>
  800678:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067a:	83 f8 0f             	cmp    $0xf,%eax
  80067d:	7f 0b                	jg     80068a <vprintfmt+0x12e>
  80067f:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800686:	85 d2                	test   %edx,%edx
  800688:	75 15                	jne    80069f <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  80068a:	50                   	push   %eax
  80068b:	68 b8 0f 80 00       	push   $0x800fb8
  800690:	57                   	push   %edi
  800691:	56                   	push   %esi
  800692:	e8 6e 02 00 00       	call   800905 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	e9 d1 fe ff ff       	jmp    800570 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80069f:	52                   	push   %edx
  8006a0:	68 c1 0f 80 00       	push   $0x800fc1
  8006a5:	57                   	push   %edi
  8006a6:	56                   	push   %esi
  8006a7:	e8 59 02 00 00       	call   800905 <printfmt>
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	e9 bc fe ff ff       	jmp    800570 <vprintfmt+0x14>
  8006b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006bd:	8b 55 14             	mov    0x14(%ebp),%edx
  8006c0:	8d 42 04             	lea    0x4(%edx),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c6:	8b 1a                	mov    (%edx),%ebx
  8006c8:	85 db                	test   %ebx,%ebx
  8006ca:	75 05                	jne    8006d1 <vprintfmt+0x175>
  8006cc:	bb c4 0f 80 00       	mov    $0x800fc4,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006d5:	7e 66                	jle    80073d <vprintfmt+0x1e1>
  8006d7:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006db:	74 60                	je     80073d <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	51                   	push   %ecx
  8006e1:	53                   	push   %ebx
  8006e2:	e8 57 02 00 00       	call   80093e <strnlen>
  8006e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006ea:	29 c1                	sub    %eax,%ecx
  8006ec:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006f6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006f9:	eb 0f                	jmp    80070a <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	57                   	push   %edi
  8006ff:	ff 75 c4             	pushl  -0x3c(%ebp)
  800702:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	ff 4d d8             	decl   -0x28(%ebp)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070e:	7f eb                	jg     8006fb <vprintfmt+0x19f>
  800710:	eb 2b                	jmp    80073d <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800712:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800715:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800719:	74 15                	je     800730 <vprintfmt+0x1d4>
  80071b:	8d 42 e0             	lea    -0x20(%edx),%eax
  80071e:	83 f8 5e             	cmp    $0x5e,%eax
  800721:	76 0d                	jbe    800730 <vprintfmt+0x1d4>
					putch('?', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	57                   	push   %edi
  800727:	6a 3f                	push   $0x3f
  800729:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 0a                	jmp    80073a <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	57                   	push   %edi
  800734:	52                   	push   %edx
  800735:	ff d6                	call   *%esi
  800737:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073a:	ff 4d d8             	decl   -0x28(%ebp)
  80073d:	8a 03                	mov    (%ebx),%al
  80073f:	43                   	inc    %ebx
  800740:	84 c0                	test   %al,%al
  800742:	74 1b                	je     80075f <vprintfmt+0x203>
  800744:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800748:	78 c8                	js     800712 <vprintfmt+0x1b6>
  80074a:	ff 4d dc             	decl   -0x24(%ebp)
  80074d:	79 c3                	jns    800712 <vprintfmt+0x1b6>
  80074f:	eb 0e                	jmp    80075f <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	57                   	push   %edi
  800755:	6a 20                	push   $0x20
  800757:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800759:	ff 4d d8             	decl   -0x28(%ebp)
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800763:	7f ec                	jg     800751 <vprintfmt+0x1f5>
  800765:	e9 06 fe ff ff       	jmp    800570 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076a:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80076e:	7e 10                	jle    800780 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800770:	8b 55 14             	mov    0x14(%ebp),%edx
  800773:	8d 42 08             	lea    0x8(%edx),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
  800779:	8b 02                	mov    (%edx),%eax
  80077b:	8b 52 04             	mov    0x4(%edx),%edx
  80077e:	eb 20                	jmp    8007a0 <vprintfmt+0x244>
	else if (lflag)
  800780:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800784:	74 0e                	je     800794 <vprintfmt+0x238>
		return va_arg(*ap, long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	99                   	cltd   
  800792:	eb 0c                	jmp    8007a0 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a0:	89 d1                	mov    %edx,%ecx
  8007a2:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8007a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007aa:	85 c9                	test   %ecx,%ecx
  8007ac:	78 0a                	js     8007b8 <vprintfmt+0x25c>
  8007ae:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007b3:	e9 89 00 00 00       	jmp    800841 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	57                   	push   %edi
  8007bc:	6a 2d                	push   $0x2d
  8007be:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007c3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007c6:	f7 da                	neg    %edx
  8007c8:	83 d1 00             	adc    $0x0,%ecx
  8007cb:	f7 d9                	neg    %ecx
  8007cd:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	eb 6a                	jmp    800841 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007da:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007dd:	e8 22 fd ff ff       	call   800504 <getuint>
  8007e2:	89 d1                	mov    %edx,%ecx
  8007e4:	89 c2                	mov    %eax,%edx
  8007e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007eb:	eb 54                	jmp    800841 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f3:	e8 0c fd ff ff       	call   800504 <getuint>
  8007f8:	89 d1                	mov    %edx,%ecx
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800801:	eb 3e                	jmp    800841 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	57                   	push   %edi
  800807:	6a 30                	push   $0x30
  800809:	ff d6                	call   *%esi
			putch('x', putdat);
  80080b:	83 c4 08             	add    $0x8,%esp
  80080e:	57                   	push   %edi
  80080f:	6a 78                	push   $0x78
  800811:	ff d6                	call   *%esi
			num = (unsigned long long)
  800813:	8b 55 14             	mov    0x14(%ebp),%edx
  800816:	8d 42 04             	lea    0x4(%edx),%eax
  800819:	89 45 14             	mov    %eax,0x14(%ebp)
  80081c:	8b 12                	mov    (%edx),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800823:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	eb 14                	jmp    800841 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
  800830:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800833:	e8 cc fc ff ff       	call   800504 <getuint>
  800838:	89 d1                	mov    %edx,%ecx
  80083a:	89 c2                	mov    %eax,%edx
  80083c:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800841:	83 ec 0c             	sub    $0xc,%esp
  800844:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 d8             	pushl  -0x28(%ebp)
  80084c:	53                   	push   %ebx
  80084d:	51                   	push   %ecx
  80084e:	52                   	push   %edx
  80084f:	89 fa                	mov    %edi,%edx
  800851:	89 f0                	mov    %esi,%eax
  800853:	e8 08 fc ff ff       	call   800460 <printnum>
			break;
  800858:	83 c4 20             	add    $0x20,%esp
  80085b:	e9 10 fd ff ff       	jmp    800570 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	57                   	push   %edi
  800864:	52                   	push   %edx
  800865:	ff d6                	call   *%esi
			break;
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	e9 01 fd ff ff       	jmp    800570 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	57                   	push   %edi
  800873:	6a 25                	push   $0x25
  800875:	ff d6                	call   *%esi
  800877:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80087a:	83 ea 02             	sub    $0x2,%edx
  80087d:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800880:	8a 02                	mov    (%edx),%al
  800882:	4a                   	dec    %edx
  800883:	3c 25                	cmp    $0x25,%al
  800885:	75 f9                	jne    800880 <vprintfmt+0x324>
  800887:	83 c2 02             	add    $0x2,%edx
  80088a:	89 55 ec             	mov    %edx,-0x14(%ebp)
  80088d:	e9 de fc ff ff       	jmp    800570 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 18             	sub    $0x18,%esp
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	74 37                	je     8008e1 <vsnprintf+0x47>
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	7e 33                	jle    8008e1 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008bc:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bf:	ff 75 14             	pushl  0x14(%ebp)
  8008c2:	ff 75 10             	pushl  0x10(%ebp)
  8008c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c8:	50                   	push   %eax
  8008c9:	68 40 05 80 00       	push   $0x800540
  8008ce:	e8 89 fc ff ff       	call   80055c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb 05                	jmp    8008e6 <vsnprintf+0x4c>
  8008e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008f4:	50                   	push   %eax
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 97 ff ff ff       	call   80089a <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
  80090e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800911:	50                   	push   %eax
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 3c fc ff ff       	call   80055c <vprintfmt>
	va_end(ap);
  800920:	83 c4 10             	add    $0x10,%esp
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    
  800925:	00 00                	add    %al,(%eax)
	...

00800928 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 55 08             	mov    0x8(%ebp),%edx
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 01                	jmp    800936 <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800935:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  80093a:	75 f9                	jne    800935 <strlen+0xd>
		n++;
	return n;
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 01                	jmp    80094f <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  80094e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	74 06                	je     800959 <strnlen+0x1b>
  800953:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800957:	75 f5                	jne    80094e <strnlen+0x10>
		n++;
	return n;
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800961:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800964:	8a 01                	mov    (%ecx),%al
  800966:	88 02                	mov    %al,(%edx)
  800968:	42                   	inc    %edx
  800969:	41                   	inc    %ecx
  80096a:	84 c0                	test   %al,%al
  80096c:	75 f6                	jne    800964 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097a:	53                   	push   %ebx
  80097b:	e8 a8 ff ff ff       	call   800928 <strlen>
	strcpy(dst + len, src);
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800986:	50                   	push   %eax
  800987:	e8 cf ff ff ff       	call   80095b <strcpy>
	return dst;
}
  80098c:	89 d8                	mov    %ebx,%eax
  80098e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 75 08             	mov    0x8(%ebp),%esi
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8009a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a6:	eb 0c                	jmp    8009b4 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009a8:	8a 02                	mov    (%edx),%al
  8009aa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ad:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b3:	41                   	inc    %ecx
  8009b4:	39 d9                	cmp    %ebx,%ecx
  8009b6:	75 f0                	jne    8009a8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b8:	89 f0                	mov    %esi,%eax
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	75 04                	jne    8009d4 <strlcpy+0x16>
  8009d0:	89 f0                	mov    %esi,%eax
  8009d2:	eb 14                	jmp    8009e8 <strlcpy+0x2a>
  8009d4:	89 f0                	mov    %esi,%eax
  8009d6:	eb 04                	jmp    8009dc <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d8:	88 10                	mov    %dl,(%eax)
  8009da:	40                   	inc    %eax
  8009db:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009dc:	49                   	dec    %ecx
  8009dd:	74 06                	je     8009e5 <strlcpy+0x27>
  8009df:	8a 13                	mov    (%ebx),%dl
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f3                	jne    8009d8 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009e5:	c6 00 00             	movb   $0x0,(%eax)
  8009e8:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f7:	eb 02                	jmp    8009fb <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009f9:	42                   	inc    %edx
  8009fa:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fb:	8a 02                	mov    (%edx),%al
  8009fd:	84 c0                	test   %al,%al
  8009ff:	74 04                	je     800a05 <strcmp+0x17>
  800a01:	3a 01                	cmp    (%ecx),%al
  800a03:	74 f4                	je     8009f9 <strcmp+0xb>
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 11             	movzbl (%ecx),%edx
  800a0b:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a19:	8b 55 10             	mov    0x10(%ebp),%edx
  800a1c:	eb 03                	jmp    800a21 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a1e:	4a                   	dec    %edx
  800a1f:	41                   	inc    %ecx
  800a20:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a21:	85 d2                	test   %edx,%edx
  800a23:	75 07                	jne    800a2c <strncmp+0x1d>
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	eb 14                	jmp    800a40 <strncmp+0x31>
  800a2c:	8a 01                	mov    (%ecx),%al
  800a2e:	84 c0                	test   %al,%al
  800a30:	74 04                	je     800a36 <strncmp+0x27>
  800a32:	3a 03                	cmp    (%ebx),%al
  800a34:	74 e8                	je     800a1e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a36:	0f b6 d0             	movzbl %al,%edx
  800a39:	0f b6 03             	movzbl (%ebx),%eax
  800a3c:	29 c2                	sub    %eax,%edx
  800a3e:	89 d0                	mov    %edx,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a4c:	eb 05                	jmp    800a53 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a4e:	38 ca                	cmp    %cl,%dl
  800a50:	74 0c                	je     800a5e <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a52:	40                   	inc    %eax
  800a53:	8a 10                	mov    (%eax),%dl
  800a55:	84 d2                	test   %dl,%dl
  800a57:	75 f5                	jne    800a4e <strchr+0xb>
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a69:	eb 05                	jmp    800a70 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a6b:	38 ca                	cmp    %cl,%dl
  800a6d:	74 07                	je     800a76 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6f:	40                   	inc    %eax
  800a70:	8a 10                	mov    (%eax),%dl
  800a72:	84 d2                	test   %dl,%dl
  800a74:	75 f5                	jne    800a6b <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	74 36                	je     800ac1 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a91:	75 29                	jne    800abc <memset+0x44>
  800a93:	f6 c3 03             	test   $0x3,%bl
  800a96:	75 24                	jne    800abc <memset+0x44>
		c &= 0xFF;
  800a98:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a9b:	89 d6                	mov    %edx,%esi
  800a9d:	c1 e6 08             	shl    $0x8,%esi
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	c1 e0 18             	shl    $0x18,%eax
  800aa5:	89 d1                	mov    %edx,%ecx
  800aa7:	c1 e1 10             	shl    $0x10,%ecx
  800aaa:	09 c8                	or     %ecx,%eax
  800aac:	09 c2                	or     %eax,%edx
  800aae:	89 f0                	mov    %esi,%eax
  800ab0:	09 d0                	or     %edx,%eax
  800ab2:	89 d9                	mov    %ebx,%ecx
  800ab4:	c1 e9 02             	shr    $0x2,%ecx
  800ab7:	fc                   	cld    
  800ab8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aba:	eb 05                	jmp    800ac1 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abc:	89 d9                	mov    %ebx,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ad6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	73 36                	jae    800b12 <memmove+0x4a>
  800adc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adf:	39 d0                	cmp    %edx,%eax
  800ae1:	73 2f                	jae    800b12 <memmove+0x4a>
		s += n;
		d += n;
  800ae3:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	f6 c2 03             	test   $0x3,%dl
  800ae9:	75 1b                	jne    800b06 <memmove+0x3e>
  800aeb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af1:	75 13                	jne    800b06 <memmove+0x3e>
  800af3:	f6 c1 03             	test   $0x3,%cl
  800af6:	75 0e                	jne    800b06 <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800af8:	8d 7e fc             	lea    -0x4(%esi),%edi
  800afb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afe:	c1 e9 02             	shr    $0x2,%ecx
  800b01:	fd                   	std    
  800b02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b04:	eb 09                	jmp    800b0f <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b06:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b09:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b0c:	fd                   	std    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0f:	fc                   	cld    
  800b10:	eb 20                	jmp    800b32 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b18:	75 15                	jne    800b2f <memmove+0x67>
  800b1a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b20:	75 0d                	jne    800b2f <memmove+0x67>
  800b22:	f6 c1 03             	test   $0x3,%cl
  800b25:	75 08                	jne    800b2f <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b27:	c1 e9 02             	shr    $0x2,%ecx
  800b2a:	fc                   	cld    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb 03                	jmp    800b32 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2f:	fc                   	cld    
  800b30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b39:	ff 75 10             	pushl  0x10(%ebp)
  800b3c:	ff 75 0c             	pushl  0xc(%ebp)
  800b3f:	ff 75 08             	pushl  0x8(%ebp)
  800b42:	e8 81 ff ff ff       	call   800ac8 <memmove>
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 04             	sub    $0x4,%esp
  800b50:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b59:	eb 1b                	jmp    800b76 <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b5b:	8a 1a                	mov    (%edx),%bl
  800b5d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b60:	8a 19                	mov    (%ecx),%bl
  800b62:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b65:	74 0d                	je     800b74 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b67:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b6b:	0f b6 c3             	movzbl %bl,%eax
  800b6e:	29 c2                	sub    %eax,%edx
  800b70:	89 d0                	mov    %edx,%eax
  800b72:	eb 0d                	jmp    800b81 <memcmp+0x38>
		s1++, s2++;
  800b74:	42                   	inc    %edx
  800b75:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b76:	48                   	dec    %eax
  800b77:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b7a:	75 df                	jne    800b5b <memcmp+0x12>
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b81:	83 c4 04             	add    $0x4,%esp
  800b84:	5b                   	pop    %ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	03 55 10             	add    0x10(%ebp),%edx
  800b95:	eb 05                	jmp    800b9c <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b97:	38 08                	cmp    %cl,(%eax)
  800b99:	74 05                	je     800ba0 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9b:	40                   	inc    %eax
  800b9c:	39 d0                	cmp    %edx,%eax
  800b9e:	72 f7                	jb     800b97 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 04             	sub    $0x4,%esp
  800bab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bae:	8b 75 10             	mov    0x10(%ebp),%esi
  800bb1:	eb 01                	jmp    800bb4 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bb3:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb4:	8a 01                	mov    (%ecx),%al
  800bb6:	3c 20                	cmp    $0x20,%al
  800bb8:	74 f9                	je     800bb3 <strtol+0x11>
  800bba:	3c 09                	cmp    $0x9,%al
  800bbc:	74 f5                	je     800bb3 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bbe:	3c 2b                	cmp    $0x2b,%al
  800bc0:	75 0a                	jne    800bcc <strtol+0x2a>
		s++;
  800bc2:	41                   	inc    %ecx
  800bc3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bca:	eb 17                	jmp    800be3 <strtol+0x41>
	else if (*s == '-')
  800bcc:	3c 2d                	cmp    $0x2d,%al
  800bce:	74 09                	je     800bd9 <strtol+0x37>
  800bd0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd7:	eb 0a                	jmp    800be3 <strtol+0x41>
		s++, neg = 1;
  800bd9:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bdc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be3:	85 f6                	test   %esi,%esi
  800be5:	74 05                	je     800bec <strtol+0x4a>
  800be7:	83 fe 10             	cmp    $0x10,%esi
  800bea:	75 1a                	jne    800c06 <strtol+0x64>
  800bec:	8a 01                	mov    (%ecx),%al
  800bee:	3c 30                	cmp    $0x30,%al
  800bf0:	75 10                	jne    800c02 <strtol+0x60>
  800bf2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf6:	75 0a                	jne    800c02 <strtol+0x60>
		s += 2, base = 16;
  800bf8:	83 c1 02             	add    $0x2,%ecx
  800bfb:	be 10 00 00 00       	mov    $0x10,%esi
  800c00:	eb 04                	jmp    800c06 <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800c02:	85 f6                	test   %esi,%esi
  800c04:	74 07                	je     800c0d <strtol+0x6b>
  800c06:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0b:	eb 13                	jmp    800c20 <strtol+0x7e>
  800c0d:	3c 30                	cmp    $0x30,%al
  800c0f:	74 07                	je     800c18 <strtol+0x76>
  800c11:	be 0a 00 00 00       	mov    $0xa,%esi
  800c16:	eb ee                	jmp    800c06 <strtol+0x64>
		s++, base = 8;
  800c18:	41                   	inc    %ecx
  800c19:	be 08 00 00 00       	mov    $0x8,%esi
  800c1e:	eb e6                	jmp    800c06 <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c20:	8a 11                	mov    (%ecx),%dl
  800c22:	88 d3                	mov    %dl,%bl
  800c24:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c27:	3c 09                	cmp    $0x9,%al
  800c29:	77 08                	ja     800c33 <strtol+0x91>
			dig = *s - '0';
  800c2b:	0f be c2             	movsbl %dl,%eax
  800c2e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c31:	eb 1c                	jmp    800c4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c33:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c36:	3c 19                	cmp    $0x19,%al
  800c38:	77 08                	ja     800c42 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c3a:	0f be c2             	movsbl %dl,%eax
  800c3d:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c40:	eb 0d                	jmp    800c4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c42:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c45:	3c 19                	cmp    $0x19,%al
  800c47:	77 15                	ja     800c5e <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c49:	0f be c2             	movsbl %dl,%eax
  800c4c:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c4f:	39 f2                	cmp    %esi,%edx
  800c51:	7d 0b                	jge    800c5e <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c53:	41                   	inc    %ecx
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	0f af c6             	imul   %esi,%eax
  800c59:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c5c:	eb c2                	jmp    800c20 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c5e:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c64:	74 05                	je     800c6b <strtol+0xc9>
		*endptr = (char *) s;
  800c66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c69:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c6f:	74 04                	je     800c75 <strtol+0xd3>
  800c71:	89 c7                	mov    %eax,%edi
  800c73:	f7 df                	neg    %edi
}
  800c75:	89 f8                	mov    %edi,%eax
  800c77:	83 c4 04             	add    $0x4,%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    
	...

00800c80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	83 ec 28             	sub    $0x28,%esp
  800c88:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c8f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c96:	8b 45 10             	mov    0x10(%ebp),%eax
  800c99:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c9f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800ca1:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cac:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800caf:	85 ff                	test   %edi,%edi
  800cb1:	75 21                	jne    800cd4 <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cb3:	39 d1                	cmp    %edx,%ecx
  800cb5:	76 49                	jbe    800d00 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800cb7:	f7 f1                	div    %ecx
  800cb9:	89 c1                	mov    %eax,%ecx
  800cbb:	31 c0                	xor    %eax,%eax
  800cbd:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cc0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cc3:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cc9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ccc:	83 c4 28             	add    $0x28,%esp
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    
  800cd3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800cd4:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800cd7:	0f 87 97 00 00 00    	ja     800d74 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cdd:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800ce0:	83 f0 1f             	xor    $0x1f,%eax
  800ce3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ce6:	75 34                	jne    800d1c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce8:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ceb:	72 08                	jb     800cf5 <__udivdi3+0x75>
  800ced:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800cf0:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800cf3:	77 7f                	ja     800d74 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cf5:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cfa:	31 c0                	xor    %eax,%eax
  800cfc:	eb c2                	jmp    800cc0 <__udivdi3+0x40>
  800cfe:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d03:	85 c0                	test   %eax,%eax
  800d05:	74 79                	je     800d80 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d0a:	89 fa                	mov    %edi,%edx
  800d0c:	f7 f1                	div    %ecx
  800d0e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d13:	f7 f1                	div    %ecx
  800d15:	89 c1                	mov    %eax,%ecx
  800d17:	89 f0                	mov    %esi,%eax
  800d19:	eb a5                	jmp    800cc0 <__udivdi3+0x40>
  800d1b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d1c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d21:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d27:	89 fa                	mov    %edi,%edx
  800d29:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d2c:	d3 e2                	shl    %cl,%edx
  800d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d31:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d34:	d3 e8                	shr    %cl,%eax
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d3a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d3d:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d40:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d42:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d45:	d3 e0                	shl    %cl,%eax
  800d47:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d4a:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d4d:	d3 ea                	shr    %cl,%edx
  800d4f:	09 d0                	or     %edx,%eax
  800d51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d54:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	f7 f7                	div    %edi
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d60:	f7 e6                	mul    %esi
  800d62:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d64:	39 d7                	cmp    %edx,%edi
  800d66:	72 38                	jb     800da0 <__udivdi3+0x120>
  800d68:	74 27                	je     800d91 <__udivdi3+0x111>
  800d6a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d6d:	31 c0                	xor    %eax,%eax
  800d6f:	e9 4c ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d74:	31 c9                	xor    %ecx,%ecx
  800d76:	31 c0                	xor    %eax,%eax
  800d78:	e9 43 ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	31 d2                	xor    %edx,%edx
  800d87:	f7 75 f4             	divl   -0xc(%ebp)
  800d8a:	89 c1                	mov    %eax,%ecx
  800d8c:	e9 76 ff ff ff       	jmp    800d07 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d94:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d97:	d3 e0                	shl    %cl,%eax
  800d99:	39 f0                	cmp    %esi,%eax
  800d9b:	73 cd                	jae    800d6a <__udivdi3+0xea>
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800da0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800da3:	49                   	dec    %ecx
  800da4:	31 c0                	xor    %eax,%eax
  800da6:	e9 15 ff ff ff       	jmp    800cc0 <__udivdi3+0x40>
	...

00800dac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	83 ec 30             	sub    $0x30,%esp
  800db4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800dbb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcb:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd1:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dd3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dd6:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dd9:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ddc:	85 d2                	test   %edx,%edx
  800dde:	75 1c                	jne    800dfc <__umoddi3+0x50>
    {
      if (d0 > n1)
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	39 f8                	cmp    %edi,%eax
  800de4:	0f 86 c2 00 00 00    	jbe    800eac <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dea:	89 f0                	mov    %esi,%eax
  800dec:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800dee:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800df1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800df8:	eb 12                	jmp    800e0c <__umoddi3+0x60>
  800dfa:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dfc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800dff:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800e02:	76 18                	jbe    800e1c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800e04:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800e07:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e0a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e0f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e12:	83 c4 30             	add    $0x30,%esp
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    
  800e19:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e1c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e20:	83 f0 1f             	xor    $0x1f,%eax
  800e23:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e26:	0f 84 ac 00 00 00    	je     800ed8 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e37:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e3a:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e3d:	d3 e2                	shl    %cl,%edx
  800e3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e42:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	89 d6                	mov    %edx,%esi
  800e49:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e4e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e51:	d3 e0                	shl    %cl,%eax
  800e53:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e56:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e59:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e5e:	d3 e0                	shl    %cl,%eax
  800e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e63:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e66:	d3 ea                	shr    %cl,%edx
  800e68:	09 d0                	or     %edx,%eax
  800e6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e6d:	d3 ea                	shr    %cl,%edx
  800e6f:	f7 f6                	div    %esi
  800e71:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e74:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e77:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e7a:	0f 82 8d 00 00 00    	jb     800f0d <__umoddi3+0x161>
  800e80:	0f 84 91 00 00 00    	je     800f17 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e86:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e89:	29 c7                	sub    %eax,%edi
  800e8b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e8d:	89 f2                	mov    %esi,%edx
  800e8f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e92:	d3 e2                	shl    %cl,%edx
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e99:	d3 e8                	shr    %cl,%eax
  800e9b:	09 c2                	or     %eax,%edx
  800e9d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800ea0:	d3 ee                	shr    %cl,%esi
  800ea2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800ea5:	e9 62 ff ff ff       	jmp    800e0c <__umoddi3+0x60>
  800eaa:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	74 15                	je     800ec8 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eb6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eb9:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebe:	f7 f1                	div    %ecx
  800ec0:	e9 29 ff ff ff       	jmp    800dee <__umoddi3+0x42>
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecd:	31 d2                	xor    %edx,%edx
  800ecf:	f7 75 ec             	divl   -0x14(%ebp)
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	eb dd                	jmp    800eb3 <__umoddi3+0x107>
  800ed6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800edb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ede:	72 19                	jb     800ef9 <__umoddi3+0x14d>
  800ee0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee3:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ee6:	76 11                	jbe    800ef9 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ee8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eeb:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800eee:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ef1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800ef4:	e9 13 ff ff ff       	jmp    800e0c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eff:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800f02:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f0b:	eb db                	jmp    800ee8 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f0d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f10:	19 f2                	sbb    %esi,%edx
  800f12:	e9 6f ff ff ff       	jmp    800e86 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f17:	39 c7                	cmp    %eax,%edi
  800f19:	72 f2                	jb     800f0d <__umoddi3+0x161>
  800f1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f1e:	e9 63 ff ff ff       	jmp    800e86 <__umoddi3+0xda>
