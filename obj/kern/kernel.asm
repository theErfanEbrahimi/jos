
obj/kern/kernel:     file format elf64-x86-64


Disassembly of section .bootstrap:

0000000000100000 <_head64>:
.globl _head64
_head64:

# Save multiboot_info addr passed by bootloader
	
    movl $multiboot_info, %eax
  100000:	b8 00 70 10 00       	mov    $0x107000,%eax
    movl %ebx, (%eax)
  100005:	89 18                	mov    %ebx,(%rax)

    movw $0x1234,0x472			# warm boot	
  100007:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472(%rip)        # 100482 <verify_cpu_no_longmode+0x36f>
  10000e:	34 12 
	
# Reset the stack pointer in case we didn't come from the loader
    movl $0x7c00,%esp
  100010:	bc 00 7c 00 00       	mov    $0x7c00,%esp

    call verify_cpu   #check if CPU supports long mode
  100015:	e8 cc 00 00 00       	callq  1000e6 <verify_cpu>
    movl $CR4_PAE,%eax	
  10001a:	b8 20 00 00 00       	mov    $0x20,%eax
    movl %eax,%cr4
  10001f:	0f 22 e0             	mov    %rax,%cr4

# build an early boot pml4 at physical address pml4phys 

    #initializing the page tables
    movl $pml4,%edi
  100022:	bf 00 20 10 00       	mov    $0x102000,%edi
    xorl %eax,%eax
  100027:	31 c0                	xor    %eax,%eax
    movl $((4096/4)*5),%ecx  # moving these many words to the 6 pages with 4 second level pages + 1 3rd level + 1 4th level pages 
  100029:	b9 00 14 00 00       	mov    $0x1400,%ecx
    rep stosl
  10002e:	f3 ab                	rep stos %eax,%es:(%rdi)
    # creating a 4G boot page table
    # setting the 4th level page table only the second entry needed (PML4)
    movl $pml4,%eax
  100030:	b8 00 20 10 00       	mov    $0x102000,%eax
    movl $pdpt1, %ebx
  100035:	bb 00 30 10 00       	mov    $0x103000,%ebx
    orl $PTE_P,%ebx
  10003a:	83 cb 01             	or     $0x1,%ebx
    orl $PTE_W,%ebx
  10003d:	83 cb 02             	or     $0x2,%ebx
    movl %ebx,(%eax)
  100040:	89 18                	mov    %ebx,(%rax)

    movl $pdpt2, %ebx
  100042:	bb 00 40 10 00       	mov    $0x104000,%ebx
    orl $PTE_P,%ebx
  100047:	83 cb 01             	or     $0x1,%ebx
    orl $PTE_W,%ebx
  10004a:	83 cb 02             	or     $0x2,%ebx
    movl %ebx,0x8(%eax)
  10004d:	89 58 08             	mov    %ebx,0x8(%rax)

    # setting the 3rd level page table (PDPE)
    # 4 entries (counter in ecx), point to the next four physical pages (pgdirs)
    # pgdirs in 0xa0000--0xd000
    movl $pdpt1,%edi
  100050:	bf 00 30 10 00       	mov    $0x103000,%edi
    movl $pde1,%ebx
  100055:	bb 00 50 10 00       	mov    $0x105000,%ebx
    orl $PTE_P,%ebx
  10005a:	83 cb 01             	or     $0x1,%ebx
    orl $PTE_W,%ebx
  10005d:	83 cb 02             	or     $0x2,%ebx
    movl %ebx,(%edi)
  100060:	89 1f                	mov    %ebx,(%rdi)

    movl $pdpt2,%edi
  100062:	bf 00 40 10 00       	mov    $0x104000,%edi
    movl $pde2,%ebx
  100067:	bb 00 60 10 00       	mov    $0x106000,%ebx
    orl $PTE_P,%ebx
  10006c:	83 cb 01             	or     $0x1,%ebx
    orl $PTE_W,%ebx
  10006f:	83 cb 02             	or     $0x2,%ebx
    movl %ebx,(%edi)
  100072:	89 1f                	mov    %ebx,(%rdi)
    
    # setting the pgdir so that the LA=PA
    # mapping first 1G of mem at KERNBASE
    movl $128,%ecx
  100074:	b9 80 00 00 00       	mov    $0x80,%ecx
    # Start at the end and work backwards
    #leal (pml4 + 5*0x1000 - 0x8),%edi
    movl $pde1,%edi
  100079:	bf 00 50 10 00       	mov    $0x105000,%edi
    movl $pde2,%ebx
  10007e:	bb 00 60 10 00       	mov    $0x106000,%ebx
    #64th entry - 0x8004000000
    addl $256,%ebx 
  100083:	81 c3 00 01 00 00    	add    $0x100,%ebx
    # PTE_P|PTE_W|PTE_MBZ
    movl $0x00000183,%eax
  100089:	b8 83 01 00 00       	mov    $0x183,%eax
  1:
     movl %eax,(%edi)
  10008e:	89 07                	mov    %eax,(%rdi)
     movl %eax,(%ebx)
  100090:	89 03                	mov    %eax,(%rbx)
     addl $0x8,%edi
  100092:	83 c7 08             	add    $0x8,%edi
     addl $0x8,%ebx
  100095:	83 c3 08             	add    $0x8,%ebx
     addl $0x00200000,%eax
  100098:	05 00 00 20 00       	add    $0x200000,%eax
     subl $1,%ecx
  10009d:	83 e9 01             	sub    $0x1,%ecx
     cmp $0x0,%ecx
  1000a0:	83 f9 00             	cmp    $0x0,%ecx
     jne 1b
  1000a3:	75 e9                	jne    10008e <_head64+0x8e>
 /*    subl $1,%ecx */
 /*    cmp $0x0,%ecx */
 /*    jne 1b */

    # set the cr3 register
    movl $pml4,%eax
  1000a5:	b8 00 20 10 00       	mov    $0x102000,%eax
    movl %eax, %cr3
  1000aa:	0f 22 d8             	mov    %rax,%cr3

	
    # enable the long mode in MSR
    movl $EFER_MSR,%ecx
  1000ad:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
    rdmsr
  1000b2:	0f 32                	rdmsr  
    btsl $EFER_LME,%eax
  1000b4:	0f ba e8 08          	bts    $0x8,%eax
    wrmsr
  1000b8:	0f 30                	wrmsr  
    
    # enable paging 
    movl %cr0,%eax
  1000ba:	0f 20 c0             	mov    %cr0,%rax
    orl $CR0_PE,%eax
  1000bd:	83 c8 01             	or     $0x1,%eax
    orl $CR0_PG,%eax
  1000c0:	0d 00 00 00 80       	or     $0x80000000,%eax
    orl $CR0_AM,%eax
  1000c5:	0d 00 00 04 00       	or     $0x40000,%eax
    orl $CR0_WP,%eax
  1000ca:	0d 00 00 01 00       	or     $0x10000,%eax
    orl $CR0_MP,%eax
  1000cf:	83 c8 02             	or     $0x2,%eax
    movl %eax,%cr0
  1000d2:	0f 22 c0             	mov    %rax,%cr0
    #jump to long mode with CS=0 and

    movl $gdtdesc_64,%eax
  1000d5:	b8 18 10 10 00       	mov    $0x101018,%eax
    lgdt (%eax)
  1000da:	0f 01 10             	lgdt   (%rax)
    pushl $0x8
  1000dd:	6a 08                	pushq  $0x8
    movl $_start,%eax
  1000df:	b8 0c 00 20 00       	mov    $0x20000c,%eax
    pushl %eax
  1000e4:	50                   	push   %rax

00000000001000e5 <jumpto_longmode>:
    
    .globl jumpto_longmode
    .type jumpto_longmode,@function
jumpto_longmode:
    lret
  1000e5:	cb                   	lret   

00000000001000e6 <verify_cpu>:
/*     movabs $_back_from_head64, %rax */
/*     pushq %rax */
/*     lretq */

verify_cpu:
    pushfl                   # get eflags in eax -- standardard way to check for cpuid
  1000e6:	9c                   	pushfq 
    popl %eax
  1000e7:	58                   	pop    %rax
    movl %eax,%ecx
  1000e8:	89 c1                	mov    %eax,%ecx
    xorl $0x200000, %eax
  1000ea:	35 00 00 20 00       	xor    $0x200000,%eax
    pushl %eax
  1000ef:	50                   	push   %rax
    popfl
  1000f0:	9d                   	popfq  
    pushfl
  1000f1:	9c                   	pushfq 
    popl %eax
  1000f2:	58                   	pop    %rax
    cmpl %eax,%ebx
  1000f3:	39 c3                	cmp    %eax,%ebx
    jz verify_cpu_no_longmode   # no cpuid -- no long mode
  1000f5:	74 1c                	je     100113 <verify_cpu_no_longmode>

    movl $0x0,%eax              # see if cpuid 1 is implemented
  1000f7:	b8 00 00 00 00       	mov    $0x0,%eax
    cpuid
  1000fc:	0f a2                	cpuid  
    cmpl $0x1,%eax
  1000fe:	83 f8 01             	cmp    $0x1,%eax
    jb verify_cpu_no_longmode    # cpuid 1 is not implemented
  100101:	72 10                	jb     100113 <verify_cpu_no_longmode>


    mov $0x80000001, %eax
  100103:	b8 01 00 00 80       	mov    $0x80000001,%eax
    cpuid                 
  100108:	0f a2                	cpuid  
    test $(1 << 29),%edx                 #Test if the LM-bit, is set or not.
  10010a:	f7 c2 00 00 00 20    	test   $0x20000000,%edx
    jz verify_cpu_no_longmode
  100110:	74 01                	je     100113 <verify_cpu_no_longmode>

    ret
  100112:	c3                   	retq   

0000000000100113 <verify_cpu_no_longmode>:

verify_cpu_no_longmode:
    jmp verify_cpu_no_longmode
  100113:	eb fe                	jmp    100113 <verify_cpu_no_longmode>
  100115:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10011c:	00 00 00 
  10011f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100126:	00 00 00 
  100129:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100130:	00 00 00 
  100133:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10013a:	00 00 00 
  10013d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100144:	00 00 00 
  100147:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10014e:	00 00 00 
  100151:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100158:	00 00 00 
  10015b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100162:	00 00 00 
  100165:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10016c:	00 00 00 
  10016f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100176:	00 00 00 
  100179:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100180:	00 00 00 
  100183:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10018a:	00 00 00 
  10018d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100194:	00 00 00 
  100197:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10019e:	00 00 00 
  1001a1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001a8:	00 00 00 
  1001ab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001b2:	00 00 00 
  1001b5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001bc:	00 00 00 
  1001bf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001c6:	00 00 00 
  1001c9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001d0:	00 00 00 
  1001d3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001da:	00 00 00 
  1001dd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001e4:	00 00 00 
  1001e7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001ee:	00 00 00 
  1001f1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1001f8:	00 00 00 
  1001fb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100202:	00 00 00 
  100205:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10020c:	00 00 00 
  10020f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100216:	00 00 00 
  100219:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100220:	00 00 00 
  100223:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10022a:	00 00 00 
  10022d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100234:	00 00 00 
  100237:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10023e:	00 00 00 
  100241:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100248:	00 00 00 
  10024b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100252:	00 00 00 
  100255:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10025c:	00 00 00 
  10025f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100266:	00 00 00 
  100269:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100270:	00 00 00 
  100273:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10027a:	00 00 00 
  10027d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100284:	00 00 00 
  100287:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10028e:	00 00 00 
  100291:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100298:	00 00 00 
  10029b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002a2:	00 00 00 
  1002a5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002ac:	00 00 00 
  1002af:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002b6:	00 00 00 
  1002b9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002c0:	00 00 00 
  1002c3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002ca:	00 00 00 
  1002cd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002d4:	00 00 00 
  1002d7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002de:	00 00 00 
  1002e1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002e8:	00 00 00 
  1002eb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002f2:	00 00 00 
  1002f5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1002fc:	00 00 00 
  1002ff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100306:	00 00 00 
  100309:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100310:	00 00 00 
  100313:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10031a:	00 00 00 
  10031d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100324:	00 00 00 
  100327:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10032e:	00 00 00 
  100331:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100338:	00 00 00 
  10033b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100342:	00 00 00 
  100345:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10034c:	00 00 00 
  10034f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100356:	00 00 00 
  100359:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100360:	00 00 00 
  100363:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10036a:	00 00 00 
  10036d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100374:	00 00 00 
  100377:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10037e:	00 00 00 
  100381:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100388:	00 00 00 
  10038b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100392:	00 00 00 
  100395:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10039c:	00 00 00 
  10039f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003a6:	00 00 00 
  1003a9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003b0:	00 00 00 
  1003b3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003ba:	00 00 00 
  1003bd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003c4:	00 00 00 
  1003c7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003ce:	00 00 00 
  1003d1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003d8:	00 00 00 
  1003db:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003e2:	00 00 00 
  1003e5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003ec:	00 00 00 
  1003ef:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1003f6:	00 00 00 
  1003f9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100400:	00 00 00 
  100403:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10040a:	00 00 00 
  10040d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100414:	00 00 00 
  100417:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10041e:	00 00 00 
  100421:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100428:	00 00 00 
  10042b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100432:	00 00 00 
  100435:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10043c:	00 00 00 
  10043f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100446:	00 00 00 
  100449:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100450:	00 00 00 
  100453:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10045a:	00 00 00 
  10045d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100464:	00 00 00 
  100467:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10046e:	00 00 00 
  100471:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100478:	00 00 00 
  10047b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100482:	00 00 00 
  100485:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10048c:	00 00 00 
  10048f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100496:	00 00 00 
  100499:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004a0:	00 00 00 
  1004a3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004aa:	00 00 00 
  1004ad:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004b4:	00 00 00 
  1004b7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004be:	00 00 00 
  1004c1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004c8:	00 00 00 
  1004cb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004d2:	00 00 00 
  1004d5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004dc:	00 00 00 
  1004df:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004e6:	00 00 00 
  1004e9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004f0:	00 00 00 
  1004f3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1004fa:	00 00 00 
  1004fd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100504:	00 00 00 
  100507:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10050e:	00 00 00 
  100511:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100518:	00 00 00 
  10051b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100522:	00 00 00 
  100525:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10052c:	00 00 00 
  10052f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100536:	00 00 00 
  100539:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100540:	00 00 00 
  100543:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10054a:	00 00 00 
  10054d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100554:	00 00 00 
  100557:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10055e:	00 00 00 
  100561:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100568:	00 00 00 
  10056b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100572:	00 00 00 
  100575:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10057c:	00 00 00 
  10057f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100586:	00 00 00 
  100589:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100590:	00 00 00 
  100593:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10059a:	00 00 00 
  10059d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005a4:	00 00 00 
  1005a7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005ae:	00 00 00 
  1005b1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005b8:	00 00 00 
  1005bb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005c2:	00 00 00 
  1005c5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005cc:	00 00 00 
  1005cf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005d6:	00 00 00 
  1005d9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005e0:	00 00 00 
  1005e3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005ea:	00 00 00 
  1005ed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005f4:	00 00 00 
  1005f7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1005fe:	00 00 00 
  100601:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100608:	00 00 00 
  10060b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100612:	00 00 00 
  100615:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10061c:	00 00 00 
  10061f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100626:	00 00 00 
  100629:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100630:	00 00 00 
  100633:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10063a:	00 00 00 
  10063d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100644:	00 00 00 
  100647:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10064e:	00 00 00 
  100651:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100658:	00 00 00 
  10065b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100662:	00 00 00 
  100665:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10066c:	00 00 00 
  10066f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100676:	00 00 00 
  100679:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100680:	00 00 00 
  100683:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10068a:	00 00 00 
  10068d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100694:	00 00 00 
  100697:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10069e:	00 00 00 
  1006a1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006a8:	00 00 00 
  1006ab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006b2:	00 00 00 
  1006b5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006bc:	00 00 00 
  1006bf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006c6:	00 00 00 
  1006c9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006d0:	00 00 00 
  1006d3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006da:	00 00 00 
  1006dd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006e4:	00 00 00 
  1006e7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006ee:	00 00 00 
  1006f1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1006f8:	00 00 00 
  1006fb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100702:	00 00 00 
  100705:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10070c:	00 00 00 
  10070f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100716:	00 00 00 
  100719:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100720:	00 00 00 
  100723:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10072a:	00 00 00 
  10072d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100734:	00 00 00 
  100737:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10073e:	00 00 00 
  100741:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100748:	00 00 00 
  10074b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100752:	00 00 00 
  100755:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10075c:	00 00 00 
  10075f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100766:	00 00 00 
  100769:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100770:	00 00 00 
  100773:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10077a:	00 00 00 
  10077d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100784:	00 00 00 
  100787:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10078e:	00 00 00 
  100791:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100798:	00 00 00 
  10079b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007a2:	00 00 00 
  1007a5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007ac:	00 00 00 
  1007af:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007b6:	00 00 00 
  1007b9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007c0:	00 00 00 
  1007c3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007ca:	00 00 00 
  1007cd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007d4:	00 00 00 
  1007d7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007de:	00 00 00 
  1007e1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007e8:	00 00 00 
  1007eb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007f2:	00 00 00 
  1007f5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1007fc:	00 00 00 
  1007ff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100806:	00 00 00 
  100809:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100810:	00 00 00 
  100813:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10081a:	00 00 00 
  10081d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100824:	00 00 00 
  100827:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10082e:	00 00 00 
  100831:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100838:	00 00 00 
  10083b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100842:	00 00 00 
  100845:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10084c:	00 00 00 
  10084f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100856:	00 00 00 
  100859:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100860:	00 00 00 
  100863:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10086a:	00 00 00 
  10086d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100874:	00 00 00 
  100877:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10087e:	00 00 00 
  100881:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100888:	00 00 00 
  10088b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100892:	00 00 00 
  100895:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10089c:	00 00 00 
  10089f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008a6:	00 00 00 
  1008a9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008b0:	00 00 00 
  1008b3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008ba:	00 00 00 
  1008bd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008c4:	00 00 00 
  1008c7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008ce:	00 00 00 
  1008d1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008d8:	00 00 00 
  1008db:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008e2:	00 00 00 
  1008e5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008ec:	00 00 00 
  1008ef:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1008f6:	00 00 00 
  1008f9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100900:	00 00 00 
  100903:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10090a:	00 00 00 
  10090d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100914:	00 00 00 
  100917:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10091e:	00 00 00 
  100921:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100928:	00 00 00 
  10092b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100932:	00 00 00 
  100935:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10093c:	00 00 00 
  10093f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100946:	00 00 00 
  100949:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100950:	00 00 00 
  100953:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10095a:	00 00 00 
  10095d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100964:	00 00 00 
  100967:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10096e:	00 00 00 
  100971:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100978:	00 00 00 
  10097b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100982:	00 00 00 
  100985:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  10098c:	00 00 00 
  10098f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100996:	00 00 00 
  100999:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009a0:	00 00 00 
  1009a3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009aa:	00 00 00 
  1009ad:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009b4:	00 00 00 
  1009b7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009be:	00 00 00 
  1009c1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009c8:	00 00 00 
  1009cb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009d2:	00 00 00 
  1009d5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009dc:	00 00 00 
  1009df:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009e6:	00 00 00 
  1009e9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009f0:	00 00 00 
  1009f3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  1009fa:	00 00 00 
  1009fd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a04:	00 00 00 
  100a07:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a0e:	00 00 00 
  100a11:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a18:	00 00 00 
  100a1b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a22:	00 00 00 
  100a25:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a2c:	00 00 00 
  100a2f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a36:	00 00 00 
  100a39:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a40:	00 00 00 
  100a43:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a4a:	00 00 00 
  100a4d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a54:	00 00 00 
  100a57:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a5e:	00 00 00 
  100a61:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a68:	00 00 00 
  100a6b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a72:	00 00 00 
  100a75:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a7c:	00 00 00 
  100a7f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a86:	00 00 00 
  100a89:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a90:	00 00 00 
  100a93:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100a9a:	00 00 00 
  100a9d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100aa4:	00 00 00 
  100aa7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100aae:	00 00 00 
  100ab1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ab8:	00 00 00 
  100abb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ac2:	00 00 00 
  100ac5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100acc:	00 00 00 
  100acf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ad6:	00 00 00 
  100ad9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ae0:	00 00 00 
  100ae3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100aea:	00 00 00 
  100aed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100af4:	00 00 00 
  100af7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100afe:	00 00 00 
  100b01:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b08:	00 00 00 
  100b0b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b12:	00 00 00 
  100b15:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b1c:	00 00 00 
  100b1f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b26:	00 00 00 
  100b29:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b30:	00 00 00 
  100b33:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b3a:	00 00 00 
  100b3d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b44:	00 00 00 
  100b47:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b4e:	00 00 00 
  100b51:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b58:	00 00 00 
  100b5b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b62:	00 00 00 
  100b65:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b6c:	00 00 00 
  100b6f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b76:	00 00 00 
  100b79:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b80:	00 00 00 
  100b83:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b8a:	00 00 00 
  100b8d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b94:	00 00 00 
  100b97:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100b9e:	00 00 00 
  100ba1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ba8:	00 00 00 
  100bab:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bb2:	00 00 00 
  100bb5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bbc:	00 00 00 
  100bbf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bc6:	00 00 00 
  100bc9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bd0:	00 00 00 
  100bd3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bda:	00 00 00 
  100bdd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100be4:	00 00 00 
  100be7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bee:	00 00 00 
  100bf1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100bf8:	00 00 00 
  100bfb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c02:	00 00 00 
  100c05:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c0c:	00 00 00 
  100c0f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c16:	00 00 00 
  100c19:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c20:	00 00 00 
  100c23:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c2a:	00 00 00 
  100c2d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c34:	00 00 00 
  100c37:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c3e:	00 00 00 
  100c41:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c48:	00 00 00 
  100c4b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c52:	00 00 00 
  100c55:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c5c:	00 00 00 
  100c5f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c66:	00 00 00 
  100c69:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c70:	00 00 00 
  100c73:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c7a:	00 00 00 
  100c7d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c84:	00 00 00 
  100c87:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c8e:	00 00 00 
  100c91:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100c98:	00 00 00 
  100c9b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ca2:	00 00 00 
  100ca5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cac:	00 00 00 
  100caf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cb6:	00 00 00 
  100cb9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cc0:	00 00 00 
  100cc3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cca:	00 00 00 
  100ccd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cd4:	00 00 00 
  100cd7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cde:	00 00 00 
  100ce1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ce8:	00 00 00 
  100ceb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cf2:	00 00 00 
  100cf5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100cfc:	00 00 00 
  100cff:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d06:	00 00 00 
  100d09:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d10:	00 00 00 
  100d13:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d1a:	00 00 00 
  100d1d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d24:	00 00 00 
  100d27:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d2e:	00 00 00 
  100d31:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d38:	00 00 00 
  100d3b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d42:	00 00 00 
  100d45:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d4c:	00 00 00 
  100d4f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d56:	00 00 00 
  100d59:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d60:	00 00 00 
  100d63:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d6a:	00 00 00 
  100d6d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d74:	00 00 00 
  100d77:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d7e:	00 00 00 
  100d81:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d88:	00 00 00 
  100d8b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d92:	00 00 00 
  100d95:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100d9c:	00 00 00 
  100d9f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100da6:	00 00 00 
  100da9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100db0:	00 00 00 
  100db3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100dba:	00 00 00 
  100dbd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100dc4:	00 00 00 
  100dc7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100dce:	00 00 00 
  100dd1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100dd8:	00 00 00 
  100ddb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100de2:	00 00 00 
  100de5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100dec:	00 00 00 
  100def:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100df6:	00 00 00 
  100df9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e00:	00 00 00 
  100e03:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e0a:	00 00 00 
  100e0d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e14:	00 00 00 
  100e17:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e1e:	00 00 00 
  100e21:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e28:	00 00 00 
  100e2b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e32:	00 00 00 
  100e35:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e3c:	00 00 00 
  100e3f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e46:	00 00 00 
  100e49:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e50:	00 00 00 
  100e53:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e5a:	00 00 00 
  100e5d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e64:	00 00 00 
  100e67:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e6e:	00 00 00 
  100e71:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e78:	00 00 00 
  100e7b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e82:	00 00 00 
  100e85:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e8c:	00 00 00 
  100e8f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100e96:	00 00 00 
  100e99:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ea0:	00 00 00 
  100ea3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100eaa:	00 00 00 
  100ead:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100eb4:	00 00 00 
  100eb7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ebe:	00 00 00 
  100ec1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ec8:	00 00 00 
  100ecb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ed2:	00 00 00 
  100ed5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100edc:	00 00 00 
  100edf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ee6:	00 00 00 
  100ee9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ef0:	00 00 00 
  100ef3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100efa:	00 00 00 
  100efd:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f04:	00 00 00 
  100f07:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f0e:	00 00 00 
  100f11:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f18:	00 00 00 
  100f1b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f22:	00 00 00 
  100f25:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f2c:	00 00 00 
  100f2f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f36:	00 00 00 
  100f39:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f40:	00 00 00 
  100f43:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f4a:	00 00 00 
  100f4d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f54:	00 00 00 
  100f57:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f5e:	00 00 00 
  100f61:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f68:	00 00 00 
  100f6b:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f72:	00 00 00 
  100f75:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f7c:	00 00 00 
  100f7f:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f86:	00 00 00 
  100f89:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f90:	00 00 00 
  100f93:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100f9a:	00 00 00 
  100f9d:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fa4:	00 00 00 
  100fa7:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fae:	00 00 00 
  100fb1:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fb8:	00 00 00 
  100fbb:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fc2:	00 00 00 
  100fc5:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fcc:	00 00 00 
  100fcf:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fd6:	00 00 00 
  100fd9:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fe0:	00 00 00 
  100fe3:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100fea:	00 00 00 
  100fed:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
  100ff4:	00 00 00 
  100ff7:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  100ffe:	00 00 

0000000000101000 <gdt_64>:
	...
  101008:	ff                   	(bad)  
  101009:	ff 00                	incl   (%rax)
  10100b:	00 00                	add    %al,(%rax)
  10100d:	9a                   	(bad)  
  10100e:	af                   	scas   %es:(%rdi),%eax
  10100f:	00 ff                	add    %bh,%bh
  101011:	ff 00                	incl   (%rax)
  101013:	00 00                	add    %al,(%rax)
  101015:	92                   	xchg   %eax,%edx
  101016:	cf                   	iret   
	...

0000000000101018 <gdtdesc_64>:
  101018:	17                   	(bad)  
  101019:	00 00                	add    %al,(%rax)
  10101b:	10 10                	adc    %dl,(%rax)
	...

0000000000102000 <pml4phys>:
	...

0000000000103000 <pdpt1>:
	...

0000000000104000 <pdpt2>:
	...

0000000000105000 <pde1>:
	...

0000000000106000 <pde2>:
	...

0000000000107000 <multiboot_info>:
  107000:	00 00                	add    %al,(%rax)
	...

Disassembly of section .text:

0000008004200000 <_start+0x8003fffff4>:
  8004200000:	02 b0 ad 1b 00 00    	add    0x1bad(%rax),%dh
  8004200006:	00 00                	add    %al,(%rax)
  8004200008:	fe 4f 52             	decb   0x52(%rdi)
  800420000b:	e4 48                	in     $0x48,%al

000000800420000c <entry>:
entry:

/* .globl _back_from_head64 */
/* _back_from_head64: */

    movabs   $gdtdesc_64,%rax
  800420000c:	48 b8 38 c0 21 04 80 	movabs $0x800421c038,%rax
  8004200013:	00 00 00 
    lgdt     (%rax)
  8004200016:	0f 01 10             	lgdt   (%rax)
    movw    $DATA_SEL,%ax
  8004200019:	66 b8 10 00          	mov    $0x10,%ax
    movw    %ax,%ds
  800420001d:	8e d8                	mov    %eax,%ds
    movw    %ax,%ss
  800420001f:	8e d0                	mov    %eax,%ss
    movw    %ax,%fs
  8004200021:	8e e0                	mov    %eax,%fs
    movw    %ax,%gs
  8004200023:	8e e8                	mov    %eax,%gs
    movw    %ax,%es
  8004200025:	8e c0                	mov    %eax,%es
    pushq   $CODE_SEL
  8004200027:	6a 08                	pushq  $0x8
    movabs  $relocated,%rax
  8004200029:	48 b8 36 00 20 04 80 	movabs $0x8004200036,%rax
  8004200030:	00 00 00 
    pushq   %rax
  8004200033:	50                   	push   %rax
    lretq
  8004200034:	48 cb                	lretq  

0000008004200036 <relocated>:
relocated:

	# Clear the frame pointer register (RBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movq	$0x0,%rbp			# nuke frame pointer
  8004200036:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp

	# Set the stack pointer
	movabs	$(bootstacktop),%rax
  800420003d:	48 b8 00 c0 21 04 80 	movabs $0x800421c000,%rax
  8004200044:	00 00 00 
	movq  %rax,%rsp
  8004200047:	48 89 c4             	mov    %rax,%rsp

	# now to C code
    movabs $i386_init, %rax
  800420004a:	48 b8 dc 00 20 04 80 	movabs $0x80042000dc,%rax
  8004200051:	00 00 00 
	call *%rax
  8004200054:	ff d0                	callq  *%rax

0000008004200056 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
  8004200056:	eb fe                	jmp    8004200056 <spin>

0000008004200058 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
  8004200058:	55                   	push   %rbp
  8004200059:	48 89 e5             	mov    %rsp,%rbp
  800420005c:	48 83 ec 10          	sub    $0x10,%rsp
  8004200060:	89 7d fc             	mov    %edi,-0x4(%rbp)
	cprintf("entering test_backtrace %d\n", x);
  8004200063:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200066:	89 c6                	mov    %eax,%esi
  8004200068:	48 bf c0 94 20 04 80 	movabs $0x80042094c0,%rdi
  800420006f:	00 00 00 
  8004200072:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200077:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  800420007e:	00 00 00 
  8004200081:	ff d2                	callq  *%rdx
	if (x > 0)
  8004200083:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004200087:	7e 16                	jle    800420009f <test_backtrace+0x47>
		test_backtrace(x-1);
  8004200089:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420008c:	83 e8 01             	sub    $0x1,%eax
  800420008f:	89 c7                	mov    %eax,%edi
  8004200091:	48 b8 58 00 20 04 80 	movabs $0x8004200058,%rax
  8004200098:	00 00 00 
  800420009b:	ff d0                	callq  *%rax
  800420009d:	eb 1b                	jmp    80042000ba <test_backtrace+0x62>
	else
		mon_backtrace(0, 0, 0);
  800420009f:	ba 00 00 00 00       	mov    $0x0,%edx
  80042000a4:	be 00 00 00 00       	mov    $0x0,%esi
  80042000a9:	bf 00 00 00 00       	mov    $0x0,%edi
  80042000ae:	48 b8 ca 10 20 04 80 	movabs $0x80042010ca,%rax
  80042000b5:	00 00 00 
  80042000b8:	ff d0                	callq  *%rax
	cprintf("leaving test_backtrace %d\n", x);
  80042000ba:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80042000bd:	89 c6                	mov    %eax,%esi
  80042000bf:	48 bf dc 94 20 04 80 	movabs $0x80042094dc,%rdi
  80042000c6:	00 00 00 
  80042000c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80042000ce:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042000d5:	00 00 00 
  80042000d8:	ff d2                	callq  *%rdx
}
  80042000da:	c9                   	leaveq 
  80042000db:	c3                   	retq   

00000080042000dc <i386_init>:

void
i386_init(void)
{
  80042000dc:	55                   	push   %rbp
  80042000dd:	48 89 e5             	mov    %rsp,%rbp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
  80042000e0:	48 ba 40 dd 21 04 80 	movabs $0x800421dd40,%rdx
  80042000e7:	00 00 00 
  80042000ea:	48 b8 a0 c6 21 04 80 	movabs $0x800421c6a0,%rax
  80042000f1:	00 00 00 
  80042000f4:	48 29 c2             	sub    %rax,%rdx
  80042000f7:	48 89 d0             	mov    %rdx,%rax
  80042000fa:	48 89 c2             	mov    %rax,%rdx
  80042000fd:	be 00 00 00 00       	mov    $0x0,%esi
  8004200102:	48 bf a0 c6 21 04 80 	movabs $0x800421c6a0,%rdi
  8004200109:	00 00 00 
  800420010c:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  8004200113:	00 00 00 
  8004200116:	ff d0                	callq  *%rax

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  8004200118:	48 b8 fa 0d 20 04 80 	movabs $0x8004200dfa,%rax
  800420011f:	00 00 00 
  8004200122:	ff d0                	callq  *%rax

	cprintf("6828 decimal is %o octal!\n", 6828);
  8004200124:	be ac 1a 00 00       	mov    $0x1aac,%esi
  8004200129:	48 bf f7 94 20 04 80 	movabs $0x80042094f7,%rdi
  8004200130:	00 00 00 
  8004200133:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200138:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  800420013f:	00 00 00 
  8004200142:	ff d2                	callq  *%rdx

	extern char end[];
	end_debug = read_section_headers((0x10000+KERNBASE), (uintptr_t)end);
  8004200144:	48 b8 40 dd 21 04 80 	movabs $0x800421dd40,%rax
  800420014b:	00 00 00 
  800420014e:	48 89 c6             	mov    %rax,%rsi
  8004200151:	48 bf 00 00 01 04 80 	movabs $0x8004010000,%rdi
  8004200158:	00 00 00 
  800420015b:	48 b8 e4 8a 20 04 80 	movabs $0x8004208ae4,%rax
  8004200162:	00 00 00 
  8004200165:	ff d0                	callq  *%rax
  8004200167:	48 ba 48 cd 21 04 80 	movabs $0x800421cd48,%rdx
  800420016e:	00 00 00 
  8004200171:	48 89 02             	mov    %rax,(%rdx)




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
  8004200174:	bf 05 00 00 00       	mov    $0x5,%edi
  8004200179:	48 b8 58 00 20 04 80 	movabs $0x8004200058,%rax
  8004200180:	00 00 00 
  8004200183:	ff d0                	callq  *%rax

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
  8004200185:	bf 00 00 00 00       	mov    $0x0,%edi
  800420018a:	48 b8 73 14 20 04 80 	movabs $0x8004201473,%rax
  8004200191:	00 00 00 
  8004200194:	ff d0                	callq  *%rax
  8004200196:	eb ed                	jmp    8004200185 <i386_init+0xa9>

0000008004200198 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8004200198:	55                   	push   %rbp
  8004200199:	48 89 e5             	mov    %rsp,%rbp
  800420019c:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  80042001a3:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  80042001aa:	89 b5 24 ff ff ff    	mov    %esi,-0xdc(%rbp)
  80042001b0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80042001b7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80042001be:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80042001c5:	84 c0                	test   %al,%al
  80042001c7:	74 20                	je     80042001e9 <_panic+0x51>
  80042001c9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80042001cd:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80042001d1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80042001d5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80042001d9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80042001dd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80042001e1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80042001e5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  80042001e9:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	if (panicstr)
  80042001f0:	48 b8 50 cd 21 04 80 	movabs $0x800421cd50,%rax
  80042001f7:	00 00 00 
  80042001fa:	48 8b 00             	mov    (%rax),%rax
  80042001fd:	48 85 c0             	test   %rax,%rax
  8004200200:	74 05                	je     8004200207 <_panic+0x6f>
		goto dead;
  8004200202:	e9 a9 00 00 00       	jmpq   80042002b0 <_panic+0x118>
	panicstr = fmt;
  8004200207:	48 b8 50 cd 21 04 80 	movabs $0x800421cd50,%rax
  800420020e:	00 00 00 
  8004200211:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  8004200218:	48 89 10             	mov    %rdx,(%rax)

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
  800420021b:	fa                   	cli    
  800420021c:	fc                   	cld    

	va_start(ap, fmt);
  800420021d:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004200224:	00 00 00 
  8004200227:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800420022e:	00 00 00 
  8004200231:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004200235:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800420023c:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004200243:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	cprintf("kernel panic at %s:%d: ", file, line);
  800420024a:	8b 95 24 ff ff ff    	mov    -0xdc(%rbp),%edx
  8004200250:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004200257:	48 89 c6             	mov    %rax,%rsi
  800420025a:	48 bf 12 95 20 04 80 	movabs $0x8004209512,%rdi
  8004200261:	00 00 00 
  8004200264:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200269:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004200270:	00 00 00 
  8004200273:	ff d1                	callq  *%rcx
	vcprintf(fmt, ap);
  8004200275:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  800420027c:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  8004200283:	48 89 d6             	mov    %rdx,%rsi
  8004200286:	48 89 c7             	mov    %rax,%rdi
  8004200289:	48 b8 28 15 20 04 80 	movabs $0x8004201528,%rax
  8004200290:	00 00 00 
  8004200293:	ff d0                	callq  *%rax
	cprintf("\n");
  8004200295:	48 bf 2a 95 20 04 80 	movabs $0x800420952a,%rdi
  800420029c:	00 00 00 
  800420029f:	b8 00 00 00 00       	mov    $0x0,%eax
  80042002a4:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042002ab:	00 00 00 
  80042002ae:	ff d2                	callq  *%rdx
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  80042002b0:	bf 00 00 00 00       	mov    $0x0,%edi
  80042002b5:	48 b8 73 14 20 04 80 	movabs $0x8004201473,%rax
  80042002bc:	00 00 00 
  80042002bf:	ff d0                	callq  *%rax
  80042002c1:	eb ed                	jmp    80042002b0 <_panic+0x118>

00000080042002c3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
  80042002c3:	55                   	push   %rbp
  80042002c4:	48 89 e5             	mov    %rsp,%rbp
  80042002c7:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  80042002ce:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  80042002d5:	89 b5 24 ff ff ff    	mov    %esi,-0xdc(%rbp)
  80042002db:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80042002e2:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80042002e9:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80042002f0:	84 c0                	test   %al,%al
  80042002f2:	74 20                	je     8004200314 <_warn+0x51>
  80042002f4:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80042002f8:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80042002fc:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004200300:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004200304:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004200308:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800420030c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004200310:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004200314:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  800420031b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004200322:	00 00 00 
  8004200325:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800420032c:	00 00 00 
  800420032f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004200333:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800420033a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004200341:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	cprintf("kernel warning at %s:%d: ", file, line);
  8004200348:	8b 95 24 ff ff ff    	mov    -0xdc(%rbp),%edx
  800420034e:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004200355:	48 89 c6             	mov    %rax,%rsi
  8004200358:	48 bf 2c 95 20 04 80 	movabs $0x800420952c,%rdi
  800420035f:	00 00 00 
  8004200362:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200367:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  800420036e:	00 00 00 
  8004200371:	ff d1                	callq  *%rcx
	vcprintf(fmt, ap);
  8004200373:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  800420037a:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  8004200381:	48 89 d6             	mov    %rdx,%rsi
  8004200384:	48 89 c7             	mov    %rax,%rdi
  8004200387:	48 b8 28 15 20 04 80 	movabs $0x8004201528,%rax
  800420038e:	00 00 00 
  8004200391:	ff d0                	callq  *%rax
	cprintf("\n");
  8004200393:	48 bf 2a 95 20 04 80 	movabs $0x800420952a,%rdi
  800420039a:	00 00 00 
  800420039d:	b8 00 00 00 00       	mov    $0x0,%eax
  80042003a2:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042003a9:	00 00 00 
  80042003ac:	ff d2                	callq  *%rdx
	va_end(ap);
}
  80042003ae:	c9                   	leaveq 
  80042003af:	c3                   	retq   

00000080042003b0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  80042003b0:	55                   	push   %rbp
  80042003b1:	48 89 e5             	mov    %rsp,%rbp
  80042003b4:	48 83 ec 20          	sub    $0x20,%rsp
  80042003b8:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042003bf:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80042003c2:	89 c2                	mov    %eax,%edx
  80042003c4:	ec                   	in     (%dx),%al
  80042003c5:	88 45 fb             	mov    %al,-0x5(%rbp)
  80042003c8:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%rbp)
  80042003cf:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042003d2:	89 c2                	mov    %eax,%edx
  80042003d4:	ec                   	in     (%dx),%al
  80042003d5:	88 45 f3             	mov    %al,-0xd(%rbp)
  80042003d8:	c7 45 ec 84 00 00 00 	movl   $0x84,-0x14(%rbp)
  80042003df:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042003e2:	89 c2                	mov    %eax,%edx
  80042003e4:	ec                   	in     (%dx),%al
  80042003e5:	88 45 eb             	mov    %al,-0x15(%rbp)
  80042003e8:	c7 45 e4 84 00 00 00 	movl   $0x84,-0x1c(%rbp)
  80042003ef:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042003f2:	89 c2                	mov    %eax,%edx
  80042003f4:	ec                   	in     (%dx),%al
  80042003f5:	88 45 e3             	mov    %al,-0x1d(%rbp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  80042003f8:	c9                   	leaveq 
  80042003f9:	c3                   	retq   

00000080042003fa <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
  80042003fa:	55                   	push   %rbp
  80042003fb:	48 89 e5             	mov    %rsp,%rbp
  80042003fe:	48 83 ec 10          	sub    $0x10,%rsp
  8004200402:	c7 45 fc fd 03 00 00 	movl   $0x3fd,-0x4(%rbp)
  8004200409:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420040c:	89 c2                	mov    %eax,%edx
  800420040e:	ec                   	in     (%dx),%al
  800420040f:	88 45 fb             	mov    %al,-0x5(%rbp)
	return data;
  8004200412:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  8004200416:	0f b6 c0             	movzbl %al,%eax
  8004200419:	83 e0 01             	and    $0x1,%eax
  800420041c:	85 c0                	test   %eax,%eax
  800420041e:	75 07                	jne    8004200427 <serial_proc_data+0x2d>
		return -1;
  8004200420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004200425:	eb 17                	jmp    800420043e <serial_proc_data+0x44>
  8004200427:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800420042e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004200431:	89 c2                	mov    %eax,%edx
  8004200433:	ec                   	in     (%dx),%al
  8004200434:	88 45 f3             	mov    %al,-0xd(%rbp)
	return data;
  8004200437:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
	return inb(COM1+COM_RX);
  800420043b:	0f b6 c0             	movzbl %al,%eax
}
  800420043e:	c9                   	leaveq 
  800420043f:	c3                   	retq   

0000008004200440 <serial_intr>:

void
serial_intr(void)
{
  8004200440:	55                   	push   %rbp
  8004200441:	48 89 e5             	mov    %rsp,%rbp
	if (serial_exists)
  8004200444:	48 b8 a0 c6 21 04 80 	movabs $0x800421c6a0,%rax
  800420044b:	00 00 00 
  800420044e:	0f b6 00             	movzbl (%rax),%eax
  8004200451:	84 c0                	test   %al,%al
  8004200453:	74 16                	je     800420046b <serial_intr+0x2b>
		cons_intr(serial_proc_data);
  8004200455:	48 bf fa 03 20 04 80 	movabs $0x80042003fa,%rdi
  800420045c:	00 00 00 
  800420045f:	48 b8 7d 0c 20 04 80 	movabs $0x8004200c7d,%rax
  8004200466:	00 00 00 
  8004200469:	ff d0                	callq  *%rax
}
  800420046b:	5d                   	pop    %rbp
  800420046c:	c3                   	retq   

000000800420046d <serial_putc>:

static void
serial_putc(int c)
{
  800420046d:	55                   	push   %rbp
  800420046e:	48 89 e5             	mov    %rsp,%rbp
  8004200471:	48 83 ec 28          	sub    $0x28,%rsp
  8004200475:	89 7d dc             	mov    %edi,-0x24(%rbp)
	int i;

	for (i = 0;
  8004200478:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  800420047f:	eb 10                	jmp    8004200491 <serial_putc+0x24>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  8004200481:	48 b8 b0 03 20 04 80 	movabs $0x80042003b0,%rax
  8004200488:	00 00 00 
  800420048b:	ff d0                	callq  *%rax
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  800420048d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8004200491:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200498:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800420049b:	89 c2                	mov    %eax,%edx
  800420049d:	ec                   	in     (%dx),%al
  800420049e:	88 45 f7             	mov    %al,-0x9(%rbp)
	return data;
  80042004a1:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  80042004a5:	0f b6 c0             	movzbl %al,%eax
  80042004a8:	83 e0 20             	and    $0x20,%eax
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
  80042004ab:	85 c0                	test   %eax,%eax
  80042004ad:	75 09                	jne    80042004b8 <serial_putc+0x4b>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  80042004af:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%rbp)
  80042004b6:	7e c9                	jle    8004200481 <serial_putc+0x14>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
  80042004b8:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80042004bb:	0f b6 c0             	movzbl %al,%eax
  80042004be:	c7 45 f0 f8 03 00 00 	movl   $0x3f8,-0x10(%rbp)
  80042004c5:	88 45 ef             	mov    %al,-0x11(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042004c8:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  80042004cc:	8b 55 f0             	mov    -0x10(%rbp),%edx
  80042004cf:	ee                   	out    %al,(%dx)
}
  80042004d0:	c9                   	leaveq 
  80042004d1:	c3                   	retq   

00000080042004d2 <serial_init>:

static void
serial_init(void)
{
  80042004d2:	55                   	push   %rbp
  80042004d3:	48 89 e5             	mov    %rsp,%rbp
  80042004d6:	48 83 ec 50          	sub    $0x50,%rsp
  80042004da:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%rbp)
  80042004e1:	c6 45 fb 00          	movb   $0x0,-0x5(%rbp)
  80042004e5:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80042004e9:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042004ec:	ee                   	out    %al,(%dx)
  80042004ed:	c7 45 f4 fb 03 00 00 	movl   $0x3fb,-0xc(%rbp)
  80042004f4:	c6 45 f3 80          	movb   $0x80,-0xd(%rbp)
  80042004f8:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
  80042004fc:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80042004ff:	ee                   	out    %al,(%dx)
  8004200500:	c7 45 ec f8 03 00 00 	movl   $0x3f8,-0x14(%rbp)
  8004200507:	c6 45 eb 0c          	movb   $0xc,-0x15(%rbp)
  800420050b:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  800420050f:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8004200512:	ee                   	out    %al,(%dx)
  8004200513:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%rbp)
  800420051a:	c6 45 e3 00          	movb   $0x0,-0x1d(%rbp)
  800420051e:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  8004200522:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004200525:	ee                   	out    %al,(%dx)
  8004200526:	c7 45 dc fb 03 00 00 	movl   $0x3fb,-0x24(%rbp)
  800420052d:	c6 45 db 03          	movb   $0x3,-0x25(%rbp)
  8004200531:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  8004200535:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8004200538:	ee                   	out    %al,(%dx)
  8004200539:	c7 45 d4 fc 03 00 00 	movl   $0x3fc,-0x2c(%rbp)
  8004200540:	c6 45 d3 00          	movb   $0x0,-0x2d(%rbp)
  8004200544:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  8004200548:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  800420054b:	ee                   	out    %al,(%dx)
  800420054c:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%rbp)
  8004200553:	c6 45 cb 01          	movb   $0x1,-0x35(%rbp)
  8004200557:	0f b6 45 cb          	movzbl -0x35(%rbp),%eax
  800420055b:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420055e:	ee                   	out    %al,(%dx)
  800420055f:	c7 45 c4 fd 03 00 00 	movl   $0x3fd,-0x3c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200566:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8004200569:	89 c2                	mov    %eax,%edx
  800420056b:	ec                   	in     (%dx),%al
  800420056c:	88 45 c3             	mov    %al,-0x3d(%rbp)
	return data;
  800420056f:	0f b6 45 c3          	movzbl -0x3d(%rbp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  8004200573:	3c ff                	cmp    $0xff,%al
  8004200575:	0f 95 c2             	setne  %dl
  8004200578:	48 b8 a0 c6 21 04 80 	movabs $0x800421c6a0,%rax
  800420057f:	00 00 00 
  8004200582:	88 10                	mov    %dl,(%rax)
  8004200584:	c7 45 bc fa 03 00 00 	movl   $0x3fa,-0x44(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800420058b:	8b 45 bc             	mov    -0x44(%rbp),%eax
  800420058e:	89 c2                	mov    %eax,%edx
  8004200590:	ec                   	in     (%dx),%al
  8004200591:	88 45 bb             	mov    %al,-0x45(%rbp)
  8004200594:	c7 45 b4 f8 03 00 00 	movl   $0x3f8,-0x4c(%rbp)
  800420059b:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  800420059e:	89 c2                	mov    %eax,%edx
  80042005a0:	ec                   	in     (%dx),%al
  80042005a1:	88 45 b3             	mov    %al,-0x4d(%rbp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
  80042005a4:	c9                   	leaveq 
  80042005a5:	c3                   	retq   

00000080042005a6 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
  80042005a6:	55                   	push   %rbp
  80042005a7:	48 89 e5             	mov    %rsp,%rbp
  80042005aa:	48 83 ec 38          	sub    $0x38,%rsp
  80042005ae:	89 7d cc             	mov    %edi,-0x34(%rbp)
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  80042005b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80042005b8:	eb 10                	jmp    80042005ca <lpt_putc+0x24>
		delay();
  80042005ba:	48 b8 b0 03 20 04 80 	movabs $0x80042003b0,%rax
  80042005c1:	00 00 00 
  80042005c4:	ff d0                	callq  *%rax
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  80042005c6:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80042005ca:	c7 45 f8 79 03 00 00 	movl   $0x379,-0x8(%rbp)
  80042005d1:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80042005d4:	89 c2                	mov    %eax,%edx
  80042005d6:	ec                   	in     (%dx),%al
  80042005d7:	88 45 f7             	mov    %al,-0x9(%rbp)
	return data;
  80042005da:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
  80042005de:	84 c0                	test   %al,%al
  80042005e0:	78 09                	js     80042005eb <lpt_putc+0x45>
  80042005e2:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%rbp)
  80042005e9:	7e cf                	jle    80042005ba <lpt_putc+0x14>
		delay();
	outb(0x378+0, c);
  80042005eb:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042005ee:	0f b6 c0             	movzbl %al,%eax
  80042005f1:	c7 45 f0 78 03 00 00 	movl   $0x378,-0x10(%rbp)
  80042005f8:	88 45 ef             	mov    %al,-0x11(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042005fb:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  80042005ff:	8b 55 f0             	mov    -0x10(%rbp),%edx
  8004200602:	ee                   	out    %al,(%dx)
  8004200603:	c7 45 e8 7a 03 00 00 	movl   $0x37a,-0x18(%rbp)
  800420060a:	c6 45 e7 0d          	movb   $0xd,-0x19(%rbp)
  800420060e:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004200612:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8004200615:	ee                   	out    %al,(%dx)
  8004200616:	c7 45 e0 7a 03 00 00 	movl   $0x37a,-0x20(%rbp)
  800420061d:	c6 45 df 08          	movb   $0x8,-0x21(%rbp)
  8004200621:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  8004200625:	8b 55 e0             	mov    -0x20(%rbp),%edx
  8004200628:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
  8004200629:	c9                   	leaveq 
  800420062a:	c3                   	retq   

000000800420062b <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
  800420062b:	55                   	push   %rbp
  800420062c:	48 89 e5             	mov    %rsp,%rbp
  800420062f:	48 83 ec 30          	sub    $0x30,%rsp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
  8004200633:	48 b8 00 80 0b 04 80 	movabs $0x80040b8000,%rax
  800420063a:	00 00 00 
  800420063d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	was = *cp;
  8004200641:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004200645:	0f b7 00             	movzwl (%rax),%eax
  8004200648:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
	*cp = (uint16_t) 0xA55A;
  800420064c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004200650:	66 c7 00 5a a5       	movw   $0xa55a,(%rax)
	if (*cp != 0xA55A) {
  8004200655:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004200659:	0f b7 00             	movzwl (%rax),%eax
  800420065c:	66 3d 5a a5          	cmp    $0xa55a,%ax
  8004200660:	74 20                	je     8004200682 <cga_init+0x57>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
  8004200662:	48 b8 00 00 0b 04 80 	movabs $0x80040b0000,%rax
  8004200669:	00 00 00 
  800420066c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		addr_6845 = MONO_BASE;
  8004200670:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  8004200677:	00 00 00 
  800420067a:	c7 00 b4 03 00 00    	movl   $0x3b4,(%rax)
  8004200680:	eb 1b                	jmp    800420069d <cga_init+0x72>
	} else {
		*cp = was;
  8004200682:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004200686:	0f b7 55 f6          	movzwl -0xa(%rbp),%edx
  800420068a:	66 89 10             	mov    %dx,(%rax)
		addr_6845 = CGA_BASE;
  800420068d:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  8004200694:	00 00 00 
  8004200697:	c7 00 d4 03 00 00    	movl   $0x3d4,(%rax)
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
  800420069d:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  80042006a4:	00 00 00 
  80042006a7:	8b 00                	mov    (%rax),%eax
  80042006a9:	89 45 ec             	mov    %eax,-0x14(%rbp)
  80042006ac:	c6 45 eb 0e          	movb   $0xe,-0x15(%rbp)
  80042006b0:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  80042006b4:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80042006b7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  80042006b8:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  80042006bf:	00 00 00 
  80042006c2:	8b 00                	mov    (%rax),%eax
  80042006c4:	83 c0 01             	add    $0x1,%eax
  80042006c7:	89 45 e4             	mov    %eax,-0x1c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042006ca:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042006cd:	89 c2                	mov    %eax,%edx
  80042006cf:	ec                   	in     (%dx),%al
  80042006d0:	88 45 e3             	mov    %al,-0x1d(%rbp)
	return data;
  80042006d3:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  80042006d7:	0f b6 c0             	movzbl %al,%eax
  80042006da:	c1 e0 08             	shl    $0x8,%eax
  80042006dd:	89 45 f0             	mov    %eax,-0x10(%rbp)
	outb(addr_6845, 15);
  80042006e0:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  80042006e7:	00 00 00 
  80042006ea:	8b 00                	mov    (%rax),%eax
  80042006ec:	89 45 dc             	mov    %eax,-0x24(%rbp)
  80042006ef:	c6 45 db 0f          	movb   $0xf,-0x25(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042006f3:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  80042006f7:	8b 55 dc             	mov    -0x24(%rbp),%edx
  80042006fa:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  80042006fb:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  8004200702:	00 00 00 
  8004200705:	8b 00                	mov    (%rax),%eax
  8004200707:	83 c0 01             	add    $0x1,%eax
  800420070a:	89 45 d4             	mov    %eax,-0x2c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800420070d:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  8004200710:	89 c2                	mov    %eax,%edx
  8004200712:	ec                   	in     (%dx),%al
  8004200713:	88 45 d3             	mov    %al,-0x2d(%rbp)
	return data;
  8004200716:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  800420071a:	0f b6 c0             	movzbl %al,%eax
  800420071d:	09 45 f0             	or     %eax,-0x10(%rbp)

	crt_buf = (uint16_t*) cp;
  8004200720:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  8004200727:	00 00 00 
  800420072a:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420072e:	48 89 10             	mov    %rdx,(%rax)
	crt_pos = pos;
  8004200731:	8b 45 f0             	mov    -0x10(%rbp),%eax
  8004200734:	89 c2                	mov    %eax,%edx
  8004200736:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  800420073d:	00 00 00 
  8004200740:	66 89 10             	mov    %dx,(%rax)
}
  8004200743:	c9                   	leaveq 
  8004200744:	c3                   	retq   

0000008004200745 <cga_putc>:



static void
cga_putc(int c)
{
  8004200745:	55                   	push   %rbp
  8004200746:	48 89 e5             	mov    %rsp,%rbp
  8004200749:	48 83 ec 40          	sub    $0x40,%rsp
  800420074d:	89 7d cc             	mov    %edi,-0x34(%rbp)
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  8004200750:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004200753:	b0 00                	mov    $0x0,%al
  8004200755:	85 c0                	test   %eax,%eax
  8004200757:	75 07                	jne    8004200760 <cga_putc+0x1b>
		c |= 0x0700;
  8004200759:	81 4d cc 00 07 00 00 	orl    $0x700,-0x34(%rbp)

	switch (c & 0xff) {
  8004200760:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004200763:	0f b6 c0             	movzbl %al,%eax
  8004200766:	83 f8 09             	cmp    $0x9,%eax
  8004200769:	0f 84 f6 00 00 00    	je     8004200865 <cga_putc+0x120>
  800420076f:	83 f8 09             	cmp    $0x9,%eax
  8004200772:	7f 0a                	jg     800420077e <cga_putc+0x39>
  8004200774:	83 f8 08             	cmp    $0x8,%eax
  8004200777:	74 18                	je     8004200791 <cga_putc+0x4c>
  8004200779:	e9 3e 01 00 00       	jmpq   80042008bc <cga_putc+0x177>
  800420077e:	83 f8 0a             	cmp    $0xa,%eax
  8004200781:	74 75                	je     80042007f8 <cga_putc+0xb3>
  8004200783:	83 f8 0d             	cmp    $0xd,%eax
  8004200786:	0f 84 89 00 00 00    	je     8004200815 <cga_putc+0xd0>
  800420078c:	e9 2b 01 00 00       	jmpq   80042008bc <cga_putc+0x177>
	case '\b':
		if (crt_pos > 0) {
  8004200791:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  8004200798:	00 00 00 
  800420079b:	0f b7 00             	movzwl (%rax),%eax
  800420079e:	66 85 c0             	test   %ax,%ax
  80042007a1:	74 50                	je     80042007f3 <cga_putc+0xae>
			crt_pos--;
  80042007a3:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042007aa:	00 00 00 
  80042007ad:	0f b7 00             	movzwl (%rax),%eax
  80042007b0:	8d 50 ff             	lea    -0x1(%rax),%edx
  80042007b3:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042007ba:	00 00 00 
  80042007bd:	66 89 10             	mov    %dx,(%rax)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  80042007c0:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  80042007c7:	00 00 00 
  80042007ca:	48 8b 10             	mov    (%rax),%rdx
  80042007cd:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042007d4:	00 00 00 
  80042007d7:	0f b7 00             	movzwl (%rax),%eax
  80042007da:	0f b7 c0             	movzwl %ax,%eax
  80042007dd:	48 01 c0             	add    %rax,%rax
  80042007e0:	48 01 c2             	add    %rax,%rdx
  80042007e3:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042007e6:	b0 00                	mov    $0x0,%al
  80042007e8:	83 c8 20             	or     $0x20,%eax
  80042007eb:	66 89 02             	mov    %ax,(%rdx)
		}
		break;
  80042007ee:	e9 04 01 00 00       	jmpq   80042008f7 <cga_putc+0x1b2>
  80042007f3:	e9 ff 00 00 00       	jmpq   80042008f7 <cga_putc+0x1b2>
	case '\n':
		crt_pos += CRT_COLS;
  80042007f8:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042007ff:	00 00 00 
  8004200802:	0f b7 00             	movzwl (%rax),%eax
  8004200805:	8d 50 50             	lea    0x50(%rax),%edx
  8004200808:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  800420080f:	00 00 00 
  8004200812:	66 89 10             	mov    %dx,(%rax)
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  8004200815:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  800420081c:	00 00 00 
  800420081f:	0f b7 30             	movzwl (%rax),%esi
  8004200822:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  8004200829:	00 00 00 
  800420082c:	0f b7 08             	movzwl (%rax),%ecx
  800420082f:	0f b7 c1             	movzwl %cx,%eax
  8004200832:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  8004200838:	c1 e8 10             	shr    $0x10,%eax
  800420083b:	89 c2                	mov    %eax,%edx
  800420083d:	66 c1 ea 06          	shr    $0x6,%dx
  8004200841:	89 d0                	mov    %edx,%eax
  8004200843:	c1 e0 02             	shl    $0x2,%eax
  8004200846:	01 d0                	add    %edx,%eax
  8004200848:	c1 e0 04             	shl    $0x4,%eax
  800420084b:	29 c1                	sub    %eax,%ecx
  800420084d:	89 ca                	mov    %ecx,%edx
  800420084f:	29 d6                	sub    %edx,%esi
  8004200851:	89 f2                	mov    %esi,%edx
  8004200853:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  800420085a:	00 00 00 
  800420085d:	66 89 10             	mov    %dx,(%rax)
		break;
  8004200860:	e9 92 00 00 00       	jmpq   80042008f7 <cga_putc+0x1b2>
	case '\t':
		cons_putc(' ');
  8004200865:	bf 20 00 00 00       	mov    $0x20,%edi
  800420086a:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  8004200871:	00 00 00 
  8004200874:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200876:	bf 20 00 00 00       	mov    $0x20,%edi
  800420087b:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  8004200882:	00 00 00 
  8004200885:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200887:	bf 20 00 00 00       	mov    $0x20,%edi
  800420088c:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  8004200893:	00 00 00 
  8004200896:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200898:	bf 20 00 00 00       	mov    $0x20,%edi
  800420089d:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  80042008a4:	00 00 00 
  80042008a7:	ff d0                	callq  *%rax
		cons_putc(' ');
  80042008a9:	bf 20 00 00 00       	mov    $0x20,%edi
  80042008ae:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  80042008b5:	00 00 00 
  80042008b8:	ff d0                	callq  *%rax
		break;
  80042008ba:	eb 3b                	jmp    80042008f7 <cga_putc+0x1b2>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  80042008bc:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  80042008c3:	00 00 00 
  80042008c6:	48 8b 30             	mov    (%rax),%rsi
  80042008c9:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042008d0:	00 00 00 
  80042008d3:	0f b7 00             	movzwl (%rax),%eax
  80042008d6:	8d 48 01             	lea    0x1(%rax),%ecx
  80042008d9:	48 ba b0 c6 21 04 80 	movabs $0x800421c6b0,%rdx
  80042008e0:	00 00 00 
  80042008e3:	66 89 0a             	mov    %cx,(%rdx)
  80042008e6:	0f b7 c0             	movzwl %ax,%eax
  80042008e9:	48 01 c0             	add    %rax,%rax
  80042008ec:	48 8d 14 06          	lea    (%rsi,%rax,1),%rdx
  80042008f0:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042008f3:	66 89 02             	mov    %ax,(%rdx)
		break;
  80042008f6:	90                   	nop
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  80042008f7:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042008fe:	00 00 00 
  8004200901:	0f b7 00             	movzwl (%rax),%eax
  8004200904:	66 3d cf 07          	cmp    $0x7cf,%ax
  8004200908:	0f 86 89 00 00 00    	jbe    8004200997 <cga_putc+0x252>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  800420090e:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  8004200915:	00 00 00 
  8004200918:	48 8b 00             	mov    (%rax),%rax
  800420091b:	48 8d 88 a0 00 00 00 	lea    0xa0(%rax),%rcx
  8004200922:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  8004200929:	00 00 00 
  800420092c:	48 8b 00             	mov    (%rax),%rax
  800420092f:	ba 00 0f 00 00       	mov    $0xf00,%edx
  8004200934:	48 89 ce             	mov    %rcx,%rsi
  8004200937:	48 89 c7             	mov    %rax,%rdi
  800420093a:	48 b8 4f 31 20 04 80 	movabs $0x800420314f,%rax
  8004200941:	00 00 00 
  8004200944:	ff d0                	callq  *%rax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  8004200946:	c7 45 fc 80 07 00 00 	movl   $0x780,-0x4(%rbp)
  800420094d:	eb 22                	jmp    8004200971 <cga_putc+0x22c>
			crt_buf[i] = 0x0700 | ' ';
  800420094f:	48 b8 a8 c6 21 04 80 	movabs $0x800421c6a8,%rax
  8004200956:	00 00 00 
  8004200959:	48 8b 00             	mov    (%rax),%rax
  800420095c:	8b 55 fc             	mov    -0x4(%rbp),%edx
  800420095f:	48 63 d2             	movslq %edx,%rdx
  8004200962:	48 01 d2             	add    %rdx,%rdx
  8004200965:	48 01 d0             	add    %rdx,%rax
  8004200968:	66 c7 00 20 07       	movw   $0x720,(%rax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  800420096d:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8004200971:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  8004200978:	7e d5                	jle    800420094f <cga_putc+0x20a>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  800420097a:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  8004200981:	00 00 00 
  8004200984:	0f b7 00             	movzwl (%rax),%eax
  8004200987:	8d 50 b0             	lea    -0x50(%rax),%edx
  800420098a:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  8004200991:	00 00 00 
  8004200994:	66 89 10             	mov    %dx,(%rax)
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  8004200997:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  800420099e:	00 00 00 
  80042009a1:	8b 00                	mov    (%rax),%eax
  80042009a3:	89 45 f8             	mov    %eax,-0x8(%rbp)
  80042009a6:	c6 45 f7 0e          	movb   $0xe,-0x9(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042009aa:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
  80042009ae:	8b 55 f8             	mov    -0x8(%rbp),%edx
  80042009b1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  80042009b2:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  80042009b9:	00 00 00 
  80042009bc:	0f b7 00             	movzwl (%rax),%eax
  80042009bf:	66 c1 e8 08          	shr    $0x8,%ax
  80042009c3:	0f b6 c0             	movzbl %al,%eax
  80042009c6:	48 ba a4 c6 21 04 80 	movabs $0x800421c6a4,%rdx
  80042009cd:	00 00 00 
  80042009d0:	8b 12                	mov    (%rdx),%edx
  80042009d2:	83 c2 01             	add    $0x1,%edx
  80042009d5:	89 55 f0             	mov    %edx,-0x10(%rbp)
  80042009d8:	88 45 ef             	mov    %al,-0x11(%rbp)
  80042009db:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  80042009df:	8b 55 f0             	mov    -0x10(%rbp),%edx
  80042009e2:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  80042009e3:	48 b8 a4 c6 21 04 80 	movabs $0x800421c6a4,%rax
  80042009ea:	00 00 00 
  80042009ed:	8b 00                	mov    (%rax),%eax
  80042009ef:	89 45 e8             	mov    %eax,-0x18(%rbp)
  80042009f2:	c6 45 e7 0f          	movb   $0xf,-0x19(%rbp)
  80042009f6:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  80042009fa:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80042009fd:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  80042009fe:	48 b8 b0 c6 21 04 80 	movabs $0x800421c6b0,%rax
  8004200a05:	00 00 00 
  8004200a08:	0f b7 00             	movzwl (%rax),%eax
  8004200a0b:	0f b6 c0             	movzbl %al,%eax
  8004200a0e:	48 ba a4 c6 21 04 80 	movabs $0x800421c6a4,%rdx
  8004200a15:	00 00 00 
  8004200a18:	8b 12                	mov    (%rdx),%edx
  8004200a1a:	83 c2 01             	add    $0x1,%edx
  8004200a1d:	89 55 e0             	mov    %edx,-0x20(%rbp)
  8004200a20:	88 45 df             	mov    %al,-0x21(%rbp)
  8004200a23:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  8004200a27:	8b 55 e0             	mov    -0x20(%rbp),%edx
  8004200a2a:	ee                   	out    %al,(%dx)
}
  8004200a2b:	c9                   	leaveq 
  8004200a2c:	c3                   	retq   

0000008004200a2d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  8004200a2d:	55                   	push   %rbp
  8004200a2e:	48 89 e5             	mov    %rsp,%rbp
  8004200a31:	48 83 ec 20          	sub    $0x20,%rsp
  8004200a35:	c7 45 f4 64 00 00 00 	movl   $0x64,-0xc(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200a3c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004200a3f:	89 c2                	mov    %eax,%edx
  8004200a41:	ec                   	in     (%dx),%al
  8004200a42:	88 45 f3             	mov    %al,-0xd(%rbp)
	return data;
  8004200a45:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;
	int r;
	if ((inb(KBSTATP) & KBS_DIB) == 0)
  8004200a49:	0f b6 c0             	movzbl %al,%eax
  8004200a4c:	83 e0 01             	and    $0x1,%eax
  8004200a4f:	85 c0                	test   %eax,%eax
  8004200a51:	75 0a                	jne    8004200a5d <kbd_proc_data+0x30>
		return -1;
  8004200a53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004200a58:	e9 fc 01 00 00       	jmpq   8004200c59 <kbd_proc_data+0x22c>
  8004200a5d:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200a64:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004200a67:	89 c2                	mov    %eax,%edx
  8004200a69:	ec                   	in     (%dx),%al
  8004200a6a:	88 45 eb             	mov    %al,-0x15(%rbp)
	return data;
  8004200a6d:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax

	data = inb(KBDATAP);
  8004200a71:	88 45 fb             	mov    %al,-0x5(%rbp)

	if (data == 0xE0) {
  8004200a74:	80 7d fb e0          	cmpb   $0xe0,-0x5(%rbp)
  8004200a78:	75 27                	jne    8004200aa1 <kbd_proc_data+0x74>
		// E0 escape character
		shift |= E0ESC;
  8004200a7a:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200a81:	00 00 00 
  8004200a84:	8b 00                	mov    (%rax),%eax
  8004200a86:	83 c8 40             	or     $0x40,%eax
  8004200a89:	89 c2                	mov    %eax,%edx
  8004200a8b:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200a92:	00 00 00 
  8004200a95:	89 10                	mov    %edx,(%rax)
		return 0;
  8004200a97:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200a9c:	e9 b8 01 00 00       	jmpq   8004200c59 <kbd_proc_data+0x22c>
	} else if (data & 0x80) {
  8004200aa1:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200aa5:	84 c0                	test   %al,%al
  8004200aa7:	79 65                	jns    8004200b0e <kbd_proc_data+0xe1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  8004200aa9:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200ab0:	00 00 00 
  8004200ab3:	8b 00                	mov    (%rax),%eax
  8004200ab5:	83 e0 40             	and    $0x40,%eax
  8004200ab8:	85 c0                	test   %eax,%eax
  8004200aba:	75 09                	jne    8004200ac5 <kbd_proc_data+0x98>
  8004200abc:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200ac0:	83 e0 7f             	and    $0x7f,%eax
  8004200ac3:	eb 04                	jmp    8004200ac9 <kbd_proc_data+0x9c>
  8004200ac5:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200ac9:	88 45 fb             	mov    %al,-0x5(%rbp)
		shift &= ~(shiftcode[data] | E0ESC);
  8004200acc:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200ad0:	48 ba 60 c0 21 04 80 	movabs $0x800421c060,%rdx
  8004200ad7:	00 00 00 
  8004200ada:	48 98                	cltq   
  8004200adc:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200ae0:	83 c8 40             	or     $0x40,%eax
  8004200ae3:	0f b6 c0             	movzbl %al,%eax
  8004200ae6:	f7 d0                	not    %eax
  8004200ae8:	89 c2                	mov    %eax,%edx
  8004200aea:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200af1:	00 00 00 
  8004200af4:	8b 00                	mov    (%rax),%eax
  8004200af6:	21 c2                	and    %eax,%edx
  8004200af8:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200aff:	00 00 00 
  8004200b02:	89 10                	mov    %edx,(%rax)
		return 0;
  8004200b04:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200b09:	e9 4b 01 00 00       	jmpq   8004200c59 <kbd_proc_data+0x22c>
	} else if (shift & E0ESC) {
  8004200b0e:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b15:	00 00 00 
  8004200b18:	8b 00                	mov    (%rax),%eax
  8004200b1a:	83 e0 40             	and    $0x40,%eax
  8004200b1d:	85 c0                	test   %eax,%eax
  8004200b1f:	74 21                	je     8004200b42 <kbd_proc_data+0x115>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  8004200b21:	80 4d fb 80          	orb    $0x80,-0x5(%rbp)
		shift &= ~E0ESC;
  8004200b25:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b2c:	00 00 00 
  8004200b2f:	8b 00                	mov    (%rax),%eax
  8004200b31:	83 e0 bf             	and    $0xffffffbf,%eax
  8004200b34:	89 c2                	mov    %eax,%edx
  8004200b36:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b3d:	00 00 00 
  8004200b40:	89 10                	mov    %edx,(%rax)
	}

	shift |= shiftcode[data];
  8004200b42:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200b46:	48 ba 60 c0 21 04 80 	movabs $0x800421c060,%rdx
  8004200b4d:	00 00 00 
  8004200b50:	48 98                	cltq   
  8004200b52:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200b56:	0f b6 d0             	movzbl %al,%edx
  8004200b59:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b60:	00 00 00 
  8004200b63:	8b 00                	mov    (%rax),%eax
  8004200b65:	09 c2                	or     %eax,%edx
  8004200b67:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b6e:	00 00 00 
  8004200b71:	89 10                	mov    %edx,(%rax)
	shift ^= togglecode[data];
  8004200b73:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200b77:	48 ba 60 c1 21 04 80 	movabs $0x800421c160,%rdx
  8004200b7e:	00 00 00 
  8004200b81:	48 98                	cltq   
  8004200b83:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200b87:	0f b6 d0             	movzbl %al,%edx
  8004200b8a:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b91:	00 00 00 
  8004200b94:	8b 00                	mov    (%rax),%eax
  8004200b96:	31 c2                	xor    %eax,%edx
  8004200b98:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200b9f:	00 00 00 
  8004200ba2:	89 10                	mov    %edx,(%rax)

	c = charcode[shift & (CTL | SHIFT)][data];
  8004200ba4:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200bab:	00 00 00 
  8004200bae:	8b 00                	mov    (%rax),%eax
  8004200bb0:	83 e0 03             	and    $0x3,%eax
  8004200bb3:	89 c2                	mov    %eax,%edx
  8004200bb5:	48 b8 60 c5 21 04 80 	movabs $0x800421c560,%rax
  8004200bbc:	00 00 00 
  8004200bbf:	89 d2                	mov    %edx,%edx
  8004200bc1:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  8004200bc5:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200bc9:	48 01 d0             	add    %rdx,%rax
  8004200bcc:	0f b6 00             	movzbl (%rax),%eax
  8004200bcf:	0f b6 c0             	movzbl %al,%eax
  8004200bd2:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (shift & CAPSLOCK) {
  8004200bd5:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200bdc:	00 00 00 
  8004200bdf:	8b 00                	mov    (%rax),%eax
  8004200be1:	83 e0 08             	and    $0x8,%eax
  8004200be4:	85 c0                	test   %eax,%eax
  8004200be6:	74 22                	je     8004200c0a <kbd_proc_data+0x1dd>
		if ('a' <= c && c <= 'z')
  8004200be8:	83 7d fc 60          	cmpl   $0x60,-0x4(%rbp)
  8004200bec:	7e 0c                	jle    8004200bfa <kbd_proc_data+0x1cd>
  8004200bee:	83 7d fc 7a          	cmpl   $0x7a,-0x4(%rbp)
  8004200bf2:	7f 06                	jg     8004200bfa <kbd_proc_data+0x1cd>
			c += 'A' - 'a';
  8004200bf4:	83 6d fc 20          	subl   $0x20,-0x4(%rbp)
  8004200bf8:	eb 10                	jmp    8004200c0a <kbd_proc_data+0x1dd>
		else if ('A' <= c && c <= 'Z')
  8004200bfa:	83 7d fc 40          	cmpl   $0x40,-0x4(%rbp)
  8004200bfe:	7e 0a                	jle    8004200c0a <kbd_proc_data+0x1dd>
  8004200c00:	83 7d fc 5a          	cmpl   $0x5a,-0x4(%rbp)
  8004200c04:	7f 04                	jg     8004200c0a <kbd_proc_data+0x1dd>
			c += 'a' - 'A';
  8004200c06:	83 45 fc 20          	addl   $0x20,-0x4(%rbp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8004200c0a:	48 b8 c8 c8 21 04 80 	movabs $0x800421c8c8,%rax
  8004200c11:	00 00 00 
  8004200c14:	8b 00                	mov    (%rax),%eax
  8004200c16:	f7 d0                	not    %eax
  8004200c18:	83 e0 06             	and    $0x6,%eax
  8004200c1b:	85 c0                	test   %eax,%eax
  8004200c1d:	75 37                	jne    8004200c56 <kbd_proc_data+0x229>
  8004200c1f:	81 7d fc e9 00 00 00 	cmpl   $0xe9,-0x4(%rbp)
  8004200c26:	75 2e                	jne    8004200c56 <kbd_proc_data+0x229>
		cprintf("Rebooting!\n");
  8004200c28:	48 bf 46 95 20 04 80 	movabs $0x8004209546,%rdi
  8004200c2f:	00 00 00 
  8004200c32:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200c37:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004200c3e:	00 00 00 
  8004200c41:	ff d2                	callq  *%rdx
  8004200c43:	c7 45 e4 92 00 00 00 	movl   $0x92,-0x1c(%rbp)
  8004200c4a:	c6 45 e3 03          	movb   $0x3,-0x1d(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004200c4e:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  8004200c52:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004200c55:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}
	return c;
  8004200c56:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004200c59:	c9                   	leaveq 
  8004200c5a:	c3                   	retq   

0000008004200c5b <kbd_intr>:

void
kbd_intr(void)
{
  8004200c5b:	55                   	push   %rbp
  8004200c5c:	48 89 e5             	mov    %rsp,%rbp
	cons_intr(kbd_proc_data);
  8004200c5f:	48 bf 2d 0a 20 04 80 	movabs $0x8004200a2d,%rdi
  8004200c66:	00 00 00 
  8004200c69:	48 b8 7d 0c 20 04 80 	movabs $0x8004200c7d,%rax
  8004200c70:	00 00 00 
  8004200c73:	ff d0                	callq  *%rax
}
  8004200c75:	5d                   	pop    %rbp
  8004200c76:	c3                   	retq   

0000008004200c77 <kbd_init>:

static void
kbd_init(void)
{
  8004200c77:	55                   	push   %rbp
  8004200c78:	48 89 e5             	mov    %rsp,%rbp
}
  8004200c7b:	5d                   	pop    %rbp
  8004200c7c:	c3                   	retq   

0000008004200c7d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
  8004200c7d:	55                   	push   %rbp
  8004200c7e:	48 89 e5             	mov    %rsp,%rbp
  8004200c81:	48 83 ec 20          	sub    $0x20,%rsp
  8004200c85:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int c;

	while ((c = (*proc)()) != -1) {
  8004200c89:	eb 6a                	jmp    8004200cf5 <cons_intr+0x78>
		if (c == 0)
  8004200c8b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004200c8f:	75 02                	jne    8004200c93 <cons_intr+0x16>
			continue;
  8004200c91:	eb 62                	jmp    8004200cf5 <cons_intr+0x78>
		cons.buf[cons.wpos++] = c;
  8004200c93:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200c9a:	00 00 00 
  8004200c9d:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200ca3:	8d 48 01             	lea    0x1(%rax),%ecx
  8004200ca6:	48 ba c0 c6 21 04 80 	movabs $0x800421c6c0,%rdx
  8004200cad:	00 00 00 
  8004200cb0:	89 8a 04 02 00 00    	mov    %ecx,0x204(%rdx)
  8004200cb6:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004200cb9:	89 d1                	mov    %edx,%ecx
  8004200cbb:	48 ba c0 c6 21 04 80 	movabs $0x800421c6c0,%rdx
  8004200cc2:	00 00 00 
  8004200cc5:	89 c0                	mov    %eax,%eax
  8004200cc7:	88 0c 02             	mov    %cl,(%rdx,%rax,1)
		if (cons.wpos == CONSBUFSIZE)
  8004200cca:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200cd1:	00 00 00 
  8004200cd4:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200cda:	3d 00 02 00 00       	cmp    $0x200,%eax
  8004200cdf:	75 14                	jne    8004200cf5 <cons_intr+0x78>
			cons.wpos = 0;
  8004200ce1:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200ce8:	00 00 00 
  8004200ceb:	c7 80 04 02 00 00 00 	movl   $0x0,0x204(%rax)
  8004200cf2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  8004200cf5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004200cf9:	ff d0                	callq  *%rax
  8004200cfb:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8004200cfe:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%rbp)
  8004200d02:	75 87                	jne    8004200c8b <cons_intr+0xe>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  8004200d04:	c9                   	leaveq 
  8004200d05:	c3                   	retq   

0000008004200d06 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  8004200d06:	55                   	push   %rbp
  8004200d07:	48 89 e5             	mov    %rsp,%rbp
  8004200d0a:	48 83 ec 10          	sub    $0x10,%rsp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  8004200d0e:	48 b8 40 04 20 04 80 	movabs $0x8004200440,%rax
  8004200d15:	00 00 00 
  8004200d18:	ff d0                	callq  *%rax
	kbd_intr();
  8004200d1a:	48 b8 5b 0c 20 04 80 	movabs $0x8004200c5b,%rax
  8004200d21:	00 00 00 
  8004200d24:	ff d0                	callq  *%rax

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  8004200d26:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200d2d:	00 00 00 
  8004200d30:	8b 90 00 02 00 00    	mov    0x200(%rax),%edx
  8004200d36:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200d3d:	00 00 00 
  8004200d40:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200d46:	39 c2                	cmp    %eax,%edx
  8004200d48:	74 69                	je     8004200db3 <cons_getc+0xad>
		c = cons.buf[cons.rpos++];
  8004200d4a:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200d51:	00 00 00 
  8004200d54:	8b 80 00 02 00 00    	mov    0x200(%rax),%eax
  8004200d5a:	8d 48 01             	lea    0x1(%rax),%ecx
  8004200d5d:	48 ba c0 c6 21 04 80 	movabs $0x800421c6c0,%rdx
  8004200d64:	00 00 00 
  8004200d67:	89 8a 00 02 00 00    	mov    %ecx,0x200(%rdx)
  8004200d6d:	48 ba c0 c6 21 04 80 	movabs $0x800421c6c0,%rdx
  8004200d74:	00 00 00 
  8004200d77:	89 c0                	mov    %eax,%eax
  8004200d79:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200d7d:	0f b6 c0             	movzbl %al,%eax
  8004200d80:	89 45 fc             	mov    %eax,-0x4(%rbp)
		if (cons.rpos == CONSBUFSIZE)
  8004200d83:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200d8a:	00 00 00 
  8004200d8d:	8b 80 00 02 00 00    	mov    0x200(%rax),%eax
  8004200d93:	3d 00 02 00 00       	cmp    $0x200,%eax
  8004200d98:	75 14                	jne    8004200dae <cons_getc+0xa8>
			cons.rpos = 0;
  8004200d9a:	48 b8 c0 c6 21 04 80 	movabs $0x800421c6c0,%rax
  8004200da1:	00 00 00 
  8004200da4:	c7 80 00 02 00 00 00 	movl   $0x0,0x200(%rax)
  8004200dab:	00 00 00 
		return c;
  8004200dae:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200db1:	eb 05                	jmp    8004200db8 <cons_getc+0xb2>
	}
	return 0;
  8004200db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004200db8:	c9                   	leaveq 
  8004200db9:	c3                   	retq   

0000008004200dba <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  8004200dba:	55                   	push   %rbp
  8004200dbb:	48 89 e5             	mov    %rsp,%rbp
  8004200dbe:	48 83 ec 10          	sub    $0x10,%rsp
  8004200dc2:	89 7d fc             	mov    %edi,-0x4(%rbp)
	serial_putc(c);
  8004200dc5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200dc8:	89 c7                	mov    %eax,%edi
  8004200dca:	48 b8 6d 04 20 04 80 	movabs $0x800420046d,%rax
  8004200dd1:	00 00 00 
  8004200dd4:	ff d0                	callq  *%rax
	lpt_putc(c);
  8004200dd6:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200dd9:	89 c7                	mov    %eax,%edi
  8004200ddb:	48 b8 a6 05 20 04 80 	movabs $0x80042005a6,%rax
  8004200de2:	00 00 00 
  8004200de5:	ff d0                	callq  *%rax
	cga_putc(c);
  8004200de7:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200dea:	89 c7                	mov    %eax,%edi
  8004200dec:	48 b8 45 07 20 04 80 	movabs $0x8004200745,%rax
  8004200df3:	00 00 00 
  8004200df6:	ff d0                	callq  *%rax
}
  8004200df8:	c9                   	leaveq 
  8004200df9:	c3                   	retq   

0000008004200dfa <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  8004200dfa:	55                   	push   %rbp
  8004200dfb:	48 89 e5             	mov    %rsp,%rbp
	cga_init();
  8004200dfe:	48 b8 2b 06 20 04 80 	movabs $0x800420062b,%rax
  8004200e05:	00 00 00 
  8004200e08:	ff d0                	callq  *%rax
	kbd_init();
  8004200e0a:	48 b8 77 0c 20 04 80 	movabs $0x8004200c77,%rax
  8004200e11:	00 00 00 
  8004200e14:	ff d0                	callq  *%rax
	serial_init();
  8004200e16:	48 b8 d2 04 20 04 80 	movabs $0x80042004d2,%rax
  8004200e1d:	00 00 00 
  8004200e20:	ff d0                	callq  *%rax

	if (!serial_exists)
  8004200e22:	48 b8 a0 c6 21 04 80 	movabs $0x800421c6a0,%rax
  8004200e29:	00 00 00 
  8004200e2c:	0f b6 00             	movzbl (%rax),%eax
  8004200e2f:	83 f0 01             	xor    $0x1,%eax
  8004200e32:	84 c0                	test   %al,%al
  8004200e34:	74 1b                	je     8004200e51 <cons_init+0x57>
		cprintf("Serial port does not exist!\n");
  8004200e36:	48 bf 52 95 20 04 80 	movabs $0x8004209552,%rdi
  8004200e3d:	00 00 00 
  8004200e40:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200e45:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004200e4c:	00 00 00 
  8004200e4f:	ff d2                	callq  *%rdx
}
  8004200e51:	5d                   	pop    %rbp
  8004200e52:	c3                   	retq   

0000008004200e53 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
  8004200e53:	55                   	push   %rbp
  8004200e54:	48 89 e5             	mov    %rsp,%rbp
  8004200e57:	48 83 ec 10          	sub    $0x10,%rsp
  8004200e5b:	89 7d fc             	mov    %edi,-0x4(%rbp)
	cons_putc(c);
  8004200e5e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200e61:	89 c7                	mov    %eax,%edi
  8004200e63:	48 b8 ba 0d 20 04 80 	movabs $0x8004200dba,%rax
  8004200e6a:	00 00 00 
  8004200e6d:	ff d0                	callq  *%rax
}
  8004200e6f:	c9                   	leaveq 
  8004200e70:	c3                   	retq   

0000008004200e71 <getchar>:

int
getchar(void)
{
  8004200e71:	55                   	push   %rbp
  8004200e72:	48 89 e5             	mov    %rsp,%rbp
  8004200e75:	48 83 ec 10          	sub    $0x10,%rsp
	int c;

	while ((c = cons_getc()) == 0)
  8004200e79:	48 b8 06 0d 20 04 80 	movabs $0x8004200d06,%rax
  8004200e80:	00 00 00 
  8004200e83:	ff d0                	callq  *%rax
  8004200e85:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8004200e88:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004200e8c:	74 eb                	je     8004200e79 <getchar+0x8>
		/* do nothing */;
	return c;
  8004200e8e:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004200e91:	c9                   	leaveq 
  8004200e92:	c3                   	retq   

0000008004200e93 <iscons>:

int
iscons(int fdnum)
{
  8004200e93:	55                   	push   %rbp
  8004200e94:	48 89 e5             	mov    %rsp,%rbp
  8004200e97:	48 83 ec 04          	sub    $0x4,%rsp
  8004200e9b:	89 7d fc             	mov    %edi,-0x4(%rbp)
	// used by readline
	return 1;
  8004200e9e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004200ea3:	c9                   	leaveq 
  8004200ea4:	c3                   	retq   

0000008004200ea5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
  8004200ea5:	55                   	push   %rbp
  8004200ea6:	48 89 e5             	mov    %rsp,%rbp
  8004200ea9:	48 83 ec 30          	sub    $0x30,%rsp
  8004200ead:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8004200eb0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004200eb4:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int i;

	for (i = 0; i < NCOMMANDS; i++)
  8004200eb8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004200ebf:	eb 6c                	jmp    8004200f2d <mon_help+0x88>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8004200ec1:	48 b9 80 c5 21 04 80 	movabs $0x800421c580,%rcx
  8004200ec8:	00 00 00 
  8004200ecb:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200ece:	48 63 d0             	movslq %eax,%rdx
  8004200ed1:	48 89 d0             	mov    %rdx,%rax
  8004200ed4:	48 01 c0             	add    %rax,%rax
  8004200ed7:	48 01 d0             	add    %rdx,%rax
  8004200eda:	48 c1 e0 03          	shl    $0x3,%rax
  8004200ede:	48 01 c8             	add    %rcx,%rax
  8004200ee1:	48 8b 48 08          	mov    0x8(%rax),%rcx
  8004200ee5:	48 be 80 c5 21 04 80 	movabs $0x800421c580,%rsi
  8004200eec:	00 00 00 
  8004200eef:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200ef2:	48 63 d0             	movslq %eax,%rdx
  8004200ef5:	48 89 d0             	mov    %rdx,%rax
  8004200ef8:	48 01 c0             	add    %rax,%rax
  8004200efb:	48 01 d0             	add    %rdx,%rax
  8004200efe:	48 c1 e0 03          	shl    $0x3,%rax
  8004200f02:	48 01 f0             	add    %rsi,%rax
  8004200f05:	48 8b 00             	mov    (%rax),%rax
  8004200f08:	48 89 ca             	mov    %rcx,%rdx
  8004200f0b:	48 89 c6             	mov    %rax,%rsi
  8004200f0e:	48 bf df 95 20 04 80 	movabs $0x80042095df,%rdi
  8004200f15:	00 00 00 
  8004200f18:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f1d:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004200f24:	00 00 00 
  8004200f27:	ff d1                	callq  *%rcx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
  8004200f29:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8004200f2d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200f30:	83 f8 02             	cmp    $0x2,%eax
  8004200f33:	76 8c                	jbe    8004200ec1 <mon_help+0x1c>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
  8004200f35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004200f3a:	c9                   	leaveq 
  8004200f3b:	c3                   	retq   

0000008004200f3c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
  8004200f3c:	55                   	push   %rbp
  8004200f3d:	48 89 e5             	mov    %rsp,%rbp
  8004200f40:	48 83 ec 30          	sub    $0x30,%rsp
  8004200f44:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8004200f47:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004200f4b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
  8004200f4f:	48 bf e8 95 20 04 80 	movabs $0x80042095e8,%rdi
  8004200f56:	00 00 00 
  8004200f59:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f5e:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004200f65:	00 00 00 
  8004200f68:	ff d2                	callq  *%rdx
	cprintf("  _start                  %08x (phys)\n", _start);
  8004200f6a:	48 be 0c 00 20 00 00 	movabs $0x20000c,%rsi
  8004200f71:	00 00 00 
  8004200f74:	48 bf 08 96 20 04 80 	movabs $0x8004209608,%rdi
  8004200f7b:	00 00 00 
  8004200f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f83:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004200f8a:	00 00 00 
  8004200f8d:	ff d2                	callq  *%rdx
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
  8004200f8f:	48 ba 0c 00 20 00 00 	movabs $0x20000c,%rdx
  8004200f96:	00 00 00 
  8004200f99:	48 be 0c 00 20 04 80 	movabs $0x800420000c,%rsi
  8004200fa0:	00 00 00 
  8004200fa3:	48 bf 30 96 20 04 80 	movabs $0x8004209630,%rdi
  8004200faa:	00 00 00 
  8004200fad:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200fb2:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004200fb9:	00 00 00 
  8004200fbc:	ff d1                	callq  *%rcx
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  8004200fbe:	48 ba ad 94 20 00 00 	movabs $0x2094ad,%rdx
  8004200fc5:	00 00 00 
  8004200fc8:	48 be ad 94 20 04 80 	movabs $0x80042094ad,%rsi
  8004200fcf:	00 00 00 
  8004200fd2:	48 bf 58 96 20 04 80 	movabs $0x8004209658,%rdi
  8004200fd9:	00 00 00 
  8004200fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200fe1:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004200fe8:	00 00 00 
  8004200feb:	ff d1                	callq  *%rcx
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  8004200fed:	48 ba a0 c6 21 00 00 	movabs $0x21c6a0,%rdx
  8004200ff4:	00 00 00 
  8004200ff7:	48 be a0 c6 21 04 80 	movabs $0x800421c6a0,%rsi
  8004200ffe:	00 00 00 
  8004201001:	48 bf 80 96 20 04 80 	movabs $0x8004209680,%rdi
  8004201008:	00 00 00 
  800420100b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201010:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004201017:	00 00 00 
  800420101a:	ff d1                	callq  *%rcx
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  800420101c:	48 ba 40 dd 21 00 00 	movabs $0x21dd40,%rdx
  8004201023:	00 00 00 
  8004201026:	48 be 40 dd 21 04 80 	movabs $0x800421dd40,%rsi
  800420102d:	00 00 00 
  8004201030:	48 bf a8 96 20 04 80 	movabs $0x80042096a8,%rdi
  8004201037:	00 00 00 
  800420103a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420103f:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  8004201046:	00 00 00 
  8004201049:	ff d1                	callq  *%rcx
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
  800420104b:	48 c7 45 f8 00 04 00 	movq   $0x400,-0x8(%rbp)
  8004201052:	00 
  8004201053:	48 b8 0c 00 20 04 80 	movabs $0x800420000c,%rax
  800420105a:	00 00 00 
  800420105d:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004201061:	48 29 c2             	sub    %rax,%rdx
  8004201064:	48 b8 40 dd 21 04 80 	movabs $0x800421dd40,%rax
  800420106b:	00 00 00 
  800420106e:	48 83 e8 01          	sub    $0x1,%rax
  8004201072:	48 01 d0             	add    %rdx,%rax
  8004201075:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8004201079:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420107d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004201082:	48 f7 75 f8          	divq   -0x8(%rbp)
  8004201086:	48 89 d0             	mov    %rdx,%rax
  8004201089:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420108d:	48 29 c2             	sub    %rax,%rdx
  8004201090:	48 89 d0             	mov    %rdx,%rax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
  8004201093:	48 8d 90 ff 03 00 00 	lea    0x3ff(%rax),%rdx
  800420109a:	48 85 c0             	test   %rax,%rax
  800420109d:	48 0f 48 c2          	cmovs  %rdx,%rax
  80042010a1:	48 c1 f8 0a          	sar    $0xa,%rax
  80042010a5:	48 89 c6             	mov    %rax,%rsi
  80042010a8:	48 bf d0 96 20 04 80 	movabs $0x80042096d0,%rdi
  80042010af:	00 00 00 
  80042010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  80042010b7:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042010be:	00 00 00 
  80042010c1:	ff d2                	callq  *%rdx
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
  80042010c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042010c8:	c9                   	leaveq 
  80042010c9:	c3                   	retq   

00000080042010ca <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  80042010ca:	55                   	push   %rbp
  80042010cb:	48 89 e5             	mov    %rsp,%rbp
  80042010ce:	48 81 ec 20 05 00 00 	sub    $0x520,%rsp
  80042010d5:	89 bd fc fa ff ff    	mov    %edi,-0x504(%rbp)
  80042010db:	48 89 b5 f0 fa ff ff 	mov    %rsi,-0x510(%rbp)
  80042010e2:	48 89 95 e8 fa ff ff 	mov    %rdx,-0x518(%rbp)

static __inline uint64_t
read_rbp(void)
{
	uint64_t rbp;
	__asm __volatile("movq %%rbp,%0" : "=r" (rbp)::"cc","memory");
  80042010e9:	48 89 e8             	mov    %rbp,%rax
  80042010ec:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	return rbp;
  80042010f0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
	// Your code here.
	// read register base pointer
	uint64_t *rbp = (uint64_t *)read_rbp();
  80042010f4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	uint64_t rip;
	read_rip(rip);
  80042010f8:	48 8d 05 00 00 00 00 	lea    0x0(%rip),%rax        # 42010ff <_start+0x40010f3>
  80042010ff:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	cprintf("Stack backtrace: \n");
  8004201103:	48 bf fa 96 20 04 80 	movabs $0x80042096fa,%rdi
  800420110a:	00 00 00 
  800420110d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201112:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004201119:	00 00 00 
  800420111c:	ff d2                	callq  *%rdx

	do {
		
		cprintf("rbp %016x   rip %016x\n", rbp, rip);
  800420111e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004201122:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201126:	48 89 c6             	mov    %rax,%rsi
  8004201129:	48 bf 0d 97 20 04 80 	movabs $0x800420970d,%rdi
  8004201130:	00 00 00 
  8004201133:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201138:	48 b9 87 15 20 04 80 	movabs $0x8004201587,%rcx
  800420113f:	00 00 00 
  8004201142:	ff d1                	callq  *%rcx
		struct Ripdebuginfo info;
		debuginfo_rip(rip, &info);
  8004201144:	48 8d 95 00 fb ff ff 	lea    -0x500(%rbp),%rdx
  800420114b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420114f:	48 89 d6             	mov    %rdx,%rsi
  8004201152:	48 89 c7             	mov    %rax,%rdi
  8004201155:	48 b8 0f 1e 20 04 80 	movabs $0x8004201e0f,%rax
  800420115c:	00 00 00 
  800420115f:	ff d0                	callq  *%rax
        	int offset=rip-info.rip_fn_addr;
  8004201161:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004201165:	89 c2                	mov    %eax,%edx
  8004201167:	48 8b 85 20 fb ff ff 	mov    -0x4e0(%rbp),%rax
  800420116e:	29 c2                	sub    %eax,%edx
  8004201170:	89 d0                	mov    %edx,%eax
  8004201172:	89 45 e8             	mov    %eax,-0x18(%rbp)
		cprintf(" %s:%d: %s+%016x ",info.rip_file, info.rip_line, info.rip_fn_name,offset);
  8004201175:	48 8b 8d 10 fb ff ff 	mov    -0x4f0(%rbp),%rcx
  800420117c:	8b 95 08 fb ff ff    	mov    -0x4f8(%rbp),%edx
  8004201182:	48 8b 85 00 fb ff ff 	mov    -0x500(%rbp),%rax
  8004201189:	8b 75 e8             	mov    -0x18(%rbp),%esi
  800420118c:	41 89 f0             	mov    %esi,%r8d
  800420118f:	48 89 c6             	mov    %rax,%rsi
  8004201192:	48 bf 24 97 20 04 80 	movabs $0x8004209724,%rdi
  8004201199:	00 00 00 
  800420119c:	b8 00 00 00 00       	mov    $0x0,%eax
  80042011a1:	49 b9 87 15 20 04 80 	movabs $0x8004201587,%r9
  80042011a8:	00 00 00 
  80042011ab:	41 ff d1             	callq  *%r9
		cprintf("args:%x ",info.rip_fn_narg);
  80042011ae:	8b 85 28 fb ff ff    	mov    -0x4d8(%rbp),%eax
  80042011b4:	89 c6                	mov    %eax,%esi
  80042011b6:	48 bf 36 97 20 04 80 	movabs $0x8004209736,%rdi
  80042011bd:	00 00 00 
  80042011c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80042011c5:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042011cc:	00 00 00 
  80042011cf:	ff d2                	callq  *%rdx
		int i;
		for(i = 1; i <= info.rip_fn_narg; i++) {
  80042011d1:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%rbp)
  80042011d8:	eb 39                	jmp    8004201213 <mon_backtrace+0x149>
			cprintf("%016x ", *((int *)(rbp) -i));
  80042011da:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042011dd:	48 98                	cltq   
  80042011df:	48 c1 e0 02          	shl    $0x2,%rax
  80042011e3:	48 f7 d8             	neg    %rax
  80042011e6:	48 89 c2             	mov    %rax,%rdx
  80042011e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042011ed:	48 01 d0             	add    %rdx,%rax
  80042011f0:	8b 00                	mov    (%rax),%eax
  80042011f2:	89 c6                	mov    %eax,%esi
  80042011f4:	48 bf 3f 97 20 04 80 	movabs $0x800420973f,%rdi
  80042011fb:	00 00 00 
  80042011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201203:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  800420120a:	00 00 00 
  800420120d:	ff d2                	callq  *%rdx
		debuginfo_rip(rip, &info);
        	int offset=rip-info.rip_fn_addr;
		cprintf(" %s:%d: %s+%016x ",info.rip_file, info.rip_line, info.rip_fn_name,offset);
		cprintf("args:%x ",info.rip_fn_narg);
		int i;
		for(i = 1; i <= info.rip_fn_narg; i++) {
  800420120f:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  8004201213:	8b 85 28 fb ff ff    	mov    -0x4d8(%rbp),%eax
  8004201219:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420121c:	7d bc                	jge    80042011da <mon_backtrace+0x110>
			cprintf("%016x ", *((int *)(rbp) -i));
		}     
		cprintf("\n");
  800420121e:	48 bf 46 97 20 04 80 	movabs $0x8004209746,%rdi
  8004201225:	00 00 00 
  8004201228:	b8 00 00 00 00       	mov    $0x0,%eax
  800420122d:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004201234:	00 00 00 
  8004201237:	ff d2                	callq  *%rdx
		rip = (uint64_t) *(rbp+1);
  8004201239:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420123d:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004201241:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		rbp = (uint64_t *)(*rbp);
  8004201245:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201249:	48 8b 00             	mov    (%rax),%rax
  800420124c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	} while (rbp!=0);
  8004201250:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004201255:	0f 85 c3 fe ff ff    	jne    800420111e <mon_backtrace+0x54>

    return 0;
  800420125b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004201260:	c9                   	leaveq 
  8004201261:	c3                   	retq   

0000008004201262 <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
  8004201262:	55                   	push   %rbp
  8004201263:	48 89 e5             	mov    %rsp,%rbp
  8004201266:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
  800420126d:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  8004201274:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
  800420127b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	argv[argc] = 0;
  8004201282:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004201285:	48 98                	cltq   
  8004201287:	48 c7 84 c5 70 ff ff 	movq   $0x0,-0x90(%rbp,%rax,8)
  800420128e:	ff 00 00 00 00 
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  8004201293:	eb 15                	jmp    80042012aa <runcmd+0x48>
			*buf++ = 0;
  8004201295:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420129c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80042012a0:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  80042012a7:	c6 00 00             	movb   $0x0,(%rax)
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  80042012aa:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042012b1:	0f b6 00             	movzbl (%rax),%eax
  80042012b4:	84 c0                	test   %al,%al
  80042012b6:	74 2a                	je     80042012e2 <runcmd+0x80>
  80042012b8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042012bf:	0f b6 00             	movzbl (%rax),%eax
  80042012c2:	0f be c0             	movsbl %al,%eax
  80042012c5:	89 c6                	mov    %eax,%esi
  80042012c7:	48 bf 48 97 20 04 80 	movabs $0x8004209748,%rdi
  80042012ce:	00 00 00 
  80042012d1:	48 b8 51 30 20 04 80 	movabs $0x8004203051,%rax
  80042012d8:	00 00 00 
  80042012db:	ff d0                	callq  *%rax
  80042012dd:	48 85 c0             	test   %rax,%rax
  80042012e0:	75 b3                	jne    8004201295 <runcmd+0x33>
			*buf++ = 0;
		if (*buf == 0)
  80042012e2:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042012e9:	0f b6 00             	movzbl (%rax),%eax
  80042012ec:	84 c0                	test   %al,%al
  80042012ee:	75 21                	jne    8004201311 <runcmd+0xaf>
			break;
  80042012f0:	90                   	nop
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
  80042012f1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80042012f4:	48 98                	cltq   
  80042012f6:	48 c7 84 c5 70 ff ff 	movq   $0x0,-0x90(%rbp,%rax,8)
  80042012fd:	ff 00 00 00 00 

	// Lookup and invoke the command
	if (argc == 0)
  8004201302:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004201306:	0f 85 a1 00 00 00    	jne    80042013ad <runcmd+0x14b>
  800420130c:	e9 92 00 00 00       	jmpq   80042013a3 <runcmd+0x141>
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  8004201311:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
  8004201315:	75 2a                	jne    8004201341 <runcmd+0xdf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  8004201317:	be 10 00 00 00       	mov    $0x10,%esi
  800420131c:	48 bf 4d 97 20 04 80 	movabs $0x800420974d,%rdi
  8004201323:	00 00 00 
  8004201326:	b8 00 00 00 00       	mov    $0x0,%eax
  800420132b:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004201332:	00 00 00 
  8004201335:	ff d2                	callq  *%rdx
			return 0;
  8004201337:	b8 00 00 00 00       	mov    $0x0,%eax
  800420133c:	e9 30 01 00 00       	jmpq   8004201471 <runcmd+0x20f>
		}
		argv[argc++] = buf;
  8004201341:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004201344:	8d 50 01             	lea    0x1(%rax),%edx
  8004201347:	89 55 fc             	mov    %edx,-0x4(%rbp)
  800420134a:	48 98                	cltq   
  800420134c:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  8004201353:	48 89 94 c5 70 ff ff 	mov    %rdx,-0x90(%rbp,%rax,8)
  800420135a:	ff 
		while (*buf && !strchr(WHITESPACE, *buf))
  800420135b:	eb 08                	jmp    8004201365 <runcmd+0x103>
			buf++;
  800420135d:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  8004201364:	01 
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  8004201365:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420136c:	0f b6 00             	movzbl (%rax),%eax
  800420136f:	84 c0                	test   %al,%al
  8004201371:	74 2a                	je     800420139d <runcmd+0x13b>
  8004201373:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420137a:	0f b6 00             	movzbl (%rax),%eax
  800420137d:	0f be c0             	movsbl %al,%eax
  8004201380:	89 c6                	mov    %eax,%esi
  8004201382:	48 bf 48 97 20 04 80 	movabs $0x8004209748,%rdi
  8004201389:	00 00 00 
  800420138c:	48 b8 51 30 20 04 80 	movabs $0x8004203051,%rax
  8004201393:	00 00 00 
  8004201396:	ff d0                	callq  *%rax
  8004201398:	48 85 c0             	test   %rax,%rax
  800420139b:	74 c0                	je     800420135d <runcmd+0xfb>
			buf++;
	}
  800420139d:	90                   	nop
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  800420139e:	e9 07 ff ff ff       	jmpq   80042012aa <runcmd+0x48>
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
  80042013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  80042013a8:	e9 c4 00 00 00       	jmpq   8004201471 <runcmd+0x20f>
	for (i = 0; i < NCOMMANDS; i++) {
  80042013ad:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  80042013b4:	e9 82 00 00 00       	jmpq   800420143b <runcmd+0x1d9>
		if (strcmp(argv[0], commands[i].name) == 0)
  80042013b9:	48 b9 80 c5 21 04 80 	movabs $0x800421c580,%rcx
  80042013c0:	00 00 00 
  80042013c3:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80042013c6:	48 63 d0             	movslq %eax,%rdx
  80042013c9:	48 89 d0             	mov    %rdx,%rax
  80042013cc:	48 01 c0             	add    %rax,%rax
  80042013cf:	48 01 d0             	add    %rdx,%rax
  80042013d2:	48 c1 e0 03          	shl    $0x3,%rax
  80042013d6:	48 01 c8             	add    %rcx,%rax
  80042013d9:	48 8b 10             	mov    (%rax),%rdx
  80042013dc:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  80042013e3:	48 89 d6             	mov    %rdx,%rsi
  80042013e6:	48 89 c7             	mov    %rax,%rdi
  80042013e9:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  80042013f0:	00 00 00 
  80042013f3:	ff d0                	callq  *%rax
  80042013f5:	85 c0                	test   %eax,%eax
  80042013f7:	75 3e                	jne    8004201437 <runcmd+0x1d5>
			return commands[i].func(argc, argv, tf);
  80042013f9:	48 b9 80 c5 21 04 80 	movabs $0x800421c580,%rcx
  8004201400:	00 00 00 
  8004201403:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004201406:	48 63 d0             	movslq %eax,%rdx
  8004201409:	48 89 d0             	mov    %rdx,%rax
  800420140c:	48 01 c0             	add    %rax,%rax
  800420140f:	48 01 d0             	add    %rdx,%rax
  8004201412:	48 c1 e0 03          	shl    $0x3,%rax
  8004201416:	48 01 c8             	add    %rcx,%rax
  8004201419:	48 83 c0 10          	add    $0x10,%rax
  800420141d:	48 8b 00             	mov    (%rax),%rax
  8004201420:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004201427:	48 8d b5 70 ff ff ff 	lea    -0x90(%rbp),%rsi
  800420142e:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8004201431:	89 cf                	mov    %ecx,%edi
  8004201433:	ff d0                	callq  *%rax
  8004201435:	eb 3a                	jmp    8004201471 <runcmd+0x20f>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  8004201437:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  800420143b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  800420143e:	83 f8 02             	cmp    $0x2,%eax
  8004201441:	0f 86 72 ff ff ff    	jbe    80042013b9 <runcmd+0x157>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  8004201447:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420144e:	48 89 c6             	mov    %rax,%rsi
  8004201451:	48 bf 6a 97 20 04 80 	movabs $0x800420976a,%rdi
  8004201458:	00 00 00 
  800420145b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201460:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004201467:	00 00 00 
  800420146a:	ff d2                	callq  *%rdx
	return 0;
  800420146c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004201471:	c9                   	leaveq 
  8004201472:	c3                   	retq   

0000008004201473 <monitor>:

void
monitor(struct Trapframe *tf)
{
  8004201473:	55                   	push   %rbp
  8004201474:	48 89 e5             	mov    %rsp,%rbp
  8004201477:	48 83 ec 20          	sub    $0x20,%rsp
  800420147b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
  800420147f:	48 bf 80 97 20 04 80 	movabs $0x8004209780,%rdi
  8004201486:	00 00 00 
  8004201489:	b8 00 00 00 00       	mov    $0x0,%eax
  800420148e:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004201495:	00 00 00 
  8004201498:	ff d2                	callq  *%rdx
	cprintf("Type 'help' for a list of commands.\n");
  800420149a:	48 bf a8 97 20 04 80 	movabs $0x80042097a8,%rdi
  80042014a1:	00 00 00 
  80042014a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042014a9:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  80042014b0:	00 00 00 
  80042014b3:	ff d2                	callq  *%rdx


	while (1) {
		buf = readline("K> ");
  80042014b5:	48 bf cd 97 20 04 80 	movabs $0x80042097cd,%rdi
  80042014bc:	00 00 00 
  80042014bf:	48 b8 70 2c 20 04 80 	movabs $0x8004202c70,%rax
  80042014c6:	00 00 00 
  80042014c9:	ff d0                	callq  *%rax
  80042014cb:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		if (buf != NULL)
  80042014cf:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042014d4:	74 20                	je     80042014f6 <monitor+0x83>
			if (runcmd(buf, tf) < 0)
  80042014d6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042014da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042014de:	48 89 d6             	mov    %rdx,%rsi
  80042014e1:	48 89 c7             	mov    %rax,%rdi
  80042014e4:	48 b8 62 12 20 04 80 	movabs $0x8004201262,%rax
  80042014eb:	00 00 00 
  80042014ee:	ff d0                	callq  *%rax
  80042014f0:	85 c0                	test   %eax,%eax
  80042014f2:	79 02                	jns    80042014f6 <monitor+0x83>
				break;
  80042014f4:	eb 02                	jmp    80042014f8 <monitor+0x85>
	}
  80042014f6:	eb bd                	jmp    80042014b5 <monitor+0x42>
}
  80042014f8:	c9                   	leaveq 
  80042014f9:	c3                   	retq   

00000080042014fa <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
  80042014fa:	55                   	push   %rbp
  80042014fb:	48 89 e5             	mov    %rsp,%rbp
  80042014fe:	48 83 ec 10          	sub    $0x10,%rsp
  8004201502:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8004201505:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	cputchar(ch);
  8004201509:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420150c:	89 c7                	mov    %eax,%edi
  800420150e:	48 b8 53 0e 20 04 80 	movabs $0x8004200e53,%rax
  8004201515:	00 00 00 
  8004201518:	ff d0                	callq  *%rax
	*cnt++;
  800420151a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420151e:	48 83 c0 04          	add    $0x4,%rax
  8004201522:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
}
  8004201526:	c9                   	leaveq 
  8004201527:	c3                   	retq   

0000008004201528 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004201528:	55                   	push   %rbp
  8004201529:	48 89 e5             	mov    %rsp,%rbp
  800420152c:	48 83 ec 30          	sub    $0x30,%rsp
  8004201530:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004201534:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int cnt = 0;
  8004201538:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	va_list aq;
	va_copy(aq,ap);
  800420153f:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  8004201543:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004201547:	48 8b 0a             	mov    (%rdx),%rcx
  800420154a:	48 89 08             	mov    %rcx,(%rax)
  800420154d:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004201551:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8004201555:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8004201559:	48 89 50 10          	mov    %rdx,0x10(%rax)
	vprintfmt((void*)putch, &cnt, fmt, aq);
  800420155d:	48 8d 4d e0          	lea    -0x20(%rbp),%rcx
  8004201561:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004201565:	48 8d 45 fc          	lea    -0x4(%rbp),%rax
  8004201569:	48 89 c6             	mov    %rax,%rsi
  800420156c:	48 bf fa 14 20 04 80 	movabs $0x80042014fa,%rdi
  8004201573:	00 00 00 
  8004201576:	48 b8 da 24 20 04 80 	movabs $0x80042024da,%rax
  800420157d:	00 00 00 
  8004201580:	ff d0                	callq  *%rax
	va_end(aq);
	return cnt;
  8004201582:	8b 45 fc             	mov    -0x4(%rbp),%eax

}
  8004201585:	c9                   	leaveq 
  8004201586:	c3                   	retq   

0000008004201587 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004201587:	55                   	push   %rbp
  8004201588:	48 89 e5             	mov    %rsp,%rbp
  800420158b:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  8004201592:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8004201599:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  80042015a0:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80042015a7:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80042015ae:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80042015b5:	84 c0                	test   %al,%al
  80042015b7:	74 20                	je     80042015d9 <cprintf+0x52>
  80042015b9:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80042015bd:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  80042015c1:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80042015c5:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80042015c9:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80042015cd:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  80042015d1:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80042015d5:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  80042015d9:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
	va_list ap;
	int cnt;
	va_start(ap, fmt);
  80042015e0:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  80042015e7:	00 00 00 
  80042015ea:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  80042015f1:	00 00 00 
  80042015f4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80042015f8:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80042015ff:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004201606:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
	va_list aq;
	va_copy(aq,ap);
  800420160d:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8004201614:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  800420161b:	48 8b 0a             	mov    (%rdx),%rcx
  800420161e:	48 89 08             	mov    %rcx,(%rax)
  8004201621:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004201625:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8004201629:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800420162d:	48 89 50 10          	mov    %rdx,0x10(%rax)
	cnt = vcprintf(fmt, aq);
  8004201631:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  8004201638:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800420163f:	48 89 d6             	mov    %rdx,%rsi
  8004201642:	48 89 c7             	mov    %rax,%rdi
  8004201645:	48 b8 28 15 20 04 80 	movabs $0x8004201528,%rax
  800420164c:	00 00 00 
  800420164f:	ff d0                	callq  *%rax
  8004201651:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
	va_end(aq);

	return cnt;
  8004201657:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  800420165d:	c9                   	leaveq 
  800420165e:	c3                   	retq   

000000800420165f <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int64_t
syscall(uint64_t syscallno, uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4, uint64_t a5)
{
  800420165f:	55                   	push   %rbp
  8004201660:	48 89 e5             	mov    %rsp,%rbp
  8004201663:	48 83 ec 30          	sub    $0x30,%rsp
  8004201667:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  800420166b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  800420166f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004201673:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004201677:	4c 89 45 d8          	mov    %r8,-0x28(%rbp)
  800420167b:	4c 89 4d d0          	mov    %r9,-0x30(%rbp)
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
  800420167f:	48 ba d1 97 20 04 80 	movabs $0x80042097d1,%rdx
  8004201686:	00 00 00 
  8004201689:	be 0e 00 00 00       	mov    $0xe,%esi
  800420168e:	48 bf e9 97 20 04 80 	movabs $0x80042097e9,%rdi
  8004201695:	00 00 00 
  8004201698:	b8 00 00 00 00       	mov    $0x0,%eax
  800420169d:	48 b9 98 01 20 04 80 	movabs $0x8004200198,%rcx
  80042016a4:	00 00 00 
  80042016a7:	ff d1                	callq  *%rcx

00000080042016a9 <list_func_die>:

#endif


int list_func_die(struct Ripdebuginfo *info, Dwarf_Die *die, uint64_t addr)
{
  80042016a9:	55                   	push   %rbp
  80042016aa:	48 89 e5             	mov    %rsp,%rbp
  80042016ad:	48 81 ec f0 61 00 00 	sub    $0x61f0,%rsp
  80042016b4:	48 89 bd 58 9e ff ff 	mov    %rdi,-0x61a8(%rbp)
  80042016bb:	48 89 b5 50 9e ff ff 	mov    %rsi,-0x61b0(%rbp)
  80042016c2:	48 89 95 48 9e ff ff 	mov    %rdx,-0x61b8(%rbp)
	_Dwarf_Line ln;
	Dwarf_Attribute *low;
	Dwarf_Attribute *high;
	Dwarf_CU *cu = die->cu_header;
  80042016c9:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042016d0:	48 8b 80 60 03 00 00 	mov    0x360(%rax),%rax
  80042016d7:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	Dwarf_Die *cudie = die->cu_die; 
  80042016db:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042016e2:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  80042016e9:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	Dwarf_Die ret, sib=*die; 
  80042016ed:	48 8b 95 50 9e ff ff 	mov    -0x61b0(%rbp),%rdx
  80042016f4:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  80042016fb:	48 89 d1             	mov    %rdx,%rcx
  80042016fe:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004201703:	48 89 ce             	mov    %rcx,%rsi
  8004201706:	48 89 c7             	mov    %rax,%rdi
  8004201709:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004201710:	00 00 00 
  8004201713:	ff d0                	callq  *%rax
	Dwarf_Attribute *attr;
	uint64_t offset;
	uint64_t ret_val=8;
  8004201715:	48 c7 45 f8 08 00 00 	movq   $0x8,-0x8(%rbp)
  800420171c:	00 
	uint64_t ret_offset=0;
  800420171d:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004201724:	00 

	if(die->die_tag != DW_TAG_subprogram)
  8004201725:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  800420172c:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004201730:	48 83 f8 2e          	cmp    $0x2e,%rax
  8004201734:	74 0a                	je     8004201740 <list_func_die+0x97>
		return 0;
  8004201736:	b8 00 00 00 00       	mov    $0x0,%eax
  800420173b:	e9 cd 06 00 00       	jmpq   8004201e0d <list_func_die+0x764>

	memset(&ln, 0, sizeof(_Dwarf_Line));
  8004201740:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004201747:	ba 38 00 00 00       	mov    $0x38,%edx
  800420174c:	be 00 00 00 00       	mov    $0x0,%esi
  8004201751:	48 89 c7             	mov    %rax,%rdi
  8004201754:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  800420175b:	00 00 00 
  800420175e:	ff d0                	callq  *%rax

	low  = _dwarf_attr_find(die, DW_AT_low_pc);
  8004201760:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004201767:	be 11 00 00 00       	mov    $0x11,%esi
  800420176c:	48 89 c7             	mov    %rax,%rdi
  800420176f:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201776:	00 00 00 
  8004201779:	ff d0                	callq  *%rax
  800420177b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	high = _dwarf_attr_find(die, DW_AT_high_pc);
  800420177f:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004201786:	be 12 00 00 00       	mov    $0x12,%esi
  800420178b:	48 89 c7             	mov    %rax,%rdi
  800420178e:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201795:	00 00 00 
  8004201798:	ff d0                	callq  *%rax
  800420179a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)

	if((low && (low->u[0].u64 < addr)) && (high && (high->u[0].u64 > addr)))
  800420179e:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  80042017a3:	0f 84 5f 06 00 00    	je     8004201e08 <list_func_die+0x75f>
  80042017a9:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042017ad:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042017b1:	48 3b 85 48 9e ff ff 	cmp    -0x61b8(%rbp),%rax
  80042017b8:	0f 83 4a 06 00 00    	jae    8004201e08 <list_func_die+0x75f>
  80042017be:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  80042017c3:	0f 84 3f 06 00 00    	je     8004201e08 <list_func_die+0x75f>
  80042017c9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042017cd:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042017d1:	48 3b 85 48 9e ff ff 	cmp    -0x61b8(%rbp),%rax
  80042017d8:	0f 86 2a 06 00 00    	jbe    8004201e08 <list_func_die+0x75f>
	{
		info->rip_file = die->cu_die->die_name;
  80042017de:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042017e5:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  80042017ec:	48 8b 90 50 03 00 00 	mov    0x350(%rax),%rdx
  80042017f3:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042017fa:	48 89 10             	mov    %rdx,(%rax)

		info->rip_fn_name = die->die_name;
  80042017fd:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004201804:	48 8b 90 50 03 00 00 	mov    0x350(%rax),%rdx
  800420180b:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201812:	48 89 50 10          	mov    %rdx,0x10(%rax)
		info->rip_fn_namelen = strlen(die->die_name);
  8004201816:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  800420181d:	48 8b 80 50 03 00 00 	mov    0x350(%rax),%rax
  8004201824:	48 89 c7             	mov    %rax,%rdi
  8004201827:	48 b8 bf 2d 20 04 80 	movabs $0x8004202dbf,%rax
  800420182e:	00 00 00 
  8004201831:	ff d0                	callq  *%rax
  8004201833:	48 8b 95 58 9e ff ff 	mov    -0x61a8(%rbp),%rdx
  800420183a:	89 42 18             	mov    %eax,0x18(%rdx)

		info->rip_fn_addr = (uintptr_t)low->u[0].u64;
  800420183d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004201841:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8004201845:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  800420184c:	48 89 50 20          	mov    %rdx,0x20(%rax)

		assert(die->cu_die);	
  8004201850:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004201857:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  800420185e:	48 85 c0             	test   %rax,%rax
  8004201861:	75 35                	jne    8004201898 <list_func_die+0x1ef>
  8004201863:	48 b9 20 9b 20 04 80 	movabs $0x8004209b20,%rcx
  800420186a:	00 00 00 
  800420186d:	48 ba 2c 9b 20 04 80 	movabs $0x8004209b2c,%rdx
  8004201874:	00 00 00 
  8004201877:	be 88 00 00 00       	mov    $0x88,%esi
  800420187c:	48 bf 41 9b 20 04 80 	movabs $0x8004209b41,%rdi
  8004201883:	00 00 00 
  8004201886:	b8 00 00 00 00       	mov    $0x0,%eax
  800420188b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004201892:	00 00 00 
  8004201895:	41 ff d0             	callq  *%r8
		dwarf_srclines(die->cu_die, &ln, addr, NULL); 
  8004201898:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  800420189f:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  80042018a6:	48 8b 95 48 9e ff ff 	mov    -0x61b8(%rbp),%rdx
  80042018ad:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  80042018b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042018b9:	48 89 c7             	mov    %rax,%rdi
  80042018bc:	48 b8 20 86 20 04 80 	movabs $0x8004208620,%rax
  80042018c3:	00 00 00 
  80042018c6:	ff d0                	callq  *%rax

		info->rip_line = ln.ln_lineno;
  80042018c8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042018cf:	89 c2                	mov    %eax,%edx
  80042018d1:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042018d8:	89 50 08             	mov    %edx,0x8(%rax)
		info->rip_fn_narg = 0;
  80042018db:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042018e2:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%rax)

		Dwarf_Attribute* attr;

		if(dwarf_child(dbg, cu, &sib, &ret) != DW_DLE_NO_ENTRY)
  80042018e9:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042018f0:	00 00 00 
  80042018f3:	48 8b 00             	mov    (%rax),%rax
  80042018f6:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  80042018fd:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  8004201904:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  8004201908:	48 89 c7             	mov    %rax,%rdi
  800420190b:	48 b8 d0 52 20 04 80 	movabs $0x80042052d0,%rax
  8004201912:	00 00 00 
  8004201915:	ff d0                	callq  *%rax
  8004201917:	83 f8 04             	cmp    $0x4,%eax
  800420191a:	0f 84 e1 04 00 00    	je     8004201e01 <list_func_die+0x758>
		{
			if(ret.die_tag != DW_TAG_formal_parameter)
  8004201920:	48 8b 85 f8 ce ff ff 	mov    -0x3108(%rbp),%rax
  8004201927:	48 83 f8 05          	cmp    $0x5,%rax
  800420192b:	74 05                	je     8004201932 <list_func_die+0x289>
				goto last;
  800420192d:	e9 cf 04 00 00       	jmpq   8004201e01 <list_func_die+0x758>

			attr = _dwarf_attr_find(&ret, DW_AT_type);
  8004201932:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004201939:	be 49 00 00 00       	mov    $0x49,%esi
  800420193e:	48 89 c7             	mov    %rax,%rdi
  8004201941:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201948:	00 00 00 
  800420194b:	ff d0                	callq  *%rax
  800420194d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	
		try_again:
			if(attr != NULL)
  8004201951:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201956:	0f 84 d7 00 00 00    	je     8004201a33 <list_func_die+0x38a>
			{
				offset = (uint64_t)cu->cu_offset + attr->u[0].u64;
  800420195c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004201960:	48 8b 50 30          	mov    0x30(%rax),%rdx
  8004201964:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201968:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420196c:	48 01 d0             	add    %rdx,%rax
  800420196f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
				dwarf_offdie(dbg, offset, &sib, *cu);
  8004201973:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  800420197a:	00 00 00 
  800420197d:	48 8b 08             	mov    (%rax),%rcx
  8004201980:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  8004201987:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  800420198b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420198f:	48 8b 38             	mov    (%rax),%rdi
  8004201992:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004201996:	48 8b 78 08          	mov    0x8(%rax),%rdi
  800420199a:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  800420199f:	48 8b 78 10          	mov    0x10(%rax),%rdi
  80042019a3:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  80042019a8:	48 8b 78 18          	mov    0x18(%rax),%rdi
  80042019ac:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  80042019b1:	48 8b 78 20          	mov    0x20(%rax),%rdi
  80042019b5:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  80042019ba:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80042019be:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  80042019c3:	48 8b 40 30          	mov    0x30(%rax),%rax
  80042019c7:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  80042019cc:	48 89 cf             	mov    %rcx,%rdi
  80042019cf:	48 b8 f6 4e 20 04 80 	movabs $0x8004204ef6,%rax
  80042019d6:	00 00 00 
  80042019d9:	ff d0                	callq  *%rax
				attr = _dwarf_attr_find(&sib, DW_AT_byte_size);
  80042019db:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  80042019e2:	be 0b 00 00 00       	mov    $0xb,%esi
  80042019e7:	48 89 c7             	mov    %rax,%rdi
  80042019ea:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  80042019f1:	00 00 00 
  80042019f4:	ff d0                	callq  *%rax
  80042019f6:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
		
				if(attr != NULL)
  80042019fa:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042019ff:	74 0e                	je     8004201a0f <list_func_die+0x366>
				{
					ret_val = attr->u[0].u64;
  8004201a01:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201a05:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004201a09:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004201a0d:	eb 24                	jmp    8004201a33 <list_func_die+0x38a>
				}
				else
				{
					attr = _dwarf_attr_find(&sib, DW_AT_type);
  8004201a0f:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004201a16:	be 49 00 00 00       	mov    $0x49,%esi
  8004201a1b:	48 89 c7             	mov    %rax,%rdi
  8004201a1e:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201a25:	00 00 00 
  8004201a28:	ff d0                	callq  *%rax
  8004201a2a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
					goto try_again;
  8004201a2e:	e9 1e ff ff ff       	jmpq   8004201951 <list_func_die+0x2a8>
				}
			}

			ret_offset = 0;
  8004201a33:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004201a3a:	00 
			attr = _dwarf_attr_find(&ret, DW_AT_location);
  8004201a3b:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004201a42:	be 02 00 00 00       	mov    $0x2,%esi
  8004201a47:	48 89 c7             	mov    %rax,%rdi
  8004201a4a:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201a51:	00 00 00 
  8004201a54:	ff d0                	callq  *%rax
  8004201a56:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			if (attr != NULL)
  8004201a5a:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201a5f:	0f 84 a2 00 00 00    	je     8004201b07 <list_func_die+0x45e>
			{
				Dwarf_Unsigned loc_len = attr->at_block.bl_len;
  8004201a65:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201a69:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004201a6d:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
				Dwarf_Small *loc_ptr = attr->at_block.bl_data;
  8004201a71:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201a75:	48 8b 40 40          	mov    0x40(%rax),%rax
  8004201a79:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
				Dwarf_Small atom;
				Dwarf_Unsigned op1, op2;

				switch(attr->at_form) {
  8004201a7d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201a81:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004201a85:	48 83 f8 03          	cmp    $0x3,%rax
  8004201a89:	72 7c                	jb     8004201b07 <list_func_die+0x45e>
  8004201a8b:	48 83 f8 04          	cmp    $0x4,%rax
  8004201a8f:	76 06                	jbe    8004201a97 <list_func_die+0x3ee>
  8004201a91:	48 83 f8 0a          	cmp    $0xa,%rax
  8004201a95:	75 70                	jne    8004201b07 <list_func_die+0x45e>
					case DW_FORM_block1:
					case DW_FORM_block2:
					case DW_FORM_block4:
						offset = 0;
  8004201a97:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8004201a9e:	00 
						atom = *(loc_ptr++);
  8004201a9f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004201aa3:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004201aa7:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
  8004201aab:	0f b6 00             	movzbl (%rax),%eax
  8004201aae:	88 45 af             	mov    %al,-0x51(%rbp)
						offset++;
  8004201ab1:	48 83 45 c0 01       	addq   $0x1,-0x40(%rbp)
						if (atom == DW_OP_fbreg) {
  8004201ab6:	80 7d af 91          	cmpb   $0x91,-0x51(%rbp)
  8004201aba:	75 4a                	jne    8004201b06 <list_func_die+0x45d>
							uint8_t *p = loc_ptr;
  8004201abc:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004201ac0:	48 89 85 68 9e ff ff 	mov    %rax,-0x6198(%rbp)
							ret_offset = _dwarf_decode_sleb128(&p);
  8004201ac7:	48 8d 85 68 9e ff ff 	lea    -0x6198(%rbp),%rax
  8004201ace:	48 89 c7             	mov    %rax,%rdi
  8004201ad1:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004201ad8:	00 00 00 
  8004201adb:	ff d0                	callq  *%rax
  8004201add:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
							offset += p - loc_ptr;
  8004201ae1:	48 8b 85 68 9e ff ff 	mov    -0x6198(%rbp),%rax
  8004201ae8:	48 89 c2             	mov    %rax,%rdx
  8004201aeb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004201aef:	48 29 c2             	sub    %rax,%rdx
  8004201af2:	48 89 d0             	mov    %rdx,%rax
  8004201af5:	48 01 45 c0          	add    %rax,-0x40(%rbp)
							loc_ptr = p;
  8004201af9:	48 8b 85 68 9e ff ff 	mov    -0x6198(%rbp),%rax
  8004201b00:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
						}
						break;
  8004201b04:	eb 00                	jmp    8004201b06 <list_func_die+0x45d>
  8004201b06:	90                   	nop
				}
			}

			info->size_fn_arg[info->rip_fn_narg] = ret_val;
  8004201b07:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b0e:	8b 48 28             	mov    0x28(%rax),%ecx
  8004201b11:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201b15:	89 c2                	mov    %eax,%edx
  8004201b17:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b1e:	48 63 c9             	movslq %ecx,%rcx
  8004201b21:	48 83 c1 08          	add    $0x8,%rcx
  8004201b25:	89 54 88 0c          	mov    %edx,0xc(%rax,%rcx,4)
			info->offset_fn_arg[info->rip_fn_narg] = ret_offset;
  8004201b29:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b30:	8b 50 28             	mov    0x28(%rax),%edx
  8004201b33:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b3a:	48 63 d2             	movslq %edx,%rdx
  8004201b3d:	48 8d 4a 0a          	lea    0xa(%rdx),%rcx
  8004201b41:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004201b45:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
			info->rip_fn_narg++;
  8004201b4a:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b51:	8b 40 28             	mov    0x28(%rax),%eax
  8004201b54:	8d 50 01             	lea    0x1(%rax),%edx
  8004201b57:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201b5e:	89 50 28             	mov    %edx,0x28(%rax)
			sib = ret; 
  8004201b61:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004201b68:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  8004201b6f:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004201b74:	48 89 ce             	mov    %rcx,%rsi
  8004201b77:	48 89 c7             	mov    %rax,%rdi
  8004201b7a:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004201b81:	00 00 00 
  8004201b84:	ff d0                	callq  *%rax

			while(dwarf_siblingof(dbg, &sib, &ret, cu) == DW_DLV_OK)	
  8004201b86:	e9 40 02 00 00       	jmpq   8004201dcb <list_func_die+0x722>
			{
				if(ret.die_tag != DW_TAG_formal_parameter)
  8004201b8b:	48 8b 85 f8 ce ff ff 	mov    -0x3108(%rbp),%rax
  8004201b92:	48 83 f8 05          	cmp    $0x5,%rax
  8004201b96:	74 05                	je     8004201b9d <list_func_die+0x4f4>
					break;
  8004201b98:	e9 64 02 00 00       	jmpq   8004201e01 <list_func_die+0x758>

				attr = _dwarf_attr_find(&ret, DW_AT_type);
  8004201b9d:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004201ba4:	be 49 00 00 00       	mov    $0x49,%esi
  8004201ba9:	48 89 c7             	mov    %rax,%rdi
  8004201bac:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201bb3:	00 00 00 
  8004201bb6:	ff d0                	callq  *%rax
  8004201bb8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    
				if(attr != NULL)
  8004201bbc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201bc1:	0f 84 b1 00 00 00    	je     8004201c78 <list_func_die+0x5cf>
				{	   
					offset = (uint64_t)cu->cu_offset + attr->u[0].u64;
  8004201bc7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004201bcb:	48 8b 50 30          	mov    0x30(%rax),%rdx
  8004201bcf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201bd3:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004201bd7:	48 01 d0             	add    %rdx,%rax
  8004201bda:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
					dwarf_offdie(dbg, offset, &sib, *cu);
  8004201bde:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201be5:	00 00 00 
  8004201be8:	48 8b 08             	mov    (%rax),%rcx
  8004201beb:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  8004201bf2:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004201bf6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004201bfa:	48 8b 38             	mov    (%rax),%rdi
  8004201bfd:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004201c01:	48 8b 78 08          	mov    0x8(%rax),%rdi
  8004201c05:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  8004201c0a:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8004201c0e:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  8004201c13:	48 8b 78 18          	mov    0x18(%rax),%rdi
  8004201c17:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  8004201c1c:	48 8b 78 20          	mov    0x20(%rax),%rdi
  8004201c20:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  8004201c25:	48 8b 78 28          	mov    0x28(%rax),%rdi
  8004201c29:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  8004201c2e:	48 8b 40 30          	mov    0x30(%rax),%rax
  8004201c32:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  8004201c37:	48 89 cf             	mov    %rcx,%rdi
  8004201c3a:	48 b8 f6 4e 20 04 80 	movabs $0x8004204ef6,%rax
  8004201c41:	00 00 00 
  8004201c44:	ff d0                	callq  *%rax
					attr = _dwarf_attr_find(&sib, DW_AT_byte_size);
  8004201c46:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004201c4d:	be 0b 00 00 00       	mov    $0xb,%esi
  8004201c52:	48 89 c7             	mov    %rax,%rdi
  8004201c55:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201c5c:	00 00 00 
  8004201c5f:	ff d0                	callq  *%rax
  8004201c61:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
        
					if(attr != NULL)
  8004201c65:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201c6a:	74 0c                	je     8004201c78 <list_func_die+0x5cf>
					{
						ret_val = attr->u[0].u64;
  8004201c6c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201c70:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004201c74:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
					}
				}
	
				ret_offset = 0;
  8004201c78:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004201c7f:	00 
				attr = _dwarf_attr_find(&ret, DW_AT_location);
  8004201c80:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004201c87:	be 02 00 00 00       	mov    $0x2,%esi
  8004201c8c:	48 89 c7             	mov    %rax,%rdi
  8004201c8f:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  8004201c96:	00 00 00 
  8004201c99:	ff d0                	callq  *%rax
  8004201c9b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				if (attr != NULL)
  8004201c9f:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201ca4:	0f 84 a2 00 00 00    	je     8004201d4c <list_func_die+0x6a3>
				{
					Dwarf_Unsigned loc_len = attr->at_block.bl_len;
  8004201caa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201cae:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004201cb2:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
					Dwarf_Small *loc_ptr = attr->at_block.bl_data;
  8004201cb6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201cba:	48 8b 40 40          	mov    0x40(%rax),%rax
  8004201cbe:	48 89 45 98          	mov    %rax,-0x68(%rbp)
					Dwarf_Small atom;
					Dwarf_Unsigned op1, op2;

					switch(attr->at_form) {
  8004201cc2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201cc6:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004201cca:	48 83 f8 03          	cmp    $0x3,%rax
  8004201cce:	72 7c                	jb     8004201d4c <list_func_die+0x6a3>
  8004201cd0:	48 83 f8 04          	cmp    $0x4,%rax
  8004201cd4:	76 06                	jbe    8004201cdc <list_func_die+0x633>
  8004201cd6:	48 83 f8 0a          	cmp    $0xa,%rax
  8004201cda:	75 70                	jne    8004201d4c <list_func_die+0x6a3>
						case DW_FORM_block1:
						case DW_FORM_block2:
						case DW_FORM_block4:
							offset = 0;
  8004201cdc:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8004201ce3:	00 
							atom = *(loc_ptr++);
  8004201ce4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201ce8:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004201cec:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8004201cf0:	0f b6 00             	movzbl (%rax),%eax
  8004201cf3:	88 45 97             	mov    %al,-0x69(%rbp)
							offset++;
  8004201cf6:	48 83 45 c0 01       	addq   $0x1,-0x40(%rbp)
							if (atom == DW_OP_fbreg) {
  8004201cfb:	80 7d 97 91          	cmpb   $0x91,-0x69(%rbp)
  8004201cff:	75 4a                	jne    8004201d4b <list_func_die+0x6a2>
								uint8_t *p = loc_ptr;
  8004201d01:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201d05:	48 89 85 60 9e ff ff 	mov    %rax,-0x61a0(%rbp)
								ret_offset = _dwarf_decode_sleb128(&p);
  8004201d0c:	48 8d 85 60 9e ff ff 	lea    -0x61a0(%rbp),%rax
  8004201d13:	48 89 c7             	mov    %rax,%rdi
  8004201d16:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004201d1d:	00 00 00 
  8004201d20:	ff d0                	callq  *%rax
  8004201d22:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
								offset += p - loc_ptr;
  8004201d26:	48 8b 85 60 9e ff ff 	mov    -0x61a0(%rbp),%rax
  8004201d2d:	48 89 c2             	mov    %rax,%rdx
  8004201d30:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201d34:	48 29 c2             	sub    %rax,%rdx
  8004201d37:	48 89 d0             	mov    %rdx,%rax
  8004201d3a:	48 01 45 c0          	add    %rax,-0x40(%rbp)
								loc_ptr = p;
  8004201d3e:	48 8b 85 60 9e ff ff 	mov    -0x61a0(%rbp),%rax
  8004201d45:	48 89 45 98          	mov    %rax,-0x68(%rbp)
							}
							break;
  8004201d49:	eb 00                	jmp    8004201d4b <list_func_die+0x6a2>
  8004201d4b:	90                   	nop
					}
				}

				info->size_fn_arg[info->rip_fn_narg]=ret_val;// _get_arg_size(ret);
  8004201d4c:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201d53:	8b 48 28             	mov    0x28(%rax),%ecx
  8004201d56:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201d5a:	89 c2                	mov    %eax,%edx
  8004201d5c:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201d63:	48 63 c9             	movslq %ecx,%rcx
  8004201d66:	48 83 c1 08          	add    $0x8,%rcx
  8004201d6a:	89 54 88 0c          	mov    %edx,0xc(%rax,%rcx,4)
				info->offset_fn_arg[info->rip_fn_narg]=ret_offset;
  8004201d6e:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201d75:	8b 50 28             	mov    0x28(%rax),%edx
  8004201d78:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201d7f:	48 63 d2             	movslq %edx,%rdx
  8004201d82:	48 8d 4a 0a          	lea    0xa(%rdx),%rcx
  8004201d86:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004201d8a:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
				info->rip_fn_narg++;
  8004201d8f:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201d96:	8b 40 28             	mov    0x28(%rax),%eax
  8004201d99:	8d 50 01             	lea    0x1(%rax),%edx
  8004201d9c:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004201da3:	89 50 28             	mov    %edx,0x28(%rax)
				sib = ret; 
  8004201da6:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004201dad:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  8004201db4:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004201db9:	48 89 ce             	mov    %rcx,%rsi
  8004201dbc:	48 89 c7             	mov    %rax,%rdi
  8004201dbf:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004201dc6:	00 00 00 
  8004201dc9:	ff d0                	callq  *%rax
			info->size_fn_arg[info->rip_fn_narg] = ret_val;
			info->offset_fn_arg[info->rip_fn_narg] = ret_offset;
			info->rip_fn_narg++;
			sib = ret; 

			while(dwarf_siblingof(dbg, &sib, &ret, cu) == DW_DLV_OK)	
  8004201dcb:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201dd2:	00 00 00 
  8004201dd5:	48 8b 00             	mov    (%rax),%rax
  8004201dd8:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004201ddc:	48 8d 95 e0 ce ff ff 	lea    -0x3120(%rbp),%rdx
  8004201de3:	48 8d b5 70 9e ff ff 	lea    -0x6190(%rbp),%rsi
  8004201dea:	48 89 c7             	mov    %rax,%rdi
  8004201ded:	48 b8 8c 50 20 04 80 	movabs $0x800420508c,%rax
  8004201df4:	00 00 00 
  8004201df7:	ff d0                	callq  *%rax
  8004201df9:	85 c0                	test   %eax,%eax
  8004201dfb:	0f 84 8a fd ff ff    	je     8004201b8b <list_func_die+0x4e2>
				info->rip_fn_narg++;
				sib = ret; 
			}
		}
	last:	
		return 1;
  8004201e01:	b8 01 00 00 00       	mov    $0x1,%eax
  8004201e06:	eb 05                	jmp    8004201e0d <list_func_die+0x764>
	}

	return 0;
  8004201e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004201e0d:	c9                   	leaveq 
  8004201e0e:	c3                   	retq   

0000008004201e0f <debuginfo_rip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info)
{
  8004201e0f:	55                   	push   %rbp
  8004201e10:	48 89 e5             	mov    %rsp,%rbp
  8004201e13:	53                   	push   %rbx
  8004201e14:	48 81 ec c8 91 00 00 	sub    $0x91c8,%rsp
  8004201e1b:	48 89 bd 38 6e ff ff 	mov    %rdi,-0x91c8(%rbp)
  8004201e22:	48 89 b5 30 6e ff ff 	mov    %rsi,-0x91d0(%rbp)
	static struct Env* lastenv = NULL;
	void* elf;    
	Dwarf_Section *sect;
	Dwarf_CU cu;
	Dwarf_Die die, cudie, die2;
	Dwarf_Regtable *rt = NULL;
  8004201e29:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004201e30:	00 
	//Set up initial pc
	uint64_t pc  = (uintptr_t)addr;
  8004201e31:	48 8b 85 38 6e ff ff 	mov    -0x91c8(%rbp),%rax
  8004201e38:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

    
	// Initialize *info
	info->rip_file = "<unknown>";
  8004201e3c:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e43:	48 bb 4f 9b 20 04 80 	movabs $0x8004209b4f,%rbx
  8004201e4a:	00 00 00 
  8004201e4d:	48 89 18             	mov    %rbx,(%rax)
	info->rip_line = 0;
  8004201e50:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)
	info->rip_fn_name = "<unknown>";
  8004201e5e:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e65:	48 bb 4f 9b 20 04 80 	movabs $0x8004209b4f,%rbx
  8004201e6c:	00 00 00 
  8004201e6f:	48 89 58 10          	mov    %rbx,0x10(%rax)
	info->rip_fn_namelen = 9;
  8004201e73:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e7a:	c7 40 18 09 00 00 00 	movl   $0x9,0x18(%rax)
	info->rip_fn_addr = addr;
  8004201e81:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e88:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  8004201e8f:	48 89 50 20          	mov    %rdx,0x20(%rax)
	info->rip_fn_narg = 0;
  8004201e93:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004201e9a:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%rax)
    
	// Find the relevant set of stabs
	if (addr >= ULIM) {
  8004201ea1:	48 b8 ff ff bf 03 80 	movabs $0x8003bfffff,%rax
  8004201ea8:	00 00 00 
  8004201eab:	48 39 85 38 6e ff ff 	cmp    %rax,-0x91c8(%rbp)
  8004201eb2:	0f 86 95 00 00 00    	jbe    8004201f4d <debuginfo_rip+0x13e>
		elf = (void *)0x10000 + KERNBASE;
  8004201eb8:	48 b8 00 00 01 04 80 	movabs $0x8004010000,%rax
  8004201ebf:	00 00 00 
  8004201ec2:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	} else {
		// Can't search for user-level addresses yet!
		panic("User address");
	}
	_dwarf_init(dbg, elf);
  8004201ec6:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201ecd:	00 00 00 
  8004201ed0:	48 8b 00             	mov    (%rax),%rax
  8004201ed3:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004201ed7:	48 89 d6             	mov    %rdx,%rsi
  8004201eda:	48 89 c7             	mov    %rax,%rdi
  8004201edd:	48 b8 04 3f 20 04 80 	movabs $0x8004203f04,%rax
  8004201ee4:	00 00 00 
  8004201ee7:	ff d0                	callq  *%rax

	sect = _dwarf_find_section(".debug_info");	
  8004201ee9:	48 bf 66 9b 20 04 80 	movabs $0x8004209b66,%rdi
  8004201ef0:	00 00 00 
  8004201ef3:	48 b8 9b 87 20 04 80 	movabs $0x800420879b,%rax
  8004201efa:	00 00 00 
  8004201efd:	ff d0                	callq  *%rax
  8004201eff:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
  8004201f03:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201f0a:	00 00 00 
  8004201f0d:	48 8b 00             	mov    (%rax),%rax
  8004201f10:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004201f14:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004201f18:	48 89 50 08          	mov    %rdx,0x8(%rax)
	dbg->dbg_info_size = sect->ds_size;
  8004201f1c:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201f23:	00 00 00 
  8004201f26:	48 8b 00             	mov    (%rax),%rax
  8004201f29:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004201f2d:	48 8b 52 18          	mov    0x18(%rdx),%rdx
  8004201f31:	48 89 50 10          	mov    %rdx,0x10(%rax)

	assert(dbg->dbg_info_size);
  8004201f35:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201f3c:	00 00 00 
  8004201f3f:	48 8b 00             	mov    (%rax),%rax
  8004201f42:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004201f46:	48 85 c0             	test   %rax,%rax
  8004201f49:	75 61                	jne    8004201fac <debuginfo_rip+0x19d>
  8004201f4b:	eb 2a                	jmp    8004201f77 <debuginfo_rip+0x168>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		elf = (void *)0x10000 + KERNBASE;
	} else {
		// Can't search for user-level addresses yet!
		panic("User address");
  8004201f4d:	48 ba 59 9b 20 04 80 	movabs $0x8004209b59,%rdx
  8004201f54:	00 00 00 
  8004201f57:	be 23 01 00 00       	mov    $0x123,%esi
  8004201f5c:	48 bf 41 9b 20 04 80 	movabs $0x8004209b41,%rdi
  8004201f63:	00 00 00 
  8004201f66:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201f6b:	48 b9 98 01 20 04 80 	movabs $0x8004200198,%rcx
  8004201f72:	00 00 00 
  8004201f75:	ff d1                	callq  *%rcx

	sect = _dwarf_find_section(".debug_info");	
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
	dbg->dbg_info_size = sect->ds_size;

	assert(dbg->dbg_info_size);
  8004201f77:	48 b9 72 9b 20 04 80 	movabs $0x8004209b72,%rcx
  8004201f7e:	00 00 00 
  8004201f81:	48 ba 2c 9b 20 04 80 	movabs $0x8004209b2c,%rdx
  8004201f88:	00 00 00 
  8004201f8b:	be 2b 01 00 00       	mov    $0x12b,%esi
  8004201f90:	48 bf 41 9b 20 04 80 	movabs $0x8004209b41,%rdi
  8004201f97:	00 00 00 
  8004201f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201f9f:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004201fa6:	00 00 00 
  8004201fa9:	41 ff d0             	callq  *%r8
	while(_get_next_cu(dbg, &cu) == 0)
  8004201fac:	e9 6f 01 00 00       	jmpq   8004202120 <debuginfo_rip+0x311>
	{
		if(dwarf_siblingof(dbg, NULL, &cudie, &cu) == DW_DLE_NO_ENTRY)
  8004201fb1:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004201fb8:	00 00 00 
  8004201fbb:	48 8b 00             	mov    (%rax),%rax
  8004201fbe:	48 8d 4d 90          	lea    -0x70(%rbp),%rcx
  8004201fc2:	48 8d 95 b0 9e ff ff 	lea    -0x6150(%rbp),%rdx
  8004201fc9:	be 00 00 00 00       	mov    $0x0,%esi
  8004201fce:	48 89 c7             	mov    %rax,%rdi
  8004201fd1:	48 b8 8c 50 20 04 80 	movabs $0x800420508c,%rax
  8004201fd8:	00 00 00 
  8004201fdb:	ff d0                	callq  *%rax
  8004201fdd:	83 f8 04             	cmp    $0x4,%eax
  8004201fe0:	75 05                	jne    8004201fe7 <debuginfo_rip+0x1d8>
			continue;
  8004201fe2:	e9 39 01 00 00       	jmpq   8004202120 <debuginfo_rip+0x311>

		cudie.cu_header = &cu;
  8004201fe7:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004201feb:	48 89 85 10 a2 ff ff 	mov    %rax,-0x5df0(%rbp)
		cudie.cu_die = NULL;
  8004201ff2:	48 c7 85 18 a2 ff ff 	movq   $0x0,-0x5de8(%rbp)
  8004201ff9:	00 00 00 00 

		if(dwarf_child(dbg, &cu, &cudie, &die) == DW_DLE_NO_ENTRY)
  8004201ffd:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004202004:	00 00 00 
  8004202007:	48 8b 00             	mov    (%rax),%rax
  800420200a:	48 8d 8d 20 cf ff ff 	lea    -0x30e0(%rbp),%rcx
  8004202011:	48 8d 95 b0 9e ff ff 	lea    -0x6150(%rbp),%rdx
  8004202018:	48 8d 75 90          	lea    -0x70(%rbp),%rsi
  800420201c:	48 89 c7             	mov    %rax,%rdi
  800420201f:	48 b8 d0 52 20 04 80 	movabs $0x80042052d0,%rax
  8004202026:	00 00 00 
  8004202029:	ff d0                	callq  *%rax
  800420202b:	83 f8 04             	cmp    $0x4,%eax
  800420202e:	75 05                	jne    8004202035 <debuginfo_rip+0x226>
			continue;
  8004202030:	e9 eb 00 00 00       	jmpq   8004202120 <debuginfo_rip+0x311>

		die.cu_header = &cu;
  8004202035:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004202039:	48 89 85 80 d2 ff ff 	mov    %rax,-0x2d80(%rbp)
		die.cu_die = &cudie;
  8004202040:	48 8d 85 b0 9e ff ff 	lea    -0x6150(%rbp),%rax
  8004202047:	48 89 85 88 d2 ff ff 	mov    %rax,-0x2d78(%rbp)
		while(1)
		{
			if(list_func_die(info, &die, addr))
  800420204e:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  8004202055:	48 8d 8d 20 cf ff ff 	lea    -0x30e0(%rbp),%rcx
  800420205c:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004202063:	48 89 ce             	mov    %rcx,%rsi
  8004202066:	48 89 c7             	mov    %rax,%rdi
  8004202069:	48 b8 a9 16 20 04 80 	movabs $0x80042016a9,%rax
  8004202070:	00 00 00 
  8004202073:	ff d0                	callq  *%rax
  8004202075:	85 c0                	test   %eax,%eax
  8004202077:	74 30                	je     80042020a9 <debuginfo_rip+0x29a>
				goto find_done;
  8004202079:	90                   	nop

	return -1;

find_done:

	if (dwarf_init_eh_section(dbg, NULL) == DW_DLV_ERROR)
  800420207a:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004202081:	00 00 00 
  8004202084:	48 8b 00             	mov    (%rax),%rax
  8004202087:	be 00 00 00 00       	mov    $0x0,%esi
  800420208c:	48 89 c7             	mov    %rax,%rdi
  800420208f:	48 b8 a8 79 20 04 80 	movabs $0x80042079a8,%rax
  8004202096:	00 00 00 
  8004202099:	ff d0                	callq  *%rax
  800420209b:	83 f8 01             	cmp    $0x1,%eax
  800420209e:	0f 85 bb 00 00 00    	jne    800420215f <debuginfo_rip+0x350>
  80042020a4:	e9 ac 00 00 00       	jmpq   8004202155 <debuginfo_rip+0x346>
		die.cu_die = &cudie;
		while(1)
		{
			if(list_func_die(info, &die, addr))
				goto find_done;
			if(dwarf_siblingof(dbg, &die, &die2, &cu) < 0)
  80042020a9:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042020b0:	00 00 00 
  80042020b3:	48 8b 00             	mov    (%rax),%rax
  80042020b6:	48 8d 4d 90          	lea    -0x70(%rbp),%rcx
  80042020ba:	48 8d 95 40 6e ff ff 	lea    -0x91c0(%rbp),%rdx
  80042020c1:	48 8d b5 20 cf ff ff 	lea    -0x30e0(%rbp),%rsi
  80042020c8:	48 89 c7             	mov    %rax,%rdi
  80042020cb:	48 b8 8c 50 20 04 80 	movabs $0x800420508c,%rax
  80042020d2:	00 00 00 
  80042020d5:	ff d0                	callq  *%rax
  80042020d7:	85 c0                	test   %eax,%eax
  80042020d9:	79 02                	jns    80042020dd <debuginfo_rip+0x2ce>
				break; 
  80042020db:	eb 43                	jmp    8004202120 <debuginfo_rip+0x311>
			die = die2;
  80042020dd:	48 8d 85 20 cf ff ff 	lea    -0x30e0(%rbp),%rax
  80042020e4:	48 8d 8d 40 6e ff ff 	lea    -0x91c0(%rbp),%rcx
  80042020eb:	ba 70 30 00 00       	mov    $0x3070,%edx
  80042020f0:	48 89 ce             	mov    %rcx,%rsi
  80042020f3:	48 89 c7             	mov    %rax,%rdi
  80042020f6:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  80042020fd:	00 00 00 
  8004202100:	ff d0                	callq  *%rax
			die.cu_header = &cu;
  8004202102:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004202106:	48 89 85 80 d2 ff ff 	mov    %rax,-0x2d80(%rbp)
			die.cu_die = &cudie;
  800420210d:	48 8d 85 b0 9e ff ff 	lea    -0x6150(%rbp),%rax
  8004202114:	48 89 85 88 d2 ff ff 	mov    %rax,-0x2d78(%rbp)
		}
  800420211b:	e9 2e ff ff ff       	jmpq   800420204e <debuginfo_rip+0x23f>
	sect = _dwarf_find_section(".debug_info");	
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
	dbg->dbg_info_size = sect->ds_size;

	assert(dbg->dbg_info_size);
	while(_get_next_cu(dbg, &cu) == 0)
  8004202120:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004202127:	00 00 00 
  800420212a:	48 8b 00             	mov    (%rax),%rax
  800420212d:	48 8d 55 90          	lea    -0x70(%rbp),%rdx
  8004202131:	48 89 d6             	mov    %rdx,%rsi
  8004202134:	48 89 c7             	mov    %rax,%rdi
  8004202137:	48 b8 e6 3f 20 04 80 	movabs $0x8004203fe6,%rax
  800420213e:	00 00 00 
  8004202141:	ff d0                	callq  *%rax
  8004202143:	85 c0                	test   %eax,%eax
  8004202145:	0f 84 66 fe ff ff    	je     8004201fb1 <debuginfo_rip+0x1a2>
			die.cu_header = &cu;
			die.cu_die = &cudie;
		}
	}

	return -1;
  800420214b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004202150:	e9 a0 00 00 00       	jmpq   80042021f5 <debuginfo_rip+0x3e6>

find_done:

	if (dwarf_init_eh_section(dbg, NULL) == DW_DLV_ERROR)
		return -1;
  8004202155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420215a:	e9 96 00 00 00       	jmpq   80042021f5 <debuginfo_rip+0x3e6>

	if (dwarf_get_fde_at_pc(dbg, addr, fde, cie, NULL) == DW_DLV_OK) {
  800420215f:	48 b8 d0 c5 21 04 80 	movabs $0x800421c5d0,%rax
  8004202166:	00 00 00 
  8004202169:	48 8b 08             	mov    (%rax),%rcx
  800420216c:	48 b8 c8 c5 21 04 80 	movabs $0x800421c5c8,%rax
  8004202173:	00 00 00 
  8004202176:	48 8b 10             	mov    (%rax),%rdx
  8004202179:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004202180:	00 00 00 
  8004202183:	48 8b 00             	mov    (%rax),%rax
  8004202186:	48 8b b5 38 6e ff ff 	mov    -0x91c8(%rbp),%rsi
  800420218d:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  8004202193:	48 89 c7             	mov    %rax,%rdi
  8004202196:	48 b8 11 55 20 04 80 	movabs $0x8004205511,%rax
  800420219d:	00 00 00 
  80042021a0:	ff d0                	callq  *%rax
  80042021a2:	85 c0                	test   %eax,%eax
  80042021a4:	75 4a                	jne    80042021f0 <debuginfo_rip+0x3e1>
		dwarf_get_fde_info_for_all_regs(dbg, fde, addr,
  80042021a6:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  80042021ad:	48 8d 88 a8 00 00 00 	lea    0xa8(%rax),%rcx
  80042021b4:	48 b8 c8 c5 21 04 80 	movabs $0x800421c5c8,%rax
  80042021bb:	00 00 00 
  80042021be:	48 8b 30             	mov    (%rax),%rsi
  80042021c1:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042021c8:	00 00 00 
  80042021cb:	48 8b 00             	mov    (%rax),%rax
  80042021ce:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  80042021d5:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80042021db:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80042021e1:	48 89 c7             	mov    %rax,%rdi
  80042021e4:	48 b8 1d 68 20 04 80 	movabs $0x800420681d,%rax
  80042021eb:	00 00 00 
  80042021ee:	ff d0                	callq  *%rax
					break;
			}
		}
#endif
	}
	return 0;
  80042021f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042021f5:	48 81 c4 c8 91 00 00 	add    $0x91c8,%rsp
  80042021fc:	5b                   	pop    %rbx
  80042021fd:	5d                   	pop    %rbp
  80042021fe:	c3                   	retq   

00000080042021ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042021ff:	55                   	push   %rbp
  8004202200:	48 89 e5             	mov    %rsp,%rbp
  8004202203:	53                   	push   %rbx
  8004202204:	48 83 ec 38          	sub    $0x38,%rsp
  8004202208:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420220c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202210:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004202214:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  8004202217:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  800420221b:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800420221f:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  8004202222:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8004202226:	77 3b                	ja     8004202263 <printnum+0x64>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004202228:	8b 45 d0             	mov    -0x30(%rbp),%eax
  800420222b:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  800420222f:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  8004202232:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202236:	ba 00 00 00 00       	mov    $0x0,%edx
  800420223b:	48 f7 f3             	div    %rbx
  800420223e:	48 89 c2             	mov    %rax,%rdx
  8004202241:	8b 7d cc             	mov    -0x34(%rbp),%edi
  8004202244:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8004202247:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  800420224b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420224f:	41 89 f9             	mov    %edi,%r9d
  8004202252:	48 89 c7             	mov    %rax,%rdi
  8004202255:	48 b8 ff 21 20 04 80 	movabs $0x80042021ff,%rax
  800420225c:	00 00 00 
  800420225f:	ff d0                	callq  *%rax
  8004202261:	eb 1e                	jmp    8004202281 <printnum+0x82>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004202263:	eb 12                	jmp    8004202277 <printnum+0x78>
			putch(padc, putdat);
  8004202265:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004202269:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420226c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202270:	48 89 ce             	mov    %rcx,%rsi
  8004202273:	89 d7                	mov    %edx,%edi
  8004202275:	ff d0                	callq  *%rax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004202277:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  800420227b:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  800420227f:	7f e4                	jg     8004202265 <printnum+0x66>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004202281:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8004202284:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202288:	ba 00 00 00 00       	mov    $0x0,%edx
  800420228d:	48 f7 f1             	div    %rcx
  8004202290:	48 89 d0             	mov    %rdx,%rax
  8004202293:	48 ba d0 9c 20 04 80 	movabs $0x8004209cd0,%rdx
  800420229a:	00 00 00 
  800420229d:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  80042022a1:	0f be d0             	movsbl %al,%edx
  80042022a4:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  80042022a8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042022ac:	48 89 ce             	mov    %rcx,%rsi
  80042022af:	89 d7                	mov    %edx,%edi
  80042022b1:	ff d0                	callq  *%rax
}
  80042022b3:	48 83 c4 38          	add    $0x38,%rsp
  80042022b7:	5b                   	pop    %rbx
  80042022b8:	5d                   	pop    %rbp
  80042022b9:	c3                   	retq   

00000080042022ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042022ba:	55                   	push   %rbp
  80042022bb:	48 89 e5             	mov    %rsp,%rbp
  80042022be:	48 83 ec 1c          	sub    $0x1c,%rsp
  80042022c2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042022c6:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	unsigned long long x;    
	if (lflag >= 2)
  80042022c9:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  80042022cd:	7e 52                	jle    8004202321 <getuint+0x67>
		x= va_arg(*ap, unsigned long long);
  80042022cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042022d3:	8b 00                	mov    (%rax),%eax
  80042022d5:	83 f8 30             	cmp    $0x30,%eax
  80042022d8:	73 24                	jae    80042022fe <getuint+0x44>
  80042022da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042022de:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042022e2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042022e6:	8b 00                	mov    (%rax),%eax
  80042022e8:	89 c0                	mov    %eax,%eax
  80042022ea:	48 01 d0             	add    %rdx,%rax
  80042022ed:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042022f1:	8b 12                	mov    (%rdx),%edx
  80042022f3:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80042022f6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042022fa:	89 0a                	mov    %ecx,(%rdx)
  80042022fc:	eb 17                	jmp    8004202315 <getuint+0x5b>
  80042022fe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202302:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004202306:	48 89 d0             	mov    %rdx,%rax
  8004202309:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420230d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202311:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004202315:	48 8b 00             	mov    (%rax),%rax
  8004202318:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420231c:	e9 a3 00 00 00       	jmpq   80042023c4 <getuint+0x10a>
	else if (lflag)
  8004202321:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004202325:	74 4f                	je     8004202376 <getuint+0xbc>
		x= va_arg(*ap, unsigned long);
  8004202327:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420232b:	8b 00                	mov    (%rax),%eax
  800420232d:	83 f8 30             	cmp    $0x30,%eax
  8004202330:	73 24                	jae    8004202356 <getuint+0x9c>
  8004202332:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202336:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420233a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420233e:	8b 00                	mov    (%rax),%eax
  8004202340:	89 c0                	mov    %eax,%eax
  8004202342:	48 01 d0             	add    %rdx,%rax
  8004202345:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202349:	8b 12                	mov    (%rdx),%edx
  800420234b:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800420234e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202352:	89 0a                	mov    %ecx,(%rdx)
  8004202354:	eb 17                	jmp    800420236d <getuint+0xb3>
  8004202356:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420235a:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420235e:	48 89 d0             	mov    %rdx,%rax
  8004202361:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  8004202365:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202369:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800420236d:	48 8b 00             	mov    (%rax),%rax
  8004202370:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004202374:	eb 4e                	jmp    80042023c4 <getuint+0x10a>
	else
		x= va_arg(*ap, unsigned int);
  8004202376:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420237a:	8b 00                	mov    (%rax),%eax
  800420237c:	83 f8 30             	cmp    $0x30,%eax
  800420237f:	73 24                	jae    80042023a5 <getuint+0xeb>
  8004202381:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202385:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004202389:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420238d:	8b 00                	mov    (%rax),%eax
  800420238f:	89 c0                	mov    %eax,%eax
  8004202391:	48 01 d0             	add    %rdx,%rax
  8004202394:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202398:	8b 12                	mov    (%rdx),%edx
  800420239a:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800420239d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042023a1:	89 0a                	mov    %ecx,(%rdx)
  80042023a3:	eb 17                	jmp    80042023bc <getuint+0x102>
  80042023a5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042023a9:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042023ad:	48 89 d0             	mov    %rdx,%rax
  80042023b0:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  80042023b4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042023b8:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80042023bc:	8b 00                	mov    (%rax),%eax
  80042023be:	89 c0                	mov    %eax,%eax
  80042023c0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  80042023c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  80042023c8:	c9                   	leaveq 
  80042023c9:	c3                   	retq   

00000080042023ca <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80042023ca:	55                   	push   %rbp
  80042023cb:	48 89 e5             	mov    %rsp,%rbp
  80042023ce:	48 83 ec 1c          	sub    $0x1c,%rsp
  80042023d2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042023d6:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	long long x;
	if (lflag >= 2)
  80042023d9:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  80042023dd:	7e 52                	jle    8004202431 <getint+0x67>
		x=va_arg(*ap, long long);
  80042023df:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042023e3:	8b 00                	mov    (%rax),%eax
  80042023e5:	83 f8 30             	cmp    $0x30,%eax
  80042023e8:	73 24                	jae    800420240e <getint+0x44>
  80042023ea:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042023ee:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042023f2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042023f6:	8b 00                	mov    (%rax),%eax
  80042023f8:	89 c0                	mov    %eax,%eax
  80042023fa:	48 01 d0             	add    %rdx,%rax
  80042023fd:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202401:	8b 12                	mov    (%rdx),%edx
  8004202403:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8004202406:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420240a:	89 0a                	mov    %ecx,(%rdx)
  800420240c:	eb 17                	jmp    8004202425 <getint+0x5b>
  800420240e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202412:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004202416:	48 89 d0             	mov    %rdx,%rax
  8004202419:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420241d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202421:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004202425:	48 8b 00             	mov    (%rax),%rax
  8004202428:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420242c:	e9 a3 00 00 00       	jmpq   80042024d4 <getint+0x10a>
	else if (lflag)
  8004202431:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004202435:	74 4f                	je     8004202486 <getint+0xbc>
		x=va_arg(*ap, long);
  8004202437:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420243b:	8b 00                	mov    (%rax),%eax
  800420243d:	83 f8 30             	cmp    $0x30,%eax
  8004202440:	73 24                	jae    8004202466 <getint+0x9c>
  8004202442:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202446:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420244a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420244e:	8b 00                	mov    (%rax),%eax
  8004202450:	89 c0                	mov    %eax,%eax
  8004202452:	48 01 d0             	add    %rdx,%rax
  8004202455:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202459:	8b 12                	mov    (%rdx),%edx
  800420245b:	8d 4a 08             	lea    0x8(%rdx),%ecx
  800420245e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202462:	89 0a                	mov    %ecx,(%rdx)
  8004202464:	eb 17                	jmp    800420247d <getint+0xb3>
  8004202466:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420246a:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420246e:	48 89 d0             	mov    %rdx,%rax
  8004202471:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  8004202475:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202479:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  800420247d:	48 8b 00             	mov    (%rax),%rax
  8004202480:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004202484:	eb 4e                	jmp    80042024d4 <getint+0x10a>
	else
		x=va_arg(*ap, int);
  8004202486:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420248a:	8b 00                	mov    (%rax),%eax
  800420248c:	83 f8 30             	cmp    $0x30,%eax
  800420248f:	73 24                	jae    80042024b5 <getint+0xeb>
  8004202491:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202495:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004202499:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420249d:	8b 00                	mov    (%rax),%eax
  800420249f:	89 c0                	mov    %eax,%eax
  80042024a1:	48 01 d0             	add    %rdx,%rax
  80042024a4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042024a8:	8b 12                	mov    (%rdx),%edx
  80042024aa:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80042024ad:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042024b1:	89 0a                	mov    %ecx,(%rdx)
  80042024b3:	eb 17                	jmp    80042024cc <getint+0x102>
  80042024b5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042024b9:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042024bd:	48 89 d0             	mov    %rdx,%rax
  80042024c0:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  80042024c4:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042024c8:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80042024cc:	8b 00                	mov    (%rax),%eax
  80042024ce:	48 98                	cltq   
  80042024d0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  80042024d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  80042024d8:	c9                   	leaveq 
  80042024d9:	c3                   	retq   

00000080042024da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042024da:	55                   	push   %rbp
  80042024db:	48 89 e5             	mov    %rsp,%rbp
  80042024de:	41 54                	push   %r12
  80042024e0:	53                   	push   %rbx
  80042024e1:	48 83 ec 60          	sub    $0x60,%rsp
  80042024e5:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80042024e9:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  80042024ed:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  80042024f1:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
  80042024f5:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80042024f9:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  80042024fd:	48 8b 0a             	mov    (%rdx),%rcx
  8004202500:	48 89 08             	mov    %rcx,(%rax)
  8004202503:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004202507:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800420250b:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  800420250f:	48 89 50 10          	mov    %rdx,0x10(%rax)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004202513:	eb 17                	jmp    800420252c <vprintfmt+0x52>
			if (ch == '\0')
  8004202515:	85 db                	test   %ebx,%ebx
  8004202517:	0f 84 cc 04 00 00    	je     80042029e9 <vprintfmt+0x50f>
				return;
			putch(ch, putdat);
  800420251d:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004202521:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004202525:	48 89 d6             	mov    %rdx,%rsi
  8004202528:	89 df                	mov    %ebx,%edi
  800420252a:	ff d0                	callq  *%rax
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800420252c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004202530:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004202534:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8004202538:	0f b6 00             	movzbl (%rax),%eax
  800420253b:	0f b6 d8             	movzbl %al,%ebx
  800420253e:	83 fb 25             	cmp    $0x25,%ebx
  8004202541:	75 d2                	jne    8004202515 <vprintfmt+0x3b>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004202543:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
		width = -1;
  8004202547:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
		precision = -1;
  800420254e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
		lflag = 0;
  8004202555:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
		altflag = 0;
  800420255c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004202563:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004202567:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420256b:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  800420256f:	0f b6 00             	movzbl (%rax),%eax
  8004202572:	0f b6 d8             	movzbl %al,%ebx
  8004202575:	8d 43 dd             	lea    -0x23(%rbx),%eax
  8004202578:	83 f8 55             	cmp    $0x55,%eax
  800420257b:	0f 87 34 04 00 00    	ja     80042029b5 <vprintfmt+0x4db>
  8004202581:	89 c0                	mov    %eax,%eax
  8004202583:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420258a:	00 
  800420258b:	48 b8 f8 9c 20 04 80 	movabs $0x8004209cf8,%rax
  8004202592:	00 00 00 
  8004202595:	48 01 d0             	add    %rdx,%rax
  8004202598:	48 8b 00             	mov    (%rax),%rax
  800420259b:	ff e0                	jmpq   *%rax

			// flag to pad on the right
		case '-':
			padc = '-';
  800420259d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
			goto reswitch;
  80042025a1:	eb c0                	jmp    8004202563 <vprintfmt+0x89>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042025a3:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
			goto reswitch;
  80042025a7:	eb ba                	jmp    8004202563 <vprintfmt+0x89>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042025a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
				precision = precision * 10 + ch - '0';
  80042025b0:	8b 55 d8             	mov    -0x28(%rbp),%edx
  80042025b3:	89 d0                	mov    %edx,%eax
  80042025b5:	c1 e0 02             	shl    $0x2,%eax
  80042025b8:	01 d0                	add    %edx,%eax
  80042025ba:	01 c0                	add    %eax,%eax
  80042025bc:	01 d8                	add    %ebx,%eax
  80042025be:	83 e8 30             	sub    $0x30,%eax
  80042025c1:	89 45 d8             	mov    %eax,-0x28(%rbp)
				ch = *fmt;
  80042025c4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042025c8:	0f b6 00             	movzbl (%rax),%eax
  80042025cb:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80042025ce:	83 fb 2f             	cmp    $0x2f,%ebx
  80042025d1:	7e 0c                	jle    80042025df <vprintfmt+0x105>
  80042025d3:	83 fb 39             	cmp    $0x39,%ebx
  80042025d6:	7f 07                	jg     80042025df <vprintfmt+0x105>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042025d8:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042025dd:	eb d1                	jmp    80042025b0 <vprintfmt+0xd6>
			goto process_precision;
  80042025df:	eb 58                	jmp    8004202639 <vprintfmt+0x15f>

		case '*':
			precision = va_arg(aq, int);
  80042025e1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042025e4:	83 f8 30             	cmp    $0x30,%eax
  80042025e7:	73 17                	jae    8004202600 <vprintfmt+0x126>
  80042025e9:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042025ed:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042025f0:	89 c0                	mov    %eax,%eax
  80042025f2:	48 01 d0             	add    %rdx,%rax
  80042025f5:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80042025f8:	83 c2 08             	add    $0x8,%edx
  80042025fb:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80042025fe:	eb 0f                	jmp    800420260f <vprintfmt+0x135>
  8004202600:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004202604:	48 89 d0             	mov    %rdx,%rax
  8004202607:	48 83 c2 08          	add    $0x8,%rdx
  800420260b:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800420260f:	8b 00                	mov    (%rax),%eax
  8004202611:	89 45 d8             	mov    %eax,-0x28(%rbp)
			goto process_precision;
  8004202614:	eb 23                	jmp    8004202639 <vprintfmt+0x15f>

		case '.':
			if (width < 0)
  8004202616:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420261a:	79 0c                	jns    8004202628 <vprintfmt+0x14e>
				width = 0;
  800420261c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
			goto reswitch;
  8004202623:	e9 3b ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>
  8004202628:	e9 36 ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>

		case '#':
			altflag = 1;
  800420262d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
			goto reswitch;
  8004202634:	e9 2a ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>

		process_precision:
			if (width < 0)
  8004202639:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420263d:	79 12                	jns    8004202651 <vprintfmt+0x177>
				width = precision, precision = -1;
  800420263f:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8004202642:	89 45 dc             	mov    %eax,-0x24(%rbp)
  8004202645:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
			goto reswitch;
  800420264c:	e9 12 ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>
  8004202651:	e9 0d ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004202656:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
			goto reswitch;
  800420265a:	e9 04 ff ff ff       	jmpq   8004202563 <vprintfmt+0x89>

			// character
		case 'c':
			putch(va_arg(aq, int), putdat);
  800420265f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004202662:	83 f8 30             	cmp    $0x30,%eax
  8004202665:	73 17                	jae    800420267e <vprintfmt+0x1a4>
  8004202667:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420266b:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800420266e:	89 c0                	mov    %eax,%eax
  8004202670:	48 01 d0             	add    %rdx,%rax
  8004202673:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8004202676:	83 c2 08             	add    $0x8,%edx
  8004202679:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800420267c:	eb 0f                	jmp    800420268d <vprintfmt+0x1b3>
  800420267e:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004202682:	48 89 d0             	mov    %rdx,%rax
  8004202685:	48 83 c2 08          	add    $0x8,%rdx
  8004202689:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800420268d:	8b 10                	mov    (%rax),%edx
  800420268f:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8004202693:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004202697:	48 89 ce             	mov    %rcx,%rsi
  800420269a:	89 d7                	mov    %edx,%edi
  800420269c:	ff d0                	callq  *%rax
			break;
  800420269e:	e9 40 03 00 00       	jmpq   80042029e3 <vprintfmt+0x509>

			// error message
		case 'e':
			err = va_arg(aq, int);
  80042026a3:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042026a6:	83 f8 30             	cmp    $0x30,%eax
  80042026a9:	73 17                	jae    80042026c2 <vprintfmt+0x1e8>
  80042026ab:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042026af:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042026b2:	89 c0                	mov    %eax,%eax
  80042026b4:	48 01 d0             	add    %rdx,%rax
  80042026b7:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80042026ba:	83 c2 08             	add    $0x8,%edx
  80042026bd:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80042026c0:	eb 0f                	jmp    80042026d1 <vprintfmt+0x1f7>
  80042026c2:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80042026c6:	48 89 d0             	mov    %rdx,%rax
  80042026c9:	48 83 c2 08          	add    $0x8,%rdx
  80042026cd:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  80042026d1:	8b 18                	mov    (%rax),%ebx
			if (err < 0)
  80042026d3:	85 db                	test   %ebx,%ebx
  80042026d5:	79 02                	jns    80042026d9 <vprintfmt+0x1ff>
				err = -err;
  80042026d7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042026d9:	83 fb 15             	cmp    $0x15,%ebx
  80042026dc:	7f 16                	jg     80042026f4 <vprintfmt+0x21a>
  80042026de:	48 b8 20 9c 20 04 80 	movabs $0x8004209c20,%rax
  80042026e5:	00 00 00 
  80042026e8:	48 63 d3             	movslq %ebx,%rdx
  80042026eb:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  80042026ef:	4d 85 e4             	test   %r12,%r12
  80042026f2:	75 2e                	jne    8004202722 <vprintfmt+0x248>
				printfmt(putch, putdat, "error %d", err);
  80042026f4:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  80042026f8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042026fc:	89 d9                	mov    %ebx,%ecx
  80042026fe:	48 ba e1 9c 20 04 80 	movabs $0x8004209ce1,%rdx
  8004202705:	00 00 00 
  8004202708:	48 89 c7             	mov    %rax,%rdi
  800420270b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202710:	49 b8 f2 29 20 04 80 	movabs $0x80042029f2,%r8
  8004202717:	00 00 00 
  800420271a:	41 ff d0             	callq  *%r8
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800420271d:	e9 c1 02 00 00       	jmpq   80042029e3 <vprintfmt+0x509>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004202722:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8004202726:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420272a:	4c 89 e1             	mov    %r12,%rcx
  800420272d:	48 ba ea 9c 20 04 80 	movabs $0x8004209cea,%rdx
  8004202734:	00 00 00 
  8004202737:	48 89 c7             	mov    %rax,%rdi
  800420273a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420273f:	49 b8 f2 29 20 04 80 	movabs $0x80042029f2,%r8
  8004202746:	00 00 00 
  8004202749:	41 ff d0             	callq  *%r8
			break;
  800420274c:	e9 92 02 00 00       	jmpq   80042029e3 <vprintfmt+0x509>

			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
  8004202751:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004202754:	83 f8 30             	cmp    $0x30,%eax
  8004202757:	73 17                	jae    8004202770 <vprintfmt+0x296>
  8004202759:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420275d:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004202760:	89 c0                	mov    %eax,%eax
  8004202762:	48 01 d0             	add    %rdx,%rax
  8004202765:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8004202768:	83 c2 08             	add    $0x8,%edx
  800420276b:	89 55 b8             	mov    %edx,-0x48(%rbp)
  800420276e:	eb 0f                	jmp    800420277f <vprintfmt+0x2a5>
  8004202770:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004202774:	48 89 d0             	mov    %rdx,%rax
  8004202777:	48 83 c2 08          	add    $0x8,%rdx
  800420277b:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800420277f:	4c 8b 20             	mov    (%rax),%r12
  8004202782:	4d 85 e4             	test   %r12,%r12
  8004202785:	75 0a                	jne    8004202791 <vprintfmt+0x2b7>
				p = "(null)";
  8004202787:	49 bc ed 9c 20 04 80 	movabs $0x8004209ced,%r12
  800420278e:	00 00 00 
			if (width > 0 && padc != '-')
  8004202791:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8004202795:	7e 3f                	jle    80042027d6 <vprintfmt+0x2fc>
  8004202797:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  800420279b:	74 39                	je     80042027d6 <vprintfmt+0x2fc>
				for (width -= strnlen(p, precision); width > 0; width--)
  800420279d:	8b 45 d8             	mov    -0x28(%rbp),%eax
  80042027a0:	48 98                	cltq   
  80042027a2:	48 89 c6             	mov    %rax,%rsi
  80042027a5:	4c 89 e7             	mov    %r12,%rdi
  80042027a8:	48 b8 ed 2d 20 04 80 	movabs $0x8004202ded,%rax
  80042027af:	00 00 00 
  80042027b2:	ff d0                	callq  *%rax
  80042027b4:	29 45 dc             	sub    %eax,-0x24(%rbp)
  80042027b7:	eb 17                	jmp    80042027d0 <vprintfmt+0x2f6>
					putch(padc, putdat);
  80042027b9:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  80042027bd:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80042027c1:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042027c5:	48 89 ce             	mov    %rcx,%rsi
  80042027c8:	89 d7                	mov    %edx,%edi
  80042027ca:	ff d0                	callq  *%rax
			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042027cc:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  80042027d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  80042027d4:	7f e3                	jg     80042027b9 <vprintfmt+0x2df>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042027d6:	eb 37                	jmp    800420280f <vprintfmt+0x335>
				if (altflag && (ch < ' ' || ch > '~'))
  80042027d8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  80042027dc:	74 1e                	je     80042027fc <vprintfmt+0x322>
  80042027de:	83 fb 1f             	cmp    $0x1f,%ebx
  80042027e1:	7e 05                	jle    80042027e8 <vprintfmt+0x30e>
  80042027e3:	83 fb 7e             	cmp    $0x7e,%ebx
  80042027e6:	7e 14                	jle    80042027fc <vprintfmt+0x322>
					putch('?', putdat);
  80042027e8:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042027ec:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042027f0:	48 89 d6             	mov    %rdx,%rsi
  80042027f3:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80042027f8:	ff d0                	callq  *%rax
  80042027fa:	eb 0f                	jmp    800420280b <vprintfmt+0x331>
				else
					putch(ch, putdat);
  80042027fc:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004202800:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004202804:	48 89 d6             	mov    %rdx,%rsi
  8004202807:	89 df                	mov    %ebx,%edi
  8004202809:	ff d0                	callq  *%rax
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800420280b:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  800420280f:	4c 89 e0             	mov    %r12,%rax
  8004202812:	4c 8d 60 01          	lea    0x1(%rax),%r12
  8004202816:	0f b6 00             	movzbl (%rax),%eax
  8004202819:	0f be d8             	movsbl %al,%ebx
  800420281c:	85 db                	test   %ebx,%ebx
  800420281e:	74 10                	je     8004202830 <vprintfmt+0x356>
  8004202820:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  8004202824:	78 b2                	js     80042027d8 <vprintfmt+0x2fe>
  8004202826:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  800420282a:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  800420282e:	79 a8                	jns    80042027d8 <vprintfmt+0x2fe>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004202830:	eb 16                	jmp    8004202848 <vprintfmt+0x36e>
				putch(' ', putdat);
  8004202832:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004202836:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420283a:	48 89 d6             	mov    %rdx,%rsi
  800420283d:	bf 20 00 00 00       	mov    $0x20,%edi
  8004202842:	ff d0                	callq  *%rax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004202844:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  8004202848:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420284c:	7f e4                	jg     8004202832 <vprintfmt+0x358>
				putch(' ', putdat);
			break;
  800420284e:	e9 90 01 00 00       	jmpq   80042029e3 <vprintfmt+0x509>

			// (signed) decimal
		case 'd':
			num = getint(&aq, 3);
  8004202853:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8004202857:	be 03 00 00 00       	mov    $0x3,%esi
  800420285c:	48 89 c7             	mov    %rax,%rdi
  800420285f:	48 b8 ca 23 20 04 80 	movabs $0x80042023ca,%rax
  8004202866:	00 00 00 
  8004202869:	ff d0                	callq  *%rax
  800420286b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			if ((long long) num < 0) {
  800420286f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202873:	48 85 c0             	test   %rax,%rax
  8004202876:	79 1d                	jns    8004202895 <vprintfmt+0x3bb>
				putch('-', putdat);
  8004202878:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800420287c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004202880:	48 89 d6             	mov    %rdx,%rsi
  8004202883:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8004202888:	ff d0                	callq  *%rax
				num = -(long long) num;
  800420288a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420288e:	48 f7 d8             	neg    %rax
  8004202891:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			}
			base = 10;
  8004202895:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  800420289c:	e9 d5 00 00 00       	jmpq   8004202976 <vprintfmt+0x49c>

			// unsigned decimal
		case 'u':
			num = getuint(&aq, 3);
  80042028a1:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80042028a5:	be 03 00 00 00       	mov    $0x3,%esi
  80042028aa:	48 89 c7             	mov    %rax,%rdi
  80042028ad:	48 b8 ba 22 20 04 80 	movabs $0x80042022ba,%rax
  80042028b4:	00 00 00 
  80042028b7:	ff d0                	callq  *%rax
  80042028b9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 10;
  80042028bd:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  80042028c4:	e9 ad 00 00 00       	jmpq   8004202976 <vprintfmt+0x49c>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&aq, 3);
  80042028c9:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80042028cd:	be 03 00 00 00       	mov    $0x3,%esi
  80042028d2:	48 89 c7             	mov    %rax,%rdi
  80042028d5:	48 b8 ba 22 20 04 80 	movabs $0x80042022ba,%rax
  80042028dc:	00 00 00 
  80042028df:	ff d0                	callq  *%rax
  80042028e1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 8;
  80042028e5:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
			goto number;
  80042028ec:	e9 85 00 00 00       	jmpq   8004202976 <vprintfmt+0x49c>
			break;

			// pointer
		case 'p':
			putch('0', putdat);
  80042028f1:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042028f5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042028f9:	48 89 d6             	mov    %rdx,%rsi
  80042028fc:	bf 30 00 00 00       	mov    $0x30,%edi
  8004202901:	ff d0                	callq  *%rax
			putch('x', putdat);
  8004202903:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004202907:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420290b:	48 89 d6             	mov    %rdx,%rsi
  800420290e:	bf 78 00 00 00       	mov    $0x78,%edi
  8004202913:	ff d0                	callq  *%rax
			num = (unsigned long long)
				(uintptr_t) va_arg(aq, void *);
  8004202915:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004202918:	83 f8 30             	cmp    $0x30,%eax
  800420291b:	73 17                	jae    8004202934 <vprintfmt+0x45a>
  800420291d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004202921:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004202924:	89 c0                	mov    %eax,%eax
  8004202926:	48 01 d0             	add    %rdx,%rax
  8004202929:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800420292c:	83 c2 08             	add    $0x8,%edx
  800420292f:	89 55 b8             	mov    %edx,-0x48(%rbp)

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8004202932:	eb 0f                	jmp    8004202943 <vprintfmt+0x469>
				(uintptr_t) va_arg(aq, void *);
  8004202934:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004202938:	48 89 d0             	mov    %rdx,%rax
  800420293b:	48 83 c2 08          	add    $0x8,%rdx
  800420293f:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8004202943:	48 8b 00             	mov    (%rax),%rax

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8004202946:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				(uintptr_t) va_arg(aq, void *);
			base = 16;
  800420294a:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
			goto number;
  8004202951:	eb 23                	jmp    8004202976 <vprintfmt+0x49c>

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&aq, 3);
  8004202953:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8004202957:	be 03 00 00 00       	mov    $0x3,%esi
  800420295c:	48 89 c7             	mov    %rax,%rdi
  800420295f:	48 b8 ba 22 20 04 80 	movabs $0x80042022ba,%rax
  8004202966:	00 00 00 
  8004202969:	ff d0                	callq  *%rax
  800420296b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 16;
  800420296f:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8004202976:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  800420297b:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  800420297e:	8b 7d dc             	mov    -0x24(%rbp),%edi
  8004202981:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202985:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8004202989:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420298d:	45 89 c1             	mov    %r8d,%r9d
  8004202990:	41 89 f8             	mov    %edi,%r8d
  8004202993:	48 89 c7             	mov    %rax,%rdi
  8004202996:	48 b8 ff 21 20 04 80 	movabs $0x80042021ff,%rax
  800420299d:	00 00 00 
  80042029a0:	ff d0                	callq  *%rax
			break;
  80042029a2:	eb 3f                	jmp    80042029e3 <vprintfmt+0x509>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  80042029a4:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042029a8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042029ac:	48 89 d6             	mov    %rdx,%rsi
  80042029af:	89 df                	mov    %ebx,%edi
  80042029b1:	ff d0                	callq  *%rax
			break;
  80042029b3:	eb 2e                	jmp    80042029e3 <vprintfmt+0x509>

			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80042029b5:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042029b9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042029bd:	48 89 d6             	mov    %rdx,%rsi
  80042029c0:	bf 25 00 00 00       	mov    $0x25,%edi
  80042029c5:	ff d0                	callq  *%rax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80042029c7:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  80042029cc:	eb 05                	jmp    80042029d3 <vprintfmt+0x4f9>
  80042029ce:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  80042029d3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042029d7:	48 83 e8 01          	sub    $0x1,%rax
  80042029db:	0f b6 00             	movzbl (%rax),%eax
  80042029de:	3c 25                	cmp    $0x25,%al
  80042029e0:	75 ec                	jne    80042029ce <vprintfmt+0x4f4>
				/* do nothing */;
			break;
  80042029e2:	90                   	nop
		}
	}
  80042029e3:	90                   	nop
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042029e4:	e9 43 fb ff ff       	jmpq   800420252c <vprintfmt+0x52>
				/* do nothing */;
			break;
		}
	}
	va_end(aq);
}
  80042029e9:	48 83 c4 60          	add    $0x60,%rsp
  80042029ed:	5b                   	pop    %rbx
  80042029ee:	41 5c                	pop    %r12
  80042029f0:	5d                   	pop    %rbp
  80042029f1:	c3                   	retq   

00000080042029f2 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042029f2:	55                   	push   %rbp
  80042029f3:	48 89 e5             	mov    %rsp,%rbp
  80042029f6:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  80042029fd:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  8004202a04:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  8004202a0b:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004202a12:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004202a19:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004202a20:	84 c0                	test   %al,%al
  8004202a22:	74 20                	je     8004202a44 <printfmt+0x52>
  8004202a24:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004202a28:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004202a2c:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004202a30:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004202a34:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004202a38:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004202a3c:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004202a40:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004202a44:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  8004202a4b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  8004202a52:	00 00 00 
  8004202a55:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004202a5c:	00 00 00 
  8004202a5f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004202a63:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004202a6a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004202a71:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	vprintfmt(putch, putdat, fmt, ap);
  8004202a78:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  8004202a7f:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  8004202a86:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  8004202a8d:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004202a94:	48 89 c7             	mov    %rax,%rdi
  8004202a97:	48 b8 da 24 20 04 80 	movabs $0x80042024da,%rax
  8004202a9e:	00 00 00 
  8004202aa1:	ff d0                	callq  *%rax
	va_end(ap);
}
  8004202aa3:	c9                   	leaveq 
  8004202aa4:	c3                   	retq   

0000008004202aa5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004202aa5:	55                   	push   %rbp
  8004202aa6:	48 89 e5             	mov    %rsp,%rbp
  8004202aa9:	48 83 ec 10          	sub    $0x10,%rsp
  8004202aad:	89 7d fc             	mov    %edi,-0x4(%rbp)
  8004202ab0:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	b->cnt++;
  8004202ab4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202ab8:	8b 40 10             	mov    0x10(%rax),%eax
  8004202abb:	8d 50 01             	lea    0x1(%rax),%edx
  8004202abe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202ac2:	89 50 10             	mov    %edx,0x10(%rax)
	if (b->buf < b->ebuf)
  8004202ac5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202ac9:	48 8b 10             	mov    (%rax),%rdx
  8004202acc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202ad0:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004202ad4:	48 39 c2             	cmp    %rax,%rdx
  8004202ad7:	73 17                	jae    8004202af0 <sprintputch+0x4b>
		*b->buf++ = ch;
  8004202ad9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202add:	48 8b 00             	mov    (%rax),%rax
  8004202ae0:	48 8d 48 01          	lea    0x1(%rax),%rcx
  8004202ae4:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004202ae8:	48 89 0a             	mov    %rcx,(%rdx)
  8004202aeb:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004202aee:	88 10                	mov    %dl,(%rax)
}
  8004202af0:	c9                   	leaveq 
  8004202af1:	c3                   	retq   

0000008004202af2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8004202af2:	55                   	push   %rbp
  8004202af3:	48 89 e5             	mov    %rsp,%rbp
  8004202af6:	48 83 ec 50          	sub    $0x50,%rsp
  8004202afa:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004202afe:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  8004202b01:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8004202b05:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
	va_list aq;
	va_copy(aq,ap);
  8004202b09:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  8004202b0d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004202b11:	48 8b 0a             	mov    (%rdx),%rcx
  8004202b14:	48 89 08             	mov    %rcx,(%rax)
  8004202b17:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004202b1b:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8004202b1f:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8004202b23:	48 89 50 10          	mov    %rdx,0x10(%rax)
	struct sprintbuf b = {buf, buf+n-1, 0};
  8004202b27:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004202b2b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004202b2f:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8004202b32:	48 98                	cltq   
  8004202b34:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8004202b38:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004202b3c:	48 01 d0             	add    %rdx,%rax
  8004202b3f:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  8004202b43:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)

	if (buf == NULL || n < 1)
  8004202b4a:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004202b4f:	74 06                	je     8004202b57 <vsnprintf+0x65>
  8004202b51:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8004202b55:	7f 07                	jg     8004202b5e <vsnprintf+0x6c>
		return -E_INVAL;
  8004202b57:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004202b5c:	eb 2f                	jmp    8004202b8d <vsnprintf+0x9b>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, aq);
  8004202b5e:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  8004202b62:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004202b66:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8004202b6a:	48 89 c6             	mov    %rax,%rsi
  8004202b6d:	48 bf a5 2a 20 04 80 	movabs $0x8004202aa5,%rdi
  8004202b74:	00 00 00 
  8004202b77:	48 b8 da 24 20 04 80 	movabs $0x80042024da,%rax
  8004202b7e:	00 00 00 
  8004202b81:	ff d0                	callq  *%rax
	va_end(aq);
	// null terminate the buffer
	*b.buf = '\0';
  8004202b83:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004202b87:	c6 00 00             	movb   $0x0,(%rax)

	return b.cnt;
  8004202b8a:	8b 45 e0             	mov    -0x20(%rbp),%eax
}
  8004202b8d:	c9                   	leaveq 
  8004202b8e:	c3                   	retq   

0000008004202b8f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8004202b8f:	55                   	push   %rbp
  8004202b90:	48 89 e5             	mov    %rsp,%rbp
  8004202b93:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8004202b9a:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  8004202ba1:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  8004202ba7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004202bae:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004202bb5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004202bbc:	84 c0                	test   %al,%al
  8004202bbe:	74 20                	je     8004202be0 <snprintf+0x51>
  8004202bc0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004202bc4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004202bc8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004202bcc:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004202bd0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004202bd4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004202bd8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004202bdc:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004202be0:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
	va_list ap;
	int rc;
	va_list aq;
	va_start(ap, fmt);
  8004202be7:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  8004202bee:	00 00 00 
  8004202bf1:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  8004202bf8:	00 00 00 
  8004202bfb:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004202bff:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8004202c06:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004202c0d:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
	va_copy(aq,ap);
  8004202c14:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8004202c1b:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  8004202c22:	48 8b 0a             	mov    (%rdx),%rcx
  8004202c25:	48 89 08             	mov    %rcx,(%rax)
  8004202c28:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004202c2c:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8004202c30:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8004202c34:	48 89 50 10          	mov    %rdx,0x10(%rax)
	rc = vsnprintf(buf, n, fmt, aq);
  8004202c38:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  8004202c3f:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  8004202c46:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  8004202c4c:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  8004202c53:	48 89 c7             	mov    %rax,%rdi
  8004202c56:	48 b8 f2 2a 20 04 80 	movabs $0x8004202af2,%rax
  8004202c5d:	00 00 00 
  8004202c60:	ff d0                	callq  *%rax
  8004202c62:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
	va_end(aq);

	return rc;
  8004202c68:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  8004202c6e:	c9                   	leaveq 
  8004202c6f:	c3                   	retq   

0000008004202c70 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8004202c70:	55                   	push   %rbp
  8004202c71:	48 89 e5             	mov    %rsp,%rbp
  8004202c74:	48 83 ec 20          	sub    $0x20,%rsp
  8004202c78:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int i, c, echoing;

	if (prompt != NULL)
  8004202c7c:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004202c81:	74 22                	je     8004202ca5 <readline+0x35>
		cprintf("%s", prompt);
  8004202c83:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202c87:	48 89 c6             	mov    %rax,%rsi
  8004202c8a:	48 bf a8 9f 20 04 80 	movabs $0x8004209fa8,%rdi
  8004202c91:	00 00 00 
  8004202c94:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202c99:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004202ca0:	00 00 00 
  8004202ca3:	ff d2                	callq  *%rdx

	i = 0;
  8004202ca5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	echoing = iscons(0);
  8004202cac:	bf 00 00 00 00       	mov    $0x0,%edi
  8004202cb1:	48 b8 93 0e 20 04 80 	movabs $0x8004200e93,%rax
  8004202cb8:	00 00 00 
  8004202cbb:	ff d0                	callq  *%rax
  8004202cbd:	89 45 f8             	mov    %eax,-0x8(%rbp)
	while (1) {
		c = getchar();
  8004202cc0:	48 b8 71 0e 20 04 80 	movabs $0x8004200e71,%rax
  8004202cc7:	00 00 00 
  8004202cca:	ff d0                	callq  *%rax
  8004202ccc:	89 45 f4             	mov    %eax,-0xc(%rbp)
		if (c < 0) {
  8004202ccf:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8004202cd3:	79 2a                	jns    8004202cff <readline+0x8f>
			cprintf("read error: %e\n", c);
  8004202cd5:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004202cd8:	89 c6                	mov    %eax,%esi
  8004202cda:	48 bf ab 9f 20 04 80 	movabs $0x8004209fab,%rdi
  8004202ce1:	00 00 00 
  8004202ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202ce9:	48 ba 87 15 20 04 80 	movabs $0x8004201587,%rdx
  8004202cf0:	00 00 00 
  8004202cf3:	ff d2                	callq  *%rdx
			return NULL;
  8004202cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202cfa:	e9 be 00 00 00       	jmpq   8004202dbd <readline+0x14d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8004202cff:	83 7d f4 08          	cmpl   $0x8,-0xc(%rbp)
  8004202d03:	74 06                	je     8004202d0b <readline+0x9b>
  8004202d05:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%rbp)
  8004202d09:	75 26                	jne    8004202d31 <readline+0xc1>
  8004202d0b:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004202d0f:	7e 20                	jle    8004202d31 <readline+0xc1>
			if (echoing)
  8004202d11:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004202d15:	74 11                	je     8004202d28 <readline+0xb8>
				cputchar('\b');
  8004202d17:	bf 08 00 00 00       	mov    $0x8,%edi
  8004202d1c:	48 b8 53 0e 20 04 80 	movabs $0x8004200e53,%rax
  8004202d23:	00 00 00 
  8004202d26:	ff d0                	callq  *%rax
			i--;
  8004202d28:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
  8004202d2c:	e9 87 00 00 00       	jmpq   8004202db8 <readline+0x148>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8004202d31:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004202d35:	7e 3f                	jle    8004202d76 <readline+0x106>
  8004202d37:	81 7d fc fe 03 00 00 	cmpl   $0x3fe,-0x4(%rbp)
  8004202d3e:	7f 36                	jg     8004202d76 <readline+0x106>
			if (echoing)
  8004202d40:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004202d44:	74 11                	je     8004202d57 <readline+0xe7>
				cputchar(c);
  8004202d46:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004202d49:	89 c7                	mov    %eax,%edi
  8004202d4b:	48 b8 53 0e 20 04 80 	movabs $0x8004200e53,%rax
  8004202d52:	00 00 00 
  8004202d55:	ff d0                	callq  *%rax
			buf[i++] = c;
  8004202d57:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202d5a:	8d 50 01             	lea    0x1(%rax),%edx
  8004202d5d:	89 55 fc             	mov    %edx,-0x4(%rbp)
  8004202d60:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004202d63:	89 d1                	mov    %edx,%ecx
  8004202d65:	48 ba e0 c8 21 04 80 	movabs $0x800421c8e0,%rdx
  8004202d6c:	00 00 00 
  8004202d6f:	48 98                	cltq   
  8004202d71:	88 0c 02             	mov    %cl,(%rdx,%rax,1)
  8004202d74:	eb 42                	jmp    8004202db8 <readline+0x148>
		} else if (c == '\n' || c == '\r') {
  8004202d76:	83 7d f4 0a          	cmpl   $0xa,-0xc(%rbp)
  8004202d7a:	74 06                	je     8004202d82 <readline+0x112>
  8004202d7c:	83 7d f4 0d          	cmpl   $0xd,-0xc(%rbp)
  8004202d80:	75 36                	jne    8004202db8 <readline+0x148>
			if (echoing)
  8004202d82:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004202d86:	74 11                	je     8004202d99 <readline+0x129>
				cputchar('\n');
  8004202d88:	bf 0a 00 00 00       	mov    $0xa,%edi
  8004202d8d:	48 b8 53 0e 20 04 80 	movabs $0x8004200e53,%rax
  8004202d94:	00 00 00 
  8004202d97:	ff d0                	callq  *%rax
			buf[i] = 0;
  8004202d99:	48 ba e0 c8 21 04 80 	movabs $0x800421c8e0,%rdx
  8004202da0:	00 00 00 
  8004202da3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202da6:	48 98                	cltq   
  8004202da8:	c6 04 02 00          	movb   $0x0,(%rdx,%rax,1)
			return buf;
  8004202dac:	48 b8 e0 c8 21 04 80 	movabs $0x800421c8e0,%rax
  8004202db3:	00 00 00 
  8004202db6:	eb 05                	jmp    8004202dbd <readline+0x14d>
		}
	}
  8004202db8:	e9 03 ff ff ff       	jmpq   8004202cc0 <readline+0x50>
}
  8004202dbd:	c9                   	leaveq 
  8004202dbe:	c3                   	retq   

0000008004202dbf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8004202dbf:	55                   	push   %rbp
  8004202dc0:	48 89 e5             	mov    %rsp,%rbp
  8004202dc3:	48 83 ec 18          	sub    $0x18,%rsp
  8004202dc7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int n;

	for (n = 0; *s != '\0'; s++)
  8004202dcb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004202dd2:	eb 09                	jmp    8004202ddd <strlen+0x1e>
		n++;
  8004202dd4:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8004202dd8:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004202ddd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202de1:	0f b6 00             	movzbl (%rax),%eax
  8004202de4:	84 c0                	test   %al,%al
  8004202de6:	75 ec                	jne    8004202dd4 <strlen+0x15>
		n++;
	return n;
  8004202de8:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004202deb:	c9                   	leaveq 
  8004202dec:	c3                   	retq   

0000008004202ded <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8004202ded:	55                   	push   %rbp
  8004202dee:	48 89 e5             	mov    %rsp,%rbp
  8004202df1:	48 83 ec 20          	sub    $0x20,%rsp
  8004202df5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202df9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8004202dfd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004202e04:	eb 0e                	jmp    8004202e14 <strnlen+0x27>
		n++;
  8004202e06:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8004202e0a:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004202e0f:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  8004202e14:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004202e19:	74 0b                	je     8004202e26 <strnlen+0x39>
  8004202e1b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e1f:	0f b6 00             	movzbl (%rax),%eax
  8004202e22:	84 c0                	test   %al,%al
  8004202e24:	75 e0                	jne    8004202e06 <strnlen+0x19>
		n++;
	return n;
  8004202e26:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004202e29:	c9                   	leaveq 
  8004202e2a:	c3                   	retq   

0000008004202e2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8004202e2b:	55                   	push   %rbp
  8004202e2c:	48 89 e5             	mov    %rsp,%rbp
  8004202e2f:	48 83 ec 20          	sub    $0x20,%rsp
  8004202e33:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202e37:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	char *ret;

	ret = dst;
  8004202e3b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e3f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	while ((*dst++ = *src++) != '\0')
  8004202e43:	90                   	nop
  8004202e44:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e48:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004202e4c:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004202e50:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004202e54:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8004202e58:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004202e5c:	0f b6 12             	movzbl (%rdx),%edx
  8004202e5f:	88 10                	mov    %dl,(%rax)
  8004202e61:	0f b6 00             	movzbl (%rax),%eax
  8004202e64:	84 c0                	test   %al,%al
  8004202e66:	75 dc                	jne    8004202e44 <strcpy+0x19>
		/* do nothing */;
	return ret;
  8004202e68:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004202e6c:	c9                   	leaveq 
  8004202e6d:	c3                   	retq   

0000008004202e6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  8004202e6e:	55                   	push   %rbp
  8004202e6f:	48 89 e5             	mov    %rsp,%rbp
  8004202e72:	48 83 ec 20          	sub    $0x20,%rsp
  8004202e76:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202e7a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int len = strlen(dst);
  8004202e7e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e82:	48 89 c7             	mov    %rax,%rdi
  8004202e85:	48 b8 bf 2d 20 04 80 	movabs $0x8004202dbf,%rax
  8004202e8c:	00 00 00 
  8004202e8f:	ff d0                	callq  *%rax
  8004202e91:	89 45 fc             	mov    %eax,-0x4(%rbp)
	strcpy(dst + len, src);
  8004202e94:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202e97:	48 63 d0             	movslq %eax,%rdx
  8004202e9a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e9e:	48 01 c2             	add    %rax,%rdx
  8004202ea1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202ea5:	48 89 c6             	mov    %rax,%rsi
  8004202ea8:	48 89 d7             	mov    %rdx,%rdi
  8004202eab:	48 b8 2b 2e 20 04 80 	movabs $0x8004202e2b,%rax
  8004202eb2:	00 00 00 
  8004202eb5:	ff d0                	callq  *%rax
	return dst;
  8004202eb7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004202ebb:	c9                   	leaveq 
  8004202ebc:	c3                   	retq   

0000008004202ebd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8004202ebd:	55                   	push   %rbp
  8004202ebe:	48 89 e5             	mov    %rsp,%rbp
  8004202ec1:	48 83 ec 28          	sub    $0x28,%rsp
  8004202ec5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202ec9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202ecd:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	size_t i;
	char *ret;

	ret = dst;
  8004202ed1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202ed5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	for (i = 0; i < size; i++) {
  8004202ed9:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004202ee0:	00 
  8004202ee1:	eb 2a                	jmp    8004202f0d <strncpy+0x50>
		*dst++ = *src;
  8004202ee3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202ee7:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004202eeb:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004202eef:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004202ef3:	0f b6 12             	movzbl (%rdx),%edx
  8004202ef6:	88 10                	mov    %dl,(%rax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8004202ef8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202efc:	0f b6 00             	movzbl (%rax),%eax
  8004202eff:	84 c0                	test   %al,%al
  8004202f01:	74 05                	je     8004202f08 <strncpy+0x4b>
			src++;
  8004202f03:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8004202f08:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004202f0d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202f11:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8004202f15:	72 cc                	jb     8004202ee3 <strncpy+0x26>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8004202f17:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004202f1b:	c9                   	leaveq 
  8004202f1c:	c3                   	retq   

0000008004202f1d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8004202f1d:	55                   	push   %rbp
  8004202f1e:	48 89 e5             	mov    %rsp,%rbp
  8004202f21:	48 83 ec 28          	sub    $0x28,%rsp
  8004202f25:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202f29:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202f2d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	char *dst_in;

	dst_in = dst;
  8004202f31:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202f35:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (size > 0) {
  8004202f39:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004202f3e:	74 3d                	je     8004202f7d <strlcpy+0x60>
		while (--size > 0 && *src != '\0')
  8004202f40:	eb 1d                	jmp    8004202f5f <strlcpy+0x42>
			*dst++ = *src++;
  8004202f42:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202f46:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004202f4a:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004202f4e:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004202f52:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8004202f56:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004202f5a:	0f b6 12             	movzbl (%rdx),%edx
  8004202f5d:	88 10                	mov    %dl,(%rax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8004202f5f:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  8004202f64:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004202f69:	74 0b                	je     8004202f76 <strlcpy+0x59>
  8004202f6b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202f6f:	0f b6 00             	movzbl (%rax),%eax
  8004202f72:	84 c0                	test   %al,%al
  8004202f74:	75 cc                	jne    8004202f42 <strlcpy+0x25>
			*dst++ = *src++;
		*dst = '\0';
  8004202f76:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202f7a:	c6 00 00             	movb   $0x0,(%rax)
	}
	return dst - dst_in;
  8004202f7d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004202f81:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202f85:	48 29 c2             	sub    %rax,%rdx
  8004202f88:	48 89 d0             	mov    %rdx,%rax
}
  8004202f8b:	c9                   	leaveq 
  8004202f8c:	c3                   	retq   

0000008004202f8d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8004202f8d:	55                   	push   %rbp
  8004202f8e:	48 89 e5             	mov    %rsp,%rbp
  8004202f91:	48 83 ec 10          	sub    $0x10,%rsp
  8004202f95:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004202f99:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	while (*p && *p == *q)
  8004202f9d:	eb 0a                	jmp    8004202fa9 <strcmp+0x1c>
		p++, q++;
  8004202f9f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004202fa4:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8004202fa9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202fad:	0f b6 00             	movzbl (%rax),%eax
  8004202fb0:	84 c0                	test   %al,%al
  8004202fb2:	74 12                	je     8004202fc6 <strcmp+0x39>
  8004202fb4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202fb8:	0f b6 10             	movzbl (%rax),%edx
  8004202fbb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202fbf:	0f b6 00             	movzbl (%rax),%eax
  8004202fc2:	38 c2                	cmp    %al,%dl
  8004202fc4:	74 d9                	je     8004202f9f <strcmp+0x12>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8004202fc6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202fca:	0f b6 00             	movzbl (%rax),%eax
  8004202fcd:	0f b6 d0             	movzbl %al,%edx
  8004202fd0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202fd4:	0f b6 00             	movzbl (%rax),%eax
  8004202fd7:	0f b6 c0             	movzbl %al,%eax
  8004202fda:	29 c2                	sub    %eax,%edx
  8004202fdc:	89 d0                	mov    %edx,%eax
}
  8004202fde:	c9                   	leaveq 
  8004202fdf:	c3                   	retq   

0000008004202fe0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8004202fe0:	55                   	push   %rbp
  8004202fe1:	48 89 e5             	mov    %rsp,%rbp
  8004202fe4:	48 83 ec 18          	sub    $0x18,%rsp
  8004202fe8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004202fec:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8004202ff0:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	while (n > 0 && *p && *p == *q)
  8004202ff4:	eb 0f                	jmp    8004203005 <strncmp+0x25>
		n--, p++, q++;
  8004202ff6:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  8004202ffb:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004203000:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8004203005:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420300a:	74 1d                	je     8004203029 <strncmp+0x49>
  800420300c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203010:	0f b6 00             	movzbl (%rax),%eax
  8004203013:	84 c0                	test   %al,%al
  8004203015:	74 12                	je     8004203029 <strncmp+0x49>
  8004203017:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420301b:	0f b6 10             	movzbl (%rax),%edx
  800420301e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203022:	0f b6 00             	movzbl (%rax),%eax
  8004203025:	38 c2                	cmp    %al,%dl
  8004203027:	74 cd                	je     8004202ff6 <strncmp+0x16>
		n--, p++, q++;
	if (n == 0)
  8004203029:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420302e:	75 07                	jne    8004203037 <strncmp+0x57>
		return 0;
  8004203030:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203035:	eb 18                	jmp    800420304f <strncmp+0x6f>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8004203037:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420303b:	0f b6 00             	movzbl (%rax),%eax
  800420303e:	0f b6 d0             	movzbl %al,%edx
  8004203041:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203045:	0f b6 00             	movzbl (%rax),%eax
  8004203048:	0f b6 c0             	movzbl %al,%eax
  800420304b:	29 c2                	sub    %eax,%edx
  800420304d:	89 d0                	mov    %edx,%eax
}
  800420304f:	c9                   	leaveq 
  8004203050:	c3                   	retq   

0000008004203051 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8004203051:	55                   	push   %rbp
  8004203052:	48 89 e5             	mov    %rsp,%rbp
  8004203055:	48 83 ec 0c          	sub    $0xc,%rsp
  8004203059:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  800420305d:	89 f0                	mov    %esi,%eax
  800420305f:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  8004203062:	eb 17                	jmp    800420307b <strchr+0x2a>
		if (*s == c)
  8004203064:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203068:	0f b6 00             	movzbl (%rax),%eax
  800420306b:	3a 45 f4             	cmp    -0xc(%rbp),%al
  800420306e:	75 06                	jne    8004203076 <strchr+0x25>
			return (char *) s;
  8004203070:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203074:	eb 15                	jmp    800420308b <strchr+0x3a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8004203076:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  800420307b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420307f:	0f b6 00             	movzbl (%rax),%eax
  8004203082:	84 c0                	test   %al,%al
  8004203084:	75 de                	jne    8004203064 <strchr+0x13>
		if (*s == c)
			return (char *) s;
	return 0;
  8004203086:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420308b:	c9                   	leaveq 
  800420308c:	c3                   	retq   

000000800420308d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800420308d:	55                   	push   %rbp
  800420308e:	48 89 e5             	mov    %rsp,%rbp
  8004203091:	48 83 ec 0c          	sub    $0xc,%rsp
  8004203095:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004203099:	89 f0                	mov    %esi,%eax
  800420309b:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  800420309e:	eb 13                	jmp    80042030b3 <strfind+0x26>
		if (*s == c)
  80042030a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042030a4:	0f b6 00             	movzbl (%rax),%eax
  80042030a7:	3a 45 f4             	cmp    -0xc(%rbp),%al
  80042030aa:	75 02                	jne    80042030ae <strfind+0x21>
			break;
  80042030ac:	eb 10                	jmp    80042030be <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80042030ae:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80042030b3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042030b7:	0f b6 00             	movzbl (%rax),%eax
  80042030ba:	84 c0                	test   %al,%al
  80042030bc:	75 e2                	jne    80042030a0 <strfind+0x13>
		if (*s == c)
			break;
	return (char *) s;
  80042030be:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  80042030c2:	c9                   	leaveq 
  80042030c3:	c3                   	retq   

00000080042030c4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80042030c4:	55                   	push   %rbp
  80042030c5:	48 89 e5             	mov    %rsp,%rbp
  80042030c8:	48 83 ec 18          	sub    $0x18,%rsp
  80042030cc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80042030d0:	89 75 f4             	mov    %esi,-0xc(%rbp)
  80042030d3:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	char *p;

	if (n == 0)
  80042030d7:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042030dc:	75 06                	jne    80042030e4 <memset+0x20>
		return v;
  80042030de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042030e2:	eb 69                	jmp    800420314d <memset+0x89>
	if ((int64_t)v%4 == 0 && n%4 == 0) {
  80042030e4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042030e8:	83 e0 03             	and    $0x3,%eax
  80042030eb:	48 85 c0             	test   %rax,%rax
  80042030ee:	75 48                	jne    8004203138 <memset+0x74>
  80042030f0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042030f4:	83 e0 03             	and    $0x3,%eax
  80042030f7:	48 85 c0             	test   %rax,%rax
  80042030fa:	75 3c                	jne    8004203138 <memset+0x74>
		c &= 0xFF;
  80042030fc:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8004203103:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203106:	c1 e0 18             	shl    $0x18,%eax
  8004203109:	89 c2                	mov    %eax,%edx
  800420310b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420310e:	c1 e0 10             	shl    $0x10,%eax
  8004203111:	09 c2                	or     %eax,%edx
  8004203113:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203116:	c1 e0 08             	shl    $0x8,%eax
  8004203119:	09 d0                	or     %edx,%eax
  800420311b:	09 45 f4             	or     %eax,-0xc(%rbp)
		asm volatile("cld; rep stosl\n"
			     :: "D" (v), "a" (c), "c" (n/4)
  800420311e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203122:	48 c1 e8 02          	shr    $0x2,%rax
  8004203126:	48 89 c1             	mov    %rax,%rcx
	if (n == 0)
		return v;
	if ((int64_t)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8004203129:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420312d:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203130:	48 89 d7             	mov    %rdx,%rdi
  8004203133:	fc                   	cld    
  8004203134:	f3 ab                	rep stos %eax,%es:(%rdi)
  8004203136:	eb 11                	jmp    8004203149 <memset+0x85>
			     :: "D" (v), "a" (c), "c" (n/4)
			     : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8004203138:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420313c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420313f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004203143:	48 89 d7             	mov    %rdx,%rdi
  8004203146:	fc                   	cld    
  8004203147:	f3 aa                	rep stos %al,%es:(%rdi)
			     :: "D" (v), "a" (c), "c" (n)
			     : "cc", "memory");
	return v;
  8004203149:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800420314d:	c9                   	leaveq 
  800420314e:	c3                   	retq   

000000800420314f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800420314f:	55                   	push   %rbp
  8004203150:	48 89 e5             	mov    %rsp,%rbp
  8004203153:	48 83 ec 28          	sub    $0x28,%rsp
  8004203157:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420315b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420315f:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const char *s;
	char *d;

	s = src;
  8004203163:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203167:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	d = dst;
  800420316b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420316f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	if (s < d && s + n > d) {
  8004203173:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203177:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  800420317b:	0f 83 88 00 00 00    	jae    8004203209 <memmove+0xba>
  8004203181:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203185:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004203189:	48 01 d0             	add    %rdx,%rax
  800420318c:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8004203190:	76 77                	jbe    8004203209 <memmove+0xba>
		s += n;
  8004203192:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203196:	48 01 45 f8          	add    %rax,-0x8(%rbp)
		d += n;
  800420319a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420319e:	48 01 45 f0          	add    %rax,-0x10(%rbp)
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  80042031a2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042031a6:	83 e0 03             	and    $0x3,%eax
  80042031a9:	48 85 c0             	test   %rax,%rax
  80042031ac:	75 3b                	jne    80042031e9 <memmove+0x9a>
  80042031ae:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042031b2:	83 e0 03             	and    $0x3,%eax
  80042031b5:	48 85 c0             	test   %rax,%rax
  80042031b8:	75 2f                	jne    80042031e9 <memmove+0x9a>
  80042031ba:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042031be:	83 e0 03             	and    $0x3,%eax
  80042031c1:	48 85 c0             	test   %rax,%rax
  80042031c4:	75 23                	jne    80042031e9 <memmove+0x9a>
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80042031c6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042031ca:	48 83 e8 04          	sub    $0x4,%rax
  80042031ce:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042031d2:	48 83 ea 04          	sub    $0x4,%rdx
  80042031d6:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  80042031da:	48 c1 e9 02          	shr    $0x2,%rcx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80042031de:	48 89 c7             	mov    %rax,%rdi
  80042031e1:	48 89 d6             	mov    %rdx,%rsi
  80042031e4:	fd                   	std    
  80042031e5:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80042031e7:	eb 1d                	jmp    8004203206 <memmove+0xb7>
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80042031e9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042031ed:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80042031f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042031f5:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80042031f9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042031fd:	48 89 d7             	mov    %rdx,%rdi
  8004203200:	48 89 c1             	mov    %rax,%rcx
  8004203203:	fd                   	std    
  8004203204:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8004203206:	fc                   	cld    
  8004203207:	eb 57                	jmp    8004203260 <memmove+0x111>
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  8004203209:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420320d:	83 e0 03             	and    $0x3,%eax
  8004203210:	48 85 c0             	test   %rax,%rax
  8004203213:	75 36                	jne    800420324b <memmove+0xfc>
  8004203215:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203219:	83 e0 03             	and    $0x3,%eax
  800420321c:	48 85 c0             	test   %rax,%rax
  800420321f:	75 2a                	jne    800420324b <memmove+0xfc>
  8004203221:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203225:	83 e0 03             	and    $0x3,%eax
  8004203228:	48 85 c0             	test   %rax,%rax
  800420322b:	75 1e                	jne    800420324b <memmove+0xfc>
			asm volatile("cld; rep movsl\n"
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800420322d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203231:	48 c1 e8 02          	shr    $0x2,%rax
  8004203235:	48 89 c1             	mov    %rax,%rcx
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8004203238:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420323c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004203240:	48 89 c7             	mov    %rax,%rdi
  8004203243:	48 89 d6             	mov    %rdx,%rsi
  8004203246:	fc                   	cld    
  8004203247:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8004203249:	eb 15                	jmp    8004203260 <memmove+0x111>
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800420324b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420324f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004203253:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004203257:	48 89 c7             	mov    %rax,%rdi
  800420325a:	48 89 d6             	mov    %rdx,%rsi
  800420325d:	fc                   	cld    
  800420325e:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  8004203260:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004203264:	c9                   	leaveq 
  8004203265:	c3                   	retq   

0000008004203266 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8004203266:	55                   	push   %rbp
  8004203267:	48 89 e5             	mov    %rsp,%rbp
  800420326a:	48 83 ec 18          	sub    $0x18,%rsp
  800420326e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004203272:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8004203276:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	return memmove(dst, src, n);
  800420327a:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420327e:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  8004203282:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203286:	48 89 ce             	mov    %rcx,%rsi
  8004203289:	48 89 c7             	mov    %rax,%rdi
  800420328c:	48 b8 4f 31 20 04 80 	movabs $0x800420314f,%rax
  8004203293:	00 00 00 
  8004203296:	ff d0                	callq  *%rax
}
  8004203298:	c9                   	leaveq 
  8004203299:	c3                   	retq   

000000800420329a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800420329a:	55                   	push   %rbp
  800420329b:	48 89 e5             	mov    %rsp,%rbp
  800420329e:	48 83 ec 28          	sub    $0x28,%rsp
  80042032a2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042032a6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80042032aa:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const uint8_t *s1 = (const uint8_t *) v1;
  80042032ae:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042032b2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	const uint8_t *s2 = (const uint8_t *) v2;
  80042032b6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042032ba:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	while (n-- > 0) {
  80042032be:	eb 36                	jmp    80042032f6 <memcmp+0x5c>
		if (*s1 != *s2)
  80042032c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042032c4:	0f b6 10             	movzbl (%rax),%edx
  80042032c7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042032cb:	0f b6 00             	movzbl (%rax),%eax
  80042032ce:	38 c2                	cmp    %al,%dl
  80042032d0:	74 1a                	je     80042032ec <memcmp+0x52>
			return (int) *s1 - (int) *s2;
  80042032d2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042032d6:	0f b6 00             	movzbl (%rax),%eax
  80042032d9:	0f b6 d0             	movzbl %al,%edx
  80042032dc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042032e0:	0f b6 00             	movzbl (%rax),%eax
  80042032e3:	0f b6 c0             	movzbl %al,%eax
  80042032e6:	29 c2                	sub    %eax,%edx
  80042032e8:	89 d0                	mov    %edx,%eax
  80042032ea:	eb 20                	jmp    800420330c <memcmp+0x72>
		s1++, s2++;
  80042032ec:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80042032f1:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80042032f6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042032fa:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80042032fe:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004203302:	48 85 c0             	test   %rax,%rax
  8004203305:	75 b9                	jne    80042032c0 <memcmp+0x26>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8004203307:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420330c:	c9                   	leaveq 
  800420330d:	c3                   	retq   

000000800420330e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800420330e:	55                   	push   %rbp
  800420330f:	48 89 e5             	mov    %rsp,%rbp
  8004203312:	48 83 ec 28          	sub    $0x28,%rsp
  8004203316:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420331a:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  800420331d:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const void *ends = (const char *) s + n;
  8004203321:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203325:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004203329:	48 01 d0             	add    %rdx,%rax
  800420332c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	for (; s < ends; s++)
  8004203330:	eb 15                	jmp    8004203347 <memfind+0x39>
		if (*(const unsigned char *) s == (unsigned char) c)
  8004203332:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203336:	0f b6 10             	movzbl (%rax),%edx
  8004203339:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420333c:	38 c2                	cmp    %al,%dl
  800420333e:	75 02                	jne    8004203342 <memfind+0x34>
			break;
  8004203340:	eb 0f                	jmp    8004203351 <memfind+0x43>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8004203342:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004203347:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420334b:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  800420334f:	72 e1                	jb     8004203332 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8004203351:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004203355:	c9                   	leaveq 
  8004203356:	c3                   	retq   

0000008004203357 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8004203357:	55                   	push   %rbp
  8004203358:	48 89 e5             	mov    %rsp,%rbp
  800420335b:	48 83 ec 34          	sub    $0x34,%rsp
  800420335f:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004203363:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8004203367:	89 55 cc             	mov    %edx,-0x34(%rbp)
	int neg = 0;
  800420336a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	long val = 0;
  8004203371:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004203378:	00 

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8004203379:	eb 05                	jmp    8004203380 <strtol+0x29>
		s++;
  800420337b:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8004203380:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203384:	0f b6 00             	movzbl (%rax),%eax
  8004203387:	3c 20                	cmp    $0x20,%al
  8004203389:	74 f0                	je     800420337b <strtol+0x24>
  800420338b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420338f:	0f b6 00             	movzbl (%rax),%eax
  8004203392:	3c 09                	cmp    $0x9,%al
  8004203394:	74 e5                	je     800420337b <strtol+0x24>
		s++;

	// plus/minus sign
	if (*s == '+')
  8004203396:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420339a:	0f b6 00             	movzbl (%rax),%eax
  800420339d:	3c 2b                	cmp    $0x2b,%al
  800420339f:	75 07                	jne    80042033a8 <strtol+0x51>
		s++;
  80042033a1:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  80042033a6:	eb 17                	jmp    80042033bf <strtol+0x68>
	else if (*s == '-')
  80042033a8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042033ac:	0f b6 00             	movzbl (%rax),%eax
  80042033af:	3c 2d                	cmp    $0x2d,%al
  80042033b1:	75 0c                	jne    80042033bf <strtol+0x68>
		s++, neg = 1;
  80042033b3:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  80042033b8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80042033bf:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  80042033c3:	74 06                	je     80042033cb <strtol+0x74>
  80042033c5:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  80042033c9:	75 28                	jne    80042033f3 <strtol+0x9c>
  80042033cb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042033cf:	0f b6 00             	movzbl (%rax),%eax
  80042033d2:	3c 30                	cmp    $0x30,%al
  80042033d4:	75 1d                	jne    80042033f3 <strtol+0x9c>
  80042033d6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042033da:	48 83 c0 01          	add    $0x1,%rax
  80042033de:	0f b6 00             	movzbl (%rax),%eax
  80042033e1:	3c 78                	cmp    $0x78,%al
  80042033e3:	75 0e                	jne    80042033f3 <strtol+0x9c>
		s += 2, base = 16;
  80042033e5:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  80042033ea:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  80042033f1:	eb 2c                	jmp    800420341f <strtol+0xc8>
	else if (base == 0 && s[0] == '0')
  80042033f3:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  80042033f7:	75 19                	jne    8004203412 <strtol+0xbb>
  80042033f9:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042033fd:	0f b6 00             	movzbl (%rax),%eax
  8004203400:	3c 30                	cmp    $0x30,%al
  8004203402:	75 0e                	jne    8004203412 <strtol+0xbb>
		s++, base = 8;
  8004203404:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8004203409:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  8004203410:	eb 0d                	jmp    800420341f <strtol+0xc8>
	else if (base == 0)
  8004203412:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8004203416:	75 07                	jne    800420341f <strtol+0xc8>
		base = 10;
  8004203418:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800420341f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203423:	0f b6 00             	movzbl (%rax),%eax
  8004203426:	3c 2f                	cmp    $0x2f,%al
  8004203428:	7e 1d                	jle    8004203447 <strtol+0xf0>
  800420342a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420342e:	0f b6 00             	movzbl (%rax),%eax
  8004203431:	3c 39                	cmp    $0x39,%al
  8004203433:	7f 12                	jg     8004203447 <strtol+0xf0>
			dig = *s - '0';
  8004203435:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203439:	0f b6 00             	movzbl (%rax),%eax
  800420343c:	0f be c0             	movsbl %al,%eax
  800420343f:	83 e8 30             	sub    $0x30,%eax
  8004203442:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8004203445:	eb 4e                	jmp    8004203495 <strtol+0x13e>
		else if (*s >= 'a' && *s <= 'z')
  8004203447:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420344b:	0f b6 00             	movzbl (%rax),%eax
  800420344e:	3c 60                	cmp    $0x60,%al
  8004203450:	7e 1d                	jle    800420346f <strtol+0x118>
  8004203452:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203456:	0f b6 00             	movzbl (%rax),%eax
  8004203459:	3c 7a                	cmp    $0x7a,%al
  800420345b:	7f 12                	jg     800420346f <strtol+0x118>
			dig = *s - 'a' + 10;
  800420345d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203461:	0f b6 00             	movzbl (%rax),%eax
  8004203464:	0f be c0             	movsbl %al,%eax
  8004203467:	83 e8 57             	sub    $0x57,%eax
  800420346a:	89 45 ec             	mov    %eax,-0x14(%rbp)
  800420346d:	eb 26                	jmp    8004203495 <strtol+0x13e>
		else if (*s >= 'A' && *s <= 'Z')
  800420346f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203473:	0f b6 00             	movzbl (%rax),%eax
  8004203476:	3c 40                	cmp    $0x40,%al
  8004203478:	7e 48                	jle    80042034c2 <strtol+0x16b>
  800420347a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420347e:	0f b6 00             	movzbl (%rax),%eax
  8004203481:	3c 5a                	cmp    $0x5a,%al
  8004203483:	7f 3d                	jg     80042034c2 <strtol+0x16b>
			dig = *s - 'A' + 10;
  8004203485:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203489:	0f b6 00             	movzbl (%rax),%eax
  800420348c:	0f be c0             	movsbl %al,%eax
  800420348f:	83 e8 37             	sub    $0x37,%eax
  8004203492:	89 45 ec             	mov    %eax,-0x14(%rbp)
		else
			break;
		if (dig >= base)
  8004203495:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004203498:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  800420349b:	7c 02                	jl     800420349f <strtol+0x148>
			break;
  800420349d:	eb 23                	jmp    80042034c2 <strtol+0x16b>
		s++, val = (val * base) + dig;
  800420349f:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  80042034a4:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042034a7:	48 98                	cltq   
  80042034a9:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  80042034ae:	48 89 c2             	mov    %rax,%rdx
  80042034b1:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042034b4:	48 98                	cltq   
  80042034b6:	48 01 d0             	add    %rdx,%rax
  80042034b9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		// we don't properly detect overflow!
	}
  80042034bd:	e9 5d ff ff ff       	jmpq   800420341f <strtol+0xc8>

	if (endptr)
  80042034c2:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  80042034c7:	74 0b                	je     80042034d4 <strtol+0x17d>
		*endptr = (char *) s;
  80042034c9:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042034cd:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80042034d1:	48 89 10             	mov    %rdx,(%rax)
	return (neg ? -val : val);
  80042034d4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80042034d8:	74 09                	je     80042034e3 <strtol+0x18c>
  80042034da:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042034de:	48 f7 d8             	neg    %rax
  80042034e1:	eb 04                	jmp    80042034e7 <strtol+0x190>
  80042034e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  80042034e7:	c9                   	leaveq 
  80042034e8:	c3                   	retq   

00000080042034e9 <strstr>:

char * strstr(const char *in, const char *str)
{
  80042034e9:	55                   	push   %rbp
  80042034ea:	48 89 e5             	mov    %rsp,%rbp
  80042034ed:	48 83 ec 30          	sub    $0x30,%rsp
  80042034f1:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80042034f5:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	char c;
	size_t len;

	c = *str++;
  80042034f9:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042034fd:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203501:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  8004203505:	0f b6 00             	movzbl (%rax),%eax
  8004203508:	88 45 ff             	mov    %al,-0x1(%rbp)
	if (!c)
  800420350b:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  800420350f:	75 06                	jne    8004203517 <strstr+0x2e>
		return (char *) in;	// Trivial empty string case
  8004203511:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203515:	eb 6b                	jmp    8004203582 <strstr+0x99>

	len = strlen(str);
  8004203517:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420351b:	48 89 c7             	mov    %rax,%rdi
  800420351e:	48 b8 bf 2d 20 04 80 	movabs $0x8004202dbf,%rax
  8004203525:	00 00 00 
  8004203528:	ff d0                	callq  *%rax
  800420352a:	48 98                	cltq   
  800420352c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	do {
		char sc;

		do {
			sc = *in++;
  8004203530:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203534:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203538:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800420353c:	0f b6 00             	movzbl (%rax),%eax
  800420353f:	88 45 ef             	mov    %al,-0x11(%rbp)
			if (!sc)
  8004203542:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  8004203546:	75 07                	jne    800420354f <strstr+0x66>
				return (char *) 0;
  8004203548:	b8 00 00 00 00       	mov    $0x0,%eax
  800420354d:	eb 33                	jmp    8004203582 <strstr+0x99>
		} while (sc != c);
  800420354f:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  8004203553:	3a 45 ff             	cmp    -0x1(%rbp),%al
  8004203556:	75 d8                	jne    8004203530 <strstr+0x47>
	} while (strncmp(in, str, len) != 0);
  8004203558:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420355c:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  8004203560:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203564:	48 89 ce             	mov    %rcx,%rsi
  8004203567:	48 89 c7             	mov    %rax,%rdi
  800420356a:	48 b8 e0 2f 20 04 80 	movabs $0x8004202fe0,%rax
  8004203571:	00 00 00 
  8004203574:	ff d0                	callq  *%rax
  8004203576:	85 c0                	test   %eax,%eax
  8004203578:	75 b6                	jne    8004203530 <strstr+0x47>

	return (char *) (in - 1);
  800420357a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420357e:	48 83 e8 01          	sub    $0x1,%rax
}
  8004203582:	c9                   	leaveq 
  8004203583:	c3                   	retq   

0000008004203584 <_dwarf_read_lsb>:
Dwarf_Section *
_dwarf_find_section(const char *name);

uint64_t
_dwarf_read_lsb(uint8_t *data, uint64_t *offsetp, int bytes_to_read)
{
  8004203584:	55                   	push   %rbp
  8004203585:	48 89 e5             	mov    %rsp,%rbp
  8004203588:	48 83 ec 24          	sub    $0x24,%rsp
  800420358c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004203590:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004203594:	89 55 dc             	mov    %edx,-0x24(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = data + *offsetp;
  8004203597:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420359b:	48 8b 10             	mov    (%rax),%rdx
  800420359e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042035a2:	48 01 d0             	add    %rdx,%rax
  80042035a5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  80042035a9:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042035b0:	00 
	switch (bytes_to_read) {
  80042035b1:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80042035b4:	83 f8 02             	cmp    $0x2,%eax
  80042035b7:	0f 84 ab 00 00 00    	je     8004203668 <_dwarf_read_lsb+0xe4>
  80042035bd:	83 f8 02             	cmp    $0x2,%eax
  80042035c0:	7f 0e                	jg     80042035d0 <_dwarf_read_lsb+0x4c>
  80042035c2:	83 f8 01             	cmp    $0x1,%eax
  80042035c5:	0f 84 b3 00 00 00    	je     800420367e <_dwarf_read_lsb+0xfa>
  80042035cb:	e9 d9 00 00 00       	jmpq   80042036a9 <_dwarf_read_lsb+0x125>
  80042035d0:	83 f8 04             	cmp    $0x4,%eax
  80042035d3:	74 65                	je     800420363a <_dwarf_read_lsb+0xb6>
  80042035d5:	83 f8 08             	cmp    $0x8,%eax
  80042035d8:	0f 85 cb 00 00 00    	jne    80042036a9 <_dwarf_read_lsb+0x125>
	case 8:
		ret |= ((uint64_t) src[4]) << 32 | ((uint64_t) src[5]) << 40;
  80042035de:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042035e2:	48 83 c0 04          	add    $0x4,%rax
  80042035e6:	0f b6 00             	movzbl (%rax),%eax
  80042035e9:	0f b6 c0             	movzbl %al,%eax
  80042035ec:	48 c1 e0 20          	shl    $0x20,%rax
  80042035f0:	48 89 c2             	mov    %rax,%rdx
  80042035f3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042035f7:	48 83 c0 05          	add    $0x5,%rax
  80042035fb:	0f b6 00             	movzbl (%rax),%eax
  80042035fe:	0f b6 c0             	movzbl %al,%eax
  8004203601:	48 c1 e0 28          	shl    $0x28,%rax
  8004203605:	48 09 d0             	or     %rdx,%rax
  8004203608:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[6]) << 48 | ((uint64_t) src[7]) << 56;
  800420360c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203610:	48 83 c0 06          	add    $0x6,%rax
  8004203614:	0f b6 00             	movzbl (%rax),%eax
  8004203617:	0f b6 c0             	movzbl %al,%eax
  800420361a:	48 c1 e0 30          	shl    $0x30,%rax
  800420361e:	48 89 c2             	mov    %rax,%rdx
  8004203621:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203625:	48 83 c0 07          	add    $0x7,%rax
  8004203629:	0f b6 00             	movzbl (%rax),%eax
  800420362c:	0f b6 c0             	movzbl %al,%eax
  800420362f:	48 c1 e0 38          	shl    $0x38,%rax
  8004203633:	48 09 d0             	or     %rdx,%rax
  8004203636:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 4:
		ret |= ((uint64_t) src[2]) << 16 | ((uint64_t) src[3]) << 24;
  800420363a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420363e:	48 83 c0 02          	add    $0x2,%rax
  8004203642:	0f b6 00             	movzbl (%rax),%eax
  8004203645:	0f b6 c0             	movzbl %al,%eax
  8004203648:	48 c1 e0 10          	shl    $0x10,%rax
  800420364c:	48 89 c2             	mov    %rax,%rdx
  800420364f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203653:	48 83 c0 03          	add    $0x3,%rax
  8004203657:	0f b6 00             	movzbl (%rax),%eax
  800420365a:	0f b6 c0             	movzbl %al,%eax
  800420365d:	48 c1 e0 18          	shl    $0x18,%rax
  8004203661:	48 09 d0             	or     %rdx,%rax
  8004203664:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 2:
		ret |= ((uint64_t) src[1]) << 8;
  8004203668:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420366c:	48 83 c0 01          	add    $0x1,%rax
  8004203670:	0f b6 00             	movzbl (%rax),%eax
  8004203673:	0f b6 c0             	movzbl %al,%eax
  8004203676:	48 c1 e0 08          	shl    $0x8,%rax
  800420367a:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 1:
		ret |= src[0];
  800420367e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203682:	0f b6 00             	movzbl (%rax),%eax
  8004203685:	0f b6 c0             	movzbl %al,%eax
  8004203688:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  800420368c:	90                   	nop
	default:
		return (0);
	}

	*offsetp += bytes_to_read;
  800420368d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203691:	48 8b 10             	mov    (%rax),%rdx
  8004203694:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004203697:	48 98                	cltq   
  8004203699:	48 01 c2             	add    %rax,%rdx
  800420369c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042036a0:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  80042036a3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042036a7:	eb 05                	jmp    80042036ae <_dwarf_read_lsb+0x12a>
		ret |= ((uint64_t) src[1]) << 8;
	case 1:
		ret |= src[0];
		break;
	default:
		return (0);
  80042036a9:	b8 00 00 00 00       	mov    $0x0,%eax
	}

	*offsetp += bytes_to_read;

	return (ret);
}
  80042036ae:	c9                   	leaveq 
  80042036af:	c3                   	retq   

00000080042036b0 <_dwarf_decode_lsb>:

uint64_t
_dwarf_decode_lsb(uint8_t **data, int bytes_to_read)
{
  80042036b0:	55                   	push   %rbp
  80042036b1:	48 89 e5             	mov    %rsp,%rbp
  80042036b4:	48 83 ec 1c          	sub    $0x1c,%rsp
  80042036b8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042036bc:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = *data;
  80042036bf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042036c3:	48 8b 00             	mov    (%rax),%rax
  80042036c6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  80042036ca:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042036d1:	00 
	switch (bytes_to_read) {
  80042036d2:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042036d5:	83 f8 02             	cmp    $0x2,%eax
  80042036d8:	0f 84 ab 00 00 00    	je     8004203789 <_dwarf_decode_lsb+0xd9>
  80042036de:	83 f8 02             	cmp    $0x2,%eax
  80042036e1:	7f 0e                	jg     80042036f1 <_dwarf_decode_lsb+0x41>
  80042036e3:	83 f8 01             	cmp    $0x1,%eax
  80042036e6:	0f 84 b3 00 00 00    	je     800420379f <_dwarf_decode_lsb+0xef>
  80042036ec:	e9 d9 00 00 00       	jmpq   80042037ca <_dwarf_decode_lsb+0x11a>
  80042036f1:	83 f8 04             	cmp    $0x4,%eax
  80042036f4:	74 65                	je     800420375b <_dwarf_decode_lsb+0xab>
  80042036f6:	83 f8 08             	cmp    $0x8,%eax
  80042036f9:	0f 85 cb 00 00 00    	jne    80042037ca <_dwarf_decode_lsb+0x11a>
	case 8:
		ret |= ((uint64_t) src[4]) << 32 | ((uint64_t) src[5]) << 40;
  80042036ff:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203703:	48 83 c0 04          	add    $0x4,%rax
  8004203707:	0f b6 00             	movzbl (%rax),%eax
  800420370a:	0f b6 c0             	movzbl %al,%eax
  800420370d:	48 c1 e0 20          	shl    $0x20,%rax
  8004203711:	48 89 c2             	mov    %rax,%rdx
  8004203714:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203718:	48 83 c0 05          	add    $0x5,%rax
  800420371c:	0f b6 00             	movzbl (%rax),%eax
  800420371f:	0f b6 c0             	movzbl %al,%eax
  8004203722:	48 c1 e0 28          	shl    $0x28,%rax
  8004203726:	48 09 d0             	or     %rdx,%rax
  8004203729:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[6]) << 48 | ((uint64_t) src[7]) << 56;
  800420372d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203731:	48 83 c0 06          	add    $0x6,%rax
  8004203735:	0f b6 00             	movzbl (%rax),%eax
  8004203738:	0f b6 c0             	movzbl %al,%eax
  800420373b:	48 c1 e0 30          	shl    $0x30,%rax
  800420373f:	48 89 c2             	mov    %rax,%rdx
  8004203742:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203746:	48 83 c0 07          	add    $0x7,%rax
  800420374a:	0f b6 00             	movzbl (%rax),%eax
  800420374d:	0f b6 c0             	movzbl %al,%eax
  8004203750:	48 c1 e0 38          	shl    $0x38,%rax
  8004203754:	48 09 d0             	or     %rdx,%rax
  8004203757:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 4:
		ret |= ((uint64_t) src[2]) << 16 | ((uint64_t) src[3]) << 24;
  800420375b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420375f:	48 83 c0 02          	add    $0x2,%rax
  8004203763:	0f b6 00             	movzbl (%rax),%eax
  8004203766:	0f b6 c0             	movzbl %al,%eax
  8004203769:	48 c1 e0 10          	shl    $0x10,%rax
  800420376d:	48 89 c2             	mov    %rax,%rdx
  8004203770:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203774:	48 83 c0 03          	add    $0x3,%rax
  8004203778:	0f b6 00             	movzbl (%rax),%eax
  800420377b:	0f b6 c0             	movzbl %al,%eax
  800420377e:	48 c1 e0 18          	shl    $0x18,%rax
  8004203782:	48 09 d0             	or     %rdx,%rax
  8004203785:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 2:
		ret |= ((uint64_t) src[1]) << 8;
  8004203789:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420378d:	48 83 c0 01          	add    $0x1,%rax
  8004203791:	0f b6 00             	movzbl (%rax),%eax
  8004203794:	0f b6 c0             	movzbl %al,%eax
  8004203797:	48 c1 e0 08          	shl    $0x8,%rax
  800420379b:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 1:
		ret |= src[0];
  800420379f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042037a3:	0f b6 00             	movzbl (%rax),%eax
  80042037a6:	0f b6 c0             	movzbl %al,%eax
  80042037a9:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  80042037ad:	90                   	nop
	default:
		return (0);
	}

	*data += bytes_to_read;
  80042037ae:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042037b2:	48 8b 10             	mov    (%rax),%rdx
  80042037b5:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042037b8:	48 98                	cltq   
  80042037ba:	48 01 c2             	add    %rax,%rdx
  80042037bd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042037c1:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  80042037c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042037c8:	eb 05                	jmp    80042037cf <_dwarf_decode_lsb+0x11f>
		ret |= ((uint64_t) src[1]) << 8;
	case 1:
		ret |= src[0];
		break;
	default:
		return (0);
  80042037ca:	b8 00 00 00 00       	mov    $0x0,%eax
	}

	*data += bytes_to_read;

	return (ret);
}
  80042037cf:	c9                   	leaveq 
  80042037d0:	c3                   	retq   

00000080042037d1 <_dwarf_read_msb>:

uint64_t
_dwarf_read_msb(uint8_t *data, uint64_t *offsetp, int bytes_to_read)
{
  80042037d1:	55                   	push   %rbp
  80042037d2:	48 89 e5             	mov    %rsp,%rbp
  80042037d5:	48 83 ec 24          	sub    $0x24,%rsp
  80042037d9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042037dd:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80042037e1:	89 55 dc             	mov    %edx,-0x24(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = data + *offsetp;
  80042037e4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042037e8:	48 8b 10             	mov    (%rax),%rdx
  80042037eb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042037ef:	48 01 d0             	add    %rdx,%rax
  80042037f2:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	switch (bytes_to_read) {
  80042037f6:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80042037f9:	83 f8 02             	cmp    $0x2,%eax
  80042037fc:	74 35                	je     8004203833 <_dwarf_read_msb+0x62>
  80042037fe:	83 f8 02             	cmp    $0x2,%eax
  8004203801:	7f 0a                	jg     800420380d <_dwarf_read_msb+0x3c>
  8004203803:	83 f8 01             	cmp    $0x1,%eax
  8004203806:	74 18                	je     8004203820 <_dwarf_read_msb+0x4f>
  8004203808:	e9 53 01 00 00       	jmpq   8004203960 <_dwarf_read_msb+0x18f>
  800420380d:	83 f8 04             	cmp    $0x4,%eax
  8004203810:	74 49                	je     800420385b <_dwarf_read_msb+0x8a>
  8004203812:	83 f8 08             	cmp    $0x8,%eax
  8004203815:	0f 84 96 00 00 00    	je     80042038b1 <_dwarf_read_msb+0xe0>
  800420381b:	e9 40 01 00 00       	jmpq   8004203960 <_dwarf_read_msb+0x18f>
	case 1:
		ret = src[0];
  8004203820:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203824:	0f b6 00             	movzbl (%rax),%eax
  8004203827:	0f b6 c0             	movzbl %al,%eax
  800420382a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  800420382e:	e9 34 01 00 00       	jmpq   8004203967 <_dwarf_read_msb+0x196>
	case 2:
		ret = src[1] | ((uint64_t) src[0]) << 8;
  8004203833:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203837:	48 83 c0 01          	add    $0x1,%rax
  800420383b:	0f b6 00             	movzbl (%rax),%eax
  800420383e:	0f b6 d0             	movzbl %al,%edx
  8004203841:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203845:	0f b6 00             	movzbl (%rax),%eax
  8004203848:	0f b6 c0             	movzbl %al,%eax
  800420384b:	48 c1 e0 08          	shl    $0x8,%rax
  800420384f:	48 09 d0             	or     %rdx,%rax
  8004203852:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  8004203856:	e9 0c 01 00 00       	jmpq   8004203967 <_dwarf_read_msb+0x196>
	case 4:
		ret = src[3] | ((uint64_t) src[2]) << 8;
  800420385b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420385f:	48 83 c0 03          	add    $0x3,%rax
  8004203863:	0f b6 00             	movzbl (%rax),%eax
  8004203866:	0f b6 c0             	movzbl %al,%eax
  8004203869:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420386d:	48 83 c2 02          	add    $0x2,%rdx
  8004203871:	0f b6 12             	movzbl (%rdx),%edx
  8004203874:	0f b6 d2             	movzbl %dl,%edx
  8004203877:	48 c1 e2 08          	shl    $0x8,%rdx
  800420387b:	48 09 d0             	or     %rdx,%rax
  800420387e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 16 | ((uint64_t) src[0]) << 24;
  8004203882:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203886:	48 83 c0 01          	add    $0x1,%rax
  800420388a:	0f b6 00             	movzbl (%rax),%eax
  800420388d:	0f b6 c0             	movzbl %al,%eax
  8004203890:	48 c1 e0 10          	shl    $0x10,%rax
  8004203894:	48 89 c2             	mov    %rax,%rdx
  8004203897:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420389b:	0f b6 00             	movzbl (%rax),%eax
  800420389e:	0f b6 c0             	movzbl %al,%eax
  80042038a1:	48 c1 e0 18          	shl    $0x18,%rax
  80042038a5:	48 09 d0             	or     %rdx,%rax
  80042038a8:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  80042038ac:	e9 b6 00 00 00       	jmpq   8004203967 <_dwarf_read_msb+0x196>
	case 8:
		ret = src[7] | ((uint64_t) src[6]) << 8;
  80042038b1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042038b5:	48 83 c0 07          	add    $0x7,%rax
  80042038b9:	0f b6 00             	movzbl (%rax),%eax
  80042038bc:	0f b6 c0             	movzbl %al,%eax
  80042038bf:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80042038c3:	48 83 c2 06          	add    $0x6,%rdx
  80042038c7:	0f b6 12             	movzbl (%rdx),%edx
  80042038ca:	0f b6 d2             	movzbl %dl,%edx
  80042038cd:	48 c1 e2 08          	shl    $0x8,%rdx
  80042038d1:	48 09 d0             	or     %rdx,%rax
  80042038d4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[5]) << 16 | ((uint64_t) src[4]) << 24;
  80042038d8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042038dc:	48 83 c0 05          	add    $0x5,%rax
  80042038e0:	0f b6 00             	movzbl (%rax),%eax
  80042038e3:	0f b6 c0             	movzbl %al,%eax
  80042038e6:	48 c1 e0 10          	shl    $0x10,%rax
  80042038ea:	48 89 c2             	mov    %rax,%rdx
  80042038ed:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042038f1:	48 83 c0 04          	add    $0x4,%rax
  80042038f5:	0f b6 00             	movzbl (%rax),%eax
  80042038f8:	0f b6 c0             	movzbl %al,%eax
  80042038fb:	48 c1 e0 18          	shl    $0x18,%rax
  80042038ff:	48 09 d0             	or     %rdx,%rax
  8004203902:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[3]) << 32 | ((uint64_t) src[2]) << 40;
  8004203906:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420390a:	48 83 c0 03          	add    $0x3,%rax
  800420390e:	0f b6 00             	movzbl (%rax),%eax
  8004203911:	0f b6 c0             	movzbl %al,%eax
  8004203914:	48 c1 e0 20          	shl    $0x20,%rax
  8004203918:	48 89 c2             	mov    %rax,%rdx
  800420391b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420391f:	48 83 c0 02          	add    $0x2,%rax
  8004203923:	0f b6 00             	movzbl (%rax),%eax
  8004203926:	0f b6 c0             	movzbl %al,%eax
  8004203929:	48 c1 e0 28          	shl    $0x28,%rax
  800420392d:	48 09 d0             	or     %rdx,%rax
  8004203930:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 48 | ((uint64_t) src[0]) << 56;
  8004203934:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203938:	48 83 c0 01          	add    $0x1,%rax
  800420393c:	0f b6 00             	movzbl (%rax),%eax
  800420393f:	0f b6 c0             	movzbl %al,%eax
  8004203942:	48 c1 e0 30          	shl    $0x30,%rax
  8004203946:	48 89 c2             	mov    %rax,%rdx
  8004203949:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420394d:	0f b6 00             	movzbl (%rax),%eax
  8004203950:	0f b6 c0             	movzbl %al,%eax
  8004203953:	48 c1 e0 38          	shl    $0x38,%rax
  8004203957:	48 09 d0             	or     %rdx,%rax
  800420395a:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  800420395e:	eb 07                	jmp    8004203967 <_dwarf_read_msb+0x196>
	default:
		return (0);
  8004203960:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203965:	eb 1a                	jmp    8004203981 <_dwarf_read_msb+0x1b0>
	}

	*offsetp += bytes_to_read;
  8004203967:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420396b:	48 8b 10             	mov    (%rax),%rdx
  800420396e:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004203971:	48 98                	cltq   
  8004203973:	48 01 c2             	add    %rax,%rdx
  8004203976:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420397a:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  800420397d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203981:	c9                   	leaveq 
  8004203982:	c3                   	retq   

0000008004203983 <_dwarf_decode_msb>:

uint64_t
_dwarf_decode_msb(uint8_t **data, int bytes_to_read)
{
  8004203983:	55                   	push   %rbp
  8004203984:	48 89 e5             	mov    %rsp,%rbp
  8004203987:	48 83 ec 1c          	sub    $0x1c,%rsp
  800420398b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420398f:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = *data;
  8004203992:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203996:	48 8b 00             	mov    (%rax),%rax
  8004203999:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  800420399d:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042039a4:	00 
	switch (bytes_to_read) {
  80042039a5:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042039a8:	83 f8 02             	cmp    $0x2,%eax
  80042039ab:	74 35                	je     80042039e2 <_dwarf_decode_msb+0x5f>
  80042039ad:	83 f8 02             	cmp    $0x2,%eax
  80042039b0:	7f 0a                	jg     80042039bc <_dwarf_decode_msb+0x39>
  80042039b2:	83 f8 01             	cmp    $0x1,%eax
  80042039b5:	74 18                	je     80042039cf <_dwarf_decode_msb+0x4c>
  80042039b7:	e9 53 01 00 00       	jmpq   8004203b0f <_dwarf_decode_msb+0x18c>
  80042039bc:	83 f8 04             	cmp    $0x4,%eax
  80042039bf:	74 49                	je     8004203a0a <_dwarf_decode_msb+0x87>
  80042039c1:	83 f8 08             	cmp    $0x8,%eax
  80042039c4:	0f 84 96 00 00 00    	je     8004203a60 <_dwarf_decode_msb+0xdd>
  80042039ca:	e9 40 01 00 00       	jmpq   8004203b0f <_dwarf_decode_msb+0x18c>
	case 1:
		ret = src[0];
  80042039cf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042039d3:	0f b6 00             	movzbl (%rax),%eax
  80042039d6:	0f b6 c0             	movzbl %al,%eax
  80042039d9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  80042039dd:	e9 34 01 00 00       	jmpq   8004203b16 <_dwarf_decode_msb+0x193>
	case 2:
		ret = src[1] | ((uint64_t) src[0]) << 8;
  80042039e2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042039e6:	48 83 c0 01          	add    $0x1,%rax
  80042039ea:	0f b6 00             	movzbl (%rax),%eax
  80042039ed:	0f b6 d0             	movzbl %al,%edx
  80042039f0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042039f4:	0f b6 00             	movzbl (%rax),%eax
  80042039f7:	0f b6 c0             	movzbl %al,%eax
  80042039fa:	48 c1 e0 08          	shl    $0x8,%rax
  80042039fe:	48 09 d0             	or     %rdx,%rax
  8004203a01:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  8004203a05:	e9 0c 01 00 00       	jmpq   8004203b16 <_dwarf_decode_msb+0x193>
	case 4:
		ret = src[3] | ((uint64_t) src[2]) << 8;
  8004203a0a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203a0e:	48 83 c0 03          	add    $0x3,%rax
  8004203a12:	0f b6 00             	movzbl (%rax),%eax
  8004203a15:	0f b6 c0             	movzbl %al,%eax
  8004203a18:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004203a1c:	48 83 c2 02          	add    $0x2,%rdx
  8004203a20:	0f b6 12             	movzbl (%rdx),%edx
  8004203a23:	0f b6 d2             	movzbl %dl,%edx
  8004203a26:	48 c1 e2 08          	shl    $0x8,%rdx
  8004203a2a:	48 09 d0             	or     %rdx,%rax
  8004203a2d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 16 | ((uint64_t) src[0]) << 24;
  8004203a31:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203a35:	48 83 c0 01          	add    $0x1,%rax
  8004203a39:	0f b6 00             	movzbl (%rax),%eax
  8004203a3c:	0f b6 c0             	movzbl %al,%eax
  8004203a3f:	48 c1 e0 10          	shl    $0x10,%rax
  8004203a43:	48 89 c2             	mov    %rax,%rdx
  8004203a46:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203a4a:	0f b6 00             	movzbl (%rax),%eax
  8004203a4d:	0f b6 c0             	movzbl %al,%eax
  8004203a50:	48 c1 e0 18          	shl    $0x18,%rax
  8004203a54:	48 09 d0             	or     %rdx,%rax
  8004203a57:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004203a5b:	e9 b6 00 00 00       	jmpq   8004203b16 <_dwarf_decode_msb+0x193>
	case 8:
		ret = src[7] | ((uint64_t) src[6]) << 8;
  8004203a60:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203a64:	48 83 c0 07          	add    $0x7,%rax
  8004203a68:	0f b6 00             	movzbl (%rax),%eax
  8004203a6b:	0f b6 c0             	movzbl %al,%eax
  8004203a6e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004203a72:	48 83 c2 06          	add    $0x6,%rdx
  8004203a76:	0f b6 12             	movzbl (%rdx),%edx
  8004203a79:	0f b6 d2             	movzbl %dl,%edx
  8004203a7c:	48 c1 e2 08          	shl    $0x8,%rdx
  8004203a80:	48 09 d0             	or     %rdx,%rax
  8004203a83:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[5]) << 16 | ((uint64_t) src[4]) << 24;
  8004203a87:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203a8b:	48 83 c0 05          	add    $0x5,%rax
  8004203a8f:	0f b6 00             	movzbl (%rax),%eax
  8004203a92:	0f b6 c0             	movzbl %al,%eax
  8004203a95:	48 c1 e0 10          	shl    $0x10,%rax
  8004203a99:	48 89 c2             	mov    %rax,%rdx
  8004203a9c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203aa0:	48 83 c0 04          	add    $0x4,%rax
  8004203aa4:	0f b6 00             	movzbl (%rax),%eax
  8004203aa7:	0f b6 c0             	movzbl %al,%eax
  8004203aaa:	48 c1 e0 18          	shl    $0x18,%rax
  8004203aae:	48 09 d0             	or     %rdx,%rax
  8004203ab1:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[3]) << 32 | ((uint64_t) src[2]) << 40;
  8004203ab5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203ab9:	48 83 c0 03          	add    $0x3,%rax
  8004203abd:	0f b6 00             	movzbl (%rax),%eax
  8004203ac0:	0f b6 c0             	movzbl %al,%eax
  8004203ac3:	48 c1 e0 20          	shl    $0x20,%rax
  8004203ac7:	48 89 c2             	mov    %rax,%rdx
  8004203aca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203ace:	48 83 c0 02          	add    $0x2,%rax
  8004203ad2:	0f b6 00             	movzbl (%rax),%eax
  8004203ad5:	0f b6 c0             	movzbl %al,%eax
  8004203ad8:	48 c1 e0 28          	shl    $0x28,%rax
  8004203adc:	48 09 d0             	or     %rdx,%rax
  8004203adf:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 48 | ((uint64_t) src[0]) << 56;
  8004203ae3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203ae7:	48 83 c0 01          	add    $0x1,%rax
  8004203aeb:	0f b6 00             	movzbl (%rax),%eax
  8004203aee:	0f b6 c0             	movzbl %al,%eax
  8004203af1:	48 c1 e0 30          	shl    $0x30,%rax
  8004203af5:	48 89 c2             	mov    %rax,%rdx
  8004203af8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004203afc:	0f b6 00             	movzbl (%rax),%eax
  8004203aff:	0f b6 c0             	movzbl %al,%eax
  8004203b02:	48 c1 e0 38          	shl    $0x38,%rax
  8004203b06:	48 09 d0             	or     %rdx,%rax
  8004203b09:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004203b0d:	eb 07                	jmp    8004203b16 <_dwarf_decode_msb+0x193>
	default:
		return (0);
  8004203b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203b14:	eb 1a                	jmp    8004203b30 <_dwarf_decode_msb+0x1ad>
		break;
	}

	*data += bytes_to_read;
  8004203b16:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203b1a:	48 8b 10             	mov    (%rax),%rdx
  8004203b1d:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004203b20:	48 98                	cltq   
  8004203b22:	48 01 c2             	add    %rax,%rdx
  8004203b25:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203b29:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004203b2c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203b30:	c9                   	leaveq 
  8004203b31:	c3                   	retq   

0000008004203b32 <_dwarf_read_sleb128>:

int64_t
_dwarf_read_sleb128(uint8_t *data, uint64_t *offsetp)
{
  8004203b32:	55                   	push   %rbp
  8004203b33:	48 89 e5             	mov    %rsp,%rbp
  8004203b36:	48 83 ec 30          	sub    $0x30,%rsp
  8004203b3a:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004203b3e:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int64_t ret = 0;
  8004203b42:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004203b49:	00 
	uint8_t b;
	int shift = 0;
  8004203b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	uint8_t *src;

	src = data + *offsetp;
  8004203b51:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203b55:	48 8b 10             	mov    (%rax),%rdx
  8004203b58:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203b5c:	48 01 d0             	add    %rdx,%rax
  8004203b5f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004203b63:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203b67:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203b6b:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004203b6f:	0f b6 00             	movzbl (%rax),%eax
  8004203b72:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004203b75:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203b79:	83 e0 7f             	and    $0x7f,%eax
  8004203b7c:	89 c2                	mov    %eax,%edx
  8004203b7e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203b81:	89 c1                	mov    %eax,%ecx
  8004203b83:	d3 e2                	shl    %cl,%edx
  8004203b85:	89 d0                	mov    %edx,%eax
  8004203b87:	48 98                	cltq   
  8004203b89:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		(*offsetp)++;
  8004203b8d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203b91:	48 8b 00             	mov    (%rax),%rax
  8004203b94:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203b98:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203b9c:	48 89 10             	mov    %rdx,(%rax)
		shift += 7;
  8004203b9f:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004203ba3:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203ba7:	84 c0                	test   %al,%al
  8004203ba9:	78 b8                	js     8004203b63 <_dwarf_read_sleb128+0x31>

	if (shift < 32 && (b & 0x40) != 0)
  8004203bab:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004203baf:	7f 1f                	jg     8004203bd0 <_dwarf_read_sleb128+0x9e>
  8004203bb1:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203bb5:	83 e0 40             	and    $0x40,%eax
  8004203bb8:	85 c0                	test   %eax,%eax
  8004203bba:	74 14                	je     8004203bd0 <_dwarf_read_sleb128+0x9e>
		ret |= (-1 << shift);
  8004203bbc:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203bbf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8004203bc4:	89 c1                	mov    %eax,%ecx
  8004203bc6:	d3 e2                	shl    %cl,%edx
  8004203bc8:	89 d0                	mov    %edx,%eax
  8004203bca:	48 98                	cltq   
  8004203bcc:	48 09 45 f8          	or     %rax,-0x8(%rbp)

	return (ret);
  8004203bd0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203bd4:	c9                   	leaveq 
  8004203bd5:	c3                   	retq   

0000008004203bd6 <_dwarf_read_uleb128>:

uint64_t
_dwarf_read_uleb128(uint8_t *data, uint64_t *offsetp)
{
  8004203bd6:	55                   	push   %rbp
  8004203bd7:	48 89 e5             	mov    %rsp,%rbp
  8004203bda:	48 83 ec 30          	sub    $0x30,%rsp
  8004203bde:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004203be2:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	uint64_t ret = 0;
  8004203be6:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004203bed:	00 
	uint8_t b;
	int shift = 0;
  8004203bee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	uint8_t *src;

	src = data + *offsetp;
  8004203bf5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203bf9:	48 8b 10             	mov    (%rax),%rdx
  8004203bfc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203c00:	48 01 d0             	add    %rdx,%rax
  8004203c03:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004203c07:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203c0b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203c0f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004203c13:	0f b6 00             	movzbl (%rax),%eax
  8004203c16:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004203c19:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203c1d:	83 e0 7f             	and    $0x7f,%eax
  8004203c20:	89 c2                	mov    %eax,%edx
  8004203c22:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203c25:	89 c1                	mov    %eax,%ecx
  8004203c27:	d3 e2                	shl    %cl,%edx
  8004203c29:	89 d0                	mov    %edx,%eax
  8004203c2b:	48 98                	cltq   
  8004203c2d:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		(*offsetp)++;
  8004203c31:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203c35:	48 8b 00             	mov    (%rax),%rax
  8004203c38:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203c3c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203c40:	48 89 10             	mov    %rdx,(%rax)
		shift += 7;
  8004203c43:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004203c47:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203c4b:	84 c0                	test   %al,%al
  8004203c4d:	78 b8                	js     8004203c07 <_dwarf_read_uleb128+0x31>

	return (ret);
  8004203c4f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203c53:	c9                   	leaveq 
  8004203c54:	c3                   	retq   

0000008004203c55 <_dwarf_decode_sleb128>:

int64_t
_dwarf_decode_sleb128(uint8_t **dp)
{
  8004203c55:	55                   	push   %rbp
  8004203c56:	48 89 e5             	mov    %rsp,%rbp
  8004203c59:	48 83 ec 28          	sub    $0x28,%rsp
  8004203c5d:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
	int64_t ret = 0;
  8004203c61:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004203c68:	00 
	uint8_t b;
	int shift = 0;
  8004203c69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)

	uint8_t *src = *dp;
  8004203c70:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203c74:	48 8b 00             	mov    (%rax),%rax
  8004203c77:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004203c7b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203c7f:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203c83:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004203c87:	0f b6 00             	movzbl (%rax),%eax
  8004203c8a:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004203c8d:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203c91:	83 e0 7f             	and    $0x7f,%eax
  8004203c94:	89 c2                	mov    %eax,%edx
  8004203c96:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203c99:	89 c1                	mov    %eax,%ecx
  8004203c9b:	d3 e2                	shl    %cl,%edx
  8004203c9d:	89 d0                	mov    %edx,%eax
  8004203c9f:	48 98                	cltq   
  8004203ca1:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		shift += 7;
  8004203ca5:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004203ca9:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203cad:	84 c0                	test   %al,%al
  8004203caf:	78 ca                	js     8004203c7b <_dwarf_decode_sleb128+0x26>

	if (shift < 32 && (b & 0x40) != 0)
  8004203cb1:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004203cb5:	7f 1f                	jg     8004203cd6 <_dwarf_decode_sleb128+0x81>
  8004203cb7:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203cbb:	83 e0 40             	and    $0x40,%eax
  8004203cbe:	85 c0                	test   %eax,%eax
  8004203cc0:	74 14                	je     8004203cd6 <_dwarf_decode_sleb128+0x81>
		ret |= (-1 << shift);
  8004203cc2:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203cc5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8004203cca:	89 c1                	mov    %eax,%ecx
  8004203ccc:	d3 e2                	shl    %cl,%edx
  8004203cce:	89 d0                	mov    %edx,%eax
  8004203cd0:	48 98                	cltq   
  8004203cd2:	48 09 45 f8          	or     %rax,-0x8(%rbp)

	*dp = src;
  8004203cd6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203cda:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004203cde:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004203ce1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203ce5:	c9                   	leaveq 
  8004203ce6:	c3                   	retq   

0000008004203ce7 <_dwarf_decode_uleb128>:

uint64_t
_dwarf_decode_uleb128(uint8_t **dp)
{
  8004203ce7:	55                   	push   %rbp
  8004203ce8:	48 89 e5             	mov    %rsp,%rbp
  8004203ceb:	48 83 ec 28          	sub    $0x28,%rsp
  8004203cef:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
	uint64_t ret = 0;
  8004203cf3:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004203cfa:	00 
	uint8_t b;
	int shift = 0;
  8004203cfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)

	uint8_t *src = *dp;
  8004203d02:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203d06:	48 8b 00             	mov    (%rax),%rax
  8004203d09:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004203d0d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203d11:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203d15:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004203d19:	0f b6 00             	movzbl (%rax),%eax
  8004203d1c:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004203d1f:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203d23:	83 e0 7f             	and    $0x7f,%eax
  8004203d26:	89 c2                	mov    %eax,%edx
  8004203d28:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203d2b:	89 c1                	mov    %eax,%ecx
  8004203d2d:	d3 e2                	shl    %cl,%edx
  8004203d2f:	89 d0                	mov    %edx,%eax
  8004203d31:	48 98                	cltq   
  8004203d33:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		shift += 7;
  8004203d37:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004203d3b:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004203d3f:	84 c0                	test   %al,%al
  8004203d41:	78 ca                	js     8004203d0d <_dwarf_decode_uleb128+0x26>

	*dp = src;
  8004203d43:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203d47:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004203d4b:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004203d4e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004203d52:	c9                   	leaveq 
  8004203d53:	c3                   	retq   

0000008004203d54 <_dwarf_read_string>:

#define Dwarf_Unsigned uint64_t

char *
_dwarf_read_string(void *data, Dwarf_Unsigned size, uint64_t *offsetp)
{
  8004203d54:	55                   	push   %rbp
  8004203d55:	48 89 e5             	mov    %rsp,%rbp
  8004203d58:	48 83 ec 28          	sub    $0x28,%rsp
  8004203d5c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004203d60:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004203d64:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	char *ret, *src;

	ret = src = (char *) data + *offsetp;
  8004203d68:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203d6c:	48 8b 10             	mov    (%rax),%rdx
  8004203d6f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203d73:	48 01 d0             	add    %rdx,%rax
  8004203d76:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203d7a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203d7e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	while (*src != '\0' && *offsetp < size) {
  8004203d82:	eb 17                	jmp    8004203d9b <_dwarf_read_string+0x47>
		src++;
  8004203d84:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
		(*offsetp)++;
  8004203d89:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203d8d:	48 8b 00             	mov    (%rax),%rax
  8004203d90:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203d94:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203d98:	48 89 10             	mov    %rdx,(%rax)
{
	char *ret, *src;

	ret = src = (char *) data + *offsetp;

	while (*src != '\0' && *offsetp < size) {
  8004203d9b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203d9f:	0f b6 00             	movzbl (%rax),%eax
  8004203da2:	84 c0                	test   %al,%al
  8004203da4:	74 0d                	je     8004203db3 <_dwarf_read_string+0x5f>
  8004203da6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203daa:	48 8b 00             	mov    (%rax),%rax
  8004203dad:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004203db1:	72 d1                	jb     8004203d84 <_dwarf_read_string+0x30>
		src++;
		(*offsetp)++;
	}

	if (*src == '\0' && *offsetp < size)
  8004203db3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203db7:	0f b6 00             	movzbl (%rax),%eax
  8004203dba:	84 c0                	test   %al,%al
  8004203dbc:	75 1f                	jne    8004203ddd <_dwarf_read_string+0x89>
  8004203dbe:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203dc2:	48 8b 00             	mov    (%rax),%rax
  8004203dc5:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004203dc9:	73 12                	jae    8004203ddd <_dwarf_read_string+0x89>
		(*offsetp)++;
  8004203dcb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203dcf:	48 8b 00             	mov    (%rax),%rax
  8004203dd2:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004203dd6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203dda:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004203ddd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004203de1:	c9                   	leaveq 
  8004203de2:	c3                   	retq   

0000008004203de3 <_dwarf_read_block>:

uint8_t *
_dwarf_read_block(void *data, uint64_t *offsetp, uint64_t length)
{
  8004203de3:	55                   	push   %rbp
  8004203de4:	48 89 e5             	mov    %rsp,%rbp
  8004203de7:	48 83 ec 28          	sub    $0x28,%rsp
  8004203deb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004203def:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004203df3:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	uint8_t *ret, *src;

	ret = src = (uint8_t *) data + *offsetp;
  8004203df7:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203dfb:	48 8b 10             	mov    (%rax),%rdx
  8004203dfe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203e02:	48 01 d0             	add    %rdx,%rax
  8004203e05:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203e09:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203e0d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	(*offsetp) += length;
  8004203e11:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203e15:	48 8b 10             	mov    (%rax),%rdx
  8004203e18:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203e1c:	48 01 c2             	add    %rax,%rdx
  8004203e1f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203e23:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004203e26:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004203e2a:	c9                   	leaveq 
  8004203e2b:	c3                   	retq   

0000008004203e2c <_dwarf_elf_get_byte_order>:

Dwarf_Endianness
_dwarf_elf_get_byte_order(void *obj)
{
  8004203e2c:	55                   	push   %rbp
  8004203e2d:	48 89 e5             	mov    %rsp,%rbp
  8004203e30:	48 83 ec 20          	sub    $0x20,%rsp
  8004203e34:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Elf *e;

	e = (Elf *)obj;
  8004203e38:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203e3c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(e != NULL);
  8004203e40:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004203e45:	75 35                	jne    8004203e7c <_dwarf_elf_get_byte_order+0x50>
  8004203e47:	48 b9 c0 9f 20 04 80 	movabs $0x8004209fc0,%rcx
  8004203e4e:	00 00 00 
  8004203e51:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004203e58:	00 00 00 
  8004203e5b:	be 29 01 00 00       	mov    $0x129,%esi
  8004203e60:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004203e67:	00 00 00 
  8004203e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203e6f:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004203e76:	00 00 00 
  8004203e79:	41 ff d0             	callq  *%r8

//TODO: Need to check for 64bit here. Because currently Elf header for
//      64bit doesn't have any memeber e_ident. But need to see what is
//      similar in 64bit.
	switch (e->e_ident[EI_DATA]) {
  8004203e7c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203e80:	0f b6 40 05          	movzbl 0x5(%rax),%eax
  8004203e84:	0f b6 c0             	movzbl %al,%eax
  8004203e87:	83 f8 02             	cmp    $0x2,%eax
  8004203e8a:	75 07                	jne    8004203e93 <_dwarf_elf_get_byte_order+0x67>
	case ELFDATA2MSB:
		return (DW_OBJECT_MSB);
  8004203e8c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203e91:	eb 05                	jmp    8004203e98 <_dwarf_elf_get_byte_order+0x6c>

	case ELFDATA2LSB:
	case ELFDATANONE:
	default:
		return (DW_OBJECT_LSB);
  8004203e93:	b8 01 00 00 00       	mov    $0x1,%eax
	}
}
  8004203e98:	c9                   	leaveq 
  8004203e99:	c3                   	retq   

0000008004203e9a <_dwarf_elf_get_pointer_size>:

Dwarf_Small
_dwarf_elf_get_pointer_size(void *obj)
{
  8004203e9a:	55                   	push   %rbp
  8004203e9b:	48 89 e5             	mov    %rsp,%rbp
  8004203e9e:	48 83 ec 20          	sub    $0x20,%rsp
  8004203ea2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Elf *e;

	e = (Elf *) obj;
  8004203ea6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203eaa:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(e != NULL);
  8004203eae:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004203eb3:	75 35                	jne    8004203eea <_dwarf_elf_get_pointer_size+0x50>
  8004203eb5:	48 b9 c0 9f 20 04 80 	movabs $0x8004209fc0,%rcx
  8004203ebc:	00 00 00 
  8004203ebf:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004203ec6:	00 00 00 
  8004203ec9:	be 3f 01 00 00       	mov    $0x13f,%esi
  8004203ece:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004203ed5:	00 00 00 
  8004203ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203edd:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004203ee4:	00 00 00 
  8004203ee7:	41 ff d0             	callq  *%r8

	if (e->e_ident[4] == ELFCLASS32)
  8004203eea:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203eee:	0f b6 40 04          	movzbl 0x4(%rax),%eax
  8004203ef2:	3c 01                	cmp    $0x1,%al
  8004203ef4:	75 07                	jne    8004203efd <_dwarf_elf_get_pointer_size+0x63>
		return (4);
  8004203ef6:	b8 04 00 00 00       	mov    $0x4,%eax
  8004203efb:	eb 05                	jmp    8004203f02 <_dwarf_elf_get_pointer_size+0x68>
	else
		return (8);
  8004203efd:	b8 08 00 00 00       	mov    $0x8,%eax
}
  8004203f02:	c9                   	leaveq 
  8004203f03:	c3                   	retq   

0000008004203f04 <_dwarf_init>:

//Return 0 on success
int _dwarf_init(Dwarf_Debug dbg, void *obj)
{
  8004203f04:	55                   	push   %rbp
  8004203f05:	48 89 e5             	mov    %rsp,%rbp
  8004203f08:	53                   	push   %rbx
  8004203f09:	48 83 ec 18          	sub    $0x18,%rsp
  8004203f0d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004203f11:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	memset(dbg, 0, sizeof(struct _Dwarf_Debug));
  8004203f15:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f19:	ba 60 00 00 00       	mov    $0x60,%edx
  8004203f1e:	be 00 00 00 00       	mov    $0x0,%esi
  8004203f23:	48 89 c7             	mov    %rax,%rdi
  8004203f26:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  8004203f2d:	00 00 00 
  8004203f30:	ff d0                	callq  *%rax
	dbg->curr_off_dbginfo = 0;
  8004203f32:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f36:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
	dbg->dbg_info_size = 0;
  8004203f3d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f41:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
  8004203f48:	00 
	dbg->dbg_pointer_size = _dwarf_elf_get_pointer_size(obj); 
  8004203f49:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203f4d:	48 89 c7             	mov    %rax,%rdi
  8004203f50:	48 b8 9a 3e 20 04 80 	movabs $0x8004203e9a,%rax
  8004203f57:	00 00 00 
  8004203f5a:	ff d0                	callq  *%rax
  8004203f5c:	0f b6 d0             	movzbl %al,%edx
  8004203f5f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f63:	89 50 28             	mov    %edx,0x28(%rax)

	if (_dwarf_elf_get_byte_order(obj) == DW_OBJECT_MSB) {
  8004203f66:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203f6a:	48 89 c7             	mov    %rax,%rdi
  8004203f6d:	48 b8 2c 3e 20 04 80 	movabs $0x8004203e2c,%rax
  8004203f74:	00 00 00 
  8004203f77:	ff d0                	callq  *%rax
  8004203f79:	85 c0                	test   %eax,%eax
  8004203f7b:	75 26                	jne    8004203fa3 <_dwarf_init+0x9f>
		dbg->read = _dwarf_read_msb;
  8004203f7d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f81:	48 b9 d1 37 20 04 80 	movabs $0x80042037d1,%rcx
  8004203f88:	00 00 00 
  8004203f8b:	48 89 48 18          	mov    %rcx,0x18(%rax)
		dbg->decode = _dwarf_decode_msb;
  8004203f8f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f93:	48 bb 83 39 20 04 80 	movabs $0x8004203983,%rbx
  8004203f9a:	00 00 00 
  8004203f9d:	48 89 58 20          	mov    %rbx,0x20(%rax)
  8004203fa1:	eb 24                	jmp    8004203fc7 <_dwarf_init+0xc3>
	} else {
		dbg->read = _dwarf_read_lsb;
  8004203fa3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203fa7:	48 b9 84 35 20 04 80 	movabs $0x8004203584,%rcx
  8004203fae:	00 00 00 
  8004203fb1:	48 89 48 18          	mov    %rcx,0x18(%rax)
		dbg->decode = _dwarf_decode_lsb;
  8004203fb5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203fb9:	48 be b0 36 20 04 80 	movabs $0x80042036b0,%rsi
  8004203fc0:	00 00 00 
  8004203fc3:	48 89 70 20          	mov    %rsi,0x20(%rax)
	}
	_dwarf_frame_params_init(dbg);
  8004203fc7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203fcb:	48 89 c7             	mov    %rax,%rdi
  8004203fce:	48 b8 d1 54 20 04 80 	movabs $0x80042054d1,%rax
  8004203fd5:	00 00 00 
  8004203fd8:	ff d0                	callq  *%rax
	return 0;
  8004203fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004203fdf:	48 83 c4 18          	add    $0x18,%rsp
  8004203fe3:	5b                   	pop    %rbx
  8004203fe4:	5d                   	pop    %rbp
  8004203fe5:	c3                   	retq   

0000008004203fe6 <_get_next_cu>:

//Return 0 on success
int _get_next_cu(Dwarf_Debug dbg, Dwarf_CU *cu)
{
  8004203fe6:	55                   	push   %rbp
  8004203fe7:	48 89 e5             	mov    %rsp,%rbp
  8004203fea:	48 83 ec 20          	sub    $0x20,%rsp
  8004203fee:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004203ff2:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	uint32_t length;
	uint64_t offset;
	uint8_t dwarf_size;

	if(dbg->curr_off_dbginfo > dbg->dbg_info_size)
  8004203ff6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203ffa:	48 8b 10             	mov    (%rax),%rdx
  8004203ffd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204001:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004204005:	48 39 c2             	cmp    %rax,%rdx
  8004204008:	76 0a                	jbe    8004204014 <_get_next_cu+0x2e>
		return -1;
  800420400a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420400f:	e9 6b 01 00 00       	jmpq   800420417f <_get_next_cu+0x199>

	offset = dbg->curr_off_dbginfo;
  8004204014:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204018:	48 8b 00             	mov    (%rax),%rax
  800420401b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	cu->cu_offset = offset;
  800420401f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004204023:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204027:	48 89 50 30          	mov    %rdx,0x30(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset,4);
  800420402b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420402f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204033:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004204037:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  800420403b:	48 89 d1             	mov    %rdx,%rcx
  800420403e:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004204042:	ba 04 00 00 00       	mov    $0x4,%edx
  8004204047:	48 89 cf             	mov    %rcx,%rdi
  800420404a:	ff d0                	callq  *%rax
  800420404c:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (length == 0xffffffff) {
  800420404f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%rbp)
  8004204053:	75 2a                	jne    800420407f <_get_next_cu+0x99>
		length = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 8);
  8004204055:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204059:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420405d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004204061:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004204065:	48 89 d1             	mov    %rdx,%rcx
  8004204068:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  800420406c:	ba 08 00 00 00       	mov    $0x8,%edx
  8004204071:	48 89 cf             	mov    %rcx,%rdi
  8004204074:	ff d0                	callq  *%rax
  8004204076:	89 45 fc             	mov    %eax,-0x4(%rbp)
		dwarf_size = 8;
  8004204079:	c6 45 fb 08          	movb   $0x8,-0x5(%rbp)
  800420407d:	eb 04                	jmp    8004204083 <_get_next_cu+0x9d>
	} else {
		dwarf_size = 4;
  800420407f:	c6 45 fb 04          	movb   $0x4,-0x5(%rbp)
	}

	cu->cu_dwarf_size = dwarf_size;
  8004204083:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204087:	0f b6 55 fb          	movzbl -0x5(%rbp),%edx
  800420408b:	88 50 19             	mov    %dl,0x19(%rax)
	 if (length > ds->ds_size - offset) {
	 return (DW_DLE_CU_LENGTH_ERROR);
	 }*/

	/* Compute the offset to the next compilation unit: */
	dbg->curr_off_dbginfo = offset + length;
  800420408e:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004204091:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004204095:	48 01 c2             	add    %rax,%rdx
  8004204098:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420409c:	48 89 10             	mov    %rdx,(%rax)
	cu->cu_next_offset   = dbg->curr_off_dbginfo;
  800420409f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042040a3:	48 8b 10             	mov    (%rax),%rdx
  80042040a6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042040aa:	48 89 50 20          	mov    %rdx,0x20(%rax)

	/* Initialise the compilation unit. */
	cu->cu_length = (uint64_t)length;
  80042040ae:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042040b1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042040b5:	48 89 10             	mov    %rdx,(%rax)

	cu->cu_length_size   = (dwarf_size == 4 ? 4 : 12);
  80042040b8:	80 7d fb 04          	cmpb   $0x4,-0x5(%rbp)
  80042040bc:	75 07                	jne    80042040c5 <_get_next_cu+0xdf>
  80042040be:	b8 04 00 00 00       	mov    $0x4,%eax
  80042040c3:	eb 05                	jmp    80042040ca <_get_next_cu+0xe4>
  80042040c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  80042040ca:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  80042040ce:	88 42 18             	mov    %al,0x18(%rdx)
	cu->version              = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 2);
  80042040d1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042040d5:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042040d9:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042040dd:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  80042040e1:	48 89 d1             	mov    %rdx,%rcx
  80042040e4:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  80042040e8:	ba 02 00 00 00       	mov    $0x2,%edx
  80042040ed:	48 89 cf             	mov    %rcx,%rdi
  80042040f0:	ff d0                	callq  *%rax
  80042040f2:	89 c2                	mov    %eax,%edx
  80042040f4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042040f8:	66 89 50 08          	mov    %dx,0x8(%rax)
	cu->debug_abbrev_offset  = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, dwarf_size);
  80042040fc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204100:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204104:	0f b6 55 fb          	movzbl -0x5(%rbp),%edx
  8004204108:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420410c:	48 8b 49 08          	mov    0x8(%rcx),%rcx
  8004204110:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004204114:	48 89 cf             	mov    %rcx,%rdi
  8004204117:	ff d0                	callq  *%rax
  8004204119:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420411d:	48 89 42 10          	mov    %rax,0x10(%rdx)
	//cu->cu_abbrev_offset_cur = cu->cu_abbrev_offset;
	cu->addr_size  = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 1);
  8004204121:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204125:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204129:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420412d:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004204131:	48 89 d1             	mov    %rdx,%rcx
  8004204134:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004204138:	ba 01 00 00 00       	mov    $0x1,%edx
  800420413d:	48 89 cf             	mov    %rcx,%rdi
  8004204140:	ff d0                	callq  *%rax
  8004204142:	89 c2                	mov    %eax,%edx
  8004204144:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204148:	88 50 0a             	mov    %dl,0xa(%rax)

	if (cu->version < 2 || cu->version > 4) {
  800420414b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420414f:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204153:	66 83 f8 01          	cmp    $0x1,%ax
  8004204157:	76 0e                	jbe    8004204167 <_get_next_cu+0x181>
  8004204159:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420415d:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204161:	66 83 f8 04          	cmp    $0x4,%ax
  8004204165:	76 07                	jbe    800420416e <_get_next_cu+0x188>
		return -1;
  8004204167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420416c:	eb 11                	jmp    800420417f <_get_next_cu+0x199>
	}

	cu->cu_die_offset = offset;
  800420416e:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004204172:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204176:	48 89 50 28          	mov    %rdx,0x28(%rax)

	return 0;
  800420417a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420417f:	c9                   	leaveq 
  8004204180:	c3                   	retq   

0000008004204181 <print_cu>:

void print_cu(Dwarf_CU cu)
{
  8004204181:	55                   	push   %rbp
  8004204182:	48 89 e5             	mov    %rsp,%rbp
	cprintf("%ld---%du--%d\n",cu.cu_length,cu.version,cu.addr_size);
  8004204185:	0f b6 45 1a          	movzbl 0x1a(%rbp),%eax
  8004204189:	0f b6 c8             	movzbl %al,%ecx
  800420418c:	0f b7 45 18          	movzwl 0x18(%rbp),%eax
  8004204190:	0f b7 d0             	movzwl %ax,%edx
  8004204193:	48 8b 45 10          	mov    0x10(%rbp),%rax
  8004204197:	48 89 c6             	mov    %rax,%rsi
  800420419a:	48 bf f2 9f 20 04 80 	movabs $0x8004209ff2,%rdi
  80042041a1:	00 00 00 
  80042041a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042041a9:	49 b8 87 15 20 04 80 	movabs $0x8004201587,%r8
  80042041b0:	00 00 00 
  80042041b3:	41 ff d0             	callq  *%r8
}
  80042041b6:	5d                   	pop    %rbp
  80042041b7:	c3                   	retq   

00000080042041b8 <_dwarf_abbrev_parse>:

//Return 0 on success
int
_dwarf_abbrev_parse(Dwarf_Debug dbg, Dwarf_CU cu, Dwarf_Unsigned *offset,
		    Dwarf_Abbrev *abp, Dwarf_Section *ds)
{
  80042041b8:	55                   	push   %rbp
  80042041b9:	48 89 e5             	mov    %rsp,%rbp
  80042041bc:	48 83 ec 60          	sub    $0x60,%rsp
  80042041c0:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80042041c4:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  80042041c8:	48 89 55 a8          	mov    %rdx,-0x58(%rbp)
  80042041cc:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
	uint64_t tag;
	uint8_t children;
	uint64_t abbr_addr;
	int ret;

	assert(abp != NULL);
  80042041d0:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  80042041d5:	75 35                	jne    800420420c <_dwarf_abbrev_parse+0x54>
  80042041d7:	48 b9 01 a0 20 04 80 	movabs $0x800420a001,%rcx
  80042041de:	00 00 00 
  80042041e1:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  80042041e8:	00 00 00 
  80042041eb:	be a4 01 00 00       	mov    $0x1a4,%esi
  80042041f0:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  80042041f7:	00 00 00 
  80042041fa:	b8 00 00 00 00       	mov    $0x0,%eax
  80042041ff:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204206:	00 00 00 
  8004204209:	41 ff d0             	callq  *%r8
	assert(ds != NULL);
  800420420c:	48 83 7d a0 00       	cmpq   $0x0,-0x60(%rbp)
  8004204211:	75 35                	jne    8004204248 <_dwarf_abbrev_parse+0x90>
  8004204213:	48 b9 0d a0 20 04 80 	movabs $0x800420a00d,%rcx
  800420421a:	00 00 00 
  800420421d:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204224:	00 00 00 
  8004204227:	be a5 01 00 00       	mov    $0x1a5,%esi
  800420422c:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204233:	00 00 00 
  8004204236:	b8 00 00 00 00       	mov    $0x0,%eax
  800420423b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204242:	00 00 00 
  8004204245:	41 ff d0             	callq  *%r8

	if (*offset >= ds->ds_size)
  8004204248:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420424c:	48 8b 10             	mov    (%rax),%rdx
  800420424f:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204253:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204257:	48 39 c2             	cmp    %rax,%rdx
  800420425a:	72 0a                	jb     8004204266 <_dwarf_abbrev_parse+0xae>
        	return (DW_DLE_NO_ENTRY);
  800420425c:	b8 04 00 00 00       	mov    $0x4,%eax
  8004204261:	e9 d3 01 00 00       	jmpq   8004204439 <_dwarf_abbrev_parse+0x281>

	aboff = *offset;
  8004204266:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420426a:	48 8b 00             	mov    (%rax),%rax
  800420426d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	abbr_addr = (uint64_t)ds->ds_data; //(uint64_t)((uint8_t *)elf_base_ptr + ds->sh_offset);
  8004204271:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204275:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004204279:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	entry = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  800420427d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004204281:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004204285:	48 89 d6             	mov    %rdx,%rsi
  8004204288:	48 89 c7             	mov    %rax,%rdi
  800420428b:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204292:	00 00 00 
  8004204295:	ff d0                	callq  *%rax
  8004204297:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	if (entry == 0) {
  800420429b:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042042a0:	75 15                	jne    80042042b7 <_dwarf_abbrev_parse+0xff>
		/* Last entry. */
		//Need to make connection from below function
		abp->ab_entry = 0;
  80042042a2:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042042a6:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
		return DW_DLE_NONE;
  80042042ad:	b8 00 00 00 00       	mov    $0x0,%eax
  80042042b2:	e9 82 01 00 00       	jmpq   8004204439 <_dwarf_abbrev_parse+0x281>
	}

	tag = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  80042042b7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042042bb:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80042042bf:	48 89 d6             	mov    %rdx,%rsi
  80042042c2:	48 89 c7             	mov    %rax,%rdi
  80042042c5:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  80042042cc:	00 00 00 
  80042042cf:	ff d0                	callq  *%rax
  80042042d1:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	children = dbg->read((uint8_t *)abbr_addr, offset, 1);
  80042042d5:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042042d9:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042042dd:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  80042042e1:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80042042e5:	ba 01 00 00 00       	mov    $0x1,%edx
  80042042ea:	48 89 cf             	mov    %rcx,%rdi
  80042042ed:	ff d0                	callq  *%rax
  80042042ef:	88 45 df             	mov    %al,-0x21(%rbp)

	abp->ab_entry    = entry;
  80042042f2:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042042f6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042042fa:	48 89 10             	mov    %rdx,(%rax)
	abp->ab_tag      = tag;
  80042042fd:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204301:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004204305:	48 89 50 08          	mov    %rdx,0x8(%rax)
	abp->ab_children = children;
  8004204309:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420430d:	0f b6 55 df          	movzbl -0x21(%rbp),%edx
  8004204311:	88 50 10             	mov    %dl,0x10(%rax)
	abp->ab_offset   = aboff;
  8004204314:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204318:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420431c:	48 89 50 18          	mov    %rdx,0x18(%rax)
	abp->ab_length   = 0;    /* fill in later. */
  8004204320:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204324:	48 c7 40 20 00 00 00 	movq   $0x0,0x20(%rax)
  800420432b:	00 
	abp->ab_atnum    = 0;
  800420432c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204330:	48 c7 40 28 00 00 00 	movq   $0x0,0x28(%rax)
  8004204337:	00 

	/* Parse attribute definitions. */
	do {
		adoff = *offset;
  8004204338:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420433c:	48 8b 00             	mov    (%rax),%rax
  800420433f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		attr = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  8004204343:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004204347:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  800420434b:	48 89 d6             	mov    %rdx,%rsi
  800420434e:	48 89 c7             	mov    %rax,%rdi
  8004204351:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204358:	00 00 00 
  800420435b:	ff d0                	callq  *%rax
  800420435d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
		form = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  8004204361:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004204365:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004204369:	48 89 d6             	mov    %rdx,%rsi
  800420436c:	48 89 c7             	mov    %rax,%rdi
  800420436f:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204376:	00 00 00 
  8004204379:	ff d0                	callq  *%rax
  800420437b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
		if (attr != 0)
  800420437f:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004204384:	0f 84 89 00 00 00    	je     8004204413 <_dwarf_abbrev_parse+0x25b>
		{
			/* Initialise the attribute definition structure. */
			abp->ab_attrdef[abp->ab_atnum].ad_attrib = attr;
  800420438a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420438e:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8004204392:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8004204396:	48 89 d0             	mov    %rdx,%rax
  8004204399:	48 01 c0             	add    %rax,%rax
  800420439c:	48 01 d0             	add    %rdx,%rax
  800420439f:	48 c1 e0 03          	shl    $0x3,%rax
  80042043a3:	48 01 c8             	add    %rcx,%rax
  80042043a6:	48 8d 50 30          	lea    0x30(%rax),%rdx
  80042043aa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042043ae:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_attrdef[abp->ab_atnum].ad_form   = form;
  80042043b1:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042043b5:	48 8b 50 28          	mov    0x28(%rax),%rdx
  80042043b9:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  80042043bd:	48 89 d0             	mov    %rdx,%rax
  80042043c0:	48 01 c0             	add    %rax,%rax
  80042043c3:	48 01 d0             	add    %rdx,%rax
  80042043c6:	48 c1 e0 03          	shl    $0x3,%rax
  80042043ca:	48 01 c8             	add    %rcx,%rax
  80042043cd:	48 8d 50 38          	lea    0x38(%rax),%rdx
  80042043d1:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042043d5:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_attrdef[abp->ab_atnum].ad_offset = adoff;
  80042043d8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042043dc:	48 8b 50 28          	mov    0x28(%rax),%rdx
  80042043e0:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  80042043e4:	48 89 d0             	mov    %rdx,%rax
  80042043e7:	48 01 c0             	add    %rax,%rax
  80042043ea:	48 01 d0             	add    %rdx,%rax
  80042043ed:	48 c1 e0 03          	shl    $0x3,%rax
  80042043f1:	48 01 c8             	add    %rcx,%rax
  80042043f4:	48 8d 50 40          	lea    0x40(%rax),%rdx
  80042043f8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042043fc:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_atnum++;
  80042043ff:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204403:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004204407:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420440b:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420440f:	48 89 50 28          	mov    %rdx,0x28(%rax)
		}
	} while (attr != 0);
  8004204413:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004204418:	0f 85 1a ff ff ff    	jne    8004204338 <_dwarf_abbrev_parse+0x180>

	//(*abp)->ab_length = *offset - aboff;
	abp->ab_length = (uint64_t)(*offset - aboff);
  800420441e:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004204422:	48 8b 00             	mov    (%rax),%rax
  8004204425:	48 2b 45 f8          	sub    -0x8(%rbp),%rax
  8004204429:	48 89 c2             	mov    %rax,%rdx
  800420442c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004204430:	48 89 50 20          	mov    %rdx,0x20(%rax)

	return DW_DLV_OK;
  8004204434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004204439:	c9                   	leaveq 
  800420443a:	c3                   	retq   

000000800420443b <_dwarf_abbrev_find>:

//Return 0 on success
int
_dwarf_abbrev_find(Dwarf_Debug dbg, Dwarf_CU cu, uint64_t entry, Dwarf_Abbrev *abp)
{
  800420443b:	55                   	push   %rbp
  800420443c:	48 89 e5             	mov    %rsp,%rbp
  800420443f:	48 83 ec 70          	sub    $0x70,%rsp
  8004204443:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004204447:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420444b:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	Dwarf_Section *ds;
	uint64_t offset;
	int ret;

	if (entry == 0)
  800420444f:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004204454:	75 0a                	jne    8004204460 <_dwarf_abbrev_find+0x25>
	{
		return (DW_DLE_NO_ENTRY);
  8004204456:	b8 04 00 00 00       	mov    $0x4,%eax
  800420445b:	e9 0a 01 00 00       	jmpq   800420456a <_dwarf_abbrev_find+0x12f>
	}

	/* Load and search the abbrev table. */
	ds = _dwarf_find_section(".debug_abbrev");
  8004204460:	48 bf 18 a0 20 04 80 	movabs $0x800420a018,%rdi
  8004204467:	00 00 00 
  800420446a:	48 b8 9b 87 20 04 80 	movabs $0x800420879b,%rax
  8004204471:	00 00 00 
  8004204474:	ff d0                	callq  *%rax
  8004204476:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(ds != NULL);
  800420447a:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420447f:	75 35                	jne    80042044b6 <_dwarf_abbrev_find+0x7b>
  8004204481:	48 b9 0d a0 20 04 80 	movabs $0x800420a00d,%rcx
  8004204488:	00 00 00 
  800420448b:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204492:	00 00 00 
  8004204495:	be e5 01 00 00       	mov    $0x1e5,%esi
  800420449a:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  80042044a1:	00 00 00 
  80042044a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042044a9:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042044b0:	00 00 00 
  80042044b3:	41 ff d0             	callq  *%r8

	//TODO: We are starting offset from 0, however libdwarf logic
	//      is keeping a counter for current offset. Ok. let use
	//      that. I relent, but this will be done in Phase 2. :)
	//offset = 0; //cu->cu_abbrev_offset_cur;
	offset = cu.debug_abbrev_offset; //cu->cu_abbrev_offset_cur;
  80042044b6:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042044ba:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	while (offset < ds->ds_size) {
  80042044be:	e9 8d 00 00 00       	jmpq   8004204550 <_dwarf_abbrev_find+0x115>
		ret = _dwarf_abbrev_parse(dbg, cu, &offset, abp, ds);
  80042044c3:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  80042044c7:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042044cb:	48 8d 75 e8          	lea    -0x18(%rbp),%rsi
  80042044cf:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042044d3:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  80042044d7:	48 89 3c 24          	mov    %rdi,(%rsp)
  80042044db:	48 8b 7d 18          	mov    0x18(%rbp),%rdi
  80042044df:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  80042044e4:	48 8b 7d 20          	mov    0x20(%rbp),%rdi
  80042044e8:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  80042044ed:	48 8b 7d 28          	mov    0x28(%rbp),%rdi
  80042044f1:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  80042044f6:	48 8b 7d 30          	mov    0x30(%rbp),%rdi
  80042044fa:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  80042044ff:	48 8b 7d 38          	mov    0x38(%rbp),%rdi
  8004204503:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  8004204508:	48 8b 7d 40          	mov    0x40(%rbp),%rdi
  800420450c:	48 89 7c 24 30       	mov    %rdi,0x30(%rsp)
  8004204511:	48 89 c7             	mov    %rax,%rdi
  8004204514:	48 b8 b8 41 20 04 80 	movabs $0x80042041b8,%rax
  800420451b:	00 00 00 
  800420451e:	ff d0                	callq  *%rax
  8004204520:	89 45 f4             	mov    %eax,-0xc(%rbp)
		if (ret != DW_DLE_NONE)
  8004204523:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8004204527:	74 05                	je     800420452e <_dwarf_abbrev_find+0xf3>
			return (ret);
  8004204529:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420452c:	eb 3c                	jmp    800420456a <_dwarf_abbrev_find+0x12f>
		if (abp->ab_entry == entry) {
  800420452e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204532:	48 8b 00             	mov    (%rax),%rax
  8004204535:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004204539:	75 07                	jne    8004204542 <_dwarf_abbrev_find+0x107>
			//cu->cu_abbrev_offset_cur = offset;
			return DW_DLE_NONE;
  800420453b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204540:	eb 28                	jmp    800420456a <_dwarf_abbrev_find+0x12f>
		}
		if (abp->ab_entry == 0) {
  8004204542:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204546:	48 8b 00             	mov    (%rax),%rax
  8004204549:	48 85 c0             	test   %rax,%rax
  800420454c:	75 02                	jne    8004204550 <_dwarf_abbrev_find+0x115>
			//cu->cu_abbrev_offset_cur = offset;
			//cu->cu_abbrev_loaded = 1;
			break;
  800420454e:	eb 15                	jmp    8004204565 <_dwarf_abbrev_find+0x12a>
	//TODO: We are starting offset from 0, however libdwarf logic
	//      is keeping a counter for current offset. Ok. let use
	//      that. I relent, but this will be done in Phase 2. :)
	//offset = 0; //cu->cu_abbrev_offset_cur;
	offset = cu.debug_abbrev_offset; //cu->cu_abbrev_offset_cur;
	while (offset < ds->ds_size) {
  8004204550:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004204554:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004204558:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420455c:	48 39 c2             	cmp    %rax,%rdx
  800420455f:	0f 87 5e ff ff ff    	ja     80042044c3 <_dwarf_abbrev_find+0x88>
			//cu->cu_abbrev_loaded = 1;
			break;
		}
	}

	return DW_DLE_NO_ENTRY;
  8004204565:	b8 04 00 00 00       	mov    $0x4,%eax
}
  800420456a:	c9                   	leaveq 
  800420456b:	c3                   	retq   

000000800420456c <_dwarf_attr_init>:

//Return 0 on success
int
_dwarf_attr_init(Dwarf_Debug dbg, uint64_t *offsetp, Dwarf_CU *cu, Dwarf_Die *ret_die, Dwarf_AttrDef *ad,
		 uint64_t form, int indirect)
{
  800420456c:	55                   	push   %rbp
  800420456d:	48 89 e5             	mov    %rsp,%rbp
  8004204570:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004204577:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  800420457e:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  8004204585:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  800420458c:	48 89 8d 50 ff ff ff 	mov    %rcx,-0xb0(%rbp)
  8004204593:	4c 89 85 48 ff ff ff 	mov    %r8,-0xb8(%rbp)
  800420459a:	4c 89 8d 40 ff ff ff 	mov    %r9,-0xc0(%rbp)
	struct _Dwarf_Attribute atref;
	Dwarf_Section *str;
	int ret;
	Dwarf_Section *ds = _dwarf_find_section(".debug_info");
  80042045a1:	48 bf 26 a0 20 04 80 	movabs $0x800420a026,%rdi
  80042045a8:	00 00 00 
  80042045ab:	48 b8 9b 87 20 04 80 	movabs $0x800420879b,%rax
  80042045b2:	00 00 00 
  80042045b5:	ff d0                	callq  *%rax
  80042045b7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	uint8_t *ds_data = (uint8_t *)ds->ds_data; //(uint8_t *)dbg->dbg_info_offset_elf;
  80042045bb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042045bf:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042045c3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uint8_t dwarf_size = cu->cu_dwarf_size;
  80042045c7:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80042045ce:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  80042045d2:	88 45 e7             	mov    %al,-0x19(%rbp)

	ret = DW_DLE_NONE;
  80042045d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	memset(&atref, 0, sizeof(atref));
  80042045dc:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  80042045e3:	ba 60 00 00 00       	mov    $0x60,%edx
  80042045e8:	be 00 00 00 00       	mov    $0x0,%esi
  80042045ed:	48 89 c7             	mov    %rax,%rdi
  80042045f0:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  80042045f7:	00 00 00 
  80042045fa:	ff d0                	callq  *%rax
	atref.at_die = ret_die;
  80042045fc:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004204603:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
	atref.at_attrib = ad->ad_attrib;
  800420460a:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004204611:	48 8b 00             	mov    (%rax),%rax
  8004204614:	48 89 45 80          	mov    %rax,-0x80(%rbp)
	atref.at_form = ad->ad_form;
  8004204618:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  800420461f:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004204623:	48 89 45 88          	mov    %rax,-0x78(%rbp)
	atref.at_indirect = indirect;
  8004204627:	8b 45 10             	mov    0x10(%rbp),%eax
  800420462a:	89 45 90             	mov    %eax,-0x70(%rbp)
	atref.at_ld = NULL;
  800420462d:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8004204634:	00 

	switch (form) {
  8004204635:	48 83 bd 40 ff ff ff 	cmpq   $0x20,-0xc0(%rbp)
  800420463c:	20 
  800420463d:	0f 87 82 04 00 00    	ja     8004204ac5 <_dwarf_attr_init+0x559>
  8004204643:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  800420464a:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004204651:	00 
  8004204652:	48 b8 50 a0 20 04 80 	movabs $0x800420a050,%rax
  8004204659:	00 00 00 
  800420465c:	48 01 d0             	add    %rdx,%rax
  800420465f:	48 8b 00             	mov    (%rax),%rax
  8004204662:	ff e0                	jmpq   *%rax
	case DW_FORM_addr:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, cu->addr_size);
  8004204664:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420466b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420466f:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  8004204676:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  800420467a:	0f b6 d2             	movzbl %dl,%edx
  800420467d:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204684:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204688:	48 89 cf             	mov    %rcx,%rdi
  800420468b:	ff d0                	callq  *%rax
  800420468d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004204691:	e9 37 04 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_block:
	case DW_FORM_exprloc:
		atref.u[0].u64 = _dwarf_read_uleb128(ds_data, offsetp);
  8004204696:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  800420469d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042046a1:	48 89 d6             	mov    %rdx,%rsi
  80042046a4:	48 89 c7             	mov    %rax,%rdi
  80042046a7:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  80042046ae:	00 00 00 
  80042046b1:	ff d0                	callq  *%rax
  80042046b3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  80042046b7:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  80042046bb:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  80042046c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042046c6:	48 89 ce             	mov    %rcx,%rsi
  80042046c9:	48 89 c7             	mov    %rax,%rdi
  80042046cc:	48 b8 e3 3d 20 04 80 	movabs $0x8004203de3,%rax
  80042046d3:	00 00 00 
  80042046d6:	ff d0                	callq  *%rax
  80042046d8:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  80042046dc:	e9 ec 03 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_block1:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 1);
  80042046e1:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042046e8:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042046ec:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042046f3:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042046f7:	ba 01 00 00 00       	mov    $0x1,%edx
  80042046fc:	48 89 cf             	mov    %rcx,%rdi
  80042046ff:	ff d0                	callq  *%rax
  8004204701:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  8004204705:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004204709:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  8004204710:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204714:	48 89 ce             	mov    %rcx,%rsi
  8004204717:	48 89 c7             	mov    %rax,%rdi
  800420471a:	48 b8 e3 3d 20 04 80 	movabs $0x8004203de3,%rax
  8004204721:	00 00 00 
  8004204724:	ff d0                	callq  *%rax
  8004204726:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  800420472a:	e9 9e 03 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_block2:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 2);
  800420472f:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004204736:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420473a:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204741:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204745:	ba 02 00 00 00       	mov    $0x2,%edx
  800420474a:	48 89 cf             	mov    %rcx,%rdi
  800420474d:	ff d0                	callq  *%rax
  800420474f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  8004204753:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004204757:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  800420475e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204762:	48 89 ce             	mov    %rcx,%rsi
  8004204765:	48 89 c7             	mov    %rax,%rdi
  8004204768:	48 b8 e3 3d 20 04 80 	movabs $0x8004203de3,%rax
  800420476f:	00 00 00 
  8004204772:	ff d0                	callq  *%rax
  8004204774:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004204778:	e9 50 03 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_block4:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 4);
  800420477d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004204784:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204788:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420478f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204793:	ba 04 00 00 00       	mov    $0x4,%edx
  8004204798:	48 89 cf             	mov    %rcx,%rdi
  800420479b:	ff d0                	callq  *%rax
  800420479d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  80042047a1:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  80042047a5:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  80042047ac:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042047b0:	48 89 ce             	mov    %rcx,%rsi
  80042047b3:	48 89 c7             	mov    %rax,%rdi
  80042047b6:	48 b8 e3 3d 20 04 80 	movabs $0x8004203de3,%rax
  80042047bd:	00 00 00 
  80042047c0:	ff d0                	callq  *%rax
  80042047c2:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  80042047c6:	e9 02 03 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_data1:
	case DW_FORM_flag:
	case DW_FORM_ref1:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 1);
  80042047cb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042047d2:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042047d6:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042047dd:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042047e1:	ba 01 00 00 00       	mov    $0x1,%edx
  80042047e6:	48 89 cf             	mov    %rcx,%rdi
  80042047e9:	ff d0                	callq  *%rax
  80042047eb:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042047ef:	e9 d9 02 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_data2:
	case DW_FORM_ref2:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 2);
  80042047f4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042047fb:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042047ff:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204806:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420480a:	ba 02 00 00 00       	mov    $0x2,%edx
  800420480f:	48 89 cf             	mov    %rcx,%rdi
  8004204812:	ff d0                	callq  *%rax
  8004204814:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004204818:	e9 b0 02 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_data4:
	case DW_FORM_ref4:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 4);
  800420481d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004204824:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204828:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420482f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204833:	ba 04 00 00 00       	mov    $0x4,%edx
  8004204838:	48 89 cf             	mov    %rcx,%rdi
  800420483b:	ff d0                	callq  *%rax
  800420483d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004204841:	e9 87 02 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_data8:
	case DW_FORM_ref8:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 8);
  8004204846:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420484d:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204851:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204858:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420485c:	ba 08 00 00 00       	mov    $0x8,%edx
  8004204861:	48 89 cf             	mov    %rcx,%rdi
  8004204864:	ff d0                	callq  *%rax
  8004204866:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420486a:	e9 5e 02 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_indirect:
		form = _dwarf_read_uleb128(ds_data, offsetp);
  800420486f:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004204876:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420487a:	48 89 d6             	mov    %rdx,%rsi
  800420487d:	48 89 c7             	mov    %rax,%rdi
  8004204880:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204887:	00 00 00 
  800420488a:	ff d0                	callq  *%rax
  800420488c:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
		return (_dwarf_attr_init(dbg, offsetp, cu, ret_die, ad, form, 1));
  8004204893:	4c 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%r8
  800420489a:	48 8b bd 48 ff ff ff 	mov    -0xb8(%rbp),%rdi
  80042048a1:	48 8b 8d 50 ff ff ff 	mov    -0xb0(%rbp),%rcx
  80042048a8:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  80042048af:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042048b6:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042048bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%rsp)
  80042048c4:	4d 89 c1             	mov    %r8,%r9
  80042048c7:	49 89 f8             	mov    %rdi,%r8
  80042048ca:	48 89 c7             	mov    %rax,%rdi
  80042048cd:	48 b8 6c 45 20 04 80 	movabs $0x800420456c,%rax
  80042048d4:	00 00 00 
  80042048d7:	ff d0                	callq  *%rax
  80042048d9:	e9 1d 03 00 00       	jmpq   8004204bfb <_dwarf_attr_init+0x68f>
	case DW_FORM_ref_addr:
		if (cu->version == 2)
  80042048de:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80042048e5:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042048e9:	66 83 f8 02          	cmp    $0x2,%ax
  80042048ed:	75 2f                	jne    800420491e <_dwarf_attr_init+0x3b2>
			atref.u[0].u64 = dbg->read(ds_data, offsetp, cu->addr_size);
  80042048ef:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042048f6:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042048fa:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  8004204901:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  8004204905:	0f b6 d2             	movzbl %dl,%edx
  8004204908:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420490f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204913:	48 89 cf             	mov    %rcx,%rdi
  8004204916:	ff d0                	callq  *%rax
  8004204918:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800420491c:	eb 39                	jmp    8004204957 <_dwarf_attr_init+0x3eb>
		else if (cu->version == 3)
  800420491e:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004204925:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204929:	66 83 f8 03          	cmp    $0x3,%ax
  800420492d:	75 28                	jne    8004204957 <_dwarf_attr_init+0x3eb>
			atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  800420492f:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004204936:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420493a:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  800420493e:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204945:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204949:	48 89 cf             	mov    %rcx,%rdi
  800420494c:	ff d0                	callq  *%rax
  800420494e:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004204952:	e9 76 01 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
  8004204957:	e9 71 01 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_ref_udata:
	case DW_FORM_udata:
		atref.u[0].u64 = _dwarf_read_uleb128(ds_data, offsetp);
  800420495c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004204963:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204967:	48 89 d6             	mov    %rdx,%rsi
  800420496a:	48 89 c7             	mov    %rax,%rdi
  800420496d:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204974:	00 00 00 
  8004204977:	ff d0                	callq  *%rax
  8004204979:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420497d:	e9 4b 01 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_sdata:
		atref.u[0].s64 = _dwarf_read_sleb128(ds_data, offsetp);
  8004204982:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004204989:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420498d:	48 89 d6             	mov    %rdx,%rsi
  8004204990:	48 89 c7             	mov    %rax,%rdi
  8004204993:	48 b8 32 3b 20 04 80 	movabs $0x8004203b32,%rax
  800420499a:	00 00 00 
  800420499d:	ff d0                	callq  *%rax
  800420499f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042049a3:	e9 25 01 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_sec_offset:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  80042049a8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042049af:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042049b3:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  80042049b7:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042049be:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042049c2:	48 89 cf             	mov    %rcx,%rdi
  80042049c5:	ff d0                	callq  *%rax
  80042049c7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042049cb:	e9 fd 00 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_string:
		atref.u[0].s =(char*) _dwarf_read_string(ds_data, (uint64_t)ds->ds_size, offsetp);
  80042049d0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042049d4:	48 8b 48 18          	mov    0x18(%rax),%rcx
  80042049d8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  80042049df:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042049e3:	48 89 ce             	mov    %rcx,%rsi
  80042049e6:	48 89 c7             	mov    %rax,%rdi
  80042049e9:	48 b8 54 3d 20 04 80 	movabs $0x8004203d54,%rax
  80042049f0:	00 00 00 
  80042049f3:	ff d0                	callq  *%rax
  80042049f5:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042049f9:	e9 cf 00 00 00       	jmpq   8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_strp:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  80042049fe:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004204a05:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004204a09:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  8004204a0d:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004204a14:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204a18:	48 89 cf             	mov    %rcx,%rdi
  8004204a1b:	ff d0                	callq  *%rax
  8004204a1d:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		str = _dwarf_find_section(".debug_str");
  8004204a21:	48 bf 32 a0 20 04 80 	movabs $0x800420a032,%rdi
  8004204a28:	00 00 00 
  8004204a2b:	48 b8 9b 87 20 04 80 	movabs $0x800420879b,%rax
  8004204a32:	00 00 00 
  8004204a35:	ff d0                	callq  *%rax
  8004204a37:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
		assert(str != NULL);
  8004204a3b:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004204a40:	75 35                	jne    8004204a77 <_dwarf_attr_init+0x50b>
  8004204a42:	48 b9 3d a0 20 04 80 	movabs $0x800420a03d,%rcx
  8004204a49:	00 00 00 
  8004204a4c:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204a53:	00 00 00 
  8004204a56:	be 51 02 00 00       	mov    $0x251,%esi
  8004204a5b:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204a62:	00 00 00 
  8004204a65:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204a6a:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204a71:	00 00 00 
  8004204a74:	41 ff d0             	callq  *%r8
		//atref.u[1].s = (char *)(elf_base_ptr + str->sh_offset) + atref.u[0].u64;
		atref.u[1].s = (char *)str->ds_data + atref.u[0].u64;
  8004204a77:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004204a7b:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004204a7f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004204a83:	48 01 d0             	add    %rdx,%rax
  8004204a86:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004204a8a:	eb 41                	jmp    8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_ref_sig8:
		atref.u[0].u64 = 8;
  8004204a8c:	48 c7 45 98 08 00 00 	movq   $0x8,-0x68(%rbp)
  8004204a93:	00 
		atref.u[1].u8p = (uint8_t*)(_dwarf_read_block(ds_data, offsetp, atref.u[0].u64));
  8004204a94:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004204a98:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  8004204a9f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204aa3:	48 89 ce             	mov    %rcx,%rsi
  8004204aa6:	48 89 c7             	mov    %rax,%rdi
  8004204aa9:	48 b8 e3 3d 20 04 80 	movabs $0x8004203de3,%rax
  8004204ab0:	00 00 00 
  8004204ab3:	ff d0                	callq  *%rax
  8004204ab5:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004204ab9:	eb 12                	jmp    8004204acd <_dwarf_attr_init+0x561>
	case DW_FORM_flag_present:
		/* This form has no value encoded in the DIE. */
		atref.u[0].u64 = 1;
  8004204abb:	48 c7 45 98 01 00 00 	movq   $0x1,-0x68(%rbp)
  8004204ac2:	00 
		break;
  8004204ac3:	eb 08                	jmp    8004204acd <_dwarf_attr_init+0x561>
	default:
		//DWARF_SET_ERROR(dbg, error, DW_DLE_ATTR_FORM_BAD);
		ret = DW_DLE_ATTR_FORM_BAD;
  8004204ac5:	c7 45 fc 0e 00 00 00 	movl   $0xe,-0x4(%rbp)
		break;
  8004204acc:	90                   	nop
	}

	if (ret == DW_DLE_NONE) {
  8004204acd:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004204ad1:	0f 85 21 01 00 00    	jne    8004204bf8 <_dwarf_attr_init+0x68c>
		if (form == DW_FORM_block || form == DW_FORM_block1 ||
  8004204ad7:	48 83 bd 40 ff ff ff 	cmpq   $0x9,-0xc0(%rbp)
  8004204ade:	09 
  8004204adf:	74 1e                	je     8004204aff <_dwarf_attr_init+0x593>
  8004204ae1:	48 83 bd 40 ff ff ff 	cmpq   $0xa,-0xc0(%rbp)
  8004204ae8:	0a 
  8004204ae9:	74 14                	je     8004204aff <_dwarf_attr_init+0x593>
  8004204aeb:	48 83 bd 40 ff ff ff 	cmpq   $0x3,-0xc0(%rbp)
  8004204af2:	03 
  8004204af3:	74 0a                	je     8004204aff <_dwarf_attr_init+0x593>
		    form == DW_FORM_block2 || form == DW_FORM_block4) {
  8004204af5:	48 83 bd 40 ff ff ff 	cmpq   $0x4,-0xc0(%rbp)
  8004204afc:	04 
  8004204afd:	75 10                	jne    8004204b0f <_dwarf_attr_init+0x5a3>
			atref.at_block.bl_len = atref.u[0].u64;
  8004204aff:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004204b03:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
			atref.at_block.bl_data = atref.u[1].u8p;
  8004204b07:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204b0b:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
		}
		//ret = _dwarf_attr_add(die, &atref, NULL, error);
		if (atref.at_attrib == DW_AT_name) {
  8004204b0f:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004204b13:	48 83 f8 03          	cmp    $0x3,%rax
  8004204b17:	75 39                	jne    8004204b52 <_dwarf_attr_init+0x5e6>
			switch (atref.at_form) {
  8004204b19:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004204b1d:	48 83 f8 08          	cmp    $0x8,%rax
  8004204b21:	74 1c                	je     8004204b3f <_dwarf_attr_init+0x5d3>
  8004204b23:	48 83 f8 0e          	cmp    $0xe,%rax
  8004204b27:	74 02                	je     8004204b2b <_dwarf_attr_init+0x5bf>
				break;
			case DW_FORM_string:
				ret_die->die_name = atref.u[0].s;
				break;
			default:
				break;
  8004204b29:	eb 27                	jmp    8004204b52 <_dwarf_attr_init+0x5e6>
		}
		//ret = _dwarf_attr_add(die, &atref, NULL, error);
		if (atref.at_attrib == DW_AT_name) {
			switch (atref.at_form) {
			case DW_FORM_strp:
				ret_die->die_name = atref.u[1].s;
  8004204b2b:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004204b2f:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004204b36:	48 89 90 50 03 00 00 	mov    %rdx,0x350(%rax)
				break;
  8004204b3d:	eb 13                	jmp    8004204b52 <_dwarf_attr_init+0x5e6>
			case DW_FORM_string:
				ret_die->die_name = atref.u[0].s;
  8004204b3f:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004204b43:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004204b4a:	48 89 90 50 03 00 00 	mov    %rdx,0x350(%rax)
				break;
  8004204b51:	90                   	nop
			default:
				break;
			}
		}
		ret_die->die_attr[ret_die->die_attr_count++] = atref;
  8004204b52:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004204b59:	0f b6 80 58 03 00 00 	movzbl 0x358(%rax),%eax
  8004204b60:	8d 48 01             	lea    0x1(%rax),%ecx
  8004204b63:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  8004204b6a:	88 8a 58 03 00 00    	mov    %cl,0x358(%rdx)
  8004204b70:	0f b6 c0             	movzbl %al,%eax
  8004204b73:	48 8b 8d 50 ff ff ff 	mov    -0xb0(%rbp),%rcx
  8004204b7a:	48 63 d0             	movslq %eax,%rdx
  8004204b7d:	48 89 d0             	mov    %rdx,%rax
  8004204b80:	48 01 c0             	add    %rax,%rax
  8004204b83:	48 01 d0             	add    %rdx,%rax
  8004204b86:	48 c1 e0 05          	shl    $0x5,%rax
  8004204b8a:	48 01 c8             	add    %rcx,%rax
  8004204b8d:	48 05 70 03 00 00    	add    $0x370,%rax
  8004204b93:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  8004204b9a:	48 89 10             	mov    %rdx,(%rax)
  8004204b9d:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  8004204ba4:	48 89 50 08          	mov    %rdx,0x8(%rax)
  8004204ba8:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  8004204bac:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8004204bb0:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8004204bb4:	48 89 50 18          	mov    %rdx,0x18(%rax)
  8004204bb8:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  8004204bbc:	48 89 50 20          	mov    %rdx,0x20(%rax)
  8004204bc0:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004204bc4:	48 89 50 28          	mov    %rdx,0x28(%rax)
  8004204bc8:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004204bcc:	48 89 50 30          	mov    %rdx,0x30(%rax)
  8004204bd0:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8004204bd4:	48 89 50 38          	mov    %rdx,0x38(%rax)
  8004204bd8:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004204bdc:	48 89 50 40          	mov    %rdx,0x40(%rax)
  8004204be0:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004204be4:	48 89 50 48          	mov    %rdx,0x48(%rax)
  8004204be8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004204bec:	48 89 50 50          	mov    %rdx,0x50(%rax)
  8004204bf0:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004204bf4:	48 89 50 58          	mov    %rdx,0x58(%rax)
	}

	return (ret);
  8004204bf8:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004204bfb:	c9                   	leaveq 
  8004204bfc:	c3                   	retq   

0000008004204bfd <dwarf_search_die_within_cu>:

int
dwarf_search_die_within_cu(Dwarf_Debug dbg, Dwarf_CU cu, uint64_t offset, Dwarf_Die *ret_die, int search_sibling)
{
  8004204bfd:	55                   	push   %rbp
  8004204bfe:	48 89 e5             	mov    %rsp,%rbp
  8004204c01:	48 81 ec d0 03 00 00 	sub    $0x3d0,%rsp
  8004204c08:	48 89 bd 88 fc ff ff 	mov    %rdi,-0x378(%rbp)
  8004204c0f:	48 89 b5 80 fc ff ff 	mov    %rsi,-0x380(%rbp)
  8004204c16:	48 89 95 78 fc ff ff 	mov    %rdx,-0x388(%rbp)
  8004204c1d:	89 8d 74 fc ff ff    	mov    %ecx,-0x38c(%rbp)
	uint64_t abnum;
	uint64_t die_offset;
	int ret, level;
	int i;

	assert(dbg);
  8004204c23:	48 83 bd 88 fc ff ff 	cmpq   $0x0,-0x378(%rbp)
  8004204c2a:	00 
  8004204c2b:	75 35                	jne    8004204c62 <dwarf_search_die_within_cu+0x65>
  8004204c2d:	48 b9 58 a1 20 04 80 	movabs $0x800420a158,%rcx
  8004204c34:	00 00 00 
  8004204c37:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204c3e:	00 00 00 
  8004204c41:	be 86 02 00 00       	mov    $0x286,%esi
  8004204c46:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204c4d:	00 00 00 
  8004204c50:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204c55:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204c5c:	00 00 00 
  8004204c5f:	41 ff d0             	callq  *%r8
	//assert(cu);
	assert(ret_die);
  8004204c62:	48 83 bd 78 fc ff ff 	cmpq   $0x0,-0x388(%rbp)
  8004204c69:	00 
  8004204c6a:	75 35                	jne    8004204ca1 <dwarf_search_die_within_cu+0xa4>
  8004204c6c:	48 b9 5c a1 20 04 80 	movabs $0x800420a15c,%rcx
  8004204c73:	00 00 00 
  8004204c76:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204c7d:	00 00 00 
  8004204c80:	be 88 02 00 00       	mov    $0x288,%esi
  8004204c85:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204c8c:	00 00 00 
  8004204c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204c94:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204c9b:	00 00 00 
  8004204c9e:	41 ff d0             	callq  *%r8

	level = 1;
  8004204ca1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)

	while (offset < cu.cu_next_offset && offset < dbg->dbg_info_size) {
  8004204ca8:	e9 17 02 00 00       	jmpq   8004204ec4 <dwarf_search_die_within_cu+0x2c7>

		die_offset = offset;
  8004204cad:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004204cb4:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

		abnum = _dwarf_read_uleb128((uint8_t *)dbg->dbg_info_offset_elf, &offset);
  8004204cb8:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004204cbf:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004204cc3:	48 8d 95 80 fc ff ff 	lea    -0x380(%rbp),%rdx
  8004204cca:	48 89 d6             	mov    %rdx,%rsi
  8004204ccd:	48 89 c7             	mov    %rax,%rdi
  8004204cd0:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004204cd7:	00 00 00 
  8004204cda:	ff d0                	callq  *%rax
  8004204cdc:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

		if (abnum == 0) {
  8004204ce0:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004204ce5:	75 22                	jne    8004204d09 <dwarf_search_die_within_cu+0x10c>
			if (level == 0 || !search_sibling) {
  8004204ce7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004204ceb:	74 09                	je     8004204cf6 <dwarf_search_die_within_cu+0xf9>
  8004204ced:	83 bd 74 fc ff ff 00 	cmpl   $0x0,-0x38c(%rbp)
  8004204cf4:	75 0a                	jne    8004204d00 <dwarf_search_die_within_cu+0x103>
				//No more entry
				return (DW_DLE_NO_ENTRY);
  8004204cf6:	b8 04 00 00 00       	mov    $0x4,%eax
  8004204cfb:	e9 f4 01 00 00       	jmpq   8004204ef4 <dwarf_search_die_within_cu+0x2f7>
			}
			/*
			 * Return to previous DIE level.
			 */
			level--;
  8004204d00:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
			continue;
  8004204d04:	e9 bb 01 00 00       	jmpq   8004204ec4 <dwarf_search_die_within_cu+0x2c7>
		}

		if ((ret = _dwarf_abbrev_find(dbg, cu, abnum, &ab)) != DW_DLE_NONE)
  8004204d09:	48 8d 95 b0 fc ff ff 	lea    -0x350(%rbp),%rdx
  8004204d10:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004204d14:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004204d1b:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  8004204d1f:	48 89 34 24          	mov    %rsi,(%rsp)
  8004204d23:	48 8b 75 18          	mov    0x18(%rbp),%rsi
  8004204d27:	48 89 74 24 08       	mov    %rsi,0x8(%rsp)
  8004204d2c:	48 8b 75 20          	mov    0x20(%rbp),%rsi
  8004204d30:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
  8004204d35:	48 8b 75 28          	mov    0x28(%rbp),%rsi
  8004204d39:	48 89 74 24 18       	mov    %rsi,0x18(%rsp)
  8004204d3e:	48 8b 75 30          	mov    0x30(%rbp),%rsi
  8004204d42:	48 89 74 24 20       	mov    %rsi,0x20(%rsp)
  8004204d47:	48 8b 75 38          	mov    0x38(%rbp),%rsi
  8004204d4b:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
  8004204d50:	48 8b 75 40          	mov    0x40(%rbp),%rsi
  8004204d54:	48 89 74 24 30       	mov    %rsi,0x30(%rsp)
  8004204d59:	48 89 ce             	mov    %rcx,%rsi
  8004204d5c:	48 89 c7             	mov    %rax,%rdi
  8004204d5f:	48 b8 3b 44 20 04 80 	movabs $0x800420443b,%rax
  8004204d66:	00 00 00 
  8004204d69:	ff d0                	callq  *%rax
  8004204d6b:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004204d6e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004204d72:	74 08                	je     8004204d7c <dwarf_search_die_within_cu+0x17f>
			return (ret);
  8004204d74:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004204d77:	e9 78 01 00 00       	jmpq   8004204ef4 <dwarf_search_die_within_cu+0x2f7>
		ret_die->die_offset = die_offset;
  8004204d7c:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204d83:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004204d87:	48 89 10             	mov    %rdx,(%rax)
		ret_die->die_abnum  = abnum;
  8004204d8a:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204d91:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004204d95:	48 89 50 10          	mov    %rdx,0x10(%rax)
		ret_die->die_ab  = ab;
  8004204d99:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204da0:	48 8d 78 20          	lea    0x20(%rax),%rdi
  8004204da4:	48 8d 95 b0 fc ff ff 	lea    -0x350(%rbp),%rdx
  8004204dab:	b8 66 00 00 00       	mov    $0x66,%eax
  8004204db0:	48 89 d6             	mov    %rdx,%rsi
  8004204db3:	48 89 c1             	mov    %rax,%rcx
  8004204db6:	f3 48 a5             	rep movsq %ds:(%rsi),%es:(%rdi)
		ret_die->die_attr_count = 0;
  8004204db9:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204dc0:	c6 80 58 03 00 00 00 	movb   $0x0,0x358(%rax)
		ret_die->die_tag = ab.ab_tag;
  8004204dc7:	48 8b 95 b8 fc ff ff 	mov    -0x348(%rbp),%rdx
  8004204dce:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204dd5:	48 89 50 18          	mov    %rdx,0x18(%rax)
		//ret_die->die_cu  = cu;
		//ret_die->die_dbg = cu->cu_dbg;

		for(i=0; i < ab.ab_atnum; i++)
  8004204dd9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  8004204de0:	e9 8e 00 00 00       	jmpq   8004204e73 <dwarf_search_die_within_cu+0x276>
		{
			if ((ret = _dwarf_attr_init(dbg, &offset, &cu, ret_die, &ab.ab_attrdef[i], ab.ab_attrdef[i].ad_form, 0)) != DW_DLE_NONE)
  8004204de5:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004204de8:	48 63 d0             	movslq %eax,%rdx
  8004204deb:	48 89 d0             	mov    %rdx,%rax
  8004204dee:	48 01 c0             	add    %rax,%rax
  8004204df1:	48 01 d0             	add    %rdx,%rax
  8004204df4:	48 c1 e0 03          	shl    $0x3,%rax
  8004204df8:	48 01 e8             	add    %rbp,%rax
  8004204dfb:	48 2d 18 03 00 00    	sub    $0x318,%rax
  8004204e01:	48 8b 08             	mov    (%rax),%rcx
  8004204e04:	48 8d b5 b0 fc ff ff 	lea    -0x350(%rbp),%rsi
  8004204e0b:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004204e0e:	48 63 d0             	movslq %eax,%rdx
  8004204e11:	48 89 d0             	mov    %rdx,%rax
  8004204e14:	48 01 c0             	add    %rax,%rax
  8004204e17:	48 01 d0             	add    %rdx,%rax
  8004204e1a:	48 c1 e0 03          	shl    $0x3,%rax
  8004204e1e:	48 83 c0 30          	add    $0x30,%rax
  8004204e22:	48 8d 3c 06          	lea    (%rsi,%rax,1),%rdi
  8004204e26:	48 8b 95 78 fc ff ff 	mov    -0x388(%rbp),%rdx
  8004204e2d:	48 8d b5 80 fc ff ff 	lea    -0x380(%rbp),%rsi
  8004204e34:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004204e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%rsp)
  8004204e42:	49 89 c9             	mov    %rcx,%r9
  8004204e45:	49 89 f8             	mov    %rdi,%r8
  8004204e48:	48 89 d1             	mov    %rdx,%rcx
  8004204e4b:	48 8d 55 10          	lea    0x10(%rbp),%rdx
  8004204e4f:	48 89 c7             	mov    %rax,%rdi
  8004204e52:	48 b8 6c 45 20 04 80 	movabs $0x800420456c,%rax
  8004204e59:	00 00 00 
  8004204e5c:	ff d0                	callq  *%rax
  8004204e5e:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004204e61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004204e65:	74 08                	je     8004204e6f <dwarf_search_die_within_cu+0x272>
				return (ret);
  8004204e67:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004204e6a:	e9 85 00 00 00       	jmpq   8004204ef4 <dwarf_search_die_within_cu+0x2f7>
		ret_die->die_attr_count = 0;
		ret_die->die_tag = ab.ab_tag;
		//ret_die->die_cu  = cu;
		//ret_die->die_dbg = cu->cu_dbg;

		for(i=0; i < ab.ab_atnum; i++)
  8004204e6f:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  8004204e73:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004204e76:	48 63 d0             	movslq %eax,%rdx
  8004204e79:	48 8b 85 d8 fc ff ff 	mov    -0x328(%rbp),%rax
  8004204e80:	48 39 c2             	cmp    %rax,%rdx
  8004204e83:	0f 82 5c ff ff ff    	jb     8004204de5 <dwarf_search_die_within_cu+0x1e8>
		{
			if ((ret = _dwarf_attr_init(dbg, &offset, &cu, ret_die, &ab.ab_attrdef[i], ab.ab_attrdef[i].ad_form, 0)) != DW_DLE_NONE)
				return (ret);
		}

		ret_die->die_next_off = offset;
  8004204e89:	48 8b 95 80 fc ff ff 	mov    -0x380(%rbp),%rdx
  8004204e90:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004204e97:	48 89 50 08          	mov    %rdx,0x8(%rax)
		if (search_sibling && level > 0) {
  8004204e9b:	83 bd 74 fc ff ff 00 	cmpl   $0x0,-0x38c(%rbp)
  8004204ea2:	74 19                	je     8004204ebd <dwarf_search_die_within_cu+0x2c0>
  8004204ea4:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004204ea8:	7e 13                	jle    8004204ebd <dwarf_search_die_within_cu+0x2c0>
			//dwarf_dealloc(dbg, die, DW_DLA_DIE);
			if (ab.ab_children == DW_CHILDREN_yes) {
  8004204eaa:	0f b6 85 c0 fc ff ff 	movzbl -0x340(%rbp),%eax
  8004204eb1:	3c 01                	cmp    $0x1,%al
  8004204eb3:	75 06                	jne    8004204ebb <dwarf_search_die_within_cu+0x2be>
				/* Advance to next DIE level. */
				level++;
  8004204eb5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
		}

		ret_die->die_next_off = offset;
		if (search_sibling && level > 0) {
			//dwarf_dealloc(dbg, die, DW_DLA_DIE);
			if (ab.ab_children == DW_CHILDREN_yes) {
  8004204eb9:	eb 09                	jmp    8004204ec4 <dwarf_search_die_within_cu+0x2c7>
  8004204ebb:	eb 07                	jmp    8004204ec4 <dwarf_search_die_within_cu+0x2c7>
				/* Advance to next DIE level. */
				level++;
			}
		} else {
			//*ret_die = die;
			return (DW_DLE_NONE);
  8004204ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204ec2:	eb 30                	jmp    8004204ef4 <dwarf_search_die_within_cu+0x2f7>
	//assert(cu);
	assert(ret_die);

	level = 1;

	while (offset < cu.cu_next_offset && offset < dbg->dbg_info_size) {
  8004204ec4:	48 8b 55 30          	mov    0x30(%rbp),%rdx
  8004204ec8:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004204ecf:	48 39 c2             	cmp    %rax,%rdx
  8004204ed2:	76 1b                	jbe    8004204eef <dwarf_search_die_within_cu+0x2f2>
  8004204ed4:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004204edb:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004204edf:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004204ee6:	48 39 c2             	cmp    %rax,%rdx
  8004204ee9:	0f 87 be fd ff ff    	ja     8004204cad <dwarf_search_die_within_cu+0xb0>
			//*ret_die = die;
			return (DW_DLE_NONE);
		}
	}

	return (DW_DLE_NO_ENTRY);
  8004204eef:	b8 04 00 00 00       	mov    $0x4,%eax
}
  8004204ef4:	c9                   	leaveq 
  8004204ef5:	c3                   	retq   

0000008004204ef6 <dwarf_offdie>:

//Return 0 on success
int
dwarf_offdie(Dwarf_Debug dbg, uint64_t offset, Dwarf_Die *ret_die, Dwarf_CU cu)
{
  8004204ef6:	55                   	push   %rbp
  8004204ef7:	48 89 e5             	mov    %rsp,%rbp
  8004204efa:	48 83 ec 60          	sub    $0x60,%rsp
  8004204efe:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004204f02:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004204f06:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int ret;

	assert(dbg);
  8004204f0a:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004204f0f:	75 35                	jne    8004204f46 <dwarf_offdie+0x50>
  8004204f11:	48 b9 58 a1 20 04 80 	movabs $0x800420a158,%rcx
  8004204f18:	00 00 00 
  8004204f1b:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204f22:	00 00 00 
  8004204f25:	be c4 02 00 00       	mov    $0x2c4,%esi
  8004204f2a:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204f31:	00 00 00 
  8004204f34:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204f39:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204f40:	00 00 00 
  8004204f43:	41 ff d0             	callq  *%r8
	assert(ret_die);
  8004204f46:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004204f4b:	75 35                	jne    8004204f82 <dwarf_offdie+0x8c>
  8004204f4d:	48 b9 5c a1 20 04 80 	movabs $0x800420a15c,%rcx
  8004204f54:	00 00 00 
  8004204f57:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004204f5e:	00 00 00 
  8004204f61:	be c5 02 00 00       	mov    $0x2c5,%esi
  8004204f66:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004204f6d:	00 00 00 
  8004204f70:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204f75:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004204f7c:	00 00 00 
  8004204f7f:	41 ff d0             	callq  *%r8

	/* First search the current CU. */
	if (offset < cu.cu_next_offset) {
  8004204f82:	48 8b 45 30          	mov    0x30(%rbp),%rax
  8004204f86:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004204f8a:	76 66                	jbe    8004204ff2 <dwarf_offdie+0xfc>
		ret = dwarf_search_die_within_cu(dbg, cu, offset, ret_die, 0);
  8004204f8c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004204f90:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  8004204f94:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204f98:	48 8b 4d 10          	mov    0x10(%rbp),%rcx
  8004204f9c:	48 89 0c 24          	mov    %rcx,(%rsp)
  8004204fa0:	48 8b 4d 18          	mov    0x18(%rbp),%rcx
  8004204fa4:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  8004204fa9:	48 8b 4d 20          	mov    0x20(%rbp),%rcx
  8004204fad:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  8004204fb2:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  8004204fb6:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  8004204fbb:	48 8b 4d 30          	mov    0x30(%rbp),%rcx
  8004204fbf:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
  8004204fc4:	48 8b 4d 38          	mov    0x38(%rbp),%rcx
  8004204fc8:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
  8004204fcd:	48 8b 4d 40          	mov    0x40(%rbp),%rcx
  8004204fd1:	48 89 4c 24 30       	mov    %rcx,0x30(%rsp)
  8004204fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204fdb:	48 89 c7             	mov    %rax,%rdi
  8004204fde:	48 b8 fd 4b 20 04 80 	movabs $0x8004204bfd,%rax
  8004204fe5:	00 00 00 
  8004204fe8:	ff d0                	callq  *%rax
  8004204fea:	89 45 fc             	mov    %eax,-0x4(%rbp)
		return ret;
  8004204fed:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004204ff0:	eb 05                	jmp    8004204ff7 <dwarf_offdie+0x101>
	}

	/*TODO: Search other CU*/
	return DW_DLV_OK;
  8004204ff2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004204ff7:	c9                   	leaveq 
  8004204ff8:	c3                   	retq   

0000008004204ff9 <_dwarf_attr_find>:

Dwarf_Attribute*
_dwarf_attr_find(Dwarf_Die *die, uint16_t attr)
{
  8004204ff9:	55                   	push   %rbp
  8004204ffa:	48 89 e5             	mov    %rsp,%rbp
  8004204ffd:	48 83 ec 1c          	sub    $0x1c,%rsp
  8004205001:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004205005:	89 f0                	mov    %esi,%eax
  8004205007:	66 89 45 e4          	mov    %ax,-0x1c(%rbp)
	Dwarf_Attribute *myat = NULL;
  800420500b:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004205012:	00 
	int i;
    
	for(i=0; i < die->die_attr_count; i++)
  8004205013:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  800420501a:	eb 57                	jmp    8004205073 <_dwarf_attr_find+0x7a>
	{
		if (die->die_attr[i].at_attrib == attr)
  800420501c:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004205020:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004205023:	48 63 d0             	movslq %eax,%rdx
  8004205026:	48 89 d0             	mov    %rdx,%rax
  8004205029:	48 01 c0             	add    %rax,%rax
  800420502c:	48 01 d0             	add    %rdx,%rax
  800420502f:	48 c1 e0 05          	shl    $0x5,%rax
  8004205033:	48 01 c8             	add    %rcx,%rax
  8004205036:	48 05 80 03 00 00    	add    $0x380,%rax
  800420503c:	48 8b 10             	mov    (%rax),%rdx
  800420503f:	0f b7 45 e4          	movzwl -0x1c(%rbp),%eax
  8004205043:	48 39 c2             	cmp    %rax,%rdx
  8004205046:	75 27                	jne    800420506f <_dwarf_attr_find+0x76>
		{
			myat = &(die->die_attr[i]);
  8004205048:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420504b:	48 63 d0             	movslq %eax,%rdx
  800420504e:	48 89 d0             	mov    %rdx,%rax
  8004205051:	48 01 c0             	add    %rax,%rax
  8004205054:	48 01 d0             	add    %rdx,%rax
  8004205057:	48 c1 e0 05          	shl    $0x5,%rax
  800420505b:	48 8d 90 70 03 00 00 	lea    0x370(%rax),%rdx
  8004205062:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004205066:	48 01 d0             	add    %rdx,%rax
  8004205069:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			break;
  800420506d:	eb 17                	jmp    8004205086 <_dwarf_attr_find+0x8d>
_dwarf_attr_find(Dwarf_Die *die, uint16_t attr)
{
	Dwarf_Attribute *myat = NULL;
	int i;
    
	for(i=0; i < die->die_attr_count; i++)
  800420506f:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  8004205073:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004205077:	0f b6 80 58 03 00 00 	movzbl 0x358(%rax),%eax
  800420507e:	0f b6 c0             	movzbl %al,%eax
  8004205081:	3b 45 f4             	cmp    -0xc(%rbp),%eax
  8004205084:	7f 96                	jg     800420501c <_dwarf_attr_find+0x23>
			myat = &(die->die_attr[i]);
			break;
		}
	}

	return myat;
  8004205086:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800420508a:	c9                   	leaveq 
  800420508b:	c3                   	retq   

000000800420508c <dwarf_siblingof>:

//Return 0 on success
int
dwarf_siblingof(Dwarf_Debug dbg, Dwarf_Die *die, Dwarf_Die *ret_die,
		Dwarf_CU *cu)
{
  800420508c:	55                   	push   %rbp
  800420508d:	48 89 e5             	mov    %rsp,%rbp
  8004205090:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
  8004205094:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004205098:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420509c:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80042050a0:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
	Dwarf_Attribute *at;
	uint64_t offset;
	int ret, search_sibling;

	assert(dbg);
  80042050a4:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80042050a9:	75 35                	jne    80042050e0 <dwarf_siblingof+0x54>
  80042050ab:	48 b9 58 a1 20 04 80 	movabs $0x800420a158,%rcx
  80042050b2:	00 00 00 
  80042050b5:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  80042050bc:	00 00 00 
  80042050bf:	be ec 02 00 00       	mov    $0x2ec,%esi
  80042050c4:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  80042050cb:	00 00 00 
  80042050ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80042050d3:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042050da:	00 00 00 
  80042050dd:	41 ff d0             	callq  *%r8
	assert(ret_die);
  80042050e0:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  80042050e5:	75 35                	jne    800420511c <dwarf_siblingof+0x90>
  80042050e7:	48 b9 5c a1 20 04 80 	movabs $0x800420a15c,%rcx
  80042050ee:	00 00 00 
  80042050f1:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  80042050f8:	00 00 00 
  80042050fb:	be ed 02 00 00       	mov    $0x2ed,%esi
  8004205100:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004205107:	00 00 00 
  800420510a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420510f:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004205116:	00 00 00 
  8004205119:	41 ff d0             	callq  *%r8
	assert(cu);
  800420511c:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  8004205121:	75 35                	jne    8004205158 <dwarf_siblingof+0xcc>
  8004205123:	48 b9 64 a1 20 04 80 	movabs $0x800420a164,%rcx
  800420512a:	00 00 00 
  800420512d:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004205134:	00 00 00 
  8004205137:	be ee 02 00 00       	mov    $0x2ee,%esi
  800420513c:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004205143:	00 00 00 
  8004205146:	b8 00 00 00 00       	mov    $0x0,%eax
  800420514b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004205152:	00 00 00 
  8004205155:	41 ff d0             	callq  *%r8

	/* Application requests the first DIE in this CU. */
	if (die == NULL)
  8004205158:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420515d:	75 65                	jne    80042051c4 <dwarf_siblingof+0x138>
		return (dwarf_offdie(dbg, cu->cu_die_offset, ret_die, *cu));
  800420515f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205163:	48 8b 70 28          	mov    0x28(%rax),%rsi
  8004205167:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420516b:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420516f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205173:	48 8b 38             	mov    (%rax),%rdi
  8004205176:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420517a:	48 8b 78 08          	mov    0x8(%rax),%rdi
  800420517e:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  8004205183:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8004205187:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  800420518c:	48 8b 78 18          	mov    0x18(%rax),%rdi
  8004205190:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  8004205195:	48 8b 78 20          	mov    0x20(%rax),%rdi
  8004205199:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  800420519e:	48 8b 78 28          	mov    0x28(%rax),%rdi
  80042051a2:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  80042051a7:	48 8b 40 30          	mov    0x30(%rax),%rax
  80042051ab:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  80042051b0:	48 89 cf             	mov    %rcx,%rdi
  80042051b3:	48 b8 f6 4e 20 04 80 	movabs $0x8004204ef6,%rax
  80042051ba:	00 00 00 
  80042051bd:	ff d0                	callq  *%rax
  80042051bf:	e9 0a 01 00 00       	jmpq   80042052ce <dwarf_siblingof+0x242>

	/*
	 * If the DIE doesn't have any children, its sibling sits next
	 * right to it.
	 */
	search_sibling = 0;
  80042051c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	if (die->die_ab.ab_children == DW_CHILDREN_no)
  80042051cb:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042051cf:	0f b6 40 30          	movzbl 0x30(%rax),%eax
  80042051d3:	84 c0                	test   %al,%al
  80042051d5:	75 0e                	jne    80042051e5 <dwarf_siblingof+0x159>
		offset = die->die_next_off;
  80042051d7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042051db:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042051df:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042051e3:	eb 6b                	jmp    8004205250 <dwarf_siblingof+0x1c4>
	else {
		/*
		 * Look for DW_AT_sibling attribute for the offset of
		 * its sibling.
		 */
		if ((at = _dwarf_attr_find(die, DW_AT_sibling)) != NULL) {
  80042051e5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042051e9:	be 01 00 00 00       	mov    $0x1,%esi
  80042051ee:	48 89 c7             	mov    %rax,%rdi
  80042051f1:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  80042051f8:	00 00 00 
  80042051fb:	ff d0                	callq  *%rax
  80042051fd:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004205201:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004205206:	74 35                	je     800420523d <dwarf_siblingof+0x1b1>
			if (at->at_form != DW_FORM_ref_addr)
  8004205208:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420520c:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004205210:	48 83 f8 10          	cmp    $0x10,%rax
  8004205214:	74 19                	je     800420522f <dwarf_siblingof+0x1a3>
				offset = at->u[0].u64 + cu->cu_offset;
  8004205216:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420521a:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420521e:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205222:	48 8b 40 30          	mov    0x30(%rax),%rax
  8004205226:	48 01 d0             	add    %rdx,%rax
  8004205229:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420522d:	eb 21                	jmp    8004205250 <dwarf_siblingof+0x1c4>
			else
				offset = at->u[0].u64;
  800420522f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004205233:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004205237:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420523b:	eb 13                	jmp    8004205250 <dwarf_siblingof+0x1c4>
		} else {
			offset = die->die_next_off;
  800420523d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205241:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004205245:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			search_sibling = 1;
  8004205249:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%rbp)
		}
	}

	ret = dwarf_search_die_within_cu(dbg, *cu, offset, ret_die, search_sibling);
  8004205250:	8b 4d f4             	mov    -0xc(%rbp),%ecx
  8004205253:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004205257:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
  800420525b:	48 8b 7d d8          	mov    -0x28(%rbp),%rdi
  800420525f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205263:	4c 8b 00             	mov    (%rax),%r8
  8004205266:	4c 89 04 24          	mov    %r8,(%rsp)
  800420526a:	4c 8b 40 08          	mov    0x8(%rax),%r8
  800420526e:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  8004205273:	4c 8b 40 10          	mov    0x10(%rax),%r8
  8004205277:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
  800420527c:	4c 8b 40 18          	mov    0x18(%rax),%r8
  8004205280:	4c 89 44 24 18       	mov    %r8,0x18(%rsp)
  8004205285:	4c 8b 40 20          	mov    0x20(%rax),%r8
  8004205289:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  800420528e:	4c 8b 40 28          	mov    0x28(%rax),%r8
  8004205292:	4c 89 44 24 28       	mov    %r8,0x28(%rsp)
  8004205297:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420529b:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  80042052a0:	48 b8 fd 4b 20 04 80 	movabs $0x8004204bfd,%rax
  80042052a7:	00 00 00 
  80042052aa:	ff d0                	callq  *%rax
  80042052ac:	89 45 e4             	mov    %eax,-0x1c(%rbp)


	if (ret == DW_DLE_NO_ENTRY) {
  80042052af:	83 7d e4 04          	cmpl   $0x4,-0x1c(%rbp)
  80042052b3:	75 07                	jne    80042052bc <dwarf_siblingof+0x230>
		return (DW_DLV_NO_ENTRY);
  80042052b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80042052ba:	eb 12                	jmp    80042052ce <dwarf_siblingof+0x242>
	} else if (ret != DW_DLE_NONE)
  80042052bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  80042052c0:	74 07                	je     80042052c9 <dwarf_siblingof+0x23d>
		return (DW_DLV_ERROR);
  80042052c2:	b8 01 00 00 00       	mov    $0x1,%eax
  80042052c7:	eb 05                	jmp    80042052ce <dwarf_siblingof+0x242>


	return (DW_DLV_OK);
  80042052c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042052ce:	c9                   	leaveq 
  80042052cf:	c3                   	retq   

00000080042052d0 <dwarf_child>:

int
dwarf_child(Dwarf_Debug dbg, Dwarf_CU *cu, Dwarf_Die *die, Dwarf_Die *ret_die)
{
  80042052d0:	55                   	push   %rbp
  80042052d1:	48 89 e5             	mov    %rsp,%rbp
  80042052d4:	48 83 ec 70          	sub    $0x70,%rsp
  80042052d8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042052dc:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80042052e0:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80042052e4:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
	int ret;

	assert(die);
  80042052e8:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80042052ed:	75 35                	jne    8004205324 <dwarf_child+0x54>
  80042052ef:	48 b9 67 a1 20 04 80 	movabs $0x800420a167,%rcx
  80042052f6:	00 00 00 
  80042052f9:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004205300:	00 00 00 
  8004205303:	be 1c 03 00 00       	mov    $0x31c,%esi
  8004205308:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  800420530f:	00 00 00 
  8004205312:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205317:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420531e:	00 00 00 
  8004205321:	41 ff d0             	callq  *%r8
	assert(ret_die);
  8004205324:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004205329:	75 35                	jne    8004205360 <dwarf_child+0x90>
  800420532b:	48 b9 5c a1 20 04 80 	movabs $0x800420a15c,%rcx
  8004205332:	00 00 00 
  8004205335:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  800420533c:	00 00 00 
  800420533f:	be 1d 03 00 00       	mov    $0x31d,%esi
  8004205344:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  800420534b:	00 00 00 
  800420534e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205353:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420535a:	00 00 00 
  800420535d:	41 ff d0             	callq  *%r8
	assert(dbg);
  8004205360:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004205365:	75 35                	jne    800420539c <dwarf_child+0xcc>
  8004205367:	48 b9 58 a1 20 04 80 	movabs $0x800420a158,%rcx
  800420536e:	00 00 00 
  8004205371:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  8004205378:	00 00 00 
  800420537b:	be 1e 03 00 00       	mov    $0x31e,%esi
  8004205380:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  8004205387:	00 00 00 
  800420538a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420538f:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004205396:	00 00 00 
  8004205399:	41 ff d0             	callq  *%r8
	assert(cu);
  800420539c:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  80042053a1:	75 35                	jne    80042053d8 <dwarf_child+0x108>
  80042053a3:	48 b9 64 a1 20 04 80 	movabs $0x800420a164,%rcx
  80042053aa:	00 00 00 
  80042053ad:	48 ba ca 9f 20 04 80 	movabs $0x8004209fca,%rdx
  80042053b4:	00 00 00 
  80042053b7:	be 1f 03 00 00       	mov    $0x31f,%esi
  80042053bc:	48 bf df 9f 20 04 80 	movabs $0x8004209fdf,%rdi
  80042053c3:	00 00 00 
  80042053c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80042053cb:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042053d2:	00 00 00 
  80042053d5:	41 ff d0             	callq  *%r8

	if (die->die_ab.ab_children == DW_CHILDREN_no)
  80042053d8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042053dc:	0f b6 40 30          	movzbl 0x30(%rax),%eax
  80042053e0:	84 c0                	test   %al,%al
  80042053e2:	75 0a                	jne    80042053ee <dwarf_child+0x11e>
		return (DW_DLE_NO_ENTRY);
  80042053e4:	b8 04 00 00 00       	mov    $0x4,%eax
  80042053e9:	e9 84 00 00 00       	jmpq   8004205472 <dwarf_child+0x1a2>

	ret = dwarf_search_die_within_cu(dbg, *cu, die->die_next_off, ret_die, 0);
  80042053ee:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042053f2:	48 8b 70 08          	mov    0x8(%rax),%rsi
  80042053f6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042053fa:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  80042053fe:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004205402:	48 8b 08             	mov    (%rax),%rcx
  8004205405:	48 89 0c 24          	mov    %rcx,(%rsp)
  8004205409:	48 8b 48 08          	mov    0x8(%rax),%rcx
  800420540d:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  8004205412:	48 8b 48 10          	mov    0x10(%rax),%rcx
  8004205416:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  800420541b:	48 8b 48 18          	mov    0x18(%rax),%rcx
  800420541f:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  8004205424:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205428:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
  800420542d:	48 8b 48 28          	mov    0x28(%rax),%rcx
  8004205431:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
  8004205436:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420543a:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  800420543f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004205444:	48 b8 fd 4b 20 04 80 	movabs $0x8004204bfd,%rax
  800420544b:	00 00 00 
  800420544e:	ff d0                	callq  *%rax
  8004205450:	89 45 fc             	mov    %eax,-0x4(%rbp)

	if (ret == DW_DLE_NO_ENTRY) {
  8004205453:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  8004205457:	75 07                	jne    8004205460 <dwarf_child+0x190>
		DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
		return (DW_DLV_NO_ENTRY);
  8004205459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420545e:	eb 12                	jmp    8004205472 <dwarf_child+0x1a2>
	} else if (ret != DW_DLE_NONE)
  8004205460:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004205464:	74 07                	je     800420546d <dwarf_child+0x19d>
		return (DW_DLV_ERROR);
  8004205466:	b8 01 00 00 00       	mov    $0x1,%eax
  800420546b:	eb 05                	jmp    8004205472 <dwarf_child+0x1a2>

	return (DW_DLV_OK);
  800420546d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004205472:	c9                   	leaveq 
  8004205473:	c3                   	retq   

0000008004205474 <_dwarf_find_section_enhanced>:


int  _dwarf_find_section_enhanced(Dwarf_Section *ds)
{
  8004205474:	55                   	push   %rbp
  8004205475:	48 89 e5             	mov    %rsp,%rbp
  8004205478:	48 83 ec 20          	sub    $0x20,%rsp
  800420547c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Dwarf_Section *secthdr = _dwarf_find_section(ds->ds_name);
  8004205480:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004205484:	48 8b 00             	mov    (%rax),%rax
  8004205487:	48 89 c7             	mov    %rax,%rdi
  800420548a:	48 b8 9b 87 20 04 80 	movabs $0x800420879b,%rax
  8004205491:	00 00 00 
  8004205494:	ff d0                	callq  *%rax
  8004205496:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	ds->ds_data = secthdr->ds_data;//(Dwarf_Small*)((uint8_t *)elf_base_ptr + secthdr->sh_offset);
  800420549a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420549e:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042054a2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042054a6:	48 89 50 08          	mov    %rdx,0x8(%rax)
	ds->ds_addr = secthdr->ds_addr;
  80042054aa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054ae:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042054b2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042054b6:	48 89 50 10          	mov    %rdx,0x10(%rax)
	ds->ds_size = secthdr->ds_size;
  80042054ba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054be:	48 8b 50 18          	mov    0x18(%rax),%rdx
  80042054c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042054c6:	48 89 50 18          	mov    %rdx,0x18(%rax)
	return 0;
  80042054ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042054cf:	c9                   	leaveq 
  80042054d0:	c3                   	retq   

00000080042054d1 <_dwarf_frame_params_init>:

extern int  _dwarf_find_section_enhanced(Dwarf_Section *ds);

void
_dwarf_frame_params_init(Dwarf_Debug dbg)
{
  80042054d1:	55                   	push   %rbp
  80042054d2:	48 89 e5             	mov    %rsp,%rbp
  80042054d5:	48 83 ec 08          	sub    $0x8,%rsp
  80042054d9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	/* Initialise call frame related parameters. */
	dbg->dbg_frame_rule_table_size = DW_FRAME_LAST_REG_NUM;
  80042054dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054e1:	66 c7 40 48 42 00    	movw   $0x42,0x48(%rax)
	dbg->dbg_frame_rule_initial_value = DW_FRAME_REG_INITIAL_VALUE;
  80042054e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054eb:	66 c7 40 4a 0b 04    	movw   $0x40b,0x4a(%rax)
	dbg->dbg_frame_cfa_value = DW_FRAME_CFA_COL3;
  80042054f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054f5:	66 c7 40 4c 9c 05    	movw   $0x59c,0x4c(%rax)
	dbg->dbg_frame_same_value = DW_FRAME_SAME_VAL;
  80042054fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042054ff:	66 c7 40 4e 0b 04    	movw   $0x40b,0x4e(%rax)
	dbg->dbg_frame_undefined_value = DW_FRAME_UNDEFINED_VAL;
  8004205505:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004205509:	66 c7 40 50 0a 04    	movw   $0x40a,0x50(%rax)
}
  800420550f:	c9                   	leaveq 
  8004205510:	c3                   	retq   

0000008004205511 <dwarf_get_fde_at_pc>:

int
dwarf_get_fde_at_pc(Dwarf_Debug dbg, Dwarf_Addr pc,
		    struct _Dwarf_Fde *ret_fde, Dwarf_Cie cie,
		    Dwarf_Error *error)
{
  8004205511:	55                   	push   %rbp
  8004205512:	48 89 e5             	mov    %rsp,%rbp
  8004205515:	48 83 ec 40          	sub    $0x40,%rsp
  8004205519:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420551d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004205521:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004205525:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  8004205529:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
	Dwarf_Fde fde = ret_fde;
  800420552d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004205531:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	memset(fde, 0, sizeof(struct _Dwarf_Fde));
  8004205535:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004205539:	ba 80 00 00 00       	mov    $0x80,%edx
  800420553e:	be 00 00 00 00       	mov    $0x0,%esi
  8004205543:	48 89 c7             	mov    %rax,%rdi
  8004205546:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  800420554d:	00 00 00 
  8004205550:	ff d0                	callq  *%rax
	fde->fde_cie = cie;
  8004205552:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004205556:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420555a:	48 89 50 08          	mov    %rdx,0x8(%rax)
	
	if (ret_fde == NULL)
  800420555e:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004205563:	75 07                	jne    800420556c <dwarf_get_fde_at_pc+0x5b>
		return (DW_DLV_ERROR);
  8004205565:	b8 01 00 00 00       	mov    $0x1,%eax
  800420556a:	eb 75                	jmp    80042055e1 <dwarf_get_fde_at_pc+0xd0>

	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
  800420556c:	eb 59                	jmp    80042055c7 <dwarf_get_fde_at_pc+0xb6>
		if (_dwarf_get_next_fde(dbg, true, error, fde) < 0)
  800420556e:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  8004205572:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004205576:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420557a:	be 01 00 00 00       	mov    $0x1,%esi
  800420557f:	48 89 c7             	mov    %rax,%rdi
  8004205582:	48 b8 26 77 20 04 80 	movabs $0x8004207726,%rax
  8004205589:	00 00 00 
  800420558c:	ff d0                	callq  *%rax
  800420558e:	85 c0                	test   %eax,%eax
  8004205590:	79 07                	jns    8004205599 <dwarf_get_fde_at_pc+0x88>
		{
			return DW_DLV_NO_ENTRY;
  8004205592:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004205597:	eb 48                	jmp    80042055e1 <dwarf_get_fde_at_pc+0xd0>
		}
		if (pc >= fde->fde_initloc && pc < fde->fde_initloc +
  8004205599:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420559d:	48 8b 40 30          	mov    0x30(%rax),%rax
  80042055a1:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  80042055a5:	77 20                	ja     80042055c7 <dwarf_get_fde_at_pc+0xb6>
  80042055a7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042055ab:	48 8b 50 30          	mov    0x30(%rax),%rdx
		    fde->fde_adrange)
  80042055af:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042055b3:	48 8b 40 38          	mov    0x38(%rax),%rax
	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
		if (_dwarf_get_next_fde(dbg, true, error, fde) < 0)
		{
			return DW_DLV_NO_ENTRY;
		}
		if (pc >= fde->fde_initloc && pc < fde->fde_initloc +
  80042055b7:	48 01 d0             	add    %rdx,%rax
  80042055ba:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  80042055be:	76 07                	jbe    80042055c7 <dwarf_get_fde_at_pc+0xb6>
		    fde->fde_adrange)
			return (DW_DLV_OK);
  80042055c0:	b8 00 00 00 00       	mov    $0x0,%eax
  80042055c5:	eb 1a                	jmp    80042055e1 <dwarf_get_fde_at_pc+0xd0>
	fde->fde_cie = cie;
	
	if (ret_fde == NULL)
		return (DW_DLV_ERROR);

	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
  80042055c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042055cb:	48 8b 50 30          	mov    0x30(%rax),%rdx
  80042055cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042055d3:	48 8b 40 40          	mov    0x40(%rax),%rax
  80042055d7:	48 39 c2             	cmp    %rax,%rdx
  80042055da:	72 92                	jb     800420556e <dwarf_get_fde_at_pc+0x5d>
		    fde->fde_adrange)
			return (DW_DLV_OK);
	}

	DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
	return (DW_DLV_NO_ENTRY);
  80042055dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  80042055e1:	c9                   	leaveq 
  80042055e2:	c3                   	retq   

00000080042055e3 <_dwarf_frame_regtable_copy>:

int
_dwarf_frame_regtable_copy(Dwarf_Debug dbg, Dwarf_Regtable3 **dest,
			   Dwarf_Regtable3 *src, Dwarf_Error *error)
{
  80042055e3:	55                   	push   %rbp
  80042055e4:	48 89 e5             	mov    %rsp,%rbp
  80042055e7:	53                   	push   %rbx
  80042055e8:	48 83 ec 38          	sub    $0x38,%rsp
  80042055ec:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80042055f0:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  80042055f4:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80042055f8:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
	int i;

	assert(dest != NULL);
  80042055fc:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004205601:	75 35                	jne    8004205638 <_dwarf_frame_regtable_copy+0x55>
  8004205603:	48 b9 7a a1 20 04 80 	movabs $0x800420a17a,%rcx
  800420560a:	00 00 00 
  800420560d:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  8004205614:	00 00 00 
  8004205617:	be 57 00 00 00       	mov    $0x57,%esi
  800420561c:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  8004205623:	00 00 00 
  8004205626:	b8 00 00 00 00       	mov    $0x0,%eax
  800420562b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004205632:	00 00 00 
  8004205635:	41 ff d0             	callq  *%r8
	assert(src != NULL);
  8004205638:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800420563d:	75 35                	jne    8004205674 <_dwarf_frame_regtable_copy+0x91>
  800420563f:	48 b9 b2 a1 20 04 80 	movabs $0x800420a1b2,%rcx
  8004205646:	00 00 00 
  8004205649:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  8004205650:	00 00 00 
  8004205653:	be 58 00 00 00       	mov    $0x58,%esi
  8004205658:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  800420565f:	00 00 00 
  8004205662:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205667:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420566e:	00 00 00 
  8004205671:	41 ff d0             	callq  *%r8

	if (*dest == NULL) {
  8004205674:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205678:	48 8b 00             	mov    (%rax),%rax
  800420567b:	48 85 c0             	test   %rax,%rax
  800420567e:	75 39                	jne    80042056b9 <_dwarf_frame_regtable_copy+0xd6>
		*dest = &global_rt_table_shadow;
  8004205680:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205684:	48 bb 20 cd 21 04 80 	movabs $0x800421cd20,%rbx
  800420568b:	00 00 00 
  800420568e:	48 89 18             	mov    %rbx,(%rax)
		(*dest)->rt3_reg_table_size = src->rt3_reg_table_size;
  8004205691:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205695:	48 8b 00             	mov    (%rax),%rax
  8004205698:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420569c:	0f b7 52 18          	movzwl 0x18(%rdx),%edx
  80042056a0:	66 89 50 18          	mov    %dx,0x18(%rax)
		(*dest)->rt3_rules = global_rules_shadow;
  80042056a4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042056a8:	48 8b 00             	mov    (%rax),%rax
  80042056ab:	48 bb c0 ce 21 04 80 	movabs $0x800421cec0,%rbx
  80042056b2:	00 00 00 
  80042056b5:	48 89 58 20          	mov    %rbx,0x20(%rax)
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
  80042056b9:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  80042056bd:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042056c1:	48 8b 00             	mov    (%rax),%rax
  80042056c4:	ba 18 00 00 00       	mov    $0x18,%edx
  80042056c9:	48 89 ce             	mov    %rcx,%rsi
  80042056cc:	48 89 c7             	mov    %rax,%rdi
  80042056cf:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  80042056d6:	00 00 00 
  80042056d9:	ff d0                	callq  *%rax
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  80042056db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  80042056e2:	eb 5a                	jmp    800420573e <_dwarf_frame_regtable_copy+0x15b>
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
  80042056e4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042056e8:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042056ec:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042056ef:	48 63 d0             	movslq %eax,%rdx
  80042056f2:	48 89 d0             	mov    %rdx,%rax
  80042056f5:	48 01 c0             	add    %rax,%rax
  80042056f8:	48 01 d0             	add    %rdx,%rax
  80042056fb:	48 c1 e0 03          	shl    $0x3,%rax
  80042056ff:	48 01 c1             	add    %rax,%rcx
  8004205702:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205706:	48 8b 00             	mov    (%rax),%rax
  8004205709:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420570d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004205710:	48 63 d0             	movslq %eax,%rdx
  8004205713:	48 89 d0             	mov    %rdx,%rax
  8004205716:	48 01 c0             	add    %rax,%rax
  8004205719:	48 01 d0             	add    %rdx,%rax
  800420571c:	48 c1 e0 03          	shl    $0x3,%rax
  8004205720:	48 01 f0             	add    %rsi,%rax
  8004205723:	ba 18 00 00 00       	mov    $0x18,%edx
  8004205728:	48 89 ce             	mov    %rcx,%rsi
  800420572b:	48 89 c7             	mov    %rax,%rdi
  800420572e:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004205735:	00 00 00 
  8004205738:	ff d0                	callq  *%rax

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
		     i < src->rt3_reg_table_size; i++)
  800420573a:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  800420573e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205742:	48 8b 00             	mov    (%rax),%rax
  8004205745:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205749:	0f b7 c0             	movzwl %ax,%eax
  800420574c:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420574f:	7e 10                	jle    8004205761 <_dwarf_frame_regtable_copy+0x17e>
		     i < src->rt3_reg_table_size; i++)
  8004205751:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004205755:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205759:	0f b7 c0             	movzwl %ax,%eax
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  800420575c:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420575f:	7f 83                	jg     80042056e4 <_dwarf_frame_regtable_copy+0x101>
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
  8004205761:	eb 32                	jmp    8004205795 <_dwarf_frame_regtable_copy+0x1b2>
		(*dest)->rt3_rules[i].dw_regnum =
  8004205763:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205767:	48 8b 00             	mov    (%rax),%rax
  800420576a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420576e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004205771:	48 63 d0             	movslq %eax,%rdx
  8004205774:	48 89 d0             	mov    %rdx,%rax
  8004205777:	48 01 c0             	add    %rax,%rax
  800420577a:	48 01 d0             	add    %rdx,%rax
  800420577d:	48 c1 e0 03          	shl    $0x3,%rax
  8004205781:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
			dbg->dbg_frame_undefined_value;
  8004205785:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004205789:	0f b7 40 50          	movzwl 0x50(%rax),%eax
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
		(*dest)->rt3_rules[i].dw_regnum =
  800420578d:	66 89 42 02          	mov    %ax,0x2(%rdx)
	for (i = 0; i < (*dest)->rt3_reg_table_size &&
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
  8004205791:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  8004205795:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205799:	48 8b 00             	mov    (%rax),%rax
  800420579c:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042057a0:	0f b7 c0             	movzwl %ax,%eax
  80042057a3:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  80042057a6:	7f bb                	jg     8004205763 <_dwarf_frame_regtable_copy+0x180>
		(*dest)->rt3_rules[i].dw_regnum =
			dbg->dbg_frame_undefined_value;

	return (DW_DLE_NONE);
  80042057a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042057ad:	48 83 c4 38          	add    $0x38,%rsp
  80042057b1:	5b                   	pop    %rbx
  80042057b2:	5d                   	pop    %rbp
  80042057b3:	c3                   	retq   

00000080042057b4 <_dwarf_frame_run_inst>:

static int
_dwarf_frame_run_inst(Dwarf_Debug dbg, Dwarf_Regtable3 *rt, uint8_t *insts,
		      Dwarf_Unsigned len, Dwarf_Unsigned caf, Dwarf_Signed daf, Dwarf_Addr pc,
		      Dwarf_Addr pc_req, Dwarf_Addr *row_pc, Dwarf_Error *error)
{
  80042057b4:	55                   	push   %rbp
  80042057b5:	48 89 e5             	mov    %rsp,%rbp
  80042057b8:	53                   	push   %rbx
  80042057b9:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  80042057c0:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  80042057c4:	48 89 75 90          	mov    %rsi,-0x70(%rbp)
  80042057c8:	48 89 55 88          	mov    %rdx,-0x78(%rbp)
  80042057cc:	48 89 4d 80          	mov    %rcx,-0x80(%rbp)
  80042057d0:	4c 89 85 78 ff ff ff 	mov    %r8,-0x88(%rbp)
  80042057d7:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
			ret = DW_DLE_DF_REG_NUM_TOO_HIGH;               \
			goto program_done;                              \
		}                                                       \
	} while(0)

	ret = DW_DLE_NONE;
  80042057de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
	init_rt = saved_rt = NULL;
  80042057e5:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80042057ec:	00 
  80042057ed:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042057f1:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
	*row_pc = pc;
  80042057f5:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042057f9:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  80042057fd:	48 89 10             	mov    %rdx,(%rax)

	/* Save a copy of the table as initial state. */
	_dwarf_frame_regtable_copy(dbg, &init_rt, rt, error);
  8004205800:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  8004205804:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  8004205808:	48 8d 75 b0          	lea    -0x50(%rbp),%rsi
  800420580c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205810:	48 89 c7             	mov    %rax,%rdi
  8004205813:	48 b8 e3 55 20 04 80 	movabs $0x80042055e3,%rax
  800420581a:	00 00 00 
  800420581d:	ff d0                	callq  *%rax
	p = insts;
  800420581f:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004205823:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
	pe = p + len;
  8004205827:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800420582b:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420582f:	48 01 d0             	add    %rdx,%rax
  8004205832:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

	while (p < pe) {
  8004205836:	e9 3a 0d 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		if (*p == DW_CFA_nop) {
  800420583b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420583f:	0f b6 00             	movzbl (%rax),%eax
  8004205842:	84 c0                	test   %al,%al
  8004205844:	75 11                	jne    8004205857 <_dwarf_frame_run_inst+0xa3>
			p++;
  8004205846:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420584a:	48 83 c0 01          	add    $0x1,%rax
  800420584e:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			continue;
  8004205852:	e9 1e 0d 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		}

		high2 = *p & 0xc0;
  8004205857:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420585b:	0f b6 00             	movzbl (%rax),%eax
  800420585e:	83 e0 c0             	and    $0xffffffc0,%eax
  8004205861:	88 45 df             	mov    %al,-0x21(%rbp)
		low6 = *p & 0x3f;
  8004205864:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004205868:	0f b6 00             	movzbl (%rax),%eax
  800420586b:	83 e0 3f             	and    $0x3f,%eax
  800420586e:	88 45 de             	mov    %al,-0x22(%rbp)
		p++;
  8004205871:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004205875:	48 83 c0 01          	add    $0x1,%rax
  8004205879:	48 89 45 a0          	mov    %rax,-0x60(%rbp)

		if (high2 > 0) {
  800420587d:	80 7d df 00          	cmpb   $0x0,-0x21(%rbp)
  8004205881:	0f 84 a1 01 00 00    	je     8004205a28 <_dwarf_frame_run_inst+0x274>
			switch (high2) {
  8004205887:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  800420588b:	3d 80 00 00 00       	cmp    $0x80,%eax
  8004205890:	74 38                	je     80042058ca <_dwarf_frame_run_inst+0x116>
  8004205892:	3d c0 00 00 00       	cmp    $0xc0,%eax
  8004205897:	0f 84 01 01 00 00    	je     800420599e <_dwarf_frame_run_inst+0x1ea>
  800420589d:	83 f8 40             	cmp    $0x40,%eax
  80042058a0:	0f 85 71 01 00 00    	jne    8004205a17 <_dwarf_frame_run_inst+0x263>
			case DW_CFA_advance_loc:
			        pc += low6 * caf;
  80042058a6:	0f b6 45 de          	movzbl -0x22(%rbp),%eax
  80042058aa:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  80042058b1:	ff 
  80042058b2:	48 01 45 10          	add    %rax,0x10(%rbp)
			        if (pc_req < pc)
  80042058b6:	48 8b 45 18          	mov    0x18(%rbp),%rax
  80042058ba:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  80042058be:	73 05                	jae    80042058c5 <_dwarf_frame_run_inst+0x111>
			                goto program_done;
  80042058c0:	e9 be 0c 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			        break;
  80042058c5:	e9 59 01 00 00       	jmpq   8004205a23 <_dwarf_frame_run_inst+0x26f>
			case DW_CFA_offset:
			        *row_pc = pc;
  80042058ca:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042058ce:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  80042058d2:	48 89 10             	mov    %rdx,(%rax)
			        CHECK_TABLE_SIZE(low6);
  80042058d5:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  80042058d9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042058dd:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042058e1:	66 39 c2             	cmp    %ax,%dx
  80042058e4:	72 0c                	jb     80042058f2 <_dwarf_frame_run_inst+0x13e>
  80042058e6:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  80042058ed:	e9 91 0c 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			        RL[low6].dw_offset_relevant = 1;
  80042058f2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042058f6:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042058fa:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  80042058fe:	48 89 d0             	mov    %rdx,%rax
  8004205901:	48 01 c0             	add    %rax,%rax
  8004205904:	48 01 d0             	add    %rdx,%rax
  8004205907:	48 c1 e0 03          	shl    $0x3,%rax
  800420590b:	48 01 c8             	add    %rcx,%rax
  800420590e:	c6 00 01             	movb   $0x1,(%rax)
			        RL[low6].dw_value_type = DW_EXPR_OFFSET;
  8004205911:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205915:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205919:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420591d:	48 89 d0             	mov    %rdx,%rax
  8004205920:	48 01 c0             	add    %rax,%rax
  8004205923:	48 01 d0             	add    %rdx,%rax
  8004205926:	48 c1 e0 03          	shl    $0x3,%rax
  800420592a:	48 01 c8             	add    %rcx,%rax
  800420592d:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			        RL[low6].dw_regnum = dbg->dbg_frame_cfa_value;
  8004205931:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205935:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205939:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420593d:	48 89 d0             	mov    %rdx,%rax
  8004205940:	48 01 c0             	add    %rax,%rax
  8004205943:	48 01 d0             	add    %rdx,%rax
  8004205946:	48 c1 e0 03          	shl    $0x3,%rax
  800420594a:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420594e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205952:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  8004205956:	66 89 42 02          	mov    %ax,0x2(%rdx)
			        RL[low6].dw_offset_or_block_len =
  800420595a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420595e:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205962:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  8004205966:	48 89 d0             	mov    %rdx,%rax
  8004205969:	48 01 c0             	add    %rax,%rax
  800420596c:	48 01 d0             	add    %rdx,%rax
  800420596f:	48 c1 e0 03          	shl    $0x3,%rax
  8004205973:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
					_dwarf_decode_uleb128(&p) * daf;
  8004205977:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420597b:	48 89 c7             	mov    %rax,%rdi
  800420597e:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205985:	00 00 00 
  8004205988:	ff d0                	callq  *%rax
  800420598a:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  8004205991:	48 0f af c2          	imul   %rdx,%rax
			        *row_pc = pc;
			        CHECK_TABLE_SIZE(low6);
			        RL[low6].dw_offset_relevant = 1;
			        RL[low6].dw_value_type = DW_EXPR_OFFSET;
			        RL[low6].dw_regnum = dbg->dbg_frame_cfa_value;
			        RL[low6].dw_offset_or_block_len =
  8004205995:	48 89 43 08          	mov    %rax,0x8(%rbx)
					_dwarf_decode_uleb128(&p) * daf;
			        break;
  8004205999:	e9 85 00 00 00       	jmpq   8004205a23 <_dwarf_frame_run_inst+0x26f>
			case DW_CFA_restore:
			        *row_pc = pc;
  800420599e:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042059a2:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  80042059a6:	48 89 10             	mov    %rdx,(%rax)
			        CHECK_TABLE_SIZE(low6);
  80042059a9:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  80042059ad:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042059b1:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042059b5:	66 39 c2             	cmp    %ax,%dx
  80042059b8:	72 0c                	jb     80042059c6 <_dwarf_frame_run_inst+0x212>
  80042059ba:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  80042059c1:	e9 bd 0b 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			        memcpy(&RL[low6], &INITRL[low6],
  80042059c6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042059ca:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042059ce:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  80042059d2:	48 89 d0             	mov    %rdx,%rax
  80042059d5:	48 01 c0             	add    %rax,%rax
  80042059d8:	48 01 d0             	add    %rdx,%rax
  80042059db:	48 c1 e0 03          	shl    $0x3,%rax
  80042059df:	48 01 c1             	add    %rax,%rcx
  80042059e2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042059e6:	48 8b 70 20          	mov    0x20(%rax),%rsi
  80042059ea:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  80042059ee:	48 89 d0             	mov    %rdx,%rax
  80042059f1:	48 01 c0             	add    %rax,%rax
  80042059f4:	48 01 d0             	add    %rdx,%rax
  80042059f7:	48 c1 e0 03          	shl    $0x3,%rax
  80042059fb:	48 01 f0             	add    %rsi,%rax
  80042059fe:	ba 18 00 00 00       	mov    $0x18,%edx
  8004205a03:	48 89 ce             	mov    %rcx,%rsi
  8004205a06:	48 89 c7             	mov    %rax,%rdi
  8004205a09:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004205a10:	00 00 00 
  8004205a13:	ff d0                	callq  *%rax
				       sizeof(Dwarf_Regtable_Entry3));
			        break;
  8004205a15:	eb 0c                	jmp    8004205a23 <_dwarf_frame_run_inst+0x26f>
			default:
			        DWARF_SET_ERROR(dbg, error,
						DW_DLE_FRAME_INSTR_EXEC_ERROR);
			        ret = DW_DLE_FRAME_INSTR_EXEC_ERROR;
  8004205a17:	c7 45 ec 15 00 00 00 	movl   $0x15,-0x14(%rbp)
			        goto program_done;
  8004205a1e:	e9 60 0b 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			}

			continue;
  8004205a23:	e9 4d 0b 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		}

		switch (low6) {
  8004205a28:	0f b6 45 de          	movzbl -0x22(%rbp),%eax
  8004205a2c:	83 f8 16             	cmp    $0x16,%eax
  8004205a2f:	0f 87 37 0b 00 00    	ja     800420656c <_dwarf_frame_run_inst+0xdb8>
  8004205a35:	89 c0                	mov    %eax,%eax
  8004205a37:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004205a3e:	00 
  8004205a3f:	48 b8 c0 a1 20 04 80 	movabs $0x800420a1c0,%rax
  8004205a46:	00 00 00 
  8004205a49:	48 01 d0             	add    %rdx,%rax
  8004205a4c:	48 8b 00             	mov    (%rax),%rax
  8004205a4f:	ff e0                	jmpq   *%rax
		case DW_CFA_set_loc:
			pc = dbg->decode(&p, dbg->dbg_pointer_size);
  8004205a51:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205a55:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004205a59:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004205a5d:	8b 4a 28             	mov    0x28(%rdx),%ecx
  8004205a60:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  8004205a64:	89 ce                	mov    %ecx,%esi
  8004205a66:	48 89 d7             	mov    %rdx,%rdi
  8004205a69:	ff d0                	callq  *%rax
  8004205a6b:	48 89 45 10          	mov    %rax,0x10(%rbp)
			if (pc_req < pc)
  8004205a6f:	48 8b 45 18          	mov    0x18(%rbp),%rax
  8004205a73:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  8004205a77:	73 05                	jae    8004205a7e <_dwarf_frame_run_inst+0x2ca>
			        goto program_done;
  8004205a79:	e9 05 0b 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			break;
  8004205a7e:	e9 f2 0a 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc1:
			pc += dbg->decode(&p, 1) * caf;
  8004205a83:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205a87:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004205a8b:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  8004205a8f:	be 01 00 00 00       	mov    $0x1,%esi
  8004205a94:	48 89 d7             	mov    %rdx,%rdi
  8004205a97:	ff d0                	callq  *%rax
  8004205a99:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  8004205aa0:	ff 
  8004205aa1:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  8004205aa5:	48 8b 45 18          	mov    0x18(%rbp),%rax
  8004205aa9:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  8004205aad:	73 05                	jae    8004205ab4 <_dwarf_frame_run_inst+0x300>
			        goto program_done;
  8004205aaf:	e9 cf 0a 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			break;
  8004205ab4:	e9 bc 0a 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc2:
			pc += dbg->decode(&p, 2) * caf;
  8004205ab9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205abd:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004205ac1:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  8004205ac5:	be 02 00 00 00       	mov    $0x2,%esi
  8004205aca:	48 89 d7             	mov    %rdx,%rdi
  8004205acd:	ff d0                	callq  *%rax
  8004205acf:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  8004205ad6:	ff 
  8004205ad7:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  8004205adb:	48 8b 45 18          	mov    0x18(%rbp),%rax
  8004205adf:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  8004205ae3:	73 05                	jae    8004205aea <_dwarf_frame_run_inst+0x336>
			        goto program_done;
  8004205ae5:	e9 99 0a 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			break;
  8004205aea:	e9 86 0a 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc4:
			pc += dbg->decode(&p, 4) * caf;
  8004205aef:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205af3:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004205af7:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  8004205afb:	be 04 00 00 00       	mov    $0x4,%esi
  8004205b00:	48 89 d7             	mov    %rdx,%rdi
  8004205b03:	ff d0                	callq  *%rax
  8004205b05:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  8004205b0c:	ff 
  8004205b0d:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  8004205b11:	48 8b 45 18          	mov    0x18(%rbp),%rax
  8004205b15:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  8004205b19:	73 05                	jae    8004205b20 <_dwarf_frame_run_inst+0x36c>
			        goto program_done;
  8004205b1b:	e9 63 0a 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			break;
  8004205b20:	e9 50 0a 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_offset_extended:
			*row_pc = pc;
  8004205b25:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205b29:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205b2d:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205b30:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205b34:	48 89 c7             	mov    %rax,%rdi
  8004205b37:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205b3e:	00 00 00 
  8004205b41:	ff d0                	callq  *%rax
  8004205b43:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  8004205b47:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205b4b:	48 89 c7             	mov    %rax,%rdi
  8004205b4e:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205b55:	00 00 00 
  8004205b58:	ff d0                	callq  *%rax
  8004205b5a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205b5e:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205b62:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205b66:	0f b7 c0             	movzwl %ax,%eax
  8004205b69:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205b6d:	77 0c                	ja     8004205b7b <_dwarf_frame_run_inst+0x3c7>
  8004205b6f:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004205b76:	e9 08 0a 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  8004205b7b:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205b7f:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205b83:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205b87:	48 89 d0             	mov    %rdx,%rax
  8004205b8a:	48 01 c0             	add    %rax,%rax
  8004205b8d:	48 01 d0             	add    %rdx,%rax
  8004205b90:	48 c1 e0 03          	shl    $0x3,%rax
  8004205b94:	48 01 c8             	add    %rcx,%rax
  8004205b97:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_OFFSET;
  8004205b9a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205b9e:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205ba2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205ba6:	48 89 d0             	mov    %rdx,%rax
  8004205ba9:	48 01 c0             	add    %rax,%rax
  8004205bac:	48 01 d0             	add    %rdx,%rax
  8004205baf:	48 c1 e0 03          	shl    $0x3,%rax
  8004205bb3:	48 01 c8             	add    %rcx,%rax
  8004205bb6:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  8004205bba:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205bbe:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205bc2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205bc6:	48 89 d0             	mov    %rdx,%rax
  8004205bc9:	48 01 c0             	add    %rax,%rax
  8004205bcc:	48 01 d0             	add    %rdx,%rax
  8004205bcf:	48 c1 e0 03          	shl    $0x3,%rax
  8004205bd3:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004205bd7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205bdb:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  8004205bdf:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = uoff * daf;
  8004205be3:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205be7:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205beb:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205bef:	48 89 d0             	mov    %rdx,%rax
  8004205bf2:	48 01 c0             	add    %rax,%rax
  8004205bf5:	48 01 d0             	add    %rdx,%rax
  8004205bf8:	48 c1 e0 03          	shl    $0x3,%rax
  8004205bfc:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004205c00:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  8004205c07:	48 0f af 45 c8       	imul   -0x38(%rbp),%rax
  8004205c0c:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  8004205c10:	e9 60 09 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_restore_extended:
			*row_pc = pc;
  8004205c15:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205c19:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205c1d:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205c20:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205c24:	48 89 c7             	mov    %rax,%rdi
  8004205c27:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205c2e:	00 00 00 
  8004205c31:	ff d0                	callq  *%rax
  8004205c33:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205c37:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205c3b:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205c3f:	0f b7 c0             	movzwl %ax,%eax
  8004205c42:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205c46:	77 0c                	ja     8004205c54 <_dwarf_frame_run_inst+0x4a0>
  8004205c48:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004205c4f:	e9 2f 09 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			memcpy(&RL[reg], &INITRL[reg],
  8004205c54:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004205c58:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205c5c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205c60:	48 89 d0             	mov    %rdx,%rax
  8004205c63:	48 01 c0             	add    %rax,%rax
  8004205c66:	48 01 d0             	add    %rdx,%rax
  8004205c69:	48 c1 e0 03          	shl    $0x3,%rax
  8004205c6d:	48 01 c1             	add    %rax,%rcx
  8004205c70:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205c74:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004205c78:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205c7c:	48 89 d0             	mov    %rdx,%rax
  8004205c7f:	48 01 c0             	add    %rax,%rax
  8004205c82:	48 01 d0             	add    %rdx,%rax
  8004205c85:	48 c1 e0 03          	shl    $0x3,%rax
  8004205c89:	48 01 f0             	add    %rsi,%rax
  8004205c8c:	ba 18 00 00 00       	mov    $0x18,%edx
  8004205c91:	48 89 ce             	mov    %rcx,%rsi
  8004205c94:	48 89 c7             	mov    %rax,%rdi
  8004205c97:	48 b8 66 32 20 04 80 	movabs $0x8004203266,%rax
  8004205c9e:	00 00 00 
  8004205ca1:	ff d0                	callq  *%rax
			       sizeof(Dwarf_Regtable_Entry3));
			break;
  8004205ca3:	e9 cd 08 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_undefined:
			*row_pc = pc;
  8004205ca8:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205cac:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205cb0:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205cb3:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205cb7:	48 89 c7             	mov    %rax,%rdi
  8004205cba:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205cc1:	00 00 00 
  8004205cc4:	ff d0                	callq  *%rax
  8004205cc6:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205cca:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205cce:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205cd2:	0f b7 c0             	movzwl %ax,%eax
  8004205cd5:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205cd9:	77 0c                	ja     8004205ce7 <_dwarf_frame_run_inst+0x533>
  8004205cdb:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004205ce2:	e9 9c 08 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  8004205ce7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205ceb:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205cef:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205cf3:	48 89 d0             	mov    %rdx,%rax
  8004205cf6:	48 01 c0             	add    %rax,%rax
  8004205cf9:	48 01 d0             	add    %rdx,%rax
  8004205cfc:	48 c1 e0 03          	shl    $0x3,%rax
  8004205d00:	48 01 c8             	add    %rcx,%rax
  8004205d03:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_undefined_value;
  8004205d06:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205d0a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205d0e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205d12:	48 89 d0             	mov    %rdx,%rax
  8004205d15:	48 01 c0             	add    %rax,%rax
  8004205d18:	48 01 d0             	add    %rdx,%rax
  8004205d1b:	48 c1 e0 03          	shl    $0x3,%rax
  8004205d1f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004205d23:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205d27:	0f b7 40 50          	movzwl 0x50(%rax),%eax
  8004205d2b:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  8004205d2f:	e9 41 08 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_same_value:
			reg = _dwarf_decode_uleb128(&p);
  8004205d34:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205d38:	48 89 c7             	mov    %rax,%rdi
  8004205d3b:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205d42:	00 00 00 
  8004205d45:	ff d0                	callq  *%rax
  8004205d47:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205d4b:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205d4f:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205d53:	0f b7 c0             	movzwl %ax,%eax
  8004205d56:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205d5a:	77 0c                	ja     8004205d68 <_dwarf_frame_run_inst+0x5b4>
  8004205d5c:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004205d63:	e9 1b 08 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  8004205d68:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205d6c:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205d70:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205d74:	48 89 d0             	mov    %rdx,%rax
  8004205d77:	48 01 c0             	add    %rax,%rax
  8004205d7a:	48 01 d0             	add    %rdx,%rax
  8004205d7d:	48 c1 e0 03          	shl    $0x3,%rax
  8004205d81:	48 01 c8             	add    %rcx,%rax
  8004205d84:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_same_value;
  8004205d87:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205d8b:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205d8f:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205d93:	48 89 d0             	mov    %rdx,%rax
  8004205d96:	48 01 c0             	add    %rax,%rax
  8004205d99:	48 01 d0             	add    %rdx,%rax
  8004205d9c:	48 c1 e0 03          	shl    $0x3,%rax
  8004205da0:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004205da4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205da8:	0f b7 40 4e          	movzwl 0x4e(%rax),%eax
  8004205dac:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  8004205db0:	e9 c0 07 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_register:
			*row_pc = pc;
  8004205db5:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205db9:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205dbd:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205dc0:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205dc4:	48 89 c7             	mov    %rax,%rdi
  8004205dc7:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205dce:	00 00 00 
  8004205dd1:	ff d0                	callq  *%rax
  8004205dd3:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			reg2 = _dwarf_decode_uleb128(&p);
  8004205dd7:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205ddb:	48 89 c7             	mov    %rax,%rdi
  8004205dde:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205de5:	00 00 00 
  8004205de8:	ff d0                	callq  *%rax
  8004205dea:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205dee:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205df2:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004205df6:	0f b7 c0             	movzwl %ax,%eax
  8004205df9:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205dfd:	77 0c                	ja     8004205e0b <_dwarf_frame_run_inst+0x657>
  8004205dff:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004205e06:	e9 78 07 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  8004205e0b:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205e0f:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205e13:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205e17:	48 89 d0             	mov    %rdx,%rax
  8004205e1a:	48 01 c0             	add    %rax,%rax
  8004205e1d:	48 01 d0             	add    %rdx,%rax
  8004205e20:	48 c1 e0 03          	shl    $0x3,%rax
  8004205e24:	48 01 c8             	add    %rcx,%rax
  8004205e27:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = reg2;
  8004205e2a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205e2e:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004205e32:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205e36:	48 89 d0             	mov    %rdx,%rax
  8004205e39:	48 01 c0             	add    %rax,%rax
  8004205e3c:	48 01 d0             	add    %rdx,%rax
  8004205e3f:	48 c1 e0 03          	shl    $0x3,%rax
  8004205e43:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004205e47:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205e4b:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  8004205e4f:	e9 21 07 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_remember_state:
			_dwarf_frame_regtable_copy(dbg, &saved_rt, rt, error);
  8004205e54:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  8004205e58:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  8004205e5c:	48 8d 75 a8          	lea    -0x58(%rbp),%rsi
  8004205e60:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205e64:	48 89 c7             	mov    %rax,%rdi
  8004205e67:	48 b8 e3 55 20 04 80 	movabs $0x80042055e3,%rax
  8004205e6e:	00 00 00 
  8004205e71:	ff d0                	callq  *%rax
			break;
  8004205e73:	e9 fd 06 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_restore_state:
			*row_pc = pc;
  8004205e78:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205e7c:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205e80:	48 89 10             	mov    %rdx,(%rax)
			_dwarf_frame_regtable_copy(dbg, &rt, saved_rt, error);
  8004205e83:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8004205e87:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  8004205e8b:	48 8d 75 90          	lea    -0x70(%rbp),%rsi
  8004205e8f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205e93:	48 89 c7             	mov    %rax,%rdi
  8004205e96:	48 b8 e3 55 20 04 80 	movabs $0x80042055e3,%rax
  8004205e9d:	00 00 00 
  8004205ea0:	ff d0                	callq  *%rax
			break;
  8004205ea2:	e9 ce 06 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa:
			*row_pc = pc;
  8004205ea7:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205eab:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205eaf:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205eb2:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205eb6:	48 89 c7             	mov    %rax,%rdi
  8004205eb9:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205ec0:	00 00 00 
  8004205ec3:	ff d0                	callq  *%rax
  8004205ec5:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  8004205ec9:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205ecd:	48 89 c7             	mov    %rax,%rdi
  8004205ed0:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205ed7:	00 00 00 
  8004205eda:	ff d0                	callq  *%rax
  8004205edc:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CFA.dw_offset_relevant = 1;
  8004205ee0:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205ee4:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  8004205ee7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205eeb:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_regnum = reg;
  8004205eef:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205ef3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205ef7:	66 89 50 02          	mov    %dx,0x2(%rax)
			CFA.dw_offset_or_block_len = uoff;
  8004205efb:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205eff:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004205f03:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  8004205f07:	e9 69 06 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_register:
			*row_pc = pc;
  8004205f0c:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205f10:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205f14:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205f17:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205f1b:	48 89 c7             	mov    %rax,%rdi
  8004205f1e:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205f25:	00 00 00 
  8004205f28:	ff d0                	callq  *%rax
  8004205f2a:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CFA.dw_regnum = reg;
  8004205f2e:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f32:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004205f36:	66 89 50 02          	mov    %dx,0x2(%rax)
			 * Note that DW_CFA_def_cfa_register change the CFA
			 * rule register while keep the old offset. So we
			 * should not touch the CFA.dw_offset_relevant flag
			 * here.
			 */
			break;
  8004205f3a:	e9 36 06 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_offset:
			*row_pc = pc;
  8004205f3f:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205f43:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205f47:	48 89 10             	mov    %rdx,(%rax)
			uoff = _dwarf_decode_uleb128(&p);
  8004205f4a:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205f4e:	48 89 c7             	mov    %rax,%rdi
  8004205f51:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205f58:	00 00 00 
  8004205f5b:	ff d0                	callq  *%rax
  8004205f5d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CFA.dw_offset_relevant = 1;
  8004205f61:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f65:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  8004205f68:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f6c:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_offset_or_block_len = uoff;
  8004205f70:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f74:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004205f78:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  8004205f7c:	e9 f4 05 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_expression:
			*row_pc = pc;
  8004205f81:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205f85:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205f89:	48 89 10             	mov    %rdx,(%rax)
			CFA.dw_offset_relevant = 0;
  8004205f8c:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f90:	c6 00 00             	movb   $0x0,(%rax)
			CFA.dw_value_type = DW_EXPR_EXPRESSION;
  8004205f93:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205f97:	c6 40 01 02          	movb   $0x2,0x1(%rax)
			CFA.dw_offset_or_block_len = _dwarf_decode_uleb128(&p);
  8004205f9b:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  8004205f9f:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205fa3:	48 89 c7             	mov    %rax,%rdi
  8004205fa6:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205fad:	00 00 00 
  8004205fb0:	ff d0                	callq  *%rax
  8004205fb2:	48 89 43 08          	mov    %rax,0x8(%rbx)
			CFA.dw_block_ptr = p;
  8004205fb6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205fba:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004205fbe:	48 89 50 10          	mov    %rdx,0x10(%rax)
			p += CFA.dw_offset_or_block_len;
  8004205fc2:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004205fc6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004205fca:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004205fce:	48 01 d0             	add    %rdx,%rax
  8004205fd1:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  8004205fd5:	e9 9b 05 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_expression:
			*row_pc = pc;
  8004205fda:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004205fde:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004205fe2:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004205fe5:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004205fe9:	48 89 c7             	mov    %rax,%rdi
  8004205fec:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004205ff3:	00 00 00 
  8004205ff6:	ff d0                	callq  *%rax
  8004205ff8:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  8004205ffc:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206000:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004206004:	0f b7 c0             	movzwl %ax,%eax
  8004206007:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420600b:	77 0c                	ja     8004206019 <_dwarf_frame_run_inst+0x865>
  800420600d:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004206014:	e9 6a 05 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  8004206019:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420601d:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206021:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206025:	48 89 d0             	mov    %rdx,%rax
  8004206028:	48 01 c0             	add    %rax,%rax
  800420602b:	48 01 d0             	add    %rdx,%rax
  800420602e:	48 c1 e0 03          	shl    $0x3,%rax
  8004206032:	48 01 c8             	add    %rcx,%rax
  8004206035:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_value_type = DW_EXPR_EXPRESSION;
  8004206038:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420603c:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206040:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206044:	48 89 d0             	mov    %rdx,%rax
  8004206047:	48 01 c0             	add    %rax,%rax
  800420604a:	48 01 d0             	add    %rdx,%rax
  800420604d:	48 c1 e0 03          	shl    $0x3,%rax
  8004206051:	48 01 c8             	add    %rcx,%rax
  8004206054:	c6 40 01 02          	movb   $0x2,0x1(%rax)
			RL[reg].dw_offset_or_block_len =
  8004206058:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420605c:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206060:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206064:	48 89 d0             	mov    %rdx,%rax
  8004206067:	48 01 c0             	add    %rax,%rax
  800420606a:	48 01 d0             	add    %rdx,%rax
  800420606d:	48 c1 e0 03          	shl    $0x3,%rax
  8004206071:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
				_dwarf_decode_uleb128(&p);
  8004206075:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206079:	48 89 c7             	mov    %rax,%rdi
  800420607c:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004206083:	00 00 00 
  8004206086:	ff d0                	callq  *%rax
			*row_pc = pc;
			reg = _dwarf_decode_uleb128(&p);
			CHECK_TABLE_SIZE(reg);
			RL[reg].dw_offset_relevant = 0;
			RL[reg].dw_value_type = DW_EXPR_EXPRESSION;
			RL[reg].dw_offset_or_block_len =
  8004206088:	48 89 43 08          	mov    %rax,0x8(%rbx)
				_dwarf_decode_uleb128(&p);
			RL[reg].dw_block_ptr = p;
  800420608c:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206090:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206094:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206098:	48 89 d0             	mov    %rdx,%rax
  800420609b:	48 01 c0             	add    %rax,%rax
  800420609e:	48 01 d0             	add    %rdx,%rax
  80042060a1:	48 c1 e0 03          	shl    $0x3,%rax
  80042060a5:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  80042060a9:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042060ad:	48 89 42 10          	mov    %rax,0x10(%rdx)
			p += RL[reg].dw_offset_or_block_len;
  80042060b1:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  80042060b5:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042060b9:	48 8b 70 20          	mov    0x20(%rax),%rsi
  80042060bd:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042060c1:	48 89 d0             	mov    %rdx,%rax
  80042060c4:	48 01 c0             	add    %rax,%rax
  80042060c7:	48 01 d0             	add    %rdx,%rax
  80042060ca:	48 c1 e0 03          	shl    $0x3,%rax
  80042060ce:	48 01 f0             	add    %rsi,%rax
  80042060d1:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042060d5:	48 01 c8             	add    %rcx,%rax
  80042060d8:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  80042060dc:	e9 94 04 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_offset_extended_sf:
			*row_pc = pc;
  80042060e1:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042060e5:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  80042060e9:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  80042060ec:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  80042060f0:	48 89 c7             	mov    %rax,%rdi
  80042060f3:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  80042060fa:	00 00 00 
  80042060fd:	ff d0                	callq  *%rax
  80042060ff:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  8004206103:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206107:	48 89 c7             	mov    %rax,%rdi
  800420610a:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004206111:	00 00 00 
  8004206114:	ff d0                	callq  *%rax
  8004206116:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420611a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420611e:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004206122:	0f b7 c0             	movzwl %ax,%eax
  8004206125:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004206129:	77 0c                	ja     8004206137 <_dwarf_frame_run_inst+0x983>
  800420612b:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  8004206132:	e9 4c 04 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  8004206137:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420613b:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420613f:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206143:	48 89 d0             	mov    %rdx,%rax
  8004206146:	48 01 c0             	add    %rax,%rax
  8004206149:	48 01 d0             	add    %rdx,%rax
  800420614c:	48 c1 e0 03          	shl    $0x3,%rax
  8004206150:	48 01 c8             	add    %rcx,%rax
  8004206153:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_OFFSET;
  8004206156:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420615a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420615e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206162:	48 89 d0             	mov    %rdx,%rax
  8004206165:	48 01 c0             	add    %rax,%rax
  8004206168:	48 01 d0             	add    %rdx,%rax
  800420616b:	48 c1 e0 03          	shl    $0x3,%rax
  800420616f:	48 01 c8             	add    %rcx,%rax
  8004206172:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  8004206176:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420617a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420617e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206182:	48 89 d0             	mov    %rdx,%rax
  8004206185:	48 01 c0             	add    %rax,%rax
  8004206188:	48 01 d0             	add    %rdx,%rax
  800420618b:	48 c1 e0 03          	shl    $0x3,%rax
  800420618f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004206193:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004206197:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420619b:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = soff * daf;
  800420619f:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042061a3:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042061a7:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042061ab:	48 89 d0             	mov    %rdx,%rax
  80042061ae:	48 01 c0             	add    %rax,%rax
  80042061b1:	48 01 d0             	add    %rdx,%rax
  80042061b4:	48 c1 e0 03          	shl    $0x3,%rax
  80042061b8:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  80042061bc:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  80042061c3:	48 0f af 45 b8       	imul   -0x48(%rbp),%rax
  80042061c8:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  80042061cc:	e9 a4 03 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_sf:
			*row_pc = pc;
  80042061d1:	48 8b 45 20          	mov    0x20(%rbp),%rax
  80042061d5:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  80042061d9:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  80042061dc:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  80042061e0:	48 89 c7             	mov    %rax,%rdi
  80042061e3:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  80042061ea:	00 00 00 
  80042061ed:	ff d0                	callq  *%rax
  80042061ef:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  80042061f3:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  80042061f7:	48 89 c7             	mov    %rax,%rdi
  80042061fa:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004206201:	00 00 00 
  8004206204:	ff d0                	callq  *%rax
  8004206206:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CFA.dw_offset_relevant = 1;
  800420620a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420620e:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  8004206211:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206215:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_regnum = reg;
  8004206219:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420621d:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206221:	66 89 50 02          	mov    %dx,0x2(%rax)
			CFA.dw_offset_or_block_len = soff * daf;
  8004206225:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206229:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  8004206230:	48 0f af 55 b8       	imul   -0x48(%rbp),%rdx
  8004206235:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  8004206239:	e9 37 03 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_offset_sf:
			*row_pc = pc;
  800420623e:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004206242:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004206246:	48 89 10             	mov    %rdx,(%rax)
			soff = _dwarf_decode_sleb128(&p);
  8004206249:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420624d:	48 89 c7             	mov    %rax,%rdi
  8004206250:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004206257:	00 00 00 
  800420625a:	ff d0                	callq  *%rax
  800420625c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CFA.dw_offset_relevant = 1;
  8004206260:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206264:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  8004206267:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420626b:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_offset_or_block_len = soff * daf;
  800420626f:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206273:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  800420627a:	48 0f af 55 b8       	imul   -0x48(%rbp),%rdx
  800420627f:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  8004206283:	e9 ed 02 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_offset:
			*row_pc = pc;
  8004206288:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420628c:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004206290:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004206293:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206297:	48 89 c7             	mov    %rax,%rdi
  800420629a:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  80042062a1:	00 00 00 
  80042062a4:	ff d0                	callq  *%rax
  80042062a6:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  80042062aa:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  80042062ae:	48 89 c7             	mov    %rax,%rdi
  80042062b1:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  80042062b8:	00 00 00 
  80042062bb:	ff d0                	callq  *%rax
  80042062bd:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CHECK_TABLE_SIZE(reg);
  80042062c1:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042062c5:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042062c9:	0f b7 c0             	movzwl %ax,%eax
  80042062cc:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  80042062d0:	77 0c                	ja     80042062de <_dwarf_frame_run_inst+0xb2a>
  80042062d2:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  80042062d9:	e9 a5 02 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  80042062de:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042062e2:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042062e6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042062ea:	48 89 d0             	mov    %rdx,%rax
  80042062ed:	48 01 c0             	add    %rax,%rax
  80042062f0:	48 01 d0             	add    %rdx,%rax
  80042062f3:	48 c1 e0 03          	shl    $0x3,%rax
  80042062f7:	48 01 c8             	add    %rcx,%rax
  80042062fa:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_OFFSET;
  80042062fd:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206301:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206305:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206309:	48 89 d0             	mov    %rdx,%rax
  800420630c:	48 01 c0             	add    %rax,%rax
  800420630f:	48 01 d0             	add    %rdx,%rax
  8004206312:	48 c1 e0 03          	shl    $0x3,%rax
  8004206316:	48 01 c8             	add    %rcx,%rax
  8004206319:	c6 40 01 01          	movb   $0x1,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420631d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206321:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206325:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206329:	48 89 d0             	mov    %rdx,%rax
  800420632c:	48 01 c0             	add    %rax,%rax
  800420632f:	48 01 d0             	add    %rdx,%rax
  8004206332:	48 c1 e0 03          	shl    $0x3,%rax
  8004206336:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420633a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420633e:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  8004206342:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = uoff * daf;
  8004206346:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420634a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420634e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206352:	48 89 d0             	mov    %rdx,%rax
  8004206355:	48 01 c0             	add    %rax,%rax
  8004206358:	48 01 d0             	add    %rdx,%rax
  800420635b:	48 c1 e0 03          	shl    $0x3,%rax
  800420635f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004206363:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420636a:	48 0f af 45 c8       	imul   -0x38(%rbp),%rax
  800420636f:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  8004206373:	e9 fd 01 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_offset_sf:
			*row_pc = pc;
  8004206378:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420637c:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004206380:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004206383:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206387:	48 89 c7             	mov    %rax,%rdi
  800420638a:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004206391:	00 00 00 
  8004206394:	ff d0                	callq  *%rax
  8004206396:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  800420639a:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420639e:	48 89 c7             	mov    %rax,%rdi
  80042063a1:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  80042063a8:	00 00 00 
  80042063ab:	ff d0                	callq  *%rax
  80042063ad:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CHECK_TABLE_SIZE(reg);
  80042063b1:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042063b5:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042063b9:	0f b7 c0             	movzwl %ax,%eax
  80042063bc:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  80042063c0:	77 0c                	ja     80042063ce <_dwarf_frame_run_inst+0xc1a>
  80042063c2:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  80042063c9:	e9 b5 01 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  80042063ce:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042063d2:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042063d6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042063da:	48 89 d0             	mov    %rdx,%rax
  80042063dd:	48 01 c0             	add    %rax,%rax
  80042063e0:	48 01 d0             	add    %rdx,%rax
  80042063e3:	48 c1 e0 03          	shl    $0x3,%rax
  80042063e7:	48 01 c8             	add    %rcx,%rax
  80042063ea:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_OFFSET;
  80042063ed:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042063f1:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042063f5:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042063f9:	48 89 d0             	mov    %rdx,%rax
  80042063fc:	48 01 c0             	add    %rax,%rax
  80042063ff:	48 01 d0             	add    %rdx,%rax
  8004206402:	48 c1 e0 03          	shl    $0x3,%rax
  8004206406:	48 01 c8             	add    %rcx,%rax
  8004206409:	c6 40 01 01          	movb   $0x1,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420640d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206411:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206415:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206419:	48 89 d0             	mov    %rdx,%rax
  800420641c:	48 01 c0             	add    %rax,%rax
  800420641f:	48 01 d0             	add    %rdx,%rax
  8004206422:	48 c1 e0 03          	shl    $0x3,%rax
  8004206426:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420642a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420642e:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  8004206432:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = soff * daf;
  8004206436:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420643a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420643e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206442:	48 89 d0             	mov    %rdx,%rax
  8004206445:	48 01 c0             	add    %rax,%rax
  8004206448:	48 01 d0             	add    %rdx,%rax
  800420644b:	48 c1 e0 03          	shl    $0x3,%rax
  800420644f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004206453:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420645a:	48 0f af 45 b8       	imul   -0x48(%rbp),%rax
  800420645f:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  8004206463:	e9 0d 01 00 00       	jmpq   8004206575 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_expression:
			*row_pc = pc;
  8004206468:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420646c:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  8004206470:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  8004206473:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206477:	48 89 c7             	mov    %rax,%rdi
  800420647a:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004206481:	00 00 00 
  8004206484:	ff d0                	callq  *%rax
  8004206486:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420648a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420648e:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004206492:	0f b7 c0             	movzwl %ax,%eax
  8004206495:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004206499:	77 0c                	ja     80042064a7 <_dwarf_frame_run_inst+0xcf3>
  800420649b:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  80042064a2:	e9 dc 00 00 00       	jmpq   8004206583 <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  80042064a7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042064ab:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042064af:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042064b3:	48 89 d0             	mov    %rdx,%rax
  80042064b6:	48 01 c0             	add    %rax,%rax
  80042064b9:	48 01 d0             	add    %rdx,%rax
  80042064bc:	48 c1 e0 03          	shl    $0x3,%rax
  80042064c0:	48 01 c8             	add    %rcx,%rax
  80042064c3:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_EXPRESSION;
  80042064c6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042064ca:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042064ce:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042064d2:	48 89 d0             	mov    %rdx,%rax
  80042064d5:	48 01 c0             	add    %rax,%rax
  80042064d8:	48 01 d0             	add    %rdx,%rax
  80042064db:	48 c1 e0 03          	shl    $0x3,%rax
  80042064df:	48 01 c8             	add    %rcx,%rax
  80042064e2:	c6 40 01 03          	movb   $0x3,0x1(%rax)
			RL[reg].dw_offset_or_block_len =
  80042064e6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042064ea:	48 8b 48 20          	mov    0x20(%rax),%rcx
  80042064ee:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042064f2:	48 89 d0             	mov    %rdx,%rax
  80042064f5:	48 01 c0             	add    %rax,%rax
  80042064f8:	48 01 d0             	add    %rdx,%rax
  80042064fb:	48 c1 e0 03          	shl    $0x3,%rax
  80042064ff:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
				_dwarf_decode_uleb128(&p);
  8004206503:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  8004206507:	48 89 c7             	mov    %rax,%rdi
  800420650a:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004206511:	00 00 00 
  8004206514:	ff d0                	callq  *%rax
			*row_pc = pc;
			reg = _dwarf_decode_uleb128(&p);
			CHECK_TABLE_SIZE(reg);
			RL[reg].dw_offset_relevant = 0;
			RL[reg].dw_value_type = DW_EXPR_VAL_EXPRESSION;
			RL[reg].dw_offset_or_block_len =
  8004206516:	48 89 43 08          	mov    %rax,0x8(%rbx)
				_dwarf_decode_uleb128(&p);
			RL[reg].dw_block_ptr = p;
  800420651a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420651e:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206522:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206526:	48 89 d0             	mov    %rdx,%rax
  8004206529:	48 01 c0             	add    %rax,%rax
  800420652c:	48 01 d0             	add    %rdx,%rax
  800420652f:	48 c1 e0 03          	shl    $0x3,%rax
  8004206533:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  8004206537:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420653b:	48 89 42 10          	mov    %rax,0x10(%rdx)
			p += RL[reg].dw_offset_or_block_len;
  800420653f:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  8004206543:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004206547:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420654b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420654f:	48 89 d0             	mov    %rdx,%rax
  8004206552:	48 01 c0             	add    %rax,%rax
  8004206555:	48 01 d0             	add    %rdx,%rax
  8004206558:	48 c1 e0 03          	shl    $0x3,%rax
  800420655c:	48 01 f0             	add    %rsi,%rax
  800420655f:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004206563:	48 01 c8             	add    %rcx,%rax
  8004206566:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  800420656a:	eb 09                	jmp    8004206575 <_dwarf_frame_run_inst+0xdc1>
		default:
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_FRAME_INSTR_EXEC_ERROR);
			ret = DW_DLE_FRAME_INSTR_EXEC_ERROR;
  800420656c:	c7 45 ec 15 00 00 00 	movl   $0x15,-0x14(%rbp)
			goto program_done;
  8004206573:	eb 0e                	jmp    8004206583 <_dwarf_frame_run_inst+0xdcf>
	/* Save a copy of the table as initial state. */
	_dwarf_frame_regtable_copy(dbg, &init_rt, rt, error);
	p = insts;
	pe = p + len;

	while (p < pe) {
  8004206575:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004206579:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420657d:	0f 82 b8 f2 ff ff    	jb     800420583b <_dwarf_frame_run_inst+0x87>
			goto program_done;
		}
	}

program_done:
	return (ret);
  8004206583:	8b 45 ec             	mov    -0x14(%rbp),%eax
#undef  CFA
#undef  INITCFA
#undef  RL
#undef  INITRL
#undef  CHECK_TABLE_SIZE
}
  8004206586:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  800420658d:	5b                   	pop    %rbx
  800420658e:	5d                   	pop    %rbp
  800420658f:	c3                   	retq   

0000008004206590 <_dwarf_frame_get_internal_table>:
int
_dwarf_frame_get_internal_table(Dwarf_Debug dbg, Dwarf_Fde fde,
				Dwarf_Addr pc_req, Dwarf_Regtable3 **ret_rt,
				Dwarf_Addr *ret_row_pc,
				Dwarf_Error *error)
{
  8004206590:	55                   	push   %rbp
  8004206591:	48 89 e5             	mov    %rsp,%rbp
  8004206594:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
  8004206598:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420659c:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  80042065a0:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  80042065a4:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  80042065a8:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  80042065ac:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
	Dwarf_Cie cie;
	Dwarf_Regtable3 *rt;
	Dwarf_Addr row_pc;
	int i, ret;

	assert(ret_rt != NULL);
  80042065b0:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
  80042065b5:	75 35                	jne    80042065ec <_dwarf_frame_get_internal_table+0x5c>
  80042065b7:	48 b9 78 a2 20 04 80 	movabs $0x800420a278,%rcx
  80042065be:	00 00 00 
  80042065c1:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  80042065c8:	00 00 00 
  80042065cb:	be 83 01 00 00       	mov    $0x183,%esi
  80042065d0:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  80042065d7:	00 00 00 
  80042065da:	b8 00 00 00 00       	mov    $0x0,%eax
  80042065df:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042065e6:	00 00 00 
  80042065e9:	41 ff d0             	callq  *%r8

	//dbg = fde->fde_dbg;
	assert(dbg != NULL);
  80042065ec:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  80042065f1:	75 35                	jne    8004206628 <_dwarf_frame_get_internal_table+0x98>
  80042065f3:	48 b9 87 a2 20 04 80 	movabs $0x800420a287,%rcx
  80042065fa:	00 00 00 
  80042065fd:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  8004206604:	00 00 00 
  8004206607:	be 86 01 00 00       	mov    $0x186,%esi
  800420660c:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  8004206613:	00 00 00 
  8004206616:	b8 00 00 00 00       	mov    $0x0,%eax
  800420661b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004206622:	00 00 00 
  8004206625:	41 ff d0             	callq  *%r8

	rt = dbg->dbg_internal_reg_table;
  8004206628:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420662c:	48 8b 40 58          	mov    0x58(%rax),%rax
  8004206630:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	/* Clear the content of regtable from previous run. */
	memset(&rt->rt3_cfa_rule, 0, sizeof(Dwarf_Regtable_Entry3));
  8004206634:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206638:	ba 18 00 00 00       	mov    $0x18,%edx
  800420663d:	be 00 00 00 00       	mov    $0x0,%esi
  8004206642:	48 89 c7             	mov    %rax,%rdi
  8004206645:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  800420664c:	00 00 00 
  800420664f:	ff d0                	callq  *%rax
	memset(rt->rt3_rules, 0, rt->rt3_reg_table_size *
  8004206651:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206655:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  8004206659:	0f b7 d0             	movzwl %ax,%edx
  800420665c:	48 89 d0             	mov    %rdx,%rax
  800420665f:	48 01 c0             	add    %rax,%rax
  8004206662:	48 01 d0             	add    %rdx,%rax
  8004206665:	48 c1 e0 03          	shl    $0x3,%rax
  8004206669:	48 89 c2             	mov    %rax,%rdx
  800420666c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206670:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004206674:	be 00 00 00 00       	mov    $0x0,%esi
  8004206679:	48 89 c7             	mov    %rax,%rdi
  800420667c:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  8004206683:	00 00 00 
  8004206686:	ff d0                	callq  *%rax
	       sizeof(Dwarf_Regtable_Entry3));

	/* Set rules to initial values. */
	for (i = 0; i < rt->rt3_reg_table_size; i++)
  8004206688:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  800420668f:	eb 2f                	jmp    80042066c0 <_dwarf_frame_get_internal_table+0x130>
		rt->rt3_rules[i].dw_regnum = dbg->dbg_frame_rule_initial_value;
  8004206691:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206695:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206699:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420669c:	48 63 d0             	movslq %eax,%rdx
  800420669f:	48 89 d0             	mov    %rdx,%rax
  80042066a2:	48 01 c0             	add    %rax,%rax
  80042066a5:	48 01 d0             	add    %rdx,%rax
  80042066a8:	48 c1 e0 03          	shl    $0x3,%rax
  80042066ac:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  80042066b0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042066b4:	0f b7 40 4a          	movzwl 0x4a(%rax),%eax
  80042066b8:	66 89 42 02          	mov    %ax,0x2(%rdx)
	memset(&rt->rt3_cfa_rule, 0, sizeof(Dwarf_Regtable_Entry3));
	memset(rt->rt3_rules, 0, rt->rt3_reg_table_size *
	       sizeof(Dwarf_Regtable_Entry3));

	/* Set rules to initial values. */
	for (i = 0; i < rt->rt3_reg_table_size; i++)
  80042066bc:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80042066c0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042066c4:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  80042066c8:	0f b7 c0             	movzwl %ax,%eax
  80042066cb:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  80042066ce:	7f c1                	jg     8004206691 <_dwarf_frame_get_internal_table+0x101>
		rt->rt3_rules[i].dw_regnum = dbg->dbg_frame_rule_initial_value;

	/* Run initial instructions in CIE. */
	cie = fde->fde_cie;
  80042066d0:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042066d4:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042066d8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	assert(cie != NULL);
  80042066dc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042066e1:	75 35                	jne    8004206718 <_dwarf_frame_get_internal_table+0x188>
  80042066e3:	48 b9 93 a2 20 04 80 	movabs $0x800420a293,%rcx
  80042066ea:	00 00 00 
  80042066ed:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  80042066f4:	00 00 00 
  80042066f7:	be 95 01 00 00       	mov    $0x195,%esi
  80042066fc:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  8004206703:	00 00 00 
  8004206706:	b8 00 00 00 00       	mov    $0x0,%eax
  800420670b:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004206712:	00 00 00 
  8004206715:	41 ff d0             	callq  *%r8
	ret = _dwarf_frame_run_inst(dbg, rt, cie->cie_initinst,
  8004206718:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420671c:	4c 8b 48 40          	mov    0x40(%rax),%r9
  8004206720:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206724:	4c 8b 40 38          	mov    0x38(%rax),%r8
  8004206728:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420672c:	48 8b 48 70          	mov    0x70(%rax),%rcx
  8004206730:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206734:	48 8b 50 68          	mov    0x68(%rax),%rdx
  8004206738:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  800420673c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206740:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  8004206744:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  8004206749:	48 8d 7d d8          	lea    -0x28(%rbp),%rdi
  800420674d:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  8004206752:	48 c7 44 24 08 ff ff 	movq   $0xffffffffffffffff,0x8(%rsp)
  8004206759:	ff ff 
  800420675b:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  8004206762:	00 
  8004206763:	48 89 c7             	mov    %rax,%rdi
  8004206766:	48 b8 b4 57 20 04 80 	movabs $0x80042057b4,%rax
  800420676d:	00 00 00 
  8004206770:	ff d0                	callq  *%rax
  8004206772:	89 45 e4             	mov    %eax,-0x1c(%rbp)
				    cie->cie_instlen, cie->cie_caf,
				    cie->cie_daf, 0, ~0ULL,
				    &row_pc, error);
	if (ret != DW_DLE_NONE)
  8004206775:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004206779:	74 08                	je     8004206783 <_dwarf_frame_get_internal_table+0x1f3>
		return (ret);
  800420677b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420677e:	e9 98 00 00 00       	jmpq   800420681b <_dwarf_frame_get_internal_table+0x28b>
	/* Run instructions in FDE. */
	if (pc_req >= fde->fde_initloc) {
  8004206783:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206787:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420678b:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  800420678f:	77 6f                	ja     8004206800 <_dwarf_frame_get_internal_table+0x270>
		ret = _dwarf_frame_run_inst(dbg, rt, fde->fde_inst,
  8004206791:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206795:	48 8b 78 30          	mov    0x30(%rax),%rdi
  8004206799:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420679d:	4c 8b 48 40          	mov    0x40(%rax),%r9
  80042067a1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042067a5:	4c 8b 50 38          	mov    0x38(%rax),%r10
  80042067a9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042067ad:	48 8b 48 58          	mov    0x58(%rax),%rcx
  80042067b1:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042067b5:	48 8b 50 50          	mov    0x50(%rax),%rdx
  80042067b9:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  80042067bd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042067c1:	4c 8b 45 a0          	mov    -0x60(%rbp),%r8
  80042067c5:	4c 89 44 24 18       	mov    %r8,0x18(%rsp)
  80042067ca:	4c 8d 45 d8          	lea    -0x28(%rbp),%r8
  80042067ce:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
  80042067d3:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  80042067d7:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  80042067dc:	48 89 3c 24          	mov    %rdi,(%rsp)
  80042067e0:	4d 89 d0             	mov    %r10,%r8
  80042067e3:	48 89 c7             	mov    %rax,%rdi
  80042067e6:	48 b8 b4 57 20 04 80 	movabs $0x80042057b4,%rax
  80042067ed:	00 00 00 
  80042067f0:	ff d0                	callq  *%rax
  80042067f2:	89 45 e4             	mov    %eax,-0x1c(%rbp)
					    fde->fde_instlen, cie->cie_caf,
					    cie->cie_daf,
					    fde->fde_initloc, pc_req,
					    &row_pc, error);
		if (ret != DW_DLE_NONE)
  80042067f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  80042067f9:	74 05                	je     8004206800 <_dwarf_frame_get_internal_table+0x270>
			return (ret);
  80042067fb:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042067fe:	eb 1b                	jmp    800420681b <_dwarf_frame_get_internal_table+0x28b>
	}

	*ret_rt = rt;
  8004206800:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004206804:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004206808:	48 89 10             	mov    %rdx,(%rax)
	*ret_row_pc = row_pc;
  800420680b:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420680f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004206813:	48 89 10             	mov    %rdx,(%rax)

	return (DW_DLE_NONE);
  8004206816:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420681b:	c9                   	leaveq 
  800420681c:	c3                   	retq   

000000800420681d <dwarf_get_fde_info_for_all_regs>:
int
dwarf_get_fde_info_for_all_regs(Dwarf_Debug dbg, Dwarf_Fde fde,
				Dwarf_Addr pc_requested,
				Dwarf_Regtable *reg_table, Dwarf_Addr *row_pc,
				Dwarf_Error *error)
{
  800420681d:	55                   	push   %rbp
  800420681e:	48 89 e5             	mov    %rsp,%rbp
  8004206821:	48 83 ec 50          	sub    $0x50,%rsp
  8004206825:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004206829:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420682d:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8004206831:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
  8004206835:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
  8004206839:	4c 89 4d b0          	mov    %r9,-0x50(%rbp)
	Dwarf_Regtable3 *rt;
	Dwarf_Addr pc;
	Dwarf_Half cfa;
	int i, ret;

	if (fde == NULL || reg_table == NULL) {
  800420683d:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004206842:	74 07                	je     800420684b <dwarf_get_fde_info_for_all_regs+0x2e>
  8004206844:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  8004206849:	75 0a                	jne    8004206855 <dwarf_get_fde_info_for_all_regs+0x38>
		DWARF_SET_ERROR(dbg, error, DW_DLE_ARGUMENT);
		return (DW_DLV_ERROR);
  800420684b:	b8 01 00 00 00       	mov    $0x1,%eax
  8004206850:	e9 eb 02 00 00       	jmpq   8004206b40 <dwarf_get_fde_info_for_all_regs+0x323>
	}

	assert(dbg != NULL);
  8004206855:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  800420685a:	75 35                	jne    8004206891 <dwarf_get_fde_info_for_all_regs+0x74>
  800420685c:	48 b9 87 a2 20 04 80 	movabs $0x800420a287,%rcx
  8004206863:	00 00 00 
  8004206866:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  800420686d:	00 00 00 
  8004206870:	be bf 01 00 00       	mov    $0x1bf,%esi
  8004206875:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  800420687c:	00 00 00 
  800420687f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206884:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420688b:	00 00 00 
  800420688e:	41 ff d0             	callq  *%r8

	if (pc_requested < fde->fde_initloc ||
  8004206891:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004206895:	48 8b 40 30          	mov    0x30(%rax),%rax
  8004206899:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  800420689d:	77 19                	ja     80042068b8 <dwarf_get_fde_info_for_all_regs+0x9b>
	    pc_requested >= fde->fde_initloc + fde->fde_adrange) {
  800420689f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042068a3:	48 8b 50 30          	mov    0x30(%rax),%rdx
  80042068a7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042068ab:	48 8b 40 38          	mov    0x38(%rax),%rax
  80042068af:	48 01 d0             	add    %rdx,%rax
		return (DW_DLV_ERROR);
	}

	assert(dbg != NULL);

	if (pc_requested < fde->fde_initloc ||
  80042068b2:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80042068b6:	77 0a                	ja     80042068c2 <dwarf_get_fde_info_for_all_regs+0xa5>
	    pc_requested >= fde->fde_initloc + fde->fde_adrange) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_PC_NOT_IN_FDE_RANGE);
		return (DW_DLV_ERROR);
  80042068b8:	b8 01 00 00 00       	mov    $0x1,%eax
  80042068bd:	e9 7e 02 00 00       	jmpq   8004206b40 <dwarf_get_fde_info_for_all_regs+0x323>
	}

	ret = _dwarf_frame_get_internal_table(dbg, fde, pc_requested, &rt, &pc,
  80042068c2:	4c 8b 45 b0          	mov    -0x50(%rbp),%r8
  80042068c6:	48 8d 7d e0          	lea    -0x20(%rbp),%rdi
  80042068ca:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  80042068ce:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042068d2:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  80042068d6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042068da:	4d 89 c1             	mov    %r8,%r9
  80042068dd:	49 89 f8             	mov    %rdi,%r8
  80042068e0:	48 89 c7             	mov    %rax,%rdi
  80042068e3:	48 b8 90 65 20 04 80 	movabs $0x8004206590,%rax
  80042068ea:	00 00 00 
  80042068ed:	ff d0                	callq  *%rax
  80042068ef:	89 45 f8             	mov    %eax,-0x8(%rbp)
					      error);
	if (ret != DW_DLE_NONE)
  80042068f2:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  80042068f6:	74 0a                	je     8004206902 <dwarf_get_fde_info_for_all_regs+0xe5>
		return (DW_DLV_ERROR);
  80042068f8:	b8 01 00 00 00       	mov    $0x1,%eax
  80042068fd:	e9 3e 02 00 00       	jmpq   8004206b40 <dwarf_get_fde_info_for_all_regs+0x323>
	/*
	 * Copy the CFA rule to the column intended for holding the CFA,
	 * if it's within the range of regtable.
	 */
#define CFA rt->rt3_cfa_rule
	cfa = dbg->dbg_frame_cfa_value;
  8004206902:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004206906:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420690a:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
	if (cfa < DW_REG_TABLE_SIZE) {
  800420690e:	66 83 7d f6 41       	cmpw   $0x41,-0xa(%rbp)
  8004206913:	0f 87 b1 00 00 00    	ja     80042069ca <dwarf_get_fde_info_for_all_regs+0x1ad>
		reg_table->rules[cfa].dw_offset_relevant =
  8004206919:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
			CFA.dw_offset_relevant;
  800420691d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206921:	0f b6 00             	movzbl (%rax),%eax
	 * if it's within the range of regtable.
	 */
#define CFA rt->rt3_cfa_rule
	cfa = dbg->dbg_frame_cfa_value;
	if (cfa < DW_REG_TABLE_SIZE) {
		reg_table->rules[cfa].dw_offset_relevant =
  8004206924:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206928:	48 63 c9             	movslq %ecx,%rcx
  800420692b:	48 83 c1 01          	add    $0x1,%rcx
  800420692f:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206933:	48 01 ca             	add    %rcx,%rdx
  8004206936:	88 02                	mov    %al,(%rdx)
			CFA.dw_offset_relevant;
		reg_table->rules[cfa].dw_value_type = CFA.dw_value_type;
  8004206938:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420693c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206940:	0f b6 40 01          	movzbl 0x1(%rax),%eax
  8004206944:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206948:	48 63 c9             	movslq %ecx,%rcx
  800420694b:	48 83 c1 01          	add    $0x1,%rcx
  800420694f:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206953:	48 01 ca             	add    %rcx,%rdx
  8004206956:	88 42 01             	mov    %al,0x1(%rdx)
		reg_table->rules[cfa].dw_regnum = CFA.dw_regnum;
  8004206959:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420695d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206961:	0f b7 40 02          	movzwl 0x2(%rax),%eax
  8004206965:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206969:	48 63 c9             	movslq %ecx,%rcx
  800420696c:	48 83 c1 01          	add    $0x1,%rcx
  8004206970:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206974:	48 01 ca             	add    %rcx,%rdx
  8004206977:	66 89 42 02          	mov    %ax,0x2(%rdx)
		reg_table->rules[cfa].dw_offset = CFA.dw_offset_or_block_len;
  800420697b:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420697f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206983:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004206987:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420698b:	48 63 c9             	movslq %ecx,%rcx
  800420698e:	48 83 c1 01          	add    $0x1,%rcx
  8004206992:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206996:	48 01 ca             	add    %rcx,%rdx
  8004206999:	48 83 c2 08          	add    $0x8,%rdx
  800420699d:	48 89 02             	mov    %rax,(%rdx)
		reg_table->cfa_rule = reg_table->rules[cfa];
  80042069a0:	0f b7 55 f6          	movzwl -0xa(%rbp),%edx
  80042069a4:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  80042069a8:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042069ac:	48 63 d2             	movslq %edx,%rdx
  80042069af:	48 83 c2 01          	add    $0x1,%rdx
  80042069b3:	48 c1 e2 04          	shl    $0x4,%rdx
  80042069b7:	48 01 d0             	add    %rdx,%rax
  80042069ba:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042069be:	48 8b 00             	mov    (%rax),%rax
  80042069c1:	48 89 01             	mov    %rax,(%rcx)
  80042069c4:	48 89 51 08          	mov    %rdx,0x8(%rcx)
  80042069c8:	eb 3c                	jmp    8004206a06 <dwarf_get_fde_info_for_all_regs+0x1e9>
	} else {
		reg_table->cfa_rule.dw_offset_relevant =
		    CFA.dw_offset_relevant;
  80042069ca:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042069ce:	0f b6 10             	movzbl (%rax),%edx
		reg_table->rules[cfa].dw_value_type = CFA.dw_value_type;
		reg_table->rules[cfa].dw_regnum = CFA.dw_regnum;
		reg_table->rules[cfa].dw_offset = CFA.dw_offset_or_block_len;
		reg_table->cfa_rule = reg_table->rules[cfa];
	} else {
		reg_table->cfa_rule.dw_offset_relevant =
  80042069d1:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042069d5:	88 10                	mov    %dl,(%rax)
		    CFA.dw_offset_relevant;
		reg_table->cfa_rule.dw_value_type = CFA.dw_value_type;
  80042069d7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042069db:	0f b6 50 01          	movzbl 0x1(%rax),%edx
  80042069df:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042069e3:	88 50 01             	mov    %dl,0x1(%rax)
		reg_table->cfa_rule.dw_regnum = CFA.dw_regnum;
  80042069e6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042069ea:	0f b7 50 02          	movzwl 0x2(%rax),%edx
  80042069ee:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042069f2:	66 89 50 02          	mov    %dx,0x2(%rax)
		reg_table->cfa_rule.dw_offset = CFA.dw_offset_or_block_len;
  80042069f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042069fa:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042069fe:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206a02:	48 89 50 08          	mov    %rdx,0x8(%rax)
	}

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
  8004206a06:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004206a0d:	e9 fd 00 00 00       	jmpq   8004206b0f <dwarf_get_fde_info_for_all_regs+0x2f2>
	     i++) {

		/* Do not overwrite CFA column */
		if (i == cfa)
  8004206a12:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
  8004206a16:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  8004206a19:	75 05                	jne    8004206a20 <dwarf_get_fde_info_for_all_regs+0x203>
			continue;
  8004206a1b:	e9 eb 00 00 00       	jmpq   8004206b0b <dwarf_get_fde_info_for_all_regs+0x2ee>

		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
  8004206a20:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206a24:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206a28:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004206a2b:	48 63 d0             	movslq %eax,%rdx
  8004206a2e:	48 89 d0             	mov    %rdx,%rax
  8004206a31:	48 01 c0             	add    %rax,%rax
  8004206a34:	48 01 d0             	add    %rdx,%rax
  8004206a37:	48 c1 e0 03          	shl    $0x3,%rax
  8004206a3b:	48 01 c8             	add    %rcx,%rax
  8004206a3e:	0f b6 00             	movzbl (%rax),%eax

		/* Do not overwrite CFA column */
		if (i == cfa)
			continue;

		reg_table->rules[i].dw_offset_relevant =
  8004206a41:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206a45:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8004206a48:	48 63 c9             	movslq %ecx,%rcx
  8004206a4b:	48 83 c1 01          	add    $0x1,%rcx
  8004206a4f:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206a53:	48 01 ca             	add    %rcx,%rdx
  8004206a56:	88 02                	mov    %al,(%rdx)
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
			rt->rt3_rules[i].dw_value_type;
  8004206a58:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206a5c:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206a60:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004206a63:	48 63 d0             	movslq %eax,%rdx
  8004206a66:	48 89 d0             	mov    %rdx,%rax
  8004206a69:	48 01 c0             	add    %rax,%rax
  8004206a6c:	48 01 d0             	add    %rdx,%rax
  8004206a6f:	48 c1 e0 03          	shl    $0x3,%rax
  8004206a73:	48 01 c8             	add    %rcx,%rax
  8004206a76:	0f b6 40 01          	movzbl 0x1(%rax),%eax
		if (i == cfa)
			continue;

		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
  8004206a7a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206a7e:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8004206a81:	48 63 c9             	movslq %ecx,%rcx
  8004206a84:	48 83 c1 01          	add    $0x1,%rcx
  8004206a88:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206a8c:	48 01 ca             	add    %rcx,%rdx
  8004206a8f:	88 42 01             	mov    %al,0x1(%rdx)
			rt->rt3_rules[i].dw_value_type;
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
  8004206a92:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206a96:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206a9a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004206a9d:	48 63 d0             	movslq %eax,%rdx
  8004206aa0:	48 89 d0             	mov    %rdx,%rax
  8004206aa3:	48 01 c0             	add    %rax,%rax
  8004206aa6:	48 01 d0             	add    %rdx,%rax
  8004206aa9:	48 c1 e0 03          	shl    $0x3,%rax
  8004206aad:	48 01 c8             	add    %rcx,%rax
  8004206ab0:	0f b7 40 02          	movzwl 0x2(%rax),%eax
  8004206ab4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206ab8:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8004206abb:	48 63 c9             	movslq %ecx,%rcx
  8004206abe:	48 83 c1 01          	add    $0x1,%rcx
  8004206ac2:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206ac6:	48 01 ca             	add    %rcx,%rdx
  8004206ac9:	66 89 42 02          	mov    %ax,0x2(%rdx)
		reg_table->rules[i].dw_offset =
			rt->rt3_rules[i].dw_offset_or_block_len;
  8004206acd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206ad1:	48 8b 48 20          	mov    0x20(%rax),%rcx
  8004206ad5:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004206ad8:	48 63 d0             	movslq %eax,%rdx
  8004206adb:	48 89 d0             	mov    %rdx,%rax
  8004206ade:	48 01 c0             	add    %rax,%rax
  8004206ae1:	48 01 d0             	add    %rdx,%rax
  8004206ae4:	48 c1 e0 03          	shl    $0x3,%rax
  8004206ae8:	48 01 c8             	add    %rcx,%rax
  8004206aeb:	48 8b 40 08          	mov    0x8(%rax),%rax
		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
			rt->rt3_rules[i].dw_value_type;
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
		reg_table->rules[i].dw_offset =
  8004206aef:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004206af3:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  8004206af6:	48 63 c9             	movslq %ecx,%rcx
  8004206af9:	48 83 c1 01          	add    $0x1,%rcx
  8004206afd:	48 c1 e1 04          	shl    $0x4,%rcx
  8004206b01:	48 01 ca             	add    %rcx,%rdx
  8004206b04:	48 83 c2 08          	add    $0x8,%rdx
  8004206b08:	48 89 02             	mov    %rax,(%rdx)

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
	     i++) {
  8004206b0b:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
	}

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
  8004206b0f:	83 7d fc 41          	cmpl   $0x41,-0x4(%rbp)
  8004206b13:	7f 14                	jg     8004206b29 <dwarf_get_fde_info_for_all_regs+0x30c>
  8004206b15:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004206b19:	0f b7 40 48          	movzwl 0x48(%rax),%eax
  8004206b1d:	0f b7 c0             	movzwl %ax,%eax
  8004206b20:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  8004206b23:	0f 8f e9 fe ff ff    	jg     8004206a12 <dwarf_get_fde_info_for_all_regs+0x1f5>
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
		reg_table->rules[i].dw_offset =
			rt->rt3_rules[i].dw_offset_or_block_len;
	}

	if (row_pc) *row_pc = pc;
  8004206b29:	48 83 7d b8 00       	cmpq   $0x0,-0x48(%rbp)
  8004206b2e:	74 0b                	je     8004206b3b <dwarf_get_fde_info_for_all_regs+0x31e>
  8004206b30:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206b34:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004206b38:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLV_OK);
  8004206b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004206b40:	c9                   	leaveq 
  8004206b41:	c3                   	retq   

0000008004206b42 <_dwarf_frame_read_lsb_encoded>:

static int
_dwarf_frame_read_lsb_encoded(Dwarf_Debug dbg, uint64_t *val, uint8_t *data,
			      uint64_t *offsetp, uint8_t encode, Dwarf_Addr pc, Dwarf_Error *error)
{
  8004206b42:	55                   	push   %rbp
  8004206b43:	48 89 e5             	mov    %rsp,%rbp
  8004206b46:	48 83 ec 40          	sub    $0x40,%rsp
  8004206b4a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004206b4e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004206b52:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004206b56:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  8004206b5a:	44 89 c0             	mov    %r8d,%eax
  8004206b5d:	4c 89 4d c0          	mov    %r9,-0x40(%rbp)
  8004206b61:	88 45 cc             	mov    %al,-0x34(%rbp)
	uint8_t application;

	if (encode == DW_EH_PE_omit)
  8004206b64:	80 7d cc ff          	cmpb   $0xff,-0x34(%rbp)
  8004206b68:	75 0a                	jne    8004206b74 <_dwarf_frame_read_lsb_encoded+0x32>
		return (DW_DLE_NONE);
  8004206b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206b6f:	e9 e6 01 00 00       	jmpq   8004206d5a <_dwarf_frame_read_lsb_encoded+0x218>

	application = encode & 0xf0;
  8004206b74:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  8004206b78:	83 e0 f0             	and    $0xfffffff0,%eax
  8004206b7b:	88 45 ff             	mov    %al,-0x1(%rbp)
	encode &= 0x0f;
  8004206b7e:	80 65 cc 0f          	andb   $0xf,-0x34(%rbp)

	switch (encode) {
  8004206b82:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  8004206b86:	83 f8 0c             	cmp    $0xc,%eax
  8004206b89:	0f 87 72 01 00 00    	ja     8004206d01 <_dwarf_frame_read_lsb_encoded+0x1bf>
  8004206b8f:	89 c0                	mov    %eax,%eax
  8004206b91:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004206b98:	00 
  8004206b99:	48 b8 a0 a2 20 04 80 	movabs $0x800420a2a0,%rax
  8004206ba0:	00 00 00 
  8004206ba3:	48 01 d0             	add    %rdx,%rax
  8004206ba6:	48 8b 00             	mov    (%rax),%rax
  8004206ba9:	ff e0                	jmpq   *%rax
	case DW_EH_PE_absptr:
		*val = dbg->read(data, offsetp, dbg->dbg_pointer_size);
  8004206bab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206baf:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206bb3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004206bb7:	8b 52 28             	mov    0x28(%rdx),%edx
  8004206bba:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206bbe:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206bc2:	48 89 cf             	mov    %rcx,%rdi
  8004206bc5:	ff d0                	callq  *%rax
  8004206bc7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206bcb:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206bce:	e9 35 01 00 00       	jmpq   8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_uleb128:
		*val = _dwarf_read_uleb128(data, offsetp);
  8004206bd3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206bd7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004206bdb:	48 89 d6             	mov    %rdx,%rsi
  8004206bde:	48 89 c7             	mov    %rax,%rdi
  8004206be1:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  8004206be8:	00 00 00 
  8004206beb:	ff d0                	callq  *%rax
  8004206bed:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206bf1:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206bf4:	e9 0f 01 00 00       	jmpq   8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata2:
		*val = dbg->read(data, offsetp, 2);
  8004206bf9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206bfd:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206c01:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206c05:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206c09:	ba 02 00 00 00       	mov    $0x2,%edx
  8004206c0e:	48 89 cf             	mov    %rcx,%rdi
  8004206c11:	ff d0                	callq  *%rax
  8004206c13:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206c17:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206c1a:	e9 e9 00 00 00       	jmpq   8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata4:
		*val = dbg->read(data, offsetp, 4);
  8004206c1f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206c23:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206c27:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206c2b:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206c2f:	ba 04 00 00 00       	mov    $0x4,%edx
  8004206c34:	48 89 cf             	mov    %rcx,%rdi
  8004206c37:	ff d0                	callq  *%rax
  8004206c39:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206c3d:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206c40:	e9 c3 00 00 00       	jmpq   8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata8:
		*val = dbg->read(data, offsetp, 8);
  8004206c45:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206c49:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206c4d:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206c51:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206c55:	ba 08 00 00 00       	mov    $0x8,%edx
  8004206c5a:	48 89 cf             	mov    %rcx,%rdi
  8004206c5d:	ff d0                	callq  *%rax
  8004206c5f:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206c63:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206c66:	e9 9d 00 00 00       	jmpq   8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sleb128:
		*val = _dwarf_read_sleb128(data, offsetp);
  8004206c6b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206c6f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004206c73:	48 89 d6             	mov    %rdx,%rsi
  8004206c76:	48 89 c7             	mov    %rax,%rdi
  8004206c79:	48 b8 32 3b 20 04 80 	movabs $0x8004203b32,%rax
  8004206c80:	00 00 00 
  8004206c83:	ff d0                	callq  *%rax
  8004206c85:	48 89 c2             	mov    %rax,%rdx
  8004206c88:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206c8c:	48 89 10             	mov    %rdx,(%rax)
		break;
  8004206c8f:	eb 77                	jmp    8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata2:
		*val = (int16_t) dbg->read(data, offsetp, 2);
  8004206c91:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206c95:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206c99:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206c9d:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206ca1:	ba 02 00 00 00       	mov    $0x2,%edx
  8004206ca6:	48 89 cf             	mov    %rcx,%rdi
  8004206ca9:	ff d0                	callq  *%rax
  8004206cab:	48 0f bf d0          	movswq %ax,%rdx
  8004206caf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206cb3:	48 89 10             	mov    %rdx,(%rax)
		break;
  8004206cb6:	eb 50                	jmp    8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata4:
		*val = (int32_t) dbg->read(data, offsetp, 4);
  8004206cb8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206cbc:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206cc0:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206cc4:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206cc8:	ba 04 00 00 00       	mov    $0x4,%edx
  8004206ccd:	48 89 cf             	mov    %rcx,%rdi
  8004206cd0:	ff d0                	callq  *%rax
  8004206cd2:	48 63 d0             	movslq %eax,%rdx
  8004206cd5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206cd9:	48 89 10             	mov    %rdx,(%rax)
		break;
  8004206cdc:	eb 2a                	jmp    8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata8:
		*val = dbg->read(data, offsetp, 8);
  8004206cde:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206ce2:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206ce6:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004206cea:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004206cee:	ba 08 00 00 00       	mov    $0x8,%edx
  8004206cf3:	48 89 cf             	mov    %rcx,%rdi
  8004206cf6:	ff d0                	callq  *%rax
  8004206cf8:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004206cfc:	48 89 02             	mov    %rax,(%rdx)
		break;
  8004206cff:	eb 07                	jmp    8004206d08 <_dwarf_frame_read_lsb_encoded+0x1c6>
	default:
		DWARF_SET_ERROR(dbg, error, DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
		return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
  8004206d01:	b8 14 00 00 00       	mov    $0x14,%eax
  8004206d06:	eb 52                	jmp    8004206d5a <_dwarf_frame_read_lsb_encoded+0x218>
	}

	if (application == DW_EH_PE_pcrel) {
  8004206d08:	80 7d ff 10          	cmpb   $0x10,-0x1(%rbp)
  8004206d0c:	75 47                	jne    8004206d55 <_dwarf_frame_read_lsb_encoded+0x213>
		/*
		 * Value is relative to .eh_frame section virtual addr.
		 */
		switch (encode) {
  8004206d0e:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  8004206d12:	83 f8 01             	cmp    $0x1,%eax
  8004206d15:	7c 3d                	jl     8004206d54 <_dwarf_frame_read_lsb_encoded+0x212>
  8004206d17:	83 f8 04             	cmp    $0x4,%eax
  8004206d1a:	7e 0a                	jle    8004206d26 <_dwarf_frame_read_lsb_encoded+0x1e4>
  8004206d1c:	83 e8 09             	sub    $0x9,%eax
  8004206d1f:	83 f8 03             	cmp    $0x3,%eax
  8004206d22:	77 30                	ja     8004206d54 <_dwarf_frame_read_lsb_encoded+0x212>
  8004206d24:	eb 17                	jmp    8004206d3d <_dwarf_frame_read_lsb_encoded+0x1fb>
		case DW_EH_PE_uleb128:
		case DW_EH_PE_udata2:
		case DW_EH_PE_udata4:
		case DW_EH_PE_udata8:
			*val += pc;
  8004206d26:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206d2a:	48 8b 10             	mov    (%rax),%rdx
  8004206d2d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206d31:	48 01 c2             	add    %rax,%rdx
  8004206d34:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206d38:	48 89 10             	mov    %rdx,(%rax)
			break;
  8004206d3b:	eb 18                	jmp    8004206d55 <_dwarf_frame_read_lsb_encoded+0x213>
		case DW_EH_PE_sleb128:
		case DW_EH_PE_sdata2:
		case DW_EH_PE_sdata4:
		case DW_EH_PE_sdata8:
			*val = pc + (int64_t) *val;
  8004206d3d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206d41:	48 8b 10             	mov    (%rax),%rdx
  8004206d44:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206d48:	48 01 c2             	add    %rax,%rdx
  8004206d4b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206d4f:	48 89 10             	mov    %rdx,(%rax)
			break;
  8004206d52:	eb 01                	jmp    8004206d55 <_dwarf_frame_read_lsb_encoded+0x213>
		default:
			/* DW_EH_PE_absptr is absolute value. */
			break;
  8004206d54:	90                   	nop
		}
	}

	/* XXX Applications other than DW_EH_PE_pcrel are not handled. */

	return (DW_DLE_NONE);
  8004206d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004206d5a:	c9                   	leaveq 
  8004206d5b:	c3                   	retq   

0000008004206d5c <_dwarf_frame_parse_lsb_cie_augment>:

static int
_dwarf_frame_parse_lsb_cie_augment(Dwarf_Debug dbg, Dwarf_Cie cie,
				   Dwarf_Error *error)
{
  8004206d5c:	55                   	push   %rbp
  8004206d5d:	48 89 e5             	mov    %rsp,%rbp
  8004206d60:	48 83 ec 50          	sub    $0x50,%rsp
  8004206d64:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004206d68:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  8004206d6c:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
	uint8_t *aug_p, *augdata_p;
	uint64_t val, offset;
	uint8_t encode;
	int ret;

	assert(cie->cie_augment != NULL && *cie->cie_augment == 'z');
  8004206d70:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206d74:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206d78:	48 85 c0             	test   %rax,%rax
  8004206d7b:	74 0f                	je     8004206d8c <_dwarf_frame_parse_lsb_cie_augment+0x30>
  8004206d7d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206d81:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206d85:	0f b6 00             	movzbl (%rax),%eax
  8004206d88:	3c 7a                	cmp    $0x7a,%al
  8004206d8a:	74 35                	je     8004206dc1 <_dwarf_frame_parse_lsb_cie_augment+0x65>
  8004206d8c:	48 b9 08 a3 20 04 80 	movabs $0x800420a308,%rcx
  8004206d93:	00 00 00 
  8004206d96:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  8004206d9d:	00 00 00 
  8004206da0:	be 4a 02 00 00       	mov    $0x24a,%esi
  8004206da5:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  8004206dac:	00 00 00 
  8004206daf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206db4:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004206dbb:	00 00 00 
  8004206dbe:	41 ff d0             	callq  *%r8
	/*
	 * Here we're only interested in the presence of augment 'R'
	 * and associated CIE augment data, which describes the
	 * encoding scheme of FDE PC begin and range.
	 */
	aug_p = &cie->cie_augment[1];
  8004206dc1:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206dc5:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206dc9:	48 83 c0 01          	add    $0x1,%rax
  8004206dcd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	augdata_p = cie->cie_augdata;
  8004206dd1:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206dd5:	48 8b 40 58          	mov    0x58(%rax),%rax
  8004206dd9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	while (*aug_p != '\0') {
  8004206ddd:	e9 af 00 00 00       	jmpq   8004206e91 <_dwarf_frame_parse_lsb_cie_augment+0x135>
		switch (*aug_p) {
  8004206de2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004206de6:	0f b6 00             	movzbl (%rax),%eax
  8004206de9:	0f b6 c0             	movzbl %al,%eax
  8004206dec:	83 f8 50             	cmp    $0x50,%eax
  8004206def:	74 18                	je     8004206e09 <_dwarf_frame_parse_lsb_cie_augment+0xad>
  8004206df1:	83 f8 52             	cmp    $0x52,%eax
  8004206df4:	74 77                	je     8004206e6d <_dwarf_frame_parse_lsb_cie_augment+0x111>
  8004206df6:	83 f8 4c             	cmp    $0x4c,%eax
  8004206df9:	0f 85 86 00 00 00    	jne    8004206e85 <_dwarf_frame_parse_lsb_cie_augment+0x129>
		case 'L':
			/* Skip one augment in augment data. */
			augdata_p++;
  8004206dff:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
			break;
  8004206e04:	e9 83 00 00 00       	jmpq   8004206e8c <_dwarf_frame_parse_lsb_cie_augment+0x130>
		case 'P':
			/* Skip two augments in augment data. */
			encode = *augdata_p++;
  8004206e09:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206e0d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004206e11:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  8004206e15:	0f b6 00             	movzbl (%rax),%eax
  8004206e18:	88 45 ef             	mov    %al,-0x11(%rbp)
			offset = 0;
  8004206e1b:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  8004206e22:	00 
			ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  8004206e23:	44 0f b6 45 ef       	movzbl -0x11(%rbp),%r8d
  8004206e28:	48 8d 4d d8          	lea    -0x28(%rbp),%rcx
  8004206e2c:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004206e30:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  8004206e34:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206e38:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8004206e3c:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004206e40:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  8004206e46:	48 89 c7             	mov    %rax,%rdi
  8004206e49:	48 b8 42 6b 20 04 80 	movabs $0x8004206b42,%rax
  8004206e50:	00 00 00 
  8004206e53:	ff d0                	callq  *%rax
  8004206e55:	89 45 e8             	mov    %eax,-0x18(%rbp)
							    augdata_p, &offset, encode, 0, error);
			if (ret != DW_DLE_NONE)
  8004206e58:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  8004206e5c:	74 05                	je     8004206e63 <_dwarf_frame_parse_lsb_cie_augment+0x107>
				return (ret);
  8004206e5e:	8b 45 e8             	mov    -0x18(%rbp),%eax
  8004206e61:	eb 42                	jmp    8004206ea5 <_dwarf_frame_parse_lsb_cie_augment+0x149>
			augdata_p += offset;
  8004206e63:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004206e67:	48 01 45 f0          	add    %rax,-0x10(%rbp)
			break;
  8004206e6b:	eb 1f                	jmp    8004206e8c <_dwarf_frame_parse_lsb_cie_augment+0x130>
		case 'R':
			cie->cie_fde_encode = *augdata_p++;
  8004206e6d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004206e71:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004206e75:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  8004206e79:	0f b6 10             	movzbl (%rax),%edx
  8004206e7c:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004206e80:	88 50 60             	mov    %dl,0x60(%rax)
			break;
  8004206e83:	eb 07                	jmp    8004206e8c <_dwarf_frame_parse_lsb_cie_augment+0x130>
		default:
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
			return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
  8004206e85:	b8 14 00 00 00       	mov    $0x14,%eax
  8004206e8a:	eb 19                	jmp    8004206ea5 <_dwarf_frame_parse_lsb_cie_augment+0x149>
		}
		aug_p++;
  8004206e8c:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
	 * and associated CIE augment data, which describes the
	 * encoding scheme of FDE PC begin and range.
	 */
	aug_p = &cie->cie_augment[1];
	augdata_p = cie->cie_augdata;
	while (*aug_p != '\0') {
  8004206e91:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004206e95:	0f b6 00             	movzbl (%rax),%eax
  8004206e98:	84 c0                	test   %al,%al
  8004206e9a:	0f 85 42 ff ff ff    	jne    8004206de2 <_dwarf_frame_parse_lsb_cie_augment+0x86>
			return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
		}
		aug_p++;
	}

	return (DW_DLE_NONE);
  8004206ea0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004206ea5:	c9                   	leaveq 
  8004206ea6:	c3                   	retq   

0000008004206ea7 <_dwarf_frame_set_cie>:


static int
_dwarf_frame_set_cie(Dwarf_Debug dbg, Dwarf_Section *ds,
		     Dwarf_Unsigned *off, Dwarf_Cie ret_cie, Dwarf_Error *error)
{
  8004206ea7:	55                   	push   %rbp
  8004206ea8:	48 89 e5             	mov    %rsp,%rbp
  8004206eab:	48 83 ec 60          	sub    $0x60,%rsp
  8004206eaf:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004206eb3:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  8004206eb7:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8004206ebb:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  8004206ebf:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
	Dwarf_Cie cie;
	uint64_t length;
	int dwarf_size, ret;
	char *p;

	assert(ret_cie);
  8004206ec3:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
  8004206ec8:	75 35                	jne    8004206eff <_dwarf_frame_set_cie+0x58>
  8004206eca:	48 b9 3d a3 20 04 80 	movabs $0x800420a33d,%rcx
  8004206ed1:	00 00 00 
  8004206ed4:	48 ba 87 a1 20 04 80 	movabs $0x800420a187,%rdx
  8004206edb:	00 00 00 
  8004206ede:	be 7b 02 00 00       	mov    $0x27b,%esi
  8004206ee3:	48 bf 9c a1 20 04 80 	movabs $0x800420a19c,%rdi
  8004206eea:	00 00 00 
  8004206eed:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206ef2:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004206ef9:	00 00 00 
  8004206efc:	41 ff d0             	callq  *%r8
	cie = ret_cie;
  8004206eff:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004206f03:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	cie->cie_dbg = dbg;
  8004206f07:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206f0b:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004206f0f:	48 89 10             	mov    %rdx,(%rax)
	cie->cie_offset = *off;
  8004206f12:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004206f16:	48 8b 10             	mov    (%rax),%rdx
  8004206f19:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206f1d:	48 89 50 10          	mov    %rdx,0x10(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  8004206f21:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206f25:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206f29:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004206f2d:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004206f31:	48 89 d1             	mov    %rdx,%rcx
  8004206f34:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004206f38:	ba 04 00 00 00       	mov    $0x4,%edx
  8004206f3d:	48 89 cf             	mov    %rcx,%rdi
  8004206f40:	ff d0                	callq  *%rax
  8004206f42:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (length == 0xffffffff) {
  8004206f46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004206f4b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  8004206f4f:	75 2e                	jne    8004206f7f <_dwarf_frame_set_cie+0xd8>
		dwarf_size = 8;
  8004206f51:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 8);
  8004206f58:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206f5c:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206f60:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004206f64:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004206f68:	48 89 d1             	mov    %rdx,%rcx
  8004206f6b:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004206f6f:	ba 08 00 00 00       	mov    $0x8,%edx
  8004206f74:	48 89 cf             	mov    %rcx,%rdi
  8004206f77:	ff d0                	callq  *%rax
  8004206f79:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004206f7d:	eb 07                	jmp    8004206f86 <_dwarf_frame_set_cie+0xdf>
	} else
		dwarf_size = 4;
  8004206f7f:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

	if (length > dbg->dbg_eh_size - *off) {
  8004206f86:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206f8a:	48 8b 50 40          	mov    0x40(%rax),%rdx
  8004206f8e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004206f92:	48 8b 00             	mov    (%rax),%rax
  8004206f95:	48 29 c2             	sub    %rax,%rdx
  8004206f98:	48 89 d0             	mov    %rdx,%rax
  8004206f9b:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8004206f9f:	73 0a                	jae    8004206fab <_dwarf_frame_set_cie+0x104>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_FRAME_LENGTH_BAD);
		return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  8004206fa1:	b8 12 00 00 00       	mov    $0x12,%eax
  8004206fa6:	e9 5d 03 00 00       	jmpq   8004207308 <_dwarf_frame_set_cie+0x461>
	}

	(void) dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size); /* Skip CIE id. */
  8004206fab:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206faf:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206fb3:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004206fb7:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004206fbb:	48 89 d1             	mov    %rdx,%rcx
  8004206fbe:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004206fc1:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004206fc5:	48 89 cf             	mov    %rcx,%rdi
  8004206fc8:	ff d0                	callq  *%rax
	cie->cie_length = length;
  8004206fca:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206fce:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004206fd2:	48 89 50 18          	mov    %rdx,0x18(%rax)

	cie->cie_version = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
  8004206fd6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206fda:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206fde:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004206fe2:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004206fe6:	48 89 d1             	mov    %rdx,%rcx
  8004206fe9:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004206fed:	ba 01 00 00 00       	mov    $0x1,%edx
  8004206ff2:	48 89 cf             	mov    %rcx,%rdi
  8004206ff5:	ff d0                	callq  *%rax
  8004206ff7:	89 c2                	mov    %eax,%edx
  8004206ff9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206ffd:	66 89 50 20          	mov    %dx,0x20(%rax)
	if (cie->cie_version != 1 && cie->cie_version != 3 &&
  8004207001:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207005:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  8004207009:	66 83 f8 01          	cmp    $0x1,%ax
  800420700d:	74 26                	je     8004207035 <_dwarf_frame_set_cie+0x18e>
  800420700f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207013:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  8004207017:	66 83 f8 03          	cmp    $0x3,%ax
  800420701b:	74 18                	je     8004207035 <_dwarf_frame_set_cie+0x18e>
	    cie->cie_version != 4) {
  800420701d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207021:	0f b7 40 20          	movzwl 0x20(%rax),%eax

	(void) dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size); /* Skip CIE id. */
	cie->cie_length = length;

	cie->cie_version = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
	if (cie->cie_version != 1 && cie->cie_version != 3 &&
  8004207025:	66 83 f8 04          	cmp    $0x4,%ax
  8004207029:	74 0a                	je     8004207035 <_dwarf_frame_set_cie+0x18e>
	    cie->cie_version != 4) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_FRAME_VERSION_BAD);
		return (DW_DLE_FRAME_VERSION_BAD);
  800420702b:	b8 16 00 00 00       	mov    $0x16,%eax
  8004207030:	e9 d3 02 00 00       	jmpq   8004207308 <_dwarf_frame_set_cie+0x461>
	}

	cie->cie_augment = (uint8_t *)dbg->dbg_eh_offset + *off;
  8004207035:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207039:	48 8b 10             	mov    (%rax),%rdx
  800420703c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207040:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207044:	48 01 d0             	add    %rdx,%rax
  8004207047:	48 89 c2             	mov    %rax,%rdx
  800420704a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420704e:	48 89 50 28          	mov    %rdx,0x28(%rax)
	p = (char *)dbg->dbg_eh_offset;
  8004207052:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207056:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420705a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	while (p[(*off)++] != '\0')
  800420705e:	90                   	nop
  800420705f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207063:	48 8b 00             	mov    (%rax),%rax
  8004207066:	48 8d 48 01          	lea    0x1(%rax),%rcx
  800420706a:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420706e:	48 89 0a             	mov    %rcx,(%rdx)
  8004207071:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207075:	48 01 d0             	add    %rdx,%rax
  8004207078:	0f b6 00             	movzbl (%rax),%eax
  800420707b:	84 c0                	test   %al,%al
  800420707d:	75 e0                	jne    800420705f <_dwarf_frame_set_cie+0x1b8>
		;

	/* We only recognize normal .dwarf_frame and GNU .eh_frame sections. */
	if (*cie->cie_augment != 0 && *cie->cie_augment != 'z') {
  800420707f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207083:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004207087:	0f b6 00             	movzbl (%rax),%eax
  800420708a:	84 c0                	test   %al,%al
  800420708c:	74 48                	je     80042070d6 <_dwarf_frame_set_cie+0x22f>
  800420708e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207092:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004207096:	0f b6 00             	movzbl (%rax),%eax
  8004207099:	3c 7a                	cmp    $0x7a,%al
  800420709b:	74 39                	je     80042070d6 <_dwarf_frame_set_cie+0x22f>
		*off = cie->cie_offset + ((dwarf_size == 4) ? 4 : 12) +
  800420709d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042070a1:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042070a5:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  80042070a9:	75 07                	jne    80042070b2 <_dwarf_frame_set_cie+0x20b>
  80042070ab:	b8 04 00 00 00       	mov    $0x4,%eax
  80042070b0:	eb 05                	jmp    80042070b7 <_dwarf_frame_set_cie+0x210>
  80042070b2:	b8 0c 00 00 00       	mov    $0xc,%eax
  80042070b7:	48 01 c2             	add    %rax,%rdx
			cie->cie_length;
  80042070ba:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042070be:	48 8b 40 18          	mov    0x18(%rax),%rax
	while (p[(*off)++] != '\0')
		;

	/* We only recognize normal .dwarf_frame and GNU .eh_frame sections. */
	if (*cie->cie_augment != 0 && *cie->cie_augment != 'z') {
		*off = cie->cie_offset + ((dwarf_size == 4) ? 4 : 12) +
  80042070c2:	48 01 c2             	add    %rax,%rdx
  80042070c5:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042070c9:	48 89 10             	mov    %rdx,(%rax)
			cie->cie_length;
		return (DW_DLE_NONE);
  80042070cc:	b8 00 00 00 00       	mov    $0x0,%eax
  80042070d1:	e9 32 02 00 00       	jmpq   8004207308 <_dwarf_frame_set_cie+0x461>
	}

	/* Optional EH Data field for .eh_frame section. */
	if (strstr((char *)cie->cie_augment, "eh") != NULL)
  80042070d6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042070da:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042070de:	48 be 45 a3 20 04 80 	movabs $0x800420a345,%rsi
  80042070e5:	00 00 00 
  80042070e8:	48 89 c7             	mov    %rax,%rdi
  80042070eb:	48 b8 e9 34 20 04 80 	movabs $0x80042034e9,%rax
  80042070f2:	00 00 00 
  80042070f5:	ff d0                	callq  *%rax
  80042070f7:	48 85 c0             	test   %rax,%rax
  80042070fa:	74 28                	je     8004207124 <_dwarf_frame_set_cie+0x27d>
		cie->cie_ehdata = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  80042070fc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207100:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207104:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207108:	8b 52 28             	mov    0x28(%rdx),%edx
  800420710b:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420710f:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  8004207113:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004207117:	48 89 cf             	mov    %rcx,%rdi
  800420711a:	ff d0                	callq  *%rax
  800420711c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207120:	48 89 42 30          	mov    %rax,0x30(%rdx)
					    dbg->dbg_pointer_size);

	cie->cie_caf = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  8004207124:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207128:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420712c:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004207130:	48 89 d6             	mov    %rdx,%rsi
  8004207133:	48 89 c7             	mov    %rax,%rdi
  8004207136:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  800420713d:	00 00 00 
  8004207140:	ff d0                	callq  *%rax
  8004207142:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207146:	48 89 42 38          	mov    %rax,0x38(%rdx)
	cie->cie_daf = _dwarf_read_sleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420714a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420714e:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207152:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004207156:	48 89 d6             	mov    %rdx,%rsi
  8004207159:	48 89 c7             	mov    %rax,%rdi
  800420715c:	48 b8 32 3b 20 04 80 	movabs $0x8004203b32,%rax
  8004207163:	00 00 00 
  8004207166:	ff d0                	callq  *%rax
  8004207168:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420716c:	48 89 42 40          	mov    %rax,0x40(%rdx)

	/* Return address register. */
	if (cie->cie_version == 1)
  8004207170:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207174:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  8004207178:	66 83 f8 01          	cmp    $0x1,%ax
  800420717c:	75 2b                	jne    80042071a9 <_dwarf_frame_set_cie+0x302>
		cie->cie_ra = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
  800420717e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207182:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207186:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420718a:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420718e:	48 89 d1             	mov    %rdx,%rcx
  8004207191:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004207195:	ba 01 00 00 00       	mov    $0x1,%edx
  800420719a:	48 89 cf             	mov    %rcx,%rdi
  800420719d:	ff d0                	callq  *%rax
  800420719f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042071a3:	48 89 42 48          	mov    %rax,0x48(%rdx)
  80042071a7:	eb 26                	jmp    80042071cf <_dwarf_frame_set_cie+0x328>
	else
		cie->cie_ra = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  80042071a9:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042071ad:	48 8b 40 38          	mov    0x38(%rax),%rax
  80042071b1:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80042071b5:	48 89 d6             	mov    %rdx,%rsi
  80042071b8:	48 89 c7             	mov    %rax,%rdi
  80042071bb:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  80042071c2:	00 00 00 
  80042071c5:	ff d0                	callq  *%rax
  80042071c7:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042071cb:	48 89 42 48          	mov    %rax,0x48(%rdx)

	/* Optional CIE augmentation data for .eh_frame section. */
	if (*cie->cie_augment == 'z') {
  80042071cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071d3:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042071d7:	0f b6 00             	movzbl (%rax),%eax
  80042071da:	3c 7a                	cmp    $0x7a,%al
  80042071dc:	0f 85 93 00 00 00    	jne    8004207275 <_dwarf_frame_set_cie+0x3ce>
		cie->cie_auglen = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  80042071e2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042071e6:	48 8b 40 38          	mov    0x38(%rax),%rax
  80042071ea:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80042071ee:	48 89 d6             	mov    %rdx,%rsi
  80042071f1:	48 89 c7             	mov    %rax,%rdi
  80042071f4:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  80042071fb:	00 00 00 
  80042071fe:	ff d0                	callq  *%rax
  8004207200:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207204:	48 89 42 50          	mov    %rax,0x50(%rdx)
		cie->cie_augdata = (uint8_t *)dbg->dbg_eh_offset + *off;
  8004207208:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420720c:	48 8b 10             	mov    (%rax),%rdx
  800420720f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207213:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207217:	48 01 d0             	add    %rdx,%rax
  800420721a:	48 89 c2             	mov    %rax,%rdx
  800420721d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207221:	48 89 50 58          	mov    %rdx,0x58(%rax)
		*off += cie->cie_auglen;
  8004207225:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207229:	48 8b 10             	mov    (%rax),%rdx
  800420722c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207230:	48 8b 40 50          	mov    0x50(%rax),%rax
  8004207234:	48 01 c2             	add    %rax,%rdx
  8004207237:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420723b:	48 89 10             	mov    %rdx,(%rax)
		/*
		 * XXX Use DW_EH_PE_absptr for default FDE PC start/range,
		 * in case _dwarf_frame_parse_lsb_cie_augment fails to
		 * find out the real encode.
		 */
		cie->cie_fde_encode = DW_EH_PE_absptr;
  800420723e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207242:	c6 40 60 00          	movb   $0x0,0x60(%rax)
		ret = _dwarf_frame_parse_lsb_cie_augment(dbg, cie, error);
  8004207246:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  800420724a:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420724e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207252:	48 89 ce             	mov    %rcx,%rsi
  8004207255:	48 89 c7             	mov    %rax,%rdi
  8004207258:	48 b8 5c 6d 20 04 80 	movabs $0x8004206d5c,%rax
  800420725f:	00 00 00 
  8004207262:	ff d0                	callq  *%rax
  8004207264:	89 45 dc             	mov    %eax,-0x24(%rbp)
		if (ret != DW_DLE_NONE)
  8004207267:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420726b:	74 08                	je     8004207275 <_dwarf_frame_set_cie+0x3ce>
			return (ret);
  800420726d:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004207270:	e9 93 00 00 00       	jmpq   8004207308 <_dwarf_frame_set_cie+0x461>
	}

	/* CIE Initial instructions. */
	cie->cie_initinst = (uint8_t *)dbg->dbg_eh_offset + *off;
  8004207275:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207279:	48 8b 10             	mov    (%rax),%rdx
  800420727c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207280:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207284:	48 01 d0             	add    %rdx,%rax
  8004207287:	48 89 c2             	mov    %rax,%rdx
  800420728a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420728e:	48 89 50 68          	mov    %rdx,0x68(%rax)
	if (dwarf_size == 4)
  8004207292:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  8004207296:	75 2a                	jne    80042072c2 <_dwarf_frame_set_cie+0x41b>
		cie->cie_instlen = cie->cie_offset + 4 + length - *off;
  8004207298:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420729c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042072a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042072a4:	48 01 c2             	add    %rax,%rdx
  80042072a7:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042072ab:	48 8b 00             	mov    (%rax),%rax
  80042072ae:	48 29 c2             	sub    %rax,%rdx
  80042072b1:	48 89 d0             	mov    %rdx,%rax
  80042072b4:	48 8d 50 04          	lea    0x4(%rax),%rdx
  80042072b8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072bc:	48 89 50 70          	mov    %rdx,0x70(%rax)
  80042072c0:	eb 28                	jmp    80042072ea <_dwarf_frame_set_cie+0x443>
	else
		cie->cie_instlen = cie->cie_offset + 12 + length - *off;
  80042072c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072c6:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042072ca:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042072ce:	48 01 c2             	add    %rax,%rdx
  80042072d1:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042072d5:	48 8b 00             	mov    (%rax),%rax
  80042072d8:	48 29 c2             	sub    %rax,%rdx
  80042072db:	48 89 d0             	mov    %rdx,%rax
  80042072de:	48 8d 50 0c          	lea    0xc(%rax),%rdx
  80042072e2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072e6:	48 89 50 70          	mov    %rdx,0x70(%rax)

	*off += cie->cie_instlen;
  80042072ea:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042072ee:	48 8b 10             	mov    (%rax),%rdx
  80042072f1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072f5:	48 8b 40 70          	mov    0x70(%rax),%rax
  80042072f9:	48 01 c2             	add    %rax,%rdx
  80042072fc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207300:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLE_NONE);
  8004207303:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004207308:	c9                   	leaveq 
  8004207309:	c3                   	retq   

000000800420730a <_dwarf_frame_set_fde>:

static int
_dwarf_frame_set_fde(Dwarf_Debug dbg, Dwarf_Fde ret_fde, Dwarf_Section *ds,
		     Dwarf_Unsigned *off, int eh_frame, Dwarf_Cie cie, Dwarf_Error *error)
{
  800420730a:	55                   	push   %rbp
  800420730b:	48 89 e5             	mov    %rsp,%rbp
  800420730e:	48 83 ec 70          	sub    $0x70,%rsp
  8004207312:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004207316:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420731a:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800420731e:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  8004207322:	44 89 45 ac          	mov    %r8d,-0x54(%rbp)
  8004207326:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
	Dwarf_Fde fde;
	Dwarf_Unsigned cieoff;
	uint64_t length, val;
	int dwarf_size, ret;

	fde = ret_fde;
  800420732a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420732e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	fde->fde_dbg = dbg;
  8004207332:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207336:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420733a:	48 89 10             	mov    %rdx,(%rax)
	fde->fde_addr = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420733d:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207341:	48 8b 10             	mov    (%rax),%rdx
  8004207344:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207348:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420734c:	48 01 d0             	add    %rdx,%rax
  800420734f:	48 89 c2             	mov    %rax,%rdx
  8004207352:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207356:	48 89 50 10          	mov    %rdx,0x10(%rax)
	fde->fde_offset = *off;
  800420735a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420735e:	48 8b 10             	mov    (%rax),%rdx
  8004207361:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207365:	48 89 50 18          	mov    %rdx,0x18(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  8004207369:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420736d:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207371:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207375:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004207379:	48 89 d1             	mov    %rdx,%rcx
  800420737c:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8004207380:	ba 04 00 00 00       	mov    $0x4,%edx
  8004207385:	48 89 cf             	mov    %rcx,%rdi
  8004207388:	ff d0                	callq  *%rax
  800420738a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (length == 0xffffffff) {
  800420738e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004207393:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  8004207397:	75 2e                	jne    80042073c7 <_dwarf_frame_set_fde+0xbd>
		dwarf_size = 8;
  8004207399:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 8);
  80042073a0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042073a4:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042073a8:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042073ac:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  80042073b0:	48 89 d1             	mov    %rdx,%rcx
  80042073b3:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80042073b7:	ba 08 00 00 00       	mov    $0x8,%edx
  80042073bc:	48 89 cf             	mov    %rcx,%rdi
  80042073bf:	ff d0                	callq  *%rax
  80042073c1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042073c5:	eb 07                	jmp    80042073ce <_dwarf_frame_set_fde+0xc4>
	} else
		dwarf_size = 4;
  80042073c7:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

	if (length > dbg->dbg_eh_size - *off) {
  80042073ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042073d2:	48 8b 50 40          	mov    0x40(%rax),%rdx
  80042073d6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042073da:	48 8b 00             	mov    (%rax),%rax
  80042073dd:	48 29 c2             	sub    %rax,%rdx
  80042073e0:	48 89 d0             	mov    %rdx,%rax
  80042073e3:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  80042073e7:	73 0a                	jae    80042073f3 <_dwarf_frame_set_fde+0xe9>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_FRAME_LENGTH_BAD);
		return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  80042073e9:	b8 12 00 00 00       	mov    $0x12,%eax
  80042073ee:	e9 ca 02 00 00       	jmpq   80042076bd <_dwarf_frame_set_fde+0x3b3>
	}

	fde->fde_length = length;
  80042073f3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042073f7:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042073fb:	48 89 50 20          	mov    %rdx,0x20(%rax)

	if (eh_frame) {
  80042073ff:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8004207403:	74 5e                	je     8004207463 <_dwarf_frame_set_fde+0x159>
		fde->fde_cieoff = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  8004207405:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207409:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420740d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207411:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004207415:	48 89 d1             	mov    %rdx,%rcx
  8004207418:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420741c:	ba 04 00 00 00       	mov    $0x4,%edx
  8004207421:	48 89 cf             	mov    %rcx,%rdi
  8004207424:	ff d0                	callq  *%rax
  8004207426:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420742a:	48 89 42 28          	mov    %rax,0x28(%rdx)
		cieoff = *off - (4 + fde->fde_cieoff);
  800420742e:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207432:	48 8b 10             	mov    (%rax),%rdx
  8004207435:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207439:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420743d:	48 29 c2             	sub    %rax,%rdx
  8004207440:	48 89 d0             	mov    %rdx,%rax
  8004207443:	48 83 e8 04          	sub    $0x4,%rax
  8004207447:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
		/* This delta should never be 0. */
		if (cieoff == fde->fde_offset) {
  800420744b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420744f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207453:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004207457:	75 3d                	jne    8004207496 <_dwarf_frame_set_fde+0x18c>
			DWARF_SET_ERROR(dbg, error, DW_DLE_NO_CIE_FOR_FDE);
			return (DW_DLE_NO_CIE_FOR_FDE);
  8004207459:	b8 13 00 00 00       	mov    $0x13,%eax
  800420745e:	e9 5a 02 00 00       	jmpq   80042076bd <_dwarf_frame_set_fde+0x3b3>
		}
	} else {
		fde->fde_cieoff = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size);
  8004207463:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207467:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420746b:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420746f:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004207473:	48 89 d1             	mov    %rdx,%rcx
  8004207476:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004207479:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420747d:	48 89 cf             	mov    %rcx,%rdi
  8004207480:	ff d0                	callq  *%rax
  8004207482:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207486:	48 89 42 28          	mov    %rax,0x28(%rdx)
		cieoff = fde->fde_cieoff;
  800420748a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420748e:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004207492:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	}

	if (eh_frame) {
  8004207496:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800420749a:	0f 84 c9 00 00 00    	je     8004207569 <_dwarf_frame_set_fde+0x25f>
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
  80042074a0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042074a4:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042074a8:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042074ac:	48 8b 00             	mov    (%rax),%rax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  80042074af:	4c 8d 0c 02          	lea    (%rdx,%rax,1),%r9
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
  80042074b3:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042074b7:	0f b6 40 60          	movzbl 0x60(%rax),%eax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  80042074bb:	44 0f b6 c0          	movzbl %al,%r8d
						    (uint8_t *)dbg->dbg_eh_offset,
  80042074bf:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042074c3:	48 8b 40 38          	mov    0x38(%rax),%rax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  80042074c7:	48 89 c2             	mov    %rax,%rdx
  80042074ca:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  80042074ce:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  80042074d2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042074d6:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  80042074da:	48 89 3c 24          	mov    %rdi,(%rsp)
  80042074de:	48 89 c7             	mov    %rax,%rdi
  80042074e1:	48 b8 42 6b 20 04 80 	movabs $0x8004206b42,%rax
  80042074e8:	00 00 00 
  80042074eb:	ff d0                	callq  *%rax
  80042074ed:	89 45 dc             	mov    %eax,-0x24(%rbp)
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
		if (ret != DW_DLE_NONE)
  80042074f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  80042074f4:	74 08                	je     80042074fe <_dwarf_frame_set_fde+0x1f4>
			return (ret);
  80042074f6:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80042074f9:	e9 bf 01 00 00       	jmpq   80042076bd <_dwarf_frame_set_fde+0x3b3>
		fde->fde_initloc = val;
  80042074fe:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004207502:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207506:	48 89 50 30          	mov    %rdx,0x30(%rax)
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, 0, error);
  800420750a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420750e:	0f b6 40 60          	movzbl 0x60(%rax),%eax
		fde->fde_initloc = val;
		/*
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  8004207512:	44 0f b6 c0          	movzbl %al,%r8d
						    (uint8_t *)dbg->dbg_eh_offset,
  8004207516:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420751a:	48 8b 40 38          	mov    0x38(%rax),%rax
		fde->fde_initloc = val;
		/*
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420751e:	48 89 c2             	mov    %rax,%rdx
  8004207521:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  8004207525:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  8004207529:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420752d:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  8004207531:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004207535:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800420753b:	48 89 c7             	mov    %rax,%rdi
  800420753e:	48 b8 42 6b 20 04 80 	movabs $0x8004206b42,%rax
  8004207545:	00 00 00 
  8004207548:	ff d0                	callq  *%rax
  800420754a:	89 45 dc             	mov    %eax,-0x24(%rbp)
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, 0, error);
		if (ret != DW_DLE_NONE)
  800420754d:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8004207551:	74 08                	je     800420755b <_dwarf_frame_set_fde+0x251>
			return (ret);
  8004207553:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004207556:	e9 62 01 00 00       	jmpq   80042076bd <_dwarf_frame_set_fde+0x3b3>
		fde->fde_adrange = val;
  800420755b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420755f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207563:	48 89 50 38          	mov    %rdx,0x38(%rax)
  8004207567:	eb 50                	jmp    80042075b9 <_dwarf_frame_set_fde+0x2af>
	} else {
		fde->fde_initloc = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  8004207569:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420756d:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207571:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207575:	8b 52 28             	mov    0x28(%rdx),%edx
  8004207578:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420757c:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  8004207580:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8004207584:	48 89 cf             	mov    %rcx,%rdi
  8004207587:	ff d0                	callq  *%rax
  8004207589:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420758d:	48 89 42 30          	mov    %rax,0x30(%rdx)
					     dbg->dbg_pointer_size);
		fde->fde_adrange = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  8004207591:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207595:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207599:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420759d:	8b 52 28             	mov    0x28(%rdx),%edx
  80042075a0:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  80042075a4:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  80042075a8:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80042075ac:	48 89 cf             	mov    %rcx,%rdi
  80042075af:	ff d0                	callq  *%rax
  80042075b1:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042075b5:	48 89 42 38          	mov    %rax,0x38(%rdx)
					     dbg->dbg_pointer_size);
	}

	/* Optional FDE augmentation data for .eh_frame section. (ignored) */
	if (eh_frame && *cie->cie_augment == 'z') {
  80042075b9:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  80042075bd:	74 6b                	je     800420762a <_dwarf_frame_set_fde+0x320>
  80042075bf:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042075c3:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042075c7:	0f b6 00             	movzbl (%rax),%eax
  80042075ca:	3c 7a                	cmp    $0x7a,%al
  80042075cc:	75 5c                	jne    800420762a <_dwarf_frame_set_fde+0x320>
		fde->fde_auglen = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  80042075ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042075d2:	48 8b 40 38          	mov    0x38(%rax),%rax
  80042075d6:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80042075da:	48 89 d6             	mov    %rdx,%rsi
  80042075dd:	48 89 c7             	mov    %rax,%rdi
  80042075e0:	48 b8 d6 3b 20 04 80 	movabs $0x8004203bd6,%rax
  80042075e7:	00 00 00 
  80042075ea:	ff d0                	callq  *%rax
  80042075ec:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042075f0:	48 89 42 40          	mov    %rax,0x40(%rdx)
		fde->fde_augdata = (uint8_t *)dbg->dbg_eh_offset + *off;
  80042075f4:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042075f8:	48 8b 10             	mov    (%rax),%rdx
  80042075fb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042075ff:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207603:	48 01 d0             	add    %rdx,%rax
  8004207606:	48 89 c2             	mov    %rax,%rdx
  8004207609:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420760d:	48 89 50 48          	mov    %rdx,0x48(%rax)
		*off += fde->fde_auglen;
  8004207611:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207615:	48 8b 10             	mov    (%rax),%rdx
  8004207618:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420761c:	48 8b 40 40          	mov    0x40(%rax),%rax
  8004207620:	48 01 c2             	add    %rax,%rdx
  8004207623:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207627:	48 89 10             	mov    %rdx,(%rax)
	}

	fde->fde_inst = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420762a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420762e:	48 8b 10             	mov    (%rax),%rdx
  8004207631:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207635:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004207639:	48 01 d0             	add    %rdx,%rax
  800420763c:	48 89 c2             	mov    %rax,%rdx
  800420763f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207643:	48 89 50 50          	mov    %rdx,0x50(%rax)
	if (dwarf_size == 4)
  8004207647:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420764b:	75 2a                	jne    8004207677 <_dwarf_frame_set_fde+0x36d>
		fde->fde_instlen = fde->fde_offset + 4 + length - *off;
  800420764d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207651:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004207655:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207659:	48 01 c2             	add    %rax,%rdx
  800420765c:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207660:	48 8b 00             	mov    (%rax),%rax
  8004207663:	48 29 c2             	sub    %rax,%rdx
  8004207666:	48 89 d0             	mov    %rdx,%rax
  8004207669:	48 8d 50 04          	lea    0x4(%rax),%rdx
  800420766d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207671:	48 89 50 58          	mov    %rdx,0x58(%rax)
  8004207675:	eb 28                	jmp    800420769f <_dwarf_frame_set_fde+0x395>
	else
		fde->fde_instlen = fde->fde_offset + 12 + length - *off;
  8004207677:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420767b:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420767f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207683:	48 01 c2             	add    %rax,%rdx
  8004207686:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420768a:	48 8b 00             	mov    (%rax),%rax
  800420768d:	48 29 c2             	sub    %rax,%rdx
  8004207690:	48 89 d0             	mov    %rdx,%rax
  8004207693:	48 8d 50 0c          	lea    0xc(%rax),%rdx
  8004207697:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420769b:	48 89 50 58          	mov    %rdx,0x58(%rax)

	*off += fde->fde_instlen;
  800420769f:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042076a3:	48 8b 10             	mov    (%rax),%rdx
  80042076a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042076aa:	48 8b 40 58          	mov    0x58(%rax),%rax
  80042076ae:	48 01 c2             	add    %rax,%rdx
  80042076b1:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042076b5:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLE_NONE);
  80042076b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042076bd:	c9                   	leaveq 
  80042076be:	c3                   	retq   

00000080042076bf <_dwarf_frame_interal_table_init>:


int
_dwarf_frame_interal_table_init(Dwarf_Debug dbg, Dwarf_Error *error)
{
  80042076bf:	55                   	push   %rbp
  80042076c0:	48 89 e5             	mov    %rsp,%rbp
  80042076c3:	48 83 ec 20          	sub    $0x20,%rsp
  80042076c7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042076cb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	Dwarf_Regtable3 *rt = &global_rt_table;
  80042076cf:	48 b8 e0 cc 21 04 80 	movabs $0x800421cce0,%rax
  80042076d6:	00 00 00 
  80042076d9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	if (dbg->dbg_internal_reg_table != NULL)
  80042076dd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042076e1:	48 8b 40 58          	mov    0x58(%rax),%rax
  80042076e5:	48 85 c0             	test   %rax,%rax
  80042076e8:	74 07                	je     80042076f1 <_dwarf_frame_interal_table_init+0x32>
		return (DW_DLE_NONE);
  80042076ea:	b8 00 00 00 00       	mov    $0x0,%eax
  80042076ef:	eb 33                	jmp    8004207724 <_dwarf_frame_interal_table_init+0x65>

	rt->rt3_reg_table_size = dbg->dbg_frame_rule_table_size;
  80042076f1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042076f5:	0f b7 50 48          	movzwl 0x48(%rax),%edx
  80042076f9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042076fd:	66 89 50 18          	mov    %dx,0x18(%rax)
	rt->rt3_rules = global_rules;
  8004207701:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207705:	48 b9 00 d5 21 04 80 	movabs $0x800421d500,%rcx
  800420770c:	00 00 00 
  800420770f:	48 89 48 20          	mov    %rcx,0x20(%rax)

	dbg->dbg_internal_reg_table = rt;
  8004207713:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207717:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420771b:	48 89 50 58          	mov    %rdx,0x58(%rax)

	return (DW_DLE_NONE);
  800420771f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004207724:	c9                   	leaveq 
  8004207725:	c3                   	retq   

0000008004207726 <_dwarf_get_next_fde>:

static int
_dwarf_get_next_fde(Dwarf_Debug dbg,
		    int eh_frame, Dwarf_Error *error, Dwarf_Fde ret_fde)
{
  8004207726:	55                   	push   %rbp
  8004207727:	48 89 e5             	mov    %rsp,%rbp
  800420772a:	48 83 ec 60          	sub    $0x60,%rsp
  800420772e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004207732:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  8004207735:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  8004207739:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
	Dwarf_Section *ds = &debug_frame_sec; 
  800420773d:	48 b8 e0 c5 21 04 80 	movabs $0x800421c5e0,%rax
  8004207744:	00 00 00 
  8004207747:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uint64_t length, offset, cie_id, entry_off;
	int dwarf_size, i, ret=-1;
  800420774b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%rbp)

	offset = dbg->curr_off_eh;
  8004207752:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207756:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420775a:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	if (offset < dbg->dbg_eh_size) {
  800420775e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207762:	48 8b 50 40          	mov    0x40(%rax),%rdx
  8004207766:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420776a:	48 39 c2             	cmp    %rax,%rdx
  800420776d:	0f 86 fe 01 00 00    	jbe    8004207971 <_dwarf_get_next_fde+0x24b>
		entry_off = offset;
  8004207773:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004207777:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, 4);
  800420777b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420777f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004207783:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207787:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420778b:	48 89 d1             	mov    %rdx,%rcx
  800420778e:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  8004207792:	ba 04 00 00 00       	mov    $0x4,%edx
  8004207797:	48 89 cf             	mov    %rcx,%rdi
  800420779a:	ff d0                	callq  *%rax
  800420779c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		if (length == 0xffffffff) {
  80042077a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80042077a5:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  80042077a9:	75 2e                	jne    80042077d9 <_dwarf_get_next_fde+0xb3>
			dwarf_size = 8;
  80042077ab:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
			length = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, 8);
  80042077b2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042077b6:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042077ba:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042077be:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  80042077c2:	48 89 d1             	mov    %rdx,%rcx
  80042077c5:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  80042077c9:	ba 08 00 00 00       	mov    $0x8,%edx
  80042077ce:	48 89 cf             	mov    %rcx,%rdi
  80042077d1:	ff d0                	callq  *%rax
  80042077d3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042077d7:	eb 07                	jmp    80042077e0 <_dwarf_get_next_fde+0xba>
		} else
			dwarf_size = 4;
  80042077d9:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

		if (length > dbg->dbg_eh_size - offset || (length == 0 && !eh_frame)) {
  80042077e0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042077e4:	48 8b 50 40          	mov    0x40(%rax),%rdx
  80042077e8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042077ec:	48 29 c2             	sub    %rax,%rdx
  80042077ef:	48 89 d0             	mov    %rdx,%rax
  80042077f2:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  80042077f6:	72 0d                	jb     8004207805 <_dwarf_get_next_fde+0xdf>
  80042077f8:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042077fd:	75 10                	jne    800420780f <_dwarf_get_next_fde+0xe9>
  80042077ff:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8004207803:	75 0a                	jne    800420780f <_dwarf_get_next_fde+0xe9>
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_DEBUG_FRAME_LENGTH_BAD);
			return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  8004207805:	b8 12 00 00 00       	mov    $0x12,%eax
  800420780a:	e9 67 01 00 00       	jmpq   8004207976 <_dwarf_get_next_fde+0x250>
		}

		/* Check terminator for .eh_frame */
		if (eh_frame && length == 0)
  800420780f:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8004207813:	74 11                	je     8004207826 <_dwarf_get_next_fde+0x100>
  8004207815:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420781a:	75 0a                	jne    8004207826 <_dwarf_get_next_fde+0x100>
			return(-1);
  800420781c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004207821:	e9 50 01 00 00       	jmpq   8004207976 <_dwarf_get_next_fde+0x250>

		cie_id = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, dwarf_size);
  8004207826:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420782a:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420782e:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207832:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  8004207836:	48 89 d1             	mov    %rdx,%rcx
  8004207839:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420783c:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  8004207840:	48 89 cf             	mov    %rcx,%rdi
  8004207843:	ff d0                	callq  *%rax
  8004207845:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

		if (eh_frame) {
  8004207849:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800420784d:	74 79                	je     80042078c8 <_dwarf_get_next_fde+0x1a2>
			/* GNU .eh_frame use CIE id 0. */
			if (cie_id == 0)
  800420784f:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004207854:	75 32                	jne    8004207888 <_dwarf_get_next_fde+0x162>
				ret = _dwarf_frame_set_cie(dbg, ds,
  8004207856:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420785a:	48 8b 48 08          	mov    0x8(%rax),%rcx
  800420785e:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8004207862:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  8004207866:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  800420786a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420786e:	49 89 f8             	mov    %rdi,%r8
  8004207871:	48 89 c7             	mov    %rax,%rdi
  8004207874:	48 b8 a7 6e 20 04 80 	movabs $0x8004206ea7,%rax
  800420787b:	00 00 00 
  800420787e:	ff d0                	callq  *%rax
  8004207880:	89 45 f0             	mov    %eax,-0x10(%rbp)
  8004207883:	e9 c8 00 00 00       	jmpq   8004207950 <_dwarf_get_next_fde+0x22a>
							   &entry_off, ret_fde->fde_cie, error);
			else
				ret = _dwarf_frame_set_fde(dbg,ret_fde, ds,
  8004207888:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420788c:	4c 8b 40 08          	mov    0x8(%rax),%r8
  8004207890:	48 8d 4d d0          	lea    -0x30(%rbp),%rcx
  8004207894:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207898:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420789c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042078a0:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  80042078a4:	48 89 3c 24          	mov    %rdi,(%rsp)
  80042078a8:	4d 89 c1             	mov    %r8,%r9
  80042078ab:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  80042078b1:	48 89 c7             	mov    %rax,%rdi
  80042078b4:	48 b8 0a 73 20 04 80 	movabs $0x800420730a,%rax
  80042078bb:	00 00 00 
  80042078be:	ff d0                	callq  *%rax
  80042078c0:	89 45 f0             	mov    %eax,-0x10(%rbp)
  80042078c3:	e9 88 00 00 00       	jmpq   8004207950 <_dwarf_get_next_fde+0x22a>
							   &entry_off, 1, ret_fde->fde_cie, error);
		} else {
			/* .dwarf_frame use CIE id ~0 */
			if ((dwarf_size == 4 && cie_id == ~0U) ||
  80042078c8:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  80042078cc:	75 0b                	jne    80042078d9 <_dwarf_get_next_fde+0x1b3>
  80042078ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80042078d3:	48 39 45 e0          	cmp    %rax,-0x20(%rbp)
  80042078d7:	74 0d                	je     80042078e6 <_dwarf_get_next_fde+0x1c0>
  80042078d9:	83 7d f4 08          	cmpl   $0x8,-0xc(%rbp)
  80042078dd:	75 36                	jne    8004207915 <_dwarf_get_next_fde+0x1ef>
			    (dwarf_size == 8 && cie_id == ~0ULL))
  80042078df:	48 83 7d e0 ff       	cmpq   $0xffffffffffffffff,-0x20(%rbp)
  80042078e4:	75 2f                	jne    8004207915 <_dwarf_get_next_fde+0x1ef>
				ret = _dwarf_frame_set_cie(dbg, ds,
  80042078e6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042078ea:	48 8b 48 08          	mov    0x8(%rax),%rcx
  80042078ee:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  80042078f2:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  80042078f6:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  80042078fa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042078fe:	49 89 f8             	mov    %rdi,%r8
  8004207901:	48 89 c7             	mov    %rax,%rdi
  8004207904:	48 b8 a7 6e 20 04 80 	movabs $0x8004206ea7,%rax
  800420790b:	00 00 00 
  800420790e:	ff d0                	callq  *%rax
  8004207910:	89 45 f0             	mov    %eax,-0x10(%rbp)
  8004207913:	eb 3b                	jmp    8004207950 <_dwarf_get_next_fde+0x22a>
							   &entry_off, ret_fde->fde_cie, error);
			else
				ret = _dwarf_frame_set_fde(dbg, ret_fde, ds,
  8004207915:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004207919:	4c 8b 40 08          	mov    0x8(%rax),%r8
  800420791d:	48 8d 4d d0          	lea    -0x30(%rbp),%rcx
  8004207921:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207925:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  8004207929:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420792d:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  8004207931:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004207935:	4d 89 c1             	mov    %r8,%r9
  8004207938:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  800420793e:	48 89 c7             	mov    %rax,%rdi
  8004207941:	48 b8 0a 73 20 04 80 	movabs $0x800420730a,%rax
  8004207948:	00 00 00 
  800420794b:	ff d0                	callq  *%rax
  800420794d:	89 45 f0             	mov    %eax,-0x10(%rbp)
							   &entry_off, 0, ret_fde->fde_cie, error);
		}

		if (ret != DW_DLE_NONE)
  8004207950:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  8004207954:	74 07                	je     800420795d <_dwarf_get_next_fde+0x237>
			return(-1);
  8004207956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420795b:	eb 19                	jmp    8004207976 <_dwarf_get_next_fde+0x250>

		offset = entry_off;
  800420795d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004207961:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
		dbg->curr_off_eh = offset;
  8004207965:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004207969:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420796d:	48 89 50 30          	mov    %rdx,0x30(%rax)
	}

	return (0);
  8004207971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004207976:	c9                   	leaveq 
  8004207977:	c3                   	retq   

0000008004207978 <dwarf_set_frame_cfa_value>:

Dwarf_Half
dwarf_set_frame_cfa_value(Dwarf_Debug dbg, Dwarf_Half value)
{
  8004207978:	55                   	push   %rbp
  8004207979:	48 89 e5             	mov    %rsp,%rbp
  800420797c:	48 83 ec 1c          	sub    $0x1c,%rsp
  8004207980:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207984:	89 f0                	mov    %esi,%eax
  8004207986:	66 89 45 e4          	mov    %ax,-0x1c(%rbp)
	Dwarf_Half old_value;

	old_value = dbg->dbg_frame_cfa_value;
  800420798a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420798e:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  8004207992:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
	dbg->dbg_frame_cfa_value = value;
  8004207996:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420799a:	0f b7 55 e4          	movzwl -0x1c(%rbp),%edx
  800420799e:	66 89 50 4c          	mov    %dx,0x4c(%rax)

	return (old_value);
  80042079a2:	0f b7 45 fe          	movzwl -0x2(%rbp),%eax
}
  80042079a6:	c9                   	leaveq 
  80042079a7:	c3                   	retq   

00000080042079a8 <dwarf_init_eh_section>:

int dwarf_init_eh_section(Dwarf_Debug dbg, Dwarf_Error *error)
{
  80042079a8:	55                   	push   %rbp
  80042079a9:	48 89 e5             	mov    %rsp,%rbp
  80042079ac:	48 83 ec 10          	sub    $0x10,%rsp
  80042079b0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  80042079b4:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	Dwarf_Section *section;

	if (dbg == NULL) {
  80042079b8:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042079bd:	75 0a                	jne    80042079c9 <dwarf_init_eh_section+0x21>
		DWARF_SET_ERROR(dbg, error, DW_DLE_ARGUMENT);
		return (DW_DLV_ERROR);
  80042079bf:	b8 01 00 00 00       	mov    $0x1,%eax
  80042079c4:	e9 85 00 00 00       	jmpq   8004207a4e <dwarf_init_eh_section+0xa6>
	}

	if (dbg->dbg_internal_reg_table == NULL) {
  80042079c9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042079cd:	48 8b 40 58          	mov    0x58(%rax),%rax
  80042079d1:	48 85 c0             	test   %rax,%rax
  80042079d4:	75 25                	jne    80042079fb <dwarf_init_eh_section+0x53>
		if (_dwarf_frame_interal_table_init(dbg, error) != DW_DLE_NONE)
  80042079d6:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80042079da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042079de:	48 89 d6             	mov    %rdx,%rsi
  80042079e1:	48 89 c7             	mov    %rax,%rdi
  80042079e4:	48 b8 bf 76 20 04 80 	movabs $0x80042076bf,%rax
  80042079eb:	00 00 00 
  80042079ee:	ff d0                	callq  *%rax
  80042079f0:	85 c0                	test   %eax,%eax
  80042079f2:	74 07                	je     80042079fb <dwarf_init_eh_section+0x53>
			return (DW_DLV_ERROR);
  80042079f4:	b8 01 00 00 00       	mov    $0x1,%eax
  80042079f9:	eb 53                	jmp    8004207a4e <dwarf_init_eh_section+0xa6>
	}

	_dwarf_find_section_enhanced(&debug_frame_sec);
  80042079fb:	48 bf e0 c5 21 04 80 	movabs $0x800421c5e0,%rdi
  8004207a02:	00 00 00 
  8004207a05:	48 b8 74 54 20 04 80 	movabs $0x8004205474,%rax
  8004207a0c:	00 00 00 
  8004207a0f:	ff d0                	callq  *%rax

	dbg->curr_off_eh = 0;
  8004207a11:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207a15:	48 c7 40 30 00 00 00 	movq   $0x0,0x30(%rax)
  8004207a1c:	00 
	dbg->dbg_eh_offset = debug_frame_sec.ds_addr;
  8004207a1d:	48 b8 e0 c5 21 04 80 	movabs $0x800421c5e0,%rax
  8004207a24:	00 00 00 
  8004207a27:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004207a2b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207a2f:	48 89 50 38          	mov    %rdx,0x38(%rax)
	dbg->dbg_eh_size = debug_frame_sec.ds_size;
  8004207a33:	48 b8 e0 c5 21 04 80 	movabs $0x800421c5e0,%rax
  8004207a3a:	00 00 00 
  8004207a3d:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004207a41:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207a45:	48 89 50 40          	mov    %rdx,0x40(%rax)

	return (DW_DLV_OK);
  8004207a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004207a4e:	c9                   	leaveq 
  8004207a4f:	c3                   	retq   

0000008004207a50 <_dwarf_lineno_run_program>:
int  _dwarf_find_section_enhanced(Dwarf_Section *ds);

static int
_dwarf_lineno_run_program(Dwarf_CU *cu, Dwarf_LineInfo li, uint8_t *p,
			  uint8_t *pe, Dwarf_Addr pc, Dwarf_Error *error)
{
  8004207a50:	55                   	push   %rbp
  8004207a51:	48 89 e5             	mov    %rsp,%rbp
  8004207a54:	53                   	push   %rbx
  8004207a55:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  8004207a5c:	48 89 7d 88          	mov    %rdi,-0x78(%rbp)
  8004207a60:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
  8004207a64:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  8004207a6b:	48 89 8d 70 ff ff ff 	mov    %rcx,-0x90(%rbp)
  8004207a72:	4c 89 85 68 ff ff ff 	mov    %r8,-0x98(%rbp)
  8004207a79:	4c 89 8d 60 ff ff ff 	mov    %r9,-0xa0(%rbp)
	uint64_t address, file, line, column, isa, opsize;
	int is_stmt, basic_block, end_sequence;
	int prologue_end, epilogue_begin;
	int ret;

	ln = &li->li_line;
  8004207a80:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207a84:	48 83 c0 48          	add    $0x48,%rax
  8004207a88:	48 89 45 b8          	mov    %rax,-0x48(%rbp)

	/*
	 *   ln->ln_li     = li;             \
	 * Set registers to their default values.
	 */
	RESET_REGISTERS;
  8004207a8c:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004207a93:	00 
  8004207a94:	48 c7 45 e0 01 00 00 	movq   $0x1,-0x20(%rbp)
  8004207a9b:	00 
  8004207a9c:	48 c7 45 d8 01 00 00 	movq   $0x1,-0x28(%rbp)
  8004207aa3:	00 
  8004207aa4:	48 c7 45 d0 00 00 00 	movq   $0x0,-0x30(%rbp)
  8004207aab:	00 
  8004207aac:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207ab0:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  8004207ab4:	0f b6 c0             	movzbl %al,%eax
  8004207ab7:	89 45 cc             	mov    %eax,-0x34(%rbp)
  8004207aba:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
  8004207ac1:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
  8004207ac8:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
  8004207acf:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)

	/*
	 * Start line number program.
	 */
	while (p < pe) {
  8004207ad6:	e9 0a 05 00 00       	jmpq   8004207fe5 <_dwarf_lineno_run_program+0x595>
		if (*p == 0) {
  8004207adb:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207ae2:	0f b6 00             	movzbl (%rax),%eax
  8004207ae5:	84 c0                	test   %al,%al
  8004207ae7:	0f 85 78 01 00 00    	jne    8004207c65 <_dwarf_lineno_run_program+0x215>

			/*
			 * Extended Opcodes.
			 */

			p++;
  8004207aed:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207af4:	48 83 c0 01          	add    $0x1,%rax
  8004207af8:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
			opsize = _dwarf_decode_uleb128(&p);
  8004207aff:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207b06:	48 89 c7             	mov    %rax,%rdi
  8004207b09:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004207b10:	00 00 00 
  8004207b13:	ff d0                	callq  *%rax
  8004207b15:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
			switch (*p) {
  8004207b19:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207b20:	0f b6 00             	movzbl (%rax),%eax
  8004207b23:	0f b6 c0             	movzbl %al,%eax
  8004207b26:	83 f8 02             	cmp    $0x2,%eax
  8004207b29:	74 7a                	je     8004207ba5 <_dwarf_lineno_run_program+0x155>
  8004207b2b:	83 f8 03             	cmp    $0x3,%eax
  8004207b2e:	0f 84 b3 00 00 00    	je     8004207be7 <_dwarf_lineno_run_program+0x197>
  8004207b34:	83 f8 01             	cmp    $0x1,%eax
  8004207b37:	0f 85 09 01 00 00    	jne    8004207c46 <_dwarf_lineno_run_program+0x1f6>
			case DW_LNE_end_sequence:
				p++;
  8004207b3d:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207b44:	48 83 c0 01          	add    $0x1,%rax
  8004207b48:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				end_sequence = 1;
  8004207b4f:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%rbp)
				RESET_REGISTERS;
  8004207b56:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004207b5d:	00 
  8004207b5e:	48 c7 45 e0 01 00 00 	movq   $0x1,-0x20(%rbp)
  8004207b65:	00 
  8004207b66:	48 c7 45 d8 01 00 00 	movq   $0x1,-0x28(%rbp)
  8004207b6d:	00 
  8004207b6e:	48 c7 45 d0 00 00 00 	movq   $0x0,-0x30(%rbp)
  8004207b75:	00 
  8004207b76:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207b7a:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  8004207b7e:	0f b6 c0             	movzbl %al,%eax
  8004207b81:	89 45 cc             	mov    %eax,-0x34(%rbp)
  8004207b84:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
  8004207b8b:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
  8004207b92:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
  8004207b99:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
				break;
  8004207ba0:	e9 bb 00 00 00       	jmpq   8004207c60 <_dwarf_lineno_run_program+0x210>
			case DW_LNE_set_address:
				p++;
  8004207ba5:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207bac:	48 83 c0 01          	add    $0x1,%rax
  8004207bb0:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				address = dbg->decode(&p, cu->addr_size);
  8004207bb7:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004207bbe:	00 00 00 
  8004207bc1:	48 8b 00             	mov    (%rax),%rax
  8004207bc4:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004207bc8:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8004207bcc:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  8004207bd0:	0f b6 ca             	movzbl %dl,%ecx
  8004207bd3:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  8004207bda:	89 ce                	mov    %ecx,%esi
  8004207bdc:	48 89 d7             	mov    %rdx,%rdi
  8004207bdf:	ff d0                	callq  *%rax
  8004207be1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				break;
  8004207be5:	eb 79                	jmp    8004207c60 <_dwarf_lineno_run_program+0x210>
			case DW_LNE_define_file:
				p++;
  8004207be7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207bee:	48 83 c0 01          	add    $0x1,%rax
  8004207bf2:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				ret = _dwarf_lineno_add_file(li, &p, NULL,
  8004207bf9:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004207c00:	00 00 00 
  8004207c03:	48 8b 08             	mov    (%rax),%rcx
  8004207c06:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004207c0d:	48 8d b5 78 ff ff ff 	lea    -0x88(%rbp),%rsi
  8004207c14:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207c18:	49 89 c8             	mov    %rcx,%r8
  8004207c1b:	48 89 d1             	mov    %rdx,%rcx
  8004207c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  8004207c23:	48 89 c7             	mov    %rax,%rdi
  8004207c26:	48 b8 08 80 20 04 80 	movabs $0x8004208008,%rax
  8004207c2d:	00 00 00 
  8004207c30:	ff d0                	callq  *%rax
  8004207c32:	89 45 a4             	mov    %eax,-0x5c(%rbp)
							     error, dbg);
				if (ret != DW_DLE_NONE)
  8004207c35:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  8004207c39:	74 09                	je     8004207c44 <_dwarf_lineno_run_program+0x1f4>
					goto prog_fail;
  8004207c3b:	90                   	nop

	return (DW_DLE_NONE);

prog_fail:

	return (ret);
  8004207c3c:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  8004207c3f:	e9 ba 03 00 00       	jmpq   8004207ffe <_dwarf_lineno_run_program+0x5ae>
				p++;
				ret = _dwarf_lineno_add_file(li, &p, NULL,
							     error, dbg);
				if (ret != DW_DLE_NONE)
					goto prog_fail;
				break;
  8004207c44:	eb 1a                	jmp    8004207c60 <_dwarf_lineno_run_program+0x210>
			default:
				/* Unrecognized extened opcodes. */
				p += opsize;
  8004207c46:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  8004207c4d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207c51:	48 01 d0             	add    %rdx,%rax
  8004207c54:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  8004207c5b:	e9 85 03 00 00       	jmpq   8004207fe5 <_dwarf_lineno_run_program+0x595>
  8004207c60:	e9 80 03 00 00       	jmpq   8004207fe5 <_dwarf_lineno_run_program+0x595>
			}

		} else if (*p > 0 && *p < li->li_opbase) {
  8004207c65:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207c6c:	0f b6 00             	movzbl (%rax),%eax
  8004207c6f:	84 c0                	test   %al,%al
  8004207c71:	0f 84 3c 02 00 00    	je     8004207eb3 <_dwarf_lineno_run_program+0x463>
  8004207c77:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207c7e:	0f b6 10             	movzbl (%rax),%edx
  8004207c81:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207c85:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  8004207c89:	38 c2                	cmp    %al,%dl
  8004207c8b:	0f 83 22 02 00 00    	jae    8004207eb3 <_dwarf_lineno_run_program+0x463>

			/*
			 * Standard Opcodes.
			 */

			switch (*p++) {
  8004207c91:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207c98:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207c9c:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  8004207ca3:	0f b6 00             	movzbl (%rax),%eax
  8004207ca6:	0f b6 c0             	movzbl %al,%eax
  8004207ca9:	83 f8 0c             	cmp    $0xc,%eax
  8004207cac:	0f 87 fb 01 00 00    	ja     8004207ead <_dwarf_lineno_run_program+0x45d>
  8004207cb2:	89 c0                	mov    %eax,%eax
  8004207cb4:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004207cbb:	00 
  8004207cbc:	48 b8 48 a3 20 04 80 	movabs $0x800420a348,%rax
  8004207cc3:	00 00 00 
  8004207cc6:	48 01 d0             	add    %rdx,%rax
  8004207cc9:	48 8b 00             	mov    (%rax),%rax
  8004207ccc:	ff e0                	jmpq   *%rax
			case DW_LNS_copy:
				APPEND_ROW;
  8004207cce:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004207cd5:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  8004207cd9:	73 0a                	jae    8004207ce5 <_dwarf_lineno_run_program+0x295>
  8004207cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207ce0:	e9 19 03 00 00       	jmpq   8004207ffe <_dwarf_lineno_run_program+0x5ae>
  8004207ce5:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207ce9:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207ced:	48 89 10             	mov    %rdx,(%rax)
  8004207cf0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207cf4:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  8004207cfb:	00 
  8004207cfc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d00:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207d04:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8004207d08:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d0c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004207d10:	48 89 50 18          	mov    %rdx,0x18(%rax)
  8004207d14:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004207d18:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d1c:	48 89 50 20          	mov    %rdx,0x20(%rax)
  8004207d20:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d24:	8b 55 c8             	mov    -0x38(%rbp),%edx
  8004207d27:	89 50 28             	mov    %edx,0x28(%rax)
  8004207d2a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d2e:	8b 55 cc             	mov    -0x34(%rbp),%edx
  8004207d31:	89 50 2c             	mov    %edx,0x2c(%rax)
  8004207d34:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207d38:	8b 55 c4             	mov    -0x3c(%rbp),%edx
  8004207d3b:	89 50 30             	mov    %edx,0x30(%rax)
  8004207d3e:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207d42:	48 8b 80 80 00 00 00 	mov    0x80(%rax),%rax
  8004207d49:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207d4d:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207d51:	48 89 90 80 00 00 00 	mov    %rdx,0x80(%rax)
				basic_block = 0;
  8004207d58:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
				prologue_end = 0;
  8004207d5f:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
				epilogue_begin = 0;
  8004207d66:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
				break;
  8004207d6d:	e9 3c 01 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_advance_pc:
				address += _dwarf_decode_uleb128(&p) *
  8004207d72:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207d79:	48 89 c7             	mov    %rax,%rdi
  8004207d7c:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004207d83:	00 00 00 
  8004207d86:	ff d0                	callq  *%rax
					li->li_minlen;
  8004207d88:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  8004207d8c:	0f b6 52 18          	movzbl 0x18(%rdx),%edx
				basic_block = 0;
				prologue_end = 0;
				epilogue_begin = 0;
				break;
			case DW_LNS_advance_pc:
				address += _dwarf_decode_uleb128(&p) *
  8004207d90:	0f b6 d2             	movzbl %dl,%edx
  8004207d93:	48 0f af c2          	imul   %rdx,%rax
  8004207d97:	48 01 45 e8          	add    %rax,-0x18(%rbp)
					li->li_minlen;
				break;
  8004207d9b:	e9 0e 01 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_advance_line:
				line += _dwarf_decode_sleb128(&p);
  8004207da0:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207da7:	48 89 c7             	mov    %rax,%rdi
  8004207daa:	48 b8 55 3c 20 04 80 	movabs $0x8004203c55,%rax
  8004207db1:	00 00 00 
  8004207db4:	ff d0                	callq  *%rax
  8004207db6:	48 01 45 d8          	add    %rax,-0x28(%rbp)
				break;
  8004207dba:	e9 ef 00 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_file:
				file = _dwarf_decode_uleb128(&p);
  8004207dbf:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207dc6:	48 89 c7             	mov    %rax,%rdi
  8004207dc9:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004207dd0:	00 00 00 
  8004207dd3:	ff d0                	callq  *%rax
  8004207dd5:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
				break;
  8004207dd9:	e9 d0 00 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_column:
				column = _dwarf_decode_uleb128(&p);
  8004207dde:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207de5:	48 89 c7             	mov    %rax,%rdi
  8004207de8:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004207def:	00 00 00 
  8004207df2:	ff d0                	callq  *%rax
  8004207df4:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
				break;
  8004207df8:	e9 b1 00 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_negate_stmt:
				is_stmt = !is_stmt;
  8004207dfd:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8004207e01:	0f 94 c0             	sete   %al
  8004207e04:	0f b6 c0             	movzbl %al,%eax
  8004207e07:	89 45 cc             	mov    %eax,-0x34(%rbp)
				break;
  8004207e0a:	e9 9f 00 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_basic_block:
				basic_block = 1;
  8004207e0f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%rbp)
				break;
  8004207e16:	e9 93 00 00 00       	jmpq   8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_const_add_pc:
				address += ADDRESS(255);
  8004207e1b:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207e1f:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  8004207e23:	0f b6 c0             	movzbl %al,%eax
  8004207e26:	ba ff 00 00 00       	mov    $0xff,%edx
  8004207e2b:	89 d1                	mov    %edx,%ecx
  8004207e2d:	29 c1                	sub    %eax,%ecx
  8004207e2f:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207e33:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  8004207e37:	0f b6 d8             	movzbl %al,%ebx
  8004207e3a:	89 c8                	mov    %ecx,%eax
  8004207e3c:	99                   	cltd   
  8004207e3d:	f7 fb                	idiv   %ebx
  8004207e3f:	89 c2                	mov    %eax,%edx
  8004207e41:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207e45:	0f b6 40 18          	movzbl 0x18(%rax),%eax
  8004207e49:	0f b6 c0             	movzbl %al,%eax
  8004207e4c:	0f af c2             	imul   %edx,%eax
  8004207e4f:	48 98                	cltq   
  8004207e51:	48 01 45 e8          	add    %rax,-0x18(%rbp)
				break;
  8004207e55:	eb 57                	jmp    8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_fixed_advance_pc:
				address += dbg->decode(&p, 2);
  8004207e57:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004207e5e:	00 00 00 
  8004207e61:	48 8b 00             	mov    (%rax),%rax
  8004207e64:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004207e68:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  8004207e6f:	be 02 00 00 00       	mov    $0x2,%esi
  8004207e74:	48 89 d7             	mov    %rdx,%rdi
  8004207e77:	ff d0                	callq  *%rax
  8004207e79:	48 01 45 e8          	add    %rax,-0x18(%rbp)
				break;
  8004207e7d:	eb 2f                	jmp    8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_prologue_end:
				prologue_end = 1;
  8004207e7f:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%rbp)
				break;
  8004207e86:	eb 26                	jmp    8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_epilogue_begin:
				epilogue_begin = 1;
  8004207e88:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%rbp)
				break;
  8004207e8f:	eb 1d                	jmp    8004207eae <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_isa:
				isa = _dwarf_decode_uleb128(&p);
  8004207e91:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  8004207e98:	48 89 c7             	mov    %rax,%rdi
  8004207e9b:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004207ea2:	00 00 00 
  8004207ea5:	ff d0                	callq  *%rax
  8004207ea7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
				break;
  8004207eab:	eb 01                	jmp    8004207eae <_dwarf_lineno_run_program+0x45e>
			default:
				/* Unrecognized extened opcodes. What to do? */
				break;
  8004207ead:	90                   	nop
			}

		} else {
  8004207eae:	e9 32 01 00 00       	jmpq   8004207fe5 <_dwarf_lineno_run_program+0x595>

			/*
			 * Special Opcodes.
			 */

			line += LINE(*p);
  8004207eb3:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207eb7:	0f b6 40 1a          	movzbl 0x1a(%rax),%eax
  8004207ebb:	0f be c8             	movsbl %al,%ecx
  8004207ebe:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207ec5:	0f b6 00             	movzbl (%rax),%eax
  8004207ec8:	0f b6 d0             	movzbl %al,%edx
  8004207ecb:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207ecf:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  8004207ed3:	0f b6 c0             	movzbl %al,%eax
  8004207ed6:	29 c2                	sub    %eax,%edx
  8004207ed8:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207edc:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  8004207ee0:	0f b6 f0             	movzbl %al,%esi
  8004207ee3:	89 d0                	mov    %edx,%eax
  8004207ee5:	99                   	cltd   
  8004207ee6:	f7 fe                	idiv   %esi
  8004207ee8:	89 d0                	mov    %edx,%eax
  8004207eea:	01 c8                	add    %ecx,%eax
  8004207eec:	48 98                	cltq   
  8004207eee:	48 01 45 d8          	add    %rax,-0x28(%rbp)
			address += ADDRESS(*p);
  8004207ef2:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207ef9:	0f b6 00             	movzbl (%rax),%eax
  8004207efc:	0f b6 d0             	movzbl %al,%edx
  8004207eff:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207f03:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  8004207f07:	0f b6 c0             	movzbl %al,%eax
  8004207f0a:	89 d1                	mov    %edx,%ecx
  8004207f0c:	29 c1                	sub    %eax,%ecx
  8004207f0e:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207f12:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  8004207f16:	0f b6 d8             	movzbl %al,%ebx
  8004207f19:	89 c8                	mov    %ecx,%eax
  8004207f1b:	99                   	cltd   
  8004207f1c:	f7 fb                	idiv   %ebx
  8004207f1e:	89 c2                	mov    %eax,%edx
  8004207f20:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207f24:	0f b6 40 18          	movzbl 0x18(%rax),%eax
  8004207f28:	0f b6 c0             	movzbl %al,%eax
  8004207f2b:	0f af c2             	imul   %edx,%eax
  8004207f2e:	48 98                	cltq   
  8004207f30:	48 01 45 e8          	add    %rax,-0x18(%rbp)
			APPEND_ROW;
  8004207f34:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004207f3b:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  8004207f3f:	73 0a                	jae    8004207f4b <_dwarf_lineno_run_program+0x4fb>
  8004207f41:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207f46:	e9 b3 00 00 00       	jmpq   8004207ffe <_dwarf_lineno_run_program+0x5ae>
  8004207f4b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f4f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207f53:	48 89 10             	mov    %rdx,(%rax)
  8004207f56:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f5a:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  8004207f61:	00 
  8004207f62:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f66:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207f6a:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8004207f6e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f72:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004207f76:	48 89 50 18          	mov    %rdx,0x18(%rax)
  8004207f7a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004207f7e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f82:	48 89 50 20          	mov    %rdx,0x20(%rax)
  8004207f86:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f8a:	8b 55 c8             	mov    -0x38(%rbp),%edx
  8004207f8d:	89 50 28             	mov    %edx,0x28(%rax)
  8004207f90:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f94:	8b 55 cc             	mov    -0x34(%rbp),%edx
  8004207f97:	89 50 2c             	mov    %edx,0x2c(%rax)
  8004207f9a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004207f9e:	8b 55 c4             	mov    -0x3c(%rbp),%edx
  8004207fa1:	89 50 30             	mov    %edx,0x30(%rax)
  8004207fa4:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207fa8:	48 8b 80 80 00 00 00 	mov    0x80(%rax),%rax
  8004207faf:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207fb3:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004207fb7:	48 89 90 80 00 00 00 	mov    %rdx,0x80(%rax)
			basic_block = 0;
  8004207fbe:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
			prologue_end = 0;
  8004207fc5:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
			epilogue_begin = 0;
  8004207fcc:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
			p++;
  8004207fd3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207fda:	48 83 c0 01          	add    $0x1,%rax
  8004207fde:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
	RESET_REGISTERS;

	/*
	 * Start line number program.
	 */
	while (p < pe) {
  8004207fe5:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004207fec:	48 3b 85 70 ff ff ff 	cmp    -0x90(%rbp),%rax
  8004207ff3:	0f 82 e2 fa ff ff    	jb     8004207adb <_dwarf_lineno_run_program+0x8b>
			epilogue_begin = 0;
			p++;
		}
	}

	return (DW_DLE_NONE);
  8004207ff9:	b8 00 00 00 00       	mov    $0x0,%eax

#undef  RESET_REGISTERS
#undef  APPEND_ROW
#undef  LINE
#undef  ADDRESS
}
  8004207ffe:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  8004208005:	5b                   	pop    %rbx
  8004208006:	5d                   	pop    %rbp
  8004208007:	c3                   	retq   

0000008004208008 <_dwarf_lineno_add_file>:

static int
_dwarf_lineno_add_file(Dwarf_LineInfo li, uint8_t **p, const char *compdir,
		       Dwarf_Error *error, Dwarf_Debug dbg)
{
  8004208008:	55                   	push   %rbp
  8004208009:	48 89 e5             	mov    %rsp,%rbp
  800420800c:	53                   	push   %rbx
  800420800d:	48 83 ec 48          	sub    $0x48,%rsp
  8004208011:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004208015:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8004208019:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800420801d:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
  8004208021:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
	char *fname;
	//const char *dirname;
	uint8_t *src;
	int slen;

	src = *p;
  8004208025:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208029:	48 8b 00             	mov    (%rax),%rax
  800420802c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
  return (DW_DLE_MEMORY);
  }
*/  
	//lf->lf_fullpath = NULL;
	fname = (char *) src;
  8004208030:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208034:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	src += strlen(fname) + 1;
  8004208038:	48 8b 5d e0          	mov    -0x20(%rbp),%rbx
  800420803c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208040:	48 89 c7             	mov    %rax,%rdi
  8004208043:	48 b8 bf 2d 20 04 80 	movabs $0x8004202dbf,%rax
  800420804a:	00 00 00 
  800420804d:	ff d0                	callq  *%rax
  800420804f:	48 98                	cltq   
  8004208051:	48 83 c0 01          	add    $0x1,%rax
  8004208055:	48 01 d8             	add    %rbx,%rax
  8004208058:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	_dwarf_decode_uleb128(&src);
  800420805c:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  8004208060:	48 89 c7             	mov    %rax,%rdi
  8004208063:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  800420806a:	00 00 00 
  800420806d:	ff d0                	callq  *%rax
	   snprintf(lf->lf_fullpath, slen, "%s/%s", dirname,
	   lf->lf_fname);
	   }
	   }
	*/
	_dwarf_decode_uleb128(&src);
  800420806f:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  8004208073:	48 89 c7             	mov    %rax,%rdi
  8004208076:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  800420807d:	00 00 00 
  8004208080:	ff d0                	callq  *%rax
	_dwarf_decode_uleb128(&src);
  8004208082:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  8004208086:	48 89 c7             	mov    %rax,%rdi
  8004208089:	48 b8 e7 3c 20 04 80 	movabs $0x8004203ce7,%rax
  8004208090:	00 00 00 
  8004208093:	ff d0                	callq  *%rax
	//STAILQ_INSERT_TAIL(&li->li_lflist, lf, lf_next);
	//li->li_lflen++;

	*p = src;
  8004208095:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004208099:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420809d:	48 89 10             	mov    %rdx,(%rax)

	return (DW_DLE_NONE);
  80042080a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042080a5:	48 83 c4 48          	add    $0x48,%rsp
  80042080a9:	5b                   	pop    %rbx
  80042080aa:	5d                   	pop    %rbp
  80042080ab:	c3                   	retq   

00000080042080ac <_dwarf_lineno_init>:

int     
_dwarf_lineno_init(Dwarf_Die *die, uint64_t offset, Dwarf_LineInfo linfo, Dwarf_Addr pc, Dwarf_Error *error)
{   
  80042080ac:	55                   	push   %rbp
  80042080ad:	48 89 e5             	mov    %rsp,%rbp
  80042080b0:	53                   	push   %rbx
  80042080b1:	48 81 ec 08 01 00 00 	sub    $0x108,%rsp
  80042080b8:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  80042080bf:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
  80042080c6:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
  80042080cd:	48 89 8d 00 ff ff ff 	mov    %rcx,-0x100(%rbp)
  80042080d4:	4c 89 85 f8 fe ff ff 	mov    %r8,-0x108(%rbp)
	Dwarf_Section myds = {.ds_name = ".debug_line"};
  80042080db:	48 c7 45 90 00 00 00 	movq   $0x0,-0x70(%rbp)
  80042080e2:	00 
  80042080e3:	48 c7 45 98 00 00 00 	movq   $0x0,-0x68(%rbp)
  80042080ea:	00 
  80042080eb:	48 c7 45 a0 00 00 00 	movq   $0x0,-0x60(%rbp)
  80042080f2:	00 
  80042080f3:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  80042080fa:	00 
  80042080fb:	48 b8 b0 a3 20 04 80 	movabs $0x800420a3b0,%rax
  8004208102:	00 00 00 
  8004208105:	48 89 45 90          	mov    %rax,-0x70(%rbp)
	Dwarf_Section *ds = &myds;
  8004208109:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  800420810d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	//Dwarf_LineFile lf, tlf;
	uint64_t length, hdroff, endoff;
	uint8_t *p;
	int dwarf_size, i, ret;
            
	cu = die->cu_header;
  8004208111:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  8004208118:	48 8b 80 60 03 00 00 	mov    0x360(%rax),%rax
  800420811f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
	assert(cu != NULL); 
  8004208123:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004208128:	75 35                	jne    800420815f <_dwarf_lineno_init+0xb3>
  800420812a:	48 b9 bc a3 20 04 80 	movabs $0x800420a3bc,%rcx
  8004208131:	00 00 00 
  8004208134:	48 ba c7 a3 20 04 80 	movabs $0x800420a3c7,%rdx
  800420813b:	00 00 00 
  800420813e:	be 13 01 00 00       	mov    $0x113,%esi
  8004208143:	48 bf dc a3 20 04 80 	movabs $0x800420a3dc,%rdi
  800420814a:	00 00 00 
  800420814d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208152:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004208159:	00 00 00 
  800420815c:	41 ff d0             	callq  *%r8
	assert(dbg != NULL);
  800420815f:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208166:	00 00 00 
  8004208169:	48 8b 00             	mov    (%rax),%rax
  800420816c:	48 85 c0             	test   %rax,%rax
  800420816f:	75 35                	jne    80042081a6 <_dwarf_lineno_init+0xfa>
  8004208171:	48 b9 f3 a3 20 04 80 	movabs $0x800420a3f3,%rcx
  8004208178:	00 00 00 
  800420817b:	48 ba c7 a3 20 04 80 	movabs $0x800420a3c7,%rdx
  8004208182:	00 00 00 
  8004208185:	be 14 01 00 00       	mov    $0x114,%esi
  800420818a:	48 bf dc a3 20 04 80 	movabs $0x800420a3dc,%rdi
  8004208191:	00 00 00 
  8004208194:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208199:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042081a0:	00 00 00 
  80042081a3:	41 ff d0             	callq  *%r8

	if ((_dwarf_find_section_enhanced(ds)) != 0)
  80042081a6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042081aa:	48 89 c7             	mov    %rax,%rdi
  80042081ad:	48 b8 74 54 20 04 80 	movabs $0x8004205474,%rax
  80042081b4:	00 00 00 
  80042081b7:	ff d0                	callq  *%rax
  80042081b9:	85 c0                	test   %eax,%eax
  80042081bb:	74 0a                	je     80042081c7 <_dwarf_lineno_init+0x11b>
		return (DW_DLE_NONE);
  80042081bd:	b8 00 00 00 00       	mov    $0x0,%eax
  80042081c2:	e9 4f 04 00 00       	jmpq   8004208616 <_dwarf_lineno_init+0x56a>

	li = linfo;
  80042081c7:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  80042081ce:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
	 break;
	 }
	 }
	*/

	length = dbg->read(ds->ds_data, &offset, 4);
  80042081d2:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042081d9:	00 00 00 
  80042081dc:	48 8b 00             	mov    (%rax),%rax
  80042081df:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042081e3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042081e7:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042081eb:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  80042081f2:	ba 04 00 00 00       	mov    $0x4,%edx
  80042081f7:	48 89 cf             	mov    %rcx,%rdi
  80042081fa:	ff d0                	callq  *%rax
  80042081fc:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	if (length == 0xffffffff) {
  8004208200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004208205:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
  8004208209:	75 37                	jne    8004208242 <_dwarf_lineno_init+0x196>
		dwarf_size = 8;
  800420820b:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
		length = dbg->read(ds->ds_data, &offset, 8);
  8004208212:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208219:	00 00 00 
  800420821c:	48 8b 00             	mov    (%rax),%rax
  800420821f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208223:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004208227:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420822b:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  8004208232:	ba 08 00 00 00       	mov    $0x8,%edx
  8004208237:	48 89 cf             	mov    %rcx,%rdi
  800420823a:	ff d0                	callq  *%rax
  800420823c:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004208240:	eb 07                	jmp    8004208249 <_dwarf_lineno_init+0x19d>
	} else
		dwarf_size = 4;
  8004208242:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%rbp)

	if (length > ds->ds_size - offset) {
  8004208249:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420824d:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208251:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  8004208258:	48 29 c2             	sub    %rax,%rdx
  800420825b:	48 89 d0             	mov    %rdx,%rax
  800420825e:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  8004208262:	73 0a                	jae    800420826e <_dwarf_lineno_init+0x1c2>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_LINE_LENGTH_BAD);
		return (DW_DLE_DEBUG_LINE_LENGTH_BAD);
  8004208264:	b8 0f 00 00 00       	mov    $0xf,%eax
  8004208269:	e9 a8 03 00 00       	jmpq   8004208616 <_dwarf_lineno_init+0x56a>
	}
	/*
	 * Read in line number program header.
	 */
	li->li_length = length;
  800420826e:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208272:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208276:	48 89 10             	mov    %rdx,(%rax)
	endoff = offset + length;
  8004208279:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  8004208280:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208284:	48 01 d0             	add    %rdx,%rax
  8004208287:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
	li->li_version = dbg->read(ds->ds_data, &offset, 2); /* FIXME: verify version */
  800420828b:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208292:	00 00 00 
  8004208295:	48 8b 00             	mov    (%rax),%rax
  8004208298:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420829c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042082a0:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042082a4:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  80042082ab:	ba 02 00 00 00       	mov    $0x2,%edx
  80042082b0:	48 89 cf             	mov    %rcx,%rdi
  80042082b3:	ff d0                	callq  *%rax
  80042082b5:	89 c2                	mov    %eax,%edx
  80042082b7:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042082bb:	66 89 50 08          	mov    %dx,0x8(%rax)
	li->li_hdrlen = dbg->read(ds->ds_data, &offset, dwarf_size);
  80042082bf:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042082c6:	00 00 00 
  80042082c9:	48 8b 00             	mov    (%rax),%rax
  80042082cc:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042082d0:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042082d4:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042082d8:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  80042082db:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  80042082e2:	48 89 cf             	mov    %rcx,%rdi
  80042082e5:	ff d0                	callq  *%rax
  80042082e7:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80042082eb:	48 89 42 10          	mov    %rax,0x10(%rdx)
	hdroff = offset;
  80042082ef:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  80042082f6:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
	li->li_minlen = dbg->read(ds->ds_data, &offset, 1);
  80042082fa:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208301:	00 00 00 
  8004208304:	48 8b 00             	mov    (%rax),%rax
  8004208307:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420830b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420830f:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004208313:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420831a:	ba 01 00 00 00       	mov    $0x1,%edx
  800420831f:	48 89 cf             	mov    %rcx,%rdi
  8004208322:	ff d0                	callq  *%rax
  8004208324:	89 c2                	mov    %eax,%edx
  8004208326:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420832a:	88 50 18             	mov    %dl,0x18(%rax)
	li->li_defstmt = dbg->read(ds->ds_data, &offset, 1);
  800420832d:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208334:	00 00 00 
  8004208337:	48 8b 00             	mov    (%rax),%rax
  800420833a:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420833e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004208342:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004208346:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420834d:	ba 01 00 00 00       	mov    $0x1,%edx
  8004208352:	48 89 cf             	mov    %rcx,%rdi
  8004208355:	ff d0                	callq  *%rax
  8004208357:	89 c2                	mov    %eax,%edx
  8004208359:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420835d:	88 50 19             	mov    %dl,0x19(%rax)
	li->li_lbase = dbg->read(ds->ds_data, &offset, 1);
  8004208360:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208367:	00 00 00 
  800420836a:	48 8b 00             	mov    (%rax),%rax
  800420836d:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208371:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004208375:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004208379:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  8004208380:	ba 01 00 00 00       	mov    $0x1,%edx
  8004208385:	48 89 cf             	mov    %rcx,%rdi
  8004208388:	ff d0                	callq  *%rax
  800420838a:	89 c2                	mov    %eax,%edx
  800420838c:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208390:	88 50 1a             	mov    %dl,0x1a(%rax)
	li->li_lrange = dbg->read(ds->ds_data, &offset, 1);
  8004208393:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  800420839a:	00 00 00 
  800420839d:	48 8b 00             	mov    (%rax),%rax
  80042083a0:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042083a4:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042083a8:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042083ac:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  80042083b3:	ba 01 00 00 00       	mov    $0x1,%edx
  80042083b8:	48 89 cf             	mov    %rcx,%rdi
  80042083bb:	ff d0                	callq  *%rax
  80042083bd:	89 c2                	mov    %eax,%edx
  80042083bf:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042083c3:	88 50 1b             	mov    %dl,0x1b(%rax)
	li->li_opbase = dbg->read(ds->ds_data, &offset, 1);
  80042083c6:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  80042083cd:	00 00 00 
  80042083d0:	48 8b 00             	mov    (%rax),%rax
  80042083d3:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042083d7:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  80042083db:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042083df:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  80042083e6:	ba 01 00 00 00       	mov    $0x1,%edx
  80042083eb:	48 89 cf             	mov    %rcx,%rdi
  80042083ee:	ff d0                	callq  *%rax
  80042083f0:	89 c2                	mov    %eax,%edx
  80042083f2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042083f6:	88 50 1c             	mov    %dl,0x1c(%rax)
	//STAILQ_INIT(&li->li_lflist);
	//STAILQ_INIT(&li->li_lnlist);

	if ((int)li->li_hdrlen - 5 < li->li_opbase - 1) {
  80042083f9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042083fd:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004208401:	8d 50 fb             	lea    -0x5(%rax),%edx
  8004208404:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208408:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420840c:	0f b6 c0             	movzbl %al,%eax
  800420840f:	83 e8 01             	sub    $0x1,%eax
  8004208412:	39 c2                	cmp    %eax,%edx
  8004208414:	7d 0c                	jge    8004208422 <_dwarf_lineno_init+0x376>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  8004208416:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  800420841d:	e9 f1 01 00 00       	jmpq   8004208613 <_dwarf_lineno_init+0x567>
	}

	li->li_oplen = global_std_op;
  8004208422:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208426:	48 bb 40 db 21 04 80 	movabs $0x800421db40,%rbx
  800420842d:	00 00 00 
  8004208430:	48 89 58 20          	mov    %rbx,0x20(%rax)

	/*
	 * Read in std opcode arg length list. Note that the first
	 * element is not used.
	 */
	for (i = 1; i < li->li_opbase; i++)
  8004208434:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%rbp)
  800420843b:	eb 41                	jmp    800420847e <_dwarf_lineno_init+0x3d2>
		li->li_oplen[i] = dbg->read(ds->ds_data, &offset, 1);
  800420843d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208441:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208445:	8b 45 e0             	mov    -0x20(%rbp),%eax
  8004208448:	48 98                	cltq   
  800420844a:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
  800420844e:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208455:	00 00 00 
  8004208458:	48 8b 00             	mov    (%rax),%rax
  800420845b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420845f:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004208463:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004208467:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420846e:	ba 01 00 00 00       	mov    $0x1,%edx
  8004208473:	48 89 cf             	mov    %rcx,%rdi
  8004208476:	ff d0                	callq  *%rax
  8004208478:	88 03                	mov    %al,(%rbx)

	/*
	 * Read in std opcode arg length list. Note that the first
	 * element is not used.
	 */
	for (i = 1; i < li->li_opbase; i++)
  800420847a:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
  800420847e:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004208482:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  8004208486:	0f b6 c0             	movzbl %al,%eax
  8004208489:	3b 45 e0             	cmp    -0x20(%rbp),%eax
  800420848c:	7f af                	jg     800420843d <_dwarf_lineno_init+0x391>
		li->li_oplen[i] = dbg->read(ds->ds_data, &offset, 1);

	/*
	 * Check how many strings in the include dir string array.
	 */
	length = 0;
  800420848e:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004208495:	00 
	p = ds->ds_data + offset;
  8004208496:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420849a:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420849e:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  80042084a5:	48 01 d0             	add    %rdx,%rax
  80042084a8:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
	while (*p != '\0') {
  80042084af:	eb 1f                	jmp    80042084d0 <_dwarf_lineno_init+0x424>
		while (*p++ != '\0')
  80042084b1:	90                   	nop
  80042084b2:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80042084b9:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80042084bd:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
  80042084c4:	0f b6 00             	movzbl (%rax),%eax
  80042084c7:	84 c0                	test   %al,%al
  80042084c9:	75 e7                	jne    80042084b2 <_dwarf_lineno_init+0x406>
			;
		length++;
  80042084cb:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
	/*
	 * Check how many strings in the include dir string array.
	 */
	length = 0;
	p = ds->ds_data + offset;
	while (*p != '\0') {
  80042084d0:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80042084d7:	0f b6 00             	movzbl (%rax),%eax
  80042084da:	84 c0                	test   %al,%al
  80042084dc:	75 d3                	jne    80042084b1 <_dwarf_lineno_init+0x405>
		while (*p++ != '\0')
			;
		length++;
	}
	li->li_inclen = length;
  80042084de:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042084e2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042084e6:	48 89 50 30          	mov    %rdx,0x30(%rax)

	/* Sanity check. */
	if (p - ds->ds_data > (int) ds->ds_size) {
  80042084ea:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80042084f1:	48 89 c2             	mov    %rax,%rdx
  80042084f4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042084f8:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042084fc:	48 29 c2             	sub    %rax,%rdx
  80042084ff:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208503:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208507:	48 98                	cltq   
  8004208509:	48 39 c2             	cmp    %rax,%rdx
  800420850c:	7e 0c                	jle    800420851a <_dwarf_lineno_init+0x46e>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  800420850e:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  8004208515:	e9 f9 00 00 00       	jmpq   8004208613 <_dwarf_lineno_init+0x567>
	}
	p++;
  800420851a:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004208521:	48 83 c0 01          	add    $0x1,%rax
  8004208525:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

	/*
	 * Process file list.
	 */
	while (*p != '\0') {
  800420852c:	eb 3c                	jmp    800420856a <_dwarf_lineno_init+0x4be>
		ret = _dwarf_lineno_add_file(li, &p, NULL, error, dbg);
  800420852e:	48 b8 d8 c5 21 04 80 	movabs $0x800421c5d8,%rax
  8004208535:	00 00 00 
  8004208538:	48 8b 08             	mov    (%rax),%rcx
  800420853b:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  8004208542:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  8004208549:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420854d:	49 89 c8             	mov    %rcx,%r8
  8004208550:	48 89 d1             	mov    %rdx,%rcx
  8004208553:	ba 00 00 00 00       	mov    $0x0,%edx
  8004208558:	48 89 c7             	mov    %rax,%rdi
  800420855b:	48 b8 08 80 20 04 80 	movabs $0x8004208008,%rax
  8004208562:	00 00 00 
  8004208565:	ff d0                	callq  *%rax
  8004208567:	89 45 dc             	mov    %eax,-0x24(%rbp)
	p++;

	/*
	 * Process file list.
	 */
	while (*p != '\0') {
  800420856a:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004208571:	0f b6 00             	movzbl (%rax),%eax
  8004208574:	84 c0                	test   %al,%al
  8004208576:	75 b6                	jne    800420852e <_dwarf_lineno_init+0x482>
		ret = _dwarf_lineno_add_file(li, &p, NULL, error, dbg);
		//p++;
	}

	p++;
  8004208578:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420857f:	48 83 c0 01          	add    $0x1,%rax
  8004208583:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
	/* Sanity check. */
	if (p - ds->ds_data - hdroff != li->li_hdrlen) {
  800420858a:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004208591:	48 89 c2             	mov    %rax,%rdx
  8004208594:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208598:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420859c:	48 29 c2             	sub    %rax,%rdx
  800420859f:	48 89 d0             	mov    %rdx,%rax
  80042085a2:	48 2b 45 b0          	sub    -0x50(%rbp),%rax
  80042085a6:	48 89 c2             	mov    %rax,%rdx
  80042085a9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042085ad:	48 8b 40 10          	mov    0x10(%rax),%rax
  80042085b1:	48 39 c2             	cmp    %rax,%rdx
  80042085b4:	74 09                	je     80042085bf <_dwarf_lineno_init+0x513>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  80042085b6:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  80042085bd:	eb 54                	jmp    8004208613 <_dwarf_lineno_init+0x567>
	}

	/*
	 * Process line number program.
	 */
	ret = _dwarf_lineno_run_program(cu, li, p, ds->ds_data + endoff, pc,
  80042085bf:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042085c3:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042085c7:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042085cb:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  80042085cf:	48 8b 95 28 ff ff ff 	mov    -0xd8(%rbp),%rdx
  80042085d6:	4c 8b 85 f8 fe ff ff 	mov    -0x108(%rbp),%r8
  80042085dd:	48 8b bd 00 ff ff ff 	mov    -0x100(%rbp),%rdi
  80042085e4:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  80042085e8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042085ec:	4d 89 c1             	mov    %r8,%r9
  80042085ef:	49 89 f8             	mov    %rdi,%r8
  80042085f2:	48 89 c7             	mov    %rax,%rdi
  80042085f5:	48 b8 50 7a 20 04 80 	movabs $0x8004207a50,%rax
  80042085fc:	00 00 00 
  80042085ff:	ff d0                	callq  *%rax
  8004208601:	89 45 dc             	mov    %eax,-0x24(%rbp)
					error);
	if (ret != DW_DLE_NONE)
  8004208604:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8004208608:	74 02                	je     800420860c <_dwarf_lineno_init+0x560>
		goto fail_cleanup;
  800420860a:	eb 07                	jmp    8004208613 <_dwarf_lineno_init+0x567>

	//cu->cu_lineinfo = li;

	return (DW_DLE_NONE);
  800420860c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208611:	eb 03                	jmp    8004208616 <_dwarf_lineno_init+0x56a>
fail_cleanup:

	/*if (li->li_oplen)
	  free(li->li_oplen);*/

	return (ret);
  8004208613:	8b 45 dc             	mov    -0x24(%rbp),%eax
}
  8004208616:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
  800420861d:	5b                   	pop    %rbx
  800420861e:	5d                   	pop    %rbp
  800420861f:	c3                   	retq   

0000008004208620 <dwarf_srclines>:

int
dwarf_srclines(Dwarf_Die *die, Dwarf_Line linebuf, Dwarf_Addr pc, Dwarf_Error *error)
{
  8004208620:	55                   	push   %rbp
  8004208621:	48 89 e5             	mov    %rsp,%rbp
  8004208624:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  800420862b:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  8004208632:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  8004208639:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  8004208640:	48 89 8d 50 ff ff ff 	mov    %rcx,-0xb0(%rbp)
	_Dwarf_LineInfo li;
	Dwarf_Attribute *at;

	assert(die);
  8004208647:	48 83 bd 68 ff ff ff 	cmpq   $0x0,-0x98(%rbp)
  800420864e:	00 
  800420864f:	75 35                	jne    8004208686 <dwarf_srclines+0x66>
  8004208651:	48 b9 ff a3 20 04 80 	movabs $0x800420a3ff,%rcx
  8004208658:	00 00 00 
  800420865b:	48 ba c7 a3 20 04 80 	movabs $0x800420a3c7,%rdx
  8004208662:	00 00 00 
  8004208665:	be 9a 01 00 00       	mov    $0x19a,%esi
  800420866a:	48 bf dc a3 20 04 80 	movabs $0x800420a3dc,%rdi
  8004208671:	00 00 00 
  8004208674:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208679:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004208680:	00 00 00 
  8004208683:	41 ff d0             	callq  *%r8
	assert(linebuf);
  8004208686:	48 83 bd 60 ff ff ff 	cmpq   $0x0,-0xa0(%rbp)
  800420868d:	00 
  800420868e:	75 35                	jne    80042086c5 <dwarf_srclines+0xa5>
  8004208690:	48 b9 03 a4 20 04 80 	movabs $0x800420a403,%rcx
  8004208697:	00 00 00 
  800420869a:	48 ba c7 a3 20 04 80 	movabs $0x800420a3c7,%rdx
  80042086a1:	00 00 00 
  80042086a4:	be 9b 01 00 00       	mov    $0x19b,%esi
  80042086a9:	48 bf dc a3 20 04 80 	movabs $0x800420a3dc,%rdi
  80042086b0:	00 00 00 
  80042086b3:	b8 00 00 00 00       	mov    $0x0,%eax
  80042086b8:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  80042086bf:	00 00 00 
  80042086c2:	41 ff d0             	callq  *%r8

	memset(&li, 0, sizeof(_Dwarf_LineInfo));
  80042086c5:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  80042086cc:	ba 88 00 00 00       	mov    $0x88,%edx
  80042086d1:	be 00 00 00 00       	mov    $0x0,%esi
  80042086d6:	48 89 c7             	mov    %rax,%rdi
  80042086d9:	48 b8 c4 30 20 04 80 	movabs $0x80042030c4,%rax
  80042086e0:	00 00 00 
  80042086e3:	ff d0                	callq  *%rax

	if ((at = _dwarf_attr_find(die, DW_AT_stmt_list)) == NULL) {
  80042086e5:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042086ec:	be 10 00 00 00       	mov    $0x10,%esi
  80042086f1:	48 89 c7             	mov    %rax,%rdi
  80042086f4:	48 b8 f9 4f 20 04 80 	movabs $0x8004204ff9,%rax
  80042086fb:	00 00 00 
  80042086fe:	ff d0                	callq  *%rax
  8004208700:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004208704:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004208709:	75 0a                	jne    8004208715 <dwarf_srclines+0xf5>
		DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
		return (DW_DLV_NO_ENTRY);
  800420870b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004208710:	e9 84 00 00 00       	jmpq   8004208799 <dwarf_srclines+0x179>
	}

	if (_dwarf_lineno_init(die, at->u[0].u64, &li, pc, error) !=
  8004208715:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208719:	48 8b 70 28          	mov    0x28(%rax),%rsi
  800420871d:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  8004208724:	48 8b 8d 58 ff ff ff 	mov    -0xa8(%rbp),%rcx
  800420872b:	48 8d 95 70 ff ff ff 	lea    -0x90(%rbp),%rdx
  8004208732:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004208739:	49 89 f8             	mov    %rdi,%r8
  800420873c:	48 89 c7             	mov    %rax,%rdi
  800420873f:	48 b8 ac 80 20 04 80 	movabs $0x80042080ac,%rax
  8004208746:	00 00 00 
  8004208749:	ff d0                	callq  *%rax
  800420874b:	85 c0                	test   %eax,%eax
  800420874d:	74 07                	je     8004208756 <dwarf_srclines+0x136>
	    DW_DLE_NONE)
	{
		return (DW_DLV_ERROR);
  800420874f:	b8 01 00 00 00       	mov    $0x1,%eax
  8004208754:	eb 43                	jmp    8004208799 <dwarf_srclines+0x179>
	}
	*linebuf = li.li_line;
  8004208756:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  800420875d:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004208761:	48 89 10             	mov    %rdx,(%rax)
  8004208764:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004208768:	48 89 50 08          	mov    %rdx,0x8(%rax)
  800420876c:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004208770:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8004208774:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004208778:	48 89 50 18          	mov    %rdx,0x18(%rax)
  800420877c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004208780:	48 89 50 20          	mov    %rdx,0x20(%rax)
  8004208784:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004208788:	48 89 50 28          	mov    %rdx,0x28(%rax)
  800420878c:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208790:	48 89 50 30          	mov    %rdx,0x30(%rax)

	return (DW_DLV_OK);
  8004208794:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004208799:	c9                   	leaveq 
  800420879a:	c3                   	retq   

000000800420879b <_dwarf_find_section>:
uintptr_t
read_section_headers(uintptr_t, uintptr_t);

Dwarf_Section *
_dwarf_find_section(const char *name)
{
  800420879b:	55                   	push   %rbp
  800420879c:	48 89 e5             	mov    %rsp,%rbp
  800420879f:	48 83 ec 20          	sub    $0x20,%rsp
  80042087a3:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Dwarf_Section *ret=NULL;
  80042087a7:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042087ae:	00 
	int i;

	for(i=0; i < NDEBUG_SECT; i++) {
  80042087af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  80042087b6:	eb 57                	jmp    800420880f <_dwarf_find_section+0x74>
		if(!strcmp(section_info[i].ds_name, name)) {
  80042087b8:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042087bf:	00 00 00 
  80042087c2:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80042087c5:	48 63 d2             	movslq %edx,%rdx
  80042087c8:	48 c1 e2 05          	shl    $0x5,%rdx
  80042087cc:	48 01 d0             	add    %rdx,%rax
  80042087cf:	48 8b 00             	mov    (%rax),%rax
  80042087d2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042087d6:	48 89 d6             	mov    %rdx,%rsi
  80042087d9:	48 89 c7             	mov    %rax,%rdi
  80042087dc:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  80042087e3:	00 00 00 
  80042087e6:	ff d0                	callq  *%rax
  80042087e8:	85 c0                	test   %eax,%eax
  80042087ea:	75 1f                	jne    800420880b <_dwarf_find_section+0x70>
			ret = (section_info + i);
  80042087ec:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042087ef:	48 98                	cltq   
  80042087f1:	48 c1 e0 05          	shl    $0x5,%rax
  80042087f5:	48 89 c2             	mov    %rax,%rdx
  80042087f8:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042087ff:	00 00 00 
  8004208802:	48 01 d0             	add    %rdx,%rax
  8004208805:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			break;
  8004208809:	eb 0a                	jmp    8004208815 <_dwarf_find_section+0x7a>
_dwarf_find_section(const char *name)
{
	Dwarf_Section *ret=NULL;
	int i;

	for(i=0; i < NDEBUG_SECT; i++) {
  800420880b:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  800420880f:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  8004208813:	7e a3                	jle    80042087b8 <_dwarf_find_section+0x1d>
			ret = (section_info + i);
			break;
		}
	}

	return ret;
  8004208815:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208819:	c9                   	leaveq 
  800420881a:	c3                   	retq   

000000800420881b <find_debug_sections>:

void find_debug_sections(uintptr_t elf) 
{
  800420881b:	55                   	push   %rbp
  800420881c:	48 89 e5             	mov    %rsp,%rbp
  800420881f:	48 83 ec 40          	sub    $0x40,%rsp
  8004208823:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
	Elf *ehdr = (Elf *)elf;
  8004208827:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420882b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uintptr_t debug_address = USTABDATA;
  800420882f:	48 c7 45 f8 00 00 20 	movq   $0x200000,-0x8(%rbp)
  8004208836:	00 
	Secthdr *sh = (Secthdr *)(((uint8_t *)ehdr + ehdr->e_shoff));
  8004208837:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420883b:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420883f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208843:	48 01 d0             	add    %rdx,%rax
  8004208846:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	Secthdr *shstr_tab = sh + ehdr->e_shstrndx;
  800420884a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420884e:	0f b7 40 3e          	movzwl 0x3e(%rax),%eax
  8004208852:	0f b7 c0             	movzwl %ax,%eax
  8004208855:	48 c1 e0 06          	shl    $0x6,%rax
  8004208859:	48 89 c2             	mov    %rax,%rdx
  800420885c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208860:	48 01 d0             	add    %rdx,%rax
  8004208863:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	Secthdr* esh = sh + ehdr->e_shnum;
  8004208867:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420886b:	0f b7 40 3c          	movzwl 0x3c(%rax),%eax
  800420886f:	0f b7 c0             	movzwl %ax,%eax
  8004208872:	48 c1 e0 06          	shl    $0x6,%rax
  8004208876:	48 89 c2             	mov    %rax,%rdx
  8004208879:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420887d:	48 01 d0             	add    %rdx,%rax
  8004208880:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	for(;sh < esh; sh++) {
  8004208884:	e9 4b 02 00 00       	jmpq   8004208ad4 <find_debug_sections+0x2b9>
		char* name = (char*)((uint8_t*)elf + shstr_tab->sh_offset) + sh->sh_name;
  8004208889:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420888d:	8b 00                	mov    (%rax),%eax
  800420888f:	89 c2                	mov    %eax,%edx
  8004208891:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208895:	48 8b 48 18          	mov    0x18(%rax),%rcx
  8004208899:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420889d:	48 01 c8             	add    %rcx,%rax
  80042088a0:	48 01 d0             	add    %rdx,%rax
  80042088a3:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		if(!strcmp(name, ".debug_info")) {
  80042088a7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042088ab:	48 be 0b a4 20 04 80 	movabs $0x800420a40b,%rsi
  80042088b2:	00 00 00 
  80042088b5:	48 89 c7             	mov    %rax,%rdi
  80042088b8:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  80042088bf:	00 00 00 
  80042088c2:	ff d0                	callq  *%rax
  80042088c4:	85 c0                	test   %eax,%eax
  80042088c6:	75 4b                	jne    8004208913 <find_debug_sections+0xf8>
			section_info[DEBUG_INFO].ds_data = (uint8_t*)debug_address;
  80042088c8:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042088cc:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042088d3:	00 00 00 
  80042088d6:	48 89 50 08          	mov    %rdx,0x8(%rax)
			section_info[DEBUG_INFO].ds_addr = debug_address;
  80042088da:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042088e1:	00 00 00 
  80042088e4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042088e8:	48 89 50 10          	mov    %rdx,0x10(%rax)
			section_info[DEBUG_INFO].ds_size = sh->sh_size;
  80042088ec:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042088f0:	48 8b 50 20          	mov    0x20(%rax),%rdx
  80042088f4:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042088fb:	00 00 00 
  80042088fe:	48 89 50 18          	mov    %rdx,0x18(%rax)
			debug_address += sh->sh_size;
  8004208902:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208906:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420890a:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420890e:	e9 bc 01 00 00       	jmpq   8004208acf <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_abbrev")) {
  8004208913:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208917:	48 be 17 a4 20 04 80 	movabs $0x800420a417,%rsi
  800420891e:	00 00 00 
  8004208921:	48 89 c7             	mov    %rax,%rdi
  8004208924:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  800420892b:	00 00 00 
  800420892e:	ff d0                	callq  *%rax
  8004208930:	85 c0                	test   %eax,%eax
  8004208932:	75 4b                	jne    800420897f <find_debug_sections+0x164>
			section_info[DEBUG_ABBREV].ds_data = (uint8_t*)debug_address;
  8004208934:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208938:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  800420893f:	00 00 00 
  8004208942:	48 89 50 28          	mov    %rdx,0x28(%rax)
			section_info[DEBUG_ABBREV].ds_addr = debug_address;
  8004208946:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  800420894d:	00 00 00 
  8004208950:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208954:	48 89 50 30          	mov    %rdx,0x30(%rax)
			section_info[DEBUG_ABBREV].ds_size = sh->sh_size;
  8004208958:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420895c:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208960:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208967:	00 00 00 
  800420896a:	48 89 50 38          	mov    %rdx,0x38(%rax)
			debug_address += sh->sh_size;
  800420896e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208972:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004208976:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420897a:	e9 50 01 00 00       	jmpq   8004208acf <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_line")){
  800420897f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208983:	48 be 2f a4 20 04 80 	movabs $0x800420a42f,%rsi
  800420898a:	00 00 00 
  800420898d:	48 89 c7             	mov    %rax,%rdi
  8004208990:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208997:	00 00 00 
  800420899a:	ff d0                	callq  *%rax
  800420899c:	85 c0                	test   %eax,%eax
  800420899e:	75 4b                	jne    80042089eb <find_debug_sections+0x1d0>
			section_info[DEBUG_LINE].ds_data = (uint8_t*)debug_address;
  80042089a0:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042089a4:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042089ab:	00 00 00 
  80042089ae:	48 89 50 68          	mov    %rdx,0x68(%rax)
			section_info[DEBUG_LINE].ds_addr = debug_address;
  80042089b2:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042089b9:	00 00 00 
  80042089bc:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042089c0:	48 89 50 70          	mov    %rdx,0x70(%rax)
			section_info[DEBUG_LINE].ds_size = sh->sh_size;
  80042089c4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042089c8:	48 8b 50 20          	mov    0x20(%rax),%rdx
  80042089cc:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042089d3:	00 00 00 
  80042089d6:	48 89 50 78          	mov    %rdx,0x78(%rax)
			debug_address += sh->sh_size;
  80042089da:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042089de:	48 8b 40 20          	mov    0x20(%rax),%rax
  80042089e2:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  80042089e6:	e9 e4 00 00 00       	jmpq   8004208acf <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".eh_frame")){
  80042089eb:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042089ef:	48 be 25 a4 20 04 80 	movabs $0x800420a425,%rsi
  80042089f6:	00 00 00 
  80042089f9:	48 89 c7             	mov    %rax,%rdi
  80042089fc:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208a03:	00 00 00 
  8004208a06:	ff d0                	callq  *%rax
  8004208a08:	85 c0                	test   %eax,%eax
  8004208a0a:	75 53                	jne    8004208a5f <find_debug_sections+0x244>
			section_info[DEBUG_FRAME].ds_data = (uint8_t*)sh->sh_addr;
  8004208a0c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208a10:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004208a14:	48 89 c2             	mov    %rax,%rdx
  8004208a17:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208a1e:	00 00 00 
  8004208a21:	48 89 50 48          	mov    %rdx,0x48(%rax)
			section_info[DEBUG_FRAME].ds_addr = sh->sh_addr;
  8004208a25:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208a29:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004208a2d:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208a34:	00 00 00 
  8004208a37:	48 89 50 50          	mov    %rdx,0x50(%rax)
			section_info[DEBUG_FRAME].ds_size = sh->sh_size;
  8004208a3b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208a3f:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208a43:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208a4a:	00 00 00 
  8004208a4d:	48 89 50 58          	mov    %rdx,0x58(%rax)
			debug_address += sh->sh_size;
  8004208a51:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208a55:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004208a59:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  8004208a5d:	eb 70                	jmp    8004208acf <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_str")) {
  8004208a5f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208a63:	48 be 3b a4 20 04 80 	movabs $0x800420a43b,%rsi
  8004208a6a:	00 00 00 
  8004208a6d:	48 89 c7             	mov    %rax,%rdi
  8004208a70:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208a77:	00 00 00 
  8004208a7a:	ff d0                	callq  *%rax
  8004208a7c:	85 c0                	test   %eax,%eax
  8004208a7e:	75 4f                	jne    8004208acf <find_debug_sections+0x2b4>
			section_info[DEBUG_STR].ds_data = (uint8_t*)debug_address;
  8004208a80:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208a84:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208a8b:	00 00 00 
  8004208a8e:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
			section_info[DEBUG_STR].ds_addr = debug_address;
  8004208a95:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208a9c:	00 00 00 
  8004208a9f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208aa3:	48 89 90 90 00 00 00 	mov    %rdx,0x90(%rax)
			section_info[DEBUG_STR].ds_size = sh->sh_size;
  8004208aaa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208aae:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208ab2:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208ab9:	00 00 00 
  8004208abc:	48 89 90 98 00 00 00 	mov    %rdx,0x98(%rax)
			debug_address += sh->sh_size;
  8004208ac3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208ac7:	48 8b 40 20          	mov    0x20(%rax),%rax
  8004208acb:	48 01 45 f8          	add    %rax,-0x8(%rbp)
	Elf *ehdr = (Elf *)elf;
	uintptr_t debug_address = USTABDATA;
	Secthdr *sh = (Secthdr *)(((uint8_t *)ehdr + ehdr->e_shoff));
	Secthdr *shstr_tab = sh + ehdr->e_shstrndx;
	Secthdr* esh = sh + ehdr->e_shnum;
	for(;sh < esh; sh++) {
  8004208acf:	48 83 45 f0 40       	addq   $0x40,-0x10(%rbp)
  8004208ad4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208ad8:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8004208adc:	0f 82 a7 fd ff ff    	jb     8004208889 <find_debug_sections+0x6e>
			section_info[DEBUG_STR].ds_size = sh->sh_size;
			debug_address += sh->sh_size;
		}
	}

}
  8004208ae2:	c9                   	leaveq 
  8004208ae3:	c3                   	retq   

0000008004208ae4 <read_section_headers>:

uint64_t
read_section_headers(uintptr_t elfhdr, uintptr_t to_va)
{
  8004208ae4:	55                   	push   %rbp
  8004208ae5:	48 89 e5             	mov    %rsp,%rbp
  8004208ae8:	48 81 ec 60 01 00 00 	sub    $0x160,%rsp
  8004208aef:	48 89 bd a8 fe ff ff 	mov    %rdi,-0x158(%rbp)
  8004208af6:	48 89 b5 a0 fe ff ff 	mov    %rsi,-0x160(%rbp)
	Secthdr* secthdr_ptr[20] = {0};
  8004208afd:	48 8d b5 c0 fe ff ff 	lea    -0x140(%rbp),%rsi
  8004208b04:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208b09:	ba 14 00 00 00       	mov    $0x14,%edx
  8004208b0e:	48 89 f7             	mov    %rsi,%rdi
  8004208b11:	48 89 d1             	mov    %rdx,%rcx
  8004208b14:	f3 48 ab             	rep stos %rax,%es:(%rdi)
	char* kvbase = ROUNDUP((char*)to_va, SECTSIZE);
  8004208b17:	48 c7 45 e8 00 02 00 	movq   $0x200,-0x18(%rbp)
  8004208b1e:	00 
  8004208b1f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208b23:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  8004208b2a:	48 01 d0             	add    %rdx,%rax
  8004208b2d:	48 83 e8 01          	sub    $0x1,%rax
  8004208b31:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004208b35:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208b39:	ba 00 00 00 00       	mov    $0x0,%edx
  8004208b3e:	48 f7 75 e8          	divq   -0x18(%rbp)
  8004208b42:	48 89 d0             	mov    %rdx,%rax
  8004208b45:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004208b49:	48 29 c2             	sub    %rax,%rdx
  8004208b4c:	48 89 d0             	mov    %rdx,%rax
  8004208b4f:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	uint64_t kvoffset = 0;
  8004208b53:	48 c7 85 b8 fe ff ff 	movq   $0x0,-0x148(%rbp)
  8004208b5a:	00 00 00 00 
	char *orig_secthdr = (char*)kvbase;
  8004208b5e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208b62:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	char * secthdr = NULL;
  8004208b66:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  8004208b6d:	00 
	uint64_t offset;
	if(elfhdr == KELFHDR)
  8004208b6e:	48 b8 00 00 01 04 80 	movabs $0x8004010000,%rax
  8004208b75:	00 00 00 
  8004208b78:	48 39 85 a8 fe ff ff 	cmp    %rax,-0x158(%rbp)
  8004208b7f:	75 11                	jne    8004208b92 <read_section_headers+0xae>
		offset = ((Elf*)elfhdr)->e_shoff;
  8004208b81:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208b88:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004208b8c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004208b90:	eb 26                	jmp    8004208bb8 <read_section_headers+0xd4>
	else
		offset = ((Elf*)elfhdr)->e_shoff + (elfhdr - KERNBASE);
  8004208b92:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208b99:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8004208b9d:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208ba4:	48 01 c2             	add    %rax,%rdx
  8004208ba7:	48 b8 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rax
  8004208bae:	ff ff ff 
  8004208bb1:	48 01 d0             	add    %rdx,%rax
  8004208bb4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	int numSectionHeaders = ((Elf*)elfhdr)->e_shnum;
  8004208bb8:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208bbf:	0f b7 40 3c          	movzwl 0x3c(%rax),%eax
  8004208bc3:	0f b7 c0             	movzwl %ax,%eax
  8004208bc6:	89 45 c4             	mov    %eax,-0x3c(%rbp)
	int sizeSections = ((Elf*)elfhdr)->e_shentsize;
  8004208bc9:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208bd0:	0f b7 40 3a          	movzwl 0x3a(%rax),%eax
  8004208bd4:	0f b7 c0             	movzwl %ax,%eax
  8004208bd7:	89 45 c0             	mov    %eax,-0x40(%rbp)
	char *nametab;
	int i;
	uint64_t temp;
	char *name;

	Elf *ehdr = (Elf *)elfhdr;
  8004208bda:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  8004208be1:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
	Secthdr *sec_name;  

	readseg((uint64_t)orig_secthdr , numSectionHeaders * sizeSections,
  8004208be5:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8004208be8:	0f af 45 c0          	imul   -0x40(%rbp),%eax
  8004208bec:	48 63 f0             	movslq %eax,%rsi
  8004208bef:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208bf3:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004208bfa:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208bfe:	48 89 c7             	mov    %rax,%rdi
  8004208c01:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  8004208c08:	00 00 00 
  8004208c0b:	ff d0                	callq  *%rax
		offset, &kvoffset);
	secthdr = (char*)orig_secthdr + (offset - ROUNDDOWN(offset, SECTSIZE));
  8004208c0d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208c11:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8004208c15:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004208c19:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  8004208c1f:	48 89 c2             	mov    %rax,%rdx
  8004208c22:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208c26:	48 29 d0             	sub    %rdx,%rax
  8004208c29:	48 89 c2             	mov    %rax,%rdx
  8004208c2c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208c30:	48 01 d0             	add    %rdx,%rax
  8004208c33:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
	for (i = 0; i < numSectionHeaders; i++)
  8004208c37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  8004208c3e:	eb 24                	jmp    8004208c64 <read_section_headers+0x180>
	{
		secthdr_ptr[i] = (Secthdr*)(secthdr) + i;
  8004208c40:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208c43:	48 98                	cltq   
  8004208c45:	48 c1 e0 06          	shl    $0x6,%rax
  8004208c49:	48 89 c2             	mov    %rax,%rdx
  8004208c4c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004208c50:	48 01 c2             	add    %rax,%rdx
  8004208c53:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208c56:	48 98                	cltq   
  8004208c58:	48 89 94 c5 c0 fe ff 	mov    %rdx,-0x140(%rbp,%rax,8)
  8004208c5f:	ff 
	Secthdr *sec_name;  

	readseg((uint64_t)orig_secthdr , numSectionHeaders * sizeSections,
		offset, &kvoffset);
	secthdr = (char*)orig_secthdr + (offset - ROUNDDOWN(offset, SECTSIZE));
	for (i = 0; i < numSectionHeaders; i++)
  8004208c60:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  8004208c64:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208c67:	3b 45 c4             	cmp    -0x3c(%rbp),%eax
  8004208c6a:	7c d4                	jl     8004208c40 <read_section_headers+0x15c>
	{
		secthdr_ptr[i] = (Secthdr*)(secthdr) + i;
	}
	
	sec_name = secthdr_ptr[ehdr->e_shstrndx]; 
  8004208c6c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004208c70:	0f b7 40 3e          	movzwl 0x3e(%rax),%eax
  8004208c74:	0f b7 c0             	movzwl %ax,%eax
  8004208c77:	48 98                	cltq   
  8004208c79:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208c80:	ff 
  8004208c81:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
	temp = kvoffset;
  8004208c85:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  8004208c8c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
	readseg((uint64_t)((char *)kvbase + kvoffset), sec_name->sh_size,
  8004208c90:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004208c94:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208c98:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004208c9c:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004208ca0:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  8004208ca7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208cab:	48 01 c8             	add    %rcx,%rax
  8004208cae:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004208cb5:	48 89 c7             	mov    %rax,%rdi
  8004208cb8:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  8004208cbf:	00 00 00 
  8004208cc2:	ff d0                	callq  *%rax
		sec_name->sh_offset, &kvoffset);
	nametab = (char *)((char *)kvbase + temp) + OFFSET_CORRECT(sec_name->sh_offset);	
  8004208cc4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004208cc8:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208ccc:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004208cd0:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208cd4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8004208cd8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004208cdc:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  8004208ce2:	48 29 c2             	sub    %rax,%rdx
  8004208ce5:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004208ce9:	48 01 c2             	add    %rax,%rdx
  8004208cec:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208cf0:	48 01 d0             	add    %rdx,%rax
  8004208cf3:	48 89 45 90          	mov    %rax,-0x70(%rbp)

	for (i = 0; i < numSectionHeaders; i++)
  8004208cf7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  8004208cfe:	e9 04 05 00 00       	jmpq   8004209207 <read_section_headers+0x723>
	{
		name = (char *)(nametab + secthdr_ptr[i]->sh_name);
  8004208d03:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208d06:	48 98                	cltq   
  8004208d08:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208d0f:	ff 
  8004208d10:	8b 00                	mov    (%rax),%eax
  8004208d12:	89 c2                	mov    %eax,%edx
  8004208d14:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004208d18:	48 01 d0             	add    %rdx,%rax
  8004208d1b:	48 89 45 88          	mov    %rax,-0x78(%rbp)
		assert(kvoffset % SECTSIZE == 0);
  8004208d1f:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  8004208d26:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004208d2b:	48 85 c0             	test   %rax,%rax
  8004208d2e:	74 35                	je     8004208d65 <read_section_headers+0x281>
  8004208d30:	48 b9 46 a4 20 04 80 	movabs $0x800420a446,%rcx
  8004208d37:	00 00 00 
  8004208d3a:	48 ba 5f a4 20 04 80 	movabs $0x800420a45f,%rdx
  8004208d41:	00 00 00 
  8004208d44:	be 86 00 00 00       	mov    $0x86,%esi
  8004208d49:	48 bf 74 a4 20 04 80 	movabs $0x800420a474,%rdi
  8004208d50:	00 00 00 
  8004208d53:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208d58:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  8004208d5f:	00 00 00 
  8004208d62:	41 ff d0             	callq  *%r8
		temp = kvoffset;
  8004208d65:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  8004208d6c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
#ifdef DWARF_DEBUG
		cprintf("SectName: %s\n", name);
#endif
		if(!strcmp(name, ".debug_info"))
  8004208d70:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004208d74:	48 be 0b a4 20 04 80 	movabs $0x800420a40b,%rsi
  8004208d7b:	00 00 00 
  8004208d7e:	48 89 c7             	mov    %rax,%rdi
  8004208d81:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208d88:	00 00 00 
  8004208d8b:	ff d0                	callq  *%rax
  8004208d8d:	85 c0                	test   %eax,%eax
  8004208d8f:	0f 85 d8 00 00 00    	jne    8004208e6d <read_section_headers+0x389>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  8004208d95:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208d98:	48 98                	cltq   
  8004208d9a:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208da1:	ff 
#ifdef DWARF_DEBUG
		cprintf("SectName: %s\n", name);
#endif
		if(!strcmp(name, ".debug_info"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  8004208da2:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208da6:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208da9:	48 98                	cltq   
  8004208dab:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208db2:	ff 
  8004208db3:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004208db7:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  8004208dbe:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208dc2:	48 01 c8             	add    %rcx,%rax
  8004208dc5:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004208dcc:	48 89 c7             	mov    %rax,%rdi
  8004208dcf:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  8004208dd6:	00 00 00 
  8004208dd9:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_INFO].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  8004208ddb:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208dde:	48 98                	cltq   
  8004208de0:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208de7:	ff 
  8004208de8:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208dec:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208def:	48 98                	cltq   
  8004208df1:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208df8:	ff 
  8004208df9:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208dfd:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  8004208e01:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004208e05:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  8004208e0b:	48 29 c2             	sub    %rax,%rdx
  8004208e0e:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004208e12:	48 01 c2             	add    %rax,%rdx
  8004208e15:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208e19:	48 01 c2             	add    %rax,%rdx
  8004208e1c:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208e23:	00 00 00 
  8004208e26:	48 89 50 08          	mov    %rdx,0x8(%rax)
			section_info[DEBUG_INFO].ds_addr = (uintptr_t)section_info[DEBUG_INFO].ds_data;
  8004208e2a:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208e31:	00 00 00 
  8004208e34:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004208e38:	48 89 c2             	mov    %rax,%rdx
  8004208e3b:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208e42:	00 00 00 
  8004208e45:	48 89 50 10          	mov    %rdx,0x10(%rax)
			section_info[DEBUG_INFO].ds_size = secthdr_ptr[i]->sh_size;
  8004208e49:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208e4c:	48 98                	cltq   
  8004208e4e:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208e55:	ff 
  8004208e56:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208e5a:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208e61:	00 00 00 
  8004208e64:	48 89 50 18          	mov    %rdx,0x18(%rax)
  8004208e68:	e9 96 03 00 00       	jmpq   8004209203 <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_abbrev"))
  8004208e6d:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004208e71:	48 be 17 a4 20 04 80 	movabs $0x800420a417,%rsi
  8004208e78:	00 00 00 
  8004208e7b:	48 89 c7             	mov    %rax,%rdi
  8004208e7e:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208e85:	00 00 00 
  8004208e88:	ff d0                	callq  *%rax
  8004208e8a:	85 c0                	test   %eax,%eax
  8004208e8c:	0f 85 de 00 00 00    	jne    8004208f70 <read_section_headers+0x48c>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  8004208e92:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208e95:	48 98                	cltq   
  8004208e97:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208e9e:	ff 
			section_info[DEBUG_INFO].ds_addr = (uintptr_t)section_info[DEBUG_INFO].ds_data;
			section_info[DEBUG_INFO].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_abbrev"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  8004208e9f:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208ea3:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208ea6:	48 98                	cltq   
  8004208ea8:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208eaf:	ff 
  8004208eb0:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004208eb4:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  8004208ebb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208ebf:	48 01 c8             	add    %rcx,%rax
  8004208ec2:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004208ec9:	48 89 c7             	mov    %rax,%rdi
  8004208ecc:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  8004208ed3:	00 00 00 
  8004208ed6:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_ABBREV].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  8004208ed8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208edb:	48 98                	cltq   
  8004208edd:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208ee4:	ff 
  8004208ee5:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208ee9:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208eec:	48 98                	cltq   
  8004208eee:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208ef5:	ff 
  8004208ef6:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208efa:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  8004208f01:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004208f08:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  8004208f0e:	48 29 c2             	sub    %rax,%rdx
  8004208f11:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004208f15:	48 01 c2             	add    %rax,%rdx
  8004208f18:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208f1c:	48 01 c2             	add    %rax,%rdx
  8004208f1f:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208f26:	00 00 00 
  8004208f29:	48 89 50 28          	mov    %rdx,0x28(%rax)
			section_info[DEBUG_ABBREV].ds_addr = (uintptr_t)section_info[DEBUG_ABBREV].ds_data;
  8004208f2d:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208f34:	00 00 00 
  8004208f37:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004208f3b:	48 89 c2             	mov    %rax,%rdx
  8004208f3e:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208f45:	00 00 00 
  8004208f48:	48 89 50 30          	mov    %rdx,0x30(%rax)
			section_info[DEBUG_ABBREV].ds_size = secthdr_ptr[i]->sh_size;
  8004208f4c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208f4f:	48 98                	cltq   
  8004208f51:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208f58:	ff 
  8004208f59:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004208f5d:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004208f64:	00 00 00 
  8004208f67:	48 89 50 38          	mov    %rdx,0x38(%rax)
  8004208f6b:	e9 93 02 00 00       	jmpq   8004209203 <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_line"))
  8004208f70:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004208f74:	48 be 2f a4 20 04 80 	movabs $0x800420a42f,%rsi
  8004208f7b:	00 00 00 
  8004208f7e:	48 89 c7             	mov    %rax,%rdi
  8004208f81:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004208f88:	00 00 00 
  8004208f8b:	ff d0                	callq  *%rax
  8004208f8d:	85 c0                	test   %eax,%eax
  8004208f8f:	0f 85 de 00 00 00    	jne    8004209073 <read_section_headers+0x58f>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  8004208f95:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208f98:	48 98                	cltq   
  8004208f9a:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208fa1:	ff 
			section_info[DEBUG_ABBREV].ds_addr = (uintptr_t)section_info[DEBUG_ABBREV].ds_data;
			section_info[DEBUG_ABBREV].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_line"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  8004208fa2:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208fa6:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208fa9:	48 98                	cltq   
  8004208fab:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208fb2:	ff 
  8004208fb3:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004208fb7:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  8004208fbe:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208fc2:	48 01 c8             	add    %rcx,%rax
  8004208fc5:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004208fcc:	48 89 c7             	mov    %rax,%rdi
  8004208fcf:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  8004208fd6:	00 00 00 
  8004208fd9:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_LINE].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  8004208fdb:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208fde:	48 98                	cltq   
  8004208fe0:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208fe7:	ff 
  8004208fe8:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004208fec:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208fef:	48 98                	cltq   
  8004208ff1:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004208ff8:	ff 
  8004208ff9:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208ffd:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  8004209004:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420900b:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  8004209011:	48 29 c2             	sub    %rax,%rdx
  8004209014:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004209018:	48 01 c2             	add    %rax,%rdx
  800420901b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420901f:	48 01 c2             	add    %rax,%rdx
  8004209022:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004209029:	00 00 00 
  800420902c:	48 89 50 68          	mov    %rdx,0x68(%rax)
			section_info[DEBUG_LINE].ds_addr = (uintptr_t)section_info[DEBUG_LINE].ds_data;
  8004209030:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004209037:	00 00 00 
  800420903a:	48 8b 40 68          	mov    0x68(%rax),%rax
  800420903e:	48 89 c2             	mov    %rax,%rdx
  8004209041:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004209048:	00 00 00 
  800420904b:	48 89 50 70          	mov    %rdx,0x70(%rax)
			section_info[DEBUG_LINE].ds_size = secthdr_ptr[i]->sh_size;
  800420904f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209052:	48 98                	cltq   
  8004209054:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420905b:	ff 
  800420905c:	48 8b 50 20          	mov    0x20(%rax),%rdx
  8004209060:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  8004209067:	00 00 00 
  800420906a:	48 89 50 78          	mov    %rdx,0x78(%rax)
  800420906e:	e9 90 01 00 00       	jmpq   8004209203 <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".eh_frame"))
  8004209073:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004209077:	48 be 25 a4 20 04 80 	movabs $0x800420a425,%rsi
  800420907e:	00 00 00 
  8004209081:	48 89 c7             	mov    %rax,%rdi
  8004209084:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  800420908b:	00 00 00 
  800420908e:	ff d0                	callq  *%rax
  8004209090:	85 c0                	test   %eax,%eax
  8004209092:	75 65                	jne    80042090f9 <read_section_headers+0x615>
		{
			section_info[DEBUG_FRAME].ds_data = (uint8_t *)secthdr_ptr[i]->sh_addr;
  8004209094:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209097:	48 98                	cltq   
  8004209099:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  80042090a0:	ff 
  80042090a1:	48 8b 40 10          	mov    0x10(%rax),%rax
  80042090a5:	48 89 c2             	mov    %rax,%rdx
  80042090a8:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042090af:	00 00 00 
  80042090b2:	48 89 50 48          	mov    %rdx,0x48(%rax)
			section_info[DEBUG_FRAME].ds_addr = (uintptr_t)section_info[DEBUG_FRAME].ds_data;
  80042090b6:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042090bd:	00 00 00 
  80042090c0:	48 8b 40 48          	mov    0x48(%rax),%rax
  80042090c4:	48 89 c2             	mov    %rax,%rdx
  80042090c7:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042090ce:	00 00 00 
  80042090d1:	48 89 50 50          	mov    %rdx,0x50(%rax)
			section_info[DEBUG_FRAME].ds_size = secthdr_ptr[i]->sh_size;
  80042090d5:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042090d8:	48 98                	cltq   
  80042090da:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  80042090e1:	ff 
  80042090e2:	48 8b 50 20          	mov    0x20(%rax),%rdx
  80042090e6:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042090ed:	00 00 00 
  80042090f0:	48 89 50 58          	mov    %rdx,0x58(%rax)
  80042090f4:	e9 0a 01 00 00       	jmpq   8004209203 <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_str"))
  80042090f9:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  80042090fd:	48 be 3b a4 20 04 80 	movabs $0x800420a43b,%rsi
  8004209104:	00 00 00 
  8004209107:	48 89 c7             	mov    %rax,%rdi
  800420910a:	48 b8 8d 2f 20 04 80 	movabs $0x8004202f8d,%rax
  8004209111:	00 00 00 
  8004209114:	ff d0                	callq  *%rax
  8004209116:	85 c0                	test   %eax,%eax
  8004209118:	0f 85 e5 00 00 00    	jne    8004209203 <read_section_headers+0x71f>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  800420911e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209121:	48 98                	cltq   
  8004209123:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420912a:	ff 
			section_info[DEBUG_FRAME].ds_addr = (uintptr_t)section_info[DEBUG_FRAME].ds_data;
			section_info[DEBUG_FRAME].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_str"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  800420912b:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420912f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209132:	48 98                	cltq   
  8004209134:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420913b:	ff 
  800420913c:	48 8b 70 20          	mov    0x20(%rax),%rsi
  8004209140:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  8004209147:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420914b:	48 01 c8             	add    %rcx,%rax
  800420914e:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  8004209155:	48 89 c7             	mov    %rax,%rdi
  8004209158:	48 b8 23 92 20 04 80 	movabs $0x8004209223,%rax
  800420915f:	00 00 00 
  8004209162:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_STR].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  8004209164:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209167:	48 98                	cltq   
  8004209169:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004209170:	ff 
  8004209171:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004209175:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209178:	48 98                	cltq   
  800420917a:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  8004209181:	ff 
  8004209182:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209186:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  800420918d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209194:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420919a:	48 29 c2             	sub    %rax,%rdx
  800420919d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042091a1:	48 01 c2             	add    %rax,%rdx
  80042091a4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042091a8:	48 01 c2             	add    %rax,%rdx
  80042091ab:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042091b2:	00 00 00 
  80042091b5:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
			section_info[DEBUG_STR].ds_addr = (uintptr_t)section_info[DEBUG_STR].ds_data;
  80042091bc:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042091c3:	00 00 00 
  80042091c6:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
  80042091cd:	48 89 c2             	mov    %rax,%rdx
  80042091d0:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042091d7:	00 00 00 
  80042091da:	48 89 90 90 00 00 00 	mov    %rdx,0x90(%rax)
			section_info[DEBUG_STR].ds_size = secthdr_ptr[i]->sh_size;
  80042091e1:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042091e4:	48 98                	cltq   
  80042091e6:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  80042091ed:	ff 
  80042091ee:	48 8b 50 20          	mov    0x20(%rax),%rdx
  80042091f2:	48 b8 00 c6 21 04 80 	movabs $0x800421c600,%rax
  80042091f9:	00 00 00 
  80042091fc:	48 89 90 98 00 00 00 	mov    %rdx,0x98(%rax)
	temp = kvoffset;
	readseg((uint64_t)((char *)kvbase + kvoffset), sec_name->sh_size,
		sec_name->sh_offset, &kvoffset);
	nametab = (char *)((char *)kvbase + temp) + OFFSET_CORRECT(sec_name->sh_offset);	

	for (i = 0; i < numSectionHeaders; i++)
  8004209203:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  8004209207:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420920a:	3b 45 c4             	cmp    -0x3c(%rbp),%eax
  800420920d:	0f 8c f0 fa ff ff    	jl     8004208d03 <read_section_headers+0x21f>
			section_info[DEBUG_STR].ds_addr = (uintptr_t)section_info[DEBUG_STR].ds_data;
			section_info[DEBUG_STR].ds_size = secthdr_ptr[i]->sh_size;
		}
	}
	
	return ((uintptr_t)kvbase + kvoffset);
  8004209213:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004209217:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  800420921e:	48 01 d0             	add    %rdx,%rax
}
  8004209221:	c9                   	leaveq 
  8004209222:	c3                   	retq   

0000008004209223 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint64_t pa, uint64_t count, uint64_t offset, uint64_t* kvoffset)
{
  8004209223:	55                   	push   %rbp
  8004209224:	48 89 e5             	mov    %rsp,%rbp
  8004209227:	48 83 ec 30          	sub    $0x30,%rsp
  800420922b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420922f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004209233:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004209237:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
	uint64_t end_pa;
	uint64_t orgoff = offset;
  800420923b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420923f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	end_pa = pa + count;
  8004209243:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004209247:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420924b:	48 01 d0             	add    %rdx,%rax
  800420924e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	assert(pa % SECTSIZE == 0);	
  8004209252:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209256:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420925b:	48 85 c0             	test   %rax,%rax
  800420925e:	74 35                	je     8004209295 <readseg+0x72>
  8004209260:	48 b9 82 a4 20 04 80 	movabs $0x800420a482,%rcx
  8004209267:	00 00 00 
  800420926a:	48 ba 5f a4 20 04 80 	movabs $0x800420a45f,%rdx
  8004209271:	00 00 00 
  8004209274:	be c0 00 00 00       	mov    $0xc0,%esi
  8004209279:	48 bf 74 a4 20 04 80 	movabs $0x800420a474,%rdi
  8004209280:	00 00 00 
  8004209283:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209288:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420928f:	00 00 00 
  8004209292:	41 ff d0             	callq  *%r8
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
  8004209295:	48 81 65 e8 00 fe ff 	andq   $0xfffffffffffffe00,-0x18(%rbp)
  800420929c:	ff 

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
  800420929d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042092a1:	48 c1 e8 09          	shr    $0x9,%rax
  80042092a5:	48 83 c0 01          	add    $0x1,%rax
  80042092a9:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
  80042092ad:	eb 3c                	jmp    80042092eb <readseg+0xc8>
		readsect((uint8_t*) pa, offset);
  80042092af:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042092b3:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80042092b7:	48 89 d6             	mov    %rdx,%rsi
  80042092ba:	48 89 c7             	mov    %rax,%rdi
  80042092bd:	48 b8 b3 93 20 04 80 	movabs $0x80042093b3,%rax
  80042092c4:	00 00 00 
  80042092c7:	ff d0                	callq  *%rax
		pa += SECTSIZE;
  80042092c9:	48 81 45 e8 00 02 00 	addq   $0x200,-0x18(%rbp)
  80042092d0:	00 
		*kvoffset += SECTSIZE;
  80042092d1:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042092d5:	48 8b 00             	mov    (%rax),%rax
  80042092d8:	48 8d 90 00 02 00 00 	lea    0x200(%rax),%rdx
  80042092df:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042092e3:	48 89 10             	mov    %rdx,(%rax)
		offset++;
  80042092e6:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
  80042092eb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042092ef:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  80042092f3:	72 ba                	jb     80042092af <readseg+0x8c>
		pa += SECTSIZE;
		*kvoffset += SECTSIZE;
		offset++;
	}

	if(((orgoff % SECTSIZE) + count) > SECTSIZE)
  80042092f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042092f9:	25 ff 01 00 00       	and    $0x1ff,%eax
  80042092fe:	48 89 c2             	mov    %rax,%rdx
  8004209301:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004209305:	48 01 d0             	add    %rdx,%rax
  8004209308:	48 3d 00 02 00 00    	cmp    $0x200,%rax
  800420930e:	76 2f                	jbe    800420933f <readseg+0x11c>
	{
		readsect((uint8_t*) pa, offset);
  8004209310:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209314:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004209318:	48 89 d6             	mov    %rdx,%rsi
  800420931b:	48 89 c7             	mov    %rax,%rdi
  800420931e:	48 b8 b3 93 20 04 80 	movabs $0x80042093b3,%rax
  8004209325:	00 00 00 
  8004209328:	ff d0                	callq  *%rax
		*kvoffset += SECTSIZE;
  800420932a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420932e:	48 8b 00             	mov    (%rax),%rax
  8004209331:	48 8d 90 00 02 00 00 	lea    0x200(%rax),%rdx
  8004209338:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420933c:	48 89 10             	mov    %rdx,(%rax)
	}
	assert(*kvoffset % SECTSIZE == 0);
  800420933f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004209343:	48 8b 00             	mov    (%rax),%rax
  8004209346:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420934b:	48 85 c0             	test   %rax,%rax
  800420934e:	74 35                	je     8004209385 <readseg+0x162>
  8004209350:	48 b9 95 a4 20 04 80 	movabs $0x800420a495,%rcx
  8004209357:	00 00 00 
  800420935a:	48 ba 5f a4 20 04 80 	movabs $0x800420a45f,%rdx
  8004209361:	00 00 00 
  8004209364:	be d6 00 00 00       	mov    $0xd6,%esi
  8004209369:	48 bf 74 a4 20 04 80 	movabs $0x800420a474,%rdi
  8004209370:	00 00 00 
  8004209373:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209378:	49 b8 98 01 20 04 80 	movabs $0x8004200198,%r8
  800420937f:	00 00 00 
  8004209382:	41 ff d0             	callq  *%r8
}
  8004209385:	c9                   	leaveq 
  8004209386:	c3                   	retq   

0000008004209387 <waitdisk>:

void
waitdisk(void)
{
  8004209387:	55                   	push   %rbp
  8004209388:	48 89 e5             	mov    %rsp,%rbp
  800420938b:	48 83 ec 10          	sub    $0x10,%rsp
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
  800420938f:	90                   	nop
  8004209390:	c7 45 fc f7 01 00 00 	movl   $0x1f7,-0x4(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004209397:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420939a:	89 c2                	mov    %eax,%edx
  800420939c:	ec                   	in     (%dx),%al
  800420939d:	88 45 fb             	mov    %al,-0x5(%rbp)
	return data;
  80042093a0:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80042093a4:	0f b6 c0             	movzbl %al,%eax
  80042093a7:	25 c0 00 00 00       	and    $0xc0,%eax
  80042093ac:	83 f8 40             	cmp    $0x40,%eax
  80042093af:	75 df                	jne    8004209390 <waitdisk+0x9>
		/* do nothing */;
}
  80042093b1:	c9                   	leaveq 
  80042093b2:	c3                   	retq   

00000080042093b3 <readsect>:

void
readsect(void *dst, uint64_t offset)
{
  80042093b3:	55                   	push   %rbp
  80042093b4:	48 89 e5             	mov    %rsp,%rbp
  80042093b7:	48 83 ec 60          	sub    $0x60,%rsp
  80042093bb:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80042093bf:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
	// wait for disk to be ready
	waitdisk();
  80042093c3:	48 b8 87 93 20 04 80 	movabs $0x8004209387,%rax
  80042093ca:	00 00 00 
  80042093cd:	ff d0                	callq  *%rax
  80042093cf:	c7 45 fc f2 01 00 00 	movl   $0x1f2,-0x4(%rbp)
  80042093d6:	c6 45 fb 01          	movb   $0x1,-0x5(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042093da:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80042093de:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042093e1:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
  80042093e2:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042093e6:	0f b6 c0             	movzbl %al,%eax
  80042093e9:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%rbp)
  80042093f0:	88 45 f3             	mov    %al,-0xd(%rbp)
  80042093f3:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
  80042093f7:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80042093fa:	ee                   	out    %al,(%dx)
	outb(0x1F4, offset >> 8);
  80042093fb:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042093ff:	48 c1 e8 08          	shr    $0x8,%rax
  8004209403:	0f b6 c0             	movzbl %al,%eax
  8004209406:	c7 45 ec f4 01 00 00 	movl   $0x1f4,-0x14(%rbp)
  800420940d:	88 45 eb             	mov    %al,-0x15(%rbp)
  8004209410:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  8004209414:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8004209417:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
  8004209418:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420941c:	48 c1 e8 10          	shr    $0x10,%rax
  8004209420:	0f b6 c0             	movzbl %al,%eax
  8004209423:	c7 45 e4 f5 01 00 00 	movl   $0x1f5,-0x1c(%rbp)
  800420942a:	88 45 e3             	mov    %al,-0x1d(%rbp)
  800420942d:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  8004209431:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004209434:	ee                   	out    %al,(%dx)
	outb(0x1F6, (offset >> 24) | 0xE0);
  8004209435:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004209439:	48 c1 e8 18          	shr    $0x18,%rax
  800420943d:	83 c8 e0             	or     $0xffffffe0,%eax
  8004209440:	0f b6 c0             	movzbl %al,%eax
  8004209443:	c7 45 dc f6 01 00 00 	movl   $0x1f6,-0x24(%rbp)
  800420944a:	88 45 db             	mov    %al,-0x25(%rbp)
  800420944d:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  8004209451:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8004209454:	ee                   	out    %al,(%dx)
  8004209455:	c7 45 d4 f7 01 00 00 	movl   $0x1f7,-0x2c(%rbp)
  800420945c:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
  8004209460:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  8004209464:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  8004209467:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
  8004209468:	48 b8 87 93 20 04 80 	movabs $0x8004209387,%rax
  800420946f:	00 00 00 
  8004209472:	ff d0                	callq  *%rax
  8004209474:	c7 45 cc f0 01 00 00 	movl   $0x1f0,-0x34(%rbp)
  800420947b:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420947f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004209483:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%rbp)
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800420948a:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420948d:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  8004209491:	8b 45 bc             	mov    -0x44(%rbp),%eax
  8004209494:	48 89 ce             	mov    %rcx,%rsi
  8004209497:	48 89 f7             	mov    %rsi,%rdi
  800420949a:	89 c1                	mov    %eax,%ecx
  800420949c:	fc                   	cld    
  800420949d:	f2 6d                	repnz insl (%dx),%es:(%rdi)
  800420949f:	89 c8                	mov    %ecx,%eax
  80042094a1:	48 89 fe             	mov    %rdi,%rsi
  80042094a4:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  80042094a8:	89 45 bc             	mov    %eax,-0x44(%rbp)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
  80042094ab:	c9                   	leaveq 
  80042094ac:	c3                   	retq   
