
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
  800420000c:	48 b8 38 20 22 04 80 	movabs $0x8004222038,%rax
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
  800420003d:	48 b8 00 20 22 04 80 	movabs $0x8004222000,%rax
  8004200044:	00 00 00 
	movq  %rax,%rsp
  8004200047:	48 89 c4             	mov    %rax,%rsp

	# now to C code
    movabs $i386_init, %rax
  800420004a:	48 b8 58 00 20 04 80 	movabs $0x8004200058,%rax
  8004200051:	00 00 00 
	call *%rax
  8004200054:	ff d0                	callq  *%rax

0000008004200056 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
  8004200056:	eb fe                	jmp    8004200056 <spin>

0000008004200058 <i386_init>:



void
i386_init(void)
{
  8004200058:	55                   	push   %rbp
  8004200059:	48 89 e5             	mov    %rsp,%rbp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
  800420005c:	48 ba 80 3d 22 04 80 	movabs $0x8004223d80,%rdx
  8004200063:	00 00 00 
  8004200066:	48 b8 a0 26 22 04 80 	movabs $0x80042226a0,%rax
  800420006d:	00 00 00 
  8004200070:	48 29 c2             	sub    %rax,%rdx
  8004200073:	48 89 d0             	mov    %rdx,%rax
  8004200076:	48 89 c2             	mov    %rax,%rdx
  8004200079:	be 00 00 00 00       	mov    $0x0,%esi
  800420007e:	48 bf a0 26 22 04 80 	movabs $0x80042226a0,%rdi
  8004200085:	00 00 00 
  8004200088:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420008f:	00 00 00 
  8004200092:	ff d0                	callq  *%rax

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
  8004200094:	48 b8 76 0d 20 04 80 	movabs $0x8004200d76,%rax
  800420009b:	00 00 00 
  800420009e:	ff d0                	callq  *%rax

	cprintf("6828 decimal is %o octal!\n", 6828);
  80042000a0:	be ac 1a 00 00       	mov    $0x1aac,%esi
  80042000a5:	48 bf a0 e3 20 04 80 	movabs $0x800420e3a0,%rdi
  80042000ac:	00 00 00 
  80042000af:	b8 00 00 00 00       	mov    $0x0,%eax
  80042000b4:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  80042000bb:	00 00 00 
  80042000be:	ff d2                	callq  *%rdx

	extern char end[];
	end_debug = read_section_headers((0x10000+KERNBASE), (uintptr_t)end);
  80042000c0:	48 b8 80 3d 22 04 80 	movabs $0x8004223d80,%rax
  80042000c7:	00 00 00 
  80042000ca:	48 89 c6             	mov    %rax,%rsi
  80042000cd:	48 bf 00 00 01 04 80 	movabs $0x8004010000,%rdi
  80042000d4:	00 00 00 
  80042000d7:	48 b8 c0 d9 20 04 80 	movabs $0x800420d9c0,%rax
  80042000de:	00 00 00 
  80042000e1:	ff d0                	callq  *%rax
  80042000e3:	48 ba 68 2d 22 04 80 	movabs $0x8004222d68,%rdx
  80042000ea:	00 00 00 
  80042000ed:	48 89 02             	mov    %rax,(%rdx)

	// Lab 2 memory management initialization functions
	x64_vm_init();
  80042000f0:	b8 00 00 00 00       	mov    $0x0,%eax
  80042000f5:	48 ba 94 1f 20 04 80 	movabs $0x8004201f94,%rdx
  80042000fc:	00 00 00 
  80042000ff:	ff d2                	callq  *%rdx



	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
  8004200101:	bf 00 00 00 00       	mov    $0x0,%edi
  8004200106:	48 b8 ef 13 20 04 80 	movabs $0x80042013ef,%rax
  800420010d:	00 00 00 
  8004200110:	ff d0                	callq  *%rax
  8004200112:	eb ed                	jmp    8004200101 <i386_init+0xa9>

0000008004200114 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8004200114:	55                   	push   %rbp
  8004200115:	48 89 e5             	mov    %rsp,%rbp
  8004200118:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  800420011f:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  8004200126:	89 b5 24 ff ff ff    	mov    %esi,-0xdc(%rbp)
  800420012c:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004200133:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800420013a:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004200141:	84 c0                	test   %al,%al
  8004200143:	74 20                	je     8004200165 <_panic+0x51>
  8004200145:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004200149:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800420014d:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004200151:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004200155:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004200159:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800420015d:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004200161:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004200165:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	if (panicstr)
  800420016c:	48 b8 70 2d 22 04 80 	movabs $0x8004222d70,%rax
  8004200173:	00 00 00 
  8004200176:	48 8b 00             	mov    (%rax),%rax
  8004200179:	48 85 c0             	test   %rax,%rax
  800420017c:	74 05                	je     8004200183 <_panic+0x6f>
		goto dead;
  800420017e:	e9 a9 00 00 00       	jmpq   800420022c <_panic+0x118>
	panicstr = fmt;
  8004200183:	48 b8 70 2d 22 04 80 	movabs $0x8004222d70,%rax
  800420018a:	00 00 00 
  800420018d:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  8004200194:	48 89 10             	mov    %rdx,(%rax)

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
  8004200197:	fa                   	cli    
  8004200198:	fc                   	cld    

	va_start(ap, fmt);
  8004200199:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  80042001a0:	00 00 00 
  80042001a3:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80042001aa:	00 00 00 
  80042001ad:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80042001b1:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80042001b8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80042001bf:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	cprintf("kernel panic at %s:%d: ", file, line);
  80042001c6:	8b 95 24 ff ff ff    	mov    -0xdc(%rbp),%edx
  80042001cc:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80042001d3:	48 89 c6             	mov    %rax,%rsi
  80042001d6:	48 bf bb e3 20 04 80 	movabs $0x800420e3bb,%rdi
  80042001dd:	00 00 00 
  80042001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  80042001e5:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  80042001ec:	00 00 00 
  80042001ef:	ff d1                	callq  *%rcx
	vcprintf(fmt, ap);
  80042001f1:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  80042001f8:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  80042001ff:	48 89 d6             	mov    %rdx,%rsi
  8004200202:	48 89 c7             	mov    %rax,%rdi
  8004200205:	48 b8 f1 63 20 04 80 	movabs $0x80042063f1,%rax
  800420020c:	00 00 00 
  800420020f:	ff d0                	callq  *%rax
	cprintf("\n");
  8004200211:	48 bf d3 e3 20 04 80 	movabs $0x800420e3d3,%rdi
  8004200218:	00 00 00 
  800420021b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200220:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200227:	00 00 00 
  800420022a:	ff d2                	callq  *%rdx
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
  800420022c:	bf 00 00 00 00       	mov    $0x0,%edi
  8004200231:	48 b8 ef 13 20 04 80 	movabs $0x80042013ef,%rax
  8004200238:	00 00 00 
  800420023b:	ff d0                	callq  *%rax
  800420023d:	eb ed                	jmp    800420022c <_panic+0x118>

000000800420023f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
  800420023f:	55                   	push   %rbp
  8004200240:	48 89 e5             	mov    %rsp,%rbp
  8004200243:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  800420024a:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  8004200251:	89 b5 24 ff ff ff    	mov    %esi,-0xdc(%rbp)
  8004200257:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800420025e:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004200265:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800420026c:	84 c0                	test   %al,%al
  800420026e:	74 20                	je     8004200290 <_warn+0x51>
  8004200270:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004200274:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004200278:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800420027c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004200280:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004200284:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004200288:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800420028c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004200290:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  8004200297:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800420029e:	00 00 00 
  80042002a1:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80042002a8:	00 00 00 
  80042002ab:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80042002af:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80042002b6:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80042002bd:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	cprintf("kernel warning at %s:%d: ", file, line);
  80042002c4:	8b 95 24 ff ff ff    	mov    -0xdc(%rbp),%edx
  80042002ca:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  80042002d1:	48 89 c6             	mov    %rax,%rsi
  80042002d4:	48 bf d5 e3 20 04 80 	movabs $0x800420e3d5,%rdi
  80042002db:	00 00 00 
  80042002de:	b8 00 00 00 00       	mov    $0x0,%eax
  80042002e3:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  80042002ea:	00 00 00 
  80042002ed:	ff d1                	callq  *%rcx
	vcprintf(fmt, ap);
  80042002ef:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  80042002f6:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  80042002fd:	48 89 d6             	mov    %rdx,%rsi
  8004200300:	48 89 c7             	mov    %rax,%rdi
  8004200303:	48 b8 f1 63 20 04 80 	movabs $0x80042063f1,%rax
  800420030a:	00 00 00 
  800420030d:	ff d0                	callq  *%rax
	cprintf("\n");
  800420030f:	48 bf d3 e3 20 04 80 	movabs $0x800420e3d3,%rdi
  8004200316:	00 00 00 
  8004200319:	b8 00 00 00 00       	mov    $0x0,%eax
  800420031e:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200325:	00 00 00 
  8004200328:	ff d2                	callq  *%rdx
	va_end(ap);
}
  800420032a:	c9                   	leaveq 
  800420032b:	c3                   	retq   

000000800420032c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
  800420032c:	55                   	push   %rbp
  800420032d:	48 89 e5             	mov    %rsp,%rbp
  8004200330:	48 83 ec 20          	sub    $0x20,%rsp
  8004200334:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800420033b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420033e:	89 c2                	mov    %eax,%edx
  8004200340:	ec                   	in     (%dx),%al
  8004200341:	88 45 fb             	mov    %al,-0x5(%rbp)
  8004200344:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%rbp)
  800420034b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420034e:	89 c2                	mov    %eax,%edx
  8004200350:	ec                   	in     (%dx),%al
  8004200351:	88 45 f3             	mov    %al,-0xd(%rbp)
  8004200354:	c7 45 ec 84 00 00 00 	movl   $0x84,-0x14(%rbp)
  800420035b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420035e:	89 c2                	mov    %eax,%edx
  8004200360:	ec                   	in     (%dx),%al
  8004200361:	88 45 eb             	mov    %al,-0x15(%rbp)
  8004200364:	c7 45 e4 84 00 00 00 	movl   $0x84,-0x1c(%rbp)
  800420036b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420036e:	89 c2                	mov    %eax,%edx
  8004200370:	ec                   	in     (%dx),%al
  8004200371:	88 45 e3             	mov    %al,-0x1d(%rbp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
  8004200374:	c9                   	leaveq 
  8004200375:	c3                   	retq   

0000008004200376 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
  8004200376:	55                   	push   %rbp
  8004200377:	48 89 e5             	mov    %rsp,%rbp
  800420037a:	48 83 ec 10          	sub    $0x10,%rsp
  800420037e:	c7 45 fc fd 03 00 00 	movl   $0x3fd,-0x4(%rbp)
  8004200385:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200388:	89 c2                	mov    %eax,%edx
  800420038a:	ec                   	in     (%dx),%al
  800420038b:	88 45 fb             	mov    %al,-0x5(%rbp)
	return data;
  800420038e:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
  8004200392:	0f b6 c0             	movzbl %al,%eax
  8004200395:	83 e0 01             	and    $0x1,%eax
  8004200398:	85 c0                	test   %eax,%eax
  800420039a:	75 07                	jne    80042003a3 <serial_proc_data+0x2d>
		return -1;
  800420039c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80042003a1:	eb 17                	jmp    80042003ba <serial_proc_data+0x44>
  80042003a3:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042003aa:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042003ad:	89 c2                	mov    %eax,%edx
  80042003af:	ec                   	in     (%dx),%al
  80042003b0:	88 45 f3             	mov    %al,-0xd(%rbp)
	return data;
  80042003b3:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
	return inb(COM1+COM_RX);
  80042003b7:	0f b6 c0             	movzbl %al,%eax
}
  80042003ba:	c9                   	leaveq 
  80042003bb:	c3                   	retq   

00000080042003bc <serial_intr>:

void
serial_intr(void)
{
  80042003bc:	55                   	push   %rbp
  80042003bd:	48 89 e5             	mov    %rsp,%rbp
	if (serial_exists)
  80042003c0:	48 b8 a0 26 22 04 80 	movabs $0x80042226a0,%rax
  80042003c7:	00 00 00 
  80042003ca:	0f b6 00             	movzbl (%rax),%eax
  80042003cd:	84 c0                	test   %al,%al
  80042003cf:	74 16                	je     80042003e7 <serial_intr+0x2b>
		cons_intr(serial_proc_data);
  80042003d1:	48 bf 76 03 20 04 80 	movabs $0x8004200376,%rdi
  80042003d8:	00 00 00 
  80042003db:	48 b8 f9 0b 20 04 80 	movabs $0x8004200bf9,%rax
  80042003e2:	00 00 00 
  80042003e5:	ff d0                	callq  *%rax
}
  80042003e7:	5d                   	pop    %rbp
  80042003e8:	c3                   	retq   

00000080042003e9 <serial_putc>:

static void
serial_putc(int c)
{
  80042003e9:	55                   	push   %rbp
  80042003ea:	48 89 e5             	mov    %rsp,%rbp
  80042003ed:	48 83 ec 28          	sub    $0x28,%rsp
  80042003f1:	89 7d dc             	mov    %edi,-0x24(%rbp)
	int i;

	for (i = 0;
  80042003f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  80042003fb:	eb 10                	jmp    800420040d <serial_putc+0x24>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
  80042003fd:	48 b8 2c 03 20 04 80 	movabs $0x800420032c,%rax
  8004200404:	00 00 00 
  8004200407:	ff d0                	callq  *%rax
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
  8004200409:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  800420040d:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200414:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004200417:	89 c2                	mov    %eax,%edx
  8004200419:	ec                   	in     (%dx),%al
  800420041a:	88 45 f7             	mov    %al,-0x9(%rbp)
	return data;
  800420041d:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  8004200421:	0f b6 c0             	movzbl %al,%eax
  8004200424:	83 e0 20             	and    $0x20,%eax
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
  8004200427:	85 c0                	test   %eax,%eax
  8004200429:	75 09                	jne    8004200434 <serial_putc+0x4b>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
  800420042b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%rbp)
  8004200432:	7e c9                	jle    80042003fd <serial_putc+0x14>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
  8004200434:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004200437:	0f b6 c0             	movzbl %al,%eax
  800420043a:	c7 45 f0 f8 03 00 00 	movl   $0x3f8,-0x10(%rbp)
  8004200441:	88 45 ef             	mov    %al,-0x11(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004200444:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  8004200448:	8b 55 f0             	mov    -0x10(%rbp),%edx
  800420044b:	ee                   	out    %al,(%dx)
}
  800420044c:	c9                   	leaveq 
  800420044d:	c3                   	retq   

000000800420044e <serial_init>:

static void
serial_init(void)
{
  800420044e:	55                   	push   %rbp
  800420044f:	48 89 e5             	mov    %rsp,%rbp
  8004200452:	48 83 ec 50          	sub    $0x50,%rsp
  8004200456:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%rbp)
  800420045d:	c6 45 fb 00          	movb   $0x0,-0x5(%rbp)
  8004200461:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200465:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004200468:	ee                   	out    %al,(%dx)
  8004200469:	c7 45 f4 fb 03 00 00 	movl   $0x3fb,-0xc(%rbp)
  8004200470:	c6 45 f3 80          	movb   $0x80,-0xd(%rbp)
  8004200474:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
  8004200478:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420047b:	ee                   	out    %al,(%dx)
  800420047c:	c7 45 ec f8 03 00 00 	movl   $0x3f8,-0x14(%rbp)
  8004200483:	c6 45 eb 0c          	movb   $0xc,-0x15(%rbp)
  8004200487:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  800420048b:	8b 55 ec             	mov    -0x14(%rbp),%edx
  800420048e:	ee                   	out    %al,(%dx)
  800420048f:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%rbp)
  8004200496:	c6 45 e3 00          	movb   $0x0,-0x1d(%rbp)
  800420049a:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  800420049e:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  80042004a1:	ee                   	out    %al,(%dx)
  80042004a2:	c7 45 dc fb 03 00 00 	movl   $0x3fb,-0x24(%rbp)
  80042004a9:	c6 45 db 03          	movb   $0x3,-0x25(%rbp)
  80042004ad:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  80042004b1:	8b 55 dc             	mov    -0x24(%rbp),%edx
  80042004b4:	ee                   	out    %al,(%dx)
  80042004b5:	c7 45 d4 fc 03 00 00 	movl   $0x3fc,-0x2c(%rbp)
  80042004bc:	c6 45 d3 00          	movb   $0x0,-0x2d(%rbp)
  80042004c0:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  80042004c4:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  80042004c7:	ee                   	out    %al,(%dx)
  80042004c8:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%rbp)
  80042004cf:	c6 45 cb 01          	movb   $0x1,-0x35(%rbp)
  80042004d3:	0f b6 45 cb          	movzbl -0x35(%rbp),%eax
  80042004d7:	8b 55 cc             	mov    -0x34(%rbp),%edx
  80042004da:	ee                   	out    %al,(%dx)
  80042004db:	c7 45 c4 fd 03 00 00 	movl   $0x3fd,-0x3c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042004e2:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  80042004e5:	89 c2                	mov    %eax,%edx
  80042004e7:	ec                   	in     (%dx),%al
  80042004e8:	88 45 c3             	mov    %al,-0x3d(%rbp)
	return data;
  80042004eb:	0f b6 45 c3          	movzbl -0x3d(%rbp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
  80042004ef:	3c ff                	cmp    $0xff,%al
  80042004f1:	0f 95 c2             	setne  %dl
  80042004f4:	48 b8 a0 26 22 04 80 	movabs $0x80042226a0,%rax
  80042004fb:	00 00 00 
  80042004fe:	88 10                	mov    %dl,(%rax)
  8004200500:	c7 45 bc fa 03 00 00 	movl   $0x3fa,-0x44(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200507:	8b 45 bc             	mov    -0x44(%rbp),%eax
  800420050a:	89 c2                	mov    %eax,%edx
  800420050c:	ec                   	in     (%dx),%al
  800420050d:	88 45 bb             	mov    %al,-0x45(%rbp)
  8004200510:	c7 45 b4 f8 03 00 00 	movl   $0x3f8,-0x4c(%rbp)
  8004200517:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  800420051a:	89 c2                	mov    %eax,%edx
  800420051c:	ec                   	in     (%dx),%al
  800420051d:	88 45 b3             	mov    %al,-0x4d(%rbp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
  8004200520:	c9                   	leaveq 
  8004200521:	c3                   	retq   

0000008004200522 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
  8004200522:	55                   	push   %rbp
  8004200523:	48 89 e5             	mov    %rsp,%rbp
  8004200526:	48 83 ec 38          	sub    $0x38,%rsp
  800420052a:	89 7d cc             	mov    %edi,-0x34(%rbp)
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  800420052d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004200534:	eb 10                	jmp    8004200546 <lpt_putc+0x24>
		delay();
  8004200536:	48 b8 2c 03 20 04 80 	movabs $0x800420032c,%rax
  800420053d:	00 00 00 
  8004200540:	ff d0                	callq  *%rax
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
  8004200542:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8004200546:	c7 45 f8 79 03 00 00 	movl   $0x379,-0x8(%rbp)
  800420054d:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004200550:	89 c2                	mov    %eax,%edx
  8004200552:	ec                   	in     (%dx),%al
  8004200553:	88 45 f7             	mov    %al,-0x9(%rbp)
	return data;
  8004200556:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
  800420055a:	84 c0                	test   %al,%al
  800420055c:	78 09                	js     8004200567 <lpt_putc+0x45>
  800420055e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%rbp)
  8004200565:	7e cf                	jle    8004200536 <lpt_putc+0x14>
		delay();
	outb(0x378+0, c);
  8004200567:	8b 45 cc             	mov    -0x34(%rbp),%eax
  800420056a:	0f b6 c0             	movzbl %al,%eax
  800420056d:	c7 45 f0 78 03 00 00 	movl   $0x378,-0x10(%rbp)
  8004200574:	88 45 ef             	mov    %al,-0x11(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004200577:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  800420057b:	8b 55 f0             	mov    -0x10(%rbp),%edx
  800420057e:	ee                   	out    %al,(%dx)
  800420057f:	c7 45 e8 7a 03 00 00 	movl   $0x37a,-0x18(%rbp)
  8004200586:	c6 45 e7 0d          	movb   $0xd,-0x19(%rbp)
  800420058a:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  800420058e:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8004200591:	ee                   	out    %al,(%dx)
  8004200592:	c7 45 e0 7a 03 00 00 	movl   $0x37a,-0x20(%rbp)
  8004200599:	c6 45 df 08          	movb   $0x8,-0x21(%rbp)
  800420059d:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  80042005a1:	8b 55 e0             	mov    -0x20(%rbp),%edx
  80042005a4:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
  80042005a5:	c9                   	leaveq 
  80042005a6:	c3                   	retq   

00000080042005a7 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
  80042005a7:	55                   	push   %rbp
  80042005a8:	48 89 e5             	mov    %rsp,%rbp
  80042005ab:	48 83 ec 30          	sub    $0x30,%rsp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
  80042005af:	48 b8 00 80 0b 04 80 	movabs $0x80040b8000,%rax
  80042005b6:	00 00 00 
  80042005b9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	was = *cp;
  80042005bd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042005c1:	0f b7 00             	movzwl (%rax),%eax
  80042005c4:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
	*cp = (uint16_t) 0xA55A;
  80042005c8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042005cc:	66 c7 00 5a a5       	movw   $0xa55a,(%rax)
	if (*cp != 0xA55A) {
  80042005d1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042005d5:	0f b7 00             	movzwl (%rax),%eax
  80042005d8:	66 3d 5a a5          	cmp    $0xa55a,%ax
  80042005dc:	74 20                	je     80042005fe <cga_init+0x57>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
  80042005de:	48 b8 00 00 0b 04 80 	movabs $0x80040b0000,%rax
  80042005e5:	00 00 00 
  80042005e8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		addr_6845 = MONO_BASE;
  80042005ec:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  80042005f3:	00 00 00 
  80042005f6:	c7 00 b4 03 00 00    	movl   $0x3b4,(%rax)
  80042005fc:	eb 1b                	jmp    8004200619 <cga_init+0x72>
	} else {
		*cp = was;
  80042005fe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004200602:	0f b7 55 f6          	movzwl -0xa(%rbp),%edx
  8004200606:	66 89 10             	mov    %dx,(%rax)
		addr_6845 = CGA_BASE;
  8004200609:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  8004200610:	00 00 00 
  8004200613:	c7 00 d4 03 00 00    	movl   $0x3d4,(%rax)
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
  8004200619:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  8004200620:	00 00 00 
  8004200623:	8b 00                	mov    (%rax),%eax
  8004200625:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8004200628:	c6 45 eb 0e          	movb   $0xe,-0x15(%rbp)
  800420062c:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  8004200630:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8004200633:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
  8004200634:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  800420063b:	00 00 00 
  800420063e:	8b 00                	mov    (%rax),%eax
  8004200640:	83 c0 01             	add    $0x1,%eax
  8004200643:	89 45 e4             	mov    %eax,-0x1c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200646:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004200649:	89 c2                	mov    %eax,%edx
  800420064b:	ec                   	in     (%dx),%al
  800420064c:	88 45 e3             	mov    %al,-0x1d(%rbp)
	return data;
  800420064f:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  8004200653:	0f b6 c0             	movzbl %al,%eax
  8004200656:	c1 e0 08             	shl    $0x8,%eax
  8004200659:	89 45 f0             	mov    %eax,-0x10(%rbp)
	outb(addr_6845, 15);
  800420065c:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  8004200663:	00 00 00 
  8004200666:	8b 00                	mov    (%rax),%eax
  8004200668:	89 45 dc             	mov    %eax,-0x24(%rbp)
  800420066b:	c6 45 db 0f          	movb   $0xf,-0x25(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800420066f:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  8004200673:	8b 55 dc             	mov    -0x24(%rbp),%edx
  8004200676:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
  8004200677:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  800420067e:	00 00 00 
  8004200681:	8b 00                	mov    (%rax),%eax
  8004200683:	83 c0 01             	add    $0x1,%eax
  8004200686:	89 45 d4             	mov    %eax,-0x2c(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004200689:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  800420068c:	89 c2                	mov    %eax,%edx
  800420068e:	ec                   	in     (%dx),%al
  800420068f:	88 45 d3             	mov    %al,-0x2d(%rbp)
	return data;
  8004200692:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  8004200696:	0f b6 c0             	movzbl %al,%eax
  8004200699:	09 45 f0             	or     %eax,-0x10(%rbp)

	crt_buf = (uint16_t*) cp;
  800420069c:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  80042006a3:	00 00 00 
  80042006a6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042006aa:	48 89 10             	mov    %rdx,(%rax)
	crt_pos = pos;
  80042006ad:	8b 45 f0             	mov    -0x10(%rbp),%eax
  80042006b0:	89 c2                	mov    %eax,%edx
  80042006b2:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  80042006b9:	00 00 00 
  80042006bc:	66 89 10             	mov    %dx,(%rax)
}
  80042006bf:	c9                   	leaveq 
  80042006c0:	c3                   	retq   

00000080042006c1 <cga_putc>:



static void
cga_putc(int c)
{
  80042006c1:	55                   	push   %rbp
  80042006c2:	48 89 e5             	mov    %rsp,%rbp
  80042006c5:	48 83 ec 40          	sub    $0x40,%rsp
  80042006c9:	89 7d cc             	mov    %edi,-0x34(%rbp)
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
  80042006cc:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042006cf:	b0 00                	mov    $0x0,%al
  80042006d1:	85 c0                	test   %eax,%eax
  80042006d3:	75 07                	jne    80042006dc <cga_putc+0x1b>
		c |= 0x0700;
  80042006d5:	81 4d cc 00 07 00 00 	orl    $0x700,-0x34(%rbp)

	switch (c & 0xff) {
  80042006dc:	8b 45 cc             	mov    -0x34(%rbp),%eax
  80042006df:	0f b6 c0             	movzbl %al,%eax
  80042006e2:	83 f8 09             	cmp    $0x9,%eax
  80042006e5:	0f 84 f6 00 00 00    	je     80042007e1 <cga_putc+0x120>
  80042006eb:	83 f8 09             	cmp    $0x9,%eax
  80042006ee:	7f 0a                	jg     80042006fa <cga_putc+0x39>
  80042006f0:	83 f8 08             	cmp    $0x8,%eax
  80042006f3:	74 18                	je     800420070d <cga_putc+0x4c>
  80042006f5:	e9 3e 01 00 00       	jmpq   8004200838 <cga_putc+0x177>
  80042006fa:	83 f8 0a             	cmp    $0xa,%eax
  80042006fd:	74 75                	je     8004200774 <cga_putc+0xb3>
  80042006ff:	83 f8 0d             	cmp    $0xd,%eax
  8004200702:	0f 84 89 00 00 00    	je     8004200791 <cga_putc+0xd0>
  8004200708:	e9 2b 01 00 00       	jmpq   8004200838 <cga_putc+0x177>
	case '\b':
		if (crt_pos > 0) {
  800420070d:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200714:	00 00 00 
  8004200717:	0f b7 00             	movzwl (%rax),%eax
  800420071a:	66 85 c0             	test   %ax,%ax
  800420071d:	74 50                	je     800420076f <cga_putc+0xae>
			crt_pos--;
  800420071f:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200726:	00 00 00 
  8004200729:	0f b7 00             	movzwl (%rax),%eax
  800420072c:	8d 50 ff             	lea    -0x1(%rax),%edx
  800420072f:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200736:	00 00 00 
  8004200739:	66 89 10             	mov    %dx,(%rax)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
  800420073c:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  8004200743:	00 00 00 
  8004200746:	48 8b 10             	mov    (%rax),%rdx
  8004200749:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200750:	00 00 00 
  8004200753:	0f b7 00             	movzwl (%rax),%eax
  8004200756:	0f b7 c0             	movzwl %ax,%eax
  8004200759:	48 01 c0             	add    %rax,%rax
  800420075c:	48 01 c2             	add    %rax,%rdx
  800420075f:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004200762:	b0 00                	mov    $0x0,%al
  8004200764:	83 c8 20             	or     $0x20,%eax
  8004200767:	66 89 02             	mov    %ax,(%rdx)
		}
		break;
  800420076a:	e9 04 01 00 00       	jmpq   8004200873 <cga_putc+0x1b2>
  800420076f:	e9 ff 00 00 00       	jmpq   8004200873 <cga_putc+0x1b2>
	case '\n':
		crt_pos += CRT_COLS;
  8004200774:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  800420077b:	00 00 00 
  800420077e:	0f b7 00             	movzwl (%rax),%eax
  8004200781:	8d 50 50             	lea    0x50(%rax),%edx
  8004200784:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  800420078b:	00 00 00 
  800420078e:	66 89 10             	mov    %dx,(%rax)
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
  8004200791:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200798:	00 00 00 
  800420079b:	0f b7 30             	movzwl (%rax),%esi
  800420079e:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  80042007a5:	00 00 00 
  80042007a8:	0f b7 08             	movzwl (%rax),%ecx
  80042007ab:	0f b7 c1             	movzwl %cx,%eax
  80042007ae:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  80042007b4:	c1 e8 10             	shr    $0x10,%eax
  80042007b7:	89 c2                	mov    %eax,%edx
  80042007b9:	66 c1 ea 06          	shr    $0x6,%dx
  80042007bd:	89 d0                	mov    %edx,%eax
  80042007bf:	c1 e0 02             	shl    $0x2,%eax
  80042007c2:	01 d0                	add    %edx,%eax
  80042007c4:	c1 e0 04             	shl    $0x4,%eax
  80042007c7:	29 c1                	sub    %eax,%ecx
  80042007c9:	89 ca                	mov    %ecx,%edx
  80042007cb:	29 d6                	sub    %edx,%esi
  80042007cd:	89 f2                	mov    %esi,%edx
  80042007cf:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  80042007d6:	00 00 00 
  80042007d9:	66 89 10             	mov    %dx,(%rax)
		break;
  80042007dc:	e9 92 00 00 00       	jmpq   8004200873 <cga_putc+0x1b2>
	case '\t':
		cons_putc(' ');
  80042007e1:	bf 20 00 00 00       	mov    $0x20,%edi
  80042007e6:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  80042007ed:	00 00 00 
  80042007f0:	ff d0                	callq  *%rax
		cons_putc(' ');
  80042007f2:	bf 20 00 00 00       	mov    $0x20,%edi
  80042007f7:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  80042007fe:	00 00 00 
  8004200801:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200803:	bf 20 00 00 00       	mov    $0x20,%edi
  8004200808:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  800420080f:	00 00 00 
  8004200812:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200814:	bf 20 00 00 00       	mov    $0x20,%edi
  8004200819:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  8004200820:	00 00 00 
  8004200823:	ff d0                	callq  *%rax
		cons_putc(' ');
  8004200825:	bf 20 00 00 00       	mov    $0x20,%edi
  800420082a:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  8004200831:	00 00 00 
  8004200834:	ff d0                	callq  *%rax
		break;
  8004200836:	eb 3b                	jmp    8004200873 <cga_putc+0x1b2>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
  8004200838:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  800420083f:	00 00 00 
  8004200842:	48 8b 30             	mov    (%rax),%rsi
  8004200845:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  800420084c:	00 00 00 
  800420084f:	0f b7 00             	movzwl (%rax),%eax
  8004200852:	8d 48 01             	lea    0x1(%rax),%ecx
  8004200855:	48 ba b0 26 22 04 80 	movabs $0x80042226b0,%rdx
  800420085c:	00 00 00 
  800420085f:	66 89 0a             	mov    %cx,(%rdx)
  8004200862:	0f b7 c0             	movzwl %ax,%eax
  8004200865:	48 01 c0             	add    %rax,%rax
  8004200868:	48 8d 14 06          	lea    (%rsi,%rax,1),%rdx
  800420086c:	8b 45 cc             	mov    -0x34(%rbp),%eax
  800420086f:	66 89 02             	mov    %ax,(%rdx)
		break;
  8004200872:	90                   	nop
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
  8004200873:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  800420087a:	00 00 00 
  800420087d:	0f b7 00             	movzwl (%rax),%eax
  8004200880:	66 3d cf 07          	cmp    $0x7cf,%ax
  8004200884:	0f 86 89 00 00 00    	jbe    8004200913 <cga_putc+0x252>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  800420088a:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  8004200891:	00 00 00 
  8004200894:	48 8b 00             	mov    (%rax),%rax
  8004200897:	48 8d 88 a0 00 00 00 	lea    0xa0(%rax),%rcx
  800420089e:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  80042008a5:	00 00 00 
  80042008a8:	48 8b 00             	mov    (%rax),%rax
  80042008ab:	ba 00 0f 00 00       	mov    $0xf00,%edx
  80042008b0:	48 89 ce             	mov    %rcx,%rsi
  80042008b3:	48 89 c7             	mov    %rax,%rdi
  80042008b6:	48 b8 2b 80 20 04 80 	movabs $0x800420802b,%rax
  80042008bd:	00 00 00 
  80042008c0:	ff d0                	callq  *%rax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  80042008c2:	c7 45 fc 80 07 00 00 	movl   $0x780,-0x4(%rbp)
  80042008c9:	eb 22                	jmp    80042008ed <cga_putc+0x22c>
			crt_buf[i] = 0x0700 | ' ';
  80042008cb:	48 b8 a8 26 22 04 80 	movabs $0x80042226a8,%rax
  80042008d2:	00 00 00 
  80042008d5:	48 8b 00             	mov    (%rax),%rax
  80042008d8:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042008db:	48 63 d2             	movslq %edx,%rdx
  80042008de:	48 01 d2             	add    %rdx,%rdx
  80042008e1:	48 01 d0             	add    %rdx,%rax
  80042008e4:	66 c7 00 20 07       	movw   $0x720,(%rax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
  80042008e9:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  80042008ed:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  80042008f4:	7e d5                	jle    80042008cb <cga_putc+0x20a>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
  80042008f6:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  80042008fd:	00 00 00 
  8004200900:	0f b7 00             	movzwl (%rax),%eax
  8004200903:	8d 50 b0             	lea    -0x50(%rax),%edx
  8004200906:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  800420090d:	00 00 00 
  8004200910:	66 89 10             	mov    %dx,(%rax)
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
  8004200913:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  800420091a:	00 00 00 
  800420091d:	8b 00                	mov    (%rax),%eax
  800420091f:	89 45 f8             	mov    %eax,-0x8(%rbp)
  8004200922:	c6 45 f7 0e          	movb   $0xe,-0x9(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004200926:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
  800420092a:	8b 55 f8             	mov    -0x8(%rbp),%edx
  800420092d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
  800420092e:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200935:	00 00 00 
  8004200938:	0f b7 00             	movzwl (%rax),%eax
  800420093b:	66 c1 e8 08          	shr    $0x8,%ax
  800420093f:	0f b6 c0             	movzbl %al,%eax
  8004200942:	48 ba a4 26 22 04 80 	movabs $0x80042226a4,%rdx
  8004200949:	00 00 00 
  800420094c:	8b 12                	mov    (%rdx),%edx
  800420094e:	83 c2 01             	add    $0x1,%edx
  8004200951:	89 55 f0             	mov    %edx,-0x10(%rbp)
  8004200954:	88 45 ef             	mov    %al,-0x11(%rbp)
  8004200957:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  800420095b:	8b 55 f0             	mov    -0x10(%rbp),%edx
  800420095e:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
  800420095f:	48 b8 a4 26 22 04 80 	movabs $0x80042226a4,%rax
  8004200966:	00 00 00 
  8004200969:	8b 00                	mov    (%rax),%eax
  800420096b:	89 45 e8             	mov    %eax,-0x18(%rbp)
  800420096e:	c6 45 e7 0f          	movb   $0xf,-0x19(%rbp)
  8004200972:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004200976:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8004200979:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
  800420097a:	48 b8 b0 26 22 04 80 	movabs $0x80042226b0,%rax
  8004200981:	00 00 00 
  8004200984:	0f b7 00             	movzwl (%rax),%eax
  8004200987:	0f b6 c0             	movzbl %al,%eax
  800420098a:	48 ba a4 26 22 04 80 	movabs $0x80042226a4,%rdx
  8004200991:	00 00 00 
  8004200994:	8b 12                	mov    (%rdx),%edx
  8004200996:	83 c2 01             	add    $0x1,%edx
  8004200999:	89 55 e0             	mov    %edx,-0x20(%rbp)
  800420099c:	88 45 df             	mov    %al,-0x21(%rbp)
  800420099f:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  80042009a3:	8b 55 e0             	mov    -0x20(%rbp),%edx
  80042009a6:	ee                   	out    %al,(%dx)
}
  80042009a7:	c9                   	leaveq 
  80042009a8:	c3                   	retq   

00000080042009a9 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  80042009a9:	55                   	push   %rbp
  80042009aa:	48 89 e5             	mov    %rsp,%rbp
  80042009ad:	48 83 ec 20          	sub    $0x20,%rsp
  80042009b1:	c7 45 f4 64 00 00 00 	movl   $0x64,-0xc(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042009b8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  80042009bb:	89 c2                	mov    %eax,%edx
  80042009bd:	ec                   	in     (%dx),%al
  80042009be:	88 45 f3             	mov    %al,-0xd(%rbp)
	return data;
  80042009c1:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;
	int r;
	if ((inb(KBSTATP) & KBS_DIB) == 0)
  80042009c5:	0f b6 c0             	movzbl %al,%eax
  80042009c8:	83 e0 01             	and    $0x1,%eax
  80042009cb:	85 c0                	test   %eax,%eax
  80042009cd:	75 0a                	jne    80042009d9 <kbd_proc_data+0x30>
		return -1;
  80042009cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80042009d4:	e9 fc 01 00 00       	jmpq   8004200bd5 <kbd_proc_data+0x22c>
  80042009d9:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80042009e0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042009e3:	89 c2                	mov    %eax,%edx
  80042009e5:	ec                   	in     (%dx),%al
  80042009e6:	88 45 eb             	mov    %al,-0x15(%rbp)
	return data;
  80042009e9:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax

	data = inb(KBDATAP);
  80042009ed:	88 45 fb             	mov    %al,-0x5(%rbp)

	if (data == 0xE0) {
  80042009f0:	80 7d fb e0          	cmpb   $0xe0,-0x5(%rbp)
  80042009f4:	75 27                	jne    8004200a1d <kbd_proc_data+0x74>
		// E0 escape character
		shift |= E0ESC;
  80042009f6:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  80042009fd:	00 00 00 
  8004200a00:	8b 00                	mov    (%rax),%eax
  8004200a02:	83 c8 40             	or     $0x40,%eax
  8004200a05:	89 c2                	mov    %eax,%edx
  8004200a07:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200a0e:	00 00 00 
  8004200a11:	89 10                	mov    %edx,(%rax)
		return 0;
  8004200a13:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200a18:	e9 b8 01 00 00       	jmpq   8004200bd5 <kbd_proc_data+0x22c>
	} else if (data & 0x80) {
  8004200a1d:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200a21:	84 c0                	test   %al,%al
  8004200a23:	79 65                	jns    8004200a8a <kbd_proc_data+0xe1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  8004200a25:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200a2c:	00 00 00 
  8004200a2f:	8b 00                	mov    (%rax),%eax
  8004200a31:	83 e0 40             	and    $0x40,%eax
  8004200a34:	85 c0                	test   %eax,%eax
  8004200a36:	75 09                	jne    8004200a41 <kbd_proc_data+0x98>
  8004200a38:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200a3c:	83 e0 7f             	and    $0x7f,%eax
  8004200a3f:	eb 04                	jmp    8004200a45 <kbd_proc_data+0x9c>
  8004200a41:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200a45:	88 45 fb             	mov    %al,-0x5(%rbp)
		shift &= ~(shiftcode[data] | E0ESC);
  8004200a48:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200a4c:	48 ba 60 20 22 04 80 	movabs $0x8004222060,%rdx
  8004200a53:	00 00 00 
  8004200a56:	48 98                	cltq   
  8004200a58:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200a5c:	83 c8 40             	or     $0x40,%eax
  8004200a5f:	0f b6 c0             	movzbl %al,%eax
  8004200a62:	f7 d0                	not    %eax
  8004200a64:	89 c2                	mov    %eax,%edx
  8004200a66:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200a6d:	00 00 00 
  8004200a70:	8b 00                	mov    (%rax),%eax
  8004200a72:	21 c2                	and    %eax,%edx
  8004200a74:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200a7b:	00 00 00 
  8004200a7e:	89 10                	mov    %edx,(%rax)
		return 0;
  8004200a80:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200a85:	e9 4b 01 00 00       	jmpq   8004200bd5 <kbd_proc_data+0x22c>
	} else if (shift & E0ESC) {
  8004200a8a:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200a91:	00 00 00 
  8004200a94:	8b 00                	mov    (%rax),%eax
  8004200a96:	83 e0 40             	and    $0x40,%eax
  8004200a99:	85 c0                	test   %eax,%eax
  8004200a9b:	74 21                	je     8004200abe <kbd_proc_data+0x115>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  8004200a9d:	80 4d fb 80          	orb    $0x80,-0x5(%rbp)
		shift &= ~E0ESC;
  8004200aa1:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200aa8:	00 00 00 
  8004200aab:	8b 00                	mov    (%rax),%eax
  8004200aad:	83 e0 bf             	and    $0xffffffbf,%eax
  8004200ab0:	89 c2                	mov    %eax,%edx
  8004200ab2:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200ab9:	00 00 00 
  8004200abc:	89 10                	mov    %edx,(%rax)
	}

	shift |= shiftcode[data];
  8004200abe:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200ac2:	48 ba 60 20 22 04 80 	movabs $0x8004222060,%rdx
  8004200ac9:	00 00 00 
  8004200acc:	48 98                	cltq   
  8004200ace:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200ad2:	0f b6 d0             	movzbl %al,%edx
  8004200ad5:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200adc:	00 00 00 
  8004200adf:	8b 00                	mov    (%rax),%eax
  8004200ae1:	09 c2                	or     %eax,%edx
  8004200ae3:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200aea:	00 00 00 
  8004200aed:	89 10                	mov    %edx,(%rax)
	shift ^= togglecode[data];
  8004200aef:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200af3:	48 ba 60 21 22 04 80 	movabs $0x8004222160,%rdx
  8004200afa:	00 00 00 
  8004200afd:	48 98                	cltq   
  8004200aff:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200b03:	0f b6 d0             	movzbl %al,%edx
  8004200b06:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200b0d:	00 00 00 
  8004200b10:	8b 00                	mov    (%rax),%eax
  8004200b12:	31 c2                	xor    %eax,%edx
  8004200b14:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200b1b:	00 00 00 
  8004200b1e:	89 10                	mov    %edx,(%rax)

	c = charcode[shift & (CTL | SHIFT)][data];
  8004200b20:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200b27:	00 00 00 
  8004200b2a:	8b 00                	mov    (%rax),%eax
  8004200b2c:	83 e0 03             	and    $0x3,%eax
  8004200b2f:	89 c2                	mov    %eax,%edx
  8004200b31:	48 b8 60 25 22 04 80 	movabs $0x8004222560,%rax
  8004200b38:	00 00 00 
  8004200b3b:	89 d2                	mov    %edx,%edx
  8004200b3d:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
  8004200b41:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004200b45:	48 01 d0             	add    %rdx,%rax
  8004200b48:	0f b6 00             	movzbl (%rax),%eax
  8004200b4b:	0f b6 c0             	movzbl %al,%eax
  8004200b4e:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (shift & CAPSLOCK) {
  8004200b51:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200b58:	00 00 00 
  8004200b5b:	8b 00                	mov    (%rax),%eax
  8004200b5d:	83 e0 08             	and    $0x8,%eax
  8004200b60:	85 c0                	test   %eax,%eax
  8004200b62:	74 22                	je     8004200b86 <kbd_proc_data+0x1dd>
		if ('a' <= c && c <= 'z')
  8004200b64:	83 7d fc 60          	cmpl   $0x60,-0x4(%rbp)
  8004200b68:	7e 0c                	jle    8004200b76 <kbd_proc_data+0x1cd>
  8004200b6a:	83 7d fc 7a          	cmpl   $0x7a,-0x4(%rbp)
  8004200b6e:	7f 06                	jg     8004200b76 <kbd_proc_data+0x1cd>
			c += 'A' - 'a';
  8004200b70:	83 6d fc 20          	subl   $0x20,-0x4(%rbp)
  8004200b74:	eb 10                	jmp    8004200b86 <kbd_proc_data+0x1dd>
		else if ('A' <= c && c <= 'Z')
  8004200b76:	83 7d fc 40          	cmpl   $0x40,-0x4(%rbp)
  8004200b7a:	7e 0a                	jle    8004200b86 <kbd_proc_data+0x1dd>
  8004200b7c:	83 7d fc 5a          	cmpl   $0x5a,-0x4(%rbp)
  8004200b80:	7f 04                	jg     8004200b86 <kbd_proc_data+0x1dd>
			c += 'a' - 'A';
  8004200b82:	83 45 fc 20          	addl   $0x20,-0x4(%rbp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  8004200b86:	48 b8 c8 28 22 04 80 	movabs $0x80042228c8,%rax
  8004200b8d:	00 00 00 
  8004200b90:	8b 00                	mov    (%rax),%eax
  8004200b92:	f7 d0                	not    %eax
  8004200b94:	83 e0 06             	and    $0x6,%eax
  8004200b97:	85 c0                	test   %eax,%eax
  8004200b99:	75 37                	jne    8004200bd2 <kbd_proc_data+0x229>
  8004200b9b:	81 7d fc e9 00 00 00 	cmpl   $0xe9,-0x4(%rbp)
  8004200ba2:	75 2e                	jne    8004200bd2 <kbd_proc_data+0x229>
		cprintf("Rebooting!\n");
  8004200ba4:	48 bf ef e3 20 04 80 	movabs $0x800420e3ef,%rdi
  8004200bab:	00 00 00 
  8004200bae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200bb3:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200bba:	00 00 00 
  8004200bbd:	ff d2                	callq  *%rdx
  8004200bbf:	c7 45 e4 92 00 00 00 	movl   $0x92,-0x1c(%rbp)
  8004200bc6:	c6 45 e3 03          	movb   $0x3,-0x1d(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004200bca:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  8004200bce:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004200bd1:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}
	return c;
  8004200bd2:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004200bd5:	c9                   	leaveq 
  8004200bd6:	c3                   	retq   

0000008004200bd7 <kbd_intr>:

void
kbd_intr(void)
{
  8004200bd7:	55                   	push   %rbp
  8004200bd8:	48 89 e5             	mov    %rsp,%rbp
	cons_intr(kbd_proc_data);
  8004200bdb:	48 bf a9 09 20 04 80 	movabs $0x80042009a9,%rdi
  8004200be2:	00 00 00 
  8004200be5:	48 b8 f9 0b 20 04 80 	movabs $0x8004200bf9,%rax
  8004200bec:	00 00 00 
  8004200bef:	ff d0                	callq  *%rax
}
  8004200bf1:	5d                   	pop    %rbp
  8004200bf2:	c3                   	retq   

0000008004200bf3 <kbd_init>:

static void
kbd_init(void)
{
  8004200bf3:	55                   	push   %rbp
  8004200bf4:	48 89 e5             	mov    %rsp,%rbp
}
  8004200bf7:	5d                   	pop    %rbp
  8004200bf8:	c3                   	retq   

0000008004200bf9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
  8004200bf9:	55                   	push   %rbp
  8004200bfa:	48 89 e5             	mov    %rsp,%rbp
  8004200bfd:	48 83 ec 20          	sub    $0x20,%rsp
  8004200c01:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int c;

	while ((c = (*proc)()) != -1) {
  8004200c05:	eb 6a                	jmp    8004200c71 <cons_intr+0x78>
		if (c == 0)
  8004200c07:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004200c0b:	75 02                	jne    8004200c0f <cons_intr+0x16>
			continue;
  8004200c0d:	eb 62                	jmp    8004200c71 <cons_intr+0x78>
		cons.buf[cons.wpos++] = c;
  8004200c0f:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200c16:	00 00 00 
  8004200c19:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200c1f:	8d 48 01             	lea    0x1(%rax),%ecx
  8004200c22:	48 ba c0 26 22 04 80 	movabs $0x80042226c0,%rdx
  8004200c29:	00 00 00 
  8004200c2c:	89 8a 04 02 00 00    	mov    %ecx,0x204(%rdx)
  8004200c32:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004200c35:	89 d1                	mov    %edx,%ecx
  8004200c37:	48 ba c0 26 22 04 80 	movabs $0x80042226c0,%rdx
  8004200c3e:	00 00 00 
  8004200c41:	89 c0                	mov    %eax,%eax
  8004200c43:	88 0c 02             	mov    %cl,(%rdx,%rax,1)
		if (cons.wpos == CONSBUFSIZE)
  8004200c46:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200c4d:	00 00 00 
  8004200c50:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200c56:	3d 00 02 00 00       	cmp    $0x200,%eax
  8004200c5b:	75 14                	jne    8004200c71 <cons_intr+0x78>
			cons.wpos = 0;
  8004200c5d:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200c64:	00 00 00 
  8004200c67:	c7 80 04 02 00 00 00 	movl   $0x0,0x204(%rax)
  8004200c6e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  8004200c71:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004200c75:	ff d0                	callq  *%rax
  8004200c77:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8004200c7a:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%rbp)
  8004200c7e:	75 87                	jne    8004200c07 <cons_intr+0xe>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
  8004200c80:	c9                   	leaveq 
  8004200c81:	c3                   	retq   

0000008004200c82 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
  8004200c82:	55                   	push   %rbp
  8004200c83:	48 89 e5             	mov    %rsp,%rbp
  8004200c86:	48 83 ec 10          	sub    $0x10,%rsp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
  8004200c8a:	48 b8 bc 03 20 04 80 	movabs $0x80042003bc,%rax
  8004200c91:	00 00 00 
  8004200c94:	ff d0                	callq  *%rax
	kbd_intr();
  8004200c96:	48 b8 d7 0b 20 04 80 	movabs $0x8004200bd7,%rax
  8004200c9d:	00 00 00 
  8004200ca0:	ff d0                	callq  *%rax

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  8004200ca2:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200ca9:	00 00 00 
  8004200cac:	8b 90 00 02 00 00    	mov    0x200(%rax),%edx
  8004200cb2:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200cb9:	00 00 00 
  8004200cbc:	8b 80 04 02 00 00    	mov    0x204(%rax),%eax
  8004200cc2:	39 c2                	cmp    %eax,%edx
  8004200cc4:	74 69                	je     8004200d2f <cons_getc+0xad>
		c = cons.buf[cons.rpos++];
  8004200cc6:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200ccd:	00 00 00 
  8004200cd0:	8b 80 00 02 00 00    	mov    0x200(%rax),%eax
  8004200cd6:	8d 48 01             	lea    0x1(%rax),%ecx
  8004200cd9:	48 ba c0 26 22 04 80 	movabs $0x80042226c0,%rdx
  8004200ce0:	00 00 00 
  8004200ce3:	89 8a 00 02 00 00    	mov    %ecx,0x200(%rdx)
  8004200ce9:	48 ba c0 26 22 04 80 	movabs $0x80042226c0,%rdx
  8004200cf0:	00 00 00 
  8004200cf3:	89 c0                	mov    %eax,%eax
  8004200cf5:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  8004200cf9:	0f b6 c0             	movzbl %al,%eax
  8004200cfc:	89 45 fc             	mov    %eax,-0x4(%rbp)
		if (cons.rpos == CONSBUFSIZE)
  8004200cff:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200d06:	00 00 00 
  8004200d09:	8b 80 00 02 00 00    	mov    0x200(%rax),%eax
  8004200d0f:	3d 00 02 00 00       	cmp    $0x200,%eax
  8004200d14:	75 14                	jne    8004200d2a <cons_getc+0xa8>
			cons.rpos = 0;
  8004200d16:	48 b8 c0 26 22 04 80 	movabs $0x80042226c0,%rax
  8004200d1d:	00 00 00 
  8004200d20:	c7 80 00 02 00 00 00 	movl   $0x0,0x200(%rax)
  8004200d27:	00 00 00 
		return c;
  8004200d2a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200d2d:	eb 05                	jmp    8004200d34 <cons_getc+0xb2>
	}
	return 0;
  8004200d2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004200d34:	c9                   	leaveq 
  8004200d35:	c3                   	retq   

0000008004200d36 <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
  8004200d36:	55                   	push   %rbp
  8004200d37:	48 89 e5             	mov    %rsp,%rbp
  8004200d3a:	48 83 ec 10          	sub    $0x10,%rsp
  8004200d3e:	89 7d fc             	mov    %edi,-0x4(%rbp)
	serial_putc(c);
  8004200d41:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200d44:	89 c7                	mov    %eax,%edi
  8004200d46:	48 b8 e9 03 20 04 80 	movabs $0x80042003e9,%rax
  8004200d4d:	00 00 00 
  8004200d50:	ff d0                	callq  *%rax
	lpt_putc(c);
  8004200d52:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200d55:	89 c7                	mov    %eax,%edi
  8004200d57:	48 b8 22 05 20 04 80 	movabs $0x8004200522,%rax
  8004200d5e:	00 00 00 
  8004200d61:	ff d0                	callq  *%rax
	cga_putc(c);
  8004200d63:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200d66:	89 c7                	mov    %eax,%edi
  8004200d68:	48 b8 c1 06 20 04 80 	movabs $0x80042006c1,%rax
  8004200d6f:	00 00 00 
  8004200d72:	ff d0                	callq  *%rax
}
  8004200d74:	c9                   	leaveq 
  8004200d75:	c3                   	retq   

0000008004200d76 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
  8004200d76:	55                   	push   %rbp
  8004200d77:	48 89 e5             	mov    %rsp,%rbp
	cga_init();
  8004200d7a:	48 b8 a7 05 20 04 80 	movabs $0x80042005a7,%rax
  8004200d81:	00 00 00 
  8004200d84:	ff d0                	callq  *%rax
	kbd_init();
  8004200d86:	48 b8 f3 0b 20 04 80 	movabs $0x8004200bf3,%rax
  8004200d8d:	00 00 00 
  8004200d90:	ff d0                	callq  *%rax
	serial_init();
  8004200d92:	48 b8 4e 04 20 04 80 	movabs $0x800420044e,%rax
  8004200d99:	00 00 00 
  8004200d9c:	ff d0                	callq  *%rax

	if (!serial_exists)
  8004200d9e:	48 b8 a0 26 22 04 80 	movabs $0x80042226a0,%rax
  8004200da5:	00 00 00 
  8004200da8:	0f b6 00             	movzbl (%rax),%eax
  8004200dab:	83 f0 01             	xor    $0x1,%eax
  8004200dae:	84 c0                	test   %al,%al
  8004200db0:	74 1b                	je     8004200dcd <cons_init+0x57>
		cprintf("Serial port does not exist!\n");
  8004200db2:	48 bf fb e3 20 04 80 	movabs $0x800420e3fb,%rdi
  8004200db9:	00 00 00 
  8004200dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200dc1:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200dc8:	00 00 00 
  8004200dcb:	ff d2                	callq  *%rdx
}
  8004200dcd:	5d                   	pop    %rbp
  8004200dce:	c3                   	retq   

0000008004200dcf <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
  8004200dcf:	55                   	push   %rbp
  8004200dd0:	48 89 e5             	mov    %rsp,%rbp
  8004200dd3:	48 83 ec 10          	sub    $0x10,%rsp
  8004200dd7:	89 7d fc             	mov    %edi,-0x4(%rbp)
	cons_putc(c);
  8004200dda:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200ddd:	89 c7                	mov    %eax,%edi
  8004200ddf:	48 b8 36 0d 20 04 80 	movabs $0x8004200d36,%rax
  8004200de6:	00 00 00 
  8004200de9:	ff d0                	callq  *%rax
}
  8004200deb:	c9                   	leaveq 
  8004200dec:	c3                   	retq   

0000008004200ded <getchar>:

int
getchar(void)
{
  8004200ded:	55                   	push   %rbp
  8004200dee:	48 89 e5             	mov    %rsp,%rbp
  8004200df1:	48 83 ec 10          	sub    $0x10,%rsp
	int c;

	while ((c = cons_getc()) == 0)
  8004200df5:	48 b8 82 0c 20 04 80 	movabs $0x8004200c82,%rax
  8004200dfc:	00 00 00 
  8004200dff:	ff d0                	callq  *%rax
  8004200e01:	89 45 fc             	mov    %eax,-0x4(%rbp)
  8004200e04:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004200e08:	74 eb                	je     8004200df5 <getchar+0x8>
		/* do nothing */;
	return c;
  8004200e0a:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004200e0d:	c9                   	leaveq 
  8004200e0e:	c3                   	retq   

0000008004200e0f <iscons>:

int
iscons(int fdnum)
{
  8004200e0f:	55                   	push   %rbp
  8004200e10:	48 89 e5             	mov    %rsp,%rbp
  8004200e13:	48 83 ec 04          	sub    $0x4,%rsp
  8004200e17:	89 7d fc             	mov    %edi,-0x4(%rbp)
	// used by readline
	return 1;
  8004200e1a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004200e1f:	c9                   	leaveq 
  8004200e20:	c3                   	retq   

0000008004200e21 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
  8004200e21:	55                   	push   %rbp
  8004200e22:	48 89 e5             	mov    %rsp,%rbp
  8004200e25:	48 83 ec 30          	sub    $0x30,%rsp
  8004200e29:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8004200e2c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004200e30:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    int i;

    for (i = 0; i < NCOMMANDS; i++)
  8004200e34:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004200e3b:	eb 6c                	jmp    8004200ea9 <mon_help+0x88>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  8004200e3d:	48 b9 80 25 22 04 80 	movabs $0x8004222580,%rcx
  8004200e44:	00 00 00 
  8004200e47:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200e4a:	48 63 d0             	movslq %eax,%rdx
  8004200e4d:	48 89 d0             	mov    %rdx,%rax
  8004200e50:	48 01 c0             	add    %rax,%rax
  8004200e53:	48 01 d0             	add    %rdx,%rax
  8004200e56:	48 c1 e0 03          	shl    $0x3,%rax
  8004200e5a:	48 01 c8             	add    %rcx,%rax
  8004200e5d:	48 8b 48 08          	mov    0x8(%rax),%rcx
  8004200e61:	48 be 80 25 22 04 80 	movabs $0x8004222580,%rsi
  8004200e68:	00 00 00 
  8004200e6b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200e6e:	48 63 d0             	movslq %eax,%rdx
  8004200e71:	48 89 d0             	mov    %rdx,%rax
  8004200e74:	48 01 c0             	add    %rax,%rax
  8004200e77:	48 01 d0             	add    %rdx,%rax
  8004200e7a:	48 c1 e0 03          	shl    $0x3,%rax
  8004200e7e:	48 01 f0             	add    %rsi,%rax
  8004200e81:	48 8b 00             	mov    (%rax),%rax
  8004200e84:	48 89 ca             	mov    %rcx,%rdx
  8004200e87:	48 89 c6             	mov    %rax,%rsi
  8004200e8a:	48 bf 87 e4 20 04 80 	movabs $0x800420e487,%rdi
  8004200e91:	00 00 00 
  8004200e94:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200e99:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  8004200ea0:	00 00 00 
  8004200ea3:	ff d1                	callq  *%rcx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
    int i;

    for (i = 0; i < NCOMMANDS; i++)
  8004200ea5:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  8004200ea9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004200eac:	83 f8 02             	cmp    $0x2,%eax
  8004200eaf:	76 8c                	jbe    8004200e3d <mon_help+0x1c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    return 0;
  8004200eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004200eb6:	c9                   	leaveq 
  8004200eb7:	c3                   	retq   

0000008004200eb8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
  8004200eb8:	55                   	push   %rbp
  8004200eb9:	48 89 e5             	mov    %rsp,%rbp
  8004200ebc:	48 83 ec 30          	sub    $0x30,%rsp
  8004200ec0:	89 7d ec             	mov    %edi,-0x14(%rbp)
  8004200ec3:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004200ec7:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    extern char _start[], entry[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
  8004200ecb:	48 bf 90 e4 20 04 80 	movabs $0x800420e490,%rdi
  8004200ed2:	00 00 00 
  8004200ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200eda:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200ee1:	00 00 00 
  8004200ee4:	ff d2                	callq  *%rdx
    cprintf("  _start                  %08x (phys)\n", _start);
  8004200ee6:	48 be 0c 00 20 00 00 	movabs $0x20000c,%rsi
  8004200eed:	00 00 00 
  8004200ef0:	48 bf b0 e4 20 04 80 	movabs $0x800420e4b0,%rdi
  8004200ef7:	00 00 00 
  8004200efa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200eff:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004200f06:	00 00 00 
  8004200f09:	ff d2                	callq  *%rdx
    cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
  8004200f0b:	48 ba 0c 00 20 00 00 	movabs $0x20000c,%rdx
  8004200f12:	00 00 00 
  8004200f15:	48 be 0c 00 20 04 80 	movabs $0x800420000c,%rsi
  8004200f1c:	00 00 00 
  8004200f1f:	48 bf d8 e4 20 04 80 	movabs $0x800420e4d8,%rdi
  8004200f26:	00 00 00 
  8004200f29:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f2e:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  8004200f35:	00 00 00 
  8004200f38:	ff d1                	callq  *%rcx
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
  8004200f3a:	48 ba 89 e3 20 00 00 	movabs $0x20e389,%rdx
  8004200f41:	00 00 00 
  8004200f44:	48 be 89 e3 20 04 80 	movabs $0x800420e389,%rsi
  8004200f4b:	00 00 00 
  8004200f4e:	48 bf 00 e5 20 04 80 	movabs $0x800420e500,%rdi
  8004200f55:	00 00 00 
  8004200f58:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f5d:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  8004200f64:	00 00 00 
  8004200f67:	ff d1                	callq  *%rcx
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
  8004200f69:	48 ba a0 26 22 00 00 	movabs $0x2226a0,%rdx
  8004200f70:	00 00 00 
  8004200f73:	48 be a0 26 22 04 80 	movabs $0x80042226a0,%rsi
  8004200f7a:	00 00 00 
  8004200f7d:	48 bf 28 e5 20 04 80 	movabs $0x800420e528,%rdi
  8004200f84:	00 00 00 
  8004200f87:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200f8c:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  8004200f93:	00 00 00 
  8004200f96:	ff d1                	callq  *%rcx
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
  8004200f98:	48 ba 80 3d 22 00 00 	movabs $0x223d80,%rdx
  8004200f9f:	00 00 00 
  8004200fa2:	48 be 80 3d 22 04 80 	movabs $0x8004223d80,%rsi
  8004200fa9:	00 00 00 
  8004200fac:	48 bf 50 e5 20 04 80 	movabs $0x800420e550,%rdi
  8004200fb3:	00 00 00 
  8004200fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004200fbb:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  8004200fc2:	00 00 00 
  8004200fc5:	ff d1                	callq  *%rcx
    cprintf("Kernel executable memory footprint: %dKB\n",
            ROUNDUP(end - entry, 1024) / 1024);
  8004200fc7:	48 c7 45 f8 00 04 00 	movq   $0x400,-0x8(%rbp)
  8004200fce:	00 
  8004200fcf:	48 b8 0c 00 20 04 80 	movabs $0x800420000c,%rax
  8004200fd6:	00 00 00 
  8004200fd9:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004200fdd:	48 29 c2             	sub    %rax,%rdx
  8004200fe0:	48 b8 80 3d 22 04 80 	movabs $0x8004223d80,%rax
  8004200fe7:	00 00 00 
  8004200fea:	48 83 e8 01          	sub    $0x1,%rax
  8004200fee:	48 01 d0             	add    %rdx,%rax
  8004200ff1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8004200ff5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004200ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004200ffe:	48 f7 75 f8          	divq   -0x8(%rbp)
  8004201002:	48 89 d0             	mov    %rdx,%rax
  8004201005:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004201009:	48 29 c2             	sub    %rax,%rdx
  800420100c:	48 89 d0             	mov    %rdx,%rax
    cprintf("  _start                  %08x (phys)\n", _start);
    cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
    cprintf("Kernel executable memory footprint: %dKB\n",
  800420100f:	48 8d 90 ff 03 00 00 	lea    0x3ff(%rax),%rdx
  8004201016:	48 85 c0             	test   %rax,%rax
  8004201019:	48 0f 48 c2          	cmovs  %rdx,%rax
  800420101d:	48 c1 f8 0a          	sar    $0xa,%rax
  8004201021:	48 89 c6             	mov    %rax,%rsi
  8004201024:	48 bf 78 e5 20 04 80 	movabs $0x800420e578,%rdi
  800420102b:	00 00 00 
  800420102e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201033:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  800420103a:	00 00 00 
  800420103d:	ff d2                	callq  *%rdx
            ROUNDUP(end - entry, 1024) / 1024);
    return 0;
  800420103f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004201044:	c9                   	leaveq 
  8004201045:	c3                   	retq   

0000008004201046 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
  8004201046:	55                   	push   %rbp
  8004201047:	48 89 e5             	mov    %rsp,%rbp
  800420104a:	48 81 ec 20 05 00 00 	sub    $0x520,%rsp
  8004201051:	89 bd fc fa ff ff    	mov    %edi,-0x504(%rbp)
  8004201057:	48 89 b5 f0 fa ff ff 	mov    %rsi,-0x510(%rbp)
  800420105e:	48 89 95 e8 fa ff ff 	mov    %rdx,-0x518(%rbp)

static __inline uint64_t
read_rbp(void)
{
	uint64_t rbp;
	__asm __volatile("movq %%rbp,%0" : "=r" (rbp)::"cc","memory");
  8004201065:	48 89 e8             	mov    %rbp,%rax
  8004201068:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	return rbp;
  800420106c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
    // Your code here.
    // read register base pointer
    uint64_t *rbp = (uint64_t *)read_rbp();
  8004201070:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    uint64_t rip;
    read_rip(rip);
  8004201074:	48 8d 05 00 00 00 00 	lea    0x0(%rip),%rax        # 420107b <_start+0x400106f>
  800420107b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    cprintf("Stack backtrace: \n");
  800420107f:	48 bf a2 e5 20 04 80 	movabs $0x800420e5a2,%rdi
  8004201086:	00 00 00 
  8004201089:	b8 00 00 00 00       	mov    $0x0,%eax
  800420108e:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004201095:	00 00 00 
  8004201098:	ff d2                	callq  *%rdx

    do {

        cprintf("rbp %016x   rip %016x\n", rbp, rip);
  800420109a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420109e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042010a2:	48 89 c6             	mov    %rax,%rsi
  80042010a5:	48 bf b5 e5 20 04 80 	movabs $0x800420e5b5,%rdi
  80042010ac:	00 00 00 
  80042010af:	b8 00 00 00 00       	mov    $0x0,%eax
  80042010b4:	48 b9 50 64 20 04 80 	movabs $0x8004206450,%rcx
  80042010bb:	00 00 00 
  80042010be:	ff d1                	callq  *%rcx
        struct Ripdebuginfo info;
        debuginfo_rip(rip, &info);
  80042010c0:	48 8d 95 00 fb ff ff 	lea    -0x500(%rbp),%rdx
  80042010c7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042010cb:	48 89 d6             	mov    %rdx,%rsi
  80042010ce:	48 89 c7             	mov    %rax,%rdi
  80042010d1:	48 b8 d8 6c 20 04 80 	movabs $0x8004206cd8,%rax
  80042010d8:	00 00 00 
  80042010db:	ff d0                	callq  *%rax
        int offset=rip-info.rip_fn_addr;
  80042010dd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042010e1:	89 c2                	mov    %eax,%edx
  80042010e3:	48 8b 85 20 fb ff ff 	mov    -0x4e0(%rbp),%rax
  80042010ea:	29 c2                	sub    %eax,%edx
  80042010ec:	89 d0                	mov    %edx,%eax
  80042010ee:	89 45 e8             	mov    %eax,-0x18(%rbp)
        cprintf(" %s:%d: %s+%016x ",info.rip_file, info.rip_line, info.rip_fn_name,offset);
  80042010f1:	48 8b 8d 10 fb ff ff 	mov    -0x4f0(%rbp),%rcx
  80042010f8:	8b 95 08 fb ff ff    	mov    -0x4f8(%rbp),%edx
  80042010fe:	48 8b 85 00 fb ff ff 	mov    -0x500(%rbp),%rax
  8004201105:	8b 75 e8             	mov    -0x18(%rbp),%esi
  8004201108:	41 89 f0             	mov    %esi,%r8d
  800420110b:	48 89 c6             	mov    %rax,%rsi
  800420110e:	48 bf cc e5 20 04 80 	movabs $0x800420e5cc,%rdi
  8004201115:	00 00 00 
  8004201118:	b8 00 00 00 00       	mov    $0x0,%eax
  800420111d:	49 b9 50 64 20 04 80 	movabs $0x8004206450,%r9
  8004201124:	00 00 00 
  8004201127:	41 ff d1             	callq  *%r9
        cprintf("args:%x ",info.rip_fn_narg);
  800420112a:	8b 85 28 fb ff ff    	mov    -0x4d8(%rbp),%eax
  8004201130:	89 c6                	mov    %eax,%esi
  8004201132:	48 bf de e5 20 04 80 	movabs $0x800420e5de,%rdi
  8004201139:	00 00 00 
  800420113c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201141:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004201148:	00 00 00 
  800420114b:	ff d2                	callq  *%rdx
        int i;
        for(i = 1; i <= info.rip_fn_narg; i++) {
  800420114d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%rbp)
  8004201154:	eb 39                	jmp    800420118f <mon_backtrace+0x149>
            cprintf("%016x ", *((int *)(rbp) -i));
  8004201156:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201159:	48 98                	cltq   
  800420115b:	48 c1 e0 02          	shl    $0x2,%rax
  800420115f:	48 f7 d8             	neg    %rax
  8004201162:	48 89 c2             	mov    %rax,%rdx
  8004201165:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201169:	48 01 d0             	add    %rdx,%rax
  800420116c:	8b 00                	mov    (%rax),%eax
  800420116e:	89 c6                	mov    %eax,%esi
  8004201170:	48 bf e7 e5 20 04 80 	movabs $0x800420e5e7,%rdi
  8004201177:	00 00 00 
  800420117a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420117f:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004201186:	00 00 00 
  8004201189:	ff d2                	callq  *%rdx
        debuginfo_rip(rip, &info);
        int offset=rip-info.rip_fn_addr;
        cprintf(" %s:%d: %s+%016x ",info.rip_file, info.rip_line, info.rip_fn_name,offset);
        cprintf("args:%x ",info.rip_fn_narg);
        int i;
        for(i = 1; i <= info.rip_fn_narg; i++) {
  800420118b:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  800420118f:	8b 85 28 fb ff ff    	mov    -0x4d8(%rbp),%eax
  8004201195:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  8004201198:	7d bc                	jge    8004201156 <mon_backtrace+0x110>
            cprintf("%016x ", *((int *)(rbp) -i));
        }
        cprintf("\n");
  800420119a:	48 bf ee e5 20 04 80 	movabs $0x800420e5ee,%rdi
  80042011a1:	00 00 00 
  80042011a4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042011a9:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  80042011b0:	00 00 00 
  80042011b3:	ff d2                	callq  *%rdx
        rip = (uint64_t) *(rbp+1);
  80042011b5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042011b9:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042011bd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
        rbp = (uint64_t *)(*rbp);
  80042011c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042011c5:	48 8b 00             	mov    (%rax),%rax
  80042011c8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    } while (rbp!=0);
  80042011cc:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042011d1:	0f 85 c3 fe ff ff    	jne    800420109a <mon_backtrace+0x54>

    return 0;
  80042011d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042011dc:	c9                   	leaveq 
  80042011dd:	c3                   	retq   

00000080042011de <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
  80042011de:	55                   	push   %rbp
  80042011df:	48 89 e5             	mov    %rsp,%rbp
  80042011e2:	48 81 ec a0 00 00 00 	sub    $0xa0,%rsp
  80042011e9:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  80042011f0:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
    int argc;
    char *argv[MAXARGS];
    int i;

    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
  80042011f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    argv[argc] = 0;
  80042011fe:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004201201:	48 98                	cltq   
  8004201203:	48 c7 84 c5 70 ff ff 	movq   $0x0,-0x90(%rbp,%rax,8)
  800420120a:	ff 00 00 00 00 
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
  800420120f:	eb 15                	jmp    8004201226 <runcmd+0x48>
            *buf++ = 0;
  8004201211:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004201218:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420121c:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  8004201223:	c6 00 00             	movb   $0x0,(%rax)
    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
    argv[argc] = 0;
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
  8004201226:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420122d:	0f b6 00             	movzbl (%rax),%eax
  8004201230:	84 c0                	test   %al,%al
  8004201232:	74 2a                	je     800420125e <runcmd+0x80>
  8004201234:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420123b:	0f b6 00             	movzbl (%rax),%eax
  800420123e:	0f be c0             	movsbl %al,%eax
  8004201241:	89 c6                	mov    %eax,%esi
  8004201243:	48 bf f0 e5 20 04 80 	movabs $0x800420e5f0,%rdi
  800420124a:	00 00 00 
  800420124d:	48 b8 2d 7f 20 04 80 	movabs $0x8004207f2d,%rax
  8004201254:	00 00 00 
  8004201257:	ff d0                	callq  *%rax
  8004201259:	48 85 c0             	test   %rax,%rax
  800420125c:	75 b3                	jne    8004201211 <runcmd+0x33>
            *buf++ = 0;
        if (*buf == 0)
  800420125e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004201265:	0f b6 00             	movzbl (%rax),%eax
  8004201268:	84 c0                	test   %al,%al
  800420126a:	75 21                	jne    800420128d <runcmd+0xaf>
            break;
  800420126c:	90                   	nop
        }
        argv[argc++] = buf;
        while (*buf && !strchr(WHITESPACE, *buf))
            buf++;
    }
    argv[argc] = 0;
  800420126d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004201270:	48 98                	cltq   
  8004201272:	48 c7 84 c5 70 ff ff 	movq   $0x0,-0x90(%rbp,%rax,8)
  8004201279:	ff 00 00 00 00 

    // Lookup and invoke the command
    if (argc == 0)
  800420127e:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004201282:	0f 85 a1 00 00 00    	jne    8004201329 <runcmd+0x14b>
  8004201288:	e9 92 00 00 00       	jmpq   800420131f <runcmd+0x141>
            *buf++ = 0;
        if (*buf == 0)
            break;

        // save and scan past next arg
        if (argc == MAXARGS-1) {
  800420128d:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
  8004201291:	75 2a                	jne    80042012bd <runcmd+0xdf>
            cprintf("Too many arguments (max %d)\n", MAXARGS);
  8004201293:	be 10 00 00 00       	mov    $0x10,%esi
  8004201298:	48 bf f5 e5 20 04 80 	movabs $0x800420e5f5,%rdi
  800420129f:	00 00 00 
  80042012a2:	b8 00 00 00 00       	mov    $0x0,%eax
  80042012a7:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  80042012ae:	00 00 00 
  80042012b1:	ff d2                	callq  *%rdx
            return 0;
  80042012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  80042012b8:	e9 30 01 00 00       	jmpq   80042013ed <runcmd+0x20f>
        }
        argv[argc++] = buf;
  80042012bd:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80042012c0:	8d 50 01             	lea    0x1(%rax),%edx
  80042012c3:	89 55 fc             	mov    %edx,-0x4(%rbp)
  80042012c6:	48 98                	cltq   
  80042012c8:	48 8b 95 68 ff ff ff 	mov    -0x98(%rbp),%rdx
  80042012cf:	48 89 94 c5 70 ff ff 	mov    %rdx,-0x90(%rbp,%rax,8)
  80042012d6:	ff 
        while (*buf && !strchr(WHITESPACE, *buf))
  80042012d7:	eb 08                	jmp    80042012e1 <runcmd+0x103>
            buf++;
  80042012d9:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  80042012e0:	01 
        if (argc == MAXARGS-1) {
            cprintf("Too many arguments (max %d)\n", MAXARGS);
            return 0;
        }
        argv[argc++] = buf;
        while (*buf && !strchr(WHITESPACE, *buf))
  80042012e1:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042012e8:	0f b6 00             	movzbl (%rax),%eax
  80042012eb:	84 c0                	test   %al,%al
  80042012ed:	74 2a                	je     8004201319 <runcmd+0x13b>
  80042012ef:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042012f6:	0f b6 00             	movzbl (%rax),%eax
  80042012f9:	0f be c0             	movsbl %al,%eax
  80042012fc:	89 c6                	mov    %eax,%esi
  80042012fe:	48 bf f0 e5 20 04 80 	movabs $0x800420e5f0,%rdi
  8004201305:	00 00 00 
  8004201308:	48 b8 2d 7f 20 04 80 	movabs $0x8004207f2d,%rax
  800420130f:	00 00 00 
  8004201312:	ff d0                	callq  *%rax
  8004201314:	48 85 c0             	test   %rax,%rax
  8004201317:	74 c0                	je     80042012d9 <runcmd+0xfb>
            buf++;
    }
  8004201319:	90                   	nop
    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
    argv[argc] = 0;
    while (1) {
        // gobble whitespace
        while (*buf && strchr(WHITESPACE, *buf))
  800420131a:	e9 07 ff ff ff       	jmpq   8004201226 <runcmd+0x48>
    }
    argv[argc] = 0;

    // Lookup and invoke the command
    if (argc == 0)
        return 0;
  800420131f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201324:	e9 c4 00 00 00       	jmpq   80042013ed <runcmd+0x20f>
    for (i = 0; i < NCOMMANDS; i++) {
  8004201329:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  8004201330:	e9 82 00 00 00       	jmpq   80042013b7 <runcmd+0x1d9>
        if (strcmp(argv[0], commands[i].name) == 0)
  8004201335:	48 b9 80 25 22 04 80 	movabs $0x8004222580,%rcx
  800420133c:	00 00 00 
  800420133f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004201342:	48 63 d0             	movslq %eax,%rdx
  8004201345:	48 89 d0             	mov    %rdx,%rax
  8004201348:	48 01 c0             	add    %rax,%rax
  800420134b:	48 01 d0             	add    %rdx,%rax
  800420134e:	48 c1 e0 03          	shl    $0x3,%rax
  8004201352:	48 01 c8             	add    %rcx,%rax
  8004201355:	48 8b 10             	mov    (%rax),%rdx
  8004201358:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420135f:	48 89 d6             	mov    %rdx,%rsi
  8004201362:	48 89 c7             	mov    %rax,%rdi
  8004201365:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420136c:	00 00 00 
  800420136f:	ff d0                	callq  *%rax
  8004201371:	85 c0                	test   %eax,%eax
  8004201373:	75 3e                	jne    80042013b3 <runcmd+0x1d5>
            return commands[i].func(argc, argv, tf);
  8004201375:	48 b9 80 25 22 04 80 	movabs $0x8004222580,%rcx
  800420137c:	00 00 00 
  800420137f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004201382:	48 63 d0             	movslq %eax,%rdx
  8004201385:	48 89 d0             	mov    %rdx,%rax
  8004201388:	48 01 c0             	add    %rax,%rax
  800420138b:	48 01 d0             	add    %rdx,%rax
  800420138e:	48 c1 e0 03          	shl    $0x3,%rax
  8004201392:	48 01 c8             	add    %rcx,%rax
  8004201395:	48 83 c0 10          	add    $0x10,%rax
  8004201399:	48 8b 00             	mov    (%rax),%rax
  800420139c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  80042013a3:	48 8d b5 70 ff ff ff 	lea    -0x90(%rbp),%rsi
  80042013aa:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  80042013ad:	89 cf                	mov    %ecx,%edi
  80042013af:	ff d0                	callq  *%rax
  80042013b1:	eb 3a                	jmp    80042013ed <runcmd+0x20f>
    argv[argc] = 0;

    // Lookup and invoke the command
    if (argc == 0)
        return 0;
    for (i = 0; i < NCOMMANDS; i++) {
  80042013b3:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  80042013b7:	8b 45 f8             	mov    -0x8(%rbp),%eax
  80042013ba:	83 f8 02             	cmp    $0x2,%eax
  80042013bd:	0f 86 72 ff ff ff    	jbe    8004201335 <runcmd+0x157>
        if (strcmp(argv[0], commands[i].name) == 0)
            return commands[i].func(argc, argv, tf);
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  80042013c3:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  80042013ca:	48 89 c6             	mov    %rax,%rsi
  80042013cd:	48 bf 12 e6 20 04 80 	movabs $0x800420e612,%rdi
  80042013d4:	00 00 00 
  80042013d7:	b8 00 00 00 00       	mov    $0x0,%eax
  80042013dc:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  80042013e3:	00 00 00 
  80042013e6:	ff d2                	callq  *%rdx
    return 0;
  80042013e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042013ed:	c9                   	leaveq 
  80042013ee:	c3                   	retq   

00000080042013ef <monitor>:

void
monitor(struct Trapframe *tf)
{
  80042013ef:	55                   	push   %rbp
  80042013f0:	48 89 e5             	mov    %rsp,%rbp
  80042013f3:	48 83 ec 20          	sub    $0x20,%rsp
  80042013f7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    char *buf;

    cprintf("Welcome to the JOS kernel monitor!\n");
  80042013fb:	48 bf 28 e6 20 04 80 	movabs $0x800420e628,%rdi
  8004201402:	00 00 00 
  8004201405:	b8 00 00 00 00       	mov    $0x0,%eax
  800420140a:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004201411:	00 00 00 
  8004201414:	ff d2                	callq  *%rdx
    cprintf("Type 'help' for a list of commands.\n");
  8004201416:	48 bf 50 e6 20 04 80 	movabs $0x800420e650,%rdi
  800420141d:	00 00 00 
  8004201420:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201425:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  800420142c:	00 00 00 
  800420142f:	ff d2                	callq  *%rdx


    while (1) {
        buf = readline("K> ");
  8004201431:	48 bf 75 e6 20 04 80 	movabs $0x800420e675,%rdi
  8004201438:	00 00 00 
  800420143b:	48 b8 4c 7b 20 04 80 	movabs $0x8004207b4c,%rax
  8004201442:	00 00 00 
  8004201445:	ff d0                	callq  *%rax
  8004201447:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        if (buf != NULL)
  800420144b:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004201450:	74 20                	je     8004201472 <monitor+0x83>
            if (runcmd(buf, tf) < 0)
  8004201452:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004201456:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420145a:	48 89 d6             	mov    %rdx,%rsi
  800420145d:	48 89 c7             	mov    %rax,%rdi
  8004201460:	48 b8 de 11 20 04 80 	movabs $0x80042011de,%rax
  8004201467:	00 00 00 
  800420146a:	ff d0                	callq  *%rax
  800420146c:	85 c0                	test   %eax,%eax
  800420146e:	79 02                	jns    8004201472 <monitor+0x83>
                break;
  8004201470:	eb 02                	jmp    8004201474 <monitor+0x85>
    }
  8004201472:	eb bd                	jmp    8004201431 <monitor+0x42>
}
  8004201474:	c9                   	leaveq 
  8004201475:	c3                   	retq   

0000008004201476 <page2ppn>:

void	tlb_invalidate(pml4e_t *pml4e, void *va);

static inline ppn_t
page2ppn(struct PageInfo *pp)
{
  8004201476:	55                   	push   %rbp
  8004201477:	48 89 e5             	mov    %rsp,%rbp
  800420147a:	48 83 ec 08          	sub    $0x8,%rsp
  800420147e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return pp - pages;
  8004201482:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004201486:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  800420148d:	00 00 00 
  8004201490:	48 8b 00             	mov    (%rax),%rax
  8004201493:	48 29 c2             	sub    %rax,%rdx
  8004201496:	48 89 d0             	mov    %rdx,%rax
  8004201499:	48 c1 f8 04          	sar    $0x4,%rax
}
  800420149d:	c9                   	leaveq 
  800420149e:	c3                   	retq   

000000800420149f <page2pa>:

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
  800420149f:	55                   	push   %rbp
  80042014a0:	48 89 e5             	mov    %rsp,%rbp
  80042014a3:	48 83 ec 08          	sub    $0x8,%rsp
  80042014a7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	return page2ppn(pp) << PGSHIFT;
  80042014ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042014af:	48 89 c7             	mov    %rax,%rdi
  80042014b2:	48 b8 76 14 20 04 80 	movabs $0x8004201476,%rax
  80042014b9:	00 00 00 
  80042014bc:	ff d0                	callq  *%rax
  80042014be:	48 c1 e0 0c          	shl    $0xc,%rax
}
  80042014c2:	c9                   	leaveq 
  80042014c3:	c3                   	retq   

00000080042014c4 <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
  80042014c4:	55                   	push   %rbp
  80042014c5:	48 89 e5             	mov    %rsp,%rbp
  80042014c8:	48 83 ec 10          	sub    $0x10,%rsp
  80042014cc:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	if (PPN(pa) >= npages)
  80042014d0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042014d4:	48 c1 e8 0c          	shr    $0xc,%rax
  80042014d8:	48 89 c2             	mov    %rax,%rdx
  80042014db:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042014e2:	00 00 00 
  80042014e5:	48 8b 00             	mov    (%rax),%rax
  80042014e8:	48 39 c2             	cmp    %rax,%rdx
  80042014eb:	72 2a                	jb     8004201517 <pa2page+0x53>
		panic("pa2page called with invalid pa");
  80042014ed:	48 ba 80 e6 20 04 80 	movabs $0x800420e680,%rdx
  80042014f4:	00 00 00 
  80042014f7:	be 4e 00 00 00       	mov    $0x4e,%esi
  80042014fc:	48 bf 9f e6 20 04 80 	movabs $0x800420e69f,%rdi
  8004201503:	00 00 00 
  8004201506:	b8 00 00 00 00       	mov    $0x0,%eax
  800420150b:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  8004201512:	00 00 00 
  8004201515:	ff d1                	callq  *%rcx
	return &pages[PPN(pa)];
  8004201517:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  800420151e:	00 00 00 
  8004201521:	48 8b 00             	mov    (%rax),%rax
  8004201524:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004201528:	48 c1 ea 0c          	shr    $0xc,%rdx
  800420152c:	48 c1 e2 04          	shl    $0x4,%rdx
  8004201530:	48 01 d0             	add    %rdx,%rax
}
  8004201533:	c9                   	leaveq 
  8004201534:	c3                   	retq   

0000008004201535 <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
  8004201535:	55                   	push   %rbp
  8004201536:	48 89 e5             	mov    %rsp,%rbp
  8004201539:	48 83 ec 20          	sub    $0x20,%rsp
  800420153d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	return KADDR(page2pa(pp));
  8004201541:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201545:	48 89 c7             	mov    %rax,%rdi
  8004201548:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420154f:	00 00 00 
  8004201552:	ff d0                	callq  *%rax
  8004201554:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004201558:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420155c:	48 c1 e8 0c          	shr    $0xc,%rax
  8004201560:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8004201563:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004201566:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420156d:	00 00 00 
  8004201570:	48 8b 00             	mov    (%rax),%rax
  8004201573:	48 39 c2             	cmp    %rax,%rdx
  8004201576:	72 32                	jb     80042015aa <page2kva+0x75>
  8004201578:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420157c:	48 89 c1             	mov    %rax,%rcx
  800420157f:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004201586:	00 00 00 
  8004201589:	be 55 00 00 00       	mov    $0x55,%esi
  800420158e:	48 bf 9f e6 20 04 80 	movabs $0x800420e69f,%rdi
  8004201595:	00 00 00 
  8004201598:	b8 00 00 00 00       	mov    $0x0,%eax
  800420159d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042015a4:	00 00 00 
  80042015a7:	41 ff d0             	callq  *%r8
  80042015aa:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042015b1:	00 00 00 
  80042015b4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042015b8:	48 01 d0             	add    %rdx,%rax
}
  80042015bb:	c9                   	leaveq 
  80042015bc:	c3                   	retq   

00000080042015bd <restrictive_type>:
   uint32_t length_low;
   uint32_t length_high;
   uint32_t type;
 } memory_map_t;

static __inline uint32_t restrictive_type(uint32_t t1, uint32_t t2) {
  80042015bd:	55                   	push   %rbp
  80042015be:	48 89 e5             	mov    %rsp,%rbp
  80042015c1:	48 83 ec 08          	sub    $0x8,%rsp
  80042015c5:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80042015c8:	89 75 f8             	mov    %esi,-0x8(%rbp)
  if(t1==MB_TYPE_BAD || t2==MB_TYPE_BAD)
  80042015cb:	83 7d fc 05          	cmpl   $0x5,-0x4(%rbp)
  80042015cf:	74 06                	je     80042015d7 <restrictive_type+0x1a>
  80042015d1:	83 7d f8 05          	cmpl   $0x5,-0x8(%rbp)
  80042015d5:	75 07                	jne    80042015de <restrictive_type+0x21>
    return MB_TYPE_BAD;
  80042015d7:	b8 05 00 00 00       	mov    $0x5,%eax
  80042015dc:	eb 3e                	jmp    800420161c <restrictive_type+0x5f>
  else if(t1==MB_TYPE_ACPI_NVS || t2==MB_TYPE_ACPI_NVS)
  80042015de:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  80042015e2:	74 06                	je     80042015ea <restrictive_type+0x2d>
  80042015e4:	83 7d f8 04          	cmpl   $0x4,-0x8(%rbp)
  80042015e8:	75 07                	jne    80042015f1 <restrictive_type+0x34>
    return MB_TYPE_ACPI_NVS;
  80042015ea:	b8 04 00 00 00       	mov    $0x4,%eax
  80042015ef:	eb 2b                	jmp    800420161c <restrictive_type+0x5f>
  else if(t1==MB_TYPE_RESERVED || t2==MB_TYPE_RESERVED)
  80042015f1:	83 7d fc 02          	cmpl   $0x2,-0x4(%rbp)
  80042015f5:	74 06                	je     80042015fd <restrictive_type+0x40>
  80042015f7:	83 7d f8 02          	cmpl   $0x2,-0x8(%rbp)
  80042015fb:	75 07                	jne    8004201604 <restrictive_type+0x47>
    return MB_TYPE_RESERVED;
  80042015fd:	b8 02 00 00 00       	mov    $0x2,%eax
  8004201602:	eb 18                	jmp    800420161c <restrictive_type+0x5f>
  else if(t1==MB_TYPE_ACPI_RECLM || t2==MB_TYPE_ACPI_RECLM)
  8004201604:	83 7d fc 03          	cmpl   $0x3,-0x4(%rbp)
  8004201608:	74 06                	je     8004201610 <restrictive_type+0x53>
  800420160a:	83 7d f8 03          	cmpl   $0x3,-0x8(%rbp)
  800420160e:	75 07                	jne    8004201617 <restrictive_type+0x5a>
    return MB_TYPE_ACPI_RECLM;
  8004201610:	b8 03 00 00 00       	mov    $0x3,%eax
  8004201615:	eb 05                	jmp    800420161c <restrictive_type+0x5f>

  return MB_TYPE_USABLE;
  8004201617:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800420161c:	c9                   	leaveq 
  800420161d:	c3                   	retq   

000000800420161e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
  800420161e:	55                   	push   %rbp
  800420161f:	48 89 e5             	mov    %rsp,%rbp
  8004201622:	53                   	push   %rbx
  8004201623:	48 83 ec 18          	sub    $0x18,%rsp
  8004201627:	89 7d ec             	mov    %edi,-0x14(%rbp)
    return mc146818_read(r) | (mc146818_read(r + 1) << 8);
  800420162a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420162d:	89 c7                	mov    %eax,%edi
  800420162f:	48 b8 47 63 20 04 80 	movabs $0x8004206347,%rax
  8004201636:	00 00 00 
  8004201639:	ff d0                	callq  *%rax
  800420163b:	89 c3                	mov    %eax,%ebx
  800420163d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201640:	83 c0 01             	add    $0x1,%eax
  8004201643:	89 c7                	mov    %eax,%edi
  8004201645:	48 b8 47 63 20 04 80 	movabs $0x8004206347,%rax
  800420164c:	00 00 00 
  800420164f:	ff d0                	callq  *%rax
  8004201651:	c1 e0 08             	shl    $0x8,%eax
  8004201654:	09 d8                	or     %ebx,%eax
}
  8004201656:	48 83 c4 18          	add    $0x18,%rsp
  800420165a:	5b                   	pop    %rbx
  800420165b:	5d                   	pop    %rbp
  800420165c:	c3                   	retq   

000000800420165d <multiboot_read>:

static void
multiboot_read(multiboot_info_t* mbinfo, size_t* basemem, size_t* extmem) {
  800420165d:	55                   	push   %rbp
  800420165e:	48 89 e5             	mov    %rsp,%rbp
  8004201661:	41 54                	push   %r12
  8004201663:	53                   	push   %rbx
  8004201664:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  800420166b:	48 89 bd 58 ff ff ff 	mov    %rdi,-0xa8(%rbp)
  8004201672:	48 89 b5 50 ff ff ff 	mov    %rsi,-0xb0(%rbp)
  8004201679:	48 89 95 48 ff ff ff 	mov    %rdx,-0xb8(%rbp)
  8004201680:	48 89 e0             	mov    %rsp,%rax
  8004201683:	49 89 c4             	mov    %rax,%r12
    int i;

    memory_map_t* mmap_base = (memory_map_t*)(uintptr_t)mbinfo->mmap_addr;
  8004201686:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  800420168d:	8b 40 30             	mov    0x30(%rax),%eax
  8004201690:	89 c0                	mov    %eax,%eax
  8004201692:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    memory_map_t* mmap_list[mbinfo->mmap_length/ (sizeof(memory_map_t))];
  8004201696:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  800420169d:	8b 40 2c             	mov    0x2c(%rax),%eax
  80042016a0:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
  80042016a5:	f7 e2                	mul    %edx
  80042016a7:	89 d0                	mov    %edx,%eax
  80042016a9:	c1 e8 04             	shr    $0x4,%eax
  80042016ac:	89 c0                	mov    %eax,%eax
  80042016ae:	48 89 c2             	mov    %rax,%rdx
  80042016b1:	48 83 ea 01          	sub    $0x1,%rdx
  80042016b5:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80042016b9:	49 89 c0             	mov    %rax,%r8
  80042016bc:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80042016c2:	48 89 c1             	mov    %rax,%rcx
  80042016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042016ca:	48 c1 e0 03          	shl    $0x3,%rax
  80042016ce:	48 8d 50 07          	lea    0x7(%rax),%rdx
  80042016d2:	b8 10 00 00 00       	mov    $0x10,%eax
  80042016d7:	48 83 e8 01          	sub    $0x1,%rax
  80042016db:	48 01 d0             	add    %rdx,%rax
  80042016de:	bb 10 00 00 00       	mov    $0x10,%ebx
  80042016e3:	ba 00 00 00 00       	mov    $0x0,%edx
  80042016e8:	48 f7 f3             	div    %rbx
  80042016eb:	48 6b c0 10          	imul   $0x10,%rax,%rax
  80042016ef:	48 29 c4             	sub    %rax,%rsp
  80042016f2:	48 89 e0             	mov    %rsp,%rax
  80042016f5:	48 83 c0 07          	add    $0x7,%rax
  80042016f9:	48 c1 e8 03          	shr    $0x3,%rax
  80042016fd:	48 c1 e0 03          	shl    $0x3,%rax
  8004201701:	48 89 45 c8          	mov    %rax,-0x38(%rbp)

    cprintf("\ne820 MEMORY MAP\n");
  8004201705:	48 bf d3 e6 20 04 80 	movabs $0x800420e6d3,%rdi
  800420170c:	00 00 00 
  800420170f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201714:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  800420171b:	00 00 00 
  800420171e:	ff d2                	callq  *%rdx
    for(i = 0; i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  8004201720:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  8004201727:	e9 6c 01 00 00       	jmpq   8004201898 <multiboot_read+0x23b>
        memory_map_t* mmap = &mmap_base[i];
  800420172c:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420172f:	48 63 d0             	movslq %eax,%rdx
  8004201732:	48 89 d0             	mov    %rdx,%rax
  8004201735:	48 01 c0             	add    %rax,%rax
  8004201738:	48 01 d0             	add    %rdx,%rax
  800420173b:	48 c1 e0 03          	shl    $0x3,%rax
  800420173f:	48 89 c2             	mov    %rax,%rdx
  8004201742:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004201746:	48 01 d0             	add    %rdx,%rax
  8004201749:	48 89 45 c0          	mov    %rax,-0x40(%rbp)

        uint64_t addr = APPEND_HILO(mmap->base_addr_high, mmap->base_addr_low);
  800420174d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201751:	8b 40 08             	mov    0x8(%rax),%eax
  8004201754:	89 c0                	mov    %eax,%eax
  8004201756:	48 c1 e0 20          	shl    $0x20,%rax
  800420175a:	48 89 c2             	mov    %rax,%rdx
  800420175d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201761:	8b 40 04             	mov    0x4(%rax),%eax
  8004201764:	89 c0                	mov    %eax,%eax
  8004201766:	48 01 d0             	add    %rdx,%rax
  8004201769:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
        uint64_t len = APPEND_HILO(mmap->length_high, mmap->length_low);
  800420176d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201771:	8b 40 10             	mov    0x10(%rax),%eax
  8004201774:	89 c0                	mov    %eax,%eax
  8004201776:	48 c1 e0 20          	shl    $0x20,%rax
  800420177a:	48 89 c2             	mov    %rax,%rdx
  800420177d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201781:	8b 40 0c             	mov    0xc(%rax),%eax
  8004201784:	89 c0                	mov    %eax,%eax
  8004201786:	48 01 d0             	add    %rdx,%rax
  8004201789:	48 89 45 b0          	mov    %rax,-0x50(%rbp)

        cprintf("size: %d, address: 0x%016x, length: 0x%016x, type: %x\n", mmap->size,
  800420178d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201791:	8b 70 14             	mov    0x14(%rax),%esi
  8004201794:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201798:	8b 00                	mov    (%rax),%eax
  800420179a:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  800420179e:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  80042017a2:	41 89 f0             	mov    %esi,%r8d
  80042017a5:	89 c6                	mov    %eax,%esi
  80042017a7:	48 bf e8 e6 20 04 80 	movabs $0x800420e6e8,%rdi
  80042017ae:	00 00 00 
  80042017b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042017b6:	49 b9 50 64 20 04 80 	movabs $0x8004206450,%r9
  80042017bd:	00 00 00 
  80042017c0:	41 ff d1             	callq  *%r9
                addr, len, mmap->type);

        if(mmap->type > 5 || mmap->type < 1)
  80042017c3:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042017c7:	8b 40 14             	mov    0x14(%rax),%eax
  80042017ca:	83 f8 05             	cmp    $0x5,%eax
  80042017cd:	77 0b                	ja     80042017da <multiboot_read+0x17d>
  80042017cf:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042017d3:	8b 40 14             	mov    0x14(%rax),%eax
  80042017d6:	85 c0                	test   %eax,%eax
  80042017d8:	75 0b                	jne    80042017e5 <multiboot_read+0x188>
            mmap->type = MB_TYPE_RESERVED;
  80042017da:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042017de:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%rax)

        //Insert into the sorted list
        int j = 0;
  80042017e5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
        for(;j<i;j++) {
  80042017ec:	e9 85 00 00 00       	jmpq   8004201876 <multiboot_read+0x219>
            memory_map_t* this = mmap_list[j];
  80042017f1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042017f5:	8b 55 e8             	mov    -0x18(%rbp),%edx
  80042017f8:	48 63 d2             	movslq %edx,%rdx
  80042017fb:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80042017ff:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            uint64_t this_addr = APPEND_HILO(this->base_addr_high, this->base_addr_low);
  8004201803:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004201807:	8b 40 08             	mov    0x8(%rax),%eax
  800420180a:	89 c0                	mov    %eax,%eax
  800420180c:	48 c1 e0 20          	shl    $0x20,%rax
  8004201810:	48 89 c2             	mov    %rax,%rdx
  8004201813:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004201817:	8b 40 04             	mov    0x4(%rax),%eax
  800420181a:	89 c0                	mov    %eax,%eax
  800420181c:	48 01 d0             	add    %rdx,%rax
  800420181f:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
            if(this_addr > addr) {
  8004201823:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004201827:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  800420182b:	76 45                	jbe    8004201872 <multiboot_read+0x215>
                int last = i+1;
  800420182d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201830:	83 c0 01             	add    $0x1,%eax
  8004201833:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                while(last != j) {
  8004201836:	eb 30                	jmp    8004201868 <multiboot_read+0x20b>
                    *(mmap_list + last) = *(mmap_list + last - 1);
  8004201838:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420183c:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  800420183f:	48 63 d2             	movslq %edx,%rdx
  8004201842:	48 c1 e2 03          	shl    $0x3,%rdx
  8004201846:	48 01 c2             	add    %rax,%rdx
  8004201849:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420184d:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  8004201850:	48 63 c9             	movslq %ecx,%rcx
  8004201853:	48 c1 e1 03          	shl    $0x3,%rcx
  8004201857:	48 83 e9 08          	sub    $0x8,%rcx
  800420185b:	48 01 c8             	add    %rcx,%rax
  800420185e:	48 8b 00             	mov    (%rax),%rax
  8004201861:	48 89 02             	mov    %rax,(%rdx)
                    last--;
  8004201864:	83 6d e4 01          	subl   $0x1,-0x1c(%rbp)
        for(;j<i;j++) {
            memory_map_t* this = mmap_list[j];
            uint64_t this_addr = APPEND_HILO(this->base_addr_high, this->base_addr_low);
            if(this_addr > addr) {
                int last = i+1;
                while(last != j) {
  8004201868:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420186b:	3b 45 e8             	cmp    -0x18(%rbp),%eax
  800420186e:	75 c8                	jne    8004201838 <multiboot_read+0x1db>
                    *(mmap_list + last) = *(mmap_list + last - 1);
                    last--;
                }
                break;
  8004201870:	eb 10                	jmp    8004201882 <multiboot_read+0x225>
        if(mmap->type > 5 || mmap->type < 1)
            mmap->type = MB_TYPE_RESERVED;

        //Insert into the sorted list
        int j = 0;
        for(;j<i;j++) {
  8004201872:	83 45 e8 01          	addl   $0x1,-0x18(%rbp)
  8004201876:	8b 45 e8             	mov    -0x18(%rbp),%eax
  8004201879:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420187c:	0f 8c 6f ff ff ff    	jl     80042017f1 <multiboot_read+0x194>
                    last--;
                }
                break;
            }
        }
        mmap_list[j] = mmap;
  8004201882:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004201886:	8b 55 e8             	mov    -0x18(%rbp),%edx
  8004201889:	48 63 d2             	movslq %edx,%rdx
  800420188c:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  8004201890:	48 89 0c d0          	mov    %rcx,(%rax,%rdx,8)

    memory_map_t* mmap_base = (memory_map_t*)(uintptr_t)mbinfo->mmap_addr;
    memory_map_t* mmap_list[mbinfo->mmap_length/ (sizeof(memory_map_t))];

    cprintf("\ne820 MEMORY MAP\n");
    for(i = 0; i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  8004201894:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  8004201898:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420189b:	48 63 c8             	movslq %eax,%rcx
  800420189e:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80042018a5:	8b 40 2c             	mov    0x2c(%rax),%eax
  80042018a8:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
  80042018ad:	f7 e2                	mul    %edx
  80042018af:	89 d0                	mov    %edx,%eax
  80042018b1:	c1 e8 04             	shr    $0x4,%eax
  80042018b4:	89 c0                	mov    %eax,%eax
  80042018b6:	48 39 c1             	cmp    %rax,%rcx
  80042018b9:	0f 82 6d fe ff ff    	jb     800420172c <multiboot_read+0xcf>
                break;
            }
        }
        mmap_list[j] = mmap;
    }
    cprintf("\n");
  80042018bf:	48 bf 1f e7 20 04 80 	movabs $0x800420e71f,%rdi
  80042018c6:	00 00 00 
  80042018c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80042018ce:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  80042018d5:	00 00 00 
  80042018d8:	ff d2                	callq  *%rdx

    // Sanitize the list
    for(i=1;i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  80042018da:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%rbp)
  80042018e1:	e9 93 01 00 00       	jmpq   8004201a79 <multiboot_read+0x41c>
        memory_map_t* prev = mmap_list[i-1];
  80042018e6:	8b 45 ec             	mov    -0x14(%rbp),%eax
  80042018e9:	8d 50 ff             	lea    -0x1(%rax),%edx
  80042018ec:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042018f0:	48 63 d2             	movslq %edx,%rdx
  80042018f3:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  80042018f7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
        memory_map_t* this = mmap_list[i];
  80042018fb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042018ff:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8004201902:	48 63 d2             	movslq %edx,%rdx
  8004201905:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8004201909:	48 89 45 90          	mov    %rax,-0x70(%rbp)

        uint64_t this_addr = APPEND_HILO(this->base_addr_high, this->base_addr_low);
  800420190d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201911:	8b 40 08             	mov    0x8(%rax),%eax
  8004201914:	89 c0                	mov    %eax,%eax
  8004201916:	48 c1 e0 20          	shl    $0x20,%rax
  800420191a:	48 89 c2             	mov    %rax,%rdx
  800420191d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201921:	8b 40 04             	mov    0x4(%rax),%eax
  8004201924:	89 c0                	mov    %eax,%eax
  8004201926:	48 01 d0             	add    %rdx,%rax
  8004201929:	48 89 45 88          	mov    %rax,-0x78(%rbp)
        uint64_t prev_addr = APPEND_HILO(prev->base_addr_high, prev->base_addr_low);
  800420192d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201931:	8b 40 08             	mov    0x8(%rax),%eax
  8004201934:	89 c0                	mov    %eax,%eax
  8004201936:	48 c1 e0 20          	shl    $0x20,%rax
  800420193a:	48 89 c2             	mov    %rax,%rdx
  800420193d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201941:	8b 40 04             	mov    0x4(%rax),%eax
  8004201944:	89 c0                	mov    %eax,%eax
  8004201946:	48 01 d0             	add    %rdx,%rax
  8004201949:	48 89 45 80          	mov    %rax,-0x80(%rbp)
        uint64_t prev_length = APPEND_HILO(prev->length_high, prev->length_low);
  800420194d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201951:	8b 40 10             	mov    0x10(%rax),%eax
  8004201954:	89 c0                	mov    %eax,%eax
  8004201956:	48 c1 e0 20          	shl    $0x20,%rax
  800420195a:	48 89 c2             	mov    %rax,%rdx
  800420195d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201961:	8b 40 0c             	mov    0xc(%rax),%eax
  8004201964:	89 c0                	mov    %eax,%eax
  8004201966:	48 01 d0             	add    %rdx,%rax
  8004201969:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
        uint64_t this_length = APPEND_HILO(this->length_high, this->length_low);
  8004201970:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201974:	8b 40 10             	mov    0x10(%rax),%eax
  8004201977:	89 c0                	mov    %eax,%eax
  8004201979:	48 c1 e0 20          	shl    $0x20,%rax
  800420197d:	48 89 c2             	mov    %rax,%rdx
  8004201980:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201984:	8b 40 0c             	mov    0xc(%rax),%eax
  8004201987:	89 c0                	mov    %eax,%eax
  8004201989:	48 01 d0             	add    %rdx,%rax
  800420198c:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)

        // Merge adjacent regions with same type
        if(prev_addr + prev_length == this_addr && prev->type == this->type) {
  8004201993:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420199a:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  800420199e:	48 01 d0             	add    %rdx,%rax
  80042019a1:	48 3b 45 88          	cmp    -0x78(%rbp),%rax
  80042019a5:	75 7c                	jne    8004201a23 <multiboot_read+0x3c6>
  80042019a7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042019ab:	8b 50 14             	mov    0x14(%rax),%edx
  80042019ae:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042019b2:	8b 40 14             	mov    0x14(%rax),%eax
  80042019b5:	39 c2                	cmp    %eax,%edx
  80042019b7:	75 6a                	jne    8004201a23 <multiboot_read+0x3c6>
            this->length_low = (uint32_t)prev_length + this_length;
  80042019b9:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  80042019c0:	89 c2                	mov    %eax,%edx
  80042019c2:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  80042019c9:	01 c2                	add    %eax,%edx
  80042019cb:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042019cf:	89 50 0c             	mov    %edx,0xc(%rax)
            this->length_high = (uint32_t)((prev_length + this_length)>>32);
  80042019d2:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  80042019d9:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  80042019e0:	48 01 d0             	add    %rdx,%rax
  80042019e3:	48 c1 e8 20          	shr    $0x20,%rax
  80042019e7:	89 c2                	mov    %eax,%edx
  80042019e9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042019ed:	89 50 10             	mov    %edx,0x10(%rax)
            this->base_addr_low = prev->base_addr_low;
  80042019f0:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042019f4:	8b 50 04             	mov    0x4(%rax),%edx
  80042019f7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042019fb:	89 50 04             	mov    %edx,0x4(%rax)
            this->base_addr_high = prev->base_addr_high;
  80042019fe:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201a02:	8b 50 08             	mov    0x8(%rax),%edx
  8004201a05:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201a09:	89 50 08             	mov    %edx,0x8(%rax)
            mmap_list[i-1] = NULL;
  8004201a0c:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201a0f:	8d 50 ff             	lea    -0x1(%rax),%edx
  8004201a12:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004201a16:	48 63 d2             	movslq %edx,%rdx
  8004201a19:	48 c7 04 d0 00 00 00 	movq   $0x0,(%rax,%rdx,8)
  8004201a20:	00 
  8004201a21:	eb 52                	jmp    8004201a75 <multiboot_read+0x418>
        } else if(prev_addr + prev_length > this_addr) {
  8004201a23:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004201a2a:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  8004201a2e:	48 01 d0             	add    %rdx,%rax
  8004201a31:	48 3b 45 88          	cmp    -0x78(%rbp),%rax
  8004201a35:	76 3e                	jbe    8004201a75 <multiboot_read+0x418>
            //Overlapping regions
            uint32_t type = restrictive_type(prev->type, this->type);
  8004201a37:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201a3b:	8b 50 14             	mov    0x14(%rax),%edx
  8004201a3e:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201a42:	8b 40 14             	mov    0x14(%rax),%eax
  8004201a45:	89 d6                	mov    %edx,%esi
  8004201a47:	89 c7                	mov    %eax,%edi
  8004201a49:	48 b8 bd 15 20 04 80 	movabs $0x80042015bd,%rax
  8004201a50:	00 00 00 
  8004201a53:	ff d0                	callq  *%rax
  8004201a55:	89 85 6c ff ff ff    	mov    %eax,-0x94(%rbp)
            prev->type = type;
  8004201a5b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004201a5f:	8b 95 6c ff ff ff    	mov    -0x94(%rbp),%edx
  8004201a65:	89 50 14             	mov    %edx,0x14(%rax)
            this->type = type;
  8004201a68:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  8004201a6c:	8b 95 6c ff ff ff    	mov    -0x94(%rbp),%edx
  8004201a72:	89 50 14             	mov    %edx,0x14(%rax)
        mmap_list[j] = mmap;
    }
    cprintf("\n");

    // Sanitize the list
    for(i=1;i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  8004201a75:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  8004201a79:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201a7c:	48 63 c8             	movslq %eax,%rcx
  8004201a7f:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004201a86:	8b 40 2c             	mov    0x2c(%rax),%eax
  8004201a89:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
  8004201a8e:	f7 e2                	mul    %edx
  8004201a90:	89 d0                	mov    %edx,%eax
  8004201a92:	c1 e8 04             	shr    $0x4,%eax
  8004201a95:	89 c0                	mov    %eax,%eax
  8004201a97:	48 39 c1             	cmp    %rax,%rcx
  8004201a9a:	0f 82 46 fe ff ff    	jb     80042018e6 <multiboot_read+0x289>
            prev->type = type;
            this->type = type;
        }
    }

    for(i=0;i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  8004201aa0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  8004201aa7:	e9 dc 00 00 00       	jmpq   8004201b88 <multiboot_read+0x52b>
        memory_map_t* mmap = mmap_list[i];
  8004201aac:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004201ab0:	8b 55 ec             	mov    -0x14(%rbp),%edx
  8004201ab3:	48 63 d2             	movslq %edx,%rdx
  8004201ab6:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
  8004201aba:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
        if(mmap) {
  8004201ac1:	48 83 bd 60 ff ff ff 	cmpq   $0x0,-0xa0(%rbp)
  8004201ac8:	00 
  8004201ac9:	0f 84 b5 00 00 00    	je     8004201b84 <multiboot_read+0x527>
            if(mmap->type == MB_TYPE_USABLE || mmap->type == MB_TYPE_ACPI_RECLM) {
  8004201acf:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201ad6:	8b 40 14             	mov    0x14(%rax),%eax
  8004201ad9:	83 f8 01             	cmp    $0x1,%eax
  8004201adc:	74 13                	je     8004201af1 <multiboot_read+0x494>
  8004201ade:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201ae5:	8b 40 14             	mov    0x14(%rax),%eax
  8004201ae8:	83 f8 03             	cmp    $0x3,%eax
  8004201aeb:	0f 85 93 00 00 00    	jne    8004201b84 <multiboot_read+0x527>
                if(mmap->base_addr_low < 0x100000 && mmap->base_addr_high == 0)
  8004201af1:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201af8:	8b 40 04             	mov    0x4(%rax),%eax
  8004201afb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8004201b00:	77 49                	ja     8004201b4b <multiboot_read+0x4ee>
  8004201b02:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201b09:	8b 40 08             	mov    0x8(%rax),%eax
  8004201b0c:	85 c0                	test   %eax,%eax
  8004201b0e:	75 3b                	jne    8004201b4b <multiboot_read+0x4ee>
                    *basemem += APPEND_HILO(mmap->length_high, mmap->length_low);
  8004201b10:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004201b17:	48 8b 10             	mov    (%rax),%rdx
  8004201b1a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201b21:	8b 40 10             	mov    0x10(%rax),%eax
  8004201b24:	89 c0                	mov    %eax,%eax
  8004201b26:	48 c1 e0 20          	shl    $0x20,%rax
  8004201b2a:	48 89 c1             	mov    %rax,%rcx
  8004201b2d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201b34:	8b 40 0c             	mov    0xc(%rax),%eax
  8004201b37:	89 c0                	mov    %eax,%eax
  8004201b39:	48 01 c8             	add    %rcx,%rax
  8004201b3c:	48 01 c2             	add    %rax,%rdx
  8004201b3f:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004201b46:	48 89 10             	mov    %rdx,(%rax)
  8004201b49:	eb 39                	jmp    8004201b84 <multiboot_read+0x527>
                else
                    *extmem += APPEND_HILO(mmap->length_high, mmap->length_low);
  8004201b4b:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004201b52:	48 8b 10             	mov    (%rax),%rdx
  8004201b55:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201b5c:	8b 40 10             	mov    0x10(%rax),%eax
  8004201b5f:	89 c0                	mov    %eax,%eax
  8004201b61:	48 c1 e0 20          	shl    $0x20,%rax
  8004201b65:	48 89 c1             	mov    %rax,%rcx
  8004201b68:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004201b6f:	8b 40 0c             	mov    0xc(%rax),%eax
  8004201b72:	89 c0                	mov    %eax,%eax
  8004201b74:	48 01 c8             	add    %rcx,%rax
  8004201b77:	48 01 c2             	add    %rax,%rdx
  8004201b7a:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004201b81:	48 89 10             	mov    %rdx,(%rax)
            prev->type = type;
            this->type = type;
        }
    }

    for(i=0;i < (mbinfo->mmap_length / (sizeof(memory_map_t))); i++) {
  8004201b84:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  8004201b88:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004201b8b:	48 63 c8             	movslq %eax,%rcx
  8004201b8e:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004201b95:	8b 40 2c             	mov    0x2c(%rax),%eax
  8004201b98:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
  8004201b9d:	f7 e2                	mul    %edx
  8004201b9f:	89 d0                	mov    %edx,%eax
  8004201ba1:	c1 e8 04             	shr    $0x4,%eax
  8004201ba4:	89 c0                	mov    %eax,%eax
  8004201ba6:	48 39 c1             	cmp    %rax,%rcx
  8004201ba9:	0f 82 fd fe ff ff    	jb     8004201aac <multiboot_read+0x44f>
  8004201baf:	4c 89 e4             	mov    %r12,%rsp
                else
                    *extmem += APPEND_HILO(mmap->length_high, mmap->length_low);
            }
        }
    }
}
  8004201bb2:	48 8d 65 f0          	lea    -0x10(%rbp),%rsp
  8004201bb6:	5b                   	pop    %rbx
  8004201bb7:	41 5c                	pop    %r12
  8004201bb9:	5d                   	pop    %rbp
  8004201bba:	c3                   	retq   

0000008004201bbb <i386_detect_memory>:

static void
i386_detect_memory(void)
{
  8004201bbb:	55                   	push   %rbp
  8004201bbc:	48 89 e5             	mov    %rsp,%rbp
  8004201bbf:	48 83 ec 50          	sub    $0x50,%rsp
    size_t npages_extmem;
    size_t basemem = 0;
  8004201bc3:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8004201bca:	00 
    size_t extmem = 0;
  8004201bcb:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8004201bd2:	00 

    // Check if the bootloader passed us a multiboot structure
    extern char multiboot_info[];
    uintptr_t* mbp = (uintptr_t*)multiboot_info;
  8004201bd3:	48 b8 00 70 10 00 00 	movabs $0x107000,%rax
  8004201bda:	00 00 00 
  8004201bdd:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    multiboot_info_t * mbinfo = (multiboot_info_t*)*mbp;
  8004201be1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004201be5:	48 8b 00             	mov    (%rax),%rax
  8004201be8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

    if(mbinfo && (mbinfo->flags & MB_FLAG_MMAP)) {
  8004201bec:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004201bf1:	74 2d                	je     8004201c20 <i386_detect_memory+0x65>
  8004201bf3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201bf7:	8b 00                	mov    (%rax),%eax
  8004201bf9:	83 e0 40             	and    $0x40,%eax
  8004201bfc:	85 c0                	test   %eax,%eax
  8004201bfe:	74 20                	je     8004201c20 <i386_detect_memory+0x65>
        multiboot_read(mbinfo, &basemem, &extmem);
  8004201c00:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
  8004201c04:	48 8d 4d c0          	lea    -0x40(%rbp),%rcx
  8004201c08:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004201c0c:	48 89 ce             	mov    %rcx,%rsi
  8004201c0f:	48 89 c7             	mov    %rax,%rdi
  8004201c12:	48 b8 5d 16 20 04 80 	movabs $0x800420165d,%rax
  8004201c19:	00 00 00 
  8004201c1c:	ff d0                	callq  *%rax
  8004201c1e:	eb 34                	jmp    8004201c54 <i386_detect_memory+0x99>
    } else {
        basemem = (nvram_read(NVRAM_BASELO) * 1024);
  8004201c20:	bf 15 00 00 00       	mov    $0x15,%edi
  8004201c25:	48 b8 1e 16 20 04 80 	movabs $0x800420161e,%rax
  8004201c2c:	00 00 00 
  8004201c2f:	ff d0                	callq  *%rax
  8004201c31:	c1 e0 0a             	shl    $0xa,%eax
  8004201c34:	48 98                	cltq   
  8004201c36:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
        extmem = (nvram_read(NVRAM_EXTLO) * 1024);
  8004201c3a:	bf 17 00 00 00       	mov    $0x17,%edi
  8004201c3f:	48 b8 1e 16 20 04 80 	movabs $0x800420161e,%rax
  8004201c46:	00 00 00 
  8004201c49:	ff d0                	callq  *%rax
  8004201c4b:	c1 e0 0a             	shl    $0xa,%eax
  8004201c4e:	48 98                	cltq   
  8004201c50:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    }

    assert(basemem);
  8004201c54:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201c58:	48 85 c0             	test   %rax,%rax
  8004201c5b:	75 35                	jne    8004201c92 <i386_detect_memory+0xd7>
  8004201c5d:	48 b9 21 e7 20 04 80 	movabs $0x800420e721,%rcx
  8004201c64:	00 00 00 
  8004201c67:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004201c6e:	00 00 00 
  8004201c71:	be 84 00 00 00       	mov    $0x84,%esi
  8004201c76:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004201c7d:	00 00 00 
  8004201c80:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201c85:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004201c8c:	00 00 00 
  8004201c8f:	41 ff d0             	callq  *%r8

    npages_basemem = basemem / PGSIZE;
  8004201c92:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004201c96:	48 c1 e8 0c          	shr    $0xc,%rax
  8004201c9a:	48 89 c2             	mov    %rax,%rdx
  8004201c9d:	48 b8 d0 28 22 04 80 	movabs $0x80042228d0,%rax
  8004201ca4:	00 00 00 
  8004201ca7:	48 89 10             	mov    %rdx,(%rax)
    npages_extmem = extmem / PGSIZE;
  8004201caa:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004201cae:	48 c1 e8 0c          	shr    $0xc,%rax
  8004201cb2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

    if(nvram_read(NVRAM_EXTLO) == 0xffff) {
  8004201cb6:	bf 17 00 00 00       	mov    $0x17,%edi
  8004201cbb:	48 b8 1e 16 20 04 80 	movabs $0x800420161e,%rax
  8004201cc2:	00 00 00 
  8004201cc5:	ff d0                	callq  *%rax
  8004201cc7:	3d ff ff 00 00       	cmp    $0xffff,%eax
  8004201ccc:	75 2c                	jne    8004201cfa <i386_detect_memory+0x13f>
        // EXTMEM > 16M in blocks of 64k
        size_t pextmem = nvram_read(NVRAM_EXTGT16LO) * (64 * 1024);
  8004201cce:	bf 34 00 00 00       	mov    $0x34,%edi
  8004201cd3:	48 b8 1e 16 20 04 80 	movabs $0x800420161e,%rax
  8004201cda:	00 00 00 
  8004201cdd:	ff d0                	callq  *%rax
  8004201cdf:	c1 e0 10             	shl    $0x10,%eax
  8004201ce2:	48 98                	cltq   
  8004201ce4:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
        npages_extmem = ((16 * 1024 * 1024) + pextmem - (1 * 1024 * 1024)) / PGSIZE;
  8004201ce8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004201cec:	48 05 00 00 f0 00    	add    $0xf00000,%rax
  8004201cf2:	48 c1 e8 0c          	shr    $0xc,%rax
  8004201cf6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    }

    // Calculate the number of physical pages available in both base
    // and extended memory.
    if (npages_extmem)
  8004201cfa:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004201cff:	74 1a                	je     8004201d1b <i386_detect_memory+0x160>
        npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
  8004201d01:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201d05:	48 8d 90 00 01 00 00 	lea    0x100(%rax),%rdx
  8004201d0c:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201d13:	00 00 00 
  8004201d16:	48 89 10             	mov    %rdx,(%rax)
  8004201d19:	eb 1a                	jmp    8004201d35 <i386_detect_memory+0x17a>
    else
        npages = npages_basemem;
  8004201d1b:	48 b8 d0 28 22 04 80 	movabs $0x80042228d0,%rax
  8004201d22:	00 00 00 
  8004201d25:	48 8b 10             	mov    (%rax),%rdx
  8004201d28:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201d2f:	00 00 00 
  8004201d32:	48 89 10             	mov    %rdx,(%rax)

    cprintf("Physical memory: %uM available, base = %uK, extended = %uK, npages = %d\n",
  8004201d35:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201d3c:	00 00 00 
  8004201d3f:	48 8b 30             	mov    (%rax),%rsi
            npages * PGSIZE / (1024 * 1024),
            npages_basemem * PGSIZE / 1024,
            npages_extmem * PGSIZE / 1024,
  8004201d42:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201d46:	48 c1 e0 0c          	shl    $0xc,%rax
    if (npages_extmem)
        npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
    else
        npages = npages_basemem;

    cprintf("Physical memory: %uM available, base = %uK, extended = %uK, npages = %d\n",
  8004201d4a:	48 c1 e8 0a          	shr    $0xa,%rax
  8004201d4e:	48 89 c1             	mov    %rax,%rcx
            npages * PGSIZE / (1024 * 1024),
            npages_basemem * PGSIZE / 1024,
  8004201d51:	48 b8 d0 28 22 04 80 	movabs $0x80042228d0,%rax
  8004201d58:	00 00 00 
  8004201d5b:	48 8b 00             	mov    (%rax),%rax
  8004201d5e:	48 c1 e0 0c          	shl    $0xc,%rax
    if (npages_extmem)
        npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
    else
        npages = npages_basemem;

    cprintf("Physical memory: %uM available, base = %uK, extended = %uK, npages = %d\n",
  8004201d62:	48 c1 e8 0a          	shr    $0xa,%rax
  8004201d66:	48 89 c2             	mov    %rax,%rdx
            npages * PGSIZE / (1024 * 1024),
  8004201d69:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201d70:	00 00 00 
  8004201d73:	48 8b 00             	mov    (%rax),%rax
  8004201d76:	48 c1 e0 0c          	shl    $0xc,%rax
    if (npages_extmem)
        npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
    else
        npages = npages_basemem;

    cprintf("Physical memory: %uM available, base = %uK, extended = %uK, npages = %d\n",
  8004201d7a:	48 c1 e8 14          	shr    $0x14,%rax
  8004201d7e:	49 89 f0             	mov    %rsi,%r8
  8004201d81:	48 89 c6             	mov    %rax,%rsi
  8004201d84:	48 bf 50 e7 20 04 80 	movabs $0x800420e750,%rdi
  8004201d8b:	00 00 00 
  8004201d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201d93:	49 b9 50 64 20 04 80 	movabs $0x8004206450,%r9
  8004201d9a:	00 00 00 
  8004201d9d:	41 ff d1             	callq  *%r9
    //JOS 64 pages are limited by the size of both the UPAGES
    //  virtual address space, and the range from KERNBASE to UVPT.
    //
    // NB: qemu seems to have a bug that crashes the host system on 13.10 if you try to
    //     max out memory.
    uint64_t upages_max = (ULIM - UPAGES) / sizeof(struct PageInfo);
  8004201da0:	48 c7 45 d8 00 00 32 	movq   $0x320000,-0x28(%rbp)
  8004201da7:	00 
    uint64_t kern_mem_max = (UVPT - KERNBASE) / PGSIZE;
  8004201da8:	48 c7 45 d0 00 c0 ff 	movq   $0x7ffc000,-0x30(%rbp)
  8004201daf:	07 
    cprintf("Pages limited to %llu by upage address range (%uMB), Pages limited to %llu by remapped phys mem (%uMB)\n",
            upages_max, ((upages_max * PGSIZE) / (1024 * 1024)),
            kern_mem_max, kern_mem_max * PGSIZE / (1024 * 1024));
  8004201db0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004201db4:	48 c1 e0 0c          	shl    $0xc,%rax
    //
    // NB: qemu seems to have a bug that crashes the host system on 13.10 if you try to
    //     max out memory.
    uint64_t upages_max = (ULIM - UPAGES) / sizeof(struct PageInfo);
    uint64_t kern_mem_max = (UVPT - KERNBASE) / PGSIZE;
    cprintf("Pages limited to %llu by upage address range (%uMB), Pages limited to %llu by remapped phys mem (%uMB)\n",
  8004201db8:	48 c1 e8 14          	shr    $0x14,%rax
  8004201dbc:	48 89 c1             	mov    %rax,%rcx
            upages_max, ((upages_max * PGSIZE) / (1024 * 1024)),
  8004201dbf:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004201dc3:	48 c1 e0 0c          	shl    $0xc,%rax
    //
    // NB: qemu seems to have a bug that crashes the host system on 13.10 if you try to
    //     max out memory.
    uint64_t upages_max = (ULIM - UPAGES) / sizeof(struct PageInfo);
    uint64_t kern_mem_max = (UVPT - KERNBASE) / PGSIZE;
    cprintf("Pages limited to %llu by upage address range (%uMB), Pages limited to %llu by remapped phys mem (%uMB)\n",
  8004201dc7:	48 c1 e8 14          	shr    $0x14,%rax
  8004201dcb:	48 89 c6             	mov    %rax,%rsi
  8004201dce:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004201dd2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004201dd6:	49 89 c8             	mov    %rcx,%r8
  8004201dd9:	48 89 d1             	mov    %rdx,%rcx
  8004201ddc:	48 89 f2             	mov    %rsi,%rdx
  8004201ddf:	48 89 c6             	mov    %rax,%rsi
  8004201de2:	48 bf a0 e7 20 04 80 	movabs $0x800420e7a0,%rdi
  8004201de9:	00 00 00 
  8004201dec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201df1:	49 b9 50 64 20 04 80 	movabs $0x8004206450,%r9
  8004201df8:	00 00 00 
  8004201dfb:	41 ff d1             	callq  *%r9
            upages_max, ((upages_max * PGSIZE) / (1024 * 1024)),
            kern_mem_max, kern_mem_max * PGSIZE / (1024 * 1024));
    uint64_t max_npages = upages_max < kern_mem_max ? upages_max : kern_mem_max;
  8004201dfe:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004201e02:	48 39 45 d0          	cmp    %rax,-0x30(%rbp)
  8004201e06:	48 0f 46 45 d0       	cmovbe -0x30(%rbp),%rax
  8004201e0b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)

    if(npages > max_npages) {
  8004201e0f:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201e16:	00 00 00 
  8004201e19:	48 8b 00             	mov    (%rax),%rax
  8004201e1c:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004201e20:	76 3a                	jbe    8004201e5c <i386_detect_memory+0x2a1>
        npages = max_npages - 1024;
  8004201e22:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004201e26:	48 8d 90 00 fc ff ff 	lea    -0x400(%rax),%rdx
  8004201e2d:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201e34:	00 00 00 
  8004201e37:	48 89 10             	mov    %rdx,(%rax)
        cprintf("Using only %uK of the available memory.\n", max_npages);
  8004201e3a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004201e3e:	48 89 c6             	mov    %rax,%rsi
  8004201e41:	48 bf 08 e8 20 04 80 	movabs $0x800420e808,%rdi
  8004201e48:	00 00 00 
  8004201e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201e50:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004201e57:	00 00 00 
  8004201e5a:	ff d2                	callq  *%rdx
    }
}
  8004201e5c:	c9                   	leaveq 
  8004201e5d:	c3                   	retq   

0000008004201e5e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
  8004201e5e:	55                   	push   %rbp
  8004201e5f:	48 89 e5             	mov    %rsp,%rbp
  8004201e62:	48 83 ec 40          	sub    $0x40,%rsp
  8004201e66:	89 7d cc             	mov    %edi,-0x34(%rbp)
    static char *nextfree;	// virtual address of next byte of free memory
    char *result;

    if (!nextfree) {
  8004201e69:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201e70:	00 00 00 
  8004201e73:	48 8b 00             	mov    (%rax),%rax
  8004201e76:	48 85 c0             	test   %rax,%rax
  8004201e79:	75 4b                	jne    8004201ec6 <boot_alloc+0x68>
        extern char end[];
        nextfree = ROUNDUP((char *) end, PGSIZE);
  8004201e7b:	48 c7 45 f8 00 10 00 	movq   $0x1000,-0x8(%rbp)
  8004201e82:	00 
  8004201e83:	48 b8 80 3d 22 04 80 	movabs $0x8004223d80,%rax
  8004201e8a:	00 00 00 
  8004201e8d:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8004201e91:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201e95:	48 01 d0             	add    %rdx,%rax
  8004201e98:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8004201e9c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004201ea0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004201ea5:	48 f7 75 f8          	divq   -0x8(%rbp)
  8004201ea9:	48 89 d0             	mov    %rdx,%rax
  8004201eac:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004201eb0:	48 29 c2             	sub    %rax,%rdx
  8004201eb3:	48 89 d0             	mov    %rdx,%rax
  8004201eb6:	48 89 c2             	mov    %rax,%rdx
  8004201eb9:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201ec0:	00 00 00 
  8004201ec3:	48 89 10             	mov    %rdx,(%rax)
    }
    result = nextfree;
  8004201ec6:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201ecd:	00 00 00 
  8004201ed0:	48 8b 00             	mov    (%rax),%rax
  8004201ed3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

    if (n > 0) {
  8004201ed7:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  8004201edb:	0f 84 ad 00 00 00    	je     8004201f8e <boot_alloc+0x130>
        nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
  8004201ee1:	48 c7 45 e0 00 10 00 	movq   $0x1000,-0x20(%rbp)
  8004201ee8:	00 
  8004201ee9:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201ef0:	00 00 00 
  8004201ef3:	48 8b 10             	mov    (%rax),%rdx
  8004201ef6:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004201ef9:	48 01 d0             	add    %rdx,%rax
  8004201efc:	48 89 c2             	mov    %rax,%rdx
  8004201eff:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004201f03:	48 01 d0             	add    %rdx,%rax
  8004201f06:	48 83 e8 01          	sub    $0x1,%rax
  8004201f0a:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  8004201f0e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004201f12:	ba 00 00 00 00       	mov    $0x0,%edx
  8004201f17:	48 f7 75 e0          	divq   -0x20(%rbp)
  8004201f1b:	48 89 d0             	mov    %rdx,%rax
  8004201f1e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004201f22:	48 29 c2             	sub    %rax,%rdx
  8004201f25:	48 89 d0             	mov    %rdx,%rax
  8004201f28:	48 89 c2             	mov    %rax,%rdx
  8004201f2b:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201f32:	00 00 00 
  8004201f35:	48 89 10             	mov    %rdx,(%rax)
        if ((uint64_t) nextfree > KERNBASE + (npages * PGSIZE)) {
  8004201f38:	48 b8 e0 28 22 04 80 	movabs $0x80042228e0,%rax
  8004201f3f:	00 00 00 
  8004201f42:	48 8b 00             	mov    (%rax),%rax
  8004201f45:	48 89 c2             	mov    %rax,%rdx
  8004201f48:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004201f4f:	00 00 00 
  8004201f52:	48 8b 00             	mov    (%rax),%rax
  8004201f55:	48 05 00 40 00 08    	add    $0x8004000,%rax
  8004201f5b:	48 c1 e0 0c          	shl    $0xc,%rax
  8004201f5f:	48 39 c2             	cmp    %rax,%rdx
  8004201f62:	76 2a                	jbe    8004201f8e <boot_alloc+0x130>
            panic("boot alloc error: out of memory\n");
  8004201f64:	48 ba 38 e8 20 04 80 	movabs $0x800420e838,%rdx
  8004201f6b:	00 00 00 
  8004201f6e:	be d5 00 00 00       	mov    $0xd5,%esi
  8004201f73:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004201f7a:	00 00 00 
  8004201f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004201f82:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  8004201f89:	00 00 00 
  8004201f8c:	ff d1                	callq  *%rcx
        }
    }

    return result;
  8004201f8e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004201f92:	c9                   	leaveq 
  8004201f93:	c3                   	retq   

0000008004201f94 <x64_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
x64_vm_init(void)
{
  8004201f94:	55                   	push   %rbp
  8004201f95:	48 89 e5             	mov    %rsp,%rbp
  8004201f98:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
    pml4e_t* pml4e;
    uint32_t cr0;
    uint64_t n;
    int r;
    struct Env *env;
    i386_detect_memory();
  8004201f9c:	48 b8 bb 1b 20 04 80 	movabs $0x8004201bbb,%rax
  8004201fa3:	00 00 00 
  8004201fa6:	ff d0                	callq  *%rax
    //////////////////////////////////////////////////////////////////////
    // create initial page directory.
    // panic("x64_vm_init: this function is not finished\n");
    pml4e = boot_alloc(PGSIZE);
  8004201fa8:	bf 00 10 00 00       	mov    $0x1000,%edi
  8004201fad:	48 b8 5e 1e 20 04 80 	movabs $0x8004201e5e,%rax
  8004201fb4:	00 00 00 
  8004201fb7:	ff d0                	callq  *%rax
  8004201fb9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    memset(pml4e, 0, PGSIZE);
  8004201fbd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201fc1:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004201fc6:	be 00 00 00 00       	mov    $0x0,%esi
  8004201fcb:	48 89 c7             	mov    %rax,%rdi
  8004201fce:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004201fd5:	00 00 00 
  8004201fd8:	ff d0                	callq  *%rax
    boot_pml4e = pml4e;
  8004201fda:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004201fe1:	00 00 00 
  8004201fe4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004201fe8:	48 89 10             	mov    %rdx,(%rax)
    boot_cr3 = PADDR(pml4e);
  8004201feb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004201fef:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  8004201ff3:	48 b8 ff ff ff 03 80 	movabs $0x8003ffffff,%rax
  8004201ffa:	00 00 00 
  8004201ffd:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  8004202001:	77 32                	ja     8004202035 <x64_vm_init+0xa1>
  8004202003:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202007:	48 89 c1             	mov    %rax,%rcx
  800420200a:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  8004202011:	00 00 00 
  8004202014:	be f4 00 00 00       	mov    $0xf4,%esi
  8004202019:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202020:	00 00 00 
  8004202023:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202028:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420202f:	00 00 00 
  8004202032:	41 ff d0             	callq  *%r8
  8004202035:	48 ba 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rdx
  800420203c:	ff ff ff 
  800420203f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202043:	48 01 c2             	add    %rax,%rdx
  8004202046:	48 b8 78 2d 22 04 80 	movabs $0x8004222d78,%rax
  800420204d:	00 00 00 
  8004202050:	48 89 10             	mov    %rdx,(%rax)
    // Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
    // The kernel uses this array to keep track of physical pages: for
    // each physical page, there is a corresponding struct PageInfo in this
    // array.  'npages' is the number of physical pages in memory.
    // Your code goes here:
    uint32_t page_size = ROUNDUP(sizeof(struct PageInfo) * npages, PGSIZE);
  8004202053:	48 c7 45 e8 00 10 00 	movq   $0x1000,-0x18(%rbp)
  800420205a:	00 
  800420205b:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004202062:	00 00 00 
  8004202065:	48 8b 00             	mov    (%rax),%rax
  8004202068:	48 c1 e0 04          	shl    $0x4,%rax
  800420206c:	48 89 c2             	mov    %rax,%rdx
  800420206f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202073:	48 01 d0             	add    %rdx,%rax
  8004202076:	48 83 e8 01          	sub    $0x1,%rax
  800420207a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  800420207e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202082:	ba 00 00 00 00       	mov    $0x0,%edx
  8004202087:	48 f7 75 e8          	divq   -0x18(%rbp)
  800420208b:	48 89 d0             	mov    %rdx,%rax
  800420208e:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004202092:	48 29 c2             	sub    %rax,%rdx
  8004202095:	48 89 d0             	mov    %rdx,%rax
  8004202098:	89 45 dc             	mov    %eax,-0x24(%rbp)
    pages = boot_alloc(page_size);
  800420209b:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800420209e:	89 c7                	mov    %eax,%edi
  80042020a0:	48 b8 5e 1e 20 04 80 	movabs $0x8004201e5e,%rax
  80042020a7:	00 00 00 
  80042020aa:	ff d0                	callq  *%rax
  80042020ac:	48 ba 90 2d 22 04 80 	movabs $0x8004222d90,%rdx
  80042020b3:	00 00 00 
  80042020b6:	48 89 02             	mov    %rax,(%rdx)
    //////////////////////////////////////////////////////////////////////
    // Now that we've allocated the initial kernel data structures, we set
    // up the list of free physical pages. Once we've done so, all further
    // memory management will go through the page_* functions. In
    // particular, we can now map memory using boot_map_region or page_insert
    page_init();
  80042020b9:	48 b8 11 24 20 04 80 	movabs $0x8004202411,%rax
  80042020c0:	00 00 00 
  80042020c3:	ff d0                	callq  *%rax
    //    - the new image at UPAGES -- kernel R, us/er R
    //      (ie. perm = PTE_U | PTE_P)
    //    - pages itself -- kernel RW, user NONE
    // Your code goes here:

    boot_map_region(pml4e, UPAGES, page_size, PADDR(pages), PTE_U);
  80042020c5:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042020cc:	00 00 00 
  80042020cf:	48 8b 00             	mov    (%rax),%rax
  80042020d2:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  80042020d6:	48 b8 ff ff ff 03 80 	movabs $0x8003ffffff,%rax
  80042020dd:	00 00 00 
  80042020e0:	48 39 45 d0          	cmp    %rax,-0x30(%rbp)
  80042020e4:	77 32                	ja     8004202118 <x64_vm_init+0x184>
  80042020e6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042020ea:	48 89 c1             	mov    %rax,%rcx
  80042020ed:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  80042020f4:	00 00 00 
  80042020f7:	be 10 01 00 00       	mov    $0x110,%esi
  80042020fc:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202103:	00 00 00 
  8004202106:	b8 00 00 00 00       	mov    $0x0,%eax
  800420210b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202112:	00 00 00 
  8004202115:	41 ff d0             	callq  *%r8
  8004202118:	48 ba 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rdx
  800420211f:	ff ff ff 
  8004202122:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004202126:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  800420212a:	8b 55 dc             	mov    -0x24(%rbp),%edx
  800420212d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202131:	41 b8 04 00 00 00    	mov    $0x4,%r8d
  8004202137:	48 be 00 00 a0 00 80 	movabs $0x8000a00000,%rsi
  800420213e:	00 00 00 
  8004202141:	48 89 c7             	mov    %rax,%rdi
  8004202144:	48 b8 8f 2c 20 04 80 	movabs $0x8004202c8f,%rax
  800420214b:	00 00 00 
  800420214e:	ff d0                	callq  *%rax
    boot_map_region(pml4e, (uintptr_t) pages, PGSIZE, PADDR(pages), PTE_W);
  8004202150:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004202157:	00 00 00 
  800420215a:	48 8b 00             	mov    (%rax),%rax
  800420215d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8004202161:	48 b8 ff ff ff 03 80 	movabs $0x8003ffffff,%rax
  8004202168:	00 00 00 
  800420216b:	48 39 45 c8          	cmp    %rax,-0x38(%rbp)
  800420216f:	77 32                	ja     80042021a3 <x64_vm_init+0x20f>
  8004202171:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004202175:	48 89 c1             	mov    %rax,%rcx
  8004202178:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  800420217f:	00 00 00 
  8004202182:	be 11 01 00 00       	mov    $0x111,%esi
  8004202187:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420218e:	00 00 00 
  8004202191:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202196:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420219d:	00 00 00 
  80042021a0:	41 ff d0             	callq  *%r8
  80042021a3:	48 ba 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rdx
  80042021aa:	ff ff ff 
  80042021ad:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042021b1:	48 01 c2             	add    %rax,%rdx
  80042021b4:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042021bb:	00 00 00 
  80042021be:	48 8b 00             	mov    (%rax),%rax
  80042021c1:	48 89 c6             	mov    %rax,%rsi
  80042021c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042021c8:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  80042021ce:	48 89 d1             	mov    %rdx,%rcx
  80042021d1:	ba 00 10 00 00       	mov    $0x1000,%edx
  80042021d6:	48 89 c7             	mov    %rax,%rdi
  80042021d9:	48 b8 8f 2c 20 04 80 	movabs $0x8004202c8f,%rax
  80042021e0:	00 00 00 
  80042021e3:	ff d0                	callq  *%rax
    //       the kernel overflows its stack, it will fault rather than
    //       overwrite memory.  Known as a "guard page".
    //     Permissions: kernel RW, user NONE
    // Your code goes here:

    boot_map_region(pml4e, KSTACKTOP-KSTKSIZE, 16*PGSIZE, PADDR(bootstack), PTE_W);
  80042021e5:	48 b8 00 20 21 04 80 	movabs $0x8004212000,%rax
  80042021ec:	00 00 00 
  80042021ef:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80042021f3:	48 b8 ff ff ff 03 80 	movabs $0x8003ffffff,%rax
  80042021fa:	00 00 00 
  80042021fd:	48 39 45 c0          	cmp    %rax,-0x40(%rbp)
  8004202201:	77 32                	ja     8004202235 <x64_vm_init+0x2a1>
  8004202203:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202207:	48 89 c1             	mov    %rax,%rcx
  800420220a:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  8004202211:	00 00 00 
  8004202214:	be 1f 01 00 00       	mov    $0x11f,%esi
  8004202219:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202220:	00 00 00 
  8004202223:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202228:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420222f:	00 00 00 
  8004202232:	41 ff d0             	callq  *%r8
  8004202235:	48 ba 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rdx
  800420223c:	ff ff ff 
  800420223f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202243:	48 01 c2             	add    %rax,%rdx
  8004202246:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420224a:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  8004202250:	48 89 d1             	mov    %rdx,%rcx
  8004202253:	ba 00 00 01 00       	mov    $0x10000,%edx
  8004202258:	48 be 00 00 ff 03 80 	movabs $0x8003ff0000,%rsi
  800420225f:	00 00 00 
  8004202262:	48 89 c7             	mov    %rax,%rdi
  8004202265:	48 b8 8f 2c 20 04 80 	movabs $0x8004202c8f,%rax
  800420226c:	00 00 00 
  800420226f:	ff d0                	callq  *%rax
    // Ie.  the VA range [KERNBASE, npages*PGSIZE) should map to
    //      the PA range [0, npages*PGSIZE)
    // Permissions: kernel RW, user NONE
    // Your code goes here:

    boot_map_region(pml4e, KERNBASE, npages * PGSIZE, (physaddr_t)0x0, PTE_W);
  8004202271:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004202278:	00 00 00 
  800420227b:	48 8b 00             	mov    (%rax),%rax
  800420227e:	48 c1 e0 0c          	shl    $0xc,%rax
  8004202282:	48 89 c2             	mov    %rax,%rdx
  8004202285:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202289:	41 b8 02 00 00 00    	mov    $0x2,%r8d
  800420228f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004202294:	48 be 00 00 00 04 80 	movabs $0x8004000000,%rsi
  800420229b:	00 00 00 
  800420229e:	48 89 c7             	mov    %rax,%rdi
  80042022a1:	48 b8 8f 2c 20 04 80 	movabs $0x8004202c8f,%rax
  80042022a8:	00 00 00 
  80042022ab:	ff d0                	callq  *%rax

    // Check that the initial page directory has been set up correctly.
    check_page_free_list(1);
  80042022ad:	bf 01 00 00 00       	mov    $0x1,%edi
  80042022b2:	48 b8 32 2f 20 04 80 	movabs $0x8004202f32,%rax
  80042022b9:	00 00 00 
  80042022bc:	ff d0                	callq  *%rax
    check_page_alloc();
  80042022be:	48 b8 0f 34 20 04 80 	movabs $0x800420340f,%rax
  80042022c5:	00 00 00 
  80042022c8:	ff d0                	callq  *%rax
    page_check();
  80042022ca:	48 b8 1f 46 20 04 80 	movabs $0x800420461f,%rax
  80042022d1:	00 00 00 
  80042022d4:	ff d0                	callq  *%rax
    check_page_free_list(0);
  80042022d6:	bf 00 00 00 00       	mov    $0x0,%edi
  80042022db:	48 b8 32 2f 20 04 80 	movabs $0x8004202f32,%rax
  80042022e2:	00 00 00 
  80042022e5:	ff d0                	callq  *%rax
    check_boot_pml4e(boot_pml4e);
  80042022e7:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042022ee:	00 00 00 
  80042022f1:	48 8b 00             	mov    (%rax),%rax
  80042022f4:	48 89 c7             	mov    %rax,%rdi
  80042022f7:	48 b8 fb 3d 20 04 80 	movabs $0x8004203dfb,%rax
  80042022fe:	00 00 00 
  8004202301:	ff d0                	callq  *%rax

    //////////////////////////////////////////////////////////////////////
    // Permissions: kernel RW, user NONE
    pdpe_t *pdpe = KADDR(PTE_ADDR(pml4e[1]));
  8004202303:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202307:	48 83 c0 08          	add    $0x8,%rax
  800420230b:	48 8b 00             	mov    (%rax),%rax
  800420230e:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202314:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8004202318:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420231c:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202320:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  8004202323:	8b 55 b4             	mov    -0x4c(%rbp),%edx
  8004202326:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420232d:	00 00 00 
  8004202330:	48 8b 00             	mov    (%rax),%rax
  8004202333:	48 39 c2             	cmp    %rax,%rdx
  8004202336:	72 32                	jb     800420236a <x64_vm_init+0x3d6>
  8004202338:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420233c:	48 89 c1             	mov    %rax,%rcx
  800420233f:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004202346:	00 00 00 
  8004202349:	be 34 01 00 00       	mov    $0x134,%esi
  800420234e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202355:	00 00 00 
  8004202358:	b8 00 00 00 00       	mov    $0x0,%eax
  800420235d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202364:	00 00 00 
  8004202367:	41 ff d0             	callq  *%r8
  800420236a:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004202371:	00 00 00 
  8004202374:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004202378:	48 01 d0             	add    %rdx,%rax
  800420237b:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
    pde_t *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  800420237f:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004202383:	48 8b 00             	mov    (%rax),%rax
  8004202386:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  800420238c:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
  8004202390:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004202394:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202398:	89 45 9c             	mov    %eax,-0x64(%rbp)
  800420239b:	8b 55 9c             	mov    -0x64(%rbp),%edx
  800420239e:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042023a5:	00 00 00 
  80042023a8:	48 8b 00             	mov    (%rax),%rax
  80042023ab:	48 39 c2             	cmp    %rax,%rdx
  80042023ae:	72 32                	jb     80042023e2 <x64_vm_init+0x44e>
  80042023b0:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042023b4:	48 89 c1             	mov    %rax,%rcx
  80042023b7:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  80042023be:	00 00 00 
  80042023c1:	be 35 01 00 00       	mov    $0x135,%esi
  80042023c6:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042023cd:	00 00 00 
  80042023d0:	b8 00 00 00 00       	mov    $0x0,%eax
  80042023d5:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042023dc:	00 00 00 
  80042023df:	41 ff d0             	callq  *%r8
  80042023e2:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042023e9:	00 00 00 
  80042023ec:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042023f0:	48 01 d0             	add    %rdx,%rax
  80042023f3:	48 89 45 90          	mov    %rax,-0x70(%rbp)
    lcr3(boot_cr3);
  80042023f7:	48 b8 78 2d 22 04 80 	movabs $0x8004222d78,%rax
  80042023fe:	00 00 00 
  8004202401:	48 8b 00             	mov    (%rax),%rax
  8004202404:	48 89 45 88          	mov    %rax,-0x78(%rbp)
}

static __inline void
lcr3(uint64_t val)
{
	__asm __volatile("movq %0,%%cr3" : : "r" (val));
  8004202408:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420240c:	0f 22 d8             	mov    %rax,%cr3
}
  800420240f:	c9                   	leaveq 
  8004202410:	c3                   	retq   

0000008004202411 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
  8004202411:	55                   	push   %rbp
  8004202412:	48 89 e5             	mov    %rsp,%rbp
  8004202415:	48 83 ec 60          	sub    $0x60,%rsp
    // free pages!
    // NB: Make sure you preserve the direction in which your page_free_list
    // is constructed
    // NB: Remember to mark the memory used for initial boot page table i.e (va>=BOOT_PAGE_TABLE_START && va < BOOT_PAGE_TABLE_END) as in-use (not free)
    size_t i;
    struct PageInfo* last = NULL;
  8004202419:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004202420:	00 

    uint64_t io_page = IOPHYSMEM / PGSIZE;
  8004202421:	48 c7 45 e0 a0 00 00 	movq   $0xa0,-0x20(%rbp)
  8004202428:	00 
    uint64_t free_page = PADDR(boot_alloc(0)) / PGSIZE;
  8004202429:	bf 00 00 00 00       	mov    $0x0,%edi
  800420242e:	48 b8 5e 1e 20 04 80 	movabs $0x8004201e5e,%rax
  8004202435:	00 00 00 
  8004202438:	ff d0                	callq  *%rax
  800420243a:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  800420243e:	48 b8 ff ff ff 03 80 	movabs $0x8003ffffff,%rax
  8004202445:	00 00 00 
  8004202448:	48 39 45 d8          	cmp    %rax,-0x28(%rbp)
  800420244c:	77 32                	ja     8004202480 <page_init+0x6f>
  800420244e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202452:	48 89 c1             	mov    %rax,%rcx
  8004202455:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  800420245c:	00 00 00 
  800420245f:	be 61 01 00 00       	mov    $0x161,%esi
  8004202464:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420246b:	00 00 00 
  800420246e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202473:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420247a:	00 00 00 
  800420247d:	41 ff d0             	callq  *%r8
  8004202480:	48 ba 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rdx
  8004202487:	ff ff ff 
  800420248a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420248e:	48 01 d0             	add    %rdx,%rax
  8004202491:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202495:	48 89 45 d0          	mov    %rax,-0x30(%rbp)

    pages[0].pp_ref = 1;
  8004202499:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042024a0:	00 00 00 
  80042024a3:	48 8b 00             	mov    (%rax),%rax
  80042024a6:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
    pages[0].pp_link = NULL;
  80042024ac:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042024b3:	00 00 00 
  80042024b6:	48 8b 00             	mov    (%rax),%rax
  80042024b9:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    for (i = 1; i < npages; i++) {
  80042024c0:	48 c7 45 f8 01 00 00 	movq   $0x1,-0x8(%rbp)
  80042024c7:	00 
  80042024c8:	e9 fe 01 00 00       	jmpq   80042026cb <page_init+0x2ba>

        bool used = false;
  80042024cd:	c6 45 ef 00          	movb   $0x0,-0x11(%rbp)

        if (i >= io_page && i < free_page)
  80042024d1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042024d5:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  80042024d9:	72 0e                	jb     80042024e9 <page_init+0xd8>
  80042024db:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042024df:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  80042024e3:	73 04                	jae    80042024e9 <page_init+0xd8>
            used = true;
  80042024e5:	c6 45 ef 01          	movb   $0x1,-0x11(%rbp)

        uint64_t va = KERNBASE + i * PGSIZE;
  80042024e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042024ed:	48 05 00 40 00 08    	add    $0x8004000,%rax
  80042024f3:	48 c1 e0 0c          	shl    $0xc,%rax
  80042024f7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)

        if (va >= BOOT_PAGE_TABLE_START && va < BOOT_PAGE_TABLE_END)
  80042024fb:	48 b8 00 20 10 00 00 	movabs $0x102000,%rax
  8004202502:	00 00 00 
  8004202505:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004202509:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420250d:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202511:	89 45 bc             	mov    %eax,-0x44(%rbp)
  8004202514:	8b 55 bc             	mov    -0x44(%rbp),%edx
  8004202517:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420251e:	00 00 00 
  8004202521:	48 8b 00             	mov    (%rax),%rax
  8004202524:	48 39 c2             	cmp    %rax,%rdx
  8004202527:	72 32                	jb     800420255b <page_init+0x14a>
  8004202529:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420252d:	48 89 c1             	mov    %rax,%rcx
  8004202530:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004202537:	00 00 00 
  800420253a:	be 6f 01 00 00       	mov    $0x16f,%esi
  800420253f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202546:	00 00 00 
  8004202549:	b8 00 00 00 00       	mov    $0x0,%eax
  800420254e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202555:	00 00 00 
  8004202558:	41 ff d0             	callq  *%r8
  800420255b:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004202562:	00 00 00 
  8004202565:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202569:	48 01 d0             	add    %rdx,%rax
  800420256c:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004202570:	0f 87 81 00 00 00    	ja     80042025f7 <page_init+0x1e6>
  8004202576:	48 b8 00 20 10 00 00 	movabs $0x102000,%rax
  800420257d:	00 00 00 
  8004202580:	48 05 00 50 00 00    	add    $0x5000,%rax
  8004202586:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  800420258a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420258e:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202592:	89 45 ac             	mov    %eax,-0x54(%rbp)
  8004202595:	8b 55 ac             	mov    -0x54(%rbp),%edx
  8004202598:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420259f:	00 00 00 
  80042025a2:	48 8b 00             	mov    (%rax),%rax
  80042025a5:	48 39 c2             	cmp    %rax,%rdx
  80042025a8:	72 32                	jb     80042025dc <page_init+0x1cb>
  80042025aa:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042025ae:	48 89 c1             	mov    %rax,%rcx
  80042025b1:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  80042025b8:	00 00 00 
  80042025bb:	be 6f 01 00 00       	mov    $0x16f,%esi
  80042025c0:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042025c7:	00 00 00 
  80042025ca:	b8 00 00 00 00       	mov    $0x0,%eax
  80042025cf:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042025d6:	00 00 00 
  80042025d9:	41 ff d0             	callq  *%r8
  80042025dc:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042025e3:	00 00 00 
  80042025e6:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042025ea:	48 01 d0             	add    %rdx,%rax
  80042025ed:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80042025f1:	76 04                	jbe    80042025f7 <page_init+0x1e6>
            used = true;
  80042025f3:	c6 45 ef 01          	movb   $0x1,-0x11(%rbp)

        if (used) {
  80042025f7:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  80042025fb:	74 42                	je     800420263f <page_init+0x22e>
            pages[i].pp_ref = 1;
  80042025fd:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004202604:	00 00 00 
  8004202607:	48 8b 00             	mov    (%rax),%rax
  800420260a:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420260e:	48 c1 e2 04          	shl    $0x4,%rdx
  8004202612:	48 01 d0             	add    %rdx,%rax
  8004202615:	66 c7 40 08 01 00    	movw   $0x1,0x8(%rax)
            pages[i].pp_link = NULL;
  800420261b:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004202622:	00 00 00 
  8004202625:	48 8b 00             	mov    (%rax),%rax
  8004202628:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420262c:	48 c1 e2 04          	shl    $0x4,%rdx
  8004202630:	48 01 d0             	add    %rdx,%rax
  8004202633:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
            continue;
  800420263a:	e9 87 00 00 00       	jmpq   80042026c6 <page_init+0x2b5>
        }

        pages[i].pp_ref = 0;
  800420263f:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004202646:	00 00 00 
  8004202649:	48 8b 00             	mov    (%rax),%rax
  800420264c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004202650:	48 c1 e2 04          	shl    $0x4,%rdx
  8004202654:	48 01 d0             	add    %rdx,%rax
  8004202657:	66 c7 40 08 00 00    	movw   $0x0,0x8(%rax)
        if(last)
  800420265d:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
  8004202662:	74 21                	je     8004202685 <page_init+0x274>
            last->pp_link = &pages[i];
  8004202664:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  800420266b:	00 00 00 
  800420266e:	48 8b 00             	mov    (%rax),%rax
  8004202671:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004202675:	48 c1 e2 04          	shl    $0x4,%rdx
  8004202679:	48 01 c2             	add    %rax,%rdx
  800420267c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202680:	48 89 10             	mov    %rdx,(%rax)
  8004202683:	eb 25                	jmp    80042026aa <page_init+0x299>
        else
            page_free_list = &pages[i];
  8004202685:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  800420268c:	00 00 00 
  800420268f:	48 8b 00             	mov    (%rax),%rax
  8004202692:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004202696:	48 c1 e2 04          	shl    $0x4,%rdx
  800420269a:	48 01 c2             	add    %rax,%rdx
  800420269d:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  80042026a4:	00 00 00 
  80042026a7:	48 89 10             	mov    %rdx,(%rax)
        last = &pages[i];
  80042026aa:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042026b1:	00 00 00 
  80042026b4:	48 8b 00             	mov    (%rax),%rax
  80042026b7:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042026bb:	48 c1 e2 04          	shl    $0x4,%rdx
  80042026bf:	48 01 d0             	add    %rdx,%rax
  80042026c2:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    uint64_t free_page = PADDR(boot_alloc(0)) / PGSIZE;

    pages[0].pp_ref = 1;
    pages[0].pp_link = NULL;

    for (i = 1; i < npages; i++) {
  80042026c6:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80042026cb:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042026d2:	00 00 00 
  80042026d5:	48 8b 00             	mov    (%rax),%rax
  80042026d8:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  80042026dc:	0f 82 eb fd ff ff    	jb     80042024cd <page_init+0xbc>
            last->pp_link = &pages[i];
        else
            page_free_list = &pages[i];
        last = &pages[i];
    }
}
  80042026e2:	c9                   	leaveq 
  80042026e3:	c3                   	retq   

00000080042026e4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
  80042026e4:	55                   	push   %rbp
  80042026e5:	48 89 e5             	mov    %rsp,%rbp
  80042026e8:	48 83 ec 20          	sub    $0x20,%rsp
  80042026ec:	89 7d ec             	mov    %edi,-0x14(%rbp)
    if (!page_free_list)
  80042026ef:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  80042026f6:	00 00 00 
  80042026f9:	48 8b 00             	mov    (%rax),%rax
  80042026fc:	48 85 c0             	test   %rax,%rax
  80042026ff:	75 07                	jne    8004202708 <page_alloc+0x24>
        return NULL;
  8004202701:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202706:	eb 6a                	jmp    8004202772 <page_alloc+0x8e>

    struct PageInfo *page = page_free_list;
  8004202708:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  800420270f:	00 00 00 
  8004202712:	48 8b 00             	mov    (%rax),%rax
  8004202715:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    page_free_list = page->pp_link;
  8004202719:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420271d:	48 8b 10             	mov    (%rax),%rdx
  8004202720:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004202727:	00 00 00 
  800420272a:	48 89 10             	mov    %rdx,(%rax)

    if (alloc_flags & ALLOC_ZERO)
  800420272d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004202730:	83 e0 01             	and    $0x1,%eax
  8004202733:	85 c0                	test   %eax,%eax
  8004202735:	74 2c                	je     8004202763 <page_alloc+0x7f>
        memset(page2kva(page), '\0', PGSIZE);
  8004202737:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420273b:	48 89 c7             	mov    %rax,%rdi
  800420273e:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  8004202745:	00 00 00 
  8004202748:	ff d0                	callq  *%rax
  800420274a:	ba 00 10 00 00       	mov    $0x1000,%edx
  800420274f:	be 00 00 00 00       	mov    $0x0,%esi
  8004202754:	48 89 c7             	mov    %rax,%rdi
  8004202757:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420275e:	00 00 00 
  8004202761:	ff d0                	callq  *%rax

    page->pp_link = NULL;
  8004202763:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202767:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    return page;
  800420276e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004202772:	c9                   	leaveq 
  8004202773:	c3                   	retq   

0000008004202774 <page_initpp>:
// The result has null links and 0 refcount.
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct PageInfo *pp)
{
  8004202774:	55                   	push   %rbp
  8004202775:	48 89 e5             	mov    %rsp,%rbp
  8004202778:	48 83 ec 10          	sub    $0x10,%rsp
  800420277c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    memset(pp, 0, sizeof(*pp));
  8004202780:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202784:	ba 10 00 00 00       	mov    $0x10,%edx
  8004202789:	be 00 00 00 00       	mov    $0x0,%esi
  800420278e:	48 89 c7             	mov    %rax,%rdi
  8004202791:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004202798:	00 00 00 
  800420279b:	ff d0                	callq  *%rax
}
  800420279d:	c9                   	leaveq 
  800420279e:	c3                   	retq   

000000800420279f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
  800420279f:	55                   	push   %rbp
  80042027a0:	48 89 e5             	mov    %rsp,%rbp
  80042027a3:	48 83 ec 10          	sub    $0x10,%rsp
  80042027a7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    if (pp->pp_ref != 0 || pp->pp_link)
  80042027ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042027af:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042027b3:	66 85 c0             	test   %ax,%ax
  80042027b6:	75 0c                	jne    80042027c4 <page_free+0x25>
  80042027b8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042027bc:	48 8b 00             	mov    (%rax),%rax
  80042027bf:	48 85 c0             	test   %rax,%rax
  80042027c2:	74 2a                	je     80042027ee <page_free+0x4f>
        panic("'the page could not be freed");
  80042027c4:	48 ba 84 e8 20 04 80 	movabs $0x800420e884,%rdx
  80042027cb:	00 00 00 
  80042027ce:	be b0 01 00 00       	mov    $0x1b0,%esi
  80042027d3:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042027da:	00 00 00 
  80042027dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80042027e2:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  80042027e9:	00 00 00 
  80042027ec:	ff d1                	callq  *%rcx

    pp->pp_link = page_free_list;
  80042027ee:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  80042027f5:	00 00 00 
  80042027f8:	48 8b 10             	mov    (%rax),%rdx
  80042027fb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042027ff:	48 89 10             	mov    %rdx,(%rax)
    page_free_list = pp;
  8004202802:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004202809:	00 00 00 
  800420280c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004202810:	48 89 10             	mov    %rdx,(%rax)
}
  8004202813:	c9                   	leaveq 
  8004202814:	c3                   	retq   

0000008004202815 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
  8004202815:	55                   	push   %rbp
  8004202816:	48 89 e5             	mov    %rsp,%rbp
  8004202819:	48 83 ec 10          	sub    $0x10,%rsp
  800420281d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    if (--pp->pp_ref == 0)
  8004202821:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202825:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004202829:	8d 50 ff             	lea    -0x1(%rax),%edx
  800420282c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202830:	66 89 50 08          	mov    %dx,0x8(%rax)
  8004202834:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202838:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420283c:	66 85 c0             	test   %ax,%ax
  800420283f:	75 13                	jne    8004202854 <page_decref+0x3f>
        page_free(pp);
  8004202841:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202845:	48 89 c7             	mov    %rax,%rdi
  8004202848:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  800420284f:	00 00 00 
  8004202852:	ff d0                	callq  *%rax
}
  8004202854:	c9                   	leaveq 
  8004202855:	c3                   	retq   

0000008004202856 <pml4e_walk>:
// table, page directory,page directory pointer and pml4 entries.
//

pte_t *
pml4e_walk(pml4e_t *pml4e, const void *va, int create)
{
  8004202856:	55                   	push   %rbp
  8004202857:	48 89 e5             	mov    %rsp,%rbp
  800420285a:	48 83 ec 50          	sub    $0x50,%rsp
  800420285e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004202862:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  8004202866:	89 55 bc             	mov    %edx,-0x44(%rbp)
    pdpe_t *pdpe;
    struct PageInfo *page = NULL;
  8004202869:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004202870:	00 
    pml4e_t *current_pml4e = &pml4e[PML4(va)];
  8004202871:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202875:	48 c1 e8 27          	shr    $0x27,%rax
  8004202879:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420287e:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004202885:	00 
  8004202886:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420288a:	48 01 d0             	add    %rdx,%rax
  800420288d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

    if(create && !*current_pml4e) {
  8004202891:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8004202895:	74 6c                	je     8004202903 <pml4e_walk+0xad>
  8004202897:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420289b:	48 8b 00             	mov    (%rax),%rax
  800420289e:	48 85 c0             	test   %rax,%rax
  80042028a1:	75 60                	jne    8004202903 <pml4e_walk+0xad>
        page = page_alloc(ALLOC_ZERO);
  80042028a3:	bf 01 00 00 00       	mov    $0x1,%edi
  80042028a8:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042028af:	00 00 00 
  80042028b2:	ff d0                	callq  *%rax
  80042028b4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        if (!page)
  80042028b8:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042028bd:	75 0a                	jne    80042028c9 <pml4e_walk+0x73>
            return NULL;
  80042028bf:	b8 00 00 00 00       	mov    $0x0,%eax
  80042028c4:	e9 03 01 00 00       	jmpq   80042029cc <pml4e_walk+0x176>

        page->pp_ref++;
  80042028c9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042028cd:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042028d1:	8d 50 01             	lea    0x1(%rax),%edx
  80042028d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042028d8:	66 89 50 08          	mov    %dx,0x8(%rax)
        *current_pml4e = (pml4e_t) (page2pa(page) & ~0xFFF) | PTE_P | PTE_W | PTE_U;
  80042028dc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042028e0:	48 89 c7             	mov    %rax,%rdi
  80042028e3:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042028ea:	00 00 00 
  80042028ed:	ff d0                	callq  *%rax
  80042028ef:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80042028f5:	48 83 c8 07          	or     $0x7,%rax
  80042028f9:	48 89 c2             	mov    %rax,%rdx
  80042028fc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202900:	48 89 10             	mov    %rdx,(%rax)
    }

    pdpe = (pdpe_t *) KADDR(PTE_ADDR(*current_pml4e));
  8004202903:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202907:	48 8b 00             	mov    (%rax),%rax
  800420290a:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202910:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004202914:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202918:	48 c1 e8 0c          	shr    $0xc,%rax
  800420291c:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  800420291f:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004202922:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004202929:	00 00 00 
  800420292c:	48 8b 00             	mov    (%rax),%rax
  800420292f:	48 39 c2             	cmp    %rax,%rdx
  8004202932:	72 32                	jb     8004202966 <pml4e_walk+0x110>
  8004202934:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202938:	48 89 c1             	mov    %rax,%rcx
  800420293b:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004202942:	00 00 00 
  8004202945:	be ea 01 00 00       	mov    $0x1ea,%esi
  800420294a:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202951:	00 00 00 
  8004202954:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202959:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202960:	00 00 00 
  8004202963:	41 ff d0             	callq  *%r8
  8004202966:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  800420296d:	00 00 00 
  8004202970:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202974:	48 01 d0             	add    %rdx,%rax
  8004202977:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

    pte_t *pte = pdpe_walk(pdpe, va, create);
  800420297b:	8b 55 bc             	mov    -0x44(%rbp),%edx
  800420297e:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  8004202982:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202986:	48 89 ce             	mov    %rcx,%rsi
  8004202989:	48 89 c7             	mov    %rax,%rdi
  800420298c:	48 b8 ce 29 20 04 80 	movabs $0x80042029ce,%rax
  8004202993:	00 00 00 
  8004202996:	ff d0                	callq  *%rax
  8004202998:	48 89 45 d0          	mov    %rax,-0x30(%rbp)

    if (!pte && page) {
  800420299c:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  80042029a1:	75 25                	jne    80042029c8 <pml4e_walk+0x172>
  80042029a3:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042029a8:	74 1e                	je     80042029c8 <pml4e_walk+0x172>
        page_decref(page);
  80042029aa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042029ae:	48 89 c7             	mov    %rax,%rdi
  80042029b1:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  80042029b8:	00 00 00 
  80042029bb:	ff d0                	callq  *%rax
        *current_pml4e = 0x0;
  80042029bd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042029c1:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    }

    return pte;
  80042029c8:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
}
  80042029cc:	c9                   	leaveq 
  80042029cd:	c3                   	retq   

00000080042029ce <pdpe_walk>:
// Given a pdpe i.e page directory pointer pdpe_walk returns the pointer to page table entry
// The programming logic in this function is similar to pml4e_walk.
// It calls the pgdir_walk which returns the page_table entry pointer.
// Hints are the same as in pml4e_walk
pte_t *
pdpe_walk(pdpe_t *pdpe,const void *va,int create){
  80042029ce:	55                   	push   %rbp
  80042029cf:	48 89 e5             	mov    %rsp,%rbp
  80042029d2:	48 83 ec 50          	sub    $0x50,%rsp
  80042029d6:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  80042029da:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  80042029de:	89 55 bc             	mov    %edx,-0x44(%rbp)
    pde_t *pde;
    struct PageInfo *page = NULL;
  80042029e1:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042029e8:	00 
    pdpe_t *current_pdpe = &pdpe[PDPE(va)];
  80042029e9:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042029ed:	48 c1 e8 1e          	shr    $0x1e,%rax
  80042029f1:	25 ff 01 00 00       	and    $0x1ff,%eax
  80042029f6:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80042029fd:	00 
  80042029fe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004202a02:	48 01 d0             	add    %rdx,%rax
  8004202a05:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

    if(create && !*current_pdpe) {
  8004202a09:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8004202a0d:	74 6c                	je     8004202a7b <pdpe_walk+0xad>
  8004202a0f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202a13:	48 8b 00             	mov    (%rax),%rax
  8004202a16:	48 85 c0             	test   %rax,%rax
  8004202a19:	75 60                	jne    8004202a7b <pdpe_walk+0xad>
        page = page_alloc(ALLOC_ZERO);
  8004202a1b:	bf 01 00 00 00       	mov    $0x1,%edi
  8004202a20:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004202a27:	00 00 00 
  8004202a2a:	ff d0                	callq  *%rax
  8004202a2c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        if (!page)
  8004202a30:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004202a35:	75 0a                	jne    8004202a41 <pdpe_walk+0x73>
            return NULL;
  8004202a37:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202a3c:	e9 03 01 00 00       	jmpq   8004202b44 <pdpe_walk+0x176>
        page->pp_ref++;
  8004202a41:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202a45:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004202a49:	8d 50 01             	lea    0x1(%rax),%edx
  8004202a4c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202a50:	66 89 50 08          	mov    %dx,0x8(%rax)
        *current_pdpe = (pdpe_t) (page2pa(page) & ~0xFFF) | PTE_P | PTE_W;
  8004202a54:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202a58:	48 89 c7             	mov    %rax,%rdi
  8004202a5b:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004202a62:	00 00 00 
  8004202a65:	ff d0                	callq  *%rax
  8004202a67:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202a6d:	48 83 c8 03          	or     $0x3,%rax
  8004202a71:	48 89 c2             	mov    %rax,%rdx
  8004202a74:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202a78:	48 89 10             	mov    %rdx,(%rax)
    }

    pde = (pde_t *) KADDR(PTE_ADDR(*current_pdpe));
  8004202a7b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202a7f:	48 8b 00             	mov    (%rax),%rax
  8004202a82:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202a88:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004202a8c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202a90:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202a94:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004202a97:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004202a9a:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004202aa1:	00 00 00 
  8004202aa4:	48 8b 00             	mov    (%rax),%rax
  8004202aa7:	48 39 c2             	cmp    %rax,%rdx
  8004202aaa:	72 32                	jb     8004202ade <pdpe_walk+0x110>
  8004202aac:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202ab0:	48 89 c1             	mov    %rax,%rcx
  8004202ab3:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004202aba:	00 00 00 
  8004202abd:	be 08 02 00 00       	mov    $0x208,%esi
  8004202ac2:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202ac9:	00 00 00 
  8004202acc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202ad1:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202ad8:	00 00 00 
  8004202adb:	41 ff d0             	callq  *%r8
  8004202ade:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004202ae5:	00 00 00 
  8004202ae8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202aec:	48 01 d0             	add    %rdx,%rax
  8004202aef:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

    pte_t *pte = pgdir_walk(pde, va, create);
  8004202af3:	8b 55 bc             	mov    -0x44(%rbp),%edx
  8004202af6:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  8004202afa:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202afe:	48 89 ce             	mov    %rcx,%rsi
  8004202b01:	48 89 c7             	mov    %rax,%rdi
  8004202b04:	48 b8 46 2b 20 04 80 	movabs $0x8004202b46,%rax
  8004202b0b:	00 00 00 
  8004202b0e:	ff d0                	callq  *%rax
  8004202b10:	48 89 45 d0          	mov    %rax,-0x30(%rbp)

    if (!pte && page) {
  8004202b14:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004202b19:	75 25                	jne    8004202b40 <pdpe_walk+0x172>
  8004202b1b:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004202b20:	74 1e                	je     8004202b40 <pdpe_walk+0x172>
        page_decref(page);
  8004202b22:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202b26:	48 89 c7             	mov    %rax,%rdi
  8004202b29:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004202b30:	00 00 00 
  8004202b33:	ff d0                	callq  *%rax
        *current_pdpe = 0x0;
  8004202b35:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202b39:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    }

    return pte;
  8004202b40:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
}
  8004202b44:	c9                   	leaveq 
  8004202b45:	c3                   	retq   

0000008004202b46 <pgdir_walk>:
// The logic here is slightly different, in that it needs to look
// not just at the page directory, but also get the last-level page table entry.

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
  8004202b46:	55                   	push   %rbp
  8004202b47:	48 89 e5             	mov    %rsp,%rbp
  8004202b4a:	48 83 ec 50          	sub    $0x50,%rsp
  8004202b4e:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  8004202b52:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  8004202b56:	89 55 bc             	mov    %edx,-0x44(%rbp)
    pde_t *current_pde = &pgdir[PDX(va)];
  8004202b59:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202b5d:	48 c1 e8 15          	shr    $0x15,%rax
  8004202b61:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004202b66:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004202b6d:	00 
  8004202b6e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004202b72:	48 01 d0             	add    %rdx,%rax
  8004202b75:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    pte_t *pte;

    if(create && !*current_pde) {
  8004202b79:	83 7d bc 00          	cmpl   $0x0,-0x44(%rbp)
  8004202b7d:	74 6c                	je     8004202beb <pgdir_walk+0xa5>
  8004202b7f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202b83:	48 8b 00             	mov    (%rax),%rax
  8004202b86:	48 85 c0             	test   %rax,%rax
  8004202b89:	75 60                	jne    8004202beb <pgdir_walk+0xa5>
        struct PageInfo *page = page_alloc(ALLOC_ZERO);
  8004202b8b:	bf 01 00 00 00       	mov    $0x1,%edi
  8004202b90:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004202b97:	00 00 00 
  8004202b9a:	ff d0                	callq  *%rax
  8004202b9c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
        if (!page)
  8004202ba0:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
  8004202ba5:	75 0a                	jne    8004202bb1 <pgdir_walk+0x6b>
            return NULL;
  8004202ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202bac:	e9 dc 00 00 00       	jmpq   8004202c8d <pgdir_walk+0x147>

        page->pp_ref++;
  8004202bb1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202bb5:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004202bb9:	8d 50 01             	lea    0x1(%rax),%edx
  8004202bbc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202bc0:	66 89 50 08          	mov    %dx,0x8(%rax)
        *current_pde = (pde_t) (page2pa(page) & ~0xFFF) | PTE_P | PTE_W;
  8004202bc4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202bc8:	48 89 c7             	mov    %rax,%rdi
  8004202bcb:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004202bd2:	00 00 00 
  8004202bd5:	ff d0                	callq  *%rax
  8004202bd7:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202bdd:	48 83 c8 03          	or     $0x3,%rax
  8004202be1:	48 89 c2             	mov    %rax,%rdx
  8004202be4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202be8:	48 89 10             	mov    %rdx,(%rax)
    }

    pte = (pte_t *) KADDR(PTE_ADDR(*current_pde));
  8004202beb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202bef:	48 8b 00             	mov    (%rax),%rax
  8004202bf2:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202bf8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004202bfc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202c00:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202c04:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004202c07:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  8004202c0a:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004202c11:	00 00 00 
  8004202c14:	48 8b 00             	mov    (%rax),%rax
  8004202c17:	48 39 c2             	cmp    %rax,%rdx
  8004202c1a:	72 32                	jb     8004202c4e <pgdir_walk+0x108>
  8004202c1c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202c20:	48 89 c1             	mov    %rax,%rcx
  8004202c23:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004202c2a:	00 00 00 
  8004202c2d:	be 2a 02 00 00       	mov    $0x22a,%esi
  8004202c32:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202c39:	00 00 00 
  8004202c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202c41:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004202c48:	00 00 00 
  8004202c4b:	41 ff d0             	callq  *%r8
  8004202c4e:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004202c55:	00 00 00 
  8004202c58:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202c5c:	48 01 d0             	add    %rdx,%rax
  8004202c5f:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

    if(!pte)
  8004202c63:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004202c68:	75 07                	jne    8004202c71 <pgdir_walk+0x12b>
        return NULL;
  8004202c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202c6f:	eb 1c                	jmp    8004202c8d <pgdir_walk+0x147>

    return &pte[PTX(va)];
  8004202c71:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004202c75:	48 c1 e8 0c          	shr    $0xc,%rax
  8004202c79:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004202c7e:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004202c85:	00 
  8004202c86:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202c8a:	48 01 d0             	add    %rdx,%rax
}
  8004202c8d:	c9                   	leaveq 
  8004202c8e:	c3                   	retq   

0000008004202c8f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pml4e_walk
static void
boot_map_region(pml4e_t *pml4e, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
  8004202c8f:	55                   	push   %rbp
  8004202c90:	48 89 e5             	mov    %rsp,%rbp
  8004202c93:	48 83 ec 40          	sub    $0x40,%rsp
  8004202c97:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202c9b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202c9f:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004202ca3:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  8004202ca7:	44 89 45 cc          	mov    %r8d,-0x34(%rbp)
    pte_t *pte;
    int i = 0;
  8004202cab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
    for( i = 0; i < size; i += PGSIZE) {
  8004202cb2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004202cb9:	e9 8a 00 00 00       	jmpq   8004202d48 <boot_map_region+0xb9>
        pte = pml4e_walk(pml4e, (void *)la + i, true);
  8004202cbe:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202cc1:	48 63 d0             	movslq %eax,%rdx
  8004202cc4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202cc8:	48 01 d0             	add    %rdx,%rax
  8004202ccb:	48 89 c1             	mov    %rax,%rcx
  8004202cce:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202cd2:	ba 01 00 00 00       	mov    $0x1,%edx
  8004202cd7:	48 89 ce             	mov    %rcx,%rsi
  8004202cda:	48 89 c7             	mov    %rax,%rdi
  8004202cdd:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004202ce4:	00 00 00 
  8004202ce7:	ff d0                	callq  *%rax
  8004202ce9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
        if (!pte)
  8004202ced:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
  8004202cf2:	75 2a                	jne    8004202d1e <boot_map_region+0x8f>
            panic("failed to find the physical memory");
  8004202cf4:	48 ba a8 e8 20 04 80 	movabs $0x800420e8a8,%rdx
  8004202cfb:	00 00 00 
  8004202cfe:	be 44 02 00 00       	mov    $0x244,%esi
  8004202d03:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202d0a:	00 00 00 
  8004202d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202d12:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  8004202d19:	00 00 00 
  8004202d1c:	ff d1                	callq  *%rcx
        *pte = (pa + i) | perm | PTE_P;
  8004202d1e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202d21:	48 63 d0             	movslq %eax,%rdx
  8004202d24:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004202d28:	48 01 c2             	add    %rax,%rdx
  8004202d2b:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004202d2e:	48 98                	cltq   
  8004202d30:	48 09 d0             	or     %rdx,%rax
  8004202d33:	48 83 c8 01          	or     $0x1,%rax
  8004202d37:	48 89 c2             	mov    %rax,%rdx
  8004202d3a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202d3e:	48 89 10             	mov    %rdx,(%rax)
static void
boot_map_region(pml4e_t *pml4e, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
    pte_t *pte;
    int i = 0;
    for( i = 0; i < size; i += PGSIZE) {
  8004202d41:	81 45 fc 00 10 00 00 	addl   $0x1000,-0x4(%rbp)
  8004202d48:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004202d4b:	48 98                	cltq   
  8004202d4d:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8004202d51:	0f 82 67 ff ff ff    	jb     8004202cbe <boot_map_region+0x2f>
        pte = pml4e_walk(pml4e, (void *)la + i, true);
        if (!pte)
            panic("failed to find the physical memory");
        *pte = (pa + i) | perm | PTE_P;
    }
}
  8004202d57:	c9                   	leaveq 
  8004202d58:	c3                   	retq   

0000008004202d59 <page_insert>:
// Hint: The TA solution is implemented using pml4e_walk, page_remove,
// and page2pa.
//
int
page_insert(pml4e_t *pml4e, struct PageInfo *pp, void *va, int perm)
{
  8004202d59:	55                   	push   %rbp
  8004202d5a:	48 89 e5             	mov    %rsp,%rbp
  8004202d5d:	48 83 ec 30          	sub    $0x30,%rsp
  8004202d61:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202d65:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202d69:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004202d6d:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
    pte_t *pte = pml4e_walk(pml4e, va, true);
  8004202d70:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004202d74:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202d78:	ba 01 00 00 00       	mov    $0x1,%edx
  8004202d7d:	48 89 ce             	mov    %rcx,%rsi
  8004202d80:	48 89 c7             	mov    %rax,%rdi
  8004202d83:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004202d8a:	00 00 00 
  8004202d8d:	ff d0                	callq  *%rax
  8004202d8f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (!pte)
  8004202d93:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004202d98:	75 07                	jne    8004202da1 <page_insert+0x48>
        return -E_NO_MEM;
  8004202d9a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8004202d9f:	eb 73                	jmp    8004202e14 <page_insert+0xbb>
    if (*pte & PTE_P)
  8004202da1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202da5:	48 8b 00             	mov    (%rax),%rax
  8004202da8:	83 e0 01             	and    $0x1,%eax
  8004202dab:	48 85 c0             	test   %rax,%rax
  8004202dae:	74 1a                	je     8004202dca <page_insert+0x71>
        page_remove(pml4e, va);
  8004202db0:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004202db4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202db8:	48 89 d6             	mov    %rdx,%rsi
  8004202dbb:	48 89 c7             	mov    %rax,%rdi
  8004202dbe:	48 b8 8d 2e 20 04 80 	movabs $0x8004202e8d,%rax
  8004202dc5:	00 00 00 
  8004202dc8:	ff d0                	callq  *%rax

    pp->pp_ref++;
  8004202dca:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202dce:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004202dd2:	8d 50 01             	lea    0x1(%rax),%edx
  8004202dd5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202dd9:	66 89 50 08          	mov    %dx,0x8(%rax)
    *pte = (page2pa(pp) & ~0xFFF) | perm | PTE_P;
  8004202ddd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202de1:	48 89 c7             	mov    %rax,%rdi
  8004202de4:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004202deb:	00 00 00 
  8004202dee:	ff d0                	callq  *%rax
  8004202df0:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004202df6:	48 89 c2             	mov    %rax,%rdx
  8004202df9:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  8004202dfc:	48 98                	cltq   
  8004202dfe:	48 09 d0             	or     %rdx,%rax
  8004202e01:	48 83 c8 01          	or     $0x1,%rax
  8004202e05:	48 89 c2             	mov    %rax,%rdx
  8004202e08:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202e0c:	48 89 10             	mov    %rdx,(%rax)

    return 0;
  8004202e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004202e14:	c9                   	leaveq 
  8004202e15:	c3                   	retq   

0000008004202e16 <page_lookup>:
//
// Hint: the TA solution uses pml4e_walk and pa2page.
//
struct PageInfo *
page_lookup(pml4e_t *pml4e, void *va, pte_t **pte_store)
{
  8004202e16:	55                   	push   %rbp
  8004202e17:	48 89 e5             	mov    %rsp,%rbp
  8004202e1a:	48 83 ec 30          	sub    $0x30,%rsp
  8004202e1e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202e22:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202e26:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    pte_t *pte = pml4e_walk(pml4e, va, true);
  8004202e2a:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004202e2e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202e32:	ba 01 00 00 00       	mov    $0x1,%edx
  8004202e37:	48 89 ce             	mov    %rcx,%rsi
  8004202e3a:	48 89 c7             	mov    %rax,%rdi
  8004202e3d:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004202e44:	00 00 00 
  8004202e47:	ff d0                	callq  *%rax
  8004202e49:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (!pte)
  8004202e4d:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004202e52:	75 07                	jne    8004202e5b <page_lookup+0x45>
        return NULL;
  8004202e54:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202e59:	eb 30                	jmp    8004202e8b <page_lookup+0x75>

    physaddr_t pa = (physaddr_t) *pte;
  8004202e5b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202e5f:	48 8b 00             	mov    (%rax),%rax
  8004202e62:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

    if (pte_store)
  8004202e66:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004202e6b:	74 0b                	je     8004202e78 <page_lookup+0x62>
        *pte_store = pte;
  8004202e6d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004202e71:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004202e75:	48 89 10             	mov    %rdx,(%rax)

    return pa2page(pa);
  8004202e78:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202e7c:	48 89 c7             	mov    %rax,%rdi
  8004202e7f:	48 b8 c4 14 20 04 80 	movabs $0x80042014c4,%rax
  8004202e86:	00 00 00 
  8004202e89:	ff d0                	callq  *%rax
}
  8004202e8b:	c9                   	leaveq 
  8004202e8c:	c3                   	retq   

0000008004202e8d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pml4e_t *pml4e, void *va)
{
  8004202e8d:	55                   	push   %rbp
  8004202e8e:	48 89 e5             	mov    %rsp,%rbp
  8004202e91:	48 83 ec 20          	sub    $0x20,%rsp
  8004202e95:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202e99:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    pte_t *pte = NULL;
  8004202e9d:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004202ea4:	00 
    struct PageInfo *page = page_lookup(pml4e, va, &pte);
  8004202ea5:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
  8004202ea9:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004202ead:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202eb1:	48 89 ce             	mov    %rcx,%rsi
  8004202eb4:	48 89 c7             	mov    %rax,%rdi
  8004202eb7:	48 b8 16 2e 20 04 80 	movabs $0x8004202e16,%rax
  8004202ebe:	00 00 00 
  8004202ec1:	ff d0                	callq  *%rax
  8004202ec3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (page) {
  8004202ec7:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004202ecc:	74 41                	je     8004202f0f <page_remove+0x82>
        page_decref(page);
  8004202ece:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202ed2:	48 89 c7             	mov    %rax,%rdi
  8004202ed5:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004202edc:	00 00 00 
  8004202edf:	ff d0                	callq  *%rax
        if (pte) {
  8004202ee1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202ee5:	48 85 c0             	test   %rax,%rax
  8004202ee8:	74 25                	je     8004202f0f <page_remove+0x82>
            *pte = 0;
  8004202eea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004202eee:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
            tlb_invalidate(pml4e, va);
  8004202ef5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004202ef9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004202efd:	48 89 d6             	mov    %rdx,%rsi
  8004202f00:	48 89 c7             	mov    %rax,%rdi
  8004202f03:	48 b8 11 2f 20 04 80 	movabs $0x8004202f11,%rax
  8004202f0a:	00 00 00 
  8004202f0d:	ff d0                	callq  *%rax
        }
    }
}
  8004202f0f:	c9                   	leaveq 
  8004202f10:	c3                   	retq   

0000008004202f11 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pml4e_t *pml4e, void *va)
{
  8004202f11:	55                   	push   %rbp
  8004202f12:	48 89 e5             	mov    %rsp,%rbp
  8004202f15:	48 83 ec 20          	sub    $0x20,%rsp
  8004202f19:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004202f1d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004202f21:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004202f25:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
}

static __inline void 
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
  8004202f29:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202f2d:	0f 01 38             	invlpg (%rax)
    // Flush the entry only if we're modifying the current address space.
    // For now, there is only one address space, so always invalidate.
    invlpg(va);
}
  8004202f30:	c9                   	leaveq 
  8004202f31:	c3                   	retq   

0000008004202f32 <check_page_free_list>:
// Check that the pages on the page_free_list are reasonable.
//

static void
check_page_free_list(bool only_low_memory)
{
  8004202f32:	55                   	push   %rbp
  8004202f33:	48 89 e5             	mov    %rsp,%rbp
  8004202f36:	48 83 ec 60          	sub    $0x60,%rsp
  8004202f3a:	89 f8                	mov    %edi,%eax
  8004202f3c:	88 45 ac             	mov    %al,-0x54(%rbp)
    struct PageInfo *pp;
    unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
  8004202f3f:	80 7d ac 00          	cmpb   $0x0,-0x54(%rbp)
  8004202f43:	74 07                	je     8004202f4c <check_page_free_list+0x1a>
  8004202f45:	b8 01 00 00 00       	mov    $0x1,%eax
  8004202f4a:	eb 05                	jmp    8004202f51 <check_page_free_list+0x1f>
  8004202f4c:	b8 00 02 00 00       	mov    $0x200,%eax
  8004202f51:	89 45 e4             	mov    %eax,-0x1c(%rbp)
    uint64_t nfree_basemem = 0, nfree_extmem = 0;
  8004202f54:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004202f5b:	00 
  8004202f5c:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004202f63:	00 
    void *first_free_page;

    if (!page_free_list)
  8004202f64:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004202f6b:	00 00 00 
  8004202f6e:	48 8b 00             	mov    (%rax),%rax
  8004202f71:	48 85 c0             	test   %rax,%rax
  8004202f74:	75 2a                	jne    8004202fa0 <check_page_free_list+0x6e>
        panic("'page_free_list' is a null pointer!");
  8004202f76:	48 ba d0 e8 20 04 80 	movabs $0x800420e8d0,%rdx
  8004202f7d:	00 00 00 
  8004202f80:	be c6 02 00 00       	mov    $0x2c6,%esi
  8004202f85:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004202f8c:	00 00 00 
  8004202f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004202f94:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  8004202f9b:	00 00 00 
  8004202f9e:	ff d1                	callq  *%rcx

    if (only_low_memory) {
  8004202fa0:	80 7d ac 00          	cmpb   $0x0,-0x54(%rbp)
  8004202fa4:	0f 84 a9 00 00 00    	je     8004203053 <check_page_free_list+0x121>
        // Move pages with lower addresses first in the free
        // list, since entry_pgdir does not map all pages.
        struct PageInfo *pp1, *pp2;
        struct PageInfo **tp[2] = { &pp1, &pp2 };
  8004202faa:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8004202fae:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8004202fb2:	48 8d 45 c8          	lea    -0x38(%rbp),%rax
  8004202fb6:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
        for (pp = page_free_list; pp; pp = pp->pp_link) {
  8004202fba:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004202fc1:	00 00 00 
  8004202fc4:	48 8b 00             	mov    (%rax),%rax
  8004202fc7:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004202fcb:	eb 58                	jmp    8004203025 <check_page_free_list+0xf3>
            int pagetype = PDX(page2pa(pp)) >= pdx_limit;
  8004202fcd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004202fd1:	48 89 c7             	mov    %rax,%rdi
  8004202fd4:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004202fdb:	00 00 00 
  8004202fde:	ff d0                	callq  *%rax
  8004202fe0:	48 c1 e8 15          	shr    $0x15,%rax
  8004202fe4:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004202fe9:	48 89 c2             	mov    %rax,%rdx
  8004202fec:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004202fef:	48 39 c2             	cmp    %rax,%rdx
  8004202ff2:	0f 93 c0             	setae  %al
  8004202ff5:	0f b6 c0             	movzbl %al,%eax
  8004202ff8:	89 45 e0             	mov    %eax,-0x20(%rbp)
            *tp[pagetype] = pp;
  8004202ffb:	8b 45 e0             	mov    -0x20(%rbp),%eax
  8004202ffe:	48 98                	cltq   
  8004203000:	48 8b 44 c5 b0       	mov    -0x50(%rbp,%rax,8),%rax
  8004203005:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004203009:	48 89 10             	mov    %rdx,(%rax)
            tp[pagetype] = &pp->pp_link;
  800420300c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004203010:	8b 45 e0             	mov    -0x20(%rbp),%eax
  8004203013:	48 98                	cltq   
  8004203015:	48 89 54 c5 b0       	mov    %rdx,-0x50(%rbp,%rax,8)
    if (only_low_memory) {
        // Move pages with lower addresses first in the free
        // list, since entry_pgdir does not map all pages.
        struct PageInfo *pp1, *pp2;
        struct PageInfo **tp[2] = { &pp1, &pp2 };
        for (pp = page_free_list; pp; pp = pp->pp_link) {
  800420301a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420301e:	48 8b 00             	mov    (%rax),%rax
  8004203021:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203025:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420302a:	75 a1                	jne    8004202fcd <check_page_free_list+0x9b>
            int pagetype = PDX(page2pa(pp)) >= pdx_limit;
            *tp[pagetype] = pp;
            tp[pagetype] = &pp->pp_link;
        }
        *tp[1] = 0;
  800420302c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004203030:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
        *tp[0] = pp2;
  8004203037:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420303b:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420303f:	48 89 10             	mov    %rdx,(%rax)
        page_free_list = pp1;
  8004203042:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004203046:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  800420304d:	00 00 00 
  8004203050:	48 89 10             	mov    %rdx,(%rax)
    }

    // if there's a page that shouldn't be on the free list,
    // try to make sure it eventually causes trouble.
    for (pp = page_free_list; pp; pp = pp->pp_link)
  8004203053:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  800420305a:	00 00 00 
  800420305d:	48 8b 00             	mov    (%rax),%rax
  8004203060:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203064:	eb 5e                	jmp    80042030c4 <check_page_free_list+0x192>
        if (PDX(page2pa(pp)) < pdx_limit)
  8004203066:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420306a:	48 89 c7             	mov    %rax,%rdi
  800420306d:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004203074:	00 00 00 
  8004203077:	ff d0                	callq  *%rax
  8004203079:	48 c1 e8 15          	shr    $0x15,%rax
  800420307d:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004203082:	48 89 c2             	mov    %rax,%rdx
  8004203085:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004203088:	48 39 c2             	cmp    %rax,%rdx
  800420308b:	73 2c                	jae    80042030b9 <check_page_free_list+0x187>
            memset(page2kva(pp), 0x97, 128);
  800420308d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203091:	48 89 c7             	mov    %rax,%rdi
  8004203094:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  800420309b:	00 00 00 
  800420309e:	ff d0                	callq  *%rax
  80042030a0:	ba 80 00 00 00       	mov    $0x80,%edx
  80042030a5:	be 97 00 00 00       	mov    $0x97,%esi
  80042030aa:	48 89 c7             	mov    %rax,%rdi
  80042030ad:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  80042030b4:	00 00 00 
  80042030b7:	ff d0                	callq  *%rax
        page_free_list = pp1;
    }

    // if there's a page that shouldn't be on the free list,
    // try to make sure it eventually causes trouble.
    for (pp = page_free_list; pp; pp = pp->pp_link)
  80042030b9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042030bd:	48 8b 00             	mov    (%rax),%rax
  80042030c0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042030c4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042030c9:	75 9b                	jne    8004203066 <check_page_free_list+0x134>
        if (PDX(page2pa(pp)) < pdx_limit)
            memset(page2kva(pp), 0x97, 128);

    first_free_page = boot_alloc(0);
  80042030cb:	bf 00 00 00 00       	mov    $0x0,%edi
  80042030d0:	48 b8 5e 1e 20 04 80 	movabs $0x8004201e5e,%rax
  80042030d7:	00 00 00 
  80042030da:	ff d0                	callq  *%rax
  80042030dc:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  80042030e0:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  80042030e7:	00 00 00 
  80042030ea:	48 8b 00             	mov    (%rax),%rax
  80042030ed:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042030f1:	e9 d0 02 00 00       	jmpq   80042033c6 <check_page_free_list+0x494>
        // check that we didn't corrupt the free list itself
        assert(pp >= pages);
  80042030f6:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042030fd:	00 00 00 
  8004203100:	48 8b 00             	mov    (%rax),%rax
  8004203103:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  8004203107:	73 35                	jae    800420313e <check_page_free_list+0x20c>
  8004203109:	48 b9 f4 e8 20 04 80 	movabs $0x800420e8f4,%rcx
  8004203110:	00 00 00 
  8004203113:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420311a:	00 00 00 
  800420311d:	be e0 02 00 00       	mov    $0x2e0,%esi
  8004203122:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203129:	00 00 00 
  800420312c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203131:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203138:	00 00 00 
  800420313b:	41 ff d0             	callq  *%r8
        assert(pp < pages + npages);
  800420313e:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004203145:	00 00 00 
  8004203148:	48 8b 10             	mov    (%rax),%rdx
  800420314b:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004203152:	00 00 00 
  8004203155:	48 8b 00             	mov    (%rax),%rax
  8004203158:	48 c1 e0 04          	shl    $0x4,%rax
  800420315c:	48 01 d0             	add    %rdx,%rax
  800420315f:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8004203163:	77 35                	ja     800420319a <check_page_free_list+0x268>
  8004203165:	48 b9 00 e9 20 04 80 	movabs $0x800420e900,%rcx
  800420316c:	00 00 00 
  800420316f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203176:	00 00 00 
  8004203179:	be e1 02 00 00       	mov    $0x2e1,%esi
  800420317e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203185:	00 00 00 
  8004203188:	b8 00 00 00 00       	mov    $0x0,%eax
  800420318d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203194:	00 00 00 
  8004203197:	41 ff d0             	callq  *%r8
        assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
  800420319a:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420319e:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042031a5:	00 00 00 
  80042031a8:	48 8b 00             	mov    (%rax),%rax
  80042031ab:	48 29 c2             	sub    %rax,%rdx
  80042031ae:	48 89 d0             	mov    %rdx,%rax
  80042031b1:	83 e0 0f             	and    $0xf,%eax
  80042031b4:	48 85 c0             	test   %rax,%rax
  80042031b7:	74 35                	je     80042031ee <check_page_free_list+0x2bc>
  80042031b9:	48 b9 18 e9 20 04 80 	movabs $0x800420e918,%rcx
  80042031c0:	00 00 00 
  80042031c3:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042031ca:	00 00 00 
  80042031cd:	be e2 02 00 00       	mov    $0x2e2,%esi
  80042031d2:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042031d9:	00 00 00 
  80042031dc:	b8 00 00 00 00       	mov    $0x0,%eax
  80042031e1:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042031e8:	00 00 00 
  80042031eb:	41 ff d0             	callq  *%r8

        // check a few pages that shouldn't be on the free list
        assert(page2pa(pp) != 0);
  80042031ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042031f2:	48 89 c7             	mov    %rax,%rdi
  80042031f5:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042031fc:	00 00 00 
  80042031ff:	ff d0                	callq  *%rax
  8004203201:	48 85 c0             	test   %rax,%rax
  8004203204:	75 35                	jne    800420323b <check_page_free_list+0x309>
  8004203206:	48 b9 4a e9 20 04 80 	movabs $0x800420e94a,%rcx
  800420320d:	00 00 00 
  8004203210:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203217:	00 00 00 
  800420321a:	be e5 02 00 00       	mov    $0x2e5,%esi
  800420321f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203226:	00 00 00 
  8004203229:	b8 00 00 00 00       	mov    $0x0,%eax
  800420322e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203235:	00 00 00 
  8004203238:	41 ff d0             	callq  *%r8
        assert(page2pa(pp) != IOPHYSMEM);
  800420323b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420323f:	48 89 c7             	mov    %rax,%rdi
  8004203242:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004203249:	00 00 00 
  800420324c:	ff d0                	callq  *%rax
  800420324e:	48 3d 00 00 0a 00    	cmp    $0xa0000,%rax
  8004203254:	75 35                	jne    800420328b <check_page_free_list+0x359>
  8004203256:	48 b9 5b e9 20 04 80 	movabs $0x800420e95b,%rcx
  800420325d:	00 00 00 
  8004203260:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203267:	00 00 00 
  800420326a:	be e6 02 00 00       	mov    $0x2e6,%esi
  800420326f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203276:	00 00 00 
  8004203279:	b8 00 00 00 00       	mov    $0x0,%eax
  800420327e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203285:	00 00 00 
  8004203288:	41 ff d0             	callq  *%r8
        assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
  800420328b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420328f:	48 89 c7             	mov    %rax,%rdi
  8004203292:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004203299:	00 00 00 
  800420329c:	ff d0                	callq  *%rax
  800420329e:	48 3d 00 f0 0f 00    	cmp    $0xff000,%rax
  80042032a4:	75 35                	jne    80042032db <check_page_free_list+0x3a9>
  80042032a6:	48 b9 78 e9 20 04 80 	movabs $0x800420e978,%rcx
  80042032ad:	00 00 00 
  80042032b0:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042032b7:	00 00 00 
  80042032ba:	be e7 02 00 00       	mov    $0x2e7,%esi
  80042032bf:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042032c6:	00 00 00 
  80042032c9:	b8 00 00 00 00       	mov    $0x0,%eax
  80042032ce:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042032d5:	00 00 00 
  80042032d8:	41 ff d0             	callq  *%r8
        assert(page2pa(pp) != EXTPHYSMEM);
  80042032db:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042032df:	48 89 c7             	mov    %rax,%rdi
  80042032e2:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042032e9:	00 00 00 
  80042032ec:	ff d0                	callq  *%rax
  80042032ee:	48 3d 00 00 10 00    	cmp    $0x100000,%rax
  80042032f4:	75 35                	jne    800420332b <check_page_free_list+0x3f9>
  80042032f6:	48 b9 9b e9 20 04 80 	movabs $0x800420e99b,%rcx
  80042032fd:	00 00 00 
  8004203300:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203307:	00 00 00 
  800420330a:	be e8 02 00 00       	mov    $0x2e8,%esi
  800420330f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203316:	00 00 00 
  8004203319:	b8 00 00 00 00       	mov    $0x0,%eax
  800420331e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203325:	00 00 00 
  8004203328:	41 ff d0             	callq  *%r8
        assert(page2pa(pp) < EXTPHYSMEM || page2kva(pp) >= first_free_page);
  800420332b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420332f:	48 89 c7             	mov    %rax,%rdi
  8004203332:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004203339:	00 00 00 
  800420333c:	ff d0                	callq  *%rax
  800420333e:	48 3d ff ff 0f 00    	cmp    $0xfffff,%rax
  8004203344:	76 4e                	jbe    8004203394 <check_page_free_list+0x462>
  8004203346:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420334a:	48 89 c7             	mov    %rax,%rdi
  800420334d:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  8004203354:	00 00 00 
  8004203357:	ff d0                	callq  *%rax
  8004203359:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  800420335d:	73 35                	jae    8004203394 <check_page_free_list+0x462>
  800420335f:	48 b9 b8 e9 20 04 80 	movabs $0x800420e9b8,%rcx
  8004203366:	00 00 00 
  8004203369:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203370:	00 00 00 
  8004203373:	be e9 02 00 00       	mov    $0x2e9,%esi
  8004203378:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420337f:	00 00 00 
  8004203382:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203387:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420338e:	00 00 00 
  8004203391:	41 ff d0             	callq  *%r8

        if (page2pa(pp) < EXTPHYSMEM)
  8004203394:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203398:	48 89 c7             	mov    %rax,%rdi
  800420339b:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042033a2:	00 00 00 
  80042033a5:	ff d0                	callq  *%rax
  80042033a7:	48 3d ff ff 0f 00    	cmp    $0xfffff,%rax
  80042033ad:	77 07                	ja     80042033b6 <check_page_free_list+0x484>
            ++nfree_basemem;
  80042033af:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  80042033b4:	eb 05                	jmp    80042033bb <check_page_free_list+0x489>
        else
            ++nfree_extmem;
  80042033b6:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
    for (pp = page_free_list; pp; pp = pp->pp_link)
        if (PDX(page2pa(pp)) < pdx_limit)
            memset(page2kva(pp), 0x97, 128);

    first_free_page = boot_alloc(0);
    for (pp = page_free_list; pp; pp = pp->pp_link) {
  80042033bb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042033bf:	48 8b 00             	mov    (%rax),%rax
  80042033c2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042033c6:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042033cb:	0f 85 25 fd ff ff    	jne    80042030f6 <check_page_free_list+0x1c4>
            ++nfree_basemem;
        else
            ++nfree_extmem;
    }

    assert(nfree_extmem > 0);
  80042033d1:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042033d6:	75 35                	jne    800420340d <check_page_free_list+0x4db>
  80042033d8:	48 b9 f4 e9 20 04 80 	movabs $0x800420e9f4,%rcx
  80042033df:	00 00 00 
  80042033e2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042033e9:	00 00 00 
  80042033ec:	be f1 02 00 00       	mov    $0x2f1,%esi
  80042033f1:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042033f8:	00 00 00 
  80042033fb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203400:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203407:	00 00 00 
  800420340a:	41 ff d0             	callq  *%r8
}
  800420340d:	c9                   	leaveq 
  800420340e:	c3                   	retq   

000000800420340f <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
  800420340f:	55                   	push   %rbp
  8004203410:	48 89 e5             	mov    %rsp,%rbp
  8004203413:	48 83 ec 40          	sub    $0x40,%rsp
    int i;

    // if there's a page that shouldn't be on
    // the free list, try to make sure it
    // eventually causes trouble.
    for (pp0 = page_free_list, nfree = 0; pp0; pp0 = pp0->pp_link) {
  8004203417:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  800420341e:	00 00 00 
  8004203421:	48 8b 00             	mov    (%rax),%rax
  8004203424:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203428:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
  800420342f:	eb 37                	jmp    8004203468 <check_page_alloc+0x59>
        memset(page2kva(pp0), 0x97, PGSIZE);
  8004203431:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203435:	48 89 c7             	mov    %rax,%rdi
  8004203438:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  800420343f:	00 00 00 
  8004203442:	ff d0                	callq  *%rax
  8004203444:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004203449:	be 97 00 00 00       	mov    $0x97,%esi
  800420344e:	48 89 c7             	mov    %rax,%rdi
  8004203451:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004203458:	00 00 00 
  800420345b:	ff d0                	callq  *%rax
    int i;

    // if there's a page that shouldn't be on
    // the free list, try to make sure it
    // eventually causes trouble.
    for (pp0 = page_free_list, nfree = 0; pp0; pp0 = pp0->pp_link) {
  800420345d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203461:	48 8b 00             	mov    (%rax),%rax
  8004203464:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203468:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420346d:	75 c2                	jne    8004203431 <check_page_alloc+0x22>
        memset(page2kva(pp0), 0x97, PGSIZE);
    }

    for (pp0 = page_free_list, nfree = 0; pp0; pp0 = pp0->pp_link) {
  800420346f:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004203476:	00 00 00 
  8004203479:	48 8b 00             	mov    (%rax),%rax
  800420347c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203480:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
  8004203487:	e9 ec 01 00 00       	jmpq   8004203678 <check_page_alloc+0x269>
        // check that we didn't corrupt the free list itself
        assert(pp0 >= pages);
  800420348c:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  8004203493:	00 00 00 
  8004203496:	48 8b 00             	mov    (%rax),%rax
  8004203499:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  800420349d:	73 35                	jae    80042034d4 <check_page_alloc+0xc5>
  800420349f:	48 b9 05 ea 20 04 80 	movabs $0x800420ea05,%rcx
  80042034a6:	00 00 00 
  80042034a9:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042034b0:	00 00 00 
  80042034b3:	be 0b 03 00 00       	mov    $0x30b,%esi
  80042034b8:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042034bf:	00 00 00 
  80042034c2:	b8 00 00 00 00       	mov    $0x0,%eax
  80042034c7:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042034ce:	00 00 00 
  80042034d1:	41 ff d0             	callq  *%r8
        assert(pp0 < pages + npages);
  80042034d4:	48 b8 90 2d 22 04 80 	movabs $0x8004222d90,%rax
  80042034db:	00 00 00 
  80042034de:	48 8b 10             	mov    (%rax),%rdx
  80042034e1:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042034e8:	00 00 00 
  80042034eb:	48 8b 00             	mov    (%rax),%rax
  80042034ee:	48 c1 e0 04          	shl    $0x4,%rax
  80042034f2:	48 01 d0             	add    %rdx,%rax
  80042034f5:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  80042034f9:	77 35                	ja     8004203530 <check_page_alloc+0x121>
  80042034fb:	48 b9 12 ea 20 04 80 	movabs $0x800420ea12,%rcx
  8004203502:	00 00 00 
  8004203505:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420350c:	00 00 00 
  800420350f:	be 0c 03 00 00       	mov    $0x30c,%esi
  8004203514:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420351b:	00 00 00 
  800420351e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203523:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420352a:	00 00 00 
  800420352d:	41 ff d0             	callq  *%r8

        // check a few pages that shouldn't be on the free list
        assert(page2pa(pp0) != 0);
  8004203530:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203534:	48 89 c7             	mov    %rax,%rdi
  8004203537:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420353e:	00 00 00 
  8004203541:	ff d0                	callq  *%rax
  8004203543:	48 85 c0             	test   %rax,%rax
  8004203546:	75 35                	jne    800420357d <check_page_alloc+0x16e>
  8004203548:	48 b9 27 ea 20 04 80 	movabs $0x800420ea27,%rcx
  800420354f:	00 00 00 
  8004203552:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203559:	00 00 00 
  800420355c:	be 0f 03 00 00       	mov    $0x30f,%esi
  8004203561:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203568:	00 00 00 
  800420356b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203570:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203577:	00 00 00 
  800420357a:	41 ff d0             	callq  *%r8
        assert(page2pa(pp0) != IOPHYSMEM);
  800420357d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203581:	48 89 c7             	mov    %rax,%rdi
  8004203584:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420358b:	00 00 00 
  800420358e:	ff d0                	callq  *%rax
  8004203590:	48 3d 00 00 0a 00    	cmp    $0xa0000,%rax
  8004203596:	75 35                	jne    80042035cd <check_page_alloc+0x1be>
  8004203598:	48 b9 39 ea 20 04 80 	movabs $0x800420ea39,%rcx
  800420359f:	00 00 00 
  80042035a2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042035a9:	00 00 00 
  80042035ac:	be 10 03 00 00       	mov    $0x310,%esi
  80042035b1:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042035b8:	00 00 00 
  80042035bb:	b8 00 00 00 00       	mov    $0x0,%eax
  80042035c0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042035c7:	00 00 00 
  80042035ca:	41 ff d0             	callq  *%r8
        assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
  80042035cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042035d1:	48 89 c7             	mov    %rax,%rdi
  80042035d4:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042035db:	00 00 00 
  80042035de:	ff d0                	callq  *%rax
  80042035e0:	48 3d 00 f0 0f 00    	cmp    $0xff000,%rax
  80042035e6:	75 35                	jne    800420361d <check_page_alloc+0x20e>
  80042035e8:	48 b9 58 ea 20 04 80 	movabs $0x800420ea58,%rcx
  80042035ef:	00 00 00 
  80042035f2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042035f9:	00 00 00 
  80042035fc:	be 11 03 00 00       	mov    $0x311,%esi
  8004203601:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203608:	00 00 00 
  800420360b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203610:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203617:	00 00 00 
  800420361a:	41 ff d0             	callq  *%r8
        assert(page2pa(pp0) != EXTPHYSMEM);
  800420361d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203621:	48 89 c7             	mov    %rax,%rdi
  8004203624:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420362b:	00 00 00 
  800420362e:	ff d0                	callq  *%rax
  8004203630:	48 3d 00 00 10 00    	cmp    $0x100000,%rax
  8004203636:	75 35                	jne    800420366d <check_page_alloc+0x25e>
  8004203638:	48 b9 7c ea 20 04 80 	movabs $0x800420ea7c,%rcx
  800420363f:	00 00 00 
  8004203642:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203649:	00 00 00 
  800420364c:	be 12 03 00 00       	mov    $0x312,%esi
  8004203651:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203658:	00 00 00 
  800420365b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203660:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203667:	00 00 00 
  800420366a:	41 ff d0             	callq  *%r8
    // eventually causes trouble.
    for (pp0 = page_free_list, nfree = 0; pp0; pp0 = pp0->pp_link) {
        memset(page2kva(pp0), 0x97, PGSIZE);
    }

    for (pp0 = page_free_list, nfree = 0; pp0; pp0 = pp0->pp_link) {
  800420366d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203671:	48 8b 00             	mov    (%rax),%rax
  8004203674:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203678:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420367d:	0f 85 09 fe ff ff    	jne    800420348c <check_page_alloc+0x7d>
        assert(page2pa(pp0) != IOPHYSMEM);
        assert(page2pa(pp0) != EXTPHYSMEM - PGSIZE);
        assert(page2pa(pp0) != EXTPHYSMEM);
    }
    // should be able to allocate three pages
    pp0 = pp1 = pp2 = 0;
  8004203683:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  800420368a:	00 
  800420368b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420368f:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004203693:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203697:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    assert((pp0 = page_alloc(0)));
  800420369b:	bf 00 00 00 00       	mov    $0x0,%edi
  80042036a0:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042036a7:	00 00 00 
  80042036aa:	ff d0                	callq  *%rax
  80042036ac:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042036b0:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  80042036b5:	75 35                	jne    80042036ec <check_page_alloc+0x2dd>
  80042036b7:	48 b9 97 ea 20 04 80 	movabs $0x800420ea97,%rcx
  80042036be:	00 00 00 
  80042036c1:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042036c8:	00 00 00 
  80042036cb:	be 16 03 00 00       	mov    $0x316,%esi
  80042036d0:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042036d7:	00 00 00 
  80042036da:	b8 00 00 00 00       	mov    $0x0,%eax
  80042036df:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042036e6:	00 00 00 
  80042036e9:	41 ff d0             	callq  *%r8
    assert((pp1 = page_alloc(0)));
  80042036ec:	bf 00 00 00 00       	mov    $0x0,%edi
  80042036f1:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042036f8:	00 00 00 
  80042036fb:	ff d0                	callq  *%rax
  80042036fd:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004203701:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004203706:	75 35                	jne    800420373d <check_page_alloc+0x32e>
  8004203708:	48 b9 ad ea 20 04 80 	movabs $0x800420eaad,%rcx
  800420370f:	00 00 00 
  8004203712:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203719:	00 00 00 
  800420371c:	be 17 03 00 00       	mov    $0x317,%esi
  8004203721:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203728:	00 00 00 
  800420372b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203730:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203737:	00 00 00 
  800420373a:	41 ff d0             	callq  *%r8
    assert((pp2 = page_alloc(0)));
  800420373d:	bf 00 00 00 00       	mov    $0x0,%edi
  8004203742:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203749:	00 00 00 
  800420374c:	ff d0                	callq  *%rax
  800420374e:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004203752:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004203757:	75 35                	jne    800420378e <check_page_alloc+0x37f>
  8004203759:	48 b9 c3 ea 20 04 80 	movabs $0x800420eac3,%rcx
  8004203760:	00 00 00 
  8004203763:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420376a:	00 00 00 
  800420376d:	be 18 03 00 00       	mov    $0x318,%esi
  8004203772:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203779:	00 00 00 
  800420377c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203781:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203788:	00 00 00 
  800420378b:	41 ff d0             	callq  *%r8
    assert(pp0);
  800420378e:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004203793:	75 35                	jne    80042037ca <check_page_alloc+0x3bb>
  8004203795:	48 b9 d9 ea 20 04 80 	movabs $0x800420ead9,%rcx
  800420379c:	00 00 00 
  800420379f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042037a6:	00 00 00 
  80042037a9:	be 19 03 00 00       	mov    $0x319,%esi
  80042037ae:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042037b5:	00 00 00 
  80042037b8:	b8 00 00 00 00       	mov    $0x0,%eax
  80042037bd:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042037c4:	00 00 00 
  80042037c7:	41 ff d0             	callq  *%r8
    assert(pp1 && pp1 != pp0);
  80042037ca:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  80042037cf:	74 0a                	je     80042037db <check_page_alloc+0x3cc>
  80042037d1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042037d5:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  80042037d9:	75 35                	jne    8004203810 <check_page_alloc+0x401>
  80042037db:	48 b9 dd ea 20 04 80 	movabs $0x800420eadd,%rcx
  80042037e2:	00 00 00 
  80042037e5:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042037ec:	00 00 00 
  80042037ef:	be 1a 03 00 00       	mov    $0x31a,%esi
  80042037f4:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042037fb:	00 00 00 
  80042037fe:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203803:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420380a:	00 00 00 
  800420380d:	41 ff d0             	callq  *%r8
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8004203810:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004203815:	74 14                	je     800420382b <check_page_alloc+0x41c>
  8004203817:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420381b:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420381f:	74 0a                	je     800420382b <check_page_alloc+0x41c>
  8004203821:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203825:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8004203829:	75 35                	jne    8004203860 <check_page_alloc+0x451>
  800420382b:	48 b9 f0 ea 20 04 80 	movabs $0x800420eaf0,%rcx
  8004203832:	00 00 00 
  8004203835:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420383c:	00 00 00 
  800420383f:	be 1b 03 00 00       	mov    $0x31b,%esi
  8004203844:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420384b:	00 00 00 
  800420384e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203853:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420385a:	00 00 00 
  800420385d:	41 ff d0             	callq  *%r8
    assert(page2pa(pp0) < npages*PGSIZE);
  8004203860:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203864:	48 89 c7             	mov    %rax,%rdi
  8004203867:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420386e:	00 00 00 
  8004203871:	ff d0                	callq  *%rax
  8004203873:	48 ba 88 2d 22 04 80 	movabs $0x8004222d88,%rdx
  800420387a:	00 00 00 
  800420387d:	48 8b 12             	mov    (%rdx),%rdx
  8004203880:	48 c1 e2 0c          	shl    $0xc,%rdx
  8004203884:	48 39 d0             	cmp    %rdx,%rax
  8004203887:	72 35                	jb     80042038be <check_page_alloc+0x4af>
  8004203889:	48 b9 10 eb 20 04 80 	movabs $0x800420eb10,%rcx
  8004203890:	00 00 00 
  8004203893:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420389a:	00 00 00 
  800420389d:	be 1c 03 00 00       	mov    $0x31c,%esi
  80042038a2:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042038a9:	00 00 00 
  80042038ac:	b8 00 00 00 00       	mov    $0x0,%eax
  80042038b1:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042038b8:	00 00 00 
  80042038bb:	41 ff d0             	callq  *%r8
    assert(page2pa(pp1) < npages*PGSIZE);
  80042038be:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042038c2:	48 89 c7             	mov    %rax,%rdi
  80042038c5:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042038cc:	00 00 00 
  80042038cf:	ff d0                	callq  *%rax
  80042038d1:	48 ba 88 2d 22 04 80 	movabs $0x8004222d88,%rdx
  80042038d8:	00 00 00 
  80042038db:	48 8b 12             	mov    (%rdx),%rdx
  80042038de:	48 c1 e2 0c          	shl    $0xc,%rdx
  80042038e2:	48 39 d0             	cmp    %rdx,%rax
  80042038e5:	72 35                	jb     800420391c <check_page_alloc+0x50d>
  80042038e7:	48 b9 2d eb 20 04 80 	movabs $0x800420eb2d,%rcx
  80042038ee:	00 00 00 
  80042038f1:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042038f8:	00 00 00 
  80042038fb:	be 1d 03 00 00       	mov    $0x31d,%esi
  8004203900:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203907:	00 00 00 
  800420390a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420390f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203916:	00 00 00 
  8004203919:	41 ff d0             	callq  *%r8
    assert(page2pa(pp2) < npages*PGSIZE);
  800420391c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203920:	48 89 c7             	mov    %rax,%rdi
  8004203923:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420392a:	00 00 00 
  800420392d:	ff d0                	callq  *%rax
  800420392f:	48 ba 88 2d 22 04 80 	movabs $0x8004222d88,%rdx
  8004203936:	00 00 00 
  8004203939:	48 8b 12             	mov    (%rdx),%rdx
  800420393c:	48 c1 e2 0c          	shl    $0xc,%rdx
  8004203940:	48 39 d0             	cmp    %rdx,%rax
  8004203943:	72 35                	jb     800420397a <check_page_alloc+0x56b>
  8004203945:	48 b9 4a eb 20 04 80 	movabs $0x800420eb4a,%rcx
  800420394c:	00 00 00 
  800420394f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203956:	00 00 00 
  8004203959:	be 1e 03 00 00       	mov    $0x31e,%esi
  800420395e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203965:	00 00 00 
  8004203968:	b8 00 00 00 00       	mov    $0x0,%eax
  800420396d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203974:	00 00 00 
  8004203977:	41 ff d0             	callq  *%r8

    // temporarily steal the rest of the free pages
    fl = page_free_list;
  800420397a:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004203981:	00 00 00 
  8004203984:	48 8b 00             	mov    (%rax),%rax
  8004203987:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    page_free_list = 0;
  800420398b:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004203992:	00 00 00 
  8004203995:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    // should be no free memory
    assert(!page_alloc(0));
  800420399c:	bf 00 00 00 00       	mov    $0x0,%edi
  80042039a1:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042039a8:	00 00 00 
  80042039ab:	ff d0                	callq  *%rax
  80042039ad:	48 85 c0             	test   %rax,%rax
  80042039b0:	74 35                	je     80042039e7 <check_page_alloc+0x5d8>
  80042039b2:	48 b9 67 eb 20 04 80 	movabs $0x800420eb67,%rcx
  80042039b9:	00 00 00 
  80042039bc:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042039c3:	00 00 00 
  80042039c6:	be 25 03 00 00       	mov    $0x325,%esi
  80042039cb:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042039d2:	00 00 00 
  80042039d5:	b8 00 00 00 00       	mov    $0x0,%eax
  80042039da:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042039e1:	00 00 00 
  80042039e4:	41 ff d0             	callq  *%r8

    // free and re-allocate?
    page_free(pp0);
  80042039e7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042039eb:	48 89 c7             	mov    %rax,%rdi
  80042039ee:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  80042039f5:	00 00 00 
  80042039f8:	ff d0                	callq  *%rax
    page_free(pp1);
  80042039fa:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042039fe:	48 89 c7             	mov    %rax,%rdi
  8004203a01:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203a08:	00 00 00 
  8004203a0b:	ff d0                	callq  *%rax
    page_free(pp2);
  8004203a0d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203a11:	48 89 c7             	mov    %rax,%rdi
  8004203a14:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203a1b:	00 00 00 
  8004203a1e:	ff d0                	callq  *%rax
    pp0 = pp1 = pp2 = 0;
  8004203a20:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004203a27:	00 
  8004203a28:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203a2c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004203a30:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203a34:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    assert((pp0 = page_alloc(0)));
  8004203a38:	bf 00 00 00 00       	mov    $0x0,%edi
  8004203a3d:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203a44:	00 00 00 
  8004203a47:	ff d0                	callq  *%rax
  8004203a49:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004203a4d:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004203a52:	75 35                	jne    8004203a89 <check_page_alloc+0x67a>
  8004203a54:	48 b9 97 ea 20 04 80 	movabs $0x800420ea97,%rcx
  8004203a5b:	00 00 00 
  8004203a5e:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203a65:	00 00 00 
  8004203a68:	be 2c 03 00 00       	mov    $0x32c,%esi
  8004203a6d:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203a74:	00 00 00 
  8004203a77:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203a7c:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203a83:	00 00 00 
  8004203a86:	41 ff d0             	callq  *%r8
    assert((pp1 = page_alloc(0)));
  8004203a89:	bf 00 00 00 00       	mov    $0x0,%edi
  8004203a8e:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203a95:	00 00 00 
  8004203a98:	ff d0                	callq  *%rax
  8004203a9a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004203a9e:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004203aa3:	75 35                	jne    8004203ada <check_page_alloc+0x6cb>
  8004203aa5:	48 b9 ad ea 20 04 80 	movabs $0x800420eaad,%rcx
  8004203aac:	00 00 00 
  8004203aaf:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203ab6:	00 00 00 
  8004203ab9:	be 2d 03 00 00       	mov    $0x32d,%esi
  8004203abe:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203ac5:	00 00 00 
  8004203ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203acd:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203ad4:	00 00 00 
  8004203ad7:	41 ff d0             	callq  *%r8
    assert((pp2 = page_alloc(0)));
  8004203ada:	bf 00 00 00 00       	mov    $0x0,%edi
  8004203adf:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203ae6:	00 00 00 
  8004203ae9:	ff d0                	callq  *%rax
  8004203aeb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  8004203aef:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004203af4:	75 35                	jne    8004203b2b <check_page_alloc+0x71c>
  8004203af6:	48 b9 c3 ea 20 04 80 	movabs $0x800420eac3,%rcx
  8004203afd:	00 00 00 
  8004203b00:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203b07:	00 00 00 
  8004203b0a:	be 2e 03 00 00       	mov    $0x32e,%esi
  8004203b0f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203b16:	00 00 00 
  8004203b19:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203b1e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203b25:	00 00 00 
  8004203b28:	41 ff d0             	callq  *%r8
    assert(pp0);
  8004203b2b:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004203b30:	75 35                	jne    8004203b67 <check_page_alloc+0x758>
  8004203b32:	48 b9 d9 ea 20 04 80 	movabs $0x800420ead9,%rcx
  8004203b39:	00 00 00 
  8004203b3c:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203b43:	00 00 00 
  8004203b46:	be 2f 03 00 00       	mov    $0x32f,%esi
  8004203b4b:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203b52:	00 00 00 
  8004203b55:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203b5a:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203b61:	00 00 00 
  8004203b64:	41 ff d0             	callq  *%r8
    assert(pp1 && pp1 != pp0);
  8004203b67:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004203b6c:	74 0a                	je     8004203b78 <check_page_alloc+0x769>
  8004203b6e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203b72:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8004203b76:	75 35                	jne    8004203bad <check_page_alloc+0x79e>
  8004203b78:	48 b9 dd ea 20 04 80 	movabs $0x800420eadd,%rcx
  8004203b7f:	00 00 00 
  8004203b82:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203b89:	00 00 00 
  8004203b8c:	be 30 03 00 00       	mov    $0x330,%esi
  8004203b91:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203b98:	00 00 00 
  8004203b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203ba0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203ba7:	00 00 00 
  8004203baa:	41 ff d0             	callq  *%r8
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
  8004203bad:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004203bb2:	74 14                	je     8004203bc8 <check_page_alloc+0x7b9>
  8004203bb4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203bb8:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004203bbc:	74 0a                	je     8004203bc8 <check_page_alloc+0x7b9>
  8004203bbe:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203bc2:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  8004203bc6:	75 35                	jne    8004203bfd <check_page_alloc+0x7ee>
  8004203bc8:	48 b9 f0 ea 20 04 80 	movabs $0x800420eaf0,%rcx
  8004203bcf:	00 00 00 
  8004203bd2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203bd9:	00 00 00 
  8004203bdc:	be 31 03 00 00       	mov    $0x331,%esi
  8004203be1:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203be8:	00 00 00 
  8004203beb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203bf0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203bf7:	00 00 00 
  8004203bfa:	41 ff d0             	callq  *%r8
    assert(!page_alloc(0));
  8004203bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  8004203c02:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203c09:	00 00 00 
  8004203c0c:	ff d0                	callq  *%rax
  8004203c0e:	48 85 c0             	test   %rax,%rax
  8004203c11:	74 35                	je     8004203c48 <check_page_alloc+0x839>
  8004203c13:	48 b9 67 eb 20 04 80 	movabs $0x800420eb67,%rcx
  8004203c1a:	00 00 00 
  8004203c1d:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203c24:	00 00 00 
  8004203c27:	be 32 03 00 00       	mov    $0x332,%esi
  8004203c2c:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203c33:	00 00 00 
  8004203c36:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203c3b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203c42:	00 00 00 
  8004203c45:	41 ff d0             	callq  *%r8

    // test flags
    memset(page2kva(pp0), 1, PGSIZE);
  8004203c48:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203c4c:	48 89 c7             	mov    %rax,%rdi
  8004203c4f:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  8004203c56:	00 00 00 
  8004203c59:	ff d0                	callq  *%rax
  8004203c5b:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004203c60:	be 01 00 00 00       	mov    $0x1,%esi
  8004203c65:	48 89 c7             	mov    %rax,%rdi
  8004203c68:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004203c6f:	00 00 00 
  8004203c72:	ff d0                	callq  *%rax
    page_free(pp0);
  8004203c74:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203c78:	48 89 c7             	mov    %rax,%rdi
  8004203c7b:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203c82:	00 00 00 
  8004203c85:	ff d0                	callq  *%rax
    assert((pp = page_alloc(ALLOC_ZERO)));
  8004203c87:	bf 01 00 00 00       	mov    $0x1,%edi
  8004203c8c:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004203c93:	00 00 00 
  8004203c96:	ff d0                	callq  *%rax
  8004203c98:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004203c9c:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004203ca1:	75 35                	jne    8004203cd8 <check_page_alloc+0x8c9>
  8004203ca3:	48 b9 76 eb 20 04 80 	movabs $0x800420eb76,%rcx
  8004203caa:	00 00 00 
  8004203cad:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203cb4:	00 00 00 
  8004203cb7:	be 37 03 00 00       	mov    $0x337,%esi
  8004203cbc:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203cc3:	00 00 00 
  8004203cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203ccb:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203cd2:	00 00 00 
  8004203cd5:	41 ff d0             	callq  *%r8
    assert(pp && pp0 == pp);
  8004203cd8:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004203cdd:	74 0a                	je     8004203ce9 <check_page_alloc+0x8da>
  8004203cdf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203ce3:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004203ce7:	74 35                	je     8004203d1e <check_page_alloc+0x90f>
  8004203ce9:	48 b9 94 eb 20 04 80 	movabs $0x800420eb94,%rcx
  8004203cf0:	00 00 00 
  8004203cf3:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203cfa:	00 00 00 
  8004203cfd:	be 38 03 00 00       	mov    $0x338,%esi
  8004203d02:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203d09:	00 00 00 
  8004203d0c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203d11:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203d18:	00 00 00 
  8004203d1b:	41 ff d0             	callq  *%r8
    c = page2kva(pp);
  8004203d1e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203d22:	48 89 c7             	mov    %rax,%rdi
  8004203d25:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  8004203d2c:	00 00 00 
  8004203d2f:	ff d0                	callq  *%rax
  8004203d31:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    for (i = 0; i < PGSIZE; i++)
  8004203d35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  8004203d3c:	eb 4d                	jmp    8004203d8b <check_page_alloc+0x97c>
        assert(c[i] == 0);
  8004203d3e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004203d41:	48 63 d0             	movslq %eax,%rdx
  8004203d44:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004203d48:	48 01 d0             	add    %rdx,%rax
  8004203d4b:	0f b6 00             	movzbl (%rax),%eax
  8004203d4e:	84 c0                	test   %al,%al
  8004203d50:	74 35                	je     8004203d87 <check_page_alloc+0x978>
  8004203d52:	48 b9 a4 eb 20 04 80 	movabs $0x800420eba4,%rcx
  8004203d59:	00 00 00 
  8004203d5c:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203d63:	00 00 00 
  8004203d66:	be 3b 03 00 00       	mov    $0x33b,%esi
  8004203d6b:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203d72:	00 00 00 
  8004203d75:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203d7a:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203d81:	00 00 00 
  8004203d84:	41 ff d0             	callq  *%r8
    memset(page2kva(pp0), 1, PGSIZE);
    page_free(pp0);
    assert((pp = page_alloc(ALLOC_ZERO)));
    assert(pp && pp0 == pp);
    c = page2kva(pp);
    for (i = 0; i < PGSIZE; i++)
  8004203d87:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  8004203d8b:	81 7d f4 ff 0f 00 00 	cmpl   $0xfff,-0xc(%rbp)
  8004203d92:	7e aa                	jle    8004203d3e <check_page_alloc+0x92f>
        assert(c[i] == 0);

    // give free list back
    page_free_list = fl;
  8004203d94:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004203d9b:	00 00 00 
  8004203d9e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004203da2:	48 89 10             	mov    %rdx,(%rax)

    // free the pages we took
    page_free(pp0);
  8004203da5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004203da9:	48 89 c7             	mov    %rax,%rdi
  8004203dac:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203db3:	00 00 00 
  8004203db6:	ff d0                	callq  *%rax
    page_free(pp1);
  8004203db8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203dbc:	48 89 c7             	mov    %rax,%rdi
  8004203dbf:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203dc6:	00 00 00 
  8004203dc9:	ff d0                	callq  *%rax
    page_free(pp2);
  8004203dcb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203dcf:	48 89 c7             	mov    %rax,%rdi
  8004203dd2:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004203dd9:	00 00 00 
  8004203ddc:	ff d0                	callq  *%rax

    cprintf("check_page_alloc() succeeded!\n");
  8004203dde:	48 bf b0 eb 20 04 80 	movabs $0x800420ebb0,%rdi
  8004203de5:	00 00 00 
  8004203de8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203ded:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004203df4:	00 00 00 
  8004203df7:	ff d2                	callq  *%rdx
}
  8004203df9:	c9                   	leaveq 
  8004203dfa:	c3                   	retq   

0000008004203dfb <check_boot_pml4e>:
// but it is a pretty good sanity check.
//

static void
check_boot_pml4e(pml4e_t *pml4e)
{
  8004203dfb:	55                   	push   %rbp
  8004203dfc:	48 89 e5             	mov    %rsp,%rbp
  8004203dff:	53                   	push   %rbx
  8004203e00:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  8004203e07:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
    uint64_t i, n;

    pml4e = boot_pml4e;
  8004203e0e:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004203e15:	00 00 00 
  8004203e18:	48 8b 00             	mov    (%rax),%rax
  8004203e1b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

    // check pages array
    n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
  8004203e1f:	48 c7 45 d8 00 10 00 	movq   $0x1000,-0x28(%rbp)
  8004203e26:	00 
  8004203e27:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004203e2e:	00 00 00 
  8004203e31:	48 8b 00             	mov    (%rax),%rax
  8004203e34:	48 c1 e0 04          	shl    $0x4,%rax
  8004203e38:	48 89 c2             	mov    %rax,%rdx
  8004203e3b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004203e3f:	48 01 d0             	add    %rdx,%rax
  8004203e42:	48 83 e8 01          	sub    $0x1,%rax
  8004203e46:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004203e4a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004203e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  8004203e53:	48 f7 75 d8          	divq   -0x28(%rbp)
  8004203e57:	48 89 d0             	mov    %rdx,%rax
  8004203e5a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004203e5e:	48 29 c2             	sub    %rax,%rdx
  8004203e61:	48 89 d0             	mov    %rdx,%rax
  8004203e64:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    for (i = 0; i < n; i += PGSIZE) {
  8004203e68:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004203e6f:	00 
  8004203e70:	e9 d4 00 00 00       	jmpq   8004203f49 <check_boot_pml4e+0x14e>
        // cprintf("%x %x %x\n",i,check_va2pa(pml4e, UPAGES + i), PADDR(pages) + i);
        assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
  8004203e75:	48 ba 00 00 a0 00 80 	movabs $0x8000a00000,%rdx
  8004203e7c:	00 00 00 
  8004203e7f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203e83:	48 01 c2             	add    %rax,%rdx
  8004203e86:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203e8a:	48 89 d6             	mov    %rdx,%rsi
  8004203e8d:	48 89 c7             	mov    %rax,%rdi
  8004203e90:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004203e97:	00 00 00 
  8004203e9a:	ff d0                	callq  *%rax
  8004203e9c:	48 ba 90 2d 22 04 80 	movabs $0x8004222d90,%rdx
  8004203ea3:	00 00 00 
  8004203ea6:	48 8b 12             	mov    (%rdx),%rdx
  8004203ea9:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8004203ead:	48 ba ff ff ff 03 80 	movabs $0x8003ffffff,%rdx
  8004203eb4:	00 00 00 
  8004203eb7:	48 39 55 c0          	cmp    %rdx,-0x40(%rbp)
  8004203ebb:	77 32                	ja     8004203eef <check_boot_pml4e+0xf4>
  8004203ebd:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004203ec1:	48 89 c1             	mov    %rax,%rcx
  8004203ec4:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  8004203ecb:	00 00 00 
  8004203ece:	be 5b 03 00 00       	mov    $0x35b,%esi
  8004203ed3:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203eda:	00 00 00 
  8004203edd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203ee2:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203ee9:	00 00 00 
  8004203eec:	41 ff d0             	callq  *%r8
  8004203eef:	48 b9 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rcx
  8004203ef6:	ff ff ff 
  8004203ef9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004203efd:	48 01 d1             	add    %rdx,%rcx
  8004203f00:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004203f04:	48 01 ca             	add    %rcx,%rdx
  8004203f07:	48 39 d0             	cmp    %rdx,%rax
  8004203f0a:	74 35                	je     8004203f41 <check_boot_pml4e+0x146>
  8004203f0c:	48 b9 d0 eb 20 04 80 	movabs $0x800420ebd0,%rcx
  8004203f13:	00 00 00 
  8004203f16:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203f1d:	00 00 00 
  8004203f20:	be 5b 03 00 00       	mov    $0x35b,%esi
  8004203f25:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203f2c:	00 00 00 
  8004203f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203f34:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203f3b:	00 00 00 
  8004203f3e:	41 ff d0             	callq  *%r8

    pml4e = boot_pml4e;

    // check pages array
    n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
    for (i = 0; i < n; i += PGSIZE) {
  8004203f41:	48 81 45 e8 00 10 00 	addq   $0x1000,-0x18(%rbp)
  8004203f48:	00 
  8004203f49:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f4d:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004203f51:	0f 82 1e ff ff ff    	jb     8004203e75 <check_boot_pml4e+0x7a>
        assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
    }


    // check phys mem
    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8004203f57:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004203f5e:	00 
  8004203f5f:	eb 6a                	jmp    8004203fcb <check_boot_pml4e+0x1d0>
        assert(check_va2pa(pml4e, KERNBASE + i) == i);
  8004203f61:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004203f68:	00 00 00 
  8004203f6b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004203f6f:	48 01 c2             	add    %rax,%rdx
  8004203f72:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004203f76:	48 89 d6             	mov    %rdx,%rsi
  8004203f79:	48 89 c7             	mov    %rax,%rdi
  8004203f7c:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004203f83:	00 00 00 
  8004203f86:	ff d0                	callq  *%rax
  8004203f88:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  8004203f8c:	74 35                	je     8004203fc3 <check_boot_pml4e+0x1c8>
  8004203f8e:	48 b9 08 ec 20 04 80 	movabs $0x800420ec08,%rcx
  8004203f95:	00 00 00 
  8004203f98:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004203f9f:	00 00 00 
  8004203fa2:	be 61 03 00 00       	mov    $0x361,%esi
  8004203fa7:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004203fae:	00 00 00 
  8004203fb1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004203fb6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004203fbd:	00 00 00 
  8004203fc0:	41 ff d0             	callq  *%r8
        assert(check_va2pa(pml4e, UPAGES + i) == PADDR(pages) + i);
    }


    // check phys mem
    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
  8004203fc3:	48 81 45 e8 00 10 00 	addq   $0x1000,-0x18(%rbp)
  8004203fca:	00 
  8004203fcb:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004203fd2:	00 00 00 
  8004203fd5:	48 8b 00             	mov    (%rax),%rax
  8004203fd8:	48 c1 e0 0c          	shl    $0xc,%rax
  8004203fdc:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  8004203fe0:	0f 87 7b ff ff ff    	ja     8004203f61 <check_boot_pml4e+0x166>
        assert(check_va2pa(pml4e, KERNBASE + i) == i);

    // check kernel stack
    for (i = 0; i < KSTKSIZE; i += PGSIZE) {
  8004203fe6:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004203fed:	00 
  8004203fee:	e9 d1 00 00 00       	jmpq   80042040c4 <check_boot_pml4e+0x2c9>
        assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
  8004203ff3:	48 ba 00 00 ff 03 80 	movabs $0x8003ff0000,%rdx
  8004203ffa:	00 00 00 
  8004203ffd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204001:	48 01 c2             	add    %rax,%rdx
  8004204004:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204008:	48 89 d6             	mov    %rdx,%rsi
  800420400b:	48 89 c7             	mov    %rax,%rdi
  800420400e:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004204015:	00 00 00 
  8004204018:	ff d0                	callq  *%rax
  800420401a:	48 bb 00 20 21 04 80 	movabs $0x8004212000,%rbx
  8004204021:	00 00 00 
  8004204024:	48 89 5d b8          	mov    %rbx,-0x48(%rbp)
  8004204028:	48 ba ff ff ff 03 80 	movabs $0x8003ffffff,%rdx
  800420402f:	00 00 00 
  8004204032:	48 39 55 b8          	cmp    %rdx,-0x48(%rbp)
  8004204036:	77 32                	ja     800420406a <check_boot_pml4e+0x26f>
  8004204038:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420403c:	48 89 c1             	mov    %rax,%rcx
  800420403f:	48 ba 60 e8 20 04 80 	movabs $0x800420e860,%rdx
  8004204046:	00 00 00 
  8004204049:	be 65 03 00 00       	mov    $0x365,%esi
  800420404e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204055:	00 00 00 
  8004204058:	b8 00 00 00 00       	mov    $0x0,%eax
  800420405d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204064:	00 00 00 
  8004204067:	41 ff d0             	callq  *%r8
  800420406a:	48 b9 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rcx
  8004204071:	ff ff ff 
  8004204074:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004204078:	48 01 d1             	add    %rdx,%rcx
  800420407b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420407f:	48 01 ca             	add    %rcx,%rdx
  8004204082:	48 39 d0             	cmp    %rdx,%rax
  8004204085:	74 35                	je     80042040bc <check_boot_pml4e+0x2c1>
  8004204087:	48 b9 30 ec 20 04 80 	movabs $0x800420ec30,%rcx
  800420408e:	00 00 00 
  8004204091:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204098:	00 00 00 
  800420409b:	be 65 03 00 00       	mov    $0x365,%esi
  80042040a0:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042040a7:	00 00 00 
  80042040aa:	b8 00 00 00 00       	mov    $0x0,%eax
  80042040af:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042040b6:	00 00 00 
  80042040b9:	41 ff d0             	callq  *%r8
    // check phys mem
    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
        assert(check_va2pa(pml4e, KERNBASE + i) == i);

    // check kernel stack
    for (i = 0; i < KSTKSIZE; i += PGSIZE) {
  80042040bc:	48 81 45 e8 00 10 00 	addq   $0x1000,-0x18(%rbp)
  80042040c3:	00 
  80042040c4:	48 81 7d e8 ff ff 00 	cmpq   $0xffff,-0x18(%rbp)
  80042040cb:	00 
  80042040cc:	0f 86 21 ff ff ff    	jbe    8004203ff3 <check_boot_pml4e+0x1f8>
        assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
    }
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE - 1 )  == ~0);
  80042040d2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042040d6:	48 be ff ff fe 03 80 	movabs $0x8003feffff,%rsi
  80042040dd:	00 00 00 
  80042040e0:	48 89 c7             	mov    %rax,%rdi
  80042040e3:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  80042040ea:	00 00 00 
  80042040ed:	ff d0                	callq  *%rax
  80042040ef:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  80042040f3:	74 35                	je     800420412a <check_boot_pml4e+0x32f>
  80042040f5:	48 b9 78 ec 20 04 80 	movabs $0x800420ec78,%rcx
  80042040fc:	00 00 00 
  80042040ff:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204106:	00 00 00 
  8004204109:	be 67 03 00 00       	mov    $0x367,%esi
  800420410e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204115:	00 00 00 
  8004204118:	b8 00 00 00 00       	mov    $0x0,%eax
  800420411d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204124:	00 00 00 
  8004204127:	41 ff d0             	callq  *%r8

    pdpe_t *pdpe = KADDR(PTE_ADDR(boot_pml4e[1]));
  800420412a:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204131:	00 00 00 
  8004204134:	48 8b 00             	mov    (%rax),%rax
  8004204137:	48 83 c0 08          	add    $0x8,%rax
  800420413b:	48 8b 00             	mov    (%rax),%rax
  800420413e:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004204144:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  8004204148:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420414c:	48 c1 e8 0c          	shr    $0xc,%rax
  8004204150:	89 45 ac             	mov    %eax,-0x54(%rbp)
  8004204153:	8b 55 ac             	mov    -0x54(%rbp),%edx
  8004204156:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420415d:	00 00 00 
  8004204160:	48 8b 00             	mov    (%rax),%rax
  8004204163:	48 39 c2             	cmp    %rax,%rdx
  8004204166:	72 32                	jb     800420419a <check_boot_pml4e+0x39f>
  8004204168:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420416c:	48 89 c1             	mov    %rax,%rcx
  800420416f:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004204176:	00 00 00 
  8004204179:	be 69 03 00 00       	mov    $0x369,%esi
  800420417e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204185:	00 00 00 
  8004204188:	b8 00 00 00 00       	mov    $0x0,%eax
  800420418d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204194:	00 00 00 
  8004204197:	41 ff d0             	callq  *%r8
  800420419a:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042041a1:	00 00 00 
  80042041a4:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042041a8:	48 01 d0             	add    %rdx,%rax
  80042041ab:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
    pde_t  *pgdir = KADDR(PTE_ADDR(pdpe[0]));
  80042041af:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042041b3:	48 8b 00             	mov    (%rax),%rax
  80042041b6:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80042041bc:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80042041c0:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042041c4:	48 c1 e8 0c          	shr    $0xc,%rax
  80042041c8:	89 45 94             	mov    %eax,-0x6c(%rbp)
  80042041cb:	8b 55 94             	mov    -0x6c(%rbp),%edx
  80042041ce:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042041d5:	00 00 00 
  80042041d8:	48 8b 00             	mov    (%rax),%rax
  80042041db:	48 39 c2             	cmp    %rax,%rdx
  80042041de:	72 32                	jb     8004204212 <check_boot_pml4e+0x417>
  80042041e0:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042041e4:	48 89 c1             	mov    %rax,%rcx
  80042041e7:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  80042041ee:	00 00 00 
  80042041f1:	be 6a 03 00 00       	mov    $0x36a,%esi
  80042041f6:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042041fd:	00 00 00 
  8004204200:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204205:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420420c:	00 00 00 
  800420420f:	41 ff d0             	callq  *%r8
  8004204212:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004204219:	00 00 00 
  800420421c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004204220:	48 01 d0             	add    %rdx,%rax
  8004204223:	48 89 45 88          	mov    %rax,-0x78(%rbp)
    // check PDE permissions
    for (i = 0; i < NPDENTRIES; i++) {
  8004204227:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  800420422e:	00 
  800420422f:	e9 3e 01 00 00       	jmpq   8004204372 <check_boot_pml4e+0x577>
        switch (i) {
  8004204234:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204238:	48 83 f8 05          	cmp    $0x5,%rax
  800420423c:	74 06                	je     8004204244 <check_boot_pml4e+0x449>
  800420423e:	48 83 f8 1f          	cmp    $0x1f,%rax
  8004204242:	75 58                	jne    800420429c <check_boot_pml4e+0x4a1>
            //case PDX(UVPT):
            case PDX(KSTACKTOP - 1):
            case PDX(UPAGES):
                assert(pgdir[i] & PTE_P);
  8004204244:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204248:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420424f:	00 
  8004204250:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  8004204254:	48 01 d0             	add    %rdx,%rax
  8004204257:	48 8b 00             	mov    (%rax),%rax
  800420425a:	83 e0 01             	and    $0x1,%eax
  800420425d:	48 85 c0             	test   %rax,%rax
  8004204260:	75 35                	jne    8004204297 <check_boot_pml4e+0x49c>
  8004204262:	48 b9 ac ec 20 04 80 	movabs $0x800420ecac,%rcx
  8004204269:	00 00 00 
  800420426c:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204273:	00 00 00 
  8004204276:	be 71 03 00 00       	mov    $0x371,%esi
  800420427b:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204282:	00 00 00 
  8004204285:	b8 00 00 00 00       	mov    $0x0,%eax
  800420428a:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204291:	00 00 00 
  8004204294:	41 ff d0             	callq  *%r8
                break;
  8004204297:	e9 d1 00 00 00       	jmpq   800420436d <check_boot_pml4e+0x572>
            default:
                if (i >= PDX(KERNBASE)) {
  800420429c:	48 83 7d e8 1f       	cmpq   $0x1f,-0x18(%rbp)
  80042042a1:	0f 86 c5 00 00 00    	jbe    800420436c <check_boot_pml4e+0x571>
                    if (pgdir[i] & PTE_P)
  80042042a7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042042ab:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80042042b2:	00 
  80042042b3:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  80042042b7:	48 01 d0             	add    %rdx,%rax
  80042042ba:	48 8b 00             	mov    (%rax),%rax
  80042042bd:	83 e0 01             	and    $0x1,%eax
  80042042c0:	48 85 c0             	test   %rax,%rax
  80042042c3:	74 57                	je     800420431c <check_boot_pml4e+0x521>
                        assert(pgdir[i] & PTE_W);
  80042042c5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042042c9:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80042042d0:	00 
  80042042d1:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  80042042d5:	48 01 d0             	add    %rdx,%rax
  80042042d8:	48 8b 00             	mov    (%rax),%rax
  80042042db:	83 e0 02             	and    $0x2,%eax
  80042042de:	48 85 c0             	test   %rax,%rax
  80042042e1:	0f 85 85 00 00 00    	jne    800420436c <check_boot_pml4e+0x571>
  80042042e7:	48 b9 bd ec 20 04 80 	movabs $0x800420ecbd,%rcx
  80042042ee:	00 00 00 
  80042042f1:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042042f8:	00 00 00 
  80042042fb:	be 76 03 00 00       	mov    $0x376,%esi
  8004204300:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204307:	00 00 00 
  800420430a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420430f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204316:	00 00 00 
  8004204319:	41 ff d0             	callq  *%r8
                    else
                        assert(pgdir[i] == 0);
  800420431c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204320:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004204327:	00 
  8004204328:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420432c:	48 01 d0             	add    %rdx,%rax
  800420432f:	48 8b 00             	mov    (%rax),%rax
  8004204332:	48 85 c0             	test   %rax,%rax
  8004204335:	74 35                	je     800420436c <check_boot_pml4e+0x571>
  8004204337:	48 b9 ce ec 20 04 80 	movabs $0x800420ecce,%rcx
  800420433e:	00 00 00 
  8004204341:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204348:	00 00 00 
  800420434b:	be 78 03 00 00       	mov    $0x378,%esi
  8004204350:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204357:	00 00 00 
  800420435a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420435f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204366:	00 00 00 
  8004204369:	41 ff d0             	callq  *%r8
                }
                break;
  800420436c:	90                   	nop
    assert(check_va2pa(pml4e, KSTACKTOP - KSTKSIZE - 1 )  == ~0);

    pdpe_t *pdpe = KADDR(PTE_ADDR(boot_pml4e[1]));
    pde_t  *pgdir = KADDR(PTE_ADDR(pdpe[0]));
    // check PDE permissions
    for (i = 0; i < NPDENTRIES; i++) {
  800420436d:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004204372:	48 81 7d e8 ff 01 00 	cmpq   $0x1ff,-0x18(%rbp)
  8004204379:	00 
  800420437a:	0f 86 b4 fe ff ff    	jbe    8004204234 <check_boot_pml4e+0x439>
                        assert(pgdir[i] == 0);
                }
                break;
        }
    }
    cprintf("check_boot_pml4e() succeeded!\n");
  8004204380:	48 bf e0 ec 20 04 80 	movabs $0x800420ece0,%rdi
  8004204387:	00 00 00 
  800420438a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420438f:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004204396:	00 00 00 
  8004204399:	ff d2                	callq  *%rdx
}
  800420439b:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  80042043a2:	5b                   	pop    %rbx
  80042043a3:	5d                   	pop    %rbp
  80042043a4:	c3                   	retq   

00000080042043a5 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pml4e() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pml4e_t *pml4e, uintptr_t va)
{
  80042043a5:	55                   	push   %rbp
  80042043a6:	48 89 e5             	mov    %rsp,%rbp
  80042043a9:	48 83 ec 60          	sub    $0x60,%rsp
  80042043ad:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80042043b1:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
    pte_t *pte;
    pdpe_t *pdpe;
    pde_t *pde;
    // cprintf("%x", va);
    pml4e = &pml4e[PML4(va)];
  80042043b5:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042043b9:	48 c1 e8 27          	shr    $0x27,%rax
  80042043bd:	25 ff 01 00 00       	and    $0x1ff,%eax
  80042043c2:	48 c1 e0 03          	shl    $0x3,%rax
  80042043c6:	48 01 45 a8          	add    %rax,-0x58(%rbp)
    // cprintf(" %x %x " , PML4(va), *pml4e);
    if(!(*pml4e & PTE_P))
  80042043ca:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042043ce:	48 8b 00             	mov    (%rax),%rax
  80042043d1:	83 e0 01             	and    $0x1,%eax
  80042043d4:	48 85 c0             	test   %rax,%rax
  80042043d7:	75 0c                	jne    80042043e5 <check_va2pa+0x40>
        return ~0;
  80042043d9:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80042043e0:	e9 38 02 00 00       	jmpq   800420461d <check_va2pa+0x278>
    pdpe = (pdpe_t *) KADDR(PTE_ADDR(*pml4e));
  80042043e5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042043e9:	48 8b 00             	mov    (%rax),%rax
  80042043ec:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80042043f2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042043f6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042043fa:	48 c1 e8 0c          	shr    $0xc,%rax
  80042043fe:	89 45 f4             	mov    %eax,-0xc(%rbp)
  8004204401:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004204404:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  800420440b:	00 00 00 
  800420440e:	48 8b 00             	mov    (%rax),%rax
  8004204411:	48 39 c2             	cmp    %rax,%rdx
  8004204414:	72 32                	jb     8004204448 <check_va2pa+0xa3>
  8004204416:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420441a:	48 89 c1             	mov    %rax,%rcx
  800420441d:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004204424:	00 00 00 
  8004204427:	be 90 03 00 00       	mov    $0x390,%esi
  800420442c:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204433:	00 00 00 
  8004204436:	b8 00 00 00 00       	mov    $0x0,%eax
  800420443b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204442:	00 00 00 
  8004204445:	41 ff d0             	callq  *%r8
  8004204448:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  800420444f:	00 00 00 
  8004204452:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004204456:	48 01 d0             	add    %rdx,%rax
  8004204459:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    // cprintf(" %x %x " , pdpe, *pdpe);
    if (!(pdpe[PDPE(va)] & PTE_P))
  800420445d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204461:	48 c1 e8 1e          	shr    $0x1e,%rax
  8004204465:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420446a:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004204471:	00 
  8004204472:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004204476:	48 01 d0             	add    %rdx,%rax
  8004204479:	48 8b 00             	mov    (%rax),%rax
  800420447c:	83 e0 01             	and    $0x1,%eax
  800420447f:	48 85 c0             	test   %rax,%rax
  8004204482:	75 0c                	jne    8004204490 <check_va2pa+0xeb>
        return ~0;
  8004204484:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  800420448b:	e9 8d 01 00 00       	jmpq   800420461d <check_va2pa+0x278>
    pde = (pde_t *) KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8004204490:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204494:	48 c1 e8 1e          	shr    $0x1e,%rax
  8004204498:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420449d:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80042044a4:	00 
  80042044a5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042044a9:	48 01 d0             	add    %rdx,%rax
  80042044ac:	48 8b 00             	mov    (%rax),%rax
  80042044af:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80042044b5:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  80042044b9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042044bd:	48 c1 e8 0c          	shr    $0xc,%rax
  80042044c1:	89 45 dc             	mov    %eax,-0x24(%rbp)
  80042044c4:	8b 55 dc             	mov    -0x24(%rbp),%edx
  80042044c7:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042044ce:	00 00 00 
  80042044d1:	48 8b 00             	mov    (%rax),%rax
  80042044d4:	48 39 c2             	cmp    %rax,%rdx
  80042044d7:	72 32                	jb     800420450b <check_va2pa+0x166>
  80042044d9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042044dd:	48 89 c1             	mov    %rax,%rcx
  80042044e0:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  80042044e7:	00 00 00 
  80042044ea:	be 94 03 00 00       	mov    $0x394,%esi
  80042044ef:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042044f6:	00 00 00 
  80042044f9:	b8 00 00 00 00       	mov    $0x0,%eax
  80042044fe:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204505:	00 00 00 
  8004204508:	41 ff d0             	callq  *%r8
  800420450b:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004204512:	00 00 00 
  8004204515:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204519:	48 01 d0             	add    %rdx,%rax
  800420451c:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    // cprintf(" %x %x " , pde, *pde);
    pde = &pde[PDX(va)];
  8004204520:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004204524:	48 c1 e8 15          	shr    $0x15,%rax
  8004204528:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420452d:	48 c1 e0 03          	shl    $0x3,%rax
  8004204531:	48 01 45 d0          	add    %rax,-0x30(%rbp)
    if (!(*pde & PTE_P))
  8004204535:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204539:	48 8b 00             	mov    (%rax),%rax
  800420453c:	83 e0 01             	and    $0x1,%eax
  800420453f:	48 85 c0             	test   %rax,%rax
  8004204542:	75 0c                	jne    8004204550 <check_va2pa+0x1ab>
        return ~0;
  8004204544:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  800420454b:	e9 cd 00 00 00       	jmpq   800420461d <check_va2pa+0x278>
    pte = (pte_t*) KADDR(PTE_ADDR(*pde));
  8004204550:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204554:	48 8b 00             	mov    (%rax),%rax
  8004204557:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  800420455d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8004204561:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204565:	48 c1 e8 0c          	shr    $0xc,%rax
  8004204569:	89 45 c4             	mov    %eax,-0x3c(%rbp)
  800420456c:	8b 55 c4             	mov    -0x3c(%rbp),%edx
  800420456f:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004204576:	00 00 00 
  8004204579:	48 8b 00             	mov    (%rax),%rax
  800420457c:	48 39 c2             	cmp    %rax,%rdx
  800420457f:	72 32                	jb     80042045b3 <check_va2pa+0x20e>
  8004204581:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204585:	48 89 c1             	mov    %rax,%rcx
  8004204588:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  800420458f:	00 00 00 
  8004204592:	be 99 03 00 00       	mov    $0x399,%esi
  8004204597:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420459e:	00 00 00 
  80042045a1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042045a6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042045ad:	00 00 00 
  80042045b0:	41 ff d0             	callq  *%r8
  80042045b3:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042045ba:	00 00 00 
  80042045bd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042045c1:	48 01 d0             	add    %rdx,%rax
  80042045c4:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    // cprintf(" %x %x " , pte, *pte);
    if (!(pte[PTX(va)] & PTE_P))
  80042045c8:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042045cc:	48 c1 e8 0c          	shr    $0xc,%rax
  80042045d0:	25 ff 01 00 00       	and    $0x1ff,%eax
  80042045d5:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  80042045dc:	00 
  80042045dd:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042045e1:	48 01 d0             	add    %rdx,%rax
  80042045e4:	48 8b 00             	mov    (%rax),%rax
  80042045e7:	83 e0 01             	and    $0x1,%eax
  80042045ea:	48 85 c0             	test   %rax,%rax
  80042045ed:	75 09                	jne    80042045f8 <check_va2pa+0x253>
        return ~0;
  80042045ef:	48 c7 c0 ff ff ff ff 	mov    $0xffffffffffffffff,%rax
  80042045f6:	eb 25                	jmp    800420461d <check_va2pa+0x278>
    // cprintf(" %x %x\n" , PTX(va),  PTE_ADDR(pte[PTX(va)]));
    return PTE_ADDR(pte[PTX(va)]);
  80042045f8:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042045fc:	48 c1 e8 0c          	shr    $0xc,%rax
  8004204600:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004204605:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420460c:	00 
  800420460d:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004204611:	48 01 d0             	add    %rdx,%rax
  8004204614:	48 8b 00             	mov    (%rax),%rax
  8004204617:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
}
  800420461d:	c9                   	leaveq 
  800420461e:	c3                   	retq   

000000800420461f <page_check>:


// check page_insert, page_remove, &c
static void
page_check(void)
{
  800420461f:	55                   	push   %rbp
  8004204620:	48 89 e5             	mov    %rsp,%rbp
  8004204623:	53                   	push   %rbx
  8004204624:	48 81 ec 08 01 00 00 	sub    $0x108,%rsp
    pte_t *ptep, *ptep1;
    pdpe_t *pdpe;
    pde_t *pde;
    void *va;
    int i;
    pp0 = pp1 = pp2 = pp3 = pp4 = pp5 =0;
  800420462b:	48 c7 45 e0 00 00 00 	movq   $0x0,-0x20(%rbp)
  8004204632:	00 
  8004204633:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204637:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  800420463b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420463f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004204643:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204647:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  800420464b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420464f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004204653:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004204657:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    assert(pp0 = page_alloc(0));
  800420465b:	bf 00 00 00 00       	mov    $0x0,%edi
  8004204660:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004204667:	00 00 00 
  800420466a:	ff d0                	callq  *%rax
  800420466c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  8004204670:	48 83 7d b8 00       	cmpq   $0x0,-0x48(%rbp)
  8004204675:	75 35                	jne    80042046ac <page_check+0x8d>
  8004204677:	48 b9 ff ec 20 04 80 	movabs $0x800420ecff,%rcx
  800420467e:	00 00 00 
  8004204681:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204688:	00 00 00 
  800420468b:	be ae 03 00 00       	mov    $0x3ae,%esi
  8004204690:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204697:	00 00 00 
  800420469a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420469f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042046a6:	00 00 00 
  80042046a9:	41 ff d0             	callq  *%r8
    assert(pp1 = page_alloc(0));
  80042046ac:	bf 00 00 00 00       	mov    $0x0,%edi
  80042046b1:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042046b8:	00 00 00 
  80042046bb:	ff d0                	callq  *%rax
  80042046bd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80042046c1:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  80042046c6:	75 35                	jne    80042046fd <page_check+0xde>
  80042046c8:	48 b9 13 ed 20 04 80 	movabs $0x800420ed13,%rcx
  80042046cf:	00 00 00 
  80042046d2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042046d9:	00 00 00 
  80042046dc:	be af 03 00 00       	mov    $0x3af,%esi
  80042046e1:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042046e8:	00 00 00 
  80042046eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80042046f0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042046f7:	00 00 00 
  80042046fa:	41 ff d0             	callq  *%r8
    assert(pp2 = page_alloc(0));
  80042046fd:	bf 00 00 00 00       	mov    $0x0,%edi
  8004204702:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004204709:	00 00 00 
  800420470c:	ff d0                	callq  *%rax
  800420470e:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
  8004204712:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004204717:	75 35                	jne    800420474e <page_check+0x12f>
  8004204719:	48 b9 27 ed 20 04 80 	movabs $0x800420ed27,%rcx
  8004204720:	00 00 00 
  8004204723:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420472a:	00 00 00 
  800420472d:	be b0 03 00 00       	mov    $0x3b0,%esi
  8004204732:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204739:	00 00 00 
  800420473c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204741:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204748:	00 00 00 
  800420474b:	41 ff d0             	callq  *%r8
    assert(pp3 = page_alloc(0));
  800420474e:	bf 00 00 00 00       	mov    $0x0,%edi
  8004204753:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  800420475a:	00 00 00 
  800420475d:	ff d0                	callq  *%rax
  800420475f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004204763:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004204768:	75 35                	jne    800420479f <page_check+0x180>
  800420476a:	48 b9 3b ed 20 04 80 	movabs $0x800420ed3b,%rcx
  8004204771:	00 00 00 
  8004204774:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420477b:	00 00 00 
  800420477e:	be b1 03 00 00       	mov    $0x3b1,%esi
  8004204783:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420478a:	00 00 00 
  800420478d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204792:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204799:	00 00 00 
  800420479c:	41 ff d0             	callq  *%r8
    assert(pp4 = page_alloc(0));
  800420479f:	bf 00 00 00 00       	mov    $0x0,%edi
  80042047a4:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042047ab:	00 00 00 
  80042047ae:	ff d0                	callq  *%rax
  80042047b0:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  80042047b4:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  80042047b9:	75 35                	jne    80042047f0 <page_check+0x1d1>
  80042047bb:	48 b9 4f ed 20 04 80 	movabs $0x800420ed4f,%rcx
  80042047c2:	00 00 00 
  80042047c5:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042047cc:	00 00 00 
  80042047cf:	be b2 03 00 00       	mov    $0x3b2,%esi
  80042047d4:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042047db:	00 00 00 
  80042047de:	b8 00 00 00 00       	mov    $0x0,%eax
  80042047e3:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042047ea:	00 00 00 
  80042047ed:	41 ff d0             	callq  *%r8
    assert(pp5 = page_alloc(0));
  80042047f0:	bf 00 00 00 00       	mov    $0x0,%edi
  80042047f5:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042047fc:	00 00 00 
  80042047ff:	ff d0                	callq  *%rax
  8004204801:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  8004204805:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  800420480a:	75 35                	jne    8004204841 <page_check+0x222>
  800420480c:	48 b9 63 ed 20 04 80 	movabs $0x800420ed63,%rcx
  8004204813:	00 00 00 
  8004204816:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420481d:	00 00 00 
  8004204820:	be b3 03 00 00       	mov    $0x3b3,%esi
  8004204825:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420482c:	00 00 00 
  800420482f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204834:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420483b:	00 00 00 
  800420483e:	41 ff d0             	callq  *%r8

    assert(pp0);
  8004204841:	48 83 7d b8 00       	cmpq   $0x0,-0x48(%rbp)
  8004204846:	75 35                	jne    800420487d <page_check+0x25e>
  8004204848:	48 b9 d9 ea 20 04 80 	movabs $0x800420ead9,%rcx
  800420484f:	00 00 00 
  8004204852:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204859:	00 00 00 
  800420485c:	be b5 03 00 00       	mov    $0x3b5,%esi
  8004204861:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204868:	00 00 00 
  800420486b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204870:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204877:	00 00 00 
  800420487a:	41 ff d0             	callq  *%r8
    assert(pp1 && pp1 != pp0);
  800420487d:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  8004204882:	74 0a                	je     800420488e <page_check+0x26f>
  8004204884:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004204888:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  800420488c:	75 35                	jne    80042048c3 <page_check+0x2a4>
  800420488e:	48 b9 dd ea 20 04 80 	movabs $0x800420eadd,%rcx
  8004204895:	00 00 00 
  8004204898:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420489f:	00 00 00 
  80042048a2:	be b6 03 00 00       	mov    $0x3b6,%esi
  80042048a7:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042048ae:	00 00 00 
  80042048b1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042048b6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042048bd:	00 00 00 
  80042048c0:	41 ff d0             	callq  *%r8
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
  80042048c3:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  80042048c8:	74 14                	je     80042048de <page_check+0x2bf>
  80042048ca:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042048ce:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  80042048d2:	74 0a                	je     80042048de <page_check+0x2bf>
  80042048d4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  80042048d8:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  80042048dc:	75 35                	jne    8004204913 <page_check+0x2f4>
  80042048de:	48 b9 f0 ea 20 04 80 	movabs $0x800420eaf0,%rcx
  80042048e5:	00 00 00 
  80042048e8:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042048ef:	00 00 00 
  80042048f2:	be b7 03 00 00       	mov    $0x3b7,%esi
  80042048f7:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042048fe:	00 00 00 
  8004204901:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204906:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420490d:	00 00 00 
  8004204910:	41 ff d0             	callq  *%r8
    assert(pp3 && pp3 != pp2 && pp3 != pp1 && pp3 != pp0);
  8004204913:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004204918:	74 1e                	je     8004204938 <page_check+0x319>
  800420491a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420491e:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004204922:	74 14                	je     8004204938 <page_check+0x319>
  8004204924:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204928:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  800420492c:	74 0a                	je     8004204938 <page_check+0x319>
  800420492e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204932:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  8004204936:	75 35                	jne    800420496d <page_check+0x34e>
  8004204938:	48 b9 78 ed 20 04 80 	movabs $0x800420ed78,%rcx
  800420493f:	00 00 00 
  8004204942:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204949:	00 00 00 
  800420494c:	be b8 03 00 00       	mov    $0x3b8,%esi
  8004204951:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204958:	00 00 00 
  800420495b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204960:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204967:	00 00 00 
  800420496a:	41 ff d0             	callq  *%r8
    assert(pp4 && pp4 != pp3 && pp4 != pp2 && pp4 != pp1 && pp4 != pp0);
  800420496d:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004204972:	74 28                	je     800420499c <page_check+0x37d>
  8004204974:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004204978:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420497c:	74 1e                	je     800420499c <page_check+0x37d>
  800420497e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004204982:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004204986:	74 14                	je     800420499c <page_check+0x37d>
  8004204988:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420498c:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  8004204990:	74 0a                	je     800420499c <page_check+0x37d>
  8004204992:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004204996:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  800420499a:	75 35                	jne    80042049d1 <page_check+0x3b2>
  800420499c:	48 b9 a8 ed 20 04 80 	movabs $0x800420eda8,%rcx
  80042049a3:	00 00 00 
  80042049a6:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042049ad:	00 00 00 
  80042049b0:	be b9 03 00 00       	mov    $0x3b9,%esi
  80042049b5:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042049bc:	00 00 00 
  80042049bf:	b8 00 00 00 00       	mov    $0x0,%eax
  80042049c4:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042049cb:	00 00 00 
  80042049ce:	41 ff d0             	callq  *%r8
    assert(pp5 && pp5 != pp4 && pp5 != pp3 && pp5 != pp2 && pp5 != pp1 && pp5 != pp0);
  80042049d1:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  80042049d6:	74 32                	je     8004204a0a <page_check+0x3eb>
  80042049d8:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042049dc:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  80042049e0:	74 28                	je     8004204a0a <page_check+0x3eb>
  80042049e2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042049e6:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  80042049ea:	74 1e                	je     8004204a0a <page_check+0x3eb>
  80042049ec:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042049f0:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  80042049f4:	74 14                	je     8004204a0a <page_check+0x3eb>
  80042049f6:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042049fa:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
  80042049fe:	74 0a                	je     8004204a0a <page_check+0x3eb>
  8004204a00:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004204a04:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  8004204a08:	75 35                	jne    8004204a3f <page_check+0x420>
  8004204a0a:	48 b9 e8 ed 20 04 80 	movabs $0x800420ede8,%rcx
  8004204a11:	00 00 00 
  8004204a14:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204a1b:	00 00 00 
  8004204a1e:	be ba 03 00 00       	mov    $0x3ba,%esi
  8004204a23:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204a2a:	00 00 00 
  8004204a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204a32:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204a39:	00 00 00 
  8004204a3c:	41 ff d0             	callq  *%r8

    // temporarily steal the rest of the free pages
    fl = page_free_list;
  8004204a3f:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004204a46:	00 00 00 
  8004204a49:	48 8b 00             	mov    (%rax),%rax
  8004204a4c:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
    page_free_list = NULL;
  8004204a50:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004204a57:	00 00 00 
  8004204a5a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    // should be no free memory
    assert(!page_alloc(0));
  8004204a61:	bf 00 00 00 00       	mov    $0x0,%edi
  8004204a66:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004204a6d:	00 00 00 
  8004204a70:	ff d0                	callq  *%rax
  8004204a72:	48 85 c0             	test   %rax,%rax
  8004204a75:	74 35                	je     8004204aac <page_check+0x48d>
  8004204a77:	48 b9 67 eb 20 04 80 	movabs $0x800420eb67,%rcx
  8004204a7e:	00 00 00 
  8004204a81:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204a88:	00 00 00 
  8004204a8b:	be c1 03 00 00       	mov    $0x3c1,%esi
  8004204a90:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204a97:	00 00 00 
  8004204a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204a9f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204aa6:	00 00 00 
  8004204aa9:	41 ff d0             	callq  *%r8

    // there is no page allocated at address 0
    assert(page_lookup(boot_pml4e, (void *) 0x0, &ptep) == NULL);
  8004204aac:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204ab3:	00 00 00 
  8004204ab6:	48 8b 00             	mov    (%rax),%rax
  8004204ab9:	48 8d 95 f0 fe ff ff 	lea    -0x110(%rbp),%rdx
  8004204ac0:	be 00 00 00 00       	mov    $0x0,%esi
  8004204ac5:	48 89 c7             	mov    %rax,%rdi
  8004204ac8:	48 b8 16 2e 20 04 80 	movabs $0x8004202e16,%rax
  8004204acf:	00 00 00 
  8004204ad2:	ff d0                	callq  *%rax
  8004204ad4:	48 85 c0             	test   %rax,%rax
  8004204ad7:	74 35                	je     8004204b0e <page_check+0x4ef>
  8004204ad9:	48 b9 38 ee 20 04 80 	movabs $0x800420ee38,%rcx
  8004204ae0:	00 00 00 
  8004204ae3:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204aea:	00 00 00 
  8004204aed:	be c4 03 00 00       	mov    $0x3c4,%esi
  8004204af2:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204af9:	00 00 00 
  8004204afc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204b01:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204b08:	00 00 00 
  8004204b0b:	41 ff d0             	callq  *%r8

    // there is no free memory, so we can't allocate a page table
    assert(page_insert(boot_pml4e, pp1, 0x0, 0) < 0);
  8004204b0e:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204b15:	00 00 00 
  8004204b18:	48 8b 00             	mov    (%rax),%rax
  8004204b1b:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004204b1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204b24:	ba 00 00 00 00       	mov    $0x0,%edx
  8004204b29:	48 89 c7             	mov    %rax,%rdi
  8004204b2c:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004204b33:	00 00 00 
  8004204b36:	ff d0                	callq  *%rax
  8004204b38:	85 c0                	test   %eax,%eax
  8004204b3a:	78 35                	js     8004204b71 <page_check+0x552>
  8004204b3c:	48 b9 70 ee 20 04 80 	movabs $0x800420ee70,%rcx
  8004204b43:	00 00 00 
  8004204b46:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204b4d:	00 00 00 
  8004204b50:	be c7 03 00 00       	mov    $0x3c7,%esi
  8004204b55:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204b5c:	00 00 00 
  8004204b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204b64:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204b6b:	00 00 00 
  8004204b6e:	41 ff d0             	callq  *%r8

    // free pp0 and try again: pp0 should be used for page table
    page_free(pp0);
  8004204b71:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004204b75:	48 89 c7             	mov    %rax,%rdi
  8004204b78:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004204b7f:	00 00 00 
  8004204b82:	ff d0                	callq  *%rax
    assert(page_insert(boot_pml4e, pp1, 0x0, 0) < 0);
  8004204b84:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204b8b:	00 00 00 
  8004204b8e:	48 8b 00             	mov    (%rax),%rax
  8004204b91:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004204b95:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  8004204b9f:	48 89 c7             	mov    %rax,%rdi
  8004204ba2:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004204ba9:	00 00 00 
  8004204bac:	ff d0                	callq  *%rax
  8004204bae:	85 c0                	test   %eax,%eax
  8004204bb0:	78 35                	js     8004204be7 <page_check+0x5c8>
  8004204bb2:	48 b9 70 ee 20 04 80 	movabs $0x800420ee70,%rcx
  8004204bb9:	00 00 00 
  8004204bbc:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204bc3:	00 00 00 
  8004204bc6:	be cb 03 00 00       	mov    $0x3cb,%esi
  8004204bcb:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204bd2:	00 00 00 
  8004204bd5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204bda:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204be1:	00 00 00 
  8004204be4:	41 ff d0             	callq  *%r8
    page_free(pp2);
  8004204be7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204beb:	48 89 c7             	mov    %rax,%rdi
  8004204bee:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004204bf5:	00 00 00 
  8004204bf8:	ff d0                	callq  *%rax
    page_free(pp3);
  8004204bfa:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204bfe:	48 89 c7             	mov    %rax,%rdi
  8004204c01:	48 b8 9f 27 20 04 80 	movabs $0x800420279f,%rax
  8004204c08:	00 00 00 
  8004204c0b:	ff d0                	callq  *%rax
    //cprintf("pp1 ref count = %d\n",pp1->pp_ref);
    //cprintf("pp0 ref count = %d\n",pp0->pp_ref);
    //cprintf("pp2 ref count = %d\n",pp2->pp_ref);
    assert(page_insert(boot_pml4e, pp1, 0x0, 0) == 0);
  8004204c0d:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204c14:	00 00 00 
  8004204c17:	48 8b 00             	mov    (%rax),%rax
  8004204c1a:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004204c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204c23:	ba 00 00 00 00       	mov    $0x0,%edx
  8004204c28:	48 89 c7             	mov    %rax,%rdi
  8004204c2b:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004204c32:	00 00 00 
  8004204c35:	ff d0                	callq  *%rax
  8004204c37:	85 c0                	test   %eax,%eax
  8004204c39:	74 35                	je     8004204c70 <page_check+0x651>
  8004204c3b:	48 b9 a0 ee 20 04 80 	movabs $0x800420eea0,%rcx
  8004204c42:	00 00 00 
  8004204c45:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204c4c:	00 00 00 
  8004204c4f:	be d1 03 00 00       	mov    $0x3d1,%esi
  8004204c54:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204c5b:	00 00 00 
  8004204c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204c63:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204c6a:	00 00 00 
  8004204c6d:	41 ff d0             	callq  *%r8
    assert((PTE_ADDR(boot_pml4e[0]) == page2pa(pp0) || PTE_ADDR(boot_pml4e[0]) == page2pa(pp2) || PTE_ADDR(boot_pml4e[0]) == page2pa(pp3) ));
  8004204c70:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204c77:	00 00 00 
  8004204c7a:	48 8b 00             	mov    (%rax),%rax
  8004204c7d:	48 8b 00             	mov    (%rax),%rax
  8004204c80:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004204c86:	48 89 c3             	mov    %rax,%rbx
  8004204c89:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004204c8d:	48 89 c7             	mov    %rax,%rdi
  8004204c90:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004204c97:	00 00 00 
  8004204c9a:	ff d0                	callq  *%rax
  8004204c9c:	48 39 c3             	cmp    %rax,%rbx
  8004204c9f:	0f 84 97 00 00 00    	je     8004204d3c <page_check+0x71d>
  8004204ca5:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204cac:	00 00 00 
  8004204caf:	48 8b 00             	mov    (%rax),%rax
  8004204cb2:	48 8b 00             	mov    (%rax),%rax
  8004204cb5:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004204cbb:	48 89 c3             	mov    %rax,%rbx
  8004204cbe:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204cc2:	48 89 c7             	mov    %rax,%rdi
  8004204cc5:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004204ccc:	00 00 00 
  8004204ccf:	ff d0                	callq  *%rax
  8004204cd1:	48 39 c3             	cmp    %rax,%rbx
  8004204cd4:	74 66                	je     8004204d3c <page_check+0x71d>
  8004204cd6:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204cdd:	00 00 00 
  8004204ce0:	48 8b 00             	mov    (%rax),%rax
  8004204ce3:	48 8b 00             	mov    (%rax),%rax
  8004204ce6:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004204cec:	48 89 c3             	mov    %rax,%rbx
  8004204cef:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204cf3:	48 89 c7             	mov    %rax,%rdi
  8004204cf6:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004204cfd:	00 00 00 
  8004204d00:	ff d0                	callq  *%rax
  8004204d02:	48 39 c3             	cmp    %rax,%rbx
  8004204d05:	74 35                	je     8004204d3c <page_check+0x71d>
  8004204d07:	48 b9 d0 ee 20 04 80 	movabs $0x800420eed0,%rcx
  8004204d0e:	00 00 00 
  8004204d11:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204d18:	00 00 00 
  8004204d1b:	be d2 03 00 00       	mov    $0x3d2,%esi
  8004204d20:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204d27:	00 00 00 
  8004204d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204d2f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204d36:	00 00 00 
  8004204d39:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, 0x0) == page2pa(pp1));
  8004204d3c:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204d43:	00 00 00 
  8004204d46:	48 8b 00             	mov    (%rax),%rax
  8004204d49:	be 00 00 00 00       	mov    $0x0,%esi
  8004204d4e:	48 89 c7             	mov    %rax,%rdi
  8004204d51:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004204d58:	00 00 00 
  8004204d5b:	ff d0                	callq  *%rax
  8004204d5d:	48 89 c3             	mov    %rax,%rbx
  8004204d60:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004204d64:	48 89 c7             	mov    %rax,%rdi
  8004204d67:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004204d6e:	00 00 00 
  8004204d71:	ff d0                	callq  *%rax
  8004204d73:	48 39 c3             	cmp    %rax,%rbx
  8004204d76:	74 35                	je     8004204dad <page_check+0x78e>
  8004204d78:	48 b9 58 ef 20 04 80 	movabs $0x800420ef58,%rcx
  8004204d7f:	00 00 00 
  8004204d82:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204d89:	00 00 00 
  8004204d8c:	be d3 03 00 00       	mov    $0x3d3,%esi
  8004204d91:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204d98:	00 00 00 
  8004204d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204da0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204da7:	00 00 00 
  8004204daa:	41 ff d0             	callq  *%r8
    assert(pp1->pp_ref == 1);
  8004204dad:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004204db1:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204db5:	66 83 f8 01          	cmp    $0x1,%ax
  8004204db9:	74 35                	je     8004204df0 <page_check+0x7d1>
  8004204dbb:	48 b9 85 ef 20 04 80 	movabs $0x800420ef85,%rcx
  8004204dc2:	00 00 00 
  8004204dc5:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204dcc:	00 00 00 
  8004204dcf:	be d4 03 00 00       	mov    $0x3d4,%esi
  8004204dd4:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204ddb:	00 00 00 
  8004204dde:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204de3:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204dea:	00 00 00 
  8004204ded:	41 ff d0             	callq  *%r8
    assert(pp0->pp_ref == 1);
  8004204df0:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004204df4:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204df8:	66 83 f8 01          	cmp    $0x1,%ax
  8004204dfc:	74 35                	je     8004204e33 <page_check+0x814>
  8004204dfe:	48 b9 96 ef 20 04 80 	movabs $0x800420ef96,%rcx
  8004204e05:	00 00 00 
  8004204e08:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204e0f:	00 00 00 
  8004204e12:	be d5 03 00 00       	mov    $0x3d5,%esi
  8004204e17:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204e1e:	00 00 00 
  8004204e21:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204e26:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204e2d:	00 00 00 
  8004204e30:	41 ff d0             	callq  *%r8
    assert(pp2->pp_ref == 1);
  8004204e33:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004204e37:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204e3b:	66 83 f8 01          	cmp    $0x1,%ax
  8004204e3f:	74 35                	je     8004204e76 <page_check+0x857>
  8004204e41:	48 b9 a7 ef 20 04 80 	movabs $0x800420efa7,%rcx
  8004204e48:	00 00 00 
  8004204e4b:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204e52:	00 00 00 
  8004204e55:	be d6 03 00 00       	mov    $0x3d6,%esi
  8004204e5a:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204e61:	00 00 00 
  8004204e64:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204e69:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204e70:	00 00 00 
  8004204e73:	41 ff d0             	callq  *%r8
    //should be able to map pp3 at PGSIZE because pp0 is already allocated for page table
    assert(page_insert(boot_pml4e, pp3, (void*) PGSIZE, 0) == 0);
  8004204e76:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204e7d:	00 00 00 
  8004204e80:	48 8b 00             	mov    (%rax),%rax
  8004204e83:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004204e87:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204e8c:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004204e91:	48 89 c7             	mov    %rax,%rdi
  8004204e94:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004204e9b:	00 00 00 
  8004204e9e:	ff d0                	callq  *%rax
  8004204ea0:	85 c0                	test   %eax,%eax
  8004204ea2:	74 35                	je     8004204ed9 <page_check+0x8ba>
  8004204ea4:	48 b9 b8 ef 20 04 80 	movabs $0x800420efb8,%rcx
  8004204eab:	00 00 00 
  8004204eae:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204eb5:	00 00 00 
  8004204eb8:	be d8 03 00 00       	mov    $0x3d8,%esi
  8004204ebd:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204ec4:	00 00 00 
  8004204ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204ecc:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204ed3:	00 00 00 
  8004204ed6:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == page2pa(pp3));
  8004204ed9:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204ee0:	00 00 00 
  8004204ee3:	48 8b 00             	mov    (%rax),%rax
  8004204ee6:	be 00 10 00 00       	mov    $0x1000,%esi
  8004204eeb:	48 89 c7             	mov    %rax,%rdi
  8004204eee:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004204ef5:	00 00 00 
  8004204ef8:	ff d0                	callq  *%rax
  8004204efa:	48 89 c3             	mov    %rax,%rbx
  8004204efd:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204f01:	48 89 c7             	mov    %rax,%rdi
  8004204f04:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004204f0b:	00 00 00 
  8004204f0e:	ff d0                	callq  *%rax
  8004204f10:	48 39 c3             	cmp    %rax,%rbx
  8004204f13:	74 35                	je     8004204f4a <page_check+0x92b>
  8004204f15:	48 b9 f0 ef 20 04 80 	movabs $0x800420eff0,%rcx
  8004204f1c:	00 00 00 
  8004204f1f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204f26:	00 00 00 
  8004204f29:	be d9 03 00 00       	mov    $0x3d9,%esi
  8004204f2e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204f35:	00 00 00 
  8004204f38:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204f3d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204f44:	00 00 00 
  8004204f47:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 2);
  8004204f4a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004204f4e:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004204f52:	66 83 f8 02          	cmp    $0x2,%ax
  8004204f56:	74 35                	je     8004204f8d <page_check+0x96e>
  8004204f58:	48 b9 20 f0 20 04 80 	movabs $0x800420f020,%rcx
  8004204f5f:	00 00 00 
  8004204f62:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204f69:	00 00 00 
  8004204f6c:	be da 03 00 00       	mov    $0x3da,%esi
  8004204f71:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204f78:	00 00 00 
  8004204f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204f80:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204f87:	00 00 00 
  8004204f8a:	41 ff d0             	callq  *%r8

    // should be no free memory
    assert(!page_alloc(0));
  8004204f8d:	bf 00 00 00 00       	mov    $0x0,%edi
  8004204f92:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  8004204f99:	00 00 00 
  8004204f9c:	ff d0                	callq  *%rax
  8004204f9e:	48 85 c0             	test   %rax,%rax
  8004204fa1:	74 35                	je     8004204fd8 <page_check+0x9b9>
  8004204fa3:	48 b9 67 eb 20 04 80 	movabs $0x800420eb67,%rcx
  8004204faa:	00 00 00 
  8004204fad:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004204fb4:	00 00 00 
  8004204fb7:	be dd 03 00 00       	mov    $0x3dd,%esi
  8004204fbc:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004204fc3:	00 00 00 
  8004204fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004204fcb:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004204fd2:	00 00 00 
  8004204fd5:	41 ff d0             	callq  *%r8

    // should be able to map pp3 at PGSIZE because it's already there
    assert(page_insert(boot_pml4e, pp3, (void*) PGSIZE, 0) == 0);
  8004204fd8:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004204fdf:	00 00 00 
  8004204fe2:	48 8b 00             	mov    (%rax),%rax
  8004204fe5:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  8004204fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004204fee:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004204ff3:	48 89 c7             	mov    %rax,%rdi
  8004204ff6:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004204ffd:	00 00 00 
  8004205000:	ff d0                	callq  *%rax
  8004205002:	85 c0                	test   %eax,%eax
  8004205004:	74 35                	je     800420503b <page_check+0xa1c>
  8004205006:	48 b9 b8 ef 20 04 80 	movabs $0x800420efb8,%rcx
  800420500d:	00 00 00 
  8004205010:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205017:	00 00 00 
  800420501a:	be e0 03 00 00       	mov    $0x3e0,%esi
  800420501f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205026:	00 00 00 
  8004205029:	b8 00 00 00 00       	mov    $0x0,%eax
  800420502e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205035:	00 00 00 
  8004205038:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == page2pa(pp3));
  800420503b:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205042:	00 00 00 
  8004205045:	48 8b 00             	mov    (%rax),%rax
  8004205048:	be 00 10 00 00       	mov    $0x1000,%esi
  800420504d:	48 89 c7             	mov    %rax,%rdi
  8004205050:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004205057:	00 00 00 
  800420505a:	ff d0                	callq  *%rax
  800420505c:	48 89 c3             	mov    %rax,%rbx
  800420505f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205063:	48 89 c7             	mov    %rax,%rdi
  8004205066:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  800420506d:	00 00 00 
  8004205070:	ff d0                	callq  *%rax
  8004205072:	48 39 c3             	cmp    %rax,%rbx
  8004205075:	74 35                	je     80042050ac <page_check+0xa8d>
  8004205077:	48 b9 f0 ef 20 04 80 	movabs $0x800420eff0,%rcx
  800420507e:	00 00 00 
  8004205081:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205088:	00 00 00 
  800420508b:	be e1 03 00 00       	mov    $0x3e1,%esi
  8004205090:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205097:	00 00 00 
  800420509a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420509f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042050a6:	00 00 00 
  80042050a9:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 2);
  80042050ac:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042050b0:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042050b4:	66 83 f8 02          	cmp    $0x2,%ax
  80042050b8:	74 35                	je     80042050ef <page_check+0xad0>
  80042050ba:	48 b9 20 f0 20 04 80 	movabs $0x800420f020,%rcx
  80042050c1:	00 00 00 
  80042050c4:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042050cb:	00 00 00 
  80042050ce:	be e2 03 00 00       	mov    $0x3e2,%esi
  80042050d3:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042050da:	00 00 00 
  80042050dd:	b8 00 00 00 00       	mov    $0x0,%eax
  80042050e2:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042050e9:	00 00 00 
  80042050ec:	41 ff d0             	callq  *%r8

    // pp3 should NOT be on the free list
    // could happen in ref counts are handled sloppily in page_insert
    assert(!page_alloc(0));
  80042050ef:	bf 00 00 00 00       	mov    $0x0,%edi
  80042050f4:	48 b8 e4 26 20 04 80 	movabs $0x80042026e4,%rax
  80042050fb:	00 00 00 
  80042050fe:	ff d0                	callq  *%rax
  8004205100:	48 85 c0             	test   %rax,%rax
  8004205103:	74 35                	je     800420513a <page_check+0xb1b>
  8004205105:	48 b9 67 eb 20 04 80 	movabs $0x800420eb67,%rcx
  800420510c:	00 00 00 
  800420510f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205116:	00 00 00 
  8004205119:	be e6 03 00 00       	mov    $0x3e6,%esi
  800420511e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205125:	00 00 00 
  8004205128:	b8 00 00 00 00       	mov    $0x0,%eax
  800420512d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205134:	00 00 00 
  8004205137:	41 ff d0             	callq  *%r8
    // check that pgdir_walk returns a pointer to the pte
    pdpe = KADDR(PTE_ADDR(boot_pml4e[PML4(PGSIZE)]));
  800420513a:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205141:	00 00 00 
  8004205144:	48 8b 00             	mov    (%rax),%rax
  8004205147:	48 8b 00             	mov    (%rax),%rax
  800420514a:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205150:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
  8004205154:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004205158:	48 c1 e8 0c          	shr    $0xc,%rax
  800420515c:	89 45 a4             	mov    %eax,-0x5c(%rbp)
  800420515f:	8b 55 a4             	mov    -0x5c(%rbp),%edx
  8004205162:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205169:	00 00 00 
  800420516c:	48 8b 00             	mov    (%rax),%rax
  800420516f:	48 39 c2             	cmp    %rax,%rdx
  8004205172:	72 32                	jb     80042051a6 <page_check+0xb87>
  8004205174:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004205178:	48 89 c1             	mov    %rax,%rcx
  800420517b:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205182:	00 00 00 
  8004205185:	be e8 03 00 00       	mov    $0x3e8,%esi
  800420518a:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205191:	00 00 00 
  8004205194:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205199:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042051a0:	00 00 00 
  80042051a3:	41 ff d0             	callq  *%r8
  80042051a6:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042051ad:	00 00 00 
  80042051b0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042051b4:	48 01 d0             	add    %rdx,%rax
  80042051b7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    pde = KADDR(PTE_ADDR(pdpe[PDPE(PGSIZE)]));
  80042051bb:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042051bf:	48 8b 00             	mov    (%rax),%rax
  80042051c2:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  80042051c8:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  80042051cc:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042051d0:	48 c1 e8 0c          	shr    $0xc,%rax
  80042051d4:	89 45 8c             	mov    %eax,-0x74(%rbp)
  80042051d7:	8b 55 8c             	mov    -0x74(%rbp),%edx
  80042051da:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  80042051e1:	00 00 00 
  80042051e4:	48 8b 00             	mov    (%rax),%rax
  80042051e7:	48 39 c2             	cmp    %rax,%rdx
  80042051ea:	72 32                	jb     800420521e <page_check+0xbff>
  80042051ec:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  80042051f0:	48 89 c1             	mov    %rax,%rcx
  80042051f3:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  80042051fa:	00 00 00 
  80042051fd:	be e9 03 00 00       	mov    $0x3e9,%esi
  8004205202:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205209:	00 00 00 
  800420520c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205211:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205218:	00 00 00 
  800420521b:	41 ff d0             	callq  *%r8
  800420521e:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004205225:	00 00 00 
  8004205228:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420522c:	48 01 d0             	add    %rdx,%rax
  800420522f:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    ptep = KADDR(PTE_ADDR(pde[PDX(PGSIZE)]));
  8004205233:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004205237:	48 8b 00             	mov    (%rax),%rax
  800420523a:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205240:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  8004205247:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420524e:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205252:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
  8004205258:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  800420525e:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205265:	00 00 00 
  8004205268:	48 8b 00             	mov    (%rax),%rax
  800420526b:	48 39 c2             	cmp    %rax,%rdx
  800420526e:	72 35                	jb     80042052a5 <page_check+0xc86>
  8004205270:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  8004205277:	48 89 c1             	mov    %rax,%rcx
  800420527a:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205281:	00 00 00 
  8004205284:	be ea 03 00 00       	mov    $0x3ea,%esi
  8004205289:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205290:	00 00 00 
  8004205293:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205298:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420529f:	00 00 00 
  80042052a2:	41 ff d0             	callq  *%r8
  80042052a5:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042052ac:	00 00 00 
  80042052af:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  80042052b6:	48 01 d0             	add    %rdx,%rax
  80042052b9:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
    assert(pml4e_walk(boot_pml4e, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
  80042052c0:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042052c7:	00 00 00 
  80042052ca:	48 8b 00             	mov    (%rax),%rax
  80042052cd:	ba 00 00 00 00       	mov    $0x0,%edx
  80042052d2:	be 00 10 00 00       	mov    $0x1000,%esi
  80042052d7:	48 89 c7             	mov    %rax,%rdi
  80042052da:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  80042052e1:	00 00 00 
  80042052e4:	ff d0                	callq  *%rax
  80042052e6:	48 8b 95 f0 fe ff ff 	mov    -0x110(%rbp),%rdx
  80042052ed:	48 83 c2 08          	add    $0x8,%rdx
  80042052f1:	48 39 d0             	cmp    %rdx,%rax
  80042052f4:	74 35                	je     800420532b <page_check+0xd0c>
  80042052f6:	48 b9 38 f0 20 04 80 	movabs $0x800420f038,%rcx
  80042052fd:	00 00 00 
  8004205300:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205307:	00 00 00 
  800420530a:	be eb 03 00 00       	mov    $0x3eb,%esi
  800420530f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205316:	00 00 00 
  8004205319:	b8 00 00 00 00       	mov    $0x0,%eax
  800420531e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205325:	00 00 00 
  8004205328:	41 ff d0             	callq  *%r8

    // should be able to change permissions too.
    assert(page_insert(boot_pml4e, pp3, (void*) PGSIZE, PTE_U) == 0);
  800420532b:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205332:	00 00 00 
  8004205335:	48 8b 00             	mov    (%rax),%rax
  8004205338:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420533c:	b9 04 00 00 00       	mov    $0x4,%ecx
  8004205341:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004205346:	48 89 c7             	mov    %rax,%rdi
  8004205349:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004205350:	00 00 00 
  8004205353:	ff d0                	callq  *%rax
  8004205355:	85 c0                	test   %eax,%eax
  8004205357:	74 35                	je     800420538e <page_check+0xd6f>
  8004205359:	48 b9 78 f0 20 04 80 	movabs $0x800420f078,%rcx
  8004205360:	00 00 00 
  8004205363:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420536a:	00 00 00 
  800420536d:	be ee 03 00 00       	mov    $0x3ee,%esi
  8004205372:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205379:	00 00 00 
  800420537c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205381:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205388:	00 00 00 
  800420538b:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == page2pa(pp3));
  800420538e:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205395:	00 00 00 
  8004205398:	48 8b 00             	mov    (%rax),%rax
  800420539b:	be 00 10 00 00       	mov    $0x1000,%esi
  80042053a0:	48 89 c7             	mov    %rax,%rdi
  80042053a3:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  80042053aa:	00 00 00 
  80042053ad:	ff d0                	callq  *%rax
  80042053af:	48 89 c3             	mov    %rax,%rbx
  80042053b2:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042053b6:	48 89 c7             	mov    %rax,%rdi
  80042053b9:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042053c0:	00 00 00 
  80042053c3:	ff d0                	callq  *%rax
  80042053c5:	48 39 c3             	cmp    %rax,%rbx
  80042053c8:	74 35                	je     80042053ff <page_check+0xde0>
  80042053ca:	48 b9 f0 ef 20 04 80 	movabs $0x800420eff0,%rcx
  80042053d1:	00 00 00 
  80042053d4:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042053db:	00 00 00 
  80042053de:	be ef 03 00 00       	mov    $0x3ef,%esi
  80042053e3:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042053ea:	00 00 00 
  80042053ed:	b8 00 00 00 00       	mov    $0x0,%eax
  80042053f2:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042053f9:	00 00 00 
  80042053fc:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 2);
  80042053ff:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205403:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004205407:	66 83 f8 02          	cmp    $0x2,%ax
  800420540b:	74 35                	je     8004205442 <page_check+0xe23>
  800420540d:	48 b9 20 f0 20 04 80 	movabs $0x800420f020,%rcx
  8004205414:	00 00 00 
  8004205417:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420541e:	00 00 00 
  8004205421:	be f0 03 00 00       	mov    $0x3f0,%esi
  8004205426:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420542d:	00 00 00 
  8004205430:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205435:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420543c:	00 00 00 
  800420543f:	41 ff d0             	callq  *%r8
    assert(*pml4e_walk(boot_pml4e, (void*) PGSIZE, 0) & PTE_U);
  8004205442:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205449:	00 00 00 
  800420544c:	48 8b 00             	mov    (%rax),%rax
  800420544f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004205454:	be 00 10 00 00       	mov    $0x1000,%esi
  8004205459:	48 89 c7             	mov    %rax,%rdi
  800420545c:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004205463:	00 00 00 
  8004205466:	ff d0                	callq  *%rax
  8004205468:	48 8b 00             	mov    (%rax),%rax
  800420546b:	83 e0 04             	and    $0x4,%eax
  800420546e:	48 85 c0             	test   %rax,%rax
  8004205471:	75 35                	jne    80042054a8 <page_check+0xe89>
  8004205473:	48 b9 b8 f0 20 04 80 	movabs $0x800420f0b8,%rcx
  800420547a:	00 00 00 
  800420547d:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205484:	00 00 00 
  8004205487:	be f1 03 00 00       	mov    $0x3f1,%esi
  800420548c:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205493:	00 00 00 
  8004205496:	b8 00 00 00 00       	mov    $0x0,%eax
  800420549b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042054a2:	00 00 00 
  80042054a5:	41 ff d0             	callq  *%r8
    assert(boot_pml4e[0] & PTE_U);
  80042054a8:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042054af:	00 00 00 
  80042054b2:	48 8b 00             	mov    (%rax),%rax
  80042054b5:	48 8b 00             	mov    (%rax),%rax
  80042054b8:	83 e0 04             	and    $0x4,%eax
  80042054bb:	48 85 c0             	test   %rax,%rax
  80042054be:	75 35                	jne    80042054f5 <page_check+0xed6>
  80042054c0:	48 b9 eb f0 20 04 80 	movabs $0x800420f0eb,%rcx
  80042054c7:	00 00 00 
  80042054ca:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042054d1:	00 00 00 
  80042054d4:	be f2 03 00 00       	mov    $0x3f2,%esi
  80042054d9:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042054e0:	00 00 00 
  80042054e3:	b8 00 00 00 00       	mov    $0x0,%eax
  80042054e8:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042054ef:	00 00 00 
  80042054f2:	41 ff d0             	callq  *%r8


    // should not be able to map at PTSIZE because need free page for page table
    assert(page_insert(boot_pml4e, pp0, (void*) PTSIZE, 0) < 0);
  80042054f5:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042054fc:	00 00 00 
  80042054ff:	48 8b 00             	mov    (%rax),%rax
  8004205502:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  8004205506:	b9 00 00 00 00       	mov    $0x0,%ecx
  800420550b:	ba 00 00 20 00       	mov    $0x200000,%edx
  8004205510:	48 89 c7             	mov    %rax,%rdi
  8004205513:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  800420551a:	00 00 00 
  800420551d:	ff d0                	callq  *%rax
  800420551f:	85 c0                	test   %eax,%eax
  8004205521:	78 35                	js     8004205558 <page_check+0xf39>
  8004205523:	48 b9 08 f1 20 04 80 	movabs $0x800420f108,%rcx
  800420552a:	00 00 00 
  800420552d:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205534:	00 00 00 
  8004205537:	be f6 03 00 00       	mov    $0x3f6,%esi
  800420553c:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205543:	00 00 00 
  8004205546:	b8 00 00 00 00       	mov    $0x0,%eax
  800420554b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205552:	00 00 00 
  8004205555:	41 ff d0             	callq  *%r8

    // insert pp1 at PGSIZE (replacing pp3)
    assert(page_insert(boot_pml4e, pp1, (void*) PGSIZE, 0) == 0);
  8004205558:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  800420555f:	00 00 00 
  8004205562:	48 8b 00             	mov    (%rax),%rax
  8004205565:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004205569:	b9 00 00 00 00       	mov    $0x0,%ecx
  800420556e:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004205573:	48 89 c7             	mov    %rax,%rdi
  8004205576:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  800420557d:	00 00 00 
  8004205580:	ff d0                	callq  *%rax
  8004205582:	85 c0                	test   %eax,%eax
  8004205584:	74 35                	je     80042055bb <page_check+0xf9c>
  8004205586:	48 b9 40 f1 20 04 80 	movabs $0x800420f140,%rcx
  800420558d:	00 00 00 
  8004205590:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205597:	00 00 00 
  800420559a:	be f9 03 00 00       	mov    $0x3f9,%esi
  800420559f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042055a6:	00 00 00 
  80042055a9:	b8 00 00 00 00       	mov    $0x0,%eax
  80042055ae:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042055b5:	00 00 00 
  80042055b8:	41 ff d0             	callq  *%r8
    assert(!(*pml4e_walk(boot_pml4e, (void*) PGSIZE, 0) & PTE_U));
  80042055bb:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042055c2:	00 00 00 
  80042055c5:	48 8b 00             	mov    (%rax),%rax
  80042055c8:	ba 00 00 00 00       	mov    $0x0,%edx
  80042055cd:	be 00 10 00 00       	mov    $0x1000,%esi
  80042055d2:	48 89 c7             	mov    %rax,%rdi
  80042055d5:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  80042055dc:	00 00 00 
  80042055df:	ff d0                	callq  *%rax
  80042055e1:	48 8b 00             	mov    (%rax),%rax
  80042055e4:	83 e0 04             	and    $0x4,%eax
  80042055e7:	48 85 c0             	test   %rax,%rax
  80042055ea:	74 35                	je     8004205621 <page_check+0x1002>
  80042055ec:	48 b9 78 f1 20 04 80 	movabs $0x800420f178,%rcx
  80042055f3:	00 00 00 
  80042055f6:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042055fd:	00 00 00 
  8004205600:	be fa 03 00 00       	mov    $0x3fa,%esi
  8004205605:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420560c:	00 00 00 
  800420560f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205614:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420561b:	00 00 00 
  800420561e:	41 ff d0             	callq  *%r8

    // should have pp1 at both 0 and PGSIZE
    assert(check_va2pa(boot_pml4e, 0) == page2pa(pp1));
  8004205621:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205628:	00 00 00 
  800420562b:	48 8b 00             	mov    (%rax),%rax
  800420562e:	be 00 00 00 00       	mov    $0x0,%esi
  8004205633:	48 89 c7             	mov    %rax,%rdi
  8004205636:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  800420563d:	00 00 00 
  8004205640:	ff d0                	callq  *%rax
  8004205642:	48 89 c3             	mov    %rax,%rbx
  8004205645:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205649:	48 89 c7             	mov    %rax,%rdi
  800420564c:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004205653:	00 00 00 
  8004205656:	ff d0                	callq  *%rax
  8004205658:	48 39 c3             	cmp    %rax,%rbx
  800420565b:	74 35                	je     8004205692 <page_check+0x1073>
  800420565d:	48 b9 b0 f1 20 04 80 	movabs $0x800420f1b0,%rcx
  8004205664:	00 00 00 
  8004205667:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420566e:	00 00 00 
  8004205671:	be fd 03 00 00       	mov    $0x3fd,%esi
  8004205676:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420567d:	00 00 00 
  8004205680:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205685:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420568c:	00 00 00 
  800420568f:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == page2pa(pp1));
  8004205692:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205699:	00 00 00 
  800420569c:	48 8b 00             	mov    (%rax),%rax
  800420569f:	be 00 10 00 00       	mov    $0x1000,%esi
  80042056a4:	48 89 c7             	mov    %rax,%rdi
  80042056a7:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  80042056ae:	00 00 00 
  80042056b1:	ff d0                	callq  *%rax
  80042056b3:	48 89 c3             	mov    %rax,%rbx
  80042056b6:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042056ba:	48 89 c7             	mov    %rax,%rdi
  80042056bd:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  80042056c4:	00 00 00 
  80042056c7:	ff d0                	callq  *%rax
  80042056c9:	48 39 c3             	cmp    %rax,%rbx
  80042056cc:	74 35                	je     8004205703 <page_check+0x10e4>
  80042056ce:	48 b9 e0 f1 20 04 80 	movabs $0x800420f1e0,%rcx
  80042056d5:	00 00 00 
  80042056d8:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042056df:	00 00 00 
  80042056e2:	be fe 03 00 00       	mov    $0x3fe,%esi
  80042056e7:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042056ee:	00 00 00 
  80042056f1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042056f6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042056fd:	00 00 00 
  8004205700:	41 ff d0             	callq  *%r8
    // ... and ref counts should reflect this
    assert(pp1->pp_ref == 2);
  8004205703:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205707:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420570b:	66 83 f8 02          	cmp    $0x2,%ax
  800420570f:	74 35                	je     8004205746 <page_check+0x1127>
  8004205711:	48 b9 10 f2 20 04 80 	movabs $0x800420f210,%rcx
  8004205718:	00 00 00 
  800420571b:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205722:	00 00 00 
  8004205725:	be 00 04 00 00       	mov    $0x400,%esi
  800420572a:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205731:	00 00 00 
  8004205734:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205739:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205740:	00 00 00 
  8004205743:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 1);
  8004205746:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420574a:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420574e:	66 83 f8 01          	cmp    $0x1,%ax
  8004205752:	74 35                	je     8004205789 <page_check+0x116a>
  8004205754:	48 b9 21 f2 20 04 80 	movabs $0x800420f221,%rcx
  800420575b:	00 00 00 
  800420575e:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205765:	00 00 00 
  8004205768:	be 01 04 00 00       	mov    $0x401,%esi
  800420576d:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205774:	00 00 00 
  8004205777:	b8 00 00 00 00       	mov    $0x0,%eax
  800420577c:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205783:	00 00 00 
  8004205786:	41 ff d0             	callq  *%r8


    // unmapping pp1 at 0 should keep pp1 at PGSIZE
    page_remove(boot_pml4e, 0x0);
  8004205789:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205790:	00 00 00 
  8004205793:	48 8b 00             	mov    (%rax),%rax
  8004205796:	be 00 00 00 00       	mov    $0x0,%esi
  800420579b:	48 89 c7             	mov    %rax,%rdi
  800420579e:	48 b8 8d 2e 20 04 80 	movabs $0x8004202e8d,%rax
  80042057a5:	00 00 00 
  80042057a8:	ff d0                	callq  *%rax
    assert(check_va2pa(boot_pml4e, 0x0) == ~0);
  80042057aa:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042057b1:	00 00 00 
  80042057b4:	48 8b 00             	mov    (%rax),%rax
  80042057b7:	be 00 00 00 00       	mov    $0x0,%esi
  80042057bc:	48 89 c7             	mov    %rax,%rdi
  80042057bf:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  80042057c6:	00 00 00 
  80042057c9:	ff d0                	callq  *%rax
  80042057cb:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  80042057cf:	74 35                	je     8004205806 <page_check+0x11e7>
  80042057d1:	48 b9 38 f2 20 04 80 	movabs $0x800420f238,%rcx
  80042057d8:	00 00 00 
  80042057db:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042057e2:	00 00 00 
  80042057e5:	be 06 04 00 00       	mov    $0x406,%esi
  80042057ea:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042057f1:	00 00 00 
  80042057f4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042057f9:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205800:	00 00 00 
  8004205803:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == page2pa(pp1));
  8004205806:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  800420580d:	00 00 00 
  8004205810:	48 8b 00             	mov    (%rax),%rax
  8004205813:	be 00 10 00 00       	mov    $0x1000,%esi
  8004205818:	48 89 c7             	mov    %rax,%rdi
  800420581b:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004205822:	00 00 00 
  8004205825:	ff d0                	callq  *%rax
  8004205827:	48 89 c3             	mov    %rax,%rbx
  800420582a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420582e:	48 89 c7             	mov    %rax,%rdi
  8004205831:	48 b8 9f 14 20 04 80 	movabs $0x800420149f,%rax
  8004205838:	00 00 00 
  800420583b:	ff d0                	callq  *%rax
  800420583d:	48 39 c3             	cmp    %rax,%rbx
  8004205840:	74 35                	je     8004205877 <page_check+0x1258>
  8004205842:	48 b9 e0 f1 20 04 80 	movabs $0x800420f1e0,%rcx
  8004205849:	00 00 00 
  800420584c:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205853:	00 00 00 
  8004205856:	be 07 04 00 00       	mov    $0x407,%esi
  800420585b:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205862:	00 00 00 
  8004205865:	b8 00 00 00 00       	mov    $0x0,%eax
  800420586a:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205871:	00 00 00 
  8004205874:	41 ff d0             	callq  *%r8
    assert(pp1->pp_ref == 1);
  8004205877:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420587b:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420587f:	66 83 f8 01          	cmp    $0x1,%ax
  8004205883:	74 35                	je     80042058ba <page_check+0x129b>
  8004205885:	48 b9 85 ef 20 04 80 	movabs $0x800420ef85,%rcx
  800420588c:	00 00 00 
  800420588f:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205896:	00 00 00 
  8004205899:	be 08 04 00 00       	mov    $0x408,%esi
  800420589e:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042058a5:	00 00 00 
  80042058a8:	b8 00 00 00 00       	mov    $0x0,%eax
  80042058ad:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042058b4:	00 00 00 
  80042058b7:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 1);
  80042058ba:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042058be:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042058c2:	66 83 f8 01          	cmp    $0x1,%ax
  80042058c6:	74 35                	je     80042058fd <page_check+0x12de>
  80042058c8:	48 b9 21 f2 20 04 80 	movabs $0x800420f221,%rcx
  80042058cf:	00 00 00 
  80042058d2:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042058d9:	00 00 00 
  80042058dc:	be 09 04 00 00       	mov    $0x409,%esi
  80042058e1:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042058e8:	00 00 00 
  80042058eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80042058f0:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042058f7:	00 00 00 
  80042058fa:	41 ff d0             	callq  *%r8

    // Test re-inserting pp1 at PGSIZE.
    // Thanks to Varun Agrawal for suggesting this test case.
    assert(page_insert(boot_pml4e, pp1, (void*) PGSIZE, 0) == 0);
  80042058fd:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205904:	00 00 00 
  8004205907:	48 8b 00             	mov    (%rax),%rax
  800420590a:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  800420590e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004205913:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004205918:	48 89 c7             	mov    %rax,%rdi
  800420591b:	48 b8 59 2d 20 04 80 	movabs $0x8004202d59,%rax
  8004205922:	00 00 00 
  8004205925:	ff d0                	callq  *%rax
  8004205927:	85 c0                	test   %eax,%eax
  8004205929:	74 35                	je     8004205960 <page_check+0x1341>
  800420592b:	48 b9 40 f1 20 04 80 	movabs $0x800420f140,%rcx
  8004205932:	00 00 00 
  8004205935:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420593c:	00 00 00 
  800420593f:	be 0d 04 00 00       	mov    $0x40d,%esi
  8004205944:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420594b:	00 00 00 
  800420594e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205953:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420595a:	00 00 00 
  800420595d:	41 ff d0             	callq  *%r8
    assert(pp1->pp_ref);
  8004205960:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205964:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004205968:	66 85 c0             	test   %ax,%ax
  800420596b:	75 35                	jne    80042059a2 <page_check+0x1383>
  800420596d:	48 b9 5b f2 20 04 80 	movabs $0x800420f25b,%rcx
  8004205974:	00 00 00 
  8004205977:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420597e:	00 00 00 
  8004205981:	be 0e 04 00 00       	mov    $0x40e,%esi
  8004205986:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420598d:	00 00 00 
  8004205990:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205995:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420599c:	00 00 00 
  800420599f:	41 ff d0             	callq  *%r8
    assert(pp1->pp_link == NULL);
  80042059a2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042059a6:	48 8b 00             	mov    (%rax),%rax
  80042059a9:	48 85 c0             	test   %rax,%rax
  80042059ac:	74 35                	je     80042059e3 <page_check+0x13c4>
  80042059ae:	48 b9 67 f2 20 04 80 	movabs $0x800420f267,%rcx
  80042059b5:	00 00 00 
  80042059b8:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042059bf:	00 00 00 
  80042059c2:	be 0f 04 00 00       	mov    $0x40f,%esi
  80042059c7:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042059ce:	00 00 00 
  80042059d1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042059d6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042059dd:	00 00 00 
  80042059e0:	41 ff d0             	callq  *%r8

    // unmapping pp1 at PGSIZE should free it
    page_remove(boot_pml4e, (void*) PGSIZE);
  80042059e3:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  80042059ea:	00 00 00 
  80042059ed:	48 8b 00             	mov    (%rax),%rax
  80042059f0:	be 00 10 00 00       	mov    $0x1000,%esi
  80042059f5:	48 89 c7             	mov    %rax,%rdi
  80042059f8:	48 b8 8d 2e 20 04 80 	movabs $0x8004202e8d,%rax
  80042059ff:	00 00 00 
  8004205a02:	ff d0                	callq  *%rax
    assert(check_va2pa(boot_pml4e, 0x0) == ~0);
  8004205a04:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205a0b:	00 00 00 
  8004205a0e:	48 8b 00             	mov    (%rax),%rax
  8004205a11:	be 00 00 00 00       	mov    $0x0,%esi
  8004205a16:	48 89 c7             	mov    %rax,%rdi
  8004205a19:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004205a20:	00 00 00 
  8004205a23:	ff d0                	callq  *%rax
  8004205a25:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8004205a29:	74 35                	je     8004205a60 <page_check+0x1441>
  8004205a2b:	48 b9 38 f2 20 04 80 	movabs $0x800420f238,%rcx
  8004205a32:	00 00 00 
  8004205a35:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205a3c:	00 00 00 
  8004205a3f:	be 13 04 00 00       	mov    $0x413,%esi
  8004205a44:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205a4b:	00 00 00 
  8004205a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205a53:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205a5a:	00 00 00 
  8004205a5d:	41 ff d0             	callq  *%r8
    assert(check_va2pa(boot_pml4e, PGSIZE) == ~0);
  8004205a60:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205a67:	00 00 00 
  8004205a6a:	48 8b 00             	mov    (%rax),%rax
  8004205a6d:	be 00 10 00 00       	mov    $0x1000,%esi
  8004205a72:	48 89 c7             	mov    %rax,%rdi
  8004205a75:	48 b8 a5 43 20 04 80 	movabs $0x80042043a5,%rax
  8004205a7c:	00 00 00 
  8004205a7f:	ff d0                	callq  *%rax
  8004205a81:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  8004205a85:	74 35                	je     8004205abc <page_check+0x149d>
  8004205a87:	48 b9 80 f2 20 04 80 	movabs $0x800420f280,%rcx
  8004205a8e:	00 00 00 
  8004205a91:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205a98:	00 00 00 
  8004205a9b:	be 14 04 00 00       	mov    $0x414,%esi
  8004205aa0:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205aa7:	00 00 00 
  8004205aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205aaf:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205ab6:	00 00 00 
  8004205ab9:	41 ff d0             	callq  *%r8
    assert(pp1->pp_ref == 0);
  8004205abc:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  8004205ac0:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004205ac4:	66 85 c0             	test   %ax,%ax
  8004205ac7:	74 35                	je     8004205afe <page_check+0x14df>
  8004205ac9:	48 b9 a6 f2 20 04 80 	movabs $0x800420f2a6,%rcx
  8004205ad0:	00 00 00 
  8004205ad3:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205ada:	00 00 00 
  8004205add:	be 15 04 00 00       	mov    $0x415,%esi
  8004205ae2:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205ae9:	00 00 00 
  8004205aec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205af1:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205af8:	00 00 00 
  8004205afb:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 1);
  8004205afe:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205b02:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004205b06:	66 83 f8 01          	cmp    $0x1,%ax
  8004205b0a:	74 35                	je     8004205b41 <page_check+0x1522>
  8004205b0c:	48 b9 21 f2 20 04 80 	movabs $0x800420f221,%rcx
  8004205b13:	00 00 00 
  8004205b16:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205b1d:	00 00 00 
  8004205b20:	be 16 04 00 00       	mov    $0x416,%esi
  8004205b25:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205b2c:	00 00 00 
  8004205b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205b34:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205b3b:	00 00 00 
  8004205b3e:	41 ff d0             	callq  *%r8
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

    // forcibly take pp3 back
    struct PageInfo *pp_l1 = pa2page(PTE_ADDR(boot_pml4e[0]));
  8004205b41:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205b48:	00 00 00 
  8004205b4b:	48 8b 00             	mov    (%rax),%rax
  8004205b4e:	48 8b 00             	mov    (%rax),%rax
  8004205b51:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205b57:	48 89 c7             	mov    %rax,%rdi
  8004205b5a:	48 b8 c4 14 20 04 80 	movabs $0x80042014c4,%rax
  8004205b61:	00 00 00 
  8004205b64:	ff d0                	callq  *%rax
  8004205b66:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
    boot_pml4e[0] = 0;
  8004205b6d:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205b74:	00 00 00 
  8004205b77:	48 8b 00             	mov    (%rax),%rax
  8004205b7a:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
    assert(pp3->pp_ref == 1);
  8004205b81:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205b85:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004205b89:	66 83 f8 01          	cmp    $0x1,%ax
  8004205b8d:	74 35                	je     8004205bc4 <page_check+0x15a5>
  8004205b8f:	48 b9 21 f2 20 04 80 	movabs $0x800420f221,%rcx
  8004205b96:	00 00 00 
  8004205b99:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205ba0:	00 00 00 
  8004205ba3:	be 2c 04 00 00       	mov    $0x42c,%esi
  8004205ba8:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205baf:	00 00 00 
  8004205bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205bb7:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205bbe:	00 00 00 
  8004205bc1:	41 ff d0             	callq  *%r8
    page_decref(pp_l1);
  8004205bc4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004205bcb:	48 89 c7             	mov    %rax,%rdi
  8004205bce:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004205bd5:	00 00 00 
  8004205bd8:	ff d0                	callq  *%rax
    // check pointer arithmetic in pml4e_walk
    if (pp_l1 != pp3) page_decref(pp3);
  8004205bda:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004205be1:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004205be5:	74 13                	je     8004205bfa <page_check+0x15db>
  8004205be7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004205beb:	48 89 c7             	mov    %rax,%rdi
  8004205bee:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004205bf5:	00 00 00 
  8004205bf8:	ff d0                	callq  *%rax
    if (pp_l1 != pp2) page_decref(pp2);
  8004205bfa:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004205c01:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  8004205c05:	74 13                	je     8004205c1a <page_check+0x15fb>
  8004205c07:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004205c0b:	48 89 c7             	mov    %rax,%rdi
  8004205c0e:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004205c15:	00 00 00 
  8004205c18:	ff d0                	callq  *%rax
    if (pp_l1 != pp0) page_decref(pp0);
  8004205c1a:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004205c21:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  8004205c25:	74 13                	je     8004205c3a <page_check+0x161b>
  8004205c27:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004205c2b:	48 89 c7             	mov    %rax,%rdi
  8004205c2e:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004205c35:	00 00 00 
  8004205c38:	ff d0                	callq  *%rax
    va = (void*)(PGSIZE * 100);
  8004205c3a:	48 c7 85 60 ff ff ff 	movq   $0x64000,-0xa0(%rbp)
  8004205c41:	00 40 06 00 
    ptep = pml4e_walk(boot_pml4e, va, 1);
  8004205c45:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205c4c:	00 00 00 
  8004205c4f:	48 8b 00             	mov    (%rax),%rax
  8004205c52:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  8004205c59:	ba 01 00 00 00       	mov    $0x1,%edx
  8004205c5e:	48 89 ce             	mov    %rcx,%rsi
  8004205c61:	48 89 c7             	mov    %rax,%rdi
  8004205c64:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004205c6b:	00 00 00 
  8004205c6e:	ff d0                	callq  *%rax
  8004205c70:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
    pdpe = KADDR(PTE_ADDR(boot_pml4e[PML4(va)]));
  8004205c77:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205c7e:	00 00 00 
  8004205c81:	48 8b 00             	mov    (%rax),%rax
  8004205c84:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004205c8b:	48 c1 ea 27          	shr    $0x27,%rdx
  8004205c8f:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
  8004205c95:	48 c1 e2 03          	shl    $0x3,%rdx
  8004205c99:	48 01 d0             	add    %rdx,%rax
  8004205c9c:	48 8b 00             	mov    (%rax),%rax
  8004205c9f:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205ca5:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  8004205cac:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004205cb3:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205cb7:	89 85 54 ff ff ff    	mov    %eax,-0xac(%rbp)
  8004205cbd:	8b 95 54 ff ff ff    	mov    -0xac(%rbp),%edx
  8004205cc3:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205cca:	00 00 00 
  8004205ccd:	48 8b 00             	mov    (%rax),%rax
  8004205cd0:	48 39 c2             	cmp    %rax,%rdx
  8004205cd3:	72 35                	jb     8004205d0a <page_check+0x16eb>
  8004205cd5:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004205cdc:	48 89 c1             	mov    %rax,%rcx
  8004205cdf:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205ce6:	00 00 00 
  8004205ce9:	be 34 04 00 00       	mov    $0x434,%esi
  8004205cee:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205cf5:	00 00 00 
  8004205cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205cfd:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205d04:	00 00 00 
  8004205d07:	41 ff d0             	callq  *%r8
  8004205d0a:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004205d11:	00 00 00 
  8004205d14:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004205d1b:	48 01 d0             	add    %rdx,%rax
  8004205d1e:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    pde  = KADDR(PTE_ADDR(pdpe[PDPE(va)]));
  8004205d22:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004205d29:	48 c1 e8 1e          	shr    $0x1e,%rax
  8004205d2d:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004205d32:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004205d39:	00 
  8004205d3a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205d3e:	48 01 d0             	add    %rdx,%rax
  8004205d41:	48 8b 00             	mov    (%rax),%rax
  8004205d44:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205d4a:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  8004205d51:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004205d58:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205d5c:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%rbp)
  8004205d62:	8b 95 44 ff ff ff    	mov    -0xbc(%rbp),%edx
  8004205d68:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205d6f:	00 00 00 
  8004205d72:	48 8b 00             	mov    (%rax),%rax
  8004205d75:	48 39 c2             	cmp    %rax,%rdx
  8004205d78:	72 35                	jb     8004205daf <page_check+0x1790>
  8004205d7a:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004205d81:	48 89 c1             	mov    %rax,%rcx
  8004205d84:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205d8b:	00 00 00 
  8004205d8e:	be 35 04 00 00       	mov    $0x435,%esi
  8004205d93:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205d9a:	00 00 00 
  8004205d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205da2:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205da9:	00 00 00 
  8004205dac:	41 ff d0             	callq  *%r8
  8004205daf:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004205db6:	00 00 00 
  8004205db9:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  8004205dc0:	48 01 d0             	add    %rdx,%rax
  8004205dc3:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    ptep1 = KADDR(PTE_ADDR(pde[PDX(va)]));
  8004205dc7:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004205dce:	48 c1 e8 15          	shr    $0x15,%rax
  8004205dd2:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004205dd7:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004205dde:	00 
  8004205ddf:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004205de3:	48 01 d0             	add    %rdx,%rax
  8004205de6:	48 8b 00             	mov    (%rax),%rax
  8004205de9:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205def:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8004205df6:	48 8b 85 38 ff ff ff 	mov    -0xc8(%rbp),%rax
  8004205dfd:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205e01:	89 85 34 ff ff ff    	mov    %eax,-0xcc(%rbp)
  8004205e07:	8b 95 34 ff ff ff    	mov    -0xcc(%rbp),%edx
  8004205e0d:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205e14:	00 00 00 
  8004205e17:	48 8b 00             	mov    (%rax),%rax
  8004205e1a:	48 39 c2             	cmp    %rax,%rdx
  8004205e1d:	72 35                	jb     8004205e54 <page_check+0x1835>
  8004205e1f:	48 8b 85 38 ff ff ff 	mov    -0xc8(%rbp),%rax
  8004205e26:	48 89 c1             	mov    %rax,%rcx
  8004205e29:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205e30:	00 00 00 
  8004205e33:	be 36 04 00 00       	mov    $0x436,%esi
  8004205e38:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205e3f:	00 00 00 
  8004205e42:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205e47:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205e4e:	00 00 00 
  8004205e51:	41 ff d0             	callq  *%r8
  8004205e54:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004205e5b:	00 00 00 
  8004205e5e:	48 8b 85 38 ff ff ff 	mov    -0xc8(%rbp),%rax
  8004205e65:	48 01 d0             	add    %rdx,%rax
  8004205e68:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
    assert(ptep == ptep1 + PTX(va));
  8004205e6f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  8004205e76:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205e7a:	25 ff 01 00 00       	and    $0x1ff,%eax
  8004205e7f:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004205e86:	00 
  8004205e87:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004205e8e:	48 01 c2             	add    %rax,%rdx
  8004205e91:	48 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%rax
  8004205e98:	48 39 c2             	cmp    %rax,%rdx
  8004205e9b:	74 35                	je     8004205ed2 <page_check+0x18b3>
  8004205e9d:	48 b9 b7 f2 20 04 80 	movabs $0x800420f2b7,%rcx
  8004205ea4:	00 00 00 
  8004205ea7:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004205eae:	00 00 00 
  8004205eb1:	be 37 04 00 00       	mov    $0x437,%esi
  8004205eb6:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205ebd:	00 00 00 
  8004205ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205ec5:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205ecc:	00 00 00 
  8004205ecf:	41 ff d0             	callq  *%r8

    // check that new page tables get cleared
    memset(page2kva(pp4), 0xFF, PGSIZE);
  8004205ed2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004205ed6:	48 89 c7             	mov    %rax,%rdi
  8004205ed9:	48 b8 35 15 20 04 80 	movabs $0x8004201535,%rax
  8004205ee0:	00 00 00 
  8004205ee3:	ff d0                	callq  *%rax
  8004205ee5:	ba 00 10 00 00       	mov    $0x1000,%edx
  8004205eea:	be ff 00 00 00       	mov    $0xff,%esi
  8004205eef:	48 89 c7             	mov    %rax,%rdi
  8004205ef2:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004205ef9:	00 00 00 
  8004205efc:	ff d0                	callq  *%rax
    pml4e_walk(boot_pml4e, 0x0, 1);
  8004205efe:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205f05:	00 00 00 
  8004205f08:	48 8b 00             	mov    (%rax),%rax
  8004205f0b:	ba 01 00 00 00       	mov    $0x1,%edx
  8004205f10:	be 00 00 00 00       	mov    $0x0,%esi
  8004205f15:	48 89 c7             	mov    %rax,%rdi
  8004205f18:	48 b8 56 28 20 04 80 	movabs $0x8004202856,%rax
  8004205f1f:	00 00 00 
  8004205f22:	ff d0                	callq  *%rax
    pdpe = KADDR(PTE_ADDR(boot_pml4e[0]));
  8004205f24:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  8004205f2b:	00 00 00 
  8004205f2e:	48 8b 00             	mov    (%rax),%rax
  8004205f31:	48 8b 00             	mov    (%rax),%rax
  8004205f34:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205f3a:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  8004205f41:	48 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%rax
  8004205f48:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205f4c:	89 85 1c ff ff ff    	mov    %eax,-0xe4(%rbp)
  8004205f52:	8b 95 1c ff ff ff    	mov    -0xe4(%rbp),%edx
  8004205f58:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205f5f:	00 00 00 
  8004205f62:	48 8b 00             	mov    (%rax),%rax
  8004205f65:	48 39 c2             	cmp    %rax,%rdx
  8004205f68:	72 35                	jb     8004205f9f <page_check+0x1980>
  8004205f6a:	48 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%rax
  8004205f71:	48 89 c1             	mov    %rax,%rcx
  8004205f74:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004205f7b:	00 00 00 
  8004205f7e:	be 3c 04 00 00       	mov    $0x43c,%esi
  8004205f83:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004205f8a:	00 00 00 
  8004205f8d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004205f92:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004205f99:	00 00 00 
  8004205f9c:	41 ff d0             	callq  *%r8
  8004205f9f:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004205fa6:	00 00 00 
  8004205fa9:	48 8b 85 20 ff ff ff 	mov    -0xe0(%rbp),%rax
  8004205fb0:	48 01 d0             	add    %rdx,%rax
  8004205fb3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
    pde  = KADDR(PTE_ADDR(pdpe[0]));
  8004205fb7:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004205fbb:	48 8b 00             	mov    (%rax),%rax
  8004205fbe:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  8004205fc4:	48 89 85 10 ff ff ff 	mov    %rax,-0xf0(%rbp)
  8004205fcb:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  8004205fd2:	48 c1 e8 0c          	shr    $0xc,%rax
  8004205fd6:	89 85 0c ff ff ff    	mov    %eax,-0xf4(%rbp)
  8004205fdc:	8b 95 0c ff ff ff    	mov    -0xf4(%rbp),%edx
  8004205fe2:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004205fe9:	00 00 00 
  8004205fec:	48 8b 00             	mov    (%rax),%rax
  8004205fef:	48 39 c2             	cmp    %rax,%rdx
  8004205ff2:	72 35                	jb     8004206029 <page_check+0x1a0a>
  8004205ff4:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  8004205ffb:	48 89 c1             	mov    %rax,%rcx
  8004205ffe:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  8004206005:	00 00 00 
  8004206008:	be 3d 04 00 00       	mov    $0x43d,%esi
  800420600d:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004206014:	00 00 00 
  8004206017:	b8 00 00 00 00       	mov    $0x0,%eax
  800420601c:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206023:	00 00 00 
  8004206026:	41 ff d0             	callq  *%r8
  8004206029:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  8004206030:	00 00 00 
  8004206033:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  800420603a:	48 01 d0             	add    %rdx,%rax
  800420603d:	48 89 45 80          	mov    %rax,-0x80(%rbp)
    ptep  = KADDR(PTE_ADDR(pde[0]));
  8004206041:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  8004206045:	48 8b 00             	mov    (%rax),%rax
  8004206048:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  800420604e:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  8004206055:	48 8b 85 00 ff ff ff 	mov    -0x100(%rbp),%rax
  800420605c:	48 c1 e8 0c          	shr    $0xc,%rax
  8004206060:	89 85 fc fe ff ff    	mov    %eax,-0x104(%rbp)
  8004206066:	8b 95 fc fe ff ff    	mov    -0x104(%rbp),%edx
  800420606c:	48 b8 88 2d 22 04 80 	movabs $0x8004222d88,%rax
  8004206073:	00 00 00 
  8004206076:	48 8b 00             	mov    (%rax),%rax
  8004206079:	48 39 c2             	cmp    %rax,%rdx
  800420607c:	72 35                	jb     80042060b3 <page_check+0x1a94>
  800420607e:	48 8b 85 00 ff ff ff 	mov    -0x100(%rbp),%rax
  8004206085:	48 89 c1             	mov    %rax,%rcx
  8004206088:	48 ba b0 e6 20 04 80 	movabs $0x800420e6b0,%rdx
  800420608f:	00 00 00 
  8004206092:	be 3e 04 00 00       	mov    $0x43e,%esi
  8004206097:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420609e:	00 00 00 
  80042060a1:	b8 00 00 00 00       	mov    $0x0,%eax
  80042060a6:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042060ad:	00 00 00 
  80042060b0:	41 ff d0             	callq  *%r8
  80042060b3:	48 ba 00 00 00 04 80 	movabs $0x8004000000,%rdx
  80042060ba:	00 00 00 
  80042060bd:	48 8b 85 00 ff ff ff 	mov    -0x100(%rbp),%rax
  80042060c4:	48 01 d0             	add    %rdx,%rax
  80042060c7:	48 89 85 f0 fe ff ff 	mov    %rax,-0x110(%rbp)
    for(i=0; i<NPTENTRIES; i++)
  80042060ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  80042060d5:	eb 58                	jmp    800420612f <page_check+0x1b10>
        assert((ptep[i] & PTE_P) == 0);
  80042060d7:	48 8b 85 f0 fe ff ff 	mov    -0x110(%rbp),%rax
  80042060de:	8b 55 ec             	mov    -0x14(%rbp),%edx
  80042060e1:	48 63 d2             	movslq %edx,%rdx
  80042060e4:	48 c1 e2 03          	shl    $0x3,%rdx
  80042060e8:	48 01 d0             	add    %rdx,%rax
  80042060eb:	48 8b 00             	mov    (%rax),%rax
  80042060ee:	83 e0 01             	and    $0x1,%eax
  80042060f1:	48 85 c0             	test   %rax,%rax
  80042060f4:	74 35                	je     800420612b <page_check+0x1b0c>
  80042060f6:	48 b9 cf f2 20 04 80 	movabs $0x800420f2cf,%rcx
  80042060fd:	00 00 00 
  8004206100:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004206107:	00 00 00 
  800420610a:	be 40 04 00 00       	mov    $0x440,%esi
  800420610f:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004206116:	00 00 00 
  8004206119:	b8 00 00 00 00       	mov    $0x0,%eax
  800420611e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206125:	00 00 00 
  8004206128:	41 ff d0             	callq  *%r8
    memset(page2kva(pp4), 0xFF, PGSIZE);
    pml4e_walk(boot_pml4e, 0x0, 1);
    pdpe = KADDR(PTE_ADDR(boot_pml4e[0]));
    pde  = KADDR(PTE_ADDR(pdpe[0]));
    ptep  = KADDR(PTE_ADDR(pde[0]));
    for(i=0; i<NPTENTRIES; i++)
  800420612b:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  800420612f:	81 7d ec ff 01 00 00 	cmpl   $0x1ff,-0x14(%rbp)
  8004206136:	7e 9f                	jle    80042060d7 <page_check+0x1ab8>
        assert((ptep[i] & PTE_P) == 0);
    boot_pml4e[0] = 0;
  8004206138:	48 b8 80 2d 22 04 80 	movabs $0x8004222d80,%rax
  800420613f:	00 00 00 
  8004206142:	48 8b 00             	mov    (%rax),%rax
  8004206145:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)

    // give free list back
    page_free_list = fl;
  800420614c:	48 b8 d8 28 22 04 80 	movabs $0x80042228d8,%rax
  8004206153:	00 00 00 
  8004206156:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  800420615a:	48 89 10             	mov    %rdx,(%rax)

    // free the pages we took
    page_decref(pp0);
  800420615d:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  8004206161:	48 89 c7             	mov    %rax,%rdi
  8004206164:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  800420616b:	00 00 00 
  800420616e:	ff d0                	callq  *%rax
    page_decref(pp2);
  8004206170:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206174:	48 89 c7             	mov    %rax,%rdi
  8004206177:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  800420617e:	00 00 00 
  8004206181:	ff d0                	callq  *%rax
    page_decref(pp3);
  8004206183:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004206187:	48 89 c7             	mov    %rax,%rdi
  800420618a:	48 b8 15 28 20 04 80 	movabs $0x8004202815,%rax
  8004206191:	00 00 00 
  8004206194:	ff d0                	callq  *%rax

    // Triple check that we got the ref counts right
    assert(pp0->pp_ref == 0);
  8004206196:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420619a:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420619e:	66 85 c0             	test   %ax,%ax
  80042061a1:	74 35                	je     80042061d8 <page_check+0x1bb9>
  80042061a3:	48 b9 e6 f2 20 04 80 	movabs $0x800420f2e6,%rcx
  80042061aa:	00 00 00 
  80042061ad:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042061b4:	00 00 00 
  80042061b7:	be 4c 04 00 00       	mov    $0x44c,%esi
  80042061bc:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042061c3:	00 00 00 
  80042061c6:	b8 00 00 00 00       	mov    $0x0,%eax
  80042061cb:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042061d2:	00 00 00 
  80042061d5:	41 ff d0             	callq  *%r8
    assert(pp1->pp_ref == 0);
  80042061d8:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042061dc:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042061e0:	66 85 c0             	test   %ax,%ax
  80042061e3:	74 35                	je     800420621a <page_check+0x1bfb>
  80042061e5:	48 b9 a6 f2 20 04 80 	movabs $0x800420f2a6,%rcx
  80042061ec:	00 00 00 
  80042061ef:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042061f6:	00 00 00 
  80042061f9:	be 4d 04 00 00       	mov    $0x44d,%esi
  80042061fe:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004206205:	00 00 00 
  8004206208:	b8 00 00 00 00       	mov    $0x0,%eax
  800420620d:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206214:	00 00 00 
  8004206217:	41 ff d0             	callq  *%r8
    assert(pp2->pp_ref == 0);
  800420621a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420621e:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004206222:	66 85 c0             	test   %ax,%ax
  8004206225:	74 35                	je     800420625c <page_check+0x1c3d>
  8004206227:	48 b9 f7 f2 20 04 80 	movabs $0x800420f2f7,%rcx
  800420622e:	00 00 00 
  8004206231:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  8004206238:	00 00 00 
  800420623b:	be 4e 04 00 00       	mov    $0x44e,%esi
  8004206240:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004206247:	00 00 00 
  800420624a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420624f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206256:	00 00 00 
  8004206259:	41 ff d0             	callq  *%r8
    assert(pp3->pp_ref == 0);
  800420625c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004206260:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004206264:	66 85 c0             	test   %ax,%ax
  8004206267:	74 35                	je     800420629e <page_check+0x1c7f>
  8004206269:	48 b9 08 f3 20 04 80 	movabs $0x800420f308,%rcx
  8004206270:	00 00 00 
  8004206273:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  800420627a:	00 00 00 
  800420627d:	be 4f 04 00 00       	mov    $0x44f,%esi
  8004206282:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  8004206289:	00 00 00 
  800420628c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206291:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206298:	00 00 00 
  800420629b:	41 ff d0             	callq  *%r8
    assert(pp4->pp_ref == 0);
  800420629e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042062a2:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042062a6:	66 85 c0             	test   %ax,%ax
  80042062a9:	74 35                	je     80042062e0 <page_check+0x1cc1>
  80042062ab:	48 b9 19 f3 20 04 80 	movabs $0x800420f319,%rcx
  80042062b2:	00 00 00 
  80042062b5:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042062bc:	00 00 00 
  80042062bf:	be 50 04 00 00       	mov    $0x450,%esi
  80042062c4:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  80042062cb:	00 00 00 
  80042062ce:	b8 00 00 00 00       	mov    $0x0,%eax
  80042062d3:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042062da:	00 00 00 
  80042062dd:	41 ff d0             	callq  *%r8
    assert(pp5->pp_ref == 0);
  80042062e0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042062e4:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042062e8:	66 85 c0             	test   %ax,%ax
  80042062eb:	74 35                	je     8004206322 <page_check+0x1d03>
  80042062ed:	48 b9 2a f3 20 04 80 	movabs $0x800420f32a,%rcx
  80042062f4:	00 00 00 
  80042062f7:	48 ba 29 e7 20 04 80 	movabs $0x800420e729,%rdx
  80042062fe:	00 00 00 
  8004206301:	be 51 04 00 00       	mov    $0x451,%esi
  8004206306:	48 bf 3e e7 20 04 80 	movabs $0x800420e73e,%rdi
  800420630d:	00 00 00 
  8004206310:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206315:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420631c:	00 00 00 
  800420631f:	41 ff d0             	callq  *%r8

    cprintf("check_page() succeeded!\n");
  8004206322:	48 bf 3b f3 20 04 80 	movabs $0x800420f33b,%rdi
  8004206329:	00 00 00 
  800420632c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206331:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004206338:	00 00 00 
  800420633b:	ff d2                	callq  *%rdx
}
  800420633d:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
  8004206344:	5b                   	pop    %rbx
  8004206345:	5d                   	pop    %rbp
  8004206346:	c3                   	retq   

0000008004206347 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
  8004206347:	55                   	push   %rbp
  8004206348:	48 89 e5             	mov    %rsp,%rbp
  800420634b:	48 83 ec 14          	sub    $0x14,%rsp
  800420634f:	89 7d ec             	mov    %edi,-0x14(%rbp)
	outb(IO_RTC, reg);
  8004206352:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004206355:	0f b6 c0             	movzbl %al,%eax
  8004206358:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%rbp)
  800420635f:	88 45 fb             	mov    %al,-0x5(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8004206362:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  8004206366:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004206369:	ee                   	out    %al,(%dx)
  800420636a:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  8004206371:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004206374:	89 c2                	mov    %eax,%edx
  8004206376:	ec                   	in     (%dx),%al
  8004206377:	88 45 f3             	mov    %al,-0xd(%rbp)
	return data;
  800420637a:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
	return inb(IO_RTC+1);
  800420637e:	0f b6 c0             	movzbl %al,%eax
}
  8004206381:	c9                   	leaveq 
  8004206382:	c3                   	retq   

0000008004206383 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
  8004206383:	55                   	push   %rbp
  8004206384:	48 89 e5             	mov    %rsp,%rbp
  8004206387:	48 83 ec 18          	sub    $0x18,%rsp
  800420638b:	89 7d ec             	mov    %edi,-0x14(%rbp)
  800420638e:	89 75 e8             	mov    %esi,-0x18(%rbp)
	outb(IO_RTC, reg);
  8004206391:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004206394:	0f b6 c0             	movzbl %al,%eax
  8004206397:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%rbp)
  800420639e:	88 45 fb             	mov    %al,-0x5(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80042063a1:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  80042063a5:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042063a8:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
  80042063a9:	8b 45 e8             	mov    -0x18(%rbp),%eax
  80042063ac:	0f b6 c0             	movzbl %al,%eax
  80042063af:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%rbp)
  80042063b6:	88 45 f3             	mov    %al,-0xd(%rbp)
  80042063b9:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
  80042063bd:	8b 55 f4             	mov    -0xc(%rbp),%edx
  80042063c0:	ee                   	out    %al,(%dx)
}
  80042063c1:	c9                   	leaveq 
  80042063c2:	c3                   	retq   

00000080042063c3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
  80042063c3:	55                   	push   %rbp
  80042063c4:	48 89 e5             	mov    %rsp,%rbp
  80042063c7:	48 83 ec 10          	sub    $0x10,%rsp
  80042063cb:	89 7d fc             	mov    %edi,-0x4(%rbp)
  80042063ce:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	cputchar(ch);
  80042063d2:	8b 45 fc             	mov    -0x4(%rbp),%eax
  80042063d5:	89 c7                	mov    %eax,%edi
  80042063d7:	48 b8 cf 0d 20 04 80 	movabs $0x8004200dcf,%rax
  80042063de:	00 00 00 
  80042063e1:	ff d0                	callq  *%rax
	*cnt++;
  80042063e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042063e7:	48 83 c0 04          	add    $0x4,%rax
  80042063eb:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
}
  80042063ef:	c9                   	leaveq 
  80042063f0:	c3                   	retq   

00000080042063f1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042063f1:	55                   	push   %rbp
  80042063f2:	48 89 e5             	mov    %rsp,%rbp
  80042063f5:	48 83 ec 30          	sub    $0x30,%rsp
  80042063f9:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80042063fd:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int cnt = 0;
  8004206401:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	va_list aq;
	va_copy(aq,ap);
  8004206408:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  800420640c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206410:	48 8b 0a             	mov    (%rdx),%rcx
  8004206413:	48 89 08             	mov    %rcx,(%rax)
  8004206416:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420641a:	48 89 48 08          	mov    %rcx,0x8(%rax)
  800420641e:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8004206422:	48 89 50 10          	mov    %rdx,0x10(%rax)
	vprintfmt((void*)putch, &cnt, fmt, aq);
  8004206426:	48 8d 4d e0          	lea    -0x20(%rbp),%rcx
  800420642a:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420642e:	48 8d 45 fc          	lea    -0x4(%rbp),%rax
  8004206432:	48 89 c6             	mov    %rax,%rsi
  8004206435:	48 bf c3 63 20 04 80 	movabs $0x80042063c3,%rdi
  800420643c:	00 00 00 
  800420643f:	48 b8 a3 73 20 04 80 	movabs $0x80042073a3,%rax
  8004206446:	00 00 00 
  8004206449:	ff d0                	callq  *%rax
	va_end(aq);
	return cnt;
  800420644b:	8b 45 fc             	mov    -0x4(%rbp),%eax

}
  800420644e:	c9                   	leaveq 
  800420644f:	c3                   	retq   

0000008004206450 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004206450:	55                   	push   %rbp
  8004206451:	48 89 e5             	mov    %rsp,%rbp
  8004206454:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
  800420645b:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8004206462:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8004206469:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004206470:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004206477:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800420647e:	84 c0                	test   %al,%al
  8004206480:	74 20                	je     80042064a2 <cprintf+0x52>
  8004206482:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004206486:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800420648a:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800420648e:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004206492:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004206496:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800420649a:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800420649e:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  80042064a2:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
	va_list ap;
	int cnt;
	va_start(ap, fmt);
  80042064a9:	c7 85 30 ff ff ff 08 	movl   $0x8,-0xd0(%rbp)
  80042064b0:	00 00 00 
  80042064b3:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  80042064ba:	00 00 00 
  80042064bd:	48 8d 45 10          	lea    0x10(%rbp),%rax
  80042064c1:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  80042064c8:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  80042064cf:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
	va_list aq;
	va_copy(aq,ap);
  80042064d6:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  80042064dd:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  80042064e4:	48 8b 0a             	mov    (%rdx),%rcx
  80042064e7:	48 89 08             	mov    %rcx,(%rax)
  80042064ea:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042064ee:	48 89 48 08          	mov    %rcx,0x8(%rax)
  80042064f2:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80042064f6:	48 89 50 10          	mov    %rdx,0x10(%rax)
	cnt = vcprintf(fmt, aq);
  80042064fa:	48 8d 95 18 ff ff ff 	lea    -0xe8(%rbp),%rdx
  8004206501:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  8004206508:	48 89 d6             	mov    %rdx,%rsi
  800420650b:	48 89 c7             	mov    %rax,%rdi
  800420650e:	48 b8 f1 63 20 04 80 	movabs $0x80042063f1,%rax
  8004206515:	00 00 00 
  8004206518:	ff d0                	callq  *%rax
  800420651a:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
	va_end(aq);

	return cnt;
  8004206520:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  8004206526:	c9                   	leaveq 
  8004206527:	c3                   	retq   

0000008004206528 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int64_t
syscall(uint64_t syscallno, uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4, uint64_t a5)
{
  8004206528:	55                   	push   %rbp
  8004206529:	48 89 e5             	mov    %rsp,%rbp
  800420652c:	48 83 ec 30          	sub    $0x30,%rsp
  8004206530:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004206534:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8004206538:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  800420653c:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004206540:	4c 89 45 d8          	mov    %r8,-0x28(%rbp)
  8004206544:	4c 89 4d d0          	mov    %r9,-0x30(%rbp)
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
  8004206548:	48 ba 54 f3 20 04 80 	movabs $0x800420f354,%rdx
  800420654f:	00 00 00 
  8004206552:	be 0e 00 00 00       	mov    $0xe,%esi
  8004206557:	48 bf 6c f3 20 04 80 	movabs $0x800420f36c,%rdi
  800420655e:	00 00 00 
  8004206561:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206566:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  800420656d:	00 00 00 
  8004206570:	ff d1                	callq  *%rcx

0000008004206572 <list_func_die>:

#endif


int list_func_die(struct Ripdebuginfo *info, Dwarf_Die *die, uint64_t addr)
{
  8004206572:	55                   	push   %rbp
  8004206573:	48 89 e5             	mov    %rsp,%rbp
  8004206576:	48 81 ec f0 61 00 00 	sub    $0x61f0,%rsp
  800420657d:	48 89 bd 58 9e ff ff 	mov    %rdi,-0x61a8(%rbp)
  8004206584:	48 89 b5 50 9e ff ff 	mov    %rsi,-0x61b0(%rbp)
  800420658b:	48 89 95 48 9e ff ff 	mov    %rdx,-0x61b8(%rbp)
	_Dwarf_Line ln;
	Dwarf_Attribute *low;
	Dwarf_Attribute *high;
	Dwarf_CU *cu = die->cu_header;
  8004206592:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004206599:	48 8b 80 60 03 00 00 	mov    0x360(%rax),%rax
  80042065a0:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	Dwarf_Die *cudie = die->cu_die; 
  80042065a4:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042065ab:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  80042065b2:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	Dwarf_Die ret, sib=*die; 
  80042065b6:	48 8b 95 50 9e ff ff 	mov    -0x61b0(%rbp),%rdx
  80042065bd:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  80042065c4:	48 89 d1             	mov    %rdx,%rcx
  80042065c7:	ba 70 30 00 00       	mov    $0x3070,%edx
  80042065cc:	48 89 ce             	mov    %rcx,%rsi
  80042065cf:	48 89 c7             	mov    %rax,%rdi
  80042065d2:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  80042065d9:	00 00 00 
  80042065dc:	ff d0                	callq  *%rax
	Dwarf_Attribute *attr;
	uint64_t offset;
	uint64_t ret_val=8;
  80042065de:	48 c7 45 f8 08 00 00 	movq   $0x8,-0x8(%rbp)
  80042065e5:	00 
	uint64_t ret_offset=0;
  80042065e6:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  80042065ed:	00 

	if(die->die_tag != DW_TAG_subprogram)
  80042065ee:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042065f5:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042065f9:	48 83 f8 2e          	cmp    $0x2e,%rax
  80042065fd:	74 0a                	je     8004206609 <list_func_die+0x97>
		return 0;
  80042065ff:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206604:	e9 cd 06 00 00       	jmpq   8004206cd6 <list_func_die+0x764>

	memset(&ln, 0, sizeof(_Dwarf_Line));
  8004206609:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004206610:	ba 38 00 00 00       	mov    $0x38,%edx
  8004206615:	be 00 00 00 00       	mov    $0x0,%esi
  800420661a:	48 89 c7             	mov    %rax,%rdi
  800420661d:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004206624:	00 00 00 
  8004206627:	ff d0                	callq  *%rax

	low  = _dwarf_attr_find(die, DW_AT_low_pc);
  8004206629:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004206630:	be 11 00 00 00       	mov    $0x11,%esi
  8004206635:	48 89 c7             	mov    %rax,%rdi
  8004206638:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  800420663f:	00 00 00 
  8004206642:	ff d0                	callq  *%rax
  8004206644:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	high = _dwarf_attr_find(die, DW_AT_high_pc);
  8004206648:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  800420664f:	be 12 00 00 00       	mov    $0x12,%esi
  8004206654:	48 89 c7             	mov    %rax,%rdi
  8004206657:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  800420665e:	00 00 00 
  8004206661:	ff d0                	callq  *%rax
  8004206663:	48 89 45 c8          	mov    %rax,-0x38(%rbp)

	if((low && (low->u[0].u64 < addr)) && (high && (high->u[0].u64 > addr)))
  8004206667:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420666c:	0f 84 5f 06 00 00    	je     8004206cd1 <list_func_die+0x75f>
  8004206672:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004206676:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420667a:	48 3b 85 48 9e ff ff 	cmp    -0x61b8(%rbp),%rax
  8004206681:	0f 83 4a 06 00 00    	jae    8004206cd1 <list_func_die+0x75f>
  8004206687:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800420668c:	0f 84 3f 06 00 00    	je     8004206cd1 <list_func_die+0x75f>
  8004206692:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004206696:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420669a:	48 3b 85 48 9e ff ff 	cmp    -0x61b8(%rbp),%rax
  80042066a1:	0f 86 2a 06 00 00    	jbe    8004206cd1 <list_func_die+0x75f>
	{
		info->rip_file = die->cu_die->die_name;
  80042066a7:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042066ae:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  80042066b5:	48 8b 90 50 03 00 00 	mov    0x350(%rax),%rdx
  80042066bc:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042066c3:	48 89 10             	mov    %rdx,(%rax)

		info->rip_fn_name = die->die_name;
  80042066c6:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042066cd:	48 8b 90 50 03 00 00 	mov    0x350(%rax),%rdx
  80042066d4:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042066db:	48 89 50 10          	mov    %rdx,0x10(%rax)
		info->rip_fn_namelen = strlen(die->die_name);
  80042066df:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  80042066e6:	48 8b 80 50 03 00 00 	mov    0x350(%rax),%rax
  80042066ed:	48 89 c7             	mov    %rax,%rdi
  80042066f0:	48 b8 9b 7c 20 04 80 	movabs $0x8004207c9b,%rax
  80042066f7:	00 00 00 
  80042066fa:	ff d0                	callq  *%rax
  80042066fc:	48 8b 95 58 9e ff ff 	mov    -0x61a8(%rbp),%rdx
  8004206703:	89 42 18             	mov    %eax,0x18(%rdx)

		info->rip_fn_addr = (uintptr_t)low->u[0].u64;
  8004206706:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420670a:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420670e:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206715:	48 89 50 20          	mov    %rdx,0x20(%rax)

		assert(die->cu_die);	
  8004206719:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004206720:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  8004206727:	48 85 c0             	test   %rax,%rax
  800420672a:	75 35                	jne    8004206761 <list_func_die+0x1ef>
  800420672c:	48 b9 a0 f6 20 04 80 	movabs $0x800420f6a0,%rcx
  8004206733:	00 00 00 
  8004206736:	48 ba ac f6 20 04 80 	movabs $0x800420f6ac,%rdx
  800420673d:	00 00 00 
  8004206740:	be 88 00 00 00       	mov    $0x88,%esi
  8004206745:	48 bf c1 f6 20 04 80 	movabs $0x800420f6c1,%rdi
  800420674c:	00 00 00 
  800420674f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206754:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420675b:	00 00 00 
  800420675e:	41 ff d0             	callq  *%r8
		dwarf_srclines(die->cu_die, &ln, addr, NULL); 
  8004206761:	48 8b 85 50 9e ff ff 	mov    -0x61b0(%rbp),%rax
  8004206768:	48 8b 80 68 03 00 00 	mov    0x368(%rax),%rax
  800420676f:	48 8b 95 48 9e ff ff 	mov    -0x61b8(%rbp),%rdx
  8004206776:	48 8d b5 50 ff ff ff 	lea    -0xb0(%rbp),%rsi
  800420677d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004206782:	48 89 c7             	mov    %rax,%rdi
  8004206785:	48 b8 fc d4 20 04 80 	movabs $0x800420d4fc,%rax
  800420678c:	00 00 00 
  800420678f:	ff d0                	callq  *%rax

		info->rip_line = ln.ln_lineno;
  8004206791:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004206798:	89 c2                	mov    %eax,%edx
  800420679a:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042067a1:	89 50 08             	mov    %edx,0x8(%rax)
		info->rip_fn_narg = 0;
  80042067a4:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042067ab:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%rax)

		Dwarf_Attribute* attr;

		if(dwarf_child(dbg, cu, &sib, &ret) != DW_DLE_NO_ENTRY)
  80042067b2:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  80042067b9:	00 00 00 
  80042067bc:	48 8b 00             	mov    (%rax),%rax
  80042067bf:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  80042067c6:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  80042067cd:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  80042067d1:	48 89 c7             	mov    %rax,%rdi
  80042067d4:	48 b8 ac a1 20 04 80 	movabs $0x800420a1ac,%rax
  80042067db:	00 00 00 
  80042067de:	ff d0                	callq  *%rax
  80042067e0:	83 f8 04             	cmp    $0x4,%eax
  80042067e3:	0f 84 e1 04 00 00    	je     8004206cca <list_func_die+0x758>
		{
			if(ret.die_tag != DW_TAG_formal_parameter)
  80042067e9:	48 8b 85 f8 ce ff ff 	mov    -0x3108(%rbp),%rax
  80042067f0:	48 83 f8 05          	cmp    $0x5,%rax
  80042067f4:	74 05                	je     80042067fb <list_func_die+0x289>
				goto last;
  80042067f6:	e9 cf 04 00 00       	jmpq   8004206cca <list_func_die+0x758>

			attr = _dwarf_attr_find(&ret, DW_AT_type);
  80042067fb:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004206802:	be 49 00 00 00       	mov    $0x49,%esi
  8004206807:	48 89 c7             	mov    %rax,%rdi
  800420680a:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  8004206811:	00 00 00 
  8004206814:	ff d0                	callq  *%rax
  8004206816:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	
		try_again:
			if(attr != NULL)
  800420681a:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420681f:	0f 84 d7 00 00 00    	je     80042068fc <list_func_die+0x38a>
			{
				offset = (uint64_t)cu->cu_offset + attr->u[0].u64;
  8004206825:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206829:	48 8b 50 30          	mov    0x30(%rax),%rdx
  800420682d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206831:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206835:	48 01 d0             	add    %rdx,%rax
  8004206838:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
				dwarf_offdie(dbg, offset, &sib, *cu);
  800420683c:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206843:	00 00 00 
  8004206846:	48 8b 08             	mov    (%rax),%rcx
  8004206849:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  8004206850:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004206854:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206858:	48 8b 38             	mov    (%rax),%rdi
  800420685b:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420685f:	48 8b 78 08          	mov    0x8(%rax),%rdi
  8004206863:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  8004206868:	48 8b 78 10          	mov    0x10(%rax),%rdi
  800420686c:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  8004206871:	48 8b 78 18          	mov    0x18(%rax),%rdi
  8004206875:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  800420687a:	48 8b 78 20          	mov    0x20(%rax),%rdi
  800420687e:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  8004206883:	48 8b 78 28          	mov    0x28(%rax),%rdi
  8004206887:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  800420688c:	48 8b 40 30          	mov    0x30(%rax),%rax
  8004206890:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  8004206895:	48 89 cf             	mov    %rcx,%rdi
  8004206898:	48 b8 d2 9d 20 04 80 	movabs $0x8004209dd2,%rax
  800420689f:	00 00 00 
  80042068a2:	ff d0                	callq  *%rax
				attr = _dwarf_attr_find(&sib, DW_AT_byte_size);
  80042068a4:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  80042068ab:	be 0b 00 00 00       	mov    $0xb,%esi
  80042068b0:	48 89 c7             	mov    %rax,%rdi
  80042068b3:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  80042068ba:	00 00 00 
  80042068bd:	ff d0                	callq  *%rax
  80042068bf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
		
				if(attr != NULL)
  80042068c3:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  80042068c8:	74 0e                	je     80042068d8 <list_func_die+0x366>
				{
					ret_val = attr->u[0].u64;
  80042068ca:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042068ce:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042068d2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042068d6:	eb 24                	jmp    80042068fc <list_func_die+0x38a>
				}
				else
				{
					attr = _dwarf_attr_find(&sib, DW_AT_type);
  80042068d8:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  80042068df:	be 49 00 00 00       	mov    $0x49,%esi
  80042068e4:	48 89 c7             	mov    %rax,%rdi
  80042068e7:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  80042068ee:	00 00 00 
  80042068f1:	ff d0                	callq  *%rax
  80042068f3:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
					goto try_again;
  80042068f7:	e9 1e ff ff ff       	jmpq   800420681a <list_func_die+0x2a8>
				}
			}

			ret_offset = 0;
  80042068fc:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004206903:	00 
			attr = _dwarf_attr_find(&ret, DW_AT_location);
  8004206904:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  800420690b:	be 02 00 00 00       	mov    $0x2,%esi
  8004206910:	48 89 c7             	mov    %rax,%rdi
  8004206913:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  800420691a:	00 00 00 
  800420691d:	ff d0                	callq  *%rax
  800420691f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			if (attr != NULL)
  8004206923:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004206928:	0f 84 a2 00 00 00    	je     80042069d0 <list_func_die+0x45e>
			{
				Dwarf_Unsigned loc_len = attr->at_block.bl_len;
  800420692e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206932:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004206936:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
				Dwarf_Small *loc_ptr = attr->at_block.bl_data;
  800420693a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420693e:	48 8b 40 40          	mov    0x40(%rax),%rax
  8004206942:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
				Dwarf_Small atom;
				Dwarf_Unsigned op1, op2;

				switch(attr->at_form) {
  8004206946:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420694a:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420694e:	48 83 f8 03          	cmp    $0x3,%rax
  8004206952:	72 7c                	jb     80042069d0 <list_func_die+0x45e>
  8004206954:	48 83 f8 04          	cmp    $0x4,%rax
  8004206958:	76 06                	jbe    8004206960 <list_func_die+0x3ee>
  800420695a:	48 83 f8 0a          	cmp    $0xa,%rax
  800420695e:	75 70                	jne    80042069d0 <list_func_die+0x45e>
					case DW_FORM_block1:
					case DW_FORM_block2:
					case DW_FORM_block4:
						offset = 0;
  8004206960:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8004206967:	00 
						atom = *(loc_ptr++);
  8004206968:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420696c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004206970:	48 89 55 b0          	mov    %rdx,-0x50(%rbp)
  8004206974:	0f b6 00             	movzbl (%rax),%eax
  8004206977:	88 45 af             	mov    %al,-0x51(%rbp)
						offset++;
  800420697a:	48 83 45 c0 01       	addq   $0x1,-0x40(%rbp)
						if (atom == DW_OP_fbreg) {
  800420697f:	80 7d af 91          	cmpb   $0x91,-0x51(%rbp)
  8004206983:	75 4a                	jne    80042069cf <list_func_die+0x45d>
							uint8_t *p = loc_ptr;
  8004206985:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004206989:	48 89 85 68 9e ff ff 	mov    %rax,-0x6198(%rbp)
							ret_offset = _dwarf_decode_sleb128(&p);
  8004206990:	48 8d 85 68 9e ff ff 	lea    -0x6198(%rbp),%rax
  8004206997:	48 89 c7             	mov    %rax,%rdi
  800420699a:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  80042069a1:	00 00 00 
  80042069a4:	ff d0                	callq  *%rax
  80042069a6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
							offset += p - loc_ptr;
  80042069aa:	48 8b 85 68 9e ff ff 	mov    -0x6198(%rbp),%rax
  80042069b1:	48 89 c2             	mov    %rax,%rdx
  80042069b4:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042069b8:	48 29 c2             	sub    %rax,%rdx
  80042069bb:	48 89 d0             	mov    %rdx,%rax
  80042069be:	48 01 45 c0          	add    %rax,-0x40(%rbp)
							loc_ptr = p;
  80042069c2:	48 8b 85 68 9e ff ff 	mov    -0x6198(%rbp),%rax
  80042069c9:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
						}
						break;
  80042069cd:	eb 00                	jmp    80042069cf <list_func_die+0x45d>
  80042069cf:	90                   	nop
				}
			}

			info->size_fn_arg[info->rip_fn_narg] = ret_val;
  80042069d0:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042069d7:	8b 48 28             	mov    0x28(%rax),%ecx
  80042069da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042069de:	89 c2                	mov    %eax,%edx
  80042069e0:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042069e7:	48 63 c9             	movslq %ecx,%rcx
  80042069ea:	48 83 c1 08          	add    $0x8,%rcx
  80042069ee:	89 54 88 0c          	mov    %edx,0xc(%rax,%rcx,4)
			info->offset_fn_arg[info->rip_fn_narg] = ret_offset;
  80042069f2:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  80042069f9:	8b 50 28             	mov    0x28(%rax),%edx
  80042069fc:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206a03:	48 63 d2             	movslq %edx,%rdx
  8004206a06:	48 8d 4a 0a          	lea    0xa(%rdx),%rcx
  8004206a0a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004206a0e:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
			info->rip_fn_narg++;
  8004206a13:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206a1a:	8b 40 28             	mov    0x28(%rax),%eax
  8004206a1d:	8d 50 01             	lea    0x1(%rax),%edx
  8004206a20:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206a27:	89 50 28             	mov    %edx,0x28(%rax)
			sib = ret; 
  8004206a2a:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004206a31:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  8004206a38:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004206a3d:	48 89 ce             	mov    %rcx,%rsi
  8004206a40:	48 89 c7             	mov    %rax,%rdi
  8004206a43:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  8004206a4a:	00 00 00 
  8004206a4d:	ff d0                	callq  *%rax

			while(dwarf_siblingof(dbg, &sib, &ret, cu) == DW_DLV_OK)	
  8004206a4f:	e9 40 02 00 00       	jmpq   8004206c94 <list_func_die+0x722>
			{
				if(ret.die_tag != DW_TAG_formal_parameter)
  8004206a54:	48 8b 85 f8 ce ff ff 	mov    -0x3108(%rbp),%rax
  8004206a5b:	48 83 f8 05          	cmp    $0x5,%rax
  8004206a5f:	74 05                	je     8004206a66 <list_func_die+0x4f4>
					break;
  8004206a61:	e9 64 02 00 00       	jmpq   8004206cca <list_func_die+0x758>

				attr = _dwarf_attr_find(&ret, DW_AT_type);
  8004206a66:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004206a6d:	be 49 00 00 00       	mov    $0x49,%esi
  8004206a72:	48 89 c7             	mov    %rax,%rdi
  8004206a75:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  8004206a7c:	00 00 00 
  8004206a7f:	ff d0                	callq  *%rax
  8004206a81:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    
				if(attr != NULL)
  8004206a85:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004206a8a:	0f 84 b1 00 00 00    	je     8004206b41 <list_func_die+0x5cf>
				{	   
					offset = (uint64_t)cu->cu_offset + attr->u[0].u64;
  8004206a90:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206a94:	48 8b 50 30          	mov    0x30(%rax),%rdx
  8004206a98:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206a9c:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206aa0:	48 01 d0             	add    %rdx,%rax
  8004206aa3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
					dwarf_offdie(dbg, offset, &sib, *cu);
  8004206aa7:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206aae:	00 00 00 
  8004206ab1:	48 8b 08             	mov    (%rax),%rcx
  8004206ab4:	48 8d 95 70 9e ff ff 	lea    -0x6190(%rbp),%rdx
  8004206abb:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  8004206abf:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004206ac3:	48 8b 38             	mov    (%rax),%rdi
  8004206ac6:	48 89 3c 24          	mov    %rdi,(%rsp)
  8004206aca:	48 8b 78 08          	mov    0x8(%rax),%rdi
  8004206ace:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  8004206ad3:	48 8b 78 10          	mov    0x10(%rax),%rdi
  8004206ad7:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  8004206adc:	48 8b 78 18          	mov    0x18(%rax),%rdi
  8004206ae0:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  8004206ae5:	48 8b 78 20          	mov    0x20(%rax),%rdi
  8004206ae9:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  8004206aee:	48 8b 78 28          	mov    0x28(%rax),%rdi
  8004206af2:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  8004206af7:	48 8b 40 30          	mov    0x30(%rax),%rax
  8004206afb:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  8004206b00:	48 89 cf             	mov    %rcx,%rdi
  8004206b03:	48 b8 d2 9d 20 04 80 	movabs $0x8004209dd2,%rax
  8004206b0a:	00 00 00 
  8004206b0d:	ff d0                	callq  *%rax
					attr = _dwarf_attr_find(&sib, DW_AT_byte_size);
  8004206b0f:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004206b16:	be 0b 00 00 00       	mov    $0xb,%esi
  8004206b1b:	48 89 c7             	mov    %rax,%rdi
  8004206b1e:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  8004206b25:	00 00 00 
  8004206b28:	ff d0                	callq  *%rax
  8004206b2a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
        
					if(attr != NULL)
  8004206b2e:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004206b33:	74 0c                	je     8004206b41 <list_func_die+0x5cf>
					{
						ret_val = attr->u[0].u64;
  8004206b35:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206b39:	48 8b 40 28          	mov    0x28(%rax),%rax
  8004206b3d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
					}
				}
	
				ret_offset = 0;
  8004206b41:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004206b48:	00 
				attr = _dwarf_attr_find(&ret, DW_AT_location);
  8004206b49:	48 8d 85 e0 ce ff ff 	lea    -0x3120(%rbp),%rax
  8004206b50:	be 02 00 00 00       	mov    $0x2,%esi
  8004206b55:	48 89 c7             	mov    %rax,%rdi
  8004206b58:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  8004206b5f:	00 00 00 
  8004206b62:	ff d0                	callq  *%rax
  8004206b64:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				if (attr != NULL)
  8004206b68:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004206b6d:	0f 84 a2 00 00 00    	je     8004206c15 <list_func_die+0x6a3>
				{
					Dwarf_Unsigned loc_len = attr->at_block.bl_len;
  8004206b73:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206b77:	48 8b 40 38          	mov    0x38(%rax),%rax
  8004206b7b:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
					Dwarf_Small *loc_ptr = attr->at_block.bl_data;
  8004206b7f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206b83:	48 8b 40 40          	mov    0x40(%rax),%rax
  8004206b87:	48 89 45 98          	mov    %rax,-0x68(%rbp)
					Dwarf_Small atom;
					Dwarf_Unsigned op1, op2;

					switch(attr->at_form) {
  8004206b8b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004206b8f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004206b93:	48 83 f8 03          	cmp    $0x3,%rax
  8004206b97:	72 7c                	jb     8004206c15 <list_func_die+0x6a3>
  8004206b99:	48 83 f8 04          	cmp    $0x4,%rax
  8004206b9d:	76 06                	jbe    8004206ba5 <list_func_die+0x633>
  8004206b9f:	48 83 f8 0a          	cmp    $0xa,%rax
  8004206ba3:	75 70                	jne    8004206c15 <list_func_die+0x6a3>
						case DW_FORM_block1:
						case DW_FORM_block2:
						case DW_FORM_block4:
							offset = 0;
  8004206ba5:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  8004206bac:	00 
							atom = *(loc_ptr++);
  8004206bad:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004206bb1:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004206bb5:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8004206bb9:	0f b6 00             	movzbl (%rax),%eax
  8004206bbc:	88 45 97             	mov    %al,-0x69(%rbp)
							offset++;
  8004206bbf:	48 83 45 c0 01       	addq   $0x1,-0x40(%rbp)
							if (atom == DW_OP_fbreg) {
  8004206bc4:	80 7d 97 91          	cmpb   $0x91,-0x69(%rbp)
  8004206bc8:	75 4a                	jne    8004206c14 <list_func_die+0x6a2>
								uint8_t *p = loc_ptr;
  8004206bca:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004206bce:	48 89 85 60 9e ff ff 	mov    %rax,-0x61a0(%rbp)
								ret_offset = _dwarf_decode_sleb128(&p);
  8004206bd5:	48 8d 85 60 9e ff ff 	lea    -0x61a0(%rbp),%rax
  8004206bdc:	48 89 c7             	mov    %rax,%rdi
  8004206bdf:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  8004206be6:	00 00 00 
  8004206be9:	ff d0                	callq  *%rax
  8004206beb:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
								offset += p - loc_ptr;
  8004206bef:	48 8b 85 60 9e ff ff 	mov    -0x61a0(%rbp),%rax
  8004206bf6:	48 89 c2             	mov    %rax,%rdx
  8004206bf9:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004206bfd:	48 29 c2             	sub    %rax,%rdx
  8004206c00:	48 89 d0             	mov    %rdx,%rax
  8004206c03:	48 01 45 c0          	add    %rax,-0x40(%rbp)
								loc_ptr = p;
  8004206c07:	48 8b 85 60 9e ff ff 	mov    -0x61a0(%rbp),%rax
  8004206c0e:	48 89 45 98          	mov    %rax,-0x68(%rbp)
							}
							break;
  8004206c12:	eb 00                	jmp    8004206c14 <list_func_die+0x6a2>
  8004206c14:	90                   	nop
					}
				}

				info->size_fn_arg[info->rip_fn_narg]=ret_val;// _get_arg_size(ret);
  8004206c15:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c1c:	8b 48 28             	mov    0x28(%rax),%ecx
  8004206c1f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004206c23:	89 c2                	mov    %eax,%edx
  8004206c25:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c2c:	48 63 c9             	movslq %ecx,%rcx
  8004206c2f:	48 83 c1 08          	add    $0x8,%rcx
  8004206c33:	89 54 88 0c          	mov    %edx,0xc(%rax,%rcx,4)
				info->offset_fn_arg[info->rip_fn_narg]=ret_offset;
  8004206c37:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c3e:	8b 50 28             	mov    0x28(%rax),%edx
  8004206c41:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c48:	48 63 d2             	movslq %edx,%rdx
  8004206c4b:	48 8d 4a 0a          	lea    0xa(%rdx),%rcx
  8004206c4f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004206c53:	48 89 54 c8 08       	mov    %rdx,0x8(%rax,%rcx,8)
				info->rip_fn_narg++;
  8004206c58:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c5f:	8b 40 28             	mov    0x28(%rax),%eax
  8004206c62:	8d 50 01             	lea    0x1(%rax),%edx
  8004206c65:	48 8b 85 58 9e ff ff 	mov    -0x61a8(%rbp),%rax
  8004206c6c:	89 50 28             	mov    %edx,0x28(%rax)
				sib = ret; 
  8004206c6f:	48 8d 85 70 9e ff ff 	lea    -0x6190(%rbp),%rax
  8004206c76:	48 8d 8d e0 ce ff ff 	lea    -0x3120(%rbp),%rcx
  8004206c7d:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004206c82:	48 89 ce             	mov    %rcx,%rsi
  8004206c85:	48 89 c7             	mov    %rax,%rdi
  8004206c88:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  8004206c8f:	00 00 00 
  8004206c92:	ff d0                	callq  *%rax
			info->size_fn_arg[info->rip_fn_narg] = ret_val;
			info->offset_fn_arg[info->rip_fn_narg] = ret_offset;
			info->rip_fn_narg++;
			sib = ret; 

			while(dwarf_siblingof(dbg, &sib, &ret, cu) == DW_DLV_OK)	
  8004206c94:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206c9b:	00 00 00 
  8004206c9e:	48 8b 00             	mov    (%rax),%rax
  8004206ca1:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004206ca5:	48 8d 95 e0 ce ff ff 	lea    -0x3120(%rbp),%rdx
  8004206cac:	48 8d b5 70 9e ff ff 	lea    -0x6190(%rbp),%rsi
  8004206cb3:	48 89 c7             	mov    %rax,%rdi
  8004206cb6:	48 b8 68 9f 20 04 80 	movabs $0x8004209f68,%rax
  8004206cbd:	00 00 00 
  8004206cc0:	ff d0                	callq  *%rax
  8004206cc2:	85 c0                	test   %eax,%eax
  8004206cc4:	0f 84 8a fd ff ff    	je     8004206a54 <list_func_die+0x4e2>
				info->rip_fn_narg++;
				sib = ret; 
			}
		}
	last:	
		return 1;
  8004206cca:	b8 01 00 00 00       	mov    $0x1,%eax
  8004206ccf:	eb 05                	jmp    8004206cd6 <list_func_die+0x764>
	}

	return 0;
  8004206cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004206cd6:	c9                   	leaveq 
  8004206cd7:	c3                   	retq   

0000008004206cd8 <debuginfo_rip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_rip(uintptr_t addr, struct Ripdebuginfo *info)
{
  8004206cd8:	55                   	push   %rbp
  8004206cd9:	48 89 e5             	mov    %rsp,%rbp
  8004206cdc:	53                   	push   %rbx
  8004206cdd:	48 81 ec c8 91 00 00 	sub    $0x91c8,%rsp
  8004206ce4:	48 89 bd 38 6e ff ff 	mov    %rdi,-0x91c8(%rbp)
  8004206ceb:	48 89 b5 30 6e ff ff 	mov    %rsi,-0x91d0(%rbp)
	static struct Env* lastenv = NULL;
	void* elf;    
	Dwarf_Section *sect;
	Dwarf_CU cu;
	Dwarf_Die die, cudie, die2;
	Dwarf_Regtable *rt = NULL;
  8004206cf2:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  8004206cf9:	00 
	//Set up initial pc
	uint64_t pc  = (uintptr_t)addr;
  8004206cfa:	48 8b 85 38 6e ff ff 	mov    -0x91c8(%rbp),%rax
  8004206d01:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

    
	// Initialize *info
	info->rip_file = "<unknown>";
  8004206d05:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d0c:	48 bb cf f6 20 04 80 	movabs $0x800420f6cf,%rbx
  8004206d13:	00 00 00 
  8004206d16:	48 89 18             	mov    %rbx,(%rax)
	info->rip_line = 0;
  8004206d19:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d20:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%rax)
	info->rip_fn_name = "<unknown>";
  8004206d27:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d2e:	48 bb cf f6 20 04 80 	movabs $0x800420f6cf,%rbx
  8004206d35:	00 00 00 
  8004206d38:	48 89 58 10          	mov    %rbx,0x10(%rax)
	info->rip_fn_namelen = 9;
  8004206d3c:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d43:	c7 40 18 09 00 00 00 	movl   $0x9,0x18(%rax)
	info->rip_fn_addr = addr;
  8004206d4a:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d51:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  8004206d58:	48 89 50 20          	mov    %rdx,0x20(%rax)
	info->rip_fn_narg = 0;
  8004206d5c:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206d63:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%rax)
    
	// Find the relevant set of stabs
	if (addr >= ULIM) {
  8004206d6a:	48 b8 ff ff bf 03 80 	movabs $0x8003bfffff,%rax
  8004206d71:	00 00 00 
  8004206d74:	48 39 85 38 6e ff ff 	cmp    %rax,-0x91c8(%rbp)
  8004206d7b:	0f 86 95 00 00 00    	jbe    8004206e16 <debuginfo_rip+0x13e>
		elf = (void *)0x10000 + KERNBASE;
  8004206d81:	48 b8 00 00 01 04 80 	movabs $0x8004010000,%rax
  8004206d88:	00 00 00 
  8004206d8b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	} else {
		// Can't search for user-level addresses yet!
		panic("User address");
	}
	_dwarf_init(dbg, elf);
  8004206d8f:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206d96:	00 00 00 
  8004206d99:	48 8b 00             	mov    (%rax),%rax
  8004206d9c:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004206da0:	48 89 d6             	mov    %rdx,%rsi
  8004206da3:	48 89 c7             	mov    %rax,%rdi
  8004206da6:	48 b8 e0 8d 20 04 80 	movabs $0x8004208de0,%rax
  8004206dad:	00 00 00 
  8004206db0:	ff d0                	callq  *%rax

	sect = _dwarf_find_section(".debug_info");	
  8004206db2:	48 bf e6 f6 20 04 80 	movabs $0x800420f6e6,%rdi
  8004206db9:	00 00 00 
  8004206dbc:	48 b8 77 d6 20 04 80 	movabs $0x800420d677,%rax
  8004206dc3:	00 00 00 
  8004206dc6:	ff d0                	callq  *%rax
  8004206dc8:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
  8004206dcc:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206dd3:	00 00 00 
  8004206dd6:	48 8b 00             	mov    (%rax),%rax
  8004206dd9:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206ddd:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004206de1:	48 89 50 08          	mov    %rdx,0x8(%rax)
	dbg->dbg_info_size = sect->ds_size;
  8004206de5:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206dec:	00 00 00 
  8004206def:	48 8b 00             	mov    (%rax),%rax
  8004206df2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  8004206df6:	48 8b 52 18          	mov    0x18(%rdx),%rdx
  8004206dfa:	48 89 50 10          	mov    %rdx,0x10(%rax)

	assert(dbg->dbg_info_size);
  8004206dfe:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206e05:	00 00 00 
  8004206e08:	48 8b 00             	mov    (%rax),%rax
  8004206e0b:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004206e0f:	48 85 c0             	test   %rax,%rax
  8004206e12:	75 61                	jne    8004206e75 <debuginfo_rip+0x19d>
  8004206e14:	eb 2a                	jmp    8004206e40 <debuginfo_rip+0x168>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		elf = (void *)0x10000 + KERNBASE;
	} else {
		// Can't search for user-level addresses yet!
		panic("User address");
  8004206e16:	48 ba d9 f6 20 04 80 	movabs $0x800420f6d9,%rdx
  8004206e1d:	00 00 00 
  8004206e20:	be 23 01 00 00       	mov    $0x123,%esi
  8004206e25:	48 bf c1 f6 20 04 80 	movabs $0x800420f6c1,%rdi
  8004206e2c:	00 00 00 
  8004206e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206e34:	48 b9 14 01 20 04 80 	movabs $0x8004200114,%rcx
  8004206e3b:	00 00 00 
  8004206e3e:	ff d1                	callq  *%rcx

	sect = _dwarf_find_section(".debug_info");	
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
	dbg->dbg_info_size = sect->ds_size;

	assert(dbg->dbg_info_size);
  8004206e40:	48 b9 f2 f6 20 04 80 	movabs $0x800420f6f2,%rcx
  8004206e47:	00 00 00 
  8004206e4a:	48 ba ac f6 20 04 80 	movabs $0x800420f6ac,%rdx
  8004206e51:	00 00 00 
  8004206e54:	be 2b 01 00 00       	mov    $0x12b,%esi
  8004206e59:	48 bf c1 f6 20 04 80 	movabs $0x800420f6c1,%rdi
  8004206e60:	00 00 00 
  8004206e63:	b8 00 00 00 00       	mov    $0x0,%eax
  8004206e68:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004206e6f:	00 00 00 
  8004206e72:	41 ff d0             	callq  *%r8
	while(_get_next_cu(dbg, &cu) == 0)
  8004206e75:	e9 6f 01 00 00       	jmpq   8004206fe9 <debuginfo_rip+0x311>
	{
		if(dwarf_siblingof(dbg, NULL, &cudie, &cu) == DW_DLE_NO_ENTRY)
  8004206e7a:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206e81:	00 00 00 
  8004206e84:	48 8b 00             	mov    (%rax),%rax
  8004206e87:	48 8d 4d 90          	lea    -0x70(%rbp),%rcx
  8004206e8b:	48 8d 95 b0 9e ff ff 	lea    -0x6150(%rbp),%rdx
  8004206e92:	be 00 00 00 00       	mov    $0x0,%esi
  8004206e97:	48 89 c7             	mov    %rax,%rdi
  8004206e9a:	48 b8 68 9f 20 04 80 	movabs $0x8004209f68,%rax
  8004206ea1:	00 00 00 
  8004206ea4:	ff d0                	callq  *%rax
  8004206ea6:	83 f8 04             	cmp    $0x4,%eax
  8004206ea9:	75 05                	jne    8004206eb0 <debuginfo_rip+0x1d8>
			continue;
  8004206eab:	e9 39 01 00 00       	jmpq   8004206fe9 <debuginfo_rip+0x311>

		cudie.cu_header = &cu;
  8004206eb0:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004206eb4:	48 89 85 10 a2 ff ff 	mov    %rax,-0x5df0(%rbp)
		cudie.cu_die = NULL;
  8004206ebb:	48 c7 85 18 a2 ff ff 	movq   $0x0,-0x5de8(%rbp)
  8004206ec2:	00 00 00 00 

		if(dwarf_child(dbg, &cu, &cudie, &die) == DW_DLE_NO_ENTRY)
  8004206ec6:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206ecd:	00 00 00 
  8004206ed0:	48 8b 00             	mov    (%rax),%rax
  8004206ed3:	48 8d 8d 20 cf ff ff 	lea    -0x30e0(%rbp),%rcx
  8004206eda:	48 8d 95 b0 9e ff ff 	lea    -0x6150(%rbp),%rdx
  8004206ee1:	48 8d 75 90          	lea    -0x70(%rbp),%rsi
  8004206ee5:	48 89 c7             	mov    %rax,%rdi
  8004206ee8:	48 b8 ac a1 20 04 80 	movabs $0x800420a1ac,%rax
  8004206eef:	00 00 00 
  8004206ef2:	ff d0                	callq  *%rax
  8004206ef4:	83 f8 04             	cmp    $0x4,%eax
  8004206ef7:	75 05                	jne    8004206efe <debuginfo_rip+0x226>
			continue;
  8004206ef9:	e9 eb 00 00 00       	jmpq   8004206fe9 <debuginfo_rip+0x311>

		die.cu_header = &cu;
  8004206efe:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004206f02:	48 89 85 80 d2 ff ff 	mov    %rax,-0x2d80(%rbp)
		die.cu_die = &cudie;
  8004206f09:	48 8d 85 b0 9e ff ff 	lea    -0x6150(%rbp),%rax
  8004206f10:	48 89 85 88 d2 ff ff 	mov    %rax,-0x2d78(%rbp)
		while(1)
		{
			if(list_func_die(info, &die, addr))
  8004206f17:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  8004206f1e:	48 8d 8d 20 cf ff ff 	lea    -0x30e0(%rbp),%rcx
  8004206f25:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004206f2c:	48 89 ce             	mov    %rcx,%rsi
  8004206f2f:	48 89 c7             	mov    %rax,%rdi
  8004206f32:	48 b8 72 65 20 04 80 	movabs $0x8004206572,%rax
  8004206f39:	00 00 00 
  8004206f3c:	ff d0                	callq  *%rax
  8004206f3e:	85 c0                	test   %eax,%eax
  8004206f40:	74 30                	je     8004206f72 <debuginfo_rip+0x29a>
				goto find_done;
  8004206f42:	90                   	nop

	return -1;

find_done:

	if (dwarf_init_eh_section(dbg, NULL) == DW_DLV_ERROR)
  8004206f43:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206f4a:	00 00 00 
  8004206f4d:	48 8b 00             	mov    (%rax),%rax
  8004206f50:	be 00 00 00 00       	mov    $0x0,%esi
  8004206f55:	48 89 c7             	mov    %rax,%rdi
  8004206f58:	48 b8 84 c8 20 04 80 	movabs $0x800420c884,%rax
  8004206f5f:	00 00 00 
  8004206f62:	ff d0                	callq  *%rax
  8004206f64:	83 f8 01             	cmp    $0x1,%eax
  8004206f67:	0f 85 bb 00 00 00    	jne    8004207028 <debuginfo_rip+0x350>
  8004206f6d:	e9 ac 00 00 00       	jmpq   800420701e <debuginfo_rip+0x346>
		die.cu_die = &cudie;
		while(1)
		{
			if(list_func_die(info, &die, addr))
				goto find_done;
			if(dwarf_siblingof(dbg, &die, &die2, &cu) < 0)
  8004206f72:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206f79:	00 00 00 
  8004206f7c:	48 8b 00             	mov    (%rax),%rax
  8004206f7f:	48 8d 4d 90          	lea    -0x70(%rbp),%rcx
  8004206f83:	48 8d 95 40 6e ff ff 	lea    -0x91c0(%rbp),%rdx
  8004206f8a:	48 8d b5 20 cf ff ff 	lea    -0x30e0(%rbp),%rsi
  8004206f91:	48 89 c7             	mov    %rax,%rdi
  8004206f94:	48 b8 68 9f 20 04 80 	movabs $0x8004209f68,%rax
  8004206f9b:	00 00 00 
  8004206f9e:	ff d0                	callq  *%rax
  8004206fa0:	85 c0                	test   %eax,%eax
  8004206fa2:	79 02                	jns    8004206fa6 <debuginfo_rip+0x2ce>
				break; 
  8004206fa4:	eb 43                	jmp    8004206fe9 <debuginfo_rip+0x311>
			die = die2;
  8004206fa6:	48 8d 85 20 cf ff ff 	lea    -0x30e0(%rbp),%rax
  8004206fad:	48 8d 8d 40 6e ff ff 	lea    -0x91c0(%rbp),%rcx
  8004206fb4:	ba 70 30 00 00       	mov    $0x3070,%edx
  8004206fb9:	48 89 ce             	mov    %rcx,%rsi
  8004206fbc:	48 89 c7             	mov    %rax,%rdi
  8004206fbf:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  8004206fc6:	00 00 00 
  8004206fc9:	ff d0                	callq  *%rax
			die.cu_header = &cu;
  8004206fcb:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  8004206fcf:	48 89 85 80 d2 ff ff 	mov    %rax,-0x2d80(%rbp)
			die.cu_die = &cudie;
  8004206fd6:	48 8d 85 b0 9e ff ff 	lea    -0x6150(%rbp),%rax
  8004206fdd:	48 89 85 88 d2 ff ff 	mov    %rax,-0x2d78(%rbp)
		}
  8004206fe4:	e9 2e ff ff ff       	jmpq   8004206f17 <debuginfo_rip+0x23f>
	sect = _dwarf_find_section(".debug_info");	
	dbg->dbg_info_offset_elf = (uint64_t)sect->ds_data; 
	dbg->dbg_info_size = sect->ds_size;

	assert(dbg->dbg_info_size);
	while(_get_next_cu(dbg, &cu) == 0)
  8004206fe9:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004206ff0:	00 00 00 
  8004206ff3:	48 8b 00             	mov    (%rax),%rax
  8004206ff6:	48 8d 55 90          	lea    -0x70(%rbp),%rdx
  8004206ffa:	48 89 d6             	mov    %rdx,%rsi
  8004206ffd:	48 89 c7             	mov    %rax,%rdi
  8004207000:	48 b8 c2 8e 20 04 80 	movabs $0x8004208ec2,%rax
  8004207007:	00 00 00 
  800420700a:	ff d0                	callq  *%rax
  800420700c:	85 c0                	test   %eax,%eax
  800420700e:	0f 84 66 fe ff ff    	je     8004206e7a <debuginfo_rip+0x1a2>
			die.cu_header = &cu;
			die.cu_die = &cudie;
		}
	}

	return -1;
  8004207014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004207019:	e9 a0 00 00 00       	jmpq   80042070be <debuginfo_rip+0x3e6>

find_done:

	if (dwarf_init_eh_section(dbg, NULL) == DW_DLV_ERROR)
		return -1;
  800420701e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004207023:	e9 96 00 00 00       	jmpq   80042070be <debuginfo_rip+0x3e6>

	if (dwarf_get_fde_at_pc(dbg, addr, fde, cie, NULL) == DW_DLV_OK) {
  8004207028:	48 b8 d0 25 22 04 80 	movabs $0x80042225d0,%rax
  800420702f:	00 00 00 
  8004207032:	48 8b 08             	mov    (%rax),%rcx
  8004207035:	48 b8 c8 25 22 04 80 	movabs $0x80042225c8,%rax
  800420703c:	00 00 00 
  800420703f:	48 8b 10             	mov    (%rax),%rdx
  8004207042:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004207049:	00 00 00 
  800420704c:	48 8b 00             	mov    (%rax),%rax
  800420704f:	48 8b b5 38 6e ff ff 	mov    -0x91c8(%rbp),%rsi
  8004207056:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  800420705c:	48 89 c7             	mov    %rax,%rdi
  800420705f:	48 b8 ed a3 20 04 80 	movabs $0x800420a3ed,%rax
  8004207066:	00 00 00 
  8004207069:	ff d0                	callq  *%rax
  800420706b:	85 c0                	test   %eax,%eax
  800420706d:	75 4a                	jne    80042070b9 <debuginfo_rip+0x3e1>
		dwarf_get_fde_info_for_all_regs(dbg, fde, addr,
  800420706f:	48 8b 85 30 6e ff ff 	mov    -0x91d0(%rbp),%rax
  8004207076:	48 8d 88 a8 00 00 00 	lea    0xa8(%rax),%rcx
  800420707d:	48 b8 c8 25 22 04 80 	movabs $0x80042225c8,%rax
  8004207084:	00 00 00 
  8004207087:	48 8b 30             	mov    (%rax),%rsi
  800420708a:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  8004207091:	00 00 00 
  8004207094:	48 8b 00             	mov    (%rax),%rax
  8004207097:	48 8b 95 38 6e ff ff 	mov    -0x91c8(%rbp),%rdx
  800420709e:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  80042070a4:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  80042070aa:	48 89 c7             	mov    %rax,%rdi
  80042070ad:	48 b8 f9 b6 20 04 80 	movabs $0x800420b6f9,%rax
  80042070b4:	00 00 00 
  80042070b7:	ff d0                	callq  *%rax
					break;
			}
		}
#endif
	}
	return 0;
  80042070b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042070be:	48 81 c4 c8 91 00 00 	add    $0x91c8,%rsp
  80042070c5:	5b                   	pop    %rbx
  80042070c6:	5d                   	pop    %rbp
  80042070c7:	c3                   	retq   

00000080042070c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042070c8:	55                   	push   %rbp
  80042070c9:	48 89 e5             	mov    %rsp,%rbp
  80042070cc:	53                   	push   %rbx
  80042070cd:	48 83 ec 38          	sub    $0x38,%rsp
  80042070d1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042070d5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80042070d9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80042070dd:	89 4d d4             	mov    %ecx,-0x2c(%rbp)
  80042070e0:	44 89 45 d0          	mov    %r8d,-0x30(%rbp)
  80042070e4:	44 89 4d cc          	mov    %r9d,-0x34(%rbp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042070e8:	8b 45 d4             	mov    -0x2c(%rbp),%eax
  80042070eb:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  80042070ef:	77 3b                	ja     800420712c <printnum+0x64>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042070f1:	8b 45 d0             	mov    -0x30(%rbp),%eax
  80042070f4:	44 8d 40 ff          	lea    -0x1(%rax),%r8d
  80042070f8:	8b 5d d4             	mov    -0x2c(%rbp),%ebx
  80042070fb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042070ff:	ba 00 00 00 00       	mov    $0x0,%edx
  8004207104:	48 f7 f3             	div    %rbx
  8004207107:	48 89 c2             	mov    %rax,%rdx
  800420710a:	8b 7d cc             	mov    -0x34(%rbp),%edi
  800420710d:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  8004207110:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  8004207114:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207118:	41 89 f9             	mov    %edi,%r9d
  800420711b:	48 89 c7             	mov    %rax,%rdi
  800420711e:	48 b8 c8 70 20 04 80 	movabs $0x80042070c8,%rax
  8004207125:	00 00 00 
  8004207128:	ff d0                	callq  *%rax
  800420712a:	eb 1e                	jmp    800420714a <printnum+0x82>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800420712c:	eb 12                	jmp    8004207140 <printnum+0x78>
			putch(padc, putdat);
  800420712e:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004207132:	8b 55 cc             	mov    -0x34(%rbp),%edx
  8004207135:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207139:	48 89 ce             	mov    %rcx,%rsi
  800420713c:	89 d7                	mov    %edx,%edi
  800420713e:	ff d0                	callq  *%rax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004207140:	83 6d d0 01          	subl   $0x1,-0x30(%rbp)
  8004207144:	83 7d d0 00          	cmpl   $0x0,-0x30(%rbp)
  8004207148:	7f e4                	jg     800420712e <printnum+0x66>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800420714a:	8b 4d d4             	mov    -0x2c(%rbp),%ecx
  800420714d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004207151:	ba 00 00 00 00       	mov    $0x0,%edx
  8004207156:	48 f7 f1             	div    %rcx
  8004207159:	48 89 d0             	mov    %rdx,%rax
  800420715c:	48 ba 50 f8 20 04 80 	movabs $0x800420f850,%rdx
  8004207163:	00 00 00 
  8004207166:	0f b6 04 02          	movzbl (%rdx,%rax,1),%eax
  800420716a:	0f be d0             	movsbl %al,%edx
  800420716d:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  8004207171:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207175:	48 89 ce             	mov    %rcx,%rsi
  8004207178:	89 d7                	mov    %edx,%edi
  800420717a:	ff d0                	callq  *%rax
}
  800420717c:	48 83 c4 38          	add    $0x38,%rsp
  8004207180:	5b                   	pop    %rbx
  8004207181:	5d                   	pop    %rbp
  8004207182:	c3                   	retq   

0000008004207183 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004207183:	55                   	push   %rbp
  8004207184:	48 89 e5             	mov    %rsp,%rbp
  8004207187:	48 83 ec 1c          	sub    $0x1c,%rsp
  800420718b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420718f:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	unsigned long long x;    
	if (lflag >= 2)
  8004207192:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  8004207196:	7e 52                	jle    80042071ea <getuint+0x67>
		x= va_arg(*ap, unsigned long long);
  8004207198:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420719c:	8b 00                	mov    (%rax),%eax
  800420719e:	83 f8 30             	cmp    $0x30,%eax
  80042071a1:	73 24                	jae    80042071c7 <getuint+0x44>
  80042071a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071a7:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042071ab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071af:	8b 00                	mov    (%rax),%eax
  80042071b1:	89 c0                	mov    %eax,%eax
  80042071b3:	48 01 d0             	add    %rdx,%rax
  80042071b6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042071ba:	8b 12                	mov    (%rdx),%edx
  80042071bc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80042071bf:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042071c3:	89 0a                	mov    %ecx,(%rdx)
  80042071c5:	eb 17                	jmp    80042071de <getuint+0x5b>
  80042071c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071cb:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042071cf:	48 89 d0             	mov    %rdx,%rax
  80042071d2:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  80042071d6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042071da:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80042071de:	48 8b 00             	mov    (%rax),%rax
  80042071e1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042071e5:	e9 a3 00 00 00       	jmpq   800420728d <getuint+0x10a>
	else if (lflag)
  80042071ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  80042071ee:	74 4f                	je     800420723f <getuint+0xbc>
		x= va_arg(*ap, unsigned long);
  80042071f0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071f4:	8b 00                	mov    (%rax),%eax
  80042071f6:	83 f8 30             	cmp    $0x30,%eax
  80042071f9:	73 24                	jae    800420721f <getuint+0x9c>
  80042071fb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042071ff:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004207203:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207207:	8b 00                	mov    (%rax),%eax
  8004207209:	89 c0                	mov    %eax,%eax
  800420720b:	48 01 d0             	add    %rdx,%rax
  800420720e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207212:	8b 12                	mov    (%rdx),%edx
  8004207214:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8004207217:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420721b:	89 0a                	mov    %ecx,(%rdx)
  800420721d:	eb 17                	jmp    8004207236 <getuint+0xb3>
  800420721f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207223:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004207227:	48 89 d0             	mov    %rdx,%rax
  800420722a:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420722e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207232:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004207236:	48 8b 00             	mov    (%rax),%rax
  8004207239:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420723d:	eb 4e                	jmp    800420728d <getuint+0x10a>
	else
		x= va_arg(*ap, unsigned int);
  800420723f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207243:	8b 00                	mov    (%rax),%eax
  8004207245:	83 f8 30             	cmp    $0x30,%eax
  8004207248:	73 24                	jae    800420726e <getuint+0xeb>
  800420724a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420724e:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004207252:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207256:	8b 00                	mov    (%rax),%eax
  8004207258:	89 c0                	mov    %eax,%eax
  800420725a:	48 01 d0             	add    %rdx,%rax
  800420725d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207261:	8b 12                	mov    (%rdx),%edx
  8004207263:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8004207266:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420726a:	89 0a                	mov    %ecx,(%rdx)
  800420726c:	eb 17                	jmp    8004207285 <getuint+0x102>
  800420726e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207272:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004207276:	48 89 d0             	mov    %rdx,%rax
  8004207279:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420727d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207281:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004207285:	8b 00                	mov    (%rax),%eax
  8004207287:	89 c0                	mov    %eax,%eax
  8004207289:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  800420728d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004207291:	c9                   	leaveq 
  8004207292:	c3                   	retq   

0000008004207293 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8004207293:	55                   	push   %rbp
  8004207294:	48 89 e5             	mov    %rsp,%rbp
  8004207297:	48 83 ec 1c          	sub    $0x1c,%rsp
  800420729b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420729f:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	long long x;
	if (lflag >= 2)
  80042072a2:	83 7d e4 01          	cmpl   $0x1,-0x1c(%rbp)
  80042072a6:	7e 52                	jle    80042072fa <getint+0x67>
		x=va_arg(*ap, long long);
  80042072a8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072ac:	8b 00                	mov    (%rax),%eax
  80042072ae:	83 f8 30             	cmp    $0x30,%eax
  80042072b1:	73 24                	jae    80042072d7 <getint+0x44>
  80042072b3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072b7:	48 8b 50 10          	mov    0x10(%rax),%rdx
  80042072bb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072bf:	8b 00                	mov    (%rax),%eax
  80042072c1:	89 c0                	mov    %eax,%eax
  80042072c3:	48 01 d0             	add    %rdx,%rax
  80042072c6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042072ca:	8b 12                	mov    (%rdx),%edx
  80042072cc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  80042072cf:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042072d3:	89 0a                	mov    %ecx,(%rdx)
  80042072d5:	eb 17                	jmp    80042072ee <getint+0x5b>
  80042072d7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042072db:	48 8b 50 08          	mov    0x8(%rax),%rdx
  80042072df:	48 89 d0             	mov    %rdx,%rax
  80042072e2:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  80042072e6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042072ea:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  80042072ee:	48 8b 00             	mov    (%rax),%rax
  80042072f1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  80042072f5:	e9 a3 00 00 00       	jmpq   800420739d <getint+0x10a>
	else if (lflag)
  80042072fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  80042072fe:	74 4f                	je     800420734f <getint+0xbc>
		x=va_arg(*ap, long);
  8004207300:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207304:	8b 00                	mov    (%rax),%eax
  8004207306:	83 f8 30             	cmp    $0x30,%eax
  8004207309:	73 24                	jae    800420732f <getint+0x9c>
  800420730b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420730f:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004207313:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207317:	8b 00                	mov    (%rax),%eax
  8004207319:	89 c0                	mov    %eax,%eax
  800420731b:	48 01 d0             	add    %rdx,%rax
  800420731e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207322:	8b 12                	mov    (%rdx),%edx
  8004207324:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8004207327:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420732b:	89 0a                	mov    %ecx,(%rdx)
  800420732d:	eb 17                	jmp    8004207346 <getint+0xb3>
  800420732f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207333:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004207337:	48 89 d0             	mov    %rdx,%rax
  800420733a:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420733e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207342:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004207346:	48 8b 00             	mov    (%rax),%rax
  8004207349:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420734d:	eb 4e                	jmp    800420739d <getint+0x10a>
	else
		x=va_arg(*ap, int);
  800420734f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207353:	8b 00                	mov    (%rax),%eax
  8004207355:	83 f8 30             	cmp    $0x30,%eax
  8004207358:	73 24                	jae    800420737e <getint+0xeb>
  800420735a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420735e:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004207362:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207366:	8b 00                	mov    (%rax),%eax
  8004207368:	89 c0                	mov    %eax,%eax
  800420736a:	48 01 d0             	add    %rdx,%rax
  800420736d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207371:	8b 12                	mov    (%rdx),%edx
  8004207373:	8d 4a 08             	lea    0x8(%rdx),%ecx
  8004207376:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420737a:	89 0a                	mov    %ecx,(%rdx)
  800420737c:	eb 17                	jmp    8004207395 <getint+0x102>
  800420737e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207382:	48 8b 50 08          	mov    0x8(%rax),%rdx
  8004207386:	48 89 d0             	mov    %rdx,%rax
  8004207389:	48 8d 4a 08          	lea    0x8(%rdx),%rcx
  800420738d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207391:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  8004207395:	8b 00                	mov    (%rax),%eax
  8004207397:	48 98                	cltq   
  8004207399:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	return x;
  800420739d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  80042073a1:	c9                   	leaveq 
  80042073a2:	c3                   	retq   

00000080042073a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042073a3:	55                   	push   %rbp
  80042073a4:	48 89 e5             	mov    %rsp,%rbp
  80042073a7:	41 54                	push   %r12
  80042073a9:	53                   	push   %rbx
  80042073aa:	48 83 ec 60          	sub    $0x60,%rsp
  80042073ae:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  80042073b2:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  80042073b6:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  80042073ba:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
  80042073be:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  80042073c2:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  80042073c6:	48 8b 0a             	mov    (%rdx),%rcx
  80042073c9:	48 89 08             	mov    %rcx,(%rax)
  80042073cc:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042073d0:	48 89 48 08          	mov    %rcx,0x8(%rax)
  80042073d4:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80042073d8:	48 89 50 10          	mov    %rdx,0x10(%rax)
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042073dc:	eb 17                	jmp    80042073f5 <vprintfmt+0x52>
			if (ch == '\0')
  80042073de:	85 db                	test   %ebx,%ebx
  80042073e0:	0f 84 df 04 00 00    	je     80042078c5 <vprintfmt+0x522>
				return;
			putch(ch, putdat);
  80042073e6:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042073ea:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042073ee:	48 89 d6             	mov    %rdx,%rsi
  80042073f1:	89 df                	mov    %ebx,%edi
  80042073f3:	ff d0                	callq  *%rax
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042073f5:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042073f9:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80042073fd:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8004207401:	0f b6 00             	movzbl (%rax),%eax
  8004207404:	0f b6 d8             	movzbl %al,%ebx
  8004207407:	83 fb 25             	cmp    $0x25,%ebx
  800420740a:	75 d2                	jne    80042073de <vprintfmt+0x3b>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800420740c:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
		width = -1;
  8004207410:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%rbp)
		precision = -1;
  8004207417:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
		lflag = 0;
  800420741e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
		altflag = 0;
  8004207425:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420742c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004207430:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207434:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  8004207438:	0f b6 00             	movzbl (%rax),%eax
  800420743b:	0f b6 d8             	movzbl %al,%ebx
  800420743e:	8d 43 dd             	lea    -0x23(%rbx),%eax
  8004207441:	83 f8 55             	cmp    $0x55,%eax
  8004207444:	0f 87 47 04 00 00    	ja     8004207891 <vprintfmt+0x4ee>
  800420744a:	89 c0                	mov    %eax,%eax
  800420744c:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  8004207453:	00 
  8004207454:	48 b8 78 f8 20 04 80 	movabs $0x800420f878,%rax
  800420745b:	00 00 00 
  800420745e:	48 01 d0             	add    %rdx,%rax
  8004207461:	48 8b 00             	mov    (%rax),%rax
  8004207464:	ff e0                	jmpq   *%rax

			// flag to pad on the right
		case '-':
			padc = '-';
  8004207466:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%rbp)
			goto reswitch;
  800420746a:	eb c0                	jmp    800420742c <vprintfmt+0x89>

			// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420746c:	c6 45 d3 30          	movb   $0x30,-0x2d(%rbp)
			goto reswitch;
  8004207470:	eb ba                	jmp    800420742c <vprintfmt+0x89>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004207472:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%rbp)
				precision = precision * 10 + ch - '0';
  8004207479:	8b 55 d8             	mov    -0x28(%rbp),%edx
  800420747c:	89 d0                	mov    %edx,%eax
  800420747e:	c1 e0 02             	shl    $0x2,%eax
  8004207481:	01 d0                	add    %edx,%eax
  8004207483:	01 c0                	add    %eax,%eax
  8004207485:	01 d8                	add    %ebx,%eax
  8004207487:	83 e8 30             	sub    $0x30,%eax
  800420748a:	89 45 d8             	mov    %eax,-0x28(%rbp)
				ch = *fmt;
  800420748d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8004207491:	0f b6 00             	movzbl (%rax),%eax
  8004207494:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004207497:	83 fb 2f             	cmp    $0x2f,%ebx
  800420749a:	7e 0c                	jle    80042074a8 <vprintfmt+0x105>
  800420749c:	83 fb 39             	cmp    $0x39,%ebx
  800420749f:	7f 07                	jg     80042074a8 <vprintfmt+0x105>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042074a1:	48 83 45 98 01       	addq   $0x1,-0x68(%rbp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042074a6:	eb d1                	jmp    8004207479 <vprintfmt+0xd6>
			goto process_precision;
  80042074a8:	eb 58                	jmp    8004207502 <vprintfmt+0x15f>

		case '*':
			precision = va_arg(aq, int);
  80042074aa:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042074ad:	83 f8 30             	cmp    $0x30,%eax
  80042074b0:	73 17                	jae    80042074c9 <vprintfmt+0x126>
  80042074b2:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042074b6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042074b9:	89 c0                	mov    %eax,%eax
  80042074bb:	48 01 d0             	add    %rdx,%rax
  80042074be:	8b 55 b8             	mov    -0x48(%rbp),%edx
  80042074c1:	83 c2 08             	add    $0x8,%edx
  80042074c4:	89 55 b8             	mov    %edx,-0x48(%rbp)
  80042074c7:	eb 0f                	jmp    80042074d8 <vprintfmt+0x135>
  80042074c9:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80042074cd:	48 89 d0             	mov    %rdx,%rax
  80042074d0:	48 83 c2 08          	add    $0x8,%rdx
  80042074d4:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  80042074d8:	8b 00                	mov    (%rax),%eax
  80042074da:	89 45 d8             	mov    %eax,-0x28(%rbp)
			goto process_precision;
  80042074dd:	eb 23                	jmp    8004207502 <vprintfmt+0x15f>

		case '.':
			if (width < 0)
  80042074df:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  80042074e3:	79 0c                	jns    80042074f1 <vprintfmt+0x14e>
				width = 0;
  80042074e5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
			goto reswitch;
  80042074ec:	e9 3b ff ff ff       	jmpq   800420742c <vprintfmt+0x89>
  80042074f1:	e9 36 ff ff ff       	jmpq   800420742c <vprintfmt+0x89>

		case '#':
			altflag = 1;
  80042074f6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
			goto reswitch;
  80042074fd:	e9 2a ff ff ff       	jmpq   800420742c <vprintfmt+0x89>

		process_precision:
			if (width < 0)
  8004207502:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8004207506:	79 12                	jns    800420751a <vprintfmt+0x177>
				width = precision, precision = -1;
  8004207508:	8b 45 d8             	mov    -0x28(%rbp),%eax
  800420750b:	89 45 dc             	mov    %eax,-0x24(%rbp)
  800420750e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%rbp)
			goto reswitch;
  8004207515:	e9 12 ff ff ff       	jmpq   800420742c <vprintfmt+0x89>
  800420751a:	e9 0d ff ff ff       	jmpq   800420742c <vprintfmt+0x89>

			// long flag (doubled for long long)
		case 'l':
			lflag++;
  800420751f:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
			goto reswitch;
  8004207523:	e9 04 ff ff ff       	jmpq   800420742c <vprintfmt+0x89>

			// character
		case 'c':
			putch(va_arg(aq, int), putdat);
  8004207528:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800420752b:	83 f8 30             	cmp    $0x30,%eax
  800420752e:	73 17                	jae    8004207547 <vprintfmt+0x1a4>
  8004207530:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207534:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004207537:	89 c0                	mov    %eax,%eax
  8004207539:	48 01 d0             	add    %rdx,%rax
  800420753c:	8b 55 b8             	mov    -0x48(%rbp),%edx
  800420753f:	83 c2 08             	add    $0x8,%edx
  8004207542:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8004207545:	eb 0f                	jmp    8004207556 <vprintfmt+0x1b3>
  8004207547:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420754b:	48 89 d0             	mov    %rdx,%rax
  800420754e:	48 83 c2 08          	add    $0x8,%rdx
  8004207552:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8004207556:	8b 10                	mov    (%rax),%edx
  8004207558:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800420755c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207560:	48 89 ce             	mov    %rcx,%rsi
  8004207563:	89 d7                	mov    %edx,%edi
  8004207565:	ff d0                	callq  *%rax
			break;
  8004207567:	e9 53 03 00 00       	jmpq   80042078bf <vprintfmt+0x51c>

			// error message
		case 'e':
			err = va_arg(aq, int);
  800420756c:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800420756f:	83 f8 30             	cmp    $0x30,%eax
  8004207572:	73 17                	jae    800420758b <vprintfmt+0x1e8>
  8004207574:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207578:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800420757b:	89 c0                	mov    %eax,%eax
  800420757d:	48 01 d0             	add    %rdx,%rax
  8004207580:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8004207583:	83 c2 08             	add    $0x8,%edx
  8004207586:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8004207589:	eb 0f                	jmp    800420759a <vprintfmt+0x1f7>
  800420758b:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420758f:	48 89 d0             	mov    %rdx,%rax
  8004207592:	48 83 c2 08          	add    $0x8,%rdx
  8004207596:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800420759a:	8b 18                	mov    (%rax),%ebx
			if (err < 0)
  800420759c:	85 db                	test   %ebx,%ebx
  800420759e:	79 02                	jns    80042075a2 <vprintfmt+0x1ff>
				err = -err;
  80042075a0:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042075a2:	83 fb 15             	cmp    $0x15,%ebx
  80042075a5:	7f 16                	jg     80042075bd <vprintfmt+0x21a>
  80042075a7:	48 b8 a0 f7 20 04 80 	movabs $0x800420f7a0,%rax
  80042075ae:	00 00 00 
  80042075b1:	48 63 d3             	movslq %ebx,%rdx
  80042075b4:	4c 8b 24 d0          	mov    (%rax,%rdx,8),%r12
  80042075b8:	4d 85 e4             	test   %r12,%r12
  80042075bb:	75 2e                	jne    80042075eb <vprintfmt+0x248>
				printfmt(putch, putdat, "error %d", err);
  80042075bd:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  80042075c1:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042075c5:	89 d9                	mov    %ebx,%ecx
  80042075c7:	48 ba 61 f8 20 04 80 	movabs $0x800420f861,%rdx
  80042075ce:	00 00 00 
  80042075d1:	48 89 c7             	mov    %rax,%rdi
  80042075d4:	b8 00 00 00 00       	mov    $0x0,%eax
  80042075d9:	49 b8 ce 78 20 04 80 	movabs $0x80042078ce,%r8
  80042075e0:	00 00 00 
  80042075e3:	41 ff d0             	callq  *%r8
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80042075e6:	e9 d4 02 00 00       	jmpq   80042078bf <vprintfmt+0x51c>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80042075eb:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  80042075ef:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042075f3:	4c 89 e1             	mov    %r12,%rcx
  80042075f6:	48 ba 6a f8 20 04 80 	movabs $0x800420f86a,%rdx
  80042075fd:	00 00 00 
  8004207600:	48 89 c7             	mov    %rax,%rdi
  8004207603:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207608:	49 b8 ce 78 20 04 80 	movabs $0x80042078ce,%r8
  800420760f:	00 00 00 
  8004207612:	41 ff d0             	callq  *%r8
			break;
  8004207615:	e9 a5 02 00 00       	jmpq   80042078bf <vprintfmt+0x51c>

			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
  800420761a:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800420761d:	83 f8 30             	cmp    $0x30,%eax
  8004207620:	73 17                	jae    8004207639 <vprintfmt+0x296>
  8004207622:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004207626:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004207629:	89 c0                	mov    %eax,%eax
  800420762b:	48 01 d0             	add    %rdx,%rax
  800420762e:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8004207631:	83 c2 08             	add    $0x8,%edx
  8004207634:	89 55 b8             	mov    %edx,-0x48(%rbp)
  8004207637:	eb 0f                	jmp    8004207648 <vprintfmt+0x2a5>
  8004207639:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420763d:	48 89 d0             	mov    %rdx,%rax
  8004207640:	48 83 c2 08          	add    $0x8,%rdx
  8004207644:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  8004207648:	4c 8b 20             	mov    (%rax),%r12
  800420764b:	4d 85 e4             	test   %r12,%r12
  800420764e:	75 0a                	jne    800420765a <vprintfmt+0x2b7>
				p = "(null)";
  8004207650:	49 bc 6d f8 20 04 80 	movabs $0x800420f86d,%r12
  8004207657:	00 00 00 
			if (width > 0 && padc != '-')
  800420765a:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420765e:	7e 3f                	jle    800420769f <vprintfmt+0x2fc>
  8004207660:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%rbp)
  8004207664:	74 39                	je     800420769f <vprintfmt+0x2fc>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004207666:	8b 45 d8             	mov    -0x28(%rbp),%eax
  8004207669:	48 98                	cltq   
  800420766b:	48 89 c6             	mov    %rax,%rsi
  800420766e:	4c 89 e7             	mov    %r12,%rdi
  8004207671:	48 b8 c9 7c 20 04 80 	movabs $0x8004207cc9,%rax
  8004207678:	00 00 00 
  800420767b:	ff d0                	callq  *%rax
  800420767d:	29 45 dc             	sub    %eax,-0x24(%rbp)
  8004207680:	eb 17                	jmp    8004207699 <vprintfmt+0x2f6>
					putch(padc, putdat);
  8004207682:	0f be 55 d3          	movsbl -0x2d(%rbp),%edx
  8004207686:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800420768a:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420768e:	48 89 ce             	mov    %rcx,%rsi
  8004207691:	89 d7                	mov    %edx,%edi
  8004207693:	ff d0                	callq  *%rax
			// string
		case 's':
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004207695:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  8004207699:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420769d:	7f e3                	jg     8004207682 <vprintfmt+0x2df>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800420769f:	eb 37                	jmp    80042076d8 <vprintfmt+0x335>
				if (altflag && (ch < ' ' || ch > '~'))
  80042076a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  80042076a5:	74 1e                	je     80042076c5 <vprintfmt+0x322>
  80042076a7:	83 fb 1f             	cmp    $0x1f,%ebx
  80042076aa:	7e 05                	jle    80042076b1 <vprintfmt+0x30e>
  80042076ac:	83 fb 7e             	cmp    $0x7e,%ebx
  80042076af:	7e 14                	jle    80042076c5 <vprintfmt+0x322>
					putch('?', putdat);
  80042076b1:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042076b5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042076b9:	48 89 d6             	mov    %rdx,%rsi
  80042076bc:	bf 3f 00 00 00       	mov    $0x3f,%edi
  80042076c1:	ff d0                	callq  *%rax
  80042076c3:	eb 0f                	jmp    80042076d4 <vprintfmt+0x331>
				else
					putch(ch, putdat);
  80042076c5:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042076c9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042076cd:	48 89 d6             	mov    %rdx,%rsi
  80042076d0:	89 df                	mov    %ebx,%edi
  80042076d2:	ff d0                	callq  *%rax
			if ((p = va_arg(aq, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042076d4:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  80042076d8:	4c 89 e0             	mov    %r12,%rax
  80042076db:	4c 8d 60 01          	lea    0x1(%rax),%r12
  80042076df:	0f b6 00             	movzbl (%rax),%eax
  80042076e2:	0f be d8             	movsbl %al,%ebx
  80042076e5:	85 db                	test   %ebx,%ebx
  80042076e7:	74 10                	je     80042076f9 <vprintfmt+0x356>
  80042076e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  80042076ed:	78 b2                	js     80042076a1 <vprintfmt+0x2fe>
  80042076ef:	83 6d d8 01          	subl   $0x1,-0x28(%rbp)
  80042076f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%rbp)
  80042076f7:	79 a8                	jns    80042076a1 <vprintfmt+0x2fe>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80042076f9:	eb 16                	jmp    8004207711 <vprintfmt+0x36e>
				putch(' ', putdat);
  80042076fb:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042076ff:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207703:	48 89 d6             	mov    %rdx,%rsi
  8004207706:	bf 20 00 00 00       	mov    $0x20,%edi
  800420770b:	ff d0                	callq  *%rax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800420770d:	83 6d dc 01          	subl   $0x1,-0x24(%rbp)
  8004207711:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  8004207715:	7f e4                	jg     80042076fb <vprintfmt+0x358>
				putch(' ', putdat);
			break;
  8004207717:	e9 a3 01 00 00       	jmpq   80042078bf <vprintfmt+0x51c>

			// (signed) decimal
		case 'd':
			num = getint(&aq, 3);
  800420771c:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8004207720:	be 03 00 00 00       	mov    $0x3,%esi
  8004207725:	48 89 c7             	mov    %rax,%rdi
  8004207728:	48 b8 93 72 20 04 80 	movabs $0x8004207293,%rax
  800420772f:	00 00 00 
  8004207732:	ff d0                	callq  *%rax
  8004207734:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			if ((long long) num < 0) {
  8004207738:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420773c:	48 85 c0             	test   %rax,%rax
  800420773f:	79 1d                	jns    800420775e <vprintfmt+0x3bb>
				putch('-', putdat);
  8004207741:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004207745:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207749:	48 89 d6             	mov    %rdx,%rsi
  800420774c:	bf 2d 00 00 00       	mov    $0x2d,%edi
  8004207751:	ff d0                	callq  *%rax
				num = -(long long) num;
  8004207753:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207757:	48 f7 d8             	neg    %rax
  800420775a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			}
			base = 10;
  800420775e:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  8004207765:	e9 e8 00 00 00       	jmpq   8004207852 <vprintfmt+0x4af>

			// unsigned decimal
		case 'u':
			num = getuint(&aq, 3);
  800420776a:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  800420776e:	be 03 00 00 00       	mov    $0x3,%esi
  8004207773:	48 89 c7             	mov    %rax,%rdi
  8004207776:	48 b8 83 71 20 04 80 	movabs $0x8004207183,%rax
  800420777d:	00 00 00 
  8004207780:	ff d0                	callq  *%rax
  8004207782:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 10;
  8004207786:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%rbp)
			goto number;
  800420778d:	e9 c0 00 00 00       	jmpq   8004207852 <vprintfmt+0x4af>

			// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8004207792:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004207796:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420779a:	48 89 d6             	mov    %rdx,%rsi
  800420779d:	bf 58 00 00 00       	mov    $0x58,%edi
  80042077a2:	ff d0                	callq  *%rax
			putch('X', putdat);
  80042077a4:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042077a8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042077ac:	48 89 d6             	mov    %rdx,%rsi
  80042077af:	bf 58 00 00 00       	mov    $0x58,%edi
  80042077b4:	ff d0                	callq  *%rax
			putch('X', putdat);
  80042077b6:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042077ba:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042077be:	48 89 d6             	mov    %rdx,%rsi
  80042077c1:	bf 58 00 00 00       	mov    $0x58,%edi
  80042077c6:	ff d0                	callq  *%rax
			break;
  80042077c8:	e9 f2 00 00 00       	jmpq   80042078bf <vprintfmt+0x51c>

			// pointer
		case 'p':
			putch('0', putdat);
  80042077cd:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042077d1:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042077d5:	48 89 d6             	mov    %rdx,%rsi
  80042077d8:	bf 30 00 00 00       	mov    $0x30,%edi
  80042077dd:	ff d0                	callq  *%rax
			putch('x', putdat);
  80042077df:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  80042077e3:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042077e7:	48 89 d6             	mov    %rdx,%rsi
  80042077ea:	bf 78 00 00 00       	mov    $0x78,%edi
  80042077ef:	ff d0                	callq  *%rax
			num = (unsigned long long)
				(uintptr_t) va_arg(aq, void *);
  80042077f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80042077f4:	83 f8 30             	cmp    $0x30,%eax
  80042077f7:	73 17                	jae    8004207810 <vprintfmt+0x46d>
  80042077f9:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042077fd:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004207800:	89 c0                	mov    %eax,%eax
  8004207802:	48 01 d0             	add    %rdx,%rax
  8004207805:	8b 55 b8             	mov    -0x48(%rbp),%edx
  8004207808:	83 c2 08             	add    $0x8,%edx
  800420780b:	89 55 b8             	mov    %edx,-0x48(%rbp)

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800420780e:	eb 0f                	jmp    800420781f <vprintfmt+0x47c>
				(uintptr_t) va_arg(aq, void *);
  8004207810:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004207814:	48 89 d0             	mov    %rdx,%rax
  8004207817:	48 83 c2 08          	add    $0x8,%rdx
  800420781b:	48 89 55 c0          	mov    %rdx,-0x40(%rbp)
  800420781f:	48 8b 00             	mov    (%rax),%rax

			// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8004207822:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				(uintptr_t) va_arg(aq, void *);
			base = 16;
  8004207826:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
			goto number;
  800420782d:	eb 23                	jmp    8004207852 <vprintfmt+0x4af>

			// (unsigned) hexadecimal
		case 'x':
			num = getuint(&aq, 3);
  800420782f:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
  8004207833:	be 03 00 00 00       	mov    $0x3,%esi
  8004207838:	48 89 c7             	mov    %rax,%rdi
  800420783b:	48 b8 83 71 20 04 80 	movabs $0x8004207183,%rax
  8004207842:	00 00 00 
  8004207845:	ff d0                	callq  *%rax
  8004207847:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
			base = 16;
  800420784b:	c7 45 e4 10 00 00 00 	movl   $0x10,-0x1c(%rbp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8004207852:	44 0f be 45 d3       	movsbl -0x2d(%rbp),%r8d
  8004207857:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
  800420785a:	8b 7d dc             	mov    -0x24(%rbp),%edi
  800420785d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207861:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  8004207865:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207869:	45 89 c1             	mov    %r8d,%r9d
  800420786c:	41 89 f8             	mov    %edi,%r8d
  800420786f:	48 89 c7             	mov    %rax,%rdi
  8004207872:	48 b8 c8 70 20 04 80 	movabs $0x80042070c8,%rax
  8004207879:	00 00 00 
  800420787c:	ff d0                	callq  *%rax
			break;
  800420787e:	eb 3f                	jmp    80042078bf <vprintfmt+0x51c>

			// escaped '%' character
		case '%':
			putch(ch, putdat);
  8004207880:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004207884:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207888:	48 89 d6             	mov    %rdx,%rsi
  800420788b:	89 df                	mov    %ebx,%edi
  800420788d:	ff d0                	callq  *%rax
			break;
  800420788f:	eb 2e                	jmp    80042078bf <vprintfmt+0x51c>

			// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8004207891:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004207895:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004207899:	48 89 d6             	mov    %rdx,%rsi
  800420789c:	bf 25 00 00 00       	mov    $0x25,%edi
  80042078a1:	ff d0                	callq  *%rax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80042078a3:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  80042078a8:	eb 05                	jmp    80042078af <vprintfmt+0x50c>
  80042078aa:	48 83 6d 98 01       	subq   $0x1,-0x68(%rbp)
  80042078af:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042078b3:	48 83 e8 01          	sub    $0x1,%rax
  80042078b7:	0f b6 00             	movzbl (%rax),%eax
  80042078ba:	3c 25                	cmp    $0x25,%al
  80042078bc:	75 ec                	jne    80042078aa <vprintfmt+0x507>
				/* do nothing */;
			break;
  80042078be:	90                   	nop
		}
	}
  80042078bf:	90                   	nop
	int base, lflag, width, precision, altflag;
	char padc;
	va_list aq;
	va_copy(aq,ap);
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042078c0:	e9 30 fb ff ff       	jmpq   80042073f5 <vprintfmt+0x52>
				/* do nothing */;
			break;
		}
	}
	va_end(aq);
}
  80042078c5:	48 83 c4 60          	add    $0x60,%rsp
  80042078c9:	5b                   	pop    %rbx
  80042078ca:	41 5c                	pop    %r12
  80042078cc:	5d                   	pop    %rbp
  80042078cd:	c3                   	retq   

00000080042078ce <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042078ce:	55                   	push   %rbp
  80042078cf:	48 89 e5             	mov    %rsp,%rbp
  80042078d2:	48 81 ec f0 00 00 00 	sub    $0xf0,%rsp
  80042078d9:	48 89 bd 28 ff ff ff 	mov    %rdi,-0xd8(%rbp)
  80042078e0:	48 89 b5 20 ff ff ff 	mov    %rsi,-0xe0(%rbp)
  80042078e7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  80042078ee:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  80042078f5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  80042078fc:	84 c0                	test   %al,%al
  80042078fe:	74 20                	je     8004207920 <printfmt+0x52>
  8004207900:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004207904:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004207908:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800420790c:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004207910:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004207914:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004207918:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800420791c:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004207920:	48 89 95 18 ff ff ff 	mov    %rdx,-0xe8(%rbp)
	va_list ap;

	va_start(ap, fmt);
  8004207927:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800420792e:	00 00 00 
  8004207931:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  8004207938:	00 00 00 
  800420793b:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800420793f:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  8004207946:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800420794d:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
	vprintfmt(putch, putdat, fmt, ap);
  8004207954:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800420795b:	48 8b 95 18 ff ff ff 	mov    -0xe8(%rbp),%rdx
  8004207962:	48 8b b5 20 ff ff ff 	mov    -0xe0(%rbp),%rsi
  8004207969:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  8004207970:	48 89 c7             	mov    %rax,%rdi
  8004207973:	48 b8 a3 73 20 04 80 	movabs $0x80042073a3,%rax
  800420797a:	00 00 00 
  800420797d:	ff d0                	callq  *%rax
	va_end(ap);
}
  800420797f:	c9                   	leaveq 
  8004207980:	c3                   	retq   

0000008004207981 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004207981:	55                   	push   %rbp
  8004207982:	48 89 e5             	mov    %rsp,%rbp
  8004207985:	48 83 ec 10          	sub    $0x10,%rsp
  8004207989:	89 7d fc             	mov    %edi,-0x4(%rbp)
  800420798c:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	b->cnt++;
  8004207990:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004207994:	8b 40 10             	mov    0x10(%rax),%eax
  8004207997:	8d 50 01             	lea    0x1(%rax),%edx
  800420799a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420799e:	89 50 10             	mov    %edx,0x10(%rax)
	if (b->buf < b->ebuf)
  80042079a1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042079a5:	48 8b 10             	mov    (%rax),%rdx
  80042079a8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042079ac:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042079b0:	48 39 c2             	cmp    %rax,%rdx
  80042079b3:	73 17                	jae    80042079cc <sprintputch+0x4b>
		*b->buf++ = ch;
  80042079b5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042079b9:	48 8b 00             	mov    (%rax),%rax
  80042079bc:	48 8d 48 01          	lea    0x1(%rax),%rcx
  80042079c0:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80042079c4:	48 89 0a             	mov    %rcx,(%rdx)
  80042079c7:	8b 55 fc             	mov    -0x4(%rbp),%edx
  80042079ca:	88 10                	mov    %dl,(%rax)
}
  80042079cc:	c9                   	leaveq 
  80042079cd:	c3                   	retq   

00000080042079ce <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80042079ce:	55                   	push   %rbp
  80042079cf:	48 89 e5             	mov    %rsp,%rbp
  80042079d2:	48 83 ec 50          	sub    $0x50,%rsp
  80042079d6:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  80042079da:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  80042079dd:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  80042079e1:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
	va_list aq;
	va_copy(aq,ap);
  80042079e5:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  80042079e9:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  80042079ed:	48 8b 0a             	mov    (%rdx),%rcx
  80042079f0:	48 89 08             	mov    %rcx,(%rax)
  80042079f3:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  80042079f7:	48 89 48 08          	mov    %rcx,0x8(%rax)
  80042079fb:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  80042079ff:	48 89 50 10          	mov    %rdx,0x10(%rax)
	struct sprintbuf b = {buf, buf+n-1, 0};
  8004207a03:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207a07:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  8004207a0b:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  8004207a0e:	48 98                	cltq   
  8004207a10:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  8004207a14:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004207a18:	48 01 d0             	add    %rdx,%rax
  8004207a1b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  8004207a1f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)

	if (buf == NULL || n < 1)
  8004207a26:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004207a2b:	74 06                	je     8004207a33 <vsnprintf+0x65>
  8004207a2d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  8004207a31:	7f 07                	jg     8004207a3a <vsnprintf+0x6c>
		return -E_INVAL;
  8004207a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004207a38:	eb 2f                	jmp    8004207a69 <vsnprintf+0x9b>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, aq);
  8004207a3a:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  8004207a3e:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004207a42:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  8004207a46:	48 89 c6             	mov    %rax,%rsi
  8004207a49:	48 bf 81 79 20 04 80 	movabs $0x8004207981,%rdi
  8004207a50:	00 00 00 
  8004207a53:	48 b8 a3 73 20 04 80 	movabs $0x80042073a3,%rax
  8004207a5a:	00 00 00 
  8004207a5d:	ff d0                	callq  *%rax
	va_end(aq);
	// null terminate the buffer
	*b.buf = '\0';
  8004207a5f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004207a63:	c6 00 00             	movb   $0x0,(%rax)

	return b.cnt;
  8004207a66:	8b 45 e0             	mov    -0x20(%rbp),%eax
}
  8004207a69:	c9                   	leaveq 
  8004207a6a:	c3                   	retq   

0000008004207a6b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8004207a6b:	55                   	push   %rbp
  8004207a6c:	48 89 e5             	mov    %rsp,%rbp
  8004207a6f:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  8004207a76:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
  8004207a7d:	89 b5 04 ff ff ff    	mov    %esi,-0xfc(%rbp)
  8004207a83:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8004207a8a:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8004207a91:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8004207a98:	84 c0                	test   %al,%al
  8004207a9a:	74 20                	je     8004207abc <snprintf+0x51>
  8004207a9c:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  8004207aa0:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  8004207aa4:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  8004207aa8:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  8004207aac:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  8004207ab0:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  8004207ab4:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  8004207ab8:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  8004207abc:	48 89 95 f8 fe ff ff 	mov    %rdx,-0x108(%rbp)
	va_list ap;
	int rc;
	va_list aq;
	va_start(ap, fmt);
  8004207ac3:	c7 85 30 ff ff ff 18 	movl   $0x18,-0xd0(%rbp)
  8004207aca:	00 00 00 
  8004207acd:	c7 85 34 ff ff ff 30 	movl   $0x30,-0xcc(%rbp)
  8004207ad4:	00 00 00 
  8004207ad7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  8004207adb:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  8004207ae2:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  8004207ae9:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
	va_copy(aq,ap);
  8004207af0:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
  8004207af7:	48 8d 95 30 ff ff ff 	lea    -0xd0(%rbp),%rdx
  8004207afe:	48 8b 0a             	mov    (%rdx),%rcx
  8004207b01:	48 89 08             	mov    %rcx,(%rax)
  8004207b04:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  8004207b08:	48 89 48 08          	mov    %rcx,0x8(%rax)
  8004207b0c:	48 8b 52 10          	mov    0x10(%rdx),%rdx
  8004207b10:	48 89 50 10          	mov    %rdx,0x10(%rax)
	rc = vsnprintf(buf, n, fmt, aq);
  8004207b14:	48 8d 8d 18 ff ff ff 	lea    -0xe8(%rbp),%rcx
  8004207b1b:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  8004207b22:	8b b5 04 ff ff ff    	mov    -0xfc(%rbp),%esi
  8004207b28:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  8004207b2f:	48 89 c7             	mov    %rax,%rdi
  8004207b32:	48 b8 ce 79 20 04 80 	movabs $0x80042079ce,%rax
  8004207b39:	00 00 00 
  8004207b3c:	ff d0                	callq  *%rax
  8004207b3e:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%rbp)
	va_end(aq);

	return rc;
  8004207b44:	8b 85 4c ff ff ff    	mov    -0xb4(%rbp),%eax
}
  8004207b4a:	c9                   	leaveq 
  8004207b4b:	c3                   	retq   

0000008004207b4c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8004207b4c:	55                   	push   %rbp
  8004207b4d:	48 89 e5             	mov    %rsp,%rbp
  8004207b50:	48 83 ec 20          	sub    $0x20,%rsp
  8004207b54:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int i, c, echoing;

	if (prompt != NULL)
  8004207b58:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004207b5d:	74 22                	je     8004207b81 <readline+0x35>
		cprintf("%s", prompt);
  8004207b5f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207b63:	48 89 c6             	mov    %rax,%rsi
  8004207b66:	48 bf 28 fb 20 04 80 	movabs $0x800420fb28,%rdi
  8004207b6d:	00 00 00 
  8004207b70:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207b75:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004207b7c:	00 00 00 
  8004207b7f:	ff d2                	callq  *%rdx

	i = 0;
  8004207b81:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	echoing = iscons(0);
  8004207b88:	bf 00 00 00 00       	mov    $0x0,%edi
  8004207b8d:	48 b8 0f 0e 20 04 80 	movabs $0x8004200e0f,%rax
  8004207b94:	00 00 00 
  8004207b97:	ff d0                	callq  *%rax
  8004207b99:	89 45 f8             	mov    %eax,-0x8(%rbp)
	while (1) {
		c = getchar();
  8004207b9c:	48 b8 ed 0d 20 04 80 	movabs $0x8004200ded,%rax
  8004207ba3:	00 00 00 
  8004207ba6:	ff d0                	callq  *%rax
  8004207ba8:	89 45 f4             	mov    %eax,-0xc(%rbp)
		if (c < 0) {
  8004207bab:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8004207baf:	79 2a                	jns    8004207bdb <readline+0x8f>
			cprintf("read error: %e\n", c);
  8004207bb1:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004207bb4:	89 c6                	mov    %eax,%esi
  8004207bb6:	48 bf 2b fb 20 04 80 	movabs $0x800420fb2b,%rdi
  8004207bbd:	00 00 00 
  8004207bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207bc5:	48 ba 50 64 20 04 80 	movabs $0x8004206450,%rdx
  8004207bcc:	00 00 00 
  8004207bcf:	ff d2                	callq  *%rdx
			return NULL;
  8004207bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207bd6:	e9 be 00 00 00       	jmpq   8004207c99 <readline+0x14d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8004207bdb:	83 7d f4 08          	cmpl   $0x8,-0xc(%rbp)
  8004207bdf:	74 06                	je     8004207be7 <readline+0x9b>
  8004207be1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%rbp)
  8004207be5:	75 26                	jne    8004207c0d <readline+0xc1>
  8004207be7:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004207beb:	7e 20                	jle    8004207c0d <readline+0xc1>
			if (echoing)
  8004207bed:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004207bf1:	74 11                	je     8004207c04 <readline+0xb8>
				cputchar('\b');
  8004207bf3:	bf 08 00 00 00       	mov    $0x8,%edi
  8004207bf8:	48 b8 cf 0d 20 04 80 	movabs $0x8004200dcf,%rax
  8004207bff:	00 00 00 
  8004207c02:	ff d0                	callq  *%rax
			i--;
  8004207c04:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
  8004207c08:	e9 87 00 00 00       	jmpq   8004207c94 <readline+0x148>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8004207c0d:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004207c11:	7e 3f                	jle    8004207c52 <readline+0x106>
  8004207c13:	81 7d fc fe 03 00 00 	cmpl   $0x3fe,-0x4(%rbp)
  8004207c1a:	7f 36                	jg     8004207c52 <readline+0x106>
			if (echoing)
  8004207c1c:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004207c20:	74 11                	je     8004207c33 <readline+0xe7>
				cputchar(c);
  8004207c22:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004207c25:	89 c7                	mov    %eax,%edi
  8004207c27:	48 b8 cf 0d 20 04 80 	movabs $0x8004200dcf,%rax
  8004207c2e:	00 00 00 
  8004207c31:	ff d0                	callq  *%rax
			buf[i++] = c;
  8004207c33:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004207c36:	8d 50 01             	lea    0x1(%rax),%edx
  8004207c39:	89 55 fc             	mov    %edx,-0x4(%rbp)
  8004207c3c:	8b 55 f4             	mov    -0xc(%rbp),%edx
  8004207c3f:	89 d1                	mov    %edx,%ecx
  8004207c41:	48 ba 00 29 22 04 80 	movabs $0x8004222900,%rdx
  8004207c48:	00 00 00 
  8004207c4b:	48 98                	cltq   
  8004207c4d:	88 0c 02             	mov    %cl,(%rdx,%rax,1)
  8004207c50:	eb 42                	jmp    8004207c94 <readline+0x148>
		} else if (c == '\n' || c == '\r') {
  8004207c52:	83 7d f4 0a          	cmpl   $0xa,-0xc(%rbp)
  8004207c56:	74 06                	je     8004207c5e <readline+0x112>
  8004207c58:	83 7d f4 0d          	cmpl   $0xd,-0xc(%rbp)
  8004207c5c:	75 36                	jne    8004207c94 <readline+0x148>
			if (echoing)
  8004207c5e:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  8004207c62:	74 11                	je     8004207c75 <readline+0x129>
				cputchar('\n');
  8004207c64:	bf 0a 00 00 00       	mov    $0xa,%edi
  8004207c69:	48 b8 cf 0d 20 04 80 	movabs $0x8004200dcf,%rax
  8004207c70:	00 00 00 
  8004207c73:	ff d0                	callq  *%rax
			buf[i] = 0;
  8004207c75:	48 ba 00 29 22 04 80 	movabs $0x8004222900,%rdx
  8004207c7c:	00 00 00 
  8004207c7f:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004207c82:	48 98                	cltq   
  8004207c84:	c6 04 02 00          	movb   $0x0,(%rdx,%rax,1)
			return buf;
  8004207c88:	48 b8 00 29 22 04 80 	movabs $0x8004222900,%rax
  8004207c8f:	00 00 00 
  8004207c92:	eb 05                	jmp    8004207c99 <readline+0x14d>
		}
	}
  8004207c94:	e9 03 ff ff ff       	jmpq   8004207b9c <readline+0x50>
}
  8004207c99:	c9                   	leaveq 
  8004207c9a:	c3                   	retq   

0000008004207c9b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8004207c9b:	55                   	push   %rbp
  8004207c9c:	48 89 e5             	mov    %rsp,%rbp
  8004207c9f:	48 83 ec 18          	sub    $0x18,%rsp
  8004207ca3:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	int n;

	for (n = 0; *s != '\0'; s++)
  8004207ca7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004207cae:	eb 09                	jmp    8004207cb9 <strlen+0x1e>
		n++;
  8004207cb0:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8004207cb4:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004207cb9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207cbd:	0f b6 00             	movzbl (%rax),%eax
  8004207cc0:	84 c0                	test   %al,%al
  8004207cc2:	75 ec                	jne    8004207cb0 <strlen+0x15>
		n++;
	return n;
  8004207cc4:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004207cc7:	c9                   	leaveq 
  8004207cc8:	c3                   	retq   

0000008004207cc9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8004207cc9:	55                   	push   %rbp
  8004207cca:	48 89 e5             	mov    %rsp,%rbp
  8004207ccd:	48 83 ec 20          	sub    $0x20,%rsp
  8004207cd1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207cd5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8004207cd9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  8004207ce0:	eb 0e                	jmp    8004207cf0 <strnlen+0x27>
		n++;
  8004207ce2:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8004207ce6:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004207ceb:	48 83 6d e0 01       	subq   $0x1,-0x20(%rbp)
  8004207cf0:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  8004207cf5:	74 0b                	je     8004207d02 <strnlen+0x39>
  8004207cf7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207cfb:	0f b6 00             	movzbl (%rax),%eax
  8004207cfe:	84 c0                	test   %al,%al
  8004207d00:	75 e0                	jne    8004207ce2 <strnlen+0x19>
		n++;
	return n;
  8004207d02:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004207d05:	c9                   	leaveq 
  8004207d06:	c3                   	retq   

0000008004207d07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8004207d07:	55                   	push   %rbp
  8004207d08:	48 89 e5             	mov    %rsp,%rbp
  8004207d0b:	48 83 ec 20          	sub    $0x20,%rsp
  8004207d0f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207d13:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	char *ret;

	ret = dst;
  8004207d17:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207d1b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	while ((*dst++ = *src++) != '\0')
  8004207d1f:	90                   	nop
  8004207d20:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207d24:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207d28:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004207d2c:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207d30:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8004207d34:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004207d38:	0f b6 12             	movzbl (%rdx),%edx
  8004207d3b:	88 10                	mov    %dl,(%rax)
  8004207d3d:	0f b6 00             	movzbl (%rax),%eax
  8004207d40:	84 c0                	test   %al,%al
  8004207d42:	75 dc                	jne    8004207d20 <strcpy+0x19>
		/* do nothing */;
	return ret;
  8004207d44:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004207d48:	c9                   	leaveq 
  8004207d49:	c3                   	retq   

0000008004207d4a <strcat>:

char *
strcat(char *dst, const char *src)
{
  8004207d4a:	55                   	push   %rbp
  8004207d4b:	48 89 e5             	mov    %rsp,%rbp
  8004207d4e:	48 83 ec 20          	sub    $0x20,%rsp
  8004207d52:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207d56:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	int len = strlen(dst);
  8004207d5a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207d5e:	48 89 c7             	mov    %rax,%rdi
  8004207d61:	48 b8 9b 7c 20 04 80 	movabs $0x8004207c9b,%rax
  8004207d68:	00 00 00 
  8004207d6b:	ff d0                	callq  *%rax
  8004207d6d:	89 45 fc             	mov    %eax,-0x4(%rbp)
	strcpy(dst + len, src);
  8004207d70:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004207d73:	48 63 d0             	movslq %eax,%rdx
  8004207d76:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207d7a:	48 01 c2             	add    %rax,%rdx
  8004207d7d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004207d81:	48 89 c6             	mov    %rax,%rsi
  8004207d84:	48 89 d7             	mov    %rdx,%rdi
  8004207d87:	48 b8 07 7d 20 04 80 	movabs $0x8004207d07,%rax
  8004207d8e:	00 00 00 
  8004207d91:	ff d0                	callq  *%rax
	return dst;
  8004207d93:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004207d97:	c9                   	leaveq 
  8004207d98:	c3                   	retq   

0000008004207d99 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8004207d99:	55                   	push   %rbp
  8004207d9a:	48 89 e5             	mov    %rsp,%rbp
  8004207d9d:	48 83 ec 28          	sub    $0x28,%rsp
  8004207da1:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207da5:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004207da9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	size_t i;
	char *ret;

	ret = dst;
  8004207dad:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207db1:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	for (i = 0; i < size; i++) {
  8004207db5:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004207dbc:	00 
  8004207dbd:	eb 2a                	jmp    8004207de9 <strncpy+0x50>
		*dst++ = *src;
  8004207dbf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207dc3:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207dc7:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004207dcb:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207dcf:	0f b6 12             	movzbl (%rdx),%edx
  8004207dd2:	88 10                	mov    %dl,(%rax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8004207dd4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004207dd8:	0f b6 00             	movzbl (%rax),%eax
  8004207ddb:	84 c0                	test   %al,%al
  8004207ddd:	74 05                	je     8004207de4 <strncpy+0x4b>
			src++;
  8004207ddf:	48 83 45 e0 01       	addq   $0x1,-0x20(%rbp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8004207de4:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004207de9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207ded:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  8004207df1:	72 cc                	jb     8004207dbf <strncpy+0x26>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8004207df3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004207df7:	c9                   	leaveq 
  8004207df8:	c3                   	retq   

0000008004207df9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8004207df9:	55                   	push   %rbp
  8004207dfa:	48 89 e5             	mov    %rsp,%rbp
  8004207dfd:	48 83 ec 28          	sub    $0x28,%rsp
  8004207e01:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004207e05:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004207e09:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	char *dst_in;

	dst_in = dst;
  8004207e0d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207e11:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (size > 0) {
  8004207e15:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004207e1a:	74 3d                	je     8004207e59 <strlcpy+0x60>
		while (--size > 0 && *src != '\0')
  8004207e1c:	eb 1d                	jmp    8004207e3b <strlcpy+0x42>
			*dst++ = *src++;
  8004207e1e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207e22:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004207e26:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004207e2a:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004207e2e:	48 8d 4a 01          	lea    0x1(%rdx),%rcx
  8004207e32:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
  8004207e36:	0f b6 12             	movzbl (%rdx),%edx
  8004207e39:	88 10                	mov    %dl,(%rax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8004207e3b:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  8004207e40:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004207e45:	74 0b                	je     8004207e52 <strlcpy+0x59>
  8004207e47:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004207e4b:	0f b6 00             	movzbl (%rax),%eax
  8004207e4e:	84 c0                	test   %al,%al
  8004207e50:	75 cc                	jne    8004207e1e <strlcpy+0x25>
			*dst++ = *src++;
		*dst = '\0';
  8004207e52:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207e56:	c6 00 00             	movb   $0x0,(%rax)
	}
	return dst - dst_in;
  8004207e59:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004207e5d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207e61:	48 29 c2             	sub    %rax,%rdx
  8004207e64:	48 89 d0             	mov    %rdx,%rax
}
  8004207e67:	c9                   	leaveq 
  8004207e68:	c3                   	retq   

0000008004207e69 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8004207e69:	55                   	push   %rbp
  8004207e6a:	48 89 e5             	mov    %rsp,%rbp
  8004207e6d:	48 83 ec 10          	sub    $0x10,%rsp
  8004207e71:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004207e75:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	while (*p && *p == *q)
  8004207e79:	eb 0a                	jmp    8004207e85 <strcmp+0x1c>
		p++, q++;
  8004207e7b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004207e80:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8004207e85:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207e89:	0f b6 00             	movzbl (%rax),%eax
  8004207e8c:	84 c0                	test   %al,%al
  8004207e8e:	74 12                	je     8004207ea2 <strcmp+0x39>
  8004207e90:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207e94:	0f b6 10             	movzbl (%rax),%edx
  8004207e97:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004207e9b:	0f b6 00             	movzbl (%rax),%eax
  8004207e9e:	38 c2                	cmp    %al,%dl
  8004207ea0:	74 d9                	je     8004207e7b <strcmp+0x12>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8004207ea2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207ea6:	0f b6 00             	movzbl (%rax),%eax
  8004207ea9:	0f b6 d0             	movzbl %al,%edx
  8004207eac:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004207eb0:	0f b6 00             	movzbl (%rax),%eax
  8004207eb3:	0f b6 c0             	movzbl %al,%eax
  8004207eb6:	29 c2                	sub    %eax,%edx
  8004207eb8:	89 d0                	mov    %edx,%eax
}
  8004207eba:	c9                   	leaveq 
  8004207ebb:	c3                   	retq   

0000008004207ebc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8004207ebc:	55                   	push   %rbp
  8004207ebd:	48 89 e5             	mov    %rsp,%rbp
  8004207ec0:	48 83 ec 18          	sub    $0x18,%rsp
  8004207ec4:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004207ec8:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8004207ecc:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	while (n > 0 && *p && *p == *q)
  8004207ed0:	eb 0f                	jmp    8004207ee1 <strncmp+0x25>
		n--, p++, q++;
  8004207ed2:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  8004207ed7:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004207edc:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8004207ee1:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004207ee6:	74 1d                	je     8004207f05 <strncmp+0x49>
  8004207ee8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207eec:	0f b6 00             	movzbl (%rax),%eax
  8004207eef:	84 c0                	test   %al,%al
  8004207ef1:	74 12                	je     8004207f05 <strncmp+0x49>
  8004207ef3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207ef7:	0f b6 10             	movzbl (%rax),%edx
  8004207efa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004207efe:	0f b6 00             	movzbl (%rax),%eax
  8004207f01:	38 c2                	cmp    %al,%dl
  8004207f03:	74 cd                	je     8004207ed2 <strncmp+0x16>
		n--, p++, q++;
	if (n == 0)
  8004207f05:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004207f0a:	75 07                	jne    8004207f13 <strncmp+0x57>
		return 0;
  8004207f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004207f11:	eb 18                	jmp    8004207f2b <strncmp+0x6f>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8004207f13:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f17:	0f b6 00             	movzbl (%rax),%eax
  8004207f1a:	0f b6 d0             	movzbl %al,%edx
  8004207f1d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004207f21:	0f b6 00             	movzbl (%rax),%eax
  8004207f24:	0f b6 c0             	movzbl %al,%eax
  8004207f27:	29 c2                	sub    %eax,%edx
  8004207f29:	89 d0                	mov    %edx,%eax
}
  8004207f2b:	c9                   	leaveq 
  8004207f2c:	c3                   	retq   

0000008004207f2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8004207f2d:	55                   	push   %rbp
  8004207f2e:	48 89 e5             	mov    %rsp,%rbp
  8004207f31:	48 83 ec 0c          	sub    $0xc,%rsp
  8004207f35:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004207f39:	89 f0                	mov    %esi,%eax
  8004207f3b:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  8004207f3e:	eb 17                	jmp    8004207f57 <strchr+0x2a>
		if (*s == c)
  8004207f40:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f44:	0f b6 00             	movzbl (%rax),%eax
  8004207f47:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8004207f4a:	75 06                	jne    8004207f52 <strchr+0x25>
			return (char *) s;
  8004207f4c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f50:	eb 15                	jmp    8004207f67 <strchr+0x3a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8004207f52:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004207f57:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f5b:	0f b6 00             	movzbl (%rax),%eax
  8004207f5e:	84 c0                	test   %al,%al
  8004207f60:	75 de                	jne    8004207f40 <strchr+0x13>
		if (*s == c)
			return (char *) s;
	return 0;
  8004207f62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004207f67:	c9                   	leaveq 
  8004207f68:	c3                   	retq   

0000008004207f69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8004207f69:	55                   	push   %rbp
  8004207f6a:	48 89 e5             	mov    %rsp,%rbp
  8004207f6d:	48 83 ec 0c          	sub    $0xc,%rsp
  8004207f71:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004207f75:	89 f0                	mov    %esi,%eax
  8004207f77:	88 45 f4             	mov    %al,-0xc(%rbp)
	for (; *s; s++)
  8004207f7a:	eb 13                	jmp    8004207f8f <strfind+0x26>
		if (*s == c)
  8004207f7c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f80:	0f b6 00             	movzbl (%rax),%eax
  8004207f83:	3a 45 f4             	cmp    -0xc(%rbp),%al
  8004207f86:	75 02                	jne    8004207f8a <strfind+0x21>
			break;
  8004207f88:	eb 10                	jmp    8004207f9a <strfind+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8004207f8a:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  8004207f8f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207f93:	0f b6 00             	movzbl (%rax),%eax
  8004207f96:	84 c0                	test   %al,%al
  8004207f98:	75 e2                	jne    8004207f7c <strfind+0x13>
		if (*s == c)
			break;
	return (char *) s;
  8004207f9a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004207f9e:	c9                   	leaveq 
  8004207f9f:	c3                   	retq   

0000008004207fa0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8004207fa0:	55                   	push   %rbp
  8004207fa1:	48 89 e5             	mov    %rsp,%rbp
  8004207fa4:	48 83 ec 18          	sub    $0x18,%rsp
  8004207fa8:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  8004207fac:	89 75 f4             	mov    %esi,-0xc(%rbp)
  8004207faf:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	char *p;

	if (n == 0)
  8004207fb3:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004207fb8:	75 06                	jne    8004207fc0 <memset+0x20>
		return v;
  8004207fba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207fbe:	eb 69                	jmp    8004208029 <memset+0x89>
	if ((int64_t)v%4 == 0 && n%4 == 0) {
  8004207fc0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004207fc4:	83 e0 03             	and    $0x3,%eax
  8004207fc7:	48 85 c0             	test   %rax,%rax
  8004207fca:	75 48                	jne    8004208014 <memset+0x74>
  8004207fcc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207fd0:	83 e0 03             	and    $0x3,%eax
  8004207fd3:	48 85 c0             	test   %rax,%rax
  8004207fd6:	75 3c                	jne    8004208014 <memset+0x74>
		c &= 0xFF;
  8004207fd8:	81 65 f4 ff 00 00 00 	andl   $0xff,-0xc(%rbp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8004207fdf:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004207fe2:	c1 e0 18             	shl    $0x18,%eax
  8004207fe5:	89 c2                	mov    %eax,%edx
  8004207fe7:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004207fea:	c1 e0 10             	shl    $0x10,%eax
  8004207fed:	09 c2                	or     %eax,%edx
  8004207fef:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004207ff2:	c1 e0 08             	shl    $0x8,%eax
  8004207ff5:	09 d0                	or     %edx,%eax
  8004207ff7:	09 45 f4             	or     %eax,-0xc(%rbp)
		asm volatile("cld; rep stosl\n"
			     :: "D" (v), "a" (c), "c" (n/4)
  8004207ffa:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004207ffe:	48 c1 e8 02          	shr    $0x2,%rax
  8004208002:	48 89 c1             	mov    %rax,%rcx
	if (n == 0)
		return v;
	if ((int64_t)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8004208005:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208009:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420800c:	48 89 d7             	mov    %rdx,%rdi
  800420800f:	fc                   	cld    
  8004208010:	f3 ab                	rep stos %eax,%es:(%rdi)
  8004208012:	eb 11                	jmp    8004208025 <memset+0x85>
			     :: "D" (v), "a" (c), "c" (n/4)
			     : "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8004208014:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208018:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420801b:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420801f:	48 89 d7             	mov    %rdx,%rdi
  8004208022:	fc                   	cld    
  8004208023:	f3 aa                	rep stos %al,%es:(%rdi)
			     :: "D" (v), "a" (c), "c" (n)
			     : "cc", "memory");
	return v;
  8004208025:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208029:	c9                   	leaveq 
  800420802a:	c3                   	retq   

000000800420802b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800420802b:	55                   	push   %rbp
  800420802c:	48 89 e5             	mov    %rsp,%rbp
  800420802f:	48 83 ec 28          	sub    $0x28,%rsp
  8004208033:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208037:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420803b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const char *s;
	char *d;

	s = src;
  800420803f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208043:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	d = dst;
  8004208047:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420804b:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	if (s < d && s + n > d) {
  800420804f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208053:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  8004208057:	0f 83 88 00 00 00    	jae    80042080e5 <memmove+0xba>
  800420805d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208061:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  8004208065:	48 01 d0             	add    %rdx,%rax
  8004208068:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  800420806c:	76 77                	jbe    80042080e5 <memmove+0xba>
		s += n;
  800420806e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208072:	48 01 45 f8          	add    %rax,-0x8(%rbp)
		d += n;
  8004208076:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420807a:	48 01 45 f0          	add    %rax,-0x10(%rbp)
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  800420807e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208082:	83 e0 03             	and    $0x3,%eax
  8004208085:	48 85 c0             	test   %rax,%rax
  8004208088:	75 3b                	jne    80042080c5 <memmove+0x9a>
  800420808a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420808e:	83 e0 03             	and    $0x3,%eax
  8004208091:	48 85 c0             	test   %rax,%rax
  8004208094:	75 2f                	jne    80042080c5 <memmove+0x9a>
  8004208096:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420809a:	83 e0 03             	and    $0x3,%eax
  800420809d:	48 85 c0             	test   %rax,%rax
  80042080a0:	75 23                	jne    80042080c5 <memmove+0x9a>
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80042080a2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042080a6:	48 83 e8 04          	sub    $0x4,%rax
  80042080aa:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042080ae:	48 83 ea 04          	sub    $0x4,%rdx
  80042080b2:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  80042080b6:	48 c1 e9 02          	shr    $0x2,%rcx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80042080ba:	48 89 c7             	mov    %rax,%rdi
  80042080bd:	48 89 d6             	mov    %rdx,%rsi
  80042080c0:	fd                   	std    
  80042080c1:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  80042080c3:	eb 1d                	jmp    80042080e2 <memmove+0xb7>
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80042080c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042080c9:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80042080cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042080d1:	48 8d 70 ff          	lea    -0x1(%rax),%rsi
		d += n;
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				     :: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80042080d5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042080d9:	48 89 d7             	mov    %rdx,%rdi
  80042080dc:	48 89 c1             	mov    %rax,%rcx
  80042080df:	fd                   	std    
  80042080e0:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80042080e2:	fc                   	cld    
  80042080e3:	eb 57                	jmp    800420813c <memmove+0x111>
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
  80042080e5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042080e9:	83 e0 03             	and    $0x3,%eax
  80042080ec:	48 85 c0             	test   %rax,%rax
  80042080ef:	75 36                	jne    8004208127 <memmove+0xfc>
  80042080f1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042080f5:	83 e0 03             	and    $0x3,%eax
  80042080f8:	48 85 c0             	test   %rax,%rax
  80042080fb:	75 2a                	jne    8004208127 <memmove+0xfc>
  80042080fd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208101:	83 e0 03             	and    $0x3,%eax
  8004208104:	48 85 c0             	test   %rax,%rax
  8004208107:	75 1e                	jne    8004208127 <memmove+0xfc>
			asm volatile("cld; rep movsl\n"
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8004208109:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420810d:	48 c1 e8 02          	shr    $0x2,%rax
  8004208111:	48 89 c1             	mov    %rax,%rcx
				     :: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int64_t)s%4 == 0 && (int64_t)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8004208114:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208118:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420811c:	48 89 c7             	mov    %rax,%rdi
  800420811f:	48 89 d6             	mov    %rdx,%rsi
  8004208122:	fc                   	cld    
  8004208123:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  8004208125:	eb 15                	jmp    800420813c <memmove+0x111>
				     :: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8004208127:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420812b:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420812f:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  8004208133:	48 89 c7             	mov    %rax,%rdi
  8004208136:	48 89 d6             	mov    %rdx,%rsi
  8004208139:	fc                   	cld    
  800420813a:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
				     :: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800420813c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004208140:	c9                   	leaveq 
  8004208141:	c3                   	retq   

0000008004208142 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8004208142:	55                   	push   %rbp
  8004208143:	48 89 e5             	mov    %rsp,%rbp
  8004208146:	48 83 ec 18          	sub    $0x18,%rsp
  800420814a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  800420814e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  8004208152:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
	return memmove(dst, src, n);
  8004208156:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420815a:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  800420815e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208162:	48 89 ce             	mov    %rcx,%rsi
  8004208165:	48 89 c7             	mov    %rax,%rdi
  8004208168:	48 b8 2b 80 20 04 80 	movabs $0x800420802b,%rax
  800420816f:	00 00 00 
  8004208172:	ff d0                	callq  *%rax
}
  8004208174:	c9                   	leaveq 
  8004208175:	c3                   	retq   

0000008004208176 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8004208176:	55                   	push   %rbp
  8004208177:	48 89 e5             	mov    %rsp,%rbp
  800420817a:	48 83 ec 28          	sub    $0x28,%rsp
  800420817e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208182:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004208186:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const uint8_t *s1 = (const uint8_t *) v1;
  800420818a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420818e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	const uint8_t *s2 = (const uint8_t *) v2;
  8004208192:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208196:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	while (n-- > 0) {
  800420819a:	eb 36                	jmp    80042081d2 <memcmp+0x5c>
		if (*s1 != *s2)
  800420819c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042081a0:	0f b6 10             	movzbl (%rax),%edx
  80042081a3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042081a7:	0f b6 00             	movzbl (%rax),%eax
  80042081aa:	38 c2                	cmp    %al,%dl
  80042081ac:	74 1a                	je     80042081c8 <memcmp+0x52>
			return (int) *s1 - (int) *s2;
  80042081ae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042081b2:	0f b6 00             	movzbl (%rax),%eax
  80042081b5:	0f b6 d0             	movzbl %al,%edx
  80042081b8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042081bc:	0f b6 00             	movzbl (%rax),%eax
  80042081bf:	0f b6 c0             	movzbl %al,%eax
  80042081c2:	29 c2                	sub    %eax,%edx
  80042081c4:	89 d0                	mov    %edx,%eax
  80042081c6:	eb 20                	jmp    80042081e8 <memcmp+0x72>
		s1++, s2++;
  80042081c8:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  80042081cd:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80042081d2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042081d6:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  80042081da:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  80042081de:	48 85 c0             	test   %rax,%rax
  80042081e1:	75 b9                	jne    800420819c <memcmp+0x26>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80042081e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042081e8:	c9                   	leaveq 
  80042081e9:	c3                   	retq   

00000080042081ea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80042081ea:	55                   	push   %rbp
  80042081eb:	48 89 e5             	mov    %rsp,%rbp
  80042081ee:	48 83 ec 28          	sub    $0x28,%rsp
  80042081f2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042081f6:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  80042081f9:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	const void *ends = (const char *) s + n;
  80042081fd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208201:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208205:	48 01 d0             	add    %rdx,%rax
  8004208208:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	for (; s < ends; s++)
  800420820c:	eb 15                	jmp    8004208223 <memfind+0x39>
		if (*(const unsigned char *) s == (unsigned char) c)
  800420820e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208212:	0f b6 10             	movzbl (%rax),%edx
  8004208215:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004208218:	38 c2                	cmp    %al,%dl
  800420821a:	75 02                	jne    800420821e <memfind+0x34>
			break;
  800420821c:	eb 0f                	jmp    800420822d <memfind+0x43>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800420821e:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  8004208223:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208227:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  800420822b:	72 e1                	jb     800420820e <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800420822d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  8004208231:	c9                   	leaveq 
  8004208232:	c3                   	retq   

0000008004208233 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8004208233:	55                   	push   %rbp
  8004208234:	48 89 e5             	mov    %rsp,%rbp
  8004208237:	48 83 ec 34          	sub    $0x34,%rsp
  800420823b:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  800420823f:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8004208243:	89 55 cc             	mov    %edx,-0x34(%rbp)
	int neg = 0;
  8004208246:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	long val = 0;
  800420824d:	48 c7 45 f0 00 00 00 	movq   $0x0,-0x10(%rbp)
  8004208254:	00 

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8004208255:	eb 05                	jmp    800420825c <strtol+0x29>
		s++;
  8004208257:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800420825c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208260:	0f b6 00             	movzbl (%rax),%eax
  8004208263:	3c 20                	cmp    $0x20,%al
  8004208265:	74 f0                	je     8004208257 <strtol+0x24>
  8004208267:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420826b:	0f b6 00             	movzbl (%rax),%eax
  800420826e:	3c 09                	cmp    $0x9,%al
  8004208270:	74 e5                	je     8004208257 <strtol+0x24>
		s++;

	// plus/minus sign
	if (*s == '+')
  8004208272:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208276:	0f b6 00             	movzbl (%rax),%eax
  8004208279:	3c 2b                	cmp    $0x2b,%al
  800420827b:	75 07                	jne    8004208284 <strtol+0x51>
		s++;
  800420827d:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8004208282:	eb 17                	jmp    800420829b <strtol+0x68>
	else if (*s == '-')
  8004208284:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208288:	0f b6 00             	movzbl (%rax),%eax
  800420828b:	3c 2d                	cmp    $0x2d,%al
  800420828d:	75 0c                	jne    800420829b <strtol+0x68>
		s++, neg = 1;
  800420828f:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8004208294:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800420829b:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  800420829f:	74 06                	je     80042082a7 <strtol+0x74>
  80042082a1:	83 7d cc 10          	cmpl   $0x10,-0x34(%rbp)
  80042082a5:	75 28                	jne    80042082cf <strtol+0x9c>
  80042082a7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042082ab:	0f b6 00             	movzbl (%rax),%eax
  80042082ae:	3c 30                	cmp    $0x30,%al
  80042082b0:	75 1d                	jne    80042082cf <strtol+0x9c>
  80042082b2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042082b6:	48 83 c0 01          	add    $0x1,%rax
  80042082ba:	0f b6 00             	movzbl (%rax),%eax
  80042082bd:	3c 78                	cmp    $0x78,%al
  80042082bf:	75 0e                	jne    80042082cf <strtol+0x9c>
		s += 2, base = 16;
  80042082c1:	48 83 45 d8 02       	addq   $0x2,-0x28(%rbp)
  80042082c6:	c7 45 cc 10 00 00 00 	movl   $0x10,-0x34(%rbp)
  80042082cd:	eb 2c                	jmp    80042082fb <strtol+0xc8>
	else if (base == 0 && s[0] == '0')
  80042082cf:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  80042082d3:	75 19                	jne    80042082ee <strtol+0xbb>
  80042082d5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042082d9:	0f b6 00             	movzbl (%rax),%eax
  80042082dc:	3c 30                	cmp    $0x30,%al
  80042082de:	75 0e                	jne    80042082ee <strtol+0xbb>
		s++, base = 8;
  80042082e0:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  80042082e5:	c7 45 cc 08 00 00 00 	movl   $0x8,-0x34(%rbp)
  80042082ec:	eb 0d                	jmp    80042082fb <strtol+0xc8>
	else if (base == 0)
  80042082ee:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  80042082f2:	75 07                	jne    80042082fb <strtol+0xc8>
		base = 10;
  80042082f4:	c7 45 cc 0a 00 00 00 	movl   $0xa,-0x34(%rbp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80042082fb:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042082ff:	0f b6 00             	movzbl (%rax),%eax
  8004208302:	3c 2f                	cmp    $0x2f,%al
  8004208304:	7e 1d                	jle    8004208323 <strtol+0xf0>
  8004208306:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420830a:	0f b6 00             	movzbl (%rax),%eax
  800420830d:	3c 39                	cmp    $0x39,%al
  800420830f:	7f 12                	jg     8004208323 <strtol+0xf0>
			dig = *s - '0';
  8004208311:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208315:	0f b6 00             	movzbl (%rax),%eax
  8004208318:	0f be c0             	movsbl %al,%eax
  800420831b:	83 e8 30             	sub    $0x30,%eax
  800420831e:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8004208321:	eb 4e                	jmp    8004208371 <strtol+0x13e>
		else if (*s >= 'a' && *s <= 'z')
  8004208323:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208327:	0f b6 00             	movzbl (%rax),%eax
  800420832a:	3c 60                	cmp    $0x60,%al
  800420832c:	7e 1d                	jle    800420834b <strtol+0x118>
  800420832e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208332:	0f b6 00             	movzbl (%rax),%eax
  8004208335:	3c 7a                	cmp    $0x7a,%al
  8004208337:	7f 12                	jg     800420834b <strtol+0x118>
			dig = *s - 'a' + 10;
  8004208339:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420833d:	0f b6 00             	movzbl (%rax),%eax
  8004208340:	0f be c0             	movsbl %al,%eax
  8004208343:	83 e8 57             	sub    $0x57,%eax
  8004208346:	89 45 ec             	mov    %eax,-0x14(%rbp)
  8004208349:	eb 26                	jmp    8004208371 <strtol+0x13e>
		else if (*s >= 'A' && *s <= 'Z')
  800420834b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420834f:	0f b6 00             	movzbl (%rax),%eax
  8004208352:	3c 40                	cmp    $0x40,%al
  8004208354:	7e 48                	jle    800420839e <strtol+0x16b>
  8004208356:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420835a:	0f b6 00             	movzbl (%rax),%eax
  800420835d:	3c 5a                	cmp    $0x5a,%al
  800420835f:	7f 3d                	jg     800420839e <strtol+0x16b>
			dig = *s - 'A' + 10;
  8004208361:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208365:	0f b6 00             	movzbl (%rax),%eax
  8004208368:	0f be c0             	movsbl %al,%eax
  800420836b:	83 e8 37             	sub    $0x37,%eax
  800420836e:	89 45 ec             	mov    %eax,-0x14(%rbp)
		else
			break;
		if (dig >= base)
  8004208371:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004208374:	3b 45 cc             	cmp    -0x34(%rbp),%eax
  8004208377:	7c 02                	jl     800420837b <strtol+0x148>
			break;
  8004208379:	eb 23                	jmp    800420839e <strtol+0x16b>
		s++, val = (val * base) + dig;
  800420837b:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
  8004208380:	8b 45 cc             	mov    -0x34(%rbp),%eax
  8004208383:	48 98                	cltq   
  8004208385:	48 0f af 45 f0       	imul   -0x10(%rbp),%rax
  800420838a:	48 89 c2             	mov    %rax,%rdx
  800420838d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  8004208390:	48 98                	cltq   
  8004208392:	48 01 d0             	add    %rdx,%rax
  8004208395:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
		// we don't properly detect overflow!
	}
  8004208399:	e9 5d ff ff ff       	jmpq   80042082fb <strtol+0xc8>

	if (endptr)
  800420839e:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  80042083a3:	74 0b                	je     80042083b0 <strtol+0x17d>
		*endptr = (char *) s;
  80042083a5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042083a9:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  80042083ad:	48 89 10             	mov    %rdx,(%rax)
	return (neg ? -val : val);
  80042083b0:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80042083b4:	74 09                	je     80042083bf <strtol+0x18c>
  80042083b6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042083ba:	48 f7 d8             	neg    %rax
  80042083bd:	eb 04                	jmp    80042083c3 <strtol+0x190>
  80042083bf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  80042083c3:	c9                   	leaveq 
  80042083c4:	c3                   	retq   

00000080042083c5 <strstr>:

char * strstr(const char *in, const char *str)
{
  80042083c5:	55                   	push   %rbp
  80042083c6:	48 89 e5             	mov    %rsp,%rbp
  80042083c9:	48 83 ec 30          	sub    $0x30,%rsp
  80042083cd:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  80042083d1:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	char c;
	size_t len;

	c = *str++;
  80042083d5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042083d9:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80042083dd:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  80042083e1:	0f b6 00             	movzbl (%rax),%eax
  80042083e4:	88 45 ff             	mov    %al,-0x1(%rbp)
	if (!c)
  80042083e7:	80 7d ff 00          	cmpb   $0x0,-0x1(%rbp)
  80042083eb:	75 06                	jne    80042083f3 <strstr+0x2e>
		return (char *) in;	// Trivial empty string case
  80042083ed:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042083f1:	eb 6b                	jmp    800420845e <strstr+0x99>

	len = strlen(str);
  80042083f3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042083f7:	48 89 c7             	mov    %rax,%rdi
  80042083fa:	48 b8 9b 7c 20 04 80 	movabs $0x8004207c9b,%rax
  8004208401:	00 00 00 
  8004208404:	ff d0                	callq  *%rax
  8004208406:	48 98                	cltq   
  8004208408:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	do {
		char sc;

		do {
			sc = *in++;
  800420840c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208410:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208414:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  8004208418:	0f b6 00             	movzbl (%rax),%eax
  800420841b:	88 45 ef             	mov    %al,-0x11(%rbp)
			if (!sc)
  800420841e:	80 7d ef 00          	cmpb   $0x0,-0x11(%rbp)
  8004208422:	75 07                	jne    800420842b <strstr+0x66>
				return (char *) 0;
  8004208424:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208429:	eb 33                	jmp    800420845e <strstr+0x99>
		} while (sc != c);
  800420842b:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
  800420842f:	3a 45 ff             	cmp    -0x1(%rbp),%al
  8004208432:	75 d8                	jne    800420840c <strstr+0x47>
	} while (strncmp(in, str, len) != 0);
  8004208434:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004208438:	48 8b 4d d0          	mov    -0x30(%rbp),%rcx
  800420843c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208440:	48 89 ce             	mov    %rcx,%rsi
  8004208443:	48 89 c7             	mov    %rax,%rdi
  8004208446:	48 b8 bc 7e 20 04 80 	movabs $0x8004207ebc,%rax
  800420844d:	00 00 00 
  8004208450:	ff d0                	callq  *%rax
  8004208452:	85 c0                	test   %eax,%eax
  8004208454:	75 b6                	jne    800420840c <strstr+0x47>

	return (char *) (in - 1);
  8004208456:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420845a:	48 83 e8 01          	sub    $0x1,%rax
}
  800420845e:	c9                   	leaveq 
  800420845f:	c3                   	retq   

0000008004208460 <_dwarf_read_lsb>:
Dwarf_Section *
_dwarf_find_section(const char *name);

uint64_t
_dwarf_read_lsb(uint8_t *data, uint64_t *offsetp, int bytes_to_read)
{
  8004208460:	55                   	push   %rbp
  8004208461:	48 89 e5             	mov    %rsp,%rbp
  8004208464:	48 83 ec 24          	sub    $0x24,%rsp
  8004208468:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420846c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004208470:	89 55 dc             	mov    %edx,-0x24(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = data + *offsetp;
  8004208473:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208477:	48 8b 10             	mov    (%rax),%rdx
  800420847a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420847e:	48 01 d0             	add    %rdx,%rax
  8004208481:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  8004208485:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  800420848c:	00 
	switch (bytes_to_read) {
  800420848d:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004208490:	83 f8 02             	cmp    $0x2,%eax
  8004208493:	0f 84 ab 00 00 00    	je     8004208544 <_dwarf_read_lsb+0xe4>
  8004208499:	83 f8 02             	cmp    $0x2,%eax
  800420849c:	7f 0e                	jg     80042084ac <_dwarf_read_lsb+0x4c>
  800420849e:	83 f8 01             	cmp    $0x1,%eax
  80042084a1:	0f 84 b3 00 00 00    	je     800420855a <_dwarf_read_lsb+0xfa>
  80042084a7:	e9 d9 00 00 00       	jmpq   8004208585 <_dwarf_read_lsb+0x125>
  80042084ac:	83 f8 04             	cmp    $0x4,%eax
  80042084af:	74 65                	je     8004208516 <_dwarf_read_lsb+0xb6>
  80042084b1:	83 f8 08             	cmp    $0x8,%eax
  80042084b4:	0f 85 cb 00 00 00    	jne    8004208585 <_dwarf_read_lsb+0x125>
	case 8:
		ret |= ((uint64_t) src[4]) << 32 | ((uint64_t) src[5]) << 40;
  80042084ba:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042084be:	48 83 c0 04          	add    $0x4,%rax
  80042084c2:	0f b6 00             	movzbl (%rax),%eax
  80042084c5:	0f b6 c0             	movzbl %al,%eax
  80042084c8:	48 c1 e0 20          	shl    $0x20,%rax
  80042084cc:	48 89 c2             	mov    %rax,%rdx
  80042084cf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042084d3:	48 83 c0 05          	add    $0x5,%rax
  80042084d7:	0f b6 00             	movzbl (%rax),%eax
  80042084da:	0f b6 c0             	movzbl %al,%eax
  80042084dd:	48 c1 e0 28          	shl    $0x28,%rax
  80042084e1:	48 09 d0             	or     %rdx,%rax
  80042084e4:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[6]) << 48 | ((uint64_t) src[7]) << 56;
  80042084e8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042084ec:	48 83 c0 06          	add    $0x6,%rax
  80042084f0:	0f b6 00             	movzbl (%rax),%eax
  80042084f3:	0f b6 c0             	movzbl %al,%eax
  80042084f6:	48 c1 e0 30          	shl    $0x30,%rax
  80042084fa:	48 89 c2             	mov    %rax,%rdx
  80042084fd:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208501:	48 83 c0 07          	add    $0x7,%rax
  8004208505:	0f b6 00             	movzbl (%rax),%eax
  8004208508:	0f b6 c0             	movzbl %al,%eax
  800420850b:	48 c1 e0 38          	shl    $0x38,%rax
  800420850f:	48 09 d0             	or     %rdx,%rax
  8004208512:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 4:
		ret |= ((uint64_t) src[2]) << 16 | ((uint64_t) src[3]) << 24;
  8004208516:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420851a:	48 83 c0 02          	add    $0x2,%rax
  800420851e:	0f b6 00             	movzbl (%rax),%eax
  8004208521:	0f b6 c0             	movzbl %al,%eax
  8004208524:	48 c1 e0 10          	shl    $0x10,%rax
  8004208528:	48 89 c2             	mov    %rax,%rdx
  800420852b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420852f:	48 83 c0 03          	add    $0x3,%rax
  8004208533:	0f b6 00             	movzbl (%rax),%eax
  8004208536:	0f b6 c0             	movzbl %al,%eax
  8004208539:	48 c1 e0 18          	shl    $0x18,%rax
  800420853d:	48 09 d0             	or     %rdx,%rax
  8004208540:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 2:
		ret |= ((uint64_t) src[1]) << 8;
  8004208544:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208548:	48 83 c0 01          	add    $0x1,%rax
  800420854c:	0f b6 00             	movzbl (%rax),%eax
  800420854f:	0f b6 c0             	movzbl %al,%eax
  8004208552:	48 c1 e0 08          	shl    $0x8,%rax
  8004208556:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 1:
		ret |= src[0];
  800420855a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420855e:	0f b6 00             	movzbl (%rax),%eax
  8004208561:	0f b6 c0             	movzbl %al,%eax
  8004208564:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004208568:	90                   	nop
	default:
		return (0);
	}

	*offsetp += bytes_to_read;
  8004208569:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420856d:	48 8b 10             	mov    (%rax),%rdx
  8004208570:	8b 45 dc             	mov    -0x24(%rbp),%eax
  8004208573:	48 98                	cltq   
  8004208575:	48 01 c2             	add    %rax,%rdx
  8004208578:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420857c:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  800420857f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208583:	eb 05                	jmp    800420858a <_dwarf_read_lsb+0x12a>
		ret |= ((uint64_t) src[1]) << 8;
	case 1:
		ret |= src[0];
		break;
	default:
		return (0);
  8004208585:	b8 00 00 00 00       	mov    $0x0,%eax
	}

	*offsetp += bytes_to_read;

	return (ret);
}
  800420858a:	c9                   	leaveq 
  800420858b:	c3                   	retq   

000000800420858c <_dwarf_decode_lsb>:

uint64_t
_dwarf_decode_lsb(uint8_t **data, int bytes_to_read)
{
  800420858c:	55                   	push   %rbp
  800420858d:	48 89 e5             	mov    %rsp,%rbp
  8004208590:	48 83 ec 1c          	sub    $0x1c,%rsp
  8004208594:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208598:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = *data;
  800420859b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420859f:	48 8b 00             	mov    (%rax),%rax
  80042085a2:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  80042085a6:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  80042085ad:	00 
	switch (bytes_to_read) {
  80042085ae:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042085b1:	83 f8 02             	cmp    $0x2,%eax
  80042085b4:	0f 84 ab 00 00 00    	je     8004208665 <_dwarf_decode_lsb+0xd9>
  80042085ba:	83 f8 02             	cmp    $0x2,%eax
  80042085bd:	7f 0e                	jg     80042085cd <_dwarf_decode_lsb+0x41>
  80042085bf:	83 f8 01             	cmp    $0x1,%eax
  80042085c2:	0f 84 b3 00 00 00    	je     800420867b <_dwarf_decode_lsb+0xef>
  80042085c8:	e9 d9 00 00 00       	jmpq   80042086a6 <_dwarf_decode_lsb+0x11a>
  80042085cd:	83 f8 04             	cmp    $0x4,%eax
  80042085d0:	74 65                	je     8004208637 <_dwarf_decode_lsb+0xab>
  80042085d2:	83 f8 08             	cmp    $0x8,%eax
  80042085d5:	0f 85 cb 00 00 00    	jne    80042086a6 <_dwarf_decode_lsb+0x11a>
	case 8:
		ret |= ((uint64_t) src[4]) << 32 | ((uint64_t) src[5]) << 40;
  80042085db:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042085df:	48 83 c0 04          	add    $0x4,%rax
  80042085e3:	0f b6 00             	movzbl (%rax),%eax
  80042085e6:	0f b6 c0             	movzbl %al,%eax
  80042085e9:	48 c1 e0 20          	shl    $0x20,%rax
  80042085ed:	48 89 c2             	mov    %rax,%rdx
  80042085f0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042085f4:	48 83 c0 05          	add    $0x5,%rax
  80042085f8:	0f b6 00             	movzbl (%rax),%eax
  80042085fb:	0f b6 c0             	movzbl %al,%eax
  80042085fe:	48 c1 e0 28          	shl    $0x28,%rax
  8004208602:	48 09 d0             	or     %rdx,%rax
  8004208605:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[6]) << 48 | ((uint64_t) src[7]) << 56;
  8004208609:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420860d:	48 83 c0 06          	add    $0x6,%rax
  8004208611:	0f b6 00             	movzbl (%rax),%eax
  8004208614:	0f b6 c0             	movzbl %al,%eax
  8004208617:	48 c1 e0 30          	shl    $0x30,%rax
  800420861b:	48 89 c2             	mov    %rax,%rdx
  800420861e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208622:	48 83 c0 07          	add    $0x7,%rax
  8004208626:	0f b6 00             	movzbl (%rax),%eax
  8004208629:	0f b6 c0             	movzbl %al,%eax
  800420862c:	48 c1 e0 38          	shl    $0x38,%rax
  8004208630:	48 09 d0             	or     %rdx,%rax
  8004208633:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 4:
		ret |= ((uint64_t) src[2]) << 16 | ((uint64_t) src[3]) << 24;
  8004208637:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420863b:	48 83 c0 02          	add    $0x2,%rax
  800420863f:	0f b6 00             	movzbl (%rax),%eax
  8004208642:	0f b6 c0             	movzbl %al,%eax
  8004208645:	48 c1 e0 10          	shl    $0x10,%rax
  8004208649:	48 89 c2             	mov    %rax,%rdx
  800420864c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208650:	48 83 c0 03          	add    $0x3,%rax
  8004208654:	0f b6 00             	movzbl (%rax),%eax
  8004208657:	0f b6 c0             	movzbl %al,%eax
  800420865a:	48 c1 e0 18          	shl    $0x18,%rax
  800420865e:	48 09 d0             	or     %rdx,%rax
  8004208661:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 2:
		ret |= ((uint64_t) src[1]) << 8;
  8004208665:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208669:	48 83 c0 01          	add    $0x1,%rax
  800420866d:	0f b6 00             	movzbl (%rax),%eax
  8004208670:	0f b6 c0             	movzbl %al,%eax
  8004208673:	48 c1 e0 08          	shl    $0x8,%rax
  8004208677:	48 09 45 f8          	or     %rax,-0x8(%rbp)
	case 1:
		ret |= src[0];
  800420867b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420867f:	0f b6 00             	movzbl (%rax),%eax
  8004208682:	0f b6 c0             	movzbl %al,%eax
  8004208685:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004208689:	90                   	nop
	default:
		return (0);
	}

	*data += bytes_to_read;
  800420868a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420868e:	48 8b 10             	mov    (%rax),%rdx
  8004208691:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004208694:	48 98                	cltq   
  8004208696:	48 01 c2             	add    %rax,%rdx
  8004208699:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420869d:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  80042086a0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  80042086a4:	eb 05                	jmp    80042086ab <_dwarf_decode_lsb+0x11f>
		ret |= ((uint64_t) src[1]) << 8;
	case 1:
		ret |= src[0];
		break;
	default:
		return (0);
  80042086a6:	b8 00 00 00 00       	mov    $0x0,%eax
	}

	*data += bytes_to_read;

	return (ret);
}
  80042086ab:	c9                   	leaveq 
  80042086ac:	c3                   	retq   

00000080042086ad <_dwarf_read_msb>:

uint64_t
_dwarf_read_msb(uint8_t *data, uint64_t *offsetp, int bytes_to_read)
{
  80042086ad:	55                   	push   %rbp
  80042086ae:	48 89 e5             	mov    %rsp,%rbp
  80042086b1:	48 83 ec 24          	sub    $0x24,%rsp
  80042086b5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  80042086b9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  80042086bd:	89 55 dc             	mov    %edx,-0x24(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = data + *offsetp;
  80042086c0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  80042086c4:	48 8b 10             	mov    (%rax),%rdx
  80042086c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042086cb:	48 01 d0             	add    %rdx,%rax
  80042086ce:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	switch (bytes_to_read) {
  80042086d2:	8b 45 dc             	mov    -0x24(%rbp),%eax
  80042086d5:	83 f8 02             	cmp    $0x2,%eax
  80042086d8:	74 35                	je     800420870f <_dwarf_read_msb+0x62>
  80042086da:	83 f8 02             	cmp    $0x2,%eax
  80042086dd:	7f 0a                	jg     80042086e9 <_dwarf_read_msb+0x3c>
  80042086df:	83 f8 01             	cmp    $0x1,%eax
  80042086e2:	74 18                	je     80042086fc <_dwarf_read_msb+0x4f>
  80042086e4:	e9 53 01 00 00       	jmpq   800420883c <_dwarf_read_msb+0x18f>
  80042086e9:	83 f8 04             	cmp    $0x4,%eax
  80042086ec:	74 49                	je     8004208737 <_dwarf_read_msb+0x8a>
  80042086ee:	83 f8 08             	cmp    $0x8,%eax
  80042086f1:	0f 84 96 00 00 00    	je     800420878d <_dwarf_read_msb+0xe0>
  80042086f7:	e9 40 01 00 00       	jmpq   800420883c <_dwarf_read_msb+0x18f>
	case 1:
		ret = src[0];
  80042086fc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208700:	0f b6 00             	movzbl (%rax),%eax
  8004208703:	0f b6 c0             	movzbl %al,%eax
  8004208706:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  800420870a:	e9 34 01 00 00       	jmpq   8004208843 <_dwarf_read_msb+0x196>
	case 2:
		ret = src[1] | ((uint64_t) src[0]) << 8;
  800420870f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208713:	48 83 c0 01          	add    $0x1,%rax
  8004208717:	0f b6 00             	movzbl (%rax),%eax
  800420871a:	0f b6 d0             	movzbl %al,%edx
  800420871d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208721:	0f b6 00             	movzbl (%rax),%eax
  8004208724:	0f b6 c0             	movzbl %al,%eax
  8004208727:	48 c1 e0 08          	shl    $0x8,%rax
  800420872b:	48 09 d0             	or     %rdx,%rax
  800420872e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  8004208732:	e9 0c 01 00 00       	jmpq   8004208843 <_dwarf_read_msb+0x196>
	case 4:
		ret = src[3] | ((uint64_t) src[2]) << 8;
  8004208737:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420873b:	48 83 c0 03          	add    $0x3,%rax
  800420873f:	0f b6 00             	movzbl (%rax),%eax
  8004208742:	0f b6 c0             	movzbl %al,%eax
  8004208745:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004208749:	48 83 c2 02          	add    $0x2,%rdx
  800420874d:	0f b6 12             	movzbl (%rdx),%edx
  8004208750:	0f b6 d2             	movzbl %dl,%edx
  8004208753:	48 c1 e2 08          	shl    $0x8,%rdx
  8004208757:	48 09 d0             	or     %rdx,%rax
  800420875a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 16 | ((uint64_t) src[0]) << 24;
  800420875e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208762:	48 83 c0 01          	add    $0x1,%rax
  8004208766:	0f b6 00             	movzbl (%rax),%eax
  8004208769:	0f b6 c0             	movzbl %al,%eax
  800420876c:	48 c1 e0 10          	shl    $0x10,%rax
  8004208770:	48 89 c2             	mov    %rax,%rdx
  8004208773:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208777:	0f b6 00             	movzbl (%rax),%eax
  800420877a:	0f b6 c0             	movzbl %al,%eax
  800420877d:	48 c1 e0 18          	shl    $0x18,%rax
  8004208781:	48 09 d0             	or     %rdx,%rax
  8004208784:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004208788:	e9 b6 00 00 00       	jmpq   8004208843 <_dwarf_read_msb+0x196>
	case 8:
		ret = src[7] | ((uint64_t) src[6]) << 8;
  800420878d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208791:	48 83 c0 07          	add    $0x7,%rax
  8004208795:	0f b6 00             	movzbl (%rax),%eax
  8004208798:	0f b6 c0             	movzbl %al,%eax
  800420879b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420879f:	48 83 c2 06          	add    $0x6,%rdx
  80042087a3:	0f b6 12             	movzbl (%rdx),%edx
  80042087a6:	0f b6 d2             	movzbl %dl,%edx
  80042087a9:	48 c1 e2 08          	shl    $0x8,%rdx
  80042087ad:	48 09 d0             	or     %rdx,%rax
  80042087b0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[5]) << 16 | ((uint64_t) src[4]) << 24;
  80042087b4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042087b8:	48 83 c0 05          	add    $0x5,%rax
  80042087bc:	0f b6 00             	movzbl (%rax),%eax
  80042087bf:	0f b6 c0             	movzbl %al,%eax
  80042087c2:	48 c1 e0 10          	shl    $0x10,%rax
  80042087c6:	48 89 c2             	mov    %rax,%rdx
  80042087c9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042087cd:	48 83 c0 04          	add    $0x4,%rax
  80042087d1:	0f b6 00             	movzbl (%rax),%eax
  80042087d4:	0f b6 c0             	movzbl %al,%eax
  80042087d7:	48 c1 e0 18          	shl    $0x18,%rax
  80042087db:	48 09 d0             	or     %rdx,%rax
  80042087de:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[3]) << 32 | ((uint64_t) src[2]) << 40;
  80042087e2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042087e6:	48 83 c0 03          	add    $0x3,%rax
  80042087ea:	0f b6 00             	movzbl (%rax),%eax
  80042087ed:	0f b6 c0             	movzbl %al,%eax
  80042087f0:	48 c1 e0 20          	shl    $0x20,%rax
  80042087f4:	48 89 c2             	mov    %rax,%rdx
  80042087f7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042087fb:	48 83 c0 02          	add    $0x2,%rax
  80042087ff:	0f b6 00             	movzbl (%rax),%eax
  8004208802:	0f b6 c0             	movzbl %al,%eax
  8004208805:	48 c1 e0 28          	shl    $0x28,%rax
  8004208809:	48 09 d0             	or     %rdx,%rax
  800420880c:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 48 | ((uint64_t) src[0]) << 56;
  8004208810:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208814:	48 83 c0 01          	add    $0x1,%rax
  8004208818:	0f b6 00             	movzbl (%rax),%eax
  800420881b:	0f b6 c0             	movzbl %al,%eax
  800420881e:	48 c1 e0 30          	shl    $0x30,%rax
  8004208822:	48 89 c2             	mov    %rax,%rdx
  8004208825:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208829:	0f b6 00             	movzbl (%rax),%eax
  800420882c:	0f b6 c0             	movzbl %al,%eax
  800420882f:	48 c1 e0 38          	shl    $0x38,%rax
  8004208833:	48 09 d0             	or     %rdx,%rax
  8004208836:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  800420883a:	eb 07                	jmp    8004208843 <_dwarf_read_msb+0x196>
	default:
		return (0);
  800420883c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208841:	eb 1a                	jmp    800420885d <_dwarf_read_msb+0x1b0>
	}

	*offsetp += bytes_to_read;
  8004208843:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208847:	48 8b 10             	mov    (%rax),%rdx
  800420884a:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800420884d:	48 98                	cltq   
  800420884f:	48 01 c2             	add    %rax,%rdx
  8004208852:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208856:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208859:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800420885d:	c9                   	leaveq 
  800420885e:	c3                   	retq   

000000800420885f <_dwarf_decode_msb>:

uint64_t
_dwarf_decode_msb(uint8_t **data, int bytes_to_read)
{
  800420885f:	55                   	push   %rbp
  8004208860:	48 89 e5             	mov    %rsp,%rbp
  8004208863:	48 83 ec 1c          	sub    $0x1c,%rsp
  8004208867:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420886b:	89 75 e4             	mov    %esi,-0x1c(%rbp)
	uint64_t ret;
	uint8_t *src;

	src = *data;
  800420886e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208872:	48 8b 00             	mov    (%rax),%rax
  8004208875:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	ret = 0;
  8004208879:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004208880:	00 
	switch (bytes_to_read) {
  8004208881:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004208884:	83 f8 02             	cmp    $0x2,%eax
  8004208887:	74 35                	je     80042088be <_dwarf_decode_msb+0x5f>
  8004208889:	83 f8 02             	cmp    $0x2,%eax
  800420888c:	7f 0a                	jg     8004208898 <_dwarf_decode_msb+0x39>
  800420888e:	83 f8 01             	cmp    $0x1,%eax
  8004208891:	74 18                	je     80042088ab <_dwarf_decode_msb+0x4c>
  8004208893:	e9 53 01 00 00       	jmpq   80042089eb <_dwarf_decode_msb+0x18c>
  8004208898:	83 f8 04             	cmp    $0x4,%eax
  800420889b:	74 49                	je     80042088e6 <_dwarf_decode_msb+0x87>
  800420889d:	83 f8 08             	cmp    $0x8,%eax
  80042088a0:	0f 84 96 00 00 00    	je     800420893c <_dwarf_decode_msb+0xdd>
  80042088a6:	e9 40 01 00 00       	jmpq   80042089eb <_dwarf_decode_msb+0x18c>
	case 1:
		ret = src[0];
  80042088ab:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042088af:	0f b6 00             	movzbl (%rax),%eax
  80042088b2:	0f b6 c0             	movzbl %al,%eax
  80042088b5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  80042088b9:	e9 34 01 00 00       	jmpq   80042089f2 <_dwarf_decode_msb+0x193>
	case 2:
		ret = src[1] | ((uint64_t) src[0]) << 8;
  80042088be:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042088c2:	48 83 c0 01          	add    $0x1,%rax
  80042088c6:	0f b6 00             	movzbl (%rax),%eax
  80042088c9:	0f b6 d0             	movzbl %al,%edx
  80042088cc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042088d0:	0f b6 00             	movzbl (%rax),%eax
  80042088d3:	0f b6 c0             	movzbl %al,%eax
  80042088d6:	48 c1 e0 08          	shl    $0x8,%rax
  80042088da:	48 09 d0             	or     %rdx,%rax
  80042088dd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		break;
  80042088e1:	e9 0c 01 00 00       	jmpq   80042089f2 <_dwarf_decode_msb+0x193>
	case 4:
		ret = src[3] | ((uint64_t) src[2]) << 8;
  80042088e6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042088ea:	48 83 c0 03          	add    $0x3,%rax
  80042088ee:	0f b6 00             	movzbl (%rax),%eax
  80042088f1:	0f b6 c0             	movzbl %al,%eax
  80042088f4:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  80042088f8:	48 83 c2 02          	add    $0x2,%rdx
  80042088fc:	0f b6 12             	movzbl (%rdx),%edx
  80042088ff:	0f b6 d2             	movzbl %dl,%edx
  8004208902:	48 c1 e2 08          	shl    $0x8,%rdx
  8004208906:	48 09 d0             	or     %rdx,%rax
  8004208909:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 16 | ((uint64_t) src[0]) << 24;
  800420890d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208911:	48 83 c0 01          	add    $0x1,%rax
  8004208915:	0f b6 00             	movzbl (%rax),%eax
  8004208918:	0f b6 c0             	movzbl %al,%eax
  800420891b:	48 c1 e0 10          	shl    $0x10,%rax
  800420891f:	48 89 c2             	mov    %rax,%rdx
  8004208922:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208926:	0f b6 00             	movzbl (%rax),%eax
  8004208929:	0f b6 c0             	movzbl %al,%eax
  800420892c:	48 c1 e0 18          	shl    $0x18,%rax
  8004208930:	48 09 d0             	or     %rdx,%rax
  8004208933:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  8004208937:	e9 b6 00 00 00       	jmpq   80042089f2 <_dwarf_decode_msb+0x193>
	case 8:
		ret = src[7] | ((uint64_t) src[6]) << 8;
  800420893c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208940:	48 83 c0 07          	add    $0x7,%rax
  8004208944:	0f b6 00             	movzbl (%rax),%eax
  8004208947:	0f b6 c0             	movzbl %al,%eax
  800420894a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420894e:	48 83 c2 06          	add    $0x6,%rdx
  8004208952:	0f b6 12             	movzbl (%rdx),%edx
  8004208955:	0f b6 d2             	movzbl %dl,%edx
  8004208958:	48 c1 e2 08          	shl    $0x8,%rdx
  800420895c:	48 09 d0             	or     %rdx,%rax
  800420895f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[5]) << 16 | ((uint64_t) src[4]) << 24;
  8004208963:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208967:	48 83 c0 05          	add    $0x5,%rax
  800420896b:	0f b6 00             	movzbl (%rax),%eax
  800420896e:	0f b6 c0             	movzbl %al,%eax
  8004208971:	48 c1 e0 10          	shl    $0x10,%rax
  8004208975:	48 89 c2             	mov    %rax,%rdx
  8004208978:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420897c:	48 83 c0 04          	add    $0x4,%rax
  8004208980:	0f b6 00             	movzbl (%rax),%eax
  8004208983:	0f b6 c0             	movzbl %al,%eax
  8004208986:	48 c1 e0 18          	shl    $0x18,%rax
  800420898a:	48 09 d0             	or     %rdx,%rax
  800420898d:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[3]) << 32 | ((uint64_t) src[2]) << 40;
  8004208991:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208995:	48 83 c0 03          	add    $0x3,%rax
  8004208999:	0f b6 00             	movzbl (%rax),%eax
  800420899c:	0f b6 c0             	movzbl %al,%eax
  800420899f:	48 c1 e0 20          	shl    $0x20,%rax
  80042089a3:	48 89 c2             	mov    %rax,%rdx
  80042089a6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042089aa:	48 83 c0 02          	add    $0x2,%rax
  80042089ae:	0f b6 00             	movzbl (%rax),%eax
  80042089b1:	0f b6 c0             	movzbl %al,%eax
  80042089b4:	48 c1 e0 28          	shl    $0x28,%rax
  80042089b8:	48 09 d0             	or     %rdx,%rax
  80042089bb:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		ret |= ((uint64_t) src[1]) << 48 | ((uint64_t) src[0]) << 56;
  80042089bf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042089c3:	48 83 c0 01          	add    $0x1,%rax
  80042089c7:	0f b6 00             	movzbl (%rax),%eax
  80042089ca:	0f b6 c0             	movzbl %al,%eax
  80042089cd:	48 c1 e0 30          	shl    $0x30,%rax
  80042089d1:	48 89 c2             	mov    %rax,%rdx
  80042089d4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042089d8:	0f b6 00             	movzbl (%rax),%eax
  80042089db:	0f b6 c0             	movzbl %al,%eax
  80042089de:	48 c1 e0 38          	shl    $0x38,%rax
  80042089e2:	48 09 d0             	or     %rdx,%rax
  80042089e5:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		break;
  80042089e9:	eb 07                	jmp    80042089f2 <_dwarf_decode_msb+0x193>
	default:
		return (0);
  80042089eb:	b8 00 00 00 00       	mov    $0x0,%eax
  80042089f0:	eb 1a                	jmp    8004208a0c <_dwarf_decode_msb+0x1ad>
		break;
	}

	*data += bytes_to_read;
  80042089f2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042089f6:	48 8b 10             	mov    (%rax),%rdx
  80042089f9:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  80042089fc:	48 98                	cltq   
  80042089fe:	48 01 c2             	add    %rax,%rdx
  8004208a01:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208a05:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208a08:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208a0c:	c9                   	leaveq 
  8004208a0d:	c3                   	retq   

0000008004208a0e <_dwarf_read_sleb128>:

int64_t
_dwarf_read_sleb128(uint8_t *data, uint64_t *offsetp)
{
  8004208a0e:	55                   	push   %rbp
  8004208a0f:	48 89 e5             	mov    %rsp,%rbp
  8004208a12:	48 83 ec 30          	sub    $0x30,%rsp
  8004208a16:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004208a1a:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	int64_t ret = 0;
  8004208a1e:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004208a25:	00 
	uint8_t b;
	int shift = 0;
  8004208a26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	uint8_t *src;

	src = data + *offsetp;
  8004208a2d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208a31:	48 8b 10             	mov    (%rax),%rdx
  8004208a34:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208a38:	48 01 d0             	add    %rdx,%rax
  8004208a3b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004208a3f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208a43:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208a47:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004208a4b:	0f b6 00             	movzbl (%rax),%eax
  8004208a4e:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004208a51:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208a55:	83 e0 7f             	and    $0x7f,%eax
  8004208a58:	89 c2                	mov    %eax,%edx
  8004208a5a:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208a5d:	89 c1                	mov    %eax,%ecx
  8004208a5f:	d3 e2                	shl    %cl,%edx
  8004208a61:	89 d0                	mov    %edx,%eax
  8004208a63:	48 98                	cltq   
  8004208a65:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		(*offsetp)++;
  8004208a69:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208a6d:	48 8b 00             	mov    (%rax),%rax
  8004208a70:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208a74:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208a78:	48 89 10             	mov    %rdx,(%rax)
		shift += 7;
  8004208a7b:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004208a7f:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208a83:	84 c0                	test   %al,%al
  8004208a85:	78 b8                	js     8004208a3f <_dwarf_read_sleb128+0x31>

	if (shift < 32 && (b & 0x40) != 0)
  8004208a87:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004208a8b:	7f 1f                	jg     8004208aac <_dwarf_read_sleb128+0x9e>
  8004208a8d:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208a91:	83 e0 40             	and    $0x40,%eax
  8004208a94:	85 c0                	test   %eax,%eax
  8004208a96:	74 14                	je     8004208aac <_dwarf_read_sleb128+0x9e>
		ret |= (-1 << shift);
  8004208a98:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208a9b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8004208aa0:	89 c1                	mov    %eax,%ecx
  8004208aa2:	d3 e2                	shl    %cl,%edx
  8004208aa4:	89 d0                	mov    %edx,%eax
  8004208aa6:	48 98                	cltq   
  8004208aa8:	48 09 45 f8          	or     %rax,-0x8(%rbp)

	return (ret);
  8004208aac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208ab0:	c9                   	leaveq 
  8004208ab1:	c3                   	retq   

0000008004208ab2 <_dwarf_read_uleb128>:

uint64_t
_dwarf_read_uleb128(uint8_t *data, uint64_t *offsetp)
{
  8004208ab2:	55                   	push   %rbp
  8004208ab3:	48 89 e5             	mov    %rsp,%rbp
  8004208ab6:	48 83 ec 30          	sub    $0x30,%rsp
  8004208aba:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004208abe:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
	uint64_t ret = 0;
  8004208ac2:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004208ac9:	00 
	uint8_t b;
	int shift = 0;
  8004208aca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	uint8_t *src;

	src = data + *offsetp;
  8004208ad1:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208ad5:	48 8b 10             	mov    (%rax),%rdx
  8004208ad8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208adc:	48 01 d0             	add    %rdx,%rax
  8004208adf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004208ae3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208ae7:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208aeb:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004208aef:	0f b6 00             	movzbl (%rax),%eax
  8004208af2:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004208af5:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208af9:	83 e0 7f             	and    $0x7f,%eax
  8004208afc:	89 c2                	mov    %eax,%edx
  8004208afe:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208b01:	89 c1                	mov    %eax,%ecx
  8004208b03:	d3 e2                	shl    %cl,%edx
  8004208b05:	89 d0                	mov    %edx,%eax
  8004208b07:	48 98                	cltq   
  8004208b09:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		(*offsetp)++;
  8004208b0d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208b11:	48 8b 00             	mov    (%rax),%rax
  8004208b14:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208b18:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  8004208b1c:	48 89 10             	mov    %rdx,(%rax)
		shift += 7;
  8004208b1f:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004208b23:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208b27:	84 c0                	test   %al,%al
  8004208b29:	78 b8                	js     8004208ae3 <_dwarf_read_uleb128+0x31>

	return (ret);
  8004208b2b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208b2f:	c9                   	leaveq 
  8004208b30:	c3                   	retq   

0000008004208b31 <_dwarf_decode_sleb128>:

int64_t
_dwarf_decode_sleb128(uint8_t **dp)
{
  8004208b31:	55                   	push   %rbp
  8004208b32:	48 89 e5             	mov    %rsp,%rbp
  8004208b35:	48 83 ec 28          	sub    $0x28,%rsp
  8004208b39:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
	int64_t ret = 0;
  8004208b3d:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004208b44:	00 
	uint8_t b;
	int shift = 0;
  8004208b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)

	uint8_t *src = *dp;
  8004208b4c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208b50:	48 8b 00             	mov    (%rax),%rax
  8004208b53:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004208b57:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208b5b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208b5f:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004208b63:	0f b6 00             	movzbl (%rax),%eax
  8004208b66:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004208b69:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208b6d:	83 e0 7f             	and    $0x7f,%eax
  8004208b70:	89 c2                	mov    %eax,%edx
  8004208b72:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208b75:	89 c1                	mov    %eax,%ecx
  8004208b77:	d3 e2                	shl    %cl,%edx
  8004208b79:	89 d0                	mov    %edx,%eax
  8004208b7b:	48 98                	cltq   
  8004208b7d:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		shift += 7;
  8004208b81:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004208b85:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208b89:	84 c0                	test   %al,%al
  8004208b8b:	78 ca                	js     8004208b57 <_dwarf_decode_sleb128+0x26>

	if (shift < 32 && (b & 0x40) != 0)
  8004208b8d:	83 7d f4 1f          	cmpl   $0x1f,-0xc(%rbp)
  8004208b91:	7f 1f                	jg     8004208bb2 <_dwarf_decode_sleb128+0x81>
  8004208b93:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208b97:	83 e0 40             	and    $0x40,%eax
  8004208b9a:	85 c0                	test   %eax,%eax
  8004208b9c:	74 14                	je     8004208bb2 <_dwarf_decode_sleb128+0x81>
		ret |= (-1 << shift);
  8004208b9e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208ba1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8004208ba6:	89 c1                	mov    %eax,%ecx
  8004208ba8:	d3 e2                	shl    %cl,%edx
  8004208baa:	89 d0                	mov    %edx,%eax
  8004208bac:	48 98                	cltq   
  8004208bae:	48 09 45 f8          	or     %rax,-0x8(%rbp)

	*dp = src;
  8004208bb2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208bb6:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208bba:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208bbd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208bc1:	c9                   	leaveq 
  8004208bc2:	c3                   	retq   

0000008004208bc3 <_dwarf_decode_uleb128>:

uint64_t
_dwarf_decode_uleb128(uint8_t **dp)
{
  8004208bc3:	55                   	push   %rbp
  8004208bc4:	48 89 e5             	mov    %rsp,%rbp
  8004208bc7:	48 83 ec 28          	sub    $0x28,%rsp
  8004208bcb:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
	uint64_t ret = 0;
  8004208bcf:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004208bd6:	00 
	uint8_t b;
	int shift = 0;
  8004208bd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)

	uint8_t *src = *dp;
  8004208bde:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208be2:	48 8b 00             	mov    (%rax),%rax
  8004208be5:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	do {
		b = *src++;
  8004208be9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208bed:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208bf1:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
  8004208bf5:	0f b6 00             	movzbl (%rax),%eax
  8004208bf8:	88 45 e7             	mov    %al,-0x19(%rbp)
		ret |= ((b & 0x7f) << shift);
  8004208bfb:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208bff:	83 e0 7f             	and    $0x7f,%eax
  8004208c02:	89 c2                	mov    %eax,%edx
  8004208c04:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004208c07:	89 c1                	mov    %eax,%ecx
  8004208c09:	d3 e2                	shl    %cl,%edx
  8004208c0b:	89 d0                	mov    %edx,%eax
  8004208c0d:	48 98                	cltq   
  8004208c0f:	48 09 45 f8          	or     %rax,-0x8(%rbp)
		shift += 7;
  8004208c13:	83 45 f4 07          	addl   $0x7,-0xc(%rbp)
	} while ((b & 0x80) != 0);
  8004208c17:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  8004208c1b:	84 c0                	test   %al,%al
  8004208c1d:	78 ca                	js     8004208be9 <_dwarf_decode_uleb128+0x26>

	*dp = src;
  8004208c1f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c23:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208c27:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208c2a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004208c2e:	c9                   	leaveq 
  8004208c2f:	c3                   	retq   

0000008004208c30 <_dwarf_read_string>:

#define Dwarf_Unsigned uint64_t

char *
_dwarf_read_string(void *data, Dwarf_Unsigned size, uint64_t *offsetp)
{
  8004208c30:	55                   	push   %rbp
  8004208c31:	48 89 e5             	mov    %rsp,%rbp
  8004208c34:	48 83 ec 28          	sub    $0x28,%rsp
  8004208c38:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208c3c:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004208c40:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	char *ret, *src;

	ret = src = (char *) data + *offsetp;
  8004208c44:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c48:	48 8b 10             	mov    (%rax),%rdx
  8004208c4b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208c4f:	48 01 d0             	add    %rdx,%rax
  8004208c52:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004208c56:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208c5a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	while (*src != '\0' && *offsetp < size) {
  8004208c5e:	eb 17                	jmp    8004208c77 <_dwarf_read_string+0x47>
		src++;
  8004208c60:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
		(*offsetp)++;
  8004208c65:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c69:	48 8b 00             	mov    (%rax),%rax
  8004208c6c:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208c70:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c74:	48 89 10             	mov    %rdx,(%rax)
{
	char *ret, *src;

	ret = src = (char *) data + *offsetp;

	while (*src != '\0' && *offsetp < size) {
  8004208c77:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208c7b:	0f b6 00             	movzbl (%rax),%eax
  8004208c7e:	84 c0                	test   %al,%al
  8004208c80:	74 0d                	je     8004208c8f <_dwarf_read_string+0x5f>
  8004208c82:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c86:	48 8b 00             	mov    (%rax),%rax
  8004208c89:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004208c8d:	72 d1                	jb     8004208c60 <_dwarf_read_string+0x30>
		src++;
		(*offsetp)++;
	}

	if (*src == '\0' && *offsetp < size)
  8004208c8f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208c93:	0f b6 00             	movzbl (%rax),%eax
  8004208c96:	84 c0                	test   %al,%al
  8004208c98:	75 1f                	jne    8004208cb9 <_dwarf_read_string+0x89>
  8004208c9a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208c9e:	48 8b 00             	mov    (%rax),%rax
  8004208ca1:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004208ca5:	73 12                	jae    8004208cb9 <_dwarf_read_string+0x89>
		(*offsetp)++;
  8004208ca7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208cab:	48 8b 00             	mov    (%rax),%rax
  8004208cae:	48 8d 50 01          	lea    0x1(%rax),%rdx
  8004208cb2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208cb6:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208cb9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004208cbd:	c9                   	leaveq 
  8004208cbe:	c3                   	retq   

0000008004208cbf <_dwarf_read_block>:

uint8_t *
_dwarf_read_block(void *data, uint64_t *offsetp, uint64_t length)
{
  8004208cbf:	55                   	push   %rbp
  8004208cc0:	48 89 e5             	mov    %rsp,%rbp
  8004208cc3:	48 83 ec 28          	sub    $0x28,%rsp
  8004208cc7:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208ccb:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004208ccf:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	uint8_t *ret, *src;

	ret = src = (uint8_t *) data + *offsetp;
  8004208cd3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208cd7:	48 8b 10             	mov    (%rax),%rdx
  8004208cda:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208cde:	48 01 d0             	add    %rdx,%rax
  8004208ce1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  8004208ce5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208ce9:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	(*offsetp) += length;
  8004208ced:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208cf1:	48 8b 10             	mov    (%rax),%rdx
  8004208cf4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004208cf8:	48 01 c2             	add    %rax,%rdx
  8004208cfb:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208cff:	48 89 10             	mov    %rdx,(%rax)

	return (ret);
  8004208d02:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
}
  8004208d06:	c9                   	leaveq 
  8004208d07:	c3                   	retq   

0000008004208d08 <_dwarf_elf_get_byte_order>:

Dwarf_Endianness
_dwarf_elf_get_byte_order(void *obj)
{
  8004208d08:	55                   	push   %rbp
  8004208d09:	48 89 e5             	mov    %rsp,%rbp
  8004208d0c:	48 83 ec 20          	sub    $0x20,%rsp
  8004208d10:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Elf *e;

	e = (Elf *)obj;
  8004208d14:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208d18:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(e != NULL);
  8004208d1c:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004208d21:	75 35                	jne    8004208d58 <_dwarf_elf_get_byte_order+0x50>
  8004208d23:	48 b9 40 fb 20 04 80 	movabs $0x800420fb40,%rcx
  8004208d2a:	00 00 00 
  8004208d2d:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004208d34:	00 00 00 
  8004208d37:	be 29 01 00 00       	mov    $0x129,%esi
  8004208d3c:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004208d43:	00 00 00 
  8004208d46:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208d4b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004208d52:	00 00 00 
  8004208d55:	41 ff d0             	callq  *%r8

//TODO: Need to check for 64bit here. Because currently Elf header for
//      64bit doesn't have any memeber e_ident. But need to see what is
//      similar in 64bit.
	switch (e->e_ident[EI_DATA]) {
  8004208d58:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208d5c:	0f b6 40 05          	movzbl 0x5(%rax),%eax
  8004208d60:	0f b6 c0             	movzbl %al,%eax
  8004208d63:	83 f8 02             	cmp    $0x2,%eax
  8004208d66:	75 07                	jne    8004208d6f <_dwarf_elf_get_byte_order+0x67>
	case ELFDATA2MSB:
		return (DW_OBJECT_MSB);
  8004208d68:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208d6d:	eb 05                	jmp    8004208d74 <_dwarf_elf_get_byte_order+0x6c>

	case ELFDATA2LSB:
	case ELFDATANONE:
	default:
		return (DW_OBJECT_LSB);
  8004208d6f:	b8 01 00 00 00       	mov    $0x1,%eax
	}
}
  8004208d74:	c9                   	leaveq 
  8004208d75:	c3                   	retq   

0000008004208d76 <_dwarf_elf_get_pointer_size>:

Dwarf_Small
_dwarf_elf_get_pointer_size(void *obj)
{
  8004208d76:	55                   	push   %rbp
  8004208d77:	48 89 e5             	mov    %rsp,%rbp
  8004208d7a:	48 83 ec 20          	sub    $0x20,%rsp
  8004208d7e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Elf *e;

	e = (Elf *) obj;
  8004208d82:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208d86:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(e != NULL);
  8004208d8a:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  8004208d8f:	75 35                	jne    8004208dc6 <_dwarf_elf_get_pointer_size+0x50>
  8004208d91:	48 b9 40 fb 20 04 80 	movabs $0x800420fb40,%rcx
  8004208d98:	00 00 00 
  8004208d9b:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004208da2:	00 00 00 
  8004208da5:	be 3f 01 00 00       	mov    $0x13f,%esi
  8004208daa:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004208db1:	00 00 00 
  8004208db4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004208db9:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004208dc0:	00 00 00 
  8004208dc3:	41 ff d0             	callq  *%r8

	if (e->e_ident[4] == ELFCLASS32)
  8004208dc6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004208dca:	0f b6 40 04          	movzbl 0x4(%rax),%eax
  8004208dce:	3c 01                	cmp    $0x1,%al
  8004208dd0:	75 07                	jne    8004208dd9 <_dwarf_elf_get_pointer_size+0x63>
		return (4);
  8004208dd2:	b8 04 00 00 00       	mov    $0x4,%eax
  8004208dd7:	eb 05                	jmp    8004208dde <_dwarf_elf_get_pointer_size+0x68>
	else
		return (8);
  8004208dd9:	b8 08 00 00 00       	mov    $0x8,%eax
}
  8004208dde:	c9                   	leaveq 
  8004208ddf:	c3                   	retq   

0000008004208de0 <_dwarf_init>:

//Return 0 on success
int _dwarf_init(Dwarf_Debug dbg, void *obj)
{
  8004208de0:	55                   	push   %rbp
  8004208de1:	48 89 e5             	mov    %rsp,%rbp
  8004208de4:	53                   	push   %rbx
  8004208de5:	48 83 ec 18          	sub    $0x18,%rsp
  8004208de9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208ded:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	memset(dbg, 0, sizeof(struct _Dwarf_Debug));
  8004208df1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208df5:	ba 60 00 00 00       	mov    $0x60,%edx
  8004208dfa:	be 00 00 00 00       	mov    $0x0,%esi
  8004208dff:	48 89 c7             	mov    %rax,%rdi
  8004208e02:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  8004208e09:	00 00 00 
  8004208e0c:	ff d0                	callq  *%rax
	dbg->curr_off_dbginfo = 0;
  8004208e0e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e12:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
	dbg->dbg_info_size = 0;
  8004208e19:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e1d:	48 c7 40 10 00 00 00 	movq   $0x0,0x10(%rax)
  8004208e24:	00 
	dbg->dbg_pointer_size = _dwarf_elf_get_pointer_size(obj); 
  8004208e25:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208e29:	48 89 c7             	mov    %rax,%rdi
  8004208e2c:	48 b8 76 8d 20 04 80 	movabs $0x8004208d76,%rax
  8004208e33:	00 00 00 
  8004208e36:	ff d0                	callq  *%rax
  8004208e38:	0f b6 d0             	movzbl %al,%edx
  8004208e3b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e3f:	89 50 28             	mov    %edx,0x28(%rax)

	if (_dwarf_elf_get_byte_order(obj) == DW_OBJECT_MSB) {
  8004208e42:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208e46:	48 89 c7             	mov    %rax,%rdi
  8004208e49:	48 b8 08 8d 20 04 80 	movabs $0x8004208d08,%rax
  8004208e50:	00 00 00 
  8004208e53:	ff d0                	callq  *%rax
  8004208e55:	85 c0                	test   %eax,%eax
  8004208e57:	75 26                	jne    8004208e7f <_dwarf_init+0x9f>
		dbg->read = _dwarf_read_msb;
  8004208e59:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e5d:	48 b9 ad 86 20 04 80 	movabs $0x80042086ad,%rcx
  8004208e64:	00 00 00 
  8004208e67:	48 89 48 18          	mov    %rcx,0x18(%rax)
		dbg->decode = _dwarf_decode_msb;
  8004208e6b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e6f:	48 bb 5f 88 20 04 80 	movabs $0x800420885f,%rbx
  8004208e76:	00 00 00 
  8004208e79:	48 89 58 20          	mov    %rbx,0x20(%rax)
  8004208e7d:	eb 24                	jmp    8004208ea3 <_dwarf_init+0xc3>
	} else {
		dbg->read = _dwarf_read_lsb;
  8004208e7f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e83:	48 b9 60 84 20 04 80 	movabs $0x8004208460,%rcx
  8004208e8a:	00 00 00 
  8004208e8d:	48 89 48 18          	mov    %rcx,0x18(%rax)
		dbg->decode = _dwarf_decode_lsb;
  8004208e91:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208e95:	48 be 8c 85 20 04 80 	movabs $0x800420858c,%rsi
  8004208e9c:	00 00 00 
  8004208e9f:	48 89 70 20          	mov    %rsi,0x20(%rax)
	}
	_dwarf_frame_params_init(dbg);
  8004208ea3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208ea7:	48 89 c7             	mov    %rax,%rdi
  8004208eaa:	48 b8 ad a3 20 04 80 	movabs $0x800420a3ad,%rax
  8004208eb1:	00 00 00 
  8004208eb4:	ff d0                	callq  *%rax
	return 0;
  8004208eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004208ebb:	48 83 c4 18          	add    $0x18,%rsp
  8004208ebf:	5b                   	pop    %rbx
  8004208ec0:	5d                   	pop    %rbp
  8004208ec1:	c3                   	retq   

0000008004208ec2 <_get_next_cu>:

//Return 0 on success
int _get_next_cu(Dwarf_Debug dbg, Dwarf_CU *cu)
{
  8004208ec2:	55                   	push   %rbp
  8004208ec3:	48 89 e5             	mov    %rsp,%rbp
  8004208ec6:	48 83 ec 20          	sub    $0x20,%rsp
  8004208eca:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004208ece:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	uint32_t length;
	uint64_t offset;
	uint8_t dwarf_size;

	if(dbg->curr_off_dbginfo > dbg->dbg_info_size)
  8004208ed2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208ed6:	48 8b 10             	mov    (%rax),%rdx
  8004208ed9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208edd:	48 8b 40 10          	mov    0x10(%rax),%rax
  8004208ee1:	48 39 c2             	cmp    %rax,%rdx
  8004208ee4:	76 0a                	jbe    8004208ef0 <_get_next_cu+0x2e>
		return -1;
  8004208ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004208eeb:	e9 6b 01 00 00       	jmpq   800420905b <_get_next_cu+0x199>

	offset = dbg->curr_off_dbginfo;
  8004208ef0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208ef4:	48 8b 00             	mov    (%rax),%rax
  8004208ef7:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	cu->cu_offset = offset;
  8004208efb:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004208eff:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208f03:	48 89 50 30          	mov    %rdx,0x30(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset,4);
  8004208f07:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208f0b:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208f0f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208f13:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004208f17:	48 89 d1             	mov    %rdx,%rcx
  8004208f1a:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004208f1e:	ba 04 00 00 00       	mov    $0x4,%edx
  8004208f23:	48 89 cf             	mov    %rcx,%rdi
  8004208f26:	ff d0                	callq  *%rax
  8004208f28:	89 45 fc             	mov    %eax,-0x4(%rbp)
	if (length == 0xffffffff) {
  8004208f2b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%rbp)
  8004208f2f:	75 2a                	jne    8004208f5b <_get_next_cu+0x99>
		length = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 8);
  8004208f31:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208f35:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208f39:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208f3d:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004208f41:	48 89 d1             	mov    %rdx,%rcx
  8004208f44:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004208f48:	ba 08 00 00 00       	mov    $0x8,%edx
  8004208f4d:	48 89 cf             	mov    %rcx,%rdi
  8004208f50:	ff d0                	callq  *%rax
  8004208f52:	89 45 fc             	mov    %eax,-0x4(%rbp)
		dwarf_size = 8;
  8004208f55:	c6 45 fb 08          	movb   $0x8,-0x5(%rbp)
  8004208f59:	eb 04                	jmp    8004208f5f <_get_next_cu+0x9d>
	} else {
		dwarf_size = 4;
  8004208f5b:	c6 45 fb 04          	movb   $0x4,-0x5(%rbp)
	}

	cu->cu_dwarf_size = dwarf_size;
  8004208f5f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208f63:	0f b6 55 fb          	movzbl -0x5(%rbp),%edx
  8004208f67:	88 50 19             	mov    %dl,0x19(%rax)
	 if (length > ds->ds_size - offset) {
	 return (DW_DLE_CU_LENGTH_ERROR);
	 }*/

	/* Compute the offset to the next compilation unit: */
	dbg->curr_off_dbginfo = offset + length;
  8004208f6a:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004208f6d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004208f71:	48 01 c2             	add    %rax,%rdx
  8004208f74:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208f78:	48 89 10             	mov    %rdx,(%rax)
	cu->cu_next_offset   = dbg->curr_off_dbginfo;
  8004208f7b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208f7f:	48 8b 10             	mov    (%rax),%rdx
  8004208f82:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208f86:	48 89 50 20          	mov    %rdx,0x20(%rax)

	/* Initialise the compilation unit. */
	cu->cu_length = (uint64_t)length;
  8004208f8a:	8b 55 fc             	mov    -0x4(%rbp),%edx
  8004208f8d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208f91:	48 89 10             	mov    %rdx,(%rax)

	cu->cu_length_size   = (dwarf_size == 4 ? 4 : 12);
  8004208f94:	80 7d fb 04          	cmpb   $0x4,-0x5(%rbp)
  8004208f98:	75 07                	jne    8004208fa1 <_get_next_cu+0xdf>
  8004208f9a:	b8 04 00 00 00       	mov    $0x4,%eax
  8004208f9f:	eb 05                	jmp    8004208fa6 <_get_next_cu+0xe4>
  8004208fa1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8004208fa6:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004208faa:	88 42 18             	mov    %al,0x18(%rdx)
	cu->version              = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 2);
  8004208fad:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208fb1:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208fb5:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004208fb9:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  8004208fbd:	48 89 d1             	mov    %rdx,%rcx
  8004208fc0:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004208fc4:	ba 02 00 00 00       	mov    $0x2,%edx
  8004208fc9:	48 89 cf             	mov    %rcx,%rdi
  8004208fcc:	ff d0                	callq  *%rax
  8004208fce:	89 c2                	mov    %eax,%edx
  8004208fd0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004208fd4:	66 89 50 08          	mov    %dx,0x8(%rax)
	cu->debug_abbrev_offset  = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, dwarf_size);
  8004208fd8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004208fdc:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004208fe0:	0f b6 55 fb          	movzbl -0x5(%rbp),%edx
  8004208fe4:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004208fe8:	48 8b 49 08          	mov    0x8(%rcx),%rcx
  8004208fec:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004208ff0:	48 89 cf             	mov    %rcx,%rdi
  8004208ff3:	ff d0                	callq  *%rax
  8004208ff5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  8004208ff9:	48 89 42 10          	mov    %rax,0x10(%rdx)
	//cu->cu_abbrev_offset_cur = cu->cu_abbrev_offset;
	cu->addr_size  = dbg->read((uint8_t *)dbg->dbg_info_offset_elf, &offset, 1);
  8004208ffd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209001:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209005:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004209009:	48 8b 52 08          	mov    0x8(%rdx),%rdx
  800420900d:	48 89 d1             	mov    %rdx,%rcx
  8004209010:	48 8d 75 f0          	lea    -0x10(%rbp),%rsi
  8004209014:	ba 01 00 00 00       	mov    $0x1,%edx
  8004209019:	48 89 cf             	mov    %rcx,%rdi
  800420901c:	ff d0                	callq  *%rax
  800420901e:	89 c2                	mov    %eax,%edx
  8004209020:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004209024:	88 50 0a             	mov    %dl,0xa(%rax)

	if (cu->version < 2 || cu->version > 4) {
  8004209027:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420902b:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420902f:	66 83 f8 01          	cmp    $0x1,%ax
  8004209033:	76 0e                	jbe    8004209043 <_get_next_cu+0x181>
  8004209035:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004209039:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  800420903d:	66 83 f8 04          	cmp    $0x4,%ax
  8004209041:	76 07                	jbe    800420904a <_get_next_cu+0x188>
		return -1;
  8004209043:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004209048:	eb 11                	jmp    800420905b <_get_next_cu+0x199>
	}

	cu->cu_die_offset = offset;
  800420904a:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420904e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  8004209052:	48 89 50 28          	mov    %rdx,0x28(%rax)

	return 0;
  8004209056:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420905b:	c9                   	leaveq 
  800420905c:	c3                   	retq   

000000800420905d <print_cu>:

void print_cu(Dwarf_CU cu)
{
  800420905d:	55                   	push   %rbp
  800420905e:	48 89 e5             	mov    %rsp,%rbp
	cprintf("%ld---%du--%d\n",cu.cu_length,cu.version,cu.addr_size);
  8004209061:	0f b6 45 1a          	movzbl 0x1a(%rbp),%eax
  8004209065:	0f b6 c8             	movzbl %al,%ecx
  8004209068:	0f b7 45 18          	movzwl 0x18(%rbp),%eax
  800420906c:	0f b7 d0             	movzwl %ax,%edx
  800420906f:	48 8b 45 10          	mov    0x10(%rbp),%rax
  8004209073:	48 89 c6             	mov    %rax,%rsi
  8004209076:	48 bf 72 fb 20 04 80 	movabs $0x800420fb72,%rdi
  800420907d:	00 00 00 
  8004209080:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209085:	49 b8 50 64 20 04 80 	movabs $0x8004206450,%r8
  800420908c:	00 00 00 
  800420908f:	41 ff d0             	callq  *%r8
}
  8004209092:	5d                   	pop    %rbp
  8004209093:	c3                   	retq   

0000008004209094 <_dwarf_abbrev_parse>:

//Return 0 on success
int
_dwarf_abbrev_parse(Dwarf_Debug dbg, Dwarf_CU cu, Dwarf_Unsigned *offset,
		    Dwarf_Abbrev *abp, Dwarf_Section *ds)
{
  8004209094:	55                   	push   %rbp
  8004209095:	48 89 e5             	mov    %rsp,%rbp
  8004209098:	48 83 ec 60          	sub    $0x60,%rsp
  800420909c:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
  80042090a0:	48 89 75 b0          	mov    %rsi,-0x50(%rbp)
  80042090a4:	48 89 55 a8          	mov    %rdx,-0x58(%rbp)
  80042090a8:	48 89 4d a0          	mov    %rcx,-0x60(%rbp)
	uint64_t tag;
	uint8_t children;
	uint64_t abbr_addr;
	int ret;

	assert(abp != NULL);
  80042090ac:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  80042090b1:	75 35                	jne    80042090e8 <_dwarf_abbrev_parse+0x54>
  80042090b3:	48 b9 81 fb 20 04 80 	movabs $0x800420fb81,%rcx
  80042090ba:	00 00 00 
  80042090bd:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  80042090c4:	00 00 00 
  80042090c7:	be a4 01 00 00       	mov    $0x1a4,%esi
  80042090cc:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  80042090d3:	00 00 00 
  80042090d6:	b8 00 00 00 00       	mov    $0x0,%eax
  80042090db:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  80042090e2:	00 00 00 
  80042090e5:	41 ff d0             	callq  *%r8
	assert(ds != NULL);
  80042090e8:	48 83 7d a0 00       	cmpq   $0x0,-0x60(%rbp)
  80042090ed:	75 35                	jne    8004209124 <_dwarf_abbrev_parse+0x90>
  80042090ef:	48 b9 8d fb 20 04 80 	movabs $0x800420fb8d,%rcx
  80042090f6:	00 00 00 
  80042090f9:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209100:	00 00 00 
  8004209103:	be a5 01 00 00       	mov    $0x1a5,%esi
  8004209108:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420910f:	00 00 00 
  8004209112:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209117:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420911e:	00 00 00 
  8004209121:	41 ff d0             	callq  *%r8

	if (*offset >= ds->ds_size)
  8004209124:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004209128:	48 8b 10             	mov    (%rax),%rdx
  800420912b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420912f:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209133:	48 39 c2             	cmp    %rax,%rdx
  8004209136:	72 0a                	jb     8004209142 <_dwarf_abbrev_parse+0xae>
        	return (DW_DLE_NO_ENTRY);
  8004209138:	b8 04 00 00 00       	mov    $0x4,%eax
  800420913d:	e9 d3 01 00 00       	jmpq   8004209315 <_dwarf_abbrev_parse+0x281>

	aboff = *offset;
  8004209142:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004209146:	48 8b 00             	mov    (%rax),%rax
  8004209149:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	abbr_addr = (uint64_t)ds->ds_data; //(uint64_t)((uint8_t *)elf_base_ptr + ds->sh_offset);
  800420914d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  8004209151:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004209155:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	entry = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  8004209159:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420915d:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004209161:	48 89 d6             	mov    %rdx,%rsi
  8004209164:	48 89 c7             	mov    %rax,%rdi
  8004209167:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420916e:	00 00 00 
  8004209171:	ff d0                	callq  *%rax
  8004209173:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	if (entry == 0) {
  8004209177:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420917c:	75 15                	jne    8004209193 <_dwarf_abbrev_parse+0xff>
		/* Last entry. */
		//Need to make connection from below function
		abp->ab_entry = 0;
  800420917e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004209182:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
		return DW_DLE_NONE;
  8004209189:	b8 00 00 00 00       	mov    $0x0,%eax
  800420918e:	e9 82 01 00 00       	jmpq   8004209315 <_dwarf_abbrev_parse+0x281>
	}

	tag = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  8004209193:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004209197:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  800420919b:	48 89 d6             	mov    %rdx,%rsi
  800420919e:	48 89 c7             	mov    %rax,%rdi
  80042091a1:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  80042091a8:	00 00 00 
  80042091ab:	ff d0                	callq  *%rax
  80042091ad:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	children = dbg->read((uint8_t *)abbr_addr, offset, 1);
  80042091b1:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  80042091b5:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042091b9:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
  80042091bd:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  80042091c1:	ba 01 00 00 00       	mov    $0x1,%edx
  80042091c6:	48 89 cf             	mov    %rcx,%rdi
  80042091c9:	ff d0                	callq  *%rax
  80042091cb:	88 45 df             	mov    %al,-0x21(%rbp)

	abp->ab_entry    = entry;
  80042091ce:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042091d2:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  80042091d6:	48 89 10             	mov    %rdx,(%rax)
	abp->ab_tag      = tag;
  80042091d9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042091dd:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  80042091e1:	48 89 50 08          	mov    %rdx,0x8(%rax)
	abp->ab_children = children;
  80042091e5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042091e9:	0f b6 55 df          	movzbl -0x21(%rbp),%edx
  80042091ed:	88 50 10             	mov    %dl,0x10(%rax)
	abp->ab_offset   = aboff;
  80042091f0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042091f4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  80042091f8:	48 89 50 18          	mov    %rdx,0x18(%rax)
	abp->ab_length   = 0;    /* fill in later. */
  80042091fc:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004209200:	48 c7 40 20 00 00 00 	movq   $0x0,0x20(%rax)
  8004209207:	00 
	abp->ab_atnum    = 0;
  8004209208:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420920c:	48 c7 40 28 00 00 00 	movq   $0x0,0x28(%rax)
  8004209213:	00 

	/* Parse attribute definitions. */
	do {
		adoff = *offset;
  8004209214:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  8004209218:	48 8b 00             	mov    (%rax),%rax
  800420921b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		attr = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  800420921f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004209223:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004209227:	48 89 d6             	mov    %rdx,%rsi
  800420922a:	48 89 c7             	mov    %rax,%rdi
  800420922d:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  8004209234:	00 00 00 
  8004209237:	ff d0                	callq  *%rax
  8004209239:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
		form = _dwarf_read_uleb128((uint8_t *)abbr_addr, offset);
  800420923d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  8004209241:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004209245:	48 89 d6             	mov    %rdx,%rsi
  8004209248:	48 89 c7             	mov    %rax,%rdi
  800420924b:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  8004209252:	00 00 00 
  8004209255:	ff d0                	callq  *%rax
  8004209257:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
		if (attr != 0)
  800420925b:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004209260:	0f 84 89 00 00 00    	je     80042092ef <_dwarf_abbrev_parse+0x25b>
		{
			/* Initialise the attribute definition structure. */
			abp->ab_attrdef[abp->ab_atnum].ad_attrib = attr;
  8004209266:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420926a:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420926e:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8004209272:	48 89 d0             	mov    %rdx,%rax
  8004209275:	48 01 c0             	add    %rax,%rax
  8004209278:	48 01 d0             	add    %rdx,%rax
  800420927b:	48 c1 e0 03          	shl    $0x3,%rax
  800420927f:	48 01 c8             	add    %rcx,%rax
  8004209282:	48 8d 50 30          	lea    0x30(%rax),%rdx
  8004209286:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420928a:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_attrdef[abp->ab_atnum].ad_form   = form;
  800420928d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  8004209291:	48 8b 50 28          	mov    0x28(%rax),%rdx
  8004209295:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  8004209299:	48 89 d0             	mov    %rdx,%rax
  800420929c:	48 01 c0             	add    %rax,%rax
  800420929f:	48 01 d0             	add    %rdx,%rax
  80042092a2:	48 c1 e0 03          	shl    $0x3,%rax
  80042092a6:	48 01 c8             	add    %rcx,%rax
  80042092a9:	48 8d 50 38          	lea    0x38(%rax),%rdx
  80042092ad:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  80042092b1:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_attrdef[abp->ab_atnum].ad_offset = adoff;
  80042092b4:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042092b8:	48 8b 50 28          	mov    0x28(%rax),%rdx
  80042092bc:	48 8b 4d a8          	mov    -0x58(%rbp),%rcx
  80042092c0:	48 89 d0             	mov    %rdx,%rax
  80042092c3:	48 01 c0             	add    %rax,%rax
  80042092c6:	48 01 d0             	add    %rdx,%rax
  80042092c9:	48 c1 e0 03          	shl    $0x3,%rax
  80042092cd:	48 01 c8             	add    %rcx,%rax
  80042092d0:	48 8d 50 40          	lea    0x40(%rax),%rdx
  80042092d4:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  80042092d8:	48 89 02             	mov    %rax,(%rdx)
			abp->ab_atnum++;
  80042092db:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042092df:	48 8b 40 28          	mov    0x28(%rax),%rax
  80042092e3:	48 8d 50 01          	lea    0x1(%rax),%rdx
  80042092e7:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  80042092eb:	48 89 50 28          	mov    %rdx,0x28(%rax)
		}
	} while (attr != 0);
  80042092ef:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  80042092f4:	0f 85 1a ff ff ff    	jne    8004209214 <_dwarf_abbrev_parse+0x180>

	//(*abp)->ab_length = *offset - aboff;
	abp->ab_length = (uint64_t)(*offset - aboff);
  80042092fa:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  80042092fe:	48 8b 00             	mov    (%rax),%rax
  8004209301:	48 2b 45 f8          	sub    -0x8(%rbp),%rax
  8004209305:	48 89 c2             	mov    %rax,%rdx
  8004209308:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420930c:	48 89 50 20          	mov    %rdx,0x20(%rax)

	return DW_DLV_OK;
  8004209310:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004209315:	c9                   	leaveq 
  8004209316:	c3                   	retq   

0000008004209317 <_dwarf_abbrev_find>:

//Return 0 on success
int
_dwarf_abbrev_find(Dwarf_Debug dbg, Dwarf_CU cu, uint64_t entry, Dwarf_Abbrev *abp)
{
  8004209317:	55                   	push   %rbp
  8004209318:	48 89 e5             	mov    %rsp,%rbp
  800420931b:	48 83 ec 70          	sub    $0x70,%rsp
  800420931f:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004209323:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8004209327:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
	Dwarf_Section *ds;
	uint64_t offset;
	int ret;

	if (entry == 0)
  800420932b:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  8004209330:	75 0a                	jne    800420933c <_dwarf_abbrev_find+0x25>
	{
		return (DW_DLE_NO_ENTRY);
  8004209332:	b8 04 00 00 00       	mov    $0x4,%eax
  8004209337:	e9 0a 01 00 00       	jmpq   8004209446 <_dwarf_abbrev_find+0x12f>
	}

	/* Load and search the abbrev table. */
	ds = _dwarf_find_section(".debug_abbrev");
  800420933c:	48 bf 98 fb 20 04 80 	movabs $0x800420fb98,%rdi
  8004209343:	00 00 00 
  8004209346:	48 b8 77 d6 20 04 80 	movabs $0x800420d677,%rax
  800420934d:	00 00 00 
  8004209350:	ff d0                	callq  *%rax
  8004209352:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	assert(ds != NULL);
  8004209356:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420935b:	75 35                	jne    8004209392 <_dwarf_abbrev_find+0x7b>
  800420935d:	48 b9 8d fb 20 04 80 	movabs $0x800420fb8d,%rcx
  8004209364:	00 00 00 
  8004209367:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420936e:	00 00 00 
  8004209371:	be e5 01 00 00       	mov    $0x1e5,%esi
  8004209376:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420937d:	00 00 00 
  8004209380:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209385:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420938c:	00 00 00 
  800420938f:	41 ff d0             	callq  *%r8

	//TODO: We are starting offset from 0, however libdwarf logic
	//      is keeping a counter for current offset. Ok. let use
	//      that. I relent, but this will be done in Phase 2. :)
	//offset = 0; //cu->cu_abbrev_offset_cur;
	offset = cu.debug_abbrev_offset; //cu->cu_abbrev_offset_cur;
  8004209392:	48 8b 45 20          	mov    0x20(%rbp),%rax
  8004209396:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	while (offset < ds->ds_size) {
  800420939a:	e9 8d 00 00 00       	jmpq   800420942c <_dwarf_abbrev_find+0x115>
		ret = _dwarf_abbrev_parse(dbg, cu, &offset, abp, ds);
  800420939f:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  80042093a3:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  80042093a7:	48 8d 75 e8          	lea    -0x18(%rbp),%rsi
  80042093ab:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  80042093af:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  80042093b3:	48 89 3c 24          	mov    %rdi,(%rsp)
  80042093b7:	48 8b 7d 18          	mov    0x18(%rbp),%rdi
  80042093bb:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  80042093c0:	48 8b 7d 20          	mov    0x20(%rbp),%rdi
  80042093c4:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  80042093c9:	48 8b 7d 28          	mov    0x28(%rbp),%rdi
  80042093cd:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  80042093d2:	48 8b 7d 30          	mov    0x30(%rbp),%rdi
  80042093d6:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  80042093db:	48 8b 7d 38          	mov    0x38(%rbp),%rdi
  80042093df:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  80042093e4:	48 8b 7d 40          	mov    0x40(%rbp),%rdi
  80042093e8:	48 89 7c 24 30       	mov    %rdi,0x30(%rsp)
  80042093ed:	48 89 c7             	mov    %rax,%rdi
  80042093f0:	48 b8 94 90 20 04 80 	movabs $0x8004209094,%rax
  80042093f7:	00 00 00 
  80042093fa:	ff d0                	callq  *%rax
  80042093fc:	89 45 f4             	mov    %eax,-0xc(%rbp)
		if (ret != DW_DLE_NONE)
  80042093ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
  8004209403:	74 05                	je     800420940a <_dwarf_abbrev_find+0xf3>
			return (ret);
  8004209405:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209408:	eb 3c                	jmp    8004209446 <_dwarf_abbrev_find+0x12f>
		if (abp->ab_entry == entry) {
  800420940a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420940e:	48 8b 00             	mov    (%rax),%rax
  8004209411:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  8004209415:	75 07                	jne    800420941e <_dwarf_abbrev_find+0x107>
			//cu->cu_abbrev_offset_cur = offset;
			return DW_DLE_NONE;
  8004209417:	b8 00 00 00 00       	mov    $0x0,%eax
  800420941c:	eb 28                	jmp    8004209446 <_dwarf_abbrev_find+0x12f>
		}
		if (abp->ab_entry == 0) {
  800420941e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8004209422:	48 8b 00             	mov    (%rax),%rax
  8004209425:	48 85 c0             	test   %rax,%rax
  8004209428:	75 02                	jne    800420942c <_dwarf_abbrev_find+0x115>
			//cu->cu_abbrev_offset_cur = offset;
			//cu->cu_abbrev_loaded = 1;
			break;
  800420942a:	eb 15                	jmp    8004209441 <_dwarf_abbrev_find+0x12a>
	//TODO: We are starting offset from 0, however libdwarf logic
	//      is keeping a counter for current offset. Ok. let use
	//      that. I relent, but this will be done in Phase 2. :)
	//offset = 0; //cu->cu_abbrev_offset_cur;
	offset = cu.debug_abbrev_offset; //cu->cu_abbrev_offset_cur;
	while (offset < ds->ds_size) {
  800420942c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8004209430:	48 8b 50 18          	mov    0x18(%rax),%rdx
  8004209434:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209438:	48 39 c2             	cmp    %rax,%rdx
  800420943b:	0f 87 5e ff ff ff    	ja     800420939f <_dwarf_abbrev_find+0x88>
			//cu->cu_abbrev_loaded = 1;
			break;
		}
	}

	return DW_DLE_NO_ENTRY;
  8004209441:	b8 04 00 00 00       	mov    $0x4,%eax
}
  8004209446:	c9                   	leaveq 
  8004209447:	c3                   	retq   

0000008004209448 <_dwarf_attr_init>:

//Return 0 on success
int
_dwarf_attr_init(Dwarf_Debug dbg, uint64_t *offsetp, Dwarf_CU *cu, Dwarf_Die *ret_die, Dwarf_AttrDef *ad,
		 uint64_t form, int indirect)
{
  8004209448:	55                   	push   %rbp
  8004209449:	48 89 e5             	mov    %rsp,%rbp
  800420944c:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8004209453:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  800420945a:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  8004209461:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  8004209468:	48 89 8d 50 ff ff ff 	mov    %rcx,-0xb0(%rbp)
  800420946f:	4c 89 85 48 ff ff ff 	mov    %r8,-0xb8(%rbp)
  8004209476:	4c 89 8d 40 ff ff ff 	mov    %r9,-0xc0(%rbp)
	struct _Dwarf_Attribute atref;
	Dwarf_Section *str;
	int ret;
	Dwarf_Section *ds = _dwarf_find_section(".debug_info");
  800420947d:	48 bf a6 fb 20 04 80 	movabs $0x800420fba6,%rdi
  8004209484:	00 00 00 
  8004209487:	48 b8 77 d6 20 04 80 	movabs $0x800420d677,%rax
  800420948e:	00 00 00 
  8004209491:	ff d0                	callq  *%rax
  8004209493:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	uint8_t *ds_data = (uint8_t *)ds->ds_data; //(uint8_t *)dbg->dbg_info_offset_elf;
  8004209497:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420949b:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420949f:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uint8_t dwarf_size = cu->cu_dwarf_size;
  80042094a3:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80042094aa:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  80042094ae:	88 45 e7             	mov    %al,-0x19(%rbp)

	ret = DW_DLE_NONE;
  80042094b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
	memset(&atref, 0, sizeof(atref));
  80042094b8:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  80042094bf:	ba 60 00 00 00       	mov    $0x60,%edx
  80042094c4:	be 00 00 00 00       	mov    $0x0,%esi
  80042094c9:	48 89 c7             	mov    %rax,%rdi
  80042094cc:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  80042094d3:	00 00 00 
  80042094d6:	ff d0                	callq  *%rax
	atref.at_die = ret_die;
  80042094d8:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  80042094df:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
	atref.at_attrib = ad->ad_attrib;
  80042094e6:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  80042094ed:	48 8b 00             	mov    (%rax),%rax
  80042094f0:	48 89 45 80          	mov    %rax,-0x80(%rbp)
	atref.at_form = ad->ad_form;
  80042094f4:	48 8b 85 48 ff ff ff 	mov    -0xb8(%rbp),%rax
  80042094fb:	48 8b 40 08          	mov    0x8(%rax),%rax
  80042094ff:	48 89 45 88          	mov    %rax,-0x78(%rbp)
	atref.at_indirect = indirect;
  8004209503:	8b 45 10             	mov    0x10(%rbp),%eax
  8004209506:	89 45 90             	mov    %eax,-0x70(%rbp)
	atref.at_ld = NULL;
  8004209509:	48 c7 45 b8 00 00 00 	movq   $0x0,-0x48(%rbp)
  8004209510:	00 

	switch (form) {
  8004209511:	48 83 bd 40 ff ff ff 	cmpq   $0x20,-0xc0(%rbp)
  8004209518:	20 
  8004209519:	0f 87 82 04 00 00    	ja     80042099a1 <_dwarf_attr_init+0x559>
  800420951f:	48 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%rax
  8004209526:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420952d:	00 
  800420952e:	48 b8 d0 fb 20 04 80 	movabs $0x800420fbd0,%rax
  8004209535:	00 00 00 
  8004209538:	48 01 d0             	add    %rdx,%rax
  800420953b:	48 8b 00             	mov    (%rax),%rax
  800420953e:	ff e0                	jmpq   *%rax
	case DW_FORM_addr:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, cu->addr_size);
  8004209540:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209547:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420954b:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  8004209552:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  8004209556:	0f b6 d2             	movzbl %dl,%edx
  8004209559:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004209560:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209564:	48 89 cf             	mov    %rcx,%rdi
  8004209567:	ff d0                	callq  *%rax
  8004209569:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420956d:	e9 37 04 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_block:
	case DW_FORM_exprloc:
		atref.u[0].u64 = _dwarf_read_uleb128(ds_data, offsetp);
  8004209572:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004209579:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420957d:	48 89 d6             	mov    %rdx,%rsi
  8004209580:	48 89 c7             	mov    %rax,%rdi
  8004209583:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420958a:	00 00 00 
  800420958d:	ff d0                	callq  *%rax
  800420958f:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  8004209593:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209597:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  800420959e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042095a2:	48 89 ce             	mov    %rcx,%rsi
  80042095a5:	48 89 c7             	mov    %rax,%rdi
  80042095a8:	48 b8 bf 8c 20 04 80 	movabs $0x8004208cbf,%rax
  80042095af:	00 00 00 
  80042095b2:	ff d0                	callq  *%rax
  80042095b4:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  80042095b8:	e9 ec 03 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_block1:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 1);
  80042095bd:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042095c4:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042095c8:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042095cf:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042095d3:	ba 01 00 00 00       	mov    $0x1,%edx
  80042095d8:	48 89 cf             	mov    %rcx,%rdi
  80042095db:	ff d0                	callq  *%rax
  80042095dd:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  80042095e1:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  80042095e5:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  80042095ec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042095f0:	48 89 ce             	mov    %rcx,%rsi
  80042095f3:	48 89 c7             	mov    %rax,%rdi
  80042095f6:	48 b8 bf 8c 20 04 80 	movabs $0x8004208cbf,%rax
  80042095fd:	00 00 00 
  8004209600:	ff d0                	callq  *%rax
  8004209602:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004209606:	e9 9e 03 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_block2:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 2);
  800420960b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209612:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209616:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420961d:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209621:	ba 02 00 00 00       	mov    $0x2,%edx
  8004209626:	48 89 cf             	mov    %rcx,%rdi
  8004209629:	ff d0                	callq  *%rax
  800420962b:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  800420962f:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209633:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  800420963a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420963e:	48 89 ce             	mov    %rcx,%rsi
  8004209641:	48 89 c7             	mov    %rax,%rdi
  8004209644:	48 b8 bf 8c 20 04 80 	movabs $0x8004208cbf,%rax
  800420964b:	00 00 00 
  800420964e:	ff d0                	callq  *%rax
  8004209650:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004209654:	e9 50 03 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_block4:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 4);
  8004209659:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209660:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209664:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420966b:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420966f:	ba 04 00 00 00       	mov    $0x4,%edx
  8004209674:	48 89 cf             	mov    %rcx,%rdi
  8004209677:	ff d0                	callq  *%rax
  8004209679:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		atref.u[1].u8p = (uint8_t*)_dwarf_read_block(ds_data, offsetp, atref.u[0].u64);
  800420967d:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209681:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  8004209688:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420968c:	48 89 ce             	mov    %rcx,%rsi
  800420968f:	48 89 c7             	mov    %rax,%rdi
  8004209692:	48 b8 bf 8c 20 04 80 	movabs $0x8004208cbf,%rax
  8004209699:	00 00 00 
  800420969c:	ff d0                	callq  *%rax
  800420969e:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  80042096a2:	e9 02 03 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_data1:
	case DW_FORM_flag:
	case DW_FORM_ref1:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 1);
  80042096a7:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042096ae:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042096b2:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042096b9:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042096bd:	ba 01 00 00 00       	mov    $0x1,%edx
  80042096c2:	48 89 cf             	mov    %rcx,%rdi
  80042096c5:	ff d0                	callq  *%rax
  80042096c7:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042096cb:	e9 d9 02 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_data2:
	case DW_FORM_ref2:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 2);
  80042096d0:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042096d7:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042096db:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042096e2:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042096e6:	ba 02 00 00 00       	mov    $0x2,%edx
  80042096eb:	48 89 cf             	mov    %rcx,%rdi
  80042096ee:	ff d0                	callq  *%rax
  80042096f0:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042096f4:	e9 b0 02 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_data4:
	case DW_FORM_ref4:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 4);
  80042096f9:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209700:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209704:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420970b:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420970f:	ba 04 00 00 00       	mov    $0x4,%edx
  8004209714:	48 89 cf             	mov    %rcx,%rdi
  8004209717:	ff d0                	callq  *%rax
  8004209719:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420971d:	e9 87 02 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_data8:
	case DW_FORM_ref8:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, 8);
  8004209722:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209729:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420972d:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004209734:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209738:	ba 08 00 00 00       	mov    $0x8,%edx
  800420973d:	48 89 cf             	mov    %rcx,%rdi
  8004209740:	ff d0                	callq  *%rax
  8004209742:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004209746:	e9 5e 02 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_indirect:
		form = _dwarf_read_uleb128(ds_data, offsetp);
  800420974b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004209752:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209756:	48 89 d6             	mov    %rdx,%rsi
  8004209759:	48 89 c7             	mov    %rax,%rdi
  800420975c:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  8004209763:	00 00 00 
  8004209766:	ff d0                	callq  *%rax
  8004209768:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
		return (_dwarf_attr_init(dbg, offsetp, cu, ret_die, ad, form, 1));
  800420976f:	4c 8b 85 40 ff ff ff 	mov    -0xc0(%rbp),%r8
  8004209776:	48 8b bd 48 ff ff ff 	mov    -0xb8(%rbp),%rdi
  800420977d:	48 8b 8d 50 ff ff ff 	mov    -0xb0(%rbp),%rcx
  8004209784:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  800420978b:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004209792:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209799:	c7 04 24 01 00 00 00 	movl   $0x1,(%rsp)
  80042097a0:	4d 89 c1             	mov    %r8,%r9
  80042097a3:	49 89 f8             	mov    %rdi,%r8
  80042097a6:	48 89 c7             	mov    %rax,%rdi
  80042097a9:	48 b8 48 94 20 04 80 	movabs $0x8004209448,%rax
  80042097b0:	00 00 00 
  80042097b3:	ff d0                	callq  *%rax
  80042097b5:	e9 1d 03 00 00       	jmpq   8004209ad7 <_dwarf_attr_init+0x68f>
	case DW_FORM_ref_addr:
		if (cu->version == 2)
  80042097ba:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  80042097c1:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  80042097c5:	66 83 f8 02          	cmp    $0x2,%ax
  80042097c9:	75 2f                	jne    80042097fa <_dwarf_attr_init+0x3b2>
			atref.u[0].u64 = dbg->read(ds_data, offsetp, cu->addr_size);
  80042097cb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042097d2:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042097d6:	48 8b 95 58 ff ff ff 	mov    -0xa8(%rbp),%rdx
  80042097dd:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  80042097e1:	0f b6 d2             	movzbl %dl,%edx
  80042097e4:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042097eb:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042097ef:	48 89 cf             	mov    %rcx,%rdi
  80042097f2:	ff d0                	callq  *%rax
  80042097f4:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  80042097f8:	eb 39                	jmp    8004209833 <_dwarf_attr_init+0x3eb>
		else if (cu->version == 3)
  80042097fa:	48 8b 85 58 ff ff ff 	mov    -0xa8(%rbp),%rax
  8004209801:	0f b7 40 08          	movzwl 0x8(%rax),%eax
  8004209805:	66 83 f8 03          	cmp    $0x3,%ax
  8004209809:	75 28                	jne    8004209833 <_dwarf_attr_init+0x3eb>
			atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  800420980b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  8004209812:	48 8b 40 18          	mov    0x18(%rax),%rax
  8004209816:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  800420981a:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  8004209821:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209825:	48 89 cf             	mov    %rcx,%rdi
  8004209828:	ff d0                	callq  *%rax
  800420982a:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420982e:	e9 76 01 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
  8004209833:	e9 71 01 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_ref_udata:
	case DW_FORM_udata:
		atref.u[0].u64 = _dwarf_read_uleb128(ds_data, offsetp);
  8004209838:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  800420983f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209843:	48 89 d6             	mov    %rdx,%rsi
  8004209846:	48 89 c7             	mov    %rax,%rdi
  8004209849:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  8004209850:	00 00 00 
  8004209853:	ff d0                	callq  *%rax
  8004209855:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  8004209859:	e9 4b 01 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_sdata:
		atref.u[0].s64 = _dwarf_read_sleb128(ds_data, offsetp);
  800420985e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  8004209865:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209869:	48 89 d6             	mov    %rdx,%rsi
  800420986c:	48 89 c7             	mov    %rax,%rdi
  800420986f:	48 b8 0e 8a 20 04 80 	movabs $0x8004208a0e,%rax
  8004209876:	00 00 00 
  8004209879:	ff d0                	callq  *%rax
  800420987b:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  800420987f:	e9 25 01 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_sec_offset:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  8004209884:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420988b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420988f:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  8004209893:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  800420989a:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420989e:	48 89 cf             	mov    %rcx,%rdi
  80042098a1:	ff d0                	callq  *%rax
  80042098a3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042098a7:	e9 fd 00 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_string:
		atref.u[0].s =(char*) _dwarf_read_string(ds_data, (uint64_t)ds->ds_size, offsetp);
  80042098ac:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  80042098b0:	48 8b 48 18          	mov    0x18(%rax),%rcx
  80042098b4:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  80042098bb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  80042098bf:	48 89 ce             	mov    %rcx,%rsi
  80042098c2:	48 89 c7             	mov    %rax,%rdi
  80042098c5:	48 b8 30 8c 20 04 80 	movabs $0x8004208c30,%rax
  80042098cc:	00 00 00 
  80042098cf:	ff d0                	callq  *%rax
  80042098d1:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		break;
  80042098d5:	e9 cf 00 00 00       	jmpq   80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_strp:
		atref.u[0].u64 = dbg->read(ds_data, offsetp, dwarf_size);
  80042098da:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  80042098e1:	48 8b 40 18          	mov    0x18(%rax),%rax
  80042098e5:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  80042098e9:	48 8b b5 60 ff ff ff 	mov    -0xa0(%rbp),%rsi
  80042098f0:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  80042098f4:	48 89 cf             	mov    %rcx,%rdi
  80042098f7:	ff d0                	callq  *%rax
  80042098f9:	48 89 45 98          	mov    %rax,-0x68(%rbp)
		str = _dwarf_find_section(".debug_str");
  80042098fd:	48 bf b2 fb 20 04 80 	movabs $0x800420fbb2,%rdi
  8004209904:	00 00 00 
  8004209907:	48 b8 77 d6 20 04 80 	movabs $0x800420d677,%rax
  800420990e:	00 00 00 
  8004209911:	ff d0                	callq  *%rax
  8004209913:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
		assert(str != NULL);
  8004209917:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  800420991c:	75 35                	jne    8004209953 <_dwarf_attr_init+0x50b>
  800420991e:	48 b9 bd fb 20 04 80 	movabs $0x800420fbbd,%rcx
  8004209925:	00 00 00 
  8004209928:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420992f:	00 00 00 
  8004209932:	be 51 02 00 00       	mov    $0x251,%esi
  8004209937:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420993e:	00 00 00 
  8004209941:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209946:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420994d:	00 00 00 
  8004209950:	41 ff d0             	callq  *%r8
		//atref.u[1].s = (char *)(elf_base_ptr + str->sh_offset) + atref.u[0].u64;
		atref.u[1].s = (char *)str->ds_data + atref.u[0].u64;
  8004209953:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  8004209957:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420995b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420995f:	48 01 d0             	add    %rdx,%rax
  8004209962:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004209966:	eb 41                	jmp    80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_ref_sig8:
		atref.u[0].u64 = 8;
  8004209968:	48 c7 45 98 08 00 00 	movq   $0x8,-0x68(%rbp)
  800420996f:	00 
		atref.u[1].u8p = (uint8_t*)(_dwarf_read_block(ds_data, offsetp, atref.u[0].u64));
  8004209970:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209974:	48 8b 8d 60 ff ff ff 	mov    -0xa0(%rbp),%rcx
  800420997b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420997f:	48 89 ce             	mov    %rcx,%rsi
  8004209982:	48 89 c7             	mov    %rax,%rdi
  8004209985:	48 b8 bf 8c 20 04 80 	movabs $0x8004208cbf,%rax
  800420998c:	00 00 00 
  800420998f:	ff d0                	callq  *%rax
  8004209991:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
		break;
  8004209995:	eb 12                	jmp    80042099a9 <_dwarf_attr_init+0x561>
	case DW_FORM_flag_present:
		/* This form has no value encoded in the DIE. */
		atref.u[0].u64 = 1;
  8004209997:	48 c7 45 98 01 00 00 	movq   $0x1,-0x68(%rbp)
  800420999e:	00 
		break;
  800420999f:	eb 08                	jmp    80042099a9 <_dwarf_attr_init+0x561>
	default:
		//DWARF_SET_ERROR(dbg, error, DW_DLE_ATTR_FORM_BAD);
		ret = DW_DLE_ATTR_FORM_BAD;
  80042099a1:	c7 45 fc 0e 00 00 00 	movl   $0xe,-0x4(%rbp)
		break;
  80042099a8:	90                   	nop
	}

	if (ret == DW_DLE_NONE) {
  80042099a9:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  80042099ad:	0f 85 21 01 00 00    	jne    8004209ad4 <_dwarf_attr_init+0x68c>
		if (form == DW_FORM_block || form == DW_FORM_block1 ||
  80042099b3:	48 83 bd 40 ff ff ff 	cmpq   $0x9,-0xc0(%rbp)
  80042099ba:	09 
  80042099bb:	74 1e                	je     80042099db <_dwarf_attr_init+0x593>
  80042099bd:	48 83 bd 40 ff ff ff 	cmpq   $0xa,-0xc0(%rbp)
  80042099c4:	0a 
  80042099c5:	74 14                	je     80042099db <_dwarf_attr_init+0x593>
  80042099c7:	48 83 bd 40 ff ff ff 	cmpq   $0x3,-0xc0(%rbp)
  80042099ce:	03 
  80042099cf:	74 0a                	je     80042099db <_dwarf_attr_init+0x593>
		    form == DW_FORM_block2 || form == DW_FORM_block4) {
  80042099d1:	48 83 bd 40 ff ff ff 	cmpq   $0x4,-0xc0(%rbp)
  80042099d8:	04 
  80042099d9:	75 10                	jne    80042099eb <_dwarf_attr_init+0x5a3>
			atref.at_block.bl_len = atref.u[0].u64;
  80042099db:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80042099df:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
			atref.at_block.bl_data = atref.u[1].u8p;
  80042099e3:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  80042099e7:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
		}
		//ret = _dwarf_attr_add(die, &atref, NULL, error);
		if (atref.at_attrib == DW_AT_name) {
  80042099eb:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  80042099ef:	48 83 f8 03          	cmp    $0x3,%rax
  80042099f3:	75 39                	jne    8004209a2e <_dwarf_attr_init+0x5e6>
			switch (atref.at_form) {
  80042099f5:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  80042099f9:	48 83 f8 08          	cmp    $0x8,%rax
  80042099fd:	74 1c                	je     8004209a1b <_dwarf_attr_init+0x5d3>
  80042099ff:	48 83 f8 0e          	cmp    $0xe,%rax
  8004209a03:	74 02                	je     8004209a07 <_dwarf_attr_init+0x5bf>
				break;
			case DW_FORM_string:
				ret_die->die_name = atref.u[0].s;
				break;
			default:
				break;
  8004209a05:	eb 27                	jmp    8004209a2e <_dwarf_attr_init+0x5e6>
		}
		//ret = _dwarf_attr_add(die, &atref, NULL, error);
		if (atref.at_attrib == DW_AT_name) {
			switch (atref.at_form) {
			case DW_FORM_strp:
				ret_die->die_name = atref.u[1].s;
  8004209a07:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004209a0b:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004209a12:	48 89 90 50 03 00 00 	mov    %rdx,0x350(%rax)
				break;
  8004209a19:	eb 13                	jmp    8004209a2e <_dwarf_attr_init+0x5e6>
			case DW_FORM_string:
				ret_die->die_name = atref.u[0].s;
  8004209a1b:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209a1f:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004209a26:	48 89 90 50 03 00 00 	mov    %rdx,0x350(%rax)
				break;
  8004209a2d:	90                   	nop
			default:
				break;
			}
		}
		ret_die->die_attr[ret_die->die_attr_count++] = atref;
  8004209a2e:	48 8b 85 50 ff ff ff 	mov    -0xb0(%rbp),%rax
  8004209a35:	0f b6 80 58 03 00 00 	movzbl 0x358(%rax),%eax
  8004209a3c:	8d 48 01             	lea    0x1(%rax),%ecx
  8004209a3f:	48 8b 95 50 ff ff ff 	mov    -0xb0(%rbp),%rdx
  8004209a46:	88 8a 58 03 00 00    	mov    %cl,0x358(%rdx)
  8004209a4c:	0f b6 c0             	movzbl %al,%eax
  8004209a4f:	48 8b 8d 50 ff ff ff 	mov    -0xb0(%rbp),%rcx
  8004209a56:	48 63 d0             	movslq %eax,%rdx
  8004209a59:	48 89 d0             	mov    %rdx,%rax
  8004209a5c:	48 01 c0             	add    %rax,%rax
  8004209a5f:	48 01 d0             	add    %rdx,%rax
  8004209a62:	48 c1 e0 05          	shl    $0x5,%rax
  8004209a66:	48 01 c8             	add    %rcx,%rax
  8004209a69:	48 05 70 03 00 00    	add    $0x370,%rax
  8004209a6f:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  8004209a76:	48 89 10             	mov    %rdx,(%rax)
  8004209a79:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  8004209a80:	48 89 50 08          	mov    %rdx,0x8(%rax)
  8004209a84:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  8004209a88:	48 89 50 10          	mov    %rdx,0x10(%rax)
  8004209a8c:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  8004209a90:	48 89 50 18          	mov    %rdx,0x18(%rax)
  8004209a94:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  8004209a98:	48 89 50 20          	mov    %rdx,0x20(%rax)
  8004209a9c:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  8004209aa0:	48 89 50 28          	mov    %rdx,0x28(%rax)
  8004209aa4:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  8004209aa8:	48 89 50 30          	mov    %rdx,0x30(%rax)
  8004209aac:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  8004209ab0:	48 89 50 38          	mov    %rdx,0x38(%rax)
  8004209ab4:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  8004209ab8:	48 89 50 40          	mov    %rdx,0x40(%rax)
  8004209abc:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  8004209ac0:	48 89 50 48          	mov    %rdx,0x48(%rax)
  8004209ac4:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004209ac8:	48 89 50 50          	mov    %rdx,0x50(%rax)
  8004209acc:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  8004209ad0:	48 89 50 58          	mov    %rdx,0x58(%rax)
	}

	return (ret);
  8004209ad4:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
  8004209ad7:	c9                   	leaveq 
  8004209ad8:	c3                   	retq   

0000008004209ad9 <dwarf_search_die_within_cu>:

int
dwarf_search_die_within_cu(Dwarf_Debug dbg, Dwarf_CU cu, uint64_t offset, Dwarf_Die *ret_die, int search_sibling)
{
  8004209ad9:	55                   	push   %rbp
  8004209ada:	48 89 e5             	mov    %rsp,%rbp
  8004209add:	48 81 ec d0 03 00 00 	sub    $0x3d0,%rsp
  8004209ae4:	48 89 bd 88 fc ff ff 	mov    %rdi,-0x378(%rbp)
  8004209aeb:	48 89 b5 80 fc ff ff 	mov    %rsi,-0x380(%rbp)
  8004209af2:	48 89 95 78 fc ff ff 	mov    %rdx,-0x388(%rbp)
  8004209af9:	89 8d 74 fc ff ff    	mov    %ecx,-0x38c(%rbp)
	uint64_t abnum;
	uint64_t die_offset;
	int ret, level;
	int i;

	assert(dbg);
  8004209aff:	48 83 bd 88 fc ff ff 	cmpq   $0x0,-0x378(%rbp)
  8004209b06:	00 
  8004209b07:	75 35                	jne    8004209b3e <dwarf_search_die_within_cu+0x65>
  8004209b09:	48 b9 d8 fc 20 04 80 	movabs $0x800420fcd8,%rcx
  8004209b10:	00 00 00 
  8004209b13:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209b1a:	00 00 00 
  8004209b1d:	be 86 02 00 00       	mov    $0x286,%esi
  8004209b22:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209b29:	00 00 00 
  8004209b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209b31:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209b38:	00 00 00 
  8004209b3b:	41 ff d0             	callq  *%r8
	//assert(cu);
	assert(ret_die);
  8004209b3e:	48 83 bd 78 fc ff ff 	cmpq   $0x0,-0x388(%rbp)
  8004209b45:	00 
  8004209b46:	75 35                	jne    8004209b7d <dwarf_search_die_within_cu+0xa4>
  8004209b48:	48 b9 dc fc 20 04 80 	movabs $0x800420fcdc,%rcx
  8004209b4f:	00 00 00 
  8004209b52:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209b59:	00 00 00 
  8004209b5c:	be 88 02 00 00       	mov    $0x288,%esi
  8004209b61:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209b68:	00 00 00 
  8004209b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209b70:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209b77:	00 00 00 
  8004209b7a:	41 ff d0             	callq  *%r8

	level = 1;
  8004209b7d:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)

	while (offset < cu.cu_next_offset && offset < dbg->dbg_info_size) {
  8004209b84:	e9 17 02 00 00       	jmpq   8004209da0 <dwarf_search_die_within_cu+0x2c7>

		die_offset = offset;
  8004209b89:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004209b90:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

		abnum = _dwarf_read_uleb128((uint8_t *)dbg->dbg_info_offset_elf, &offset);
  8004209b94:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004209b9b:	48 8b 40 08          	mov    0x8(%rax),%rax
  8004209b9f:	48 8d 95 80 fc ff ff 	lea    -0x380(%rbp),%rdx
  8004209ba6:	48 89 d6             	mov    %rdx,%rsi
  8004209ba9:	48 89 c7             	mov    %rax,%rdi
  8004209bac:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  8004209bb3:	00 00 00 
  8004209bb6:	ff d0                	callq  *%rax
  8004209bb8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

		if (abnum == 0) {
  8004209bbc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004209bc1:	75 22                	jne    8004209be5 <dwarf_search_die_within_cu+0x10c>
			if (level == 0 || !search_sibling) {
  8004209bc3:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004209bc7:	74 09                	je     8004209bd2 <dwarf_search_die_within_cu+0xf9>
  8004209bc9:	83 bd 74 fc ff ff 00 	cmpl   $0x0,-0x38c(%rbp)
  8004209bd0:	75 0a                	jne    8004209bdc <dwarf_search_die_within_cu+0x103>
				//No more entry
				return (DW_DLE_NO_ENTRY);
  8004209bd2:	b8 04 00 00 00       	mov    $0x4,%eax
  8004209bd7:	e9 f4 01 00 00       	jmpq   8004209dd0 <dwarf_search_die_within_cu+0x2f7>
			}
			/*
			 * Return to previous DIE level.
			 */
			level--;
  8004209bdc:	83 6d fc 01          	subl   $0x1,-0x4(%rbp)
			continue;
  8004209be0:	e9 bb 01 00 00       	jmpq   8004209da0 <dwarf_search_die_within_cu+0x2c7>
		}

		if ((ret = _dwarf_abbrev_find(dbg, cu, abnum, &ab)) != DW_DLE_NONE)
  8004209be5:	48 8d 95 b0 fc ff ff 	lea    -0x350(%rbp),%rdx
  8004209bec:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209bf0:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004209bf7:	48 8b 75 10          	mov    0x10(%rbp),%rsi
  8004209bfb:	48 89 34 24          	mov    %rsi,(%rsp)
  8004209bff:	48 8b 75 18          	mov    0x18(%rbp),%rsi
  8004209c03:	48 89 74 24 08       	mov    %rsi,0x8(%rsp)
  8004209c08:	48 8b 75 20          	mov    0x20(%rbp),%rsi
  8004209c0c:	48 89 74 24 10       	mov    %rsi,0x10(%rsp)
  8004209c11:	48 8b 75 28          	mov    0x28(%rbp),%rsi
  8004209c15:	48 89 74 24 18       	mov    %rsi,0x18(%rsp)
  8004209c1a:	48 8b 75 30          	mov    0x30(%rbp),%rsi
  8004209c1e:	48 89 74 24 20       	mov    %rsi,0x20(%rsp)
  8004209c23:	48 8b 75 38          	mov    0x38(%rbp),%rsi
  8004209c27:	48 89 74 24 28       	mov    %rsi,0x28(%rsp)
  8004209c2c:	48 8b 75 40          	mov    0x40(%rbp),%rsi
  8004209c30:	48 89 74 24 30       	mov    %rsi,0x30(%rsp)
  8004209c35:	48 89 ce             	mov    %rcx,%rsi
  8004209c38:	48 89 c7             	mov    %rax,%rdi
  8004209c3b:	48 b8 17 93 20 04 80 	movabs $0x8004209317,%rax
  8004209c42:	00 00 00 
  8004209c45:	ff d0                	callq  *%rax
  8004209c47:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004209c4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004209c4e:	74 08                	je     8004209c58 <dwarf_search_die_within_cu+0x17f>
			return (ret);
  8004209c50:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004209c53:	e9 78 01 00 00       	jmpq   8004209dd0 <dwarf_search_die_within_cu+0x2f7>
		ret_die->die_offset = die_offset;
  8004209c58:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209c5f:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  8004209c63:	48 89 10             	mov    %rdx,(%rax)
		ret_die->die_abnum  = abnum;
  8004209c66:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209c6d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  8004209c71:	48 89 50 10          	mov    %rdx,0x10(%rax)
		ret_die->die_ab  = ab;
  8004209c75:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209c7c:	48 8d 78 20          	lea    0x20(%rax),%rdi
  8004209c80:	48 8d 95 b0 fc ff ff 	lea    -0x350(%rbp),%rdx
  8004209c87:	b8 66 00 00 00       	mov    $0x66,%eax
  8004209c8c:	48 89 d6             	mov    %rdx,%rsi
  8004209c8f:	48 89 c1             	mov    %rax,%rcx
  8004209c92:	f3 48 a5             	rep movsq %ds:(%rsi),%es:(%rdi)
		ret_die->die_attr_count = 0;
  8004209c95:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209c9c:	c6 80 58 03 00 00 00 	movb   $0x0,0x358(%rax)
		ret_die->die_tag = ab.ab_tag;
  8004209ca3:	48 8b 95 b8 fc ff ff 	mov    -0x348(%rbp),%rdx
  8004209caa:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209cb1:	48 89 50 18          	mov    %rdx,0x18(%rax)
		//ret_die->die_cu  = cu;
		//ret_die->die_dbg = cu->cu_dbg;

		for(i=0; i < ab.ab_atnum; i++)
  8004209cb5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
  8004209cbc:	e9 8e 00 00 00       	jmpq   8004209d4f <dwarf_search_die_within_cu+0x276>
		{
			if ((ret = _dwarf_attr_init(dbg, &offset, &cu, ret_die, &ab.ab_attrdef[i], ab.ab_attrdef[i].ad_form, 0)) != DW_DLE_NONE)
  8004209cc1:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004209cc4:	48 63 d0             	movslq %eax,%rdx
  8004209cc7:	48 89 d0             	mov    %rdx,%rax
  8004209cca:	48 01 c0             	add    %rax,%rax
  8004209ccd:	48 01 d0             	add    %rdx,%rax
  8004209cd0:	48 c1 e0 03          	shl    $0x3,%rax
  8004209cd4:	48 01 e8             	add    %rbp,%rax
  8004209cd7:	48 2d 18 03 00 00    	sub    $0x318,%rax
  8004209cdd:	48 8b 08             	mov    (%rax),%rcx
  8004209ce0:	48 8d b5 b0 fc ff ff 	lea    -0x350(%rbp),%rsi
  8004209ce7:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004209cea:	48 63 d0             	movslq %eax,%rdx
  8004209ced:	48 89 d0             	mov    %rdx,%rax
  8004209cf0:	48 01 c0             	add    %rax,%rax
  8004209cf3:	48 01 d0             	add    %rdx,%rax
  8004209cf6:	48 c1 e0 03          	shl    $0x3,%rax
  8004209cfa:	48 83 c0 30          	add    $0x30,%rax
  8004209cfe:	48 8d 3c 06          	lea    (%rsi,%rax,1),%rdi
  8004209d02:	48 8b 95 78 fc ff ff 	mov    -0x388(%rbp),%rdx
  8004209d09:	48 8d b5 80 fc ff ff 	lea    -0x380(%rbp),%rsi
  8004209d10:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004209d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%rsp)
  8004209d1e:	49 89 c9             	mov    %rcx,%r9
  8004209d21:	49 89 f8             	mov    %rdi,%r8
  8004209d24:	48 89 d1             	mov    %rdx,%rcx
  8004209d27:	48 8d 55 10          	lea    0x10(%rbp),%rdx
  8004209d2b:	48 89 c7             	mov    %rax,%rdi
  8004209d2e:	48 b8 48 94 20 04 80 	movabs $0x8004209448,%rax
  8004209d35:	00 00 00 
  8004209d38:	ff d0                	callq  *%rax
  8004209d3a:	89 45 e4             	mov    %eax,-0x1c(%rbp)
  8004209d3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  8004209d41:	74 08                	je     8004209d4b <dwarf_search_die_within_cu+0x272>
				return (ret);
  8004209d43:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  8004209d46:	e9 85 00 00 00       	jmpq   8004209dd0 <dwarf_search_die_within_cu+0x2f7>
		ret_die->die_attr_count = 0;
		ret_die->die_tag = ab.ab_tag;
		//ret_die->die_cu  = cu;
		//ret_die->die_dbg = cu->cu_dbg;

		for(i=0; i < ab.ab_atnum; i++)
  8004209d4b:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
  8004209d4f:	8b 45 f8             	mov    -0x8(%rbp),%eax
  8004209d52:	48 63 d0             	movslq %eax,%rdx
  8004209d55:	48 8b 85 d8 fc ff ff 	mov    -0x328(%rbp),%rax
  8004209d5c:	48 39 c2             	cmp    %rax,%rdx
  8004209d5f:	0f 82 5c ff ff ff    	jb     8004209cc1 <dwarf_search_die_within_cu+0x1e8>
		{
			if ((ret = _dwarf_attr_init(dbg, &offset, &cu, ret_die, &ab.ab_attrdef[i], ab.ab_attrdef[i].ad_form, 0)) != DW_DLE_NONE)
				return (ret);
		}

		ret_die->die_next_off = offset;
  8004209d65:	48 8b 95 80 fc ff ff 	mov    -0x380(%rbp),%rdx
  8004209d6c:	48 8b 85 78 fc ff ff 	mov    -0x388(%rbp),%rax
  8004209d73:	48 89 50 08          	mov    %rdx,0x8(%rax)
		if (search_sibling && level > 0) {
  8004209d77:	83 bd 74 fc ff ff 00 	cmpl   $0x0,-0x38c(%rbp)
  8004209d7e:	74 19                	je     8004209d99 <dwarf_search_die_within_cu+0x2c0>
  8004209d80:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  8004209d84:	7e 13                	jle    8004209d99 <dwarf_search_die_within_cu+0x2c0>
			//dwarf_dealloc(dbg, die, DW_DLA_DIE);
			if (ab.ab_children == DW_CHILDREN_yes) {
  8004209d86:	0f b6 85 c0 fc ff ff 	movzbl -0x340(%rbp),%eax
  8004209d8d:	3c 01                	cmp    $0x1,%al
  8004209d8f:	75 06                	jne    8004209d97 <dwarf_search_die_within_cu+0x2be>
				/* Advance to next DIE level. */
				level++;
  8004209d91:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
		}

		ret_die->die_next_off = offset;
		if (search_sibling && level > 0) {
			//dwarf_dealloc(dbg, die, DW_DLA_DIE);
			if (ab.ab_children == DW_CHILDREN_yes) {
  8004209d95:	eb 09                	jmp    8004209da0 <dwarf_search_die_within_cu+0x2c7>
  8004209d97:	eb 07                	jmp    8004209da0 <dwarf_search_die_within_cu+0x2c7>
				/* Advance to next DIE level. */
				level++;
			}
		} else {
			//*ret_die = die;
			return (DW_DLE_NONE);
  8004209d99:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209d9e:	eb 30                	jmp    8004209dd0 <dwarf_search_die_within_cu+0x2f7>
	//assert(cu);
	assert(ret_die);

	level = 1;

	while (offset < cu.cu_next_offset && offset < dbg->dbg_info_size) {
  8004209da0:	48 8b 55 30          	mov    0x30(%rbp),%rdx
  8004209da4:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004209dab:	48 39 c2             	cmp    %rax,%rdx
  8004209dae:	76 1b                	jbe    8004209dcb <dwarf_search_die_within_cu+0x2f2>
  8004209db0:	48 8b 85 88 fc ff ff 	mov    -0x378(%rbp),%rax
  8004209db7:	48 8b 50 10          	mov    0x10(%rax),%rdx
  8004209dbb:	48 8b 85 80 fc ff ff 	mov    -0x380(%rbp),%rax
  8004209dc2:	48 39 c2             	cmp    %rax,%rdx
  8004209dc5:	0f 87 be fd ff ff    	ja     8004209b89 <dwarf_search_die_within_cu+0xb0>
			//*ret_die = die;
			return (DW_DLE_NONE);
		}
	}

	return (DW_DLE_NO_ENTRY);
  8004209dcb:	b8 04 00 00 00       	mov    $0x4,%eax
}
  8004209dd0:	c9                   	leaveq 
  8004209dd1:	c3                   	retq   

0000008004209dd2 <dwarf_offdie>:

//Return 0 on success
int
dwarf_offdie(Dwarf_Debug dbg, uint64_t offset, Dwarf_Die *ret_die, Dwarf_CU cu)
{
  8004209dd2:	55                   	push   %rbp
  8004209dd3:	48 89 e5             	mov    %rsp,%rbp
  8004209dd6:	48 83 ec 60          	sub    $0x60,%rsp
  8004209dda:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004209dde:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  8004209de2:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
	int ret;

	assert(dbg);
  8004209de6:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  8004209deb:	75 35                	jne    8004209e22 <dwarf_offdie+0x50>
  8004209ded:	48 b9 d8 fc 20 04 80 	movabs $0x800420fcd8,%rcx
  8004209df4:	00 00 00 
  8004209df7:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209dfe:	00 00 00 
  8004209e01:	be c4 02 00 00       	mov    $0x2c4,%esi
  8004209e06:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209e0d:	00 00 00 
  8004209e10:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209e15:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209e1c:	00 00 00 
  8004209e1f:	41 ff d0             	callq  *%r8
	assert(ret_die);
  8004209e22:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004209e27:	75 35                	jne    8004209e5e <dwarf_offdie+0x8c>
  8004209e29:	48 b9 dc fc 20 04 80 	movabs $0x800420fcdc,%rcx
  8004209e30:	00 00 00 
  8004209e33:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209e3a:	00 00 00 
  8004209e3d:	be c5 02 00 00       	mov    $0x2c5,%esi
  8004209e42:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209e49:	00 00 00 
  8004209e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209e51:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209e58:	00 00 00 
  8004209e5b:	41 ff d0             	callq  *%r8

	/* First search the current CU. */
	if (offset < cu.cu_next_offset) {
  8004209e5e:	48 8b 45 30          	mov    0x30(%rbp),%rax
  8004209e62:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  8004209e66:	76 66                	jbe    8004209ece <dwarf_offdie+0xfc>
		ret = dwarf_search_die_within_cu(dbg, cu, offset, ret_die, 0);
  8004209e68:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  8004209e6c:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
  8004209e70:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209e74:	48 8b 4d 10          	mov    0x10(%rbp),%rcx
  8004209e78:	48 89 0c 24          	mov    %rcx,(%rsp)
  8004209e7c:	48 8b 4d 18          	mov    0x18(%rbp),%rcx
  8004209e80:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  8004209e85:	48 8b 4d 20          	mov    0x20(%rbp),%rcx
  8004209e89:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  8004209e8e:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  8004209e92:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  8004209e97:	48 8b 4d 30          	mov    0x30(%rbp),%rcx
  8004209e9b:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
  8004209ea0:	48 8b 4d 38          	mov    0x38(%rbp),%rcx
  8004209ea4:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
  8004209ea9:	48 8b 4d 40          	mov    0x40(%rbp),%rcx
  8004209ead:	48 89 4c 24 30       	mov    %rcx,0x30(%rsp)
  8004209eb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004209eb7:	48 89 c7             	mov    %rax,%rdi
  8004209eba:	48 b8 d9 9a 20 04 80 	movabs $0x8004209ad9,%rax
  8004209ec1:	00 00 00 
  8004209ec4:	ff d0                	callq  *%rax
  8004209ec6:	89 45 fc             	mov    %eax,-0x4(%rbp)
		return ret;
  8004209ec9:	8b 45 fc             	mov    -0x4(%rbp),%eax
  8004209ecc:	eb 05                	jmp    8004209ed3 <dwarf_offdie+0x101>
	}

	/*TODO: Search other CU*/
	return DW_DLV_OK;
  8004209ece:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8004209ed3:	c9                   	leaveq 
  8004209ed4:	c3                   	retq   

0000008004209ed5 <_dwarf_attr_find>:

Dwarf_Attribute*
_dwarf_attr_find(Dwarf_Die *die, uint16_t attr)
{
  8004209ed5:	55                   	push   %rbp
  8004209ed6:	48 89 e5             	mov    %rsp,%rbp
  8004209ed9:	48 83 ec 1c          	sub    $0x1c,%rsp
  8004209edd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  8004209ee1:	89 f0                	mov    %esi,%eax
  8004209ee3:	66 89 45 e4          	mov    %ax,-0x1c(%rbp)
	Dwarf_Attribute *myat = NULL;
  8004209ee7:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  8004209eee:	00 
	int i;
    
	for(i=0; i < die->die_attr_count; i++)
  8004209eef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  8004209ef6:	eb 57                	jmp    8004209f4f <_dwarf_attr_find+0x7a>
	{
		if (die->die_attr[i].at_attrib == attr)
  8004209ef8:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  8004209efc:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209eff:	48 63 d0             	movslq %eax,%rdx
  8004209f02:	48 89 d0             	mov    %rdx,%rax
  8004209f05:	48 01 c0             	add    %rax,%rax
  8004209f08:	48 01 d0             	add    %rdx,%rax
  8004209f0b:	48 c1 e0 05          	shl    $0x5,%rax
  8004209f0f:	48 01 c8             	add    %rcx,%rax
  8004209f12:	48 05 80 03 00 00    	add    $0x380,%rax
  8004209f18:	48 8b 10             	mov    (%rax),%rdx
  8004209f1b:	0f b7 45 e4          	movzwl -0x1c(%rbp),%eax
  8004209f1f:	48 39 c2             	cmp    %rax,%rdx
  8004209f22:	75 27                	jne    8004209f4b <_dwarf_attr_find+0x76>
		{
			myat = &(die->die_attr[i]);
  8004209f24:	8b 45 f4             	mov    -0xc(%rbp),%eax
  8004209f27:	48 63 d0             	movslq %eax,%rdx
  8004209f2a:	48 89 d0             	mov    %rdx,%rax
  8004209f2d:	48 01 c0             	add    %rax,%rax
  8004209f30:	48 01 d0             	add    %rdx,%rax
  8004209f33:	48 c1 e0 05          	shl    $0x5,%rax
  8004209f37:	48 8d 90 70 03 00 00 	lea    0x370(%rax),%rdx
  8004209f3e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209f42:	48 01 d0             	add    %rdx,%rax
  8004209f45:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			break;
  8004209f49:	eb 17                	jmp    8004209f62 <_dwarf_attr_find+0x8d>
_dwarf_attr_find(Dwarf_Die *die, uint16_t attr)
{
	Dwarf_Attribute *myat = NULL;
	int i;
    
	for(i=0; i < die->die_attr_count; i++)
  8004209f4b:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  8004209f4f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  8004209f53:	0f b6 80 58 03 00 00 	movzbl 0x358(%rax),%eax
  8004209f5a:	0f b6 c0             	movzbl %al,%eax
  8004209f5d:	3b 45 f4             	cmp    -0xc(%rbp),%eax
  8004209f60:	7f 96                	jg     8004209ef8 <_dwarf_attr_find+0x23>
			myat = &(die->die_attr[i]);
			break;
		}
	}

	return myat;
  8004209f62:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  8004209f66:	c9                   	leaveq 
  8004209f67:	c3                   	retq   

0000008004209f68 <dwarf_siblingof>:

//Return 0 on success
int
dwarf_siblingof(Dwarf_Debug dbg, Dwarf_Die *die, Dwarf_Die *ret_die,
		Dwarf_CU *cu)
{
  8004209f68:	55                   	push   %rbp
  8004209f69:	48 89 e5             	mov    %rsp,%rbp
  8004209f6c:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
  8004209f70:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  8004209f74:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  8004209f78:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  8004209f7c:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
	Dwarf_Attribute *at;
	uint64_t offset;
	int ret, search_sibling;

	assert(dbg);
  8004209f80:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  8004209f85:	75 35                	jne    8004209fbc <dwarf_siblingof+0x54>
  8004209f87:	48 b9 d8 fc 20 04 80 	movabs $0x800420fcd8,%rcx
  8004209f8e:	00 00 00 
  8004209f91:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209f98:	00 00 00 
  8004209f9b:	be ec 02 00 00       	mov    $0x2ec,%esi
  8004209fa0:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209fa7:	00 00 00 
  8004209faa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209faf:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209fb6:	00 00 00 
  8004209fb9:	41 ff d0             	callq  *%r8
	assert(ret_die);
  8004209fbc:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  8004209fc1:	75 35                	jne    8004209ff8 <dwarf_siblingof+0x90>
  8004209fc3:	48 b9 dc fc 20 04 80 	movabs $0x800420fcdc,%rcx
  8004209fca:	00 00 00 
  8004209fcd:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  8004209fd4:	00 00 00 
  8004209fd7:	be ed 02 00 00       	mov    $0x2ed,%esi
  8004209fdc:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  8004209fe3:	00 00 00 
  8004209fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004209feb:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  8004209ff2:	00 00 00 
  8004209ff5:	41 ff d0             	callq  *%r8
	assert(cu);
  8004209ff8:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  8004209ffd:	75 35                	jne    800420a034 <dwarf_siblingof+0xcc>
  8004209fff:	48 b9 e4 fc 20 04 80 	movabs $0x800420fce4,%rcx
  800420a006:	00 00 00 
  800420a009:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420a010:	00 00 00 
  800420a013:	be ee 02 00 00       	mov    $0x2ee,%esi
  800420a018:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420a01f:	00 00 00 
  800420a022:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a027:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a02e:	00 00 00 
  800420a031:	41 ff d0             	callq  *%r8

	/* Application requests the first DIE in this CU. */
	if (die == NULL)
  800420a034:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420a039:	75 65                	jne    800420a0a0 <dwarf_siblingof+0x138>
		return (dwarf_offdie(dbg, cu->cu_die_offset, ret_die, *cu));
  800420a03b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420a03f:	48 8b 70 28          	mov    0x28(%rax),%rsi
  800420a043:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420a047:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420a04b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420a04f:	48 8b 38             	mov    (%rax),%rdi
  800420a052:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420a056:	48 8b 78 08          	mov    0x8(%rax),%rdi
  800420a05a:	48 89 7c 24 08       	mov    %rdi,0x8(%rsp)
  800420a05f:	48 8b 78 10          	mov    0x10(%rax),%rdi
  800420a063:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  800420a068:	48 8b 78 18          	mov    0x18(%rax),%rdi
  800420a06c:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  800420a071:	48 8b 78 20          	mov    0x20(%rax),%rdi
  800420a075:	48 89 7c 24 20       	mov    %rdi,0x20(%rsp)
  800420a07a:	48 8b 78 28          	mov    0x28(%rax),%rdi
  800420a07e:	48 89 7c 24 28       	mov    %rdi,0x28(%rsp)
  800420a083:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420a087:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  800420a08c:	48 89 cf             	mov    %rcx,%rdi
  800420a08f:	48 b8 d2 9d 20 04 80 	movabs $0x8004209dd2,%rax
  800420a096:	00 00 00 
  800420a099:	ff d0                	callq  *%rax
  800420a09b:	e9 0a 01 00 00       	jmpq   800420a1aa <dwarf_siblingof+0x242>

	/*
	 * If the DIE doesn't have any children, its sibling sits next
	 * right to it.
	 */
	search_sibling = 0;
  800420a0a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
	if (die->die_ab.ab_children == DW_CHILDREN_no)
  800420a0a7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a0ab:	0f b6 40 30          	movzbl 0x30(%rax),%eax
  800420a0af:	84 c0                	test   %al,%al
  800420a0b1:	75 0e                	jne    800420a0c1 <dwarf_siblingof+0x159>
		offset = die->die_next_off;
  800420a0b3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a0b7:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420a0bb:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420a0bf:	eb 6b                	jmp    800420a12c <dwarf_siblingof+0x1c4>
	else {
		/*
		 * Look for DW_AT_sibling attribute for the offset of
		 * its sibling.
		 */
		if ((at = _dwarf_attr_find(die, DW_AT_sibling)) != NULL) {
  800420a0c1:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a0c5:	be 01 00 00 00       	mov    $0x1,%esi
  800420a0ca:	48 89 c7             	mov    %rax,%rdi
  800420a0cd:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  800420a0d4:	00 00 00 
  800420a0d7:	ff d0                	callq  *%rax
  800420a0d9:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800420a0dd:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420a0e2:	74 35                	je     800420a119 <dwarf_siblingof+0x1b1>
			if (at->at_form != DW_FORM_ref_addr)
  800420a0e4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a0e8:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420a0ec:	48 83 f8 10          	cmp    $0x10,%rax
  800420a0f0:	74 19                	je     800420a10b <dwarf_siblingof+0x1a3>
				offset = at->u[0].u64 + cu->cu_offset;
  800420a0f2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a0f6:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420a0fa:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420a0fe:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420a102:	48 01 d0             	add    %rdx,%rax
  800420a105:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420a109:	eb 21                	jmp    800420a12c <dwarf_siblingof+0x1c4>
			else
				offset = at->u[0].u64;
  800420a10b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a10f:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420a113:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420a117:	eb 13                	jmp    800420a12c <dwarf_siblingof+0x1c4>
		} else {
			offset = die->die_next_off;
  800420a119:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a11d:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420a121:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			search_sibling = 1;
  800420a125:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%rbp)
		}
	}

	ret = dwarf_search_die_within_cu(dbg, *cu, offset, ret_die, search_sibling);
  800420a12c:	8b 4d f4             	mov    -0xc(%rbp),%ecx
  800420a12f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420a133:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
  800420a137:	48 8b 7d d8          	mov    -0x28(%rbp),%rdi
  800420a13b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420a13f:	4c 8b 00             	mov    (%rax),%r8
  800420a142:	4c 89 04 24          	mov    %r8,(%rsp)
  800420a146:	4c 8b 40 08          	mov    0x8(%rax),%r8
  800420a14a:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  800420a14f:	4c 8b 40 10          	mov    0x10(%rax),%r8
  800420a153:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
  800420a158:	4c 8b 40 18          	mov    0x18(%rax),%r8
  800420a15c:	4c 89 44 24 18       	mov    %r8,0x18(%rsp)
  800420a161:	4c 8b 40 20          	mov    0x20(%rax),%r8
  800420a165:	4c 89 44 24 20       	mov    %r8,0x20(%rsp)
  800420a16a:	4c 8b 40 28          	mov    0x28(%rax),%r8
  800420a16e:	4c 89 44 24 28       	mov    %r8,0x28(%rsp)
  800420a173:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420a177:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  800420a17c:	48 b8 d9 9a 20 04 80 	movabs $0x8004209ad9,%rax
  800420a183:	00 00 00 
  800420a186:	ff d0                	callq  *%rax
  800420a188:	89 45 e4             	mov    %eax,-0x1c(%rbp)


	if (ret == DW_DLE_NO_ENTRY) {
  800420a18b:	83 7d e4 04          	cmpl   $0x4,-0x1c(%rbp)
  800420a18f:	75 07                	jne    800420a198 <dwarf_siblingof+0x230>
		return (DW_DLV_NO_ENTRY);
  800420a191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420a196:	eb 12                	jmp    800420a1aa <dwarf_siblingof+0x242>
	} else if (ret != DW_DLE_NONE)
  800420a198:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800420a19c:	74 07                	je     800420a1a5 <dwarf_siblingof+0x23d>
		return (DW_DLV_ERROR);
  800420a19e:	b8 01 00 00 00       	mov    $0x1,%eax
  800420a1a3:	eb 05                	jmp    800420a1aa <dwarf_siblingof+0x242>


	return (DW_DLV_OK);
  800420a1a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420a1aa:	c9                   	leaveq 
  800420a1ab:	c3                   	retq   

000000800420a1ac <dwarf_child>:

int
dwarf_child(Dwarf_Debug dbg, Dwarf_CU *cu, Dwarf_Die *die, Dwarf_Die *ret_die)
{
  800420a1ac:	55                   	push   %rbp
  800420a1ad:	48 89 e5             	mov    %rsp,%rbp
  800420a1b0:	48 83 ec 70          	sub    $0x70,%rsp
  800420a1b4:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420a1b8:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420a1bc:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800420a1c0:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
	int ret;

	assert(die);
  800420a1c4:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  800420a1c9:	75 35                	jne    800420a200 <dwarf_child+0x54>
  800420a1cb:	48 b9 e7 fc 20 04 80 	movabs $0x800420fce7,%rcx
  800420a1d2:	00 00 00 
  800420a1d5:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420a1dc:	00 00 00 
  800420a1df:	be 1c 03 00 00       	mov    $0x31c,%esi
  800420a1e4:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420a1eb:	00 00 00 
  800420a1ee:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a1f3:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a1fa:	00 00 00 
  800420a1fd:	41 ff d0             	callq  *%r8
	assert(ret_die);
  800420a200:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420a205:	75 35                	jne    800420a23c <dwarf_child+0x90>
  800420a207:	48 b9 dc fc 20 04 80 	movabs $0x800420fcdc,%rcx
  800420a20e:	00 00 00 
  800420a211:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420a218:	00 00 00 
  800420a21b:	be 1d 03 00 00       	mov    $0x31d,%esi
  800420a220:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420a227:	00 00 00 
  800420a22a:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a22f:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a236:	00 00 00 
  800420a239:	41 ff d0             	callq  *%r8
	assert(dbg);
  800420a23c:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420a241:	75 35                	jne    800420a278 <dwarf_child+0xcc>
  800420a243:	48 b9 d8 fc 20 04 80 	movabs $0x800420fcd8,%rcx
  800420a24a:	00 00 00 
  800420a24d:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420a254:	00 00 00 
  800420a257:	be 1e 03 00 00       	mov    $0x31e,%esi
  800420a25c:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420a263:	00 00 00 
  800420a266:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a26b:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a272:	00 00 00 
  800420a275:	41 ff d0             	callq  *%r8
	assert(cu);
  800420a278:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  800420a27d:	75 35                	jne    800420a2b4 <dwarf_child+0x108>
  800420a27f:	48 b9 e4 fc 20 04 80 	movabs $0x800420fce4,%rcx
  800420a286:	00 00 00 
  800420a289:	48 ba 4a fb 20 04 80 	movabs $0x800420fb4a,%rdx
  800420a290:	00 00 00 
  800420a293:	be 1f 03 00 00       	mov    $0x31f,%esi
  800420a298:	48 bf 5f fb 20 04 80 	movabs $0x800420fb5f,%rdi
  800420a29f:	00 00 00 
  800420a2a2:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a2a7:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a2ae:	00 00 00 
  800420a2b1:	41 ff d0             	callq  *%r8

	if (die->die_ab.ab_children == DW_CHILDREN_no)
  800420a2b4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420a2b8:	0f b6 40 30          	movzbl 0x30(%rax),%eax
  800420a2bc:	84 c0                	test   %al,%al
  800420a2be:	75 0a                	jne    800420a2ca <dwarf_child+0x11e>
		return (DW_DLE_NO_ENTRY);
  800420a2c0:	b8 04 00 00 00       	mov    $0x4,%eax
  800420a2c5:	e9 84 00 00 00       	jmpq   800420a34e <dwarf_child+0x1a2>

	ret = dwarf_search_die_within_cu(dbg, *cu, die->die_next_off, ret_die, 0);
  800420a2ca:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420a2ce:	48 8b 70 08          	mov    0x8(%rax),%rsi
  800420a2d2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420a2d6:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
  800420a2da:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420a2de:	48 8b 08             	mov    (%rax),%rcx
  800420a2e1:	48 89 0c 24          	mov    %rcx,(%rsp)
  800420a2e5:	48 8b 48 08          	mov    0x8(%rax),%rcx
  800420a2e9:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  800420a2ee:	48 8b 48 10          	mov    0x10(%rax),%rcx
  800420a2f2:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  800420a2f7:	48 8b 48 18          	mov    0x18(%rax),%rcx
  800420a2fb:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  800420a300:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a304:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
  800420a309:	48 8b 48 28          	mov    0x28(%rax),%rcx
  800420a30d:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
  800420a312:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420a316:	48 89 44 24 30       	mov    %rax,0x30(%rsp)
  800420a31b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800420a320:	48 b8 d9 9a 20 04 80 	movabs $0x8004209ad9,%rax
  800420a327:	00 00 00 
  800420a32a:	ff d0                	callq  *%rax
  800420a32c:	89 45 fc             	mov    %eax,-0x4(%rbp)

	if (ret == DW_DLE_NO_ENTRY) {
  800420a32f:	83 7d fc 04          	cmpl   $0x4,-0x4(%rbp)
  800420a333:	75 07                	jne    800420a33c <dwarf_child+0x190>
		DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
		return (DW_DLV_NO_ENTRY);
  800420a335:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420a33a:	eb 12                	jmp    800420a34e <dwarf_child+0x1a2>
	} else if (ret != DW_DLE_NONE)
  800420a33c:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
  800420a340:	74 07                	je     800420a349 <dwarf_child+0x19d>
		return (DW_DLV_ERROR);
  800420a342:	b8 01 00 00 00       	mov    $0x1,%eax
  800420a347:	eb 05                	jmp    800420a34e <dwarf_child+0x1a2>

	return (DW_DLV_OK);
  800420a349:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420a34e:	c9                   	leaveq 
  800420a34f:	c3                   	retq   

000000800420a350 <_dwarf_find_section_enhanced>:


int  _dwarf_find_section_enhanced(Dwarf_Section *ds)
{
  800420a350:	55                   	push   %rbp
  800420a351:	48 89 e5             	mov    %rsp,%rbp
  800420a354:	48 83 ec 20          	sub    $0x20,%rsp
  800420a358:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Dwarf_Section *secthdr = _dwarf_find_section(ds->ds_name);
  800420a35c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a360:	48 8b 00             	mov    (%rax),%rax
  800420a363:	48 89 c7             	mov    %rax,%rdi
  800420a366:	48 b8 77 d6 20 04 80 	movabs $0x800420d677,%rax
  800420a36d:	00 00 00 
  800420a370:	ff d0                	callq  *%rax
  800420a372:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	ds->ds_data = secthdr->ds_data;//(Dwarf_Small*)((uint8_t *)elf_base_ptr + secthdr->sh_offset);
  800420a376:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a37a:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420a37e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a382:	48 89 50 08          	mov    %rdx,0x8(%rax)
	ds->ds_addr = secthdr->ds_addr;
  800420a386:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a38a:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420a38e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a392:	48 89 50 10          	mov    %rdx,0x10(%rax)
	ds->ds_size = secthdr->ds_size;
  800420a396:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a39a:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420a39e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a3a2:	48 89 50 18          	mov    %rdx,0x18(%rax)
	return 0;
  800420a3a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420a3ab:	c9                   	leaveq 
  800420a3ac:	c3                   	retq   

000000800420a3ad <_dwarf_frame_params_init>:

extern int  _dwarf_find_section_enhanced(Dwarf_Section *ds);

void
_dwarf_frame_params_init(Dwarf_Debug dbg)
{
  800420a3ad:	55                   	push   %rbp
  800420a3ae:	48 89 e5             	mov    %rsp,%rbp
  800420a3b1:	48 83 ec 08          	sub    $0x8,%rsp
  800420a3b5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
	/* Initialise call frame related parameters. */
	dbg->dbg_frame_rule_table_size = DW_FRAME_LAST_REG_NUM;
  800420a3b9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a3bd:	66 c7 40 48 42 00    	movw   $0x42,0x48(%rax)
	dbg->dbg_frame_rule_initial_value = DW_FRAME_REG_INITIAL_VALUE;
  800420a3c3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a3c7:	66 c7 40 4a 0b 04    	movw   $0x40b,0x4a(%rax)
	dbg->dbg_frame_cfa_value = DW_FRAME_CFA_COL3;
  800420a3cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a3d1:	66 c7 40 4c 9c 05    	movw   $0x59c,0x4c(%rax)
	dbg->dbg_frame_same_value = DW_FRAME_SAME_VAL;
  800420a3d7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a3db:	66 c7 40 4e 0b 04    	movw   $0x40b,0x4e(%rax)
	dbg->dbg_frame_undefined_value = DW_FRAME_UNDEFINED_VAL;
  800420a3e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a3e5:	66 c7 40 50 0a 04    	movw   $0x40a,0x50(%rax)
}
  800420a3eb:	c9                   	leaveq 
  800420a3ec:	c3                   	retq   

000000800420a3ed <dwarf_get_fde_at_pc>:

int
dwarf_get_fde_at_pc(Dwarf_Debug dbg, Dwarf_Addr pc,
		    struct _Dwarf_Fde *ret_fde, Dwarf_Cie cie,
		    Dwarf_Error *error)
{
  800420a3ed:	55                   	push   %rbp
  800420a3ee:	48 89 e5             	mov    %rsp,%rbp
  800420a3f1:	48 83 ec 40          	sub    $0x40,%rsp
  800420a3f5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420a3f9:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420a3fd:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800420a401:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  800420a405:	4c 89 45 c8          	mov    %r8,-0x38(%rbp)
	Dwarf_Fde fde = ret_fde;
  800420a409:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420a40d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	memset(fde, 0, sizeof(struct _Dwarf_Fde));
  800420a411:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a415:	ba 80 00 00 00       	mov    $0x80,%edx
  800420a41a:	be 00 00 00 00       	mov    $0x0,%esi
  800420a41f:	48 89 c7             	mov    %rax,%rdi
  800420a422:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420a429:	00 00 00 
  800420a42c:	ff d0                	callq  *%rax
	fde->fde_cie = cie;
  800420a42e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a432:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420a436:	48 89 50 08          	mov    %rdx,0x8(%rax)
	
	if (ret_fde == NULL)
  800420a43a:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  800420a43f:	75 07                	jne    800420a448 <dwarf_get_fde_at_pc+0x5b>
		return (DW_DLV_ERROR);
  800420a441:	b8 01 00 00 00       	mov    $0x1,%eax
  800420a446:	eb 75                	jmp    800420a4bd <dwarf_get_fde_at_pc+0xd0>

	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
  800420a448:	eb 59                	jmp    800420a4a3 <dwarf_get_fde_at_pc+0xb6>
		if (_dwarf_get_next_fde(dbg, true, error, fde) < 0)
  800420a44a:	48 8b 4d f8          	mov    -0x8(%rbp),%rcx
  800420a44e:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420a452:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a456:	be 01 00 00 00       	mov    $0x1,%esi
  800420a45b:	48 89 c7             	mov    %rax,%rdi
  800420a45e:	48 b8 02 c6 20 04 80 	movabs $0x800420c602,%rax
  800420a465:	00 00 00 
  800420a468:	ff d0                	callq  *%rax
  800420a46a:	85 c0                	test   %eax,%eax
  800420a46c:	79 07                	jns    800420a475 <dwarf_get_fde_at_pc+0x88>
		{
			return DW_DLV_NO_ENTRY;
  800420a46e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420a473:	eb 48                	jmp    800420a4bd <dwarf_get_fde_at_pc+0xd0>
		}
		if (pc >= fde->fde_initloc && pc < fde->fde_initloc +
  800420a475:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a479:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420a47d:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420a481:	77 20                	ja     800420a4a3 <dwarf_get_fde_at_pc+0xb6>
  800420a483:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a487:	48 8b 50 30          	mov    0x30(%rax),%rdx
		    fde->fde_adrange)
  800420a48b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420a48f:	48 8b 40 38          	mov    0x38(%rax),%rax
	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
		if (_dwarf_get_next_fde(dbg, true, error, fde) < 0)
		{
			return DW_DLV_NO_ENTRY;
		}
		if (pc >= fde->fde_initloc && pc < fde->fde_initloc +
  800420a493:	48 01 d0             	add    %rdx,%rax
  800420a496:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420a49a:	76 07                	jbe    800420a4a3 <dwarf_get_fde_at_pc+0xb6>
		    fde->fde_adrange)
			return (DW_DLV_OK);
  800420a49c:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a4a1:	eb 1a                	jmp    800420a4bd <dwarf_get_fde_at_pc+0xd0>
	fde->fde_cie = cie;
	
	if (ret_fde == NULL)
		return (DW_DLV_ERROR);

	while(dbg->curr_off_eh < dbg->dbg_eh_size) {
  800420a4a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a4a7:	48 8b 50 30          	mov    0x30(%rax),%rdx
  800420a4ab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420a4af:	48 8b 40 40          	mov    0x40(%rax),%rax
  800420a4b3:	48 39 c2             	cmp    %rax,%rdx
  800420a4b6:	72 92                	jb     800420a44a <dwarf_get_fde_at_pc+0x5d>
		    fde->fde_adrange)
			return (DW_DLV_OK);
	}

	DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
	return (DW_DLV_NO_ENTRY);
  800420a4b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800420a4bd:	c9                   	leaveq 
  800420a4be:	c3                   	retq   

000000800420a4bf <_dwarf_frame_regtable_copy>:

int
_dwarf_frame_regtable_copy(Dwarf_Debug dbg, Dwarf_Regtable3 **dest,
			   Dwarf_Regtable3 *src, Dwarf_Error *error)
{
  800420a4bf:	55                   	push   %rbp
  800420a4c0:	48 89 e5             	mov    %rsp,%rbp
  800420a4c3:	53                   	push   %rbx
  800420a4c4:	48 83 ec 38          	sub    $0x38,%rsp
  800420a4c8:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  800420a4cc:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420a4d0:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800420a4d4:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
	int i;

	assert(dest != NULL);
  800420a4d8:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420a4dd:	75 35                	jne    800420a514 <_dwarf_frame_regtable_copy+0x55>
  800420a4df:	48 b9 fa fc 20 04 80 	movabs $0x800420fcfa,%rcx
  800420a4e6:	00 00 00 
  800420a4e9:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420a4f0:	00 00 00 
  800420a4f3:	be 57 00 00 00       	mov    $0x57,%esi
  800420a4f8:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420a4ff:	00 00 00 
  800420a502:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a507:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a50e:	00 00 00 
  800420a511:	41 ff d0             	callq  *%r8
	assert(src != NULL);
  800420a514:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800420a519:	75 35                	jne    800420a550 <_dwarf_frame_regtable_copy+0x91>
  800420a51b:	48 b9 32 fd 20 04 80 	movabs $0x800420fd32,%rcx
  800420a522:	00 00 00 
  800420a525:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420a52c:	00 00 00 
  800420a52f:	be 58 00 00 00       	mov    $0x58,%esi
  800420a534:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420a53b:	00 00 00 
  800420a53e:	b8 00 00 00 00       	mov    $0x0,%eax
  800420a543:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420a54a:	00 00 00 
  800420a54d:	41 ff d0             	callq  *%r8

	if (*dest == NULL) {
  800420a550:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a554:	48 8b 00             	mov    (%rax),%rax
  800420a557:	48 85 c0             	test   %rax,%rax
  800420a55a:	75 39                	jne    800420a595 <_dwarf_frame_regtable_copy+0xd6>
		*dest = &global_rt_table_shadow;
  800420a55c:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a560:	48 bb 40 2d 22 04 80 	movabs $0x8004222d40,%rbx
  800420a567:	00 00 00 
  800420a56a:	48 89 18             	mov    %rbx,(%rax)
		(*dest)->rt3_reg_table_size = src->rt3_reg_table_size;
  800420a56d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a571:	48 8b 00             	mov    (%rax),%rax
  800420a574:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420a578:	0f b7 52 18          	movzwl 0x18(%rdx),%edx
  800420a57c:	66 89 50 18          	mov    %dx,0x18(%rax)
		(*dest)->rt3_rules = global_rules_shadow;
  800420a580:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a584:	48 8b 00             	mov    (%rax),%rax
  800420a587:	48 bb 00 2f 22 04 80 	movabs $0x8004222f00,%rbx
  800420a58e:	00 00 00 
  800420a591:	48 89 58 20          	mov    %rbx,0x20(%rax)
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
  800420a595:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420a599:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a59d:	48 8b 00             	mov    (%rax),%rax
  800420a5a0:	ba 18 00 00 00       	mov    $0x18,%edx
  800420a5a5:	48 89 ce             	mov    %rcx,%rsi
  800420a5a8:	48 89 c7             	mov    %rax,%rdi
  800420a5ab:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  800420a5b2:	00 00 00 
  800420a5b5:	ff d0                	callq  *%rax
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  800420a5b7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
  800420a5be:	eb 5a                	jmp    800420a61a <_dwarf_frame_regtable_copy+0x15b>
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
  800420a5c0:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420a5c4:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a5c8:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420a5cb:	48 63 d0             	movslq %eax,%rdx
  800420a5ce:	48 89 d0             	mov    %rdx,%rax
  800420a5d1:	48 01 c0             	add    %rax,%rax
  800420a5d4:	48 01 d0             	add    %rdx,%rax
  800420a5d7:	48 c1 e0 03          	shl    $0x3,%rax
  800420a5db:	48 01 c1             	add    %rax,%rcx
  800420a5de:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a5e2:	48 8b 00             	mov    (%rax),%rax
  800420a5e5:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420a5e9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420a5ec:	48 63 d0             	movslq %eax,%rdx
  800420a5ef:	48 89 d0             	mov    %rdx,%rax
  800420a5f2:	48 01 c0             	add    %rax,%rax
  800420a5f5:	48 01 d0             	add    %rdx,%rax
  800420a5f8:	48 c1 e0 03          	shl    $0x3,%rax
  800420a5fc:	48 01 f0             	add    %rsi,%rax
  800420a5ff:	ba 18 00 00 00       	mov    $0x18,%edx
  800420a604:	48 89 ce             	mov    %rcx,%rsi
  800420a607:	48 89 c7             	mov    %rax,%rdi
  800420a60a:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  800420a611:	00 00 00 
  800420a614:	ff d0                	callq  *%rax

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
		     i < src->rt3_reg_table_size; i++)
  800420a616:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  800420a61a:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a61e:	48 8b 00             	mov    (%rax),%rax
  800420a621:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420a625:	0f b7 c0             	movzwl %ax,%eax
  800420a628:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420a62b:	7e 10                	jle    800420a63d <_dwarf_frame_regtable_copy+0x17e>
		     i < src->rt3_reg_table_size; i++)
  800420a62d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420a631:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420a635:	0f b7 c0             	movzwl %ax,%eax
	}

	memcpy(&(*dest)->rt3_cfa_rule, &src->rt3_cfa_rule,
	       sizeof(Dwarf_Regtable_Entry3));

	for (i = 0; i < (*dest)->rt3_reg_table_size &&
  800420a638:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420a63b:	7f 83                	jg     800420a5c0 <_dwarf_frame_regtable_copy+0x101>
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
  800420a63d:	eb 32                	jmp    800420a671 <_dwarf_frame_regtable_copy+0x1b2>
		(*dest)->rt3_rules[i].dw_regnum =
  800420a63f:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a643:	48 8b 00             	mov    (%rax),%rax
  800420a646:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a64a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  800420a64d:	48 63 d0             	movslq %eax,%rdx
  800420a650:	48 89 d0             	mov    %rdx,%rax
  800420a653:	48 01 c0             	add    %rax,%rax
  800420a656:	48 01 d0             	add    %rdx,%rax
  800420a659:	48 c1 e0 03          	shl    $0x3,%rax
  800420a65d:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
			dbg->dbg_frame_undefined_value;
  800420a661:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420a665:	0f b7 40 50          	movzwl 0x50(%rax),%eax
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
		(*dest)->rt3_rules[i].dw_regnum =
  800420a669:	66 89 42 02          	mov    %ax,0x2(%rdx)
	for (i = 0; i < (*dest)->rt3_reg_table_size &&
		     i < src->rt3_reg_table_size; i++)
		memcpy(&(*dest)->rt3_rules[i], &src->rt3_rules[i],
		       sizeof(Dwarf_Regtable_Entry3));

	for (; i < (*dest)->rt3_reg_table_size; i++)
  800420a66d:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
  800420a671:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420a675:	48 8b 00             	mov    (%rax),%rax
  800420a678:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420a67c:	0f b7 c0             	movzwl %ax,%eax
  800420a67f:	3b 45 ec             	cmp    -0x14(%rbp),%eax
  800420a682:	7f bb                	jg     800420a63f <_dwarf_frame_regtable_copy+0x180>
		(*dest)->rt3_rules[i].dw_regnum =
			dbg->dbg_frame_undefined_value;

	return (DW_DLE_NONE);
  800420a684:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420a689:	48 83 c4 38          	add    $0x38,%rsp
  800420a68d:	5b                   	pop    %rbx
  800420a68e:	5d                   	pop    %rbp
  800420a68f:	c3                   	retq   

000000800420a690 <_dwarf_frame_run_inst>:

static int
_dwarf_frame_run_inst(Dwarf_Debug dbg, Dwarf_Regtable3 *rt, uint8_t *insts,
		      Dwarf_Unsigned len, Dwarf_Unsigned caf, Dwarf_Signed daf, Dwarf_Addr pc,
		      Dwarf_Addr pc_req, Dwarf_Addr *row_pc, Dwarf_Error *error)
{
  800420a690:	55                   	push   %rbp
  800420a691:	48 89 e5             	mov    %rsp,%rbp
  800420a694:	53                   	push   %rbx
  800420a695:	48 81 ec 88 00 00 00 	sub    $0x88,%rsp
  800420a69c:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
  800420a6a0:	48 89 75 90          	mov    %rsi,-0x70(%rbp)
  800420a6a4:	48 89 55 88          	mov    %rdx,-0x78(%rbp)
  800420a6a8:	48 89 4d 80          	mov    %rcx,-0x80(%rbp)
  800420a6ac:	4c 89 85 78 ff ff ff 	mov    %r8,-0x88(%rbp)
  800420a6b3:	4c 89 8d 70 ff ff ff 	mov    %r9,-0x90(%rbp)
			ret = DW_DLE_DF_REG_NUM_TOO_HIGH;               \
			goto program_done;                              \
		}                                                       \
	} while(0)

	ret = DW_DLE_NONE;
  800420a6ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
	init_rt = saved_rt = NULL;
  800420a6c1:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  800420a6c8:	00 
  800420a6c9:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420a6cd:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
	*row_pc = pc;
  800420a6d1:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420a6d5:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420a6d9:	48 89 10             	mov    %rdx,(%rax)

	/* Save a copy of the table as initial state. */
	_dwarf_frame_regtable_copy(dbg, &init_rt, rt, error);
  800420a6dc:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  800420a6e0:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  800420a6e4:	48 8d 75 b0          	lea    -0x50(%rbp),%rsi
  800420a6e8:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a6ec:	48 89 c7             	mov    %rax,%rdi
  800420a6ef:	48 b8 bf a4 20 04 80 	movabs $0x800420a4bf,%rax
  800420a6f6:	00 00 00 
  800420a6f9:	ff d0                	callq  *%rax
	p = insts;
  800420a6fb:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420a6ff:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
	pe = p + len;
  800420a703:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800420a707:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420a70b:	48 01 d0             	add    %rdx,%rax
  800420a70e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

	while (p < pe) {
  800420a712:	e9 3a 0d 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		if (*p == DW_CFA_nop) {
  800420a717:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420a71b:	0f b6 00             	movzbl (%rax),%eax
  800420a71e:	84 c0                	test   %al,%al
  800420a720:	75 11                	jne    800420a733 <_dwarf_frame_run_inst+0xa3>
			p++;
  800420a722:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420a726:	48 83 c0 01          	add    $0x1,%rax
  800420a72a:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			continue;
  800420a72e:	e9 1e 0d 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		}

		high2 = *p & 0xc0;
  800420a733:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420a737:	0f b6 00             	movzbl (%rax),%eax
  800420a73a:	83 e0 c0             	and    $0xffffffc0,%eax
  800420a73d:	88 45 df             	mov    %al,-0x21(%rbp)
		low6 = *p & 0x3f;
  800420a740:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420a744:	0f b6 00             	movzbl (%rax),%eax
  800420a747:	83 e0 3f             	and    $0x3f,%eax
  800420a74a:	88 45 de             	mov    %al,-0x22(%rbp)
		p++;
  800420a74d:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420a751:	48 83 c0 01          	add    $0x1,%rax
  800420a755:	48 89 45 a0          	mov    %rax,-0x60(%rbp)

		if (high2 > 0) {
  800420a759:	80 7d df 00          	cmpb   $0x0,-0x21(%rbp)
  800420a75d:	0f 84 a1 01 00 00    	je     800420a904 <_dwarf_frame_run_inst+0x274>
			switch (high2) {
  800420a763:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
  800420a767:	3d 80 00 00 00       	cmp    $0x80,%eax
  800420a76c:	74 38                	je     800420a7a6 <_dwarf_frame_run_inst+0x116>
  800420a76e:	3d c0 00 00 00       	cmp    $0xc0,%eax
  800420a773:	0f 84 01 01 00 00    	je     800420a87a <_dwarf_frame_run_inst+0x1ea>
  800420a779:	83 f8 40             	cmp    $0x40,%eax
  800420a77c:	0f 85 71 01 00 00    	jne    800420a8f3 <_dwarf_frame_run_inst+0x263>
			case DW_CFA_advance_loc:
			        pc += low6 * caf;
  800420a782:	0f b6 45 de          	movzbl -0x22(%rbp),%eax
  800420a786:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  800420a78d:	ff 
  800420a78e:	48 01 45 10          	add    %rax,0x10(%rbp)
			        if (pc_req < pc)
  800420a792:	48 8b 45 18          	mov    0x18(%rbp),%rax
  800420a796:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  800420a79a:	73 05                	jae    800420a7a1 <_dwarf_frame_run_inst+0x111>
			                goto program_done;
  800420a79c:	e9 be 0c 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			        break;
  800420a7a1:	e9 59 01 00 00       	jmpq   800420a8ff <_dwarf_frame_run_inst+0x26f>
			case DW_CFA_offset:
			        *row_pc = pc;
  800420a7a6:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420a7aa:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420a7ae:	48 89 10             	mov    %rdx,(%rax)
			        CHECK_TABLE_SIZE(low6);
  800420a7b1:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a7b5:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a7b9:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420a7bd:	66 39 c2             	cmp    %ax,%dx
  800420a7c0:	72 0c                	jb     800420a7ce <_dwarf_frame_run_inst+0x13e>
  800420a7c2:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420a7c9:	e9 91 0c 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			        RL[low6].dw_offset_relevant = 1;
  800420a7ce:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a7d2:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a7d6:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a7da:	48 89 d0             	mov    %rdx,%rax
  800420a7dd:	48 01 c0             	add    %rax,%rax
  800420a7e0:	48 01 d0             	add    %rdx,%rax
  800420a7e3:	48 c1 e0 03          	shl    $0x3,%rax
  800420a7e7:	48 01 c8             	add    %rcx,%rax
  800420a7ea:	c6 00 01             	movb   $0x1,(%rax)
			        RL[low6].dw_value_type = DW_EXPR_OFFSET;
  800420a7ed:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a7f1:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a7f5:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a7f9:	48 89 d0             	mov    %rdx,%rax
  800420a7fc:	48 01 c0             	add    %rax,%rax
  800420a7ff:	48 01 d0             	add    %rdx,%rax
  800420a802:	48 c1 e0 03          	shl    $0x3,%rax
  800420a806:	48 01 c8             	add    %rcx,%rax
  800420a809:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			        RL[low6].dw_regnum = dbg->dbg_frame_cfa_value;
  800420a80d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a811:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a815:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a819:	48 89 d0             	mov    %rdx,%rax
  800420a81c:	48 01 c0             	add    %rax,%rax
  800420a81f:	48 01 d0             	add    %rdx,%rax
  800420a822:	48 c1 e0 03          	shl    $0x3,%rax
  800420a826:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420a82a:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a82e:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420a832:	66 89 42 02          	mov    %ax,0x2(%rdx)
			        RL[low6].dw_offset_or_block_len =
  800420a836:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a83a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a83e:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a842:	48 89 d0             	mov    %rdx,%rax
  800420a845:	48 01 c0             	add    %rax,%rax
  800420a848:	48 01 d0             	add    %rdx,%rax
  800420a84b:	48 c1 e0 03          	shl    $0x3,%rax
  800420a84f:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
					_dwarf_decode_uleb128(&p) * daf;
  800420a853:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420a857:	48 89 c7             	mov    %rax,%rdi
  800420a85a:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420a861:	00 00 00 
  800420a864:	ff d0                	callq  *%rax
  800420a866:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  800420a86d:	48 0f af c2          	imul   %rdx,%rax
			        *row_pc = pc;
			        CHECK_TABLE_SIZE(low6);
			        RL[low6].dw_offset_relevant = 1;
			        RL[low6].dw_value_type = DW_EXPR_OFFSET;
			        RL[low6].dw_regnum = dbg->dbg_frame_cfa_value;
			        RL[low6].dw_offset_or_block_len =
  800420a871:	48 89 43 08          	mov    %rax,0x8(%rbx)
					_dwarf_decode_uleb128(&p) * daf;
			        break;
  800420a875:	e9 85 00 00 00       	jmpq   800420a8ff <_dwarf_frame_run_inst+0x26f>
			case DW_CFA_restore:
			        *row_pc = pc;
  800420a87a:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420a87e:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420a882:	48 89 10             	mov    %rdx,(%rax)
			        CHECK_TABLE_SIZE(low6);
  800420a885:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a889:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a88d:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420a891:	66 39 c2             	cmp    %ax,%dx
  800420a894:	72 0c                	jb     800420a8a2 <_dwarf_frame_run_inst+0x212>
  800420a896:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420a89d:	e9 bd 0b 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			        memcpy(&RL[low6], &INITRL[low6],
  800420a8a2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420a8a6:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420a8aa:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a8ae:	48 89 d0             	mov    %rdx,%rax
  800420a8b1:	48 01 c0             	add    %rax,%rax
  800420a8b4:	48 01 d0             	add    %rdx,%rax
  800420a8b7:	48 c1 e0 03          	shl    $0x3,%rax
  800420a8bb:	48 01 c1             	add    %rax,%rcx
  800420a8be:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420a8c2:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420a8c6:	0f b6 55 de          	movzbl -0x22(%rbp),%edx
  800420a8ca:	48 89 d0             	mov    %rdx,%rax
  800420a8cd:	48 01 c0             	add    %rax,%rax
  800420a8d0:	48 01 d0             	add    %rdx,%rax
  800420a8d3:	48 c1 e0 03          	shl    $0x3,%rax
  800420a8d7:	48 01 f0             	add    %rsi,%rax
  800420a8da:	ba 18 00 00 00       	mov    $0x18,%edx
  800420a8df:	48 89 ce             	mov    %rcx,%rsi
  800420a8e2:	48 89 c7             	mov    %rax,%rdi
  800420a8e5:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  800420a8ec:	00 00 00 
  800420a8ef:	ff d0                	callq  *%rax
				       sizeof(Dwarf_Regtable_Entry3));
			        break;
  800420a8f1:	eb 0c                	jmp    800420a8ff <_dwarf_frame_run_inst+0x26f>
			default:
			        DWARF_SET_ERROR(dbg, error,
						DW_DLE_FRAME_INSTR_EXEC_ERROR);
			        ret = DW_DLE_FRAME_INSTR_EXEC_ERROR;
  800420a8f3:	c7 45 ec 15 00 00 00 	movl   $0x15,-0x14(%rbp)
			        goto program_done;
  800420a8fa:	e9 60 0b 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			}

			continue;
  800420a8ff:	e9 4d 0b 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		}

		switch (low6) {
  800420a904:	0f b6 45 de          	movzbl -0x22(%rbp),%eax
  800420a908:	83 f8 16             	cmp    $0x16,%eax
  800420a90b:	0f 87 37 0b 00 00    	ja     800420b448 <_dwarf_frame_run_inst+0xdb8>
  800420a911:	89 c0                	mov    %eax,%eax
  800420a913:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420a91a:	00 
  800420a91b:	48 b8 40 fd 20 04 80 	movabs $0x800420fd40,%rax
  800420a922:	00 00 00 
  800420a925:	48 01 d0             	add    %rdx,%rax
  800420a928:	48 8b 00             	mov    (%rax),%rax
  800420a92b:	ff e0                	jmpq   *%rax
		case DW_CFA_set_loc:
			pc = dbg->decode(&p, dbg->dbg_pointer_size);
  800420a92d:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a931:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420a935:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  800420a939:	8b 4a 28             	mov    0x28(%rdx),%ecx
  800420a93c:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  800420a940:	89 ce                	mov    %ecx,%esi
  800420a942:	48 89 d7             	mov    %rdx,%rdi
  800420a945:	ff d0                	callq  *%rax
  800420a947:	48 89 45 10          	mov    %rax,0x10(%rbp)
			if (pc_req < pc)
  800420a94b:	48 8b 45 18          	mov    0x18(%rbp),%rax
  800420a94f:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  800420a953:	73 05                	jae    800420a95a <_dwarf_frame_run_inst+0x2ca>
			        goto program_done;
  800420a955:	e9 05 0b 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			break;
  800420a95a:	e9 f2 0a 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc1:
			pc += dbg->decode(&p, 1) * caf;
  800420a95f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a963:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420a967:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  800420a96b:	be 01 00 00 00       	mov    $0x1,%esi
  800420a970:	48 89 d7             	mov    %rdx,%rdi
  800420a973:	ff d0                	callq  *%rax
  800420a975:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  800420a97c:	ff 
  800420a97d:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  800420a981:	48 8b 45 18          	mov    0x18(%rbp),%rax
  800420a985:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  800420a989:	73 05                	jae    800420a990 <_dwarf_frame_run_inst+0x300>
			        goto program_done;
  800420a98b:	e9 cf 0a 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			break;
  800420a990:	e9 bc 0a 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc2:
			pc += dbg->decode(&p, 2) * caf;
  800420a995:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a999:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420a99d:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  800420a9a1:	be 02 00 00 00       	mov    $0x2,%esi
  800420a9a6:	48 89 d7             	mov    %rdx,%rdi
  800420a9a9:	ff d0                	callq  *%rax
  800420a9ab:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  800420a9b2:	ff 
  800420a9b3:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  800420a9b7:	48 8b 45 18          	mov    0x18(%rbp),%rax
  800420a9bb:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  800420a9bf:	73 05                	jae    800420a9c6 <_dwarf_frame_run_inst+0x336>
			        goto program_done;
  800420a9c1:	e9 99 0a 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			break;
  800420a9c6:	e9 86 0a 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_advance_loc4:
			pc += dbg->decode(&p, 4) * caf;
  800420a9cb:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420a9cf:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420a9d3:	48 8d 55 a0          	lea    -0x60(%rbp),%rdx
  800420a9d7:	be 04 00 00 00       	mov    $0x4,%esi
  800420a9dc:	48 89 d7             	mov    %rdx,%rdi
  800420a9df:	ff d0                	callq  *%rax
  800420a9e1:	48 0f af 85 78 ff ff 	imul   -0x88(%rbp),%rax
  800420a9e8:	ff 
  800420a9e9:	48 01 45 10          	add    %rax,0x10(%rbp)
			if (pc_req < pc)
  800420a9ed:	48 8b 45 18          	mov    0x18(%rbp),%rax
  800420a9f1:	48 3b 45 10          	cmp    0x10(%rbp),%rax
  800420a9f5:	73 05                	jae    800420a9fc <_dwarf_frame_run_inst+0x36c>
			        goto program_done;
  800420a9f7:	e9 63 0a 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			break;
  800420a9fc:	e9 50 0a 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_offset_extended:
			*row_pc = pc;
  800420aa01:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420aa05:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420aa09:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420aa0c:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420aa10:	48 89 c7             	mov    %rax,%rdi
  800420aa13:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420aa1a:	00 00 00 
  800420aa1d:	ff d0                	callq  *%rax
  800420aa1f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  800420aa23:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420aa27:	48 89 c7             	mov    %rax,%rdi
  800420aa2a:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420aa31:	00 00 00 
  800420aa34:	ff d0                	callq  *%rax
  800420aa36:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420aa3a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aa3e:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420aa42:	0f b7 c0             	movzwl %ax,%eax
  800420aa45:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420aa49:	77 0c                	ja     800420aa57 <_dwarf_frame_run_inst+0x3c7>
  800420aa4b:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420aa52:	e9 08 0a 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  800420aa57:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aa5b:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420aa5f:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420aa63:	48 89 d0             	mov    %rdx,%rax
  800420aa66:	48 01 c0             	add    %rax,%rax
  800420aa69:	48 01 d0             	add    %rdx,%rax
  800420aa6c:	48 c1 e0 03          	shl    $0x3,%rax
  800420aa70:	48 01 c8             	add    %rcx,%rax
  800420aa73:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_OFFSET;
  800420aa76:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aa7a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420aa7e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420aa82:	48 89 d0             	mov    %rdx,%rax
  800420aa85:	48 01 c0             	add    %rax,%rax
  800420aa88:	48 01 d0             	add    %rdx,%rax
  800420aa8b:	48 c1 e0 03          	shl    $0x3,%rax
  800420aa8f:	48 01 c8             	add    %rcx,%rax
  800420aa92:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420aa96:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aa9a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420aa9e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420aaa2:	48 89 d0             	mov    %rdx,%rax
  800420aaa5:	48 01 c0             	add    %rax,%rax
  800420aaa8:	48 01 d0             	add    %rdx,%rax
  800420aaab:	48 c1 e0 03          	shl    $0x3,%rax
  800420aaaf:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420aab3:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420aab7:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420aabb:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = uoff * daf;
  800420aabf:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aac3:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420aac7:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420aacb:	48 89 d0             	mov    %rdx,%rax
  800420aace:	48 01 c0             	add    %rax,%rax
  800420aad1:	48 01 d0             	add    %rdx,%rax
  800420aad4:	48 c1 e0 03          	shl    $0x3,%rax
  800420aad8:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420aadc:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420aae3:	48 0f af 45 c8       	imul   -0x38(%rbp),%rax
  800420aae8:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  800420aaec:	e9 60 09 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_restore_extended:
			*row_pc = pc;
  800420aaf1:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420aaf5:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420aaf9:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420aafc:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ab00:	48 89 c7             	mov    %rax,%rdi
  800420ab03:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ab0a:	00 00 00 
  800420ab0d:	ff d0                	callq  *%rax
  800420ab0f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420ab13:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ab17:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420ab1b:	0f b7 c0             	movzwl %ax,%eax
  800420ab1e:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420ab22:	77 0c                	ja     800420ab30 <_dwarf_frame_run_inst+0x4a0>
  800420ab24:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420ab2b:	e9 2f 09 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			memcpy(&RL[reg], &INITRL[reg],
  800420ab30:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420ab34:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420ab38:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ab3c:	48 89 d0             	mov    %rdx,%rax
  800420ab3f:	48 01 c0             	add    %rax,%rax
  800420ab42:	48 01 d0             	add    %rdx,%rax
  800420ab45:	48 c1 e0 03          	shl    $0x3,%rax
  800420ab49:	48 01 c1             	add    %rax,%rcx
  800420ab4c:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ab50:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420ab54:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ab58:	48 89 d0             	mov    %rdx,%rax
  800420ab5b:	48 01 c0             	add    %rax,%rax
  800420ab5e:	48 01 d0             	add    %rdx,%rax
  800420ab61:	48 c1 e0 03          	shl    $0x3,%rax
  800420ab65:	48 01 f0             	add    %rsi,%rax
  800420ab68:	ba 18 00 00 00       	mov    $0x18,%edx
  800420ab6d:	48 89 ce             	mov    %rcx,%rsi
  800420ab70:	48 89 c7             	mov    %rax,%rdi
  800420ab73:	48 b8 42 81 20 04 80 	movabs $0x8004208142,%rax
  800420ab7a:	00 00 00 
  800420ab7d:	ff d0                	callq  *%rax
			       sizeof(Dwarf_Regtable_Entry3));
			break;
  800420ab7f:	e9 cd 08 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_undefined:
			*row_pc = pc;
  800420ab84:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ab88:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ab8c:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420ab8f:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ab93:	48 89 c7             	mov    %rax,%rdi
  800420ab96:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ab9d:	00 00 00 
  800420aba0:	ff d0                	callq  *%rax
  800420aba2:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420aba6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420abaa:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420abae:	0f b7 c0             	movzwl %ax,%eax
  800420abb1:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420abb5:	77 0c                	ja     800420abc3 <_dwarf_frame_run_inst+0x533>
  800420abb7:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420abbe:	e9 9c 08 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  800420abc3:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420abc7:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420abcb:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420abcf:	48 89 d0             	mov    %rdx,%rax
  800420abd2:	48 01 c0             	add    %rax,%rax
  800420abd5:	48 01 d0             	add    %rdx,%rax
  800420abd8:	48 c1 e0 03          	shl    $0x3,%rax
  800420abdc:	48 01 c8             	add    %rcx,%rax
  800420abdf:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_undefined_value;
  800420abe2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420abe6:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420abea:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420abee:	48 89 d0             	mov    %rdx,%rax
  800420abf1:	48 01 c0             	add    %rax,%rax
  800420abf4:	48 01 d0             	add    %rdx,%rax
  800420abf7:	48 c1 e0 03          	shl    $0x3,%rax
  800420abfb:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420abff:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420ac03:	0f b7 40 50          	movzwl 0x50(%rax),%eax
  800420ac07:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  800420ac0b:	e9 41 08 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_same_value:
			reg = _dwarf_decode_uleb128(&p);
  800420ac10:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ac14:	48 89 c7             	mov    %rax,%rdi
  800420ac17:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ac1e:	00 00 00 
  800420ac21:	ff d0                	callq  *%rax
  800420ac23:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420ac27:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ac2b:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420ac2f:	0f b7 c0             	movzwl %ax,%eax
  800420ac32:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420ac36:	77 0c                	ja     800420ac44 <_dwarf_frame_run_inst+0x5b4>
  800420ac38:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420ac3f:	e9 1b 08 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  800420ac44:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ac48:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420ac4c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ac50:	48 89 d0             	mov    %rdx,%rax
  800420ac53:	48 01 c0             	add    %rax,%rax
  800420ac56:	48 01 d0             	add    %rdx,%rax
  800420ac59:	48 c1 e0 03          	shl    $0x3,%rax
  800420ac5d:	48 01 c8             	add    %rcx,%rax
  800420ac60:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_same_value;
  800420ac63:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ac67:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420ac6b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ac6f:	48 89 d0             	mov    %rdx,%rax
  800420ac72:	48 01 c0             	add    %rax,%rax
  800420ac75:	48 01 d0             	add    %rdx,%rax
  800420ac78:	48 c1 e0 03          	shl    $0x3,%rax
  800420ac7c:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420ac80:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420ac84:	0f b7 40 4e          	movzwl 0x4e(%rax),%eax
  800420ac88:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  800420ac8c:	e9 c0 07 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_register:
			*row_pc = pc;
  800420ac91:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ac95:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ac99:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420ac9c:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420aca0:	48 89 c7             	mov    %rax,%rdi
  800420aca3:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420acaa:	00 00 00 
  800420acad:	ff d0                	callq  *%rax
  800420acaf:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			reg2 = _dwarf_decode_uleb128(&p);
  800420acb3:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420acb7:	48 89 c7             	mov    %rax,%rdi
  800420acba:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420acc1:	00 00 00 
  800420acc4:	ff d0                	callq  *%rax
  800420acc6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420acca:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420acce:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420acd2:	0f b7 c0             	movzwl %ax,%eax
  800420acd5:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420acd9:	77 0c                	ja     800420ace7 <_dwarf_frame_run_inst+0x657>
  800420acdb:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420ace2:	e9 78 07 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  800420ace7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aceb:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420acef:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420acf3:	48 89 d0             	mov    %rdx,%rax
  800420acf6:	48 01 c0             	add    %rax,%rax
  800420acf9:	48 01 d0             	add    %rdx,%rax
  800420acfc:	48 c1 e0 03          	shl    $0x3,%rax
  800420ad00:	48 01 c8             	add    %rcx,%rax
  800420ad03:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_regnum = reg2;
  800420ad06:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ad0a:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420ad0e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ad12:	48 89 d0             	mov    %rdx,%rax
  800420ad15:	48 01 c0             	add    %rax,%rax
  800420ad18:	48 01 d0             	add    %rdx,%rax
  800420ad1b:	48 c1 e0 03          	shl    $0x3,%rax
  800420ad1f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420ad23:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420ad27:	66 89 42 02          	mov    %ax,0x2(%rdx)
			break;
  800420ad2b:	e9 21 07 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_remember_state:
			_dwarf_frame_regtable_copy(dbg, &saved_rt, rt, error);
  800420ad30:	48 8b 55 90          	mov    -0x70(%rbp),%rdx
  800420ad34:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  800420ad38:	48 8d 75 a8          	lea    -0x58(%rbp),%rsi
  800420ad3c:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420ad40:	48 89 c7             	mov    %rax,%rdi
  800420ad43:	48 b8 bf a4 20 04 80 	movabs $0x800420a4bf,%rax
  800420ad4a:	00 00 00 
  800420ad4d:	ff d0                	callq  *%rax
			break;
  800420ad4f:	e9 fd 06 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_restore_state:
			*row_pc = pc;
  800420ad54:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ad58:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ad5c:	48 89 10             	mov    %rdx,(%rax)
			_dwarf_frame_regtable_copy(dbg, &rt, saved_rt, error);
  800420ad5f:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  800420ad63:	48 8b 4d 28          	mov    0x28(%rbp),%rcx
  800420ad67:	48 8d 75 90          	lea    -0x70(%rbp),%rsi
  800420ad6b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420ad6f:	48 89 c7             	mov    %rax,%rdi
  800420ad72:	48 b8 bf a4 20 04 80 	movabs $0x800420a4bf,%rax
  800420ad79:	00 00 00 
  800420ad7c:	ff d0                	callq  *%rax
			break;
  800420ad7e:	e9 ce 06 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa:
			*row_pc = pc;
  800420ad83:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ad87:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ad8b:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420ad8e:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ad92:	48 89 c7             	mov    %rax,%rdi
  800420ad95:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ad9c:	00 00 00 
  800420ad9f:	ff d0                	callq  *%rax
  800420ada1:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  800420ada5:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ada9:	48 89 c7             	mov    %rax,%rdi
  800420adac:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420adb3:	00 00 00 
  800420adb6:	ff d0                	callq  *%rax
  800420adb8:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CFA.dw_offset_relevant = 1;
  800420adbc:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420adc0:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  800420adc3:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420adc7:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_regnum = reg;
  800420adcb:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420adcf:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420add3:	66 89 50 02          	mov    %dx,0x2(%rax)
			CFA.dw_offset_or_block_len = uoff;
  800420add7:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420addb:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420addf:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  800420ade3:	e9 69 06 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_register:
			*row_pc = pc;
  800420ade8:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420adec:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420adf0:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420adf3:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420adf7:	48 89 c7             	mov    %rax,%rdi
  800420adfa:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ae01:	00 00 00 
  800420ae04:	ff d0                	callq  *%rax
  800420ae06:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CFA.dw_regnum = reg;
  800420ae0a:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae0e:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ae12:	66 89 50 02          	mov    %dx,0x2(%rax)
			 * Note that DW_CFA_def_cfa_register change the CFA
			 * rule register while keep the old offset. So we
			 * should not touch the CFA.dw_offset_relevant flag
			 * here.
			 */
			break;
  800420ae16:	e9 36 06 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_offset:
			*row_pc = pc;
  800420ae1b:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ae1f:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ae23:	48 89 10             	mov    %rdx,(%rax)
			uoff = _dwarf_decode_uleb128(&p);
  800420ae26:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ae2a:	48 89 c7             	mov    %rax,%rdi
  800420ae2d:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ae34:	00 00 00 
  800420ae37:	ff d0                	callq  *%rax
  800420ae39:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CFA.dw_offset_relevant = 1;
  800420ae3d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae41:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  800420ae44:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae48:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_offset_or_block_len = uoff;
  800420ae4c:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae50:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420ae54:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  800420ae58:	e9 f4 05 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_expression:
			*row_pc = pc;
  800420ae5d:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420ae61:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420ae65:	48 89 10             	mov    %rdx,(%rax)
			CFA.dw_offset_relevant = 0;
  800420ae68:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae6c:	c6 00 00             	movb   $0x0,(%rax)
			CFA.dw_value_type = DW_EXPR_EXPRESSION;
  800420ae6f:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae73:	c6 40 01 02          	movb   $0x2,0x1(%rax)
			CFA.dw_offset_or_block_len = _dwarf_decode_uleb128(&p);
  800420ae77:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  800420ae7b:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420ae7f:	48 89 c7             	mov    %rax,%rdi
  800420ae82:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ae89:	00 00 00 
  800420ae8c:	ff d0                	callq  *%rax
  800420ae8e:	48 89 43 08          	mov    %rax,0x8(%rbx)
			CFA.dw_block_ptr = p;
  800420ae92:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420ae96:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800420ae9a:	48 89 50 10          	mov    %rdx,0x10(%rax)
			p += CFA.dw_offset_or_block_len;
  800420ae9e:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  800420aea2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aea6:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420aeaa:	48 01 d0             	add    %rdx,%rax
  800420aead:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  800420aeb1:	e9 9b 05 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_expression:
			*row_pc = pc;
  800420aeb6:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420aeba:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420aebe:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420aec1:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420aec5:	48 89 c7             	mov    %rax,%rdi
  800420aec8:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420aecf:	00 00 00 
  800420aed2:	ff d0                	callq  *%rax
  800420aed4:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420aed8:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aedc:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420aee0:	0f b7 c0             	movzwl %ax,%eax
  800420aee3:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420aee7:	77 0c                	ja     800420aef5 <_dwarf_frame_run_inst+0x865>
  800420aee9:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420aef0:	e9 6a 05 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  800420aef5:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420aef9:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420aefd:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420af01:	48 89 d0             	mov    %rdx,%rax
  800420af04:	48 01 c0             	add    %rax,%rax
  800420af07:	48 01 d0             	add    %rdx,%rax
  800420af0a:	48 c1 e0 03          	shl    $0x3,%rax
  800420af0e:	48 01 c8             	add    %rcx,%rax
  800420af11:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_value_type = DW_EXPR_EXPRESSION;
  800420af14:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420af18:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420af1c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420af20:	48 89 d0             	mov    %rdx,%rax
  800420af23:	48 01 c0             	add    %rax,%rax
  800420af26:	48 01 d0             	add    %rdx,%rax
  800420af29:	48 c1 e0 03          	shl    $0x3,%rax
  800420af2d:	48 01 c8             	add    %rcx,%rax
  800420af30:	c6 40 01 02          	movb   $0x2,0x1(%rax)
			RL[reg].dw_offset_or_block_len =
  800420af34:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420af38:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420af3c:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420af40:	48 89 d0             	mov    %rdx,%rax
  800420af43:	48 01 c0             	add    %rax,%rax
  800420af46:	48 01 d0             	add    %rdx,%rax
  800420af49:	48 c1 e0 03          	shl    $0x3,%rax
  800420af4d:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
				_dwarf_decode_uleb128(&p);
  800420af51:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420af55:	48 89 c7             	mov    %rax,%rdi
  800420af58:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420af5f:	00 00 00 
  800420af62:	ff d0                	callq  *%rax
			*row_pc = pc;
			reg = _dwarf_decode_uleb128(&p);
			CHECK_TABLE_SIZE(reg);
			RL[reg].dw_offset_relevant = 0;
			RL[reg].dw_value_type = DW_EXPR_EXPRESSION;
			RL[reg].dw_offset_or_block_len =
  800420af64:	48 89 43 08          	mov    %rax,0x8(%rbx)
				_dwarf_decode_uleb128(&p);
			RL[reg].dw_block_ptr = p;
  800420af68:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420af6c:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420af70:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420af74:	48 89 d0             	mov    %rdx,%rax
  800420af77:	48 01 c0             	add    %rax,%rax
  800420af7a:	48 01 d0             	add    %rdx,%rax
  800420af7d:	48 c1 e0 03          	shl    $0x3,%rax
  800420af81:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420af85:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420af89:	48 89 42 10          	mov    %rax,0x10(%rdx)
			p += RL[reg].dw_offset_or_block_len;
  800420af8d:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800420af91:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420af95:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420af99:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420af9d:	48 89 d0             	mov    %rdx,%rax
  800420afa0:	48 01 c0             	add    %rax,%rax
  800420afa3:	48 01 d0             	add    %rdx,%rax
  800420afa6:	48 c1 e0 03          	shl    $0x3,%rax
  800420afaa:	48 01 f0             	add    %rsi,%rax
  800420afad:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420afb1:	48 01 c8             	add    %rcx,%rax
  800420afb4:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  800420afb8:	e9 94 04 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_offset_extended_sf:
			*row_pc = pc;
  800420afbd:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420afc1:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420afc5:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420afc8:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420afcc:	48 89 c7             	mov    %rax,%rdi
  800420afcf:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420afd6:	00 00 00 
  800420afd9:	ff d0                	callq  *%rax
  800420afdb:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  800420afdf:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420afe3:	48 89 c7             	mov    %rax,%rdi
  800420afe6:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  800420afed:	00 00 00 
  800420aff0:	ff d0                	callq  *%rax
  800420aff2:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420aff6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420affa:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420affe:	0f b7 c0             	movzwl %ax,%eax
  800420b001:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420b005:	77 0c                	ja     800420b013 <_dwarf_frame_run_inst+0x983>
  800420b007:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420b00e:	e9 4c 04 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  800420b013:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b017:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b01b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b01f:	48 89 d0             	mov    %rdx,%rax
  800420b022:	48 01 c0             	add    %rax,%rax
  800420b025:	48 01 d0             	add    %rdx,%rax
  800420b028:	48 c1 e0 03          	shl    $0x3,%rax
  800420b02c:	48 01 c8             	add    %rcx,%rax
  800420b02f:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_OFFSET;
  800420b032:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b036:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b03a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b03e:	48 89 d0             	mov    %rdx,%rax
  800420b041:	48 01 c0             	add    %rax,%rax
  800420b044:	48 01 d0             	add    %rdx,%rax
  800420b047:	48 c1 e0 03          	shl    $0x3,%rax
  800420b04b:	48 01 c8             	add    %rcx,%rax
  800420b04e:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420b052:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b056:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b05a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b05e:	48 89 d0             	mov    %rdx,%rax
  800420b061:	48 01 c0             	add    %rax,%rax
  800420b064:	48 01 d0             	add    %rdx,%rax
  800420b067:	48 c1 e0 03          	shl    $0x3,%rax
  800420b06b:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b06f:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420b073:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420b077:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = soff * daf;
  800420b07b:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b07f:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b083:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b087:	48 89 d0             	mov    %rdx,%rax
  800420b08a:	48 01 c0             	add    %rax,%rax
  800420b08d:	48 01 d0             	add    %rdx,%rax
  800420b090:	48 c1 e0 03          	shl    $0x3,%rax
  800420b094:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b098:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420b09f:	48 0f af 45 b8       	imul   -0x48(%rbp),%rax
  800420b0a4:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  800420b0a8:	e9 a4 03 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_sf:
			*row_pc = pc;
  800420b0ad:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420b0b1:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420b0b5:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420b0b8:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b0bc:	48 89 c7             	mov    %rax,%rdi
  800420b0bf:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b0c6:	00 00 00 
  800420b0c9:	ff d0                	callq  *%rax
  800420b0cb:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  800420b0cf:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b0d3:	48 89 c7             	mov    %rax,%rdi
  800420b0d6:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  800420b0dd:	00 00 00 
  800420b0e0:	ff d0                	callq  *%rax
  800420b0e2:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CFA.dw_offset_relevant = 1;
  800420b0e6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b0ea:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  800420b0ed:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b0f1:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_regnum = reg;
  800420b0f5:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b0f9:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b0fd:	66 89 50 02          	mov    %dx,0x2(%rax)
			CFA.dw_offset_or_block_len = soff * daf;
  800420b101:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b105:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  800420b10c:	48 0f af 55 b8       	imul   -0x48(%rbp),%rdx
  800420b111:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  800420b115:	e9 37 03 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_def_cfa_offset_sf:
			*row_pc = pc;
  800420b11a:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420b11e:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420b122:	48 89 10             	mov    %rdx,(%rax)
			soff = _dwarf_decode_sleb128(&p);
  800420b125:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b129:	48 89 c7             	mov    %rax,%rdi
  800420b12c:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  800420b133:	00 00 00 
  800420b136:	ff d0                	callq  *%rax
  800420b138:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CFA.dw_offset_relevant = 1;
  800420b13c:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b140:	c6 00 01             	movb   $0x1,(%rax)
			CFA.dw_value_type = DW_EXPR_OFFSET;
  800420b143:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b147:	c6 40 01 00          	movb   $0x0,0x1(%rax)
			CFA.dw_offset_or_block_len = soff * daf;
  800420b14b:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b14f:	48 8b 95 70 ff ff ff 	mov    -0x90(%rbp),%rdx
  800420b156:	48 0f af 55 b8       	imul   -0x48(%rbp),%rdx
  800420b15b:	48 89 50 08          	mov    %rdx,0x8(%rax)
			break;
  800420b15f:	e9 ed 02 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_offset:
			*row_pc = pc;
  800420b164:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420b168:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420b16c:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420b16f:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b173:	48 89 c7             	mov    %rax,%rdi
  800420b176:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b17d:	00 00 00 
  800420b180:	ff d0                	callq  *%rax
  800420b182:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			uoff = _dwarf_decode_uleb128(&p);
  800420b186:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b18a:	48 89 c7             	mov    %rax,%rdi
  800420b18d:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b194:	00 00 00 
  800420b197:	ff d0                	callq  *%rax
  800420b199:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420b19d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b1a1:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420b1a5:	0f b7 c0             	movzwl %ax,%eax
  800420b1a8:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420b1ac:	77 0c                	ja     800420b1ba <_dwarf_frame_run_inst+0xb2a>
  800420b1ae:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420b1b5:	e9 a5 02 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  800420b1ba:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b1be:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b1c2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b1c6:	48 89 d0             	mov    %rdx,%rax
  800420b1c9:	48 01 c0             	add    %rax,%rax
  800420b1cc:	48 01 d0             	add    %rdx,%rax
  800420b1cf:	48 c1 e0 03          	shl    $0x3,%rax
  800420b1d3:	48 01 c8             	add    %rcx,%rax
  800420b1d6:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_OFFSET;
  800420b1d9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b1dd:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b1e1:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b1e5:	48 89 d0             	mov    %rdx,%rax
  800420b1e8:	48 01 c0             	add    %rax,%rax
  800420b1eb:	48 01 d0             	add    %rdx,%rax
  800420b1ee:	48 c1 e0 03          	shl    $0x3,%rax
  800420b1f2:	48 01 c8             	add    %rcx,%rax
  800420b1f5:	c6 40 01 01          	movb   $0x1,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420b1f9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b1fd:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b201:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b205:	48 89 d0             	mov    %rdx,%rax
  800420b208:	48 01 c0             	add    %rax,%rax
  800420b20b:	48 01 d0             	add    %rdx,%rax
  800420b20e:	48 c1 e0 03          	shl    $0x3,%rax
  800420b212:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b216:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420b21a:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420b21e:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = uoff * daf;
  800420b222:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b226:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b22a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b22e:	48 89 d0             	mov    %rdx,%rax
  800420b231:	48 01 c0             	add    %rax,%rax
  800420b234:	48 01 d0             	add    %rdx,%rax
  800420b237:	48 c1 e0 03          	shl    $0x3,%rax
  800420b23b:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b23f:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420b246:	48 0f af 45 c8       	imul   -0x38(%rbp),%rax
  800420b24b:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  800420b24f:	e9 fd 01 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_offset_sf:
			*row_pc = pc;
  800420b254:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420b258:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420b25c:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420b25f:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b263:	48 89 c7             	mov    %rax,%rdi
  800420b266:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b26d:	00 00 00 
  800420b270:	ff d0                	callq  *%rax
  800420b272:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			soff = _dwarf_decode_sleb128(&p);
  800420b276:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b27a:	48 89 c7             	mov    %rax,%rdi
  800420b27d:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  800420b284:	00 00 00 
  800420b287:	ff d0                	callq  *%rax
  800420b289:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420b28d:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b291:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420b295:	0f b7 c0             	movzwl %ax,%eax
  800420b298:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420b29c:	77 0c                	ja     800420b2aa <_dwarf_frame_run_inst+0xc1a>
  800420b29e:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420b2a5:	e9 b5 01 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 1;
  800420b2aa:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b2ae:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b2b2:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b2b6:	48 89 d0             	mov    %rdx,%rax
  800420b2b9:	48 01 c0             	add    %rax,%rax
  800420b2bc:	48 01 d0             	add    %rdx,%rax
  800420b2bf:	48 c1 e0 03          	shl    $0x3,%rax
  800420b2c3:	48 01 c8             	add    %rcx,%rax
  800420b2c6:	c6 00 01             	movb   $0x1,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_OFFSET;
  800420b2c9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b2cd:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b2d1:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b2d5:	48 89 d0             	mov    %rdx,%rax
  800420b2d8:	48 01 c0             	add    %rax,%rax
  800420b2db:	48 01 d0             	add    %rdx,%rax
  800420b2de:	48 c1 e0 03          	shl    $0x3,%rax
  800420b2e2:	48 01 c8             	add    %rcx,%rax
  800420b2e5:	c6 40 01 01          	movb   $0x1,0x1(%rax)
			RL[reg].dw_regnum = dbg->dbg_frame_cfa_value;
  800420b2e9:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b2ed:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b2f1:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b2f5:	48 89 d0             	mov    %rdx,%rax
  800420b2f8:	48 01 c0             	add    %rax,%rax
  800420b2fb:	48 01 d0             	add    %rdx,%rax
  800420b2fe:	48 c1 e0 03          	shl    $0x3,%rax
  800420b302:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b306:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420b30a:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420b30e:	66 89 42 02          	mov    %ax,0x2(%rdx)
			RL[reg].dw_offset_or_block_len = soff * daf;
  800420b312:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b316:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b31a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b31e:	48 89 d0             	mov    %rdx,%rax
  800420b321:	48 01 c0             	add    %rax,%rax
  800420b324:	48 01 d0             	add    %rdx,%rax
  800420b327:	48 c1 e0 03          	shl    $0x3,%rax
  800420b32b:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b32f:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420b336:	48 0f af 45 b8       	imul   -0x48(%rbp),%rax
  800420b33b:	48 89 42 08          	mov    %rax,0x8(%rdx)
			break;
  800420b33f:	e9 0d 01 00 00       	jmpq   800420b451 <_dwarf_frame_run_inst+0xdc1>
		case DW_CFA_val_expression:
			*row_pc = pc;
  800420b344:	48 8b 45 20          	mov    0x20(%rbp),%rax
  800420b348:	48 8b 55 10          	mov    0x10(%rbp),%rdx
  800420b34c:	48 89 10             	mov    %rdx,(%rax)
			reg = _dwarf_decode_uleb128(&p);
  800420b34f:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b353:	48 89 c7             	mov    %rax,%rdi
  800420b356:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b35d:	00 00 00 
  800420b360:	ff d0                	callq  *%rax
  800420b362:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
			CHECK_TABLE_SIZE(reg);
  800420b366:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b36a:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420b36e:	0f b7 c0             	movzwl %ax,%eax
  800420b371:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
  800420b375:	77 0c                	ja     800420b383 <_dwarf_frame_run_inst+0xcf3>
  800420b377:	c7 45 ec 18 00 00 00 	movl   $0x18,-0x14(%rbp)
  800420b37e:	e9 dc 00 00 00       	jmpq   800420b45f <_dwarf_frame_run_inst+0xdcf>
			RL[reg].dw_offset_relevant = 0;
  800420b383:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b387:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b38b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b38f:	48 89 d0             	mov    %rdx,%rax
  800420b392:	48 01 c0             	add    %rax,%rax
  800420b395:	48 01 d0             	add    %rdx,%rax
  800420b398:	48 c1 e0 03          	shl    $0x3,%rax
  800420b39c:	48 01 c8             	add    %rcx,%rax
  800420b39f:	c6 00 00             	movb   $0x0,(%rax)
			RL[reg].dw_value_type = DW_EXPR_VAL_EXPRESSION;
  800420b3a2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b3a6:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b3aa:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b3ae:	48 89 d0             	mov    %rdx,%rax
  800420b3b1:	48 01 c0             	add    %rax,%rax
  800420b3b4:	48 01 d0             	add    %rdx,%rax
  800420b3b7:	48 c1 e0 03          	shl    $0x3,%rax
  800420b3bb:	48 01 c8             	add    %rcx,%rax
  800420b3be:	c6 40 01 03          	movb   $0x3,0x1(%rax)
			RL[reg].dw_offset_or_block_len =
  800420b3c2:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b3c6:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b3ca:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b3ce:	48 89 d0             	mov    %rdx,%rax
  800420b3d1:	48 01 c0             	add    %rax,%rax
  800420b3d4:	48 01 d0             	add    %rdx,%rax
  800420b3d7:	48 c1 e0 03          	shl    $0x3,%rax
  800420b3db:	48 8d 1c 01          	lea    (%rcx,%rax,1),%rbx
				_dwarf_decode_uleb128(&p);
  800420b3df:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
  800420b3e3:	48 89 c7             	mov    %rax,%rdi
  800420b3e6:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420b3ed:	00 00 00 
  800420b3f0:	ff d0                	callq  *%rax
			*row_pc = pc;
			reg = _dwarf_decode_uleb128(&p);
			CHECK_TABLE_SIZE(reg);
			RL[reg].dw_offset_relevant = 0;
			RL[reg].dw_value_type = DW_EXPR_VAL_EXPRESSION;
			RL[reg].dw_offset_or_block_len =
  800420b3f2:	48 89 43 08          	mov    %rax,0x8(%rbx)
				_dwarf_decode_uleb128(&p);
			RL[reg].dw_block_ptr = p;
  800420b3f6:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b3fa:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b3fe:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b402:	48 89 d0             	mov    %rdx,%rax
  800420b405:	48 01 c0             	add    %rax,%rax
  800420b408:	48 01 d0             	add    %rdx,%rax
  800420b40b:	48 c1 e0 03          	shl    $0x3,%rax
  800420b40f:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b413:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420b417:	48 89 42 10          	mov    %rax,0x10(%rdx)
			p += RL[reg].dw_offset_or_block_len;
  800420b41b:	48 8b 4d a0          	mov    -0x60(%rbp),%rcx
  800420b41f:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420b423:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420b427:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420b42b:	48 89 d0             	mov    %rdx,%rax
  800420b42e:	48 01 c0             	add    %rax,%rax
  800420b431:	48 01 d0             	add    %rdx,%rax
  800420b434:	48 c1 e0 03          	shl    $0x3,%rax
  800420b438:	48 01 f0             	add    %rsi,%rax
  800420b43b:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420b43f:	48 01 c8             	add    %rcx,%rax
  800420b442:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
			break;
  800420b446:	eb 09                	jmp    800420b451 <_dwarf_frame_run_inst+0xdc1>
		default:
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_FRAME_INSTR_EXEC_ERROR);
			ret = DW_DLE_FRAME_INSTR_EXEC_ERROR;
  800420b448:	c7 45 ec 15 00 00 00 	movl   $0x15,-0x14(%rbp)
			goto program_done;
  800420b44f:	eb 0e                	jmp    800420b45f <_dwarf_frame_run_inst+0xdcf>
	/* Save a copy of the table as initial state. */
	_dwarf_frame_regtable_copy(dbg, &init_rt, rt, error);
	p = insts;
	pe = p + len;

	while (p < pe) {
  800420b451:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420b455:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420b459:	0f 82 b8 f2 ff ff    	jb     800420a717 <_dwarf_frame_run_inst+0x87>
			goto program_done;
		}
	}

program_done:
	return (ret);
  800420b45f:	8b 45 ec             	mov    -0x14(%rbp),%eax
#undef  CFA
#undef  INITCFA
#undef  RL
#undef  INITRL
#undef  CHECK_TABLE_SIZE
}
  800420b462:	48 81 c4 88 00 00 00 	add    $0x88,%rsp
  800420b469:	5b                   	pop    %rbx
  800420b46a:	5d                   	pop    %rbp
  800420b46b:	c3                   	retq   

000000800420b46c <_dwarf_frame_get_internal_table>:
int
_dwarf_frame_get_internal_table(Dwarf_Debug dbg, Dwarf_Fde fde,
				Dwarf_Addr pc_req, Dwarf_Regtable3 **ret_rt,
				Dwarf_Addr *ret_row_pc,
				Dwarf_Error *error)
{
  800420b46c:	55                   	push   %rbp
  800420b46d:	48 89 e5             	mov    %rsp,%rbp
  800420b470:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
  800420b474:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420b478:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420b47c:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800420b480:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  800420b484:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
  800420b488:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
	Dwarf_Cie cie;
	Dwarf_Regtable3 *rt;
	Dwarf_Addr row_pc;
	int i, ret;

	assert(ret_rt != NULL);
  800420b48c:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
  800420b491:	75 35                	jne    800420b4c8 <_dwarf_frame_get_internal_table+0x5c>
  800420b493:	48 b9 f8 fd 20 04 80 	movabs $0x800420fdf8,%rcx
  800420b49a:	00 00 00 
  800420b49d:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420b4a4:	00 00 00 
  800420b4a7:	be 83 01 00 00       	mov    $0x183,%esi
  800420b4ac:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420b4b3:	00 00 00 
  800420b4b6:	b8 00 00 00 00       	mov    $0x0,%eax
  800420b4bb:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420b4c2:	00 00 00 
  800420b4c5:	41 ff d0             	callq  *%r8

	//dbg = fde->fde_dbg;
	assert(dbg != NULL);
  800420b4c8:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800420b4cd:	75 35                	jne    800420b504 <_dwarf_frame_get_internal_table+0x98>
  800420b4cf:	48 b9 07 fe 20 04 80 	movabs $0x800420fe07,%rcx
  800420b4d6:	00 00 00 
  800420b4d9:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420b4e0:	00 00 00 
  800420b4e3:	be 86 01 00 00       	mov    $0x186,%esi
  800420b4e8:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420b4ef:	00 00 00 
  800420b4f2:	b8 00 00 00 00       	mov    $0x0,%eax
  800420b4f7:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420b4fe:	00 00 00 
  800420b501:	41 ff d0             	callq  *%r8

	rt = dbg->dbg_internal_reg_table;
  800420b504:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420b508:	48 8b 40 58          	mov    0x58(%rax),%rax
  800420b50c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	/* Clear the content of regtable from previous run. */
	memset(&rt->rt3_cfa_rule, 0, sizeof(Dwarf_Regtable_Entry3));
  800420b510:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420b514:	ba 18 00 00 00       	mov    $0x18,%edx
  800420b519:	be 00 00 00 00       	mov    $0x0,%esi
  800420b51e:	48 89 c7             	mov    %rax,%rdi
  800420b521:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420b528:	00 00 00 
  800420b52b:	ff d0                	callq  *%rax
	memset(rt->rt3_rules, 0, rt->rt3_reg_table_size *
  800420b52d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420b531:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420b535:	0f b7 d0             	movzwl %ax,%edx
  800420b538:	48 89 d0             	mov    %rdx,%rax
  800420b53b:	48 01 c0             	add    %rax,%rax
  800420b53e:	48 01 d0             	add    %rdx,%rax
  800420b541:	48 c1 e0 03          	shl    $0x3,%rax
  800420b545:	48 89 c2             	mov    %rax,%rdx
  800420b548:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420b54c:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420b550:	be 00 00 00 00       	mov    $0x0,%esi
  800420b555:	48 89 c7             	mov    %rax,%rdi
  800420b558:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420b55f:	00 00 00 
  800420b562:	ff d0                	callq  *%rax
	       sizeof(Dwarf_Regtable_Entry3));

	/* Set rules to initial values. */
	for (i = 0; i < rt->rt3_reg_table_size; i++)
  800420b564:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  800420b56b:	eb 2f                	jmp    800420b59c <_dwarf_frame_get_internal_table+0x130>
		rt->rt3_rules[i].dw_regnum = dbg->dbg_frame_rule_initial_value;
  800420b56d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420b571:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b575:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420b578:	48 63 d0             	movslq %eax,%rdx
  800420b57b:	48 89 d0             	mov    %rdx,%rax
  800420b57e:	48 01 c0             	add    %rax,%rax
  800420b581:	48 01 d0             	add    %rdx,%rax
  800420b584:	48 c1 e0 03          	shl    $0x3,%rax
  800420b588:	48 8d 14 01          	lea    (%rcx,%rax,1),%rdx
  800420b58c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420b590:	0f b7 40 4a          	movzwl 0x4a(%rax),%eax
  800420b594:	66 89 42 02          	mov    %ax,0x2(%rdx)
	memset(&rt->rt3_cfa_rule, 0, sizeof(Dwarf_Regtable_Entry3));
	memset(rt->rt3_rules, 0, rt->rt3_reg_table_size *
	       sizeof(Dwarf_Regtable_Entry3));

	/* Set rules to initial values. */
	for (i = 0; i < rt->rt3_reg_table_size; i++)
  800420b598:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  800420b59c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420b5a0:	0f b7 40 18          	movzwl 0x18(%rax),%eax
  800420b5a4:	0f b7 c0             	movzwl %ax,%eax
  800420b5a7:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  800420b5aa:	7f c1                	jg     800420b56d <_dwarf_frame_get_internal_table+0x101>
		rt->rt3_rules[i].dw_regnum = dbg->dbg_frame_rule_initial_value;

	/* Run initial instructions in CIE. */
	cie = fde->fde_cie;
  800420b5ac:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b5b0:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420b5b4:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	assert(cie != NULL);
  800420b5b8:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
  800420b5bd:	75 35                	jne    800420b5f4 <_dwarf_frame_get_internal_table+0x188>
  800420b5bf:	48 b9 13 fe 20 04 80 	movabs $0x800420fe13,%rcx
  800420b5c6:	00 00 00 
  800420b5c9:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420b5d0:	00 00 00 
  800420b5d3:	be 95 01 00 00       	mov    $0x195,%esi
  800420b5d8:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420b5df:	00 00 00 
  800420b5e2:	b8 00 00 00 00       	mov    $0x0,%eax
  800420b5e7:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420b5ee:	00 00 00 
  800420b5f1:	41 ff d0             	callq  *%r8
	ret = _dwarf_frame_run_inst(dbg, rt, cie->cie_initinst,
  800420b5f4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b5f8:	4c 8b 48 40          	mov    0x40(%rax),%r9
  800420b5fc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b600:	4c 8b 40 38          	mov    0x38(%rax),%r8
  800420b604:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b608:	48 8b 48 70          	mov    0x70(%rax),%rcx
  800420b60c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b610:	48 8b 50 68          	mov    0x68(%rax),%rdx
  800420b614:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  800420b618:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420b61c:	48 8b 7d a0          	mov    -0x60(%rbp),%rdi
  800420b620:	48 89 7c 24 18       	mov    %rdi,0x18(%rsp)
  800420b625:	48 8d 7d d8          	lea    -0x28(%rbp),%rdi
  800420b629:	48 89 7c 24 10       	mov    %rdi,0x10(%rsp)
  800420b62e:	48 c7 44 24 08 ff ff 	movq   $0xffffffffffffffff,0x8(%rsp)
  800420b635:	ff ff 
  800420b637:	48 c7 04 24 00 00 00 	movq   $0x0,(%rsp)
  800420b63e:	00 
  800420b63f:	48 89 c7             	mov    %rax,%rdi
  800420b642:	48 b8 90 a6 20 04 80 	movabs $0x800420a690,%rax
  800420b649:	00 00 00 
  800420b64c:	ff d0                	callq  *%rax
  800420b64e:	89 45 e4             	mov    %eax,-0x1c(%rbp)
				    cie->cie_instlen, cie->cie_caf,
				    cie->cie_daf, 0, ~0ULL,
				    &row_pc, error);
	if (ret != DW_DLE_NONE)
  800420b651:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800420b655:	74 08                	je     800420b65f <_dwarf_frame_get_internal_table+0x1f3>
		return (ret);
  800420b657:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420b65a:	e9 98 00 00 00       	jmpq   800420b6f7 <_dwarf_frame_get_internal_table+0x28b>
	/* Run instructions in FDE. */
	if (pc_req >= fde->fde_initloc) {
  800420b65f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b663:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420b667:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
  800420b66b:	77 6f                	ja     800420b6dc <_dwarf_frame_get_internal_table+0x270>
		ret = _dwarf_frame_run_inst(dbg, rt, fde->fde_inst,
  800420b66d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b671:	48 8b 78 30          	mov    0x30(%rax),%rdi
  800420b675:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b679:	4c 8b 48 40          	mov    0x40(%rax),%r9
  800420b67d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b681:	4c 8b 50 38          	mov    0x38(%rax),%r10
  800420b685:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b689:	48 8b 48 58          	mov    0x58(%rax),%rcx
  800420b68d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b691:	48 8b 50 50          	mov    0x50(%rax),%rdx
  800420b695:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
  800420b699:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420b69d:	4c 8b 45 a0          	mov    -0x60(%rbp),%r8
  800420b6a1:	4c 89 44 24 18       	mov    %r8,0x18(%rsp)
  800420b6a6:	4c 8d 45 d8          	lea    -0x28(%rbp),%r8
  800420b6aa:	4c 89 44 24 10       	mov    %r8,0x10(%rsp)
  800420b6af:	4c 8b 45 b8          	mov    -0x48(%rbp),%r8
  800420b6b3:	4c 89 44 24 08       	mov    %r8,0x8(%rsp)
  800420b6b8:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420b6bc:	4d 89 d0             	mov    %r10,%r8
  800420b6bf:	48 89 c7             	mov    %rax,%rdi
  800420b6c2:	48 b8 90 a6 20 04 80 	movabs $0x800420a690,%rax
  800420b6c9:	00 00 00 
  800420b6cc:	ff d0                	callq  *%rax
  800420b6ce:	89 45 e4             	mov    %eax,-0x1c(%rbp)
					    fde->fde_instlen, cie->cie_caf,
					    cie->cie_daf,
					    fde->fde_initloc, pc_req,
					    &row_pc, error);
		if (ret != DW_DLE_NONE)
  800420b6d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  800420b6d5:	74 05                	je     800420b6dc <_dwarf_frame_get_internal_table+0x270>
			return (ret);
  800420b6d7:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  800420b6da:	eb 1b                	jmp    800420b6f7 <_dwarf_frame_get_internal_table+0x28b>
	}

	*ret_rt = rt;
  800420b6dc:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420b6e0:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420b6e4:	48 89 10             	mov    %rdx,(%rax)
	*ret_row_pc = row_pc;
  800420b6e7:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420b6eb:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420b6ef:	48 89 10             	mov    %rdx,(%rax)

	return (DW_DLE_NONE);
  800420b6f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420b6f7:	c9                   	leaveq 
  800420b6f8:	c3                   	retq   

000000800420b6f9 <dwarf_get_fde_info_for_all_regs>:
int
dwarf_get_fde_info_for_all_regs(Dwarf_Debug dbg, Dwarf_Fde fde,
				Dwarf_Addr pc_requested,
				Dwarf_Regtable *reg_table, Dwarf_Addr *row_pc,
				Dwarf_Error *error)
{
  800420b6f9:	55                   	push   %rbp
  800420b6fa:	48 89 e5             	mov    %rsp,%rbp
  800420b6fd:	48 83 ec 50          	sub    $0x50,%rsp
  800420b701:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  800420b705:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420b709:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800420b70d:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
  800420b711:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
  800420b715:	4c 89 4d b0          	mov    %r9,-0x50(%rbp)
	Dwarf_Regtable3 *rt;
	Dwarf_Addr pc;
	Dwarf_Half cfa;
	int i, ret;

	if (fde == NULL || reg_table == NULL) {
  800420b719:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  800420b71e:	74 07                	je     800420b727 <dwarf_get_fde_info_for_all_regs+0x2e>
  800420b720:	48 83 7d c0 00       	cmpq   $0x0,-0x40(%rbp)
  800420b725:	75 0a                	jne    800420b731 <dwarf_get_fde_info_for_all_regs+0x38>
		DWARF_SET_ERROR(dbg, error, DW_DLE_ARGUMENT);
		return (DW_DLV_ERROR);
  800420b727:	b8 01 00 00 00       	mov    $0x1,%eax
  800420b72c:	e9 eb 02 00 00       	jmpq   800420ba1c <dwarf_get_fde_info_for_all_regs+0x323>
	}

	assert(dbg != NULL);
  800420b731:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  800420b736:	75 35                	jne    800420b76d <dwarf_get_fde_info_for_all_regs+0x74>
  800420b738:	48 b9 07 fe 20 04 80 	movabs $0x800420fe07,%rcx
  800420b73f:	00 00 00 
  800420b742:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420b749:	00 00 00 
  800420b74c:	be bf 01 00 00       	mov    $0x1bf,%esi
  800420b751:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420b758:	00 00 00 
  800420b75b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420b760:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420b767:	00 00 00 
  800420b76a:	41 ff d0             	callq  *%r8

	if (pc_requested < fde->fde_initloc ||
  800420b76d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420b771:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420b775:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  800420b779:	77 19                	ja     800420b794 <dwarf_get_fde_info_for_all_regs+0x9b>
	    pc_requested >= fde->fde_initloc + fde->fde_adrange) {
  800420b77b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420b77f:	48 8b 50 30          	mov    0x30(%rax),%rdx
  800420b783:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420b787:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420b78b:	48 01 d0             	add    %rdx,%rax
		return (DW_DLV_ERROR);
	}

	assert(dbg != NULL);

	if (pc_requested < fde->fde_initloc ||
  800420b78e:	48 3b 45 c8          	cmp    -0x38(%rbp),%rax
  800420b792:	77 0a                	ja     800420b79e <dwarf_get_fde_info_for_all_regs+0xa5>
	    pc_requested >= fde->fde_initloc + fde->fde_adrange) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_PC_NOT_IN_FDE_RANGE);
		return (DW_DLV_ERROR);
  800420b794:	b8 01 00 00 00       	mov    $0x1,%eax
  800420b799:	e9 7e 02 00 00       	jmpq   800420ba1c <dwarf_get_fde_info_for_all_regs+0x323>
	}

	ret = _dwarf_frame_get_internal_table(dbg, fde, pc_requested, &rt, &pc,
  800420b79e:	4c 8b 45 b0          	mov    -0x50(%rbp),%r8
  800420b7a2:	48 8d 7d e0          	lea    -0x20(%rbp),%rdi
  800420b7a6:	48 8d 4d e8          	lea    -0x18(%rbp),%rcx
  800420b7aa:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420b7ae:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420b7b2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420b7b6:	4d 89 c1             	mov    %r8,%r9
  800420b7b9:	49 89 f8             	mov    %rdi,%r8
  800420b7bc:	48 89 c7             	mov    %rax,%rdi
  800420b7bf:	48 b8 6c b4 20 04 80 	movabs $0x800420b46c,%rax
  800420b7c6:	00 00 00 
  800420b7c9:	ff d0                	callq  *%rax
  800420b7cb:	89 45 f8             	mov    %eax,-0x8(%rbp)
					      error);
	if (ret != DW_DLE_NONE)
  800420b7ce:	83 7d f8 00          	cmpl   $0x0,-0x8(%rbp)
  800420b7d2:	74 0a                	je     800420b7de <dwarf_get_fde_info_for_all_regs+0xe5>
		return (DW_DLV_ERROR);
  800420b7d4:	b8 01 00 00 00       	mov    $0x1,%eax
  800420b7d9:	e9 3e 02 00 00       	jmpq   800420ba1c <dwarf_get_fde_info_for_all_regs+0x323>
	/*
	 * Copy the CFA rule to the column intended for holding the CFA,
	 * if it's within the range of regtable.
	 */
#define CFA rt->rt3_cfa_rule
	cfa = dbg->dbg_frame_cfa_value;
  800420b7de:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420b7e2:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420b7e6:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
	if (cfa < DW_REG_TABLE_SIZE) {
  800420b7ea:	66 83 7d f6 41       	cmpw   $0x41,-0xa(%rbp)
  800420b7ef:	0f 87 b1 00 00 00    	ja     800420b8a6 <dwarf_get_fde_info_for_all_regs+0x1ad>
		reg_table->rules[cfa].dw_offset_relevant =
  800420b7f5:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
			CFA.dw_offset_relevant;
  800420b7f9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b7fd:	0f b6 00             	movzbl (%rax),%eax
	 * if it's within the range of regtable.
	 */
#define CFA rt->rt3_cfa_rule
	cfa = dbg->dbg_frame_cfa_value;
	if (cfa < DW_REG_TABLE_SIZE) {
		reg_table->rules[cfa].dw_offset_relevant =
  800420b800:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b804:	48 63 c9             	movslq %ecx,%rcx
  800420b807:	48 83 c1 01          	add    $0x1,%rcx
  800420b80b:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b80f:	48 01 ca             	add    %rcx,%rdx
  800420b812:	88 02                	mov    %al,(%rdx)
			CFA.dw_offset_relevant;
		reg_table->rules[cfa].dw_value_type = CFA.dw_value_type;
  800420b814:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420b818:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b81c:	0f b6 40 01          	movzbl 0x1(%rax),%eax
  800420b820:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b824:	48 63 c9             	movslq %ecx,%rcx
  800420b827:	48 83 c1 01          	add    $0x1,%rcx
  800420b82b:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b82f:	48 01 ca             	add    %rcx,%rdx
  800420b832:	88 42 01             	mov    %al,0x1(%rdx)
		reg_table->rules[cfa].dw_regnum = CFA.dw_regnum;
  800420b835:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420b839:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b83d:	0f b7 40 02          	movzwl 0x2(%rax),%eax
  800420b841:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b845:	48 63 c9             	movslq %ecx,%rcx
  800420b848:	48 83 c1 01          	add    $0x1,%rcx
  800420b84c:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b850:	48 01 ca             	add    %rcx,%rdx
  800420b853:	66 89 42 02          	mov    %ax,0x2(%rdx)
		reg_table->rules[cfa].dw_offset = CFA.dw_offset_or_block_len;
  800420b857:	0f b7 4d f6          	movzwl -0xa(%rbp),%ecx
  800420b85b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b85f:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420b863:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b867:	48 63 c9             	movslq %ecx,%rcx
  800420b86a:	48 83 c1 01          	add    $0x1,%rcx
  800420b86e:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b872:	48 01 ca             	add    %rcx,%rdx
  800420b875:	48 83 c2 08          	add    $0x8,%rdx
  800420b879:	48 89 02             	mov    %rax,(%rdx)
		reg_table->cfa_rule = reg_table->rules[cfa];
  800420b87c:	0f b7 55 f6          	movzwl -0xa(%rbp),%edx
  800420b880:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  800420b884:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b888:	48 63 d2             	movslq %edx,%rdx
  800420b88b:	48 83 c2 01          	add    $0x1,%rdx
  800420b88f:	48 c1 e2 04          	shl    $0x4,%rdx
  800420b893:	48 01 d0             	add    %rdx,%rax
  800420b896:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420b89a:	48 8b 00             	mov    (%rax),%rax
  800420b89d:	48 89 01             	mov    %rax,(%rcx)
  800420b8a0:	48 89 51 08          	mov    %rdx,0x8(%rcx)
  800420b8a4:	eb 3c                	jmp    800420b8e2 <dwarf_get_fde_info_for_all_regs+0x1e9>
	} else {
		reg_table->cfa_rule.dw_offset_relevant =
		    CFA.dw_offset_relevant;
  800420b8a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b8aa:	0f b6 10             	movzbl (%rax),%edx
		reg_table->rules[cfa].dw_value_type = CFA.dw_value_type;
		reg_table->rules[cfa].dw_regnum = CFA.dw_regnum;
		reg_table->rules[cfa].dw_offset = CFA.dw_offset_or_block_len;
		reg_table->cfa_rule = reg_table->rules[cfa];
	} else {
		reg_table->cfa_rule.dw_offset_relevant =
  800420b8ad:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b8b1:	88 10                	mov    %dl,(%rax)
		    CFA.dw_offset_relevant;
		reg_table->cfa_rule.dw_value_type = CFA.dw_value_type;
  800420b8b3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b8b7:	0f b6 50 01          	movzbl 0x1(%rax),%edx
  800420b8bb:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b8bf:	88 50 01             	mov    %dl,0x1(%rax)
		reg_table->cfa_rule.dw_regnum = CFA.dw_regnum;
  800420b8c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b8c6:	0f b7 50 02          	movzwl 0x2(%rax),%edx
  800420b8ca:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b8ce:	66 89 50 02          	mov    %dx,0x2(%rax)
		reg_table->cfa_rule.dw_offset = CFA.dw_offset_or_block_len;
  800420b8d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b8d6:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420b8da:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420b8de:	48 89 50 08          	mov    %rdx,0x8(%rax)
	}

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
  800420b8e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  800420b8e9:	e9 fd 00 00 00       	jmpq   800420b9eb <dwarf_get_fde_info_for_all_regs+0x2f2>
	     i++) {

		/* Do not overwrite CFA column */
		if (i == cfa)
  800420b8ee:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
  800420b8f2:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  800420b8f5:	75 05                	jne    800420b8fc <dwarf_get_fde_info_for_all_regs+0x203>
			continue;
  800420b8f7:	e9 eb 00 00 00       	jmpq   800420b9e7 <dwarf_get_fde_info_for_all_regs+0x2ee>

		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
  800420b8fc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b900:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b904:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420b907:	48 63 d0             	movslq %eax,%rdx
  800420b90a:	48 89 d0             	mov    %rdx,%rax
  800420b90d:	48 01 c0             	add    %rax,%rax
  800420b910:	48 01 d0             	add    %rdx,%rax
  800420b913:	48 c1 e0 03          	shl    $0x3,%rax
  800420b917:	48 01 c8             	add    %rcx,%rax
  800420b91a:	0f b6 00             	movzbl (%rax),%eax

		/* Do not overwrite CFA column */
		if (i == cfa)
			continue;

		reg_table->rules[i].dw_offset_relevant =
  800420b91d:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b921:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  800420b924:	48 63 c9             	movslq %ecx,%rcx
  800420b927:	48 83 c1 01          	add    $0x1,%rcx
  800420b92b:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b92f:	48 01 ca             	add    %rcx,%rdx
  800420b932:	88 02                	mov    %al,(%rdx)
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
			rt->rt3_rules[i].dw_value_type;
  800420b934:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b938:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b93c:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420b93f:	48 63 d0             	movslq %eax,%rdx
  800420b942:	48 89 d0             	mov    %rdx,%rax
  800420b945:	48 01 c0             	add    %rax,%rax
  800420b948:	48 01 d0             	add    %rdx,%rax
  800420b94b:	48 c1 e0 03          	shl    $0x3,%rax
  800420b94f:	48 01 c8             	add    %rcx,%rax
  800420b952:	0f b6 40 01          	movzbl 0x1(%rax),%eax
		if (i == cfa)
			continue;

		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
  800420b956:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b95a:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  800420b95d:	48 63 c9             	movslq %ecx,%rcx
  800420b960:	48 83 c1 01          	add    $0x1,%rcx
  800420b964:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b968:	48 01 ca             	add    %rcx,%rdx
  800420b96b:	88 42 01             	mov    %al,0x1(%rdx)
			rt->rt3_rules[i].dw_value_type;
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
  800420b96e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b972:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b976:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420b979:	48 63 d0             	movslq %eax,%rdx
  800420b97c:	48 89 d0             	mov    %rdx,%rax
  800420b97f:	48 01 c0             	add    %rax,%rax
  800420b982:	48 01 d0             	add    %rdx,%rax
  800420b985:	48 c1 e0 03          	shl    $0x3,%rax
  800420b989:	48 01 c8             	add    %rcx,%rax
  800420b98c:	0f b7 40 02          	movzwl 0x2(%rax),%eax
  800420b990:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b994:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  800420b997:	48 63 c9             	movslq %ecx,%rcx
  800420b99a:	48 83 c1 01          	add    $0x1,%rcx
  800420b99e:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b9a2:	48 01 ca             	add    %rcx,%rdx
  800420b9a5:	66 89 42 02          	mov    %ax,0x2(%rdx)
		reg_table->rules[i].dw_offset =
			rt->rt3_rules[i].dw_offset_or_block_len;
  800420b9a9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420b9ad:	48 8b 48 20          	mov    0x20(%rax),%rcx
  800420b9b1:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420b9b4:	48 63 d0             	movslq %eax,%rdx
  800420b9b7:	48 89 d0             	mov    %rdx,%rax
  800420b9ba:	48 01 c0             	add    %rax,%rax
  800420b9bd:	48 01 d0             	add    %rdx,%rax
  800420b9c0:	48 c1 e0 03          	shl    $0x3,%rax
  800420b9c4:	48 01 c8             	add    %rcx,%rax
  800420b9c7:	48 8b 40 08          	mov    0x8(%rax),%rax
		reg_table->rules[i].dw_offset_relevant =
			rt->rt3_rules[i].dw_offset_relevant;
		reg_table->rules[i].dw_value_type =
			rt->rt3_rules[i].dw_value_type;
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
		reg_table->rules[i].dw_offset =
  800420b9cb:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420b9cf:	8b 4d fc             	mov    -0x4(%rbp),%ecx
  800420b9d2:	48 63 c9             	movslq %ecx,%rcx
  800420b9d5:	48 83 c1 01          	add    $0x1,%rcx
  800420b9d9:	48 c1 e1 04          	shl    $0x4,%rcx
  800420b9dd:	48 01 ca             	add    %rcx,%rdx
  800420b9e0:	48 83 c2 08          	add    $0x8,%rdx
  800420b9e4:	48 89 02             	mov    %rax,(%rdx)

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
	     i++) {
  800420b9e7:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
	}

	/*
	 * Copy other columns.
	 */
	for (i = 0; i < DW_REG_TABLE_SIZE && i < dbg->dbg_frame_rule_table_size;
  800420b9eb:	83 7d fc 41          	cmpl   $0x41,-0x4(%rbp)
  800420b9ef:	7f 14                	jg     800420ba05 <dwarf_get_fde_info_for_all_regs+0x30c>
  800420b9f1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420b9f5:	0f b7 40 48          	movzwl 0x48(%rax),%eax
  800420b9f9:	0f b7 c0             	movzwl %ax,%eax
  800420b9fc:	3b 45 fc             	cmp    -0x4(%rbp),%eax
  800420b9ff:	0f 8f e9 fe ff ff    	jg     800420b8ee <dwarf_get_fde_info_for_all_regs+0x1f5>
		reg_table->rules[i].dw_regnum = rt->rt3_rules[i].dw_regnum;
		reg_table->rules[i].dw_offset =
			rt->rt3_rules[i].dw_offset_or_block_len;
	}

	if (row_pc) *row_pc = pc;
  800420ba05:	48 83 7d b8 00       	cmpq   $0x0,-0x48(%rbp)
  800420ba0a:	74 0b                	je     800420ba17 <dwarf_get_fde_info_for_all_regs+0x31e>
  800420ba0c:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420ba10:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ba14:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLV_OK);
  800420ba17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420ba1c:	c9                   	leaveq 
  800420ba1d:	c3                   	retq   

000000800420ba1e <_dwarf_frame_read_lsb_encoded>:

static int
_dwarf_frame_read_lsb_encoded(Dwarf_Debug dbg, uint64_t *val, uint8_t *data,
			      uint64_t *offsetp, uint8_t encode, Dwarf_Addr pc, Dwarf_Error *error)
{
  800420ba1e:	55                   	push   %rbp
  800420ba1f:	48 89 e5             	mov    %rsp,%rbp
  800420ba22:	48 83 ec 40          	sub    $0x40,%rsp
  800420ba26:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420ba2a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420ba2e:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800420ba32:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
  800420ba36:	44 89 c0             	mov    %r8d,%eax
  800420ba39:	4c 89 4d c0          	mov    %r9,-0x40(%rbp)
  800420ba3d:	88 45 cc             	mov    %al,-0x34(%rbp)
	uint8_t application;

	if (encode == DW_EH_PE_omit)
  800420ba40:	80 7d cc ff          	cmpb   $0xff,-0x34(%rbp)
  800420ba44:	75 0a                	jne    800420ba50 <_dwarf_frame_read_lsb_encoded+0x32>
		return (DW_DLE_NONE);
  800420ba46:	b8 00 00 00 00       	mov    $0x0,%eax
  800420ba4b:	e9 e6 01 00 00       	jmpq   800420bc36 <_dwarf_frame_read_lsb_encoded+0x218>

	application = encode & 0xf0;
  800420ba50:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  800420ba54:	83 e0 f0             	and    $0xfffffff0,%eax
  800420ba57:	88 45 ff             	mov    %al,-0x1(%rbp)
	encode &= 0x0f;
  800420ba5a:	80 65 cc 0f          	andb   $0xf,-0x34(%rbp)

	switch (encode) {
  800420ba5e:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  800420ba62:	83 f8 0c             	cmp    $0xc,%eax
  800420ba65:	0f 87 72 01 00 00    	ja     800420bbdd <_dwarf_frame_read_lsb_encoded+0x1bf>
  800420ba6b:	89 c0                	mov    %eax,%eax
  800420ba6d:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420ba74:	00 
  800420ba75:	48 b8 20 fe 20 04 80 	movabs $0x800420fe20,%rax
  800420ba7c:	00 00 00 
  800420ba7f:	48 01 d0             	add    %rdx,%rax
  800420ba82:	48 8b 00             	mov    (%rax),%rax
  800420ba85:	ff e0                	jmpq   *%rax
	case DW_EH_PE_absptr:
		*val = dbg->read(data, offsetp, dbg->dbg_pointer_size);
  800420ba87:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420ba8b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420ba8f:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420ba93:	8b 52 28             	mov    0x28(%rdx),%edx
  800420ba96:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420ba9a:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420ba9e:	48 89 cf             	mov    %rcx,%rdi
  800420baa1:	ff d0                	callq  *%rax
  800420baa3:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420baa7:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420baaa:	e9 35 01 00 00       	jmpq   800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_uleb128:
		*val = _dwarf_read_uleb128(data, offsetp);
  800420baaf:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420bab3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420bab7:	48 89 d6             	mov    %rdx,%rsi
  800420baba:	48 89 c7             	mov    %rax,%rdi
  800420babd:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420bac4:	00 00 00 
  800420bac7:	ff d0                	callq  *%rax
  800420bac9:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420bacd:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420bad0:	e9 0f 01 00 00       	jmpq   800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata2:
		*val = dbg->read(data, offsetp, 2);
  800420bad5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bad9:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420badd:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bae1:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bae5:	ba 02 00 00 00       	mov    $0x2,%edx
  800420baea:	48 89 cf             	mov    %rcx,%rdi
  800420baed:	ff d0                	callq  *%rax
  800420baef:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420baf3:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420baf6:	e9 e9 00 00 00       	jmpq   800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata4:
		*val = dbg->read(data, offsetp, 4);
  800420bafb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420baff:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bb03:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bb07:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bb0b:	ba 04 00 00 00       	mov    $0x4,%edx
  800420bb10:	48 89 cf             	mov    %rcx,%rdi
  800420bb13:	ff d0                	callq  *%rax
  800420bb15:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420bb19:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420bb1c:	e9 c3 00 00 00       	jmpq   800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_udata8:
		*val = dbg->read(data, offsetp, 8);
  800420bb21:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bb25:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bb29:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bb2d:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bb31:	ba 08 00 00 00       	mov    $0x8,%edx
  800420bb36:	48 89 cf             	mov    %rcx,%rdi
  800420bb39:	ff d0                	callq  *%rax
  800420bb3b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420bb3f:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420bb42:	e9 9d 00 00 00       	jmpq   800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sleb128:
		*val = _dwarf_read_sleb128(data, offsetp);
  800420bb47:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420bb4b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420bb4f:	48 89 d6             	mov    %rdx,%rsi
  800420bb52:	48 89 c7             	mov    %rax,%rdi
  800420bb55:	48 b8 0e 8a 20 04 80 	movabs $0x8004208a0e,%rax
  800420bb5c:	00 00 00 
  800420bb5f:	ff d0                	callq  *%rax
  800420bb61:	48 89 c2             	mov    %rax,%rdx
  800420bb64:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bb68:	48 89 10             	mov    %rdx,(%rax)
		break;
  800420bb6b:	eb 77                	jmp    800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata2:
		*val = (int16_t) dbg->read(data, offsetp, 2);
  800420bb6d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bb71:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bb75:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bb79:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bb7d:	ba 02 00 00 00       	mov    $0x2,%edx
  800420bb82:	48 89 cf             	mov    %rcx,%rdi
  800420bb85:	ff d0                	callq  *%rax
  800420bb87:	48 0f bf d0          	movswq %ax,%rdx
  800420bb8b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bb8f:	48 89 10             	mov    %rdx,(%rax)
		break;
  800420bb92:	eb 50                	jmp    800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata4:
		*val = (int32_t) dbg->read(data, offsetp, 4);
  800420bb94:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bb98:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bb9c:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bba0:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bba4:	ba 04 00 00 00       	mov    $0x4,%edx
  800420bba9:	48 89 cf             	mov    %rcx,%rdi
  800420bbac:	ff d0                	callq  *%rax
  800420bbae:	48 63 d0             	movslq %eax,%rdx
  800420bbb1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bbb5:	48 89 10             	mov    %rdx,(%rax)
		break;
  800420bbb8:	eb 2a                	jmp    800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	case DW_EH_PE_sdata8:
		*val = dbg->read(data, offsetp, 8);
  800420bbba:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bbbe:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bbc2:	48 8b 75 d0          	mov    -0x30(%rbp),%rsi
  800420bbc6:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  800420bbca:	ba 08 00 00 00       	mov    $0x8,%edx
  800420bbcf:	48 89 cf             	mov    %rcx,%rdi
  800420bbd2:	ff d0                	callq  *%rax
  800420bbd4:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420bbd8:	48 89 02             	mov    %rax,(%rdx)
		break;
  800420bbdb:	eb 07                	jmp    800420bbe4 <_dwarf_frame_read_lsb_encoded+0x1c6>
	default:
		DWARF_SET_ERROR(dbg, error, DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
		return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
  800420bbdd:	b8 14 00 00 00       	mov    $0x14,%eax
  800420bbe2:	eb 52                	jmp    800420bc36 <_dwarf_frame_read_lsb_encoded+0x218>
	}

	if (application == DW_EH_PE_pcrel) {
  800420bbe4:	80 7d ff 10          	cmpb   $0x10,-0x1(%rbp)
  800420bbe8:	75 47                	jne    800420bc31 <_dwarf_frame_read_lsb_encoded+0x213>
		/*
		 * Value is relative to .eh_frame section virtual addr.
		 */
		switch (encode) {
  800420bbea:	0f b6 45 cc          	movzbl -0x34(%rbp),%eax
  800420bbee:	83 f8 01             	cmp    $0x1,%eax
  800420bbf1:	7c 3d                	jl     800420bc30 <_dwarf_frame_read_lsb_encoded+0x212>
  800420bbf3:	83 f8 04             	cmp    $0x4,%eax
  800420bbf6:	7e 0a                	jle    800420bc02 <_dwarf_frame_read_lsb_encoded+0x1e4>
  800420bbf8:	83 e8 09             	sub    $0x9,%eax
  800420bbfb:	83 f8 03             	cmp    $0x3,%eax
  800420bbfe:	77 30                	ja     800420bc30 <_dwarf_frame_read_lsb_encoded+0x212>
  800420bc00:	eb 17                	jmp    800420bc19 <_dwarf_frame_read_lsb_encoded+0x1fb>
		case DW_EH_PE_uleb128:
		case DW_EH_PE_udata2:
		case DW_EH_PE_udata4:
		case DW_EH_PE_udata8:
			*val += pc;
  800420bc02:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bc06:	48 8b 10             	mov    (%rax),%rdx
  800420bc09:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bc0d:	48 01 c2             	add    %rax,%rdx
  800420bc10:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bc14:	48 89 10             	mov    %rdx,(%rax)
			break;
  800420bc17:	eb 18                	jmp    800420bc31 <_dwarf_frame_read_lsb_encoded+0x213>
		case DW_EH_PE_sleb128:
		case DW_EH_PE_sdata2:
		case DW_EH_PE_sdata4:
		case DW_EH_PE_sdata8:
			*val = pc + (int64_t) *val;
  800420bc19:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bc1d:	48 8b 10             	mov    (%rax),%rdx
  800420bc20:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bc24:	48 01 c2             	add    %rax,%rdx
  800420bc27:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420bc2b:	48 89 10             	mov    %rdx,(%rax)
			break;
  800420bc2e:	eb 01                	jmp    800420bc31 <_dwarf_frame_read_lsb_encoded+0x213>
		default:
			/* DW_EH_PE_absptr is absolute value. */
			break;
  800420bc30:	90                   	nop
		}
	}

	/* XXX Applications other than DW_EH_PE_pcrel are not handled. */

	return (DW_DLE_NONE);
  800420bc31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420bc36:	c9                   	leaveq 
  800420bc37:	c3                   	retq   

000000800420bc38 <_dwarf_frame_parse_lsb_cie_augment>:

static int
_dwarf_frame_parse_lsb_cie_augment(Dwarf_Debug dbg, Dwarf_Cie cie,
				   Dwarf_Error *error)
{
  800420bc38:	55                   	push   %rbp
  800420bc39:	48 89 e5             	mov    %rsp,%rbp
  800420bc3c:	48 83 ec 50          	sub    $0x50,%rsp
  800420bc40:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420bc44:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420bc48:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
	uint8_t *aug_p, *augdata_p;
	uint64_t val, offset;
	uint8_t encode;
	int ret;

	assert(cie->cie_augment != NULL && *cie->cie_augment == 'z');
  800420bc4c:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bc50:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bc54:	48 85 c0             	test   %rax,%rax
  800420bc57:	74 0f                	je     800420bc68 <_dwarf_frame_parse_lsb_cie_augment+0x30>
  800420bc59:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bc5d:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bc61:	0f b6 00             	movzbl (%rax),%eax
  800420bc64:	3c 7a                	cmp    $0x7a,%al
  800420bc66:	74 35                	je     800420bc9d <_dwarf_frame_parse_lsb_cie_augment+0x65>
  800420bc68:	48 b9 88 fe 20 04 80 	movabs $0x800420fe88,%rcx
  800420bc6f:	00 00 00 
  800420bc72:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420bc79:	00 00 00 
  800420bc7c:	be 4a 02 00 00       	mov    $0x24a,%esi
  800420bc81:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420bc88:	00 00 00 
  800420bc8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420bc90:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420bc97:	00 00 00 
  800420bc9a:	41 ff d0             	callq  *%r8
	/*
	 * Here we're only interested in the presence of augment 'R'
	 * and associated CIE augment data, which describes the
	 * encoding scheme of FDE PC begin and range.
	 */
	aug_p = &cie->cie_augment[1];
  800420bc9d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bca1:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bca5:	48 83 c0 01          	add    $0x1,%rax
  800420bca9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	augdata_p = cie->cie_augdata;
  800420bcad:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bcb1:	48 8b 40 58          	mov    0x58(%rax),%rax
  800420bcb5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	while (*aug_p != '\0') {
  800420bcb9:	e9 af 00 00 00       	jmpq   800420bd6d <_dwarf_frame_parse_lsb_cie_augment+0x135>
		switch (*aug_p) {
  800420bcbe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420bcc2:	0f b6 00             	movzbl (%rax),%eax
  800420bcc5:	0f b6 c0             	movzbl %al,%eax
  800420bcc8:	83 f8 50             	cmp    $0x50,%eax
  800420bccb:	74 18                	je     800420bce5 <_dwarf_frame_parse_lsb_cie_augment+0xad>
  800420bccd:	83 f8 52             	cmp    $0x52,%eax
  800420bcd0:	74 77                	je     800420bd49 <_dwarf_frame_parse_lsb_cie_augment+0x111>
  800420bcd2:	83 f8 4c             	cmp    $0x4c,%eax
  800420bcd5:	0f 85 86 00 00 00    	jne    800420bd61 <_dwarf_frame_parse_lsb_cie_augment+0x129>
		case 'L':
			/* Skip one augment in augment data. */
			augdata_p++;
  800420bcdb:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
			break;
  800420bce0:	e9 83 00 00 00       	jmpq   800420bd68 <_dwarf_frame_parse_lsb_cie_augment+0x130>
		case 'P':
			/* Skip two augments in augment data. */
			encode = *augdata_p++;
  800420bce5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420bce9:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420bced:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  800420bcf1:	0f b6 00             	movzbl (%rax),%eax
  800420bcf4:	88 45 ef             	mov    %al,-0x11(%rbp)
			offset = 0;
  800420bcf7:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  800420bcfe:	00 
			ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420bcff:	44 0f b6 45 ef       	movzbl -0x11(%rbp),%r8d
  800420bd04:	48 8d 4d d8          	lea    -0x28(%rbp),%rcx
  800420bd08:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420bd0c:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800420bd10:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420bd14:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  800420bd18:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420bd1c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800420bd22:	48 89 c7             	mov    %rax,%rdi
  800420bd25:	48 b8 1e ba 20 04 80 	movabs $0x800420ba1e,%rax
  800420bd2c:	00 00 00 
  800420bd2f:	ff d0                	callq  *%rax
  800420bd31:	89 45 e8             	mov    %eax,-0x18(%rbp)
							    augdata_p, &offset, encode, 0, error);
			if (ret != DW_DLE_NONE)
  800420bd34:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  800420bd38:	74 05                	je     800420bd3f <_dwarf_frame_parse_lsb_cie_augment+0x107>
				return (ret);
  800420bd3a:	8b 45 e8             	mov    -0x18(%rbp),%eax
  800420bd3d:	eb 42                	jmp    800420bd81 <_dwarf_frame_parse_lsb_cie_augment+0x149>
			augdata_p += offset;
  800420bd3f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420bd43:	48 01 45 f0          	add    %rax,-0x10(%rbp)
			break;
  800420bd47:	eb 1f                	jmp    800420bd68 <_dwarf_frame_parse_lsb_cie_augment+0x130>
		case 'R':
			cie->cie_fde_encode = *augdata_p++;
  800420bd49:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420bd4d:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420bd51:	48 89 55 f0          	mov    %rdx,-0x10(%rbp)
  800420bd55:	0f b6 10             	movzbl (%rax),%edx
  800420bd58:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420bd5c:	88 50 60             	mov    %dl,0x60(%rax)
			break;
  800420bd5f:	eb 07                	jmp    800420bd68 <_dwarf_frame_parse_lsb_cie_augment+0x130>
		default:
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
			return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
  800420bd61:	b8 14 00 00 00       	mov    $0x14,%eax
  800420bd66:	eb 19                	jmp    800420bd81 <_dwarf_frame_parse_lsb_cie_augment+0x149>
		}
		aug_p++;
  800420bd68:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
	 * and associated CIE augment data, which describes the
	 * encoding scheme of FDE PC begin and range.
	 */
	aug_p = &cie->cie_augment[1];
	augdata_p = cie->cie_augdata;
	while (*aug_p != '\0') {
  800420bd6d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420bd71:	0f b6 00             	movzbl (%rax),%eax
  800420bd74:	84 c0                	test   %al,%al
  800420bd76:	0f 85 42 ff ff ff    	jne    800420bcbe <_dwarf_frame_parse_lsb_cie_augment+0x86>
			return (DW_DLE_FRAME_AUGMENTATION_UNKNOWN);
		}
		aug_p++;
	}

	return (DW_DLE_NONE);
  800420bd7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420bd81:	c9                   	leaveq 
  800420bd82:	c3                   	retq   

000000800420bd83 <_dwarf_frame_set_cie>:


static int
_dwarf_frame_set_cie(Dwarf_Debug dbg, Dwarf_Section *ds,
		     Dwarf_Unsigned *off, Dwarf_Cie ret_cie, Dwarf_Error *error)
{
  800420bd83:	55                   	push   %rbp
  800420bd84:	48 89 e5             	mov    %rsp,%rbp
  800420bd87:	48 83 ec 60          	sub    $0x60,%rsp
  800420bd8b:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420bd8f:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420bd93:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800420bd97:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  800420bd9b:	4c 89 45 a8          	mov    %r8,-0x58(%rbp)
	Dwarf_Cie cie;
	uint64_t length;
	int dwarf_size, ret;
	char *p;

	assert(ret_cie);
  800420bd9f:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
  800420bda4:	75 35                	jne    800420bddb <_dwarf_frame_set_cie+0x58>
  800420bda6:	48 b9 bd fe 20 04 80 	movabs $0x800420febd,%rcx
  800420bdad:	00 00 00 
  800420bdb0:	48 ba 07 fd 20 04 80 	movabs $0x800420fd07,%rdx
  800420bdb7:	00 00 00 
  800420bdba:	be 7b 02 00 00       	mov    $0x27b,%esi
  800420bdbf:	48 bf 1c fd 20 04 80 	movabs $0x800420fd1c,%rdi
  800420bdc6:	00 00 00 
  800420bdc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800420bdce:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420bdd5:	00 00 00 
  800420bdd8:	41 ff d0             	callq  *%r8
	cie = ret_cie;
  800420bddb:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420bddf:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

	cie->cie_dbg = dbg;
  800420bde3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bde7:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420bdeb:	48 89 10             	mov    %rdx,(%rax)
	cie->cie_offset = *off;
  800420bdee:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420bdf2:	48 8b 10             	mov    (%rax),%rdx
  800420bdf5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bdf9:	48 89 50 10          	mov    %rdx,0x10(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  800420bdfd:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420be01:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420be05:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420be09:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420be0d:	48 89 d1             	mov    %rdx,%rcx
  800420be10:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420be14:	ba 04 00 00 00       	mov    $0x4,%edx
  800420be19:	48 89 cf             	mov    %rcx,%rdi
  800420be1c:	ff d0                	callq  *%rax
  800420be1e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (length == 0xffffffff) {
  800420be22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420be27:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  800420be2b:	75 2e                	jne    800420be5b <_dwarf_frame_set_cie+0xd8>
		dwarf_size = 8;
  800420be2d:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 8);
  800420be34:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420be38:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420be3c:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420be40:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420be44:	48 89 d1             	mov    %rdx,%rcx
  800420be47:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420be4b:	ba 08 00 00 00       	mov    $0x8,%edx
  800420be50:	48 89 cf             	mov    %rcx,%rdi
  800420be53:	ff d0                	callq  *%rax
  800420be55:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420be59:	eb 07                	jmp    800420be62 <_dwarf_frame_set_cie+0xdf>
	} else
		dwarf_size = 4;
  800420be5b:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

	if (length > dbg->dbg_eh_size - *off) {
  800420be62:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420be66:	48 8b 50 40          	mov    0x40(%rax),%rdx
  800420be6a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420be6e:	48 8b 00             	mov    (%rax),%rax
  800420be71:	48 29 c2             	sub    %rax,%rdx
  800420be74:	48 89 d0             	mov    %rdx,%rax
  800420be77:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  800420be7b:	73 0a                	jae    800420be87 <_dwarf_frame_set_cie+0x104>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_FRAME_LENGTH_BAD);
		return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  800420be7d:	b8 12 00 00 00       	mov    $0x12,%eax
  800420be82:	e9 5d 03 00 00       	jmpq   800420c1e4 <_dwarf_frame_set_cie+0x461>
	}

	(void) dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size); /* Skip CIE id. */
  800420be87:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420be8b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420be8f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420be93:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420be97:	48 89 d1             	mov    %rdx,%rcx
  800420be9a:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420be9d:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420bea1:	48 89 cf             	mov    %rcx,%rdi
  800420bea4:	ff d0                	callq  *%rax
	cie->cie_length = length;
  800420bea6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420beaa:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420beae:	48 89 50 18          	mov    %rdx,0x18(%rax)

	cie->cie_version = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
  800420beb2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420beb6:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420beba:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420bebe:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420bec2:	48 89 d1             	mov    %rdx,%rcx
  800420bec5:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420bec9:	ba 01 00 00 00       	mov    $0x1,%edx
  800420bece:	48 89 cf             	mov    %rcx,%rdi
  800420bed1:	ff d0                	callq  *%rax
  800420bed3:	89 c2                	mov    %eax,%edx
  800420bed5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bed9:	66 89 50 20          	mov    %dx,0x20(%rax)
	if (cie->cie_version != 1 && cie->cie_version != 3 &&
  800420bedd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bee1:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  800420bee5:	66 83 f8 01          	cmp    $0x1,%ax
  800420bee9:	74 26                	je     800420bf11 <_dwarf_frame_set_cie+0x18e>
  800420beeb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420beef:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  800420bef3:	66 83 f8 03          	cmp    $0x3,%ax
  800420bef7:	74 18                	je     800420bf11 <_dwarf_frame_set_cie+0x18e>
	    cie->cie_version != 4) {
  800420bef9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420befd:	0f b7 40 20          	movzwl 0x20(%rax),%eax

	(void) dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size); /* Skip CIE id. */
	cie->cie_length = length;

	cie->cie_version = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
	if (cie->cie_version != 1 && cie->cie_version != 3 &&
  800420bf01:	66 83 f8 04          	cmp    $0x4,%ax
  800420bf05:	74 0a                	je     800420bf11 <_dwarf_frame_set_cie+0x18e>
	    cie->cie_version != 4) {
		DWARF_SET_ERROR(dbg, error, DW_DLE_FRAME_VERSION_BAD);
		return (DW_DLE_FRAME_VERSION_BAD);
  800420bf07:	b8 16 00 00 00       	mov    $0x16,%eax
  800420bf0c:	e9 d3 02 00 00       	jmpq   800420c1e4 <_dwarf_frame_set_cie+0x461>
	}

	cie->cie_augment = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420bf11:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420bf15:	48 8b 10             	mov    (%rax),%rdx
  800420bf18:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420bf1c:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420bf20:	48 01 d0             	add    %rdx,%rax
  800420bf23:	48 89 c2             	mov    %rax,%rdx
  800420bf26:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bf2a:	48 89 50 28          	mov    %rdx,0x28(%rax)
	p = (char *)dbg->dbg_eh_offset;
  800420bf2e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420bf32:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420bf36:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	while (p[(*off)++] != '\0')
  800420bf3a:	90                   	nop
  800420bf3b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420bf3f:	48 8b 00             	mov    (%rax),%rax
  800420bf42:	48 8d 48 01          	lea    0x1(%rax),%rcx
  800420bf46:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420bf4a:	48 89 0a             	mov    %rcx,(%rdx)
  800420bf4d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420bf51:	48 01 d0             	add    %rdx,%rax
  800420bf54:	0f b6 00             	movzbl (%rax),%eax
  800420bf57:	84 c0                	test   %al,%al
  800420bf59:	75 e0                	jne    800420bf3b <_dwarf_frame_set_cie+0x1b8>
		;

	/* We only recognize normal .dwarf_frame and GNU .eh_frame sections. */
	if (*cie->cie_augment != 0 && *cie->cie_augment != 'z') {
  800420bf5b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bf5f:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bf63:	0f b6 00             	movzbl (%rax),%eax
  800420bf66:	84 c0                	test   %al,%al
  800420bf68:	74 48                	je     800420bfb2 <_dwarf_frame_set_cie+0x22f>
  800420bf6a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bf6e:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bf72:	0f b6 00             	movzbl (%rax),%eax
  800420bf75:	3c 7a                	cmp    $0x7a,%al
  800420bf77:	74 39                	je     800420bfb2 <_dwarf_frame_set_cie+0x22f>
		*off = cie->cie_offset + ((dwarf_size == 4) ? 4 : 12) +
  800420bf79:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bf7d:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420bf81:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420bf85:	75 07                	jne    800420bf8e <_dwarf_frame_set_cie+0x20b>
  800420bf87:	b8 04 00 00 00       	mov    $0x4,%eax
  800420bf8c:	eb 05                	jmp    800420bf93 <_dwarf_frame_set_cie+0x210>
  800420bf8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800420bf93:	48 01 c2             	add    %rax,%rdx
			cie->cie_length;
  800420bf96:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bf9a:	48 8b 40 18          	mov    0x18(%rax),%rax
	while (p[(*off)++] != '\0')
		;

	/* We only recognize normal .dwarf_frame and GNU .eh_frame sections. */
	if (*cie->cie_augment != 0 && *cie->cie_augment != 'z') {
		*off = cie->cie_offset + ((dwarf_size == 4) ? 4 : 12) +
  800420bf9e:	48 01 c2             	add    %rax,%rdx
  800420bfa1:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420bfa5:	48 89 10             	mov    %rdx,(%rax)
			cie->cie_length;
		return (DW_DLE_NONE);
  800420bfa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800420bfad:	e9 32 02 00 00       	jmpq   800420c1e4 <_dwarf_frame_set_cie+0x461>
	}

	/* Optional EH Data field for .eh_frame section. */
	if (strstr((char *)cie->cie_augment, "eh") != NULL)
  800420bfb2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420bfb6:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420bfba:	48 be c5 fe 20 04 80 	movabs $0x800420fec5,%rsi
  800420bfc1:	00 00 00 
  800420bfc4:	48 89 c7             	mov    %rax,%rdi
  800420bfc7:	48 b8 c5 83 20 04 80 	movabs $0x80042083c5,%rax
  800420bfce:	00 00 00 
  800420bfd1:	ff d0                	callq  *%rax
  800420bfd3:	48 85 c0             	test   %rax,%rax
  800420bfd6:	74 28                	je     800420c000 <_dwarf_frame_set_cie+0x27d>
		cie->cie_ehdata = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  800420bfd8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420bfdc:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420bfe0:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420bfe4:	8b 52 28             	mov    0x28(%rdx),%edx
  800420bfe7:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420bfeb:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  800420bfef:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420bff3:	48 89 cf             	mov    %rcx,%rdi
  800420bff6:	ff d0                	callq  *%rax
  800420bff8:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420bffc:	48 89 42 30          	mov    %rax,0x30(%rdx)
					    dbg->dbg_pointer_size);

	cie->cie_caf = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420c000:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c004:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c008:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420c00c:	48 89 d6             	mov    %rdx,%rsi
  800420c00f:	48 89 c7             	mov    %rax,%rdi
  800420c012:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420c019:	00 00 00 
  800420c01c:	ff d0                	callq  *%rax
  800420c01e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c022:	48 89 42 38          	mov    %rax,0x38(%rdx)
	cie->cie_daf = _dwarf_read_sleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420c026:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c02a:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c02e:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420c032:	48 89 d6             	mov    %rdx,%rsi
  800420c035:	48 89 c7             	mov    %rax,%rdi
  800420c038:	48 b8 0e 8a 20 04 80 	movabs $0x8004208a0e,%rax
  800420c03f:	00 00 00 
  800420c042:	ff d0                	callq  *%rax
  800420c044:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c048:	48 89 42 40          	mov    %rax,0x40(%rdx)

	/* Return address register. */
	if (cie->cie_version == 1)
  800420c04c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c050:	0f b7 40 20          	movzwl 0x20(%rax),%eax
  800420c054:	66 83 f8 01          	cmp    $0x1,%ax
  800420c058:	75 2b                	jne    800420c085 <_dwarf_frame_set_cie+0x302>
		cie->cie_ra = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 1);
  800420c05a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c05e:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c062:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c066:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c06a:	48 89 d1             	mov    %rdx,%rcx
  800420c06d:	48 8b 75 b8          	mov    -0x48(%rbp),%rsi
  800420c071:	ba 01 00 00 00       	mov    $0x1,%edx
  800420c076:	48 89 cf             	mov    %rcx,%rdi
  800420c079:	ff d0                	callq  *%rax
  800420c07b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c07f:	48 89 42 48          	mov    %rax,0x48(%rdx)
  800420c083:	eb 26                	jmp    800420c0ab <_dwarf_frame_set_cie+0x328>
	else
		cie->cie_ra = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420c085:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c089:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c08d:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420c091:	48 89 d6             	mov    %rdx,%rsi
  800420c094:	48 89 c7             	mov    %rax,%rdi
  800420c097:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420c09e:	00 00 00 
  800420c0a1:	ff d0                	callq  *%rax
  800420c0a3:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c0a7:	48 89 42 48          	mov    %rax,0x48(%rdx)

	/* Optional CIE augmentation data for .eh_frame section. */
	if (*cie->cie_augment == 'z') {
  800420c0ab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c0af:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420c0b3:	0f b6 00             	movzbl (%rax),%eax
  800420c0b6:	3c 7a                	cmp    $0x7a,%al
  800420c0b8:	0f 85 93 00 00 00    	jne    800420c151 <_dwarf_frame_set_cie+0x3ce>
		cie->cie_auglen = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420c0be:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c0c2:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c0c6:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420c0ca:	48 89 d6             	mov    %rdx,%rsi
  800420c0cd:	48 89 c7             	mov    %rax,%rdi
  800420c0d0:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420c0d7:	00 00 00 
  800420c0da:	ff d0                	callq  *%rax
  800420c0dc:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c0e0:	48 89 42 50          	mov    %rax,0x50(%rdx)
		cie->cie_augdata = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420c0e4:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c0e8:	48 8b 10             	mov    (%rax),%rdx
  800420c0eb:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c0ef:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c0f3:	48 01 d0             	add    %rdx,%rax
  800420c0f6:	48 89 c2             	mov    %rax,%rdx
  800420c0f9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c0fd:	48 89 50 58          	mov    %rdx,0x58(%rax)
		*off += cie->cie_auglen;
  800420c101:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c105:	48 8b 10             	mov    (%rax),%rdx
  800420c108:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c10c:	48 8b 40 50          	mov    0x50(%rax),%rax
  800420c110:	48 01 c2             	add    %rax,%rdx
  800420c113:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c117:	48 89 10             	mov    %rdx,(%rax)
		/*
		 * XXX Use DW_EH_PE_absptr for default FDE PC start/range,
		 * in case _dwarf_frame_parse_lsb_cie_augment fails to
		 * find out the real encode.
		 */
		cie->cie_fde_encode = DW_EH_PE_absptr;
  800420c11a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c11e:	c6 40 60 00          	movb   $0x0,0x60(%rax)
		ret = _dwarf_frame_parse_lsb_cie_augment(dbg, cie, error);
  800420c122:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
  800420c126:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
  800420c12a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c12e:	48 89 ce             	mov    %rcx,%rsi
  800420c131:	48 89 c7             	mov    %rax,%rdi
  800420c134:	48 b8 38 bc 20 04 80 	movabs $0x800420bc38,%rax
  800420c13b:	00 00 00 
  800420c13e:	ff d0                	callq  *%rax
  800420c140:	89 45 dc             	mov    %eax,-0x24(%rbp)
		if (ret != DW_DLE_NONE)
  800420c143:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420c147:	74 08                	je     800420c151 <_dwarf_frame_set_cie+0x3ce>
			return (ret);
  800420c149:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800420c14c:	e9 93 00 00 00       	jmpq   800420c1e4 <_dwarf_frame_set_cie+0x461>
	}

	/* CIE Initial instructions. */
	cie->cie_initinst = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420c151:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c155:	48 8b 10             	mov    (%rax),%rdx
  800420c158:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c15c:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c160:	48 01 d0             	add    %rdx,%rax
  800420c163:	48 89 c2             	mov    %rax,%rdx
  800420c166:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c16a:	48 89 50 68          	mov    %rdx,0x68(%rax)
	if (dwarf_size == 4)
  800420c16e:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420c172:	75 2a                	jne    800420c19e <_dwarf_frame_set_cie+0x41b>
		cie->cie_instlen = cie->cie_offset + 4 + length - *off;
  800420c174:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c178:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420c17c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c180:	48 01 c2             	add    %rax,%rdx
  800420c183:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c187:	48 8b 00             	mov    (%rax),%rax
  800420c18a:	48 29 c2             	sub    %rax,%rdx
  800420c18d:	48 89 d0             	mov    %rdx,%rax
  800420c190:	48 8d 50 04          	lea    0x4(%rax),%rdx
  800420c194:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c198:	48 89 50 70          	mov    %rdx,0x70(%rax)
  800420c19c:	eb 28                	jmp    800420c1c6 <_dwarf_frame_set_cie+0x443>
	else
		cie->cie_instlen = cie->cie_offset + 12 + length - *off;
  800420c19e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c1a2:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420c1a6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c1aa:	48 01 c2             	add    %rax,%rdx
  800420c1ad:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c1b1:	48 8b 00             	mov    (%rax),%rax
  800420c1b4:	48 29 c2             	sub    %rax,%rdx
  800420c1b7:	48 89 d0             	mov    %rdx,%rax
  800420c1ba:	48 8d 50 0c          	lea    0xc(%rax),%rdx
  800420c1be:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c1c2:	48 89 50 70          	mov    %rdx,0x70(%rax)

	*off += cie->cie_instlen;
  800420c1c6:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c1ca:	48 8b 10             	mov    (%rax),%rdx
  800420c1cd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c1d1:	48 8b 40 70          	mov    0x70(%rax),%rax
  800420c1d5:	48 01 c2             	add    %rax,%rdx
  800420c1d8:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c1dc:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLE_NONE);
  800420c1df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420c1e4:	c9                   	leaveq 
  800420c1e5:	c3                   	retq   

000000800420c1e6 <_dwarf_frame_set_fde>:

static int
_dwarf_frame_set_fde(Dwarf_Debug dbg, Dwarf_Fde ret_fde, Dwarf_Section *ds,
		     Dwarf_Unsigned *off, int eh_frame, Dwarf_Cie cie, Dwarf_Error *error)
{
  800420c1e6:	55                   	push   %rbp
  800420c1e7:	48 89 e5             	mov    %rsp,%rbp
  800420c1ea:	48 83 ec 70          	sub    $0x70,%rsp
  800420c1ee:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420c1f2:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420c1f6:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800420c1fa:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
  800420c1fe:	44 89 45 ac          	mov    %r8d,-0x54(%rbp)
  800420c202:	4c 89 4d a0          	mov    %r9,-0x60(%rbp)
	Dwarf_Fde fde;
	Dwarf_Unsigned cieoff;
	uint64_t length, val;
	int dwarf_size, ret;

	fde = ret_fde;
  800420c206:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420c20a:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	fde->fde_dbg = dbg;
  800420c20e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c212:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c216:	48 89 10             	mov    %rdx,(%rax)
	fde->fde_addr = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420c219:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c21d:	48 8b 10             	mov    (%rax),%rdx
  800420c220:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c224:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c228:	48 01 d0             	add    %rdx,%rax
  800420c22b:	48 89 c2             	mov    %rax,%rdx
  800420c22e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c232:	48 89 50 10          	mov    %rdx,0x10(%rax)
	fde->fde_offset = *off;
  800420c236:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c23a:	48 8b 10             	mov    (%rax),%rdx
  800420c23d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c241:	48 89 50 18          	mov    %rdx,0x18(%rax)

	length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  800420c245:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c249:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c24d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c251:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c255:	48 89 d1             	mov    %rdx,%rcx
  800420c258:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c25c:	ba 04 00 00 00       	mov    $0x4,%edx
  800420c261:	48 89 cf             	mov    %rcx,%rdi
  800420c264:	ff d0                	callq  *%rax
  800420c266:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
	if (length == 0xffffffff) {
  800420c26a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420c26f:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  800420c273:	75 2e                	jne    800420c2a3 <_dwarf_frame_set_fde+0xbd>
		dwarf_size = 8;
  800420c275:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 8);
  800420c27c:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c280:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c284:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c288:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c28c:	48 89 d1             	mov    %rdx,%rcx
  800420c28f:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c293:	ba 08 00 00 00       	mov    $0x8,%edx
  800420c298:	48 89 cf             	mov    %rcx,%rdi
  800420c29b:	ff d0                	callq  *%rax
  800420c29d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420c2a1:	eb 07                	jmp    800420c2aa <_dwarf_frame_set_fde+0xc4>
	} else
		dwarf_size = 4;
  800420c2a3:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

	if (length > dbg->dbg_eh_size - *off) {
  800420c2aa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c2ae:	48 8b 50 40          	mov    0x40(%rax),%rdx
  800420c2b2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c2b6:	48 8b 00             	mov    (%rax),%rax
  800420c2b9:	48 29 c2             	sub    %rax,%rdx
  800420c2bc:	48 89 d0             	mov    %rdx,%rax
  800420c2bf:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  800420c2c3:	73 0a                	jae    800420c2cf <_dwarf_frame_set_fde+0xe9>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_FRAME_LENGTH_BAD);
		return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  800420c2c5:	b8 12 00 00 00       	mov    $0x12,%eax
  800420c2ca:	e9 ca 02 00 00       	jmpq   800420c599 <_dwarf_frame_set_fde+0x3b3>
	}

	fde->fde_length = length;
  800420c2cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c2d3:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420c2d7:	48 89 50 20          	mov    %rdx,0x20(%rax)

	if (eh_frame) {
  800420c2db:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800420c2df:	74 5e                	je     800420c33f <_dwarf_frame_set_fde+0x159>
		fde->fde_cieoff = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, 4);
  800420c2e1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c2e5:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c2e9:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c2ed:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c2f1:	48 89 d1             	mov    %rdx,%rcx
  800420c2f4:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c2f8:	ba 04 00 00 00       	mov    $0x4,%edx
  800420c2fd:	48 89 cf             	mov    %rcx,%rdi
  800420c300:	ff d0                	callq  *%rax
  800420c302:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c306:	48 89 42 28          	mov    %rax,0x28(%rdx)
		cieoff = *off - (4 + fde->fde_cieoff);
  800420c30a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c30e:	48 8b 10             	mov    (%rax),%rdx
  800420c311:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c315:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420c319:	48 29 c2             	sub    %rax,%rdx
  800420c31c:	48 89 d0             	mov    %rdx,%rax
  800420c31f:	48 83 e8 04          	sub    $0x4,%rax
  800420c323:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
		/* This delta should never be 0. */
		if (cieoff == fde->fde_offset) {
  800420c327:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c32b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c32f:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  800420c333:	75 3d                	jne    800420c372 <_dwarf_frame_set_fde+0x18c>
			DWARF_SET_ERROR(dbg, error, DW_DLE_NO_CIE_FOR_FDE);
			return (DW_DLE_NO_CIE_FOR_FDE);
  800420c335:	b8 13 00 00 00       	mov    $0x13,%eax
  800420c33a:	e9 5a 02 00 00       	jmpq   800420c599 <_dwarf_frame_set_fde+0x3b3>
		}
	} else {
		fde->fde_cieoff = dbg->read((uint8_t *)dbg->dbg_eh_offset, off, dwarf_size);
  800420c33f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c343:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c347:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c34b:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c34f:	48 89 d1             	mov    %rdx,%rcx
  800420c352:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420c355:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c359:	48 89 cf             	mov    %rcx,%rdi
  800420c35c:	ff d0                	callq  *%rax
  800420c35e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c362:	48 89 42 28          	mov    %rax,0x28(%rdx)
		cieoff = fde->fde_cieoff;
  800420c366:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c36a:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420c36e:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	}

	if (eh_frame) {
  800420c372:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800420c376:	0f 84 c9 00 00 00    	je     800420c445 <_dwarf_frame_set_fde+0x25f>
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
  800420c37c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420c380:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420c384:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c388:	48 8b 00             	mov    (%rax),%rax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420c38b:	4c 8d 0c 02          	lea    (%rdx,%rax,1),%r9
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
  800420c38f:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420c393:	0f b6 40 60          	movzbl 0x60(%rax),%eax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420c397:	44 0f b6 c0          	movzbl %al,%r8d
						    (uint8_t *)dbg->dbg_eh_offset,
  800420c39b:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c39f:	48 8b 40 38          	mov    0x38(%rax),%rax
	if (eh_frame) {
		/*
		 * The FDE PC start/range for .eh_frame is encoded according
		 * to the LSB spec's extension to DWARF2.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420c3a3:	48 89 c2             	mov    %rax,%rdx
  800420c3a6:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  800420c3aa:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  800420c3ae:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c3b2:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  800420c3b6:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420c3ba:	48 89 c7             	mov    %rax,%rdi
  800420c3bd:	48 b8 1e ba 20 04 80 	movabs $0x800420ba1e,%rax
  800420c3c4:	00 00 00 
  800420c3c7:	ff d0                	callq  *%rax
  800420c3c9:	89 45 dc             	mov    %eax,-0x24(%rbp)
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, ds->ds_addr + *off, error);
		if (ret != DW_DLE_NONE)
  800420c3cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420c3d0:	74 08                	je     800420c3da <_dwarf_frame_set_fde+0x1f4>
			return (ret);
  800420c3d2:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800420c3d5:	e9 bf 01 00 00       	jmpq   800420c599 <_dwarf_frame_set_fde+0x3b3>
		fde->fde_initloc = val;
  800420c3da:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420c3de:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c3e2:	48 89 50 30          	mov    %rdx,0x30(%rax)
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, 0, error);
  800420c3e6:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420c3ea:	0f b6 40 60          	movzbl 0x60(%rax),%eax
		fde->fde_initloc = val;
		/*
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420c3ee:	44 0f b6 c0          	movzbl %al,%r8d
						    (uint8_t *)dbg->dbg_eh_offset,
  800420c3f2:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c3f6:	48 8b 40 38          	mov    0x38(%rax),%rax
		fde->fde_initloc = val;
		/*
		 * FDE PC range should not be relative value to anything.
		 * So pass 0 for pc value.
		 */
		ret = _dwarf_frame_read_lsb_encoded(dbg, &val,
  800420c3fa:	48 89 c2             	mov    %rax,%rdx
  800420c3fd:	48 8b 4d b0          	mov    -0x50(%rbp),%rcx
  800420c401:	48 8d 75 d0          	lea    -0x30(%rbp),%rsi
  800420c405:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c409:	48 8b 7d 10          	mov    0x10(%rbp),%rdi
  800420c40d:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420c411:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800420c417:	48 89 c7             	mov    %rax,%rdi
  800420c41a:	48 b8 1e ba 20 04 80 	movabs $0x800420ba1e,%rax
  800420c421:	00 00 00 
  800420c424:	ff d0                	callq  *%rax
  800420c426:	89 45 dc             	mov    %eax,-0x24(%rbp)
						    (uint8_t *)dbg->dbg_eh_offset,
						    off, cie->cie_fde_encode, 0, error);
		if (ret != DW_DLE_NONE)
  800420c429:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420c42d:	74 08                	je     800420c437 <_dwarf_frame_set_fde+0x251>
			return (ret);
  800420c42f:	8b 45 dc             	mov    -0x24(%rbp),%eax
  800420c432:	e9 62 01 00 00       	jmpq   800420c599 <_dwarf_frame_set_fde+0x3b3>
		fde->fde_adrange = val;
  800420c437:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420c43b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c43f:	48 89 50 38          	mov    %rdx,0x38(%rax)
  800420c443:	eb 50                	jmp    800420c495 <_dwarf_frame_set_fde+0x2af>
	} else {
		fde->fde_initloc = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  800420c445:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c449:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c44d:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c451:	8b 52 28             	mov    0x28(%rdx),%edx
  800420c454:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420c458:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  800420c45c:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c460:	48 89 cf             	mov    %rcx,%rdi
  800420c463:	ff d0                	callq  *%rax
  800420c465:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c469:	48 89 42 30          	mov    %rax,0x30(%rdx)
					     dbg->dbg_pointer_size);
		fde->fde_adrange = dbg->read((uint8_t *)dbg->dbg_eh_offset, off,
  800420c46d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c471:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c475:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c479:	8b 52 28             	mov    0x28(%rdx),%edx
  800420c47c:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
  800420c480:	48 8b 49 38          	mov    0x38(%rcx),%rcx
  800420c484:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c488:	48 89 cf             	mov    %rcx,%rdi
  800420c48b:	ff d0                	callq  *%rax
  800420c48d:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c491:	48 89 42 38          	mov    %rax,0x38(%rdx)
					     dbg->dbg_pointer_size);
	}

	/* Optional FDE augmentation data for .eh_frame section. (ignored) */
	if (eh_frame && *cie->cie_augment == 'z') {
  800420c495:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800420c499:	74 6b                	je     800420c506 <_dwarf_frame_set_fde+0x320>
  800420c49b:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420c49f:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420c4a3:	0f b6 00             	movzbl (%rax),%eax
  800420c4a6:	3c 7a                	cmp    $0x7a,%al
  800420c4a8:	75 5c                	jne    800420c506 <_dwarf_frame_set_fde+0x320>
		fde->fde_auglen = _dwarf_read_uleb128((uint8_t *)dbg->dbg_eh_offset, off);
  800420c4aa:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c4ae:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c4b2:	48 8b 55 b0          	mov    -0x50(%rbp),%rdx
  800420c4b6:	48 89 d6             	mov    %rdx,%rsi
  800420c4b9:	48 89 c7             	mov    %rax,%rdi
  800420c4bc:	48 b8 b2 8a 20 04 80 	movabs $0x8004208ab2,%rax
  800420c4c3:	00 00 00 
  800420c4c6:	ff d0                	callq  *%rax
  800420c4c8:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c4cc:	48 89 42 40          	mov    %rax,0x40(%rdx)
		fde->fde_augdata = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420c4d0:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c4d4:	48 8b 10             	mov    (%rax),%rdx
  800420c4d7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c4db:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c4df:	48 01 d0             	add    %rdx,%rax
  800420c4e2:	48 89 c2             	mov    %rax,%rdx
  800420c4e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c4e9:	48 89 50 48          	mov    %rdx,0x48(%rax)
		*off += fde->fde_auglen;
  800420c4ed:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c4f1:	48 8b 10             	mov    (%rax),%rdx
  800420c4f4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c4f8:	48 8b 40 40          	mov    0x40(%rax),%rax
  800420c4fc:	48 01 c2             	add    %rax,%rdx
  800420c4ff:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c503:	48 89 10             	mov    %rdx,(%rax)
	}

	fde->fde_inst = (uint8_t *)dbg->dbg_eh_offset + *off;
  800420c506:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c50a:	48 8b 10             	mov    (%rax),%rdx
  800420c50d:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c511:	48 8b 40 38          	mov    0x38(%rax),%rax
  800420c515:	48 01 d0             	add    %rdx,%rax
  800420c518:	48 89 c2             	mov    %rax,%rdx
  800420c51b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c51f:	48 89 50 50          	mov    %rdx,0x50(%rax)
	if (dwarf_size == 4)
  800420c523:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420c527:	75 2a                	jne    800420c553 <_dwarf_frame_set_fde+0x36d>
		fde->fde_instlen = fde->fde_offset + 4 + length - *off;
  800420c529:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c52d:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420c531:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c535:	48 01 c2             	add    %rax,%rdx
  800420c538:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c53c:	48 8b 00             	mov    (%rax),%rax
  800420c53f:	48 29 c2             	sub    %rax,%rdx
  800420c542:	48 89 d0             	mov    %rdx,%rax
  800420c545:	48 8d 50 04          	lea    0x4(%rax),%rdx
  800420c549:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c54d:	48 89 50 58          	mov    %rdx,0x58(%rax)
  800420c551:	eb 28                	jmp    800420c57b <_dwarf_frame_set_fde+0x395>
	else
		fde->fde_instlen = fde->fde_offset + 12 + length - *off;
  800420c553:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c557:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420c55b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c55f:	48 01 c2             	add    %rax,%rdx
  800420c562:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c566:	48 8b 00             	mov    (%rax),%rax
  800420c569:	48 29 c2             	sub    %rax,%rdx
  800420c56c:	48 89 d0             	mov    %rdx,%rax
  800420c56f:	48 8d 50 0c          	lea    0xc(%rax),%rdx
  800420c573:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c577:	48 89 50 58          	mov    %rdx,0x58(%rax)

	*off += fde->fde_instlen;
  800420c57b:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c57f:	48 8b 10             	mov    (%rax),%rdx
  800420c582:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c586:	48 8b 40 58          	mov    0x58(%rax),%rax
  800420c58a:	48 01 c2             	add    %rax,%rdx
  800420c58d:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c591:	48 89 10             	mov    %rdx,(%rax)
	return (DW_DLE_NONE);
  800420c594:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420c599:	c9                   	leaveq 
  800420c59a:	c3                   	retq   

000000800420c59b <_dwarf_frame_interal_table_init>:


int
_dwarf_frame_interal_table_init(Dwarf_Debug dbg, Dwarf_Error *error)
{
  800420c59b:	55                   	push   %rbp
  800420c59c:	48 89 e5             	mov    %rsp,%rbp
  800420c59f:	48 83 ec 20          	sub    $0x20,%rsp
  800420c5a3:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420c5a7:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
	Dwarf_Regtable3 *rt = &global_rt_table;
  800420c5ab:	48 b8 00 2d 22 04 80 	movabs $0x8004222d00,%rax
  800420c5b2:	00 00 00 
  800420c5b5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	if (dbg->dbg_internal_reg_table != NULL)
  800420c5b9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c5bd:	48 8b 40 58          	mov    0x58(%rax),%rax
  800420c5c1:	48 85 c0             	test   %rax,%rax
  800420c5c4:	74 07                	je     800420c5cd <_dwarf_frame_interal_table_init+0x32>
		return (DW_DLE_NONE);
  800420c5c6:	b8 00 00 00 00       	mov    $0x0,%eax
  800420c5cb:	eb 33                	jmp    800420c600 <_dwarf_frame_interal_table_init+0x65>

	rt->rt3_reg_table_size = dbg->dbg_frame_rule_table_size;
  800420c5cd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c5d1:	0f b7 50 48          	movzwl 0x48(%rax),%edx
  800420c5d5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c5d9:	66 89 50 18          	mov    %dx,0x18(%rax)
	rt->rt3_rules = global_rules;
  800420c5dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c5e1:	48 b9 40 35 22 04 80 	movabs $0x8004223540,%rcx
  800420c5e8:	00 00 00 
  800420c5eb:	48 89 48 20          	mov    %rcx,0x20(%rax)

	dbg->dbg_internal_reg_table = rt;
  800420c5ef:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c5f3:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420c5f7:	48 89 50 58          	mov    %rdx,0x58(%rax)

	return (DW_DLE_NONE);
  800420c5fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420c600:	c9                   	leaveq 
  800420c601:	c3                   	retq   

000000800420c602 <_dwarf_get_next_fde>:

static int
_dwarf_get_next_fde(Dwarf_Debug dbg,
		    int eh_frame, Dwarf_Error *error, Dwarf_Fde ret_fde)
{
  800420c602:	55                   	push   %rbp
  800420c603:	48 89 e5             	mov    %rsp,%rbp
  800420c606:	48 83 ec 60          	sub    $0x60,%rsp
  800420c60a:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
  800420c60e:	89 75 c4             	mov    %esi,-0x3c(%rbp)
  800420c611:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
  800420c615:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
	Dwarf_Section *ds = &debug_frame_sec; 
  800420c619:	48 b8 e0 25 22 04 80 	movabs $0x80042225e0,%rax
  800420c620:	00 00 00 
  800420c623:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uint64_t length, offset, cie_id, entry_off;
	int dwarf_size, i, ret=-1;
  800420c627:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%rbp)

	offset = dbg->curr_off_eh;
  800420c62e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c632:	48 8b 40 30          	mov    0x30(%rax),%rax
  800420c636:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	if (offset < dbg->dbg_eh_size) {
  800420c63a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c63e:	48 8b 50 40          	mov    0x40(%rax),%rdx
  800420c642:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420c646:	48 39 c2             	cmp    %rax,%rdx
  800420c649:	0f 86 fe 01 00 00    	jbe    800420c84d <_dwarf_get_next_fde+0x24b>
		entry_off = offset;
  800420c64f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420c653:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		length = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, 4);
  800420c657:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c65b:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c65f:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c663:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c667:	48 89 d1             	mov    %rdx,%rcx
  800420c66a:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  800420c66e:	ba 04 00 00 00       	mov    $0x4,%edx
  800420c673:	48 89 cf             	mov    %rcx,%rdi
  800420c676:	ff d0                	callq  *%rax
  800420c678:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
		if (length == 0xffffffff) {
  800420c67c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420c681:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
  800420c685:	75 2e                	jne    800420c6b5 <_dwarf_get_next_fde+0xb3>
			dwarf_size = 8;
  800420c687:	c7 45 f4 08 00 00 00 	movl   $0x8,-0xc(%rbp)
			length = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, 8);
  800420c68e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c692:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c696:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c69a:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c69e:	48 89 d1             	mov    %rdx,%rcx
  800420c6a1:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  800420c6a5:	ba 08 00 00 00       	mov    $0x8,%edx
  800420c6aa:	48 89 cf             	mov    %rcx,%rdi
  800420c6ad:	ff d0                	callq  *%rax
  800420c6af:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420c6b3:	eb 07                	jmp    800420c6bc <_dwarf_get_next_fde+0xba>
		} else
			dwarf_size = 4;
  800420c6b5:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%rbp)

		if (length > dbg->dbg_eh_size - offset || (length == 0 && !eh_frame)) {
  800420c6bc:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c6c0:	48 8b 50 40          	mov    0x40(%rax),%rdx
  800420c6c4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420c6c8:	48 29 c2             	sub    %rax,%rdx
  800420c6cb:	48 89 d0             	mov    %rdx,%rax
  800420c6ce:	48 3b 45 f8          	cmp    -0x8(%rbp),%rax
  800420c6d2:	72 0d                	jb     800420c6e1 <_dwarf_get_next_fde+0xdf>
  800420c6d4:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420c6d9:	75 10                	jne    800420c6eb <_dwarf_get_next_fde+0xe9>
  800420c6db:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800420c6df:	75 0a                	jne    800420c6eb <_dwarf_get_next_fde+0xe9>
			DWARF_SET_ERROR(dbg, error,
					DW_DLE_DEBUG_FRAME_LENGTH_BAD);
			return (DW_DLE_DEBUG_FRAME_LENGTH_BAD);
  800420c6e1:	b8 12 00 00 00       	mov    $0x12,%eax
  800420c6e6:	e9 67 01 00 00       	jmpq   800420c852 <_dwarf_get_next_fde+0x250>
		}

		/* Check terminator for .eh_frame */
		if (eh_frame && length == 0)
  800420c6eb:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800420c6ef:	74 11                	je     800420c702 <_dwarf_get_next_fde+0x100>
  800420c6f1:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420c6f6:	75 0a                	jne    800420c702 <_dwarf_get_next_fde+0x100>
			return(-1);
  800420c6f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420c6fd:	e9 50 01 00 00       	jmpq   800420c852 <_dwarf_get_next_fde+0x250>

		cie_id = dbg->read((uint8_t *)dbg->dbg_eh_offset, &offset, dwarf_size);
  800420c702:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c706:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420c70a:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420c70e:	48 8b 52 38          	mov    0x38(%rdx),%rdx
  800420c712:	48 89 d1             	mov    %rdx,%rcx
  800420c715:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420c718:	48 8d 75 d8          	lea    -0x28(%rbp),%rsi
  800420c71c:	48 89 cf             	mov    %rcx,%rdi
  800420c71f:	ff d0                	callq  *%rax
  800420c721:	48 89 45 e0          	mov    %rax,-0x20(%rbp)

		if (eh_frame) {
  800420c725:	83 7d c4 00          	cmpl   $0x0,-0x3c(%rbp)
  800420c729:	74 79                	je     800420c7a4 <_dwarf_get_next_fde+0x1a2>
			/* GNU .eh_frame use CIE id 0. */
			if (cie_id == 0)
  800420c72b:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  800420c730:	75 32                	jne    800420c764 <_dwarf_get_next_fde+0x162>
				ret = _dwarf_frame_set_cie(dbg, ds,
  800420c732:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c736:	48 8b 48 08          	mov    0x8(%rax),%rcx
  800420c73a:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  800420c73e:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  800420c742:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  800420c746:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c74a:	49 89 f8             	mov    %rdi,%r8
  800420c74d:	48 89 c7             	mov    %rax,%rdi
  800420c750:	48 b8 83 bd 20 04 80 	movabs $0x800420bd83,%rax
  800420c757:	00 00 00 
  800420c75a:	ff d0                	callq  *%rax
  800420c75c:	89 45 f0             	mov    %eax,-0x10(%rbp)
  800420c75f:	e9 c8 00 00 00       	jmpq   800420c82c <_dwarf_get_next_fde+0x22a>
							   &entry_off, ret_fde->fde_cie, error);
			else
				ret = _dwarf_frame_set_fde(dbg,ret_fde, ds,
  800420c764:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c768:	4c 8b 40 08          	mov    0x8(%rax),%r8
  800420c76c:	48 8d 4d d0          	lea    -0x30(%rbp),%rcx
  800420c770:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c774:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c778:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c77c:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  800420c780:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420c784:	4d 89 c1             	mov    %r8,%r9
  800420c787:	41 b8 01 00 00 00    	mov    $0x1,%r8d
  800420c78d:	48 89 c7             	mov    %rax,%rdi
  800420c790:	48 b8 e6 c1 20 04 80 	movabs $0x800420c1e6,%rax
  800420c797:	00 00 00 
  800420c79a:	ff d0                	callq  *%rax
  800420c79c:	89 45 f0             	mov    %eax,-0x10(%rbp)
  800420c79f:	e9 88 00 00 00       	jmpq   800420c82c <_dwarf_get_next_fde+0x22a>
							   &entry_off, 1, ret_fde->fde_cie, error);
		} else {
			/* .dwarf_frame use CIE id ~0 */
			if ((dwarf_size == 4 && cie_id == ~0U) ||
  800420c7a4:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420c7a8:	75 0b                	jne    800420c7b5 <_dwarf_get_next_fde+0x1b3>
  800420c7aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420c7af:	48 39 45 e0          	cmp    %rax,-0x20(%rbp)
  800420c7b3:	74 0d                	je     800420c7c2 <_dwarf_get_next_fde+0x1c0>
  800420c7b5:	83 7d f4 08          	cmpl   $0x8,-0xc(%rbp)
  800420c7b9:	75 36                	jne    800420c7f1 <_dwarf_get_next_fde+0x1ef>
			    (dwarf_size == 8 && cie_id == ~0ULL))
  800420c7bb:	48 83 7d e0 ff       	cmpq   $0xffffffffffffffff,-0x20(%rbp)
  800420c7c0:	75 2f                	jne    800420c7f1 <_dwarf_get_next_fde+0x1ef>
				ret = _dwarf_frame_set_cie(dbg, ds,
  800420c7c2:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c7c6:	48 8b 48 08          	mov    0x8(%rax),%rcx
  800420c7ca:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  800420c7ce:	48 8d 55 d0          	lea    -0x30(%rbp),%rdx
  800420c7d2:	48 8b 75 e8          	mov    -0x18(%rbp),%rsi
  800420c7d6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c7da:	49 89 f8             	mov    %rdi,%r8
  800420c7dd:	48 89 c7             	mov    %rax,%rdi
  800420c7e0:	48 b8 83 bd 20 04 80 	movabs $0x800420bd83,%rax
  800420c7e7:	00 00 00 
  800420c7ea:	ff d0                	callq  *%rax
  800420c7ec:	89 45 f0             	mov    %eax,-0x10(%rbp)
  800420c7ef:	eb 3b                	jmp    800420c82c <_dwarf_get_next_fde+0x22a>
							   &entry_off, ret_fde->fde_cie, error);
			else
				ret = _dwarf_frame_set_fde(dbg, ret_fde, ds,
  800420c7f1:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420c7f5:	4c 8b 40 08          	mov    0x8(%rax),%r8
  800420c7f9:	48 8d 4d d0          	lea    -0x30(%rbp),%rcx
  800420c7fd:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420c801:	48 8b 75 b0          	mov    -0x50(%rbp),%rsi
  800420c805:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c809:	48 8b 7d b8          	mov    -0x48(%rbp),%rdi
  800420c80d:	48 89 3c 24          	mov    %rdi,(%rsp)
  800420c811:	4d 89 c1             	mov    %r8,%r9
  800420c814:	41 b8 00 00 00 00    	mov    $0x0,%r8d
  800420c81a:	48 89 c7             	mov    %rax,%rdi
  800420c81d:	48 b8 e6 c1 20 04 80 	movabs $0x800420c1e6,%rax
  800420c824:	00 00 00 
  800420c827:	ff d0                	callq  *%rax
  800420c829:	89 45 f0             	mov    %eax,-0x10(%rbp)
							   &entry_off, 0, ret_fde->fde_cie, error);
		}

		if (ret != DW_DLE_NONE)
  800420c82c:	83 7d f0 00          	cmpl   $0x0,-0x10(%rbp)
  800420c830:	74 07                	je     800420c839 <_dwarf_get_next_fde+0x237>
			return(-1);
  800420c832:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420c837:	eb 19                	jmp    800420c852 <_dwarf_get_next_fde+0x250>

		offset = entry_off;
  800420c839:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420c83d:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
		dbg->curr_off_eh = offset;
  800420c841:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420c845:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420c849:	48 89 50 30          	mov    %rdx,0x30(%rax)
	}

	return (0);
  800420c84d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420c852:	c9                   	leaveq 
  800420c853:	c3                   	retq   

000000800420c854 <dwarf_set_frame_cfa_value>:

Dwarf_Half
dwarf_set_frame_cfa_value(Dwarf_Debug dbg, Dwarf_Half value)
{
  800420c854:	55                   	push   %rbp
  800420c855:	48 89 e5             	mov    %rsp,%rbp
  800420c858:	48 83 ec 1c          	sub    $0x1c,%rsp
  800420c85c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420c860:	89 f0                	mov    %esi,%eax
  800420c862:	66 89 45 e4          	mov    %ax,-0x1c(%rbp)
	Dwarf_Half old_value;

	old_value = dbg->dbg_frame_cfa_value;
  800420c866:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c86a:	0f b7 40 4c          	movzwl 0x4c(%rax),%eax
  800420c86e:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
	dbg->dbg_frame_cfa_value = value;
  800420c872:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420c876:	0f b7 55 e4          	movzwl -0x1c(%rbp),%edx
  800420c87a:	66 89 50 4c          	mov    %dx,0x4c(%rax)

	return (old_value);
  800420c87e:	0f b7 45 fe          	movzwl -0x2(%rbp),%eax
}
  800420c882:	c9                   	leaveq 
  800420c883:	c3                   	retq   

000000800420c884 <dwarf_init_eh_section>:

int dwarf_init_eh_section(Dwarf_Debug dbg, Dwarf_Error *error)
{
  800420c884:	55                   	push   %rbp
  800420c885:	48 89 e5             	mov    %rsp,%rbp
  800420c888:	48 83 ec 10          	sub    $0x10,%rsp
  800420c88c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  800420c890:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
	Dwarf_Section *section;

	if (dbg == NULL) {
  800420c894:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420c899:	75 0a                	jne    800420c8a5 <dwarf_init_eh_section+0x21>
		DWARF_SET_ERROR(dbg, error, DW_DLE_ARGUMENT);
		return (DW_DLV_ERROR);
  800420c89b:	b8 01 00 00 00       	mov    $0x1,%eax
  800420c8a0:	e9 85 00 00 00       	jmpq   800420c92a <dwarf_init_eh_section+0xa6>
	}

	if (dbg->dbg_internal_reg_table == NULL) {
  800420c8a5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c8a9:	48 8b 40 58          	mov    0x58(%rax),%rax
  800420c8ad:	48 85 c0             	test   %rax,%rax
  800420c8b0:	75 25                	jne    800420c8d7 <dwarf_init_eh_section+0x53>
		if (_dwarf_frame_interal_table_init(dbg, error) != DW_DLE_NONE)
  800420c8b2:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  800420c8b6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c8ba:	48 89 d6             	mov    %rdx,%rsi
  800420c8bd:	48 89 c7             	mov    %rax,%rdi
  800420c8c0:	48 b8 9b c5 20 04 80 	movabs $0x800420c59b,%rax
  800420c8c7:	00 00 00 
  800420c8ca:	ff d0                	callq  *%rax
  800420c8cc:	85 c0                	test   %eax,%eax
  800420c8ce:	74 07                	je     800420c8d7 <dwarf_init_eh_section+0x53>
			return (DW_DLV_ERROR);
  800420c8d0:	b8 01 00 00 00       	mov    $0x1,%eax
  800420c8d5:	eb 53                	jmp    800420c92a <dwarf_init_eh_section+0xa6>
	}

	_dwarf_find_section_enhanced(&debug_frame_sec);
  800420c8d7:	48 bf e0 25 22 04 80 	movabs $0x80042225e0,%rdi
  800420c8de:	00 00 00 
  800420c8e1:	48 b8 50 a3 20 04 80 	movabs $0x800420a350,%rax
  800420c8e8:	00 00 00 
  800420c8eb:	ff d0                	callq  *%rax

	dbg->curr_off_eh = 0;
  800420c8ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c8f1:	48 c7 40 30 00 00 00 	movq   $0x0,0x30(%rax)
  800420c8f8:	00 
	dbg->dbg_eh_offset = debug_frame_sec.ds_addr;
  800420c8f9:	48 b8 e0 25 22 04 80 	movabs $0x80042225e0,%rax
  800420c900:	00 00 00 
  800420c903:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420c907:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c90b:	48 89 50 38          	mov    %rdx,0x38(%rax)
	dbg->dbg_eh_size = debug_frame_sec.ds_size;
  800420c90f:	48 b8 e0 25 22 04 80 	movabs $0x80042225e0,%rax
  800420c916:	00 00 00 
  800420c919:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420c91d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420c921:	48 89 50 40          	mov    %rdx,0x40(%rax)

	return (DW_DLV_OK);
  800420c925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420c92a:	c9                   	leaveq 
  800420c92b:	c3                   	retq   

000000800420c92c <_dwarf_lineno_run_program>:
int  _dwarf_find_section_enhanced(Dwarf_Section *ds);

static int
_dwarf_lineno_run_program(Dwarf_CU *cu, Dwarf_LineInfo li, uint8_t *p,
			  uint8_t *pe, Dwarf_Addr pc, Dwarf_Error *error)
{
  800420c92c:	55                   	push   %rbp
  800420c92d:	48 89 e5             	mov    %rsp,%rbp
  800420c930:	53                   	push   %rbx
  800420c931:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  800420c938:	48 89 7d 88          	mov    %rdi,-0x78(%rbp)
  800420c93c:	48 89 75 80          	mov    %rsi,-0x80(%rbp)
  800420c940:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  800420c947:	48 89 8d 70 ff ff ff 	mov    %rcx,-0x90(%rbp)
  800420c94e:	4c 89 85 68 ff ff ff 	mov    %r8,-0x98(%rbp)
  800420c955:	4c 89 8d 60 ff ff ff 	mov    %r9,-0xa0(%rbp)
	uint64_t address, file, line, column, isa, opsize;
	int is_stmt, basic_block, end_sequence;
	int prologue_end, epilogue_begin;
	int ret;

	ln = &li->li_line;
  800420c95c:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420c960:	48 83 c0 48          	add    $0x48,%rax
  800420c964:	48 89 45 b8          	mov    %rax,-0x48(%rbp)

	/*
	 *   ln->ln_li     = li;             \
	 * Set registers to their default values.
	 */
	RESET_REGISTERS;
  800420c968:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  800420c96f:	00 
  800420c970:	48 c7 45 e0 01 00 00 	movq   $0x1,-0x20(%rbp)
  800420c977:	00 
  800420c978:	48 c7 45 d8 01 00 00 	movq   $0x1,-0x28(%rbp)
  800420c97f:	00 
  800420c980:	48 c7 45 d0 00 00 00 	movq   $0x0,-0x30(%rbp)
  800420c987:	00 
  800420c988:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420c98c:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  800420c990:	0f b6 c0             	movzbl %al,%eax
  800420c993:	89 45 cc             	mov    %eax,-0x34(%rbp)
  800420c996:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
  800420c99d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
  800420c9a4:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
  800420c9ab:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)

	/*
	 * Start line number program.
	 */
	while (p < pe) {
  800420c9b2:	e9 0a 05 00 00       	jmpq   800420cec1 <_dwarf_lineno_run_program+0x595>
		if (*p == 0) {
  800420c9b7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420c9be:	0f b6 00             	movzbl (%rax),%eax
  800420c9c1:	84 c0                	test   %al,%al
  800420c9c3:	0f 85 78 01 00 00    	jne    800420cb41 <_dwarf_lineno_run_program+0x215>

			/*
			 * Extended Opcodes.
			 */

			p++;
  800420c9c9:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420c9d0:	48 83 c0 01          	add    $0x1,%rax
  800420c9d4:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
			opsize = _dwarf_decode_uleb128(&p);
  800420c9db:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420c9e2:	48 89 c7             	mov    %rax,%rdi
  800420c9e5:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420c9ec:	00 00 00 
  800420c9ef:	ff d0                	callq  *%rax
  800420c9f1:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
			switch (*p) {
  800420c9f5:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420c9fc:	0f b6 00             	movzbl (%rax),%eax
  800420c9ff:	0f b6 c0             	movzbl %al,%eax
  800420ca02:	83 f8 02             	cmp    $0x2,%eax
  800420ca05:	74 7a                	je     800420ca81 <_dwarf_lineno_run_program+0x155>
  800420ca07:	83 f8 03             	cmp    $0x3,%eax
  800420ca0a:	0f 84 b3 00 00 00    	je     800420cac3 <_dwarf_lineno_run_program+0x197>
  800420ca10:	83 f8 01             	cmp    $0x1,%eax
  800420ca13:	0f 85 09 01 00 00    	jne    800420cb22 <_dwarf_lineno_run_program+0x1f6>
			case DW_LNE_end_sequence:
				p++;
  800420ca19:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420ca20:	48 83 c0 01          	add    $0x1,%rax
  800420ca24:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				end_sequence = 1;
  800420ca2b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%rbp)
				RESET_REGISTERS;
  800420ca32:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  800420ca39:	00 
  800420ca3a:	48 c7 45 e0 01 00 00 	movq   $0x1,-0x20(%rbp)
  800420ca41:	00 
  800420ca42:	48 c7 45 d8 01 00 00 	movq   $0x1,-0x28(%rbp)
  800420ca49:	00 
  800420ca4a:	48 c7 45 d0 00 00 00 	movq   $0x0,-0x30(%rbp)
  800420ca51:	00 
  800420ca52:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420ca56:	0f b6 40 19          	movzbl 0x19(%rax),%eax
  800420ca5a:	0f b6 c0             	movzbl %al,%eax
  800420ca5d:	89 45 cc             	mov    %eax,-0x34(%rbp)
  800420ca60:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
  800420ca67:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%rbp)
  800420ca6e:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
  800420ca75:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
				break;
  800420ca7c:	e9 bb 00 00 00       	jmpq   800420cb3c <_dwarf_lineno_run_program+0x210>
			case DW_LNE_set_address:
				p++;
  800420ca81:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420ca88:	48 83 c0 01          	add    $0x1,%rax
  800420ca8c:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				address = dbg->decode(&p, cu->addr_size);
  800420ca93:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420ca9a:	00 00 00 
  800420ca9d:	48 8b 00             	mov    (%rax),%rax
  800420caa0:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420caa4:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
  800420caa8:	0f b6 52 0a          	movzbl 0xa(%rdx),%edx
  800420caac:	0f b6 ca             	movzbl %dl,%ecx
  800420caaf:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  800420cab6:	89 ce                	mov    %ecx,%esi
  800420cab8:	48 89 d7             	mov    %rdx,%rdi
  800420cabb:	ff d0                	callq  *%rax
  800420cabd:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
				break;
  800420cac1:	eb 79                	jmp    800420cb3c <_dwarf_lineno_run_program+0x210>
			case DW_LNE_define_file:
				p++;
  800420cac3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420caca:	48 83 c0 01          	add    $0x1,%rax
  800420cace:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
				ret = _dwarf_lineno_add_file(li, &p, NULL,
  800420cad5:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420cadc:	00 00 00 
  800420cadf:	48 8b 08             	mov    (%rax),%rcx
  800420cae2:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  800420cae9:	48 8d b5 78 ff ff ff 	lea    -0x88(%rbp),%rsi
  800420caf0:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420caf4:	49 89 c8             	mov    %rcx,%r8
  800420caf7:	48 89 d1             	mov    %rdx,%rcx
  800420cafa:	ba 00 00 00 00       	mov    $0x0,%edx
  800420caff:	48 89 c7             	mov    %rax,%rdi
  800420cb02:	48 b8 e4 ce 20 04 80 	movabs $0x800420cee4,%rax
  800420cb09:	00 00 00 
  800420cb0c:	ff d0                	callq  *%rax
  800420cb0e:	89 45 a4             	mov    %eax,-0x5c(%rbp)
							     error, dbg);
				if (ret != DW_DLE_NONE)
  800420cb11:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  800420cb15:	74 09                	je     800420cb20 <_dwarf_lineno_run_program+0x1f4>
					goto prog_fail;
  800420cb17:	90                   	nop

	return (DW_DLE_NONE);

prog_fail:

	return (ret);
  800420cb18:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  800420cb1b:	e9 ba 03 00 00       	jmpq   800420ceda <_dwarf_lineno_run_program+0x5ae>
				p++;
				ret = _dwarf_lineno_add_file(li, &p, NULL,
							     error, dbg);
				if (ret != DW_DLE_NONE)
					goto prog_fail;
				break;
  800420cb20:	eb 1a                	jmp    800420cb3c <_dwarf_lineno_run_program+0x210>
			default:
				/* Unrecognized extened opcodes. */
				p += opsize;
  800420cb22:	48 8b 95 78 ff ff ff 	mov    -0x88(%rbp),%rdx
  800420cb29:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420cb2d:	48 01 d0             	add    %rdx,%rax
  800420cb30:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  800420cb37:	e9 85 03 00 00       	jmpq   800420cec1 <_dwarf_lineno_run_program+0x595>
  800420cb3c:	e9 80 03 00 00       	jmpq   800420cec1 <_dwarf_lineno_run_program+0x595>
			}

		} else if (*p > 0 && *p < li->li_opbase) {
  800420cb41:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cb48:	0f b6 00             	movzbl (%rax),%eax
  800420cb4b:	84 c0                	test   %al,%al
  800420cb4d:	0f 84 3c 02 00 00    	je     800420cd8f <_dwarf_lineno_run_program+0x463>
  800420cb53:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cb5a:	0f b6 10             	movzbl (%rax),%edx
  800420cb5d:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cb61:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420cb65:	38 c2                	cmp    %al,%dl
  800420cb67:	0f 83 22 02 00 00    	jae    800420cd8f <_dwarf_lineno_run_program+0x463>

			/*
			 * Standard Opcodes.
			 */

			switch (*p++) {
  800420cb6d:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cb74:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420cb78:	48 89 95 78 ff ff ff 	mov    %rdx,-0x88(%rbp)
  800420cb7f:	0f b6 00             	movzbl (%rax),%eax
  800420cb82:	0f b6 c0             	movzbl %al,%eax
  800420cb85:	83 f8 0c             	cmp    $0xc,%eax
  800420cb88:	0f 87 fb 01 00 00    	ja     800420cd89 <_dwarf_lineno_run_program+0x45d>
  800420cb8e:	89 c0                	mov    %eax,%eax
  800420cb90:	48 8d 14 c5 00 00 00 	lea    0x0(,%rax,8),%rdx
  800420cb97:	00 
  800420cb98:	48 b8 c8 fe 20 04 80 	movabs $0x800420fec8,%rax
  800420cb9f:	00 00 00 
  800420cba2:	48 01 d0             	add    %rdx,%rax
  800420cba5:	48 8b 00             	mov    (%rax),%rax
  800420cba8:	ff e0                	jmpq   *%rax
			case DW_LNS_copy:
				APPEND_ROW;
  800420cbaa:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420cbb1:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  800420cbb5:	73 0a                	jae    800420cbc1 <_dwarf_lineno_run_program+0x295>
  800420cbb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800420cbbc:	e9 19 03 00 00       	jmpq   800420ceda <_dwarf_lineno_run_program+0x5ae>
  800420cbc1:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cbc5:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420cbc9:	48 89 10             	mov    %rdx,(%rax)
  800420cbcc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cbd0:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  800420cbd7:	00 
  800420cbd8:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cbdc:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420cbe0:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800420cbe4:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cbe8:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420cbec:	48 89 50 18          	mov    %rdx,0x18(%rax)
  800420cbf0:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420cbf4:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cbf8:	48 89 50 20          	mov    %rdx,0x20(%rax)
  800420cbfc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cc00:	8b 55 c8             	mov    -0x38(%rbp),%edx
  800420cc03:	89 50 28             	mov    %edx,0x28(%rax)
  800420cc06:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cc0a:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420cc0d:	89 50 2c             	mov    %edx,0x2c(%rax)
  800420cc10:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420cc14:	8b 55 c4             	mov    -0x3c(%rbp),%edx
  800420cc17:	89 50 30             	mov    %edx,0x30(%rax)
  800420cc1a:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cc1e:	48 8b 80 80 00 00 00 	mov    0x80(%rax),%rax
  800420cc25:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420cc29:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cc2d:	48 89 90 80 00 00 00 	mov    %rdx,0x80(%rax)
				basic_block = 0;
  800420cc34:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
				prologue_end = 0;
  800420cc3b:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
				epilogue_begin = 0;
  800420cc42:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
				break;
  800420cc49:	e9 3c 01 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_advance_pc:
				address += _dwarf_decode_uleb128(&p) *
  800420cc4e:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420cc55:	48 89 c7             	mov    %rax,%rdi
  800420cc58:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cc5f:	00 00 00 
  800420cc62:	ff d0                	callq  *%rax
					li->li_minlen;
  800420cc64:	48 8b 55 80          	mov    -0x80(%rbp),%rdx
  800420cc68:	0f b6 52 18          	movzbl 0x18(%rdx),%edx
				basic_block = 0;
				prologue_end = 0;
				epilogue_begin = 0;
				break;
			case DW_LNS_advance_pc:
				address += _dwarf_decode_uleb128(&p) *
  800420cc6c:	0f b6 d2             	movzbl %dl,%edx
  800420cc6f:	48 0f af c2          	imul   %rdx,%rax
  800420cc73:	48 01 45 e8          	add    %rax,-0x18(%rbp)
					li->li_minlen;
				break;
  800420cc77:	e9 0e 01 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_advance_line:
				line += _dwarf_decode_sleb128(&p);
  800420cc7c:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420cc83:	48 89 c7             	mov    %rax,%rdi
  800420cc86:	48 b8 31 8b 20 04 80 	movabs $0x8004208b31,%rax
  800420cc8d:	00 00 00 
  800420cc90:	ff d0                	callq  *%rax
  800420cc92:	48 01 45 d8          	add    %rax,-0x28(%rbp)
				break;
  800420cc96:	e9 ef 00 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_file:
				file = _dwarf_decode_uleb128(&p);
  800420cc9b:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420cca2:	48 89 c7             	mov    %rax,%rdi
  800420cca5:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420ccac:	00 00 00 
  800420ccaf:	ff d0                	callq  *%rax
  800420ccb1:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
				break;
  800420ccb5:	e9 d0 00 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_column:
				column = _dwarf_decode_uleb128(&p);
  800420ccba:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420ccc1:	48 89 c7             	mov    %rax,%rdi
  800420ccc4:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cccb:	00 00 00 
  800420ccce:	ff d0                	callq  *%rax
  800420ccd0:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
				break;
  800420ccd4:	e9 b1 00 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_negate_stmt:
				is_stmt = !is_stmt;
  800420ccd9:	83 7d cc 00          	cmpl   $0x0,-0x34(%rbp)
  800420ccdd:	0f 94 c0             	sete   %al
  800420cce0:	0f b6 c0             	movzbl %al,%eax
  800420cce3:	89 45 cc             	mov    %eax,-0x34(%rbp)
				break;
  800420cce6:	e9 9f 00 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_basic_block:
				basic_block = 1;
  800420cceb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%rbp)
				break;
  800420ccf2:	e9 93 00 00 00       	jmpq   800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_const_add_pc:
				address += ADDRESS(255);
  800420ccf7:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420ccfb:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420ccff:	0f b6 c0             	movzbl %al,%eax
  800420cd02:	ba ff 00 00 00       	mov    $0xff,%edx
  800420cd07:	89 d1                	mov    %edx,%ecx
  800420cd09:	29 c1                	sub    %eax,%ecx
  800420cd0b:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cd0f:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  800420cd13:	0f b6 d8             	movzbl %al,%ebx
  800420cd16:	89 c8                	mov    %ecx,%eax
  800420cd18:	99                   	cltd   
  800420cd19:	f7 fb                	idiv   %ebx
  800420cd1b:	89 c2                	mov    %eax,%edx
  800420cd1d:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cd21:	0f b6 40 18          	movzbl 0x18(%rax),%eax
  800420cd25:	0f b6 c0             	movzbl %al,%eax
  800420cd28:	0f af c2             	imul   %edx,%eax
  800420cd2b:	48 98                	cltq   
  800420cd2d:	48 01 45 e8          	add    %rax,-0x18(%rbp)
				break;
  800420cd31:	eb 57                	jmp    800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_fixed_advance_pc:
				address += dbg->decode(&p, 2);
  800420cd33:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420cd3a:	00 00 00 
  800420cd3d:	48 8b 00             	mov    (%rax),%rax
  800420cd40:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420cd44:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  800420cd4b:	be 02 00 00 00       	mov    $0x2,%esi
  800420cd50:	48 89 d7             	mov    %rdx,%rdi
  800420cd53:	ff d0                	callq  *%rax
  800420cd55:	48 01 45 e8          	add    %rax,-0x18(%rbp)
				break;
  800420cd59:	eb 2f                	jmp    800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_prologue_end:
				prologue_end = 1;
  800420cd5b:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%rbp)
				break;
  800420cd62:	eb 26                	jmp    800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_epilogue_begin:
				epilogue_begin = 1;
  800420cd64:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%rbp)
				break;
  800420cd6b:	eb 1d                	jmp    800420cd8a <_dwarf_lineno_run_program+0x45e>
			case DW_LNS_set_isa:
				isa = _dwarf_decode_uleb128(&p);
  800420cd6d:	48 8d 85 78 ff ff ff 	lea    -0x88(%rbp),%rax
  800420cd74:	48 89 c7             	mov    %rax,%rdi
  800420cd77:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cd7e:	00 00 00 
  800420cd81:	ff d0                	callq  *%rax
  800420cd83:	48 89 45 98          	mov    %rax,-0x68(%rbp)
				break;
  800420cd87:	eb 01                	jmp    800420cd8a <_dwarf_lineno_run_program+0x45e>
			default:
				/* Unrecognized extened opcodes. What to do? */
				break;
  800420cd89:	90                   	nop
			}

		} else {
  800420cd8a:	e9 32 01 00 00       	jmpq   800420cec1 <_dwarf_lineno_run_program+0x595>

			/*
			 * Special Opcodes.
			 */

			line += LINE(*p);
  800420cd8f:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cd93:	0f b6 40 1a          	movzbl 0x1a(%rax),%eax
  800420cd97:	0f be c8             	movsbl %al,%ecx
  800420cd9a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cda1:	0f b6 00             	movzbl (%rax),%eax
  800420cda4:	0f b6 d0             	movzbl %al,%edx
  800420cda7:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cdab:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420cdaf:	0f b6 c0             	movzbl %al,%eax
  800420cdb2:	29 c2                	sub    %eax,%edx
  800420cdb4:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cdb8:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  800420cdbc:	0f b6 f0             	movzbl %al,%esi
  800420cdbf:	89 d0                	mov    %edx,%eax
  800420cdc1:	99                   	cltd   
  800420cdc2:	f7 fe                	idiv   %esi
  800420cdc4:	89 d0                	mov    %edx,%eax
  800420cdc6:	01 c8                	add    %ecx,%eax
  800420cdc8:	48 98                	cltq   
  800420cdca:	48 01 45 d8          	add    %rax,-0x28(%rbp)
			address += ADDRESS(*p);
  800420cdce:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cdd5:	0f b6 00             	movzbl (%rax),%eax
  800420cdd8:	0f b6 d0             	movzbl %al,%edx
  800420cddb:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cddf:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420cde3:	0f b6 c0             	movzbl %al,%eax
  800420cde6:	89 d1                	mov    %edx,%ecx
  800420cde8:	29 c1                	sub    %eax,%ecx
  800420cdea:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420cdee:	0f b6 40 1b          	movzbl 0x1b(%rax),%eax
  800420cdf2:	0f b6 d8             	movzbl %al,%ebx
  800420cdf5:	89 c8                	mov    %ecx,%eax
  800420cdf7:	99                   	cltd   
  800420cdf8:	f7 fb                	idiv   %ebx
  800420cdfa:	89 c2                	mov    %eax,%edx
  800420cdfc:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420ce00:	0f b6 40 18          	movzbl 0x18(%rax),%eax
  800420ce04:	0f b6 c0             	movzbl %al,%eax
  800420ce07:	0f af c2             	imul   %edx,%eax
  800420ce0a:	48 98                	cltq   
  800420ce0c:	48 01 45 e8          	add    %rax,-0x18(%rbp)
			APPEND_ROW;
  800420ce10:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420ce17:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  800420ce1b:	73 0a                	jae    800420ce27 <_dwarf_lineno_run_program+0x4fb>
  800420ce1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800420ce22:	e9 b3 00 00 00       	jmpq   800420ceda <_dwarf_lineno_run_program+0x5ae>
  800420ce27:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce2b:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420ce2f:	48 89 10             	mov    %rdx,(%rax)
  800420ce32:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce36:	48 c7 40 08 00 00 00 	movq   $0x0,0x8(%rax)
  800420ce3d:	00 
  800420ce3e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce42:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420ce46:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800420ce4a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce4e:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420ce52:	48 89 50 18          	mov    %rdx,0x18(%rax)
  800420ce56:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420ce5a:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce5e:	48 89 50 20          	mov    %rdx,0x20(%rax)
  800420ce62:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce66:	8b 55 c8             	mov    -0x38(%rbp),%edx
  800420ce69:	89 50 28             	mov    %edx,0x28(%rax)
  800420ce6c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce70:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420ce73:	89 50 2c             	mov    %edx,0x2c(%rax)
  800420ce76:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420ce7a:	8b 55 c4             	mov    -0x3c(%rbp),%edx
  800420ce7d:	89 50 30             	mov    %edx,0x30(%rax)
  800420ce80:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420ce84:	48 8b 80 80 00 00 00 	mov    0x80(%rax),%rax
  800420ce8b:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420ce8f:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420ce93:	48 89 90 80 00 00 00 	mov    %rdx,0x80(%rax)
			basic_block = 0;
  800420ce9a:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%rbp)
			prologue_end = 0;
  800420cea1:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%rbp)
			epilogue_begin = 0;
  800420cea8:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
			p++;
  800420ceaf:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420ceb6:	48 83 c0 01          	add    $0x1,%rax
  800420ceba:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
	RESET_REGISTERS;

	/*
	 * Start line number program.
	 */
	while (p < pe) {
  800420cec1:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420cec8:	48 3b 85 70 ff ff ff 	cmp    -0x90(%rbp),%rax
  800420cecf:	0f 82 e2 fa ff ff    	jb     800420c9b7 <_dwarf_lineno_run_program+0x8b>
			epilogue_begin = 0;
			p++;
		}
	}

	return (DW_DLE_NONE);
  800420ced5:	b8 00 00 00 00       	mov    $0x0,%eax

#undef  RESET_REGISTERS
#undef  APPEND_ROW
#undef  LINE
#undef  ADDRESS
}
  800420ceda:	48 81 c4 98 00 00 00 	add    $0x98,%rsp
  800420cee1:	5b                   	pop    %rbx
  800420cee2:	5d                   	pop    %rbp
  800420cee3:	c3                   	retq   

000000800420cee4 <_dwarf_lineno_add_file>:

static int
_dwarf_lineno_add_file(Dwarf_LineInfo li, uint8_t **p, const char *compdir,
		       Dwarf_Error *error, Dwarf_Debug dbg)
{
  800420cee4:	55                   	push   %rbp
  800420cee5:	48 89 e5             	mov    %rsp,%rbp
  800420cee8:	53                   	push   %rbx
  800420cee9:	48 83 ec 48          	sub    $0x48,%rsp
  800420ceed:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  800420cef1:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  800420cef5:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  800420cef9:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
  800420cefd:	4c 89 45 b8          	mov    %r8,-0x48(%rbp)
	char *fname;
	//const char *dirname;
	uint8_t *src;
	int slen;

	src = *p;
  800420cf01:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420cf05:	48 8b 00             	mov    (%rax),%rax
  800420cf08:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  DWARF_SET_ERROR(dbg, error, DW_DLE_MEMORY);
  return (DW_DLE_MEMORY);
  }
*/  
	//lf->lf_fullpath = NULL;
	fname = (char *) src;
  800420cf0c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420cf10:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	src += strlen(fname) + 1;
  800420cf14:	48 8b 5d e0          	mov    -0x20(%rbp),%rbx
  800420cf18:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420cf1c:	48 89 c7             	mov    %rax,%rdi
  800420cf1f:	48 b8 9b 7c 20 04 80 	movabs $0x8004207c9b,%rax
  800420cf26:	00 00 00 
  800420cf29:	ff d0                	callq  *%rax
  800420cf2b:	48 98                	cltq   
  800420cf2d:	48 83 c0 01          	add    $0x1,%rax
  800420cf31:	48 01 d8             	add    %rbx,%rax
  800420cf34:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	_dwarf_decode_uleb128(&src);
  800420cf38:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  800420cf3c:	48 89 c7             	mov    %rax,%rdi
  800420cf3f:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cf46:	00 00 00 
  800420cf49:	ff d0                	callq  *%rax
	   snprintf(lf->lf_fullpath, slen, "%s/%s", dirname,
	   lf->lf_fname);
	   }
	   }
	*/
	_dwarf_decode_uleb128(&src);
  800420cf4b:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  800420cf4f:	48 89 c7             	mov    %rax,%rdi
  800420cf52:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cf59:	00 00 00 
  800420cf5c:	ff d0                	callq  *%rax
	_dwarf_decode_uleb128(&src);
  800420cf5e:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
  800420cf62:	48 89 c7             	mov    %rax,%rdi
  800420cf65:	48 b8 c3 8b 20 04 80 	movabs $0x8004208bc3,%rax
  800420cf6c:	00 00 00 
  800420cf6f:	ff d0                	callq  *%rax
	//STAILQ_INSERT_TAIL(&li->li_lflist, lf, lf_next);
	//li->li_lflen++;

	*p = src;
  800420cf71:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420cf75:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420cf79:	48 89 10             	mov    %rdx,(%rax)

	return (DW_DLE_NONE);
  800420cf7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420cf81:	48 83 c4 48          	add    $0x48,%rsp
  800420cf85:	5b                   	pop    %rbx
  800420cf86:	5d                   	pop    %rbp
  800420cf87:	c3                   	retq   

000000800420cf88 <_dwarf_lineno_init>:

int     
_dwarf_lineno_init(Dwarf_Die *die, uint64_t offset, Dwarf_LineInfo linfo, Dwarf_Addr pc, Dwarf_Error *error)
{   
  800420cf88:	55                   	push   %rbp
  800420cf89:	48 89 e5             	mov    %rsp,%rbp
  800420cf8c:	53                   	push   %rbx
  800420cf8d:	48 81 ec 08 01 00 00 	sub    $0x108,%rsp
  800420cf94:	48 89 bd 18 ff ff ff 	mov    %rdi,-0xe8(%rbp)
  800420cf9b:	48 89 b5 10 ff ff ff 	mov    %rsi,-0xf0(%rbp)
  800420cfa2:	48 89 95 08 ff ff ff 	mov    %rdx,-0xf8(%rbp)
  800420cfa9:	48 89 8d 00 ff ff ff 	mov    %rcx,-0x100(%rbp)
  800420cfb0:	4c 89 85 f8 fe ff ff 	mov    %r8,-0x108(%rbp)
	Dwarf_Section myds = {.ds_name = ".debug_line"};
  800420cfb7:	48 c7 45 90 00 00 00 	movq   $0x0,-0x70(%rbp)
  800420cfbe:	00 
  800420cfbf:	48 c7 45 98 00 00 00 	movq   $0x0,-0x68(%rbp)
  800420cfc6:	00 
  800420cfc7:	48 c7 45 a0 00 00 00 	movq   $0x0,-0x60(%rbp)
  800420cfce:	00 
  800420cfcf:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  800420cfd6:	00 
  800420cfd7:	48 b8 30 ff 20 04 80 	movabs $0x800420ff30,%rax
  800420cfde:	00 00 00 
  800420cfe1:	48 89 45 90          	mov    %rax,-0x70(%rbp)
	Dwarf_Section *ds = &myds;
  800420cfe5:	48 8d 45 90          	lea    -0x70(%rbp),%rax
  800420cfe9:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	//Dwarf_LineFile lf, tlf;
	uint64_t length, hdroff, endoff;
	uint8_t *p;
	int dwarf_size, i, ret;
            
	cu = die->cu_header;
  800420cfed:	48 8b 85 18 ff ff ff 	mov    -0xe8(%rbp),%rax
  800420cff4:	48 8b 80 60 03 00 00 	mov    0x360(%rax),%rax
  800420cffb:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
	assert(cu != NULL); 
  800420cfff:	48 83 7d c8 00       	cmpq   $0x0,-0x38(%rbp)
  800420d004:	75 35                	jne    800420d03b <_dwarf_lineno_init+0xb3>
  800420d006:	48 b9 3c ff 20 04 80 	movabs $0x800420ff3c,%rcx
  800420d00d:	00 00 00 
  800420d010:	48 ba 47 ff 20 04 80 	movabs $0x800420ff47,%rdx
  800420d017:	00 00 00 
  800420d01a:	be 13 01 00 00       	mov    $0x113,%esi
  800420d01f:	48 bf 5c ff 20 04 80 	movabs $0x800420ff5c,%rdi
  800420d026:	00 00 00 
  800420d029:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d02e:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420d035:	00 00 00 
  800420d038:	41 ff d0             	callq  *%r8
	assert(dbg != NULL);
  800420d03b:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d042:	00 00 00 
  800420d045:	48 8b 00             	mov    (%rax),%rax
  800420d048:	48 85 c0             	test   %rax,%rax
  800420d04b:	75 35                	jne    800420d082 <_dwarf_lineno_init+0xfa>
  800420d04d:	48 b9 73 ff 20 04 80 	movabs $0x800420ff73,%rcx
  800420d054:	00 00 00 
  800420d057:	48 ba 47 ff 20 04 80 	movabs $0x800420ff47,%rdx
  800420d05e:	00 00 00 
  800420d061:	be 14 01 00 00       	mov    $0x114,%esi
  800420d066:	48 bf 5c ff 20 04 80 	movabs $0x800420ff5c,%rdi
  800420d06d:	00 00 00 
  800420d070:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d075:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420d07c:	00 00 00 
  800420d07f:	41 ff d0             	callq  *%r8

	if ((_dwarf_find_section_enhanced(ds)) != 0)
  800420d082:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d086:	48 89 c7             	mov    %rax,%rdi
  800420d089:	48 b8 50 a3 20 04 80 	movabs $0x800420a350,%rax
  800420d090:	00 00 00 
  800420d093:	ff d0                	callq  *%rax
  800420d095:	85 c0                	test   %eax,%eax
  800420d097:	74 0a                	je     800420d0a3 <_dwarf_lineno_init+0x11b>
		return (DW_DLE_NONE);
  800420d099:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d09e:	e9 4f 04 00 00       	jmpq   800420d4f2 <_dwarf_lineno_init+0x56a>

	li = linfo;
  800420d0a3:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
  800420d0aa:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
	 break;
	 }
	 }
	*/

	length = dbg->read(ds->ds_data, &offset, 4);
  800420d0ae:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d0b5:	00 00 00 
  800420d0b8:	48 8b 00             	mov    (%rax),%rax
  800420d0bb:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d0bf:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d0c3:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d0c7:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d0ce:	ba 04 00 00 00       	mov    $0x4,%edx
  800420d0d3:	48 89 cf             	mov    %rcx,%rdi
  800420d0d6:	ff d0                	callq  *%rax
  800420d0d8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	if (length == 0xffffffff) {
  800420d0dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420d0e1:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
  800420d0e5:	75 37                	jne    800420d11e <_dwarf_lineno_init+0x196>
		dwarf_size = 8;
  800420d0e7:	c7 45 e4 08 00 00 00 	movl   $0x8,-0x1c(%rbp)
		length = dbg->read(ds->ds_data, &offset, 8);
  800420d0ee:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d0f5:	00 00 00 
  800420d0f8:	48 8b 00             	mov    (%rax),%rax
  800420d0fb:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d0ff:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d103:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d107:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d10e:	ba 08 00 00 00       	mov    $0x8,%edx
  800420d113:	48 89 cf             	mov    %rcx,%rdi
  800420d116:	ff d0                	callq  *%rax
  800420d118:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800420d11c:	eb 07                	jmp    800420d125 <_dwarf_lineno_init+0x19d>
	} else
		dwarf_size = 4;
  800420d11e:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%rbp)

	if (length > ds->ds_size - offset) {
  800420d125:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d129:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420d12d:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  800420d134:	48 29 c2             	sub    %rax,%rdx
  800420d137:	48 89 d0             	mov    %rdx,%rax
  800420d13a:	48 3b 45 e8          	cmp    -0x18(%rbp),%rax
  800420d13e:	73 0a                	jae    800420d14a <_dwarf_lineno_init+0x1c2>
		DWARF_SET_ERROR(dbg, error, DW_DLE_DEBUG_LINE_LENGTH_BAD);
		return (DW_DLE_DEBUG_LINE_LENGTH_BAD);
  800420d140:	b8 0f 00 00 00       	mov    $0xf,%eax
  800420d145:	e9 a8 03 00 00       	jmpq   800420d4f2 <_dwarf_lineno_init+0x56a>
	}
	/*
	 * Read in line number program header.
	 */
	li->li_length = length;
  800420d14a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d14e:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420d152:	48 89 10             	mov    %rdx,(%rax)
	endoff = offset + length;
  800420d155:	48 8b 95 10 ff ff ff 	mov    -0xf0(%rbp),%rdx
  800420d15c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d160:	48 01 d0             	add    %rdx,%rax
  800420d163:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
	li->li_version = dbg->read(ds->ds_data, &offset, 2); /* FIXME: verify version */
  800420d167:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d16e:	00 00 00 
  800420d171:	48 8b 00             	mov    (%rax),%rax
  800420d174:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d178:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d17c:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d180:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d187:	ba 02 00 00 00       	mov    $0x2,%edx
  800420d18c:	48 89 cf             	mov    %rcx,%rdi
  800420d18f:	ff d0                	callq  *%rax
  800420d191:	89 c2                	mov    %eax,%edx
  800420d193:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d197:	66 89 50 08          	mov    %dx,0x8(%rax)
	li->li_hdrlen = dbg->read(ds->ds_data, &offset, dwarf_size);
  800420d19b:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d1a2:	00 00 00 
  800420d1a5:	48 8b 00             	mov    (%rax),%rax
  800420d1a8:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d1ac:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d1b0:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d1b4:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  800420d1b7:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d1be:	48 89 cf             	mov    %rcx,%rdi
  800420d1c1:	ff d0                	callq  *%rax
  800420d1c3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420d1c7:	48 89 42 10          	mov    %rax,0x10(%rdx)
	hdroff = offset;
  800420d1cb:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  800420d1d2:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
	li->li_minlen = dbg->read(ds->ds_data, &offset, 1);
  800420d1d6:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d1dd:	00 00 00 
  800420d1e0:	48 8b 00             	mov    (%rax),%rax
  800420d1e3:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d1e7:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d1eb:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d1ef:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d1f6:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d1fb:	48 89 cf             	mov    %rcx,%rdi
  800420d1fe:	ff d0                	callq  *%rax
  800420d200:	89 c2                	mov    %eax,%edx
  800420d202:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d206:	88 50 18             	mov    %dl,0x18(%rax)
	li->li_defstmt = dbg->read(ds->ds_data, &offset, 1);
  800420d209:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d210:	00 00 00 
  800420d213:	48 8b 00             	mov    (%rax),%rax
  800420d216:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d21a:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d21e:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d222:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d229:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d22e:	48 89 cf             	mov    %rcx,%rdi
  800420d231:	ff d0                	callq  *%rax
  800420d233:	89 c2                	mov    %eax,%edx
  800420d235:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d239:	88 50 19             	mov    %dl,0x19(%rax)
	li->li_lbase = dbg->read(ds->ds_data, &offset, 1);
  800420d23c:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d243:	00 00 00 
  800420d246:	48 8b 00             	mov    (%rax),%rax
  800420d249:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d24d:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d251:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d255:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d25c:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d261:	48 89 cf             	mov    %rcx,%rdi
  800420d264:	ff d0                	callq  *%rax
  800420d266:	89 c2                	mov    %eax,%edx
  800420d268:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d26c:	88 50 1a             	mov    %dl,0x1a(%rax)
	li->li_lrange = dbg->read(ds->ds_data, &offset, 1);
  800420d26f:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d276:	00 00 00 
  800420d279:	48 8b 00             	mov    (%rax),%rax
  800420d27c:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d280:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d284:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d288:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d28f:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d294:	48 89 cf             	mov    %rcx,%rdi
  800420d297:	ff d0                	callq  *%rax
  800420d299:	89 c2                	mov    %eax,%edx
  800420d29b:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d29f:	88 50 1b             	mov    %dl,0x1b(%rax)
	li->li_opbase = dbg->read(ds->ds_data, &offset, 1);
  800420d2a2:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d2a9:	00 00 00 
  800420d2ac:	48 8b 00             	mov    (%rax),%rax
  800420d2af:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d2b3:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d2b7:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d2bb:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d2c2:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d2c7:	48 89 cf             	mov    %rcx,%rdi
  800420d2ca:	ff d0                	callq  *%rax
  800420d2cc:	89 c2                	mov    %eax,%edx
  800420d2ce:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d2d2:	88 50 1c             	mov    %dl,0x1c(%rax)
	//STAILQ_INIT(&li->li_lflist);
	//STAILQ_INIT(&li->li_lnlist);

	if ((int)li->li_hdrlen - 5 < li->li_opbase - 1) {
  800420d2d5:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d2d9:	48 8b 40 10          	mov    0x10(%rax),%rax
  800420d2dd:	8d 50 fb             	lea    -0x5(%rax),%edx
  800420d2e0:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d2e4:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420d2e8:	0f b6 c0             	movzbl %al,%eax
  800420d2eb:	83 e8 01             	sub    $0x1,%eax
  800420d2ee:	39 c2                	cmp    %eax,%edx
  800420d2f0:	7d 0c                	jge    800420d2fe <_dwarf_lineno_init+0x376>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  800420d2f2:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  800420d2f9:	e9 f1 01 00 00       	jmpq   800420d4ef <_dwarf_lineno_init+0x567>
	}

	li->li_oplen = global_std_op;
  800420d2fe:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d302:	48 bb 80 3b 22 04 80 	movabs $0x8004223b80,%rbx
  800420d309:	00 00 00 
  800420d30c:	48 89 58 20          	mov    %rbx,0x20(%rax)

	/*
	 * Read in std opcode arg length list. Note that the first
	 * element is not used.
	 */
	for (i = 1; i < li->li_opbase; i++)
  800420d310:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%rbp)
  800420d317:	eb 41                	jmp    800420d35a <_dwarf_lineno_init+0x3d2>
		li->li_oplen[i] = dbg->read(ds->ds_data, &offset, 1);
  800420d319:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d31d:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d321:	8b 45 e0             	mov    -0x20(%rbp),%eax
  800420d324:	48 98                	cltq   
  800420d326:	48 8d 1c 02          	lea    (%rdx,%rax,1),%rbx
  800420d32a:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d331:	00 00 00 
  800420d334:	48 8b 00             	mov    (%rax),%rax
  800420d337:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d33b:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d33f:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
  800420d343:	48 8d b5 10 ff ff ff 	lea    -0xf0(%rbp),%rsi
  800420d34a:	ba 01 00 00 00       	mov    $0x1,%edx
  800420d34f:	48 89 cf             	mov    %rcx,%rdi
  800420d352:	ff d0                	callq  *%rax
  800420d354:	88 03                	mov    %al,(%rbx)

	/*
	 * Read in std opcode arg length list. Note that the first
	 * element is not used.
	 */
	for (i = 1; i < li->li_opbase; i++)
  800420d356:	83 45 e0 01          	addl   $0x1,-0x20(%rbp)
  800420d35a:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d35e:	0f b6 40 1c          	movzbl 0x1c(%rax),%eax
  800420d362:	0f b6 c0             	movzbl %al,%eax
  800420d365:	3b 45 e0             	cmp    -0x20(%rbp),%eax
  800420d368:	7f af                	jg     800420d319 <_dwarf_lineno_init+0x391>
		li->li_oplen[i] = dbg->read(ds->ds_data, &offset, 1);

	/*
	 * Check how many strings in the include dir string array.
	 */
	length = 0;
  800420d36a:	48 c7 45 e8 00 00 00 	movq   $0x0,-0x18(%rbp)
  800420d371:	00 
	p = ds->ds_data + offset;
  800420d372:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d376:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420d37a:	48 8b 85 10 ff ff ff 	mov    -0xf0(%rbp),%rax
  800420d381:	48 01 d0             	add    %rdx,%rax
  800420d384:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
	while (*p != '\0') {
  800420d38b:	eb 1f                	jmp    800420d3ac <_dwarf_lineno_init+0x424>
		while (*p++ != '\0')
  800420d38d:	90                   	nop
  800420d38e:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d395:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800420d399:	48 89 95 28 ff ff ff 	mov    %rdx,-0xd8(%rbp)
  800420d3a0:	0f b6 00             	movzbl (%rax),%eax
  800420d3a3:	84 c0                	test   %al,%al
  800420d3a5:	75 e7                	jne    800420d38e <_dwarf_lineno_init+0x406>
			;
		length++;
  800420d3a7:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
	/*
	 * Check how many strings in the include dir string array.
	 */
	length = 0;
	p = ds->ds_data + offset;
	while (*p != '\0') {
  800420d3ac:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d3b3:	0f b6 00             	movzbl (%rax),%eax
  800420d3b6:	84 c0                	test   %al,%al
  800420d3b8:	75 d3                	jne    800420d38d <_dwarf_lineno_init+0x405>
		while (*p++ != '\0')
			;
		length++;
	}
	li->li_inclen = length;
  800420d3ba:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d3be:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420d3c2:	48 89 50 30          	mov    %rdx,0x30(%rax)

	/* Sanity check. */
	if (p - ds->ds_data > (int) ds->ds_size) {
  800420d3c6:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d3cd:	48 89 c2             	mov    %rax,%rdx
  800420d3d0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d3d4:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420d3d8:	48 29 c2             	sub    %rax,%rdx
  800420d3db:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d3df:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420d3e3:	48 98                	cltq   
  800420d3e5:	48 39 c2             	cmp    %rax,%rdx
  800420d3e8:	7e 0c                	jle    800420d3f6 <_dwarf_lineno_init+0x46e>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  800420d3ea:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  800420d3f1:	e9 f9 00 00 00       	jmpq   800420d4ef <_dwarf_lineno_init+0x567>
	}
	p++;
  800420d3f6:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d3fd:	48 83 c0 01          	add    $0x1,%rax
  800420d401:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

	/*
	 * Process file list.
	 */
	while (*p != '\0') {
  800420d408:	eb 3c                	jmp    800420d446 <_dwarf_lineno_init+0x4be>
		ret = _dwarf_lineno_add_file(li, &p, NULL, error, dbg);
  800420d40a:	48 b8 d8 25 22 04 80 	movabs $0x80042225d8,%rax
  800420d411:	00 00 00 
  800420d414:	48 8b 08             	mov    (%rax),%rcx
  800420d417:	48 8b 95 f8 fe ff ff 	mov    -0x108(%rbp),%rdx
  800420d41e:	48 8d b5 28 ff ff ff 	lea    -0xd8(%rbp),%rsi
  800420d425:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d429:	49 89 c8             	mov    %rcx,%r8
  800420d42c:	48 89 d1             	mov    %rdx,%rcx
  800420d42f:	ba 00 00 00 00       	mov    $0x0,%edx
  800420d434:	48 89 c7             	mov    %rax,%rdi
  800420d437:	48 b8 e4 ce 20 04 80 	movabs $0x800420cee4,%rax
  800420d43e:	00 00 00 
  800420d441:	ff d0                	callq  *%rax
  800420d443:	89 45 dc             	mov    %eax,-0x24(%rbp)
	p++;

	/*
	 * Process file list.
	 */
	while (*p != '\0') {
  800420d446:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d44d:	0f b6 00             	movzbl (%rax),%eax
  800420d450:	84 c0                	test   %al,%al
  800420d452:	75 b6                	jne    800420d40a <_dwarf_lineno_init+0x482>
		ret = _dwarf_lineno_add_file(li, &p, NULL, error, dbg);
		//p++;
	}

	p++;
  800420d454:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d45b:	48 83 c0 01          	add    $0x1,%rax
  800420d45f:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)
	/* Sanity check. */
	if (p - ds->ds_data - hdroff != li->li_hdrlen) {
  800420d466:	48 8b 85 28 ff ff ff 	mov    -0xd8(%rbp),%rax
  800420d46d:	48 89 c2             	mov    %rax,%rdx
  800420d470:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d474:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420d478:	48 29 c2             	sub    %rax,%rdx
  800420d47b:	48 89 d0             	mov    %rdx,%rax
  800420d47e:	48 2b 45 b0          	sub    -0x50(%rbp),%rax
  800420d482:	48 89 c2             	mov    %rax,%rdx
  800420d485:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  800420d489:	48 8b 40 10          	mov    0x10(%rax),%rax
  800420d48d:	48 39 c2             	cmp    %rax,%rdx
  800420d490:	74 09                	je     800420d49b <_dwarf_lineno_init+0x513>
		ret = DW_DLE_DEBUG_LINE_LENGTH_BAD;
  800420d492:	c7 45 dc 0f 00 00 00 	movl   $0xf,-0x24(%rbp)
		DWARF_SET_ERROR(dbg, error, ret);
		goto fail_cleanup;
  800420d499:	eb 54                	jmp    800420d4ef <_dwarf_lineno_init+0x567>
	}

	/*
	 * Process line number program.
	 */
	ret = _dwarf_lineno_run_program(cu, li, p, ds->ds_data + endoff, pc,
  800420d49b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d49f:	48 8b 50 08          	mov    0x8(%rax),%rdx
  800420d4a3:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420d4a7:	48 8d 0c 02          	lea    (%rdx,%rax,1),%rcx
  800420d4ab:	48 8b 95 28 ff ff ff 	mov    -0xd8(%rbp),%rdx
  800420d4b2:	4c 8b 85 f8 fe ff ff 	mov    -0x108(%rbp),%r8
  800420d4b9:	48 8b bd 00 ff ff ff 	mov    -0x100(%rbp),%rdi
  800420d4c0:	48 8b 75 c0          	mov    -0x40(%rbp),%rsi
  800420d4c4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420d4c8:	4d 89 c1             	mov    %r8,%r9
  800420d4cb:	49 89 f8             	mov    %rdi,%r8
  800420d4ce:	48 89 c7             	mov    %rax,%rdi
  800420d4d1:	48 b8 2c c9 20 04 80 	movabs $0x800420c92c,%rax
  800420d4d8:	00 00 00 
  800420d4db:	ff d0                	callq  *%rax
  800420d4dd:	89 45 dc             	mov    %eax,-0x24(%rbp)
					error);
	if (ret != DW_DLE_NONE)
  800420d4e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  800420d4e4:	74 02                	je     800420d4e8 <_dwarf_lineno_init+0x560>
		goto fail_cleanup;
  800420d4e6:	eb 07                	jmp    800420d4ef <_dwarf_lineno_init+0x567>

	//cu->cu_lineinfo = li;

	return (DW_DLE_NONE);
  800420d4e8:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d4ed:	eb 03                	jmp    800420d4f2 <_dwarf_lineno_init+0x56a>
fail_cleanup:

	/*if (li->li_oplen)
	  free(li->li_oplen);*/

	return (ret);
  800420d4ef:	8b 45 dc             	mov    -0x24(%rbp),%eax
}
  800420d4f2:	48 81 c4 08 01 00 00 	add    $0x108,%rsp
  800420d4f9:	5b                   	pop    %rbx
  800420d4fa:	5d                   	pop    %rbp
  800420d4fb:	c3                   	retq   

000000800420d4fc <dwarf_srclines>:

int
dwarf_srclines(Dwarf_Die *die, Dwarf_Line linebuf, Dwarf_Addr pc, Dwarf_Error *error)
{
  800420d4fc:	55                   	push   %rbp
  800420d4fd:	48 89 e5             	mov    %rsp,%rbp
  800420d500:	48 81 ec b0 00 00 00 	sub    $0xb0,%rsp
  800420d507:	48 89 bd 68 ff ff ff 	mov    %rdi,-0x98(%rbp)
  800420d50e:	48 89 b5 60 ff ff ff 	mov    %rsi,-0xa0(%rbp)
  800420d515:	48 89 95 58 ff ff ff 	mov    %rdx,-0xa8(%rbp)
  800420d51c:	48 89 8d 50 ff ff ff 	mov    %rcx,-0xb0(%rbp)
	_Dwarf_LineInfo li;
	Dwarf_Attribute *at;

	assert(die);
  800420d523:	48 83 bd 68 ff ff ff 	cmpq   $0x0,-0x98(%rbp)
  800420d52a:	00 
  800420d52b:	75 35                	jne    800420d562 <dwarf_srclines+0x66>
  800420d52d:	48 b9 7f ff 20 04 80 	movabs $0x800420ff7f,%rcx
  800420d534:	00 00 00 
  800420d537:	48 ba 47 ff 20 04 80 	movabs $0x800420ff47,%rdx
  800420d53e:	00 00 00 
  800420d541:	be 9a 01 00 00       	mov    $0x19a,%esi
  800420d546:	48 bf 5c ff 20 04 80 	movabs $0x800420ff5c,%rdi
  800420d54d:	00 00 00 
  800420d550:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d555:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420d55c:	00 00 00 
  800420d55f:	41 ff d0             	callq  *%r8
	assert(linebuf);
  800420d562:	48 83 bd 60 ff ff ff 	cmpq   $0x0,-0xa0(%rbp)
  800420d569:	00 
  800420d56a:	75 35                	jne    800420d5a1 <dwarf_srclines+0xa5>
  800420d56c:	48 b9 83 ff 20 04 80 	movabs $0x800420ff83,%rcx
  800420d573:	00 00 00 
  800420d576:	48 ba 47 ff 20 04 80 	movabs $0x800420ff47,%rdx
  800420d57d:	00 00 00 
  800420d580:	be 9b 01 00 00       	mov    $0x19b,%esi
  800420d585:	48 bf 5c ff 20 04 80 	movabs $0x800420ff5c,%rdi
  800420d58c:	00 00 00 
  800420d58f:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d594:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420d59b:	00 00 00 
  800420d59e:	41 ff d0             	callq  *%r8

	memset(&li, 0, sizeof(_Dwarf_LineInfo));
  800420d5a1:	48 8d 85 70 ff ff ff 	lea    -0x90(%rbp),%rax
  800420d5a8:	ba 88 00 00 00       	mov    $0x88,%edx
  800420d5ad:	be 00 00 00 00       	mov    $0x0,%esi
  800420d5b2:	48 89 c7             	mov    %rax,%rdi
  800420d5b5:	48 b8 a0 7f 20 04 80 	movabs $0x8004207fa0,%rax
  800420d5bc:	00 00 00 
  800420d5bf:	ff d0                	callq  *%rax

	if ((at = _dwarf_attr_find(die, DW_AT_stmt_list)) == NULL) {
  800420d5c1:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420d5c8:	be 10 00 00 00       	mov    $0x10,%esi
  800420d5cd:	48 89 c7             	mov    %rax,%rdi
  800420d5d0:	48 b8 d5 9e 20 04 80 	movabs $0x8004209ed5,%rax
  800420d5d7:	00 00 00 
  800420d5da:	ff d0                	callq  *%rax
  800420d5dc:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420d5e0:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
  800420d5e5:	75 0a                	jne    800420d5f1 <dwarf_srclines+0xf5>
		DWARF_SET_ERROR(dbg, error, DW_DLE_NO_ENTRY);
		return (DW_DLV_NO_ENTRY);
  800420d5e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800420d5ec:	e9 84 00 00 00       	jmpq   800420d675 <dwarf_srclines+0x179>
	}

	if (_dwarf_lineno_init(die, at->u[0].u64, &li, pc, error) !=
  800420d5f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420d5f5:	48 8b 70 28          	mov    0x28(%rax),%rsi
  800420d5f9:	48 8b bd 50 ff ff ff 	mov    -0xb0(%rbp),%rdi
  800420d600:	48 8b 8d 58 ff ff ff 	mov    -0xa8(%rbp),%rcx
  800420d607:	48 8d 95 70 ff ff ff 	lea    -0x90(%rbp),%rdx
  800420d60e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420d615:	49 89 f8             	mov    %rdi,%r8
  800420d618:	48 89 c7             	mov    %rax,%rdi
  800420d61b:	48 b8 88 cf 20 04 80 	movabs $0x800420cf88,%rax
  800420d622:	00 00 00 
  800420d625:	ff d0                	callq  *%rax
  800420d627:	85 c0                	test   %eax,%eax
  800420d629:	74 07                	je     800420d632 <dwarf_srclines+0x136>
	    DW_DLE_NONE)
	{
		return (DW_DLV_ERROR);
  800420d62b:	b8 01 00 00 00       	mov    $0x1,%eax
  800420d630:	eb 43                	jmp    800420d675 <dwarf_srclines+0x179>
	}
	*linebuf = li.li_line;
  800420d632:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  800420d639:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
  800420d63d:	48 89 10             	mov    %rdx,(%rax)
  800420d640:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800420d644:	48 89 50 08          	mov    %rdx,0x8(%rax)
  800420d648:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  800420d64c:	48 89 50 10          	mov    %rdx,0x10(%rax)
  800420d650:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
  800420d654:	48 89 50 18          	mov    %rdx,0x18(%rax)
  800420d658:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420d65c:	48 89 50 20          	mov    %rdx,0x20(%rax)
  800420d660:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420d664:	48 89 50 28          	mov    %rdx,0x28(%rax)
  800420d668:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420d66c:	48 89 50 30          	mov    %rdx,0x30(%rax)

	return (DW_DLV_OK);
  800420d670:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800420d675:	c9                   	leaveq 
  800420d676:	c3                   	retq   

000000800420d677 <_dwarf_find_section>:
uintptr_t
read_section_headers(uintptr_t, uintptr_t);

Dwarf_Section *
_dwarf_find_section(const char *name)
{
  800420d677:	55                   	push   %rbp
  800420d678:	48 89 e5             	mov    %rsp,%rbp
  800420d67b:	48 83 ec 20          	sub    $0x20,%rsp
  800420d67f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
	Dwarf_Section *ret=NULL;
  800420d683:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  800420d68a:	00 
	int i;

	for(i=0; i < NDEBUG_SECT; i++) {
  800420d68b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  800420d692:	eb 57                	jmp    800420d6eb <_dwarf_find_section+0x74>
		if(!strcmp(section_info[i].ds_name, name)) {
  800420d694:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d69b:	00 00 00 
  800420d69e:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420d6a1:	48 63 d2             	movslq %edx,%rdx
  800420d6a4:	48 c1 e2 05          	shl    $0x5,%rdx
  800420d6a8:	48 01 d0             	add    %rdx,%rax
  800420d6ab:	48 8b 00             	mov    (%rax),%rax
  800420d6ae:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420d6b2:	48 89 d6             	mov    %rdx,%rsi
  800420d6b5:	48 89 c7             	mov    %rax,%rdi
  800420d6b8:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d6bf:	00 00 00 
  800420d6c2:	ff d0                	callq  *%rax
  800420d6c4:	85 c0                	test   %eax,%eax
  800420d6c6:	75 1f                	jne    800420d6e7 <_dwarf_find_section+0x70>
			ret = (section_info + i);
  800420d6c8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420d6cb:	48 98                	cltq   
  800420d6cd:	48 c1 e0 05          	shl    $0x5,%rax
  800420d6d1:	48 89 c2             	mov    %rax,%rdx
  800420d6d4:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d6db:	00 00 00 
  800420d6de:	48 01 d0             	add    %rdx,%rax
  800420d6e1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
			break;
  800420d6e5:	eb 0a                	jmp    800420d6f1 <_dwarf_find_section+0x7a>
_dwarf_find_section(const char *name)
{
	Dwarf_Section *ret=NULL;
	int i;

	for(i=0; i < NDEBUG_SECT; i++) {
  800420d6e7:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  800420d6eb:	83 7d f4 04          	cmpl   $0x4,-0xc(%rbp)
  800420d6ef:	7e a3                	jle    800420d694 <_dwarf_find_section+0x1d>
			ret = (section_info + i);
			break;
		}
	}

	return ret;
  800420d6f1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  800420d6f5:	c9                   	leaveq 
  800420d6f6:	c3                   	retq   

000000800420d6f7 <find_debug_sections>:

void find_debug_sections(uintptr_t elf) 
{
  800420d6f7:	55                   	push   %rbp
  800420d6f8:	48 89 e5             	mov    %rsp,%rbp
  800420d6fb:	48 83 ec 40          	sub    $0x40,%rsp
  800420d6ff:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
	Elf *ehdr = (Elf *)elf;
  800420d703:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420d707:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
	uintptr_t debug_address = USTABDATA;
  800420d70b:	48 c7 45 f8 00 00 20 	movq   $0x200000,-0x8(%rbp)
  800420d712:	00 
	Secthdr *sh = (Secthdr *)(((uint8_t *)ehdr + ehdr->e_shoff));
  800420d713:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d717:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420d71b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d71f:	48 01 d0             	add    %rdx,%rax
  800420d722:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
	Secthdr *shstr_tab = sh + ehdr->e_shstrndx;
  800420d726:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d72a:	0f b7 40 3e          	movzwl 0x3e(%rax),%eax
  800420d72e:	0f b7 c0             	movzwl %ax,%eax
  800420d731:	48 c1 e0 06          	shl    $0x6,%rax
  800420d735:	48 89 c2             	mov    %rax,%rdx
  800420d738:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d73c:	48 01 d0             	add    %rdx,%rax
  800420d73f:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
	Secthdr* esh = sh + ehdr->e_shnum;
  800420d743:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d747:	0f b7 40 3c          	movzwl 0x3c(%rax),%eax
  800420d74b:	0f b7 c0             	movzwl %ax,%eax
  800420d74e:	48 c1 e0 06          	shl    $0x6,%rax
  800420d752:	48 89 c2             	mov    %rax,%rdx
  800420d755:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d759:	48 01 d0             	add    %rdx,%rax
  800420d75c:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	for(;sh < esh; sh++) {
  800420d760:	e9 4b 02 00 00       	jmpq   800420d9b0 <find_debug_sections+0x2b9>
		char* name = (char*)((uint8_t*)elf + shstr_tab->sh_offset) + sh->sh_name;
  800420d765:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d769:	8b 00                	mov    (%rax),%eax
  800420d76b:	89 c2                	mov    %eax,%edx
  800420d76d:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420d771:	48 8b 48 18          	mov    0x18(%rax),%rcx
  800420d775:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420d779:	48 01 c8             	add    %rcx,%rax
  800420d77c:	48 01 d0             	add    %rdx,%rax
  800420d77f:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
		if(!strcmp(name, ".debug_info")) {
  800420d783:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d787:	48 be 8b ff 20 04 80 	movabs $0x800420ff8b,%rsi
  800420d78e:	00 00 00 
  800420d791:	48 89 c7             	mov    %rax,%rdi
  800420d794:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d79b:	00 00 00 
  800420d79e:	ff d0                	callq  *%rax
  800420d7a0:	85 c0                	test   %eax,%eax
  800420d7a2:	75 4b                	jne    800420d7ef <find_debug_sections+0xf8>
			section_info[DEBUG_INFO].ds_data = (uint8_t*)debug_address;
  800420d7a4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d7a8:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d7af:	00 00 00 
  800420d7b2:	48 89 50 08          	mov    %rdx,0x8(%rax)
			section_info[DEBUG_INFO].ds_addr = debug_address;
  800420d7b6:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d7bd:	00 00 00 
  800420d7c0:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d7c4:	48 89 50 10          	mov    %rdx,0x10(%rax)
			section_info[DEBUG_INFO].ds_size = sh->sh_size;
  800420d7c8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d7cc:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d7d0:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d7d7:	00 00 00 
  800420d7da:	48 89 50 18          	mov    %rdx,0x18(%rax)
			debug_address += sh->sh_size;
  800420d7de:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d7e2:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420d7e6:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420d7ea:	e9 bc 01 00 00       	jmpq   800420d9ab <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_abbrev")) {
  800420d7ef:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d7f3:	48 be 97 ff 20 04 80 	movabs $0x800420ff97,%rsi
  800420d7fa:	00 00 00 
  800420d7fd:	48 89 c7             	mov    %rax,%rdi
  800420d800:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d807:	00 00 00 
  800420d80a:	ff d0                	callq  *%rax
  800420d80c:	85 c0                	test   %eax,%eax
  800420d80e:	75 4b                	jne    800420d85b <find_debug_sections+0x164>
			section_info[DEBUG_ABBREV].ds_data = (uint8_t*)debug_address;
  800420d810:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d814:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d81b:	00 00 00 
  800420d81e:	48 89 50 28          	mov    %rdx,0x28(%rax)
			section_info[DEBUG_ABBREV].ds_addr = debug_address;
  800420d822:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d829:	00 00 00 
  800420d82c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d830:	48 89 50 30          	mov    %rdx,0x30(%rax)
			section_info[DEBUG_ABBREV].ds_size = sh->sh_size;
  800420d834:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d838:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d83c:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d843:	00 00 00 
  800420d846:	48 89 50 38          	mov    %rdx,0x38(%rax)
			debug_address += sh->sh_size;
  800420d84a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d84e:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420d852:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420d856:	e9 50 01 00 00       	jmpq   800420d9ab <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_line")){
  800420d85b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d85f:	48 be af ff 20 04 80 	movabs $0x800420ffaf,%rsi
  800420d866:	00 00 00 
  800420d869:	48 89 c7             	mov    %rax,%rdi
  800420d86c:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d873:	00 00 00 
  800420d876:	ff d0                	callq  *%rax
  800420d878:	85 c0                	test   %eax,%eax
  800420d87a:	75 4b                	jne    800420d8c7 <find_debug_sections+0x1d0>
			section_info[DEBUG_LINE].ds_data = (uint8_t*)debug_address;
  800420d87c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d880:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d887:	00 00 00 
  800420d88a:	48 89 50 68          	mov    %rdx,0x68(%rax)
			section_info[DEBUG_LINE].ds_addr = debug_address;
  800420d88e:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d895:	00 00 00 
  800420d898:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d89c:	48 89 50 70          	mov    %rdx,0x70(%rax)
			section_info[DEBUG_LINE].ds_size = sh->sh_size;
  800420d8a0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d8a4:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d8a8:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d8af:	00 00 00 
  800420d8b2:	48 89 50 78          	mov    %rdx,0x78(%rax)
			debug_address += sh->sh_size;
  800420d8b6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d8ba:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420d8be:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420d8c2:	e9 e4 00 00 00       	jmpq   800420d9ab <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".eh_frame")){
  800420d8c7:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d8cb:	48 be a5 ff 20 04 80 	movabs $0x800420ffa5,%rsi
  800420d8d2:	00 00 00 
  800420d8d5:	48 89 c7             	mov    %rax,%rdi
  800420d8d8:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d8df:	00 00 00 
  800420d8e2:	ff d0                	callq  *%rax
  800420d8e4:	85 c0                	test   %eax,%eax
  800420d8e6:	75 53                	jne    800420d93b <find_debug_sections+0x244>
			section_info[DEBUG_FRAME].ds_data = (uint8_t*)sh->sh_addr;
  800420d8e8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d8ec:	48 8b 40 10          	mov    0x10(%rax),%rax
  800420d8f0:	48 89 c2             	mov    %rax,%rdx
  800420d8f3:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d8fa:	00 00 00 
  800420d8fd:	48 89 50 48          	mov    %rdx,0x48(%rax)
			section_info[DEBUG_FRAME].ds_addr = sh->sh_addr;
  800420d901:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d905:	48 8b 50 10          	mov    0x10(%rax),%rdx
  800420d909:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d910:	00 00 00 
  800420d913:	48 89 50 50          	mov    %rdx,0x50(%rax)
			section_info[DEBUG_FRAME].ds_size = sh->sh_size;
  800420d917:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d91b:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d91f:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d926:	00 00 00 
  800420d929:	48 89 50 58          	mov    %rdx,0x58(%rax)
			debug_address += sh->sh_size;
  800420d92d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d931:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420d935:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  800420d939:	eb 70                	jmp    800420d9ab <find_debug_sections+0x2b4>
		} else if(!strcmp(name, ".debug_str")) {
  800420d93b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420d93f:	48 be bb ff 20 04 80 	movabs $0x800420ffbb,%rsi
  800420d946:	00 00 00 
  800420d949:	48 89 c7             	mov    %rax,%rdi
  800420d94c:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420d953:	00 00 00 
  800420d956:	ff d0                	callq  *%rax
  800420d958:	85 c0                	test   %eax,%eax
  800420d95a:	75 4f                	jne    800420d9ab <find_debug_sections+0x2b4>
			section_info[DEBUG_STR].ds_data = (uint8_t*)debug_address;
  800420d95c:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d960:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d967:	00 00 00 
  800420d96a:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
			section_info[DEBUG_STR].ds_addr = debug_address;
  800420d971:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d978:	00 00 00 
  800420d97b:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420d97f:	48 89 90 90 00 00 00 	mov    %rdx,0x90(%rax)
			section_info[DEBUG_STR].ds_size = sh->sh_size;
  800420d986:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d98a:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420d98e:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420d995:	00 00 00 
  800420d998:	48 89 90 98 00 00 00 	mov    %rdx,0x98(%rax)
			debug_address += sh->sh_size;
  800420d99f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d9a3:	48 8b 40 20          	mov    0x20(%rax),%rax
  800420d9a7:	48 01 45 f8          	add    %rax,-0x8(%rbp)
	Elf *ehdr = (Elf *)elf;
	uintptr_t debug_address = USTABDATA;
	Secthdr *sh = (Secthdr *)(((uint8_t *)ehdr + ehdr->e_shoff));
	Secthdr *shstr_tab = sh + ehdr->e_shstrndx;
	Secthdr* esh = sh + ehdr->e_shnum;
	for(;sh < esh; sh++) {
  800420d9ab:	48 83 45 f0 40       	addq   $0x40,-0x10(%rbp)
  800420d9b0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  800420d9b4:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
  800420d9b8:	0f 82 a7 fd ff ff    	jb     800420d765 <find_debug_sections+0x6e>
			section_info[DEBUG_STR].ds_size = sh->sh_size;
			debug_address += sh->sh_size;
		}
	}

}
  800420d9be:	c9                   	leaveq 
  800420d9bf:	c3                   	retq   

000000800420d9c0 <read_section_headers>:

uint64_t
read_section_headers(uintptr_t elfhdr, uintptr_t to_va)
{
  800420d9c0:	55                   	push   %rbp
  800420d9c1:	48 89 e5             	mov    %rsp,%rbp
  800420d9c4:	48 81 ec 60 01 00 00 	sub    $0x160,%rsp
  800420d9cb:	48 89 bd a8 fe ff ff 	mov    %rdi,-0x158(%rbp)
  800420d9d2:	48 89 b5 a0 fe ff ff 	mov    %rsi,-0x160(%rbp)
	Secthdr* secthdr_ptr[20] = {0};
  800420d9d9:	48 8d b5 c0 fe ff ff 	lea    -0x140(%rbp),%rsi
  800420d9e0:	b8 00 00 00 00       	mov    $0x0,%eax
  800420d9e5:	ba 14 00 00 00       	mov    $0x14,%edx
  800420d9ea:	48 89 f7             	mov    %rsi,%rdi
  800420d9ed:	48 89 d1             	mov    %rdx,%rcx
  800420d9f0:	f3 48 ab             	rep stos %rax,%es:(%rdi)
	char* kvbase = ROUNDUP((char*)to_va, SECTSIZE);
  800420d9f3:	48 c7 45 e8 00 02 00 	movq   $0x200,-0x18(%rbp)
  800420d9fa:	00 
  800420d9fb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420d9ff:	48 8b 95 a0 fe ff ff 	mov    -0x160(%rbp),%rdx
  800420da06:	48 01 d0             	add    %rdx,%rax
  800420da09:	48 83 e8 01          	sub    $0x1,%rax
  800420da0d:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  800420da11:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420da15:	ba 00 00 00 00       	mov    $0x0,%edx
  800420da1a:	48 f7 75 e8          	divq   -0x18(%rbp)
  800420da1e:	48 89 d0             	mov    %rdx,%rax
  800420da21:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  800420da25:	48 29 c2             	sub    %rax,%rdx
  800420da28:	48 89 d0             	mov    %rdx,%rax
  800420da2b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
	uint64_t kvoffset = 0;
  800420da2f:	48 c7 85 b8 fe ff ff 	movq   $0x0,-0x148(%rbp)
  800420da36:	00 00 00 00 
	char *orig_secthdr = (char*)kvbase;
  800420da3a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420da3e:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
	char * secthdr = NULL;
  800420da42:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  800420da49:	00 
	uint64_t offset;
	if(elfhdr == KELFHDR)
  800420da4a:	48 b8 00 00 01 04 80 	movabs $0x8004010000,%rax
  800420da51:	00 00 00 
  800420da54:	48 39 85 a8 fe ff ff 	cmp    %rax,-0x158(%rbp)
  800420da5b:	75 11                	jne    800420da6e <read_section_headers+0xae>
		offset = ((Elf*)elfhdr)->e_shoff;
  800420da5d:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420da64:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420da68:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  800420da6c:	eb 26                	jmp    800420da94 <read_section_headers+0xd4>
	else
		offset = ((Elf*)elfhdr)->e_shoff + (elfhdr - KERNBASE);
  800420da6e:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420da75:	48 8b 50 28          	mov    0x28(%rax),%rdx
  800420da79:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420da80:	48 01 c2             	add    %rax,%rdx
  800420da83:	48 b8 00 00 00 fc 7f 	movabs $0xffffff7ffc000000,%rax
  800420da8a:	ff ff ff 
  800420da8d:	48 01 d0             	add    %rdx,%rax
  800420da90:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	int numSectionHeaders = ((Elf*)elfhdr)->e_shnum;
  800420da94:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420da9b:	0f b7 40 3c          	movzwl 0x3c(%rax),%eax
  800420da9f:	0f b7 c0             	movzwl %ax,%eax
  800420daa2:	89 45 c4             	mov    %eax,-0x3c(%rbp)
	int sizeSections = ((Elf*)elfhdr)->e_shentsize;
  800420daa5:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420daac:	0f b7 40 3a          	movzwl 0x3a(%rax),%eax
  800420dab0:	0f b7 c0             	movzwl %ax,%eax
  800420dab3:	89 45 c0             	mov    %eax,-0x40(%rbp)
	char *nametab;
	int i;
	uint64_t temp;
	char *name;

	Elf *ehdr = (Elf *)elfhdr;
  800420dab6:	48 8b 85 a8 fe ff ff 	mov    -0x158(%rbp),%rax
  800420dabd:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
	Secthdr *sec_name;  

	readseg((uint64_t)orig_secthdr , numSectionHeaders * sizeSections,
  800420dac1:	8b 45 c4             	mov    -0x3c(%rbp),%eax
  800420dac4:	0f af 45 c0          	imul   -0x40(%rbp),%eax
  800420dac8:	48 63 f0             	movslq %eax,%rsi
  800420dacb:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420dacf:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420dad6:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  800420dada:	48 89 c7             	mov    %rax,%rdi
  800420dadd:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420dae4:	00 00 00 
  800420dae7:	ff d0                	callq  *%rax
		offset, &kvoffset);
	secthdr = (char*)orig_secthdr + (offset - ROUNDDOWN(offset, SECTSIZE));
  800420dae9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420daed:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  800420daf1:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
  800420daf5:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420dafb:	48 89 c2             	mov    %rax,%rdx
  800420dafe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420db02:	48 29 d0             	sub    %rdx,%rax
  800420db05:	48 89 c2             	mov    %rax,%rdx
  800420db08:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420db0c:	48 01 d0             	add    %rdx,%rax
  800420db0f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
	for (i = 0; i < numSectionHeaders; i++)
  800420db13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  800420db1a:	eb 24                	jmp    800420db40 <read_section_headers+0x180>
	{
		secthdr_ptr[i] = (Secthdr*)(secthdr) + i;
  800420db1c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420db1f:	48 98                	cltq   
  800420db21:	48 c1 e0 06          	shl    $0x6,%rax
  800420db25:	48 89 c2             	mov    %rax,%rdx
  800420db28:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  800420db2c:	48 01 c2             	add    %rax,%rdx
  800420db2f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420db32:	48 98                	cltq   
  800420db34:	48 89 94 c5 c0 fe ff 	mov    %rdx,-0x140(%rbp,%rax,8)
  800420db3b:	ff 
	Secthdr *sec_name;  

	readseg((uint64_t)orig_secthdr , numSectionHeaders * sizeSections,
		offset, &kvoffset);
	secthdr = (char*)orig_secthdr + (offset - ROUNDDOWN(offset, SECTSIZE));
	for (i = 0; i < numSectionHeaders; i++)
  800420db3c:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  800420db40:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420db43:	3b 45 c4             	cmp    -0x3c(%rbp),%eax
  800420db46:	7c d4                	jl     800420db1c <read_section_headers+0x15c>
	{
		secthdr_ptr[i] = (Secthdr*)(secthdr) + i;
	}
	
	sec_name = secthdr_ptr[ehdr->e_shstrndx]; 
  800420db48:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  800420db4c:	0f b7 40 3e          	movzwl 0x3e(%rax),%eax
  800420db50:	0f b7 c0             	movzwl %ax,%eax
  800420db53:	48 98                	cltq   
  800420db55:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420db5c:	ff 
  800420db5d:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
	temp = kvoffset;
  800420db61:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  800420db68:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
	readseg((uint64_t)((char *)kvbase + kvoffset), sec_name->sh_size,
  800420db6c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420db70:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420db74:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420db78:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420db7c:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  800420db83:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420db87:	48 01 c8             	add    %rcx,%rax
  800420db8a:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420db91:	48 89 c7             	mov    %rax,%rdi
  800420db94:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420db9b:	00 00 00 
  800420db9e:	ff d0                	callq  *%rax
		sec_name->sh_offset, &kvoffset);
	nametab = (char *)((char *)kvbase + temp) + OFFSET_CORRECT(sec_name->sh_offset);	
  800420dba0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420dba4:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420dba8:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420dbac:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420dbb0:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  800420dbb4:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  800420dbb8:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420dbbe:	48 29 c2             	sub    %rax,%rdx
  800420dbc1:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420dbc5:	48 01 c2             	add    %rax,%rdx
  800420dbc8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420dbcc:	48 01 d0             	add    %rdx,%rax
  800420dbcf:	48 89 45 90          	mov    %rax,-0x70(%rbp)

	for (i = 0; i < numSectionHeaders; i++)
  800420dbd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
  800420dbda:	e9 04 05 00 00       	jmpq   800420e0e3 <read_section_headers+0x723>
	{
		name = (char *)(nametab + secthdr_ptr[i]->sh_name);
  800420dbdf:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dbe2:	48 98                	cltq   
  800420dbe4:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dbeb:	ff 
  800420dbec:	8b 00                	mov    (%rax),%eax
  800420dbee:	89 c2                	mov    %eax,%edx
  800420dbf0:	48 8b 45 90          	mov    -0x70(%rbp),%rax
  800420dbf4:	48 01 d0             	add    %rdx,%rax
  800420dbf7:	48 89 45 88          	mov    %rax,-0x78(%rbp)
		assert(kvoffset % SECTSIZE == 0);
  800420dbfb:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  800420dc02:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420dc07:	48 85 c0             	test   %rax,%rax
  800420dc0a:	74 35                	je     800420dc41 <read_section_headers+0x281>
  800420dc0c:	48 b9 c6 ff 20 04 80 	movabs $0x800420ffc6,%rcx
  800420dc13:	00 00 00 
  800420dc16:	48 ba df ff 20 04 80 	movabs $0x800420ffdf,%rdx
  800420dc1d:	00 00 00 
  800420dc20:	be 86 00 00 00       	mov    $0x86,%esi
  800420dc25:	48 bf f4 ff 20 04 80 	movabs $0x800420fff4,%rdi
  800420dc2c:	00 00 00 
  800420dc2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800420dc34:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420dc3b:	00 00 00 
  800420dc3e:	41 ff d0             	callq  *%r8
		temp = kvoffset;
  800420dc41:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  800420dc48:	48 89 45 a0          	mov    %rax,-0x60(%rbp)
#ifdef DWARF_DEBUG
		cprintf("SectName: %s\n", name);
#endif
		if(!strcmp(name, ".debug_info"))
  800420dc4c:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420dc50:	48 be 8b ff 20 04 80 	movabs $0x800420ff8b,%rsi
  800420dc57:	00 00 00 
  800420dc5a:	48 89 c7             	mov    %rax,%rdi
  800420dc5d:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420dc64:	00 00 00 
  800420dc67:	ff d0                	callq  *%rax
  800420dc69:	85 c0                	test   %eax,%eax
  800420dc6b:	0f 85 d8 00 00 00    	jne    800420dd49 <read_section_headers+0x389>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  800420dc71:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dc74:	48 98                	cltq   
  800420dc76:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dc7d:	ff 
#ifdef DWARF_DEBUG
		cprintf("SectName: %s\n", name);
#endif
		if(!strcmp(name, ".debug_info"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  800420dc7e:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420dc82:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dc85:	48 98                	cltq   
  800420dc87:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dc8e:	ff 
  800420dc8f:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420dc93:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  800420dc9a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420dc9e:	48 01 c8             	add    %rcx,%rax
  800420dca1:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420dca8:	48 89 c7             	mov    %rax,%rdi
  800420dcab:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420dcb2:	00 00 00 
  800420dcb5:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_INFO].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  800420dcb7:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dcba:	48 98                	cltq   
  800420dcbc:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dcc3:	ff 
  800420dcc4:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420dcc8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dccb:	48 98                	cltq   
  800420dccd:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dcd4:	ff 
  800420dcd5:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420dcd9:	48 89 45 80          	mov    %rax,-0x80(%rbp)
  800420dcdd:	48 8b 45 80          	mov    -0x80(%rbp),%rax
  800420dce1:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420dce7:	48 29 c2             	sub    %rax,%rdx
  800420dcea:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420dcee:	48 01 c2             	add    %rax,%rdx
  800420dcf1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420dcf5:	48 01 c2             	add    %rax,%rdx
  800420dcf8:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dcff:	00 00 00 
  800420dd02:	48 89 50 08          	mov    %rdx,0x8(%rax)
			section_info[DEBUG_INFO].ds_addr = (uintptr_t)section_info[DEBUG_INFO].ds_data;
  800420dd06:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dd0d:	00 00 00 
  800420dd10:	48 8b 40 08          	mov    0x8(%rax),%rax
  800420dd14:	48 89 c2             	mov    %rax,%rdx
  800420dd17:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dd1e:	00 00 00 
  800420dd21:	48 89 50 10          	mov    %rdx,0x10(%rax)
			section_info[DEBUG_INFO].ds_size = secthdr_ptr[i]->sh_size;
  800420dd25:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dd28:	48 98                	cltq   
  800420dd2a:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dd31:	ff 
  800420dd32:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420dd36:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dd3d:	00 00 00 
  800420dd40:	48 89 50 18          	mov    %rdx,0x18(%rax)
  800420dd44:	e9 96 03 00 00       	jmpq   800420e0df <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_abbrev"))
  800420dd49:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420dd4d:	48 be 97 ff 20 04 80 	movabs $0x800420ff97,%rsi
  800420dd54:	00 00 00 
  800420dd57:	48 89 c7             	mov    %rax,%rdi
  800420dd5a:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420dd61:	00 00 00 
  800420dd64:	ff d0                	callq  *%rax
  800420dd66:	85 c0                	test   %eax,%eax
  800420dd68:	0f 85 de 00 00 00    	jne    800420de4c <read_section_headers+0x48c>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  800420dd6e:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dd71:	48 98                	cltq   
  800420dd73:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dd7a:	ff 
			section_info[DEBUG_INFO].ds_addr = (uintptr_t)section_info[DEBUG_INFO].ds_data;
			section_info[DEBUG_INFO].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_abbrev"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  800420dd7b:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420dd7f:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dd82:	48 98                	cltq   
  800420dd84:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dd8b:	ff 
  800420dd8c:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420dd90:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  800420dd97:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420dd9b:	48 01 c8             	add    %rcx,%rax
  800420dd9e:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420dda5:	48 89 c7             	mov    %rax,%rdi
  800420dda8:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420ddaf:	00 00 00 
  800420ddb2:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_ABBREV].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  800420ddb4:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420ddb7:	48 98                	cltq   
  800420ddb9:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420ddc0:	ff 
  800420ddc1:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420ddc5:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420ddc8:	48 98                	cltq   
  800420ddca:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420ddd1:	ff 
  800420ddd2:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420ddd6:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  800420dddd:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  800420dde4:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420ddea:	48 29 c2             	sub    %rax,%rdx
  800420dded:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420ddf1:	48 01 c2             	add    %rax,%rdx
  800420ddf4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420ddf8:	48 01 c2             	add    %rax,%rdx
  800420ddfb:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420de02:	00 00 00 
  800420de05:	48 89 50 28          	mov    %rdx,0x28(%rax)
			section_info[DEBUG_ABBREV].ds_addr = (uintptr_t)section_info[DEBUG_ABBREV].ds_data;
  800420de09:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420de10:	00 00 00 
  800420de13:	48 8b 40 28          	mov    0x28(%rax),%rax
  800420de17:	48 89 c2             	mov    %rax,%rdx
  800420de1a:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420de21:	00 00 00 
  800420de24:	48 89 50 30          	mov    %rdx,0x30(%rax)
			section_info[DEBUG_ABBREV].ds_size = secthdr_ptr[i]->sh_size;
  800420de28:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420de2b:	48 98                	cltq   
  800420de2d:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420de34:	ff 
  800420de35:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420de39:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420de40:	00 00 00 
  800420de43:	48 89 50 38          	mov    %rdx,0x38(%rax)
  800420de47:	e9 93 02 00 00       	jmpq   800420e0df <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_line"))
  800420de4c:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420de50:	48 be af ff 20 04 80 	movabs $0x800420ffaf,%rsi
  800420de57:	00 00 00 
  800420de5a:	48 89 c7             	mov    %rax,%rdi
  800420de5d:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420de64:	00 00 00 
  800420de67:	ff d0                	callq  *%rax
  800420de69:	85 c0                	test   %eax,%eax
  800420de6b:	0f 85 de 00 00 00    	jne    800420df4f <read_section_headers+0x58f>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  800420de71:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420de74:	48 98                	cltq   
  800420de76:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420de7d:	ff 
			section_info[DEBUG_ABBREV].ds_addr = (uintptr_t)section_info[DEBUG_ABBREV].ds_data;
			section_info[DEBUG_ABBREV].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_line"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  800420de7e:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420de82:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420de85:	48 98                	cltq   
  800420de87:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420de8e:	ff 
  800420de8f:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420de93:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  800420de9a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420de9e:	48 01 c8             	add    %rcx,%rax
  800420dea1:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420dea8:	48 89 c7             	mov    %rax,%rdi
  800420deab:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420deb2:	00 00 00 
  800420deb5:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_LINE].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  800420deb7:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420deba:	48 98                	cltq   
  800420debc:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dec3:	ff 
  800420dec4:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420dec8:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420decb:	48 98                	cltq   
  800420decd:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420ded4:	ff 
  800420ded5:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420ded9:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  800420dee0:	48 8b 85 70 ff ff ff 	mov    -0x90(%rbp),%rax
  800420dee7:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420deed:	48 29 c2             	sub    %rax,%rdx
  800420def0:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420def4:	48 01 c2             	add    %rax,%rdx
  800420def7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420defb:	48 01 c2             	add    %rax,%rdx
  800420defe:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df05:	00 00 00 
  800420df08:	48 89 50 68          	mov    %rdx,0x68(%rax)
			section_info[DEBUG_LINE].ds_addr = (uintptr_t)section_info[DEBUG_LINE].ds_data;
  800420df0c:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df13:	00 00 00 
  800420df16:	48 8b 40 68          	mov    0x68(%rax),%rax
  800420df1a:	48 89 c2             	mov    %rax,%rdx
  800420df1d:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df24:	00 00 00 
  800420df27:	48 89 50 70          	mov    %rdx,0x70(%rax)
			section_info[DEBUG_LINE].ds_size = secthdr_ptr[i]->sh_size;
  800420df2b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420df2e:	48 98                	cltq   
  800420df30:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420df37:	ff 
  800420df38:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420df3c:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df43:	00 00 00 
  800420df46:	48 89 50 78          	mov    %rdx,0x78(%rax)
  800420df4a:	e9 90 01 00 00       	jmpq   800420e0df <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".eh_frame"))
  800420df4f:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420df53:	48 be a5 ff 20 04 80 	movabs $0x800420ffa5,%rsi
  800420df5a:	00 00 00 
  800420df5d:	48 89 c7             	mov    %rax,%rdi
  800420df60:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420df67:	00 00 00 
  800420df6a:	ff d0                	callq  *%rax
  800420df6c:	85 c0                	test   %eax,%eax
  800420df6e:	75 65                	jne    800420dfd5 <read_section_headers+0x615>
		{
			section_info[DEBUG_FRAME].ds_data = (uint8_t *)secthdr_ptr[i]->sh_addr;
  800420df70:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420df73:	48 98                	cltq   
  800420df75:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420df7c:	ff 
  800420df7d:	48 8b 40 10          	mov    0x10(%rax),%rax
  800420df81:	48 89 c2             	mov    %rax,%rdx
  800420df84:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df8b:	00 00 00 
  800420df8e:	48 89 50 48          	mov    %rdx,0x48(%rax)
			section_info[DEBUG_FRAME].ds_addr = (uintptr_t)section_info[DEBUG_FRAME].ds_data;
  800420df92:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420df99:	00 00 00 
  800420df9c:	48 8b 40 48          	mov    0x48(%rax),%rax
  800420dfa0:	48 89 c2             	mov    %rax,%rdx
  800420dfa3:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dfaa:	00 00 00 
  800420dfad:	48 89 50 50          	mov    %rdx,0x50(%rax)
			section_info[DEBUG_FRAME].ds_size = secthdr_ptr[i]->sh_size;
  800420dfb1:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dfb4:	48 98                	cltq   
  800420dfb6:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420dfbd:	ff 
  800420dfbe:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420dfc2:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420dfc9:	00 00 00 
  800420dfcc:	48 89 50 58          	mov    %rdx,0x58(%rax)
  800420dfd0:	e9 0a 01 00 00       	jmpq   800420e0df <read_section_headers+0x71f>
		}
		else if(!strcmp(name, ".debug_str"))
  800420dfd5:	48 8b 45 88          	mov    -0x78(%rbp),%rax
  800420dfd9:	48 be bb ff 20 04 80 	movabs $0x800420ffbb,%rsi
  800420dfe0:	00 00 00 
  800420dfe3:	48 89 c7             	mov    %rax,%rdi
  800420dfe6:	48 b8 69 7e 20 04 80 	movabs $0x8004207e69,%rax
  800420dfed:	00 00 00 
  800420dff0:	ff d0                	callq  *%rax
  800420dff2:	85 c0                	test   %eax,%eax
  800420dff4:	0f 85 e5 00 00 00    	jne    800420e0df <read_section_headers+0x71f>
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
				secthdr_ptr[i]->sh_offset, &kvoffset);	
  800420dffa:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420dffd:	48 98                	cltq   
  800420dfff:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420e006:	ff 
			section_info[DEBUG_FRAME].ds_addr = (uintptr_t)section_info[DEBUG_FRAME].ds_data;
			section_info[DEBUG_FRAME].ds_size = secthdr_ptr[i]->sh_size;
		}
		else if(!strcmp(name, ".debug_str"))
		{
			readseg((uint64_t)((char *)kvbase + kvoffset), secthdr_ptr[i]->sh_size, 
  800420e007:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420e00b:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420e00e:	48 98                	cltq   
  800420e010:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420e017:	ff 
  800420e018:	48 8b 70 20          	mov    0x20(%rax),%rsi
  800420e01c:	48 8b 8d b8 fe ff ff 	mov    -0x148(%rbp),%rcx
  800420e023:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420e027:	48 01 c8             	add    %rcx,%rax
  800420e02a:	48 8d 8d b8 fe ff ff 	lea    -0x148(%rbp),%rcx
  800420e031:	48 89 c7             	mov    %rax,%rdi
  800420e034:	48 b8 ff e0 20 04 80 	movabs $0x800420e0ff,%rax
  800420e03b:	00 00 00 
  800420e03e:	ff d0                	callq  *%rax
				secthdr_ptr[i]->sh_offset, &kvoffset);	
			section_info[DEBUG_STR].ds_data = (uint8_t *)((char *)kvbase + temp) + OFFSET_CORRECT(secthdr_ptr[i]->sh_offset);
  800420e040:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420e043:	48 98                	cltq   
  800420e045:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420e04c:	ff 
  800420e04d:	48 8b 50 18          	mov    0x18(%rax),%rdx
  800420e051:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420e054:	48 98                	cltq   
  800420e056:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420e05d:	ff 
  800420e05e:	48 8b 40 18          	mov    0x18(%rax),%rax
  800420e062:	48 89 85 68 ff ff ff 	mov    %rax,-0x98(%rbp)
  800420e069:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  800420e070:	48 25 00 fe ff ff    	and    $0xfffffffffffffe00,%rax
  800420e076:	48 29 c2             	sub    %rax,%rdx
  800420e079:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420e07d:	48 01 c2             	add    %rax,%rdx
  800420e080:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420e084:	48 01 c2             	add    %rax,%rdx
  800420e087:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420e08e:	00 00 00 
  800420e091:	48 89 90 88 00 00 00 	mov    %rdx,0x88(%rax)
			section_info[DEBUG_STR].ds_addr = (uintptr_t)section_info[DEBUG_STR].ds_data;
  800420e098:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420e09f:	00 00 00 
  800420e0a2:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
  800420e0a9:	48 89 c2             	mov    %rax,%rdx
  800420e0ac:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420e0b3:	00 00 00 
  800420e0b6:	48 89 90 90 00 00 00 	mov    %rdx,0x90(%rax)
			section_info[DEBUG_STR].ds_size = secthdr_ptr[i]->sh_size;
  800420e0bd:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420e0c0:	48 98                	cltq   
  800420e0c2:	48 8b 84 c5 c0 fe ff 	mov    -0x140(%rbp,%rax,8),%rax
  800420e0c9:	ff 
  800420e0ca:	48 8b 50 20          	mov    0x20(%rax),%rdx
  800420e0ce:	48 b8 00 26 22 04 80 	movabs $0x8004222600,%rax
  800420e0d5:	00 00 00 
  800420e0d8:	48 89 90 98 00 00 00 	mov    %rdx,0x98(%rax)
	temp = kvoffset;
	readseg((uint64_t)((char *)kvbase + kvoffset), sec_name->sh_size,
		sec_name->sh_offset, &kvoffset);
	nametab = (char *)((char *)kvbase + temp) + OFFSET_CORRECT(sec_name->sh_offset);	

	for (i = 0; i < numSectionHeaders; i++)
  800420e0df:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
  800420e0e3:	8b 45 f4             	mov    -0xc(%rbp),%eax
  800420e0e6:	3b 45 c4             	cmp    -0x3c(%rbp),%eax
  800420e0e9:	0f 8c f0 fa ff ff    	jl     800420dbdf <read_section_headers+0x21f>
			section_info[DEBUG_STR].ds_addr = (uintptr_t)section_info[DEBUG_STR].ds_data;
			section_info[DEBUG_STR].ds_size = secthdr_ptr[i]->sh_size;
		}
	}
	
	return ((uintptr_t)kvbase + kvoffset);
  800420e0ef:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420e0f3:	48 8b 85 b8 fe ff ff 	mov    -0x148(%rbp),%rax
  800420e0fa:	48 01 d0             	add    %rdx,%rax
}
  800420e0fd:	c9                   	leaveq 
  800420e0fe:	c3                   	retq   

000000800420e0ff <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint64_t pa, uint64_t count, uint64_t offset, uint64_t* kvoffset)
{
  800420e0ff:	55                   	push   %rbp
  800420e100:	48 89 e5             	mov    %rsp,%rbp
  800420e103:	48 83 ec 30          	sub    $0x30,%rsp
  800420e107:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  800420e10b:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  800420e10f:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  800420e113:	48 89 4d d0          	mov    %rcx,-0x30(%rbp)
	uint64_t end_pa;
	uint64_t orgoff = offset;
  800420e117:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420e11b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)

	end_pa = pa + count;
  800420e11f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420e123:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
  800420e127:	48 01 d0             	add    %rdx,%rax
  800420e12a:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

	assert(pa % SECTSIZE == 0);	
  800420e12e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420e132:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420e137:	48 85 c0             	test   %rax,%rax
  800420e13a:	74 35                	je     800420e171 <readseg+0x72>
  800420e13c:	48 b9 02 00 21 04 80 	movabs $0x8004210002,%rcx
  800420e143:	00 00 00 
  800420e146:	48 ba df ff 20 04 80 	movabs $0x800420ffdf,%rdx
  800420e14d:	00 00 00 
  800420e150:	be c0 00 00 00       	mov    $0xc0,%esi
  800420e155:	48 bf f4 ff 20 04 80 	movabs $0x800420fff4,%rdi
  800420e15c:	00 00 00 
  800420e15f:	b8 00 00 00 00       	mov    $0x0,%eax
  800420e164:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420e16b:	00 00 00 
  800420e16e:	41 ff d0             	callq  *%r8
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
  800420e171:	48 81 65 e8 00 fe ff 	andq   $0xfffffffffffffe00,-0x18(%rbp)
  800420e178:	ff 

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
  800420e179:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  800420e17d:	48 c1 e8 09          	shr    $0x9,%rax
  800420e181:	48 83 c0 01          	add    $0x1,%rax
  800420e185:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
  800420e189:	eb 3c                	jmp    800420e1c7 <readseg+0xc8>
		readsect((uint8_t*) pa, offset);
  800420e18b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420e18f:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420e193:	48 89 d6             	mov    %rdx,%rsi
  800420e196:	48 89 c7             	mov    %rax,%rdi
  800420e199:	48 b8 8f e2 20 04 80 	movabs $0x800420e28f,%rax
  800420e1a0:	00 00 00 
  800420e1a3:	ff d0                	callq  *%rax
		pa += SECTSIZE;
  800420e1a5:	48 81 45 e8 00 02 00 	addq   $0x200,-0x18(%rbp)
  800420e1ac:	00 
		*kvoffset += SECTSIZE;
  800420e1ad:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420e1b1:	48 8b 00             	mov    (%rax),%rax
  800420e1b4:	48 8d 90 00 02 00 00 	lea    0x200(%rax),%rdx
  800420e1bb:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420e1bf:	48 89 10             	mov    %rdx,(%rax)
		offset++;
  800420e1c2:	48 83 45 d8 01       	addq   $0x1,-0x28(%rbp)
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
  800420e1c7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420e1cb:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  800420e1cf:	72 ba                	jb     800420e18b <readseg+0x8c>
		pa += SECTSIZE;
		*kvoffset += SECTSIZE;
		offset++;
	}

	if(((orgoff % SECTSIZE) + count) > SECTSIZE)
  800420e1d1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  800420e1d5:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420e1da:	48 89 c2             	mov    %rax,%rdx
  800420e1dd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800420e1e1:	48 01 d0             	add    %rdx,%rax
  800420e1e4:	48 3d 00 02 00 00    	cmp    $0x200,%rax
  800420e1ea:	76 2f                	jbe    800420e21b <readseg+0x11c>
	{
		readsect((uint8_t*) pa, offset);
  800420e1ec:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  800420e1f0:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
  800420e1f4:	48 89 d6             	mov    %rdx,%rsi
  800420e1f7:	48 89 c7             	mov    %rax,%rdi
  800420e1fa:	48 b8 8f e2 20 04 80 	movabs $0x800420e28f,%rax
  800420e201:	00 00 00 
  800420e204:	ff d0                	callq  *%rax
		*kvoffset += SECTSIZE;
  800420e206:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420e20a:	48 8b 00             	mov    (%rax),%rax
  800420e20d:	48 8d 90 00 02 00 00 	lea    0x200(%rax),%rdx
  800420e214:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420e218:	48 89 10             	mov    %rdx,(%rax)
	}
	assert(*kvoffset % SECTSIZE == 0);
  800420e21b:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  800420e21f:	48 8b 00             	mov    (%rax),%rax
  800420e222:	25 ff 01 00 00       	and    $0x1ff,%eax
  800420e227:	48 85 c0             	test   %rax,%rax
  800420e22a:	74 35                	je     800420e261 <readseg+0x162>
  800420e22c:	48 b9 15 00 21 04 80 	movabs $0x8004210015,%rcx
  800420e233:	00 00 00 
  800420e236:	48 ba df ff 20 04 80 	movabs $0x800420ffdf,%rdx
  800420e23d:	00 00 00 
  800420e240:	be d6 00 00 00       	mov    $0xd6,%esi
  800420e245:	48 bf f4 ff 20 04 80 	movabs $0x800420fff4,%rdi
  800420e24c:	00 00 00 
  800420e24f:	b8 00 00 00 00       	mov    $0x0,%eax
  800420e254:	49 b8 14 01 20 04 80 	movabs $0x8004200114,%r8
  800420e25b:	00 00 00 
  800420e25e:	41 ff d0             	callq  *%r8
}
  800420e261:	c9                   	leaveq 
  800420e262:	c3                   	retq   

000000800420e263 <waitdisk>:

void
waitdisk(void)
{
  800420e263:	55                   	push   %rbp
  800420e264:	48 89 e5             	mov    %rsp,%rbp
  800420e267:	48 83 ec 10          	sub    $0x10,%rsp
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
  800420e26b:	90                   	nop
  800420e26c:	c7 45 fc f7 01 00 00 	movl   $0x1f7,-0x4(%rbp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800420e273:	8b 45 fc             	mov    -0x4(%rbp),%eax
  800420e276:	89 c2                	mov    %eax,%edx
  800420e278:	ec                   	in     (%dx),%al
  800420e279:	88 45 fb             	mov    %al,-0x5(%rbp)
	return data;
  800420e27c:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  800420e280:	0f b6 c0             	movzbl %al,%eax
  800420e283:	25 c0 00 00 00       	and    $0xc0,%eax
  800420e288:	83 f8 40             	cmp    $0x40,%eax
  800420e28b:	75 df                	jne    800420e26c <waitdisk+0x9>
		/* do nothing */;
}
  800420e28d:	c9                   	leaveq 
  800420e28e:	c3                   	retq   

000000800420e28f <readsect>:

void
readsect(void *dst, uint64_t offset)
{
  800420e28f:	55                   	push   %rbp
  800420e290:	48 89 e5             	mov    %rsp,%rbp
  800420e293:	48 83 ec 60          	sub    $0x60,%rsp
  800420e297:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  800420e29b:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
	// wait for disk to be ready
	waitdisk();
  800420e29f:	48 b8 63 e2 20 04 80 	movabs $0x800420e263,%rax
  800420e2a6:	00 00 00 
  800420e2a9:	ff d0                	callq  *%rax
  800420e2ab:	c7 45 fc f2 01 00 00 	movl   $0x1f2,-0x4(%rbp)
  800420e2b2:	c6 45 fb 01          	movb   $0x1,-0x5(%rbp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800420e2b6:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
  800420e2ba:	8b 55 fc             	mov    -0x4(%rbp),%edx
  800420e2bd:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
  800420e2be:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420e2c2:	0f b6 c0             	movzbl %al,%eax
  800420e2c5:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%rbp)
  800420e2cc:	88 45 f3             	mov    %al,-0xd(%rbp)
  800420e2cf:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
  800420e2d3:	8b 55 f4             	mov    -0xc(%rbp),%edx
  800420e2d6:	ee                   	out    %al,(%dx)
	outb(0x1F4, offset >> 8);
  800420e2d7:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420e2db:	48 c1 e8 08          	shr    $0x8,%rax
  800420e2df:	0f b6 c0             	movzbl %al,%eax
  800420e2e2:	c7 45 ec f4 01 00 00 	movl   $0x1f4,-0x14(%rbp)
  800420e2e9:	88 45 eb             	mov    %al,-0x15(%rbp)
  800420e2ec:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
  800420e2f0:	8b 55 ec             	mov    -0x14(%rbp),%edx
  800420e2f3:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
  800420e2f4:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420e2f8:	48 c1 e8 10          	shr    $0x10,%rax
  800420e2fc:	0f b6 c0             	movzbl %al,%eax
  800420e2ff:	c7 45 e4 f5 01 00 00 	movl   $0x1f5,-0x1c(%rbp)
  800420e306:	88 45 e3             	mov    %al,-0x1d(%rbp)
  800420e309:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
  800420e30d:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  800420e310:	ee                   	out    %al,(%dx)
	outb(0x1F6, (offset >> 24) | 0xE0);
  800420e311:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
  800420e315:	48 c1 e8 18          	shr    $0x18,%rax
  800420e319:	83 c8 e0             	or     $0xffffffe0,%eax
  800420e31c:	0f b6 c0             	movzbl %al,%eax
  800420e31f:	c7 45 dc f6 01 00 00 	movl   $0x1f6,-0x24(%rbp)
  800420e326:	88 45 db             	mov    %al,-0x25(%rbp)
  800420e329:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
  800420e32d:	8b 55 dc             	mov    -0x24(%rbp),%edx
  800420e330:	ee                   	out    %al,(%dx)
  800420e331:	c7 45 d4 f7 01 00 00 	movl   $0x1f7,-0x2c(%rbp)
  800420e338:	c6 45 d3 20          	movb   $0x20,-0x2d(%rbp)
  800420e33c:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
  800420e340:	8b 55 d4             	mov    -0x2c(%rbp),%edx
  800420e343:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
  800420e344:	48 b8 63 e2 20 04 80 	movabs $0x800420e263,%rax
  800420e34b:	00 00 00 
  800420e34e:	ff d0                	callq  *%rax
  800420e350:	c7 45 cc f0 01 00 00 	movl   $0x1f0,-0x34(%rbp)
  800420e357:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  800420e35b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800420e35f:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%rbp)
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800420e366:	8b 55 cc             	mov    -0x34(%rbp),%edx
  800420e369:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  800420e36d:	8b 45 bc             	mov    -0x44(%rbp),%eax
  800420e370:	48 89 ce             	mov    %rcx,%rsi
  800420e373:	48 89 f7             	mov    %rsi,%rdi
  800420e376:	89 c1                	mov    %eax,%ecx
  800420e378:	fc                   	cld    
  800420e379:	f2 6d                	repnz insl (%dx),%es:(%rdi)
  800420e37b:	89 c8                	mov    %ecx,%eax
  800420e37d:	48 89 fe             	mov    %rdi,%rsi
  800420e380:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
  800420e384:	89 45 bc             	mov    %eax,-0x44(%rbp)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
  800420e387:	c9                   	leaveq 
  800420e388:	c3                   	retq   
