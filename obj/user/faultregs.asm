
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 f7 04 00 00       	call   800528 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	89 c6                	mov    %eax,%esi
  80003f:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	ff 75 08             	pushl  0x8(%ebp)
  800044:	52                   	push   %edx
  800045:	68 f1 14 80 00       	push   $0x8014f1
  80004a:	68 c0 14 80 00       	push   $0x8014c0
  80004f:	e8 d9 05 00 00       	call   80062d <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800054:	ff 33                	pushl  (%ebx)
  800056:	ff 36                	pushl  (%esi)
  800058:	68 d0 14 80 00       	push   $0x8014d0
  80005d:	68 d4 14 80 00       	push   $0x8014d4
  800062:	e8 c6 05 00 00       	call   80062d <cprintf>
  800067:	83 c4 20             	add    $0x20,%esp
  80006a:	8b 06                	mov    (%esi),%eax
  80006c:	3b 03                	cmp    (%ebx),%eax
  80006e:	75 17                	jne    800087 <check_regs+0x53>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 e4 14 80 00       	push   $0x8014e4
  800078:	e8 b0 05 00 00       	call   80062d <cprintf>
  80007d:	bf 00 00 00 00       	mov    $0x0,%edi
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	eb 15                	jmp    80009c <check_regs+0x68>
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	68 e8 14 80 00       	push   $0x8014e8
  80008f:	e8 99 05 00 00       	call   80062d <cprintf>
  800094:	bf 01 00 00 00       	mov    $0x1,%edi
  800099:	83 c4 10             	add    $0x10,%esp
	CHECK(esi, regs.reg_esi);
  80009c:	ff 73 04             	pushl  0x4(%ebx)
  80009f:	ff 76 04             	pushl  0x4(%esi)
  8000a2:	68 f2 14 80 00       	push   $0x8014f2
  8000a7:	68 d4 14 80 00       	push   $0x8014d4
  8000ac:	e8 7c 05 00 00       	call   80062d <cprintf>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 46 04             	mov    0x4(%esi),%eax
  8000b7:	3b 43 04             	cmp    0x4(%ebx),%eax
  8000ba:	75 12                	jne    8000ce <check_regs+0x9a>
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	68 e4 14 80 00       	push   $0x8014e4
  8000c4:	e8 64 05 00 00       	call   80062d <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb 15                	jmp    8000e3 <check_regs+0xaf>
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 e8 14 80 00       	push   $0x8014e8
  8000d6:	e8 52 05 00 00       	call   80062d <cprintf>
  8000db:	bf 01 00 00 00       	mov    $0x1,%edi
  8000e0:	83 c4 10             	add    $0x10,%esp
	CHECK(ebp, regs.reg_ebp);
  8000e3:	ff 73 08             	pushl  0x8(%ebx)
  8000e6:	ff 76 08             	pushl  0x8(%esi)
  8000e9:	68 f6 14 80 00       	push   $0x8014f6
  8000ee:	68 d4 14 80 00       	push   $0x8014d4
  8000f3:	e8 35 05 00 00       	call   80062d <cprintf>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	8b 46 08             	mov    0x8(%esi),%eax
  8000fe:	3b 43 08             	cmp    0x8(%ebx),%eax
  800101:	75 12                	jne    800115 <check_regs+0xe1>
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	68 e4 14 80 00       	push   $0x8014e4
  80010b:	e8 1d 05 00 00       	call   80062d <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	eb 15                	jmp    80012a <check_regs+0xf6>
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 e8 14 80 00       	push   $0x8014e8
  80011d:	e8 0b 05 00 00       	call   80062d <cprintf>
  800122:	bf 01 00 00 00       	mov    $0x1,%edi
  800127:	83 c4 10             	add    $0x10,%esp
	CHECK(ebx, regs.reg_ebx);
  80012a:	ff 73 10             	pushl  0x10(%ebx)
  80012d:	ff 76 10             	pushl  0x10(%esi)
  800130:	68 fa 14 80 00       	push   $0x8014fa
  800135:	68 d4 14 80 00       	push   $0x8014d4
  80013a:	e8 ee 04 00 00       	call   80062d <cprintf>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	3b 43 10             	cmp    0x10(%ebx),%eax
  800148:	75 12                	jne    80015c <check_regs+0x128>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 e4 14 80 00       	push   $0x8014e4
  800152:	e8 d6 04 00 00       	call   80062d <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb 15                	jmp    800171 <check_regs+0x13d>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	68 e8 14 80 00       	push   $0x8014e8
  800164:	e8 c4 04 00 00       	call   80062d <cprintf>
  800169:	bf 01 00 00 00       	mov    $0x1,%edi
  80016e:	83 c4 10             	add    $0x10,%esp
	CHECK(edx, regs.reg_edx);
  800171:	ff 73 14             	pushl  0x14(%ebx)
  800174:	ff 76 14             	pushl  0x14(%esi)
  800177:	68 fe 14 80 00       	push   $0x8014fe
  80017c:	68 d4 14 80 00       	push   $0x8014d4
  800181:	e8 a7 04 00 00       	call   80062d <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp
  800189:	8b 46 14             	mov    0x14(%esi),%eax
  80018c:	3b 43 14             	cmp    0x14(%ebx),%eax
  80018f:	75 12                	jne    8001a3 <check_regs+0x16f>
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 e4 14 80 00       	push   $0x8014e4
  800199:	e8 8f 04 00 00       	call   80062d <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb 15                	jmp    8001b8 <check_regs+0x184>
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 e8 14 80 00       	push   $0x8014e8
  8001ab:	e8 7d 04 00 00       	call   80062d <cprintf>
  8001b0:	bf 01 00 00 00       	mov    $0x1,%edi
  8001b5:	83 c4 10             	add    $0x10,%esp
	CHECK(ecx, regs.reg_ecx);
  8001b8:	ff 73 18             	pushl  0x18(%ebx)
  8001bb:	ff 76 18             	pushl  0x18(%esi)
  8001be:	68 02 15 80 00       	push   $0x801502
  8001c3:	68 d4 14 80 00       	push   $0x8014d4
  8001c8:	e8 60 04 00 00       	call   80062d <cprintf>
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	8b 46 18             	mov    0x18(%esi),%eax
  8001d3:	3b 43 18             	cmp    0x18(%ebx),%eax
  8001d6:	75 12                	jne    8001ea <check_regs+0x1b6>
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	68 e4 14 80 00       	push   $0x8014e4
  8001e0:	e8 48 04 00 00       	call   80062d <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
  8001e8:	eb 15                	jmp    8001ff <check_regs+0x1cb>
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	68 e8 14 80 00       	push   $0x8014e8
  8001f2:	e8 36 04 00 00       	call   80062d <cprintf>
  8001f7:	bf 01 00 00 00       	mov    $0x1,%edi
  8001fc:	83 c4 10             	add    $0x10,%esp
	CHECK(eax, regs.reg_eax);
  8001ff:	ff 73 1c             	pushl  0x1c(%ebx)
  800202:	ff 76 1c             	pushl  0x1c(%esi)
  800205:	68 06 15 80 00       	push   $0x801506
  80020a:	68 d4 14 80 00       	push   $0x8014d4
  80020f:	e8 19 04 00 00       	call   80062d <cprintf>
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	3b 43 1c             	cmp    0x1c(%ebx),%eax
  80021d:	75 12                	jne    800231 <check_regs+0x1fd>
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 e4 14 80 00       	push   $0x8014e4
  800227:	e8 01 04 00 00       	call   80062d <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 15                	jmp    800246 <check_regs+0x212>
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	68 e8 14 80 00       	push   $0x8014e8
  800239:	e8 ef 03 00 00       	call   80062d <cprintf>
  80023e:	bf 01 00 00 00       	mov    $0x1,%edi
  800243:	83 c4 10             	add    $0x10,%esp
	CHECK(eip, eip);
  800246:	ff 73 20             	pushl  0x20(%ebx)
  800249:	ff 76 20             	pushl  0x20(%esi)
  80024c:	68 0a 15 80 00       	push   $0x80150a
  800251:	68 d4 14 80 00       	push   $0x8014d4
  800256:	e8 d2 03 00 00       	call   80062d <cprintf>
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8b 46 20             	mov    0x20(%esi),%eax
  800261:	3b 43 20             	cmp    0x20(%ebx),%eax
  800264:	75 12                	jne    800278 <check_regs+0x244>
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	68 e4 14 80 00       	push   $0x8014e4
  80026e:	e8 ba 03 00 00       	call   80062d <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	eb 15                	jmp    80028d <check_regs+0x259>
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	68 e8 14 80 00       	push   $0x8014e8
  800280:	e8 a8 03 00 00       	call   80062d <cprintf>
  800285:	bf 01 00 00 00       	mov    $0x1,%edi
  80028a:	83 c4 10             	add    $0x10,%esp
	CHECK(eflags, eflags);
  80028d:	ff 73 24             	pushl  0x24(%ebx)
  800290:	ff 76 24             	pushl  0x24(%esi)
  800293:	68 0e 15 80 00       	push   $0x80150e
  800298:	68 d4 14 80 00       	push   $0x8014d4
  80029d:	e8 8b 03 00 00       	call   80062d <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8b 46 24             	mov    0x24(%esi),%eax
  8002a8:	3b 43 24             	cmp    0x24(%ebx),%eax
  8002ab:	75 12                	jne    8002bf <check_regs+0x28b>
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	68 e4 14 80 00       	push   $0x8014e4
  8002b5:	e8 73 03 00 00       	call   80062d <cprintf>
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 15                	jmp    8002d4 <check_regs+0x2a0>
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	68 e8 14 80 00       	push   $0x8014e8
  8002c7:	e8 61 03 00 00       	call   80062d <cprintf>
  8002cc:	bf 01 00 00 00       	mov    $0x1,%edi
  8002d1:	83 c4 10             	add    $0x10,%esp
	CHECK(esp, esp);
  8002d4:	ff 73 28             	pushl  0x28(%ebx)
  8002d7:	ff 76 28             	pushl  0x28(%esi)
  8002da:	68 15 15 80 00       	push   $0x801515
  8002df:	68 d4 14 80 00       	push   $0x8014d4
  8002e4:	e8 44 03 00 00       	call   80062d <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8b 46 28             	mov    0x28(%esi),%eax
  8002ef:	3b 43 28             	cmp    0x28(%ebx),%eax
  8002f2:	75 26                	jne    80031a <check_regs+0x2e6>
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 e4 14 80 00       	push   $0x8014e4
  8002fc:	e8 2c 03 00 00       	call   80062d <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800301:	83 c4 08             	add    $0x8,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	68 19 15 80 00       	push   $0x801519
  80030c:	e8 1c 03 00 00       	call   80062d <cprintf>
	if (!mismatch)
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	85 ff                	test   %edi,%edi
  800316:	75 36                	jne    80034e <check_regs+0x31a>
  800318:	eb 22                	jmp    80033c <check_regs+0x308>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	68 e8 14 80 00       	push   $0x8014e8
  800322:	e8 06 03 00 00       	call   80062d <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	83 c4 08             	add    $0x8,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	68 19 15 80 00       	push   $0x801519
  800332:	e8 f6 02 00 00       	call   80062d <cprintf>
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	eb 12                	jmp    80034e <check_regs+0x31a>
	if (!mismatch)
		cprintf("OK\n");
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 e4 14 80 00       	push   $0x8014e4
  800344:	e8 e4 02 00 00       	call   80062d <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	eb 10                	jmp    80035e <check_regs+0x32a>
	else
		cprintf("MISMATCH\n");
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 e8 14 80 00       	push   $0x8014e8
  800356:	e8 d2 02 00 00       	call   80062d <cprintf>
  80035b:	83 c4 10             	add    $0x10,%esp
}
  80035e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  80036c:	68 7d 04 80 00       	push   $0x80047d
  800371:	e8 e2 0d 00 00       	call   801158 <set_pgfault_handler>

	asm volatile(
  800376:	50                   	push   %eax
  800377:	9c                   	pushf  
  800378:	58                   	pop    %eax
  800379:	0d d5 08 00 00       	or     $0x8d5,%eax
  80037e:	50                   	push   %eax
  80037f:	9d                   	popf   
  800380:	a3 44 20 80 00       	mov    %eax,0x802044
  800385:	8d 05 c0 03 80 00    	lea    0x8003c0,%eax
  80038b:	a3 40 20 80 00       	mov    %eax,0x802040
  800390:	58                   	pop    %eax
  800391:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800397:	89 35 24 20 80 00    	mov    %esi,0x802024
  80039d:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8003a3:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8003a9:	89 15 34 20 80 00    	mov    %edx,0x802034
  8003af:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8003b5:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8003ba:	89 25 48 20 80 00    	mov    %esp,0x802048
  8003c0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003c7:	00 00 00 
  8003ca:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8003d0:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8003d6:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8003dc:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8003e2:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8003e8:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8003ee:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8003f3:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8003f9:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8003ff:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800405:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  80040b:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  800411:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800417:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  80041d:	a1 3c 20 80 00       	mov    0x80203c,%eax
  800422:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800428:	50                   	push   %eax
  800429:	9c                   	pushf  
  80042a:	58                   	pop    %eax
  80042b:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800430:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80043b:	74 10                	je     80044d <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80043d:	83 ec 0c             	sub    $0xc,%esp
  800440:	68 80 15 80 00       	push   $0x801580
  800445:	e8 e3 01 00 00       	call   80062d <cprintf>
  80044a:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  80044d:	a1 40 20 80 00       	mov    0x802040,%eax
  800452:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	68 2e 15 80 00       	push   $0x80152e
  80045f:	68 3f 15 80 00       	push   $0x80153f
  800464:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800469:	ba 27 15 80 00       	mov    $0x801527,%edx
  80046e:	b8 20 20 80 00       	mov    $0x802020,%eax
  800473:	e8 bc fb ff ff       	call   800034 <check_regs>
  800478:	83 c4 10             	add    $0x10,%esp
}
  80047b:	c9                   	leave  
  80047c:	c3                   	ret    

0080047d <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	8b 55 08             	mov    0x8(%ebp),%edx
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	3d 00 00 40 00       	cmp    $0x400000,%eax
  80048c:	74 18                	je     8004a6 <pgfault+0x29>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80048e:	83 ec 0c             	sub    $0xc,%esp
  800491:	ff 72 28             	pushl  0x28(%edx)
  800494:	50                   	push   %eax
  800495:	68 a0 15 80 00       	push   $0x8015a0
  80049a:	6a 51                	push   $0x51
  80049c:	68 45 15 80 00       	push   $0x801545
  8004a1:	e8 e6 00 00 00       	call   80058c <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004a6:	bf 60 20 80 00       	mov    $0x802060,%edi
  8004ab:	8d 72 08             	lea    0x8(%edx),%esi
  8004ae:	fc                   	cld    
  8004af:	b9 08 00 00 00       	mov    $0x8,%ecx
  8004b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8004b6:	8b 42 28             	mov    0x28(%edx),%eax
  8004b9:	a3 80 20 80 00       	mov    %eax,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  8004be:	8b 42 2c             	mov    0x2c(%edx),%eax
  8004c1:	25 ff ff fe ff       	and    $0xfffeffff,%eax
  8004c6:	a3 84 20 80 00       	mov    %eax,0x802084
	during.esp = utf->utf_esp;
  8004cb:	8b 42 30             	mov    0x30(%edx),%eax
  8004ce:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	68 56 15 80 00       	push   $0x801556
  8004db:	68 64 15 80 00       	push   $0x801564
  8004e0:	b9 60 20 80 00       	mov    $0x802060,%ecx
  8004e5:	ba 27 15 80 00       	mov    $0x801527,%edx
  8004ea:	b8 20 20 80 00       	mov    $0x802020,%eax
  8004ef:	e8 40 fb ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8004f4:	83 c4 0c             	add    $0xc,%esp
  8004f7:	6a 07                	push   $0x7
  8004f9:	68 00 00 40 00       	push   $0x400000
  8004fe:	6a 00                	push   $0x0
  800500:	e8 90 0b 00 00       	call   801095 <sys_page_alloc>
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	85 c0                	test   %eax,%eax
  80050a:	79 12                	jns    80051e <pgfault+0xa1>
		panic("sys_page_alloc: %e", r);
  80050c:	50                   	push   %eax
  80050d:	68 6b 15 80 00       	push   $0x80156b
  800512:	6a 5c                	push   $0x5c
  800514:	68 45 15 80 00       	push   $0x801545
  800519:	e8 6e 00 00 00       	call   80058c <_panic>
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5e                   	pop    %esi
  800522:	5f                   	pop    %edi
  800523:	c9                   	leave  
  800524:	c3                   	ret    
  800525:	00 00                	add    %al,(%eax)
	...

00800528 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();    
  800533:	e8 bf 0b 00 00       	call   8010f7 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800538:	25 ff 03 00 00       	and    $0x3ff,%eax
  80053d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800544:	c1 e0 07             	shl    $0x7,%eax
  800547:	29 d0                	sub    %edx,%eax
  800549:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80054e:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800553:	85 f6                	test   %esi,%esi
  800555:	7e 07                	jle    80055e <libmain+0x36>
		binaryname = argv[0];
  800557:	8b 03                	mov    (%ebx),%eax
  800559:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	56                   	push   %esi
  800563:	e8 fe fd ff ff       	call   800366 <umain>

	// exit gracefully
	exit();
  800568:	e8 0b 00 00 00       	call   800578 <exit>
  80056d:	83 c4 10             	add    $0x10,%esp
}
  800570:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800573:	5b                   	pop    %ebx
  800574:	5e                   	pop    %esi
  800575:	c9                   	leave  
  800576:	c3                   	ret    
	...

00800578 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	83 ec 14             	sub    $0x14,%esp
//	close_all();
	sys_env_destroy(0);
  80057e:	6a 00                	push   $0x0
  800580:	e8 91 0b 00 00       	call   801116 <sys_env_destroy>
  800585:	83 c4 10             	add    $0x10,%esp
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    
	...

0080058c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	53                   	push   %ebx
  800590:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	89 45 f8             	mov    %eax,-0x8(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800599:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80059f:	e8 53 0b 00 00       	call   8010f7 <sys_getenvid>
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	ff 75 08             	pushl  0x8(%ebp)
  8005ad:	53                   	push   %ebx
  8005ae:	50                   	push   %eax
  8005af:	68 dc 15 80 00       	push   $0x8015dc
  8005b4:	e8 74 00 00 00       	call   80062d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005b9:	83 c4 18             	add    $0x18,%esp
  8005bc:	ff 75 f8             	pushl  -0x8(%ebp)
  8005bf:	ff 75 10             	pushl  0x10(%ebp)
  8005c2:	e8 15 00 00 00       	call   8005dc <vcprintf>
	cprintf("\n");
  8005c7:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  8005ce:	e8 5a 00 00 00       	call   80062d <cprintf>
  8005d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005d6:	cc                   	int3   
  8005d7:	eb fd                	jmp    8005d6 <_panic+0x4a>
  8005d9:	00 00                	add    %al,(%eax)
	...

008005dc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8005dc:	55                   	push   %ebp
  8005dd:	89 e5                	mov    %esp,%ebp
  8005df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005e5:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
  8005ec:	00 00 00 
	b.cnt = 0;
  8005ef:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
  8005f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005f9:	ff 75 0c             	pushl  0xc(%ebp)
  8005fc:	ff 75 08             	pushl  0x8(%ebp)
  8005ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800605:	50                   	push   %eax
  800606:	68 44 06 80 00       	push   $0x800644
  80060b:	e8 70 01 00 00       	call   800780 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	ff b5 f8 fe ff ff    	pushl  -0x108(%ebp)
  800619:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
  80061f:	50                   	push   %eax
  800620:	e8 9e 08 00 00       	call   800ec3 <sys_cputs>
  800625:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax

	return b.cnt;
}
  80062b:	c9                   	leave  
  80062c:	c3                   	ret    

0080062d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	83 ec 20             	sub    $0x20,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800633:	8d 45 0c             	lea    0xc(%ebp),%eax
  800636:	89 45 fc             	mov    %eax,-0x4(%ebp)
	cnt = vcprintf(fmt, ap);
  800639:	50                   	push   %eax
  80063a:	ff 75 08             	pushl  0x8(%ebp)
  80063d:	e8 9a ff ff ff       	call   8005dc <vcprintf>
	va_end(ap);

	return cnt;
}
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	53                   	push   %ebx
  800648:	83 ec 04             	sub    $0x4,%esp
  80064b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80064e:	8b 03                	mov    (%ebx),%eax
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800657:	40                   	inc    %eax
  800658:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80065a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065f:	75 1a                	jne    80067b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	68 ff 00 00 00       	push   $0xff
  800669:	8d 43 08             	lea    0x8(%ebx),%eax
  80066c:	50                   	push   %eax
  80066d:	e8 51 08 00 00       	call   800ec3 <sys_cputs>
		b->idx = 0;
  800672:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800678:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80067b:	ff 43 04             	incl   0x4(%ebx)
}
  80067e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800681:	c9                   	leave  
  800682:	c3                   	ret    
	...

00800684 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	57                   	push   %edi
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	83 ec 1c             	sub    $0x1c,%esp
  80068d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800690:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
  800699:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80069f:	8b 55 10             	mov    0x10(%ebp),%edx
  8006a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006a5:	89 d6                	mov    %edx,%esi
  8006a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8006ac:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  8006af:	72 04                	jb     8006b5 <printnum+0x31>
  8006b1:	39 c2                	cmp    %eax,%edx
  8006b3:	77 3f                	ja     8006f4 <printnum+0x70>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006b5:	83 ec 0c             	sub    $0xc,%esp
  8006b8:	ff 75 18             	pushl  0x18(%ebp)
  8006bb:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006be:	50                   	push   %eax
  8006bf:	52                   	push   %edx
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	57                   	push   %edi
  8006c4:	56                   	push   %esi
  8006c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	e8 30 0b 00 00       	call   801200 <__udivdi3>
  8006d0:	83 c4 18             	add    $0x18,%esp
  8006d3:	52                   	push   %edx
  8006d4:	50                   	push   %eax
  8006d5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8006d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006db:	e8 a4 ff ff ff       	call   800684 <printnum>
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	eb 14                	jmp    8006f9 <printnum+0x75>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	ff 75 e8             	pushl  -0x18(%ebp)
  8006eb:	ff 75 18             	pushl  0x18(%ebp)
  8006ee:	ff 55 ec             	call   *-0x14(%ebp)
  8006f1:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006f4:	4b                   	dec    %ebx
  8006f5:	85 db                	test   %ebx,%ebx
  8006f7:	7f ec                	jg     8006e5 <printnum+0x61>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 e8             	pushl  -0x18(%ebp)
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	57                   	push   %edi
  800703:	56                   	push   %esi
  800704:	ff 75 e4             	pushl  -0x1c(%ebp)
  800707:	ff 75 e0             	pushl  -0x20(%ebp)
  80070a:	e8 1d 0c 00 00       	call   80132c <__umoddi3>
  80070f:	83 c4 14             	add    $0x14,%esp
  800712:	0f be 80 ff 15 80 00 	movsbl 0x8015ff(%eax),%eax
  800719:	50                   	push   %eax
  80071a:	ff 55 ec             	call   *-0x14(%ebp)
  80071d:	83 c4 10             	add    $0x10,%esp
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	89 c1                	mov    %eax,%ecx
	if (lflag >= 2)
  80072d:	83 fa 01             	cmp    $0x1,%edx
  800730:	7e 0e                	jle    800740 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
  800732:	8b 10                	mov    (%eax),%edx
  800734:	8d 42 08             	lea    0x8(%edx),%eax
  800737:	89 01                	mov    %eax,(%ecx)
  800739:	8b 02                	mov    (%edx),%eax
  80073b:	8b 52 04             	mov    0x4(%edx),%edx
  80073e:	eb 22                	jmp    800762 <getuint+0x3a>
	else if (lflag)
  800740:	85 d2                	test   %edx,%edx
  800742:	74 10                	je     800754 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
  800744:	8b 10                	mov    (%eax),%edx
  800746:	8d 42 04             	lea    0x4(%edx),%eax
  800749:	89 01                	mov    %eax,(%ecx)
  80074b:	8b 02                	mov    (%edx),%eax
  80074d:	ba 00 00 00 00       	mov    $0x0,%edx
  800752:	eb 0e                	jmp    800762 <getuint+0x3a>
	else
		return va_arg(*ap, unsigned int);
  800754:	8b 10                	mov    (%eax),%edx
  800756:	8d 42 04             	lea    0x4(%edx),%eax
  800759:	89 01                	mov    %eax,(%ecx)
  80075b:	8b 02                	mov    (%edx),%eax
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	b->cnt++;
  80076a:	ff 41 08             	incl   0x8(%ecx)
	if (b->buf < b->ebuf)
  80076d:	8b 11                	mov    (%ecx),%edx
  80076f:	3b 51 04             	cmp    0x4(%ecx),%edx
  800772:	73 0a                	jae    80077e <sprintputch+0x1a>
		*b->buf++ = ch;
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	88 02                	mov    %al,(%edx)
  800779:	8d 42 01             	lea    0x1(%edx),%eax
  80077c:	89 01                	mov    %eax,(%ecx)
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	57                   	push   %edi
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	83 ec 3c             	sub    $0x3c,%esp
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80078f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800792:	eb 1a                	jmp    8007ae <vprintfmt+0x2e>
  800794:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800797:	eb 15                	jmp    8007ae <vprintfmt+0x2e>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800799:	84 c0                	test   %al,%al
  80079b:	0f 84 15 03 00 00    	je     800ab6 <vprintfmt+0x336>
				return;
			putch(ch, putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	57                   	push   %edi
  8007a5:	0f b6 c0             	movzbl %al,%eax
  8007a8:	50                   	push   %eax
  8007a9:	ff d6                	call   *%esi
  8007ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ae:	8a 03                	mov    (%ebx),%al
  8007b0:	43                   	inc    %ebx
  8007b1:	3c 25                	cmp    $0x25,%al
  8007b3:	75 e4                	jne    800799 <vprintfmt+0x19>
  8007b5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8007bc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8007c3:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8007ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8007d1:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
  8007d5:	eb 0a                	jmp    8007e1 <vprintfmt+0x61>
  8007d7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		padc = ' ';
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
  8007de:	8b 5d ec             	mov    -0x14(%ebp),%ebx
		switch (ch = *(unsigned char *) fmt++) {
  8007e1:	8a 03                	mov    (%ebx),%al
  8007e3:	0f b6 d0             	movzbl %al,%edx
  8007e6:	8d 4b 01             	lea    0x1(%ebx),%ecx
  8007e9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  8007ec:	83 e8 23             	sub    $0x23,%eax
  8007ef:	3c 55                	cmp    $0x55,%al
  8007f1:	0f 87 9c 02 00 00    	ja     800a93 <vprintfmt+0x313>
  8007f7:	0f b6 c0             	movzbl %al,%eax
  8007fa:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  800801:	c6 45 e7 30          	movb   $0x30,-0x19(%ebp)
  800805:	eb d7                	jmp    8007de <vprintfmt+0x5e>
  800807:	c6 45 e7 2d          	movb   $0x2d,-0x19(%ebp)
  80080b:	eb d1                	jmp    8007de <vprintfmt+0x5e>

		// flag to pad on the right
		case '-':
			padc = '-';
			goto reswitch;
  80080d:	89 d9                	mov    %ebx,%ecx
  80080f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800816:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800819:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80081c:	8d 54 42 d0          	lea    -0x30(%edx,%eax,2),%edx
  800820:	89 55 dc             	mov    %edx,-0x24(%ebp)
				ch = *fmt;
  800823:	0f be 51 01          	movsbl 0x1(%ecx),%edx
  800827:	41                   	inc    %ecx
				if (ch < '0' || ch > '9')
  800828:	8d 42 d0             	lea    -0x30(%edx),%eax
  80082b:	83 f8 09             	cmp    $0x9,%eax
  80082e:	77 21                	ja     800851 <vprintfmt+0xd1>
  800830:	eb e4                	jmp    800816 <vprintfmt+0x96>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800832:	8b 55 14             	mov    0x14(%ebp),%edx
  800835:	8d 42 04             	lea    0x4(%edx),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
  80083b:	8b 12                	mov    (%edx),%edx
  80083d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800840:	eb 12                	jmp    800854 <vprintfmt+0xd4>
			goto process_precision;

		case '.':
			if (width < 0)
  800842:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800846:	79 96                	jns    8007de <vprintfmt+0x5e>
  800848:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80084f:	eb 8d                	jmp    8007de <vprintfmt+0x5e>
  800851:	89 4d ec             	mov    %ecx,-0x14(%ebp)
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800854:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800858:	79 84                	jns    8007de <vprintfmt+0x5e>
  80085a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80085d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800860:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800867:	e9 72 ff ff ff       	jmp    8007de <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80086c:	ff 45 d4             	incl   -0x2c(%ebp)
  80086f:	e9 6a ff ff ff       	jmp    8007de <vprintfmt+0x5e>
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800874:	8b 55 14             	mov    0x14(%ebp),%edx
  800877:	8d 42 04             	lea    0x4(%edx),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	57                   	push   %edi
  800881:	ff 32                	pushl  (%edx)
  800883:	ff d6                	call   *%esi
			break;
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	e9 07 ff ff ff       	jmp    800794 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80088d:	8b 55 14             	mov    0x14(%ebp),%edx
  800890:	8d 42 04             	lea    0x4(%edx),%eax
  800893:	89 45 14             	mov    %eax,0x14(%ebp)
  800896:	8b 02                	mov    (%edx),%eax
  800898:	85 c0                	test   %eax,%eax
  80089a:	79 02                	jns    80089e <vprintfmt+0x11e>
  80089c:	f7 d8                	neg    %eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80089e:	83 f8 0f             	cmp    $0xf,%eax
  8008a1:	7f 0b                	jg     8008ae <vprintfmt+0x12e>
  8008a3:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	75 15                	jne    8008c3 <vprintfmt+0x143>
				printfmt(putch, putdat, "error %d", err);
  8008ae:	50                   	push   %eax
  8008af:	68 10 16 80 00       	push   $0x801610
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	e8 6e 02 00 00       	call   800b29 <printfmt>
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	e9 d1 fe ff ff       	jmp    800794 <vprintfmt+0x14>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008c3:	52                   	push   %edx
  8008c4:	68 19 16 80 00       	push   $0x801619
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	e8 59 02 00 00       	call   800b29 <printfmt>
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	e9 bc fe ff ff       	jmp    800794 <vprintfmt+0x14>
  8008d8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008db:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8008de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e1:	8b 55 14             	mov    0x14(%ebp),%edx
  8008e4:	8d 42 04             	lea    0x4(%edx),%eax
  8008e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ea:	8b 1a                	mov    (%edx),%ebx
  8008ec:	85 db                	test   %ebx,%ebx
  8008ee:	75 05                	jne    8008f5 <vprintfmt+0x175>
  8008f0:	bb 1c 16 80 00       	mov    $0x80161c,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8008f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8008f9:	7e 66                	jle    800961 <vprintfmt+0x1e1>
  8008fb:	80 7d e7 2d          	cmpb   $0x2d,-0x19(%ebp)
  8008ff:	74 60                	je     800961 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	51                   	push   %ecx
  800905:	53                   	push   %ebx
  800906:	e8 57 02 00 00       	call   800b62 <strnlen>
  80090b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80090e:	29 c1                	sub    %eax,%ecx
  800910:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80091a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80091d:	eb 0f                	jmp    80092e <vprintfmt+0x1ae>
					putch(padc, putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	57                   	push   %edi
  800923:	ff 75 c4             	pushl  -0x3c(%ebp)
  800926:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800928:	ff 4d d8             	decl   -0x28(%ebp)
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800932:	7f eb                	jg     80091f <vprintfmt+0x19f>
  800934:	eb 2b                	jmp    800961 <vprintfmt+0x1e1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800936:	0f be d0             	movsbl %al,%edx
				if (altflag && (ch < ' ' || ch > '~'))
  800939:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80093d:	74 15                	je     800954 <vprintfmt+0x1d4>
  80093f:	8d 42 e0             	lea    -0x20(%edx),%eax
  800942:	83 f8 5e             	cmp    $0x5e,%eax
  800945:	76 0d                	jbe    800954 <vprintfmt+0x1d4>
					putch('?', putdat);
  800947:	83 ec 08             	sub    $0x8,%esp
  80094a:	57                   	push   %edi
  80094b:	6a 3f                	push   $0x3f
  80094d:	ff d6                	call   *%esi
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80094f:	83 c4 10             	add    $0x10,%esp
  800952:	eb 0a                	jmp    80095e <vprintfmt+0x1de>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	57                   	push   %edi
  800958:	52                   	push   %edx
  800959:	ff d6                	call   *%esi
  80095b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80095e:	ff 4d d8             	decl   -0x28(%ebp)
  800961:	8a 03                	mov    (%ebx),%al
  800963:	43                   	inc    %ebx
  800964:	84 c0                	test   %al,%al
  800966:	74 1b                	je     800983 <vprintfmt+0x203>
  800968:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80096c:	78 c8                	js     800936 <vprintfmt+0x1b6>
  80096e:	ff 4d dc             	decl   -0x24(%ebp)
  800971:	79 c3                	jns    800936 <vprintfmt+0x1b6>
  800973:	eb 0e                	jmp    800983 <vprintfmt+0x203>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800975:	83 ec 08             	sub    $0x8,%esp
  800978:	57                   	push   %edi
  800979:	6a 20                	push   $0x20
  80097b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80097d:	ff 4d d8             	decl   -0x28(%ebp)
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800987:	7f ec                	jg     800975 <vprintfmt+0x1f5>
  800989:	e9 06 fe ff ff       	jmp    800794 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80098e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800992:	7e 10                	jle    8009a4 <vprintfmt+0x224>
		return va_arg(*ap, long long);
  800994:	8b 55 14             	mov    0x14(%ebp),%edx
  800997:	8d 42 08             	lea    0x8(%edx),%eax
  80099a:	89 45 14             	mov    %eax,0x14(%ebp)
  80099d:	8b 02                	mov    (%edx),%eax
  80099f:	8b 52 04             	mov    0x4(%edx),%edx
  8009a2:	eb 20                	jmp    8009c4 <vprintfmt+0x244>
	else if (lflag)
  8009a4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009a8:	74 0e                	je     8009b8 <vprintfmt+0x238>
		return va_arg(*ap, long);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 50 04             	lea    0x4(%eax),%edx
  8009b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b3:	8b 00                	mov    (%eax),%eax
  8009b5:	99                   	cltd   
  8009b6:	eb 0c                	jmp    8009c4 <vprintfmt+0x244>
	else
		return va_arg(*ap, int);
  8009b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bb:	8d 50 04             	lea    0x4(%eax),%edx
  8009be:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c1:	8b 00                	mov    (%eax),%eax
  8009c3:	99                   	cltd   
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c4:	89 d1                	mov    %edx,%ecx
  8009c6:	89 c2                	mov    %eax,%edx
			if ((long long) num < 0) {
  8009c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8009cb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ce:	85 c9                	test   %ecx,%ecx
  8009d0:	78 0a                	js     8009dc <vprintfmt+0x25c>
  8009d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d7:	e9 89 00 00 00       	jmp    800a65 <vprintfmt+0x2e5>
				putch('-', putdat);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	57                   	push   %edi
  8009e0:	6a 2d                	push   $0x2d
  8009e2:	ff d6                	call   *%esi
				num = -(long long) num;
  8009e4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8009e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009ea:	f7 da                	neg    %edx
  8009ec:	83 d1 00             	adc    $0x0,%ecx
  8009ef:	f7 d9                	neg    %ecx
  8009f1:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009f6:	83 c4 10             	add    $0x10,%esp
  8009f9:	eb 6a                	jmp    800a65 <vprintfmt+0x2e5>
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a01:	e8 22 fd ff ff       	call   800728 <getuint>
  800a06:	89 d1                	mov    %edx,%ecx
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a0f:	eb 54                	jmp    800a65 <vprintfmt+0x2e5>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a11:	8d 45 14             	lea    0x14(%ebp),%eax
  800a14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a17:	e8 0c fd ff ff       	call   800728 <getuint>
  800a1c:	89 d1                	mov    %edx,%ecx
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a25:	eb 3e                	jmp    800a65 <vprintfmt+0x2e5>
			goto number;
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a27:	83 ec 08             	sub    $0x8,%esp
  800a2a:	57                   	push   %edi
  800a2b:	6a 30                	push   $0x30
  800a2d:	ff d6                	call   *%esi
			putch('x', putdat);
  800a2f:	83 c4 08             	add    $0x8,%esp
  800a32:	57                   	push   %edi
  800a33:	6a 78                	push   $0x78
  800a35:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a37:	8b 55 14             	mov    0x14(%ebp),%edx
  800a3a:	8d 42 04             	lea    0x4(%edx),%eax
  800a3d:	89 45 14             	mov    %eax,0x14(%ebp)
  800a40:	8b 12                	mov    (%edx),%edx
  800a42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a47:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	eb 14                	jmp    800a65 <vprintfmt+0x2e5>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a51:	8d 45 14             	lea    0x14(%ebp),%eax
  800a54:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a57:	e8 cc fc ff ff       	call   800728 <getuint>
  800a5c:	89 d1                	mov    %edx,%ecx
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  800a6c:	50                   	push   %eax
  800a6d:	ff 75 d8             	pushl  -0x28(%ebp)
  800a70:	53                   	push   %ebx
  800a71:	51                   	push   %ecx
  800a72:	52                   	push   %edx
  800a73:	89 fa                	mov    %edi,%edx
  800a75:	89 f0                	mov    %esi,%eax
  800a77:	e8 08 fc ff ff       	call   800684 <printnum>
			break;
  800a7c:	83 c4 20             	add    $0x20,%esp
  800a7f:	e9 10 fd ff ff       	jmp    800794 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	57                   	push   %edi
  800a88:	52                   	push   %edx
  800a89:	ff d6                	call   *%esi
			break;
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	e9 01 fd ff ff       	jmp    800794 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	57                   	push   %edi
  800a97:	6a 25                	push   $0x25
  800a99:	ff d6                	call   *%esi
  800a9b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800a9e:	83 ea 02             	sub    $0x2,%edx
  800aa1:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa4:	8a 02                	mov    (%edx),%al
  800aa6:	4a                   	dec    %edx
  800aa7:	3c 25                	cmp    $0x25,%al
  800aa9:	75 f9                	jne    800aa4 <vprintfmt+0x324>
  800aab:	83 c2 02             	add    $0x2,%edx
  800aae:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ab1:	e9 de fc ff ff       	jmp    800794 <vprintfmt+0x14>
				/* do nothing */;
			break;
		}
	}
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    

00800abe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	83 ec 18             	sub    $0x18,%esp
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aca:	85 d2                	test   %edx,%edx
  800acc:	74 37                	je     800b05 <vsnprintf+0x47>
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	7e 33                	jle    800b05 <vsnprintf+0x47>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ad9:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800add:	89 45 f8             	mov    %eax,-0x8(%ebp)
  800ae0:	89 55 f4             	mov    %edx,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae3:	ff 75 14             	pushl  0x14(%ebp)
  800ae6:	ff 75 10             	pushl  0x10(%ebp)
  800ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aec:	50                   	push   %eax
  800aed:	68 64 07 80 00       	push   $0x800764
  800af2:	e8 89 fc ff ff       	call   800780 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800afa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	eb 05                	jmp    800b0a <vsnprintf+0x4c>
  800b05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b12:	8d 45 14             	lea    0x14(%ebp),%eax
  800b15:	89 45 fc             	mov    %eax,-0x4(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b18:	50                   	push   %eax
  800b19:	ff 75 10             	pushl  0x10(%ebp)
  800b1c:	ff 75 0c             	pushl  0xc(%ebp)
  800b1f:	ff 75 08             	pushl  0x8(%ebp)
  800b22:	e8 97 ff ff ff       	call   800abe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b2f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b32:	89 45 fc             	mov    %eax,-0x4(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b35:	50                   	push   %eax
  800b36:	ff 75 10             	pushl  0x10(%ebp)
  800b39:	ff 75 0c             	pushl  0xc(%ebp)
  800b3c:	ff 75 08             	pushl  0x8(%ebp)
  800b3f:	e8 3c fc ff ff       	call   800780 <vprintfmt>
	va_end(ap);
  800b44:	83 c4 10             	add    $0x10,%esp
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    
  800b49:	00 00                	add    %al,(%eax)
	...

00800b4c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	eb 01                	jmp    800b5a <strlen+0xe>
	int n;

	for (n = 0; *s != '\0'; s++)
		n++;
  800b59:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b5a:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
  800b5e:	75 f9                	jne    800b59 <strlen+0xd>
		n++;
	return n;
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	eb 01                	jmp    800b73 <strnlen+0x11>
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
		n++;
  800b72:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	74 06                	je     800b7d <strnlen+0x1b>
  800b77:	80 3c 08 00          	cmpb   $0x0,(%eax,%ecx,1)
  800b7b:	75 f5                	jne    800b72 <strnlen+0x10>
		n++;
	return n;
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b88:	8a 01                	mov    (%ecx),%al
  800b8a:	88 02                	mov    %al,(%edx)
  800b8c:	42                   	inc    %edx
  800b8d:	41                   	inc    %ecx
  800b8e:	84 c0                	test   %al,%al
  800b90:	75 f6                	jne    800b88 <strcpy+0x9>
		/* do nothing */;
	return ret;
}
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	53                   	push   %ebx
  800b9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b9e:	53                   	push   %ebx
  800b9f:	e8 a8 ff ff ff       	call   800b4c <strlen>
	strcpy(dst + len, src);
  800ba4:	ff 75 0c             	pushl  0xc(%ebp)
  800ba7:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800baa:	50                   	push   %eax
  800bab:	e8 cf ff ff ff       	call   800b7f <strcpy>
	return dst;
}
  800bb0:	89 d8                	mov    %ebx,%eax
  800bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	eb 0c                	jmp    800bd8 <strncpy+0x21>
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  800bcc:	8a 02                	mov    (%edx),%al
  800bce:	88 04 31             	mov    %al,(%ecx,%esi,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bd1:	80 3a 01             	cmpb   $0x1,(%edx)
  800bd4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd7:	41                   	inc    %ecx
  800bd8:	39 d9                	cmp    %ebx,%ecx
  800bda:	75 f0                	jne    800bcc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bdc:	89 f0                	mov    %esi,%eax
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bf0:	85 c9                	test   %ecx,%ecx
  800bf2:	75 04                	jne    800bf8 <strlcpy+0x16>
  800bf4:	89 f0                	mov    %esi,%eax
  800bf6:	eb 14                	jmp    800c0c <strlcpy+0x2a>
  800bf8:	89 f0                	mov    %esi,%eax
  800bfa:	eb 04                	jmp    800c00 <strlcpy+0x1e>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bfc:	88 10                	mov    %dl,(%eax)
  800bfe:	40                   	inc    %eax
  800bff:	43                   	inc    %ebx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c00:	49                   	dec    %ecx
  800c01:	74 06                	je     800c09 <strlcpy+0x27>
  800c03:	8a 13                	mov    (%ebx),%dl
  800c05:	84 d2                	test   %dl,%dl
  800c07:	75 f3                	jne    800bfc <strlcpy+0x1a>
			*dst++ = *src++;
		*dst = '\0';
  800c09:	c6 00 00             	movb   $0x0,(%eax)
  800c0c:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	eb 02                	jmp    800c1f <strcmp+0xd>
	while (*p && *p == *q)
		p++, q++;
  800c1d:	42                   	inc    %edx
  800c1e:	41                   	inc    %ecx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c1f:	8a 02                	mov    (%edx),%al
  800c21:	84 c0                	test   %al,%al
  800c23:	74 04                	je     800c29 <strcmp+0x17>
  800c25:	3a 01                	cmp    (%ecx),%al
  800c27:	74 f4                	je     800c1d <strcmp+0xb>
  800c29:	0f b6 c0             	movzbl %al,%eax
  800c2c:	0f b6 11             	movzbl (%ecx),%edx
  800c2f:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3d:	8b 55 10             	mov    0x10(%ebp),%edx
  800c40:	eb 03                	jmp    800c45 <strncmp+0x12>
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  800c42:	4a                   	dec    %edx
  800c43:	41                   	inc    %ecx
  800c44:	43                   	inc    %ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c45:	85 d2                	test   %edx,%edx
  800c47:	75 07                	jne    800c50 <strncmp+0x1d>
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	eb 14                	jmp    800c64 <strncmp+0x31>
  800c50:	8a 01                	mov    (%ecx),%al
  800c52:	84 c0                	test   %al,%al
  800c54:	74 04                	je     800c5a <strncmp+0x27>
  800c56:	3a 03                	cmp    (%ebx),%al
  800c58:	74 e8                	je     800c42 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c5a:	0f b6 d0             	movzbl %al,%edx
  800c5d:	0f b6 03             	movzbl (%ebx),%eax
  800c60:	29 c2                	sub    %eax,%edx
  800c62:	89 d0                	mov    %edx,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6d:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c70:	eb 05                	jmp    800c77 <strchr+0x10>
	for (; *s; s++)
		if (*s == c)
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	74 0c                	je     800c82 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c76:	40                   	inc    %eax
  800c77:	8a 10                	mov    (%eax),%dl
  800c79:	84 d2                	test   %dl,%dl
  800c7b:	75 f5                	jne    800c72 <strchr+0xb>
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800c8d:	eb 05                	jmp    800c94 <strfind+0x10>
	for (; *s; s++)
		if (*s == c)
  800c8f:	38 ca                	cmp    %cl,%dl
  800c91:	74 07                	je     800c9a <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c93:	40                   	inc    %eax
  800c94:	8a 10                	mov    (%eax),%dl
  800c96:	84 d2                	test   %dl,%dl
  800c98:	75 f5                	jne    800c8f <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;

	if (n == 0)
  800cab:	85 db                	test   %ebx,%ebx
  800cad:	74 36                	je     800ce5 <memset+0x49>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cb5:	75 29                	jne    800ce0 <memset+0x44>
  800cb7:	f6 c3 03             	test   $0x3,%bl
  800cba:	75 24                	jne    800ce0 <memset+0x44>
		c &= 0xFF;
  800cbc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	c1 e6 08             	shl    $0x8,%esi
  800cc4:	89 d0                	mov    %edx,%eax
  800cc6:	c1 e0 18             	shl    $0x18,%eax
  800cc9:	89 d1                	mov    %edx,%ecx
  800ccb:	c1 e1 10             	shl    $0x10,%ecx
  800cce:	09 c8                	or     %ecx,%eax
  800cd0:	09 c2                	or     %eax,%edx
  800cd2:	89 f0                	mov    %esi,%eax
  800cd4:	09 d0                	or     %edx,%eax
  800cd6:	89 d9                	mov    %ebx,%ecx
  800cd8:	c1 e9 02             	shr    $0x2,%ecx
  800cdb:	fc                   	cld    
  800cdc:	f3 ab                	rep stos %eax,%es:(%edi)
  800cde:	eb 05                	jmp    800ce5 <memset+0x49>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce0:	89 d9                	mov    %ebx,%ecx
  800ce2:	fc                   	cld    
  800ce3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce5:	89 f8                	mov    %edi,%eax
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800cf7:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfa:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cfc:	39 c6                	cmp    %eax,%esi
  800cfe:	73 36                	jae    800d36 <memmove+0x4a>
  800d00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d03:	39 d0                	cmp    %edx,%eax
  800d05:	73 2f                	jae    800d36 <memmove+0x4a>
		s += n;
		d += n;
  800d07:	8d 34 08             	lea    (%eax,%ecx,1),%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0a:	f6 c2 03             	test   $0x3,%dl
  800d0d:	75 1b                	jne    800d2a <memmove+0x3e>
  800d0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d15:	75 13                	jne    800d2a <memmove+0x3e>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 0e                	jne    800d2a <memmove+0x3e>
			asm volatile("std; rep movsl\n"
  800d1c:	8d 7e fc             	lea    -0x4(%esi),%edi
  800d1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d22:	c1 e9 02             	shr    $0x2,%ecx
  800d25:	fd                   	std    
  800d26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d28:	eb 09                	jmp    800d33 <memmove+0x47>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2a:	8d 7e ff             	lea    -0x1(%esi),%edi
  800d2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d30:	fd                   	std    
  800d31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d33:	fc                   	cld    
  800d34:	eb 20                	jmp    800d56 <memmove+0x6a>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3c:	75 15                	jne    800d53 <memmove+0x67>
  800d3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d44:	75 0d                	jne    800d53 <memmove+0x67>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 08                	jne    800d53 <memmove+0x67>
			asm volatile("cld; rep movsl\n"
  800d4b:	c1 e9 02             	shr    $0x2,%ecx
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d51:	eb 03                	jmp    800d56 <memmove+0x6a>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	fc                   	cld    
  800d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d5d:	ff 75 10             	pushl  0x10(%ebp)
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	ff 75 08             	pushl  0x8(%ebp)
  800d66:	e8 81 ff ff ff       	call   800cec <memmove>
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	53                   	push   %ebx
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
	const uint8_t *s2 = (const uint8_t *) v2;
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	eb 1b                	jmp    800d9a <memcmp+0x2d>

	while (n-- > 0) {
		if (*s1 != *s2)
  800d7f:	8a 1a                	mov    (%edx),%bl
  800d81:	88 5d fb             	mov    %bl,-0x5(%ebp)
  800d84:	8a 19                	mov    (%ecx),%bl
  800d86:	38 5d fb             	cmp    %bl,-0x5(%ebp)
  800d89:	74 0d                	je     800d98 <memcmp+0x2b>
			return (int) *s1 - (int) *s2;
  800d8b:	0f b6 55 fb          	movzbl -0x5(%ebp),%edx
  800d8f:	0f b6 c3             	movzbl %bl,%eax
  800d92:	29 c2                	sub    %eax,%edx
  800d94:	89 d0                	mov    %edx,%eax
  800d96:	eb 0d                	jmp    800da5 <memcmp+0x38>
		s1++, s2++;
  800d98:	42                   	inc    %edx
  800d99:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9a:	48                   	dec    %eax
  800d9b:	83 f8 ff             	cmp    $0xffffffff,%eax
  800d9e:	75 df                	jne    800d7f <memcmp+0x12>
  800da0:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800da5:	83 c4 04             	add    $0x4,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	03 55 10             	add    0x10(%ebp),%edx
  800db9:	eb 05                	jmp    800dc0 <memfind+0x15>
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800dbb:	38 08                	cmp    %cl,(%eax)
  800dbd:	74 05                	je     800dc4 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dbf:	40                   	inc    %eax
  800dc0:	39 d0                	cmp    %edx,%eax
  800dc2:	72 f7                	jb     800dbb <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	8b 75 10             	mov    0x10(%ebp),%esi
  800dd5:	eb 01                	jmp    800dd8 <strtol+0x12>
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;
  800dd7:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd8:	8a 01                	mov    (%ecx),%al
  800dda:	3c 20                	cmp    $0x20,%al
  800ddc:	74 f9                	je     800dd7 <strtol+0x11>
  800dde:	3c 09                	cmp    $0x9,%al
  800de0:	74 f5                	je     800dd7 <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800de2:	3c 2b                	cmp    $0x2b,%al
  800de4:	75 0a                	jne    800df0 <strtol+0x2a>
		s++;
  800de6:	41                   	inc    %ecx
  800de7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dee:	eb 17                	jmp    800e07 <strtol+0x41>
	else if (*s == '-')
  800df0:	3c 2d                	cmp    $0x2d,%al
  800df2:	74 09                	je     800dfd <strtol+0x37>
  800df4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dfb:	eb 0a                	jmp    800e07 <strtol+0x41>
		s++, neg = 1;
  800dfd:	8d 49 01             	lea    0x1(%ecx),%ecx
  800e00:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e07:	85 f6                	test   %esi,%esi
  800e09:	74 05                	je     800e10 <strtol+0x4a>
  800e0b:	83 fe 10             	cmp    $0x10,%esi
  800e0e:	75 1a                	jne    800e2a <strtol+0x64>
  800e10:	8a 01                	mov    (%ecx),%al
  800e12:	3c 30                	cmp    $0x30,%al
  800e14:	75 10                	jne    800e26 <strtol+0x60>
  800e16:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e1a:	75 0a                	jne    800e26 <strtol+0x60>
		s += 2, base = 16;
  800e1c:	83 c1 02             	add    $0x2,%ecx
  800e1f:	be 10 00 00 00       	mov    $0x10,%esi
  800e24:	eb 04                	jmp    800e2a <strtol+0x64>
	else if (base == 0 && s[0] == '0')
  800e26:	85 f6                	test   %esi,%esi
  800e28:	74 07                	je     800e31 <strtol+0x6b>
  800e2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e2f:	eb 13                	jmp    800e44 <strtol+0x7e>
  800e31:	3c 30                	cmp    $0x30,%al
  800e33:	74 07                	je     800e3c <strtol+0x76>
  800e35:	be 0a 00 00 00       	mov    $0xa,%esi
  800e3a:	eb ee                	jmp    800e2a <strtol+0x64>
		s++, base = 8;
  800e3c:	41                   	inc    %ecx
  800e3d:	be 08 00 00 00       	mov    $0x8,%esi
  800e42:	eb e6                	jmp    800e2a <strtol+0x64>

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e44:	8a 11                	mov    (%ecx),%dl
  800e46:	88 d3                	mov    %dl,%bl
  800e48:	8d 42 d0             	lea    -0x30(%edx),%eax
  800e4b:	3c 09                	cmp    $0x9,%al
  800e4d:	77 08                	ja     800e57 <strtol+0x91>
			dig = *s - '0';
  800e4f:	0f be c2             	movsbl %dl,%eax
  800e52:	8d 50 d0             	lea    -0x30(%eax),%edx
  800e55:	eb 1c                	jmp    800e73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e57:	8d 43 9f             	lea    -0x61(%ebx),%eax
  800e5a:	3c 19                	cmp    $0x19,%al
  800e5c:	77 08                	ja     800e66 <strtol+0xa0>
			dig = *s - 'a' + 10;
  800e5e:	0f be c2             	movsbl %dl,%eax
  800e61:	8d 50 a9             	lea    -0x57(%eax),%edx
  800e64:	eb 0d                	jmp    800e73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800e66:	8d 43 bf             	lea    -0x41(%ebx),%eax
  800e69:	3c 19                	cmp    $0x19,%al
  800e6b:	77 15                	ja     800e82 <strtol+0xbc>
			dig = *s - 'A' + 10;
  800e6d:	0f be c2             	movsbl %dl,%eax
  800e70:	8d 50 c9             	lea    -0x37(%eax),%edx
		else
			break;
		if (dig >= base)
  800e73:	39 f2                	cmp    %esi,%edx
  800e75:	7d 0b                	jge    800e82 <strtol+0xbc>
			break;
		s++, val = (val * base) + dig;
  800e77:	41                   	inc    %ecx
  800e78:	89 f8                	mov    %edi,%eax
  800e7a:	0f af c6             	imul   %esi,%eax
  800e7d:	8d 3c 02             	lea    (%edx,%eax,1),%edi
  800e80:	eb c2                	jmp    800e44 <strtol+0x7e>
		// we don't properly detect overflow!
	}
  800e82:	89 f8                	mov    %edi,%eax

	if (endptr)
  800e84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e88:	74 05                	je     800e8f <strtol+0xc9>
		*endptr = (char *) s;
  800e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8d:	89 0a                	mov    %ecx,(%edx)
	return (neg ? -val : val);
  800e8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e93:	74 04                	je     800e99 <strtol+0xd3>
  800e95:	89 c7                	mov    %eax,%edi
  800e97:	f7 df                	neg    %edi
}
  800e99:	89 f8                	mov    %edi,%eax
  800e9b:	83 c4 04             	add    $0x4,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    
	...

00800ea4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eaf:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb4:	89 fa                	mov    %edi,%edx
  800eb6:	89 f9                	mov    %edi,%ecx
  800eb8:	89 fb                	mov    %edi,%ebx
  800eba:	89 fe                	mov    %edi,%esi
  800ebc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed7:	89 f8                	mov    %edi,%eax
  800ed9:	89 fb                	mov    %edi,%ebx
  800edb:	89 fe                	mov    %edi,%esi
  800edd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800edf:	83 c4 04             	add    $0x4,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	57                   	push   %edi
  800eeb:	56                   	push   %esi
  800eec:	53                   	push   %ebx
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef8:	bf 00 00 00 00       	mov    $0x0,%edi
  800efd:	89 f9                	mov    %edi,%ecx
  800eff:	89 fb                	mov    %edi,%ebx
  800f01:	89 fe                	mov    %edi,%esi
  800f03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f05:	85 c0                	test   %eax,%eax
  800f07:	7e 17                	jle    800f20 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f09:	83 ec 0c             	sub    $0xc,%esp
  800f0c:	50                   	push   %eax
  800f0d:	6a 0d                	push   $0xd
  800f0f:	68 ff 18 80 00       	push   $0x8018ff
  800f14:	6a 23                	push   $0x23
  800f16:	68 1c 19 80 00       	push   $0x80191c
  800f1b:	e8 6c f6 ff ff       	call   80058c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f37:	8b 7d 14             	mov    0x14(%ebp),%edi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3f:	be 00 00 00 00       	mov    $0x0,%esi
  800f44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	8b 55 08             	mov    0x8(%ebp),%edx
  800f57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f64:	89 fb                	mov    %edi,%ebx
  800f66:	89 fe                	mov    %edi,%esi
  800f68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 17                	jle    800f85 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	50                   	push   %eax
  800f72:	6a 0a                	push   $0xa
  800f74:	68 ff 18 80 00       	push   $0x8018ff
  800f79:	6a 23                	push   $0x23
  800f7b:	68 1c 19 80 00       	push   $0x80191c
  800f80:	e8 07 f6 ff ff       	call   80058c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	57                   	push   %edi
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800fa1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa6:	89 fb                	mov    %edi,%ebx
  800fa8:	89 fe                	mov    %edi,%esi
  800faa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fac:	85 c0                	test   %eax,%eax
  800fae:	7e 17                	jle    800fc7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	50                   	push   %eax
  800fb4:	6a 09                	push   $0x9
  800fb6:	68 ff 18 80 00       	push   $0x8018ff
  800fbb:	6a 23                	push   $0x23
  800fbd:	68 1c 19 80 00       	push   $0x80191c
  800fc2:	e8 c5 f5 ff ff       	call   80058c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe8:	89 fb                	mov    %edi,%ebx
  800fea:	89 fe                	mov    %edi,%esi
  800fec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	7e 17                	jle    801009 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	50                   	push   %eax
  800ff6:	6a 08                	push   $0x8
  800ff8:	68 ff 18 80 00       	push   $0x8018ff
  800ffd:	6a 23                	push   $0x23
  800fff:	68 1c 19 80 00       	push   $0x80191c
  801004:	e8 83 f5 ff ff       	call   80058c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801009:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
  801017:	83 ec 0c             	sub    $0xc,%esp
  80101a:	8b 55 08             	mov    0x8(%ebp),%edx
  80101d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	b8 06 00 00 00       	mov    $0x6,%eax
  801025:	bf 00 00 00 00       	mov    $0x0,%edi
  80102a:	89 fb                	mov    %edi,%ebx
  80102c:	89 fe                	mov    %edi,%esi
  80102e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801030:	85 c0                	test   %eax,%eax
  801032:	7e 17                	jle    80104b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	50                   	push   %eax
  801038:	6a 06                	push   $0x6
  80103a:	68 ff 18 80 00       	push   $0x8018ff
  80103f:	6a 23                	push   $0x23
  801041:	68 1c 19 80 00       	push   $0x80191c
  801046:	e8 41 f5 ff ff       	call   80058c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80104b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	8b 55 08             	mov    0x8(%ebp),%edx
  80105f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801062:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801065:	8b 7d 14             	mov    0x14(%ebp),%edi
  801068:	8b 75 18             	mov    0x18(%ebp),%esi
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106b:	b8 05 00 00 00       	mov    $0x5,%eax
  801070:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 17                	jle    80108d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	6a 05                	push   $0x5
  80107c:	68 ff 18 80 00       	push   $0x8018ff
  801081:	6a 23                	push   $0x23
  801083:	68 1c 19 80 00       	push   $0x80191c
  801088:	e8 ff f4 ff ff       	call   80058c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8010ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8010b1:	89 fe                	mov    %edi,%esi
  8010b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	7e 17                	jle    8010d0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	50                   	push   %eax
  8010bd:	6a 04                	push   $0x4
  8010bf:	68 ff 18 80 00       	push   $0x8018ff
  8010c4:	6a 23                	push   $0x23
  8010c6:	68 1c 19 80 00       	push   $0x80191c
  8010cb:	e8 bc f4 ff ff       	call   80058c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	89 fb                	mov    %edi,%ebx
  8010ee:	89 fe                	mov    %edi,%esi
  8010f0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fd:	b8 02 00 00 00       	mov    $0x2,%eax
  801102:	bf 00 00 00 00       	mov    $0x0,%edi
  801107:	89 fa                	mov    %edi,%edx
  801109:	89 f9                	mov    %edi,%ecx
  80110b:	89 fb                	mov    %edi,%ebx
  80110d:	89 fe                	mov    %edi,%esi
  80110f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	8b 55 08             	mov    0x8(%ebp),%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	b8 03 00 00 00       	mov    $0x3,%eax
  801127:	bf 00 00 00 00       	mov    $0x0,%edi
  80112c:	89 f9                	mov    %edi,%ecx
  80112e:	89 fb                	mov    %edi,%ebx
  801130:	89 fe                	mov    %edi,%esi
  801132:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	7e 17                	jle    80114f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	50                   	push   %eax
  80113c:	6a 03                	push   $0x3
  80113e:	68 ff 18 80 00       	push   $0x8018ff
  801143:	6a 23                	push   $0x23
  801145:	68 1c 19 80 00       	push   $0x80191c
  80114a:	e8 3d f4 ff ff       	call   80058c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80114f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	c9                   	leave  
  801156:	c3                   	ret    
	...

00801158 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80115e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801165:	75 64                	jne    8011cb <set_pgfault_handler+0x73>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(thisenv->env_id,
  801167:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  80116c:	8b 40 48             	mov    0x48(%eax),%eax
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	6a 07                	push   $0x7
  801174:	68 00 f0 bf ee       	push   $0xeebff000
  801179:	50                   	push   %eax
  80117a:	e8 16 ff ff ff       	call   801095 <sys_page_alloc>
				(void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W);
		if(r < 0)panic("set_pgfault_handler: sys_page_alloc failed!\n");
  80117f:	83 c4 10             	add    $0x10,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	79 14                	jns    80119a <set_pgfault_handler+0x42>
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	68 2c 19 80 00       	push   $0x80192c
  80118e:	6a 22                	push   $0x22
  801190:	68 98 19 80 00       	push   $0x801998
  801195:	e8 f2 f3 ff ff       	call   80058c <_panic>
		//from second time to pgfault upcall
		r = sys_env_set_pgfault_upcall(thisenv->env_id, (void *)_pgfault_upcall);
  80119a:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  80119f:	8b 40 48             	mov    0x48(%eax),%eax
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	68 d8 11 80 00       	push   $0x8011d8
  8011aa:	50                   	push   %eax
  8011ab:	e8 9b fd ff ff       	call   800f4b <sys_env_set_pgfault_upcall>
		if(r < 0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed!\n");
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 14                	jns    8011cb <set_pgfault_handler+0x73>
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	68 5c 19 80 00       	push   $0x80195c
  8011bf:	6a 25                	push   $0x25
  8011c1:	68 98 19 80 00       	push   $0x801998
  8011c6:	e8 c1 f3 ff ff       	call   80058c <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    
  8011d5:	00 00                	add    %al,(%eax)
	...

008011d8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011d8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011d9:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8011de:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011e0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// trap-time esp -= 4 to push trap-time eip into trap-time stack
	movl 0x30(%esp), %eax
  8011e3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011e7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011ea:	89 44 24 30          	mov    %eax,0x30(%esp)
	//push trap-time eip into trap-time stack
	movl 0x28(%esp), %ebx
  8011ee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	mov %ebx, (%eax)
  8011f2:	89 18                	mov    %ebx,(%eax)
	//restore trap-time registers
	addl $8, %esp
  8011f4:	83 c4 08             	add    $0x8,%esp
	popal
  8011f7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8011f8:	83 c4 04             	add    $0x4,%esp
	popfl
  8011fb:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011fc:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	//ret: popl %eip
	ret
  8011fd:	c3                   	ret    
	...

00801200 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	83 ec 28             	sub    $0x28,%esp
  801208:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80120f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801216:	8b 45 10             	mov    0x10(%ebp),%eax
  801219:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80121c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80121f:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801221:	89 d7                	mov    %edx,%edi
  n0 = nn.s.low;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	89 45 ec             	mov    %eax,-0x14(%ebp)
  n1 = nn.s.high;
  801229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122c:	89 55 e8             	mov    %edx,-0x18(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80122f:	85 ff                	test   %edi,%edi
  801231:	75 21                	jne    801254 <__udivdi3+0x54>
    {
      if (d0 > n1)
  801233:	39 d1                	cmp    %edx,%ecx
  801235:	76 49                	jbe    801280 <__udivdi3+0x80>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801237:	f7 f1                	div    %ecx
  801239:	89 c1                	mov    %eax,%ecx
  80123b:	31 c0                	xor    %eax,%eax
  80123d:	8d 76 00             	lea    0x0(%esi),%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801240:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  801243:	89 45 dc             	mov    %eax,-0x24(%ebp)
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801246:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801249:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80124c:	83 c4 28             	add    $0x28,%esp
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	c9                   	leave  
  801252:	c3                   	ret    
  801253:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801254:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  801257:	0f 87 97 00 00 00    	ja     8012f4 <__udivdi3+0xf4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80125d:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801260:	83 f0 1f             	xor    $0x1f,%eax
  801263:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801266:	75 34                	jne    80129c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801268:	3b 7d e8             	cmp    -0x18(%ebp),%edi
  80126b:	72 08                	jb     801275 <__udivdi3+0x75>
  80126d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801270:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801273:	77 7f                	ja     8012f4 <__udivdi3+0xf4>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801275:	b9 01 00 00 00       	mov    $0x1,%ecx
  80127a:	31 c0                	xor    %eax,%eax
  80127c:	eb c2                	jmp    801240 <__udivdi3+0x40>
  80127e:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801280:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801283:	85 c0                	test   %eax,%eax
  801285:	74 79                	je     801300 <__udivdi3+0x100>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801287:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80128a:	89 fa                	mov    %edi,%edx
  80128c:	f7 f1                	div    %ecx
  80128e:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801290:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801293:	f7 f1                	div    %ecx
  801295:	89 c1                	mov    %eax,%ecx
  801297:	89 f0                	mov    %esi,%eax
  801299:	eb a5                	jmp    801240 <__udivdi3+0x40>
  80129b:	90                   	nop
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80129c:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a1:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  8012a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8012a7:	89 fa                	mov    %edi,%edx
  8012a9:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8012ac:	d3 e2                	shl    %cl,%edx
  8012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b1:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8012b4:	d3 e8                	shr    %cl,%eax
  8012b6:	89 d7                	mov    %edx,%edi
  8012b8:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8012ba:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8012bd:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8012c0:	d3 e6                	shl    %cl,%esi
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8012c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012c5:	d3 e0                	shl    %cl,%eax
  8012c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8012ca:	8a 4d f0             	mov    -0x10(%ebp),%cl
  8012cd:	d3 ea                	shr    %cl,%edx
  8012cf:	09 d0                	or     %edx,%eax
  8012d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8012d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012d7:	d3 ea                	shr    %cl,%edx
  8012d9:	f7 f7                	div    %edi
  8012db:	89 d7                	mov    %edx,%edi
  8012dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8012e0:	f7 e6                	mul    %esi
  8012e2:	89 c6                	mov    %eax,%esi

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012e4:	39 d7                	cmp    %edx,%edi
  8012e6:	72 38                	jb     801320 <__udivdi3+0x120>
  8012e8:	74 27                	je     801311 <__udivdi3+0x111>
  8012ea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8012ed:	31 c0                	xor    %eax,%eax
  8012ef:	e9 4c ff ff ff       	jmp    801240 <__udivdi3+0x40>
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012f4:	31 c9                	xor    %ecx,%ecx
  8012f6:	31 c0                	xor    %eax,%eax
  8012f8:	e9 43 ff ff ff       	jmp    801240 <__udivdi3+0x40>
  8012fd:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801300:	b8 01 00 00 00       	mov    $0x1,%eax
  801305:	31 d2                	xor    %edx,%edx
  801307:	f7 75 f4             	divl   -0xc(%ebp)
  80130a:	89 c1                	mov    %eax,%ecx
  80130c:	e9 76 ff ff ff       	jmp    801287 <__udivdi3+0x87>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801311:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801314:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801317:	d3 e0                	shl    %cl,%eax
  801319:	39 f0                	cmp    %esi,%eax
  80131b:	73 cd                	jae    8012ea <__udivdi3+0xea>
  80131d:	8d 76 00             	lea    0x0(%esi),%esi
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801320:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801323:	49                   	dec    %ecx
  801324:	31 c0                	xor    %eax,%eax
  801326:	e9 15 ff ff ff       	jmp    801240 <__udivdi3+0x40>
	...

0080132c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	57                   	push   %edi
  801330:	56                   	push   %esi
  801331:	83 ec 30             	sub    $0x30,%esp
  801334:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80133b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801342:	8b 75 08             	mov    0x8(%ebp),%esi
  801345:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801348:	8b 45 10             	mov    0x10(%ebp),%eax
  80134b:	8b 55 14             	mov    0x14(%ebp),%edx
  DWunion rr;
  UWtype d0, d1, n0, n1, n2;
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  80134e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801351:	89 c1                	mov    %eax,%ecx
  d1 = dd.s.high;
  801353:	89 55 e8             	mov    %edx,-0x18(%ebp)
  n0 = nn.s.low;
  801356:	89 75 f4             	mov    %esi,-0xc(%ebp)
  n1 = nn.s.high;
  801359:	89 7d e0             	mov    %edi,-0x20(%ebp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80135c:	85 d2                	test   %edx,%edx
  80135e:	75 1c                	jne    80137c <__umoddi3+0x50>
    {
      if (d0 > n1)
  801360:	89 fa                	mov    %edi,%edx
  801362:	39 f8                	cmp    %edi,%eax
  801364:	0f 86 c2 00 00 00    	jbe    80142c <__umoddi3+0x100>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80136a:	89 f0                	mov    %esi,%eax
  80136c:	f7 f1                	div    %ecx
	  /* Remainder in n0.  */
	}

      if (rp != 0)
	{
	  rr.s.low = n0;
  80136e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	  rr.s.high = 0;
  801371:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801378:	eb 12                	jmp    80138c <__umoddi3+0x60>
  80137a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80137c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80137f:	39 4d e8             	cmp    %ecx,-0x18(%ebp)
  801382:	76 18                	jbe    80139c <__umoddi3+0x70>
	  q1 = 0;

	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
  801384:	89 75 d0             	mov    %esi,-0x30(%ebp)
	      rr.s.high = n1;
  801387:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80138a:	66 90                	xchg   %ax,%ax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80138c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80138f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801392:	83 c4 30             	add    $0x30,%esp
  801395:	5e                   	pop    %esi
  801396:	5f                   	pop    %edi
  801397:	c9                   	leave  
  801398:	c3                   	ret    
  801399:	8d 76 00             	lea    0x0(%esi),%esi
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80139c:	0f bd 45 e8          	bsr    -0x18(%ebp),%eax
	  if (bm == 0)
  8013a0:	83 f0 1f             	xor    $0x1f,%eax
  8013a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013a6:	0f 84 ac 00 00 00    	je     801458 <__umoddi3+0x12c>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8013b1:	2b 45 dc             	sub    -0x24(%ebp),%eax
  8013b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013b7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8013ba:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8013bd:	d3 e2                	shl    %cl,%edx
  8013bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013c2:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8013c5:	d3 e8                	shr    %cl,%eax
  8013c7:	89 d6                	mov    %edx,%esi
  8013c9:	09 c6                	or     %eax,%esi
	      d0 = d0 << bm;
  8013cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013ce:	8a 4d dc             	mov    -0x24(%ebp),%cl
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8013d6:	8b 7d f4             	mov    -0xc(%ebp),%edi
  8013d9:	d3 e7                	shl    %cl,%edi

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8013db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013de:	d3 e0                	shl    %cl,%eax
  8013e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013e3:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  8013e6:	d3 ea                	shr    %cl,%edx
  8013e8:	09 d0                	or     %edx,%eax
  8013ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8013ed:	d3 ea                	shr    %cl,%edx
  8013ef:	f7 f6                	div    %esi
  8013f1:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      umul_ppmm (m1, m0, q0, d0);
  8013f4:	f7 65 cc             	mull   -0x34(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013f7:	39 55 f0             	cmp    %edx,-0x10(%ebp)
  8013fa:	0f 82 8d 00 00 00    	jb     80148d <__umoddi3+0x161>
  801400:	0f 84 91 00 00 00    	je     801497 <__umoddi3+0x16b>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801406:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801409:	29 c7                	sub    %eax,%edi
  80140b:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80140d:	89 f2                	mov    %esi,%edx
  80140f:	8a 4d e4             	mov    -0x1c(%ebp),%cl
  801412:	d3 e2                	shl    %cl,%edx
  801414:	89 f8                	mov    %edi,%eax
  801416:	8a 4d dc             	mov    -0x24(%ebp),%cl
  801419:	d3 e8                	shr    %cl,%eax
  80141b:	09 c2                	or     %eax,%edx
  80141d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1 >> bm;
  801420:	d3 ee                	shr    %cl,%esi
  801422:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  801425:	e9 62 ff ff ff       	jmp    80138c <__umoddi3+0x60>
  80142a:	66 90                	xchg   %ax,%ax
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80142c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80142f:	85 c0                	test   %eax,%eax
  801431:	74 15                	je     801448 <__umoddi3+0x11c>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801436:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801439:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80143b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143e:	f7 f1                	div    %ecx
  801440:	e9 29 ff ff ff       	jmp    80136e <__umoddi3+0x42>
  801445:	8d 76 00             	lea    0x0(%esi),%esi
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801448:	b8 01 00 00 00       	mov    $0x1,%eax
  80144d:	31 d2                	xor    %edx,%edx
  80144f:	f7 75 ec             	divl   -0x14(%ebp)
  801452:	89 c1                	mov    %eax,%ecx
  801454:	eb dd                	jmp    801433 <__umoddi3+0x107>
  801456:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  80145e:	72 19                	jb     801479 <__umoddi3+0x14d>
  801460:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801463:	39 55 ec             	cmp    %edx,-0x14(%ebp)
  801466:	76 11                	jbe    801479 <__umoddi3+0x14d>

	      q1 = 0;

	      if (rp != 0)
		{
		  rr.s.low = n0;
  801468:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80146b:	89 55 d0             	mov    %edx,-0x30(%ebp)
		  rr.s.high = n1;
  80146e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801471:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801474:	e9 13 ff ff ff       	jmp    80138c <__umoddi3+0x60>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801479:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	2b 45 ec             	sub    -0x14(%ebp),%eax
  801482:	1b 4d e8             	sbb    -0x18(%ebp),%ecx
  801485:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80148b:	eb db                	jmp    801468 <__umoddi3+0x13c>
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80148d:	2b 45 cc             	sub    -0x34(%ebp),%eax
  801490:	19 f2                	sbb    %esi,%edx
  801492:	e9 6f ff ff ff       	jmp    801406 <__umoddi3+0xda>
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801497:	39 c7                	cmp    %eax,%edi
  801499:	72 f2                	jb     80148d <__umoddi3+0x161>
  80149b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149e:	e9 63 ff ff ff       	jmp    801406 <__umoddi3+0xda>
