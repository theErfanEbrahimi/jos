
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 17 00 00 00       	call   800048 <libmain>
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
	sys_cputs((char*)1, 1);
  80003a:	6a 01                	push   $0x1
  80003c:	6a 01                	push   $0x1
  80003e:	e8 88 00 00 00       	call   8000cb <sys_cputs>
  800043:	83 c4 10             	add    $0x10,%esp
}
  800046:	c9                   	leave  
  800047:	c3                   	ret    

00800048 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800048:	55                   	push   %ebp
  800049:	89 e5                	mov    %esp,%ebp
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800053:	e8 a7 02 00 00       	call   8002ff <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800064:	c1 e0 07             	shl    $0x7,%eax
  800067:	29 d0                	sub    %edx,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 07                	jle    80007e <libmain+0x36>
		binaryname = argv[0];
  800077:	8b 03                	mov    (%ebx),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	53                   	push   %ebx
  800082:	56                   	push   %esi
  800083:	e8 ac ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800088:	e8 0b 00 00 00       	call   800098 <exit>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	c9                   	leave  
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 79 02 00 00       	call   80031e <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    
	...

008000ac <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b7:	bf 00 00 00 00       	mov    $0x0,%edi
  8000bc:	89 fa                	mov    %edi,%edx
  8000be:	89 f9                	mov    %edi,%ecx
  8000c0:	89 fb                	mov    %edi,%ebx
  8000c2:	89 fe                	mov    %edi,%esi
  8000c4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	bf 00 00 00 00       	mov    $0x0,%edi
  8000df:	89 f8                	mov    %edi,%eax
  8000e1:	89 fb                	mov    %edi,%ebx
  8000e3:	89 fe                	mov    %edi,%esi
  8000e5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e7:	83 c4 04             	add    $0x4,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800100:	bf 00 00 00 00       	mov    $0x0,%edi
  800105:	89 f9                	mov    %edi,%ecx
  800107:	89 fb                	mov    %edi,%ebx
  800109:	89 fe                	mov    %edi,%esi
  80010b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010d:	85 c0                	test   %eax,%eax
  80010f:	7e 17                	jle    800128 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 0d                	push   $0xd
  800117:	68 2a 0f 80 00       	push   $0x800f2a
  80011c:	6a 23                	push   $0x23
  80011e:	68 47 0f 80 00       	push   $0x800f47
  800123:	e8 38 02 00 00       	call   800360 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5f                   	pop    %edi
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	57                   	push   %edi
  800134:	56                   	push   %esi
  800135:	53                   	push   %ebx
  800136:	8b 55 08             	mov    0x8(%ebp),%edx
  800139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80013c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80013f:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	b8 0c 00 00 00       	mov    $0xc,%eax
  800147:	be 00 00 00 00       	mov    $0x0,%esi
  80014c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800162:	b8 0a 00 00 00       	mov    $0xa,%eax
  800167:	bf 00 00 00 00       	mov    $0x0,%edi
  80016c:	89 fb                	mov    %edi,%ebx
  80016e:	89 fe                	mov    %edi,%esi
  800170:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 0a                	push   $0xa
  80017c:	68 2a 0f 80 00       	push   $0x800f2a
  800181:	6a 23                	push   $0x23
  800183:	68 47 0f 80 00       	push   $0x800f47
  800188:	e8 d3 01 00 00       	call   800360 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8001a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8001ae:	89 fb                	mov    %edi,%ebx
  8001b0:	89 fe                	mov    %edi,%esi
  8001b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 09                	push   $0x9
  8001be:	68 2a 0f 80 00       	push   $0x800f2a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 47 0f 80 00       	push   $0x800f47
  8001ca:	e8 91 01 00 00       	call   800360 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8001eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8001f0:	89 fb                	mov    %edi,%ebx
  8001f2:	89 fe                	mov    %edi,%esi
  8001f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 08                	push   $0x8
  800200:	68 2a 0f 80 00       	push   $0x800f2a
  800205:	6a 23                	push   $0x23
  800207:	68 47 0f 80 00       	push   $0x800f47
  80020c:	e8 4f 01 00 00       	call   800360 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800228:	b8 06 00 00 00       	mov    $0x6,%eax
  80022d:	bf 00 00 00 00       	mov    $0x0,%edi
  800232:	89 fb                	mov    %edi,%ebx
  800234:	89 fe                	mov    %edi,%esi
  800236:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 06                	push   $0x6
  800242:	68 2a 0f 80 00       	push   $0x800f2a
  800247:	6a 23                	push   $0x23
  800249:	68 47 0f 80 00       	push   $0x800f47
  80024e:	e8 0d 01 00 00       	call   800360 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	8b 55 08             	mov    0x8(%ebp),%edx
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80026d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800270:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800273:	b8 05 00 00 00       	mov    $0x5,%eax
  800278:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 05                	push   $0x5
  800284:	68 2a 0f 80 00       	push   $0x800f2a
  800289:	6a 23                	push   $0x23
  80028b:	68 47 0f 80 00       	push   $0x800f47
  800290:	e8 cb 00 00 00       	call   800360 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 0c             	sub    $0xc,%esp
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	b8 04 00 00 00       	mov    $0x4,%eax
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	89 fe                	mov    %edi,%esi
  8002bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	7e 17                	jle    8002d8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	50                   	push   %eax
  8002c5:	6a 04                	push   $0x4
  8002c7:	68 2a 0f 80 00       	push   $0x800f2a
  8002cc:	6a 23                	push   $0x23
  8002ce:	68 47 0f 80 00       	push   $0x800f47
  8002d3:	e8 88 00 00 00       	call   800360 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8002f0:	89 fa                	mov    %edi,%edx
  8002f2:	89 f9                	mov    %edi,%ecx
  8002f4:	89 fb                	mov    %edi,%ebx
  8002f6:	89 fe                	mov    %edi,%esi
  8002f8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8002fa:	5b                   	pop    %ebx
  8002fb:	5e                   	pop    %esi
  8002fc:	5f                   	pop    %edi
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800305:	b8 02 00 00 00       	mov    $0x2,%eax
  80030a:	bf 00 00 00 00       	mov    $0x0,%edi
  80030f:	89 fa                	mov    %edi,%edx
  800311:	89 f9                	mov    %edi,%ecx
  800313:	89 fb                	mov    %edi,%ebx
  800315:	89 fe                	mov    %edi,%esi
  800317:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	b8 03 00 00 00       	mov    $0x3,%eax
  80032f:	bf 00 00 00 00       	mov    $0x0,%edi
  800334:	89 f9                	mov    %edi,%ecx
  800336:	89 fb                	mov    %edi,%ebx
  800338:	89 fe                	mov    %edi,%esi
  80033a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	7e 17                	jle    800357 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	50                   	push   %eax
  800344:	6a 03                	push   $0x3
  800346:	68 2a 0f 80 00       	push   $0x800f2a
  80034b:	6a 23                	push   $0x23
  80034d:	68 47 0f 80 00       	push   $0x800f47
  800352:	e8 09 00 00 00       	call   800360 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    
	...

00800360 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	53                   	push   %ebx
  800364:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800367:	8d 45 14             	lea    0x14(%ebp),%eax
  80036a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80036d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800373:	e8 87 ff ff ff       	call   8002ff <sys_getenvid>
  800378:	83 ec 0c             	sub    $0xc,%esp
  80037b:	ff 75 0c             	pushl  0xc(%ebp)
  80037e:	ff 75 08             	pushl  0x8(%ebp)
  800381:	53                   	push   %ebx
  800382:	50                   	push   %eax
  800383:	68 58 0f 80 00       	push   $0x800f58
  800388:	e8 74 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80038d:	83 c4 18             	add    $0x18,%esp
  800390:	ff 75 f8             	pushl  -0x8(%ebp)
  800393:	ff 75 10             	pushl  0x10(%ebp)
  800396:	e8 15 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80039b:	c7 04 24 7b 0f 80 00 	movl   $0x800f7b,(%esp)
  8003a2:	e8 5a 00 00 00       	call   800401 <cprintf>
  8003a7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003aa:	cc                   	int3   
  8003ab:	eb fd                	jmp    8003aa <_panic+0x4a>
  8003ad:	00 00                	add    %al,(%eax)
	...

008003b0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b9:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8003c0:	00 00 00 
	b.cnt = 0;
  8003c3:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8003ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cd:	ff 75 0c             	pushl  0xc(%ebp)
  8003d0:	ff 75 08             	pushl  0x8(%ebp)
  8003d3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d9:	50                   	push   %eax
  8003da:	68 18 04 80 00       	push   $0x800418
  8003df:	e8 70 01 00 00       	call   800554 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e4:	83 c4 08             	add    $0x8,%esp
  8003e7:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  8003ed:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	e8 d2 fc ff ff       	call   8000cb <sys_cputs>
  8003f9:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
  80040a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  80040d:	50                   	push   %eax
  80040e:	ff 75 08             	pushl  0x8(%ebp)
  800411:	e8 9a ff ff ff       	call   8003b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	53                   	push   %ebx
  80041c:	83 ec 04             	sub    $0x4,%esp
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800422:	8b 03                	mov    (%ebx),%eax
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80042b:	40                   	inc    %eax
  80042c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80042e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800433:	75 1a                	jne    80044f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	68 ff 00 00 00       	push   $0xff
  80043d:	8d 43 08             	lea    0x8(%ebx),%eax
  800440:	50                   	push   %eax
  800441:	e8 85 fc ff ff       	call   8000cb <sys_cputs>
		b->idx = 0;
  800446:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80044c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80044f:	ff 43 04             	incl   0x4(%ebx)
}
  800452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800455:	c9                   	leave  
  800456:	c3                   	ret    
	...

00800458 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	57                   	push   %edi
  80045c:	56                   	push   %esi
  80045d:	53                   	push   %ebx
  80045e:	83 ec 1c             	sub    $0x1c,%esp
  800461:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800464:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800470:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800473:	8b 55 10             	mov    0x10(%ebp),%edx
  800476:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800479:	89 d6                	mov    %edx,%esi
  80047b:	bf 00 00 00 00       	mov    $0x0,%edi
  800480:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  800483:	72 04                	jb     800489 <printnum+0x31>
  800485:	39 c2                	cmp    %eax,%edx
  800487:	77 3f                	ja     8004c8 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800489:	83 ec 0c             	sub    $0xc,%esp
  80048c:	ff 75 18             	pushl  0x18(%ebp)
  80048f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800492:	50                   	push   %eax
  800493:	52                   	push   %edx
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049c:	ff 75 e0             	pushl  -0x20(%ebp)
  80049f:	e8 d4 07 00 00       	call   800c78 <__udivdi3>
  8004a4:	83 c4 18             	add    $0x18,%esp
  8004a7:	52                   	push   %edx
  8004a8:	50                   	push   %eax
  8004a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8004af:	e8 a4 ff ff ff       	call   800458 <printnum>
  8004b4:	83 c4 20             	add    $0x20,%esp
  8004b7:	eb 14                	jmp    8004cd <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 e8             	pushl  -0x18(%ebp)
  8004bf:	ff 75 18             	pushl  0x18(%ebp)
  8004c2:	ff 55 ec             	call   *-0x14(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c8:	4b                   	dec    %ebx
  8004c9:	85 db                	test   %ebx,%ebx
  8004cb:	7f ec                	jg     8004b9 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 e8             	pushl  -0x18(%ebp)
  8004d3:	83 ec 04             	sub    $0x4,%esp
  8004d6:	57                   	push   %edi
  8004d7:	56                   	push   %esi
  8004d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004db:	ff 75 e0             	pushl  -0x20(%ebp)
  8004de:	e8 c1 08 00 00       	call   800da4 <__umoddi3>
  8004e3:	83 c4 14             	add    $0x14,%esp
  8004e6:	0f be 80 7d 0f 80 00 	movsbl 0x800f7d(%eax),%eax
  8004ed:	50                   	push   %eax
  8004ee:	ff 55 ec             	call   *-0x14(%ebp)
  8004f1:	83 c4 10             	add    $0x10,%esp
}
  8004f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5f                   	pop    %edi
  8004fa:	c9                   	leave  
  8004fb:	c3                   	ret    

008004fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  800501:	83 fa 01             	cmp    $0x1,%edx
  800504:	7e 0e                	jle    800514 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800506:	8b 10                	mov    (%eax),%edx
  800508:	8d 42 08             	lea    0x8(%edx),%eax
  80050b:	89 01                	mov    %eax,(%ecx)
  80050d:	8b 02                	mov    (%edx),%eax
  80050f:	8b 52 04             	mov    0x4(%edx),%edx
  800512:	eb 22                	jmp    800536 <getuint+0x3a>
	else if (lflag)
  800514:	85 d2                	test   %edx,%edx
  800516:	74 10                	je     800528 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800518:	8b 10                	mov    (%eax),%edx
  80051a:	8d 42 04             	lea    0x4(%edx),%eax
  80051d:	89 01                	mov    %eax,(%ecx)
  80051f:	8b 02                	mov    (%edx),%eax
  800521:	ba 00 00 00 00       	mov    $0x0,%edx
  800526:	eb 0e                	jmp    800536 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	8d 42 04             	lea    0x4(%edx),%eax
  80052d:	89 01                	mov    %eax,(%ecx)
  80052f:	8b 02                	mov    (%edx),%eax
  800531:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80053e:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  800541:	8b 11                	mov    (%ecx),%edx
  800543:	3b 51 04             	cmp    0x4(%ecx),%edx
  800546:	73 0a                	jae    800552 <sprintputch+0x1a>
		*b->buf++ = ch;
  800548:	8b 45 08             	mov    0x8(%ebp),%eax
  80054b:	88 02                	mov    %al,(%edx)
  80054d:	8d 42 01             	lea    0x1(%edx),%eax
  800550:	89 01                	mov    %eax,(%ecx)
}
  800552:	c9                   	leave  
  800553:	c3                   	ret    

00800554 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	57                   	push   %edi
  800558:	56                   	push   %esi
  800559:	53                   	push   %ebx
  80055a:	83 ec 3c             	sub    $0x3c,%esp
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800563:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800566:	eb 1a                	jmp    800582 <vprintfmt+0x2e>
  800568:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80056b:	eb 15                	jmp    800582 <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80056d:	84 c0                	test   %al,%al
  80056f:	0f 84 15 03 00 00    	je     80088a <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	57                   	push   %edi
  800579:	0f b6 c0             	movzbl %al,%eax
  80057c:	50                   	push   %eax
  80057d:	ff d6                	call   *%esi
  80057f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800582:	8a 03                	mov    (%ebx),%al
  800584:	43                   	inc    %ebx
  800585:	3c 25                	cmp    $0x25,%al
  800587:	75 e4                	jne    80056d <vprintfmt+0x19>
  800589:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800590:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800597:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80059e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8005a5:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8005a9:	eb 0a                	jmp    8005b5 <vprintfmt+0x61>
  8005ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8005b2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8a 03                	mov    (%ebx),%al
  8005b7:	0f b6 d0             	movzbl %al,%edx
  8005ba:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8005bd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8005c0:	83 e8 23             	sub    $0x23,%eax
  8005c3:	3c 55                	cmp    $0x55,%al
  8005c5:	0f 87 9c 02 00 00    	ja     800867 <vprintfmt+0x313>
  8005cb:	0f b6 c0             	movzbl %al,%eax
  8005ce:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8005d5:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  8005d9:	eb d7                	jmp    8005b2 <vprintfmt+0x5e>
  8005db:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  8005df:	eb d1                	jmp    8005b2 <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  8005e1:	89 d9                	mov    %ebx,%ecx
  8005e3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ea:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ed:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8005f0:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  8005f7:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  8005fb:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  8005fc:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005ff:	83 f8 09             	cmp    $0x9,%eax
  800602:	77 21                	ja     800625 <vprintfmt+0xd1>
  800604:	eb e4                	jmp    8005ea <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800606:	8b 55 14             	mov    0x14(%ebp),%edx
  800609:	8d 42 04             	lea    0x4(%edx),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
  80060f:	8b 12                	mov    (%edx),%edx
  800611:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800614:	eb 12                	jmp    800628 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800616:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061a:	79 96                	jns    8005b2 <vprintfmt+0x5e>
  80061c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800623:	eb 8d                	jmp    8005b2 <vprintfmt+0x5e>
  800625:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800628:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80062c:	79 84                	jns    8005b2 <vprintfmt+0x5e>
  80062e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80063b:	e9 72 ff ff ff       	jmp    8005b2 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800640:	ff 45 d4             	incl   -0x2c(%ebp)
  800643:	e9 6a ff ff ff       	jmp    8005b2 <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800648:	8b 55 14             	mov    0x14(%ebp),%edx
  80064b:	8d 42 04             	lea    0x4(%edx),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	57                   	push   %edi
  800655:	ff 32                	pushl  (%edx)
  800657:	ff d6                	call   *%esi
			break;
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	e9 07 ff ff ff       	jmp    800568 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800661:	8b 55 14             	mov    0x14(%ebp),%edx
  800664:	8d 42 04             	lea    0x4(%edx),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
  80066a:	8b 02                	mov    (%edx),%eax
  80066c:	85 c0                	test   %eax,%eax
  80066e:	79 02                	jns    800672 <vprintfmt+0x11e>
  800670:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800672:	83 f8 0f             	cmp    $0xf,%eax
  800675:	7f 0b                	jg     800682 <vprintfmt+0x12e>
  800677:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80067e:	85 d2                	test   %edx,%edx
  800680:	75 15                	jne    800697 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  800682:	50                   	push   %eax
  800683:	68 8e 0f 80 00       	push   $0x800f8e
  800688:	57                   	push   %edi
  800689:	56                   	push   %esi
  80068a:	e8 6e 02 00 00       	call   8008fd <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	e9 d1 fe ff ff       	jmp    800568 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800697:	52                   	push   %edx
  800698:	68 97 0f 80 00       	push   $0x800f97
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	e8 59 02 00 00       	call   8008fd <printfmt>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	e9 bc fe ff ff       	jmp    800568 <vprintfmt+0x14>
  8006ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006af:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8006b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b5:	8b 55 14             	mov    0x14(%ebp),%edx
  8006b8:	8d 42 04             	lea    0x4(%edx),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006be:	8b 1a                	mov    (%edx),%ebx
  8006c0:	85 db                	test   %ebx,%ebx
  8006c2:	75 05                	jne    8006c9 <vprintfmt+0x175>
  8006c4:	bb 9a 0f 80 00       	mov    $0x800f9a,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8006c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006cd:	7e 66                	jle    800735 <vprintfmt+0x1e1>
  8006cf:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8006d3:	74 60                	je     800735 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	51                   	push   %ecx
  8006d9:	53                   	push   %ebx
  8006da:	e8 57 02 00 00       	call   800936 <strnlen>
  8006df:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8006e2:	29 c1                	sub    %eax,%ecx
  8006e4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  8006ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006f1:	eb 0f                	jmp    800702 <vprintfmt+0x1ae>
					putch(padc, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	57                   	push   %edi
  8006f7:	ff 75 c4             	pushl  -0x3c(%ebp)
  8006fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	ff 4d d8             	decl   -0x28(%ebp)
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800706:	7f eb                	jg     8006f3 <vprintfmt+0x19f>
  800708:	eb 2b                	jmp    800735 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070a:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  80070d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800711:	74 15                	je     800728 <vprintfmt+0x1d4>
  800713:	8d 42 e0             	lea    -0x20(%edx),%eax
  800716:	83 f8 5e             	cmp    $0x5e,%eax
  800719:	76 0d                	jbe    800728 <vprintfmt+0x1d4>
					putch('?', putdat);
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	57                   	push   %edi
  80071f:	6a 3f                	push   $0x3f
  800721:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	eb 0a                	jmp    800732 <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	57                   	push   %edi
  80072c:	52                   	push   %edx
  80072d:	ff d6                	call   *%esi
  80072f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800732:	ff 4d d8             	decl   -0x28(%ebp)
  800735:	8a 03                	mov    (%ebx),%al
  800737:	43                   	inc    %ebx
  800738:	84 c0                	test   %al,%al
  80073a:	74 1b                	je     800757 <vprintfmt+0x203>
  80073c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800740:	78 c8                	js     80070a <vprintfmt+0x1b6>
  800742:	ff 4d dc             	decl   -0x24(%ebp)
  800745:	79 c3                	jns    80070a <vprintfmt+0x1b6>
  800747:	eb 0e                	jmp    800757 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	57                   	push   %edi
  80074d:	6a 20                	push   $0x20
  80074f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800751:	ff 4d d8             	decl   -0x28(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075b:	7f ec                	jg     800749 <vprintfmt+0x1f5>
  80075d:	e9 06 fe ff ff       	jmp    800568 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800762:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800766:	7e 10                	jle    800778 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800768:	8b 55 14             	mov    0x14(%ebp),%edx
  80076b:	8d 42 08             	lea    0x8(%edx),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
  800771:	8b 02                	mov    (%edx),%eax
  800773:	8b 52 04             	mov    0x4(%edx),%edx
  800776:	eb 20                	jmp    800798 <vprintfmt+0x244>
	else if (lflag)
  800778:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077c:	74 0e                	je     80078c <vprintfmt+0x238>
		return va_arg(*ap, long);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)
  800787:	8b 00                	mov    (%eax),%eax
  800789:	99                   	cltd   
  80078a:	eb 0c                	jmp    800798 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)
  800795:	8b 00                	mov    (%eax),%eax
  800797:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800798:	89 d1                	mov    %edx,%ecx
  80079a:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  80079c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80079f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	78 0a                	js     8007b0 <vprintfmt+0x25c>
  8007a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007ab:	e9 89 00 00 00       	jmp    800839 <vprintfmt+0x2e5>
				putch('-', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	57                   	push   %edi
  8007b4:	6a 2d                	push   $0x2d
  8007b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007bb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007be:	f7 da                	neg    %edx
  8007c0:	83 d1 00             	adc    $0x0,%ecx
  8007c3:	f7 d9                	neg    %ecx
  8007c5:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	eb 6a                	jmp    800839 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d5:	e8 22 fd ff ff       	call   8004fc <getuint>
  8007da:	89 d1                	mov    %edx,%ecx
  8007dc:	89 c2                	mov    %eax,%edx
  8007de:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8007e3:	eb 54                	jmp    800839 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007eb:	e8 0c fd ff ff       	call   8004fc <getuint>
  8007f0:	89 d1                	mov    %edx,%ecx
  8007f2:	89 c2                	mov    %eax,%edx
  8007f4:	bb 08 00 00 00       	mov    $0x8,%ebx
  8007f9:	eb 3e                	jmp    800839 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	57                   	push   %edi
  8007ff:	6a 30                	push   $0x30
  800801:	ff d6                	call   *%esi
			putch('x', putdat);
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	57                   	push   %edi
  800807:	6a 78                	push   $0x78
  800809:	ff d6                	call   *%esi
			num = (unsigned long long)
  80080b:	8b 55 14             	mov    0x14(%ebp),%edx
  80080e:	8d 42 04             	lea    0x4(%edx),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
  800814:	8b 12                	mov    (%edx),%edx
  800816:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081b:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	eb 14                	jmp    800839 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80082b:	e8 cc fc ff ff       	call   8004fc <getuint>
  800830:	89 d1                	mov    %edx,%ecx
  800832:	89 c2                	mov    %eax,%edx
  800834:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800839:	83 ec 0c             	sub    $0xc,%esp
  80083c:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 d8             	pushl  -0x28(%ebp)
  800844:	53                   	push   %ebx
  800845:	51                   	push   %ecx
  800846:	52                   	push   %edx
  800847:	89 fa                	mov    %edi,%edx
  800849:	89 f0                	mov    %esi,%eax
  80084b:	e8 08 fc ff ff       	call   800458 <printnum>
			break;
  800850:	83 c4 20             	add    $0x20,%esp
  800853:	e9 10 fd ff ff       	jmp    800568 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	57                   	push   %edi
  80085c:	52                   	push   %edx
  80085d:	ff d6                	call   *%esi
			break;
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	e9 01 fd ff ff       	jmp    800568 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	57                   	push   %edi
  80086b:	6a 25                	push   $0x25
  80086d:	ff d6                	call   *%esi
  80086f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800872:	83 ea 02             	sub    $0x2,%edx
  800875:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800878:	8a 02                	mov    (%edx),%al
  80087a:	4a                   	dec    %edx
  80087b:	3c 25                	cmp    $0x25,%al
  80087d:	75 f9                	jne    800878 <vprintfmt+0x324>
  80087f:	83 c2 02             	add    $0x2,%edx
  800882:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800885:	e9 de fc ff ff       	jmp    800568 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  80088a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5f                   	pop    %edi
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	83 ec 18             	sub    $0x18,%esp
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80089e:	85 d2                	test   %edx,%edx
  8008a0:	74 37                	je     8008d9 <vsnprintf+0x47>
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	7e 33                	jle    8008d9 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008ad:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  8008b4:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b7:	ff 75 14             	pushl  0x14(%ebp)
  8008ba:	ff 75 10             	pushl  0x10(%ebp)
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	50                   	push   %eax
  8008c1:	68 38 05 80 00       	push   $0x800538
  8008c6:	e8 89 fc ff ff       	call   800554 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	eb 05                	jmp    8008de <vsnprintf+0x4c>
  8008d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008ec:	50                   	push   %eax
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 97 ff ff ff       	call   800892 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
  800906:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800909:	50                   	push   %eax
  80090a:	ff 75 10             	pushl  0x10(%ebp)
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	ff 75 08             	pushl  0x8(%ebp)
  800913:	e8 3c fc ff ff       	call   800554 <vprintfmt>
	va_end(ap);
  800918:	83 c4 10             	add    $0x10,%esp
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    
  80091d:	00 00                	add    %al,(%eax)
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 01                	jmp    80092e <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  80092d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092e:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800932:	75 f9                	jne    80092d <strlen+0xd>
		n++;
	return n;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb 01                	jmp    800947 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800946:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	39 d0                	cmp    %edx,%eax
  800949:	74 06                	je     800951 <strnlen+0x1b>
  80094b:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  80094f:	75 f5                	jne    800946 <strnlen+0x10>
		n++;
	return n;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800959:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095c:	8a 01                	mov    (%ecx),%al
  80095e:	88 02                	mov    %al,(%edx)
  800960:	42                   	inc    %edx
  800961:	41                   	inc    %ecx
  800962:	84 c0                	test   %al,%al
  800964:	75 f6                	jne    80095c <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800972:	53                   	push   %ebx
  800973:	e8 a8 ff ff ff       	call   800920 <strlen>
	strcpy(dst + len, src);
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80097e:	50                   	push   %eax
  80097f:	e8 cf ff ff ff       	call   800953 <strcpy>
	return dst;
}
  800984:	89 d8                	mov    %ebx,%eax
  800986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 75 08             	mov    0x8(%ebp),%esi
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800999:	b9 00 00 00 00       	mov    $0x0,%ecx
  80099e:	eb 0c                	jmp    8009ac <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8009a0:	8a 02                	mov    (%edx),%al
  8009a2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a5:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ab:	41                   	inc    %ecx
  8009ac:	39 d9                	cmp    %ebx,%ecx
  8009ae:	75 f0                	jne    8009a0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b0:	89 f0                	mov    %esi,%eax
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c4:	85 c9                	test   %ecx,%ecx
  8009c6:	75 04                	jne    8009cc <strlcpy+0x16>
  8009c8:	89 f0                	mov    %esi,%eax
  8009ca:	eb 14                	jmp    8009e0 <strlcpy+0x2a>
  8009cc:	89 f0                	mov    %esi,%eax
  8009ce:	eb 04                	jmp    8009d4 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d0:	88 10                	mov    %dl,(%eax)
  8009d2:	40                   	inc    %eax
  8009d3:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d4:	49                   	dec    %ecx
  8009d5:	74 06                	je     8009dd <strlcpy+0x27>
  8009d7:	8a 13                	mov    (%ebx),%dl
  8009d9:	84 d2                	test   %dl,%dl
  8009db:	75 f3                	jne    8009d0 <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  8009dd:	c6 00 00             	movb   $0x0,(%eax)
  8009e0:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ef:	eb 02                	jmp    8009f3 <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  8009f1:	42                   	inc    %edx
  8009f2:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009f3:	8a 02                	mov    (%edx),%al
  8009f5:	84 c0                	test   %al,%al
  8009f7:	74 04                	je     8009fd <strcmp+0x17>
  8009f9:	3a 01                	cmp    (%ecx),%al
  8009fb:	74 f4                	je     8009f1 <strcmp+0xb>
  8009fd:	0f b6 c0             	movzbl %al,%eax
  800a00:	0f b6 11             	movzbl (%ecx),%edx
  800a03:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a11:	8b 55 10             	mov    0x10(%ebp),%edx
  800a14:	eb 03                	jmp    800a19 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800a16:	4a                   	dec    %edx
  800a17:	41                   	inc    %ecx
  800a18:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a19:	85 d2                	test   %edx,%edx
  800a1b:	75 07                	jne    800a24 <strncmp+0x1d>
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	eb 14                	jmp    800a38 <strncmp+0x31>
  800a24:	8a 01                	mov    (%ecx),%al
  800a26:	84 c0                	test   %al,%al
  800a28:	74 04                	je     800a2e <strncmp+0x27>
  800a2a:	3a 03                	cmp    (%ebx),%al
  800a2c:	74 e8                	je     800a16 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2e:	0f b6 d0             	movzbl %al,%edx
  800a31:	0f b6 03             	movzbl (%ebx),%eax
  800a34:	29 c2                	sub    %eax,%edx
  800a36:	89 d0                	mov    %edx,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a44:	eb 05                	jmp    800a4b <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800a46:	38 ca                	cmp    %cl,%dl
  800a48:	74 0c                	je     800a56 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	40                   	inc    %eax
  800a4b:	8a 10                	mov    (%eax),%dl
  800a4d:	84 d2                	test   %dl,%dl
  800a4f:	75 f5                	jne    800a46 <strchr+0xb>
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a61:	eb 05                	jmp    800a68 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800a63:	38 ca                	cmp    %cl,%dl
  800a65:	74 07                	je     800a6e <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a67:	40                   	inc    %eax
  800a68:	8a 10                	mov    (%eax),%dl
  800a6a:	84 d2                	test   %dl,%dl
  800a6c:	75 f5                	jne    800a63 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	74 36                	je     800ab9 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a83:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a89:	75 29                	jne    800ab4 <memset+0x44>
  800a8b:	f6 c3 03             	test   $0x3,%bl
  800a8e:	75 24                	jne    800ab4 <memset+0x44>
		c &= 0xFF;
  800a90:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	c1 e6 08             	shl    $0x8,%esi
  800a98:	89 d0                	mov    %edx,%eax
  800a9a:	c1 e0 18             	shl    $0x18,%eax
  800a9d:	89 d1                	mov    %edx,%ecx
  800a9f:	c1 e1 10             	shl    $0x10,%ecx
  800aa2:	09 c8                	or     %ecx,%eax
  800aa4:	09 c2                	or     %eax,%edx
  800aa6:	89 f0                	mov    %esi,%eax
  800aa8:	09 d0                	or     %edx,%eax
  800aaa:	89 d9                	mov    %ebx,%ecx
  800aac:	c1 e9 02             	shr    $0x2,%ecx
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb 05                	jmp    800ab9 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab4:	89 d9                	mov    %ebx,%ecx
  800ab6:	fc                   	cld    
  800ab7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab9:	89 f8                	mov    %edi,%eax
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ace:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad0:	39 c6                	cmp    %eax,%esi
  800ad2:	73 36                	jae    800b0a <memmove+0x4a>
  800ad4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad7:	39 d0                	cmp    %edx,%eax
  800ad9:	73 2f                	jae    800b0a <memmove+0x4a>
		s += n;
		d += n;
  800adb:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ade:	f6 c2 03             	test   $0x3,%dl
  800ae1:	75 1b                	jne    800afe <memmove+0x3e>
  800ae3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae9:	75 13                	jne    800afe <memmove+0x3e>
  800aeb:	f6 c1 03             	test   $0x3,%cl
  800aee:	75 0e                	jne    800afe <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800af0:	8d 7e fc             	lea    -0x4(%esi),%edi
  800af3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af6:	c1 e9 02             	shr    $0x2,%ecx
  800af9:	fd                   	std    
  800afa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afc:	eb 09                	jmp    800b07 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afe:	8d 7e ff             	lea    -0x1(%esi),%edi
  800b01:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b04:	fd                   	std    
  800b05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b07:	fc                   	cld    
  800b08:	eb 20                	jmp    800b2a <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b10:	75 15                	jne    800b27 <memmove+0x67>
  800b12:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b18:	75 0d                	jne    800b27 <memmove+0x67>
  800b1a:	f6 c1 03             	test   $0x3,%cl
  800b1d:	75 08                	jne    800b27 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
  800b22:	fc                   	cld    
  800b23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b25:	eb 03                	jmp    800b2a <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b27:	fc                   	cld    
  800b28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b31:	ff 75 10             	pushl  0x10(%ebp)
  800b34:	ff 75 0c             	pushl  0xc(%ebp)
  800b37:	ff 75 08             	pushl  0x8(%ebp)
  800b3a:	e8 81 ff ff ff       	call   800ac0 <memmove>
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	53                   	push   %ebx
  800b45:	83 ec 04             	sub    $0x4,%esp
  800b48:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	eb 1b                	jmp    800b6e <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800b53:	8a 1a                	mov    (%edx),%bl
  800b55:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800b58:	8a 19                	mov    (%ecx),%bl
  800b5a:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800b5d:	74 0d                	je     800b6c <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800b5f:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800b63:	0f b6 c3             	movzbl %bl,%eax
  800b66:	29 c2                	sub    %eax,%edx
  800b68:	89 d0                	mov    %edx,%eax
  800b6a:	eb 0d                	jmp    800b79 <memcmp+0x38>
		s1++, s2++;
  800b6c:	42                   	inc    %edx
  800b6d:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	48                   	dec    %eax
  800b6f:	83 f8 ff             	cmp    $0xffffffff,%eax
  800b72:	75 df                	jne    800b53 <memcmp+0x12>
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b79:	83 c4 04             	add    $0x4,%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b88:	89 c2                	mov    %eax,%edx
  800b8a:	03 55 10             	add    0x10(%ebp),%edx
  800b8d:	eb 05                	jmp    800b94 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8f:	38 08                	cmp    %cl,(%eax)
  800b91:	74 05                	je     800b98 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b93:	40                   	inc    %eax
  800b94:	39 d0                	cmp    %edx,%eax
  800b96:	72 f7                	jb     800b8f <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 04             	sub    $0x4,%esp
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	8b 75 10             	mov    0x10(%ebp),%esi
  800ba9:	eb 01                	jmp    800bac <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800bab:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bac:	8a 01                	mov    (%ecx),%al
  800bae:	3c 20                	cmp    $0x20,%al
  800bb0:	74 f9                	je     800bab <strtol+0x11>
  800bb2:	3c 09                	cmp    $0x9,%al
  800bb4:	74 f5                	je     800bab <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb6:	3c 2b                	cmp    $0x2b,%al
  800bb8:	75 0a                	jne    800bc4 <strtol+0x2a>
		s++;
  800bba:	41                   	inc    %ecx
  800bbb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bc2:	eb 17                	jmp    800bdb <strtol+0x41>
	else if (*s == '-')
  800bc4:	3c 2d                	cmp    $0x2d,%al
  800bc6:	74 09                	je     800bd1 <strtol+0x37>
  800bc8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bcf:	eb 0a                	jmp    800bdb <strtol+0x41>
		s++, neg = 1;
  800bd1:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bd4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdb:	85 f6                	test   %esi,%esi
  800bdd:	74 05                	je     800be4 <strtol+0x4a>
  800bdf:	83 fe 10             	cmp    $0x10,%esi
  800be2:	75 1a                	jne    800bfe <strtol+0x64>
  800be4:	8a 01                	mov    (%ecx),%al
  800be6:	3c 30                	cmp    $0x30,%al
  800be8:	75 10                	jne    800bfa <strtol+0x60>
  800bea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bee:	75 0a                	jne    800bfa <strtol+0x60>
		s += 2, base = 16;
  800bf0:	83 c1 02             	add    $0x2,%ecx
  800bf3:	be 10 00 00 00       	mov    $0x10,%esi
  800bf8:	eb 04                	jmp    800bfe <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800bfa:	85 f6                	test   %esi,%esi
  800bfc:	74 07                	je     800c05 <strtol+0x6b>
  800bfe:	bf 00 00 00 00       	mov    $0x0,%edi
  800c03:	eb 13                	jmp    800c18 <strtol+0x7e>
  800c05:	3c 30                	cmp    $0x30,%al
  800c07:	74 07                	je     800c10 <strtol+0x76>
  800c09:	be 0a 00 00 00       	mov    $0xa,%esi
  800c0e:	eb ee                	jmp    800bfe <strtol+0x64>
		s++, base = 8;
  800c10:	41                   	inc    %ecx
  800c11:	be 08 00 00 00       	mov    $0x8,%esi
  800c16:	eb e6                	jmp    800bfe <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c18:	8a 11                	mov    (%ecx),%dl
  800c1a:	88 d3                	mov    %dl,%bl
  800c1c:	8d 42 d0             	lea    -0x30(%edx),%eax
  800c1f:	3c 09                	cmp    $0x9,%al
  800c21:	77 08                	ja     800c2b <strtol+0x91>
			dig = *s - '0';
  800c23:	0f be c2             	movsbl %dl,%eax
  800c26:	8d 50 d0             	lea    -0x30(%eax),%edx
  800c29:	eb 1c                	jmp    800c47 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c2b:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800c2e:	3c 19                	cmp    $0x19,%al
  800c30:	77 08                	ja     800c3a <strtol+0xa0>
			dig = *s - 'a' + 10;
  800c32:	0f be c2             	movsbl %dl,%eax
  800c35:	8d 50 a9             	lea    -0x57(%eax),%edx
  800c38:	eb 0d                	jmp    800c47 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c3a:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800c3d:	3c 19                	cmp    $0x19,%al
  800c3f:	77 15                	ja     800c56 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800c41:	0f be c2             	movsbl %dl,%eax
  800c44:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800c47:	39 f2                	cmp    %esi,%edx
  800c49:	7d 0b                	jge    800c56 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800c4b:	41                   	inc    %ecx
  800c4c:	89 f8                	mov    %edi,%eax
  800c4e:	0f af c6             	imul   %esi,%eax
  800c51:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800c54:	eb c2                	jmp    800c18 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800c56:	89 f8                	mov    %edi,%eax

	if (endptr)
  800c58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5c:	74 05                	je     800c63 <strtol+0xc9>
		*endptr = (char *) s;
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c61:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800c63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c67:	74 04                	je     800c6d <strtol+0xd3>
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	f7 df                	neg    %edi
}
  800c6d:	89 f8                	mov    %edi,%eax
  800c6f:	83 c4 04             	add    $0x4,%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    
	...

00800c78 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	83 ec 28             	sub    $0x28,%esp
  800c80:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c87:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c91:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800c94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c97:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800c99:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  800ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca4:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ca7:	85 ff                	test   %edi,%edi
  800ca9:	75 21                	jne    800ccc <__udivdi3+0x54>
    {
      if (d0 > n1)
  800cab:	39 d1                	cmp    %edx,%ecx
  800cad:	76 49                	jbe    800cf8 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800caf:	f7 f1                	div    %ecx
  800cb1:	89 c1                	mov    %eax,%ecx
  800cb3:	31 c0                	xor    %eax,%eax
  800cb5:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cb8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800cbb:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800cc4:	83 c4 28             	add    $0x28,%esp
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    
  800ccb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ccc:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ccf:	0f 87 97 00 00 00    	ja     800d6c <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800cd5:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800cd8:	83 f0 1f             	xor    $0x1f,%eax
  800cdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800cde:	75 34                	jne    800d14 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ce0:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  800ce3:	72 08                	jb     800ced <__udivdi3+0x75>
  800ce5:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ce8:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800ceb:	77 7f                	ja     800d6c <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ced:	b9 01 00 00 00       	mov    $0x1,%ecx
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	eb c2                	jmp    800cb8 <__udivdi3+0x40>
  800cf6:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	74 79                	je     800d78 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800cff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d02:	89 fa                	mov    %edi,%edx
  800d04:	f7 f1                	div    %ecx
  800d06:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d0b:	f7 f1                	div    %ecx
  800d0d:	89 c1                	mov    %eax,%ecx
  800d0f:	89 f0                	mov    %esi,%eax
  800d11:	eb a5                	jmp    800cb8 <__udivdi3+0x40>
  800d13:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d14:	b8 20 00 00 00       	mov    $0x20,%eax
  800d19:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800d1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d1f:	89 fa                	mov    %edi,%edx
  800d21:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d24:	d3 e2                	shl    %cl,%edx
  800d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d29:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d2c:	d3 e8                	shr    %cl,%eax
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  800d32:	8b 75 f4             	mov    -0xc(%ebp),%esi
  800d35:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d38:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d3d:	d3 e0                	shl    %cl,%eax
  800d3f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800d42:	8a 4d f0             	mov    -0x10(%ebp),%cl
  800d45:	d3 ea                	shr    %cl,%edx
  800d47:	09 d0                	or     %edx,%eax
  800d49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d4c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d4f:	d3 ea                	shr    %cl,%edx
  800d51:	f7 f7                	div    %edi
  800d53:	89 d7                	mov    %edx,%edi
  800d55:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800d58:	f7 e6                	mul    %esi
  800d5a:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d5c:	39 d7                	cmp    %edx,%edi
  800d5e:	72 38                	jb     800d98 <__udivdi3+0x120>
  800d60:	74 27                	je     800d89 <__udivdi3+0x111>
  800d62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d65:	31 c0                	xor    %eax,%eax
  800d67:	e9 4c ff ff ff       	jmp    800cb8 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d6c:	31 c9                	xor    %ecx,%ecx
  800d6e:	31 c0                	xor    %eax,%eax
  800d70:	e9 43 ff ff ff       	jmp    800cb8 <__udivdi3+0x40>
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d78:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	f7 75 f4             	divl   -0xc(%ebp)
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	e9 76 ff ff ff       	jmp    800cff <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d8c:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800d8f:	d3 e0                	shl    %cl,%eax
  800d91:	39 f0                	cmp    %esi,%eax
  800d93:	73 cd                	jae    800d62 <__udivdi3+0xea>
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800d98:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d9b:	49                   	dec    %ecx
  800d9c:	31 c0                	xor    %eax,%eax
  800d9e:	e9 15 ff ff ff       	jmp    800cb8 <__udivdi3+0x40>
	...

00800da4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	83 ec 30             	sub    $0x30,%esp
  800dac:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800db3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800dba:	8b 75 08             	mov    0x8(%ebp),%esi
  800dbd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc3:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  800dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dc9:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  800dcb:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  800dce:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  800dd1:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dd4:	85 d2                	test   %edx,%edx
  800dd6:	75 1c                	jne    800df4 <__umoddi3+0x50>
    {
      if (d0 > n1)
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	39 f8                	cmp    %edi,%eax
  800ddc:	0f 86 c2 00 00 00    	jbe    800ea4 <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de2:	89 f0                	mov    %esi,%eax
  800de4:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  800de6:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  800de9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800df0:	eb 12                	jmp    800e04 <__umoddi3+0x60>
  800df2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800df7:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  800dfa:	76 18                	jbe    800e14 <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  800dfc:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  800dff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800e02:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e04:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800e07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e0a:	83 c4 30             	add    $0x30,%esp
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    
  800e11:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e14:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  800e18:	83 f0 1f             	xor    $0x1f,%eax
  800e1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e1e:	0f 84 ac 00 00 00    	je     800ed0 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e24:	b8 20 00 00 00       	mov    $0x20,%eax
  800e29:	2b 45 dc             	sub    -0x24(%ebp),%eax
  800e2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e2f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800e32:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e35:	d3 e2                	shl    %cl,%edx
  800e37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e3a:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e3d:	d3 e8                	shr    %cl,%eax
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  800e43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e46:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e49:	d3 e0                	shl    %cl,%eax
  800e4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e4e:	8b 7d f4             	mov    -0xc(%ebp),%edi
  800e51:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e56:	d3 e0                	shl    %cl,%eax
  800e58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5b:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e5e:	d3 ea                	shr    %cl,%edx
  800e60:	09 d0                	or     %edx,%eax
  800e62:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e65:	d3 ea                	shr    %cl,%edx
  800e67:	f7 f6                	div    %esi
  800e69:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  800e6c:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6f:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  800e72:	0f 82 8d 00 00 00    	jb     800f05 <__umoddi3+0x161>
  800e78:	0f 84 91 00 00 00    	je     800f0f <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800e7e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e81:	29 c7                	sub    %eax,%edi
  800e83:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800e85:	89 f2                	mov    %esi,%edx
  800e87:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  800e8a:	d3 e2                	shl    %cl,%edx
  800e8c:	89 f8                	mov    %edi,%eax
  800e8e:	8a 4d dc             	mov    -0x24(%ebp),%cl
  800e91:	d3 e8                	shr    %cl,%eax
  800e93:	09 c2                	or     %eax,%edx
  800e95:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  800e98:	d3 ee                	shr    %cl,%esi
  800e9a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800e9d:	e9 62 ff ff ff       	jmp    800e04 <__umoddi3+0x60>
  800ea2:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	74 15                	je     800ec0 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eae:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800eb1:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb6:	f7 f1                	div    %ecx
  800eb8:	e9 29 ff ff ff       	jmp    800de6 <__umoddi3+0x42>
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ec0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec5:	31 d2                	xor    %edx,%edx
  800ec7:	f7 75 ec             	divl   -0x14(%ebp)
  800eca:	89 c1                	mov    %eax,%ecx
  800ecc:	eb dd                	jmp    800eab <__umoddi3+0x107>
  800ece:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ed3:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  800ed6:	72 19                	jb     800ef1 <__umoddi3+0x14d>
  800ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800edb:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  800ede:	76 11                	jbe    800ef1 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  800ee0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee3:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  800ee6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ee9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800eec:	e9 13 ff ff ff       	jmp    800e04 <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ef1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  800efa:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  800efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f00:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800f03:	eb db                	jmp    800ee0 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f05:	2b 45 cc             	sub    -0x34(%ebp),%eax
  800f08:	19 f2                	sbb    %esi,%edx
  800f0a:	e9 6f ff ff ff       	jmp    800e7e <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0f:	39 c7                	cmp    %eax,%edi
  800f11:	72 f2                	jb     800f05 <__umoddi3+0x161>
  800f13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f16:	e9 63 ff ff ff       	jmp    800e7e <__umoddi3+0xda>
